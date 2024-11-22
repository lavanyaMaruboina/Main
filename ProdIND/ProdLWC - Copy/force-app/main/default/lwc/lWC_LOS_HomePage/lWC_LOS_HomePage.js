import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createLoanApplication from '@salesforce/apex/LWC_LOS_HomePage_Cntrl.createLoanApplication';
import checkUserRoleAccess from '@salesforce/apex/LWC_LOS_HomePage_Cntrl.checkUserRoleAccess';

export default class LWC_LOS_HomePage extends NavigationMixin(LightningElement) {
    @track showCreateLeadButton = true;
    @track showSpinner = false
    connectedCallback(){
        this.showSpinner = true;
        checkUserRoleAccess().then(result => {
            this.showSpinner = false;
            if(!result){
                this.showCreateLeadButton = false;
            }
        }).catch(error => {
            this.showSpinner = false;
            console.log('Error in checkUserRoleAccess() :: ',error);
        }); 
    }

    handleNavigateToApplicant() {      
        createLoanApplication().then(result => {
            console.dir(result)
            setTimeout(function() {
                //your code to be executed after 1 second
              }, 10000);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: 'Opportunity',
                    actionName: 'view',
                }
            });
        }).catch(error => {
            this.error = error;
            console.log('Error in creating Loan Application: ',error);
        });                
    }

  /*  publishRecordIs(id){
        const message={
            recordId: id
        }
        //publish(messageContext, messageChannel, message)
        publish(this.context, MESSAGE_CHANNEL, message)
    } */
}