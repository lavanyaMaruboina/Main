import { LightningElement,api,wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import CREATED_BY_ID from '@salesforce/schema/Case.CreatedById';

//Array to store the fields that we need to fetch.
const FIELDS = [CREATED_BY_ID];

export default class IND_LWC_CMUAcceptReject extends LightningElement {
    //Attribute to store the value Object API Name 
    @api objectApiName = 'Case';
    //Attribute to store the value of current Record Id.
    @api recordId ;
    //Attribute to store the label of button which is clicked from the UI.
    clickedButton = '';

    //Fetching the value of fields of current record.
    @wire(getRecord, {recordId: '$recordId',fields: FIELDS})
    case;

    //Handler for accept button onclick event.
    handleAccept(event){
        this.clickedButton =event.target.label;
    }
    //Handler for reject button onclick event.
    handleReject(event){
        this.clickedButton =event.target.label;
    }

    //Handler for record-edit-form obsubmit event.
    handleSubmit(event){
        //Stopping the form from submitting.
        event.preventDefault();

        //fetching the fields of record-edit-form.
        const fields = event.detail.fields;
        //Attribute to store the value of created by user id.
        const createdById = this.case.data.fields.CreatedById.value;

        //If the accept button is clicked, Checking the CMU_Accept checkbox.
        if(this.clickedButton == 'Accepts'){
            fields.CMU_Accept__c = true;
        }
        //If the reject button is clicked. Assigning the case back to the one who created the case. 
        else if(this.clickedButton =='Reject'){
            fields.OwnerId = createdById;
        }
        //Submitting the form.
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }   
}