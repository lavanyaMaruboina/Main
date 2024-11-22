import { LightningElement, api, wire, track } from 'lwc';
import VEHICLE_CATEGORY_OBJECT_NAME from '@salesforce/schema/Opportunity.Vehicle_Sub_Category__c';
import getInsuranceDetails from '@salesforce/apex/AdditionalDocumentsClass.getInsuranceDetails'
import getLoanApplicationCategory from '@salesforce/apex/AdditionalDocumentsClass.getLoanApplicationCategory';
import fetchRelatedDocument from '@salesforce/apex/AdditionalDocumentsClass.fetchRelatedDocument';
import fetchAdditionalDocuments from '@salesforce/apex/AdditionalDocumentsClass.fetchAdditionalDocuments';
import fetchPicklistValue from '@salesforce/apex/AdditionalDocumentsClass.fetchPicklistValue';
import fetchContentDocument from '@salesforce/apex/AdditionalDocumentsClass.fetchContentDocument';
import postSavedDataOnSubmit from '@salesforce/apex/AdditionalDocumentsClass.postSavedDataOnSubmit';
import getApplicantData from '@salesforce/apex/AdditionalDocumentsClass.getApplicantData';
import createDocumentForAdditionalDocument from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForAdditionalDocument';
import updateAdditionalDocument from '@salesforce/apex/AdditionalDocumentsClass.updateAdditionalDocument';
import getAdditionalData from '@salesforce/apex/AdditionalDocumentsClass.getAdditionalData';
import getBankName from '@salesforce/apex/AdditionalDocumentsClass.getBankName';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import getContentVersion from '@salesforce/apex/SecurityMandate.getContentVersion'
const fields = [VEHICLE_CATEGORY_OBJECT_NAME];
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkIfReadOnly from '@salesforce/apex/AdditionalDocumentsClass.checkIfReadOnly';
import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';
import deleteDocRecord from '@salesforce/apex/AdditionalDocumentsClass.deleteDocRecord';
export default class IND_LWC_AddtionalDocuments extends NavigationMixin(LightningElement) {
    headerTitle = 'Note : “Please check if any of the below documents are applicable for the application. Please upload the same if applicable.”';
    @api dealId = '';
    communityPartnersURL = IBL_Community_Partners_URL;
    isCheckBoxSectionOpen = false;
    fileType;
    isCommunityUser;
    @api currentStep
    isBEVisible;
    aaplicantIdBorrower;
    aaplicantIdCoBorrower;
    applicantRecords;
    @api isSubmitDisabled = false;
    isAddPayment = false;
    @track paymentList = [];
    keyIndex = 0;
    docType;
    uploadAdditionalDocFlag;
    isAllDocType;
    showUpload;
    showPhotoCopy;
    showDocView;
    isVehicleDoc;
    uploadViewDocFlag;
    disableHypothecation;
    isHypothecationValue;
    yesNoOptions;
    isRCVisible;
    isSellerPassbook;
    issellerBankState;
    issellerChqCancel;
    isSeller;
    isBankTransfer;
    isForeClosure;
    isDDforClosing;
    isBorrowerDeclare = false;
    isCoBorrowerDeclare;
    isBranchUndertake;
    isNOC;
    isPaymentReceipts;
    isTaxInvoice;
    isSaleAgreement;
    isBuyerSeller;
    isIndemnityLetter;
    isBorrower;
    isborrowercancelCheq;
    isborrowPassbook;
    isborrowerBankState;
    isCoBorrower;
    isCoborrowercancelCheq;
    isCoborrowPassbook;
    isCoborrowerBankState;
    @api recordId;
    fieldLabel;
    documentRecordId;
    applicantid;
    vehiclerecordid;
    ContentDocumentId;
    hypothecationName;
    documentIdWithType;
    documentIdWithTypeList = [];
    coBorrowerHealthData =[];
    borrowerHealthData =[];
    branchUndertakingData =[];
    saleAgreementData =[];
    indexRow = 0;
    isPreview = false;
    converId;
    height = 32;
    @track taxInvoice = [];
    @track indemnityLetterData =[];
    @track buyerSellerData=[];
    @track rcDoumentData = [];
    @track foreclosureLetter=[];
    @track bankTransfer = [];
    @track sellerData = [];
    @track sellerData1 = [];
    @track sellerData2 = [];
    @track borrowerData = [];
    @track borrowerData1 = [];
    @track borrowerData2 = [];
    @track borrowerCancelCheque =[];
    @track coBorrowerData = [];
    @track coBorrowerData1 = [];
    @track coBorrowerData2 = [];
    @track nocData = [];
    nocNumberOfLA;
    isPaymentDataAlready = 0;
    applicantType;
    isReadOnly;
    isadditionDocSectionOpen = false;
    @track coBorrowerReadOnly = false;
    isSeller1;
    isSeller2;
    isSeller3;
    isBorrower1;
    isBorrower2;
    isBorrower3;
    isCoBorrower1;
    isCoBorrower2;
    isCoBorrower3;
    paymentDocUploadedValue;
    paymentLegibleValue;
    paymentRemarksValue;
    get optionsYesOrNo() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' },
        ];
    }

    // D2C_CHANGE - Raman, Added disabled conditions for d2c
    get isD2CDisabled(){
        return this.isReadOnly || this.isD2C;
    }

    get isNOCDisabled(){
        return this.isNOCMandatory || this.isD2C;
    }

    get isBorrowerDisabled(){
        return this.isBorrowerMandetory || this.isD2C;
    }

    get disableCaptureChassisNumberWithD2C(){
        return this.disableCaptureChassisNumber || this.isD2C;
    }

    // EO D2C_CHANGE

    @track stageCheck = false
    @track isLoadingSpinner = false;
    @track isNotPreDisbursement  =false
    @track bankNameList = [];
    // D2C_CHANGE - Raman
    @track isD2C = false;
    @track disableCaptureChassisNumber = false; // variable missing in original vlos
    // EO D2C_CHANGE
    disabledFields = false;
    isBorrowerMandetory = false;
    isCoBorrowerMandetory = false;
    isNOCMandatory = false; 
    noDocSelected=false;uncheckedRec = [];//CISP-3726
    checkPostSanctionSubmit(){
        checkIfReadOnly({ lAId: this.recordId, dealId: this.dealId }).then(result => {
            this.isReadOnly = result;
            if(this.isReadOnly == true){
                this.coBorrowerReadOnly = true;
                this.isBorrowerMandetory = true;
                this.isCoBorrowerMandetory = true;
                this.isNOCMandatory = true;
                this.isNotPreDisbursement = true;
                this.stageCheck = false;
               
            }else{
                this.stageCheck = true;
            }
            this.fetchRelatedDocument();
            this.isCheckBoxSectionOpen = true;
            this.isadditionDocSectionOpen = true;
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
    @api isRevokedLoanApplication;//CISP-2735
    async connectedCallback() {
        this.isSubmitDisabled = true;
        
        this.paymentList = [];
        // this.vehicleCategory();
        var optionList = new Array();
        optionList.push({ label: 'Yes', value: 'Yes' });
        optionList.push({ label: 'No', value: 'No' });
        this.yesNoOptions = optionList;

        optionList = new Array();
        optionList.push({ label: 'IBL', value: 'IBL' });
        optionList.push({ label: 'Others', value: 'Others' });
        this.hypothecationName = optionList;

        await getInsuranceDetails({ loanApplicationId: this.recordId }).then(result => {
            if (result.length>0) {
                let insuranceName = result[0].Name;
                this.applicantType = result[0].Applicant__r.Applicant_Type__c;
                if (insuranceName == 'COMBO' && this.applicantType == 'Borrower' && result[0].Product_Type__c != 'Two Wheeler') {
                    this.isBorrowerDeclare = true;
                    this.isBorrowerMandetory = true;
                } else if (insuranceName == 'COMBO' && this.applicantType == 'Co-borrower' && result[0].Product_Type__c != 'Two Wheeler') {
                    this.isCoBorrowerDeclare = true;
                    this.isCoBorrowerMandetory = true;
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });

        await getLoanApplicationCategory({ loanApplicationId: this.recordId, dealId: this.dealId }).then(result => {
            result = JSON.parse(result);
            if (result) {
                this.isBEVisible = result.isOwnerSame;
                this.isCommunityUser = result.isCommunityUser;
                this.vehicleCategoryCode = result.loanApplication.Vehicle_Sub_Category__c;
                // D2C_CHANGE - Raman
                this.isD2C = result.loanApplication.LeadSource === 'D2C';
                // EO D2C_CHANGE
                this.loanstage = result.loanApplication.StageName;
                this.vehiclerecordid = result.loanApplication.Vehicle_Details__r.records[0].Id;
                this.nocNumberOfLA = result.loanApplication.NOC_Number__c;
                if (this.vehicleCategoryCode == 'RLN') {
                    this.isNOC = true;
                    this.isNOCMandatory = true;
                }
                if(this.loanstage == 'Disbursement Request Preparation'  && this.currentStep == 'post-sanction'){
                    this.checkPostSanctionSubmit();
                    this.disabledFields = true;
                    this.fetchRelatedDocument();
                }else if(this.loanstage == 'Disbursement Request Preparation'  && this.currentStep == 'pre-disbursement'){
                    this.isLoadingSpinner = true
                    this.stageCheck = false;
                    this.disabledFields = true;
                    this.isNotPreDisbursement = true;
                    this.isadditionDocSectionOpen = true;
                    this.fetchRelatedDocument();
                }
                if (this.loanstage == 'Pre Disbursement Check'  && this.currentStep != 'post-sanction') {
                    this.isLoadingSpinner = true
                    this.stageCheck = false;
                    this.isNotPreDisbursement = true
                    this.isAddPayment = true;
                    this.isadditionDocSectionOpen = true;
                    this.fetchRelatedDocument();
                } else if(this.loanstage == 'Pre Disbursement Check'  && this.currentStep == 'post-sanction'){
                    console.log('additional document when stage is pre dis and step is  post sanction  : ',);
                    this.stageCheck = false;
                    this.isReadOnly = true;
                    this.coBorrowerReadOnly = true;
                    this.isBorrowerMandetory = true;
                    this.isCoBorrowerMandetory = true;
                    this.isNOCMandatory = true;
                    this.isNotPreDisbursement = true;
                    this.isadditionDocSectionOpen = true;
                    this.isCheckBoxSectionOpen = true;
                    this.disabledFields = true;
                    this.isLoadingSpinner = true
                    this.fetchRelatedDocument();
                }
                if(this.loanstage == 'Post Sanction Checks and Documentation'){
                    this.checkPostSanctionSubmit();
                    this.disabledFields = true;
                    this.isSubmitDisabled = false;
                   
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
        await getApplicantData({ loanApplicationId: this.recordId })
          .then(result => {
            this.applicantRecords = JSON.parse(JSON.stringify(result));
            this.applicantRecords.forEach(element => {
                if(element.Applicant_Type__c == 'Borrower'){
                    this.aaplicantIdBorrower = element.Id;
                }else{
                    this.aaplicantIdCoBorrower = element.Id;
                }
            });
            
          })
          .catch(error => {
            console.error('Error:', error);
        });
        //CISP-3216-START
        if(this.aaplicantIdCoBorrower == '' || this.aaplicantIdCoBorrower == null || this.aaplicantIdCoBorrower == undefined){
            this.coBorrowerReadOnly = true;
            this.isCoBorrowerMandetory = true;
        }
        //CISP-3216-END
        

        await getBankName().then(result => {
            let bankNameList = result;
            var optionList = [];
            bankNameList.forEach(element => {
                optionList.push({ label: element.Name, value: element.Id });
            });
            this.bankNameList = optionList;
        })
        .catch(error => {
            console.error('Error:', error);
        });
        await getAdditionalData({ loanApplicationId: this.recordId, dealId: this.dealId }).then(result => {
            console.log('Result', result);
            let data = JSON.parse(result);
            console.log('data : ', data);
            let isAdditionalPreSubmit = data.additionalPreHistory;
            console.log('isAdditionalPreSubmit : ',isAdditionalPreSubmit);
            if (data.docDetails.length > 0) {
                data.docDetails.forEach(element => {
                    if (element.Document_Type__c == 'Tax Invoice') {
                        console.log('in if condition *** : ', );
                        this.taxInvoice = element;
                        console.log('this.taxInvoice : ',this.taxInvoice);
                        if((this.taxInvoice.enter_details_asper_Tax_Invoice_upload__c == 'No' || this.taxInvoice.Is_Tax_Invoice_legible__c =='No')){
                            console.log('tax invoice No : ',);
                            this.isTaxInvoice = true;
                        }

                    } else if (element.Document_Type__c == 'RC Document') {
                        console.log('in if condition *** : ', );
                        this.rcDoumentData = element;
                        if((this.rcDoumentData.Are_enter_details_as_per_RC_doc_upload__c == 'No' || this.rcDoumentData.Are_entered_details_as_per_document_uplo__c == 'No')){
                            this.isRCVisible = true;
                        }

                    }else if (element.Document_Type__c == 'DD for closing existing loan') {
                        console.log('in if condition *** : ', );
                        this.bankTransfer = element;
                        if(this.bankTransfer.Is_sale_DD_legible__c == 'No'){
                            this.isBankTransfer = true;
                        }
                       
                    }else if (element.Document_Type__c == 'Foreclosure letter for closed existing loan') {
                        console.log('in if condition *** : ', );
                        this.foreclosureLetter = element;
                        if( this.foreclosureLetter.Is_sale_Foreclosure_Letter_legible__c == 'No'){
                            this.isForeClosure = true;
                        }
                     
                    } else if (element.Document_Type__c == 'Seller\'s Passbook' ){
                       
                        this.sellerData = element;
                        console.log('seller pass *** : ', this.sellerData);
                        console.log('OUTPUT : ',this.optionsIsSellerPassbookLegible);
                        console.log('OUTPUT : ',this.bankNameList);
                        if( (this.sellerData.entered_details_asper_passbook_upload__c == 'No' || this.sellerData.Is_passbook_legible_for_Seller__c == 'No')){
                            this.isSeller = true;
                            this.isSellerPassbook = true;
                        }

                    } else if(element.Document_Type__c == 'Seller\'s Bank Statement'){
                        this.sellerData1 = element;
                        if((JSON.parse(JSON.stringify(this.sellerData))).length == 0){
                            console.log('this.sellerData in bank : ',this.sellerData);
                            this.sellerData = element;
                        }
                        console.log('seller bank *** : ', this.sellerData1);
                        if( (this.sellerData1.enter_details_asper_bank_STMT_upload__c == 'No' || this.sellerData1.Is_bank_statement_legible_for_Seller__c == 'No')){
                            this.issellerBankState = true; this.isSeller = true;
                        }
                    }
                    else if(element.Document_Type__c == 'Seller\'s Cancel Cheque'){
                        this.sellerData2 = element;
                        if((JSON.parse(JSON.stringify(this.sellerData))).length == 0){
                            console.log('this.sellerData cancel cheque : ',this.sellerData);
                            this.sellerData = element;
                        }
                        console.log('seller cancel *** : ', this.sellerData2);
                        if( (this.sellerData2.enter_details_as_per_canc_chq_upload__c == 'No' || this.sellerData2.Is_cancelled_cheque_legible_for_Seller__c == 'No')){
                            this.issellerChqCancel = true; this.isSeller = true;
                        }

                    }else if (element.Document_Type__c == 'Borrower\'s Passbook') {
                        console.log('in if condition *** : ', );
                        this.borrowerData = element;
                        console.log('borrower pass *** : ', this.borrowerData);
                        if((this.borrowerData.enter_DETLS_asper_BWR_passbook_upload__c == 'No' || this.borrowerData.Is_passbook_legible_for_Borrower__c == 'No')){
                            this.isborrowPassbook = true;isBorrower = true;
                        }

                    }else if(element.Document_Type__c == 'Borrower\'s Bank Statement'){
                        this.borrowerData1 = element;
                        if((JSON.parse(JSON.stringify(this.borrowerData))).length == 0){
                            console.log('this.borrowerData bank: ',this.borrowerData);
                            this.borrowerData = element;
                        }
                        console.log('borrower bank *** : ', this.borrowerData1);
                        if((this.borrowerData1.enter_DETLS_asper_BWR_bank_STMT_upload__c == 'No' || this.borrowerData1.Is_bank_statement_legible_for_Borrower__c == 'No')){
                            this.isborrowerBankState = true ; this.isBorrower = true;
                        }
                    }
                    else if(element.Document_Type__c == 'Borrower\'s Cancel Cheque'){
                        this.borrowerData2 = element;
                        if((JSON.parse(JSON.stringify(this.borrowerData))).length == 0){
                            console.log('this.borrowerData cancel cheque: ',this.borrowerData);
                            this.borrowerData = element;
                        }
                        console.log('this.borrowerData2 : ',this.borrowerData2);
                        if( (this.borrowerData2.enter_DETLS_as_per_BWR_canc_chq_upload__c == 'No' || this.borrowerData2.Is_cancelled_cheque_legible_for_Borrower__c == 'No')){
                            this.isborrowercancelCheq = true; this.isBorrower = true;
                        }
                    } 
                    else if (element.Document_Type__c == 'Co-Borrower\'s Passbook') {
                        console.log('in if condition *** : ', );
                        this.coBorrowerData = element;
                        console.log('Coborrower pass *** : ', this.coBorrowerData);
                        if( (this.coBorrowerData.enter_DETLS_asper_COBWR_pasbook_upload__c == 'No' || this.coBorrowerData.Is_passbook_legible_for_CoBorrower__c == 'No')){
                            this.isCoborrowPassbook = true; this.isCoBorrower = true;
                        }
                    }
                    else if(element.Document_Type__c == 'Co-Borrower\'s Bank Statement'){
                        this.coBorrowerData1 = element;
                        if((JSON.parse(JSON.stringify(this.coBorrowerData))).length == 0){
                            console.log('this.coBorrowerData bank: ',this.coBorrowerData);
                            this.coBorrowerData = element;
                        }
                        console.log('Coborrower bank *** : ', this.coBorrowerData1);
                        if( (this.coBorrowerData1.DETLS_asper_COBWR_bank_STMT_upload__c == 'No' || this.coBorrowerData1.Is_bank_statement_legible_for_CoBorrowe__c == 'No')){
                            this.isCoborrowerBankState = true; this.isCoBorrower = true;
                        }
                    }
                    else if(element.Document_Type__c == 'Co-Borrower\'s Cancel Cheque'){
                        this.coBorrowerData2 = element;
                        if((JSON.parse(JSON.stringify(this.coBorrowerData))).length == 0){
                            console.log('this.coBorrowerData cancel cheque: ',this.coBorrowerData);
                            this.coBorrowerData = element;
                        }
                        console.log('this.coBorrowerData2 : ',this.coBorrowerData2);
                        if((this.coBorrowerData2.DETLS_asper_COBWR_canc_chq_upload__c == 'No' || this.coBorrowerData2.Is_cancelled_cheque_legible_CoBorrower__c == "No")){
                            this.isCoborrowercancelCheq = true; this.isCoBorrower = true;
                        }
                    }
                    else if (element.Document_Type__c == 'Buyer-Seller Undertaking letter') {
                    console.log('in if condition *** : ', );
                    this.buyerSellerData = element;
                    if( this.buyerSellerData.Buyer_Seller_Undertaking_Letter_legib__c == 'No'){
                        this.isBuyerSeller = true;
                    }
                   
                } else if (element.Document_Type__c == 'Indemnity letter') {
                    console.log('in if condition *** : ', );
                    this.indemnityLetterData = element;
                    if( this.indemnityLetterData.Buy_Seller_Indemnity_LTR_legible__c == 'No'){
                        this.isIndemnityLetter = true;
                    }
                   
                } else if (element.Document_Type__c == 'Sale Agreement') {
                    console.log('in if condition *** : ', );
                    this.saleAgreementData = element;
                    if( this.saleAgreementData.Is_Sale_Agreement_legible__c == 'No'){
                        this.isSaleAgreement = true;
                    }
                  
                }  else if (element.Document_Type__c == 'NOC') {
                        console.log('in if condition *** : ', );
                        this.nocData = element;
                        console.log('this.nocData  : ',this.nocData );
                        if( (this.nocData.Is_Cancelled_NOC_legible__c == 'No' || this.nocData.Are_enter_details_asper_NOC_doc_upload__c == 'No')){
                            this.isNOC = true;
                        }else if( (this.nocData.Is_Cancelled_NOC_legible__c == 'Yes' && this.nocData.Are_enter_details_asper_NOC_doc_upload__c == 'Yes')){
                            this.isNOC = false;
                        }
                       
                    } else if (element.Document_Type__c == 'Branch Undertaking letter') {
                        console.log('in if condition *** : ', );
                        this.branchUndertakingData = element;
                        if( this.branchUndertakingData.Is_Branch_Undertaking_Letter_legible__c == 'No'){
                            this.isBranchUndertake = true;
                        }
                        
                    }else if (element.Document_Type__c == 'Declaration of Borrower Good Health') {
                        console.log('in if condition *** : ', );
                        this.borrowerHealthData = element;
                        if( this.borrowerHealthData.Doc_for_Good_Health_borrower_legible__c == 'No'){
                            this.isBorrowerDeclare = true;
                        }else if(this.borrowerHealthData.Doc_for_Good_Health_borrower_legible__c == 'Yes'){
                            this.isBorrowerDeclare = false;  
                        }
                       
                    }else if (element.Document_Type__c == 'Declaration of Co-Borrower Good Health') {
                        console.log('in if condition *** : ', );
                        this.coBorrowerHealthData = element;
                        if(this.coBorrowerHealthData.Doc_for_Good_Health_coborrower_legible__c == 'No'){
                            this.isCoBorrowerDeclare = true;
                        }else if(this.coBorrowerHealthData.Doc_for_Good_Health_coborrower_legible__c == 'Yes'){
                            this.isCoBorrowerDeclare = false;
                        }
                        
                    } else if (element.Document_Type__c == 'Payment Receipt') {
                        console.log('payment receipt---',element);
                        this.paymentDocUploadedValue = element.enter_DETLS_asper_Payment_doc_upload__c;
                        this.paymentLegibleValue = element.Is_Payment_Receipt_legible__c;
                        this.paymentRemarksValue = element.Payment_Receipt_Remarks__c;
                        console.log('this.paymentList',this.paymentList)
                        this.keyIndex = this.paymentList.length;
                        this.paymentList.push({
                            'keyIndex': this.keyIndex,
                            'Payment_receipt_no__c': element.Payment_receipt_no__c,
                            'Payment_receipt_date__c': element.Payment_receipt_date__c,
                            'Payment_made_to__c': element.Payment_made_to__c,
                            'Payment_made_by__c': element.Payment_made_by__c,
                            'Payment_amount__c': element.Payment_amount__c,
                            'paymentPreview': '',
                            'docId': element.Id
                        });
                        this.isPaymentDataAlready = this.paymentList.length;

                        if((element.enter_DETLS_asper_Payment_doc_upload__c == 'No' || element.Is_Payment_Receipt_legible__c == 'No')){
                            this.isPaymentReceipts = true;this.isAddPayment = true;
                        }else if( element.enter_DETLS_asper_Payment_doc_upload__c == 'Yes' && element.Is_Payment_Receipt_legible__c == 'Yes'){
                            this.isPaymentReceipts = false;
                        }
                        console.log('OUTPUT : ', this.paymentList);
                    }
                });//CISP-4109
                if(!this.isRCVisible && !this.isBankTransfer && !this.isSeller && !this.isBorrower && !this.isCoBorrower && !this.isBuyerSeller && !this.isIndemnityLetter && !this.isSaleAgreement
                    && !this.isTaxInvoice && !this.isPaymentReceipts && !this.isNOC && !this.isBranchUndertake && !this.isBorrowerDeclare && !this.isCoBorrowerDeclare){
                    this.noDocSelected = true;
                                if(this.isCheckBoxSectionOpen===false){
                                    this.isBEVisible=false;
                                }
                }
            }
            //CISP-3726
            else{
                        this.noDocSelected = true;
                        if(this.isCheckBoxSectionOpen===false){
                            this.isBEVisible=false;
                        }
            }
            if (this.paymentList.length > 0) {
                this.paymentList.forEach(element => {
                    for (let i = 0; i < data.contentDocId.length; i++) {
                        if (data.contentDocId[i].LinkedEntityId == element.docId) {
                            console.log('in if record id match : ');
                            element.paymentPreview = data.contentDocId[i].ContentDocumentId
                        }
                    }
                });
                this.paymentList.forEach(element => {
                    for (let i = 0; i < data.contentVersionList.length; i++) {
                        if (data.contentVersionList[i].ContentDocumentId == element.paymentPreview) {
                            console.log('in if version id match : ');
                            element.contentVersion = data.contentVersionList[i].Id;
                            element.fileType = data.contentVersionList[i].FileType;
                        }
                    }
                });
                console.log('this.paymentList after content doc and version : ',this.paymentList);
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }//CISP-2735-END
    @track valueEnteredDetailsAsPerDocRC = '';
    @track valueIsRCDocLegible = '';
    @track valueRemarksRCDoc = '';
    @track valueIsSaleLegibleDD = ''
    @track valueRemarksSaleLegibleDD = ''
    @track valueIsForeclosureLetterLegible = ''
    @track valueForeclosureLetterRemarks = ''

    @track valueIfscCodeSeller = ''
    @track valueSellerPassbookUploaded = ''
    @track valueIsSellerPassbookLegible = ''
    @track valueSellerPassbookRemarks = ''
    @track valueIsSellerEnteredDetailsUploaded = ''
    @track valueIsSellerBankStatementLegible = ''
    @track valueSellerBankStatementRemarks = ''
    @track valueisSellerCanCheq = ''
    @track valueIsSellerCanCheqLegible = ''
    @track valueSellerCanCheqRemarks = ''

    @track valueIfscCodeBorrower = ''
    @track valueBorrowerPassbookUploaded = ''
    @track valueIsBorrowerPassbookLegible = ''
    @track valueBorrowerPassbookRemarks = ''
    @track valueIsBorrowerEnteredDetailsUploaded = ''
    @track valueIsBorrowerBankStatementLegible = ''
    @track valueBorrowerBankStatementRemarks = ''
    @track valueisBorrowerCanCheq = ''
    @track valueIsBorrowerCanCheqLegible = ''
    @track valueBorrowerCanCheqRemarks = ''

    @track valueIfscCodeCoBorrower = ''
    @track valueCoBorrowerPassbookUploaded = ''
    @track valueIsCoBorrowerPassbookLegible = ''
    @track valueCoBorrowerPassbookRemarks = ''
    @track valueIsCoBorrowerEnteredDetailsUploaded = ''
    @track valueIsCoBorrowerBankStatementLegible = ''
    @track valueCoBorrowerBankStatementRemarks = ''
    @track valueisCoBorrowerCanCheq = ''
    @track valueIsCoBorrowerCanCheqLegible = ''
    @track valueCoBorrowerCanCheqRemarks = ''

    @track valueIsBuyerSellerUndertakingLetterLegible = ''
    @track valueBuyerSellerUndertakingLetterRemarks = ''
    @track valueIsSaleAgreementLegible = ''
    @track valueSaleAgreementRemarks = ''

    @track valueIsIndemnityLetterLegible = ''
    @track valueIndemnityLetterRemarks = ''
    @track valueIsTaxInvoiceDcoUploaded = ''
    @track valueTaxInvoiceRemarks = ''
    @track valueIsTaxInvoiceLegible = ''
    @track valueIsNOCDetailsDocUpload = ''
    @track valueIsCancelNOCLegible = ''
    @track valuenOCRemarks = ''
    @track valueIsBranchUndertakLetterLegible = ''
    @track valueBranchUndertakRemarks = ''
    @track valueIsDecGoodBorrowerLegible = ''
    @track valueDecGoodBorrowerRemarks = ''
    @track valueIsDecGoodCoBorrower = ''
    @track valueDecGoodCoBorrowerRemarks = ''

    handleInputFieldChange(event) {
        this.isSubmitDisabled = false;
        if (event.target.name === 'hypothecationName') {
            this.disableHypothecation = false;
            this.isHypothecationValue = event.target.value;
            console.log('Is Hypothecation ::', this.isHypothecationValue);
        }
        //RC
        if (event.target.name == 'enteredDetailsAsPerDocRC') {
            this.valueEnteredDetailsAsPerDocRC = event.target.value;

        }if (event.target.name === 'isRCDocLegible') {
            this.valueIsRCDocLegible = event.target.value;
        }if (event.target.name === 'remarksRCDoc') {
            this.valueRemarksRCDoc = event.target.value;
        }
        //Bank Transfer
        if (event.target.name === 'isSaleLegibleDD') {
            this.valueIsSaleLegibleDD = event.target.value;
        }if (event.target.name === 'remarksSaleLegibleDD') {
            this.valueRemarksSaleLegibleDD = event.target.value;
        }
        if (event.target.name === 'isForeclosureLetterLegible') {
            this.valueIsForeclosureLetterLegible = event.target.value;
        }if (event.target.name === 'foreclosureLetterRemarks') {
            this.valueForeclosureLetterRemarks = event.target.value;
        }
        //Seller Bank targets
        if (event.target.name === 'ifscCodeSeller') {
            this.valueIfscCodeSeller = event.target.value;
        }if (event.target.name === 'isSellerPassbookUploaded') {
            this.valueSellerPassbookUploaded = event.target.value;
        }if (event.target.name === 'isSellerPassbookLegible') {
            this.valueIsSellerPassbookLegible = event.target.value;
        }if (event.target.name === 'sellerPassbookRemarks') {
            this.valueSellerPassbookRemarks = event.target.value;
        }if (event.target.name === 'isSellerEnteredDetailsUploaded') {
            this.valueIsSellerEnteredDetailsUploaded = event.target.value;
        }if (event.target.name === 'isSellerBankStatementLegible') {
            this.valueIsSellerBankStatementLegible = event.target.value;
        }if (event.target.name === 'sellerBankStatementRemarks') {
            this.valueSellerBankStatementRemarks = event.target.value;
        }if (event.target.name === 'isSellerCanCheq') {
            this.valueisSellerCanCheq = event.target.value;
        }if (event.target.name === 'isSellerCanCheqLegible') {
            this.valueIsSellerCanCheqLegible = event.target.value;
        }if (event.target.name === 'sellerCanCheqRemarks') {
            this.valueSellerCanCheqRemarks = event.target.value;
        }
        //Borrower
        if (event.target.name === 'ifscCodeBorrower') {
            this.valueIfscCodeBorrower = event.target.value;
        }if (event.target.name === 'isBorrowerPassbookUploaded') {
            this.valueBorrowerPassbookUploaded = event.target.value;
        }if (event.target.name === 'isBorrowerPassbookLegible') {
            this.valueIsBorrowerPassbookLegible = event.target.value;
        }if (event.target.name === 'borrowerPassbookRemarks') {
            this.valueBorrowerPassbookRemarks = event.target.value;
        }if (event.target.name === 'isBorrowerEnteredDetailsUploaded') {
            this.valueIsBorrowerEnteredDetailsUploaded = event.target.value;
        }if (event.target.name === 'isBorrowerBankStatementLegible') {
            this.valueIsBorrowerBankStatementLegible = event.target.value;
        }if (event.target.name === 'borrowerBankStatementRemarks') {
            this.valueBorrowerBankStatementRemarks = event.target.value;
        }if (event.target.name === 'isBorrowerCanCheq') {
            this.valueisBorrowerCanCheq = event.target.value;
        }if (event.target.name === 'isBorrowerCanCheqLegible') {
            this.valueIsBorrowerCanCheqLegible = event.target.value;
        }if (event.target.name === 'borrowerCanCheqRemarks') {
            this.valueBorrowerCanCheqRemarks = event.target.value;
        }
        //Coborrower
        if (event.target.name === 'ifscCodeCoBorrower') {
            this.valueIfscCodeCoBorrower = event.target.value;
        }if (event.target.name === 'isCoBorrowerPassbookUploaded') {
            this.valueCoBorrowerPassbookUploaded = event.target.value;
        }if (event.target.name === 'isCoBorrowerPassbookLegible') {
            this.valueIsCoBorrowerPassbookLegible = event.target.value;
        }if (event.target.name === 'coBorrowerPassbookRemarks') {
            this.valueCoBorrowerPassbookRemarks = event.target.value;
        }if (event.target.name === 'isCoBorrowerEnteredtargetsUploaded') {
            this.valueIsCoBorrowerBankStatementUploaded = event.target.value;
        }if (event.target.name === 'isCoBorrowerBankStatementLegible') {
            this.valueIsCoBorrowerBankStatementLegible = event.target.value;
        }if (event.target.name === 'coBorrowerBankStatementRemarks') {
            this.valueCoBorrowerBankStatementRemarks = event.target.value;
        }if (event.target.name === 'isCoBorrowerCanCheq') {
            this.valueisCoBorrowerCanCheq = event.target.value;
        }if (event.target.name === 'isCoBorrowerCanCheqLegible') {
            this.valueIsCoBorrowerCanCheqLegible = event.target.value;
        }if (event.target.name === 'coBorrowerCanCheqRemarks') {
            this.valueCoBorrowerCanCheqRemarks = event.target.value;
        }
        //Buyer-seller undertaking Letter
        if (event.target.name === 'isBuyerSellerUndertakingLetterLegible') {
            this.valueIsBuyerSellerUndertakingLetterLegible = event.target.value;
        }if (event.target.name === 'buyerSellerUndertakingLetterRemarks') {
            this.valueBuyerSellerUndertakingLetterRemarks = event.target.value;
        }
        //Indeminity Letter
        if (event.target.name === 'isIndemnityLetterLegible') {
            this.valueIsIndemnityLetterLegible = event.target.value;
        }if (event.target.name === 'indemnityLetterRemarks') {
            this.valueIndemnityLetterRemarks = event.target.value;
        }
        //Sale Agreement
        if (event.target.name === 'isSaleAgreementLegible') {
            this.valueIsSaleAgreementLegible = event.target.value;
        }if (event.target.name === 'saleAgreementRemarks') {
            this.valueSaleAgreementRemarks = event.target.value;
        }
        //Tax Invoice
        if (event.target.name === 'isTaxInvoiceDcoUploaded') {
            this.valueIsTaxInvoiceDcoUploaded = event.target.value;
        }if (event.target.name === 'isTaxInvoiceLegible') {
            this.valueIsTaxInvoiceLegible = event.target.value;
        }if (event.target.name === 'taxInvoiceRemarks') {
            this.valueTaxInvoiceRemarks = event.target.value;
        }
        //Noc
        if (event.target.name === 'isNOCDetailsDocUpload') {
            this.valueIsNOCtargetsDocUpload = event.target.value;
        }if (event.target.name === 'isCancelNOCLegible') {
            this.valueIsCancelNOCLegible = event.target.value;
        }if (event.target.name === 'nOCRemarks') {
            this.valuenOCRemarks = event.target.value;
        }
        //Branch Undertaking
        if (event.target.name === 'isBranchUndertakLetterLegible') {
            this.valueIsBranchUndertakLetterLegible = event.target.value;
        }if (event.target.name === 'branchUndertakRemarks') {
            this.valueBranchUndertakRemarks = event.target.value;
        }
        //Declaration of Good Health(borrower)
        if (event.target.name === 'isDecGoodBorrowerLegible'){
            this.valueIsDecGoodBorrowerLegible = event.target.value;
        }if (event.target.name === 'decGoodBorrowerRemarks') {
            this.valueDecGoodBorrowerRemarks = event.target.value;
        }
        ////Declaration of Good Health(Co-borrower)
        if (event.target.name === 'isDecGoodCoBorrower') {
            this.valueIsDecGoodCoBorrower = event.target.value;
        }if (event.target.name === 'decGoodCoBorrowerRemarks') {
            this.valueDecGoodCoBorrowerRemarks = event.target.value;
        }
    }

    handleCaptureChassisNumber(event) {
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        this.docType = 'Addtional Documents';
        this.uploadViewDocFlag = true;
    }
    addPaymentReceipt() {
        console.log('in addPaymentReceipt : ', this.paymentList.length);
        this.keyIndex = this.paymentList.length;
        this.isAddPayment = true;
        this.paymentList.push({
            'keyIndex': this.keyIndex,
            'Payment_receipt_no__c': '',
            'Payment_receipt_date__c': '',
            'Payment_made_to__c': '',
            'Payment_made_by__c': '',
            'Payment_amount__c': '',
            'paymentPreview': '',
            'docId': ''
        })
        // ++ this.keyIndex;
        this.paymentList = JSON.parse(JSON.stringify(this.paymentList))
        console.log('paymentList : ', this.paymentList);

    }
    deleteRow(event) {
        if(!this.isNotPreDisbursement){//CISP-3252
            console.log('this.paymentList before : ', this.paymentList);
            var index = event.target.dataset.targetId;
            console.log('index : ', index);
            let documentId = this.paymentList[index].docId;
            console.log('this.paymentList[index].docId : ', this.paymentList[index].docId);
            if (this.paymentList[index].docId) {
                deleteRecord(documentId);
            }
            console.log('this.documentIdWithTypeList before : ', this.documentIdWithTypeList);
            if (this.documentIdWithTypeList.length > 0) {
                for (var i = 0; i < this.documentIdWithTypeList.length; i++) {
                    if (this.documentIdWithTypeList[i] === documentId + ' ' + 'Payment Receipt') {
                        this.documentIdWithTypeList.splice(i, 1);
                        i--;
                    }
                }
            }
            console.log('this.documentIdWithTypeList after : ', this.documentIdWithTypeList);
    
            let temp = this.paymentList.filter(function(element) {
                return parseInt(element.keyIndex) !== parseInt(event.target.id);
            })
            console.log('temp : ', temp);
            this.paymentList = temp;
            this.keyIndex = this.paymentList.length;
            console.log('this.paymentList before : ', this.paymentList);
        }
    }
    handlePreviewPostSanction(event) {
        this.isSubmitCall = false;
        var index = event.target.dataset.targetId;
        console.log('index in preview : ', index);
        let contentDocId; 
        console.log('index in contentDocId : ', contentDocId);
        if(this.isCommunityUser == true){
            contentDocId = this.paymentList[index].contentVersion;
            this.fileType = this.paymentList[index].fileType;
        }else
        {
            contentDocId = this.paymentList[index].paymentPreview;
        }
        if (contentDocId) {
            this.previewFile(contentDocId,this.fileType);
        }
        
    }

    hideModalBox() {
        this.isPreview = false;
    }
    
    previewFile(contentDocId,fileType) {
        console.log('preview Id', contentDocId);
        console.log('OUTPUT : ',this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+ fileType +'&versionId=' + contentDocId);
        if(this.isCommunityUser == true){
           /* console.log('preview file when add doc is community user');
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url : this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + contentDocId
                }
            }, false );*/
            this.converId = contentDocId;
            this.isPreview = true;
        }
        else{
            console.log('preview file when add doc is salesforce user');
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: contentDocId
                }
            });
        }
    }
    handleUploadDocument(event) {
        this.isSubmitCall = false;
        this.isSubmitDisabled = false;
        this.docType = event.target.value;
        if(this.docType == 'Co-Borrower\'s Cancel Cheque' || this.docType == 'Declaration of Co-Borrower Good Health'
        || this.docType == 'Co-Borrower\'s Passbook' || this.docType == 'Co-Borrower\'s Bank Statement'){
            console.log('when document type related to co borrower : ',);
            this.applicantid = this.aaplicantIdCoBorrower;
        }else{
            this.applicantid = this.aaplicantIdBorrower;
        }
        if(this.applicantid == undefined || this.applicantid == '' || this.applicantid == null){
            this.applicantid = this.aaplicantIdBorrower
        }
        console.log('OUTPUT this.docType: ', this.docType);
        console.log('OUTPUT this.docType: ', this.applicantid);
        if (this.docType == 'Payment Receipt') {
            console.log('this.docType : ', this.docType);
            console.log('event.target.dataset.targetId: ', event.target.dataset.targetId);
            var index = event.target.dataset.targetId;
            console.log('index---- : ', index);
            this.indexRow = index;
        }
        console.log('event : ', event.target.value);

        this.docTypeListAll = JSON.parse(JSON.stringify(this.docTypeListAll));
        let newArray = this.docTypeListAll.filter(item => {
            if(item.Document_Type__c == this.docType){
                return item
            }
        });
        console.log('newArray : ',newArray);
        if(newArray.length > 0){//INDI-4645
            this.uploadAdditionalDocFlag = true;
                this.documentRecordId = newArray[0].Id;
                this.showUpload = true;
                this.showPhotoCopy = false;
                this.showDocView = true;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = false;
        }else{
        createDocumentForAdditionalDocument({
                docType: this.docType,
                vehicleDetailId: this.vehiclerecordid,
                applicantId: this.applicantid,
                loanApplicationId: this.recordId,
            })
            .then(result => {
                console.log('Result', result);
                this.documentIdWithType = result + ' ' + this.docType;
                console.log('documentIdWithType : ', this.documentIdWithType);
                if (this.docType == 'Payment Receipt') {
                    this.paymentList[this.indexRow].docId = result;

                }
                this.uploadAdditionalDocFlag = true;
                this.documentRecordId = result;
                this.showUpload = true;
                this.showPhotoCopy = false;
                this.showDocView = true;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = false;

                this.documentIdWithTypeList.push(this.documentIdWithType);
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }
        console.log('OUTPUT : ', this.uploadChequeDocFlag);
    }
    changeFlagValue() {
        this.uploadAdditionalDocFlag = false;
    }
    docUploadSuccessfully(event) {
        this.ContentDocumentId = event.detail;
        console.log('this.ContentDocumentId ---- : ', this.ContentDocumentId);
        if (this.docType == 'Payment Receipt') {
            this.paymentList[this.indexRow].paymentPreview = this.ContentDocumentId;
            
            if(this.ContentDocumentId){
                getContentVersion({ conDocId: this.ContentDocumentId })
                  .then(result => {
                    console.log('getContentVersion', result);
                    if(result!=null){
                        this.paymentList[this.indexRow].contentVersion = result[0].Id;
                        this.paymentList[this.indexRow].fileType = result[0].FileType;
                    }
                  })
                  .catch(error => {
                    console.error('Error:', error);
                });
            }
            console.log('paymentList : ', this.paymentList);
        }
    }
    onRCClick(event) {
        this.isSubmitDisabled = false;
        this.isRCVisible = event.target.checked;
       if(!event.target.checked){this.uncheckedRec.push('RC Document');}
    }
    handleSellerPassbook(event) {
        this.isSubmitDisabled = false;
        this.isSellerPassbook = event.target.checked;
        this.isSeller1 = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Seller\'s Passbook');}
        if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
            this.isSeller = true;
        } else {
            this.isSeller = false;
        }

    }
    handlesellerBankState(event) {
        this.isSubmitDisabled = false;
        this.issellerBankState = event.target.checked;
        this.isSeller2 = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Seller\'s Bank Statement');}
        if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
            this.isSeller = true;
        } else {
            this.isSeller = false;
        }
    }
    handlesellerChqCancel(event) {
        this.isSubmitDisabled = false;
        this.issellerChqCancel = event.target.checked;
        this.isSeller3 = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Seller\'s Cancel Cheque');}
        if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
            this.isSeller = true;
        } else {
            this.isSeller = false;
        }
    }
    handleDDforClosing(event) {
        this.isSubmitDisabled = false;
        this.isBankTransfer = event.target.checked;
        this.isDDforClosing = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('DD for closing existing loan');}
    }
    handleForeclosure(event) {
        this.isSubmitDisabled = false;
        this.isBankTransfer = event.target.checked;
        this.isForeClosure = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Foreclosure letter for closed existing loan');}
    }
    handleBorrowerDeclare(event) {
        this.isSubmitDisabled = false;
        this.isBorrowerDeclare = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Declaration of Borrower Good Health');}
    }
    handleCoBorrowerDeclare(event) {
        this.isSubmitDisabled = false;
        this.isCoBorrowerDeclare = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Declaration of Co-Borrower Good Health');}
    }
    handleBranchUndertake(event) {
        this.isSubmitDisabled = false;
        this.isBranchUndertake = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Branch Undertaking letter');}
    }
    handleNOC(event) {
        this.isSubmitDisabled = false;
        this.isNOC = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('NOC');}
    }
    handlePaymentReceipts(event) {
        this.isSubmitDisabled = false;
        this.isPaymentReceipts = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Payment Receipt');}
    }
    handleTaxInvoice(event) {
        this.isSubmitDisabled = false;
        this.isTaxInvoice = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Tax Invoice');}
    }
    handleSaleAgreement(event) {
        this.isSubmitDisabled = false;
        this.isSaleAgreement = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Sale Agreement');}
    }
    handleBuyerSeller(event) {
        this.isSubmitDisabled = false;
        this.isBuyerSeller = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Buyer-Seller Undertaking letter');}
    }
    handleindemnity(event) {
        this.isSubmitDisabled = false;
        this.isIndemnityLetter = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Indemnity letter');}
    }
    handleborrowercancelCheq(event) {
        this.isSubmitDisabled = false;
        this.isBorrower1 = event.target.checked;
        this.isborrowercancelCheq = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Borrower\'s Cancel Cheque');}
        if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
            this.isBorrower = true;
        } else {
            this.isBorrower = false;
        }
    }
    handleborrowerBankState(event) {
        this.isSubmitDisabled = false;
        this.isBorrower2 = event.target.checked;
        this.isborrowerBankState = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Borrower\'s Bank Statement');}
        if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
            this.isBorrower = true;
        } else {
            this.isBorrower = false;
        }
    }
    handleborrowPassbook(event) {
        this.isSubmitDisabled = false;
        this.isBorrower3 = event.target.checked;
        this.isborrowPassbook = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Borrower\'s Passbook');}
        if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
            this.isBorrower = true;
        } else {
            this.isBorrower = false;
        }
    }
    handleCoborrowerPassbook(event) {
        this.isSubmitDisabled = false;
        this.isCoBorrower1 = event.target.checked;
        this.isCoborrowPassbook = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Co-Borrower\'s Passbook');}
        if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
            this.isCoBorrower = true;
        } else {
            this.isCoBorrower = false;
        }
    }
    handleCoborrowerBankState(event) {
        this.isSubmitDisabled = false;
        this.isCoBorrower2 = event.target.checked;
        this.isCoborrowerBankState = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Co-Borrower\'s Bank Statement');}
        if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
            this.isCoBorrower = true;
        } else {
            this.isCoBorrower = false;
        }
    }
    handleCoboroowercancelChqCo(event) {
        this.isSubmitDisabled = false;
        this.isCoBorrower3 = event.target.checked;
        this.isCoborrowercancelCheq = event.target.checked;
        if(!event.target.checked){this.uncheckedRec.push('Co-Borrower\'s Cancel Cheque');}
        if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
            this.isCoBorrower = true;
        } else {
            this.isCoBorrower = false;
        }
    }
    /*handleSave() {
        this.handleUpdateAndSaveData();
    }*/
    @api handleSubmitFromParent(){
        this.handleUpdateAndSaveData(false);
    }
    //CISP-3726
    childChange(){
        this.handleSubmit();
    }

    handleSubmit() {
        if(this.isCheckBoxSectionOpen){
         deleteDocRecord({loanApplicationId:this.recordId, docDetails: this.uncheckedRec});
        }
        if(!this.stageCheck){
            this.isLoadingSpinner = true;
            this.postSavedDataOnSubmit();
        }else{
            this.handleUpdateAndSaveData(true);
        }
    }
    @track metaDataList = [];
    async postSavedDataOnSubmit() {
        console.log('--------',this.docTypeListAll)
        let dataObj = [];
        for(var i in this.docTypeListAll){
            if(this.docTypeListAll[i]['Document_Type__c'] == 'RC Document' && this.isRCVisible == true){//CISP-3325
                let valueEnteredDetailsAsPerDocRC1 = this.template.querySelector('[data-id="valueEnteredDetailsAsPerDocRC"]');
                let valueIsRCDocLegible1 = this.template.querySelector('[data-id="valueIsRCDocLegible"]');
                let valueRemarksRCDoc1 = this.template.querySelector('[data-id="valueRemarksRCDoc"]');
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'RC Document',
                    'Are_enter_details_as_per_RC_doc_upload__c': valueEnteredDetailsAsPerDocRC1.value,
                    'Are_entered_details_as_per_document_uplo__c': valueIsRCDocLegible1.value,
                    'Remarks_for_RC_Upload__c': valueRemarksRCDoc1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'DD for closing existing loan' && this.isBankTransfer == true){//CISP-3325
                let valueIsSaleLegibleDD1 = this.template.querySelector('[data-id="valueIsSaleLegibleDD"]');
                let valueRemarksSaleLegibleDD1 = this.template.querySelector('[data-id="valueRemarksSaleLegibleDD"]');
              
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'DD for closing existing loan',
                    'Is_sale_DD_legible__c': valueIsSaleLegibleDD1.value,
                    'Remarks_for_DD__c': valueRemarksSaleLegibleDD1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Foreclosure letter for closed existing loan' && this.isForeClosure == true){//CISP-3325
                let valueIsForeclosureLetterLegible1= this.template.querySelector('[data-id="valueIsForeclosureLetterLegible"]');
                let valueForeclosureLetterRemarks1 = this.template.querySelector('[data-id="valueForeclosureLetterRemarks"]');
              
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Foreclosure letter for closed existing loan',
                    'Is_sale_Foreclosure_Letter_legible__c': valueIsForeclosureLetterLegible1.value,
                    'Remarks_for_foreclosure_letter__c': valueForeclosureLetterRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Seller\'s Passbook' && this.isSellerPassbook == true){//CISP-3325
                let valueSellerPassbookUploaded1 = this.template.querySelector('[data-id="valueSellerPassbookUploaded"]');
                let valueIsSellerPassbookLegible1 = this.template.querySelector('[data-id="valueIsSellerPassbookLegible"]');
                let valueSellerPassbookRemarks1 = this.template.querySelector('[data-id="valueSellerPassbookRemarks"]');
                
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Seller\'s Passbook',
                    'entered_details_asper_passbook_upload__c': valueSellerPassbookUploaded1.value,
                    'Is_passbook_legible_for_Seller__c': valueIsSellerPassbookLegible1.value,
                    'Passbook_Remarks_for_Seller__c': valueSellerPassbookRemarks1.value,
                    
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Seller\'s Bank Statement' && this.issellerBankState == true){//CISP-3325
                let valueIsSellerEnteredDetailsUploaded1 = this.template.querySelector('[data-id="valueIsSellerEnteredDetailsUploaded"]');
                let valueIsSellerBankStatementLegible1 = this.template.querySelector('[data-id="valueIsSellerBankStatementLegible"]');
                let valueSellerBankStatementRemarks1 = this.template.querySelector('[data-id="valueSellerBankStatementRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Seller\'s Bank Statement',
                    'enter_details_asper_bank_STMT_upload__c': valueIsSellerEnteredDetailsUploaded1.value,
                    'Is_bank_statement_legible_for_Seller__c': valueIsSellerBankStatementLegible1.value,
                    'Bank_Statement_Remarks_for_Seller__c': valueSellerBankStatementRemarks1.value,
                    
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Seller\'s Cancel Cheque' && this.issellerChqCancel == true){//CISP-3325
                let valueisSellerCanCheq1 = this.template.querySelector('[data-id="valueisSellerCanCheq"]');
                let valueIsSellerCanCheqLegible1 = this.template.querySelector('[data-id="valueIsSellerCanCheqLegible"]');
                let valueSellerCanCheqRemarks1 = this.template.querySelector('[data-id="valueSellerCanCheqRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Seller\'s Cancel Cheque',
                    'enter_details_as_per_canc_chq_upload__c': valueisSellerCanCheq1.value,
                    'Is_cancelled_cheque_legible_for_Seller__c': valueIsSellerCanCheqLegible1.value,
                    'cancelled_cheque_Remarks_for_Seller__c': valueSellerCanCheqRemarks1.value,
                   
                }
                dataObj.push(obj);
            }
            if(this.docTypeListAll[i]['Document_Type__c'] == 'Borrower\'s Passbook' && this.isborrowPassbook == true){//CISP-3325
                let valueBorrowerPassbookUploaded1 = this.template.querySelector('[data-id="valueBorrowerPassbookUploaded"]');
                let valueIsBorrowerPassbookLegible1 = this.template.querySelector('[data-id="valueIsBorrowerPassbookLegible"]');
                let valueBorrowerPassbookRemarks1 = this.template.querySelector('[data-id="valueBorrowerPassbookRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Borrower\'s Passbook',
                    'enter_DETLS_asper_BWR_passbook_upload__c': valueBorrowerPassbookUploaded1.value,
                    'Is_passbook_legible_for_Borrower__c': valueIsBorrowerPassbookLegible1.value,
                    'Passbook_Remarks_for_Borrower__c': valueBorrowerPassbookRemarks1.value,
                   
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Borrower\'s Bank Statement' && this.isborrowerBankState == true){//CISP-3325
                let valueIsBorrowerEnteredDetailsUploaded1 = this.template.querySelector('[data-id="valueIsBorrowerEnteredDetailsUploaded"]');
                let valueIsBorrowerBankStatementLegible1 = this.template.querySelector('[data-id="valueIsBorrowerBankStatementLegible"]');
                let valueBorrowerBankStatementRemarks1 = this.template.querySelector('[data-id="valueBorrowerBankStatementRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Borrower\'s Bank Statement',
                    'enter_DETLS_asper_BWR_bank_STMT_upload__c': valueIsBorrowerEnteredDetailsUploaded1.value,
                    'Is_bank_statement_legible_for_Borrower__c': valueIsBorrowerBankStatementLegible1.value,
                    'Bank_Statement_Remarks_for_Borrower__c': valueBorrowerBankStatementRemarks1.value,
                   
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Borrower\'s Cancel Cheque' && this.isborrowercancelCheq == true){//CISP-3325
                let valueisBorrowerCanCheq1 = this.template.querySelector('[data-id="valueisBorrowerCanCheq"]');
                let valueIsCoBorrowerPassbookLegible1 = this.template.querySelector('[data-id="valueIsBorrowerCanCheqLegible"]');
                let valueCoBorrowerPassbookRemarks1 = this.template.querySelector('[data-id="valueBorrowerCanCheqRemarks"]');
                
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Borrower\'s Cancel Cheque',
                    'enter_DETLS_as_per_BWR_canc_chq_upload__c': valueisBorrowerCanCheq1.value,
                    'Is_cancelled_cheque_legible_for_Borrower__c': valueIsCoBorrowerPassbookLegible1.value,
                    'Cancelled_cheque_Remarks_for_Borrower__c': valueCoBorrowerPassbookRemarks1.value,
                    
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Co-Borrower\'s Passbook' && this.isCoborrowPassbook == true){//CISP-3325
                let valueIsCoBorrowerEnteredDetailsUploaded1 = this.template.querySelector('[data-id="valueIsCoBorrowerEnteredDetailsUploaded"]');
                let valueIsCoBorrowerBankStatementLegible1 = this.template.querySelector('[data-id="valueIsCoBorrowerBankStatementLegible"]');
                let valueCoBorrowerBankStatementRemarks1 = this.template.querySelector('[data-id="valueCoBorrowerBankStatementRemarks"]');
              
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Co-Borrower\'s Passbook',
                    'enter_DETLS_asper_COBWR_pasbook_upload__c': valueIsCoBorrowerEnteredDetailsUploaded1.value,
                    'Is_passbook_legible_for_CoBorrower__c': valueIsCoBorrowerBankStatementLegible1.value,
                    'Passbook_Remarks_for_CoBorrower__c': valueCoBorrowerBankStatementRemarks1.value,
                   
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Co-Borrower\'s Bank Statement' && this.isCoborrowerBankState == true){//CISP-3325
                let valueisCoBorrowerBank1 = this.template.querySelector('[data-id="valueisCoBorrowerBank"]');
                let valueIsCoBorrowerBankLegible1 = this.template.querySelector('[data-id="valueIsCoBorrowerBankLegible"]');
                let valueCoBorrowerBankqRemarks1 = this.template.querySelector('[data-id="valueCoBorrowerBankqRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Co-Borrower\'s Bank Statement',
                    'DETLS_asper_COBWR_bank_STMT_upload__c': valueisCoBorrowerBank1.value,
                    'Is_bank_statement_legible_for_CoBorrowe__c': valueIsCoBorrowerBankLegible1.value,
                    'Bank_Statement_Remarks_for_CoBorrower__c': valueCoBorrowerBankqRemarks1.value,
                    
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Co-Borrower\'s Cancel Cheque' && this.isCoborrowercancelCheq == true){//CISP-3325
                let valueisBorrowerCanCheq1 = this.template.querySelector('[data-id="valueisCoBorrowerCanCheq"]');
                let valueIsBorrowerCanCheqLegible1 = this.template.querySelector('[data-id="valueIsCoBorrowerCanCheqLegible"]');
                let valueBorrowerCanCheqRemarks1 = this.template.querySelector('[data-id="valueCoBorrowerCanCheqRemarks"]');
                
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Co-Borrower\'s Cancel Cheque',
                    'DETLS_asper_COBWR_canc_chq_upload__c': valueisBorrowerCanCheq1.value,
                    'Is_cancelled_cheque_legible_CoBorrower__c': valueIsBorrowerCanCheqLegible1.value,
                    'Cancelled_cheque_Remarks_for_CoBorrower__c': this.valueCoBorrowerCanCheqRemarks,
                   
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Buyer-Seller Undertaking letter' && this.isBuyerSeller == true){//CISP-3325
                let valueIsBuyerSellerUndertakingLetterLegible1 = this.template.querySelector('[data-id="valueIsBuyerSellerUndertakingLetterLegible"]');
                let valueBuyerSellerUndertakingLetterRemarks1 = this.template.querySelector('[data-id="valueBuyerSellerUndertakingLetterRemarks"]');
              
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Buyer-Seller Undertaking letter',
                    'Buyer_Seller_Undertaking_Letter_legib__c': valueIsBuyerSellerUndertakingLetterLegible1.value,
                    'Buyer_Seller_Undertaking_Letter_Remarks__c': valueBuyerSellerUndertakingLetterRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Indemnity letter' && this.isIndemnityLetter == true){//CISP-3325
                let valueIsIndemnityLetterLegible1 = this.template.querySelector('[data-id="valueIsIndemnityLetterLegible"]');
                let valueIndemnityLetterRemarks1 = this.template.querySelector('[data-id="valueIndemnityLetterRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Indemnity letter',
                    'Buy_Seller_Indemnity_LTR_legible__c': valueIsIndemnityLetterLegible1.value,
                    'Indemnity_Remarks__c': valueIndemnityLetterRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Sale Agreement' && this.isSaleAgreement == true){//CISP-3325
                let valueIsSaleAgreementLegible1 = this.template.querySelector('[data-id="valueIsSaleAgreementLegible"]');
                let valueSaleAgreementRemarks1 = this.template.querySelector('[data-id="valueSaleAgreementRemarks"]');
          
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Sale Agreement',
                    'Is_Sale_Agreement_legible__c': valueIsSaleAgreementLegible1.value,
                    'Sale_Agreement_Remarks__c': valueSaleAgreementRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Tax Invoice' && this.isTaxInvoice == true){//CISP-3325
                

                let valueIsTaxInvoiceDcoUploaded1 = this.template.querySelector('[data-id="valueIsTaxInvoiceDcoUploaded"]');
                let valueIsTaxInvoiceLegible1 = this.template.querySelector('[data-id="valueIsTaxInvoiceLegible"]');
                let valueTaxInvoiceRemarks1 = this.template.querySelector('[data-id="valueTaxInvoiceRemarks"]');

                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Tax Invoice',
                    'enter_details_asper_Tax_Invoice_upload__c': valueIsTaxInvoiceDcoUploaded1.value,
                    'Is_Tax_Invoice_legible__c': valueIsTaxInvoiceLegible1.value,
                    'Tax_Invoice_Remarks__c': valueTaxInvoiceRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'NOC' && this.isNOC == true){//CISP-3325
                let valueIsNOCDetailsDocUpload1 = this.template.querySelector('[data-id="valueIsNOCDetailsDocUpload"]');
                let valueIsCancelNOCLegible1 = this.template.querySelector('[data-id="valueIsCancelNOCLegible"]');
                let valuenOCRemarks1 = this.template.querySelector('[data-id="valuenOCRemarks"]');
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'NOC',
                    'Are_enter_details_asper_NOC_doc_upload__c': valueIsNOCDetailsDocUpload1.value,
                    'Is_Cancelled_NOC_legible__c': valueIsCancelNOCLegible1.value,
                    'NOC_Remarks__c': valuenOCRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Branch Undertaking letter' && this.isBranchUndertake == true){//CISP-3325
                let valueIsBranchUndertakLetterLegible1 = this.template.querySelector('[data-id="valueIsBranchUndertakLetterLegible"]');
                let valueBranchUndertakRemarks1 = this.template.querySelector('[data-id="valueBranchUndertakRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Branch Undertaking letter',
                    'Is_Branch_Undertaking_Letter_legible__c': valueIsBranchUndertakLetterLegible1.value,
                    'Branch_Undertaking_Remarks__c': valueBranchUndertakRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Declaration of Borrower Good Health' && this.isBorrowerDeclare == true){//CISP-3325
                let valueIsDecGoodBorrowerLegible1 = this.template.querySelector('[data-id="valueIsDecGoodBorrowerLegible"]');
                let valueDecGoodBorrowerRemarks1 = this.template.querySelector('[data-id="valueDecGoodBorrowerRemarks"]');
             
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Declaration of Borrower Good Health',
                    'Doc_for_Good_Health_borrower_legible__c': valueIsDecGoodBorrowerLegible1.value,
                    'Borrower_Good_Health_Dec_Remarks__c': valueDecGoodBorrowerRemarks1.value,
                }
                dataObj.push(obj);
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Declaration of Co-Borrower Good Health' && this.isCoBorrowerDeclare == true){//CISP-3325
                let valueIsDecGoodCoBorrower1 = this.template.querySelector('[data-id="valueIsDecGoodCoBorrower"]');
                let valueDecGoodCoBorrowerRemarks1 = this.template.querySelector('[data-id="valueDecGoodCoBorrowerRemarks"]');
               
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Declaration of Co-Borrower Good Health',
                    'Doc_for_Good_Health_coborrower_legible__c': valueIsDecGoodCoBorrower1.value,
                    'CoBorrower_Good_Health_Declaration_Remak__c': valueDecGoodCoBorrowerRemarks1.value,
                }
                dataObj.push(obj);
            }
            if(this.docTypeListAll[i]['Document_Type__c'] == 'Payment Receipt' && this.isPaymentReceipts == true){ //CISP-3325
                console.log('payment list to add',this.paymentList);
                
                let valuepaymentReceiptUploaded = this.template.querySelector('[data-id="paymentReceiptUploaded"]');
                let valuepaymentReceiptLegible = this.template.querySelector('[data-id="paymentReceiptLegible"]');
                let valuepaymentRemarks = this.template.querySelector('[data-id="paymentRemarks"]');
                let obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Payment Receipt',
                    'enter_DETLS_asper_Payment_doc_upload__c':valuepaymentReceiptUploaded.value,
                    'Is_Payment_Receipt_legible__c':valuepaymentReceiptLegible.value,
                    'Payment_Receipt_Remarks__c':valuepaymentRemarks.value,
                }
                console.log('obj : ', obj);
                dataObj.push(obj);
            }
        }
        console.log('dataObj',dataObj)
        var data1 =await postSavedDataOnSubmit({loanApplicationId:this.recordId,data: JSON.stringify(dataObj), dealId: this.dealId});

        if(data1 == 'RCU case is not closed!'){
            const evt = new ShowToastEvent({
                title: "Warning",
                message: 'RCU case is not closed!',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Opportunity',
                    actionName: 'view',
                },
            });
        }else if(data1 == 'Success'){
            this.dispatchEvent(new ShowToastEvent({title: 'Success',message: 'Data Submit Success',variant: 'success',}),);
            // eval("$A.get('e.force:refreshView').fire();");
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Opportunity',
                    actionName: 'view',
                },
            });
         }
         else{
            console.log('error',data1)
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: data1,variant: 'error',}),);    
         }
         this.isLoadingSpinner = false;
    }
    async handleUpdateAndSaveData(subFlag) {
        console.log('test sdfgfd');
        let res = await fetchAdditionalDocuments({'lAId' : this.recordId, dealId: this.dealId});
        console.log('result testdfgfdsa ', res);
        if(res){
            this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: `Please upload atleast one file in ${res} document.`,variant: 'warning',}),);
            return;
        }
        let isSuccess = false;
        let isAllDocumentUploaded = false;
        let allDocTypeChecked = [];//CISP-2432
        console.log('handleUpdateAndSaveData');
        let data;
     
            data = this.template.querySelectorAll('.chkBox');
            console.log('data : ',data);
    
        
        let count= 0;
        data.forEach(currentItem => {
            if(currentItem.checked == true){
                count ++;
                allDocTypeChecked.push(currentItem.name);//CISP-2432
            }
        });
        
        console.log('count',count);
        console.log('documentIdWithTypeList : ',this.documentIdWithTypeList.length);
        if(this.documentIdWithTypeList.length == 0 && count != 0 && !this.isD2C){//CISP-7005
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please upload atleast one document',
                    variant: 'error',
                }),
            );
            return;
        }
        if(this.documentIdWithTypeList.length >= count || this.isD2C ){//CISP-7005
            isAllDocumentUploaded = true;
        }
        let isNocUploaded = false;
        let isBorrowerUploaded = false;
        if (this.vehicleCategoryCode == 'RLN' && this.isNOC == true) {
            console.log('In RLN : ', );
            if (this.documentIdWithTypeList.length > 0) {
                this.documentIdWithTypeList.forEach(currentItem => {
                    let docTypeandId = currentItem.substring(0, currentItem.indexOf(' '));
                    let docTypeName = currentItem.substring(currentItem.indexOf(' ') + 1);
                    console.log('OUTPUT : ', );
                    if (docTypeName == 'NOC') {
                        isNocUploaded = true;
                    }
                });
            } else {
                isNocUploaded = false;
            }
        } else {
            isNocUploaded = true;
        }

        if (this.isBorrowerDeclare == true  || this.isCoBorrowerDeclare == true) {
            console.log('In isBorrowerDeclare : ', );
            if (this.documentIdWithTypeList.length > 0) {
                this.documentIdWithTypeList.forEach(currentItem => {
                    let docTypeandId = currentItem.substring(0, currentItem.indexOf(' '));
                    let docTypeName = currentItem.substring(currentItem.indexOf(' ') + 1);
                    console.log('OUTPUT docTypeName: ', docTypeName);
                    if (docTypeName == 'Declaration of Borrower Good Health' || docTypeName == 'Declaration of Co-Borrower Good Health') {
                        isBorrowerUploaded = true;
                    }
                });
            } else {
                isBorrowerUploaded = false;
            }
        } else {
            isBorrowerUploaded = true;
        }
        let paymentIndex = 0;
        if (this.isPaymentDataAlready > 0) {
            console.log('this.isPaymentDataAlready.length : ', this.isPaymentDataAlready);
            paymentIndex = this.isPaymentDataAlready;
        }
        console.log('paymentIndex ---: ', paymentIndex);
        let isAllValid = [];
        console.log('OUTPUT in handle submit', this.documentIdWithTypeList);
        let dataObj = [];
        this.documentIdWithTypeList.forEach(currentItem => {
            console.log('currentItem in handle submit', currentItem);
            let docTypeandId = currentItem.substring(0, currentItem.indexOf(' '));
            let docTypeName = currentItem.substring(currentItem.indexOf(' ') + 1);
            console.log('docTypeandId : ', docTypeandId);
            console.log('docTypeName : ', docTypeName);
            if (docTypeName == 'RC Document' && this.isRCVisible == true) {
                let RCOwner = this.template.querySelector('[data-id="RCOwner"]');
                let Hypothecationavailable = this.template.querySelector('[data-id="Hypothecationavailable"]');
                let hypothecationName = this.template.querySelector('[data-id="hypothecationName"]');
                RCOwner.reportValidity();
                Hypothecationavailable.reportValidity();
                hypothecationName.reportValidity();

                if (RCOwner.validity.valid === true && Hypothecationavailable.validity.valid && hypothecationName.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'RC_Owner__c': RCOwner.value,
                        'Hypothecation_available__c': Hypothecationavailable.value,
                        'Hypothecation_in_name_of__c': hypothecationName.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'DD for closing existing loan') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            } else if (docTypeName == 'Foreclosure letter for closed existing loan') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            } else if (docTypeName == 'Seller\'s Passbook' && this.isSellerPassbook == true) {
                console.log('in seller : ', );
                let sellerBankName = this.template.querySelector('[data-id="sellerBankName"]');
                let sellerAccountNumber = this.template.querySelector('[data-id="sellerAccountNumber"]');
                let sellerAccountHolder = this.template.querySelector('[data-id="sellerAccountHolder"]');
                let valueIfscCodeSeller1 = this.template.querySelector('[data-id="valueIfscCodeSeller"]');
                sellerBankName.reportValidity();
                sellerAccountNumber.reportValidity();
                sellerAccountHolder.reportValidity();

                if (sellerBankName.validity.valid === true && sellerAccountNumber.validity.valid && sellerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Seller_Bank_name__c': sellerBankName.value,
                        'Seller_Account_number__c': sellerAccountNumber.value,
                        'Name_of_Seller_account_holder__c': sellerAccountHolder.value,
                        'IFSC_code_Seller__c': valueIfscCodeSeller1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }


            } else if (docTypeName == 'Seller\'s Bank Statement' && this.issellerBankState == true) {
                console.log('in seller : ', );
                let sellerBankName = this.template.querySelector('[data-id="sellerBankName"]');
                let sellerAccountNumber = this.template.querySelector('[data-id="sellerAccountNumber"]');
                let sellerAccountHolder = this.template.querySelector('[data-id="sellerAccountHolder"]');
                let valueIfscCodeSeller1 = this.template.querySelector('[data-id="valueIfscCodeSeller"]');
                sellerBankName.reportValidity();
                sellerAccountNumber.reportValidity();
                sellerAccountHolder.reportValidity();

                if (sellerBankName.validity.valid === true && sellerAccountNumber.validity.valid && sellerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Seller_Bank_name__c': sellerBankName.value,
                        'Seller_Account_number__c': sellerAccountNumber.value,
                        'Name_of_Seller_account_holder__c': sellerAccountHolder.value,
                        'IFSC_code_Seller__c': valueIfscCodeSeller1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'Seller\'s Cancel Cheque' && this.issellerChqCancel == true) {
                console.log('in seller : ', );
                let sellerBankName = this.template.querySelector('[data-id="sellerBankName"]');
                let sellerAccountNumber = this.template.querySelector('[data-id="sellerAccountNumber"]');
                let sellerAccountHolder = this.template.querySelector('[data-id="sellerAccountHolder"]');
                let valueIfscCodeSeller1 = this.template.querySelector('[data-id="valueIfscCodeSeller"]');
                sellerBankName.reportValidity();
                sellerAccountNumber.reportValidity();
                sellerAccountHolder.reportValidity();

                if (sellerBankName.validity.valid === true && sellerAccountNumber.validity.valid && sellerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Seller_Bank_name__c': sellerBankName.value,
                        'Seller_Account_number__c': sellerAccountNumber.value,
                        'Name_of_Seller_account_holder__c': sellerAccountHolder.value,
                        'IFSC_code_Seller__c': valueIfscCodeSeller1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'Borrower\'s Passbook' && this.isborrowPassbook == true) {
                let borrowerBankName = this.template.querySelector('[data-id="borrowerBankName"]');
                let borrowerAccountNumber = this.template.querySelector('[data-id="borrowerAccountNumber"]');
                let borrowerAccountHolder = this.template.querySelector('[data-id="borrowerAccountHolder"]');
                let valueIfscCodeBorrower1 = this.template.querySelector('[data-id="valueIfscCodeBorrower"]');
                borrowerBankName.reportValidity();
                borrowerAccountNumber.reportValidity();
                borrowerAccountHolder.reportValidity();

                if (borrowerBankName.validity.valid === true && borrowerAccountNumber.validity.valid && borrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Borrower_Bank_name__c': borrowerBankName.value,
                        'Borrower_Account_number__c': borrowerAccountNumber.value,
                        'Name_of_Borrower_account_holder__c': borrowerAccountHolder.value,
                        'IFSC_code_Borrower__c': valueIfscCodeBorrower1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'Borrower\'s Bank Statement' && this.isborrowerBankState == true) {
                let borrowerBankName = this.template.querySelector('[data-id="borrowerBankName"]');
                let borrowerAccountNumber = this.template.querySelector('[data-id="borrowerAccountNumber"]');
                let borrowerAccountHolder = this.template.querySelector('[data-id="borrowerAccountHolder"]');
                let valueIfscCodeBorrower1 = this.template.querySelector('[data-id="valueIfscCodeBorrower"]');
                borrowerBankName.reportValidity();
                borrowerAccountNumber.reportValidity();
                borrowerAccountHolder.reportValidity();

                if (borrowerBankName.validity.valid === true && borrowerAccountNumber.validity.valid && borrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Borrower_Bank_name__c': borrowerBankName.value,
                        'Borrower_Account_number__c': borrowerAccountNumber.value,
                        'Name_of_Borrower_account_holder__c': borrowerAccountHolder.value,
                        'IFSC_code_Borrower__c': valueIfscCodeBorrower1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Borrower\'s Cancel Cheque' && this.isborrowercancelCheq == true) {
                let borrowerBankName = this.template.querySelector('[data-id="borrowerBankName"]');
                let borrowerAccountNumber = this.template.querySelector('[data-id="borrowerAccountNumber"]');
                let borrowerAccountHolder = this.template.querySelector('[data-id="borrowerAccountHolder"]');
                let valueIfscCodeBorrower1 = this.template.querySelector('[data-id="valueIfscCodeBorrower"]');
                borrowerBankName.reportValidity();
                borrowerAccountNumber.reportValidity();
                borrowerAccountHolder.reportValidity();

                if (borrowerBankName.validity.valid === true && borrowerAccountNumber.validity.valid && borrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Borrower_Bank_name__c': borrowerBankName.value,
                        'Borrower_Account_number__c': borrowerAccountNumber.value,
                        'Name_of_Borrower_account_holder__c': borrowerAccountHolder.value,
                        'IFSC_code_Borrower__c': valueIfscCodeBorrower1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Co-Borrower\'s Passbook' && this.isCoborrowPassbook == true) {
                let coBorrowerBankName = this.template.querySelector('[data-id="coBorrowerBankName"]');
                let coBorrowerAccountNumber = this.template.querySelector('[data-id="coBorrowerAccountNumber"]');
                let coBorrowerAccountHolder = this.template.querySelector('[data-id="coBorrowerAccountHolder"]');
                let valueIfscCodeCoBorrower1 = this.template.querySelector('[data-id="valueIfscCodeCoBorrower"]');
                coBorrowerBankName.reportValidity();
                coBorrowerAccountNumber.reportValidity();
                coBorrowerAccountHolder.reportValidity();
                if (coBorrowerBankName.validity.valid === true && coBorrowerAccountNumber.validity.valid && coBorrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'CoBorrower_Bank_name__c': coBorrowerBankName.value,
                        'CoBorrower_Account_number__c': coBorrowerAccountNumber.value,
                        'Name_of_CoBorrower_account_holder__c': coBorrowerAccountHolder.value,
                        'IFSC_code_CoBorrower__c': valueIfscCodeCoBorrower1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'Co-Borrower\'s Bank Statement' && this.isCoborrowerBankState == true) {
                let coBorrowerBankName = this.template.querySelector('[data-id="coBorrowerBankName"]');
                let coBorrowerAccountNumber = this.template.querySelector('[data-id="coBorrowerAccountNumber"]');
                let coBorrowerAccountHolder = this.template.querySelector('[data-id="coBorrowerAccountHolder"]');
                let valueIfscCodeCoBorrower1 = this.template.querySelector('[data-id="valueIfscCodeCoBorrower"]');
                coBorrowerBankName.reportValidity();
                coBorrowerAccountNumber.reportValidity();
                coBorrowerAccountHolder.reportValidity();
                if (coBorrowerBankName.validity.valid === true && coBorrowerAccountNumber.validity.valid && coBorrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'CoBorrower_Bank_name__c': coBorrowerBankName.value,
                        'CoBorrower_Account_number__c': coBorrowerAccountNumber.value,
                        'Name_of_CoBorrower_account_holder__c': coBorrowerAccountHolder.value,
                        'IFSC_code_CoBorrower__c': valueIfscCodeCoBorrower1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Co-Borrower\'s Cancel Cheque' && this.isCoborrowercancelCheq == true) {
                let coBorrowerBankName = this.template.querySelector('[data-id="coBorrowerBankName"]');
                let coBorrowerAccountNumber = this.template.querySelector('[data-id="coBorrowerAccountNumber"]');
                let coBorrowerAccountHolder = this.template.querySelector('[data-id="coBorrowerAccountHolder"]');
                let valueIfscCodeCoBorrower1 = this.template.querySelector('[data-id="valueIfscCodeCoBorrower"]');
                coBorrowerBankName.reportValidity();
                coBorrowerAccountNumber.reportValidity();
                coBorrowerAccountHolder.reportValidity();
                if (coBorrowerBankName.validity.valid === true && coBorrowerAccountNumber.validity.valid && coBorrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'CoBorrower_Bank_name__c': coBorrowerBankName.value,
                        'CoBorrower_Account_number__c': coBorrowerAccountNumber.value,
                        'Name_of_CoBorrower_account_holder__c': coBorrowerAccountHolder.value,
                        'IFSC_code_CoBorrower__c': valueIfscCodeCoBorrower1.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Buyer-Seller Undertaking letter') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            } else if (docTypeName == 'Indemnity letter') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            } else if (docTypeName == 'Sale Agreement') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            } else if (docTypeName == 'Tax Invoice' && this.isTaxInvoice == true) {
                console.log('in Tax invoice : ', );
                let invoiceNumber = this.template.querySelector('[data-id="invoiceNumber"]');
                let invoiceDate = this.template.querySelector('[data-id="invoiceDate"]');
                let invoiceAmount = this.template.querySelector('[data-id="invoiceAmount"]');
                invoiceNumber.reportValidity();
                invoiceDate.reportValidity();
                invoiceAmount.reportValidity();
                console.log('invoiceNumber.validity.valid  : ', invoiceNumber.validity.valid);
                console.log('invoiceDate.validity.valid : ', invoiceDate.validity.valid);
                console.log('invoiceAmount.validity.valid : ', invoiceAmount.validity.valid);
                if (invoiceNumber.validity.valid === true && invoiceDate.validity.valid && invoiceAmount.validity.valid) {
                    console.log('in invoice part if  : ', );
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Invoice_number__c': invoiceNumber.value,
                        'Invoice_date__c': invoiceDate.value,
                        'Invoice_amount__c': invoiceAmount.value,
                    }
                    dataObj.push(obj);
                } else {
                    console.log('in invoice part else : ', );
                    isAllValid.push(false);
                }


            } else if (docTypeName == 'Payment Receipt'  && this.isPaymentReceipts == true) {
                console.log('Payment Receipt : ',docTypeandId );
                console.log('payment list to add',this.paymentList);
                let findArray = this.paymentList.filter(item => item.docId == docTypeandId);
                console.log('findArray',findArray[0].keyIndex);
                let findedIndex = findArray[0].keyIndex;
                let receiptNo = this.template.querySelectorAll('[data-id="receiptNo"]');
                let receiptDate = this.template.querySelectorAll('[data-id="receiptDate"]');
                let paymentMadeTo = this.template.querySelectorAll('[data-id="paymentMadeTo"]');
                let paymentMadeBy = this.template.querySelectorAll('[data-id="paymentMadeBy"]');
                let paymentAmount = this.template.querySelectorAll('[data-id="paymentAmount"]');

                console.log('payment part if  : ', );
                isAllValid.push(true);
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                    'Payment_receipt_no__c': receiptNo[findedIndex].value,
                    'Payment_receipt_date__c': receiptDate[findedIndex].value,
                    'Payment_made_to__c': paymentMadeTo[findedIndex].value,
                    'Payment_made_by__c': paymentMadeBy[findedIndex].value,
                    'Payment_amount__c': paymentAmount[findedIndex].value,
                }
                console.log('obj : ', obj);
                dataObj.push(obj);

            } else if (docTypeName == 'NOC' && this.isNOC == true) {
                let hologramNO = this.template.querySelector('[data-id="hologramNO"]');
                let nocRef = this.template.querySelector('[data-id="nocRef"]');
                let hasNocCanel = this.template.querySelector('[data-id="hasNocCanel"]');
                console.log('OUTPUT : ', hasNocCanel.value);
                if (hasNocCanel.value != 'Yes') {
                    console.log('in if : ', );
                    hasNocCanel.setCustomValidity('Please Select Yes for "Has NOC Been Canceled?"')
                } else {
                    console.log('in else : ', );
                    hasNocCanel.setCustomValidity('');
                }
                hologramNO.reportValidity();
                hasNocCanel.reportValidity();
                if (hologramNO.validity.valid === true  && hasNocCanel.validity.valid) {
                    isAllValid.push(true);
                    let obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Hologram_no_as_per_NOC__c': hologramNO.value,
                        'NOC_ref_no_as_per_journey__c': nocRef.value,
                        'Has_NOC_been_canceled__c': hasNocCanel.value,
                    }
                    dataObj.push(obj);
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'Branch Undertaking letter') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            } else if (docTypeName == 'Declaration of Borrower Good Health') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            } else if (docTypeName == 'Declaration of Co-Borrower Good Health') {
                let obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                dataObj.push(obj);
            }

        });
        console.log('isAllValid : ', isAllValid);
        const result = isAllValid.every(element => {
            if (element === isAllValid[0] && element == true) {
                return true;
            }
        });
        console.log('OUTPUT result **: ', result);
        console.log('isNocUploaded **: ', isNocUploaded);
        console.log('isBorrowerUploaded : ', isBorrowerUploaded);
        console.log('dataObj : ',dataObj);
        console.log('allDocTypeChecked : ',allDocTypeChecked);
        if (result == true && isNocUploaded == true && isBorrowerUploaded == true || (this.isD2C && this.isBorrowerDeclare == true) && isAllDocumentUploaded == true) {//CISP-7005
            updateAdditionalDocument({ loanApplicationId: this.recordId, data: JSON.stringify(dataObj) ,submitFlag: subFlag,activeDocList: JSON.stringify(allDocTypeChecked), dealId: this.dealId})//CISP-2432
                .then(result => {
                    console.log('Result11111111111', result);
                    if(subFlag == true){
                        this.isReadOnly = true;
                        this.coBorrowerReadOnly = true;
                        this.isBorrowerMandetory = true;
                        this.isNOCMandatory = true;
                        this.isCoBorrowerMandetory = true;
                        this.isNotPreDisbursement = true;
                        this.stageCheck = false;   
                        this.isCheckBoxSectionOpen = true;
                        this.isadditionDocSectionOpen = true;
                    }
                    this.isSubmitDisabled = true;
                    if(count==0){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Submit successfully without providing any additional documents',
                                variant: 'success',
                            }),
                        );
                        eval("$A.get('e.force:refreshView').fire();");
                    }
                    else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Documents successfully uploaded.',
                            variant: 'success',
                        }),
                    );
                    eval("$A.get('e.force:refreshView').fire();");
                }

                })
                .catch(error => {
                    this.isReadOnly = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error,
                            variant: 'error',
                        }),
                    );
                });
                isSuccess = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Documents and Informationneeds to be captured for the sections those have been selected',
                    variant: 'error',
                }),
            );
        }
        if(subFlag == false){
        const actionResultEvent = new CustomEvent("submitresultaction", {
            detail: {isSuccess: isSuccess}
          });
      
          // Dispatches the event.
          this.dispatchEvent(actionResultEvent);
        }
    }
    @track docTypeListId = []
    @track docTypeListAll = [];
    //fetching document typelist
    fetchRelatedDocument() {
        fetchRelatedDocument({ lAId: this.recordId, dealId: this.dealId }).then(data => {
            if (data) {
                console.log('OUTPUTfetchRelatedDocument: ',data);
                this.docTypeListAll = JSON.parse(data);
                console.log(this.docTypeListAll)
                for(var i in this.docTypeListAll){
                    this.docTypeList.push(this.docTypeListAll[i]['Document_Type__c'])
                    this.docTypeListId.push(this.docTypeListAll[i]['Id'])
                    this.documentIdWithTypeList.push(this.docTypeListAll[i]['Id'] + ' ' + this.docTypeListAll[i]['Document_Type__c']); //INDI-4645
                }
                console.log('OUTPUT this.documentIdWithTypeList ****: ',this.documentIdWithTypeList);//INDI-4645
                this.retreiveDocumentTypeCheck();
            } else {
                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: '',variant: 'error',}),);
            }
        })
    }
    @track optionsEnteredDetailsAsPerDocRC
    @track optionsIsRCDocLegible
    @track optionsIsSaleLegibleDD
    @track optionsIsRCDocLegible
    @track optionsIsSellerEnteredDetailsUploaded
    @track optionsIsSellerBankStatementLegible
    @track optionsisSellerCanCheq
    @track optionsIsSellerCanCheqLegible

    @track optionsBorrowerPassbookUploaded
    @track optionsIsBorrowerPassbookLegible
    @track optionsIsBorrowerEnteredDetailsUploaded
    @track optionsIsBorrowerBankStatementLegible
    @track optionsisBorrowerCanCheq
    @track optionsIsBorrowerCanCheqLegible

    @track optionsCoBorrowerPassbookUploaded
    @track optionsIsCoBorrowerPassbookLegible
    @track optionsIsCoBorrowerEnteredDetailsUploaded
    @track optionsIsCoBorrowerBankStatementLegible
    @track optionsisCoBorrowerCanCheq
    @track optionsIsCoBorrowerCanCheqLegible

    @track optionsIsBuyerSellerUndertakingLetterLegible
    @track optionsIsIndemnityLetterLegible
    @track optionsIsTaxInvoiceDcoUploaded
    @track optionsIsSaleAgreementLegible
    @track optionsIsTaxInvoiceLegible
    @track optionsIsPaymentLegible
    @track optionsIsPaymentReceiptDocUploaded
    @track optionsIsNOCDetailsDocUpload
    @track optionsIsCancelNOCLegible
    @track optionsIsBranchUndertakLetterLegible
    @track optionsIsDecGoodBorrowerLegible
    @track optionsIsDecGoodCoBorrower
    @track docTypeList = []
    
    async retreiveDocumentTypeCheck() {
        for (var i in this.docTypeList) {
            if (this.docTypeList[i] === 'RC Document') {
                this.isRCVisible = true;
                this.optionsEnteredDetailsAsPerDocRC = await fetchPicklistValue({fieldName: 'Are_enter_details_as_per_RC_doc_upload__c'});
                this.optionsIsRCDocLegible = await fetchPicklistValue({fieldName: 'Are_entered_details_as_per_document_uplo__c'});
            }if (this.docTypeList[i] === 'DD for closing existing loan') {
                this.isBankTransfer = true;
                this.optionsIsSaleLegibleDD = await fetchPicklistValue({fieldName: 'Is_sale_DD_legible__c'});
                this.isDDforClosing = true;
            }if (this.docTypeList[i] === 'Foreclosure letter for closed existing loan') {
                this.optionsIsForeclosureLetterLegible = await fetchPicklistValue({fieldName: 'Is_sale_Foreclosure_Letter_legible__c'});
                this.isBankTransfer = true;
                this.isForeClosure = true;
            }if (this.docTypeList[i] === 'Seller\'s Passbook') {
                this.optionsSellerPassbookUploaded = await fetchPicklistValue({fieldName: 'entered_details_asper_passbook_upload__c'});
                this.optionsIsSellerPassbookLegible = await fetchPicklistValue({fieldName: 'Is_passbook_legible_for_Seller__c'});
                this.isSellerPassbook = true;
                this.isSeller1 = true;
                if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
                    this.isSeller = true;
                } else {
                    this.isSeller = false;
                }
            }if (this.docTypeList[i] === 'Seller\'s Bank Statement') {
                this.optionsIsSellerEnteredDetailsUploaded = await fetchPicklistValue({fieldName: 'enter_details_asper_bank_STMT_upload__c'});
                this.optionsIsSellerBankStatementLegible = await fetchPicklistValue({fieldName: 'Is_bank_statement_legible_for_Seller__c'});
                this.issellerBankState = true;
                this.isSeller2 = true;
                if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
                    this.isSeller = true;
                } else {
                    this.isSeller = false;
                }
            }if (this.docTypeList[i] === 'Seller\'s Cancel Cheque') {
                this.optionsisSellerCanCheq = await fetchPicklistValue({fieldName: 'enter_details_as_per_canc_chq_upload__c'});
                this.optionsIsSellerCanCheqLegible = await fetchPicklistValue({fieldName: 'Is_cancelled_cheque_legible_for_Seller__c'});
                this.issellerChqCancel = true;
                this.isSeller3 = true;;
                if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
                    this.isSeller = true;
                } else {
                    this.isSeller = false;
                }
            }if (this.docTypeList[i] === 'Borrower\'s Passbook') {
                this.optionsBorrowerPassbookUploaded = await fetchPicklistValue({fieldName: 'enter_DETLS_asper_BWR_passbook_upload__c'});
                this.optionsIsBorrowerPassbookLegible = await fetchPicklistValue({fieldName: 'Is_passbook_legible_for_Borrower__c'});
                this.isBorrower3 = true;
                this.isborrowPassbook = true;
                if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
                    this.isBorrower = true;
                } else {
                    this.isBorrower = false;
                }
            }if (this.docTypeList[i] === 'Borrower\'s Bank Statement') {
                this.optionsIsBorrowerEnteredDetailsUploaded = await fetchPicklistValue({fieldName: 'enter_DETLS_asper_BWR_bank_STMT_upload__c'});
                this.optionsIsBorrowerBankStatementLegible = await fetchPicklistValue({fieldName: 'Is_bank_statement_legible_for_Borrower__c'});
                this.isBorrower2 = true;
                this.isborrowerBankState = true;
                if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
                    this.isBorrower = true;
                } else {
                    this.isBorrower = false;
                }
            }if (this.docTypeList[i] === 'Borrower\'s Cancel Cheque') {
                this.optionsisBorrowerCanCheq = await fetchPicklistValue({fieldName: 'enter_DETLS_as_per_BWR_canc_chq_upload__c'});
                this.optionsIsBorrowerCanCheqLegible = await fetchPicklistValue({fieldName: 'Is_cancelled_cheque_legible_for_Borrower__c'});
                this.isBorrower1 = true;
                this.isborrowercancelCheq = true;
                if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
                    this.isBorrower = true;
                } else {
                    this.isBorrower = false;
                }
            }if (this.docTypeList[i] === 'Co-Borrower\'s Passbook') {
                this.optionsCoBorrowerPassbookUploaded = await fetchPicklistValue({fieldName: 'enter_DETLS_asper_COBWR_pasbook_upload__c'});
                this.optionsIsCoBorrowerPassbookLegible = await fetchPicklistValue({fieldName: 'Is_passbook_legible_for_CoBorrower__c'});
                this.isCoBorrower1 = true;
                this.isCoborrowPassbook = true;
                if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
                    this.isCoBorrower = true;
                } else {
                    this.isCoBorrower = false;
                }
            }if (this.docTypeList[i] === 'Co-Borrower\'s Bank Statement') {
                this.optionsIsCoBorrowerEnteredDetailsUploaded = await fetchPicklistValue({fieldName: 'DETLS_asper_COBWR_bank_STMT_upload__c'});
                this.optionsIsCoBorrowerBankStatementLegible = await fetchPicklistValue({fieldName: 'Is_bank_statement_legible_for_CoBorrowe__c'});
                this.isCoBorrower2 = true;
                this.isCoborrowerBankState = true;
                if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
                    this.isCoBorrower = true;
                } else {
                    this.isCoBorrower = false;
                }
            }if (this.docTypeList[i] === 'Co-Borrower\'s Cancel Cheque') {
                this.optionsisCoBorrowerCanCheq = await fetchPicklistValue({fieldName: 'DETLS_asper_COBWR_canc_chq_upload__c'});
                this.optionsIsCoBorrowerCanCheqLegible = await fetchPicklistValue({fieldName: 'Is_cancelled_cheque_legible_CoBorrower__c'});
                this.isCoBorrower3 = true;
                this.isCoborrowercancelCheq = true;
                if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
                    this.isCoBorrower = true;
                } else {
                    this.isCoBorrower = false;
                }
            }if (this.docTypeList[i] === 'Buyer-Seller Undertaking letter') {
                this.optionsIsBuyerSellerUndertakingLetterLegible = await fetchPicklistValue({fieldName: 'Buyer_Seller_Undertaking_Letter_legib__c'});
                this.isBuyerSeller = true;
            }if (this.docTypeList[i] === 'Indemnity letter') {
                this.optionsIsIndemnityLetterLegible = await fetchPicklistValue({fieldName: 'Buy_Seller_Indemnity_LTR_legible__c'});
                this.isIndemnityLetter = true;
            }if (this.docTypeList[i] === 'Sale Agreement') {
                this.optionsIsSaleAgreementLegible = await fetchPicklistValue({fieldName: 'Is_Sale_Agreement_legible__c'});
                this.isSaleAgreement = true;
            }if (this.docTypeList[i] === 'Tax Invoice') {
                console.log('in tax invoice : ',);
                this.optionsIsTaxInvoiceDcoUploaded = await fetchPicklistValue({fieldName: 'enter_details_asper_Tax_Invoice_upload__c'});
                this.optionsIsTaxInvoiceLegible = await fetchPicklistValue({fieldName: 'Is_Tax_Invoice_legible__c'});
                this.isTaxInvoice = true;
                console.log('in tax invoice : ',this.optionsIsTaxInvoiceDcoUploaded);
                console.log('in tax invoice : ',this.optionsIsTaxInvoiceLegible);
            }if (this.docTypeList[i] === 'Payment Receipt') {
                this.isPaymentReceipts = true;
                this.optionsIsPaymentReceiptDocUploaded = await fetchPicklistValue({fieldName: 'enter_DETLS_asper_Payment_doc_upload__c'});
                this.optionsIsPaymentLegible = await fetchPicklistValue({fieldName: 'Is_Payment_Receipt_legible__c'});
            }if (this.docTypeList[i] === 'NOC') {
                this.optionsIsNOCDetailsDocUpload = await fetchPicklistValue({fieldName: 'Are_enter_details_asper_NOC_doc_upload__c'});
                this.optionsIsCancelNOCLegible = await fetchPicklistValue({fieldName: 'Is_Cancelled_NOC_legible__c'});
                this.isNOC = true;
            }if (this.docTypeList[i] === 'Branch Undertaking letter') {
                this.optionsIsBranchUndertakLetterLegible = await fetchPicklistValue({fieldName: 'Is_Branch_Undertaking_Letter_legible__c'});
                this.isBranchUndertake = true;
            }if (this.docTypeList[i] === 'Declaration of Borrower Good Health') {
                this.optionsIsDecGoodBorrowerLegible = await fetchPicklistValue({fieldName: 'Doc_for_Good_Health_borrower_legible__c'});
                this.isBorrowerDeclare = true;
            }if (this.docTypeList[i] === 'Declaration of Co-Borrower Good Health') {
                this.optionsIsDecGoodCoBorrower = await fetchPicklistValue({fieldName: 'Doc_for_Good_Health_coborrower_legible__c'});
                this.isCoBorrowerDeclare = true;
            }
        }
        this.isLoadingSpinner = false;
    }
    async handlePreview(event){
        let contentDocId ;
        let docType;
        if(event.target.name === 'previewRC'){
            docType = 'RC Document';
        }if(event.target.name === 'previewDDClosingLoan'){
            docType = 'DD for closing existing loan';
        }if(event.target.name === 'previewForeClosure'){
            docType = 'Foreclosure letter for closed existing loan';
        }if(event.target.name === 'previewSellerPassBook'){
            docType = 'Seller\'s Passbook';
        }if(event.target.name === 'previewSellerBankStatement'){
            docType = 'Seller\'s Bank Statement';
        }if(event.target.name === 'previewSellerCanCheq'){
            docType = 'Seller\'s Cancel Cheque';
        }if(event.target.name === 'previewBorrowerPassBook'){
            docType = 'Borrower\'s Passbook';
        }if(event.target.name === 'previewBorrowerBankStatement'){
            docType = 'Borrower\'s Bank Statement';
        }if(event.target.name === 'previewBorrowerCanCheq'){
            docType = 'Borrower\'s Cancel Cheque';
        }if(event.target.name === 'previewCoBorrowerPassBook'){
            docType = 'Co-Borrower\'s Passbook';
        }if(event.target.name === 'previewCoBorrowerBankStatement'){
            docType = 'Co-Borrower\'s Bank Statement';
        }if(event.target.name === 'previewCoBorrowerCanCheq'){
            docType = 'Co-Borrower\'s Cancel Cheque';
        }if(event.target.name === 'previewBuyerSellerUnderTaking'){
            docType = 'Buyer-Seller Undertaking letter';
        }if(event.target.name === 'previewIndeminityLetter'){
            docType = 'Indemnity letter';
        }if(event.target.name === 'previewSaleAgreement'){
            docType = 'Sale Agreement';
        }if(event.target.name === 'previewTaxInvoice'){
            docType = 'Tax Invoice';
        }if(event.target.name === 'previewNOC'){
            docType = 'NOC';
        }if(event.target.name === 'previewBranchUndertaking'){
            docType = 'Branch Undertaking letter';
        }if(event.target.name === 'previewHealthBorrower'){
            docType = 'Declaration of Borrower Good Health';
        }if(event.target.name === 'previewHealthCoBorrower'){
            docType = 'Declaration of Co-Borrower Good Health';
        }if(event.target.name === 'previewPaymentRecipt'){
            docType = 'Payment Receipt';
        }
        let contentDocIdMetaData = await fetchContentDocument({lAId : this.recordId, docType : docType, dealId: this.dealId });
        if(contentDocIdMetaData){
            contentDocId = contentDocIdMetaData['ContentDocumentId'];
            if(this.isCommunityUser == true){
                getContentVersion({ conDocId: contentDocId })
                  .then(result => {
                    console.log('Result when addition doc other documents', result);
                    this.fileType = result[0].FileType;
                    if(result!=null){
                        this.previewFile(result[0].Id,this.fileType);
                    }
                  })
                  .catch(error => {
                    console.error('Error:', error);
                });
            }else{
            this.previewFile(contentDocId,this.fileType);
            }
        }else{
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'No File to Preview',variant: 'error',}),);
        }
    }
}