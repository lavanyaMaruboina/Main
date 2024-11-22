import { LightningElement ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changeOwnerOfLA from '@salesforce/apex/RtoDpnPoaDocumentController.changeOwnerOfLA';
import { NavigationMixin } from 'lightning/navigation';
export default class Ind_LWC_AcceptCurrentOwner extends NavigationMixin(LightningElement) {

    @api recordId;

    connectedCallback(){
        console.log('OUTPUT : ',this.recordId);
        changeOwnerOfLA({ recordId: this.recordId })
          .then(result => {
            console.log('Result', result);
            let isSuccess = false;
            if(result == 'success'){     
                isSuccess = true;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Loan application has been assigned to you.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);  
                if(isSuccess){ 
                    this.navigatetoPage();
                }
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    navigatetoPage(){
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