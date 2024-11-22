import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import FLEETDETAIL_OBJ from '@salesforce/schema/Fleet_Details__c';
import ASSET_TYPE from '@salesforce/schema/Fleet_Details__c.Asset_Type__c';
import HYPOTHECATION_TYPE from '@salesforce/schema/Fleet_Details__c.Hypothecation__c';


import getFleetDetails from '@salesforce/apex/iND_TF_FI_DetailsController.getFleetDetails';
import saveFleetDetails from '@salesforce/apex/iND_TF_FI_DetailsController.saveFleetDetails';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class Lwc_LOS_FleetDetails extends LightningElement {
    @track filterList = [];
    @track filterListCopy=[];
    @track newlyAddedRows = [];
    keyIndex = 0;
    disableAddRows=false;
    isSpinner = false;
    maxRows = Infinity;
    @api recordId;
    @api fiRecordId;
    refreshApexData;
    assettypeOption=[];
    hypothecationTypeOptions=[];

   // @track scrollableClass = 'slds-scrollable_x';

    get isDesktop(){
      //  console.log('FORM_FACTOR '+FORM_FACTOR);
        if(FORM_FACTOR == 'Large'){
          //  this.scrollableClass = '';
            return true;
        }
        return false; 
    }
      get className(){
        return FORM_FACTOR!='Large' ? 'slds-scrollable_x': '';
    }

    @wire(getObjectInfo, { objectApiName: FLEETDETAIL_OBJ })
    workOrderDetails

    @wire(getPicklistValues, { recordTypeId: '$workOrderDetails.data.defaultRecordTypeId', fieldApiName: ASSET_TYPE })
    assetTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.assettypeOption = [...this.assettypeOption, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$workOrderDetails.data.defaultRecordTypeId', fieldApiName: HYPOTHECATION_TYPE })
    hypothecationValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.hypothecationTypeOptions = [...this.hypothecationTypeOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getFleetDetails, { fieldInvestigationId: '$fiRecordId' })
    getFleetDetailsData(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('Fleet detail DATA @wire method >>'+JSON.stringify(data));
            if(data.length>0){
                this.filterList = [];
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
        this.handleAddRow();
    };
    async handleChange(event) {
        let idx = event.currentTarget.dataset.index;
        if (event.target.name == 'Asset_Type__c') {
            this.filterList[idx].assetType = event.target.value;
        }
        if (event.target.name == 'Asset_Name__c') {
            this.filterList[idx].assetName = event.target.value;
        }
        if (event.target.name == 'RC_no__c') {
            this.filterList[idx].rcNo = event.target.value;
        }
        if (event.target.name == 'YOM__c') {
            this.filterList[idx].yom = event.target.value;
        }
        if (event.target.name == 'Owner_Name__c') {
            this.filterList[idx].ownerName = event.target.value;
        }
        if (event.target.name == 'Hypothecation__c') {
            this.filterList[idx].hypothecation = event.target.value;
        }
        if (event.target.name == 'Financier_Name__c') {
            this.filterList[idx].financierName = event.target.value;
        }
        if (event.target.name == 'Loan__c') {
            this.filterList[idx].loan = event.target.value;
        }
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

    handleAddRow(event) {
        if(!this.isInputValid(this.keyIndex)){
            return;
        }

        let objRow = {
            isValid : false,
            isDatabase: false,
            assetType: '',
            assetName: '',
            rcNo:'',
            yom:'',
            ownerName:'',
            hypothecation:'',
            financierName:'',
            loan:'',
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

    saveRows() {
        console.log('this.filterList SAVING => ', JSON.stringify(this.filterList));
        console.log('Field Investigation Id : '+ this.fiRecordId);

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
        saveFleetDetails({ fleetLst: this.filterList, fieldInvestigationId: this.fiRecordId }).then(result => {
            this.showToastMessage('success', 'Fleet Details Saved Successfully!!', 'Success');
            refreshApex(this.refreshApexData);
            this.isSpinner = false;
        }).catch(error => {
            this.processErrorMessage(error);
            this.isSpinner = false;
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