import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import FORM_FACTOR from '@salesforce/client/formFactor';
import LandHolderDocumentType from '@salesforce/label/c.Land_Holder_Document_Type';
import OtherDocumentRecordType from '@salesforce/label/c.Other_Document_Record_Type';
import createDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.createDocumentRecord';
import checkDocFromApp from '@salesforce/apex/IND_ResidenceFIController.checkDocFromApp';
import APPLICANT_ID_FIELD from "@salesforce/schema/Field_Investigation__c.Case__r.Applicant__c";
import LOAN_APPLICATION_ID_FIELD from "@salesforce/schema/Field_Investigation__c.Case__r.Loan_Application__c";


import LOAN_LAND_HOLDING_TYPE_FIELD from "@salesforce/schema/Field_Investigation__c.Sub_Scheme_Type__c";


import LANDHOLDINGDETAILS_OBJECT from '@salesforce/schema/Land_Holding_Detail__c';
import TYPE_FIELD from '@salesforce/schema/Land_Holding_Detail__c.Type__c';
import LAND_HOLDING_TYPE_FIELD from '@salesforce/schema/Land_Holding_Detail__c.Land_holding_Type__c';
import PROOF_ATTACHED_FIELD from '@salesforce/schema/Land_Holding_Detail__c.Proof_attached__c';
import OWNERSHIP_TYPE_FIELD from '@salesforce/schema/Land_Holding_Detail__c.Ownership_Type__c';
import FI_LandHoldingDetails_Rows_Lael from '@salesforce/label/c.FI_LandHoldingDetails_Rows';
import Loans_Land_Holding_Field_Not_Submitted_Message_LABEL from '@salesforce/label/c.Loans_Land_Holding_Field_Not_Submitted_Message';


import getDistrict from '@salesforce/apex/iND_TF_FI_DetailsController.getDistrictMasterByPOA';
import getTaluqa from '@salesforce/apex/iND_TF_FI_DetailsController.getTaluqaMaster';
import saveLandHoldingDetails from '@salesforce/apex/iND_TF_FI_DetailsController.saveLandHoldingDetails';
import getLandHoldingDetails from '@salesforce/apex/iND_TF_FI_DetailsController.getLandHoldingDetails';
import getSubSchemeValue from '@salesforce/apex/iND_TF_FI_DetailsController.getSubSchemeValue';
import { deleteRecord } from 'lightning/uiRecordApi';
import LandHolderName from '@salesforce/label/c.LandHolderName';
const fields = [LOAN_LAND_HOLDING_TYPE_FIELD];

const FI_FIELDS = [
    APPLICANT_ID_FIELD,
    LOAN_APPLICATION_ID_FIELD
    ];

export default class LWC_LOS_LandHoldingDetails extends LightningElement {
    @api recordId;
    @api fieldInvestigationRecordId;
    @track KYC_State = '';
    @track KYC_State_Id = '';
    @track isLoansLandHolding = false;
    @track loansLandHoldingValue = '';
    @track isLoansLandHoldingRefresh;

    totalLandHolding_landholder = 0;
    @api sumOfLandHolding_landholder = 0;
    totalLandHolding_family = 0;
    approximateValueOfAgriLand_landHolder = 0;

    typeOptions = [];
    landHoldingTypeOptions = [];
    ownershipTypeOptions = [];
    proofAttachedOptions = [];
    stateOptions = [];
    districtOptions = [];
    talukaOptions = [];
    disableAddRows = false;
    refreshApexData;
    landHolderNamePattern = LandHolderName;
    // { value: '-Nonee-', label: 'Nonee', perAcreCost: 3200 }
    // districtOptions = [ 
    //     {
    //         "id" : 0,
    //         "list" : [{ value: '-Nonee-', label: 'Nonee' }]
    //     },
    //     {
    //         "id" : 1,
    //         "list" : [{ value: 'B', label: 'B' }]
    //     }
    // ]

    @track filterList = [];
    keyIndex = 0;

    isSpinner = false;
    maxRows = FI_LandHoldingDetails_Rows_Lael;
    LandHoldingWarningMessage = Loans_Land_Holding_Field_Not_Submitted_Message_LABEL;
    @wire(getRecord, { recordId: '$fieldInvestigationRecordId', fields: FI_FIELDS })
    wiredFIRecord({ error, data }) {
        this.applicantId = getFieldValue(data, APPLICANT_ID_FIELD);
        this.applicationId = getFieldValue(data, LOAN_APPLICATION_ID_FIELD);
    }

    fetchLoanLandHolderTypeField(){
        this.isSpinner = true;
        getSubSchemeValue({ fieldInvestigationId: this.fieldInvestigationRecordId }).then(data => {
            console.log('getSubScheme Response : '+JSON.stringify(data));
            this.isSpinner = false;
            this.loansLandHoldingValue = data;
            if(this.loansLandHoldingValue === undefined || this.loansLandHoldingValue === null){
                this.isLoansLandHolding = true;
            }else{
                this.isLoansLandHolding = false;
            }
        }).catch(error => {
            this.isSpinner = false;
            this.processErrorMessage(error);
        })
    }

    @api async refreshComponentView(){
        console.log('refreshComponentView called');
        await this.fetchLoanLandHolderTypeField();
    }

    @wire(getObjectInfo, { objectApiName: LANDHOLDINGDETAILS_OBJECT })
    landholdingdetailsinfo;
    
    @wire(getPicklistValues, { recordTypeId: '$landholdingdetailsinfo.data.defaultRecordTypeId', fieldApiName: OWNERSHIP_TYPE_FIELD })
    ownershipTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.ownershipTypeOptions = [...this.ownershipTypeOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$landholdingdetailsinfo.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD })
    typeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.typeOptions = [...this.typeOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$landholdingdetailsinfo.data.defaultRecordTypeId', fieldApiName: LAND_HOLDING_TYPE_FIELD })
    landHoldingTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.landHoldingTypeOptions = [...this.landHoldingTypeOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$landholdingdetailsinfo.data.defaultRecordTypeId', fieldApiName: PROOF_ATTACHED_FIELD })
    proofAttachedValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.proofAttachedOptions = [...this.proofAttachedOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getLandHoldingDetails, { fieldInvestigationId: '$fieldInvestigationRecordId' })
    getLandHoldingDetailValues(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('Land Holding Values @wire method >>'+JSON.stringify(data));
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
                this.allRowsCalculation();
            }
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    async connectedCallback() {
        console.log('fieldInvestigationRecordId >>>  '+this.fieldInvestigationRecordId);
        await this.getStateValues();
        await this.getDistrictValues('');
        await this.fetchLoanLandHolderTypeField();
        this.handleAddRow();
    }

    get getDistrictPicklist(){
        console.log('INSIDE DISTRICT PICKLIST get >> '+this.districtOptions);
        return this.districtOptions;
    }

    get disableSave(){
        return this.filterList.reduce((valid,current)=>{
            return valid && current.isDatabase;
        },true);
    }

    async handleChange(event) {
        //Enhancement - Handle adding POA based state value in the list.c/addressSections
        this.filterList[event.currentTarget.dataset.index].State_Master = this.KYC_State_Id;
        this.filterList[event.currentTarget.dataset.index].State_Master_Value = this.KYC_State;
        //END

        this.filterList[event.currentTarget.dataset.index].Land_holding_Type = this.loansLandHoldingValue;

        if (event.target.name == 'Land_holder_Name__c') {
            this.filterList[event.currentTarget.dataset.index].Land_holder_Name = event.target.value;
            
            if(this.loansLandHoldingValue === 'KYC or lease land holding') {
                //typeOptions values on the basis of loansLandHoldingValue
                const filteredOptions = this.typeOptions.filter(option => {
                    return ['Farming Friend', 'Neighbours', 'Villagers', 'Lease Land'].includes(option.label);
                });
                this.typeOptions = filteredOptions;

                //ownershipTypeOptions values on the basis of loansLandHoldingValue
                const filteredOwnerOptions = this.ownershipTypeOptions.filter(option => {
                    return ['Third Party'].includes(option.label);
                });
                this.ownershipTypeOptions = filteredOwnerOptions;
            }else {
                //typeOptions values on the basis of loansLandHoldingValue
                const excludedOptions = this.typeOptions.filter(option => {
                    return !['Farming Friend', 'Neighbours', 'Villagers', 'Lease Land'].includes(option.label);
                });
                this.typeOptions = excludedOptions;

                //ownershipTypeOptions values on the basis of loansLandHoldingValue
                const excludedOwnershipOptions = this.ownershipTypeOptions.filter(option => {
                    return !['Third Party'].includes(option.label);
                });
                this.ownershipTypeOptions = excludedOwnershipOptions;
            }
            
        }
        else if (event.target.name == 'Type__c') {
            this.filterList[event.currentTarget.dataset.index].Type = event.target.value;
            // if(event.target.value!="Borrower"){
                // this.filterList[event.currentTarget.dataset.index].Approx_Value = 0.00;
                // this.filterList = [...this.filterList];
            // }
        }
        else if (event.target.name == 'Land_holding_Type__c') {
            this.filterList[event.currentTarget.dataset.index].Land_holding_Type = event.target.value;
        }
        else if (event.target.name == 'Ownership_Type__c') {
            this.filterList[event.currentTarget.dataset.index].Ownership_Type = event.target.value;
        }
        else if (event.target.name == 'State_Master__c') {
            this.filterList[event.currentTarget.dataset.index].State_Master = event.target.value;
            this.filterList[event.currentTarget.dataset.index].State_Master_Value = this.stateOptions.filter(rec => rec.value == event.target.value)[0]?.label;
            await this.getDistrictValues(event.target.value);
        } 
        else if (event.target.name == 'District_Master__c') {
            this.filterList[event.currentTarget.dataset.index].District_Master = event.target.value;
            this.filterList[event.currentTarget.dataset.index].District_Master_Value = this.districtOptions.filter(rec => rec.value == event.target.value)[0]?.label;
            let stateName = this.KYC_State; /*this.filterList[event.currentTarget.dataset.index].State_Master_Value;*/
            let districtName =  this.filterList[event.currentTarget.dataset.index].District_Master_Value;
            await this.getTaluqaValues(stateName,districtName);
        } 
        else if (event.target.name == 'Taluka_Master__c') {
            this.filterList[event.currentTarget.dataset.index].Taluka_Master = event.target.value;
            this.filterList[event.currentTarget.dataset.index].Taluka_Master_Value = this.talukaOptions.filter(rec => rec.value == event.target.value)[0]?.label;
        } 
        else if (event.target.name == 'Village_Name__c') {
            this.filterList[event.currentTarget.dataset.index].Village_Name = event.target.value;
        } 
        else if (event.target.name == 'Survey_No__c') {
            var pattern = /^\d+$/; 
            if(isNaN(event.target.value) || !pattern.test(event.target.value)){
                event?.target?.setCustomValidity('Please enter numeric value.');
            }else{
                event?.target?.setCustomValidity('');
                this.filterList[event.currentTarget.dataset.index].Survey_No = event.target.value;
            }
            event?.target?.reportValidity();

        } 
        else if (event.target.name == 'Land_holding_In_acres__c') {
            this.filterList[event.currentTarget.dataset.index].Land_holding_In_acres = event.target.value;
        } 
        else if (event.target.name == 'Proof_attached__c') {
            this.filterList[event.currentTarget.dataset.index].Proof_attached = event.target.value;
        } 
        else if (event.target.name == 'Since_How_long_are_they_doing_Agricultu__c') {
            this.filterList[event.currentTarget.dataset.index].Since_How_long_are_they_doing_Agricultu = event.target.value;
        }   
        this.calculateAgriLandValue(event?.currentTarget?.dataset?.index);
    }

    calculateAgriLandValue(index){
        // if(this.filterList[index]?.Type == "Borrower"){
            let landHolding = 0.00;
            let cost = this.talukaOptions.filter(res => res.value == this.filterList[index].Taluka_Master)[0]?.perAcreCost;
            landHolding = this.filterList[index]?.Land_holding_In_acres;
            let res = parseFloat(cost) * parseFloat(landHolding);
            if(this.filterList[index]){
                this.filterList[index].Approx_Value = (res == undefined || isNaN(res))?parseFloat(0):res.toFixed(2);
                this.filterList = [...this.filterList];
            }
        // }else{
        //     this.filterList[index].Approx_Value = parseFloat(0);
        // }
    }

    isInputValid(index) {
        let landHoldingType;
        let type;
        let valid = [
            ...this.template.querySelectorAll(`[data-id="${index}"]`)
        ].reduce((validSoFar, inputField) => {
            if (!inputField.checkValidity()){
                inputField.reportValidity();
            }
            console.log('RECEIVED inputField >> '+inputField.name);
            console.log('RECEIVED inputValue >> '+inputField.value);
            // if(inputField.name == "Land_holding_Type__c"){
            //     landHoldingType = inputField.value;
            // }
            landHoldingType = this.loansLandHoldingValue;
            if(inputField.name == "Type__c"){
                type = inputField.value;
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

        // this.districtOptions = [];
        this.talukaOptions = [];

        let objRow = {
            isValid : false,
            isDatabase: false,
            Land_holder_Name: '',
            Type: '',
            Land_holding_Type: '',
            Ownership_Type: '',
            State_Master: '',
            State_Master_Value: '',
            District_Master: '',
            District_Master_Value: '',
            Taluka_Master: '',
            Taluka_Master_Value: '',
            Village_Name: '',
            Survey_No: '',
            Land_holding_In_acres: '',
            Proof_attached: '',
            Since_How_long_are_they_doing_Agricultu: '',
            Approx_Value: 0.00,
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
    
            if(this.filterList.length<this.maxRows){
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

    getStateValues(){
        this.isSpinner = true;

        getDistrict({fieldInvestigationId: this.fieldInvestigationRecordId,'fetchState':true}).then(data => {
            this.isSpinner = false;
            console.log('POA Based State Recived : '+JSON.stringify(data));
            if(data && data.length > 0){
                this.KYC_State = data[0].name;
                this.KYC_State_Id = data[0].id;
            }
        }).catch(error => {
            this.isSpinner = false;
            this.processErrorMessage(error);
        });


        // getState().then(data => {
        //     this.isSpinner = false;
        //     data.forEach(val => {
        //         this.stateOptions = [...this.stateOptions, { value: val.id, label: val.name }];
        //     });
        // }).catch(error => {
        //     this.isSpinner = false;
        //     this.processErrorMessage(error);
        // })
    }

    getDistrictValues(geoStateId){
        this.districtOptions = [];
        this.isSpinner = true;
        getDistrict({ fieldInvestigationId: this.fieldInvestigationRecordId }).then(data => {
            console.log('District based POA Values : '+JSON.stringify(data));
            this.isSpinner = false;
            data.forEach(val => {
                this.districtOptions = [...this.districtOptions, { value: val.id, label: val.name }];
            });
        }).catch(error => {
            this.isSpinner = false;
            this.processErrorMessage(error);
        })
    }

    getTaluqaValues( geoStateMasterName, districtMasterName){
        this.talukaOptions = [];
        this.isSpinner = true;
        getTaluqa({ stateName: geoStateMasterName, districtName: districtMasterName }).then(data => {
            this.isSpinner = false;
            data.forEach(val => {
                this.talukaOptions = [...this.talukaOptions, { value: val.id, label: val.name, perAcreCost: val.perAcreCost }];
            });
        }).catch(error => {
            this.isSpinner = false;
            this.processErrorMessage(error);
        })
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
                    res.Land_holder_Name = res.Land_holder_Name;
                    res.Type = res.Type;
                    res.Ownership_Type = res.Ownership_Type;
                    res.District_Master = this.districtOptions.filter(rec => rec.label == res.District_Master_Value)[0]?.value;
                    this.getTaluqaValues(res.State_Master_Value, res.District_Master_Value);
                    //res.Taluka_Master = res.Taluka_Master_Value;
                    res.Village_Name = res.Village_Name;
                    res.Survey_No = res.Survey_No;
                    res.Land_holding_In_acres = res.Land_holding_In_acres;
                    res.Proof_attached = res.Proof_attached;
                    res.Since_How_long_are_they_doing_Agricultu = res.Since_How_long_are_they_doing_Agricultu;
                    this.disableAddRows = true;
                    return;
                }
            }
        });
    }//SFTRAC-614 Ends

    async saveRows() {
        console.log('this.filterList SAVING => ', JSON.stringify(this.filterList));
        console.log('Field Investigation Id : '+ this.fieldInvestigationRecordId);
        let recLst = this.filterList.filter(ele => ele.isValid == false);
        let isAllRowsValid = recLst.reduce((validSoFar, inputField) => {
            return validSoFar && this.isInputValid(inputField.id);
        },true);

        if(!isAllRowsValid){
            return;
        }

        this.allRowsCalculation();console.log('+++++this.sumOfLandHolding_landholder '+this.sumOfLandHolding_landholder +' this.sumErrorFlag '+this.sumErrorFlag);
        //To check sum of Land holding In acres
        if(this.loansLandHoldingValue == '0.1-2 acre' && this.sumErrorFlag && (this.sumOfLandHolding_landholder < 0.1 || this.sumOfLandHolding_landholder > 2)){
            this.showToastMessage('Error', 'Sum of Land holding In acres should be within the range.', 'Error');
        }else if(this.loansLandHoldingValue == '2-4 acre' && this.sumErrorFlag && (this.sumOfLandHolding_landholder < 2 || this.sumOfLandHolding_landholder > 4)){
            this.showToastMessage('Error', 'Sum of Land holding In acres should be within the range.', 'Error');
        }else{
            //Validate Duplicate Survey Number
            let validSuveryNumber = true;
            let surveyMap = new Map();
            for (let index = 0; index < this.filterList.length; index++) {
                if(surveyMap.has(this.filterList[index].Survey_No.toUpperCase())){
                    validSuveryNumber = false;
                    break;
                }else{
                    surveyMap.set(this.filterList[index].Survey_No.toUpperCase(),this.filterList[index].Survey_No.toUpperCase());
                }
            }
            if(validSuveryNumber == false){
                this.showToastMessage('Warning', 'One or more records have been found with the same Survey No.', 'warning');
                return;
            }


            this.filterList.forEach(res=>{
                if(res.isDatabase == false){
                    res.isValid = true;
                    res.isDatabase = false;
                }
            });
            this.isSpinner = true;
            saveLandHoldingDetails({ landLst: this.filterList, fieldInvestigationId: this.fieldInvestigationRecordId }).then(result => {
                this.dispatchEvent(new CustomEvent('refreshchildcomponents'));
                this.showToastMessage('success', 'Land Holding Details Saved Successfully!!', 'Success');
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
    }
    sumErrorFlag = false;
    @api
    allRowsCalculation(){
        this.totalLandHolding_landholder = parseFloat(0);
        this.sumOfLandHolding_landholder = parseFloat(0);
        this.approximateValueOfAgriLand_landHolder = parseFloat(0);
        this.totalLandHolding_family = parseFloat(0);
        
        this.filterList.forEach(res=>{
            //SFTRAC-283 LandHoldingType : Guarantor, is not included in any calculation.
            if(res.Type == "Borrower" || res.Type == 'Co-Borrower'){
                this.totalLandHolding_landholder += parseFloat(res.Land_holding_In_acres);
                if(res.hasOwnProperty('Approx_Value')){
                    this.approximateValueOfAgriLand_landHolder += parseFloat(res.Approx_Value);
                }
            }else if(res.Type != 'Guarantor'){
                this.totalLandHolding_family += parseFloat(res.Land_holding_In_acres);
            }
            if(res.Type != 'Guarantor'){
                this.sumOfLandHolding_landholder += parseFloat(res.Land_holding_In_acres);
                this.sumErrorFlag = true;
            }else{
                this.sumErrorFlag = false;
            }
        });

        this.totalLandHolding_landholder = this.totalLandHolding_landholder.toFixed(2);
        this.approximateValueOfAgriLand_landHolder = this.approximateValueOfAgriLand_landHolder.toFixed(2);
        this.totalLandHolding_family = this.totalLandHolding_family.toFixed(2);
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

    handleUplaod(){
        console.log('INSIDE Upload');
        this.documentType = LandHolderDocumentType;
        this.createDocument(LandHolderDocumentType, OtherDocumentRecordType);
    }

    async createDocument(docType, recordType) {
        await createDocumentRecord({ caseId: this.fieldInvestigationRecordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: docType, recordTypeName: recordType })
            .then((response) => {
                console.log('response ', response);
                this.documentId = response;
                this.openUploadComp(recordType);
            })
            .catch((error) => {
                if (error.body.message) {
                    this.showToast('Error!', error.body.message, 'error', 'sticky');
                } else {
                    this.showToast('Error!', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                }
            });

    }

    @track showUpload;
    @track showDocView;
    @track isVehicleDoc;
    @track isAllDocType;
    @track sendingRecordTypeName;
    @track uploadViewDocFlag;
    @track documentType;
    @track documentId;

    @track applicantId;
    @track applicationId;
    //@track scrollableClass = 'slds-scrollable';

    get isDesktop(){
       // console.log('FORM_FACTOR '+FORM_FACTOR);
        if(FORM_FACTOR == 'Large'){
           // this.scrollableClass = '';
            return true;
        }
        return false; 
    }
    get className(){
        return FORM_FACTOR!='Large' ? 'slds-scrollable_x': '';
    }

    openUploadComp(recordType) {
        this.showDocView = true;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.sendingRecordTypeName = recordType;
        this.uploadViewDocFlag = true;
        this.showUpload = true;
    }

    async changeflagvalue(event) {
        this.uploadViewDocFlag = false;
        if (FORM_FACTOR != 'Large') {
            await checkDocFromApp({ applicantId: this.applicantId, docType: this.documentType })
                .then(result => {
                    if (result != null) {
                        const evt = new ShowToastEvent({
                            title: "All uploaded!",
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                })
        }

        if (event.detail && event.detail.contentDocumentId != null && event.detail.backcontentDocumentId != null) {
            const evt = new ShowToastEvent({
                title: "All uploaded!",
                variant: 'success',
            });
            this.dispatchEvent(evt);

        }
    }

    docDeleted() { this.documentId = null; }

}