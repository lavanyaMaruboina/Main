import { LightningElement, track, api } from 'lwc';
import gattingCheckEligibility from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility';
import addAdditionalDetails from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.addAdditionalDetails';
import checkRetryExhausted from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.checkRetryExhausted';
import getApplicantDetails from '@salesforce/apex/Ind_Demographic.getApplicantDetails';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import Guarantor from '@salesforce/label/c.Guarantor';
import Beneficiary from '@salesforce/label/c.Beneficiary';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Bureau_Pull_Match__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Match__c';
import Check_Eligibility_Match__c from '@salesforce/schema/Applicant__c.Check_Eligibility_Match__c';
import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import addCoborrower from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.addCoborrower';
import coborrowerCount from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.coborrowerCount';
import changeCoborrower from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.changeCoborrower';
import doInActiveCoBorrower from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.doInActiveCoBorrower';//CISP-113/CISP-2425
import getCurrentApplicantRecord from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.getCurrentApplicantRecord';
import Bureau_Pull_Message__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Message__c';
import Check_Eligibility_Message__c from '@salesforce/schema/Applicant__c.Check_Eligibility_Message__c';
import Check_Eligibility_Final_Reason__c from '@salesforce/schema/Applicant__c.Check_Eligibility_Final_Reason__c';//CISP-113/CISP-2425
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import PAN_CIN_Matched from '@salesforce/label/c.PAN_CIN_Matched';
import PAN_CIN_Match_Not_Found from '@salesforce/label/c.PAN_CIN_Match_Not_Found';
import Journey_stop from '@salesforce/label/c.Journey_stop';
import Journey_Stop_message from '@salesforce/label/c.Journey_Stop_message';
import Add_Coborrower from '@salesforce/label/c.Add_Coborrower';
import ContWithJourney from '@salesforce/label/c.ContWithJourney';
import CoborrowerNotReq from '@salesforce/label/c.CoborrowerNotReq';
import PAN_not_captured from '@salesforce/label/c.PAN_not_captured';
import SuccessMessage from '@salesforce/label/c.SuccessMessage';
import PAN_CIN_Check from '@salesforce/label/c.PAN_CIN_Check';
import Bureau_Pull_Check from '@salesforce/label/c.Bureau_Pull_Check';
import BureauPull_CoBorrower from '@salesforce/label/c.BureauPull_CoBorrower';
import Addition_Details_Capture from '@salesforce/label/c.Addition_Details_Capture';
import FailureMessage from '@salesforce/label/c.FailureMessage';
import ChangeCoborrower from '@salesforce/label/c.ChangeCoborrower';
import Journey_Continues from '@salesforce/label/c.Journey_Continues';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';

import Change_Co_borrower_1 from '@salesforce/label/c.Change_Co_borrower_1';
import Change_Co_borrower_2 from '@salesforce/label/c.Change_Co_borrower_2';
import Change_Co_borrower_3 from '@salesforce/label/c.Change_Co_borrower_3';
import Change_Co_borrower_1_2 from '@salesforce/label/c.Change_Co_borrower_1_2';
import Change_Co_borrower_1_3 from '@salesforce/label/c.Change_Co_borrower_1_3';
import Change_Co_borrower_2_3 from '@salesforce/label/c.Change_Co_borrower_2_3';
import Change_Co_borrower_1_2_3 from '@salesforce/label/c.Change_Co_borrower_1_2_3';
import Change_Co_borrower_1_Guarantor from '@salesforce/label/c.Change_Co_borrower_1_Guarantor';
import Change_Co_borrower_2_Guarantor from '@salesforce/label/c.Change_Co_borrower_2_Guarantor';
import Change_Co_borrower_3_Guarantor from '@salesforce/label/c.Change_Co_borrower_3_Guarantor';
import Change_Co_borrower_1_2_Guarantor from '@salesforce/label/c.Change_Co_borrower_1_2_Guarantor';
import Change_Co_borrower_2_3_Guarantor from '@salesforce/label/c.Change_Co_borrower_2_3_Guarantor';
import Change_Co_borrower_1_3_Guarantor from '@salesforce/label/c.Change_Co_borrower_1_3_Guarantor';
import Change_Co_borrower_1_2_3_Guarantor from '@salesforce/label/c.Change_Co_borrower_1_2_3_Guarantor';
import Change_Guarantor from '@salesforce/label/c.Change_Guarantor';
import Add_Co_borrower from '@salesforce/label/c.Add_Co_borrower';

import CheckBankAccountForBorrowerAndCoborrower from '@salesforce/label/c.CheckBankAccountForBorrowerAndCoborrower';
import { NavigationMixin } from 'lightning/navigation';
import doGatingScreeningCheckEligibilityCallout from '@salesforce/apexContinuation/IntegrationEngine.doGatingScreeningCheckEligibilityCallout';
import doTractorGatingScreeningCheckEligibilityCallout from '@salesforce/apexContinuation/IntegrationEngine.doTractorGatingScreeningCheckEligibilityCallout';
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';

import CIBIL_DETAILS_OBJECT from '@salesforce/schema/CIBIL_Details__c';
import CIBIL_PULL_DATE from '@salesforce/schema/CIBIL_Details__c.CIBIL_Pull_Date__c';
import CIBIL_MAKER_DATE from '@salesforce/schema/CIBIL_Details__c.Maker_Date__c';
import CIBIL_RECORD_DETAILS_ID from '@salesforce/schema/CIBIL_Details__c.Id';
import AMOUNT_OVERDUE_FIELD from '@salesforce/schema/CIBIL_Details__c.Amount_Overdue__c';
import CIBIL_APPLICANT_FIELD from '@salesforce/schema/CIBIL_Details__c.Applicant__c';
import CIBIL_DECISION_FIELD from '@salesforce/schema/CIBIL_Details__c.Cibil_Decision__c';
import CIBIL_REPORT_URI_FIELD from '@salesforce/schema/CIBIL_Details__c.CIBIL_Report_URl__c';
import CIC_NO_FIELD from '@salesforce/schema/CIBIL_Details__c.CIC_No__c';
import CRIF_SCORE_DESC_FIELD from '@salesforce/schema/CIBIL_Details__c.CRIF_Score_Desc__c';
import CURRENT_BALANCE_FIELD from '@salesforce/schema/CIBIL_Details__c.Current_Balance__c';
import ENTITY_FIELD from '@salesforce/schema/CIBIL_Details__c.Entity_Type__c';
import EQUIFAX_REPORT_URL_FIELD from '@salesforce/schema/CIBIL_Details__c.Equifax_Report_URl__c';
import HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD from '@salesforce/schema/CIBIL_Details__c.HighCredit_Or_SanctionedAmount__c';
import MONTH_OVERDUE_FIELD from '@salesforce/schema/CIBIL_Details__c.Month_Overdue__c';
import NOOFENLTSIXMON_FIELD from '@salesforce/schema/CIBIL_Details__c.NoOfEnLtSixMon__c';
import OLDEST_DATE_FIELD from '@salesforce/schema/CIBIL_Details__c.Oldest_Date__c';
import RECENT_DATE_FIELD from '@salesforce/schema/CIBIL_Details__c.Recent_Date__c';
import SCORE_FIELD from '@salesforce/schema/CIBIL_Details__c.Score__c';
import SUITFILEDORWILFULDEFAULT_FIELD from '@salesforce/schema/CIBIL_Details__c.SuitFiledOrWilfulDefault__c';
import TYPE_FIELD from '@salesforce/schema/CIBIL_Details__c.Type__c';
import WRITTENOFFAMOUNTTOTAL_FIELD from '@salesforce/schema/CIBIL_Details__c.WrittenoffAmountTotal__c';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication'; //CISP: 2845
import updateApplicationSeqNumber from '@salesforce/apex/UniqueLeadNumberHandler.updateApplicationSeqNumber';
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
//CISP-4609 START
import doGenerateTokenAPI from  '@salesforce/apex/IntegrationEngine.doGenerateTokenAPI';
import getCIBILDetails from '@salesforce/apex/IND_CibilEquifaxReportController.getCIBILDetails';
import getCheckeligibility from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.getCheckeligibility';
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
//CISP-4609 END
import storingCIBILDetails from '@salesforce/apex/ExternalCAMDataController.storingCIBILDetails';

import cRIFFAPICall from  '@salesforce/apex/IntegrationEngine.cRIFFAPICall'; //SFTRAC-308
import getCoborrowerRecords from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.getCoborrowerRecords';
import removeCoborrowerRecords from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.removeCoborrowerRecords';


const COLUMNS=[
    {label:'Name',fieldName:'Name'},{label:'Applicant Type',fieldName:'Applicant_Type__c'}
]
export default class IND_LWC_GattingAndScreening extends NavigationMixin(LightningElement) {
    isParentLeadMoreThan30or90Days = false
    @api recordId;
    @api applicantId;
    @api tabType;
    @api tabListCount;
    @api checkleadaccess;//coming from tabloanApplication
    //CISP-2457 /CISP-2506
    @track _clearretrycount;
    @api set clearretrycount(value){
        this._clearretrycount = value;
        console.log('this 78 : ',this._clearretrycount);
        if(this._clearretrycount){
            this.disableCheckEligibilityButton = false;
            this.checkEligibilityTick = false;
            this.checkEligibilityCross = false;
        }
    }
    get clearretrycount(){
        return this._clearretrycount;
    }
    //CISP-2457 /CISP-2506
    @track disablePanCinAlertButton = false;
    @track disabledBureauPullButton = false;
    @track disableCheckEligibilityButton = true;
    @track retrypopup = false;
    @track journeyStopPopUp = false;
    @track disableAddCoBorrower = false;
    @track disableAddGuarantor = false;
    @track delaytime;

    @track panCinFlag = false;
    @track bureauPullFlag = false;
    @track checkEligFlag = false;
    @track panCinMessage = '';
    @track bureauPullMessage = '';
    @track checkEligibilityMessage = '';
    @track panCinTick = false;
    @track bureauPullTick = false;
    @track checkEligibilityTick = false;
    @track panCinCross = false;
    @track bureauPullCross = false;
    @track checkEligibilityCross = false;
    @track isSpinnerMoving = false;
    @track tryCatchError = '';
    @track form60KycDocId;
    @track cibilDetailsRecordId;
    @track coborrowercount = 0;
    @track pancincount = 0;
    @track buruepullcount = 0;
    @track bankAccCheck = false;
    @track declaredAmount;
    @track isIncomeSourceAvailable;
    @track makerDateConversion;
    @track gattingAndScreeningForBorrower = false;
    @track journeyModal = false;

    // @track showSubmitButton;
    @api currentStage;
    @api isCoborrowerExist;

    @track coborrowerPopup = false;
    @track coborrowerPopupMessage = '';
    @track reasonPopupMessage = '';//CISP-113/CISP-2425
    //CISP-4609 START
    @track reportURL;
    @track reportheader;
    @track CibilReportURL;
    @track EquifaxReportURL;
    @track disableViewCibilBtnBrw = true;
    @track disableViewEquifaxBtnBrw = true;
    checkEligibilitystatus= false;
    @track dataCibil =[];
    isPV
    //CISP-4609 END

    isTractor
    isNonIndividual = false; //SFTRAC-308
    get isBorrowerTab(){
        return this.tabType == this.label.Borrower; 
    } //SFTRAC-308

    stageName;//CISP-2378
    lastStageName;//CISP-2378
    leadSource;// Ola integration changes
    applicantionNo;//CISP-7949
    productType;//CISP-7949
    entityType;//SFTRAC-724
    isPropriorBusinessEntityType = false;//SFTRAC-724 Flag to set true if Entity Type = Proprietorship or Business Entities Created by Statute
    isGetCRIFFButton = true; //SFTRAC-308
    isDisableViewCRIFFButton = false;  //SFTRAC-308
    isDisableGetCRIFFButton = false;  //SFTRAC-308
    @track  cRIFFURL;  //SFTRAC-308
    label = {
        Borrower, CoBorrower, Guarantor, Retry_Exhausted, Journey_stop, CoborrowerNotReq, ContWithJourney, Add_Coborrower, PAN_not_captured, SuccessMessage,
        PAN_CIN_Check, Bureau_Pull_Check, BureauPull_CoBorrower, FailureMessage, ChangeCoborrower, Journey_Stop_message, CheckBankAccountForBorrowerAndCoborrower, PAN_CIN_Matched, PAN_CIN_Match_Not_Found, Journey_Continues,Beneficiary
    };
    removeApplicant = false;
    disableRemoveApp = true;
    tableData;
    columns = COLUMNS;
    selectedData =[];
    journeyStage;
    disableAddBeneficiary=false;
    @track criffInitiated = false;
    get disableCheckEligibilityButtonVal() {
        return this.isNonIndividual ? true : this.disableCheckEligibilityButton;
    }

    async connectedCallback() {
        //Get Record Id Based on Query
        this.isLoading = true;
       await getCurrentApplicantRecord({ applicantId: this.applicantId })
            .then(response => {
                console.log('current record details', response);
                //CISP-2378 - START
                if(response.Opportunity__r){
                    this.stageName = response?.Opportunity__r?.StageName;
                    this.lastStageName = response?.Opportunity__r?.LastStageName__c;
                    this.leadSource = response?.Opportunity__r?.LeadSource;//Ola Integration changes
                    this.applicantionNo = response?.Opportunity__r?.Application_number__c;//CISP-7949
                    this.productType = response?.Opportunity__r?.Product_Type__c;//CISP-7949
                    this.entityType = response?.Opportunity__r?.Entity_Type__c;//SFTRAC-724
                }
                //CISP-2378 - END
                if (response.CIBIL_Details__r) {
                    console.log('current record details id', response.CIBIL_Details__r[0].Id);
                    this.cibilDetailsRecordId = response.CIBIL_Details__r[0].Id;
                    this.CibilReportURL =response.CIBIL_Details__r[0].CIBIL_Report_URl__c;
                    this.EquifaxReportURL = response.CIBIL_Details__r[0].Equifax_Report_URl__c;
                } else {
                    this.cibilDetailsRecordId = null;
                }

                console.log('Checking COnditions ');
                if (response.Bureau_Pull_Match__c === true || response.Bureau_Pull_Message__c === this.label.Retry_Exhausted) {
                    this.disabledBureauPullButton = true;
                }
                if (response.Bureau_Pull_Match__c === true) {
                    this.bureauPullTick = true;
                }
                if (response.PAN_CIN_Match__c === true || response.PAN_CIN_Message__c === this.label.Retry_Exhausted || response.Do_you_have_a_bank_account__c === false || response.PAN_CIN_Message__c === this.label.PAN_CIN_Match_Not_Found || response.PAN_CIN_Message__c === this.label.PAN_CIN_Matched) {

                    this.disablePanCinAlertButton = true;
                }
                if (response.PAN_CIN_Match__c === true) {
                    this.panCinTick = true;
                }
                if (response.Check_Eligibility_Match__c === true) {
                    this.checkEligibilityTick = true;
                }
                if (response.Check_Eligibility_Match__c === true || response.Check_Eligibility_Message__c === this.label.Retry_Exhausted || response.Check_Eligibility_Message__c === 'Customer does not meet eligibility criteria. This application is closed.') {
                    this.disableCheckEligibilityButton = true;
                    //this.disableAddCoBorrower = true; //CISP-2355
                }else if(this.stageName == 'Loan Initiation' && this.lastStageName == 'Loan Initiation'){
                    this.disableCheckEligibilityButton = false;
                }
                if (response.Check_Eligibility_Message__c === this.label.Journey_stop) {
                    this.handleJourneyStopPopUp();
                }
                if (response.Bureau_Pull_Message__c === this.label.Retry_Exhausted && !response.Bureau_Pull_Match__c) {
                    this.bureauPullCross = true;
                    console.log('khg ', response.Bureau_Pull_Match__c);
                }
                if (response.PAN_CIN_Message__c === this.label.Retry_Exhausted) {
                    this.panCinCross = true;
                }
                if (response.Check_Eligibility_Message__c === this.label.Retry_Exhausted || response.Check_Eligibility_Message__c === this.label.Journey_stop) {
                    this.checkEligibilityCross = true;
                }
                if(response.Opportunity__r.Product_Type__c == 'Two Wheeler' && this.leadSource!='D2C'){ //CISP-15662
                    this.getReportVisibility = false;
                }//CISP-15662
                if (response.Documents__r != null && response.Documents__r != undefined) {
                    if (response.Documents__r[0].Id !== null && response.Documents__r[0].Id !== undefined) {
                        console.log('Check Value 1: ' + this.disablePanCinAlertButton);
                        this.disablePanCinAlertButton = true;
                    }
                    this.form60KycDocId = response.Documents__r[0].Id;
                    console.log(' response.Documents__r[0].Id   ---> ' + response.Documents__r[0].Id + ', this.form60KycDocId-->  ' + this.form60KycDocId);

                }
                console.log('All COndition Check Done ');
                // this.panCinFlag = response.PAN_CIN_Match__c;
                this.checkEligFlag = response.Check_Eligibility_Match__c;
                console.log('this.checkEligFlag   ---> ' + this.checkEligFlag);
                this.bureauPullFlag = response.Bureau_Pull_Match__c;
                console.log('this.bureauPullFlag   ---> ' + this.bureauPullFlag);
                // this.panCinMessage = response.PAN_CIN_Message__c;
                this.bureauPullMessage = response.Bureau_Pull_Message__c;
                console.log('this.bureauPullMessage   ---> ' + this.bureauPullMessage);
                this.checkEligibilityMessage = response.Check_Eligibility_Message__c;
                console.log(' this.checkEligibilityMessage   ---> ' + this.checkEligibilityMessage);
                this.declaredAmount = response.Declared_income__c;
                console.log(' this.declaredAmount   ---> ' + this.declaredAmount);
                this.isIncomeSourceAvailable = response.Income_source_available__c;
                console.log(' Opportunity__r.Product_Type__c ' + response.Opportunity__r.Product_Type__c);
                this.isPV = response.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ? true: false;//CISP-4609
                this.isTractor = response.Opportunity__r.Product_Type__c == 'Tractor' ? true: false; //SFTRAC-34
                this.isNonIndividual = response.Opportunity__r.Customer_Type__c == 'Non-Individual' ? true: false; //SFTRAC-308
                this.criffInitiated = response.Opportunity__r.CRIFF_Report_Initiated__c;
                this.journeyStage = response.Journey_Stage__c;
                if (this.isNonIndividual && this.isTractor && this.stageName == 'Loan Initiation' && this.lastStageName == 'Loan Initiation' && this.isBorrowerTab) {//SFTRAC-310
                    if(this.applicantionNo){
                        this.enableNextBtnHandler();
                    }else{
                        this.genrateApplicationNo();
                    }
                }
                if(this.stageName == 'Loan Initiation' && this.journeyStage == 'Gatting And Screening'){
                    this.disableRemoveApp = false;
                }
                this.isParentLeadMoreThan30or90Days = response?.Opportunity__r?.isParentLeadMoreThan30or90Days__c;
                if(this.isTractor && response?.Opportunity__r?.isParentLeadMoreThan30or90Days__c){
                    this.disableAddGuarantor = true;this.disableAddBeneficiary = true; this.disableRemoveApp = true; this.disableAddCoBorrower = true;
                }//SFTRAC-2277
                this.bankAccCheck = response.Do_you_have_a_bank_account__c;
                if (response.Income_source_available__c && (response.Do_you_have_a_bank_account__c || response.Do_you_have_a_bank_account_with_IBL__c || response.Would_you_like_to_open_a_bank_account__c) && response.Opportunity__r.Product_Type__c == 'Passenger Vehicles') {
                    console.log('line 193   ---> ');
                    //this.disableAddCoBorrower = true; //CISP-2355
                }
                // this.disableAddCoBorrower = (this.declaredAmount != null && this.isIncomeSourceAvailable && this.bankAccCheck);
                console.log('this.disableAddCoBorrower   ---> ' + this.disableAddCoBorrower + ' , Declared Amount :' + this.declaredAmount + ', Income Source Availiable :' + this.isIncomeSourceAvailable + ', Account Check : ' + this.bankAccCheck);

                // CISP-120 -- START - (10-6-2022)
                if (response.Check_Eligibility_Message__c === this.label.Journey_Stop_message || response.Check_Eligibility_Message__c == this.label.Journey_stop) {
                    this.journeyStopPopUp = true;
                    this.checkEligibilityMessage = this.label.Journey_stop;
                    this.reasonPopupMessage = response.Check_Eligibility_Final_Reason__c;//CISP-113/CISP-2425
                }
                //CISP-120 --STOP - (10-6-2022)

                //CISP-1196 - CISP-2451 - Added condtion for failure
                if((response.Check_Eligibility_Message__c == Journey_Continues && response.Check_Eligibility_Match__c == true) || response.Check_Eligibility_Message__c === this.label.Retry_Exhausted ||  response.Check_Eligibility_Message__c == this.label.CoborrowerNotReq){//CISP-2375 //CISP-4802
                    //CISP-519-START
                    if(this.stageName === 'Loan Initiation' && this.lastStageName === 'Loan Initiation' && this.leadSource!='OLA' && this.leadSource!='Hero'){//CISH-28
                        this.enableNextBtnHandler();//CISP-2451
                    }
                    //CISP-519-END
                    if(this.isTractor){this.disableAddGuarantor=true;this.disableAddBeneficiary=true;this.disableRemoveApp=true;this.disableAddCoBorrower=true;}
                }
                //CISP-1196
                //SFTRAC-308
                if(this.isBorrowerTab && this.isNonIndividual){
                    if(this.entityType == 'Business Entities Created by Statute' || this.entityType == 'Proprietorship'){
                        this.isDisableGetCRIFFButton = true;
                        this.isPropriorBusinessEntityType = true;
                    }else{
                        this.isPropriorBusinessEntityType = false;
                        this.isGetCRIFFButton = this.criffInitiated == true ? false : true;
                        this.isDisableGetCRIFFButton = this.criffInitiated;                       
                        this.isDisableViewCRIFFButton = response.CRIFF_Report_URL__c == undefined ? true: false;
                        this.cRIFFURL = response.CRIFF_Report_URL__c != undefined ? response.CRIFF_Report_URL__c : '';
                    }
                }
                //SFTRAC-308

            }).catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
            //Ola integration changes
            await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
            .then(data => {
                let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}

                
                console.log(fieldList);
                if(fieldList.length>0){
                    this.disableAddCoBorrower = fieldList.includes('Add Co-borrower')? true :this.disableAddCoBorrower;
                    //this.disableCheckEligibilityButton = fieldList.includes('Check eligibility')? true :this.disableCheckEligibilityButton;
                    
                }
            }).catch(error => { 
                this.tryCatchError = error;
                this.errorInCatch();
            });
            //Ola Integration changes
            getCheckeligibility({LoanId: this.recordId, type: 'Borrower'})
            .then(response => {//CISP-4894
                if (this.bureauPullTick && this.disableCheckEligibilityButton && (response.Check_Eligibility_Match__c === true || response.Check_Eligibility_Message__c === this.label.Retry_Exhausted || response.Check_Eligibility_Message__c === 'Customer does not meet eligibility criteria. This application is closed.')) {
                    this.disableViewCibilBtnBrw=false;
                    if(!this.EquifaxReportURL && this.isTractor){
                        this.disableViewEquifaxBtnBrw=true;
                    }else{
                        this.disableViewEquifaxBtnBrw=false;
                    }
                }
                //CISP-4791 //CISP-4894
                else if (this.bureauPullTick && this.tabType === this.label.CoBorrower && (response.Check_Eligibility_Match__c === true || response.Check_Eligibility_Message__c === this.label.Retry_Exhausted || response.Check_Eligibility_Message__c === 'Customer does not meet eligibility criteria. This application is closed.')) {
                    this.checkEligibilitystatus=true;
                    this.disableViewCibilBtnBrw=false;
                    if(!this.EquifaxReportURL && this.isTractor){
                        this.disableViewEquifaxBtnBrw=true;
                    }else{
                        this.disableViewEquifaxBtnBrw=false;
                    }
                }
            }).catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
            
            this.getCibildata(this.cibilDetailsRecordId);
            //Ola integration changes
            await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
            .then(data => {
                let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}
                if(this.leadSource=='OLA' || this.leadSource=='Hero'){this.disableCheckEligibilityButton=false;}//OLA-144//CISH-28
                console.log(fieldList);
                if(fieldList.length>0){
                    this.disableAddCoBorrower = fieldList.includes('Add Co-borrower')? true :this.disableAddCoBorrower;
                    //this.disableCheckEligibilityButton = fieldList.includes('Check eligibility')? true :this.disableCheckEligibilityButton;
                    
                }
            }).catch(error => { 
                this.tryCatchError = error;
                this.errorInCatch();
            });
            //Ola Integration changes
        if (this.tabType === this.label.Borrower) {
            this.gattingAndScreeningForBorrower = true;
        } else if (this.tabType === this.label.CoBorrower) {
            this.gattingAndScreeningForBorrower = false;
        }
        this.callAccessLoanApplication();//CISP: 2845

        /*if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
            const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
            this.disableEverything();
        }*/
        // CISP-2576 - START
        let res = await coborrowerCount({ loanApplicationId: this.recordId });
        console.log('this.checkEligibilityMessage ', this.checkEligibilityMessage);
        console.log('res ', res);
        if((res == 3 && !this.isTractor) || this.checkEligibilityMessage == this.label.CoborrowerNotReq){ this.disableAddCoBorrower = true;}
        //CISP-2576 - END

       
    }

    //CISP:CISP: 2845

    getReportVisibility(){
        return this.isPV || this.isTractor;
    }

    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordId , stage: 'Loan Initiation'}).then(response => {
            console.log('accessLoanApplication Response:: ', response,' ',this.checkleadaccess);
            if(!response){ 
                this.disableEverything();
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






    //Popup : on click of 'Kindly Retry'
    handleRetry() {
        this.retrypopup = false;
    }
    //CISP-4884
    enableReportButton() {
        let reportBtn = this.template.querySelectorAll('.viewBtnClass');
        reportBtn.forEach(element =>{
            if(!this.EquifaxReportURL && this.isTractor && element.name == 'equifax'){
                element.disabled = true;
            }else{
                element.disabled = false
            }
        });
    }

    //Start: Create button for Bureau Pull - Naga Puppala
    renderedCallback() {
        if (this.currentStage === 'Credit Processing') {
            this.disableEverything();
            //CISP-4884
            if(this.disableCheckEligibilityButton && this.bureauPullTick){
            this.enableReportButton();
            }
            else if(this.bureauPullTick && this.tabType === this.label.CoBorrower && this.checkEligibilitystatus){
                this.enableReportButton();
            }
        }
        if(this.isTractor && this.isNonIndividual && this.tabType === this.label.Borrower){
            this.disabledBureauPullButton = true;
        }
        if(!this.EquifaxReportURL && this.isTractor){
            this.disableViewEquifaxBtnBrw=true;
        }
        //CISP-2378 - START
        if(this.stageName != 'Loan Initiation' && this.lastStageName != 'Loan Initiation' && this.stageName != undefined && this.lastStageName != undefined){//CISP-519
            this.disableAddCoBorrower = true;
            this.disableAddGuarantor = true;
            this.disableCheckEligibilityButton = true; 
            this.disableAddBeneficiary = true;
        }
        //CISP-2378 - END
        //CISP-4609 //CISP-4894
        // if(this.disableCheckEligibilityButton && this.bureauPullTick){ ##Changed logic as part of the SFTRAC-411
        if(this.bureauPullTick){
            this.disableViewCibilBtnBrw=false;
            if(!this.EquifaxReportURL && this.isTractor){
                this.disableViewEquifaxBtnBrw=true;
            }else{
                this.disableViewEquifaxBtnBrw=false;
            }
        }
    }
     
    handleBureauPullClick() {
        this.isSpinnerMoving = true;
        console.log('Check ID : ' + this.recordId, '', this.applicantId);
        if(this.isTractor){ //SFTRAC-918 calling CIBILAPI directly withot checking Retry count only for Tractor
            this.callCIBILAPI();
        }else{
        checkRetryExhausted({
            loanApplicationId: this.recordId, attemptFor: 'Bureau Pull Attempts', applicantId: this.applicantId, moduleName: 'Gatting & Screening'
        })
        .then(response => {
            if (response === this.label.FailureMessage) {
                this.bureauPullFlag = false;
                this.bureauPullMessage = response;
                const applicantsFields = {};
                applicantsFields[Bureau_Pull_Match__c.fieldApiName] = this.bureauPullFlag;
                applicantsFields[Bureau_Pull_Message__c.fieldApiName] = this.bureauPullMessage;
                this.updateRecordDetails(applicantsFields)
                this.isSpinnerMoving = false;
            } else if (response === this.label.Retry_Exhausted) {
                //If response is false and retry attempts are also exhausted,show toast message and disable the Bureau Pull button.
                this.bureauPullFlag = false;
                this.bureauPullMessage = response;
                this.disabledBureauPullButton = true;
                this.bureauPullCross = true;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: response,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                applicantsFields[Bureau_Pull_Match__c.fieldApiName] = this.bureauPullFlag;
                applicantsFields[Bureau_Pull_Message__c.fieldApiName] = this.bureauPullMessage;
                this.updateRecordDetails(applicantsFields)
                this.isSpinnerMoving = false;
            } else if (response === this.label.SuccessMessage) {
                console.log("Bureau Pull API Integration : Start", this.applicantId, '', this.recordId);
                    this.callCIBILAPI(); //SFTRAC-918 calling CIBIL API in another method.
                // Bureau Pull API Integration starts.
                    /*let cibilRequest = {
                    applicantId: this.applicantId,
                    loanApplicationId: this.recordId
                }

                doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
                    .then(res => {
                        console.log('res=>', res);

                        const result = JSON.parse(res);
                        console.log('Bureau Pull API Response:==>', (result.Data.Application_Cibil_Details));
                        console.log('Bureau Pull API Response:==>', result);

                        const cibilFields = {};
                        if (result.Data && result.Data.StatusCode == 200 && (result.Data.Application_Cibil_Details).length) {

                            cibilFields[AMOUNT_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Amount_Overdue;
                            cibilFields[CIBIL_DECISION_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CibilDecision;
                            cibilFields[CIC_NO_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CIC_No;
                            cibilFields[CRIF_SCORE_DESC_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CRIFScore_Desc;
                            cibilFields[CURRENT_BALANCE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Current_Balance;
                            cibilFields[ENTITY_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Entity_Type;
                            cibilFields[HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].HighCredit_Or_SanctionedAmount;
                            cibilFields[MONTH_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Month_Overdue;
                            cibilFields[NOOFENLTSIXMON_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].NoOfEnLtSixMon;
                            cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].OldestDate));
                            cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].RecentDate));
                            cibilFields[SCORE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Score;
                            cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
                            cibilFields[TYPE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Type;
                            cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;
                            if((result.Data.Cibil_LoanAccount_Details).length){
                                if((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')){
                                    let makerDate =  result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                                    this.makerDateConversion = makerDate.substring(0, makerDate.lastIndexOf(' '));
                               }
                            }
                            cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? this.makerDateConversion.split("-").reverse().join("-") : '';
                            if(this.isTractor){cibilFields[CIBIL_PULL_DATE.fieldApiName] = new Date().toISOString();}
                            if (result.Data.Equifax_Report_URl) {
                                cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] = result.Data.Equifax_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                            }
                            if (result.Data.Cibil_Report_URl) {
                                cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] = result.Data.Cibil_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                            }

                            if (this.cibilDetailsRecordId == undefined && result.Data.Application_Cibil_Details[0].CIC_No) {
                                cibilFields[CIBIL_APPLICANT_FIELD.fieldApiName] = this.applicantId;
                                this.createRecordDetails(CIBIL_DETAILS_OBJECT.objectApiName, cibilFields);
                            } else if (this.cibilDetailsRecordId) {
                                cibilFields[CIBIL_RECORD_DETAILS_ID.fieldApiName] = this.cibilDetailsRecordId;
                                this.updateRecordDetails(cibilFields);
                            }


                            const applicantsFields = {};
                            applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                            applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                            applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                            this.updateRecordDetails(applicantsFields);
                            console.log('end of cibil api');

                            //CISP-2506-START
                            if(result.Data.IsSuccess === 'True'){
                                const evt = new ShowToastEvent({
                                    title: 'success',
                                    message: result.Data.StatusDescription,
                                    variant: 'success',
                                });
                                this.dispatchEvent(evt);
                                this.bureauPullTick = true;
                                this.disabledBureauPullButton = true;
                                this.disableViewCibilBtnBrw=false;
                                if(!this.EquifaxReportURL && this.isTractor){
                                    this.disableViewEquifaxBtnBrw=true;
                                }else{
                                    this.disableViewEquifaxBtnBrw=false;
                                }
                            }else{
                                this.retrypopup = true;
                            }
                            //CISP-2506-END
                            storingCIBILDetails({ loanAppId: this.recordId, apiResponse: JSON.stringify(result.Data), applicantId: this.applicantId}).then({});
                        } else {
                            const evt = new ShowToastEvent({
                                title: 'Warning',
                                message: result.Data.StatusDescription,
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                            this.retrypopup = true;
                        }
                        this.isSpinnerMoving = false;
                    })
                    .catch(error => {
                        this.isSpinnerMoving = false;
                        console.log('Bureau Pull API Error is :==>', error);
                        this.bureauPullFlag = false;
                        this.bureauPullMessage = error.body.message;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        const applicantsFields = {};
                        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                        //Added below as part of Bug id 1424 by Sathyanarayana Somayajula
                        applicantsFields[Bureau_Pull_Match__c.fieldApiName] = this.bureauPullFlag;
                        applicantsFields[Bureau_Pull_Message__c.fieldApiName] = this.bureauPullMessage;
                        this.updateRecordDetails(applicantsFields);
                        console.log('end of cibil api');
                        this.retrypopup = true;
                        });*/
            }
        })
        .catch(error => {
            console.log('error in bureaPull:', error);
            const evt = new ShowToastEvent({
                title: 'Kindly Retry',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isSpinnerMoving = false;
        });
        }  
        //this.isSpinnerMoving = false;
        // }
    }
    //End: Create button for Bureau Pull - Naga Puppala

    //CALL CIBIL API class method //SFTRAC-918
    callCIBILAPI(){
        // Bureau Pull API Integration starts.
        let cibilRequest = {
            applicantId: this.applicantId,
            loanApplicationId: this.recordId
        }

        doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
            .then(res => {
                console.log('res=>', res);

                const result = JSON.parse(res);
                console.log('Bureau Pull API Response:==>', (result.Data.Application_Cibil_Details));
                console.log('Bureau Pull API Response:==>', result);

                const cibilFields = {};
                if (result.Data && result.Data.StatusCode == 200 && (result.Data.Application_Cibil_Details).length) {

                    cibilFields[AMOUNT_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Amount_Overdue;
                    cibilFields[CIBIL_DECISION_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CibilDecision;
                    cibilFields[CIC_NO_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CIC_No;
                    cibilFields[CRIF_SCORE_DESC_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CRIFScore_Desc;
                    cibilFields[CURRENT_BALANCE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Current_Balance;
                    cibilFields[ENTITY_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Entity_Type;
                    cibilFields[HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].HighCredit_Or_SanctionedAmount;
                    cibilFields[MONTH_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Month_Overdue;
                    cibilFields[NOOFENLTSIXMON_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].NoOfEnLtSixMon;
                    cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].OldestDate));
                    cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].RecentDate));
                    cibilFields[SCORE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Score;
                    cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
                    cibilFields[TYPE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Type;
                    cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;
                    if((result.Data.Cibil_LoanAccount_Details).length){
                        if((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')){
                            let makerDate =  result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                            this.makerDateConversion = makerDate.substring(0, makerDate.lastIndexOf(' '));
                       }
                    }
                    cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? this.makerDateConversion.split("-").reverse().join("-") : '';
                    if(this.isTractor){cibilFields[CIBIL_PULL_DATE.fieldApiName] = new Date().toISOString();}
                    if (result.Data.Equifax_Report_URl) {
                        cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] = result.Data.Equifax_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                        this.EquifaxReportURL = result.Data.Equifax_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                    }
                    if (result.Data.Cibil_Report_URl) {
                        cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] = result.Data.Cibil_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                        this.CibilReportURL = result.Data.Cibil_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;;
                    }

                    if (this.cibilDetailsRecordId == undefined && result.Data.Application_Cibil_Details[0].CIC_No) {
                        cibilFields[CIBIL_APPLICANT_FIELD.fieldApiName] = this.applicantId;
                        this.createRecordDetails(CIBIL_DETAILS_OBJECT.objectApiName, cibilFields);
                    } else if (this.cibilDetailsRecordId) {
                        cibilFields[CIBIL_RECORD_DETAILS_ID.fieldApiName] = this.cibilDetailsRecordId;
                        this.updateRecordDetails(cibilFields);
                    }


                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                    applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                    applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                    this.updateRecordDetails(applicantsFields);
                    console.log('end of cibil api');

                    //CISP-2506-START
                    if(result.Data.IsSuccess === 'True'){
                        const evt = new ShowToastEvent({
                            title: 'success',
                            message: result.Data.StatusDescription,
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                        this.bureauPullTick = true;
                        this.disabledBureauPullButton = true;
                        this.disableViewCibilBtnBrw=false;
                        this.disableViewEquifaxBtnBrw=false;
                    }else{
                        this.retrypopup = true;
                    }
                    //CISP-2506-END
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: result.Data.StatusDescription,
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.retrypopup = true;
                }
                this.isSpinnerMoving = false;
            })
            .catch(error => {
                this.isSpinnerMoving = false;
                console.log('Bureau Pull API Error is :==>', error);
                this.bureauPullFlag = false;
                this.bureauPullMessage = error.body.message;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                //Added below as part of Bug id 1424 by Sathyanarayana Somayajula
                applicantsFields[Bureau_Pull_Match__c.fieldApiName] = this.bureauPullFlag;
                applicantsFields[Bureau_Pull_Message__c.fieldApiName] = this.bureauPullMessage;
                this.updateRecordDetails(applicantsFields);
                console.log('end of cibil api');
                this.retrypopup = true;
            });
    }

    // Start : handle Check “Check Eligibility” Alert button.
    addAddtionalDetail = false;

    async handleCheckEligibility() {
        this.isSpinnerMoving = true;
        let isValid = true;
        let bankAccountPresent = false;
        await getApplicantDetails({opportunityId: this.recordId,}).then(result => {
            let totalActiveApplicant = 0;
            for (let index = 0; index < result.length; index++) {
                if(result[index].In_Active_Applicant__c === false) {
                    totalActiveApplicant++;
                }
            }
            if(this.disableAddCoBorrower==true && !this.isTractor){//Ola Integration changes

            } else if(totalActiveApplicant === 1 && this.tabListCount >= 2){
                const evt = new ShowToastEvent({
                            title: "Error",
                            message: 'Please fill the details of other tab first',
                            variant: 'error',
                            });
                this.dispatchEvent(evt);
                isValid = false;
                this.isSpinnerMoving = false;
            }
            else if (result.length === 1) {
                console.log(!result[0].Do_you_have_a_bank_account__c, ' ', !result[0].Do_you_have_a_bank_account_with_IBL__c, ' ', !result[0].Would_you_like_to_open_a_bank_account__c)
                if (result[0].Income_source_available__c === false  && result[0].Opportunity__r.Product_Type__c === 'Two Wheeler') {
                    console.log('result::', result);
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: 'Borrower is non-earning, Please add Co-borrower.',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    isValid = false;
                    this.isSpinnerMoving = false;
                }
                else if ((!result[0].Do_you_have_a_bank_account__c && !result[0].Do_you_have_a_bank_account_with_IBL__c && !result[0].Would_you_like_to_open_a_bank_account__c) && !this.isTractor) {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: 'Please add Co-borrower.',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    isValid = false;
                    this.isSpinnerMoving = false;
                }else if ((result[0].Do_you_have_a_bank_account__c || result[0].Do_you_have_a_bank_account_with_IBL__c) && this.isTractor && !this.isNonIndividual) {
                    bankAccountPresent = true
                }
            }
            else if (result && result.length > 1) {
                console.log('Barrower and Co barrower ', result.length);
                let isEarningBorrower = false;
                let isEarningCoBorrower = false;
                for (let index = 0; index < result.length; index++) {
                    if (result[index].Applicant_Type__c == 'Borrower' && result[index].Income_source_available__c === true) {
                        isEarningBorrower = true;
                    }
                    else if (result[index].Applicant_Type__c == 'Co-borrower' && result[index].Income_source_available__c === true) {
                        isEarningCoBorrower = true;
                    }
                }
                console.log('Barrower is earning ', isEarningBorrower);
                console.log('Co Barrower is earning ', isEarningCoBorrower);
                if (!isEarningBorrower && !isEarningCoBorrower) {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: 'Income Source is not available.',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    isValid = false;
                    this.isSpinnerMoving = false;
                }

                for (let index = 0; index < result.length; index++) {
                    if ((result[index].Do_you_have_a_bank_account__c || result[index].Do_you_have_a_bank_account_with_IBL__c) && this.isTractor && !this.isNonIndividual && (result[index].Applicant_Type__c === this.label.CoBorrower || result[index].Applicant_Type__c === this.label.Borrower)) {
                        bankAccountPresent = true;
                    }
                }
            }
        })
        .catch(error => {
            console.log('error came ', error);
            const evt = new ShowToastEvent({
                title: "Error",
                message: error.body,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isSpinnerMoving = false;
        });

        if(bankAccountPresent == false && this.isTractor && !this.isNonIndividual){
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Please Add/Change Co-borrower since bank account is not available either for Borrower & Co-borrower.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            isValid = false;
            this.isSpinnerMoving = false;
            return;
        }

        if (isValid) {
            if (this.currentStage === 'Credit Processing') {
                if (this.isCoborrowerExist) {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: "Please check the details of coborrower first",
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                } else {
                    console.log('Inside Check Eligibility stage');
                    const nextStage = new CustomEvent('submit', { bubbles: true, composed: true });
                    this.dispatchEvent(nextStage);
                }
            }
            if (this.disabledBureauPullButton === false) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: this.label.Bureau_Pull_Check,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.isSpinnerMoving = false; //CISP-2362
            } else {
                console.log('ID : ' + this.recordId, '', this.applicantId);
                this.isSpinnerMoving = false;
                if(this.leadSource=='OLA' || this.leadSource=='Hero'){//Hero CISH-6
                    //this.saveCheckEligibilityResponse('Lead Source is OLA API calls not needed', true);
                    this.enableNextBtnHandler();
                } else if(this.stageName == 'Loan Initiation' && this.lastStageName == 'Loan Initiation'){
                    await this.callGattingCheckEligibility();
                } else{
                    this.disableCheckEligibilityButton = true
                    return;
                }
            }
        }
    }

    async checkRetryExhaustedCount() {
        console.log('inside of count increase');
        await checkRetryExhausted({
            loanApplicationId: this.recordId, attemptFor: 'Check Eligibility Attempts', applicantId: this.applicantId, moduleName: 'Gatting & Screening'
         }).then(response => {
            console.log('Inside the checkExaust::', response)
            if (response === this.label.FailureMessage) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: response,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.isSpinnerMoving = false;
                console.log('response ---> ' + response);
            } else if (response === this.label.Retry_Exhausted) {
                this.isSpinnerMoving = false;
                this.checkEligFlag = false;
                coborrowerCount({ loanApplicationId: this.recordId }).then(result => {
                    if(result === 4){ // CISP-1196 - value changed to 4
                        this.reasonPopupMessage = this.label.Journey_Stop_message;//CISP-113/CISP-2425
                        this.journeyStopPopUp = true;
                        this.checkEligibilityTick = true;   
                        this.checkEligibilityMessage = this.label.Retry_Exhausted;//CISP-113/CISP-2425
                        this.disableEverything();
                        this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);

                    //if retry count less than 3
                    }else{
                        this.checkEligibilityMessage = this.label.Retry_Exhausted;//CISP-113/CISP-2425
                        this.disableCheckEligibilityButton = true;
                        this.reasonPopupMessage = this.label.Journey_Stop_message;//CISP-113/CISP-2425
                        const evt = new ShowToastEvent({
                        title: 'Error',
                        message: response,
                        variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
                        this.genrateApplicationNo();
                        this.enableNextBtnHandler();//CISP-2451
                    }
                })
                .catch(error => {console.log('event in additional ' + JSON.stringify(error));});
            } else if (response === this.label.SuccessMessage) {
                console.log('result of checkRetryExhausted =>:', response);
                if(this.productType == 'Tractor'){
                    this.callTractorCheckEligibilityAPI(this.recordId);
                }else{
                    let checkEligRequest = {
                        'applicantId': this.applicantId,
                        'loanApplicationId': this.recordId
                    };
                    console.log('before api call '+JSON.stringify(checkEligRequest));
                    this.callCheckEligibilityAPI(checkEligRequest);
                }
            }
            //this.isSpinnerMoving = false;
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('error in checkRetryExhaustedCount => ', error);
            const evt = new ShowToastEvent({
                title: "Error",
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            
        });
    }

    enableNextBtnHandler(){this.dispatchEvent(new CustomEvent('enablenextbtn'));
    if(this.applicantionNo == null && this.productType == 'Two Wheeler'){//CISP-7949
        this.genrateApplicationNo();
                   }//CISP-7949
}//CISP-2451

    async callGattingCheckEligibility() {
        await gattingCheckEligibility({ applicantId: this.applicantId, loanApplicationId: this.recordId })
        .then(result => {
            console.log('result of gattingCheckEligibility => ', result);
            if (result === 'Please check the Bureau Pull for Guarantor First') {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'Please check the Bureau Pull for Guarantor First',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.isSpinnerMoving = false;
                return;
            }else if (result === 'Please check the Bureau Pull for Beneficiary First') {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'Please check the Bureau Pull for Beneficiary First',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.isSpinnerMoving = false;
                return;
            } else if (result === this.label.BureauPull_CoBorrower) {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: this.label.BureauPull_CoBorrower,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.isSpinnerMoving = false;
                return;
            } else if (result === this.label.CheckBankAccountForBorrowerAndCoborrower && !this.isTractor) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: this.label.CheckBankAccountForBorrowerAndCoborrower,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.isSpinnerMoving = false;
                return;
            } else if ((result == 'Success')) { // //SFTRAC-918 Removed Or condition || (result === this.label.CheckBankAccountForBorrowerAndCoborrower && this.isTractor)
                this.isSpinnerMoving = true;
                if(this.isTractor){ //SFTRAC-918 directly call callTractorCheckEligibilityAPI without calling checkRetryExhaustedCount
                    this.callTractorCheckEligibilityAPI(this.recordId);
                }else{
                this.checkRetryExhaustedCount();
                }
                
            }else{
                this.isSpinnerMoving = false;
            }
        })
        .catch(error => {
            this.isSpinnerMoving = false;
            console.log('result of gattingCheckEligibility: error', error);
            this.tryCatchError = error;
            console.log('this.tryCatchError:', this.tryCatchError);
            this.errorInCatch();
        });
    }
    //CISP-4459 start
    journeyStopScenarioFound(){
        updateJourneyStop({ leadNo: this.recordId })
        .then(result => {
            console.log('Result', result);
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }//CISP-4459
    async callCheckEligibilityAPI(checkEligRequest) {
        console.log('api call is happening 799');
        await doGatingScreeningCheckEligibilityCallout({
            'checkEligibilityString': JSON.stringify(checkEligRequest)
        })
        .then(result => {
            const obj = JSON.parse(result);
            console.log('check elig api response => ' + JSON.stringify(obj));
            // this.isSpinnerMoving=false;
            //obj.gatingScreeningOutcome = this.label.Add_Coborrower;
            //console.log('modified response : ' + obj.gatingScreeningOutcome);
            coborrowerCount({ loanApplicationId: this.recordId }).then(count => {

                if (obj.gatingScreeningOutcome === this.label.Journey_stop) {
                    this.reasonPopupMessage = obj.finalDisplayReason;//CISP-113/CISP-2425
                    this.journeyStopPopUp = true;
                    this.disableCheckEligibilityButton = true;
                    this.checkEligibilityTick = true;
                    this.isSpinnerMoving = false;
                    this.checkEligFlag = false;
                    this.checkEligibilityMessage = this.label.Journey_stop;
                    this.journeyStopScenarioFound(); //CISP-4459
                    this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
                } else if (obj.gatingScreeningOutcome === this.label.Add_Coborrower) {
                    this.isSpinnerMoving = false;
                    //CISP-2375
                    this.checkEligibilityTick = true;
                    this.checkEligFlag = true;
                    this.checkEligibilityMessage = this.label.Add_Coborrower;
                    this.reasonPopupMessage = obj?.finalDisplayReason;//CISP-113/CISP-2425
                    this.genrateApplicationNo(); //CISP-2679
                    this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
                    //end
                    this.reasonPopupMessage = obj.finalDisplayReason;//CISP-113/CISP-2425
                    this.coborrowerPopup = true;
                    this.coborrowerPopupMessage = obj.gatingScreeningOutcome;
                } else if (obj.gatingScreeningOutcome === this.label.CoborrowerNotReq) {
                    console.log('inside Continue without coborrower : ' + obj.gatingScreeningOutcome);
                    this.isSpinnerMoving = false;
                    //start - CISP-1196
                    this.disableAddCoBorrower = false;
                    this.enableNextBtnHandler();//CISP-2451
                    if(count === 3)
                    {
                        this.disableAddCoBorrower = true;
                    }
                    //end - CISP-1196
                    //marking Co-Borrower as Inactive and deleting Tab from frontend
                    //CISP-2375
                    this.inactiveApplicantLogic(true,[1]);
                    this.checkEligFlag = true;
                    this.checkEligibilityMessage = this.label.CoborrowerNotReq;
                    this.reasonPopupMessage = obj?.finalDisplayReason;//CISP-113/CISP-2425
                    this.journeyModal = true;
                    this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
                    this.genrateApplicationNo();
                    this.disableCheckEligibilityButton = true;
                    this.checkEligibilityTick = true;
                } else if (obj.gatingScreeningOutcome === this.label.Journey_Continues) {
                    console.log('this.label.ContWithJourney =>', this.label.ContWithJourney);
                    this.isSpinnerMoving = false;
                    this.genrateApplicationNo();
                    //Start - CISP-1196
                    if(this.leadSource!='OLA' && this.leadSource !='Hero'){this.enableNextBtnHandler();}//CISP-2451//CISH-28
                    this.disableAddCoBorrower = false;
                    if(count === 3) {
                        this.disableAddCoBorrower = true;
                    }
                    // end - CISP-1196
                    this.disableCheckEligibilityButton = true;
                    this.checkEligibilityTick = true;
                    this.checkEligFlag = true;
                    this.reasonPopupMessage = obj?.finalDisplayReason;//CISP-113/CISP-2425
                    this.checkEligibilityMessage = this.label.Journey_Continues;
                    this.journeyModal = true;
                    this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
                } else if (obj.gatingScreeningOutcome === this.label.ChangeCoborrower) {
                    this.isSpinnerMoving = false;
                    // const evnt = new CustomEvent('deletecoborrower', { bubbles: true, composed: true });
                    // this.dispatchEvent(evnt);
                    // this.enableNextBtnHandler();//CISP-2451
                    this.genrateApplicationNo();
                    //start -> CISP-1196
                    this.checkEligibilityTick = true;
                    this.checkEligFlag = true;
                    this.reasonPopupMessage = obj?.finalDisplayReason;//CISP-113/CISP-2425
                    this.checkEligibilityMessage = this.label.ChangeCoborrower;
                    this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
                    //end -> CISP-1196
                    this.coborrowerPopupMessage = obj.gatingScreeningOutcome;
                    this.coborrowerPopup = true;
                    // doInActiveCoBorrower({ loanApplicationId: this.recordId });//CISP-113/CISP-2425
                    this.inactiveApplicantLogic(true,[1]);
                }else{
                    this.retrypopup = true; 
                }
                this.isSpinnerMoving = false;

            })
            .catch((error) => console.log('error in api',error))

            
        })
        .catch(error => {
            this.isSpinnerMoving = false;
            this.retrypopup = true;
            console.log('CheckEligibility API Error:==>', error);
            if(error.body.message != 'Unrecognized base64 character: "'){
                const evt = new ShowToastEvent({
                    title: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        });
        //If response is true this code will run and show toast message
    }

    async callTractorCheckEligibilityAPI(requestData){
        console.log('api call is happening 799');
        await doTractorGatingScreeningCheckEligibilityCallout({
            'loanApplicationId': requestData
        })
        .then(result => {
            const obj = JSON.parse(result);
            console.log('Check Eligibility API response | TRACTOR => ' + JSON.stringify(obj));
            if (obj.gatingScreeningOutcome && obj.gatingScreeningOutcome.includes('Journey Stop')) {
                this.reasonPopupMessage = obj.finalDisplayReason;
                this.journeyStopPopUp = true;
                this.disableCheckEligibilityButton = true;
                this.checkEligibilityTick = true;
                this.isSpinnerMoving = false;
                this.checkEligFlag = false;
                this.checkEligibilityMessage = this.label.Journey_stop;
                this.journeyStopScenarioFound();
                this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
            }else if(obj.gatingScreeningOutcome && obj.gatingScreeningOutcome.includes('Journey Continue')){
                console.log('this.label.ContWithJourney =>', this.label.ContWithJourney);
                this.isSpinnerMoving = false;
                this.genrateApplicationNo();
                if(this.leadSource!='OLA'){this.enableNextBtnHandler();}
                this.disableAddGuarantor=true;this.disableAddBeneficiary=true;this.disableRemoveApp=true;this.disableAddCoBorrower=true;
                this.disableCheckEligibilityButton = true;
                this.checkEligibilityTick = true;
                this.checkEligFlag = true;
                this.reasonPopupMessage = obj?.finalDisplayReason;
                this.checkEligibilityMessage = this.label.Journey_Continues;
                this.journeyModal = true;
                this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);   
            }else if(obj.gatingScreeningOutcome === Add_Co_borrower){
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.checkEligibilityTick = true;
                this.checkEligFlag = false;
                this.checkEligibilityMessage = Add_Co_borrower;
                this.reasonPopupMessage = obj?.finalDisplayReason;
                this.genrateApplicationNo();
                this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
                this.reasonPopupMessage = obj.finalDisplayReason;
                this.coborrowerPopup = true;
                this.coborrowerPopupMessage = obj.gatingScreeningOutcome;
            }else if (obj.gatingScreeningOutcome === Change_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddGuarantor = false;
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.inactiveApplicantLogic(true,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_2) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.inactiveApplicantLogic(true,[2]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_3) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.inactiveApplicantLogic(true,[3]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1_2) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.inactiveApplicantLogic(true,[1,2]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1_3) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.inactiveApplicantLogic(true,[1,3]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_2_3) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.inactiveApplicantLogic(true,[2,3]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1_2_3) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days)this.disableAddCoBorrower = false;
                this.inactiveApplicantLogic(true,[1,2,3]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days){this.disableAddCoBorrower = false;this.disableAddGuarantor = false}
                this.inactiveApplicantLogic(true,[1]);
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_2_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days){this.disableAddCoBorrower = false;this.disableAddGuarantor = false}
                this.inactiveApplicantLogic(true,[2]);
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_3_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days){this.disableAddCoBorrower = false;this.disableAddGuarantor = false}
                this.inactiveApplicantLogic(true,[3]);
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1_2_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days){this.disableAddCoBorrower = false;this.disableAddGuarantor = false}
                this.inactiveApplicantLogic(true,[1,2]);
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_2_3_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days){this.disableAddCoBorrower = false;this.disableAddGuarantor = false}
                this.inactiveApplicantLogic(true,[2,3]);
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1_3_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days){this.disableAddCoBorrower = false;this.disableAddGuarantor = false}
                this.inactiveApplicantLogic(true,[1,3]);
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else if (obj.gatingScreeningOutcome === Change_Co_borrower_1_2_3_Guarantor) {
                this.isSpinnerMoving = false;
                if(this.isParentLeadMoreThan30or90Days){this.disableAddCoBorrower = false;this.disableAddGuarantor = false}
                this.inactiveApplicantLogic(true,[1,2,3]);
                this.inactiveApplicantLogic(false,[1]);
                this.afterChangeApplicantLogic(obj);
            }else{
                this.retrypopup = true; 
            }
            this.isSpinnerMoving = false;
        })
        .catch(error => {
            this.isSpinnerMoving = false;
            this.retrypopup = true;
            console.log('CheckEligibility API Error:==>', error);
            if(error.body.message != 'Unrecognized base64 character: "'){
                const evt = new ShowToastEvent({
                    title: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        });
        
    }

    afterChangeApplicantLogic(obj){
        this.isSpinnerMoving = true;
        setTimeout(()=>{
            this.isSpinnerMoving = false;
            this.genrateApplicationNo();
            this.checkEligibilityTick = true;
            this.checkEligFlag = false;
            this.reasonPopupMessage = obj?.finalDisplayReason;
            this.checkEligibilityMessage = this.label.ChangeCoborrower;
            this.saveCheckEligibilityResponse(this.checkEligibilityMessage, this.checkEligFlag);
            this.coborrowerPopupMessage = obj.gatingScreeningOutcome;
            this.coborrowerPopup = true;
        }, 3000);
    }

    inactiveApplicantLogic(isCoborrowerType, applicantNo){
        this.isSpinnerMoving = true;
        doInActiveCoBorrower({ loanApplicationId: this.recordId, isCoborrower: isCoborrowerType, num: applicantNo }).then(result => {
            this.isSpinnerMoving = false;
            if (!(result == undefined || result.length == 0)) {
                result.forEach((appId)=>{
                    const evnt = new CustomEvent('deletecoborrower', { bubbles: true, composed: true, detail: {id: appId} });
                    this.dispatchEvent(evnt);
                });
                console.log('after deleting new applicant by event ');
            }
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('doInActiveCoBorrower error :: ',JSON.stringify(error));
        });
    }

    saveCheckEligibilityResponse(message, flag) {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        applicantsFields[Check_Eligibility_Match__c.fieldApiName] = flag;
        applicantsFields[Check_Eligibility_Message__c.fieldApiName] = message;
        applicantsFields[Check_Eligibility_Final_Reason__c.fieldApiName] = this.reasonPopupMessage;//CISP-113/CISP-2425
        this.updateRecordDetails(applicantsFields);
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
            console.log('error in navigateToHomePage => ', error);
        });
    }

    handleJourneyStopPopUp() {
        this.journeyStopPopUp = false;
        this.disablePanCinAlertButton = true;
        this.disabledBureauPullButton = true;
        this.disableCheckEligibilityButton = true;
        this.disableAddCoBorrower = true;
        this.reasonPopupMessage = '';//CISP-113/CISP-2425
        this.dispatchEvent(new CustomEvent('checkeligiblity'));
        //this.navigateToHomePage(); //CISP-4802
    }

    handleJourneyModal(event){
        this.journeyModal = false;
    }

    handleAddCoBorrower() {
        if (this.disabledBureauPullButton === false || (this.isDisableGetCRIFFButton === false && this.isNonIndividual)) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: this.label.Bureau_Pull_Check,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        } else {
            //dispatches event to CoBorrower Handler in LoanApplication component
            const evnt = new CustomEvent('coborroweraddition');
            this.dispatchEvent(evnt);
        }
    }
    handleRemoveCoBorrower(){ //SFTRAC-502
        getCoborrowerRecords({LoanId :this.recordId}).then(response=>{
            if(response){
                this.tableData = [];
                this.tableData = response;
               // this.disableRemoveApp = false;
            }
            this.removeApplicant = true;
        })
    }

    handleAddGuarantor(){
        console.log('Guarantor clicked!!');
        if (this.disabledBureauPullButton === false || (this.isDisableGetCRIFFButton === false && this.isNonIndividual)) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: this.label.Bureau_Pull_Check,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        } else {
            //dispatches event to Guarantor Handler in LoanApplication component
            const evnt = new CustomEvent('guarantoraddition');
            this.dispatchEvent(evnt);
        }
    }

    handleAddBeneficiary() {
        if (this.disabledBureauPullButton === false || (this.isDisableGetCRIFFButton === false && this.isNonIndividual)) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: this.label.Bureau_Pull_Check,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        } else {
            //dispatches event to Guarantor Handler in LoanApplication component
            const evnt = new CustomEvent('beneficiaryaddition');
            this.dispatchEvent(evnt);
        }
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
        .then(() => {
            console.log('record update success', JSON.stringify(fields));//keeping for reference
        })
        .catch(error => {  
            console.log('error in record update =>', error)
            this.tryCatchError=error;
            this.errorInCatch();
        });
    }

    errorInCatch() {
        if (this.tryCatchError.body) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: this.tryCatchError.body.message,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
    }

    async handleAddDetails() {
        console.log('Inside Additional Details' + this.recordId);
        await addAdditionalDetails({ loanApplicationId: this.recordId })
        .then(result => {
            console.log("Calling Additional Details Screen")
            if (result == this.recordId) {
                const screenEvent = new CustomEvent("addscreen", {
                    detail: Addition_Details_Capture
                });
                this.dispatchEvent(screenEvent);
                console.log('event is dispatch');
            }
        })
        .catch(error => {
            console.log('error in moving to additional details ' + JSON.stringify(error));
            this.tryCatchError=error;
            this.errorInCatch();
        });
    }

    async handleChangeOrAddCoborrower() {
        this.coborrowerPopup = false;
        this.reasonPopupMessage = '';//CISP-113/CISP-2425
        if (this.coborrowerPopupMessage === this.label.ChangeCoborrower) {
            await this.applicantAdditionFrontEndLogic(1,0);
        }else if (this.coborrowerPopupMessage === this.label.Add_Coborrower || this.coborrowerPopupMessage === Add_Co_borrower) {//Add coborrower
            //this.handleAddCoBorrower();
            await addCoborrower({ loanApplicationId: this.recordId })
            .then(result => {
                if (!(result == undefined || result == '')) {
                    const evn = new CustomEvent('addnewcoborrower', { bubbles: true, composed: true, detail: {id : result, type: CoBorrower } });
                    this.dispatchEvent(evn);
                    console.log('after adding new coborrower by event ',this.recordId);
                }
            })
            .catch(error => {
                console.log('event in additional ' + JSON.stringify(error));
            });
        }else if (this.coborrowerPopupMessage === Change_Co_borrower_1 || this.coborrowerPopupMessage === Change_Co_borrower_2 || this.coborrowerPopupMessage === Change_Co_borrower_3){
            await this.applicantAdditionFrontEndLogic(1,0);
        }else if (this.coborrowerPopupMessage === Change_Co_borrower_1_2 || this.coborrowerPopupMessage === Change_Co_borrower_1_3 || this.coborrowerPopupMessage === Change_Co_borrower_2_3){
            await this.applicantAdditionFrontEndLogic(2,0);
        }else if(this.coborrowerPopupMessage === Change_Co_borrower_1_2_3){
            await this.applicantAdditionFrontEndLogic(3,0);
        }else if(this.coborrowerPopupMessage === Change_Co_borrower_1_Guarantor || this.coborrowerPopupMessage === Change_Co_borrower_2_Guarantor || this.coborrowerPopupMessage === Change_Co_borrower_3_Guarantor){
            await this.applicantAdditionFrontEndLogic(1,1);
        }else if(this.coborrowerPopupMessage === Change_Co_borrower_1_2_Guarantor || this.coborrowerPopupMessage === Change_Co_borrower_2_3_Guarantor || this.coborrowerPopupMessage === Change_Co_borrower_1_3_Guarantor){
            await this.applicantAdditionFrontEndLogic(2,1);
        }else if(this.coborrowerPopupMessage === Change_Co_borrower_1_2_3_Guarantor){
            await this.applicantAdditionFrontEndLogic(3,1);
        }else if(this.coborrowerPopupMessage === Change_Guarantor){
            await this.applicantAdditionFrontEndLogic(0,1);
        }
    }

    applicantAdditionFrontEndLogic(noOfCoborrower,noOfGuarantor){
        console.log('$$$ applicantAdditionFrontEndLogic $$$ CALLED!!! CO: '+ noOfCoborrower + ' G:'+noOfGuarantor);
        changeCoborrower({ loanApplicationId: this.recordId, additionCoBorrower: noOfCoborrower, additionGuarantor: noOfGuarantor })
        .then(result => {
            if (!(result == undefined || result.length == 0)) {
                result.forEach((data)=>{
                    const evn = new CustomEvent('addnewcoborrower', { bubbles: true, composed: true, detail: {id : data.appId, type: data.appType} });
                    this.dispatchEvent(evn);
                });
                console.log('after adding new coborrower by event ');
            }
        })
        .catch(error => {
            console.log('event in additional ' + JSON.stringify(error));
        });
    }

    async createRecordDetails(objectApiName, fields) {
        await createRecord({ apiName: objectApiName, fields: fields })
        .then(obj => {
            console.log('record created successfully', JSON.stringify(fields));
            this.cibilDetailsRecordId = obj.id;
            //CISP-4609
            this.getCibildata(obj.id);   
        })
        .catch(error => {
            console.log('error in record creation ', error);
        });
    }
    //CISP-4609
    getCibildata(id){
        getCIBILDetails({cibilId : id})
                .then( res =>{ 
                    if(res){
                    if(res?.Applicant__r?.Applicant_Type__c == this.label.Borrower){
                            this.CibilReportURL =res.CIBIL_Report_URl__c;
                            this.EquifaxReportURL = res.Equifax_Report_URl__c;

                    }else if(res?.Applicant__r?.Applicant_Type__c == this.label.CoBorrower){ 
                            this.CibilReportURL =res.CIBIL_Report_URl__c
                            this.EquifaxReportURL = res.Equifax_Report_URl__c;
                    }else if(res?.Applicant__r?.Applicant_Type__c == this.label.Guarantor){
                        this.CibilReportURL =res.CIBIL_Report_URl__c;
                        this.EquifaxReportURL = res.Equifax_Report_URl__c;
                    }else if(res?.Applicant__r?.Applicant_Type__c == this.label.Beneficiary){
                        this.CibilReportURL =res.CIBIL_Report_URl__c;
                        this.EquifaxReportURL = res.Equifax_Report_URl__c;
                    }
                }
                })
    }
    async genrateApplicationNo() {
        await updateApplicationSeqNumber({ OpptyIdSet: this.recordId })
        .then(response => {
            console.log('genrateApplicationNo res');
            if (this.isNonIndividual && this.isTractor && this.stageName == 'Loan Initiation' && this.lastStageName == 'Loan Initiation') {
                this.enableNextBtnHandler();
            }
            //CISP-1196
            //this.handleAddDetails();
        })
        .catch(error => {
            console.log('genrateApplicationNo error');
        })
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    //CISP-4609 START
    viewCibilReport() {
        doGenerateTokenAPI()
        .then(resp=>{ 
            this.reportURL = this.CibilReportURL+'&SessionId='+resp;
            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: this.reportURL 
                }                
            })
        }).catch(error=>{
            console.log('error ->'+JSON.stringify(error));
        });
    }

    viewEquifaxReport() {
        doGenerateTokenAPI()
        .then(resp=>{ 
            this.reportURL = this.EquifaxReportURL+'&SessionId='+resp;
            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: this.reportURL 
                }                
            })
        })
        .catch(error => {	
            console.log('error ->'+JSON.stringify(error));
        });
    }
//CISP-4609 END

    //SFTRAC-308 STARTS
    getCRIFFReport(){
        this.isSpinnerMoving = true;
        console.log("cRIFFAPICall Called:: "+this.applicantId +' LOAN ID '+ this.recordId);
        cRIFFAPICall({loanAppId: this.recordId, applicantId: this.applicantId}).then(result =>{
        console.log("cRIFFAPICall Result:: "+result);
        
        this.isSpinnerMoving = false;
        if(result =='Success'){
            const evt = new ShowToastEvent({title: 'Success',message: 'CRIF report request initiation has been submitted.', variant: 'Success',});this.dispatchEvent(evt); 
            this.isGetCRIFFButton = false;
            this.isDisableViewCRIFFButton = true;
            this.isDisableGetCRIFFButton = true;
        }else if (result =='Error' || result == ''){
            const evt = new ShowToastEvent({title: 'Error',message: 'CRIF report request initiation not submitted, Check with Admin', variant: 'Error',});this.dispatchEvent(evt); 
            this.isGetCRIFFButton = true;
            this.isDisableViewCRIFFButton = false;
            this.isDisableGetCRIFFButton = false;
        }
        
        }).catch(error => {
            console.log(' cRIFFAPICall error:- ' + error.body.message);
            this.isSpinnerMoving = false;
            this.isGetCRIFFButton = true;
            this.isDisableViewCRIFFButton = false;
            this.isDisableGetCRIFFButton = false;
            const evt = new ShowToastEvent({title: 'Error',message: error.body.message, variant: 'error',});this.dispatchEvent(evt);       
        });
    }

    viewCRIFFReport(){
        doGenerateTokenAPI().then(resp=>{
            this.reportURL = this.cRIFFURL+'&SessionId='+resp;
            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: this.reportURL 
                }                
            })
        }).catch(error=>{
            console.log('error ->'+JSON.stringify(error));
        });
    }
    //SFTRAC-308 ENDS
      
handleRowSelection(event) { //SFTRAC-502

    switch (event.detail.config.action) {
        case 'selectAllRows':
            for (let i = 0; i < event.detail.selectedRows.length; i++) {
                this.selectedData.push(event.detail.selectedRows[i].Id);
            }
            break;
        case 'deselectAllRows':
            this.selectedData = [];
            break;
        case 'rowSelect':
            this.selectedData = [];
            for (let i = 0; i < event.detail.selectedRows.length; i++) {
                this.selectedData.push(event.detail.selectedRows[i].Id);
                console.log('selectedid---'+event.detail.selectedRows[i].Id);
                
            }
            break;
        case 'rowDeselect':
            this.selectedData = [];
            for (let i = 0; i < event.detail.selectedRows.length; i++) {
                this.selectedData.push(event.detail.selectedRows[i].Id);
                console.log('selecteddeid---'+event.detail.selectedRows[i].Id);
                
            }
            break;
        default:
            break;
    }
    console.log('selectedData---'+JSON.stringify(this.selectedData));
}
    removeApp(){ //SFTRAC-502
        if(this.selectedData.length != 0){
        this.isSpinnerMoving = true;
        removeCoborrowerRecords({appIds : this.selectedData}).then((result) => {
        const evt = new ShowToastEvent({title: 'Success',message: 'Applicant Records Removed Successfully', variant: 'Success'});
            this.dispatchEvent(evt); 
            this.removeApplicant = false;
            this.selectedData.forEach((appId)=>{
                const evnt = new CustomEvent('deletecoborrower', { bubbles: true, composed: true, detail: {id: appId} });
                this.dispatchEvent(evnt);
            });
            this.isSpinnerMoving = false;
            this.selectedData = [];
            }).catch(error=>{this.isSpinnerMoving = false})
        }else{
        const evt = new ShowToastEvent({title: 'Error',message: 'No records were selected', variant: 'error'});
        this.dispatchEvent(evt); 
        this.removeApplicant = false;
    }
    }
closeModal(){ //SFTRAC-502
    this.removeApplicant = false;
}
}