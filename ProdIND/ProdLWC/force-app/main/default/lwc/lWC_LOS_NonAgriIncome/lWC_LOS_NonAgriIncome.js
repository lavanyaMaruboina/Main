import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import NON_AGRI_OBJECT from '@salesforce/schema/Non_Agri_Income__c';
import UTILIZATION_FIELD from '@salesforce/schema/Non_Agri_Income__c.Utilization__c';

import fetchCategoryMaster from '@salesforce/apex/iND_TF_FI_DetailsController.fetchCategoryMaster';
import fetchSubcategoriesByCategory from '@salesforce/apex/iND_TF_FI_DetailsController.fetchSubcategoriesByCategory';

import fetchNonAgriInfo from '@salesforce/apex/iND_TF_FI_DetailsController.fetchNonAgriInfo';
import saveNonAgriIncomeInformation from '@salesforce/apex/iND_TF_FI_DetailsController.saveNonAgriIncomeInformation';

import FORM_FACTOR from '@salesforce/client/formFactor';

import FI_NonAgriIncomeInfo_Rows_LABEL from '@salesforce/label/c.FI_NonAgriIncomeInformation_Rows';
import { deleteRecord } from 'lightning/uiRecordApi';
export default class LWC_LOS_NonAgriIncome extends LightningElement {
    @api recordId;
    @api fieldInvestigationRecordId;

    @track categoryOptions = [];
    @track utilizationOptions = [];

    disableAddRows = false;
    refreshApexData;

    @track filterList = [];
    keyIndex = 0;

    isSpinner = false;
    maxRows = FI_NonAgriIncomeInfo_Rows_LABEL;

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

    @wire(getObjectInfo, { objectApiName: NON_AGRI_OBJECT })
    nonAgriIncomeinfo;
    
    @wire(getPicklistValues, { recordTypeId: '$nonAgriIncomeinfo.data.defaultRecordTypeId', fieldApiName: UTILIZATION_FIELD })
    utilizationPicklistValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.utilizationOptions = [...this.utilizationOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    // @wire(fetchCategoryMaster)
    // getCategoryData({data,error}) {
    //     if (data) {
    //         console.log('Category Master Information DATA @wire method >>'+JSON.stringify(data));
    //         data.forEach(val => {
    //             this.categoryOptions = [...this.categoryOptions, { value: val.id, label: val.category, subCategory: val.sub_category, income: val.income }];
    //         });
    //     }
    //     else if (error) {
    //         this.processErrorMessage(error);
    //     }
    // }

    @wire(fetchCategoryMaster)
    getCategoryData({data,error}) {
        if (data) {
            console.log('Category Master Information DATA @wire method >>'+JSON.stringify(data));
            const uniqueCategories = new Set();

            data.forEach(val => {
                uniqueCategories.add(val.category);
            });

            this.categoryOptions = Array.from(uniqueCategories).map(category => ({
                label: category,
                value: category
            }));

        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }


    @wire(fetchNonAgriInfo, { fieldInvestigationRecordId: '$fieldInvestigationRecordId' })
    getNonAgriIncomeData(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('Non Agri Income Information DATA @wire method >>'+JSON.stringify(data));
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
    
    fetchSubcategories(selectedCategory,index) {
        fetchSubcategoriesByCategory({ selectedCategory: selectedCategory })
            .then(result => {
                this.subcategoryOptions = result.map(subcategory => ({
                    label: subcategory.subcategoryName,
                    value: subcategory.subcategoryId,
                    income: subcategory.income
                }));

                this.filterList = this.filterList.map((row, i) => {
                    if (i === index) {
                        return { ...row, subcategoryOptions };
                    }
                    return row;
                });
            })
            .catch(error => {
                this.processErrorMessage(error);
            });
    }

    async handleChange(event) {
        console.log('Handle select '+event.target.value);
        if (event.target.name == 'Category') {
            this.filterList[event.currentTarget.dataset.index].Category = event.target.value;
             let cat = this.categoryOptions?.filter(val => val.value == event.target.value)[0];
             this.filterList[event.currentTarget.dataset.index].Category_Value = cat?.label;
            // this.filterList[event.currentTarget.dataset.index].Sub_Category = cat.subCategory;
            // this.filterList[event.currentTarget.dataset.index].Income = cat.income;
            this.fetchSubcategories(event.target.value , event.currentTarget.dataset.index);
        }
        else if(event.target.name == 'Sub_Category'){
            this.filterList[event.currentTarget.dataset.index].Sub_Category = event.target.value;
            let cat = this.subcategoryOptions?.filter(val => val.value == event.target.value)[0];
            this.filterList[event.currentTarget.dataset.index].Income = cat?.income;
            this.filterList[event.currentTarget.dataset.index].Sub_categoryLabel = cat?.label
        }
        else if (event.target.name == 'Utilization') {
            this.filterList[event.currentTarget.dataset.index].Utilization = event.target.value;
        }
        this.calculateTotalIncome(event.currentTarget.dataset.index);
        console.log('HANDLE CHANGE >>  '+JSON.stringify(this.filterList));
    }

    calculateTotalIncome(index){
        if(this.filterList[index].hasOwnProperty('Category') && this.filterList[index].hasOwnProperty('Utilization') && this.filterList[index].Category.length > 0 && this.filterList[index].Utilization.length > 0 ){
            let total = parseFloat(this.filterList[index].Income) * parseFloat(this.filterList[index].Utilization);
            total/=100.0;
            this.filterList[index].Total_Income = total.toFixed(2);
        }else{
            this.filterList[index].Total_Income = parseFloat(0).toFixed(2);
        }
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
            Category: '',
            Category_Value: '',
            Sub_Category: '',
            Sub_categoryLabel:'',
            Income: '',
            Utilization: '',
            Total_Income: '',
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
    
            console.log('After Deleting >> FilterList >> '+JSON.stringify(this.filterList));
    
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
                    res.Category = res.Category_Value;
                    this.fetchSubcategories(res.Category_Value , currentRecId);
                    res.Sub_Category = res.Sub_Category;
                    res.Utilization = res.Utilization;
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
        saveNonAgriIncomeInformation({ nonAgriLst: this.filterList, fieldInvestigationRecordId: this.fieldInvestigationRecordId }).then(result => {
            this.showToastMessage('success', 'Non Agri Income Information Saved Successfully!!', 'Success');
            refreshApex(this.refreshApexData);
            this.isSpinner = false;
        }).catch(error => {
            this.processErrorMessage(error);
            this.isSpinner = false;
        })

        //SFTRAC-614
        if(this.filterList.length < this.maxRows){
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