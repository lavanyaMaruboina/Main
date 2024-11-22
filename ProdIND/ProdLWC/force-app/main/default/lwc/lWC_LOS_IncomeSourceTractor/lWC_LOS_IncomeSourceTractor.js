import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardApplyCSS from '@salesforce/resourceUrl/loanApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createOtherDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createOtherDocument';
import checkDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkDocument';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import INCOME_DETAIL_OBJECT from '@salesforce/schema/Income_Details__c';
import INCOME_SOURCES from '@salesforce/schema/Income_Details__c.Income_Source_for_Tractor__c';
import fetchDocument from '@salesforce/apex/Ind_IncomeDetailsCtrl.fetchDocument';
import fillAllRequiredFields from '@salesforce/label/c.Please_fill_all_the_mandatory_fields';
import saveIncomeDetails from '@salesforce/apex/Ind_IncomeDetailsCtrl.saveIncomeDetails';
import ACCOUNT_FORMAT_ERROR from "@salesforce/label/c.AccountFormatError";

export default class LWC_LOS_IncomeSourceTractor extends LightningElement {
    @api checkleadaccess;//coming from tabloanApplication
    @api recordId
    @api isRevokedLoanApplication
    @api currentStage;
    @api currentStageName;
    @api isDeleteDisable;
    @api isDeleteButton;
    @api get checkValidate(){
        return this.checkFieldValidation(true);
    }
    @api applicantId;
    @api applicantType;
    @api currentOppRecordId;
    @api incomeDetail = {};
    @api isPan;
    @api isBank;
    @api isIblBank;
    @api isTwoWheeler;
    @api profileType;
    @api documentRecordId = null;
    @api contentDocumentId;
    @api leadNumber;
    @api emailId;
    @api firstName;

    @track assessmentYearsOptions = [];
    @track vehicledocs = true;
    @track isLoading = false;
    @track incomeSourceOptions;
    @track incomeSource = '';
    @track showITRSection = false;
    @track showFinancialsSection = false;
    @track showBankingSection = false;
    @track showModalForFileUpload = false;
    @track modalHeader = '';

    @track docType;
    @track showDocView = true;
    @track showPhotoCopy = false;
    @track showUpload = true;
    @track isVehicleDoc = false;
    @track isAllDocType = false;
    @track documentRecordId = '';
    @track vehiclerecordid = '';
    @track isCommunityUser = false;
    @track documetAlreadyPresent = false;

    @track uploadItrOrForm16 = false;
    @track uploadBankDetail = false;
    @track assessmentYear;
    @track itrLastYearDate ;
    @track incomeLastYear;
    @track doYouHaveAnotherITR = false;
    @track financialYear = '';
    @track totalIncome;
    @track totalExpense;
    @track PbtValue;
    @track PatValue;
    @track cashProfit;
    shareholderFunds;
    securedLoans;
    workingCapital;
    unsecuredLoans;
    currentLiabilities;
    sundryCreditors;
    currentAssets;
    sundryDebtors;
    fixedAssets;
    nonCurrentAssets;
    cashAndBankBalances;
    accountNumber;
    @track bankBranch;
    @track accountOpeningDate;
    @track bank;
    @track incomeSourceId = null;
    @track disableAllFields = false;
    @track isSubmit = false;
    @track incomeSourceRequired = false;
    @track bankId;
    @track UploadButtonLabel;
    @track last3MonthsLabels = {};
    @track last3MonthsValues = {};
    @track uploadBankStatement = false;
    @track iconButtonCaptureImage = false;
    @track taxReturnFiled; //SFTRAC-241
    @track saralDate;//SFTRAC-241
    get taxReturnFiledOptions() { //SFTRAC-241
        return [
            {label : 'Yes', value: 'Y'},
            {label : 'No', value: 'N'}
               ];
    }

    @track label = {fillAllRequiredFields};

    @wire(getObjectInfo, { objectApiName: INCOME_DETAIL_OBJECT })
    incomeDetailMetaData;

    @wire(getPicklistValues, {recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId', fieldApiName: INCOME_SOURCES })
    incomeSources({data,error}){
        if (data) {
            this.isLoading = true;
            let incomesource = [];
            incomesource = data.values.filter(object => {
                if(this.applicantType != 'Borrower' && object.value != 'Financials') {
                    return object;
                } else if(this.applicantType == 'Borrower'){
                    return object;
                }
            });
            this.incomeSourceOptions = incomesource;
            this.isLoading = false;
        }
        else if(error){
            this.isLoading = false;
            console.log('Error :'+error);
        }
    }

    get maxDate() {
        const currentDate = new Date().toISOString().split('T')[0];
        return currentDate;
    }

    checkFieldValidation(checkSubmitValidation){
        console.log('checkFieldValidation');
        let lightningInputValidity = this.validityCheck('lightning-input');
        let lightningComboboxValidity = this.validityCheck('lightning-combobox');
        if (!lightningInputValidity || !lightningComboboxValidity) {
            this.showToast(this.label.fillAllRequiredFields, '', 'warning');
            return false;
        }else if(checkSubmitValidation && !this.isSubmit){
            this.showToast('', 'Submit Income Source first', 'warning');
            return false;       
        } else if(checkSubmitValidation) {
            return true;
        } else{
            return true;
        }
    }
    

    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    async connectedCallback() {        
        this.isLoading = true;
        loadStyle(this, LightningCardApplyCSS);

        console.log('connectedCallback12::');

        const month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"];

        let currentDate = new Date();
        let tempMonthLabel = this.last3MonthsLabels;
        currentDate = new Date(currentDate.setMonth(currentDate.getMonth() - 1));
        tempMonthLabel.lastMonthDay1 =  month[currentDate.getMonth()]+' 1st';
        tempMonthLabel.lastMonthDay10 = month[currentDate.getMonth()]+' 10th';
        tempMonthLabel.lastMonthDay20 = month[currentDate.getMonth()]+' 20th';
        currentDate = new Date(currentDate.setMonth(currentDate.getMonth() - 1));
        tempMonthLabel.last2ndMonthDay1 = month[currentDate.getMonth()]+' 1st';
        tempMonthLabel.last2ndMonthDay10 = month[currentDate.getMonth()]+' 10th';
        tempMonthLabel.last2ndMonthDay20 = month[currentDate.getMonth()]+' 20th';
        currentDate = new Date(currentDate.setMonth(currentDate.getMonth() - 1));
        tempMonthLabel.last3rdMonthDay1 = month[currentDate.getMonth()]+' 1st';
        tempMonthLabel.last3rdMonthDay10 = month[currentDate.getMonth()]+' 10th';
        tempMonthLabel.last3rdMonthDay20 = month[currentDate.getMonth()]+' 20th';
        this.last3MonthsLabels = tempMonthLabel;

        
         
       /* await fetchDocument({ docType: 'Bank Statement', applicantId: this.applicantId })
        .then(response => {
            if (response != null) {
                console.log('this.documentRecordId:::'+response);
                this.documentRecordId = response;
                this.documetAlreadyPresent = true;
                this.isLoading = false;
            }else {
                this.documetAlreadyPresent = false;
                this.isLoading = false;
            }
        }).catch(error => {
            this.isLoading = false;
            return false;
        });
        */
        if(this.applicantType == 'Borrower'){
            this.incomeSourceRequired = true;
        }

        console.log('incomeDetail::'+JSON.stringify(this.incomeDetail));
        this.incomeSource = this.incomeDetail.Income_Source_for_Tractor__c;

        //SFTRAC-241
        this.saralDate = this.incomeDetail.Saral_date__c;
        this.taxReturnFiled = this.incomeDetail.Tax_Return_Filed__c;
        

        if(this.incomeDetail.Income_Source_for_Tractor__c == 'ITR') {
            this.setAssessmentYearOptions();
            this.showITRSection = true;
            this.displayUploadButton = true;
            this.UploadButtonLabel = 'Upload Bank Statements';
            this.assessmentYear = this.incomeDetail.Assessment_Year__c;
            this.itrLastYearDate = this.incomeDetail.ITR_Last_Year_Date__c;
            this.incomeLastYear = this.incomeDetail.Income_Last_Year__c;
            this.doYouHaveAnotherITR = this.incomeDetail.Do_you_have_another_ITR__c;
            this.isSubmit = true;
            this.disableAllFields = true;
        }
        else if(this.incomeDetail.Income_Source_for_Tractor__c == 'Financials') {
            this.setAssessmentYearOptions();
            this.showFinancialsSection = true;
            this.displayUploadButton = true;
            this.UploadButtonLabel = 'Upload Financial Statements';
            this.financialYear = this.incomeDetail.Financial_Year__c;
            this.totalIncome = this.incomeDetail.Total_Income__c;
            this.totalExpense = this.incomeDetail.Total_Expense__c;
            this.PbtValue = this.incomeDetail.PBT__c;
            this.PatValue = this.incomeDetail.PAT__c;
            this.cashProfit = this.incomeDetail.Cash_Profit__c;
            this.shareholderFunds = this.incomeDetail.Shareholder_funds__c;
            this.securedLoans = this.incomeDetail.Secured_Loans__c;
            this.workingCapital = this.incomeDetail.Working_Capital__c;
            this.unsecuredLoans = this.incomeDetail.Unsecured_Loans__c;
            this.currentLiabilities = this.incomeDetail.Current_Liabilities__c;
            this.sundryCreditors = this.incomeDetail.Sundry_Creditors__c;
            this.currentAssets = this.incomeDetail.Current_Assets__c;
            this.sundryDebtors = this.incomeDetail.Sundry_Debtors__c;
            this.fixedAssets = this.incomeDetail.Fixed_Assets__c;
            this.nonCurrentAssets = this.incomeDetail.Non_Current_Assets__c;
            this.cashAndBankBalances = this.incomeDetail.Cash_and_Bank_Balances__c;            
            this.isSubmit = true;
            this.disableAllFields = true;    
        }
        else if(this.incomeDetail.Income_Source_for_Tractor__c == 'Banking') {
            this.showBankingSection = true;
            this.displayUploadButton = true;
            this.UploadButtonLabel = 'Upload Bank Statements';
            this.iconButtonCaptureImage = true;
            this.bankId = this.incomeDetail.Income_Detail_Bank_Master__c;
            this.bank = this.incomeDetail.Income_Detail_Bank_Master__r.Name;
            this.bankBranch = this.incomeDetail.Bank_Branch__c;
            this.accountNumber = this.incomeDetail.Account_Number__c;
            this.accountOpeningDate = this.incomeDetail.Account_Opening_Date__c;
            this.last3MonthsValues.lastMonthDay1 =  this.incomeDetail.Last_Month_Day_1__c
            this.last3MonthsValues.lastMonthDay10 =  this.incomeDetail.Last_Month_Day_10__c
            this.last3MonthsValues.lastMonthDay20 =  this.incomeDetail.Last_Month_Day_20__c
            this.last3MonthsValues.last2ndMonthDay1 =  this.incomeDetail.Last_2nd_Month_Day_1__c
            this.last3MonthsValues.last2ndMonthDay10 =  this.incomeDetail.Last_2nd_Month_Day_10__c
            this.last3MonthsValues.last2ndMonthDay20 =  this.incomeDetail.Last_2nd_Month_Day_20__c
            this.last3MonthsValues.last3rdMonthDay1 = this.incomeDetail.Last_3rd_Month_Day_1__c
            this.last3MonthsValues.last3rdMonthDay10 =  this.incomeDetail.Last_3rd_Month_Day_10__c
            this.last3MonthsValues.last3rdMonthDay20 =  this.incomeDetail.Last_3rd_Month_Day_20__c


            this.isSubmit = true;
            this.disableAllFields = true;    
        }
        
    }

    validityCheck(query) {
        return [...this.template.querySelectorAll(query)]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }

    saveIncomeSource() {
        const incomeSourceArray = [];
        const incomeSourceDetailsFields = {};

        incomeSourceDetailsFields['incomeSource'] = this.incomeSource;
        incomeSourceDetailsFields['Id'] = this.incomeSourceId;

        if(this.incomeSource == 'ITR'){

            incomeSourceDetailsFields['assessmentYear'] = this.assessmentYear;
            incomeSourceDetailsFields['iTRLastYearDate'] = this.itrLastYearDate;
            incomeSourceDetailsFields['incomeLastYear'] = this.incomeLastYear;
            incomeSourceDetailsFields['doYouHaveAnotherITR'] = this.doYouHaveAnotherITR;
            incomeSourceDetailsFields['saralDate'] = this.saralDate;//SFTRAC-241
            incomeSourceDetailsFields['taxReturnsFiled'] = this.taxReturnFiled;//SFTRAC-241
            incomeSourceArray.push(incomeSourceDetailsFields);
            return incomeSourceArray;
        }
        else if(this.incomeSource == 'Financials'){
            incomeSourceDetailsFields['financialYear'] = this.financialYear;
            incomeSourceDetailsFields['totalIncome'] = this.totalIncome;
            incomeSourceDetailsFields['totalExpense'] = this.totalExpense;
            incomeSourceDetailsFields['pBT'] = this.PbtValue;
            incomeSourceDetailsFields['pAT'] = this.PatValue;
            incomeSourceDetailsFields['cashProfit'] = this.cashProfit;
            incomeSourceDetailsFields['shareholderFunds'] = this.shareholderFunds;
            incomeSourceDetailsFields['securedLoans'] = this.securedLoans;
            incomeSourceDetailsFields['workingCapital'] = this.workingCapital;
            incomeSourceDetailsFields['unsecuredLoans'] = this.unsecuredLoans;
            incomeSourceDetailsFields['currentLiabilities'] = this.currentLiabilities;
            incomeSourceDetailsFields['sundryCreditors'] = this.sundryCreditors;
            incomeSourceDetailsFields['currentAssets'] = this.currentAssets;
            incomeSourceDetailsFields['sundryDebtors'] = this.sundryDebtors;
            incomeSourceDetailsFields['fixedAssets'] = this.fixedAssets;
            incomeSourceDetailsFields['nonCurrentAssets'] = this.nonCurrentAssets;
            incomeSourceDetailsFields['cashAndBankBalances'] = this.cashAndBankBalances;
            incomeSourceArray.push(incomeSourceDetailsFields);
            return incomeSourceArray;
        }
        else if(this.incomeSource == 'Banking'){
            incomeSourceDetailsFields['bankName'] = this.bankId;
            incomeSourceDetailsFields['bankBranch'] = this.bankBranch;
            incomeSourceDetailsFields['accountNumber'] = this.accountNumber;
            incomeSourceDetailsFields['accountOpetingDate'] = this.accountOpeningDate;
            incomeSourceDetailsFields['lastMonthDay1'] = this.last3MonthsValues.lastMonthDay1;
            incomeSourceDetailsFields['lastMonthDay10'] =this.last3MonthsValues.lastMonthDay10;
            incomeSourceDetailsFields['lastMonthDay20'] =this.last3MonthsValues.lastMonthDay20;
            incomeSourceDetailsFields['last2ndMonthDay1'] = this.last3MonthsValues.last2ndMonthDay1;
            incomeSourceDetailsFields['last2ndMonthDay10'] = this.last3MonthsValues.last2ndMonthDay10;
            incomeSourceDetailsFields['last2ndMonthDay20'] = this.last3MonthsValues.last2ndMonthDay20;
            incomeSourceDetailsFields['last3rdMonthDay1'] = this.last3MonthsValues.last3rdMonthDay1;
            incomeSourceDetailsFields['last3rdMonthDay10'] = this.last3MonthsValues.last3rdMonthDay10;
            incomeSourceDetailsFields['last3rdMonthDay20'] = this.last3MonthsValues.last3rdMonthDay20;
            incomeSourceArray.push(incomeSourceDetailsFields);
            console.log('incomeSourceDetailsFields '+JSON.stringify(incomeSourceDetailsFields));
            return incomeSourceArray;
        }
        
    }

    async handleSubmit() {
        console.log('test');
        this.isLoading = true;
        let valid = await this.checkFieldValidation(false);
        if(this.incomeSource == 'Banking' && !this.uploadBankStatement) {
            this.showToast('', 'Upload Bank Statement first', 'warning');
            valid = false;      
        }
        console.log('valid:::'+valid);
        if(valid) {
            await this.saveIncomeDetails();
        } else{
            this.isLoading = false;
        }
    }

    deleteIncomeSource() {
        const screenEvent = new CustomEvent("deleteincome", { detail: this.incomeDetail.key });this.dispatchEvent(screenEvent);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title: title,message: message,variant: variant,});
        this.dispatchEvent(evt);
    }

    setAssessmentYearOptions(){
        let assessmentYearsOptions = [];

        const date = new Date();
        let year = date.getFullYear();
        for(let i = 15; i > 0 ; i--) {
            assessmentYearsOptions.push({"label": 'AY'+year, "value": 'AY'+year});
            year --;
        }

        this.assessmentYearsOptions = assessmentYearsOptions;
        console.log('assessmentYearsOptions::'+JSON.stringify(assessmentYearsOptions));
    }

    handleInputChange(event){
        if(event.target.name == 'incomeSource') {
            this.incomeSource = event.target.value;
            console.log('event123:::'+this.incomeSource);

            if(this.incomeSource == 'ITR') {
                this.setAssessmentYearOptions();
                this.UploadButtonLabel = 'Upload ITR or Form 16';
                this.docType = 'ITR-Forms';
                this.showITRSection = true;
                this.showBankingSection = false;
                this.showFinancialsSection = false;
                this.displayUploadButton = true;

            }
            else if(this.incomeSource == 'Financials') {
                this.setAssessmentYearOptions();
                this.UploadButtonLabel = 'Upload Financial Statements';
                this.docType = 'Financial Statement';
                this.showITRSection = false;
                this.showBankingSection = false;
                this.showFinancialsSection = true;
                this.displayUploadButton = true;
            }
            else if(this.incomeSource == 'Banking') {
                this.UploadButtonLabel = 'Upload Bank Statements';
                this.docType = 'Customer Bank Statement';
                this.showITRSection = false;
                this.showBankingSection = true;
                this.showFinancialsSection = false;
                this.displayUploadButton = true;

            }
            
        }
        else if(event.target.name == 'assessmentYear'){
            this.assessmentYear = event.detail.value;
            console.log('assessmentYear '+this.assessmentYear);
        }
        else if(event.target.name == 'itrLastYearDate'){
            let inputField = this.template.querySelector('[data-name="itrLastYearDate"]');
            const selectedDate = event.detail.value;
            const currentDate = new Date().toISOString().split('T')[0];

            if (selectedDate > currentDate) {
                inputField.setCustomValidity("Date cannot be a future date.");
            } else {
                this.itrLastYearDate = selectedDate;
                inputField.setCustomValidity("");
            }
            inputField.reportValidity();

        }
        else if(event.target.name == 'incomeLastYear'){
            this.incomeLastYear = event.target.value;
            console.log('incomeLastYear '+this.incomeLastYear);

        }
        else if(event.target.name == 'doYouHaveAnotherITR'){
            this.doYouHaveAnotherITR = event.target.checked;
            console.log('doYouHaveAnotherITR '+this.doYouHaveAnotherITR);

        }
        else if(event.target.name == 'saralDate'){//SFTRAC-241
            this.saralDate = event.target.value;
        }
        else if(event.target.name == 'taxReturnFiled'){//SFTRAC-241
            this.taxReturnFiled = event.target.value;
        }
        else if(event.target.name == 'financialYear'){
            this.financialYear = event.target.value;
            console.log('financialYear '+this.financialYear);

        }
        else if(event.target.name == 'totalIncome'){
            this.totalIncome = event.target.value;
            console.log('totalIncome '+this.totalIncome);

        }
        else if(event.target.name == 'totalExpense'){
            this.totalExpense = event.target.value;
            console.log('totalExpense '+this.totalExpense);

        }
        else if(event.target.name == 'PbtValue'){
            this.PbtValue = event.target.value;
            console.log('PbtValue '+this.PbtValue);

        }
        else if(event.target.name == 'PatValue'){
            this.PatValue = event.target.value;
            console.log('PatValue '+this.PatValue);

        }
        else if(event.target.name == 'cashProfit'){
            this.cashProfit = event.target.value;
            console.log('cashProfit '+this.cashProfit);

        }
        else if(event.target.name == 'shareholderFunds'){
            this.shareholderFunds = event.target.value;
            console.log('shareholderFunds '+this.shareholderFunds);
        }
        else if(event.target.name == 'securedLoans'){
            this.securedLoans = event.target.value;
            console.log('securedLoans '+this.securedLoans);
        }
        else if(event.target.name == 'workingCapital'){
            this.workingCapital = event.target.value;
            console.log('workingCapital '+this.workingCapital);
        }
        else if(event.target.name == 'unsecuredLoans'){
            this.unsecuredLoans = event.target.value;
            console.log('unsecuredLoans '+this.unsecuredLoans);
        } 
        else if(event.target.name == 'currentLiabilities'){
            this.currentLiabilities = event.target.value;
            console.log('currentLiabilities '+this.currentLiabilities);
        }
        else if(event.target.name == 'sundryCreditors'){
            this.sundryCreditors = event.target.value;
            console.log('sundryCreditors '+this.sundryCreditors);
        }
        else if(event.target.name == 'currentAssets'){
            this.currentAssets = event.target.value;
            console.log('currentAssets '+this.currentAssets);
        }
        else if(event.target.name == 'sundryDebtors'){
            this.sundryDebtors = event.target.value;
            console.log('sundryDebtors '+this.sundryDebtors);
        }
        else if(event.target.name == 'fixedAssets'){
            this.fixedAssets = event.target.value;
            console.log('fixedAssets '+this.fixedAssets);
        }
        else if(event.target.name == 'nonCurrentAssets'){
            this.nonCurrentAssets = event.target.value;
            console.log('nonCurrentAssets '+this.nonCurrentAssets);
        }
        else if(event.target.name == 'cashAndBankBalances'){
            this.cashAndBankBalances = event.target.value;
            console.log('cashAndBankBalances '+this.cashAndBankBalances);
        }
        else if(event.target.name == 'bankBranch'){
            this.bankBranch = event.target.value;
            console.log('bankBranch '+this.bankBranch);

        }
        else if(event.target.name == 'accountNumber'){
            let inputField = this.template.querySelector('[data-name="accountNumber"]');
            let accountNumber = event.target.value;
            inputField?.setCustomValidity('');
            var regularExpression = new RegExp('^[0-9]*$');
            if (!regularExpression.test(accountNumber) && accountNumber != '') {
                inputField?.setCustomValidity("Enter valid account number");
                inputField?.reportValidity();
                this.showToast('',ACCOUNT_FORMAT_ERROR, 'Warning');
                return;
                

            }
            inputField?.reportValidity();
            this.accountNumber = accountNumber;
        }
        else if(event.target.name == 'accountOpeningDate'){

            let inputField = this.template.querySelector('[data-name="accountOpeningDate"]');
            const selectedDate = event.detail.value;
            const currentDate = new Date().toISOString().split('T')[0];

            if (selectedDate > currentDate) {
                inputField.setCustomValidity("Date cannot be a future date.");
            } else {
                this.accountOpeningDate = selectedDate;
                inputField.setCustomValidity("");
            }
            inputField.reportValidity();

        }
        else if(event.target.dataset.key == 'lastMonthDay1'){
            this.last3MonthsValues.lastMonthDay1 =  event.target.value;
            console.log('accountOpeningDate '+JSON.stringify(this.last3MonthsValues));


        }
        else if(event.target.dataset.key == 'lastMonthDay10'){
            this.last3MonthsValues.lastMonthDay10 =  event.target.value;
            console.log('accountOpeningDate '+this.last3MonthsValues);

        }
        else if(event.target.dataset.key == 'lastMonthDay20'){
            this.last3MonthsValues.lastMonthDay20 =  event.target.value;

        }
        else if(event.target.dataset.key == 'last2ndMonthDay1'){
            this.last3MonthsValues.last2ndMonthDay1 = event.target.value;

        }
        else if(event.target.dataset.key == 'last2ndMonthDay10'){
            this.last3MonthsValues.last2ndMonthDay10 =  event.target.value;

        }
        else if(event.target.dataset.key == 'last2ndMonthDay20'){
            this.last3MonthsValues.last2ndMonthDay20 =  event.target.value;

        }
        else if(event.target.dataset.key == 'last3rdMonthDay1'){
            this.last3MonthsValues.last3rdMonthDay1 = event.target.value;

        }
        else if(event.target.dataset.key == 'last3rdMonthDay10'){
            this.last3MonthsValues.last3rdMonthDay10 =  event.target.value;

        }
        else if(event.target.dataset.key == 'last3rdMonthDay20'){
            this.last3MonthsValues.last3rdMonthDay20 =  event.target.value;
        }
    }
   
    @api async isfieldsCompleted(doctype, from){
        console.log('isfieldsCompleted');
        this.isLoading = true;
        let lightningInputValidity = this.validityCheck('lightning-input');
        let lightningComboboxValidity = this.validityCheck('lightning-combobox');
        if (!lightningInputValidity || !lightningComboboxValidity) {
            this.showToast(this.label.fillAllRequiredFields,'', 'warning');
            this.isLoading = false;
            return true;
        } else if(!this.isSubmit){
            this.isLoading = false;
            this.showToast('', 'Submit Income Source first', 'warning');
            return true;       
        } else{
            this.isLoading = false;
            return false;
        }
    }

    saveIncomeDetails(){
        saveIncomeDetails({ incomeDetails: JSON.stringify(this.saveIncomeSource()), applicantId: this.applicantId, isTractor: 'true' }).then(response => {
            if(response?.status === 'success'){
                this.incomeSourceId = response?.recordId;
                this.isDeleteDisable = true;
                this.disableAllFields = true;
                this.isLoading = false;
                this.isSubmit = true;
                const evt = new ShowToastEvent({title: "success", message: 'Income Source Details Saved', variant: 'success'}); 
                this.dispatchEvent(evt);
            } else {
                this.isLoading = false;
                const evt = new ShowToastEvent({ title: "error", message: response?.message, variant: 'error'});
                this.dispatchEvent(evt);
            }
        }).catch(error => {
            this.isLoading = false;
            const evt = new ShowToastEvent({ title: 'Error in Saving Income Source Details', message: error, variant: 'error'});
            this.dispatchEvent(evt);
        });
    }

    async handleUpload(event) {
        this.isLoading = true;
        console.log('showModalForFileUpload'+this.showModalForFileUpload);
        if (!this.documetAlreadyPresent) {
            await createOtherDocument({ docType: this.docType, applicantId: this.applicantId, loanApplicationId: this.currentOppRecordId })
            .then(result => {
                this.documentRecordId = result;
                console.log('result:::'+result);
                this.showModalForFileUpload = true;
                this.isLoading = false;
            }).catch(error => {
                this.error = error;
                this.isLoading = false;
            });
        } else{
            this.showModalForFileUpload = true;
            this.isLoading = false;
        }
        // this.modalheader = 'ITR OR FORM 16'
    }

    async changeflagvalue(event) {
        console.log('event.detail:::'+JSON.stringify(event.detail));
        let result = await checkDocument({'documentRecordId' : this.documentRecordId});
        if(result == true){
            this.uploadBankStatement = true;
            this.iconButtonCaptureImage = true;
        }
        this.showModalForFileUpload = false;
    }

    fileUploadStatus(event) {
        console.log('event.detail:::'+JSON.stringify(event.detail));
        if(event.detail){
            this.uploadBankStatement = true;
            this.iconButtonCaptureImage = true;
        }
    }

    handleUploadFinished(event) {
        console.log('event.detail.files[0].documentId:::'+event.detail.files[0].documentId);
        console.log("applicantId::"+this.applicantId);
        this.successToast('','File Uploaded','success');
    }

    successToast(toastTitle, message, variant) {
        if(message == null) {
             message = ''; 
        }
        const evt = new ShowToastEvent({title: toastTitle, message: message, variant: variant});
        this.dispatchEvent(evt);
    }

    selectedStateHandler(event) {
        this.bankId = event.detail.selectedValueId;
        this.bank = event.detail.selectedValueName;
      }

}