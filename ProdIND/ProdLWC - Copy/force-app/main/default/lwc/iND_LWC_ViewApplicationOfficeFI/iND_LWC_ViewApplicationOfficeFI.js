import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveOfficeFI from '@salesforce/apex/IND_OfficeFIReadOnlyController.saveOfficeFI';
import getDocumentsOfFI from '@salesforce/apex/IND_OfficeFIReadOnlyController.getDocumentsOfFI';
import getIncomeSourceRecord from '@salesforce/apex/OfficeFiClass.getIncomeSourceRecord';

// Custom labels
import creditProcessing from '@salesforce/label/c.Credit_Processing';
import fieldInvestigation from '@salesforce/label/c.Field_Investigation';
import pendingOfficeFIStatus from '@salesforce/label/c.Pending_Office_FI_Status';
import cordVerGreenColor from '@salesforce/label/c.Coordinates_Verified_Green_Color';
import cordVerAmberColor from '@salesforce/label/c.Coordinates_Verified_Amber_Color';
import cordVerRedColor from '@salesforce/label/c.Coordinates_Verified_Red_Color';
import variation from '@salesforce/label/c.OfficeFI_Final_Income_Variation';
import variationTitle from '@salesforce/label/c.OfficeFI_Final_Income_Variation_Title';
import variationMessage from '@salesforce/label/c.OfficeFI_Final_Income_Variation_Message';
import ofcAcptRejSelMessage from '@salesforce/label/c.Office_FI_Accepted_Rejected_Selection_Error_Message';
import remarksMessage from '@salesforce/label/c.FI_Remarks_Error_Message';
import serverDownErrMessage from '@salesforce/label/c.Server_down_error_message';
import acceptedSuccessfully from '@salesforce/label/c.Accepted_Successfully';
import rejectedSuccessfully from '@salesforce/label/c.Rejected_Successfully';
import buildingfrontview from '@salesforce/label/c.buildingfrontview';
import signatureView from '@salesforce/label/c.signatureView';
import caseOfficeFIType from '@salesforce/label/c.Case_Office_FI_Type';
import officeFIStatus from '@salesforce/label/c.Office_FI_Status';
import accepted from '@salesforce/label/c.FI_Accepted';
import rejected from '@salesforce/label/c.FI_Rejected';
import offcResFITitle from '@salesforce/label/c.OFFICE_RESIDENCE_FI_TITLE';
import coordinatesVerfied from '@salesforce/label/c.coordinatesVerfied';
import name from '@salesforce/label/c.Name';
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
    'Field_Investigation__c.Employer_Business_Name__c',
    'Field_Investigation__c.Current_experience_years__c',
    'Field_Investigation__c.Total_Experience_Years__c',
    'Field_Investigation__c.Income__c',
    'Field_Investigation__c.Estimated_Service_Income_as_per_FI__c',
    'Field_Investigation__c.SENP_Agriculture_Income__c',
    'Field_Investigation__c.SENP_Own_Shop_Income__c',
    'Field_Investigation__c.SENP_Service_oriented_Income__c',
    'Field_Investigation__c.SENP_Transporter_Income__c',
    'Field_Investigation__c.SENP_Contractor_Income__c',
    'Field_Investigation__c.SENP_Rental_Income__c',
    'Field_Investigation__c.SENP_Pension_Income__c',
    'Field_Investigation__c.Declared_Income_During_Application__c',
    'Field_Investigation__c.Case__c',
    'Field_Investigation__c.Case__r.OwnerId',
    'Field_Investigation__c.Case__r.Origin',
    'Field_Investigation__c.Case__r.Type',
    'Field_Investigation__c.Case__r.Status',
    'Field_Investigation__c.Case__r.Subject',
    'Field_Investigation__c.Case__r.CreatedDate',
    'Field_Investigation__c.Case__r.Applicant__c',
    'Field_Investigation__c.Case__r.Applicant__r.Name',
    'Field_Investigation__c.Case__r.Loan_Application__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.StageName',
    'Field_Investigation__c.Case__r.Loan_Application__r.Sub_Stage__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Product_Type__c',

];

export default class IND_LWC_ViewApplicationOfficeFI extends NavigationMixin(LightningElement) {
    iscommunityuser;isPreview = false;converId;height = 32;//CISP-7179 
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
    @track pendingFI = false;
    @track disableButtonsAndFields = false;
    @track showVariationPopup = false;
    @track variationTitle;
    @track variationMessage;
    @track fiAccordionTitle;
    @track inputWrapper = {};
    @track activeSections = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'];
    @track kycLocation;
    @track fiLocation;

    @track isPrimaryIncomeSourceTrue = false;
    @track isSalaried = false;
    @track isSelfEmployed = false;
    @track profileName = '';
    @track profileAgriculture = false;
    @track profileShop = false;
    @track profileService = false;
    @track profileTransporter = false;
    @track profileContracter = false;
    @track profileRental = false;
    @track profilePension = false;
    @track Sep_IPNIP = false;
    @track Senp_IPNIP = false;
    @track isrequired = true;
    @track coordinatesMatchDisable = false; //CISP-3135
    @track isTractor = false;
    @track callingFromFIScreen = true;
    @track currentCaseId;

    connectedCallback() {
        console.log("inside connected callback method");
        if(this.kycLocation == '' || this.fiLocation == ''){
            console.log("inside connected callback if condition");
                 this.inputWrapper['coordinatesVerfied'] = cordVerRedColor;
          }
    }

    setProfile(incomeDetails) {
        //console.log('incomeDetails::',incomeDetails);
        try{
        console.log('isPrimaryIncomeSourceTrue ', this.isPrimaryIncomeSourceTrue, ' hete 0 isSelfEmployed ', this.isSelfEmployed, ' incomeDetails.Profile__r.Sub_Bucket_Desc__c ', incomeDetails.Profile__r.Sub_Bucket_Desc__c, ' incomeDetails.Profile__r.Category__c ', incomeDetails.Profile__r.Category__c);
        if (incomeDetails.Profile__r.Category__c == 'SENP') {
            switch (incomeDetails.Profile__r.Sub_Bucket_Desc__c) {
                case 'OWN SHOP / STORE':
                    this.profileShop = true;
                    break;
                case 'SERVICE ORIENTED':
                    this.profileService = true;
                    break;
                case 'AGRICULTURE':
                    this.profileAgriculture = true;
                    console.log('profileAgriculture', this.profileAgriculture);
                    this.isrequired = false;
                    break;
                case 'CONTRACTOR':
                    this.profileContracter = true;
                    break;
                case 'RENTAL INCOME':
                    this.profileRental = true;
                    break;
                case 'TRANSPORTER':
                    this.profileTransporter = true;
                    break;
                default:
                    this.Senp_IPNIP = true;
            }

        }
        else if (incomeDetails.Profile__r.Category__c == 'SEP') {
            this.Sep_IPNIP = true;
        }
        }catch(error){
            console.log(error);
        }

    }


    get fiStatusOptions() {
        return [
            { label: accepted, value: accepted },
            { label: rejected, value: rejected }
        ];
    }

    fiRecord;
    @wire(getRecord, { recordId: '$recordId', fields: FI_FIELDS })
    async wiredFIRecord({ error, data }) {
        if (data) {
            this.fiRecord = data;
            this.isTractor = this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Product_Type__c.value == 'Tractor'? true : false;
            console.log('isTractor '+this.isTractor);
            // Prepare Input Wrapper
            await this.inputWrapperPopulator();
            console.log(' inputWrapper..', this.inputWrapper.applicantId.value);
            // Updating other fields
            this.applicationId = this.inputWrapper.applicationId.value;
            this.applicantId = this.inputWrapper.applicantId.value;
            if (this.inputWrapper.stage.value !== creditProcessing || this.inputWrapper.subStage.value !== fieldInvestigation) {
                this.disableButtonsAndFields = true;
            }
            if (this.inputWrapper.officeFIStatus.value == null || this.inputWrapper.officeFIStatus.value === pendingOfficeFIStatus) {
                this.pendingFI = true;
                this.disableButtonsAndFields = true;
            }
            if (this.inputWrapper.Office_FI_Accepted_Rejected.value === accepted && this.inputWrapper.subStage.value !== fieldInvestigation) {//CISP-3183
                this.disableButtonsAndFields = true;
            }
             //CISP-3135
             if( this.inputWrapper.coordinatesVerfied.value != 'warning'){//CISP-3225
                this.coordinatesMatchDisable = true; 
            }//CISP-3135 END
            this.getIncomeDetails(this.inputWrapper.applicantId.value);
            this.getProfile(this.inputWrapper.applicationId.value);//CISP-7179
            this.currentCaseId = this.inputWrapper.caseId.value;
        }
        else if (error) {
            if (error.body.message) {
                this.showToast(errorMsg, error.body.message, 'error', 'sticky');
            } else {
                this.showToast(errorMsg, serverDownErrMessage, 'error', 'sticky');
            }
        }
    }
    //CISP-7179start 
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
    @wire(getDocumentsOfFI, { applicationId: '$applicationId', applicantId: '$applicantId' })
    wiredFilesResult({ data, error }) {
        console.log('office files data..',data);
        if (data) {
            console.log('office files data..', JSON.stringify(data));
            if (data.signatureView) {
                this.inputWrapper['signatureView'].value = data.signatureView;
            }
            if (data.buildingfrontview) {
                this.inputWrapper['buildingfrontview'].value = data.buildingfrontview;
            }
        }
        else if (error) {
            console.log('office files data..', error);

            if (error.body.message) {
                this.showToast(errorMsg, error.body.message, 'error', 'sticky');
            } else {
                this.showToast(errorMsg, serverDownErrMessage, 'error', 'sticky');
            }
        }
    }


    async getIncomeDetails(applicationId) {
        try{
        let incomeDetails = await getIncomeSourceRecord({
            applicantId: applicationId
        }).then(record => {
            return record;
        });
        console.log(' incomeDetails==>', incomeDetails, ' this.applicationId ', this.applicationId);
        if (incomeDetails != null) {
            console.log('inside if');
            this.isPrimaryIncomeSourceTrue = incomeDetails.Primary_Income_Source__c;
            this.isSalaried = incomeDetails.Is_Salaried__c;
            this.isSelfEmployed = incomeDetails.Is_Self_Employed__c;
            this.profileName = incomeDetails.Profile__r.Sub_Bucket_Desc__c;
            console.log(' this.isSalaried==>', this.isSalaried, ' this.isSelfEmployed==>', this.isSelfEmployed, ' ', this.profileName);
            this.setProfile(incomeDetails);
        }
        console.log(' incomeDetails2==>', incomeDetails, ' this.applicationId ', this.applicationId);
        }catch(error){
            console.log(error);
        }

    }

    async validateFinalIncome() {
        console.log("inside     validateFinalIncome");

        if (this.isSelfEmployed == true) {
            console.log("inside selfEmployed");
            let variationAmount = this.inputWrapper.Declared_Income_During_Application.value * (parseInt(variation) / 100);
            let maxRange = this.inputWrapper.Declared_Income_During_Application.value + variationAmount;
            let minRange = this.inputWrapper.Declared_Income_During_Application.value - variationAmount;
            if ((minRange <= this.inputWrapper.SENP_Agriculture_Income.value && this.inputWrapper.SENP_Agriculture_Income.value <= maxRange)
                || (minRange <= this.inputWrapper.SENP_Own_Shop_Income.value && this.inputWrapper.SENP_Own_Shop_Income.value <= maxRange)
                || (minRange <= this.inputWrapper.SENP_Service_oriented_Income.value && this.inputWrapper.SENP_Service_oriented_Income.value <= maxRange)
                || (minRange <= this.inputWrapper.SENP_Transporter_Income.value && this.inputWrapper.SENP_Transporter_Income.value <= maxRange)
                || (minRange <= this.inputWrapper.SENP_Contractor_Income.value && this.inputWrapper.SENP_Contractor_Income.value <= maxRange)
                || (minRange <= this.inputWrapper.SENP_Rental_Income.value && this.inputWrapper.SENP_Rental_Income.value <= maxRange)
                || (minRange <= this.inputWrapper.SENP_Pension_Income.value && this.inputWrapper.SENP_Pension_Income.value <= maxRange)) {
                await this.saveOfficeFI();
            } else {
                this.variationTitle = variationTitle;
                this.variationMessage = variationMessage;
                this.showVariationPopup = true;
            }
        } else if (this.isSalaried == true) {
            console.log("inside salaried");
            await this.saveOfficeFI();
        }else{ //if(incomeDetails == null){
            console.log("inside nothing");
            console.log('inputWrapper', this.inputWrapper);

            await this.saveOfficeFI();
        }

    }

    async saveOfficeFI() {
        //console.log('after inputWrapper..', JSON.stringify(this.inputWrapper));
        this.showVariationPopup = false;
        if(this.isTractor){
            this.inputWrapper.Office_FI_Accepted_Rejected.value = 'Accepted';
        }
        if (this.inputWrapper.Office_FI_Accepted_Rejected.value && this.inputWrapper.Remarks.value) {
            console.log('inputWrapper',this.inputWrapper);

            await saveOfficeFI({
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
        } else if (this.inputWrapper.Office_FI_Accepted_Rejected.value === '') {
            this.showToast(errorMsg, ofcAcptRejSelMessage, 'warning', 'dismissable');
        } else if (this.inputWrapper.Remarks.value === '') {
            this.showToast(errorMsg, remarksMessage, 'warning', 'dismissable');
        } else {
            this.showToast(errorMsg, ofcAcptRejSelMessage + ' & ' + remarksMessage, 'warning', 'dismissable');
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
        this.inputWrapper['Office_FI_Accepted_Rejected'].value = event.target.value;
    }

    closeVariationPopup() {
        this.showVariationPopup = false;
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
        this.inputWrapper['officeFIStatus'] = { value: this.fiRecord.fields.FI_Status__c.value };
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
        this.inputWrapper['product'] = { label: 'Product', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Product_Type__c.value };
        this.inputWrapper['Remarks'] = { value: this.fiRecord.fields.Remarks__c.value ? this.fiRecord.fields.Remarks__c.value : '' };
        this.inputWrapper['Employer_Business_Name'] = { value: this.fiRecord.fields.Employer_Business_Name__c.value };
        this.inputWrapper['Current_experience_years'] = { value: this.fiRecord.fields.Current_experience_years__c.value };
        this.inputWrapper['Total_Experience_Years'] = { value: this.fiRecord.fields.Total_Experience_Years__c.value };
        this.inputWrapper['Income'] = { value: this.fiRecord.fields.Income__c.value };
        this.inputWrapper['Estimated_Service_Income_as_per_FI'] = { value: this.fiRecord.fields.Estimated_Service_Income_as_per_FI__c.value };
        this.inputWrapper['SENP_Agriculture_Income'] = { value: this.fiRecord.fields.SENP_Agriculture_Income__c.value };
        this.inputWrapper['SENP_Own_Shop_Income'] = { value: this.fiRecord.fields.SENP_Own_Shop_Income__c.value };
        this.inputWrapper['SENP_Service_oriented_Income'] = { value: this.fiRecord.fields.SENP_Service_oriented_Income__c.value };
        this.inputWrapper['SENP_Transporter_Income'] = { value: this.fiRecord.fields.SENP_Transporter_Income__c.value };
        this.inputWrapper['SENP_Contractor_Income'] = { value: this.fiRecord.fields.SENP_Contractor_Income__c.value };
        this.inputWrapper['SENP_Rental_Income'] = { value: this.fiRecord.fields.SENP_Rental_Income__c.value };
        this.inputWrapper['SENP_Pension_Income'] = { value: this.fiRecord.fields.SENP_Pension_Income__c.value };
        this.inputWrapper['Declared_Income_During_Application'] = { value: this.fiRecord.fields.Declared_Income_During_Application__c.value };
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
        this.inputWrapper['stage'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.StageName.value };
        this.inputWrapper['subStage'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Sub_Stage__c.value };
        // Document fields
        this.inputWrapper['signatureView'] = { label: signatureView, value: '' };
        this.inputWrapper['buildingfrontview'] = { label: buildingfrontview, value: '' };
        //Status field
        if (this.inputWrapper.Type.value === caseOfficeFIType) {
            this.inputWrapper['Office_FI_Accepted_Rejected'] = {
                label: officeFIStatus,
                value: (this.fiRecord.fields.Case__r.value.fields.Status.value === accepted) ? this.fiRecord.fields.Case__r.value.fields.Status.value : ''
            };
            this.fiAccordionTitle = offcResFITitle;
        }
    }
}