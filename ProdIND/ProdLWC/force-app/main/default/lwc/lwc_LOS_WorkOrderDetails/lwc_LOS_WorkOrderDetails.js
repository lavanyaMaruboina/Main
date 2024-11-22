import { LightningElement, wire, api, track  } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import FORM_FACTOR from '@salesforce/client/formFactor';
import residentFrontView from '@salesforce/label/c.Residence_Front_View';
import otherDocument from '@salesforce/label/c.Other_Document_Record_Type';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord} from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import userId from '@salesforce/user/Id';

import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';

import createDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.createDocumentRecord';
import checkDocFromApp from '@salesforce/apex/IND_ResidenceFIController.checkDocFromApp';

import WORKORDERDETAIL_OBJ from '@salesforce/schema/Work_Order_Details__c';

import getWorkOrderDetails from '@salesforce/apex/iND_TF_FI_DetailsController.getWorkOrderDetails';
import saveWorkOrderDetail from '@salesforce/apex/iND_TF_FI_DetailsController.saveWorkOrderDetails';

export default class Lwc_LOS_WorkOrderDetails extends NavigationMixin(LightningElement) {
    @track filterList = [];
    @track filterListCopy=[];
    @track newlyAddedRows = [];
    keyIndex = 0;
    disableAddRows=false;
    isSpinner = false;
    maxRows = 3;
    @api recordId;
    @api fiRecordId;
    @api applicationId;
    @api applicantId;
    refreshApexData;

    label = {
        residentFrontView,otherDocument
        };

    showUpload = false;
    showDocView = false;
    isVehicleDoc = false;
    isAllDocType = false;
    uploadViewDocFlag = false;
    sendingRecordTypeName = '';
    residenceUpload=false;

    @track currentUserName;
    @track currentUserEmailId;
    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserEmailId = data.fields.Email.value;
        } else if (error) {
        }
    }

    @wire(getObjectInfo, { objectApiName: WORKORDERDETAIL_OBJ })
    workOrderDetails

    @wire(getWorkOrderDetails, { fieldInvestigationId: '$fiRecordId' })
    getWorkOrderDetailsData(result) {
        this.refreshApexData = result;
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('Work Order detail DATA @wire method >>'+JSON.stringify(data));
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
        console.log('work order application'+this.applicationId , 'applicant-', this.applicantId);
        this.handleAddRow();
    };

    async handleChange(event) {
        let idx = event.currentTarget.dataset.index;
        if (event.target.name == 'Contract_with_Company__c') {
            this.filterList[idx].ContractWithCompany = event.target.value;
        }
        if (event.target.name == 'Date_of_Commencement__c') {
            this.filterList[idx].dateofCommencement = event.target.value;
        }
        if (event.target.name == 'Explanation__c') {
            this.filterList[idx].Explanation = event.target.value;
        }
        if (event.target.name == 'Contact_Amount__c') {
            this.filterList[idx].contactAmount = event.target.value;
        }
        if (event.target.name == 'Tenure_of_Contract_Years__c') {
            this.filterList[idx].tenureofContacts = event.target.value;
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
            ContractWithCompany: '',
            dateofCommencement: '',
            Explanation:'',
            contactAmount:'',
            tenureofContacts:'',
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
        saveWorkOrderDetail({ workOrderLst: this.filterList, fieldInvestigationId: this.fiRecordId }).then(result => {
            this.showToastMessage('success', 'Work Order Saved Successfully!!', 'Success');
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
    documentType;
    handleUpload(){
        this.documentType = 'Work order'
        this.createDocument(this.documentType, this.label.otherDocument);
    }
    documentId;
    docDeleted() { this.documentId = null; }
    openUploadComp(recordType) {
        this.showUpload = true;
        this.showDocView = true;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.sendingRecordTypeName = recordType;
        this.uploadViewDocFlag = true;
    }

    async createDocument(docType, recordType) {
        await createDocumentRecord({ caseId: this.fiRecordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: docType, recordTypeName: recordType })
            .then((response) => {
                console.log('response ', response);
                this.documentId = response;
                this.openUploadComp(recordType);//CISP-2975
            })
            .catch((error) => {
                if (error.body.message) {
                    this.showToast('Error!', error.body.message, 'error', 'sticky');
                } else {
                    this.showToast('Error!', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                }
            });
    }

    async changeflagvalue(event) {
        this.uploadViewDocFlag = false;
        this.residenceUpload = true;
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

        if (event.detail.contentDocumentId != null && event.detail.backcontentDocumentId != null) {
            const evt = new ShowToastEvent({
                title: "All uploaded!",
                variant: 'success',
            });
            this.dispatchEvent(evt);

        }
    }
}