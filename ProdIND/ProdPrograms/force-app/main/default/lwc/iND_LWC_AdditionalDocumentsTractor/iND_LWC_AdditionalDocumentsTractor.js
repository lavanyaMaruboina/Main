import { LightningElement, api, track } from 'lwc';
import getInsuranceDetails from '@salesforce/apex/AdditionalDocumentsClass.getInsuranceDetails'
import getLoanApplicationCategory from '@salesforce/apex/AdditionalDocumentsClass.getLoanApplicationCategory';
import fetchRelatedDocument from '@salesforce/apex/AdditionalDocumentsClass.fetchRelatedDocument';
import fetchAdditionalDocuments from '@salesforce/apex/AdditionalDocumentsClass.fetchAdditionalDocuments';
import fetchContentDocument from '@salesforce/apex/AdditionalDocumentsClass.fetchContentDocument';
import postSavedDataOnSubmit from '@salesforce/apex/AdditionalDocumentsClass.postSavedDataOnSubmit';
import getApplicantData from '@salesforce/apex/AdditionalDocumentsClass.getApplicantData';
import createDocumentForAdditionalDocument from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForAdditionalDocument';
import updateAdditionalDocument from '@salesforce/apex/AdditionalDocumentsClass.updateAdditionalDocument';
import getAdditionalData from '@salesforce/apex/AdditionalDocumentsClass.getAdditionalData';
import getBankName from '@salesforce/apex/AdditionalDocumentsClass.getBankName';
import { NavigationMixin } from 'lightning/navigation';
import ACCOUNT_FORMAT_ERROR from "@salesforce/label/c.AccountFormatError";
import getContentVersion from '@salesforce/apex/SecurityMandate.getContentVersion'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkIfReadOnly from '@salesforce/apex/AdditionalDocumentsClass.checkIfReadOnly';
import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';
import deleteDocRecord from '@salesforce/apex/AdditionalDocumentsClass.deleteDocRecord';
import FORM_FACTOR from '@salesforce/client/formFactor';
import IntegratorAppURL from '@salesforce/label/c.IntegratorAppURL';
import getUserDetails from '@salesforce/apex/IND_DocumentUploadCntrl.getUserDetails';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';

export default class IND_LWC_AddtionalDocuments extends NavigationMixin(LightningElement) {
    @api dealId ;communityPartnersURL = IBL_Community_Partners_URL;isCheckBoxSectionOpen = false;fileType;isCommunityUser;@api currentStep;isBEVisible;aaplicantIdBorrower;aaplicantIdCoBorrower;applicantRecords;@api isSubmitDisabled = false;isAddPayment = false;@track paymentList = [];keyIndex = 0;docType;uploadAdditionalDocFlag;isAllDocType;showUpload;showPhotoCopy;showDocView;isVehicleDoc;uploadViewDocFlag;isHypothecationValue;isRCVisible;isSellerPassbook;issellerBankState;issellerChqCancel;isSeller;isBankTransfer;isDDforClosing;isBorrowerDeclare = false;isCoBorrowerDeclare;isBranchUndertake;isNOC;isPaymentReceipts;isTaxInvoice;isBuyerSeller;isIndemnityLetter;isBorrower;isborrowercancelCheq;isborrowerBankState;isCoBorrower;isCoborrowercancelCheq;isCoborrowerBankState;@api recordId;fieldLabel;documentRecordId;applicantid;vehiclerecordid;ContentDocumentId;hypothecationName;documentIdWithType;documentIdWithTypeList = [];coBorrowerHealthData =[];borrowerHealthData =[];branchUndertakingData =[];bankersSignatureData = [];insuranceCoverNoteData = [];insurancePolicyData = [];deliveryChallanData = [];paymentToCoborrowerDealerData = [];existingLoanSettlementData = [];affidavitData = [];enachData = [];DebitAuthData = [];DSALetterData = [];DealerLetterData = [];TalathiSarpanchData = [];vahanData = [];FundUtilisationData = [];indexRow = 0;isPreview = false;converId;height = 32;@track taxInvoice = [];@track indemnityLetterData =[];@track buyerSellerData=[];@track rcDoumentData = [];@track bankTransfer = [];@track sellerData = [];@track sellerData1 = [];@track sellerData2 = [];@track borrowerData = [];@track borrowerData1 = [];@track borrowerData2 = [];@track borrowerCancelCheque =[];@track coBorrowerData = [];@track coBorrowerData1 = [];@track coBorrowerData2 = [];@track nocData = [];nocNumberOfLA;isPaymentDataAlready = 0;applicantType;isReadOnly;isadditionDocSectionOpen = false;@track coBorrowerReadOnly = false;isSeller1;isSeller2;isSeller3;isBorrower1;isBorrower2;isBorrower3;isCoBorrower1;isCoBorrower2;isCoBorrower3;leadId;mobileTabApp;documentSide = 'Front';BankerSignatureVerificationVal = false;MarginMoneyReceiptVal = false;InsuranceCoverNoteVal = false;InsurancePolicyVal = false;DeliveryChallanVal = false;PaymentToCoBorrowerDealerDSAVal = false;ExistingLoanSettlementVal = false;AffidavitVal = false;EnachVal = false;DebitAuthorisationVal = false;DSALetterVal = false;SDPCACHFormVal = false;TalathiSarpanchCertificateVal = false;VahanExtractVal = false;FundUtilisationVal = false;

    get optionsYesOrNo() {return [{ label: 'Yes', value: 'Yes' },{ label: 'No', value: 'No' },];}
    get isD2CDisabled(){return this.isReadOnly || this.isD2C;}
    get isNOCDisabled(){return this.isNOCMandatory || this.isD2C;}
    get isBorrowerDisabled(){return this.isBorrowerMandetory || this.isD2C;}
    get disableCaptureChassisNumberWithD2C(){return this.disableCaptureChassisNumber || this.isD2C;}
    label = {currentUserId,currentUserName,currentUserEmailid,currentApplicantid,mode}
    handleOnChange(event) {
        let name = event.target.name;
        let value = event.target.checked;
        if(!value){this.uncheckedRec.push(name);}
        switch (name) {
            case 'Banker\'s signature verification':
                this.BankerSignatureVerificationVal = value; break;
            case 'Margin money receipt':
                this.MarginMoneyReceiptVal = value; break;
            case 'Insurance Cover Note':
                this.InsuranceCoverNoteVal = value; break;
            case 'Insurance Policy Doc':
                this.InsurancePolicyVal = value; break;
            case 'Delivery challan':
                this.DeliveryChallanVal = value; break;
            case 'Customer declaration letter for payment to Co-borrower/Dealer/ DSA':
                this.PaymentToCoBorrowerDealerDSAVal = value; break;
            case 'Existing loan settlement copy for refinance':
                this.ExistingLoanSettlementVal = value; break;
            case 'Affidavit':
                this.AffidavitVal = value; break;
            case 'Enach':
                this.EnachVal = value; break;
            case 'Debit Authorisation letter for closing existing loan':
                this.DebitAuthorisationVal = value; break;
            case 'DSA letter':
                this.DSALetterVal = value; break;
            case 'Dealer letter':
                this.DealerLetterVal = value; break;
            case 'SDPC / ACH Form':
                this.SDPCACHFormVal = value; break;
            case 'Talathi/Sarpanch Certificate':
                this.TalathiSarpanchCertificateVal = value; break;
            case 'Vahan Extract':
                this.VahanExtractVal = value; break;
            case 'Fund Utilisation letter for Refinance':
                this.FundUtilisationVal = value; break;
            
            default:
                break;
        }
    }
    @track isTractor = false;@track stageCheck = false;@track isLoadingSpinner = false;@track isNotPreDisbursement  =false;bankNameList = [];@track isD2C = false;@track disableCaptureChassisNumber = false;disabledFields = false;isBorrowerMandetory = false;isCoBorrowerMandetory = false;isNOCMandatory = false; noDocSelected=false;uncheckedRec = [];
    checkPostSanctionSubmit(){
        checkIfReadOnly({ lAId: this.recordId, dealId: this.dealId }).then(result => {
            this.isReadOnly = result;
            if(this.isReadOnly == true){this.coBorrowerReadOnly = true;this.isBorrowerMandetory = true;this.isCoBorrowerMandetory = true;this.isNOCMandatory = true;this.isNotPreDisbursement = true;this.stageCheck = false;}else{this.stageCheck = true;}this.fetchRelatedDocument();this.isCheckBoxSectionOpen = true;this.isadditionDocSectionOpen = true;
        }).catch(error => {});
    }
    @api isRevokedLoanApplication;
    async connectedCallback() {
        this.isSubmitDisabled = true;
        this.paymentList = [];
        let optionList = new Array();
        optionList.push({ label: 'IBL', value: 'IBL' });
        optionList.push({ label: 'Others', value: 'Others' });
        this.hypothecationName = optionList;
        if (FORM_FACTOR != 'Large') {
            this.mobileTabApp = true;
        } else {
            this.mobileTabApp = false;
        }

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
                this.isTractor = result.loanApplication.Product_Type__c == 'Tractor';
                this.isD2C = result.loanApplication.LeadSource === 'D2C';
                this.loanstage = result.loanApplication.StageName;
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
        if(this.aaplicantIdCoBorrower == '' || this.aaplicantIdCoBorrower == null || this.aaplicantIdCoBorrower == undefined){
            this.coBorrowerReadOnly = true;
            this.isCoBorrowerMandetory = true;
        } 
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
                        this.taxInvoice = element;
                        if((this.taxInvoice.enter_details_asper_Tax_Invoice_upload__c == 'No' || this.taxInvoice.Is_Tax_Invoice_legible__c =='No')){
                            console.log('tax invoice No : ',);
                            this.isTaxInvoice = true;
                        }

                    } else if (element.Document_Type__c == 'RC Document') {
                        this.rcDoumentData = element;
                        if((this.rcDoumentData.Are_enter_details_as_per_RC_doc_upload__c == 'No' || this.rcDoumentData.Are_entered_details_as_per_document_uplo__c == 'No')){
                            this.isRCVisible = true;
                        }

                    }else if (element.Document_Type__c == 'DD for closing existing loan') {
                        this.bankTransfer = element;
                        if(this.bankTransfer.Is_sale_DD_legible__c == 'No'){
                            this.isBankTransfer = true;
                        }
                    } else if (element.Document_Type__c == 'Seller\'s Passbook' ){
                        this.sellerData = element;
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
                    
                    this.buyerSellerData = element;
                    if( this.buyerSellerData.Buyer_Seller_Undertaking_Letter_legib__c == 'No'){
                        this.isBuyerSeller = true;
                    }
                   
                } else if (element.Document_Type__c == 'Indemnity letter') {
                    this.indemnityLetterData = element;  if (this.indemnityLetterData.Buy_Seller_Indemnity_LTR_legible__c == 'No') {this.isIndemnityLetter = true}
                } else if (element.Document_Type__c == 'NOC') {
                    if( (this.nocData.Is_Cancelled_NOC_legible__c == 'No' || this.nocData.Are_enter_details_asper_NOC_doc_upload__c == 'No')){this.isNOC = true;
                    }else if( (this.nocData.Is_Cancelled_NOC_legible__c == 'Yes' && this.nocData.Are_enter_details_asper_NOC_doc_upload__c == 'Yes')){this.isNOC = false;} 
                } else if (element.Document_Type__c == 'Branch Undertaking letter') {
                    this.branchUndertakingData = element; if (this.branchUndertakingData.Is_Branch_Undertaking_Letter_legible__c == 'No') {this.isBranchUndertake = true;}
                }else if (element.Document_Type__c == 'Declaration of Borrower Good Health') {
                    this.borrowerHealthData = element; if (this.borrowerHealthData.Doc_for_Good_Health_borrower_legible__c == 'No') {this.isBorrowerDeclare = true;}
                }else if (element.Document_Type__c == 'Declaration of Co-Borrower Good Health') {
                    this.coBorrowerHealthData = element; if (this.coBorrowerHealthData.Doc_for_Good_Health_coborrower_legible__c == 'No') {this.isCoBorrowerDeclare = true;} 
                } else if (element.Document_Type__c == 'Banker\'s signature verification') {
                    this.bankersSignatureData = element; if (this.bankersSignatureData.Is_Signature_verification_legible__c == 'No') {this.BankerSignatureVerificationVal = true;}
                } else if (element.Document_Type__c == 'Insurance Cover Note') {
                    this.insuranceCoverNoteData = element; if (this.insuranceCoverNoteData.Is_Insurance_cover_note_legible__c == 'No') {this.InsuranceCoverNoteVal = true;}
                } else if (element.Document_Type__c == 'Insurance Policy Doc') {
                    this.insurancePolicyData = element; if (this.insurancePolicyData.Doc_for_Good_Health_coborrower_legible__c == 'No') {this.InsurancePolicyVal = true;}
                } else if (element.Document_Type__c == 'Delivery challan') {
                    this.deliveryChallanData = element; if (this.deliveryChallanData.Is_Delivery_Challan_legible__c == 'No') {this.DeliveryChallanVal = true;}
                }  else if (element.Document_Type__c == 'Customer declaration letter for payment to Co-borrower/Dealer/ DSA') {
                    this.paymentToCoborrowerDealerData = element;if (this.paymentToCoborrowerDealerData.Is_customer_declaration_letter_legible__c == 'No') {this.PaymentToCoBorrowerDealerDSAVal = true;}
                }  else if (element.Document_Type__c == 'Existing loan settlement copy for refinance') {
                    this.existingLoanSettlementData = element;if (this.existingLoanSettlementData.Is_Delivery_Challan_legible__c == 'No') {this.ExistingLoanSettlementVal = true;}
                }  else if (element.Document_Type__c == 'Affidavit') {
                    this.affidavitData = element;if (this.affidavitData.Is_Affidavit_legible__c == 'No') {this.AffidavitVal = true;}
                }  else if (element.Document_Type__c == 'Enach') {
                    this.enachData = element;if (this.enachData.Is_ENACH_Form_legible__c == 'No') {this.EnachVal = true;}
                } else if (element.Document_Type__c == 'Debit Authorisation') {
                    this.DebitAuthData = element;if (this.DebitAuthData.Is_Debit_Authorisation_letter_legible__c == 'No') {this.DebitAuthorisationVal = true;}
                } else if (element.Document_Type__c == 'DSA letter') {
                    this.DealerLetterData = element;if (this.DealerLetterData.Is_DSA_Letter_legible__c == 'No') {this.DSALetterVal = true;}
                } else if (element.Document_Type__c == 'Dealer Letter') {
                    this.DealerLetterData = element; if (this.DealerLetterData.Is_Dealer_Letter_legible__c == 'No') {this.DealerLetterVal = true;}
                } else if (element.Document_Type__c == 'SDPC / ACH Form') {
                } else if (element.Document_Type__c == 'Talathi/Sarpanch Certificate') {
                    this.TalathiSarpanchData = element; if (this.TalathiSarpanchData.Is_Talathi_Sarpanch_certificate_legible__c == 'No') {this.TalathiSarpanchCertificateVal = true;}
                } else if (element.Document_Type__c == 'Vahan Extract') {
                    this.vahanData = element; if (this.vahanData.Is_Vahan_legible__c == 'No') {this.VahanExtractVal = true;}
                }  else if (element.Document_Type__c == 'Fund Utilisation letter for Refinance') {
                    this.FundUtilisationData = element; if (this.FundUtilisationData.Is_Talathi_Sarpanch_certificate_legible__c == 'No') {this.FundUtilisationVal = true;}
                }   
                });
                if(!this.isRCVisible && !this.isBankTransfer && !this.isSeller && !this.isBorrower && !this.isCoBorrower && !this.isBuyerSeller && !this.isIndemnityLetter 
                    && !this.isTaxInvoice && !this.isNOC && !this.isBranchUndertake && !this.isBorrowerDeclare && !this.isCoBorrowerDeclare){
                    this.noDocSelected = true;
                                if(this.isCheckBoxSectionOpen===false){
                                    this.isBEVisible=false;
                                }
                }
            }
            else{
                        this.noDocSelected = true;
                        if(this.isCheckBoxSectionOpen===false){
                            this.isBEVisible=false;
                        }
            }
        
        })
        .catch(error => {
            console.error('Error:', error);
        });
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    handleInputFieldChange(event) {
        this.isSubmitDisabled = false;
        switch (event.detail.name) {
            case 'hypothecationNameRc':
                this.rcDoumentData.Hypothecation_in_name_of__c = event.detail.value; break;
            case 'RCOwner':
                this.rcDoumentData.RC_Owner__c = event.detail.value; break;
            case 'enteredDetailsAsPerDocRC':
                this.rcDoumentData.Are_enter_details_as_per_RC_doc_upload__c = event.detail.value; break;
            case 'isRCDocLegible':
                this.rcDoumentData.Are_entered_details_as_per_document_uplo__c = event.detail.value; break;        
            case 'remarksRCDoc':
                this.rcDoumentData.Remarks_for_RC_Upload__c = event.detail.value; break; 
            case 'coBorrowerBankName':
                this.coBorrowerData.DETLS_asper_COBWR_bank_STMT_upload__c = event.detail.value; break;
            case 'coBorrowerAccountNumber':
                this.coBorrowerData.CoBorrower_Account_number__c = event.detail.value; break;
            case 'coBorrowerAccountHolder':
                this.coBorrowerData.Name_of_CoBorrower_account_holder__c = event.detail.value; break;
            case 'ifscCodeCoBorrower':
                this.coBorrowerData.IFSC_code_CoBorrower__c = event.detail.value; break;        
            case 'isCoBorrowerEnteredDetailsUploaded':
                this.coBorrowerData1.DETLS_asper_COBWR_bank_STMT_upload__c = event.detail.value; break;  
            case 'isCoBorrowerBankStatementLegible':
                this.coBorrowerData1.Is_bank_statement_legible_for_CoBorrowe__c = event.detail.value; break;  
            case 'coBorrowerBankStatementRemarks':
                this.coBorrowerData1.Bank_Statement_Remarks_for_CoBorrower__c = event.detail.value; break;
            case 'isCoBorrowerCanCheq':
                this.coBorrowerData2.DETLS_asper_COBWR_canc_chq_upload__c = event.detail.value; break;  
            case 'isCoBorrowerCanCheqLegible':
                this.oBorrowerData2.Is_cancelled_cheque_legible_CoBorrower__c = event.detail.value; break;                        
            case 'coBorrowerCanCheqRemarks':
                this.coBorrowerData2.Cancelled_cheque_Remarks_for_CoBorrower__c = event.detail.value; break;  
            case 'isSaleLegibleDD':
                this.bankTransfer.Is_sale_DD_legible__c = event.detail.value; break;
            case 'remarksSaleLegibleDD':
                this.bankTransfer.Remarks_for_DD__c = event.detail.value; break;  
            case 'Buyer-SellerUndertakingletter':
                this.buyerSellerData.Buyer_Seller_Undertaking_Letter_legib__c = event.detail.value; break;                        
            case 'buyerSellerUndertakingLetterRemarks':
                this.buyerSellerData.Buyer_Seller_Undertaking_Letter_Remarks__c = event.detail.value; break;  
            case 'IsIndemnityLetterLegible':
                this.indemnityLetterData.Buy_Seller_Indemnity_LTR_legible__c = event.detail.value; break;
            case 'indemnityLetterRemarks':
                this.indemnityLetterData.Indemnity_Remarks__c = event.detail.value; break;  
            case 'sellerBankName':
                this.sellerData.Seller_Bank_name__c = event.detail.value; break;                        
            case 'sellerAccountNumber':
                this.sellerData.Seller_Account_number__c = event.detail.value; break;  
            case 'sellerAccountHolder':
                this.sellerData.Name_of_Seller_account_holder__c = event.detail.value; break;
            case 'ifscCodeSeller':
                this.sellerData.IFSC_code_Seller__c = event.detail.value; break;  
            case 'isSellerPassbookUploaded':
                this.sellerData.entered_details_asper_passbook_upload__c = event.detail.value; break;                        
            case 'isSellerPassbookLegible':
                this.sellerData.Is_passbook_legible_for_Seller__c = event.detail.value; break;  
            case 'sellerPassbookRemarks':
                this.sellerData.Passbook_Remarks_for_Seller__c = event.detail.value; break;                        
            case 'isSellerEnteredDetailsUploaded':
                this.sellerData1.enter_details_asper_bank_STMT_upload__c = event.detail.value; break;  
            case 'isSellerBankStatementLegible':
                this.sellerData1.Is_bank_statement_legible_for_Seller__c = event.detail.value; break;
            case 'sellerBankStatementRemarks':
                this.sellerData1.Bank_Statement_Remarks_for_Seller__c = event.detail.value; break;  
            case 'isSellerCanCheq':
                this.sellerData2.enter_details_as_per_canc_chq_upload__c = event.detail.value; break;                        
            case 'isSellerCanCheqLegible':
                this.sellerData2.Is_cancelled_cheque_legible_for_Seller__c = event.detail.value; break;  
            case 'sellerCanCheqRemarks':
                this.sellerData2.cancelled_cheque_Remarks_for_Seller__c = event.detail.value; break;                        
            case 'hologramAsperNOC':
                this.nocData.Hologram_no_as_per_NOC__c = event.detail.value; break;  
            case 'hasNOcCancel':
                this.nocData.Has_NOC_been_canceled__c = event.detail.value; break;
            case 'isNOCDetailsDocUpload':
                this.nocData.Are_enter_details_asper_NOC_doc_upload__c = event.detail.value; break;  
            case 'isCancelNOCLegible':
                this.nocData.Is_Cancelled_NOC_legible__c = event.detail.value; break;                        
            case 'nOCRemarks':
                this.nocData.NOC_Remarks__c = event.detail.value; break;  
            case 'isBranchUndertakLetterLegible' : 
                this.branchUndertakingData.Is_Branch_Undertaking_Letter_legible__c = event.detail.value; break; 
            case 'branchUndertakRemarks' : 
                this.branchUndertakingData.Branch_Undertaking_Remarks__c = event.detail.value; break; 
            case 'borrowerBankName' : 
                this.borrowerData.Borrower_Bank_name__c = event.detail.value; break; 
            case 'borrowerAccountNumber' : 
                this.borrowerData.Borrower_Account_number__c = event.detail.value; break; 
            case 'borrowerAccountHolder' : 
                this.borrowerData.Name_of_Borrower_account_holder__c = event.detail.value; break; 
            case 'ifscCodeBorrower' : 
                this.borrowerData.IFSC_code_Borrower__c = event.detail.value; break; 
            case 'isBorrowerEnteredDetailsUploaded' : 
                this.borrowerData1.enter_DETLS_asper_BWR_bank_STMT_upload__c = event.detail.value; break; 
            case 'isBorrowerBankStatementLegible' : 
                this.borrowerData1.Is_bank_statement_legible_for_Borrower__c = event.detail.value; break; 
            case 'borrowerBankStatementRemarks' : 
                this.borrowerData1.Bank_Statement_Remarks_for_Borrower__c = event.detail.value; break; 
            case 'isBorrowerCanCheq' : 
                this.borrowerData2.enter_DETLS_as_per_BWR_canc_chq_upload__c = event.detail.value; break; 
            case 'isBorrowerCanCheqLegible' : 
                this.borrowerData2.Is_cancelled_cheque_legible_for_Borrower__c = event.detail.value; break; 
            case 'borrowerCanCheqRemarks' : 
                this.borrowerData2.Cancelled_cheque_Remarks_for_Borrower__c = event.detail.value; break; 
            case 'isDecGoodBorrowerLegible' : 
                this.borrowerHealthData.Doc_for_Good_Health_borrower_legible__c = event.detail.value; break; 
            case 'decGoodBorrowerRemarks' : 
                this.coBorrowerHealthData.Borrower_Good_Health_Dec_Remarks__c = event.detail.value; break; 
            case 'isDecGoodCoBorrower' : 
                this.coBorrowerHealthData.Doc_for_Good_Health_coborrower_legible__c = event.detail.value; break; 
            case 'decGoodCoBorrowerRemarks' : 
                this.coBorrowerHealthData.CoBorrower_Good_Health_Declaration_Remak__c = event.detail.value; break; 
            case 'signatureVerificationBankName' : 
                this.bankersSignatureData.Signature_Verification_Bank_Name__c = event.detail.value; break; 
            case 'SignatureVerificationFor' : 
                this.bankersSignatureData.Signature_verification_for__c = event.detail.value; break; 
            case 'isSignatureTallyWithOtherDocuments' : 
                this.bankersSignatureData.Is_Signature_tally_with_other_documents__c = event.detail.value; break; 
            case 'isSignatureVerificationLegible' : 
                this.bankersSignatureData.Is_Signature_verification_legible__c = event.detail.value; break; 
            case 'signatureRemarks' : 
                this.bankersSignatureData.CoBorrower_Good_Health_Declaration_Remak__c = event.detail.value; break; 
            case 'invoiceNumber' : 
                this.taxInvoice.Invoice_number__c = event.detail.value; break; 
            case 'invoiceDate' : 
                this.taxInvoice.Invoice_date__c = event.detail.value; break; 
            case 'invoiceAmount' : 
                this.taxInvoice.Invoice_amount__c = event.detail.value; break; 
            case 'isTaxInvoiceDcoUploaded' : 
                this.taxInvoice.enter_details_asper_Tax_Invoice_upload__c = event.detail.value; break;
            case 'isTaxInvoiceLegible' : 
                this.taxInvoice.Is_Tax_Invoice_legible__c = event.detail.value; break; 
            case 'insuranceRemarks' : 
                this.taxInvoice.Tax_Invoice_Remarks__c = event.detail.value; break; 
            case 'InsuranceCoverNoteNumber' : 
                this.insuranceCoverNoteData.Insurance_cover_note_number__c = event.detail.value; break; 
            case 'InsuranceCoverNoteDate' : 
                this.insuranceCoverNoteData.Insurance_cover_note_Date__c = event.detail.value; break; 
            case 'InsuranceDeclaredValue' : 
                this.insuranceCoverNoteData.Insurance_declared_value__c = event.detail.value; break; 
            case 'isHypothecationAvaialble' : 
                this.insuranceCoverNoteData.Is_Hypothecation_available__c = event.detail.value; break; 
            case 'EnteredDetailsAsPerDocUploaded' : 
                this.insuranceCoverNoteData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'insuranceCoverNoteLegible' : 
                this.insuranceCoverNoteData.Is_Insurance_cover_note_legible__c = event.detail.value; break; 
            case 'insuranceRemarks' : 
                this.insuranceCoverNoteData.Remarks__c = event.detail.value; break; 
            case 'InsurancePolicyNumber' : 
                this.insurancePolicyData.Insurance_Policy_number__c = event.detail.value; break; 
            case 'InsurancePolicyDate' : 
                this.insurancePolicyData.Insurance_Policy_Date__c = event.detail.value; break; 
            case 'InsuranceDeclaredValue' : 
                this.insurancePolicyData.Insurance_declared_value__c = event.detail.value; break; 
            case 'isHypothecationAvaialble' : 
                this.insurancePolicyData.Is_Hypothecation_available__c = event.detail.value; break; 
            case 'EnteredDetailsAsPerDocUploaded' : 
                this.insurancePolicyData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'insuranceCoverNoteLegible' : 
                this.insurancePolicyData.Is_Insurance_Policy_legible__c = event.detail.value; break; 
            case 'insuranceRemarks' : 
                this.insurancePolicyData.Remarks__c = event.detail.value; break; 
            case 'DeliveryDateOfAsset' : 
                this.deliveryChallanData.Delivery_Date_of_Asset__c = event.detail.value; break; 
            case 'IsCustomerSignatureAvailable' : 
                this.deliveryChallanData.Is_customer_signature_available__c = event.detail.value; break; 
            case 'IsAssetDetailsMatching' : 
                this.deliveryChallanData.Is_Asset_details_matching_with_Invoice__c = event.detail.value; break; 
            case 'isDeliveryChallanLegible' : 
                this.deliveryChallanData.Is_Delivery_Challan_legible__c = event.detail.value; break; 
            case 'insuranceRemarks' : 
                this.deliveryChallanData.Remarks__c = event.detail.value; break; 
            case 'IsCustomerDeclarationLetterLegible' : 
                this.paymentToCoborrowerDealerData.Is_customer_declaration_letter_legible__c = event.detail.value; break; 
            case 'insuranceRemarks' : 
                this.paymentToCoborrowerDealerData.Remarks__c = event.detail.value; break; 
            case 'IsTheSettlementDateCorrect' : 
                this.existingLoanSettlementData.Delivery_Date_of_Asset__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploaded' : 
                this.existingLoanSettlementData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsExistingLoanSettlementCopyLegible' : 
                this.existingLoanSettlementData.Is_Asset_details_matching_with_Invoice__c = event.detail.value; break; 
            case 'ExistingLoanSettlementRemarks' : 
                this.existingLoanSettlementData.Remarks__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploaded' : 
                this.affidavitData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsAffidavitLegible' : 
                this.affidavitData.Is_Affidavit_legible__c = event.detail.value; break; 
            case 'AffidavitRemarks' : 
                this.affidavitData.Remarks__c = event.detail.value; break; 
            case 'isEnachFormCompletelyFilled' : 
                this.enachData.Is_ENACH_form_completely_filled__c = event.detail.value; break; 
            case 'isEnachFormSignedByCustomer' : 
                this.enachData.Is_ENACH_form_signed_by_customer__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploaded' : 
                this.enachData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsEnachFormLegible' : 
                this.enachData.Is_ENACH_Form_legible__c = event.detail.value; break; 
            case 'EnachRemarks' : 
                this.enachData.Remarks__c = event.detail.value; break; 
            case 'isDebitAuthorisationCompletelyFilled' : 
                this.DebitAuthData.Is_Debit_Authorisation_letter_completely__c = event.detail.value; break; 
            case 'isDebitAuthorisationSignedByCustomer' : 
                this.DebitAuthData.Is_Debit_Authorisation_letter_signed_by__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploaded' : 
                this.DebitAuthData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsDebitAuthorisationLegible' : 
                this.DebitAuthData.Is_Debit_Authorisation_letter_legible__c = event.detail.value; break; 
            case 'DebitAuthRemarks' : 
                this.DebitAuthData.Remarks__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploaded' : 
                this.DSALetterData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsDSALetterLegible' : 
                this.DSALetterData.Is_DSA_Letter_legible__c = event.detail.value; break; 
            case 'DSALetterRemarks' : 
                this.DSALetterData.Remarks__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploaded' : 
                this.DealerLetterData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsDealerLetterLegible' : 
                this.DealerLetterData.Is_Dealer_Letter_legible__c = event.detail.value; break; 
            case 'DealerLetterRemarks' : 
                this.DealerLetterData.Remarks__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploaded' : 
                this.TalathiSarpanchData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsTalathiSarpanchLegible' : 
                this.TalathiSarpanchData.Is_Talathi_Sarpanch_certificate_legible__c = event.detail.value; break; 
            case 'talathiSarpanchRemarks' : 
                this.TalathiSarpanchData.Remarks__c = event.detail.value; break; 
            case 'rcInTheNameOf' : 
                this.vahanData.RC_Owner__c = event.detail.value; break; 
            case 'hypothecationInNameOfVahan' : 
                this.vahanData.Hypothecation_in_name_of__c = event.detail.value; break; hypothecationName = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploadedVahan' : 
                this.vahanData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsVahanLegible' : 
                this.vahanData.Is_Vahan_legible__c = event.detail.value; break; 
            case 'vahanRemarks' : 
                this.vahanData.Remarks__c = event.detail.value; break; 
            case 'fundUtilLetterFilledCompletely' : 
                this.FundUtilisationData.Is_Fund_utilisation_letter_filled__c = event.detail.value; break; 
            case 'fundUtilLetterSignedByCust' : 
                this.FundUtilisationData.Is_Fund_utilisation_signed_by_customer__c = event.detail.value; break; 
            case 'areEnteredDetailsAsPerDocUploadedFun' : 
                this.FundUtilisationData.Are_entered_details_asper_doc_uploaded__c = event.detail.value; break; 
            case 'IsFundLegible' : 
                this.FundUtilisationData.Is_Fund_utilisation_letter_legible__c = event.detail.value; break; 
            case 'fundRemarks' : 
                this.FundUtilisationData.Remarks__c = event.detail.value; break;                     
            default: break;
        }
    }

    hideModalBox() {
        this.isPreview = false;
    }
    
    previewFile(contentDocId,fileType) {
        console.log('preview Id', contentDocId);
        console.log('OUTPUT : ',this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+ fileType +'&versionId=' + contentDocId);
        if(this.isCommunityUser == true){
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
            this.leadId = this.aaplicantIdCoBorrower;
        }else{
            this.leadId = this.aaplicantIdBorrower;
            this.applicantid = this.aaplicantIdBorrower;
        }
        if(this.applicantid == undefined || this.applicantid == '' || this.applicantid == null){
            this.leadId = aaplicantIdBorrower;
            this.applicantid = this.aaplicantIdBorrower;
        }
        console.log('OUTPUT this.docType: ', this.docType);
        console.log('OUTPUT this.docType: ', this.applicantid);
        
        console.log('event : ', event.target.value);

        if(this.mobileTabApp == true){
            if(this.docType){
                let userDetails;
                getUserDetails({})
                .then(result => {
                if(result){
                    userDetails = result;
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url: IntegratorAppURL + this.label.currentApplicantid + '=' + this.leadId + '&' + this.label.currentUserId + '=' + userDetails[this.label.currentUserId] + '&' + this.label.mode + '=' + this.docType + '&' + this.label.currentUserName + '=' + userDetails[this.label.currentUserName] + '&' + this.label.currentUserEmailid + '=' + userDetails[this.label.currentUserEmailid] + '&documentSide=' + this.documentSide
                        }
                    });
                }
                }).catch(error => {
                    console.debug(error);
                });
            }
    
        }else{
        this.docTypeListAll = JSON.parse(JSON.stringify(this.docTypeListAll));
        let newArray = this.docTypeListAll.filter(item => {
            if(item.Document_Type__c == this.docType){
                return item
            }
        });
        if(newArray.length > 0){
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
                dealId: this.dealId,
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
    @api handleSubmitFromParent(){
        this.handleUpdateAndSaveData(false);
    }
    childChange(){
        this.handleSubmit();
    }

    async handleSubmit() {
        if(this.isCheckBoxSectionOpen){
            let allCheckBoxElements = await this.template.querySelectorAll('.chkBox');   
            let uncheckedRec = [];
            if(allCheckBoxElements){
                await allCheckBoxElements.forEach(element => {
                    if(element.type == 'checkbox' && element.checked == false){
                        if(element.name && element.name.includes(`'`)){
                            uncheckedRec.push(element.name.replace(`'` , '\''));
                        }else{
                            uncheckedRec.push(element.name);
                        }
                    }
                });
            }
            if(uncheckedRec && uncheckedRec.length > 0){
                deleteDocRecord({loanApplicationId:this.recordId, docDetails: uncheckedRec});
            }
        }
        if(!this.stageCheck){
            this.isLoadingSpinner = true;
            this.postSavedDataOnSubmit();
        }else{
            this.handleUpdateAndSaveData(true);
        }
    }
    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }
    validateHandler(){
        let allElements = this.template.querySelectorAll('c-i-n-d_-l-w-c_-input-field-for-additional-documents');
        let isValid = true;
        let validAccNo = true;
        if(allElements){
            for (let index = 0; index < allElements.length; index++) {
                if(allElements[index] && allElements[index].getInput() && !allElements[index].getInput().disabled && (allElements[index].getInput().name == 'borrowerAccountNumber' || allElements[index].getInput().name == 'coBorrowerAccountNumber' || allElements[index].getInput().name == 'sellerAccountNumber')){
                    var accountNumber = allElements[index].getInput().value;
                    var regularExpression = new RegExp('^[0-9]*$');
                    if (!regularExpression.test(accountNumber) && accountNumber != '') {
                        validAccNo = false;
                        break;
                      }
                }
                if(allElements[index] && allElements[index].getInput() && !allElements[index].getInput().value && !allElements[index].getInput().disabled){
                    allElements[index].getInput().reportValidity();
                    allElements[index].getInput().checkValidity();
                    isValid = false;
                }
            }
        }
        if(isValid == false){
            this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: 'Please fill all required fields!',variant: 'warning'}));
            this.isLoadingSpinner = false;
            return false;
        }
        if(validAccNo == false){
            this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: ACCOUNT_FORMAT_ERROR,variant: 'warning'}));
            this.isLoadingSpinner = false;
            return false;
        }
        return true;
    }
    @track metaDataList = [];
    async postSavedDataOnSubmit() {
        try{
        let valid = this.validateHandler();
        if(!valid){return;}
        console.log('--------',this.docTypeListAll)
        let dataObj = [];
        for(var i in this.docTypeListAll){
            let obj;
            if(this.docTypeListAll[i]['Document_Type__c'] == 'RC Document' && this.isRCVisible == true){
                let valueEnteredDetailsAsPerDocRC1 = this.template.querySelector('[data-id="enteredDetailsAsPerDocRC"]').getInput();
                let valueIsRCDocLegible1 = this.template.querySelector('[data-id="isRCDocLegible"]').getInput();
                let valueRemarksRCDoc1 = this.template.querySelector('[data-id="remarksRCDoc"]').getInput();
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'RC Document',
                    'Are_enter_details_as_per_RC_doc_upload__c': valueEnteredDetailsAsPerDocRC1.value,
                    'Are_entered_details_as_per_document_uplo__c': valueIsRCDocLegible1.value,
                    'Remarks_for_RC_Upload__c': valueRemarksRCDoc1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'DD for closing existing loan' && this.isBankTransfer == true){//CISP-3325
                let valueIsSaleLegibleDD1 = this.template.querySelector('[data-id="isSaleLegibleDD"]').getInput();
                let valueRemarksSaleLegibleDD1 = this.template.querySelector('[data-id="remarksSaleLegibleDD"]').getInput();
              
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'DD for closing existing loan',
                    'Is_sale_DD_legible__c': valueIsSaleLegibleDD1.value,
                    'Remarks_for_DD__c': valueRemarksSaleLegibleDD1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Seller\'s Passbook' && this.isSellerPassbook == true){//CISP-3325
                let valueSellerPassbookUploaded1 = this.template.querySelector('[data-id="isSellerPassbookUploaded"]').getInput();
                let valueIsSellerPassbookLegible1 = this.template.querySelector('[data-id="isSellerPassbookLegible"]').getInput();
                let valueSellerPassbookRemarks1 = this.template.querySelector('[data-id="sellerPassbookRemarks"]').getInput();
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Seller\'s Passbook',
                    'entered_details_asper_passbook_upload__c': valueSellerPassbookUploaded1.value,
                    'Is_passbook_legible_for_Seller__c': valueIsSellerPassbookLegible1.value,
                    'Passbook_Remarks_for_Seller__c': valueSellerPassbookRemarks1.value,
                    }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Seller\'s Bank Statement' && this.issellerBankState == true){//CISP-3325
                let valueIsSellerEnteredDetailsUploaded1 = this.template.querySelector('[data-id="isSellerEnteredDetailsUploaded"]').getInput();
                let valueIsSellerBankStatementLegible1 = this.template.querySelector('[data-id="isSellerBankStatementLegible"]').getInput();
                let valueSellerBankStatementRemarks1 = this.template.querySelector('[data-id="sellerBankStatementRemarks"]').getInput();
               
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Seller\'s Bank Statement',
                    'enter_details_asper_bank_STMT_upload__c': valueIsSellerEnteredDetailsUploaded1.value,
                    'Is_bank_statement_legible_for_Seller__c': valueIsSellerBankStatementLegible1.value,
                    'Bank_Statement_Remarks_for_Seller__c': valueSellerBankStatementRemarks1.value,
                    }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Seller\'s Cancel Cheque' && this.issellerChqCancel == true){//CISP-3325
                let valueisSellerCanCheq1 = this.template.querySelector('[data-id="isSellerCanCheq"]').getInput();
                let valueIsSellerCanCheqLegible1 = this.template.querySelector('[data-id="isSellerCanCheqLegible"]').getInput();
                let valueSellerCanCheqRemarks1 = this.template.querySelector('[data-id="sellerCanCheqRemarks"]').getInput();
               
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Seller\'s Cancel Cheque',
                    'enter_details_as_per_canc_chq_upload__c': valueisSellerCanCheq1.value,
                    'Is_cancelled_cheque_legible_for_Seller__c': valueIsSellerCanCheqLegible1.value,
                    'cancelled_cheque_Remarks_for_Seller__c': valueSellerCanCheqRemarks1.value,
                   }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Borrower\'s Bank Statement' && this.isborrowerBankState == true){//CISP-3325
                let valueIsBorrowerEnteredDetailsUploaded1 = this.template.querySelector('[data-id="isBorrowerEnteredDetailsUploaded"]').getInput();
                let valueIsBorrowerBankStatementLegible1 = this.template.querySelector('[data-id="isBorrowerBankStatementLegible"]').getInput();
                let valueBorrowerBankStatementRemarks1 = this.template.querySelector('[data-id="borrowerBankStatementRemarks"]').getInput();
               
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Borrower\'s Bank Statement',
                    'enter_DETLS_asper_BWR_bank_STMT_upload__c': valueIsBorrowerEnteredDetailsUploaded1.value,
                    'Is_bank_statement_legible_for_Borrower__c': valueIsBorrowerBankStatementLegible1.value,
                    'Bank_Statement_Remarks_for_Borrower__c': valueBorrowerBankStatementRemarks1.value,
                   }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Borrower\'s Cancel Cheque' && this.isborrowercancelCheq == true){//CISP-3325
                let valueisBorrowerCanCheq1 = this.template.querySelector('[data-id="isBorrowerCanCheq"]').getInput();
                let valueIsCoBorrowerPassbookLegible1 = this.template.querySelector('[data-id="isBorrowerCanCheqLegible"]').getInput();
                let valueCoBorrowerPassbookRemarks1 = this.template.querySelector('[data-id="borrowerCanCheqRemarks"]').getInput();
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Borrower\'s Cancel Cheque',
                    'enter_DETLS_as_per_BWR_canc_chq_upload__c': valueisBorrowerCanCheq1.value,
                    'Is_cancelled_cheque_legible_for_Borrower__c': valueIsCoBorrowerPassbookLegible1.value,
                    'Cancelled_cheque_Remarks_for_Borrower__c': valueCoBorrowerPassbookRemarks1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Co-Borrower\'s Bank Statement' && this.isCoborrowerBankState == true){//CISP-3325
                let valueisCoBorrowerBank1 = this.template.querySelector('[data-id="isCoBorrowerEnteredDetailsUploaded"]').getInput();
                let valueIsCoBorrowerBankLegible1 = this.template.querySelector('[data-id="isCoBorrowerBankStatementLegible"]').getInput();
                let valueCoBorrowerBankqRemarks1 = this.template.querySelector('[data-id="coBorrowerBankStatementRemarks"]').getInput();
               
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Co-Borrower\'s Bank Statement',
                    'DETLS_asper_COBWR_bank_STMT_upload__c': valueisCoBorrowerBank1.value,
                    'Is_bank_statement_legible_for_CoBorrowe__c': valueIsCoBorrowerBankLegible1.value,
                    'Bank_Statement_Remarks_for_CoBorrower__c': valueCoBorrowerBankqRemarks1.value,
                    }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Co-Borrower\'s Cancel Cheque' && this.isCoborrowercancelCheq == true){//CISP-3325
                let valueisBorrowerCanCheq1 = this.template.querySelector('[data-id="isCoBorrowerCanCheq"]').getInput();
                let valueIsBorrowerCanCheqLegible1 = this.template.querySelector('[data-id="isCoBorrowerCanCheqLegible"]').getInput();
                let valueBorrowerCanCheqRemarks1 = this.template.querySelector('[data-id="coBorrowerCanCheqRemarks"]').getInput();
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Co-Borrower\'s Cancel Cheque',
                    'DETLS_asper_COBWR_canc_chq_upload__c': valueisBorrowerCanCheq1.value,
                    'Is_cancelled_cheque_legible_CoBorrower__c': valueIsBorrowerCanCheqLegible1.value,
                    'Cancelled_cheque_Remarks_for_CoBorrower__c': valueBorrowerCanCheqRemarks1.value,
                   }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Buyer-Seller Undertaking letter' && this.isBuyerSeller == true){//CISP-3325
                let valueIsBuyerSellerUndertakingLetterLegible1 = this.template.querySelector('[data-id="Buyer-SellerUndertakingletter"]').getInput();
                let valueBuyerSellerUndertakingLetterRemarks1 = this.template.querySelector('[data-id="buyerSellerUndertakingLetterRemarks"]').getInput();
              
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Buyer-Seller Undertaking letter',
                    'Buyer_Seller_Undertaking_Letter_legib__c': valueIsBuyerSellerUndertakingLetterLegible1.value,
                    'Buyer_Seller_Undertaking_Letter_Remarks__c': valueBuyerSellerUndertakingLetterRemarks1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Indemnity letter' && this.isIndemnityLetter == true){//CISP-3325
                let valueIsIndemnityLetterLegible1 = this.template.querySelector('[data-id="IsIndemnityLetterLegible"]').getInput();
                let valueIndemnityLetterRemarks1 = this.template.querySelector('[data-id="indemnityLetterRemarks"]').getInput();
               
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Indemnity letter',
                    'Buy_Seller_Indemnity_LTR_legible__c': valueIsIndemnityLetterLegible1.value,
                    'Indemnity_Remarks__c': valueIndemnityLetterRemarks1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Tax Invoice' && this.isTaxInvoice == true){//CISP-3325

                let valueIsTaxInvoiceDcoUploaded1 = this.template.querySelector('[data-id="isTaxInvoiceDcoUploaded"]').getInput();
                let valueIsTaxInvoiceLegible1 = this.template.querySelector('[data-id="isTaxInvoiceLegible"]').getInput();
                let valueTaxInvoiceRemarks1 = this.template.querySelector('[data-id="insuranceRemarkstax"]').getInput();

                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Tax Invoice',
                    'enter_details_asper_Tax_Invoice_upload__c': valueIsTaxInvoiceDcoUploaded1.value,
                    'Is_Tax_Invoice_legible__c': valueIsTaxInvoiceLegible1.value,
                    'Tax_Invoice_Remarks__c': valueTaxInvoiceRemarks1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'NOC' && this.isNOC == true){//CISP-3325
                let valueIsNOCDetailsDocUpload1 = this.template.querySelector('[data-id="isNOCDetailsDocUpload"]').getInput();
                let valueIsCancelNOCLegible1 = this.template.querySelector('[data-id="isCancelNOCLegible"]').getInput();
                let valuenOCRemarks1 = this.template.querySelector('[data-id="nOCRemarks"]').getInput();
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'NOC',
                    'Are_enter_details_asper_NOC_doc_upload__c': valueIsNOCDetailsDocUpload1.value,
                    'Is_Cancelled_NOC_legible__c': valueIsCancelNOCLegible1.value,
                    'NOC_Remarks__c': valuenOCRemarks1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Branch Undertaking letter' && this.isBranchUndertake == true){//CISP-3325
                let valueIsBranchUndertakLetterLegible1 = this.template.querySelector('[data-id="isBranchUndertakLetterLegible"]').getInput();
                let valueBranchUndertakRemarks1 = this.template.querySelector('[data-id="branchUndertakRemarks"]').getInput();
               
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Branch Undertaking letter',
                    'Is_Branch_Undertaking_Letter_legible__c': valueIsBranchUndertakLetterLegible1.value,
                    'Branch_Undertaking_Remarks__c': valueBranchUndertakRemarks1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Declaration of Borrower Good Health' && this.isBorrowerDeclare == true){//CISP-3325
                let valueIsDecGoodBorrowerLegible1 = this.template.querySelector('[data-id="isDecGoodBorrowerLegible"]').getInput();
                let valueDecGoodBorrowerRemarks1 = this.template.querySelector('[data-id="decGoodBorrowerRemarks"]').getInput();
             
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Declaration of Borrower Good Health',
                    'Doc_for_Good_Health_borrower_legible__c': valueIsDecGoodBorrowerLegible1.value,
                    'Borrower_Good_Health_Dec_Remarks__c': valueDecGoodBorrowerRemarks1.value,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Declaration of Co-Borrower Good Health' && this.isCoBorrowerDeclare == true){//CISP-3325
                let valueIsDecGoodCoBorrower1 = this.template.querySelector('[data-id="isDecGoodCoBorrower"]').getInput();
                let valueDecGoodCoBorrowerRemarks1 = this.template.querySelector('[data-id="decGoodCoBorrowerRemarks"]').getInput();
               
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Declaration of Co-Borrower Good Health',
                    'Doc_for_Good_Health_coborrower_legible__c': valueIsDecGoodCoBorrower1.value,
                    'CoBorrower_Good_Health_Declaration_Remak__c': valueDecGoodCoBorrowerRemarks1.value,
                }
            } if(this.docTypeListAll[i]['Document_Type__c'] == 'Banker\'s signature verification' && this.BankerSignatureVerificationVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Banker\'s signature verification',
                    'Signature_Verification_Bank_Name__c': this.bankersSignatureData.Signature_Verification_Bank_Name__c,
                    'Signature_verification_for__c': this.bankersSignatureData.Signature_verification_for__c,
                }
            } if(this.docTypeListAll[i]['Document_Type__c'] == 'Insurance Cover Note' && this.InsuranceCoverNoteVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Insurance Cover Note',
                    'Insurance_cover_note_number__c': this.insuranceCoverNoteData.Insurance_cover_note_number__c,
                    'Insurance_cover_note_Date__c': this.insuranceCoverNoteData.Insurance_cover_note_Date__c,
                    'Insurance_declared_value__c': this.insuranceCoverNoteData.Insurance_declared_value__c,
                }
            } if(this.docTypeListAll[i]['Document_Type__c'] == 'Insurance Policy Doc' && this.InsurancePolicyVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Insurance Policy Doc',
                    'Insurance_Policy_number__c': this.insurancePolicyData.Insurance_Policy_number__c,
                    'Insurance_Policy_Date__c': this.insurancePolicyData.Insurance_Policy_Date__c,
                    'Insurance_declared_value__c': this.insurancePolicyData.Insurance_declared_value__c,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Delivery challan' && this.DeliveryChallanVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Delivery challan',
                    'Delivery_Date_of_Asset__c': this.deliveryChallanData.Delivery_Date_of_Asset__c
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Customer declaration letter for payment to Co-borrower/Dealer/ DSA' && this.PaymentToCoBorrowerDealerDSAVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Customer declaration letter for payment to Co-borrower/Dealer/ DSA',
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Existing loan settlement copy for refinance' && this.ExistingLoanSettlementVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Existing loan settlement copy for refinance'
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Affidavit' && this.AffidavitVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Affidavit'
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Enach' && this.EnachVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Enach',
                    'Is_ENACH_form_completely_filled__c': this.enachData.Is_ENACH_form_completely_filled__c,
                    'Is_ENACH_form_signed_by_customer__c': this.enachData.Is_ENACH_form_signed_by_customer__c,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Debit Authorisation' && this.DebitAuthorisationVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Debit Authorisation',
                    'Is_Debit_Authorisation_letter_completely__c': this.DebitAuthData.Is_Debit_Authorisation_letter_completely__c,
                    'Is_Debit_Authorisation_letter_signed_by__c': this.DebitAuthData.Is_Debit_Authorisation_letter_signed_by__c,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'DSA letter' && this.DSALetterVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'DSA letter',
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Dealer Letter' && this.DealerLetterVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Dealer Letter',
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Talathi/Sarpanch Certificate' && this.TalathiSarpanchCertificateVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Talathi/Sarpanch Certificate'
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Vahan Extract' && this.VahanExtractVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Vahan Extract',
                    'RC_Owner__c': this.vahanData.RC_Owner__c,
                    'Hypothecation_in_name_of__c': this.vahanData.Hypothecation_in_name_of__c,
                }
            }if(this.docTypeListAll[i]['Document_Type__c'] == 'Fund Utilisation letter for Refinance' && this.FundUtilisationVal == true){
                obj = {
                    'Id': this.docTypeListAll[i]['Id'],
                    'Document_Type__c': 'Fund Utilisation letter for Refinance',
                    'Is_Fund_utilisation_letter_filled__c': this.FundUtilisationData.Is_Fund_utilisation_letter_filled__c,
                    'Is_Fund_utilisation_signed_by_customer__c': this.FundUtilisationData.Is_Fund_utilisation_signed_by_customer__c,
                }
            }
            if(obj){
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
        }catch(error){
            this.isLoadingSpinner = false;
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something Went Wrong!',variant: 'error',}),); 
        }
    }
    async handleUpdateAndSaveData(subFlag) {
        let valid = this.validateHandler();
        if(!valid){return;}
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
            let obj;
            if (docTypeName == 'RC Document' && this.isRCVisible == true) {
                let RCOwner = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="RCOwner"]').getInput();
                let Hypothecationavailable = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="Hypothecationavailable"]').getInput();
                let hypothecationName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="hypothecationNameRc"]').getInput();
                RCOwner.reportValidity();
                Hypothecationavailable.reportValidity();
                hypothecationName.reportValidity();

                if (RCOwner.validity.valid === true && Hypothecationavailable.validity.valid && hypothecationName.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'RC_Owner__c': RCOwner.value,
                        'Hypothecation_available__c': Hypothecationavailable.value,
                        'Hypothecation_in_name_of__c': hypothecationName.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'DD for closing existing loan') {
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                
            } else if (docTypeName == 'Seller\'s Passbook' && this.isSellerPassbook == true) {
                console.log('in seller : ', );
                let sellerBankName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerBankName"]').getInput();
                let sellerAccountNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerAccountNumber"]').getInput();
                let sellerAccountHolder = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerAccountHolder"]').getInput();
                let valueIfscCodeSeller1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="ifscCodeSeller"]').getInput();
                sellerBankName.reportValidity();
                sellerAccountNumber.reportValidity();
                sellerAccountHolder.reportValidity();

                if (sellerBankName.validity.valid === true && sellerAccountNumber.validity.valid && sellerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Seller_Bank_name__c': sellerBankName.value,
                        'Seller_Account_number__c': sellerAccountNumber.value,
                        'Name_of_Seller_account_holder__c': sellerAccountHolder.value,
                        'IFSC_code_Seller__c': valueIfscCodeSeller1.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }


            } else if (docTypeName == 'Seller\'s Bank Statement' && this.issellerBankState == true) {
                console.log('in seller : ', );
                let sellerBankName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerBankName"]').getInput();
                let sellerAccountNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerAccountNumber"]').getInput();
                let sellerAccountHolder = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerAccountHolder"]').getInput();
                let valueIfscCodeSeller1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="ifscCodeSeller"]').getInput();
                sellerBankName.reportValidity();
                sellerAccountNumber.reportValidity();
                sellerAccountHolder.reportValidity();

                if (sellerBankName.validity.valid === true && sellerAccountNumber.validity.valid && sellerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Seller_Bank_name__c': sellerBankName.value,
                        'Seller_Account_number__c': sellerAccountNumber.value,
                        'Name_of_Seller_account_holder__c': sellerAccountHolder.value,
                        'IFSC_code_Seller__c': valueIfscCodeSeller1.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'Seller\'s Cancel Cheque' && this.issellerChqCancel == true) {
                console.log('in seller : ', );
                let sellerBankName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerBankName"]').getInput();
                let sellerAccountNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerAccountNumber"]').getInput();
                let sellerAccountHolder = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="sellerAccountHolder"]').getInput();
                let valueIfscCodeSeller1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="ifscCodeSeller"]').getInput();
                sellerBankName.reportValidity();
                sellerAccountNumber.reportValidity();
                sellerAccountHolder.reportValidity();

                if (sellerBankName.validity.valid === true && sellerAccountNumber.validity.valid && sellerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Seller_Bank_name__c': sellerBankName.value,
                        'Seller_Account_number__c': sellerAccountNumber.value,
                        'Name_of_Seller_account_holder__c': sellerAccountHolder.value,
                        'IFSC_code_Seller__c': valueIfscCodeSeller1.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }

            }  else if (docTypeName == 'Borrower\'s Bank Statement' && this.isborrowerBankState == true) {
                let borrowerBankName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="borrowerBankName"]').getInput();
                let borrowerAccountNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="borrowerAccountNumber"]').getInput();
                let borrowerAccountHolder = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="borrowerAccountHolder"]').getInput();
                let valueIfscCodeBorrower1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="ifscCodeBorrower"]').getInput();
                borrowerBankName.reportValidity();
                borrowerAccountNumber.reportValidity();
                borrowerAccountHolder.reportValidity();

                if (borrowerBankName.validity.valid === true && borrowerAccountNumber.validity.valid && borrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Borrower_Bank_name__c': borrowerBankName.value,
                        'Borrower_Account_number__c': borrowerAccountNumber.value,
                        'Name_of_Borrower_account_holder__c': borrowerAccountHolder.value,
                        'IFSC_code_Borrower__c': valueIfscCodeBorrower1.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Borrower\'s Cancel Cheque' && this.isborrowercancelCheq == true) {
                let borrowerBankName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="borrowerBankName"]').getInput();
                let borrowerAccountNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="borrowerAccountNumber"]').getInput();
                let borrowerAccountHolder = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="borrowerAccountHolder"]').getInput();
                let valueIfscCodeBorrower1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="ifscCodeBorrower"]').getInput();
                borrowerBankName.reportValidity();
                borrowerAccountNumber.reportValidity();
                borrowerAccountHolder.reportValidity();

                if (borrowerBankName.validity.valid === true && borrowerAccountNumber.validity.valid && borrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Borrower_Bank_name__c': borrowerBankName.value,
                        'Borrower_Account_number__c': borrowerAccountNumber.value,
                        'Name_of_Borrower_account_holder__c': borrowerAccountHolder.value,
                        'IFSC_code_Borrower__c': valueIfscCodeBorrower1.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Co-Borrower\'s Bank Statement' && this.isCoborrowerBankState == true) {
                let coBorrowerBankName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="coBorrowerBankName"]').getInput();
                let coBorrowerAccountNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="coBorrowerAccountNumber"]').getInput();
                let coBorrowerAccountHolder = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="coBorrowerAccountHolder"]').getInput();
                let valueIfscCodeCoBorrower1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="ifscCodeCoBorrower"]').getInput();
                coBorrowerBankName.reportValidity();
                coBorrowerAccountNumber.reportValidity();
                coBorrowerAccountHolder.reportValidity();
                if (coBorrowerBankName.validity.valid === true && coBorrowerAccountNumber.validity.valid && coBorrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'CoBorrower_Bank_name__c': coBorrowerBankName.value,
                        'CoBorrower_Account_number__c': coBorrowerAccountNumber.value,
                        'Name_of_CoBorrower_account_holder__c': coBorrowerAccountHolder.value,
                        'IFSC_code_CoBorrower__c': valueIfscCodeCoBorrower1.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Co-Borrower\'s Cancel Cheque' && this.isCoborrowercancelCheq == true) {
                let coBorrowerBankName = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="coBorrowerBankName"]').getInput();
                let coBorrowerAccountNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="coBorrowerAccountNumber"]').getInput();
                let coBorrowerAccountHolder = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="coBorrowerAccountHolder"]').getInput();
                let valueIfscCodeCoBorrower1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="ifscCodeCoBorrower"]').getInput();
                coBorrowerBankName.reportValidity();
                coBorrowerAccountNumber.reportValidity();
                coBorrowerAccountHolder.reportValidity();
                if (coBorrowerBankName.validity.valid === true && coBorrowerAccountNumber.validity.valid && coBorrowerAccountHolder.validity.valid) {
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'CoBorrower_Bank_name__c': coBorrowerBankName.value,
                        'CoBorrower_Account_number__c': coBorrowerAccountNumber.value,
                        'Name_of_CoBorrower_account_holder__c': coBorrowerAccountHolder.value,
                        'IFSC_code_CoBorrower__c': valueIfscCodeCoBorrower1.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }
            } else if (docTypeName == 'Buyer-Seller Undertaking letter') {
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                
            } else if (docTypeName == 'Indemnity letter') {
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                
            } else if (docTypeName == 'Tax Invoice' && this.isTaxInvoice == true) {
                console.log('in Tax invoice : ', );
                let invoiceNumber = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="invoiceNumber"]').getInput();
                let invoiceDate = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="invoiceDate"]').getInput();
                let invoiceAmount = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="invoiceAmount"]').getInput();
                invoiceNumber.reportValidity();
                invoiceDate.reportValidity();
                invoiceAmount.reportValidity();
                if (invoiceNumber.validity.valid === true && invoiceDate.validity.valid && invoiceAmount.validity.valid) {
                    console.log('in invoice part if  : ', );
                    isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Invoice_number__c': invoiceNumber.value,
                        'Invoice_date__c': invoiceDate.value,
                        'Invoice_amount__c': invoiceAmount.value,
                    }
                    
                } else {
                    console.log('in invoice part else : ', );
                    isAllValid.push(false);
                }


            } else if (docTypeName == 'NOC' && this.isNOC == true) {
                let hologramNO = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="hologramAsperNOC"]').getInput();
                let nocRef = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="NOCrefNo"]').getInput();
                let hasNocCanel = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="hasNOcCancel"]').getInput();
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
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': docTypeName,
                        'Hologram_no_as_per_NOC__c': hologramNO.value,
                        'NOC_ref_no_as_per_journey__c': nocRef.value,
                        'Has_NOC_been_canceled__c': hasNocCanel.value,
                    }
                    
                } else {
                    isAllValid.push(false);
                }

            } else if (docTypeName == 'Branch Undertaking letter') {
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                
            } else if (docTypeName == 'Declaration of Borrower Good Health') {
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                
            } else if (docTypeName == 'Declaration of Co-Borrower Good Health') {
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': docTypeName,
                }
                
            }  else if(docTypeName == 'Banker\'s signature verification' && this.BankerSignatureVerificationVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="signatureVerificationBankName"]').getInput();
                let field2 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="SignatureVerificationFor"]').getInput();
                field1.reportValidity();
                field2.reportValidity();
                if (field1.validity.valid === true  && field2.validity.valid) { isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': 'Banker\'s signature verification',
                        'Signature_Verification_Bank_Name__c': this.bankersSignatureData.Signature_Verification_Bank_Name__c,
                        'Signature_verification_for__c': this.bankersSignatureData.Signature_verification_for__c,
                    }
                } else {isAllValid.push(false);}
                
            }  else if(docTypeName == 'Insurance Cover Note' && this.InsuranceCoverNoteVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="InsuranceCoverNoteNumber"]').getInput();
                let field2 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="InsuranceCoverNoteDate"]').getInput();
                let field3 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="InsuranceDeclaredValue"]').getInput();
                field1.reportValidity();
                field2.reportValidity();
                field3.reportValidity();
                if (field1.validity.valid === true  && field2.validity.valid === true &&  field3.validity.valid === true) { isAllValid.push(true);
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Insurance Cover Note',
                    'Insurance_cover_note_number__c': this.insuranceCoverNoteData.Insurance_cover_note_number__c,
                    'Insurance_cover_note_Date__c': this.insuranceCoverNoteData.Insurance_cover_note_Date__c,
                    'Insurance_declared_value__c': this.insuranceCoverNoteData.Insurance_declared_value__c,
                }} else {isAllValid.push(false);}
            }  else if(docTypeName == 'Insurance Policy Doc' && this.InsurancePolicyVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="InsurancePolicyNumber"]').getInput();
                let field2 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="InsurancePolicyDate"]').getInput();
                let field3 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="InsurancePolDeclaredValue"]').getInput();
                field1.reportValidity();
                field2.reportValidity();
                field3.reportValidity();
                if (field1.validity.valid === true  && field2.validity.valid === true &&  field3.validity.valid === true) { isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': 'Insurance Policy Doc',
                        'Insurance_Policy_number__c': this.insurancePolicyData.Insurance_Policy_number__c,
                        'Insurance_Policy_Date__c': this.insurancePolicyData.Insurance_Policy_Date__c,
                        'Insurance_declared_value__c': this.insurancePolicyData.Insurance_declared_value__c,
                    }} else {isAllValid.push(false);}
            } else if(docTypeName == 'Delivery challan' && this.DeliveryChallanVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="DeliveryDateOfAsset"]').getInput();
                field1.reportValidity();
                if (field1.validity.valid === true ) { isAllValid.push(true);
                    obj = {
                        'Id': docTypeandId,
                        'Document_Type__c': 'Delivery challan',
                        'Delivery_Date_of_Asset__c': this.deliveryChallanData.Delivery_Date_of_Asset__c
                    }} else {isAllValid.push(false);}
            } else if(docTypeName == 'Customer declaration letter for payment to Co-borrower/Dealer/ DSA' && this.PaymentToCoBorrowerDealerDSAVal == true){
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Customer declaration letter for payment to Co-borrower/Dealer/ DSA',
                }
            } else if(docTypeName == 'Existing loan settlement copy for refinance' && this.ExistingLoanSettlementVal == true){
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Existing loan settlement copy for refinance'
                }
            } else if(docTypeName == 'Affidavit' && this.AffidavitVal == true){
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Affidavit'
                }
            } else if(docTypeName == 'Enach' && this.EnachVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="isEnachFormCompletelyFilled"]').getInput();
                let field2 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="isEnachFormSignedByCustomer"]').getInput();
                field1.reportValidity();
                field2.reportValidity();
                if (field1.validity.valid === true  && field2.validity.valid === true) { isAllValid.push(true);
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Enach',
                    'Is_ENACH_form_completely_filled__c': this.enachData.Is_ENACH_form_completely_filled__c,
                    'Is_ENACH_form_signed_by_customer__c': this.enachData.Is_ENACH_form_signed_by_customer__c,
                }} else {isAllValid.push(false);}
            } else if(docTypeName == 'Debit Authorisation' && this.DebitAuthorisationVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="isDebitAuthorisationCompletelyFilled"]').getInput();
                let field2 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="isDebitAuthorisationSignedByCustomer"]').getInput();
                field1.reportValidity();
                field2.reportValidity();
                if (field1.validity.valid === true  && field2.validity.valid === true) { isAllValid.push(true);
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Debit Authorisation',
                    'Is_Debit_Authorisation_letter_completely__c': this.DebitAuthData.Is_Debit_Authorisation_letter_completely__c,
                    'Is_Debit_Authorisation_letter_signed_by__c': this.DebitAuthData.Is_Debit_Authorisation_letter_signed_by__c,
                }} else {isAllValid.push(false);}
            } else if(docTypeName == 'DSA letter' && this.DSALetterVal == true){
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'DSA letter',
                }
            } else if(docTypeName == 'Dealer Letter' && this.DealerLetterVal == true){
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Dealer Letter',
                }
            } else if(docTypeName == 'Talathi/Sarpanch Certificate' && this.TalathiSarpanchCertificateVal == true){
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Talathi/Sarpanch Certificate'
                }
            } else if(docTypeName == 'Vahan Extract' && this.VahanExtractVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="rcInTheNameOf"]').getInput();
                let field2 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="hypothecationInNameOfVahan"]').getInput();
                field1.reportValidity();
                field2.reportValidity();
                if (field1.validity.valid === true  && field2.validity.valid === true) { isAllValid.push(true);
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Vahan Extract',
                    'RC_Owner__c': this.vahanData.RC_Owner__c,
                    'Hypothecation_in_name_of__c': this.vahanData.Hypothecation_in_name_of__c,
                }} else {isAllValid.push(false);}
            } else if(docTypeName == 'Fund Utilisation letter for Refinance' && this.FundUtilisationVal == true){
                let field1 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="fundUtilLetterFilledCompletely"]').getInput();
                let field2 = this.template.querySelector('c-i-n-d_-l-w-c_-input-field-for-additional-documents[data-id="fundUtilLetterSignedByCust"]').getInput();
                field1.reportValidity();
                field2.reportValidity();
                if (field1.validity.valid === true  && field2.validity.valid === true) { isAllValid.push(true);
                obj = {
                    'Id': docTypeandId,
                    'Document_Type__c': 'Fund Utilisation letter for Refinance',
                    'Is_Fund_utilisation_letter_filled__c': this.FundUtilisationData.Is_Fund_utilisation_letter_filled__c,
                    'Is_Fund_utilisation_signed_by_customer__c': this.FundUtilisationData.Is_Fund_utilisation_signed_by_customer__c,
                }} else {isAllValid.push(false);}
            }
            if (obj) {
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
          this.dispatchEvent(actionResultEvent);
        }
    }
    @track docTypeListId = []
    @track docTypeListAll = [];
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
    @track docTypeList = []
    
    async retreiveDocumentTypeCheck() {
        for (var i in this.docTypeList) {
            if (this.docTypeList[i] === 'RC Document') {
                this.isRCVisible = true;
            }if (this.docTypeList[i] === 'DD for closing existing loan') {
                this.isBankTransfer = true;
                this.isDDforClosing = true;
            }if (this.docTypeList[i] === 'Seller\'s Passbook') {
                this.isSellerPassbook = true;
                this.isSeller1 = true;
                if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
                    this.isSeller = true;
                } else {
                    this.isSeller = false;
                }
            }if (this.docTypeList[i] === 'Seller\'s Bank Statement') {
                this.issellerBankState = true;
                this.isSeller2 = true;
                if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
                    this.isSeller = true;
                } else {
                    this.isSeller = false;
                }
            }if (this.docTypeList[i] === 'Seller\'s Cancel Cheque') {
                this.issellerChqCancel = true;
                this.isSeller3 = true;;
                if (this.isSeller1 == true || this.isSeller2 == true || this.isSeller3 == true) {
                    this.isSeller = true;
                } else {
                    this.isSeller = false;
                }
            }if (this.docTypeList[i] === 'Borrower\'s Bank Statement') {
                this.isBorrower2 = true;
                this.isborrowerBankState = true;
                if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
                    this.isBorrower = true;
                } else {
                    this.isBorrower = false;
                }
            }if (this.docTypeList[i] === 'Borrower\'s Cancel Cheque') {
                this.isBorrower1 = true;
                this.isborrowercancelCheq = true;
                if (this.isBorrower1 == true || this.isBorrower2 == true || this.isBorrower3 == true) {
                    this.isBorrower = true;
                } else {
                    this.isBorrower = false;
                }
            }if (this.docTypeList[i] === 'Co-Borrower\'s Bank Statement') {
                this.isCoBorrower2 = true;
                this.isCoborrowerBankState = true;
                if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
                    this.isCoBorrower = true;
                } else {
                    this.isCoBorrower = false;
                }
            }if (this.docTypeList[i] === 'Co-Borrower\'s Cancel Cheque') {
                this.isCoBorrower3 = true;
                this.isCoborrowercancelCheq = true;
                if (this.isCoBorrower1 == true || this.isCoBorrower2 == true || this.isCoBorrower3 == true) {
                    this.isCoBorrower = true;
                } else {
                    this.isCoBorrower = false;
                }
            }if (this.docTypeList[i] === 'Buyer-Seller Undertaking letter') {
                this.isBuyerSeller = true;
            }if (this.docTypeList[i] === 'Indemnity letter') {
                this.isIndemnityLetter = true;
            }if (this.docTypeList[i] === 'Tax Invoice') {
                console.log('in tax invoice : ',);
                this.isTaxInvoice = true;
            }if (this.docTypeList[i] === 'NOC') {
                this.isNOC = true;
            }if (this.docTypeList[i] === 'Branch Undertaking letter') {
                this.isBranchUndertake = true;
            }if (this.docTypeList[i] === 'Declaration of Borrower Good Health') {
                this.isBorrowerDeclare = true;
            }if (this.docTypeList[i] === 'Declaration of Co-Borrower Good Health') {
                this.isCoBorrowerDeclare = true;
            } else if(this.docTypeList[i] == 'Banker\'s signature verification' ){
                this.BankerSignatureVerificationVal = true;
            }  else if(this.docTypeList[i] == 'Insurance Cover Note' ){
                this.InsuranceCoverNoteVal = true;
            }  else if(this.docTypeList[i] == 'Insurance Policy Doc' ){
                this.InsurancePolicyVal = true;
            } else if(this.docTypeList[i] == 'Delivery challan'){
                this.DeliveryChallanVal = true;
            } else if(this.docTypeList[i] == 'Customer declaration letter for payment to Co-borrower/Dealer/ DSA' ){
                this.PaymentToCoBorrowerDealerDSAVal = true;
            } else if(this.docTypeList[i] == 'Existing loan settlement copy for refinance' ){
                this.ExistingLoanSettlementVal = true;
            } else if(this.docTypeList[i] == 'Affidavit'){
                this.AffidavitVal = true;
            } else if(this.docTypeList[i] == 'Enach' ){
                this.EnachVal = true;
            } else if(this.docTypeList[i] == 'Debit Authorisation'){
                this.DebitAuthorisationVal = true;
            } else if(this.docTypeList[i] == 'DSA letter'){
                this.DSALetterVal = true;
            } else if(this.docTypeList[i] == 'Dealer Letter' ){
                this.DealerLetterVal = true;
            } else if(this.docTypeList[i] == 'Talathi/Sarpanch Certificate' ){
                this.TalathiSarpanchCertificateVal = true;
            } else if(this.docTypeList[i] == 'Vahan Extract' ){
                this.VahanExtractVal = true;
            } else if(this.docTypeList[i] == 'Fund Utilisation letter for Refinance' ){
                this.FundUtilisationVal = true;
            }
        }
        this.isLoadingSpinner = false;
    }
    async handlePreview(event){
        let contentDocId ;
        let docType = event.target.name;
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