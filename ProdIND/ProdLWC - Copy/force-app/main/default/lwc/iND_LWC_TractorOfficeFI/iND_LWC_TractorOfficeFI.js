import { LightningElement,api,wire ,track } from 'lwc';
import cordVerGreenColor from '@salesforce/label/c.Coordinates_Verified_Green_Color';
import cordVerAmberColor from '@salesforce/label/c.Coordinates_Verified_Amber_Color';
import cordVerRedColor from '@salesforce/label/c.Coordinates_Verified_Red_Color';
import accepted from '@salesforce/label/c.FI_Accepted';
import rejected from '@salesforce/label/c.FI_Rejected';

import createRCUCase from '@salesforce/apex/RCUCaseController.createRCUCase';

import getFIRecord from '@salesforce/apex/IND_LWC_FICasePageCntrl.getFIRecord';
//Labels for the document upload from integrator app
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import residentFrontView from '@salesforce/label/c.Residence_Front_View';
import otherDocument from '@salesforce/label/c.Other_Document_Record_Type';
import kycDocument from '@salesforce/label/c.KYCDocument';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord,getRelatedListRecords,getFieldValue} from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';

import SCHEME_TYPE from '@salesforce/schema/Field_Investigation__c.Scheme_Type__c';
import SUB_SCHEME_TYPE from '@salesforce/schema/Field_Investigation__c.Sub_Scheme_Type__c';
import GENDER from '@salesforce/schema/Field_Investigation__c.Gender__c';
import CASTE from '@salesforce/schema/Field_Investigation__c.Caste__c';
import ADDRESS_IS_SAME_AS_FI_BE from '@salesforce/schema/Field_Investigation__c.Whether_address_is_same_as_FI_done_by_BE__c';
import RESIDENCE_PERMANENT_ADDR_SAME from '@salesforce/schema/Field_Investigation__c.Residance_Permanent_Address_are_Same__c';
import HOUSE_OWNERSHIP from '@salesforce/schema/Field_Investigation__c.House_ownership__c';
import BORROWER_VALID_DRIVING_LICENSE from '@salesforce/schema/Field_Investigation__c.Borrower_Having_Valid_Driving_licence__c';
import EARNING_MEMBER_FAMILY from '@salesforce/schema/Field_Investigation__c.Number_of_Earning_Member_in_Family__c';
import ASSET_AT_HOME from '@salesforce/schema/Field_Investigation__c.Assets_at_Home_Sum_up__c';
import Land_Irrigation_source from '@salesforce/schema/Field_Investigation__c.Land_Irrigation_source__c';
import TYPE_OF_HOUSE from '@salesforce/schema/Field_Investigation__c.House_Type__c';
import IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATION from '@salesforce/schema/Field_Investigation__c.IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATI__c';
import CURRENT_ADDR_DIFF_KYC_ADDR from '@salesforce/schema/Field_Investigation__c.Current_Addr_is_different_than_KYC_Addr__c';


import CROP_SOLD_SPECIFIC_PERSON from '@salesforce/schema/Field_Investigation__c.Crop_sold_to_any_specific_person__c';
import CATTLE_NAME from '@salesforce/schema/Field_Investigation__c.CATTLE_NAME__c';
import AGRI_COMMERCIAL from '@salesforce/schema/Field_Investigation__c.Agri_Commercial__c';
import WORK_ORDER_DETAILS from '@salesforce/schema/Field_Investigation__c.Work_order_details__c';
import KCC_LOAN_RUNNING from '@salesforce/schema/Field_Investigation__c.Any_KCC_loan_running__c';
import ANY_EXISTING_LOAN_LIKE_TWHLCARPL from '@salesforce/schema/Field_Investigation__c.Any_existing_loans_like_TWHLCARPL__c';
import ANY_EXISTING_TRACTORHARVESTOR_LOAN from '@salesforce/schema/Field_Investigation__c.Any_existing_TractorHarvester_Loan__c';
import SOURCE_OF_MARGIN_MONEY_USED from '@salesforce/schema/Field_Investigation__c.What_is_the_source_of_margin_money__c';
import SOURCE_OF_MARGIN_MONEY_CASH from '@salesforce/schema/Field_Investigation__c.If_the_source_of_margin_money_is_CASH__c';
import CUSTOMER_HAVING_EXISTING_IMPLEMENT from '@salesforce/schema/Field_Investigation__c.IS_CUSTOMER_HAVING_IMPLEMENT__c';
import DEPLOYMENT_OF_ASSET from '@salesforce/schema/Field_Investigation__c.DEPLOYMENT_OF_ASSET__c';
import ANY_NEGATIVE_OR_CAUTION_PROFILE from '@salesforce/schema/Field_Investigation__c.ANY_NEGATIVE_OR_CAUTION_PROFILE__c';
import VILLAGE_DOMINATED_WITH_ANY_COMMUNITY from '@salesforce/schema/Field_Investigation__c.VILLAGE_DOMINATED_WITH_ANY_COMMUNITY__c';
import IN_LAST_5_YEARS_ANY_DRAUGHTFlood from '@salesforce/schema/Field_Investigation__c.IN_LAST_5_YEARS_ANY_DRAUGHTFlood__c';
import Profile_to_Product_Match from '@salesforce/schema/Field_Investigation__c.Profile_to_Product_Match_1__c';
import FI_RESULT from '@salesforce/schema/Field_Investigation__c.FI_RESULT__c';
import IF_YES_ANY_IMPECT_OF_OUR_RECOVERY from '@salesforce/schema/Field_Investigation__c.IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c';
import Is_coborrower_existing_customer from '@salesforce/schema/Field_Investigation__c.Is_coborrower_existing_customer__c';
import EXISTING_NO_OF_VEHICLE from '@salesforce/schema/Field_Investigation__c.Existing_no_of_vehicles__c';

import SPOUSE_GENDER from '@salesforce/schema/Field_Investigation__c.Spouse_Gender__c';
import FIRST_CHILD_GENDER from '@salesforce/schema/Field_Investigation__c.First_Child_Gender__c';
import SECOND_CHILD_GENDER from '@salesforce/schema/Field_Investigation__c.Second_Child_Gender__c';
import THIRD_CHILD_GENDER from '@salesforce/schema/Field_Investigation__c.Third_Child_Gender__c';

import WHO_WILL_CLOSE_LOAN from '@salesforce/schema/Field_Investigation__c.Who_will_close_the_loan__c';
import FINANCE_FREE from '@salesforce/schema/Field_Investigation__c.Finance_Free__c';
import ARE_YOU_READY_TO_GUARNTEE_LOAN from '@salesforce/schema/Field_Investigation__c.Are_you_ready_for_guarntee_for_this_loan__c';
import ENTITY_TYPE from '@salesforce/schema/Field_Investigation__c.Entity_Type__c';
import OFFICE_TYPE from '@salesforce/schema/Field_Investigation__c.Office_Type__c';
import OFFICEOWNERSHIP from '@salesforce/schema/Field_Investigation__c.Office_ownership__c';
import NATUREOFBUSINESSMAJOR from '@salesforce/schema/Field_Investigation__c.Nature_of_Business_Major_Industry__c';


import FORM_FACTOR from '@salesforce/client/formFactor';

import FIELD_INVESTIGATION_OBJECT from '@salesforce/schema/Field_Investigation__c';

import checkRetryExhausted from '@salesforce/apex/IND_ResidenceFIController.checkRetryExhausted';
import getFieldInvestigation from '@salesforce/apex/IND_ResidenceFIController.getFieldInvestigation';
import createDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.createDocumentRecord';
import getDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.getDocumentRecord';

import checkDocFromApp from '@salesforce/apex/IND_ResidenceFIController.checkDocFromApp';
import getCurrentResidence from '@salesforce/apex/iND_TF_FI_DetailsController.getCurrentResidenceAddress';
import getPermanentAddress from '@salesforce/apex/iND_TF_FI_DetailsController.getPermanentResidenceAddress';

import getVehicleDetailsRecord from '@salesforce/apex/iND_TF_FI_DetailsController.getVehicleDetailsRecord';
import getFieldInvestigationKycLocation from '@salesforce/apex/iND_TF_FI_DetailsController.getFieldInvestigationKycLocation';

import doGeoCoderAPI from '@salesforce/apex/IntegrationEngine.doGeoCoderAPI';

import getRecordWithGeoLocation from '@salesforce/apex/iND_TF_FI_DetailsController.getRecordWithGeoLocation'; //SFTRAC-1880
import isFISubmitAllowed from '@salesforce/apex/iND_TF_FI_DetailsController.isFISubmitAllowed'; //SFTRAC-1880
import IS_SAVE_NAME from '@salesforce/schema/Field_Investigation__c.Is_Save__c'; //SFTRAC-1880 New

import * as helper from './IND_LWC_TractorOfficeFIHelper';

const FI_FIELDS = [
'Field_Investigation__c.Sub_Scheme_Type__c',
'Field_Investigation__c.Coordinates_Verified__c',
'Field_Investigation__c.Residence_FI_Status__c',
'Field_Investigation__c.FI_Status__c',
'Field_Investigation__c.Scheme_Type__c',

'Field_Investigation__c.Address_Line_1__c',
'Field_Investigation__c.Address_Line_2__c',
'Field_Investigation__c.City__c',
'Field_Investigation__c.Pin_Code__c',
'Field_Investigation__c.State__c',
'Field_Investigation__c.Remarks__c',

'Field_Investigation__c.Distance_from_Branch_to_customer__c',
'Field_Investigation__c.Distance_from_Borrower_to_Co_borrower__c',
'Field_Investigation__c.Basic_FI_address_to_be_populated_in_FI__c',
'Field_Investigation__c.Address_Verified_with_KYC__c',
'Field_Investigation__c.how_long_he_is_residing_kyc_address__c',
'Field_Investigation__c.Gender__c',
'Field_Investigation__c.Caste__c',
'Field_Investigation__c.Residance_Permanent_Address_are_Same__c',
'Field_Investigation__c.House_Type__c',
'Field_Investigation__c.Whether_address_is_same_as_FI_done_by_BE__c',
'Field_Investigation__c.House_ownership__c',
'Field_Investigation__c.How_many_members_in_the_Family__c',
'Field_Investigation__c.Number_of_Earning_Member_in_Family__c',
'Field_Investigation__c.Borrower_Having_Valid_Driving_licence__c',
'Field_Investigation__c.Assets_at_Home_Sum_up__c',
'Field_Investigation__c.Total_land_holding_within_the_family__c',
'Field_Investigation__c.Land_Irrigation_source__c',
'Field_Investigation__c.Approximate_Value_of_Agri_land__c',
'Field_Investigation__c.Crop_details_cultivated_last_year__c',
'Field_Investigation__c.Current_cropping_pattern_details__c',
'Field_Investigation__c.Crop_sold_to_any_specific_person__c',
'Field_Investigation__c.Sold_to_Contact_details__c',
'Field_Investigation__c.CATTLE_NAME__c',
'Field_Investigation__c.No_of_Cattle__c',
'Field_Investigation__c.Agri_Commercial__c',
'Field_Investigation__c.Since_how_long_in_Agri_commercial__c',
'Field_Investigation__c.Work_order_details__c',
'Field_Investigation__c.Other_source_of_Income__c',
'Field_Investigation__c.What_is_the_source_of_margin_money__c',
'Field_Investigation__c.If_the_source_of_margin_money_is_CASH__c',
'Field_Investigation__c.WHAT_IS_THE_AMOUNT_BORROWED_FROM_MARKET__c',
'Field_Investigation__c.IS_CUSTOMER_HAVING_IMPLEMENT__c',
'Field_Investigation__c.DEPLOYMENT_OF_ASSET__c',
'Field_Investigation__c.HOW_HE_WILL_DEPLOY_THE_ASSET__c',
'Field_Investigation__c.IF_NEGATIVE_THEN_REASON_FOR_NEGATIVE__c',
'Field_Investigation__c.Land_by_Borrower_in_Acres_with_proof__c',
'Field_Investigation__c.Current_Addr_is_different_than_KYC_Addr__c',
'Field_Investigation__c.Number_of_years_in_city_in_years__c',
'Field_Investigation__c.REFERENCE_CHECK_TRACTORHARVESTER__c',
'Field_Investigation__c.BORROWER_KNOWN_TO_Gurantor_SINCE__c',
'Field_Investigation__c.FI_OBSERVATION_1__c',
'Field_Investigation__c.NEAR_BY_POLICE_STATION_NAME__c',
'Field_Investigation__c.BROKER_DETAILS_FOR_HARVESTER__c',
'Field_Investigation__c.NEGATIVE_OR_CAUTION_Profile_details__c',
'Field_Investigation__c.If_yes_provide_details_of_damage__c',
'Field_Investigation__c.IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATI__c',
'Field_Investigation__c.Any_political_relation_Remarks__c',

'Field_Investigation__c.ANY_NEGATIVE_OR_CAUTION_PROFILE__c',
'Field_Investigation__c.VILLAGE_DOMINATED_WITH_ANY_COMMUNITY__c',
'Field_Investigation__c.IN_LAST_5_YEARS_ANY_DRAUGHTFlood__c',
'Field_Investigation__c.IBL_TFE_customer_borrower_count__c',
'Field_Investigation__c.Profile_to_Product_Match_1__c',
'Field_Investigation__c.Office_FI_Completion_Time__c',
'Field_Investigation__c.FI_RESULT__c',
'Field_Investigation__c.WHAT_IS_THE_TERMS_FOR_PARTNERSHIP__c',
'Field_Investigation__c.IF_EXCHANGE_OF_ASSET__c',
'Field_Investigation__c.Any_Margin_money_pending_with_dealer__c',
'Field_Investigation__c.Coordinates_Verified__c',
'Field_Investigation__c.IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c',
'Field_Investigation__c.Collection_FI__c', // created but may need  to change
'Field_Investigation__c.Are_you_ready_for_guarntee_for_this_loan__c',
'Field_Investigation__c.Existing_no_of_vehicles__c',

'Field_Investigation__c.Case__r.Applicant__c',
'Field_Investigation__c.Case__r.Applicant__r.Name',
'Field_Investigation__c.Case__r.Applicant__r.Applicant_Type__c',
'Field_Investigation__c.Case__r.Loan_Application__c',
'Field_Investigation__c.Case__r.Loan_Application__r.Name',
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

'Field_Investigation__c.FI_Address_Line_1__c',
'Field_Investigation__c.FI_Address_Line_2__c',
'Field_Investigation__c.FI_City__c',
'Field_Investigation__c.FI_Pin_Code__c',
'Field_Investigation__c.FI_District__c',
'Field_Investigation__c.FI_State__c',

'Field_Investigation__c.Asset_Model__c',
'Field_Investigation__c.Finance_Free__c',
'Field_Investigation__c.Financier_Name__c',
'Field_Investigation__c.Who_will_close_the_loan__c',
'Field_Investigation__c.Entity_Type__c',
'Field_Investigation__c.Office_Type__c',
'Field_Investigation__c.Office_ownership__c',
'Field_Investigation__c.How_many_Employees_in_Office__c',
'Field_Investigation__c.Contact_person_Name_Phone_number__c',
'Field_Investigation__c.Contact_person_Desingnation__c',
'Field_Investigation__c.ITR_1__c',
'Field_Investigation__c.ITR_2__c',
'Field_Investigation__c.ITR_3__c',
'Field_Investigation__c.Nature_of_Business_Major_Industry__c',
'Field_Investigation__c.Nature_of_Business_Minor_Industry__c',
IS_SAVE_NAME //SFTRAC-1880 New
];

export default class IND_LWC_TractorOfficeFI extends NavigationMixin(LightningElement) {
    @track rcuMethodCalled = false;
    @track SubmitDisabled = false;
    isSpinnerMoving = false;
    disableButtonsAndFields = false;
    applicationId;
    applicantId;
    applicantType;
    documentAddressType;
    fiRecord;
    label = {
    currentUserId, currentUserName,
    currentUserEmailid,mode,
    residentFrontView, currentApplicantid,otherDocument, kycDocument
    };
    wireRunsOnlyOnce = false;
    getFIrecordOnlyOnce = false;
    disabledCapturedBtn = false;
    currentUserId = userId;
    coordinatesDistance;
    activeSections = [];

    showUpload = false;
    showDocView = false;
    isVehicleDoc = false;
    isAllDocType = false;
    uploadViewDocFlag = false;
    viewDocFlag = false;
    sendingRecordTypeName = '';
    residenceUpload=false;
    expinvestment;
    vehicleInfo;

    @api recordId;
    @track inputWrapper = {};
    @track fiDetails;
    @track showResidenceFIComponent = false;
    @track showOfficeFIComponent = false;


    currentUserName;
    currentUserEmailId;
    perFamilyMemberExpense=0;

    submitFIAllowed = false;
    loanInfoTableDisabled = false; //SFTRAC-1880 New
    isSave = false; //SFTRAC-1880 New

    get saveDisabled(){
        return this.isSave;
    }

    get isSubmitDisabled(){
        return this.SubmitDisabled || (!this.submitFIAllowed && this.inputWrapper?.caseStatus?.value && this.inputWrapper?.caseStatus?.value != 'FI-Unassigned');
    }
    get getPhotoLabel(){
        return this.isSubmitDisabled ? "View Photo of Office" : "Upload Photo of Office";
    }

    //SFTRAC-1880 Start
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
    //SFTRAC-1880 End

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

    @wire(getObjectInfo, { objectApiName: FIELD_INVESTIGATION_OBJECT })
    fiMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: SCHEME_TYPE
    })
    schemeType;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: CURRENT_ADDR_DIFF_KYC_ADDR
        })
        isCurrentAddrDiffKycAddr;

    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: Land_Irrigation_source})
    landIrrigationSourceValues;

    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: AGRI_COMMERCIAL})
    agriCommercialValues;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: SUB_SCHEME_TYPE
        })
        subSchemeType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: ANY_NEGATIVE_OR_CAUTION_PROFILE
    })
    anyNeagativeorCautionProfileType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: VILLAGE_DOMINATED_WITH_ANY_COMMUNITY
    })
    villageDominatedwithAnyCommunityType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: Profile_to_Product_Match
    })
    profileToProductMatchType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: FI_RESULT
    })
    fiResultType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: EXISTING_NO_OF_VEHICLE
    })
    existingNoofVehicleType;

    //SFTRAC-1183
    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: WORK_ORDER_DETAILS
    })
    workOrderDetail;
    
    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: SOURCE_OF_MARGIN_MONEY_USED
    })
    sourceOfMarginMoneyUsed;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: SOURCE_OF_MARGIN_MONEY_CASH
    })
    sourceOfMarginMoneyCashType;

    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: CUSTOMER_HAVING_EXISTING_IMPLEMENT})
    customerHavingExistingImplementType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: IF_YES_ANY_IMPECT_OF_OUR_RECOVERY
    })
    ifYesAnyImpactofOurRecoveryType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: WHO_WILL_CLOSE_LOAN
    })
    whowillCloseLoanType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: FINANCE_FREE
    })
    financeFreeType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: ARE_YOU_READY_TO_GUARNTEE_LOAN
    })
    areYouReadyToGuarnteeLoanType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATION
    })
    isCoBorrowerHaveAnyPoliticalRelationType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: ENTITY_TYPE
    })
    ENTITYTYPE;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: OFFICE_TYPE
    })
    officeType;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: OFFICEOWNERSHIP
    })
    officeOwnership;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: NATUREOFBUSINESSMAJOR
    })
    natureofBusinessMajorType;


    @api callingFromFIScreen;
    @api disableRemarksField;
    @track fiRecordId;
    @wire(getFIRecord, {caseId: '$recordId'})
    wiredResult({data, error}){ 
        if(data && !this.getFIrecordOnlyOnce){
            this.getFIrecordOnlyOnce = true;
            this.fiDetails = data;
            this.fiRecordId = data.Id;
            console.log('data'+JSON.stringify(this.fiDetails));
            if(this.fiDetails.RecordType.Name === 'Office'){
                this.showOfficeFIComponent = true;
            }else{
                this.showResidenceFIComponent = true;
            }
        }else if(error){
            console.log('Error::',error);
            if(error.body.message) {
                this.showToast('Error!',error.body.message,'error','sticky');
            } else {
                this.showToast('Error!','Something went wrong, Please contact System Administrator','error','sticky');
            }
        }
    }

    borrowerFlag=false;
    coBorrowerFlag=false;
    guarantorFlag=false;
    fiLatLonRetryExhausted = false; //SFTRAC-1810
    @wire(getRecord, { recordId: '$fiRecordId', fields: FI_FIELDS })
    async wiredFIRecord({ error, data }) {
        if (data && !this.wireRunsOnlyOnce) {
            this.isSave = getFieldValue(data, IS_SAVE_NAME); //SFTRAC-1880 New
            this.wireRunsOnlyOnce = true;
            console.log('getRecord FI_FIELDS ', data);
            this.fiRecord = data;

            await this.inputWrapperPopulator();
            await this.renderedCallbackHandler();
            this.applicationId = this.inputWrapper.applicationId.value;
            this.applicantId = this.inputWrapper.applicantId.value;
            console.log('applicant id' + this.applicantId);
            this.applicantType = this.inputWrapper.applicantType.value;
            if (this.applicantType == 'Borrower') {
                this.borrowerFlag = true;
            }
            else if (this.applicantType == 'Co-borrower') {
                this.coBorrowerFlag = true;
            }
            else if (this.applicantType == 'Guarantor') {
                this.guarantorFlag = true;
            }
            await this.fetchFIRecords(); //SFTRAC-1880
            if(!this.isDisabled && !this.callingFromFIScreen && (this.filattitude == undefined || this.filongitude == undefined)){ //SFTRAC-1880
                helper.populateLatLon(this);
            }else{
                this.init();
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


    get borrowerAndCoborrower(){
        return this.borrowerFlag || this.coBorrowerFlag
    }

    get coborrowerAndGuarantor(){
        return this.coBorrowerFlag || this.guarantorFlag
    }

    get borrowerAndCoborrowerAndGuarantor(){
        return this.borrowerFlag || this.coBorrowerFlag || this.guarantorFlag
    }

    permanentAddr;
    wiredgetpermanentAddr=false;
    @wire(getPermanentAddress,{applicantId :'$applicantId'})
    getPermanentAddr({data,error}){
        if (data && !this.wiredgetpermanentAddr){
            this.wiredgetpermanentAddr = true;
            this.permanentAddr = data;
            //addr field - 
            if(data && data.length > 0){
                this.inputWrapper['permaddrLine1'] = { label: 'Permanent Adress line 1', value: data[0].KYC_Address_Line_1__c };
                this.inputWrapper['permaddrLine2'] = { label: 'Permanent Adress line 2', value:  data[0].KYC_Address_Line_2__c};
                this.inputWrapper['permcity'] = { label: 'Permanent City', value:  data[0].KYC_City__c};
                this.inputWrapper['permpinCode'] = { label: 'Permanent Pin Code', value:  data[0].KYC_Pin_Code__c};
                this.inputWrapper['permstate'] = { label: 'Permanent State', value:  data[0].KYC_State__c};
            }else{
                this.inputWrapper['permaddrLine1'] = { label: 'Permanent Adress line 1', value: '' };
                this.inputWrapper['permaddrLine2'] = { label: 'Permanent Adress line 2', value:  ''};
                this.inputWrapper['permcity'] = { label: 'Permanent City', value:  ''};
                this.inputWrapper['permpinCode'] = { label: 'Permanent Pin Code', value:  ''};
                this.inputWrapper['permstate'] = { label: 'Permanent State', value:  ''};
            }

        }
        if(error){
            console.log('error Registered ', error);
            if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }
    kyclocationDisplay;
    async init() {
        if(!this.isDisabled && !this.callingFromFIScreen){
            const fields = {};
            fields['Id'] = this.fiRecordId;
            fields['FI_Location__Latitude__s'] = this.filattitude;
            fields['FI_Location__Longitude__s'] = this.filongitude;
            const recordInput = {
                fields
            };
            await updateRecord(recordInput);
        

        await checkRetryExhausted({'loanApplicationId':this.applicationId, 'fieldInvestigation': this.fiRecordId}).then(result=>{
            this.disabledCapturedBtn = result;
        });
        await doGeoCoderAPI({ 'fiId': this.fiRecordId, 'loanApplicationId': this.applicationId })
                .then(result => {
                    this.isSpinnerMoving = false;
                })
                .catch(error => {
                    this.isSpinnerMoving = false;
                    console.log('error doGeoCoderAPI ',error);
                });
        }
        await getFieldInvestigationKycLocation({fieldInvestigationId:this.fiRecordId}).then(result=>{
            console.log('result ', result);
            if(result){
                this.kyclocationDisplay = result.KYC_Location__c ? result.KYC_Location__c: null;
                this.inputWrapper['kycLocation'] = { label: 'Kyc Location', value: this.kyclocationDisplay, latitude:result.KYC_Location__Latitude__s , longitude:result.KYC_Location__Longitude__s};
                
                this.FIclocationDisplay = result.FI_Location__c ? result.FI_Location__c: null;
                this.inputWrapper['FiLocation'] = { label: 'FI Location', value: this.FIclocationDisplay, latitude:result.FI_Location__Latitude__s , longitude:result.FI_Location__Longitude__s};

                let coordinatesVerifiedVariant = 'expired';
                if (result?.Coordinates_Verified__c === cordVerGreenColor) {
                    coordinatesVerifiedVariant = 'base-autocomplete';
                } else if (result?.Coordinates_Verified__c === cordVerAmberColor) {
                    coordinatesVerifiedVariant = 'warning';
                } else if (result?.Coordinates_Verified__c === cordVerRedColor) {
                    coordinatesVerifiedVariant = 'expired';
                }

                this.inputWrapper['coordinatesVerfied'] = { label: 'Coordinates Verify', value: coordinatesVerifiedVariant };
            }
        });
    }
    isDisabled=false;
    renderedCallback(){
        this.renderedCallbackHandler();
    }
    async renderedCallbackHandler() {
        //SFTRAC-1880 New START
        if(this.isSave){
            await this.handleDisableScreenOnSave();
            this.isDisabled=true;
        }
        console.log('++++++renderedCallbackHandler '+this.inputWrapper.caseStatus +' this.callingFromFIScreen ',this.callingFromFIScreen);
        //SFTRAC-1880 New END
        if ((this.inputWrapper.caseStatus && this.inputWrapper.caseStatus.value && (this.inputWrapper.caseStatus.value === 'Completed' || this.inputWrapper.caseStatus.value != 'FI-Unassigned')) || this.callingFromFIScreen ) {
            this.handleDisableScreen();
            this.isDisabled=true;
            this.SubmitDisabled = true;
            this.loanInfoTableDisabled = true; //SFTRAC-1880 New
        }console.log('++++this.loanInfoTableDisabled ',this.loanInfoTableDisabled);
        this.template.querySelectorAll(`[data-name=btn]`).forEach(ele=>ele.disabled=false);
    }
    handleDisableScreen() {
        const allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => {
            element.disabled = true;
        });
    }
    //SFTRAC-1880 New START
    handleDisableScreenOnSave() {
        const allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => {
            let dataId = element.getAttribute("data-id");
            if (dataId == 'MainSubmit') {
                console.log('Main Submit received');
            }else{
                element.disabled = true;
            }
        });
    }
    //SFTRAC-1880 New END

    inputWrapperPopulator() {
        this.inputWrapper['caseStatus'] = { label: 'Case Status', value: this.fiRecord.fields.Case__r.value.fields.Status.value };
        this.inputWrapper['Remarks'] = { value: this.fiRecord.fields.Remarks__c.value ? this.fiRecord.fields.Remarks__c.value : '' };
        this.inputWrapper['schmType'] = { label: 'Buyer Type', value: this.fiRecord.fields.Scheme_Type__c.value };

        this.inputWrapper['subschmType'] = { label: 'Land Holding Type', value: this.fiRecord.fields.Sub_Scheme_Type__c.value };

        if(this.fiRecord.fields.Sub_Scheme_Type__c.value){
            //this.disbaledLandHoldingType=true;
        }
        this.inputWrapper['entityType'] = { label: 'Entity Type', value: this.fiRecord.fields.Entity_Type__c.value };
        this.inputWrapper['officeType'] = { label: 'Office Type', value: this.fiRecord.fields.Office_Type__c.value };
        this.inputWrapper['officeOwnerShip'] = { label: 'Office Ownership Type', value: this.fiRecord.fields.Office_ownership__c.value };
        this.inputWrapper['howManyEmployeeinOffice'] = { label: 'How many employee in office?', value: this.fiRecord.fields.How_many_Employees_in_Office__c.value };
        this.inputWrapper['natureOfBusinessMajor'] = { label: 'Nature of Business - Major Industry', value: this.fiRecord.fields.Nature_of_Business_Major_Industry__c.value };
        this.inputWrapper['natureOfBusinessMinor'] = { label: 'Nature of Business - Minor Industry', value: this.fiRecord.fields.Nature_of_Business_Minor_Industry__c.value };
        
        this.inputWrapper['contactPersonNameandPhone'] = { label: 'Contact Person name and phone number', value: this.fiRecord.fields.Contact_person_Name_Phone_number__c.value };
        this.inputWrapper['contactPersonDesingnation'] = { label: 'Contact person Desingnation', value: this.fiRecord.fields.Contact_person_Desingnation__c.value };

        this.inputWrapper['applicantId'] = { label: 'Applicant ID', value: this.fiRecord.fields.Case__r.value.fields.Applicant__c.value };
        this.inputWrapper['applicantType'] = { label: 'Applicant Type', value: this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Applicant_Type__c.value };
        this.inputWrapper['applicationId'] = { label: 'Loan Application ID', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__c.value };
        this.inputWrapper['currentAddrisDiffKycAddr'] = { label: 'Current Address is different than KYC Address', value: this.fiRecord.fields.Current_Addr_is_different_than_KYC_Addr__c.value };
        this.inputWrapper['numberOfYearsInCity'] = { label: 'Number of years in city(in years)', value: this.fiRecord.fields.Number_of_years_in_city_in_years__c.value };
        this.inputWrapper['FIAddressLine1'] = { label: 'FI Address Line 1', value: this.fiRecord.fields.FI_Address_Line_1__c.value };
        this.inputWrapper['FIAddressLine2'] = { label: 'FI Address Line 2', value: this.fiRecord.fields.FI_Address_Line_2__c.value };
        this.inputWrapper['FICity'] = { label: 'FI City', value: this.fiRecord.fields.FI_City__c.value };
        this.inputWrapper['FIPinCode'] = { label: 'FI Pin Code', value: this.fiRecord.fields.FI_Pin_Code__c.value };
        this.inputWrapper['FIDistrict'] = { label: 'FI District', value: this.fiRecord.fields.FI_District__c.value };
        this.inputWrapper['FIState'] = { label: 'FI State', value: this.fiRecord.fields.FI_State__c.value };
        this.inputWrapper['originalKYCVerified'] = { label: 'Original KYC verifed', value: this.fiRecord.fields.Address_Verified_with_KYC__c.value };

        let landIrrigationSourceArray = [];
        if(this.fiRecord.fields.Land_Irrigation_source__c.value){
            let val = this.fiRecord.fields.Land_Irrigation_source__c.value;
            landIrrigationSourceArray = val.split(';')
        }
        
        this.inputWrapper['landIrrigationSource'] = { label: 'Land Irrigation Source', value: landIrrigationSourceArray.length>0?landIrrigationSourceArray:this.fiRecord.fields.Land_Irrigation_source__c.value };
        
        let agriCommercialArray = [];
        if(this.fiRecord.fields.Agri_Commercial__c.value){
            let val = this.fiRecord.fields.Agri_Commercial__c.value;
            agriCommercialArray = val.split(';')
        }
        this.inputWrapper['agriCommercial'] = { label: 'Agri Commercial', value:agriCommercialArray.length>0?agriCommercialArray:this.fiRecord.fields.Agri_Commercial__c.value };
        this.inputWrapper['workOrderDetails'] = { label: 'Work Order Details', value: this.fiRecord.fields.Work_order_details__c.value };//SFTRAC-1183
        this.inputWrapper['otherSourceOfIncome'] = { label: 'Other Source of Income', value: this.fiRecord.fields.Other_source_of_Income__c.value };

        this.inputWrapper['itr1'] = { label: 'ITR 1', value: this.fiRecord.fields.ITR_1__c.value };
        this.inputWrapper['itr2'] = { label: 'ITR 2', value: this.fiRecord.fields.ITR_2__c.value };
        this.inputWrapper['itr3'] = { label: 'ITR 3', value: this.fiRecord.fields.ITR_3__c.value };

        this.inputWrapper['distanceBranchtoCustomer'] = { label: 'Distance from Branch location to Current Residence (In kms)', value: this.fiRecord.fields.Distance_from_Branch_to_customer__c.value };

        this.inputWrapper['negativeProfile'] = { label: 'Any Negative or Caution Profile', value: this.fiRecord.fields.ANY_NEGATIVE_OR_CAUTION_PROFILE__c.value };
        this.inputWrapper['negativeProfileDetails'] = { label: 'Negative or Caution Profile Details', value: this.fiRecord.fields.NEGATIVE_OR_CAUTION_Profile_details__c.value };
        this.inputWrapper['nearByPoliceStation'] = { label: 'Nearby Police Station Name', value: this.fiRecord.fields.NEAR_BY_POLICE_STATION_NAME__c.value };
        this.inputWrapper['communityDominance'] = { label: 'Village/Area Dominated by Any Community', value: this.fiRecord.fields.VILLAGE_DOMINATED_WITH_ANY_COMMUNITY__c.value };

        
        this.inputWrapper['fiObservation'] = { label: 'FI Observation', value: this.fiRecord.fields.FI_OBSERVATION_1__c.value};
        this.inputWrapper['profileToProductMatch'] = { label: 'Profile to Product Match', value: this.fiRecord.fields.Profile_to_Product_Match_1__c.value };
        this.inputWrapper['fiResult'] = { label: 'FI Result', value: this.fiRecord.fields.FI_RESULT__c.value };
        
        this.inputWrapper['negativeReason'] = { label: 'If Negative, Then Reason for Negative', value: this.fiRecord.fields.IF_NEGATIVE_THEN_REASON_FOR_NEGATIVE__c.value };
        
        this.inputWrapper['fiDateTime'] = { label: 'FI Date and Time to Be Captured', value: this.inputWrapper.caseStatus.value !== 'FI-Unassigned' ?this.fiRecord.fields.Office_FI_Completion_Time__c.value:new Date().toISOString() };
        this.inputWrapper['kycLocation'] = { label: 'KYC Location', value: null };
        this.inputWrapper['FiLocation'] = { label: 'FI Location', value: null };
        this.inputWrapper['coordinatesVerfied'] = { label: 'Coordinates Verify', value: 'expired' };
        
        this.inputWrapper['existingNoofVehicle'] = { label: 'Existing no of vehicles', value: this.fiRecord.fields.Existing_no_of_vehicles__c.value };

        this.inputWrapper['sourceOfMarginMoney'] = { label: 'What is the source of margin money?', value: this.fiRecord.fields.What_is_the_source_of_margin_money__c.value };
        this.inputWrapper['sourceOfMarginMoneyCash'] = { label: 'If the source of margin money is Cash, please specify the amount', value: this.fiRecord.fields.If_the_source_of_margin_money_is_CASH__c.value };

        this.inputWrapper['assetModel'] = { label: 'Asset Model', value: this.fiRecord.fields.Asset_Model__c.value };
        this.inputWrapper['financeFree'] = { label: 'Finance Free', value: this.fiRecord.fields.Finance_Free__c.value };
        this.inputWrapper['financierName'] = { label: 'Financier Name', value: this.fiRecord.fields.Financier_Name__c.value };
        this.inputWrapper['whowillCloseLoan'] = { label: 'Who will close the loan', value: this.fiRecord.fields.Who_will_close_the_loan__c.value };

        this.inputWrapper['marginMoneyPending'] = { label: 'As per your observation any Margin money pending with Dealer/DSA, if Yes, what is the amount?', value: this.fiRecord.fields.Any_Margin_money_pending_with_dealer__c.value };

        let existingImplementArray = [];
        if(this.fiRecord.fields.IS_CUSTOMER_HAVING_IMPLEMENT__c.value){
            let val = this.fiRecord.fields.IS_CUSTOMER_HAVING_IMPLEMENT__c.value;
            existingImplementArray = val.split(';')
        }

        this.inputWrapper['existingImplement'] = { label: 'Is customer having any existing implement?', value:existingImplementArray.length>0?existingImplementArray:this.fiRecord.fields.IS_CUSTOMER_HAVING_IMPLEMENT__c.value };
        this.inputWrapper['deployAssetWithoutImplement'] = { label: 'How he will deploy the asset without implement?', value: this.fiRecord.fields.HOW_HE_WILL_DEPLOY_THE_ASSET__c };
        this.inputWrapper['majorImpact'] = { label: 'If Yes, Any Major Impact of Our Recovery', value: this.fiRecord.fields.IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c.value  };

        this.inputWrapper['coborrowerPoliticalRelation'] = { label: 'Any political relation', value: this.fiRecord.fields.IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATI__c.value };
        this.inputWrapper['politicalRelationRemarks'] = { label: 'Political relation remarks', value: this.fiRecord.fields.Any_political_relation_Remarks__c.value };

        this.inputWrapper['borrowerKnownToGurantorSince'] = { label: 'Borrower known to gurantor since', value: this.fiRecord.fields.BORROWER_KNOWN_TO_Gurantor_SINCE__c.value };
        this.inputWrapper['readyForGuarantee'] = { label: 'Are you ready to guarantee this loan', value: this.fiRecord.fields.Are_you_ready_for_guarntee_for_this_loan__c.value };
       
    }

    scrollToElement(className) {
        const element = this.template.querySelector(`.${className}`);
        if (element) {
            // Scroll to the element
            element.scrollIntoView({
                behavior: 'auto',
                block: 'center',
                inline: "start"
            });
        }
    }
   
    
    handleSubmitClicked(){ //SFTRAC-1880 # new CR
        this.isSpinnerMoving = true;
        this.isSubmitCalled = true;
        this.loanInfoTableDisabled = true;
        this.SubmitDisabled = true;
        

        let loanDetails = this.template.querySelectorAll('c-l-w-c_-l-o-s_-loan-informationfi-details');
        if(loanDetails && loanDetails.length > 0){
            let isValidLoanDetails = true;
            for (let index = 0; index < loanDetails.length; index++) {
                if(loanDetails[index] && loanDetails[index].saveRows()){
                    isValidLoanDetails = false;
                }
            }
            if(!isValidLoanDetails){
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.loanInfoTableDisabled = false;
                return;
            }
        }

        if(!this.isSave){
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'FI record should be Save before clicking on Submit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            
            this.isSpinnerMoving = false;
            this.isSubmitCalled = false;
            this.SubmitDisabled = false;

            return;
        }else{
            this.saveFIPage();
        }
    }

    async saveFI() {
        let landIrrigationSourceClass = this.template.querySelector('.landIrrigationSourceClass');
        let agriCommercialClass = this.template.querySelector('.agriCommercialClass');
        let negativeProfileDetailsClass = this.template.querySelector('.negativeProfileDetailsClass');
        let sourceOfMarginMoneyCashClass = this.template.querySelector('.sourceOfMarginMoneyCashClass');

        let financierNameClass = this.template.querySelector('.financierNameClass');
        let assetModelClass = this.template.querySelector('.assetModelClass');
        let financeFreeClass = this.template.querySelector('.financeFreeClass');
        let whowillCloseLoanClass = this.template.querySelector('.whowillCloseLoanClass');

        let existingImplementClass = this.template.querySelector('.existingImplementClass');
        let deployAssetWithoutImplementClass = this.template.querySelector('.deployAssetWithoutImplementClass');

        let politicalRelationRemarks = this.template.querySelector('.politicalRelationRemarks');
        let negativeReasonClass = this.template.querySelector('.negativeReasonClass');
        this.isSpinnerMoving = true;
        let isValid = true;

        if(this.borrowerFlag){
            // let loanDetails = this.template.querySelectorAll('c-l-w-c_-l-o-s_-loan-informationfi-details');
            // if(loanDetails && loanDetails.length > 0){
            //     let isValidLoanDetails = true;
            //     for (let index = 0; index < loanDetails.length; index++) {
            //         if(loanDetails[index] && loanDetails[index].saveRows()){
            //             isValidLoanDetails = false;
            //         }
            //     }
            //     if(!isValidLoanDetails){
            //         this.isSpinnerMoving = false;
            //         this.SubmitDisabled = false;
            //         return;
            //     }
            // } ##CODE Removed and moved to another handler based on SFTRAC-1880 Change Request
            if (this.inputWrapper['landIrrigationSource'].value && this.inputWrapper['landIrrigationSource'].value.length > 1 && this.inputWrapper['landIrrigationSource'].value.includes('DEPENDENT ON RAINS')) {
                landIrrigationSourceClass.setCustomValidity("DEPENDENT ON RAINS cant be selected with other options");
                landIrrigationSourceClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('landIrrigationSourceClass');
                return; // Exit early
            } else {
                landIrrigationSourceClass.setCustomValidity("");
                landIrrigationSourceClass.reportValidity();
                isValid = true;
            }
    
            if (this.inputWrapper['agriCommercial'].value && this.inputWrapper['agriCommercial'].value.length > 1 && this.inputWrapper['agriCommercial'].value.includes('None')) {
                agriCommercialClass.setCustomValidity("None cant be selected with other options");
                agriCommercialClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('agriCommercialClass');
    
                return; // Exit early
            } else {
                agriCommercialClass.setCustomValidity("");
                agriCommercialClass.reportValidity();
                isValid = true;
    
            }

            if (this.inputWrapper['sourceOfMarginMoney'].value === 'CASH' && !this.inputWrapper['sourceOfMarginMoneyCash'].value) {
                sourceOfMarginMoneyCashClass.setCustomValidity("Mandatory if 'What is the source of margin money' is selected as 'Cash'");
                sourceOfMarginMoneyCashClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('sourceOfMarginMoneyCashClass');
    
                return; // Exit early
            } else {
                sourceOfMarginMoneyCashClass.setCustomValidity("");
                sourceOfMarginMoneyCashClass.reportValidity();
                isValid = true;
            }
            if (this.inputWrapper['sourceOfMarginMoney'].value === 'CASH' && this.inputWrapper['sourceOfMarginMoneyCash'].value) {
                sourceOfMarginMoneyCashClass.setCustomValidity("");
                sourceOfMarginMoneyCashClass.reportValidity();
                isValid = true;
    
            }
    
            if (this.inputWrapper['sourceOfMarginMoney'].value === 'EXCHANGE OF TRACTOR' && (!this.inputWrapper['assetModel'].value 
                || !this.inputWrapper['financeFree'].value ||  !this.inputWrapper['financierName'].value || !this.inputWrapper['whowillCloseLoan'].value )
                ) {
    
                    assetModelClass.setCustomValidity("Mandatory if 'What is the source of margin money' is selected as 'Exchange of Tractor'");
                    assetModelClass.reportValidity();
                    financierNameClass.setCustomValidity("Mandatory if 'What is the source of margin money' is selected as 'Exchange of Tractor'");
                    financierNameClass.reportValidity();
                    financeFreeClass.setCustomValidity("Mandatory if 'What is the source of margin money' is selected as 'Exchange of Tractor'");
                    financeFreeClass.reportValidity();
                    whowillCloseLoanClass.setCustomValidity("Mandatory if 'What is the source of margin money' is selected as 'Exchange of Tractor'");
                    whowillCloseLoanClass.reportValidity();
                    isValid = false;
                    this.isSpinnerMoving = false;
                    this.SubmitDisabled = false;
                    this.scrollToElement('assetModelClass');
                    return; // Exit early
                } else {
                    assetModelClass.setCustomValidity('');
                    assetModelClass.reportValidity();
                    financierNameClass.setCustomValidity("");
                    financierNameClass.reportValidity();
                    financeFreeClass.setCustomValidity("");
                    financeFreeClass.reportValidity();
                    whowillCloseLoanClass.setCustomValidity("");
                    whowillCloseLoanClass.reportValidity();
                    isValid = true;
                }
                if (this.inputWrapper['sourceOfMarginMoney'].value === 'EXCHANGE OF TRACTOR' && this.inputWrapper['assetModel'].value &&
                this.inputWrapper['financeFree'].value && this.inputWrapper['financierName'].value && this.inputWrapper['whowillCloseLoan'].value) {
                    financierNameClass.setCustomValidity("");
                    financierNameClass.reportValidity();
                    assetModelClass.setCustomValidity("");
                    assetModelClass.reportValidity();
                    financeFreeClass.setCustomValidity("");
                    financeFreeClass.reportValidity();
                    whowillCloseLoanClass.setCustomValidity("");
                    whowillCloseLoanClass.reportValidity();
                    isValid = true;
                }
    
                if (this.inputWrapper['existingImplement'].value && this.inputWrapper['existingImplement'].value.length > 1 && this.inputWrapper['existingImplement'].value.includes('No')) {
                    existingImplementClass.setCustomValidity("No cant be selected with other options");
                    existingImplementClass.reportValidity();
                    isValid = false;
                    this.isSpinnerMoving = false;
                    this.SubmitDisabled = false;
                    this.scrollToElement('existingImplementClass');
                    return; // Exit early
                } else {
                    existingImplementClass.setCustomValidity("");
                    existingImplementClass.reportValidity();
                    isValid = true;
                }
    
                if (this.inputWrapper['existingImplement'].value && this.inputWrapper['existingImplement'].value.includes('No')) {
                    deployAssetWithoutImplementClass.setCustomValidity("Mandatory if 'IS customer HAVING ANY EXISTING IMPLEMENT' is selected as 'No'");
                    deployAssetWithoutImplementClass.reportValidity();
                    isValid = false;
                    this.isSpinnerMoving = false;
                    this.SubmitDisabled = false;
                    this.scrollToElement('deployAssetWithoutImplementClass');
       
                    // Now, make the 'Since How Long Agri Commercial' field required
                    if (!this.inputWrapper['deployAssetWithoutImplement'].value) {
                        deployAssetWithoutImplementClass.setCustomValidity("Mandatory if 'IS customer HAVING ANY EXISTING IMPLEMENT' is selected as 'No'");
                        deployAssetWithoutImplementClass.reportValidity();
                        isValid = false;
                        this.isSpinnerMoving = false;
                        this.SubmitDisabled = false;
                        this.scrollToElement('deployAssetWithoutImplementClass');
       
                        return; // Exit early
                    }
                    return; // Exit early
                } else {
                    deployAssetWithoutImplementClass.setCustomValidity("");
                    deployAssetWithoutImplementClass.reportValidity();
                    isValid = true;
       
                }
                if (this.inputWrapper['existingImplement'].value && !this.inputWrapper['existingImplement'].value.includes('No') &&
                    this.inputWrapper['deployAssetWithoutImplement'].value) {
                    deployAssetWithoutImplementClass.setCustomValidity("");
                    deployAssetWithoutImplementClass.reportValidity();
                    isValid = true;
       
                }
        }
        if(this.coBorrowerFlag || this.guarantorFlag){
            if (this.inputWrapper['negativeProfile'].value == 'Yes' && !this.inputWrapper['negativeProfile'].value) {
                negativeProfileDetailsClass.setCustomValidity("Mandatory if Negative or Caution Profile is yes");
                negativeProfileDetailsClass.reportValidity("");
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('negativeProfileDetailsClass');
                return;
            } else {
                negativeProfileDetailsClass.setCustomValidity("");
                negativeProfileDetailsClass.reportValidity("");
                isValid = true;
            }
            if (this.inputWrapper['negativeProfile'].value == 'Yes' && this.inputWrapper['negativeProfile'].value) {
                negativeProfileDetailsClass.setCustomValidity("");
                negativeProfileDetailsClass.reportValidity("");
                isValid = true;
            }
        }
        
        if(this.borrowerFlag || this.coBorrowerFlag){
            if (this.inputWrapper['fiResult'].value == 'Negative' && !this.inputWrapper['negativeReason'].value) {
                negativeReasonClass.setCustomValidity("Mandatory if 'FI RESULT' is Negative");
                negativeReasonClass.reportValidity("");
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('negativeReasonClass');
                return;
            } else {
                negativeReasonClass.setCustomValidity("");
                negativeReasonClass.reportValidity("");
                isValid = true;
            }
            if (this.inputWrapper['fiResult'].value == 'Negative' && this.inputWrapper['negativeReason'].value) {
                negativeReasonClass.setCustomValidity("");
                negativeReasonClass.reportValidity("");
                isValid = true;
            }
        }

        if (this.inputWrapper['currentAddrisDiffKycAddr'].value === 'Yes') {
            if (!this.validityCheck('.CurrentaddressDiffClass')) {
                this.showToast('Error!', 'Fill all Address details', 'warning');
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                isValid = false;
                return;
            } else {
                isValid = true;
            }
        }

        if (!this.validityCheck('.loanInformationDetails')) {
            this.showToast('Error!', 'Fill all the Loan Information Details', 'warning');
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            isValid = false;
            return;
        } else {
            isValid = true;
        }

        if (!this.validityCheck('.borrowerInformationDetails')) {
            this.showToast('Error!', 'Fill all the Borrower Information Details', 'warning');
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            isValid = false;
            return;
        } else {
            isValid = true;
        }

        if (!this.validityCheck('.landInformationDetails')) {
            this.showToast('Error!', 'Fill all Land,Crop Cattle Information', 'warning');
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            isValid = false;
            return;
        } else {
            isValid = true;
        }
       
        if (!this.validityCheck('.financialLiabilityInformation')) {
            this.showToast('Error!', 'Fill all the Financial Liability Information', 'warning');
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            isValid = false;
            return;
        } else {
            isValid = true;
        }

        if (!this.validityCheck('.fiInformationDetails')) {
            this.showToast('Error!', 'Fill all the FI Information Details', 'warning');
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            isValid = false;
            return;
        } else {
            isValid = true;
        }

        if (this.inputWrapper['coborrowerPoliticalRelation'].value === 'Yes' && !this.inputWrapper['politicalRelationRemarks'].value) {
            politicalRelationRemarks.setCustomValidity("Remarks is Required if Political relation is yes");
            politicalRelationRemarks.reportValidity();
            isValid = false;
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            this.scrollToElement('politicalRelationRemarks');
            return; // Exit early
            //this.showToast('Error!', 'Please Complete Sold to Contact Detail field', 'error', 'sticky');
        } else {
            politicalRelationRemarks.setCustomValidity("");
            politicalRelationRemarks.reportValidity();

        }
        if (this.inputWrapper['coborrowerPoliticalRelation'].value === 'Yes' && this.inputWrapper['politicalRelationRemarks'].value) {
            politicalRelationRemarks.setCustomValidity("");
            politicalRelationRemarks.reportValidity();
            isValid = true;
        }

        if (isValid) {
            // this.isSubmitCalled = true; //SFTRAC-1880 ## NEW Chnages
            this.saveFIPage();
        } else {
            this.showToast('Please Fill all the required inputs.', '', 'error', 'dismissable');
            this.isSpinnerMoving = false;
        }

    }

    isSubmitCalled = false; //SFTRAC-1880

    saveFIPage(){
        const fields = {};
        fields['Id'] = this.fiRecordId;
        fields['Scheme_Type__c'] = this.inputWrapper['schmType'].value;
        fields['Sub_Scheme_Type__c'] = this.inputWrapper['subschmType'].value;
        fields['Entity_Type__c'] = this.inputWrapper['entityType'].value;
        fields['Current_Addr_is_different_than_KYC_Addr__c'] = this.inputWrapper['currentAddrisDiffKycAddr'].value;
        fields['Number_of_years_in_city_in_years__c'] = this.inputWrapper['numberOfYearsInCity'].value;

        fields['FI_Address_Line_1__c'] = this.inputWrapper['FIAddressLine1'].value;
        fields['FI_Address_Line_2__c'] = this.inputWrapper['FIAddressLine2'].value;
        fields['FI_City__c'] = this.inputWrapper['FICity'].value;
        fields['FI_Pin_Code__c'] = this.inputWrapper['FIPinCode'].value;
        fields['FI_District__c'] = this.inputWrapper['FIDistrict'].value;
        fields['FI_State__c'] = this.inputWrapper['FIState'].value;
        fields['Address_Verified_with_KYC__c'] = this.inputWrapper['originalKYCVerified'].value;

        if (this.inputWrapper['landIrrigationSource'] && Array.isArray(this.inputWrapper['landIrrigationSource'].value) && this.inputWrapper['landIrrigationSource'].value.length > 0) {
            fields['Land_Irrigation_source__c'] = this.inputWrapper['landIrrigationSource'].value.join(';');
        } else {
            fields['Land_Irrigation_source__c'] = null;
        }

        if (this.inputWrapper['agriCommercial'] && Array.isArray(this.inputWrapper['agriCommercial'].value) && this.inputWrapper['agriCommercial'].value.length > 0) {
            fields['Agri_Commercial__c'] = this.inputWrapper['agriCommercial'].value.join(';');
        } else {
            fields['Agri_Commercial__c'] = null;
        }
        fields['Work_order_details__c'] = this.inputWrapper['workOrderDetails'].value; //SFTRAC-1183
        fields['Other_source_of_Income__c'] = this.inputWrapper['otherSourceOfIncome'].value;
        fields['ITR_1__c'] = this.inputWrapper['itr1'].value;
        fields['ITR_2__c'] = this.inputWrapper['itr2'].value;
        fields['ITR_3__c'] = this.inputWrapper['itr3'].value;

        fields['Distance_from_Branch_to_customer__c'] = this.inputWrapper['distanceBranchtoCustomer'].value;

        fields['ANY_NEGATIVE_OR_CAUTION_PROFILE__c'] = this.inputWrapper['negativeProfile'].value;
        fields['NEGATIVE_OR_CAUTION_Profile_details__c'] = this.inputWrapper['negativeProfileDetails'].value;
        fields['NEAR_BY_POLICE_STATION_NAME__c'] = this.inputWrapper['nearByPoliceStation'].value;
        fields['VILLAGE_DOMINATED_WITH_ANY_COMMUNITY__c'] = this.inputWrapper['communityDominance'].value;
        fields['FI_OBSERVATION_1__c'] = this.inputWrapper['fiObservation'].value;
        fields['Profile_to_Product_Match_1__c'] = this.inputWrapper['profileToProductMatch'].value;
        fields['FI_RESULT__c'] = this.inputWrapper['fiResult'].value;
        fields['IF_NEGATIVE_THEN_REASON_FOR_NEGATIVE__c'] = this.inputWrapper['negativeReason'].value;
        fields['Office_FI_Completion_Time__c'] = new Date().toISOString();

        fields['FI_Location__Latitude__s'] = this.filattitude;
        fields['FI_Location__Longitude__s'] = this.filongitude;

        fields['Existing_no_of_vehicles__c'] = this.inputWrapper['existingNoofVehicle'].value;
        fields['What_is_the_source_of_margin_money__c'] = this.inputWrapper['sourceOfMarginMoney'].value;
        fields['If_the_source_of_margin_money_is_CASH__c'] = this.inputWrapper['sourceOfMarginMoneyCash'].value;

        fields['Asset_Model__c'] = this.inputWrapper['assetModel'].value;
        fields['Finance_Free__c'] = this.inputWrapper['financeFree'].value;
        fields['Financier_Name__c'] = this.inputWrapper['financierName'].value;
        fields['Who_will_close_the_loan__c'] = this.inputWrapper['whowillCloseLoan'].value;

        fields['Any_Margin_money_pending_with_dealer__c'] = this.inputWrapper['marginMoneyPending'].value;

        if (this.inputWrapper['existingImplement'] && Array.isArray(this.inputWrapper['existingImplement'].value) && this.inputWrapper['existingImplement'].value.length > 0) {
            fields['IS_CUSTOMER_HAVING_IMPLEMENT__c'] = this.inputWrapper['existingImplement'].value.join(';');
        } else {
            fields['IS_CUSTOMER_HAVING_IMPLEMENT__c'] = null;
        }

        fields['HOW_HE_WILL_DEPLOY_THE_ASSET__c'] = this.inputWrapper['deployAssetWithoutImplement'].value;

        fields['IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c'] = this.inputWrapper['majorImpact'].value;
        fields['IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATI__c'] = this.inputWrapper['coborrowerPoliticalRelation'].value; // values not provided in sheet. picklist
        
        fields['Any_political_relation_Remarks__c'] = this.inputWrapper['politicalRelationRemarks'].value;

        fields['BORROWER_KNOWN_TO_Gurantor_SINCE__c'] = this.inputWrapper['borrowerKnownToGurantorSince'].value;
        fields['Are_you_ready_for_guarntee_for_this_loan__c'] = this.inputWrapper['readyForGuarantee'].value;

        fields['Office_Type__c'] = this.inputWrapper['officeType'].value;
        fields['Office_ownership__c'] = this.inputWrapper['officeOwnerShip'].value;
        fields['How_many_Employees_in_Office__c'] = this.inputWrapper['howManyEmployeeinOffice'].value;
        fields['Nature_of_Business_Major_Industry__c'] = this.inputWrapper['natureOfBusinessMajor'].value;
        fields['Nature_of_Business_Minor_Industry__c'] = this.inputWrapper['natureOfBusinessMinor'].value;

        fields['Contact_person_Name_Phone_number__c'] = this.inputWrapper['contactPersonNameandPhone'].value;
        fields['Contact_person_Desingnation__c'] = this.inputWrapper['contactPersonDesingnation'].value;
        if(this.isSubmitCalled){
            fields['FI_Status__c'] = 'Complete'; // Updating FI Status to complete
        }

        // SFTRAC-478 - Sahil - START
        const recordInput = {
            fields
        };
        // SFTRAC-478 - Sahil - END
        console.log('field' + JSON.stringify(fields));
        updateRecord(recordInput)
            .then(() => {
                if(!this.kyclocationDisplay){
                    this.SubmitDisabled = false;
                    this.isSpinnerMoving = false;
                    this.showToast('Error!', 'KYC loaction not captured!', 'error', 'dismissable');
                    return;
                }else if (!this.fiLatLonRetryExhausted && (!this.filongitude || !this.filattitude)){
                    this.SubmitDisabled = false;
                    this.isSpinnerMoving = false;
                    this.showToast('Error!', 'FI loaction not captured!', 'error', 'dismissable');
                    return;
                }else{
                this.SubmitDisabled = this.isSubmitCalled;
                this.showToast('Success!', 'FI Updated Successfully', 'success', 'dismissable');
                if(this.isSubmitCalled){
                    const fields = {};
                    fields['Id'] = this.recordId; // update case record
                    fields['Status'] = 'Completed';

                    const recordInput = { fields };
                    updateRecord(recordInput).then(result=>{
                        if(result){
                            this.isDisabled = true;
                            this.handleDisableScreen();
                            if(this.rcuMethodCalled == false){
                                this.rcuMethodCalled = true;
                                this.SubmitDisabled = true;
                                let response = createRCUCase({'loanApplicationId' : this.applicationId});
                                if(response == true){
                                    this.showToast('Success!', 'RCU Case is created!', 'success', 'dismissable');
                                }else{
                                    this.rcuMethodCalled = false;
                                }
                                window.location.reload();
                            }
                            this.isSpinnerMoving = false;
                        }
                    })
                    .catch(error=>{
                        console.log('Error case update'+JSON.stringify(error));
                        this.isSpinnerMoving = false;
                        this.SubmitDisabled = false;
                    });
                    }
                    else{
                        helper.onSaveFI(this); //SFTRAC-1880 New
                    }
                }
            })
            .catch((error) => {
                console.log('Error' + JSON.stringify(error));
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                //this.showToast('Error!', 'Error while updating data.', 'error', 'sticky');
                if (error.body.message) {
                    this.showToast('Error!', error.body.message, 'error', 'sticky');
                } else {
                    this.showToast('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'sticky');
                }
            });
    }

    disbaledLandHoldingType=false;
    exchangeofAssetValid=true;
    showAddrifCurretAddrisDiff
    async handleInputChange(event) {
        this.inputWrapper[event.target.name].value = event.target.value;
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        //SFTRAC:525 Fix Added Extra condition to avoid values field are getting disappeared
        if  ( 
            fieldName == 'currentAddrisDiffKycAddr' || 
            fieldName == 'FIAddressLine1' || 
            fieldName == 'FIAddressLine2' || 
            fieldName == 'FIState' || 
            fieldName == 'FIDistrict' || 
            fieldName == 'FICity' || 
            fieldName == 'FIPinCode' 
        ) {
            if (this.inputWrapper['currentAddrisDiffKycAddr'].value === 'Yes') {
            this.showAddrifCurretAddrisDiff = true;
        }
        else {
            this.showAddrifCurretAddrisDiff = false;
            this.inputWrapper['FIAddressLine1'].value='';
            this.inputWrapper['FIAddressLine2'].value='';
            this.inputWrapper['FIState'].value='';
            this.inputWrapper['FIDistrict'].value='';
            this.inputWrapper['FICity'].value='';
            this.inputWrapper['FIPinCode'].value='';
            }
        }
        if(fieldName == 'subschmType' && fieldValue){
            //this.disbaledLandHoldingType=true;
            await this.updateFiRecord(); // Update Land holding type immidiately after change as this will be used in land holding table
            let childElem=this.template.querySelector('c-l-w-c_-l-o-s_-land-holding-details');
            childElem.fieldInvestigationRecordId = this.fiRecordId;
            childElem.refreshComponentView();
        }

        if (fieldName === 'landIrrigationSource') {
            const selectedValues = this.inputWrapper['landIrrigationSource'].value || [];
            const landIrrigationSourceClass = this.template.querySelector('.landIrrigationSourceClass');

            if (this.inputWrapper['landIrrigationSource'].value && 
                this.inputWrapper['landIrrigationSource'].value.length > 1 && 
                this.inputWrapper['landIrrigationSource'].value.includes('DEPENDENT ON RAINS')) 
            {
                landIrrigationSourceClass.setCustomValidity("DEPENDENT ON RAINS cant be selected with other options");
                landIrrigationSourceClass.reportValidity();
            } else {
                landIrrigationSourceClass.setCustomValidity("");
                landIrrigationSourceClass.reportValidity();
            }
        }

        if (fieldName === 'agriCommercial'){
            let agriCommercialClass = this.template.querySelector('.agriCommercialClass');

            if (this.inputWrapper['agriCommercial'].value && 
                this.inputWrapper['agriCommercial'].value.length > 1 && 
                this.inputWrapper['agriCommercial'].value.includes('None')) 
            {
                agriCommercialClass.setCustomValidity("None cant be selected with other options");
                agriCommercialClass.reportValidity();
            } else {
                agriCommercialClass.setCustomValidity("");
                agriCommercialClass.reportValidity();
            }
        }
        if (
            fieldName === 'sourceOfMarginMoney' ||
            fieldName === 'assetModel' ||
            fieldName === 'financeFree' ||
            fieldName === 'financierName' ||
            fieldName === 'whowillCloseLoan'
        ) {
            if (this.inputWrapper['sourceOfMarginMoney'].value === 'EXCHANGE OF TRACTOR') {
                this.exchangeofAssetValid = false;
            } else {
                this.exchangeofAssetValid = true;
            }
        }

        if (fieldName === 'numberOfYearsInCity') {
            var pattern = /^\d+$/; 
            if(isNaN(event.target.value) || !pattern.test(event.target.value)){
                event?.target?.setCustomValidity('Please enter numeric value.');
            }else{
                event?.target?.setCustomValidity('');
                this.inputWrapper['numberOfYearsInCity'].value = fieldValue;
            }
            event?.target?.reportValidity();
        }
        if (fieldName === 'existingImplement') {
            const selectedValues = this.inputWrapper['existingImplement'].value || [];
            const existingImplementClass = this.template.querySelector('.existingImplementClass');
    
            if (
                this.inputWrapper['existingImplement'].value &&
                this.inputWrapper['existingImplement'].value.length > 1 &&
                this.inputWrapper['existingImplement'].value.includes('No')
            ) {
                existingImplementClass.setCustomValidity("No can't be selected with other options");
                existingImplementClass.reportValidity();
            } else {
                existingImplementClass.setCustomValidity("");
                existingImplementClass.reportValidity();
            }
        }

    }

    handleCheckboxChange(event) {
        this.inputWrapper[event.target.name].value = event.target.checked;
    }

    async updateFiRecord(){
        const fields = {};
            fields['Id'] = this.fiRecordId;
            fields['Sub_Scheme_Type__c'] = this.inputWrapper['subschmType'].value;
            const recordInput = {
                fields
            };
            await updateRecord(recordInput);
    }

    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
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

    handleCaptureFrontViewUplaod() {

        this.documentType = 'Office Front View';
        console.log('ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.documentType + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId +  '&documentSide=Front' + '&caseID' + '=' + this.recordId);
        // if (FORM_FACTOR === 'Large') {
            this.isSpinnerMoving = true;
            this.createDocument(this.documentType, this.label.otherDocument);
        // } else {
        //     this[NavigationMixin.Navigate]({
        //         type: "standard__webPage",
        //         attributes: {
        //             url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.documentType + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId +  '&documentSide=Front' + '&caseID' + '=' + this.recordId
        //         }
        //     });
        // }
    }
    documentId;
    docDeleted() { this.documentId = null; }
    functionality;
    openUploadComp(recordType) {
        this.showUpload = this.isSubmitDisabled ? false: true;;
        this.showDocView = true;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.sendingRecordTypeName = recordType;
        if(this.isSubmitDisabled){
            this.viewDocFlag = true;
        }else{
            this.uploadViewDocFlag = true;
        }
        this.functionality = 'ACH';
        this.isSpinnerMoving = false;

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
                this.isSpinnerMoving = false;
            });

    }

    async changeflagvalue(event) {
        this.uploadViewDocFlag = false;
        this.viewDocFlag = false;
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

        if (event.detail && event.detail.contentDocumentId != null && event.detail.backcontentDocumentId != null) {
            const evt = new ShowToastEvent({
                title: "All uploaded!",
                variant: 'success',
            });
            this.dispatchEvent(evt);

        }
    }

    vehicleInfoHandler(){
        //Event handler - do logic
    }

    refreshchildComponents(event){
        this.template.querySelectorAll('c-l-w-c_-l-o-s_-crop-details').forEach(ele=>{
            ele.refreshChildData();
        });
    }

    expInvHandler(event){
        this.expinvestment = event.detail;
    }

    //SFTRAC-1880 Start
    async fetchFIRecords() {
        this.isSpinnerMoving = true;
        await getRecordWithGeoLocation({ recordId: this.fiRecordId })
            .then(result => {
                this.isSpinnerMoving = false;
                console.log('FI Location Received >>'+JSON.stringify(result));
                this.filattitude = result?.FI_Location__Latitude__s;
                this.filongitude = result?.FI_Location__Longitude__s;
            })
            .catch(error => {
                this.isSpinnerMoving = false;
                this.errorMessage = 'An error occurred: ' + error.body.message;
                console.error('Error:', error);
            });
    }
    //SFTRAC-1880 End
}