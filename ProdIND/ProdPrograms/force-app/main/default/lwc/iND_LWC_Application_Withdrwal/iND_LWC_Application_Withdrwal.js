import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LoanApplication from '@salesforce/schema/Opportunity';
import WithdrawalReason_Field from '@salesforce/schema/Opportunity.Withdrawal_Reason__c';
import getApplication from '@salesforce/apex/Application_withdrwalController.getApplication';
import { NavigationMixin } from 'lightning/navigation';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import isPaymentRequestGenerated from '@salesforce/apex/LoanDisbursementController.isPaymentRequestGenerated';

import TRACTOR_ProductType from '@salesforce/label/c.Tractor';
import loanApplicationRevoke from '@salesforce/apex/IND_RevokeController.loanApplicationRevoke'; // Revoke Loan Application
import getRCUDocumentsList from '@salesforce/apex/IND_RevokeController.getRCUDocumentsList';
import updateClonedLoanApplicationOwner from '@salesforce/apex/IND_RevokeController.updateClonedLoanApplicationOwner'; // CISP-2452
import upsertRecordDetails from '@salesforce/apex/IND_RevokeController.upsertRecordDetails'; // INDI-4342/CISP-503 Modified
import isRevokedLoanApplication from '@salesforce/apex/IND_RevokeController.isRevokedLoanApplication'; // CISP-2390
import isUserSelectionLookupRequiredOnRevoke from '@salesforce/apex/IND_RevokeController.isUserSelectionLookupRequiredOnRevoke'; //CISP-4628
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';
import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import EXCEPTIONMESSAGE from '@salesforce/label/c.ExceptionMessage';

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
import haveLeadAccesibility from '@salesforce/apex/LwcLOSLoanApplicationCntrl.haveLeadAccesibility';

import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';//CISP-503
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Bureau_Pull_Match__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Match__c';
import Bureau_Pull_Message__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Message__c';
//Modified for D2C by Rohan
import { getRecord } from 'lightning/uiRecordApi';
import OPP_LEAD_SORCE from '@salesforce/schema/Opportunity.LeadSource';
import OPP_PROD_TYPE from '@salesforce/schema/Opportunity.Product_Type__c';
import isTractorLoanApplication from '@salesforce/apex/IND_RevokeController.isTractorLoanApplication';//SFTRAC-166
import checkCIBILFetchDate from '@salesforce/apex/LoanDisbursementController.checkCIBILFetchDate';//SFTRAC-2277

const columns = [
    {
        label : 'View',
        type : 'button-icon',
        typeAttributes:{
            iconName:'action:preview',
            title: 'Preview',
            variant: 'border-filled',
            alternativeText: 'View'
        }
    },
    {label : 'Document Type',fieldName : 'documentType',type:'text'},
    {label : 'Applicant Type',fieldName : 'applicantType',type:'text'}];
//End of D2C Code
import storingCIBILDetails from '@salesforce/apex/ExternalCAMDataController.storingCIBILDetails';

export default class IND_LWC_Application_Withdrwal extends NavigationMixin(LightningElement) {
    @track openCoBorrowerRevokeOption = false;//SFTRAC-2277
    @track typeOptions;
    @api isModalOpen = false;
    @api hideButton = false;
    @track reasons;
    @api recordId;
    @api currentStage;//CISP-3255
    @api currentStep;//CISP-3255
    @api checkleadaccess;//coming from tabloanApplication
    @api showRevokeBtn = false;
    showRevokeModal = false;
    isRevokedLoanApplication;//CISP-2390
    disableRevokeBtn;
    showConfirmRevokeModal = false;
    d2cTWDisabled;
    isPV = false;
    //CISP-4628 Start
    showUserSelectionLookupOnRevoke = false;
    benName;
    benCode;
    branchAccountId;
    isUserSelected = false;
    selectedUserName;
    selectedUserId;
    revokeData = {};
    //CISP-4628 End
    ph1TWRevokeErr;//CISP-14306
    columns = columns;
    documentData= [];
    isSelected = false;
    @track selectedDocument = [];
    @track tableData =[];
    @track showMessage = false;
    @track tableProps = {};
    prodType;
    docId = [];
    @track documentId;
    isTractorApp = false;//SFTRAC-166
    @track isPELead = false;//SFTRAC-166
    @track isBELead = false;
    @track showRevokeModalForTractor = false;//SFTRAC-166
    @track revokeTypeValue ;//SFTRAC-166
    @track selectedRCUDocId = [];

    get disabledRevokeBtn(){
        return this.disableRevokeBtn || this.d2cTWDisabled;
    }
    //CISP-4628
    get isConfirmDisabled() {
        return this.showUserSelectionLookupOnRevoke == false ? false : this.isUserSelected == true ? false : true;
    }
    //D2C Change
    @wire(getRecord, { recordId: '$recordId', fields: [OPP_LEAD_SORCE, OPP_PROD_TYPE] })
    opportunity({ error, data }) {
    if (data) {
        console.log('d@c--'+data.fields.LeadSource.value);
        let source=data.fields.LeadSource.value;
        this.prodType = data.fields.Product_Type__c.value;
        if(source === 'D2C' && this.prodType === 'Two Wheeler'){
            this.d2cTWDisabled = true;
            console.log('this.source--'+this.source);
        }
        if(this.prodType === 'Passenger Vehicles'){
            this.isPV = true;
        }
    } else if (error) {
        console.log('error-->'+JSON.stringify(error));
    }
    }
    //EO D2C Change

    //CISP-2390
    renderedCallback(){
        if(this.checkleadaccess || this.isRevokedLoanApplication || this.disableRevokeBtn){//CISP-3255
            if(this.template.querySelector(`lightning-button[data-id="revokedBtn"]`)){
                this.template.querySelector(`lightning-button[data-id="revokedBtn"]`).disabled = true;
            }
        }
        if(this.disbableWithdrawn && this.isTractorApp){
            if(this.template.querySelector(`lightning-button[data-id="withdrawnBtn"]`)){
                this.template.querySelector(`lightning-button[data-id="withdrawnBtn"]`).disabled = true;
            }
        }
    }
    //CISP-2390
//SFTRAC-166 start
    get revokeReasonVal(){
        let revokeValues = [];
        if(this.isPELead){
            revokeValues.push({ label: 'Pay-in and Payout changes', value: 'payandpayoutchanges' });
            if(this.openCoBorrowerRevokeOption && this.currentStage == 'Disbursement Request Preparation'){
                revokeValues.push({ label: 'Remove Co-Borrower/Add Co-Borrower', value: 'removecoborroweraddcoborrowerbypeuser' });
            }
            return revokeValues;    
        }
        else if(this.isBELead){
            revokeValues.push({ label: 'Remove Co-Borrower/Add Co-Borrower', value: 'removecoborroweraddcoborrower' },{ label: 'Asset modifications', value: 'assetmodifications' });
            return revokeValues;
        }else{
        revokeValues.push({ label: 'Remove Co-Borrower/Add Co-Borrower', value: 'removecoborroweraddcoborrower' },{ label: 'Asset modifications', value: 'assetmodifications' },{ label: 'Any Loan information changes', value: 'anyloaninformationchanges' });
            return revokeValues;
    }
    }//SFTRAC-166 end

    @wire(getObjectInfo, { objectApiName: LoanApplication })
    LoanApphistoryMetadata;

    @wire(getPicklistValues, { recordTypeId: '$LoanApphistoryMetadata.data.defaultRecordTypeId', fieldApiName: WithdrawalReason_Field })
    typePicklist({ data, error }) {
        if (data) {
            //  alert('data is'+JSON.stringify(data))
            this.typeOptions = data.values;
        } if (error) {
            //  alert('error is'+JSON.stringify(error))
        }
    }
    disbableWithdrawn=false;
    async connectedCallback(){
        //SFTRAC-166
        isTractorLoanApplication({ loanApplicationId: this.recordId })
        .then(result => {
          console.log('Result', result);
          let data = JSON.parse(result);
          this.isTractorApp = data?.productType == 'Tractor' ? true : false;
          this.isPELead = (data?.profileName == 'IBL TF Payment Executive' || data?.profileName == 'IBL TF Internal Payment Executive') ? true : false;
          this.isBELead = (data?.profileName == 'IBL TF Business Executive' || data?.profileName == 'IBL Partner Community TF Business Executive') ? true : false;
          console.log('OUTPUT isTractorApp: ',this.isTractorApp);
        })
        .catch(error => {
          console.error('Error:', error);
      });
        //CISP: CISP-3026
         await haveLeadAccesibility({ leadApplicationId: this.recordId}).then(response => {
            if(!response){
                this.disbableWithdrawn = true;
            }
         console.log('haveLeadAccesibility result:: ', response);
        }).catch(error => {
         console.log('haveLeadAccesibility error:: ', error);
        })
        //CISP-4628 Start
        await isUserSelectionLookupRequiredOnRevoke({ loanApplicationId: this.recordId })
            .then(response => {
                let result = JSON.parse(response);
                if (result.isUserSelectionNeeded) {
                    this.showUserSelectionLookupOnRevoke = true;
                    this.benCode = result.benCode;
                    this.benName = result.benName;
                    this.revokeData.branchAccountId = result.branchAccountId;
                } else if(result?.ph1TWRevokeErr) {
                    this.ph1TWRevokeErr = result.ph1TWRevokeErr;
                }
            })
            .catch(error => {
                console.log('isUserSelectionLookupRequiredOnRevoke error:: ', error);
            });
        //CISP-4628 End

        
        /*if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
            console.log('from tab loan');
            this.disbableWithdrawn=true;
          
            console.log('The button is diable', this.disbableWithdrawn)
        }*/
    

        // JIRA ticket:  INDI-4678 , Imperative call to isPaymentRequestGenerated method
        //checking if, payment req is generated then disabled the withdraw button on UI
        isPaymentRequestGenerated({ loanApplicationId: this.recordId })
        .then(response => {
            if(response === true)
            {
                this.disbableWithdrawn = true;
                this.disableRevokeBtn = true;
                setTimeout(() => {
                    this.renderedCallback();
                },);
            }
        })
        .catch(error => {
            console.error(error);
        });
        
       
        //CISP-2390
        isRevokedLoanApplication({ loanApplicationId: this.recordId }).then(result => {
            this.isRevokedLoanApplication = result;
            setTimeout(() => {
                this.renderedCallback();
            },);
        }).catch(error=> {
            console.log('error in isRevokedLoanApplication ',error);
        });
        //CISP-2390
        await checkCIBILFetchDate({loanApplicationId:this.recordId}).then(result =>{if(result){this.openCoBorrowerRevokeOption = true;this.disbableWithdrawn = true}}).catch(error =>{console.log('error getInvoiceRecord',error)}); 
    }
    openModal() {
        this.isModalOpen = true;
        console.log('this.recordId', this.recordId);

    }
    closeModal() {
        this.isModalOpen = false;

    }

    handleTypeChange(event) {
        this.reasons = event.target.value;
        console.log('this.reasons', this.reasons);
        console.log('this.recordId', this.recordId);
    }

    handleSubmit() {
        if (this.reasons != null) {
            getApplication({ oppId: this.recordId, reason: this.reasons })
                .then(response => {
                    console.log("response <--48-->", response);
                    if (response == true) {
                        const event = new ShowToastEvent({
                            title: 'Message',
                            message: 'Application Withdrawn Successfully',
                            variant: 'Success'
                        });
                        this.dispatchEvent(event);
                        this.isModalOpen = false;

                        this.navigateToHomePage();
                    }
                })
                .catch(error => {
                    console.log("Error <--59-->", error);

                });
        } else {
            const event = new ShowToastEvent({
                title: 'Message',
                message: 'Please Enter Withdrawn Reason',
                variant: 'Error'
            });
            this.dispatchEvent(event);
        }

    }
    navigateToHomePage() {
        isCommunity()
            .then(response => {
                console.log('response',response);
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

    handleRowAction(event){
        this.fileId = event.detail.row.contentDocumentId;
             this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: this.fileId
            }
        });
        
    }
    handleRevokeBtnClick() {
        if(this.prodType == TRACTOR_ProductType){
            this.showRevokeModalForTractor = true;
            this.revokeTypeValue = '';
            getRCUDocumentsList({loanApplicationId : this.recordId}).then(response =>{
           // console.log('response==>'+JSON.stringify(response));
            if(response){
                this.tableData = response;
                // this.documentId = response.contentDocuId;
               // console.log(' this.documentId', JSON.stringify(this.documentId));
                // this.documentId.forEach(currentItem => {
                //     this.docId.push(currentItem.ContentDocumentId);
                // });
               // console.log('docId=>',JSON.stringify(this.docId));
               }
          })
        }else{
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
        //CISP-4628 End
        }
    }
}

    closeRevokeModal() {
        if(this.isTractorApp){
            this.showRevokeModalForTractor = false;
        }else
        this.showRevokeModal = false;
    }
    closeRevokeConfirmModal(){
        this.showConfirmRevokeModal = false;
    }
   
    showSpinner = false;

    handleRowSelection(event){
        const selectedRow = event.detail.selectedRows;
        this.selectedDocument = selectedRow;
        let selectedDoc = [];
        this.selectedDocument.forEach(document=>{
            selectedDoc.push(document.documentId);
        });
        this.selectedRCUDocId = selectedDoc;
        if(selectedRow){
            this.isSelected = true;
        }
      
    }
    async handleRevokeConfirm() {//CISP-2452
        try {
            this.showRevokeModal = false;
            this.showSpinner = true;
            this.showConfirmRevokeModal = false;
            let revokeTyepVal;
            if(this.prodType == TRACTOR_ProductType){
                revokeTyepVal = this.revokeTypeValue;
            }else{
                revokeTyepVal = 'General Revoke';
            }
            //let responseObj;//CISP-2452
            this.showSpinner = true;
            let responseObj;//CISP-2452
            let response = await loanApplicationRevoke({ loanApplicationId : this.recordId, revokeType : revokeTyepVal, newOwnerId : (this.showUserSelectionLookupOnRevoke?this.selectedUserId:''), documentId: this.selectedRCUDocId });
                console.log('response ',response);
                if (response) {
                    responseObj = JSON.parse(response);//CISP-2452
                    if(revokeTyepVal == 'General Revoke'){
                        if(responseObj.clonedLoanApplicationId){
                            await updateClonedLoanApplicationOwner({loanApplicationId : this.recordId,clonedLoanAppId:responseObj.clonedLoanApplicationId, newOwnerId : (this.showUserSelectionLookupOnRevoke?this.selectedUserId:'')}).then(()=>{}).catch(error=>{//CISP-4628
                                this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
                            });
                        }
                        if(responseObj.clonedApplicantsId.clonedPrimaryApplicantId){
                        await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedPrimaryApplicantId);
                        }
                        if(responseObj.clonedApplicantsId.clonedSecondaryApplicantId){
                            await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedSecondaryApplicantId);
                        }
                    }
                    const event = new ShowToastEvent({
                        title: 'Message',
                        message: 'Application Revoked Successfully',
                        variant: 'Success'
                    });
                    this.dispatchEvent(event);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'Opportunity',
                            actionName: 'view',
                        },
                    });
                    this.showSpinner = false;
                }
        } catch (error) {
            console.error('handleRevokeConfirm ', JSON.stringify(error));
            if(error?.body?.message){
                this.showToastMessage('Error!',error?.body?.message,'error');
            }else{
                this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
            }
            this.showSpinner = false;
        }
    }
   //SFTRAC-166
    handleRevokeTypeChange(event){
        this.revokeTypeValue = event.target.value;
  
    }
    handleRevokeConfirmForTractor(){
        if(this.revokeTypeValue){
        this.showRevokeModalForTractor = false;
        this.showConfirmRevokeModal = true;
        }else{
            this.showToastMessage('Info!','Please select revoke reason','info');
        }
    }//SFTRAC-166

    async cibilReportCalloutAPI(loanApplicationId,applicantId) {
        let cibilRequest = {
            applicantId: applicantId,
            loanApplicationId: loanApplicationId
        }

        await doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
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
                    //CISP-503 - START
                    if(result.Data.Application_Cibil_Details[0].OldestDate){
                        cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].OldestDate));
                    }
                    if(result.Data.Application_Cibil_Details[0].RecentDate){
                        cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].RecentDate));
                    }
                    //CISP-503 - END
                    cibilFields[SCORE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Score;
                    cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
                    cibilFields[TYPE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Type;
                    cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;
                    
                    if((result.Data.Cibil_LoanAccount_Details).length){
                        if((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')){
                            let makerDate =  result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                            //CISP-503
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
                    //CISP-503
                    this.upsertRecordDetailsHandler(loanApplicationId,CIBIL_DETAILS_OBJECT.objectApiName, cibilFields);

                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                    applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                    applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                    // CISP-503
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
                // CISP-503
                this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                console.log('error 249 ', error);
                this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
            });
    }

    //CISP-503 -- START
    async upsertRecordDetailsHandler(loanApplicationId,objectApiName, fields) {
        console.table('fields ', fields)
        await upsertRecordDetails({ loanApplicationId:loanApplicationId, fields: JSON.stringify(fields), objectApiName: objectApiName })
        .then(obj => {
            console.log('record upsertRecordDetails successfully', JSON.stringify(fields));
        })
        .catch(error => {
            console.log('error in record upsertRecordDetails ', error);
            this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
        });
    }
    //CISP-503- END
    //CISP-4628 Start
    handleUserSelection(event) {
        this.selectedUserName = event.detail.selectedValueName;
        this.selectedUserId = event.detail.selectedValueId;
        this.isUserSelected = true;
        console.log('In handleUserSelection');
    }

    clearUserSelection(event) {
        this.selectedUserName = event.detail.selectedValueName;
        this.selectedUserId = event.detail.selectedValueId;
        this.isUserSelected = false;
        console.log('In clearUserSelection');
    }
    //CISP-4628 End

    showToastMessage(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}