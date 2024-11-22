//import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { LightningElement, api, track, wire } from 'lwc';
import getIncomeSourceRecord from '@salesforce/apex/OfficeFiClass.getIncomeSourceRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import uploadDocuments from "@salesforce/apex/CreateFieldInvestigationRecord.uploadDocuments";
import getOfficeFIRecord from '@salesforce/apex/OfficeFiClass.getOfficeFIRecord';
import getDocumentRecordId from '@salesforce/apex/OfficeFiClass.getDocumentRecordId';
import Field_Investigation__c from '@salesforce/schema/Field_Investigation__c';
import createDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.createDocumentRecord';
import checkRetryExhausted from '@salesforce/apex/IND_ResidenceFIController.checkRetryExhausted';//CISP-2701
import retryCountIncrease from '@salesforce/apex/IND_ResidenceFIController.retryCountIncrease';//CISP-2701
import doGeoCoderAPI from '@salesforce/apex/IntegrationEngine.doGeoCoderAPI'
import getFieldInvestigation from '@salesforce/apex/IND_ResidenceFIController.getFieldInvestigation';//CISP-2701
import updateActualGeoLocationDetails from '@salesforce/apex/IND_ResidenceFIController.updateActualGeoLocationDetails';
import getContentDocumentId from '@salesforce/apex/IND_ResidenceFIController.getContentDocumentId';
//import getDocumentsOfFI from '@salesforce/apex/IND_ResidenceFIController.getDocumentsOfFI';
import haveCurrentCaseAccess from '@salesforce/apex/IND_ResidenceFIController.haveCurrentCaseAccess';
import signature from '@salesforce/label/c.Signature';
import otherDocument from '@salesforce/label/c.Other_Document_Record_Type';
import kycDocument from '@salesforce/label/c.KYCDocument';

import officeFrontView from '@salesforce/label/c.Office_Front_View';
import landPhoto from '@salesforce/label/c.Land_Photo';
import patttaDocument from '@salesforce/label/c.Patta_Document';
import rentAgreement from '@salesforce/label/c.Rent_Agreement_Reciept';
import pensionDocumnet from '@salesforce/label/c.Pension_Document';
import Please_fill_all_the_mandatory_fields from '@salesforce/label/c.Please_fill_all_the_mandatory_fields';
import Length_is_too_short_of_FI_Feedback from '@salesforce/label/c.Length_is_too_short_of_FI_Feedback';
import Please_enter_letter_only_for_FI_Feedback from '@salesforce/label/c.Please_enter_letter_only_for_FI_Feedback';
import Length_is_too_short_long_of_Name_of_person_met from '@salesforce/label/c.Length_is_too_short_long_of_Name_of_person_met';
import Please_enter_letter_only_for_Name_of_person_met from '@salesforce/label/c.Please_enter_letter_only_for_Name_of_person_met';

import FORM_FACTOR from '@salesforce/client/formFactor';
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import lastNameError from '@salesforce/label/c.Last_Name_Error';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import Document_Office_Address_Type from '@salesforce/label/c.Document_Office_Address_Type';

import userId from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

import SAME_ADDRESS from '@salesforce/schema/Field_Investigation__c.Same_Addresst_as_in_the_Application__c';//CISP-2727
import ADDRESS_TYPE from '@salesforce/schema/Documents__c.Addresss_Type__c';
import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';

export default class lwc_OfficeFi extends NavigationMixin(LightningElement) {
    @api recordId;
    @api id;
    @track fieldInvestigation = {};
    @track inputWrapper = {};
    // @track creditProcAndResFICase = false;
    Field_Investigation__c_Id;
    patttaDocData;
    landPhotoName;
    landPhotoData;
    rentAggrementData;
    pensionDocData;
    pensionDocName;
    rentalAgreementName;
    pattaDocName;
    activeSectionMessage = '';
    activeSections = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'LocationBoundBy'];
    @track name;
    @track prodct;
    @track addLine1;
    @track addLine2;
    @track cty;
    @track pincde;
    @track state;
    @track phnNum;
    @track mobile;
    @track catgry;
    @track profile;
    @track currntExp;
    @track totalExp;
    @track landmark;
    @track cse;
    @track fiReqGenDT;
    @track resiFiStatus;
    @track officeFICompTime;
    @track disablelistOfEqupmntToolsOwnd=true;
    @track requiredlistOfEqupmntToolsOwnd=false;
    @track nameOfPersonMetVal='';
    //---------------------
    @track smeAddAsInApp;
    @track empBusnssName;
    @track offBusnsstyp;
    @track busnssPremse;
    @track offBusnssBrd;
    @track offBusnssSizSqft;
    @track lctn;
    @track nameOfPersnMet;
    @track relatnshp;
    @track politiclPhto;
    @track pllRecgnzd;
    @track touingOrTransfrbleJob;
    @track monthlyOncmAsPerFiVisit;
    @track IncmeAsPerFiVisit;
    @track area;
    @track userDetails
    //  @track landPhoto;
    @track noOfCrpsPerAnm;
    @track typeOfCrp;
    @track yeildPerAcreMonthly;
    @track pricePerunit;
    @track incme;
    @track typeOfHuose;
    @track electricityConnctnPresent;
    @track accessToTubwll;
    @track irrigtnSysPresent;
    @track noOfCattle;
    @track typeOfGoodSold;
    @track noOfEmpls;
    @track inhuseSecCamPre;
    @track posMachin;
    @track acInstlld;
    @track avrgNoOfCustmrs;
    @track avrgTicktSize;
    @track numOfOperHoursInAday;
    @track montlySales;
    @track annualTurnover;
    @track prftMargn;
    @track estmtdIncmeAsPerFi;
    @track declrdIncmeDurngApp;
    @track finalIncme;
    @track latestWatrBill;
    @track paymntPrfShwn;
    @track latestTelephoneBill;
    @track paymntPrfShwnforTeleBill;
    @track latestElecBill;
    @track paymntPrfShwnforEleBill;
    @track pattaDocAvail;
    @track ownEqupmntTools;
    @track listOfEqupmntToolsOwnd;
    @track affilatnToECommrce;
    @track avrgPrffFeeSer_rs;
    @track noOfServcReqCatInMonths;
    @track estimatedSerIncmAsPerFi = 0;
    @track typOfVehclOwnd;
    @track noOfvehclesOwnd;
    @track estmtdAvrgIncmPerMnth;
    @track noOfContractsAwardedInLast1Yrs;
    @track doYouHveAnyGovContracts;
    @track estimtdtotalMnthlyIncme;
    @track noOfProprtsRentd;
    @track incmePerMonthProprty;
    @track incmePerMonth;
    @track noOfAttmpts;
    @track fiObservtn;
    @track fiFeedback='';
    @track offFiAccptdRegctd;
    @track showSignatureModal = false;
    @track signatureDocumentId;
    @track documentId;
    @track documentType
    @track applicationId;
    @track applicantId;
    @track profilePensions;
    @track imageExist=false;
    @track isreadAble=false;
    @track officeFIStatus = 'Complete';
    @track isSpinnerMoving=false;

    label = {
        lastNameError,
        RegEx_Alphabets_Only,
        signature,
        otherDocument,
        kycDocument,
        currentUserId,
        officeFrontView,
        currentUserName,
        currentUserEmailid,
        mode,
        currentApplicantid,
        landPhoto,
        patttaDocument,
        rentAgreement,
        pensionDocumnet,
        Please_fill_all_the_mandatory_fields,
        Length_is_too_short_of_FI_Feedback,
        Please_enter_letter_only_for_FI_Feedback,
        Length_is_too_short_long_of_Name_of_person_met,
        Please_enter_letter_only_for_Name_of_person_met
    };
    @track isPrimaryIncomeSourceTrue = false;
    @track isSalaried = false;
    @track isSelfEmployed = false;
    @track profileName = '';
    @track profileAgriculture = false;
    @track profileShop = false;
    @track profileService = false;
    @track profileTransporter = false;
    @track profileContracter = false;
    @track profileRental = false;
    @track profilePension = false;
    @track profileIPNIP = false;
    @track isrequired = true; 
    @track haveCaseAccess = true;
    @wire(getObjectInfo, { objectApiName: Field_Investigation__c })
    officeFIObjectInfo;

    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })
    userDetails({ error, data }) {
        if (data) {
            this.userDetails = data;
        } else if (error) {
                this.showToast(Error, 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
            
        }
    }

    yesNoOptions = [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }]//CISP-2727
    async connectedCallback() {
        console.log('recordId::', this.recordId);
        this.officeFIDetails = await getOfficeFIRecord({
            recordId: this.recordId
        }
        ).then(record => {
            // return record.Name;
            console.log("Inside", JSON.stringify(record));
            return record;
        }).catch(error => {
            console.log('error::',error);
            const evt = new ShowToastEvent({
                title: Error,
                message: 'Something went wrong, please contact your admin!',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        });

        console.log("<>", JSON.stringify(this.officeFIDetails));
        this.name = this.officeFIDetails.Case__r.Applicant__r.Name;
        this.prodct = this.officeFIDetails.Case__r.Loan_Application__r?.Product_Type__c;
        this.addLine1 = this.officeFIDetails.Address_Line_1__c;
        this.addLine2 = this.officeFIDetails.Address_Line_2__c;
        this.cty = this.officeFIDetails.City__c;
        this.pincde = this.officeFIDetails.Pin_Code__c;
        this.state = this.officeFIDetails.State__c;
        this.phnNum = this.officeFIDetails.Case__r.Applicant__r.Contact_number__c;
        this.mobile = this.officeFIDetails.Case__r.Applicant__r.Whatsapp_number__c;
        this.catgry = this.officeFIDetails.Category__c;
        this.profile = this.officeFIDetails.Profile__c;
        this.currntExp = this.officeFIDetails.Current_experience_years__c;
        this.totalExp = this.officeFIDetails.Total_Experience_Years__c;
        this.cse = this.officeFIDetails.Case__c;
        this.fiReqGenDT = this.officeFIDetails.FI_Request_Generation_Date_Time__c;
        this.resiFiStatus = this.officeFIDetails.Residence_FI_Status__c;
        this.officeFICompTime = this.officeFIDetails.Office_FI_Completion_Time__c;
        this.landmark = this.officeFIDetails.Landmark__c;
        //CISP-2727
        if(this.officeFIDetails?.FI_Status__c === 'Complete'){
            this.smeAddAsInApp = this.officeFIDetails.Same_Addresst_as_in_the_Application__c ? 'Yes' : 'No';
        }
        //CISP-2727
        //-----
        this.empBusnssName = this.officeFIDetails.Employer_Business_Name__c;
        this.offBusnsstyp = this.officeFIDetails.Office_Business_Type__c;
        this.busnssPremse = this.officeFIDetails.Business_Premise__c;
        this.offBusnssBrd = this.officeFIDetails.Office_Business_Board__c;
        this.offBusnssSizSqft = this.officeFIDetails.Office_Business_Size_Sqft__c;
        this.lctn = this.officeFIDetails.Location__c;
        this.nameOfPersnMet = this.officeFIDetails.Name_of_Person_met__c;
        this.relatnshp = this.officeFIDetails.Relationship__c;
        this.politiclPhto = this.officeFIDetails.Political_Photo__c;
        this.pllRecgnzd = this.officeFIDetails.Applicant_Recognized__c;
        this.touingOrTransfrbleJob = this.officeFIDetails.Touring_or_Transferable_Job__c;
        this.monthlyOncmAsPerFiVisit = this.officeFIDetails.Monthly_Income_as_per_FI_Visit__c;
        this.IncmeAsPerFiVisit = this.officeFIDetails.Income_as_per_FI_Visit__c;
        this.area = this.officeFIDetails.Area__c;
        // this.landPhoto = this.officeFIDetails.Land_Photo__c;
        this.noOfCrpsPerAnm = this.officeFIDetails.No_of_crops_per_annum__c;
        this.typeOfCrp = this.officeFIDetails.Type_of_Crop__c;
        this.yeildPerAcreMonthly = this.officeFIDetails.Yield_Per_Acre_monthly__c;
        this.pricePerunit = this.officeFIDetails.Price_per_unit__c;
        this.incme = this.officeFIDetails.Income__c;
        this.typeOfHuose = this.officeFIDetails.Type_of_House__c;
        this.electricityConnctnPresent = this.officeFIDetails.Electricity_Connection_Present__c;
        this.accessToTubwll = this.officeFIDetails.Access_to_Tubewells__c;
        this.irrigtnSysPresent = this.officeFIDetails.Irrigation_system_present__c;
        this.noOfCattle = this.officeFIDetails.No_of_Cattle__c;
        this.typeOfGoodSold = this.officeFIDetails.Type_of_goods_sold__c;
        this.noOfEmpls = this.officeFIDetails.No_of_Employees__c;
        this.inhuseSecCamPre = this.officeFIDetails.Inhouse_Security_Camera_present__c;
        this.posMachin = this.officeFIDetails.POS_Machine__c;
        this.acInstlld = this.officeFIDetails.AC_Installed__c;
        this.avrgNoOfCustmrs = this.officeFIDetails.Average_no_of_customers__c;
        this.avrgTicktSize = this.officeFIDetails.Average_Ticket_Size_Rs__c;
        this.numOfOperHoursInAday = this.officeFIDetails.Number_of_operational_hours_in_a_day__c;
        this.montlySales = this.officeFIDetails.Monthly_Sales__c;
        this.annualTurnover = this.officeFIDetails.Annual_Turnover__c;
        this.prftMargn = this.officeFIDetails.Profit_Margin__c;
        this.estmtdIncmeAsPerFi = this.officeFIDetails.Estimated_Income_as_per_FI__c;
        this.declrdIncmeDurngApp = this.officeFIDetails.Declared_Income_During_Application__c;
        this.finalIncme = this.officeFIDetails.Final_Income__c;
        this.latestWatrBill = this.officeFIDetails.Latest_Water_Bill__c;
        this.paymntPrfShwn = this.officeFIDetails.Payment_Proof_Shown__c;
        this.latestTelephoneBill = this.officeFIDetails.Latest_Telephone_Bill_Amount_Paid_Month__c;
        this.paymntPrfShwnforTeleBill = this.officeFIDetails.Telephone_Bill_Payment_Proof_Shown__c;
        this.latestElecBill = this.officeFIDetails.Latest_Electricity_Bill_Amount_Paid_Mont__c;
        this.paymntPrfShwnforEleBill = this.officeFIDetails.Payment_Proof_shown_for_Electricity_Bill__c;
        this.pattaDocAvail = this.officeFIDetails.Patta_Document_available__c;
        this.ownEqupmntTools = this.officeFIDetails.Own_Equipment_Tools__c;
        this.listOfEqupmntToolsOwnd = this.officeFIDetails.List_of_equipment_tools_owned__c;
        this.affilatnToECommrce = this.officeFIDetails.Affiliation_to_e_commerce__c;
        this.avrgPrffFeeSer_rs = this.officeFIDetails.Average_Professional_Fee_Service_Rs__c;
        this.noOfServcReqCatInMonths = this.officeFIDetails.No_of_Service_Requests_catered_in_month__c;
      //  this.estimatedSerIncmAsPerFi = this.officeFIDetails.Estimated_Service_Income_as_per_FI__c;
        this.typOfVehclOwnd = this.officeFIDetails.Types_of_vehicles_owned__c;
        this.noOfvehclesOwnd = this.officeFIDetails.No_of_vehicles_owned__c;
        this.estmtdAvrgIncmPerMnth = this.officeFIDetails.Estimated_Average_Income_per_month__c;
        this.noOfContractsAwardedInLast1Yrs = this.officeFIDetails.No_of_contracts_awarded_in_last_1_year__c;
        this.doYouHveAnyGovContracts = this.officeFIDetails.Do_you_have_any_government_contracts__c;
        this.estimtdtotalMnthlyIncme = this.officeFIDetails.Estimated_Total_Monthly_Income__c;
        this.noOfProprtsRentd = this.officeFIDetails.Number_of_Properties_rented__c;
        this.incmePerMonthProprty = this.officeFIDetails.Income_per_month_property__c;
        this.incmePerMonth = this.officeFIDetails.Income_per_month__c;
        this.noOfAttmpts = this.officeFIDetails.No_of_Attempts__c;
        this.fiObservtn = this.officeFIDetails.FI_Observation__c;
        this.fiFeedback = this.officeFIDetails.FI_Feedback__c;
        this.offFiAccptdRegctd = this.officeFIDetails.Office_FI_Accepted_Rejected__c;
        this.applicantId = this.officeFIDetails.Case__r.Applicant__c;
        this.applicationId = this.officeFIDetails.Case__r.Loan_Application__c;
        try {
            let incomeDetails = await getIncomeSourceRecord({
                applicantId: this.applicantId
            }).then(record => {
                return record;
            });
            this.isPrimaryIncomeSourceTrue = incomeDetails?.Primary_Income_Source__c;
            this.isSalaried = incomeDetails?.Is_Salaried__c;
            this.isSelfEmployed = incomeDetails?.Is_Self_Employed__c;
            this.profileName = incomeDetails?.Profile__r?.Sub_Bucket_Desc__c;
            
            this.setProfile(incomeDetails);

        } catch (error) {
            console.error(error);
        }
        // CISP-2701-START
        await checkRetryExhausted({'loanApplicationId':this.applicationId, 'fieldInvestigation': this.recordId}).then(result=>{//CISP-3069
            this.disabledCapturedBtn = result;
        }).catch(error=>{
            console.log(error);
        });
        await getFieldInvestigation({fieldInvestigationId:this.recordId}).then(result=>{
            console.log('result ', result);
            if(result){
                this.coordinatesDistance = result.Coordinates_Distance__c;//CISP-3155
            }
        }).catch(error=>{
            console.log(error);
        });
        if(this.applicationId && this.cse){
            await haveCurrentCaseAccess({loanId: this.applicationId, caseId : this.cse}).then(result=>{
                console.log('result ', result);
                this.haveCaseAccess = result;
                if(!this.haveCaseAccess){
                    this.handleDisableScreen();
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'This Case is owned by another user. It is available in Read only mode. You will not able to edit it.',
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                }
            }).catch(error=>{
                console.log(error);
            });
        }
    }
    disabledCapturedBtn = false;
    //CISP-2701-END
    renderedCallback() {
        if (!this.haveCaseAccess || (this.officeFIDetails && this.officeFIDetails.FI_Status__c && this.officeFIDetails.FI_Status__c === 'Complete')) {
            this.handleDisableScreen();
        }
    }
    //CISP-2727
    handleInputFieldChange(event){
        this.smeAddAsInApp = event.target.value;
    }
    //CISP-2727
    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }

    handleSetActiveSectionC() {
        const accordion = this.template.querySelector('.example-accordion');
        activeSections = ['A', 'B', 'C'];
        //  accordion.activeSections = 'C';
    }

    handlePattaDOC(event){
        this.pattaDocAvail = event.detail.value;
        console.log('this.pattaDocAvail',this.pattaDocAvail);
        if(this.pattaDocAvail == 'YES'){
            this.uploadDoc = true;
        }else{
            this.uploadDoc = false;
        }
    }

     handleSuccess(event) {
        this.Field_Investigation__c_Id = this.recordId;

        // updateRecord(recordInput)
        // .then(result=>{
        //     console.log("-result- "+JSON.stringify(result));
        //     if(result){
        //     }
        // })
        // .catch(exception=>{

        // });
        uploadDocuments({
            patttaDocData: this.patttaDocData,
            landPhotoData: this.landPhotoData,
            rentAggrementData: this.rentAggrementData,
            pensionDocData: this.pensionDocData,
            recordId: this.recordId
        })
            .then(result => {
                console.log("-result- " + JSON.stringify(result));
                if (result) {
                    console.log("< -- >" + JSON.stringify(result));
                }
            })
            .catch(error => {
                console.log('error uploadDocuments ',error);

            });
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Record created successfully!',
            variant: 'success',
            mode: 'dismissable'
        });

        //console.log('event.detail.id 104 '+event.detail.id);
        this.dispatchEvent(evt);

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: event.detail.id,
        //         objectApiName: 'Field_Investigation__c', // objectApiName is optional
        //         actionName: 'view'
        //     }
        // });
        console.log("line 113 ")
        this.handleDisableScreen();
    }
    handleDisableScreen() {
        const allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => {
            element.disabled = true;
        });
    }
    //Open
    isFileUpload = false;
    isSignatureUpload = false;
    handleChangeFileUpload() {
        console.log('ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + userId + '&' + this.label.mode + '=' + this.label.officeFrontView + '&' + this.label.currentUserName + '=' + this.userDetails.fields.Name.value + '&' + this.label.currentUserEmailid + '=' + this.userDetails.fields.Email.value + '&documentSide=Front'+'&caseID='+this.cse )
        if (FORM_FACTOR === 'Large') {
            this.documentType = this.label.officeFrontView;
            this.createDocument(this.label.officeFrontView, this.label.otherDocument);
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + userId + '&' + this.label.mode + '=' + this.label.officeFrontView + '&' + this.label.currentUserName + '=' + this.userDetails.fields.Name.value + '&' + this.label.currentUserEmailid + '=' + this.userDetails.fields.Email.value + '&documentSide=Front'+'&caseID='+this.cse
                }
            });
        }
    }

    hanldePattaDcoumentUplaod() {
        if (FORM_FACTOR === 'Large') {
            this.documentType = this.label.patttaDocument; // Patta document custom lable needs to be there
            this.createDocument(this.label.patttaDocument, this.label.otherDocument);
        } else {
            getDocumentRecordId().then(result => {
                if(result !== null){
                    let documentRecordId = result;
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + userId + '&' + this.label.mode + '=' + this.label.patttaDocument + '&' + this.label.currentUserName + '=' + this.userDetails.fields.Name.value + '&' + this.label.currentUserEmailid + '=' + this.userDetails.fields.Email.value + '&documentSide=Front'+'&caseID='+this.cse+'&loanApplicationId=' +  this.applicationId +'&documentRecordTypeId='+documentRecordId
                        }
                    });
                }
            }).catch(error => {
                console.log('getDocumentRecordId',error);
            });
        }
    }

    hanldePensionDcoumentUplaod() {
        if (FORM_FACTOR === 'Large') {
            this.documentType = this.label.pensionDocumnet; // Patta document custom lable needs to be there
            this.createDocument(this.label.pensionDocumnet, this.label.otherDocument);
        } else {
            getDocumentRecordId().then(result => {
                console.log('getDocumentRecordId',result);
                if(result !== null){     
                    let documentRecordId = result;   
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + userId + '&' + this.label.mode + '=' + this.label.pensionDocumnet + '&' + this.label.currentUserName + '=' + this.userDetails.fields.Name.value + '&' + this.label.currentUserEmailid + '=' + this.userDetails.fields.Email.value + '&documentSide=Front'+'&caseID='+this.cse+'&loanApplicationId=' +  this.applicationId +'&documentRecordTypeId='+documentRecordId
                        }
                    });
                }
            }).catch(error => {
                console.log('getDocumentRecordId',error);
            });
        }
    }

    hanldeLandPhotoUplaod() {
        if (FORM_FACTOR === 'Large') {
            this.documentType = this.label.landPhoto; // Patta document custom lable needs to be there
            this.createDocument(this.label.landPhoto, this.label.otherDocument);
        } else {
            getDocumentRecordId().then(result => {
                console.log('getDocumentRecordId',result);
                if(result !== null){     
                    let documentRecordId = result;   
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + userId + '&' + this.label.mode + '=' + this.label.landPhoto + '&' + this.label.currentUserName + '=' + this.userDetails.fields.Name.value + '&' + this.label.currentUserEmailid + '=' + this.userDetails.fields.Email.value + '&documentSide=Front'+'&caseID='+this.cse+'&loanApplicationId=' +  this.applicationId +'&documentRecordTypeId='+documentRecordId //loanApplicationId: this.applicationId
                }
            });
        }
        }).catch(error => {
            console.log('getDocumentRecordId',error);
        });
    }
        }
        
    

    hanldeRentAgreementUplaod() {
        if (FORM_FACTOR === 'Large') {
            this.documentType = this.label.rentAgreement; // Patta document custom lable needs to be there
            this.createDocument(this.label.rentAgreement, this.label.otherDocument);
        } else {
            getDocumentRecordId().then(result => {
                console.log('getDocumentRecordId',result);
                if(result !== null){     
                    let documentRecordId = result; 
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + userId + '&' + this.label.mode + '=' + this.label.rentAgreement + '&' + this.label.currentUserName + '=' + this.userDetails.fields.Name.value + '&' + this.label.currentUserEmailid + '=' + this.userDetails.fields.Email.value + '&documentSide=Front'+'&caseID='+this.cse+'&loanApplicationId=' +  this.applicationId +'&documentRecordTypeId='+documentRecordId
                }
            });
        }
    }).catch(error => {
        console.log('getDocumentRecordId',error);
    });
}
    }

    //Close
    closeUploadBuildingView() {

        this.isFileUpload = false;
    }
    // handleChangeSignatureUpload(event) {
    //     if(this.isSignatureUpload){
    //         this.showSignModal = false;
    //         this.isSignatureUpload = false;
    //     }

    //     else {
    //         this.isSignatureUpload = true;
    //         this.showSignModal = true;
    //     }

    // }
    // @track showSignModal = false;

    // openSignModal() {
    //     // Setting boolean variable to true, this will show the Modal
    //     this.showSignModal = true;
    // }

    // closeSignModal() {
    //     // Setting boolean variable to false, this will hide the Modal
    //     this.showSignModal = false;
    //     this.isSignatureUpload = false;
    // }

    FieldInvestigationRecord = { 'sobjectType': 'Field_Investigation__c' }


    // pattaDocUploadHandler(event) {
    //     const file = event.target.files[0]
    //     this.pattaDocName = file.name;
    //     var reader = new FileReader()
    //     reader.onload = () => {
    //         var base64 = reader.result.split(',')[1]
    //         this.patttaDocData = {
    //             'filename': file.name,
    //             'base64': base64
    //         }
    //     }
    //     reader.readAsDataURL(file)
    // }
    // landPhotoUploadHandler(event) {
    //     const file = event.target.files[0]
    //     this.landPhotoName = file.name;
    //     var reader = new FileReader()
    //     reader.onload = () => {
    //         var base64 = reader.result.split(',')[1]
    //         this.landPhotoData = {
    //             'filename': file.name,
    //             'base64': base64            
    //         }
    //     }
    //     reader.readAsDataURL(file)
    // }
    // rentAggrementUploadHandler(event) {
    //     const file = event.target.files[0]
    //     this.rentalAgreementName = file.name;
    //     var reader = new FileReader()
    //     reader.onload = () => {
    //         var base64 = reader.result.split(',')[1]
    //         this.rentAggrementData = {
    //             'filename': file.name,
    //             'base64': base64            
    //         }
    //     }
    //     reader.readAsDataURL(file)
    // }
    // pensionRecieptUploadHandler(event) {
    //     const file = event.target.files[0]
    //     this.pensionDocName = file.name;
    //     var reader = new FileReader()
    //     reader.onload = () => {
    //         var base64 = reader.result.split(',')[1]
    //         this.pensionDocData = {
    //             'filename': file.name,
    //             'base64': base64            
    //         }
    //     }
    //     reader.readAsDataURL(file)
    // }

    handleSignatureUpload() {
        // createDocumentRecord({ applicantId : this.applicantId, loanApplicationId : this.applicationId,documentType : this.label.signature })
        createDocumentRecord({caseId: this.recordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: this.label.signature, recordTypeName: this.label.otherDocument })
            .then((response) => {
                this.signatureDocumentId = response;
                //CISP-4267 start
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.signatureDocumentId;
                docFields[ADDRESS_TYPE.fieldApiName] = this.label.Document_Office_Address_Type;
                this.updateRecordDetails(docFields);
                //CISP-4267 end

                this.showSignatureModal = true;
                const scrollOptions = {
                    left: 0,
                    top: 0,
                    behavior: 'smooth'
                }
                window.scrollTo(scrollOptions);
            })
            .catch((error) => {
                    this.showToast(Error, 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                

            });

    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
        .then((result) => {}).catch(error => {console.log('error ', error);});
    }

    handlemontlySales(event) {
        this.montlySales = event.detail.value;
        console.log('value',event.detail.value);
        console.log('montlySales',this.montlySales);
        this.handleEstimateIncome();

    }
    handleprofitMargin(event) {
        this.prftMargn = event.detail.value;
        console.log('value',event.detail.value);

        if (this.prftMargn > 100) {
            this.prftMargn = null;
            console.log('prftMargn inside if>100',this.prftMargn);
        }
        console.log('prftMargn',this.prftMargn);
        this.handleEstimateIncome();
    }

    handleEstimateIncome(){
        if(this.prftMargn!=null && this.montlySales!=null){
            this.isreadAble = true;
            this.estmtdIncmeAsPerFi = this.prftMargn * this.montlySales;
            console.log('inside if isreadAble',this.isreadAble);
            console.log('inside if estmtdIncmeAsPerFi',this.estmtdIncmeAsPerFi);

        }
        if(!this.prftMargn || !this.montlySales){
            this.isreadAble = false;
            console.log('inside else isreadAble ',this.isreadAble);

        }
    }

    handleCloseSignatureModal() {
        this.showSignatureModal = false;
    }
    handleSignatureSave() {
        this.template.querySelector('c-capture-signature').handleSaveClick();
    }

    handleSignatureClear() {
        this.template.querySelector('c-capture-signature').handleClearClick();
    }
    get name() { return this.name; }
    get prodct() { return this.prodct; }
    get addLine1() { return this.addLine1; }
    get addLine2() { return this.addLine2; }
    get cty() { return this.cty; }
    get pincde() { return this.pincde; }
    get state() { return this.state; }
    get phnNum() { return this.phnNum; }
    get mobile() { return this.mobile; }
    get catgry() { return this.catgry; }
    get profile() { return this.profile; }
    get currntExp() { return this.currntExp; }
    get totalExp() { return this.totalExp; }
    get landmark() { return this.landmark; }
    get cse() { return this.cse; }
    get fiReqGenDT() { return this.fiReqGenDT; }
    get resiFiStatus() { return this.resiFiStatus; }
    get officeFICompTime() { return this.officeFICompTime; }
    //----------------
    get empBusnssName() { return this.empBusnssName; }
    get offBusnsstyp() { return this.offBusnsstyp; }
    get busnssPremse() { return this.busnssPremse; }
    get offBusnssBrd() { return this.offBusnssBrd; }
    get offBusnssSizSqft() { return this.offBusnssSizSqft; }
    get lctn() { return this.lctn; }
    get nameOfPersnMet() { return this.nameOfPersnMet; }
    get relatnshp() { return this.relatnshp; }
    get politiclPhto() { return this.politiclPhto; }
    get pllRecgnzd() { return this.pllRecgnzd; }
    get touingOrTransfrbleJob() { return this.touingOrTransfrbleJob; }
    get monthlyOncmAsPerFiVisit() { return this.monthlyOncmAsPerFiVisit; }
    get IncmeAsPerFiVisit() { return this.IncmeAsPerFiVisit; }
    get area() { return this.area; }
    // get landPhoto(){return this.landPhoto; } 
    get noOfCrpsPerAnm() { return this.noOfCrpsPerAnm; }
    get typeOfCrp() { return this.typeOfCrp; }
    get yeildPerAcreMonthly() { return this.yeildPerAcreMonthly; }
    get pricePerunit() { return this.pricePerunit; }
    get incme() { return this.incme; }
    get typeOfHuose() { return this.typeOfHuose; }
    get electricityConnctnPresent() { return this.electricityConnctnPresent; }
    get accessToTubwll() { return this.accessToTubwll; }
    get irrigtnSysPresent() { return this.irrigtnSysPresent; }
    get noOfCattle() { return this.noOfCattle; }
    get typeOfGoodSold() { return this.typeOfGoodSold; }
    get noOfEmpls() { return this.noOfEmpls; }
    get inhuseSecCamPre() { return this.inhuseSecCamPre; }
    get posMachin() { return this.posMachin; }
    get acInstlld() { return this.acInstlld; }
    get avrgNoOfCustmrs() { return this.avrgNoOfCustmrs; }
    get avrgTicktSize() { return this.avrgTicktSize; }
    get numOfOperHoursInAday() { return this.numOfOperHoursInAday; }
    get montlySales() { return this.montlySales; }
    get annualTurnover() { return this.annualTurnover; }
    get prftMargn() { return this.prftMargn; }
    get estmtdIncmeAsPerFi() { return this.estmtdIncmeAsPerFi; }
    get declrdIncmeDurngApp() { return this.declrdIncmeDurngApp; }
    get finalIncme() { return this.finalIncme; }
    get latestWatrBill() { return this.latestWatrBill; }
    get paymntPrfShwn() { return this.paymntPrfShwn; }
    get latestTelephoneBill() { return this.latestTelephoneBill; }
    get paymntPrfShwnforTeleBill() { return this.paymntPrfShwnforTeleBill; }
    get latestElecBill() { return this.latestElecBill; }
    get paymntPrfShwnforEleBill() { return this.paymntPrfShwnforEleBill; }
    get pattaDocAvail() { return this.pattaDocAvail; }
    get ownEqupmntTools() { return this.ownEqupmntTools; }
    get listOfEqupmntToolsOwnd() { return this.listOfEqupmntToolsOwnd; }
    get affilatnToECommrce() { return this.affilatnToECommrce; }
    get avrgPrffFeeSer_rs() { return this.avrgPrffFeeSer_rs; }
    get noOfServcReqCatInMonths() { return this.noOfServcReqCatInMonths; }
    get estimatedSerIncmAsPerFi() { return this.estimatedSerIncmAsPerFi; }
    get typOfVehclOwnd() { return this.typOfVehclOwnd; }
    get noOfvehclesOwnd() { return this.noOfvehclesOwnd; }
    get estmtdAvrgIncmPerMnth() { return this.estmtdAvrgIncmPerMnth; }
    get noOfContractsAwardedInLast1Yrs() { return this.noOfContractsAwardedInLast1Yrs; }
    get doYouHveAnyGovContracts() { return this.doYouHveAnyGovContracts; }
    get estimtdtotalMnthlyIncme() { return this.estimtdtotalMnthlyIncme; }
    get noOfProprtsRentd() { return this.noOfProprtsRentd; }
    get incmePerMonthProprty() { return this.incmePerMonthProprty; }
    get incmePerMonth() { return this.incmePerMonth; }
    get noOfAttmpts() { return this.noOfAttmpts; }
    get fiObservtn() { return this.fiObservtn; }
    get fiFeedback() { return this.fiFeedback; }
    get offFiAccptdRegctd() { return this.offFiAccptdRegctd; }


    saveRecord() {
        console.log(122, this.FieldInvestigationRecord.Name);
        //insertRecord({record_FI: this.FieldInvestigationRecord })
        //insertRecord()
        const recordInput = { record_FI: this.FieldInvestigationRecord };
        console.log('recordInput -- > ', JSON.stringify(recordInput));
        // updateRecord(recordInput)  
        createRecord(recordInput)
            .then(result => {
                console.log(result);
                // this.template.querySelectorAll('lightning-input').forEach(each => {each.value = '';});
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record created successfully!',
                    variant: 'success',
                    mode: 'dismissable'
                });

                //this.dispatchEvent(evt);
                //this.dispatchEvent(new CustomEvent("closemodal"));
            })
            .catch(error => {
                console.log(error);
            });
    }

    previewImage(event) {
        console.log('dataset id', event.target.dataset.id);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    setProfile(incomeDetails) {
        //console.log('incomeDetails::',incomeDetails);
        
        console.log('isPrimaryIncomeSourceTrue ',this.isPrimaryIncomeSourceTrue,' hete 0 isSelfEmployed ',this.isSelfEmployed , ' incomeDetails.Profile__r.Sub_Bucket_Desc__c ',incomeDetails?.Profile__r?.Sub_Bucket_Desc__c, ' incomeDetails.Profile__r.Category__c ',incomeDetails?.Profile__r?.Category__c);
        if(incomeDetails?.Profile__r?.Category__c=='SENP'){
            switch (incomeDetails?.Profile__r?.Sub_Bucket_Desc__c) {
                case 'OWN SHOP / STORE':
                    this.profileShop = true;
                    break;
                case 'SERVICE ORIENTED':
                    this.profileService = true;
                    break;
                case 'AGRICULTURE':
                    this.profileAgriculture = true;
                    console.log('profileAgriculture', this.profileAgriculture);
                    this.isrequired = false; 
                    break;
                case 'CONTRACTOR':
                    this.profileContracter = true;
                    break;
                case 'RENTAL INCOME':
                    this.profileRental = true;
                    break;
                case 'TRANSPORTER':
                    this.profileTransporter = true;
                    break;
                case 'PENSION INCOME':
                    this.profilePension = true;
                    break;
                default:
                    this.selfEmpIpNipLabel='SENP - IP/NIP';
                    this.profileIPNIP = true;
            }

        }else if((incomeDetails?.Profile__r?.Category__c=='NE' || incomeDetails?.Profile__r?.Category__c=='SAL') && incomeDetails?.Profile__r?.Sub_Bucket_Desc__c =='PENSION INCOME' ){
    
           this.PensionIncomeLabel='PENSION INCOME';
            this.profilePensions = true;
        }
        else if(incomeDetails?.Profile__r?.Category__c=='SEP'){
            this.selfEmpIpNipLabel='SEP - IP/NIP';
            this.profileIPNIP = true;
        }
        /* this.profileAgriculture = false;
        this.profileShop = false;
        this.profileService = false;
        this.profileTransporter = false;
        this.profileContracter = false;
        this.profileRental = false;
        this.profilePension = false;
        this.profileIPNIP = false; */

        /* if(this.profileName == 'SENP - IP/NIP'){
            this.profileIPNIP = true;
        }else if(this.profileName == 'SENP - Agriculture'){
            this.profileAgriculture = true;
        }else if(this.profileName == 'SENP - Own Shop/Store'){
            this.profileShop = true;
        }else if(this.profileName == 'SENP - Service oriented'){
            this.profileService = true;
        }else if(this.profileName == 'SENP - Transporter'){
            this.profileTransporter = true; 
        }else if(this.profileName == 'SENP - Contractor'){
            this.profileContracter = true;
        }else if(this.profileName == 'SENP - Rental Income'){
            this.profileRental = true; 
        }else{
            this.profilePension = true;
        } */

    }

    filesList;
    /* @wire(getDocumentsOfFI, {applicationId: '$applicationId'})
     wiredResult({data, error}){ 
         if(data){
             this.filesList = data;
             this.inputWrapper['signatureView'] = { label: 'Signature View', value: this.filesList.signatureView };
            // this.inputWrapper['viewResidencefrontview'] = { label: 'View Residence front view', value: this.filesList.viewResidencefrontview };
         }
         else if (error) { 
             if(error.body.message) {
                  this.ShowToast(Error,error.body.message,'error','sticky');
             } else {
                 this.ShowToast('Error!','Currently server is down, Please contact System Administrator','error','sticky');
             }
         }
     } */
    //Open
    createDocument(docType, recordType) {
        createDocumentRecord({caseId: this.recordId, applicantId: this.applicantId, loanApplicationId: this.applicationId, documentType: docType, recordTypeName: recordType })
            .then((response) => {
                this.documentId = response;

                //CISP-4267 start
                if(docType==this.label.officeFrontView){
                    const docFields = {};
                    docFields[DOC_ID_FIELD.fieldApiName] = this.documentId;
                    docFields[ADDRESS_TYPE.fieldApiName] = this.label.Document_Office_Address_Type;
                    this.updateRecordDetails(docFields);
                }
                //CISP-4267 end
                this.isFileUpload = true;
            })
            .catch((error) => {
                    this.showToast(Error, 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                
            });
    }
    //Close
    onChangeAvgFeeChange(event){
        this.avrgPrffFeeSer_rs = event.target.value;
        let cater = isNaN(this.noOfServcReqCatInMonths)?0:this.noOfServcReqCatInMonths;
        this.estimatedSerIncmAsPerFi = event.target.value * cater;
    }
    onChangeCater(event){       
        this.noOfServcReqCatInMonths = event.target.value;
        let avgFee = isNaN(this.avrgPrffFeeSer_rs)?0:this.avrgPrffFeeSer_rs;
        this.estimatedSerIncmAsPerFi = event.target.value * avgFee;
    }

    onyeildPerAcreMonthly(event){
        this.yeildPerAcreMonthly = event.target.value;
        let yeildPrice = isNaN(this.yeildPerAcreMonthly)?0:this.yeildPerAcreMonthly;
        this.incme = event.target.value * yeildPrice;
    }
    onpricePerunit(event){       
        this.pricePerunit = event.target.value;
        let unitPrice = isNaN(this.pricePerunit)?0:this.pricePerunit;
        this.incme = event.target.value * unitPrice;
    }
    /*handleInputChange(event) {
        console.log('value = ', event.target.value);
        let feedback = this.template.querySelector('[data-id="fiFeedback"]');
        //console.log('feedback = ', feedback);
        this.fiFeedback = event.target.value;

        if (/^[a-zA-Z]*$/.test(this.fiFeedback)) {
            console.log('Inside if = ');

            feedback.setCustomValidity('');
        } else {
            console.log('Inside else = ');

            feedback.setCustomValidity('Please enter letter only');
        }
        feedback.reportValidity();
    }*/
    async handleSubmit(event){
        event.stopPropagation();
        event.preventDefault();
        //CISP-2727
        let mandatoryFieldsFill = true;
        await this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()){
                mandatoryFieldsFill = false;
            }
        });
        await this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if(!element.reportValidity()){
                mandatoryFieldsFill = false;
            }
        });
        // CISP-2701-START
        // if(this.coordinatesDistance > 300 && !this.disabledCapturedBtn){
            //     const evt = new ShowToastEvent({
                //         title: '',
                //         message: `Distance ${this.coordinatesDistance} between the Address as per application and Current FI location is not within the range. Please recapture.`,
                //         variant: 'error',
                //         mode: 'sticky'
            //     });
            //     this.dispatchEvent(evt);
            //     return;
        // }
        // CISP-2701-END
        //CISP-2727-END
        console.log('coordinatesDistance ', this.coordinatesDistance);
        this.isSpinnerMoving=true;
        console.log('here ',this.imageExist);
        await this.fetchContentDocumentId(this.label.officeFrontView);
        console.log('here ',this.imageExist);
        
        this.isSpinnerMoving=false;
        if(this.imageExist && mandatoryFieldsFill && (this.coordinatesDistance || this.coordinatesDistance == 0 || this.disabledCapturedBtn)){//CISP-2727
            this.template.querySelector('lightning-record-edit-form').submit();
            //CISP-2727-START
            const fields = {};
            fields[SAME_ADDRESS.fieldApiName] = this.smeAddAsInApp == 'Yes' ? true : false;
            this.template.querySelector("lightning-record-edit-form").submit(fields);
        }else if(!mandatoryFieldsFill){        
            this.showToast(Please_fill_all_the_mandatory_fields, '', 'error', 'dismissable');
            //CISP-2727-END
        }else if(!this.coordinatesDistance && this.imageExist){   //CISP-2701     
            this.showToast('Please Capture FI Latitude & Longitude first.', '', 'error', 'dismissable');//CISP-2701
        }else{        
            this.showToast('Please Upload Building front View', '', 'error', 'dismissable');
        }
     
    }


    async fetchContentDocumentId(docType){
        
        this.isSpinnerMoving=true;
        await getContentDocumentId({ applicantId: this.applicantId,  docType: docType  })
        .then((response) => {
        this.isSpinnerMoving=false;
            console.log('response getContentDocumentId : ',response);
            if(response!=null){
                this.imageExist=true;
            }else{
                this.imageExist=false;
            }
        })
        .catch((error) => {
            
        this.isSpinnerMoving=false;
        this.imageExist=false;
            console.log('error : ',error);});
    }

    //CISP-2701-START
    watchId;
    async fiLatitudeLongitude(event){
        try {
            this.isSpinnerMoving = true;
            console.log('navigator.geolocation ', navigator.geolocation);
            var thisins = this;
            this.watchId = await navigator.geolocation.watchPosition(
                function (position)  { 
                    console.log("i'm tracking you! ", position?.coords?.latitude); 
                    console.log("i'm tracking you! ", position?.coords?.longitude); 
                    navigator.geolocation.clearWatch(thisins.watchId);

                    navigator.geolocation.getCurrentPosition(position => {
                        var latitude = position.coords.latitude;//CISP-3099
                        var longitude = position.coords.longitude;//CISP-3099
                        console.log('Test '+longitude+ latitude);
          
                        updateActualGeoLocationDetails({ fiId: thisins.recordId, lattitude: latitude, longitude: longitude })
                        .then(() => {
                            thisins.callGeoApi();
                        })
                        .catch((error) => {
                            thisins.isSpinnerMoving = false;
                            console.log('error updateActualGeoLocationDetails ',error);
                            thisins.showToast('Error', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                            
                        });
                    });
                },
                function (error) {
                    if (error.code == error.PERMISSION_DENIED){
                        thisins.isSpinnerMoving = false;
                        thisins.showToast('Error', 'Plese provide the location access to the browser.', 'error', 'sticky');
                        console.log("you denied me :-(");
                        return;
                    }
              });

              console.log('this.watchId ', this.watchId);

                setTimeout(() => {
                    thisins.isSpinnerMoving = false;
                    navigator.geolocation.clearWatch(thisins.watchId);
                }, 1000);

        } catch (error) {
            this.isSpinnerMoving = false;
            this.showToast('Error', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
            console.log('fiLatitudeLongitude ' , error);
            console.log('fiLatitudeLongitude ' , event);
        }
    }
    async callGeoApi(){
        await retryCountIncrease({'loanApplicationId':this.applicationId, 'fieldInvestigation': this.recordId}).then(result=>{//CISP-3069
            this.disabledCapturedBtn = result;
        });
        if(this.disabledCapturedBtn){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Retry Exhausted',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.isSpinnerMoving = false;
            return;
        }else{
            this.showToast('Success', 'Actual Geo code details updated Succesfully', 'success', 'sticky');
            await doGeoCoderAPI({ 'fiId': this.recordId, 'loanApplicationId': this.applicationId })
                .then(result => {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'KYC Geo Code Details updated successfully!',
                        variant: 'success',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                })
                .catch(error => {
                    this.isSpinnerMoving = false;
                    console.log('error doGeoCoderAPI ',error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong, please contact your admin!',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                });
                await getFieldInvestigation({'fieldInvestigationId':this.recordId}).then(result=>{
                    this.isSpinnerMoving = false;
                    console.log('result ', result);
                    if(result){
                        this.coordinatesDistance = result.Coordinates_Distance__c ? result.Coordinates_Distance__c: null;
                    }
                }).catch(error=>{
                    this.isSpinnerMoving = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong, please contact your admin!',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                })
        }
    }
    @track coordinatesDistance;//CISP-3155
    //CISP-2701-END
    
    validateFields(){
        console.log('validateFields : ');
        //console.log('feedback = ', feedback);
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()){
                this.showToast(Please_fill_all_the_mandatory_fields, '', 'error', 'dismissable');
            }
        });
        let feedback = this.template.querySelector('[data-id="fiFeedback"]');
        this.fiFeedback = feedback.value;
        if (feedback.value!=''   && /^[a-zA-Z ]*$/.test(this.fiFeedback)) {
            console.log('Inside if = ',this.fiFeedback); 
            if(feedback.value!=null && feedback.value.length<3 ){
                this.showToast(Length_is_too_short_of_FI_Feedback, '', 'error', 'dismissable');
            }
        } else if ( this.fiFeedback!='' ) {
            console.log('Inside else = ',this.fiFeedback);
            this.showToast(Please_enter_letter_only_for_FI_Feedback, '', 'error', 'dismissable');
        }

        // if(this.isPrimaryIncomeSourceTrue){
            
        //     let nameOfPersonMet = this.template.querySelector('[data-id="nameOfPersonMet"]');
        //     this.nameOfPersonMetVal = nameOfPersonMet.value;
        //     if (nameOfPersonMet.value!=''  && /^[a-zA-Z ]*$/.test(this.nameOfPersonMetVal)) {
        //         console.log('Inside nameOfPersonMetVal = ',this.nameOfPersonMetVal);
        //         if(nameOfPersonMet.value!=null && (nameOfPersonMet.value.length<3 || nameOfPersonMet.value.length>26)  ){
        //             this.showToast(Length_is_too_short_long_of_Name_of_person_met, '', 'error', 'dismissable');
        //         }
        //     } else if (this.nameOfPersonMetVal!=''  ) {
        //         console.log('Inside nameOfPersonMetVal else = ',this.nameOfPersonMetVal);
        //         this.showToast(Please_enter_letter_only_for_Name_of_person_met, '', 'error', 'dismissable');
        //     }

        // }
        
        
    }
    NameChangeEvent(){
        let nameofPersonInput = this.template.querySelector('lightning-input[data-id=nameOfPersonMet]');
        let nameOfPersnMet = nameofPersonInput.value;

        this.nameOfPersnMet = nameOfPersnMet;
        if (nameOfPersnMet.length > 26) {
            nameofPersonInput.setCustomValidity(this.label.lastNameError);
        } else {
            nameofPersonInput.setCustomValidity("");
        }

        let hasConsecativeNumber = /(.)\1\1/.test(nameOfPersnMet);

        // if((nameOfPersnMet.charAt(0) === nameOfPersnMet.charAt(1)) 
        //          && (nameOfPersnMet.charAt(0) === nameOfPersnMet.charAt(2))){
        //         nameofPersonInput.setCustomValidity(this.label.lastNameError);
        // }

        if(hasConsecativeNumber){
            nameofPersonInput.setCustomValidity(this.label.lastNameError);
        }
        nameofPersonInput.reportValidity();
    }
    
    handleOwnEquipmentTools(event){
        console.log('handleOwnEquipmentTools ',event.target.value);
        if(event.target.value=='Yes'){
            this.disablelistOfEqupmntToolsOwnd=false;
            this.requiredlistOfEqupmntToolsOwnd=true;
        }else{
            this.disablelistOfEqupmntToolsOwnd=true;
            this.requiredlistOfEqupmntToolsOwnd=false;
        }
    }
}