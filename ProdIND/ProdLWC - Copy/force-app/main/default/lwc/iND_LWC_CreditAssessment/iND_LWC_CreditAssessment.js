import { LightningElement, track, wire, api } from 'lwc';
// import uId from '@salesforce/user/Id';
import { updateRecord } from 'lightning/uiRecordApi';
import getUserRemarks from '@salesforce/apex/IND_LWC_CreditAssessmentCntrl.getUserRemarks';
import saveUserRemarks from '@salesforce/apex/IND_LWC_CreditAssessmentCntrl.saveUserRemarks';
import createRealatedRecords from '@salesforce/apex/IND_TeleverificationDetails.createRealatedRecords';
import checkCurrentSubStage from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkCurrentSubStage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import LoanCategory from '@salesforce/schema/Opportunity.Loan_Categorization__c';
import AcreCategory from '@salesforce/schema/Opportunity.Acre_Category__c';
import PSLSubCategory from '@salesforce/schema/Opportunity.PSL_Sub_Type__c';
import NonPSLSubCategory from '@salesforce/schema/Opportunity.Non_PSL_Categorization__c';
import BorrowerCategory from '@salesforce/schema/Opportunity.Borrower_Category__c';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import Loan_Recommendation from '@salesforce/schema/Opportunity.Recommendation_for_the_Loan__c';
import Opportunity_OBJECT from '@salesforce/schema/Opportunity';
export default class IND_LWC_CreditAssessment extends LightningElement {
    @track remarksTextValue;
    @track isReadonlyMode;
    @track relatedRecordsCreated = false;
    //CISP-2663
    @track isSubmitClicked = true;
    @api applicantId;
    @api recordId;
    @api applicantType; 
    @api checkleadaccess;//coming from tabloanApplication
    @api isRevokedLoanApplication;//CISP-2735
    @track acreCategoryData=[];
    @track acreCategoryDataObj;
    @track loanCategorizationData;
    @track nonPSLCategorizationData;
    @track PSLSubTypeData;
    @track isLoanCategorizationDisable;
    @track LoanCategoryField = LoanCategory;
    @track shownonPSLCategory = false;
    @track showPSLCategory = false;
    @track acreCategoryValue;
    @track isAcreCategoryDisable = false;
    @track borrowerCategoryValue;
    @track isTractorProduct = false;    
    @track isnonPSLCategorizationDisable = false;
    @track isPSLSubTypeDisable = false;
    @track isNonIndividual = false;
    @track loanRecRemarks;
    @track disableLoanRemarks = false;
    @track ispopulated = false;
    @wire( getObjectInfo, { objectApiName: Opportunity_OBJECT } )
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LoanCategory}) loanCategorizationPicklistData({ error, data }) {
        if (data) {
            this.loanCategorizationData = JSON.parse(JSON.stringify(data.values));
        } else if (error) {
            console.log('error---',error);
         }
    };
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: NonPSLSubCategory}) nonPSLSubCategoryPicklistData({ error, data }) {
        if (data) {
            this.nonPSLCategorizationData = JSON.parse(JSON.stringify(data.values));
        } else if (error) {
            console.log('error---',error);
         }
    };
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PSLSubCategory}) pSLSubTypeCategoryPicklistData({ error, data }) {
        if (data) {
            this.PSLSubTypeData = JSON.parse(JSON.stringify(data.values));
        } else if (error) {
            console.log('error---',error);
         }
    };
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: AcreCategory}) acreCategoryPicklistData({ error, data }) {
        if (data) {
            console.log('getPicklistValues==> acreCategoryPicklistData');
            this.acreCategoryDataObj = JSON.parse(JSON.stringify(data.values));
        } else if (error) {
            console.log('error---',error);
         }
    };
    get getAcreCategoryPicklist(){
        return this.acreCategoryValue;
    }
    async connectedCallback() {
        try {
            this.isLoanCategorizationDisable = false;
            console.log('record id & applicant type => ', this.recordId , "   ",  this.applicantType);
            const userRemarksObj = await getUserRemarks({ applicantId: this.applicantId, loanApplicationId : this.recordId });
            if (userRemarksObj) {
                this.remarksTextValue = userRemarksObj.Remarks__c;
                if(userRemarksObj.Opportunity__r.Product_Type__c == 'Tractor' && this.applicantType=='Borrower'){
                    this.isTractorProduct = true;
                    this.loanCategorizationValue = userRemarksObj.Opportunity__r?.Loan_Categorization__c;
                    this.nonPSLCategorizationValue = userRemarksObj.Opportunity__r?.Non_PSL_Categorization__c;
                    this.isNonIndividual = userRemarksObj.Opportunity__r?.Customer_Type__c === 'Non-Individual';
                    this.loanRecRemarks = userRemarksObj.Opportunity__r?.Recommendation_for_the_Loan__c;                    
                    if(this.nonPSLCategorizationValue){
                        this.shownonPSLCategory = true;
                    }
                    this.pSLSubTypeValue = userRemarksObj.Opportunity__r?.PSL_Sub_Type__c;
                    if(this.pSLSubTypeValue){
                        this.showPSLCategory = true;
                        let eventObj = { 
                                            detail: {
                                                            value: this.pSLSubTypeValue
                                                            }
                                                    }
                                        
                        console.log('eventObj',this.eventObj);
                        await this.PSLSubTypeHandler(eventObj);
                    }
                    this.acreCategoryValue = userRemarksObj.Opportunity__r?.Acre_Category__c;
                    this.borrowerCategoryValue = userRemarksObj.Opportunity__r?.Borrower_Category__c;
                    if(this.loanCategorizationValue == 'Non-PSL'){
                        this.shownonPSLCategory = true;
                        this.showPSLCategory = false;
                        this.isloanCategorizationDisable = true;
                        this.isnonPSLCategorizationDisable = true;
                    }else if(this.loanCategorizationValue == 'PSL'){
                        this.shownonPSLCategory = false;
                        this.showPSLCategory = true;
                        this.isloanCategorizationDisable = true;
                        this.isAcreCategoryDisable = true;
                        this.isPSLSubTypeDisable = true;
                    }else{
                        this.shownonPSLCategory = false;
                        this.showPSLCategory = false;
                    }
                    
                }
                if(this.remarksTextValue){
                    this.template.querySelector('.text').value = this.remarksTextValue;
                }
            }

            checkCurrentSubStage({'loanApplicationId': this.recordId, 'screenName' : 'Credit Assessment'}).then(result=>{
                if(result){
                    this.isSubmitClicked = true;
                }else{
                    this.isSubmitClicked = false;
                }
            }).catch(error=>{
                const evt = new ShowToastEvent({
                    title: 'Something went wrong, Please contact your administrator.',
                    variant: '',
                    mode: 'dismissible'
                });
                this.dispatchEvent(evt);
            });
            
        } catch (e) {
            console.error(e);
        }
        this.checkIfIsReadOnlyMode();
        if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
            const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
            this.disableEverything(); 
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
            if(this.isNonIndividual && this.loanRecRemarks && !this.ispopulated){
                this.template.querySelector('.loanText').value = this.loanRecRemarks;
                this.ispopulated = true;
            }
    }

    get getAcreCategoryData(){
        return this.acreCategoryData;
    }

    checkIfIsReadOnlyMode() {
        if (this.remarksTextValue && this.remarksTextValue.length > 0) {
            this.isReadonlyMode = true;
        } else {
            this.isReadonlyMode = false;
        }
        if(this.loanRecRemarks && this.loanRecRemarks.length > 0){
            this.disableLoanRemarks = true;
        } else {
            this.disableLoanRemarks = false;
        }
    }

    async handleClick(event) {
        
        //CISP-2663
        this.isSubmitClicked = true;
        let remarksText = this.template.querySelector('.text').value;
        let loanRemarksText = this.isNonIndividual ? this.template.querySelector('.loanText').value : '';
        if(this.isTractorProduct){
            let valid = this.validateFields("lightning-combobox");
            if(!valid){
                const evt = new ShowToastEvent({
                    title: 'Please fill all mandatory fields!',
                    variant: 'warning',
                    mode: ''
                });
                this.dispatchEvent(evt);
                this.isSubmitClicked = false; 
                return; 
            }
        }
        // TODO: Save only if remarks are not empty
        try {

            if(!this.relatedRecordsCreated)
            {
                await createRealatedRecords({ //CISP-2987                  
                    strOppId: this.recordId,
                    tvrType:'Pre-TVR'
                })
                .then(result => {     
                      //CISP-2663
                      this.isSubmitClicked = true;                   
                    console.log('successAAAA');  
                    this.relatedRecordsCreated = true;      
                })
                .catch(error => {  
                     // CISP-2663  
                     this.isSubmitClicked = false;                   
                    console.log('error ',error); 
                })
            }          

            //CISP-2987
            if(!this.relatedRecordsCreated){
                const evt = new ShowToastEvent({
                    title: 'Something went wrong, Please contact your administrator.',
                    variant: '',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                return;
            }       
            //CISP-2987
            await saveUserRemarks({ applicantId: this.applicantId, loanApplicationId : this.recordId, remarks: remarksText });
            this.remarksTextValue = remarksText;
            if(this.isTractorProduct){
                const updatePSLData = {};
                updatePSLData[OPP_ID_FIELD.fieldApiName] = this.recordId;
                updatePSLData[BorrowerCategory.fieldApiName] = this.borrowerCategoryValue;
                updatePSLData[NonPSLSubCategory.fieldApiName] = this.nonPSLCategorizationValue;
                updatePSLData[PSLSubCategory.fieldApiName] = this.pSLSubTypeValue;   
                updatePSLData[AcreCategory.fieldApiName] = this.acreCategoryValue;
                updatePSLData[LoanCategory.fieldApiName] = this.loanCategorizationValue;
                if(this.isNonIndividual){
                    this.loanRecRemarks = loanRemarksText;
                    updatePSLData[Loan_Recommendation.fieldApiName] = loanRemarksText;
                }
                console.log('updatePSLData--------',updatePSLData);       
                this.updateRecordDetails(updatePSLData); 
                this.disableEverything();
            }    
            console.log('Inside handle click');
            const selectedEvent = new CustomEvent('creditassessmentevent', { detail: 'Credit Assessment' });
            this.dispatchEvent(selectedEvent);

        } catch (e) {
            console.error(e);
        }
        this.checkIfIsReadOnlyMode();
    }
    loanCategorizationHandler(event){
        console.log('inside loanCategorizationHandler--->'+event.detail.value);
        if(event.detail.value == 'PSL'){
            this.shownonPSLCategory = false;
            this.showPSLCategory = true;
            this.nonPSLCategorizationValue = '';
        }else{
            this.shownonPSLCategory = true;
            this.showPSLCategory = false;
        }
        this.loanCategorizationValue = event.detail.value;
    }
    nonPSLCategorizationHandler(event){
        console.log('inside nonPSLCategorizationHandler');
        this.nonPSLCategorizationValue = event.detail.value;
        this.pSLSubTypeValue='';
    }
    PSLSubTypeHandler(event){
        console.log('inside PSLSubTypeHandler--->');
        this.pSLSubTypeValue = event.detail.value;
        let acreOption = [];
        if(this.pSLSubTypeValue == 'Agri - Individual'){
            if (this.acreCategoryDataObj) {
                this.acreCategoryDataObj.forEach(item => {
                    if(item.value != 'Other borrowers engaged in agriculture and allied activities'){
                    acreOption.push({
                                     label: item.label,
                                     value: item.value
                                    });
                    }
                });
            } 
            this.acreCategoryData = acreOption;
            this.isAcreCategoryDisable = false;
            this.borrowerCategoryValue = null;
        }else{
            if (this.acreCategoryDataObj) {
                this.acreCategoryDataObj.forEach(item => {
                    if(item.value == 'Other borrowers engaged in agriculture and allied activities'){
                    acreOption.push({
                                        label: item.label,
                                        value: item.value
                                    });
                    }
                });
            }
            this.acreCategoryData = acreOption;
            this.acreCategoryValue = 'Other borrowers engaged in agriculture and allied activities';
            this.borrowerCategoryValue = 49;
        }
    }
    acreCategoryHandler(event){
        console.log('inside acreCategoryHandler');
        this.acreCategoryValue = event.detail.value;
        let selectedAcerCategory = event.detail.value;
        if(selectedAcerCategory == '> 2.5 acres to 5 acres - individual'){
            this.borrowerCategoryValue = 41;
        }else if(selectedAcerCategory == 'upto 2.5 acres - individual'){
            this.borrowerCategoryValue = 42;
        }else if(selectedAcerCategory == 'Tenant Farmers/ Sharecroppers/ Oral lessees -  no own land'){
            this.borrowerCategoryValue = 44;
        }else if(selectedAcerCategory == 'Other (Medium and Large) - > 5 acres - individual'){
            this.borrowerCategoryValue = 45;
        }else{
            this.borrowerCategoryValue = 49;
        }
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    updateRecordDetails(fields) {
        const recordInput = { fields };
        if (this.isTractorProduct) {
            updateRecord(recordInput).then(() => {
                console.log('updateRecordDetails - Success:: ', fields);
            }).catch(error => {
                console.log('updateRecordDetails - Error:: ', error);
            });
        }
    }
    validateFields(fieldName) {
        let valid = true;
        this.template.querySelectorAll(fieldName).forEach(element => {
            if(!element.value){
                valid = false;
            }
        });
        return valid;
    }
}