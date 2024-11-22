import { LightningElement, api, track } from 'lwc';
import getDeviationsForApprovals from '@salesforce/apex/CAMApprovalLogController.getDeviationsForApprovals';
import isJustificationProvided from '@salesforce/apex/CAMApprovalLogController.isJustificationProvided';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

export default class IND_LWC_ViewDeviation extends LightningElement {
    @track isModalOpen = false;
    @track deveiationResponse = [];
    @api receviedvaluefromparent;
    @api istractor;
    @api camrecordid;
    @track data;
    @track isDeviationTriggered=false;
    parentCamDeviationList = []
    @api iconButton = false;
    handledevi(){
        this.isModalOpen = this.receviedvaluefromparent.modalOpen;
        let camRecId = this.receviedvaluefromparent.camRecId;
        this.isDeviationTriggered = this.receviedvaluefromparent.isDeviationTriggered;
        this.renderedCallback();
        this.iconButton =  this.receviedvaluefromparent.iconButton;
        getDeviationsForApprovals({camID:camRecId})
        .then(response =>{
            if (response) {
                this.deveiationResponse = [];
                response.forEach(element => {
                    let obj = Object.create(element);
                    obj.Id = element.Id;
                    obj.justificationRemarks = element.Justification_Remarks__c;
                    obj.Source = element.Source__c;
                    obj.Type =element.Type__c;
                    obj.DeviationID = element.DeviationID__c;
                    obj.DeviationDescription = element.Type__c == 'Committee Deviation'?element.Parent_CAM__r.Loan_Application__r.Product_Type__c == 'Tractor' ? (element.Deviation_Level__c+ ` Committee for (${element.Deviation_Description__c}) ` + element.Role__c) : (element.Deviation_Level__c+ ' Committee for (Exposure) ' + element.Role__c):element.Deviation_Description__c;
                    obj.Role = element.Role__c;
                    obj.DeviationLevel = element.Deviation_Level__c;
                    obj.ApprovalStatus = element.Approval_Status__c;
                    obj.Remarks = element.Remarks__c;
                    obj.SourceAppNo = element.Source_AppNo__c;
                    this.deveiationResponse.push(obj);
                });  
                        
            }
        })
        .catch(error =>{
            console.error('error in handleDeviationClick ', error);
        });
    }

    

    @api
    openModal() {
        this.isModalOpen = true;
        this.handledevi();
    }
    closeModal() {
        this.isModalOpen = false;
    }

    async triggerDeviations () {
        let res = true;
        if(this.istractor){
            res = await isJustificationProvided({'camId' : this.camrecordid})
        }
        if(res){
            this.dispatchEvent(new CustomEvent('triggerdeviations'));
            this.isModalOpen = false;
        }else{
            this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: "Please enter justification remarks for all deviations!",variant: 'warning',}))
        }
    }

    renderedCallback(){
        if(this.isDeviationTriggered && this.istractor){
            this.template.querySelectorAll('lightning-input').forEach(ele=>{
                ele.disabled = true;
            })
        }
    }
    async justificationhandler(event){
        if(event.currentTarget.dataset.id){
            let fields = {};
            fields['Id'] = event.currentTarget.dataset.id;
            fields['Justification_Remarks__c'] = event.target.value;
            const recordInput = { fields };
            let result = await updateRecord(recordInput).then(() => {return true;});
            if(!result){
                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: "Data updation failed!",variant: 'error',}))
            }
        }
    }

}