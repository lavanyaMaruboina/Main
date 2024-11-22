import { LightningElement, wire, api, track } from 'lwc';
import getFinalOfferRecord from '@salesforce/apex/IND_GetFinalOfferRecords.getFinalOfferRecord';
import getFinalOfferRecordForTractor from '@salesforce/apex/IND_GetFinalOfferRecords.getFinalOfferRecordForTractor';//Added for Tractor Case
import getFinalOfferDetailsflag from '@salesforce/apex/IND_GetFinalOfferRecords.getFinalOfferDetailsflag';
import doSmsCallout from '@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout';
import checkRetryExhaustedForResendSMS from '@salesforce/apexContinuation/FinalTermscontroller.checkRetryExhaustedForResendSMS';
import retryCountIncreaseForResendSMS from '@salesforce/apexContinuation/FinalTermscontroller.retryCountIncreaseForResendSMS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import ResendSMS from '@salesforce/apexContinuation/FinalTermscontroller.ResendSMS';
import getDetails from '@salesforce/apex/IND_GetFinalOfferRecords.getDetails';
import OfferPagefailuremsg from '@salesforce/label/c.OfferPagefailuremsg';
import OfferPageconsent from '@salesforce/label/c.OfferPageconsent';
import applicantRejectMethod from '@salesforce/apex/IND_GetFinalOfferRecords.applicantRejectMethod';
import createFIRecord from '@salesforce/apex/FinalTermscontroller.callCreateFI';
import applicationAssignmentTW from '@salesforce/apex/FIAssignmentController.applicationAssignmentTW';
import checkUserRole from '@salesforce/apex/FIAssignmentController.checkUserRole';
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
import Tractor from '@salesforce/label/c.Tractor';
//import createCase from '@salesforce/apexContinuation/FinalTermscontroller.createCase';
import createCase from '@salesforce/apex/OffRollEmpApproval.createCase';
import fetchProductType from '@salesforce/apex/FinalTermscontroller.fetchProductType';
import getUserInfo from '@salesforce/apex/FinalTermscontroller.getUserInfo';
import { NavigationMixin } from 'lightning/navigation';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';

import Opp_Rec_Id from '@salesforce/schema/Opportunity.Id';
import StageName from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import Sub_Stage from '@salesforce/schema/Opportunity.Sub_Stage__c';
import appId from '@salesforce/schema/Applicant__c.Id';
import journeystats from '@salesforce/schema/Applicant__c.Journey_Stage__c';
import View_Application_Sub_Stage from '@salesforce/schema/Opportunity.View_Application_Sub_Stages__c';
import FINAL_TERM_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import DO_YOU_WANT_TO_INITIATE_E_NACH_FIELD from '@salesforce/schema/Final_Term__c.Do_you_want_to_initiate_e_NACH__c';

import { updateRecord, getRecord } from 'lightning/uiRecordApi';

import View_Application_Details from '@salesforce/label/c.View_Application_Details';
import Credit_Processing from '@salesforce/label/c.Credit_Processing';
import Lead_KYC_Details from '@salesforce/label/c.Lead_KYC_Details';

import dec from '@salesforce/label/c.dec';
import Congratulations from '@salesforce/label/c.Congratulations';
import abc from '@salesforce/label/c.abc';
import Thank_you from '@salesforce/label/c.Thank_you';
import Loan_Sanctioned_by_Indusind_Bank from '@salesforce/label/c.Loan_Sanctioned_by_Indusind_Bank';
import Principle_loan_offer_from_indusind from '@salesforce/label/c.Principle_loan_offer_from_indusind';
import application_under_review from '@salesforce/label/c.application_under_review';
import Final_Offer from '@salesforce/label/c.Final_Offer';
import GREEN from '@salesforce/label/c.GREEN';
import YELLOW from '@salesforce/label/c.YELLOW';
import LOADING from '@salesforce/label/c.LOADING';
import greenworld from '@salesforce/label/c.greenworld';
import action_approval from '@salesforce/label/c.action_approval';
import yellowworld from '@salesforce/label/c.yellowworld';
import utility_spinner from '@salesforce/label/c.utility_spinner';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';

import navigateToViewApplicationDataApex from '@salesforce/apex/IND_CreditProcessing.navigateToViewApplicationData';
import getApplicantId from '@salesforce/apex/Utilities.getApplicantId';
import getParentApplicationFiCaseDetails from '@salesforce/apex/IND_GetFinalOfferWithoutSharing.getParentApplicationFiCaseDetails';
import cloneParentFICasetoChildApplication from '@salesforce/apex/IND_GetFinalOfferWithoutSharing.cloneParentFICasetoChildApplication';
import checkRepaymentRecordAndRetryCount from '@salesforce/apex/IND_GetFinalOfferRecords.checkRepaymentRecordAndRetryCount';
import assingedLeadtoTFCVO from '@salesforce/apex/IND_GetFinalOfferRecords.assingedLeadtoTFCVO';
import getRecentEMIdetails from '@salesforce/apex/InstallmentScheduleController.getRecentEMIdetails';
export default class IND_LWC_FinalOfferPage extends NavigationMixin(LightningElement) {

    @track isProductTypeTractor = false; //Added for Tractor case // SFTRAC-439
    @track finalOfferRecordsForTractor; //Added for Tractor case  //SFTRAC-439
    @api checkleadaccess;//coming from tabloanApplication
    @api activeTab;
    @api recordId;
    @api applicantId;
    @track fields;
    @api creditval;
    @api isRevokedLoanApplication;
    @track templist;
    @track lstRecords = [];
    @api appname = '';
    @api tempvar = '';
    @api decision = dec;
    @api count = 0;
    @api count1 = 0;
    @track strmsg = '';
    @track FS_str1 = Congratulations;
    @track applicant_name;
    @track FS_str2 = Loan_Sanctioned_by_Indusind_Bank;
    @track IP_str2 = Principle_loan_offer_from_indusind;
    @track other_str1 = Thank_you;
    @track other_str2 = application_under_review;
    @track loadingtnksmsg = Thank_you;
    @track loadingmsg = application_under_review;
    @api currentStage;
    @api loaded;
    @api iconname;
    @track isloanstatus;
    @track isView = false;
    @track isViewable = true;
    @track ProductType;
    @track oppid = '';
    @track objName = '';
    @track coapplicantId;
    @track currentStageName;
    @track lastStage;
    @track label = {
        Retry_Exhausted,
        OfferPagefailuremsg,
        OfferPageconsent,
        Credit_Processing,
        View_Application_Details,
        Lead_KYC_Details,
        dec,
        Congratulations,
        abc,
        Loan_Sanctioned_by_Indusind_Bank,
        Principle_loan_offer_from_indusind,
        Thank_you,
        application_under_review,
        Final_Offer,
        GREEN,
        YELLOW,
        LOADING,
        greenworld,
        action_approval,
        yellowworld,
        utility_spinner
    };

    @track isEnableNext = false;
    @track isSubmitAgain;
    @track userRole;
    showSpinner=false;
    visibleFIButton = false;
    showFiStatusModal = false;
    fiCaseData;
    flagforFICase = 'Pre-FI';
    cloneFIcaseforTW = false;
    disableFIbutton = false;
    disableFiTriggerbutton = false;
    //CISP-4181 Enable L1 users to initiate eNach from final offer screen
    currentStep = 'final-offer';
    finalTermRecordId;
    isInvokedFromFinalOffer = true;
    repaymentRecordId;
    eNachRetryCount;
    isRepaymentModeENACH;
    eNachValue;
    showRepaymentMandateComponent = false;
    isRevokedLoanApplication;
    isProductTypeTW;

    get eNachOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get showInitiateENACH() {
        if(this.isProductTypeTW && this.isRepaymentModeENACH) {
            return true;
        } else {
            return false;
        }
    }
    async init() {
        await getParentApplicationFiCaseDetails({ loanAppId: this.recordId })
            .then(result => {
                if(result){
                    console.log(result);
                    if(result == 'Existing lead not found' || result == 'FI case not found'){
                        console.log(result);
                        this.flagforFICase = 'Pre-FI';
                    } else {
                        let res = JSON.parse(result);
                        this.fiCaseData = res;
                        if(this.fiCaseData.parentLoanAppId && this.fiCaseData.productType == PassengerVehicles){
                            this.visibleFIButton = true;
                            if(this.fiCaseData.casePresent){
                                this.disableFiTriggerbutton = true;
                                this.disableFIbutton = true;
                            }
                        }else if(this.fiCaseData.parentLoanAppId && this.fiCaseData.productType == TwoWheeler){
                            if (this.fiCaseData.leadType == 'Restart' || this.fiCaseData.leadType == 'Revoked and Restart') {
                                this.flagforFICase = 'Pre-FI';
                            } else if (this.fiCaseData.leadType == 'Revoked') {
                                this.flagforFICase = JSON.stringify(this.fiCaseData);
                                this.cloneFIcaseforTW = true;
                            }
                        }
                    }
                }
            })
            .catch(error => {
                console.error(error);
            });

        const currentApplicantId = await getApplicantId({
            opportunityId: this.recordId,
            applicantType: 'Borrower',
        })
        this.applicantId = currentApplicantId;
        const coApplicantId = await getApplicantId({
            opportunityId: this.recordId,
            applicantType: 'Co-borrower',
        })
        this.coapplicantId = coApplicantId;

    }
    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordId', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    async connectedCallback() {
        await getRecentEMIdetails({loanId:this.recordId}).then((data)=>{
            if(data && data.length>0){
               this.disableInsSchedule = false;
            }else{
               this.disableInsSchedule = true;
            }
         }).catch((error) => { console.log('error in getRecentEMIdetails ',error);});
        await this.init();

        if (this.currentStage === Final_Offer) {
            this.creditval = false;
        }

        console.log('Record Id::', this.recordId);

        await this.getRecordsFromApex();
        await this.getSanctionMsg();

        await this.getRecordsFromApexForTractor();//Added for tractor case

        await getUserInfo({ recordId: this.recordId })
            .then(res => {
                this.userRole = res;
            }).catch(error => {
            })


        await fetchProductType({ loanAppId: this.recordId })
            .then(result => {
                this.ProductType = result[0].Product_Type__c;
                if(this.ProductType == 'Two Wheeler') {
                    this.isProductTypeTW = true;
                }else {
                    this.isProductTypeTW = false;
                }
                this.currentStageName = result[0].StageName;
                this.lastStage = result[0].LastStageName__c;
                this.isRevokedLoanApplication = result[0].Is_Revoked__c;
                this.disableEverythingCall();//CISP-2509
            })
            .catch(error => {
            })

            console.log('this.checkleadaccess ',this.checkleadaccess);
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

    async getSanctionMsg() {
        await getDetails({ loanId: this.recordId })
            .then(result => {
                console.log('result  ---> ', result);
                if (result == GREEN) {
                    this.isloanstatus = this.label.greenworld;
                    this.iconname = this.label.action_approval;
                    this.loaded = true;
                    this.tempvar = this.FS_str1.concat(this.applicant_name);
                    this.tempvar = this.tempvar.concat(this.FS_str2);
                    this.strmsg = this.tempvar;
                }
                else if (result == YELLOW) {
                    this.isloanstatus = this.label.yellowworld;
                    this.iconname = this.label.action_approval;
                    this.loaded = true;
                    this.tempvar = this.FS_str1.concat(this.applicant_name);
                    this.tempvar = this.tempvar.concat(this.IP_str2);
                    this.strmsg = this.tempvar;
                }
                else if (result == LOADING) {
                    this.iconname = this.label.utility_spinner;
                    this.isloanstatus = this.label.yellowworld;
                    this.loaded = false;
                    this.lstRecords.pop({ key: 'EMI Amount' });
                }
                else {
                    this.tempvar = this.other_str1.concat(this.applicant_name);
                    this.tempvar = this.tempvar.concat(this.other_str2);
                    this.strmsg = this.tempvar;
                    //console.log('line no 130');
                }

            }).catch(error => {
                console.log('Error: ', error);
            })
    }
    disableEverythingCall(){
        if (this.currentStageName==='Loan Initiation' || this.currentStageName==='Additional Details' || this.currentStageName==='Asset Details' || this.currentStageName==='Vehicle Valuation' || this.currentStageName==='Vehicle Insurance' || this.currentStageName==='Loan Details' || this.currentStageName==='Income Details' || this.currentStageName==='Final Terms'|| this.currentStageName==='Offer Screen' || this.currentStageName==='Customer Code Addition' || this.currentStageName==='Insurance Details' || (this.currentStageName!=='Final Offer' && this.lastStage !== 'Final Offer' && this.lastStage != undefined && this.currentStageName != undefined)) {//CISP-519
            console.log('by connected currentStageName: ',);
            this.disableEverything();
        }

        if (this.currentStage === Credit_Processing) {
           this.disableEverything();
            this.isEnableNext = true;
            if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }

        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    renderedCallback() {
        this.disableEverythingCall(); //CISP-2509
    }
    
    //calling apex method to get Final offer record
    async getRecordsFromApex() {
        await getFinalOfferRecord({ loanId: this.recordId })
            .then(result => {

                if (result) {
                    for (let key in result) {
                        console.log('key',key);
                        if(key == 'Do you want to initiate eNACH') {
                            this.eNachValue = result[key];
                            continue;
                        } else if(key == 'Final Term RecordId') {
                            this.finalTermRecordId = result[key];
                            continue;
                        } else if(key == 'Is Repayment Mode eNACH') {
                            this.isRepaymentModeENACH = result[key] == 'Yes' ? true : false;
                            continue;
                        }
                        else if(key == 'Offer Engine Failed') {
                            this.disableInsSchedule = result[key] == 'Yes' ? true : this.disableInsSchedule;
                            continue;
                        }
                        else if(key == 'EMI') {
                            this.disableInsSchedule = result[key] == '' ? true : this.disableInsSchedule;
                            continue;
                        }
                        this.lstRecords.push({ value: result[key], key: key });
                    }
                    for (let key in result) {
                        if (this.count == 0) {
                            this.tempvar = result[key];
                            this.appname = this.appname.concat(this.tempvar);
                            this.count++;
                            this.applicant_name = " " + this.appname + " ";
                        }
                    }
                }
                else if (error) {
                    console.log(error);
                    this.lstRecords = [];
                }
            })
            .catch(error => {
                console.log('Error: ', error);
            })
    }

    //calling apex method to get Final offer record for Tractor //SFTRAC-439
    async getRecordsFromApexForTractor() {
        await getFinalOfferRecordForTractor({ loanId: this.recordId })
            .then(result => {
                if (result) {
                    console.log('Final term result is -> ',JSON.stringify(result));
                    let nestedMap = [];
                    let counter = 1;
                    for (let key in result.ftmapForTractor) {
                        let valueOfFinalTerm = [];
                        for (let innerkey in result.ftmapForTractor[key]) {
                            if (innerkey == 'Do you want to initiate eNACH') {
                                console.log('Do you want to initiate eNACH innerkey -> ',innerkey);
                                console.log('Do you want to initiate eNACH result.ftmapForTractor[key] -> ',result.ftmapForTractor[key]);
                                this.eNachValue = result.ftmapForTractor[key];
                                continue;
                            } else if (innerkey == 'Final Term RecordId') {
                                console.log('Final Term RecordId innerkey -> ',innerkey);
                                console.log('Final Term RecordId result.ftmapForTractor[key] -> ',result.ftmapForTractor[key]);
                                this.finalTermRecordId = result.ftmapForTractor[key];
                                continue;
                            } else if (innerkey == 'Is Repayment Mode eNACH') {
                                console.log('Is Repayment Mode eNACH innerkey -> ',innerkey);
                                console.log('Is Repayment Mode eNACH result.ftmapForTractor[key] -> ',result.ftmapForTractor[key]);
                                this.isRepaymentModeENACH = result.ftmapForTractor[key] == 'Yes' ? true : false;
                                continue;
                            }
                            if (this.count == 0) {
                                this.tempvar = result.ftmapForTractor[key];
                                this.appname = this.appname.concat(this.tempvar);
                                this.count++;
                                this.applicant_name = " " + this.appname + " ";
                            }
                            valueOfFinalTerm.push({ key: innerkey, value: result.ftmapForTractor[key][innerkey] });
                        }
                        nestedMap.push({ key: 'Final Offer Detail '+counter, value: valueOfFinalTerm });
                        counter++;
                        console.log('key', key, result.ftmapForTractor[key]);
                    }
                    this.finalOfferRecordsForTractor = nestedMap;
                    this.isProductTypeTractor = result.isProductTypeTractor;
                } else if (error) {
                    console.log(error);
                    this.lstRecords = [];
                }
            })
            .catch(error => {
                console.log('Error: ', error);
            })
    }

    //function to check retry exhausted resend SMS.
    handleSms() {
        checkRetryExhaustedForResendSMS({ loanApplicationId: this.recordId })
            .then(result => {
                if (result == this.label.Retry_Exhausted) {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'SMS retry attempts are exceeded. Please click submit',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                    this.creditval = false;
                } else {
                    ResendSMS({ loanId: this.recordId })
                        .then(result => {
                            if (result != null || result != undefined || result.length != 0) {
                                //  alert('result one'+result);
                                for (var i = 0; i < result.length; i++) {
                                    result[i].id;
                                    let smsRequestString = {
                                        'applicantId': result[i].Id,  // appid need to send?
                                        'loanApplicationId': this.recordId,
                                        'flag': 'LAS',
                                    };

                                    doSmsCallout({
                                        smsRequestString: JSON.stringify(smsRequestString)
                                    })
                                        .then(smsresult => {
                                            if (smsresult == 'SUCCESS') {
                                                console.log('sms result => ', smsresult);
                                                const event = new ShowToastEvent({
                                                    title: 'Success',
                                                    message: 'SMS is Sent',
                                                    variant: 'success',
                                                });
                                                this.dispatchEvent(event);
                                            }
                                        })
                                        .catch(error => {
                                            this.error = error;
                                            console.log('Consent ERROR' + JSON.stringify(error));
                                        });
                                }
                            }
                        })
                        .catch(error => {
                            console.log('error in ResendSMS =>', error);
                        });
                }
            })
            .catch(error => {
                console.log(error);
            });

    }

    handleOnfinish() {
        if (this.currentStage === Credit_Processing) {
            const nextStage = new CustomEvent('finalofferevent');
            this.dispatchEvent(nextStage);
        }
    }

    async handleSubmit() {
        try{
            if(this.isNotTractor && !this.isInsSubmitted && !this.disableInsSchedule){
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Submit Installment Schedule first',
                    variant: 'warning'
                });
                this.dispatchEvent(event);
                this.showSpinner=false;
                return;
            }
        //  console.log('submit clicked');
        if(this.visibleFIButton && !this.disableFIbutton){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Click on FI Trigger button first',
                variant: 'warning'
            });
            this.dispatchEvent(event);
            this.showSpinner=false;
            return;
        }
        this.showSpinner=true;
        if (!this.isSubmitAgain) {
            if(this.ProductType == 'Two Wheeler' && this.isRepaymentModeENACH) {
                await this.fetchRetryCount();
                if(this.repaymentRecordId) {
                    if(!this.eNachRetryCount > 0) {
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: "Prior to submitting the final offer screen, kindly click the 'Initiate e-NACH' button on the Repayment Mandate screen",
                            variant: 'warning'
                        });
                        this.dispatchEvent(event);
                        this.showSpinner=false;
                        return;
                    }
                }
            }
                let caseCreate = false;
                if(this.ProductType == 'Two Wheeler' && !caseCreate){
                    let result = await createCase({ loanId: this.recordId, productType: this.ProductType });
                        //.then(result => {
                           //console.log(result);
                            caseCreate = true;
                        if (result != 'not entered') {
                            const event = new ShowToastEvent({
                                title: 'SUCCESS',
                                message: 'Case created successfully.',
                                variant: 'SUCCESS'

                            });
                            this.dispatchEvent(event);
                        }
                   // })
                   // .catch(error => {
                   //     console.log('Error ', error);
                   // });
                //console.log('submit clicked');
            }

            if(this.ProductType && !this.visibleFIButton && this.ProductType != Tractor){
                await createFIRecord({
                    loanApplicationId: this.recordId,
                    parentLeadData: this.flagforFICase
                }).then(result => {
                    this.isSubmitAgain = true;
                    this.showSpinner=false;
    
                    console.log('product type => ' + this.ProductType);
                    console.log('userROle => ' + this.userRole);
    
                    if (this.ProductType === TwoWheeler) {
                        if(this.cloneFIcaseforTW){
                            this.cloneParentFICasetoChild();
                        }
                        console.log('Inside the block of TW');
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: 'Application owner has been changed & Field Investigation requests are assigned to FI Agent.',
                            variant: 'SUCCESS',
                            mode: 'dismissable'
                        });
                        this.applicationAssignmentTW();
                        const oppFields = {};
                        oppFields[Opp_Rec_Id.fieldApiName] = this.recordId;
                        oppFields[StageName.fieldApiName] = this.label.Credit_Processing;
                        oppFields[LASTSTAGENAME.fieldApiName] = this.label.Credit_Processing;
                        oppFields[Sub_Stage.fieldApiName] = this.label.View_Application_Details
                        oppFields[View_Application_Sub_Stage.fieldApiName] = this.label.Lead_KYC_Details;
                        this.updateRecordDetails(oppFields);
                        const appFields = {};
                        appFields[appId.fieldApiName] = this.applicantId;
                        appFields[journeystats.fieldApiName] = 'User Details';
                        this.updateRecordDetails(appFields);
                        if (this.coapplicantId != null) {
                            const appFieldsCo = {};
                            appFieldsCo[appId.fieldApiName] = this.coapplicantId;
                            appFieldsCo[journeystats.fieldApiName] = 'User Details';
                            this.updateRecordDetails(appFieldsCo);
                        }
                        if (this.userRole === 'CVO') {
                            console.log('CVO');
                            this.dispatchEvent(new CustomEvent('submitnavigation', { detail: this.label.Credit_Processing }));
                        } else {
                            console.log('CVO else');
                            this.navigateToHomePage();
                        }
                    } else if (this.ProductType == PassengerVehicles && this.userRole != 'BE') {
                        this.oppid = '';
                        this.objName = 'Opportunity';
                        this.isViewable = false;
                        this.isView = true;
                        // iND_FI_Assignment  ==> This should be called dynamically with below 2 fields
                        // 1. recordId : Opportunity Id, 2. objectAPIName : 'Opportunity'
                    } else if (this.ProductType == PassengerVehicles && this.userRole == 'BE') {
    
                        const oppFields = {};
                        oppFields[Opp_Rec_Id.fieldApiName] = this.recordId;
                        oppFields[StageName.fieldApiName] = this.label.Credit_Processing;
                        oppFields[LASTSTAGENAME.fieldApiName] = this.label.Credit_Processing;
                        oppFields[Sub_Stage.fieldApiName] = this.label.View_Application_Details
                        oppFields[View_Application_Sub_Stage.fieldApiName] = this.label.Lead_KYC_Details;
                        this.updateRecordDetails(oppFields);
                        const appFields = {};
                        appFields[appId.fieldApiName] = this.applicantId;
                        appFields[journeystats.fieldApiName] = 'User Details';
                        this.updateRecordDetails(appFields);
                        if (this.coapplicantId != null) {
                            const appFieldsCo = {};
                            appFieldsCo[appId.fieldApiName] = this.coapplicantId;
                            appFieldsCo[journeystats.fieldApiName] = 'User Details';
                            this.updateRecordDetails(appFieldsCo);
                        }
    
                        this.dispatchEvent(new CustomEvent('submitnavigation', { detail: this.label.Credit_Processing }));
                        //this.navigateToHomePage();
                    }
                    
    
                }).catch(error => {
                    
                this.showSpinner=false;
                    console.log('error ', error);
                    this.isSubmitAgain = false;
                });
            }else{
                this.showSpinner=false;
                if (this.ProductType == PassengerVehicles && this.userRole != 'BE') {
                    this.oppid = '';
                    this.objName = 'Opportunity';
                    this.isViewable = false;
                    this.isView = true;
                    // iND_FI_Assignment  ==> This should be called dynamically with below 2 fields
                    // 1. recordId : Opportunity Id, 2. objectAPIName : 'Opportunity'
                } else if (this.ProductType == PassengerVehicles && this.userRole == 'BE') {

                    const oppFields = {};
                    oppFields[Opp_Rec_Id.fieldApiName] = this.recordId;
                    oppFields[StageName.fieldApiName] = this.label.Credit_Processing;
                    oppFields[LASTSTAGENAME.fieldApiName] = this.label.Credit_Processing;
                    oppFields[Sub_Stage.fieldApiName] = this.label.View_Application_Details
                    oppFields[View_Application_Sub_Stage.fieldApiName] = this.label.Lead_KYC_Details;
                    this.updateRecordDetails(oppFields);
                    const appFields = {};
                    appFields[appId.fieldApiName] = this.applicantId;
                    appFields[journeystats.fieldApiName] = 'User Details';
                    this.updateRecordDetails(appFields);
                    if (this.coapplicantId != null) {
                        const appFieldsCo = {};
                        appFieldsCo[appId.fieldApiName] = this.coapplicantId;
                        appFieldsCo[journeystats.fieldApiName] = 'User Details';
                        this.updateRecordDetails(appFieldsCo);
                    }

                    this.dispatchEvent(new CustomEvent('submitnavigation', { detail: this.label.Credit_Processing }));
                    //this.navigateToHomePage();
                }else if(this.ProductType == Tractor){
                    let result = await assingedLeadtoTFCVO({loanApplicationId : this.recordId});
                    if(result){
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: 'Application assigned successfully to CVO user.',
                            variant: 'success'

                        });
                        this.dispatchEvent(event);
                        //location.reload();
                        this.navigateToTFHomePage();
                    }
                }
            }
        }
    }catch(error){
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Something went wrong!',
            variant: 'error'

        });
        this.dispatchEvent(event);
        this.showSpinner = false;
    }


    }

    // for Application owner and case owner assignment
    applicationAssignmentTW() {
        checkUserRole({
            loanApplicationId: this.recordId
        }).then(result => {
            console.log('result in checkUserRole ', result);
            let res = result
            console.log('res ', res);

            applicationAssignmentTW({
                loanApplicationId: this.recordId ,// loan application id to be passed dyanmically
                isMoRefinanceApplication: res
            }).then(result => {
                const event = new ShowToastEvent({
                    title: 'SUCCESS',
                    message: 'Application and case owner assigned successfully.',
                    variant: 'SUCCESS',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }).catch(error => {
                console.log('error ', error);
            })
        }).catch(error=>{
            console.log('error ', error);
        })
    }

     //method to update record details
    async updateRecordDetails(fields) {
            const recordInput = { fields };
            await updateRecord(recordInput)
            .then(() => {
                this.callNavigateToViewApplicationDataApex();
            })
                .catch(error => {
                });
        }

    async callNavigateToViewApplicationDataApex(){
            await navigateToViewApplicationDataApex({ loanApplicationId: this.recordId
        })
            .then(result => {
                if (result) {
                    this.dispatchEvent(new CustomEvent('navigatetoviewapplicationtata'));
                } else {
                    this.navigateToHomePage();
                    this.creditval = true;
                }
            })
            .catch(error => {
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

    navigateToTFHomePage() {
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
                            apiName: 'IndusInd_Home'
                        }
                    });
                }
            })
            .catch(error => {
            });
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }


    handleFiTrigger(){
        this.showFiStatusModal = true;
    }
    cancelFiStatusModal(){
        this.showFiStatusModal = false;
    }
    handleYesClick(){
        this.disableFIbutton = true;
        this.showFiStatusModal = false;
        this.showSpinner=true;
        createFIRecord({
            loanApplicationId: this.recordId,
            parentLeadData: 'Yes'  
        }).then(result => {
            this.showSpinner=false;
            const event = new ShowToastEvent({
                title: 'SUCCESS',
                message: 'Case created successfully.',
                variant: 'SUCCESS'
            });
            this.dispatchEvent(event);            
        }).catch(error => {
            this.showSpinner=false;
            console.log('error ', error);
        });
    }
    async handleNoClick(){ 
        this.disableFIbutton = true;
        this.showFiStatusModal = false;
        this.showSpinner=true;
        await createFIRecord({ 
            loanApplicationId: this.recordId,
            parentLeadData: 'No' 
        }).then(result => {
            this.cloneParentFICasetoChild();
            
        }).catch(error => {
            this.showSpinner=false;
            console.log('error ', error);
        });
    }
    //CISP-4181 Enable L1 users to initiate eNach from final offer screen
    
    async handleUpdateFinalTermRecord() {
        const fields = {};
        fields[FINAL_TERM_ID_FIELD.fieldApiName] = this.finalTermRecordId;
        fields[DO_YOU_WANT_TO_INITIATE_E_NACH_FIELD.fieldApiName] = this.eNachValue == 'Yes' ? true : false;
        const recordInput = { fields };

        await updateRecord(recordInput)
            .then(() => {
                console.log('Final Term record updated successfully');
            }).catch(error => {
                console.log('error ', error);
            });
    }
    async fetchRetryCount() {
        await checkRepaymentRecordAndRetryCount({ loanApplicationId: this.recordId })
            .then(result => {
                if(result){
                    console.log(result);
                    let data = JSON.parse(result);
                    if(data.repaymentRecordId) {
                        this.repaymentRecordId = data.repaymentRecordId;
                        this.eNachRetryCount = data.retryCount;
                    }
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleEnachChange(event) {
        const field = event.detail.value;
        if(field == 'Yes') {
            this.eNachValue = 'Yes';
            this.showRepaymentMandateComponent = true;
        }else if(field == 'No') {
            this.eNachValue = 'No';
            this.showRepaymentMandateComponent = false;
        }
    }

    handleOpenFinalOfferPage(event) {
        if(!event.detail.repaymentRecordId) {
            this.eNachValue = 'No';
        }
        this.showRepaymentMandateComponent = false;
    }

    cloneParentFICasetoChild(){
        this.disableFIbutton = true;
        cloneParentFICasetoChildApplication({
            loanAppId: this.recordId,
            parentLeadData: JSON.stringify(this.fiCaseData)
        }).then(result => {
            this.showSpinner=false;
            const event = new ShowToastEvent({
                title: 'SUCCESS',
                message: 'Case created successfully.',
                variant: 'SUCCESS'
            });
            this.dispatchEvent(event);
            log('from here',result);
        }).catch(error => {
            this.showSpinner=false;
        });
    }
}