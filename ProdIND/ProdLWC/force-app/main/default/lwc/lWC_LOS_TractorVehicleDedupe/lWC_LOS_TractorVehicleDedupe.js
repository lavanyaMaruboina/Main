import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';

import Vehicle_New from '@salesforce/label/c.Vehicle_New';
import Vehicle_Old from '@salesforce/label/c.Vehicle_Old';
import Vehicle_Old_PlaceHolder from '@salesforce/label/c.Vehicle_Old_Pattern_PlaceHolder';
import Vehicle_New_PlaceHolder from '@salesforce/label/c.Vehicle_New_Pattern_PlaceHolder';

import { loadStyle } from 'lightning/platformResourceLoader';
import vehicleDedupeCss from '@salesforce/resourceUrl/VehicleDedupeCss';
import {updateRecord} from 'lightning/uiRecordApi';
import OPP_ID from '@salesforce/schema/Opportunity.Id';
import PARENT_DEAL_NUMBER from '@salesforce/schema/Opportunity.Parent_Deal_number__c';
import OPP_ID_FIELD from '@salesforce/schema/Vehicle_Detail__c.Loan_Application__c';
import STAGE_NAME from '@salesforce/schema/Opportunity.StageName';
import SUB_STAGE_NAME from '@salesforce/schema/Opportunity.Sub_Stage__c';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';

import getVehicleDetailsRecord from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getVehicleDetailsRecord';
import getApplicantStageDetails from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getApplicantStageDetails';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import updateVehicleDetails from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updateVehicleDetails';
import deleteVehicleDetail from '@salesforce/apex/LwcLOSLoanApplicationCntrl.deleteVehicleDetail';
import fetchCustomerCode from '@salesforce/apex/Utilities.fetchCustomerCode';
import doVehicleDedupeCallout from '@salesforce/apexContinuation/IntegrationEngine.doVehicleDedupeCallout';
import doDealEligibleRefinanceCallout from '@salesforce/apexContinuation/IntegrationEngine.doDealEligibleRefinanceCallout';
import doTractorVehicleDedupeCallout from '@salesforce/apexContinuation/IntegrationEngine.doTractorVehicleDedupeCallout';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import FORM_FACTOR from '@salesforce/client/formFactor';
import Loan_amount from '@salesforce/schema/Opportunity.Loan_amount__c';

export default class LWC_LOS_TractorVehicleDedupe extends LightningElement {
    @api recordid ;
    @api currentStage;
    @api lastStage;
    @api applicantId;
    @api checkleadaccess; 
    @api currenttab;//SFTRAC-458

    @track vehicleDetails = [];
    oppleadSource = '';
    oppStageName = '';
    oppSubStage ='';
    oppLastStageName ='';
    oppProductType ='';

    processedVerified = '';
    vehicleRegistrationPatternPlaceholder='';

    //disableFields = false;
    //isCustomerCodeDisabled = false;
    //isParentDealNumberDisabled = false;
    isVehicleRegistrationNumberDisabled = false;
    //isNOCNumberDisabled = false;
    isVerifyVehicleSubCategoryButtonDisabled = true;
    isRegisterationNumberFormatDisabled = false;
    //vehicleDedupeTemplate = false;
    //subCategoryComboboxTemplate = false;
    verifyButton=false;
    VerifyExclamation = false;
    verifyChecked = false;
    isDisabledSubmit = false;
    vehicleVerified=false;
    nocNumberPopup = false;
    checkForNullValue = true;
    callVehicleDedupe = true;
    disableVehicleType = false;

    currentSUBTYPEvalue = '';
    //List for holding the value of dependent picklist.
    @track vehicleSubCategory = [{ label: '--None--', value: 'none' }];
    @track vehicleSubType = [{ label: '--None--', value: 'none' }];
    label = {
        Regex_NumberOnly
    }

    get isNotBenificiary() {//SFTRAC-458
        return this.currenttab != 'Beneficiary';
    }
    @track isNocNumberVerified=false;
    //@track isNOCNumberDisabled=false;
    @track isSpinnerMoving = true;
    oppvehicleType;
    vehicleRegistrationPattern = Vehicle_New;
    @track dealNumberValue;
    isRefinance = false;
    @api isTopUpLoan = false;//SFTRAC-172
    isUsedORRefinance = false;
    isUsed = false;
    disableDealNobtn = false;

    //@track scrollableClass = 'slds-scrollable_x';

    get isDesktop(){
       // console.log('FORM_FACTOR '+FORM_FACTOR);
        if(FORM_FACTOR == 'Large'){
           // this.scrollableClass = '';
            return true;
        }
        return false; 
    }
      get className(){
        return FORM_FACTOR!='Large' ? 'slds-scrollable_x': '';
    }

    async connectedCallback() {
        console.log('ConnectedCallBack');
        
        this.vehicleDetails = [ {
            'name' : null,
            'vehicleType' : null,
            'vehicleSubCategoryType' : null,
            'vehicleSubType' : null,
            'vehicleDelivered' : null,
            'registerationNumberFormatValue' : null,
            'vehicleRegistrationNumberValue' : null,
            'isvehicleNoFormatRequired' : null,
            'isvehicleNoRequired' : null,
            'isvehicleSubCategoryTypeRequired' : null,
            'engineNoValue': null,
            'chassisNoValue':null,
            'vehicleProceedFlag':null,
            'vehicleVerified':false,
            'verifyChecked':false,
            'oppRecId':this.recordid,
            'vehicleRegistrationPattern':null,
            'vehicleRegistrationPatternPlaceholder':null,
            'vehicleDetailId': null,
            'oppvehicleType': null,
            'serialNoValue': null,
            'isEngineNoRequired' : false,
            'isChassisNoRequired' : false,
            'isSerialNoRequired' : false,
            'isSaved':false,
            'disableSubCategoryField':false,
            'disableSubTypeField':false,
            'registerationNumberFormatDisabled':false,
            'vehicleRegistrationNumberDisabled':false,
            'disableDeliveredField':false,
            'isEngineNumberDisabled':false,
            'isChassisNumberDisabled':false,
            'isSerialNumberDisabled':false,
            'isVerifydisableFields':false,
            'parentDealNumber' : null,
            'isParentDealNumberDisabled' : false,
            'customerCodeValue' : null,
            'isCustomerCodeDisabled' : false,
            'nocNumberValue' : null,
            'isNOCNumberDisabled' : false,
            'pvtwAPIFlag' : false,
            'firstAPIfields' : false,   
            'nocNumberValueReq' : false,    //SFTRAC-1579
        } ];

        await this.init(); 
        setTimeout(() => {
            this.isSpinnerMoving = false;
        }, 10000);
        console.log('this.checkleadaccess ',this.checkleadaccess);
        //SFTRAC-1373 Starts
        const allVerified = this.vehicleDetails.every(item => item.vehicleVerified === true); //SFTRAC-1373
        if(allVerified){console.log("++++++Connected All items are verified.");
            this.isDisableAddRow = false;
        }else{ console.log("++++++Connected All items are not verified.");
            this.isDisableAddRow = true;
        }//SFTRAC-1373 Ends
        this.callAccessLoanApplication();
        await getApplicantStageDetails ({applicantId : this.applicantId}).then( result => {
            console.log('result---'+result);
            if(result && (result?.Journey_Stage__c != 'Vehicle Dedupe') || result?.Opportunity__r?.StageName != 'Loan Initiation' || result?.Opportunity__r?.LastStageName__c != 'Loan Initiation'){
                this.isDisableDelete = true;
                this.isDisableAddRow = true;
            }
        }).catch(error => { 
            console.log('getApplicantStageDetails Error:: ',error);
        });
    }
    loanApplicationWrapper;
    isL2Journey = false; // checks and set to true for StageName =='Credit Processing'  && Sub_Stage__c =='View Application Details' && View_Application_Sub_Stages__c
    isFullL2Journey = false; // checks and set to true for all StageName =='Credit Processing' || 'Post Sanction' ||'Pre Disbursement'  || 'Payment Request'
    isDisableDelete = false;
    isDisableAddRow = false;
    oneCustomerCodeValue;
    topUpUsedLead = false;//SFTRAC-172
    disableDealInput = false //SFTRAC-1436
    async init() {  
        //Get Record Id Based on Query
        await getVehicleDetailsRecord({loanApplicationId : this.recordid}).then(response =>{      
  
            this.loanApplicationWrapper = response;
            console.log('++++loanApplicationWrapper ',this.loanApplicationWrapper);
            const vehicledetailsList = this.loanApplicationWrapper.vehicledetailsList; 

            const currentOppRecord = this.loanApplicationWrapper.oppRecord; 
            const borrowerApplicantRec = this.loanApplicationWrapper.applicantBorrowerRecord; 
            console.log('++++currentOppRecord ',currentOppRecord);
            if(currentOppRecord.StageName =='Credit Processing' && currentOppRecord.Sub_Stage__c =='View Application Details' && currentOppRecord.View_Application_Sub_Stages__c
            =='Lead/KYC Details'){
                this.isL2Journey = true;
            }

            if(currentOppRecord.StageName =='Credit Processing' || currentOppRecord.StageName =='Post Sanction' || currentOppRecord.StageName =='Pre Disbursement'  || currentOppRecord.StageName =='Payment Request' || currentOppRecord.StageName =='Disbursement Request Preparation'){
                this.isFullL2Journey = true;
            }

            if(this.isFullL2Journey == true){
                this.isDisableDelete = true;
                this.isDisableAddRow = true;
            }
            this.oppvehicleType = currentOppRecord.Vehicle_Type__c;
            this.isTopUpLoan = currentOppRecord.isTopUpLoan__c;//SFTRAC-172
            this.isRefinance = this.oppvehicleType === 'Refinance';
            this.topUpUsedLead = this.oppvehicleType === 'Used' && this.isTopUpLoan == true;//SFTRAC-172
            if(this.topUpUsedLead){this.isRefinance = true;}//SFTRAC-172
            this.isUsedORRefinance = this.oppvehicleType === 'Refinance' || this.oppvehicleType === 'Used';
            this.isUsed = this.oppvehicleType === 'Used';
            if(this.isRefinance == true && this.isDisableAddRow == false){
                this.isDisableAddRow = true;
            }
            console.log('borrowerApplicantRec APP', borrowerApplicantRec);
            console.log('borrowerApplicantRec APP2', borrowerApplicantRec.Customer_Code__c);
            if(borrowerApplicantRec){
                this.oneCustomerCodeValue = borrowerApplicantRec.Customer_Code__c;
                console.log('IN APP', this.oneCustomerCodeValue);
            }

            if(vehicledetailsList && vehicledetailsList.length >0){
                // Create an empty array to store the mapped records
                const mappedVehicleDetails = [];

                // Loop through vehicleDetailsList and map each record
                vehicledetailsList.forEach(item => {
                    const mappedRecord = {
                        'name': item.name,
                        'vehicleType': this.oppvehicleType, 
                        'vehicleSubCategoryType': item.vehicleSubCategoryType,
                        'vehicleSubType' : item.vehicleSubType,  // Aakash create a new wrapper variable in Apex
                        'vehicleDelivered': item.vehicleDelivered,   // Aakash change apex varibale name and mapping 
                        'registerationNumberFormatValue': item.registerationNumberFormatValue, 
                        'vehicleRegistrationNumberValue': item.vehicleRegistrationNumberValue, 
                        'isvehicleNoFormatRequired' : false,
                        'isvehicleNoRequired' : false,
                        'isvehicleSubCategoryTypeRequired' : false,
                        'engineNoValue': item.engineNoValue,  // Aakash change apex varibale name and mapping 
                        'chassisNoValue': item.chassisNoValue,    // Aakash change apex varibale name and mapping 
                        'vehicleProceedFlag':item.vehicleProceedFlag,
                        'vehicleVerified':item.vehicleVerified,
                        'verifyChecked':item.vehicleVerified,
                        'oppRecId':this.recordid,
                        'vehicleDetailId': item.vehicleDetailId,
                        //'oppvehicleType': this.oppvehicleType,
                        'serialNoValue' : item.serialNoValue,     // Aakash Add field in the APex class
                        'isEngineNoRequired' : false,
                        'isChassisNoRequired' : false,
                        'isSerialNoRequired' : false,
                        'isSaved':true,
                        'disableSubCategoryField':true,
                        'disableSubTypeField':item.vehicleVerified == false ? false : true,
                        'registerationNumberFormatDisabled':item.vehicleVerified == false ? false : true,
                        'vehicleRegistrationNumberDisabled':item.vehicleVerified == false ? false : true,
                        'disableDeliveredField':item.vehicleVerified == false ? false : true,
                        'isEngineNumberDisabled':item.vehicleVerified == false ? false : true,
                        'isChassisNumberDisabled':item.vehicleVerified == false ? false : true,
                        'isSerialNumberDisabled':item.vehicleVerified == false ? false : true,
                        //'isVerifydisableFields':true,
                        //'isVerifydisableFields' : (this.isFullL2Journey == true && item.vehicleVerified == false) ? false : true,
                        'isVerifydisableFields' : (this.isFullL2Journey == true && item.vehicleVerified == false) ? false : item.vehicleVerified == false ? false : true,
                        'parentDealNumber' : item.parentDealNumber,
                        'isParentDealNumberDisabled' : true,
                        'customerCodeValue' : this.oneCustomerCodeValue,
                        'isCustomerCodeDisabled' : true,
                        'nocNumberValue' :  item.nocNumberValue,
                        'isNOCNumberDisabled' : true,
                        'pvtwAPIFlag' : item.pvtwAPIFlag,
                        'firstAPIfields' : false,   
                        'nocNumberValueReq' : false,    //SFTRAC-1579
                    };
 
                    // Push the mapped record to the array
                    mappedVehicleDetails.push(mappedRecord);
                });

                // Assign the mapped array to this.vehicleDetails for display in the LWC datatable
                this.vehicleDetails = mappedVehicleDetails;      
            }
            //SFTRAC-1436 Starts
            if(this.isTopUpLoan && this.vehicleDetails[0].parentDealNumber != null){
                this.dealNumberValue = this.vehicleDetails[0].parentDealNumber != null ? this.vehicleDetails[0].parentDealNumber : '';
                this.disableDealInput = true;
                this.disableDealNobtn = true;
            }//SFTRAC-1436 Ends
            this.verifyCheckedHandler();
            //Aakash check the values disableFields later
            if(this.oppvehicleType !=null){
                this.disableVehicleType = true;
                this.returnVehicleSubCategory(this.oppvehicleType);
            }

        }).catch(error => { 
            console.log('getCurrentOppRecord Error:: ',error);
        });
        setTimeout(() => {
        }, 60000);

        if(!this.isDesktop && this.vehicleDetails){
                    
            var vehicleSubtype = this.template.querySelectorAll('[data-value="vehicleSubtype"]');
            vehicleSubtype.forEach((each, index) =>{
                    each.value= this.vehicleDetails[index].vehicleSubType;
            }) 
            var vehicleSubCat = this.template.querySelectorAll('[data-value="vehicleSubCategory"]');
            vehicleSubCat.forEach((each, index) =>{
                    each.value= this.vehicleDetails[index].vehicleSubCategoryType;
            }) 
            var regNumFormat = this.template.querySelectorAll('[data-value="regNumFormat"]');
            regNumFormat.forEach((each, index) =>{
                    each.value= this.vehicleDetails[index].registerationNumberFormatValue;
            }) 
            var vehicleDelivered = this.template.querySelectorAll('[data-value="vehicleDelivered"]');
            vehicleDelivered.forEach((each, index) =>{
                    each.value= this.vehicleDetails[index].vehicleDelivered;
            }) 
        }
    }

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

    addRow() {
        const allVerified = this.vehicleDetails.every(item => item.vehicleVerified === true); //SFTRAC-1373
        if(allVerified){
            this.isDisableAddRow = false;
        }else{
            this.isDisableAddRow = true;
        }
        if(this.vehicleDetails && this.vehicleDetails.length < 5){
            console.log('addRow IF ',this.vehicleDetails.length);
            let newEntry = {
                'name' : null,
                'vehicleType' : this.oppvehicleType,
                'vehicleSubCategoryType' : null,
                'vehicleSubType' : null,
                'vehicleDelivered' : null,
                'registerationNumberFormatValue' : null,
                //'registerationNumberFormatValue' : this.oppvehicleType !== 'New' ? null : 'New',
                'vehicleRegistrationNumberValue' : null,
                'isvehicleNoFormatRequired' : null,
                'isvehicleNoRequired' : null,
                'isvehicleSubCategoryTypeRequired' : null,
                'engineNoValue': null,
                'chassisNoValue':null,
                'vehicleProceedFlag':null,
                'vehicleVerified':false,
                'verifyChecked':false,
                'oppRecId':this.recordid,
                'vehicleRegistrationPattern':null,
                'vehicleRegistrationPatternPlaceholder':null,
                'vehicleDetailId': null,
                //'oppvehicleType': this.oppvehicleType,
                'serialNoValue': null,
                'isEngineNoRequired' : false,
                'isChassisNoRequired' : false,
                'isSerialNoRequired' : false,
                'isSaved':false,
                'disableSubCategoryField':false,
                'disableSubTypeField':false,
                'registerationNumberFormatDisabled':false,
                //'registerationNumberFormatDisabled' : this.oppvehicleType !== 'New' ? false : true,
                'vehicleRegistrationNumberDisabled':false,
                'disableDeliveredField':false,
                'isEngineNumberDisabled':false,
                'isChassisNumberDisabled':false,
                'isSerialNumberDisabled':false,
                'isVerifydisableFields':false,
                'parentDealNumber' : null,
                'isParentDealNumberDisabled' : false,
                'customerCodeValue' : this.oneCustomerCodeValue,
                'isCustomerCodeDisabled' : true,
                'nocNumberValue' : null,
                'isNOCNumberDisabled' : false,
                'pvtwAPIFlag' : false,
                'firstAPIfields' : false,
                'nocNumberValueReq' : false,    //SFTRAC-1579
            };
    
            if ( this.vehicleDetails ) {
                this.vehicleDetails = [...this.vehicleDetails, newEntry ];
                console.log('addRow this.vehicleDetail ',this.vehicleDetails);
            } else {
                this.vehicleDetails = [ newEntry ];
                console.log('addRow this.vehicleDetail 2 ',this.vehicleDetails);
            }
            this.isDisableAddRow = true;//SFTRAC-1373
            this.verifyCheckedHandler();
            //this.returnVehicleSubCategory(this.oppvehicleType);
        }else{
            console.log('addRow ELSE ',this.vehicleDetails.length);
            this.showErrorToast('Maximum limit of 5 rows reached.');
        }
        
    }

    deleteRow( event ) {
        console.log('strIndex deleteRow ',event.target.dataset.recordId);
        const strIndex = event.target.dataset.recordId;
        let currentRec = this.vehicleDetails[strIndex];
        //this.vehicleDetails = this.vehicleDetails.filter((item, index) => index !== parseInt(strIndex));
        console.log('currentRec deleteRow currentRec',currentRec);
        if(!currentRec.vehicleDetailId){
            console.log('deleteRow Inside If');
            this.vehicleDetails = this.vehicleDetails.filter((item, index) => index !== parseInt(strIndex));
            if(this.isRefinance == true && this.isDisableAddRow == true){
                //this.isDisableAddRow = false;
                this.addRow();
            }
            if(this.isRefinance == false){this.isDisableAddRow = false}//SFTRAC-1373
        }else{
            console.log('deleteRow Inside else');
            this.isSpinnerMoving = true;
            // If it's an existing record, call the Apex method to delete it
            deleteVehicleDetail({ vehicleDetailId: currentRec.vehicleDetailId })
                .then(result => {
                    // Handle success and remove the deleted record from the UI
                    console.log('deleteRow result '+result);
                    if(result =='Successfully deleted'){
                        this.dispatchEvent(new ShowToastEvent({title: 'Success',message: 'Verified Vehicle Detail deleted!',variant: 'Success',mode: 'dismissible'}));
                        this.vehicleDetails = this.vehicleDetails.filter((item, index) => index !== parseInt(strIndex));
                        if((this.isRefinance == true || this.isTopUpLoan) && this.isDisableAddRow == true && this.vehicleDetails.length == 0){
                            //this.isDisableAddRow = false;
                            this.addRow();
                        }
                        if((this.vehicleDetails.length == 0) && this.isRefinance == false){this.isDisableAddRow = false}//SFTRAC-1373
                        if(this.dealNumberValue != null){this.dealNumberValue = ''; this.disableDealInput = false; this.disableDealNobtn = false;} //SFTRAC-1436
                        this.isSpinnerMoving = false;
                    }else{
                        console.error('Error deleting VehicleDetail please try again: ' + error);
                    }
                })
                .catch(error => {
                    // Handle errors
                    console.error('Error deleting VehicleDetail please try again: ' + error);
                });
        }
        this.verifyCheckedHandler(); 
    }

  //Aakash no need now Options for Vehicle Type Dropdown
    get vehicleDeliveredType() {
        let options = this.oppvehicleType == 'New' ? [ { label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' } ] : [{label: 'Yes', value: 'Yes'}] ;
        return options;
    }
    
    //Options for Vehicle SubCategory Dropdown
    get vehicleSubCategoryOptions() {
        return this.vehicleSubCategory;
    }

    //Options for Vehicle SubType Dropdown
    get vehicleSubTypeOptions() {
        let vehicleSubTypeop = [];
        if(this.oppvehicleType == 'Refinance'){
            vehicleSubTypeop = [
                { label: 'Tractor', value: 'Tractor' },
                { label: 'Harvester', value: 'Harvester' },
            ];
        } else {
            vehicleSubTypeop = [
            { label: 'Tractor', value: 'Tractor' },
            { label: 'Harvester', value: 'Harvester' },
            { label: 'Implement', value: 'Implement' },
        ];
    }
        return vehicleSubTypeop;
    }

    get disableVehicleTypeField(){
        //return this.disableFields || this.oppleadSource == 'D2C'
        return this.disableFields;
    }

    get registeratioNumberFormatOptions(){
        let regFormat = this.oppvehicleType !== 'New' ? [{ label: 'New', value: 'New' },{ label: 'Old', value: 'old' }] : [{label: 'New', value: 'New'}] ;
        return regFormat;
        /*return [
            { label: 'New', value: 'New' },
            { label: 'Old', value: 'old' },
        ];*/
    }

    //check and update this as well on the basis of Index
    getRegNumberFormat(currentRec){      
        if (currentRec.registerationNumberFormatValue == 'old') {
            currentRec.vehicleRegistrationPattern = Vehicle_Old;
        }
        else if (currentRec.registerationNumberFormatValue == 'New') {
            currentRec.vehicleRegistrationPattern = Vehicle_New;
        }

        return currentRec.vehicleRegistrationPattern;
    }

    get registerationNumberFormatDisabled(){
        //return this.isRegisterationNumberFormatDisabled || this.oppleadSource == 'D2C'
        return this.isRegisterationNumberFormatDisabled;
    }
    get vehicleRegistrationNumberDisabled(){
        //return this.isVehicleRegistrationNumberDisabled || this.oppleadSource == 'D2C'
        return this.isVehicleRegistrationNumberDisabled
    }

    handleChange( event ) {
        console.log('handleChange');
        let recs =  this.vehicleDetails;
        let value = event.target.value;
        let label = (event.target.label || this.isDesktop) ? event.target.label : event.target.name;
        let name;
        
        let strIndex = event.target.dataset.recordId;
        console.log( 'Index is ' + strIndex );
        console.log( label + ' – ' + value );
        switch( label ) {

            /*case 'Vehicle Type':
                name = 'vehicleType';
                this.handleVehicleTypeChange(event,strIndex);
                break;*/

            case 'Vehicle SubCategory':
                name = 'vehicleSubCategoryType';
                this.handleVehicleSubCategoryChange(event,strIndex);
                break;

            case 'Vehicle SubType':
                name = 'vehicleSubType';
                this.handleVehicleSubTypeChange(event,strIndex);
                break;

            case 'Vehicle Delivered':
                name = 'vehicleDelivered';
                this.handleDedupeInputField(event,strIndex);
                break;

            case 'Registration Number Format':
                name = 'registerationNumberFormatValue';
                this.handleRegisterNumberFormat(event,strIndex);
                break;

            case 'Vehicle Registration Number':
                name = 'vehicleRegistrationNumberValue';
                this.handleDedupeInputField(event,strIndex);
                break;

            case 'Engine Number':
                name = 'engineNoValue';
                this.handleDedupeInputField(event,strIndex);
                break;
            
            case 'Chassis Number':
                name = 'chassisNoValue';
                this.handleDedupeInputField(event,strIndex);
                break;

            case 'Serial Number':
                name = 'serialNoValue';
                this.handleDedupeInputField(event,strIndex);
                break;
            
            case 'Parent Deal Number':
                name = 'parentDealNumber';
                this.handleDedupeInputField(event,strIndex);
                break;
            
            case 'Customer Code':
                name = 'customerCodeValue';
                this.handleDedupeInputField(event,strIndex);
                break;

            case 'NOC Number':
                name = 'nocNumberValue';
                this.handleDedupeInputField(event,strIndex);
                break;


        }
        
        let rec = recs[ strIndex ];
        rec[ name ] = value;
        recs[ strIndex ] = rec;
        this.vehicleDetails = JSON.parse( JSON.stringify( this.vehicleDetails ) );
        this.verifyCheckedHandler();
    }

    // to be removed Vehicle Type Value Change Handler
    handleVehicleTypeChange(event,strIndex) {
        console.log('Inside handleVehicleTypeChange ',strIndex);
        this.vehicleType = event.detail.value;
        if (this.vehicleType !== 'New') {
            fetchCustomerCode({applicantId : this.applicantId})
            .then(result =>{
                console.log('result of customer code fetch', result);
                this.engineNoValue = result;
            })
            .catch(error =>{
                console.log('error in fetching the customer code', error);
            })
        }

         //save if new is selected
         console.log('Inside vehicle dedupe 1: ', this.vehicleType);
        this.vehicleSubCategory=[{ label: '--None--', value: 'none' }];
        this.returnVehicleSubCategory(this.vehicleType, strIndex);
        
        /*this.isRegisterationNumberFormatDisabled = false;
        this.vehicleSubCategoryType = event.detail.value=null;
        this.registerationNumberFormatValue=event.target.value=null;
        this.vehicleRegistrationNumberValue=event.target.value=null;
        this.chassisNoValue=event.target.value=null;
        //this.customerCodeValue=event.target.value=null;
        this.vehicleDelivered=event.target.value=null;

        console.log('Inside handleVehiclechange 1', this.vehicleType );
        console.log('AJthis.vehicleDetails ',this.vehicleDetails );

        let rec = this.vehicleDetails[strIndex];
        rec['vehicleType'] = this.vehicleType;
        rec['oppRecId'] = this.recordid;
        this.vehicleDetails[strIndex] = rec;
        this.vehicleDetails = [...this.vehicleDetails];*/

        //handleChange(event);
        this.dispatchEvent(new CustomEvent('vehicleselectedtype',{detail: this.oppvehicleType}));
    }

    returnVehicleSubCategory(selectedvehicleType){    
        
       if (selectedvehicleType == 'New') {
            //this.subCategoryComboboxTemplate = false;
            //this.vehicleDedupeTemplate = false;
        }
        else if (selectedvehicleType == 'Used') {
            console.log('Inside Used', selectedvehicleType);
            //this.verifyChecked = false;
            //this.subCategoryComboboxTemplate = true;
            //this.vehicleDedupeTemplate = false;
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
        }
        else if (selectedvehicleType == 'Refinance') {
            //this.verifyChecked = false;
            //this.subCategoryComboboxTemplate = true;
            //this.vehicleDedupeTemplate = false;
            this.vehicleSubCategory = [
            { label: 'RLY-REFINANCE WITH IBL LIEN', value: 'RLY' },
            { label: 'RLN-REFINANCE WITHOUT IBL LIEN', value: 'RLN' }
            ]
        }
        else {
            console.log('++++this.vehicleSubCategory ',this.vehicleSubCategory);
            return this.vehicleSubCategory;   
        }
        
    }

    //isvehicleNoRequired = false;
    //Vehicle SubType Value Change Handler.
    handleVehicleSubTypeChange(event,strIndex) {
        let currentRec = this.vehicleDetails[strIndex];
        let currSubType = event.target.value;
        this.currentSUBTYPEvalue = currSubType;
        console.log('====handleVehicleSubTypeChange currSubType ',currSubType);

        currentRec.vehicleSubType = currSubType;

        if(!this.isDesktop && this.vehicleDetails[strIndex] && !this.vehicleDetails[strIndex].vehicleSubType){
            this.vehicleDetails[strIndex].vehicleSubType = currSubType;
        }
        if (this.isTopUpLoan == true) {
            currentRec.isvehicleNoRequired = true;
        }
        if(this.isTopUpLoan == true || this.oppvehicleType == 'Refinance'){
            currentRec.firstAPIfields = true;
        }
        if(this.isUsedORRefinance == true && currSubType != 'Implement'){
            currentRec.isvehicleSubCategoryTypeRequired = true;
        }
        if (currSubType == 'Tractor' || currSubType == 'Harvester') {
            currentRec.isEngineNoRequired = true;
            currentRec.isChassisNoRequired = true;
            currentRec.isSerialNoRequired = false;
            currentRec.vehicleRegistrationNumberDisabled = false;
            currentRec.registerationNumberFormatDisabled = false;
            currentRec.isEngineNumberDisabled = false;
            currentRec.isChassisNumberDisabled = false;
        }

        if (currSubType == 'Implement') {
            currentRec.isEngineNoRequired = false;
            currentRec.isChassisNoRequired = false;
            currentRec.isSerialNoRequired = true;
            currentRec.vehicleRegistrationNumberDisabled = true;
            currentRec.registerationNumberFormatDisabled = true;
            currentRec.isEngineNumberDisabled = true;
            currentRec.isChassisNumberDisabled = true;
            currentRec.isvehicleSubCategoryTypeRequired = false;
        }

        if(this.oppvehicleType == 'Used' && currSubType == 'Implement'){
            console.log('handleVehicleSubCategoryType ',currSubType);
            this.showErrorToast('You cannot select Used & Implement');   
        }

        /*if(this.oppvehicleType == 'Used' || this.oppvehicleType == 'Refinance'){
            console.log('handleVehicleSubCategoryType ',this.oppvehicleType);
            currentRec.firstAPIfields = true;   
        }*/
    }

    //Vehicle SubCategroy Value Change Handler.
    handleVehicleSubCategoryChange(event,strIndex) {
        console.log('Inside handleVehicleSubCategoryChange ',strIndex);
        let currentRec = this.vehicleDetails[strIndex];
        let currSubType = event.target.value;
        currentRec.customerCodeValue = this.oneCustomerCodeValue;
        this.vehicleVerified = false;
        //this.vehicleDedupeTemplate = true;
        this.verifyButton=false;
        this.VerifyExclamation = false;
        currentRec.registerationNumberFormatValue = 'New';
        currentRec.vehicleRegistrationPatternPlaceholder =  Vehicle_New_PlaceHolder;
        currentRec.vehicleType = this.oppvehicleType;
        this.vehicleSubCategoryType = event.target.value;
        
        console.log('Before handleVehicleSubCategoryType ' ,currentRec);
        this.handleVehicleSubCategoryType(currentRec,currSubType);   //AJ update validation Logic
        console.log('After handleVehicleSubCategoryType ' ,currentRec);

        this.vehicleDetails[strIndex] = currentRec;
        this.vehicleDetails = [...this.vehicleDetails];
        console.log('AJthis.vehicleDetails2 ',this.vehicleDetails );    
    }

    //Aakash check this method
    handleVehicleSubCategoryType(currentRec,currSubType){

        this.isRegisterationNumberFormatDisabled = false;

        if (this.vehicleSubCategoryType == 'UOM') {
            currentRec.isCustomerCodeDisabled = false;          
            //currentRec.isParentDealNumberDisabled = true;
            if(this.isTopUpLoan == false){currentRec.isParentDealNumberDisabled = true;} //Vijay's input for topup Parent deal Number will not be disable
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = false;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true; 
            currentRec.chassisNoValue=null;                
        }
        else if (this.vehicleSubCategoryType == 'UOB') {
            currentRec.isCustomerCodeDisabled = false;
            //currentRec.isParentDealNumberDisabled = true;
            if(this.isTopUpLoan == false){currentRec.isParentDealNumberDisabled = true;} //Vijay's input for topup Parent deal Number will not be disable
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = false;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true; 
            currentRec.chassisNoValue=null;             
        }
        else if (this.vehicleSubCategoryType == 'UPD') {
            currentRec.isCustomerCodeDisabled = false;
            //currentRec.isParentDealNumberDisabled = true;
            if(this.isTopUpLoan == false){currentRec.isParentDealNumberDisabled = true;} //Vijay's input for topup Parent deal Number will not be disable
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = false;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true;
            currentRec.chassisNoValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'URS') {
            currentRec.isCustomerCodeDisabled = false;
            currentRec.isParentDealNumberDisabled = false;
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = true;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true;
            currentRec.chassisNoValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'URV') {
            currentRec.isCustomerCodeDisabled = false;
            currentRec.isParentDealNumberDisabled = false;
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = true;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true;
            currentRec.chassisNoValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'UEB') {
            currentRec.isCustomerCodeDisabled = false;
            currentRec.isParentDealNumberDisabled = false;
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = true;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = false;
            currentRec.chassisNoValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'UPB') {
            currentRec.isCustomerCodeDisabled = false;
            //currentRec.isParentDealNumberDisabled = true;
            if(this.isTopUpLoan == false){currentRec.isParentDealNumberDisabled = true;} //Vijay's input for topup Parent deal Number will not be disable
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = false;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = false;
        }
        else if (this.vehicleSubCategoryType == 'UPO') {
            currentRec.isCustomerCodeDisabled = false;
            //currentRec.isParentDealNumberDisabled = true;
            if(this.isTopUpLoan == false){currentRec.isParentDealNumberDisabled = true;} //Vijay's input for topup Parent deal Number will not be disable
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = false;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true;
            currentRec.chassisNoValue=null;  
        }      
        else if (this.vehicleSubCategoryType == 'UIM') {
            currentRec.isCustomerCodeDisabled = false;
            currentRec.isParentDealNumberDisabled = false;
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = true;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true;
            currentRec.chassisNoValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'RLY') {
            currentRec.isCustomerCodeDisabled = false;
            currentRec.isParentDealNumberDisabled = false;
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = true;
            currentRec.nocNumberValueReq = false;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = true;
            currentRec.chassisNoValue=null;  
        }
        else if (this.vehicleSubCategoryType == 'RLN') {
            currentRec.isCustomerCodeDisabled = false;
            currentRec.isParentDealNumberDisabled = false;
            currentRec.vehicleDelivered=null;
            currentRec.firstAPIfields = true;
            currentRec.nocNumberValueReq = true;//SFTRAC-1579
            currentRec.registerationNumberFormatValue= null;
            currentRec.isNOCNumberDisabled = false;
        }
    }

    //On Blur Handler for Input field.Also getting the values of input fields to pass them in vehicleDedupe method.
    handleDedupeInputField(event,strIndex){
        console.log('Inside handleDedupeInputField ',strIndex);
        let currentRec = this.vehicleDetails[strIndex];
        const label = event.target.label;

        if (label == 'Engine Number') {
            console.log('Inside Engine Number ',event.target.value);
            currentRec.engineNoValue = event.target.value;
        }
        else if (label == 'Vehicle Delivered') {
            currentRec.vehicleDelivered = event.target.value;
        }
        else if (label == 'Vehicle Registration Number') {
            console.log('vehicle 729 ');
            this.vehicleRegistrationNumberValue = event.target.value;
            let vehicleRegistrationInput = this.template.querySelector('lightning-input[data-id=dedupeeInput]');
            let formdataVehicleNumber = vehicleRegistrationInput.value;
            currentRec.vehicleRegistrationNumberValue = formdataVehicleNumber;
            vehicleRegistrationInput.reportValidity();
        }
        else if (label == 'Chassis Number') {
            console.log('Inside Chassis Number ',event.target.value);
            currentRec.chassisNoValue = event.target.value;
        }
        else if (label == 'Serial Number'){
            console.log('Inside Serial Number ',event.target.value);
            currentRec.serialNoValue = event.target.value;
        }
        else if (label == 'Parent Deal Number'){
            console.log('Inside Parent Deal Number ',event.target.value);
            currentRec.parentDealNumber = event.target.value;
        }else if (label == 'Customer Code'){
            console.log('Inside Customer Code ',event.target.value);
            currentRec.customerCodeValue = event.target.value;
        }else if (label == 'NOC Number'){
            console.log('Inside NOC Number ',event.target.value);
            currentRec.nocNumberValue = event.target.value;
        }

        this.vehicleDetails[strIndex] = currentRec;
        this.vehicleDetails = [...this.vehicleDetails];
    }

    //Handler for registration number format value change.
    handleRegisterNumberFormat(event,strIndex){
        let currentRec = this.vehicleDetails[strIndex];
        console.log('handleRegisterNumberFormat currentRec ' ,currentRec);

        this.verifyButton = false;
        this.VerifyExclamation = false;
        currentRec.registerationNumberFormatValue = event?.detail?.value;
        currentRec.vehicleRegistrationNumberValue = null;

        if (currentRec.registerationNumberFormatValue == 'old') {
            currentRec.vehicleRegistrationPattern = Vehicle_Old;  
            currentRec.vehicleRegistrationPatternPlaceholder = Vehicle_Old_PlaceHolder
        }
        else if (currentRec.registerationNumberFormatValue == 'New') {
            currentRec.vehicleRegistrationPattern = Vehicle_New;
            currentRec.vehicleRegistrationPatternPlaceholder = Vehicle_New_PlaceHolder;
        }

        this.vehicleDetails[strIndex] = currentRec;
        this.vehicleDetails = [...this.vehicleDetails];
    }

    label = {Retry_Exhausted};
    handleVerifyButton(event){
        this.isSpinnerMoving = true;
        try{
        console.log('+++++callVehicleDedupe ', this.callVehicleDedupe);
        console.log('====vehicleDetails Verify ',this.vehicleDetails);
        let strIndex = event.target.dataset.recordId;
        // Update the subcategories for this row
        let currentRec = this.vehicleDetails[strIndex];
        currentRec.isVerifydisableFields = true; //SFTRAC-1375
        // Making this true as and when the button will be clicked.
        //this.callVehicleDedupe = true;
        console.log('verify ',currentRec);
        if(!currentRec.vehicleSubType){
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: "Please enter Vehicle Sub Type ",variant: 'Error',mode: 'dismissible',}));
            this.isSpinnerMoving = false;
            this.callVehicleDedupe = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        } else if(!currentRec.vehicleDelivered){
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: "Please select Vehicle delivered ",variant: 'Error',mode: 'dismissible',}));
            this.isSpinnerMoving = false;
            this.callVehicleDedupe = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        }else if (currentRec.vehicleSubType == 'Implement' && this.oppvehicleType === 'Used'){
            this.isSpinnerMoving = false;
            this.showErrorToast('You cannot select Used & Implement');
            this.callVehicleDedupe = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        }else if(currentRec.vehicleSubType == 'Implement'){
            let allRows = this.vehicleDetails;
            let implementCount = 0;

            allRows.forEach(element => {
                console.log('====element ', element);
                console.log('====allRows ', element.vehicleSubType);

                if (element.vehicleSubType === 'Implement') {
                    implementCount++;
                }

                if (element.vehicleSubType === currentRec.vehicleSubType && currentRec.vehicleSubType === 'Implement' && implementCount > 1) {
                    this.isSpinnerMoving = false;
                    this.showErrorToast('You cannot add new Implement, already one Implement added');
                    this.callVehicleDedupe = false;
                    currentRec.isVerifydisableFields = false; //SFTRAC-1375
                }else{
                    this.callVehicleDedupe = true;
                }
            });
            
        }else if(currentRec.vehicleDelivered == 'No'){
            this.callVehicleDedupe = false;
            if(this.isUsedORRefinance == true && currentRec.vehicleSubType != 'Implement' && (!currentRec.vehicleSubCategoryType)){
                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: "Please enter Vehicle Sub Category ",variant: 'Error',mode: 'dismissible',}));
                this.isSpinnerMoving = false;
                currentRec.isVerifydisableFields = false; //SFTRAC-1375
            }else{
                currentRec.vehicleVerified = true; // setting it as Verified true because we are not going to call any API
                setTimeout(() => {
                    // Code to be executed after the wait time
                    this.updateRecordVDetails(this.vehicleDetails[strIndex],strIndex)
                    .then(result => {
                        this.dispatchEvent(new ShowToastEvent({title: 'Success',message: "Record saved successfully.",variant: 'Success',mode: 'dismissible',}));
                        this.verifyCheckedHandler();
                    }).catch(error=>{
                        this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                        this.isSpinnerMoving = false;
                        currentRec.isVerifydisableFields = false; //SFTRAC-1375
                    });
                }, 2000);
            }
        }else{
            if(currentRec.vehicleRegistrationNumberValue != null && currentRec.vehicleRegistrationNumberValue != ''){
                let vRNopattern;
                if(currentRec.registerationNumberFormatValue == 'old'){
                     vRNopattern = new RegExp("^[A-Z]{3}[0-9]{4}$");
                }else{
                     vRNopattern = new RegExp("^[A-Z]{2}[0-9A-Z]{2}[0-9A-Z]{0,3}[0-9]{4}$");
                }
                if (vRNopattern.test(currentRec.vehicleRegistrationNumberValue)) {
                    this.callVehicleDedupe = true;
                } else {
                    this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Pattern not matched please correct the Vehicle Registration Number',variant: 'error',}));
                    this.isSpinnerMoving = false;
                    this.callVehicleDedupe = false;
                    currentRec.isVerifydisableFields = false; //SFTRAC-1375
                }
            }else if((!currentRec.vehicleRegistrationNumberValue) && this.isTopUpLoan == true){
                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Please enter Vehicle Registration Number',variant: 'error',}));
                    this.isSpinnerMoving = false;
                    this.callVehicleDedupe = false;
                    currentRec.isVerifydisableFields = false; //SFTRAC-1375
            }

            if(this.isUsedORRefinance && currentRec.nocNumberValue){
                //const nOCPattern = new RegExp("^[0-9]*$");
                const nOCPattern =new RegExp("^[0-9a-zA-Z]*$");
                if (nOCPattern.test(currentRec.nocNumberValue) && currentRec.isVerifydisableFields == true) { //SFTRAC-1121 added currentRec.isVerifydisableFields == true check
                    this.callVehicleDedupe = true;
                } else {
                    console.log("++++++++The NOC number does not match the pattern.");
                    this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Pattern not matched please correct the NOC Number',variant: 'error',}));
                    this.isSpinnerMoving = false;
                    this.callVehicleDedupe = false;
                    currentRec.isVerifydisableFields = false; //SFTRAC-1375
                }
            }

            if((!currentRec.parentDealNumber) && (this.isTopUpLoan == true || this.oppvehicleType == 'Refinance' || currentRec.vehicleSubCategoryType == 'RLY' || currentRec.vehicleSubCategoryType == 'RLN' || currentRec.vehicleSubCategoryType == 'UIM' || currentRec.vehicleSubCategoryType == 'URS' || currentRec.vehicleSubCategoryType == 'URV' || currentRec.vehicleSubCategoryType == 'UEB')){
                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Please enter Parent Deal Number',variant: 'error',}));
                this.isSpinnerMoving = false;
                this.callVehicleDedupe = false;
                currentRec.isVerifydisableFields = false; //SFTRAC-1375
            }else if (currentRec.isVerifydisableFields == true){    //SFTRAC-1121 added currentRec.isVerifydisableFields == true check
                this.callVehicleDedupe = true;
                currentRec.isVerifydisableFields = true; //SFTRAC-1375
            }
        }

        if (this.callVehicleDedupe == true) {
            //this.isSpinnerMoving == false ? true : false;
            console.log('this.callVehicleDedupe ',this.callVehicleDedupe);
            console.log('doTractorVehicleDedupeCallout Para  engine_No '+currentRec.engineNoValue +'chassis_No '+currentRec.chassisNoValue+'serial_No '+ currentRec.serialNoValue +'currentRec.vehicleSubType '+currentRec.vehicleSubType);
            console.log('usedorfinance---'+this.isUsedORRefinance);
            console.log('isFullL2Journey---'+this.isFullL2Journey);
            if(this.isUsedORRefinance == false){
                this.callTractorDedupeAPI(currentRec, strIndex);
                /*if(this.isSpinnerMoving == true){
                    this.isSpinnerMoving = false;
                }*/
            }else if(this.isUsedORRefinance == true  && this.isFullL2Journey == false){
                this.callPVTWDedupeAPI(currentRec, strIndex);
                /*if(this.isSpinnerMoving == true){
                    this.isSpinnerMoving = false;
                }*/
                /*if(currentRec.customerCodeValue == null || currentRec.nocNumberValue == null || currentRec.parentDealNumber == null){
                    //currentRec.firstAPIfields = true;
                    this.isSpinnerMoving = false;
                    this.showErrorToast('Please enter required fields value like Customer Code or Noc Number or Parent Deal Number'); 
                }else{
                    this.callPVTWDedupeAPI(currentRec, strIndex);
                }*/
                
            }else if(currentRec.pvtwAPIFlag == true && this.isFullL2Journey == true){
                this.callTractorDedupeAPI(currentRec, strIndex);
            }/*else if(currentRec.pvtwAPIFlag == false && this.isFullL2Journey == true){
                this.callPVTWDedupeAPI(currentRec, strIndex);
            }*/
        
        }else if (this.callVehicleDedupe == true && !currentRec.vehicleRegistrationNumberValue.match(this.getRegNumberFormat(currentRec)) ) {
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Pattern not matched',variant: 'error',}));
            this.verifyChecked = false;
            this.isSpinnerMoving = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        }
        }catch(error){
            this.isSpinnerMoving = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        }
    }
    // End of handleVerifyButton handler

    //Tractor New API call
    callTractorDedupeAPI(currentRec, strIndex){
        if(currentRec.nocNumberValue == ''){currentRec.nocNumberValue = null}
        console.log('callTractorDedupeAPI API '+currentRec+' strIndex '+strIndex);
        if(currentRec.vehicleRegistrationNumberValue == null && currentRec.vehicleType == 'Refinance' && currentRec.vehicleSubType != 'Implement'){
            this.showErrorToast('Cannot check dedupe!! Registration Number is mandatory for Refinance Vehicle');
            this.isSpinnerMoving = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        }
        else if((currentRec.engineNoValue == null || currentRec.chassisNoValue == null || currentRec.engineNoValue == "" || currentRec.chassisNoValue == "") && currentRec.vehicleSubType != 'Implement'){
            this.showErrorToast('Cannot check dedupe for this vehicle details Engine No. or Chassis No. is Empty');
            this.isSpinnerMoving = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        }else if((currentRec.serialNoValue == null || currentRec.serialNoValue == "") && currentRec.vehicleSubType == 'Implement' && currentRec.vehicleDelivered == 'Yes'){
            this.showErrorToast('Cannot check dedupe for this vehicle details Serial No. is Empty');
            this.isSpinnerMoving = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
        }else if(currentRec.vehicleSubType == 'Implement'){
            currentRec.vehicleVerified = true;
            setTimeout(() => {
                this.updateRecordVDetails(this.vehicleDetails[strIndex],strIndex)
                .then(result => { 
                    this.dispatchEvent(new ShowToastEvent({title: 'Success',message: "Record saved successfully.",variant: 'Success',mode: 'dismissible',}));
                    this.verifyCheckedHandler();
                }).catch(error=>{
                    this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                    this.isSpinnerMoving = false;
                    currentRec.isVerifydisableFields = false; //SFTRAC-1375
                });
            }, 2000);
        }else if(this.oppvehicleType == 'Refinance' && currentRec.nocNumberValue == null && currentRec.vehicleSubCategoryType == 'RLN'){ //SFTRAC-1579
            this.showErrorToast('Cannot check dedupe for this vehicle details NOC No. is Empty');
            this.isSpinnerMoving = false;
            currentRec.isVerifydisableFields = false; 
        }
        else{
            this.isSpinnerMoving = true;
            doTractorVehicleDedupeCallout({'engine_No': currentRec.engineNoValue, 'chassis_No': currentRec.chassisNoValue, 
                    'serial_No': currentRec.serialNoValue, 'subType': currentRec.vehicleSubType, 'loanAppId': this.recordid, 
                    'vehicleType': this.oppvehicleType}).then(result =>{
                    console.log("doTractorVehicleDedupeCallout Result:: "+result);
                    if(result =='no'){
                        console.log("doTractorVehicleDedupeCallout Result no:: "+result);
                        console.log("doTractorVehicleDedupeCallout Update: "+this.vehicleDetails[strIndex]);
                        currentRec.verifyChecked = true;
                        currentRec.vehicleVerified =true;
                        if(currentRec.vehicleVerified =true){
                            //this.updateRecordDetails(this.vehicleDetails[strIndex],strIndex);
                            this.updateRecordVDetails(this.vehicleDetails[strIndex],strIndex)
                            .then(result => { 
                                console.log('updateRecordVDetails in NO:',result);
                                this.dispatchEvent(new ShowToastEvent({title: 'Success',message: "Vehicle dedupe details Verified.",variant: 'Success',mode: 'dismissible',}));
                                this.verifyCheckedHandler();

                                if(!this.isDesktop){
                                    var vehicleSubtype = this.template.querySelectorAll('[data-value="vehicleSubtype"]');
                                    if(vehicleSubtype && vehicleSubtype?.length > 0 ){
                                    vehicleSubtype[strIndex].value = this.vehicleDetails[strIndex].vehicleSubType;
                                    }                                
                                    var vehicleSubCat= this.template.querySelectorAll('[data-value="vehicleSubCategory"]');
                                    if(vehicleSubCat && vehicleSubCat?.length >0){
                                    vehicleSubCat[strIndex].value = this.vehicleDetails[strIndex].vehicleSubCategoryType;
                                    }
                                    var regNumFormat = this.template.querySelectorAll('[data-value="regNumFormat"]');
                                    if(regNumFormat && regNumFormat?.length >0){
                                    regNumFormat[strIndex].value = this.vehicleDetails[strIndex].registerationNumberFormatValue;

                                    }
                                    var vehicleDelivered = this.template.querySelectorAll('[data-value="vehicleDelivered"]');
                                  if(vehicleDelivered && vehicleDelivered?.length >0){
                                    vehicleDelivered[strIndex].value = this.vehicleDetails[strIndex].vehicleDelivered;
                                    }
                                }
                        
                                /*if(this.isUsedORRefinance == true){
                                    this.callPVTWDedupeAPI(currentRec); //Call PV TW API call for isUsedORRefinance
                                }*/
                            }).catch(error=>{
                                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                                this.isSpinnerMoving = false;
                                currentRec.isVerifydisableFields = false; //SFTRAC-1375
                            });
                        }
                    }else if(result =='yes'){
                        console.log("doTractorVehicleDedupeCallout Result yes:: "+result);
                        currentRec.verifyChecked = true;
                        currentRec.vehicleVerified =true;
                        if(this.isFullL2Journey == false){
                            // this is for New or Used or Refinance in L1 Journey
                            if(this.isUsedORRefinance == true){
                                this.updateRecordVDetails(this.vehicleDetails[strIndex],strIndex)
                                .then(result => { 
                                    this.dispatchEvent(new ShowToastEvent({title: 'Success',message: "Vehicle dedupe found but record is created",variant: 'Success',mode: 'dismissible',}));
                                    this.verifyCheckedHandler();
                                }).catch(error=>{
                                    this.isSpinnerMoving = false;
                                    currentRec.isVerifydisableFields = false; //SFTRAC-1375
                                    this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                                });   
                            }else{
                                this.isSpinnerMoving = false; 
                                currentRec.isVerifydisableFields = false; //SFTRAC-1375
                                this.showErrorToast('Duplicate Vehicle found, please enter your details again');
                            }
                        }else if(this.isUsedORRefinance == true && this.isFullL2Journey == true){
                            this.updateRecordVDetails(this.vehicleDetails[strIndex],strIndex)
                            .then(result => { 
                                console.log('updateRecordVDetails in isUsedORRefinance:',result);
                                this.dispatchEvent(new ShowToastEvent({title: 'Success',message: "Vehicle dedupe found but record is created",variant: 'Success',mode: 'dismissible',}));
                                this.verifyCheckedHandler();
                                /*if(this.isUsedORRefinance == true){
                                    this.callPVTWDedupeAPI(currentRec); //Call PV TW API call for isUsedORRefinance
                                }*/
                            }).catch(error=>{
                                this.isSpinnerMoving = false;
                                currentRec.isVerifydisableFields = false; //SFTRAC-1375
                                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                            });   
                        }/*else if(this.isUsedORRefinance == false && this.isL2Journey == true){
                            const oppFields = {};
                            oppFields[OPP_ID.fieldApiName] = this.recordid;
                            oppFields[STAGE_NAME.fieldApiName] = 'Journey Stop';
                            this.updateRecordDetails(oppFields);
                            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: "Loan Application Journey has stop because Vehicle dedupe found",variant: 'Error',mode: 'dismissible',}));
                        }*/                   
                    }else if(result =='retry'){
                        //show toast message and add retry logic Vehicle Dedupe is unsuccessfull.Please
                        this.isSpinnerMoving = false; //SFTRAC-487
                        currentRec.isVerifydisableFields = false; //SFTRAC-1375
                        this.showErrorToast('Vehicle Dedupe is unsuccessfull please try again'); 
                        console.log("doTractorVehicleDedupeCallout Result retry:: "+result);
                        
                    }else if(result === this.label.Retry_Exhausted){
                        //You have reached maximum attempt to RUN EMI Engine
                        this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'You have reached maximum attempt to RUN Vehicle Dedupe API, You can try in L2 journey',variant: 'error',mode: 'dismissible'}));
                        currentRec.verifyChecked = false;
                        currentRec.vehicleVerified =false;
                        this.updateRecordVDetails(this.vehicleDetails[strIndex],strIndex)
                        .then(result => { 
                            console.log('updateRecordVDetails in retry:',result);
                            this.verifyCheckedHandler();
                        }).catch(error=>{
                            this.isSpinnerMoving = false;
                            currentRec.isVerifydisableFields = false; //SFTRAC-1375
                            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Something went wrong!',variant: 'error',mode: 'dismissible'}));
                        });

                    }else if(result=='journeystop'){
                        this.isSpinnerMoving = false;
                        this.dispatchEvent(new ShowToastEvent({title: 'Error',message: "Loan Application Journey has stop because Vehicle dedupe found",variant: 'Error',mode: 'dismissible',}));
                    }
            }).catch(error => {
                console.log(' doTractorVehicleDedupeCallout error:- ' + error.body.message);
                this.isSpinnerMoving = false;
                currentRec.isVerifydisableFields = false; //SFTRAC-1375
                const evt = new ShowToastEvent({title: 'Error',message: error.body.message, variant: 'error',});this.dispatchEvent(evt);       
            });
        }
    }

    //Call PV & TW Dedupe API
    callPVTWDedupeAPI(currentRec, strIndex){
        let NocNumberDetails = {
            'loanApplicationId': this.recordid,
            'customerCode': currentRec.customerCodeValue,
            'oldDealNo': currentRec.parentDealNumber,
            'vehicleRegisterationNumber': currentRec.vehicleRegistrationNumberValue,
            'nocNo': currentRec.nocNumberValue,
            'product': 'Tractor',
            'category': currentRec.registerationNumberFormatValue,
            'subCategory': currentRec.vehicleSubCategoryType
        };

        doVehicleDedupeCallout({'vehicleDedupe': JSON.stringify(NocNumberDetails)}).then(result =>{
            const obj = JSON.parse(result);
            console.log('doVehicleDedupeCallout - Result:: ' ,obj);
            console.log("doVehicleDedupeCallout - Parsed Result:: "+result);

            if (obj.response.content[0].Proceed_Flag == 'Y') {
                console.log('existing API Y ');
                currentRec.pvtwAPIFlag = true;
                this.callTractorDedupeAPI(currentRec,strIndex);
                //this.isSpinnerMoving = false; //SFTRAC-487
                /*this.verifyButton = true;
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
                }*/
            } else if (obj.response.content[0].Proceed_Flag == 'N') {
                this.isSpinnerMoving = false;
                const evt = new ShowToastEvent({title: 'Error',message: obj.response.content[0].Description,variant: 'error',mode: 'sticky', });
                this.dispatchEvent(evt);
                currentRec.isVerifydisableFields = false; //SFTRAC-1375
                /*if(this.currentOppRecord?.LeadSource == 'D2C'){
                    doD2cVehicleDedupeCallout({loanId : this.recordid, status : 'Journey Stopped'})
                }
                console.log('getting N input ',obj.response.content[0].Description);
                this.vehicleVerified =false;*/
            } else if (obj.response.content[0].Proceed_Flag == 'W') {
                console.log('getting W input ',obj.response.content[0].Description);
                this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: obj.response.content[0].Description,variant: 'warning',mode: 'sticky',}));
                console.log('existing API W ');
                currentRec.pvtwAPIFlag = true;
                this.callTractorDedupeAPI(currentRec,strIndex);
                //this.isSpinnerMoving = false; //SFTRAC-487
                /*this.verifyChecked = true;
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
                }*/
            } else {
                this.vehicleVerified =false;
                const evt = new ShowToastEvent({title: 'Error',message: 'Vehicle Dedupe is unsuccessfull.Please enter your details again.',variant: 'error',mode: 'sticky',});this.dispatchEvent(evt);
                this.isSpinnerMoving = false;
                currentRec.isVerifydisableFields = false; //SFTRAC-1375
            }
        }).catch(error => {
            console.log(' doVehicleDedupeCallout error:- ' + error.body.message);
            this.isSpinnerMoving = false;
            currentRec.isVerifydisableFields = false; //SFTRAC-1375
            const evt = new ShowToastEvent({title: 'Error',message: error.body.message, variant: 'error',});this.dispatchEvent(evt);       
        });
    }

    verifyCheckedHandler(){

        this.vehicleVerified = this.vehicleDetails.every(element => element.vehicleVerified === true);
        this.verifyChecked = this.vehicleDetails.every(element => element.verifyChecked === true);

        console.log('this.vehicleVerified '+this.vehicleVerified+' this.verifyChecked '+this.verifyChecked);
        this.dispatchEvent(new CustomEvent('vehicleverified',{detail: this.vehicleVerified}));
        this.dispatchEvent(new CustomEvent('verifychecked',{detail: this.verifyChecked}));

        this.isSpinnerMoving = false;

        /*Disbaling the input fields if the dedupe is successfull.
        this.isCustomerCodeDisabled = true;
        this.isParentDealNumberDisabled = true;
        this.isVehicleRegistrationNumberDisabled = true;
        this.isRegisterationNumberFormatDisabled = true;*/
    }

    updateVehiclelist =[];
    //this method saves the record values
    async updateRecordVDetails(finalvehicleDetails,strIndex){
        console.log('finalvehicleDetails++++ ', finalvehicleDetails);
        this.updateVehiclelist =[];
        console.log('this.updateVehiclelist++++ ', this.updateVehiclelist);
        console.log('Update finalvehicleDetails22 ', finalvehicleDetails[0]);
        if(strIndex != undefined && finalvehicleDetails != null){
            console.log('Update strIndex++++ ', strIndex);
            console.log('Update finalvehicleDetails.isSaved++++ ', finalvehicleDetails.isSaved);
            //if(!finalvehicleDetails.isSaved){
                this.updateVehiclelist.push(finalvehicleDetails); 
            //}     
        }else{
            console.log('Update Else++++ ', finalvehicleDetails);
            this.updateVehiclelist = finalvehicleDetails;
        }
        console.log('this.updateVehiclelist ', this.updateVehiclelist);
        console.log('this.updateVehiclelist2 ', this.updateVehiclelist[0]);
    try {

        const result = await updateVehicleDetails({ listVehicleDetails: this.updateVehiclelist });

            let message;
            let variant;

            if (result) {
                message = 'Successfully Processed!';
                variant = 'success';
                
                if (strIndex != undefined) {
                    let currentRec = this.vehicleDetails[strIndex];
                    currentRec.isSaved = true;
                    currentRec.isVerifydisableFields = true;
                    
                    //let temporaryArray = [];
                    //temporaryArray = this.vehicleDetails.filter((item, index) => !item.vehicleVerified && index !== parseInt(strIndex));

                    await this.init();
                    currentRec.vehicleDetailId = result[0];
                    this.vehicleDetails[strIndex] = currentRec;
                    this.vehicleDetails = [...this.vehicleDetails];//SFTRAC-1373
                    /*this.vehicleDetails = [
                        ...this.vehicleDetails.filter((detail, index, self) => index === self.findIndex((t) => (
                            t.vehicleDetailId === detail.vehicleDetailId )))];
                    this.vehicleDetails = this.vehicleDetails.filter((item) => item.vehicleVerified === true).concat(temporaryArray);*/
                    console.log('====+vehicleDetails updateVehicleDetails3 ', this.vehicleDetails);

                    this.disableAllFields(currentRec);
                    if(this.isRefinance == false){this.isDisableAddRow = false}//SFTRAC-1373
                                    
                } else {
                    this.vehicleDetails.forEach(item => {
                        if (item.isSaved != true) {
                            item.isSaved = true;
                        }
                    });
                }
                
            } else {
                message = 'Some error occurred. Please reach out to your Salesforce Admin for help!';
                variant = 'error';
            }

            const toastEvent = new ShowToastEvent( {
                title: 'Vehicle Details updated',
                message: message,
                variant: variant
            } );
            this.dispatchEvent( toastEvent );

        }catch (error) {
            console.error('Error during updateVehicleDetails: ', error);
        // Handle the error appropriately
    }

    }
    @api vehicleTypeVerified(){
        /*if(this.verifyChecked && this.vehicleVerified){
            return true;
        }*/
        let allVehicleVerified = true;
        for (let index = 0; index < this.vehicleDetails.length; index++) {
            const element = this.vehicleDetails[index];
            if(!element.isVerifydisableFields){
                allVehicleVerified = false;
                break;
            }
        }
        return allVehicleVerified;
    }
    @api vehicleTypeSelected(){
        /*let returnstr = true;
        await getVehicleDetailsRecord({loanApplicationId : this.recordid}).then(response =>{ 
            //this.loanApplicationWrapper = response;
            const vehicledetailsList = response.vehicledetailsList; 
            console.log('vehicleTypeSelected vehicledetailsList ',vehicledetailsList);
            if(vehicledetailsList && vehicledetailsList.length >0){
                console.log('IF vehicleTypeSelected vehicledetailsList ',vehicledetailsList);
                returnstr = true;
                //return true;
            }else{
                console.log('ELSE vehicleTypeSelected vehicledetailsList ',vehicledetailsList);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please add atleast one Vehicle Details record to procced',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                returnstr = false;   
                //return false;         
            }
            //return true;
        }).catch(error => { 
                console.log('vehicleTypeSelected getCurrentOppRecord Error:: ',error);
        });
        
        return returnstr;*/

        /*let vehicleTypeInput;
        if(this.isRefinance){
            vehicleTypeInput = this.template.querySelector('.vehicleCssRefinance');
        }else{
            vehicleTypeInput = this.template.querySelector('.vehicleCss');
        }       
        console.log('check vehicle verify or not', vehicleTypeInput.value);
        if (vehicleTypeInput.value == undefined) {
            vehicleTypeInput.reportValidity();
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Select Vehicle type to procced.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return false;
        }
        return true;*/
    }

    disableAllFields(currentRec){

        currentRec.disableSubCategoryField = true;
        currentRec.disableSubTypeField = true;
        currentRec.registerationNumberFormatDisabled = true;
        currentRec.vehicleRegistrationNumberDisabled = true;
        currentRec.disableDeliveredField = true;
        currentRec.isEngineNumberDisabled = true;
        currentRec.isChassisNumberDisabled = true;
        currentRec.isSerialNumberDisabled = true;
        currentRec.isVerifydisableFields = true; 
        currentRec.isParentDealNumberDisabled = true;
        currentRec.isNOCNumberDisabled = true;
    }

    isvehicleRegistrationNumberValue = false;
    @api  vehicleRegisterationNumber(){
        console.log('Tractor Dedupe vehicleRegisterationNumber API ');
        /*let vehicleNumberInput = this.template.querySelector('.vehicleNumber');
        console.log('Tractor Dedupe vehicleNumberInput API ',vehicleNumberInput);
        console.log('Tractor Dedupe vehicleNumberInput2 API ',vehicleNumberInput.reportValidity());
        vehicleNumberInput.reportValidity();*/
        //console.log('Tractor Dedupe API '+vehicleNumberInput.value + 'check '+this.vehicleRegistrationNumberValue.match(this.getRegNumberFormat()));
        
        /*let allRows = this.vehicleDetails;
        allRows.forEach(element => {
            console.log('allRows vehicleVerified ',element.vehicleRegistrationNumberValue);
            console.log('allRows vehicleVerified2 ',element.vehicleRegistrationNumberValue.match(this.getRegNumberFormat(element)));
            console.log('allRows vehicleVerified3 ',this.getRegNumberFormat(element))
            if(element.vehicleRegistrationNumberValue.match(this.getRegNumberFormat(element)) == true){
                element.vehicleRegistrationNumberValue.reportValidity();
                this.isvehicleRegistrationNumberValue = true;
                console.log('Tractor Dedupe if API ',this.isvehicleRegistrationNumberValue);
            }else{
                this.isvehicleRegistrationNumberValue = false;
                console.log('Tractor Dedupe else API ',this.isvehicleRegistrationNumberValue);
            }
        });
        console.log('Tractor Dedupe if else API3 ',this.isvehicleRegistrationNumberValue);
        console.log('Tractor Dedupe value API3 ',vehicleNumberInput.value);
        if (!this.isvehicleRegistrationNumberValue) {
            console.log('Vehicle number is correct or not ');
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Vehicle Registration number is not valid. Please enter correct details.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return false;
        }*/
        //return this.isvehicleRegistrationNumberValue;  
        return true; 
    }

    renderedCallback(){
        if(this.isTopUpLoan || this.isRefinance){
            this.isDisableAddRow = true;
        }
        console.log('renderedCallback');

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
        this.disableDealNobtn = true;
    }

    showErrorToast(message) {
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(toastEvent);
    }

    saveVehicleDetails(){
        //alert('Save VD');
        console.log('Save array ',this.vehicleDetails);
        let vehicleDetailsfilteredList = [];
        vehicleDetailsfilteredList = this.vehicleDetails.filter(item => !item.isSaved);
        console.log( 'update vehicleDetailsfilteredList ' + vehicleDetailsfilteredList );
        this.updateRecordDetails(vehicleDetailsfilteredList);
    }

    handleVerified(){
        const toastEvent = new ShowToastEvent({
            title: 'Warning',
            message: 'This row record is already Verified',
            variant: 'warning',
        });
        this.dispatchEvent(toastEvent);
    }

    searchDealNumber(event){
        this.dealNumberValue = event.target.value;
        console.log('dealNumberValue',this.dealNumberValue);
    }

    async validateDealNo(){
        try{
        console.log('dealNumberValue',this.dealNumberValue);
        if(!this.dealNumberValue){
            const toastEvent = new ShowToastEvent({
                title: 'Missing Deal Number',
                message: 'Application cannot be move ahead without Deal Number',
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
            return;
        }else{
            this.dispatchEvent(new CustomEvent('enablednextbutton'));
            this.isSpinnerMoving = true;
            const oppFields = {};
            oppFields[OPP_ID.fieldApiName] = this.recordid;
            oppFields[PARENT_DEAL_NUMBER.fieldApiName] = this.dealNumberValue;
            const fields = oppFields;
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(()=> {
            doDealEligibleRefinanceCallout({ 'opportunityId': this.recordid,'dealNumber' : this.dealNumberValue }).then(response => {
                let result = JSON.parse(response);
                console.log('Eligible Master API Response:==>', result.response);
                if(result?.response?.content[0]?.RefinanceEligible?.trim() === 'No'){
                    let msg ='Not eligible for Refinance';
                    if(this.isTopUpLoan){msg = 'Not eligible for Topup Loan'}
                    const toastEvent = new ShowToastEvent({
                        title: msg,
                        message: 'Application cannot be move ahead',
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvent);
                    const oppFields = {};
                    oppFields[OPP_ID.fieldApiName] = this.recordid;
                    oppFields[PARENT_DEAL_NUMBER.fieldApiName] = null;
                    this.updateRecordDetails(oppFields);
                    this.isSpinnerMoving = false;
                    if(this.isTopUpLoan){this.dispatchEvent(new CustomEvent('disablenextbutton'));}
                }else if(this.isTopUpLoan && result?.response?.content[0]?.RefinanceEligible?.trim() === 'Yes' && result?.response?.content[0]?.TopUp_Refin == 'T'){
                    this.isSpinnerMoving = false;
                    this.eligibilityLoanAmount = result?.response?.content[0]?.EligibilityAmount;
                    this.tenureInMonths = result?.response?.content[0]?.Tenure_In_Months;
                        const toastEvent = new ShowToastEvent({
                            title: 'Eligible for TopUp',
                            message: 'Application eligible for Topup Loan',
                            variant: 'success',
                        });
                        this.dispatchEvent(toastEvent);
                        const oppFields = {};
                        oppFields[OPP_ID.fieldApiName] = this.recordid;
                        oppFields[Loan_amount.fieldApiName] = result?.response?.content[0]?.EligibilityAmount;
                        this.updateRecordDetails(oppFields);
                        
                }
                else if(result?.response?.content[0]?.RefinanceEligible?.trim() === 'Yes'){
                    this.isSpinnerMoving = false;
                    this.eligibilityLoanAmount = result?.response?.content[0]?.EligibilityAmount;
                    this.tenureInMonths = result?.response?.content[0]?.Tenure_In_Months;
                    let message;
                    let variant;
                    if(this.isTopUpLoan){
                        message = 'Application eligible for Refinance Loan, cannot be move ahead';
                        variant ='error';
                    }else{
                        message= 'Application eligible for Refinance Loan';
                        variant ='success';
                    }
                    const toastEvent = new ShowToastEvent({
                        title: 'Eligible for Refinance',
                        message: message,
                        variant: variant,
                    });
                    this.dispatchEvent(toastEvent);
                    if(this.isTopUpLoan){this.dispatchEvent(new CustomEvent('disablenextbutton'));} //SFTRAC-1079
                }
            }).catch(error => {
                console.log('Eligible Master API Error:==>', error);
                const toastEvent = new ShowToastEvent({
                    title: 'Error in getting details from Eligible Master API',
                    message: error?.body?.message,
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);
                this.isSpinnerMoving = false;
                const oppFields = {};
                oppFields[OPP_ID.fieldApiName] = this.recordid;
                oppFields[PARENT_DEAL_NUMBER.fieldApiName] = null;
                this.updateRecordDetails(oppFields);
                return;
            });
            }).catch(error=>{
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong!',
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);
                this.isSpinnerMoving = false;
            });

        }
        }catch(error){
            this.isSpinnerMoving = false;
        }
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
}