import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import CROP_DETAILS_OBJECT from '@salesforce/schema/Crop_Detail__c';
import CROP_TYPE_FIELD from '@salesforce/schema/Crop_Detail__c.Crop_Type__c';

import getCropInformation from '@salesforce/apex/iND_TF_FI_DetailsController.getCropInformation';
import saveCropInformation from '@salesforce/apex/iND_TF_FI_DetailsController.saveCropInformation';
import fetchCropMaster from '@salesforce/apex/iND_TF_FI_DetailsController.fetchCropMaster';
import getDistrict from '@salesforce/apex/iND_TF_FI_DetailsController.getDistrictMasterByPOA';

import fetchLandSurveyNo from '@salesforce/apex/iND_TF_FI_DetailsController.getLandSurveyNo';
import FORM_FACTOR from '@salesforce/client/formFactor';


import FI_CROPDETAILS_Rows_LABEL from '@salesforce/label/c.FI_CropDetail_Rows';
import { deleteRecord } from 'lightning/uiRecordApi';

export default class LWC_LOS_CropDetails extends LightningElement {
    @api recordId;
    @api fieldInvestigationRecordId;
    @api yearOfCropCultivation;

    @track cropTypeOptions = [];
    @track cropMasterLst = [];
    @track districtOptions = [];
    @track landSurveyNoOptions = [];

    @api refreshChildData(){
        refreshApex(this.refreshSurveyNoApexData);
    }

    disableAddRows = false;
    refreshApexData;
    refreshSurveyNoApexData;
    districtSelectedName;

    @track filterList = [];
    keyIndex = 0;

    isSpinner = false;
    maxRows = FI_CROPDETAILS_Rows_LABEL;

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

    @wire(getObjectInfo, { objectApiName: CROP_DETAILS_OBJECT })
    cropDetailsinfo;
    
    @wire(getPicklistValues, { recordTypeId: '$cropDetailsinfo.data.defaultRecordTypeId', fieldApiName: CROP_TYPE_FIELD })
    cropTypePicklistValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.cropTypeOptions = [...this.cropTypeOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getDistrict,{fieldInvestigationId: '$fieldInvestigationRecordId'})
    districtPicklistValues({data,error}){
        if(data){
            data.forEach(val => {
                this.districtOptions = [...this.districtOptions, { value: val.name, label: val.name }];
            });
        }else if(error){
            this.processErrorMessage(error);
        }
    }

    @wire(getCropInformation,({fieldInvestigationId: '$fieldInvestigationRecordId', year:'$yearOfCropCultivation' }))
    getCropInformationsData(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('Crop Information DATA @wire method >>'+JSON.stringify(data));
            if(data.length>0){
                this.filterList = [];
                this.filterList = data;
            }
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(fetchLandSurveyNo,({fieldInvestigationId: '$fieldInvestigationRecordId' }))
    fetchLandSurveyNoData(result) {
        this.refreshSurveyNoApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('Land Survey No DATA @wire method >>'+JSON.stringify(data));
            if(data.length>0){
                this.landSurveyNoOptions = [];
                this.landSurveyNoOptions = data;
            }
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    async connectedCallback() {
        this.handleAddRow();
    }

    get disableSave(){
        return this.filterList.reduce((valid,current)=>{
            return valid && current.isDatabase;
        },true);
    }

    async handleChange(event) {
        if(event.target.name == 'District_Master__c'){
            console.log('districtMaster  '+event.target.value);

            console.log('districtOptions  '+JSON.stringify(this.districtOptions));
            this.filterList[event.currentTarget.dataset.index].District_Master = event.target.value;
            this.filterList[event.currentTarget.dataset.index].District_Master_Value = this.districtOptions.filter(rec => rec.value == event.target.value)[0]?.label;
            this.districtSelectedName = event.target.value;
            this.clearRowData(event.currentTarget.dataset.index);
            this.calculateNetIncome(event.currentTarget.dataset.index);
            await this.getCropData();

            console.log('End of District_Master__c condition');
        }
        else if (event.target.name == 'Crop_Type__c') {
            this.filterList[event.currentTarget.dataset.index].Crop_Type = event.target.value;
        }
        else if (event.target.name == 'Crop_Grown_in_acre__c') {
            let element = this.template.querySelector(`[data-index="${event.currentTarget.dataset.index}"][data-name="Crop_Grown_in_acre__c"]`);
            if(element){
                const inputValue = event.target.value;
                const regex = /^\d*\.?\d+$/;
                if (!regex.test(inputValue)) {
                    element.setCustomValidity("Please enter valid input value.");
                } else {
                    element.setCustomValidity("");
                    this.filterList[event.currentTarget.dataset.index].Crop_Grown_in_acre = event.target.value;
                    this.calculateNetIncome(event.currentTarget.dataset.index);
                }
                element.reportValidity();
            }
        }
        else if (event.target.name == 'Crop_Master__c') {
            this.filterList[event.currentTarget.dataset.index].Crop_Master = event.target.value;
            this.filterList[event.currentTarget.dataset.index].Crop_Master_Value = this.cropMasterLst.filter(rec => rec.value == event.target.value)[0]?.label;
            this.filterList[event.currentTarget.dataset.index].Sold_Price = this.cropMasterLst.filter(rec => rec.value == event.target.value)[0]?.Sold_Price;
            this.filterList[event.currentTarget.dataset.index].Yield_Acre = this.cropMasterLst.filter(rec => rec.value == event.target.value)[0]?.Yield_Acre;
            this.calculateNetIncome(event.currentTarget.dataset.index);
        }else if (event.target.name == 'Land_Survey_No__c'){
            this.filterList[event.currentTarget.dataset.index].Land_Survey_No = event.target.value;
        }
        console.log('HANDLE CHANGE >>  '+JSON.stringify(this.filterList));
    }

    clearRowData(index){
        this.filterList[index].Crop_Master = '';
        this.filterList[index].Crop_Master_Value = '';
        this.filterList[index].Yield_Acre = '';
        this.filterList[index].Sold_Price = '';
        this.template.querySelector(`[data-index="${index}"][data-name="Crop_Master__c"]`).value='';
    }

    getCropData(){

        this.isSpinner = true;
        this.cropMasterLst = [];

        fetchCropMaster({districtName: this.districtSelectedName}).then(result => {
            result.forEach(val => {
                this.cropMasterLst = [...this.cropMasterLst, { value: val.id, label: val.name, Yield_Acre: val.Yield_Acre, Sold_Price: val.Sold_Price }];
            });
            this.isSpinner = false;
        }).catch(error => {
            this.processErrorMessage(error);
            this.isSpinner = false;
        })
    }

    calculateNetIncome(index){
        if(this.filterList[index].hasOwnProperty('Crop_Grown_in_acre') && this.filterList[index].hasOwnProperty('Crop_Master') && this.filterList[index].Crop_Grown_in_acre.length > 0 && this.filterList[index].Crop_Master.length > 0 ){
            let cropGrown = this.filterList[index].Crop_Grown_in_acre;
            let yieldAcre = this.cropMasterLst.filter(rec => rec.value == this.filterList[index].Crop_Master)[0].Yield_Acre;
            let soldPrice = this.cropMasterLst.filter(rec => rec.value == this.filterList[index].Crop_Master)[0].Sold_Price;
            //soldPrice /= 2.0;
            this.filterList[index].Net_Income = parseFloat((yieldAcre * soldPrice * cropGrown) ? (yieldAcre * soldPrice * cropGrown) : 0).toFixed(2);
        }else{
            this.filterList[index].Net_Income = parseFloat(0).toFixed(2);
        }
    }

    isInputValid(index) {
        let valid = [
            ...this.template.querySelectorAll(`[data-id="${index}"]`)
        ].slice(1).reduce((validSoFar, inputField) => {
            if (!inputField.checkValidity()){
                inputField.reportValidity();
            }
            let val = inputField.value;
            if(val == undefined || val.length <= 0){
                inputField.setCustomValidity("Fill all the required information.");
                inputField.reportValidity();
            }else{
                inputField.setCustomValidity("");
            }
            return validSoFar && inputField.checkValidity();
        }, true);

        return valid;
    }

    isBlankRow(index){
        let valid = true;
        let obj = this.filterList[index];
        for(var propt in obj){
            console.log(propt + ': ' + obj[propt]);
            if(obj[propt] == undefined || obj[propt] == null || obj[propt].length<=0){
                valid = false;
                break;
            }
        }

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

        refreshApex(this.refreshSurveyNoApexData);

        let objRow = {
            isValid : false,
            isDatabase: false,
            District_Master: '',
            District_Master_Value: '',
            Crop_Type: '',
            Crop_Grown_in_acre: '',
            Net_Income: 0.00,
            Crop_Master: '',
            Crop_Master_Value: '',
            Yield_Acre: '',
            Sold_Price: '',
            Land_Survey_No: '',
            id: ++this.keyIndex
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
        this.filterList.forEach(res=>{console.log('+++++res ', JSON.stringify(res));
            if(newRowsAdded && !editDisableFlag){
                editDisableFlag = true;
                this.showToastMessage('error', 'Cannot edit row while another row is being added or edited', 'Error');
                return;
            }else{
                if(res.id == currentRecId && !editDisableFlag){console.log('+++++res2 ', JSON.stringify(res));
                    console.log('+++++res.isValid '+res.isValid + ' res.isDatabase '+res.isDatabase);
                    res.isValid = false;
                    res.isDatabase = false;
                    this.disableAddRows = true;
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
        saveCropInformation({ cropDetails: this.filterList, fieldInvestigationId: this.fieldInvestigationRecordId, year: this.yearOfCropCultivation }).then(result => {
            this.showToastMessage('success', 'CROP Information Saved Successfully!!', 'Success');
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