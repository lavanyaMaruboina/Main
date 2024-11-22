import { LightningElement, wire, api, track } from 'lwc';
import saveCurrentResidenceFI from '@salesforce/apex/IND_ResidenceFIController.saveCurrentResidenceFI';
import fetchAddtionalRealtedDetails from '@salesforce/apex/IND_ResidenceFIController.fetchAddtionalRealtedDetails';
import loadResidenceFIData from '@salesforce/apex/IND_ResidenceFIController.loadResidenceFIData';
import createDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.createDocumentRecord';
import checkDocFromApp from '@salesforce/apex/IND_ResidenceFIController.checkDocFromApp';
import getDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.getDocumentRecord';

import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FIELD_INVESTIGATION_OBJECT from '@salesforce/schema/Field_Investigation__c';
import RESI_YEAR_FIELD from '@salesforce/schema/Field_Investigation__c.Years_in_Residence__c';
import RESI_TYPE_FIELD from '@salesforce/schema/Field_Investigation__c.Residence_Type__c';
import CITY_YEAR_FIELD from '@salesforce/schema/Field_Investigation__c.Years_in_CIty__c';
import RELATION from '@salesforce/schema/Field_Investigation__c.Relationship__c';
import OBSERVATION from '@salesforce/schema/Field_Investigation__c.FI_Observation__c';
import GOODS_COUNT from '@salesforce/schema/Field_Investigation__c.No_of_Sofas__c';
import signature from '@salesforce/label/c.Signature';
import residentFrontView from '@salesforce/label/c.Residence_Front_View';
import otherDocument from '@salesforce/label/c.Other_Document_Record_Type';
import kycDocument from '@salesforce/label/c.KYCDocument';
import FORM_FACTOR from '@salesforce/client/formFactor';
import doGeoCoderAPI from '@salesforce/apex/IntegrationEngine.doGeoCoderAPI';//CISP-2701
import checkRetryExhausted from '@salesforce/apex/IND_ResidenceFIController.checkRetryExhausted';//CISP-2701
import retryCountIncrease from '@salesforce/apex/IND_ResidenceFIController.retryCountIncrease';//CISP-2701
import getFieldInvestigation from '@salesforce/apex/IND_ResidenceFIController.getFieldInvestigation';//CISP-2701
import haveCurrentCaseAccess from '@salesforce/apex/IND_ResidenceFIController.haveCurrentCaseAccess';
//Labels for the document upload from integrator app
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import userId from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
//import { refreshApex } from '@salesforce/apex';

// FI Readonly methods and labels
import saveCurrentFI from '@salesforce/apex/IND_ResidenceFIReadOnlyController.saveCurrentFI';
import getDocumentsOfFI from '@salesforce/apex/IND_ResidenceFIReadOnlyController.getDocumentsOfFI';
import updateActualGeoLocationDetails from '@salesforce/apex/IND_ResidenceFIController.updateActualGeoLocationDetails';
import creditProcessing from '@salesforce/label/c.Credit_Processing';
import fieldInvestigation from '@salesforce/label/c.Field_Investigation';
import pendingOfficeFIStatus from '@salesforce/label/c.Pending_Office_FI_Status';
import cordVerGreenColor from '@salesforce/label/c.Coordinates_Verified_Green_Color';
import cordVerAmberColor from '@salesforce/label/c.Coordinates_Verified_Amber_Color';
import cordVerRedColor from '@salesforce/label/c.Coordinates_Verified_Red_Color';
import resAcptRejSelMessage from '@salesforce/label/c.Residence_FI_Accepted_Rejected_Selection_Error_Message';
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

const FI_FIELDS = [
    'Field_Investigation__c.Residence_FI_Status__c',
    'Field_Investigation__c.FI_Status__c',
    'Field_Investigation__c.Residence_FI_completion_time__c',
    'Field_Investigation__c.Address_Line_1__c',
    'Field_Investigation__c.Address_Line_2__c',
    'Field_Investigation__c.City__c',
    'Field_Investigation__c.Pin_Code__c',
    'Field_Investigation__c.State__c',
    'Field_Investigation__c.Landmark__c',
    'Field_Investigation__c.Phone_Number__c',
    'Field_Investigation__c.Mobile__c',
    'Field_Investigation__c.Customer_house_same_as_in_application__c',
    'Field_Investigation__c.GeoCoder_Latitude_and_Longitude__Latitude__s',
    'Field_Investigation__c.GeoCoder_Latitude_and_Longitude__Longitude__s',
    'Field_Investigation__c.FI_Location__Latitude__s',
    'Field_Investigation__c.FI_Location__Longitude__s',
    'Field_Investigation__c.Coordinates_Verified__c',
    'Field_Investigation__c.Are_Co_ordinates_Matching_If_Amber__c',
    'Field_Investigation__c.Years_in_Residence__c',
    'Field_Investigation__c.Product__c',
    'Field_Investigation__c.Residence_Type__c',
    'Field_Investigation__c.Purpose_of_Purchase__c',
    'Field_Investigation__c.Profile_to_Product_Match__c',
    'Field_Investigation__c.Number_of_Dependent__c',
    'Field_Investigation__c.Number_of_Earning_Member_in_Family__c',
    'Field_Investigation__c.Name_of_Person_met__c',
    'Field_Investigation__c.Relationship__c',
    'Field_Investigation__c.No_of_Attempts__c',
    'Field_Investigation__c.FI_Observation__c',
    'Field_Investigation__c.FI_Feedback__c',
    'Field_Investigation__c.No_of_TVs__c',
    'Field_Investigation__c.No_of_Fridges__c',
    'Field_Investigation__c.No_of_Washing_Machines__c',
    'Field_Investigation__c.No_of_Sofas__c',
    'Field_Investigation__c.No_of_ACs__c',
    'Field_Investigation__c.No_of_Computers__c',
    'Field_Investigation__c.No_of_2_Wheelers__c',
    'Field_Investigation__c.No_of_3_Wheelers__c',
    'Field_Investigation__c.No_of_4_Wheelers__c',
    'Field_Investigation__c.No_of_CVs__c',
    'Field_Investigation__c.Remarks__c',
    'Field_Investigation__c.Case__c',
    'Field_Investigation__c.Case__r.OwnerId',
    'Field_Investigation__c.Case__r.Origin',
    'Field_Investigation__c.Case__r.Type',
    'Field_Investigation__c.Case__r.Status',
    'Field_Investigation__c.Case__r.CreatedDate',
    'Field_Investigation__c.Case__r.Applicant__c',
    'Field_Investigation__c.Case__r.Applicant__r.Name',
    'Field_Investigation__c.Case__r.Applicant__r.Contact_number__c',
    'Field_Investigation__c.Case__r.Applicant__r.Whatsapp_number__c',
    'Field_Investigation__c.Case__r.Loan_Application__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Name',
    'Field_Investigation__c.Case__r.Loan_Application__r.Make__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Model__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Variant__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.StageName',
    'Field_Investigation__c.Case__r.Loan_Application__r.Sub_Stage__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Product_Type__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Is_Mobile_Journey_Completed__c'];

export default class IND_LWC_CurrentResidenceFI extends NavigationMixin(LightningElement) {
    sendingRecordTypeName = ''; //CISP-2975
    label = {
        signature,
        currentUserId,
        currentUserName,
        currentUserEmailid,
        mode,
        residentFrontView,
        currentApplicantid,
        otherDocument,
        kycDocument
    };

    @track wireRunsOnlyOnce = false;//CISP-2571
    currentUserId = userId;
    activeSections = ['ResidenceAddress', 'OtherFields', 'PersonalInformation', 'IdentityProof', 'ResidenceAddressPermanent', 'LoanDetails', 'FamilyDetails', 'OtherObservations', 'FIFeedback'];
    activeFISections = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
    @api recordId;
    @track inputWrapper = {};
    @track applicationId;
    @track applicantId;
    @track documentAddressType;
    @track signatureUpload = false;
    @track residenceUpload = false;
    showUpload = false;
    showDocView = false;
    isVehicleDoc = false;
    isAllDocType = false;
    uploadViewDocFlag = false;
    @track pendingFI = false;
    @track disableButtonsAndFields = false;
    @track documentId;
    @track documentType;
    //@api userDetails;
    @track fileDocumentLists = [];
    @track showSignatureModal = false;
    @track showCaptureFrontViewComponent = false;
    @track signatureDocumentId;
    @track frontCaptureDocumentId;
    @track haveCaseAccess = true;
    @track fiType = 'Current Residence'; //This should be dynamic
    @track residenceAddressSectionHeader = 'Residence Address'; //This will be dynamically render based on the type of Residence FI.
    @track isSpinnerMoving = false;
    @track fiAccordionTitle;
    get fiStatusOptions() {
        return [
            { label: accepted, value: accepted },
            { label: rejected, value: rejected }
        ];
    }

    /*
    @track yesNoOptions;
    @track permSameAsCurrent;
    @track documents;
    */
    @wire(getObjectInfo, { objectApiName: FIELD_INVESTIGATION_OBJECT })
    fiMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: RESI_YEAR_FIELD
    })
    resiYearPicklist;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: RESI_TYPE_FIELD
    })
    resiTypePicklist;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: GOODS_COUNT
    })
    goodsCountPicklist;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: CITY_YEAR_FIELD
    })
    cityYearPicklist;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: RELATION
    })
    relationPicklist;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: OBSERVATION
    })
    observationPicklist;

    fiRecord;
    @wire(getRecord, { recordId: '$recordId', fields: FI_FIELDS })
    async wiredFIRecord({ error, data }) {//CISP-2701
        if (data && !this.wireRunsOnlyOnce) {//CISP-2571
            this.wireRunsOnlyOnce = true;//CISP-2571
            console.log('getRecord FI_FIELDS ', data);
            this.fiRecord = data;
            // Prepare Input Wrapper
            this.inputWrapperPopulator();
            //console.log('before inputWrapper..', JSON.stringify(this.inputWrapper));
            // Updating other fields
            this.applicationId = this.inputWrapper.applicationId.value;
            this.applicantId = this.inputWrapper.applicantId.value;
            this.documentAddressType = this.inputWrapper.documentAddressType.value;
            console.log('this.inputWrapper.documentAddressType.value::', this.inputWrapper.documentAddressType.value);
            console.log('documentAddressType==>', this.documentAddressType);
            console.log('this.inputWrapper.residenceFIStatus.value::', this.inputWrapper.residenceFIStatus.value);

            if (this.inputWrapper.Residence_FI_Accepted_Rejected.value === accepted) {
                this.disableButtonsAndFields = true;
            }
            await this.init();//CISP-2701

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
    //CISP-2701-START
    async init() {
        await checkRetryExhausted({'loanApplicationId':this.applicationId, 'fieldInvestigation': this.recordId}).then(result=>{//CISP-3069
            this.disabledCapturedBtn = result;
        });
        await getFieldInvestigation({fieldInvestigationId:this.recordId}).then(result=>{
            console.log('result ', result);
            if(result){
                this.coordinatesDistance = result.Coordinates_Distance__c ? result.Coordinates_Distance__c: null;
            }
        });
        if(this.applicationId && this.fiRecord.fields.Case__c.value){
            await haveCurrentCaseAccess({loanId: this.applicationId, caseId : this.fiRecord.fields.Case__c.value}).then(result=>{
                console.log('result ', result);
                this.haveCaseAccess = result;
                if(!this.haveCaseAccess){
                    this.handleDisableScreen();
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'This Case is owned by another user. It is available in Read only mode. You will not able to edit it.',
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                }
            }).catch(error=>{
                console.log(error);
            });
        }
    }
    // CISP-2701-END
    renderedCallback() {
        if (!this.haveCaseAccess || (this.inputWrapper.residenceFIStatus && this.inputWrapper.residenceFIStatus.value && this.inputWrapper.residenceFIStatus.value === 'Complete')) {
            this.handleDisableScreen();
        }
        if(this.disabledCapturedBtn){this.template.querySelector('.fiLatitudeAndLogitude').disabled = true;}//CISP-3069
    }
    @wire(getDocumentsOfFI, { applicationId: '$applicationId', applicantId: '$applicantId', documentAddressType: '$documentAddressType' })
    wiredFilesResult({ data, error }) {
        if (data) {
            console.log('residence files data..', JSON.stringify(data));
            if (data.signatureView) {
                this.inputWrapper['signatureView'].value = data.signatureView;
            }
            if (data.viewResidencefrontview) {
                this.inputWrapper['viewResidencefrontview'].value = data.viewResidencefrontview;
            }
        }
        else if (error) {
            console.log('error 1 ', error);
            if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    @wire(loadResidenceFIData, { applicantId: '$applicantId', addrType:'$documentAddressType' })
    wiredDocsResult({ data, error }) {
        if (data) {
            this.fileDocumentLists = [...data];
            console.log('fileDocumentLists: ', this.fileDocumentLists);
        } else if (error) {
            if (error.body.message) {
                console.log('error 1 ', error);
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }


    currentUserName;
    currentUserEmailId;

    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })
    userDetails({ error, data }) {
        if (data) {

            console.log('data ', data);
            this.currentUserName = data.fields.Name.value;
            this.currentUserEmailId = data.fields.Email.value;
            console.log(' this.currentUserName ', this.currentUserName, '  this.currentUserEmailId ', this.currentUserEmailId);
        } else if (error) {
            console.log('userDetails error ', error)
            this.showToast('Error!', '', 'error', 'sticky');
        }
    }

    @wire(fetchAddtionalRealtedDetails, { applicationId: '$applicationId' })
    vehicleDetails({ error, data }) {
        if (data) {
            this.inputWrapper['make'].value = data.Make__c;
            this.inputWrapper['model'].value = data.Model__c;
            this.inputWrapper['variant'].value = data.Variant__c;
            this.inputWrapper['dealer'].value = data.Dealer_Sub_dealer_name__c;
        } else if (error) {
            console.log('error 1 ', error);
            if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }
    //CISP-2701-START
    watchId;
    async fiLatitudeLongitude(event){
        try {
            this.isSpinnerMoving = true;
            console.log('navigator.geolocation ', navigator.geolocation);
            var thisins = this;
            this.watchId = await navigator.geolocation.watchPosition(
                function (position) { 
                    console.log("i'm tracking you! ", position?.coords?.latitude); 
                    console.log("i'm tracking you! ", position?.coords?.longitude);  
                    navigator.geolocation.clearWatch(thisins.watchId);
                    
                    navigator.geolocation.getCurrentPosition(position => {
                        var latitude = position.coords.latitude;//CISP-3099
                        var longitude = position.coords.longitude;//CISP-3099
                        console.log('Test '+longitude+ latitude);
          
                        updateActualGeoLocationDetails({ fiId: thisins.recordId, lattitude: latitude, longitude: longitude })
                        .then(() => {
                            thisins.callGeoApi();
                        })
                        .catch((error) => {
                            thisins.isSpinnerMoving = false;
                            console.log('error updateActualGeoLocationDetails ',error);
                            thisins.showToast('Error', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                            
                        });
                    }); 
                },
                function (error) {
                    if (error.code == error.PERMISSION_DENIED){
                        thisins.isSpinnerMoving = false;
                        thisins.showToast('Error', 'Plese provide the location access to the browser.', 'error', 'sticky');
                        console.log("you denied me :-(");
                        return;
                    }
              });
              console.log('this.watchId ', this.watchId);
            
                setTimeout(() => {
                    this.isSpinnerMoving = false;
                    navigator.geolocation.clearWatch(thisins.watchId);
                }, 1000);

        } catch (error) {
            this.isSpinnerMoving = false;
            this.showToast('Error', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
            console.log('fiLatitudeLongitude ' , error);
            console.log('fiLatitudeLongitude ' , event);
        }
    }
    async callGeoApi(){
        await retryCountIncrease({'loanApplicationId':this.applicationId, 'fieldInvestigation': this.recordId}).then(result=>{//CISP-3069
            this.disabledCapturedBtn = result;
        });
        if(this.disabledCapturedBtn){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Retry Exhausted',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.isSpinnerMoving = false;
            return;
        }else{
            this.showToast('Success', 'Actual Geo code details updated Succesfully', 'success', 'sticky');
            await doGeoCoderAPI({ 'fiId': this.recordId, 'loanApplicationId': this.applicationId })
                .then(result => {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'KYC Geo Code Details updated successfully!',
                        variant: 'success',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                })
                .catch(error => {
                    this.isSpinnerMoving = false;
                    console.log('error doGeoCoderAPI ',error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong, please contact your admin!',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                });
                await getFieldInvestigation({'fieldInvestigationId':this.recordId}).then(result=>{
                    this.isSpinnerMoving = false;
                    console.log('result ', result);
                    if(result){
                        this.coordinatesDistance = result.Coordinates_Distance__c;//CISP-3155
                    }
                }).catch(error=>{
                    this.isSpinnerMoving = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong, please contact your admin!',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                })
        }
    }
    disabledCapturedBtn = false;
    @track coordinatesDistance;//CISP-3155
    //CISP-2701-END
    async saveResidenceFI() {
        this.isSpinnerMoving = true;
        let isValid = true;
        
        let feedback = this.template.querySelector('.fiFeedback');
        if (!feedback.checkValidity()) {
            feedback.reportValidity();
            this.isSpinnerMoving = false;
            isValid = false;
            this.showToast('Error!', 'Please enter letter only in fi feedback', 'error', 'sticky');
        }

        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                this.isSpinnerMoving = false;
                isValid = false;
                this.showToast('Error!', 'Please complete all the required fields', 'error', 'sticky');
            } else {
                this.isSpinnerMoving = false;
                if (inputField.value === '< 1 yr') {
                    let yearInput = this.template.querySelector('.noOfYearsinCity');
                    if (!yearInput.checkValidity()) {
                        yearInput.reportValidity();
                        isValid = false;
                        this.showToast('Error!', 'Please fill No of Years in City details.', 'error', 'sticky');
                    }
                }
            }
        });

        if (!this.signatureUpload) {
           await getDocumentRecord({ caseId: this.recordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: this.label.signature, recordTypeName: this.label.otherDocument })
                .then(response => {
                    this.isSpinnerMoving = false;
                    console.log('line 346', response);
                    if (response) {
                        this.signatureUpload = true;
                    } else {
                        this.showToast('Error!', 'Please Upload Signature.', 'error', 'sticky');

                    }
                    console.log('signatureUpload ', this.signatureUpload);
                })
                .catch(error => {
                    this.isSpinnerMoving = false;
                    console.log('error 356', error);
                    if (error.body.message) {
                        this.showToast('Error!', error.body.message, 'error', 'sticky');
                    } else {
                        this.showToast('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'sticky');
                    }
                });
        }
        
        if (!this.residenceUpload) {
           await getDocumentRecord({ caseId: this.recordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: this.label.residentFrontView, recordTypeName: this.label.otherDocument })
                .then(response => {
                    this.isSpinnerMoving = false;
                    console.log('line 364', response);

                    if (response) {
                        this.residenceUpload = true;
                    }
                    else {
                        this.showToast('Error!', 'Please Upload Residence Front View.', 'error', 'sticky');
                    }
                    console.log('residenceUpload ', this.residenceUpload);

                })
                .catch(error => {
                    this.isSpinnerMoving = false;
                    console.log('error 356', error);

                    if (error.body.message) {
                        this.showToast('Error!', error.body.message, 'error', 'sticky');
                    } else {
                        this.showToast('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'sticky');
                    }
                });

        }

        //CISP-2701-START
        // if(this.coordinatesDistance > 300 && !this.disabledCapturedBtn){
            //     const evt = new ShowToastEvent({
                //         title: '',
                //         message: `Distance ${this.coordinatesDistance} between the Address as per application and Current FI location is not within the range. Please recapture.`,
                //         variant: 'error',
                //         mode: 'sticky'
            //     });
            //     this.dispatchEvent(evt);
            //     return;
        // }
        console.log('coordinatesDistance ', this.coordinatesDistance);
        if (isValid && this.residenceUpload && this.signatureUpload && (this.coordinatesDistance || this.coordinatesDistance == 0 || this.disabledCapturedBtn)) {//CISP-2701-END
            //console.log(JSON.stringify(this.inputWrapper));
            await saveCurrentResidenceFI({
                inputWrapper: JSON.stringify(this.inputWrapper)
            })
                .then(result => {
                    this.isSpinnerMoving = false;
                    if (result) {
                        this.showToast('Success!', 'FI Updated Successfully', 'success', 'dismissable');
                        this.handleDisableScreen();
                    } else {
                        this.showToast('Error!', 'FI Update Failed', 'error', 'sticky');
                    }
                })
                .catch(error => {
                    this.isSpinnerMoving = false;
                    console.log('error 1 ', error);
                    if (error.body.message) {
                        this.showToast('Error!', error.body.message, 'error', 'sticky');
                    } else {
                        this.showToast('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'sticky');
                    }
                });
        }else if(!this.coordinatesDistance && isValid && this.residenceUpload && this.signatureUpload){
            this.showToast('Please Capture FI Latitude & Longitude first.', '', 'error', 'dismissable');
            return;
        }
    }
    handleInputChange(event) {
        this.inputWrapper[event.target.name].value = event.target.value;
    }
    handleInputFIChange(event) {
        let feedback = this.template.querySelector('.fiFeedback');
        if (feedback) {
            if (/^[a-z A-Z]*$/.test(event.target.value)) {//CISP-2698 space added
                feedback.setCustomValidity('');
                this.inputWrapper[event.target.name].value = event.target.value;
            } else {
                feedback.setCustomValidity('Please enter letter only');
            }
            feedback.reportValidity();
        }

    }

    handleCheckboxChange(event) {
        this.inputWrapper[event.target.name].value = event.target.checked;
    }

    handleKycCheckBoxChange(event) {
        const dataId = event.target.dataset.id;
        if (event.target.checked) {
            this.template.querySelector('button[data-id="' + dataId + '"]').disabled = false;
        } else {
            this.template.querySelector('button[data-id="' + dataId + '"]').disabled = true;
        }
    }

    handleKycButtonClick(event) {
        console.log('integrator details appid2: ', this.applicantId, ' usrid ' + this.currentUserId + ' usname ' + this.currentUserName + ' usemail ' + this.currentUserEmailId);

        this.documentType = event.target.name;
        console.log('event.target.name ', event.target.name, ' ', this.label.kycDocument);
        this.createDocument(event.target.name, this.label.kycDocument);

    }

    handleFIInputChange(event) {
        this.inputWrapper[event.target.fieldName.slice(0, -3)].value = event.target.value;
    }

    handleFIStatusChange(event) {
        this.inputWrapper['Residence_FI_Accepted_Rejected'].value = event.target.value;
    }

    saveCurrentFI() {
        if (this.inputWrapper.Residence_FI_Accepted_Rejected.value) {
            this.disableButtonsAndFields = true;
            saveCurrentFI({
                inputWrapper: JSON.stringify(this.inputWrapper)
            })
                .then(result => {
                    if (result) {
                        this.showToast('Success!', acceptedSuccessfully, 'success', 'dismissable');
                    } else {
                        this.showToast('Success!', rejectedSuccessfully, 'success', 'dismissable');
                    }
                    const nextStage = new CustomEvent('submit');
                    this.dispatchEvent(nextStage);
                })
                .catch(error => {
                    if (error.body.message) {
                        this.showToast('Error!', error.body.message, 'error', 'sticky');
                    } else {
                        this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
                    }
                });
        }
        else {
            this.showToast('Error!', resAcptRejSelMessage, 'error', 'sticky');
        }
    }

    previewImage(event) {
        console.log('event.target.dataset.id', event.target.dataset.id);
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

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    handleDisableScreen() {
        const allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => {
            element.disabled = true;
        });
    }

    inputWrapperPopulator() {
        console.log('this.fiRecord.fields  => ', this.fiRecord.fields);
        // Color variant based on Coordinates_Verified__c value
        let coordinatesVerifiedVariant = '';
        if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerGreenColor) {
            coordinatesVerifiedVariant = 'base-autocomplete';
        } else if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerAmberColor) {
            coordinatesVerifiedVariant = 'warning';
        } else if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerRedColor) {
            coordinatesVerifiedVariant = 'expired';
        }

        // UI fields
        this.inputWrapper['fiRequestGenerationDT'] = { label: 'FI Request Generation date and time', value: this.fiRecord.fields.Case__r.value.fields.CreatedDate.value };
        this.inputWrapper['residenceFIStatus'] = { label: 'Residence FI Status', value: this.fiRecord.fields.FI_Status__c.value };
        this.inputWrapper['residenceFICompletionTime'] = { label: 'Residence FI completion time', value: this.fiRecord.fields.Residence_FI_completion_time__c.value };
        this.inputWrapper['addrLine1'] = { label: 'Adress line 1', value: this.fiRecord.fields.Address_Line_1__c.value };
        this.inputWrapper['addrLine2'] = { label: 'Adress line 2', value: this.fiRecord.fields.Address_Line_2__c.value };
        this.inputWrapper['city'] = { label: 'City', value: this.fiRecord.fields.City__c.value };
        this.inputWrapper['pinCode'] = { label: 'Pin Code', value: this.fiRecord.fields.Pin_Code__c.value };
        this.inputWrapper['state'] = { label: 'State', value: this.fiRecord.fields.State__c.value };
        this.inputWrapper['landmark'] = { label: 'Landmark', value: this.fiRecord.fields.Landmark__c.value };
        if (this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Contact_number__c.value) {
            this.inputWrapper['phoneNo'] = { label: 'Phone no', value: this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Contact_number__c.value };
        } else {
            this.inputWrapper['phoneNo'] = { label: 'Phone no', value: null };
        }
        if (this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Whatsapp_number__c.value) {
            this.inputWrapper['mobile'] = { label: 'Mobile', value: this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Whatsapp_number__c.value };
        } else {
            this.inputWrapper['mobile'] = { label: 'Mobile', value: null };
        }
        this.inputWrapper['locationSameAsInApplication'] = { label: 'Whether customer house located in the same address as in the application', value: this.fiRecord.fields.Customer_house_same_as_in_application__c.value };
        this.inputWrapper['geocoderLatitudeAndLongitude'] = { label: 'Geocoder Latitude and Longitude', value: (this.fiRecord.fields.GeoCoder_Latitude_and_Longitude__Latitude__s.value + ', ' + this.fiRecord.fields.GeoCoder_Latitude_and_Longitude__Longitude__s.value) };
        this.inputWrapper['fiLatitudeAndLongitude'] = { label: 'FI Latitude and Longitude', value: (this.fiRecord.fields.FI_Location__Latitude__s.value + ', ' + this.fiRecord.fields.FI_Location__Longitude__s.value) };
        this.inputWrapper['coordinatesVerfied'] = { label: 'Coordinates Verfied', value: coordinatesVerifiedVariant };
        this.inputWrapper['areCoordinatesMatching'] = { label: 'Are Co-ordinates matching (if Amber)', value: this.fiRecord.fields.Are_Co_ordinates_Matching_If_Amber__c.value };
        this.inputWrapper['yearsInResidence'] = { label: 'Years in Residence', value: this.fiRecord.fields.Years_in_Residence__c.value };
        this.inputWrapper['name'] = { label: 'Name', value: this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Name.value };
        this.inputWrapper['product'] = { label: 'Product', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Product_Type__c.value };
        this.inputWrapper['resiType'] = { label: 'Residence Type', value: this.fiRecord.fields.Residence_Type__c.value };
        this.inputWrapper['permCurrAddress'] = { label: 'Permanent Address is same as Current Address?', value: '' };
        this.inputWrapper['purposeOfPurchase'] = { label: 'Purpose Of Purchase', value: this.fiRecord.fields.Purpose_of_Purchase__c.value };
        this.inputWrapper['make'] = { label: 'Make', value: '' };
        this.inputWrapper['model'] = { label: 'Model', value: '' };
        this.inputWrapper['variant'] = { label: 'Variant', value: '' };
        this.inputWrapper['profileProductMatch'] = { label: 'Profile to Product Match', value: this.fiRecord.fields.Profile_to_Product_Match__c.value };
        this.inputWrapper['dealer'] = { label: 'Dealer', value: '' };
        this.inputWrapper['noofDependents'] = { label: 'No of Dependents', value: this.fiRecord.fields.Number_of_Dependent__c.value };
        this.inputWrapper['numberOfEarningMembersInTheFamily'] = { label: 'Number of earning members in the family', value: this.fiRecord.fields.Number_of_Earning_Member_in_Family__c.value };
        this.inputWrapper['nameOfPersonMet'] = { label: 'Name of Person met', value: this.fiRecord.fields.Name_of_Person_met__c.value };
        this.inputWrapper['relationShipWithCustomer'] = { label: 'Relationship with customer', value: this.fiRecord.fields.Relationship__c.value };
        this.inputWrapper['noOfYearsinCity'] = { label: 'No of Years in City', value: '' };
        this.inputWrapper['noofAttempts'] = { label: 'No of Attempts', value: this.fiRecord.fields.No_of_Attempts__c.value };
        this.inputWrapper['fiObservation'] = { label: 'FI Observation', value: this.fiRecord.fields.FI_Observation__c.value };
        this.inputWrapper['fiFeedback'] = { label: 'FI Feedback', value: this.fiRecord.fields.FI_Feedback__c.value };
        this.inputWrapper['noOfTVs'] = { label: 'TV', value: this.fiRecord.fields.No_of_TVs__c.value };
        this.inputWrapper['noOfFridgess'] = { label: 'Fridge', value: this.fiRecord.fields.No_of_Fridges__c.value };
        this.inputWrapper['noofWashingMachines'] = { label: 'Washing Machine', value: this.fiRecord.fields.No_of_Washing_Machines__c.value };
        this.inputWrapper['noOfSofas'] = { label: 'Sofa', value: this.fiRecord.fields.No_of_Sofas__c.value };
        this.inputWrapper['noOfACs'] = { label: 'AC', value: this.fiRecord.fields.No_of_ACs__c.value };
        this.inputWrapper['noOfComputers'] = { label: 'Computer', value: this.fiRecord.fields.No_of_Computers__c.value };
        this.inputWrapper['noOf2Wheelers'] = { label: '2 Wheeler', value: this.fiRecord.fields.No_of_2_Wheelers__c.value };
        this.inputWrapper['noOf3Wheelers'] = { label: '3 Wheeler', value: this.fiRecord.fields.No_of_3_Wheelers__c.value };
        this.inputWrapper['noOf4Wheelers'] = { label: '4 Wheeler', value: this.fiRecord.fields.No_of_4_Wheelers__c.value };
        this.inputWrapper['noOfCVs'] = { label: 'CV', value: this.fiRecord.fields.No_of_CVs__c.value };
        // Apex fields
        this.inputWrapper['fiId'] = { label: 'Field Investigation ID', value: this.recordId };
        this.inputWrapper['caseId'] = { label: 'Case ID', value: this.fiRecord.fields.Case__c.value };
        console.log(' this.inputWrapper[caseId]',  this.inputWrapper['caseId'].value);
        this.inputWrapper['ownerId'] = { label: 'Owner ID', value: this.fiRecord.fields.Case__r.value.fields.OwnerId.value };
        this.inputWrapper['applicantId'] = { label: 'Applicant ID', value: this.fiRecord.fields.Case__r.value.fields.Applicant__c.value };
        this.inputWrapper['applicationId'] = { label: 'Loan Application ID', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__c.value };
        this.inputWrapper['stage'] = { label: 'Stage', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.StageName.value };
        this.inputWrapper['subStage'] = { label: 'Sub Stage', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Sub_Stage__c.value };
        this.inputWrapper['Origin'] = { value: this.fiRecord.fields.Case__r.value.fields.Origin.value };
        this.inputWrapper['Type'] = { value: this.fiRecord.fields.Case__r.value.fields.Type.value };
        // Document fields
        this.inputWrapper['signatureView'] = { label: 'Signature View', value: '' };
        this.inputWrapper['viewResidencefrontview'] = { label: 'View Residence front view', value: '' };
        // FI Input change fields
        this.inputWrapper['Are_Co_ordinates_Matching_If_Amber'] = { value: this.fiRecord.fields.Are_Co_ordinates_Matching_If_Amber__c.value };
        this.inputWrapper['Remarks'] = { value: this.fiRecord.fields.Remarks__c.value };
        //Status field
        if (this.inputWrapper.Type.value === caseCurrentResidnceFIType) {
            this.inputWrapper['Residence_FI_Accepted_Rejected'] = {
                label: currentFIStatus,
                value: (this.fiRecord.fields.Case__r.value.fields.Status.value === accepted) ? this.fiRecord.fields.Case__r.value.fields.Status.value : ''
            };
            this.inputWrapper['documentAddressType'] = { value: docCurResAdrType };
            this.fiAccordionTitle = 'CURRENT RESIDENCE FI';
        }
        else if (this.inputWrapper.Type.value === casePermanentResidnceFIType) {
            this.inputWrapper['Residence_FI_Accepted_Rejected'] = {
                label: permanentFIStatus,
                value: (this.fiRecord.fields.Case__r.value.fields.Status.value === accepted) ? this.fiRecord.fields.Case__r.value.fields.Status.value : ''
            };
            this.inputWrapper['documentAddressType'] = { value: docPerResAdrType };
            this.fiAccordionTitle = 'PERMANENT RESIDENCE FI';
        }
    }

    handleSignatureUpload() {
        createDocumentRecord({ caseId: this.recordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: this.label.signature, recordTypeName: this.label.otherDocument })
            .then((response) => {
                this.signatureDocumentId = response;
                this.showSignatureModal = true;
                const scrollOptions = {
                    left: 0,
                    top: 0,
                    behavior: 'smooth'
                }
                window.scrollTo(scrollOptions);
            })
            .catch((error) => {
                if (error.body.message) {
                    this.showToast('Error!', error.body.message, 'error', 'sticky');
                } else {
                    this.showToast('Error!', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                }
            });

    }

    handleCloseSignatureModal() {
        this.showSignatureModal = false;
    }

    handleSignatureSave() {
        this.template.querySelector('c-capture-signature').handleSaveClick();
        this.signatureUpload = true;
    }

    handleSignatureClear() {
        this.template.querySelector('c-capture-signature').handleClearClick();
    }

    handleCaptureFrontViewUplaod() {

        console.log('integrator details appid1: ', this.applicantId, ' usrid ' + this.currentUserId + ' usname ' + this.currentUserName + ' usemail ' + this.currentUserEmailId);
        if (FORM_FACTOR === 'Large') {
            this.documentType = this.label.residentFrontView;
            this.createDocument(this.label.residentFrontView, this.label.otherDocument);
        } else {
            console.log(' this.inputWrapper[caseId]',  this.inputWrapper['caseId'].value);

            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.label.residentFrontView + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId +  '&documentSide=Front' + '&caseID' + '=' + this.inputWrapper['caseId'].value 
                }
            });
        }
    }

    closeCaptureFrontViewUplaod() {
        this.showCaptureFrontViewComponent = false;
       // refreshApex(this.fileDocumentLists);
    }

    docDeleted() { this.documentId = null; }

    openUploadComp(recordType) {//CISP-2975
        console.log('gee');
        this.showUpload = true;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.sendingRecordTypeName = recordType;//CISP-2975
        this.uploadViewDocFlag = true;
    }

    async createDocument(docType, recordType) {
        await createDocumentRecord({ caseId: this.recordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: docType, recordTypeName: recordType })
            .then((response) => {
                console.log('response ', response);
                this.documentId = response;
                //this.showCaptureFrontViewComponent = true;     
            })
            .catch((error) => {
                if (error.body.message) {
                    this.showToast('Error!', error.body.message, 'error', 'sticky');
                } else {
                    this.showToast('Error!', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                }
            });

        this.openUploadComp(recordType);//CISP-2975
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

        if (event.detail &&  event.detail.contentDocumentId != null && event.detail.backcontentDocumentId != null) {
            const evt = new ShowToastEvent({
                title: "All uploaded!",
                variant: 'success',
            });
            this.dispatchEvent(evt);

        }
    }
}