import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLoanTransactions from "@salesforce/apex/PostSanctionController.getLoanTransactions";
import getLeadProductType from '@salesforce/apex/PostSanctionController.getLeadProductType';//CISP-8762

export default class IND_LWC_PSChecksAndDoc extends LightningElement {
    @track vehicleInspectionLabel;//CISP-8762
    @api currentStep;
    @api oppId;
    @api isRevokedLoanApplication;//CISP-2735
    showConfirmation = false;
    revoketype;
    success;
    isOpenWarningModel = false;
    warningSubmitFunction;
    warningMessage = "You have unsaved changes. Do you want to save it?";
    activeTabCmpName;
    currentTab;
    warningCmpArray = [];
    isIHMVisible = false;
    tabArray = {};
    currentTabDetails;
    previousTab;
    isLoading = false;
    structuredEMILabel;
    initTabDetails() {
        this.tabArray["Vehicle Inspection"] = {
            cmpName: "c-i-N-D-_-L-W-C-_capture-Vehicle-Inspection-R-C-Limit",
            submitFunction: "handleSubmitVehicleInspectionFromParent",
            warningMessage: "You have unsaved changes on Vehicle Inspection and RC Check. Do you want to save it?",
            isSubmitDisabledFlag: "disableSubmitVehicleInspectionButton",
            flagValueToCheck: false
        };
        this.tabArray["Structured EMI"] = {
            cmpName: "c-i-N-D-_-L-W-C-_-Structured-E-M-I",
            submitFunction: "handleSubmitFromParent",
            warningMessage: "You have unsaved changes on Structured EMI. Do you want to save it?",
            isSubmitDisabledFlag: "isValueChange",
            flagValueToCheck: true
        };
        this.tabArray["Security Mandate"] = {
            cmpName: "c-i-N-D-_-L-W-C-_-Security-Mandate",
            submitFunction: "handleSubmitFromParent",
            warningMessage: "You have unsaved changes on Security Mandate. Do you want to save it?",
            isSubmitDisabledFlag: "isSubmitDisabled",
            flagValueToCheck: false
        };
        this.tabArray["Addtional Documents"] = {
            cmpName: "c-i-N-D-_-L-W-C-_-Addtional-Documents",
            submitFunction: "handleSubmitFromParent",
            warningMessage: "You have unsaved changes on Additional Documents. Do you want to save it?",
            isSubmitDisabledFlag: "isSubmitDisabled",
            flagValueToCheck: false
        };
        this.tabArray["Invoice"] = {
            cmpName: "c-i-N-D-_-L-W-C-_capture-Invoice-Details",
            submitFunction: "handleSubmitFromParent",
            warningMessage: "You have unsaved changes on Invoice tab. Do you want to save it?",
            isSubmitDisabledFlag: "isSubmitButtonEnable",
            flagValueToCheck: false
        };
        this.tabArray["Repayment Mandate"] = {
            cmpName: "c-i-N-D-_-L-W-C-_-Repayment-Mandate-Parent",
            submitFunction: "handleSubmitRepaymentDetails",
            warningMessage: "You have unsaved changes on Repayment Mandate. Do you want to save it?",
            isSubmitDisabledFlag: "isInputChanged",
            flagValueToCheck: true
        };
        this.tabArray["RTODocUpload"] = {
            cmpName: "c-i-N-D-_-L-W-C-_-R-T-O-_-D-P-N-_-P-O-A-_-Document-Upload",
            submitFunction: "disableSubmitBtn",
            warningMessage: "You have unsaved changes on RTO, DPN, POA Documents Upload tab. Do you want to save it?",
            isSubmitDisabledFlag: "isSubmitDisabled",
            flagValueToCheck: false
        };
        this.tabArray["IHM"] = {
            cmpName: "c-i-N-D-_-L-W-C-_-I-H-M-Page",
            submitFunction: "submitHandler",
            warningMessage: "You have unsaved changes on IHM tab. Do you want to save it?",
            isSubmitDisabledFlag: "isReadOnly",
            flagValueToCheck: false
        };

    }
    isTractor = false;
    @track tabSetList = []; //	CISP-57 OR INDI-4606
    productType;
    async connectedCallback(){
        await getLeadProductType({loanApplicationId:this.oppId})////CISP-57 OR INDI-4606 - Added await
        .then(result=>{
this.isTractor = result.Product_Type__c == 'Tractor';
            if(result.Product_Type__c == 'Passenger Vehicles'  && (result.LeadSource !='OLA' && result.LeadSource != 'D2C')){
                this.vehicleInspectionLabel = 'Vehicle Inspection'
            }else{
                this.vehicleInspectionLabel = 'Vehicle Inspection and RC Check';
            }
            if(this.isTractor){
                this.structuredEMILabel = 'EMI Details';
            } else {
                this.structuredEMILabel = 'Structured EMI';
            }
            this.productType = result?.Product_Type__c;
            if(this.productType != 'Tractor'){
                this.init();
            }
        })
        
    }
    async init() {
        this.currentTab = "Security Mandate";
        this.initTabDetails();
        //	CISP-57 OR INDI-4606 - START
        await getLoanTransactions({ loanApplicationId: this.oppId, module: 'Post Sanction Checks and Documentation', dealId: this.dealId }).then(result=>{
            let completedTabList = [{},{},{},{},{},{},{},{},{}];
            let uncompletedTabList = [{},{},{},{},{},{},{},{},{}];
            let tabSetListTemp = [];
            for (let key in result) {
                if (key) {
                    if (key === 'Vehicle Inspection and RC Check') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : true,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            completedTabList[0] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : true,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            uncompletedTabList[0] = tempObj;
                        }
                    }else if (key === 'Structured EMI') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : true,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            completedTabList[1] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : true,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            uncompletedTabList[1] = tempObj;
                        }
                    }else if (key === 'Security Mandate') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : true,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            completedTabList[2] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : true,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            uncompletedTabList[2] = tempObj;
                        }
                    }else if (key === 'Additional Documents') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : true,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            completedTabList[3] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : true,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            uncompletedTabList[3] = tempObj;
                        }
                    }else if (key === 'Invoice') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : true,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            completedTabList[4] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : true,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            uncompletedTabList[4] = tempObj;
                        }
                    }else if (key === 'IHM') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : true,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            completedTabList[5] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : true,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            uncompletedTabList[5] = tempObj;
                        }
                    }else if (key === 'Loan Agreement') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : true,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            completedTabList[6] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : true,
                                repaymentMandate : false,
                                documentsUpload : false,
                            }
                            uncompletedTabList[6] = tempObj;
                        }
                    }else if (key === 'Repayment Mandate') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : true,
                                documentsUpload : false,
                            }
                            completedTabList[7] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : true,
                                documentsUpload : false,
                            }
                            uncompletedTabList[7] = tempObj;
                        }
                    }else if (key === 'RTO, DPN, POA Documents Upload') {
                        if (result[key]) {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : true,
                            }
                            completedTabList[8] = tempObj;
                        } else {
                            let tempObj = {
                                vehicleInspectionAndRCCheck : false,
                                structuredEMI : false,
                                securityMandate : false,
                                additionalDocuments : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : true,
                            }
                            uncompletedTabList[8] = tempObj;
                        }
                    }
                }
            }
            tabSetListTemp = uncompletedTabList.concat(completedTabList);
            this.tabSetList = tabSetListTemp;
        }).catch(error=>{
            console.log('error getLoanTransactions in ', error);
        });
        //	CISP-57 OR INDI-4606 - END
        
        await getLoanTransactions({ loanApplicationId: this.oppId, module: 'Post Sanction Checks and Documentation', dealId: this.dealId })//CISP-57 OR INDI-4606 - Added await
            .then((result) => {
                for (let key in result) {
                    if (key) {
                        if (key === 'Security Mandate') {
                            let elem = this.template.querySelector('.SecurityMandate');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Invoice') {
                            let elem = this.template.querySelector('.Invoice');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Loan Agreement') {
                            let elem = this.template.querySelector('.LoanAgreement');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Repayment Mandate') {
                            let elem = this.template.querySelector('.RepaymentMandate');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Additional Documents') {
                            let elem = this.template.querySelector('.AdditionalDocuments');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Initiate RCU') {
                            let elem = this.template.querySelector('.InitiateRCU');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Structured EMI') {
                            let elem = this.template.querySelector('.StructuredEMI');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'IHM') {
                            let elem = this.template.querySelector('.IHM');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Vehicle Inspection and RC Check') {
                            let elem = this.template.querySelector('.VehicleInspectionAndRCCheck');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Signing the e-Agreement') {
                            let elem = this.template.querySelector('.SigningEAgreement');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'RTO, DPN, POA Documents Upload') {
                            let elem = this.template.querySelector('.DocumentsUpload');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'RCU Manager') {
                            let elem = this.template.querySelector('.RCUManager');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        } else if (key === 'Pre-Disbursement Check') {
                            let elem = this.template.querySelector('.PreDisbursementCheck');
                            if (result[key]) {
                                elem.iconName = 'utility:success';
                            } else {
                                elem.iconName = undefined;
                            }
                        }
                    }
                }
                console.log('Result ' + JSON.stringify(result));
            }).catch((error) => {
                console.log('getLoanTransactions error ' + error);
            })
    }
    onActiveTab(event) {
            let isWarningRequired = false;
            this.previousTab = this.currentTab;
            console.log('IHM currenttab onactive ', isWarningRequired, ' ', this.currentTab);// Gaurav
            this.currentTabDetails = this.tabArray[this.currentTab];
            console.log('this.currentTabDetails : ',this.currentTabDetails);
            if (this.currentTabDetails) {
                console.log('this.currentTabDetails.cmpName : ',this.currentTabDetails.cmpName);
                
                setTimeout(() => {
                    let componentInstance = this.template.querySelector(this.currentTabDetails.cmpName);
                    console.log('componentInstance : ',componentInstance);
                console.log('componentInstance[this.currentTabDetails.isSubmitDisabledFlag] : ',componentInstance[this.currentTabDetails.isSubmitDisabledFlag]);
                if (componentInstance[this.currentTabDetails.isSubmitDisabledFlag] == this.currentTabDetails.flagValueToCheck) {
                    isWarningRequired = true;
                    this.warningMessage = this.currentTabDetails.warningMessage;
                }
            }, 1000);
                
                
            }

            /*if (this.currentActiveTab == "Vehicle Inspection") {
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_capture-Vehicle-Inspection-R-C-Limit";
    
                let vehicalInspectorCmp = this.template.querySelector(this.activeTabCmpName);
                if (vehicalInspectorCmp.disableSubmitVehicleInspectionButton != true) {
                    isWarningRequired = true;
                    this.warningSubmitFunction = "handleSubmitVehicleInspection";
                    this.warningMessage = "You have unsaved changes on Vehicle Inspection and RC Check. Do you want to save it?";
                }
    
    
            }
            if (this.currentActiveTab == "Structured EMI") {
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_-Structured-E-M-I";
                let structuredEmiCmp = this.template.querySelector("c-i-N-D-_-L-W-C-_-Structured-E-M-I");
    
                if (structuredEmiCmp.isValueChange == true) {
                    isWarningRequired = true;
                    this.warningSubmitFunction = "handleSubmitFromParent";
                    this.warningMessage = "You have unsaved changes on Structured EMI. Do you want to save it?";
                }
            }
            else if (this.currentActiveTab == 'Security Mandate') {
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_-Security-Mandate";
                let securityMandateCmp = this.template.querySelector(this.activeTabCmpName);
    
                if (securityMandateCmp.isSubmitDisabled != true) {
                    isWarningRequired = true;
                    this.warningSubmitFunction = "handleSubmitFromParent";
                    this.warningMessage = "You have unsaved changes on Security Mandate. Do you want to save it?";
                }
            }
            else if (this.currentActiveTab == 'Addtional Documents') {
                console.log('Addtional Documents inside : ',);
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_-Addtional-Documents";
                let additionalDocumentCmp = this.template.querySelector(this.activeTabCmpName);
                console.log('additionalDocumentCmp.isSubmitDisabled : ', additionalDocumentCmp.isSubmitDisabled);
                if (additionalDocumentCmp.isSubmitDisabled != true) {
                    isWarningRequired = true;
                    this.warningSubmitFunction = "handleSubmit";
                    this.warningMessage = "You have unsaved changes on Additional Documents. Do you want to save it?";
                }
            }
            else if (this.currentActiveTab == 'Invoice') {
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_capture-Invoice-Details";
                let additionalDocumentCmp = this.template.querySelector(this.activeTabCmpName);
                if (additionalDocumentCmp.isSubmitButtonEnable != true) {
                    isWarningRequired = true;
                    this.warningSubmitFunction = "handleSubmitFromParent";
                    this.warningMessage = "You have unsaved changes on Invoice tab. Do you want to save it?";
                }
    
            } else if (this.currentActiveTab == 'Repayment Mandate') {
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_-Repayment-Mandate-Parent";
                let repaymentCmp = this.template.querySelector(this.activeTabCmpName);
                if (repaymentCmp.isSubmitDisabled != true) {
                    isWarningRequired = true;
                    this.warningSubmitFunction = "handleSubmitRepaymentDetails";
                    this.warningMessage = "You have unsaved changes on Repayment Mandate. Do you want to save it?";
                }
            }
            else if (this.currentActiveTab == 'RTODocUpload') {
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_-R-T-O-_-D-P-N-_-P-O-A-_-Document-Upload";
                let rtoDocTabCmp = this.template.querySelector(this.activeTabCmpName);
                if (rtoDocTabCmp.disableSubmitBtn != true) {
                    isWarningRequired = true;
                    this.warningSubmitFunction = "handleSubmitDocuments";
                    this.warningMessage = "You have unsaved changes on RTO, DPN, POA Documents Upload tab. Do you want to save it?";
                }
            } else if (this.currentActiveTab == 'IHM') { // Gaurav
                console.log('IHM currenttab');// Gaurav
                this.activeTabCmpName = "c-i-N-D-_-L-W-C-_-I-H-M-Page";
                let ihmTabCmp = this.template.querySelector(this.activeTabCmpName);
                if (ihmTabCmp.isReadOnly != true) {
                    console.log('IHM curr tab -- > ', ihmTabCmp.isReadOnly);
                    isWarningRequired = true;
                    this.warningSubmitFunction = "submitHandler";
                    this.warningMessage = "You have unsaved changes on IHM tab. Do you want to save it?";
                }
            }*/

            if (isWarningRequired == true) { /*&& !this.warningCmpArray.includes(this.activeTabCmpName)) {*/
                this.isOpenWarningModel = true;
                /*this.warningCmpArray.push(this.activeTabCmpName);*/
                this.newTab = event.target.value;
            }

            this.currentTab = event.target.value;
            console.log('this.currentActiveTab -- > ', this.currentTab);
    }
    
    handlerIHMSubmitted(event) {
        this.template.querySelector('.IHM').iconName = 'utility:success';
    }
    handleSubmit() {

        //this.warningCmpArray = this.warningCmpArray.filter(value => value !== this.activeTabCmpName);
        //this.warningSubmitFunction = this.vehicalInspectorCmp.handleSubmitVehicleInspection();
        let componentInstance = this.template.querySelector(this.currentTabDetails.cmpName);
        console.log('cmpInstance : ', componentInstance);
        console.log('warningSubmitFunction : ', this.currentTabDetails.submitFunction);
        //cmpInstance[this.warningSubmitFunction](null);
        try {
            this.isLoading = true;
            console.log('OUTPUT @@@@: ', componentInstance[this.currentTabDetails.submitFunction](null));
            /*if(componentInstance[this.currentTabDetails.isSubmitDisabledFlag] != this.currentTabDetails.flagValueToCheck){
                this.currentTab = this.newTab;
            }
            else{
                this.template.querySelector('lightning-tabset').activeTabValue = this.previousTab;
            }*/

        }
        catch (e) {
            this.isLoading = false;
            this.template.querySelector('lightning-tabset').activeTabValue = this.previousTab;
        }
        this.closeModal();

    }

    handleSubmitActionResult(event) {
        let isSuccess = event.detail.isSuccess;
        console.log('handleSubmitActionResult : ', isSuccess);
        if (isSuccess == false) {
            this.template.querySelector('lightning-tabset').activeTabValue = this.previousTab;
        }
        this.isLoading = false;
    }
    closeModal() {
        console.log('in close modal  : ',);
        this.isOpenWarningModel = false;



    }
    onSubmitRevokeEvent(event) {
        this.revoketype = 'General Revoke';
        this.showConfirmation = true;
    }
    onSubmitBorrowerEvent(event) {
        this.revoketype = 'Add/Change Co-borrower';
        this.showConfirmation = true;
    }
    oncancelselection(event) {
        this.showConfirmation = event.detail.showConfirmation;
    }

    ontoastselection(event) {
        this.success = event.detail.success;
        console.log("Success", this.success);
        if (this.success == true) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Revoke Initiated',
                    variant: 'success',
                }),
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error occured while initiating Revoke',
                    variant: 'error',
                }),
            );
        }
    }

    @track dealId = null;
    async dealNumberHandler(event){
        if(event.detail && this.productType == 'Tractor'){ 
            this.dealId = event.detail;
            this.tabArray = {};
            this.tabSetList = [];
            this.init();
        }
    }


}