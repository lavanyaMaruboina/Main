import { LightningElement,api, track, wire } from 'lwc';
import getReferenceCustomerOfApplicant from '@salesforce/apex/IND_LWC_ReferenceCustomer.getReferenceCustomerOfApplicant';
import updateReferedCustomerOfApplicant from '@salesforce/apex/IND_LWC_ReferenceCustomer.updateReferedCustomerOfApplicant';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class IND_LWC_ReferenceCustomers extends LightningElement {

    @track referenceCustomerRecords = [];
    @api applicantId;
    @api isDisabled;
    @api callingFromFIScreen;
    @track isValid = true;

    // SFTRAC - 25
    connectedCallback() {
        getReferenceCustomerOfApplicant({ applicantId: this.applicantId, refered:false}).then(result =>{ 
            
            let selectedIds = [];
            let tempRecords =[];
            if(result){
                result.forEach(record =>{
                    let tempObj ={};
    
                    if(record.Refered__c && record.Feedback__c) {
                        tempObj.disableRow = true;
                        tempObj.isChecked = true;
                    }
                    else{
                        tempObj.disableRow = false;
                        tempObj.isChecked = false;
                    }
                    tempObj.Id = record.Id;
                    tempObj.Name =record.Name;
                    tempObj.Phone = record.Phone__c;
                    tempObj.Address = record.AddressLine1__c +' '+record.AddressLine2__c;
                    tempObj.Maker_Date = record.Maker_Date__c.split(' ')[0];
                    tempObj.Product = record.Product__c ? record.Product__c : '';
                    tempObj.Exposure = record.Exposure__c ? record.Exposure__c : '';
                    tempObj.Feedback = record.Feedback__c ? record.Feedback__c : '';
                    tempObj.feedbackDisabled = true;

                    tempRecords.push(tempObj);
                })
                this.referenceCustomerRecords = tempRecords;
                
            }
            
        }).catch(error=>{
                console.log('Error while fetching Reference customers :'+error);
        })
    }

    // SFTRAC - 25
    @api async referenceHandler(){

        let response = {title:'title', type:'type', message:'message'};


        let totalCheckedFeedback = this.template.querySelectorAll('lightning-input[data-name="feedback"]');
        
        this.isValid = true;
        
        for(let i=0; i < this.referenceCustomerRecords.length; i++){
            totalCheckedFeedback.forEach(each =>{
                if(each.dataset.id == this.referenceCustomerRecords[i].Id ){
                    this.referenceCustomerRecords[i].Feedback = each.value;
                    if (!each.checkValidity()) {
                        each.reportValidity();
                        this.isValid = false;
                    }
                }
            })
        }

        let checkedLength = 0;
        let totalChecked = this.template.querySelectorAll('lightning-input[data-name="checkbox"]');
        totalChecked.forEach(each =>{
            if(each.checked){
                checkedLength++;
            }
        })
      
        if(this.referenceCustomerRecords && this.referenceCustomerRecords.length > 0){
        
            if(this.isValid){
                if(checkedLength <= 3 && checkedLength > 0){

                    let updateResponse = await updateReferedCustomerOfApplicant({customerReferencesResponse :JSON.stringify(this.referenceCustomerRecords) , applicantId :this.applicantId});
    
                    try{
                        if(updateResponse == 'SUCCESS'){
                            let tempObj = this.referenceCustomerRecords;
                            tempObj.forEach(each =>{
                                if(each.Feedback){
                                    each.disableRow = true;
                                    each.feedbackDisabled = true;
                                }
                            })
                            this.referenceCustomerRecords = tempObj;
                            response.title = 'Success';
                            response.type = 'success';
                            response.message = 'Reference Added';
                            return response;
                        }
                        else{
                            response.title = 'Failed';
                            response.type = 'error';
                            response.message = 'Reference Adding Failed';
                            return response;
                        }
                    }
                    catch(error){
                        response.title = 'Error';
                        response.type = 'error';
                        response.message = error;
                        return response;
                    }
                        
                           
                     
                }
                else if(checkedLength == 0){
                    response.title = 'Error';
                    response.type = 'error';
                    response.message = 'Please Select Atleast 1 Reference';
                    return response;
                }
            }
            else{
                response.title = 'Error';
                    response.type = 'error';
                    response.message = 'Please provide feedback for all selected customers';
                    return response;
            }
            
        }
        else{
            response.title = 'Error';
            response.type = 'error';
            response.message = 'Reference Customer Not Available';
            return response;
        }
    }


    async handleCheckboxChange(event){
        let checked = event.target.checked;
        let checkedLength = 0;
        let totalChecked = this.template.querySelectorAll('lightning-input[data-name="checkbox"]');
        totalChecked.forEach(each =>{
            if(each.checked){
                checkedLength++;
            }
        })

        let tempRecords = this.referenceCustomerRecords;

        if(checkedLength <= 3){
           
            await tempRecords.forEach(eachRecord =>{
                if(eachRecord.Id == event.target.dataset.id){
                    if(checked){
                        eachRecord.feedbackDisabled = false;
                    }
                    else{
                        eachRecord.feedbackDisabled = true;
                        let totalFeedback = this.template.querySelectorAll('lightning-input[data-name="feedback"]');
                        totalFeedback.forEach(eachFeedback =>{
                            if(eachFeedback.dataset.id == eachRecord.Id ){
                                eachFeedback.value ='';
                            }
                            
                        })

                    }
                }
            })
            this.referenceCustomerRecords = tempRecords;
        }
        else{
            event.target.checked = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'You Can Select Upto 3 References',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    renderedCallback() {
        let totalFeedback = this.template.querySelectorAll('lightning-input[data-name="feedback"]');
        totalFeedback.forEach(eachFeedback =>{
            if (!eachFeedback.checkValidity() && !eachFeedback.disabled) {
                eachFeedback.reportValidity();
            }
            else{
                eachFeedback.setCustomValidity('');
                eachFeedback.reportValidity();
            }
            
        })

        if(this.isDisabled || this.callingFromFIScreen){
            const allElements = this.template.querySelectorAll('*');
            allElements.forEach(element => {
                element.disabled = true;
            });
        }
    }
}