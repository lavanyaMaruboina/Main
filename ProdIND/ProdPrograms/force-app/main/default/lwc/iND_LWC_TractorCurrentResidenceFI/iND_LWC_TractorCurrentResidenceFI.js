import { LightningElement,api,wire ,track} from 'lwc';

import cordVerGreenColor from '@salesforce/label/c.Coordinates_Verified_Green_Color';
import cordVerAmberColor from '@salesforce/label/c.Coordinates_Verified_Amber_Color';
import cordVerRedColor from '@salesforce/label/c.Coordinates_Verified_Red_Color';
import accepted from '@salesforce/label/c.FI_Accepted';
import rejected from '@salesforce/label/c.FI_Rejected';

import FI_RECORD_TYPE_NAME from '@salesforce/schema/Field_Investigation__c.RecordType.Name'; //SFTRAC-1789
import FI_PERSON_MET from '@salesforce/schema/Field_Investigation__c.Person_Met__c'; //SFTRAC-1789
import IS_SAVE_NAME from '@salesforce/schema/Field_Investigation__c.Is_Save__c'; //SFTRAC-1880 New

import createRCUCase from '@salesforce/apex/RCUCaseController.createRCUCase';

import getFIRecord from '@salesforce/apex/iND_TF_FI_DetailsController.getFIRecord';
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
import { getRecord, updateRecord,getRelatedListRecords, getFieldValue} from 'lightning/uiRecordApi';
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
import OFFICE_TYPE from '@salesforce/schema/Field_Investigation__c.Office_Type__c'; //SFTRAC-1183
import OFFICEOWNERSHIP from '@salesforce/schema/Field_Investigation__c.Office_ownership__c'; //SFTRAC-1183
import NATUREOFBUSINESSMAJOR from '@salesforce/schema/Field_Investigation__c.Nature_of_Business_Major_Industry__c'; //SFTRAC-1183
import FORM_FACTOR from '@salesforce/client/formFactor';

import FIELD_INVESTIGATION_OBJECT from '@salesforce/schema/Field_Investigation__c';

import checkRetryExhausted from '@salesforce/apex/IND_ResidenceFIController.checkRetryExhausted';
import getFieldInvestigation from '@salesforce/apex/IND_ResidenceFIController.getFieldInvestigation';
import getDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.getDocumentRecord';

import checkDocFromApp from '@salesforce/apex/IND_ResidenceFIController.checkDocFromApp';
import getCurrentResidence from '@salesforce/apex/iND_TF_FI_DetailsController.getCurrentResidenceAddress';
import getPermanentAddress from '@salesforce/apex/iND_TF_FI_DetailsController.getPermanentResidenceAddress';
import getVehicleDetailsRecord from '@salesforce/apex/iND_TF_FI_DetailsController.getVehicleDetailsRecord';
import getFieldInvestigationKycLocation from '@salesforce/apex/iND_TF_FI_DetailsController.getFieldInvestigationKycLocation';

import doGeoCoderAPI from '@salesforce/apex/IntegrationEngine.doGeoCoderAPI';
import Borrower from '@salesforce/label/c.Borrower';
import Documents__c from '@salesforce/schema/Documents__c';

import isFISubmitAllowed from '@salesforce/apex/iND_TF_FI_DetailsController.isFISubmitAllowed'; //SFTRAC-1880

import * as helper from './IND_LWC_TractorCurrentResidenceFIHelper';

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
    'Field_Investigation__c.DocUploaded_if_Current_KYC_Addre_Diff__c', //SFTRAC-1183
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
    'Field_Investigation__c.Residence_FI_completion_time__c',
    'Field_Investigation__c.FI_RESULT__c',
    'Field_Investigation__c.WHAT_IS_THE_TERMS_FOR_PARTNERSHIP__c',
    'Field_Investigation__c.IF_EXCHANGE_OF_ASSET__c',
    'Field_Investigation__c.Any_Margin_money_pending_with_dealer__c',

    'Field_Investigation__c.Coordinates_Verified__c',
    'Field_Investigation__c.IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c',
    'Field_Investigation__c.Are_you_ready_for_guarntee_for_this_loan__c',
    'Field_Investigation__c.Existing_no_of_vehicles__c',

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
    'Field_Investigation__c.ITR_1__c', //SFTRAC-1183
    'Field_Investigation__c.ITR_2__c', //SFTRAC-1183
    'Field_Investigation__c.ITR_3__c', //SFTRAC-1183
    'Field_Investigation__c.Office_Type__c',  //SFTRAC-1183
    'Field_Investigation__c.Office_ownership__c',  //SFTRAC-1183
    'Field_Investigation__c.How_many_Employees_in_Office__c',  //SFTRAC-1183
    'Field_Investigation__c.Contact_person_Name_Phone_number__c',  //SFTRAC-1183
    'Field_Investigation__c.Contact_person_Desingnation__c',  //SFTRAC-1183
    'Field_Investigation__c.Nature_of_Business_Major_Industry__c',  //SFTRAC-1183
    'Field_Investigation__c.Nature_of_Business_Minor_Industry__c',  //SFTRAC-1183
    FI_RECORD_TYPE_NAME, //SFTRAC-1789
    FI_PERSON_MET, //SFTRAC-1789
    IS_SAVE_NAME //SFTRAC-1880 New
    ];
  
export default class IND_LWC_TractorCurrentResidenceFI extends NavigationMixin(LightningElement) {
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
    photoAlongWithUploaded=false;
    expinvestment;
    vehicleInfo;
    isDisabledpartnershipTerms=true;
    isDisabledsourceOfMarginMoneyCash=false;
    isDisabledamountBorrowedFromMarket=false;
   
   @api recordId;
   @track inputWrapper = {};
   @track fiDetails;
    @track showResidenceFIComponent = false;
    @track showOfficeFIComponent = false;
    @api callingFromFIScreen;
    @api disableRemarksField;

    currentUserName;
    currentUserEmailId;
    perFamilyMemberExpense=0;
    @track otherDocRecordTypeId;
    @wire(getObjectInfo, { objectApiName: Documents__c }) wiredObjectInfo({ error, data }) {
        if (error) {
        } else if (data) {
            const rtis = data.recordTypeInfos;
            this.otherDocRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Other Documents');
        }
    }
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
        return this.isSubmitDisabled ? "View Photo of House with front view and inner view" : "Upload Photo of House with front view and inner view";
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

   @wire(getObjectInfo, { objectApiName: FIELD_INVESTIGATION_OBJECT })
   fiMetadata;

   //SFTRAC-1789 Start
   @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: FI_PERSON_MET
    })
    personMetOptions;
    //SFTRAC-1789 End


   @wire(getPicklistValues, {
       recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
       fieldApiName: SCHEME_TYPE
   })
   schemeType;

   @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: SUB_SCHEME_TYPE
    })
    subSchemeType;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: GENDER
        })
        genderPick;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: CASTE
    })
    castePick;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: ADDRESS_IS_SAME_AS_FI_BE
        })
        addrSameFIBE;

 @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: RESIDENCE_PERMANENT_ADDR_SAME
    })
    residencePermanentSame;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: HOUSE_OWNERSHIP
        })
        houseOwnership;

    @wire(getPicklistValues, {
    recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
    fieldApiName: BORROWER_VALID_DRIVING_LICENSE
    })
    validDrivingLicense;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: EARNING_MEMBER_FAMILY
        })
        earningMembersFamily;
    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: TYPE_OF_HOUSE
        })
        typeofHouseValue;
        
    
    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: ASSET_AT_HOME})
    assetatHomeValues;

    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: Land_Irrigation_source})
    landIrrigationSourceValues;

    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: CATTLE_NAME})
    cattleNameValues;

    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: AGRI_COMMERCIAL})
    agriCommercialValues;

    @wire(getPicklistValues, { recordTypeId: '$fiMetadata.data.defaultRecordTypeId', fieldApiName: CUSTOMER_HAVING_EXISTING_IMPLEMENT})
    customerHavingExistingImplementType;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: DEPLOYMENT_OF_ASSET
        })
        deploymentofAssetType;

    @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: CROP_SOLD_SPECIFIC_PERSON
        })
        cropSoldSpecificPerson;
    

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
        fieldApiName: IN_LAST_5_YEARS_ANY_DRAUGHTFlood
        })
        inLast5yearsanyDraughtFlood;

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
        fieldApiName: IF_YES_ANY_IMPECT_OF_OUR_RECOVERY
        })
        ifYesAnyImpactofOurRecoveryType;

        @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: CURRENT_ADDR_DIFF_KYC_ADDR
        })
        isCurrentAddrDiffKycAddr;

        @wire(getPicklistValues, {
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId',
        fieldApiName: EXISTING_NO_OF_VEHICLE
        })
        existingNoofVehicleType;

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

        @wire(getPicklistValues, {recordTypeId: '$fiMetadata.data.defaultRecordTypeId',fieldApiName: OFFICE_TYPE})
        officeType;
        
        @wire(getPicklistValues, {recordTypeId: '$fiMetadata.data.defaultRecordTypeId',fieldApiName: OFFICEOWNERSHIP})
        officeOwnership;
        
        @wire(getPicklistValues, {recordTypeId: '$fiMetadata.data.defaultRecordTypeId',fieldApiName: NATUREOFBUSINESSMAJOR})
        natureofBusinessMajorType;

        @track fiRecordId;
        @wire(getFIRecord, {caseId: '$recordId'})
        wiredResult({data, error}){ 
            if(data && !this.getFIrecordOnlyOnce){
                this.getFIrecordOnlyOnce = true;
                this.fiDetails = data;
                console.log('data'+JSON.stringify(this.fiDetails));
                if(this.fiDetails.RecordType.Name === 'Office'){
                    this.showOfficeFIComponent = true;
                    this.nonIndividualCmp = true;
                    return;
                }else{
                    this.showResidenceFIComponent = true;
                }
                this.fiRecordId = data.Id;
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
        loanAppEntityType; //SFTRAC-1183
        
        @track isCurrentResidenceRecordType = false; //SFTRAC-1789
        
        fiLatLonRetryExhausted = false; //SFTRAC-1810

    @wire(getRecord, { recordId: '$fiRecordId', fields: FI_FIELDS })
    async wiredFIRecord({ error, data }) {
        if (data && !this.wireRunsOnlyOnce) {
            this.isSave = getFieldValue(data, IS_SAVE_NAME); //SFTRAC-1880 New
            this.isCurrentResidenceRecordType = getFieldValue(data, FI_RECORD_TYPE_NAME) === 'Residence' ? true : false //SFTRAC-1789
            console.log('FI Persom Met : ',getFieldValue(data, FI_PERSON_MET)); //SFTRAC-1789
            this.wireRunsOnlyOnce = true;
            console.log('getRecord FI_FIELDS ', data);
            this.fiRecord = data;
            this.applicantType = this.fiRecord?.fields?.Case__r?.value?.fields?.Applicant__r?.value?.fields?.Applicant_Type__c?.value;
            this.loanAppEntityType = this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Entity_Type__c.value; console.log('+++++loanAppEntityType '+this.loanAppEntityType) //SFTRAC-1183
            await this.inputWrapperPopulator();
            await this.renderedCallbackHandler();
           this.applicationId = this.inputWrapper?.applicationId?.value;
           this.applicantId = this.inputWrapper?.applicantId?.value;
           this.applicantType = this.inputWrapper?.applicantType?.value;
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
            await helper.fetchFIRecords(this); //SFTRAC-1880
            if(!this.nonIndividualCmp){
                if(!this.isDisabled && !this.callingFromFIScreen && (this.filattitude == undefined || this.filongitude == undefined)){ //SFTRAC-1880
                    helper.populateLatLon(this);
                }else{
                    this.init();
                }
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
    @track filterList = [];
    @track editedData=[];
    @track flagHarvestorRequired=false;

    @wire(getVehicleDetailsRecord, { loanApplicationId: '$applicationId' })
    getVehicleDetailsRec(result) {
        let data = result.data;
        let error = result.error;
        if (data) {
            console.log('VehicleDetails >>'+JSON.stringify(data));
            this.filterList = [];
            this.filterList = data;
            this.flagHarvestorRequired = this.filterList.some(item => item.Vehicle_SubType__c === 'Harvester');
            //console.log('flagHarvestorRequired'+this.flagHarvestorRequired);
        }
        else if (error) {
            console.log('error get vehicle record ', error);
            if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    currentAddr;
    wiredgetCurrentAddronce=false;
    @wire(getCurrentResidence,{applicantId :'$applicantId'})
    getcurrentAddr({data,error}){
        if (data && !this.wiredgetCurrentAddronce){
            this.wiredgetCurrentAddronce = true;
            this.currentAddr = data;
        this.inputWrapper['addrLine1'] = { label: 'Current Adress line 1', value: data[0].KYC_Address_Line_1__c };
        this.inputWrapper['addrLine2'] = { label: 'Current Adress line 2', value:  data[0].KYC_Address_Line_2__c};
        this.inputWrapper['city'] = { label: 'Current City', value:  data[0].KYC_City__c};
        this.inputWrapper['pinCode'] = { label: 'Current Pin Code', value:  data[0].KYC_Pin_Code__c};
        this.inputWrapper['state'] = { label: 'Current State', value:  data[0].KYC_State__c};

        }
        if(error){
            console.log('error getcurrentAddr ', error);
            if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    permanentAddr;
    wiredgetpermanentAddr=false;
    @wire(getPermanentAddress,{applicantId :'$applicantId'})
    getPermanentAddr({data,error}){
        if (data && !this.wiredgetpermanentAddr){
            this.wiredgetpermanentAddr = true;
            this.permanentAddr = data;
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
            console.log('error getPermanentAddr ', error);
            if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', serverDownErrMessage, 'error', 'sticky');
            }
        }
    }

    get showDocumentLabel(){
        return this.isSubmitDisabled ? ("View Photo Along with " + this.applicantType) : ("Upload Photo Along with " + this.applicantType);
    }

    get borrowerAndCoborrower(){
        return this.borrowerFlag || this.coBorrowerFlag
    }
    //SF Team Observation
    get borrowerAndGuarantor(){
        return this.borrowerFlag || this.guarantorFlag
    }
    get drivingLicenseLabel(){
        if(this.borrowerFlag){
            return 'Borrower Having Valid Driving licence'
        }
        else{
            return `${this.applicantType} Having Valid Driving licence`
        }
    }
    get sectionInfoName(){
        return `${this.applicantType} Information`;
    }
    _nonIndividualCmp = false;
    get nonIndividualCmp() {
        return this._nonIndividualCmp;
    }
    
    set nonIndividualCmp(value) {
        this._nonIndividualCmp = value;
    }
    filattitude;
    filongitude;
    kyclocationDisplay;
    FIclocationDisplay;
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
    @track isDisabled=false;
    renderedCallback(){
        this.renderedCallbackHandler();
    }
    async renderedCallbackHandler() {
        //SFTRAC-1880 New START
        if(this.isSave){
            await this.handleDisableScreenOnSave();
            this.isDisabled=true;
        }
        //SFTRAC-1880 New END
        if ((this.inputWrapper.caseStatus && this.inputWrapper.caseStatus.value && (this.inputWrapper.caseStatus.value === 'Completed' || this.inputWrapper.caseStatus.value != 'FI-Unassigned')) || this.callingFromFIScreen ) {
            this.handleDisableScreen();
            this.isDisabled=true;
            this.SubmitDisabled = true;
            this.loanInfoTableDisabled = true; //SFTRAC-1880 New
        }
        this.template.querySelectorAll(`[data-name=btn]`).forEach(ele=>ele.disabled=false);
    }

    showAddrifCurretAddrisDiff;
    nonIndividualFlag = false;
    inputWrapperPopulator() {
        this.inputWrapper['personMet'] = { label: 'Person Met', value: getFieldValue(this.fiRecord, FI_PERSON_MET)}; //SFTRAC-1789
        this.inputWrapper['loanEntityType'] = { label: 'Loan Application ID', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Customer_Type__c.value};

        if(this.inputWrapper['loanEntityType'].value == 'Non-Individual' && this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Applicant_Type__c.value == 'Borrower' && this.fiRecord.fields.Case__r.Type == 'Office FI'){
            this.nonIndividualCmp = true;
            return;
        }if(this.inputWrapper['loanEntityType'].value == 'Non-Individual'){
            this.nonIndividualFlag = true;
        }else{this.nonIndividualFlag = false;}
        this.inputWrapper['caseStatus'] = { label: 'Case Status', value: this.fiRecord.fields.Case__r.value.fields.Status.value };
        this.inputWrapper['Remarks'] = { value: this.fiRecord.fields.Remarks__c.value ? this.fiRecord.fields.Remarks__c.value : '' };

        //console.log('this.fiRecord.fields  => ', this.fiRecord.fields);
        this.inputWrapper['schmType'] = { label: 'Buyer Type', value: this.fiRecord.fields.Scheme_Type__c.value };
        this.inputWrapper['subschmType'] = { label: 'Land Holding Type', value: this.fiRecord.fields.Sub_Scheme_Type__c.value };
        // if(this.fiRecord.fields.Sub_Scheme_Type__c.value){
        //     this.disbaledLandHoldingType=true;
        // }
        this.inputWrapper['distanceBranchtoCustomer'] = { label: 'Distance from Branch location to Current Residence (In kms)', value: this.fiRecord.fields.Distance_from_Branch_to_customer__c.value };
        this.inputWrapper['distanceborrowertoCoborrower'] = { label: `Distance from Borrower to ${this.applicantType} Residence`, value: this.fiRecord.fields.Distance_from_Borrower_to_Co_borrower__c.value };

        //Borrower Family Details - Sftrac-94
        /*this.inputWrapper['fatherDOB'] = { label: 'Father DOB', value: this.fiRecord.fields.Father_DOB__c.value };
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
        this.inputWrapper['child3DOB'] = { label: '3rd Child DOB', value: this.fiRecord.fields.Third_Child_DOB__c.value };*/
        this.inputWrapper['brokerDetails'] = { label: 'Broker Details for Harvester', value: this.fiRecord.fields.BROKER_DETAILS_FOR_HARVESTER__c.value };
        this.inputWrapper['negativeProfile'] = { label: 'Any Negative or Caution Profile', value: this.fiRecord.fields.ANY_NEGATIVE_OR_CAUTION_PROFILE__c.value };
        this.inputWrapper['negativeProfileDetails'] = { label: 'Negative or Caution Profile Details', value: this.fiRecord.fields.NEGATIVE_OR_CAUTION_Profile_details__c.value };
        this.inputWrapper['nearByPoliceStation'] = { label: 'Nearby Police Station Name', value: this.fiRecord.fields.NEAR_BY_POLICE_STATION_NAME__c.value };
        this.inputWrapper['communityDominance'] = { label: 'Village/Area Dominated by Any Community', value: this.fiRecord.fields.VILLAGE_DOMINATED_WITH_ANY_COMMUNITY__c.value };

        
        this.inputWrapper['fiObservation'] = { label: 'FI Observation', value: this.fiRecord.fields.FI_OBSERVATION_1__c.value};
        //Commented as change//this.inputWrapper['iblTfeCustomerCount'] = { label: 'Existing iBL TFE Customer Borrower Count in Village', value: this.fiRecord.fields.IBL_TFE_customer_borrower_count__c.value };
        this.inputWrapper['profileToProductMatch'] = { label: 'Profile to Product Match', value: this.fiRecord.fields.Profile_to_Product_Match_1__c.value };
        this.inputWrapper['fiResult'] = { label: 'FI Result', value: this.fiRecord.fields.FI_RESULT__c.value };
        
        this.inputWrapper['negativeReason'] = { label: 'If Negative, Then Reason for Negative', value: this.fiRecord.fields.IF_NEGATIVE_THEN_REASON_FOR_NEGATIVE__c.value };
        this.inputWrapper['fiDateTime'] = { label: 'FI Date and Time to Be Captured', value: this.inputWrapper.caseStatus.value !== 'FI-Unassigned' ?this.fiRecord.fields.Residence_FI_completion_time__c.value:new Date().toISOString() };
        //this.inputWrapper['fiDateTime'] = { label: 'FI Date and Time to Be Captured', value: new Date().toISOString() };
        this.inputWrapper['kycLocation'] = { label: 'KYC Location', value: null };
        this.inputWrapper['FiLocation'] = { label: 'FI Location', value:null};
        this.inputWrapper['coordinatesVerfied'] = { label: 'Coordinates Verify', value: 'expired' };
        
        this.inputWrapper['existingNoofVehicle'] = { label: 'Existing no of vehicles', value: this.fiRecord.fields.Existing_no_of_vehicles__c.value };
        this.inputWrapper['sourceOfMarginMoney'] = { label: 'What is the source of margin money?', value: this.fiRecord.fields.What_is_the_source_of_margin_money__c.value };
        this.inputWrapper['sourceOfMarginMoneyCash'] = { label: 'If the source of margin money is Cash, please specify the amount', value: this.fiRecord.fields.If_the_source_of_margin_money_is_CASH__c.value };
        this.inputWrapper['amountBorrowedFromMarket'] = { label: 'What is amount borrowed from market?', value: this.fiRecord.fields.WHAT_IS_THE_AMOUNT_BORROWED_FROM_MARKET__c.value };
       //Commented as change// this.inputWrapper['borrowedFromWhom'] = { label: 'WHO TO HE HAVE BORROWED', value: this.fiRecord.fields.WHO_TO_HE_HAVE_BORROWED__c.value };
        this.inputWrapper['partnershipTerms'] = { label: 'What is the terms for partnership?', value: this.fiRecord.fields.WHAT_IS_THE_TERMS_FOR_PARTNERSHIP__c.value };
        this.inputWrapper['exchangeOfAsset'] = { label: 'If exchange of asset, please provide details', value: this.fiRecord.fields.IF_EXCHANGE_OF_ASSET__c.value };
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

        let deploymentOfAssetArray = [];
        if(this.fiRecord.fields.DEPLOYMENT_OF_ASSET__c.value){
            let val = this.fiRecord.fields.DEPLOYMENT_OF_ASSET__c.value;
            deploymentOfAssetArray = val.split(';')
        }

        this.inputWrapper['deploymentOfAsset'] = { label: 'Deployment of asset', value: deploymentOfAssetArray.length>0?deploymentOfAssetArray:this.fiRecord.fields.DEPLOYMENT_OF_ASSET__c.value };

        this.inputWrapper['majorImpact'] = { label: 'If Yes, Any Major Impact of Our Recovery', value: this.fiRecord.fields.IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c.value  };
        this.inputWrapper['borrowerKnownToGurantorSince'] = { label: 'Borrower known to gurantor since', value: this.fiRecord.fields.BORROWER_KNOWN_TO_Gurantor_SINCE__c.value };
        this.inputWrapper['readyForGuarantee'] = { label: 'Are you ready to guarantee this loan', value: this.fiRecord.fields.Are_you_ready_for_guarntee_for_this_loan__c.value };
        this.inputWrapper['coborrowerPoliticalRelation'] = { label: 'Any political relation', value: this.fiRecord.fields.IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATI__c.value };
        this.inputWrapper['politicalRelationRemarks'] = { label: 'Political relation remarks', value: this.fiRecord.fields.Any_political_relation_Remarks__c.value };

        this.inputWrapper['kycAddress'] = { label: 'KYC Address', value: null }; // to be check with gaurav
        this.inputWrapper['currentAddress'] = { label: 'Current Address ', value: null };
        this.inputWrapper['currentAddrisDiffKycAddr'] = { label: 'Current Address is different than KYC Address', value: this.fiRecord.fields.Current_Addr_is_different_than_KYC_Addr__c.value };
        this.inputWrapper['numberOfYearsInCity'] = { label: 'Number of years in city(in years)', value: this.fiRecord.fields.Number_of_years_in_city_in_years__c.value };

        this.inputWrapper['FIAddressLine1'] = { label: 'FI Address Line 1', value: this.fiRecord.fields.FI_Address_Line_1__c.value };
        this.inputWrapper['FIAddressLine2'] = { label: 'FI Address Line 2', value: this.fiRecord.fields.FI_Address_Line_2__c.value };
        this.inputWrapper['FICity'] = { label: 'FI City', value: this.fiRecord.fields.FI_City__c.value };
        this.inputWrapper['FIPinCode'] = { label: 'FI Pin Code', value: this.fiRecord.fields.FI_Pin_Code__c.value };
        this.inputWrapper['FIDistrict'] = { label: 'FI District', value: this.fiRecord.fields.FI_District__c.value };
        this.inputWrapper['FIState'] = { label: 'FI State', value: this.fiRecord.fields.FI_State__c.value };

        this.inputWrapper['originalKYCVerified'] = { label: 'Original KYC verifed', value: this.fiRecord.fields.Address_Verified_with_KYC__c.value };
        this.inputWrapper['docUploadediflKYCCurrentdiff'] = { label: 'Original KYC verifed', value: this.fiRecord.fields.DocUploaded_if_Current_KYC_Addre_Diff__c.value };
        this.inputWrapper['residingDuration'] = { label: 'Since how long He/She is residing in the KYC address in Years', value: this.fiRecord.fields.how_long_he_is_residing_kyc_address__c.value };
        this.inputWrapper['gender'] = { label: 'Gender', value: this.fiRecord.fields.Gender__c.value };
        this.inputWrapper['caste'] = { label: 'Caste', value: this.fiRecord.fields.Caste__c.value };
        this.inputWrapper['addressSameAsFIBE'] = { label: 'Whether provided address is same as FI done by BE', value: this.fiRecord.fields.Whether_address_is_same_as_FI_done_by_BE__c.value };
        this.inputWrapper['residencePermanentAddressSame'] = { label: 'Residance & Permanent Address both are Same', value: this.fiRecord.fields.Residance_Permanent_Address_are_Same__c.value };
        this.inputWrapper['houseType'] = { label: 'House Type', value: this.fiRecord.fields.House_Type__c.value };
        this.inputWrapper['houseOwnership'] = { label: 'House ownership', value: this.fiRecord.fields.House_ownership__c.value };

        this.inputWrapper['familyMembers'] = { label: 'How many members in the Family', value: this.fiRecord.fields.How_many_members_in_the_Family__c.value };
        this.inputWrapper['earningMembers'] = { label: 'How many Earning members in the Family', value: this.fiRecord.fields.Number_of_Earning_Member_in_Family__c.value };
        this.inputWrapper['validDrivingLicense'] = { label: 'Borrower Having Valid Driving licence', value: this.fiRecord.fields.Borrower_Having_Valid_Driving_licence__c.value };
       
        let assetsAtHomeArray = [];
        if(this.fiRecord.fields.Assets_at_Home_Sum_up__c.value){
            let val = this.fiRecord.fields.Assets_at_Home_Sum_up__c.value;
            assetsAtHomeArray = val.split(';')
        }
        this.inputWrapper['assetsAtHome'] = { label: 'Assets at Home(Sum up)', value: assetsAtHomeArray.length>0?assetsAtHomeArray:this.fiRecord.fields.Assets_at_Home_Sum_up__c.value };
        this.inputWrapper['landHolding'] = { label: 'Land holding by Borrower in Acres', value: this.fiRecord.fields.Land_by_Borrower_in_Acres_with_proof__c.value }; // Null for now need to create new field check and then update
        
        let landIrrigationSourceArray = [];
        if(this.fiRecord.fields.Land_Irrigation_source__c.value){
            let val = this.fiRecord.fields.Land_Irrigation_source__c.value;
            landIrrigationSourceArray = val.split(';')
        }
        
        this.inputWrapper['landIrrigationSource'] = { label: 'Land Irrigation Source', value: landIrrigationSourceArray.length>0?landIrrigationSourceArray:this.fiRecord.fields.Land_Irrigation_source__c.value };
        this.inputWrapper['approxValueOfAgriLand'] = { label: 'Approximate Value of Agri Land', value: this.fiRecord.fields.Approximate_Value_of_Agri_land__c.value };
        this.inputWrapper['cropDetailsLastYear'] = { label: 'Crop Details Cultivated Last Year', value: this.fiRecord.fields.Crop_details_cultivated_last_year__c.value };
        this.inputWrapper['currentCroppingPattern'] = { label: 'Current Cropping Pattern Details', value: this.fiRecord.fields.Current_cropping_pattern_details__c.value };
        this.inputWrapper['cropSoldToSpecificPerson'] = { label: 'Whether Crop sold to any specific person every year', value: this.fiRecord.fields.Crop_sold_to_any_specific_person__c.value };
        this.inputWrapper['soldToContactDetails'] = { label: 'Sold to Contact details ', value: this.fiRecord.fields.Sold_to_Contact_details__c.value };
        this.inputWrapper['numberOfCattle'] = { label: 'No. of Cattle', value: this.fiRecord.fields.No_of_Cattle__c.value };

        let agriCommercialArray = [];
        if(this.fiRecord.fields.Agri_Commercial__c.value){
            let val = this.fiRecord.fields.Agri_Commercial__c.value;
            agriCommercialArray = val.split(';')
        }
        this.inputWrapper['agriCommercial'] = { label: 'Deployment of Asset(Agri Commercial)', value:agriCommercialArray.length>0?agriCommercialArray:this.fiRecord.fields.Agri_Commercial__c.value };
        this.inputWrapper['sinceHowLongAgriCommercial'] = { label: 'Since How Long in Agri Commercial Activity (In Years)', value: this.fiRecord.fields.Since_how_long_in_Agri_commercial__c.value };
        
        this.inputWrapper['droughtOrFlood'] = { label: 'In Last 5 Years, Any Drought/Flood?', value: this.fiRecord.fields.IN_LAST_5_YEARS_ANY_DRAUGHTFlood__c.value };
        this.inputWrapper['droughtOrFloodDetails'] = { label: 'Details of damage to customer crops and belonging due to draught', value: this.fiRecord.fields.If_yes_provide_details_of_damage__c.value };
        
        this.inputWrapper['workOrderDetails'] = { label: 'Work Order Details', value: this.fiRecord.fields.Work_order_details__c.value };
        this.inputWrapper['otherSourceOfIncome'] = { label: 'Other Source of Income', value: this.fiRecord.fields.Other_source_of_Income__c.value };

        //SFTRAC-1183 Starts
        this.inputWrapper['itr1'] = { label: 'ITR 1', value: this.fiRecord.fields.ITR_1__c.value };
        this.inputWrapper['itr2'] = { label: 'ITR 2', value: this.fiRecord.fields.ITR_2__c.value };
        this.inputWrapper['itr3'] = { label: 'ITR 3', value: this.fiRecord.fields.ITR_3__c.value };
        this.inputWrapper['officeType'] = { label: 'Office Type', value: this.fiRecord.fields.Office_Type__c.value };
        this.inputWrapper['officeOwnerShip'] = { label: 'Office Ownership Type', value: this.fiRecord.fields.Office_ownership__c.value };
        this.inputWrapper['howManyEmployeeinOffice'] = { label: 'How many employee in office?', value: this.fiRecord.fields.How_many_Employees_in_Office__c.value };
        this.inputWrapper['natureOfBusinessMajor'] = { label: 'Nature of Business - Major Industry', value: this.fiRecord.fields.Nature_of_Business_Major_Industry__c.value };
        this.inputWrapper['natureOfBusinessMinor'] = { label: 'Nature of Business - Minor Industry', value: this.fiRecord.fields.Nature_of_Business_Minor_Industry__c.value };
        this.inputWrapper['contactPersonNameandPhone'] = { label: 'Contact Person name and phone number', value: this.fiRecord.fields.Contact_person_Name_Phone_number__c.value };
        this.inputWrapper['contactPersonDesingnation'] = { label: 'Contact person Desingnation', value: this.fiRecord.fields.Contact_person_Desingnation__c.value };
        //SFTRAC-1183 Ends

        this.inputWrapper['applicantId'] = { label: 'Applicant ID', value: this.fiRecord.fields.Case__r.value.fields.Applicant__c.value };
        console.log('Type- '+this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Applicant_Type__c.value);
       this.inputWrapper['applicantType'] = { label: 'Applicant Type', value: this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Applicant_Type__c.value };
        this.inputWrapper['applicationId'] = { label: 'Loan Application ID', value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__c.value };
        if(this.inputWrapper['existingNoofVehicle'].value == 'No Assets'){
            //this.isHideKCCTable = true;
            this.existingNoVehicleValue = this.inputWrapper['existingNoofVehicle'].value; 
        }else{
            //this.isHideKCCTable = false;
            this.existingNoVehicleValue = this.inputWrapper['existingNoofVehicle'].value;
        }

        if(this.inputWrapper['cropSoldToSpecificPerson'].value === 'No'){
            this.issoldToContactDetailsDisable = true;
            this.inputWrapper['soldToContactDetails'].value = null;
        }else{
            this.issoldToContactDetailsDisable = false;
        }

        if(this.inputWrapper['droughtOrFlood'].value === 'No'){
            this.isdroughtOrFloodDetailsRequired = false;
            this.isdroughtOrFloodDetailsDisable = true;
            this.inputWrapper['droughtOrFloodDetails'].value = null;
        }else if (this.inputWrapper['droughtOrFlood'].value === 'Yes'){
            this.isdroughtOrFloodDetailsRequired = true;
            this.isdroughtOrFloodDetailsDisable = false;
        }
        if(this.inputWrapper['familyMembers'].value != null){
            this.perFamilyMemberExpense = this.inputWrapper['familyMembers'].value * 12 * 1000;
        }
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

    handleDisableScreen() {
        const allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => {
            element.disabled = true;
        });
    }
    disbaledLandHoldingType=false;
    exchangeofAssetValid=true;
    issoldToContactDetailsDisable = false;
    isdroughtOrFloodDetailsRequired = false;
    isdroughtOrFloodDetailsDisable = false;
    isHideKCCTable = false;
    @track existingNoVehicleValue='';
    async handleInputChange(event) {
        this.inputWrapper[event.target.name].value = event.target.value;
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        const earningMembersClass = this.template.querySelector('.earningMembersClass');
        if (fieldName == 'sourceOfMarginMoney') {
            console.log('here in RN');
            switch (fieldValue) {
                case 'CASH':
                    this.isDisabledpartnershipTerms=true;
                    this.isDisabledsourceOfMarginMoneyCash=false;
                    this.isDisabledamountBorrowedFromMarket=false;
                    this.inputWrapper['partnershipTerms'].value = '';
                    break;
                case 'BANK TRANSFER':
                    this.isDisabledpartnershipTerms=true;
                    this.isDisabledsourceOfMarginMoneyCash=true;
                    this.isDisabledamountBorrowedFromMarket=true;
                    this.inputWrapper['sourceOfMarginMoneyCash'].value = '';
                    this.inputWrapper['amountBorrowedFromMarket'].value = '';
                    this.inputWrapper['partnershipTerms'].value = '';
                    break;
                case 'BORROWED FROM MARKET':
                    this.isDisabledpartnershipTerms=true;
                    this.isDisabledsourceOfMarginMoneyCash=true;
                    this.isDisabledamountBorrowedFromMarket=false;
                    this.inputWrapper['sourceOfMarginMoneyCash'].value = 'BORROWED FROM MARKET';
                    break;
                case 'EXCHANGE OF TRACTOR':
                    this.isDisabledpartnershipTerms=true;
                    this.isDisabledsourceOfMarginMoneyCash=true;
                    this.isDisabledamountBorrowedFromMarket=true;
                    this.inputWrapper['sourceOfMarginMoneyCash'].value = '';
                    this.inputWrapper['amountBorrowedFromMarket'].value = '';
                    this.inputWrapper['partnershipTerms'].value = '';
                    break;
                case 'PARTNERS':
                    this.isDisabledpartnershipTerms=false;
                    this.isDisabledsourceOfMarginMoneyCash=true;
                    this.isDisabledamountBorrowedFromMarket=true;
                    this.inputWrapper['sourceOfMarginMoneyCash'].value = '';
                    this.inputWrapper['amountBorrowedFromMarket'].value = '';
                    break;
                default:
                    this.isDisabledpartnershipTerms=true;
                    this.isDisabledsourceOfMarginMoneyCash=true;
                    this.isDisabledamountBorrowedFromMarket=true;
            }
        }
        if (fieldName == 'familyMembers'){
            this.perFamilyMemberExpense = fieldValue*12*1000;
        if(parseInt(this.inputWrapper['earningMembers'].value) != null && parseInt(fieldValue) != null){
            if(parseInt(fieldValue) > 5 && this.inputWrapper['earningMembers'].value === '>5') {
                earningMembersClass.setCustomValidity("");
                earningMembersClass.reportValidity();
            }
            else if(parseInt(fieldValue) <= 5 && this.inputWrapper['earningMembers'].value === '>5') {
                earningMembersClass.setCustomValidity("Earning Member can't be more than members in the Family");
                earningMembersClass.reportValidity();
            }  
           else if(parseInt(fieldValue) >= parseInt(this.inputWrapper['earningMembers'].value)){
                  earningMembersClass.setCustomValidity("");
                earningMembersClass.reportValidity();
            }
           else if(parseInt(fieldValue) < parseInt(this.inputWrapper['earningMembers'].value)){
                    earningMembersClass.setCustomValidity("Earning Member can't be more than members in the Family");
                    earningMembersClass.reportValidity();
                }
            }
         }
         if(fieldName == 'existingNoofVehicle'){
            if(fieldValue == 'No Assets'){
                //this.isHideKCCTable = true;
                this.existingNoVehicleValue = fieldValue;
            }else{
                //this.isHideKCCTable = false;
                this.existingNoVehicleValue = fieldValue;
            }
         }
        if(fieldName == 'earningMembers'){
        if(parseInt(this.inputWrapper['familyMembers'].value) != null && parseInt(fieldValue) != null){
            if(fieldValue === '>5' && parseInt(this.inputWrapper['familyMembers'].value) > 5) {
                earningMembersClass.setCustomValidity("");
                earningMembersClass.reportValidity();
            }   
            else if(fieldValue === '>5' && parseInt(this.inputWrapper['familyMembers'].value) <= 5) {
                  earningMembersClass.setCustomValidity("Earning Member can't be more than members in the Family");
                  earningMembersClass.reportValidity();
             }            
            else if(parseInt(fieldValue) > parseInt(this.inputWrapper['familyMembers'].value)){
                earningMembersClass.setCustomValidity("Earning Member can't be more than members in the Family");
               earningMembersClass.reportValidity();
            }
             else {
                earningMembersClass.setCustomValidity("");
                earningMembersClass.reportValidity();
            }
           }
        }
        if(fieldName == 'sinceHowLongAgriCommercial'){
            const sinceHowLongAgriCommercialClass = this.template.querySelector('.sinceHowLongAgriCommercialClass');
            if(this.inputWrapper['sinceHowLongAgriCommercial'].value != null && this.inputWrapper['sinceHowLongAgriCommercial'].value >= 0 && this.inputWrapper['sinceHowLongAgriCommercial'].value <= 100){
                sinceHowLongAgriCommercialClass.setCustomValidity("");
                sinceHowLongAgriCommercialClass.reportValidity(); 
            }else{ 
                sinceHowLongAgriCommercialClass.setCustomValidity("Value should be between 0-100 in Years");
                sinceHowLongAgriCommercialClass.reportValidity();   
            }
        }

        if(fieldName == 'cropSoldToSpecificPerson'){
            if(fieldValue === 'No'){
                this.issoldToContactDetailsDisable = true;
                this.inputWrapper['soldToContactDetails'].value = null;
            }else{
                this.issoldToContactDetailsDisable = false;
            }
        }

        if(fieldName == 'soldToContactDetails'){
            let cropSoldtoAnySpecificYear = this.template.querySelector('.cropSoldToSpecificPersonClass');
            let soldToContactDetailsClass = this.template.querySelector('.soldToContactDetailsClass');
            const inputPattern = new RegExp("^[a-zA-Z0-9]+$");
            if(cropSoldtoAnySpecificYear.value === 'Yes' && soldToContactDetailsClass.value){
                if (inputPattern.test(soldToContactDetailsClass.value)) {
                    soldToContactDetailsClass.setCustomValidity("");
                } else {
                    soldToContactDetailsClass.setCustomValidity("Input should contain only numbers or letters, no special characters.");
                }
            }else{
                soldToContactDetailsClass.setCustomValidity("");
            }
        }

        if(fieldName == 'droughtOrFlood'){
            if(fieldValue === 'No'){
                this.isdroughtOrFloodDetailsRequired = false;
                this.isdroughtOrFloodDetailsDisable = true;
                this.inputWrapper['droughtOrFloodDetails'].value = null;
            }else if (fieldValue === 'Yes'){
                this.isdroughtOrFloodDetailsRequired = true;
                this.isdroughtOrFloodDetailsDisable = false;
            }
        }

        if(fieldName == 'subschmType' && fieldValue){
            // this.disbaledLandHoldingType=true;
            await this.updateFiRecord(); // Update Land holding type immidiately after change as this will be used in land holding table
            let childElem=this.template.querySelector('c-l-w-c_-l-o-s_-land-holding-details');
            childElem.fieldInvestigationRecordId = this.fiRecordId;
            childElem.refreshComponentView();
        }
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
                this.inputWrapper['assetModel'].value = '';
                this.inputWrapper['financeFree'].value = '';
                this.inputWrapper['financierName'].value = '';
                this.inputWrapper['whowillCloseLoan'].value = '';
            }
        }

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
    handleCheckboxChange(event) {
        this.inputWrapper[event.target.name].value = event.target.checked;
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
   
    @track sumOfLandHolding_landholder;

    isSubmitCalled = false; //SFTRAC-1880

    handleSubmitClicked(){ //SFTRAC-1880 New - New way of calling
        helper.handleSubmitClicked(this);
    }
    
    async saveResidenceFI() {
        this.isSpinnerMoving = true;
        // this.SubmitDisabled = true;  //SFTRAC-1880 New
        let isValid = true;
   
        let cropSoldtoAnySpecificYear = this.template.querySelector('.cropSoldToSpecificPersonClass');
        let soldToContactDetailsClass = this.template.querySelector('.soldToContactDetailsClass');
        let cattleNameClass = this.template.querySelector('.cattleNameClass');
        let numberOfCattleClass = this.template.querySelector('.numberOfCattleClass');
        let agriCommercialClass = this.template.querySelector('.agriCommercialClass');
        let sinceHowLongAgriCommercialClass = this.template.querySelector('.sinceHowLongAgriCommercialClass');
        let anyOtherLoansClass = this.template.querySelector('.anyOtherLoansClass');
        let otherLoanDetailsClass = this.template.querySelector('.otherLoanDetailsClass');
        let tractorLoanDetailsClass = this.template.querySelector('.tractorLoanDetailsClass');
        let sourceOfMarginMoneyCashClass = this.template.querySelector('.sourceOfMarginMoneyCashClass');
        let amountBorrowedFromMarketClass = this.template.querySelector('.amountBorrowedFromMarketClass');
        let borrowedFromWhomClass = this.template.querySelector('.borrowedFromWhomClass');
        let existingImplementClass = this.template.querySelector('.existingImplementClass');
        let deployAssetWithoutImplementClass = this.template.querySelector('.deployAssetWithoutImplementClass');
        let coborrowerAddressClass = this.template.querySelector('.coborrowerAddressClass');
        let borrowerKnownToCoborrowerSinceClass = this.template.querySelector('.borrowerKnownToCoborrowerSinceClass');
        let fiResultClass = this.template.querySelector('.fiResultClass');
        let negativeReasonClass = this.template.querySelector('.negativeReasonClass');
        let collectionFIClass = this.template.querySelector('.collectionFIClass');
        let relationshipBorrowerCoborrowerClass = this.template.querySelector('.relationshipBorrowerCoborrowerClass');
        let coborrowerPoliticalRelationClass = this.template.querySelector('.coborrowerPoliticalRelationClass');
        let landHoldingClass = this.template.querySelector('.landHoldingClass');
        let subschmTypeClass = this.template.querySelector('.subschmTypeClass');
        let partnershipTermsClass = this.template.querySelector('.partnershipTermsClass');
        let exchangeOfAssetClass = this.template.querySelector('.exchangeOfAssetClass');
        let financierNameClass = this.template.querySelector('.financierNameClass');
        let assetModelClass = this.template.querySelector('.assetModelClass');
        let financeFreeClass = this.template.querySelector('.financeFreeClass');
        let whowillCloseLoanClass = this.template.querySelector('.whowillCloseLoanClass');

        //let basicFIAddressClass = this.template.querySelector('.basicFIAddressClass');
        //let CurrentaddressDiffClass = this.template.querySelector('.CurrentaddressDiffClass');
        let negativeProfileDetailsClass = this.template.querySelector('.negativeProfileDetailsClass');
        //let marginMoneyPendingClass = this.template.querySelector('.marginMoneyPendingClass');
        let landIrrigationSourceClass = this.template.querySelector('.landIrrigationSourceClass');
        let politicalRelationRemarks = this.template.querySelector('.politicalRelationRemarks');
        let brokerDetailsClass = this.template.querySelector('.brokerDetailsClass');
   
        if (this.borrowerFlag) {
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
            // } ######CODE Removed and moved to another handler based on SFTRAC-1880 Change Request

        const landHoldingComponent = this.template.querySelector('c-l-w-c_-l-o-s_-land-holding-details');
        if (landHoldingComponent) {
            let isValidLandHoldingDetails = true;
            landHoldingComponent.allRowsCalculation();
            this.sumOfLandHolding_landholder = landHoldingComponent.sumOfLandHolding_landholder;
            if(this.inputWrapper['subschmType'].value == '0.1-2 acre' && (this.sumOfLandHolding_landholder < 0.1)){
                this.showToast('Error', 'Sum of Land holding In acres should be within the range.', 'Error', 'dismissable');
                isValidLandHoldingDetails = false; //SFTRAC-614
            }else if(this.inputWrapper['subschmType'].value == '2-4 acre' && (this.sumOfLandHolding_landholder < 2)){
                this.showToast('Error', 'Sum of Land holding In acres should be within the range.', 'Error', 'dismissable');
                isValidLandHoldingDetails = false; //SFTRAC-614
            }else if(this.inputWrapper['subschmType'].value == '>4 acre' && (this.sumOfLandHolding_landholder <= 4)){
                this.showToast('Error', 'Sum of Land holding In acres should be within the range.', 'Error', 'dismissable');
                isValidLandHoldingDetails = false; //SFTRAC-614
            }
            if(!isValidLandHoldingDetails){//SFTRAC-614
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                return;
            }
        }
        if(this.nonIndividualFlag == true && this.inputWrapper['docUploadediflKYCCurrentdiff'].value == false && this.inputWrapper['currentAddrisDiffKycAddr'].value === 'Yes'){//SFTARC-1183
            this.showToast('Error', 'Current Address is different than KYC Address, please upload at least one document', 'Error', 'dismissable');
            isValid = false;
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            return;
        }

            if (cropSoldtoAnySpecificYear.value === 'Yes' && !soldToContactDetailsClass.value) {
                soldToContactDetailsClass.setCustomValidity("Sold to Contact Detail value is required");
                soldToContactDetailsClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('soldToContactDetailsClass');
                return; // Exit early
            } else {
                soldToContactDetailsClass.setCustomValidity("");
                soldToContactDetailsClass.reportValidity();
   
            }
            if (cropSoldtoAnySpecificYear.value === 'Yes' && soldToContactDetailsClass.value) {
                soldToContactDetailsClass.setCustomValidity("");
                soldToContactDetailsClass.reportValidity();
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
            if (this.inputWrapper['agriCommercial'].value && !this.inputWrapper['agriCommercial'].value.includes('None') &&
                this.inputWrapper.sinceHowLongAgriCommercial.value == null) {
                sinceHowLongAgriCommercialClass.setCustomValidity("Mandatory if 'Agri Commercial' is selected other than None");
                sinceHowLongAgriCommercialClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('sinceHowLongAgriCommercialClass');
   
   
                // Now, make the 'Since How Long Agri Commercial' field required
                if (!this.inputWrapper['sinceHowLongAgriCommercial'].value) {
                    sinceHowLongAgriCommercialClass.setCustomValidity("Mandatory if 'Agri Commercial' is selected other than None");
                    sinceHowLongAgriCommercialClass.reportValidity();
                    isValid = false;
                    this.isSpinnerMoving = false;
                    this.SubmitDisabled = false;
                    this.scrollToElement('sinceHowLongAgriCommercialClass');
   
                    return; // Exit early
                }
                return; // Exit early
            } else {
                sinceHowLongAgriCommercialClass.setCustomValidity("");
                sinceHowLongAgriCommercialClass.reportValidity();
                isValid = true;
   
            }
            if (this.inputWrapper['agriCommercial'].value && !this.inputWrapper['agriCommercial'].value.includes('None') &&
                this.inputWrapper['sinceHowLongAgriCommercial'].value) {
                sinceHowLongAgriCommercialClass.setCustomValidity("");
                sinceHowLongAgriCommercialClass.reportValidity();
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
            if (this.inputWrapper['sourceOfMarginMoney'].value === 'PARTNERS' && !this.inputWrapper['partnershipTerms'].value) {
                partnershipTermsClass.setCustomValidity("Mandatory if 'What is the source of margin money' is selected as 'PARTNERS'");
                partnershipTermsClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('partnershipTermsClass');
   
                return; // Exit early
            } else {
                partnershipTermsClass.setCustomValidity("");
                partnershipTermsClass.reportValidity();
                isValid = true;
            }
            if (this.inputWrapper['sourceOfMarginMoney'].value === 'PARTNERS' && this.inputWrapper['partnershipTerms'].value) {
                partnershipTermsClass.setCustomValidity("");
                partnershipTermsClass.reportValidity();
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
   
            if (this.inputWrapper['sourceOfMarginMoney'].value === 'BORROWED FROM MARKET' &&
                (!this.inputWrapper['amountBorrowedFromMarket'].value
                    )) {
                amountBorrowedFromMarketClass.setCustomValidity("Mandatory if 'What is the source of margin money' is selected as 'BORROWED FROM MARKET'");
                amountBorrowedFromMarketClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('amountBorrowedFromMarketClass');
   
                return; // Exit early
            } else {
                amountBorrowedFromMarketClass.setCustomValidity("");
                amountBorrowedFromMarketClass.reportValidity();
                isValid = true;
   
            }
            if (this.inputWrapper['sourceOfMarginMoney'].value === 'BORROWED FROM MARKET' && this.inputWrapper['amountBorrowedFromMarket'].value 
                ) {
                amountBorrowedFromMarketClass.setCustomValidity("");
                amountBorrowedFromMarketClass.reportValidity();
                isValid = true;
   
            }
   
            if (this.inputWrapper['existingImplement'].value && this.inputWrapper['existingImplement'].value.includes('No')) {
                deployAssetWithoutImplementClass.setCustomValidity("Mandatory if 'IS customer HAVING ANY EXISTING IMPLEMENT' is selected as 'No'");
                deployAssetWithoutImplementClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('deployAssetWithoutImplementClass');
   
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
            if(this.flagHarvestorRequired && !this.inputWrapper['brokerDetails'].value){
                brokerDetailsClass.setCustomValidity("Broker Detail for harvestor is requried");
                brokerDetailsClass.reportValidity();
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                this.scrollToElement('brokerDetailsClass');
                return; 
            }else{
                brokerDetailsClass.setCustomValidity("");
                brokerDetailsClass.reportValidity();
            }

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

            if (!this.residenceUpload && (this.borrowerFlag || this.coBorrowerFlag)) {
                await getDocumentRecord({ caseId: this.fiRecordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: this.label.residentFrontView, recordTypeName: this.label.otherDocument })
                        .then(response => {
                            console.log('line 1279', response);
        
                            if (response) {
                                this.residenceUpload = true;
                            }
                            else {
                                this.showToast('Warning!', 'Please Upload Photo of House with front view and inner view.', 'warning', 'dismissable');
                                this.isSpinnerMoving = false;
                                this.SubmitDisabled = false;
                            }
                            console.log('residenceUpload ', this.residenceUpload);
        
                        })
                        .catch(error => {
                            this.isSpinnerMoving = false;
                            this.SubmitDisabled = false;
                            console.log('error 1167', error);
        
                            if (error.body.message) {
                                this.showToast('Error!','Please Upload Document or Please Contact System Administrator', 'error', 'dismissable');
                            } else {
                                this.showToast('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'dismissable');
                            }
                        });
    
            }
        // }
        if (this.coBorrowerFlag) {
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

            if (!this.photoAlongWithUploaded && (this.borrowerFlag || this.coBorrowerFlag)) {
                await getDocumentRecord({ caseId: this.fiRecordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: this.borrowerFlag == true ?'Photo With Borrower':'Photo With Co Borrower', recordTypeName: this.label.otherDocument })
                        .then(response => {
                            console.log('line 1318', response);
        
                            if (response) {
                                this.photoAlongWithUploaded = true;
                            }
                            else {
                                this.showToast('Warning!', `Please Upload Photo With ${this.applicantType}.`, 'warning', 'dismissable');
                                this.isSpinnerMoving = false;
                                this.SubmitDisabled = false;
                            }
                            console.log('photoAlongWithUploaded ', this.photoAlongWithUploaded);
        
                        })
                        .catch(error => {
                            this.isSpinnerMoving = false;
                            this.SubmitDisabled = false;
                            console.log('error 1259', error);
        
                            if (error.body.message) {
                                this.showToast('Error!', 'Please Upload Document or Please Contact System Administrator', 'error', 'dismissable');
                            } else {
                                this.showToast('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'dismissable');
                            }
                        });
            }
            
        // }


        if((!this.residenceUpload || !this.photoAlongWithUploaded) && (this.borrowerFlag || this.coBorrowerFlag)){
            this.isSpinnerMoving = false;
            return;
        }

        // if (this.inputWrapper['currentAddrisDiffKycAddr'].value === 'Yes' && !this.inputWrapper['basicFIAddress'].value) {
        //     basicFIAddressClass.setCustomValidity("Mandatory if Current Address is different than KYC Address is Y");
        //     basicFIAddressClass.reportValidity();
        //     isValid = false;
        //     this.isSpinnerMoving = false;
        //     this.scrollToElement('basicFIAddressClass');
        //     return; // Exit early
        // } else {
        //     basicFIAddressClass.setCustomValidity("");
        //     basicFIAddressClass.reportValidity();

        // }
        // if (this.inputWrapper['currentAddrisDiffKycAddr'].value === 'Yes' && this.inputWrapper['basicFIAddress'].value) {
        //     basicFIAddressClass.setCustomValidity("");
        //     basicFIAddressClass.reportValidity();
        //     isValid = true;

        // }
        if (this.inputWrapper['coborrowerPoliticalRelation'].value === 'Yes' && !this.inputWrapper['politicalRelationRemarks'].value) {
            politicalRelationRemarks.setCustomValidity("Remarks is Required if Political relation is yes");
            politicalRelationRemarks.reportValidity();
            isValid = false;
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            this.scrollToElement('politicalRelationRemarks');
            return; // Exit early
        } else {
            politicalRelationRemarks.setCustomValidity("");
            politicalRelationRemarks.reportValidity();

        }
        if (this.inputWrapper['coborrowerPoliticalRelation'].value === 'Yes' && this.inputWrapper['politicalRelationRemarks'].value) {
            politicalRelationRemarks.setCustomValidity("");
            politicalRelationRemarks.reportValidity();
            isValid = true;
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

        if (!this.validityCheck('.basicloanInformationDetails')) {
            this.showToast('Error!', 'Fill all the Basic Details', 'warning');
            this.isSpinnerMoving = false;
            this.SubmitDisabled = false;
            isValid = false;
            return;
        } else {
            isValid = true;
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
        if (!this.validityCheck('.kccotherLoanInformationClass')) {
            this.showToast('Error!', 'Fill all the FI Information Details', 'warning');
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

      
        if(this.borrowerFlag){ // SFTRAC-531 Added Borrwer check as this component is visibile to borrower only

            //SFTRAC-614 Starts
            let cropDetailsChild = this.template.querySelector('c-l-w-c_-l-o-s_-crop-details');
            if (cropDetailsChild && cropDetailsChild.getRowsCount() > 0) {
                console.log('+++++Child component has at least one row');// Do nothing
            } else {
                this.showToast('Error', 'Please fill Crop Details data', 'Error', 'dismissable');
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                return;
            }
            let totalExpenseDetailsChild = this.template.querySelector('c-l-w-c_-l-o-s_-total-expense-investment-details');
            if (totalExpenseDetailsChild && totalExpenseDetailsChild.getRowsCount() > 0) {
                console.log('+++++Total Expense Child component has at least one row');// Do nothing
            } else {
                this.showToast('Error', 'Please fill Total Expense Investment data', 'Error', 'dismissable');
                isValid = false;
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                return;
            }//SFTRAC-614 Ends
            
            let responseFromCustomerRef =  await this.template.querySelector('c-i-n-d_-l-w-c_-reference-customers').referenceHandler();
            if(responseFromCustomerRef){
                if(responseFromCustomerRef.message != 'Reference Customer Not Available'){
                    this.showToast(responseFromCustomerRef.title, responseFromCustomerRef.message, responseFromCustomerRef.type, 'dismissable');
                }
                
                if(responseFromCustomerRef.type == 'success' || responseFromCustomerRef.message == 'Reference Customer Not Available'){
                    isValid = true;           
                }
                else{
                    isValid = false;
                    this.isSpinnerMoving = false;
                    this.SubmitDisabled = false;
                    return;
                }
            }
        }
        console.log('valid' + isValid + 'front view upload : '+ this.residenceUpload);
        
        let proofFlag = (this.residenceUpload && this.borrowerFlag) || (this.residenceUpload && this.coBorrowerFlag) || (this.guarantorFlag);
        /*
        if(!this.expinvestment){
            this.showToast('Error!', 'Fill all the Expense Invesement Details', 'warning');
            return;
        }
        if(!this.vehicleInfo){
            this.showToast('Error!', 'Fill all the Vehicle details in Loan Information', 'warning');
            return;
        }*/
        if (isValid && proofFlag) {
            // this.isSubmitCalled = true; //SFTRAC-1880 ## NEW Chnages
            await this.saveFIPage(); //SFTRAC-1880
        } else if(!isValid){
            this.isSpinnerMoving = false;
            this.showToast('Please Fill all the required inputs.', '', 'error', 'dismissable');
        }

    }

    //SFTRAC-1880 Start
    async saveFIPage(event){
        // if(this.borrowerFlag){
        //     let responseFromCustomerRef =  await this.template.querySelector('c-i-n-d_-l-w-c_-reference-customers').referenceHandler();
        //     if(responseFromCustomerRef){
        //         if(responseFromCustomerRef.message != 'Reference Customer Not Available'){
        //             this.showToast(responseFromCustomerRef.title, responseFromCustomerRef.message, responseFromCustomerRef.type, 'dismissable');
        //         }
        //     }
        // } ## COmmented as part of SFTRAC-1880 Change Request
        //SFTRAC-1183
        let borrowerFamilyDetails = this.template.querySelector('c-l-w-c_-l-o-s_-borrower-family-details');
        if(borrowerFamilyDetails){
            borrowerFamilyDetails.saveRows();
        }

        console.log('existing--' + this.inputWrapper['existingImplement'].value);
        const fields = {};
        fields['Id'] = this.fiRecordId;
        //SFTRAC-1789 Start
        if(this.isCurrentResidenceRecordType){
            fields['Person_Met__c'] = this.inputWrapper['personMet'].value;
        }
        //SFTRAC-1789 End
        fields['Scheme_Type__c'] = this.inputWrapper['schmType'].value;
        fields['Sub_Scheme_Type__c'] = this.inputWrapper['subschmType'].value;
        fields['Distance_from_Branch_to_customer__c'] = this.inputWrapper['distanceBranchtoCustomer'].value;
        fields['Distance_from_Borrower_to_Co_borrower__c'] = this.inputWrapper['distanceborrowertoCoborrower'].value;

        fields['Current_Addr_is_different_than_KYC_Addr__c'] = this.inputWrapper['currentAddrisDiffKycAddr'].value;
        fields['Number_of_years_in_city_in_years__c'] = this.inputWrapper['numberOfYearsInCity'].value;

        fields['BROKER_DETAILS_FOR_HARVESTER__c'] = this.inputWrapper['brokerDetails'].value;
        fields['ANY_NEGATIVE_OR_CAUTION_PROFILE__c'] = this.inputWrapper['negativeProfile'].value;
        fields['NEGATIVE_OR_CAUTION_Profile_details__c'] = this.inputWrapper['negativeProfileDetails'].value;
        fields['NEAR_BY_POLICE_STATION_NAME__c'] = this.inputWrapper['nearByPoliceStation'].value;
        fields['VILLAGE_DOMINATED_WITH_ANY_COMMUNITY__c'] = this.inputWrapper['communityDominance'].value;
        fields['FI_OBSERVATION_1__c'] = this.inputWrapper['fiObservation'].value;
        fields['Profile_to_Product_Match_1__c'] = this.inputWrapper['profileToProductMatch'].value;
        fields['FI_RESULT__c'] = this.inputWrapper['fiResult'].value;
        fields['IF_NEGATIVE_THEN_REASON_FOR_NEGATIVE__c'] = this.inputWrapper['negativeReason'].value;
        //fields['Residence_FI_completion_time__c'] = this.inputWrapper['fiDateTime'].value;
        fields['Residence_FI_completion_time__c'] = new Date().toISOString();

        fields['FI_Location__Latitude__s'] = this.filattitude;
        fields['FI_Location__Longitude__s'] = this.filongitude;
        fields['Existing_no_of_vehicles__c'] = this.inputWrapper['existingNoofVehicle'].value;

        fields['What_is_the_source_of_margin_money__c'] = this.inputWrapper['sourceOfMarginMoney'].value;
        fields['If_the_source_of_margin_money_is_CASH__c'] = this.inputWrapper['sourceOfMarginMoneyCash'].value;
        fields['WHAT_IS_THE_AMOUNT_BORROWED_FROM_MARKET__c'] = this.inputWrapper['amountBorrowedFromMarket'].value;
        fields['WHAT_IS_THE_TERMS_FOR_PARTNERSHIP__c'] = this.inputWrapper['partnershipTerms'].value;
        fields['IF_EXCHANGE_OF_ASSET__c'] = this.inputWrapper['exchangeOfAsset'].value;
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
        if (this.inputWrapper['deploymentOfAsset'] && Array.isArray(this.inputWrapper['deploymentOfAsset'].value) && this.inputWrapper['deploymentOfAsset'].value.length > 0) {
            fields['DEPLOYMENT_OF_ASSET__c'] = this.inputWrapper['deploymentOfAsset'].value.join(';');
        } else {
            fields['DEPLOYMENT_OF_ASSET__c'] = null;
        }

        fields['IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c'] = this.inputWrapper['majorImpact'].value;

        fields['BORROWER_KNOWN_TO_Gurantor_SINCE__c'] = this.inputWrapper['borrowerKnownToGurantorSince'].value;
        fields['Are_you_ready_for_guarntee_for_this_loan__c'] = this.inputWrapper['readyForGuarantee'].value;
        fields['IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATI__c'] = this.inputWrapper['coborrowerPoliticalRelation'].value; // values not provided in sheet. picklist

        fields['Any_political_relation_Remarks__c'] = this.inputWrapper['politicalRelationRemarks'].value;
        //fields['Basic_FI_address_to_be_populated_in_FI__c'] = this.inputWrapper['basicFIAddress'].value;
        fields['FI_Address_Line_1__c'] = this.inputWrapper['FIAddressLine1'].value;
        fields['FI_Address_Line_2__c'] = this.inputWrapper['FIAddressLine2'].value;
        fields['FI_City__c'] = this.inputWrapper['FICity'].value;
        fields['FI_Pin_Code__c'] = this.inputWrapper['FIPinCode'].value;
        fields['FI_District__c'] = this.inputWrapper['FIDistrict'].value;
        fields['FI_State__c'] = this.inputWrapper['FIState'].value;

        fields['Address_Verified_with_KYC__c'] = this.inputWrapper['originalKYCVerified'].value;
        fields['DocUploaded_if_Current_KYC_Addre_Diff__c'] = this.inputWrapper['docUploadediflKYCCurrentdiff'].value;//SFTRAC-1183
        fields['how_long_he_is_residing_kyc_address__c'] = this.inputWrapper['residingDuration'].value;
        fields['Gender__c'] = this.inputWrapper['gender'].value;
        fields['Caste__c'] = this.inputWrapper['caste'].value;
        fields['Whether_address_is_same_as_FI_done_by_BE__c'] = this.inputWrapper['addressSameAsFIBE'].value;
        fields['Residance_Permanent_Address_are_Same__c'] = this.inputWrapper['residencePermanentAddressSame'].value;
        fields['House_Type__c'] = this.inputWrapper['houseType'].value;
        fields['House_ownership__c'] = this.inputWrapper['houseOwnership'].value;
        fields['How_many_members_in_the_Family__c'] = this.inputWrapper['familyMembers'].value;
        fields['Number_of_Earning_Member_in_Family__c'] = this.inputWrapper['earningMembers'].value;
        fields['Borrower_Having_Valid_Driving_licence__c'] = this.inputWrapper['validDrivingLicense'].value;

        if (this.inputWrapper['assetsAtHome'] && Array.isArray(this.inputWrapper['assetsAtHome'].value) && this.inputWrapper['assetsAtHome'].value.length > 0) {
            fields['Assets_at_Home_Sum_up__c'] = this.inputWrapper['assetsAtHome'].value.join(';');
        } else {
            fields['Assets_at_Home_Sum_up__c'] = null;
        }

        fields['Land_by_Borrower_in_Acres_with_proof__c'] = this.inputWrapper['landHolding'].value; // data type not explained

        if (this.inputWrapper['landIrrigationSource'] && Array.isArray(this.inputWrapper['landIrrigationSource'].value) && this.inputWrapper['landIrrigationSource'].value.length > 0) {
            fields['Land_Irrigation_source__c'] = this.inputWrapper['landIrrigationSource'].value.join(';');
        } else {
            fields['Land_Irrigation_source__c'] = null;
        }

        fields['Approximate_Value_of_Agri_land__c'] = this.inputWrapper['approxValueOfAgriLand'].value;
        fields['Crop_details_cultivated_last_year__c'] = this.inputWrapper['cropDetailsLastYear'].value;
        fields['Current_cropping_pattern_details__c'] = this.inputWrapper['currentCroppingPattern'].value;
        fields['Crop_sold_to_any_specific_person__c'] = this.inputWrapper['cropSoldToSpecificPerson'].value;
        fields['Sold_to_Contact_details__c'] = this.inputWrapper['soldToContactDetails'].value;

        fields['No_of_Cattle__c'] = this.inputWrapper['numberOfCattle'].value;

        if (this.inputWrapper['agriCommercial'] && Array.isArray(this.inputWrapper['agriCommercial'].value) && this.inputWrapper['agriCommercial'].value.length > 0) {
            fields['Agri_Commercial__c'] = this.inputWrapper['agriCommercial'].value.join(';');
        } else {
            fields['Agri_Commercial__c'] = null;
        }

        fields['Since_how_long_in_Agri_commercial__c'] = this.inputWrapper['sinceHowLongAgriCommercial'].value;
        fields['IN_LAST_5_YEARS_ANY_DRAUGHTFlood__c'] = this.inputWrapper['droughtOrFlood'].value;
        fields['If_yes_provide_details_of_damage__c'] = this.inputWrapper['droughtOrFloodDetails'].value;
        fields['Work_order_details__c'] = this.inputWrapper['workOrderDetails'].value;
        fields['Other_source_of_Income__c'] = this.inputWrapper['otherSourceOfIncome'].value;
        //SFTRAC-1183 Starts
        fields['ITR_1__c'] = this.inputWrapper['itr1'].value;
        fields['ITR_2__c'] = this.inputWrapper['itr2'].value;
        fields['ITR_3__c'] = this.inputWrapper['itr3'].value;
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

        const recordInput = {
            fields
        };

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
                    const recordInput = {
                        fields
                    };
                    updateRecord(recordInput).then(result=>{
                        if(result){
                            try {
                                this.isDisabled = true;
                                this.loanInfoTableDisabled = true; //SFTRAC-1880 New
                                this.SubmitDisabled = true;
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
                            } catch (error) {
                                this.showToast('Error!', 'Something went wrong!', 'error', 'sticky');
                                this.isSpinnerMoving = false;
                            }
                        }
                    }).catch(error=>{
                        this.showToast('Error!', 'Something went wrong!', 'error', 'sticky');
                        this.SubmitDisabled = false;
                        this.isSpinnerMoving = false;
                    });
                    }else{
                        helper.onSaveFI(this); //SFTRAC-1880 New
                    }
                }
            }).catch((error) => {
                console.log('Error' + JSON.stringify(error));
                this.isSpinnerMoving = false;
                this.SubmitDisabled = false;
                if (error.body.message) {
                    this.showToast('Error!', error.body.message, 'error', 'sticky');
                } else {
                    this.showToast('Error!', 'Currently server is down, Please contact System Administrator', 'error', 'sticky');
                }
            });
    }
    //SFTRAC-1880 End

    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }
    @track showFileUploadAndView = false; //SFTRAC-1183
    viewUploadViewFloater(){this.showFileUploadAndView = true;} //SFTRAC-1183
    closeUploadViewFloater(event){this.showFileUploadAndView = false;
        const documentRecordId = event.detail;console.log('+++++closeUploadViewFloater '+documentRecordId+ ' field value '+this.inputWrapper['docUploadediflKYCCurrentdiff'].value);
        if(documentRecordId != null && this.inputWrapper['docUploadediflKYCCurrentdiff'].value == false){
            this.inputWrapper['docUploadediflKYCCurrentdiff'].value = true;
            const fields = {};
            fields['Id'] = this.fiRecordId; // update case record
            fields['DocUploaded_if_Current_KYC_Addre_Diff__c'] = true;
            const recordInput = {fields};
            updateRecord(recordInput).then(() => { console.log('Updated'); }).catch((error) => { console.log('record update fail in catch'); });
        }
    }//SFTRAC-1183
    expInvHandler(event){
        this.expinvestment = event.detail;
    }
    vehicleInfoHandler(event){
        console.log('Parent evt-',event.detail);
        this.vehicleInfo = event.detail;
    }
    // Helper function to validate if a value is within a specified range
    validateRange(min, max, value) {
        return parseFloat(value) >= min && parseFloat(value) <= max;
    }
    handleCaptureFrontViewUplaod() {
        
        this.documentType = this.label.residentFrontView;
        console.log('ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.documentType + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId +  '&documentSide=Front' + '&caseID' + '=' + this.recordId + '&loanApplicationId=' +  this.applicationId + '&documentRecordTypeId=' +  this.otherDocRecordTypeId);
        //if (FORM_FACTOR === 'Large') {
            this.isSpinnerMoving = true;
            helper.createDocument(this.label.residentFrontView, this.label.otherDocument, this);
        /*} else {
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.documentType + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId +  '&documentSide=Front' + '&caseID' + '=' + this.recordId + '&loanApplicationId=' +  this.applicationId + '&documentRecordTypeId=' +  this.otherDocRecordTypeId
                }
            });
        }*/
    }

    handleCapturePhotoAlongwithBorrower(){
        console.log('integrator details appid1: ', this.applicantId, ' usrid ' + this.currentUserId + ' usname ' + this.currentUserName + ' usemail ' + this.currentUserEmailId);
        this.documentType = this.borrowerFlag==true?'Photo With Borrower':'Photo With Co Borrower';
        console.log('ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.documentType + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId +  '&documentSide=Front' + '&caseID' + '=' + this.recordId + '&loanApplicationId=' +  this.applicationId + '&documentRecordTypeId=' +  this.otherDocRecordTypeId);
        //if (FORM_FACTOR === 'Large') {
            this.isSpinnerMoving = true;
            helper.createDocument(this.documentType, this.label.otherDocument, this);
        /*} else {
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.documentType + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId +  '&documentSide=Front' + '&caseID' + '=' + this.recordId + '&loanApplicationId=' +  this.applicationId + '&documentRecordTypeId=' +  this.otherDocRecordTypeId
                }
            });
        }*/
    }

    docDeleted() { this.documentId = null; }
    functionality;
    
    async changeflagvalue(event) {
        this.uploadViewDocFlag = false;
        this.viewDocFlag = false;
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

        // if (event.detail.contentDocumentId != null && event.detail.backcontentDocumentId != null) {
        //     const evt = new ShowToastEvent({
        //         title: "All uploaded!",
        //         variant: 'success',
        //     });
        //     this.dispatchEvent(evt);

        // }


        if (event.detail && event.detail.contentDocumentId != null && event.detail.backcontentDocumentId != null) {
            const evt = new ShowToastEvent({
                title: "All uploaded!",
                variant: 'success',
            });
            this.dispatchEvent(evt);
        }
    }

    refreshchildComponents(event){
        this.template.querySelectorAll('c-l-w-c_-l-o-s_-crop-details').forEach(ele=>{
            ele.refreshChildData();
        });
    }
}