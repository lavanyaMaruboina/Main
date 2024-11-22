import { LightningElement,track,wire,api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import KCCANDOTHERLOANINFORMATION_OBJECT from '@salesforce/schema/KCC_And_Other_Loan_Information__c';
import LOAN_TYPE_FIELD from '@salesforce/schema/KCC_And_Other_Loan_Information__c.Loan_Type__c';
import LOAN_STAKEHOLDERS_FIELD from '@salesforce/schema/KCC_And_Other_Loan_Information__c.Loan_Stakeholders__c';

import saveKCCAndOtherLoanDetails from '@salesforce/apex/iND_TF_FI_DetailsController.saveKCCAndOtherLoanDetails';
import getKCCOtherLoanInformationRecords from '@salesforce/apex/iND_TF_FI_DetailsController.getKCCOtherLoanInformationRecords';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { deleteRecord } from 'lightning/uiRecordApi';
export default class LWC_LOS_KCCAndOtherLoanInformation extends LightningElement {
    @api recordId;
    @api fieldInvestigationRecordId;
    @track filterList = [];
    loanTypeOptions=[];
    loanStakeholdersOptions=[];
    sumOfAllLoanTypeKCC = 0;
    sumOfAllLoanTypeNonKCC = 0;
    keyIndex = 0;

    isSpinner = false;
    maxRows = 5;
    disableAddRows = false;

   // @track scrollableClass = 'slds-scrollable_x';

    get isDesktop(){
        //console.log('FORM_FACTOR '+FORM_FACTOR);
        if(FORM_FACTOR == 'Large'){
            //this.scrollableClass = '';
            return true;
        }
        return false; 
    }
    get className(){
        return FORM_FACTOR!='Large' ? 'slds-scrollable_x': '';
    }

    refreshApexData;
    @wire(getKCCOtherLoanInformationRecords, { fieldInvestigationId: '$fieldInvestigationRecordId' })
    getKCCOtherLoanInformationRecordsValues(result) {
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
            if(this.filterList.length>=this.maxRows){
                this.disableAddRows = true;
            }
            this.keyIndex = data.length;
            this.sumOfAllLoanTypeKCC = data[0].sumOfAllLoanTypeKCC != undefined ?  data[0].sumOfAllLoanTypeKCC : 0;
            this.sumOfAllLoanTypeNonKCC = data[0].sumOfAllLoanTypeNonKCC !=undefined ? data[0].sumOfAllLoanTypeNonKCC : 0;
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: KCCANDOTHERLOANINFORMATION_OBJECT })
    kccAndOtherLoanInformation;
    allloanTypeOptions=[];
    @wire(getPicklistValues, { recordTypeId: '$kccAndOtherLoanInformation.data.defaultRecordTypeId', fieldApiName: LOAN_TYPE_FIELD })
    loanTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.loanTypeOptions = [...this.loanTypeOptions, { value: val.value, label: val.label }];
            });
            this.allloanTypeOptions = this.loanTypeOptions;
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$kccAndOtherLoanInformation.data.defaultRecordTypeId', fieldApiName: LOAN_STAKEHOLDERS_FIELD })
    loanStakeholdersValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.loanStakeholdersOptions = [...this.loanStakeholdersOptions, { value: val.value, label: val.label }];
            });
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
        let type;
        let valid = [
            ...this.template.querySelectorAll(`[data-id="${index}"]`)
        ].reduce((validSoFar, inputField) => {
            if (!inputField.checkValidity()){
                inputField.reportValidity();
            }
            console.log('RECEIVED inputField >> '+inputField.name);
            console.log('RECEIVED inputValue >> '+inputField.value);
            /*SFTRAC-278 start*/
            if(inputField.name == 'LOAN_AMOUNT__c'){
                let v = parseInt(inputField.value);
                if(v <= 0 ){
                    inputField.setCustomValidity("value cannot be less than or equal to 0.")
                }else{
                    inputField.setCustomValidity("");
                }
                inputField.reportValidity();
            }
            if(inputField.name == 'EMI_Amount__c'){
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
            /*SFTRAC-278 close*/
            if(inputField.name == "Loan_Type__c"){
                type = inputField.value;
            }
            if(inputField.name == "Model_Details__c"){
                let v = inputField.value;
                if((v==='' || v===undefined || v===null) && (type == "CAR" || type == "TW") ){
                    inputField.setCustomValidity("Please Enter Model Details")
                }else{
                    inputField.setCustomValidity("");
                }
                inputField.reportValidity();
            }
            return validSoFar && inputField.checkValidity();
        }, true);
        return valid;
    }

    @api isDisabled;
    @api exactExistingNoVehicleValue;
    @api get existingNoVehicleValue() {
        return this.exactExistingNoVehicleValue;
    }

    set existingNoVehicleValue(value) {
        this.exactExistingNoVehicleValue = value;
        if(this.exactExistingNoVehicleValue == 'No Assets'){
            this.loanTypeOptions = this.loanTypeOptions.filter(option => option.value === 'KCC');
        }else{
            this.loanTypeOptions = this.allloanTypeOptions;
        }
    }
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
            Loan_Type: '',
            Loan_Stakeholders: '',
            Loan_number: '',
            LOAN_AMOUNT: '',
            BANK_NAME: '',
            Loan_Start_Date: '',
            Model_Details:'',
            EMI_Amount: '',
            Last_EMI_Paid_Date: '',
            Total_Remarks_by_FI_Agent:'',
            sumOfAllLoanTypeKCC:0.00,
            sumOfAllLoanTypeNonKCC:0.00,
            id: ++this.keyIndex,
            srNo: this.filterList.length+1,
            modalDetailsRequired : false
        }

        this.filterList = [...this.filterList, Object.create(objRow)];
        console.log('CURRENT KEY INDEX >>> '+(this.keyIndex-1)+' '+JSON.stringify(this.filterList));
        if(this.keyIndex != undefined){
            this.filterList.forEach(res=>{
                if(res.id == this.keyIndex-1){
                    res.isValid = true;
                    res.isDatabase = false;
                }
            });
        }
        // this.filterList.forEach(res=>{
        //     if(res.id == this.keyIndex-1){
        //         res.isValid = true;
        //         res.isDatabase = false;
        //     }
        // });

        
        console.log('CURRENT KEY INDEX >>> '+(this.keyIndex-1)+' '+JSON.stringify(this.filterList));
        
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
    
            if(this.filterList.length<this.maxRows){
                this.disableAddRows = false;
            }
            this.filterList.forEach((row, index) => {
                row.srNo = index + 1;
            })
            this.keyIndex = this.filterList.length;
            if (this.filterList.length == 0) {
                this.handleAddRow();
            }
            this.calculateTotalLoanAmount()
        }  
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
        }).catch(error => {
            console.log('++++HANDLE DELETEd error');
        });    
    }

    get disableSave(){
        return this.filterList.reduce((valid,current)=>{
            return valid && current.isDatabase;
        },true);
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
                    return;
                }
            }
        });
    }//SFTRAC-614 Ends

    saveRows() {
        console.log('this.filterList => ', this.filterList);
        console.log('Field Investigation Id : '+ this.fieldInvestigationRecordId);
        console.log('this.filterList SAVING => ', JSON.stringify(this.filterList));
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
        saveKCCAndOtherLoanDetails({ kccAndOtherLoanLst: this.filterList, fieldInvestigationId: this.fieldInvestigationRecordId }).then(result => {
            this.showToastMessage('success', 'KCC AND Other Loan Information has been saved Successfully!!', 'Success');
            console.log('result ==> ', result);
            let fields = {};
            fields['Id'] = this.fieldInvestigationRecordId;
            fields['Total_KCC_Loan_Stakeholders__c'] = this.sumOfAllLoanTypeKCC;
            fields['Total_HL_CAR_PL_TW_Loan__c'] = this.sumOfAllLoanTypeNonKCC;
            const recordInput = {
                fields
            };
            console.log('field' + JSON.stringify(fields));
            updateRecord(recordInput)
                .then(() => {
                    this.isSpinner = false;
                    this.showToastMessage('Success!', 'FI Updated Successfully', 'success', 'dismissable');
                    refreshApex(this.refreshApexData);
                    this.dispatchEvent(new CustomEvent('kccInformationUpdated',{
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
            let dataList = this.filterList;
            this.filterList = [];
            dataList[event.currentTarget.dataset.index].Loan_Type = event.target.value;
            let modalDetailMandatoryTypes = ['car','tw'];
            dataList[event.currentTarget.dataset.index].modalDetailsRequired = modalDetailMandatoryTypes.includes(event.target.value.toLowerCase());
            this.filterList = dataList;
        }
        else if(event.target.name == 'Loan_Stakeholders__c') {
            this.filterList[event.currentTarget.dataset.index].Loan_Stakeholders = event.target.value;
        }
        else if(event.target.name == 'Loan_number__c') {
            this.filterList[event.currentTarget.dataset.index].Loan_number = event.target.value;
        }
        else if(event.target.name == 'LOAN_AMOUNT__c') {
            this.filterList[event.currentTarget.dataset.index].LOAN_AMOUNT = event.target.value;
            this.calculateTotalLoanAmount();
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
        }else if(event.target.name == 'Model_Details__c'){
            this.filterList[event.currentTarget.dataset.index].Model_Details = event.target.value;
        }
    }
    calculateTotalLoanAmount(index){
        this.sumOfAllLoanTypeKCC = 0;
        this.sumOfAllLoanTypeNonKCC = 0;
        this.filterList.forEach(obj=>{
            let amount = obj.LOAN_AMOUNT!="" && obj.LOAN_AMOUNT!=undefined && obj.LOAN_AMOUNT!=null ? parseFloat(obj.LOAN_AMOUNT) : 0;
            if(obj.Loan_Type && obj.Loan_Type=='KCC'){
                this.sumOfAllLoanTypeKCC = this.sumOfAllLoanTypeKCC + amount;
            }else if(obj.Loan_Type && obj.Loan_Type!=='KCC'){
                this.sumOfAllLoanTypeNonKCC = this.sumOfAllLoanTypeNonKCC + amount;
            }
        })
        
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