import {LightningElement,api,wire,track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord,getFieldValue} from "lightning/uiRecordApi";
import {CloseActionScreenEvent} from 'lightning/actions';
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import OWNER_ID from "@salesforce/schema/Case.OwnerId";
import CURRENTUSERID from '@salesforce/user/Id';
import createCase from '@salesforce/apex/OffRollEmpApproval.createCase';
import UpdateFieldsOnConformation from '@salesforce/apex/OffRollEmpApproval.UpdateFieldsOnConformation';


const fields = [STATUS_FIELD, OWNER_ID];
export default class iND_LWC_ApplicationApprovalByOffRollEmployee extends LightningElement {

  userId = CURRENTUSERID;
  @api recordId;
  @track name;

  @track checkValue1;
  @track checkValue2;
  @track checkValue3;
  @track checkValue4;
  @track checkValue5;//CISP-3082 OR CISP-3090

  @wire(getRecord, {
    recordId: '$recordId',
    fields
  })
  case;

  handleConfirm() {    
    
    if (this.OwnerId == this.userId) {
        UpdateFieldsOnConformation({
          CaseId: this.recordId
        })
        .then(result => {        
          console.log('in success'); 
          const event = new ShowToastEvent({
            title: 'Submit Success',
            message: 'Your response has been Submitted !',
            variant: 'success',
            mode: 'dismissable'
          });
          this.dispatchEvent(event);
          this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
          console.log('error '+error);
          this.dispatchEvent(new CloseActionScreenEvent());
        });
       
    } else {      
      const evt = new ShowToastEvent({
        title: 'Toast Error',
        message: 'You are not Approver',
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(evt);
      this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    
  }

  get status() {
    return getFieldValue(this.case.data, STATUS_FIELD);
  }

  get OwnerId() {
    return getFieldValue(this.case.data, OWNER_ID);
  }
}