import { LightningElement, api, track, wire } from 'lwc';
import getCreditProcessTabs from '@salesforce/apex/IND_CreditProcessing.getCreditProcessTabs';
import IsAllRequiredFISubmitted from '@salesforce/apex/IND_ResidenceFIController.IsAllRequiredFISubmitted';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord , getRecord , getFieldValue } from "lightning/uiRecordApi";

import getTabList from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getTabList';
import getTabListForInsurance from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getTabListForInsurance';
import checkL2CibilSubmitted from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkL2CibilSubmitted';
import getHunterResponse from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getHunterResponse';

import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import VIEWApp_SUB_STAGE_FIELD from "@salesforce/schema/Opportunity.View_Application_Sub_Stages__c";
import SUB_STAGE_FIELD from "@salesforce/schema/Opportunity.Sub_Stage__c";
//import getcvalue from '@salesforce/apex/IND_CreditProcessing.getcreditvalue';
import PRODUCT_TYPE from "@salesforce/schema/Opportunity.Product_Type__c";


import View_Application_Details from '@salesforce/label/c.View_Application_Details';
import CIBIL from '@salesforce/label/c.CIBIL';
import Field_Investigation from '@salesforce/label/c.Field_Investigation';
import Valuation_IDV from '@salesforce/label/c.Valuation_IDV';
import IncomeTab from '@salesforce/label/c.IncomeTab';
import Final_Terms from '@salesforce/label/c.Final_Terms';
import Risk_Summary from '@salesforce/label/c.Risk_Summary';
import Exposure_Analysis from '@salesforce/label/c.Exposure_Analysis';
import Credit_Assesment from '@salesforce/label/c.Credit_Assesment';
import Lead_KYC_Details from '@salesforce/label/c.Lead_KYC_Details';
import Additional_Customer_Details from '@salesforce/label/c.Additional_Customer_Details';
import Asset_Details from '@salesforce/label/c.Asset_Details';
import Vehicle_Insurance from '@salesforce/label/c.Vehicle_Insurance';
import Vehicle_Valuation from '@salesforce/label/c.Vehicle_Valuation';
import Loan_Details from '@salesforce/label/c.Loan_Details';
import Income_Details from '@salesforce/label/c.Income_Details';
import Insurance_Details from '@salesforce/label/c.Insurance_Details';
import Additional_Customer_Codes from '@salesforce/label/c.Additional_Customer_Codes';
import Final_Offer_Page from '@salesforce/label/c.Final_Offer_Page';
import Engine_Outputs from '@salesforce/label/c.Engine_Outputs';
import Current_Residence_FI from '@salesforce/label/c.Case_Current_Residence_FI_Type';
import Permanent_Residence_FI from '@salesforce/label/c.Case_Permanent_Residence_FI_Type';
import Office_FI from '@salesforce/label/c.Case_Office_FI_Type';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import Credit_Processing from '@salesforce/label/c.Credit_Processing';
import Insurance from '@salesforce/label/c.Insurance';
import CAM_and_Approval_Log from '@salesforce/label/c.CAM_and_Approval_Log';
import Deal_Number_Customer_Code from '@salesforce/label/c.Deal_Number_Customer_Code';// Gaurav : Import Deal number customer code custom label.
import Sanction_of_Application from '@salesforce/label/c.Sanction_of_Application'; // Gaurav : Import sanction of application custom label.
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import loadVehicleDetailsDataForTractor from '@salesforce/apex/IND_ValuationIDVCntrl.loadVehicleDetailsDataForTractor';


export default class IND_LWC_ViewApplicationData extends LightningElement {

    label = {
        View_Application_Details,
        CIBIL,
        Field_Investigation,
        Valuation_IDV,
        IncomeTab,
        Final_Terms,
        Risk_Summary,
        Exposure_Analysis,
        Credit_Assesment,
        Lead_KYC_Details,
        Additional_Customer_Details,
        Asset_Details,
        Vehicle_Insurance,
        Vehicle_Valuation,
        Loan_Details,
        Income_Details,
        Insurance_Details,
        Additional_Customer_Codes,
        Final_Offer_Page,
        Engine_Outputs,
        Current_Residence_FI,
        Permanent_Residence_FI,
        Office_FI,
        Borrower,
        CoBorrower,
        Credit_Processing,
        Insurance,
        CAM_and_Approval_Log,
        Sanction_of_Application, // Gaurav : Added sanction of application custom label for tab visiblity.
        Deal_Number_Customer_Code // Gaurav : Added deal number customer code custom label for tab visiblity.
    }

    @track cibilTabList = [];
    @track cibilL2SubmittedTabList = [];

    @track tabListCount;
    @api tabList// = [this.label.Borrower, this.label.CoBorrower];
    @api tab = this.label.Borrower;
    @api tabValue = this.label.Borrower;
    @api borroweIncomeSource = false;
    @api isCapturImageSuccess = false;
    @api getcreditvalue = false;
    @api recordId;
    @api nextTab = [];
    @api appId;
    @api appids;
    @api creditProcFlag;
    @api currentoppstage;

    @track currentStage = this.label.Credit_Processing;
    @track tabs = [this.label.Borrower, this.label.CoBorrower];
    @track loanpage = false;
    @track activeviewappsubtab;
    @track currentSubTab = undefined;
    @track activeMainTab = undefined;
    @track applicantTypeList = []
    @track testDec;
    @track activeTab;
    @track isCoborrowerExist = false;
    @track currentResidenceFIMap = [];
    @track permanentResidenceFIMap = [];
    @track officeFIMap = [];
    @track activeFISubTab;
    @track activeTabValue;
    @track showScreen = false;
    // D2C_CHANGE - Raman
    @track oppty;
    // EO D2C_CHANGE
    @track vehicleType;//CISP-4116
    @track currentTabIndex;
    @track mainTablist = {
        "viewapplicationdata": true,
        "cibil": false,
        "fieldinvestigation": false,
        "valuationidv": false,
        "income": false,
        "finalterms": false,
        "insurance": false,
        "risksummary": false,
        "exposureanlaysis": false,
        "creditassessment": false,
        "camapprovallog": false,
        "sanctionofapplication": false, // Gaurav : Added sanctionofapplication flag.
        "dealnumberandcodegeneration": false,// Gaurav : Added dealnumberandcodegeneration flag.
    };


    @track viewappsubtabs =
        {
            "leadkyc": true,
            "additionalcustomerdetails": true,
            "assetdetails": true,
            "vehicleinsurance": false,
            "vehiclevaluation": false,
            "loanDetails": true,
            "incomeDetails": true,
            "finalTerms": true,
            "insuranceDetails": true,
            "additionalCustomerCode": true,
            "finalOfferPage": true,
            "engineOutputs": true
        };

    viewappsubtabFlags = {
        "Lead/KYC Details": "leadkyc",
        "Additional Customer Details": "additionalcustomerdetails",
        "Asset Details": "assetdetails",
        "Vehicle Insurance": "vehicleinsurance",
        "Vehicle Valuation": "vehiclevaluation",
        "Loan Details": "loanDetails",
        "Income Details": "incomeDetails",
        "Final Terms": "finalTerms",
        "Insurance Details": "insuranceDetails",
        "Additional Customer Code": "additionalCustomerCode",
        "Final Offer Page": "finalOfferPage",
        "Engine Outputs": "engineOutputs"
    }

    tabnamesAndFlags = {
        "View Applicatiion Details": "viewapplicationdata",
        "CIBIL": "cibil",
        "Field Investigation": "fieldinvestigation",
        "Valuation IDV": "valuationidv",
        "Income": "income",
        "Final Terms": "finalterms",
        "Insurance": "insurance",
        "Risk Summary": "risksummary",
        "Exposure Analysis": "exposureanlaysis",
        "Credit Assessment": "creditassessment",
        "CAM and Approval Log": "camapprovallog",
        "Sanction of Application": "sanctionofapplication", // Gaurav : Added sanction of application tab value.
        "Deal Number & Customer Code Generation": "dealnumberandcodegeneration", // Gaurav : Added Deal Number & Customer Code Generation tab value.
    };

    @track showFIsubtabs =
        {
            "currentResidenceFI": false,
            "permanentResidenceFI": false,
            "officeFI": false
        };

    @track viewFIsubtabs =
        {
            "borrowerCurrentResidenceFI": false,
            "borrowerPermanentResidenceFI": false,
            "borrowerOfficeFI": false,
            "coBorrowerCurrentResidenceFI": false,
            "coBorrowerPermanentResidenceFI": false,
            "coBorrowerOfficeFI": false
        };

    @track statusofFIsubtabs =
        {
            "borrowerCurrentResidenceFI": false,
            "borrowerPermanentResidenceFI": false,
            "borrowerOfficeFI": false,
            "coBorrowerCurrentResidenceFI": false,
            "coBorrowerPermanentResidenceFI": false,
            "coBorrowerOfficeFI": false
        };


    @api checkleadaccess;//coming from tabloanApplication
    @api isRevokedLoanApplication;//CISP-2735
    @track vehicleDetailList = [];

    connectedCallback() {
        this.getCreditProcessTabsHandler();
        if (this.checkleadaccess) {//if lead is accessible but user from different profile is viewing that
            const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
        }
        this.getTabListFunctionForInsurance();
        this.getTabListFunction();

        this.init();

    }

    async init(){
        await loadVehicleDetailsDataForTractor({ loanApplicationId: this.recordId })
        .then(response => {
            let result = JSON.parse(response);
            this.vehicleDetailList = result;
            this.vehicleDetailList = this.vehicleDetailList.filter(ele => ele.vehicleSubType != 'Implement');
        }).catch(error => {
            console.log('Error ',error);
        });
    }

    // SFTRAC-91-Start
    @wire(getRecord, { recordId: '$recordId', fields: [PRODUCT_TYPE , SUB_STAGE_FIELD]})
    getProductType;

    get isTractor(){
        let proType = getFieldValue(
            this.getProductType.data,
            PRODUCT_TYPE
        );
        if(proType == 'Tractor'){
            return true;
        }
        else{
            return false;
        }
    }

    get subStage(){
        let subStg = getFieldValue(
            this.getProductType.data,
            SUB_STAGE_FIELD
        );
        if(subStg == 'Valuation IDV'){
            return false;
        }
        else{
            return true;
        }
    }
    //SFTRAC-91-End

    getTabListFunction() {
        getTabList({ loanApplicationId: this.recordId }).then(result => {
            console.log('getTabList -- > ', JSON.stringify(result));
            if (result.length > 0) {
                this.cibilTabList = result;
                for (let index = 0; index < this.cibilTabList.length; index++) {
                    this.cibilL2SubmittedTabList.push({'index' : index , submitted : false});
                }
            }
        }).catch(error => {
            console.log('error::', error);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong, Please contact your administrator.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });
    }
    @track insuranceTabList = [];
    getTabListFunctionForInsurance() {
        getTabListForInsurance({ loanApplicationId: this.recordId }).then(result => {
            if (result.length > 0) {
                console.log('getTabListFunctionForInsurance --> ', result)
                this.insuranceTabList = result;
            }
        }).catch(error => {
            console.log('error::', error);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong, Please contact your administrator.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });
    }

    //fetching WebApp tab names by passing Loan Application Id
    getCreditProcessTabsHandler(){
        getCreditProcessTabs({ loanApplicationId: this.recordId }).then(data=>{
        if (data) {
            console.log('data.vehicleInsurance ::', data.vehicleInsurance);
            console.log('data vehicleValuation : ', data.vehicleValuation);
            console.log(data);
            console.log('view applicatn current tab :' + data.viewAppCurrentTab);
            console.log('view applicatn Main tab :' + data.currentTab);
            this.showScreen = data.showtab || this.creditProcFlag ? true : false;
            const currTabname = data.viewAppCurrentTab;
            this.activeTab = data.currentTab;
            this.appId = data.applicantIds;
            // D2C_CHANGE - Raman
            this.oppty = data.oppty;
            // EO D2C_CHANGE
            this.vehicleType = data.vehicleType;//CISP-4116
            if (data.applicantIds) {

                this.appids = data.applicantIds[0];
                console.log(' this.appids ', this.appids);
            }


            this.activeMainTab = data.currentTab;
            this.viewappsubtabs.vehicleinsurance = data.vehicleInsurance;
            this.viewappsubtabs.vehiclevaluation = data.vehicleValuation;
            if (this.tabnamesAndFlags[data.currentTab] != undefined) {
                let tempTabFlag = data.currentTab;
                console.log('tempTabFlag :' + tempTabFlag);
                switch (tempTabFlag) {
                    case this.label.View_Application_Details:
                        this.mainTablist.viewapplicationdata = true;

                        break;
                    case this.label.CIBIL:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        break;
                    case this.label.Field_Investigation:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        break;
                    case this.label.Valuation_IDV:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        break;
                    case this.label.IncomeTab:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        break;
                    case this.label.Final_Terms:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        break;
                    case this.label.Insurance:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        this.mainTablist.insurance = true;
                        break;
                    case this.label.Risk_Summary:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        this.mainTablist.insurance = true;
                        this.mainTablist.risksummary = true;
                        break;
                    case this.label.Exposure_Analysis:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        this.mainTablist.insurance = true;
                        this.mainTablist.risksummary = true;
                        this.mainTablist.exposureanlaysis = true;
                        break;
                    case this.label.Credit_Assesment:
                        console.log('inside Credit Assessment');
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        this.mainTablist.insurance = true;
                        this.mainTablist.risksummary = true;
                        this.mainTablist.exposureanlaysis = true;
                        this.mainTablist.creditassessment = true;
                        break;
                    case this.label.CAM_and_Approval_Log:
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        this.mainTablist.insurance = true;
                        this.mainTablist.risksummary = true;
                        this.mainTablist.exposureanlaysis = true;
                        this.mainTablist.creditassessment = true;
                        this.mainTablist.camapprovallog = true;
                        break;
                    case this.label.Sanction_of_Application: // Gaurav : Added this case for previous tab visiblity and current tab.
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        this.mainTablist.insurance = true;
                        this.mainTablist.risksummary = true;
                        this.mainTablist.exposureanlaysis = true;
                        this.mainTablist.creditassessment = true;
                        this.mainTablist.camapprovallog = true;
                        this.mainTablist.sanctionofapplication = true;
                        break;
                    case this.label.Deal_Number_Customer_Code: // Gaurav : Added this case for previous tab visiblity and current tab.
                        this.mainTablist.viewapplicationdata = true;
                        this.mainTablist.cibil = true;
                        this.mainTablist.fieldinvestigation = true;
                        this.mainTablist.valuationidv = true;
                        this.mainTablist.income = true;
                        this.mainTablist.finalterms = true;
                        this.mainTablist.insurance = true;
                        this.mainTablist.risksummary = true;
                        this.mainTablist.exposureanlaysis = true;
                        this.mainTablist.creditassessment = true;
                        this.mainTablist.camapprovallog = true;
                        this.mainTablist.sanctionofapplication = true;
                        this.mainTablist.dealnumberandcodegeneration = true;
                        break;
                }
            }

            if ((this.currentoppstage == 'Post Sanction Checks and Documentation' || this.currentoppstage == 'Pre Disbursement Check' || this.currentoppstage == 'Disbursement Request Preparation')) { //Kruthi : Added for screen visibility at future stages
                this.mainTablist.viewapplicationdata = true;
                this.mainTablist.cibil = true;
                this.mainTablist.fieldinvestigation = true;
                this.mainTablist.valuationidv = true;
                this.mainTablist.income = true;
                this.mainTablist.finalterms = true;
                this.mainTablist.insurance = true;
                this.mainTablist.risksummary = true;
                this.mainTablist.exposureanlaysis = true;
                this.mainTablist.creditassessment = true;
                this.mainTablist.camapprovallog = true;
                this.mainTablist.sanctionofapplication = true;
                this.mainTablist.dealnumberandcodegeneration = true;
            }
            this.tabs = data; //JSON.stringify(data);
            this.loanpage = true;
            let currentTabFlag = this.viewappsubtabFlags[currTabname];
            console.log('currentTabFlag :' + currentTabFlag);
            this.activeviewappsubtab = currTabname;

            this.currentSubTab = data.viewAppCurrentTab;
            this.applicantTypeList = data.applicantTypes;
            this.tabListCount = this.applicantTypeList.length;
            if(this.activeMainTab == this.label.Field_Investigation){
                if(this.currentResidenceFIMap && this.currentResidenceFIMap.length > 0){
                    this.activeTabValue = this.currentResidenceFIMap[0].value;
                }else if(this.permanentResidenceFIMap && this.permanentResidenceFIMap.length > 0){
                    this.activeTabValue = this.permanentResidenceFIMap[0].value;
                }else if(this.officeFIMap && this.officeFIMap.length > 0){
                    this.activeTabValue = this.officeFIMap[0].value;
                }
            }else{
                this.activeTabValue = this.tabList.length > 0 ? this.tabList[0].applicantId : this.applicantTypeList[0];
            }
            if (this.applicantTypeList.length > 1) {
                this.isCoborrowerExist = true;
            }
            this.processFieldInvestigationRecords(data.fieldInvestigationsMap, data.fiStatusMap); // Field Investigation
            console.log('appliicant type list => ', this.applicantTypeList);
            console.log('  this.activeviewappsubtab :' + this.activeviewappsubtab);
            console.log('this.activetab && this.activemaintab => ', this.activeTab, this.activeMainTab, this.activeMainTab === this.activeTab);
            console.log('Next tabs list : ', data.nextTabsMap);
            this.nextTab = data.nextTabsMap;
            console.log('next tabs Map :', this.nextTab)
        }
        }).catch(error=>{
            console.log(error);
        })
    }
    
    async navigateCoborrower() {
        let tab = await this.tabList.filter((ele)=> ele.applicantType == this.label.CoBorrower);
        this.activeTabValue = tab && tab.length > 0 ? tab[0].applicantId : this.activeTabId;
    }

    handleMainActiveTab(event) {
        console.log('acitve tab == > ', this.activeTab, ' ', this.activeMainTab);
        console.log('event target value ::' + event.target.value);
        this.activeMainTab = event.target.value;
        console.log('income main tab : ' + this.mainTablist.income)
        if (((this.activeMainTab == this.label.View_Application_Details && !this.mainTablist.viewapplicationdata) ||
            (this.activeMainTab == this.label.CIBIL && !this.mainTablist.cibil) ||
            (this.activeMainTab == this.label.Field_Investigation && !this.mainTablist.fieldinvestigation) ||
            (this.activeMainTab == this.label.Valuation_IDV && !this.mainTablist.valuationidv) ||
            (this.activeMainTab == this.label.IncomeTab && !this.mainTablist.income) ||
            (this.activeMainTab == this.label.Final_Terms && !this.mainTablist.finalterms) ||
            (this.activeMainTab == this.label.Insurance && !this.mainTablist.insurance) ||
            (this.activeMainTab == this.label.Exposure_Analysis && !this.mainTablist.exposureanlaysis) ||
            (this.activeMainTab == this.label.Credit_Assesment && !this.mainTablist.creditassessment) ||
            (this.activeMainTab == this.label.Risk_Summary && !this.mainTablist.risksummary) ||
            (this.activeMainTab == this.label.CAM_and_Approval_Log && !this.mainTablist.camapprovallog) ||
            (this.activeMainTab == this.label.Sanction_of_Application && !this.mainTablist.sanctionofapplication) || // Gaurav : Added OR condition for Sanction of Application tab visiblity.
            (this.activeMainTab == this.label.Deal_Number_Customer_Code && !this.mainTablist.dealnumberandcodegeneration)) && // Gaurav : Added OR condition for deal number and code generation tab visiblity.
            (this.currentoppstage != 'Post Sanction Checks and Documentation' && this.currentoppstage != 'Pre Disbursement Check' && this.currentoppstage != 'Disbursement Request Preparation')) //Kruthi : Added for screen visibility at future stages
        {
            console.log('Inside if condition');
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please submit the previous tab first',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
        if(this.activeMainTab == this.label.Field_Investigation){
            if(this.currentResidenceFIMap && this.currentResidenceFIMap.length > 0){
                this.activeTabValue = this.currentResidenceFIMap[0].value;
            }else if(this.permanentResidenceFIMap && this.permanentResidenceFIMap.length > 0){
                this.activeTabValue = this.permanentResidenceFIMap[0].value;
            }else if(this.officeFIMap && this.permanentResidenceFIMap.length > 0){
                this.activeTabValue = this.officeFIMap[0].value;
            }
        }else{
            this.activeTabValue = this.tabList.length > 0 ? this.tabList[0].applicantId : this.applicantTypeList ? this.applicantTypeList[0] : '';
        }
    }

    handleActiveSubTab(event) {
        this.activeviewappsubtab = event.target.value;
        if (((this.activeviewappsubtab === this.label.Additional_Customer_Details && !this.viewappsubtabs.additionalcustomerdetails) ||
            (this.activeviewappsubtab === this.label.Asset_Details && !this.viewappsubtabs.assetdetails) ||
            (this.activeviewappsubtab === this.label.Vehicle_Insurance && !this.viewappsubtabs.vehicleinsurance) ||
            (this.activeviewappsubtab === this.label.Vehicle_Valuation && !this.viewappsubtabs.vehiclevaluation) ||
            (this.activeviewappsubtab === this.label.Loan_Details && !this.viewappsubtabs.loanDetails) ||
            (this.activeviewappsubtab === this.label.Income_Details && !this.viewappsubtabs.incomeDetails) ||
            (this.activeviewappsubtab === this.label.Final_Terms && !this.viewappsubtabs.finalTerms) ||
            (this.activeviewappsubtab === this.label.Insurance_Details && !this.viewappsubtabs.insuranceDetails) ||
            (this.activeviewappsubtab === this.label.Additional_Customer_Codes && !this.viewappsubtabs.additionalCustomerCode) ||
            (this.activeviewappsubtab === this.label.Final_Offer_Page && !this.viewappsubtabs.finalOfferPage) ||
            (this.activeviewappsubtab === this.label.Deal_Number_Customer_Code && !this.viewappsubtabs.dealNumberAndCustomerCode) ||
            (this.activeviewappsubtab === this.label.Engine_Outputs && !this.viewappsubtabs.engineOutputs)) &&
            (this.currentoppstage == this.label.Credit_Processing)) {
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please submit the ' + this.currentSubTab + ' tab first',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
        this.activeTabValue = this.tabList.length > 0 ? this.tabList[0].applicantId : this.applicantTypeList ? this.applicantTypeList[0] : '';
    }

    @api submit(event) {
        console.log('enteredsubmit');
        let activeSubTab = undefined;
        if (this.activeviewappsubtab === this.label.Lead_KYC_Details) {
            activeSubTab = this.label.Additional_Customer_Details;
            this.viewappsubtabs.additionalcustomerdetails = true;
        }
        if (this.activeviewappsubtab === this.label.Additional_Customer_Details) {
            activeSubTab = this.label.Asset_Details;
            this.viewappsubtabs.assetdetails = true;
        }
        if (this.activeviewappsubtab === this.label.Asset_Details) {
            activeSubTab = this.label.Vehicle_Insurance;
            //this.viewappsubtabs.vehicleinsurance = true;
            //CISP-4116 changes start.
            if(this.vehicleType==='New'){
                activeSubTab = this.label.Loan_Details;
                this.viewappsubtabs.loanDetails = true;
            }
            //CISP-4116 changes end.
        }
        if (this.activeviewappsubtab === this.label.Vehicle_Insurance) {
            activeSubTab = this.label.Vehicle_Valuation;
            this.viewappsubtabs.vehiclevaluation = true;
        }
        if (this.activeviewappsubtab === this.label.Vehicle_Valuation) {
            activeSubTab = this.label.Loan_Details;
            this.viewappsubtabs.loanDetails = true;
        }
        if (this.activeviewappsubtab === this.label.Loan_Details) {
            activeSubTab = this.label.Income_Details;
            this.viewappsubtabs.incomeDetails = true;
        }
        if (this.activeviewappsubtab === this.label.Income_Details) {
            activeSubTab = this.label.Final_Terms;
            this.viewappsubtabs.finalTerms = true;
        }
        if (this.activeviewappsubtab === this.label.Final_Terms) {
            activeSubTab = this.label.Insurance_Details;
            this.viewappsubtabs.insuranceDetails = true;
        }
        if (this.activeviewappsubtab === this.label.Insurance_Details) {
            activeSubTab = this.label.Additional_Customer_Codes;
            this.viewappsubtabs.additionalCustomerCode = true;
        }
        if (this.activeviewappsubtab === this.label.Additional_Customer_Codes) {
            activeSubTab = this.label.Final_Offer_Page;
            this.viewappsubtabs.finalOfferPage = true;
        }
        if (this.activeviewappsubtab === this.label.Final_Offer_Page) {
            activeSubTab = this.label.Deal_Number_Customer_Code;
            this.viewappsubtabs.dealNumberAndCustomerCode = true;
        }
        if (this.activeviewappsubtab === this.label.Deal_Number_Customer_Code) {
            activeSubTab = this.label.Engine_Outputs;
            this.viewappsubtabs.engineOutputs = true;
        }
        if (this.activeviewappsubtab === this.label.Engine_Outputs) {
            activeSubTab = this.label.Engine_Outputs;
            this.viewappsubtabs.engineOutputs = true;
        }

        this.activeviewappsubtab = activeSubTab;
        this.currentSubTab = this.activeviewappsubtab;

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[VIEWApp_SUB_STAGE_FIELD.fieldApiName] = activeSubTab;
        const recordInput = {
            fields: fields
        };

        updateRecord(recordInput).then((record) => {
            console.log(record);
        });
    }


    handlecibilevent(event) {
        console.log('handle event is triggered');
        const textVal = event.detail;
        console.log('next tab name : ', textVal);
        console.log(' nextTab map ', this.nextTab[textVal]);
        this.updateSubStageField(textVal);
    }
    async handletfcibilevent(event) {
        try{
            let tabIndex = event.detail.tabIndex;
            if(this.cibilL2SubmittedTabList && this.cibilL2SubmittedTabList.length > 0){
                this.cibilL2SubmittedTabList[tabIndex].submitted = true;
            }
            let allCIBILTabSubmitted = true;
            for (let index = 0; index < this.cibilL2SubmittedTabList.length; index++) {
                if(this.cibilL2SubmittedTabList[index].submitted == false){
                    allCIBILTabSubmitted = false;
                    break;
                }                
            }
            let result = await checkL2CibilSubmitted({'loanApplicationId' : this.recordId});
            if(result == true && allCIBILTabSubmitted == true){
                this.updateSubStageField(CIBIL);
            }else if(this.cibilTabList && this.cibilTabList.length > 0){
                if(this.cibilTabList[tabIndex + 1]){
                    this.activeTabValue = this.cibilTabList[tabIndex + 1].applicantId;
                }
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please submit the all tabs of CIBIL!',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            }
        }catch(error){
            console.log(error);
        }
    }

    handlevaluationevent(event) {
        console.log('valuation IDV handle event is triggered');
        const textVal = event.detail;
        console.log('next tab name : ', textVal);
        console.log(' nextTab map ', this.nextTab);
        this.updateSubStageField(textVal);
    }

    handleActiveSecondSubTab(event) {
        console.log('acitve tab ===>  ', this.activeTabValue);
        console.log('event target ===> 363 ', event.target);
        console.log('event target ===> 364 ', event.target.value);
        this.tab = this.label.CoBorrower;
        this.activeTabValue = event.target.value;
    }

    switchincomedetailstab(event) {
        this.activeTab = this.label.CoBorrower;
    }

    handleincomeevent(event) {
        console.log('handle Income details event is triggered');
        const textVal = event.detail;
        console.log('dispatch event name : ', textVal);
        this.updateSubStageField(textVal);
    }

    handlefinaltermsevent(event) {
        console.log('handle final terms details event is triggered');
        const textVal = event.detail;
        console.log('dispatch event name : ', textVal);
        this.updateSubStageField(textVal);
    }

    handleExposureevent(event) {
        console.log('handle Exposure event is triggered');
        const textVal = event.detail;
        console.log('dispatch event name : ', textVal);
        this.updateSubStageField(textVal);
    }

    tabCount = 0;
    async handlecreditassesevent(event) {
        console.log('handle final terms details event is triggered');
        const textVal = event.detail;
        console.log('textVal ' + textVal);
        console.log('Tab value :' + this.activeTabValue);
        for (let index = 0; index < this.tabList.length; index++) {
            const element = this.tabList[index];
            if(element.applicantId == this.activeTabValue){
                this.tabCount++;
            }
        }
        if (this.tabCount >= this.tabList.length) {
            console.log('Coborrower tab :', this.nextTab);
            if (this.nextTab[textVal] !== undefined) {
                console.log('dispatch event name : ', textVal);

                if(this.isTractor){
                    // let result = await getHunterResponse({'loanApplicationId' : this.recordId});
                    // if(result && !result.isHunterResponseOk && result.isHunterMatchResponse !== 'No Match'){
                    //     const evt = new ShowToastEvent({
                    //         title: 'Warning',
                    //         message: 'Hunter APS response is pending!',
                    //         variant: 'warning',
                    //     });
                    //     this.dispatchEvent(evt);
                    //     return;
                    // }else if(result && result.isHunterResponseOk !== 'OK' && result.isHunterMatchResponse !== 'No Match'){
                    //     const evt = new ShowToastEvent({
                    //         title: 'Warning',
                    //         message: `Hunter APS has returned ${result.isHunterResponseOk} status. Hence you can not proceed.`,
                    //         variant: 'warning',
                    //     });
                    //     this.dispatchEvent(evt);
                    //     return;
                    // }else{
                        this.updateSubStageField(textVal);
                    // }
                }else{
                    this.updateSubStageField(textVal);
                }

            }
        }
    }

    // Gaurav : Added handleCamAndApprovalEvent method for the update the next sub tab.
    handleCamAndApprovalEvent(event) {
        const textVal = event.detail;
        this.activeTab = textVal;
        this.updateSubStageField(textVal);
    }

    handleCamAndApprovalTabEvent(event) {
        this.activeTab = undefined;
        console.log('this.mainTablist ', event);
        const textVal = event.detail;
        setTimeout(() => {
            this.setNextTab(textVal);
        },);
    }

    // Gaurav : Added handleSanctionOfApplicationEvent method for the update the next sub tab.
    handleSanctionOfApplicationEvent(event) {
        const textVal = event.detail;
        this.updateSubStageField(textVal);
    }

    handlerisksummaryevent(event) {
        console.log('handle risk summary terms details event is triggered');
        const textVal = event.detail;
        console.log('textVal ' + textVal);
        console.log('dispatch event name : ', textVal);
        this.updateSubStageField(textVal);
    }

    handleMainInsurnaceTabEvent(event) {
        console.log('handle inusrance event trigged ', event, '  event ', event.detail);
        this.activeTabValue = this.label.Borrower;
        const textVal = event.detail;
        console.log('textVal ' + textVal);
        console.log('dispatch event name : ', textVal);
        this.updateSubStageField(textVal);
    }


    setNextTab(textVal) {
        if (this.nextTab[textVal] !== undefined) {
            console.log(' nextTab map 222', this.nextTab[textVal]);
            this.activeTab = this.nextTab[textVal];
            const temptabval = this.nextTab[textVal];
            const tempTabkey = this.tabnamesAndFlags[temptabval];
            console.log('555' + tempTabkey);
            console.log('main tab obj ', this.mainTablist);
            this.mainTablist[tempTabkey] = true;
            console.log('income flag 333' + this.mainTablist.income);

        }
    }


    handleBorrowerIncomeSource(event) {
        console.log('Event Value::', event.detail);
        this.borroweIncomeSource = event.detail;
    }

    // Field Investigation - Start
    processFieldInvestigationRecords(fieldInvestigationsMap, fiStatusMap) {
        console.log('fieldInvestigationsMap ==', JSON.stringify(fieldInvestigationsMap));
        console.log('fiStatusMap ==', JSON.stringify(fiStatusMap));
        for (var applicantType in fieldInvestigationsMap) {
            for (var fiRecordId in fieldInvestigationsMap[applicantType]) {
                let caseType = fieldInvestigationsMap[applicantType][fiRecordId];
                if (caseType === this.label.Current_Residence_FI) {
                    this.currentResidenceFIMap.push({ value: fiRecordId, key: applicantType });
                    this.currentResidenceFIMap.sort(function (a, b) {
                        return a.key < b.key ? -1 : 1;
                    });
                    this.showFIsubtabs.currentResidenceFI = true;
                    if (applicantType === this.label.Borrower) {
                        this.viewFIsubtabs.borrowerCurrentResidenceFI = true;
                        if (fiStatusMap[fiRecordId]) {
                            this.statusofFIsubtabs.borrowerCurrentResidenceFI = true;
                        }
                    } else if (applicantType === this.label.CoBorrower) {
                        this.viewFIsubtabs.coBorrowerCurrentResidenceFI = true;
                        if (fiStatusMap[fiRecordId]) {
                            this.statusofFIsubtabs.coBorrowerCurrentResidenceFI = true;
                        }
                    }
                } else if (caseType === this.label.Permanent_Residence_FI) {
                    this.permanentResidenceFIMap.push({ value: fiRecordId, key: applicantType });
                    this.showFIsubtabs.permanentResidenceFI = true;
                    if (applicantType === this.label.Borrower) {
                        this.viewFIsubtabs.borrowerPermanentResidenceFI = true;
                        if (fiStatusMap[fiRecordId]) {
                            this.statusofFIsubtabs.borrowerPermanentResidenceFI = true;
                        }
                    } else if (applicantType === this.label.CoBorrower) {
                        this.viewFIsubtabs.coBorrowerPermanentResidenceFI = true;
                        if (fiStatusMap[fiRecordId]) {
                            this.statusofFIsubtabs.coBorrowerPermanentResidenceFI = true;
                        }
                    }
                } else if (caseType === this.label.Office_FI) {
                    this.officeFIMap.push({ value: fiRecordId, key: applicantType });
                    this.showFIsubtabs.officeFI = true;
                    if (applicantType === this.label.Borrower) {
                        this.viewFIsubtabs.borrowerOfficeFI = true;
                        if (fiStatusMap[fiRecordId]) {
                            this.statusofFIsubtabs.borrowerOfficeFI = true;
                        }
                    } else if (applicantType === this.label.CoBorrower) {
                        this.viewFIsubtabs.coBorrowerOfficeFI = true;
                        if (fiStatusMap[fiRecordId]) {
                            this.statusofFIsubtabs.coBorrowerOfficeFI = true;
                        }
                    }
                }
                // D2C_CHANGE - Raman, Skip office FI for D2C PA or STP cases
                if(this.oppty.LeadSource == 'D2C' && (this.oppty.Sanction_Status__c == 'STP' || this.oppty.Is_Pre_Approved__c == true)){
                    this.showFIsubtabs.officeFI = false;
                    this.viewFIsubtabs.borrowerOfficeFI = false;
                    this.statusofFIsubtabs.borrowerOfficeFI = false;
                    this.viewFIsubtabs.coBorrowerOfficeFI = false;
                    this.statusofFIsubtabs.coBorrowerOfficeFI = false;
                }
                // EO D2C_CHANGE
            }
        }
        // set active FI Sub Tab
        this.updateActiveFITabs();
        console.log('currentResidenceFIMap ==', JSON.stringify(this.currentResidenceFIMap));
        console.log('permanentResidenceFIMap ==', JSON.stringify(this.permanentResidenceFIMap));
        console.log('officeFIMap ==', JSON.stringify(this.officeFIMap));
    }

    handleActiveFISubTab(event) {
        this.activeFISubTab = event.target.value;
        console.log('officefiMAP==>', this.officeFIMap);
        let data = this.officeFIMap;
        console.log('data=>', data);
        console.log('data.length', data.length);

        for (let key in data) {
            let applicantKey = data[key].key;
            console.log(data.length);
            if (applicantKey == 'Co-borrower' && data.length == 1 && this.activeFISubTab === this.label.Office_FI) {
                console.log('inside if this.activeFISubTab == ', this.activeFISubTab);
                this.activeTabValue = this.label.CoBorrower;

            }
        }
        if(this.activeFISubTab == 'Current Residence FI' && this.currentResidenceFIMap && this.currentResidenceFIMap.length > 0){
            this.activeTabValue = this.currentResidenceFIMap[0].value;
        }else if(this.activeFISubTab == 'Permanent Residence FI' && this.permanentResidenceFIMap && this.permanentResidenceFIMap.length > 0){
            this.activeTabValue = this.permanentResidenceFIMap[0].value;
        } else if(this.activeFISubTab == 'Office FI' && this.officeFIMap && this.officeFIMap.length > 0){
            this.activeTabValue = this.officeFIMap[0].value;
        }
    }

    submitFI(event) {
        console.log('fi this.activeFISubTab == ', this.activeFISubTab);
        console.log('fi this.activeTabValue == ', this.activeTabValue);
        
        // Update status of FI completion
        if (this.activeFISubTab === this.label.Current_Residence_FI && this.activeTabValue === this.label.Borrower) {
            this.statusofFIsubtabs.borrowerCurrentResidenceFI = true;
        } else if (this.activeFISubTab === this.label.Current_Residence_FI && this.activeTabValue === this.label.CoBorrower) {
            this.statusofFIsubtabs.coBorrowerCurrentResidenceFI = true;
        } else if (this.activeFISubTab === this.label.Permanent_Residence_FI && this.activeTabValue === this.label.Borrower) {
            this.statusofFIsubtabs.borrowerPermanentResidenceFI = true;
        } else if (this.activeFISubTab === this.label.Permanent_Residence_FI && this.activeTabValue === this.label.CoBorrower) {
            this.statusofFIsubtabs.coBorrowerPermanentResidenceFI = true;
        } else if (this.activeFISubTab === this.label.Office_FI && this.activeTabValue === this.label.Borrower) {
            console.log('Inside Office FI Borrower');
            this.statusofFIsubtabs.borrowerOfficeFI = true;
        } else if (this.activeFISubTab === this.label.Office_FI && this.activeTabValue === this.label.CoBorrower) {
            console.log('Inside Office FI Co Borrower');
            this.statusofFIsubtabs.coBorrowerOfficeFI = true;
        }
        // Check FI Tab completion status to navigate to next tab
        console.log('Record Id %%%%%%%'+this.recordId);       



        IsAllRequiredFISubmitted({'loanApplicationId': this.recordId})
        .then(result => {
         if(result){
            console.log('submitFI next tab', JSON.stringify(this.nextTab[this.label.Field_Investigation]));
            if(this.nextTab[this.label.Field_Investigation] == this.label.Valuation_IDV && this.vehicleDetailList.length == 0){
                this.updateSubStageField(this.label.Valuation_IDV);
            }else{
                this.updateSubStageField(this.label.Field_Investigation);
            }
         }else{
            console.log('submitFI Else block');
            // set active FI Sub Tab
            this.updateActiveFITabs();
         }
        })
        .catch(error => {
            console.log('error :::',error);
           return false;
        });
        /*if (this.checkFITabCompletion()) {
            console.log('submitFI next tab', JSON.stringify(this.nextTab[this.label.Field_Investigation]));
            this.updateSubStageField(this.label.Field_Investigation);
            // this.setNextTab(this.label.Field_Investigation);
        } else {
            console.log('submitFI Else block');
            // set active FI Sub Tab
            this.updateActiveFITabs();
        }*/
    }

    updateActiveFITabs() {
        // By checking each FI status completion update the next FI tab
        if (this.viewFIsubtabs.borrowerCurrentResidenceFI && !this.statusofFIsubtabs.borrowerCurrentResidenceFI) {
            this.activeFISubTab = this.label.Current_Residence_FI;
            this.activeTabValue = this.label.Borrower;
        } else if (this.viewFIsubtabs.coBorrowerCurrentResidenceFI && !this.statusofFIsubtabs.coBorrowerCurrentResidenceFI) {
            this.activeFISubTab = this.label.Current_Residence_FI;
            this.activeTabValue = this.label.CoBorrower;
        } else if (this.viewFIsubtabs.borrowerPermanentResidenceFI && !this.statusofFIsubtabs.borrowerPermanentResidenceFI) {
            this.activeFISubTab = this.label.Permanent_Residence_FI;
            this.activeTabValue = this.label.Borrower;
        } else if (this.viewFIsubtabs.coBorrowerPermanentResidenceFI && !this.statusofFIsubtabs.coBorrowerPermanentResidenceFI) {
            this.activeFISubTab = this.label.Permanent_Residence_FI;
            this.activeTabValue = this.label.CoBorrower;
        } else if (this.viewFIsubtabs.borrowerOfficeFI && !this.statusofFIsubtabs.borrowerOfficeFI) {
            this.activeFISubTab = this.label.Office_FI;
            this.activeTabValue = this.label.Borrower;
        } else if (this.viewFIsubtabs.coBorrowerOfficeFI && !this.statusofFIsubtabs.coBorrowerOfficeFI) {
            this.activeFISubTab = this.label.Office_FI;
            this.activeTabValue = this.label.CoBorrower;
        }
        console.log('fi this.activeFISubTab == ', this.activeFISubTab);
        console.log('fi this.activeTabValue', this.activeTabValue);
    }

    checkFITabCompletion() {
       
        // return false if any one of the FI status is incomplete
        /*if (this.viewFIsubtabs.borrowerCurrentResidenceFI) {
            if (!this.statusofFIsubtabs.borrowerCurrentResidenceFI) {
                return false;
            }
        }
        if (this.viewFIsubtabs.coBorrowerCurrentResidenceFI) {
            if (!this.statusofFIsubtabs.coBorrowerCurrentResidenceFI) {
                return false;
            }
        }
        if (this.viewFIsubtabs.borrowerOfficeFI) {
            if (!this.statusofFIsubtabs.borrowerOfficeFI) {
                return false;
            }
        }
        if (this.viewFIsubtabs.coBorrowerOfficeFI) {
            if (!this.statusofFIsubtabs.coBorrowerOfficeFI) {
                return false;
            }
        }
        return true;*/
    }

    updateSubStageField(textVal) {
        console.log('Inside updateSubStageField' + textVal);
        if (this.nextTab[textVal] !== undefined) {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[SUB_STAGE_FIELD.fieldApiName] = this.nextTab[textVal];
            const recordInput = {
                fields: fields
            };
            updateRecord(recordInput).then((record) => {
                console.log('dispatch' + record);
                //Calling setNextTab method to set the current tab name
                this.setNextTab(textVal);
            });
        }
    }
    // Field Investigation - End

    handlerisksummary(event) {
        const textVal = event.detail;
        // this.msg = textVal;
        console.log('dispatch event name : ', textVal);
        this.updateSubStageField(textVal);
    }


    // getvalueofcredit(){

    //     getcvalue({'loanApplicationId': this.recordid})
    // .then(data => { 
    //         this.getcreditvalue=data;
    //         console.log("@@@###%%%^^^&&&&**((((",this.getcreditvalue);
    // })
    // .catch( error => {
    // console.log('error... ',error);
    // });
    // }



    // submit(event) {
    //     console.log('submit 1 ', this.loanpage);
    //     //this.loanpage =false;
    //     this.tabs = undefined;
    //     console.log('Submit', JSON.parse(JSON.stringify(this.loanpage)));

    //     var tabname = event.target.value;
    //     console.log('tabname ' + tabname);
    //     //@wire(updateStage,{loanApplicationId: '$recordId'}) wiredoppstages({data, error}){
    //     // updateStage({loanApplicationId:'$recordId' })
    //     updateStage({loanApplicationId : this.recordId})
    //         .then(result => {
    //             this.tabs = result;
    //             console.log('Result ==> :', result.currentTab, this.tabs.currentTab);
    //             //this.error = undefined;
    //             this.loanpage = true;
    //             this.activeTab = result.currentTab;
    //         })
    //         .catch(error => {
    //             console.log('error : ', error);
    //             // this.error = error;
    //             this.tabs = undefined;
    //         })
    // }
    // renderedCallback() {
    //     console.log('active tab in rendedcallback', this.activeTab);
    //  }


}