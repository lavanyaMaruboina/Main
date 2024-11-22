import { LightningElement, api } from 'lwc';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
import getCIBILTimelineDetails from '@salesforce/apex/ExternalCAMDataController.getCIBILTimelineDetails';

export default class IND_LWC_CIBIL_TimeLine_Details extends LightningElement {
    @api recordId;
    @api message;
    showCIBILTimeline = false;
    cIBILTimelineContent = [];
    loanApplicationId;
    applicantId;
    errorMsg='No data found';

    connectedCallback() {
        try {
            if (this.recordId) {
                this.message = this.recordId.split('-');
                this.recordId = this.message[0];
                this.getRequestDetails();
            }
        } catch (error) {
            console.error(error);
        }
    }
    getRequestDetails() {
        getRequestDetails_MTD({ camId: this.recordId })
            .then(response => {
                console.log('getRequestDetails', JSON.stringify(response));
                if (response) {
                    if(this.message[1]=='Borrower'){
                        this.applicantId = response.applicantId;
                    } else if(this.message[1]=='CoBorrower'){
                        this.applicantId = response.coBorrowerApplicantId;
                    }
                    this.loanApplicationId = response.loanAppId;
                    console.log('recordId', this.recordId, this.applicantId, this.loanApplicationId);

                    if (this.applicantId && this.loanApplicationId) {
                        getCIBILTimelineDetails({ loanAppId: this.loanApplicationId, applicantId: this.applicantId })
                            .then(response => {
                                console.log('response', response);
                                if (response && response.length > 0) {
                                    this.cIBILTimelineContent = response;
                                    this.showCIBILTimeline = true;
                                }
                            })
                            .catch(error => {
                                console.error(error);
                            })
                    }
                }
            });
    }

    handleCloseButton() {
        self.close();
    }
}