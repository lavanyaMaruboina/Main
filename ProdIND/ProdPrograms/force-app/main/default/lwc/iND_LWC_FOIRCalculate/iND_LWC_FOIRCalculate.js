import { LightningElement, api,track } from 'lwc';
import { updateRecord,createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import EXISTING_EMI_ID_FIELD from '@salesforce/schema/Existing_EMI__c.Id';
import EMI_AMOUNT_FIELD from '@salesforce/schema/Existing_EMI__c.EMI__c';
import IS_RUN_EMI_ACCESSED_FIELD from '@salesforce/schema/Applicant__c.Is_RUN_EMI_Assessed__c';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import saveEMIDetails from '@salesforce/apex/Ind_ExistingEMICtrl.saveEMIDetails1';
import doRunEmiEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doRunEmiEngineCallout';
import loadExistingEMIData from '@salesforce/apex/Ind_ExistingEMICtrl.loadExistingEMIData';
import updateRetryCount  from  '@salesforce/apex/Ind_ExistingEMICtrl.updateRetryCount';
import calculateFoir from '@salesforce/apex/Ind_ExistingEMICtrl.calculateFoir';
import validateExistingEMISubmitActionTW from '@salesforce/apex/Ind_ExistingEMICtrl.validateExistingEMISubmitActionTW';
import getEmi from '@salesforce/apex/Ind_ExistingEMICtrl.getEmi';

export default class IND_LWC_FOIRCalculate extends LightningElement {
    @api activeTab;
    @api applicantId;
    @api recordId;
    @api tablength;
    @api currentStage;
    @api isTw;
    @api isPv;
    showRunEMI=true;
    showEMIDetails = false;
    showSpinner = false;
    showModalEMI=false;

    runEMiButtonX;
    showNoEMIMessage;
    
    get emiLabel(){
        if (this.isPv) {
            console.log('Proposed Loan EMI__');
            return 'Proposed Loan EMI';
        }else {
            console.log('Current Loan EMI__');
            return 'Current Loan EMI';
        }
    }

    get totalEmiLabel(){
        if (this.isPv) {
            return 'Existing EMI + Proposed Loan EMI';
        }else {
            return 'Total Existing EMI Obligation';
        }
    }
    
    disableRentalExpense=false;disableOtherObligation=false;monthlyIncome=0;@track rentalExpense=0;otherObligation=0;netMonthlyIncome=0;foirPercent;totalEmiObligation=0;showFoir=false;currentEMI=0;
    handleRentalExpenseChange(event){
        this.rentalExpense = this.roundOff(event.target.value);
        this.netMonthlyIncome =  this.roundOff(this.monthlyIncome) -(this.roundOff(this.rentalExpense)+this.roundOff(this.otherObligation));
    }
    handleOtherObligationChange(event){
        this.otherObligation = this.roundOff(event.target.value);
        //this.netMonthlyIncome = (this.roundOff(this.monthlyIncome)-(this.roundOff(this.rentalExpense)+this.otherObligation)).toFixed(2);
        this.netMonthlyIncome =  this.roundOff(this.monthlyIncome) -(this.roundOff(this.rentalExpense)+this.roundOff(this.otherObligation));
    }
    roundOff(inputParam) {
        if (inputParam === null || inputParam === undefined || inputParam === '' || inputParam === NaN) {
            return 0;

        } else {
            return Math.round(inputParam);
        }
    }
    label = {Regex_NumberOnly,Retry_Exhausted};
    async connectedCallback() {
        this.showSpinner = true;
        await this.init();
    }

    async init(){
        console.log('INit');
        console.log('INit pv__'+this.isPv);
        if(this.isPv){
            this.disableRentalExpense=true;this.disableOtherObligation=true;
        }
        await loadExistingEMIData({ loanApplicationId: this.recordId,  applicantId: this.applicantId}).then(result => { 
            console.log('result loadExistingEMIData___'+JSON.stringify(result));
            this.isRUNEMIAccessed =  result?.isRUNEMIAccessed;
            this.monthlyIncome = result?.monthlyIncome;
            this.rentalExpense = result?.rentalExpense;
            this.otherObligation = result?.otherObligation;
            this.foirPercent =result?.foirPercent; 
            this.netMonthlyIncome  = this.roundOff(this.monthlyIncome)-(this.roundOff(this.rentalExpense)+this.roundOff(this.otherObligation));

            let existingEMIDetails = result?.existingEMIDetails;
            let emiRetryCount = result?.retryCountDetails ? result?.retryCountDetails[0] : undefined;

            if(existingEMIDetails && existingEMIDetails.length > 0) {
                let existingEMIArr = [];
                let k=0;
                let emiValue=0;
                for (let index in existingEMIDetails) {
                    let isEMISubmittedFlag = true;
                    if(existingEMIDetails[index].EMI__c === null || existingEMIDetails[index].EMI__c === '' || existingEMIDetails[index].EMI__c === undefined){
                        isEMISubmittedFlag = false;
                    }
                    //Configure Data for display
                    let existingEMIObj = {
                        ...{ 'Id': k },
                        ...{ 'Sequential_Number': 'Loan ' + (parseInt(k+ 1) ) },
                        ...{ 'Loan_Type': existingEMIDetails[index].Loan_Type__c },
                        ...{ 'Outstanding_Amount': existingEMIDetails[index].Outstanding_Amount__c },
                        ...{ 'EMI__c': existingEMIDetails[index].EMI__c },
                        ...{ 'isEMISubmitted': isEMISubmittedFlag},
                        ...{ 'existing_emi_id': existingEMIDetails[index].Id },
                        ...{ 'upper_LimitEMI': existingEMIDetails[index].Upper_EMI_Limit__c },
                        ...{ 'lower_LimitEMI': existingEMIDetails[index].Lower_EMI_Limit__c }
                    };
                    k++;
                    existingEMIArr.push(existingEMIObj);
                    emiValue+=this.roundOff(existingEMIDetails[index].EMI__c);
                }
                //this.netMonthlyIncome = this.netMonthlyIncome - emiValue;
                this.existingEMIList = existingEMIArr;
                this.showEMIDetails = true;
                this.disableRunEMIBtn = true;
                this.totalEmiObligation=emiValue;
                this.showCheckedTickForRunEMI = true;this.showSpinner = false;
            } else if(emiRetryCount?.Count__c === 4) {
                this.showEMIDetails = false;
                this.disableRunEMIBtn = true;
                this.runEMiButtonX = true;this.showSpinner = false;
            } else if(emiRetryCount?.Count__c > 0 && emiRetryCount?.Count__c < 4 && this.isRUNEMIAccessed === true) {
                this.showEMIDetails = false;
                this.disableRunEMIBtn = true;
                this.showCheckedTickForRunEMI = true;
                this.showNoEMIMessage = true;
                this.showSpinner = false;
            }else{
                this.showSpinner = false;
            }

        }).catch(error => {
            console.log('loadExistingEMIData - Error', error);
            this.showSpinner = false;
        });

        await getEmi({ oppId: this.recordId}).then(result => { 
            this.currentEMI = result[0]?.EMI_Amount__c;
            this.currentEMI = this.roundOff(this.currentEMI);
            this.totalEmiObligation = this.roundOff(this.totalEmiObligation)+this.currentEMI;
            //this.netMonthlyIncome =  this.roundOff(this.monthlyIncome) -(this.roundOff(this.rentalExpense)+this.roundOff(this.otherObligation)+this.roundOff(this.totalEmiObligation)+this.roundOff(this.currentEMI));
        }).catch(error => {
            console.log('getEmi - Error', error);
            this.showSpinner = false;
        });
    }


    handleValid(event) {
        const tableData = event.target.value;    
        console.log('emiEntered__'+JSON.stringify(tableData));    
        const rowId = tableData.Id;
        let emiEntered = this.template.querySelectorAll('.emiInput');      
        console.log('emiEntered__'+JSON.stringify(emiEntered));    
        this.userEnteredEMI = emiEntered[rowId].value;
        console.log('emiEntered__'+this.userEnteredEMI); 
        let upperLimit = tableData.upper_LimitEMI;
        let lowerLimit = tableData.lower_LimitEMI;
        let validBtnId = this.template.querySelectorAll('.validbtn');
        // if ((parseFloat(this.userEnteredEMI) <  parseFloat(lowerLimit)) || (parseFloat(this.userEnteredEMI) > parseFloat(upperLimit))) {
        //     this.higherEMIFlag = true;
        //     this.showModalEMI = true;
        //     this.showCancelBtn = true;
        //     this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        //     return;
        // }
        if ((parseFloat(this.userEnteredEMI) > parseFloat(upperLimit)) && this.higherEMIFlag == false) {
            this.higherEMIFlag = true;
            this.showModalEMI = true;
            this.showCancelBtn = true;
            this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        } else if ((parseFloat(this.userEnteredEMI) > parseFloat(upperLimit)) && this.higherEMIFlag == true) {
            this.showModalEMI = false;
            this.showCancelBtn = false;
            this.modalMsgEMI = null;
            emiEntered[rowId].disabled = true;
            validBtnId[rowId].disabled = true;
            this.existingEMIList[rowId]['emi'] = this.userEnteredEMI;
            this.attempt=0;
            this.higherEMIFlag=false;
            this.updateEMIValue(tableData.existing_emi_id, this.userEnteredEMI);
        } else if ((parseFloat(this.userEnteredEMI) < parseFloat(lowerLimit)) && this.attempt <= 2) {
            this.attempt++;
            this.showModalEMI = true;
            this.showCancelBtn = true;
            this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        } else if ((parseFloat(this.userEnteredEMI) < parseFloat(lowerLimit)) && this.attempt > 2) {
            this.disableRunEMIBtn = true;
            this.userEnteredEMI = (parseFloat(upperLimit) + parseFloat(lowerLimit)) / 2;
            this.showModalEMI = false;
            this.showCancelBtn = false;
            this.modalMsgEMI = null;
            emiEntered[rowId].value = this.userEnteredEMI;
            emiEntered[rowId].disabled = true;
            validBtnId[rowId].disabled = true;
            this.higherEMIFlag = false;
            this.attempt = 0;
            this.updateEMIValue(tableData.existing_emi_id, this.userEnteredEMI);
        } else if ((parseFloat(this.userEnteredEMI) >=  parseFloat(lowerLimit) && (parseFloat(this.userEnteredEMI) <= parseFloat(upperLimit))) && (this.attempt > 2)) {
            this.attempt++;
            this.showModalEMI = true;
            this.showCancelBtn = true;
            this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        } else if ((parseFloat(this.userEnteredEMI) >=  parseFloat(lowerLimit) && (parseFloat(this.userEnteredEMI) <= parseFloat(upperLimit)))) {
            this.showModalEMI = false;
            this.showCancelBtn = false;
            this.modalMsgEMI = null;            
            emiEntered[rowId].disabled = true;
            validBtnId[rowId].disabled = true;
            this.existingEMIList[rowId]['emi'] = this.userEnteredEMI;
            this.higherEMIFlag = false;
            this.attempt=0;
            this.updateEMIValue(tableData.existing_emi_id, this.userEnteredEMI);
        } else if(upperLimit==='' || upperLimit=== null || upperLimit=== undefined || lowerLimit==='' || lowerLimit===null || lowerLimit=== undefined){
            this.showToastMessage('Warning','As Run EMI Engine gave negative response, no range to compare EMI value','warning');
        }
    }
    userEnteredEMI;disableRunEMIBtn;showCancelBtn;showModalEMI;modalMsgEMI;showCheckedTickForRunEMI;@track loanRecordsArray = [];higherEMIFlag=false;attempt = 0;
    handleRunEMI() {
        this.showSpinner = true;
        updateRetryCount({  applicantId: this.applicantId, loanAppId :this.recordId }).then(response => {
            console.log('updateRetryCount - response:: ', response);
            if (response === this.label.Retry_Exhausted){
                this.disableRunEMIBtn = true;
                this.runEMiButtonX = true;
                this.showEMIDetails = false;
                this.showCancelBtn = true;
                this.showModalEMI = true;
                this.modalMsgEMI = 'You have reached maximum attempt to RUN EMI Engine';
                this.showSpinner =  false;
            } else {
                let runEMIDetails = {
                    'applicantId': this.applicantId,
                    'loanApplicationId': this.recordId,
                };

                doRunEmiEngineCallout({'runEmiEngine': JSON.stringify(runEMIDetails)}).then(result => {
                    console.log('DoRunEmiEngineCallout - result::', result);
                    let custObj;
                    let resArr = [JSON.parse(result)];
                    let emiRanges = resArr[0].emiRanges;
                    let k = 0;
                    let updatedResp=[]
                  
                    for (var i = 0; i < emiRanges.length; i++) {
                        if(emiRanges[i].Outstanding_Amt>0){               
                            custObj = {
                                ...{ 'Id': k },
                                ...{ 'Loan_Type': emiRanges[i].Loan_Type },
                                ...{ 'Outstanding_Amount': emiRanges[i].Outstanding_Amt },
                                ...{ 'Sequential_Number': 'Loan ' + (parseInt(k+1) ) },
                                ...{ 'upper_LimitEMI': emiRanges[i].Upper_Emi_Cap },
                                ...{ 'lower_LimitEMI': emiRanges[i].Lower_Emi_Cap },
                                ...{ 'emi': '' },
                                ...{ 'existing_emi_id': ''}
                            };
                            console.log('custObj:: ',custObj);
                            updatedResp.push(custObj);
                            k++;
                        }                   
                    }

                    this.existingEMIList = updatedResp;
                    this.showEMIDetails = true;
                    this.showCheckedTickForRunEMI = true;
                    this.disableRunEMIBtn = true;
                   
                    if(emiRanges.length>0) {
                        this.saveValidatedEMIData();
                    } else {
                        this.showEMIDetails = false;
                        this.showNoEMIMessage = true;
                    }

                    //Update API Fields
                    const fields = {};
                    fields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                    fields[IS_RUN_EMI_ACCESSED_FIELD.fieldApiName] = true;
                    const recordInput = {fields};

                    updateRecord(recordInput).then(() => {
                        console.log('Applicant Record for EMI Update is Successful:: ', JSON.stringify(fields));
                    }).catch(error => {
                        console.log('Error in updating reocrd:: ', error);
                        this.showToastMessage(null, 'Error in saving Existing EMI data', 'Error');
                    });

                    this.showSpinner = false;
                }).catch(error => {
                    this.showSpinner = false;
                    this.showEMIDetails = false;
                    this.showModalEMI = true;
                    this.showCancelBtn = true;
                    this.modalMsgEMI = error?.body?.message;
                    console.log('retryCountUpdate - Error', error);
                });
            }
        }).catch(error => {
            console.log('retryCountUpdate - Error', error);
        });
    }

    saveValidatedEMIData() {
        this.showSpinner=true;
        saveEMIDetails({ emiData: JSON.stringify(this.existingEMIList), applicantId: this.applicantId }).then(response => {
            let k=0;
            let custObj

            for (var i = 0; i < response.length; i++) {
                custObj = {
                    ...{ 'Id': k },
                    ...{ 'Loan_Type': response[i].Loan_Type__c },
                    ...{ 'Outstanding_Amount': response[i].Outstanding_Amount__c },
                    ...{ 'Sequential_Number': 'Loan ' + (parseInt(k+1) ) },
                    ...{ 'upper_LimitEMI': response[i].Upper_EMI_Limit__c },
                    ...{ 'lower_LimitEMI': response[i].Lower_EMI_Limit__c },
                    ...{ 'emi': '' },
                    ...{ 'existing_emi_id': response[i].Id}
                };
                this.loanRecordsArray.push(custObj);
                k++;
            }

            this.existingEMIList = this.loanRecordsArray;
            this.showSpinner=false;
        }).catch(error => {
            this.showToastMessage('', 'Something Went Wrong!', 'Error');
            console.log('getEMIExecutedValue - saveEMIDetails - Error:: ', error);
            this.showSpinner = false;
        });
    }

    updateEMIValue(existingEMIid, enteredEMIValue){
        const fields = {};
        fields[EXISTING_EMI_ID_FIELD.fieldApiName] = existingEMIid;
        fields[EMI_AMOUNT_FIELD.fieldApiName] = enteredEMIValue;
        const recordInput = {fields};
        this.totalEmiObligation = this.roundOff(this.totalEmiObligation);
        console.log('totalEmiObligation___'+this.totalEmiObligation);
        this.totalEmiObligation += this.roundOff(enteredEMIValue);
        console.log('totalEmiObligation___r'+this.totalEmiObligation);
        // this.existingEMIList.forEach(record =>{
        //    if (record.existing_emi_id !== existingEMIid) {
        //         this.totalEmiObligation += parseFloat(enteredEMIValue);
        //     }
        // });
        //this.netMonthlyIncome =  this.roundOff(this.monthlyIncome) -(this.roundOff(this.rentalExpense)+this.roundOff(this.otherObligation)+this.roundOff(this.totalEmiObligation));
        updateRecord(recordInput).then(() => { 
            this.showToastMessage('','EMI Amount Updated Successfully','success');
        }).catch(error => {
            console.log('Error in updating EMI Amount:: ', error);
            this.showToastMessage('', 'Error in saving Existing EMI details', 'Error');
            return;
        });
    }

    async runFoir(){
    this.showSpinner = true;
    let allowSubmitActions = false;
    await validateExistingEMISubmitActionTW({ applicantId: this.applicantId }).then(result => {
        console.log('validateExistingEMISubmitAction - Result:: ', result);
        if(result?.allowed === 'false'){
            this.showToastMessage('', result?.message, 'warning');
            this.showSpinner = false;
        } else {
            allowSubmitActions = true;
        }
    }).catch(error => {
        console.log('validateExistingEMISubmitAction - Error:: ', error);
        this.showToastMessage('Error in validating Existing EMI details', error, 'warning');
        this.showSpinner = false;
    });

    if(allowSubmitActions){
        this.rentalExpense = this.roundOff(this.rentalExpense);
        this.otherObligation = this.roundOff(this.otherObligation);
        this.currentEMI = this.roundOff(this.currentEMI);
        await calculateFoir({ applicantId: this.applicantId, rentalExpense: this.rentalExpense, otherObligation: this.otherObligation, currentEMI: this.currentEMI}).then(result => {
            this.showFoir=true;
            //let response = result.loanAgreement;
            this.foirPercent = result.foirPercent;
            this.totalEmiObligation = result.totalEmiObligation;
            this.showSpinner = false;
        }).catch(error => {
        console.log('calculateFoir - Error:: ', error);
        this.showToastMessage('Error in calculating FOIR', error, 'warning');
        this.showSpinner = false;
    });
    }
}

    showToastMessage(title, message, variant) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
            }));
        }
    }

    handleModalCancelAction() {
        this.showModalEMI = false;
        this.showCancelBtn = false;
        this.modalMsgEMI = null;
    }

    handleModalOkAction() {
        this.showModalEMI = false;
        this.showCancelBtn = false;
        this.modalMsgEMI = null;
    }
}