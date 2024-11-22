import { LightningElement, track, wire, api } from 'lwc';    
import { loadStyle } from 'lightning/platformResourceLoader';   
import LightningCardApplyCSS from '@salesforce/resourceUrl/loanApplication';   
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord, getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi'; 
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import Business_Payment from '@salesforce/label/c.Business_Payment';
import Exception_Message from '@salesforce/label/c.ExceptionMessage';
import GetLoanDisbursementDetails from '@salesforce/apex/LoanDisbursementController.getLoanDisbursementDetails';
import getVehicleType from '@salesforce/apex/LoanDisbursementController.getVehicleType'; // CISP-2984
import GetPymntOrigFromDDValues from '@salesforce/apex/LoanDisbursementController.getPymntOrigFromDDValues';
import GetVehicleSoldBy from '@salesforce/apex/LoanDisbursementController.getVehicleSoldBy';
import GetBusinessUserIds from '@salesforce/apex/LoanDisbursementController.getBusinessUserIds';
import GetCollectionExecutiveDDValues from '@salesforce/apex/LoanDisbursementController.getCollectionExecutiveDDValues';
import getbussdoneby from '@salesforce/apex/LoanDisbursementController.getbussdoneby';
import GetEmptyBusinessPaymentWrapper from '@salesforce/apex/LoanDisbursementController.newBusinessPaymentWrapper';
import CheckBalanceTranserFieldAccessbility from '@salesforce/apex/LoanDisbursementController.CheckBalanceTranserFieldAccessbility';
import GetDoToBeAuthorizedByDDValues from '@salesforce/apex/LoanDisbursementController.getDoToBeAuthorizedByDDValues';
import SaveLoanAppTransactionHistory from '@salesforce/apex/LoanDisbursementController.saveLoanAppTransactionHistory';
import LoanApplicationId_Field from '@salesforce/schema/Opportunity.Id';
import DealNumberId from '@salesforce/schema/Deal_Number__c.Id';
import LoanApplicationStage_Field from '@salesforce/schema/Opportunity.StageName';
import LoanApplicationSubStage_Field from '@salesforce/schema/Opportunity.Sub_Stage__c';
import LoanDisbursement_OBJECT from '@salesforce/schema/LoanDisbursementDetails__c';
import LoanDisbursementId_Field from '@salesforce/schema/LoanDisbursementDetails__c.Id';
import PaymentOrgFrom_Field from '@salesforce/schema/LoanDisbursementDetails__c.Payment_Originated_From__c';
import VehicleSoldBy_Field from '@salesforce/schema/LoanDisbursementDetails__c.Vehicle_Sold_By__c';
import VehicleRegInName_Field from '@salesforce/schema/LoanDisbursementDetails__c.Vehicle_Registered_in_Name__c';
import BussSourceBy_Field from '@salesforce/schema/LoanDisbursementDetails__c.Business_Sourced_By__c';
import BussSourceBy_Name_Field from '@salesforce/schema/LoanDisbursementDetails__c.Business_Sourced_By__r.Name';
import BussDoneBy_Field from '@salesforce/schema/LoanDisbursementDetails__c.Business_Done_By__c';
import BussDoneBy_Name_Field from '@salesforce/schema/LoanDisbursementDetails__c.Business_Done_By__r.Name';
import FIDoneBy_Field from '@salesforce/schema/LoanDisbursementDetails__c.FI_Done_By__c';
import FIDoneBy_Name_Field from '@salesforce/schema/LoanDisbursementDetails__c.FI_Done_By__r.Name';
import ColleEx_Field from '@salesforce/schema/LoanDisbursementDetails__c.Collection_Executive__c';
import DoIssuance_Field from '@salesforce/schema/LoanDisbursementDetails__c.Do_Issuance__c';
import DoIssuanceMode_Field from '@salesforce/schema/LoanDisbursementDetails__c.Do_Issuance_Mode__c';
import ToBeAuthBy_Field from '@salesforce/schema/LoanDisbursementDetails__c.Do_To_be_authorized_by__c';
import BalTrans_Field from '@salesforce/schema/LoanDisbursementDetails__c.Balance_Transfer_Amount_in_Rs__c';
import PurDocCat_Field from '@salesforce/schema/LoanDisbursementDetails__c.Purchase_doc_catq__c';
import OrigPurValue_Field from '@salesforce/schema/LoanDisbursementDetails__c.Original_Purchase_value_in_Rs__c';
import OrigPurDateValue_Field from '@salesforce/schema/LoanDisbursementDetails__c.Original_purchase_date__c';
import FundEndUse_Field from '@salesforce/schema/LoanDisbursementDetails__c.Fund_End_Use__c';
import ParentLoanApp_Field from '@salesforce/schema/LoanDisbursementDetails__c.Parent_Loan_Application__c';
import CreatedDate_Field from '@salesforce/schema/LoanDisbursementDetails__c.CreatedDate';
import LoanNumber_Field from '@salesforce/schema/LoanDisbursementDetails__c.Loan_Number__c';//Duplicate_record
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import isRevokedLead from '@salesforce/apex/LoanDisbursementController.isRevokedLead';
import IsValidUser from '@salesforce/apex/LoanDisbursementController.isValidUser';
import LoanApplicationProdType_Field from '@salesforce/schema/Opportunity.Product_Type__c';
import getBussSourceBy from '@salesforce/apex/HandleJourney_Utility.getBussSourceBy';
import getBussDoneByID from '@salesforce/apex/HandleJourney_Utility.getBussDoneByID';
import GetBusinessUserIdsForPVProduct from '@salesforce/apex/LoanDisbursementController.GetBusinessUserIdsForPVProduct';//CISP-6283

import createCasePDAVRecords from '@salesforce/apex/LWCLOSAssetVerificationCntrl.createCasePDAVRecords';
import isRCUCaseClosed from '@salesforce/apex/RCUCaseController.isRCUCaseClosed';
import checkAssetVerificationStatus from '@salesforce/apex/LWCLOSAssetVerificationCntrl.checkAssetVerificationStatuspaymentScreen'; // SFTRAC-1194 starts
const OPPORTUNITY_FIELDS = [LoanApplicationStage_Field, LoanApplicationSubStage_Field, LoanApplicationProdType_Field];
const BusinessPaymentFields = [LoanDisbursementId_Field, PaymentOrgFrom_Field, VehicleSoldBy_Field, VehicleRegInName_Field, BussSourceBy_Field,
    BussSourceBy_Name_Field, BussDoneBy_Field, BussDoneBy_Name_Field, FIDoneBy_Field, FIDoneBy_Name_Field, ColleEx_Field, DoIssuance_Field, DoIssuanceMode_Field, ToBeAuthBy_Field,
    BalTrans_Field, PurDocCat_Field, OrigPurValue_Field, OrigPurDateValue_Field, FundEndUse_Field, ParentLoanApp_Field, CreatedDate_Field, LoanNumber_Field
];

import Tractor from '@salesforce/label/c.Tractor';

export default class IND_LWC_BusinessPayment extends NavigationMixin(LightningElement) {
    @api dealId = '';

    label = {
        Business_Payment,
        mandotoryDetailsNotProvide
    };

    @api disbursementrecordid;
    @api disablefields;

    @track assetCaseCreated = false;

    @track isEnableUploadViewDoc = true;
    @track isSpinnerMoving = false;
    @track paymentFromOrg;
    @track vehicleSoldBy;
    @track vehRegInNameOf;
    @track collectionExecutive;
    @track doIssuance;
    @track doIssuanceMode;
    @track doToBeAuthorizedBy;
    @track balanceTranser;
    @track purchaseDocCatq;
    @track originalPurchaseValue;
    @track originalPurchaseDate;
    @track fundEndUse;
    @track isEditableDoToBeAuthorize = false;
    @track isEditableVehicleSoldBy = false;
    @track isBalanceTransferFieldDisable = false;
    @track isPaymentShow = false;
    @track paymentOrgFromOptions = [
        { label: 'HUB', value: 'HUB' },
        { label: 'TA', value: 'TA' },
        { label: 'SO', value: 'SO' }
    ];
    @track businessSourcedById;
    @track businessSourcedByName;
    @track businessDoneById;
    @track businessDoneByName;
    @track fieldInvestigationById;
    @track fieldInvestigationByName;
    @track hasError = false;
    @track isUsedVehicle = false;
    @track isNewVehicle = false;
    @track disableOrigFields = false;
    @track tfdisableOrigFields = true;
    get getDisableOrigFields(){
        return this.disableOrigFields || (this.tfdisableOrigFields && this.isTractor);
    }
    @track bussDoneByFieldOptions = [];
    @track bussSourceByFieldOptions = [];

    @wire(GetEmptyBusinessPaymentWrapper) businessPaymentWrapper;

    @track collectionExecutiveOptions = [];
    @track leadSource;//Ola integration changes
    /************************************* 
            @Author:  Daksh Mandowara
            @ModifiedDate: 08/04/2022
            @UserStory:  Feature 10.2.1 - Business Payment
    
        @track paymentOrgHUBOptions = [
            { label: 'HUB', value: 'HUB' },
        ];
        @track paymentOrgHUBTAOptions = [
            { label: 'HUB', value: 'HUB' },
            { label: 'TA', value: 'TA' }
        ];
        @track paymentOrgSOOptions = [
            { label: 'SO', value: 'SO' }
        ];
        @track paymentOrgSOTAOptions = [
            { label: 'SO', value: 'SO' },
            { label: 'TA', value: 'TA' }
        ];
        *************************************/
    @track doIssuanceOptions = [];

    @track doIssuanModeeOptions = [
        { label: 'S: Separate', value: 'Separate' },
        { label: 'P: Along with payment', value: 'Along_with_payment' },
    ]

    @track doToBeAuthorizedByOptions = [];

    @track purchaseDocCatqOptions = [
        { label: 'Invoice', value: 'Invoice' },
        { label: 'Sale Agreement', value: 'Sale_Agreement' },
        { label: 'Not Available', value: 'Not_Available' }
    ];

    @track fundEndUseOptions = [
        { label: 'New Vehicle Margin Money', value: 'New_Vehicle_Margin_Money' },
        { label: 'Home Buying', value: 'Home_Buying' },
        { label: 'Marriage in Family', value: 'Marriage_in_Family' },
        { label: 'Market Borrowing', value: 'Market_Borrowing' },
        { label: 'Vehicle Repairs/ Tax', value: 'Vehicle_Repairs_Tax' },
        { label: 'Home Renovation', value: 'Home_Renovation' },
        { label: 'Medical Expenses', value: 'Medical_Expenses' },
        { label: 'Investment in Business', value: 'Investment _in_Business	' },
        { label: 'Loan Consolidation', value: 'Loan_Consolidation' },
        { label: 'Education Expenses', value: 'Education_Expenses' },
        { label: 'Purchase of used tractor', value: 'Purchase_of_used_tractor' },
    ];

    @api uploadViewDocFlag;
    @api recordid;
    @api applicantid;

    @api currentloanappstage;
    @api currentloanappsubstage;
    // CISP-4740 - STRAT
    @api frompostsanction = false;
    @track loanApplication;
    @track currentappstage;
    @track currentappsubstage;
isTractor = false; // SFTRAC - 147
    prodType;
    // CISP-4740 - END
    handleUploadViewDoc() {
            this.showUpload = true;
            this.showPhotoCopy = false;
            this.showDocView = true;
            this.isVehicleDoc = false;
            this.isAllDocType = true;
            this.uploadViewDocFlag = true;
        }
        //Wire the output of the out of the box method getRecord to the property newUsedVehicleInfo;
    // @wire(getRecord, { recordId: '$disbursementrecordid', fields: BusinessPaymentFields })
    // businessPaymentInfo({ error, data }) {
    //     if (error) {
    //         //Hide spinner
    //         this.isSpinnerMoving = false;

    //         let message = 'Unknown error';
    //         if (Array.isArray(error.body)) {
    //             message = error.body.map(e => e.message).join(', ');
    //         } else if (typeof error.body.message === 'string') {
    //             message = error.body.message;
    //         }
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error',
    //                 message: 'Error in Loading Business Payment details.',
    //                 variant: 'error',
    //             }),
    //         );
    //     } else if (data) {
    //         //Hide spinner
    //         this.isSpinnerMoving = false;
    //         console.debug(data);
    //         //alert(JSON.stringify(data));
    //         this.paymentFromOrg = data.fields.Payment_Originated_From__c.value;
    //         this.vehicleSoldBy = data.fields.Vehicle_Sold_By__c.value;
    //         this.vehRegInNameOf = data.fields.Vehicle_Registered_in_Name__c.value;
    //         this.bussSourcedBy = data.fields.Business_Sourced_By__r.displayValue;
    //         this.bussDoneBy = data.fields.Business_Done_By__r.displayValue;
    //         this.fiDoneBy = data.fields.FI_Done_By__r.displayValue;
    //         this.collectionExecutive = data.fields.Collection_Executive__c.value;
    //         this.doIssuance = data.fields.Do_Issuance__c.value;
    //         this.doIssuanceMode = data.fields.Do_Issuance_Mode__c.value;
    //         this.doToBeAuthorizedBy = data.fields.Do_To_be_authorized_by__c.value;
    //         this.balanceTranser = data.fields.Balance_Transfer_Amount_in_Rs__c.value;
    //         this.purchaseDocCatq = data.fields.Purchase_doc_catq__c.value;
    //         this.originalPurchaseValue = data.fields.Original_Purchase_value_in_Rs__c.value;
    //         this.originalPurchaseDate = data.fields.Original_purchase_date__c.value;
    //         this.fundEndUse = data.fields.Fund_End_Use__c.value;
    //     }
    // }

    @wire(getRecord, { recordId: '$recordid', fields: OPPORTUNITY_FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading loan application',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.loanApplication = data;
            console.debug(this.loanApplication);
            this.prodType = this.loanApplication.fields.Product_Type__c.value;

              //SFTRAC-147 starts
            console.log('this.prodType ',this.prodType);
            if(this.prodType == 'Tractor'){
                this.isTractor = true;
            }//SFTRAC-147 ends
            if (this.isTractor == false && this.loanApplication.fields.StageName && this.loanApplication.fields.Sub_Stage__c) {
                this.currentappstage = this.loanApplication.fields.StageName.value;
                this.currentappssubtage = this.loanApplication.fields.Sub_Stage__c.value;
            }
            if(this.isTractor){
                this.doIssuanceOptions = [
                    { label: 'Along with Payment', value: 'Along_with_Payment' },
                    { label: 'Already Issued', value: 'Already_Issued' },
                    { label: 'Separate', value: 'Separate' },
                    { label: 'Pre-delivered', value: 'Pre-delivered' }
                ];
            }else{
                this.doIssuanceOptions = [
                    { label: 'Along with Payment', value: 'Along_with_Payment' },
                    { label: 'Already Issued', value: 'Already_Issued' },
                    { label: 'Separate', value: 'Separate' }
                ];
            }
        }
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
    disableVehRegInName = true;//CISP-2983
    isRevokedLead;
    @track isPVProduct = false;
    @track disablefieldsforCVO = true;
    //SFTRAC-147 Starts
    @track pdavFlagValue = ''; 
    get pdavFlagoptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    handlePDAVFlagChange(event) {
        console.log('this.pdavFlagValue1 ', this.pdavFlagValue);
        this.pdavFlagValue = event.detail.value;
        console.log('this.pdavFlagValue ', this.pdavFlagValue);
        
    }
    //SFTRAC-147 Ends
    async connectedCallback() {
        await isRevokedLead({'loanApplicationId':this.recordid}).then(result=>{
            if(result){ this.isRevokedLead = true; }
        });
        await IsValidUser({ loanApplicationId: this.recordid })
            .then(response => {
                console.debug(response);
                if (response.profile.includes('CVO') && response.productType && response.productType == 'Passenger Vehicles' && this.currentappstage == 'Disbursement Request Preparation') {
                    this.disablefieldsforCVO = true;
                }else if(response.profile == "IBL Business Executive" && response.productType && response.productType == 'Passenger Vehicles' && this.currentappstage != 'Disbursement Request Preparation'){
                    this.disablefieldsforCVO = false;
                }else if(response.profile.includes('CVO') && response.productType && response.productType != 'Passenger Vehicles'){
                    this.disablefieldsforCVO = false;
                }
                this.isPVProduct = response.productType == 'Passenger Vehicles' ? true : false;
                console.log('isPVProduct : ',this.isPVProduct);
            })
            .catch(error => {
                console.error(error);
            });
        this.fundEndUseOptions.sort(this.compareName);
        console.debug(this.recordid);
        console.log('dthis.isbursementrecordid:', this.disbursementrecordid);
        await GetPymntOrigFromDDValues({ loanApplicationId: this.recordid, dealId: this.dealId })
            .then(response => {
                console.debug("GetPaymentDDValue : " + response)
                    /************************************* 
            
                    @Author:  Daksh Mandowara
                    @ModifiedDate: 08/04/2022
                    @UserStory:  Feature 10.2.1 - Business Payment
            
                    *************************************/
                    this.paymentOrgFromOptions = JSON.parse(response);
                    
                /*
                if(response=='SO_ONLY'){
                    this.paymentOrgFromOptions = this.paymentOrgSOOptions;
                }
                else if(response=='HUB_ONLY'){
                    this.paymentOrgFromOptions = this.paymentOrgHUBOptions;
                }
                else if(response=='HUB_TA_ONLY'){
                    this.paymentOrgFromOptions = this.paymentOrgHUBTAOptions;
                }
                else if(response=='SO_TA_ONLY'){
                    this.paymentOrgFromOptions = this.paymentOrgSOTAOptions;
                }
                */
                // End Changes by Daksh Mandowara
                console.log(this.disablefields);
                if (this.disablefields) {
                    this.isPaymentShow = true;
                } else {
                    this.isPaymentShow = false;
                }

            })
            .catch(error => {
                console.debug(error);
                this.tryCatchError = error.body.message;
                this.errorInCatch();
            });

        await GetVehicleSoldBy({ loanApplicationId: this.recordid, dealId: this.dealId })
            .then(response => {
                console.debug(response);
                if (response == 'EDITABLE_FIELD') {
                    this.isEditableVehicleSoldBy = false;
                } else if (response == 'DISABLE_FIELD') {
                    this.isEditableVehicleSoldBy = true;
                } else {
                    this.vehicleSoldBy = response;
                    this.isEditableVehicleSoldBy = true;
                }
            })
            .catch(error => {
                console.debug(error);
                this.tryCatchError = error.body.message;
                this.errorInCatch();
            });

        await GetCollectionExecutiveDDValues({ loanApplicationId: this.recordid })
            .then(response => {
                if (response != null) {
                    var res = JSON.parse(response);
                    if (res != null && res.length > 0) {
                        for (var i = 0; i < res.length; i++) {
                            this.collectionExecutiveOptions = [...this.collectionExecutiveOptions, { label: res[i].dlcode + ' | ' + res[i].excname, value: res[i].id }];
                        }
                    }
                }
            })
            .catch(error => {
                this.tryCatchError = error.body.message;
                this.errorInCatch();
            });

        await GetDoToBeAuthorizedByDDValues({ loanApplicationId: this.recordid })
            .then(response => {
                if (response != null) {
                    var res = JSON.parse(response);
                    console.debug(res);
                    if (res != null && res.length > 0) {
                        for (var i = 0; i < res.length; i++) {
                            this.doToBeAuthorizedByOptions = [...this.doToBeAuthorizedByOptions, { label: res[i].benCode + ' | ' + res[i].benName, value: res[i].id }];
                        }
                    }
                }
            })
            .catch(error => {
                this.tryCatchError = error.message.body;
                this.errorInCatch();
            });
            if(!this.isPVProduct){

        await GetBusinessUserIds({ loanApplicationId: this.recordid, dealId: this.dealId })
            .then(response => {
                if (response != null) {
                    var res = JSON.parse(response);
                    console.log('res' ,res);
                    if (res != null) {
                        for (var i = 0; i < res.length; i++) {
                            if (res[i].module.includes('Loan Details')) {
                                if(!this.businessSourcedByName){//CISP-13460 
                                    if(!this.businessSourcedById){this.businessSourcedById = res[i].id;}
                                    this.businessSourcedByName = res[i].name;
                                }
                            }  else if (res[i].module.includes('FI')) {
                                this.fieldInvestigationById = res[i].id;
                                this.fieldInvestigationByName = res[i].name;
                            }
                        }
                    }
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'No Details are available for Lead, Vehicle/Asset and FI.',
                            variant: 'error',
                        }),
                    );
                }
            })
            .catch(error => {
                this.tryCatchError = error.message.body;
                this.errorInCatch();
            });
        }
        if(this.isPVProduct){
            GetBusinessUserIdsForPVProduct({ loanApplicationId: this.recordid })
              .then(response => {
                if (response != null) {
                    var res = JSON.parse(response);
                    console.log('res' ,res);
                    if (res != null) {
                        for (var i = 0; i < res.length; i++) {
                            if (!this.businessSourcedByName && res[i].module.includes('Business Sourced By')) {
                                if(!this.businessSourcedById){this.businessSourcedById = res[i].id;}
                                this.businessSourcedByName = res[i].name;
                            }
                            if (!this.businessDoneByName && res[i].module.includes('Business Done By')) {
                                if(!this.businessDoneById){this.businessDoneById = res[i].id;}
                                this.businessDoneByName = res[i].name;
                            }
                            if (res[i].module.includes('FI')) {

                                this.fieldInvestigationById = res[i].id;
                                this.fieldInvestigationByName = res[i].name;
                            }
                        }
                    }
                }
              })
              .catch(error => {
                console.error('Error:', error);
            });
        }

            if(!this.isPVProduct){
                await getbussdoneby({loanApplicationId: this.recordid, dealId: this.dealId})
        .then(response => {
            if (response != null) {
                var res = JSON.parse(response);
                        console.log('OUTPUT :this.bussDoneByFieldOptions ',res);
                        
                        if (res != null) {
                            for (const [key, value] of Object.entries(res)) {
                                console.log(`${key}: ${value}`);
                        this.bussDoneByFieldOptions = [...this.bussDoneByFieldOptions, { label: value, value: key }];
                      }
                    /*for (var i = 0; i < res.length; i++) {
                        this.bussDoneByFieldOptions = [...this.bussDoneByFieldOptions, { label: res[i], value: res[i] }];
                    }*/
                
                }
            }
        }).catch(error => {
            this.tryCatchError = error.message.body;
            this.errorInCatch();
        });     
    }
    await getBussSourceBy({ loanApplicationId: this.recordid })
    .then(result => {
        console.log('Result', result);
        if(result != null){
            let res = JSON.parse(result);
            if(res != null){
                for(const [key, value] of Object.entries(res)){
                    this.bussSourceByFieldOptions = [... this.bussSourceByFieldOptions , {label : value , value : key}];
                }
            }
        }
    })
    .catch(error => {
        console.error('Error:', error);
        });
        if(this.isPVProduct){
            await getBussDoneByID({ loanApplicationId: this.recordid })
            .then(result => {
                console.log('Result', result);
                let res = JSON.parse(result);
                console.log('OUTPUT :this.bussDoneByFieldOptions ',res);
                    if (res != null) {
                        for (const [key, value] of Object.entries(res)) {
                            console.log(`${key}: ${value}`);
                            this.bussDoneByFieldOptions = [...this.bussDoneByFieldOptions, { label: value, value: key }];
                        }
                    }
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }
        await fetchLoanDetails({ opportunityId: this.recordid, dealId: this.dealId }).then(result => {
            if(result.loanApplicationDetails){
                this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
            }
        });//Ola Integration changes
        await GetLoanDisbursementDetails({ loanApplicationId: this.recordid, dealId: this.dealId })
            .then(response => {
                console.debug(response);
                if (response) {
                    this.disbursementrecordid = response.Id;
                    this.paymentFromOrg = response.Payment_Originated_From__c;
                    if (response.Vehicle_Sold_By__c) {
                        this.vehicleSoldBy = response.Vehicle_Sold_By__c;
                    }
                    this.vehRegInNameOf = response.Vehicle_Registered_in_Name__c;
                    // if(this.leadSource == 'DSA'){//CISP-13460
                    //     this.isPVProduct = false;
                    //     this.businessSourcedById = response.Business_Done_By__c ? response.Business_Done_By__r.Id : this.businessSourcedById;    
                    // }else{
                    this.businessSourcedById = response.Business_Sourced_By__c ? response.Business_Sourced_By__r.Id : this.businessSourcedById;
                // }//CISP-13460
                // if(this.leadSource == 'DSA'){//CISP-13460
                //     this.businessSourcedByName = response.Business_Done_By__c ? response.Business_Done_By__r.Name : this.businessSourcedByName;
                // }else{
                    this.businessSourcedByName = response.Business_Sourced_By__c ? response.Business_Sourced_By__r.Name : this.businessSourcedByName;
                // }//CISP-13460
                    this.businessDoneById = response.Business_Done_By__c ? response.Business_Done_By__r.Id : this.businessDoneById;
                    this.businessDoneByName = response.Business_Done_By__c ? response.Business_Done_By__r.Name :this.businessDoneByName;
                    this.fieldInvestigationById = response.FI_Done_By__c ? response.FI_Done_By__r.Id : '';
                    this.fieldInvestigationByName = response.FI_Done_By__c ? response.FI_Done_By__r.Name : '';
                    this.collectionExecutive = response.Collection_Executive__c;
                    this.doIssuance = response.Do_Issuance__c;
                    this.doIssuanceMode = response.Do_Issuance_Mode__c;
                    if (this.doIssuanceMode == 'Separate') {
                        this.isEditableDoToBeAuthorize = false;
                    } else {
                        this.isEditableDoToBeAuthorize = true;
                    }
                    this.doToBeAuthorizedBy = response.Do_To_be_authorized_by__c;
                    this.balanceTranser = response.Balance_Transfer_Amount_in_Rs__c;
                    this.purchaseDocCatq = response.Purchase_doc_catq__c;
                    this.originalPurchaseValue = response.Original_Purchase_value_in_Rs__c;
                    this.originalPurchaseDate = response.Original_purchase_date__c;
                    this.fundEndUse = response.Fund_End_Use__c;
                    this.pdavFlagValue = response.PDAV_Flag__c;
                    this.disableOrigFields = this.disablefields;
                    if(response.Parent_Loan_Application__r.Vehicle_Type__c != null){
                        if (response.Parent_Loan_Application__r.Vehicle_Type__c.includes('Used') || response.Parent_Loan_Application__r.Vehicle_Type__c.includes('Refinance')) {
                            this.isUsedVehicle = true;
                            this.isNewVehicle = false;
                        } else {
                            this.isUsedVehicle = false;
                            this.isNewVehicle = true;
                            this.disableOrigFields = true;
                        }
                        if(response.Parent_Loan_Application__r.Vehicle_Type__c.includes('Used') && this.isTractor){
                            this.tfdisableOrigFields = false;
                        }
                    }
                }
                // start CISP-2984
                else{
                    getVehicleType({ loanApplicationId: this.recordid })
                        .then(response=>{
                            console.debug('response in getVehicleType : '+ JSON.stringify(response));
                            if(response?.Vehicle_Type__c != null){
                                if (response.Vehicle_Type__c.includes('Used') || response.Vehicle_Type__c.includes('Refinance')) {
                                    this.isUsedVehicle = true;
                                    this.isNewVehicle = false;
                                } else {
                                    this.isUsedVehicle = false;
                                    this.isNewVehicle = true;
                                    this.disableOrigFields = true;
                                }

                                //CISP-2983
                                if(response.Vehicle_Type__c.includes('Used')){
                                    this.disableVehRegInName = false;
                                }else{
                                    this.disableVehRegInName = true;
                                    if(response?.Applicants__r?.[0].Name){ this.vehRegInNameOf = response.Applicants__r[0].Name; }
                                }
                                //CISP-2983
                            }
                        })
                        .catch(error=>{
                            this.tryCatchError = error.body.message;
                            this.errorInCatch();
                        });
                }// end CISP-2984
            })
            .catch(error => {
                this.tryCatchError = error.body.message;
                this.errorInCatch();
            });
        CheckBalanceTranserFieldAccessbility({ loanApplicationId: this.recordid, dealId : this.dealId })
            .then(response => {
                if (response != null) {
                    if (response == true) {
                        this.isBalanceTransferFieldDisable = false;
                    } else {
                        this.isBalanceTransferFieldDisable = true;
                    }
                }
            })
            .catch(error => {
                this.tryCatchError = error.message.body;
                this.errorInCatch();
            });
}
    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
        if (this.disablefields) {
            this.isPaymentShow = true;
            this.isEditableVehicleSoldBy = true;
            this.isEditableDoToBeAuthorize = true;
            this.isBalanceTransferFieldDisable = true;
        }
        if(this.leadSource=='OLA'){
            this.template.querySelector('[data-id="doIssuanceField"]').disabled = true;
        }
        if(this.isRevokedLead){
            this.template.querySelectorAll('*').forEach(element=>{
                element.disabled = true;
            });
        }
    }

    handleInputFieldChange(event) {
        const field = event.target.name;
        if (field == 'doIssuanceModeField') {
            this.doIssuanceMode = event.target.value;
            if (this.disablefields) {
                this.isEditableDoToBeAuthorize = true;
            } else {
                if (this.doIssuanceMode == 'Separate') {
                    this.isEditableDoToBeAuthorize = false;
                    this.doToBeAuthorizedBy = '';
                } else {
                    this.isEditableDoToBeAuthorize = true;
                    this.doToBeAuthorizedBy = '';
                }
            }
        }

        if (field === 'paymentOrgFromField') {
            this.paymentFromOrg = event.target.value;
        } else if (field === 'collectionExecutiveField') {
            this.collectionExecutive = event.target.value;
        } else if (field === 'doIssuanceField') {
            this.doIssuance = event.target.value;
        } else if (field === 'doToBeAuthorizeByField') {
            this.doToBeAuthorizedBy = event.target.value;
        } else if (field === 'purchaseDocCatqField') {
            this.purchaseDocCatq = event.target.value;
        } else if (field === 'fundEndUseField') {
            this.fundEndUse = event.target.value;
        } else if (field === 'bussDoneByField') {
            this.businessDoneById = event.target.value;
        }else if (field === 'bussSourcedByField'){
            this.businessSourcedById = event.target.value;
        }
    }

    async insertBusinessPaymentDetails(fields) {
        console.debug(fields);
        if (this.disbursementrecordid) {
            const recordInput = { fields };
            await updateRecord(recordInput)
                .then(response => {
// SFTRAC-147 - START
                    if(this.pdavFlagValue =='Yes' && this.isTractor == true){
                        if(this.assetCaseCreated == false){
                        this.assetCaseCreated = true;
                        createCasePDAVRecords({loanApplicationId : this.recordid,applicantId :this.applicantid,dealId:this.dealId}).then(result =>{
                            if(result == 'true'){
                                this.assetCaseCreated = true;
                                this.isSpinnerMoving = false;
                                this.hasError = false;
                                this.disbursementrecordid = response.id;
                                const dealNumberInfo = {};
                                dealNumberInfo[DealNumberId.fieldApiName] = this.dealId;
                                dealNumberInfo['Sub_Stage__c'] = 'Business Payment Details';
                                this.updateLoanApplicationDetails(dealNumberInfo);
                            }else{
                                this.assetCaseCreated = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'There are some error while Asset verification case creation.',
                                        variant: 'error'
                                    }),
                                );
                                this.isSpinnerMoving = false;
                            }
                        })
                        .catch(error =>{
                            this.assetCaseCreated = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'There are some error while Asset verification case creation.',
                                    variant: 'error'
                                }),
                            );
                            this.isSpinnerMoving = false;
                        })
                        }
                    }else{// SFTRAC-147 - End
                    //Hide spinner
                    this.isSpinnerMoving = false;
                    this.hasError = false;
                    const loanApplicationInfo = {};
                    const dealNumberInfo = {};
                    if(this.isTractor == false){
                    loanApplicationInfo[LoanApplicationId_Field.fieldApiName] = this.recordid;
                    loanApplicationInfo[LoanApplicationSubStage_Field.fieldApiName] = 'Business Payment Details';
                    }else if(this.isTractor == true){
                        dealNumberInfo[DealNumberId.fieldApiName] = this.dealId;
                        dealNumberInfo['Sub_Stage__c'] = 'Business Payment Details';
                    }
                    if(this.leadSource=='OLA'){
                        loanApplicationInfo[LoanApplicationSubStage_Field.fieldApiName] = 'Insurance Details';
                    }
                     // CISP-4770 - START
                    if(this.isTractor == true){
                        this.updateLoanApplicationDetails(dealNumberInfo);
                    }else{
                    if(!this.frompostsanction){
                        this.updateLoanApplicationDetails(loanApplicationInfo);
                    }else{
                        this.navigateToNextTab();
                        }
                    }
                    // CISP-4770 - END
                    // this.dispatchEvent(
                    //     new ShowToastEvent({
                    //         title: 'Success',
                    //         message: 'Business Payment details has saved successfully.',
                    //         variant: 'success'
                    //     }),
                    //     );
                    // this.navigateToNextTab();    
                    //this.saveLoanApplicationTransactionHistory(this.recordid,'Business Payments');
                    }
                })
                .catch(error => {
                    //Hide spinner
                    console.debug(error);
                    console.log(error);
                    this.isSpinnerMoving = false;
                    this.hasError = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'There are some error while saving Loan Application.',
                            variant: 'error'
                        }),
                    );
                });
        } else {
            const recordInput = { apiName: LoanDisbursement_OBJECT.objectApiName, fields };
            await createRecord(recordInput)
                .then(response => {
                    if(this.pdavFlagValue =='Yes' && this.isTractor == true){
                        createCasePDAVRecords({loanApplicationId : this.recordid,applicantId :this.applicantid,dealId:this.dealId}).then(result =>{
                            if(result == 'true'){
                                this.isSpinnerMoving = false;
                                this.hasError = false;
                                this.disbursementrecordid = response.id;
                                const dealNumberInfo = {};
                                dealNumberInfo[DealNumberId.fieldApiName] = this.dealId;
                                dealNumberInfo['Sub_Stage__c'] = 'Business Payment Details';
                                this.updateLoanApplicationDetails(dealNumberInfo);
                            }else{
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'There are some error while Asset verification case creation.',
                                        variant: 'error'
                                    }),
                                );
                                this.isSpinnerMoving = false;
                            }
                        })
                        .catch(error =>{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'There are some error while Asset verification case creation.',
                                    variant: 'error'
                                }),
                            );
                            this.isSpinnerMoving = false;
                        })
                    }else{
                    //Hide spinner
                    this.isSpinnerMoving = false;
                    this.hasError = false;
                    this.disbursementrecordid = response.id;
                    // if (this.currentloanappstage.includes('Disbursement Request Preparation') && this.currentloanappsubstage.includes('Payment Request') && !this.currentloanappsubstage.includes('Business Payment Details')) {
                        const loanApplicationInfo = {};
                        const dealNumberInfo = {};
                        if(this.isTractor == false){
                        loanApplicationInfo[LoanApplicationId_Field.fieldApiName] = this.recordid;
                        loanApplicationInfo[LoanApplicationSubStage_Field.fieldApiName] = 'Business Payment Details';
                        }else if(this.isTractor == true){
                            dealNumberInfo[DealNumberId.fieldApiName] = this.dealId;
                            dealNumberInfo['Sub_Stage__c'] = 'Business Payment Details';
                        }
                         // CISP-4770 - START
                        if(this.isTractor == true){
                            this.updateLoanApplicationDetails(dealNumberInfo);
                        }else{
                         if(!this.frompostsanction){
                            this.updateLoanApplicationDetails(loanApplicationInfo);
                        }else{
                            this.navigateToNextTab();
                            }
                        }
                         // CISP-4770 - END
                    // } else {
                    //     this.dispatchEvent(
                    //         new ShowToastEvent({
                    //             title: 'Success',
                    //             message: 'Business Payment details has saved successfully.',
                    //             variant: 'success'
                    //         }),
                    //     );
                    // }
                    //this.navigateToNextTab();    
                    //this.saveLoanApplicationTransactionHistory(this.recordid,'Business Payments');
                    }

                })
                .catch(error => {
                    //Hide spinner
                    this.isSpinnerMoving = false;
                    this.hasError = true;
                    console.debug(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'There are some error while saving Business Payment details.',
                            variant: 'error'
                        }),
                    );
                });
        }
        //Calling createRecord method of uiRecordApi

    }
    async updateLoanApplicationDetails(fields) {
        if(this.prodType == 'Tractor'){
        let response = await isRCUCaseClosed({'loanApplicationId' : this.recordid});
        if(response && response != 'Non-Tractor' && response == 'RCU-Case Not Closed'){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'RCU case is not closed!',
                    variant: 'warning'
                }),
            );
            return;
        }
        }
        const recordInput = { fields };
        console.debug(fields);
        //Calling createRecord method of uiRecordApi
        await updateRecord(recordInput)
            .then(response => {
                //Hide spinner
                this.isSpinnerMoving = false;
                this.saveLoanApplicationTransactionHistory(this.recordid, 'Business Payment');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Business Payment details has saved successfully.',
                        variant: 'success'
                    }),
                );
                this.navigateToNextTab();
            })
            .catch(error => {
                //Hide spinner
                console.log(error);
                this.isSpinnerMoving = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'There are some error while saving Loan Application.',
                        variant: 'error'
                    }),
                );
            });
    }

    async handleSubmit(event) {
        try {
            this.disablefields = true; //CISP-3104
            let paymentOrgField = this.template.querySelector('lightning-combobox[data-id=paymentOrgFromField]');
            paymentOrgField.reportValidity();
            let vehSoldByField = this.template.querySelector('lightning-input[data-id=vehicleSoldByField]');
            vehSoldByField.reportValidity();
            let vehRegNameField = this.template.querySelector('lightning-input[data-id=vehRegInNameOfField]');
            vehRegNameField.reportValidity();
            let bussSourcedByField;
            if(!this.isPVProduct){
            bussSourcedByField =
            this.template.querySelector('lightning-input[data-id=bussSourcedByField]');
        }else{
            bussSourcedByField = this.template.querySelector('lightning-combobox[data-id=bussSourcedByField]');
        }
            bussSourcedByField.reportValidity();
            let bussDoneByField = this.template.querySelector('lightning-combobox[data-id=bussDoneByField]');
            bussDoneByField.reportValidity();
            let fiDoneByField = this.template.querySelector('lightning-input[data-id=fiDoneByField]');
            fiDoneByField.reportValidity();
            let collnExecField = this.template.querySelector('lightning-combobox[data-id=collectionExecutiveField]');
            collnExecField.reportValidity();
            let doIssuanceField = this.template.querySelector('lightning-combobox[data-id=doIssuanceField]');
            doIssuanceField.reportValidity();
            let doIssuanceModeField = this.template.querySelector('lightning-radio-group[data-id=doIssuanceModeField]');
            doIssuanceModeField.reportValidity();
            let authByField = this.template.querySelector('lightning-combobox[data-id=doToBeAuthorizeByField]');
            authByField.reportValidity();
            let btField = this.template.querySelector('lightning-input[data-id=balanceTranserField]');
            btField.reportValidity();
            let purchaseDocField = this.template.querySelector('lightning-combobox[data-id=purchaseDocCatqField]');
            purchaseDocField.reportValidity();
            let fundUsedField = this.template.querySelector('lightning-combobox[data-id=fundEndUseField]');
            let pdavFlagFieldField = this.template.querySelector('lightning-combobox[data-id=pdavFlagField]');
            pdavFlagFieldField?.reportValidity();
            //Field only required if its a Used Vehicle
            if(this.isUsedVehicle)
                fundUsedField.reportValidity();
            let orgPurValue = this.template.querySelector('lightning-input[data-id=originalPurchaseValueField]');
            let orgPurDate = this.template.querySelector('lightning-input[data-id=originalPurchaseDateField]');
            const field = event.target.name;
            console.log('vehSoldByField:', vehSoldByField);
            let allFieldsValid = false;
            if (paymentOrgField.validity.valid && vehSoldByField.validity.valid && vehRegNameField.validity.valid &&
                bussSourcedByField.validity.valid && bussDoneByField.validity.valid && fiDoneByField.validity.valid &&
                collnExecField.validity.valid && doIssuanceField.validity.valid && doIssuanceModeField.validity.valid &&
                authByField.validity.valid && btField.validity.valid && purchaseDocField.validity.valid &&
                (fundUsedField.validity.valid || this.isNewVehicle)) {
                allFieldsValid = true;
            }
            if(this.isTractor && pdavFlagFieldField && pdavFlagFieldField.validity.valid == false){
                allFieldsValid = false;
            }
            console.debug(allFieldsValid);
            if (field === 'businessPaymentSubmit') {
                if (this.purchaseDocCatq === 'Invoice') {
                    orgPurValue.reportValidity();
                    orgPurDate.reportValidity();
                    //Fields only required if its a Used Vehicle
                    if (this.isUsedVehicle && (orgPurValue.validity.valid === false || orgPurDate.validity.valid === false)) {
                        allFieldsValid = false;
                        const evt = new ShowToastEvent({
                            title: "Error",
                            title: 'You cannot move unless you provide value for Original Purchase Value and Date.',
                            variant: 'error'
                        });
                        this.dispatchEvent(evt);
                        return;
                    }
                }
                console.debug(this.disbursementrecordid);
                if (allFieldsValid) {
                    const businessPaymentInfo = {};
                    if (this.disbursementrecordid) {
                        console.debug(this.disbursementrecordid);
                        businessPaymentInfo[LoanDisbursementId_Field.fieldApiName] = this.disbursementrecordid;
                    } else {
                        businessPaymentInfo[ParentLoanApp_Field.fieldApiName] = this.recordid;
                    }
                    if(this.dealId){
                        businessPaymentInfo[LoanNumber_Field.fieldApiName] = this.dealId; // Added Unique field to avoide  duplicate record creation 
                        businessPaymentInfo['Deal_Number__c'] = this.dealId; // Added Unique field to avoide  duplicate record creation 
                    }else{
                    businessPaymentInfo[LoanNumber_Field.fieldApiName] = this.recordid; // Added Unique field to avoide  duplicate record creation 
                    }
                    businessPaymentInfo[PaymentOrgFrom_Field.fieldApiName] = this.paymentFromOrg;
                    businessPaymentInfo[VehicleSoldBy_Field.fieldApiName] = this.template.querySelector('lightning-input[data-id=vehicleSoldByField]').value;
                    businessPaymentInfo[VehicleRegInName_Field.fieldApiName] = this.template.querySelector('lightning-input[data-id=vehRegInNameOfField]').value;
                    // if(this.leadSource == 'DSA'){//CISP-13460
                    //     businessPaymentInfo[BussSourceBy_Field.fieldApiName] = this.businessDoneById;  
                    //     }else{
                    businessPaymentInfo[BussSourceBy_Field.fieldApiName] = this.businessSourcedById; //'00571000000ML7RAAW';
                        // }//CISP-13460 
                    businessPaymentInfo[BussDoneBy_Field.fieldApiName] = this.businessDoneById; //'00571000000ML7RAAW';
                    businessPaymentInfo[FIDoneBy_Field.fieldApiName] = this.fieldInvestigationById; //'00571000000ML7RAAW';
                    businessPaymentInfo[ColleEx_Field.fieldApiName] = this.collectionExecutive;
                    businessPaymentInfo[DoIssuance_Field.fieldApiName] = this.doIssuance;
                    businessPaymentInfo[DoIssuanceMode_Field.fieldApiName] = this.doIssuanceMode;
                    businessPaymentInfo[ToBeAuthBy_Field.fieldApiName] = this.doToBeAuthorizedBy;
                    businessPaymentInfo[BalTrans_Field.fieldApiName] = this.template.querySelector('lightning-input[data-id=balanceTranserField]').value;
                    businessPaymentInfo[PurDocCat_Field.fieldApiName] = this.purchaseDocCatq;
                    businessPaymentInfo[OrigPurValue_Field.fieldApiName] = this.template.querySelector('lightning-input[data-id=originalPurchaseValueField]').value;
                    businessPaymentInfo[OrigPurDateValue_Field.fieldApiName] = new Date(this.template.querySelector('lightning-input[data-id=originalPurchaseDateField]').value);
                    businessPaymentInfo[FundEndUse_Field.fieldApiName] = this.fundEndUse;
                    if(this.isTractor){
                        businessPaymentInfo['PDAV_Flag__c'] = this.pdavFlagValue;
                    }
                    //alert(JSON.stringify(businessPaymentInfo));
                    this.isSpinnerMoving = true;
                    if(this.isTractor == true && this.isUsedVehicle == true){
                        let result1 = await checkAssetVerificationStatus({ 'loanApplicationId': this.recordid });
                        result1 = result1.trim();
                            if (result1 == 'Asset Verification Completed') {
                                console.log('Asset Verification Completed');
                                this.insertBusinessPaymentDetails(businessPaymentInfo);
                            } else {
                                console.log('Asset Verification InCompleted');
                                this.dispatchEvent(new ShowToastEvent({title: 'Error',message: 'Loan Application all Asset Verification is not completed ',variant: 'error'}),);
                                this.isSpinnerMoving = false;//UAT Observation by SF team
                            }
                    }else{
                        this.insertBusinessPaymentDetails(businessPaymentInfo);
                    }
                    // if(!this.hasError){
                    //     this.updateLoanApplicationDetails(loanApplicationInfo);
                    // }
                } else {
                    this.disablefields = false; //CISP-3104
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: this.label.mandotoryDetailsNotProvide,
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                }
            }
        } catch (err) {
            this.disablefields = false; //CISP-3104
            console.debug(err);
        }
    }

    saveLoanApplicationTransactionHistory(loanId, screen) {

        SaveLoanAppTransactionHistory({ loanAppId: loanId, screenName: screen, dealId: this.dealId })
            .then(response => {
                if (response) {} else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error in saving Loan Transaction History.',
                            variant: 'error'
                        }),
                    );
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    changeflagvalue() {
        this.uploadViewDocFlag = false;
    }

    navigateToNextTab() {
        this.dispatchEvent(
            new CustomEvent('successfullysubmitted'), {
                detail: this.disbursementrecordid
            }
        );
    }

    errorInCatch() {
        console.error(this.tryCatchError);
        const evt = new ShowToastEvent({
            title: "Error",
            message: Exception_Message,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }
}