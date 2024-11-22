import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLoanTransactions from "@salesforce/apex/PostSanctionController.getLoanTransactions";
import getCurrentSubStage from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getCurrentSubStage';
import getLeadProductType from '@salesforce/apex/PostSanctionController.getLeadProductType';//CISP-8762
import Tractor from '@salesforce/label/c.Tractor';

export default class IND_LWC_PDChecksAndDoc extends LightningElement {
    @track dealId = null;
    @track vehicleInspectionLabel ;//CISP-8762
    @api oppId;
    @api currentStep;
    @api isRevokedLoanApplication;//CISP-2735
    showConfirmation = false;
    revoketype;
    success;
    currentSubStage = 'Tele-verification';

    @track productType;
    @track tabSetList = []; //	CISP-57 OR INDI-4606
    isTractor = false;
    async connectedCallback(){
        //CISP-8762
        await getLeadProductType({loanApplicationId:this.oppId})
        .then(result=>{
            this.isTractor = result.Product_Type__c == 'Tractor';
            if(result.Product_Type__c == 'Passenger Vehicles'  && (result.LeadSource !='OLA' && result.LeadSource != 'D2C')){
                this.vehicleInspectionLabel = 'Vehicle Inspection'
            }else{
                this.vehicleInspectionLabel = 'Vehicle Inspection and RC Check';
            }
            this.productType = result.Product_Type__c;
            if(result.Product_Type__c != Tractor){
                this.init();
            }
        })
        
    }

    async init(){
        //	CISP-57 OR INDI-4606 - START
        await getLoanTransactions({loanApplicationId:this.oppId, module:'Pre Disbursement Check', dealId: this.dealId}).then(result=>{
            let completedTabList = [{},{},{},{},{},{},{},{},{}];
            let uncompletedTabList = [{},{},{},{},{},{},{},{},{}];
            let tabSetListTemp = [];
            for (let key in result) {
                if (key) {
                    if (key === 'CAM and Conditional Approval') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : true,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            completedTabList[0] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : true,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[0] = tempObj;
                        }
                    }else if (key === 'Vehicle Inspection and RC Check') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : true,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            completedTabList[1] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : true,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[1] = tempObj;
                        }
                    }else if (key === 'Security Mandate') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : true,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            completedTabList[2] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : true,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[2] = tempObj;
                        }
                    }else if (key === 'Invoice') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : true,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            completedTabList[3] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : true,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[3] = tempObj;
                        }
                    }else if (key === 'IHM') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : true,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            completedTabList[4] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : true,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[4] = tempObj;
                        }
                    }else if (key === 'Loan Agreement') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : true,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            completedTabList[5] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : true,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[5] = tempObj;
                        }
                    }else if (key === 'Repayment Mandate') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : true,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            completedTabList[6] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : true,
                                documentsUpload : false,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[6] = tempObj;
                        }
                    }else if (key === 'RTO, DPN, POA Documents Upload') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : true,
                                additionalDocuments : false,
                            }
                            completedTabList[7] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : true,
                                additionalDocuments : false,
                            }
                            uncompletedTabList[7] = tempObj;
                        }
                    }else if (key === 'Additional Documents') {
                        if (result[key]) {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : true,
                            }
                            completedTabList[8] = tempObj;
                        } else {
                            let tempObj = {
                                preDisbursementCheck : false,
                                vehicleInspectionAndRCCheck : false,
                                securityMandate : false,
                                invoice : false,
                                ihm : false,
                                loanAgreement : false,
                                repaymentMandate : false,
                                documentsUpload : false,
                                additionalDocuments : true,
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

        await getLoanTransactions({loanApplicationId:this.oppId, module:'Pre Disbursement Check', dealId: this.dealId})//CISP-57 OR INDI-4606 - Added await
        .then((result)=>{
            for(let key in result){
                if(key){
                    if(key==='Security Mandate'){
                        let elem=this.template.querySelector('.SecurityMandate');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Invoice'){
                        let elem=this.template.querySelector('.Invoice');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Loan Agreement'){
                        let elem=this.template.querySelector('.LoanAgreement');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Repayment Mandate'){
                        let elem=this.template.querySelector('.RepaymentMandate');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Additional Documents'){
                        let elem=this.template.querySelector('.AdditionalDocuments');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Initiate RCU'){
                        let elem=this.template.querySelector('.InitiateRCU');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Structured EMI'){
                        let elem=this.template.querySelector('.StructuredEMI');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='IHM'){
                        let elem=this.template.querySelector('.IHM');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Vehicle Inspection and RC Check'){
                        let elem=this.template.querySelector('.VehicleInspectionAndRCCheck');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='Signing the e-Agreement'){
                        let elem=this.template.querySelector('.SigningEAgreement');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='RTO, DPN, POA Documents Upload'){
                        let elem=this.template.querySelector('.DocumentsUpload');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='RCU Manager'){
                        let elem=this.template.querySelector('.RCUManager');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }else if(key==='CAM and Conditional Approval'){
                        let elem=this.template.querySelector('.PreDisbursementCheck');
                        if(result[key]){
                            elem.iconName='utility:success';
                        }else{
                            elem.iconName=undefined;
                        }
                    }
                }
            }
            console.log('Result '+JSON.stringify(result));
        }).catch((error)=>{
            console.log('getLoanTransactions error '+error);
        })

        await getCurrentSubStage({loanApplicationId:this.oppId})////CISP-57 OR INDI-4606 - Added await
        .then(result=>{
            if(result){
                this.currentSubStage = result;
            }
        })
    }
    
    onSubmitRevokeEvent(event)
    {
        this.revoketype='General Revoke';
        this.showConfirmation = true;   
    }
    onSubmitBorrowerEvent(event) {
        this.revoketype='Add/Change Co-borrower';
        this.showConfirmation = true;
    }
    oncancelselection(event){
        this.showConfirmation = event.detail.showConfirmation;
    }

    ontoastselection(event){
        this.success = event.detail.success;
        console.log("Success",this.success);
        if(this.success== true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Revoke Initiated',
                    variant: 'success',
                }),
            );
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error occured while initiating Revoke',
                    variant: 'error',
                }),
            );
        }
    }
    
    dealNumberHandler(event){
        if(event.detail && this.productType == Tractor){ 
            this.dealId = event.detail;
            this.tabSetList = [];
            this.init();
        }
    }

}