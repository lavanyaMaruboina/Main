import { LightningElement, wire, api, track  } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord, updateRecord,getRelatedListRecords} from 'lightning/uiRecordApi';

import VEHICLE_DETAIL_OBJ from '@salesforce/schema/Vehicle_Detail__c';
import FIELD_INVESTIGATION_OBJECT from '@salesforce/schema/Field_Investigation__c';

import REPAYMENT_MODE from '@salesforce/schema/Vehicle_Detail__c.Repayment_Mode__c';
import REPAYMENT_FREQUENCY from '@salesforce/schema/Vehicle_Detail__c.Repayment_Frequency__c';
import INSTALLMENT_TYPE from '@salesforce/schema/Vehicle_Detail__c.Installment_Type__c';




import getVehicleDetailsRecord from '@salesforce/apex/iND_TF_FI_DetailsController.getVehicleDetailsRecord';
import updateVehicleRecord from '@salesforce/apex/iND_TF_FI_DetailsController.updateVehicleRecord';
import FORM_FACTOR from '@salesforce/client/formFactor';

import isFISubmitAllowed from '@salesforce/apex/iND_TF_FI_DetailsController.isFISubmitAllowed'; //SFTRAC-1880

const FI_FIELDS = [
    'Field_Investigation__c.Case__r.Loan_Application__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Name'
];

export default class lWC_LOS_LoanInformationfiDetails extends LightningElement {
    @track filterList = [];
    @track filterListCopy=[];
    @track newlyAddedRows = [];
    @track editedData=[];
    keyIndex = 0;

    isSpinner = false;
    maxRows = 10;
    @api recordId;
    @api fiRecordId;
    @api applicationId;
    @api isDisabled;
    typeOption = [];

    @wire(getObjectInfo, { objectApiName: VEHICLE_DETAIL_OBJ })
    vehicleDetails;

    @wire(getObjectInfo, { objectApiName: FIELD_INVESTIGATION_OBJECT })
   fiMetadata;

   //@track scrollableClass = 'slds-scrollable_x';
    get isDesktop(){
        if(FORM_FACTOR == 'Large'){
            return true;
        }
        return false; 
    }
    get className(){
        return FORM_FACTOR!='Large' ? 'slds-scrollable_x': '';
    }
    refreshApexData;


        @wire(getPicklistValues, {
        recordTypeId: '$vehicleDetails.data.defaultRecordTypeId',
        fieldApiName: REPAYMENT_MODE
        })
        repaymentModeType;

        @wire(getPicklistValues, {
        recordTypeId: '$vehicleDetails.data.defaultRecordTypeId',
        fieldApiName: REPAYMENT_FREQUENCY
        })
        repaymentFrequencyType;

        //SFTRAC-1366 Starts to remove Bi-Monthly option
        get repaymentFrequencyOptions() {
            if (this.repaymentFrequencyType && this.repaymentFrequencyType.data) {
                return this.repaymentFrequencyType.data.values.filter(option => option.value !== 'BI-MONTHLY');
            }
            return [];
        }//SFTRAC-1366 Ends

        @wire(getPicklistValues, {
        recordTypeId: '$vehicleDetails.data.defaultRecordTypeId',
        fieldApiName: INSTALLMENT_TYPE
        })
        installmentType;

    wireRunsOnlyOnce;
    @wire(getRecord, { recordId: '$fiRecordId', fields: FI_FIELDS })
    async wiredFIRecord({ error, data }) {
        if (data && !this.wireRunsOnlyOnce) {
            this.wireRunsOnlyOnce = true;
            this.fiRecord = data;
            this.applicationId = this.fiRecord.fields.Case__r.value.fields.Loan_Application__c.value;
        }
        else if (error) {
            console.log('error FI_FIELDS ', error);
            if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    @wire(getVehicleDetailsRecord, { loanApplicationId: '$applicationId' })
    getVehicleDetailsRec(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            this.filterList = [];
            this.filterList = data;
            this.editedData = data.map(item => ({ ...item, 
            purchasePrice: item.What_is_thePrice_of_TractorHarvester__c ,
            marginAmountToDealer:item.How_much_margin_amount_paid_to_dealer__c,
            emiConveyed:item.What_is_emi_convyed_to_customer__c,
            loanTenure:item.Loan_tenure__c,
            repaymentMode:item.Repayment_Mode__c,
            repaymentFrequency:item.Repayment_Frequency__c,
            installmentType:item.Installment_Type__c, loanAmountRequired:item.Loan_Amount__c, Asset_Name__c:item.Variant__c
            }));
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    submitFIAllowed = false;

    get isDisableSave(){
        return this.disableSave || !this.submitFIAllowed;
    }

    @wire(isFISubmitAllowed, {caseId: '$recordId'})
    wiredFISubmitResult({data, error}){ 
        if(data){
            this.submitFIAllowed = data;
        }else if(error){
            console.log('Error::',error);
            if(error.body.message) {
                this.showToast('Error!',error.body.message,'error','sticky');
            } else {
                this.showToast('Error!','Something went wrong, Please contact System Administrator','error','sticky');
            }
        }
    }

    async connectedCallback() {
        console.log('Loan information detail application id-',this.applicationId);
    }

    renderedCallback() {
        if (this.isDisabled) {
            const allElements = this.template.querySelectorAll('*');
            allElements.forEach(element => {
                element.disabled = true;
            });
        }
    }
    handleChange(event){
        let idx = event.currentTarget.dataset.index;
        let targetName = event.target.name;
        this.editedData[idx][targetName] = event.target.value;
        this.editedData = [...this.editedData]
    }
    validateData() {
        return this.editedData.every(item => {
            const requiredFields = ['Asset_Name__c','loanAmountRequired','purchasePrice', 'marginAmountToDealer', 'emiConveyed', 'loanTenure', 'repaymentMode', 'repaymentFrequency','installmentType'];
            for (const key of requiredFields) {
                if (!item[key]) {
                    return false;
                }
            }
            return true;
        });
    }

    async validateInput(query){
        return await [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }

    @api
    saveRows() {

        console.log('this.filterList SAVING => ', JSON.stringify(this.editedData));
        this.isSpinner = true;
       if(!this.validateData() || !this.validateInput('lightning-input') || !this.validateInput('lightning-combobox')){
        this.isSpinner = false;
        this.showToastMessage('Error', 'Please fill Vehicle data', 'Error');
        return true;
       }
        updateVehicleRecord({loanData:this.editedData, recId:this.applicationId}).then(result => {
            this.showToastMessage('success', 'Vehicle Information Updated', 'Success');
            this.isSpinner = false;
            const evt = new CustomEvent('vehicleinfoevt', {
                detail: true
            });
           this.dispatchEvent(evt);
           //SFTRAC-1915 start
           this.disableSave = true;
           const allElements = this.template.querySelectorAll('*');
            allElements.forEach(element => {
                element.disabled = true;
            });//SFTRAC-1915 end
        }).catch(error => {
            console.log('error'+JSON.stringify(error));
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