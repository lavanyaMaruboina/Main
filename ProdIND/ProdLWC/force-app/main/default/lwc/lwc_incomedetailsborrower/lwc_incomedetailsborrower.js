import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apex/PersonalDetailsforCAM.getincomeborrowerhome';
import getFiInfo from '@salesforce/apex/PersonalDetailsforCAM.getFiInfo';
import varientdet from '@salesforce/apex/PersonalDetailsforCAM.varientdetails';
import retriveFiles from '@salesforce/apex/PersonalDetailsforCAM.retriveFiles';
import { NavigationMixin } from 'lightning/navigation';
import fetchbankfields from '@salesforce/apex/PersonalDetailsforCAM.fetchbankdetails';
import getTFVehicleDetailIds from '@salesforce/apex/PersonalDetailsforCAM.getVehicleDetailRecordIdsTF'; // Added for SFTRAC : 92
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitrecabb from '@salesforce/apex/PersonalDetailsforCAM.submitborrowerecords';
import { updateRecord } from 'lightning/uiRecordApi';
//import { updateRecord } from 'lightning/uiRecordApi';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import OPPID_FIELD from '@salesforce/schema/Opportunity.Id';
import Sub_Stage from '@salesforce/schema/Opportunity.Sub_Stage__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi'; //CISP-7987
import { getObjectInfo } from 'lightning/uiObjectInfoApi';//CISP-7987 
import Relationship_with_borrower__c from '@salesforce/schema/Applicant__c.Relationship_with_borrower__c';//CISP-7987 
import Applicant__c from '@salesforce/schema/Applicant__c';//CISP-7987
import getDemographicDetails from '@salesforce/apex/Ind_Demographic.getDemographicDetailsForIncome';//CISP-7987
import Religion__c from '@salesforce/schema/Applicant__c.Religion__c';//CISP-19619
import Caste__c from '@salesforce/schema/Applicant__c.Caste__c';//CISP-19619
import GetLoanApplicantDetails from '@salesforce/apex/DealNumberCustomerCode.getLoanApplicantDetails';//CISP-19619
import doCustomerMasterCreationCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerMasterCreationCallout';//CISP-19619
import doCustomerMasterUpdationCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerMasterUpdationCallout';//CISP-19619
import updateApplicantCustomerCode  from '@salesforce/apex/DealNumberCustomerCode.updateApplicantCustomerCode';//CISP-19619
import pleaseRetry from '@salesforce/label/c.Please_Retry';//CISP-19619
import getRecentEMIdetails from '@salesforce/apex/InstallmentScheduleController.getRecentEMIdetails';
import Declaration_Content_Income_Details from '@salesforce/label/c.Declaration_Content_Income_Details';//CISP-20554
import Is_Borrower_Relative_Of_Director from '@salesforce/label/c.Is_Borrower_Relative_Of_Director';//CISP-20554
import Is_Borrower_Relative_Of_Senior_Officer from '@salesforce/label/c.Is_Borrower_Relative_Of_Senior_Officer';//CISP-20554
import Is_CoBorrower_Relative_Of_Director from '@salesforce/label/c.Is_CoBorrower_Relative_Of_Director';//CISP-20554
import Is_CoBorrower_Relative_Of_Senior_Officer from '@salesforce/label/c.Is_CoBorrower_Relative_Of_Senior_Officer';//CISP-20554
import Is_Relationship_With_IndusInd_Or_Other_Bank from '@salesforce/label/c.Is_Relationship_With_IndusInd_Or_Other_Bank';//CISP-20554
import Borrower_Relation_With_IndusInd_Question_1 from '@salesforce/label/c.Borrower_Relation_With_IndusInd_Question_1';//CISP-20554
import Borrower_Relation_With_IndusInd_Question_2 from '@salesforce/label/c.Borrower_Relation_With_IndusInd_Question_2';//CISP-20554
import Borrower_Relation_With_Other_Bank_Question_1 from '@salesforce/label/c.Borrower_Relation_With_Other_Bank_Question_1';//CISP-20554
import Borrower_Relation_With_Other_Bank_Question_2 from '@salesforce/label/c.Borrower_Relation_With_Other_Bank_Question_2';//CISP-20554
import CoBorrower_Relation_With_IndusInd_Question_1 from '@salesforce/label/c.CoBorrower_Relation_With_IndusInd_Question_1';//CISP-20554
import CoBorrower_Relation_With_IndusInd_Question_2 from '@salesforce/label/c.CoBorrower_Relation_With_IndusInd_Question_2';//CISP-20554
import CoBorrower_Relation_With_Other_Bank_Question_1 from '@salesforce/label/c.CoBorrower_Relation_With_Other_Bank_Question_1';//CISP-20554
import CoBorrower_Relation_With_Other_Bank_Question_2 from '@salesforce/label/c.CoBorrower_Relation_With_Other_Bank_Question_2';//CISP-20554
import BORROWER_RELATIVE_OF_DIRECTOR from '@salesforce/schema/Applicant__c.Is_Borrower_Relative_Of_Director__c';//cisp-20554
import BORROWER_RELATIVE_OF_SENIOR_OFFICER from '@salesforce/schema/Applicant__c.Is_Borrower_Relative_Of_Senior_Officer__c';//cisp-20554
import BORROWER_RELATION_WITH_INDUSIND_Q1 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_IndusInd_Q1__c';//cisp-20554
import BORROWER_RELATION_WITH_INDUSIND_Q2 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_IndusInd_Q2__c';//cisp-20554
import BORROWER_RELATION_WITH_OTHERBANK_Q1 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_Other_Bank_Q1__c';//cisp-20554
import BORROWER_RELATION_WITH_OTHERBANK_Q2 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_Other_Bank_Q2__c';//cisp-20554
import RELATION_WITH_INDUSIND_OR_OTHER from '@salesforce/schema/Applicant__c.Relationship_With_IndusInd_Or_Other_Bank__c';//cisp-20554
import getApplicantRelationshipWithBank from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getApplicantRelationshipWithBank';//CISP-20554
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';//CISP-20594
import validateFoir from '@salesforce/apex/Ind_ExistingEMICtrl.validateFoir';
import getPurposeOfPurchase from '@salesforce/apex/VehicleDetailsController.getPurposeOfPurchase'; // CISP -4486
export default class Lwc_incomedetailsborrower extends NavigationMixin(LightningElement) {
    uiLabel = {
        Declaration_Content_Income_Details,//CISP-20554
        Is_Borrower_Relative_Of_Director,//CISP-20554
        Is_Borrower_Relative_Of_Senior_Officer,//CISP-20554
        Is_CoBorrower_Relative_Of_Director,//CISP-20554
        Is_CoBorrower_Relative_Of_Senior_Officer,//CISP-20554
        Is_Relationship_With_IndusInd_Or_Other_Bank,//CISP-20554
        Borrower_Relation_With_IndusInd_Question_1,//CISP-20554
        Borrower_Relation_With_IndusInd_Question_2,//CISP-20554
        Borrower_Relation_With_Other_Bank_Question_1,//CISP-20554
        Borrower_Relation_With_Other_Bank_Question_2,//CISP-20554
        CoBorrower_Relation_With_IndusInd_Question_1,//CISP-20554
        CoBorrower_Relation_With_IndusInd_Question_2,//CISP-20554
        CoBorrower_Relation_With_Other_Bank_Question_1,//CISP-20554
        CoBorrower_Relation_With_Other_Bank_Question_2//CISP-20554
    }
    foirBtnDisbaled=false;
    isTw=false;
    activeSections = ['Income Details'];
    @api checkleadaccess;//coming from tabloanApplication
    @api recordid;
    @api offerengineparent = false;
    @track lstRecords = [];
    @api Bankrecords=[];
    @api CoBankrecords=[];
    @track banknameid;
    @track section;
    @track incomevalue;
    @track filesval;
    @track appId;
    @track coappId;
    @api usedInCommunity;
    @track finalTermId;
    @track varnew;
    @track varnewbool = false;
    @track filenotfound = false;
    @track changevarient = false;
    @track varusedbool = false;
    @track varrefinancebool = false;
    @track isShowModal=false;
    @track varused;
    @track varrefnce;
    @track okToProceed=false;
    @track remarkVal=false;
    @track abb=false;
    @track var;
    @track activeTab = 'Borrower';
    @track isCoborrowerTab = false;
    @track bankname;
    @track bankaccno;
    @track abbtoconsider;
    @track Cobankname;
    @track nonstpPV=false;
    @track Cobankaccno;
    @track Coabbtoconsider;
    @track submitclick = true;
    @track onchangeclick = false;
    @track rerunOEDisable=true;
    @track iconButtonengine;
    @track d2cCheck = false;
    @api substage=false;
    @track borrowerProfile;//CISP-2380
    @track co_borrowerProfile;//CISP-2380
    @track notValidTenure = false;
    productType;
    @track leadSource;//Ola Integration changes
    @track isTractorLead = false; // SFTRAC-92
    @track componentRendered = false;
    @track vehicleRecordIds = []; // SFTRAC-92
    @track isUsedTractorLead = false; // SFTRAC-92
    @track isNewTractorLead = false; // SFTRAC-92

    @track updatedORPAmount;
    relationshipWithBorrower;//CISP-7987 
    relationshipValue;//CISP-7987
    isPVProduct = false;//CISP-7987
    isModalOpen=false;
    isInsSubmitted=false;
    @track disableInsSchedule=false;
    @track isd2cLead=false;
    //CISP-19619 start
    toggleSpinner = false;
    coborrowerCodecreateStatus= false;
    borrowerCodecreateStatus= false;
    borrowerCodeUpdateStatus=false;
    coborrowerCodeUpdateStatus=false; @track isD2CLead =false;
    @track coBorrowerLoanApplicantDisabled = true;coCasteAndReligionDisable = false; casteAndReligionDisable=false;
    @track borrowerLoanApplicantDisabled = true;
    boolManageButtoncoBorr = true; coBorrCutomerCode ;religionValueForCo;casteValueForCo; coborrowerdistrict;
    boolManageButtonBorr=true; borrowerLoanApplicantId ;borrCutomerCode;toggleSpinner = false; borrowerdistrict ;religionValue;casteValue; religionValueCoBor;casteValueCoBor;
    declarationValue;//CISP-20554
    @track isCoBorrowerOptedYes;//CISP-20554
    @track isBorrowerOptedYes;//CISP-20554
    @track isBorrowerChosenIndusInd;//CISP-20554
    @track isBorrowerChosenOtherBank;//CISP-20554
    @track isCoBorrowerChosenIndusInd;//CISP-20554
    @track isCoBorrowerChosenOtherBank;//CISP-20554
    isBorrowerRelativeOfDirectorAnswer;//CISP-20554
    isBorrowerRelativeOfSeniorOfficerAnswer;//CISP-20554
    isCoBorrowerRelativeOfDirectorAnswer;//CISP-20554
    isCoBorrowerRelativeOfSeniorOfficerAnswer;//CISP-20554
    IsRelationshipWithIndusIndOrOtherBank;//CISP-20554
    IsBorrRelationshipWithIndusIndOrOtherBank;//CISP-20554
    IsCoBorrRelationshipWithIndusIndOrOtherBank;//CISP-20554
    BorrowerRelationWithIndusIndQuestion1Answer;//CISP-20554
    BorrowerRelationWithIndusIndQuestion2Answer;//CISP-20554
    BorrowerRelationWithOtherBankQuestion1Answer;//CISP-20554
    BorrowerRelationWithOtherBankQuestion2Answer;//CISP-20554
    CoBorrowerRelationWithIndusIndQuestion1Answer;//CISP-20554
    CoBorrowerRelationWithIndusIndQuestion2Answer;//CISP-20554
    CoBorrowerRelationWithOtherBankQuestion1Answer;//CISP-20554
    CoBorrowerRelationWithOtherBankQuestion2Answer;//CISP-20554

    get yesAndNoOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    get BankOptions() {
        return [
            { label: 'IndusInd Bank', value: 'IndusInd Bank' },
            { label: 'Other Bank', value: 'Other Bank' }
        ];
    }

    isFOIRModalOpen=false;
    handleFoirClick(){
        this.isFOIRModalOpen=true;
    }
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Religion__c }) religionStatus;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Caste__c }) casteStatus;
    // CISP-4486
    @wire(getPurposeOfPurchase, { opportunityId: '$recordid' })
    handleVehicleDetail({ error, data }) {
        if (data) {
            // Disable FOIR button if Purpose of Purchase is 'Commercial'
            this.purposeOfPurchase = data;
            if (data === 'Commercial') {
                this.foirBtnDisbaled = true;
            }
        } else if (error) {
            console.error('Error fetching vehicle detail: ', error);
        }
    }
    religionHandler(event) {
        this.religionValue = event.target.value;
    }
    casteHandler(event) {
        this.casteValue = event.target.value;
    }
    religionHandlerForCoBorrower(event){this.religionValueForCo = event.target.value;}
    casteHandlerForCoBorrower(event){this.casteValueForCo = event.target.value;}
    get generateBorrower(){ 
        console.log('inside generateBorrower');
        if(this.borrCutomerCode && this.boolManageButtonBorr && !this.borrowerCodecreateStatus){
            return 'Update Customer Code (Borrower)';
        }else{
            this.boolManageButtonBorr=false;
            return 'Generate Customer Code (Borrower)';
        }
    }
    //CISP-4263
    get generateCoBorrower(){
        console.log('inside generate Co Borrower');
        if(this.coBorrCutomerCode && this.boolManageButtoncoBorr && !this.coborrowerCodecreateStatus){
             return 'Update Customer Code (Co-Borrower) ';
        }
        else{
        this.boolManageButtoncoBorr= false;
        return 'Generate Customer Code (Co-Borrower) ';
    }
    }
    handleGenerateBorrowerCode() {
        //CISP-4263
         let customerMaster = doCustomerMasterCreationCallout;
        let isCustomerMaster=false;
        
        
        if (this.religionValue!= null && this.casteValue!= null && this.borrowerdistrict!= null) {
            this.toggleSpinner = true;
            console.log(this.borrowerdistrict);
            //CISP-4263
            if(this.borrCutomerCode){
                customerMaster=  doCustomerMasterUpdationCallout;
                isCustomerMaster=true;
            }
            customerMaster({
                    applicantId: this.borrowerLoanApplicantId,
                    loanAppId: this.recordid,
                    religion: this.religionValue,
                    caste: this.casteValue,
                    district: this.borrowerdistrict
                })
                .then((result) => {
                    if (result) {
                        if(result != 'Customer code is already created.') {//CISP-3799
                        var res = JSON.parse(result);
                        try{
                        if ((res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code) ||(this.borrCutomerCode && res.response.status =='SUCCESS')) {
                            if(!this.borrCutomerCode){
                            var borrowerCutomerCode = res.response.content[0].Customer_Code;
                            this.borrCutomerCode = borrowerCutomerCode;
                        }
                            updateApplicantCustomerCode({
                                loanApplicationId: this.recordid,
                                applicantId: this.borrowerLoanApplicantId,
                                customerCode: this.borrCutomerCode,
                                customerMasterStatus: isCustomerMaster,
                                customerCreationStatus: this.boolManageButtonBorr,
                                religion: this.religionValue,
                                caste: this.casteValue,
                            })
                            .then((result) => {
                                    this.borrowerLoanApplicantDisabled = true;
                                    this.borrowerCodeUpdateStatus=true;
                                    this.casteAndReligionDisable = true;
                            }).catch((error) => {
                                this.toggleSpinner = false;
                                console.log(error);
                                this.showToast('Borrower Customer Code !',error.body ? error.body.message : '','error');
                                this.borrowerLoanApplicantDisabled = false;
                            });
                        } else {
                            this.borrowerLoanApplicantDisabled = false;
                            this.showToast('Borrower Customer Code', pleaseRetry,'error');
                        }
                        }catch(err){
                            this.showToast('Borrower Customer Code', pleaseRetry,'error');
                            this.borrowerLoanApplicantDisabled = false;
                        }
                    } else {
                        this.showToast('Borrower Customer Code', pleaseRetry,'error');
                        this.borrowerLoanApplicantDisabled = false;
                    }
                    } else {
                        this.showToast('Borrower Customer Code', pleaseRetry,'error');
                        this.borrowerLoanApplicantDisabled = false;
                    }
                    this.toggleSpinner = false;
                }).catch((error) => {
                    this.toggleSpinner = false;
                    console.log(error);
                    this.showToast('Borrower Customer Code !',error.body ? error.body.message : '','error');
                    this.borrowerLoanApplicantDisabled = false;
                });
            
        } else {
            this.showToast('Borrower Customer Code', 'District/Religion/Caste values are missing','error');
            this.borrowerLoanApplicantDisabled = false;
        }
    }
    handleGenerateCoBorrowerCode(){
        let customerMaster = doCustomerMasterCreationCallout;
        let isCustomerMaster=false;
        if (this.religionValueForCo!= null && this.casteValueForCo!= null && this.coborrowerdistrict!= null) {
            this.toggleSpinner = true;
            console.log(this.coborrowerdistrict);
            //CISP-4263
            if(this.coBorrCutomerCode){
                customerMaster=  doCustomerMasterUpdationCallout;
                isCustomerMaster=true;
            }
            customerMaster({
                    applicantId: this.coBorrowerLoanApplicantId,
                    loanAppId: this.recordid,
                    religion: this.religionValueForCo,
                    caste: this.casteValueForCo,
                    district: this.coborrowerdistrict
                })
                .then((result) => {
                    if (result) {
                        if(result != 'Customer code is already created.') {//CISP-3799
                        var res = JSON.parse(result);
                        try{
                        if ((res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code) ||(this.borrCutomerCode && res.response.status =='SUCCESS')) {
                            if(!this.coBorrCutomerCode){
                                var coBorrowerCutomerCode = res.response.content[0].Customer_Code;
                                this.coBorrCutomerCode = coBorrowerCutomerCode;
                            }
                            updateApplicantCustomerCode({
                                loanApplicationId: this.recordid,
                                applicantId: this.coBorrowerLoanApplicantId,
                                customerCode: this.coBorrCutomerCode,
                                customerMasterStatus: isCustomerMaster,
                                customerCreationStatus: this.boolManageButtoncoBorr,
                                religion: this.religionValueForCo,
                                caste: this.casteValueForCo,
                            })
                            .then((result) => {
                                this.coBorrowerLoanApplicantDisabled = true;
                                this.coborrowerCodeUpdateStatus=true;
                                this.coCasteAndReligionDisable = true;
                                this.showToast('Success', 'Co-Borrower Customer Code Created/Updated Successfully', 'success');
                            }).catch((error) => {
                                this.toggleSpinner = false;
                                console.log(error);
                                this.showToast('Co-Borrower Customer Code', error.body ? error.body.message : '','error');
                                this.coBorrowerLoanApplicantDisabled = false;
                            });
                        } else {
                            this.coBorrowerLoanApplicantDisabled = false;
                            this.showToast('Co-Borrower Customer Code', pleaseRetry,'error');
                        }
                        }catch(err){
                            this.showToast('Co-Borrower Customer Code', pleaseRetry,'error');
                            this.coBorrowerLoanApplicantDisabled = false;
                        }
                    } else {
                        this.showToast('Co-Borrower Customer Code', pleaseRetry,'error');
                        this.coBorrowerLoanApplicantDisabled = false;
                    }
                    } else {
                        this.showToast('Co-Borrower Customer Code', pleaseRetry,'error');
                        this.coBorrowerLoanApplicantDisabled = false;
                    }
                    this.toggleSpinner = false;
                }).catch((error) => {
                    this.toggleSpinner = false;
                    console.log(error);
                    this.showToast('Co-Borrower Customer Code', error.body ? error.body.message : '','error');
                    this.coBorrowerLoanApplicantDisabled = false;
                });
            
        } else {
            this.showToast('Co-Borrower Customer Code', 'District/Religion/Caste values are missing','Error');
            this.borrowerLoanApplicantDisabled = false;
        }
    }
    showToast(title, message, variant){
        const toastevent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant

        });
        this.dispatchEvent(toastevent);
    }   //CISP-19619 end  
    @wire(getRecords, { opp: '$recordid' }) wiredTabs(value) {
        const {
            data,
            error
        } = value;
        if (data) {
            for (let key in data) {

                if (key == 'Borrower') {
                    this.appId = data[key];
                }
                if (key == 'Co-borrower') {
                    this.coappId = data[key];
                    this.isCoborrowerTab = true;
                } if (key == 'journey') {
                    this.nonstpPV = true;
                }
                if(key=='substage'){
                    this.substage=true;
                    this.disableInsSchedule=false;
                }
                if(key=='D2C'){
                    this.nonstpPV=false;
                    console.log('here in  D2c'+this.nonstpPV);
                }
                if (key == 'error') {

                }
                //CISP-2380
                if(key == 'BorrowerProfile'){
                    this.borrowerProfile = data[key];
                }
                if(key == 'Co-borrowerProfile'){
                    this.co_borrowerProfile = data[key];
                }
                //CISP-2380
            }
            // this.Make=lstRecords.value(Make__c);
        }
        else {
            // console.log(error);
            this.lstRecords = [];
        }
    }
    //CISP-2735
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    @api isRevokedLoanApplication;//CISP-2735
    @track fiInfo = new Object();
    @track isNonIndividual = false;
    get isNonIndividualTractorBorrower() {
        return this.isTractorLead && this.isNonIndividual && this.appId; 
    }

    @wire(getObjectInfo, { objectApiName: Applicant__c }) objectInfo;//CISP-7987
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Relationship_with_borrower__c }) relationshipWithBorrower;//CISP-7987

    //CISP-19619 start
    async getLoanApplicantDetailsHandler(){
        await GetLoanApplicantDetails({loanApplicationId : this.recordid}).then(data =>{
            if (data) {
                console.log('dtaa ----',data);
                for (let applicant of data) {
                    if (applicant.Applicant_Type__c.includes('Borrower')) {
                        this.boolManageButtonBorr = true;
                        this.borrowerLoanApplicantId = applicant.Id;
                        this.borrowerCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;
                        this.borrowerCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;
                        this.borrowerLoanApplicantDisabled =this.borrowerCodeUpdateStatus || this.borrowerCodecreateStatus ? true: false
                        this.casteAndReligionDisable = this.borrowerCodeUpdateStatus || this.borrowerCodecreateStatus ? true: false;
                        if (applicant?.Customer_Code__c) {
                            this.borrCutomerCode = applicant.Customer_Code__c;
                        }
                        if (applicant?.Customer_Dedupe_Response__r) {
                            for (let res of applicant.Customer_Dedupe_Response__r) {
                                if (res.Customer_Code__c) {
                                    this.borrCutomerCode = res.Customer_Code__c;
                                }
                            }
                        }
                        if (applicant?.Documents__r) {
                            for (let res of applicant.Documents__r) {
                                console.log(res);
                                    if(res.KYC_District__c){
                                        this.borrowerdistrict = res.KYC_District__c;
                                    }
                                }
                            console.log(this.borrowerdistrict);
                        }
                        if(applicant?.Religion__c){
                            this.religionValue = applicant.Religion__c;
                        }
                        if(applicant?.Caste__c){
                            this.casteValue = applicant.Caste__c;
                        }
                    }
                    else if (applicant.Applicant_Type__c.includes('Co-borrower')) {
                        this.coBorrowerLoanApplicantId = applicant.Id;
                        this.boolManageButtoncoBorr = true;
                        this.coborrowerCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;
                        this.coborrowerCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;
                        this.coBorrowerLoanApplicantDisabled=this.coborrowerCodeUpdateStatus || this.coborrowerCodecreateStatus? true: false
                        this.coCasteAndReligionDisable = this.coborrowerCodeUpdateStatus || this.coborrowerCodecreateStatus? true: false;
                        this.isCoborrowerExists = true;
                        if (applicant?.Customer_Code__c) {
                            console.log(applicant.Customer_Code__c);
                            this.coBorrCutomerCode = applicant.Customer_Code__c;
                        }
                        if (applicant?.Customer_Dedupe_Response__r) {
                            for (let res of applicant.Customer_Dedupe_Response__r) {
                                if (res.Customer_Code__c) {
                                    console.log(res.Customer_Code__c);
                                    this.coBorrCutomerCode = res.Customer_Code__c;
                                }
                            }
                        }
                        if (applicant.Documents__r) {
                            for (let res of applicant.Documents__r) {
                                    if(res.KYC_District__c){
                                        this.coborrowerdistrict = res.KYC_District__c;
                                    }
                            }
                        }
                        if(applicant.Religion__c){
                            this.religionValueForCo = applicant.Religion__c;
                        }
                        if(applicant.Caste__c){
                            this.casteValueForCo = applicant.Caste__c;
                        }
                    }
                    this.dataUpdated = true;
                }}
        }).catch(error =>{
            console.log('error in retriveFiles GetLoanApplicantDetails=>', error);
        })
    }//CISP-19619 end
async connectedCallback(){
    try{
    await getRecentEMIdetails({loanId:this.recordid}).then((data)=>{
        if(data && data.length>0){
            this.disableInsSchedule = false;
        }else{
            this.disableInsSchedule = true;
        }
        }).catch((error) => { console.log('error in getRecentEMIdetails ',error);});
    await getFiInfo({oppId : this.recordid})
        .then(data => {
            this.fiInfo = data;
        }).catch(error =>{
            console.log('error in retriveFiles =>', error);
        });
    await this.getLoanApplicantDetailsHandler();    
//CISP-7987 start
    await getDemographicDetails({opportunityId: this.recordid, applicantType: 'Co-borrower' })
          .then(result => {
            console.log('Result getDemographicDetails', result);
            if(result){
            this.relationshipValue = result.applicantRecord?.Relationship_with_borrower__c;
            this.isPVProduct = result.applicantRecord?.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ? true : false;
            if(result.applicantRecord?.Opportunity__r.Product_Type__c != 'Tractor'){
                this.componentRendered = true;
            }//CISP-19769
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });//CISP-7987 end

        console.log('used or new',this.substage);
        await getRecords({opp : this.recordid})
        .then(data => {
            console.log('file id in retriveFiles => ', data);
            if(data !== null){
                for (let key in data) {
                    if (key == 'journey') {
                        this.nonstpPV = true;
                    }
                    //CISP-2380
                    if(key == 'BorrowerProfile'){
                        this.borrowerProfile = data[key];
                    }
                    if(key == 'Co-borrowerProfile'){
                        this.co_borrowerProfile = data[key];
                    }
                    //CISP-2380
                    // D2C_CHANGE - Raman
                    if(key == 'd2cCheck' && data[key] == 'true'){
                        this.d2cCheck = true;
                    }
                    // EO D2C_CHANGE
                    if(key=='substage'){
                        this.substage=true;
                        this.disableInsSchedule=false;
                        console.log('used or new',this.substage);
                        let allElements = this.template.querySelectorAll('*');
                        allElements.forEach(element =>{
                            if(element.name && element.name==='amortSchedule'){
                                element.disabled = false;}else{element.disabled = true;}
                        });
                     
                        this.template.querySelector('c-lwc_incomeloanoffer').disableEverything();
                     if(this.varnewbool){
                        this.template.querySelector('c-l-W-C_Incomedetails-Varient').disableEverything();
                     }
                    }
                    }
        }
    })
    .catch(error =>{
        console.log('error in retriveFiles =>', error);
    });
        
        if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
            const evt = new ShowToastEvent({
             title: ReadOnlyLeadAccess,
             variant: 'warning',
             mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
            let allElements = this.template.querySelectorAll('*');
      allElements.forEach(element =>
       element.disabled = true
         );
            }

        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
        await fetchLoanDetails({ opportunityId: this.recordid }).then(result => {
            this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
            this.productType = result?.loanApplicationDetails[0]?.Product_Type__c;
            if(this.leadSource =='D2C'){
                this.isd2cLead = true;
                this.disableInsSchedule=true;
                if(!this.substage){this.disableInsSchedule=true;}
            }
            this.isTw = result?.loanApplicationDetails[0]?.Product_Type__c == 'Two Wheeler' ? true : false;
            this.isPVProduct = result?.loanApplicationDetails[0]?.Product_Type__c == 'Passenger Vehicles' ? true : false;
            if(this.leadSource=='OLA'){
                this.onchangeclick=true;
                this.changevarient=true;
                this.submitclick = false;
            }
            /*SFTRAC-92 : Start*/
            if(this.productType == 'Tractor'){
                this.isNonIndividual = result?.loanApplicationDetails[0]?.Customer_Type__c == 'Non-Individual';
                if(result.loanApplicationDetails && result.loanApplicationDetails.length > 0 && result.loanApplicationDetails[0].Vehicle_Type__c == 'New'){
                    console.log('isNewTractorLead<<>>')
                    this.isNewTractorLead = true;
                    this.isUsedTractorLead = false;
                }else if(result.loanApplicationDetails && result.loanApplicationDetails.length > 0 && (result.loanApplicationDetails[0].Vehicle_Type__c == 'Used' || result.loanApplicationDetails[0].Vehicle_Type__c == 'Refinance')){
                    console.log('isUsedTractorLead<<>>')
                    this.isUsedTractorLead = true;
                    this.isNewTractorLead = false;
                }
                getTFVehicleDetailIds({opp : this.recordid}).then(result => {
                    console.log('result of getTFVehicleDetailIds> '+JSON.stringify(result));
                    if(result){
                        this.vehicleRecordIds = result;
                        this.isTractorLead = true;
                        this.componentRendered = true;
                    }else{
                        console.log('something went wrong white fetching asset details')
                    }
                }).catch(error=>{
                    this.componentRendered = true;
                });
            }else{
                this.componentRendered = true;
                // checkCibilflag({loanApplicationId: this.recordid})
                // .then(res=>{
                //     if(res===1){
                //         this.rerunOEDisable=false;
                //         this.onchangeclick=true;
                //         this.changevarient = true; // Added by Abhishek CISP-4726
                //         this.isCibilCalledInLtwo = true; // Added by Abhishek CISP-4726
                //     }
                //     else if(res===2){
                //         this.rerunOEDisable=true;
                //         this.onchangeclick=false;
                //         this.changevarient = false; // Added by Abhishek CISP-4726
                //     }
                // })
                // .catch(err=>{
                //     console.error('err-->'+JSON.stringify(err));
                // });
            }
            /*SFTRAC-92 : End*/
        }).catch(error=>{
            this.componentRendered = true;
        });
        //CISP-4416
        this.doGetApplicantRelationshipWithBank();
    }catch(error){
        this.componentRendered = true;
    }
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
         element.disabled = true
           );  
    }
    handleSectionToggle(event) {
        this.section = event.detail.openSections;
    }
    @wire(varientdet, { opp: '$recordid' }) fetchData(value) {
        const {
            data,
            error
        } = value;
        if (data) {

            if (data == 'new' || data == 'New' || data == 'NEW') {
                this.varnew = data;
                this.varnewbool = true;
                this.changevarient = false;
            } else if (data == 'used' || data == 'Used' || data == 'USED') {
                //console.log('used or new',data);
                this.varused = data;
                this.varusedbool = true;
                this.changevarient = true;
            }else if (data == 'refinance' || data == 'Refinance' || data == 'REFINANCE') {
                //console.log('used or new',data);
                this.varrefnce = data;
                this.varrefinancebool = true;
                this.changevarient = true;
            } else {
                this.var = '';
            }
            // this.Make=lstRecords.value(Make__c);
        }
        else if (error) {
            //console.log(error);
            this.lstRecords = [];
        }
    }
    
    handleMainActiveTab(event) {
        this.activeTab = event.target.value;
    }
    async onsubmit() {
        this.submitclick = true;
        this.onchangeclick = false;
        if(this.leadSource=='OLA'){
            const oppFields = {};
            oppFields[OPPID_FIELD.fieldApiName] = this.recordid;
            oppFields[Sub_Stage.fieldApiName] = 'Final Terms';
            if(this.updateRecordDetails(oppFields)){window.location.reload();};
        } else
        if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.leadSource != 'D2C') {
            const lwcCompLoanamountTw = this.template.querySelector('c-lwc_incomeloanoffer');//CISP-16686 start
            const results = await lwcCompLoanamountTw.validateLoanamountTw();
            console.log('test---1'+results);
            if(results){
                 return;
                }else{window.location.reload();}//CISP-16686 end
            }else{
                window.location.reload();
            }    
    }

    @api handle_valuechange(event) {
        this.submitclick = false;
        this.onchangeclick = true;
    }
    handle_changebutton(event) {
        this.template.querySelector('c-l-W-C_Incomedetails-Varient').handle_ChangeVar();
        this.template.querySelector('c-lwc_incomeloanoffer').disabledOfferScreen();
    }
    handle_offer_Text_Click(event) {
        if(this.notValidTenure){
            const event = new ShowToastEvent({
                title: 'Error',
                message : 'Tenure is required. Please enter value multiple of 6',
                variant: 'error',
            });
            this.dispatchEvent(event); 
        }else if(!this.isTractorLead && !this.isInsSubmitted && !this.isd2cLead && !this.disableInsSchedule){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Submit Installment Schedule first',
                variant: 'warning'
            });
            this.dispatchEvent(event);
            return;
        }else{
        console.log('check');
        this.template.querySelector('c-lwc_incomeloanoffer').callcreateFinalTermRecord();
        // this.template.querySelector('c-lwc_incomeloanoffer').handleButtonClick(); 
        }
    }

    handle_offer_Text_Clickoffer(event) {
        console.log('check', event.detail);
        this.offerengineparent = true;
        if(this.productType == 'Tractor'){
            this.template.querySelector('c-lwc_incomeloanoffer').handleTFOfferEngineCalloutHelper();
        }else{
            this.template.querySelector('c-lwc_incomeloanoffer').calldoOfferEngineCalloutoffer(event.detail);
        }
    }

    handle_offer_Text_ClickofferVarient(event) {
        console.log('check', event.detail);
        if(this.productType == 'Tractor'){
            this.template.querySelectorAll('c-lwc_incomeloanoffer')[event.detail.index].handleTFOfferEngineCalloutHelper(event.detail.loanAmount);
        }else{
            this.template.querySelector('c-lwc_incomeloanoffer').calldoOfferEngineCalloutVarient(event.detail);
        }
    }
    

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        //console.log('before update ', recordInput);
        await updateRecord(recordInput)
            .then(() => {
                const event = new ShowToastEvent({
                    title: 'Record Updated',
                    variant: 'Success',
                });
                this.dispatchEvent(event);
                 return true;
            })
            .catch(error => {
                //console.log('record update fail in catch', JSON.stringify(fields));
                //console.log('record update Fields: ', fields);
                //console.log('record update error', error);
            });
    }

    previewImage(event) {
        console.log('income record id => ',event.target.dataset.id);
        retriveFiles({incomeObjId : event.target.dataset.id})
        .then(result => {
            console.log('file id in retriveFiles => ', result);
            if(result !== null){
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state: {
                        selectedRecordId: result
                    }
                });
            }else{
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message : 'No bank statement is available for this income source.',
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
        })
        .catch(error =>{
            console.log('error in retriveFiles =>', error);
        })
    }
    
    async handleacceptloan(event) {
        //CISP-19619 start
        if(this.leadSource == 'D2C'){
            if(this.borrowerCodecreateStatus !=true && this.borrowerCodeUpdateStatus != true){
                this.showToast('Error','Please Generate/Update Customer for Borrower');
                return;
            }else if(this.isCoborrowerTab && this.coborrowerCodeUpdateStatus !=true && this.coborrowerCodecreateStatus != true){
                this.showToast('Error','Please Generate/Update Customer for Co-borrower');
                return;
            }
        }//CISP-19619 end
        if(this.productType == 'Passenger Vehicles'){
            const lwcCompLoanamount = this.template.querySelector('c-lwc_incomeloanoffer');//CISP-7754 start
            const results = await lwcCompLoanamount.validateLoanamount(); 
            console.log('test---1'+results);
            if(results){
                 return;
                }
                }//CISP-7754 end
                if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.leadSource != 'D2C') {
                    const lwcCompLoanamountTw = this.template.querySelector('c-lwc_incomeloanoffer');//CISP-16686 start
                    const results = await lwcCompLoanamountTw.validateLoanamountTw();
                    if(results){
                         return;
                        }
                    }//CISP-16686 end
        //event.preventDefault();
        if(this.productType != 'Tractor' &&  this.leadSource != 'D2C'  && this.purposeOfPurchase != 'Commercial'){
                let validBool = false;
                 await validateFoir({oppId: this.recordid }).then(response => {
                    console.log('validateFoir__'+JSON.stringify(response));
                    if(response?.borrowerAllowed === 'false'){
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message : 'Calculate FOIR for the Borrower',
                            variant: 'error',
                        });
                        this.dispatchEvent(event); 
                        //this.showSpinner = false;
                        validBool =  false;
                    } else if(response?.coBorrowerAllowed === 'false'){
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message : 'Calculate FOIR for the Co-borrower',
                            variant: 'error',
                        });
                        this.dispatchEvent(event); 
                        validBool = false;
                    }else{
                       // this.showSpinner = false;
                        validBool = true;
                    }
                }).catch(error => {
                    console.error('error in validateFOIR =>', error);
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message : 'Error in validating FOIR',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                    validBool = false;
                });
                console.log('validateFoir__bool'+validBool);
            // const foirCmp = this.template.querySelector('c-i-n-d-_-l-w-c-_-run-e-m-i-engine');
            // const foirResults = await foirCmp.validateFOIR();
            if(!validBool){
                // const event = new ShowToastEvent({
                //     title: 'Error',
                //     message : 'Calculate FOIR for the applicants',
                //     variant: 'error',
                // });
                // this.dispatchEvent(event); 
                return ;
            }
        }
        if(this.notValidTenure){
            const event = new ShowToastEvent({
                title: 'Error',
                message : 'Tenure is required. Please enter value multiple of 6',
                variant: 'error',
            });
            this.dispatchEvent(event); 
        }else{
        if(this.rerunOEDisable){
            const lwcComp = this.template.querySelector('c-lwc_incomeloanoffer');
            const result = await lwcComp.validateEmiAndMD(); 
            const result2 = await lwcComp.validateORPAmount(); 
            const resCRMIRR = await lwcComp.validateCRMIRRAmount();//CISP-19529
            const result3 = await lwcComp.validateNetIRRAmount();//CISP-5450
            const isPanValid = await lwcComp.getDocumentsToCheckPanValid();//CISP-3938
            if(!result2){ return; }
            if(!resCRMIRR){ return; } //CISP-19529
            if(!result3){ return; }//CISP-5450
            if(!isPanValid) {return ;}
            console.log('result of validation method=>', result);
            if(result){
                const lwcCompCRM = this.template.querySelector('c-lwc_incomeloanoffer');//Start CISP-2702
                const response = await lwcCompCRM.validateCRMIRR(); 
                console.log('response1',response);
                if (response) {
                    console.log('response2',response);
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message : 'CRM IRR is not within permissible range. Please change Loan amount / EMI / Tenure to proceed',
                        variant: 'error',
                    });
                    this.dispatchEvent(event); 
                    lwcCompCRM.enabledOfferScreen();
                } else {
                    const lwcComp = this.template.querySelector('c-lwc_incomeloanoffer');
                    const result = await lwcComp.validateCallType(); 
                    if(result){
                    const name = 'Income';
                    const selectEvent = new CustomEvent('finaltermsevent', { detail: name });
                    this.dispatchEvent(selectEvent, { bubbles: true, composed: true });
                    this.disableEverything();
                    window.location.reload();
                    }
                    else{
                        //Calling Call Type 1/4 only if Falied In L1 part Journey.
                        this.template.querySelector('c-lwc_incomeloanoffer').calldoOfferEngineCalloutoffer(event.detail);
                    }//End CISP-2702
                }
            }
            else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message : 'Select either advance emi or moratorium days > 0',
                    variant: 'error',
                });
                this.dispatchEvent(event); 
            }
        }else if(!this.isTractorLead && !this.isInsSubmitted && !this.d2cCheck){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Submit Installment Schedule first',
                variant: 'warning'
            });
            this.dispatchEvent(event);
            return;
        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message : 'Click on rerun offer engine',
                variant: 'error',
            });
            this.dispatchEvent(event); 
        }
        }
    }

    handleEnableReRunBtn(){
        this.rerunOEDisable = false;
        if(this.template.querySelector('button[name=rerunbtn]')){
            this.template.querySelector('button[name=rerunbtn]').disabled = false;
        }
    }

    enableReRun(){
        this.rerunOEDisable=false;

    }
    disableReRun()
    {
        this.rerunOEDisable=true;
        this.iconButtonengine=true;
    }
    disableReRunAfterIrrvalue()//CISP-19529
    {
        this.onchangeclick=false;
        this.rerunOEDisable=true;
    }
    handleDisableReRun(){//Start CISP-2646
        try {
            this.rerunOEDisable=true;
            this.enableaccept();
        } catch (error) {
            console.error('1', error);
        }
    }
    handleEnableReRun(){
        try {
            this.enableReRun();
            this.disableaccept();
        } catch (error) {
            console.error('2', error);
        }
    }//End CISP-2646
    handleincChange(event){
        this.submitclick=false;
        this.onchangeclick = true;
}

parentmethoddisableds(event)
{
    if(this.productType == 'Tractor' && this.template.querySelectorAll('c-lwc_incomeloanoffer')[event.detail.index]){
        this.template.querySelectorAll('c-lwc_incomeloanoffer')[event.detail.index].disabledOfferScreen();
    }else{
        this.template.querySelector('c-lwc_incomeloanoffer').disabledOfferScreen();
    }
}
saveVarientHandler(event)
{
    if(this.productType == 'Tractor' && this.template.querySelectorAll('c-l-W-C_Incomedetails-Varient')[event.detail.index]){
        this.template.querySelectorAll('c-l-W-C_Incomedetails-Varient')[event.detail.index].saveVarientDetails();
    }
}

disableaccept()
{
    this.onchangeclick = true;
}
enableaccept(){
    this.onchangeclick = false;
}
handlefailedofferengine(){// Start CISP-60
    this.template.querySelector('c-l-W-C_Incomedetails-Varient').handleFailedOfferEngine();
}//End CISP-60
handleNotValidTenure(){
    this.notValidTenure = true;
}
handleValidTenure(){
    this.notValidTenure = false;
}

    updateORPAmountHandler(event){
        if(event.detail){
            this.updatedORPAmount = parseInt(event.detail);
        }
    }
handleFoirClose(){this.isFOIRModalOpen=false;
}
//SFTRAC-1200
@track updateofferlabel;
updateofferAccordionlabelHandler(event){
    if(this.productType == 'Tractor'){
        this.template.querySelectorAll('c-lwc_incomeloanoffer')[event.detail.index].handlehandleAccordionLabel(event.detail.accordionLabelChange);
    }
}
//CISP-20594 - START
handleBorrowerRelativeOfDirector(event)
{
    this.isBorrowerRelativeOfDirectorAnswer = event.target.value;
    if(event.target.value == 'Yes')
    this.isBorrowerOptedYes = true;
    else
    {
        if(this.isBorrowerRelativeOfSeniorOfficerAnswer == null || this.isBorrowerRelativeOfSeniorOfficerAnswer == undefined || this.isBorrowerRelativeOfSeniorOfficerAnswer == 'No')
        this.isBorrowerOptedYes = false;
    }
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.borrowerLoanApplicantId;
    applicantsFields[BORROWER_RELATIVE_OF_DIRECTOR.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}
handleRelationWithIndusIndOrOther(event)
{
    this.IsRelationshipWithIndusIndOrOtherBank = event.target.value;
    
        if(event.target.value == 'IndusInd Bank')
        {
            this.isBorrowerChosenOtherBank = false;
            this.isBorrowerChosenIndusInd = true;
        }
        else
        {
            this.isBorrowerChosenIndusInd = false;
            this.isBorrowerChosenOtherBank = true;
        }        
    
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.borrowerLoanApplicantId;
    applicantsFields[RELATION_WITH_INDUSIND_OR_OTHER.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}
handleBorrowerIndusIndQ1(event)
{
    this.BorrowerRelationWithIndusIndQuestion1Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.borrowerLoanApplicantId;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = event.target.value;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.BorrowerRelationWithOtherBankQuestion1Answer = null;
    this.BorrowerRelationWithOtherBankQuestion2Answer = null;
}
handleBorrowerOtherQ1(event)
{
    this.BorrowerRelationWithOtherBankQuestion1Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.borrowerLoanApplicantId;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = event.target.value;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.BorrowerRelationWithIndusIndQuestion1Answer = null;
    this.BorrowerRelationWithIndusIndQuestion2Answer = null;
}
handleBorrowerIndusIndQ2(event)
{
    this.BorrowerRelationWithIndusIndQuestion2Answer = event.target.value;;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.borrowerLoanApplicantId;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = event.target.value;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.BorrowerRelationWithOtherBankQuestion1Answer = null;
    this.BorrowerRelationWithOtherBankQuestion2Answer = null;
}
handleBorrowerOtherQ2(event)
{
    this.BorrowerRelationWithOtherBankQuestion2Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.borrowerLoanApplicantId;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = event.target.value;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.BorrowerRelationWithIndusIndQuestion1Answer = null;
    this.BorrowerRelationWithIndusIndQuestion2Answer = null;
}
handleBorrowerReletiveOfSeniorOfficer(event)
{
    this.isBorrowerRelativeOfSeniorOfficerAnswer = event.target.value;
    if(event.target.value == 'Yes')
    this.isBorrowerOptedYes = true;
    else
    {
        if(this.isBorrowerRelativeOfDirectorAnswer == null || this.isBorrowerRelativeOfDirectorAnswer == undefined ||this.isBorrowerRelativeOfDirectorAnswer == 'No')
        this.isBorrowerOptedYes = false;
    }
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.borrowerLoanApplicantId;
    applicantsFields[BORROWER_RELATIVE_OF_SENIOR_OFFICER.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}

    async doGetApplicantRelationshipWithBank(){
        if(this.isCoborrowerTab)
        {
            await getApplicantRelationshipWithBank({applicantId : this.coBorrowerLoanApplicantId}).then(result =>{  
                if(result)  
            {  
                this.isCoBorrowerRelativeOfDirectorAnswer = result.Is_CoBorrower_Relative_Of_Director__c;
                this.isCoBorrowerRelativeOfSeniorOfficerAnswer = result.Is_CoBorrower_Relative_Of_Senior_Officer__c;
                this.IsCoBorrRelationshipWithIndusIndOrOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c;
                this.CoBorrowerRelationWithIndusIndQuestion1Answer = result.CoBorrower_Relation_With_IndusInd_Q1__c;
                this.CoBorrowerRelationWithIndusIndQuestion2Answer = result.CoBorrower_Relation_With_IndusInd_Q2__c;
                this.CoBorrowerRelationWithOtherBankQuestion1Answer = result.CoBorrower_Relation_With_Other_Bank_Q1__c;
                this.CoBorrowerRelationWithOtherBankQuestion2Answer = result.CoBorrower_Relation_With_Other_Bank_Q2__c;
                this.isCoBorrowerOptedYes = (result.Is_CoBorrower_Relative_Of_Director__c == 'Yes' || result.Is_CoBorrower_Relative_Of_Senior_Officer__c == 'Yes') ? true : false;
                this.isCoBorrowerChosenIndusInd = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'IndusInd Bank' ? true : false;
                this.isCoBorrowerChosenOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'Other Bank' ? true : false;
            }
        })
    }
    await getApplicantRelationshipWithBank({applicantId : this.borrowerLoanApplicantId}).then(result =>{
        if(result)
        {
            this.isBorrowerRelativeOfDirectorAnswer = result.Is_Borrower_Relative_Of_Director__c;
            this.isBorrowerRelativeOfSeniorOfficerAnswer = result.Is_Borrower_Relative_Of_Senior_Officer__c;
            this.IsBorrRelationshipWithIndusIndOrOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c;
            this.BorrowerRelationWithIndusIndQuestion1Answer = result.Borrower_Relation_With_IndusInd_Q1__c;
            this.BorrowerRelationWithIndusIndQuestion2Answer = result.Borrower_Relation_With_IndusInd_Q2__c;
            this.BorrowerRelationWithOtherBankQuestion1Answer = result.Borrower_Relation_With_Other_Bank_Q1__c;
            this.BorrowerRelationWithOtherBankQuestion2Answer = result.Borrower_Relation_With_Other_Bank_Q2__c;
            this.isBorrowerOptedYes = (result.Is_Borrower_Relative_Of_Director__c == 'Yes' || result.Is_Borrower_Relative_Of_Senior_Officer__c == 'Yes') ? true : false;
            this.isBorrowerChosenIndusInd = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'IndusInd Bank' ? true : false;
            this.isBorrowerChosenOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'Other Bank' ? true : false;    
            }
        })
    }//CISP-20594 - END
handleInstallmentSchedule(){this.isModalOpen=true;}
handleCloseModal(){this.isModalOpen=false;}
handleInsSubmit(){this.isModalOpen=false;this.isInsSubmitted = true;}
enableInsButton(){this.disableInsSchedule=false;this.isInsSubmitted = false;}
disableInsButton(){this.disableInsSchedule=true;}

}