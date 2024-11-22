import { LightningElement, track, api, wire } from 'lwc';       
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'; 
import { getRecord } from 'lightning/uiRecordApi';
import AssetDetailsSaved from '@salesforce/label/c.AssetDetailsSaved';
import getDealerSubDealerDetails from '@salesforce/apex/IND_AssetDetailsCntrl.getDealerSubDealerDetails';
import changeStage from '@salesforce/apex/IND_AssetDetailsCntrl.changeStage';
import validateVehicleRecords from '@salesforce/apex/IND_AssetDetailsCntrl.validateVehicleRecords';
import loadAssetDetailsData from '@salesforce/apex/IND_AssetDetailsCntrl.loadAssetDetailsData';
import getMakeList from '@salesforce/apex/IND_AssetDetailsCntrl.getMakeList';
import getRelatedModelList from '@salesforce/apex/IND_AssetDetailsCntrl.getRelatedModelList'; 
import getMakeListTractor from '@salesforce/apex/Utilities.getMakeList';
import getRelatedModelListTractor from '@salesforce/apex/Utilities.getRelatedModelList'; 
import getRelatedVariantList from '@salesforce/apex/IND_AssetDetailsCntrl.getRelatedVariantList';
import getRelatedVariantListTractor from '@salesforce/apex/Utilities.getRelatedVariantList';
import getDealerSubDealerDetailsTractor from '@salesforce/apex/Utilities.getDealerSubDealerDetails';
import getDelayTime from '@salesforce/apex/IND_AssetDetailsCntrl.getDelayTime';
import validateDVehicleCategory from '@salesforce/apex/IND_AssetDetailsCntrl.validateDVehicleCategory';
import getMMVNameBasedOnCode from '@salesforce/apex/IND_AssetDetailsCntrl.getMMVNameBasedOnCode';
import createRecordUsingApex from '@salesforce/apex/IND_AssetDetailsCntrl.createRecordUsingApex';
import updateVehicleRecords from '@salesforce/apex/IND_AssetDetailsCntrl.updateVehicleRecords';
import doVahanVehicleValuationCallout from '@salesforce/apexContinuation/IntegrationEngine.doVahanVehicleValuationCallout';
import doDealEligibleRefinanceCallout from '@salesforce/apexContinuation/IntegrationEngine.doDealEligibleRefinanceCallout';
import doDealMasterCallout from '@salesforce/apexContinuation/IntegrationEngine.doDealMasterCallout';
import doDealMasterCalloutForCustomerName from '@salesforce/apexContinuation/IntegrationEngine.doDealMasterCalloutForCustomerName';
import doVahanVehicleReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doVahanVehicleReportCallout';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import IS_GET_VEHICLE_DETAILS_SUCCESSFUL_FIELD from '@salesforce/schema/Vehicle_Detail__c.Is_Get_Vehicle_Details_Successful__c';
import VEHICLE_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_type__c';
import PRODUCT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Product__c';
import VEHICLE_REG_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Registration_number__c';
import LOAN_APPLICATION from '@salesforce/schema/Vehicle_Detail__c.Loan_Application__c';
import LOAN_NUMBER from '@salesforce/schema/Vehicle_Detail__c.Loan_Number__c';
import VEHICLE_DETAIL from '@salesforce/schema/Vehicle_Detail__c';
import ELIGIBLE_LOAN_AMT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Eligible_Loan_Amount__c';
import ELIGIBLE_TENURE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Eligible_Tenure__c';
import VEHICLE_ID_FIELD from '@salesforce/schema/Vehicle_Detail__c.Id';
import MAKE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Make__c';
import MAKE_CODE from '@salesforce/schema/Vehicle_Detail__c.Make_Code__c';//CISP-2794
import MODEL_FIELD from '@salesforce/schema/Vehicle_Detail__c.Model__c';
import MODEL_CODE from '@salesforce/schema/Vehicle_Detail__c.Model_Code__c';//CISP-2794
import VARIANT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Variant__c';
import VARIANT_CODE from '@salesforce/schema/Vehicle_Detail__c.Variant_Code__c';//CISP-2794
import PRODUCT_SEGMENT from '@salesforce/schema/Vehicle_Detail__c.Product_Segment__c';//CISP-13665
import INVOICE_IN_THE_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Invoice_in_the_name_of__c';
import USAGE_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Usage_Type__c';
import PURPOSE_OF_PURCHANSE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Purpose_of_purchase__c';
import VEHICLE_REGISTERED_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_registered_in_the_name_of__c';
import MANUFACTURER_YEAR_MONTH_FIELD from '@salesforce/schema/Vehicle_Detail__c.Manufacturer_Year_Month__c';
import LIEN_IN_FAVOR_FIELD from '@salesforce/schema/Vehicle_Detail__c.Lien_in_favor_of__c';
import RC_RETENTION_APPLICABLE_FIELD from '@salesforce/schema/Vehicle_Detail__c.RC_retention_applicable__c';
import NUMBER_OF_OWNERSHIP_FIELD from '@salesforce/schema/Vehicle_Detail__c.Number_of_ownerships__c';
import DEALER_SUBDEALER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Dealer_Sub_dealer_name__c';
import BEN_CODE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ben_Code__c';
import ENGINE_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Engine_number__c';
import LAST_OWNER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Last_owner_name__c';
import CHASSIS_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Chassis_number__c';
import INSURER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurer_name__c';
import INSURANCE_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_number__c';
import INS_ISSUANCE_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Issuance_date__c';
import INS_EXPIRY_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Expiry_date__c';
import OWNER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Owner_Name__c';
import OWNER_CONTACT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Owner_Contact_Number__c';
import VEHICLE_PLACE_VALUATION_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Place_Of_Valuation__c';
import IS_D_CATEGORY_VEHICLE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Is_D_Category_Vehicle__c';
import RefinanceLabel from '@salesforce/label/c.Refinance';
import EngineNo_Regex from '@salesforce/label/c.EngineNo_Regex';
import ChassisNo_Regex from '@salesforce/label/c.ChassisNo_Regex';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import lastNameError from '@salesforce/label/c.Last_Name_Error';
import NameError from '@salesforce/label/c.Name_Error';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import checkRCLimitBasedOnBencode from '@salesforce/apex/IND_AssetDetailsCntrl.checkRCLimitBasedOnBencode';//CISP-8762
import RC_limit_enabled_Dealer from '@salesforce/schema/Vehicle_Detail__c.RC_limit_enabled_Dealer__c';//CISP-8762
import RC_HOLD_AMOUNT_FIELD from '@salesforce/schema/Vehicle_Detail__c.RC_Hold_Amount__c'; //SFTRAC-1715
import manufacturingDateAndYearDecoder from '@salesforce/apex/Utilities.manufacturingDateAndYearDecoder';
import createCaseAVRecords from '@salesforce/apex/LWCLOSAssetVerificationCntrl.createCaseAVRecords';
import * as helper from './LWC_LOS_getAssetDetailsHelper';
//added for commercial vehicle pv
import DISTANCE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Distance__c';
import GROSS_RECEIPTS_MONTH_FIELD from '@salesforce/schema/Vehicle_Detail__c.Gross_Receipts_Month__c';
import NUMBER_OF_VEHICLE_OWNED_FIELD from '@salesforce/schema/Vehicle_Detail__c.Number_of_vehicle_owned__c';
import EXPENSE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Expense__c';
import VEHICLE_ROUTE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Route__c';
import ROUTE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Route__c';

export default class LWC_LOS_getAssetDetails extends NavigationMixin(LightningElement) {
    manufacturerYearAndMonthFromAPI = '';@track isRcLimitChecked = false; @track isPVUsedAndRefinance = false;//CISP-8762
    leadSource;//CISP-3705
    parentLeadId;//CISP-3705
    parentLeadSource; //CISP-3705
    @track leadCreatedDate;//CISP-3431
    @track mmvDisable = false;//CISP-3425
    @track makeCodeOfProduct;//CISP-2794
    @track modelCodeOfProduct;//CISP-2794
    @track variantCodeOfProduct//CISP-2794
    @api recordid;@api applicantId;@api activeTab;@api currentStage;
    //prashanth
    @api isD2cApplication;
    @api isRevokedLoanApplication;
    d2cMMVDisable = false;//CISP-4633
    @track dealerBenCode; //CISP-2353
    @api checkleadaccess;//coming from tabloanApplication
    @track showPopupModal = false;
    @track index;
    @track showSpinner = true;
    @track modalMsg;
    @track vaahanAPIRetryCount = 0;
    @track dealMasterAPIRetryCount = 0;
    @track isEnableNext = false;
    @track isGetVehicleDetailsSuccessful = false;
    @track isDCategoryVehicle = false;
    @track disableGetVehicleDetails = false;
    @track displayUsedVehicleTypeFields = false;
    @track showVahanDetailsSection = false;
    @track showSuccessTick = false;
    @track showFailureTick = false;
    @track allowSubmit = true;
    @track vehicleType;
    @track dealNumber;
    @track chassisNumber;
    @track engineNumber;
    @track lastOwnerName;
    @track manufacturerYearAndMonth;
    @track vehicleRegNoValue;
    @track vehicleRegisteredInNameOf;
    @track invoiceInNameOf;
    @track product;
    @track makeId;
    @track modelId;
    @track vehicleDetailId;
    @track delaytime;
    @track leadNumber;
    @track eligibilityLoanAmount;
    @track tenureInMonths;
    @track vehicleCategory;
    @track isDCategoryAsset;
    @track allFieldsDisabled = false;
    @track isDisabledSubmit = false;
    @track lastStage;
    @track currentStageName;
    @track agentBLCode;

    //API OR MASTER BASED COMBOBOX VALUE FIELDS
    @track make;
    @track model;
    @track variant;
    @track dealerSubDealerName;
    @track segmentCode; //CISP-13665

    //PICKLIST VALUE FIELDS
    @track purposeOfPurchaseOptionsList = [];
    @track vehicleRegisteredInNameOfOptionsList = [];
    @track usageTypeOptionsList = [];
    @track lienInFavorOfOptionsList = [];
    @track rcRetentionOptionsList = [];
    @track usageTypeOptionsListTractor = [];
    @track rcRetentionOptionsListTractor = [];
    @track numberOfOwnershipsOptionsList = [];
    @track purposeOfPurchase;
    @track vehicleRegisteredInNameOf;
    @track usageType;
    @track lienInFavorOf;
    @track rcRetentionApplicable;
    @track numberOfOwnerships;

    //API OR MASTER BASED COMBOBOX FIELDS
    @track makeOptionsList = [];
    @track modelOptionsList = [];
    @track variantOptionsList = [];
    @track dealerSubDealerOptionsList = [];

    @track isEnableUploadViewDoc = true;
    @track showFileUploadAndView = false;
    @track insExpiryDate;
    @track fromHome=false;
    @track leadSource;//DSA//Ola Integration changes
    @track invoiceNameDisabled = false;
    @track isDealerFieldMandatory = false;
    @track isDealerFieldDisabled = true;
    aggregatorSource = '';
    @track isTractor = false;
    @track assetDetailList = [];
    @track assetCaseCreated = false;
    @track disableFieldsForRefinance = false;
    @track showViabilitySection = false;
    @track distance; //commercial vehicle pv
    @track grossReceipts; // commercial vehicle pv
    @track numberOfVehicles; //commercial vehicle pv
    @track expense; //commercial vehicle pv
    @track vehicleRoute = 'Intra State'; // commercial vehicle pv
    @track route = ''; //commercial vehicle pv
    @track routeOptions = [
        { label: 'Ola/Uber', value: 'Ola/Uber' },
        { label: 'Market Load', value: 'Market Load' },
        { label: 'Staff transportation', value: 'Staff transportation' },
        { label: 'Private Taxi', value: 'Private Taxi' },
        { label: 'Airport Taxi', value: 'Airport Taxi' },
        { label: 'Open market taxi', value: 'Open market taxi' }
    ];

    labels = {
        AssetDetailsSaved, RefinanceLabel, EngineNo_Regex, ChassisNo_Regex, lastNameError, RegEx_Alphabets_Only, NameError
    }
    get makeOptions() {return this.makeOptionsList;}
    get modelOptions() {return this.modelOptionsList;}
    get variantOptions() {return this.variantOptionsList;}
    get dealerSubDealerOptions() {return this.dealerSubDealerOptionsList;}
    //CISP-4633
    get disableMMVOverall() {return this.allFieldsDisabled || this.d2cMMVDisable;}
    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    async connectedCallback() {
        console.log('Record Id:: ', this.recordid);
        this.showSpinner = true;//CISP-519
        await this.init();
    }
    handleOnfinish(event) {
        const evnts = new CustomEvent('vehicleinsurance', { detail: event });
        this.dispatchEvent(evnts);
    }
    renderedCallback() {
        if (this.currentStage === 'Credit Processing' || this.currentStageName === 'Loan Initiation' || this.currentStageName === 'Additional Details' || (this.currentStageName != undefined && this.currentStageName !== 'Asset Details' && this.lastStage != undefined && this.lastStage !== 'Asset Details')) {//CISP-519
            this.disableEverything();
            console.log('here 1');
            if (this.currentStage === 'Credit Processing'){
                this.isEnableNext = true;
                if (this.template.querySelector('.next')) {this.template.querySelector('.next').disabled = false;}
            }this.showSpinner=false;//CISP-519
        }
        //prashanth
        if(this.isD2cApplication && this.currentStageName !== undefined && this.currentStageName != 'Asset Details' && this.lastStage != 'Asset Details'){
            console.log('enetered d2c-->');
            this.disableEverything();}
        if(this.leadSource == 'OLA' && this.currentStageName == 'Asset Details'){
            this.template.querySelector("[data-id='invoicename']").disabled = false; //OLA-119
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    async getMakeListForManualInputTractor(item) {
        await getMakeListTractor({}).then(response => {
            item.makeOptionsList = response;
        }).catch(error => {
            console.log('Error in getting Make:: ', error);
            item.makeOptionsList = [];
        });
    }
    async getModelListForManualInputTractor(index) {
        let assetDetail = this.assetDetailList[index];
        await getRelatedModelListTractor({ sMake: assetDetail.makeCodeOfProduct, vehicleSubType: assetDetail.vehicleSubType}).then(response => {
            assetDetail.modelOptionsList = response;
        }).catch(error => {
            console.log('Error in getting related Model:: ', error);
            assetDetail.modelOptionsList = [];
        });
    }
    async fetchDealerSubDealerTractor(index) {
        let assetDetail = this.assetDetailList[index];
        if (assetDetail.agentBLCode !== null && assetDetail.model !== null) {
            await getDealerSubDealerDetailsTractor({ sModelName: assetDetail.model , sBLCode: assetDetail.agentBLCode , loanApplicationId : this.recordid, vehicleSubCategory : assetDetail.vehicleSubCategory }).then(result => {
                const obj = JSON.parse(result);
                if (obj.length === 0) {
                    if(!assetDetail.isDealerFieldDisabled && assetDetail.leadSource != 'D2C'){//D2C Change
                        this.showToastMessage('Dealer/SubDealer is not available for selected Model (' + assetDetail.model + ')', 'Please contact System Administrator', 'error');
                    }
                    this.showSpinner = false;// CISP-2621
                } else {
                    assetDetail.dealerSubDealerOptionsList = obj.map(function (obj) {
                        return { label: obj.Ben_code__r.Name + ' | '+ obj.Ben_code__r.Ben_code__c , value: obj.Ben_code__r.Name + ' | '+ obj.Ben_code__r.Ben_code__c };
                    });
                }
            }).catch(error => {
                this.showToastMessage('Error in fetching Dealer/SubDealer', 'Please contact System Administrator', 'error');
                console.log('getDealerSubDealerDetails - error:: ', error);
            });
        } else {getRelatedVariantListTractor
            this.showToastMessage('Missing Agent BL code or Model value', 'Please contact System Administrator', 'error');
        }
    }
    async getVariantListForManualInputTractor(index) {
        let assetDetail = this.assetDetailList[index];
        await getRelatedVariantListTractor({ sModel: assetDetail.modelCodeOfProduct,loanApplicationId:this.recordid}).then(response => {
            assetDetail.variantOptionsList = response.map(function (obj) {
                return { label: obj.Name, value: obj.Variant_Code__c };//CISP-2794
            });
        }).catch(error => {
            console.log('Error in getting related Variant:: ', error);
        });
    }
    //Deal Master API
    async executeDealMasterAPITractor(scope, item, index) {
        try {
            this.manufacturerYearAndMonthFromAPI = '';let isDealMasterAPISuccessful = false;let dealMasterResponse;let skipMMVUpdateFlag = false;
            if (scope === 'VehicleDetails' && item.make && item.model && item.variant) {
                skipMMVUpdateFlag = true;
            }
            //API Call
            await this.dealMasterAPICallTractor(item).then(result => {
                isDealMasterAPISuccessful = result.isSuccessful;dealMasterResponse = result.response;
            }).catch(error => {
                console.log('Deal Master Callout - Error:: ' + error);
            });
            if (isDealMasterAPISuccessful === true) {
                if (!skipMMVUpdateFlag) {
                    let makeCode = dealMasterResponse?.response.content[0]?.Make;let modelCode = dealMasterResponse?.response.content[0]?.Model;
                    let variantCode = dealMasterResponse?.response.content[0]?.Variant;
                    if(dealMasterResponse?.response.content[0]?.Manufacture_Year_Month != ''){this.manufacturerYearAndMonthFromAPI = dealMasterResponse?.response.content[0]?.Manufacture_Year_Month;}//SFTRAC-1780
                     //CISP-2794
                    item.makeCodeOfProduct = makeCode;item.modelCodeOfProduct = modelCode;item.variantCodeOfProduct = variantCode;
                    await getMMVNameBasedOnCode({ makeCode: makeCode, modelCode: modelCode, variantCode: variantCode }).then(response => {
                        let mmvResponse = JSON.parse(response);
                        //Update MMV Fields with the MMV Name
                        item.make = mmvResponse.vehicleMake;item.model = mmvResponse.vehicleModel;item.variant = mmvResponse.vehicleVarient;
                        if (item.make === null) {
                            item.showToastMessage('Make Master is not available', 'Please contact System Administrator', 'error');}
                        if (item.model === null) {
                            item.showToastMessage('Model Master is not available', 'Please contact System Administrator', 'error');}
                        if (item.variant === null) {
                            item.showToastMessage('Variant Master is not available', 'Please contact System Administrator', 'error');}
                        if (item.make && item.model && item.variant) {
                            item.makeOptionsList = [{ label: item.make, value: item.makeCodeOfProduct }];//CISP-2794
                            item.modelOptionsList = [{ label: item.model, value: item.modelCodeOfProduct }];//CISP-2794
                            item.variantOptionsList = [{ label: item.variant, value: item.variantCodeOfProduct }];//CISP-2794
                        }
                        this.fetchDealerSubDealerTractor(index);
                    }).catch(error => {
                        console.log('Error - getMMVNameBasedOnCode: ', error);
                    });
                }
                if (!item.engineNumber) {item.engineNumber = dealMasterResponse?.response.content[0]?.Engine_Number;}
                if (!item.chassisNumber) {item.chassisNumber = dealMasterResponse?.response.content[0]?.Chassis_Number;
                    this.handleOnFocusoutOutTractor(null, index);}
                if (!item.lastOwnerName) {item.lastOwnerName = dealMasterResponse?.response.content[0]?.Owner_Name;}
                if (!item.numberOfOwnerships) {
                    let noOfOwnership = dealMasterResponse?.response.content[0]?.No_of_Ownership;
                    if (noOfOwnership) {
                        item.numberOfOwnershipsOptionsList.forEach((obj) => {
                            if (obj.value === noOfOwnership) {
                                item.numberOfOwnerships = noOfOwnership;
                                return true;
                            }
                        });
                    }
                }
                //Insurance fields - Future module fields
                if (!item.insExpiryDate) {item.insExpiryDate = dealMasterResponse?.response.content[0]?.Ins_Expiry_Date;}
                if (!item.insIssuanceDate) {item.insIssuanceDate = dealMasterResponse?.response.content[0]?.Ins_Issuance_Date;}
                if (!item.insurancNumber) {item.insurancNumber = dealMasterResponse?.response.content[0]?.Insurance_Number;}
                if (!item.insurerName) {item.insurerName = dealMasterResponse?.response.content[0]?.Insurer_Name;}
                //Future module fields
                if (!item.ownerContactNumber) {item.ownerContactNumber = dealMasterResponse?.response.content[0]?.Owner_Contact_Number;}
                if (!item.vehiclePlaceOfValuation) {item.vehiclePlaceOfValuation = dealMasterResponse?.response.content[0]?.Vehicle_Place_of_Valuation;}
                this.showToastMessage(null, 'Successfully fetched Vehicle Details from Deal Master API', 'Success');
            } else {
                throw 'Deal Master API Error';
            }
        } catch (error) {
            console.log('Error in Proccessing Deal Master API Response');
            ++item.dealMasterAPIRetryCount;this.showSpinner = false;
            if (item.dealMasterAPIRetryCount < 4) {
                this.modalMsg = 'Error is fetching details from Deal Master API, Kindly Retry<br/>Retry Count:: ' + item.dealMasterAPIRetryCount;
            } else {
                this.modalMsg = 'Retry attempt exhausted, Kindly enter manually';
            }
            if (scope === 'MMV') {
                item.make = null;item.model = null;item.variant = null;item.dealerSubDealerName = null;item.makeOptionsList = null;
                item.modelOptionsList = null;item.variantOptionsList = null;item.dealerSubDealerOptionsList = null;
                this.showToastMessageModeBased('Journey cannot proceed as MMV details are not populated', 'Kindy retry by clicking on Get Vehicle Details button', 'error', 'sticky');
            }
            return;
        }
    }
    //Deal Master API Call
    async dealMasterAPICallTractor(item) {
        let apiStatus = { 'isSuccessful': false, 'response': null };
        await doDealMasterCalloutForCustomerName({ dealNumber: item.dealNumber, loanAppId: this.recordid }).then(result => {
            const obj = JSON.parse(result);
            if (obj.response.status === 'SUCCESS') {apiStatus.isSuccessful = true;apiStatus.response = obj;
            } else {apiStatus.isSuccessful = false;apiStatus.response = 'Deal Master API failed';}
        }).catch(error => {
            apiStatus.isSuccessful = false;
            apiStatus.response = 'Error in executing Deal Master API - ' + error;
        });
        return apiStatus;
    }
    async handleGetVehicleDetailsTractor(event) {
        try{
        this.showSpinner = true;let assetDetail = this.assetDetailList[event.target.dataset.index];
        let inputValid = await this.validityCheck(`lightning-input[data-index="${event.target.dataset.index}"]`);  
        let comboValid = await this.validityCheck(`lightning-combobox[data-index="${event.target.dataset.index}"]`);  
        if (!inputValid || !comboValid) {
            this.showSpinner = false;
            this.showToastMessage('Fill all the fields', null, 'warning');
            return;
        }
        this.handleOnFocusoutOutTractor(null,event?.target?.dataset?.index);
        //Vaahan API
        if ((assetDetail.vaahanAPIRetryCount < 2 && assetDetail.dealNumber) || (assetDetail.vaahanAPIRetryCount < 1 && assetDetail.dealNumber === null)) {
            await this.executeVaahanAPIsTractor(assetDetail, event.target.dataset.index);
        } else {
            if (assetDetail.dealNumber === null || assetDetail.dealNumber === '') {assetDetail.disableGetVehicleDetails = true;}}
        //Deal Master API
        if (assetDetail.dealMasterAPIRetryCount < 4 && assetDetail.dealNumber) {
            await this.executeDealMasterAPITractor('VehicleDetails', assetDetail, event.target.dataset.index);} else {
            assetDetail.disableGetVehicleDetails = true;}
        await this.executeEligibleRefinanceAPITractor(assetDetail);
        assetDetail.showVahanDetailsSection = true;assetDetail.isGetVehicleDetailsSuccessful = true;assetDetail.allowSubmit = true;this.showSpinner = false;
        }catch(error){
            this.showSpinner = false;
            console.log(error);
        }
    }
    async executeVaahanAPIsTractor(assetDetail, index) {
        let vahanRequest = {'leadId': assetDetail.leadNumber,'vehicleRegisterationNumber': assetDetail.vehicleRegNoValue,'loanApplicationId': this.recordid};
        //1.1 Vaahan API
        await doVahanVehicleValuationCallout({ 'vahanVehicleValuation': JSON.stringify(vahanRequest) }).then(result => {
            const obj = JSON.parse(result);
            console.log('Vahan API Response - Parsed Result:: ', obj);
            if (obj.response.status === 'SUCCESS') {
                this.showToastMessage(null, obj.response.respDesc, 'Success');} else {
                throw 'Vaahan API Error';}
        }).catch(error => {
            console.log('Vaahan API Error:: ', error);
            ++assetDetail.vaahanAPIRetryCount;this.showSpinner = false;
            if (assetDetail.vaahanAPIRetryCount > 1) {
                this.modalMsg = 'Error is fetching details from Vaahan API again, Details will be fetched from Deal Master API now';
            } else if (assetDetail.dealNumber === null || assetDetail.dealNumber === '') {
                this.modalMsg = 'Kindly fill details manually';} else {
                this.modalMsg = 'Error is fetching details from Vaahan API, Kindly Retry';}
            //this.showPopupModal = true;
            throw new Error('Error in Vaahan API. Explicitly aborted to prevent Async execution, Retry Count:: ', this.vaahanAPIRetryCount);
        });
        await getDelayTime().then(resultOfDelayTime => {
            assetDetail.delaytime = resultOfDelayTime;
            console.log('this.delaytime:: ', assetDetail.delaytime);
            this.showToastMessage(null, 'Processing may take several minutes', 'info');
        }).catch(error => {
            console.log('Error in Get time Delay:: ', error);
            this.showSpinner = false;
            return;
        });
        let promise = new Promise((resolve, reject) => {
            setTimeout(() => resolve('Execute Report API'), assetDetail.delaytime);
        });
        if (await promise) {
            let vahanReportRequest = {
                'leadId': assetDetail.leadNumber,
                'vehicleRegisterationNumber': assetDetail.vehicleRegNoValue,
                'loanApplicationId': this.recordid
            };
            //1.2 Vaahan Report API
            await doVahanVehicleReportCallout({ 'vahanVehicleReport': JSON.stringify(vahanReportRequest) }).then(result => {
                const obj = JSON.parse(result);
                console.log('Vehicle Report API:: ', obj);
                if (obj.response.status === 'SUCCESS') {
                    if (obj.response?.content[0]?.Owner_Name) {assetDetail.lastOwnerName = obj.response?.content[0]?.Owner_Name;}
                    if (obj.response?.content[0]?.Engine_No) {assetDetail.engineNumber = obj.response?.content[0]?.Engine_No;}
                    if (obj.response?.content[0]?.Chassis_No) {assetDetail.chassisNumber = obj.response?.content[0]?.Chassis_No;
                        this.handleOnFocusoutOutTractor(null, index);}
                    if (obj.response?.content[0]?.Ins_Expiry_Date) {assetDetail.insExpiryDate = obj.response?.content[0]?.Ins_Expiry_Date;}
                    if (assetDetail.insExpiryDate) {assetDetail.insExpiryDate = assetDetail.insExpiryDate.substring(assetDetail.insExpiryDate.lastIndexOf(" ") + 1);}                    
                    if (obj.response?.content[0]?.Ins_Issuance_Date) { assetDetail.insIssuanceDate = obj.response?.content[0]?.Ins_Issuance_Date;}
                    if (obj.response?.content[0]?.Insurance_Number) {assetDetail.insurancNumber = obj.response?.content[0]?.Insurance_Number;}
                    if (obj.response?.content[0]?.Insurer_Name) {assetDetail.insurerName = obj.response?.content[0]?.Insurer_Name;}
                    //SFTRAC-2028 Start
                    if(obj.response?.content[0]?.Fitness_Upto){
                        assetDetail.fitnessUpto = helper.getDateTimeValue(obj.response?.content[0]?.Fitness_Upto);
                    }
                    if(obj.response?.content[0]?.Registration_Date){
                        assetDetail.registrationDt = helper.getDateTimeValue(obj.response?.content[0]?.Registration_Date);
                    }
                    if(obj.response?.content[0]?.Dealer){
                        assetDetail.dealer = obj.response?.content[0]?.Dealer;
                    }
                    if(obj.response?.content[0]?.Body_Type){
                        assetDetail.bodyType = obj.response?.content[0]?.Body_Type;
                    }
                    if(obj.response?.content[0]?.Owner_Sr_No){
                        assetDetail.ownerSrNo = obj.response?.content[0]?.Owner_Sr_No;
                    }
                    if(obj.response?.content[0]?.Manufacturer){
                        assetDetail.manufacturer = obj.response?.content[0]?.Manufacturer;
                    }
                    if(obj.response?.content[0]?.Maker_Model){
                        assetDetail.makerModel = obj.response?.content[0]?.Maker_Model;
                    }
                    if(obj.response?.content[0]?.Father_name){
                        assetDetail.fatherName = obj.response?.content[0]?.Father_name;
                    }
                    if(obj.response?.content[0]?.Present_Address1){
                        assetDetail.presentAddress = obj.response?.content[0]?.Present_Address1;
                    }
                    if(obj.response?.content[0]?.Financier_Name){
                        assetDetail.financierName = obj.response?.content[0]?.Financier_Name;
                    }
                    if(obj.response?.content[0]?.Vehicle_Class){
                        assetDetail.vehicleClass = obj.response?.content[0]?.Vehicle_Class;
                    }
                    //SFTRAC-2028 End
                    assetDetail.isGetVehicleDetailsSuccessful = trueassetDetail.disableGetVehicleDetails = true;assetDetail.showSuccessTick = true;
                    this.showToastMessage(null, 'Vahan Vehicle Report Fetched Successfully', 'Success');
                    return true;
                } else {
                    throw 'Vaahan Report API Error';
                }
            }).catch(error => {
                console.log('Error in doVahanVehicleReportCallout - Catch:: ', error);
                ++assetDetail.vaahanAPIRetryCount;this.showSpinner = false;
                assetDetail.isGetVehicleDetailsSuccessful = false;
                if (assetDetail.vaahanAPIRetryCount > 1) {
                    this.modalMsg = 'Error is fetching details from Vaahan API again, Details will be fetched from Deal Master API now';
                } else if (assetDetail.dealNumber === null || assetDetail.dealNumber === '') {
                    this.modalMsg = 'Kindly fill details manually';
                } else {
                    this.modalMsg = 'Error is fetching details from Vaahan API, Kindly Retry';}
                this.index = index;this.showPopupModal = true;
                throw new Error('Error in Vaahan Report API. Explicitly aborted to prevent Async execution. Retry Count:: ', this.vaahanAPIRetryCount);
            });
        }
    }
    async executeEligibleRefinanceAPITractor(assetDetail) {
        if (assetDetail.vehicleSubcategory === 'RLY' || assetDetail.vehicleSubcategory === 'RLN' || assetDetail.vehicleSubcategory === 'UIM' ||
        assetDetail.vehicleSubcategory === 'URS' || assetDetail.vehicleSubcategory === 'URV' || assetDetail.vehicleSubcategory === 'UEB') {
            if (!assetDetail.dealNumber) {
                this.showToastMessage('Missing Deal Number', 'Application cannot be move ahead without deal number', 'error');
                this.showSpinner = false;
                return;
            }
            await doDealEligibleRefinanceCallout({ 'opportunityId': this.recordid }).then(response => {
                let result = JSON.parse(response);
                console.log('Eligible Master API Response:==>', result);
                assetDetail.eligibilityLoanAmount = result?.response?.content[0]?.EligibilityAmount;
                assetDetail.tenureInMonths = result?.response?.content[0]?.Tenure_In_Months;
                this.showToastMessage('Sucessfully executed Eligible Refinance API', 'Details are updated for future use', 'success');
            }).catch(error => {
                this.showToastMessage('Error in getting details from Eligible Master API', error?.body?.message, 'error');
                this.showSpinner = false;
                return;
            });
        }
    }
    async handleOnFocusoutOutTractor(event,index){
        let chassisNumber = '';let assetDetail = '';
        if(event){
            event.preventDefault();chassisNumber = event?.target?.value;assetDetail = this.assetDetailList[event?.target?.dataset?.index];
        }else if(index){
            assetDetail = this.assetDetailList[index];
            if(assetDetail.chassisNumber){
                chassisNumber = assetDetail.chassisNumber;}
        }
        if(this.manufacturerYearAndMonthFromAPI != ''){
            let data = this.manufacturerYearAndMonthFromAPI.split('-');let newData = data.length>0 ? data[1] + '-' + data[0]: null;assetDetail.manufacturerYearAndMonth = newData;
        } 
        if(assetDetail.vehicleType == 'New' || assetDetail.vehicleType === 'Used' || assetDetail.vehicleType === RefinanceLabel) {
            let response = await manufacturingDateAndYearDecoder({'loanApplicationId' :this.recordid, 'makeName':assetDetail.make, 'chassisNumber':chassisNumber,'modelName' : assetDetail.model});
            if(response) {
                assetDetail.manufacturerYearAndMonth = response;assetDetail.isManufacturerYearAndMonthField = true;
            } else{
                assetDetail.isManufacturerYearAndMonthField = false;}
        }
    }
    updateVehicleDateFields(fields){
        const recordInput = { fields };updateRecord(recordInput).then(result=>{}).catch(error=>{});
    }
    async init() {
        //Get Asset Data
        await loadAssetDetailsData({ loanApplicationId: this.recordid }).then(response => {
            let result = JSON.parse(response);
            console.log('Fetched Asset Details:: ', result);
            if(result && result.length > 0 && result[0]?.productType == 'Tractor') {
                this.showSpinner = true;
                for (let index = 0; index < 1; index++) {
                    const element = result[index];
                    element.picklistFieldValueMap.Usage_Type__c.forEach(obj=>{
                        this.usageTypeOptionsListTractor.push(obj);
                    });
                    element.picklistFieldValueMap.RC_retention_applicable__c.forEach(obj=>{
                        this.rcRetentionOptionsListTractor.push(obj);
                    });
                }
                console.log('isTractor');
                this.assetDetailList = result;this.isTractor = true;this.applicantId = result[0]?.applicantId;
                this.assetDetailList.forEach((item, index) => {
                    try{
                        this.currentStageName = item?.currentStageName;
                        this.lastStage = item?.lastStage;
                        item.accordianLabel = 'Asset Detail ' + (index + 1);
                        if(item.vehicleType === 'New' || (item.vehicleType === 'Used' && item.topUpLoan == false ) || item.vehicleSubType == 'Implement') {
                            if(item.vehicleType === 'New') {
                                item.isVehicleToBeRegisteredInTheNameOf = false;}else {
                                item.isVehicleToBeRegisteredInTheNameOf = true;}
                            item.purposeOfPurchaseOptionsList = [{ label: 'Purchase of Asset', value: 'Purchase of Asset' }];
                            item.purposeOfPurchase = 'Purchase of Asset';
                        } else if(item.vehicleType === 'Refinance' || (item.vehicleType == 'Used' && item.topUpLoan == true)) {//SFTRAC-172
                            item.purposeOfPurchaseOptionsList = [{ label: 'Working Capital', value: 'Working Capital' }];
                            item.purposeOfPurchase = 'Working Capital';
                        } else{
                            item.purposeOfPurchaseOptionsList = [{ label: item.purposeOfPurchase, value: item.purposeOfPurchase }];
                        }
                        if(item.vehicleType === 'Used' || item.vehicleType === 'Refinance') {
                            item.isUsedOrRefinance = true;item.invoiceRequired = false;} else{item.isUsedOrRefinance = false;item.invoiceRequired = true;}
                        if(item.vehicleSubType == 'Implement'){item.isImplement = true;}else{item.isImplement =false;}
                        this.getMakeListForManualInputTractor(item);item.product = item?.productType;
                        item.leadNumber = item?.leadNo;item.dealNumber = item?.parentDealNumber;item.agentBLCode = item?.agentBLCode;
                        item.vehicleRegNoValue = item?.vehicleRegNumber;
                        item.isGetVehicleDetailsSuccessful = item.isGetVehicleDetailsSuccessful == null ? false : item.isGetVehicleDetailsSuccessful;
                        item.leadCreatedDate = item?.CreatedDate;item.aggregatorSource = item?.aggregatorSource;
                        item.allowSubmit = true;item.dealMasterAPIRetryCount = 0;item.vaahanAPIRetryCount = 0;
                        item.showFailureTick = false;item.isDealerFieldMandatory = false;item.isDealerFieldDisabled = true;
                        if (item?.vehicleDelivered?.toLowerCase() == 'yes') {
                            item.vehicleSubcategory = item?.vehicleSubCategory;item.displayUsedVehicleTypeFields = true;item.allowSubmit = false;
                        }
                        if((item?.vehicleType === 'New' || item?.vehicleSubCategory === 'UPD') && !(item.aggregatorSource) ){
                            if(item?.vehicleSubCategory === 'UPD'){
                                item.isDealerFieldMandatory = false;
                            }else{
                                item.isDealerFieldMandatory = true;
                            }
                            item.isDealerFieldDisabled = false;
                        }
                        item.manufacturerYearAndMonth = item?.manufacturerYearMonth;item.makeCodeOfProduct = item?.makeCode;
                        item.mmvDisable = false;item.make = item?.vehicleMake;item.allFieldsDisabled = false;
                        if(item.manufacturerYearAndMonth){
                            item.isManufacturerYearAndMonthField = true;
                        }else {
                            item.isManufacturerYearAndMonthField = false;
                        }
                        item.disableTractorFields = true;item.modelCodeOfProduct = item?.modelCode;item.model = item?.vehicleModel;
                        item.variantOptionsList = [];item.variantCodeOfProduct = item?.variantCode;item.variant = item?.vehicleVarient;
                        item.dealerBenCode = item?.benCode;item.vehicleRegisteredInNameOf = item?.invoiceInNameOf;
                        item.vehicleRegisteredInNameOfOptionsList = [{ label: item.vehicleRegisteredInNameOf, value: item.vehicleRegisteredInNameOf }];
                        item.showVahanDetailsSection = false;item.disableGetVehicleDetails = false;item.showSuccessTick = false;
                        item.numberOfOwnershipsOptionsList = [];item.insExpiryDate = '';item.insIssuanceDate = '';item.insurancNumber = '';
                        item.insurerName = '';item.ownerContactNumber = '';item.vehiclePlaceOfValuation = '';item.usageTypeOptionsList = [];
                        item.mnfYearMonthId = 'mnfYearMonthId'+index;item.lastOwnerId = 'lastOwnerId'+index;
                        item.lienInFavorOfOptionsList = [];item.rcRetentionOptionsList = [];
                        item.rcHoldAmount = item?.rcHoldAmount; //SFTRAC-1715
                        if (item.vehicleType !== 'New') {
                            item.usageTypeOptionsList = [{ label: item.usageType, value: item.usageType }];
                            if(item.numberOfOwnerships) {
                                item.picklistFieldValueMap.Number_of_ownerships__c.forEach((obj) => {
                                    if (obj.value === item.numberOfOwnerships) {
                                        item.numberOfOwnershipsOptionsList = [{ label: obj.label, value: item.numberOfOwnerships }];
                                        return true;
                                    }
                                });
                            } else {
                                item.numberOfOwnershipsOptionsList = item.picklistFieldValueMap.Number_of_ownerships__c;
                            }
                            if(item.lienInFavorOf) {
                                item.lienInFavorOfOptionsList = [{ label: item.lienInFavorOf, value: item.lienInFavorOf }];
                            } else {
                                item.lienInFavorOfOptionsList = item.picklistFieldValueMap.Lien_in_favor_of__c;//CISP-2419
                            }
                        }//SFTRAC-1715
                            if(item.rcRetentionApplicable){
                                item.rcRetentionOptionsList = [{ label: item.rcRetentionApplicable, value: item.rcRetentionApplicable }];
                                item.rcRetentionApplicableYes = item.rcRetentionApplicable == 'Yes' && this.isTractor == true ? true : false; //SFTRAC-1715
                            } else {
                                item.rcRetentionOptionsList = item.picklistFieldValueMap.RC_retention_applicable__c;//CISP-2419
                            }
                        if (item.make && item.model && item.variant) {
                            this.getMakeListForManualInputTractor(item);this.getModelListForManualInputTractor(index);this.getVariantListForManualInputTractor(index);this.fetchDealerSubDealerTractor(index)
                        }

                        if (item.dealerSubdealerName) {
                            item.dealerSubdealerName = item.dealerSubdealerName + ' | ' + item.dealerBenCode;
                            item.dealerSubDealerOptionsList = [{ label: item.dealerSubdealerName, value: item.dealerSubdealerName }];
                        }
                    }catch(error){
                        console.log('error'+error);
                        this.showSpinner = false;
                    }
                });
            }
            else {
                //Inputs
                this.product = result?.productType;this.vehicleType = result?.vehicleType;this.leadNumber = result?.leadNo;
                this.applicantId = result?.applicantId;this.vehicleDetailId = result?.vehicleDetailId;this.dealNumber = result?.parentDealNumber;
                this.vehicleRegNoValue = result?.vehicleRegNumber;
                this.isGetVehicleDetailsSuccessful = result.isGetVehicleDetailsSuccessful == null ? false : result.isGetVehicleDetailsSuccessful;
                // this.isDCategoryVehicle = result?.isDCategoryVehicle;
                this.lastStage = result?.lastStage;this.currentStageName = result?.currentStageName;this.agentBLCode = result?.agentBLCode;
                this.leadSource = result?.leadSource;//CISP-3705
                this.parentLeadId = result?.parentLeadId;//CISP-3705
                this.parentLeadSource = result?.parentLeadSource; //CISP-3705
                this.leadCreatedDate = result?.CreatedDate;//CISP-3431
                this.aggregatorSource = result?.aggregatorSource;//D2C change -- Rahul
                if (this.vehicleType === 'Used' || this.vehicleType === RefinanceLabel) {
                    this.vehicleSubcategory = result?.vehicleSubCategory;this.displayUsedVehicleTypeFields = true;this.allowSubmit = false;}
                if((result?.vehicleType === 'New' || result?.vehicleSubCategory === 'UPD' || result?.vehicleSubCategory === 'UEB') && !(this.aggregatorSource) ){//d2c changes -- rahul. IN aggregator these fields should be disabled. //CISP-4606
                    this.isDealerFieldMandatory = true;this.isDealerFieldDisabled = false;}
            if(this.vehicleType != 'New' && this.product == 'Passenger Vehicles' && (this.leadSource != 'D2C' && this.leadSource != 'OLA')){//CISP-8762
                this.isPVUsedAndRefinance = true;}
            //Get Stored Display fields
            if (this.vehicleDetailId) {
                //Get Vehicle Details fields - USED OR NEW
                this.makeCodeOfProduct = result?.makeCode;//CISP-2794
                this.modelCodeOfProduct = result?.modelCode;//CISP-2794
                this.variantCodeOfProduct = result?.variantCode;//CISP-2794
                this.make = result?.vehicleMake;this.model = result?.vehicleModel;this.variant = result?.vehicleVarient; 
                this.dealerSubDealerName = result?.dealerSubdealerName;this.invoiceInNameOf = result?.invoiceInNameOf;
                this.segmentCode = result?.productSegment; //CISP-13665
                this.dealerBenCode = result?.benCode; //CISP-2353
                this.isRcLimitChecked = result?.rcLimitEnabledDealer;//CISP-8762
                //Get Vehicle Details Picklist Selected Values - USED OR NEW
                this.purposeOfPurchase = result?.purposeOfPurchase;this.vehicleRegisteredInNameOf = result?.vehicleInNameOf;
                this.purposeOfPurchaseOptionsList = [{ label: this.purposeOfPurchase, value: this.purposeOfPurchase }];
                this.vehicleRegisteredInNameOfOptionsList = [{ label: this.vehicleRegisteredInNameOf, value: this.vehicleRegisteredInNameOf }];
                this.distance= result?.distance; // commercial pv
                this.grossReceipts= result?.grossReceiptsMonth; // commercial pv
                this.numberOfVehicles =result?.numberOfVehicleOwned; // commercial pv
                this.expense = result?.expense; // commercial pv
                this.vehicleRoute = result?.vehicleRoute; // commercial pv
                this.route = result?.route;  //commercial pv
                if (this.purposeOfPurchase === 'Commercial') {
                    this.showViabilitySection = true;
                } else {
                    this.showViabilitySection = false;
                }

                //Get Vehicle Details fields - USED Only
                if (this.vehicleType !== 'New') {
                    this.manufacturerYearAndMonth = result?.manufacturerYearMonth;this.lastOwnerName = result?.lastOwnerName;
                    this.engineNumber = result?.engineNumber;this.chassisNumber = result?.chassisNumber;
                    //Get Picklist Selected Value fields 
                    this.usageType = result?.usageType;
                    this.numberOfOwnerships = result?.numberOfOwnerships;this.lienInFavorOf = result?.LienInFavorOf;
                    this.rcRetentionApplicable = result?.rcRetentionApplicable;
                    this.usageTypeOptionsList = [{ label: this.usageType, value: this.usageType }];
                    //if(this.numberOfOwnerships != undefined && this.numberOfOwnerships != '' && this.numberOfOwnerships != null) {
                      //  //CISP-2998
                        //result.picklistFieldValueMap.Number_of_ownerships__c.forEach((obj) => {
                        //    if (obj.value === this.numberOfOwnerships) {
                          //      this.numberOfOwnershipsOptionsList = [{ label: obj.label, value: this.numberOfOwnerships }];
                          //      return true;
                         //   }
                    //   });//CISP-2998 END
                   // } else {
                        this.numberOfOwnershipsOptionsList = result.picklistFieldValueMap.Number_of_ownerships__c;//CISP-2419
                   // }
                    if(this.lienInFavorOf != undefined && this.lienInFavorOf != '' && this.lienInFavorOf != null) {
                        this.lienInFavorOfOptionsList = [{ label: this.lienInFavorOf, value: this.lienInFavorOf }];
                    } else {
                        this.lienInFavorOfOptionsList = result.picklistFieldValueMap.Lien_in_favor_of__c;//CISP-2419
                    }
                    if(this.rcRetentionApplicable != undefined && this.rcRetentionApplicable != '' && this.rcRetentionApplicable != null){
                        this.rcRetentionOptionsList = [{ label: this.rcRetentionApplicable, value: this.rcRetentionApplicable }];
                    } else {
                        this.rcRetentionOptionsList = result.picklistFieldValueMap.RC_retention_applicable__c;//CISP-2419
                    }
                }
                //UPDATE EXISTING COMBOBOX BASED FIELDS
                if (this.make) {
                    this.getMakeListForManualInput();this.getModelListForManualInput();
                }
                if (this.model) {
                    this.getVariantListForManualInput();
                }

                if (this.dealerSubDealerName) {
                    this.dealerSubDealerName = this.dealerSubDealerName + ' | ' + this.dealerBenCode;//CISP-2353
                    this.dealerSubDealerOptionsList = [{ label: this.dealerSubDealerName, value: this.dealerSubDealerName }];
                }
            } else {
                //Update Picklist fields
               // this.purposeOfPurchaseOptionsList = result.picklistFieldValueMap.Purpose_of_purchase__c;
                this.vehicleRegisteredInNameOfOptionsList = result.picklistFieldValueMap.Vehicle_registered_in_the_name_of__c;
                if(this.product == 'Passenger Vehicles'){
                    this.purposeOfPurchaseOptionsList = [{ label: 'Personal', value: 'Personal' },
                        { label: 'Commercial', value: 'Commercial' }];
                }else{
                    this.purposeOfPurchaseOptionsList = [{ label: 'Personal', value: 'Personal' }];
                   // this.purposeOfPurchaseOptionsList = result.picklistFieldValueMap.Purpose_of_purchase__c;
                    this.purposeOfPurchase = result.picklistFieldValueMap.Default_Purpose_of_purchase__c[0].label;
                }
                //this.purposeOfPurchase = result.picklistFieldValueMap.Default_Purpose_of_purchase__c[0].label;
                this.vehicleRegisteredInNameOf = result.picklistFieldValueMap.Default_Vehicle_registered_in_the_name_of__c[0].label;
                if (this.vehicleType !== 'New') {
                    this.usageTypeOptionsList = result.picklistFieldValueMap.Usage_Type__c;
                    this.numberOfOwnershipsOptionsList = result.picklistFieldValueMap.Number_of_ownerships__c;
                    this.lienInFavorOfOptionsList = result.picklistFieldValueMap.Lien_in_favor_of__c;
                    this.rcRetentionOptionsList = result.picklistFieldValueMap.RC_retention_applicable__c;
                    this.usageType = result.picklistFieldValueMap.Default_Purpose_of_purchase__c[0].label;
                }
            }
            //CISP-3425
            if(((this.makeCodeOfProduct && this.modelCodeOfProduct && this.variantCodeOfProduct) || (this.make && this.model && this.variant))
 && (this.leadSource?.includes('Digital-MSIL-Custom') || this.leadSource?.includes('Digital-Mahindra-Custom') || this.leadSource?.includes('Digital-Mahindra-PreA') || (this.parentLeadId && (this.parentLeadSource?.includes('Digital-MSIL-Custom') || this.parentLeadSource?.includes('Digital-Mahindra-Custom') || this.parentLeadSource?.includes('Digital-Mahindra-PreA')))) //CISP-15890
 && this.product == 'Passenger Vehicles' && !this.isD2cApplication){//CISP-3705
                console.log('inside mmv : ',);//revert changes
                this.mmvDisable = true;this.isDealerFieldDisabled = false;
                this.fetchDealerSubDealer(); //CISP-4163
            }
            //CISP-4633
            if(((this.makeCodeOfProduct && this.modelCodeOfProduct && this.variantCodeOfProduct) 
                || (this.make && this.model && this.variant)) && (this.isD2cApplication)
                && this.product == 'Passenger Vehicles'){
                    this.mmvDisable = true;this.d2cMMVDisable = true;this.isDealerFieldDisabled = true;
                    this.fetchDealerSubDealer(); //CISP-4163
            }
            //CISP-3425
        }
        }).catch(error => {
            console.log('Error in loading Asset Details:: ', error);
        });
        if(this.isTractor) {
            console.log('this.isTractor754:::'+this.isTractor);
            this.assetDetailList.forEach(async(item, index) => {
                try{
                    //Ola integration changes
                    await getLoanApplicationReadOnlySettings({leadSource:item.leadSource})
                    .then(data => {
                        let fieldList = [];
                        if(data){
                            fieldList = data.Input_Labels__c.split(';');
                        }
                        console.log(fieldList);
                        if(fieldList.length > 0){
                            item.invoiceNameDisabled = false;
                            item.allFieldsDisabled = fieldList.includes('Asset Details')? true : item.allFieldsDisabled;
                            item.isDealerFieldDisabled = fieldList.includes('Asset Details')? true : item.isDealerFieldDisabled;
                            item.mmvDisable = fieldList.includes('Asset Details')? true : item.mmvDisable;
                        }
                    }).catch(error => { 
                        this.showSpinner = false;
                    });
                    //Ola Integration changes
                    console.log('776');
                    //If Vehicle record is created then check the status of GetVehicleDetail button
                    if (item.vehicleDetailId && item.isGetVehicleDetailsSuccessful) {
                        item.showVahanDetailsSection = true;item.disableGetVehicleDetails = true;
                        item.showSuccessTick = true;item.allowSubmit = true;this.showSpinner = false;
                        return;
                    } else if (item.vehicleDetailId && !item.isGetVehicleDetailsSuccessful && item.dealMasterAPIRetryCount >= 4) {
                        item.showVahanDetailsSection = true;item.disableGetVehicleDetails = true;
                        item.showFailureTick = true;this.showSpinner = false;
                        return;
                    }
                    console.log('792');
                    //Used-Refinance (RLY, RLN, UIM, URS, URV, UEB) CASE 1: - Get data from Deal Master
                    if ((item.vehicleSubcategory === 'RLY' || item.vehicleSubcategory === 'RLN' || item.vehicleSubcategory === 'UIM' || item.vehicleSubcategory === 'URS' ||
                        item.vehicleSubcategory === 'URV' || item.vehicleSubcategory === 'UEB') && ((item.vehicleType === 'Used' || item.vehicleType === RefinanceLabel)) && 
                        item.vehicleDetailId!=null) {
                        //Fetch MMV data from Deal Master API on the basis of Deal Number
                        if (item.dealNumber) {
                            await this.executeDealMasterAPITractor('MMV', item, index);
                            this.showSpinner = false;
                            return;
                        } else {
                            this.showToastMessageModeBased('Missing Deal Number for Vehicle Sub-Cetegory - ' + item.vehicleSubcategory, 'Journey cannot be move ahead without deal number', 'error', 'sticky');
                            this.showSpinner = false;
                            return;
                        }
                    }
                    console.log('809'+item.make);
                    //If MMV is not populated from APIs then enter manually
                    if (!item.make) {
                        console.log('813'+index);
                        await this.getMakeListForManualInputTractor(item);
                    }
                    //DSAMODIFYEXISTING	
                    if (item.leadSource === 'DSA') {
                        this.getMakeListForManualInputTractor(item).then(() => {
                            this.getModelListForManualInputTractor(index).then(() => {
                                this.fetchDealerSubDealerTractor(index).then(() => {
                                    this.getVariantListForManualInputTractor(index);
                                })
                            })
                        })
                    }
                    this.showSpinner=false;//CISP-519
                }catch(error){
                    console.log('error'+error);
                    this.showSpinner = false;
                }
            });
            await this.callAccessLoanApplication();
        }
        else {
            //Ola integration changes
            await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
            .then(data => {
                let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}
                console.log(fieldList);
                if(fieldList.length>0){
                    this.invoiceNameDisabled = false;
                    this.allFieldsDisabled = fieldList.includes('Asset Details')? true :this.allFieldsDisabled;
                    this.isDealerFieldDisabled = fieldList.includes('Asset Details')? true :this.isDealerFieldDisabled;
                    this.mmvDisable = fieldList.includes('Asset Details')? true :this.mmvDisable;
                }
            }).catch(error => { 
                this.isLoading = false;
            });
            //Ola Integration changes
            console.log('Vehicle Type:: ', this.vehicleType);
            console.log('Vehicle ID:: ', this.vehicleDetailId);
            console.log('isGetVehicleDetailsSuccessful:: ', this.isGetVehicleDetailsSuccessful);
            //If Vehicle record is created then check the status of GetVehicleDetail button
            if ((this.vehicleType === 'Used' || this.vehicleType === RefinanceLabel) && this.vehicleDetailId && this.isGetVehicleDetailsSuccessful) {
                console.log('Vehicle Id Exists');
                this.showVahanDetailsSection = true;this.disableGetVehicleDetails = true;this.showSuccessTick = true;
                this.allowSubmit = true;this.showSpinner = false;//CISP-2674
                return;
            } else if ((this.vehicleType === 'Used' || this.vehicleType === RefinanceLabel) && this.vehicleDetailId && !this.isGetVehicleDetailsSuccessful && this.dealMasterAPIRetryCount >= 4) {
                console.log('Vehicle Id Exists and unsuccessful');
                this.showVahanDetailsSection = true;this.disableGetVehicleDetails = true;
                this.showFailureTick = true;this.showSpinner = false;//CISP-2674
                return;
            }
            console.log('Vehicle Sub-Category:: ', this.vehicleSubcategory);
            console.log('Vehicle ID:: ', this.vehicleDetailId);
            if ((this.vehicleSubcategory === 'RLY' || this.vehicleSubcategory === 'RLN' || this.vehicleSubcategory === 'UIM' || this.vehicleSubcategory === 'URS' || this.vehicleSubcategory === 'URV' || this.vehicleSubcategory === 'UEB') && ((this.vehicleType === 'Used' || this.vehicleType === RefinanceLabel)) && (this.vehicleDetailId === '' || this.vehicleDetailId === null)) {
                //Fetch MMV data from Deal Master API on the basis of Deal Number
                console.log('Deal Number:: ', this.dealNumber);
                if (this.dealNumber) {
                    await this.executeDealMasterAPI('MMV');
                    this.showSpinner = false;
                    return;
                } else {
                    this.showToastMessageModeBased('Missing Deal Number for Vehicle Sub-Cetegory - ' + this.vehicleSubcategory, 'Journey cannot be move ahead without deal number', 'error', 'sticky');
                    this.showSpinner = false;
                    return;
                }
            }
            //If MMV is not populated from APIs then enter manually
            if (this.make === '' || this.make === null || this.make === undefined) {
                await this.getMakeListForManualInput();
            }
            await this.callAccessLoanApplication();
            //DSAMODIFYEXISTING	
            if (this.leadSource === 'DSA') {
                this.getMakeListForManualInput().then(() => {
                    this.getModelListForManualInput().then(() => {
                        this.fetchDealerSubDealer().then(() => {
                            this.getVariantListForManualInput();
                        })
                    })
                })
            }
        }
        this.showSpinner=false;//CISP-519
        if(this.leadSource == 'Hero' && this.currentStageName == 'Asset Details'){
            this.template.querySelector("[data-id='dealername']").disabled = true; //Hero CISH-2
            this.template.querySelector("[data-id='invoicename']").disabled = true; //Hero CISH-2  && CISH-64
            // this.fetchDealerSubDealer(); CISH-121
        }
    }
    handleInputFieldChange(event) {
        const fieldName = event.target.name;
        if (fieldName === 'rcRetentionApplicableField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.rcRetentionApplicable = event.target.value;
                assetDetail.rcRetentionApplicableYes = assetDetail.rcRetentionApplicable == 'Yes' ? true : false; //SFTRAC-1715
                if(!assetDetail.rcRetentionApplicableYes){
                    assetDetail.rcHoldAmount = null;
                }
            } else{
                this.rcRetentionApplicable = event.target.value;
            }
        } else if(fieldName === 'rcHoldAmountField'){ //SFTRAC-1715 Start
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                const inputValue = parseFloat(event.target.value);
                if (inputValue < 10000 || inputValue > 100000 || isNaN(inputValue)) {
                    this.showToastMessage('Error', 'Please enter RC Hold Amount between 10,000 and 100,000', 'error');
                }else{
                    assetDetail.rcHoldAmount = event.target.value;
                }
            } //SFTRAC-1715 End
        } else if (fieldName === 'lienInFavorField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.lienInFavorOf = event.target.value;
            } else{
                this.lienInFavorOf = event.target.value;
            }
        } else if (fieldName === 'chassisNumberField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.chassisNumber = event.target.value;
            } else{
                this.chassisNumber = event.target.value;
            }
        } else if (fieldName === 'engineNumberField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.engineNumber = event.target.value;
            } else{
                this.engineNumber = event.target.value;
            }
        } else if (fieldName === 'usageTypeField') {
            this.usageType = event.target.value;
        } else if (fieldName === 'lastOwnerNameField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.lastOwnerName = event.target.value;
                let lastOwnerNameInput = this.template.querySelector(`lightning-input[data-id="${assetDetail.lastOwnerId}"]`);
                lastOwnerNameInput.reportValidity();
            } else{
                this.lastOwnerName = event.target.value;
                let lastOwnerNameInput = this.template.querySelector('lightning-input[data-id=lastOwnerId]');
                lastOwnerNameInput.reportValidity();
            }
        } else if (fieldName === 'manufacturerYearAndMonthField') {
            console.log('event.target.dataset.index:::'+event.target.dataset.index);
            var dateObj;
            let assetDetail;
            if(this.isTractor) {
                assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.manufacturerYearAndMonth = event.target.value;
                dateObj = new Date(assetDetail.leadCreatedDate);//CISP-3413 start
            } else{
                this.manufacturerYearAndMonth = event.target.value;
                dateObj = new Date(this.leadCreatedDate);//CISP-3413 start
            }
            var mm = dateObj.getMonth() + 1;
            var yyyy = dateObj.getFullYear();
            if (mm.toString().length == 1) {
                mm = mm.toString().padStart(2, '0')
            }
            var currentDate = yyyy + "" + mm;
            let currentDatestr = yyyy + ' ' + mm;
            var enteredManufField;
            if(this.isTractor) {
                enteredManufField = assetDetail.manufacturerYearAndMonth.split("-").join("");
            } else{
                enteredManufField = this.manufacturerYearAndMonth.split("-").join("");
            }
            //var minimumExpiryDate = currentDate - (15 * 100);
            var minimumExpiryDate = this.isTractor == true ? currentDate - (20 * 100) : currentDate - (15 * 100); 
            var diffinDays = enteredManufField - minimumExpiryDate;
            let intcurrentDate = parseInt(currentDate.toString());
            let intenterdate =  parseInt(enteredManufField.toString());
            let manufctureDate 
            if(this.isTractor){
                manufctureDate = this.template.querySelector(`[data-id="${assetDetail.mnfYearMonthId}"]`);
            }else{
                manufctureDate = this.template.querySelector('[data-id="mnfYearMonthId"');
            }
            if((intenterdate >= minimumExpiryDate && minimumExpiryDate <= intcurrentDate) && intenterdate <= intcurrentDate){
                manufctureDate.setCustomValidity("");
            }
            else {
                if(this.isTractor) {
                    manufctureDate.setCustomValidity("Manufacturing Year should be within 20 years from " + currentDatestr);
                }else{
                    manufctureDate.setCustomValidity("Manufacturing Year should be within 15 years from " + currentDatestr);
                }
            }
            //CISP-3431 end
            manufctureDate.reportValidity();
        } else if (fieldName === 'vehicleRegNoValueField') {
            this.vehicleRegNoValue = event.target.value;
        } else if (fieldName === 'vehicleRegisteredInNameOfField') {
            this.vehicleRegisteredInNameOf = event.target.value;
        } else if (fieldName === 'distance') {
            this.distance = event.target.value;
        }else if (fieldName === 'grossReceipts') {
            this.grossReceipts = event.target.value;
        }else if (fieldName === 'numberOfVehicles') {
            this.numberOfVehicles = event.target.value;
        }else if(fieldName === 'expense') {
            this.expense = event.target.value;
        }else if(fieldName === 'route') {
            this.route = event.target.value;
        } else if (fieldName === 'invoiceNameField') {
            this.invoiceInNameOf = event.target.value;
            let invoiceNameInput = this.template.querySelector('lightning-input[data-id=invoicename]');
            this.invoiceInNameOf = invoiceNameInput.value;
            if (this.invoiceInNameOf.length > 26) {
                invoiceNameInput.setCustomValidity(this.labels.lastNameError);
            } else {
                invoiceNameInput.setCustomValidity(""); // clear previous value
            }
            invoiceNameInput.reportValidity();
        } else if (fieldName === 'dealerSubDealerNameField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.dealerSubDealerName = event.target.value;
            } else{
                this.dealerSubDealerName = event.target.value;
                if(this.isPVUsedAndRefinance){//CISP-8762
                    let splitBenCode = this.dealerSubDealerName.split('|'); let benCode = splitBenCode[1];
                    console.log('OUTPUT benCode: ',benCode);
                    this.checkRCLimitEnable(benCode.trim());
                }
            }
        } else if (fieldName === 'purposeofPurcValueField') {
            this.purposeOfPurchase = event.target.value;
            if (this.purposeOfPurchase === 'Commercial') {
                this.showViabilitySection = true;
            } else {
                this.showViabilitySection = false;
            }

        } else if (fieldName === 'variantField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.variant = event.target.options.find(opt => opt.value === event.detail.value).label;//CISP-2794
                assetDetail.variantCodeOfProduct = event.target.value;//CISP-2794
            } else{
                this.variant = event.target.options.find(opt => opt.value === event.detail.value).label;//CISP-2794
                this.variantCodeOfProduct = event.target.value;//CISP-2794
            }
        } else if (fieldName === 'modelField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                if (assetDetail.model !== event.target.value) {
                    assetDetail.dealerSubDealerName = null;assetDetail.dealerSubDealerOptionsList = null;
                    assetDetail.variantCodeOfProduct = null;assetDetail.variantOptionsList = null;
                }
                assetDetail.model = event.target.options.find(opt => opt.value === event.detail.value).label;
                assetDetail.modelCodeOfProduct = event.target.value;this.showSpinner = true;
                this.fetchDealerSubDealerTractor(event.target.dataset.index);
                this.getVariantListForManualInputTractor(event.target.dataset.index);
                this.handleOnFocusoutOutTractor(null,event?.target?.dataset?.index);
                this.showSpinner = false;
            } else{
                if (this.model !== event.target.value) {
                    this.dealerSubDealerName = null;this.dealerSubDealerOptionsList = null;this.variantOptionsList = null;
                    this.variant = null;this.variantCodeOfProduct = null;
                }
                this.model = event.target.options.find(opt => opt.value === event.detail.value).label;//CISP-2794
                this.segmentCode = event.target.options.find(opt => opt.value === event.detail.value).segmentCode;//CISP-13665
                this.modelCodeOfProduct = event.target.value;//CISP-2794
                console.log('OUTPUT this.model: ',this.model);
                console.log('OUTPUT this.modelCodeOfProduct: ',this.modelCodeOfProduct);
                //Update Dealer Sub-Dealer Name on Model value change
                this.showSpinner = true;this.fetchDealerSubDealer();
                this.getVariantListForManualInput();this.showSpinner = false;
            }
        } else if (fieldName === 'makeField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                this.showSpinner = true;
                assetDetail.make = event.target.options.find(opt => opt.value === event.detail.value).label;//CISP-2794
                assetDetail.makeCodeOfProduct = event.target.value;;assetDetail.model = null;
                assetDetail.dealerSubdealerName = null;assetDetail.variantCodeOfProduct = null;assetDetail.modelCodeOfProduct = null;
                assetDetail.dealerSubDealerOptionsList = null;assetDetail.modelOptionsList = null;assetDetail.variantOptionsList = null;
                this.getModelListForManualInputTractor(event.target.dataset.index);
                this.handleOnFocusoutOutTractor(null,event?.target?.dataset?.index);
                this.showSpinner = false;
            } else{
                this.make = event.target.options.find(opt => opt.value === event.detail.value).label;//CISP-2794
                this.makeCodeOfProduct = event.target.value;//CISP-2794
                this.showSpinner = true;this.dealerSubDealerName = null;this.Variant = null;
                this.model = null;this.dealerSubDealerOptionsList = null;this.modelOptionsList = null; this.variantOptionsList = null;
                this.variantCodeOfProduct = null;this.getModelListForManualInput();this.showSpinner = false;
            }
        } else if (fieldName === 'productField') {
            this.product = event.target.value;
        } else if (fieldName === 'vehicleTypeField') {
            this.vehicleType = event.target.value;
        } else if (fieldName === 'noOfOwnershipField') {
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.numberOfOwnerships = event.target.value;
            } else{
                this.numberOfOwnerships = event.target.value;
            }
        }
        //CISP-1197 START
        if(fieldName === 'makeField' || fieldName === 'modelField' || fieldName === 'variantField'){
            if(this.isTractor) {
                let assetDetail = this.assetDetailList[event.target.dataset.index];
                assetDetail.disableGetVehicleDetails = false;
            } else {
                this.disableGetVehicleDetails = false;
            }
        }
        //CISP-1197 END
    }
    //CISP-8762 start
    checkRCLimitEnable(benCode){console.log('OUTPUT : checkRCLimitEnable');
        checkRCLimitBasedOnBencode({ benCodeValue : benCode })
          .then(result => {
            console.log('Result', result);
            this.isRcLimitChecked = result;
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }//CISP-8762 end
    async getMakeListForManualInput() {
        console.log('sProductType_1_'+this.product);
        console.log('vehicleType___1'+this.vehicleType);
        await getMakeList({ sProductType: this.product, vehicleType: this.vehicleType, sleadsource: this.leadSource }).then(response => { //CISP-4974 and //CISP-7045
            console.log('getMakeList--' ,response);
            this.makeOptionsList = response;
        }).catch(error => {
            console.log('Error in getting Make:: ', error);
        });
    }
    async getModelListForManualInput() {
        console.log('this.makeCodeOfProduct--' ,this.makeCodeOfProduct);
        console.log('this.vehicleType--' ,this.vehicleType);
        console.log('this.product--' ,this.product);
        await getRelatedModelList({ sMake: this.makeCodeOfProduct, vehicleType: this.vehicleType, productType: this.product }).then(response => {
            console.log('getModelList--' ,response);
            this.modelOptionsList = response;
        }).catch(error => {
            console.log('Error in getting related Model:: ', error);
            console.log('Error in getting related Model2:: ', error.body.message);
        });
    }
    async getVariantListForManualInput() {
        await getRelatedVariantList({ sModel: this.modelCodeOfProduct, vehicleType: this.vehicleType }).then(response => { //CISP-4818
            console.log('getVariantList--' ,response);
            this.variantOptionsList = response.map(function (obj) {
                return { label: obj.Name, value: obj.Variant_Code__c };//CISP-2794
            });
        }).catch(error => {
            console.log('Error in getting related Variant:: ', error);
        });
    }
    async fetchDealerSubDealer() {
        console.log('OUTPUTfetchDealerSubDealer : ',);
        if (this.agentBLCode !== null && this.model !== null) {
            await getDealerSubDealerDetails({ sModelName: this.model , sBLCode: this.agentBLCode , loanApplicationId : this.recordid }).then(result => {
                const obj = JSON.parse(result);
                console.log('getDealerSubDealerDetails - Result:: ', obj);
                if (obj.length === 0) {
                    if(!this.isDealerFieldDisabled && this.leadSource != 'D2C'){//D2C Change
                        this.showToastMessage('Dealer/SubDealer is not available for selected Model (' + this.model + ')', 'Please contact System Administrator', 'error');
                    }
                    this.showSpinner=false;// CISP-2621
                } else {
                    this.dealerSubDealerOptionsList = obj.map(function (obj) {
                        return { label: obj.Ben_code__r.Name + ' | '+ obj.Ben_code__r.Ben_code__c , value: obj.Ben_code__r.Name + ' | '+ obj.Ben_code__r.Ben_code__c };
                    });
                }
            }).catch(error => {
                this.showToastMessage('Error in fetching Dealer/SubDealer', 'Please contact System Administrator', 'error');
                console.log('getDealerSubDealerDetails - error:: ', error);
            });
        } else {
            this.showToastMessage('Missing Agent BL code or Model value', 'Please contact System Administrator', 'error');
        }
    }
    async handleGetVehicleDetails() {
        this.showSpinner = true;
        //Empty field Check
        if (!this.validityCheck('lightning-input')) {
            this.showSpinner = false;this.showToastMessage('Fill all the fields', null, 'warning')
            return;
        }
        console.log('Vaahan API:: ', this.vaahanAPIRetryCount);
        console.log('DealMaster API:: ', this.dealMasterAPIRetryCount);
        console.log('Deal Number:: ', this.dealNumber);
        //Vaahan API
        if ((this.vaahanAPIRetryCount < 2 && this.dealNumber) || (this.vaahanAPIRetryCount < 1 && this.dealNumber === null)) {
            await this.executeVaahanAPIs();
        } else {
            if (this.dealNumber === null || this.dealNumber === '') {this.disableGetVehicleDetails = true;}
        }
        //Deal Master API
        if (this.dealMasterAPIRetryCount < 4 && this.dealNumber) {
            await this.executeDealMasterAPI('VehicleDetails');
        } else {
            this.disableGetVehicleDetails = true;
        }
        await this.executeEligibleRefinanceAPI();
        this.showVahanDetailsSection = true;
        this.isGetVehicleDetailsSuccessful = true;//CISP-3431
        this.allowSubmit = true;this.showSpinner = false;
    }
    //Deal Master API
    async executeDealMasterAPI(scope) {
        try {
            let isDealMasterAPISuccessful = false;let dealMasterResponse;let skipMMVUpdateFlag = false;
            if (scope === 'VehicleDetails' && this.make && this.model && this.variant) {
                skipMMVUpdateFlag = true;
            }
            console.log('Deal Master processing for ' + scope);
            //API Call
            await this.dealMasterAPICall().then(result => {
                console.log('OUTPUT resultdealMasterAPICall: ',result);
                isDealMasterAPISuccessful = result.isSuccessful;
                dealMasterResponse = result.response;
            }).catch(error => {
                console.log('Deal Master Callout - Error:: ' + error);
            });
            console.log('Deal Master API callout Status:: ' + isDealMasterAPISuccessful);
            console.log('SKIP MMV Processing:: ' + !skipMMVUpdateFlag);
            if (isDealMasterAPISuccessful === true) {
                //If Deal Master API is successful while loading then skip MMV update
                if (!skipMMVUpdateFlag) {
                    let makeCode = dealMasterResponse?.response.content[0]?.Make;
                    let modelCode = dealMasterResponse?.response.content[0]?.Model;
                    let variantCode = dealMasterResponse?.response.content[0]?.Variant;
                     //CISP-2794
                    this.makeCodeOfProduct = makeCode;this.modelCodeOfProduct = modelCode;this.variantCodeOfProduct = variantCode;
                    console.log('this.makeCodeOfProduct : ',this.makeCodeOfProduct);
                    console.log('this.modelCodeOfProduct : ',this.modelCodeOfProduct);
                    console.log('this.variantCodeOfProduct : ',this.variantCodeOfProduct); //CISP-2794
                    await getMMVNameBasedOnCode({ makeCode: makeCode, modelCode: modelCode, variantCode: variantCode }).then(response => {
                        let mmvResponse = JSON.parse(response);
                        console.log('Get MMV Name:: ', mmvResponse);
                        //Update MMV Fields with the MMV Name
                        this.make = mmvResponse.vehicleMake;this.model = mmvResponse.vehicleModel;this.variant = mmvResponse.vehicleVarient;
                        if (this.make === null) {
                            this.showToastMessage('Make Master is not available', 'Please contact System Administrator', 'error');
                        }
                        if (this.model === null) {
                            this.showToastMessage('Model Master is not available', 'Please contact System Administrator', 'error');
                        }
                        if (this.variant === null) {
                            this.showToastMessage('Variant Master is not available', 'Please contact System Administrator', 'error');
                        }
                        //Update Combobox fields
                        if (this.make && this.model && this.variant) {
                            this.makeOptionsList = [{ label: this.make, value: this.makeCodeOfProduct }];//CISP-2794
                            this.modelOptionsList = [{ label: this.model, value: this.modelCodeOfProduct }];//CISP-2794
                            this.variantOptionsList = [{ label: this.variant, value: this.variantCodeOfProduct }];//CISP-2794
                            //CISP-3705 start
                            if((this.leadSource?.includes('Digital-MSIL-Custom') || this.leadSource?.includes('Digital-Mahindra-Custom') || this.leadSource?.includes('Digital-Mahindra-PreA')) || (this.parentLeadId && (this.parentLeadSource?.includes('Digital-MSIL-Custom') || this.parentLeadSource?.includes('Digital-Mahindra-Custom') || this.parentLeadSource?.includes('Digital-Mahindra-PreA'))) && this.product == 'Passenger Vehicles'){ //CISP-15890
                                this.mmvDisable = true;//CISP-3425
                                this.d2cMMVDisable = true;//CISP-4633
                                this.isDealerFieldDisabled = false;
                                if(this.isD2cApplication){
                                    this.isDealerFieldDisabled = true;
                                }
                            }//CISP-3705 end
                        }
                        console.log('this.makeOptionsList : ',this.makeOptionsList);
                        console.log('this.modelOptionsList : ',this.modelOptionsList);
                        console.log('this.variantOptionsList : ',this.variantOptionsList);
                        //Fetch Dealer/SubDealer based on the Model and Product Type
                        this.fetchDealerSubDealer();
                    }).catch(error => {
                        console.log('Error - getMMVNameBasedOnCode: ', error);
                    });
                }
                //Common Fields from Vahhan and Deal Master API - Engine_Number/Engine_No, Chassis_Number/Chassis_No, Make, Model, Variant, Manufacture_Year_Month, No_of_Ownership
                //Common Fields from Vahhan and Deal Master API - Owner_Name, Insurance_Number, Insurer_Name, Ins_Issuance_Date, Ins_Expiry_Date, Owner_Contact_Number, Vehicle_Place_of_Valuation
                //Validate Priority - If updated by Vahhan API then SKIP
                if (!this.engineNumber) {
                    this.engineNumber = dealMasterResponse?.response.content[0]?.Engine_Number;}
                if (!this.chassisNumber) {
                    this.chassisNumber = dealMasterResponse?.response.content[0]?.Chassis_Number;}
                if (!this.manufacturerYearAndMonth) {
                    this.manufacturerYearAndMonth = dealMasterResponse?.response.content[0]?.Manufacture_Year_Month;}
                if (!this.lastOwnerName) {
                    this.lastOwnerName = dealMasterResponse?.response.content[0]?.Owner_Name;}
                if (!this.numberOfOwnerships) {
                    //ALlow No Of Ownership to store only if it contains in Picklist
                    let noOfOwnership = dealMasterResponse?.response.content[0]?.No_of_Ownership;
                    if (noOfOwnership) {
                        this.numberOfOwnershipsOptionsList.forEach((obj) => {
                            if (obj.value === noOfOwnership) {
                                this.numberOfOwnerships = noOfOwnership;
                                return true;
                            }
                        });
                    }
                }
                //Insurance fields - Future module fields
                if (!this.insExpiryDate) {
                    this.insExpiryDate = dealMasterResponse?.response.content[0]?.Ins_Expiry_Date;}
                if (!this.insIssuanceDate) {
                    this.insIssuanceDate = dealMasterResponse?.response.content[0]?.Ins_Issuance_Date;}
                if (!this.insurancNumber) {
                    this.insurancNumber = dealMasterResponse?.response.content[0]?.Insurance_Number;}
                if (!this.insurerName) {
                    this.insurerName = dealMasterResponse?.response.content[0]?.Insurer_Name;}
                //Future module fields
                if (!this.ownerContactNumber) {
                    this.ownerContactNumber = dealMasterResponse?.response.content[0]?.Owner_Contact_Number;}
                if (!this.vehiclePlaceOfValuation) {
                    this.vehiclePlaceOfValuation = dealMasterResponse?.response.content[0]?.Vehicle_Place_of_Valuation;}
                if (scope == 'VehicleDetails') {
                    this.isGetVehicleDetailsSuccessful = true;this.showSuccessTick = true;this.disableGetVehicleDetails = true;}
                this.showToastMessage(null, 'Successfully fetched Vehicle Details from Deal Master API', 'Success');
            } else {
                throw 'Deal Master API Error';
            }
        } catch (error) {
            console.log('Error in Proccessing Deal Master API Response');
            ++this.dealMasterAPIRetryCount;
            this.showSpinner = false;
            if (this.dealMasterAPIRetryCount < 4) {
                this.modalMsg = 'Error is fetching details from Deal Master API, Kindly Retry<br/>Retry Count:: ' + this.dealMasterAPIRetryCount;
            } else {
                this.modalMsg = 'Retry attempt exhausted, Kindly enter manually';
            }
            if (scope === 'MMV') {
                this.make = null;this.model = null;this.variant = null;this.dealerSubDealerName = null;
                this.makeOptionsList = null;this.modelOptionsList = null;this.variantOptionsList = null;this.dealerSubDealerOptionsList = null;
                this.showToastMessageModeBased('Journey cannot proceed as MMV details are not populated', 'Kindy retry by clicking on Get Vehicle Details button', 'error', 'sticky');
            }
            return;
        }
    }
    //Deal Master API Call
    async dealMasterAPICall() {
        let apiStatus = { 'isSuccessful': false, 'response': null };
        await doDealMasterCallout({ applicantId: this.applicantId, loanAppId: this.recordid }).then(result => {
            const obj = JSON.parse(result);
            console.log('Deal Master Response:: ', obj);
            if (obj.response.status === 'SUCCESS') {
                apiStatus.isSuccessful = true;apiStatus.response = obj;
            } else {
                apiStatus.isSuccessful = false;apiStatus.response = 'Deal Master API failed';
            }
        }).catch(error => {
            apiStatus.isSuccessful = false;
            apiStatus.response = 'Error in executing Deal Master API - ' + error;
        });
        return apiStatus;
    }
    //Vahaan and Vaahan Report APIs
    async executeVaahanAPIs() {
        let vahanRequest = {
            'leadId': this.leadNumber,
            'vehicleRegisterationNumber': this.vehicleRegNoValue,
            'loanApplicationId': this.recordid
        };
        //1.1 Vaahan API
        await doVahanVehicleValuationCallout({ 'vahanVehicleValuation': JSON.stringify(vahanRequest) }).then(result => {
            const obj = JSON.parse(result);
            console.log('Vahan API Response - Parsed Result:: ', obj);
            if (obj.response.status === 'SUCCESS') {
                this.showToastMessage(null, obj.response.respDesc, 'Success');
            } else {
                throw 'Vaahan API Error';
            }
        }).catch(error => {
            console.log('Vaahan API Error:: ', error);
            ++this.vaahanAPIRetryCount;
            this.showSpinner = false;
            if (this.vaahanAPIRetryCount > 1) {
                this.modalMsg = 'Error is fetching details from Vaahan API again, Details will be fetched from Deal Master API now';
            } else if (this.dealNumber === null || this.dealNumber === '') {
                this.modalMsg = 'Kindly fill details manually';
            } else {
                this.modalMsg = 'Error is fetching details from Vaahan API, Kindly Retry';
            }
            //this.showPopupModal = true;
            throw new Error('Error in Vaahan API. Explicitly aborted to prevent Async execution, Retry Count:: ', this.vaahanAPIRetryCount);
        });
        await getDelayTime().then(resultOfDelayTime => {
            this.delaytime = resultOfDelayTime;
            console.log('this.delaytime:: ', this.delaytime);
            this.showToastMessage(null, 'Processing may take several minutes', 'info');
        }).catch(error => {
            console.log('Error in Get time Delay:: ', error);
            this.showSpinner = false;
            return;
        });
        let promise = new Promise((resolve, reject) => {
            setTimeout(() => resolve('Execute Report API'), this.delaytime);
        });
        if (await promise) {
            let vahanReportRequest = {
                'leadId': this.leadNumber,
                'vehicleRegisterationNumber': this.vehicleRegNoValue,
                'loanApplicationId': this.recordid
            };
            //1.2 Vaahan Report API
            await doVahanVehicleReportCallout({ 'vahanVehicleReport': JSON.stringify(vahanReportRequest) }).then(result => {
                const obj = JSON.parse(result);
                console.log('Vehicle Report API:: ', obj);
                if (obj.response.status === 'SUCCESS') {
                    //In case of (RLY, RLN, UIM, URS, URV, UEB) Vehicle Category,
                    //dealerSubDealerName - Can be populated from Masters
                    //lastOwnerName, engineNumber, chassisNumber - Can be populated by Deal Master API
                    //If these values will be populated the those can be override
                    //In case of (RLY, RLN, UIM, URS, URV, UEB) Vehicle Category, These values will be stored from this API only
                    if (obj.response?.content[0]?.Owner_Name) {
                        this.lastOwnerName = obj.response?.content[0]?.Owner_Name;
                    }
                    if (obj.response?.content[0]?.Engine_No) {
                        this.engineNumber = obj.response?.content[0]?.Engine_No;
                    }
                    if (obj.response?.content[0]?.Chassis_No) {
                        this.chassisNumber = obj.response?.content[0]?.Chassis_No;
                    }
                    //CISP-2816 Dealer name should not be overwritten in any case 
                    //CISP-2826 - START
                    /*if(!this.isDealerFieldDisabled){
                        if (obj.response?.content[0]?.Dealer) {
                            this.dealerSubDealerName = obj.response?.content[0]?.Dealer;
                        }
                        this.dealerSubDealerOptionsList = [{ label: this.dealerSubDealerName, value: this.dealerSubDealerName }];
                    }*/
                    //CISP-2826 - END
                    //CISP-2816 END

                    //Insurance fields - Future module fields
                    if (obj.response?.content[0]?.Ins_Expiry_Date) {
                        this.insExpiryDate = obj.response?.content[0]?.Ins_Expiry_Date;
                    }
                    if ((this.insExpiryDate !== null || this.insExpiryDate === '') && (this.insExpiryDate !== undefined)) {
                        this.insExpiryDate = this.insExpiryDate.substring(this.insExpiryDate.lastIndexOf(" ") + 1);
                    }                    
                    if (obj.response?.content[0]?.Ins_Issuance_Date) {
                        this.insIssuanceDate = obj.response?.content[0]?.Ins_Issuance_Date;
                    }
                    if (obj.response?.content[0]?.Insurance_Number) {
                        this.insurancNumber = obj.response?.content[0]?.Insurance_Number;
                    }
                    if (obj.response?.content[0]?.Insurer_Name) {
                        this.insurerName = obj.response?.content[0]?.Insurer_Name;
                    }
                    this.isGetVehicleDetailsSuccessful = true
                    this.disableGetVehicleDetails = true;
                    this.showSuccessTick = true;
                    this.showToastMessage(null, 'Vahan Vehicle Report Fetched Successfully', 'Success');
                    return true;
                } else {
                    throw 'Vaahan Report API Error';
                }
            }).catch(error => {
                console.log('Error in doVahanVehicleReportCallout - Catch:: ', error);
                ++this.vaahanAPIRetryCount;
                this.showSpinner = false;
                this.isGetVehicleDetailsSuccessful = false;
                if (this.vaahanAPIRetryCount > 1) {
                    this.modalMsg = 'Error is fetching details from Vaahan API again, Details will be fetched from Deal Master API now';
                } else if (this.dealNumber === null || this.dealNumber === '') {
                    this.modalMsg = 'Kindly fill details manually';
                } else {
                    this.modalMsg = 'Error is fetching details from Vaahan API, Kindly Retry';
                }
                this.showPopupModal = true;
                throw new Error('Error in Vaahan Report API. Explicitly aborted to prevent Async execution. Retry Count:: ', this.vaahanAPIRetryCount);
            });
        }
    }
    //Eligible loan amount and eligible tenure will be fetched on the basis of deal number
    //Applicable for (RLY, RLN, UIM, URS, URV, UEB) Vehicle Category
    async executeEligibleRefinanceAPI() {
        if (this.vehicleSubcategory === 'RLY' || this.vehicleSubcategory === 'RLN' || this.vehicleSubcategory === 'UIM' || this.vehicleSubcategory === 'URS' || this.vehicleSubcategory === 'URV' || this.vehicleSubcategory === 'UEB') {
            if (!this.dealNumber) {
                this.showToastMessage('Missing Deal Number', 'Application cannot be move ahead without deal number', 'error');
                this.showSpinner = false;
                return;
            }
            await doDealEligibleRefinanceCallout({ 'opportunityId': this.recordid }).then(response => {
                let result = JSON.parse(response);
                console.log('Eligible Master API Response:==>', result);
                this.eligibilityLoanAmount = result?.response?.content[0]?.EligibilityAmount;
                this.tenureInMonths = result?.response?.content[0]?.Tenure_In_Months;
                this.showToastMessage('Sucessfully executed Eligible Refinance API', 'Details are updated for future use', 'success');
            }).catch(error => {
                console.log('Eligible Master API Error:==>', error);
                this.showToastMessage('Error in getting details from Eligible Master API', error?.body?.message, 'error');
                this.showSpinner = false;
                return;
            });
        }
    }
    handleModalBtnAction(event) {
        this.showPopupModal = false;
        this.modalMsg = null;
        this.showSpinner = false;
        if(this.isTractor) {
            if(this.index) {
                event.target.dataset.index = this.index;
                this.handleGetVehicleDetailsTractor(event);
            }
        } else{
            this.handleGetVehicleDetails();
        }
    }
    selectedMakeHandler(event) {
        this.makeId = event.detail.selectedValueId;this.make = event.detail.selectedValueName;
    }
    selectedModelHandler(event) {
        this.modelId = event.detail.selectedValueId;this.model = event.detail.selectedValueName;
    }
    selectedVariantHandler(event) {
        this.variantId = event.detail.selectedValueId;this.variant = event.detail.selectedValueName;
    }
    async validityCheck(query) {
        console.log(this.template.querySelectorAll(query));
        return await [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }
    async handleHome() {
        this.fromHome = true;
        if(this.isTractor) {
            await helper.saveAssetDetailsTractor(this).then(submitResult=>{
                console.log('Check Submit MAP :: ',submitResult.allowedNavigate);
                if(submitResult.allowedNavigate){
                    this.goToHome();
                }
            }).catch(error => {
                console.log('Error In Saving Details - Error:: ', error);
            });
        } else{
            await this.saveAssetDetails().then(submitResult=>{
                console.log('Check Submit MAP :: ',submitResult.allowedNavigate);
                if(submitResult.allowedNavigate){
                    this.goToHome();
                }
            }).catch(error => {
                console.log('Error In Saving Details - Error:: ', error);
            });
        }
    }
    goToHome(){
        isCommunity().then(response => {
            if (response) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'home'
                    },
                });
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Home'
                    }
                });
            }
        }).catch(error => {
            console.log(error);
        });
    }
    async createRecordDetails(objectApiName, fields) {
        await createRecord({ apiName: objectApiName, fields: fields }).then(obj => {
            console.log('Record created Successfully:: ', JSON.stringify(fields));
            this.vehicleDetailId = obj.id;
            this.showToastMessage('Success', this.labels.AssetDetailsSaved, 'Success');
            return true;
        }).catch(error => {
            console.log('Error in creating reocrd:: ', JSON.stringify(error))
            this.showSpinner = false;
            this.showToastMessage(null, 'Error in saving details', 'Error');
        });
    }
    async updateRecordDetails(fields) {
        await updateRecord({ fields }).then(() => {
            console.log('Record updated Successfully:: ', JSON.stringify(fields));
            this.showToastMessage('Success', this.labels.AssetDetailsSaved, 'Success');
            return true;
        }).catch(error => {
            console.log('Error in updating reocrd:: ', JSON.stringify(error));
            this.showSpinner = false;
            this.showToastMessage(null, 'Error in saving details', 'Error');
        });
    }
    showToastMessage(title, message, variant) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
            }));
        }
    }
    showToastMessageModeBased(title, message, variant, mode) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
                mode: mode,
            }));
        }
    }
    async navigateToNextModule() {
        console.log('Inside Navigate Module :', this.vehicleType);
        let nextStage = 'Loan Details';
        if (this.vehicleType === 'Used' || this.vehicleType === RefinanceLabel) {
            nextStage = 'Vehicle Insurance';
        }
        console.log('Navigation Next stage:: ', nextStage);
        console.log('Navigation Record Id:: ', this.recordid);
        await changeStage({ stageName: nextStage, loanApplicationId: this.recordid }).then(response => {
            console.log('Inside Change Stage: ', response);
            if (response) {
                console.log('Positive Response:: ', response);
                this.callLoanApplicationHistory(nextStage);
            } else {
                console.log('Negative Response:: ', response);
                this.showToastMessage('Error in navigating to next module', null, 'error');
            }
            this.showSpinner = false;
        }).catch(error => {
            console.log(error);
        });
    }
    callLoanApplicationHistory(nextStage){
        getLoanApplicationHistory({ loanId: this.recordid, stage: 'Asset Details',nextStage: nextStage}).then(response => {
          if(response){ console.log('getLoanApplicationHistory Response:: ', response);
              this.goToHome();
          }else{
            console.log('else Response:: ', response);
            this.dispatchEvent(new CustomEvent('expirydateupdated', { detail: 'null' }));
            this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage }));
            this.showToastMessage('Details submitted successfully', null, 'success');
            //prashanth
            if(nextStage === 'Vehicle Insurance'){
                this.disableEverything();
            }
          }
        }).catch(error => {
            console.log('Error in getLoanApplicationHistoryr:: ', error);
        });
    }
    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordid , stage: 'Asset Details'}).then(response => {
            console.log('accessLoanApplication Response:: ', response);
            if(!response){ 
                this.disableEverything();
                console.log('here 2');
                if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that                  
                    const evt = new ShowToastEvent({
                        title: ReadOnlyLeadAccess,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    this.disableEverything();
                }
            }
          }).catch(error => {
              console.log('Error in accessLoanApplication:: ', error);
          });
    }
    async updateRecordDetails(fields) {
        let returnFlag = false;
        const recordInput = { fields };
        await updateRecord(recordInput).then(() => {
            console.log('Data Updated');
            returnFlag = true;
        }).catch(error => {
            console.log('Update error', error);
        });
        return returnFlag;
    }
    async validateVehicleCatogory() {
        if ((this.product == 'Passenger Vehicles')) {    
            await validateDVehicleCategory({ sModel: this.model, loanApplicationId: this.recordid }).then(response => {
                this.isDCategoryAsset = response;
            }).catch(error => {
                console.log('Error in getting vehicle category from MMV Master:: ', error);
            });
        }
    }
    async handleSubmit() {
        if(this.isTractor) {
            this.showSpinner = true;
            let isValid = true
            for (let index = 0; index < this.assetDetailList.length; index++) {
                const item = this.assetDetailList[index];
                try{
                    if (item.allowSubmit === false && !item.isImplement) {
                        this.showSpinner = false;
                        this.showToastMessage('Get Vehicle Details for all before Submit', null, 'warning');
                        isValid = false;
                        break;
                    }
                    let inputValid = await this.validityCheck('lightning-input');  
                    let comboValid = await this.validityCheck('lightning-combobox');  
                    if (!inputValid || !comboValid) {
                        this.showSpinner = false;
                        this.showToastMessage('Fill all the fields', null, 'warning');
                        isValid = false;
                        break;
                    }
                    if((item.leadSource == 'OLA' || item.leadSource == 'Hero') && (item.makeCodeOfProduct == null || item.modelCodeOfProduct == null || item.variantCodeOfProduct == null )){
                        this.showSpinner = false;
                        this.showToastMessage('make or model or variant fields should not be blank', null, 'error');
                        isValid = false;
                        break;
                    }
                }catch(error){
                    this.showSpinner = false;
                    isValid = false;
                    break;
                }
            }
            if(isValid == true){
                await helper.saveAssetDetailsTractor(this);
            }
        } 
        else {
            this.showSpinner = true;

            if (this.allowSubmit === false && (this.vehicleType === 'Used' || this.vehicleType === RefinanceLabel)) {
                this.showSpinner = false;
                this.showToastMessage('Get Vehicle Details before Submit', null, 'warning');
                return;
            }
            let comboValid = await this.validityCheck('lightning-combobox');  
            let inputValid = await this.validityCheck('lightning-input');  
            if (!inputValid || !comboValid) {  
                this.showSpinner = false;
                this.showToastMessage('Fill all the fields', null, 'warning');
                return;
            }
            console.log('makevalues',this.makeCodeOfProduct);
            console.log('modelvalues',this.modelCodeOfProduct);
            console.log('variantvalues',this.variantCodeOfProduct);
            if((this.leadSource == 'OLA' || this.leadSource == 'Hero') && (this.makeCodeOfProduct ==null || this.modelCodeOfProduct ==null || this.variantCodeOfProduct ==null )){//OLA-146
                this.showSpinner = false;
                this.showToastMessage('make or model or variant fields should not be blank', null, 'error');
                return;
            }
            if (this.purposeOfPurchase === 'Commercial') {
                // Validate the viability fields
                if (!this.distance || !this.grossReceipts || !this.numberOfVehicles || !this.expense || !this.route) {
                    this.showSpinner = false;
                    this.showToastMessage('Fill all the fields', null, 'warning');
                    return;
                }
            }

            await this.validateVehicleCatogory();

            await this.saveAssetDetails();
        }
    }
    //CISP-4459 start
    journeyStopScenarioFound(){
        updateJourneyStop({ leadNo: this.recordid })
        .then(result => {
            console.log('Result', result);
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }//CISP-4459
    async saveAssetDetails(){
        let dealerName;let benCode;
        let saveStatus = {'allowedNavigate': false,'saveMessage': ''};
        //Split logic for Ben Code
        if(this.dealerSubDealerName){
            let splitBenCode = this.dealerSubDealerName.split('|');
            dealerName = splitBenCode[0];benCode = splitBenCode[1];
        }
        const fields = {};
        //Save Operation - New and Used vehicle Type Common fields 
        fields[RC_limit_enabled_Dealer.fieldApiName] = this.isRcLimitChecked;//CISP-8762
        fields[VEHICLE_TYPE_FIELD.fieldApiName] = this.vehicleType;
        fields[PRODUCT_FIELD.fieldApiName] = this.product; //-> 'C' 
        fields[MAKE_FIELD.fieldApiName] = this.make;
        fields[MAKE_CODE.fieldApiName] = this.makeCodeOfProduct;//CISP-2794
        fields[MODEL_FIELD.fieldApiName] = this.model;
        fields[MODEL_CODE.fieldApiName] = this.modelCodeOfProduct;//CISP-2794
        fields[VARIANT_FIELD.fieldApiName] = this.variant;
        fields[VARIANT_CODE.fieldApiName] = this.variantCodeOfProduct;//CISP-2794
        fields[PRODUCT_SEGMENT.fieldApiName] = this.segmentCode;//CISP-13665
        fields[PURPOSE_OF_PURCHANSE_FIELD.fieldApiName] = this.purposeOfPurchase;
        fields[DEALER_SUBDEALER_NAME_FIELD.fieldApiName] = dealerName;
        fields[BEN_CODE_FIELD.fieldApiName] = benCode;
        fields[INVOICE_IN_THE_NAME_FIELD.fieldApiName] = this.invoiceInNameOf;
        fields[VEHICLE_REGISTERED_NAME_FIELD.fieldApiName] = this.vehicleRegisteredInNameOf;
        fields[DISTANCE_FIELD.fieldApiName] = this.distance; //commercial pv
        fields[GROSS_RECEIPTS_MONTH_FIELD.fieldApiName] = this.grossReceipts; //commercial pv
        fields[NUMBER_OF_VEHICLE_OWNED_FIELD.fieldApiName] = this.numberOfVehicles; //commercial pv
        fields[EXPENSE_FIELD.fieldApiName] = this.expense; //commercial pv
        fields[VEHICLE_ROUTE_FIELD.fieldApiName] = this.vehicleRoute; //commercial pv
        fields[ROUTE_FIELD.fieldApiName] = this.route; //commercial pv

        //Used vehicle Type Specific fields
        if (this.vehicleType === 'Used' || this.vehicleType === RefinanceLabel) {
            fields[USAGE_TYPE_FIELD.fieldApiName] = this.usageType;
            fields[VEHICLE_REG_NUMBER_FIELD.fieldApiName] = this.vehicleRegNoValue;
            fields[MANUFACTURER_YEAR_MONTH_FIELD.fieldApiName] = this.manufacturerYearAndMonth;
            fields[LAST_OWNER_NAME_FIELD.fieldApiName] = this.lastOwnerName;
            fields[ENGINE_NUMBER_FIELD.fieldApiName] = this.engineNumber;
            fields[CHASSIS_NUMBER_FIELD.fieldApiName] = this.chassisNumber;
            fields[LIEN_IN_FAVOR_FIELD.fieldApiName] = this.lienInFavorOf;
            fields[RC_RETENTION_APPLICABLE_FIELD.fieldApiName] = this.rcRetentionApplicable;
            fields[IS_GET_VEHICLE_DETAILS_SUCCESSFUL_FIELD.fieldApiName] = this.isGetVehicleDetailsSuccessful;
            //Restricted Picklist value check
            if (this.numberOfOwnerships) {
                this.numberOfOwnershipsOptionsList.forEach((obj) => {
                    if (obj.value === this.numberOfOwnerships) {//CISP-2998
                        fields[NUMBER_OF_OWNERSHIP_FIELD.fieldApiName] = this.numberOfOwnerships;
                        return true;
                    }
                });
            }
            //Vehicle Insurance Fields
            fields[INSURER_NAME_FIELD.fieldApiName] = this.insurerName;
            fields[INSURANCE_NUMBER_FIELD.fieldApiName] = this.insurancNumber;
            // fields[INS_ISSUANCE_DATE_FIELD.fieldApiName] = this.insIssuanceDate;
            console.log('Ins Expiry Date1:: ', this.insExpiryDate);
            if (this.insExpiryDate) {
                let insExpiryDateFormat = this.insExpiryDate.substring(this.insExpiryDate.lastIndexOf(" ") + 1);
                console.log("Expiry insExpiryDateMM ", insExpiryDateFormat);
                let dateObj = new Date(insExpiryDateFormat);
                // Date Conversion DD-MMM-YYYY to DD-MM-YYYY
                let dd = dateObj.getDate();let mm = dateObj.getMonth() + 1;let yyyy = dateObj.getFullYear();
                let insExpiryDateMM = dd+'-'+mm+'-'+yyyy
                console.log("Expiry insExpiryDateMM ", insExpiryDateMM); 
                let insExpiryDatee = insExpiryDateMM.replace(/\b\d\b/g, '0$&');     
                this.insExpiryDate = insExpiryDatee.split("-").reverse().join("-");
                console.log('Expiry Date Submit ',this.insExpiryDate);
                // fields[INS_EXPIRY_DATE_FIELD.fieldApiName] = this.insExpiryDate;
            }
            //Eligiible API fields
            fields[ELIGIBLE_LOAN_AMT_FIELD.fieldApiName] = this.eligibilityLoanAmount;
            fields[ELIGIBLE_TENURE_FIELD.fieldApiName] = this.tenureInMonths;
            //Vehicle Valuation Fields
            fields[OWNER_NAME_FIELD.fieldApiName] = this.lastOwnerName;
            fields[OWNER_CONTACT_FIELD.fieldApiName] = this.ownerContactNumber;
            fields[VEHICLE_PLACE_VALUATION_FIELD.fieldApiName] = this.vehiclePlaceOfValuation;
        }
        if (this.isDCategoryAsset) {
            fields[IS_D_CATEGORY_VEHICLE_FIELD.fieldApiName] = true;}
        console.log('Vehicle Id :: ', this.vehicleDetailId);
        if (this.vehicleDetailId === '' || this.vehicleDetailId === null) {
            fields[LOAN_APPLICATION.fieldApiName] = this.recordid;
            fields[LOAN_NUMBER.fieldApiName] = this.recordid;
            console.log('Create fields:: ', fields);
            await createRecordUsingApex({ 'apiName': VEHICLE_DETAIL.objectApiName, 'fields': JSON.stringify(fields) , 'loanApplicationId':this.recordid}).then(obj => {
                console.log('LOG:: ', obj);
                    if (obj) {
                        this.vehicleDetailId = obj;
                        const fields = {};
                        fields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleDetailId;
                        if(this.insIssuanceDate){
                            fields[INS_ISSUANCE_DATE_FIELD.fieldApiName] = this.insIssuanceDate;
                        }
                        if(this.insExpiryDate){
                            fields[INS_EXPIRY_DATE_FIELD.fieldApiName] = this.insExpiryDate;
                        }
                        const recordInput = { fields };
                        console.log('Update fields:: ', recordInput);
                        updateRecord(recordInput).then(result=>{console.log('updated');})
                }
                if(!this.fromHome){
                    // if (!this.isDCategoryAsset) {
                        this.navigateToNextModule();
                    // } else {
                    //     this.showSpinner = false;
                    //     this.showToastMessageModeBased('', 'Journey is stopped because of D Category Asset', 'Error', 'sticky');
                    //     this.journeyStopScenarioFound(); //CISP-4459
                    // }
                }
                saveStatus.allowedNavigate = true;
                saveStatus.saveMessage = 'Navigation Success';
                console.log('Record created Successfully:: ', JSON.stringify(fields));
            }).catch(error => {
                console.log('Error in creating reocrd:: ', JSON.stringify(error))
                this.showSpinner = false;
                this.showToastMessage(null, 'Error in saving details', 'Error');
                saveStatus.allowedNavigate = false;
                saveStatus.saveMessage = 'Navigation Fail';
            });
        } else {
            console.log('Vehicle Detailed ID for update:: ', this.vehicleDetailId);
            fields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleDetailId;
            if(this.insIssuanceDate){
                fields[INS_ISSUANCE_DATE_FIELD.fieldApiName] = this.insIssuanceDate;
            }
            if(this.insExpiryDate){
                fields[INS_EXPIRY_DATE_FIELD.fieldApiName] = this.insExpiryDate;
            }
            const recordInput = { fields };
            console.log('Update fields:: ', recordInput);
            await updateRecord(recordInput).then(() => {
                if(!this.fromHome){        
                        this.navigateToNextModule();
                }
                saveStatus.allowedNavigate = true;
                saveStatus.saveMessage = 'Navigation Success';
                console.log('Record Updated Successfully:: ', JSON.stringify(fields));
                console.log('Navigation Values:: ', saveStatus);
                //return true;
            }).catch(error => {
                console.log('Error in updating reocrd:: ', error);
                this.showSpinner = false;
                this.showToastMessage(null, 'Error in saving details', 'Error');
                saveStatus.allowedNavigate = false;
                saveStatus.saveMessage = 'Navigation Fail';
            });
        }
        return saveStatus;
    }
    viewUploadViewFloater(){
        this.showFileUploadAndView = true;
    }
    closeUploadViewFloater(event){this.showFileUploadAndView = false;}
    disableEverything(){let allElements = this.template.querySelectorAll('*');allElements.forEach(element =>element.disabled = true);this.isDealerFieldDisabled = true;}
}