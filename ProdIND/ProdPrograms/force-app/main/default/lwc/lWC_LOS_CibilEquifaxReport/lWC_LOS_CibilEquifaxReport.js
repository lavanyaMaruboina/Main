import { LightningElement, track, api, wire } from 'lwc';
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';
import getCibilRecord_MTD from '@salesforce/apex/IND_CibilEquifaxReportController.getCibilRecord';
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

import getCIBILDetails from '@salesforce/apex/IND_CibilEquifaxReportController.getCIBILDetails';

//Opportunity Field
import OPP_ID_FIELD from "@salesforce/schema/Opportunity.Id";
import OPP_SUB_STAGE_FIELD from "@salesforce/schema/Opportunity.Sub_Stage__c";

//Final Term Object
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import PricingEngine_thresholdNetrr from '@salesforce/schema/Final_Term__c.PricingEngine_thresholdNetrr__c';
import LtvEngine_Ltv from '@salesforce/schema/Final_Term__c.LtvEngine_Ltv__c';

//API Callout

import doLTVEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doLTVEngineCallout';
import doPricingEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doPricingEngineCallout';
import doBREscoreCardCallout from '@salesforce/apexContinuation/IntegrationEngine.doBREscoreCardCallout';

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
import Score_Card_Api_failed_Please_Re_Trigger from '@salesforce/label/c.Score_Card_Api_failed_Please_Re_Trigger';
import LTV_Engine_failed_Please_Re_Trigger from '@salesforce/label/c.LTV_Engine_failed_Please_Re_Trigger';
import Pricing_Engine_failed_Please_Re_Trigger from '@salesforce/label/c.Pricing_Engine_failed_Please_Re_Trigger';
import Score_Card_Passed from '@salesforce/label/c.Score_Card_Passed';
import Score_Card_failed_Please_Re_Trigger from '@salesforce/label/c.Score_Card_failed_Please_Re_Trigger';
import Pricing_Engine_Passed from '@salesforce/label/c.Pricing_Engine_Passed';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import storingCIBILDetails from '@salesforce/apex/ExternalCAMDataController.storingCIBILDetails';
export default class LWC_LOS_CibilEquifaxReport extends NavigationMixin(LightningElement) {
    
    label = {
        CIBIL,
        Borrower,
        CoBorrower,
        Equifax,
        CIBIL_Report,
        Equifax_Report
    }

    activeSections = [this.label.CIBIL, this.label.Equifax];

    @track disableBorSubmit = true;
    @track disableCoBorSubmit = true; 
    @api recordid;
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
    @track isBorrowerScoreCardEngTgr;
    @track borrowerName;

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
    @track disableField =true;

    @track reportURL;
    @track reportheader;
    @track showReport = false;

    @track isMadecallout = false;
    @track activeTab = this.label.Borrower;
    @track cibilDetailsRecordId;

    @track applicantId;
    @track finalTermId;

    @track fetchedData ;

    @track isSpinnerMoving = false;
    @track dataCibil =[];
    @track leadSource;//Ola Integration changes


    @api checkleadaccess;//coming from tabloanApplication

    async connectedCallback(){
        console.log('checkleadaccess ',this.checkleadaccess);
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
            if(this.leadSource=='OLA' || this.leadSource=='Hero'){//CISH-04
                this.disableBorSubmit=false;
                this.disableCheckEligibilityButton = true;//CISH-04
            }
            }
        });//Ola Integration changes
    }
    @api isRevokedLoanApplication;//CISP-2735
    renderedCallback(){
        if(this.isRevokedLoanApplication){
            this.disableEverything();
        }
    }
    //CISP-2735-END


   //Fetching data from backend
    @wire(getCibilRecord_MTD, { loanApplicationId: '$recordid' })
    wiredCibilRecord({ error, data }) {
        this.dataCibil =data;
        if (data) {
            //console.log('data from wired method ==> ', data);
            this.fetchedData = data;
            this.dataCibil =this.fetchedData;
            this.borrowerName = data.borrowerName;
            
            if (data.borrower) {

                this.disableViewCibilBtnBrw = !data.borrower.CIBIL_Report_URl__c ? true : false;
                this.disableViewEquifaxBtnBrw = !data.borrower.Equifax_Report_URl__c ? true : false;
                this.disableTgrCibilBtnBrw = data.borrower.CIBIL_Report_URl__c ? true : false;
                this.borrowerCICNo = data.borrower.CIC_No__c;
                this.borrowerMakerdate = data.borrower.Maker_Date__c;
                this.borrowerscore = data.borrower.Score__c;
                this.borrowerAppId = data.borrower.Applicant__c;
                this.cibilDetailsborrRecordId = data.borrower.Id;
                this.borrowerCibilReportURL = data.borrower.CIBIL_Report_URl__c ? data.borrower.CIBIL_Report_URl__c : undefined;
                this.borrowerEquifaxReportURL = data.borrower.Equifax_Report_URl__c ? data.borrower.Equifax_Report_URl__c : undefined;
                
            }
            if (data.showCoborrowerTab) {
                this.isCoborrowerTab = true;
                this.disableTgrCibilBtnCoBrw = false;
                this.coborrowerAppId = data.CoborrowerId;
                this.coBorrowerName = data.coBorrowerName;
                
            }

            if (data.coborrower && data.coborrower != undefined) {
                this.cibilDetailsCoborrRecordId = data.coborrower.Id;
                this.disableTgrCibilBtnCoBrw = data.coborrower.CIBIL_Report_URl__c ? true : false;
                this.disableViewCibilBtnCoBrw = !data.coborrower.CIBIL_Report_URl__c ? true : false;
                this.disableViewEquifaxBtnCoBrw = !data.coborrower.Equifax_Report_URl__c ? true : false;
                this.coborrowerCICNo = data.coborrower.CIC_No__c;
                this.coborrowerMakerdate = data.coborrower.Maker_Date__c;
                this.coborrowersscore = data.coborrower.Score__c;
                this.coborrowerCibilReportURL = data.coborrower.CIBIL_Report_URl__c;
                this.coborrowerEquifaxReportURL = data.coborrower.Equifax_Report_URl__c;
            }
            this.borrowerAppId = data.borrowerId;
            this.finalTermId = data.finalTermsId;
            this.isBorrowerScoreCardEngTgr = data.isBorrowerScoreCardEngTgr;
            this.isCoBorrowerScoreCardEngTgr = data.isCoBorrowerScoreCardEngTgr;
            this.isPricingEngineTgr = data.isPricingEngineTriggered;
            this.isLTVengineTgr = data.isLtvengineTriggered;

            if(data.loanApplicationSubStage != this.label.CIBIL){ 
                this.disableBorSubmit = true;
                this.disableCoBorSubmit = true;
            }else { 
                if( this.disableTgrCibilBtnBrw){                    
                    this.disableBorSubmit = false;
                }
                if(this.disableTgrCibilBtnCoBrw && this.disableTgrCibilBtnBrw){ 
                    this.disableCoBorSubmit = false; 
                }
            }
         
        } else if (error) {
            console.log('error in wired method ', error);
            // this.isSpinnerMoving = false;
        }
    }

    //close popup
    closeModalPopup() {
        this.showReport = false;
    }

    //Handle View CIBIL Report button functionality for Borrower
    viewCibilReport() {

        doGenerateTokenAPI()
        .then(resp=>{ 
            //console.log( ' Response : ', resp);            
            //console.log(' URL :', this.borrowerCibilReportURL+'&SessionId='+resp);
            //this.showReport = true;
            this.reportURL = this.borrowerCibilReportURL+'&SessionId='+resp;
            this.reportheader = this.label.CIBIL_Report;

            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: this.reportURL 
                }                
            })

        })
       console.log('Report URL : '+this.reportURL );
    }

    //Handle View CIBIL Report button functionality for Co-Borrower
    viewCoBorrowerCibilReport() {      

        doGenerateTokenAPI()
        .then(resp=>{ 
           // console.log( ' Response : ', resp);   
            //console.log(' URL :', this.borrowerCibilReportURL+'&SessionId='+resp);                    
            //this.showReport = true;
            this.reportURL = this.coborrowerCibilReportURL+'&SessionId='+resp;
            this.reportheader = this.label.CIBIL_Report;
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

    //Handle View Equifax Report button functionality for Co-Borrower
    viewCoBorrowerEquifaxReport() {  
        doGenerateTokenAPI()
        .then(resp=>{ 
          //  console.log( ' Response : ', resp);   
            //console.log(' URL :', this.borrowerCibilReportURL+'&SessionId='+resp);                      
            this.showReport = true;
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
    getCIBILReport(event) {
        
        this.isSpinnerMoving = true;
        var typeOfApplicant = event.target.value;
        this.applicantType=event.target.value;
        if (typeOfApplicant == this.label.CoBorrower) {            
            this.showToast(FETCH_BUREAU_REPORT+' '+this.coBorrowerName , 'info');
            this.applicantId = this.coborrowerAppId;
            if (this.cibilDetailsCoborrRecordId) {
                this.cibilDetailsRecordId = this.cibilDetailsCoborrRecordId;
            }else{//Start CISP-2937
                this.cibilDetailsRecordId = undefined;
            }//End CISP-2937
        } else {
            this.showToast(FETCH_BUREAU_REPORT+' '+this.borrowerName , 'info');
            this.applicantId = this.borrowerAppId;
            if (this.cibilDetailsborrRecordId) {
                this.cibilDetailsRecordId = this.cibilDetailsborrRecordId;
            }else{//Start CISP-2937
                this.cibilDetailsRecordId = undefined;
            }//End CISP-2937
        }

        let cibilRequest = {
            applicantId: this.applicantId,
            loanApplicationId: this.recordid
        }
        if (!this.isMadecallout) {
            //Calling CIBIL API
            doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
                .then(res => {
                    console.log('res=>', res);                    
                    this.isMadecallout = true;
                    //const pareseResp = JSON.parse(res);
                    const result = JSON.parse(res);
                    //console.log('Bureau Pull API Response Data:==>', result );
                    const cibilFields = {};
                    if (result.Data && result.Data.StatusCode ==200 && (result.Data.Application_Cibil_Details!= null)) { //CISP-3118
                        
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
                        //cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? result.Data.Cibil_LoanAccount_Details[0].Maker_Date : '' ;
                        
                        //stamping the maker date
                        if(((result.Data.Cibil_LoanAccount_Details).length) && 
                        (result.Data.Cibil_LoanAccount_Details[0].Maker_Date)){
                            let makerdt = result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                            makerdt = makerdt.substring(0, 10);
                            const splitDt = makerdt.split('-');   
                            let mDateVal = splitDt[2]+'-'+splitDt[1]+'-'+splitDt[0];  
                            console.log('Maker date : ',mDateVal);      
                            cibilFields[CIBIL_MAKER_DATE.fieldApiName] = mDateVal; 
                        }
                        
                       

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
                            this.updateRecordDetails(cibilFields,false);
                        }

                        const applicantsFields = {};
                        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                        applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true: false;
                        applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                        this.updateRecordDetails(applicantsFields,false);
                        this.isMadecallout = false;

                        if (typeOfApplicant === this.label.Borrower){ 
                            this.disableBorSubmit = false;
                        }else{ 
                            this.disableCoBorSubmit =false;
                        }

                        //calling Scorecard API
                        if (typeOfApplicant === this.label.Borrower && !this.isBorrowerScoreCardEngTgr) {
                            this.scoreCardAPIcall(cibilRequest);
                           
                        }
                        console.log('here 397 ',typeOfApplicant,' ',this.isCoBorrowerScoreCardEngTgr);
                        if (typeOfApplicant === this.label.CoBorrower && !this.isCoBorrowerScoreCardEngTgr) {
                            console.log('here 397');
                            this.scoreCardAPIcall(cibilRequest);
                       
                        }
                        storingCIBILDetails({  loanAppId: this.recordid, apiResponse: JSON.stringify(result.Data), applicantId: applicantId}).then({});
                    }else{ 
                        if(typeOfApplicant === this.label.Borrower ){ 
                            this.disableBorSubmit = true;
                        }else{ 
                            this.disableCoBorSubmit =true;
                        }
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
                    this.updateRecordDetails(applicantsFields,false);
                    if(typeOfApplicant === this.label.Borrower ){ 
                        this.disableBorSubmit = true;
                    }else{ 
                        this.disableCoBorSubmit =true;
                    }
                });
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
    handleSubmit(event) {
        console.log('check ',this.activeTab,' ',this.isBorrowerScoreCardEngTgr,' ',this.isLTVengineTgr,' ',this.isPricingEngineTgr);
        if (this.activeTab === this.label.Borrower  && ( !this.isBorrowerScoreCardEngTgr || !this.isLTVengineTgr || !this.isPricingEngineTgr) && this.leadSource!='OLA' && this.leadSource!='Hero') {//Ola integration changes  && CISH-04
            console.log('here');
            if(this.activeTab === this.label.Borrower && !this.isBorrowerScoreCardEngTgr) {
                this.showToastMessage(Score_Card_Api_failed_Please_Re_Trigger,'','warning');
            }else if(!this.isLTVengineTgr){
                this.showToastMessage(LTV_Engine_failed_Please_Re_Trigger,'','warning');
            }else if(!this.isPricingEngineTgr){
                this.showToastMessage(Pricing_Engine_failed_Please_Re_Trigger,'','warning');
            }
            if (this.activeTab === this.label.Borrower ) {
                this.disableRetriggerApi=false;
            }
            return null;        
        }


        this.disableBorSubmit =true;
        
        if(this.disableTgrCibilBtnCoBrw ){ 
            this.disableCoBorSubmit = false; 
        }

        if (this.isCoborrowerTab) {
            this.activeTab = this.label.CoBorrower;
        } else {
            const fields = {};
            fields[OPP_ID_FIELD.fieldApiName] = this.recordid;
            fields[OPP_SUB_STAGE_FIELD.fieldApiName] = this.label.CIBIL;
            this.isSpinnerMoving=true;
            this.updateRecordDetails(fields,true);
        }
    }

    //Handled Submit button functionality for Co-Borrower
    handleCoBorrSubmit(event) {

        console.log('check cob',this.activeTab,' ',this.isCoBorrowerScoreCardEngTgr,' ',this.isLTVengineTgr,' ',this.isPricingEngineTgr);
        if (this.activeTab === this.label.CoBorrower  && ( !this.isCoBorrowerScoreCardEngTgr || !this.isLTVengineTgr || !this.isPricingEngineTgr)) {
            console.log('here cob');
            if(this.activeTab === this.label.CoBorrower  && !this.isCoBorrowerScoreCardEngTgr ){
                this.showToastMessage(Score_Card_Api_failed_Please_Re_Trigger,'','warning');
            }else if(!this.isLTVengineTgr){
                this.showToastMessage(LTV_Engine_failed_Please_Re_Trigger,'','warning');
            }else if(!this.isPricingEngineTgr){
                this.showToastMessage(Pricing_Engine_failed_Please_Re_Trigger,'','warning');
            }
            if (this.activeTab === this.label.CoBorrower ) {
                this.disableCoBrwRetriggerApi=false;
            }
            return null;        
        }

        this.disableCoBorSubmit =true;
        const fields = {};
        fields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        fields[OPP_SUB_STAGE_FIELD.fieldApiName] = this.label.CIBIL;
        this.isSpinnerMoving=true;
        this.updateRecordDetails(fields,true);
    }

   //Borrower and Co-Borrower active tab
    handleMainActiveTab(event) {
        this.activeTab = event.target.value;
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

    //Scorecard API called and store the response in applicant object.
    scoreCardAPIcall(cibilRequest) {
        
        this.isSpinnerMoving=true;
        doBREscoreCardCallout({'applicantId' :this.applicantId, 'loanAppId' : this.recordid})
        .then(result=>{
            this.isSpinnerMoving=false;
            console.log('done 1');
            const response = JSON.parse(result);
            const applicantsFields = {};
            applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
            applicantsFields[ScoreCard_Description__c.fieldApiName] = response.BRE_Decision_Desc;
            applicantsFields[Scorecard_Decision__c.fieldApiName] =  response.BRE_Decision;
            this.updateRecordDetails(applicantsFields,false);    
            this.showToastMessage(Score_Card_Passed,'','success');
            if (this.activeTab === this.label.Borrower ) {
                this.isBorrowerScoreCardEngTgr=true;
            }else{
                this.isCoBorrowerScoreCardEngTgr=true;
            }       
            //Called LTV Engine API
            if (!this.isLTVengineTgr) {
                this.callDoLtvEngineCallout();
            }
           
        })
        .catch(error => {
            if (this.activeTab === this.label.Borrower ) {
                this.isBorrowerScoreCardEngTgr=false;
                this.disableRetriggerApi=false;
                
            }else{
                this.isCoBorrowerScoreCardEngTgr=false;
                this.disableCoBrwRetriggerApi=false;
            } 
            this.showToastMessage(Score_Card_failed_Please_Re_Trigger,'','error');
            console.log('error in Scorecard API', error);
            this.isSpinnerMoving = false;
            this.retryPopUp = true;
        });
      
    }

    //LTV engine API is called and store response in Final Terms
    callDoLtvEngineCallout() {
        
        this.isSpinnerMoving=true;
        doLTVEngineCallout({ applicantId: this.applicantId, loanAppId: this.recordid })
            .then(result => {
                
            this.isSpinnerMoving=false;
            console.log('done 2');
                const obj = JSON.parse(result);
                this.ltv = obj.LTV;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                FinalTermFields[LtvEngine_Ltv.fieldApiName] = this.ltv;
                this.updateRecordDetails(FinalTermFields,false);
                this.isLTVengineTgr = true;
                this.showToastMessage(Score_Card_Passed,'','success');
                //Called Pricing Engine API
                if (!this.isPricingEngineTgr) {
                    this.calldoPricingEngineCallout();
                }
            })
            .catch(error => {
                if (this.activeTab === this.label.Borrower ) {
                    this.disableRetriggerApi=false;
                }else{
                    this.disableCoBrwRetriggerApi=false;
                }
                this.showToastMessage(LTV_Engine_failed_Please_Re_Trigger,'','error');
                this.isLTVengineTgr = false;
                console.log('error in doLTVEngineCallout data ', error);
                this.isSpinnerMoving = false;
                this.retryPopUp = true;
            });
    }

    //Pricing engine API to be called and store the response in Final terms object.
    calldoPricingEngineCallout() {
        
        this.isSpinnerMoving=true;
        doPricingEngineCallout({ applicantId: this.applicantId, loanAppId: this.recordid })
            .then(result => {
                
                this.isSpinnerMoving=false;
                console.log('done 3');
                const obj = JSON.parse(result);
                this.thresholdNetIRR = obj.Threshold_Net_IRR;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                FinalTermFields[PricingEngine_thresholdNetrr.fieldApiName] = this.thresholdNetIRR;
                this.updateRecordDetails(FinalTermFields,false);
                this.isPricingEngineTgr = true;
                this.showToastMessage(Pricing_Engine_Passed,'','success');
            })
            .catch(error => {
                this.isPricingEngineTgr = false;
                this.isSpinnerMoving = false;
                if (this.activeTab === this.label.Borrower ) {
                    this.disableRetriggerApi=false;
                }else{
                    this.disableCoBrwRetriggerApi=false;
                }
                this.showToastMessage(Pricing_Engine_failed_Please_Re_Trigger,'','error');
                console.log('error in calldoPricingEngineCallout', error);
                this.retryPopUp = true;
            });
    }

    // Creating new records
    createRecordDetails(objectApiName, fields) {
         createRecord({ apiName: objectApiName, fields: fields })
            .then(obj => {                             
                this.cibilDetailsRecordId = obj.id;    
                getCIBILDetails({cibilId : obj.id})
                .then( res =>{ 
                    //console.log('res ::', res);
                    if(res.Applicant__r.Applicant_Type__c == this.label.Borrower){
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

                    }else if(res.Applicant__r.Applicant_Type__c == this.label.CoBorrower){ 
                        this.coborrowerCICNo = res.CIC_No__c;
                         this.coborrowersscore = res.Score__c;
                         this.coborrowerMakerdate = res.Maker_Date__c;
                         this.disableViewCibilBtnCoBrw = !res.CIBIL_Report_URl__c ? true: false;
                         this.disableViewEquifaxBtnCoBrw = !res.Equifax_Report_URl__c ?true:false;
                         this.disableTgrCibilBtnCoBrw = true;
                         if(!this.disableViewCibilBtnCoBrw){ 
                            this.coborrowerCibilReportURL =res.CIBIL_Report_URl__c
                         }
                         if(!this.disableViewEquifaxBtnCoBrw){ 
                            this.coborrowerEquifaxReportURL = res.Equifax_Report_URl__c;
                         }
                    }
                })
                refreshApex(this.dataCibil);
            })
            .catch(error => {
                console.log('error in record creation ', error);
            });
    }

    //Updating record details
    async updateRecordDetails(fields,toNextStage) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                this.isSpinnerMoving=false;
                console.log('record update success', JSON.stringify(fields));//keeping for reference
                refreshApex(this.dataCibil);
                if(toNextStage){
                    this.dispatchEvent(new CustomEvent('cibilevent', { detail: this.label.CIBIL }));
                }
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
        this.applicantId = this.activeTab === this.label.Borrower ?  this.borrowerAppId : this.coborrowerAppId;
        let cibilRequest = {
            applicantId: this.applicantId,
            loanApplicationId: this.recordid
        }
        console.log('reTriggerApis  ',this.applicantId,' ',this.recordid);
        if (this.activeTab === this.label.Borrower && !this.isBorrowerScoreCardEngTgr) {
            this.scoreCardAPIcall(cibilRequest);           
        }else if (this.activeTab === this.label.CoBorrower && !this.isCoBorrowerScoreCardEngTgr) {
            this.scoreCardAPIcall(cibilRequest);
        }else if(!this.isLTVengineTgr){
            this.callDoLtvEngineCallout();
        }else if(!this.isPricingEngineTgr){
            this.calldoPricingEngineCallout();
        }else{
            if (this.activeTab === this.label.Borrower ) {
                this.disableRetriggerApi=false;
            }else{
                this.disableCoBrwRetriggerApi=false;
            }
        }

    }
    handleCoborrowerActiveTab(event) {
        this.activeTab = event.target.value;
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
}