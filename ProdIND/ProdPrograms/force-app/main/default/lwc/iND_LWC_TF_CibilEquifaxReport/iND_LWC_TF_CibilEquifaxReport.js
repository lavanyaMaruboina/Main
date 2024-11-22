import { LightningElement, track, api, wire } from 'lwc';

import getTabList from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getTabList';
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';
import getCibilRecord_MTD from '@salesforce/apex/IND_CibilEquifaxReportController.getCibilRecordTF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import doGenerateTokenAPI from  '@salesforce/apex/IntegrationEngine.doGenerateTokenAPI';
import { NavigationMixin } from 'lightning/navigation';
//Import Applicant fields
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Bureau_Pull_Match__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Match__c';
import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import Bureau_Pull_Message__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Message__c';
import Scorecard_Decision__c from '@salesforce/schema/Applicant__c.Scorecard_Decision__c';
import ScoreCard_Description__c from '@salesforce/schema/Applicant__c.ScoreCard_Description__c';

//CIBIL object
import CIBIL_DETAILS_OBJECT from '@salesforce/schema/CIBIL_Details__c';
import L2flag from '@salesforce/schema/CIBIL_Details__c.L2flag__c';
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
import CIBIL_RECORD_DETAILS_ID from '@salesforce/schema/CIBIL_Details__c.Id';
import CIBIL_MAKER_DATE from '@salesforce/schema/CIBIL_Details__c.Maker_Date__c';
import CIBIL_PULL_DATE from '@salesforce/schema/CIBIL_Details__c.CIBIL_Pull_Date__c';
import getCIBILDetails from '@salesforce/apex/IND_CibilEquifaxReportController.getCIBILDetails';

//Final Term Object
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import PricingEngine_thresholdNetrr from '@salesforce/schema/Final_Term__c.PricingEngine_thresholdNetrr__c';
import LtvEngine_Ltv from '@salesforce/schema/Final_Term__c.LtvEngine_Ltv__c';


import { refreshApex } from '@salesforce/apex';

import CIBIL from '@salesforce/label/c.CIBIL';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import Equifax from '@salesforce/label/c.Equifax';
import CIBIL_Report from '@salesforce/label/c.CIBIL_Report';
import Equifax_Report from '@salesforce/label/c.Equifax_Report';
import FETCH_BUREAU_REPORT from '@salesforce/label/c.Fetching_Message';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';

//import custom labels
import Kindly_Retry from '@salesforce/label/c.Kindly_Retry';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import combinedBRECallout from '@salesforce/apex/IntegrationEngine.combinedBRE'; //SFTRAC-121
import Fi_Score_Band from '@salesforce/schema/Final_Term__c.Fi_Score_Band__c'; //SFTRAC-121
import Fi_Score from '@salesforce/schema/Final_Term__c.Fi_Score__c';
import Installment_To_Income_Ratio from '@salesforce/schema/Final_Term__c.Installment_To_Income_Ratio__c'; //SFTRAC-121
import cRIFFAPICall from  '@salesforce/apex/IntegrationEngine.cRIFFAPICall'; //SFTRAC-308

import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine'; //SFTRAC-126
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c'; //SFTRAC-126
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c'; //SFTRAC-126
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c'; //SFTRAC-126
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c'; //SFTRAC-126
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c'; //SFTRAC-126
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c'; //SFTRAC-126
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c'; //SFTRAC-126
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c'; //SFTRAC-126
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c'; //SFTRAC-126
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c'; //SFTRAC-126
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c'; //SFTRAC-126
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-126
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-126
import getCicNo from '@salesforce/apex/IntegrationUtilities.getCicNo';

export default class IND_LWC_TF_CibilEquifaxReport extends NavigationMixin(LightningElement) {
    
    label = {
        CIBIL,
        Borrower,
        CoBorrower,
        Equifax,
        CIBIL_Report,
        Equifax_Report
    }

    activeSections = [this.label.CIBIL, this.label.Equifax];

    @track tabList = [];
    @track disableBorSubmit = true;
    @track disableCoBorSubmit = true; 
    @api recordid;
    @api tabIndex;
    @track disableRetriggerApi=true;
    @track disableCoBrwRetriggerApi=true;
    @track applicantType;
    //Borrower
    @track disableViewCibilBtnBrw = true;
    @track disableViewEquifaxBtnBrw = true;
    @track disableTgrCibilBtnBrw = false;
    @track borrowerCICNo;
    @track borrowerMakerdate;
    @track borrowerscore;
    @track borrowerCibilReportURL;
    @track borrowerEquifaxReportURL;
    @track borrowerAppId;
    @track cibilDetailsborrRecordId;
    @track isScoreCardEngTgr;
    @track borrowerName;
    @track loanCustomerType;
    @track isNonIndividualBorrower = false;
    //coborrower;
    @track isCoborrowerTab = false;
    @track disableViewCibilBtnCoBrw = true;
    @track disableViewEquifaxBtnCoBrw = true;
    @track disableTgrCibilBtnCoBrw = false;
    @track coborrowerCICNo;
    @track coborrowerMakerdate;
    @track coborrowersscore;
    @track coborrowerCibilReportURL;
    @track coborrowerEquifaxReportURL;
    @track coborrowerAppId;
    @track cibilDetailsCoborrRecordId;
    @track isCoBorrowerScoreCardEngTgr;
    @track coBorrowerName;

    @track isPricingEngineTgr = false;
    @track isLTVengineTgr = false;
    @track isScoreCardTgr = false; //SFTRAC-121
    @track isViabilityTgr = false; //SFTRAC-121
    @track disableField =true;

    @track reportURL;
    @track reportheader;
    @track showReport = false;

    @track isMadecallout = false;
    @api activeTab = '';
    @api activeTabId = '';
    @track cibilDetailsRecordId;

    @track applicantId;
    @track finalTermId;

    @track fetchedData ;

    @track isSpinnerMoving = false;
    @track dataCibil =[];
    @track vehicleIds =[];
    @track leadSource;//Ola Integration changes

    @track ltv;
    @track thresholdNetIRR;
    @track scoreCard;
    @track viability;


    @api checkleadaccess;//coming from tabloanApplication

    async connectedCallback(){
        console.log('RECORD ID >> TF_CIBIL : ',this.recordid);
        console.log('ACTIVE Tab >> TF_CIBIL : ',this.activeTab);
        console.log('ACTIVE Tab Id >> TF_CIBIL : ',this.activeTabId);
        console.log('checkleadaccess ',this.checkleadaccess);
        await this.fetchCibilDetails();
        if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
            const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
            this.disableEverything();
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
        await fetchLoanDetails({ opportunityId: this.recordid }).then(result => {
            if(result.loanApplicationDetails){
                this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
            }
            // if(this.leadSource=='OLA'){
            //     this.disableBorSubmit=false;
            // }
        });//Ola Integration changes
    }

    get olaIntegrationDisableBorSubmit(){
        if(this.activeTab == this.label.Borrower && this.leadSource=='OLA'){
            return false;
        }
        return this.disableBorSubmit;
    }

    @api isRevokedLoanApplication;//CISP-2735
    renderedCallback(){
        if(this.isRevokedLoanApplication){
            this.disableEverything();
        }
    }
    //CISP-2735-END
    @track criffInitiated = false;
   //Fetching data from backend
   async fetchCibilDetails(){
    await getCibilRecord_MTD({ loanApplicationId: this.recordid, applicantId : this.activeTabId })
    .then(result=> {
        this.dataCibil = result;
        let data = result;

        if (data) {
            console.log('data from wired method TF CIBIL==> ', JSON.stringify(data));
            this.fetchedData = data;
            this.dataCibil =this.fetchedData;
            this.borrowerName = data.borrowerName;
            this.populateCibilData(this.activeTabId);
            this.vehicleIds = data.vehicleDetailID;
            console.log('++++this.vehicleIds '+this.vehicleIds);
            console.log('++++this.Final Term '+JSON.stringify(data.finalTermVDIdList));
            
            this.finalTermId = data.finalTermsId;
            // this.isBorrowerScoreCardEngTgr = data.isBorrowerScoreCardEngTgr;
            // this.isCoBorrowerScoreCardEngTgr = data.isCoBorrowerScoreCardEngTgr;
            this.isPricingEngineTgr = data.isPricingEngineTriggered;
            this.isLTVengineTgr = data.isLtvengineTriggered;
            this.isScoreCardTgr = data.isScoreCardAPITriggered;   //SFTRAC-121
            this.isViabilityTgr = data.isViabilityAPITriggered;   //SFTRAC-121
            this.loanCustomerType = data.loanApplicationCustomerType;
            this.isNonIndividualBorrower = this.loanCustomerType == 'Non-Individual' && this.activeTab == this.label.Borrower ? true : false;
            this.criffInitiated = data.criffReportInitiated;
            this.cRIFFURL = data.criffReportURL;
            if(this.isNonIndividualBorrower == true){
                this.disableViewCibilBtnBrw = this.isNonIndividualBorrower == true && this.cRIFFURL ? false : true;
                this.disableTgrCibilBtnBrw = this.criffInitiated && this.isNonIndividualBorrower == true ? true : false;
            }
            if(data.loanApplicationSubStage != this.label.CIBIL){ 
                this.disableBorSubmit = true;
            }else {
                if( this.disableTgrCibilBtnBrw){                    
                    this.disableBorSubmit = false;
                }
            }
        }
        }).catch(error=>{
            console.log('error in wired method ', error);
        });
    }

    populateCibilData(appId){
        console.log('populateCibilData >> : '+JSON.stringify(this.fetchedData));
        console.log('populateCibilData >> : '+JSON.stringify(this.fetchedData.applicant));
        let applicantData = this.fetchedData.applicant.filter(ele => ele.id === appId);
        let appCibilData = applicantData[0]?.cibil;
        console.log('populateCibilData AFTER FILTER>> : '+JSON.stringify(applicantData));
        console.log('populateCibilData AFTER FILTER>> : '+JSON.stringify(appCibilData));
        if(!(appCibilData == undefined || appCibilData == null)){
            this.disableViewCibilBtnBrw = !appCibilData.CIBIL_Report_URl__c && !isNonIndividualBorrower ? true : false;
            this.disableViewEquifaxBtnBrw = !appCibilData.Equifax_Report_URl__c ? true : false;
            this.disableTgrCibilBtnBrw = appCibilData.CIBIL_Report_URl__c ? true : false;
            this.borrowerCICNo = appCibilData.CIC_No__c;
            this.borrowerMakerdate = appCibilData.Maker_Date__c;
            this.borrowerscore = appCibilData.Score__c;
            this.borrowerAppId = appCibilData.Applicant__c;
            this.cibilDetailsborrRecordId = appCibilData.Id;
            this.borrowerCibilReportURL = appCibilData.CIBIL_Report_URl__c ? appCibilData.CIBIL_Report_URl__c : undefined;
            this.borrowerEquifaxReportURL = appCibilData.Equifax_Report_URl__c ? appCibilData.Equifax_Report_URl__c : undefined;
            if((appCibilData.Score__c == -1 && this.borrowerEquifaxReportURL == undefined) || applicantData[0].isCibilDaysExceeded == true){
                this.disableTgrCibilBtnBrw = false;
            }else{
                this.disableTgrCibilBtnBrw = true;
            }
            if(appCibilData.L2flag__c){
                this.disableTgrCibilBtnBrw = appCibilData.L2flag__c;
            }
            this.cibilDetailsRecordId = appCibilData.Id ? appCibilData.Id : undefined;
        }
    }

    //close popup
    closeModalPopup() {
        this.showReport = false;
    }
    @track  cRIFFURL;  //SFTRAC-308
    //Handle View CIBIL Report button functionality for Borrower
    viewCibilReport() {
        if(this.isNonIndividualBorrower){
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
        }else{
            doGenerateTokenAPI()
            .then(resp=>{ 
                this.reportURL = this.borrowerCibilReportURL+'&SessionId='+resp;
                this.reportheader = this.label.CIBIL_Report;

                this[NavigationMixin.Navigate]({ 
                    type:'standard__webPage',
                    attributes:{ 
                        url: this.reportURL 
                    }                
                })

            })
        }

       console.log('Report URL : '+this.reportURL );
    }

    //Handle View Equifax Report button functionality for Borrower
    viewEquifaxReport() {
        
        doGenerateTokenAPI()
        .then(resp=>{ 
           // console.log( ' Response : ', resp);   
            //console.log(' URL :', this.borrowerCibilReportURL+'&SessionId='+resp);             
            //this.showReport = true;
            this.reportURL = this.borrowerEquifaxReportURL+'&SessionId='+resp;
            this.reportheader = this.label.Equifax_Report;
            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: this.reportURL 
                }                
            })
        })
        .catch(error => {	
            console.log('error ->'+error);               
        });
    }
    
    //Handle Trigger CIBIL Bureau Pull button functionality
    async getCIBILReport(event) {
        //TF changes to add condition
        if(this.activeTab == 'Borrower' && this.loanCustomerType == 'Non-Individual'){
            this.isSpinnerMoving = true;
            cRIFFAPICall({loanAppId: this.recordid, applicantId: this.activeTabId}).then(result =>{

                console.log("cRIFFAPICall Result:: "+result);
                if(result =='Success'){
                    const evt = new ShowToastEvent({title: 'Success',message: 'CRIF report request initiation has been submitted.', variant: 'Success',});this.dispatchEvent(evt); 
                    this.isMadecallout = true;
                    this.disableTgrCibilBtnBrw = true;
                    this.disableBorSubmit = false;
                }else if (result =='Error' || result == ''){
                    const evt = new ShowToastEvent({title: 'Error',message: 'CRIF report request initiation not submitted, Check with Admin', variant: 'Error',});this.dispatchEvent(evt); 
                }
                this.isSpinnerMoving = false;
                
            }).catch(error => {
                console.log(' cRIFFAPICall error:- ' + error.body.message);
                this.isSpinnerMoving = false;
                const evt = new ShowToastEvent({title: 'Error',message: error.body.message, variant: 'error',});this.dispatchEvent(evt);
                this.isMadecallout = false;
                this.disableBorSubmit = true; 
                this.disableTgrCibilBtnBrw = false;      
            });

        }else{
            this.isSpinnerMoving = true;
            let applicantData = await this.fetchedData.applicant.filter(ele => ele.id === this.activeTabId);
            var applicantName = applicantData.length > 0 ? applicantData[0].name : '';
            this.applicantType=event.target.value;
                this.showToast(FETCH_BUREAU_REPORT+' '+ applicantName , 'info');
                this.applicantId = this.activeTabId;
                if (this.cibilDetailsborrRecordId) {
                    this.cibilDetailsRecordId = this.cibilDetailsborrRecordId;
                }else{//Start CISP-2937
                    this.cibilDetailsRecordId = undefined;
                }//End CISP-2937

            let cibilRequest = {
                applicantId: this.applicantId,
                loanApplicationId: this.recordid
            }
            if (!this.isMadecallout) {
                getCicNo({}).then(cicNo=>{
                    cibilRequest.cicNo = cicNo ? cicNo : '';
                    //Calling CIBIL API
                    doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
                    .then(res => {
                        console.log('res=>', res);                    
                        this.isMadecallout = true;
                        //const pareseResp = JSON.parse(res);
                        const result = JSON.parse(res);
                        //console.log('Bureau Pull API Response Data:==>', result );
                        const cibilFields = {};
                        if (result.Data && result.Data.StatusCode ==200) { //CISP-3118
                            
                            if(result.Data.Application_Cibil_Details && result.Data.Application_Cibil_Details.length > 0){
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
                            }
                            //cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? result.Data.Cibil_LoanAccount_Details[0].Maker_Date : '' ;
                            cibilFields[CIBIL_PULL_DATE.fieldApiName] = new Date().toISOString();
                            //stamping the maker date
                            if(result?.Data?.Cibil_LoanAccount_Details && result.Data.Cibil_LoanAccount_Details.length > 0 && 
                            result.Data.Cibil_LoanAccount_Details[0].Maker_Date){
                                let makerdt = result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                                makerdt = makerdt.substring(0, 10);
                                const splitDt = makerdt.split('-');   
                                let mDateVal = splitDt[2]+'-'+splitDt[1]+'-'+splitDt[0];  
                                console.log('Maker date : ',mDateVal);      
                                cibilFields[CIBIL_MAKER_DATE.fieldApiName] = mDateVal; 
                            }
                            
                        

                            if (result.Data.Equifax_Report_URl) {
                                cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] = result.Data.Equifax_Report_URl + '/?CIC_No=' + cicNo;
                                this.borrowerEquifaxReportURL = result.Data.Equifax_Report_URl + '/?CIC_No=' + cicNo;
                                this.disableViewEquifaxBtnBrw = false;
                            }
                            if (result.Data.Cibil_Report_URl) {
                                cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] = result.Data.Cibil_Report_URl + '/?CIC_No=' + cicNo;
                                this.borrowerCibilReportURL = result.Data.Cibil_Report_URl + '/?CIC_No=' + cicNo;
                                this.disableViewCibilBtnBrw = false;
                            }
                            
                            if (this.cibilDetailsRecordId == undefined && result.Data.Application_Cibil_Details && result.Data.Application_Cibil_Details.length > 0 &&  result.Data.Application_Cibil_Details[0].CIC_No) {
                                cibilFields[CIBIL_APPLICANT_FIELD.fieldApiName] = this.applicantId;
                                this.createRecordDetails(CIBIL_DETAILS_OBJECT.objectApiName, cibilFields);
                            } else if (this.cibilDetailsRecordId) {
                                cibilFields[CIBIL_RECORD_DETAILS_ID.fieldApiName] = this.cibilDetailsRecordId;
                                this.updateRecordDetails(cibilFields);
                            }

                            const applicantsFields = {};
                            applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                            applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true: false;
                            applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                            this.updateRecordDetails(applicantsFields);
                            this.isMadecallout = false;
                            this.disableTgrCibilBtnBrw = true;

                                this.disableBorSubmit = false;
                        }else{ 
                            // if(typeOfApplicant === this.label.Borrower ){ 
                                this.disableBorSubmit = true;
                            // }else{ 
                            //     this.disableCoBorSubmit =true;
                            // }
                            if(result.Data.StatusDescription){ 
                                this.showToast(result.Data.StatusDescription, 'warning');
                            }
                            
                        }
                        
                        this.isSpinnerMoving = false;
                    })
                    .catch(error => {
                        console.log('Bureau Pull API Error:==>', error);
                        this.isMadecallout = false;
                        this.showToast(Kindly_Retry, 'warning');
                        this.bureauPullFlag = false;
                        const bureauPullMessage = error.body.message;
                        this.isSpinnerMoving = false;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        const applicantsFields = {};
                        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                        applicantsFields[Bureau_Pull_Match__c.fieldApiName] = false;
                        applicantsFields[Bureau_Pull_Message__c.fieldApiName] = bureauPullMessage;
                        this.updateRecordDetails(applicantsFields);
                        // if(typeOfApplicant === this.label.Borrower ){ 
                            this.disableBorSubmit = true;
                        // }else{ 
                        //     this.disableCoBorSubmit =true;
                        // }
                    });
                }).catch(error=>{
                    this.isMadecallout = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                })
            }

        }
        
    }

    showToast(info, vari) {
        const event = new ShowToastEvent({
            title: 'Message',
            message: info,
            variant: vari,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }

    //Handled Submit button functionality for Borrower
    handleSubmit() {
        if(this.loanCustomerType != 'Non-Individual'){
            if(!this.isScoreCardTgr || !this.isViabilityTgr || !this.isLTVengineTgr || !this.isPricingEngineTgr){
                let valid = this.handleValidation();
                if(!valid){
                    this.disableRetriggerApi=false;
                    return;
                }
            }
            const fields = {};
            fields[L2flag.fieldApiName] = true;
            fields[CIBIL_RECORD_DETAILS_ID.fieldApiName] = this.cibilDetailsRecordId;
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                this.dispatchEvent(new CustomEvent('cibilsubmittfevent', { detail: {tabIndex:this.tabIndex} }));
                this.disableBorSubmit =true;
            }).catch(error=>{
                this.showToastMessage('Something went wrong!','','error');
            })
        }else{
            if(this.activeTab !== 'Borrower'){
                const fields = {};
                fields[L2flag.fieldApiName] = true;
                fields[CIBIL_RECORD_DETAILS_ID.fieldApiName] = this.cibilDetailsRecordId;
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.dispatchEvent(new CustomEvent('cibilsubmittfevent', { detail: {tabIndex:this.tabIndex} }));
                    this.disableBorSubmit =true;
                }).catch(error=>{
                    this.showToastMessage('Something went wrong!','','error');
                })
            }else if(this.cRIFFURL){
                this.dispatchEvent(new CustomEvent('cibilsubmittfevent', { detail: {tabIndex:this.tabIndex} }));
                this.disableBorSubmit =true;
            }else{
                this.showToastMessage('CRIF Report is not generated yet!','','info');
            }
        }
    }

    handleValidation(){
        if(!this.isScoreCardTgr) {
            this.showToastMessage('Score Card response not present!','','error');
            return false;
        }else if(!this.isLTVengineTgr){
            this.showToastMessage('LTV Engine response not present!','','error');
            return false;
        }else if(!this.isPricingEngineTgr){
            this.showToastMessage('Price Engine response not present!','','error');
            return false;
        }else if(!this.isViabilityTgr){
            this.showToastMessage('Viability information not present!','','warning');
        }
        return true;
    }

   //Borrower and Co-Borrower active tab
    async handleMainActiveTab(event) {
        this.activeTab = event.target.label;
        this.activeTabId = event.target.value;
        await this.populateCibilData(this.activeTabId);
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
    // Creating new records
    createRecordDetails(objectApiName, fields) {
         createRecord({ apiName: objectApiName, fields: fields })
            .then(obj => {                             
                this.cibilDetailsRecordId = obj.id;    
                getCIBILDetails({cibilId : obj.id})
                .then( res =>{ 
                    //console.log('res ::', res);
                    // if(res.Applicant__r.Applicant_Type__c == this.label.Borrower){
                         this.borrowerCICNo = res.CIC_No__c;
                         this.borrowerscore = res.Score__c;
                         this.borrowerMakerdate = res.Maker_Date__c;
                         this.disableViewCibilBtnBrw = !res.CIBIL_Report_URl__c ? true: false;
                         this.disableViewEquifaxBtnBrw = !res.Equifax_Report_URl__c ?true:false;
                         this.disableTgrCibilBtnBrw =true;
                         if(!this.disableViewCibilBtnBrw){ 
                            this.borrowerCibilReportURL =res.CIBIL_Report_URl__c;
                         }
                         if(!this.disableViewEquifaxBtnBrw ){ 
                            this.borrowerEquifaxReportURL = res.Equifax_Report_URl__c;
                         }
                })
                refreshApex(this.dataCibil);
            })
            .catch(error => {
                console.log('error in record creation ', error);
            });
    }

    //Updating record details
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                this.isSpinnerMoving=false;
                console.log('record update success', JSON.stringify(fields));//keeping for reference
                refreshApex(this.dataCibil);
            })
            .catch(error => {
                this.isSpinnerMoving=false;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                console.log('error in record update =>', error)
            });
    }

    reTriggerApis(){
        console.log('reTriggerApis ');
        //calling Scorecard API
        // this.applicantId = this.activeTab === this.label.Borrower ?  this.borrowerAppId : this.coborrowerAppId;
        this.applicantId = this.activeTabId;
        let cibilRequest = {
            applicantId: this.applicantId,
            loanApplicationId: this.recordid
        }
        console.log('reTriggerApis  ',this.applicantId,' ',this.recordid);
       
        console.log('++++this.isLTVengineTgr '+this.isLTVengineTgr+' this.isPricingEngineTgr '+this.isPricingEngineTgr+' this.isScoreCardTgr '+this.isScoreCardTgr+' this.isViabilityTgr '+this.isViabilityTgr);
        //SFTRAC-121 Starts
        if(!this.isLTVengineTgr || !this.isPricingEngineTgr || !this.isScoreCardTgr || !this.isViabilityTgr){
            console.log('++++this.vehicleIds12 '+this.vehicleIds);
            if(this.vehicleIds){
                this.vehicleIds.forEach(item => {
                    console.log('++++this.item '+item);
                    if(this.loanCustomerType != 'Non-Individual'){
                        this.handleCombinedBRECalloutHelper(item);
                        this.handleTFOfferEngineCalloutHelper(item);
                    }else{
                        this.handleTFOfferEngineCalloutHelper(item);
                    }
                })
            }
        }//SFTRAC-121 END
        
        else{
            // if (this.activeTab === this.label.Borrower ) {
                this.disableRetriggerApi=false;
            // }else{
            //     this.disableCoBrwRetriggerApi=false;
            // }
        }

    }

    showToastMessage(title,message,variant){
        const evt = new ShowToastEvent({
            title:title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    
    disableEverything(){
        console.log('jhgajhfgbahdbfjhebcj');
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
       // this.disableViewCibilBtnBrw=true; 
       // this.disableViewEquifaxBtnBrw=true; 
        this.disableField=true;

    }

        //SFTRAC -121
        // Call this from places where PV TW is been called
    handleCombinedBRECalloutHelper(singleVehicleId){
        console.log('++++singleVehicleId '+singleVehicleId);
        console.log('handleCombinedBRECalloutHelperfinalTermVDIdList >> : '+JSON.stringify(this.fetchedData.finalTermVDIdList));

        this.isSpinnerMoving = true;
        combinedBRECallout({ loanAppId: this.recordid, vehicleId: singleVehicleId}).then(
            result => {
                let finalTermIdArray = this.fetchedData.finalTermVDIdList.filter(ele => ele.vehicleDetailId === singleVehicleId).map(ele => ele.fianlTermId);
                console.log('++++finalTermIdArray '+finalTermIdArray);
                this.isSpinnerMoving=false;
                const parsedResponse = JSON.parse(result);
                console.log('+++combinedBRECallout done 2'+result);
                console.log('++++Price LTV Score res- ',parsedResponse?.application?.assetDetails?.assetLoanDetails);
                console.log('++++viablity res - ',parsedResponse?.application?.applicantDetails);
                const combineBREResponse = parsedResponse?.application?.assetDetails?.assetLoanDetails;
                const viabilityResponse = parsedResponse?.application?.applicantDetails;
                const installRes = viabilityResponse !== undefined ? viabilityResponse[0]?.applicantDecision?.installmentToIncomeRatio : null;
                //const installRes = viabilityResponse !== undefined && viabilityResponse[0]?.applicantDecision?.installmentToIncomeRatio !== undefined ? viabilityResponse[0]?.applicantDecision?.installmentToIncomeRatio : null;

                const fIscore = combineBREResponse !== undefined ? combineBREResponse.fiScore : ''; 

                let scoreBand = '';

                if (fIscore >= 175) {
                    scoreBand = 'R1';
                } else if (fIscore >= 137 && fIscore < 175) {
                    scoreBand = 'R2';
                } else if (fIscore >= 117 && fIscore < 137) {
                    scoreBand = 'R3';
                } else if (fIscore >= 82 && fIscore < 117) {
                    scoreBand = 'R4';
                } else {
                    scoreBand = 'R5';
                }

                this.ltv = combineBREResponse !== undefined ?  combineBREResponse[0].ltv : null;
                this.thresholdNetIRR = combineBREResponse !== undefined ?  combineBREResponse[0].irr : null;
                this.scoreCard = scoreBand;
                this.viability = installRes;
                
                const FinalTermFields = {};
                //FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
                FinalTermFields[final_ID_FIELD.fieldApiName]= finalTermIdArray[0];
                FinalTermFields[LtvEngine_Ltv.fieldApiName]= combineBREResponse !== undefined ?  combineBREResponse[0].ltv : '';
                FinalTermFields[PricingEngine_thresholdNetrr.fieldApiName]= combineBREResponse !== undefined ?  combineBREResponse[0].irr : '';
                FinalTermFields[CRM_IRR.fieldApiName] = combineBREResponse !== undefined && combineBREResponse[0].irr != 'NaN' ?  combineBREResponse[0].irr : '';
                FinalTermFields[Fi_Score_Band.fieldApiName]= scoreBand; 
                FinalTermFields[Fi_Score.fieldApiName] = combineBREResponse && combineBREResponse.length > 0 && combineBREResponse[0].fiScore != 'NaN' ? combineBREResponse[0].fiScore + '' : '';
                FinalTermFields[Installment_To_Income_Ratio.fieldApiName]= installRes != null ? installRes : '';

                this.updateRecordDetails(FinalTermFields);
                
                /*ADD LOGIC For SCORECARD update as well
                this.scoreCardDescription = res.BRE_Decision_Desc;
                this.scorecardDecision = res.BRE_Decision;*/

                this.isLTVengineTgr = this.ltv != null ? true: false;
                this.isPricingEngineTgr = this.thresholdNetIRR != null ? true: false;
                this.isScoreCardTgr = this.scoreCard != null ? true: false;
                this.isViabilityTgr = this.viability != null ? true: false;
                this.showToastMessage('Combined BRE callout is Success','','success');
            })
            .catch(error => {
                this.disableRetriggerApi=false;
                this.showToastMessage('Combined BRE has failed','','error');
                this.isLTVengineTgr = false;
                this.isPricingEngineTgr = false;
                this.isScoreCardTgr = false;
                this.isViabilityTgr = false;
                console.log('error in combinedBRECallout data ', error);
                this.isSpinnerMoving = false;
                this.retryPopUp = true;
            });
    }

    handleTFOfferEngineCalloutHelper(singleVehicleId){
        try{
            tractorOfferEngineCallout({ loanAppId: this.recordid, vehicleId: singleVehicleId,screenName : 'CIBIL'}).then(
              result => {
                  const parsedResponse = JSON.parse(result);
                  const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;
                  const FinalTermFields = {};
                  FinalTermFields[final_ID_FIELD.fieldApiName]= finalTermIdArray[0];
                
                FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.minLoanAmt != 'NaN' ?  offerEngineResponse.minLoanAmt : '';
                FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.maxLoanAmt != 'NaN' ?  offerEngineResponse.maxLoanAmt : '';
                FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayLoanAmt != 'NaN' ?  offerEngineResponse.displayLoanAmt.toString() : '';
                FinalTermFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.minTenure != 'NaN' ?  offerEngineResponse.minTenure : '';
                FinalTermFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.maxTenure != 'NaN' ?  offerEngineResponse.maxTenure : '';
                FinalTermFields[Tenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayTenure != 'NaN' ?  offerEngineResponse.displayTenure.toString() : '';
                FinalTermFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayEMI != 'NaN' ?  offerEngineResponse.displayEMI : '';
                FinalTermFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayCrmIrr != 'NaN' ?  offerEngineResponse.displayCrmIrr.toString() : '';
                FinalTermFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.netIrr != 'NaN' ?  offerEngineResponse.netIrr : '';
                FinalTermFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.grossIrr != 'NaN' ?  offerEngineResponse.grossIrr : '';
                FinalTermFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.bankCrmIrr != 'NaN' ?  offerEngineResponse.bankCrmIrr.toString() : '';
                FinalTermFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.agreementAmount != 'NaN' ?  offerEngineResponse.agreementAmount : '';

                  this.updateRecordDetails(FinalTermFields);
                  this.showToastMessage('Success', 'Offer Engine API Completed', 'Success');
                  
              })
              .catch(error => {
                  console.log('Offer Engine Api error'+error);
                  this.showToastMessage('Offer Engine Api has failed','','error');
                  this.isSpinnerMoving=false;
                  this.retryPopUp = true;
              });
          }catch(error){
            this.disableRetriggerApi=false;
            this.isSpinnerMoving=false;
            this.retryPopUp = true;
          }
    }
}