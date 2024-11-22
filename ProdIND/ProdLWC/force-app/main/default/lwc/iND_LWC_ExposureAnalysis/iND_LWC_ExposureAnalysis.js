import { LightningElement, track, wire, api } from 'lwc';
import getRecordDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getRecordDetails';
import dedupeSubmitByCMU from '@salesforce/apex/Ind_CustomerDedupCtrl.dedupeSubmitByCMU';
import getExposureDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getExposureDetails';
import getFamilyExposureDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getFamilyExposureDetails';
import getLienDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getLienDetails';
import getBankExposureDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getBankExposureDetails';
import getAdditionalExposureDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getAdditionalExposureDetails';
import currentexposurelabel from '@salesforce/label/c.currentexposurelabel';
import ExistingBorrowerExposure from '@salesforce/label/c.ExistingBorrowerExposure';
import Existing_Beneficiary_Exposure_label from '@salesforce/label/c.Existing_Beneficiary_Exposure_label';
import Existing_Co_Borrower_Exposure from '@salesforce/label/c.Existing_Co_Borrower_Exposure';
import Existing_Other_Exposure from '@salesforce/label/c.Existing_Other_Exposure';
import Bank_Exposure from '@salesforce/label/c.Bank_Exposure';
import There_are_no_customer_code_for_exposure_callout from '@salesforce/label/c.There_are_no_customer_code_for_exposure_callout';
import Total_Exposure from '@salesforce/label/c.Total_Exposure';
import Cheque_Return from '@salesforce/label/c.Cheque_Return';
import Relationship_Since from '@salesforce/label/c.Relationship_Since';
import doCustomerExposureCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerExposureCallout';
import doCustomerNameSearchCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerNameSearchCallout';
//import loadCustomerCodeAdditionData from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.loadCustomerCodeAdditionData';
import getCustomerCodeDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getCustomerCodeDetails';
import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import Exposure_OBJECT from "@salesforce/schema/Exposure__c";
import CIF_ID_FIELD from "@salesforce/schema/Exposure__c.CIF_ID__c";
import Type_of_Facility_FIELD from "@salesforce/schema/Exposure__c.Type_of_Facility__c";
import Date_of_Sanction_FIELD from "@salesforce/schema/Exposure__c.Date_of_Sanction__c";
import Amount_Sanctioned_FIELD from "@salesforce/schema/Exposure__c.Sanctioned_Amt__c";
import Amount_Utilized_FIELD from "@salesforce/schema/Exposure__c.Amount_Utilized__c";
import pprButPenForDis_FIELD from "@salesforce/schema/Exposure__c.ApprButPenForDis__c";
import Applicant_ID from "@salesforce/schema/Exposure__c.Applicant__c";
import Customer_Code_Id from "@salesforce/schema/Exposure__c.Customer_Code__c";
import TYPE from "@salesforce/schema/Exposure__c.Type__c";
import EXPOSURE_ID from "@salesforce/schema/Exposure__c.Id"
import loanApplication_ID from "@salesforce/schema/Exposure__c.Loan_Application__c";
import CustomerCode_OBJECT from "@salesforce/schema/Customer_Code__c";
import getCustomerCodesExpAPI from "@salesforce/apex/IND_LWC_ExposureAnalysis.getCustomerCodesExpAPI";
import Customer_Code_loanId from "@salesforce/schema/Customer_Code__c.Loan_Application__c";
import Customer_Code_Code from "@salesforce/schema/Customer_Code__c.Name";
import Customer_Code_flag from "@salesforce/schema/Customer_Code__c.Flag__c";
import Customer_Code_Customer_Name from "@salesforce/schema/Customer_Code__c.Customer_Name__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from "lightning/platformResourceLoader";
import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";
import checkExposure from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.checkExposure';
import saveExposureAPITriggered from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.saveExposureAPITriggered'; //CISP-4656
import allCostCodeTrgExpAPI from '@salesforce/apex/IND_LWC_ExposureAnalysis.allCostCodeTrgExpAPI';
import getOpptyStage from '@salesforce/apex/IND_LWC_ExposureAnalysis.getOpptyStage';
import getOpptyStageCAM from '@salesforce/apex/IND_LWC_ExposureAnalysis.getOpptyStageCAM';
import checkCustomerCodeDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.checkCustomerCodeDetails';
import deletecustCodes from '@salesforce/apex/IND_LWC_ExposureAnalysis.deletecustCodes';

import getExpRecords from '@salesforce/apex/IND_LWC_ExposureAnalysis.getExpRecords';
//Toast messages
import SuccessToastMsg from '@salesforce/label/c.SuccessToastMsg';
import ErrorToastMsg from '@salesforce/label/c.ErrorToastMsg';
import UpdateToastMsg from '@salesforce/label/c.UpdateToastMsg';
import UpdateErrorToastMsg from '@salesforce/label/c.UpdateErrorToastMsg';
import DeleteToastMsg from '@salesforce/label/c.DeleteToastMsg';
import DeleteErrorToastMsg from '@salesforce/label/c.DeleteErrorToastMsg';
import UnableToastMsg from '@salesforce/label/c.UnableToastMsg';
import ExistToastMsg from '@salesforce/label/c.ExistToastMsg';
import getFamilyExpCustCodes from '@salesforce/apex/IND_LWC_ExposureAnalysis.getFamilyExpCustCodes';

//navigation exposure analysis to next screen
import { NavigationMixin } from 'lightning/navigation';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import updateTotalExposureAmount from '@salesforce/apex/IND_LWC_ExposureAnalysis.updateTotalExposureAmount';//Enhancement for INDI-3470
import getApplicantInfo from '@salesforce/apex/IND_LWC_ExposureAnalysis.getApplicantInfo';//CISP-3447
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';//CISP-3938
// BORROWER EXPOSURE Table  
const columns_BorrowerExposure = [
    { label: 'Exposure Type', fieldName: 'Exposure_Type__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Deal Stage', fieldName: 'Deal_Stage__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Deal No', fieldName: 'Deal_No__c', hideDefaultActions: true, wrapText: true, },
    {
        label: 'Deal Date', fieldName: 'Deal_Date__c', hideDefaultActions: true, wrapText: true,
        cellAttributes: {
            style: 'word-break: break-all;',
        }
    },
    { label: 'Product', fieldName: 'Product__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Product Variant Name', fieldName: 'Product_Variant_Name__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Used', fieldName: 'Used__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Status Flag', fieldName: 'Status_Flag__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Finance Amount', fieldName: 'Finance_Amt__c', hideDefaultActions: true, wrapText: true, },
    { label: 'SOH', fieldName: 'SOH__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Over Due', fieldName: 'Over_Due__c', hideDefaultActions: true, wrapText: true, },
    { label: 'AD', fieldName: 'AD__c', hideDefaultActions: true, wrapText: true, },
    { label: 'PD', fieldName: 'PD__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Current Demand', fieldName: 'Current_Demand__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Mor 1', fieldName: 'Mor1__c', hideDefaultActions: true, wrapText: true, },
    { label: 'Mor 2', fieldName: 'Mor2__c', hideDefaultActions: true, wrapText: true, },
    {
        label: 'Lien Details', type: 'button',
        typeAttributes: {
            label: 'View', name: 'View', title: 'View', disabled: false,
            value: 'view', iconPosition: 'left'
        }
    }
];

// CO BORROWER EXPOSURE Table columns
const columns_coBorrowerExposure = [
    { label: 'Deal No', fieldName: 'Deal_No__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    {
        label: 'Deal Date', fieldName: 'Deal_Date__c', hideDefaultActions: true, wrapText: true,
        cellAttributes: {
            style: 'word-break: break-all;',
            alignment: 'right'
        }
    },
    { label: 'Product', fieldName: 'Product__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Used', fieldName: 'Used__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Status Flag', fieldName: 'Status_Flag__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Finanace Amount', fieldName: 'Finance_Amt__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'SOH', fieldName: 'SOH__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Over Due', fieldName: 'Over_Due__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'AD', fieldName: 'AD__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'PD', fieldName: 'PD__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Current Demand', fieldName: 'Current_Demand__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    {
        label: 'Lien Details', type: 'button',
        typeAttributes: { label: 'View', name: 'View', title: 'View', disabled: false, value: 'view', iconPosition: 'left' },
        cellAttributes: { alignment: 'right' }
    }

];

// GUARANTOR EXPOSURE Table columns SFTRAC-96 Added by Prashant Dixit start
const columns_GuarantorExposure = [
    { label: 'Deal No', fieldName: 'Deal_No__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    {
        label: 'Deal Date', fieldName: 'Deal_Date__c', hideDefaultActions: true, wrapText: true,
        cellAttributes: {
            style: 'word-break: break-all;',
            alignment: 'right'
        }
    },
    { label: 'Product', fieldName: 'Product__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Used', fieldName: 'Used__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Status Flag', fieldName: 'Status_Flag__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Finanace Amount', fieldName: 'Finance_Amt__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'SOH', fieldName: 'SOH__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Over Due', fieldName: 'Over_Due__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'AD', fieldName: 'AD__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'PD', fieldName: 'PD__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    { label: 'Current Demand', fieldName: 'Current_Demand__c', hideDefaultActions: true, wrapText: true, cellAttributes: { alignment: 'right' } },
    {
        label: 'Lien Details', type: 'button',
        typeAttributes: { label: 'View', name: 'View', title: 'View', disabled: false, value: 'view', iconPosition: 'left' },
        cellAttributes: { alignment: 'right' }
    }

];
// GUARANTOR EXPOSURE Table columns SFTRAC-96 Added by Prashant Dixit end

// Family Exposure Table columns
const columns_familyExposure = [
    { label: 'Deal No', fieldName: 'Deal_No__c', hideDefaultActions: true, wrapText: true },
    { label: 'Deal Date', fieldName: 'Deal_Date__c', hideDefaultActions: true, wrapText: true },
    { label: 'Product', fieldName: 'Product__c', hideDefaultActions: true, wrapText: true },
    { label: 'Variant', fieldName: 'Product_Variant_Name__c', hideDefaultActions: true, wrapText: true },
    { label: 'Used', fieldName: 'Used__c', hideDefaultActions: true, wrapText: true },
    { label: 'Status Flag', fieldName: 'Status_Flag__c', hideDefaultActions: true, wrapText: true },
    { label: 'Finanace Amount', fieldName: 'Finance_Amt__c', hideDefaultActions: true, wrapText: true },
    { label: 'Agreement Amount', fieldName: 'Agreement_amount__c', hideDefaultActions: true, wrapText: true },
    { label: 'Mfg Yr', fieldName: 'Manufacture_Date__c', hideDefaultActions: true, wrapText: true },
    { label: 'SOH', fieldName: 'SOH__c', hideDefaultActions: true, wrapText: true },
    { label: 'Over Due', fieldName: 'Over_Due__c', hideDefaultActions: true, wrapText: true },
    { label: 'IBL Seasoning', fieldName: 'IB_Seasoning__c', hideDefaultActions: true, wrapText: true },
    { label: 'AD', fieldName: 'AD__c', hideDefaultActions: true, wrapText: true },
    { label: 'PD', fieldName: 'PD__c', hideDefaultActions: true, wrapText: true },
    { label: 'Amount Paid', fieldName: 'Amount_Paid__c', hideDefaultActions: true, wrapText: true }
]; 	

// Lien Details Table columns
const columns_LienDetls = [
    { label: 'Lien No', fieldName: 'Name', hideDefaultActions: true, wrapText: true },
    { label: 'Lien Type', fieldName: 'Lien_Type__c', hideDefaultActions: true, wrapText: true },
    { label: 'Source Deal No', fieldName: 'Source_Deal_No__c', hideDefaultActions: true, wrapText: true },
    { label: 'Lien Marking Period', fieldName: 'Lien_Marking_Period__c', hideDefaultActions: true, wrapText: true },
    { label: 'Lien Marker Date ', fieldName: 'Lien_Maker_Date__c', hideDefaultActions: true, wrapText: true },
    { label: 'Lien Request By ', fieldName: 'Lien_Request_By__c', hideDefaultActions: true, wrapText: true },
    { label: 'Lien Marking Reasons', fieldName: 'Lien_Marking_Reason__c', hideDefaultActions: true, wrapText: true }
];

// Addition customer Exposure Table columns
const columns_customerExposure = [
    { label: 'Deal No', fieldName: 'Deal_No__c', hideDefaultActions: true, wrapText: true ,cellAttributes: { class: { fieldName: 'DealNoColor' }}},
    {
        label: 'Deal Date', fieldName: 'Deal_Date__c', hideDefaultActions: true, wrapText: true,
        cellAttributes: {
             class: { fieldName: 'DealNoColor' },
            style: 'word-break: break-all;'
        }
    },
    { label: 'Product', fieldName: 'Product__c', hideDefaultActions: true, wrapText: true, cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'Used', fieldName: 'Used__c', hideDefaultActions: true, wrapText: true,cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'Status Flag', fieldName: 'Status_Flag__c', hideDefaultActions: true, wrapText: true,cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'Finanace Amount', fieldName: 'Finance_Amt__c', hideDefaultActions: true, wrapText: true,cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'SOH', fieldName: 'SOH__c', hideDefaultActions: true, wrapText: true,cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'Over Due', fieldName: 'Over_Due__c', hideDefaultActions: true, wrapText: true,cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'AD', fieldName: 'AD__c', hideDefaultActions: true, wrapText: true,cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'PD', fieldName: 'PD__c', hideDefaultActions: true, wrapText: true,cellAttributes: { class: { fieldName: 'DealNoColor' }} },
    { label: 'Current Demand', fieldName: 'Current_Demand__c', hideDefaultActions: true, wrapText: true ,cellAttributes: { class: { fieldName: 'DealNoColor' }}},
    {
        label: 'Lien Details', type: 'button',
        typeAttributes: { label: 'View', name: 'View', title: 'View', disabled: false, value: 'view', iconPosition: 'left' }
    }
];

// Bank Exposure Table columns
const columns_bankExposure = [
    { label: 'CIF ID', fieldName: 'CIF_ID__c', hideDefaultActions: true, wrapText: true },
    { label: 'Type of Facility', fieldName: 'Type_of_Facility__c', hideDefaultActions: true, wrapText: true },
    { label: 'Date of Sanction', fieldName: 'Date_of_Sanction__c', hideDefaultActions: true, wrapText: true },
    { label: 'Amount Sanctioned', fieldName: 'Sanctioned_Amt__c', hideDefaultActions: true, wrapText: true },
    { label: 'Amount Utilized', fieldName: 'Amount_Utilized__c', hideDefaultActions: true, wrapText: true },
    { label: 'Approved But Pending For Disbursement', fieldName: 'ApprButPenForDis__c', hideDefaultActions: true, wrapText: true },
    {
        label: 'Edit', type: 'button',
        typeAttributes: { label: 'Edit', name: 'editbankexposure', title: 'editbankexposure', disabled: false, value: 'Edit', iconPosition: 'left' }
    },
    {
        label: 'Delete', type: 'button',
        typeAttributes: { label: 'Delete', name: 'deleteBankExposure', title: 'deleteBankExposure', disabled: false, value: 'deleteBankExposure', iconPosition: 'left' }
    }
];

// Additional Customer code Table columns
const columns_customerCode = [
    { label: 'Customer Code', fieldName: 'Name', hideDefaultActions: true, wrapText: true },
    { label: 'Name', fieldName: 'Customer_Name__c', hideDefaultActions: true, wrapText: true },
    {
        label: 'Action', type: 'button',
        typeAttributes: { label: 'X', name: 'DeleteCustCode', title: 'X', disabled: false, value: 'DeleteCustCode', iconPosition: 'left' }
    }
];


export default class ExposureAnalysis extends LightningElement {
    isPanAvailableForBorrower = false;isPanAvailableForCoBorrower = false;
    activeSections = ['A', 'B', 'C'];
    activeSectionsMessage = '';
    //@track familyExposureWrap ={};
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    @api recordId // = '00671000001Kkqv';
    //@track heading = 'CO BORROWER EXPOSURE';
    @api exposureId; //= 'a1F710000000zTJEAY'; 
    @track dealNumber = '';
    @track dataBorrowerExposure;
    @track datacoBorrowerExposure;
    @track datafamilyExposure;
    @track dataLienDetails;
    @track datacustomerExposure;
    @track databankExposure;
    @track datacustomerCode;
    @track errormessage;
    @track confirmation;
    coBorrowerFoir;averageFoir;borrowerFoir;pvProductType; 
    isPersonalPurpose = false; //CISP-4486

    @track columns_BorrowerExposure = columns_BorrowerExposure;
    @track columns_coBorrowerExposure = columns_coBorrowerExposure;
    @track columns_familyExposure = columns_familyExposure;

    @track columns_LienDetls = columns_LienDetls;
    @track columns_customerExposure = columns_customerExposure;
    @track columns_bankExposure = columns_bankExposure;
    @track columns_customerCode = columns_customerCode;
    @track _dc
    @track databankExposureData;

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track isModalOpenLien = false;
    @track isModalAdditionalExp = false;
    @track isModalBankExposure = false;
    @track hasRecordsCustomerCode = false;
    @track hasExposureData = false;
    @track hasBorrowerExposure = false;
    @track hascoBorrowerExposure = false;
    @track hascustomerExposure = false;
    @track hasLienDetails = false;
    @track hasfamilyExposure = false;
    @track disableSubmit = true;
    @track isLoading = true;
    @track stageValue = [];
    @track disableActionsPostSubmit = true;
    @track familyExpsureApexRefresh;
    @track exposureApexRefresh;
    @track disableSubmitBtn;
    @track sortBy ;
    @track savetotalExpAmt = false; //Enhancement for INDI-3470
    _wiredResult;

    CIF_ID__c;
    Type_of_Facility__c;
    Date_of_Sanction__c;
    Sanctioned_Amt__c;
    Amount_Utilized__c;
    ApprButPenForDis__c;


    @track CustomerCodeVal;
    @track familyExpDetails = [];
    @track additionalExpDetails = [];
    @track keyAdd;
    @track appBorCustomerCode= '';//CISP-3447
    @track isDedupeSubmit = false;//CISP-3447
    @track isCoBorrowerExsist = false; //CISP-3447
    @track appCoBorCustomerCode = '';//CISP-3447
    @track applicantsList;

    label = {
        currentexposurelabel,
        ExistingBorrowerExposure,
        Existing_Beneficiary_Exposure_label,
        Existing_Co_Borrower_Exposure,
        Existing_Other_Exposure,
        Bank_Exposure,
        Total_Exposure,
        Cheque_Return,
        Relationship_Since,
        There_are_no_customer_code_for_exposure_callout
    };
    @track formdata = {};
    @track isExposureApiRun = false;//CISP-4656
    borrowerCodeValidateByCMU = false;//CISP-6452
    coborrowerCodeValidateByCMU = false;//CISP-6452
    @track leadSource;  

    //Added by Prashant Dixit : SFTRAC-96
    @track columns_GuarantorExposure = columns_GuarantorExposure;
    @track hasGuarantorExposure = false;
    @track dataGuarantorExposure;
    @track isProductTypeTractor = false;

    @wire(getCustomerCodeDetails, { oppId: '$recordId' })
    wiredGetCustomerCodeDetails(result) {
        this._dc = result;
        if (result.data) {
            this.datacustomerCode = this._dc.data;
            this.hasRecordsCustomerCode = (this._dc.data.length > 0) ? true : false;

        }
        else if (result.error) {
            this.datacustomerCode = undefined;
        }

    }
    //wiring the apex method to a function 
    @wire(getExposureDetails, { oppId: '$recordId' })
    wiredExposureData({ error, data }) {
        this.exposureApexRefresh = data;
        this._wiredResult = data;

        this.isLoading = false;
        //Check if data exists 
        // this.disableActionsPostSubmit = undefined;
        //  console.log('Stage in 291 : ', data)
        if (data) {
            console.log(' wireExposure :' + data);

            console.log(' wireExposure :' + data.substage);
            // if (data.substage != 'Exposure Analysis') {
            //     this.disableActionsPostSubmit = true;
            // } else {
            //     this.disableActionsPostSubmit = false;
            // }

            this.currentExposureAmount = this.exposureApexRefresh.currentExposureAmount
            this.bankExposureAmount = this.exposureApexRefresh.bankExposureAmount
            this.totalExposureAmount = this.exposureApexRefresh.totalExposureAmount
            this.chequeReturn = this.exposureApexRefresh.chequeReturn
            this.relationshipSince = this.exposureApexRefresh.relationshipSince
            // this.relationshipSince = data.relationshipSince
            this.existingBorrowerExposureAmount = this.exposureApexRefresh.existingBorrowerExposureAmount
            this.existingCoBorrowerExposureAmount = this.exposureApexRefresh.existingCoBorrowerExposureAmount
            this.existingOtherExposureAmount = this.exposureApexRefresh.existingOtherExposureAmount
            this.dataBorrowerExposure = this.exposureApexRefresh.lstBorExposureDetails;
            console.log('dataBorrowerExposure',this.dataBorrowerExposure);
            this.datacoBorrowerExposure = this.exposureApexRefresh.lstCoBorExposureDetails;
            console.log('datacoBorrowerExposure : ',this.datacoBorrowerExposure);
            this.dataGuarantorExposure = this.exposureApexRefresh.lstGuarantorExposureDetails;//Added for Guarantor by Prashant Dixit : SFTRAC-96
            this.datacustomerExposure = this.exposureApexRefresh.lstAdditionalExposureDetails;
            console.log('this.datacustomerExposure : ', this.datacustomerExposure);
            this.hasBorrowerExposure = (data.lstBorExposureDetails.length > 0) ? true : false;
            this.hascoBorrowerExposure = (data.lstCoBorExposureDetails.length > 0) ? true : false;
            //Added for Guarantor by Prashant Dixit : SFTRAC-96 start
            this.hasGuarantorExposure = (data.lstGuarantorExposureDetails.length > 0) ? true : false;
            this.isProductTypeTractor = (data.loanAppProductType == 'Tractor') ? true : false;
            Promise.resolve().then(() => 
                 this.activeSections = [...this.activeSections, 'D']
            );
            //Added for Guarantor by Prashant Dixit : SFTRAC-96 end
            this.hascustomerExposure = (data.lstAdditionalExposureDetails.length > 0) ? true : false;
            if(this.savetotalExpAmt == false){
                updateTotalExposureAmount({ loanApplicationId: this.recordId,exposureWrapperData:this.exposureApexRefresh })//Enhancement for INDI-3470 // CISP-1120
                .then(result => {
                    this.savetotalExpAmt = true;
                }).catch(error => {
                    console.error('error::', error);
                });
            }

        } else if (error) {
            // eslint-disable-next-line no-console
            console.log(error);
        } else {
            // eslint-disable-next-line no-console
            console.log('unknown error')
        }
        // console.log(' wireExposure330 :' + this.disableActionsPostSubmit);
        //this.disableActionsPostSubmit =false;

    }

    // Family exposure details
    // @wire(getFamilyExposureDetails, { oppId: '$recordId' })
    // wiredFamilyExposureData({ error, data }) {
    //     this.familyExpsureApexRefresh = data;
    //     if (data) {
    //         this.datafamilyExposure = this.familyExpsureApexRefresh;
    //         this.hasfamilyExposure = (data.length>0)?true:false;
    //     }
    // }
    @wire(getAdditionalExposureDetails, { oppId: '$recordId' })
    wiredAdditionalExposureDetails({ error, data }) {
        this.sortBy = columns_customerExposure.Status_Flag__c;
        
        if(data){
            console.log('data 382==>',data);
            for (let key in data) {
                if(data[key]!=''){
                    let res = data[key];
                    console.log('res==>',res);
                    this.tableData = res.map(ele=>{
                        console.log('ele=>',ele);
                        
                        let DealNoColor = ele.Status_Flag__c== "Z" ? "slds-text-color_error":""
                        console.log(DealNoColor);
                        return {...ele, 
                            "DealNoColor": DealNoColor
                        }
                    });
                   console.log('tableData',this.tableData);

                    this.additionalExpDetails.push({ value: this.tableData, key: key });


                }else{
                    this.additionalExpDetails.push({ value: false, key: key });
                }
            }
            console.log('this.additionalExpDetails : ', this.additionalExpDetails);
        }if(error){
            console.log('error 387-->',error);
        }
        
    }    
    // Lien details
    @wire(getLienDetails, { expId: '$exposureId' })
    wiredLienDetailsData({ error, data }) {
        if (data) {
            this.dataLienDetails = data;
        }
    }

    //bank exposure details

    @wire(getBankExposureDetails, { oppId: '$recordId' })
    wiredBankExposureDetailsData(result) {
        this.databankExposure = result;

        if (result.data) {
            this.hasExposureData = (this.databankExposure.data.length > 0) ? true : false
            this.databankExposureData = this.databankExposure.data;

        }
        else if (result.error) {
            this.databankExposureData = undefined;
        }

    }
    //field change handler  
    changeHandler(event) {
        if (event.target.name)
            this.formdata[event.target.name] = event.target.value

        this.handleChange(event)
    }

    handleChange(e) {
        if (e.target.name === "CIF_ID__c") {
            this.CIF_ID__c = e.target.value;
        } else if (e.target.name === "Type_of_Facility__c") {
            this.Type_of_Facility__c = e.target.value;
        } else if (e.target.name === "Date_of_Sanction__c") {
            this.Date_of_Sanction__c = e.target.value;
        } else if (e.target.name === "Sanctioned_Amt__c") {
            this.Sanctioned_Amt__c = e.target.value;
        } else if (e.target.name === "Amount_Utilized__c") {
            this.Amount_Utilized__c = e.target.value;
        } else if (e.target.name === "ApprButPenForDis__c") {
            this.ApprButPenForDis__c = e.target.value;
        } else if (e.target.name === "Additional_Customer_Code__c") {
            this.Additional_Customer_Code__c = e.target.value
        } else if (e.target.name === "ExposureEditId") {
            this.ExposureEditId = e.target.value
        }
    }
    //funtion to create record details by calling apex method
    async createRecordDetails(objectApiName, fields) {
        await createRecord({ apiName: objectApiName, fields: fields })
            .then(obj => {
                console.log('record creation success =?:', obj);
                this.showMessage('success', SuccessToastMsg, 'Success');
                refreshApex(this.databankExposure);
                this.getExposureRecords();
                refreshApex(this._wiredResult);
                this.formdata = {}
                return (JSON.stringify(fields));
            })
            .catch(error => {
                this.showMessage('error', ErrorToastMsg + error, 'Error');
                console.log('error in record creation ', error);
            });
    }
    //method for updating the record details
    async updateRecordDetails(objectApiName, fields) {
        console.log('Inside updateRecordDetails: ', fields);
        await updateRecord({ fields: fields })
            .then(obj => {
                this.showMessage('success', UpdateToastMsg, 'Success');
                refreshApex(this.databankExposure);
                this.formdata = {}
                return (JSON.stringify(fields));
            })
            .catch(error => {
                this.showMessage('error', UpdateErrorToastMsg + error, 'Error');
            });
    }
    //method to add bank exposue and stop the form from submitting
    addBankExposure(event) {
        event.preventDefault();// stop the form from submitting        
        //3. Map the data to the fields
        var fields = {};
        fields[CIF_ID_FIELD.fieldApiName] = this.CIF_ID__c;
        fields[Type_of_Facility_FIELD.fieldApiName] = this.Type_of_Facility__c;
        fields[Date_of_Sanction_FIELD.fieldApiName] = this.Date_of_Sanction__c;
        fields[Amount_Sanctioned_FIELD.fieldApiName] = this.Sanctioned_Amt__c;
        fields[Amount_Utilized_FIELD.fieldApiName] = this.Amount_Utilized__c;
        fields[TYPE.fieldApiName] = 'Bank Exposure';
        fields[pprButPenForDis_FIELD.fieldApiName] = this.ApprButPenForDis__c;
        // fields[loanApplication_ID.fieldApiName] = this.recordId;  
        if (this.formdata.ExposureEditId && this.formdata.ExposureEditId != undefined) {
            console.log('bank exposure record updation start', fields);
            fields[EXPOSURE_ID.fieldApiName] = this.formdata.ExposureEditId;
            this.updateRecordDetails(Exposure_OBJECT.objectApiName, fields);
        } else {
            fields[loanApplication_ID.fieldApiName] = this.recordId;
            console.log('bank exposure record creation start');
            this.createRecordDetails(Exposure_OBJECT.objectApiName, fields);
        }
    }

    //add customer code
    addCustomerfunct() {
        // check if alredy added
        var alreadyadded = false;

        console.log(' cust code :', this.Additional_Customer_Code__c);
        console.log(' record id :,', this.recordId);
        checkCustomerCodeDetails({ oppID: this.recordId, custCodeString: this.Additional_Customer_Code__c })
            .then(res => {
                console.log('Response ::', res);
                alreadyadded = res;

                if (!alreadyadded) {
                    const payload = {
                        customerCode: this.Additional_Customer_Code__c,//, //'CU1390978',
                        dealNumber: "", /* API is expecting parameter */
                        loanApplicationId: this.recordId
                    }
                    // var customerlist = []
                    doCustomerNameSearchCallout({ customerNameSearchString: JSON.stringify(payload) })
                        .then(result => {
                            const res = JSON.parse(result);
                            console.log('result of doCustomerNameSearchCallout =>', res);
                            this.keyAdd = res.response.content[0].Customer_Code+' - '+res.response.content[0].Customer_Name;
                            console.log('keyAdd',this.keyAdd);
                            var filteredresult = res.response.content[0];
                            if (filteredresult.Flag != '') {
                                this.errormessage = '';
                                var fields = {};
                                fields[Customer_Code_loanId.fieldApiName] = this.recordId;
                                fields[Customer_Code_Customer_Name.fieldApiName] = filteredresult.Customer_Name
                                fields[Customer_Code_Code.fieldApiName] = filteredresult.Customer_Code;
                                fields[Customer_Code_flag.fieldApiName] = filteredresult.Flag;
                                this.createRecordDetails(CustomerCode_OBJECT.objectApiName, fields)
                                    .then(response => {
                                        console.log('creation of customer code record =>', response);
                                        refreshApex(this._dc);
                                        this.template.querySelector('lightning-input[data-name="Additional_Customer_Code__c"]').value = null;
                                    });
                            } else {
                                this.showMessage('error', filteredresult.Description, 'Error');
                                console.log('response from api -> record not found');
                            }
                        })
                        .catch(error => {
                            console.log('error in doCustomerNameSearchCallout =>', error);
                            this.Additional_Customer_Code__c = undefined;
                            this.showMessage('error', UnableToastMsg, 'Error');
                        })
                    this.Additional_Customer_Code__c = undefined;
                } else {
                    this.Additional_Customer_Code__c = undefined;
                    console.log(' already added => :', alreadyadded);
                    this.template.querySelector('lightning-input[data-name="Additional_Customer_Code__c"]').value = null;
                    this.showMessage('error', ExistToastMsg, 'Error');
                }
            })
    }


    showMessage(type, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: type,
            })
        );
    }

    //function to delete bank exposure
    deleteBankExposure(row) {
        if (confirm("Are you Sure you want to Delete ?") == true) {
            this.deleteRecordDetails('BankExposure', row.Id)
        }
    }
    //delete customer code
    deleteCustomerCode(row) {
        if (confirm("Are you Sure you want to Delete Customer Code ?") == true) {
            console.log('row Id ', row.Id);
            this.deleteCustomerCodeRecord(row.Id);
            // this.deleteRecordDetails('CustomerCode', row.Id);      

            //console.log('row Id ', row.Id);
        }

    }
    //function to delete customer code record
    deleteCustomerCodeRecord(recordId) {
        console.log('recordId :', recordId);
        deletecustCodes({ customercodeId: recordId })
            .then(resp => {
                console.log('deletecustCodes ', resp);
                this.getExposureRecords();
                refreshApex(this._wiredResult);

                if (resp) {
                    this.showMessage('success', DeleteToastMsg, 'Success');
                    refreshApex(this._dc);
                    // refreshApex(this.familyExpsureApexRefresh);

                } else {
                    this.showMessage('error', DeleteErrorToastMsg, 'Error');
                }

            })
            .catch(error => {
                this.showMessage('error', DeleteErrorToastMsg + error, 'Error');
            });
    }
    //function to delete record details
    async deleteRecordDetails(objectApiName, recordId) {
        await deleteRecord(recordId)
            .then(obj => {
                this.showMessage('success', DeleteToastMsg, 'Success');
                if (objectApiName == 'CustomerCode') {
                    refreshApex(this._dc);
                } else {
                    refreshApex(this.databankExposure);
                }

                this.getExposureRecords();
                refreshApex(this.exposureApexRefresh);
                refreshApex(this._wiredResult);

            })
            .catch(error => {
                this.showMessage('error', DeleteErrorToastMsg + error, 'Error');
            });
    }
    //function to check exposure to true
    checkExposurefunct() {
        this.isLoading = true;
        if(this.isDedupeSubmit == true){//CISP-4656
        getCustomerCodesExpAPI({ loanApplicationId: this.recordId })
            .then(customerCodesresp => {
                console.log('Check customerCodesresp', customerCodesresp);
                if (customerCodesresp && customerCodesresp.length) {
                    console.log('Resp -->', customerCodesresp);
                    const customerCode = customerCodesresp;
                    doCustomerExposureCallout({ lstCustCodes: customerCode, loanAppId: this.recordId })
                        .then(result => {
                            var resp = JSON.parse(result);
                            console.log('result ::', result);
                            // refreshApex(this.exposureApexRefresh); 
                            if (result) {
                                //checkExposure({loanApplicantionId : result });
                                //CISP-4656
                                saveExposureAPITriggered({ loanApplicantionId: this.recordId })
                                      .then(result => {
                                          this.isExposureApiRun = true;
                                        console.log('Result', result);
                                      })
                                      .catch(error => {
                                        console.error('Error:', error);
                                    });
                                
                                checkExposure({ lstCustCodes: customerCode, loanApplicantionId: this.recordId, exposureResponse: result })
                                    .then(reps => {
                                        console.log('Exposure insertiong reps', reps);
                                        if (reps) {
                                            this.isLoading = false;
                                            this.getExposureRecords();
                                           
                                            refreshApex(this.exposureApexRefresh);

                                            refreshApex(this._wiredResult);

                                        }

                                    })    
                                this.isLoading = false;
                                this.disableSubmit = false;
                            }
                        })
                        .catch(error => {
                            console.log('error in customer exposure api 427 => ', error);
                            this.isLoading = false;
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'Exposure API Fail !',
                                variant: 'error',
                            });
                            this.dispatchEvent(evt);
                        });
                } else {
                    console.log('No Resp -->', customerCodesresp);
                    this.isLoading = false;
                    this.isExposureApiRun = true;//CISP-4693
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: this.label.There_are_no_customer_code_for_exposure_callout,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                console.log('error in customer exposure api 432 => ', error);
                this.isLoading = false;
            });
        }
        //CISP-4656
        else{
            this.isLoading = false;
            this.showMessage('warning', 'Dedupe Response is assigned to CMU for validation', 'warning');
        }
        }
    


    //function to edit bank exposure details
    editBankExposureDetails(row) {
        console.log('Inside editBankExposureDetails :');
        if (row.Id) {
            this.formdata.ExposureEditId = row.Id;
        }
        if (row.Id) {
            this.formdata.ExposureEditId = row.Id;
        }
        if (row.Type_of_Facility__c) {
            this.formdata.Type_of_Facility__c = row.Type_of_Facility__c;
        }
        if (row.Name) {
            this.formdata.Name = row.Name;
        }
        if (row.CIF_ID__c) {
            this.formdata.CIF_ID__c = row.CIF_ID__c;
        }
        if (row.Date_of_Sanction__c) {
            this.formdata.Date_of_Sanction__c = row.Date_of_Sanction__c;
        }
        if (row.Sanctioned_Amt__c) {
            this.formdata.Sanctioned_Amt__c = row.Sanctioned_Amt__c;
        }
        if (row.Amount_Utilized__c) {
            this.formdata.Amount_Utilized__c = row.Amount_Utilized__c;
        }
        if (row.ApprButPenForDis__c) {
            this.formdata.ApprButPenForDis__c = row.ApprButPenForDis__c;
        }

    }

    // all modal functions here
    openModal() {
        console.log('Inside openModal ::', this.recordId);
        // to open modal set isModalOpen tarck value as true        
        getFamilyExpCustCodes({ oppId: this.recordId })
            .then(result => {
                this.familyExpDetails = [];
                if (result) {
                    this.datafamilyExposure = result;
                    this.isModalOpen = true;
                    this.hasfamilyExposure = true;
                    console.log('result->', result)
                    for (let key in result) {
                        this.familyExpDetails.push({ value: result[key], key: key });
                    }
                    console.log('this.familyExpDetails : ', this.familyExpDetails);
                }
            })
            .catch(error => {
                this.errorMsg = error;
            })
    }

    openModalLien() {
        this.isModalOpenLien = true;
        /* getLienDetails({ expId: '$exposureId' })
             .then(result => {
                 this.dataLienDetails = data;
             })
             .catch(error => {
                 this.errorMsg = error; 
             })*/
    }



    openModalAdditionalCustomerCode() {
        this.isModalAdditionalExp = true;
    }

    openModalBankExposure() {
        this.isModalBankExposure = true;
        // document.getElementsByClassName('slds-dropdown-trigger').style.display = "block";
    }


    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.isModalOpenLien = false;
        this.isModalAdditionalExp = false;
        this.isModalBankExposure = false;
        //window.location.reload()
    }

    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing 
        this.isModalOpen = false;
        this.isModalOpenLien = false;
        this.isModalAdditionalExp = false;
        this.isModalBankExposure = false;
        //window.location.reload()
    }


    // data table actions

    callRowAction(event) {
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        if (actionName === 'View') {
            console.log(' Inside lien record Id ' + recId);
            //this.exposureId  =recId;
            getLienDetails({ expId: recId })
                .then(result => {
                    this.dataLienDetails = result;
                    this.hasLienDetails = (result.length > 0) ? true : false
                    this.openModalLien();
                })
                .catch(error => {
                    //this.errorMsg = error; 
                })

        } else if (actionName == "editbankexposure") {

            this.editBankExposureDetails(event.detail.row);
        } else if (actionName == 'delete') {
            // deleteExposure(event.detail.row)
        } else if (actionName == 'DeleteCustCode') {
            this.deleteCustomerCode(event.detail.row);

        } else if (actionName == 'deleteBankExposure') {
            this.deleteBankExposure(event.detail.row);
        }
    }

    //load css on render
    renderedCallback() {
        //do something
        if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, WrappedHeaderTable)])
                .then(() => {
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles");
                });
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }

    @api isRevokedLoanApplication;//CISP-2735
    async connectedCallback() {

        await this.init();

        console.log('Inside Exposure Analysis connectedCallback');
        this.stageValue = undefined;
        await getOpptyStage({ loanApplicationId: this.recordId })
            .then(result => {
                console.log('Result :: ', JSON.stringify(result));
                this.stageValue = result;
                if (result != 'Exposure Analysis') {
                    console.log('Result :: ', this.disableActionsPostSubmit);
                    this.disableActionsPostSubmit = true;
                    this.disableSubmitBtn = true;
                    console.log('Result :: ', this.disableActionsPostSubmit);
                } else {
                    this.disableActionsPostSubmit = false;
                    this.disableSubmitBtn = false;
                }

            }).catch(error => {
                console.log('error::', error.message);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong, Please contact your administrator.',
                    variant: 'error',
                });
            })
            //CISP-3447 start
            await getApplicantInfo({ loanApplicationId: this.recordId })
              .then(result => {
                result = JSON.parse(result);
                console.log('Result', result);
                if(result){
                    this.appBorCustomerCode = result?.BorrowerDetails?.Customer_Code__c;
                    this.borrowerCodeValidateByCMU = result?.BorrowerDetails?.isCodeValidateBySalesUser__c;//CISP-6452
                    this.isDedupeSubmit = result?.BorrowerDetails?.Opportunity__r.Is_Customer_Dedupe_Submit__c;
                    this.leadSource = result?.BorrowerDetails?.Opportunity__r.LeadSource; 
                    if(result?.BorrowerDetails?.Opportunity__r.LeadSource == 'D2C'){
                        this.isDedupeSubmit = true;//CISP-7350 (Dedupe submit condition skipped)
                    }
                    this.isExposureApiRun = result?.BorrowerDetails?.Opportunity__r.IsExposureAPITriggered__c;//CISP-4656
                    console.log('OUTPUT ***: ',result.hasOwnProperty('CoBorrowerDetails'));
                    if(result.hasOwnProperty('CoBorrowerDetails')){
                        console.log('OUTPUT CoBorrowerDetails: ',);
                        this.isCoBorrowerExsist = true;
                        this.appCoBorCustomerCode = result?.CoBorrowerDetails?.Customer_Code__c;
                        this.coborrowerCodeValidateByCMU = result?.CoBorrowerDetails?.isCodeValidateBySalesUser__c;//CISP-6452
                    }
                   // New: Commercial flow 4486
                     this.isPersonalPurpose = result?.VehicleDetails === 'Personal';
                    
                }
                console.log('OUTPUT isCoBorrowerExsist: ',this.isCoBorrowerExsist);
              })
              .catch(error => {
                console.error('Error:', error);
            });//CISP-3447 end
            await getOpptyStageCAM({ loanApplicationId: this.recordId })
            .then(result => {
                console.log('Result :: ', JSON.stringify(result));
                this.stageValue = result;
                if (result) {
                    console.log('Result :: ', this.disableActionsPostSubmit);
                    this.disableActionsPostSubmit = false;
                    this.disableSubmitBtn = false;
                    console.log('Result :: ', this.disableActionsPostSubmit);
                }
            }).catch(error => {
                console.log('error::', error.message);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong, Please contact your administrator.',
                    variant: 'error',
                });
            })
            await updateTotalExposureAmount({ loanApplicationId: this.recordId,totalExposureAmount:this.totalExposureAmount })//Enhancement for INDI-3470
            .then(result => {
            }).catch(error => {
                console.error('error::', error);
            });
            await getDocumentsToCheckPan({ loanApplicationId: this.recordId })
              .then(result => {
                console.log('Result', result);
                let res = JSON.parse(result);
                this.isPanAvailableForBorrower = res?.borrowerPanAvailable;
                this.isPanAvailableForCoBorrower = res?.coborrowerPanAvailable;
                if(this.leadSource == 'D2C'){this.isPanAvailableForBorrower = true; this.isPanAvailableForCoBorrower = true} 
              })
              .catch(error => {
                console.error('Error:', error);
            });
            if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    async init(){
        await getRecordDetails({oppId : this.recordId})
        .then((response) => {
            console.log('oppDetails::',response);
            this.applicantsList = response;;
            if(this.applicantsList.length == 0){
                dedupeSubmitByCMU({ oppId: this.recordId })
                .then(result => {
                    this.isDedupeSubmit=result;
                    console.log('Result', result);
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            }
        })
        .catch((error) => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }); 
    }

    //screen submit button to navigate to next screen
    handleNavigate(event) {
        console.log(' inside handleNavigate JS');
        if(this.isDedupeSubmit == true){
            if(this.isExposureApiRun == true){//CISP-4656
                if(parseInt(this.totalExposureAmount) < 1000000 || (parseInt(this.totalExposureAmount) >= 1000000 && this.isPanAvailableForBorrower == true)){
            allCostCodeTrgExpAPI({ loanapplicationId: this.recordId })
                .then(resp => {
                    console.log('Resp ==>', resp);
                    if (resp == false) {
                       // this.showMessage('warning', 'Please click on check exposure button, to complete pre-requsite.', 'warning');
                       if(this.isCoBorrowerExsist){//CISP-3447 changes
                        let  sMsg = 'CMU has validated “'+ this.appBorCustomerCode +'” for borrower and “'+ this.appCoBorCustomerCode +'” for Co-borrower .Please click on “Check Exposure” button'; 
                        this.showMessage('warning', sMsg, 'warning');
                       }else{
                            this.showMessage('warning', 'CMU has validated “'+ this.appBorCustomerCode +'” for “borrower”. Please click on “Check Exposure” button.', 'warning');
                       }

                    } else {
                        this.disableActionsPostSubmit = true;
                        this.disableSubmitBtn = true;
                        this.dispatchEvent(new CustomEvent('exposureevent', { detail: 'Exposure Analysis' }));
                    }

                })
            }else{
                if(this.isPanAvailableForBorrower == false || (this.isPanAvailableForCoBorrower == false && this.isCoBorrowerExsist ))
                    this.showMessage('warning', 'Exposure (Incl. loan amount) is >= INR 10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN or change the Loan amount by revoking the application.', 'warning');
        }}else{
                if(this.borrowerCodeValidateByCMU == false && this.appBorCustomerCode && this.isCoBorrowerExsist && this.coborrowerCodeValidateByCMU == false && this.appCoBorCustomerCode){//CISP-6452
                    let  sMsg = 'CMU has validated “'+ this.appBorCustomerCode +'” for borrower and “'+ this.appCoBorCustomerCode +'” for Co-borrower .Please click on “Check Exposure” button'; 
                    this.showMessage('warning', sMsg, 'warning');
                }else if(this.borrowerCodeValidateByCMU == false && this.appBorCustomerCode){
                    this.showMessage('warning', 'CMU has validated “'+ this.appBorCustomerCode +'” for “borrower”. Please click on “Check Exposure” button.', 'warning');
                }else if(this.isCoBorrowerExsist && this.coborrowerCodeValidateByCMU == false && this.appCoBorCustomerCode){
                    this.showMessage('warning', 'CMU has validated “'+ this.appCoBorCustomerCode +'” for “Co-Borrower”. Please click on “Check Exposure” button.', 'warning');
                }else{
                    this.showMessage('warning', 'Please click on check exposure button, to complete pre-requsite.', 'warning');//CISP-4656
                }
            }
        }else{
            this.showMessage('warning', 'Dedupe Response is assigned to CMU for validation', 'warning');
        }
    }

    //function to get exposure object records
    getExposureRecords() {
        console.log(' inside getExposureDetails ' + this.recordId);

        getExpRecords({ oppId: this.recordId })
            .then(expResp => {

                if (expResp) {

                    console.log(' wireExposure 22222:', expResp);
                    this.disableActionsPostSubmit = false;

                    this.currentExposureAmount = expResp.currentExposureAmount
                    this.bankExposureAmount = expResp.bankExposureAmount
                    this.totalExposureAmount = expResp.totalExposureAmount
                    this.chequeReturn = expResp.chequeReturn
                    this.relationshipSince = expResp.relationshipSince
                    // this.relationshipSince = data.relationshipSince
                    this.existingBorrowerExposureAmount = expResp.existingBorrowerExposureAmount
                    this.existingCoBorrowerExposureAmount = expResp.existingCoBorrowerExposureAmount
                    this.existingOtherExposureAmount = expResp.existingOtherExposureAmount
                    this.dataBorrowerExposure = expResp.lstBorExposureDetails;
                    this.datacoBorrowerExposure = expResp.lstCoBorExposureDetails;
                    this.datacustomerExposure = expResp.lstAdditionalExposureDetails;

                    this.hasBorrowerExposure = (expResp.lstBorExposureDetails.length > 0) ? true : false;
                    this.hascoBorrowerExposure = (expResp.lstCoBorExposureDetails.length > 0) ? true : false;
                    this.hascustomerExposure = (expResp.lstAdditionalExposureDetails.length > 0) ? true : false;
                }
            })
    }


    @api familyexpSubmit(event) {
        this.isModalOpen = true;
    }
    // in order to refresh your data, execute this function:
    //refreshData() {
    //   return refreshApex(this._wiredResult);
    //  }

}