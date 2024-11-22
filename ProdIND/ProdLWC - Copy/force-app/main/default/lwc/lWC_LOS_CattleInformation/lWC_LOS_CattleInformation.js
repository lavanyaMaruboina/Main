import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import CATTLE_INFORMATION_OBJECT from '@salesforce/schema/Cattle_Information__c';
import CATTLE_NAME_FIELD from '@salesforce/schema/Cattle_Information__c.Cattle_Name__c';

import getCattleInformation from '@salesforce/apex/iND_TF_FI_DetailsController.getCattleInformation';
import saveCattleInformation from '@salesforce/apex/iND_TF_FI_DetailsController.saveCattleInformation';

import FI_CattleInformation_Rows_LABEL from '@salesforce/label/c.FI_CattleInformation_Rows';
import FORM_FACTOR from '@salesforce/client/formFactor';

import { deleteRecord } from 'lightning/uiRecordApi';
export default class LWC_LOS_CattleInformation extends LightningElement {
    @api recordId;
    @api fieldInvestigationRecordId;

    @track cattleNameOptions = [];

    disableAddRows = false;
    refreshApexData;

    @track filterList = [];
    keyIndex = 0;
    //@track scrollableClass = 'slds-scrollable_x';

    isSpinner = false;
    maxRows = FI_CattleInformation_Rows_LABEL;

    get isDesktop(){
        if(FORM_FACTOR == 'Large'){
            return true;
        }
        return false; 
    }
      get className(){
        return FORM_FACTOR!='Large' ? 'slds-scrollable_x': '';
    }

    @wire(getObjectInfo, { objectApiName: CATTLE_INFORMATION_OBJECT })
    cattleInformationinfo;
    
    @wire(getPicklistValues, { recordTypeId: '$cattleInformationinfo.data.defaultRecordTypeId', fieldApiName: CATTLE_NAME_FIELD })
    cattleNamePicklistValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.cattleNameOptions = [...this.cattleNameOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getCattleInformation, { fieldInvestigationId: '$fieldInvestigationRecordId' })
    getCattleInformationsData(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('Cattle Information DATA @wire method >>'+JSON.stringify(data));
            if(data.length>0){
                this.filterList = [];
                // this.filterList = data;
                this.filterList = data.map((item, index)=>({
                    ...item,
                    srNo: index + 1
                }));
                if(this.filterList.length>=this.maxRows){
                    this.disableAddRows = true;
                }
            }
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    async connectedCallback() {
        console.log('fieldInvestigationRecordId >>>  '+this.fieldInvestigationRecordId);  
        this.handleAddRow(); 
    }

    get disableSave(){
        return this.filterList.reduce((valid,current)=>{
            return valid && current.isDatabase;
        },true);
    }

    async handleChange(event) {
        if (event.target.name == 'Cattle_Name__c') {
            this.filterList[event.currentTarget.dataset.index].Cattle_Name = event.target.value;
        }
        else if (event.target.name == 'Nos_of_Cattle__c') {
            this.filterList[event.currentTarget.dataset.index].Nos_of_Cattle = event.target.value;
        }
        console.log('HANDLE CHANGE >>  '+JSON.stringify(this.filterList));
    }

    isInputValid(index) {
        let valid = [
            ...this.template.querySelectorAll(`[data-id="${index}"]`)
        ].reduce((validSoFar, inputField) => {
            if (!inputField.checkValidity()){
                inputField.reportValidity();
            }
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
            Cattle_Name: '',
            Nos_of_Cattle: '',
            id: ++this.keyIndex,
            srNo: this.filterList.length+1
        }

        this.filterList = [...this.filterList, objRow];

        console.log('CURRENT KEY INDEX >>> '+this.keyIndex-1);
        if(this.keyIndex != undefined){
            this.filterList.forEach(res=>{
                if(res.id == this.keyIndex-1){
                    res.isValid = true;
                    res.isDatabase = false;
                }
            });
        }

        console.log('Addition of row list >> '+JSON.stringify(this.filterList));
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
    
            // Re-index the rows to start from 1
            this.filterList.forEach((row, index) => {
                row.srNo = index + 1;
            });
    
            if(this.filterList.length < this.maxRows){
                this.disableAddRows = false;
            }
    
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
        }).catch(error => {
            console.log('++++HANDLE DELETEd error');
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
                    res.Type = res.Cattle_Name;
                    res.CattleNo = res.Nos_of_Cattle;
                    this.disableAddRows = true;
                    return;
                }
            }  
        });
    }//SFTRAC-614 Ends

    saveRows() {
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
        saveCattleInformation({ cattleLst: this.filterList, fieldInvestigationId: this.fieldInvestigationRecordId }).then(result => {
            this.showToastMessage('success', 'Cattle Information Saved Successfully!!', 'Success');
            refreshApex(this.refreshApexData);
            this.isSpinner = false;
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