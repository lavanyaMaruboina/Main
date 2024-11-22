import { LightningElement, api, wire} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Opportunity_Relations from '@salesforce/schema/Documents__c.Opportunity_Relation__c';
import { NavigationMixin } from 'lightning/navigation';
import journeyRestart from '@salesforce/apex/LwcLosJourneyRestart.journeyRestart';
const field = [Opportunity_Relations];

//This class is use to perform journey Restart fuctionality : Raj G.
//IND-374
export default class IND_LWC_JourneyRestart extends NavigationMixin(LightningElement) 
{
    @api recordId;
    opportunityRelation
    @wire(getRecord, {recordId:'$recordId',fields : field})
    document;
    //fetch current record id o documents object.
    

    //handle yes button on click.
    handleYes(){
        //Call apex method which perform fetchig part.
        
        this.opportunityRelation = getFieldValue(this.document.data, Opportunity_Relations);
        //Navigate from Documents to Loan Application page.
       /* this[NavigationMixin.Navigate]({
                 "type": "standard__component",
                 "attributes": {
                    //aura component is use to navigate.
                     "componentName": "c__LoanApplicationJourneyRestart"
                 }
             });  
       */
             this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.opportunityRelation,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            }); 
            journeyRestart({documentID : this.recordId})

    }
    //handle No button on click.
    handleNo()
    {
        //use to close the quick action popup.
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}