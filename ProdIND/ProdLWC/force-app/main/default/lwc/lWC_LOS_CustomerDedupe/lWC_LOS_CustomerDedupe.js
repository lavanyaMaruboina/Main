import { api, LightningElement, wire, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRetryCount from '@salesforce/apex/Utilities.getRetryCountNew';
import getApplicantname from '@salesforce/apex/Ind_CustomerDedupCtrl.getApplicantName';
import getCustomerDedupeDetails from '@salesforce/apex/Ind_CustomerDedupCtrl.getCustomerDedupeDetails';
import validateDedupeCustomerCodeInSF from '@salesforce/apex/Ind_CustomerDedupCtrl.validateDedupeCustomerCodeInSF';
import validateCustomerCode from '@salesforce/apex/Ind_CustomerDedupCtrl.validateCustomerCode';
import inactivateCoBorrowerForPurging from '@salesforce/apex/Ind_CustomerDedupCtrl.inactivateCoBorrowerForPurging';
import validateRecentLeadCallout from '@salesforce/apexContinuation/IntegrationEngine.doValidateRecentLeadCallout';
import doExternalDedupeAPICallout from '@salesforce/apexContinuation/IntegrationEngine.doExternalDedupeCallout';
import FIELD_CUSTOMER_DEDUPE_RESPONSE_ID from '@salesforce/schema/Customer_Dedupe_Response__c.Id';
import FIELD_PG_CUST_DEDUPE from '@salesforce/schema/Customer_Dedupe_Response__c.PG_Cust_Dedupe__c';
import FIELD_DEDUPE_JOURNEY_STATUS from '@salesforce/schema/Customer_Dedupe_Response__c.Dedupe_Journey_Status__c';
import FIELD_DEDUPE_JOURNEY_STATUS_REASON from '@salesforce/schema/Customer_Dedupe_Response__c.Dedupe_Journey_Status_Reason__c';
import FIELD_DEDUPE_IS_NEW_CUSTOMER from '@salesforce/schema/Customer_Dedupe_Response__c.IND_isNewCustomer__c';//CISP-5266
import Invalid_Customer_Code_By_Sales_User from '@salesforce/schema/Customer_Dedupe_Response__c.Invalid_Customer_Code_By_Sales_User__c';
import FIELD_OPP_ID from '@salesforce/schema/Opportunity.Id';
import FIELD_OPP_STAGE_NAME from '@salesforce/schema/Opportunity.StageName';
import FIELD_OPP_LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import FIELD_OPP_JOURNEY_STOP_REASON from '@salesforce/schema/Opportunity.Journey_Stop_Reason__c';
import CMUJourneyStopReason from '@salesforce/label/c.CMUJourneyStopReason';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import customerdedupecomment from '@salesforce/label/c.CustomerDedupeComment';
import saveInvalidCustomerCode from '@salesforce/apex/Ind_CustomerDedupCtrl.saveInvalidCustomerCode';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication'; //CISP-3447
import withdrawnLeadBasedOnDecision from '@salesforce/apex/customerDedupeRevisedClass.withdrawnLeadBasedOnDecision';//CISP-3447
import validateRecentLeadCheck from '@salesforce/apex/Ind_CustomerDedupCtrl.validateRecentLeadCheck';
import updateApplicantIsAllRecordValid from '@salesforce/apex/customerDedupeRevisedClass.updateApplicantIsAllRecordValid';
import salesUserValidateAnyCode from '@salesforce/apex/customerDedupeRevisedClass.salesUserValidateAnyCode'
const columns = [
    { label: 'Customer Code', fieldName: 'CustomerCodeVal', type: 'text',
        cellAttributes: {
            iconName: { fieldName: 'Validity' },
            iconPosition: 'left',
            class:{fieldName:'color'}
        }
    },
    { label: 'Sur Name', fieldName: 'SurName' },//CISP-8511
    { label: 'Name', fieldName: 'Customer_Name' },
    {label: 'Active Flag',fieldName:'Active_Flag',type:'text'},//CISP-4525
    { label: 'Aadhar No.', fieldName: 'Aadhaar_No', type: 'text' },
    { label: 'Driving License No.', fieldName: 'Driving_License_Number', type: 'text' },
    { label: 'Passport No.', fieldName: 'Passport_Number', type: 'text' },
    { label: 'Voter ID No.', fieldName: 'Voter_ID_Number', type: 'text' },
    { label: 'PAN No.', fieldName: 'PAN_GIR_Number', type: 'text' },
    { label: 'Nominee DOB', fieldName: 'Date_of_Birth', type: 'text' },
    { label: 'Matched Parameter', fieldName: 'Rule_Matching_Fields', type: 'text' },
    { label: 'Matched Score', fieldName: 'Matched_Score', type: 'text' },
    { label: 'Data Source', fieldName: 'Matched_Source', type: 'text' }
];

export default class LWC_LOS_CustomerDedupe  extends LightningElement{
    isDedupeSubmittedByCMU = false;//CISP-9068
    @track isradioButtonSelected = false; //CISP-4570
    @api currentStage;
    @api currentStageName;
    @api lastStage;
    isCodeValidateBySalesUser = false;
    @track isYesChecked = false;//CISP-4356
    @track IsTwFound;//CISP-4356
    @track isNoChecked = false;//CISP-4356
    @track IsTWMatchLeadFound = false;//CISP-4356
    @track productType //CISP-3447
    @track vehicleType //CISP-3447
    isSop = false;//CISP-3447
    radioButtonVal;//CISP-3447
    @track existingLeadNoForTW;//CISP-3447
    @track existingLeadIdForTW;//CISP-3447
    @track existingLeadTWBeforeCPStage;//CISP-3447
    @track showRadioButton = false;//CISP-3447
    @track dedupeSubmitDisable = false;
    @track externalDedupeStatus;
    @api recordId;
    @api applicantId;
    @api custType;
    @api isCMUExecution = false;
    @api checkleadaccess;//coming from tabloanApplication

    @track customerResponseDisplayData = [];
    @track customerCodeList = [];
    @track leadNumberValue;
    @track customerNameValue;

    @track hideSelection = false;
    @track showDedupeDataTable = false;
    @track showCardMsg = false;
    @track showModal = true;
    @track showModalCancelBtn = false;
    @track showModalSpinner = true;
    @track cardMsg = null;
    @track modalMsg = null;
    enableRetriggerDedupe = true; //CSIP 142
    PGCustomerDedupeApplicationNo;//CISP 142
    dedupeJourneyStatus;
    dedupeJourneyStatusReason;
    customerDedupeResponseObjId;
    internalDedupeCustCodeExists;
    externalDedupeCustCodeExists;
    externalDedupeRecentLeadExists;
    externalDedupeAPIMaxAttempts;
    externalDedupeAPICurrentAttempts;
    customerDedupeResponse;
    validatedCustomerCode;
    invalidatedCustomerCode;
    invalidCustomerCodebySales;
    SFCustomerDedupeFlag = 1;
    PGCustomerDedupeFlag = 1;
    cicNo;

    columns = columns;
    isModalOpen=false;
    //activeCustomerCode=false;
    sameCustomerCode=false;
    @track confirmationModal = false;
    applicantNameDedupe;
    applicantNameSF;
    async connectedCallback(){
        await this.init();
        
        console.log('this.checkleadaccess ',this.checkleadaccess); 
        if(!this.isCMUExecution){ 
            this.callAccessLoanApplication(); 
        } 
        /*if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
            const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
            this.disableEverything();
        }*/
    }
    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordId , stage: 'Loan Initiation'}).then(response => {
            console.log('accessLoanApplication Response:: ', response,' ',this.checkleadaccess);
            if(!response){ 
                this.disableEverything();
                if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that                  
                    const evt = new ShowToastEvent({
                        title: ReadOnlyLeadAccess,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                this.disableEverything();
                }
            }
          }).catch(error => {
              console.log('Error in accessLoanApplication:: ', error);
          });
    } 
    async init()
    {
        console.log('InIt method')
        await getCustomerDedupeDetails({ applicantId: this.applicantId }).then((result) => {
            console.log('Existing Dedupe Details:: ', result);

            const parsedResult = JSON.parse(result);
            console.log('OUTPUT : ',parsedResult);
            this.isDedupeSubmittedByCMU = parsedResult.isCustomerDedupeSubmitted;//CISP-9068
            if(this.isDedupeSubmittedByCMU){
                this.disableEverything();
                this.hideSelection = true;
            }
            this.leadNumberValue = parsedResult.leadNumber;
            this.customerNameValue = parsedResult.customerName;
            this.custType = parsedResult.applicantType;
            this.productType = parsedResult.productType;
            this.vehicleType = parsedResult.vehicleType;
            this.validatedCustomerCode = parsedResult.customerCode;
            this.invalidatedCustomerCode = parsedResult.invalidCustomerCode;
            this.invalidCustomerCodebySales = parsedResult.invalidCustomerCodeBySales;
            console.log('OUTPUT ***: ',this.invalidCustomerCodebySales);
            this.SFCustomerDedupeFlag = parsedResult.SFCustomerDedupeFlag;
            this.PGCustomerDedupeFlag = parsedResult.PGCustomerDedupeFlag;
            this.dedupeJourneyStatus = parsedResult.dedupeJourneyStatus;
            this.dedupeJourneyStatusReason = parsedResult.dedupeJourneyStatusReason;
            this.isCodeValidateBySalesUser = parsedResult.isCodeValidateBySalesUser;
            this.externalDedupeAPIMaxAttempts = parsedResult.externalDedupeAPIMaxAttempts;
            this.customerDedupeResponseObjId = parsedResult.customerDedupeResponseObjId;
            this.customerDedupeResponse = JSON.parse(parsedResult.response);
            //CISP-4356 start
            this.IsTWMatchLeadFound = parsedResult.IsTWMatchLeadFound;
            if(this.IsTWMatchLeadFound && (this.validatedCustomerCode == null && this.invalidatedCustomerCode == null)){
                this.showRadioButton = true;
                this.IsTwFound = parsedResult.IsTwFound;
                if(this.IsTwFound == 'Yes'){
                    this.isYesChecked = true;
                    this.isradioButtonSelected = true;//CISP-4570
                }
                else if(this.IsTwFound == 'No'){
                    this.isNoChecked = true;
                    this.isradioButtonSelected = true;//CISP-4570
                }

            }//CISP-4356
            /*
             * Category 1: Journey Stop Cases
             *      Case 1: Journey Stop : SF Journey Stop Case (SFCustomerDedupeFlag === 0)
             *      Case 2: Journey Stop : External Vendor Journey Stop Case (PGCustomerDedupeFlag === 0)
             *      Case 3: Journey Stop : Invalid Selected Customer case (invalidatedCustomerCode)
             * Category 2: Journey Skip - New Customer Code Cases
             *      Case 4: Journey Skipped : No Valid and Invalid Customer Code Selection case (dedupeJourneyStatus === 'Skipped') 
             *      Case 5: Journey Skipped : No Dedupe found case (validatedCustomerCode)
             *      Case 6: Journey Skipped : Callout Error case (dedupeJourneyStatus === 'Skipped') 
             * Category 3: Journey Continue Cases
             *      Case 7: Journey Continue : Valid Selected Customer Code Case (validatedCustomerCode)
             */

            //If API is already executed then process it else execute
            //If Journey Skipped or Stopped then skip executing API again (Response can be null in this case)
            if(this.customerDedupeResponse !== null || this.dedupeJourneyStatus === 'Stopped' || this.dedupeJourneyStatus === 'Skipped'){
                console.log('The value of the status is '+ this.dedupeJourneyStatus)
                console.log('line 126')
                if(this.dedupeJourneyStatus === 'Skipped' && this.customerDedupeResponse == null)//CISP-4369(enable only when response comes as null)
                {
                    this.enableRetriggerDedupe = false;
                }
                this.processResponse();
            } else {
                this.executeDedupeAPIs();
            }
        }).catch((error) => {
            console.log('Error OUTPUT : ',error);
            console.log('Error in getting Dedupe Details: ' ,error?.body?.message);
        });
        if ((this.currentStage === 'Credit Processing') || ((this.currentStageName !== 'Loan Initiation' && this.lastStage !== 'Loan Initiation' && this.isCMUExecution == false))) {
            this.disableEverything();
        }
    }

    async executeDedupeAPIs()
    { 
        this.dispatchEvent(new CustomEvent('enablednextbutton'));//CISP-12522
        this.showModal=true
        this.showModalSpinner=true
        console.log('Executing API');
        let executeValidateRecentLeadAPI = false;
        let cicNosListForValidateRecentLeadAPI = [];

        //Execute External Dedupe API
        await this.executeExternalDedupeAPI();

        //1. Validate External Dedupe API Internally
        await validateDedupeCustomerCodeInSF({applicantId: this.applicantId, cicNo : this.cicNo, custDedupeResponse: this.customerDedupeResponse ? JSON.stringify(this.customerDedupeResponse) : null}).then(result => {//CISP-2524
            console.log('Validate Customer Dedupe Response:: ', result);
            const parsedResult = JSON.parse(result);
            this.dedupeJourneyStatus = parsedResult.dedupeJourneyStatus;
            this.dedupeJourneyStatusReason = parsedResult.dedupeJourneyStatusReason;
            this.SFCustomerDedupeFlag = parsedResult.SFCustomerDedupeFlag;
            this.PGCustomerDedupeFlag = parsedResult.PGCustomerDedupeFlag;
            this.internalDedupeCustCodeExists = parsedResult.internalDedupeCustCodeExists;
            this.externalDedupeCustCodeExists = parsedResult.externalDedupeCustCodeExists;
            this.externalDedupeRecentLeadExists = parsedResult.externalDedupeRecentLeadExists;
            this.customerDedupeResponseObjId = parsedResult.customerDedupeResponseObjId;
            this.existingLeadIdForTW = parsedResult.existingLeadIdForTW;//CISP-3447
            this.existingLeadNoForTW = parsedResult.existingLeadNoForTW;//CISP-3447
            this.existingLeadTWBeforeCPStage = parsedResult.existingLeadTWBeforeCPStage;//CISP-3447

            if(this.existingLeadTWBeforeCPStage == true){
                this.showRadioButton = true;
                this.IsTWMatchLeadFound = true;
            }
            
            //If SFCustDedupeFlag is 1(No Dedupe found in SF) then validate in external vendor server
            if(this.SFCustomerDedupeFlag === 1 && this.externalDedupeRecentLeadExists === true && this.dedupeJourneyStatus !== 'Stopped' && this.dedupeJourneyStatus !== 'Skipped') {    
                executeValidateRecentLeadAPI = true;
                cicNosListForValidateRecentLeadAPI = parsedResult.cicNoSet;
            }
           

        }).catch(error => {
            console.log('Error in Validating Customer Dedupe Response:: ', JSON.stringify(error));
            //CISP 142:
                        this.showToastMessage(' Kindly retry after some time'); 
        });

        console.log('Recent Lead Exists:: ', this.externalDedupeRecentLeadExists);
        console.log('Execute Validate Recent Lead API:: ', executeValidateRecentLeadAPI);
        console.log('Cic NO List:: ', cicNosListForValidateRecentLeadAPI);

        //2. Validate External Dedupe API Externally
        if(executeValidateRecentLeadAPI){
            let blcodeNoFromApi;//CISP-7280
            for (let cicNo of cicNosListForValidateRecentLeadAPI) {
                console.log('CIC:: ', cicNo);
                if(this.PGCustomerDedupeFlag === 1)
                {  
                    await validateRecentLeadCallout({loanApplicationId : this.recordId, sCICNo: cicNo, sLeadNo: this.leadNumberValue,applicantId:this.applicantId}).then(result => {
                        console.log('ValidateRecentLeadCallout - Response:: ', result);
                        const parsedResult = JSON.parse(result);
                      
                        if(parsedResult?.response?.content[0]?.PG_cust_dedupe == 0)
                        {
                             //this.enableRetriggerDedupe=false;//CISP-7280
                             this.dispatchEvent(new CustomEvent('disablenextbutton'));
                            this.PGCustomerDedupeFlag = parsedResult?.response?.content[0]?.PG_cust_dedupe;
                            //CISP:142
                            this.PGCustomerDedupeApplicationNo=parsedResult?.response?.content[0]?.PG_Application_No;
                            blcodeNoFromApi = parsedResult?.response?.content[0]?.BL_Code;//CISP-7280
                             validateRecentLeadCheck({ leadNo: this.PGCustomerDedupeApplicationNo })// method call we only send dedupe response, message and one flag isstopped
                               .then(result => {
                                 console.log('Result', result);
                                 const parsedResult = JSON.parse(result);
                                 this.dedupeJourneyStatus = parsedResult.dedupeJourneyStatus;
                                this.dedupeJourneyStatusReason = parsedResult.dedupeJourneyStatusReason;
                                this.existingLeadIdForTW = parsedResult.existingLeadIdForTW;//CISP-3447
                                this.existingLeadNoForTW = parsedResult.existingLeadNoForTW;//CISP-3447
                                this.existingLeadTWBeforeCPStage = parsedResult.existingLeadTWBeforeCPStage;//CISP-3447
                                this.externalDedupeRecentLeadExists = parsedResult.externalDedupeRecentLeadExists;
                                this.isSop = parsedResult.isStop;
                                if(this.existingLeadTWBeforeCPStage == true){
                                    this.showRadioButton = true;this.IsTWMatchLeadFound = true
                                }
                               })
                               .catch(error => {
                                 console.error('Error:', error);
                             });

                        }
                    }).catch(error => {
                        console.log('ValidateRecentLeadCallout - Error:: ', JSON.stringify(error));
                    });
                } else {
                    break;
                }
            }

            console.log('External Dedupe Cust Code Exists:: ', this.externalDedupeCustCodeExists);
            console.log('Internal Dedupe Cust Code Exists:: ', this.internalDedupeCustCodeExists);
            console.log('PG Cust Dedupe Flag:: ', this.PGCustomerDedupeFlag);
            if(this.PGCustomerDedupeFlag == 0 && this.customerDedupeResponseObjId !== null){ //isstop = true
                let stopReason = '';//CISP-7280
                if(this.isSop == true){
                    stopReason = this.dedupeJourneyStatusReason;
                }else{
                    stopReason = 'There is an existing lead '+ this.PGCustomerDedupeApplicationNo +' at '+ blcodeNoFromApi +' Hence you cannot proceed with this lead';//CISP-7280
                }
                const fields = {};
                fields[FIELD_CUSTOMER_DEDUPE_RESPONSE_ID.fieldApiName] = this.customerDedupeResponseObjId;
                fields[FIELD_PG_CUST_DEDUPE.fieldApiName] = 0;
                fields[FIELD_DEDUPE_JOURNEY_STATUS.fieldApiName] = 'Stopped';
                fields[FIELD_DEDUPE_JOURNEY_STATUS_REASON.fieldApiName] = stopReason;//CISP-3447
                //CISP: 142
                //fields[FIELD_DEDUPE_JOURNEY_STATUS_REASON.fieldApiName] = `This is an existing lead. Please ask the customer to withdraw ${this.PGCustomerDedupeApplicationNo} and re-trigger customer dedupe OR continue with the earlier application  ${this.PGCustomerDedupeApplicationNo}.`;//whateevr we pass from apex
                console.log('Update fields:: ', fields);
                this.updateRecordDetails(fields);

                this.dedupeJourneyStatus = 'Stopped';
                this.dedupeJourneyStatusReason = stopReason;//CISP-3447
                //CISP:142
                //this.dedupeJourneyStatusReason = `This is an existing lead. Please ask the customer to withdraw ${this.PGCustomerDedupeApplicationNo} and re-trigger customer dedupe OR continue with the earlier application  ${this.PGCustomerDedupeApplicationNo}.`;
                 //this.enableRetriggerDedupe=false;//CISP-7280//Enable Re-Trigger Button when the PG flag is 0
                 this.dispatchEvent(new CustomEvent('disablenextbutton'))// Desiable the Next button
        
            } else if(this.externalDedupeCustCodeExists === false && this.internalDedupeCustCodeExists === false)
            {
                const fields = {};
                fields[FIELD_CUSTOMER_DEDUPE_RESPONSE_ID.fieldApiName] = this.customerDedupeResponseObjId;
                fields[FIELD_DEDUPE_JOURNEY_STATUS.fieldApiName] = 'Continued';
                fields[FIELD_DEDUPE_JOURNEY_STATUS_REASON.fieldApiName] = 'There are no matching code available for the applicant, hence journey will proceed as new customer'; //CISP-4651
                fields[FIELD_DEDUPE_IS_NEW_CUSTOMER.fieldApiName] =true;//CISP-5266
                console.log('Update fields:: ', fields);
                this.updateRecordDetails(fields);

                this.dedupeJourneyStatus = 'Continued';
                this.dedupeJourneyStatusReason = 'There are no matching code available for the applicant, hence journey will proceed as new customer';//CISP-4651
            }

            this.processResponse();
        } else {
            console.log('Prcessing without Validating Recent Lead API');
            this.processResponse();
        }
    }
    //CISP-3447 start
    handleFieldValueChange(event) {
        this.radioButtonVal = event.target.value;
        this.existingLeadNoForTW = this.dedupeJourneyStatusReason.substring(0,this.dedupeJourneyStatusReason.indexOf(' '));
        if(this.radioButtonVal == 'Yes'){
            this.isYesChecked = true;//CISP-4356
            this.showToastMessage('Info', 'You have chosen Yes to proceed with “'+this.leadNumberValue+'”; hence earlier “'+this.existingLeadNoForTW+'” will be withdrawn', 'warning');
            this.hideSelection = false;
        }else{
            this.isNoChecked = true;//CISP-4356
            this.showToastMessage('Info', 'You have chosen No to proceed with “'+this.leadNumberValue+'”; This lead will be withdrawn on submission of this screen', 'warning');
            this.template.querySelector('lightning-button[data-id=ValidBtnId]').disabled = true; //CISP-4356
            this.template.querySelector('lightning-button[data-id=InvalidBtnId]').disabled = true;//CISP-4356
            this.hideSelection = true
        }
    } //CISP-3447 end
    async executeExternalDedupeAPI(){
        this.enableRetriggerDedupe = true;
        let timeInterval;
        //let externalDedupeStatus;
        let apiInputs = {
            'applicantId': this.applicantId,
            'leadId' : this.leadNumberValue,
            'loanApplicationId' : this.recordId
        };

        //Get retried counts before executing API - This will also consider current execution count
        await getRetryCount({loanApplicationId : this.recordId, applicantType : this.custType, countfieldName : 'Customer_Dedupe__c', metadataAttemptsField : 'Customer_Dedupe_Attempts', applicantId: this.applicantId}).then((result) => {
            this.externalDedupeAPICurrentAttempts = result;
            console.log('Current Retry Count:: ', result);
            console.log('Total Count:: ', this.externalDedupeAPIMaxAttempts);
        }).catch((error) => {
            console.log('Error in getting API Count: ' +error?.body?.message);
        });

        if((this.externalDedupeAPICurrentAttempts <= this.externalDedupeAPIMaxAttempts && this.isCMUExecution == false && (this.productType == 'Two Wheeler' || this.productType == 'Tractor' || this.productType == 'Passenger Vehicles') && this.vehicleType == 'New') ||
        (this.isCMUExecution==true) || ((this.productType == 'Passenger Vehicles' || this.productType == 'Two Wheeler' || this.productType == 'Tractor') && (this.vehicleType == 'Used' || this.vehicleType == 'Refinance'))){ //CISP-3447 (retrigger 3 attempts for sales user (PV TW New) , cmu user no limit, sales user (PV used and refinace) no limit)
            console.log('Executing External Dedupe API:: ', JSON.stringify(apiInputs));
            
                 await doExternalDedupeAPICallout({'externalDedupeRequestString' : JSON.stringify(apiInputs)}).then(result => 
                    {
                    this.cicNo = result.cicNo;
                    try{
                        this.customerDedupeResponse = JSON.parse(result.Response);
                        console.log('The customer dedupe response is '+this.customerDedupeResponse);
                        console.log('The customer dedupe response is '+JSON.stringify(this.customerDedupeResponse));
        
                        if(this.customerDedupeResponse.response.status){
                            this.externalDedupeStatus = this.customerDedupeResponse.response.status;
                        
                        }
                            //CISp:142
                            if(this.customerDedupeResponse==null)
                            {//CISP:3447 start
                                console.log('I am in customer dedupe null resonce check '+this.customerDedupeResponse);
                                if(this.externalDedupeAPICurrentAttempts <=1){   
                                    timeInterval = 60000;
                                    console.log('timeInterval i if: ',timeInterval);
                                }else{
                                    timeInterval = 30000
                                    console.log('timeInterval : ',timeInterval);
                                }
                                setTimeout(() => {
                                    this.enableRetriggerDedupe = false;
                                    console.log('timeInterval : ',timeInterval);
                                }, timeInterval);//CISP:3447 start
                                
                            }
                    } catch(error){
                        console.log('Error in Parsing Dedupe API');
                        if(result.Response){
                            this.customerDedupeResponse = result.Response;
                        } else {
                            console.log('I am in customer dedupe responce null')
                            this.customerDedupeResponse = result;
                            //CISP:3447 start
                            if(this.externalDedupeAPICurrentAttempts <=1){
                                timeInterval = 60000
                            }else{
                                timeInterval = 30000
                            }
                            setTimeout(() => {
                                this.enableRetriggerDedupe = false;
                            }, timeInterval);//CISP:3447 start
                        }
                        this.externalDedupeStatus = 'FAILED';
                    }
        
                    console.log('Current CIC NO:: ', result.cicNo);
                    
                }).catch(error => {
                    console.log('Error in Executing External Dedupe API:: ' ,error);
                    this.externalDedupeStatus = 'FAILED';
                    if(this.productType == 'Tractor'){this.dispatchEvent(new CustomEvent('enablednextbutton'));}else{this.dispatchEvent(new CustomEvent('disablenextbutton'));}
                });
                       
            console.log('External Dedupe Parsed Response:: ', this.customerDedupeResponse);
            console.log('External Dedupe API Status:: ', this.externalDedupeStatus);

            if(this.externalDedupeStatus === 'FAILED')
            {
                //CISP: 142  Customer dedupe if failed, then this retrigger button to be clicked by user mandatorily. The user will be able to continue only if response is available
                
                //this.enableRetriggerDedupe=false;
                //CISP-3447
                    if(this.externalDedupeAPICurrentAttempts <=1){
                        timeInterval = 60000
                    }else{
                        timeInterval = 30000
                    }
                    setTimeout(() => {
                        this.enableRetriggerDedupe = false;
                    }, timeInterval);
                if(this.productType == 'Tractor'){this.dispatchEvent(new CustomEvent('enablednextbutton'));}else{this.dispatchEvent(new CustomEvent('disablenextbutton'));}
                //await this.executeExternalDedupeAPI();
            }
        } else {
            this.showToastMessage('Journey was proceeded as new customer', 'Dedupe Callout Error, Retry Count Exhausted', 'warning');
            this.dispatchEvent(new CustomEvent('enablednextbutton'));
            //CISP:142 this.enableRetriggerDedupe=false;
            //CISP-3447
            /*if(this.externalDedupeAPICurrentAttempts <=1){ commented code because if retry count exhausted re-trigger should be disabled and next button should be enabled
                timeInterval = 60000
            }else{
                timeInterval = 30000
            }
            setTimeout(() => {
                this.enableRetriggerDedupe = false;
            }, timeInterval);
            
                this.dispatchEvent(new CustomEvent('disablenextbutton'));*/

        }
    }

    //Display Dedupe Customet Response Data
    processResponse(){
        let externalAndInternalResponseUnion = [];
        let externalRes = this.customerDedupeResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate;
        let internalRes = this.customerDedupeResponse?.response?.content[0]?.Data?.InternalDedupeResponse;
        console.log('externalRes : ',externalRes);
        console.log('internalRes : ',internalRes);
        let customerMasterList = this.customerDedupeResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerMaster;
        console.log('customerMasterList : ',customerMasterList);
        if(externalRes){
            externalAndInternalResponseUnion.push(externalRes);
        }
        if(internalRes?.length > 0){
            for(let i=0 ; i< internalRes.length ; i++){
                let internalObj = this.customerDedupeResponse?.response?.content[0]?.Data?.InternalDedupeResponse[i]?.CustomerValidate;
                externalAndInternalResponseUnion.push(internalObj);//CISP-14294
            }
        }

        console.log('Processing Internal and External response:: ', externalAndInternalResponseUnion);
        console.log('externalAndInternalResponseUnion length:: ', externalAndInternalResponseUnion.length);

        if(externalAndInternalResponseUnion.length > 0){
            let invalidcodeObj = this.invalidatedCustomerCode != null ? this.invalidatedCustomerCode.split(','): null;
            console.log('OUTPUT invalidCustomerCodebySales: ',this.invalidCustomerCodebySales);
            let invalidCodeBySales = this.invalidCustomerCodebySales != null ? this.invalidCustomerCodebySales.split(','): null;
            console.log('invalidcodeObj : ',invalidcodeObj);
            console.log('invalidCodeBySales : ',invalidCodeBySales);
            for(let index in externalAndInternalResponseUnion){
                let customerObjs = externalAndInternalResponseUnion[index];
                //console.log('Current response:: ', customerObjs);

                for (let key in customerObjs) {
                    if (customerObjs.hasOwnProperty(key)) {
                        if(this.customerCodeList.includes(customerObjs[key].CustomerCodeVal)){
                            //console.log('Skipped:: ', customerObjs[key].CustomerCodeVal);
                            continue;
                        }
                        this.customerCodeList.push(customerObjs[key].CustomerCodeVal);
                          
                        //Aadhar masking Change - Started
                        let customerMaster = customerObjs[key].CustomerMaster[0];
                        let customerStatus = customerObjs[key].CustomerStatus[0];//CISP-4525
                        let newCustomerMaster = customerMasterList != null ? customerMasterList[key]:null;//CISP-5333
                        
                        for (let key in customerMaster) {
                            if (key === 'Aadhaar_No' && customerMaster.hasOwnProperty(key) && customerMaster[key] != null) {
                                let aadharNo = customerMaster[key];
                                customerMaster[key] = 'XXXX-XXXX-' + aadharNo.substr(aadharNo.length - 4)
                            }
                            if(newCustomerMaster && key === 'Rule_Matching_Fields' && newCustomerMaster.hasOwnProperty(key) && newCustomerMaster[key] != null){
                                customerMaster[key] = newCustomerMaster[key]
                            }
                            if(newCustomerMaster && key === 'Matched_Score' && newCustomerMaster.hasOwnProperty(key) && newCustomerMaster[key] != null){
                                customerMaster[key] = newCustomerMaster[key]
                            }
                            if(newCustomerMaster && key === 'Matched_Source' && newCustomerMaster.hasOwnProperty(key) && newCustomerMaster[key] != null){
                                 customerMaster[key] = newCustomerMaster[key]
                            }
                            if(newCustomerMaster && key === 'Matched_Parameter_Value' && newCustomerMaster.hasOwnProperty(key) && newCustomerMaster[key] != null){
                                 customerMaster[key] = newCustomerMaster[key]
                            }
                        }
                        //Aadhar masking Change - Ended

                        let custObj;
                        if((invalidcodeObj?.includes(customerObjs[key].CustomerCodeVal)) || (invalidCodeBySales?.includes(customerObjs[key].CustomerCodeVal))){
                            custObj = {
                                ...customerMaster,
                                ...{'CustomerCodeVal' : customerObjs[key].CustomerCodeVal},
                                ...{'Validity' : 'utility:close'},
                                ...{'color': 'slds-text-color_error'},
                                ...customerStatus
                            };
                            if(this.isCMUExecution != true)
                                this.hideSelection = true;
                        } else if(this.validatedCustomerCode === customerObjs[key].CustomerCodeVal && customerObjs[key].CustomerCodeVal != null){
                            custObj = {
                                ...customerMaster,
                                ...{'CustomerCodeVal' : customerObjs[key].CustomerCodeVal},
                                ...{'Validity' : 'utility:success'},
                                ...{'color': 'slds-text-color_success'},
                                ...customerStatus
                            };
                            if(this.isCMUExecution != true)
                                this.hideSelection = true;
                        } else {
                            if(customerObjs[key].CustomerCodeVal != null){
                                custObj = {
                                    ...customerMaster,
                                    ...{'CustomerCodeVal' : customerObjs[key].CustomerCodeVal},
                                    ...customerStatus
                                };
                            }
                        }
                        if(custObj != undefined || custObj != null){//CISP-9170||CISP-9193 
                            this.customerResponseDisplayData.push(custObj); 
                        } 
                    }
                }
                console.log('this.customerResponseDisplayData--' , this.customerResponseDisplayData);
            }

            if(this.dedupeJourneyStatus === 'Stopped'){
                if(this.SFCustomerDedupeFlag === 0){
                    //Case 1: Journey Stop : SF Journey Stop Case
                    if(this.isCMUExecution != true)
                        this.hideSelection = true;
                    this.showDedupeDataTable = true;
                    this.cardMsg = this.dedupeJourneyStatusReason;
                    this.showCardMsg = true;
                    if(this.productType == 'Two Wheeler'){ //CISP-4554
                        this.enableRetriggerDedupe = true;
                    }else{
                        this.enableRetriggerDedupe = false;
                    }
                    this.dispatchEvent(new CustomEvent('disablenextbutton'));//CISP-4335
                } else  if(this.PGCustomerDedupeFlag === 0){
                    //Case 2: Journey Stop : External Vendor Journey Stop Case
                    if(this.isCMUExecution != true)
                        this.hideSelection = true;
                    this.showDedupeDataTable = true;
                     //CISP-142
                     this.enableRetriggerDedupe=false;
                     this.dispatchEvent(new CustomEvent('disablenextbutton'));
                    this.cardMsg = this.dedupeJourneyStatusReason;
                    this.showCardMsg = true;
                } else if(this.invalidatedCustomerCode !== null){
                    //Case 3: Journey Stop : Invalid Selected Customer Code Case
                    this.hideSelection = true;
                    this.showDedupeDataTable = true;
                    this.cardMsg = this.dedupeJourneyStatusReason;
                    this.showCardMsg = true;
                    this.dispatchEvent(new CustomEvent('disablenextbutton'));//CISP-4534
                } /*else if(this.isCMUExecution == true){
                    //Case 3: Journey Stop : Invalid Selected Customer Code Case
                    this.hideSelection = true;
                    this.showDedupeDataTable = true;
                    this.cardMsg = this.dedupeJourneyStatusReason;
                    this.showCardMsg = true;
                }*/ else {
                    //Case 4: Journey Stop : Hard Stop (Fraud Check) or Callout Error Case
                    this.hideSelection = true;
                    this.showDedupeDataTable = false;
                    this.cardMsg = this.dedupeJourneyStatusReason;
                    this.showCardMsg = true;
                    this.dispatchEvent(new CustomEvent('disablenextbutton'));//CISP-4493
                }
                 if(this.SFCustomerDedupeFlag === 1 && this.PGCustomerDedupeFlag === 0){ //re-trigger button disable when match lead found from external server
                    this.enableRetriggerDedupe=true;
                }
                
            } else if(this.dedupeJourneyStatus === 'Skipped'){
                if(this.isCMUExecution != true){
                    this.hideSelection = true;
                    this.cardMsg = this.dedupeJourneyStatusReason;
                    this.showCardMsg = true;
                }
                if(this.isCMUExecution == true && (invalidCodeBySales?.length == this.customerResponseDisplayData?.length)){
                    this.cardMsg = this.dedupeJourneyStatusReason;
                    this.showCardMsg = true;
                    this.hideSelection = false;
                }
                this.showDedupeDataTable = true;
            } else if(this.dedupeJourneyStatus === 'Continued'){
                if(this.isCMUExecution != true)
                    this.hideSelection = true;
                this.showDedupeDataTable = true;
                this.cardMsg = this.dedupeJourneyStatusReason;
                this.showCardMsg = true;
            } else {
                console.log('line 438')
                //Displays message to sales user if response is successful and customer code is identified.
                this.cardMsg = 'Dedupe match is identified. Please check and validate';
                this.showCardMsg = true;
                this.hideSelection = false;
                this.showDedupeDataTable = true;
            }
        } else {
            this.showDedupeDataTable = false;
            this.dedupeJourneyStatus = 'Skipped';
            this.cardMsg = this.dedupeJourneyStatusReason;
            this.showCardMsg = true;
            this.enableRetriggerDedupe = false;//When customer validate null for both internal and external response CISP-4906
            if(this.dedupeJourneyStatusReason == 'There are no matching code available for the applicant, hence journey will proceed as new customer'){
                this.enableRetriggerDedupe = true; //CISP-20694
            }
        }

        this.showModalSpinner = false;
        this.showModal = false;

        console.log('The value at the last 465', this.enableRetriggerDedupe);

        if(this.isCMUExecution == true){
            let cmumsg = '';
            if(this.isCodeValidateBySalesUser && this.validatedCustomerCode != null){
                this.customerResponseDisplayData.forEach(currentItem => {
                    console.log('OUTPUT currentItem: ',currentItem);
                    if(this.validatedCustomerCode === currentItem.CustomerCodeVal){
                        console.log('OUTPUT currentItem.CustomerCodeVal: ',currentItem.CustomerCodeVal);
                        cmumsg = 'The code: '+ this.validatedCustomerCode + ': '+currentItem.Customer_Name + ' identified basis '+ currentItem.Rule_Matching_Fields+' with value '+currentItem.Matched_Parameter_Value+' and percentage of match is '+currentItem.Matched_Score + '% was chosen as valid for '+this.custType;   
                    }
                });
                this.cardMsg = cmumsg;
            }
            this.disableAllRows();   
        }
        if(this.isCodeValidateBySalesUser){
            this.hideSelection = true;
        }
    }
    disableAllRows(){
        console.log('OUTPUT this.customerResponseDisplayData: ',this.customerResponseDisplayData);
        let codes = [];
        this.customerResponseDisplayData.forEach(currentItem => {
            codes.push(currentItem.CustomerCodeVal);
        });
        let allcodes = [];
        let invalidcodeObj = this.invalidatedCustomerCode != null ? this.invalidatedCustomerCode.split(','): null;
        if(invalidcodeObj){
            allcodes.push(...invalidcodeObj);
        }
        if(this.validatedCustomerCode != null)
            allcodes.push(this.validatedCustomerCode);
        console.log('OUTPUT allcodes: ',allcodes);
        if((allcodes.length > 0 && this.customerResponseDisplayData.length >0) || this.customerResponseDisplayData.length == 0){
            if(allcodes.length  == this.customerResponseDisplayData.length ){
                this.hideSelection = true;
                updateApplicantIsAllRecordValid({ app: this.applicantId })
                  .then(result => {
                    console.log('Result', result);
                  })
                  .catch(error => {
                    console.error('Error:', error);
                });
            }
        }
    }
    //To block multiple Row Selection
    handleRowSelection = event => {
        let selectedRows=event.detail.selectedRows;

        if(selectedRows.length == 0) {
            this.template.querySelector('lightning-button[data-id=ValidBtnId]').disabled = true;
            this.template.querySelector('lightning-button[data-id=InvalidBtnId]').disabled = true;
        } else {
            this.template.querySelector('lightning-button[data-id=ValidBtnId]').disabled = false; 
            this.template.querySelector('lightning-button[data-id=InvalidBtnId]').disabled = false;
        }

        /*if(selectedRows.length > 1){
            let el = this.template.querySelector('lightning-datatable');

            if(selectedRows.length > 2){
                el.selectedRows = [];
            } else {
                selectedRows=el.selectedRows=el.selectedRows.slice(1);
            }
            event.preventDefault();
            return;
        }*/
    }

    //CISP-3447 start 
    async handleInvalid(){
        this.showRadioButton = false;
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        let allRows = this.customerResponseDisplayData.length;
        if(allRows == selectedRows.length){
            this.showCardMsg = true;
            if(this.isCMUExecution){
                this.cardMsg = '"No customer code” is chosen as valid. Proceeding as new customer for ' + this.custType;
            }else{
                this.cardMsg = '"No customer code” is chosen as valid. Moving ahead for CMU validation';
            }
        }
        console.log('OUTPUT selectedRows: ',selectedRows);
        
        let selectedData = JSON.parse(JSON.stringify(selectedRows));
        let invalidCustomerCodes = '';
        selectedData.forEach(currentItem => {
            invalidCustomerCodes = invalidCustomerCodes + currentItem.CustomerCodeVal + ',';
        });
        console.log('OUTPUT invalidCustomerCodes: ',invalidCustomerCodes);
        invalidCustomerCodes = invalidCustomerCodes.substring(0,invalidCustomerCodes.length-1);
        console.log('OUTPUT : ',invalidCustomerCodes);
        await saveInvalidCustomerCode({ applicantId: this.applicantId ,selectedInvalidCustomerCodes: invalidCustomerCodes, userProfile : this.isCMUExecution})
          .then(result => {
            console.log('ResultsaveInvalidCustomerCode', result);
            this.invalidatedCustomerCode = result;
            this.showToastMessage('Info', 'Selected code mark as invalid.', 'Info');
            console.log('ResultsaveInvalidCustomerCode', this.invalidatedCustomerCode);
          })
          .catch(error => {
            console.error('Error:', error);
        });
       
        if(this.isCMUExecution == true){
            this.disableAllRows();
        }
        this.template.querySelector('lightning-button[data-id=ValidBtnId]').disabled = true;//CISP-9068
        this.template.querySelector('lightning-button[data-id=InvalidBtnId]').disabled = true;//CISP-9068
    }

    //Handler for Valid Button
    handleValid(){
        if(this.validatedCustomerCode != null){
            this.showToastMessage('', 'Valid code already present. You can not change the valid code', 'error');
            return null;
        }else{
        this.showRadioButton = false;
        //this.showModalSpinner = true;
        this.showModalCancelBtn = false;
        // this.showModal = true;
        // this.showDedupeDataTable = false;
        //CISP-3447 start
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        console.log('selectedRows : ',selectedRows.length);
        if(selectedRows.length > 1){
            this.showModalSpinner = false;
            this.showToastMessage('', 'Please choose only one code to progress.', 'error');
            this.showModal = false;
            this.showDedupeDataTable = true;
            return null;
        }//CISP-3447 end
        let selectedCustomerDetailsTable = this.template.querySelector('lightning-datatable').getSelectedRows()[0];
        this.applicantNameDedupe = selectedCustomerDetailsTable.Customer_Name;
        getApplicantname({applicantId: this.applicantId}).then(response => {
            this.applicantNameSF = response;
            console.log('applicantNameSF__'+this.applicantNameSF);
        }).catch(error => {
            console.warn('validateCustomerCode - error: ', error);
        });
        if(this.applicantNameDedupe?.toLowerCase()!=this.applicantNameSF?.toLowerCase()){
            this.confirmationModal = true;
        }else{
            this.showModalSpinner = true;
            this.showModal = true;
            this.handleValidCode();
        }
    }
}
yesPopUPHandler(){
    this.confirmationModal = false;
    this.showModalSpinner = true;
    this.showModal = true;
    this.handleValidCode();
}

noPopUPHandler(){
    this.confirmationModal = false;
    this.showDedupeDataTable = true;
}

closeModal(){
    this.isModalOpen = false;
    //this.activeCustomerCode = false;
    this.sameCustomerCode = false;
}
handleValidCode(){
    let selectedCustomerDetails = this.template.querySelector('lightning-datatable').getSelectedRows()[0];

    console.log('IS CMU Execution:: ', this.isCMUExecution);

        /*if(this.isCMUExecution == true)
        {
            this.dedupeJourneyStatus = 'Stopped';
            this.showModalSpinner = false;
            this.modalMsg = CMUJourneyStopReason;
            this.showModal = true;

            selectedCustomerDetails.Validity = 'utility:close';
            selectedCustomerDetails.color = 'slds-text-color_error';
            this.invalidatedCustomerCode = selectedCustomerDetails.CustomerCodeVal;
            this.hideSelection = true;
            this.showDedupeDataTable = true;

            this.template.querySelector('lightning-button[data-id=ValidBtnId]').disabled = true;

            const fields = {};
            fields[FIELD_CUSTOMER_DEDUPE_RESPONSE_ID.fieldApiName] = this.customerDedupeResponseObjId;
            fields[FIELD_DEDUPE_JOURNEY_STATUS.fieldApiName] = 'Stopped';
            fields[FIELD_DEDUPE_JOURNEY_STATUS_REASON.fieldApiName] = CMUJourneyStopReason;
            console.log('Update fields:: ', fields);
            this.updateRecordDetails(fields);

            const oppfields = {};
            oppfields[FIELD_OPP_ID.fieldApiName] = this.recordId;
            oppfields[FIELD_OPP_STAGE_NAME.fieldApiName] = 'Journey Stop';
            oppfields[FIELD_OPP_LAST_STAGE_NAME.fieldApiName] = 'Journey Stop';
            oppfields[FIELD_OPP_JOURNEY_STOP_REASON.fieldApiName] = CMUJourneyStopReason;
            console.log('Update fields:: ', oppfields);
            this.updateRecordDetails(oppfields);
        } else {*/
            validateCustomerCode({applicantId: this.applicantId, oppId: this.recordId, dedupCustomerDetails: JSON.stringify(selectedCustomerDetails), customerType: this.custType}).then(response => {
                const result = JSON.parse(response);

                console.log('Customer Data:: ',result);
                if(result.message == 'Same customer code chosen for both borrower and co borrower'){
                    this.showModalSpinner = false;
                    this.showModal = false;
                    this.isModalOpen = true;
                    this.sameCustomerCode = true;
                    //this.activeCustomerCode = false;
                    this.showDedupeDataTable = true;
                    return;
                }
                //Invalid Customer
                if(result.isValid === false){
                    this.dedupeJourneyStatus = 'Stopped';
                    this.showModalSpinner = false;
                    this.invalidatedCustomerCode = result.invalidCustomerCode;
                    this.modalMsg = result.message;
                    this.showModal = true;

                    selectedCustomerDetails.Validity = 'utility:close';
                    selectedCustomerDetails.color = 'slds-text-color_error';
                    if(this.isCMUExecution != true){
                        this.hideSelection = true;
                    }
                        this.cardMsg = result.message;//CISP-4534
                        this.showCardMsg = true;//CISP-4534
                        this.dispatchEvent(new CustomEvent('disablenextbutton'));//CISP-4534
                } else {
                    //Valid Customer
                    this.validatedCustomerCode = result.customerCode;
                    this.showModalSpinner = false;
                    this.modalMsg = result.message ; //'Selected customer is identified as valid'; //CISP-3447
                    this.cardMsg = result.message;//cisp-3447
                    this.showModal = true;
                    this.showCardMsg = true;//CISP-4534
                    selectedCustomerDetails.Validity = 'utility:success';
                    selectedCustomerDetails.color = 'slds-text-color_success';
                    if(this.isCMUExecution != true)
                        this.hideSelection = true;
                }
                this.showDedupeDataTable = true;
                if(this.isCMUExecution != true){
                    salesUserValidateAnyCode({ applicantId: this.applicantId })
                    .then(result => {
                        console.log('Result', result);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });
                }
                if(this.isCMUExecution == true){
                    this.disableAllRows();
                }
                this.template.querySelector('lightning-button[data-id=ValidBtnId]').disabled = true;
                this.template.querySelector('lightning-button[data-id=InvalidBtnId]').disabled = true;
            }).catch(error => {
                console.warn('validateCustomerCode - error: ', error);
                this.showModalSpinner = false;
                this.showModal = false;
            });
        //}
    }

    async purgeCoborrower(){
        await inactivateCoBorrowerForPurging({applicantId: this.applicantId}).then(result => {
            console.log('inactivateCoBorrowerForPurging - Result:: ', result);
            
            if(result === true) {    
                this.dispatchEvent(new CustomEvent('deletecoborrower', { bubbles: true, composed: true }));
            } else {
                this.showToastMessage('', 'Error in purging the record', 'error');
            }
        }).catch(error => {
            console.log('inactivateCoBorrowerForPurging - Error:: ' +JSON.stringify(error));
            this.showToastMessage('', 'Error in purging the record', 'error');
        });
    }

    //Called from Parent Popup modal
    async handleModalOkAction(){
        this.showModal = false;
        this.showModalCancelBtn = false;
        this.modalMsg = null;

        //2. Without validating any customer code - Journey Auto Next
        if(this.validatedCustomerCode === null && this.invalidatedCustomerCode === null){
            console.log('OUTPUT this.customerResponseDisplayData: ',this.customerResponseDisplayData.length);
            console.log('OUTPUT this.customerResponseDisplayData: ',JSON.parse(JSON.stringify(this.customerResponseDisplayData)));
            let allCodesData = JSON.parse(JSON.stringify(this.customerResponseDisplayData));
            let invalidCustomerCodes = '';
            if(allCodesData.length >0){
                allCodesData.forEach(currentItem => {
                    invalidCustomerCodes = invalidCustomerCodes + currentItem.CustomerCodeVal + ','
                });
                console.log('OUTPUT invalidCustomerCodes: ',invalidCustomerCodes);
                invalidCustomerCodes = invalidCustomerCodes.substring(0,invalidCustomerCodes.length-1);
            }
            const fields = {};
            fields[FIELD_CUSTOMER_DEDUPE_RESPONSE_ID.fieldApiName] = this.customerDedupeResponseObjId;
            fields[FIELD_DEDUPE_JOURNEY_STATUS.fieldApiName] = 'Skipped';
            fields[FIELD_DEDUPE_JOURNEY_STATUS_REASON.fieldApiName] = 'No Customer code validated, Journey was proceeded as new customer';
            //fields[FIELD_DEDUPE_IS_NEW_CUSTOMER.fieldApiName] =true;//CISP-5266
            fields[Invalid_Customer_Code_By_Sales_User.fieldApiName] = invalidCustomerCodes;
            console.log('Update fields:: ', fields);
            this.updateRecordDetails(fields);
        
            this.dispatchEvent(new CustomEvent('allownextstep', { detail: {journeystop:false, autonext:true} }));
        }
    }

    handleModalCancelAction(){
        this.showModal = false;
        this.showModalCancelBtn = false;
        this.modalMsg = null;
    }

    @api withDrawLeadOnNextBtnClick(){
        console.log('IsTWMatchLeadFound : ',this.IsTWMatchLeadFound);
        console.log('this.existingLeadNoForTW : ',this.existingLeadNoForTW);
        if(this.IsTWMatchLeadFound == true){
                let withdrawnLeadNo;
                if(this.radioButtonVal == 'Yes')
                    withdrawnLeadNo = this.existingLeadNoForTW;
                else if(this.radioButtonVal == 'No')
                    withdrawnLeadNo = this.leadNumberValue;
                if(withdrawnLeadNo == undefined){
                    this.showToastMessage('', 'Please select either yes on No before moving to the next screen', 'error');
                    return false;
                }else{
                    withdrawnLeadBasedOnDecision({ leadNoToBeWithdrawn: withdrawnLeadNo ,decision: this.radioButtonVal, appId: this.applicantId})
                .then(result => {
                    console.log('Result', result);
                })
                .catch(error => {
                    console.error('Error:', error);
                });
                    return true; 
                }
            
        }
        else{
            return true;
        }
    }
    //This method will get called when User click on Next button
    @api customerSelectionCheckOnNextBtnClick(){
        if(this.validatedCustomerCode === null && this.invalidatedCustomerCode === null && this.dedupeJourneyStatus === null){
            this.modalMsg = 'Since no customer code validated, Journey will proceed as new customer';
            this.showModal = true;
            this.showModalCancelBtn = true;
            return false;
        }
        return true;
    }

    isJSONParseable(result){
        if(!(result && typeof result === "string")){
            return false;
        }
    
        try{
           JSON.parse(result);
           return true;
        } catch(error){
            return false;
        }    
    }

    showToastMessage(title, message, variant){
        if(title){
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

    updateRecordDetails(fields) {
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            console.log('Record updated Sucessfully');
        }).catch(error => {
            console.log('Record update error', error);
        });
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    
}