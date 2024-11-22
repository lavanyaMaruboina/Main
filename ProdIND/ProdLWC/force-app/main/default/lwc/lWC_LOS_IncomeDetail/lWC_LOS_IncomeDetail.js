import { LightningElement, api, wire, track } from 'lwc'; 
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getInputsForIncomeDetails from '@salesforce/apex/Ind_IncomeDetailsCtrl.getInputsForIncomeDetails';
import incomeLegalEntityPicklist from '@salesforce/apex/Ind_IncomeDetailsCtrl.incomeLegalEntityPicklist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INCOME_DETAIL_OBJECT from '@salesforce/schema/Income_Details__c';
import LegalValue from '@salesforce/schema/Income_Details__c.Legal__c';
import updatePrimaryIncomeSource from '@salesforce/apex/Ind_ApplicantService.updatePrimaryIncomeSource';
import KYC_Pin_Code_ErrorMessage from '@salesforce/label/c.KYC_Pin_Code_ErrorMessage';
import KYC_Address_ErrorMessage from '@salesforce/label/c.KYC_Address_ErrorMessage';
import Address_Pattern from '@salesforce/label/c.Address_Pattern';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import firstNameError from '@salesforce/label/c.Name_Er';
import Pin_code_Pattern from '@salesforce/label/c.Pin_code_Pattern';
import Please_fill_all_the_mandatory_fields from '@salesforce/label/c.Fill_All_Required_Fields';//CISP-2723
import All_Details_Stored_Sucessfully from '@salesforce/label/c.All_Details_Stored_Sucessfully';
import Mandatory_fields_are_not_entered from '@salesforce/label/c.Mandatory_fields_are_not_entered';
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
import getStateMasterData from '@salesforce/apex/Utilities.getStateMasterData';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import { NavigationMixin } from 'lightning/navigation';
import BORROWER_RELATIVE_OF_DIRECTOR from '@salesforce/schema/Applicant__c.Is_Borrower_Relative_Of_Director__c';//cisp-20554
import BORROWER_RELATIVE_OF_SENIOR_OFFICER from '@salesforce/schema/Applicant__c.Is_Borrower_Relative_Of_Senior_Officer__c';//cisp-20554
import COBORROWER_RELATIVE_OF_DIRECTOR from '@salesforce/schema/Applicant__c.Is_CoBorrower_Relative_Of_Director__c';//cisp-20554
import COBORROWER_RELATIVE_OF_SENIOR_OFFICER from '@salesforce/schema/Applicant__c.Is_CoBorrower_Relative_Of_Senior_Officer__c';//cisp-20554
import BORROWER_RELATION_WITH_INDUSIND_Q1 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_IndusInd_Q1__c';//cisp-20554
import BORROWER_RELATION_WITH_INDUSIND_Q2 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_IndusInd_Q2__c';//cisp-20554
import BORROWER_RELATION_WITH_OTHERBANK_Q1 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_Other_Bank_Q1__c';//cisp-20554
import BORROWER_RELATION_WITH_OTHERBANK_Q2 from '@salesforce/schema/Applicant__c.Borrower_Relation_With_Other_Bank_Q2__c';//cisp-20554
import COBORROWER_RELATION_WITH_INDUSIND_Q1 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_IndusInd_Q1__c';//cisp-20554
import COBORROWER_RELATION_WITH_INDUSIND_Q2 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_IndusInd_Q2__c';//cisp-20554
import COBORROWER_RELATION_WITH_OTHERBANK_Q1 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_Other_Bank_Q1__c';//cisp-20554
import COBORROWER_RELATION_WITH_OTHERBANK_Q2 from '@salesforce/schema/Applicant__c.CoBorrower_Relation_With_Other_Bank_Q2__c';//cisp-20554
import RELATION_WITH_INDUSIND_OR_OTHER from '@salesforce/schema/Applicant__c.Relationship_With_IndusInd_Or_Other_Bank__c';//cisp-20554
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import APPLICANT_SUBSTAGE from '@salesforce/schema/Applicant__c.Journey_Stage__c';
import APPLICANT_PACS_MEMBER from '@salesforce/schema/Applicant__c.PACS_Member__c';//SFTRAC-241
import APPLICANT_PACS_NAME from '@salesforce/schema/Applicant__c.PACS_Name__c';//SFTRAC-241
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import getValidationInputs from '@salesforce/apex/Ind_IncomeDetailsCtrl.getValidationInputs';
import getCustomerProfileForNE from '@salesforce/apex/Ind_IncomeDetailsCtrl.getCustomerProfileForNE';//CISP-2456
import mapProfileToIncomeDetailsOfNEApplicant from '@salesforce/apex/Ind_IncomeDetailsCtrl.mapProfileToIncomeDetailsOfNEApplicant';//CISP-18498
import updateProfileNameOfApplicant from '@salesforce/apex/Ind_IncomeDetailsCtrl.updateProfileNameOfApplicant';//CISP-2456
import Relationship_with_borrower__c from '@salesforce/schema/Applicant__c.Relationship_with_borrower__c';//CISP-7987 
import Applicant__c from '@salesforce/schema/Applicant__c';//CISP-7987
import getDemographicDetails from '@salesforce/apex/Ind_Demographic.getDemographicDetailsForIncome';//CISP-7987
import getApplicantRelationshipWithBank from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getApplicantRelationshipWithBank';//CISP-20554
export default class LWC_LOS_IncomeDetail extends NavigationMixin(LightningElement) {
    label = {
        KYC_Pin_Code_ErrorMessage,
        KYC_Address_ErrorMessage,
        Address_Pattern,
        RegEx_Alphabets_Only,
        firstNameError,
        Pin_code_Pattern,
        Please_fill_all_the_mandatory_fields,//CISP-2723
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

    
    @api checkleadaccess;//coming from tabloanApplication
    @api isRevokedLoanApplication;
    errorTitle = 'error';
    errorVariant = 'error';
    successTitle = 'Success';
    successVariant = 'success';
    officeAddressDataFields = {};
    @track isEnableNextval = false;
    @track isStepOne = false;
    @track isStepTwo = false;
    @track isStepThree = false;
    @track curnttUser;
    @track isChecked = false;
    @track textDisable = false;
    @track checkboxDisable = false;
    @track formdata = {};
    @track appId;
    @track userdata;
    @api currentStage;
    @track leadSource;//Ola Integration changes
    @track isLoading = false;
    showAccordianData = true;
    @track incomeDetailsArray = [];
    counter = 0;
    buttonLabel = 'Add Income Source';
    @track currentStep = 'Income Details';
    checking = false;
    _tabValue;
    coBorrowerRecordId;
    @api 
    set tabValue(value){
        this._tabValue= value;
    }
    get tabValue(){
        return this._tabValue;
    }
    @api recordid;
    @api tab;
    // CISP-2752
    @track _activeTab;
    @api set activeTab(value){
        this._activeTab = value;
    }
    get activeTab(){
        return this._activeTab;
    }
    // CISP-2752-END
    @api tabList;
    isIncomeSourcePresent = true;
    isBankAccountPresent = false;
    isIBLBankAccountPresent = false;
    recordCounter;
    isPanAvailable = false;
    isTwoWheelerType = false;
    isBankAcctAvailable = false;
    isIBLBankAcctAvailable = false;
    addOnlyOneIncomeSource = false;
    serverdata = [];
    @api applicantId;
    legalValue = 'Individual';
    emiValue = false;
    validButton = false;
    incomeSourceActive;
    addIncomeSourceDisabled = false;
    @track incomeSourceStatusValue;
    @track lastStage;
    @track currentStageName;
    @track showFileUploadAndView = false;
    @track isEnableUploadViewDoc = true;
    @track isMSILLeadId;//CISP-2664
    @track isCoBorrowerExist = false;//CISP-7987
    relationshipWithBorrower;//CISP-7987
    relationshipValue;//CISP-7987  
    leadNumber;
    emailId;
    firstName;
    //CISP-2456
    profileNames = [];
    profileValue ='';
    disabledProfileOption = false;
    isPVProduct = false;//CISP-7987
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
    BorrowerRelationWithIndusIndQuestion1Answer;//CISP-20554
    BorrowerRelationWithIndusIndQuestion2Answer;//CISP-20554
    BorrowerRelationWithOtherBankQuestion1Answer;//CISP-20554
    BorrowerRelationWithOtherBankQuestion2Answer;//CISP-20554
    CoBorrowerRelationWithIndusIndQuestion1Answer;//CISP-20554
    CoBorrowerRelationWithIndusIndQuestion2Answer;//CISP-20554
    CoBorrowerRelationWithOtherBankQuestion1Answer;//CISP-20554
    CoBorrowerRelationWithOtherBankQuestion2Answer;//CISP-20554
    @track productType = '';
    @track isTractor = false;
    @track nonTractor = false;
    @track applicantType = '';
    @track isNonIndividual = false;
    @track isNotIndividual = true;
    @track legalEntities =[];
    @track disablePACSFields = false;
    @track pacsMember;//SFTRAC-241
    @track pacsName;//SFTRAC-241
    entityValue;
    everythingDisabled = false;
    get pacsOptions() {//SFTRAC-241
           return [
        {label : 'Yes', value: 'Y'},
        {label : 'No', value: 'N'}
           ];
    }
    get isEnableNext() {
        return this.currentStep !== 'Run EMI Engine';

    }
    get isEnablePrev() {
        if (this.currentStep === 'Run EMI Engine' || this.currentStep === 'Office Address for primary Income Source') {
            return true;
        }
    }
    // CISP-2456
    get options() {
        let newValues = this.profileNames.map((item) => {
            return {
                label : `${item.Name}`, value: `${item.Name}`
            };
        });
        return newValues;
    }
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
    get ifCoBorrowerIsTheTab() {
        if(this.applicantId == this.coBorrowerRecordId)
        return true;
        else
        return false;
    }
    @wire(getObjectInfo, { objectApiName: INCOME_DETAIL_OBJECT })
    incomeDetailMetaData;

    @wire(getPicklistValues,
        {
            recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId',
            fieldApiName: LegalValue
        }
    )
    legalData;
    @wire(getObjectInfo, { objectApiName: Applicant__c }) objectInfo;//CISP-7987  
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Relationship_with_borrower__c }) relationshipWithBorrower;//CISP-7987 
    @track allStateData;
    @wire(getStateMasterData) wiredAccounts({ error, data }) {
        if (data) {
            let finalArrayTopush = [];
            if (data.length > 0) {
                for (let index = 0; index < data.length; index++) {
                    let stateValue = {};
                    stateValue.label = data[index].Name;
                    stateValue.value = data[index].Name;
                    stateValue.id = data[index].Id;
                    finalArrayTopush.push(stateValue);
                }
            }
            this.allStateData = finalArrayTopush;
        } if (error) {
        }
    }
    
    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    
    @api currentApplicantStage;//CISP-2966
    async connectedCallback() {
        console.log('Current Step ::', this.currentStep);
        console.log('Current currentStage ::', this.currentStage);
        console.log('activeTab : ',this.activeTab);
        if(this.activeTab != 'Borrower'){this.isCoBorrowerExist = true;}else{this.isCoBorrowerExist = false;}//CISP-7987  
        await this.init();
        
        this.callAccessLoanApplication();
        this.doGetApplicantRelationshipWithBank();
    }

    handleChangeValue(event) {
        let name = event.currentTarget.name;
        switch (name) {
            case 'pacsMember':
                this.pacsMember = event.currentTarget.value;
                break;
            case 'pacsName':
                this.pacsName = event.currentTarget.value;
                break;    
            default:
                break;
        }
    }

    async init() {
        console.log('Current Step 1 ::', this.currentStep);

        await incomeLegalEntityPicklist().then(result =>{
            console.log('legalEntities result'+JSON.stringify(result));

            if(Object.keys(result)) {
                let keys = Object.keys(result);
                let tempLegal = [];
    
                keys.forEach(each=>{
                    tempLegal.push({value: each, label: result[each]})
                });
    
                this.legalEntities = tempLegal;
                console.log('legalEntities '+this.legalEntities);
            }
        })


        await getInputsForIncomeDetails({ opportunityId: this.recordid, applicantType: this.tabValue, applicantId : this.applicantId}).then(response => {


            let applicantData = JSON.parse(response.applicantData);

            //SFTRAC-241
            let applicantDataRec = response.applicantDataRecord;
            this.pacsMember = applicantDataRec.PACS_Member__c;
            this.pacsName = applicantDataRec.PACS_Name__c;

            if(response.productType == 'Tractor'){
                this.isTractor = true;
                this.legalValue = response?.entityType;
                this.entityValue = response?.entityCategory;
                if(this.pacsMember && this.pacsName){
                    this.disablePACSFields = true;
                }
                if(response.entityType == 'Non-Individual') {
                    this.isNonIndividual = true;
                }
                if(response.entityType == 'Individual'){
                    this.isNotIndividual = false;
                }
            
                if(applicantData.legalEntity == 'Individual'){
                    this.legalEntities = this.legalEntities.filter(item => item.value == 'Individual');

                }
                else{
                    this.legalEntities = this.legalEntities.filter(item => item.value !== 'Individual');
                }
            }else{
                this.nonTractor = true;
            }



            if(applicantData.currentStage){
                if(response.productType == 'Tractor' && response.entityType == 'Individual') {
                    this.currentStep = 'Run EMI Engine';
                }else if(this.currentStage == 'Credit Processing'){
                    this.currentStep = 'Income Details';
                }else{
                    this.currentStep = applicantData.currentStage;
                }
            }
            // CISP-2966-END
            if(this.currentApplicantStage && this.currentStep != this.currentApplicantStage){
                this.currentStep = this.currentApplicantStage;
            }
            // CISP-2966-END
            this.lastStage = response?.lastStage;
            this.currentStageName = response?.currentStageName;

            console.log('Applicant Type ' + this.tabValue);
            console.log('Current Stage::', applicantData.currentStage);
            console.log('Applicant Id::', this.applicantId);
            console.log('Saved Income Details:: ', response.incomeDetails);

            if (response.applicantId && !this.isTractor) {
                this.applicantId = response.applicantId;
            }
            if(response.applicantDataRecord.Applicant_Type__c) {
                this.applicantType = response.applicantDataRecord.Applicant_Type__c;
                console.log('response.applicantDataRecord.Applicant_Type__c::'+response.applicantDataRecord.Applicant_Type__c);
            }

            if (this.currentStep === 'Office Address for primary Income Source') {
                this.isStepOne = false;
                this.isStepThree = false;
                this.isStepTwo = true;
            } else if (this.currentStep === 'Run EMI Engine' || (response.productType == 'Tractor' && response.entityType == 'Individual')) {
                this.isStepOne = false;
                this.isStepTwo = false;
                this.isStepThree = true;
            } else if (this.currentStep === 'Income Details') {
                this.isStepOne = true;
                this.isStepTwo = false;
                this.isStepThree = false;
            }

            if (response.applicantData) {
                let applicantData = JSON.parse(response.applicantData);
                
                if (applicantData.incomeDetailCount) {
                    this.recordCounter = applicantData.incomeDetailCount;
                }

                if(this.isTractor){
                    this.isIncomeSourcePresent = true;
                }else if (applicantData.isIncomeSourcePresent) {
                    this.isIncomeSourcePresent = applicantData.isIncomeSourcePresent;
                } else {
                    // start CISP-2456
                    this.isIncomeSourcePresent = false;
                    this.profileValue = response.applicantDataRecord.Profile__c;
                    getCustomerProfileForNE().then( (item) => {
                        this.profileNames = item;
                        console.log('item: ',this.profileNames);
                    })
                    .catch( (error) => {
                        console.log('error: ',error)
                    })
                    // end CISP-2456
                }

                console.log('Income Source Present ' + this.isIncomeSourcePresent);

                this.isBankAcctAvailable = applicantData.isBankAccountPresent;
                this.isIBLBankAcctAvailable = applicantData.isIBLBankAccountPresent;
                this.emailId = applicantData.emailId;
                this.firstName = applicantData.firstName;
            }

            if (response.isPanAvailable) {
                this.isPanAvailable = true;
            } else {
                this.isPanAvailable = false;
            }

            this.productType = response.productType;

            //Check Product Type 
            if (response.productType === 'Two Wheeler') {
                this.addOnlyOneIncomeSource = true;
                this.isTwoWheelerType = true;
            } else {
                this.addOnlyOneIncomeSource = false;
                this.isTwoWheelerType = false;
            }
            if (response.productType === 'Passenger Vehicles'){
                this.isPVProduct = true;
            }else{
                this.isPVProduct = false;
            }

            this.leadNumber = response.leadNumber;
            this.isMSILLeadId = response.leadSource;//CISP-2664
            this.leadSource = response.leadSourceValue;//Ola Integration changes
            if (response.incomeDetails && response.incomeDetails.length > 0) {
                this.serverdata = response.incomeDetails;
                if (this.serverdata && this.serverdata.length > 0) {
                    for (let i = 0; i < this.serverdata.length; i++) {
                        ++this.counter;

                        if (this.serverdata[i].Primary_Income_Source__c === true) {
                            this.addIncomeSourceDisabled = true;
                        }

                        this.serverdata[i].key = 'Accordian' + this.counter;
                        this.serverdata[i].accordianName = 'IncomeSource' + this.counter;
                        this.serverdata[i].label = 'Income Source ' + this.counter;
                        this.serverdata[i].isDeleteDisable = true;
                        this.serverdata[i].isDeleteButton = (i == this.serverdata.length - 1) ? true : false;
                        this.serverdata[i].isFromDatabase = true;
                        this.incomeDetailsArray.push(this.serverdata[i]);
                    }

                    if (this.addOnlyOneIncomeSource) {
                        this.buttonLabel = 'Add Income Source';
                    } else {
                        this.buttonLabel = 'Add Income Source ' + (this.counter + 1);
                        this.addData = true;
                    }
                }
            }

            console.log('Income Details Array:: ', JSON.stringify(this.incomeDetailsArray));

            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            console.log('getInputsForIncome - Error:: ', error);
        }); 
        //CISP-7987 
        getDemographicDetails({opportunityId: this.recordid, applicantType: this.tabValue })
          .then(result => {
            console.log('Result', result);
            if(result){
            this.relationshipValue = result.applicantRecord?.Relationship_with_borrower__c;
            this.isPVProduct = result.applicantRecord?.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ? true : false;
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });//CISP-7987  
    }
    // CISP-2456
    handleProfileNameChange(event) {
        this.profileValue = event.detail.value;
        console.log('selected values is: ',this.profileValue);
    }
    incomeSourceStatus(event) {
        this.incomeSourceStatusValue = event.detail;
        console.log('Income Source Status:: ', this.incomeSourceStatusValue);
    }
    // CISP-2456
    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }
    //CISP - 18498 - START
    async mapNEProfiletoIncomeDetail()
    {
        await mapProfileToIncomeDetailsOfNEApplicant({applicantId: this.applicantId , profileName: this.profileValue}).then( (res) => {
            console.log(res);
        }).catch((error) => {
            console.log(error)
        })
    }
    //CISP - 18498 - END
    currentStepNew = 'Income Details';
    async handleNext() {
        try{
        console.log('OUTPUT handleNext: ', this.currentStep);
        //if(this.nonTractor)//CISP-20554 - START
        //{
            if(!this.everythingDisabled)
            {    
            if(this.isCoBorrowerExist)
            {
                if(this.isCoBorrowerRelativeOfDirectorAnswer == null || this.isCoBorrowerRelativeOfDirectorAnswer == undefined || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == null || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == undefined)
                {
                    this.showToastMessage('', 'Please complete declaration content', 'error');
                    return;
                }
                else if(this.IsRelationshipWithIndusIndOrOtherBank == 'IndusInd Bank' && (this.isCoBorrowerRelativeOfDirectorAnswer == 'Yes' || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == 'Yes'))
                {
                    if(this.CoBorrowerRelationWithIndusIndQuestion1Answer == null || this.CoBorrowerRelationWithIndusIndQuestion1Answer == undefined || this.CoBorrowerRelationWithIndusIndQuestion2Answer == null || this.CoBorrowerRelationWithIndusIndQuestion1Answer == undefined)
                    {
                        this.showToastMessage('', 'Please complete declaration content', 'error');
                        return;
                    }
                }
                else if(this.IsRelationshipWithIndusIndOrOtherBank == 'Other Bank' && (this.isCoBorrowerRelativeOfDirectorAnswer == 'Yes' || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == 'Yes'))
                {
                    if(this.CoBorrowerRelationWithOtherBankQuestion1Answer == null || this.CoBorrowerRelationWithOtherBankQuestion1Answer == undefined || this.CoBorrowerRelationWithOtherBankQuestion2Answer == null || this.CoBorrowerRelationWithOtherBankQuestion2Answer == undefined)
                    {
                        this.showToastMessage('', 'Please complete declaration content', 'error');
                        return;
                    }
                }
                else if((this.IsRelationshipWithIndusIndOrOtherBank == null || this.IsRelationshipWithIndusIndOrOtherBank == undefined) && (this.isCoBorrowerRelativeOfDirectorAnswer == 'Yes' || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == 'Yes'))
                {
                    this.showToastMessage('', 'Please complete declaration content', 'error');
                    return;
                }
            }
            else
            {
                if(this.leadSource != 'D2C')
                {
                if(this.isBorrowerRelativeOfDirectorAnswer == null || this.isBorrowerRelativeOfDirectorAnswer == undefined || this.isBorrowerRelativeOfSeniorOfficerAnswer == null || this.isBorrowerRelativeOfSeniorOfficerAnswer == undefined)
                {
                    this.showToastMessage('', 'Please complete declaration content', 'error');
                    return;
                }
                else if(this.IsRelationshipWithIndusIndOrOtherBank == 'IndusInd Bank' && (this.isBorrowerRelativeOfDirectorAnswer == 'Yes' || this.isBorrowerRelativeOfSeniorOfficerAnswer == 'Yes'))
                {
                    if(this.BorrowerRelationWithIndusIndQuestion1Answer == null || this.BorrowerRelationWithIndusIndQuestion1Answer == undefined || this.BorrowerRelationWithIndusIndQuestion2Answer == null || this.BorrowerRelationWithIndusIndQuestion1Answer == undefined)
                    {
                        this.showToastMessage('', 'Please complete declaration content', 'error');
                        return;
                    }
                }
                else if(this.IsRelationshipWithIndusIndOrOtherBank == 'Other Bank' && (this.isBorrowerRelativeOfDirectorAnswer == 'Yes' || this.isBorrowerRelativeOfSeniorOfficerAnswer == 'Yes'))
                {
                    if(this.BorrowerRelationWithOtherBankQuestion1Answer == null || this.BorrowerRelationWithOtherBankQuestion1Answer == undefined || this.BorrowerRelationWithOtherBankQuestion2Answer == null || this.BorrowerRelationWithOtherBankQuestion2Answer == undefined)
                    {
                        this.showToastMessage('', 'Please complete declaration content', 'error');
                        return;
                    }
                }
                else if((this.IsRelationshipWithIndusIndOrOtherBank == null || this.IsRelationshipWithIndusIndOrOtherBank == undefined) && (this.isCoBorrowerRelativeOfDirectorAnswer == 'Yes' || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == 'Yes'))
                {
                    this.showToastMessage('', 'Please complete declaration content', 'error');
                    return;
                }
            }
            }
        }
        //} //CISP-20554 - END
        if (this.currentStageName === 'Credit Processing' || this.currentStageName != 'Income Details') {
            if (this.currentStep === 'Income Details' || this.currentStep !== 'Office Address for primary Income Source') {
                if(this.isTractor && this.currentStep !=='Run EMI Engine'){ // SFTRAC-40: Skip Office address screen 
                    this.currentStep = 'Run EMI Engine';
                    this.isStepThree = true;
                    this.isStepTwo = false;
                    this.isStepOne = false;
                }
                else {
                this.currentStep = 'Office Address for primary Income Source';
                this.isStepTwo = true;
                this.isStepOne = false;
                }
            } else if (this.currentStep === 'Office Address for primary Income Source') {
                this.currentStep = 'Run EMI Engine';
                this.isStepThree = true;
                this.isStepTwo = false;
            }
        } else {
            // start CISP-2456
            if(!this.tabValue){
                this.showToastMessage('', 'Please select the tab', 'warning');
                return;
            }
            if (!this.validityCheck('lightning-combobox')) {
                this.showToastMessage('', this.label.Please_fill_all_the_mandatory_fields, 'warning');//CISP-2723
                return;
            }
            if (!this.validityCheck('lightning-input')) {
                this.showToastMessage('', this.label.Please_fill_all_the_mandatory_fields, 'warning');
                return;
            }
            let response = await getInputsForIncomeDetails({ opportunityId: this.recordid, applicantType: this.tabValue, });
            let applicantData = JSON.parse(response.applicantData);
            if((this.isIncomeSourcePresent === false || applicantData.isIncomeSourcePresent == false) && !this.isTractor) {     
                if(!this.profileValue){
                    this.showToastMessage('', this.label.Please_fill_all_the_mandatory_fields, 'warning');
                    return;
                }          
                await updateProfileNameOfApplicant({applicantId: this.applicantId , profileName: this.profileValue}).then( (val) => {
                    console.log('profile updated');
                    this.mapNEProfiletoIncomeDetail();
                })
                .catch( (error) => {
                    console.log(error)
            console.log('in else part : ',);
                })
            }
            // end CISP-2456
            //CISP-2723-START
            //CISP-2664-START
            // if(this.isMSILLeadId){
            //CISP-3092-START
            // let incomeElement = await this.template.querySelector('c-l-w-c_-l-o-s_-income-source');
            // if(incomeElement){
            //     let res = await incomeElement.isfieldsCompleted('', 'save');
            //     if(res){
            //         return;
            //     }
            // }
            console.log('376');
            let incomeElements;
            if(this.isNonIndividual) {
                incomeElements = await this.template.querySelectorAll('c-l-w-c_-l-o-s_-income-source-tractor[data-id=accordianIncomeDetail]');
            } else{
                incomeElements = await this.template.querySelectorAll('c-l-w-c_-l-o-s_-income-source[data-id=accordianIncomeDetail]');
            }
            let isValid = true;
            let indexValue = 0;

            if (incomeElements) {
                for (let index = 0; index < incomeElements.length; index++) {
                    let value = await incomeElements[index].isfieldsCompleted('', 'save');
                    if (value) {
                        isValid = false;
                        indexValue = index + 1;
                        break;
                    }
                }

                if (!isValid) {
                    // const evt = new ShowToastEvent({
                    //     message: 'Please validate Income Source ' + indexValue + ' First Before Adding Income Source',
                    //     variant: 'error',
                    // });
                    // this.dispatchEvent(evt);
                    return;
                }
            }
            //CISP-3092-END
            // }
            //CISP-2664-END
            //CISP-2723-END
            let isEarningApplicant = false;
            let isIncomeSourcesExists = false;

            if (this.currentStep === 'Income Details') {
                this.disabledProfileOption = true;//CISP-2456
                if(this.incomeSourceStatusValue === 'NIP') {
                    await this.template.querySelector('c-l-w-c_-l-o-s_-income-source').isfieldsCompleted('', 'save');
                }

                await getValidationInputs({ applicantId: this.applicantId }).then(response => {
                    let result = JSON.parse(response);
                    console.log('getValidationInputs - Result:: ', result);
                    isEarningApplicant = result.isEarningApplicant;
                    isIncomeSourcesExists = result.isIncomeSourcesExists;

                if(isEarningApplicant === false || (isEarningApplicant && isIncomeSourcesExists)){
                    updatePrimaryIncomeSource({ applicantId: this.applicantId }).then(response => {
                        console.log('updatePrimaryIncomeSource - Response:: ', response);
                        
                        if(this.isTractor) { // SFTRAC 40
                            this.currentStepNew = 'Run EMI Engine';
                            this.currentStep = 'Run EMI Engine';
                            this.isStepThree = true; // SFTRAC 40
                            this.isStepOne = false;
                            this.isStepTwo = false;
                        } else{
                            this.currentStepNew = 'Office Address for primary Income Source';
                            this.currentStep = 'Office Address for primary Income Source';
                            this.isStepTwo = true;
                            this.isStepOne = false;
                        }
                        const applicantsFields = {};
                        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                        applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;
                        this.updateRecordDetails(applicantsFields);

                        this.addIncomeSourceDisabled = true;
                        // this.isStepTwo = true;
                        // this.isStepOne = false;
                    }).catch(error => {
                        console.log('updatePrimaryIncomeSource - Error:', error);
                    });
                } else {
                    this.showToastMessage('', 'Add Income Details to proceed further', 'warning');
                    return;
                }

                }).catch(error => {
                    console.log('getValidationInputs - Error:', error);
                    this.showToastMessage('', 'Error in getValidationInputs', 'error');
                });
                if(this.isTractor && !this.disablePACSFields){
                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                    applicantsFields[APPLICANT_PACS_MEMBER.fieldApiName] = this.pacsMember;
                    applicantsFields[APPLICANT_PACS_NAME.fieldApiName] = this.pacsName;
                    this.updateRecordDetails(applicantsFields);
                    this.disablePACSFields = true;
                }
            } else if (this.currentStep === 'Office Address for primary Income Source') {
                this.disabledProfileOption = true;//CISP-2456
                await getValidationInputs({ applicantId: this.applicantId }).then(response => {
                    let result = JSON.parse(response);
                    console.log('getValidationInputs - Result:: ', result);
                    isEarningApplicant = result.isEarningApplicant;
                    isIncomeSourcesExists = result.isIncomeSourcesExists;

                //Allow only if Income Source Exists
                if(isEarningApplicant === false || (isEarningApplicant && isIncomeSourcesExists)){
                    if(isEarningApplicant){
                        let isOfficeAddrssInput = this.template.querySelector('c-L-W-C_-L-O-S_-Income-Office-Address');

                        if(isOfficeAddrssInput && !isOfficeAddrssInput.checkForOfficeAddressValidy()){
                            return;
                        }
                    }

                    this.currentStep = 'Run EMI Engine';
                    if (this.currentStage != 'Credit Processing' || this.currentStageName !== 'Loan Initiation' || this.currentStageName !== 'Additional Details' || this.currentStageName !== 'Vehicle Valuation' || this.currentStageName !== 'Vehicle Insurance' || this.currentStageName !== 'Loan Details' || (this.currentStageName !== 'Income Details' && this.lastStage === 'Income Details')) {
                        const evt = new ShowToastEvent({ title: this.successTitle, message: All_Details_Stored_Sucessfully, variant: this.successVariant, });
                        this.dispatchEvent(evt);
                    }

                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                    applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;
                    this.updateRecordDetails(applicantsFields);

                    this.isStepThree = true;
                    this.isStepTwo = false;
                } else {
                    this.showToastMessage('', 'Add Income Details to proceed further', 'warning');
                    return;
                }

                }).catch(error => {
                    console.log('getValidationInputs - Error:', error);
                    this.showToastMessage('', 'Error in getValidationInputs', 'error');
                });
            }
        }
        }catch(error){
            console.error('errorobject',error);
            if(error.body.message == 'Disconnected or Canceled'){
                  this.showToastMessage('', 'Please check your network connection and retry', 'error');
            }
            else{
              
                this.showToastMessage('', 'something went wrong', 'error');
            }
        }
    }

    async handlePrev() {
        this.isLoading = true;
        console.log('Prev Value ::', this.currentStep, '', this.applicantId);
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        if (this.currentStep === 'Office Address for primary Income Source') {
            this.currentStepNew = 'Office Address for primary Income Source';
            this.currentStep = 'Income Details';
            this.isStepOne = true;
            this.isStepTwo = false;
            this.disabledProfileOption = true;//CISP-2456
            applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;
            // CISP-3092-START
            let incomeElements = await this.template.querySelectorAll('c-l-w-c_-l-o-s_-income-source[data-id=accordianIncomeDetail]');
            for (let index = 0; index < incomeElements.length; index++) {
                await incomeElements[index].disableEverything();
            }
            this.disableEverything();
            //CISP-3092-END
        } else if (this.currentStep === 'Run EMI Engine') {
            if(this.isTractor) {//SFTRAC40
                this.currentStep = 'Income Details';
                this.isStepOne = true; 
                this.isStepTwo = false;
                this.isStepThree = false;
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;
            } else{
                this.currentStep = 'Office Address for primary Income Source';
                this.isStepTwo = true;
                this.isStepThree = false;
                this.disabledProfileOption = true;//CISP-2456
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;
            }
            // this.isStepTwo = true;
            // this.isStepThree = false;
            // this.disabledProfileOption = true;//CISP-2456
            // applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;
        }
        if (this.currentStageName == 'Income Details'){
            await this.updateRecordDetails(applicantsFields).then((result) => {
                console.log('On Previous Stage updated successfully:', result);
            }).catch(error => {
                console.log('updatePrimaryIncomeSource - Error:', error);
            });
            this.counter = 0;
            this.serverdata.splice(0, this.serverdata.length);
            this.incomeDetailsArray.splice(0, this.incomeDetailsArray.length);
    
            console.log('Server Dats Size ::', this.serverdata.length);
            console.log('Income Details Size ::', this.incomeDetailsArray.length);
    
            await this.init();
        }
        this.isLoading = false;
        if(this.isTractor){
            this.disablePACSFields = true;;
        }
    }

    showToastMessage(title, message, variant) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
            }));
        }
    }

    async updateRecordDetails(fields) {
        console.log('Update Record ::', fields);
        const recordInput = { fields };
        await updateRecord(recordInput).then(() => {
            console.log('Record Update Successful::', fields);
        }).catch(error => {
            console.log('Record Update failed::', fields);
            let errorMsg = window.errorMsgToShow(error);
            throw errorMsg;
        });
    }

    addData = false;
    addIncomeSource() {

        //SFTRAC-241
        if (this.counter >= 0 && this.isTractor) {
            if(!this.pacsMember || !this.pacsName){
                const evt = new ShowToastEvent({
                    title: "warning",
                    message: 'Please enter mandatory fields!',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                let pacsFields = this.template.querySelectorAll('[data-name=pacsfields]');
                if(pacsFields){
                    pacsFields.forEach(element => {
                        if(!element.value){
                            element.reportValidity();
                        }
                    });
                }
                return;
            }
            const applicantsFields = {};
            applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
            applicantsFields[APPLICANT_PACS_MEMBER.fieldApiName] = this.pacsMember;
            applicantsFields[APPLICANT_PACS_NAME.fieldApiName] = this.pacsName;
            this.updateRecordDetails(applicantsFields);
            this.disablePACSFields = true;
        }
        let abc;
        if(this.isNonIndividual) {
            abc = this.template.querySelectorAll('c-l-w-c_-l-o-s_-income-source-tractor[data-id=accordianIncomeDetail]');
        } else{
            abc = this.template.querySelectorAll('c-l-w-c_-l-o-s_-income-source[data-id=accordianIncomeDetail]');
        }
        let isValid = true;
        let indexValue = 0;
        if (!this.addData && this.counter === 1) {
            const evt = new ShowToastEvent({
                title: "warning",
                message: 'Only One Income Source Allowed for Two Wheeler.',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            return null;
        }

        if (abc) {
            for (let index = 0; index < abc.length; index++) {
                let value = abc[index].checkValidate;//CISP-3092
                if (value == false) {
                    isValid = false;
                    indexValue = index + 1;
                    break;
                }
            }

            if (!isValid) {
                const evt = new ShowToastEvent({
                    message: 'Please complete Income Source ' + indexValue + ' First Before Adding Income Source',
                    variant: 'error',
                });//CISP-3092
                this.dispatchEvent(evt);
                return null
            }
        }

        if (this.counter != 0) {
            if (this.incomeDetailsArray[this.counter - 1].isActive == false) {
                this.incomeDetailsArray.pop();
                --this.counter;
                
                if (this.counter != 0) {
                    this.incomeDetailsArray[this.counter].isDeleteButton = true;
                }
            } else {
                this.incomeDetailsArray[this.counter - 1].isDeleteButton = false;
                this.incomeDetailsArray[this.counter - 1].isDeleteDisable = true;
            }
        }

        ++this.counter;
        this.incomeDetailsArray.push({
            key: 'Accordian' + this.counter, accordianName: 'IncomeSource' + this.counter,
            label: 'Income Source ' + this.counter, isDeleteButton: true, isDeleteDisable: false,
            isFromDatabase: false
        });

        if (!this.showAccordianData) {
            this.showAccordianData = true;
        }

        if (this.addOnlyOneIncomeSource) {
            this.buttonLabel = 'Add Income Source ';
            this.addData = false;
        } else if (!this.addOnlyOneIncomeSource) {
            this.buttonLabel = 'Add Income Source ' + (this.counter + 1);
            this.addData = true;
        }

        const accordion = this.template.querySelector('.example-accordion');
        this.incomeSourceActive = this.incomeDetailsArray[this.incomeDetailsArray.length - 1].accordianName;
    }

    renderedCallback() {
        console.log('OUTPUT relationshipWithBorrower: ',this.relationshipWithBorrower);  
        //console.log('Rendered callback incomeDetailsArray: ',JSON.stringify(this.incomeDetailsArray));
        if (this.addData) {
            const accordion = this.template.querySelector('.example-accordion');

            if (this.incomeDetailsArray[this.incomeDetailsArray.length - 1]) {
                this.incomeSourceActive = this.incomeDetailsArray[this.incomeDetailsArray.length - 1]?.accordianName;//CISP-3092
            }

            if (accordion) {
                accordion.activeSectionName = this.incomeDetailsArray[this.incomeDetailsArray.length - 1]?.accordianName;//CISP-3092
            }
        }

        if (this.cumCheckbox === true) {
            this.disableCumCheckbox = true;
        }
        if (this.currentStage === 'Credit Processing' || this.currentStageName === 'Loan Initiation' || this.currentStageName === 'Additional Details' || this.currentStageName === 'Vehicle Valuation' || this.currentStageName === 'Vehicle Insurance' || this.currentStageName === 'Loan Details' || (this.currentStageName !== 'Income Details' && this.lastStage !== 'Income Details' && this.lastStage != undefined && this.currentStageName != undefined)) {//CISP-519
            this.disableEverything();
            this.disablePACSFields = true;
            if(!this.isTractor){
                this.isEnableNextval = true;
            }

            if (this.template.querySelector('.final')) { this.template.querySelector('.final').disabled = false; }
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }

    
    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordid , stage: 'Income Details'}).then(response => {
            console.log('accessLoanApplication Response:: ', response);
            if(!response){ 
                this.disableEverything();
                console.log('here 2');
                if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                    const evt = new ShowToastEvent({
                        title: 'You do not have access for this Loan Application',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    console.log('from tab loan');
                    this.disableEverything();
                }
            }
          }).catch(error => {
              console.log('Error in accessLoanApplication:: ', error);
          });
    }

    deleteAccordian(event) {
        this.incomeDetailsArray.pop();
        if (this.incomeDetailsArray.length > 0) {
            this.incomeDetailsArray[this.counter - 2].isDeleteButton = true;
        }
        --this.counter;

        if (this.counter != 0) {
            this.buttonLabel = 'Add Income Source ' + (this.counter + 1);
        } else {
            this.buttonLabel = 'Add Income Source';
        }

        const accordion = this.template.querySelector('.example-accordion');
        if (this.counter != 0) {
            accordion.activeSectionName = this.incomeDetailsArray[this.counter - 1].accordianName;
        }
    }

    handleLegalValue(event) {
        this.legalValue = event.target.value;
    }

    checkForOfficeAddressValidy() {
        let formdataNameInput = this.template.querySelector('lightning-input[data-id=employeeNameId]');
        let formdataAddressInput = this.template.querySelector('lightning-input[data-id=addressLineOneId]');
        let formdataAddressTwoInput = this.template.querySelector('lightning-input[data-id=addressLineTwoId]');
        let formdataAddressPinCodeInput = this.template.querySelector('lightning-input[data-id=addressPinCodeId]');
        let formdataAddressDistrict = this.template.querySelector('lightning-input[data-id=addressDistrictId]');

        let formdateCityInput = this.template.querySelector('lightning-combobox[data-id=addressCityId]');
        let formdateStateInput = this.template.querySelector('lightning-combobox[data-id=kycStateDataId]');

        formdataNameInput.reportValidity();
        formdataAddressInput.reportValidity();
        formdataAddressTwoInput.reportValidity();
        formdataAddressPinCodeInput.reportValidity();
        formdataAddressDistrict.reportValidity();
        formdateCityInput.reportValidity();
        formdateStateInput.reportValidity();

        if (formdataNameInput.validity.valid === false || formdataAddressInput.validity.valid === false || formdataAddressTwoInput.validity.valid === false ||
            formdataAddressPinCodeInput.validity.valid === false || formdataAddressDistrict.validity.valid === false || formdateCityInput.validity.valid === false
            || formdateStateInput.validity.valid === false) {
            const evt = new ShowToastEvent({
                title: this.errorTitle,
                message: Mandatory_fields_are_not_entered,
                variant: this.errorVariant,
            });
            this.dispatchEvent(evt);
            return null;
        }
        return true;
    }

    finalTempsubmit(event) {
        let validityvalue = this.checkForOfficeAddressValidy();
        if (validityvalue == null) {
            return validityvalue;
        }
    }

    cumCheckbox;
    handleCurrentCumCheckbox(event) {
        this.cumCheckbox = event.detail;
    }

    disableCumCheckbox = false;
    handleDisableCurrentCumCheckbox(event) {
        this.disableCumCheckbox = event.detail;
    }

    handleHome() {
        // await this.handleSubmit(); // call method from EMI to add validation
        console.log('Current Step ::', this.currentStep);
        if (this.currentStep === 'Income Details') {
            if (this.counter === '0') {
                this.navigateToHomePage();
            } else {
                this.template.querySelector('c-l-w-c_-l-o-s_-income-source').saveDetails();
                this.navigateToHomePage();
            }

        } else if (this.currentStep === 'Office Address for primary Income Source') {
            this.template.querySelector('c-L-W-C_-L-O-S_-Income-Office-Address').saveDetails();
            this.navigateToHomePage();
        } else if (this.currentStep === 'Run EMI Engine') {
            this.navigateToHomePage();
        }
    }

    navigateToHomePage() {
        isCommunity().then(response => {
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
        }).catch(error => {
            console.log('navigateToHomePage - error ::', error);
        });
    }
    handleOnfinish(event) {
        const evnts = new CustomEvent('finalvaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

    viewUploadViewFloater(){
        this.showFileUploadAndView = true;
    }
    closeUploadViewFloater(event){
        this.showFileUploadAndView = false;
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
        
        if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }
        if (this.template.querySelector('.prev')) { this.template.querySelector('.prev').disabled = false; }
        this.everythingDisabled = true;
    }
    //CISP-7987 start
    handleRelationshipType(event){
        const applicantsFields = {}; 
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId; 
        applicantsFields[Relationship_with_borrower__c.fieldApiName] = event.target.value;  
        this.updateRecordDetails(applicantsFields); 
    }//CISP-7987 
//CISP-20554 - START
handleCoBorrowerRelativeOfDirector(event)
{
    this.isCoBorrowerRelativeOfDirectorAnswer = event.target.value;
    if(event.target.value == 'Yes')
    this.isCoBorrowerOptedYes = true;
    else
    {
        if(this.isCoBorrowerRelativeOfSeniorOfficerAnswer == null || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == undefined || this.isCoBorrowerRelativeOfSeniorOfficerAnswer == 'No')
        this.isCoBorrowerOptedYes = false;
    }
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[COBORROWER_RELATIVE_OF_DIRECTOR.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}
handleCoBorrowerRelativeOfSeniorOfficer(event)
{
    this.isCoBorrowerRelativeOfSeniorOfficerAnswer = event.target.value;
    if(event.target.value == 'Yes')
    this.isCoBorrowerOptedYes = true;
    else
    {
        if(this.isCoBorrowerRelativeOfDirectorAnswer == null || this.isCoBorrowerRelativeOfDirectorAnswer == undefined || this.isCoBorrowerRelativeOfDirectorAnswer == 'No')
        this.isCoBorrowerOptedYes = false;
    }
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[COBORROWER_RELATIVE_OF_SENIOR_OFFICER.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}
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
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[BORROWER_RELATIVE_OF_DIRECTOR.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}
handleRelationWithIndusIndOrOther(event)
{
    this.IsRelationshipWithIndusIndOrOtherBank = event.target.value;
    if(!this.isCoBorrowerExist)
    {
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
    }
    else
    {
        if(event.target.value == 'IndusInd Bank')
        {
            this.isCoBorrowerChosenIndusInd = true;
            this.isCoBorrowerChosenOtherBank = false;
        }
        else
        {
            this.isCoBorrowerChosenIndusInd = false;
            this.isCoBorrowerChosenOtherBank = true;
        }      
    }
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[RELATION_WITH_INDUSIND_OR_OTHER.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}
handleBorrowerIndusIndQ1(event)
{
    this.BorrowerRelationWithIndusIndQuestion1Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
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
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = event.target.value;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.BorrowerRelationWithIndusIndQuestion1Answer = null;
    this.BorrowerRelationWithIndusIndQuestion2Answer = null;
}
handleCoBorrowerIndusIndQ1(event)
{
    this.CoBorrowerRelationWithIndusIndQuestion1Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = event.target.value;
    applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
    applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.CoBorrowerRelationWithOtherBankQuestion1Answer = null;
    this.CoBorrowerRelationWithOtherBankQuestion2Answer = null;
}
handleCoBorrowerOtherQ1(event)
{
    this.CoBorrowerRelationWithOtherBankQuestion1Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = event.target.value;
    applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
    applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.CoBorrowerRelationWithIndusIndQuestion1Answer = null;
    this.CoBorrowerRelationWithIndusIndQuestion2Answer = null;
}
handleBorrowerIndusIndQ2(event)
{
    if(event.target.value != null)
        {
            const validateValue = (valueOfQ2) => {
                return String(valueOfQ2).toLowerCase().match(/^(?=.{3,26}$)((^[A-Za-z ]+$)\2?(?!\2))+$/);
            };
            if (validateValue(event.target.value) == null) {
                event.target.value = '';
                this.BorrowerRelationWithIndusIndQuestion2Answer = '';
                return;
            }
        }
    this.BorrowerRelationWithIndusIndQuestion2Answer = event.target.value;;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = event.target.value;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.BorrowerRelationWithOtherBankQuestion1Answer = null;
    this.BorrowerRelationWithOtherBankQuestion2Answer = null;
}
handleBorrowerOtherQ2(event)
{
    if(event.target.value != null)
        {
            const validateValue = (valueOfQ2) => {
                return String(valueOfQ2).toLowerCase().match(/^(?=.{3,26}$)((^[A-Za-z ]+$)\2?(?!\2))+$/);
            };
            if (validateValue(event.target.value) == null) {
                event.target.value = '';
                this.BorrowerRelationWithOtherBankQuestion2Answer = '';
                return;
            }
        }

    this.BorrowerRelationWithOtherBankQuestion2Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[BORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = event.target.value;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
    applicantsFields[BORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.BorrowerRelationWithIndusIndQuestion1Answer = null;
    this.BorrowerRelationWithIndusIndQuestion2Answer = null;
}
handleCoBorrowerIndusIndQ2(event)
{
    if(event.target.value != null)
        {
            const validateValue = (valueOfQ2) => {
                return String(valueOfQ2).toLowerCase().match(/^(?=.{3,26}$)((^[A-Za-z ]+$)\2?(?!\2))+$/);
            };
            if (validateValue(event.target.value) == null) {
                event.target.value = '';
                this.CoBorrowerRelationWithIndusIndQuestion2Answer = '';
                return;
            }
        }
    this.CoBorrowerRelationWithIndusIndQuestion2Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = event.target.value;
    applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q1.fieldApiName] = null;
    applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.CoBorrowerRelationWithOtherBankQuestion1Answer = null;
    this.CoBorrowerRelationWithOtherBankQuestion2Answer = null;
}
handleCoBorrowerOtherQ2(event)
{
    if(event.target.value != null)
    {
        const validateValue = (valueOfQ2) => {
            return String(valueOfQ2).toLowerCase().match(/^(?=.{3,26}$)((^[A-Za-z ]+$)\2?(?!\2))+$/);
        };
        if (validateValue(event.target.value) == null) {
            event.target.value = '';
            this.CoBorrowerRelationWithOtherBankQuestion2Answer = '';
            return;
        }
    }
    this.CoBorrowerRelationWithOtherBankQuestion2Answer = event.target.value;
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[COBORROWER_RELATION_WITH_OTHERBANK_Q2.fieldApiName] = event.target.value;
    applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q1.fieldApiName] = null;
    applicantsFields[COBORROWER_RELATION_WITH_INDUSIND_Q2.fieldApiName] = null;
    this.updateRecordDetails(applicantsFields);
    this.CoBorrowerRelationWithIndusIndQuestion1Answer = null;
    this.CoBorrowerRelationWithIndusIndQuestion2Answer = null;
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
    applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
    applicantsFields[BORROWER_RELATIVE_OF_SENIOR_OFFICER.fieldApiName] = event.target.value;
    this.updateRecordDetails(applicantsFields);
}
async doGetApplicantRelationshipWithBank(){
    await getApplicantRelationshipWithBank({applicantId : this.applicantId}).then(result =>{
        if(result)
        {
            if(result.Applicant_Type__c != 'Borrower')//SFTRAC-1791 Changed condindion from equals to co-borrower to not eqals to borrower so that it can be used for other applicant as well.
                this.coBorrowerRecordId = result.Id;
            this.isBorrowerRelativeOfDirectorAnswer = result.Is_Borrower_Relative_Of_Director__c;
            this.isBorrowerRelativeOfSeniorOfficerAnswer = result.Is_Borrower_Relative_Of_Senior_Officer__c;
            this.isCoBorrowerRelativeOfDirectorAnswer = result.Is_CoBorrower_Relative_Of_Director__c;
            this.isCoBorrowerRelativeOfSeniorOfficerAnswer = result.Is_CoBorrower_Relative_Of_Senior_Officer__c;
            this.IsRelationshipWithIndusIndOrOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c;
            this.BorrowerRelationWithIndusIndQuestion1Answer = result.Borrower_Relation_With_IndusInd_Q1__c;
            this.BorrowerRelationWithIndusIndQuestion2Answer = result.Borrower_Relation_With_IndusInd_Q2__c;
            this.BorrowerRelationWithOtherBankQuestion1Answer = result.Borrower_Relation_With_Other_Bank_Q1__c;
            this.BorrowerRelationWithOtherBankQuestion2Answer = result.Borrower_Relation_With_Other_Bank_Q2__c;
            this.CoBorrowerRelationWithIndusIndQuestion1Answer = result.CoBorrower_Relation_With_IndusInd_Q1__c;
            this.CoBorrowerRelationWithIndusIndQuestion2Answer = result.CoBorrower_Relation_With_IndusInd_Q2__c;
            this.CoBorrowerRelationWithOtherBankQuestion1Answer = result.CoBorrower_Relation_With_Other_Bank_Q1__c;
            this.CoBorrowerRelationWithOtherBankQuestion2Answer = result.CoBorrower_Relation_With_Other_Bank_Q2__c;

            this.isBorrowerOptedYes = (result.Is_Borrower_Relative_Of_Director__c == 'Yes' || result.Is_Borrower_Relative_Of_Senior_Officer__c == 'Yes') ? true : false;
            this.isCoBorrowerOptedYes = (result.Is_CoBorrower_Relative_Of_Director__c == 'Yes' || result.Is_CoBorrower_Relative_Of_Senior_Officer__c == 'Yes') ? true : false;
            this.isBorrowerChosenIndusInd = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'IndusInd Bank' ? true : false;
            this.isBorrowerChosenOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'Other Bank' ? true : false;
            this.isCoBorrowerChosenIndusInd = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'IndusInd Bank' ? true : false;
            this.isCoBorrowerChosenOtherBank = result.Relationship_With_IndusInd_Or_Other_Bank__c == 'Other Bank' ? true : false;

        }
    })
}//CISP-20554 - END
}