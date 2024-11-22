import { LightningElement,track,wire,api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import EXISTINGTRACTORLOANINFORMATION_OBJECT from '@salesforce/schema/Existing_Tractor_Loan_Information__c';
import LOAN_TYPE_FIELD from '@salesforce/schema/Existing_Tractor_Loan_Information__c.Loan_Type__c';
import LOAN_FREE_FIELD from '@salesforce/schema/Existing_Tractor_Loan_Information__c.Loan_Free__c';
import LOAN_STAKEHOLDERS_FIELD from '@salesforce/schema/Existing_Tractor_Loan_Information__c.Loan_Stakeholders__c';

import saveExistingLoanDetails from '@salesforce/apex/iND_TF_FI_DetailsController.saveExistingLoanDetails';
import getExistingLoanDetails from '@salesforce/apex/iND_TF_FI_DetailsController.getExistingLoanDetails';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { deleteRecord } from 'lightning/uiRecordApi';
export default class LWC_LOS_ExistingTractorLoanInformation extends LightningElement {
    @api recordId;
    @api fieldInvestigationRecordId;

    @track filterList = [];
    @track loanTypeOptions=[];
    @track loanFreeOptions=[];
    @track loanStakeholdersOptions=[];

    totalTractorLoanStakeholders = 0.00;
    totalTractorLoanFamily = 0.00;

    keyIndex = 0;

    isSpinner = false;
    maxRows = 3;
    disableAddRows = false;

    //@track scrollableClass = 'slds-scrollable_x';

    get isDesktop(){
       // console.log('FORM_FACTOR '+FORM_FACTOR);
        if(FORM_FACTOR == 'Large'){
          //  this.scrollableClass = '';
            return true;
        }
        return false; 
    }
    get className(){
        return FORM_FACTOR!='Large' ? 'slds-scrollable_x': '';
    }

    refreshApexData;
    @wire(getExistingLoanDetails, { fieldInvestigationId: '$fieldInvestigationRecordId' })
    getExistingLoanDetailsValues(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('KCC And Other Loan Information @wire method >>'+JSON.stringify(data));
            this.filterList = [];
            this.filterList = data;
            this.filterList = data.map((item, index) => ({
                ...item,
                srNo: index + 1
            }));
            this.keyIndex = data.length;
            this.calculateTotalLoan();
            //this.totalTractorLoanStakeholders = data[0] && data[0].totalTractorLoanStakeholders !=undefined ? data[0].totalTractorLoanStakeholders : 0;
            //this.totalTractorLoanFamily = data[0] && data[0].totalTractorLoanFamily !=undefined ? data[0].totalTractorLoanFamily : 0;
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: EXISTINGTRACTORLOANINFORMATION_OBJECT })
    existingTractorLoanInformation;

    @wire(getPicklistValues, { recordTypeId: '$existingTractorLoanInformation.data.defaultRecordTypeId', fieldApiName: LOAN_TYPE_FIELD })
    loanTypeValues({ data, error }) {
        if (data) {
            console.log('Wire Existing picklist value==> '+JSON.stringify(data.values));
            data.values.forEach(val => {
                this.loanTypeOptions = [...this.loanTypeOptions, { value: val.value, label: val.label }];
            });
            console.log('Existing picklist value==> '+this.loanTypeOptions);
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$existingTractorLoanInformation.data.defaultRecordTypeId', fieldApiName: LOAN_FREE_FIELD })
    loanFreeValues({ data, error }) {
        if (data) {
            console.log('Wire Existing picklist value==> '+JSON.stringify(data.values));
            data.values.forEach(val => {
                this.loanFreeOptions = [...this.loanFreeOptions, { value: val.value, label: val.label }];
            });
            console.log('Existing picklist value==> '+this.loanFreeOptions);
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$existingTractorLoanInformation.data.defaultRecordTypeId', fieldApiName: LOAN_STAKEHOLDERS_FIELD })
    loanStakeholdersValues({ data, error }) {
        if (data) {
            console.log('Wire Existing picklist value==> '+JSON.stringify(data.values));
            data.values.forEach(val => {
                this.loanStakeholdersOptions = [...this.loanStakeholdersOptions, { value: val.value, label: val.label }];
            });
            console.log('Existing picklist value==> '+this.loanStakeholdersOptions);
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    async connectedCallback() {
        this.handleAddRow();
    }

    isInputValid(index) {
        let loanStartDate;
        let lastEMIdate;
        let valid = [
            ...this.template.querySelectorAll(`[data-id="${index}"]`)
        ].reduce((validSoFar, inputField) => {
            if (!inputField.checkValidity()){
                inputField.reportValidity();
            }

            if(inputField.name == "LOAN_AMOUNT__c"){
                let v = parseInt(inputField.value);
                if(v <= 0 ){
                    inputField.setCustomValidity("value cannot be less than or equal to 0.")
                }else{
                    inputField.setCustomValidity("");
                }
                inputField.reportValidity();
            }

            if(inputField.name == "EMI_Amount__c"){
                let v = parseInt(inputField.value);
                if(v <= 0 ){
                    inputField.setCustomValidity("value cannot be less than or equal to 0.")
                }else{
                    inputField.setCustomValidity("");
                }
                inputField.reportValidity();
            }

            if(inputField.name == 'Loan_Start_Date__c' || inputField.name == 'Last_EMI_Paid_Date__c'){
                let selectedDate = new Date(inputField.value);
                let currentDate = new Date();

                if(inputField.name == 'Loan_Start_Date__c'){
                    loanStartDate = new Date(inputField.value);
                }
                if(inputField.name == 'Last_EMI_Paid_Date__c'){
                    lastEMIdate = new Date(inputField.value);
                }

                if (selectedDate > currentDate) {
                    inputField.setCustomValidity("Date cannot be a future date.");
                } else if (inputField.name == 'Last_EMI_Paid_Date__c'){
                    if(loanStartDate > lastEMIdate){
                        inputField.setCustomValidity("Last EMI Paid Date should be greater than Loan Start Date.");
                    }else{
                        inputField.setCustomValidity("");
                    }
                }else if(inputField.name == 'Loan_Start_Date__c'){
                    inputField.setCustomValidity("");
                }
                inputField.reportValidity();
            }

            console.log('RECEIVED inputField >> '+inputField.name);
            console.log('RECEIVED inputValue >> '+inputField.value);
            return validSoFar && inputField.checkValidity();
        }, true);
        return valid;
    }

    @api isDisabled;
    renderedCallback() {
        if (this.isDisabled) {
            const allElements = this.template.querySelectorAll('*');
            allElements.forEach(element => {
                element.disabled = true;
            });
        }
    }
    handleAddRow(event) {
        if(!this.isInputValid(this.keyIndex)){
            return;
        }
        let objRow = {
            isValid : false,
            isDatabase: false,
            BANK_NAME:'',
            EMI_Amount:'',
            Last_EMI_Paid_Date:'',
            LOAN_AMOUNT:'',
            Loan_Free:'',
            Loan_number:'',
            Loan_Stakeholders:'',
            Loan_Start_Date:'',
            Loan_Type:'',
            Model_Details:'',
            Total_Remarks_by_FI_Agent:'',
            Total_Tractor_LoanFamily:0.00,
            Total_Tractor_Loan_Stakeholders:0.00,
            id: ++this.keyIndex,
            srNo: this.filterList.length+1,
            disableFields : false 
        }
        console.log('CURRENT KEY INDEX >>> '+(this.keyIndex-1)+' '+JSON.stringify(this.filterList));
        this.filterList.forEach(res=>{
            if(res.id == this.keyIndex-1){
                res.isValid = true;
            }
        });

        this.filterList = [...this.filterList, Object.create(objRow)];
        
        if(this.filterList.length>=this.maxRows){
            this.disableAddRows = true;
        }
    }

    handleRemoveRow(event) {
        let idToRemove = event.currentTarget.dataset.index;         //SFTRAC-614
        if (idToRemove && idToRemove.length === 18) {               //SFTRAC-614 checking Id length and calling delete method
            this.handleDeleteRow(event);
        } else {
            this.filterList = this.filterList.filter((ele) => {
                return parseInt(ele.id) !== parseInt(event.currentTarget.dataset.index);
            });
    
            if(this.filterList.length<10){
                this.disableAddRows = false;
            }
            this.filterList.forEach((row, index) => {
                row.srNo = index + 1;
            })
            this.keyIndex = this.filterList.length;
            
            if (this.filterList.length == 0) {
                this.handleAddRow();
            }
            this.calculateTotalLoan();
        }
    }

    get disableSave(){
        return this.filterList.reduce((valid,current)=>{
            return valid && current.isDatabase;
        },true);
    }

    handleDeleteRow(event){
        let idToRemove = event.currentTarget.dataset.index;
        deleteRecord(idToRemove) .then(() => {
            this.filterList = this.filterList.filter(item => item.id !== idToRemove);
            this.filterList.forEach((row, index) => {
                row.srNo = index + 1;
            });
    
            if(this.filterList.length<this.maxRows){
                this.disableAddRows = false;
            }
    
            if (this.filterList.length == 0) {
                this.handleAddRow();
            }
            //refreshApex(this.refreshApexData);
            this.calculateTotalLoan();
        }).catch(error => {
            console.log('++++HANDLE DELETEd error',error);
        });    
    }

    //SFTRAC-614 Starts
    handleEditRow(event){
        let currentRecId = event.currentTarget.dataset.index;
        const newRowsAdded = this.filterList.some(res => !res.isValid);
        let editDisableFlag = false;
        this.filterList.forEach(res=>{
            if(newRowsAdded && !editDisableFlag){
                editDisableFlag = true;
                this.showToastMessage('error', 'Cannot edit row while another row is being added or edited', 'Error');
                return;
            }else{
                if(res.id == currentRecId && !editDisableFlag){
                    res.isValid = false;
                    res.isDatabase = false;
                    //res.Land_Survey_No = res.Land_Survey_No;
                    this.disableAddRows = true;
                }
            }
        });
    }//SFTRAC-614 Ends

    saveRows() {
        console.log('this.filterList => ', this.filterList);
        console.log('Field Investigation Id : '+ this.fieldInvestigationRecordId);
        let recLst = this.filterList.filter(ele => ele.isValid == false);
        let isAllRowsValid = recLst.reduce((validSoFar, inputField) => {
            return validSoFar && this.isInputValid(inputField.id);
        },true);

        if(!isAllRowsValid){
            return;
        }

        this.filterList.forEach(res=>{
            if(res.isDatabase == false){
                res.isValid = true;
                res.isDatabase = false;
            }
        });
        this.isSpinner = true;
        saveExistingLoanDetails({ existingTractorLoanLst: this.filterList, fieldInvestigationId: this.fieldInvestigationRecordId }).then(result => {
            this.isSpinner = false;
            this.showToastMessage('success', 'Existing Tractor Loan Information is Saved Successfully!!', 'Success');
            console.log('result ==> ', result);
            let fields = {};
            fields['Id'] = this.fieldInvestigationRecordId;
            fields['Total_Tractor_Loan_Family__c'] = this.totalTractorLoanFamily;
            fields['Total_Tractor_Loan_Stakeholders__c'] = this.totalTractorLoanStakeholders;
            const recordInput = {
                fields
            };
            console.log('field' + JSON.stringify(fields));
            updateRecord(recordInput)
                .then(() => {
                    this.isSpinner = false;
                    this.showToastMessage('Success!', 'FI Updated Successfully', 'success', 'dismissable');
                    refreshApex(this.refreshApexData);
                    this.dispatchEvent(new CustomEvent('existingLoanInformationUpdated',{
                        detail:true
                    }));
                })
                .catch((error) => {
                    console.log('Error' + JSON.stringify(error));
                    this.isSpinner = false;
                    if (error.body.message) {
                        this.showToastMessage('Error!', error.body.message, 'error', 'sticky');
                    } else {
                        this.showToastMessage('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'sticky');
                    }
                });
        }).catch(error => {
            this.processErrorMessage(error);
            this.isSpinner = false;
        })
        if(this.filterList.length<this.maxRows){ //SFTRAC-614
            this.disableAddRows = false;
        }
    }

    handleChange(event){
        if (event.target.name == 'Loan_Type__c') {
            this.filterList[event.currentTarget.dataset.index].Loan_Type = event.target.value;
        }
        else if(event.target.name == 'Loan_Stakeholders__c') {
            this.filterList[event.currentTarget.dataset.index].Loan_Stakeholders = event.target.value;
            this.calculateTotalLoan();
        }
        else if(event.target.name == 'Loan_number__c') {
            this.filterList[event.currentTarget.dataset.index].Loan_number = event.target.value;
        }
        else if(event.target.name == 'LOAN_AMOUNT__c' && !Number.isNaN(event.target.value)) {
            this.filterList[event.currentTarget.dataset.index].LOAN_AMOUNT = event.target.value;
            this.calculateTotalLoan();
        }
        else if(event.target.name == 'BANK_NAME__c') {
            this.filterList[event.currentTarget.dataset.index].BANK_NAME = event.target.value;
        }
        else if(event.target.name == 'Loan_Start_Date__c') {
            this.filterList[event.currentTarget.dataset.index].Loan_Start_Date = event.target.value;
        }
        else if(event.target.name == 'EMI_Amount__c') {
            this.filterList[event.currentTarget.dataset.index].EMI_Amount = event.target.value;
        }
        else if(event.target.name == 'Last_EMI_Paid_Date__c') {
            this.filterList[event.currentTarget.dataset.index].Last_EMI_Paid_Date = event.target.value;
        }
        else if(event.target.name == 'Total_Remarks_by_FI_Agent__c') {
            this.filterList[event.currentTarget.dataset.index].Total_Remarks_by_FI_Agent = event.target.value;
        }
        else if(event.target.name=='Loan_Free__c'){
            let dataList = this.filterList;
            this.filterList = [];
            dataList[event.currentTarget.dataset.index].Loan_Free = event.target.value;
            // commenting below line - SFTRAC-453 SI#5
            //dataList[event.currentTarget.dataset.index].disableFields = event.target.value.toLowerCase() == 'no'; //SFTRAC-281 Bug.

            this.filterList =  dataList;
        }
        else if(event.target.name=='Model_Details__c'){
            this.filterList[event.currentTarget.dataset.index].Model_Details = event.target.value;
        }
    }

    calculateTotalLoan(){
        this.totalTractorLoanStakeholders = 0;
        this.totalTractorLoanFamily = 0;
        this.filterList.forEach(ele=>{
            let loan_stakeholders = ele.Loan_Stakeholders;
            let amount  = ele.LOAN_AMOUNT!=undefined && ele.LOAN_AMOUNT!=null && ele.LOAN_AMOUNT!="" ? parseFloat(ele.LOAN_AMOUNT):0.00;
            let allowedStakeHolders = ['borrower', 'co-borrower'];
            if(loan_stakeholders && allowedStakeHolders.includes(loan_stakeholders.toLowerCase()) ){
                this.totalTractorLoanStakeholders  += parseInt(amount);
            }else if(loan_stakeholders && !allowedStakeHolders.includes(loan_stakeholders.toLowerCase())){
                this.totalTractorLoanFamily += parseInt(amount);
            }
        });
    }

    processErrorMessage(message) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.showToastMessage('error', errorMsg, 'Error!');
    }

    showToastMessage(variant, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}