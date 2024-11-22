import { LightningElement,track,wire,api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import VIABILITYOFEXISTINGPROPOSEDTRACTOR_OBJECT from '@salesforce/schema/Viability_of_Existing_Proposed_Tractor__c';
import USAGE_TYPE_FIELD from '@salesforce/schema/Viability_of_Existing_Proposed_Tractor__c.Usage_Type__c';
import TRACTOR_HARVESTER_FIELD from '@salesforce/schema/Viability_of_Existing_Proposed_Tractor__c.Tractor_Harvester__c';
import EXISTING_PROPOSED_FIELD from '@salesforce/schema/Viability_of_Existing_Proposed_Tractor__c.Existing_Proposed__c';
import Diesal_counsumption_hr from '@salesforce/label/c.Diesal_counsumption_hr';
import diesel_rate from '@salesforce/label/c.diesel_rate';
import per_hour_rate from '@salesforce/label/c.per_hour_rate';

import saveViabilityExistingTractorDetails from '@salesforce/apex/iND_TF_FI_DetailsController.saveViabilityExistingTractorDetails';
import getViabilityExistingTractorInformation from '@salesforce/apex/iND_TF_FI_DetailsController.getViabilityExistingTractorInformation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { deleteRecord } from 'lightning/uiRecordApi';
export default class LWC_LOS_ViabilityOfExistingAndProposedTractor extends LightningElement {
    @api recordId;
    @api fieldInvestigationRecordId;

    @track filterList = [];
    usageTypeOptions=[];
    tractorHarvesterOptions=[];
    existingProposedOptions = [];
    keyIndex = 0;

    isSpinner = false;
    maxRows = 8;
    disableAddRows = false;
    totalAgriExpensesForExistingHarvester = 0;
    totalAgriExpensesForProposedHarvester = 0;
    totalAgriExpensesForExistingTractor = 0;
    totalAgriExpensesForProposedTractor = 0;

    totalAgriIncomeForExistingHarvester = 0;
    totalAgriIncomeForProposedHarvester = 0;
    totalAgriIncomeForExistingTractor = 0;
    totalAgriIncomeForProposedTractor = 0;

    totalAgriNetIncomeForExistingHarvester = 0;
    totalAgriNetIncomeForProposedHarvester = 0;
    totalAgriNetIncomeForExistingTractor = 0;
    totalAgriNetIncomeForProposedTractor = 0;

    totalAgriCommercialExpensesForExistingHarvester = 0;
    totalAgriCommercialExpensesForProposedHarvester = 0;
    totalAgriCommercialExpensesForExistingTractor = 0;
    totalAgriCommercialExpensesForProposedTractor = 0;

    totalAgriCommercialIncomeForExistingHarvester = 0;
    totalAgriCommercialIncomeForProposedHarvester = 0;
    totalAgriCommercialIncomeForExistingTractor = 0;
    totalAgriCommercialIncomeForProposedTractor = 0;

    totalAgriCommercialNetIncomeForExistingHarvester = 0;
    totalAgriCommercialNetIncomeForProposedHarvester = 0;
    totalAgriCommercialNetIncomeForExistingTractor = 0;
    totalAgriCommercialNetIncomeForProposedTractor = 0;
    
    Expenses = 0;
    TotalIncome = 0;
    NetIncome = 0;

    No_Of_Week_Years = 0;
    Diesal_Rate = parseInt(diesel_rate);
    Diesal_counsumption = 0; //parseInt(Diesal_counsumption_hr)
    Per_Hour_Rt =0; //SFTRAC-271 Bug /*parseInt(per_hour_rate)*/ 

    //@track scrollableClass = 'slds-scrollable_x';

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
    

    get disableSave(){
        return this.filterList.reduce((valid,current)=>{
            return valid && current.isDatabase;
        },true);
    }

    refreshApexData;

    @wire(getViabilityExistingTractorInformation, { fieldInvestigationId: '$fieldInvestigationRecordId' })
    getViabilityExistingTractorInformationValues(result) {
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
            this.totalAgriExpensesForExistingHarvester = (data[0]!=undefined && data[0].totalAgriExpensesForExistingHarvester!=undefined) ? data[0].totalAgriExpensesForExistingHarvester : 0;
            this.totalAgriExpensesForProposedHarvester = data[0]!=undefined && data[0].totalAgriExpensesForProposedHarvester!=undefined ? data[0].totalAgriExpensesForProposedHarvester : 0;
            this.totalAgriExpensesForExistingTractor = data[0]!=undefined && data[0].totalAgriExpensesForExistingTractor!=undefined ? data[0].totalAgriExpensesForExistingTractor : 0;
            this.totalAgriExpensesForProposedTractor = data[0]!=undefined && data[0].totalAgriExpensesForProposedTractor!=undefined ? data[0].totalAgriExpensesForProposedTractor : 0;

            this.totalAgriIncomeForExistingHarvester = data[0]!=undefined && data[0].totalAgriIncomeForExistingHarvester!=undefined ? data[0].totalAgriIncomeForExistingHarvester : 0;
            this.totalAgriIncomeForProposedHarvester = data[0]!=undefined && data[0].totalAgriIncomeForProposedHarvester!=undefined ? data[0].totalAgriIncomeForProposedHarvester : 0;
            this.totalAgriIncomeForExistingTractor = data[0]!=undefined && data[0].totalAgriIncomeForExistingTractor!=undefined ? data[0].totalAgriIncomeForExistingTractor : 0;
            this.totalAgriIncomeForProposedTractor = data[0]!=undefined && data[0].totalAgriIncomeForProposedTractor!=undefined ? data[0].totalAgriIncomeForProposedTractor : 0;

            this.totalAgriNetIncomeForExistingHarvester = data[0]!=undefined && data[0].totalAgriNetIncomeForExistingHarvester!=undefined ? data[0].totalAgriNetIncomeForExistingHarvester : 0;
            this.totalAgriNetIncomeForProposedHarvester = data[0]!=undefined && data[0].totalAgriNetIncomeForProposedHarvester!=undefined ? data[0].totalAgriNetIncomeForProposedHarvester : 0;
            this.totalAgriNetIncomeForExistingTractor = data[0]!=undefined && data[0].totalAgriNetIncomeForExistingTractor!=undefined ? data[0].totalAgriNetIncomeForExistingTractor : 0;
            this.totalAgriNetIncomeForProposedTractor = data[0]!=undefined && data[0].totalAgriNetIncomeForProposedTractor!=undefined ? data[0].totalAgriNetIncomeForProposedTractor : 0;

            this.totalAgriCommercialExpensesForExistingHarvester = data[0]!=undefined && data[0].totalAgriCommercialExpensesForExistingHarvester!=undefined ? data[0].totalAgriCommercialExpensesForExistingHarvester : 0;
            this.totalAgriCommercialExpensesForProposedHarvester = data[0]!=undefined && data[0].totalAgriCommercialExpensesForProposedHarvester!=undefined ? data[0].totalAgriCommercialExpensesForProposedHarvester : 0;
            this.totalAgriCommercialExpensesForExistingTractor = data[0]!=undefined && data[0].totalAgriCommercialExpensesForExistingTractor!=undefined ? data[0].totalAgriCommercialExpensesForExistingTractor : 0;
            this.totalAgriCommercialExpensesForProposedTractor = data[0]!=undefined && data[0].totalAgriCommercialExpensesForProposedTractor!=undefined ? data[0].totalAgriCommercialExpensesForProposedTractor : 0;

            this.totalAgriCommercialIncomeForExistingHarvester = data[0]!=undefined && data[0].totalAgriCommercialIncomeForExistingHarvester!=undefined ? data[0].totalAgriCommercialIncomeForExistingHarvester : 0;
            this.totalAgriCommercialIncomeForProposedHarvester = data[0]!=undefined && data[0].totalAgriCommercialIncomeForProposedHarvester!=undefined ? data[0].totalAgriCommercialIncomeForProposedHarvester : 0;
            this.totalAgriCommercialIncomeForExistingTractor = data[0]!=undefined && data[0].totalAgriCommercialIncomeForExistingTractor!=undefined ? data[0].totalAgriCommercialIncomeForExistingTractor : 0;
            this.totalAgriCommercialIncomeForProposedTractor = data[0]!=undefined && data[0].totalAgriCommercialIncomeForProposedTractor!=undefined ? data[0].totalAgriCommercialIncomeForProposedTractor : 0;

            this.totalAgriCommercialNetIncomeForExistingHarvester = data[0]!=undefined && data[0].totalAgriCommercialNetIncomeForExistingHarvester!=undefined ? data[0].totalAgriCommercialNetIncomeForExistingHarvester : 0;
            this.totalAgriCommercialNetIncomeForProposedHarvester = data[0]!=undefined && data[0].totalAgriCommercialNetIncomeForProposedHarvester!=undefined ? data[0].totalAgriCommercialNetIncomeForProposedHarvester : 0;
            this.totalAgriCommercialNetIncomeForExistingTractor = data[0]!=undefined && data[0].totalAgriCommercialNetIncomeForExistingTractor!=undefined ? data[0].totalAgriCommercialNetIncomeForExistingTractor : 0;
            this.totalAgriCommercialNetIncomeForProposedTractor = data[0]!=undefined && data[0].totalAgriCommercialNetIncomeForProposedTractor!=undefined ? data[0].totalAgriCommercialNetIncomeForProposedTractor : 0;

        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: VIABILITYOFEXISTINGPROPOSEDTRACTOR_OBJECT })
    viabilityOfExistingProposedTractor;

    @wire(getPicklistValues, { recordTypeId: '$viabilityOfExistingProposedTractor.data.defaultRecordTypeId', fieldApiName: USAGE_TYPE_FIELD })
    usageTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.usageTypeOptions = [...this.usageTypeOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$viabilityOfExistingProposedTractor.data.defaultRecordTypeId', fieldApiName: TRACTOR_HARVESTER_FIELD })
    tractorHarvesterValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.tractorHarvesterOptions = [...this.tractorHarvesterOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$viabilityOfExistingProposedTractor.data.defaultRecordTypeId', fieldApiName: EXISTING_PROPOSED_FIELD })
    existingProposedValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.existingProposedOptions = [...this.existingProposedOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    async connectedCallback() {
        this.handleAddRow();
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
                    res.Usage_Type = res.Usage_Type;
                    res.Existing_Proposed = res.Existing_Proposed;
                    res.Tractor_Harvester = res.Tractor_Harvester;
                    res.Nos_of_Hours_run_in_year = res.Nos_of_Hours_run_in_year;
                    res.Per_Hour_Rate = res.Per_Hour_Rate;
                    res.Diesal_counsumption_hr = res.Diesal_counsumption_hr;
                    this.disableAddRows = true;
                    return;
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
        saveViabilityExistingTractorDetails({ viabilityOfExistingTractorLst: this.filterList, fieldInvestigationId: this.fieldInvestigationRecordId }).then(result => {
            this.isSpinner = false;
            this.showToastMessage('success', 'Existing Tractor Loan Information is Saved Successfully!!', 'Success');
            console.log('result ==> ', result);
            let fields = {};
            fields['Id'] = this.fieldInvestigationRecordId;
            fields['Total_Agri_Expenses_for_Existing_Harvest__c'] = this.totalAgriExpensesForExistingHarvester;
            fields['Total_Agri_Expenses_for_Proposed_Harvest__c'] = this.totalAgriExpensesForProposedHarvester;
            fields['Total_Agri_Expenses_for_Existing_Tractor__c'] = this.totalAgriExpensesForExistingTractor;
            fields['Total_Agri_Expenses_for_Proposed_Tractor__c'] = this.totalAgriExpensesForProposedTractor;
            fields['Total_Agri_Income_for_Existing_Harvester__c'] = this.totalAgriIncomeForExistingHarvester;
            fields['Total_Agri_Income_for_Proposed_Harvester__c'] = this.totalAgriIncomeForProposedHarvester;
            fields['Total_Agri_Income_for_Existing_Tractor__c']   = this.totalAgriIncomeForExistingTractor;
            fields['Total_Agri_Income_for_Proposed_Tractor__c']   = this.totalAgriIncomeForProposedTractor;
            fields['Total_Agri_Net_Income_for_Existing_Harve__c'] = this.totalAgriNetIncomeForExistingHarvester;
            fields['Total_Agri_Net_Income_for_Proposed_Harve__c'] = this.totalAgriNetIncomeForProposedHarvester;
            fields['Total_Agri_Net_Income_for_Existing_Tract__c'] = this.totalAgriNetIncomeForExistingTractor;
            fields['Total_Agri_Net_Income_for_Proposed_Tract__c'] = this.totalAgriNetIncomeForProposedTractor;
            fields['Total_Agri_Comm_Expenses_Exist_Harvest__c']   = this.totalAgriCommercialExpensesForExistingHarvester;
            fields['Total_Agri_Comm_Expen_Proposed_Harvest__c']   = this.totalAgriCommercialExpensesForProposedHarvester;
            fields['Total_Agri_Comm_Expense_Existing_Tractor__c'] = this.totalAgriCommercialExpensesForExistingTractor;
            fields['Total_Agri_Comm_Expense_Proposed_Tractor__c'] = this.totalAgriCommercialExpensesForProposedTractor;
            fields['Total_Agri_Comm_Income_Existing_Harvest__c']  = this.totalAgriCommercialIncomeForExistingHarvester;
            fields['Total_Agri_Comm_Income_Proposed_Harvest__c']  = this.totalAgriCommercialIncomeForProposedHarvester;
            fields['Total_Agri_Comm_Income_Existing_Tractor__c']  = this.totalAgriCommercialIncomeForExistingTractor;
            fields['Total_Agri_Comm_Income_Proposed_Tractor__c']  = this.totalAgriCommercialIncomeForProposedTractor;
            fields['Total_Agri_Com_NetIncome_Existing_Harves__c'] = this.totalAgriCommercialNetIncomeForExistingHarvester;
            fields['Total_Agri_Com_NetIncome_Proposed_Harves__c'] = this.totalAgriCommercialNetIncomeForProposedHarvester;
            fields['Total_Agri_Comm_NetIncome_Existing_Tract__c'] = this.totalAgriCommercialNetIncomeForExistingTractor;
            fields['Total_Agri_Com_NetIncome_Proposed_Tract__c']  = this.totalAgriCommercialNetIncomeForProposedTractor;

            const recordInput = {
                fields
            };
            console.log('field' + JSON.stringify(fields));
            updateRecord(recordInput)
                .then(() => {
                    this.isSpinner = false;
                    this.showToastMessage('Success!', 'FI Updated Successfully', 'success', 'dismissable');
                    refreshApex(this.refreshApexData);
                    this.dispatchEvent(new CustomEvent('viabilityInformationUpdated',{
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
        //SFTRAC-614
        if(this.filterList.length < this.maxRows){
            this.disableAddRows = false;
        }
    }

    calculateTotalIncome(){
        this.totalAgriExpensesForExistingHarvester = 0;
        this.totalAgriExpensesForProposedHarvester = 0;
        this.totalAgriExpensesForExistingTractor = 0;
        this.totalAgriExpensesForProposedTractor = 0;

        this.totalAgriIncomeForExistingHarvester = 0;
        this.totalAgriIncomeForProposedHarvester = 0;
        this.totalAgriIncomeForExistingTractor = 0;
        this.totalAgriIncomeForProposedTractor = 0;

        this.totalAgriNetIncomeForExistingHarvester = 0;
        this.totalAgriNetIncomeForProposedHarvester = 0;
        this.totalAgriNetIncomeForExistingTractor = 0;
        this.totalAgriNetIncomeForProposedTractor = 0;

        this.totalAgriCommercialExpensesForExistingHarvester = 0;
        this.totalAgriCommercialExpensesForProposedHarvester = 0;
        this.totalAgriCommercialExpensesForExistingTractor = 0;
        this.totalAgriCommercialExpensesForProposedTractor = 0;

        this.totalAgriCommercialIncomeForExistingHarvester = 0;
        this.totalAgriCommercialIncomeForProposedHarvester = 0;
        this.totalAgriCommercialIncomeForExistingTractor = 0;
        this.totalAgriCommercialIncomeForProposedTractor = 0;

        this.totalAgriCommercialNetIncomeForExistingHarvester = 0;
        this.totalAgriCommercialNetIncomeForProposedHarvester = 0;
        this.totalAgriCommercialNetIncomeForExistingTractor = 0;
        this.totalAgriCommercialNetIncomeForProposedTractor = 0;

        this.filterList.forEach(ele=>{
            let expenses = ele.Expenses && ele.Expenses!="" ? parseFloat(ele.Expenses) : 0;
            let totalIncome = ele.Net_Income && ele.Net_Income !="" ? parseFloat(ele.Net_Income) : 0;
            let netIncome = ele.Net_Income && ele.Net_Income!="" ? parseFloat(ele.Net_Income) : 0;

            if(ele.Existing_Proposed && ele.Existing_Proposed == 'Existing' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Harvester' && ele.Usage_Type && ele.Usage_Type == 'Agriculture'){
                this.totalAgriExpensesForExistingHarvester = this.totalAgriExpensesForExistingHarvester + expenses
                this.totalAgriIncomeForExistingHarvester = this.totalAgriIncomeForExistingHarvester + totalIncome;
                this.totalAgriNetIncomeForExistingHarvester = this.totalAgriNetIncomeForExistingHarvester + netIncome;
            }
            else if(ele.Existing_Proposed && ele.Existing_Proposed == 'Proposed' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Harvester' && ele.Usage_Type && ele.Usage_Type == 'Agriculture'){
                this.totalAgriExpensesForProposedHarvester = this.totalAgriExpensesForProposedHarvester + expenses;
                this.totalAgriIncomeForProposedHarvester = this.totalAgriIncomeForProposedHarvester + totalIncome;
                this.totalAgriNetIncomeForProposedHarvester = this.totalAgriNetIncomeForProposedHarvester + netIncome;
            }
            else if(ele.Existing_Proposed && ele.Existing_Proposed == 'Existing' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Tractor' && ele.Usage_Type && ele.Usage_Type == 'Agriculture'){
                this.totalAgriExpensesForExistingTractor = this.totalAgriExpensesForExistingTractor + expenses;
                this.totalAgriIncomeForExistingTractor = this.totalAgriIncomeForExistingTractor + totalIncome;
                this.totalAgriNetIncomeForExistingTractor = this.totalAgriNetIncomeForExistingTractor + netIncome;
            }
            else if(ele.Existing_Proposed && ele.Existing_Proposed == 'Proposed' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Tractor' && ele.Usage_Type && ele.Usage_Type == 'Agriculture'){
                this.totalAgriExpensesForProposedTractor = this.totalAgriExpensesForProposedTractor + expenses;
                this.totalAgriIncomeForProposedTractor = this.totalAgriIncomeForProposedTractor + totalIncome;
                this.totalAgriNetIncomeForProposedTractor = this.totalAgriNetIncomeForProposedTractor + netIncome;
            }
            else if(ele.Existing_Proposed && ele.Existing_Proposed == 'Existing' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Harvester' && ele.Usage_Type && ele.Usage_Type == 'Agri commercial'){
                this.totalAgriCommercialExpensesForExistingHarvester = this.totalAgriCommercialExpensesForExistingHarvester + expenses
                this.totalAgriCommercialIncomeForExistingHarvester = this.totalAgriCommercialIncomeForExistingHarvester + totalIncome;
                this.totalAgriCommercialNetIncomeForExistingHarvester = this.totalAgriCommercialNetIncomeForExistingHarvester + netIncome;
            }
            else if(ele.Existing_Proposed && ele.Existing_Proposed == 'Proposed' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Harvester' && ele.Usage_Type && ele.Usage_Type == 'Agri commercial'){
                this.totalAgriCommercialExpensesForProposedHarvester = this.totalAgriCommercialExpensesForProposedHarvester + expenses;
                this.totalAgriCommercialIncomeForProposedHarvester = this.totalAgriCommercialIncomeForProposedHarvester + totalIncome;
                this.totalAgriCommercialNetIncomeForProposedHarvester = this.totalAgriCommercialNetIncomeForProposedHarvester + netIncome;
            }
            else if(ele.Existing_Proposed && ele.Existing_Proposed == 'Existing' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Tractor' && ele.Usage_Type && ele.Usage_Type == 'Agri commercial'){
                this.totalAgriCommercialExpensesForExistingTractor = this.totalAgriCommercialExpensesForExistingTractor + expenses;
                this.totalAgriCommercialIncomeForExistingTractor = this.totalAgriCommercialIncomeForExistingTractor + totalIncome;
                this.totalAgriCommercialNetIncomeForExistingTractor = this.totalAgriCommercialNetIncomeForExistingTractor + netIncome;
            }
            else if(ele.Existing_Proposed && ele.Existing_Proposed == 'Proposed' && ele.Tractor_Harvester && ele.Tractor_Harvester=='Tractor' && ele.Usage_Type && ele.Usage_Type == 'Agri commercial'){
                this.totalAgriCommercialExpensesForProposedTractor = this.totalAgriCommercialExpensesForProposedTractor + expenses;
                this.totalAgriCommercialIncomeForProposedTractor = this.totalAgriCommercialIncomeForProposedTractor + totalIncome;
                this.totalAgriCommercialNetIncomeForProposedTractor = this.totalAgriCommercialNetIncomeForProposedTractor + netIncome;
            }
        })
    }
    isInputValid(index) {
        let type;
        let usageType;
        let valid = [
            ...this.template.querySelectorAll(`[data-id="${index}"]`)
        ].reduce((validSoFar, inputField) => {
            if (!inputField.checkValidity()){
                inputField.reportValidity();
            }
            console.log('RECEIVED inputField >> '+inputField.name);
            console.log('RECEIVED inputValue >> '+inputField.value);
            if(inputField.name == "Tractor_Harvester__c"){
                type = inputField.value;
            }
            if(inputField.name == "Per_Hour_Rate__c" ){
                let v = parseInt(inputField.value);
                //SFTRAC-2045 Start
                if(type == 'Tractor' && (v < 0 || v > 1500)){
                    inputField.setCustomValidity("Min & Max value should be  Rs.0 to Rs.1500");
                }else if(type == 'Harvester' && (v < 0 || v > 3000)){
                    inputField.setCustomValidity("Min & Max value should be  Rs.0 to Rs.3000");
                }else{
                    inputField.setCustomValidity("");
                }//SFTRAC-2045 end

                /*if(v < 100 || v > 2000){
                    inputField.setCustomValidity("Min & Max value should be  Rs.100 to Rs.2000");
                }else{
                    inputField.setCustomValidity("");
                }*/
                inputField.reportValidity();
            }

            if(inputField.name == "Usage_Type__c"){
                usageType = inputField.value;
            }
            console.log('++++usageType '+usageType);

            if(inputField.name == "Nos_of_Hours_run_in_year__c" ){
                let noHrs = parseInt(inputField.value);
                //SFTRAC-2045 Start
                if(usageType == 'Agriculture'){
                    if(type == 'Tractor' && (noHrs < 0 || noHrs > 800)){
                        inputField.setCustomValidity("For Agriculture Tractor range should be between 0 to 800");
                    }else if(type == 'Harvester' && (noHrs < 0 || noHrs > 2000)){
                        inputField.setCustomValidity("For Agriculture Harvester range should be between 0 to 2000");
                    }else{
                        inputField.setCustomValidity("");
                    }
                }else if (usageType == 'Agri commercial'){
                    if(type == 'Tractor' && (noHrs < 0 || noHrs > 1000)){
                        inputField.setCustomValidity("For Agri commercial Tractor range should be between 0 to 1000");
                    }else if(type == 'Harvester' && (noHrs < 0 || noHrs > 2000)){
                        inputField.setCustomValidity("For Agri commercial Harvester range should be between 0 to 2000");
                    }else{
                        inputField.setCustomValidity("");
                    }
                }//SFTRAC-2045 End
                
                /*if(usageType == 'Agriculture' && (noHrs < 400 || noHrs > 800)){
                    inputField.setCustomValidity("For Agriculture range should be between 400 to 800");
                }else if (usageType == 'Agri commercial' && (noHrs < 0 || noHrs > 1000)){
                    inputField.setCustomValidity("For Agri commercial range should be between 0 to 1000");
                }else{
                    inputField.setCustomValidity("");
                }*/
                inputField.reportValidity();
            }

            if(inputField.name == "Diesal_counsumption_hr__c"){
                let v = parseFloat(inputField.value);
                if(v < 3.5 || v> 8){
                    inputField.setCustomValidity("Range should be between 3.5 to 8");
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
            Usage_Type:'',
            Tractor_Harvester:'',
            Total_Income:'',
            Per_Hour_Rate : '',
            Nos_of_Hours_run_in_year:'',
            Net_Income:'',
            Expenses:'',
            Existing_Proposed:'',
            Diesal_Rate_Hr : diesel_rate,
            Diesal_counsumption_hr : '',
            id: ++this.keyIndex,
            srNo: this.filterList.length+1
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
    handleChange(event){
        if (event.target.name == 'Usage_Type__c') {
            this.filterList[event.currentTarget.dataset.index].Usage_Type = event.target.value;
        }
        else if(event.target.name == 'Tractor_Harvester__c'){
            this.filterList[event.currentTarget.dataset.index].Tractor_Harvester = event.target.value;
        }
        else if(event.target.name == 'Per_Hour_Rate__c'){
            this.filterList[event.currentTarget.dataset.index].Per_Hour_Rate = event.target.value;
            this.Per_Hour_Rt = parseFloat(event.target.value);
        }
        else if(event.target.name == 'Nos_of_Hours_run_in_year__c'){
            this.filterList[event.currentTarget.dataset.index].Nos_of_Hours_run_in_year = event.target.value;
            this.No_Of_Week_Years = parseInt(event.target.value);
        }
        else if(event.target.name == 'Existing_Proposed__c'){
            this.filterList[event.currentTarget.dataset.index].Existing_Proposed = event.target.value;
        }   
        else if(event.target.name == 'Diesal_Rate_Hr__c'){
            this.filterList[event.currentTarget.dataset.index].Diesal_Rate_Hr = event.target.value;
            this.Diesal_Rate = parseFloat(event.target.value);
        }
        else if(event.target.name == 'Diesal_counsumption_hr__c'){
            this.filterList[event.currentTarget.dataset.index].Diesal_counsumption_hr = event.target.value;
            this.Diesal_counsumption = parseFloat(event.target.value);
        }

        this.filterList[event.currentTarget.dataset.index].Expenses = this.No_Of_Week_Years * this.Diesal_Rate * this.Diesal_counsumption;
        this.filterList[event.currentTarget.dataset.index].Total_Income = this.Per_Hour_Rt * this.No_Of_Week_Years;
        if(this.filterList[event.currentTarget.dataset.index].Total_Income){
            this.filterList[event.currentTarget.dataset.index].Net_Income = this.filterList[event.currentTarget.dataset.index].Total_Income - this.filterList[event.currentTarget.dataset.index].Expenses;
        }

        this.calculateTotalIncome();
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
            this.calculateTotalIncome(); 
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