// Screen created By : 
// Screen Name: 'LWC_LOS_VehicleDedupe'
// Description : Vehicle Dedupe check will be done in this screen.
 
import { LightningElement ,track ,api ,wire} from 'lwc';
import getCurrentOppRecord from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getCurrentOppRecord';
//import doVehicleDedupeCallout from '@salesforce/apex/IntegrationEngine.doVehicleDedupeCallout';
import Vehicle_New from '@salesforce/label/c.Vehicle_New';
import Vehicle_Old from '@salesforce/label/c.Vehicle_Old';
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';
import vehicleDedupe from '@salesforce/apex/LwcLOSLoanApplicationCntrl.vehicleDedupe';
import Vehicle_Old_PlaceHolder from '@salesforce/label/c.Vehicle_Old_Pattern_PlaceHolder';
import Vehicle_New_PlaceHolder from '@salesforce/label/c.Vehicle_New_Pattern_PlaceHolder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import VEHICLE_TYPE from '@salesforce/schema/Opportunity.Vehicle_Type__c';
import VEHICLE_SUB_CATEGORY from '@salesforce/schema/Opportunity.Vehicle_Sub_Category__c';
import STAGE_NAME from '@salesforce/schema/Opportunity.StageName';
import SUB_STAGE_NAME from '@salesforce/schema/Opportunity.Sub_Stage__c';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import PARENT_DEAL_NUMBER from '@salesforce/schema/Opportunity.Parent_Deal_number__c';
import REGISTRATION_NUMBER_FORMAT from '@salesforce/schema/Opportunity.Registration_Number_Format__c';
import CUSTOMER_CODE from '@salesforce/schema/Opportunity.Customer_Code__c';
import VEHICLE_REGISTRATION_NUMBER from '@salesforce/schema/Opportunity.Vehicle_Registration_Number__c';
import NOC_NUMBER from '@salesforce/schema/Opportunity.NOC_Number__c';
import VEHICLE_VERIFIED from '@salesforce/schema/Opportunity.Vehicle_Verified__c';
import Vehicle_Proceed_Flag__c from '@salesforce/schema/Opportunity.Vehicle_Proceed_Flag__c';
import {updateRecord} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Vehicle_Type__c from '@salesforce/schema/Opportunity.Vehicle_Type__c';
import doVehicleDedupeCallout from '@salesforce/apexContinuation/IntegrationEngine.doVehicleDedupeCallout';
import doD2cVehicleDedupeCallout from '@salesforce/apex/D2C_IntegrationEngine.doVehicleDedupeCallout';
import fetchCustomerCode from '@salesforce/apex/Utilities.fetchCustomerCode';
import { loadStyle } from 'lightning/platformResourceLoader';
import vehicleDedupeCss from '@salesforce/resourceUrl/VehicleDedupeCss';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication'; //CISP: 2893

export default class LWC_LOS_VehicleDedupe extends LightningElement {
    @api currentStage;
    @api currentStageName;
    @api lastStage;
    @api recordid;
    @api applicantId;
    @api checkleadaccess;//coming from tabloanApplication
    disableFields=false;
    vehicleType='';
    vehicleSubCategoryType='';
    parentDealNumber='';
    registerationNumberFormatValue='';
    customerCodeValue='';
    vehicleRegistrationNumberValue='';
    vehicleProceedFlag = '';
    nocNumberValue='';
    processedVerified = '';
    productType = '';
    vehicleRegistrationPatternPlaceholder='';
    isCustomerCodeDisabled = false;
    isParentDealNumberDisabled = false;
    isVehicleRegistrationNumberDisabled = false;
    isNOCNumberDisabled = false;
    isVerifyVehicleSubCategoryButtonDisabled = true;
    isRegisterationNumberFormatDisabled = false;
    vehicleDedupeTemplate = false;
    subCategoryComboboxTemplate = false;
    verifyButton=false;
    leadSource = '';//DSA Swapnil

    @track isNocNumberVerified=false;
    @track isNOCNumberDisabled=false;
    @track isSpinnerMoving = true;

    oppObjectRecord;
    VerifyExclamation = false;
    verifyButton = false;
    verifyChecked = false;
    isDisabledSubmit = false;
    vehicleVerified=false;
    nocNumberPopup = false;
    checkForNullValue = true;
    callVehicleDedupe = true;

    vehicleRegistrationPattern = Vehicle_New;
    @track dedupeInputFieldValues = [];
    value = [];
   
    label = {
        Regex_NumberOnly
    }

    //D2C Change
    get registerationNumberFormatDisabled(){
        return this.isRegisterationNumberFormatDisabled || this.leadSource == 'D2C'
    }
    get vehicleRegistrationNumberDisabled(){
        return this.isVehicleRegistrationNumberDisabled || this.leadSource == 'D2C'
    }

    get showSubmitButton(){
        let validStages = ['Loan Initiation','Asset Details','Vehicle Insurance','Vehicle Valuation'];
        return this.vehicleType != 'New' && this.currentOppRecord?.LeadSource == 'D2C' && validStages.includes(this.currentOppRecord.StageName);
    }
    // EO D2C Change
    

    async connectedCallback(){
        await this.init(); 
        console.log('this.checkleadaccess ',this.checkleadaccess);
           /* if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                /*const evt = new ShowToastEvent({
                    title: 'You do not have access for this Loan Application',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                console.log('from tab loan');
                this.disableEverything();
            }*/
        this.isSpinnerMoving = false;
        this.callAccessLoanApplication();//CISP: 2893
    }

    async init() {  
        //Get Record Id Based on Query
        await getCurrentOppRecord({loanApplicationId : this.recordid}).then(response =>{      
            //response = response.replace('Co-borrower','Coborrower');
            let result = JSON.parse(response);    
            this.oppObjectRecord= result.oppRecord;   
            console.log('Inside ConnectedCallBack result : ',result);
            this.currentOppRecordId=result.oppRecord.Id;
            this.currentOppOwnerId = result.oppRecord.OwnerId;
            this.currentOppRecord = result.oppRecord;   
            this.leadSource = result.oppRecord.LeadSource;//DSA Swapnil             
            this.vehicleType = result.oppRecord.Vehicle_Type__c;
            this.productType = result.oppRecord.Product_Type__c=='Two Wheeler' ? 'TW' : result.oppRecord.Product_Type__c=='Passenger Vehicles' ? 'PV' : '';
            this.subCategoryComboboxTemplate = result.oppRecord.Vehicle_Type__c !== 'New' && result.oppRecord.Vehicle_Type__c !== undefined ? true:false;
            this.returnVehicleSubCategory();
            this.vehicleDedupeTemplate = result.oppRecord.Vehicle_Type__c !== 'New' && result.oppRecord.Vehicle_Type__c !== undefined ? true:false;
            //this.vehicleDedupeTemplate = result.oppRecord.Vehicle_Sub_Category__c !== undefined ? true:false;
            this.vehicleSubCategoryType = result.oppRecord.Vehicle_Sub_Category__c;
            this.handleVehicleSubCategoryType();
            
            //CISP-4967
            if(this.currentOppRecord.LeadSource == 'D2C'){
            if (this.vehicleType!=null && !((this.vehicleType == 'Used' || this.vehicleType == 'Refinance') && this.currentOppRecord.Sub_Stage__c == 'Vehicle Dedupe')) {
                this.disableFields=true;
            }
             } 
             else{
                if (this.vehicleType!=null && !((this.vehicleType == 'Used' || this.vehicleType == 'Refinance'))) {
                this.disableFields=true;
                }
             }
            // if (this.vehicleType!=null) {
            //     this.disableFields=true;
            // }
            this.vehicleVerified = result.oppRecord.Vehicle_Verified__c;
            this.processedVerified = result.oppRecord.Vehicle_Proceed_Flag__c; 
            if (this.processedVerified == 'Y') {   
                console.log("need to enter", this.processedVerified);               
                this.verifyButton = true;
                this.verifyButton = true;
                this.VerifyExclamation = false;
                this.disableAllFields();
            }
            if (this.processedVerified == "W") {
                console.log("need to close", this.processedVerified); 
                this.VerifyExclamation = true;
                this.verifyButton = false;
                this.verifyButton = false;
                this.disableAllFields();
            }
            this.parentDealNumber = result.oppRecord.Parent_Deal_number__c  ;
            this.registerationNumberFormatValue = result.oppRecord.Registration_Number_Format__c !== undefined ? result.oppRecord.Registration_Number_Format__c : 'New';
            console.log('applicant list customer code ',result.applicantsList[0].customerCode);

            let filteredList = [];
            filteredList = result.applicantsList.filter(item => item.applicantType === 'Borrower');
            if(filteredList.length > 0){
                const currentApplicant = filteredList[0];
                this.customerCodeValue = currentApplicant.customerCode;
            }
            this.vehicleRegistrationNumberValue = result.oppRecord.Vehicle_Registration_Number__c;
            this.nocNumberValue = result.oppRecord.NOC_Number__c;
            this.vehicleVerified =result.oppRecord.Vehicle_Verified__c;
        }).catch(error => { 
            console.log('getCurrentOppRecord Error:: ',error);
        });
        setTimeout(() => {
        }, 60000);
    }  
//CISp: 2893
    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordid , stage: 'Loan Initiation'}).then(response => {
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


    // Start:  Vehicle dedupe Section by Khushiram.

    //List for holding the value of dependent picklist.
    @track vehicleSubCategory = [{ label: '--None--', value: 'none' }];

    //Options for Vehicle Type Dropdown
    get vehicleTypeOptions() {
        let options = [
            { label: 'Used', value: 'Used' },
            { label: 'Refinance', value: 'Refinance' },
        ];
        if (this.leadSource !== 'DSA' && this.vehicleType =='New') {//CISP-3293
            options = [{ label: 'New', value: 'New' }, ...options];
        }
        return options;
    }

    get vehicleSubCategoryOptions() {
        return this.vehicleSubCategory;

    }
    get disableVehicleTypeField(){
        return this.disableFields || this.currentOppRecord?.LeadSource == 'D2C'
    }
    handleVehicleTypeChange(event){
        this.vehicleVerified=false;
        let vehicleTypeInput = this.template.querySelector('.vehicleCss');
        this.vehicleType = vehicleTypeInput.value;
        vehicleTypeInput.reportValidity();

        this.dispatchEvent(new CustomEvent('verifychecked',{detail: this.verifyChecked}));
        this.dispatchEvent(new CustomEvent('vehicleverified',{detail: this.vehicleVerified}));
        this.dispatchEvent(new CustomEvent('vehiclebutton', {detail: this.verifyButton}));
    }

    //Vehicle Type Value Change Handler
    handleVehicleTypeChange(event) {
        this.vehicleType = event.detail.value;
        if (this.vehicleType !== 'New') {
            fetchCustomerCode({applicantId : this.applicantId})
            .then(result =>{
                console.log('result of customer code fetch', result);
                this.customerCodeValue = result;
            })
            .catch(error =>{
                console.log('error in fetching the customer code', error);
            })
        }

         //save if new is selected
         console.log('Inside vehicle dedupe 1: ', this.vehicleType)
         if (this.vehicleType=='New') {
          
            console.log('Inside vehicle dedupe 2: ', this.vehicleType)
            const oppFields = {};
            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
            oppFields[VEHICLE_TYPE.fieldApiName] = this.vehicleType;
            oppFields[VEHICLE_SUB_CATEGORY.fieldApiName] = null;
            oppFields[PARENT_DEAL_NUMBER.fieldApiName] = null;
            oppFields[REGISTRATION_NUMBER_FORMAT.fieldApiName] = null;
            //oppFields[CUSTOMER_CODE.fieldApiName] = this.customerCodeValue;
            oppFields[VEHICLE_REGISTRATION_NUMBER.fieldApiName] = null;
            oppFields[NOC_NUMBER.fieldApiName] = null;
            //oppFields[VEHICLE_VERIFIED.fieldApiName] = null;
            this.updateRecordDetails(oppFields)
            .then(result => 
                {console.log('Inside vehicle dedupe 3: ',result);
            })
        }

        this.vehicleSubCategory=[{ label: '--None--', value: 'none' }];
        this.returnVehicleSubCategory();
        this.isRegisterationNumberFormatDisabled = false;
        this.vehicleSubCategoryType = event.detail.value=null;
        this.registerationNumberFormatValue=event.target.value=null;
        this.vehicleRegistrationNumberValue=event.target.value=null;
        this.nocNumberValue=event.target.value=null;
        //this.customerCodeValue=event.target.value=null;
        this.parentDealNumber=event.target.value=null;
        this.dispatchEvent(new CustomEvent('vehicleselectedtype',{detail: this.vehicleType}));
    }

    returnVehicleSubCategory(){    
        if (this.vehicleType == 'New') {
            this.subCategoryComboboxTemplate = false;
            this.vehicleDedupeTemplate = false;
        }else if (this.vehicleType == 'Used' && this.currentOppRecord?.LeadSource == 'D2C'){
            this.verifyChecked = false;
            this.subCategoryComboboxTemplate = true;
            this.vehicleDedupeTemplate = false;
            this.vehicleSubCategory = [ { label: 'UOM-OPEN MARKET BUY', value: 'UOM' },
            { label: 'UPD-PRE-OWNED THRU BROKER', value: 'UPD' }];
        }
        else if (this.vehicleType == 'Used') {
            this.verifyChecked = false;
            this.subCategoryComboboxTemplate = true;
            this.vehicleDedupeTemplate = false;
            this.vehicleSubCategory = [ 
                { label: 'UEB-EXISTING VEHICLE SALE THROUGH BROKER', value: 'UEB' },
                { label: 'UIM-INDUS MORE', value: 'UIM' },
                { label: 'UOB-OPEN MARKET BUY WITH BT', value: 'UOB' },
                { label: 'UOM-OPEN MARKET BUY', value: 'UOM' },
                { label: 'UPB-PRE-OWNED WITH BT', value: 'UPB' },
                { label: 'UPD-PRE-OWNED THRU BROKER', value: 'UPD' },
                { label: 'UPO-PRE-OWNED', value: 'UPO' },
                { label: 'URS-REPO SALE', value: 'URS' },
                { label: 'URV-SALE OF EXISTING VEHICLE', value: 'URV' },
            ];    
        }else if(this.vehicleType == 'Refinance' && this.currentOppRecord?.LeadSource == 'D2C'){
            this.verifyChecked = false;
            this.subCategoryComboboxTemplate = true;
            this.vehicleDedupeTemplate = false;
            this.vehicleSubCategory = [
            { label: 'RLY-REFINANCE WITH IBL LIEN', value: 'RLY' },
            { label: 'UPO-PRE-OWNED', value: 'UPO' }
            ]
        }else if (this.vehicleType == 'Refinance') {
            this.verifyChecked = false;
            this.subCategoryComboboxTemplate = true;
            this.vehicleDedupeTemplate = false;
            this.vehicleSubCategory = [
            { label: 'RLY-REFINANCE WITH IBL LIEN', value: 'RLY' },
            { label: 'RLN-REFINANCE WITHOUT IBL LIEN', value: 'RLN' }
            ]
        }
        else {
            return this.vehicleSubCategory;   
        }
    }

    get registeratioNumberFormatOptions(){
        return [
            { label: 'New', value: 'New' },
            { label: 'Old', value: 'old' },
        ];
    }

    //Handler for registration number format value change.
    handleRegisterNumberFormat(event){
        this.verifyButton = false;
        this.VerifyExclamation = false;
        this.registerationNumberFormatValue = event.detail.value;
        this.vehicleRegistrationNumberValue = event.detail.value=null;
        if (this.registerationNumberFormatValue == 'old') {
            this.vehicleRegistrationPattern = Vehicle_Old;
            this.vehicleRegistrationPatternPlaceholder = Vehicle_Old_PlaceHolder;
            console.log('vehicle Registratin paterrn ' ,Vehicle_Old_PlaceHolder);
        }
        else if (this.registerationNumberFormatValue == 'New') {
            this.vehicleRegistrationPattern = Vehicle_New;
            this.vehicleRegistrationPatternPlaceholder =  Vehicle_New_PlaceHolder;
            console.log('vehicle new Registratin paterrn ' ,Vehicle_New_PlaceHolder);
        }
    }

    getRegNumberFormat(){      
        if (this.registerationNumberFormatValue == 'old') {
            this.vehicleRegistrationPattern = Vehicle_Old;
        }
        else if (this.registerationNumberFormatValue == 'New') {
            this.vehicleRegistrationPattern = Vehicle_New;
        }

        return this.vehicleRegistrationPattern;
    }

    //Vehicle SubCategroy Value Change Handler.
    handleVehicleSubCategoryChange(event) {
        let tempFormat = this.registerationNumberFormatValue;
        this.vehicleVerified = false;
        this.vehicleDedupeTemplate = true;
        this.verifyButton=false;
        this.VerifyExclamation = false;
        this.registerationNumberFormatValue = 'New';
        this.vehicleRegistrationPatternPlaceholder =  Vehicle_New_PlaceHolder;
        this.vehicleSubCategoryType = event.target.value;
        this.testdemo = this.vehicleSubCategoryType;
        console.log('total value we pasted ' ,this.vehicleSubCategoryType);
        this.handleVehicleSubCategoryType(); 
        if(this.leadSource == 'D2C'){
            this.registerationNumberFormatValue = tempFormat;
        }
        this.dispatchEvent(new CustomEvent('verifychecked',{detail: this.verifyChecked}));
        this.dispatchEvent(new CustomEvent('vehicleverified',{detail: this.vehicleVerified}));
        this.dispatchEvent(new CustomEvent('vehiclebutton', {detail: this.verifyButton}));
        
    }
    handleVehicleSubCategoryType(){
        this.isRegisterationNumberFormatDisabled = false;

        if (this.vehicleSubCategoryType == 'UOM') {
            this.isCustomerCodeDisabled = false;          
            this.isParentDealNumberDisabled = true;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true; 
            this.nocNumberValue=null;                
        }
        else if (this.vehicleSubCategoryType == 'UOB') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true; 
            this.nocNumberValue=null;             
        }
        else if (this.vehicleSubCategoryType == 'UPD') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true;
            this.nocNumberValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'URS') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true;
            this.nocNumberValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'URV') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true;
            this.nocNumberValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'UEB') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = false;
            this.nocNumberValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'UPB') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = false;
        }
        else if (this.vehicleSubCategoryType == 'UPO') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true;
            this.nocNumberValue=null;  
        }      
        else if (this.vehicleSubCategoryType == 'UIM') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true;
            this.nocNumberValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'RLY') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = true;
            this.nocNumberValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'RLN') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.parentDealNumber=null;
            this.isVehicleRegistrationNumberDisabled = false;
            this.registerationNumberFormatValue= null;
            this.isNOCNumberDisabled = false;
        }
        //Resetting the field values of dependent pickilist value changes.
        this.template.querySelectorAll('[data-id="dedupeInput"]')
        .forEach((input) => {
            if (input.label != 'Customer Code') {
                input.value = '';
            }
        })
    }

    //On Blur Handler for Input field.Also getting the values of input fields to pass them in vehicleDedupe method.
    handleDedupeInputField(event){
        const label = event.target.label;
        if (label == 'Customer Code') {
            //this.customerCodeValue = event.target.value;
        }
        else if (label == 'Parent Deal Number') {
            this.parentDealNumber = event.target.value;
        }
        else if (label == 'Vehicle Registration Number') {
            console.log('vehicle 388 ');
            this.vehicleRegistrationNumberValue = event.target.value;
            let vehicleRegistrationInput = this.template.querySelector('lightning-input[data-id=dedupeeInput]');
            let formdataVehicleNumber = vehicleRegistrationInput.value;
            this.vehicleRegistrationNumberValue = formdataVehicleNumber;
            vehicleRegistrationInput.reportValidity();
            
        }
        else if (label == 'NOC Number') {
            this.nocNumberValue = event.target.value;
        }
    }  
    handleVehicleSubCategory(event){
        let nocNumberInput = this.template.querySelector('.nocInput');
        nocNumberInput.reportValidity();
        let vehicleNumberInput = this.template.querySelector('.vehicleNumber');
        vehicleNumberInput.reportValidity();

        console.log('Product type vehicle - ',this.productType);

        if (nocNumberInput.validity.valid!=true) {
            return;
        }

        // Making this true as and when the button will be clicked.
        this.callVehicleDedupe = true;

        //Checking validation for required value.If validation fails showing toast event sand making callDedupeVehicle false, so that server call doesn't happen.
        this.template.querySelectorAll('[data-id="dedupeInput"]').forEach((input) => {
            if (this.vehicleSubCategoryType == 'UEB' || this.vehicleSubCategoryType == 'UPB') {
                if (input.label != 'NOC Number' && input.disabled == false && input.value.length == 0) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Missing Required Value(s)',
                        message: 'Please Enter Required Field Values '+input.label,
                        variant: 'warning',
                    }));
                    
                    //Stopping server call by make it false.
                    this.callVehicleDedupe = false;
                    this.isSpinnerMoving = false;
                }
            } else{
                if (input.disabled == false && input.value.length == 0) {
                    const evt = new ShowToastEvent({
                        title: 'Missing Required Value(s)',
                        message: 'Please Enter Required Field Values '+input.label,
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    //Stopping server call by make it false.
                    this.callVehicleDedupe = false;
                }
            }
        });

        if (this.callVehicleDedupe == true && this.vehicleRegistrationNumberValue.match(this.getRegNumberFormat())) {
            this.isSpinnerMoving = true;
           
            let NocNumberDetails = {
                'loanApplicationId': this.recordid,
                'customerCode': this.customerCodeValue,
                'oldDealNo': this.parentDealNumber,
                'vehicleRegisterationNumber': this.vehicleRegistrationNumberValue,
                'nocNo': this.nocNumberValue,
                'product': this.productType == 'TW' ? 'H' : 'C',
                'category': this.registerationNumberFormatValue,
                'subCategory': this.vehicleSubCategoryType
            };
            doVehicleDedupeCallout({'vehicleDedupe': JSON.stringify(NocNumberDetails)}).then(result =>{
                const obj = JSON.parse(result);
                console.log('doVehicleDedupeCallout - Result:: ' ,obj);
                console.log("doVehicleDedupeCallout - Parsed Result:: "+result);

                if (obj.response.content[0].Proceed_Flag == 'Y') {
                    console.log('vehicle part done sub category ',this.vehicleSubCategoryType);
                    this.verifyButton = true;
                    this.verifyChecked = true;
                    this.vehicleVerified =true;
                    this.verifyButton=true;
                    this.VerifyExclamation=false;
                    this.isVehicleRegistrationNumberDisabled = true; 
                    this.disableFields = true;
                    this.dispatchEvent(new ShowToastEvent({message: "Vehicle dedupe details Verified.",variant: 'Success',mode: 'sticky',}));
                    this.isSpinnerMoving = false;

                    if (this.vehicleVerified==true ) {
                        console.log('Inside Vehicle Component data saved. ',this.vehicleSubCategoryType,'', this.recordid,'',this.nocNumberValue);
                        
                        const oppFields = {};
                        oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                        oppFields[VEHICLE_TYPE.fieldApiName] = this.vehicleType;
                        oppFields[VEHICLE_SUB_CATEGORY.fieldApiName] = this.vehicleSubCategoryType;
                        oppFields[PARENT_DEAL_NUMBER.fieldApiName] = this.parentDealNumber;
                        oppFields[REGISTRATION_NUMBER_FORMAT.fieldApiName] = this.registerationNumberFormatValue;
                        oppFields[Vehicle_Proceed_Flag__c.fieldApiName] = obj.response.content[0].Proceed_Flag;
                        //oppFields[CUSTOMER_CODE.fieldApiName] = this.customerCodeValue;
                        oppFields[VEHICLE_REGISTRATION_NUMBER.fieldApiName] = this.vehicleRegistrationNumberValue;
                        oppFields[NOC_NUMBER.fieldApiName] = this.nocNumberValue;
                        oppFields[VEHICLE_VERIFIED.fieldApiName] = this.vehicleVerified;
                        
                        this.updateRecordDetails(oppFields).then(result => {
                            console.log(':',result);
                            if(this.currentOppRecord?.LeadSource == 'D2C'){
                                doD2cVehicleDedupeCallout({loanId : this.recordid, status : 'Journey Continues'})
                            }
                            this.verifyCheckedHandler();
                        }).catch(error=>{
                            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                            this.isSpinnerMoving = false;
                        });
                    }
                } else if (obj.response.content[0].Proceed_Flag == 'N') {
                    if(this.currentOppRecord?.LeadSource == 'D2C'){
                        doD2cVehicleDedupeCallout({loanId : this.recordid, status : 'Journey Stopped'})
                    }
                    console.log('getting N input ',obj.response.content[0].Description);
                    const evt = new ShowToastEvent({title: 'Error',message: obj.response.content[0].Description,variant: 'error',mode: 'sticky', });
                    this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                    this.vehicleVerified =false;
                } else if (obj.response.content[0].Proceed_Flag == 'W') {
                    console.log('getting N input ',obj.response.content[0].Description);
                    this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: obj.response.content[0].Description,variant: 'warning',mode: 'sticky',}));
                    this.isSpinnerMoving = false;
                    this.verifyChecked = true;
                    this.vehicleVerified =true;
                    this.VerifyExclamation=true;
                    this.verifyButton=false;
                    this.isVehicleRegistrationNumberDisabled = true;
                    this.disableFields = true;

                    if (this.vehicleVerified==true) {
                        console.log('Inside Vehicle Component data saved. ',this.verifyChecked,'', this.recordid,'',this.nocNumberValue);
                        const oppFields = {};
                        oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                        oppFields[VEHICLE_TYPE.fieldApiName] = this.vehicleType;
                        oppFields[VEHICLE_SUB_CATEGORY.fieldApiName] = this.vehicleSubCategoryType;
                        oppFields[PARENT_DEAL_NUMBER.fieldApiName] = this.parentDealNumber;
                        oppFields[Vehicle_Proceed_Flag__c.fieldApiName] = obj.response.content[0].Proceed_Flag;
                        oppFields[REGISTRATION_NUMBER_FORMAT.fieldApiName] = this.registerationNumberFormatValue;
                        //oppFields[CUSTOMER_CODE.fieldApiName] = this.customerCodeValue;
                        oppFields[VEHICLE_REGISTRATION_NUMBER.fieldApiName] = this.vehicleRegistrationNumberValue;
                        oppFields[NOC_NUMBER.fieldApiName] = this.nocNumberValue;
                        oppFields[VEHICLE_VERIFIED.fieldApiName] = this.vehicleVerified;
                        this.updateRecordDetails(oppFields)
                        .then(result => { 
                            console.log(':',result);
                            if(this.currentOppRecord?.LeadSource == 'D2C'){
                                doD2cVehicleDedupeCallout({loanId : this.recordid, status : 'Journey Continues'})
                            }
                            this.verifyCheckedHandler();
                        }).catch(error=>{
                            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                            this.isSpinnerMoving = false;
                            this.isSpinnerMoving = false;
                        });
                    }
                } else {
                    this.vehicleVerified =false;
                    const evt = new ShowToastEvent({title: 'Error',message: 'Vehicle Dedupe is unsuccessfull.Please enter your details again.',variant: 'error',mode: 'sticky',});this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                }
            }).catch(error => {
                console.log(' doVehicleDedupeCallout error:- ' + error.body.message);
                this.isSpinnerMoving = false;
                const evt = new ShowToastEvent({title: 'Error',message: error.body.message, variant: 'error',});this.dispatchEvent(evt);       
            });
        }else if (this.callVehicleDedupe == true && !this.vehicleRegistrationNumberValue.match(this.getRegNumberFormat()) ) {
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Pattern not matched',variant: 'error',}));
            this.verifyChecked = false;
            this.isSpinnerMoving = false;
        }
    }  
    // End of handleVehicleSubCategory handler.

    verifyCheckedHandler(){
        this.dispatchEvent(new CustomEvent('verifychecked',{detail: this.verifyChecked}));
        this.dispatchEvent(new CustomEvent('vehicleverified',{detail: this.vehicleVerified}));
        this.dispatchEvent(new CustomEvent('vehiclebutton', {detail: this.verifyButton}));

        //Disbaling the input fields if the dedupe is successfull.
        this.isCustomerCodeDisabled = true;
        this.isParentDealNumberDisabled = true;
        this.isVehicleRegistrationNumberDisabled = true;
        this.isRegisterationNumberFormatDisabled = true;
                
        //This will show the popup if the value of NOC number is not entered in case of UEB,UPB subcategory.
        if ((this.vehicleSubCategoryType == 'UEB' || this.vehicleSubCategoryType == 'UPB') &&  (this.nocNumberValue == null || this.nocNumberValue=='')) {
            this.nocNumberPopup = true;
        }
    }

    //Handler for Yes button of NOC popup.
    populateNocNumberHandler(event){
        this.isVehicleRegistrationNumberDisabled = true;
        console.log('isVehicleRegistrationNumberDisabled ', this.isVehicleRegistrationNumberDisabled);
        this.isRegisterationNumberFormatDisabled = true;    
        this.isNocNumberVerified=true;
        this.isNOCNumberDisabled = true;
        this.nocNumberValue = this.template.querySelector('[data-id="nocNumber"]').value;
        
        const oppFields = {};
        oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        oppFields[NOC_NUMBER.fieldApiName] = this.nocNumberValue;
        this.updateRecordDetails(oppFields);
        
        this.verifyButton = true;
        this.nocNumberPopup = false;
        this.isCustomerCodeDisabled = true;    
    }

    // Handler for NO button of NOC Popup.
    closePopupHandler(event){
        if (this.vehicleSubCategoryType == 'UEB') {
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.isVehicleRegistrationNumberDisabled = false;
            this.isNOCNumberDisabled = false;
            this.isRegisterationNumberFormatDisabled = false; 
        }
        if (this.vehicleSubCategoryType == 'UPB') { 
            this.isCustomerCodeDisabled = false;   
            this.isParentDealNumberDisabled = true;
            this.isVehicleRegistrationNumberDisabled = false;
            this.isNOCNumberDisabled = false;
            this.isRegisterationNumberFormatDisabled = false;
        }
        this.vehicleVerified = false;
        this.processedVerified = '';
        const oppFields = {};
        oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        oppFields[VEHICLE_VERIFIED.fieldApiName] = this.vehicleVerified;
        oppFields[Vehicle_Proceed_Flag__c.fieldApiName] = this.processedVerified;
        this.updateRecordDetails(oppFields).then(result => {
            console.log('popup close up:',result );
        })
        this.isNocNumberVerified=false;
        this.isNOCNumberDisabled = false;
        this.nocNumberPopup = false;
        this.verifyButton = false;
        this.VerifyExclamation = false;
        this.verifyChecked = false;
        this.disableFields = false;
        this.dispatchEvent(new CustomEvent('verifychecked',{detail: this.verifyChecked}));
        this.dispatchEvent(new CustomEvent('vehicleverified',{detail: this.vehicleVerified}));
        this.dispatchEvent(new CustomEvent('vehiclebutton', {detail: this.verifyButton}));
        console.log('popup close up:',this.verifyButton );
        this.dispatchEvent(new ShowToastEvent({
            title: 'Warning',
            message: 'Please confirm the NOC number or change the parent deal number/ vehicle registration number to fetch the correct NOC number.',
            variant: 'warning',
        }));
        
    }
    
    async updateRecordDetails(fields){
        console.log('Updating record ');
        const recordInput = { fields };
        console.log('Inside update in vehicle : ',recordInput);
        await updateRecord(recordInput)
        .then(()=> {
            console.log('record update success',JSON.stringify(fields));
        })
        .catch(error => {
            console.log('record update error',error);
        });
    }

    @api vehicleTypeSelected(){
        let vehicleTypeInput = this.template.querySelector('.vehicleCss');
        vehicleTypeInput.reportValidity();
        console.log('check vehicle verify or not', vehicleTypeInput.value );
        if (vehicleTypeInput.value == undefined) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Select Vehicle type to procced.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return false;
        }
        return true;
    }

    disableAllFields(){
        this.disableFields=true;
        this.isParentDealNumberDisabled=true;
        this.isRegisterationNumberFormatDisabled = true;
        this.isCustomerCodeDisabled = true;
        this.isVehicleRegistrationNumberDisabled = true;
        this.isNOCNumberDisabled = true;
        this.isDisabledSubmit = true; 
        if(this.currentOppRecord.LeadSource == 'D2C' && this.currentOppRecord.Sub_Stage__c == 'Vehicle Dedupe' && this.currentOppRecord.StageName == 'Loan Initiation'){
            this.isDisabledSubmit = false;
        }
        
    }

    @api  vehicleRegisterationNumber(){
        let vehicleNumberInput = this.template.querySelector('.vehicleNumber');
        vehicleNumberInput.reportValidity();
        if (vehicleNumberInput.value == null || vehicleNumberInput.value == '' || !this.vehicleRegistrationNumberValue.match(this.getRegNumberFormat())) {
            console.log('Vehicle number is correct or not ');
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Vehicle Registration number is not valid. Please enter correct details.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return false;
        }
        return true;   
    }

    renderedCallback(){
        loadStyle(this,vehicleDedupeCss);
        if ((this.currentStage === 'Credit Processing') || ((this.currentStage != 'Loan Initiation' && this.lastStage != 'Loan Initiation'))) {
            this.disableEverything();
        }
        if ( this.verifyButton && (this.vehicleSubCategoryType == 'UPB' || this.vehicleSubCategoryType == 'UEB')) {
            this.isRegisterationNumberFormatDisabled = true;
            this.isVehicleRegistrationNumberDisabled = true;
        }else if (this.verifyButton) {
            this.isRegisterationNumberFormatDisabled = true;
            this.isVehicleRegistrationNumberDisabled = true;
        }
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    handleSubmit(){
        if(this.vehicleVerified){
            const oppFields = {};
            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
            oppFields[STAGE_NAME.fieldApiName] = 'Asset Details';
            oppFields[LAST_STAGE_NAME.fieldApiName] = 'Asset Details';
            oppFields[SUB_STAGE_NAME.fieldApiName] = 'User Details';
            this.updateRecordDetails(oppFields)
            .then(result => { 
                this.isDisabledSubmit = true;
                this.dispatchEvent(new CustomEvent('submitnavigation', { detail: 'Asset Details' }));
                
            })
            
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Vehicle is not verified. Please enter correct details.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }

    


}