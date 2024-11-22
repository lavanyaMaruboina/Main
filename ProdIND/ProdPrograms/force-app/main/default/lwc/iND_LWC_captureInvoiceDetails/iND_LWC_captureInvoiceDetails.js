import { LightningElement,api,wire,track } from 'lwc';

import getVehicleDetailsRecord from '@salesforce/apex/IND_InvoiceDetails.getVehicleDetailsRecord';
import getInvoiceDetailsRecord from '@salesforce/apex/IND_InvoiceDetails.getInvoiceDetailsRecord';

import getGSTTypeMetadataRecord from '@salesforce/apex/IND_InvoiceDetails.getGSTTypeMetadataRecord';
import createDocumentForAdditionalDocument from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForAdditionalDocument';
import getLoanApplicationRecord from '@salesforce/apex/IND_InvoiceDetails.getLoanApplicationRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FirstName from '@salesforce/schema/Contact.FirstName';
import updateInvoiceDetail from '@salesforce/apex/IND_InvoiceDetails.updateInvoiceDetail';
import checkIfReadOnly from '@salesforce/apex/IND_InvoiceDetails.checkIfReadOnly';
import getBeneficaryDetail from '@salesforce/apex/IND_InvoiceDetails.getBeneficaryDetail';
import getMfrBeneficaryDetail from '@salesforce/apex/IND_InvoiceDetails.getMfrBeneficaryDetail';
import getMainDealerFromBenefiDetails from '@salesforce/apex/IND_InvoiceDetails.getMainDealerFromBenefiDetails';
import updateTransactionRecord from '@salesforce/apex/IND_InvoiceDetails.updateTransactionRecord';
import Invoice_OBJECT from '@salesforce/schema/Invoice_Details__c';
import invoice_Payemnt from '@salesforce/schema/Invoice_Details__c.Payment_to_be_made__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getApplicantData from '@salesforce/apex/IND_InvoiceDetails.getApplicantData';
import loanApplicationRevoke from '@salesforce/apex/IND_RevokeController.loanApplicationRevoke';
import isUserSelectionLookupRequiredOnRevoke from '@salesforce/apex/IND_RevokeController.isUserSelectionLookupRequiredOnRevoke'; //CISP-4628
import upsertRecordDetails from '@salesforce/apex/IND_RevokeController.upsertRecordDetails'; // CISP-2452 Modified
import updateClonedLoanApplicationOwner from '@salesforce/apex/IND_RevokeController.updateClonedLoanApplicationOwner'; // CISP-2452
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';//CISP-2778
import { updateRecord,createRecord } from 'lightning/uiRecordApi';
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

import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Bureau_Pull_Match__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Match__c';
import Bureau_Pull_Message__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Message__c';
 
import { NavigationMixin } from 'lightning/navigation';
import documentRecordId from "@salesforce/apex/RepaymentScreenController.documentRecordId"; //INDI-4645
import storingCIBILDetails from '@salesforce/apex/ExternalCAMDataController.storingCIBILDetails';
const fields = [invoice_Payemnt];
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import isTractorLoanApplication from '@salesforce/apex/IND_RevokeController.isTractorLoanApplication'; //SFTRAC-166
import getLoanTransactions from "@salesforce/apex/PostSanctionController.getLoanTransactions"; //SFTRAC-850
import getDocumentTractor from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getDocumentTractor';

export default class IND_LWC_captureInvoiceDetails extends NavigationMixin(LightningElement) {
    @api dealId = '';
    isModalOpenForRevoke //CISP-2344
    showSpinner = false;
    @api currentStep;
    isBEVisible;
    disableUploadInvoice = false;
    paymentToBeMadeValue;
    beneBenCodeRecord;
    benCodeMianDealerValue;
    benedata
    @track mainDealerOptions = [];
    benCode;
    modelCode;
    @api isSubmitButtonEnable = false;
    isAllDocType;
    modalAmountValue
    modalValue
    taxInvoiceDate = '';
    activeSections = ['Invoice','Invoice details'];
    isModalOpenForDate;
    isModalOpenForAmount;
    showUpload;
    showPhotoCopy;
    showDocView;
    isVehicleDoc;
    docType;
    uploadViewDocFlag;
    yesNoOptions;
    isInvoiceLegibleValue;
    disableIsInvoiceLegible = true;
    requireIsInvoiceLegible = false;
    requireInvoiceRemarks = false;
    disableinvoiceRemarks = true;
    invoiceRemarksValue;
    submitInvoiceButton;
    disableInvoiceButton;
    dealerType;
    dealerName;
    isImplement = false; //SFTRAC-138
    isTractorFieldCheck = false; //SFTRAC-138
    dealerTypeOptions;
    disableMainDealer = false;
    requireMainDealer = false;
    disableisInvoiceDateCorrectlyCaptured = false;
    @api recordId //= '00671000001Kmj3AAC';
    applicantId ;
    vehicleRecordId;
    invoiceDetailsId;
    documentRecordId;
    uploadInvoiceDocFlag;
    gstTypeValue;
    isCGST = true;
    isSGST= true;
    isUTGST= true;
    isIGST= true;
    isCESS= true;
    validVehicleType;
    invoiceAmount = '';
    gstTypeRecords;
    ContentDocumentId;
    paymentToBeMadeOptions;
    @track paymentToBeMadeOptionsTractor = [];
    isNewTractor = false; 
    beneMfrRecord; 
    basicPrice;
    gstTotal;
    discountOnExShowroomPrice;
    exShowrromPrice;
    rtoRoadTax;
    XstYearInsurancePremium;
    otherCharges;
    onRoadPrice;
    makeValue;
    modelValue;
    variantValue;
    isModalDateSaveClicked;
    isMOdalAmountSaveClicked;
    isInvoiceMMVCheck = false;
    taxInvoiceNumberValue;
    taxCollectedValue;
    ChassisNoValue;
    HSNNOValue;
    EngineNoValue;
    SerialNoValue;
    vehicleDelivered;
    vehicleInvoicePrice;
    isEngineNoRequired;
    isChassisNoRequired;
    invoiceDateValue;
    invoiceNumberValue;
    invoiceAmtInclueDisPicklistValue;
    isPreDisbursement;
    isInvoiceAmtUploadedValue;
    isDoAcceptInvoiceValue;
    isInvoiceAmtCorrectValue;
    isInvoiceDateCorrectlyCapturedValue;
    CGST;
    SGST;
    IGST;
    UTGST;
    CESS;
    typeOfInvoiceOptions;
    typeOfInvoiceValue;
    isInvoiceTypeTax;
    isView;
    isMainDealerEnabled;
    productType;
    agentBLCode;
    mainDealerValue;
    paymentValue;
    isChangeMainDealer = true;
    isInvoiceDateEnabled;
    isInvoiceAmountEnabled;
    isSubmitPrePost;
    disablePreDisFields = false;
    isCommunityUser;
    @track leadSource;  //Ola Integration changes
    isInvoiceAmountEnabledOla; //OLA-46 changes
    isPreDisbursementnew;//Ola Integration changes
    isInvoiceDateEnabledOla;//Ola Integration changes
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
    //CISP-4628
    get isOkDisabled() {
        return this.showUserSelectionLookupOnRevoke == false ? false : this.isUserSelected == true ? false : true;
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    invoiceData;
    invoiceAmountLabel;
    isTractor = false;//SFTRAC-138
    get revenue() {
        return getFieldValue(this.invoiceData.data, invoice_Payemnt);
    }
    @track leadStageName;//CISP-3124    
    //CISP-2735
    @track revokeDisable;
    @track isRevokeLoanApplication = false;
    isTractorApp = false;@track isPELead = false; @track showRevokeModalForTractor = false; @track revokeTypeValue ;//SFTRAC-166
    get revokeReasonVal(){
        let revokeValues = [];
        if(this.isPELead){revokeValues.push({ label: 'Pay-in and Payout changes', value: 'payandpayoutchanges' });return this.salutValues;    }
        else{
        revokeValues.push({ label: 'Remove Co-Borrower/Add Co-Borrower', value: 'removecoborroweraddcoborrower' },{ label: 'Asset modifications', value: 'assetmodifications' },{ label: 'Any Loan information changes', value: 'anyloaninformationchanges' });return revokeValues;}
    }
    handleRevokeTypeChange(event){
        this.revokeTypeValue = event.target.value;}//SFTRAC-166
    async renderedCallback(){
        try{
            if(this.isRevokeLoanApplication){
                console.log('isRevokeLoanApplication ren ', this.isRevokeLoanApplication);
                let allElements = this.template.querySelectorAll('*');
                allElements.forEach(element => element.disabled = true );
            }
                //Ola Integration changes
                await fetchLoanDetails({ opportunityId: this.recordId, dealId: this.dealId }).then(result => {
                    if(result?.loanApplicationDetails){this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;}
                 }).catch(error=>{
                    console.log(error);
                 });//Ola Integration changes
                   //Ola Integration changes
                await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
                .then(data => {
                    let fieldList = data.Input_Labels__c!=null ? data.Input_Labels__c.split(';') : [];
                    
                    console.log(fieldList);
                    if(fieldList.length>0 && this.leadSource != 'Hero'){//CISH-04
                    this.typeOfInvoiceValue = 'Tax Invoice';//OLA-45 changes
                    //OLA-47 start
                    /* if(this.IGST == 0 || this.IGST == ''){
                      this.gstTypeValue= 'INTER STATE';
                    } */
                    //OLA-47 end
                    this.isInvoiceTypeTax = true;
                    this.disableUploadInvoice = fieldList.includes('Upload Invoice')? true :this.disableUploadInvoice; //OLA-44 changes
                    this.isInvoiceDateEnabledOla = fieldList.includes('Tax Invoice Date')? true :this.isInvoiceDateEnabledOla; //OLA-46 changes
                    this.isPreDisbursementnew = fieldList.includes('Tax Invoice No')? true :this.isPreDisbursementnew; //OLA-46 changes
                    //this.isPreDisbursementnew = fieldList.includes('GST Type')? true :this.isPreDisbursementnew; //OLA-46 changes
                    this.isPreDisbursementnew = fieldList.includes('Type of invoice')? true:this.isPreDisbursementnew;//OLA-45 changes
                    this.isPreDisbursementnew = fieldList.includes('Engine No')? true:this.isPreDisbursementnew; //OLA-46 changes
                    this.isPreDisbursementnew = fieldList.includes('Chassis No')? true:this.isPreDisbursementnew; //OLA-46 changes
                    this.isInvoiceAmountEnabledOla = fieldList.includes('Invoice Amount as per ORP')? true:this.isInvoiceAmountEnabledOla; //OLA-46 changes
                   // this.template.querySelector("[data-id='CGST']").disabled = this.isPreDisbursement; //OLA-46 changes
                    //this.template.querySelector("[data-id='SGST']").disabled = this.isPreDisbursement; //OLA-46 changes
                    //this.template.querySelector("[data-id='IGST']").disabled = this.isPreDisbursement; //OLA-46 changes
                    //this.template.querySelector("[data-id='gstTypeId']").disabled = false;
                    this.revokeDisable = true;//OLA-50
                    //this.template.querySelector("[data-id='IGST']").disabled=false;
        
                    }
                   // this.isPreDisbursementnew = this.isPreDisbursement;
                }).catch(error => { 
                    this.isLoading = false;
                });
                //Ola Integration changes
              if(this.leadSource == 'OLA' && this.currentStep == 'post-sanction'){
               this.template.querySelector("[data-id='gstTypeId']").disabled = false;//OLA-125
            }
            this.isInvoiceAmountEnabledOla = this.isTractor == true ? true : this.isInvoiceAmountEnabledOla;
            if(this.isTractor == true && this.invoiceAmountLabel === 'Invoice Amount (incl. discount)'){
                if(this.invoiceAmount == '' || this.invoiceAmount == undefined){  
                    this.invoiceAmount = this.vehicleInvoicePrice;
                    this.isMOdalAmountSaveClicked = true;
                }
            }            
        }catch(error){
            console.log(error);
        }

    }
    //CISP-2735-END
    @track currentTodaysDate = new Date().toISOString().split('T')[0];//SFTRAC-421

    async connectedCallback(){
        console.log('currentStep in invoice : ',this.currentStep);
        
        this.isSubmitButtonEnable = true;
        console.log('Inside IND_LWC_captureInvoiceDetails connectedCallback');
        var optionList = new Array();
        optionList.push({ label: 'Yes', value: 'Yes' });
        optionList.push({ label: 'No', value: 'No' });
        this.yesNoOptions = optionList;

        var gstTypeList = new Array();
        gstTypeList.push({ label: 'INTER STATE', value: 'INTER STATE' });
        gstTypeList.push({ label: 'INTRA STATE', value: 'INTRA STATE' });
        gstTypeList.push({ label: 'UT', value: 'UT' });
        this.gstTypeOptions = gstTypeList;

        var dealerTypeList = new Array();
        dealerTypeList.push({ label: 'Dealer', value: 'Dealer' });
        dealerTypeList.push({ label: 'sub dealer', value: 'sub dealer' });
        dealerTypeList.push({ label: 'SSP', value: 'SSP' });
        this.delaerTypeOptions = dealerTypeList;
        
        var typeOfInvoiceList = new Array();
        typeOfInvoiceList.push({ label: 'Performa Invoice', value: 'Performa Invoice' });
        typeOfInvoiceList.push({ label: 'Tax Invoice', value: 'Tax Invoice' });
        this.typeOfInvoiceOptions = typeOfInvoiceList;
        console.log('typeOfInvoiceOptions ::' + this.typeOfInvoiceOptions);

        
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

        await getInvoiceDetailsRecord({ loanApplicationId: this.recordId, dealId: this.dealId })
            .then(result=>{
                if(result!=null){
                    console.log('OUTPUT getInvoiceDetailsRecord: ',result);
                    this.invoiceDetailsId = result.Id;
                    console.log('invoiceDetailsId ::' + this.invoiceDetailsId);
                    this.taxInvoiceDate = result.Tax_Invoice_Date__c;
                    this.isInvoiceLegibleValue = result.Is_Invoice_legible__c;
                    this.invoiceRemarksValue = result.Remarks__c;
                    this.taxInvoiceNumberValue = result.Tax_Invoice_No__c;
                    this.isInvoiceDateCorrectlyCapturedValue = result.Is_Invoice_date_correctly_captured__c;
                    this.taxCollectedValue = result.Tax_Collected_at_Source__c
                    this.EngineNoValue = result.Engine_No__c;
                    this.SerialNoValue = result.Serial_No__c;//SFTRAC-138
                    this.invoiceDateValue = result.Invoice_Date__c;//SFTRAC-138
                    this.invoiceNumberValue = result.Invoice_Number__c;//SFTRAC-138
                    this.ChassisNoValue = result.Chassis_No__c;
                    this.HSNNOValue = result.HSN_No__c;
                    this.gstTypeValue = result.GST_Type__c?.toUpperCase();
                    this.CGST = result.CGST__c;
                    this.SGST = result.SGST__c;
                    this.UTGST = result.UTGST__c;
                    this.IGST = result.IGST__c;
                    this.CESS = result.CESS__c;
                    this.invoiceAmtInclueDisPicklistValue= result.Invoice_Amount_incl_discount__c;
                    this.invoiceAmount = result.Invoice_Amount_incl_discounts__c;

                    this.isInvoiceAmtCorrectValue = result.Is_Invoice_amount_correctly_captured__c;
                    this.exShowroomPriceValue = result.Ex_showroom_prices__c;
                    this.onRoadPriceValue = result.On_road_price__c;
                    this.isInvoiceMMVCheck = result.Is_Invoice_MMV_matching_with_above_MMV__c;
                    this.isInvoiceAmtUploadedValue = result.Is_Invoice_amount_entered_above_as_per_I__c;
                    this.isDoAcceptInvoiceValue = result.Do_you_accept_uploaded_invoice__c;
                    this.uploadInvoiceRemarksValue = result.Invoice_Uploaded_Remark__c;
                    this.typeOfInvoiceValue = result.Type_of_Invoice__c;
                    this.documentRecordId = result.Documents__c;
                    this.benCodeMianDealerValue = result.Ben_Code_Of_Main_dealer__c;
                    this.mainDealerValue = result.Main_Dealer__c;
                    this.paymentToBeMadeValue = result.Payment_to_be_made__c;
                    this.paymentValue = result.Payment_to_be_made__c;
                    
                    if(this.typeOfInvoiceValue == 'Tax Invoice'){
                        this.isInvoiceTypeTax = true;
                    }else{
                        this.isInvoiceTypeTax = false;
                    }
                    if(this.taxInvoiceDate){
                        console.log('OUTPUT in -----: ',);
                        this.isModalDateSaveClicked = true;
                    }
                    if(this.invoiceAmount){
                        this.isMOdalAmountSaveClicked = true;
                    }
                   
                }
                console.log('this.mainDealerValue : ',this.mainDealerValue);
                console.log('this.paymentToBeMadeValue : ',this.paymentToBeMadeValue);

            }).then(()=>{
                console.log('this.mainDealerValue Test : ',this.mainDealerValue);
                console.log('this.paymentToBeMadeValue Test : ',this.paymentToBeMadeValue);
                getVehicleDetailsRecord({ loanApplicationId: this.recordId, dealId: this.dealId }).then(result=>{
                    if(result!=null){
                        console.log('OUTPUT getVehicleDetailsRecord: ',result);
                        this.isRevokeLoanApplication = result?.Loan_Application__r?.Is_Revoked__c;//CISP-2735
                        console.log('isRevokeLoanApplication ', this.isRevokeLoanApplication);
                        this.dealerName = result.Dealer_Sub_dealer_name__c;
                        this.makeValue = result.Make__c;
                        this.modelValue = result.Model__c;
                        this.variantValue = result.Variant__c;
                        this.benCode = result.Ben_Code__c;
                        this.modelCode = result.Model_Code__c;
                        console.log('modelcode---'+this.modelCode);
                        console.log('dealerName ::' + this.dealerName);
                        this.vehicleRecordId = result.Id;
                        this.vehicleInvoicePrice = result.Invoice_Price__c;
                        //SFTRAC-138 starts
                        this.vehicleDelivered = result.Vehicle_Delivered__c !== null ? result.Vehicle_Delivered__c : '';
                        if(!this.EngineNoValue){
                        this.EngineNoValue = result.Engine_number__c !== null ? result.Engine_number__c : '';
                        }
                        if(!this.ChassisNoValue){
                        this.ChassisNoValue = result.Chassis_number__c !== null ? result.Chassis_number__c : '';
                        }
                        if(!this.SerialNoValue){
                        this.SerialNoValue = result.Serial_number__c !== null ? result.Serial_number__c : '';
                        }

                        if(result.Vehicle_SubType__c == 'Implement'){
                            this.isImplement = true;
                        }else{
                            this.isImplement = false;
                        }//SFTRAC-138 end
                        
                        this.getBenCode();
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error in getVehicleDetailsRecord IND_LWC_captureInvoiceDetails connectedCallback Function ::'+ error);
                })
            })
            .catch(error => {
                this.error = error;
                console.log('Error in getInvoiceDetailsRecord IND_LWC_captureInvoiceDetails connectedCallback Function ::'+ error);
            })

            

            getGSTTypeMetadataRecord()
              .then(result => {
                this.gstTypeRecords = result;
                console.log('Result in getGSTTypeMetadataRecord', this.gstTypeRecords);
              })
              .catch(error => {
                console.error('Error:', error);
            });
            getApplicantData({ loanApplicationId: this.recordId })
              .then(result => {
                console.log('Result getApplicantData', result);
                if(result){
                    this.applicantId =  result.Id;
                }
              })
              .catch(error => {
                console.error('Error:', error);
            });
            getLoanApplicationRecord({ loanApplicationId: this.recordId  })
              .then(result => {
                result = JSON.parse(result);
                console.log('Result getLoanApplicationRecord', result);
                if(result){
                    this.isBEVisible = result.isOwnerSame;
                    this.isCommunityUser = result.isCommunityUser;
                    this.vehicleType = result.loanApplication.Vehicle_Type__c;
                    this.productType = result.loanApplication.Product_Type__c;
                    this.agentBLCode = result.loanApplication.Agent_BL_code__c;
                    this.leadStageName = result.loanApplication.StageName; //CISP-3124
                    console.log('this.invoiceAmount-- : ',this.invoiceAmount);
                    if(this.vehicleType == 'New' && this.productType == 'Tractor'){
                        this.isNewTractor = true;
                    }
                    if(result.loanApplication.Funding_on_Ex_Showroom__c){
                        this.invoiceAmountLabel = 'Invoice Amount - as per Exshowroom (incl. discount)';
                        if(this.invoiceAmount == '' || this.invoiceAmount == undefined){
                            this.invoiceAmount = result.loanApplication.Ex_showroom_price__c
                        }
                    }else if(result.loanApplication.Funding_on_ORP__c){
                        this.invoiceAmountLabel = 'Invoice Amount - as per ORP (incl. discount)'
                        if(this.invoiceAmount == '' || this.invoiceAmount == undefined){  
                            this.invoiceAmount = result.loanApplication.On_Road_price__c
                        }
                    }else{
                        this.invoiceAmountLabel = 'Invoice Amount (incl. discount)'
                    }
                        if(this.vehicleType == 'New'){
                            this.validVehicleType = true;
                        }else{
                            this.validVehicleType = false;
                            this.updateLATransaction();
                        }
                        if(result.loanApplication.StageName == 'Disbursement Request Preparation'  && this.currentStep == 'post-sanction'){
                            this.disableisInvoiceDateCorrectlyCaptured = true;
                            this.disablePreDisFields = true;
                            this.isPreDisbursement = true;
                            this.isPreDisbursementnew = true;//Ola Integration Changes
                            this.isInvoiceDateEnabled = true;
                            this.isInvoiceDateEnabledOla = true;//Ola Integration Changes
                            this.isInvoiceAmountEnabled = true;
                            this.isInvoiceAmountEnabledOla = true;//Ola Integration Changes
                            this.disableUploadInvoice = true;
                        }
                        else if(result.loanApplication.StageName == 'Disbursement Request Preparation'  && this.currentStep == 'pre-disbursement'){
                            console.log('Invoice when stage is disbursment and step is pre dis sanction  : ',);
                            this.isPreDisbursement = true;
                            this.isPreDisbursementnew = true;//Ola Integration Changes
                            this.isInvoiceDateEnabled = true;
                            this.isInvoiceDateEnabledOla = true;//Ola Integration Changes
                            this.isInvoiceAmountEnabled = true;
                            this.isInvoiceAmountEnabledOla = true;//Ola Integration Changes
                            this.disableisInvoiceDateCorrectlyCaptured = false;
                            this.disablePreDisFields = true;
                            this.isSubmitPrePost = true;
                        }
                        if(result.loanApplication.StageName == 'Pre Disbursement Check' && this.currentStep != 'post-sanction'){
                            console.log('result.StageName : ',result.loanApplication.StageName);
                                
                            
                            this.isPreDisbursement = true;
                            this.isPreDisbursementnew = true;//Ola Integration Changes
                            this.isInvoiceDateEnabled = true;
                            this.isInvoiceDateEnabledOla = true;//Ola Integration Changes
                            this.isInvoiceAmountEnabled = true;
                            this.isInvoiceAmountEnabledOla = true;//Ola Integration Changes
                            this.disableisInvoiceDateCorrectlyCaptured = false;
                            this.isSubmitPrePost = true;
                        }
                        else if(result.loanApplication.StageName == 'Pre Disbursement Check' && this.currentStep == 'post-sanction'){
                            console.log('result.StageName *****: ',result.loanApplication.StageName);
                                this.isPreDisbursement = true;
                                this.isPreDisbursementnew = true;//Ola Integration Changes
                                this.isInvoiceDateEnabled = true;
                                this.isInvoiceDateEnabledOla = true;//Ola Integration Changes
                                this.isInvoiceAmountEnabled = true;
                                this.isInvoiceAmountEnabledOla = true;//Ola Integration Changes
                                this.disableUploadInvoice = true;
                                this.disableisInvoiceDateCorrectlyCaptured = true;
                                this.disablePreDisFields = true;
                        }
                        if(this.leadStageName == 'Disbursement Request Preparation'){
                            this.revokeDisable = true;
                        }
                        //this.validVehicleType = true; // comment after testing 
                   //this.applicantId =  result.Applicant__c;
                   this.basicPrice = result.loanApplication.Basic_Price__c;
                   this.gstTotal = result.loanApplication.GST_Amount__c == null ? 0 : result.loanApplication.GST_Amount__c;
                   this.discountOnExShowroomPrice = result.loanApplication.Discount_on_Basic_Price__c;
                   this.exShowrromPrice = result.loanApplication.Ex_showroom_price__c;
                   if(this.productType == 'Two Wheeler'){ // RTO Tax value Based on product type
                         this.rtoRoadTax = result.loanApplication.RTO_Road_Tax_New__c;
                    }else{
                        if(result.loanApplication.RTO_Road_Tax_New__c == null || result.loanApplication.RTO_Road_Tax_New__c == 0 ){//CISP-6540
                            this.rtoRoadTax = result.loanApplication.RTO_Road_Tax__c;
                        }else{
                            this.rtoRoadTax = result.loanApplication.RTO_Road_Tax_New__c;
                        }//CISP-6540  
                    }
                   this.XstYearInsurancePremium = result.loanApplication.X1st_yr_Insurance_Premium__c;
                   this.otherCharges = result.loanApplication.Other_charges__c;
                   this.onRoadPrice = result.loanApplication.On_Road_price__c;
                 console.log('OUTPUT : ',);
                  if(result.loanApplication.StageName == 'Post Sanction Checks and Documentation'){
                      console.log('in stage name  : ',);
                   checkIfReadOnly({ loanApplicationId: this.recordId, dealId: this.dealId})
                        .then(result => {
                            console.log('Result checkIfReadOnly', result);
                            result = JSON.parse(result);
                            if(result.invoiceSub == true && result.RTOSub == true){
                                console.log('when both are true : ',);
                                this.isPreDisbursement = true;
                                this.isPreDisbursementnew = true;//Ola Integration Changes
                                this.isInvoiceDateEnabled = true;
                                this.isInvoiceDateEnabledOla = true;//Ola Integration Changes
                                this.isInvoiceAmountEnabled = true;
                                this.isInvoiceAmountEnabledOla = true;//Ola Integration Changes
                                this.disableUploadInvoice = true;
                                this.disableisInvoiceDateCorrectlyCaptured = true;
                                this.disablePreDisFields = true;
                            }else if(result.invoiceSub == true){
                                console.log('when only invoice submitted : ',);
                                this.isInvoiceAmountEnabled = true;
                                this.isInvoiceAmountEnabledOla = true;//Ola Integration Changes
                                this.isPreDisbursement = true;
                                this.disablePreDisFields = true;
                                this.revokeDisable = true;
                                this.disableisInvoiceDateCorrectlyCaptured = true;
                            }
                            else{
                                this.disableisInvoiceDateCorrectlyCaptured = true;
                                this.disablePreDisFields = true;
                                console.log('when both are not true : ',this.isDoAcceptInvoiceValue);
                                if(this.isDoAcceptInvoiceValue == 'No' || this.isInvoiceLegibleValue == "No" || this.isDoAcceptInvoiceValue == undefined || this.isInvoiceLegibleValue == undefined){
                                    this.isPreDisbursement = false;
                                    this.isPreDisbursementnew = false;//Ola Integration Changes
                                    this.disableUploadInvoice = false;
                                }else if(!this.isTractor){
                                    this.isPreDisbursement = true;
                                    this.isPreDisbursementnew = true;//Ola Integration Changes
                                    this.disableUploadInvoice = true;
                                }
                                if(this.isInvoiceDateCorrectlyCapturedValue == 'No' || this.isInvoiceDateCorrectlyCapturedValue == undefined){
                                    console.log('inside invoice date are No : ',);
                                    this.isInvoiceDateEnabled = false;
                                    this.isInvoiceDateEnabledOla = false;//Ola Integration Changes
                                }else if(!this.isTractor){
                                    this.isInvoiceDateEnabled = true;
                                    this.isInvoiceDateEnabledOla = true;//Ola Integration Changes
                                }
                                if(this.isInvoiceAmtCorrectValue == 'No' || this.isInvoiceAmtCorrectValue == undefined){
                                    console.log('inside invoice amount are No : ',);
                                    this.isInvoiceAmountEnabled = false;
                                    this.isInvoiceAmountEnabledOla = false;//Ola Integration Changes
                                }
        
                                else if(!this.isTractor){
                                    console.log('inside : ',);
                                    this.isInvoiceAmountEnabled = true;
                                    this.isInvoiceAmountEnabledOla = false;//Ola Integration Changes
                                }

                            }
                            if(this.productType == 'Tractor'){
                                this.checkLATransaction();
                            }
                            this.isPreDisbursementnew = this.isPreDisbursement;  //Ola Integration Changes
                            this.isInvoiceAmountEnabledOla = this.isInvoiceAmountEnabled; //Ola Integration Changes
                            this.isInvoiceDateEnabledOla = this.isInvoiceDateEnabled; //Ola Integration Changes
                        })
                        .catch(error => {
                            console.error('Error checkIfReadOnly:', error);
                        });
                    }
                    //SFTRAC-138 starts
                    console.log('isTractor1 ',this.productType);
                    if(this.productType == 'Tractor'){
                        console.log('isTractor');
                        this.isTractor = true; 
                    }
                    //SFTRAC-138 ends
                    this.isInvoiceAmountEnabledOla = this.isTractor == true ? true : this.isInvoiceAmountEnabledOla;

                }
                console.log('isPreDisbursement : ',this.isPreDisbursement);
              })
              .catch(error => {
                console.error('Error:', error);
            });
           console.log('OUTPUT @@@@@@@@@@: ',getFieldValue(this.invoiceData.data, invoice_Payemnt)); 
           console.log('OUTPUT : ',this.invoiceData.data);
           //SFTRAC-166
           isTractorLoanApplication({ loanApplicationId: this.recordId })
             .then(result => {
               console.log('Result', result);
               let data = JSON.parse(result);
                this.isTractorApp = data?.productType == 'Tractor' ? true : false;
                this.isPELead = (data?.profileName == 'IBL TF Payment Executive' || data?.profileName == 'IBL TF Internal Payment Executive') ? true : false;
             })
             .catch(error => {
               console.error('Error:', error);
           });
  
    }
    updateLATransaction(){
        updateTransactionRecord({ loanApplicationId: this.recordId, dealId: this.dealId })
          .then(result => {
            console.log('Result', result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    async getBeneficaryDetails(){
        let result = await getMainDealerFromBenefiDetails({ blCode:this.agentBLCode,productType:this.productType });
        if(result){
            console.log('Result getMainDealerFromBenefiDetails', result);
            this.benedata = JSON.parse(JSON.stringify(result));
            var optionList = new Array();
            await this.benedata.forEach(currentItem => {
                optionList.push({ label: currentItem.Name, value:currentItem.Id })
            });
            this.mainDealerOptions = optionList;
            await optionList.push({ label: this.dealerName, value: this.beneBenCodeRecord.Id });
            if(this.beneMfrRecord){
                 await optionList.push({ label: this.beneMfrRecord.Manufacturer__r.Name,value: this.beneMfrRecord.Id  });
            }
            if(this.isPreDisbursement == true  || this.isPreDisbursement == undefined){
                console.log('paymentValue Test : ',this.paymentValue);
                console.log('optionList Test ', optionList);
                let newArray = new Array();//CISP-3302
                await optionList.forEach(item => {
                    if((item.value == this.paymentValue) )
                        newArray.push(item);//CISP-3302
                   // this.paymentToBeMadeOptionsTractor.push(item);
                });
                this.paymentToBeMadeOptions = newArray;//CISP-3302
                this.paymentToBeMadeOptionsTractor=newArray
                console.log('paymentValuepaymentValue : ',newArray);
                if(newArray.length > 0){
                    this.paymentToBeMadeValue = newArray[0].value;
                }
                console.log('paymentValuepaymentValue : ',this.paymentToBeMadeValue);
            }
            console.log('this.mainDealerOptions : ',this.mainDealerOptions);
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error",
                message: EXCEPTIONMESSAGE,
                variant: 'error' 
            }));
        }
    }
    handleMainDealerChange(event){
        // this.isChangeMainDealer = true;
        this.isSubmitButtonEnable = false;
        this.mainDealerValue = event.target.value;
        console.log('this.mainDealerValue : ',this.mainDealerValue);
        let newArray = this.benedata.filter(item => {
            if(item.Id == this.mainDealerValue )
                return item;
        });
        console.log('newArray : ',newArray);
        var paymentToBeMadeList = new Array();
        var paymentToBeMadeOptionsTractorList=new Array();

        if(newArray.length > 0){
            paymentToBeMadeList.push({ label: newArray[0].Name, value: this.mainDealerValue });
            paymentToBeMadeOptionsTractorList.push({ label: newArray[0].Name, value: this.mainDealerValue });

        } 
            paymentToBeMadeList.push({ label: this.dealerName, value: this.beneBenCodeRecord.Id });
            paymentToBeMadeOptionsTractorList.push({ label: this.dealerName, value: this.beneBenCodeRecord.Id });
             if(this.beneMfrRecord){
                paymentToBeMadeOptionsTractorList.push({ label: this.beneMfrRecord.Manufacturer__r.Name, value: this.beneMfrRecord.Id });
             }
        this.paymentToBeMadeOptionsTractor= paymentToBeMadeOptionsTractorList;  
        this.paymentToBeMadeOptions = paymentToBeMadeList;
    }
    async getBenCode(){
        console.log('this.benCode : ',this.benCode);
        await getMfrBeneficaryDetail({ bencode: this.benCode, modelcode: this.modelCode })
            .then(result => {
                this.beneMfrRecord = result;
                console.log('this.beneMfrRecord-----'+this.beneMfrRecord);
            })

        getBeneficaryDetail({ bencode: this.benCode })
          .then(result => {
            console.log('Result this.benCode', result);
            this.beneBenCodeRecord = result;
            if(this.isPreDisbursement == true){
                if(this.paymentValue == this.beneBenCodeRecord.Id ){
                    this.paymentToBeMadeValue = this.beneBenCodeRecord.Id;
                }
            }
            this.dealerType = result.Dealership_Nature__c;
            console.log('this.dealerType : ',this.dealerType);
            if(this.dealerType == 'SSP' || this.dealerType == 'SDR'){
                this.isMainDealerEnabled = true;
                this.getBeneficaryDetails();
            }else if(this.dealerType == 'MDR'){
                // this.isChangeMainDealer = true;
                console.log('when dealer is mail dealer');
                this.isMainDealerEnabled = false;
                var paymentToBeMadeList = new Array();
                paymentToBeMadeList.push({ label: this.beneBenCodeRecord.Name, value: this.beneBenCodeRecord.Id });
                if(this.isNewTractor && this.beneMfrRecord){
                    paymentToBeMadeList.push({ label: this.beneMfrRecord.Manufacturer__r.Name, value: this.beneMfrRecord.Id });
                }
                console.log('paymentToBeMadeList : ',paymentToBeMadeList);
                this.paymentToBeMadeOptions = paymentToBeMadeList;
                this.paymentToBeMadeOptionsTractor = paymentToBeMadeList;
                this.paymentToBeMadeValue = this.paymentValue;
            }
            else{
                this.isMainDealerEnabled = false;
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    handlePaymentToBeChange(event){
        this.isSubmitButtonEnable = false;
        this.paymentToBeMadeValue = event.target.value;
        let val = event.target.value;
       console.log('handlePaymentToBeChange : ',val);
       if(this.beneBenCodeRecord.Id == val){
           console.log('in if &&&& : ',);
           this.benCodeMianDealerValue = this.beneBenCodeRecord.Ben_code__c
       }else{
        if(this.benedata != undefined && this.benedata != null && this.benedata != '') {
            console.log('test---');
        let newArray = this.benedata.filter(item => {
            if(item.Id == val )
                return item;
        });
        console.log('in else &&&: ',newArray);
        if(newArray.length > 0)
        this.benCodeMianDealerValue = newArray[0].Ben_code__c
       }
       if(this.isNewTractor && this.beneMfrRecord){
          if(this.beneMfrRecord.Id == val){
            this.benCodeMianDealerValue = this.beneMfrRecord.Manufacturer_Ben_Code__c;
          }
       }
       }
    }
    handleSave(event){
        this.isSubmitButtonEnable = false;
        this.isModalOpenForDate = false;
        this.isModalOpenForAmount = false;
        const fieldName = event.target.name;
        if(fieldName == 'invoiceDateSave' && (this.isInvoiceDateCorrectlyCapturedValue == undefined)){
            console.log('1 : ',);
            this.isModalOpenForDate = true;
            this.modalValue = 'You have entered '+this.taxInvoiceDate+ ' as Date of Invoice. Please check once and press Okay to continue and cancel to re-enter the invoice date.'
        }else if(fieldName == 'invoiceDateSave' && (this.isInvoiceDateCorrectlyCapturedValue == 'No')){
            console.log('2 : ',);
            this.isModalOpenForDate = true;
            this.modalValue = ' You are changing Tax invoice date. It will be mandatory to redo the loan agreement process if this date is changed. Please press okay if you want to continue with the change or cancel if no change is required in Tax Invoice date.'
        }
        if(fieldName == 'invoiceAmountSave' && (this.isInvoiceAmtCorrectValue == undefined)){
            console.log('3 : ',);
            this.isModalOpenForAmount = true;
            this.modalAmountValue = 'You have entered '+ this.invoiceAmount+' as Invoice amount. Please check once and press Okay to continue and cancel to re-enter the invoice amount.'
        }else if(fieldName == 'invoiceAmountSave' && (this.isInvoiceAmtCorrectValue == 'No')){
            console.log('4 : ',);
            this.isModalOpenForAmount = true;
            this.modalAmountValue = 'You are changing Invoice amount. It will be mandatory to redo the IHM screen if this amount is changed. Please press okay if you want to continue with the change or cancel if no change is required in Invoice amount.'
        }
    }
    handleViewDocument(){
        //this.documentRecordId = 'a0O71000000Te3hEAC';
        this.isView = false;
        this.uploadViewDocFlag = true;
        this.showUpload = false;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        this.isAllDocType = false;

    }
    closeModal() {
        this.isModalDateSaveClicked = false;
        if(this.isInvoiceDateCorrectlyCapturedValue == undefined || this.isInvoiceDateCorrectlyCapturedValue != 'No'){
            this.taxInvoiceDate = '';
        }
        this.modalValue = 'You have entered '+this.taxInvoiceDate+ ' as Date of Invoice. Please check once and press Okay to continue and cancel to re-enter the invoice date.'
        this.isModalOpenForDate = false;
        
    }
    closeAmountModal(){
        this.isMOdalAmountSaveClicked = false;
        if(this.isInvoiceAmtCorrectValue != 'No' || this.isInvoiceAmtCorrectValue == undefined  ){
            this.invoiceAmount = '';
        }
        this.modalAmountValue = 'You have entered '+ this.invoiceAmount+' as Invoice amount. Please check once and press Okay to continue and cancel to re-enter the invoice amount.'  
        this.isModalOpenForAmount = false;
        
    }
    handleInvoiceDateChange(event){
        this.isModalDateSaveClicked = false;
        this.isSubmitButtonEnable = false;
        this.taxInvoiceDate = event.detail.value;
        console.log('handleInvoiceDateChange : '+this.taxInvoiceDate+' currentTodaysDate '+this.currentTodaysDate);
        if (this.taxInvoiceDate > this.currentTodaysDate) {
            this.showToastMessage('Error!','Invalid date. Tax Invoice Date cannot be greater than today.','error');
            this.isInvoiceDateEnabled = true;
        }else{
            this.isInvoiceDateEnabled = false;
        }//SFTRAC-421
    }
    submitDetails(){ 
        console.log('taxInvoiceDate : ',this.taxInvoiceDate);
        if(this.taxInvoiceDate == ''){
            console.log('in else part : ',);
            this.isModalDateSaveClicked = false;
        }else{
            console.log('in if part : ',);
            this.isModalDateSaveClicked = true;
            
        }
        this.isModalOpenForDate = false;
    }
    submitAmountDetails(){
        this.isModalOpenForAmount = false;
        if(this.invoiceAmount == '' ){
            this.isMOdalAmountSaveClicked = false;
        }else{
            this.isMOdalAmountSaveClicked = true;
            
        }
    }
    handleInputFieldChange(event) {
       this.isSubmitButtonEnable = false;
        const fieldName = event.target.name;
        console.log('On Change Handler Executed for :: ' + fieldName);
        this.submitInvoiceButton = false;
        this.disableInvoiceButton = false;
        console.log('submitInvoiceButton ::' + this.submitInvoiceButton);
        if (fieldName == 'invoiceRemarksField') {
            this.invoiceRemarksValue = event.target.value;
            console.log('invoiceRemarksValue ::'+ this.invoiceRemarksValue);
        }else if(fieldName == 'gstTypeField'){
            this.gstTypeValue = event.target.value;
            this.template.querySelector('lightning-input[data-id=CGST]').value = '';
            this.template.querySelector('lightning-input[data-id=SGST]').value = '';
            this.template.querySelector('lightning-input[data-id=UTGST]').value = '';
            this.template.querySelector('lightning-input[data-id=IGST]').value = '';
            this.template.querySelector('lightning-input[data-id=CESS]').value = '';
        }else if(fieldName == 'invoiceAmount'){
            this.isMOdalAmountSaveClicked = false;
            this.invoiceAmount = event.target.value;
        }else if(fieldName == 'isInvoiceMMV'){
            this.isInvoiceMMVCheck = event.target.checked;
            console.log('OUTPUTisInvoiceMMV : ',event.target.checked);
        }else if(fieldName == 'taxInvoiceNumber'){
            this.taxInvoiceNumberValue = event.target.value;
        }else if(fieldName == 'taxCollected'){
            this.taxCollectedValue = event.target.value;
        }else if(fieldName == 'ChassisNo'){
            this.ChassisNoValue = event.target.value;
        }else if(fieldName == 'HSNNO'){
            this.HSNNOValue = event.target.value;
        }else if(fieldName == 'EngineNo'){
            this.EngineNoValue = event.target.value;
        }
        //SFTRAC-138
        else if(fieldName == 'SerialNo'){ 
            this.SerialNoValue = event.target.value;
        }else if(fieldName == 'invoiceDateField'){ 
            const selectedDate = new Date(event.target.value);
            let searchCmp = this.template.querySelector('lightning-input[data-id=invoiceDateField]');
            const currentDate = new Date();
            const formattedDate = currentDate.toLocaleDateString('en-US', {
				year: 'numeric',
				month: '2-digit',
				day: '2-digit',
			  });
			const formattedDateObject = new Date(formattedDate);
			const oneEightyDaysAgo = new Date(formattedDateObject);
			oneEightyDaysAgo.setDate(formattedDateObject.getDate() - 180);//Updated 30 days to 180 days by Rajasekar as part of SFTRAC-2478
			console.log('selectedDate '+selectedDate+' currentDate '+currentDate+' oneEightyDaysAgo '+oneEightyDaysAgo);
            if ((selectedDate >= oneEightyDaysAgo && selectedDate < currentDate)) {
                console.log('Selected date is valid.');
                this.invoiceDateValue = event.target.value;
                if(this.isTractor){ this.taxInvoiceDate = this.invoiceDateValue; }
                searchCmp.setCustomValidity("");
            } else {
                this.showToastMessage('Error!','Invalid date. Please select a date within the last 180 days.','error');//Updated 30 days to 180 days by Rajasekar as part of SFTRAC-2478
                searchCmp.setCustomValidity("Invalid date. Please select a date within the last 180 days.");//Updated 30 days to 180 days by Rajasekar as part of SFTRAC-2478
            }
            searchCmp.reportValidity();
        }else if(fieldName == 'invoiceNumberField'){ 
            this.invoiceNumberValue = event.target.value;
            if(this.isTractor){ this.taxInvoiceNumberValue = this.invoiceNumberValue; }
        }
        
        console.log('this.gstTypeValue : ',this.gstTypeValue);
        if(this.leadStageName == 'Post Sanction Checks and Documentation'){//CISP-3124
            this.gstTypeRecords.forEach(element => {
                console.log('element : ',element);
                if(element.GST_Type__c == this.gstTypeValue){
                    console.log('element.GST_Type__c : ',element.GST_Type__c);
                    console.log('this.gstTypeValue : ',this.gstTypeValue);
                    this.isIGST = element.IGST__c;
                    this.isCESS = element.CESS__c;
                    this.isCGST = element.CGST__c;
                    this.isSGST = element.SGST__c;
                    this.isUTGST = element.UTGST__c;
                }
            });
        }//CISP-3124
       
    }

   /* handleDealerTypechange(event){
        this.isSubmitButtonEnable = false;
        this.dealerType = event.target.value;
        if(this.dealerType == 'sub dealer' || this.dealerType == 'SSP'){
            this.disableMainDealer = false;
            this.requireMainDealer = true;
        }else{
            this.disableMainDealer = true;
            this.requireMainDealer = false;
        }
        if(this.dealerType == 'sub dealer'){
            var paymentToBeMadeList = new Array();
            paymentToBeMadeList.push({ label: 'Main Dealer', value: 'Main Dealer' });
            paymentToBeMadeList.push({ label: 'Sub Dealer', value: 'Sub Dealer' });
            this.paymentToBeMadeOptions = paymentToBeMadeList;
        }else if(this.dealerType == 'Dealer'){
            var paymentToBeMadeList = new Array();
            paymentToBeMadeList.push({ label: 'Main Dealer', value: 'Main Dealer' });
            paymentToBeMadeList.push({ label: 'OEM', value: 'OEM' });
            this.paymentToBeMadeOptions = paymentToBeMadeList;
        }else{
            var paymentToBeMadeList = new Array();
            this.paymentToBeMadeOptions = paymentToBeMadeList;
        }
        
    }*/

    handleisInvoiceLegible(event){
        this.isSubmitButtonEnable = false;
        this.isInvoiceLegibleValue = event.target.value;
        console.log('Is Invoice Legible ::', this.isInvoiceLegibleValue);
    }

    async handleUploadInvoice(event){   
        this.isSubmitButtonEnable = false;    
        this.docType = 'Invoice';
        //INDI-4645 Check doc already present or not
        await documentRecordId({loanApplicationId:this.recordId,docType : this.docType, dealId: this.dealId}).then(result=>{
            console.log('documentRecordId',result);
            this.documentRecordId = result;
            if(this.documentRecordId != ''){
                this.isLoading = false;
                this.showPhotoCopy = false;
                this.showDocView = true;          
                this.showUpload = true;
                this.isAllDocType = false;
                this.isVehicleDoc = true;
                this.uploadViewDocFlag = true;
            }
          }).catch(error=>{
            console.error('error',error);
          });
          //INDI-4645 
        if(!this.documentRecordId){
                await createDocumentForAdditionalDocument({docType:this.docType,vehicleDetailId: this.vehicleRecordId,applicantId:this.applicantId,loanApplicationId: this.recordId,
                })
                .then(result => {
                console.log('Result', result);
                this.uploadInvoiceDocFlag = true;
                this.documentRecordId = result;
                this.showUpload = true;
                this.showPhotoCopy = false;
                this.showDocView = true;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = false;
                })
                .catch(error => {
                console.error('Error:', error);
            });
        }
    }

    docUploadSuccessfully(event){
        console.log('OUTPUT docUploadSuccessfully: ',);
        this.ContentDocumentId = event.detail;
    }
    changeflagvalue(event) {
        this.uploadInvoiceDocFlag = false;
        if(event.detail != undefined) {
            console.log('uploadresponse..'+JSON.stringify(event.detail));
            var docIdObj = event.detail;
            //this.disableUpload = true;
            //this.disableSubmit = false;
            this.documentRecordId = docIdObj.DocumentId;
        }
    }
    changeflagvalueForViewDoc(){
        this.uploadViewDocFlag = false;
    }
    handleExShowroomPrice(event){
        this.isSubmitButtonEnable = false;
        this.exShowroomPriceValue = event.target.value;
    }
    handleOnRoadPrice(event){
        this.isSubmitButtonEnable = false;
        this.onRoadPriceValue = event.target.value;
    }
    handleInvoiceAmtInclueDis(event){
        this.isSubmitButtonEnable = false;
        this.invoiceAmtInclueDisPicklistValue = event.target.value;
    }
    handleisInvoiceAmtUploaded(event){
        this.isSubmitButtonEnable = false;
        this.isInvoiceAmtUploadedValue = event.target.value;
    }
    handleisDoAcceptInvoice(event){
        this.isSubmitButtonEnable = false;
        this.isDoAcceptInvoiceValue = event.target.value;
    }
    handleisInvoiceAmtCorrect(event){
        this.isSubmitButtonEnable = false;
        this.isInvoiceAmtCorrectValue = event.target.value;
    }
    handleIsInvoiceDateCorrectlyCaptured(event){
        this.isSubmitButtonEnable = false;
        this.isInvoiceDateCorrectlyCapturedValue = event.target.value;
    }
    handleTypeOfInvoice(event){
        this.isSubmitButtonEnable = false;
        this.typeOfInvoiceValue = event.target.value;
        if(this.typeOfInvoiceValue == 'Tax Invoice'){
            this.isInvoiceTypeTax = true;
        }else{
            this.isInvoiceTypeTax = false;
        }
        //SFTRAC-138
        if(this.typeOfInvoiceValue== 'Performa Invoice' && this.vehicleType=='New' && this.productType =='Tractor'){
            this.showToastMessage('Error!','Vehicle Type New and Invoice Type Performa not allowed','error');
        }
    }
    async callSubmitMethod(submitFlag){
        console.log('callSubmitMethod isModalDateSaveClicked : ',this.isModalDateSaveClicked);
        let isSuccess = false;
        console.log('callSubmitMethod : ',submitFlag);
        let documentPresent = true;
        if(this.isTractor){
            documentPresent = await getDocumentTractor({ loanApplicationId: this.recordId ,vehicleRecordId : this.vehicleRecordId });
        }
        if(!this.documentRecordId || !documentPresent){
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error",
                message: 'Please upload Invoice Document',
                variant: 'error' 
            }));
            return ;
        }//CISP-6497
        let isGSTTypeValid = false;
        let isexShowroomPriceValid = false;
        let isonRoadPricevalid = false;
        let payemntTobeMadeValueSelected = false;

        let CGST = this.template.querySelector('lightning-input[data-id=CGST]');
        let SGST = this.template.querySelector('lightning-input[data-id=SGST]');
        let UTGST = this.template.querySelector('lightning-input[data-id=UTGST]');
        let IGST = this.template.querySelector('lightning-input[data-id=IGST]');
        let CESS = this.template.querySelector('lightning-input[data-id=CESS]');
        CGST.reportValidity();
        SGST.reportValidity();
        UTGST.reportValidity();
        IGST.reportValidity();
        CESS.reportValidity();
        if (CGST.validity.valid === true && SGST.validity.valid === true && UTGST.validity.valid === true && IGST.validity.valid === true && CESS.validity.valid === true){
        let CGSTValue = (this.template.querySelector('lightning-input[data-id=CGST]').value) ? this.template.querySelector('lightning-input[data-id=CGST]').value : 0;
        let SGSTValue = (this.template.querySelector('lightning-input[data-id=SGST]').value) ? this.template.querySelector('lightning-input[data-id=SGST]').value : 0;
        let UTGSTValue = (this.template.querySelector('lightning-input[data-id=UTGST]').value) ? this.template.querySelector('lightning-input[data-id=UTGST]').value : 0;
        let IGSTValue = (this.template.querySelector('lightning-input[data-id=IGST]').value) ? this.template.querySelector('lightning-input[data-id=IGST]').value : 0;
        let CESSValue = (this.template.querySelector('lightning-input[data-id=CESS]').value) ? this.template.querySelector('lightning-input[data-id=CESS]').value : 0;
        
        console.log('OUTPUT : ',parseFloat(CGSTValue) );
        let total = parseFloat(CGSTValue) +  parseFloat(SGSTValue) + parseFloat(UTGSTValue) + parseFloat(IGSTValue) + parseFloat(CESSValue);
        
        console.log('total : ',total);
        if(this.gstTotal != null && this.gstTotal != undefined && this.gstTotal != '' && total != parseFloat(this.gstTotal)){
            isGSTTypeValid = false;
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error",
                message: 'GST amount not matching invoice, Kindly check',
                variant: 'error' 
            })
            );
        }else{
            isGSTTypeValid = true;
        }
    }
    if(!this.isTractor){
    let exShowroomPrice = this.template.querySelector('lightning-combobox[data-id=exShowroomPriceValue]');
    let onRoadPrice = this.template.querySelector('lightning-combobox[data-id=onRoadPriceValue]');
    exShowroomPrice.reportValidity();
    onRoadPrice.reportValidity();

    if(exShowroomPrice.validity.valid === true && onRoadPrice.validity.valid === true){
        if(exShowroomPrice.value == 'No'){
            isexShowroomPriceValid = false;
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error",
                message: 'Ex showroom price not matching the invoice Kindly check/ revoke.',
                variant: 'error' 
            })
            );
        }else{
            isexShowroomPriceValid = true;
        }

       if(onRoadPrice.value == 'No'){
        isonRoadPricevalid = false;
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error",
                message: 'ORP not matching the invoice Kindly check/ revoke.',
                variant: 'error' 
            })
            );
        }else{
            isonRoadPricevalid = true;
        }
    }
    console.log('this.invoiceAmount : ',this.invoiceAmount);
    console.log('this.onRoadPrice : ',this.onRoadPrice);
    }else{
        isexShowroomPriceValid = true;
        isonRoadPricevalid = true;
    }
    
    if(this.isInvoiceTypeTax == true && !this.isTractor){
        if(!this.isModalDateSaveClicked){
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error",
                message: 'Tax invoice date needs to be save mandatory.',
                variant: 'error' 
            })
            );
        }
    }else{
        this.isModalDateSaveClicked = true; 
    }console.log('++++++this.isTractor ',this.isTractor+' this.isInvoiceAmountEnabled ',this.isInvoiceAmountEnabled+' this.isInvoiceAmountEnabledOla ',this.isInvoiceAmountEnabledOla);
    if(this.isTractor){ //Tractor change if Invoice Amount is disable & Save is disable than no error Removed && this.isInvoiceAmountEnabled && this.isInvoiceAmountEnabledOla
            // do nothing
    }else if(!this.isMOdalAmountSaveClicked){
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Error",
            message: 'Invoice amount needs to be save mandatory.',
            variant: 'error' 
        })
        );
    }
   if(!this.isInvoiceMMVCheck){
    this.dispatchEvent(
        new ShowToastEvent({
        title: "Error",
        message: 'MMV not matching the invoice Kindly check/ revoke.',
        variant: 'error' 
    })
    );
   }
   console.log('paymentToBeMadeValue ---: ',this.paymentToBeMadeValue);
   if(!this.paymentToBeMadeValue){
    payemntTobeMadeValueSelected = false;
    this.dispatchEvent(
        new ShowToastEvent({
        title: "Error",
        message: 'Please Select Payment to be made to.',
        variant: 'error'
    })
    );
   }else{
    payemntTobeMadeValueSelected = true;
   }
    //OLA-176 start
  if(this.leadSource == 'OLA' && this.taxInvoiceNumberValue == null){
    this.dispatchEvent(
        new ShowToastEvent({
        title: "Error",
        message: 'OlaInvoiceUpdate api should be mandatory to hit',
        variant: 'error'
    })
    );
   return;
  
 }else if(this.leadSource == 'OLA' && this.documentRecordId == null){
    this.dispatchEvent(
        new ShowToastEvent({
        title: "Error",
        message: 'OlaInvoiceDocUpload api should be mandatory to hit',
        variant: 'error' 
    })
    );
    return;
 }
 //OLA-176 end
 this.checkTractorMandatoryFields(); //SFTRAC-138
   let dataObj = [];
   if(isGSTTypeValid == true && isexShowroomPriceValid == true && isonRoadPricevalid == true &&  this.isInvoiceMMVCheck == true && 
    (this.isMOdalAmountSaveClicked == true || this.isTractor) && this.isModalDateSaveClicked == true &&  payemntTobeMadeValueSelected == true && this.isTractorFieldCheck == false){
        this.saveDataToDatabase('Invoice','Post Sanction Checks and Documentation',submitFlag);
    }
    }
    handleSubmit(){
        this.callSubmitMethod(true);
    }
    @api handleSubmitFromParent(){
        this.callSubmitMethod(false);
    }
    handleSubmitOnPreDis(){
        let isInvoiceLegible = false;
        let isDoAcceptInvoice = false;
        console.log('OUTPUT handleSubmitOnPreDis: ',);
        if(this.isInvoiceLegibleValue == 'No'){
            let invoiceRemarksField = this.template.querySelector('lightning-input[data-id=invoiceRemarksField]');
            console.log('invoiceRemarksField : ',invoiceRemarksField.value);
            //invoiceRemarksField.reportValidity();
            if (invoiceRemarksField.value != ''){
                console.log('in if *** : ',);
                isInvoiceLegible = false;
            }else{
                isInvoiceLegible = true;
                console.log('in else *** : ',);
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Error",
                    message: 'Please fill remarks.',
                    variant: 'error' 
                })
                );
            }
        }if(this.isDoAcceptInvoiceValue == 'No'){
            let uploadInvoiceRemarks = this.template.querySelector('lightning-input[data-id=uploadInvoiceRemarks]');
            console.log('uploadInvoiceRemarks : ',uploadInvoiceRemarks.value);
            //uploadInvoiceRemarks.reportValidity();
            if (uploadInvoiceRemarks.value != ''){
                console.log('in if *** : ',);
                isDoAcceptInvoice = false;
            }else{
                isDoAcceptInvoice = true;
                console.log('in else *** : ',);
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Error",
                    message: 'Please fill remarks.',
                    variant: 'error' 
                })
                );
            }
        }
        this.checkTractorMandatoryFields(); //SFTRAC-138
        if(isInvoiceLegible == false && isDoAcceptInvoice == false && this.isTractorFieldCheck == false){
            this.saveDataToDatabase('Invoice','Pre Disbursement Check',true);
        }
    }
    //CISP-2344 
    closeRevokeModal(){
        if(this.isTractorApp){this.showRevokeModalForTractor = false}else
        this.isModalOpenForRevoke = false;
    }
    async revokeModalCall(){
        try {
            if(this.isTractorApp && this.revokeTypeValue == ''){
                this.showToastMessage('Info!','Please select revoke reason','info');
                return null;
            }
            this.showSpinner = true;
            let responseObj = {};//CISP-2778
            let revokeTyepVal;
            revokeTyepVal = this.isTractorApp == true ? this.revokeTypeValue : 'General Revoke';
            let response = await loanApplicationRevoke({ loanApplicationId : this.recordId, revokeType : revokeTyepVal, newOwnerId : '' });
                if (response) {
                    responseObj = JSON.parse(response);//CISP-2778
                    if(revokeTyepVal == 'General Revoke'){
                    if(responseObj.clonedApplicantsId.clonedPrimaryApplicantId){
                        await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedPrimaryApplicantId);
                    }else if(responseObj.clonedApplicantsId.clonedSecondaryApplicantId){
                        await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedSecondaryApplicantId);
                    }
                    if(responseObj.clonedLoanApplicationId){
                        await updateClonedLoanApplicationOwner({loanApplicationId : this.recordId,clonedLoanAppId:responseObj.clonedLoanApplicationId, newOwnerId : (this.showUserSelectionLookupOnRevoke?this.selectedUserId:'')}).then(()=>{}).catch(error=>{//CISP-4628
                            this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
                        });
                    }
                    }
                    const event = new ShowToastEvent({
                        title: 'Message',
                        message: 'Application Revoked Successfully',
                        variant: 'Success'
                    });
                    this.dispatchEvent(event);
                    // window.location.assign('/'+this.recordId);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'Opportunity',
                            actionName: 'view',
                        },
                    });
                }
                //CISP-2452//CISP-2778
                console.log('updateClonedLoanApplicationOwner ', result);
                this.showSpinner = false;//CISP-2778
                this.isModalOpenForRevoke = false;//CISP-2778
                this.showRevokeModalForTractor = false;
        } catch (error) {
            this.showSpinner = false;//CISP-2778
            console.error('handleRevokeConfirm ', JSON.stringify(error));
            this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
        }
    }
    handleRevoke() {
        //CISP-14306 Start
        if(this.isTractorApp){this.showRevokeModalForTractor = true;}else{
        if (this.ph1TWRevokeErr) {
            this.showToastMessage('Error!', this.ph1TWRevokeErr, 'error');
        } else {//CISP-14306 End
            this.isModalOpenForRevoke = true;

            //CISP-4628 Start
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
        
        }    //CISP-2344
    async cibilReportCalloutAPI(loanApplicationId,applicantId) {
        let cibilRequest = {
            applicantId: applicantId,
            loanApplicationId: loanApplicationId,
            dealId: this.dealId
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
                    //CISP-2778-START
                    if(result?.Data?.Application_Cibil_Details[0]?.OldestDate){
                        cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].OldestDate));
                    }
                    if(result?.Data?.Application_Cibil_Details[0]?.RecentDate){
                        cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].RecentDate));
                    }
                    //CISP-2778-END
                    cibilFields[SCORE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Score;
                    cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
                    cibilFields[TYPE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Type;
                    cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;
                    if((result.Data.Cibil_LoanAccount_Details).length){
                        if((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')){
                            let makerDate =  result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                            //CISP-2778-START
                            let makerDateConversion = makerDate.substring(0, makerDate.lastIndexOf(' '));
                            cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? makerDateConversion.split("-").reverse().join("-") : '';
                            //CISP-2778-END
                       }
                    }
                    
                    if (result.Data.Equifax_Report_URl) {
                        cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] = result.Data.Equifax_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                    }
                    if (result.Data.Cibil_Report_URl) {
                        cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] = result.Data.Cibil_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                    }

                    cibilFields[CIBIL_APPLICANT_FIELD.fieldApiName] = applicantId;
                    this.upsertRecordDetailsHandler(loanApplicationId,CIBIL_DETAILS_OBJECT.objectApiName, cibilFields);

                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                    applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                    applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                    // CISP-2452
                    this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                    storingCIBILDetails({  loanAppId: loanApplicationId, apiResponse: JSON.stringify(result.Data), applicantId: applicantId}).then({});
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
                console.log('error 249 ', error);
                this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
            });
    }

    //CISP-2452 -- START
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
    //CISP-2452- END

    showToastMessage(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    saveDataToDatabase(screen,module,submitFlag){
        let isSuccess = false;
        console.log('OUTPUT ****: ',this.template.querySelector('lightning-input[data-id=invoiceRemarksField]').value);
        console.log('OUTPUT : ',this.template.querySelector('lightning-input[data-id=uploadInvoiceRemarks]').value);
        let dataObj = [];
        let obj ={
            'Id' : this.invoiceDetailsId,
            'Tax_Invoice_No__c': this.taxInvoiceNumberValue,
            'Tax_Invoice_Date__c':this.taxInvoiceDate,
            'Tax_Collected_at_Source__c':this.taxCollectedValue,
            'Chassis_No__c':this.ChassisNoValue,
            'Engine_No__c':this.EngineNoValue,
            'HSN_No__c':this.HSNNOValue,
            'GST_Type__c':this.gstTypeValue,
            'CGST__c':(this.template.querySelector('lightning-input[data-id=CGST]').value) ? this.template.querySelector('lightning-input[data-id=CGST]').value : 0,
            'CESS__c':(this.template.querySelector('lightning-input[data-id=CESS]').value) ? this.template.querySelector('lightning-input[data-id=CESS]').value : 0,
            'IGST__c':(this.template.querySelector('lightning-input[data-id=IGST]').value) ? this.template.querySelector('lightning-input[data-id=IGST]').value : 0,
            'SGST__c':(this.template.querySelector('lightning-input[data-id=SGST]').value) ? this.template.querySelector('lightning-input[data-id=SGST]').value : 0,
            'UTGST__c':(this.template.querySelector('lightning-input[data-id=UTGST]').value) ? this.template.querySelector('lightning-input[data-id=UTGST]').value : 0,
            'Is_Invoice_MMV_matching_with_above_MMV__c': this.isInvoiceMMVCheck,
            'Ex_showroom_prices__c':this.exShowroomPriceValue,
            'On_road_price__c':this.onRoadPriceValue,
            'Invoice_Amount_incl_discount__c': this.invoiceAmtInclueDisPicklistValue,
            'Invoice_Amount_incl_discounts__c': this.invoiceAmount,
            'GST_Total__c':this.gstTotal,
            'Is_Invoice_legible__c':this.isInvoiceLegibleValue,
            'Remarks__c':this.template.querySelector('lightning-input[data-id=invoiceRemarksField]').value,
            'Is_Invoice_date_correctly_captured__c':this.isInvoiceDateCorrectlyCapturedValue,
            'Is_Invoice_amount_correctly_captured__c':this.isInvoiceAmtCorrectValue,
            'Is_Invoice_amount_entered_above_as_per_I__c':this.isInvoiceAmtUploadedValue,
            'Do_you_accept_uploaded_invoice__c':this.isDoAcceptInvoiceValue,
            'Invoice_Uploaded_Remark__c':this.template.querySelector('lightning-input[data-id=uploadInvoiceRemarks]').value,
            'Type_of_Invoice__c':this.typeOfInvoiceValue,
            'Documents__c':this.documentRecordId,
            'Ben_Code_Of_Main_dealer__c':this.benCodeMianDealerValue,
            'Main_Dealer__c':this.mainDealerValue,
            'Payment_to_be_made__c':this.paymentToBeMadeValue,
            'Dealer_Name__c': this.dealerName
        }
        if(this.isTractor){
            obj['Serial_No__c'] = this.SerialNoValue; //SFTRAC-138
            obj['Vehicle_Detail__c'] = this.vehicleRecordId; //SFTRAC-138
            obj['Invoice_Date__c'] = this.invoiceDateValue; //SFTRAC-138
            obj['Invoice_Number__c'] = this.invoiceNumberValue; //SFTRAC-138
        }
        dataObj.push(obj);
        console.log('submitFlg ****: ',submitFlag);
        updateInvoiceDetail({ loanApplicationId: this.recordId,data : JSON.stringify(dataObj),screenName:screen,moduleName:module ,submitFlg:submitFlag, dealId: this.dealId})
      .then(result => {
        console.log('Result', result);
        this.isInvoiceAmountEnabled = true;
        this.isInvoiceAmountEnabledOla = true;
        this.isSubmitButtonEnable = true;
        this.disableEverything();
        /*if(module == 'Pre Disbursement Check'){
            this.isPreDisbursement = true;
            this.disableisInvoiceDateCorrectlyCaptured = true;
        }*/
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Success",
            message: 'Invoice update successfully.',
            variant: 'success' 
        })
        );
        /*if(module != 'Pre Disbursement Check'){
            this.dispatchEvent(new CustomEvent('submitpage', { detail: true}));        
        }*/
      })
     
      .catch(error => {
        this.isSubmitButtonEnable = false;
        console.error('Error:', error);
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Error",
            message: error,
            variant: 'error' 
        })
        );
        });
        this.isInvoiceAmountEnabledOla = this.isInvoiceAmountEnabled;
        isSuccess = true;
        if(submitFlag == false){
        const actionResultEvent = new CustomEvent("submitresultaction", {
            detail: {isSuccess: isSuccess}
          });
      
          // Dispatches the event.
          this.dispatchEvent(actionResultEvent);
        }
    }
    
    checkTractorMandatoryFields(){
        //SFTRAC-138 Starts
        if(this.isTractor){
            let invoiceNumberField = this.template.querySelector('lightning-input[data-id=invoiceNumberField]');
            let invoiceNumberFieldvalue = invoiceNumberField.value;
            if (!invoiceNumberFieldvalue) {
                invoiceNumberField.setCustomValidity("Invoice Number value is required");
                this.isTractorFieldCheck = true;
            } else {
                invoiceNumberField.setCustomValidity("");
            }
            invoiceNumberField.reportValidity();

            let invoiceDateField = this.template.querySelector('lightning-input[data-id=invoiceDateField]');
            let invoiceDateFieldvalue = invoiceDateField.value;
            if (!invoiceDateFieldvalue) {
                invoiceDateField.setCustomValidity("Invoice Date value is required");
                this.isTractorFieldCheck = true;
            } else {
                //invoiceDateField.setCustomValidity("");
                const currentDate = new Date();
                const formattedDate = currentDate.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                  });
                const formattedDateObject = new Date(formattedDate);
                const oneEightyDaysAgo = new Date(formattedDateObject);
                oneEightyDaysAgo.setDate(formattedDateObject.getDate() - 180);//Updated 30 days to 180 days by Rajasekar as part of SFTRAC-2478
                if ((new Date(invoiceDateFieldvalue) >= oneEightyDaysAgo && new Date(invoiceDateFieldvalue) < currentDate)) {
                    console.log('Selected date is valid.');
                    invoiceDateField.setCustomValidity("");
                } else {
                    this.showToastMessage('Error!','Invalid date. Please select a date within the last 180 days.','error');//Updated 30 days to 180 days by Rajasekar as part of SFTRAC-2478
                    invoiceDateField.setCustomValidity("Invalid date. Please select a date within the last 180 days.");//Updated 30 days to 180 days by Rajasekar as part of SFTRAC-2478
                    this.isTractorFieldCheck = true;
                }
            }
            invoiceDateField.reportValidity();

            if(this.vehicleDelivered == 'Yes' && !this.isImplement){
                this.isChassisNoRequired = true;
                this.isEngineNoRequired = true;
                let EngineNo = this.template.querySelector('lightning-input[data-id=EngineNo]');
                let EngineNovalue = EngineNo.value;
                if (!EngineNovalue && !EngineNo.disabled) {
                    EngineNo.setCustomValidity("Engine No value is required");
                    this.isTractorFieldCheck = true;
                } else {
                    EngineNo.setCustomValidity("");
                }
                EngineNo.reportValidity();

                let ChassisNo = this.template.querySelector('lightning-input[data-id=ChassisNo]');
                let ChassisNoValue = ChassisNo.value;
                if (!ChassisNoValue && !ChassisNo.disabled) {
                    ChassisNo.setCustomValidity("Chassis No value is required");
                    this.isTractorFieldCheck = true;
                } else {
                    ChassisNo.setCustomValidity("");
                }
                ChassisNo.reportValidity();
            }
            

            if(this.isImplement){
                let SerialNo = this.template.querySelector('lightning-input[data-id=SerialNo]');
                let SerialNoValue = SerialNo.value;
                if (!SerialNoValue && !SerialNo.disabled) {
                    SerialNo.setCustomValidity("Serial No value is required");
                    this.isTractorFieldCheck = true;
                } else {
                    SerialNo.setCustomValidity("");
                }
                SerialNo.reportValidity();
            }
        }
        //SFTRAC-138 Ends
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => {
            // if(element.label !== 'Revoke'){
                element.disabled = true
            // }
       });
    }

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

    //SFTRAC-805
    checkLATransaction(){
        getLoanTransactions({ loanApplicationId: this.recordId, module: 'Post Sanction Checks and Documentation', dealId: this.dealId }).then((result) => {
            for (let key in result) {
                if (key) {
                    if (key === 'Invoice') {
                        if (result[key]) {
                            this.isPreDisbursement = true;
                            this.isPreDisbursementnew = true;
                            this.disableUploadInvoice = true;
                            this.isInvoiceDateEnabled = true;
                            this.isInvoiceDateEnabledOla = true;
                            this.isInvoiceAmountEnabledOla = true;
                            this.isSubmitButtonEnable = true;
                        }
                    } 
                }
            }
        }).catch((error) => {
            console.log('++++++getLoanTransactions error ' + error);})
        }
    
}