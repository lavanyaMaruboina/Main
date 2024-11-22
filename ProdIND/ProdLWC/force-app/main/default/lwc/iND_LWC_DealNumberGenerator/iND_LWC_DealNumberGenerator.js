import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import dealNumberGeneration from '@salesforce/apex/DealNumberCustomerCode.dealNumberGeneration';
import getDistrictOptions from '@salesforce/apex/DealNumberCustomerCode.getDistrictOptions';
import doCustomerMasterCreationCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerMasterCreationCallout';
import doCustomerMasterUpdationCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerMasterUpdationCallout';//CISP-4263
import updateOpp from '@salesforce/apex/DealNumberCustomerCode.UpdateDealCustomer';
import updateApplicantCustomerCode  from '@salesforce/apex/DealNumberCustomerCode.updateApplicantCustomerCode';
import ConvertedOpportunityId from '@salesforce/schema/Lead.ConvertedOpportunityId';
import GetLoanApplicantDetails from '@salesforce/apex/DealNumberCustomerCode.getLoanApplicantDetails';
import { NavigationMixin } from 'lightning/navigation';
import createRealatedRecords from '@salesforce/apex/IND_TeleverificationDetails.createRealatedRecords';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import pleaseRetry from '@salesforce/label/c.Please_Retry';
import dealandCustomerCodeFirst from '@salesforce/label/c.Generate_Deal_Number_and_Fetch_Borrower_Coborrower_Code_First';
import dealNumberUpdatedSuccessfylly from '@salesforce/label/c.Deal_Number_Customer_Code_Upated_Sucessfully';
import Credit_Processing from '@salesforce/label/c.Credit_Processing';
import reffnamedata from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.reffnamedata';
import updateFinalTermBenCode from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.updateFinalTermBenCode';
import getFinalTermRecord from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getFinalTermRecord';
import checkCurrentSubStage from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkCurrentSubStage';
import getState from '@salesforce/apex/IND_TeleverificationDetails.getState';
import getNomineeDetails from '@salesforce/apex/DealNumberCustomerCode.getNomineeDetails';
/* SFTRAC- 97 - Start */
import getCoborrowerGrtDetails from '@salesforce/apex/DealNumberCustomerCode.getCoborrowerGrtDetails';
import getAssetDetails from '@salesforce/apex/DealNumberCustomerCode.getAssetDetails';
/* SFTRAC- 97 - End */
import updateNomineeDetails from '@salesforce/apex/DealNumberCustomerCode.updateNomineeDetails';
import Pin_code_Pattern from "@salesforce/label/c.Pin_code_Pattern";
import Address_Pattern from "@salesforce/label/c.Address_Pattern";
import doReferenceAndRelationAPICallout from '@salesforce/apexContinuation/IntegrationEngine.doReferenceAndRelationAPICallout';//CISP-9052
import updateReferenceAndRelationFieldOnOpp from '@salesforce/apex/DealNumberCustomerCode.updateReferenceAndRelationFieldOnOpp';//CISP-9052
export default class IND_LWC_DealNumberGenerator extends NavigationMixin(LightningElement) {
    referrerNameValue;
    @track referrerNameOptions = [];
    toggleSpinner = false;
    /* SFTRAC- 97 - Start */
    coBorrowerLabel;
    grtLabel;
    custCodeStr = 'Customer Code';
    coBorrowerId;
    tractorBorrowerId;
    tractorBorrCutomerCode;
    isBeneExists;
    beneLoanApplicantId;
    beneLabel;
    beneCutomerCode;
    @track beneApplicantMap = [];
    @track DealNumbers;
    @track dealNumberDisabled = false;
    @track errorMsg;
    @track activeSectionsList = [];
    @track borrCutomerCode;
    @track coBorrCutomerCode;
    @track tractorGrtCutomerCode;
    @api recordid;
    @track borrowerLoanApplicantId;
    @track borrowerLoanApplicantDisabled = true;
    @track coBorrowerLoanApplicantId;
    @track coBorrowerLoanApplicantDisabled = true;
    @track grtLoanApplicantDisabled = true;
    @track borrowerButtonVisible = false;
    @track coBorrowerButtonVisible;
    @track guarantorButtonVisible;
    @track relatedRecordsCreated = false;
    @track coBorrowerApplicantList = [];
    @track coBorrowerApplicantMap = [];
    @track assetDetailsList = [];
    @track activeApplicantSections = ['Borrower','Co-Borrower','Beneficiary','Guarantor'];
    @track guarantorApplicantList = [];
    @track religionOptions = [
        { label: 'HINDU', value: '1' },
        { label: 'MUSLIM', value: '2' },
        { label: 'CHRISTIAN', value: '3' },
        { label: 'BUDDHIST', value: '4' },
        { label: 'SIKH', value: '5' },
        { label: 'ZOROASTRIAN', value: '6' },
        { label: 'OTHERS', value: '7' },
        { label: 'JAIN', value: '8' }
    ];
    @track casteOptions = [
        { label: 'FORWARD CASTE(FC)', value: '1' },
        { label: 'BACKWARD CASTE(BC)', value: '2' },
        { label: 'BACKWARD CASTE OTHERS(OBC)', value: '3' },
        { label: 'MOST BACKWARD CASTE (MBC)', value: '4' },
        { label: 'SCHEDULED CASTE(SC)', value: '5' },
        { label: 'SCHEDULED TRIBE(ST)', value: '6' },
        { label: 'OTHERS', value: '7' },
    ];
    @track borrowReligion = '';
    @track borrowCaste = '';
    @track coBorrowReligion = '';
    @track coBorrowCaste = '';
    @track disableFields = false;
    @track borrowerstate = '';
    @track coborrowerstate = '';
    @track borrowerstate = '';
    @track coborrowerstate = '';
    @track borrowerdistrict = '';
    @track coborrowerdistrict = '';
    @track borrowerDistrictOptions=[];
    @track coborrowerDistrictOptions=[];
    @track borrowerDocId = '';
    @track coborrowerDocId = '';
    borrowerCodeUpdateStatus=false;//CISP-4263
    coborrowerCodeUpdateStatus=false;//CISP-4263
    coborrowerCodecreateStatus= false;//CISP-5382
    borrowerCodecreateStatus= false;//CISP-5382
    grtCodecreateStatus= false;
    grtCodeUpdateStatus= false;
    //CISP-4263
    boolManageButtonBorr=true;
    boolManageButtoncoBorr=true;
    label = {
        Address_Pattern,
        Pin_code_Pattern
    };
    get generateBorrower(){
        if(this.borrCutomerCode && this.boolManageButtonBorr && !this.borrowerCodecreateStatus){
            return 'Update Customer Code (Borrower)';
        }else{
            this.boolManageButtonBorr=false;
            return 'Generate Customer Code (Borrower)';
        }
    }
    //CISP-4263
    get generateCoBorrower(){
        if(this.coBorrCutomerCode && this.boolManageButtoncoBorr && !this.coborrowerCodecreateStatus){
             return 'Update Customer Code (Co-Borrower) ';
        }
        else{
        this.boolManageButtoncoBorr= true;
        return 'Generate Customer Code (Co-Borrower) ';
    }
    }
    reTriggerReverseApi = false;
    retriggerDisable = false;
    isPassengerVehicle = false;
    isPVorTractor = false; //SFTRAC-1710
    @track isTractor= false;
    @track isCmpRendered= false;
    nomineeSAAccountOpening;
    nomineeSAAccountOpenedFor;
    residenceCityFinacleValue;
    residenceCityFinacleId;
    permanentFinacleValue;
    permanentFinacleId;
    officeCityFinacleValue;
    officeCityFinacleId;
    nomineeAvailable = false;
    nomineeName;
    nomineeDOB;
    nomineeAddress;
    nomineePinCode;
    nomineeCity;
    nomineeCityId;
    nomineeState;
    nomineeStateId;
    nomineeRelationshipBorrower;
    nomineeAvailableChecked = true;
    nomineeDetailsforBorrower = false;
    CBnomineeSAAccountOpening;
    CBnomineeSAAccountOpenedFor;
    CBresidenceCityFinacleValue;
    CBresidenceCityFinacleId;
    CBpermanentFinacleValue;
    CBpermanentFinacleId;
    CBofficeCityFinacleValue;
    CBofficeCityFinacleId;
    CBnomineeAvailable = false;
    CBnomineeName;
    CBnomineeDOB;
    CBnomineeAddress;
    CBnomineePinCode;
    CBnomineeCity;
    CBnomineeCityId;
    CBnomineeState;
    CBnomineeStateId;
    CBnomineeRelationshipBorrower;
    CBnomineeAvailableChecked = true;
    casabankId;
    tvrId;
    isNomineeforCoborrower = false;
    isNomineeforBorrower = false;
    disableCBNomineeAvailable = true;
    disableBoNomineeAvailable = true;
    saveNomineeDetails = false;
    creditProcessingcheck=true;//CISP-5832
    IsReferenceAndRelationApiCalled = false;
    isRefrenceAndRelEnabled = true;
    isCoborrowerExists = false;
    relationshipOptions = [
        {label: 'Father', value: 'Father'},
        {label: 'Mother', value: 'Mother'},
        {label: 'Son', value: 'Son'},
        {label: 'Daughter', value: 'Daughter'},
        {label: 'Friend', value: 'Friend'},
        {label: 'Brother', value: 'Brother'},
        {label: 'Sister', value: 'Sister'},
        {label: 'Husband', value: 'Husband'},
        {label: 'Wife', value: 'Wife'}];
    
    getLoanApplicantDetailsHandler(){
        GetLoanApplicantDetails({ loanApplicationId: this.recordid }).then((data)=>{
            try{
                if (data) {
                    for (let applicant of data) {
                        if (applicant.Opportunity__c) {
                            if(applicant.Opportunity__r.StageName!=Credit_Processing){
                                this.disableFields = true;
                                this.dealNumberDisabled = true;
                                this.coBorrowerLoanApplicantDisabled = true;
                                this.borrowerLoanApplicantDisabled = true;
                                this.grtLoanApplicantDisabled = true; // SFTRAC-97
                                this.creditProcessingcheck = false;
                            }
                            this.DealNumbers = applicant.Opportunity__r.Deal_Number__c;
                            this.IsReferenceAndRelationApiCalled = applicant.Opportunity__r.IsReferenceAndRelationApiCalled__c;//CISP-9052
                            if(this.DealNumbers){
                                this.dealNumberDisabled = true;
                            }
                        }
                        console.debug(applicant.Applicant_Type__c);
                        if (applicant.Applicant_Type__c.includes('Borrower')) {
                            this.borrowerCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;//CISP-4263
                            this.borrowerCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;//CISP-5382
                            this.borrowerButtonVisible = true;
                            this.borrowerLoanApplicantId = applicant.Id;
                            if(this.creditProcessingcheck){
                            this.borrowerLoanApplicantDisabled =this.borrowerCodeUpdateStatus || this.borrowerCodecreateStatus ? true: false //CISP_4263
                            this.isRefrenceAndRelEnabled = this.borrowerCodeUpdateStatus || this.borrowerCodecreateStatus ? false: true//CISP-9052
                        }
                            if (applicant.Customer_Code__c) {
                                this.borrCutomerCode = applicant.Customer_Code__c;
                                //this.coBorrowerLoanApplicantDisabled = true; //CISP-2653
                                // this.borrowerLoanApplicantDisabled = true; //CISP_4263
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        this.borrCutomerCode = res.Customer_Code__c;
                                        //    this.borrowerLoanApplicantDisabled = true; //CISP-4263
                                    }
                                }
                            }
                            if (applicant.Documents__r) {
                                for (let res of applicant.Documents__r) {
                                    console.debug(res);
                                    if (res.KYC_State__c) {
                                        this.borrowerDocId = res.Id;
                                        this.borrowerstate = res.KYC_State__c;
                                        if(res.KYC_District__c){
                                            this.borrowerdistrict = res.KYC_District__c;
                                            this.borrowerDistrictOptions.push({label:res.KYC_District__c,value:res.KYC_District__c});
                                        }
                                    }
                                }
                                console.debug(this.borrowerdistrict);
                                if(!this.borrowerdistrict){
                                    console.debug(this.borrowerstate);
                                    getDistrictOptions({
                                        state: this.borrowerstate
                                    })
                                    .then(result => {
                                        if (result) {
                                            console.debug(JSON.parse(result));
                                            this.borrowerDistrictOptions = JSON.parse(result);
                                        } else {
                                            console.error('No State Found');
                                        }
                                    })
                                    .catch(error => {
                                        this.errorMsg = error;
                                        console.error(this.errorMsg);
                                    })
                                }
                            }
                            if(applicant.Religion__c){
                                this.borrowReligion = applicant.Religion__c;
                            }
                            if(applicant.Caste__c){
                                this.borrowCaste = applicant.Caste__c;
                            }
                        } else if (applicant.Applicant_Type__c.includes('Co-borrower')) {
                            this.isCoborrowerExists = true;
                            this.coBorrowerLabel = 'Customer Code ('+applicant.Name+') - Coborrower'; //SFTRAC-97
                            this.coBorrCutomerCode = '';//SFTRAC-97
                            this.coborrowerCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;//CISP-4263
                            this.coborrowerCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;//CISP-5382
                            this.coBorrowerButtonVisible = true;
                            this.coBorrowerLoanApplicantId = applicant.Id;
                            if(this.creditProcessingcheck){
                            this.coBorrowerLoanApplicantDisabled=this.coborrowerCodeUpdateStatus || this.coborrowerCodecreateStatus? true: false //CISP_4263
                            this.isRefrenceAndRelEnabled = this.coborrowerCodeUpdateStatus || this.coborrowerCodecreateStatus ? false: true    //CISP-9052
                        }
                            if (applicant.Customer_Code__c) {
                                console.debug(applicant.Customer_Code__c);
                                this.coBorrCutomerCode = applicant.Customer_Code__c;
                                // this.coBorrowerLoanApplicantDisabled = true; //CISP-4263
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        console.debug(res.Customer_Code__c);
                                        this.coBorrCutomerCode = res.Customer_Code__c;
                                        //   this.coBorrowerLoanApplicantDisabled = true; //CISP-4263
                                    }
                                }
                            }

                            this.coBorrowerApplicantMap.push({key:this.coBorrowerLabel,customerCode:this.coBorrCutomerCode,id:applicant.Id,dis:this.coBorrowerLoanApplicantDisabled}); //SFTRAC-97
                            if (applicant.Documents__r) {
                                for (let res of applicant.Documents__r) {
                                    if (res.KYC_State__c) {
                                        this.coborrowerDocId = res.Id;
                                        this.coborrowerstate = res.KYC_State__c;
                                        if(res.KYC_District__c){
                                            this.coborrowerdistrict = res.KYC_District__c;
                                            this.coborrowerDistrictOptions.push({label:res.KYC_District__c,value:res.KYC_District__c});
                                        }
                                    }
                                }
                                if(!this.coborrowerdistrict){
                                    getDistrictOptions({
                                        state: this.coborrowerstate
                                    })
                                    .then(result => {
                                        if (result && result.length>0) {
                                            this.coborrowerDistrictOptions = JSON.parse(result);
                                        } else {
                                            console.error('No State Found');
                                        }
                                    })
                                    .catch(error => {
                                        this.errorMsg = error;
                                        console.error(this.errorMsg);
                                    })
                                }
                            }
                            if(applicant.Religion__c){
                                this.coBorrowReligion = applicant.Religion__c;
                            }
                            if(applicant.Caste__c){
                                this.coBorrowCaste = applicant.Caste__c;
                            }
                        } /* SFTRAC - 97 - Start */
                        else if (applicant.Opportunity__r.Product_Type__c = 'Tractor' && applicant.Applicant_Type__c.includes('Guarantor')){
                            this.grtCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;//CISP-4263
                            this.grtCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;//CISP-5382
                            this.guarantorButtonVisible = true;
                            if(this.creditProcessingcheck){
                                this.grtLoanApplicantDisabled =this.grtCodeUpdateStatus || this.grtCodecreateStatus ? true: false //CISP_4263
                            }
                            this.grtLabel = 'Customer Code ('+applicant.Name+') - Guarantor';
                            if (applicant.Customer_Code__c) {
                                console.debug(applicant.Customer_Code__c);
                                this.tractorGrtCutomerCode = applicant.Customer_Code__c;
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        console.debug(res.Customer_Code__c);
                                        this.tractorGrtCutomerCode = res.Customer_Code__c;
                                    }
                                }
                            }
                            this.guarantorApplicantList.push({key:this.grtLabel,customerCode:this.tractorGrtCutomerCode,id:applicant.Id,dis:this.grtLoanApplicantDisabled});
                        }
                        else if((applicant.Opportunity__r.Product_Type__c = 'Tractor') && (applicant.Opportunity__r.Customer_Type__c = 'Non-Individual') && (applicant.Applicant_Type__c.includes('Beneficiary'))){ //SFTRAC-395
                            this.isBeneExists = true;
                            this.beneLoanApplicantId = applicant.Id;
                            this.beneLabel = 'Customer Code ('+applicant.Name+') - Beneficiary';
                            this.beneCutomerCode = '';
                            if (applicant.Customer_Code__c) {
                                console.log(applicant.Customer_Code__c);
                                this.beneCutomerCode = applicant.Customer_Code__c;
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        console.log(res.Customer_Code__c);
                                        this.beneCutomerCode = res.Customer_Code__c;
                                    }
                                }
                            }
                            this.beneApplicantMap.push({key:this.beneLabel,customerCode:this.beneCutomerCode,id:applicant.Id}); 
                        }
                        else {
                            this.borrowerLoanApplicantDisabled = true;
                            this.coBorrowerLoanApplicantDisabled = true;
                            this.grtLoanApplicantDisabled = true; //SFTRAC-97
                        }
                        console.debug(this.coBorrowerLoanApplicantDisabled);
                    }
                    if(this.IsReferenceAndRelationApiCalled){//CISP-9052
                        this.isRefrenceAndRelEnabled = true;
                    }
                }
            }catch(err){
                console.error(err);
            }
        }).catch(error=>{
            console.log("Error in getting loan application details",JSON.stringify(error));
        });
    }
   //SFTRAC-97 
   getAssetDetailsHandler(){
        getAssetDetails({ loanApplicationId: this.recordid }).then((data)=>{
            try{
                this.assetDetailsList = [];
                this.activeSectionsList = [];
                if (data) {
                    let assetDetails = [];
                    let activeSections = [];
                    for (let index = 0; index < data.length; index++) {
                        const asset = data[index];
                        let dealnumbers = null;
                        let assetTitle = asset.Make__c+' '+asset.Model__c+' '+asset.Variant__c;
                        if (asset.Deal_Number__c) {                
                            dealnumbers =  asset.Deal_Number__r.Deal_Number_Tractor__c;
                        } else {
                            dealnumbers = null;
                        }
                        activeSections.push(assetTitle);
                        assetDetails.push({key:asset.Id,title:assetTitle,dealnumber:dealnumbers});
                    }
                    this.assetDetailsList = assetDetails;
                    this.activeSectionsList = activeSections;
                } 
                this.toggleSpinner = false;
            }catch(err){
                console.error(err);
                this.toggleSpinner = false;
            }
        }).catch(error=>{
            console.log("Error in getting loan application details",JSON.stringify(error));
        });
    } 

    handleInputFieldChange(event) {
        if (event.target.dataset.id == 'coBorrowReligion') {
            this.coBorrowReligion = event.target.value;
        } else if (event.target.dataset.id == 'coBorrowCaste') {
            this.coBorrowCaste = event.target.value;
        } else if (event.target.dataset.id == 'coborrowDistrict'){
            this.coborrowerdistrict = event.target.value;
        } else if (event.target.dataset.id == 'borrowDistrict'){
            this.borrowerdistrict = event.target.value;
        } else if (event.target.dataset.id == 'borrowCaste') {
            this.borrowCaste = event.target.value;
        }else if (event.target.dataset.id == 'borrowReligion') {
            this.borrowReligion = event.target.value;
        }
    }
    handleReferrerNameChange(event){
        console.log('call handleReferrerNameChange : ',);
        console.log('event : ',event.target);
        this.referrerNameValue = event.target.value;
        console.log('this.referrerNameValue : ',this.referrerNameValue);
        console.log('label ' , event.target.options.find(opt => opt.value === event.detail.value).label);
        let referrerName = event.target.options.find(opt => opt.value === event.detail.value).label;
        updateFinalTermBenCode({ loanApplicationId: this.recordid, benCode:this.referrerNameValue,bencodeName:referrerName })
          .then(result => {
            console.log('Result updateFinalTermBenCode', result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    compareName(a, b) {

        // converting to uppercase to have case-insensitive comparison
        const name1 = a.label.toUpperCase();
        const name2 = b.label.toUpperCase();
    
        let comparison = 0;
    
        if (name1 > name2) {
            comparison = 1;
        } else if (name1 < name2) {
            comparison = -1;
        }
        return comparison;
    }
    async init(){
        try{
                await reffnamedata({ loanApplicationId: this.recordid })
            .then(result => {
                console.log('Result reffnamedata', result);
                let options = [];
                for (let key in result) {
                    options.push({ label: result[key], value: key });
                }
                this.referrerNameOptions = JSON.parse(JSON.stringify(options));
                console.log('this.referrerNameOptions : ',this.referrerNameOptions);
                this.referrerNameOptions.sort(this.compareName);
            })
            .catch(error => {
                console.error('Error:', error);
            }); 
            await getFinalTermRecord({ loanApplicationId: this.recordid })
            .then(result => {
                console.log('Result', result);
                if(result){
                    console.log('this.referrerNameOptions : ',this.referrerNameOptions);
                    let options = JSON.parse(JSON.stringify(this.referrerNameOptions));
                    options.find((item) => {
                        console.log('item : ',item);
                        if(item.value == result[0].Referrer_Ben_Code__c){
                            this.referrerNameValue = item.value;
                        }
                    })
                    
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }catch(error){
            console.log('error in connected callback : ',error);
        }
    }
    @api isRevokedLoanApplication;//CISP-2735
    async connectedCallback() {
        try{
        await this.getLoanApplicantDetailsHandler();
        await this.getAssetDetailsHandler(); //SFTRAC-97
       // this.init(); // CISP-2522
       if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
       await checkCurrentSubStage({'loanApplicationId': this.recordid, 'screenName' : 'Deal Number & Customer Code Generation'}).then(result=>{
            if(result){
                this.disableFields = true;
            //this.disableFields = false;//CISP-6382
            }
        }).catch(error=>{
            const evt = new ShowToastEvent({
                title: 'Something went wrong, Please contact your administrator.',
                variant: '',
                mode: 'dismissible'
            });
            this.dispatchEvent(evt);
        });
        getNomineeDetails({ loanApplicationId: this.recordid }).then( result => {
            if(result!=null){
                if (result === 'Two Wheeler') {
                    this.isPassengerVehicle = false;
                }else if (result === 'Tractor') {
                    this.isTractor = true; ////SFTRAC-97
                }else if (result === 'Passenger Vehicles') {
                    this.isPassengerVehicle = true;
                } 
                else{
                    let response = JSON.parse(result);
                    this.isPassengerVehicle = true;
                    if(response.applicantType && response.applicantType === 'Borrower'){
                        this.nomineeSAAccountOpening = response.nomineeSAAccountOpening;
                        this.nomineeSAAccountOpenedFor = response.nomineeSAAccountOpenedFor ? response.nomineeSAAccountOpenedFor : 'Borrower';
                        this.residenceCityFinacleValue = response.residenceCityFinacle;
                        this.permanentFinacleValue = response.permanentFinacle;
                        this.officeCityFinacleValue = response.officeCityFinacle;
                        this.nomineeAvailable = response.nomineeAvailable;
                        this.nomineeName = response.nomineeName;
                        this.nomineeDOB = response.nomineeDOB;
                        this.nomineeAddress = response.nomineeAddress;
                        this.nomineePinCode = response.nomineePinCode;
                        this.nomineeCity = response.nomineeCity;
                        this.nomineeState = response.nomineeState;
                        this.nomineeRelationshipBorrower = response.nomineeRelationshipBorrower;
                        this.casabankId = response.casabankId;
                        this.tvrId = response.tvrId;
                        if(!this.disableFields){
                            this.isNomineeforBorrower = true;
                            this.disableBoNomineeAvailable = false;
                        }
                        this.nomineeDetailsforBorrower = true;
                        this.saveNomineeDetails = true;
                    }else if(response.applicantType === 'Co-borrower'){
                        this.CBnomineeSAAccountOpening = response.nomineeSAAccountOpening;
                        this.CBnomineeSAAccountOpenedFor = response.nomineeSAAccountOpenedFor ? response.nomineeSAAccountOpenedFor : 'Co-borrower';
                        this.CBresidenceCityFinacleValue = response.residenceCityFinacle;
                        this.CBpermanentFinacleValue = response.permanentFinacle;
                        this.CBofficeCityFinacleValue = response.officeCityFinacle;
                        this.CBnomineeAvailable = response.nomineeAvailable;
                        this.CBnomineeName = response.nomineeName;
                        this.CBnomineeDOB = response.nomineeDOB;
                        this.CBnomineeAddress = response.nomineeAddress;
                        this.CBnomineePinCode = response.nomineePinCode;
                        this.CBnomineeCity = response.nomineeCity;
                        this.CBnomineeState = response.nomineeState;
                        this.CBnomineeRelationshipBorrower = response.nomineeRelationshipBorrower;
                        this.casabankId = response.casabankId;
                        this.tvrId = response.tvrId;
                        if(!this.disableFields){
                            this.isNomineeforCoborrower = true;
                            this.disableCBNomineeAvailable = false;
                        }
                        this.nomineeDetailsforBorrower = false;
                        this.saveNomineeDetails = true;
                    }
                }
            }
            if(this.isTractor == true || this.isPassengerVehicle == true){ //SFTRAC-1710
                this.isPVorTractor = true;
            }//SFTRAC-1710
            this.isCmpRendered = true;
        }).catch(error=>{this.isCmpRendered = true;})
        }catch(error){
            this.isCmpRendered = true;
        }
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
    showError(title, errorMessage) {
            const evt = new ShowToastEvent({
                title: title,
                message: errorMessage,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
        /* function for Deal Number generation */
    handleGenerateDealNumber() {
            this.dealNumberDisabled=true;//CISP-2834
            this.toggleSpinner = true;

            dealNumberGeneration({
                loanApplicationId: this.recordid,
                assetDetailId : ''
            })
                .then(result => {
                    if (result) {
                        this.DealNumbers = result;
                        this.dealNumberDisabled = true;
                        this.toggleSpinner = false;
                    } else {
                        this.showError('Deal Number', pleaseRetry);
                        this.dealNumberDisabled = false;//CISP-2834
                        this.toggleSpinner = false;
                    }
                })
                .catch(error => {
                    this.dealNumberDisabled = false;//CISP-2834
                    this.errorMsg = error;
                    this.showError('Deal Number!', 'There was an error in deal number generation. Please try again.');
                    this.dealNumberDisabled = false;
                    this.toggleSpinner = false;
                })

        }
        //SFTRAC-97
        handleGenerateDealNumberTractor(event) {
            this.toggleSpinner = true;
            let assetDetailId = event.target.value;

            dealNumberGeneration({
                loanApplicationId: this.recordid,
                assetDetailId : assetDetailId
            })
                .then(result => {
                    if (result) {
                        this.getAssetDetailsHandler();
                        this.showToast('Success !','Deal Number Generated Successfully!!','success');
                    } else {
                        this.showError('Deal Number', pleaseRetry);
                        this.toggleSpinner = false;
                    }
                })
                .catch(error => {
                    this.errorMsg = error;
                    console.error(this.errorMsg);
                    this.showError('Deal Number!', 'There was an error in deal number generation. Please try again.');
                    this.toggleSpinner = false;
                })

        }
        /* Generate Customer Code for Borrower*/
    handleGenerateBorrowerCode() {
            //CISP-4263
            this.borrowerLoanApplicantDisabled = true;
            let customerMaster = doCustomerMasterCreationCallout;
            let isCustomerMaster=false;
            let religionField = this.template.querySelector('lightning-combobox[data-id=borrowReligion]');
            let casteField = this.template.querySelector('lightning-combobox[data-id=borrowCaste]');
            religionField.reportValidity();
            casteField.reportValidity();
            if (religionField.validity.valid && casteField.validity.valid) {
                this.toggleSpinner = true;
                console.debug(this.borrowerdistrict);
                //CISP-4263
                if(this.borrCutomerCode){
                    customerMaster=  doCustomerMasterUpdationCallout;
                    isCustomerMaster=true;
                }
                customerMaster({
                        applicantId: this.borrowerLoanApplicantId,
                        loanAppId: this.recordid,
                        religion: religionField.value,
                        caste: casteField.value,
                        district: this.borrowerdistrict
                    })
                    .then((result) => {
                        if (result) {
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
                                    religion: religionField.value,
                                    caste: casteField.value,
                                    district: this.borrowerdistrict,
                                    POADocumentId: this.borrowerDocId,
                                    customerMasterStatus: isCustomerMaster,
                                    customerCreationStatus: this.boolManageButtonBorr
                                })
                                .then((result) => {
                                        this.borrowerLoanApplicantDisabled = true;
                                        this.borrowerCodeUpdateStatus=true;
                                        this.isRefrenceAndRelEnabled = false;//CISP-9052
                                }).catch((error) => {
                                    this.errorMsg = error;
                                    this.toggleSpinner = false;
                                    console.debug(error);
                                    this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                                    this.borrowerLoanApplicantDisabled = false;
                                });
                            } else {
                                this.borrowerLoanApplicantDisabled = false;
                                this.showError('Borrower Customer Code', pleaseRetry);
                            }
                            }catch(err){
                                this.showError('Borrower Customer Code', pleaseRetry);
                                this.borrowerLoanApplicantDisabled = false;
                            }
                        } else {
                            this.showError('Borrower Customer Code', pleaseRetry);
                            this.borrowerLoanApplicantDisabled = false;
                        }
                        this.toggleSpinner = false;
                    }).catch((error) => {
                        this.errorMsg = error;
                        this.toggleSpinner = false;
                        console.debug(error);
                        this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                        this.borrowerLoanApplicantDisabled = false;
                    });
                
            } else {
                console.debug(mandotoryDetailsNotProvide);
                this.showError('Borrower Customer Code', mandotoryDetailsNotProvide);
                this.borrowerLoanApplicantDisabled = false;
            }
        }
        /* Generate Customer Code for Co-Borrower*/
    handleGenerateCoBorrowerCode() {
            this.coBorrowerLoanApplicantDisabled = true;
            let customerMaster = doCustomerMasterCreationCallout;
            let isCustomerMaster=false;
            let religionField = this.template.querySelector('lightning-combobox[data-id=coBorrowReligion]');
            let casteField = this.template.querySelector('lightning-combobox[data-id=coBorrowCaste]');
            religionField.reportValidity();
            casteField.reportValidity();
            if (religionField.validity.valid && casteField.validity.valid) {
                this.toggleSpinner = true;
                //CISP-4263
                if(this.coBorrCutomerCode){
                   customerMaster=  doCustomerMasterUpdationCallout;
                   isCustomerMaster=true;
                }
                customerMaster({
                        applicantId: this.coBorrowerLoanApplicantId,
                        loanAppId: this.recordid,
                        religion: religionField.value,
                        caste: casteField.value,
                        district: this.coborrowerdistrict
                    })
                    .then((result) => {
                        if (result) {
                            var res = JSON.parse(result);
                            console.debug(res);
                            if (res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code ||(this.coBorrCutomerCode && res.response.status =='SUCCESS')) {
                               if(!this.coBorrCutomerCode){
                                var coBorrowerCutomerCode = res.response.content[0].Customer_Code;
                                this.coBorrCutomerCode = coBorrowerCutomerCode;
                            }
                                updateApplicantCustomerCode({
                                    loanApplicationId: this.recordid,
                                    applicantId: this.coBorrowerLoanApplicantId,
                                    customerCode: this.coBorrCutomerCode,
                                    religion: religionField.value,
                                    caste: casteField.value,
                                    district: this.coborrowerdistrict,
                                    POADocumentId: this.coborrowerDocId,
                                    customerMasterStatus: isCustomerMaster,
                                    customerCreationStatus: this.boolManageButtoncoBorr
                                })
                                .then((result) => {
                                        this.coBorrowerLoanApplicantDisabled = true;
                                        this.coborrowerCodeUpdateStatus=true;
                                        this.isRefrenceAndRelEnabled = false;//CISP-9052
                                }).catch((error) => {
                                    this.errorMsg = error;
                                    this.toggleSpinner = false;
                                    console.debug(error);
                                    this.showError('Co-Borrower Customer Code', error.body ? error.body.message : '');
                                    this.coBorrowerLoanApplicantDisabled = false;
                                });
                            } else {
                                this.showError('Co-Borrower Customer Code', pleaseRetry);
                                this.coBorrowerLoanApplicantDisabled = false;
                            }
                        } else {
                            this.coBorrowerLoanApplicantDisabled = false;
                            this.showError('Co-Borrower Customer Code', pleaseRetry);
                        }
                        this.toggleSpinner = false;
                    }).catch((error) => {
                        this.errorMsg = error;
                        this.toggleSpinner = false;
                        this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                        this.coBorrowerLoanApplicantDisabled = false;
                    });
            } else {
                this.showError('Co-Borrower Customer Code', mandotoryDetailsNotProvide);
                this.coBorrowerLoanApplicantDisabled = false;
            }

        }
        /* Handle Submit button function*/
    //CISP-4263
    showToast(title, message, variant){
        const toastevent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant

        });
        this.dispatchEvent(toastevent);
    }
    //CISP-9052 start
    handleReferenceDetails(){
        
        this.toggleSpinner = true;
        if(!this.borrowerLoanApplicantDisabled){
            this.toggleSpinner = false;
            this.showToast('Error !','Please click on generate customer code / update customer code button for borrower','error');
            return;
        }else if(!this.coBorrowerLoanApplicantDisabled && this.isCoborrowerExists){
            console.log('in second if : ',);
            this.toggleSpinner = false;
            this.showToast('Error !','Please click on generate customer code / update customer code button for Co-borrower','error');
            return;
        }
        else{
            console.log('in else part : ',);
            //SFTARC-1710 starts
            if(this.isTractor){
                this.assetDetailsList.forEach(assetRec => {
                    // Assuming you have a function named 'anotherFunction' to call
                    this.handleCallReferenceAndRelationAPI(assetRec.key);
                });
            }else{
                this.handleCallReferenceAndRelationAPI(''); 
            }//SFTARC-1710 ends            
        }
	}//CISP-9052 end

    //SFTARC-1710 STarts
    handleCallReferenceAndRelationAPI(vehicleId){
        doReferenceAndRelationAPICallout({ leadId: this.recordid, vehicleId : vehicleId })
            .then(result => {
                console.log('Result', result);
                let res = JSON.parse(result);
                if(res.response.status == 'SUCCESS'){
                    this.showToast('Success !',res.response.respDesc,'Success');
                    this.IsReferenceAndRelationApiCalled = true;
                    this.isRefrenceAndRelEnabled = true;
                    updateReferenceAndRelationFieldOnOpp({ loanApplicationId: this.recordid })
                      .then(result => {
                        console.log('Result', result);
                      })
                      .catch(error => {
                        console.error('Error:', error);
                    });
                }else if(res.response.status == 'FAILED'){
                    this.showToast('Error !',res.response.respDesc,'Error');
                    this.isRefrenceAndRelEnabled = false;
                }
                this.toggleSpinner = false;
            })
            .catch(error => {
                console.error('Error:', error);
                this.showToast('Error !','Please click on Update reference details button again!','Error');
                this.isRefrenceAndRelEnabled = false;
                this.toggleSpinner = false;
            });
        }
    //SFTRAC-1710 Ends
    async handleSubmit() {//CISP-2987
        this.disableFields = true;//CISP-2767
        this.toggleSpinner = true;//CISP-2767
        try {
            let applicantList = await GetLoanApplicantDetails({loanApplicationId: this.recordid});
            let applicants = await applicantList.filter(applicant => (applicant.Customer_Code__c == null || applicant.Customer_Code__c == undefined || applicant.Customer_Code__c == ''));
            if(applicants && applicants.length > 0 && applicants[0].Applicant_Type__c == 'Borrower'){
                this.showToast('Warning !','Customer code is not mapped for borrower!','warning');
                this.disableFields = false;
                this.toggleSpinner = false;
                return;
            }
            if(applicants && applicants.length > 0 && applicants[0].Applicant_Type__c == 'Co-borrower'){
                this.showToast('Warning !','Customer code is not mapped for Co-borrower!','warning');
                this.disableFields = false;
                this.toggleSpinner = false;
                return;
            }
            if(applicants && applicants.length > 0 && applicants[0].Applicant_Type__c == 'Guarantor'){ // SFTRAC-97
                this.showToast('Warning !','Customer code is not mapped for Guarantor!','warning');
                this.disableFields = false;
                this.toggleSpinner = false;
                return;
            }
            if(applicants && applicants.length > 0 && applicants[0].Applicant_Type__c == 'Beneficiary'){ // SFTRAC-97
                this.showToast('Warning !','Customer code is not mapped for Beneficiary!','warning');
                this.disableFields = false;
                this.toggleSpinner = false;
                return;
            }
        } catch (error) {
            this.disableFields = false;
            this.toggleSpinner = false;
            this.showToast('Error !','Something went wrong!','error');
            return;
        }
        /* checkIfError(){
             var areAllValid =true;
             var inputs = this.template.querySelectorAll('.inputrequired');
             inputs.forEach(input => {
                 if(!input.checkValidity()){
                     input.reportValidity();
                     areAllValid=false;
                 }
                 
             });
             return areAllValid;
         } */
    
      if ((!this.isTractor && this.DealNumbers == null) || this.borrCutomerCode == null || (this.coBorrowerButtonVisible && this.coBorrCutomerCode == null) || (this.isTractor && this.guarantorButtonVisible && this.tractorGrtCutomerCode == null)) {//CISP-2822 //SFTRAC-97
            const toastevent = new ShowToastEvent({
                title: 'Error !',
                message: dealandCustomerCodeFirst,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastevent);
            this.toggleSpinner = false;//CISP-2767
            this.disableFields = false;//CISP-2767
            return;
        }  
        //CISP-4263
        if((!this.borrowerCodeUpdateStatus && this.borrCutomerCode && !this.borrowerCodecreateStatus)){
            this.showToast('Error !','Update Borrower Customer Code','error');
            this.toggleSpinner = false;
            this.disableFields = false;
            return;
        }
        if((!this.coborrowerCodeUpdateStatus && this.coborrCutomerCode && !this.coborrowerCodecreateStatus)){
            this.showToast('Error !','Update coBorrower Customer Code','error');
            this.toggleSpinner = false;
            this.disableFields = false;
            return;
        }
        //CISP-9052 //Updated isPVorTractor check for SFTRAC-1710
        if(!this.IsReferenceAndRelationApiCalled && this.isPVorTractor){
            this.showToast('Error !','Please click on Update reference details button','error');
            this.toggleSpinner = false;
            this.disableFields = false;
            return;
        }//CISP-9052 end
        if (this.isPassengerVehicle && this.saveNomineeDetails) {
            if(this.isNomineeforBorrower){
                if(!this.residenceCityFinacleValue || !this.permanentFinacleValue || !this.officeCityFinacleValue || this.residenceCityFinacleValue?.trim() == '' || this.permanentFinacleValue?.trim() == '' || this.officeCityFinacleValue?.trim() == ''){
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                            message: 'Fill all the Nominee Details.',
                            variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.toggleSpinner = false;
                    this.disableFields = false;
                    return;
                }else if(this.nomineeAvailable && this.emptyFieldCheck('.boNomineeField')){
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Fill all the Nominee Details.',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.toggleSpinner = false;
                    this.disableFields = false;
                    return;
                }
            }else if(this.isNomineeforCoborrower){
                if(!this.CBresidenceCityFinacleValue || !this.CBpermanentFinacleValue || !this.CBofficeCityFinacleValue || this.CBresidenceCityFinacleValue?.trim() == '' || this.CBpermanentFinacleValue?.trim() == '' || this.CBofficeCityFinacleValue?.trim() == ''){
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                            message: 'Fill all the Nominee Details.',
                            variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.toggleSpinner = false;
                    this.disableFields = false;
                    return;
                }else if(this.CBnomineeAvailable && this.emptyFieldCheck('.cbNomineeField')){
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                            message: 'Fill all the Nominee Details.',
                            variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.toggleSpinner = false;
                    this.disableFields = false;
                    return;
                }
            }
        }
        if (this.isTractor) {
            let dealNumberGenerated = true;
            for (let index = 0; index < this.assetDetailsList.length; index++) {
                if(!this.assetDetailsList[index].dealnumber){
                    dealNumberGenerated = false;
                    break;
                }                
            }
            if(!dealNumberGenerated){
                const toastevent = new ShowToastEvent({
                    title: 'Error !',
                    message: 'Please generate deal number for all assets!',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toastevent);
                this.toggleSpinner = false;
                this.disableFields = false;
                return;
            }
        } 
        //CISP-2987-START
        if(!this.relatedRecordsCreated){
            await createRealatedRecords({                   
                strOppId: this.recordid,
                tvrType:'Post-TVR'
            })
            .then(result => {
                console.log('successAAAA');  
                this.relatedRecordsCreated = true;      
                // this.toggleSpinner = false;//CISP-2767
                // this.disableFields = false;//CISP-2767
                if(this.isPassengerVehicle && this.relatedRecordsCreated && this.saveNomineeDetails){
                    updateNomineeDetails({                   
                        loanApplicationId: this.recordid,
                        wrapperObj: this.createWrapperdata()
                    }).then(res => {
                        const evt = new ShowToastEvent({
                            title: 'Success !',
                            message: 'Nominee Details Submitted.',
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                    }).catch(error => {         
                        console.log('error ',error);
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Something went wrong, Please contact your administrator.',
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        this.toggleSpinner = false;
                        this.disableFields = false;
                        return;
                    });
                }
            })
            .catch(error => {                    
                console.log('error ',error); 
                this.toggleSpinner = false;//CISP-2767
                this.disableFields = false;//CISP-2767
            })
        }
        if(!this.relatedRecordsCreated){
            const evt = new ShowToastEvent({
                title: 'Something went wrong, Please contact your administrator.',
                variant: '',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.toggleSpinner = false;//CISP-2767
            this.disableFields = false;//CISP-2767
            return;
        }
        //CISP-2987-END
        await updateOpp({
                opportunityId: this.recordid
            })
            .then(result => {
                // console.debug('SUCCESS');
                // window.location.replace(window.location.origin + '/lightning/n/Deal_Number');
                const toastevent = new ShowToastEvent({
                    title: 'Success !',
                    message: dealNumberUpdatedSuccessfylly,
                    variant: 'success',
                    mode: 'dismissable'

                });
                const selectedEvent = new CustomEvent('onsubmitevent', {});
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
                location.reload();
            })
            .catch(error => {
                console.debug(error);
                console.debug('error');
                const toastevent = new ShowToastEvent({
                    title: 'Error !',
                    message: 'Error Occured !',
                    variant: 'error',
                    mode: 'dismissable'

                });
                this.dispatchEvent(toastevent);
                this.toggleSpinner = false;//CISP-2767
                this.disableFields = false;//CISP-2767
            });
    }
    handleCheck(event){
        const name = event.target.name;
        if(name == 'nomineeSAAccountOpening')
        {
            this.nomineeSAAccountOpening = event.detail.value;
        }
        else if(name == 'nomineeSAAccountOpenedFor')
        {
            this.nomineeSAAccountOpenedFor = event.detail.value;
        }
        else if(name == 'nomineeAvailable')
        {
            this.nomineeAvailable = event.target.checked;
            this.nomineeAvailableChecked = !event.target.checked;
            if(!event.target.checked){
                this.nomineeName = null;
                this.nomineeDOB = null;
                this.nomineeAddress = null;
                this.nomineePinCode = null;
                this.nomineeCity = null;
                this.nomineeState = null;
                this.nomineeRelationshipBorrower = null;
            }
        }
        else if(name == 'nomineeName')
        {
            this.nomineeName = event.detail.value;
        }
        else if(name == 'nomineeDOB')
        {
            this.nomineeDOB = event.detail.value;
        }
        else if(name == 'nomineeAddress')
        {
            this.nomineeAddress = event.detail.value;
        }
        else if(name == 'nomineePinCode')
        {
            this.nomineePinCode = event.detail.value;
        }
        else if(name == 'nomineeRelationshipBorrower')
        {
            this.nomineeRelationshipBorrower = event.detail.value;
        }
        else if(name == 'CB_nomineeSAAccountOpening')
        {
            this.CBnomineeSAAccountOpening = event.detail.value;
        }
        else if(name == 'CB_nomineeSAAccountOpenedFor')
        {
            this.CBnomineeSAAccountOpenedFor = event.detail.value;
        }
        else if(name == 'CB_nomineeAvailable')
        {
            this.CBnomineeAvailable = event.target.checked;
            this.CBnomineeAvailableChecked = !event.target.checked;
            if(!event.target.checked){
                this.CBnomineeName = null;
                this.CBnomineeDOB = null;
                this.CBnomineeAddress = null;
                this.CBnomineePinCode = null;
                this.CBnomineeCity = null;
                this.CBnomineeState = null;
                this.CBnomineeRelationshipBorrower = null;
            }
        }
        else if(name == 'CB_nomineeName')
        {
            this.CBnomineeName = event.detail.value;
        }
        else if(name == 'CB_nomineeDOB')
        {
            this.CBnomineeDOB = event.detail.value;
        }
        else if(name == 'CB_nomineeAddress')
        {
            this.CBnomineeAddress = event.detail.value;
        }
        else if(name == 'CB_nomineePinCode')
        {
            this.CBnomineePinCode = event.detail.value;
        }
        else if(name == 'CB_nomineeRelationshipBorrower')
        {
            this.CBnomineeRelationshipBorrower = event.detail.value;
        }
    }
    CBnomineeCitylookupHandler(event){
        const index = event.detail?.index;
        console.log(event.detail);
        let selectedCity;
        if (index == 'nomineeCityIn') {
            this.nomineeCity = event.detail.selectedValueName;
            selectedCity =  event.detail.selectedValueName;
            this.nomineeCityId = event.detail.selectedValueId;
        }else if(index == 'residenceCityIn') {
            this.residenceCityFinacleValue = event.detail.selectedValueName;
            this.residenceCityFinacleId = event.detail.selectedValueId;
        }else if(index == 'permanentCityIn') {
            this.permanentFinacleValue = event.detail.selectedValueName;
            this.permanentFinacleId = event.detail.selectedValueId;
        }else if(index == 'officeCityIn') {
            this.officeCityFinacleValue = event.detail.selectedValueName;
            this.officeCityFinacleId = event.detail.selectedValueId;
        }else if (index == 'CBnomineeCityIn') {
            this.CBnomineeCity = event.detail.selectedValueName;
            this.CBnomineeCityId = event.detail.selectedValueId;
            selectedCity =  event.detail.selectedValueName;
        }else if(index == 'CBresidenceCityIn') {
            this.CBresidenceCityFinacleValue = event.detail.selectedValueName;
            this.CBresidenceCityFinacleId = event.detail.selectedValueId;
        }else if(index == 'CBpermanentCityIn') {
            this.CBpermanentFinacleValue = event.detail.selectedValueName;
            this.CBpermanentFinacleId = event.detail.selectedValueId;
        }else if(index == 'CBofficeCityIn') {
            this.CBofficeCityFinacleValue = event.detail.selectedValueName;
            this.CBofficeCityFinacleId = event.detail.selectedValueId;
        }
        if(selectedCity){
            //apex call to get state of selcted city
            getState({FinacalCityCode : selectedCity})
            .then((resp)=>{
                console.log('resp ',resp);
                const result = JSON.parse(resp);
                if(index == 'nomineeCityIn'){
                    this.nomineeState = result.Name;
                    this.nomineeStateId = result.Id;
                }else if(index == 'CBnomineeCityIn'){
                    this.CBnomineeState = result.Name;
                    this.CBnomineeStateId = result.Id;
                }
            })
            .catch((error)=>{
                console.error('in catch',error)});    
        }
    }
    CBnomineeCityClearvaluelookupHandler(event){
        const index = event.detail?.index;
        if (index == 'nomineeCityIn') {
            this.nomineeCity = '';
            this.nomineeCityId = '';
            this.nomineeState = '';
            this.nomineeStateId = '';
        }else if(index == 'residenceCityIn') {
            this.residenceCityFinacleValue = '';
            this.residenceCityFinacleId = '';
        }else if(index == 'permanentCityIn') {
            this.permanentFinacleValue = '';
            this.permanentFinacleId = '';
        }else if(index == 'officeCityIn') {
            this.officeCityFinacleValue = '';
            this.officeCityFinacleId = '';
        }else if (index == 'CBnomineeCityIn') {
            this.CBnomineeCity = '';
            this.CBnomineeCityId = '';
            this.CBnomineeState = '';
            this.CBnomineeStateId = '';
        }else if(index == 'CBresidenceCityIn') {
            this.CBresidenceCityFinacleValue = '';
            this.CBresidenceCityFinacleId = '';
        }else if(index == 'CBpermanentCityIn') {
            this.CBpermanentFinacleValue = '';
            this.CBpermanentFinacleId = '';
        }else if(index == 'CBofficeCityIn') {
            this.CBofficeCityFinacleValue = '';
            this.CBofficeCityFinacleId = '';
        }
    }
    createWrapperdata(){
        let wrapperData = {};
        if(this.nomineeDetailsforBorrower){
            wrapperData = {
                tvrId :this.tvrId,
                casabankId:this.casabankId,
                applicantId:this.borrowerLoanApplicantId,
                nomineeSAAccountOpening: this.nomineeSAAccountOpening,
                nomineeSAAccountOpenedFor: this.nomineeSAAccountOpenedFor,
                nomineeAvailable: this.nomineeAvailable,
                nomineeName: this.nomineeName,
                nomineeDOB: this.nomineeDOB,
                nomineeAddress: this.nomineeAddress,
                nomineePinCode: this.nomineePinCode,
                nomineeCity: this.nomineeCity,
                nomineeCityId: this.nomineeCityId,
                nomineeState: this.nomineeState,
                nomineeStateId: this.nomineeStateId,
                nomineeRelationshipBorrower:this.nomineeRelationshipBorrower,
                residenceCityFinacle: this.residenceCityFinacleValue,
                residenceCityFinacleId: this.residenceCityFinacleId,
                permanentFinacle: this.permanentFinacleValue,
                permanentFinacleId: this.permanentFinacleId,
                officeCityFinacle: this.officeCityFinacleValue,
                officeCityFinacleId: this.officeCityFinacleId,
            }
        }else if(!this.nomineeDetailsforBorrower){
            wrapperData = {
                tvrId :this.tvrId,
                casabankId:this.casabankId,
                applicantId:this.coBorrowerLoanApplicantId,
                nomineeSAAccountOpening: this.CBnomineeSAAccountOpening,
                nomineeSAAccountOpenedFor: this.CBnomineeSAAccountOpenedFor,
                nomineeAvailable: this.CBnomineeAvailable,
                nomineeName: this.CBnomineeName,
                nomineeDOB: this.CBnomineeDOB,
                nomineeAddress: this.CBnomineeAddress,
                nomineePinCode: this.CBnomineePinCode,
                nomineeCity: this.CBnomineeCity,
                nomineeCityId: this.CBnomineeCityId,
                nomineeState: this.CBnomineeState,
                nomineeStateId: this.CBnomineeStateId,
                nomineeRelationshipBorrower:this.CBnomineeRelationshipBorrower,
                residenceCityFinacle: this.CBresidenceCityFinacleValue,
                residenceCityFinacleId: this.CBresidenceCityFinacleId,
                permanentFinacle: this.CBpermanentFinacleValue,
                permanentFinacleId: this.CBpermanentFinacleId,
                officeCityFinacle: this.CBofficeCityFinacleValue,
                officeCityFinacleId: this.CBofficeCityFinacleId,
            }
        }
        return wrapperData;
    }

    emptyFieldCheck(query) {
        let notEmpty = false;
        [...this.template.querySelectorAll(query)].forEach(inputField => {
            if (inputField.value == null || inputField.value == undefined || inputField.value.trim() == '') {
                notEmpty = true;
            }
        });
        return notEmpty;
    }
}