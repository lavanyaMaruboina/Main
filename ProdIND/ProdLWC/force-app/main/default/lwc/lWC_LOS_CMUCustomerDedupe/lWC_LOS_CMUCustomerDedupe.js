import { api, LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDetails from '@salesforce/apex/LWC_LOS_CMUCustomerDedupe_cntrl.getRecordDetails';
import checkCustomerResponseAvailable from '@salesforce/apex/LWC_LOS_CMUCustomerDedupe_cntrl.checkCustomerResponseAvailable'; //CISP-4376
import dedupeSubmitByCMU from '@salesforce/apex/Ind_CustomerDedupCtrl.dedupeSubmitByCMU';
import checkCaseClosed from '@salesforce/apex/LWC_LOS_CMUCustomerDedupe_cntrl.checkCaseClosed';
export default class LWC_LOS_CMUCustomerDedupe extends LightningElement {
    @api recordId;
    @track applicantsList;
    @track showCustomerDedupe = false;
    @track isCMUExecution = true;
    @track dedupeSubmitDisable = false;
    @track oppId;
    @track validatedApplicantList;
    @track showValidatedMsg = false;
    @track isTractor = false;
    @track showValidateMsgList = [];
    validateCoBorrowerMsg;
    validateBorrowerMsg;
    validateCoBorrower = false;
    validateBorrower = false;
    async connectedCallback(){ 
        //Calling apex method to get the details from Apex Class.       
        await getRecordDetails({caseId : this.recordId})
        .then((response) => {
            console.log('caseDetails::',response);
            this.oppId = response.caseRecord.Loan_Application__c;
            this.isTractor = response.caseRecord.Loan_Application__r.Product_Type__c == 'Tractor' ? true : false;
            this.applicantsList = response.applicantDetails;
            this.validatedApplicantList = response.validatedApplicantList;
            if(this.applicantsList.length > 0){
                this.showCustomerDedupe = true;
                this.oppId = this.applicantsList[0].Opportunity__c;
            }else{
                this.showCustomerDedupe = false;
                dedupeSubmitByCMU({ oppId: this.oppId })
                .then(result => {
                    console.log('Result', result);
                    this.dedupeSubmitDisable = result;
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            }
            if(this.isTractor){
                if(this.validatedApplicantList && this.validatedApplicantList.length > 0){
                    for (let index = 0; index < this.validatedApplicantList.length; index++) {
                        const element = this.validatedApplicantList[index];
                        this.showValidateMsgList.push({
                            validateMsg : element.Customer_Dedupe_Response__r[0].Dedupe_Journey_Status_Reason__c,
                            applicantType : element.Applicant_Type__c,
                            applicantName : element.Name,
                        });
                    }
                    this.showValidatedMsg = true;
                }
            }else{
                if(this.validatedApplicantList.length == 1){
                    this.showValidatedMsg = true;
                    if(this.validatedApplicantList[0].Applicant_Type__c.toLowerCase() === 'Borrower'.toLowerCase()){
                        this.validateBorrower = true;
                        this.validateBorrowerMsg = this.validatedApplicantList[0].Customer_Dedupe_Response__r[0].Dedupe_Journey_Status_Reason__c;
                    }else{
                        this.validateCoBorrower = true;
                        this.validateCoBorrowerMsg = this.validatedApplicantList[0].Customer_Dedupe_Response__r[0].Dedupe_Journey_Status_Reason__c;
                    }
                }
                if(this.validatedApplicantList.length == 2){
                    this.showValidatedMsg = true;
                    this.validateBorrower = true;
                    this.validateCoBorrower = true;
                    let resultMap = response.applicantDedupeMap;
                    this.validateBorrowerMsg = resultMap["Borrower"];
                    this.validateCoBorrowerMsg = resultMap["Co-borrower"];
                }
                //applicationId = caseDetails.Loan_Application__c;
            }
        })
        .catch((error) => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            eval("$A.get('e.force:refreshView').fire();");
        });
        checkCaseClosed({ caseId : this.recordId })
          .then(result => {
            console.log('Result', result);
            if(result)
                this.dedupeSubmitDisable = result;
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    async handleDedupeSubmit(){
        console.log('OUTPUT handleDedupeSubmit: ',);
        //CISP-4376 start
        let responseNull = false;
        await checkCustomerResponseAvailable({ oppId: this.oppId })
          .then(result => {
            console.log('Result', result);
            if(result){
                result.forEach(currentItem => {
                    console.log('currentItem : ',currentItem);
                    console.log('currentItem : ',currentItem.Customer_Dedupe_Response__r);
                    if(currentItem.Customer_Dedupe_Response__r[0].Response__c == null){
                        responseNull = true;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Dedupe response can not be null please re-trigger customer dedupe',
                            variant: 'Error',
                        });
                        this.dispatchEvent(evt);
                        return null;
                    }
                    else if(currentItem.isAllRowSelected__c == false && currentItem.isCodeValidateBySalesUser__c == false && currentItem.Customer_Dedupe_Response__r[0].Dedupe_Journey_Status_Reason__c != 'There are no matching code available for the applicant, hence journey will proceed as new customer'){
                        responseNull = true;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Please validate all customer code',
                            variant: 'Error',
                        });
                        this.dispatchEvent(evt);
                        return null;
                    }
                   
                });
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });//CISP-4376 
        if(responseNull == false){
            await dedupeSubmitByCMU({ oppId: this.oppId })
            .then(result => {
                console.log('Result', result);
                this.dedupeSubmitDisable = result;
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }
    }
}