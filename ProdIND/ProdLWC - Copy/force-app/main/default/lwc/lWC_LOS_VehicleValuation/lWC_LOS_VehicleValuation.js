import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues , getObjectInfo} from 'lightning/uiObjectInfoApi'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { loadStyle } from 'lightning/platformResourceLoader';

import vehicleValuation from '@salesforce/label/c.vehicleValuation';
import empanelled from '@salesforce/label/c.Empanelled';
import mfc from '@salesforce/label/c.MFC';
import indusIndHome from '@salesforce/label/c.IndusInd_Home';
import VehicleImage from '@salesforce/label/c.VehicleImage';
import RC_Copy from '@salesforce/label/c.RC_Copy';
import LightningCardApplyCSS from '@salesforce/resourceUrl/loanApplication';
import getVehicleValuationDetails from '@salesforce/apex/Ind_VehicleValuationController.getVehicleValuationDetails';
import checkIBBAPIAttempts from '@salesforce/apex/Ind_VehicleValuationController.checkIBBAPIAttempts';
import checkVehicleDocumentsDetails from '@salesforce/apex/Ind_VehicleValuationController.checkVehicleDocumentsDetails';
import VEHICLE_DETAIL_OBJECT from '@salesforce/schema/Vehicle_Detail__c';
import VEHICLE_ID_FIELD from '@salesforce/schema/Vehicle_Detail__c.Id';
import OWNER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Owner_Name__c';
import OWNER_CONTACT_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Owner_Contact_Number__c';
import VEHICLE_PLACE_VALUATION_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Place_Of_Valuation__c';
import LOCATION_OF_VEHICLE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Location_Of_Vehicle__c';
import EXECUTIVE_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Executive_name__c';
import EXECUTIVE_CONTACT_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Executive_Contact_Number__c';
import VALUER_CATEGORY_FIELD from '@salesforce/schema/Vehicle_Detail__c.Valuer_category__c';
import VALUER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Valuer__c';
import VALUER_CODE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Valuer_code__c';
import SLA_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.SLA_Number__c';
import SELLING_PRICE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Selling_Price__c';
import VALUATION_PRICE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Valuation_price__c';
import INSURANCE_DECLARED_VALUE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_declared_value__c';
import COLOR_OF_VEHICLE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Color_of_Vehicle__c';
import KMS_RUN_FIELD from '@salesforce/schema/Vehicle_Detail__c.KMS_Run__c';
import PURPOSE_OF_IBB_FETCH_FIELD from '@salesforce/schema/Vehicle_Detail__c.Purpose_of_IBB_fetch__c';
import GRID_VALUE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Grid_value__c';
import STATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.State__c';
import CITY_FIELD from '@salesforce/schema/Vehicle_Detail__c.City__c';
import MFC_STATE_MASTER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Details_MFC_State_Master__c';
import MFC_CITY_MASTER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Details_MFC_City_Master__c';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';

import createDocument from '@salesforce/apex/GenericUploadController.createOtherDocument';
import fetchDocument from '@salesforce/apex/Ind_IncomeDetailsCtrl.fetchDocument';
import retryExhaustedLabel from '@salesforce/label/c.Retry_Exhausted';
import mcfSuccessResponse from '@salesforce/label/c.MFC_Success_Response';
import selectValuerCategory from '@salesforce/label/c.Select_Valuer_Category';
import getValuationDoneFirst from '@salesforce/label/c.Get_Valuation_Done_First';
import MFCApiFail from '@salesforce/label/c.MFCApiFail';
import fillAllRequiredFields from '@salesforce/label/c.Fill_All_Required_Fields';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import Borrower from '@salesforce/label/c.Borrower';


import OriginalCopyForRCDoc from '@salesforce/label/c.Original_Copy_for_RC_Document_is_not_Captured';
import vehicleInsurancePolicyNotCaptured from '@salesforce/label/c.Vehicle_Insurance_Policy_not_Captured';
import vehicleValuationDetailsSaved from '@salesforce/label/c.Vehicle_Valuation_Details_Saved';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import JOURNEY_STATUS_FIELD from '@salesforce/schema/Opportunity.Journey_Status__c';

import doIbbMasterCallout from '@salesforce/apexContinuation/IntegrationEngine.doIbbMasterCallout';
import doMFCFetchValuationReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doMFCFetchValuationReportCallout';
import doMFCValuationCallout from '@salesforce/apexContinuation/IntegrationEngine.doMFCValuationCallout';

import getPicklistValuesForValuer from '@salesforce/apex/Ind_VehicleValuationController.getPicklistValuesForValuer';
import setOEMFlag from '@salesforce/apex/Ind_VehicleValuationController.setOEMFlag';
import id from '@salesforce/user/Id';
import getStateMasterData from '@salesforce/apex/Utilities.getMFCStateMasterData';
import getCityStateMaster from '@salesforce/apex/Utilities.getMFCCityMasterBasedOnStateCode';
import LoanApplicationId from '@salesforce/label/c.LoanApplicationId';
import VehicleLeadId from '@salesforce/label/c.VehicleLeadId';
import VehicleRegisterationNumber from '@salesforce/label/c.VehicleRegisterationNumber';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import getApplicantId from '@salesforce/apex/Utilities.getApplicantId';

import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';
import DOCUMENT_TYPE_FIELD from '@salesforce/schema/Documents__c.Document_Type__c';
import DOCUMENT_NAME_FIELD from '@salesforce/schema/Documents__c.Name';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import lastNameError from '@salesforce/label/c.Last_Name_Error';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import RegEx_Number from '@salesforce/label/c.RegEx_Number';
import Mobile_Number_Error_Msg from '@salesforce/label/c.Mobile_Number_Error_Msg';
import AddressValidation1 from '@salesforce/label/c.AddressValidation1';
import AddressValidation2 from '@salesforce/label/c.AddressValidation2';
import AddressValidation3 from '@salesforce/label/c.AddressValidation3';
import KycAddress1Pattern from '@salesforce/label/c.KycAddress1Pattern';
import KycAddress2Pattern from '@salesforce/label/c.KycAddress2Pattern';
import reportGeneratedMessage from '@salesforce/label/c.MFCReportGeneratedMessage';
import SellingPricemessage from '@salesforce/label/c.SellingPricemessage';
import Loanamount10000 from '@salesforce/label/c.Loanamount10000';
import Loanamount175000 from '@salesforce/label/c.Loanamount175000';
import LoanAmount200000000 from '@salesforce/label/c.LoanAmount200000000';
import LoanAmount50000 from '@salesforce/label/c.LoanAmount50000';
import enterLoanAmount from '@salesforce/label/c.enterLoanAmount';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import fetchGridValue from '@salesforce/apex/Ind_VehicleValuationController.fetchGridValue';
import fetchGridValueForTractor from '@salesforce/apex/Ind_VehicleValuationController.fetchGridValueForTractor';
import checkImageExist from '@salesforce/apex/Ind_IncomeDetailsCtrl.checkImageExist';
import doVehicleValuationCallout from '@salesforce/apex/D2C_IntegrationEngine.doVehicleValuationCallout';
import MFC_Request_Id from '@salesforce/schema/Vehicle_Detail__c.MFC_Request_Id__c';
import VALUATION_REPORTURL_FIELD from '@salesforce/schema/Vehicle_Detail__c.MFC_valuation_Report_URL__c';
import VALUATION_OverallRemarks_FIELD from '@salesforce/schema/Vehicle_Detail__c.Overall_Remarks__c';
import is_OEM_Dealer_Checked from '@salesforce/schema/Vehicle_Detail__c.isOEMDealerChecked__c';
import getMFCUniqueResponse from '@salesforce/apex/Ind_VehicleValuationController.getMFCUniqueResponse';//CISP-2455
import saveMFCResponseRecord from '@salesforce/apex/Ind_VehicleValuationController.saveMFCResponseRecord';//CISP-2455
import getParentLeadNumber from '@salesforce/apex/Ind_VehicleValuationController.getParentLeadNumber'//CISP-2737
import MFC_Valuation_Report_Date from '@salesforce/schema/Vehicle_Detail__c.MFC_Valuation_Report_Date__c';
export default class LWC_LOS_VehicleValuation extends NavigationMixin(LightningElement) {
    mfcGenerationDate;
    isRevokedApp = false;//CISP-2737
    parentLeadNo = '';//CISP-2737
    @track isMFCPresent = false;//CISP-2455
    label = {
        LoanApplicationId,
        VehicleLeadId,
        VehicleRegisterationNumber,
        vehicleValuation,
        retryExhaustedLabel,
        mcfSuccessResponse,
        selectValuerCategory,
        getValuationDoneFirst,
        fillAllRequiredFields,
        vehicleValuationDetailsSaved,
        empanelled,
        mfc,
        indusIndHome,
        RC_Copy,
        VehicleImage,
        reportGeneratedMessage,
        OriginalCopyForRCDoc,
        vehicleInsurancePolicyNotCaptured,
        Retry_Exhausted,
        Borrower,
        lastNameError,
        RegEx_Alphabets_Only,
        RegEx_Number,
        Mobile_Number_Error_Msg,
        KycAddress1Pattern,
        KycAddress2Pattern,
        AddressValidation1,
        AddressValidation2,
        AddressValidation3,
        enterLoanAmount,
        MFCApiFail
    }

    reportURL;
    overallRemarks;
    requestIdMFC;
    @api isRevokedLoanApplication;
    @api indexVal;
    @api checkleadaccess;//coming from tabloanApplication
    @api activeTab = Borrower;
    @api applicantId;
    @api recordid;
    @api uploadViewDocFlag = false;
    @api vehicleId;
    @track currentIndex;
    @track tryCatchError = '';
    @track benCode;
    @track isEnableNext = false;
    @track vehicleRecordId;
    @track ownerContactNumber;
    @track productType;
    @track ownerName;
    @track vehiclePlaceOfValuation;
    @track executiveName;
    @track executiveContactNumber;
    @track locationOfVehicle;
    @track valuationPrice;
    @track isValuationPriceDisabled = false;
    @track isGetGridValueButtonDisabled = false;
    @track slaNumberDisabled = false;
    @track isDisableInsuranceDeclaredValue = false;
    @track retryPopup;
    @track locationOfVehicleOptions = [];
    @track submitButtonDisabled = false;
    @track vehiclePlaceOfValuationDisabled = false;
    @track ownerNameDisabled = false;
    @track ownerContactNumberDisabled = false;
    @track disableGetValuation = false;
    @track disableValuerCode = false;
    @track disableValuer = true;
    @track isValuationDisabled = false;
    @track isEnableUploadViewDoc = true;
    @track valuationPrice;
    @track sellingPrice;
    @track slaNumber;
    @track insDeclaredValue;
    @track colorOfVehicle;
    @track kmsRun;
    @track valuerCode;
    @track purposeOfIBBFetch;
    @track gridValue;
    @track valuerCategory;
    @track valuerName;
    @track checkRc;
    @track checkVehicle;
    @track oemDealerFlag = false;
    @track checkOEMButton =false; //CISP-3558
    @track checkOEMButton1 = false; //CISP-3558
    @track isValuerCategory = false;
    @track disableValuationReport = true;
    @track isSpinnerMoving = false;
    @track showVehicleValuation = true;
    @track navToVehicleValuation = false;
    @track fetchValuationTick = false;

    @track allStateData;
    @track selectedStateIDValue;
    @track selectedStateCode;
    @track selectedStateName;
    @track selectedStateNameCode;

    @track allCityData;
    @track selectedCityIDValue;
    @track selectedCityName;
    @track selectedCityNameCode;

    @track vehicleRegNo;
    @track vehicleType; // SFTRAC-665
    @track leadNo;
    @track captureRCDisabled = false;
    @track captureVehicleImageDisabled = false;
    @track checkVehicleImageButton = false;
    @track checkRCButton = false;
    @track isVehicleImageClicked = false;
    @track isRCClicked = false;

    @track getValuationDone = false;
    @track lastStage;
    @track currentStageName;
    @track dealerName;
    @track manufactureYear;
    @track variantName;
    @track showFileUploadAndView = false;
    @track vehicleAge;
    @track ageOfVehicle;
    @track fromHome = false;
    @track fromGetValuation = false;
    @track fromValuationReport = false;
    @track isOEMDealerChecked = false;
    @track isTractorProduct = false;
    @track isAssetCaseVerified = false; //SFTRAC-665
    isD2C = false;
    iconAPIFailed = false;
    iconButton = false;
    disabledExecutiveName = false;
    disabledExecutiveNumber = false;
    ownerNameValue = '';
    phoneNoValue = '';
    sellingPriceAmount = '';
    @track isDealerNotPresent = false; //CISP-3558
    @track isLocationandColorAndKMS = false;
    @api tfvehicleid;
    @track varientCode; //SFTRAC-659
    @track vehicleSubType; //SFTRAC-659
    
    @wire(getStateMasterData) wiredStateMaster({ error, data }) {
        if (data) {
            let finalArrayTopush = [];
            if (data.length > 0) {
                for (let index = 0; index < data.length; index++) {
                    let stateValue = {};
                    stateValue.label = data[index].Name;
                    stateValue.value = data[index].Id;
                    stateValue.stateCode = data[index].State_Code__c;
                    stateValue.stateNameCode = data[index].State_Name_Code__c;
                    finalArrayTopush.push(stateValue);
                }
            }
            this.allStateData = finalArrayTopush;
        } if (error) {
            console.log('error in getStateMasterData=> ',error);
        }
    }

    get isDisableGetValuation(){
        return this.disableGetValuation || (this.isD2C && this.oemDealerFlag);
    }
    get getKMS_HMRLabel(){
        return this.productType == 'Tractor'?'HMR (in Hrs)':'KMS run';
    }
    get getGrid_RSVlabel(){
        return this.productType == 'Tractor'?'RSV':'Grid Value';
    }

    async stateChangeHandler(event) {
        if(event?.target?.value){
            this.selectedStateIDValue = event.target.value;
            this.selectedStateName = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.selectedStateNameCode = event.target.options.find(opt => opt.value === event.detail.value).stateNameCode;
            this.selectedStateCode = event.target.options.find(opt => opt.value === event.detail.value).stateCode;
        }

        console.log('State Id:: ', this.selectedStateIDValue);
        console.log('State Code:: ', this.selectedStateCode);
        console.log('State Name:: ', this.selectedStateName);
        console.log('State Name Code:: ', this.selectedStateNameCode);

        await getCityStateMaster({ stateCode: this.selectedStateCode }).then(response => {
            let cityData = [];

            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Id;
                    cityObject.cityNameCode = response[index].City_Name_Code__c;
                    cityData.push(cityObject);
                }
            }
            this.allCityData = cityData;

            //Reset City Field Values
            this.selectedCityIDValue = null;
            this.selectedCityName = null;
            this.selectedCityNameCode = null;
        }).catch(error => {
            console.log('error in getCityStateMaster =>', error);
        });
    }

    cityChangeHandler(event) {
        this.selectedCityIDValue = event.target.value;
        this.selectedCityName = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.selectedCityNameCode = event.target.options.find(opt => opt.value === event.detail.value).cityNameCode;
    }

    get cityValueOptions() {
        return this.allCityData;
    }

    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    
    async connectedCallback() {
        this.disableValuerCode = true;
        //this.disableValuationReport = true;

        await this.init();
        
        this.callAccessLoanApplication();

        console.log('selectedStateIDValue :: ',this.selectedStateIDValue);
        console.log('selectedStateName    :: ',this.selectedStateName);
        console.log('selectedStateCode    :: ',this.selectedStateCode);
        console.log('selectedStateNameCode:: ',this.selectedStateNameCode);
        console.log('selectedCityIDValue  :: ',this.selectedCityIDValue);
        console.log('selectedCityName     :: ',this.selectedCityName);
        console.log('selectedCityNameCode :: ',this.selectedCityNameCode);
        //CISP-2737
        getParentLeadNumber({ leadId: this.recordid })
          .then(result => {
            console.log('Result', result);
            if(result){
                
                this.parentLeadNo = result?.Parent_Loan_Application__r?.Lead_number__c;
                this.parentLeadNo = this.parentLeadNo?.toString().substring(0,12);//CISP-2904
                this.isRevokedApp = result?.Parent_Loan_Application__r?.Is_Revoked__c;
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
        //CISP-2737
    }

    async init() {
        try {
            console.log('record id and active tab ', this.recordid, this.activeTab);
            const currentApplicantId = await getApplicantId({
                opportunityId: this.recordid,
                applicantType: this.activeTab,
            })
            this.applicantId = currentApplicantId;
            console.log(' fetched current applicant id =>', this.applicantId, this.tfvehicleid);

            const vehicleDetails = await getVehicleValuationDetails({ loanApplicationId: this.recordid, tfvehicleid: this.tfvehicleid })
            const result = JSON.parse(vehicleDetails);
            console.log('result of vehicle valu connectedcallback =>', result);
            this.isTractorProduct = result.productType == 'Tractor' ? true : false;
            this.vehicleRecordId = result.vehicleRecordId;
            this.benCode = result.benCode;
            this.ownerContactNumber = result.ownerContactNumber;
            this.ownerName = result.ownerName;
            this.vehiclePlaceOfValuation = result.vehiclePlaceOfValuation;
            this.executiveName = result.executiveName;
            this.executiveContactNumber = result.executiveContactNumber;
            this.insDeclaredValue = result.insuranceDeclaredValue;
            this.vehicleRegNo = result.vehicleRegNo;
            this.vehicleType = result.vehicleType; // SFTRAC-665
            this.leadNo = result.leadNumber;
            this.valuerCategory = result.valCat;
            this.valuerName = result.valuer;
            this.valuerCode = result.valCode;
            this.slaNumber = result.slaNum;
            this.colorOfVehicle = result.colOfVeh;
            this.kmsRun = result.kmsRun;
            this.sellingPrice = result.sellPrice;
            this.valuationPrice = result.valPrice;
            if(this.isTractorProduct && result?.mfcUrl){
                this.reportURL = result.mfcUrl;
                this.fetchValuationTick = true;
                this.disableValuationReport = true;
            }
            this.purposeOfIBBFetch = result.purposeIbb;
            this.gridValue = result.gridVal;
            this.checkVehicle = result.vehicleImage;
            this.checkRc = result.rcCopy;
            this.oemDealerFlag = result.oemCheck;
            this.productType = result.productType;
            this.lastStage = result.lastStage;
            this.currentStageName = result.currentStageName;
            this.dealerName = result.dealerName;
            this.manufactureYear = result?.manufactureYear;
            this.variantName = result?.variantName;
            this.requestIdMFC = result?.requestId;
            this.isOEMDealerChecked = result.productType == 'Tractor' ? true :result?.isOEMDealerChecked;
            this.varientCode = result?.varientCode; //SFTRAC-659
            this.vehicleSubType = result?.vehicleSubType; //SFTRAC-659
                        //D2C Change
            this.isD2C = result.isD2C;
            if(this.isD2C && this.oemDealerFlag && this.isOEMDealerChecked) { 
                this.isValuerCategory = true;
                this.disableValuer = true;
                this.disableValuerCode = true;
                this.disableGetValuation = true;
                //this.slaNumberDisabled = true;
                //this.isLocationandColorAndKMS = true;
                
            }
            if(this.isD2C && this.valuationPrice != null && result.mfcUrl != null && result.aggregatorSource != null){//D2C Change
                this.isAggregatorComplete = true;
                this.category.push({"value":result.aggregatorSource, "label":result.aggregatorSource});
                this.getgridvalueicon =true;
                this.disableEverythingExceptSubmit();
            }
            //EO D2C Change

            this.checkOEMButton = result.oemCheck == true ? true:false; //CISP-3558
            this.checkOEMButton1 = result.oemCheck == false ? true:false; 
            console.log('this.dealerName : ',this.dealerName);
           //CISP-106
            if(this.dealerName == null){
                this.isDealerNotPresent = true;//CISP-3558
                this.isOEMDealerChecked = true;
            }//CISP-106
            if(this.requestIdMFC){
                console.log('disableValuationReport : ',this.disableValuationReport);
                this.disableValuationReport = false;
                this.disableGetValuation = true;
                this.iconButton = true;
                this.isLocationandColorAndKMS = true;//CISP-67
                this.textDisable = true;
                this.isValuerCategory = true;
                this.disableValuer = true;
                this.disableValuerCode = true;
                this.slaNumberDisabled = true; //CISP-67
                console.log('disableValuationReport : ',this.disableValuationReport);
            }
            if (this.valuerCategory === 'MFC' || this.oemDealerFlag) {
                this.isValuationPriceDisabled = true;
            }
            if (this.valuerCategory === 'MFC' && this.oemDealerFlag) {
                this.disableValuationReport = true;
                this.disableGetValuation = true;
                this.slaNumberDisabled = true
                this.disableValuerCode = true;
                this.disableValuer = true;
            }
            if (this.valuerCategory === 'MFC') {
                this.slaNumberDisabled = true;
            }
            if (this.valuerCategory === 'MFC' && this.oemDealerFlag == false && this.isOEMDealerChecked == true ) {
                if(this.requestIdMFC){
                    this.disableGetValuation = true;
                    this.disableValuationReport = false;
                }
                else{
                    this.disableGetValuation = false;
                    this.disableValuationReport = true;
                }
                this.slaNumberDisabled = true
                this.disableValuerCode = true;
                this.disableValuer = true;
            }

            if (result.state) {
                this.selectedStateIDValue = result.cityStateDetails?.stateDetails?.Id;
                this.selectedStateName = result.cityStateDetails?.stateDetails?.Name;
                this.selectedStateCode = result.cityStateDetails?.stateDetails?.State_Code__c;
                this.selectedStateNameCode = result.cityStateDetails?.stateDetails?.State_Name_Code__c;
                                
                await this.stateChangeHandler(null);
            }

            if (result.city) {
                this.selectedCityIDValue =  result.cityStateDetails?.CityDetails?.Id;
                this.selectedCityName = result.cityStateDetails?.CityDetails?.Name;
                this.selectedCityNameCode = result.cityStateDetails?.CityDetails?.City_Name_Code__c;
            }

            if (this.checkVehicle) {
                this.captureVehicleImageDisabled = true;
                this.checkVehicleImageButton = true;
            }

            if (this.checkRc) {
                this.captureRCDisabled = true;
                this.checkRCButton = true;
            }

            if (result.locationOfVehicle) {
                let locOfVeh = [];
                locOfVeh.push({ label: result.locationOfVehicle, value: result.locationOfVehicle });
                this.locationOfVehicleOptions = locOfVeh;
                this.locationOfVehicle = result.locationOfVehicle;
            }
            
            this.initValuerCategory();//CISP-2871
            this.getGridValueForTractor();

        } catch (error) {
            console.log("error in init method ", error);
        }

        if (this.ownerName !== null) {
            this.ownerNameDisabled = true;
        }
        if (this.ownerContactNumber !== null) {
            this.ownerContactNumberDisabled = true;
        }
        if (this.vehiclePlaceOfValuation !== null) {
            this.vehiclePlaceOfValuationDisabled = true;
        }
        if (this.executiveName !== null) {
            this.disabledExecutiveName = true;
        }
        if (this.executiveContactNumber !== null) {
            this.disabledExecutiveNumber = true;
        }
        console.log('isDisableInsuranceDeclaredValue oustide- ', this.isDisableInsuranceDeclaredValue );
        if(this.insDeclaredValue !== null){
            this.isDisableInsuranceDeclaredValue = true;
            console.log('isDisableInsuranceDeclaredValue inside- ', this.isDisableInsuranceDeclaredValue );
        }
    }

    // CISP-2871-START
    initValuerCategory() {
        try {
            if (this.valuerCategory === this.label.empanelled) {
                this.isValuationPriceDisabled = false;
                this.disableValuerCode = false;
                this.slaNumberDisabled = false;
                this.disableValuer = false;
                this.disableGetValuation = true;
            } else if (this.oemDealerFlag === false && this.valuerCategory === this.label.empanelled) {
                this.disableValuer = false; //Enable if "OEM Dealer" is unflagged and Valuer Category is Empanelled.
            } else if (this.valuerCategory === 'MFC' && this.oemDealerFlag) {
                this.disableValuationReport = true;
                this.disableGetValuation = true;
                this.slaNumberDisabled = true
                this.disableValuerCode = true;
                this.disableValuer = true;
            }else if (this.valuerCategory === this.label.mfc && this.oemDealerFlag == false && this.isOEMDealerChecked) {
                //this.valuationPrice = ''; //CISP-2961
                this.isValuationPriceDisabled = true;
                this.slaNumber = '';
                this.slaNumberDisabled = true
                if(this.requestIdMFC){
                    this.disableGetValuation = true;
                    this.disableValuationReport = false;
                }
                else{
                    this.disableGetValuation = false;
                    this.disableValuationReport = true;
                }
                this.disableValuerCode = true;
                this.disableValuer = true;
                this.valuerName = null;
                this.valuerCode = null;
            } else {
                this.disableValuerCode = true;
                this.disableValuer = true;
                this.disableGetValuation = false;
                this.slaNumberDisabled = true;//CISP-105
                this.valuerName = '';
                this.valuerCode = '';
            }
            //CISP-3669 start
            if(this.oemDealerFlag){
                this.disableGetValuation = true;
                this.isValuerCategory = true;
                this.disableValuer = true;
                this.disableValuerCode = true;this.slaNumberDisabled = true;
            }//CISP-3669 end
        } catch (error) {
            console.log('error in initValuerCategory ', error);
        }
    }
    // CISP-2871-END

    @wire(getObjectInfo, { objectApiName: VEHICLE_DETAIL_OBJECT })
    objectInfo;

    @track category;//D2C Change
    
    @wire(getPicklistValues,
        {
            recordTypeId: '$objectInfo.data.defaultRecordTypeId',
            fieldApiName: VALUER_CATEGORY_FIELD
        }
    )//D2C Change
    getcategoryOptions({error,data}){
        if(data){
            let temCat = JSON.parse(JSON.stringify(data.values));
            this.category = temCat;
        }else if(error){ }
    }// EO D2C Change
    

    @track valuerOptions = [];
    @wire(getPicklistValuesForValuer)
    getPicklistValuesForValuer({ error, data }) {
        if (data) {
            this.l_All_Types = data;
            let options = [];
            for (var key in data) {
                options.push({ label: data[key].Ben_code__r.Name, value: data[key].Ben_code__r.Name, benCode: data[key].Ben_code__r.Ben_code__c });
            }
            this.valuerOptions = options;
        } else if (error) { }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$objectInfo.data.defaultRecordTypeId',
            fieldApiName: LOCATION_OF_VEHICLE_FIELD
        }
    )
    locationOfVehicleOptions({ error, data }) {
        if (data) {
            let locOfVeh = [];
            for (let index = 0; index < data.values.length; index++) {
                let temp = {};
                temp.label = data.values[index].label;
                temp.value = data.values[index].value;
                locOfVeh.push(temp);
            }
            this.locationOfVehicleOptions = locOfVeh;
        } if (error) {
            console.log('error in location of vehi picklist value', error);
        }
    }

    get locationOfVehicleOptionsList() {
        return this.locationOfVehicleOptions;
    }

    handleOnfinish(event) {
        const evnts = new CustomEvent('loanvaleve', { detail: event, bubbles:true, composed:true });
        this.dispatchEvent(evnts);
    }

    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
        if (this.currentStage === 'Credit Processing'|| this.currentStageName === 'Loan Initiation' || this.currentStageName === 'Additional Details' || this.currentStageName === 'Asset Details' || this.currentStageName === 'Vehicle Insurance' || (this.currentStageName != undefined && this.currentStageName !== 'Vehicle Valuation' && this.lastStage !== 'Vehicle Valuation' && this.lastStage != undefined)) {
            this.disableEverything();
            if (this.currentStage === 'Credit Processing') {
            this.isEnableNext = true;
            if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }
            }
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }

    handleUploadViewDoc() {
        this.showUpload = true;
        this.showDocView = true;
        this.isVehicleDoc = false;
        this.isAllDocType = true;
        this.uploadViewDocFlag = true;
    }

    handleValuerCategory(event) {
        this.valuerCategory = event.target.value;
        let valuerCodeField = this.template.querySelector("[data-id='valuerCodeField']");
        let valuerField = this.template.querySelector("[data-id='valuerField']");
        valuerField.required = true;
        valuerCodeField.required = true;
        if (this.valuerCategory === this.label.empanelled) {
            this.isValuationPriceDisabled = false;
            this.disableValuerCode = false;
            this.slaNumberDisabled = false;
            this.disableValuer = false;
            this.disableGetValuation = true;
        } else if (this.oemDealerFlag === false && this.valuerCategory === this.label.empanelled) {
            this.disableValuer = false; //Enable if "OEM Dealer" is unflagged and Valuer Category is Empanelled.
        } else if (this.valuerCategory === 'MFC' && this.oemDealerFlag) {
            this.disableValuationReport = true;
            this.disableGetValuation = true;
            this.slaNumberDisabled = true
            this.disableValuerCode = true;
            this.disableValuer = true;
        }else if (this.valuerCategory === this.label.mfc && this.oemDealerFlag == false && this.isOEMDealerChecked) {
            this.valuationPrice = '';
            this.isValuationPriceDisabled = true;
            this.slaNumber = '';
            this.slaNumberDisabled = true
            if(this.requestIdMFC){
                this.disableGetValuation = true;
                this.disableValuationReport = false;
            }
            else{
                this.disableGetValuation = false;
                this.disableValuationReport = true;
            }
            this.disableValuerCode = true;
            this.disableValuer = true;
            this.valuerName = null;
            this.valuerCode = null;
            valuerField.required = false;
            valuerField.setCustomValidity('');
            valuerField.reportValidity();
            valuerCodeField.required = false;
            valuerCodeField.setCustomValidity('');
            valuerCodeField.reportValidity();
        } else {
            this.disableValuerCode = true;
            this.disableValuer = true;
            this.disableGetValuation = false;
            this.slaNumberDisabled = true;//CISP-105
            this.valuerName = '';
            this.valuerCode = '';
        }
    }

    handleValuer(event) {
        this.valuerName = event.target.value;
        this.valuerOptions.forEach((element => {
            if (element.value === this.valuerName) {
                this.valuerCode = element.benCode;
            }
        }))
        this.disableValuerCode = true;
    }

    validateLoanAmountField(event) {
        if (event.keyCode === 69 || event.keyCode === 77 || event.keyCode == 75 || event.keyCode == 66 || event.keyCode == 84) {
            event.preventDefault();
        }
    }

    handleInputFieldChange(event) {
        const field = event.target.name;
        if (field === 'ownerNamefield') {
            this.ownerName = event.target.value;
            let ownerNameInput = this.template.querySelector('lightning-input[data-id=ownerNameId]');
            let ownerNameValue = ownerNameInput.value;
            this.ownerNameValue = ownerNameValue;
            if (ownerNameValue.length > 26) {
                ownerNameInput.setCustomValidity(this.label.lastNameError);
            } else {
                ownerNameInput.setCustomValidity("");
            }
            ownerNameInput.reportValidity();
        } else if (field === 'ownerContactNumberfield') {
            this.ownerContactNumber = event.target.value;
            let phoneNoInput = this.template.querySelector('lightning-input[data-id=phoneNumberId]');
            let phoneNoValue = phoneNoInput.value;
            this.phoneNoValue = phoneNoValue;
            phoneNoInput.reportValidity();
        } else if (field === 'vehiclValuationfield') {
            this.vehiclePlaceOfValuation = event.target.value;
            let address1 = this.template.querySelector('lightning-input[data-id=kycAddressOneDataId]');
            let addressL1 = address1.value;
            if (addressL1.length < 3) {
                address1.setCustomValidity(AddressValidation1);
            } else if (addressL1.length > 40) {
                address1.setCustomValidity(AddressValidation2);
            } else {
                address1.setCustomValidity("");
            }
            address1.reportValidity();
        } else if (field === 'locationOfVehiclefield') {
            this.locationOfVehicle = event.target.value;
        } else if (field === 'executiveNameField') {
            this.executiveName = event.target.value;
        } else if (field === 'executiveContactNumberField') {
            this.executiveContactNumber = event.target.value;
        } else if (field === 'valuerCategoryField') {
            this.valuerCategory = event.target.value;
        } else if (field === 'executiveNameField') {
            this.executiveName = event.target.value;
        } else if (field === 'valuerField') {
            this.valuerName = event.target.value;
        } else if (field === 'executiveNameField') {
            this.executiveName = event.target.value;
        } else if (field === 'valuerCodeField') {
            this.valuerCode = event.target.value;
        } else if (field === 'slaNumberField') {
            this.slaNumber = event.target.value;
            let slaNumberField = this.template.querySelector("[data-id='slaNumber']");
            let pattern = "^\d+(\.\d[0])?$";
            if (this.slaNumber.match(pattern)) {
                slaNumberField.setCustomValidity("Decimal number is not allowed");
            } else {
                slaNumberField.setCustomValidity("");
            }
            slaNumberField.reportValidity();
        } else if (field === 'sellingPriceField') {
            this.sellingPrice = event.target.value;
            let sellingPriceAmount = event.target.value;
            this.sellingPriceAmount = sellingPriceAmount;
            let elem = this.template.querySelector(".sellPrice");
            elem.setCustomValidity("");
            console.log('product type1 ', this.productType);
            if (this.productType == 'Two Wheeler') {
                if (sellingPriceAmount && (sellingPriceAmount < parseInt(Loanamount10000) || sellingPriceAmount > parseInt(Loanamount175000))) {
                    elem.setCustomValidity(SellingPricemessage);
                }
            } else {
            if (sellingPriceAmount && (sellingPriceAmount < parseInt(LoanAmount50000) || sellingPriceAmount > parseInt(LoanAmount200000000))) {
                elem.setCustomValidity(SellingPricemessage);
            }
        }
            console.log('product type2 ', this.productType);
            elem.reportValidity();
        } else if (field === 'insDeclaredValueField') {
            this.insDeclaredValue = event.target.value;
        } else if (field === 'valuationPrice') {
            this.valuationPrice = event.target.value;
        } else if (field === 'colorOfVehicleField') {
            this.colorOfVehicle = event.target.value;
        } else if (field === 'kmsRunField') {
            this.kmsRun = event.target.value;
        } else if (field === 'purposeOfIBBFetchField') {
            this.purposeOfIBBFetch = event.target.value;
        } else if (field === 'gridValueField') {
            this.gridValue = event.target.value;
        }
    }

    selectedStateHandler(event) {
        // this.stateId = event.detail.selectedValueId;
        // this.state = event.detail.selectedValueName;
        // this.records = event.detail.records;

        // if (this.state === "" && this.city !== "") {
        //     let selectedCity = this.template.querySelectorAll('c-I-N-D_-L-W-C_-Custom_-Lookup');
        //     selectedCity[1].makeCityBlank();
        // }
    }

    selectedCityHandler(event) {
        this.cityId = event.detail.selectedValueId;
        this.city = event.detail.selectedValueName;
        this.records = event.detail.records;
    }

    async getGridValueForTractor(){
        try{
            if(this.productType == 'Tractor'){
                let currentTime = new Date();
                let monthAndYear = this.manufactureYear.split('-');
                let year = currentTime.getFullYear();
                let month = currentTime.getMonth();
                let age = Math.abs(year - monthAndYear[0]);
                if(age > 0){
                    this.vehicleAge = (age * 12) - monthAndYear[1] + month;
                }
                else{
                    this.vehicleAge = Math.abs(monthAndYear[1] - month);
                }
                let vehicleAgeInYears = Math.floor(this.vehicleAge/12)
                let vehicleAgeInMonths = this.vehicleAge % 12;
                if(vehicleAgeInMonths >= 6){
                    vehicleAgeInYears = vehicleAgeInYears + 1;
                    this.ageOfVehicle=vehicleAgeInYears;
                }else{
                    this.ageOfVehicle = vehicleAgeInYears;
                }
                let fetchGridValue = await fetchGridValueForTractor({'loanApplicationId' : this.recordid, 'vehicleAge' : vehicleAgeInYears, 'variantCode' : this.varientCode});
                if(fetchGridValue){
                    this.gridValue = fetchGridValue;
                }else{
                    this.gridValue = '';
                }
            }
        }catch(error){
            console.log(error);
        }
    }
    // varientCode= 'MVBREZVDI';// Fetch variant_code field from product object which type='Variant'
    // YOM = '2017';//fetch year from Manufacturer Year, Month field present 
    //Handler for Get Grid Value Button click.
    getGridValueHandler() {
        // this.isGetGridValueButtonDisabled = true;
        if (this.kmsRun && this.colorOfVehicle && this.selectedStateName) {
            checkIBBAPIAttempts({ loanApplicationId: this.recordid })
                .then(result => {
                    if (result === 'success') {
                        let vehicleDetailString = {
                            'loanApplicationId': this.recordid,
                            'vehicleId': this.vehicleRecordId,
                            'color': this.colorOfVehicle,
                            'kilometer': this.kmsRun,
                            'state': this.selectedStateName
                        };
                        doIbbMasterCallout({
                            'ibbRequestString': JSON.stringify(vehicleDetailString)
                        })
                        .then(result => {
                            this.getgridvalueicon = true;
                            console.log('ibb api response => ', result);
                            this.isSpinnerMoving = false;
                            const res = JSON.parse(result);
                            this.gridValue = parseFloat(res.ibb_price_avg).toFixed(2);
                            if (this.gridValue) {
                                const event = new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Grid value is fetched successfully.',
                                    variant: 'success',
                                });
                                this.dispatchEvent(event);
                            }
                        })
                        .catch(error => {
                            this.isSpinnerMoving = false;
                            console.log('Error in IBB API 1', error);
                            const event = new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'Error',
                            });
                            this.dispatchEvent(event);
                        });
                    } else if (result === this.label.Retry_Exhausted) {

                        this.isGetGridValueButtonDisabled = true;
                        this.isSpinnerMoving = false;
                        this.getgridvaluecrossicon = true;

                        console.log('Check Manufacture Value : ',this.manufactureYear);
                        //Calculate Vehicle Age
                        let currentTime = new Date();
                        let monthAndYear = this.manufactureYear.split('-');
                        let year = currentTime.getFullYear();
                        let month = currentTime.getMonth();
                        let age = Math.abs(year - monthAndYear[0]);
                        let ageofVehicles = Math.abs((age * 12 - (monthAndYear[1])));
                        this.vehicleAge = Math.abs(ageofVehicles + month); // Value get in Months
                        console.log('Vehicle Age in Months: ',this.vehicleAge);

                        //Split Age in Years and Months
                        let vehicleAgeInYears = Math.floor(this.vehicleAge/12)
                        let vehicleAgeInMonths = this.vehicleAge % 12;
                        console.log('Vehicle Age :: ',vehicleAgeInYears +' and '+vehicleAgeInMonths);
                        if(vehicleAgeInMonths >= 6){
                            vehicleAgeInYears = vehicleAgeInYears + 1;
                            this.ageOfVehicle=vehicleAgeInYears;
                        }else{
                            this.ageOfVehicle = vehicleAgeInYears;
                        }

                        console.log('Fetch Grid Value Inputs :: ',this.ageOfVehicle +' and '+this.variantName);
                        fetchGridValue({ vehicleAge: this.ageOfVehicle, variantName: this.variantName })
                        .then(result => {
                            console.log('Result:: ', result);
                            if(result !==0 && result !==-1){
                                console.log('Inside Result:: ', result);
                                this.gridValue = result;
                                const event = new ShowToastEvent({
                                    title: '',
                                    message: 'Grid Value Attempts are exhausted, fetching from Master data ',
                                    variant: 'warning',
                                    mode: 'sticky'
                                });
                                this.dispatchEvent(event);
                            }else if(result===-1){
                                console.log('Inside -1 :: ', result);
                                const event = new ShowToastEvent({
                                    title: '',
                                    message: 'Manufacturer year or Variant Code is missing on Vehicle Details',
                                    variant: 'error',
                                    mode: 'sticky'
                                });
                                this.dispatchEvent(event);
                            }else if(result===0){
                                console.log('Inside 0 :: ', result);
                                this.gridValue = result;
                                const event = new ShowToastEvent({
                                    title: '',
                                    message: 'Grid Value Not present in Masters',
                                    variant: 'error',
                                    mode: 'sticky'
                                });
                                this.dispatchEvent(event);
                            }
                        }).catch(error => {
                            console.log('Error in Fetching Grid Value from Master', error);
                            this.isSpinnerMoving = false;
                        });
                    }
                })
                .catch(error => {
                    console.log('Error in IBB API catch', error);
                    this.isSpinnerMoving = false;
                });
        } else {
            this.isSpinnerMoving = false;
            const evt = new ShowToastEvent({
                title: "Warning",
                message: 'Color of vehicle, KMS and state are required.',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }

    }

    //Popup : on click of 'Kindly Retry'
    handleRetry() {
        this.retryPopup = false;
        this.isGetGridValueButtonDisabled = false;
    }

    changeflagvalue() {
        this.uploadViewDocFlag = false;
        if(FORM_FACTOR!='Large'){
            checkImageExist({ applicantId: this.applicantId , documentType: this.docType }).then(response => {
                if(response===false){
                    this.showToast('','Document Upload Fail','warning');
                }else if(response===true){
                    if(this.docType === this.label.VehicleImage){
                        this.captureVehicleImageDisabled = true;
                        this.checkVehicleImageButton = true;
                    } else if(this.docType === this.label.RC_Copy){
                        this.captureRCDisabled = true;
                        this.checkRCButton = true;
                    }
                    this.showToast('Success',this.docType + ' Document captured successfully', 'success');
                }
            }).catch(error => {
                console.log('checkImagePresent error:',error);
            });
        }
    }

    async handleCheckOEM() {
        //this.isOEMDealerChecked = true;
        //update oem dealer flag in backend
        const assetDetailsFields = {};
        assetDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleRecordId;
        assetDetailsFields[is_OEM_Dealer_Checked.fieldApiName] = true;
        await this.updateRecordDetails(assetDetailsFields)
            .then(() => {  
                console.log('OUTPUT :handleCheckOEM ',);
            }).catch(error => {  
                console.log('OUTPUT handleCheckOEM: ',error);
            })

        await setOEMFlag({ loanApplicationId: this.recordid , dealerName: this.dealerName,vehicleId: this.vehicleRecordId })
            .then(result => {
                if (result) {
                    this.oemDealerFlag = result;
                    //this.checkOEMButton = result;
                    console.log('OUTPUT this.oemDealerFlag: ',this.oemDealerFlag);
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: 'Selected Dealer '+this.dealerName+' is found as OEM',
                        variant: 'Success',
                    });
                    this.dispatchEvent(evt);
                    if((this.valuerCategory === this.label.mfc || this.valuerCategory === this.label.empanelled) && this.oemDealerFlag ){
                        console.log('OUTPUT this.oemDealerFlag: first if ',this.disableGetValuation);
                        this.disableGetValuation = true;
                        this.isValuationPriceDisabled = true;
                        if(this.isD2C) {
                            this.isValuerCategory = true;
                            this.disableValuer = true;
                            this.disableValuerCode = true;
                            this.disableGetValuation = true;
                            this.valuerCategory = '';
                            this.valuerName = '';
                            this.valuerCode = '';
                            //this.slaNumberDisabled = true;
                            //this.isLocationandColorAndKMS = true;
                            
                        }
                    }
                    //CISP-3669 start
                    if(this.oemDealerFlag){
                        this.disableGetValuation = true;
                        this.isValuerCategory = true;
                        this.disableValuer = true;
                        this.disableValuerCode = true;this.slaNumberDisabled = true;
                    }//CISP-3669 end
                } else {
                    this.oemDealerFlag = result;//CISP-3609
                    this.isValuerCategory = false;//CISP-3609
                    //this.checkOEMButton1 = true;
                    const evt = new ShowToastEvent({
                        title: "Warning",
                        message: 'Selected Dealer '+this.dealerName+' is not OEM',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    if (this.valuerCategory === this.label.mfc && this.oemDealerFlag == false && this.isOEMDealerChecked) {
                        if(this.requestIdMFC){
                            console.log('OUTPUT this.oemDealerFlag: first else if ',this.disableGetValuation);
                            this.disableGetValuation = true;
                            this.disableValuationReport = false;
                        }else{
                            console.log('OUTPUT this.oemDealerFlag: first else ',this.disableGetValuation);
                            this.disableGetValuation = false;
                            this.disableValuationReport = true;
                        }
                        this.slaNumberDisabled = true
                        this.disableValuerCode = true;
                        this.disableValuer = true;
                    }
                }
                
            })
            .catch(error => { });
            
            this.setflagValue();

        }

    
    setflagValue(){ //CISP-3558
        this.isOEMDealerChecked = true;
        if(this.oemDealerFlag == true){
            console.log('this.checkOEMButton ');
            this.checkOEMButton = true;
            this.checkOEMButton1 = false;
        }else{
            console.log('this.checkOEMButton1 ');
            this.checkOEMButton1 = true;
            this.checkOEMButton = false;
        }
        console.log('this.checkOEMButton : ',this.checkOEMButton);
        console.log('this.checkOEMButton1 : ',this.checkOEMButton1);
    }
    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body.message,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }

    populateValuationPrice() {
        if (this.oemDealerFlag) {
            this.valuationPrice = this.sellingPrice;

        } else if(!this.isTractorProduct){
            //D2C Change
            if(!this.isD2C){
                this.isValuationPriceDisabled = true;
            }
            
        }
    }

    //CISP-2455( Added async)
    async handleValuation() {
        if (this.valuerCategory === undefined && this.disableGetValuation === false) {
            const evt = new ShowToastEvent({
                message: this.label.selectValuerCategory,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return null;
        }else if(this.isOEMDealerChecked == false){// CISP-105
            const evt = new ShowToastEvent({
                message: 'Please first select Check OEM Dealer ',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return null;
        }// CISP-105 
        else {
            if (this.recordid && this.valuerCategory && this.vehiclePlaceOfValuation && this.locationOfVehicle && this.selectedStateIDValue && this.selectedCityIDValue && (this.colorOfVehicle || this.isTractorProduct) && this.kmsRun) {// CISP-105
                this.isSpinnerMoving = true;
                this.isValuerCategory = true;
                const reqWrapper = {
                    loanApplicationId: this.recordid,
                    valuerCategory: this.valuerCategory,
                    placeOfInspection: this.vehiclePlaceOfValuation,
                    locationOfVehicle: this.locationOfVehicle,
                    city: this.selectedCityNameCode,
                    state: this.selectedStateNameCode,
                    vehicleId: this.vehicleRecordId
                }
                console.log('Check doMFCValuationCallout Inputs ::',reqWrapper);
                //CISP-2455
                await getMFCUniqueResponse({ vehicleRegNo: this.vehicleRegNo })
                  .then(result => {
                    console.log('ResultgetMFCUniqueResponse', result);
                    if(result){
                        console.log('if result present : ',result.MFC_Response_Data__c);
                        let mfcRes = result.MFC_Response_Data__c;
                        let data = JSON.parse(mfcRes.replace(/&quot;/g,'"'));
                        this.isMFCPresent = true;
                        let requestId = data.response.content[0].Requestid;
                        console.log('requestId : ',requestId);
                        this.requestIdMFC = requestId;
                        this.fromGetValuation = true;
                        this.isSpinnerMoving = false;
                        this.iconButton = true;
                        this.disableValuationReport = false;
                        this.disableGetValuation = true;
                        this.saveVehicleDetails();
                        this.ownerContactNumberDisabled = true;
                        this.vehiclePlaceOfValuationDisabled = true;
                        this.textDisable = true;
                        this.isLocationandColorAndKMS = true;
                        this.disabledExecutiveNumber = true;
                        this.disabledExecutiveName = true
                        this.isValuerCategory = true;
                        this.disableValuer = true;
                        this.disableValuerCode = true;
                        this.slaNumberDisabled = true;
                        
                    }
                  })
                  .catch(error => {
                    console.error('Error:', error);
                });
                
                if(!this.isMFCPresent){//CISP-2455
                await doMFCValuationCallout({ mfcValuationString: JSON.stringify(reqWrapper) })
                    .then(response => {
                        console.log(' doMFCValuationCallout Output ::',response);
                        let requestId = JSON.parse(response).response.content[0].Requestid;
                        console.log('requestId : ',requestId);
                        this.requestIdMFC = requestId;
                        this.isSpinnerMoving = false;
                        this.disableValuationReport = false;
                        this.disableGetValuation = true;
                        this.getValuationDone = true;
                        this.iconButton = true;
                        this.iconAPIFailed = false;
                        this.fromGetValuation = true;
                        this.saveVehicleDetails();
                        this.saveMFCResponseData(response);//CISP-2455
                        this.ownerNameDisabled = true;
                        this.ownerContactNumberDisabled = true;
                        this.vehiclePlaceOfValuationDisabled = true;
                        this.textDisable = true;
                        this.isLocationandColorAndKMS = true;
                        this.disabledExecutiveNumber = true;
                        this.disabledExecutiveName = true
                        this.isValuerCategory = true;
                        this.disableValuer = true;
                        this.disableValuerCode = true;
                        this.slaNumberDisabled = true; //CISP-67
                    })
                    .catch((error) => {
                        console.log('Check doMFCValuationCallout error ::', error);
                        let msg = error.body.message;
                        let message;//CISP-2926
                        let responseData;//CISP-2926
                            if (msg?.includes('{')) {
                            message = JSON.parse(msg).response.respDesc;//CISP-2926
                        }
                            if (message?.includes('Request already submitted')) {
                            responseData = JSON.parse(msg).response.content[0].Requestid;//CISP-2926
                            this.requestIdMFC = responseData;//CISP-2926
                            this.fromGetValuation = true;//CISP-3153
                            this.saveVehicleDetails();//CISP-2926
                            this.disableGetValuation = true;
                            this.iconAPIFailed = true;
                            this.ownerNameDisabled = true;
                            this.ownerContactNumberDisabled = true;
                            this.vehiclePlaceOfValuationDisabled = true;
                            this.textDisable = true;
                            this.isLocationandColorAndKMS = true;
                            this.disabledExecutiveNumber = true;
                            this.disabledExecutiveName = true
                            this.isValuerCategory = true;
                            this.disableValuer = true;
                            this.disableValuerCode = true;
                            this.slaNumberDisabled = true;//CISP-67
                            this.disableValuationReport = false;
                        }else{
                        this.disableGetValuation = true;
                        this.iconAPIFailed = true;
                        }
                        this.isSpinnerMoving = false;
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: this.label.MFCApiFail,
                            variant: 'Error',
                        });
                        this.dispatchEvent(event);
                    });
                }
            } else {
                this.isSpinnerMoving = false;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Fill All required fields',
                    variant: 'Error',
                });
                this.dispatchEvent(event);
            }
        }
        return true;
    }
    //CISP-2455
    saveMFCResponseData(response){
        console.log('saveMFCResponseData : ',response);
        saveMFCResponseRecord({ vehiRegNo: this.vehicleRegNo , res : response})
          .then(result => {
            console.log('saveMFCResponseRecord', result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    //CISP-2455
    handleValuationReport() {
        if(this.isTractorProduct && this.reportURL && this.valuationPrice && this.valuationPrice > 0){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.reportURL
                }
            });
            return;
        }
        console.log('handleValuationReport : ',);
        let leadRecordNo;//CISP-2737
        if(this.isRevokedApp == true && this.parentLeadNo != null){
            leadRecordNo = this.parentLeadNo;
        }else{
            leadRecordNo = this.leadNo;
        }//CISP-2737
        const requestWrapper = {
            'loanApplicationId': this.recordid,
            'leadId': leadRecordNo,
            'vehicleRegisterationNumber': this.vehicleRegNo,
            'vehicleId': this.vehicleRecordId
        }
        console.log('requestWrapper : ',requestWrapper);
        doMFCFetchValuationReportCallout({ mfcValuationReportRequestString: JSON.stringify(requestWrapper) })
            .then(result => {
                const res = JSON.parse(result);
                if (res.response.status === 'SUCCESS') {
                    if(this.isD2C || this.isTractorProduct){ //D2C Change
                        if (res.response?.content[0]?.ReportGenerated === 'No') {
                            const event = new ShowToastEvent({
                                title: 'Warning',
                                message: this.label.reportGeneratedMessage,
                                variant: 'warning',
                            });
                            this.dispatchEvent(event);
                            return;
                        }
                        
                    }
                    this.valuationPrice = parseFloat(res.response.content[0].Valuation_Price).toFixed(2);
                    if(this.isTractorProduct && this.valuerCategory === 'MFC' && (this.valuationPrice == 0 || !this.valuationPrice)){
                        this.fetchValuationTick = false;
                        this.valuationPrice = '';
                        this.disableValuationReport = false;
                        const event = new ShowToastEvent({
                            title: 'Info',
                            message: 'Valuation is not completed by MFC. Please click Fetch Valuation report button to get valuation price or click submit to proceed',
                            variant: 'Info',
                            mode:'sticky',
                        });
                        this.dispatchEvent(event);
                        return;
                    }else{
                        this.disableGetValuation = true;
                        this.disableValuationReport = true;
                        this.fetchValuationTick = true;
                    }
                    //CISP-3609 start
                    if(this.valuationPrice == 0 && this.valuerCategory === 'MFC'){
                        this.valuationPrice = '';
                        this.disableValuationReport = false;
                        const event = new ShowToastEvent({
                            title: 'Info',
                            message: 'Valuation is not completed by MFC. Please click Fetch Valuation report button to get valuation price or click submit to proceed',
                            variant: 'Info',
                            mode:'sticky',
                        });
                        this.dispatchEvent(event);
                    }else{
                        this.disableValuationReport = true;
                    }//CISP-3609 end
                    this.reportURL = res.response.content[0].ReportURL;
                    this.overallRemarks = res.response.content[0].Overall_Remarks;
                    this.mfcGenerationDate = new Date();
                    this.fromValuationReport = true;
                    this.saveVehicleDetails();
                    this.isValuerCategory = true;
                    if(this.valuationPrice > 0){
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: this.label.mcfSuccessResponse,
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                    }
                } else {
                    this.fetchValuationTick = false;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'API Response Fail',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch(error => { 
                this.fetchValuationTick = false;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'API Failed. Kindly retry.',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            });
    }
    handleGridValue() {
        if (this.disableGetValuation) {
            this.isSpinnerMoving = true;
            this.getGridValueHandler();
        } else {
            const event = new ShowToastEvent({
                title: this.label.getValuationDoneFirst,
                variant: 'warning',
            });
            this.dispatchEvent(event);
        }
    }

    handleVehicleImage() {
        if(FORM_FACTOR==='Large'){
            createDocument({ docType:this.label.VehicleImage, vehicleDetailId: this.vehicleRecordId, applicantId: this.applicantId, loanApplicationId: this.recordid })
            .then(result => {
                this.documentRecordId = result;
                this.docType = this.label.VehicleImage;
                this.showUpload = true;
                this.showDocView = false;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = true;
                this.checkVehicleImageButton = false;
                this.isVehicleImageClicked = true;
                this.saveDocumentRecord();
            })
            .catch(error => {
                console.log('error in vehicle image uploading', error);
                //this.tryCatchError = error;
                //this.errorInCatch();
            });
        } else {
            fetchDocument({ applicantId: this.applicantId, docType: this.label.VehicleImage,vehicleDetailId: this.vehicleRecordId }).then(result => {
                if(result===null){
                    this.documentRecordId = result;
                    this.docType = this.label.VehicleImage;
                    this.showUpload = true;
                    this.showDocView = false;
                    this.isVehicleDoc = true;
                    this.isAllDocType = false;
                    this.uploadViewDocFlag = true;
                    this.checkVehicleImageButton = false;
                    this.isVehicleImageClicked = true;
                    //this.saveDocumentRecord();
                }
            }).catch(error => {
                console.log('Fetch Document handleVehicleImage():: ', error);
            });
        }
    }

    handleRCCopy() {
        if(FORM_FACTOR==='Large'){
            createDocument({ docType:this.label.RC_Copy, vehicleDetailId: this.vehicleRecordId, applicantId: this.applicantId, loanApplicationId: this.recordid })
            .then(result => {
                this.documentRecordId = result;
                this.docType = this.label.RC_Copy;
                this.showUpload = true;
                this.showDocView = false;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = true;
                this.checkRCButton = false;
                this.isRCClicked = true;
                this.saveDocumentRecord();
            })
            .catch(error => {
                console.log('error in rc copy uploading', error);
            });
        } else {
            fetchDocument({ applicantId: this.applicantId, docType: this.label.RC_Copy,vehicleDetailId: this.vehicleRecordId }).then(result => {
                if(result===null){
                    this.documentRecordId = result;
                    this.docType = this.label.RC_Copy;
                    this.showUpload = true;
                    this.showDocView = false;
                    this.isVehicleDoc = true;
                    this.isAllDocType = false;
                    this.uploadViewDocFlag = true;
                    this.checkRCButton = false;
                    this.isRCClicked = true;
                    //this.saveDocumentRecord();
                }
            }).catch(error => {
                console.log('Fetch Document handleRCCopy():: ', error);
            });
        }
    }

    docUploadSuccessfully(event) {
        this.docUploadSuccessfullyValue = event.detail;
        console.log('Check Event ::', event.detail, '', this.isRCClicked, '', this.captureRCDisabled, '', this.checkRCButton);
        if (this.docUploadSuccessfullyValue && this.isVehicleImageClicked) {
            this.captureVehicleImageDisabled = true;
            this.checkVehicleImageButton = true;
            this.isVehicleImageClicked = false;
        } else if (this.docUploadSuccessfullyValue && this.isRCClicked) {
            this.captureRCDisabled = true;
            this.checkRCButton = true;
            this.isRCClicked = false;
            console.log('Check Event else::', this.captureRCDisabled, '', this.checkRCButton);
        }
    }

    //Save document records
    saveDocumentRecord() {
        console.log('doc id and type ', this.documentRecordId, this.docType);
        const docFields = {};
        docFields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
        docFields[DOCUMENT_TYPE_FIELD.fieldApiName] = this.docType;
        docFields[DOCUMENT_NAME_FIELD.fieldApiName] = this.docType;
        //docFields[IS_PHOTOCOPY_FIELD.fieldApiName] = this.isPhotocopy;
        this.updateDocument(docFields);
    }

    @api currentStage;
    async handleSubmit(event) {
                    this.currentIndex = event.target.dataset.index;
        this.fromHome = false;
        this.fromValuationReport = false;
        this.fromGetValuation = false;
        
        //CISP-2551
        if (this.oemDealerFlag) {
            this.valuationPrice = this.sellingPrice;

        } else {
            this.isValuationPriceDisabled = true;
        }//CISP-2551

        if (this.currentStage === 'Credit Processing') {
            const nextStage = new CustomEvent('submit');
            this.dispatchEvent(nextStage);
        } else {
            let res1 = await this.validityCheck('lightning-input');
            let res2 = await this.validityCheck('lightning-combobox');
            if (!res1  || !res2) {
                const event = new ShowToastEvent({
                    title: this.label.fillAllRequiredFields,
                    variant: 'warning',
                });
                this.dispatchEvent(event);
                return;
            }
            else if (this.valuerCategory === this.label.mfc && !this.disableGetValuation) {
                this.successToast('Warning', 'Get Valuation is Mandatory', 'warning');
            }
            else if (this.valuerCategory === this.label.mfc && !this.requestIdMFC && this.productType == 'Passenger Vehicles') {
                this.disableGetValuation = false;
                this.iconAPIFailed = false;
                this.successToast('Error', 'Please click Get valuation button to get request id', 'Error');
            }
            else if(this.valuerCategory === this.label.mfc && (this.isD2C || this.isTractorProduct) && !this.fetchValuationTick){ //D2C Change
                this.successToast('Warning', 'Valuation Price is Mandatory', 'warning');
            }
            else if (!this.getgridvalueicon && !this.getgridvaluecrossicon && !this.isTractorProduct) {
                this.successToast('Warning', 'Get Grid Value is Mandatory', 'warning');
            }else if(this.isTractorProduct && (!this.gridValue || this.gridValue < 0 || this.gridValue == 0) && this.vehicleSubType != 'Implement'){
                this.successToast('Warning', 'RSV value should be geater than Zero!', 'warning');
            }
            else if (res1 && res1) {
                if ((!this.checkVehicleImageButton && !this.isTractorProduct) ||(!this.checkRCButton && !this.isTractorProduct)) {
                    this.successToast('Warning', 'Please upload all required documents', 'warning');
                    return;
                }else{
                    checkVehicleDocumentsDetails({ loanApplicationId: this.recordid })
                    .then(response => {
                        let result = JSON.parse(response);
                        console.log('result of checkVehicleDocumentsDetails=>', result);
                        if (result.status === false) {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: result.message,
                                variant: 'Error',
                            });
                            this.dispatchEvent(evt);
                        }
                        else {
                           this.saveVehicleDetails();
                        }
                    })
                    .catch(error => {
                        console.log('error in checkVehicleDocumentsDetails =>', error)
                        // this.tryCatchError = error;
                        // this.errorInCatch();
                    });
                }
            }
        }

            }

    async saveVehicleDetails(){
        console.log('before updating the vehicle detail record for vehicle id=', this.vehicleRecordId);
        let saveStatus = {'allowedNavigate': false,'saveMessage': ''};
        const assetDetailsFields = {};
        assetDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleRecordId;
        assetDetailsFields[OWNER_NAME_FIELD.fieldApiName] = this.ownerName;
        assetDetailsFields[OWNER_CONTACT_NUMBER_FIELD.fieldApiName] = this.ownerContactNumber;
        assetDetailsFields[VEHICLE_PLACE_VALUATION_FIELD.fieldApiName] = this.vehiclePlaceOfValuation;
        assetDetailsFields[STATE_FIELD.fieldApiName] = this.selectedStateName;
        assetDetailsFields[CITY_FIELD.fieldApiName] = this.selectedCityName;
        assetDetailsFields[MFC_CITY_MASTER_FIELD.fieldApiName] = this.selectedCityIDValue;
        assetDetailsFields[MFC_STATE_MASTER_FIELD.fieldApiName] = this.selectedStateIDValue;
        assetDetailsFields[LOCATION_OF_VEHICLE_FIELD.fieldApiName] = this.locationOfVehicle;
        assetDetailsFields[EXECUTIVE_NAME_FIELD.fieldApiName] = this.executiveName;
        assetDetailsFields[EXECUTIVE_CONTACT_NUMBER_FIELD.fieldApiName] = this.executiveContactNumber;
        assetDetailsFields[VALUER_CATEGORY_FIELD.fieldApiName] = this.valuerCategory;
        assetDetailsFields[VALUER_FIELD.fieldApiName] = this.valuerName;
        assetDetailsFields[VALUER_CODE_FIELD.fieldApiName] = this.valuerCode;
        assetDetailsFields[SLA_NUMBER_FIELD.fieldApiName] = this.slaNumber;
        assetDetailsFields[SELLING_PRICE_FIELD.fieldApiName] = this.sellingPrice;
        assetDetailsFields[VALUATION_PRICE_FIELD.fieldApiName] = this.valuationPrice;
        assetDetailsFields[INSURANCE_DECLARED_VALUE_FIELD.fieldApiName] = this.insDeclaredValue;
        assetDetailsFields[COLOR_OF_VEHICLE_FIELD.fieldApiName] = this.colorOfVehicle;
        assetDetailsFields[KMS_RUN_FIELD.fieldApiName] = this.kmsRun;
        assetDetailsFields[PURPOSE_OF_IBB_FETCH_FIELD.fieldApiName] = this.purposeOfIBBFetch;
        assetDetailsFields[GRID_VALUE_FIELD.fieldApiName] = this.gridValue;
        assetDetailsFields[MFC_Request_Id.fieldApiName] = this.requestIdMFC;
        assetDetailsFields[VALUATION_REPORTURL_FIELD.fieldApiName] = this.reportURL;
        assetDetailsFields[VALUATION_OverallRemarks_FIELD.fieldApiName] = this.overallRemarks;
        assetDetailsFields[MFC_Valuation_Report_Date.fieldApiName] = this.mfcGenerationDate;

        await this.updateRecordDetails(assetDetailsFields)
            .then(() => {
                console.log('Inside Save: ',this.fromHome);
                console.log('this.fromValuationReport ',this.fromValuationReport);
                console.log('this.fromGetValuation: ',this.fromGetValuation);
                if((!this.fromHome) && (!this.fromGetValuation) && (!this.fromValuationReport) && (!this.isTractorProduct)){
                    console.log('updating the vehicle detail record');
                    const oppFields = {};
                    oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                    oppFields[STAGENAME.fieldApiName] = 'Loan Details';
                    oppFields[LAST_STAGE_NAME.fieldApiName] = 'Loan Details';
                    this.updateRecordDetails(oppFields);
                    this.callLoanApplicationHistory('Loan Details');
                    if(this.isD2C){
                        this.disableEverything();
                        doVehicleValuationCallout({loanAppId : this.recordid, screen : 'valuation'})
                        .then(result=>{}).
                        catch(error=>{
                            console.log(error);
                        });
                    }
                }else if((!this.fromHome) && (!this.fromGetValuation) && (!this.fromValuationReport) && (this.isTractorProduct)){
                    console.log('inside else');
                    this.dispatchEvent(new CustomEvent('submitvehiclevaluation', {
                        detail: {
                            'currentIndex' : this.currentIndex,
                            'vehicleDetailId' : this.vehicleRecordId,
                            'isSubmit' : true
                        } 
                    }));
                }
                saveStatus.allowedNavigate = true;
                saveStatus.saveMessage = 'Navigation Success';
            }).catch(error => {
                console.log('error in updating the vehicle record=>', error);
                this.tryCatchError = error;
                this.errorInCatch();
                saveStatus.allowedNavigate = false;
                saveStatus.saveMessage = 'Navigation Fail';
            })
            return saveStatus;
    }
    @api
    callLoanApplicationHistory(nextStage) {

        getLoanApplicationHistory({ loanId: this.recordid, stage: 'Vehicle Valuation', nextStage: nextStage }).then(response => {
            console.log('getLoanApplicationHistory Response:: ', response);
            if (response) {
                this.navigateToHomePage();
            } else {
                this.dispatchEvent(new CustomEvent('submitnavigation', {
                    detail: nextStage,
                    bubbles: true,
                    composed: true
                }));
            }
        }).catch(error => {
            console.log('Error getLoanApplicationHistory:: ', error);
        });
    }

    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordid , stage: 'Vehicle Valuation'}).then(response => {
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

    async updateDocument(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('doc updated successfully');
            }).catch(error => {
                console.log('error in updating the document', error);
            })
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: this.label.vehicleValuationDetailsSaved,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            })
            .catch(error => {
                console.log('error in updation =>', error);
                this.tryCatchError = error;
            });
    }

    async validityCheck(query) {
        return await [...this.template.querySelectorAll(query)]
            .reduce((validSoFar, inputField) => {
                if (query === 'c-I-N-D_-L-W-C_-Custom_-Lookup') {
                    inputField.displayValidityError();
                    return true;
                }
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
    }

    successToast(toastTitle, message, variant) {

        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    async handleHome() {
        this.fromHome = true;
        await this.saveVehicleDetails().then(submitResult => {
            if (submitResult.allowedNavigate) {
                this.navigateToHomePage();

            }
        }).catch(error => {
            console.log('Error In Saving Details - Error:: ', error);
        });
    }

    @api
    async handleHomeClick() {
        console.log('Inside handleHomeClick');
        this.fromHome = true;
         await this.saveVehicleDetails().then(submitResult => {
            if (submitResult.allowedNavigate) {
                console.log('inside navigation');
                this.dispatchEvent(new CustomEvent("homenavigation", {
                    detail: {
                        'count': "1"
                    } 
                }));
            }
        }).catch(error => {
            console.log('Error In Saving Details - Error:: ', error);
        });
    }

    navigateToHomePage() {
        isCommunity()
            .then(response => {
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
            })
            .catch(error => {
            });

    }
    @api
    viewUploadViewFloater() {
        this.showFileUploadAndView = true;
    }
    closeUploadViewFloater(event){
        this.showFileUploadAndView = false;
    }
    @api
    disableEverything() {
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
}