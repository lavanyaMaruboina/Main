import { LightningElement, track, api } from 'lwc';

import submitRCUCaseForApproval from '@salesforce/apex/RCUCaseController.submitRCUCaseForApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LWC_RCUManagerApprovalTractor extends NavigationMixin(LightningElement) {
    @api recordId;
    @track clickedOnce = false;
    @track isLoading = true;
    @api async invoke() {
        this.isLoading = true;
        if(this.clickedOnce == false){
            this.clickedOnce = true;
            let response = await submitRCUCaseForApproval({'caseId' : this.recordId});
            if(response != 'Approval sent successfully'){
                this.clickedOnce = false;
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: response,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                eval("$A.get('e.force:refreshView').fire();");
                this.isLoading = false;
                }else{
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: response,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                eval("$A.get('e.force:refreshView').fire();");
                this.isLoading = false;
            }
        }
    }
}