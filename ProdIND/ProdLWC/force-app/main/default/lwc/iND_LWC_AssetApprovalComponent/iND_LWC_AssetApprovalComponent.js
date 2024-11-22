import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import Message_Deviation_Mail_Triggered from '@salesforce/label/c.Message_Deviation_Mail_Triggered';

import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';
import triggerDeviationMail from '@salesforce/apex/IND_CAMWithoutSharing.triggerDeviationMail';
import checkCAMBeforeApproval from '@salesforce/apex/CAMApprovalLogController.checkCAMBeforeApproval';
import proposalApprove from '@salesforce/apex/CAMApprovalLogController.proposalApprove';

export default class IND_LWC_AssetApprovalComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api camRecId;
    @track isBtnClicked = false;;

    async handleApprove(event) {
        event.preventDefault();
        await this.triggerDeviationHandler('Approve');
    }

    async handleReject(event) {
        event.preventDefault();
        await this.triggerDeviationHandler('Reject');
    }

    async triggerDeviationHandler(proposalStatus) {
        try {
            let approvalStatus = await checkCAMBeforeApproval({ 'camRecordId': this.camRecId });
            if (!approvalStatus) {
                if (proposalStatus == 'Approve' && this.isBtnClicked == false) {
                    this.isBtnClicked = true;
                    await this.triggerDeviationsHandler(proposalStatus);
                } else if (proposalStatus == 'Reject') {
                    await this.proposalApproveHandler(proposalStatus);
                }
            } else {
                this.showAlert(approvalStatus);
            }
        } catch (error) {
            this.isBtnClicked = false;
            this.showAlert(error?.body?.message);
        }
    }

    async triggerDeviationsHandler(proposalStatus) {
        try {
            let response = await triggerDeviationMail({ camId: this.camRecId, caRemark: '', 'calledfrom': 'assetApprovalCmp' });
            if (response && response.length > 0) {
                let successResponse = response.length;
                let count = 0;
                for (let index = 0; index < response.length; index++) {
                    let emailRequestWrapper = response[index];
                    let result = await doEmailServiceCallout({ emailService: JSON.stringify(emailRequestWrapper) });
                    result = JSON.parse(result);
                    if (result && result.response && result.response.status == 'SUCCESS') {
                        count += 1;
                    }
                    if (count == successResponse) {
                        this.showAlert(Message_Deviation_Mail_Triggered);
                        await this.proposalApproveHandler(proposalStatus);
                    }
                }
            } else {
                await this.proposalApproveHandler(proposalStatus);
            }
        } catch (error) {
            this.isBtnClicked = false;
            this.showAlert(error?.body?.message);
        }
    }

    async proposalApproveHandler(proposalStatus) {
        try {
            let response = await proposalApprove({ 'camRecordId': this.camRecId, 'proposalStatus': proposalStatus });
            if (response) {
                this.showAlert(response);
                if (response == 'Proposal has been Approved.') {
                    window.location.reload();
                }
            }
        } catch (error) {
            this.isBtnClicked = false;
            this.showAlert(error?.body?.message);
        }
    }

    showAlert(message) {
        alert(message);
    }
}