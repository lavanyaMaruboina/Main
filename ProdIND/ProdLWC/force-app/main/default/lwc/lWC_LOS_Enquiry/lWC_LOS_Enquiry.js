import { LightningElement,track,api,wire } from 'lwc';
import getEnquiryDetails from '@salesforce/apex/Ind_EnquiryController.getEnquiryDetails';
import saveEnquiryDetails from '@salesforce/apex/Ind_EnquiryController.saveEnquiryDetails';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//import handshakeAPI from '@salesforce/apexContinuation/IntegrationEngine.handshakeAPI';
import serviceAPI from '@salesforce/apexContinuation/IntegrationEngine_Helper.serviceAPI';
import synergyReverseStatus from '@salesforce/apexContinuation/IntegrationEngine_Helper.synergyReverseStatus';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import createSynergyLoanApplication from '@salesforce/apex/LWC_LOS_HomePage_Cntrl.createSynergyLoanApplication';
import pleaseRetry from '@salesforce/label/c.Please_Retry';
import ENQUIRY_OBJECT from '@salesforce/schema/Enquiry__c';
import IS_SUBMITTED_FIELD from '@salesforce/schema/Enquiry__c.isSubmitted__c';
import getMakeList from '@salesforce/apex/IND_AssetDetailsCntrl.getMakeList';
import getRelatedModelList from '@salesforce/apex/IND_AssetDetailsCntrl.getRelatedModelList'; 
import getRelatedVariantList from '@salesforce/apex/IND_AssetDetailsCntrl.getRelatedVariantList';
import getMMVNameBasedOnCode from '@salesforce/apex/IND_AssetDetailsCntrl.getMMVNameBasedOnCode';
import getBranchesOfStateSynergy from '@salesforce/apex/iND_CustomLookup.getBranchesOfStateSynergy';
import RegEx_Number from '@salesforce/label/c.RegEx_Number';
import Mobile_Number_Error_Msg from '@salesforce/label/c.Mobile_Number_Error_Msg';
import Pan_Pattern from '@salesforce/label/c.Pan_Pattern';
const fields = [
    'Enquiry__c.isSubmitted__c',
];

export default class LWC_LOS_Enquiry extends NavigationMixin(LightningElement) {
    @api recordId;
    @track CustomerName;@track EnquiryNumber;@track journeyType;@track enquiryStatus;@track LeadReference;@track productCategory;@track LoanAmount;@track MobileNumber1;@track MobileNumber2;@track Source;@track CampaignType;@track Email;@track DealNo;@track CustomerCode;@track Product;@track PAN;@track CIFID;@track ReferredToBranch;@track Reason;@track Remarks;@track MakeCode;@track ModelCode;@track VariantCode;@track BlCode;
    @track makeOptionsList = [];
    @track isLoading = false;
    @track ReasonDisabled = true;
    @track CampaignTypeDisabled = true;
    @track SourceDisabled = true;
    @track isReasonRequired = false;
    @track makeOptionsList = [];
    @track modelOptionsList = [];
    @track variantOptionsList = [];
    @track makeCodeOfProduct;@track modelCodeOfProduct;@track variantCodeOfProduct;@track productType;@track make;@track model;@track variant;
    submitButtonDisabled = false;isTransferDisabled = false;EnquiryNumberDisabled = true;leadReferenceDisabled = true;CIFIDDisabled = true;ReferredToBranchDisabled = true;submitButtonVisible = true;phase1Enquiry = false;phase2Enquiry = false;
    convertToLeadButtonVisible = false;
    convertToLeadClicked = false;
    journeyTypeOptions = [];
    enquiryStatusOptions = [];
    productCategoryOptions = [];
    ReasonOptions = [];
    @track isSubmitted = false;
    @api label = {RegEx_Number,Mobile_Number_Error_Msg,Pan_Pattern};
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('isSubmitted value' + data.fields.isSubmitted__c.value);
            this.isSubmitted = data.fields.isSubmitted__c.value;
            this.disableFields();
        } else if (error) {
            console.log('error fetching the isSubmitted of Enquiry');
        }
    }
    showError(title, errorMessage) { 
        const evt = new ShowToastEvent({
            title: title,
            message: errorMessage,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
    showToast(title, message, variant){
        const toastevent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant

        });
        this.dispatchEvent(toastevent);
    }  
    get productTypeOptions() {
        return [
            { label: 'Passenger Vehicle', value: 'PV' },
            { label: 'Two Wheeler', value: 'TW' }
        ];
    }
    get branchValue() {
        return `${this.BlCode}-${this.ReferredToBranch}`;
    }
    @wire(getEnquiryDetails, { enquiryId: '$recordId' })
    wiredEnquiryDetails({ error, data }) {
        if (data) {
            this.CustomerName = data.Customer_Name__c;
            this.EnquiryNumber = data.Name;
            this.journeyType = data.Journey_Type__c;
            if (this.journeyType === 'Online – Customer journey') {
                this.phase2Enquiry = true;
                this.phase1Enquiry = false;
                console.log('Phase 2 Enquiry');
            }else if (this.journeyType === 'Offline – BE assisted journey') {
                this.phase1Enquiry = true;
                this.phase2Enquiry = false;
                console.log('Phase 1 Enquiry');
            }
            this.enquiryStatus = data.Enquiry_Status__c;
            if(this.enquiryStatus == 'Interested'){
                this.submitButtonVisible = false;
                this.convertToLeadButtonVisible = true;
                this.ReasonDisabled = true;
                this.Reason = null; // Reset the Reason field
                this.isReasonRequired = false; 
            }else if (this.enquiryStatus == 'Not Interested'){
                this.submitButtonVisible = true;
                this.convertToLeadButtonVisible = false;
                this.ReasonDisabled = false;
                this.isReasonRequired = true; 
            }
            this.LeadReference = data.Lead_Reference_ID__c;
            this.productCategory = data.Product_category__c;
            this.LoanAmount = data.Loan_amount__c;
            this.MobileNumber1 = data.Mobile_Number_1__c;
            this.MobileNumber2 = data.Mobile_Number_2__c;
            this.Source = data.Source__c;
            this.CampaignType = data.Campaign_Type__c;
            this.Email = data.Email__c;
            this.DealNo = data.Deal_No__c;
            this.CustomerCode = data.Customer_code__c;
            this.Product = data.Product__c;
            this.PAN = data.PAN_no__c;
            this.CIFID = data.CIF_ID__c;
            this.ReferredToBranch = data.Referred_to_Branch__c;
            this.Reason = data.Reason__c;
            this.Remarks = data.Remarks__c;
            this.MakeCode = data.Make_Code__c;
            this.ModelCode = data.Model_Code__c;
            this.VariantCode = data.Variant_Code__c;
            this.BlCode = data.Bl_Code__c
            if (this.Product && this.productCategory) {
                console.log('product value is' + this.Product);
                console.log('product Category value is' + this.productCategory);
                this.getMakeListForManualInput();
            }

            //calling the mmv method
            getMMVNameBasedOnCode({
                makeCode: this.MakeCode,
                modelCode: this.ModelCode,
                variantCode: this.VariantCode
            }).then(response => {
                let mmvResponse = JSON.parse(response);
    
                // Update MMV Fields with the MMV Name
                this.make = mmvResponse.vehicleMake;
                this.model = mmvResponse.vehicleModel;
                this.variant = mmvResponse.vehicleVarient;
                console.log('Make' + this.make);
                console.log('Model' + this.model);
                console.log('Variant' + this.variant);
    
                //Update Combobox fields
                if (this.make && this.model && this.variant) {
                    console.log('inside combox method');
                    // this.makeCodeOfProduct = this.make;
                    // this.modelCodeOfProduct = this.model;
                    // this.variantCodeOfProduct = this.variant;
                    console.log(' '+this.makeCodeOfProduct + ' ' + this.modelCodeOfProduct + ' ' +  this.variantCodeOfProduct);
                    //this.makeOptionsList = [{ label: this.make, value: this.makeCodeOfProduct }];
                    this.modelOptionsList = [{ label: this.model, value: this.modelCodeOfProduct }];
                    this.variantOptionsList = [{ label: this.variant, value: this.variantCodeOfProduct }];
                }
            
            }).catch(error => {
                console.log('Error - getMMVNameBasedOnCode: ', error);
            });




        } else if (error) {
            console.error('Error fetching Enquiry details:', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: 'Enquiry__c' })
    enquiryObjectInfo;
    @wire(getPicklistValues, { recordTypeId: '$enquiryObjectInfo.data.defaultRecordTypeId', fieldApiName: 'Enquiry__c.Journey_Type__c' })
    wiredPicklistValuesJourney({ error, data }) {
        if (data) {
            this.journeyTypeOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching Journey Category options:', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$enquiryObjectInfo.data.defaultRecordTypeId', fieldApiName: 'Enquiry__c.Enquiry_Status__c' })
    wiredPicklistValuesEnquiry({ error, data }) {
        if (data) {
            this.enquiryStatusOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching Enquiry Status options:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$enquiryObjectInfo.data.defaultRecordTypeId', fieldApiName: 'Enquiry__c.Product_category__c' })
    wiredPicklistValuesProduct({ error, data }) {
        if (data) {
            this.productCategoryOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching Product Category options:', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$enquiryObjectInfo.data.defaultRecordTypeId', fieldApiName: 'Enquiry__c.Reason__c' })
    wiredPicklistValuesReason({ error, data }) {
        if (data) {
            this.ReasonOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching Product Category options:', error);
        }
    }
    handleInputFieldChange(event) {
        const field = event.target.name;
        const previousValue = this[field];
        this[field] = event.target.value;
        if (field === 'CustomerNamefield') {
            this.CustomerName = event.target.value;}
        if (field === 'journeyTypefield') {
            this.journeyType = event.target.value;
            if (event.target.value === 'Online – Customer journey') {
                this.phase2Enquiry = true;
                this.phase1Enquiry = false;
                console.log('Phase 2 Enquiry');
            }else if (event.target.value === 'Offline – BE assisted journey') {
                this.phase1Enquiry = true;
                this.phase2Enquiry = false;
                console.log('Phase 1 Enquiry');
            }
        }
        if (field === 'enquiryStatusfield') {
            this.enquiryStatus = event.target.value;
            if (event.target.value === 'Interested') {
                    this.submitButtonVisible = false;
                    this.convertToLeadButtonVisible = true;
                    this.ReasonDisabled = true;
                    this.Reason = null;
                    this.isReasonRequired = false; 
            }else if (event.target.value === 'Not Interested') {
                this.submitButtonVisible = true;
                this.convertToLeadButtonVisible = false;
                this.ReasonDisabled = false;
                this.isReasonRequired = true; 
            }
        }
        if (field === 'productCategoryfield') {
            this.productCategory = event.target.value;}
        if (field === 'LoanAmountfield') {
            this.LoanAmount = event.target.value;}
        if (field === 'MobileNumber1field') {
            this.MobileNumber1 = event.target.value;}
        if (field === 'MobileNumber2field') {
            this.MobileNumber2 = event.target.value;}
        if (field === 'Sourcefield') {
            this.Source = event.target.value;}
        if (field === 'CampaignTypefield') {
            this.CampaignType = event.target.value;}
        if (field === 'Emailfield') {
            this.Email = event.target.value;}
        if (field === 'DealNofield') {
            this.DealNo = event.target.value;}
        if (field === 'CustomerCodefield') {
            this.CustomerCode = event.target.value;}
        if (field === 'Productfield') {
            this.Product = event.target.value;}
        if (field === 'PANfield') {
            this.PAN = event.target.value;}
        if (field === 'Reasonfield') {
            this.Reason = event.target.value;}
        if (field === 'Remarksfield') {
            this.Remarks = event.target.value;}
        if (field === 'Productfield' && this.Product !== previousValue) {
            this.getMakeListForManualInput();}    
        if (field === 'productCategoryfield' && this.productCategory !== previousValue) {
            this.getMakeListForManualInput();}    
    }
    handleSubmit(event) {
        //checking if all the mandatory fields are submitted or not
        if (!this.journeyType || !this.enquiryStatus || !this.productCategory || !this.CustomerName || (!this.Reason && this.isReasonRequired)) {
            this.showError('Please fill in all required fields.', pleaseRetry);
            return;
        }
        //checking the valid values in all the fields
        event.preventDefault();
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (!allValid) {
            this.showError('Please fill in all the fields in the required format.', pleaseRetry);
            return;
        } 
    this.isLoading = true;
    const enquiryData = {
        Id: this.recordId,
        Customer_Name__c: this.CustomerName,Journey_Type__c : this.journeyType,Enquiry_Status__c : this.enquiryStatus,Product_category__c : this.productCategory,Loan_amount__c : this.LoanAmount,Mobile_Number_1__c : this.MobileNumber1,Mobile_Number_2__c : this.MobileNumber2,Source__c : this.Source,Campaign_Type__c : this.CampaignType,Email__c : this.Email,Deal_No__c : this.DealNo,Customer_code__c : this.CustomerCode,Product__c : this.Product,PAN_no__c : this.PAN,Reason__c : this.Reason,Remarks__c : this.Remarks,Make_Code__c : this.MakeCode,Model_Code__c : this.ModelCode, Variant_Code__c : this.VariantCode      
    };

    const dataId = event.target.getAttribute('data-id');
    if (dataId === 'submitButton') {
        console.log('Submit clicked');        
    } else if (dataId === 'convertToLeadButton') {
        console.log('Convert to Lead clicked');         
        this.convertToLeadClicked = true;     
    }
    saveEnquiryDetails({ enquiryData })
        .then(result => {           
            this.showToast('Success', 'Enquiry Details saved successfully ', 'Success');

            //calling service API
                console.log('calling the Service API');
                serviceAPI({ 'loanAppId': this.recordId})
                .then(result => {
                    if(result =='Success'){
                        this.showToast('Success', 'Service API Success ', 'Success');
                        console.log('Service API Result:', result);

                        //start of reverse status API , this should run only when enquiry status in Not Interested
                        if(this.isReasonRequired){
                            console.log('calling the Reverse Status API');
                            synergyReverseStatus({ 'loanAppId': this.recordId})
                            .then(result => {
                                if(result =='Success'){
                                    this.showToast('Success', 'Update Reverse Status CRMNEXT Success ', 'Success');
                                    console.log('Update Reverse Status CRMNEXT Result:', result);
                                    //if convertToLead is not clicked then only update the isSubmitted
                                    if(!this.convertToLeadClicked){
                                        this.isSubmitted = true;
                                        this.disableFields();
                                        const fields = {};
                                        fields['Id'] = this.recordId;
                                        fields[IS_SUBMITTED_FIELD.fieldApiName] = true;
                                        const recordInput = { fields };
                                        updateRecord(recordInput)
                                            .then(() => {console.log('isSubmitted updated');
                                            })
                                            .catch(error => {console.log('failed to update isSubmitted' + JSON.stringify(error));
                                            });
                                    } 
                                }else if (result =='Error' || result == ''){
                                        this.showError('Update Reverse Status CRMNEXT failed', pleaseRetry);
                                    }
                                }).catch(error => {
                                    console.log('Update Reverse Status CRMNEXT failed', error);
                                    this.showError('Update Reverse Status CRMNEXT failed', pleaseRetry);
                                });
                        }
                        //end of reverse status API

                        //creating loan application only when service API is success and converted to lead is clicked
                        if(this.convertToLeadClicked){
                            createSynergyLoanApplication({
                                'customerName': this.CustomerName,
                                'mobile': this.MobileNumber1,
                                'productCategory': this.productCategory,
                                'loanAmount': this.LoanAmount,
                                'enquiryID': this.recordId
                            }).then(result => {console.log('converting to loan application');
                            this.isSubmitted = true;
                            this.disableFields();
                            const fields = {};
                            fields['Id'] = this.recordId;
                            fields[IS_SUBMITTED_FIELD.fieldApiName] = true;
                            const recordInput = { fields };
                            updateRecord(recordInput)
                                .then(() => {console.log('isSubmitted updated');
                                })
                                .catch(error => {console.log('failed to update isSubmitted' + JSON.stringify(error));
                                });
                            console.dir(result)
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result,
                                    objectApiName: 'Opportunity',
                                    actionName: 'view',
                                    }
                            });
                            }).catch(error => {
                                this.error = error;
                                console.log('Error in creating Loan Application: ',error);
                                });  
                        }
                        //end of creating loan application   
                           

                    }else if (result =='Error' || result == ''){
                        this.showError('Service API failed:', pleaseRetry);
                    }
    
                }).catch(error => {
                    console.log('Service API failed:', error);
                    this.showError('Service API failed:', pleaseRetry);
                })
                .finally(() => {
                    this.isLoading = false;
                });
            
            //service API end
        })
        .catch(error => {
            console.error('Error saving Enquiry details:', error);
            this.showError('Error saving Enquiry details:', pleaseRetry);
        })
        .finally(() => {
            this.submitButtonDisabled = false; // Re-enable the button
        });
}

    // Disable fields if isSubmitted is true
    disableFields() {
        if (this.isSubmitted) {
            console.log('disabling all the fields');
            const inputs = this.template.querySelectorAll('lightning-input');
            inputs.forEach(input => {
                input.disabled = true;
            });
            const comboboxes = this.template.querySelectorAll('lightning-combobox');
            comboboxes.forEach(combobox => {
            combobox.disabled = true;
            });
            const buttons = this.template.querySelectorAll('button');
            buttons.forEach(button => {
            button.disabled = true;
            });
            this.submitButtonDisabled = true;
            this.isTransferDisabled = true;
        }
    }
    get makeOptions() {
        return this.makeOptionsList;
    }
    get modelOptions() {
        return this.modelOptionsList;
    }

    get variantOptions() {
        return this.variantOptionsList;
    }    
    async getMakeListForManualInput() {
        console.log('sProductType_1_' + this.Product);
        console.log('vehicleType___1' + this.productCategory);
        this.modelOptionsList = '';
        this.variantOptionsList = '';
        this.productType = this.Product;
        if (this.Product === 'PV') {
            this.productType = 'PASSENGER VEHICLE';
        } else if (this.Product === 'TW') {
            this.productType = 'TWO WHEELER';
        }
        await getMakeList({ sProductType: this.productType, vehicleType: this.productCategory })
            .then(response => {
                console.log('getMakeList--', response);
                this.makeOptionsList = response;
                this.makeCodeOfProduct = ''; 
                console.log('make code is +' + this.makeCodeOfProduct);
            })
            .catch(error => {
                console.log('Error in getting Make:: ', error);
            });
    }
    
    async handleMakeSelection(event) {
        console.log('make has been selected' +  this.makeCodeOfProduct);
        this.makeCodeOfProduct = event.target.value;
        this.MakeCode = event.target.value;
        await this.getModelListForManualInput();
    }
    
    async getModelListForManualInput() {
        console.log('this.makeCodeOfProduct--', this.makeCodeOfProduct);
        console.log('this.vehicleType--', this.productCategory);
        console.log('this.product--', this.productType);
        // Check if a Make value is selected
        if (this.makeCodeOfProduct) {
            await getRelatedModelList({ sMake: this.makeCodeOfProduct, vehicleType: this.productCategory, productType: this.productType })
                .then(response => {
                    console.log('getModelList--', response);
                    this.modelOptionsList = response;
                })
                .catch(error => {
                    console.log('Error in getting related Model:: ', error);
                    console.log('Error in getting related Model2:: ', error.body.message);
                });
        }
    }
    
    async handleModelSelection(event) {
        this.modelCodeOfProduct = event.target.value;
        this.ModelCode = event.target.value;
        await this.getVariantListForManualInput();
    }
    async handleVariantSelection(event) {
        this.VariantCode = event.target.value;
    }
    
    async getVariantListForManualInput() {
        // Check if a Model value is selected
        if (this.modelCodeOfProduct) {
            await getRelatedVariantList({ sModel: this.modelCodeOfProduct, vehicleType: this.productCategory })
                .then(response => {
                    console.log('getVariantList--', response);
                    this.variantOptionsList = response.map(function(obj) {
                        return { label: obj.Name, value: obj.Variant_Code__c };
                    });
                })
                .catch(error => {
                    console.log('Error in getting related Variant:: ', error);
                });
        }
    }



    //Transfer Enquiry
    agentbl = '001Bi00000CkLLxIAN';
    opprecordid = '006Bi000009kTppIAE';
    typeofproduct = 'Passenger Vehicles';
    vehicleType = 'Used';
    isModalOpen;
    selectedState;
    isStateSelected;
    state_Filter_Field=[];
    branchOptions;
    selectedBranch;
    @track selectedrecordName;
    @track selectedRecordId;

    openModal()
    {//CISP:2861 If agent brach code is null then dont show th pop up , show error
        console.log('The value of the agent BL code in lead transfter'+this.agentbl);
        this.typeofproduct = this.typeofproduct=='Two Wheeler' ? 'TW' : 'PV';
        console.log('OUTPUT typeofproduct: ',this.typeofproduct);
        //this.agentbl = 'ULV';
        if(this.agentbl)
        {
            this.isModalOpen = true;
            this.flag = true; 
        }
        else{
            const evt = new ShowToastEvent({
                variant: 'error',mode: 'sticky', message:'Please enter the branch code first'});
            this.dispatchEvent(evt);
        }
       
    }
    closeModal() {
        this.isStateSelected = false;
        this.selectedType = '';
        this.selectedState = '';
        this.selectedBranch = '';
        this.branchOptions = [];
        if(this.template.querySelectorAll('c-generic-custom-lookup')){
            this.template.querySelectorAll('c-generic-custom-lookup').forEach(element => {
                element.clearRecords();
                element.clearSearchTerm();
            });
        }
        this.isModalOpen = false;
    }
    selectedStateHandler(event) {
        this.isStateSelected = true;
        this.selectedState = event.detail.selectedValueName;
        console.log('selected state: ',this.selectedState);
        console.log('typeofproduct' + this.typeofproduct); 
        console.log('record id' + this.opprecordid);
          // CISP-3497
          //SELECT Id, State__c(TELANGANA),Name ,Type(PV),Product_type__c(Used) FROM Account
          getBranchesOfStateSynergy({State:this.selectedState,productType:this.typeofproduct, vehicleType:this.vehicleType}).then(result => {
            let lstOption = [];
            for(let i=0 ; i<result.length; i++){
              //var rec =  result[i].Account;
              lstOption.push({value: result[i].Id,label: result[i].Name });
            }
               this.branchOptions = lstOption;
               console.log('branchOptions ',this.branchOptions);
        }).catch(error => {this.error = error;
            console.log('error ',error);
                });
            
    }
    clearStateHandler(event) {
        this.isStateSelected = false;
        this.selectedState = event.detail.selectedValueName;
        this.branchOptions=[];
        try {
            if(this.template.querySelectorAll('c-generic-custom-lookup')){
                this.template.querySelectorAll('c-generic-custom-lookup').forEach(element => {
                    element.clearRecords();
                    element.clearSearchTerm();
                });
            }
        } catch (error) {
            console.log(error);
        }
    }
    handleBranchChange(event) {
        this.selectedBranch = event.target.value;
        console.log('selected branch: ',this.selectedBranch)
    }
    onRecordSelection(event) {
        this.selectedrecordName = event.detail.selectedValue;
        console.log('The selected record name is '+ this.selectedrecordName)

        this.selectedRecordId = event.detail.selectedRecordId;
        console.log('The selected record name id is '+ this.selectedRecordId)

    }
    handleModalSubmit(event) {
        if(this.selectedState==null)
        {
            this.isLoading = true; 
            //this.showToast('Success', 'Update Reverse Status CRMNEXT Success ', 'Success');
            const evt = new ShowToastEvent({
               message:'Please select the State first!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }
        else if(this.selectedBranch==null)
        {
            this.isLoading = true; 
            const evt = new ShowToastEvent({
               message:'Please select the Branch first!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }
        else if(this.selectedRecordId==null)
        {
            this.isLoading = true; 
            const evt = new ShowToastEvent({
               message:'Please select the user first!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }

        else if(this.selectedRecordId !=null)
        {
        this.isLoading = true;
        this.isModalOpen = false;  
        const fields = {
            Id: this.recordId,
            OwnerId: this.selectedRecordId
        };
        const recordInput = { fields };     
        updateRecord(recordInput)
                .then(() => {
                    this.showToast('Success', 'Enquiry Owner Updated Successfully', 'Success');
                    //send SMS
                    //call handshake API
                    this.isLoading = false;
                })
                .catch(error => {
                    this.showError('Error updating the Enquiry Owner', pleaseRetry);
                    this.isLoading = false;
                    console.error('Error updating record:', error);
                });

        }
    this.isLoading = false;
}

// async triggerHandshake(){
//     try {
//         const response = await handshakeAPI({ 'loanAppId': this.recordId});
//         console.log('response is' + response);
//         let result = JSON.parse(response);
//         console.log('Handshake API Response:', result.response);
//     } catch (error) {
//         console.log('Handshake API Error:', error);
//         const toastEvent = new ShowToastEvent({
//             title: 'Error in getting details from Handshake API',
//             message: error?.body?.message || 'Unknown error',
//             variant: 'error',
//         });
//         this.dispatchEvent(toastEvent);
//     }

// }
        
}