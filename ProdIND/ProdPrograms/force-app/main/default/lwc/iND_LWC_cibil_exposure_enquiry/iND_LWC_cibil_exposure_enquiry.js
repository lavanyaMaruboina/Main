import { LightningElement, api } from 'lwc';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
import getCIBILExposureDetails from '@salesforce/apex/ExternalCAMDataController.getCIBILExposureDetails';

export default class IND_LWC_cibil_exposure_enquiry extends LightningElement {
    cIBILExposureContent = [];
    cIBILEnquiryContent = [];
    showCIBILExposure = false;
    showCIBILEnquiry = false;
    @api recordId;
    @api applicantId;
    @api loanApplicationId;
    message;
    hasCIBILContent=false;
    errorMsg='No data found';

    connectedCallback() {
        try {
            if(this.recordId){
                this.message = this.recordId.split(' ');
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
                    getCIBILExposureDetails({ loanAppId: this.loanApplicationId, applicantId: this.applicantId })
                    .then(response => {
                        console.log('response', response);
                        if (response && response.length > 0) {
                            if (response?.cIBILExposureContent?.length > 0) {
                                this.cIBILExposureContent =  response.cIBILExposureContent;
                                this.showCIBILExposure = true;
                            }
                            if(response?.cIBILEnquiryContent?.length > 0){
                                this.cIBILEnquiryContent = response.cIBILEnquiryContent;
                                this.showCIBILEnquiry = true;
                            }

                            if(this.showCIBILExposure || this.showCIBILEnquiry){
                                this.hasCIBILContent = true;
                            }
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