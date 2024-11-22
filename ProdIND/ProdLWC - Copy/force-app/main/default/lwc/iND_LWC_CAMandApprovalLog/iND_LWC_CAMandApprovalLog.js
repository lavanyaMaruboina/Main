import { LightningElement, track, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { callCamRelatedAPI, updateRecordDetails,customLabels,validateLoanamount,generateDeviations,computeLIPremiumIns,checkInsSubmit,validationHelper,getParsedJSOND2C,handleTFOfferEngineCalloutHelper, journeyStopScenarioFound,roiMasterHelper,fetchFinalTermHelper,getEmiDateList,handleEmiChangeHelper,saveEMIdueDates,saveAmortDetails,createProposalLogRecord,disableInsScheduleHelper,runOfferEngineHelper} from './iND_LWC_CAMandApprovalLogHelper';
import generatecam_MTD from '@salesforce/apex/CAMApprovalLogController.generateCAM';
import updateForwardedLogs from '@salesforce/apex/ProposalStatusClass.updateForwardedLogs';
import updateLoanApplication_MTD from '@salesforce/apex/CAMApprovalLogController.updateLoanApplication';
import getProposalLog_MTD from '@salesforce/apex/CAMApprovalLogController.getProposalApprovalLog';
import updateConditionalProposalLogs from '@salesforce/apex/CAMApprovalLogController.updateConditionalProposalLogs';
import checkCurrentUserRole_MTD from '@salesforce/apex/CAMApprovalLogController.checkCurrentUserRole';
import getRelatedCAM_MTD from '@salesforce/apex/CAMApprovalLogController.getRelatedCAM';
import triggerDeviationMail from '@salesforce/apex/IND_CAMWithoutSharing.triggerDeviationMail';
import getAvailableRoles_MTD from '@salesforce/apex/CAMApprovalLogController.getAvailableRoles';
import getTeamRoles_MTD from '@salesforce/apex/CAMApprovalLogController.getTeamRoles';
import getDeviationsForApprovals from '@salesforce/apex/CAMApprovalLogController.getDeviationsForApprovals';
import isCAMForwardedToSCM_MTD from '@salesforce/apex/CAMApprovalLogController.isCAMForwardedToSCM';
import isCAMForwardedToCA_MTD from '@salesforce/apex/CAMApprovalLogController.isCAMForwardedToCA';
import getVehicleIDs from '@salesforce/apex/CAMApprovalLogController.getVehicleIDs';
import getDevRemarks from '@salesforce/apex/CAMApprovalLogController.getDevRemarks';
import Proposal_Approval_Log__c from '@salesforce/schema/Proposal_Approval_Log__c';
import Action__c from '@salesforce/schema/Proposal_Approval_Log__c.Action__c';
import triggerDeviations from '@salesforce/apex/CAMApprovalLogController.triggerDeviations';
import doFicoDeviationCallout_MTD from '@salesforce/apexContinuation/IntegrationEngine.doFicoDeviationCallout';
import canAccessCAMApprovalLog from '@salesforce/apex/CAMApprovalLogController.canAccessCAMApprovalLog';
import DEVIATIONS_OBJECT from '@salesforce/schema/Deviation__c';
import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';
import forwardCAMWithAPI from '@salesforce/apex/IND_CAMWithoutSharing.forwardCAMWithAPI';
import createProposalLog_MTD from '@salesforce/apex/IND_CAMWithoutSharing.createProposalLog';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import serviceChargeAndDocChargeSum from '@salesforce/label/c.Valid_sum_of_Service_Charge_and_Documentation_charge';//CISP-4785
import Email_Sent from '@salesforce/label/c.Email_Sent';
import Message_Select_any_Decision_and_Enter_Remarks from '@salesforce/label/c.Message_Select_any_Decision_and_Enter_Remarks';
import EXCEPTIONMESSAGE from '@salesforce/label/c.ExceptionMessage';
import ROLES_PERMITTED_TO_EDIT_NET_IRR_PV from '@salesforce/label/c.Permitted_Roles_for_NetIRR_field';
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout';
import getFinalTermCalculations from '@salesforce/apex/CAMApprovalLogController.getFinalTermCalculations';
import loanApplicationRevoke from '@salesforce/apex/IND_RevokeController.loanApplicationRevoke';
import upsertRecordDetails from '@salesforce/apex/IND_RevokeController.upsertRecordDetails'; // CISP-2452 Modified
import updateClonedLoanApplicationOwner from '@salesforce/apex/IND_RevokeController.updateClonedLoanApplicationOwner'; // CISP-2452
import storingCIBILDetails from '@salesforce/apex/ExternalCAMDataController.storingCIBILDetails';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';//CISP-503
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';
import CIBIL_DETAILS_OBJECT from '@salesforce/schema/CIBIL_Details__c';
import CIBIL_MAKER_DATE from '@salesforce/schema/CIBIL_Details__c.Maker_Date__c';
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
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';

import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import Net_IRR_DECIMAL from '@salesforce/schema/Final_Term__c.Net_IRR_Decimal__c';
import Inputted_IRR from '@salesforce/schema/Final_Term__c.Inputted_IRR__c';//CISP-5977
import NetLTV from '@salesforce/schema/Final_Term__c.Calculated_Net_LTV__c';
import GrossLTV from '@salesforce/schema/Final_Term__c.Calculated_Gross_LTV__c';
import grossInvoiceAmount from '@salesforce/schema/Final_Term__c.Calculated_Gross_Invoice_Amount__c';
import LTVInvoiceAmount from '@salesforce/schema/Final_Term__c.Calculated_LTV_Invoice_Amount__c';
import invoiceAmount from '@salesforce/schema/Final_Term__c.Calculated_Invoice_Amount__c';
import updateDocandServiceCharge from '@salesforce/apex/ViewCamController.updateDocandServiceCharge';//CISP-3877
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import roiMaster from '@salesforce/apex/IND_OfferScreenController.roiMaster';
import roiMasterForImputedIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForImputedIRR';//CISP-5977
import existInsuranceDetailsMethod from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.existInsuranceDetailsMethod';//CISP-4490
import isUserSelectionLookupRequiredOnRevoke from '@salesforce/apex/IND_RevokeController.isUserSelectionLookupRequiredOnRevoke'; //CISP-4628
import isJustificationProvided from '@salesforce/apex/CAMApprovalLogController.isJustificationProvided';
import getFinalTerms from '@salesforce/apex/CAMApprovalLogController.getFinalTerms';
const CCCAndAbove = ['CCC', 'COCC1', 'COCC2'];
const accessibleProfiles = ['IBL CVO', 'IBL Business Executive', 'BE', 'CVO'];
const accessibleProfilesTractor = ['IBL TF CVO', 'IBL TF Business Executive', 'BE', 'CVO','IBL Partner Community TF CVO', 'IBL Partner Community TF Business Executive','IBL Partner Community CVO'];
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';

import isTractorLoanApplication from '@salesforce/apex/IND_RevokeController.isTractorLoanApplication';//SFTRAC-166
import GuarantorLabel from '@salesforce/label/c.Guarantor';
import CoBorrowerLabel from '@salesforce/label/c.CoBorrower';
import roiMasterForGrossIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForGrossIRR';//CISP-20504
import getForwardWrapper from '@salesforce/apex/IND_CAMWithoutSharing.getForwardWrapper';//CISP-5668 fix  
import OppId from '@salesforce/schema/Opportunity.Id';
import Hold_Cam_Remarks from '@salesforce/schema/Opportunity.Hold_Cam_Remarks__c';
import Hold_Cam_Status from '@salesforce/schema/Opportunity.Hold_Cam_Status__c';
import calculateFinalTermLTVCalculations from '@salesforce/apex/CAMApprovalLogController.calculateFinalTermLTVCalculations';
export default class IND_LWC_CAMandApprovalLog extends NavigationMixin(LightningElement) {
    labelCustom = customLabels;totalExposureAmt;documentCheckdata; @api isdisableChildButton = false;minCRMIRR;maxCRMIRR;minGROSSIRR;maxGROSSIRR;isNonIndividual=false;@track finalTermList = [];totalLoanAmount;isCAMApproved=false;isNotTractor=false;disableInsSchedule=false;isModalOpen=false;isInsSubmitted=false;
    oppFinalTermId;//CISP-5977
    isNetIRRChange = false;//CISP-5977
    @track netIRRDisable = true;//CISP-5977
    @track picklistOptions;@track proposalLogList;@track originalproposalLogList;@track disableRevoke = true;@track camdisable = false;@track isShowData = true;@track isShowForwardData = false;@track PrpslRejByAnyAuthy = 'NO';
    @track proposalRecordTypeId;@track checkForMandatoryRole;committeeDeviationNMRolesMap = new Map();@track mandatoryForwardRole;@track finalRemark;@track currentUserRole;@track isGenrateCamClicked = false;@track showWithdrawnModal = false;@track fwdToSCM = true;@track fwdToCCT = true;@api id;@track logRecords;@api approvalLogDetails = [];@api proposalApprovalList = [];@api proposalApprovalListToView = [];@api conditionalyApprovedProposalList = [];@api deviationList = [];@api camRecId;@api recordId;@track loanApplicationID = this.recordId;@track approvedProposedDeviation
    // D2C_CHANGE - Raman, added d2cCheck var
    @track leadSource = false;
    @track d2cCheck = false;
   // fundedIns;//CISP-7754 
    vehicleType;//CISP-7754
    basePrise;//CISP-7754
    productSegment;//CISP-16686
    // EO D2C_CHANGE
    @track forwardTo;@track viewCAMDisable = true;@track disableSubmit = false;@track disableCondtionalSubmit = true;@track holdRemark = "";@track vehicleId = "";@track addChangeCoBorrower = true;@track isDeviationTriggered = false;@track disableTriggerDeviations = false;@track finalDisableTriggerDeviations = true;  @track disableViewDeviations = false;@track remarks;@track value = '';@track loanAmmount;@track currentUserName;@track requiredNetIRR;
    @track optionsValue = [{ label: 'Yes', value: 'YES' },
    { label: 'No', value: 'NO' }];
    @track hasSentToSCM = false;@track hasSentToCA = false;@track hasLoaded = false;@track disableCARemark = true;@track caRemark;@track reply;@track actionOptionsValue; @track replyOptions = [{ label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' }];
    @track radioButtonVal = "";@api newllyCreatedDeviationName = '';@api valuesPassedToChild = {};@api processAprovalObject;
    currentPageReference = null;urlStateParameters = null;camRecord = {};hasCommitteeDeviation = false;approvedByMandatoryRoles;iconButton = false;disabledAccept = true;hideSubmit = false;showSpinner = false;applicationAccepted = true;parentLoanCam;allNormalDeviationApproved;
    inactiveCoborrowers;
    parentLoanProposalList = [];parentLoanDeviationList = [];
    @track productType;
    grandparentLoanCam;grandparentLoanProposalList = [];grandparentLoanDeviationList = [];
    labelIRR = 'Required IRR';showRevokeModal=false;
    finalTermsRecord;isPassengerVehicle;payinPayoutSubmit=false;clickedpayinPayout=false;
    disablePayinPayout=true;
    emi;
    maxcrm;mincrm;
    mingross;
    maxgross;
    minImputedCrm;
    maxImputedCrm;
    ph1TWRevokeErr;
    showUserSelectionLookupOnRevoke = false; benName; benCode; branchAccountId; isUserSelected = false; selectedUserName; selectedUserId; revokeData = {};
    isTractor = false;emidatelist= [];x2EmiDate;emidate;emidisable=false;secondemidate;firstemidate;
    get isRevokeDisabled(){return this.showUserSelectionLookupOnRevoke==false?false:this.isUserSelected==true?false:true;}
    borrowerAppId;coborrowerAppId;isProductTypeTW;isLoanamountUpdationCheck;disableComputeLIPre = true; insuranceDetailsList =[];insuName;
    @wire(getObjectInfo, { objectApiName: DEVIATIONS_OBJECT })
    deviationObjectInfo;
    @wire(getObjectInfo, { objectApiName: Proposal_Approval_Log__c })
    processAprovalObjectInfo;
    @wire(getPicklistValues, {
        recordTypeId: "$processAprovalObjectInfo.data.defaultRecordTypeId",
        fieldApiName: Action__c
    })
    fetchaAuthPicklist({ error, data }) {if (data && data.values) {this.actionOptionsValue = data.values;}}
    canAccess = false;isTractorApp = false;@track isPELead = false;@track showRevokeModalForTractor = false;@track revokeTypeValue ='removecoborroweraddcoborrower' ;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {this.urlStateParameters = currentPageReference.state;}
        if (this.urlStateParameters.c__loanId) {this.loanApplicationID = this.urlStateParameters.c__loanId;this.connectedCallback();}
    }
    get revokeReasonVal(){
        let revokeValues = [];
        revokeValues.push({ label: 'Remove Co-Borrower/Add Co-Borrower', value: 'removecoborroweraddcoborrower' }); return revokeValues;}
    renderedCallback() {
        if (this.camRecord && this.camRecord.Proposal_Status__c) {
            this.camNotGenerated = true;
            const status = this.camRecord.Proposal_Status__c;
            const radioElem = this.template.querySelector(`[data-id="${status}"]`);
            if (radioElem) {
                radioElem.checked = true;
                if ((radioElem.value === 'Accept' || radioElem.value === 'Reject') && this.disableSubmit) {//CISP-131
                this.applicationAccepted = true;this.template.querySelectorAll(`[type="radio"]`).forEach(elem => elem.disabled = true);}}}
                else if(this.camRecId == null){if(this.isTractorApp && this.profileName.includes('CVO')){this.camNotGenerated = false;if(this.loanApplicationDetails[0]?.Hold_Cam_Status__c == 'Hold'){this.template.querySelector('[data-id="Hold"]').checked = true;}}}
                else if(this.camRecId != null && this.isTractorApp){this.camNotGenerated = true}
        if(this.leadSource == 'D2C' && this.isPassengerVehicle){
            const permittedRoles = ROLES_PERMITTED_TO_EDIT_NET_IRR_PV.split(',');
            if(permittedRoles && this.currentUserRole && permittedRoles.includes(this.currentUserRole)){this.netIRRDisable = false;
            }else{this.netIRRDisable = true; }}
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
        if(!this.hideSubmit && this.isTractor && this.profileName.includes('CVO')){
            let ele = this.template.querySelector(`[data-name=forwarded]`);
            if(!this.isCAMApproved && ele){ele.disabled=true;}else if(this.isCAMApproved && ele){ele.disabled=false;}
        }
    }
    get addChangeCoBorrowerDisabled(){return this.addChangeCoBorrower || this.leadSource == 'D2C'}

    get getDisabledAccept(){
        if(this.d2cCheck && !this.hideSubmit){return false;}else { return this.disabledAccept}}

    @api isRevokedLoanApplication;
    @track leadSource;loanApplicationDetails = [];@track camNotGenerated = true;profileName;
    get coBorrowerLabel(){return  this.isPassengerVehicle ? GuarantorLabel : CoBorrowerLabel;}
    get disableDeviationBtn(){return this.isCAMApproved || this.iconButton}
    async connectedCallback() {
        try {
            await disableInsScheduleHelper(this);
            await isTractorLoanApplication({ loanApplicationId: this.recordId }).then(result => {let data = JSON.parse(result);this.isTractorApp = data?.productType == 'Tractor' ? true : false;this.isPELead = (data?.profileName == 'IBL TF Payment Executive' || data?.profileName == 'IBL TF Internal Payment Executive') ? true : false;this.isCAMApproved=data.isCAMApproved == true ? true : false;this.profileName = data?.profileName});
            await isUserSelectionLookupRequiredOnRevoke({ loanApplicationId: this.recordId }).then(response => {let result = JSON.parse(response); if(result.isUserSelectionNeeded){this.showUserSelectionLookupOnRevoke = true;this.benCode = result.benCode;this.benName = result.benName;this.revokeData.branchAccountId = result.branchAccountId;}else if(result?.ph1TWRevokeErr){this.ph1TWRevokeErr=result.ph1TWRevokeErr;}}).catch(error => {});//CISP-4628
            await fetchLoanDetails({ opportunityId: this.recordId }).then(result => {
                this.loanApplicationDetails = result?.loanApplicationDetails;
                this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
                this.totalExposureAmt = result?.loanApplicationDetails[0].Total_Exposures_Amount__c;
                this.basePrise = result?.loanApplicationDetails[0]?.Vehicle_Details__r[0].Base_Prices__c;//CISP-7754
                this.productSegment = result?.loanApplicationDetails[0]?.Vehicle_Details__r[0].Product_Segment__c;//CISP-16686
                this.isTractor = result?.loanApplicationDetails[0]?.Product_Type__c == 'Tractor';
                this.holdRemark1 = this.loanApplicationDetails[0]?.Hold_Cam_Remarks__c;
                if(this.isTractor){roiMasterHelper(this);fetchFinalTermHelper(this);}
                if(this.leadSource=='OLA'){
                    this.addChangeCoBorrower = true;
                }
            }).catch(err => {
                console.log(err,'err232');
            });
            if (this.recordId) {
                this.loanApplicationID = this.recordId;
            }
            canAccessCAMApprovalLog({ loanAppId: this.loanApplicationID })
                .then(response => {
                    this.canAccess = response;
                    this.canAccessCAMApprovalLogFunction();
                });
            if (this.loanApplicationID && this.hasLoaded == false) {
                this.hasLoaded = true;
                await this.getRelatedCAM();
                this.vehicleId = await getVehicleIDs({ loanApplicationID: this.loanApplicationID })
                    .then(record => {
                        let responseValue = record;
                        let result = responseValue.map(_val => _val.Name);
                        return result.toString();
                    });
                getAvailableRoles_MTD({ loanAppId: this.loanApplicationID })
                    .then(res => {
                        if (res) {
                            this.picklistOptions = JSON.parse(res);
                        }
                    })
                this.checkCurrentUserRole();
            }
            this.canAccessCAMApprovalLogFunction();
            if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
            await getDocumentsToCheckPan({ loanApplicationId: this.loanApplicationID })
               .then(result => {
                    this.documentCheckdata = JSON.parse(result);})
               .catch(error => {});
        } catch (error) {}
        await existInsuranceDetailsMethod({//CISP-4490 start
            loanAppID: this.recordId,
            applicantId: this.borrowerAppId
        }).then(result => {
            if (result.length > 0) {
                result.forEach(getInsProdObj => {
                    this.insuName = getInsProdObj.Ins_Product;
                });     
            }
            }).catch(error => {})
            if(this.insuName == 'LI' && this.isLoanamountUpdationCheck === true && isProductTypeTW){//CISP-4490
              this.disableComputeLIPre = false;
            }//CISP-4490
        await getEmiDateList(this);
    }
    checkCurrentUserRole() {
        try {
            checkCurrentUserRole_MTD({ loanAppId: this.loanApplicationID })
                .then(res => {
                    if (res) {
                        this.currentUserRole = res.currentUserRole;
                        this.currentUserName = res.userName;
                        this.proposalRecordTypeId = res.proposalRecordTypeId;
                        if (this.currentUserRole && (accessibleProfiles.includes(this.currentUserRole) || (this.isTractor && accessibleProfilesTractor.includes(this.currentUserRole)))) {
                            this.disableViewDeviations = false;
                            this.disableTriggerDeviations = false;
                        }
                        else {
                            this.disableViewDeviations = true;
                            this.disableTriggerDeviations = true;
                        }
                        if (this.hasCommitteeDeviation && this.hasSentToSCM && this.currentUserRole === 'SCM') {
                            this.disableViewDeviations = false;
                        }
                        if (this.hasCommitteeDeviation && this.hasSentToCA && this.currentUserRole === 'CA') {
                            this.disableViewDeviations = false;
                            this.disableTriggerDeviations = false;
                        }
                        this.disableSubmit = this.camRecord.Proposal_Status__c && (this.camRecord.Proposal_Status__c === 'Accept' || this.camRecord.Proposal_Status__c === 'Reject');
                        if (!this.disableSubmit && (!accessibleProfiles.includes(this.currentUserRole) && !accessibleProfilesTractor.includes(this.currentUserRole))) {
                            this.disableSubmit = true;
                        }
                        if(this.finalTermsRecord && this.finalTermsRecord.Loan_Application__r.Is_Revoked__c){//CISP-2382
                            this.disableSubmit = true;
                        }
                        this.canAccessCAMApprovalLogFunction();
                    }
                })
        } catch (error) {}
    }
    
    getRelatedCAM() {
        try {
            if (this.loanApplicationID) {
                getRelatedCAM_MTD({ loanAppId: this.loanApplicationID })
                    .then(response => {
                        if (response) {
                            this.requiredNetIRR = response.netIRR != null ? response.netIRR : null;
                            this.loanAmmount = response.loanAmount;
                           // this.fundedIns = response.fundedIns;//CISP-7754
                            this.vehicleType = response.vehicleType;//CISP-7754
                            this.isLoanamountUpdationCheck = response.isLoanamountUpdationCheck//CISP-4490
                            this.productType = response.productType; // CISP CISP-10091
                            this.emidisable = this.isProductTypeTW = response.productType == 'Two Wheeler'? true : false;//CISP-4490
                            this.labelIRR = response.productType == 'Passenger Vehicles' ? 'Required Net IRR' : response.productType == 'Two Wheeler' ? 'Imputed IRR' : 'Required IRR';
                            this.isPassengerVehicle = response.productType == 'Passenger Vehicles'? true : false;
                            this.finalTermsRecord=response.finalTermsRecord ? response.finalTermsRecord : null; // CISP-131
                            this.emi=response.finalTermsRecord && response.finalTermsRecord.EMI_Amount__c ? response.finalTermsRecord.EMI_Amount__c : null; // CISP-2359
                            if(this.finalTermsRecord.First_EMI_Date__c){let firstdate = new Date(this.finalTermsRecord.First_EMI_Date__c);firstdate = new Date(firstdate.getFullYear(),firstdate.getMonth(),firstdate.getDate()); this.emidatelist.push({label:firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString()});this.emidate = firstdate.toString();this.firstemidate = this.finalTermsRecord.First_EMI_Date__c;}
                            if(this.finalTermsRecord.Second_EMI_Date__c){let seconddate = new Date(this.finalTermsRecord.Second_EMI_Date__c);seconddate = new Date(seconddate.getFullYear(),seconddate.getMonth(),seconddate.getDate()); this.x2EmiDate = seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
                            this.secondemidate = this.finalTermsRecord.Second_EMI_Date__c;}this.disablePayinPayout = !response.enablePayinPayout;//CISP-2507
                            // Start CISP-1195
                            this.inactiveCoborrowers = response.inactiveCoborrowers;//CISP-2499
                            this.borrowerAppId = response.borrowerAppId ? response.borrowerAppId : null;
                            this.coborrowerAppId = response.coborrowerAppId ? response.coborrowerAppId : null;
                            if(response.oppty){
                                // D2C_CHANGE - Raman
                                if(response.oppty.LeadSource == 'D2C'){this.leadSource = 'D2C';}                            
                                if(response.oppty.LeadSource == 'D2C' && (response.oppty.Is_Pre_Approved__c == true || response.oppty.Sanction_Status__c == 'STP')){this.d2cCheck = true;}
                                // EO D2C_CHANGE
                            }
                            this.showComputeButton = (this.leadSource != 'D2C' && this.isPassengerVehicle);
                            let finalTermId = this.finalTermsRecord ? this.finalTermsRecord.Id : null;//Start CISP-2606
                            if (finalTermId) {
                                if(!this.isPassengerVehicle){ //CISP-5450 removed TW condition
                                    roiMaster({loanApplicationId : this.recordId,productType : response.productType,tenure : parseInt(this.finalTermsRecord.Tenure__c,10),vehicleCategory : this.finalTermsRecord.Loan_Application__r.Vehicle_Type__c})
                                    .then(result => {let parsedData = JSON.parse(result);if(parsedData.mincrm != null && parsedData.maxcrm != null){this.mincrm = parsedData.mincrm;this.maxcrm = parsedData.maxcrm;}});
                                }
                                if(this.isPassengerVehicle){
                                    roiMasterForImputedIRR({loanApplicationId : this.recordId,productType : response.productType,tenure : parseInt(this.finalTermsRecord.Tenure__c,10),vehicleCategory : this.finalTermsRecord.Loan_Application__r.Vehicle_Type__c,queryBased:'CRM_IRR'})
                                    .then(result => {let parsedData = JSON.parse(result); if(parsedData.mincrm != null && parsedData.maxcrm != null){this.mincrm = parsedData.mincrm;this.maxcrm = parsedData.maxcrm;}});
                                }
                                //CISP-5977 start
                                //if(!this.isPassengerVehicle){//CISP-5450NetIRR
                                    roiMasterForImputedIRR({ loanApplicationId : this.recordId,productType : response.productType,tenure : parseInt(this.finalTermsRecord.Tenure__c,10),vehicleCategory : this.finalTermsRecord.Loan_Application__r.Vehicle_Type__c ,queryBased:'NET_IRR' })
                                    .then(result => {
                                        let parsedData = JSON.parse(result);if(parsedData.mincrm != null && parsedData.maxcrm != null){this.minImputedCrm = parsedData.mincrm;this.maxImputedCrm = parsedData.maxcrm;}
                                    }).catch(error => {});
                                //}//CISP-5977 end
                                //CISP-20504
                                roiMasterForGrossIRR({loanApplicationId : this.recordId,productType : this.productType,productSegment:this.productSegment,vehicleCategory : this.finalTermsRecord.Loan_Application__r.Vehicle_Type__c})    
                                .then(result =>{
                                   let parsedData = JSON.parse(result);
                                   if(parsedData.mingross != null && parsedData.maxgross != null){
                                       this.mingross = parsedData.mingross;//CISP-20504
                                       this.maxgross = parsedData.maxgross;//CISP-20504
                                   }});
                                //CISP-20504
                                if(this.isTractor){
                                    calculateFinalTermLTVCalculations({'loanAppId' : this.recordId});
                                }else{
                                getFinalTermCalculations({loanAppId: this.loanApplicationID})
                                    .then(response => {
                                        const wrapperobj = response;
                                        const FinalTermFields = {};
                                        FinalTermFields[final_ID_FIELD.fieldApiName] = finalTermId;
                                        FinalTermFields[NetLTV.fieldApiName] = wrapperobj.netLTV ? wrapperobj.netLTV : null;
                                        FinalTermFields[GrossLTV.fieldApiName] = wrapperobj.grossLTV ? wrapperobj.grossLTV : null;
                                        FinalTermFields[grossInvoiceAmount.fieldApiName] = wrapperobj.grossInvoiceAmount ? wrapperobj.grossInvoiceAmount : null;
                                        FinalTermFields[LTVInvoiceAmount.fieldApiName] = wrapperobj.LTVInvoiceAmount ? wrapperobj.LTVInvoiceAmount : null;
                                        FinalTermFields[invoiceAmount.fieldApiName] = wrapperobj.invoiceAmount ? wrapperobj.invoiceAmount : null;
                                        updateRecordDetails(FinalTermFields);
                                    }).catch(error => {
                                        this.showSpinner = false;
                                    });
                            }
                            }
                            if(response.isloanAppOwner && (!response.camRecord || (response.camRecord && response.camRecord.Proposal_Status__c !== 'Accept')) && this.finalTermsRecord && !this.finalTermsRecord.Loan_Application__r.Is_Revoked__c){ // CISP-1208 //CISP-2376 //CISP-2382
                                if(this.leadSource!='OLA'){this.addChangeCoBorrower = response.enableAddOrChangeCoborrower;}
                            }
                            else{
                                this.addChangeCoBorrower = true;
                            } // End CISP-1195
                            if (this.loanApplicationID) {
                                getAvailableRoles_MTD({ loanAppId: this.loanApplicationID })
                                .then(res => {
                                        if (res) {
                                            this.picklistOptions = JSON.parse(res);
                                        }
                                })
                            }
                            if(response.committeeDeviationNMRolesMap){
                                let committeeDeviationNMRolesList = new Map();
                                for (const key in response.committeeDeviationNMRolesMap) {
                                    const value = response.committeeDeviationNMRolesMap[key];
                                    committeeDeviationNMRolesList.set(key,value)
                                }
                                this.committeeDeviationNMRolesMap = committeeDeviationNMRolesList;
                            }
                            if(response.parentLoanCam){
                                this.parentLoanCam = response.parentLoanCam; 
                                this.parentLoanProposalList = response.parentLoanProposal; 
                                this.parentLoanDeviationList = response.parentLoanDeviation; 
                            }
                            if(response.grandparentLoanCam){//Start CISP-2445
                                this.grandparentLoanCam = response.grandparentLoanCam; 
                                this.grandparentLoanProposalList = response.grandparentLoanProposal; 
                                this.grandparentLoanDeviationList = response.grandparentLoanDeviation; 
                            }//End CISP-2445
                            if(response.camRecord){
                                this.camRecId = response.camRecord.Id;
                                this.camRecord = response.camRecord;
                                this.caRemark = response.camRecord.Credit_Analyst_Remarks__c;
                                if (this.caRemark) {
                                    this.disableCARemark = true;
                                }
                                this.isDeviationTriggered = response.camRecord.Trigger_Deviations__c;
                                this.iconButton = response.camRecord.Trigger_Deviations__c;
                                this.applicationAccepted = response.camRecord.Loan_Application__r.Product_Type__c == 'Passenger Vehicles' ? false : response.camRecord.Trigger_Deviations__c == true && (response.camRecord.Loan_Application__r.Product_Type__c == 'Two Wheeler' || response.camRecord.Loan_Application__r.Product_Type__c == 'Tractor') ? false : true;
                                this.camdisable = true;
                                this.viewCAMDisable = false;
                                this.isGenrateCamClicked = true;
                                this.finalRemark = response.camRecord.BE_CVO_Remarks__c;
                                this.hideSubmit = this.camRecord.Proposal_Status__c === 'Accept';
                                this.checkForMandatoryRole = response.checkForMandatoryRole ? response.checkForMandatoryRole : null;
                                this.mandatoryForwardRole = response.mandatoryForwardRole ? response.mandatoryForwardRole : null;
                                this.isCAMForwardedToSCM();
                                this.isCAMForwardedToCA();
                                this.checkCurrentUserRole();
                                this.getDeviationList(false);
                                //this.getTeamRoles();
                                this.getProposalLog();
                                this.canAccessCAMApprovalLogFunction();
                                this.approvedByMandatoryRoles = response.approvedByMandatoryRoles;
                                this.allNormalDeviationApproved = response.allNormalDeviationApproved;
                                this.disableSubmit = (this.camRecord.Proposal_Status__c === 'Accept' || this.camRecord.Proposal_Status__c === 'Reject');
                                if(this.disableSubmit && this.isPassengerVehicle){
                                    this.emidisable=true;
                                }
                                if (!this.disableSubmit && !accessibleProfiles.includes(this.currentUserRole) && !accessibleProfilesTractor.includes(this.currentUserRole)) {
                                    this.disableSubmit = true;
                                    this.emidisable=true;
                                }
                            }else{console.log('in else part ');if(this.isTractorApp && this.profileName.includes('CVO')){this.camNotGenerated = false; this.radioButtonVal = this.loanApplicationDetails[0]?.Hold_Cam_Status__c; this.holdRemark1 = this.loanApplicationDetails[0]?.Hold_Cam_Remarks__c}}

                        }
                    })
            }
        } catch (error) {}
    }

    getDeviationList(viewDeviation) {
        if (this.camRecId) {
            getDeviationsForApprovals({ camID: this.camRecId })
                .then(res => {
                    if (res) {
                        this.deviationList = res;
                        if (res.length > 0) {
                            this.hasCommitteeDeviation = res.filter(deviationObj => CCCAndAbove.includes(deviationObj.Deviation_Level__c)).length > 0;
                            if (this.hasCommitteeDeviation && (accessibleProfiles.includes(this.currentUserRole) || (this.isTractor && accessibleProfilesTractor.includes(this.currentUserRole)))) {
                                this.fwdToSCM = false;
                                this.fwdToCCT = true;
                                this.disableTriggerDeviations = true;
                            }
                            if (this.hasCommitteeDeviation && this.hasSentToSCM && (this.currentUserRole === 'SCM' || this.currentUserRole === 'NCM')) {
                                this.fwdToCCT = false;
                                this.disableViewDeviations = false;
                                this.fwdToSCM = true;
                            }
                            if (this.hasCommitteeDeviation && this.hasSentToCA && this.currentUserRole === 'CA') {
                                this.disableViewDeviations = false;
                                this.disableTriggerDeviations = false;
                                this.fwdToCCT = true;
                                this.fwdToSCM = true;
                                if (this.caRemark ==null) {
                                    this.disableCARemark = false;
                                }
                            }
                            this.finalDisableTriggerDeviations = this.isDeviationTriggered ? true : this.disableTriggerDeviations; 
                            if(viewDeviation){this.handleDeviationClick();}
                        }

                    }
                    this.checkIfAllConditionsApproved();
                    this.canAccessCAMApprovalLogFunction();
                })
                .catch(error => {});
        }
    }

    checkIfAllConditionsApproved() {
        try {
            if (this.proposalApprovalList) {
                let flag = true;
                let count = 0;
                this.proposalApprovalList.forEach(element => {
                    if (flag) {
                        if (element.recordTypeName && element.recordTypeName == 'Deviation Log') {
                           if (element.approvalStatus == 'Conditionally Approve' || element.approvalStatus == 'Approved') {
                                count += 1;
                            }
                            else {
                                flag = false;
                            }
                        }
                    }
                });
                let isHold = false;
                let countNonMandatoryDeviations = 0;
                let tempList = [];
                this.deviationList.forEach(element => {
                    if ((element.Proposal_Status__c && element.Proposal_Status__c == 'Hold') && isHold == false) {
                        isHold = true;
                    }
                    if(element.Type__c == 'Committee Deviation' && this.committeeDeviationNMRolesMap && !tempList.includes(element.Deviation_Level__c) && this.committeeDeviationNMRolesMap.get(element.Deviation_Level__c)){
                        countNonMandatoryDeviations += this.committeeDeviationNMRolesMap.get(element.Deviation_Level__c).split(',').length;
                        tempList.push(element.Deviation_Level__c);
                    }
                }); 
                if (count != this.deviationList.length || isHold) {
                    this.disabledAccept = true;
                }
                else if (count == this.deviationList.length && !flag) {
                    this.disabledAccept = true;
                }
                let checkForMandatoryRoles;
                if (this.deviationList) {
                    checkForMandatoryRoles = this.deviationList.filter(deviationObj => deviationObj.Type__c == 'Committee Deviation').length > 0
                }

                let conditionalyApprovedProposalList = this.conditionalyApprovedProposalList;
                let actionTakenOnCondtions = true;
                let hasConditionallyApproved = conditionalyApprovedProposalList && conditionalyApprovedProposalList.length > 0;
                if (hasConditionallyApproved) {
                    conditionalyApprovedProposalList.forEach(element => {
                        if (element.action !== 'Action Taken') {
                            actionTakenOnCondtions = false;
                        }
                    });
                }
                if ((this.approvedByMandatoryRoles && this.allNormalDeviationApproved) || (this.deviationList.length > 0 && count == this.deviationList.length && flag) || (this.deviationList.length > 0 && count == (this.deviationList.length - countNonMandatoryDeviations) && checkForMandatoryRoles && this.approvedByMandatoryRoles && flag && this.allNormalDeviationApproved) || (this.deviationList.length === 0 && this.camRecord.Deviation_Created_Date__c)) {
                    if(this.approvedByMandatoryRoles && this.allNormalDeviationApproved){
                        this.disabledAccept = false;
                    }
                    else if ((hasConditionallyApproved && actionTakenOnCondtions)) {
                        this.disabledAccept = false;
                    }
                    else if (!hasConditionallyApproved) {
                        this.disabledAccept = false;
                    } else {
                        this.disabledAccept = true;
                    }
                }
                this.canAccessCAMApprovalLogFunction();
            }
        } catch (error) {}
    }

    get loanAmmount() {
        return this.loanAmmount;
    }
    get requiredNetIRR() { return this.requiredNetIRR; }

    handleclick(event) {
        let position = parseInt(event.currentTarget.dataset.position);
        let sections = this.template.querySelectorAll('.slds-section');
        if (sections != null) {
            if (sections[position].classList.contains('slds-is-open')) {
                sections[position].classList.remove('slds-is-open');
            } else {
                sections[position].classList.add('slds-is-open');
            }
        }
    }

    handleReplyOptions(event) {
        this.reply = event.detail.value;
        if (this.reply == 'Yes') {
            this.isShowForwardData = true;
        } else {
            this.isShowForwardData = false;
        }
    }

    async generateCam(event) {
        this.camdisable = true;//CISP-2808
        this.camNotGenerated = true;
        const existingCAM = await getRelatedCAM_MTD({ loanAppId: this.loanApplicationID });
        if (existingCAM && existingCAM.camRecord) {
            window.location.reload();
        } else {
            this.showSpinner = true;
            await generatecam_MTD({ loanAppId: this.loanApplicationID })
                .then(res => {
                    if (res && typeof (res) != undefined) {
                        this.labelIRR = res.productType == 'Passenger Vehicles' ? 'Required Net IRR' : res.productType == 'Two Wheeler' ? 'Imputed IRR' : 'Required IRR';
                        this.emidisable = this.isProductTypeTW = res.productType == 'Two Wheeler'? true : false;//CISP-4490
                        this.camdisable = true;
                        this.camRecId = res.camRecord ? res.camRecord.Id : null;
                        if (this.camRecId) {
                            callCamRelatedAPI(this.borrowerAppId, this.coborrowerAppId, this.recordId, this.camRecId);
                            this.showSpinner = false;
                            this.showToast(this.labelCustom.Message_CAM_Generated);
                        }
                        this.camRecord = res.camRecord ? res.camRecord : null;
                        this.requiredNetIRR = res.netIRR != null ? res.netIRR : null;
                        this.loanAmmount = res.loanAmount ? res.loanAmount : null;
                        this.viewCAMDisable = false;
                        this.isGenrateCamClicked = true;
                        // this.hasCommitteeDeviation = res.hasCommitteeDeviation;
                        this.checkForMandatoryRole = res.checkForMandatoryRole ? res.checkForMandatoryRole : null;
                        this.mandatoryForwardRole = res.mandatoryForwardRole ? res.mandatoryForwardRole : null;
                        this.getProposalLog();
                        this.finalTermsRecord=res.finalTermsRecord ? res.finalTermsRecord : null; // CISP-131
                        this.emi=res.finalTermsRecord && res.finalTermsRecord.EMI_Amount__c ? res.finalTermsRecord.EMI_Amount__c : null; // CISP-2359
                        //this.isdisableChildButton = false;
                    }
                    else {
                        this.showSpinner = false;
                        this.camdisable = false;//CISP-2808
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.camdisable = false;//CISP-2808
                });
        }
    }

    handleforwardEvent(event) {
        this.forwardTo = event.target.value;
    }

forwardCAM() {
        if (this.reply === 'Yes') {
            if (!this.remarks) {
                this.showToastWarning(this.labelCustom.Message_remark);
                return;
            }
            else if (!this.forwardTo) {
                this.showToastWarning(this.labelCustom.Message_ForwardTo_Role);
                return;
            }
        }
        if ((this.forwardTo == 'SCM' || this.hasSentToSCM == true) || this.hasCommitteeDeviation == false) {
            if (((this.forwardTo == 'CA' || this.hasSentToCA == true) || (this.forwardTo == 'SCM' && !this.hasSentToSCM)) || this.hasCommitteeDeviation == false) {
                this.showSpinner = true;
                this.remarks = this.remarks;
            
                forwardCAMWithAPI({ camId: this.camRecId, role: this.forwardTo })
                    .then(response => {
                        if (response) {
                            let successResponse = response.length;
                            let count = 0;
                            response.forEach(emailRequestWrapper => {
                                updateForwardedLogs({'camId' : this.camRecId});
                                        createProposalLog_MTD({ camId: this.camRecId, role: this.forwardTo, remarks: this.remarks, emailTo: emailRequestWrapper.emailTo })
                                            .then(element => {
                                                if (element == true) {
                                                    count += 1;
                                                    if (this.forwardTo == 'SCM') {
                                                        this.hasSentToSCM = true;
                                                        if(this.hasCommitteeDeviation){
                                                            const camFields = {};
                                                            camFields['Id'] = this.camRecId;
                                                            camFields['CCC_Exposure_Editable__c'] = true;
                                                            updateRecordDetails(camFields);

                                                        }
                                                    }
                                                    if (this.forwardTo == 'CA') {
                                                        this.hasSentToCA = true;
                                                    }
                                                }
                                                if (count == successResponse) {
                                                    this.showToast(Email_Sent);
                                                    this.forwardTo = null;
                                                    this.remarks = null;
                                                    getProposalLog_MTD({ camId: this.camRecId })
                                                        .then(record => {
                                                            let forwardApprovalLog = [];
                                                            let proposalApprovalList = [];
                                                            let originalProposalList = [];
                                                            let conditionalProposalList = [];
                                                            if(this.parentLoanProposalList){
                                                                this.parentLoanProposalList.forEach(element => {
                                                                    record.push(element);
                                                                });
                                                            }
                                                            if(this.grandparentLoanProposalList){//Start CISP-2445
                                                                this.grandparentLoanProposalList.forEach(element => {
                                                                    record.push(element);
                                                                });
                                                            }
                                                            if (record) {
                                                                this.proposalLogList = response;
                                                                this.originalproposalLogList = response;
                                                                this.isShowData = true;
                                                                record.forEach(element => {
                                                                    if (element.Approval_Status__c == 'Rejected' && element.RecordType && element.RecordType.Name == 'Proposal log') {
                                                                        this.PrpslRejByAnyAuthy = 'YES';
                                                                    }
                                                                    if (element.RecordType.Name == 'Forward log') {
                                                                        let forwardElement = Object.create(element);
                                                                        let dateTime = element.Forwarded_On__c ? new Date(element.Forwarded_On__c) : null;
                                                                        forwardElement.readableDate = dateTime ? dateTime.toDateString() + ' ' + dateTime.getHours() + ':' + dateTime.getMinutes() + ':' + dateTime.getSeconds() : null;
                                                                        forwardElement.fromParent = false;
                                                                        forwardElement.style = null;

                                                                        if(forwardElement.Parent_CAM__c && this.parentLoanCam && forwardElement.Parent_CAM__c == this.parentLoanCam.Id){
                                                                            forwardElement.fromParent = true;
                                                                            forwardElement.style = 'background:#e77171;';
                                                                        }
                                                                        if(forwardElement.Parent_CAM__c && this.grandparentLoanCam && forwardElement.Parent_CAM__c == this.grandparentLoanCam.Id){//Start CISP-2445
                                                                            forwardElement.fromParent = true;
                                                                            forwardElement.style = 'background:#e77171;';
                                                                        }//End CISP-2445
                                                                        forwardApprovalLog.push(forwardElement);
                                                                    }
                                                                    let dateTime = element.Date_and_Time__c ? new Date(element.Date_and_Time__c) : new Date(element.CreatedDate);
                                                                    let readableDate = dateTime ? dateTime.toDateString() + ' ' + dateTime.getHours() + ':' + dateTime.getMinutes() + ':' + dateTime.getSeconds() : null;
                                                                    let wrapObj = {
                                                                        id: element.Id,
                                                                        role: element.Role__c ? element.Role__c : element.Forwarding_Role__c,
                                                                        approvalStatus: element.RecordType != null && element.RecordType.Name == 'Forward log' ? 'Forwarded to ' + element.Forwarded_Role__c : element.Approval_Status__c,
                                                                        approvalLog: element.RecordType != null && element.RecordType.Name == 'Deviation Log' ? (element.Proposal_description__c !=null ? 'Deviation: ' + element.Proposal_description__c :  'Deviation: ' + element.Name) : element.RecordType != null && element.RecordType.Name == 'Proposal log' ? element.Proposal_Approval_Condition__c ? element.Proposal_Approval_Condition__c : element.Proposal_Remark__c : element.Proposal_Remark__c,
                                                                        dateTime: readableDate,
                                                                        recordTypeName: element.RecordType != null && element.RecordType.Name ? element.RecordType.Name : null,
                                                                        fromParent : false,
                                                                        style : null
                                                                    }
                                                                    if(element.Parent_CAM__c && this.parentLoanCam && element.Parent_CAM__c == this.parentLoanCam.Id){
                                                                        wrapObj.fromParent = true;
                                                                        wrapObj.style = 'background:#e77171;';
                                                                    }
                                                                    if(element.Parent_CAM__c && this.grandparentLoanCam && element.Parent_CAM__c == this.grandparentLoanCam.Id){//Start CISP-2445
                                                                        wrapObj.fromParent = true;
                                                                        wrapObj.style = 'background:#e77171;';
                                                                    }//End CISP-2445
                                                                    if(wrapObj.fromParent == false){
                                                                        originalProposalList.push(wrapObj);
                                                                    }
                                                                    proposalApprovalList.push(wrapObj);
                                                                    if (element.Approval_Status__c == 'Conditionally Approve' && element.RecordType.Name == 'Proposal log' && wrapObj.fromParent != true) {
                                                                        let wrapperObj = {
                                                                            id: element.Id,
                                                                            role: element.Role__c,
                                                                            approvalCondition: element.Proposal_Approval_Condition__c,
                                                                            action: element.Action__c,
                                                                            remark: element.Proposal_Remark__c,
                                                                            disabled: this.canAccess === true ? true : this.hideSubmit
                                                                        }
                                                                        conditionalProposalList.push(wrapperObj)
                                                                    }
                                                                });
                                                                this.approvalLogDetails = forwardApprovalLog;
                                                                this.proposalApprovalList = originalProposalList;
                                                                this.proposalApprovalListToView = proposalApprovalList;
                                                                this.conditionalyApprovedProposalList = conditionalProposalList;
                                                            }
                                                        }).catch(error => {
                                                            this.showSpinner = false;
                                                        });
                                                }
                                            })
                                            .catch(error => {this.showSpinner = false;});
                            });
                        }
                        this.showSpinner = false;
                    }).catch(() => {
                        this.showSpinner = false;
                    });
            }
            else {
                this.showToastWarning('Please Forward the CAM to CA first!');
            }
        }
        else {
            this.showToastWarning(this.labelCustom.Message_Forward_CAM_To_SCM);
        }
    }

    isCAMForwardedToSCM() {
        isCAMForwardedToSCM_MTD({ camId: this.camRecId })
            .then(response => {
                if (response) {
                    this.hasSentToSCM = true;
                }
                this.canAccessCAMApprovalLogFunction();
            })
            .catch(error => {})
    }
    isCAMForwardedToCA() {
        isCAMForwardedToCA_MTD({ camId: this.camRecId })
            .then(response => {
                if (response) {
                    this.hasSentToCA = true;
                    if (this.hasCommitteeDeviation && this.hasSentToCA && this.currentUserRole === 'CA') {
                        this.disableViewDeviations = false;
                        this.disableTriggerDeviations = false;
                    }
                }
                this.canAccessCAMApprovalLogFunction();
            })
            .catch(error => {})
    }
    async camForwardedToSCM() {

        if (this.isGenrateCamClickedCheck(this.labelCustom.Message_CAM_Not_Generated_Cannot_Forward_to_SCM)) {
            this.reply = 'yes';
            if (this.picklistOptions) {
                let hasSCM = false;
                let hasNCM = false;
                this.picklistOptions.forEach(element => {
                    if (element.label == 'SCM') {
                        hasSCM = true;
                    }else if(element.label == 'NCM'){
                        hasNCM = true;
                    }
                });
                if (hasSCM) {
                    this.forwardTo = 'SCM';
                    this.forwardCAM();
                }else if(hasNCM){
                    this.forwardTo = 'NCM';
                    this.forwardCAM();
                }else {
                    this.showToastWarning(this.labelCustom.Message_No_TeamMember_found_with_role_SCM)
                }
            }
        }
    }

    forwardedToCCTClicked() {
        if (this.isGenrateCamClickedCheck(this.labelCustom.Message_CAM_Not_Generated_Cannot_Forward_to_CCT)) {
            if (this.picklistOptions) {
                let hasCA = false;
                this.picklistOptions.forEach(element => {
                    if (element.label == 'CA') {
                        hasCA = true;
                    }
                });
                if (hasCA) {
                    this.reply = 'yes';
                    this.forwardTo = 'CA';
                    this.forwardCAM();
                }
                else {
                    this.showToastWarning(this.labelCustom.Message_No_TeamMember_found_with_role_CA);
                }
            }
        }
    }

    async addOrChangeCoBorrower() {//CISP-2452
        if (this.recordId){
        this.showSpinner = true;
        this.showRevokeModal=false; //CISP-2392
        let responseObj;//CISP-2452
        let revokeTyepVal = this.isTractorApp == true ? this.revokeTypeValue : 'Add/Change Co-Borrower';
        let response = await loanApplicationRevoke({ loanApplicationId : this.recordId, revokeType : revokeTyepVal, newOwnerId : (this.showUserSelectionLookupOnRevoke?this.selectedUserId:'')});
            if (response) {
                responseObj = JSON.parse(response);//CISP-2452
                if(revokeTyepVal == 'Add/Change Co-Borrower'){
                if(responseObj.clonedApplicantsId.clonedPrimaryApplicantId){await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedPrimaryApplicantId);}
                if(responseObj.clonedApplicantsId.clonedSecondaryApplicantId){await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedSecondaryApplicantId);}
                if(responseObj.clonedLoanApplicationId){
                    await updateClonedLoanApplicationOwner({loanApplicationId : this.recordId,clonedLoanAppId:responseObj.clonedLoanApplicationId, newOwnerId : (this.showUserSelectionLookupOnRevoke?this.selectedUserId:'')}).then(()=>{}).catch(error=>{
                        this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
                    });
                }
                }
                //CISP-2452
                this.showToastMessage('Message','Application Revoked Successfully','Success');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {recordId: this.recordId,objectApiName: 'Opportunity',actionName: 'view',},});
                    //CISP-2452
            }
            this.showSpinner = false;
    }else{
        this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
        this.showSpinner = false;
    }
    }

    async cibilReportCalloutAPI(loanApplicationId,applicantId) {
        let cibilRequest = {
            applicantId: applicantId,
            loanApplicationId: loanApplicationId
        }

        await doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
            .then(res => {const result = JSON.parse(res);
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
                    //CISP-2452 - START
                    if(result.Data.Application_Cibil_Details[0].OldestDate){
                        cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].OldestDate));
                    }
                    if(result.Data.Application_Cibil_Details[0].RecentDate){
                        cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].RecentDate));
                    }
                    //CISP-2452 - END
                    cibilFields[SCORE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Score;
                    cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
                    cibilFields[TYPE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Type;
                    cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;
                    
                    if((result.Data.Cibil_LoanAccount_Details).length){
                        if((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')){
                            let makerDate =  result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                            //CISP-2452
                            let makerDateConversion = makerDate.substring(0, makerDate.lastIndexOf(' '));
                            cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? makerDateConversion.split("-").reverse().join("-") : '';
                       }
                    }
                    
                    if (result.Data.Equifax_Report_URl) {
                        cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] = result.Data.Equifax_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                    }
                    if (result.Data.Cibil_Report_URl) {
                        cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] = result.Data.Cibil_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                    }

                    cibilFields[CIBIL_APPLICANT_FIELD.fieldApiName] = applicantId;
                    //CISP-2452
                    this.upsertRecordDetailsHandler(loanApplicationId,CIBIL_DETAILS_OBJECT.objectApiName, cibilFields);

                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                    applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                    applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                    // CISP-2452
                    this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                    storingCIBILDetails({ loanAppId: loanApplicationId, apiResponse: JSON.stringify(result.Data), applicantId: applicantId}).then({});
                }else{
                    this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                    applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                    applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                    this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                }
            }).catch(error => {
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                applicantsFields[Bureau_Pull_Match__c.fieldApiName] = false;
                applicantsFields[Bureau_Pull_Message__c.fieldApiName] = error.body.message;
                // CISP-2452
                this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
            });
    }

    //CISP-2452 -- START
    async upsertRecordDetailsHandler(loanApplicationId,objectApiName, fields) {
        await upsertRecordDetails({ loanApplicationId:loanApplicationId, fields: JSON.stringify(fields), objectApiName: objectApiName })
        .then(obj => {
        })
        .catch(error => {
            this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
        });
    }
    //CISP-2452- END

    showToastMessage(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    showToast(info) {
        const event = new ShowToastEvent({
            title: 'Message',
            message: info,
            variant: 'Success'
        });
        this.dispatchEvent(event);
    }

    showToastWarning(info) {
        const evt = new ShowToastEvent({
            title: "Warning",
            message: info,
            variant: "warning"
        });
        this.dispatchEvent(evt);
    }

    isGenrateCamClickedCheck(msg) {
        if (!this.isGenrateCamClicked) { this.showToastWarning(msg); return false;} else { return true; }}

    isMultipleClicked = false;
    async generateDeviationRec(event) {
        await generateDeviations(this,getDeviationsForApprovals, doFicoDeviationCallout_MTD,final_ID_FIELD,NetLTV,GrossLTV,updateRecordDetails,triggerDeviations);
    }

    async triggerDeviationsClick() {
        this.showSpinner = true;
        let forwardToMandatoryRole = new Set();
        if (!this.camRecId) {
            this.showToastWarning(this.labelCustom.Message_CAM_Not_Generated_Cannot_Generate_Deviations);
            this.showSpinner = false;
        }
        else if (this.deviationList.length == 0) {
            this.showToastWarning(this.labelCustom.Message_Generate_Deviation_First);
            this.showSpinner = false;
        }
        else if (this.hasCommitteeDeviation && !this.caRemark) {
            this.showToastWarning('Please enter Credit Analyst Remarks before triggering the deviations');
            this.showSpinner = false;
            return;
        }
        else {
            let res = true;
            if(this.isTractor){
                res = await isJustificationProvided({'camId' : this.camRecId}) 
            }
            if(!res){
                this.showSpinner = false;
                this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: "Please enter justification remarks for all deviations!",variant: 'warning',}))
            }else{
            triggerDeviationMail({ camId: this.camRecId, caRemark: this.caRemark, calledfrom : 'camScreen' })
                .then(response => {
                    if (response && response.length != 0) {
                        let successResponse = response.length;
                        let count = 0;
                        let loopCount = 0;
                        let hasMandatoryRole = false;
                        let hasMandatoryForwardRole = false;
                        if (this.caRemark) {
                            this.disableCARemark = true;
                        }
                        else {
                            this.disableCARemark = false;
                        }
                        response.forEach(emailRequestWrapper => {
                            doEmailServiceCallout({ emailService: JSON.stringify(emailRequestWrapper) }).then(result => {
                                loopCount++;
                                result = JSON.parse(result);
                                if (result && result.response && result.response.status == 'SUCCESS') {
                                    count += 1;
                                }
                                if (count == successResponse) {
                                    this.applicationAccepted = false;
                                    this.isDeviationTriggered = response && response.length > 0 ? true : false;
                                    this.showToast(this.labelCustom.Message_Deviation_Mail_Triggered);
                                    this.iconButton = response && response.length > 0 ? true : false;
                                    this.finalDisableTriggerDeviations = this.isDeviationTriggered ? true : this.disableTriggerDeviations; 
                                    
                                }
                                if (loopCount == response.length) {
                                    this.showSpinner = false;
                                }
                            }).catch(error => {
                                loopCount++;
                                this.showSpinner = false;
                            });
                            if (emailRequestWrapper.employmentType && this.checkForMandatoryRole && emailRequestWrapper.employmentType == this.checkForMandatoryRole) {
                                hasMandatoryRole = true;
                            }
                            if (emailRequestWrapper.employmentType && this.mandatoryForwardRole && emailRequestWrapper.employmentType == this.mandatoryForwardRole) {
                                hasMandatoryForwardRole = true;
                            }
                            if(emailRequestWrapper.employmentType && emailRequestWrapper.employmentType == 'RMDM')
                            {
                                forwardToMandatoryRole.add('RMDM');
                            }
                            if(emailRequestWrapper.employmentType && emailRequestWrapper.employmentType == 'HMFI')
                            {
                                forwardToMandatoryRole.add('HMFI');
                            }
                            if(emailRequestWrapper.employmentType && emailRequestWrapper.employmentType == 'HCFD')
                            {
                                forwardToMandatoryRole.add('HCFD');
                            }
                        });
                        if(hasMandatoryRole && !hasMandatoryForwardRole && this.mandatoryForwardRole)
                        forwardToMandatoryRole.add(this.mandatoryForwardRole);
                        let forwardToMandatoryRoleArray = Array.from(forwardToMandatoryRole);
                        forwardToMandatoryRoleArray.forEach(item => {
                            //if (hasMandatoryRole && !hasMandatoryForwardRole && this.mandatoryForwardRole) {
                            forwardCAMWithAPI({ camId: this.camRecId, role: item })
                                .then(response => {
                                    if (response) {
                                        let successResponse = response.length;
                                        let count = 0;
                                        response.forEach(emailRequestWrapper => {
                                            doEmailServiceCallout({ emailService: JSON.stringify(emailRequestWrapper) }).then(result => {
                                                result = JSON.parse(result);
                                                if (result && result.response && result.response.status == 'SUCCESS') {
                                                    if(item == 'RMDM')
                                                        this.forwardTo = 'RMDM';
                                                        if(item == 'HMFI')
                                                        this.forwardTo = 'HMFI';
                                                        if(item == 'HCFD')
                                                        this.forwardTo = 'HCFD';
                                                    createProposalLog_MTD({ camId: this.camRecId, role: this.forwardTo, remarks: this.remarks, emailTo: emailRequestWrapper.emailTo })
                                                        .then(element => {
                                                            if (element == true) {
                                                                count += 1;
                                                                if (this.forwardTo == 'SCM') {
                                                                    this.hasSentToSCM = true;
                                                                }
                                                                if (this.forwardTo == 'CA') {
                                                                    this.hasSentToCA = true;
                                                                }
                                                            }
                                                            if (count == successResponse) {
                                                                this.showToast(Email_Sent);
                                                                this.forwardTo = null;
                                                                this.remarks = null;
                                                                getProposalLog_MTD({ camId: this.camRecId })
                                                                    .then(record => {
                                                                        let forwardApprovalLog = [];
                                                                        let originalProposalList = [];
                                                                        let proposalApprovalList = [];
                                                                        let conditionalProposalList = [];
                                                                        if (record) {
                                                                            this.proposalLogList = response;
                                                                            this.originalproposalLogList = response;
                                                                            this.isShowData = true;
                                                                            if(this.parentLoanProposalList){
                                                                                this.parentLoanProposalList.forEach(element => {
                                                                                    record.push(element);
                                                                                });
                                                                            }
                                                                            if(this.grandparentLoanProposalList){//Start CISP-2445
                                                                                this.grandparentLoanProposalList.forEach(element => {
                                                                                    record.push(element);
                                                                                });
                                                                            }//End CISP-2445
                                                                            record.forEach(element => {
                                                                                if (element.Approval_Status__c == 'Rejected' && element.RecordType && element.RecordType.Name == 'Proposal log') {
                                                                                    this.PrpslRejByAnyAuthy = 'YES';
                                                                                }
                                                                                if (element.RecordType.Name == 'Forward log') {
                                                                                    let forwardElement = Object.create(element);
                                                                                    let dateTime = element.Forwarded_On__c ? new Date(element.Forwarded_On__c) : null;
                                                                                    forwardElement.readableDate = dateTime ? dateTime.toDateString() + ' ' + dateTime.getHours() + ':' + dateTime.getMinutes() + ':' + dateTime.getSeconds() : null;
                                                                                    forwardElement.fromParent = false;
                                                                                    forwardElement.style = null;

                                                                                    if(forwardElement.Parent_CAM__c && this.parentLoanCam && forwardElement.Parent_CAM__c == this.parentLoanCam.Id){
                                                                                        forwardElement.fromParent = true;
                                                                                        forwardElement.style = 'background:#e77171;';

                                                                                    }//Start CISP-2445
                                                                                    if(forwardElement.Parent_CAM__c && this.grandparentLoanCam && forwardElement.Parent_CAM__c == this.grandparentLoanCam.Id){
                                                                                        forwardElement.fromParent = true;
                                                                                        forwardElement.style = 'background:#e77171;';//End CISP-2445
                                                                                    }
                                                                                    forwardApprovalLog.push(forwardElement);
                                                                                }
                                                                                let dateTime = element.Date_and_Time__c ? new Date(element.Date_and_Time__c) : new Date(element.CreatedDate);
                                                                                let readableDate = dateTime ? dateTime.toDateString() + ' ' + dateTime.getHours() + ':' + dateTime.getMinutes() + ':' + dateTime.getSeconds() : null;
                                                                                let wrapObj = {
                                                                                    id: element.Id,
                                                                                    role: element.Role__c ? element.Role__c : element.Forwarding_Role__c,
                                                                                    approvalStatus: element.RecordType != null && element.RecordType.Name == 'Forward log' ? 'Forwarded to ' + element.Forwarded_Role__c : element.Approval_Status__c,
                                                                                    approvalLog: element.RecordType != null && element.RecordType.Name == 'Deviation Log' ? (element.Proposal_description__c !=null ? 'Deviation: ' + element.Proposal_description__c : 'Deviation: ' + element.Name) : element.RecordType != null && element.RecordType.Name == 'Proposal log' ? element.Proposal_Approval_Condition__c ? element.Proposal_Approval_Condition__c : element.Proposal_Remark__c : element.Proposal_Remark__c,
                                                                                    dateTime: readableDate,
                                                                                    recordTypeName: element.RecordType != null && element.RecordType.Name ? element.RecordType.Name : null,
                                                                                    fromParent : false,
                                                                                    style : null
                                                                                }
                                                                                if(element.Parent_CAM__c && this.parentLoanCam && element.Parent_CAM__c == this.parentLoanCam.Id){
                                                                                    wrapObj.fromParent = true;
                                                                                    wrapObj.style = 'background:#e77171;';
                                                                                }
                                                                                if(element.Parent_CAM__c && this.grandparentLoanCam && element.Parent_CAM__c == this.grandparentLoanCam.Id){//Start CISP-2445
                                                                                    wrapObj.fromParent = true;
                                                                                    wrapObj.style = 'background:#e77171;';
                                                                                }//End CISP-2445
                                                                                if(wrapObj.fromParent == false){
                                                                                    originalProposalList.push(wrapObj);
                                                                                }
                                                                                proposalApprovalList.push(wrapObj);
                                                                                if (element.Approval_Status__c == 'Conditionally Approve' && element.RecordType.Name == 'Proposal log' && wrapObj.fromParent != true) {
                                                                                    let wrapperObj = {
                                                                                        id: element.Id,
                                                                                        role: element.Role__c,
                                                                                        approvalCondition: element.Proposal_Approval_Condition__c,
                                                                                        action: element.Action__c,
                                                                                        remark: element.Proposal_Remark__c,
                                                                                        disabled: this.canAccess === true ? true : this.hideSubmit
                                                                                    }
                                                                                    conditionalProposalList.push(wrapperObj)
                                                                                }
                                                                            });
                                                                            this.approvalLogDetails = forwardApprovalLog;
                                                                            this.proposalApprovalList = originalProposalList;
                                                                            this.proposalApprovalListToView = proposalApprovalList;
                                                                            this.conditionalyApprovedProposalList = conditionalProposalList;
                                                                        }
                                                                    }).catch(error => {
                                                                        this.showSpinner = false;
                                                                    });
                                                            }
                                                        })
                                                        .catch(error => {
                                                            this.showSpinner = false;
                                                        });
                                                }
                                            }).catch(error => {
                                                this.showSpinner = false;
                                            });
                                        });
                                    }
                                    this.showSpinner = false;
                                }).catch(() => {
                                    this.showSpinner = false;
                                });
                        //}
                    })

                    }else{
                        this.showToastWarning('There is no Team Member who have assigned Deviation Role!!!');
                        this.showSpinner = false;
                    }
                }).catch(() => {
                    this.showSpinner = false;
                });
            }
        }

    }
    async isCheckCam(camRecId) {
        await isCAMGenerated_MTD({ camId: this.camRecId })
            .then(response => { this.camdisable = response; })
            .catch(error => {});
    }

    getProposalLog() {
    try {
    if (this.camRecId) {
    getProposalLog_MTD({ camId: this.camRecId })
    .then(response => {
    if (response) {
    this.proposalLogList = response;
    this.originalproposalLogList = response;
    let proposalApprovalList = [];
    let originalProposalList = [];
    let conditionalProposalList = [];
    if(this.parentLoanProposalList){
    this.parentLoanProposalList.forEach(element => {
    response.push(element);
    });
    }
    if(this.grandparentLoanProposalList){//Start CISP-2445
    this.grandparentLoanProposalList.forEach(element => {
    response.push(element);
    });
    }//End CISP-2445
    if (response) {
    this.isShowData = true;
    let forwardApprovalLog = [];
    let count = 0;
    try {
    response.forEach(element => {
    if (element.Approval_Status__c == 'Rejected' && element.RecordType && element.RecordType.Name == 'Proposal log') {
    this.PrpslRejByAnyAuthy = 'YES';
    }
    if (element.RecordType.Name == 'Forward log') {
    let forwardElement = Object.create(element);
    let dateTime = element.Forwarded_On__c ? new Date(element.Forwarded_On__c) : null;
    forwardElement.fromParent = false;
    forwardElement.style = null;
    forwardElement.readableDate = dateTime ? dateTime.toDateString() + ' ' + dateTime.getHours() + ':' + dateTime.getMinutes() + ':' + dateTime.getSeconds() : null;
    if(element.Parent_CAM__c && this.parentLoanCam && element.Parent_CAM__c == this.parentLoanCam.Id){
    forwardElement.fromParent = true;
    forwardElement.style = 'background:#e77171;';
    }
    if(element.Parent_CAM__c && this.grandparentLoanCam && element.Parent_CAM__c == this.grandparentLoanCam.Id){//Start CISP-2445
    forwardElement.fromParent = true;
    forwardElement.style = 'background:#e77171;';
    }//End CISP-2445
    forwardApprovalLog.push(forwardElement);
    }

    let dateTime = element.Date_and_Time__c ? new Date(element.Date_and_Time__c) : new Date(element.CreatedDate);
    let readableDate = dateTime ? dateTime.toDateString() + ' ' + dateTime.getHours() + ':' + dateTime.getMinutes() + ':' + dateTime.getSeconds() : null;
    let wrapObj = {
    id: element.Id,
    role: element.Role__c ? element.Role__c : element.Forwarding_Role__c,
    approvalStatus: element.RecordType != null && element.RecordType.Name == 'Forward log' ? 'Forwarded to ' + element.Forwarded_Role__c : element.Approval_Status__c,
    approvalLog: element.RecordType != null && element.RecordType.Name == 'Deviation Log' ? (element.Proposal_description__c !=null ? 'Deviation: ' + element.Proposal_description__c : 'Deviation: ' + element.Name) : element.RecordType != null && element.RecordType.Name == 'Proposal log' ? element.Proposal_Approval_Condition__c ? element.Proposal_Approval_Condition__c : element.Proposal_Remark__c : element.Proposal_Remark__c,
    dateTime: readableDate,
    recordTypeName: element.RecordType != null && element.RecordType.Name ? element.RecordType.Name : null,
    fromParent : false,
    style : null
    }
    if(element.Parent_CAM__c && this.parentLoanCam && element.Parent_CAM__c == this.parentLoanCam.Id){
    wrapObj.fromParent = true;
    wrapObj.style = 'background:#e77171;';
    }
    if(element.Parent_CAM__c && this.grandparentLoanCam && element.Parent_CAM__c == this.grandparentLoanCam.Id){//Start CISP-2445
    wrapObj.fromParent = true;
    wrapObj.style = 'background:#e77171;';
    }//End CISP-2445
    if(wrapObj.fromParent == false){
    originalProposalList.push(wrapObj);
    }

    proposalApprovalList.push(wrapObj);
    if (element.Approval_Status__c == 'Conditionally Approve' && element.RecordType.Name == 'Proposal log' && wrapObj.fromParent != true) {
    let wrapperObj = {
    id: element.Id,
    role: element.Role__c,
    approvalCondition: element.Proposal_Approval_Condition__c,
    action: element.Action__c,
    remark: element.Proposal_Remark__c,
    disabled: this.canAccess === true ? true : this.hideSubmit
    }
    conditionalProposalList.push(wrapperObj);  
    }
    });
    this.approvalLogDetails = forwardApprovalLog;
    this.proposalApprovalList = originalProposalList;
    this.proposalApprovalListToView = proposalApprovalList;
    this.conditionalyApprovedProposalList = conditionalProposalList;
    } catch (error) {}

    }
    this.isShowData = true;
    }
    this.checkIfAllConditionsApproved();
    })
    .catch(error => {});
    }
    this.canAccessCAMApprovalLogFunction();
    } catch (error) {}
    }

    handleCARemarkChange(event) {
        try { let remark = event.target.value;  this.caRemark = remark; } catch (error) {}
    }
    handleActionChange(event) {
        try {
            let index = event.target.label;
            if (index != null) {
                this.conditionalyApprovedProposalList[index].action = event.target.value;
                this.disableCondtionalSubmit = false;
            }
        } catch (error) {}
    }
    handleConditionalRemarkChange(event) {
        try {
            let index = event.target.label;
            if (index != null) {
                this.conditionalyApprovedProposalList[index].remark = event.target.value;
            }
        } catch (error) {}
    }

    handleCondtionalChanges() {
        try {
            let condtionalLogList = this.conditionalyApprovedProposalList;
            if (condtionalLogList) {
                let conditionalWrapperList = []
                condtionalLogList.forEach(conditionalLog => {
                    let conditionalObj = {
                        id: conditionalLog.id,
                        action: conditionalLog.action,
                        remark: conditionalLog.remark
                    }
                    conditionalWrapperList.push(conditionalObj)
                })
                updateConditionalProposalLogs({ proposalLogList: JSON.stringify(conditionalWrapperList), originalProposalLogList: this.originalproposalLogList, currentUserRole: this.currentUserRole })
                    .then(res => {
                        if (res) {
                            this.disableCondtionalSubmit = true;
                            this.showToast(this.labelCustom.Message_ApprovalLogs_Updated);
                            this.getProposalLog();
                        }
                    })
            }
        } catch (error) {}
    }

    async getTeamRoles() {

        await getTeamRoles_MTD()
            .then(response => {
                this.picklistOptions = JSON.parse(response);
            })
            .catch(error => {});
    }

    viewCam(event) {
        let currentUrl = window.location.href;
        if(currentUrl && currentUrl.includes('/s/')){
            currentUrl = currentUrl.split('/s/')[0];
            window.open(currentUrl+'/apex/IBLCAMPage' + '?id=' + this.camRecId, '_blank');
        }
        else{
            window.open('/apex/IBLCAMPage' + '?id=' + this.camRecId, '_blank');
        }
    }

    handleChange(event) {
        this.PrpslRejByAnyAuthy = event.target.name;
    }

    async handleDeviationClick() {
        if (this.isGenrateCamClickedCheck(this.labelCustom.Message_CAM_Not_Generated_Cannot_View_Deviations)) {
            this.showNewViewDeviationComponent = true;

            this.holdRemark = await getDevRemarks({
                deviationName: this.newllyCreatedDeviationName     //'D-00000208'///   
            }).then(res => {
                return res.Remarks__c;
            }).catch(error => {});
            this.valuesPassedToChild.camRecId = this.camRecId;
            this.valuesPassedToChild.modalOpen = true;
            this.valuesPassedToChild.isDeviationTriggered = this.finalDisableTriggerDeviations;
            this.valuesPassedToChild.iconButton = this.iconButton;
            this.valuesPassedToChild.parentLoanId = this.parentLoanCam ? this.parentLoanCam.Loan_Application__r.Id : null;
            this.valuesPassedToChild.grandparentLoanId = this.grandparentLoanCam ? this.grandparentLoanCam.Loan_Application__r.Id : null;// CISP-2445
            this.template.querySelector("c-i-n-d-_-l-w-c-_-view-deviation").openModal();
        }
    }

    handleFieldValueChange(event) {
        this.radioButtonVal = event.target.value;
    }

    //CISP-3877
    calculateDocandServiceCharge(){
        if(this.finalTermsRecord && this.finalTermsRecord.Is_Loan_Amount_Change_From_CAM__c===true && !this.isPassengerVehicle){
        updateDocandServiceCharge({loanApplicationId: this.recordId}).then((res)=>{
            if(res== 'TW_min_Val'){
                if(this.leadSource != 'D2C' && this.leadSource != 'DSA') {
                    this.showToastWarning('Sum of Both Service Charge and Documentation charge should not be less than '+serviceChargeAndDocChargeSum);
                }else {
                    this.showToastWarning('Sum of Both Service Charge and Documentation charge should not be less than 1400');
                }
            }
            else{
                this.updateLoanApplication(true);
            }
        })
        .catch((error)=>{
            this.showToastWarning('Something went wrong'+error);
        });
        }else{
            this.updateLoanApplication(true);
        }
    }
    async onComputeLIPreEvent(){//CISP-4490 start
        computeLIPremiumIns(this.borrowerAppId,this.recordId,this.disableSubmit,this.showSpinner,this.insuranceDetailsList);
   }//CISP-4490 end
    async onSubmitClickEvent(event, isModalOpen) {
        let result = await validationHelper(this); if(result){return}
        if ((this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && this.basePrise!=null && ((parseFloat(this.loanAmmount)) > parseFloat(this.basePrise))) {this.showToastMessage('Warning','Loan amount is out of bounds. Please enter value less than Base Price','Warning'); return;}//CISP-7754
        if(this.radioButtonVal == 'Hold'){
            this.updateHoldStatus();this.disableSubmit=true;return;
        }
        if (this.isGenrateCamClickedCheck(this.labelCustom.Message_CAM_Not_Generated_Cannot_View_Deviations)) {
            if (this.radioButtonVal === 'Reject' && !isModalOpen) {
                this.showRejectModal = true;
                return;
            }
            if (this.radioButtonVal === 'Withdrawn') {
                this.showWithdrawnModal = true;
                return;
            }
            if (this.radioButtonVal && this.finalRemark) {
                if (this.radioButtonVal == 'Accept') {
                    if(this.leadSource != 'OLA'){//OLA-122
                    this.calculateDocandServiceCharge();//CISP-3877
                    this.showSpinner = true;
                }   else {this.updateLoanApplication(true);}
                }
                else {
                    this.updateLoanApplication(false);
                }

            }
            else {
                this.showToastWarning(Message_Select_any_Decision_and_Enter_Remarks);
            }
        }
    }

    finalTermId = null;holdRemark1 ="";
    handleRemarksChange(event){this.holdRemark1 = event.target.value}
    updateHoldStatus(){
        const oppFields = {};
        oppFields[OppId.fieldApiName] = this.recordId
        oppFields[Hold_Cam_Remarks.fieldApiName] = this.holdRemark1;
        oppFields[Hold_Cam_Status.fieldApiName] = this.radioButtonVal;
        let isvalid = updateRecordDetails(oppFields);
        if(isvalid){this.showToastMessage('Message','Loan application hold successfully','Success');}
    }
    handleNetIRRChange(event){
        let netIRRvalue = event.target.value;
        let elem = this.template.querySelector('lightning-input[data-id=netIRR]');
        if(elem){
            elem.setCustomValidity("");
            if(netIRRvalue < this.minImputedCrm || netIRRvalue > this.maxImputedCrm){
                elem.setCustomValidity('Imputed IRR is not within the permissible range');
                this.disableSubmit = true;
            }
            elem.reportValidity();
            if(netIRRvalue >= this.minImputedCrm && netIRRvalue <= this.maxImputedCrm){
                this.disableSubmit = false;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.oppFinalTermId;
                if (netIRRvalue) {
                    if(!this.isPassengerVehicle){
                        FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(netIRRvalue);
                        this.requiredNetIRR = netIRRvalue;
                        this.isNetIRRChange = true;
                    }else{
                        FinalTermFields[Net_IRR.fieldApiName] = parseFloat(netIRRvalue);
                        FinalTermFields[Net_IRR_DECIMAL.fieldApiName] = parseFloat(netIRRvalue);//CISP-20429
                        this.requiredNetIRR = netIRRvalue;
                        this.isNetIRRChange = false;
                    }
                }
                updateRecordDetails(FinalTermFields);
            }
        }
    }
    async updateLoanApplication(accepted) {
        try {
            if (this.loanApplicationID) {let isvalidForSubmit = await this.getDocumentsToCheckPanValid();
                if(!isvalidForSubmit){this.showToastMessage('Exposure (Incl. loan amount) is >=10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN or change the Loan amount');
                this.showSpinner = false;
                return;}
                if(!this.radioButtonVal || !this.finalRemark){
                    this.showToastWarning(Message_Select_any_Decision_and_Enter_Remarks);
                    return;
                }
                this.camRecord.Proposal_Status__c = this.radioButtonVal ? this.radioButtonVal : '';
                this.camRecord.BE_CVO_Remarks__c = this.finalRemark ? this.finalRemark : '';
                this.camRecord.Loan_Amount__c = this.loanAmmount ? this.loanAmmount : null;
                this.camRecord.Action_Taken__c = true;
                if (accepted) {
                    if(this.payinPayoutSubmit==false && this.finalTermsRecord && this.isPassengerVehicle){//Satart CISP-131
                        setTimeout(() => {
                            this.showSpinner = false;
                            this.showToastWarning('Please submit Pay In Pay Out');
                            if (this.camRecord && this.camRecord.Proposal_Status__c) {
                                const status = this.camRecord.Proposal_Status__c;
                                const radioElem = this.template.querySelector(`[data-id="${status}"]`);
                                if (radioElem) {
                                    // radioElem.checked = true;
                                    if ((radioElem.value === 'Accept' || radioElem.value === 'Reject') && this.disableSubmit) {//CISP-131
                                        // this.applicationAccepted = false;
                                        this.template.querySelectorAll(`[type="radio"]`).forEach(elem => elem.disabled = false);
                                    }
                                }
                            }
                        }, 500);
                    }else if(!this.isTractor && !this.isInsSubmitted){this.showSpinner=false;const event = new ShowToastEvent({title: 'Warning', message: 'Submit Installment Schedule first', variant: 'warning'});this.dispatchEvent(event);return;
                    }else{//End CISP-131
                        //CISP-2754-START
                    let loanAppId = this.loanApplicationID;
                    //CISP-2754-END
                    //SFTRAC-126
                    if(this.isTractorApp){handleTFOfferEngineCalloutHelper(this,accepted);}else{saveEMIdueDates(this);
                    //OLA-73
                    if(this.leadSource != 'OLA'){

                    let offerEngineRequestString;
                    //START D2C Changes Raman
                    let offerEngineMethod = doOfferEngineCallout;
                    let offerEngineParams;
                    if(this.leadSource === 'D2C' || this.leadSource === 'Hero'){
                        offerEngineMethod = doD2COfferEngineCallout;
                        offerEngineParams = {loanId: this.recordId, applicantId: null, fromScreen:'cam',sliderLoanAmount:this.loanAmmount.toString()};
                        await runOfferEngineHelper(this,offerEngineParams,offerEngineMethod,isvalidForSubmit,accepted,true);
                    }
                    if(!this.leadSource && this.isProductTypeTW){
                        this.showSpinner =true;
                        offerEngineRequestString = {
                            'loanApplicationId': loanAppId,
                            'currentScreen': 'CAM and Approval Log',
                            'thresholdNetIRR': null,
                            'crmIrrChanged': null,
                            'loanAmountChanged': null,
                            'tenureChanged': null,
                            'advanceEmiFlag': null,
                            'offerEMI': this.emi?this.emi.toString():'', // INDI-2359
                        };
                        offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
                        await runOfferEngineHelper(this,offerEngineParams,offerEngineMethod,isvalidForSubmit,accepted,false);
                    }
                    
                    if(this.isPassengerVehicle || (!this.leadSource && this.isProductTypeTW)){
                        this.showSpinner =true;
                        offerEngineRequestString = {
                            'loanApplicationId': loanAppId,
                            'currentScreen': 'Final Offer',
                            'thresholdNetIRR': null,
                            'crmIrrChanged': null,
                            'loanAmountChanged': null,
                            'tenureChanged': null,
                            'advanceEmiFlag': null,
                            'offerEMI': this.emi?this.emi.toString():'', // INDI-2359
                        };
                        offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
                        await runOfferEngineHelper(this,offerEngineParams,offerEngineMethod,isvalidForSubmit,accepted,true);
                    }
                } else{
                    updateLoanApplication_MTD({loanAppId: this.loanApplicationID,isAccepted: accepted,cam: this.camRecord}).then((res) => {
                        if (res) {createProposalLogRecord(this);
                            this.showToast(this.labelCustom.Message_Record_Created);this.applicationAccepted = true;this.hideSubmit = true;this.showSpinner = false;this.addChangeCoBorrower = true;this.template.querySelectorAll(`[type="radio"]`).forEach(elem => elem.disabled = true);if (this.radioButtonVal == 'Accept') {const selectedEvent = new CustomEvent('camandapprovalevent', { detail: 'CAM and Approval Log' });this.dispatchEvent(selectedEvent);}
                        }else{this.showSpinner = false;this.hideSubmit = false;this.disableSubmit = false;this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');}
                    }).catch(error => {this.showSpinner = false;});
                    }
                    }
                    }
                }
                else{
                    updateLoanApplication_MTD({loanAppId: this.loanApplicationID,isAccepted: accepted,cam: this.camRecord})
                    .then(() => {createProposalLogRecord(this);this.disableSubmit = true;});journeyStopScenarioFound(this);//CISP-4459
                }}
        } catch (error) {this.showSpinner = false;}
}
    handleValueChange(event) {
        let buttonLabel = event.target.title;
        if (buttonLabel && buttonLabel == 'Forward Remarks') {this.remarks = event.target.value;}
        if (buttonLabel && buttonLabel == 'Vehicle ID') {this.vehicleId = event.target.value;}
        if (buttonLabel && buttonLabel == 'Final Remark') {this.finalRemark = event.target.value;}
    }
    showRejectModal = false;
    cancelReject() {this.showRejectModal = false;}
    saveReject(event) {this.onSubmitClickEvent(event, true);this.showRejectModal = false;}
    onNextClickEvent() {const selectedEvent = new CustomEvent('camandapprovaltabevent', { detail: 'CAM and Approval Log' });this.dispatchEvent(selectedEvent);}
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
            });
    }

    canAccessCAMApprovalLogFunction(){
                if(this.canAccess === true){this.camdisable = true;this.disableViewDeviations = true;this.finalDisableTriggerDeviations = true;this.fwdToCCT = true; this.fwdToSCM = true;this.isShowForwardData = false;this.addChangeCoBorrower = true;this.disableCARemark = true;this.disableCondtionalSubmit = true;this.disableSubmit = true;this.emidisable=true;
                    //    this.applicationAccepted = true;
                }
    }

    handleRevokeModal(){ // Start CISP-2392 //Start CISP-2499
        if(this.inactiveCoborrowers && this.inactiveCoborrowers==2){
            this.showToastWarning('Maximum limit of coborrowers can be added is exhausted. Please proceed with the available coborrower.');
        }
        else{
            //CISP-14306 Start
            if (this.ph1TWRevokeErr) {
                this.showToastMessage('Error!', this.ph1TWRevokeErr, 'error');
            } else {//CISP-14306 End
                this.showRevokeModal = true;
                // CISP-4628 Start
                if (this.showUserSelectionLookupOnRevoke) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Warning',
                        message: 'Please select the MA to whom the lead needs to be assigned as ' + this.benCode + ' | ' + this.benName + ' is Inactive.',
                        variant: 'warning',
                        mode: 'sticky'
                    }));
                }
            }
            //CISP-4628 End
        }//End CISP-2499
    }
    cancelRevoke(){
        this.showRevokeModal=false;
    } //End CISP-2392

    async handleChangePayinPayout(){  // Start CISP-131
        let checkValue = await checkInsSubmit(this.recordId);if(!checkValue && this.leadSource != 'D2C'){this.showToastWarning('Please complete Insurance Recompute first');}else{this.clickedpayinPayout = true;this.template.querySelector("c-i-n-d-_-l-w-c-_-change-payin-payout-c-a-m").openModal(this.loanApplicationID, this.leadSource,this.productType );} /*Added 3 Params to openModal method : CISP-12521 */
    }
    openInsRecompute(){this.template.querySelector("c-i-n-d-_-l-w-c-_-c-a-m-insurance-details").openModal();} 
    closeIns(){this.getRelatedCAM();}
    handleCustomEvent(event) {
        const textVal = event.detail;this.payinPayoutSubmit = textVal;this.getRelatedCAM();}// End CISP-131

    //CISP-3592
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }//CISP-3592
    async getDocumentsToCheckPanValid(){
        let totalamount = 0;
        if(this.totalExposureAmt){totalamount = parseInt(this.totalExposureAmt) }
        if(this.leadSource != 'D2C'){
        if((parseInt(totalamount) >= 1000000 || parseInt(this.loanAmmount) >= 1000000) && (this.documentCheckdata?.borrowerPanAvailable == false || this.documentCheckdata?.coborrowerPanAvailable == false )){
             return false;
        }}
        return true;
    }
    handleUserSelection(event){this.selectedUserName = event.detail.selectedValueName;this.selectedUserId = event.detail.selectedValueId;this.isUserSelected = true;}//CISP-4628
    clearUserSelection(event){this.selectedUserName = event.detail.selectedValueName;this.selectedUserId = event.detail.selectedValueId;this.isUserSelected = false;}//CISP-4628
    handleInstallmentSchedule(){this.isModalOpen=true;}
    handleCloseModal(){this.isModalOpen=false;}handleEmiChange(event){handleEmiChangeHelper(this,event);}
    handleInsSubmit(){this.isModalOpen=false;this.isInsSubmitted = true;}
}