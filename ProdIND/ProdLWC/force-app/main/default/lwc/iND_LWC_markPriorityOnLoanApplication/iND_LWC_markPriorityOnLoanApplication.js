import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updatePriorityFlagLoanApp from '@salesforce/apex/RtoDpnPoaDocumentController.updatePriorityFlagLoanApp';
import { NavigationMixin } from 'lightning/navigation';

export default class IND_LWC_markPriorityOnLoanApplication extends NavigationMixin(LightningElement) {

    @api recordId;
    connectedCallback(){
        console.log('OUTPUT : ',this.recordId);
        updatePriorityFlagLoanApp({ recordId: this.recordId })
          .then(result => {
            console.log('Result', result);
            let isSuccess = false;
            if(result == 'success'){     
                isSuccess = true;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Priority Has been updated successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);  
                if(isSuccess){ 
                    this.navigatetoList();
                }
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }

    navigatetoList(){
        console.log('OUTPUT ----: ',);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }
}