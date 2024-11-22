import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';    
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import LightningCSS from '@salesforce/resourceUrl/loanApplication';
import getLoanApplicationStageName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageName';
import getLoanApplicationStageNameMetaData from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageNameMetaData';
import getCurrentOppRecord from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getCurrentOppRecord';
import haveLeadAccesibility from '@salesforce/apex/LwcLOSLoanApplicationCntrl.haveLeadAccesibility';
import getTabList from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getTabList';
import getTabListForInsurance from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getTabListForInsurance';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import APPLICANT_SUBSTAGE from '@salesforce/schema/Applicant__c.Journey_Stage__c';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import OPPORTUNITY_STAGE from '@salesforce/schema/Opportunity.StageName';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import Guarantor from '@salesforce/label/c.Guarantor';
import Beneficiary from '@salesforce/label/c.Beneficiary';
import TF_No_Of_CoBorrower from '@salesforce/label/c.TF_No_Of_CoBorrower';
import Addition_Details_Capture from '@salesforce/label/c.Addition_Details_Capture';
import { NavigationMixin } from 'lightning/navigation';                             
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola-50

import { subscribe }  from 'lightning/empApi';//CISP-2868

import LASTSTAGENAME from "@salesforce/schema/Opportunity.LastStageName__c";//CISP-1196
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';//CISP: 2861
import checkLeadvalidateByCMU from '@salesforce/apex/Ind_CustomerDedupCtrl.checkLeadvalidateByCMU';

import * as helper from './lWC_LOS_TabLoanApplicationHelper';
import isTractorLoanApplication from '@salesforce/apex/IND_RevokeController.isTractorLoanApplication';//SFTRAC-166


export default class LWC_LOS_Tab_LoanApplication extends NavigationMixin(LightningElement) {
    @track activeTabId;
    //Decorators
    @track journeyrestarted = false;
    @track customMessage = '';
    stepName;
    ischeckBL = ''; 
    cardMsg;showCardMsg=false;
    @api isCapturImageSuccess = false;
    @api showTab = false;
    @api recordId;
    @track productType; //CISP-2692
    @api tabListCount; //IND-2373
    tabList = [];
    @track activeTab;
    @api borroweIncomeSource = false;
    @track currentStage;
    @track isRevokeApplication;//CISP-2384
    @track isTransferVisible = false;
    @track showOverlayMenu = false;
    @track lastStageName;
    @track vehicleType;
    @track insuranceDetails;
    @track creditProcFlag = false;
    @track isLoading = false;
    @track activeApplicantList = [];
    @track forUsedVehicleType = false;
    @track showFileUploadAndView = false;
    @track hideMenuIcon = false;
    @track isTractor = false;
    @track isPELead = false;@track showRCUReport = false;@track rcuCaseId;@track hidePdfBtn = true;@track showRCUDocuments = false;@track isCVOLead = false;
    @track isNonIndividualLead = false;
    AssetDetails = false;
    loanDetails = false;
    incomeDetails = false;
    additionalDetail = false;
    loanAppilication = true;
    finalTerms = false;
    showOfferScreen = false;
    finalOffer = false;
    vehicleValuation = false;
    vehicleInsurance = false;
    customerCode = false;
    withdrawn = false;
    leadSource;// Ola-50
    applicantNumber;//CISP-7759
    @track label = {
        Borrower,
        CoBorrower,
        Guarantor,
        Beneficiary,
        TF_No_Of_CoBorrower
    };
    @api checkLeadAccess=false;
    //Sayali Gore - 17/3/2022 - Added below variable
    postSanctionChecks;
    preDisbursementCheck; //Anuj - 02/05/2022
    showPaymentRequest = false;
    revokeBtnVisibilitySteps = new Set(['credit-verification','post-sanction','pre-disbursement','revoke']); // Added by Gaurav 2022

    subscription = {};//CISP-2868
    @api channelName = '/event/Refresh_View__e';//CISP-2868
    //START D2C Changes Swapnil
    showPreInitialOffer = false;
    showPostInitialOffer = false;
    showCardMsgHandler(event){
        this.showCardMsg=true;
        this.cardMsg=event.detail.value;
    }
    get showHamburger(){
        if(this.showPreInitialOffer || this.showPostInitialOffer){
            return false;
        }
        return true;
    }

    get isPrePostInitialOffer(){
        if(this.showPreInitialOffer || this.showPostInitialOffer || this.showPreApprovedOffer){
            return true;
        }
        return false;
    }
    //END D2C Changes Swapnil

    constructor() {
        super();
        console.log('Loan Application Constructor');
        this.template.addEventListener('refreshParentComponent', this.handlerRefreshEvent.bind(this));
        this.template.addEventListener('submitnavigation', this.switchScreen.bind(this));
    }
    handlerRefreshEvent(event) {
        this.stepName = "pre-disbursement";
        this.preDisbursementCheck = true;
    }
    //CISP-2868-START
    handleSubscribe() {
        const messageCallback = (response)=> {
            var obj = JSON.parse(JSON.stringify(response));
            console.log('obj--- : ',obj);
            if(obj?.data?.payload?.Record_Id__c == this.recordId && (obj?.data?.payload?.Stage__c == 'Journey Restart' || obj?.data?.payload?.Stage__c == 'STOP')){
                console.log('OUTPUT obj pass: ',obj?.data?.payload?.Stage__c);
                eval("$A.get('e.force:refreshView').fire();");
                this.restartCall();
            }
        };
        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
            console.log('OUTPUT journeyrestarted **** : ',this.journeyrestarted);
            this.restartCall();
        });
    }
    //CISP-2868-END
    restartCall(){
        checkLeadvalidateByCMU({ leadId: this.recordId })
          .then(result => {
            console.log('ResultrestartCall ', result);
            if(result){
                result.forEach(element => {
                    if((element.Opportunity__r.StageName == 'Journey Restart' || element.Opportunity__r.Journey_Status__c == 'Stop')){
                         this.journeyrestarted = true;
                        if(element.Opportunity__r.StageName == 'Journey Restart'){
                            this.customMessage = element.Opportunity__r.Journey_Restart_Reason__c;
                        }else if(element.Opportunity__r.Journey_Status__c == 'Stop'){
                            this.customMessage = element.Opportunity__r.Journey_Stop_Reason__c;
                        }else
                            this.customMessage = 'Journey has been restarted or stop for this lead';
                        /* const evt = new ShowToastEvent({
                             title: 'Info',
                             message:  this.customMessage,
                             variant: 'info',
                             mode:'sticky'
                         });
                         this.dispatchEvent(evt);*/
                         this.disableEverything();
                     }else{
                        this.journeyrestarted = false;
                     }
                });
                
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    async connectedCallback() {
        isTractorLoanApplication({ loanApplicationId: this.recordId })
        .then(result => {
          console.log('Result', result);
          let data = JSON.parse(result);
          this.isPELead = (data?.profileName == 'IBL TF Payment Executive' || data?.profileName == 'IBL TF Internal Payment Executive') ? true : false;
          this.isCVOLead = (data?.profileName == 'IBL TF CVO' || data?.profileName == 'IBL Partner Community TF CVO') ? true : false;
          this.rcuCaseId = data?.rcuCaseId;
        })
        .catch(error => {});
        /* //Ola-50 start //CISP-8437
        await fetchLoanDetails({ applicantId: this.recordId }).then(result => {
            if(result?.loanApplicationDetails){
            this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
            }
        });//Ola-50 end */ //CISP-8437
        await this.handleSubscribe();//CISP-2868
        this.restartCall();
       this.isLoading = true;
        console.log('record id :: ', this.recordId);
        await this.getTabListFunction();//CISP-2664
        await getCurrentOppRecord({ loanApplicationId: this.recordId }).then(response => {
            let result = JSON.parse(response);
            console.log('getCurrentOppRecord result:: ', result);
            this.currentStage = result.oppRecord.StageName;
            this.isRevokeApplication = result?.oppRecord?.Is_Revoked__c;//CISP-2384
            this.productType = result?.oppRecord?.Product_Type__c; //CISP-2692
            this.isNonIndividualLead = result?.oppRecord?.Customer_Type__c == 'Non-Individual' ? true : false; //CISP-2692
            this.isTractor = this.productType.toLowerCase() === 'Tractor'.toLowerCase() ? true : false;
            this.leadSource = result?.oppRecord?.LeadSource;//Ola-50 //CISP-8437
            this.applicantNumber = result?.oppRecord?.Application_number__c;//CISP-7949
            console.log('The Prod type is '+ this.productType)
            if(this.currentStage == 'Rejected') {
                console.log('currentStage..'+this.currentStage);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Loan application has been rejected.',
                    variant: 'info',
                });
                this.dispatchEvent(evt);
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Home'
                    }
                });
            }
            //CISP-2390 Removed revoked toast.
            if(this.currentStage === 'Loan Initiation' || this.currentStage === 'Additional Details' || this.currentStage === 'Asset Details' || this.currentStage === 'Vehicle Valuation' || this.currentStage === 'Vehicle Insurance' || this.currentStage === 'Loan Details' || this.currentStage === 'Income Details' || this.currentStage === 'Final Terms' || this.currentStage === 'Offer Screen' || this.currentStage === 'Customer Code Addition' || this.currentStage === 'Insurance Details' || this.currentStage === 'Final Offer'){
                this.hideMenuIcon = false;
            } else{
                this.hideMenuIcon = true;
            }
            this.stepName = this.currentStage == 'Pre Disbursement Check' ? 'pre-disbursement' : this.currentStage == 'Post Sanction Checks and Documentation' ? 'post-sanction' : this.currentStage == 'Credit Processing' ? 'credit-verification' : this.currentStage == 'Disbursement Request Preparation' ?  'payment-requests' : this.isRevokeApplication ? 'revoke':'';//CISP-3255
            // CISP-2382 Added this.isRevokeApplication
            this.vehicleType = result.oppRecord.Vehicle_Type__c;
            this.lastStageName = result.oppRecord.LastStageName__c;
            this.activeApplicantList = result.applicantsList;
            //START D2C Changes Swapnil
            if(result.oppRecord.LeadSource === 'D2C'){
                this.activeTab = 'Borrower';
                this.activeTabId = this.tabList.filter(item => item.applicantType === 'Borrower').applicantId;
            }
            //END D2C Changes Swapnil
            const filteredList = result.applicantsList.filter(item => item.applicantType === this.activeTab);
            const currentApplicant = filteredList[0];
            this.applicantId = currentApplicant.applicantId;
            if (this.vehicleType === 'New') {
                this.forUsedVehicleType = false;
            } else {
                this.forUsedVehicleType = true;
            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
        });
        
        await haveLeadAccesibility({ leadApplicationId: this.recordId }).then(response => {
            if(!response){
                this.checkLeadAccess=true;
            }
         console.log('haveLeadAccesibility result:: ', response);
        }).catch(error => {
         console.log('haveLeadAccesibility error:: ', error);
        });
        

        this.withdrawn = false;//cz we need to load this after haveLeadAccesibility method
        await getLoanApplicationStageName({ loanApplicationId: this.recordId }).then(result => {
            console.log('the resr' + result);
            this.currentStage = result;
            if (result == "Additional Details") {
                this.additionalDetail = true;
                this.loanAppilication = false;
            } else if (result === "Asset Details") {
                this.AssetDetails = true;
                this.additionalDetail = false;
                this.loanAppilication = false;
            } else if (result === "Vehicle Insurance") {
                this.vehicleInsurance = true;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
            } else if (result === "Vehicle Valuation") {
                this.vehicleValuation = true;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
            } else if (result === "Loan Details") {
                this.loanDetails = true;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
                this.isEnablePrev = true; //1714
            } else if (result === "Income Details") {
                this.incomeDetails = true;
                this.insuranceDetails = false;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
            } else if (result === "Insurance Details") {
                this.getTabListFunctionForInsurance();
                this.incomeDetails = false;
                this.insuranceDetails = true;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
            } else if (result === "Final Offer") {
                this.finalOffer = true;
                this.incomeDetails = false;
                this.insuranceDetails = false;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
            } else if (result === 'Final Terms') {
                console.log('activeTab ---> ', this.activeTab);
                console.log('tabList ---> ', this.tabList);
                this.incomeDetails = false;
                this.finalTerms = true;
                this.insuranceDetails = false;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
                this.finalOffer = false;
                this.showOfferScreen = false;
                this.customerCode = false;
            } else if (result === 'Offer Screen') {
                this.incomeDetails = false;
                this.finalTerms = false;
                this.insuranceDetails = false;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
                this.finalOffer = false;
                this.showOfferScreen = true;
                this.customerCode = false;
            } else if (result === 'Customer Code Addition') {
                console.log('inside Customer Code Addition');
                this.incomeDetails = false;
                this.customerCode = true;
                this.finalTerms = false;
                this.insuranceDetails = false;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
                this.finalOffer = false;
                this.showOfferScreen = false;
            } else if (result === 'Final Offer') {
                this.incomeDetails = false;
                this.customerCode = false;
                this.finalTerms = false;
                this.insuranceDetails = false;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
                this.finalOffer = true;
                this.activeTab = this.label.Borrower;
                this.activeTabId = this.tabList.filter(item => item.applicantType === this.label.Borrower).applicantId;
            } else if (result === "Credit Processing") {
                this.creditProcFlag = true;
                console.log('credit Processing flag', this.creditProcFlag);
            } else if (result === "Post Sanction Checks and Documentation") { //Sayali Gore - 17/3/2022 - Added this condition - line no 154-156
                this.postSanctionChecks = true;
            } else if (result === "Pre Disbursement Check") {
                this.preDisbursementCheck = true;
            } else if (result === "Disbursement Request Preparation") {
                this.showPaymentRequest = true;
            } else if (result === 'Withdrawn') {
                this.incomeDetails = false;
                this.customerCode = false;
                this.finalTerms = false;
                this.insuranceDetails = false;
                this.loanDetails = false;
                this.vehicleValuation = false;
                this.vehicleInsurance = false;
                this.AssetDetails = false;
                this.additionalDetail = false;
                this.loanAppilication = false;
                this.finalOffer = false;
                this.creditProcFlag = false;
                this.postSanctionChecks = false;
                this.preDisbursementCheck = false;
                this.withdrawn = true;
                console.log('withdrawn', this.withdrawn);
                // const event = new ShowToastEvent({
                //     title: 'Message',
                //     message: 'You Cannot view this Withdrawn Application',
                //     variant: 'Warning'
                // });
                // this.dispatchEvent(event);
            }
            this.showTransferbutton(this.currentStage);
    
        }).catch(error => {
            this.isLoading = false;
            console.log('error1::', error.message);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong, Please contact your administrator.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });
    }
    showTransferbutton(stage){
        getLoanApplicationStageNameMetaData().then(result => {
            this.isLoading = false;
            if(stage !=='Offer Screen')
            {
                console.log(' result ', result, ' check 1 ', stage);
                
                const res = result.includes(stage);
                console.log('res',res);
                this.isTransferVisible = res;
                //CISP: CISP-2692
                if(stage=='Loan Initiation' && this.productType=='Two Wheeler' && (JourneyStage == 'Capture Dedupe' || JourneyStage == 'Vehicle Dedupe' || JourneyStage == 'Declared Income/Required Loan Amount' || JourneyStage == 'Bank Account Check' || JourneyStage == 'Gatting And Screening'))//CISP-3009
                {
                    this.isTransferVisible = true;
                }else if(stage=='Loan Initiation' && this.productType=='Two Wheeler') {//CISP-3009
                    this.isTransferVisible = false;
                }
            }
            else{
                this.isTransferVisible = false;
            }
        }).catch(error => {
            //alert('error' + JSON.stringify(error));//CISP-3210
        });
    }

    async getTabListFunctionForInsurance() {
        try{
            let result = await getTabListForInsurance({ loanApplicationId: this.recordId });
            if (result.length > 0) {
                console.log('getTabListFunctionForInsurance --> ', result)
                this.tabList = result;
            }
        }catch(error){}
    }

    CheckAgentBLCode(event) //CISP:2861 to get the value of Agent brach code from loan aaplication comp
    {
        console.log('I am in agent check ',event.detail)
        this.ischeckBL =event.detail.agentBL;//CISP-3009
        if(event.detail.proType=='TW'){
            this.productType = 'Two Wheeler';
        }else if(event.detail.proType=='Tractor'){
            this.productType = 'Tractor';
        }else{
            this.productType =  'Passenger Vehicles';
        }
        // this.productType =event.detail.proType=='TW' ? 'Two Wheeler' : 'Passenger Vehicles';//CISP-3009
    }

    opneRCUReportModal(){
        this.showRCUReport = true;
    }
    closeRCUReportModal(){
        this.showRCUReport = false;
    }
    openRCUDocModal(){
        this.showRCUDocuments = true;
    }
    closeRCUDocModal(){
        this.showRCUDocuments = false;
    }
    viewUploadViewFloater(){
        this.showFileUploadAndView = true;
    }
    closeUploadViewFloater(event){
        this.showFileUploadAndView = false;
    }
    async navigateCoborrower() {
        let tab = await this.tabList.filter((ele)=> ele.applicantType == this.label.CoBorrower);
        this.activeTab = this.label.CoBorrower;
        this.activeTabId = tab && tab.length > 0 ? tab[0].applicantId : this.activeTabId;
    }

    navigateLoanCoborrower(event) {
        console.log('Inside Event ::', event.detail);
        this.activeTab = this.label.CoBorrower;
        let screenValue = event.detail;
        if (screenValue === 'Income Details') {
            this.incomeDetails = true;
            this.insuranceDetails = false;
            this.loanDetails = false;
            this.vehicleValuation = false;
            this.finalTerms = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
        }
    }

    deletePreviousCoborrower(event) {
        this.tabList = this.tabList.filter(rec => rec.applicantId != event.detail.id);
        // if (this.tabList.length > 1) {
        //     console.log('tablist before = > ', this.tabList, this.tabList.length);
        //     this.tabList.pop();
        //     console.log('tablist after = > ', this.tabList, this.tabList.length);
        // }
    }

    async addNewCoborrower(event) {
        if(this.productType === 'Tractor'){
            let noOfCoBorrowerAllowed = parseInt(this.label.TF_No_Of_CoBorrower);
            if(helper.findTabCount(this.tabList,this.label.CoBorrower) <  noOfCoBorrowerAllowed){
                const result = await this.coborrowerAddition(event);
                console.log('275 result: ', result);
                // if (result) {
                //     this.navigateCoborrower();
                // }
            }
        }else{
            if (this.tabList.length <= 1) {
                const result = await this.coborrowerAddition(event);
                console.log('275 result: ', result);
                if (result) {
                    this.navigateCoborrower();
                }
            }
        }
    }

    async coborrowerAddition(event) {
        // if(helper.findTabCount(this.tabList,this.label.CoBorrower)==0){
        // if (this.tabList.length <= 1) {
            // this.tabList.push(this.label.CoBorrower);
        this.tabList.push({"applicantType": event.detail.type, "applicantId": event.detail.id});
        console.log('tablist  = > ', JSON.stringify(this.tabList), this.tabList.length);
        this.tabListCount = this.tabList.length; //IND-2373
        // setTimeout(() => {
        //     this.template.querySelector(`lightning-tabset[data-id="applicantTabSet"]`).activeTabValue = event.detail.id;
        // }, 1000);
        return true;
        // }
    }

    //Methods
    async toCoborrower() {
        console.log('Addition of coborrower tab $$$ ');
        let result = await getTabList({ loanApplicationId: this.recordId });
        if (result && result.length > 0) {
            this.tabList = result;
        }
        helper.toCoborrower(this);
    }

    toGuarantor(){
        helper.toGuarantor(this);
    }

    toBeneficiary(){
        helper.toBeneficiary(this);
    }

    modifyTabList(event){
        helper.toModifyTabList(this,event);
    }

    handleBorrowerIncomeSource(event) {
        console.log('Event Value::', event.detail);
        this.borroweIncomeSource = event.detail;
    }

    renderedCallback() {
        loadStyle(this, LightningCSS);
        //CISP-2390
        if(this.isRevokeApplication){//CISP-2384

            const evt = new ShowToastEvent({
                title: 'This Loan Application is Revoked',
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        }
        //CISP-2390
    }

    handleActive(event) {
        this.activeTab = event.target.label;
        this.activeTabId = event.target.value;
    }
    // CISP-1196
    async submit(event){ 
        try {
            console.log('submit event');
            this.switchScreen(event);
            this.currentStage = await getLoanApplicationStageName({ 'loanApplicationId': this.recordId });
            if(this.currentStage == 'Loan Initiation'){
                this.updateSubStageField(Addition_Details_Capture); 
            
                if(this.applicantNumber == null && this.productType=='Two Wheeler'){
                    const evt = new ShowToastEvent({
                        title: 'Application Number is not generated. You cannot proceed',
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    return;
                }    
            }
        } catch (error) {
            console.log(error);
        }
    }
    updateSubStageField(textVal) {
        console.log('Inside updateSubStageField' + textVal);
        const fields = {};
        fields[OPP_ID_FIELD.fieldApiName] = this.recordId;
        fields[OPPORTUNITY_STAGE.fieldApiName] = textVal;
        fields[LASTSTAGENAME.fieldApiName] = textVal;
        const recordInput = {
            fields: fields
        };
        updateRecord(recordInput).then((record) => {
            this.additionalDetail = true;
            this.loanAppilication = false;
            this.lastStageName = textVal;//CISP-519
        });
    }
    // CISP-1196

    async switchScreen(event) {
        let screenValue = event.detail;
        console.log('Next Screeen:: ' + screenValue);
        this.lastStageName = screenValue;
        
        await this.showTransferbutton(screenValue);

        if (screenValue === Addition_Details_Capture) {
          // await this.getTabListFunction();
          await getTabList({ loanApplicationId: this.recordId }).then(result => {
            console.log('getTabList -- > ', JSON.stringify(result));
            if (result.length > 0) {
                this.activeTab = result[0].applicantType;
                this.activeTabId = result[0].applicantId;
                this.tabList = result;
            } else {
                result.push({"applicantType": this.label.Borrower, "applicantId": "B-NIL"});
                // this.activeTab = this.label.Borrower;
                this.activeTab = result[0].applicantType;
                this.activeTabId = result[0].applicantId;
                this.tabList = result;
            }
            this.tabListCount = this.tabList.length;
            this.additionalDetail = true;
            this.loanAppilication = false;
        }).catch(error => {
            console.log('error::', error);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong, Please contact your administrator.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });

        } else if (screenValue === 'Asset Details') {
            console.log('Current Screeen:: ' + screenValue);
            this.getTabListFunction();
            this.AssetDetails = true;
            this.additionalDetail = false;
            this.loanAppilication = false;
        } else if (screenValue === 'Vehicle Insurance') {
            this.vehicleInsurance = true;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
        } else if (screenValue === 'Vehicle Valuation') {
            console.log('Navigate to Vehicle Valuation Screen');
            this.vehicleValuation = true;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
        } else if (screenValue === 'Loan Details') {
            console.log('loan details tab ');
            this.loanDetails = true;
            this.vehicleValuation = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
        } else if (screenValue === 'Income Details') {
            this.getTabListFunction();
            this.incomeDetails = true;
            this.insuranceDetails = false;
            this.loanDetails = false;
            this.vehicleValuation = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
        } else if (screenValue === "Insurance Details") {
           // console.log('Inside Tab Component Insurance Details');
            this.getTabListFunctionForInsurance();
            this.incomeDetails = false;
            this.insuranceDetails = true;
            this.loanDetails = false;
            this.vehicleValuation = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
            this.customerCode = false;
        } else if (screenValue === 'Final Terms') {
            this.getTabListFunction();
            console.log('Inside Tab Component Final terms');
            this.getTabListFunction();
            this.loanAppilication = false;
            this.incomeDetails = false;
            this.finalTerms = true;
            this.loanDetails = false;
            this.vehicleValuation = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
            this.showOfferScreen = false;
            this.customerCode = false;
        } //added by aditya
        else if (screenValue === 'Final Offer') {
            this.getTabListFunction();
            //alert('final offer screen');
            this.getTabListFunction();
            this.finalOffer = true;
            this.loanAppilication = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.loanDetails = false;
            this.vehicleValuation = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
            this.insuranceDetails = false;
            this.customerCode = false;
        } else if (screenValue === 'Offer Screen') {
            this.getTabListFunction();
            this.finalOffer = false;
            this.showOfferScreen = true;
            this.loanAppilication = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.loanDetails = false;
            this.vehicleValuation = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
            this.insuranceDetails = false;
            this.customerCode = false;
        } else if (screenValue === 'Customer Code Addition') {
            console.log('inside Customer Code Addition');
            this.getTabListFunction();
            this.loanAppilication = false;
            this.incomeDetails = false;
            this.showOfferScreen = false;
            this.finalTerms = false;
            this.customerCode = true;
            this.loanDetails = false;
            this.vehicleValuation = false;
            this.vehicleInsurance = false;
            this.AssetDetails = false;
            this.additionalDetail = false;
            this.loanAppilication = false;
        }
        else if (screenValue === "Credit Processing") {
            this.creditProcFlag = true;
            console.log('credit Processing flag', this.creditProcFlag);
        } 

    }

    switchincomedetailstab(event) {
        console.log('parentjs', event.detail);
        console.log('activetab', this.activeTab);
        this.activeTab = 'Co-borrower';
    }

    navigateToCreditProcessing() {
        this.creditProcFlag = true;
    }

    navigateToViewApplicationData() {
        this.creditProcFlag = true;
        window.location.reload();
    }

    async getTabListFunction() {
       await getTabList({ loanApplicationId: this.recordId }).then(result => {
            console.log('getTabList -- > ', JSON.stringify(result));
            if (result.length > 0) {
                this.activeTab = result[0].applicantType;
                this.activeTabId = result[0].applicantId;
                this.tabList = result;
            } else {
                result.push({"applicantType": this.label.Borrower, "applicantId": "B-NIL"});
                // this.activeTab = this.label.Borrower;
                this.activeTab = result[0].applicantType;
                this.activeTabId = result[0].applicantId;
                this.tabList = result;
            }
            this.tabListCount = this.tabList.length;
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

    handleStepUpdate(params) {
        console.debug(params.detail)
        const step = params.detail;
        this.stepName = params.detail;
        //Default values of all tabs
        this.AssetDetails = false;
        this.loanDetails = false;
        this.incomeDetails = false;
        this.additionalDetail = false;
        this.finalTerms = false;
        this.showOfferScreen = false;
        this.finalOffer = false;
        this.vehicleValuation = false;
        this.vehicleInsurance = false;
        this.customerCode = false;
        this.withdrawn = false;
        this.postSanctionChecks = false;
        this.preDisbursementCheck = false;
        this.creditProcFlag = false;
        this.showPaymentRequest=false;

        this.showPreInitialOffer = false;//D2C Changes Swapnil
        this.showPostInitialOffer = false;//D2C Changes Swapnil
        this.showPreApprovedOffer = false;//D2C Changes Raman

        if (step === 'credit-verification') {
            this.creditProcFlag = true;
        } else if (step === 'post-sanction') {
            this.postSanctionChecks = true;
        } else if (step === 'pre-disbursement') {
            this.preDisbursementCheck = true;
        } else if (step === 'payment-requests') {
            this.showPaymentRequest = true;
        }//START D2C Changes Swapnil
        else if (step === 'pre-initial-offer') {
            this.showPreInitialOffer = true;
        } else if (step === 'post-initial-offer') {
            this.showPostInitialOffer = true;
        }else if(step === 'pre-approved-offer') {
            this.showPreApprovedOffer = true;
        }
        //END D2C Changes Swapnil
    }

    openOverlayMneu() {
        this.showOverlayMenu = true;
    }

    closeOverlayMenu() {
        this.showOverlayMenu = false;
    }

    handleLeadDetail() {
        this.updateMenuStage('Loan Initiation');
    }

    handleAdditionalDetail() {
        this.updateMenuStage('Additional Details');
    }

    handleAssetDetail() {
        this.updateMenuStage('Asset Details');
    }

    handleVehicleInsurance() {
        this.updateMenuStage('Vehicle Insurance');
    }

    handleVehicleValuation() {
        this.updateMenuStage('Vehicle Valuation');
    }

    handleLoanDetails() {
        this.updateMenuStage('Loan Details');
    }

    handleIncomeDetails() {
        this.updateMenuStage('Income Details');
    }

    handleFinalTerms() {
        this.updateMenuStage('Final Terms');
    }

    handleOfferScreen(){
        this.updateMenuStage('Offer Screen');
    }

    handleCustCodeAddtition(){
        this.updateMenuStage('Customer Code Addition');
    }

    handleInsuranceDetails(){
        this.updateMenuStage('Insurance Details');
    }

    handleFinalOffer(){
        this.updateMenuStage('Final Offer');
    }
    currentApplicantStage;//CISP-2966
    async updateMenuStage(updatedStageName) {
        this.showOverlayMenu = false;
        let isNavigationAllowed = false;
        console.log('currentStage of Opportunity:: ', this.currentStage);
        console.log('lastStageName of Opportunity:: ', this.lastStageName);
        console.log('updatedStageName of Opportunity:: ', updatedStageName);
        if (this.lastStageName === 'Loan Initiation') {
            isNavigationAllowed = false;
        } else if (this.lastStageName === 'Additional Details') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Asset Details') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Vehicle Insurance') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Insurance') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Vehicle Valuation') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Vehicle Valuation') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Loan Details') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Loan Details') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Income Details') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Loan Details' || updatedStageName === 'Income Details') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Final Terms') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Loan Details' || updatedStageName === 'Income Details' || updatedStageName === 'Final Terms') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Offer Screen') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Loan Details' || updatedStageName === 'Income Details' || updatedStageName === 'Final Terms' || updatedStageName === 'Offer Screen') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Customer Code Addition') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Loan Details' || updatedStageName === 'Income Details' || updatedStageName === 'Final Terms' || updatedStageName === 'Offer Screen' || updatedStageName === 'Customer Code Addition') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Insurance Details') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Loan Details' || updatedStageName === 'Income Details' || updatedStageName === 'Final Terms' || updatedStageName === 'Offer Screen' || updatedStageName === 'Customer Code Addition' || updatedStageName === 'Insurance Details') {
                isNavigationAllowed = true;
            }
        } else if (this.lastStageName === 'Final Offer') {
            if (updatedStageName === 'Loan Initiation' || updatedStageName === 'Additional Details' || updatedStageName === 'Asset Details' || updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance' || updatedStageName === 'Loan Details' || updatedStageName === 'Income Details' || updatedStageName === 'Final Terms' || updatedStageName === 'Offer Screen' || updatedStageName === 'Customer Code Addition' || updatedStageName === 'Insurance Details' || updatedStageName === 'Final Offer') {
                isNavigationAllowed = true;
            }
        } 

        //CISP-519-START
        if(isNavigationAllowed && !this.forUsedVehicleType && (updatedStageName === 'Vehicle Valuation' || updatedStageName === 'Vehicle Insurance')){
            isNavigationAllowed = false;
        }
        //CISP-519-END

        console.log('isNavigationAllowed value check:: ', isNavigationAllowed);
        let applicantArray = [];//CISP-3044
        if (isNavigationAllowed === true) {
            console.log('updatedStageName and applicantID', updatedStageName);
            applicantArray = JSON.parse(JSON.stringify(this.activeApplicantList));

            if (applicantArray.length > 0) {
                for (let index in applicantArray) {
                    this.applicantId = applicantArray[index].applicantId;
                    if (updatedStageName === 'Loan Initiation' && this.lastStageName !== 'Loan Initiation') {
                        this.currentApplicantStage = 'Gatting And Screening';//CISP-2966
                    } else if (updatedStageName === 'Additional Details') {
                        if(this.lastStageName === 'Additional Details') {
                            this.currentApplicantStage = 'Current Residential Address';//CISP-2966
                        } else {
                            this.currentApplicantStage = 'Demographic Details';//CISP-2966
                        }
                    } else if (updatedStageName === 'Income Details') {
                        if(this.lastStageName === 'Income Details') {
                            this.currentApplicantStage = 'Income Details';//CISP-2966
                        } else {
                            this.currentApplicantStage = 'Run EMI Engine';//CISP-2966
                        }
                    }
                }
            }
            // await this.updateRecordDetails(oppFields);//CISP-519
        }

        console.log('updatedStageName after updateRecord :', updatedStageName);

        if (updatedStageName === "Loan Initiation" && isNavigationAllowed) {
            // if(!this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.push(this.label.CoBorrower);
            // }//CISP-3044
            this.additionOfTabBackMovement(applicantArray);
            this.loanAppilication = true;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName == "Additional Details" && isNavigationAllowed) {
            // if(!this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.push(this.label.CoBorrower);
            // }//CISP-3044
            this.additionOfTabBackMovement(applicantArray);
            this.loanAppilication = false;
            this.additionalDetail = true;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Asset Details" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = true;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Loan Details" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = true;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Vehicle Insurance" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = true;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Vehicle Valuation" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = true;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Loan Details" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = true;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Income Details" && isNavigationAllowed) {
            // if(!this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.push(this.label.CoBorrower);
            // }//CISP-3044
            this.additionOfTabBackMovement(applicantArray);
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = true;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Final Terms" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = true;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Offer Screen" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = true;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Customer Code Addition" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = true;
            this.insuranceDetails = false;
            this.finalOffer = false;
        } else if (updatedStageName === "Insurance Details" && isNavigationAllowed) {
            this.getTabListFunctionForInsurance();
            // if(!this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.push(this.label.CoBorrower);
            // }//CISP-3044
            this.additionOfTabBackMovement(applicantArray);
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = true;
            this.finalOffer = false;
        } else if (updatedStageName === "Final Offer" && isNavigationAllowed) {
            // if(this.tabList.includes(this.label.CoBorrower) && applicantArray.length > 1){
            //     this.tabList.pop(this.label.CoBorrower);
            // }//CISP-3044
            this.removalOfTabBackMovement();
            this.loanAppilication = false;
            this.additionalDetail = false;
            this.AssetDetails = false;
            this.vehicleInsurance = false;
            this.vehicleValuation = false;
            this.loanDetails = false;
            this.incomeDetails = false;
            this.finalTerms = false;
            this.showOfferScreen = false;
            this.customerCode = false;
            this.insuranceDetails = false;
            this.finalOffer = true;
        }
    }

    additionOfTabBackMovement(lst){
        this.tabList = [];
        lst.forEach(val => {
            this.tabList = [...this.tabList, { applicantId: val.applicantId, applicantType: val.applicantType }];
        });
        this.tabList.sort(function (a, b) {
            return a.applicantType < b.applicantType ? -1 : 1;
       });       
    }

    removalOfTabBackMovement(){
        this.tabList = this.tabList.filter(ele => ele.applicantType == this.label.Borrower);
    }

    //CISP-2457 /CISP-2506
    @track clearRetryCountOfEligibility = false;
    increaseRetryCountHandler(event){
        this.clearRetryCountOfEligibility = true;
    }
    //CISP-2457 /CISP-2506
    refreshPage(){
        
       /* setTimeout(function() {  
            console.log('refresh');
            const evt = new ShowToastEvent({
                title: 'Sucess',
                message: 'Recalled sucessfully',
                variant: 'success',
            });
            this.dispatchEvent(evt);  
        }, 200);*/
        window.setTimeout(() => {
            window.location.reload(true);
        }, 200);
          
    }

    async updateRecordDetails(fields) {
        this.isLoading = true;
        const recordInput = { fields };
        await updateRecord(recordInput).then(result => {
            this.isLoading = false;
            console.log('updateRecordDetails - Fields :: ',recordInput);
        }).catch(error => {
            this.isLoading = false;
            console.log('updateRecordDetails - Error :: ', error);
        });
        this.isLoading = false;
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        console.log('allElements: ',allElements);
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    get showRevokeBtn() {
        if(this.productType == 'Tractor' && this.currentStage !== 'Loan Initiation' && this.currentStage !== 'Additional Details'){
            return true;
        } else {return this.revokeBtnVisibilitySteps.has(this.stepName);}
    }
    get isTracFinalTerm(){
        return (this.productType == 'Tractor') && this.finalTerms;
    }
    get isTracFinalTerm(){
        return (this.productType == 'Tractor') && this.finalTerms;
    }

}