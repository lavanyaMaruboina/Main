import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import DOCUMENTS_OBJECT from '@salesforce/schema/Documents__c';
import getIHMDetails from '@salesforce/apex/IHMPageController.getIHMDetails';
import documentFiles from '@salesforce/apex/IHMPageController.documentFiles';
import insertDocument from '@salesforce/apex/IHMPageController.insertDocument';
import deleteDocument from '@salesforce/apex/IHMPageController.deleteDocument';
import checkIfReadOnly from '@salesforce/apex/IHMPageController.checkIfReadOnly';
import submitIHMRecord from '@salesforce/apex/IHMPageController.submitIHMRecord';
import updateLoanAppHistory from '@salesforce/apex/IHMPageController.updateLoanAppHistory';
import getDocumentFiles from '@salesforce/apex/IHMPageController.getDocumentFiles';
import validateScreenVisiblityFromApex from '@salesforce/apex/IHMPageController.validateScreenVisiblity';
import getIHMDocumentsAmountSum from '@salesforce/apex/IHMPageController.getIHMDocumentsAmountSum';
import loanApplicationRelated from '@salesforce/apex/IHMPageController.loanApplicationRelated';
import doIHMReceiptCallout from '@salesforce/apexContinuation/IntegrationEngine.doIHMReceiptCallout';
import IHMWarningInvoice from '@salesforce/label/c.IHMWarningInvoice';
import FetchAmountSuccessMsg from '@salesforce/label/c.FetchAmountSuccessMsg';
import IHMVALUATIONCHARGESWARNING from '@salesforce/label/c.IHMVALUATIONCHARGES';
import ERROR from '@salesforce/label/c.Error';
import UPLOADFAILED from '@salesforce/label/c.Upload_Failed';
import SUBMITSUCCESSFULLY from '@salesforce/label/c.SubmitSuccessfully';
import IHM_Receipt from '@salesforce/label/c.IHM_Receipt';
import Kindly_Retry from '@salesforce/label/c.Kindly_Retry';
import Please_fill_all_the_mandatory_fields from '@salesforce/label/c.Please_fill_all_the_mandatory_fields';
import DeleteSuccessMsg from '@salesforce/label/c.DeleteSuccessMsg';
import Loan_Stage_Additional_Documents from '@salesforce/label/c.Loan_Stage_Additional_Documents';
import getContentVersion from '@salesforce/apex/SecurityMandate.getContentVersion';
import { NavigationMixin } from 'lightning/navigation';
import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';
import PASSENGERVEHICLES from '@salesforce/label/c.PassengerVehicles';
import IHMCOMPUTEDERRORMSG from '@salesforce/label/c.IHMComputedErrorMsg';
import IHM_TW_New_Validation_Error_Msg from '@salesforce/label/c.IHM_TW_New_Validation_Error_Msg';
import ValuationBorneByMandatoryMsg from '@salesforce/label/c.ValuationBorneByMandatoryMsg';//CISP-2512
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import Vehicle_Detail__c from '@salesforce/schema/Vehicle_Detail__c';
import RC_retention_applicable__c from '@salesforce/schema/Vehicle_Detail__c.RC_retention_applicable__c';
import RC_Hold_Amount__c from '@salesforce/schema/Vehicle_Detail__c.RC_Hold_Amount__c';
import getVehicleDetailsForIHMPage from '@salesforce/apex/IHMPageController.getVehicleDetailsForIHMPage'
export default class IND_LWC_IHMPage extends NavigationMixin(LightningElement) {
  rcHoldAmount;rcRetentionApplicable;@track rcRetentionApplicableYes = false;vehicleId;
  @api dealId = '';
  communityPartnersURL = IBL_Community_Partners_URL;
  isCommunityUser;
  @api ihmId;
  @api loanId;
  @api applicantId;
  @api isReadOnly;
  @api currentStep;
  oppStage;
  docType = IHM_Receipt;
  showDocView = false;
  showPhotoCopy;
  showUpload = false;
  isAllDocType = false;
  vehiclerecordid = false;
  isVehicleDoc = true;
  validateScreenVisiblity = true;
  validateWarningMessage;

  isUsedRefinancePV = false;
  isUsedRefinanceUPD = false;
  isNewTwoWheeler = false;

  @track uploadIHMRecieptFlag = false;
  @track documentRecordId;
  @track recordTypeId;
  @track ihmDetails;
  @track finalTermDetails;
  @track documentsDetails;
  @track camDetails;
  @track itemList;
  @track loadComponent = false;
  @track itemList = [{ id: 0, }];
  isPreview = false;
  converId;
  height = 32;
  ihmvaluationcharges;
  valuerCategory;
  productType;
  @track IsTractor = false;
  @track hideRecieptSectionForTractor = false;
  borneDropdownShow = false;
  _valuationDisabled = false;
  get valuationDisabled() {
    return this._valuationDisabled || this.isReadOnly;
  }
  set valuationDisabled(value) {
    this._valuationDisabled = value;
  }

  keyIndex = 0;
  activeSections = ['Total amount paid by customer to dealer', 'Invoice break up', 'Total non-funded Insurance', 'Pay-ins', 'Total amount paid by customer to bank', 'EMI amount (in case of Adv. EMI)', 'Other charges', 'IHM calculation', 'IHM Computation', 'pay-ins(this section is for used Vehicle)','IHM IBL received'];
  valuationFieldVisible = false;
  totalEmiToConsider = 0;
  _totalOfAbovePay = 0;
  @track _doesCustomerNeedToPay = '';
  _additionalAmountPaid = 0
  @track _toalNonFundedIns = 0;
  _saAccountOpeningCharge = 0;
  totalOtherCharges = 0
  _totalAmountToPaid = 0;
  // _valuationValue;
  _getTotalMarginDedDis;
  _totalNonFundedInsAmo = 0;

  cvoEnabledField = true;
  preCalSubmitDisabled = false;
  yesNoOptions;
  borneByOptions;
  borneValue;
  ihmRecoveryValue;
  toalAmountPaidToBank = 0;
  loanAmtSanctionedFexclFundInsu = 0;
  @track totalIHMpaidToDealer = 0;
  moneyDisburstmentInputLabel = 'Total margin money to be deducted from disbursement';
  paysInsUsedAccordianLabel = 'pay-ins(this section is for used Vehicle)';
  paidByBankAccordianLabel = 'Total amount paid by customer to bank';
  isLoanAmountSanctionedexcelFundInsur = true;//OLA integration changes
  leadSource;// Ola integration changes
  isReadOnlyola;//Ola integration changes

  @wire(getObjectInfo, { objectApiName: Vehicle_Detail__c })vehiObj;
  @wire(getPicklistValues, { recordTypeId: '$vehiObj.data.defaultRecordTypeId', fieldApiName: RC_retention_applicable__c })rcRetentionOptionsListTractor;

  @wire(getObjectInfo, { objectApiName: DOCUMENTS_OBJECT })
  objectInfo({ error, data }) {
    if (data) {
      let recordTypeId = Object.keys(data.recordTypeInfos).find(key => data.recordTypeInfos[key].name === 'Other Documents');
      this.recordTypeId = recordTypeId;
    }
  };

  get showDocList() {
    this.keyIndex = this.documentsDetails != undefined || this.documentsDetails != null ? this.documentsDetails.length : 0;
    var show = this.keyIndex == 0 ? false : true;
    return show;
  }

  get totalOfAbovePay() {
    this._totalOfAbovePay = this.isReadOnly ? this._totalOfAbovePay : Number(this.finalTermDetails.serviceCharges) + Number(this.finalTermDetails.documentationCharges) + Number(this.finalTermDetails.stampingCharges) + Number(this.finalTermDetails.tradeCertificate) + Number(this.finalTermDetails.dueDateShiftCharges);
    return this._totalOfAbovePay;
  }

  get doesCustomerNeedToPay() {
    this._doesCustomerNeedToPay = this.isReadOnly ? this._doesCustomerNeedToPay : Number(this.getTotalAmountToPaid) - Number(this.toalAmountPaidToBank) - Number(this.totalIHMpaidToDealer) > 0 ? 'Yes' : 'No';
    return this._doesCustomerNeedToPay;
  }

  set doesCustomerNeedToPay(value) {
    this._doesCustomerNeedToPay = value;
  }

 get additionalAmountPaid() {
    let tempSum = this.isReadOnly ? this._additionalAmountPaid : Number(this.getTotalAmountToPaid == undefined ? 0 : this.getTotalAmountToPaid) - (Number(this.toalAmountPaidToBank == undefined ? 0 : this.toalAmountPaidToBank) + Number(this.totalIHMpaidToDealer == undefined ? 0 : this.totalIHMpaidToDealer));
    if(this.IsTractor){
      if(tempSum === 0){
        this._additionalAmountPaid  = 0;
      }else{
        this._additionalAmountPaid  = tempSum;
      }
    }else{
    if(tempSum < 0){
      this._additionalAmountPaid  = 0;
    }else{
      this._additionalAmountPaid  = tempSum;
      }
    }
    return this._additionalAmountPaid;
  }

  get toalNonFundedIns() {
    this._toalNonFundedIns = this.isReadOnly ? this._toalNonFundedIns : this.ihmDetails.isMotorInsuranceFunded == 'No' ? Number(this.ihmDetails.xstYearMotorInsurancePremium) + Number(this._totalNonFundedInsAmo) : Number(this._totalNonFundedInsAmo);
    return this._toalNonFundedIns;
  }
  get toalNonFundedInsC() {
    this._totalNonFundedInsC = this.isReadOnly ? this._totalNonFundedInsC : this.ihmDetails.isMotorInsuranceFunded == 'No' ? Number(this.ihmDetails.xstYearMotorInsurancePremium) + Number(this._totalNonFundedInsAmo) : Number(this._totalNonFundedInsAmo);
    return this._totalNonFundedInsC;
  }

  get getTotalAmountToPaid() {
    this._totalAmountToPaid = this.isReadOnly ? this._totalAmountToPaid : Number(this.ihmDetails.invoicePrice == undefined ? 0 : this.ihmDetails.invoicePrice) + Number(this.toalNonFundedIns == undefined ? 0 : this.toalNonFundedIns) + Number(this._totalOfAbovePay == undefined ? 0 : this._totalOfAbovePay) + Number(this.totalEmiToConsider == undefined ? 0 : this.totalEmiToConsider) + Number(this.totalOtherCharges == undefined ? 0 : this.totalOtherCharges) - (Number(this.ihmDetails.loanAmtSanctionedFexclFundInsu == undefined ? 0 : this.ihmDetails.loanAmtSanctionedFexclFundInsu));
    return this._totalAmountToPaid;
  }

  get getTotalMarginDedDis() {
    this._getTotalMarginDedDis = this.isReadOnly ? this._getTotalMarginDedDis : Number(this.totalOfAbovePay == undefined ? 0 : this.totalOfAbovePay) + Number(this.toalNonFundedIns == undefined ? 0 : this.toalNonFundedIns) + Number(this.totalEmiToConsider == undefined ? 0 : this.totalEmiToConsider) + Number(this.ihmvaluationcharges == null ? 0 : this.ihmvaluationcharges) + Number(this._saAccountOpeningCharge == undefined ? 0 : this._saAccountOpeningCharge);
    return this._getTotalMarginDedDis;
  }

  disbursedAmount = 0;
  calculateDisbursedAmount() {
    try {
      setTimeout(() => {
        if(!this.isReadOnly){
          if(this.isUsedRefinanceUPD){
            this.disbursedAmount = this.loanAmtSanctionedFexclFundInsu - this.totalIHMpaidToDealer;
          }else if(this.isUsedRefinancePV){
            this.disbursedAmount = this.loanAmtSanctionedFexclFundInsu - this.getTotalMarginDedDis + this.toalAmountPaidToBank;
          }
          if(this.disbursedAmount){
            console.log('disbursedAmount ', this.disbursedAmount);
          }
        }
      }, 1000); 
    } catch (error) {
      console.log('error 161 ', JSON.stringify(error));
    }
  }

  _totalNonFundedInsC;
  @api isRevokedLoanApplication;//CISP-2735
  async connectedCallback() {
    // this.ihmvaluationcharges = IHMVALUATIONCHARGES;
    var optionList = new Array();
    optionList.push({ label: 'Yes', value: 'Yes' });
    optionList.push({ label: 'No', value: 'No' });
    this.yesNoOptions = optionList;

    var borneByOptions = new Array();
    borneByOptions.push({ label: 'IBL', value: 'IBL' });
    borneByOptions.push({ label: 'Customer', value: 'Customer' });
    this.borneByOptions = borneByOptions;
    await validateScreenVisiblityFromApex({ loanAppId: this.loanId, dealId: this.dealId }).then(result => {
      this.validateScreenVisiblity = result.screenVisible;
      this.isUsedRefinancePV = result.isUsedRefinancePV;
      this.isNewTwoWheeler = result.isNewTwoWheeler;
      this.isUsedRefinanceUPD = result.isUsedRefinanceUPD;
      this.isIHMReceiptShow = result.isIHMReceiptShow;
      if(this.isUsedRefinancePV){
        this.moneyDisburstmentInputLabel = 'Total margin money to be deducted from disbursement (IHM Computed)';
        this.paysInsUsedAccordianLabel = 'IHM Computation';
        this.paidByBankAccordianLabel = 'IHM IBL received';
      }
      if (this.validateScreenVisiblity) {
        loanApplicationRelated({ loanId: this.loanId, currentStep: this.currentStep, dealId: this.dealId }).then(result => {
          if (result) {
            console.log('result ', JSON.stringify(result));
            this.isCommunityUser = result.isCommunityUser;
            this.ihmId = result.ihmId;
            this.applicantId = result.applicantId;
            this.cvoEnabledField = result.cvoEnabledField;
            this.preCalSubmitDisabled = result.preCalSubmitDisabled;
            this.ihmvaluationcharges = result.ihmvaluationcharges;
            this.borneValue = result.borneValue;
            this.valuationDisabled = result.valuationDisabled;
            this.borneDropdownShow = result.valuationDisabled == false ? true : false;
            this.valuerCategory = result.valuerCategory;
            this.productType = result.productType;

            if(this.productType == 'Tractor')
            {
                this.IsTractor = true;
            }
            checkIfReadOnly({ loanId: this.loanId, dealId: this.dealId}).then(result => {
              this.isReadOnly = result.readOnly;
              this.isReadOnlyola = result.readOnly;//Ola integration changes
              this.oppStage = result.stageName;
              if(this.currentStep == 'post-sanction' && this.oppStage == Loan_Stage_Additional_Documents){
                this.isReadOnly = true;
                this.isReadOnlyola = true;//Ola integration changes
              }
              if(this.currentStep == 'pre-disbursement' && this.oppStage == Loan_Stage_Additional_Documents){
                this.isReadOnly = true;
                this.isReadOnlyola = true;//Ola integration changes
              }
              if(this.borneValue == 'Customer'){
                this.valuationDisabled = true;
              }
             // this.isReadOnlyola = this.isReadOnly;//Ola integration changes
            }).catch(error => {
              console.error('error -- >', error);
            });

            getIHMDetails({ loanAppId: this.loanId, dealId: this.dealId })
              .then(result => {
                console.log('result getIHMDetails ', JSON.stringify(result));
                this.ihmDetails = result.iHMRec;
                this.finalTermDetails = result.finalTermRec;
                this._totalNonFundedInsAmo = result.totalNonFundedAmount;
                this._saAccountOpeningCharge = result.saAccountOpeningCharges;
                this.toalAmountPaidToBank = this.ihmDetails.toalAmountPaidToBank;
                this.loanAmtSanctionedFexclFundInsu = this.ihmDetails.loanAmtSanctionedFexclFundInsu;
                this.totalOtherCharges = result.saAccountOpeningCharges;
                this.totalEmiToConsider = result.finalTermRec.totalEmiToConsider;
                this.valuationFieldVisible = (result.iHMRec.vehicleType == 'Used' || result.iHMRec.vehicleType == 'Refinance') ? true : false;
                this._getTotalMarginDedDis = result.iHMRec.marginTobeDeducted;
                this._totalAmountToPaid = result.iHMRec.totalAmountToBeByG;
                this._toalNonFundedIns = result.iHMRec.totalNonfundedInsurance;
                this._totalNonFundedInsC = result.iHMRec.totalNonFundedInsC;
                this._totalOfAbovePay = result.iHMRec.totalOfAbovePayD;
                this._doesCustomerNeedToPay = result.iHMRec.customerNeedToPay;
                this._additionalAmountPaid = result.iHMRec.additionalIHMAmount;
                this.ihmRecoveryValue = result.iHMRec.ihmRecoveryValue;
                this.loadComponent = true;
                this.getTotalIHMpaidToDealer();
                this.totalIHMpaidToDealer = result.iHMRec.totalIHMpaidToDealer;

                if(this.IsTractor == true && this.valuationFieldVisible == true)
                { 
                    this.hideRecieptSectionForTractor = true;
                }

              })
              .catch(error => {
                console.error('error -- >', error);
              });

          }
        }).catch(error => {
          console.error('error -- > ', error);
        });
        this.getDocumentFilesFromApex();
      } else {
        this.validateWarningMessage = IHMWarningInvoice;
      }
    }).catch(error => {
      console.error(error);
    });
    if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    await getVehicleDetailsForIHMPage({loanAppId: this.loanId, dealId: this.dealId}).then(data =>{
      console.log('getVehicleDetailsForIHMPage',data);
      if(data){
        this.vehicleId = data?.Id;
        this.rcRetentionApplicable = data?.RC_retention_applicable__c;
        this.rcRetentionApplicableYes = this.rcRetentionApplicable == 'Yes' ? true: false;
        this.rcHoldAmount = data?.RC_Hold_Amount__c;
      }
    }).catch(error =>{
      console.log('getVehicleDetailsForIHMPage error',error);
    })
  
  }
 async renderedCallback(){
    if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    //Ola Integration changes
    await fetchLoanDetails({ opportunityId: this.loanId, dealId: this.dealId }).then(result => {
      this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
   }).catch(error=>{
    console.log(error);
   });

    //Ola Integration changes
    await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
    .then(data => {
        let fieldList = data?.Input_Labels__c!=null ? data?.Input_Labels__c?.split(';') : [];
    
        console.log(fieldList);
        if(fieldList.length>0 && this.leadSource != 'Hero'){//CISH-04
        this.isLoanAmountSanctionedexcelFundInsur = fieldList.includes('Loan amount sanctioned (F) - excl. funded insurance')? true :this.isLoanAmountSanctionedexcelFundInsur; 
        this.template.querySelector('lightning-input[data-id="IHM_Paid_To_Dealer"]').value = this.totalIHMpaidToDealer;//OLA-49 
        this.isReadOnlyola = fieldList.includes('Upload')? true : this.isReadOnlyola;//OLA-48
        this.isReadOnlyola = fieldList.includes('IHM reciept number')? true : this.isReadOnlyola;//OLA-48
        this.isReadOnlyola = fieldList.includes('IHM amount as per receipt')? true : this.isReadOnlyola;//OLA-48
        this.isReadOnlyola = fieldList.includes('Delete')? true : this.isReadOnlyola;//OLA-48
        this.isReadOnlyola = fieldList.includes('IHM receipt date')? true : this.isReadOnlyola;//OLA-48
        }
    }).catch(error => { 
    
    });
    //Ola Integration changes
  }
  disableEverything(){
      let allElements = this.template.querySelectorAll('*');
      allElements.forEach(element =>
          element.disabled = true
      );
  }//CISP-2735-END

  inputChangeHandler(event){
    if(event.target.name == 'borneField'){
      this.borneValue = event.target.value;
      if(this.borneValue == 'IBL'){
        this.valuationDisabled = false;
        this.ihmvaluationcharges = '';
      }else if(this.borneValue == 'Customer'){
        this.valuationDisabled = true;
        this.ihmvaluationcharges = 0;
      }
    }else if(event.target.name == 'ihmRecoveryField'){
      this.ihmRecoveryValue = event.target.value;
      this.calculateDisbursedAmount();
    }else if(event.target.name == 'valuationField'){
      this.ihmvaluationcharges = event.target.value;
      if(this.template.querySelector(`lightning-input[data-name="Margin_money_to_be_deducted_from_disburs__c"]`)){
        this.template.querySelector(`lightning-input[data-name="Margin_money_to_be_deducted_from_disburs__c"]`).value = this.getTotalMarginDedDis;
      }
    }
  }

  addRowDisabled = false;
  get disabledAddRow() {
    return this.documentsDetails.length >= 2 || this.isReadOnly;
  }

  handleInputChange() {
    let additionalAmtToPay = 0;
    this.template.querySelectorAll('lightning-input[data-id="cal-inputs"]').forEach(element => {
      if(element.name == 'AddtionalCal' && additionalAmtToPay == 0){
        additionalAmtToPay = Number(element.value);
      }else if(element.name == 'AddtionalCal'){
        additionalAmtToPay = additionalAmtToPay - Number(element.value);
        }
      });
      if(this.IsTractor){
        if(additionalAmtToPay == 0 ){
          this.template.querySelector('lightning-input[data-name="Additional_IHM_amount_to_be_paid__c"]').value = 0;
        this._additionalAmountPaid = 0;
        }
        else{
        this.template.querySelector('lightning-input[data-name="Additional_IHM_amount_to_be_paid__c"]').value = additionalAmtToPay;
        this._additionalAmountPaid = additionalAmtToPay;
        }
      }else{
        if(additionalAmtToPay < 0 ){
          this.template.querySelector('lightning-input[data-name="Additional_IHM_amount_to_be_paid__c"]').value = 0;
        this._additionalAmountPaid = 0;
        }
        else{
        this.template.querySelector('lightning-input[data-name="Additional_IHM_amount_to_be_paid__c"]').value = additionalAmtToPay;
        this._additionalAmountPaid = additionalAmtToPay;
        }
      }

      if(this.template.querySelector('lightning-input[data-name="Customer_need_to_pay_additional_amount__c"]')){
        this.template.querySelector('lightning-input[data-name="Customer_need_to_pay_additional_amount__c"]').value = additionalAmtToPay <= 0 ? 'No' : 'Yes';
        this.doesCustomerNeedToPay = additionalAmtToPay <= 0 ? 'No' : 'Yes';
      }
  }

  getDocumentFilesFromApex() {
    documentFiles({ loanAppId: this.loanId, dealId: this.dealId }).then(result => {
      this.documentsDetails = result;
      let ind = 1;
      this.documentsDetails.forEach(element => { element.index = ind++ });
      this.addRowDisabled = this.documentsDetails.length >= 2 ? true : false;
    }).catch(error => {
      console.error('error -- 678>' + error);
    });
  }

  indexCounter = 0;
  addRow(event) {
    this.indexCounter = this.documentsDetails.length + 1;
    var newItem = [{ Id: `${this.indexCounter}`, Is_IHM_Receipt_legible__c: false, index: this.indexCounter }];
    this.documentsDetails = this.documentsDetails.concat(newItem);
  }

  removeRow(event) {
    let documentId = event.currentTarget.dataset.id;

    deleteDocument({ documentId: documentId ,loanId : this.loanId, dealId: this.dealId}).then((result) => {
      if (result == true) {
        this.showNotification('Success', DeleteSuccessMsg, 'success');
        if (this.documentsDetails.length > 0) {
          let documentsDetails = this.documentsDetails.filter(item => item.Id != documentId);
          this.documentsDetails = documentsDetails;
          let ind = 1;
          this.documentsDetails.forEach(element => {
            element.index = ind++;
            if (element.Id == 1 || element.Id == 2) {
              element.Id = element.index;
            }
          });
          this.calcaulteIHMAmountHandler();
          this.getTotalIHMpaidToDealer();
        }
      }
    }).catch((error) => {
      console.error('error -- >', error);
    });
  }

  handleChange(event) {
    let documentId = event.currentTarget.dataset.id;
    let documentName = event.currentTarget.dataset.name;
    let documentValue = documentName == 'Is_IHM_Receipt_legible__c' ? event.currentTarget.checked : event.currentTarget.value;
    this.documentsDetails.forEach(element => {
      if (element.Id == documentId) {
        element[documentName] = documentValue;
      }
    });
    if(documentName == 'IHM_amount_as_per_receipt__c'){
      this.calcaulteIHMAmountHandler();
    }
    this.getTotalIHMpaidToDealer();
  }

  async calcaulteIHMAmountHandler(){
    try{
      let totalSum = 0;
        let elements = this.template.querySelectorAll(`lightning-input[data-name="IHM_amount_as_per_receipt__c"]`);
        await elements.forEach(element => {
          totalSum += Number(element.value);
        });
        this.totalIHMpaidToDealer = totalSum;
    }catch(error){
      console.log('error -- > ', error);
    }
  }

  getTotalIHMpaidToDealer() {
    setTimeout(() => {
      let totalSum = 0;
      let elements = this.template.querySelectorAll(`lightning-input[data-name="IHM_amount_as_per_receipt__c"]`);
      elements.forEach(element => {
        totalSum += Number(element.value);
      });
      this.template.querySelector(`lightning-input[data-id="IHM_Paid_To_Dealer"]`).value = totalSum;
      if(this.isReadOnly){
        this.totalIHMpaidToDealer = this.totalIHMpaidToDealer;
      }else{
        this.totalIHMpaidToDealer = totalSum;
        this.handleInputChange();
      }
    }, 1000);
    this.calculateDisbursedAmount();
  }

  changeFlagValue(event) {
    try {
      this.uploadIHMRecieptFlag = this.uploadIHMRecieptFlag == false ? true : false;
      if(event?.detail?.DocumentId){
        this.documentsDetails[this.previousIndex].Id = event?.detail?.DocumentId;
      }else if(!event.detail){
        this.documentsDetails[this.previousIndex].Id = this.previousDocumentId;
      }
      if (!event?.detail?.contentDocumentId) {
        deleteRecord(this.documentRecordId).then(() => {
          this.documentsDetails[this.previousIndex].Id = this.previousDocumentId;
          this.getTotalIHMpaidToDealer();
        }).catch(error => {
          console.error('error -123- >', error);
        });
      }
    } catch (error) {
      console.error('error -- >', error);
    }
  }

  previousDocumentId;
  previousIndex;
  openFileUploaderHandler(event) {
    let documentId = event.currentTarget.dataset.id;
    let index = event.currentTarget.dataset.index;
    let elements = this.template.querySelectorAll(`lightning-input[data-index="${index}"]`);
    this.template.querySelector(`lightning-button[data-index="${index}"]`).disabled = true;
    let allValueAreFilled = true;
    let requiredFields = '';
    let isFutureDate = false; 

    // Get today's date in the format YYYY-MM-DD
    const today = new Date().toISOString().split('T')[0];
    elements.forEach(element => {
      if (!element.disabled) {
        if (element.type == 'text' && element.value == '') {
          requiredFields = requiredFields + element.name + ', ';
          allValueAreFilled = false;
        } else if (element.type == 'date' && (element.value == null || element.value == '')) {
          requiredFields = requiredFields + element.name + ', ';
          allValueAreFilled = false;
        }
        //SFTRAC-428
        if(this.productType == 'Tractor' && element.type == 'date'){
          if (new Date(element.value) > new Date(today)) {

            isFutureDate = true; // Set the variable to true if element.value is greater than today
          }
          console.log('isVarTrue,', isFutureDate);
        }
      }
    });
    if (allValueAreFilled == false) {
      this.showNotification('Required', `${requiredFields} is missing`, 'warning');
      this.template.querySelector(`lightning-button[data-index="${index}"]`).disabled = false;
    } else if(isFutureDate == true){ //SFTRAC-428
      this.showNotification('IHM Receipt Date cannot be future date', 'warning');
      this.template.querySelector(`lightning-button[data-index="${index}"]`).disabled = false;
      return;
    }
    else if (allValueAreFilled == true) {
      this.previousIndex = index;
      if (documentId == '1' || documentId == '2') {
        this.insertNewDocument(index);
      } else {
        this.documentRecordId = documentId;
        this.previousDocumentId = documentId;
        this.insertNewDocument(index);
      }

    }
  }

  insertNewDocument(index) {
    const fields = {};
    fields.is_Active__c = true;
    fields.Document_Type__c = 'IHM Receipt';
    fields.IHM__c = this.ihmId;
    fields.Opportunity_Relation__c = this.loanId;
    fields.Applicant__c = this.applicantId;
    fields.RecordTypeId = this.recordTypeId;

    this.template.querySelectorAll(`lightning-input[data-id="${this.documentRecordId}"]`).forEach(element => {
      let fieldApiName = element.dataset.name;
      if (element.type == 'checkbox') {
        fields[`${fieldApiName}`] = element.checked;
      } else {
        fields[`${fieldApiName}`] = element.value;
      }
    });

    const recordInput = { fields };

    insertDocument({ documentString: JSON.stringify(recordInput), loanId : this.loanId, dealId: this.dealId }).then((result) => {
      if (result != null) {
        this.template.querySelector(`lightning-button[data-index="${index}"]`).disabled = false;
        this.documentRecordId = result;
        this.documentsDetails[index].Id = result;
        this.getTotalIHMpaidToDealer();
        this.openIHMRecieptModalHandler();

        const fields = {};
        fields['Id'] = this.documentRecordId;
        fields.IHM__c = this.ihmId;
        console.log('index :: ', index);
        this.template.querySelectorAll(`lightning-input[data-index="${index}"]`).forEach(element => {
          let fieldApiName = element.dataset.name;
          console.log('fieldApiName ', fieldApiName);
          if (element.type == 'checkbox') {
            fields[`${fieldApiName}`] = element.checked;
          } else {
            fields[`${fieldApiName}`] = element.value;
          }
        });
    
        const recordInput = { fields };

        updateRecord(recordInput).then(() => {
          console.log('updateRecord ');
        });
      }
    }).catch(error => {
      console.error('error -- >', error);
    });
  }

  openIHMRecieptModalHandler() {
    this.uploadIHMRecieptFlag = true;
    this.isAllDocType = this.isReadOnly == true ? true : false;
  }

  docUploadSuccessfully(event) {
    try {
      this.uploadIHMRecieptFlag = false;
      const fields = {};
      fields[`Id`] = this.documentRecordId;
      fields[`is_Active__c`] = true;

      const recordInput = { fields };

      updateRecord(recordInput).then(() => {
        this.updatePreviousDocument();
        this.getTotalIHMpaidToDealer();
      }).catch(error => {
        console.error('error -123- >', error);
        this.showNotification(`${ERROR}`, `${UPLOADFAILED}`, 'error');
      });
    } catch (error) {
      console.error('error -- >', error);
    }
  }

  updatePreviousDocument() {
    if (this.previousDocumentId != null && this.previousDocumentId != undefined && this.previousDocumentId != '') {
      const fields = {};
      fields['Id'] = this.previousDocumentId;
      fields['is_Active__c'] = false;

      const recordInput = { fields };

      updateRecord(recordInput).then(() => {
        console.log('Updated : ');
      });
    }
  }

  checkInput(inputParam){
    if(inputParam !== null && inputParam !== undefined && inputParam !== '' && inputParam !== NaN){
        return true;
    }
    else{
        return false;
    }
  }

  async submitCalculationHandler(event) {
    try {
      if(this.IsTractor && this.rcRetentionApplicableYes){
        if (this.rcHoldAmount < 10000 || this.rcHoldAmount > 100000 || isNaN(this.rcHoldAmount)) {
          this.showNotification('Error', 'Please enter RC Hold Amount between 10,000 and 100,000', 'error');
          return;
        }
      }
      let receiptNumberSet = new Set();
      let isReceiptNumberUnique = true;
      await this.template.querySelectorAll(`lightning-input[data-name="IHM_receipt_number__c"]`).forEach(element => {
           let receiptNumberval = element.value;
            if(receiptNumberSet.has(receiptNumberval)){
              isReceiptNumberUnique = false; 
              element.setCustomValidity('');       
              element.reportValidity();       
            }else {
              receiptNumberSet.add(receiptNumberval);
            } 
         });
      if(!isReceiptNumberUnique){
        this.showNotification('Warning','Please enter unique Receipt Number' ,'warning');
        return;
      }
      

      // CISP-2512 -START
      let elementVal = this.template.querySelector(`lightning-combobox[data-name="Valuation_Charges_Borne_By__c"]`);
      if(elementVal){
        if(!elementVal.validity.valid){
          this.showNotification('Required', ValuationBorneByMandatoryMsg, 'warning');
          return;
        }
      }
      // CISP-2512 - END
      if(this.isNewTwoWheeler){
        if(parseInt(this.totalIHMpaidToDealer) + parseInt(this.toalAmountPaidToBank)  != parseInt(this.getTotalAmountToPaid)){
          this.showNotification('Warning', IHM_TW_New_Validation_Error_Msg, 'warning');
          return;
        }
      }
      if(this.isUsedRefinancePV){
        let recoveryElement = this.template.querySelector(`lightning-input[data-name="IHM_Recovery__c"]`);
        var recovery = this.ihmRecoveryValue;
        var regularExpression = new RegExp('^[0-9]*$');
        if (!regularExpression.test(recovery) && recovery != '') {
          this.showNotification('', 'Please enter a valid IHM Recovery value.', 'warning');
          return;
        }
        if(!recoveryElement.validity.valid){
          this.showNotification('Required', Please_fill_all_the_mandatory_fields, 'warning');
          return;
        }
        let valuationElement = this.template.querySelector(`lightning-input[data-name="Valuation_charges_D__c"]`);
        if(!valuationElement.validity.valid){
          this.showNotification('', 'Please enter a valid Valuation Charges value.', 'warning');
          return;
        }
      }
      if(!this.isUsedRefinancePV && this._additionalAmountPaid > 0){
        this.showNotification('Warning', `Please request the customer to pay ${this._additionalAmountPaid} to the dealer/CFD. Please upload the receipt on this screen/fetch from procollect`, 'warning');
        return;
      }

      if(!this.isUsedRefinancePV && this._additionalAmountPaid < 0 && this.IsTractor){
        this.showNotification('Warning', `Total amount of IHM receipts should be match with Total amount to be paid by customer`, 'warning');
        return;
      }
  
      if(this.isUsedRefinancePV && !this.IsTractor){
        let totalIHMComputed = parseFloat(this.toalAmountPaidToBank == undefined ? 0 : this.toalAmountPaidToBank) + parseFloat(this.ihmRecoveryValue == undefined ? 0 : this.ihmRecoveryValue) + parseFloat(this.totalIHMpaidToDealer == undefined ? 0 : this.totalIHMpaidToDealer);
        if(totalIHMComputed < this.getTotalMarginDedDis){
          this.showNotification('Warning', IHMCOMPUTEDERRORMSG, 'warning');
          return;
        }
      }
      if(this.isUsedRefinancePV && this.IsTractor){
        let totalIHMComputed = parseFloat(this.toalAmountPaidToBank == undefined ? 0 : this.toalAmountPaidToBank) + parseFloat(this.ihmRecoveryValue == undefined ? 0 : this.ihmRecoveryValue) + parseFloat(this.totalIHMpaidToDealer == undefined ? 0 : this.totalIHMpaidToDealer);
        if(totalIHMComputed != this.getTotalMarginDedDis){
          this.showNotification('Warning', IHMCOMPUTEDERRORMSG, 'warning');
          return;
        }
      }
  
      let allValueAreFilled = true;
      let isDocumentsPresent = true;
      this.documentsDetails.forEach(element => {
        if (element?.IHM_receipt_number__c == '' || element?.IHM_receipt_date__c == '' || element?.IHM_amount_as_per_receipt__c == '') {
          allValueAreFilled = false;
        }
        if(element.Id == 1 || element.Id == 2 || !element.Id){
          isDocumentsPresent = false;
        }
      });
  
      if (!allValueAreFilled || !isDocumentsPresent){
        this.showNotification('Warning', `Please complete IHM Receipt section`, 'warning');
        return;
      }else{
        this.documentsDetails.forEach(element => {
          let fields = {};
          console.log('element.Id ', element.Id);
          fields['Id'] = element.Id;
          fields['IHM_receipt_number__c'] = element.IHM_receipt_number__c;
          fields['IHM_receipt_date__c'] = element.IHM_receipt_date__c;
          fields['IHM_amount_as_per_receipt__c'] = element.IHM_amount_as_per_receipt__c;
  
          let recordInput = { fields };
          updateRecord(recordInput).then(() => {
            console.log('UpdateRecord : ');
          });
        });
        let res = await getIHMDocumentsAmountSum({'loanId' : this.loanId, dealId: this.dealId});
        if(this.checkInput(res) && this.checkInput(this.totalIHMpaidToDealer) && parseInt(res) != parseInt(this.totalIHMpaidToDealer)){
          this.showNotification('Warning!', 'Please check the reciept details.', 'warning');
          return;
        }
        if(this.IsTractor){
          let fields = {};
          fields['Id'] = this.vehicleId;
          fields['RC_Hold_Amount__c'] = this.rcHoldAmount; 
          fields['RC_retention_applicable__c'] = this.rcRetentionApplicable;
          let  recordInput = { fields };
          updateRecord(recordInput).then(() => {
            console.log('UpdateRecord : ');
          });
        }
      }
  
      let comboBox = this.template.querySelector(`lightning-combobox[data-id="cvo-inputs"]`); //SFTRAC-1676
      const fields = {};
      fields['Id'] = this.ihmId;
      fields[`${comboBox.dataset.name}`] = comboBox.value == 'Yes' ? true : false; //SFTRAC-1676
      this.template.querySelectorAll(`lightning-input[data-id="cal-inputs"]`).forEach(element => {
        fields[`${element.dataset.name}`] = element.value;
      });
  
      const recordInput = { fields };
  
      await updateRecord(recordInput).then(() => {
        this.submitHandler(event);
      }).catch(error => {
        console.error('error --> ', error);
      });
    } catch (error) {
      console.log('error 626 ', error);
    }
  }

  submitCVOHandler(event) {
    try {
      if (this.documentsDetails[0] != null) {
        if (this.documentsDetails[0].Payment_Receipt_Remarks__c == '' || this.documentsDetails[0].Payment_Receipt_Remarks__c == undefined) {
          this.showNotification('', Please_fill_all_the_mandatory_fields, 'warning');
          return;
        } else {
          insertDocument({ documentString: JSON.stringify(this.documentsDetails[0]),loanId : this.loanId,dealId: this.dealId  }).then((result) => {
          }).catch(error => {
            console.error('error -- >', error);
          });
        }
      }
      if (this.documentsDetails[1] != null) {
        if (this.documentsDetails[1].Payment_Receipt_Remarks__c == '' || this.documentsDetails[1].Payment_Receipt_Remarks__c == undefined) {
          this.showNotification('', Please_fill_all_the_mandatory_fields, 'warning');
          return;
        } else {
          insertDocument({ documentString: JSON.stringify(this.documentsDetails[1]),loanId : this.loanId,dealId: this.dealId  }).then((result) => {
          }).catch(error => {
            console.error('error -- >', error);
          });
        }
      }
      let comboBox = this.template.querySelector(`lightning-combobox[data-id="cvo-inputs"]`);
      let inputField = this.template.querySelector(`lightning-input[data-id="cvo-inputs"]`);
      if(comboBox.value == '' || inputField.value == ''){
        this.showNotification('', Please_fill_all_the_mandatory_fields, 'warning');
        return;
      }
      if (comboBox.value == 'No') {
        updateLoanAppHistory({ loanId: this.loanId, dealId: this.dealId }).then((result) => {
          if (result == true) {
            console.log('Update Loan App History Successfully');
          }
        }).catch((error) => {
          console.error('error -- >', error);
        });
      }
      
      const fields = {};
      fields[`Id`] = this.ihmId;
      fields[`${comboBox.dataset.name}`] = comboBox.value == 'Yes' ? true : false;
      fields[`${inputField.dataset.name}`] = inputField.value;

      const recordInput = { fields };

      updateRecord(recordInput).then(() => {
        submitIHMRecord({ loanId: this.loanId, dealId: this.dealId }).then((result) => {
          if (result == true) {
            this.cvoEnabledField = true;
            this.showNotification('', SUBMITSUCCESSFULLY, 'success');
          }
        }).catch((error) => {
          console.error('error -- >', error);
        })
      });
    } catch (error) {
      console.error(error);
    }
  }

  fetchAmountHandler(event) {
    let loanApplicationId = this.loanId;
    let applicantId = this.applicantId;
    let dealId = this.dealId;

    doIHMReceiptCallout({ applicantId: applicantId,loanAppId: loanApplicationId, dealId: dealId }).then((result) => {
      let res = JSON.parse(result);
      if (res.response.status == 'SUCCESS') {
        this.showNotification('', FetchAmountSuccessMsg, 'success');
        this.toalAmountPaidToBank = res.response.content[0];
        if(!this.isUsedRefinancePV){
          this.template.querySelector('lightning-input[data-name="Total_amount_customer_paid_to_bank_E__c"]').value = res.response.content[0];
        }
        this.handleInputChange();
      } else {
        this.toalAmountPaidToBank -= 1;
        this.showNotification('Failed', Kindly_Retry, 'warning');
      }
    }).catch((error) => {
      console.error('error -- >', JSON.stringify(error));
      this.showNotification('', `${error.body.message}`, 'error');
    })
  }

  @api
  async submitHandler(event) {
    let value = this.template.querySelector(`lightning-input[data-name="Valuation_charges_D__c"]`) == null ? '' : this.template.querySelector(`lightning-input[data-name="Valuation_charges_D__c"]`).value;
    if (this.borneValue == 'IBL' && this.productType == PASSENGERVEHICLES && this.valuerCategory == 'Empanelled' && value <= parseInt('0')) {
      this.showNotification('', IHMVALUATIONCHARGESWARNING, 'warning');
      return;
    }
    var elements = this.template.querySelectorAll(`lightning-input[data-id="other-inputs"]`);
    const fields = {};
    fields[`Id`] = this.ihmId;
    elements.forEach(element => {
      fields[`${element.dataset.name}`] = element.value;
    });

    fields['Valuation_Charges_Borne_By__c'] = this.borneValue;
    if(this.isUsedRefinancePV){
      fields['Total_IHM_paid_to_dealer_A__c'] = this.totalIHMpaidToDealer;
    }

    const recordInput = { fields };

    updateRecord(recordInput).then((result) => {
      if (event != null) {
        submitIHMRecord({ loanId: this.loanId, dealId: this.dealId }).then((result) => {
          if (result == true) {
            this.showNotification('', SUBMITSUCCESSFULLY, 'success');
            this.isReadOnly = true;
            this.isReadOnlyola = true;//Ola integration changes
            this.dispatchEvent(new CustomEvent('iHMSubmitted'));
          }
        }).catch((error) => {
          console.error('error -- >', error);
        })
      }
      else {
        this.submitCalculationHandler(event);
      }
     // this.isReadOnlyola = this.isReadOnly;//Ola integration changes
    }).catch(error => {
      console.error('error -- >', error);
    })
  }

  hideModalBox() {
    this.isPreview = false;
  }
  
  handlePreview(event) {
    let contentDocId = event.currentTarget.dataset.id;
    getDocumentFiles({ contentDocId: contentDocId,loanId : this.loanId }).then(result => {
      if (result != null) {
        let conDocId = result;
        if(this.isCommunityUser == true){
          getContentVersion({ conDocId: conDocId })
            .then(result => {
              /*let fileType = result[0].FileType;
              if(result != null){
                this[NavigationMixin.Navigate]({
                  type: 'standard__webPage',
                  attributes: {
                    url : this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+ result[0].Id
                  }
              }, false );
              }*/
              this.converId = result[0].Id;
              this.isPreview = true;
            })
            .catch(error => {
              console.error('Error:', error);
          });
        }else{
          this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
              pageName: 'filePreview'
            },
            state: {
              selectedRecordId: result
            }
          });
        }
      }
    })
  }

  showNotification(title, message, varient) {
    const event = new ShowToastEvent({
      title: `${title}`,
      message: `${message}`,
      variant: `${varient}`,
      mode: 'dismissable'
    });
    this.dispatchEvent(event);
  }
  handleInputFieldChange(event) {
    const fieldName = event.target.name;
    if (fieldName === 'rcRetentionApplicableField') {
            this.rcRetentionApplicable = event.target.value;
            this.rcRetentionApplicableYes = this.rcRetentionApplicable == 'Yes' ? true: false;
            if(!this.rcRetentionApplicableYes){
              this.rcHoldAmount=null;
            }
    } else if(fieldName === 'rcHoldAmountField'){ //SFTRAC-1715 Start
              this.rcHoldAmount = event.target.value;
    }
  }

}