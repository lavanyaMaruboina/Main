import { LightningElement, track, api,wire } from 'lwc';
import { updateRecord,createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';

import loadExistingEMIData from '@salesforce/apex/Ind_ExistingEMICtrl.loadExistingEMIData';
import getExistingEMISubmittedValue  from  '@salesforce/apex/Ind_ExistingEMICtrl.getExistingEMISubmittedValue';
import updateRetryCount  from  '@salesforce/apex/Ind_ExistingEMICtrl.updateRetryCount';
import saveEMIDetails from '@salesforce/apex/Ind_ExistingEMICtrl.saveEMIDetails1';
import createOtherDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createOtherDocument';
import checkImageExist from '@salesforce/apex/Ind_IncomeDetailsCtrl.checkImageExist';
import fetchDocument from '@salesforce/apex/Ind_IncomeDetailsCtrl.fetchDocument';
import getBankStatementDocument from '@salesforce/apex/Ind_ExistingEMICtrl.getBankStatementDocument';
import validateExistingEMISubmitAction from '@salesforce/apex/Ind_ExistingEMICtrl.validateExistingEMISubmitAction';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';

import doBREscorecardCallout from '@salesforce/apexContinuation/IntegrationEngine.doBREscoreCardCallout';
import doEPFUANLookupCallout from '@salesforce/apexContinuation/IntegrationEngine.doEPFUANLookupCallout';
import doEPFOAuthCallout from '@salesforce/apexContinuation/IntegrationEngine.doEPFOAuthCallout';
import doRunEmiEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doRunEmiEngineCallout';

import Profile_FIELD from '@salesforce/schema/Applicant__c.Profile__c';
import UAN_NUMBER_FIELD from '@salesforce/schema/Applicant__c.EPFO_UAN_Number__c';
import EMPLOYER_NAME_FIELD from '@salesforce/schema/Applicant__c.Employer_Name__c';
import EMPLOYEE_NAME_FIELD from '@salesforce/schema/Applicant__c.Employee_Name__c';
import START_DATE_FIELD from '@salesforce/schema/Applicant__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Applicant__c.End_Date__c';
import SCORE_CARD_DECISION_FIELD from '@salesforce/schema/Applicant__c.Scorecard_Decision__c';
import SCORE_CARD_DESC_FIELD from '@salesforce/schema/Applicant__c.ScoreCard_Description__c';
import IS_EXISTING_EMI_SUBMITTED_FIELD from '@salesforce/schema/Applicant__c.Is_Existing_EMI_Submitted__c';
import IS_RUN_EMI_ACCESSED_FIELD from '@salesforce/schema/Applicant__c.Is_RUN_EMI_Assessed__c';
import RENTAL_OBLIGATION from '@salesforce/schema/Applicant__c.Rental_Expense__c';
import OTHER_OBLIGATION from '@salesforce/schema/Applicant__c.Other_Obligation__c';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import LEAD_NUMBER_FIELD from '@salesforce/schema/Opportunity.Lead_number__c';
import EXISTING_EMI_ID_FIELD from '@salesforce/schema/Existing_EMI__c.Id';
import EMI_AMOUNT_FIELD from '@salesforce/schema/Existing_EMI__c.EMI__c';

import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import Customer_Bank_Statement from '@salesforce/label/c.Customer_Bank_Statement';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';


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

import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Bureau_Pull_Match__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Match__c';
import Bureau_Pull_Message__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Message__c';

import getCurrentApplicantRecord from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.getCurrentApplicantRecord';
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';
import getCurrentOppRecord from '@salesforce/apex/IND_RevokeController.getCurrentOppRecord';
import Declaration_Content_Income_Details from '@salesforce/label/c.Declaration_Content_Income_Details';//SFTRAC-1791
import Is_Borrower_Relative_Of_Director from '@salesforce/label/c.Is_Borrower_Relative_Of_Director';//SFTRAC-1791
import Is_Borrower_Relative_Of_Senior_Officer from '@salesforce/label/c.Is_Borrower_Relative_Of_Senior_Officer';//SFTRAC-1791
import Is_CoBorrower_Relative_Of_Director from '@salesforce/label/c.Is_CoBorrower_Relative_Of_Director';//SFTRAC-1791
import Is_CoBorrower_Relative_Of_Senior_Officer from '@salesforce/label/c.Is_CoBorrower_Relative_Of_Senior_Officer';//SFTRAC-1791
import Is_Relationship_With_IndusInd_Or_Other_Bank from '@salesforce/label/c.Is_Relationship_With_IndusInd_Or_Other_Bank';//SFTRAC-1791
import Borrower_Relation_With_IndusInd_Question_1 from '@salesforce/label/c.Borrower_Relation_With_IndusInd_Question_1';//SFTRAC-1791
import Borrower_Relation_With_IndusInd_Question_2 from '@salesforce/label/c.Borrower_Relation_With_IndusInd_Question_2';//SFTRAC-1791
import Borrower_Relation_With_Other_Bank_Question_1 from '@salesforce/label/c.Borrower_Relation_With_Other_Bank_Question_1';//SFTRAC-1791
import Borrower_Relation_With_Other_Bank_Question_2 from '@salesforce/label/c.Borrower_Relation_With_Other_Bank_Question_2';//SFTRAC-1791
import CoBorrower_Relation_With_IndusInd_Question_1 from '@salesforce/label/c.CoBorrower_Relation_With_IndusInd_Question_1';//SFTRAC-1791
import CoBorrower_Relation_With_IndusInd_Question_2 from '@salesforce/label/c.CoBorrower_Relation_With_IndusInd_Question_2';//SFTRAC-1791
import CoBorrower_Relation_With_Other_Bank_Question_1 from '@salesforce/label/c.CoBorrower_Relation_With_Other_Bank_Question_1';//SFTRAC-1791
import CoBorrower_Relation_With_Other_Bank_Question_2 from '@salesforce/label/c.CoBorrower_Relation_With_Other_Bank_Question_2';//SFTRAC-1791
import Borrower_SO_Relation_With_IndusInd_Question_1 from '@salesforce/label/c.Borrower_SO_Relation_With_IndusInd_Question_1';//SFTRAC-1791
import Borrower_SO_Relation_With_IndusInd_Question_2 from '@salesforce/label/c.Borrower_SO_Relation_With_IndusInd_Question_2';//SFTRAC-1791
import Borrower_SO_Relation_With_Other_Bank_Question_1 from '@salesforce/label/c.Borrower_SO_Relation_With_Other_Bank_Question_1';//SFTRAC-1791
import Borrower_SO_Relation_With_Other_Bank_Question_2 from '@salesforce/label/c.Borrower_SO_Relation_With_Other_Bank_Question_2';//SFTRAC-1791
import CoBorrower_SO_Relation_With_IndusInd_Question_1 from '@salesforce/label/c.CoBorrower_SO_Relation_With_IndusInd_Question_1';//SFTRAC-1791
import CoBorrower_SO_Relation_With_IndusInd_Question_2 from '@salesforce/label/c.CoBorrower_SO_Relation_With_IndusInd_Question_2';//SFTRAC-1791
import CoBorrower_SO_Relation_With_Other_Bank_Question_1 from '@salesforce/label/c.CoBorrower_SO_Relation_With_Other_Bank_Question_1';//SFTRAC-1791
import CoBorrower_SO_Relation_With_Other_Bank_Question_2 from '@salesforce/label/c.CoBorrower_SO_Relation_With_Other_Bank_Question_2';//SFTRAC-1791
import Relationship_with_borrower__c from '@salesforce/schema/Applicant__c.Relationship_with_borrower__c';
import Applicant__c from '@salesforce/schema/Applicant__c';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import BORROWER_RELATIVE_OF_DIRECTOR from '@salesforce/schema/Applicant__c.Is_Borrower_Relative_Of_Director__c';//SFTRAC-1791
import BORROWER_RELATIVE_OF_SENIOR_OFFICER from '@salesforce/schema/Applicant__c.Is_Borrower_Relative_Of_Senior_Officer__c';//SFTRAC-1791
import COBORROWER_RELATIVE_OF_DIRECTOR from '@salesforce/schema/Applicant__c.Is_CoBorrower_Relative_Of_Director__c';//SFTRAC-1791
import COBORROWER_RELATIVE_OF_SENIOR_OFFICER from '@salesforce/schema/Applicant__c.Is_CoBorrower_Relative_Of_Senior_Officer__c';//SFTRAC-1791
import BORROWER_RELATION_WITH_INDUSIND_Q1 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_IndusInd_Q1__c';//SFTRAC-1791
import BORROWER_RELATION_WITH_INDUSIND_Q2 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_IndusInd_Q2__c';//SFTRAC-1791
import BORROWER_RELATION_WITH_OTHERBANK_Q1 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_Other_Bank_Q1__c';//SFTRAC-1791
import BORROWER_RELATION_WITH_OTHERBANK_Q2 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_Other_Bank_Q2__c';//SFTRAC-1791
import COBORROWER_RELATION_WITH_INDUSIND_Q1 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_IndusInd_Q1__c';//SFTRAC-1791
import COBORROWER_RELATION_WITH_INDUSIND_Q2 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_IndusInd_Q2__c';//SFTRAC-1791
import COBORROWER_RELATION_WITH_OTHERBANK_Q1 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_Other_Bank_Q1__c';//SFTRAC-1791
import COBORROWER_RELATION_WITH_OTHERBANK_Q2 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_Other_Bank_Q2__c';//SFTRAC-1791
import RELATION_WITH_INDUSIND_OR_OTHER from '@salesforce/schema/Applicant__c.Relationship_With_IndusInd_Or_Other_Bank__c';//SFTRAC-1791
import BORROWER_SO_RELATION_WITH_INDUSIND_Q1 from '@salesforce/schema/Applicant__c.Borrower_SO_Relation_With_IndusInd_Q1__c';//SFTRAC-1791
import BORROWER_SO_RELATION_WITH_INDUSIND_Q2 from '@salesforce/schema/Applicant__c.Borrower_SO_Relation_With_IndusInd_Q2__c';//SFTRAC-1791
import BORROWER_SO_RELATION_WITH_OTHERBANK_Q1 from '@salesforce/schema/Applicant__c.Borrower_SO_Relation_With_Other_Bank_Q1__c';//SFTRAC-1791
import BORROWER_SO_RELATION_WITH_OTHERBANK_Q2 from '@salesforce/schema/Applicant__c.Borrower_SO_Relation_With_Other_Bank_Q2__c';//SFTRAC-1791
import COBORROWER_SO_RELATION_WITH_INDUSIND_Q1 from '@salesforce/schema/Applicant__c.CoBorrower_SO_Relation_With_IndusInd_Q1__c';//SFTRAC-1791
import COBORROWER_SO_RELATION_WITH_INDUSIND_Q2 from '@salesforce/schema/Applicant__c.CoBorrower_SO_Relation_With_IndusInd_Q2__c';//SFTRAC-1791
import COBORROWER_SO_RELATION_WITH_OTHERBANK_Q1 from '@salesforce/schema/Applicant__c.CoBorrower_SO_Relation_With_OtherBank_Q1__c';//SFTRAC-1791
import COBORROWER_SO_RELATION_WITH_OTHERBANK_Q2 from '@salesforce/schema/Applicant__c.CoBorrower_SO_Relation_With_OtherBank_Q2__c';//SFTRAC-1791
import BORROWER_SO_SPECIFIC_RELATION from '@salesforce/schema/Applicant__c.Borrower_SO_Specific_Relation__c';//SFTRAC-1791
import COBORROWER_SO_SPECIFIC_RELATION from '@salesforce/schema/Applicant__c.CoBorrower_SO_Specific_Relation__c';//SFTRAC-1791
import SO_RELATIONSHIP_WITH_INDUSIND_OR_OTHER from '@salesforce/schema/Applicant__c.SO_Relationship_With_IndusInd_Or_Other__c';//SFTRAC-1791
import BORROWER_DIRECTOR_SPECIFIC_RELATION from '@salesforce/schema/Applicant__c.Borrower_Director_Specific_Relation__c';//SFTRAC-1791
import COBORROWER_DIRECTOR_SPECIFIC_RELATION from '@salesforce/schema/Applicant__c.CoBorrower_Director_Specific_Relation__c';//SFTRAC-1791
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import getApplicantRelationshipWithBank from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getApplicantRelationshipWithBank';
const fields = [LEAD_NUMBER_FIELD];

export default class lWC_LOS_ExistingEMI  extends NavigationMixin(LightningElement) {
    @api recordId;
    @api applicantId;
    @api isRevokedLoanApplication;
    // CISP-2752
    @track _activeTab;
    @api set activeTab(value){
        this._activeTab = value;
    }
    get activeTab(){
        return this._activeTab;
    }
    // CISP-2752-END
    @api currentStage;
    @api currentStageName;
    @api lastStage;
    @api isTwoWheeler;
    @api isTractor;
    @api isPvProduct;
    @api isNonIndividual;
  
    
    @api checkleadaccess;//coming from tabloanApplication
    @api leadSource;
    @track showSpinner = false;
    @track showEMIDetails = false;
    @track disableRunEMIBtn = true;
    @track showCheckedTickForRunEMI = false;
    @track disableCaptureBankStatement = false;
    @track showRunEMI = true;
    @track showNoEMIMessage = false;
    @track showModalEMI = false;
    @track showCancelBtn = false;
    @track isRUNEMIAccessed = false;
    @track isExistingEMISubmitted = false;
    @track isBankAccountPresent = false;
    @track showCheckedTickForDocUpload = false;

    @track existingEMIsList; 
    @track modalMsgEMI;
    @track userEnteredEMI;
    @track documentRecordId;
    @track loanRecordsArray = [];
    @track existingEmiId;
    @track uploadViewDocFlag;

    @track showDocView;
    @track showUpload;
    isBorrower;

    //API fields
    scoreCardDescription;
    scorecardDecision
    uanNumber;
    higherEMIFlag = false;
    attempt = 0;
    @track relationshipDropdown;//SFTRAC-1791
    @track soRelationshipDropdown;//SFTRAC-1791

    label = {Retry_Exhausted,Customer_Bank_Statement, Regex_NumberOnly,
        Declaration_Content_Income_Details,//SFTRAC-1791
        Is_Borrower_Relative_Of_Director,//SFTRAC-1791
        Is_Borrower_Relative_Of_Senior_Officer,//SFTRAC-1791
        Is_CoBorrower_Relative_Of_Director,//SFTRAC-1791
        Is_CoBorrower_Relative_Of_Senior_Officer,//SFTRAC-1791
        Is_Relationship_With_IndusInd_Or_Other_Bank,//SFTRAC-1791
        Borrower_Relation_With_IndusInd_Question_1,//SFTRAC-1791
        Borrower_Relation_With_IndusInd_Question_2,//SFTRAC-1791
        Borrower_Relation_With_Other_Bank_Question_1,//SFTRAC-1791
        Borrower_Relation_With_Other_Bank_Question_2,//SFTRAC-1791
        CoBorrower_Relation_With_IndusInd_Question_1,//SFTRAC-1791
        CoBorrower_Relation_With_IndusInd_Question_2,//SFTRAC-1791
        CoBorrower_Relation_With_Other_Bank_Question_1,//SFTRAC-1791
        CoBorrower_Relation_With_Other_Bank_Question_2,//SFTRAC-1791
        Borrower_SO_Relation_With_IndusInd_Question_1,//SFTRAC-1791
        Borrower_SO_Relation_With_IndusInd_Question_2,//SFTRAC-1791
        Borrower_SO_Relation_With_Other_Bank_Question_1,//SFTRAC-1791
        Borrower_SO_Relation_With_Other_Bank_Question_2,//SFTRAC-1791
        CoBorrower_SO_Relation_With_IndusInd_Question_1,//SFTRAC-1791
        CoBorrower_SO_Relation_With_IndusInd_Question_2,//SFTRAC-1791
        CoBorrower_SO_Relation_With_Other_Bank_Question_1,//SFTRAC-1791
        CoBorrower_SO_Relation_With_Other_Bank_Question_2,//SFTRAC-1791
        RegEx_Alphabets_Only
    };

    @track parentLeadRevoked = false;
    @track bureauPullTick = false;
    @track disabledBureauPullButton = false;
    @track cibilDetailsRecordId;
    @track isCoBorrowerExist = false;
    get showDeclarationContent(){
        return this.isTractor && !this.isNonIndividual;
    }
    get ifCoBorrowerIsTheTab() {
        if(this.currentApplicantType == 'Borrower')
        return false;
        else
        return true;
    }
    get yesAndNoOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }
    get BankOptions() {
        return [
            { label: 'IndusInd Bank', value: 'IndusInd Bank' },
            { label: 'Other Bank', value: 'Other Bank' }
        ];
    }
    relationshipWithBorrower;
    @wire(getObjectInfo, { objectApiName: Applicant__c }) objectInfo;//CISP-7987
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Relationship_with_borrower__c }) relationshipWithBorrower;
    get showBureauPullBtn(){
        return (((this.isTractor && !this.isNonIndividual) || (this.isTractor && this.isNonIndividual && this.activeTab != 'Borrower')) && this.parentLeadRevoked);
    }

    async handleBureauPullClick(){
        this.showSpinner = true;
        let cibilRequest = {
            applicantId: this.applicantId,
            loanApplicationId: this.recordId
        }
        await doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) }).then(res => {
            const result = JSON.parse(res);
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
                if ((result.Data.Cibil_LoanAccount_Details).length) {
                    if ((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')) {
                        let makerDate = result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                        this.makerDateConversion = makerDate.substring(0, makerDate.lastIndexOf(' '));
                    }
                }
                cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? this.makerDateConversion.split("-").reverse().join("-") : '';
                if (this.isTractor) { cibilFields[CIBIL_PULL_DATE.fieldApiName] = new Date().toISOString(); }
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

                if (result.Data.IsSuccess === 'True') {
                    const evt = new ShowToastEvent({
                        title: 'success',
                        message: result.Data.StatusDescription,
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.bureauPullTick = true;
                    this.disabledBureauPullButton = true;
                }
            } else {
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: result.Data.StatusDescription,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            const applicantsFields = {};
            applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
            applicantsFields[Bureau_Pull_Match__c.fieldApiName] = false;
            applicantsFields[Bureau_Pull_Message__c.fieldApiName] = error?.body?.message;
            this.updateRecordDetails(applicantsFields);
        });
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
        .then(() => {}).catch(error => { });
    }

    async createRecordDetails(objectApiName, fields) {
        await createRecord({ apiName: objectApiName, fields: fields })
        .then(obj => {this.cibilDetailsRecordId = obj.id;})
        .catch(error => {});
    }

    async connectedCallback() {
        this.showSpinner = true;

        if(this.isTractor){
            let result = await getCurrentOppRecord({'loanApplicationId' : this.recordId});
            if(result && result.length > 0 && result[0].Parent_Loan_Application__r && result[0].Parent_Loan_Application__r.Is_Revoked__c == true){
                this.parentLeadRevoked = true;
            }
            await getCurrentApplicantRecord({ applicantId: this.applicantId })
            .then(response => {
                if (response.CIBIL_Details__r) {
                    this.cibilDetailsRecordId = response.CIBIL_Details__r[0].Id;
                } else {
                    this.cibilDetailsRecordId = null;
                }

                if (response.Bureau_Pull_Match__c === true || response.Bureau_Pull_Message__c === this.label.Retry_Exhausted) {
                    this.disabledBureauPullButton = true;
                }
                if (response.Bureau_Pull_Match__c === true) {
                    this.bureauPullTick = true;
                }
            })
            .catch((error)=>{});
            this.doGetApplicantRelationshipWithBank();
            
        }

        console.log('Is Two Wheeler:: ', this.isTwoWheeler);

        await this.init();
        await this.callAccessLoanApplication();
        this.relationshipDropdown = this.relationshipWithBorrower?.data.values;
            this.soRelationshipDropdown = this.relationshipWithBorrower?.data.values;
    }
    currentApplicantType;
    async init(){
        await loadExistingEMIData({ loanApplicationId: this.recordId, applicantId: this.applicantId }).then(result => {
            console.log('loadExistingEMIData - Result:: ', result);
            this.isExistingEMISubmitted = result?.isExistingEMISubmitted;
            this.isBankAccountPresent = result?.isHaveBankAccount;
            this.isRUNEMIAccessed =  result?.isRUNEMIAccessed;
            this.currentApplicantType =  result?.applicantType;
            this.rentalExpense = result?.rentalExpense;
            this.otherObligation = result?.otherObligation;
            if(this._activeTab == 'Borrower'){
            this.isBorrower = true;
            }
            if(this.activeTab != 'Borrower'){this.isCoBorrowerExist = true;}else{this.isCoBorrowerExist = false;}//SFTRAC-1791
            
            if(this.isNonIndividual && this.currentApplicantType === 'Borrower' && this.isTractor){
                this.disableRunEMIBtn = true;
            }else if(!this.isTwoWheeler || this.isTractor) {
                this.disableRunEMIBtn = false;
                let existingEMIDetails = result?.existingEMIDetails;
                let emiRetryCount = result?.retryCountDetails ? result?.retryCountDetails[0] : undefined;

                if(existingEMIDetails && existingEMIDetails.length > 0) {
                    let existingEMIArr = [];
                    let k=0;
                    
                    for (let index in existingEMIDetails) {
                        let isEMISubmittedFlag = true;
                        if(existingEMIDetails[index].EMI__c === null || existingEMIDetails[index].EMI__c === '' || existingEMIDetails[index].EMI__c === undefined){
                            isEMISubmittedFlag = false;
                        }
                        //Configure Data for display
                        let existingEMIObj = {
                            ...{ 'Id': k },
                            ...{ 'Sequential_Number': 'Loan ' + (parseInt(k+ 1) ) },
                            ...{ 'Loan_Type': existingEMIDetails[index].Loan_Type__c },
                            ...{ 'Outstanding_Amount': existingEMIDetails[index].Outstanding_Amount__c },
                            ...{ 'EMI__c': existingEMIDetails[index].EMI__c },
                            ...{ 'isEMISubmitted': isEMISubmittedFlag},
                            ...{ 'existing_emi_id': existingEMIDetails[index].Id },
                            ...{ 'upper_LimitEMI': existingEMIDetails[index].Upper_EMI_Limit__c },
                            ...{ 'lower_LimitEMI': existingEMIDetails[index].Lower_EMI_Limit__c }
                        };
                        k++;
                        existingEMIArr.push(existingEMIObj);
                    }

                    this.existingEMIList = existingEMIArr;
                    this.showEMIDetails = true;
                    this.disableRunEMIBtn = true;
                    this.showCheckedTickForRunEMI = true;
                } else if(emiRetryCount?.Count__c === 4) {
                    this.showEMIDetails = false;
                    this.disableRunEMIBtn = true;
                    this.runEMiButtonX = true;
                } else if(emiRetryCount?.Count__c > 0 && emiRetryCount?.Count__c < 4 && this.isRUNEMIAccessed === true) {
                    this.showEMIDetails = false;
                    this.disableRunEMIBtn = true;
                    this.showCheckedTickForRunEMI = true;
                    this.showNoEMIMessage = true;
                }
            } else {
                this.showRunEMI = false;
                this.disableRunEMIBtn = false;
            }
        }).catch(error => {
            console.log('loadExistingEMIData - Error', error);
        });

        await getBankStatementDocument({ docType: 'Customer Bank Statement', applicantId: this.applicantId }).then(result => {
            console.log('bank statment result : ', result);
            if (result.length > 0) {
                this.disableCaptureBankStatement = true;
                this.showCheckedTickForDocUpload = true;
            } else {
                this.disableCaptureBankStatement = false;
                this.showCheckedTickForDocUpload = false;
            }
        }).catch(error => {
            console.log('bank statment error', error);
        });

        this.showSpinner = false;
    }

   async renderedCallback(){
       //await this.callAccessLoanApplication();

        if (this.currentStage === 'Credit Processing' || (this.currentStageName !== 'Income Details' && this.lastStage !== 'Income Details' && this.isTractor)) {
            this.disableEverything();
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }

    handleRunEMI() {
        if(this.isTractor && this.showBureauPullBtn && !this.disabledBureauPullButton && this.parentLeadRevoked){
            this.showToastMessage('Warning','Cibil Bureau Details was not found for this applicant. Please click on bureau button!','warning');
            return;
        }
        this.showSpinner = true;
        updateRetryCount({ applicantId: this.applicantId, loanAppId :this.recordId }).then(response => {
            console.log('updateRetryCount - response:: ', response);
            
            if (response === this.label.Retry_Exhausted){
                this.disableRunEMIBtn = true;
                this.runEMiButtonX = true;
                this.showEMIDetails = false;
                this.showCancelBtn = true;
                
                this.showModalEMI = true;
                this.modalMsgEMI = 'You have reached maximum attempt to RUN EMI Engine';
      
                this.showSpinner =  false;
            } else {
                let runEMIDetails = {
                    'applicantId': this.applicantId,
                    'loanApplicationId': this.recordId,
                };

                doRunEmiEngineCallout({'runEmiEngine': JSON.stringify(runEMIDetails)}).then(result => {
                    console.log('DoRunEmiEngineCallout - result::', result);
                    let custObj;
                    let resArr = [JSON.parse(result)];
                    let emiRanges = resArr[0].emiRanges;
                    let k = 0;
                    let updatedResp=[]
                  
                    for (var i = 0; i < emiRanges.length; i++) {
                        if(emiRanges[i].Outstanding_Amt>0){               
                            custObj = {
                                ...{ 'Id': k },
                                ...{ 'Loan_Type': emiRanges[i].Loan_Type },
                                ...{ 'Outstanding_Amount': emiRanges[i].Outstanding_Amt },
                                ...{ 'Sequential_Number': 'Loan ' + (parseInt(k+1) ) },
                                ...{ 'upper_LimitEMI': emiRanges[i].Upper_Emi_Cap },
                                ...{ 'lower_LimitEMI': emiRanges[i].Lower_Emi_Cap },
                                ...{ 'emi': '' },
                                ...{ 'existing_emi_id': ''}
                            };
                            console.log('custObj:: ',custObj);
                            updatedResp.push(custObj);
                            k++;
                        }                   
                    }

                    this.existingEMIList = updatedResp;
                    this.showEMIDetails = true;
                    this.showCheckedTickForRunEMI = true;
                    this.disableRunEMIBtn = true;
                   
                    if(emiRanges.length>0) {
                        this.saveValidatedEMIData();
                    } else {
                        this.showEMIDetails = false;
                        this.showNoEMIMessage = true;
                    }

                    //Update API Fields
                    const fields = {};
                    fields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                    fields[IS_RUN_EMI_ACCESSED_FIELD.fieldApiName] = true;
                    const recordInput = {fields};

                    updateRecord(recordInput).then(() => {
                        console.log('Applicant Record for EMI Update is Successful:: ', JSON.stringify(fields));
                    }).catch(error => {
                        console.log('Error in updating reocrd:: ', error);
                        this.showToastMessage(null, 'Error in saving Existing EMI data', 'Error');
                    });

                    this.showSpinner = false;
                }).catch(error => {
                    this.showSpinner = false;
                    this.showEMIDetails = false;
                    this.showModalEMI = true;
                    this.showCancelBtn = true;
                    this.modalMsgEMI = error?.body?.message;
                    console.log('retryCountUpdate - Error', error);
                });
            }
        }).catch(error => {
            console.log('retryCountUpdate - Error', error);
        });
    }

    handleValid(event) {
        const tableData = event.target.value;      
        const rowId = tableData.Id;
        let emiEntered = this.template.querySelectorAll('.emiInput');          
        this.userEnteredEMI = emiEntered[rowId].value;
        let upperLimit = tableData.upper_LimitEMI;
        let lowerLimit = tableData.lower_LimitEMI;
        let validBtnId = this.template.querySelectorAll('.validbtn');
        // if ((parseFloat(this.userEnteredEMI) <  parseFloat(lowerLimit)) || (parseFloat(this.userEnteredEMI) > parseFloat(upperLimit))) {
        //     this.higherEMIFlag = true;
        //     this.showModalEMI = true;
        //     this.showCancelBtn = true;
        //     this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        //     return;
        // }
        if ((parseFloat(this.userEnteredEMI) > parseFloat(upperLimit)) && this.higherEMIFlag == false) {
            this.higherEMIFlag = true;
            this.showModalEMI = true;
            this.showCancelBtn = true;
            this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        } else if ((parseFloat(this.userEnteredEMI) > parseFloat(upperLimit)) && this.higherEMIFlag == true) {
            this.showModalEMI = false;
            this.showCancelBtn = false;
            this.modalMsgEMI = null;
            emiEntered[rowId].disabled = true;
            validBtnId[rowId].disabled = true;
            this.existingEMIList[rowId]['emi'] = this.userEnteredEMI;
            this.attempt=0;
            this.higherEMIFlag=false;
            this.updateEMIValue(tableData.existing_emi_id, this.userEnteredEMI);
        } else if ((parseFloat(this.userEnteredEMI) < parseFloat(lowerLimit)) && this.attempt <= 2) {
            this.attempt++;
            this.showModalEMI = true;
            this.showCancelBtn = true;
            this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        } else if ((parseFloat(this.userEnteredEMI) < parseFloat(lowerLimit)) && this.attempt > 2) {
            this.disableRunEMIBtn = true;
            this.userEnteredEMI = (parseFloat(upperLimit) + parseFloat(lowerLimit)) / 2;
            this.showModalEMI = false;
            this.showCancelBtn = false;
            this.modalMsgEMI = null;
            emiEntered[rowId].value = this.userEnteredEMI;
            emiEntered[rowId].disabled = true;
            validBtnId[rowId].disabled = true;
            this.higherEMIFlag = false;
            this.attempt = 0;
            this.updateEMIValue(tableData.existing_emi_id, this.userEnteredEMI);
        } else if ((parseFloat(this.userEnteredEMI) >=  parseFloat(lowerLimit) && (parseFloat(this.userEnteredEMI) <= parseFloat(upperLimit))) && (this.attempt > 2)) {
            this.attempt++;
            this.showModalEMI = true;
            this.showCancelBtn = true;
            this.modalMsgEMI = 'Please Recheck and Re-enter the amount';
        } else if ((parseFloat(this.userEnteredEMI) >=  parseFloat(lowerLimit) && (parseFloat(this.userEnteredEMI) <= parseFloat(upperLimit)))) {
            this.showModalEMI = false;
            this.showCancelBtn = false;
            this.modalMsgEMI = null;            
            emiEntered[rowId].disabled = true;
            validBtnId[rowId].disabled = true;
            this.existingEMIList[rowId]['emi'] = this.userEnteredEMI;
            this.higherEMIFlag = false;
            this.attempt=0;
            this.updateEMIValue(tableData.existing_emi_id, this.userEnteredEMI);
        } else if(upperLimit==='' || upperLimit=== null || upperLimit=== undefined || lowerLimit==='' || lowerLimit===null || lowerLimit=== undefined){
            this.showToastMessage('Warning','As Run EMI Engine gave negative response, no range to compare EMI value','warning');
        }
    }

    saveValidatedEMIData() {
        this.showSpinner=true;
        
        saveEMIDetails({ emiData: JSON.stringify(this.existingEMIList), applicantId: this.applicantId }).then(response => {
            let k=0;
            let custObj

            for (var i = 0; i < response.length; i++) {
                custObj = {
                    ...{ 'Id': k },
                    ...{ 'Loan_Type': response[i].Loan_Type__c },
                    ...{ 'Outstanding_Amount': response[i].Outstanding_Amount__c },
                    ...{ 'Sequential_Number': 'Loan ' + (parseInt(k+1) ) },
                    ...{ 'upper_LimitEMI': response[i].Upper_EMI_Limit__c },
                    ...{ 'lower_LimitEMI': response[i].Lower_EMI_Limit__c },
                    ...{ 'emi': '' },
                    ...{ 'existing_emi_id': response[i].Id}
                };
                this.loanRecordsArray.push(custObj);
                k++;
            }

            this.existingEMIList = this.loanRecordsArray;
            this.showSpinner=false;
        }).catch(error => {
            this.showToastMessage('', 'Something Went Wrong!', 'Error');
            console.log('getEMIExecutedValue - saveEMIDetails - Error:: ', error);
            this.showSpinner = false;
        });
    }

    updateEMIValue(existingEMIid, enteredEMIValue){
        const fields = {};
        fields[EXISTING_EMI_ID_FIELD.fieldApiName] = existingEMIid;
        fields[EMI_AMOUNT_FIELD.fieldApiName] = enteredEMIValue;
        const recordInput = {fields};
        
        updateRecord(recordInput).then(() => {
            this.showToastMessage('','EMI Amount Updated Successfully','success');
        }).catch(error => {
            console.log('Error in updating EMI Amount:: ', error);
            this.showToastMessage('', 'Error in saving Existing EMI details', 'Error');
            return;
        });
    }

    docUploadSuccessfully(event) {    
        if (event.detail) {
            this.disableCaptureBankStatement = true;
            this.showCheckedTickForDocUpload = true;
        }
    }

    handleCaptureBankStatement() {
        if(!this.isBankAccountPresent){
            this.showToastMessage('Warning','Applicant do not have any bank account!', 'warning');
        } else {
            this.showSpinner = true;
            this.docType='Customer Bank Statement';

            // if(FORM_FACTOR==='Large'){
                createOtherDocument({ docType: this.label.Customer_Bank_Statement, applicantId: this.applicantId, loanApplicationId: this.recordId }).then(result => {
                    this.documentRecordId = result;
                    this.docType = this.label.Customer_Bank_Statement;
                    this.showUpload = true;
                    this.showDocView = false;
                    this.isVehicleDoc = true;
                    this.isAllDocType = false;
                    this.uploadViewDocFlag = true;
                    this.showSpinner = false;
                }).catch(error => {
                    this.error = error;
                    this.showSpinner = false;
                    console.log('Create Other Document:: ', error);
                });
            // } else if(FORM_FACTOR !='Large'){
                //     fetchDocument({ applicantId: this.applicantId, docType: this.docType }).then(result => {
                    //         if(result===null){
                        // this.documentRecordId = result;
                        // this.showSpinner = false;
                        // this.docType = this.label.Customer_Bank_Statement;
                        // this.showUpload = true;
                        // this.showDocView = false;
                        // this.isVehicleDoc = true;
                        // this.isAllDocType = false;
                        // this.uploadViewDocFlag = true;
                    // }
                // }).catch(error => {
                    //     this.error = error;
                    //     this.showSpinner = false;
                    //     console.log('Fetch Document:: ', error);
                // });
            // }
        }
    }

    changeflagvalue() {
        this.uploadViewDocFlag = false;

        // if(FORM_FACTOR!='Large'){
            checkImageExist({ applicantId: this.applicantId , documentType: this.label.Customer_Bank_Statement }).then(response => {
                if(response===false){
                    this.showToast('','Document Upload Fail','warning');
                }else if(response===true){
                    this.disableCaptureBankStatement = true;
                    this.showCheckedTickForDocUpload = true;
                    this.showToast('Success',this.docType + ' Document captured successfully', 'success');
                }
            }).catch(error => {
                console.log('checkImagePresent error:',error);
            });
        // }
    }

    handleModalCancelAction() {
        this.showModalEMI = false;
        this.showCancelBtn = false;
        this.modalMsgEMI = null;
    }

    handleModalOkAction() {
        this.showModalEMI = false;
        this.showCancelBtn = false;
        this.modalMsgEMI = null;

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

    //Switch tabs if Existing EMI details not submitted
    async validateExistingEMISubmitStatus() {
        let isValidForSumbit = false;//CISP-3184
        await getExistingEMISubmittedValue({ loanApplicationId: this.recordId}).then(result => {
            console.log('getExistingEMISubmittedValue - result:: ',result);

            let applicantRecordDetails = result?.applicantRecordDetails;
            
            for(let i=0 ; i<applicantRecordDetails.length; i++){
                //If Co-Borrower is earning and Existing EMI details not submitted then switch to Co-Borrower tab
                if( this.activeTab === 'Borrower' && applicantRecordDetails[i].Applicant_Type__c === 'Co-borrower' && applicantRecordDetails[i].Is_Existing_EMI_Submitted__c === false){
                    this.dispatchEvent(new CustomEvent('changetocoborrower', { bubbles: true, composed: true }));
                    this.showToastMessage('', 'Update Co-Borrowers Existing EMI Details', 'info');
                    isValidForSumbit = false;
                    break;
                } else if(this.activeTab === 'Co-borrower' && applicantRecordDetails[i].Applicant_Type__c === 'Borrower' && applicantRecordDetails[i].Is_Existing_EMI_Submitted__c === false){
                    //If Borrower's Existing EMI details not submitted then display alert
                    this.showToastMessage('', 'Submit Existing EMI Details for Borrower', 'warning');
                    isValidForSumbit = false;
                    break;//CISP-3184-START
                }else if(applicantRecordDetails[i].Applicant_Type__c === 'Borrower' && applicantRecordDetails[i].Is_Existing_EMI_Submitted__c === false){
                    this.showToastMessage('', 'Submit Existing EMI Details for Borrower', 'warning');
                    isValidForSumbit = false;
                    break;
                }else if(applicantRecordDetails[i].Applicant_Type__c === 'Co-borrower' && applicantRecordDetails[i].Is_Existing_EMI_Submitted__c === false){
                    this.dispatchEvent(new CustomEvent('changetocoborrower', { bubbles: true, composed: true }));
                    this.showToastMessage('', 'Update Co-Borrowers Existing EMI Details', 'info');
                    isValidForSumbit = false;
                    break;
                }else if(applicantRecordDetails[i].Is_Existing_EMI_Submitted__c === false){
                    this.showToastMessage('', `Update ${applicantRecordDetails[i].Applicant_Type__c} Existing EMI Details`, 'info');
                    isValidForSumbit = false;
                    break;
                }else{
                    isValidForSumbit = true;
                }//CISP-3184-END
            }
        }).catch(error => {
            console.log('getExistingEMISubmittedValue - error:: ', error);
        });
        return isValidForSumbit;
    }

    async navigateToNextModule(){
        const fields = {};
        fields[OPP_ID_FIELD.fieldApiName] = this.recordId;
        fields[STAGENAME.fieldApiName] = 'Final Terms';
        fields[LAST_STAGE_NAME.fieldApiName] = 'Final Terms';

        const recordInput = { fields };

        await updateRecord(recordInput).then(() => {
            console.log('Opportunity Record Updated Successfully:: ', JSON.stringify(fields));
            this.isExistingEMISubmitted = true;
            this.callLoanApplicationHistory('Final Terms');
        }).catch(error => {
            console.log('Error in updating reocrd:: ', error);
            this.showToastMessage(null, 'Error in saving details', 'Error');
            return;
        });
    }
    
    //M4 change
    callLoanApplicationHistory(nextStage){
        getLoanApplicationHistory({ loanId: this.recordId, stage: 'Income Details',nextStage: nextStage}).then(response => {
            console.log('getLoanApplicationHistory Response:: ', response);
            if(response){ 
                this.navigateToHomePage();
            } else{
                this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage, bubbles: true, composed: true }));
            }
        }).catch(error => {
            console.log('Error in getLoanApplicationHistory:: ', error);
        });
    }

    async callAccessLoanApplication(){
        await accessLoanApplication({ loanId: this.recordId , stage: 'Income Details'}).then(response => {
            console.log('accessLoanApplication Response:: ', response);
            if(!response){ 
                this.disableEverything();
                console.log('here 2');
                if(this.checkleadaccess){
                    const evt = new ShowToastEvent({
                        title: ReadOnlyLeadAccess,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    console.log('from tab loan');
                    this.disableEverything();
                }
            }
        }).catch(error => {
            console.log('Error in accessLoanApplication:: ', error);
        });
    }
    //M4 change end

    navigateToHomePage() {
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
            console.log('navigateToHomePage - Error:: ', error);
        });
    }

    async executeEPFOUANLookupAPI() {
        let executionStatus = {'isAPISucessful':'false','message':'EPFO UAN Lookup API Failed'};
        
        //EPFO - 1. EPFO UAN Lookup API to get UAN Number
        this.showToastMessage('', 'EPFO UAN Lookup and authorization initiated', 'info');
        console.log('Applicant ID - EPFO API:: ', this.applicantId);

        await doEPFUANLookupCallout({ applicantId: this.applicantId, loanAppId: this.recordId }).then(result => {
            console.log('doEPFUANLookupCallout result : ',result);
            const obj = JSON.parse(result);
            
            try{
                var responseData = obj?.ResponseData?.Fields?.Applicants?.Applicant?.Services?.Service[0]?.Operations?.Operation[0]?.Data?.Response?.RawResponse;
                
                responseData = responseData.replace('uan-lookup', 'uanlookup');
                const parsedRespData = JSON.parse(responseData);

                console.log('doEPFUANLookupCallout - parsedRespData:: ', parsedRespData);

                if(parsedRespData?.result?.uanlookup?.result?.uan[0] !== null){
                    this.uanNumber = parsedRespData?.result?.uanlookup?.result?.uan[0];
                    executionStatus.isAPISucessful = true;
                    executionStatus.message = 'Successfully Generated UAN No. - '+ this.uanNumber;
                }
                if(parsedRespData?.result?.uanlookup?.result === {}){
                    executionStatus.isAPISucessful = false;
                    executionStatus.message = 'EPFO UAN not Generated';
                } else {
                    executionStatus.isAPISucessful = false;
                    executionStatus.message = 'Error in reading EPFO API Response';
                }
            } catch(error){
                console.log('doEPFUANLookupCallout - Response Reading Error:: ', error);
                executionStatus.isAPISucessful = false;
                executionStatus.message = 'EPFO UAN Lookup Response Error';
            }
        }).catch(error => {
            console.log('doEPFUANLookupCallout - Error:: ', error);
            executionStatus.isAPISucessful = false;
            executionStatus.message = error;
        });

        return executionStatus;
    }

    async executeEPFOAuthAPI() {
        let executionStatus = {'isAPISucessful':'false','message':'EPFO UAN Authorization API Failed'};
        console.log('Check UAN Number ::',this.uanNumber);
        //EPFO - 2. EPFO Auth API to validate UAN Number
        await doEPFOAuthCallout({ applicantId: this.applicantId, uanNumber: this.uanNumber, loanAppId: this.recordId }).then(result => {
            console.log('doEPFOAuthCallout Result :',result);
            this.showToastMessage('Success', 'EPFO Authentication successfully done !', 'success');
            const obj = JSON.parse(result);
            let responseData = obj?.ResponseData?.Fields?.Applicants?.Applicant?.Services?.Service[0]?.Operations?.Operation[0]?.Data?.Response?.RawResponse;

            responseData = responseData.replace('epf-auth', 'epfauth');
            const parsedRespData = JSON.parse(responseData);

            this.employerName = parsedRespData?.result?.epfauth?.result?.summary?.lastEmployer?.employerName;
            this.employeeName = parsedRespData?.result?.epfauth?.result?.personalDetails.name;
            this.startDate = parsedRespData?.result?.epfauth?.result?.summary?.lastEmployer?.startMonthYear;
            this.toDate = parsedRespData?.result?.epfauth?.result?.summary?.lastEmployer?.lastMonthYear;
        }).catch(error => {
            console.log('doEPFUANLookupCallout API Fail:: ', error);
            executionStatus.isAPISucessful = false;
            executionStatus.message = error;
        });

        return executionStatus;
    }

    async executeScorecardAPI() {
        let executionStatus = {'isAPISucessful':'false','message':'Scorecard API Failed'};

        await doBREscorecardCallout({ 'applicantId': this.applicantId , 'loanAppId': this.recordId}).then(result => {
            console.log('doBREscorecardCallout - result:: ',result);
            const res = JSON.parse(result);

            this.scoreCardDescription = res.BRE_Decision_Desc;
            this.scorecardDecision = res.BRE_Decision;

            executionStatus.isAPISucessful = true;
            executionStatus.message = 'Score Card Decision - '+ this.scorecardDecision;
        }).catch(error => {
            console.log('doBREscorecardCallout - error:: ', error);
            executionStatus.isAPISucessful = false;
            executionStatus.message = error;
        });

        return executionStatus;
    }

    isExecuteScoreCardAPISuccess;//CISP-3054
    disableRentalExpense=false;disableOtherObligation=false;monthlyIncome=0;@track rentalExpense=0;otherObligation=0;netMonthlyIncome=0;foirPercent;totalEmiObligation=0;showFoir=false;
    handleRentalExpenseChange(event){
        this.rentalExpense = this.roundOff(event.target.value);
        event.target.value = this.rentalExpense;
       // this.netMonthlyIncome =  this.roundOff(this.monthlyIncome) -(this.roundOff(this.rentalExpense)+this.roundOff(this.otherObligation)+this.roundOff(this.totalEmiObligation));
    }
    handleOtherObligationChange(event){
        this.otherObligation = this.roundOff(event.target.value);
        event.target.value = this.otherObligation;
        //this.netMonthlyIncome = (this.roundOff(this.monthlyIncome)-(this.roundOff(this.rentalExpense)+this.otherObligation)).toFixed(2);
       // this.netMonthlyIncome =  this.roundOff(this.monthlyIncome) -(this.roundOff(this.rentalExpense)+this.roundOff(this.otherObligation)+this.roundOff(this.totalEmiObligation));
    }

    roundOff(inputParam) {
        if (inputParam === null || inputParam === undefined || inputParam === '' || inputParam === NaN) {
            return 0;
        } else {
            return Math.round(inputParam);
        }
    }

    async handleSubmit() {
        this.showSpinner = true;
        let allowSubmitActions = false;
        await validateExistingEMISubmitAction({ applicantId: this.applicantId }).then(result => {
            console.log('validateExistingEMISubmitAction - Result:: ', result);

            if(result?.allowed === 'false'){
                this.showToastMessage('', result?.message, 'warning');
                this.showSpinner = false;
            } else {
                allowSubmitActions = true;
            }
        }).catch(error => {
            console.log('validateExistingEMISubmitAction - Error:: ', error);
            this.showToastMessage('Error in validating Existing EMI details', error, 'warning');
            this.showSpinner = false;
        });
        if((this.leadSource=='OLA' || this.leadSource=='Hero') && allowSubmitActions){//Hero CISH-11
            this.navigateToNextModule();
        } else if(allowSubmitActions){
            //Execute Scorecard
            this.isExecuteScoreCardAPISuccess = false;//CISP-3054
            //SFTRAC-121 Starts
            if(this.isTractor){
                this.isExecuteScoreCardAPISuccess = true; 
                if(this.showDeclarationContent){//SFTRAC-1791
                            if(this.currentApplicantType != 'Borrower')
                            {
                                if(this.isCoBorrowerRelativeOfDirectorAnswer == null || this.isCoBorrowerRelativeOfDirectorAnswer == undefined || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == null || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == undefined)
                                {
                                    this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                    return;
                                }
                                if(this.isCoBorrowerRelativeOfDirectorAnswer == 'Yes')
                                {
                                    if(this.IsRelationshipWithIndusIndOrOtherBank == null || this.IsRelationshipWithIndusIndOrOtherBank == undefined)
                                    {
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    else if(this.IsRelationshipWithIndusIndOrOtherBank == 'IndusInd Bank' && (this.CoBorrowerRelationWithIndusIndQuestion1Answer == null || this.CoBorrowerRelationWithIndusIndQuestion1Answer == undefined || this.CoBorrowerRelationWithIndusIndQuestion2Answer == null || this.CoBorrowerRelationWithIndusIndQuestion2Answer == undefined))
                                    {
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    else if(this.IsRelationshipWithIndusIndOrOtherBank == 'Other Bank' && (this.CoBorrowerRelationWithOtherBankQuestion1Answer == null || this.CoBorrowerRelationWithOtherBankQuestion1Answer == undefined || this.CoBorrowerRelationWithOtherBankQuestion2Answer == null || this.CoBorrowerRelationWithOtherBankQuestion2Answer == undefined))
                                    {
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    if(this.CoBorrowerRelationWithIndusIndQuestion2Answer == 'OTHERS' || this.CoBorrowerRelationWithOtherBankQuestion2Answer == 'OTHERS')
                                    {
                                        if(this.CoBorrowerDirectorSpecificRelation == null || this.CoBorrowerDirectorSpecificRelation == undefined)
                                            {
                                                this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                                return;
                                            }
                                    }
                                }
                                if(this.isCoBorrowerRelativeOfSeniorOfficerAnswer == 'Yes')
                                {
                                    if(this.IsSORelationshipWithIndusIndOrOtherBank == null || this.IsSORelationshipWithIndusIndOrOtherBank == undefined)
                                    {
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    else if(this.IsSORelationshipWithIndusIndOrOtherBank == 'IndusInd Bank' && (this.SOCoBorrowerRelationWithIndusIndQuestion1Answer == null || this.SOCoBorrowerRelationWithIndusIndQuestion1Answer == undefined || this.SOCoBorrowerRelationWithIndusIndQuestion2Answer == null || this.SOCoBorrowerRelationWithIndusIndQuestion2Answer == undefined))
                                    {
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    else if(this.IsSORelationshipWithIndusIndOrOtherBank == 'Other Bank' && (this.SOCoBorrowerRelationWithOtherBankQuestion1Answer == null || this.SOCoBorrowerRelationWithOtherBankQuestion1Answer == undefined || this.SOCoBorrowerRelationWithOtherBankQuestion2Answer == null || this.SOCoBorrowerRelationWithOtherBankQuestion2Answer == undefined))
                                    {
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    if(this.SOCoBorrowerRelationWithIndusIndQuestion2Answer == 'OTHERS' || this.SOCoBorrowerRelationWithOtherBankQuestion2Answer == 'OTHERS')
                                        {
                                            if(this.CoBorrowerSOSpecificRelation == null || this.CoBorrowerSOSpecificRelation == undefined)
                                                {
                                                    this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                                    return;
                                                }
                                        }
                                }
                            }
                        else
                        {
                            if(this.leadSource != 'D2C')
                            {
                                if(this.isBorrowerRelativeOfDirectorAnswer == null || this.isBorrowerRelativeOfDirectorAnswer == undefined || this.isBorrowerRelativeOfSeniorOfficerAnswer == null || this.isBorrowerRelativeOfSeniorOfficerAnswer == undefined)
                                {
                                    console.log('in 1 if');
                                    this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                    return;
                                }
                                if(this.isBorrowerRelativeOfDirectorAnswer == 'Yes')
                                {
                                    if(this.IsRelationshipWithIndusIndOrOtherBank == null || this.IsRelationshipWithIndusIndOrOtherBank == undefined)
                                        {
                                            console.log('in 2 if');
                                            this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                            return;
                                        }
                                    else if(this.IsRelationshipWithIndusIndOrOtherBank == 'IndusInd Bank' && (this.BorrowerRelationWithIndusIndQuestion1Answer == null || this.BorrowerRelationWithIndusIndQuestion1Answer == undefined || this.BorrowerRelationWithIndusIndQuestion2Answer == null || this.BorrowerRelationWithIndusIndQuestion2Answer == undefined))
                                    {
                                        console.log('in 3 if');
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    else if(this.IsRelationshipWithIndusIndOrOtherBank == 'Other Bank' && (this.BorrowerRelationWithOtherBankQuestion1Answer == null || this.BorrowerRelationWithOtherBankQuestion1Answer == undefined || this.BorrowerRelationWithOtherBankQuestion2Answer == null || this.BorrowerRelationWithOtherBankQuestion2Answer == undefined))
                                    {
                                        console.log('in 4 if');
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    if(this.BorrowerRelationWithIndusIndQuestion2Answer == 'OTHERS' || this.BorrowerRelationWithOtherBankQuestion2Answer == 'OTHERS')
                                        {
                                            if(this.BorrowerDirectorSpecificRelation == null || this.BorrowerDirectorSpecificRelation == undefined)
                                                {
                                                    console.log('in 5 if');
                                                    this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                                    return;
                                                }
                                        }
                                }
                                if(this.isBorrowerRelativeOfSeniorOfficerAnswer == 'Yes')
                                {
                                    if(this.IsSORelationshipWithIndusIndOrOtherBank == null || this.IsSORelationshipWithIndusIndOrOtherBank == undefined)
                                    {
                                        console.log('in 6 if');
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    else if(this.IsSORelationshipWithIndusIndOrOtherBank == 'IndusInd Bank' && (this.SOBorrowerRelationWithIndusIndQuestion1Answer == null || this.SOBorrowerRelationWithIndusIndQuestion1Answer == undefined || this.SOBorrowerRelationWithIndusIndQuestion2Answer == null || this.SOBorrowerRelationWithIndusIndQuestion2Answer == undefined))
                                    {
                                        console.log('in 7 if');
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    else if(this.IsSORelationshipWithIndusIndOrOtherBank == 'Other Bank' && (this.SOBorrowerRelationWithOtherBankQuestion1Answer == null || this.SOBorrowerRelationWithOtherBankQuestion1Answer == undefined || this.SOBorrowerRelationWithOtherBankQuestion2Answer == null || this.SOBorrowerRelationWithOtherBankQuestion2Answer == undefined))
                                    {
                                        console.log('in 8 if');
                                        this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                        return;
                                    }
                                    if(this.SOBorrowerRelationWithIndusIndQuestion2Answer == 'OTHERS' || this.SOBorrowerRelationWithOtherBankQuestion2Answer == 'OTHERS')
                                        {
                                            if(this.BorrowerSOSpecificRelation == null || this.BorrowerSOSpecificRelation == undefined)
                                                {
                                                    console.log('in 9 if');
                                                    this.showToastMessage('', 'Please complete declaration content', 'error');this.showSpinner = false;
                                                    return;
                                                }
                                        }
                                }
                            }
                        }
                    
                }
    
                //Update API Fields
                const fields = {};
                fields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    
                if(this.isTractor && !this.isNonIndividual){
                    fields[Profile_FIELD.fieldApiName] = 'AGRICULTURIST';
                }
    
                if(this.isExecuteScoreCardAPISuccess){//CISP-3054
                    fields[IS_EXISTING_EMI_SUBMITTED_FIELD.fieldApiName] = true;
                }
    
                //EPFO Fields
                if(this.uanNumber){
                    fields[UAN_NUMBER_FIELD.fieldApiName] = this.uanNumber;
                    fields[EMPLOYER_NAME_FIELD.fieldApiName] = this.employerName;
                    fields[EMPLOYEE_NAME_FIELD.fieldApiName] = this.employeeName;
                    fields[START_DATE_FIELD.fieldApiName] = this.startDate;
                    fields[END_DATE_FIELD.fieldApiName] = this.toDate;
                }
    
                const recordInput = { fields };
                console.log('Update fields:: ', recordInput);
    
                await updateRecord(recordInput).then(() => {
                    console.log('Applicant Record Updated Successfully:: ', JSON.stringify(fields));
                }).catch(error => {
                    console.log('Error in updating reocrd:: ', error);
                    this.showToastMessage(null, 'Error in saving Existing EMI details', 'Error');
                    this.showSpinner = false;
                });
    
                //Validation whether Submit Allowed or not and Navigate accordingly
                await this.validateExistingEMISubmitStatus().then(result => {
                    console.log('validateExistingEMISubmitStatus - Result:: ', result);
    
                    if(result && this.isExecuteScoreCardAPISuccess){//CISP-3054
                        this.navigateToNextModule();//CISP-3184-START
                    }//CISP-3184-END
                }).catch(error => {
                    console.log('validateExistingEMISubmitStatus - Error:: ', error);
                    this.showToastMessage('Error in Submitting the Existing EMI Details', error, 'error');
                    this.showSpinner = false;
                });
    
                if(!this.isExecuteScoreCardAPISuccess){//CISP-3054
                    this.isExistingEMISubmitted = false;
                }else{
                    this.isExistingEMISubmitted = true;
                }
                this.showSpinner = false;
            }else{//SFTRAC-121 Ends
            await this.executeScorecardAPI().then(result => {
                console.log('ExecuteScorecardAPI - Result:: ', result);

                if(result?.isAPISucessful){
                    this.isExecuteScoreCardAPISuccess = true;//CISP-3054
                    this.showToastMessage('Scorecard details fetched successfully', result?.message, 'success');
                } else {
                    this.isExecuteScoreCardAPISuccess = false;//CISP-3054
                    this.showToastMessage('Error in executing Scorecard API', result?.message?.body?.message, 'warning');
                }
            }).catch(error => {
                this.isExecuteScoreCardAPISuccess = false;//CISP-3054
                console.log('ExecuteScorecardAPI - Error:: ', error);
                this.showToastMessage('Error in executing Scorecard API', error, 'warning');
                this.showSpinner = false;
            });   

            //Execute EPFO Lookup API
            await this.executeEPFOUANLookupAPI().then(result => {
                console.log('ExecuteEPFOUANLookupAPI - Result:: ', result);

                if(result?.isAPISucessful){
                    this.showToastMessage('EPFO UAN Lookup is succeeded and Submit for Authorization', result?.message, 'success');
                } else {
                    this.showToastMessage('EPFO UAN Lookup is failed', result?.message, 'warning');
                }
            }).catch(error => {
                console.log('ExecuteEPFOUANLookupAPI - Error:: ', error);
                this.showToastMessage('Error in executing EPFO UAN Lookup API', error, 'warning');
                this.showSpinner = false;
            });

            //Execute EPFO Authorization API
            if(this.uanNumber){
                await this.executeEPFOAuthAPI().then(result => {
                    console.log('executeEPFOAuthAPI - Result:: ', result);
        
                    if(result?.isAPISucessful){
                        this.showToastMessage('EPFO UAN Authorization is succeessful', result?.message, 'success');
                    } else {
                        this.showToastMessage('EPFO UAN Authorization is failed', result?.message, 'warning');
                    }
                }).catch(error => {
                    console.log('executeEPFOAuthAPI - Error:: ', error);
                    this.showToastMessage('Error in executing EPFO UAN Authorization API', error, 'warning');
                    this.showSpinner = false;
                });
            }

            //Update API Fields
            const fields = {};
            fields[APP_ID_FIELD.fieldApiName] = this.applicantId;
            this.rentalExpense = this.roundOff(this.rentalExpense);
            this.otherObligation = this.roundOff(this.otherObligation);
            if(this.isPvProduct){
                fields[OTHER_OBLIGATION.fieldApiName] = this.otherObligation;
                fields[RENTAL_OBLIGATION.fieldApiName] = this.rentalExpense;
            }
            if(this.isExecuteScoreCardAPISuccess){//CISP-3054
                fields[IS_EXISTING_EMI_SUBMITTED_FIELD.fieldApiName] = true;
            }

            //ScoreCard Fields
            if(this.scorecardDecision && this.scoreCardDescription){
                fields[SCORE_CARD_DECISION_FIELD.fieldApiName] = this.scorecardDecision;
                fields[SCORE_CARD_DESC_FIELD.fieldApiName] = this.scoreCardDescription;
            }

            //EPFO Fields
            if(this.uanNumber){
                fields[UAN_NUMBER_FIELD.fieldApiName] = this.uanNumber;
                fields[EMPLOYER_NAME_FIELD.fieldApiName] = this.employerName;
                fields[EMPLOYEE_NAME_FIELD.fieldApiName] = this.employeeName;
                fields[START_DATE_FIELD.fieldApiName] = this.startDate;
                fields[END_DATE_FIELD.fieldApiName] = this.toDate;
            }

            const recordInput = { fields };
            console.log('Update fields:: ', recordInput);

            await updateRecord(recordInput).then(() => {
                console.log('Applicant Record Updated Successfully:: ', JSON.stringify(fields));
            }).catch(error => {
                console.log('Error in updating reocrd:: ', error);
                this.showToastMessage(null, 'Error in saving Existing EMI details', 'Error');
                this.showSpinner = false;
            });

            //Validation whether Submit Allowed or not and Navigate accordingly
            await this.validateExistingEMISubmitStatus().then(result => {
                console.log('validateExistingEMISubmitStatus - Result:: ', result);

                if(result && this.isExecuteScoreCardAPISuccess){//CISP-3054
                    this.navigateToNextModule();//CISP-3184-START
                }//CISP-3184-END
            }).catch(error => {
                console.log('validateExistingEMISubmitStatus - Error:: ', error);
                this.showToastMessage('Error in Submitting the Existing EMI Details', error, 'error');
                this.showSpinner = false;
            });

            if(!this.isExecuteScoreCardAPISuccess){//CISP-3054
                this.isExistingEMISubmitted = false;
            }else{
                this.isExistingEMISubmitted = true;
            }
            this.showSpinner = false;
            }
        }
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    isCoBorrowerRelativeOfDirectorAnswer;IsRelationshipWithIndusIndOrOtherBank;@track isBorrowerChosenOtherBank;@track isBorrowerChosenIndusInd;
    @track isCoBorrowerChosenIndusInd;@track isCoBorrowerChosenOtherBank;IsSORelationshipWithIndusIndOrOtherBank;@track isSOBorrowerChosenOtherBank;
    @track isSOBorrowerChosenIndusInd;@track isSOCoBorrowerChosenIndusInd;@track isSOCoBorrowerChosenOtherBank;CoBorrowerRelationWithIndusIndQuestion1Answer;
    SOCoBorrowerRelationWithIndusIndQuestion1Answer;

    @track isCoBorrowerOptedYes;
    handleCoBorrowerRelativeOfDirector(event)
    {
        this.isCoBorrowerRelativeOfDirectorAnswer = event.target.value;
        if(event.target.value == 'Yes')
        this.isCoBorrowerOptedYes = true;
        else
        {this.isCoBorrowerOptedYes = false;}
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        applicantsFields[COBORROWER_RELATIVE_OF_DIRECTOR.fieldApiName] = event.target.value;
        this.updateRecordDetails(applicantsFields);
    }
    handleRelationWithIndusIndOrOther(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'relationshipWithBankRadioGroup1' || event.target.name == 'relationshipWithBankRadioGroup2' || event.target.name == 'relationshipWithBankRadioGroup3' || event.target.name == 'relationshipWithBankRadioGroup4')
        {
        this.IsRelationshipWithIndusIndOrOtherBank = event.target.value;
        if(!this.isCoBorrowerExist)
        {
            if(event.target.value == 'IndusInd Bank')
            {
                this.isBorrowerChosenOtherBank = false;
                this.isBorrowerChosenIndusInd = true;
            }
            else
            {
                this.isBorrowerChosenIndusInd = false;
                this.isBorrowerChosenOtherBank = true;
            }        
        }
        else
        {
            if(event.target.value == 'IndusInd Bank')
            {
                this.isCoBorrowerChosenIndusInd = true;
                this.isCoBorrowerChosenOtherBank = false;
            }
            else
            {
                this.isCoBorrowerChosenIndusInd = false;
                this.isCoBorrowerChosenOtherBank = true;
            }      
        }
        applicantsFields[RELATION_WITH_INDUSIND_OR_OTHER.fieldApiName] = event.target.value;
    }
    else
    {
        this.IsSORelationshipWithIndusIndOrOtherBank = event.target.value;
        if(!this.isCoBorrowerExist)
        {
            if(event.target.value == 'IndusInd Bank')
            {
                this.isSOBorrowerChosenOtherBank = false;
                this.isSOBorrowerChosenIndusInd = true;
            }
            else
            {
                this.isSOBorrowerChosenIndusInd = false;
                this.isSOBorrowerChosenOtherBank = true;
            }        
        }
        else
        {
            if(event.target.value == 'IndusInd Bank')
            {
                this.isSOCoBorrowerChosenIndusInd = true;
                this.isSOCoBorrowerChosenOtherBank = false;
            }
            else
            {
                this.isSOCoBorrowerChosenIndusInd = false;
                this.isSOCoBorrowerChosenOtherBank = true;
            }      
        }
        applicantsFields[SO_RELATIONSHIP_WITH_INDUSIND_OR_OTHER.fieldApiName] = event.target.value;
    }
    this.updateRecordDetails(applicantsFields);
    }
    CoBorrowerRelationWithOtherBankQuestion1Answer;CoBorrowerRelationWithOtherBankQuestion2Answer;CoBorrowerDirectorSpecificRelation;
    SOCoBorrowerRelationWithOtherBankQuestion1Answer;SOCoBorrowerRelationWithOtherBankQuestion2Answer;CoBorrowerSOSpecificRelation;
    CoBorrowerRelationWithIndusIndQuestion2Answer;@track coborrowerDirectorChoseOthers;SOCoBorrowerRelationWithIndusIndQuestion2Answer;@track coborrowerSOChoseOthers;
    isCoBorrowerRelativeOfSeniorOfficerAnswer;@track isCoBorrowerOptedYesForSO;@track borrowerDirectorChoseOthers;BorrowerSOSpecificRelation;@track borrowerSOChoseOthers
    handleCoBorrowerIndusIndQ1(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'BrRelationWithIndQ1Radio')
        {
            this.CoBorrowerRelationWithIndusIndQuestion1Answer = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            applicantsFields[COBORROWER_DIRECTOR_SPECIFIC_RELATION.fieldApiName] = null;
            this.CoBorrowerRelationWithOtherBankQuestion1Answer = null;
            this.CoBorrowerRelationWithOtherBankQuestion2Answer = null;
            this.CoBorrowerDirectorSpecificRelation = null;
            if(event.target.value == 'Yes')
            this.relationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.relationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        else
        {
            this.SOCoBorrowerRelationWithIndusIndQuestion1Answer = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_INDUSIND_Q1.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_SO_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            applicantsFields[COBORROWER_SO_SPECIFIC_RELATION.fieldApiName] = null;
            this.SOCoBorrowerRelationWithOtherBankQuestion1Answer = null;
            this.SOCoBorrowerRelationWithOtherBankQuestion2Answer = null;
            this.CoBorrowerSOSpecificRelation = null;
            if(event.target.value == 'Yes')
            this.soRelationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.soRelationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleCoBorrowerIndusIndQ2(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'optionCoBD1')
        {
            this.CoBorrowerRelationWithIndusIndQuestion2Answer = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            applicantsFields[COBORROWER_DIRECTOR_SPECIFIC_RELATION.fieldApiName] = null;
            this.CoBorrowerRelationWithOtherBankQuestion1Answer = null;
            this.CoBorrowerRelationWithOtherBankQuestion2Answer = null;
            this.CoBorrowerDirectorSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.coborrowerDirectorChoseOthers = true;
            else
            this.coborrowerDirectorChoseOthers = false;
        }
        else
        {
            this.SOCoBorrowerRelationWithIndusIndQuestion2Answer = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_INDUSIND_Q2.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_SO_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            applicantsFields[COBORROWER_SO_SPECIFIC_RELATION.fieldApiName] = null;
            this.SOCoBorrowerRelationWithOtherBankQuestion1Answer = null;
            this.SOCoBorrowerRelationWithOtherBankQuestion2Answer = null;
            this.CoBorrowerSOSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.coborrowerSOChoseOthers = true;
            else
            this.coborrowerSOChoseOthers = false;
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleCoBSpecificRelation(event)
    {
        if(event.target.value != null)
        {
            const validateValue = (valueOfQ2) => {
                return String(valueOfQ2).toLowerCase().match(/^(?=.{3,26}$)((^[A-Za-z ]+$)\2?(?!\2))+$/);
            };
            if (validateValue(event.target.value) == null) {
                event.target.value = '';
                if(event.target.name == 'CoBDSpecificRelation')
                this.CoBorrowerDirectorSpecificRelation = '';
                else
                this.CoBorrowerSOSpecificRelation = '';
                return;
            }
        }
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'CoBDSpecificRelation')
        {
            this.CoBorrowerDirectorSpecificRelation = event.target.value;
            applicantsFields[COBORROWER_DIRECTOR_SPECIFIC_RELATION.fieldApiName] = event.target.value;
        }
        else
        {
            this.CoBorrowerSOSpecificRelation = event.target.value;
            applicantsFields[COBORROWER_SO_SPECIFIC_RELATION.fieldApiName] = event.target.value;
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleCoBorrowerOtherQ1(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'BrRelationOtherQ1Radio')
        {
            this.CoBorrowerRelationWithOtherBankQuestion1Answer = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            this.CoBorrowerRelationWithIndusIndQuestion1Answer = null;
            this.CoBorrowerRelationWithIndusIndQuestion2Answer = null;
            if(event.target.value == 'Yes')
            this.relationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.relationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        else
        {
            this.SOCoBorrowerRelationWithOtherBankQuestion1Answer = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_SO_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            this.SOCoBorrowerRelationWithIndusIndQuestion1Answer = null;
            this.SOCoBorrowerRelationWithIndusIndQuestion2Answer = null;
            if(event.target.value == 'Yes')
            this.soRelationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.soRelationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleCoBorrowerOtherQ2(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'optionCoBD2')
        {
            this.CoBorrowerRelationWithOtherBankQuestion2Answer = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            applicantsFields[COBORROWER_DIRECTOR_SPECIFIC_RELATION.fieldApiName] = null;
            this.CoBorrowerRelationWithIndusIndQuestion1Answer = null;
            this.CoBorrowerRelationWithIndusIndQuestion2Answer = null;
            this.CoBorrowerDirectorSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.coborrowerDirectorChoseOthers = true;
            else
            this.coborrowerDirectorChoseOthers = false;
        }
        else
        {
            this.SOCoBorrowerRelationWithOtherBankQuestion2Answer = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = event.target.value;
            applicantsFields[COBORROWER_SO_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[COBORROWER_SO_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            applicantsFields[COBORROWER_SO_SPECIFIC_RELATION.fieldApiName] = null;
            this.SOCoBorrowerRelationWithIndusIndQuestion1Answer = null;
            this.SOCoBorrowerRelationWithIndusIndQuestion2Answer = null;
            this.CoBorrowerSOSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.coborrowerSOChoseOthers = true;
            else
            this.coborrowerSOChoseOthers = false;
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleCoBorrowerRelativeOfSeniorOfficer(event)
    {
        this.isCoBorrowerRelativeOfSeniorOfficerAnswer = event.target.value;
        if(event.target.value == 'Yes')
        this.isCoBorrowerOptedYesForSO = true;
        else
        {this.isCoBorrowerOptedYesForSO = false;}
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        applicantsFields[COBORROWER_RELATIVE_OF_SENIOR_OFFICER.fieldApiName] = event.target.value;
        this.updateRecordDetails(applicantsFields);
    }
    isBorrowerRelativeOfDirectorAnswer;@track isBorrowerOptedYes;BorrowerRelationWithOtherBankQuestion1Answer;BorrowerRelationWithIndusIndQuestion1Answer;
    BorrowerRelationWithOtherBankQuestion2Answer;SOBorrowerRelationWithIndusIndQuestion1Answer;SOBorrowerRelationWithOtherBankQuestion1Answer;
    SOBorrowerRelationWithOtherBankQuestion2Answer;BorrowerRelationWithIndusIndQuestion2Answer;BorrowerDirectorSpecificRelation;SOBorrowerRelationWithIndusIndQuestion2Answer;
    isBorrowerRelativeOfSeniorOfficerAnswer;@track isBorrowerOptedYesForSO;
    handleBorrowerRelativeOfDirector(event)
    {
        this.isBorrowerRelativeOfDirectorAnswer = event.target.value;
        if(event.target.value == 'Yes')
        this.isBorrowerOptedYes = true;
        else
        {this.isBorrowerOptedYes = false;}
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        applicantsFields[BORROWER_RELATIVE_OF_DIRECTOR.fieldApiName] = event.target.value;
        this.updateRecordDetails(applicantsFields);
    }
    handleBorrowerIndusIndQ1(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'CoBrRelationWithIndQ1')
        {
            this.BorrowerRelationWithIndusIndQuestion1Answer = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            this.BorrowerRelationWithOtherBankQuestion1Answer = null;
            this.BorrowerRelationWithOtherBankQuestion2Answer = null;
            if(event.target.value == 'Yes')
            this.relationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.relationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        else
        {
            this.SOBorrowerRelationWithIndusIndQuestion1Answer = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_INDUSIND_Q1.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_SO_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            this.SOBorrowerRelationWithOtherBankQuestion1Answer = null;
            this.SOBorrowerRelationWithOtherBankQuestion2Answer = null;
            if(event.target.value == 'Yes')
            this.soRelationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.soRelationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleBorrowerIndusIndQ2(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'optionBoDI2')
        {
            this.BorrowerRelationWithIndusIndQuestion2Answer = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            applicantsFields[BORROWER_DIRECTOR_SPECIFIC_RELATION.fieldApiName] = null;
            this.BorrowerRelationWithOtherBankQuestion1Answer = null;
            this.BorrowerRelationWithOtherBankQuestion2Answer = null;
            this.BorrowerDirectorSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.borrowerDirectorChoseOthers = true;
            else
            this.borrowerDirectorChoseOthers = false;
        }
        else
        {
            this.SOBorrowerRelationWithIndusIndQuestion2Answer = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_INDUSIND_Q2.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_SO_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
            applicantsFields[BORROWER_SO_SPECIFIC_RELATION.fieldApiName] = null;
            this.SOBorrowerRelationWithOtherBankQuestion1Answer = null;
            this.SOBorrowerRelationWithOtherBankQuestion2Answer = null;
            this.BorrowerSOSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.borrowerSOChoseOthers = true;
            else
            this.borrowerSOChoseOthers = false;
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleBorSpecificRelation(event)
    {
        if(event.target.value != null)
        {
            const validateValue = (valueOfQ2) => {
                return String(valueOfQ2).toLowerCase().match(/^(?=.{3,26}$)((^[A-Za-z ]+$)\2?(?!\2))+$/);
            };
            if (validateValue(event.target.value) == null) {
                event.target.value = '';
                if(event.target.name == 'CoBDSpecificRelation')
                this.BorrowerDirectorSpecificRelation = '';
                else
                this.BorrowerSOSpecificRelation = '';
                return;
            }
        }
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'BorDSpecificRelation')
        {
            this.BorrowerDirectorSpecificRelation = event.target.value;
            applicantsFields[BORROWER_DIRECTOR_SPECIFIC_RELATION.fieldApiName] = event.target.value;
        }
        else
        {
            this.BorrowerSOSpecificRelation = event.target.value;
            applicantsFields[BORROWER_SO_SPECIFIC_RELATION.fieldApiName] = event.target.value;
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleBorrowerOtherQ1(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'CoBrRelationWithOtherQ1')
        {
            this.BorrowerRelationWithOtherBankQuestion1Answer = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            this.BorrowerRelationWithIndusIndQuestion1Answer = null;
            this.BorrowerRelationWithIndusIndQuestion2Answer = null;
            if(event.target.value == 'Yes')
            this.relationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.relationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        else
        {
            this.SOBorrowerRelationWithOtherBankQuestion1Answer = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_SO_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            this.SOBorrowerRelationWithIndusIndQuestion1Answer = null;
            this.SOBorrowerRelationWithIndusIndQuestion2Answer = null;
            if(event.target.value == 'Yes')
            this.soRelationshipDropdown = this.relationshipWithBorrower.data.values;
            else
            this.soRelationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleBorrowerOtherQ2(event)
    {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if(event.target.name == 'optionBorDO2')
        {
            this.BorrowerRelationWithOtherBankQuestion2Answer = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            applicantsFields[BORROWER_DIRECTOR_SPECIFIC_RELATION.fieldApiName] = null;
            this.BorrowerRelationWithIndusIndQuestion1Answer = null;
            this.BorrowerRelationWithIndusIndQuestion2Answer = null;
            this.BorrowerDirectorSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.borrowerDirectorChoseOthers = true;
            else
            this.borrowerDirectorChoseOthers = false;
        }
        else{
            this.SOBorrowerRelationWithOtherBankQuestion2Answer = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = event.target.value;
            applicantsFields[BORROWER_SO_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
            applicantsFields[BORROWER_SO_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
            applicantsFields[BORROWER_SO_SPECIFIC_RELATION.fieldApiName] = null;
            this.SOBorrowerRelationWithIndusIndQuestion1Answer = null;
            this.SOBorrowerRelationWithIndusIndQuestion2Answer = null;
            this.BorrowerSOSpecificRelation = null;
            if(event.target.value == 'OTHERS')
            this.borrowerSOChoseOthers = true;
            else
            this.borrowerSOChoseOthers = false;
        }
        this.updateRecordDetails(applicantsFields);
    }
    handleBorrowerReletiveOfSeniorOfficer(event)
    {
        this.isBorrowerRelativeOfSeniorOfficerAnswer = event.target.value;
        if(event.target.value == 'Yes')
        this.isBorrowerOptedYesForSO = true;
        else
        {this.isBorrowerOptedYesForSO = false;
        }
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        applicantsFields[BORROWER_RELATIVE_OF_SENIOR_OFFICER.fieldApiName] = event.target.value;
        this.updateRecordDetails(applicantsFields);
    }
    async doGetApplicantRelationshipWithBank(){
        await getApplicantRelationshipWithBank({applicantId : this.applicantId}).then(result =>{
            if(result)
            {
                this.isBorrowerRelativeOfDirectorAnswer = result.Is_Borrower_Relative_Of_Director__c;
                this.isBorrowerRelativeOfSeniorOfficerAnswer = result.Is_Borrower_Relative_Of_Senior_Officer__c;
                this.isCoBorrowerRelativeOfDirectorAnswer = result.Is_CoBorrower_Relative_Of_Director__c;
                this.isCoBorrowerRelativeOfSeniorOfficerAnswer = result.Is_CoBorrower_Relative_Of_Senior_Officer__c;
                this.IsRelationshipWithIndusIndOrOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c;
                this.BorrowerRelationWithIndusIndQuestion1Answer = result.Borrower_Relation_With_IndusInd_Q1__c;
                this.BorrowerRelationWithIndusIndQuestion2Answer = result.Borrower_Relation_With_IndusInd_Q2__c;
                this.BorrowerRelationWithOtherBankQuestion1Answer = result.Borrower_Relation_With_Other_Bank_Q1__c;
                this.BorrowerRelationWithOtherBankQuestion2Answer = result.Borrower_Relation_With_Other_Bank_Q2__c;
                this.CoBorrowerRelationWithIndusIndQuestion1Answer = result.CoBorrower_Relation_With_IndusInd_Q1__c;
                this.CoBorrowerRelationWithIndusIndQuestion2Answer = result.CoBorrower_Relation_With_IndusInd_Q2__c;
                this.CoBorrowerRelationWithOtherBankQuestion1Answer = result.CoBorrower_Relation_With_Other_Bank_Q1__c;
                this.CoBorrowerRelationWithOtherBankQuestion2Answer = result.CoBorrower_Relation_With_Other_Bank_Q2__c;

                this.SOBorrowerRelationWithIndusIndQuestion1Answer = result.Borrower_SO_Relation_With_IndusInd_Q1__c;
                this.SOBorrowerRelationWithIndusIndQuestion2Answer = result.Borrower_SO_Relation_With_IndusInd_Q2__c;
                this.SOBorrowerRelationWithOtherBankQuestion1Answer = result.Borrower_SO_Relation_With_Other_Bank_Q1__c;
                this.SOBorrowerRelationWithOtherBankQuestion2Answer = result.Borrower_SO_Relation_With_Other_Bank_Q2__c;
                this.SOCoBorrowerRelationWithIndusIndQuestion1Answer = result.CoBorrower_SO_Relation_With_IndusInd_Q1__c;
                this.SOCoBorrowerRelationWithIndusIndQuestion2Answer = result.CoBorrower_SO_Relation_With_IndusInd_Q2__c;
                this.SOCoBorrowerRelationWithOtherBankQuestion1Answer = result.CoBorrower_SO_Relation_With_OtherBank_Q1__c;
                this.SOCoBorrowerRelationWithOtherBankQuestion2Answer = result.CoBorrower_SO_Relation_With_OtherBank_Q2__c;
                this.BorrowerSOSpecificRelation = result.Borrower_SO_Specific_Relation__c;
                this.CoBorrowerSOSpecificRelation = result.CoBorrower_SO_Specific_Relation__c;
                this.IsSORelationshipWithIndusIndOrOtherBank = result.SO_Relationship_With_IndusInd_Or_Other__c;
                this.BorrowerDirectorSpecificRelation = result.Borrower_Director_Specific_Relation__c;
                this.CoBorrowerDirectorSpecificRelation = result.CoBorrower_Director_Specific_Relation__c;

                this.isBorrowerOptedYes = result.Is_Borrower_Relative_Of_Director__c == 'Yes' ? true : false;
                this.isBorrowerOptedYesForSO = result.Is_Borrower_Relative_Of_Senior_Officer__c == 'Yes' ? true : false; 
                this.isCoBorrowerOptedYes = result.Is_CoBorrower_Relative_Of_Director__c == 'Yes' ? true : false;
                this.isCoBorrowerOptedYesForSO = result.Is_CoBorrower_Relative_Of_Senior_Officer__c == 'Yes' ? true : false;
                this.isBorrowerChosenIndusInd = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'IndusInd Bank' ? true : false;
                this.isBorrowerChosenOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'Other Bank' ? true : false;
                this.isCoBorrowerChosenIndusInd = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'IndusInd Bank' ? true : false;
                this.isCoBorrowerChosenOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'Other Bank' ? true : false;
                this.borrowerDirectorChoseOthers = result.Borrower_Relation_With_IndusInd_Q2__c == 'OTHERS' ? true : result.Borrower_Relation_With_Other_Bank_Q2__c == 'OTHERS' ? true : false;
                this.coborrowerDirectorChoseOthers = result.CoBorrower_Relation_With_IndusInd_Q2__c == 'OTHERS' ? true : result.CoBorrower_Relation_With_Other_Bank_Q2__c == 'OTHERS' ? true : false;
                this.borrowerSOChoseOthers = result.Borrower_SO_Relation_With_IndusInd_Q2__c == 'OTHERS' ? true : result.Borrower_SO_Relation_With_Other_Bank_Q2__c == 'OTHERS' ? true : false;
                this.coborrowerSOChoseOthers = result.CoBorrower_SO_Relation_With_IndusInd_Q2__c == 'OTHERS' ? true : result.CoBorrower_SO_Relation_With_OtherBank_Q2__c == 'OTHERS' ? true : false;
                this.isSOBorrowerChosenIndusInd = result.SO_Relationship_With_IndusInd_Or_Other__c == 'IndusInd Bank' ? true : false;
                this.isSOBorrowerChosenOtherBank = result.SO_Relationship_With_IndusInd_Or_Other__c == 'Other Bank' ? true : false;
                this.isSOCoBorrowerChosenIndusInd = result.SO_Relationship_With_IndusInd_Or_Other__c == 'IndusInd Bank' ? true : false;
                this.isSOCoBorrowerChosenOtherBank = result.SO_Relationship_With_IndusInd_Or_Other__c == 'Other Bank' ? true : false;

                if(this.CoBorrowerRelationWithIndusIndQuestion1Answer == 'Yes' || this.CoBorrowerRelationWithOtherBankQuestion1Answer == 'Yes' || this.BorrowerRelationWithIndusIndQuestion1Answer == 'Yes' || this.BorrowerRelationWithOtherBankQuestion1Answer == 'Yes')
                this.relationshipDropdown = this.relationshipWithBorrower.data.values;
                else
                this.relationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
                
                if(this.SOCoBorrowerRelationWithIndusIndQuestion1Answer == 'Yes' || this.SOCoBorrowerRelationWithOtherBankQuestion1Answer == 'Yes' || this.SOBorrowerRelationWithIndusIndQuestion1Answer == 'Yes' || this.SOBorrowerRelationWithOtherBankQuestion1Answer == 'Yes')
                this.soRelationshipDropdown = this.relationshipWithBorrower.data.values;
                else
                this.soRelationshipDropdown = [{label:'Spouse', value: 'Spouse'},{label: 'Minor/Dependent child', value: 'Minor/Dependent child'}];
            }
        })
    }
}