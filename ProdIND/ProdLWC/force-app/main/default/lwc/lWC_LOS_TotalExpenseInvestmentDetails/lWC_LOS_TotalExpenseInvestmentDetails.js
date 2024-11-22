import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import TOTALEXPENSEINVESTMENT_OBJ from '@salesforce/schema/Total_Expense_and_investment__c';
import TYPE from '@salesforce/schema/Total_Expense_and_investment__c.Type__c';


import saveExpenseInvesetment from '@salesforce/apex/iND_TF_FI_DetailsController.saveExpenseInvestmentDetails';
import getExpenseInvestmentDetail from '@salesforce/apex/iND_TF_FI_DetailsController.getExpenseInvestmentDetail';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { deleteRecord } from 'lightning/uiRecordApi';


export default class LWC_LOS_TotalExpenseInvestmentDetails extends LightningElement {
    @track filterList = [];
    @track filterListCopy=[];
    @track newlyAddedRows = [];
    keyIndex = 0;

    isSpinner = false;
    maxRows = 10;
    @api recordId;
    @api fiRecordId;
    typeOption = [];

    //@track scrollableClass = 'slds-scrollable_x';

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
    

    @wire(getObjectInfo, { objectApiName: TOTALEXPENSEINVESTMENT_OBJ })
    totalExpenseInvestmentDetails;

    @wire(getPicklistValues, { recordTypeId: '$totalExpenseInvestmentDetails.data.defaultRecordTypeId', fieldApiName: TYPE })
    ownershipTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.typeOption = [...this.typeOption, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getExpenseInvestmentDetail, { fieldInvestigationId: '$fiRecordId' })
    getExpenseInvestmentDetail(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            this.filterList = [];
            this.filterList = data;
             this.filterList = data.map((item, index) => ({
            ...item,
            srNo: index + 1
        }));
        if(this.filterList.length>=this.maxRows){
            this.disableAddRows = true;
        }
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    get disableSave(){
        return this.filterList.reduce((valid,current)=>{
            return valid && current.isDatabase;
        },true);
    }
    get totalExpenses() {
        return this.filterList
            .filter(record => record.Type === 'Expense')
            .reduce((total, record) => total + (isNaN(parseFloat(record.Amount)) ? 0 : parseFloat(record.Amount)), 0);
    }

    get totalInvestment() {
        return this.filterList
            .filter(record => record.Type === 'Investment')
            .reduce((total, record) => total + (isNaN(parseFloat(record.Amount)) ? 0 : parseFloat(record.Amount)), 0);
    }

    async connectedCallback() {
        this.handleAddRow();
    }
    isPreviousRowComplete() {
        if (this.filterList.length === 0) {
            return true;
        }
    
        const previousRow = this.filterList[this.filterList.length - 1];
        return previousRow.Type && previousRow.ExpenseType && previousRow.Amount;
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
        if (this.isPreviousRowComplete()) {

            let nextId = this.filterList.length+1;

            let objRow = {
                isValid : false,
                isDatabase: false,
                Type:'',
                ExpenseType :'',
                ExpenseTypeOptions:[],
                Amount :'',
                srNo: nextId,
                id:nextId
            }

            this.filterList = [...this.filterList, Object.create(objRow)];
            this.filterListCopy = this.filterList;

            this.newlyAddedRows.push(objRow);
            if(this.filterList.length>=this.maxRows){
                this.disableAddRows = true;
            }
        }
        else{
            this.processErrorMessage('Fill all the data');
        }
    }

    
    handleRemoveRow(event) {
        let idToRemove = event.currentTarget.dataset.index;         //SFTRAC-614
        if (idToRemove && idToRemove.length === 18) {               //SFTRAC-614 checking Id length and calling delete method
            this.handleDeleteRow(event);
        } else {
            this.filterList = this.filterList.filter((ele) => {
                return parseInt(ele.id) !== parseInt(event.currentTarget.dataset.index,10);
            });
    
            if(this.filterList.length<10){
                this.disableAddRows = false;
            }
    
            // Re-index the rows to start from 1
            this.filterList.forEach((row, index) => {
                row.srNo = index + 1;
            })
    
            if (this.filterList.length == 0) {
                this.handleAddRow();
            }
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
            refreshApex(this.refreshApexData);
        }).catch(error => {
            console.log('++++HANDLE DELETEd error');
        });    
    }
    
    handleChange(event){
        let idx = event.currentTarget.dataset.index;
        if (event.target.name == 'Type__c') {
            this.filterList[idx].Type = event.target.value;
            
                this.updateDependentOptions(idx);
        }
        if (event.target.name == 'Expenses_and_Investment_Type__c') {
            this.filterList[idx].ExpenseType = event.target.value;
            
        }
        if (event.target.name == 'Amount__c') {
            this.filterList[idx].Amount = event.target.value;
        }

    }

    updateDependentOptions(index) {
        if (this.filterList[index].Type == 'Expense') {
            this.filterList[index].ExpenseTypeOptions = [
            { label: 'Expenses for higher education of son / Daughter / Family member', value: 'Expenses for higher education of son / Daughter / Family member' },
            { label: 'Approx Medical Expenses', value: 'Approx Medical Expenses' },
            { label: 'Existing vehicle maintenance', value: 'Existing vehicle maintenance' },
            { label: 'Upcoming Marriage expense (Approx) in the family in next 2 years', value: 'Upcoming Marriage expense (Approx) in the family in next 2 years' },
            { label: 'Running Loan EMI Obligation (Monthly)', value: 'Running Loan EMI Obligation (Monthly)' }
            ];
        } else if (this.filterList[index].Type == 'Investment') {
            this.filterList[index].ExpenseTypeOptions = [
            { label: 'Invested in LIC', value: 'Invested in LIC' },
            { label: 'Invested in Well digging', value: 'Invested in Well digging' },
            { label: 'Land Development', value: 'Land Development' },
            { label: 'House construction', value: 'House construction' },
            { label: 'Land Purchase', value: 'Land Purchase' },
            { label: 'Purchasing New Vehicle', value: 'Purchasing New Vehicle' },
            { label: 'Cattle Purchase', value: 'Cattle Purchase' },
            { label: 'LAST 5 YEARS MAJOR INVESTMENT OF INCOME', value: 'LAST 5 YEARS MAJOR INVESTMENT OF INCOME' }
            ];
        } else {
            this.filterList[index].ExpenseTypeOptions = [];
        }
        this.filterList = [...this.filterList];
    }

    //SFTRAC-614 Starts
    @track savedRowsList = [];
    @api
    getRowsCount() {
        this.savedRowsList = this.filterList.filter(ele => ele.isValid == true);
        return this.savedRowsList.length;
    }//SFTRAC-614 Ends

    //SFTRAC-614 Starts
    handleEditRow(event){
        let currentRecId = event.currentTarget.dataset.index;
        const newRowsAdded = this.filterList.some(res => !res.isValid);
        let editDisableFlag = false;
        this.filterList.forEach((res, index)=>{
            if(newRowsAdded && !editDisableFlag){
                editDisableFlag = true;
                this.showToastMessage('error', 'Cannot edit row while another row is being added or edited', 'Error');
                return;
            }else{
                if(res.id == currentRecId && !editDisableFlag){
                    res.isValid = false;
                    res.isDatabase = false;
                    this.updateDependentOptions(index);
                    res.ExpenseType = res.ExpenseType;
                    this.disableAddRows = true;
                }
            }
        });
    }//SFTRAC-614 Ends

    saveRows() {
       //const filteredArray = this.filterList.filter(item => !item.Id);
       let filteredArray = this.filterList.filter(ele => ele.isValid == false);
    console.log('this.filterList SAVING => ', JSON.stringify(filteredArray));
        const isEmpty = filteredArray.every(obj => Object.keys(obj).length === 0);
        if(isEmpty){
            this.showToastMessage('Warning', 'No data present ', 'Warning');
            return;
        }
        this.isSpinner = true;
        saveExpenseInvesetment({ records: filteredArray, fieldInvestigationId: this.fiRecordId }).then(result => {
            this.showToastMessage('success', 'Total Expense and investment Details saved ', 'Success');
            refreshApex(this.refreshApexData);
            this.isSpinner = false;
            const evt = new CustomEvent('expenseinvstmentevt', {
                detail: true
            });
           this.dispatchEvent(evt);
        }).catch(error => {
            this.processErrorMessage(error);
            this.isSpinner = false;
        })
        if(this.filterList.length<this.maxRows){ //SFTRAC-614
            this.disableAddRows = false;
        }
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