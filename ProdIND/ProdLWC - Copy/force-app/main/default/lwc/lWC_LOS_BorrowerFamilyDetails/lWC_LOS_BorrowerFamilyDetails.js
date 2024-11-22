import { LightningElement,api,wire ,track } from 'lwc';
import { getRecord, updateRecord,getRelatedListRecords} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import FIELD_INVESTIGATION_OBJECT from '@salesforce/schema/Field_Investigation__c';
import SPOUSE_GENDER from '@salesforce/schema/Field_Investigation__c.Spouse_Gender__c';
import FIRST_CHILD_GENDER from '@salesforce/schema/Field_Investigation__c.First_Child_Gender__c';
import SECOND_CHILD_GENDER from '@salesforce/schema/Field_Investigation__c.Second_Child_Gender__c';
import THIRD_CHILD_GENDER from '@salesforce/schema/Field_Investigation__c.Third_Child_Gender__c';
const FI_FIELDS = [
    'Field_Investigation__c.Case__r.Applicant__c',
    'Field_Investigation__c.Case__r.Type',
    'Field_Investigation__c.Case__r.Applicant__r.Name',
    'Field_Investigation__c.Case__r.Applicant__r.Applicant_Type__c',
    'Field_Investigation__c.Case__r.Loan_Application__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Name',
    'Field_Investigation__c.Case__r.Loan_Application__r.Customer_Type__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Entity_Type__c',//SFTRAC-1183
    'Field_Investigation__c.Case__r.Status',
    
    'Field_Investigation__c.Father_DOB__c',
    'Field_Investigation__c.Mother_DOB__c',
    'Field_Investigation__c.Spouse_Gender__c',
    'Field_Investigation__c.Spouse_DOB__c',
    'Field_Investigation__c.First_Child_Name__c',
    'Field_Investigation__c.First_Child_Gender__c',
    'Field_Investigation__c.First_Child_DOB__c',
    'Field_Investigation__c.Second_Child_Name__c',
    'Field_Investigation__c.Second_Child_Gender__c',
    'Field_Investigation__c.Second_Child_DOB__c',
    'Field_Investigation__c.Third_Child_Name__c',
    'Field_Investigation__c.Third_Child_Gender__c',
    'Field_Investigation__c.Third_Child_DOB__c',
    ];

export default class LWC_LOS_BorrowerFamilyDetails extends LightningElement {

    wireRunsOnlyOnce = false;
    fiRecord;
    applicantType;
    loanAppEntityType; //SFTRAC-1183
    applicationId;
    borrowerFlag=false;
    coBorrowerFlag=false;
    guarantorFlag=false;

    @api recordId;
    @track inputWrapper = {};
    @api fieldInvestigationId;
    @api isDisabled;
    @wire(getObjectInfo, { objectApiName: FIELD_INVESTIGATION_OBJECT })
    fiMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: SPOUSE_GENDER
        })
        spouseGenderType;

        @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: FIRST_CHILD_GENDER
        })
        firstChildGenderType;

        @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: SECOND_CHILD_GENDER
        })
        secondChildGenderType;

        @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: THIRD_CHILD_GENDER
        })
        thirdChildGenderType;

    @wire(getRecord, { recordId: '$fieldInvestigationId', fields: FI_FIELDS })
    async wiredFIRecord({ error, data }) {
        if (data && !this.wireRunsOnlyOnce) {
            this.wireRunsOnlyOnce = true;
            console.log('+++++BR getRecord FI_FIELDS ', data);
            this.fiRecord = data;
            this.applicantType = this.fiRecord?.fields?.Case__r?.value?.fields?.Applicant__r?.value?.fields?.Applicant_Type__c?.value;
            this.loanAppEntityType = this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Entity_Type__c.value; console.log('+++++BR loanAppEntityType '+this.loanAppEntityType) //SFTRAC-1183
            this.inputWrapperPopulator();
            this.applicationId = this.inputWrapper?.applicationId?.value;
            //this.applicantType = this.inputWrapper?.applicantType?.value;
            if(this.applicantType == 'Borrower'){
                this.borrowerFlag = true;
            }
            else if(this.applicantType == 'Co-borrower' || this.applicantType == 'Beneficiary'){
                this.coBorrowerFlag = true;
            }
            else if(this.applicantType == 'Guarantor'){
                this.guarantorFlag = true;
                this.coBorrowerFlag = true;
            }
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

    inputWrapperPopulator() {
        console.log('+++++BR inputWrapperPopulator ', this.fiRecord);
        console.log('+++++BR fatherDOB ', this.fiRecord.fields.Father_DOB__c.value);
        //Borrower Family Details - Sftrac-94
        this.inputWrapper['fatherDOB'] = { label: 'Father DOB', value: this.fiRecord.fields.Father_DOB__c.value };
        this.inputWrapper['motherDOB'] = { label: 'Mother DOB', value: this.fiRecord.fields.Mother_DOB__c.value };
        this.inputWrapper['spouseGender'] = { label: 'Spouse Gender', value: this.fiRecord.fields.Spouse_Gender__c.value };
        this.inputWrapper['spouseDOB'] = { label: 'Spouse DOB', value: this.fiRecord.fields.Spouse_DOB__c.value };
        this.inputWrapper['child1Name'] = { label: '1st Child Name', value: this.fiRecord.fields.First_Child_Name__c.value };
        this.inputWrapper['child1Gender'] = { label: '1st Child Gender', value: this.fiRecord.fields.First_Child_Gender__c.value };
        this.inputWrapper['child1DOB'] = { label: '1st Child DOB', value: this.fiRecord.fields.First_Child_DOB__c.value };
        this.inputWrapper['child2Name'] = { label: '2nd Child Name', value: this.fiRecord.fields.Second_Child_Name__c.value };
        this.inputWrapper['child2Gender'] = { label: '2nd Child Gender', value: this.fiRecord.fields.Second_Child_Gender__c.value };
        this.inputWrapper['child2DOB'] = { label: '2nd Child DOB', value: this.fiRecord.fields.Second_Child_DOB__c.value };
        this.inputWrapper['child3Name'] = { label: '3rd Child Name', value: this.fiRecord.fields.Third_Child_Name__c.value };
        this.inputWrapper['child3Gender'] = { label: '3rd Child Gender', value: this.fiRecord.fields.Third_Child_Gender__c.value };
        this.inputWrapper['child3DOB'] = { label: '3rd Child DOB', value: this.fiRecord.fields.Third_Child_DOB__c.value };

    }
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    renderedCallback() {
        if (this.isDisabled) {
            const allElements = this.template.querySelectorAll('*');
            allElements.forEach(element => {
                element.disabled = true;
            });
        }
    }

    handleInputChange(event) {
        this.inputWrapper[event.target.name].value = event.target.value;
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        if(fieldName === 'fatherDOB' || fieldName === 'motherDOB' || fieldName === 'spouseDOB'){
            var dateObj = new Date();
            var dd = dateObj.getDate();
            var mm = dateObj.getMonth() + 1;
            var yyyy = dateObj.getFullYear();
            var minDate = new Date(yyyy - 80, mm - 1, dd);
            var maxDate = new Date(yyyy - 18, mm - 1, dd);
    
            if (dd == 29 && mm == 2) {maxDate.setDate(28);}
            var minAge = minDate.toISOString().slice(0, 10);
            var maxAge = maxDate.toISOString().slice(0, 10);

            let selectedDate = new Date(fieldValue).toISOString().slice(0, 10);
            let inputField = event.target;

        if (selectedDate < minAge) {
            inputField.setCustomValidity('Maximum age should be at most 80 years');
            inputField.reportValidity();
        } else if (selectedDate > maxAge) {
            inputField.setCustomValidity('Minimum age should be at least 18 years');
            inputField.reportValidity();
        } else {
            inputField.setCustomValidity('');
            inputField.reportValidity();
        }
        }
    }
    
    @api saveRows() {
        console.log('+++++BR Save method '+this.fieldInvestigationId);
        const dateFieldNames = ['fatherDOB','motherDOB','spouseDOB'];
        let allValid = true;
        dateFieldNames.forEach((fieldName) => {
            let inputField = this.template.querySelector(`[data-id=${fieldName}]`);
            if (inputField && !inputField.reportValidity()) {
                allValid = false;
            }
        });
        if (!allValid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please verify borrower family details.',
                    variant: 'error',
                })
            );
            return;
        }
        const fields = {};
        fields['Id'] = this.fieldInvestigationId;
        //Borrower Family Details
        fields['Father_DOB__c'] = this.inputWrapper['fatherDOB'].value;
        fields['Mother_DOB__c'] = this.inputWrapper['motherDOB'].value;
        fields['Spouse_Gender__c'] = this.inputWrapper['spouseGender'].value;
        fields['Spouse_DOB__c'] = this.inputWrapper['spouseDOB'].value;
        fields['First_Child_Name__c'] = this.inputWrapper['child1Name'].value;
        fields['First_Child_Gender__c'] = this.inputWrapper['child1Gender'].value;
        fields['First_Child_DOB__c'] = this.inputWrapper['child1DOB'].value;
        fields['Second_Child_Name__c'] = this.inputWrapper['child2Name'].value;
        fields['Second_Child_Gender__c'] = this.inputWrapper['child2Gender'].value;
        fields['Second_Child_DOB__c'] = this.inputWrapper['child2DOB'].value;
        fields['Third_Child_Name__c'] = this.inputWrapper['child3Name'].value;
        fields['Third_Child_Gender__c'] = this.inputWrapper['child3Gender'].value;
        fields['Third_Child_DOB__c'] = this.inputWrapper['child3DOB'].value;

        const recordInput = {
            fields
        };
        console.log('field' + JSON.stringify(fields));
        updateRecord(recordInput) .then(() => { 
            console.log('Updated Borrower Family Details'); 
        }).catch((error) => { console.log('Borrower Family Details update fail in catch'); });
    }

}