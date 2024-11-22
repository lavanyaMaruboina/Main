import { LightningElement, track, api } from 'lwc';

import changeOwner from '@salesforce/apex/LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LWC_LOS_CMUCaseOwnerChangeFlow extends NavigationMixin(LightningElement) {
    @track isLoading;
    @api recordId;
    @api async invoke() {
        changeOwner({caseId : this.recordId})
        .then(response => {
            eval("$A.get('e.force:refreshView').fire();");
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Owner succesfully updated',
                variant: 'success',
            });
            this.dispatchEvent(evt);
            this.navigateToCaseHome();
        })
        .catch(error => {
            console.log('error::',error)
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            eval("$A.get('e.force:refreshView').fire();");
        });
    }
 
    navigateToCaseHome(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'}
            });
    }
}