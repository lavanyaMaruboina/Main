import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveCurrentFI from '@salesforce/apex/IND_ResidenceFIReadOnlyController.saveCurrentFI';
import getDocumentsOfFI from '@salesforce/apex/IND_ResidenceFIReadOnlyController.getDocumentsOfFI';
import getVehicleDetailsOfFI from '@salesforce/apex/IND_ResidenceFIReadOnlyController.getVehicleDetailsOfFI';
import loadResidenceFIData from '@salesforce/apex/IND_ResidenceFIController.loadResidenceFIData';

// Custom labels
import creditProcessing from '@salesforce/label/c.Credit_Processing';
import fieldInvestigation from '@salesforce/label/c.Field_Investigation';
import pendingOfficeFIStatus from '@salesforce/label/c.Pending_Office_FI_Status';
import cordVerGreenColor from '@salesforce/label/c.Coordinates_Verified_Green_Color';
import cordVerAmberColor from '@salesforce/label/c.Coordinates_Verified_Amber_Color';
import cordVerRedColor from '@salesforce/label/c.Coordinates_Verified_Red_Color';
import resAcptRejSelMessage from '@salesforce/label/c.Residence_FI_Accepted_Rejected_Selection_Error_Message';
import remarksMessage from '@salesforce/label/c.FI_Remarks_Error_Message';
import serverDownErrMessage from '@salesforce/label/c.Server_down_error_message';
import acceptedSuccessfully from '@salesforce/label/c.Accepted_Successfully';
import rejectedSuccessfully from '@salesforce/label/c.Rejected_Successfully';
import caseCurrentResidnceFIType from '@salesforce/label/c.Case_Current_Residence_FI_Type';
import casePermanentResidnceFIType from '@salesforce/label/c.Case_Permanent_Residence_FI_Type';
import currentFIStatus from '@salesforce/label/c.Current_FI_Status';
import permanentFIStatus from '@salesforce/label/c.Permanent_FI_Status';
import accepted from '@salesforce/label/c.FI_Accepted';
import rejected from '@salesforce/label/c.FI_Rejected';
import docCurResAdrType from '@salesforce/label/c.Document_Current_Residential_Address_Type';
import docPerResAdrType from '@salesforce/label/c.Document_Permanent_Residential_Address_Type';
import currResFITitle from '@salesforce/label/c.CURRENT_RESIDENCE_FI_TITLE';
import permResFITitle from '@salesforce/label/c.PERMANENT_RESIDENCE_FI_TITLE';
import resAddrCurrTitle from '@salesforce/label/c.Residence_Address_Current_Title';
import resAddrPermTitle from '@salesforce/label/c.Residence_Address_Permanent_Title';
import signatureView from '@salesforce/label/c.signatureView';
import viewResidencefrontview from '@salesforce/label/c.viewResidencefrontview';
import coordinatesVerfied from '@salesforce/label/c.coordinatesVerfied';
import name from '@salesforce/label/c.Name';
import makeTitle from '@salesforce/label/c.Make_Title';
import modelTitle from '@salesforce/label/c.Model_Title';
import variantTitle from '@salesforce/label/c.Variant_Title';
import dealerTitle from '@salesforce/label/c.Dealer_Title';
import fiReqGenDT from '@salesforce/label/c.FI_Request_Generation_Date_And_Time';
import successMsg from '@salesforce/label/c.Success';
import errorMsg from '@salesforce/label/c.Error';
import getProfileName from '@salesforce/apex/GenericUploadController.getProfileName';//CISP-7179   
import getContentVersion from '@salesforce/apex/GenericUploadController.getContentVersion';//CISP-7179 
// Field Investigation Field API Names
const FI_FIELDS = [
    'Field_Investigation__c.FI_Status__c',
    'Field_Investigation__c.Address_Line_1__c',
    'Field_Investigation__c.Address_Line_2__c',
    'Field_Investigation__c.City__c',
    'Field_Investigation__c.Pin_Code__c',
    'Field_Investigation__c.State__c',
    'Field_Investigation__c.Landmark__c',
    'Field_Investigation__c.Phone_Number__c',
    'Field_Investigation__c.Mobile__c',
    'Field_Investigation__c.Coordinates_Verified__c',
    'Field_Investigation__c.Are_Co_ordinates_Matching_If_Amber__c',
    'Field_Investigation__c.Coordinates_Distance__c',//CISP-2701
    'Field_Investigation__c.Product__c',
    'Field_Investigation__c.Remarks__c',
    'Field_Investigation__c.Case__c',
    'Field_Investigation__c.Case__r.OwnerId',
    'Field_Investigation__c.Case__r.CreatedDate',
    'Field_Investigation__c.Case__r.Origin',
    'Field_Investigation__c.Case__r.Type',
    'Field_Investigation__c.Case__r.Status',
    'Field_Investigation__c.Case__r.Subject',
    'Field_Investigation__c.Case__r.Applicant__c',
    'Field_Investigation__c.Case__r.Applicant__r.Name',
    'Field_Investigation__c.Case__r.Loan_Application__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.StageName',
    'Field_Investigation__c.Case__r.Loan_Application__r.Sub_Stage__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Product_Type__c',
    'Field_Investigation__c.No_of_Attempts__c',
    'Field_Investigation__c.FI_Observation__c',
];

export default class IND_LWC_ViewApplicationResidenceFI extends NavigationMixin(LightningElement) {
    iscommunityuser;isPreview = false;converId;height = 32;//CISP-7179 
    @track coordinatesMatchDisable = false; //CISP-3135
    @api recordId;
    @api isRevokedLoanApplication;
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @track applicationId;
    @track applicantId;
    @track documentAddressType;
    @track pendingFI = false;
    @track disableButtonsAndFields = false;
    @track fiAccordionTitle;
    @track residenceAddressSectionHeader;
    @track inputWrapper = {};
    @track fileDocumentLists = [];
    @track activeSections = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
    get fiStatusOptions() {
        return [
            { label: accepted, value: accepted },
            { label: rejected, value: rejected }
        ];
    }
    @track isTractor;
    fiRecord;
    @track callingFromFIScreen = true;
    @track currentCaseId;

    @wire(getRecord, { recordId: '$recordId', fields: FI_FIELDS })
    async wiredFIRecord({ error, data }) {
        if (data) {
            this.fiRecord = data;
            this.isTractor = this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Product_Type__c.value == 'Tractor'? true : false;
            console.log('isTractor '+this.isTractor);
            // Prepare Input Wrapper
            await this.inputWrapperPopulator();
            //console.log('before inputWrapper..', JSON.stringify(this.inputWrapper));
            // Updating other fields
            this.applicationId = this.inputWrapper.applicationId.value;
            this.applicantId = this.inputWrapper.applicantId.value;
            this.documentAddressType = this.inputWrapper.documentAddressType.value;
            if (this.inputWrapper.stage.value !== creditProcessing || this.inputWrapper.subStage.value !== fieldInvestigation) {
                this.disableButtonsAndFields = true;
            }
            if (this.inputWrapper.residenceFIStatus.value == null || this.inputWrapper.residenceFIStatus.value === pendingOfficeFIStatus) {
                this.pendingFI = true;
                this.disableButtonsAndFields = true;
            }
            if (this.inputWrapper.Residence_FI_Accepted_Rejected.value === accepted && this.inputWrapper.subStage.value !== fieldInvestigation) {//CISP-3183
                this.disableButtonsAndFields = true;
            }
            //CISP-3135
            if( this.inputWrapper.coordinatesVerfied.value != 'warning'){//CISP-3225
                this.coordinatesMatchDisable = true;
            }//CISP-3135 END

            this.getProfile(this.inputWrapper.applicationId.value);//CISP-7179
            this.currentCaseId = this.inputWrapper.caseId.value
        }
        else if (error) {
            if (error.body.message) {
                this.showToast(errorMsg, error.body.message, 'error', 'sticky');
            } else {
                this.showToast(errorMsg, serverDownErrMessage, 'error', 'sticky');
            }
        }
    }
    //CISP-7179 start 
    getProfile(applicationId){
        getProfileName({ loanApplicationId: applicationId })
        .then(result => {
            console.log('Result in generic upload ', result);
            if(result){
                this.iscommunityuser = result;
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }//CISP-7179 end 
    @wire(getDocumentsOfFI, { applicationId: '$applicationId', applicantId: '$applicantId', documentAddressType: '$documentAddressType' })
    wiredFilesResult({ data, error }) {
        if (data) {
            //console.log('residence files data..', JSON.stringify(data));
            if (data.signatureView) {
                this.inputWrapper['signatureView'].value = data.signatureView;
            }
            if (data.viewResidencefrontview) {
                this.inputWrapper['viewResidencefrontview'].value = data.viewResidencefrontview;
            }
        }
        else if (error) {
            if (error.body.message) {
                this.showToast(errorMsg, error.body.message, 'error', 'sticky');
            } else {
                this.showToast(errorMsg, serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    @wire(getVehicleDetailsOfFI, { applicationId: '$applicationId' })
    wiredVehicleDetails({ error, data }) {
        if (data) {
            //console.log('vehicle details data..', JSON.stringify(data));
            this.inputWrapper['make'].value = data.Make__c;
            this.inputWrapper['model'].value = data.Model__c;
            this.inputWrapper['variant'].value = data.Variant__c;
            this.inputWrapper['dealer'].value = data.Dealer_Sub_dealer_name__c;
            this.inputWrapper['purposeOfPurchase'].value = data.Purpose_of_purchase__c;
        } else if (error) {
            if (error.body.message) {
                this.showToast(errorMsg, error.body.message, 'error', 'sticky');
            } else {
                this.showToast(errorMsg, serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    @wire(loadResidenceFIData, { applicantId: '$applicantId' })
    wiredDocsResult({ data, error }) {
        if (data) {
            //console.log('document details data..', JSON.stringify(data));
            this.fileDocumentLists = [...data];
        } else if (error) {
            if (error.body.message) {
                this.showToast(errorMsg, error.body.message, 'error', 'sticky');
            } else {
                this.showToast(errorMsg, serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    saveCurrentFI() {
        //console.log('after inputWrapper..', JSON.stringify(this.inputWrapper));

        if(this.isTractor){
            this.inputWrapper.Residence_FI_Accepted_Rejected.value = 'Accepted';
        }
        if (this.inputWrapper.Residence_FI_Accepted_Rejected.value && this.inputWrapper.Remarks.value) {
            
            saveCurrentFI({
                inputWrapper: JSON.stringify(this.inputWrapper)
            })
                .then(result => {
                    this.disableButtonsAndFields = true;
                    if (result) {
                        this.showToast(successMsg, acceptedSuccessfully, 'success', 'dismissable');
                    } else {
                        this.showToast(successMsg, rejectedSuccessfully, 'success', 'dismissable');
                    }
                    const nextStage = new CustomEvent('submit');
                    this.dispatchEvent(nextStage);
                })
                .catch(error => {
                    if (error.body.message) {
                        this.showToast(errorMsg, error.body.message, 'error', 'sticky');
                    } else {
                        this.showToast(errorMsg, serverDownErrMessage, 'error', 'sticky');
                    }
                });
        } else if (this.inputWrapper.Residence_FI_Accepted_Rejected.value === '') {
            this.showToast(errorMsg, resAcptRejSelMessage, 'warning', 'dismissable');
        } else if (this.inputWrapper.Remarks.value === '') {
            this.showToast(errorMsg, remarksMessage, 'warning', 'dismissable');
        } else {
            this.showToast(errorMsg, resAcptRejSelMessage + ' & ' + remarksMessage, 'warning', 'dismissable');
        }
    }


    hideModalBox(){
        this.isPreview = false; 
    }
    previewImage(event) {
        //CISP-7179 
        if(this.iscommunityuser == true){
            getContentVersion({ conDocId: event.target.dataset.id })
              .then(result => {
                console.log('Result', result); this.converId = result[0].Id;
                this.isPreview = true;
              })
              .catch(error => {
                console.error('Error:', error);
            });
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: event.target.dataset.id
                }
            })
        } 
    } 

    handleFIInputChange(event) {
        if(event.target?.name == 'Remarks'){
            this.inputWrapper['Remarks'].value = event.target.value;
        }
        else{
            this.inputWrapper[event.target.fieldName.slice(0, -3)].value = event.target.value;
        }
    }

    handleFIStatusChange(event) {
        this.inputWrapper['Residence_FI_Accepted_Rejected'].value = event.target.value;
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

    async inputWrapperPopulator() {
        // Color variant based on Coordinates_Verified__c value
        let coordinatesVerifiedVariant = '';
        if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerGreenColor) {
            coordinatesVerifiedVariant = 'base-autocomplete';
        } else if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerAmberColor) {
            coordinatesVerifiedVariant = 'warning';
        } else if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerRedColor) {
            coordinatesVerifiedVariant = 'expired';
        }
        // FI fields
        this.inputWrapper['fiId'] = { value: this.recordId };
        this.inputWrapper['residenceFIStatus'] = { value: this.fiRecord.fields.FI_Status__c.value };
        this.inputWrapper['addrLine1'] = { value: this.fiRecord.fields.Address_Line_1__c.value };
        this.inputWrapper['addrLine2'] = { value: this.fiRecord.fields.Address_Line_2__c.value };
        this.inputWrapper['city'] = { value: this.fiRecord.fields.City__c.value };
        this.inputWrapper['pinCode'] = { value: this.fiRecord.fields.Pin_Code__c.value };
        this.inputWrapper['state'] = { value: this.fiRecord.fields.State__c.value };
        this.inputWrapper['landmark'] = { value: this.fiRecord.fields.Landmark__c.value };
        this.inputWrapper['phoneNo'] = { value: this.fiRecord.fields.Phone_Number__c.value };
        this.inputWrapper['mobile'] = { value: this.fiRecord.fields.Mobile__c.value };
        this.inputWrapper['coordinatesVerfied'] = { label: coordinatesVerfied, value: coordinatesVerifiedVariant };
        this.inputWrapper['Are_Co_ordinates_Matching_If_Amber'] = { value: this.fiRecord.fields.Are_Co_ordinates_Matching_If_Amber__c.value };
        this.inputWrapper['Coordinates_Distance'] = { value: this.fiRecord.fields.Coordinates_Distance__c.value };//CISP-2701
        this.inputWrapper['product'] = { label: 'Product', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Product_Type__c.value};
        this.inputWrapper['Remarks'] = { value: this.fiRecord.fields.Remarks__c.value ? this.fiRecord.fields.Remarks__c.value : '' };
        this.inputWrapper['noOfAttempts'] = {label: 'No of Attempts', value: this.fiRecord.fields.No_of_Attempts__c.value };
        this.inputWrapper['observation'] = {label: 'FI Observation', value: this.fiRecord.fields.FI_Observation__c.value };
        // Vehicle Details
        this.inputWrapper['make'] = { label: makeTitle, value: '' };
        this.inputWrapper['model'] = { label: modelTitle, value: '' };
        this.inputWrapper['variant'] = { label: variantTitle, value: '' };
        this.inputWrapper['dealer'] = { label: dealerTitle, value: '' };
        this.inputWrapper['purposeOfPurchase'] = {label: 'Purpose of Purchase', value: ''};
        // Case fields
        this.inputWrapper['caseId'] = { value: this.fiRecord.fields.Case__c.value };
        this.inputWrapper['ownerId'] = { value: this.fiRecord.fields.Case__r.value.fields.OwnerId.value };
        this.inputWrapper['fiRequestGenerationDT'] = { label: fiReqGenDT, value: this.fiRecord.fields.Case__r.value.fields.CreatedDate.value };
        this.inputWrapper['Origin'] = { value: this.fiRecord.fields.Case__r.value.fields.Origin.value };
        this.inputWrapper['Type'] = { value: this.fiRecord.fields.Case__r.value.fields.Type.value };
        this.inputWrapper['Subject'] = { value: this.fiRecord.fields.Case__r.value.fields.Subject.value };
        // Applicant fields
        this.inputWrapper['applicantId'] = { value: this.fiRecord.fields.Case__r.value.fields.Applicant__c.value };
        this.inputWrapper['name'] = { label: name, value: this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Name.value };
        // Opportunity fields
        this.inputWrapper['applicationId'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__c.value };
        this.inputWrapper['stage'] = { label: 'Stage', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.StageName.value };
        this.inputWrapper['subStage'] = { label: 'Sub Stage', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Sub_Stage__c.value };
        // Document fields
        this.inputWrapper['signatureView'] = { label: signatureView, value: '' };
        this.inputWrapper['viewResidencefrontview'] = { label: viewResidencefrontview, value: '' };
        //Status field
        if (this.inputWrapper.Type.value === caseCurrentResidnceFIType) {
            this.inputWrapper['Residence_FI_Accepted_Rejected'] = {
                label: currentFIStatus,
               value: (this.fiRecord.fields.Case__r.value.fields.Status.value === accepted) ? this.fiRecord.fields.Case__r.value.fields.Status.value : ''
               //value: this.fiRecord.fields.Case__r.value.fields.Status.value  
            };
            this.inputWrapper['documentAddressType'] = { value: docCurResAdrType };
            this.fiAccordionTitle = currResFITitle;
            this.residenceAddressSectionHeader = resAddrCurrTitle;
        }else if (this.inputWrapper.Type.value === caseCurrentResidnceFIType) {
            this.inputWrapper['Residence_FI_Accepted_Rejected'] = {
                label: currentFIStatus,
               value: (this.fiRecord.fields.Case__r.value.fields.Status.value === rejected) ? this.fiRecord.fields.Case__r.value.fields.Status.value : ''
               //value: this.fiRecord.fields.Case__r.value.fields.Status.value  
            };
            this.inputWrapper['documentAddressType'] = { value: docCurResAdrType };
            this.fiAccordionTitle = currResFITitle;
            this.residenceAddressSectionHeader = resAddrCurrTitle;
        }//rejected
        else if (this.inputWrapper.Type.value === casePermanentResidnceFIType) {
            this.inputWrapper['Residence_FI_Accepted_Rejected'] = {
                label: permanentFIStatus,
                value: (this.fiRecord.fields.Case__r.value.fields.Status.value === accepted) ? this.fiRecord.fields.Case__r.value.fields.Status.value : ''
            };
            this.inputWrapper['documentAddressType'] = { value: docPerResAdrType };
            this.fiAccordionTitle = permResFITitle;
            this.residenceAddressSectionHeader = resAddrPermTitle;
        } else if (this.inputWrapper.Type.value === casePermanentResidnceFIType) {
            this.inputWrapper['Residence_FI_Accepted_Rejected'] = {
                label: permanentFIStatus,
                value: (this.fiRecord.fields.Case__r.value.fields.Status.value === rejected) ? this.fiRecord.fields.Case__r.value.fields.Status.value : ''
            };
            this.inputWrapper['documentAddressType'] = { value: docPerResAdrType };
            this.fiAccordionTitle = permResFITitle;
            this.residenceAddressSectionHeader = resAddrPermTitle;
        }
    }
}