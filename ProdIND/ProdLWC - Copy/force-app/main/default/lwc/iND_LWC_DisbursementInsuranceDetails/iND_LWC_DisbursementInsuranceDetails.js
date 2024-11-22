import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningCardApplyCSS from "@salesforce/resourceUrl/loanApplication";
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import Insurance_Details from '@salesforce/label/c.Insurance_Detail';
import getIstInsurancePremiumPaidByDDValues from '@salesforce/apex/LoanDisbursementController.getIstInsurancePremiumPaidByDDValues';
import handleInsuranceSubmit from '@salesforce/apex/LoanDisbursementController.handleInsuranceSubmit';
//c/childimport loadInsuranceDetails from '@salesforce/apex/LoanDisbursementController.loadInsuranceDetails';
import loadInsuranceDetails from '@salesforce/apex/LoanDisbursementController.loadInsuranceDetails';
import InactiveInsuranceApplicationDocument from '@salesforce/apex/LoanDisbursementController.inactiveInsuranceApplicationDocument';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import isInsuranceProductSelected from '@salesforce/apex/LoanDisbursementController.isInsuranceProductSelected';//CISP-2490
import isDocumentPresentForInsuranceApplication from '@salesforce/apex/LoanDisbursementController.isDocumentPresentForInsuranceApplication';//CISP-2490
import isRevokedLead from '@salesforce/apex/LoanDisbursementController.isRevokedLead';

export default class IND_LWC_DisbursementInsuranceDetails extends LightningElement {
    @api dealId = '';
    @api recordid; //'00671000001DVrpAAG';
    @api applicantid;
    @api loanapplicantdetails;
    @api disablefields;
    label = {
        Insurance_Details,
        mandotoryDetailsNotProvide
    };
    @track isEnableUploadViewDoc = true;
    @track isEnableUploadInsuranceApplication = true;

    @api disbursementrecordid;
    InsuranceApplicationNumber = '';
    @track Installments = '';
    @track longtermpolicyavailable = 'Yes';
    @track longtermpolicyowndamageyrs = '1';
    @track policyAvailable = 'Yes';
    @track Insurer = '';
    @track RSD = '';
    @track FieldOwnDamagePremiumAddons = '';
    @track ThirdPartyPremiumsPACover = '';
    @track GST = '';
    IDV = '';
    OwnDamagePremium = '';
    ThirdPartyPremium = '';
    IDV2 = '';
    OwnDamagePremium2 = '';
    ThirdPartyPremium2 = '';
    IDV3 = '';
    OwnDamagePremium3 = '';
    ThirdPartyPremium3 = '';
    IDV4 = '';
    OwnDamagePremium4 = '';
    ThirdPartyPremium4 = '';
    IDV5 = '';
    OwnDamagePremium5 = '';
    ThirdPartyPremium5 = '';

    //Nominee details properties
    isCoBorrowerPresent = false;
    borrowerName;
    borrowerDOB;
    borrowerRelationship;
    borrowerAddress;
    borrowerSpouseGender;
    borrowerSpouseDOB;
    borrowerFirstChildName;
    borrowerFirstChildGender;
    borrowerFirstChildDOB;
    borrowerSecondChildName;
    borrowerSecondChildGender;
    borrowerSecondChildDOB;
    borrowerThirdChildName;
    borrowerThirdChildGender;
    borrowerThirdChildDOB;
    borrowerFatherDOB;
    borrowerMotherDOB;
    borrowerInsuDoneBy;
    coBorrowerName;
    coBorrowerDOB;
    coBorrowerRelationship;
    coBorrowerAddress;
    coBorrowerSpouseGender;
    coBorrowerSpouseDOB;
    coBorrowerFirstChildName;
    coBorrowerFirstChildGender;
    coBorrowerFirstChildDOB;
    coBorrowerSecondChildName;
    coBorrowerSecondChildGender;
    coBorrowerSecondChildDOB;
    coBorrowerThirdChildName;
    coBorrowerThirdChildGender;
    coBorrowerThirdChildDOB;
    coBorrowerFatherDOB;
    coBorrowerMotherDOB;
    coBorrowerInsuDoneBy;
    @track vehiclerecordid;
	@track insuAppNumberRequired = false;//CISP-3111
	insuBusiDoneByBorroRequired = false;
    insuBusiDoneByCoBorRequired = false;
    firstyrInsurance = false;
    isGPAorCOMBOSelected = false; //CISP-2490
    isPassengerVehicles=false;
    isBoNomineeRequired=false;
    isBofamilyRequired=false;
    appBorrowerName;
    isCoNomineeRequired=false;
    isCofamilyRequired =false;
    appCoborrowerName;

    @track nomineeGenderOptions;

    @track nomineeRelationshipOptions;

    @track nomineeInsDoneByOptions;
	
	@track nomineeInsDoneByOptionsCob;

    @track InstallmentsOptions = [

    ];

    @track longtermpolicyavailableOptions = [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        }
    ];

    @track longtermpolicyowndamageyrsOptions;
    @track policyavailableOptions = [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        }
    ];
    @track InsurerOptions = [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        }
    ];


    @track isSpinnerMoving = false;

    @track uploadViewDocFlag;
    @track uploadInsuranceDocFlag;

    disableInstallments = false;
    @track disablelongTermPolicy = false;
    usedVehid = false;
    @track disableLongTermPolicyField = false;
    @track disablePolicyField = false;
    @track requiredLongTermPolicyField = true;
    @track requiredPolicyField = true;
    @track docType;
    @track showUpload;
    @track showPhotoCopy = false;
    @track showDocView = true;
    @track isVehicleDoc = true;
    @track isAllDocType = false;
isTractor;

    handleUploadViewDoc() {
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = false;
        this.isAllDocType = true;
        this.uploadViewDocFlag = true;
    }
    handleUploadVInsuranceApplication() {
        try {
            console.debug(this.applicantid);
            this.showUpload = true;
            this.showPhotoCopy = false;
            this.showDocView = true;
            this.isVehicleDoc = true;
            this.isAllDocType = false;
            this.uploadInsuranceDocFlag = true;
            this.docType = 'Insurance Application';
        } catch (err) {
            console.debug(err);
        }


    }

    get insuranceFieldIsRequired() {
        return !this.isTractor;
    } 

    get requiredLongTermPolicyFieldGetter() {
        return !this.isTractor && this.requiredLongTermPolicyField;
    }

    get requiredPolicyFieldGetter() {
        return !this.isTractor && this.requiredPolicyField;
    }
    
    @wire(getRecord, {
        recordId: '$recordid',
        fields: ['Opportunity.Vehicle_Type__c', 'Opportunity.Product_Type__c']
    })
    wiredLoanApp({
        error,
        data
    }) {
        console.debug('in wire' + data);
        console.debug('in wire' + error);
        let options = [{
            label: '1',
            value: '1'
        }];
        if (data) {
            console.debug('data I got::' + data);
this.isTractor = data.fields.Product_Type__c.value.toLowerCase() === 'tractor';
            if (data.fields.Vehicle_Type__c.value == 'New') {
                this.longtermpolicyavailable = 'Yes';
                this.disableLongTermPolicyField = true;
            }
            if (data.fields.Vehicle_Type__c.value == 'Used') {
                console.debug('used vehicle');
                this.usedVehi = true;
                this.longtermpolicyowndamageyrs = '';
                options.push({
                    label: '3',
                    value: '3'
                });
            }
        } else if (error) {
            console.debug('errorr I got::' + error);
        }
        this.longtermpolicyowndamageyrsOptions = options;
    }

    handleInputFieldChange(event) {
        const field = event.target.name;
        console.debug('field' + field);
        console.debug('fieldVal' + event.target.value);
        if (field === 'insuranceApplicationNoField') {
            this.InsuranceApplicationNumber = event.target.value;
        } else if (field === 'installmentsField') {
            this.Installments = event.target.value;
        } else if (field === 'longTermPolicyAvailableField') {
            this.longtermpolicyavailable = event.target.value;
            console.debug('longtermp::' + this.longtermpolicyavailable);
            console.debug('longtermp::' + this.usedVehi);

            if (this.longtermpolicyavailable.includes('No')) {
                this.disablelongTermPolicy = true;
                this.disablePolicyField = true;
                this.requiredLongTermPolicyField = false;
                this.requiredPolicyField = false;
            } else {
                this.disablelongTermPolicy = false;
                this.disablePolicyField = false;
                this.requiredLongTermPolicyField = true;
                this.requiredPolicyField = true;
            }
            if (this.policyAvailable) {
                if (this.policyAvailable.includes('No')) {
                    this.disablePolicyField = true;
                    this.requiredPolicyField = false;
                } else {
                    this.disablePolicyField = false;
                    this.requiredPolicyField = true;
                }
            }
        } else if (field === 'longTermPolicyOwnDamageYrsField') {
            this.longtermpolicyowndamageyrs = event.target.value;
        } else if (field === 'policyAvailableField') {
            this.policyAvailable = event.target.value;
            if (this.policyAvailable.includes('No')) {
                console.debug('disabling');
                this.disablePolicyField = true;
                this.requiredPolicyField = false;
            } else {
                this.disablePolicyField = false;
                this.requiredPolicyField = true;
            }
        } else if (field === 'insurerField') {
            this.Insurer = event.target.value;
        } else if (field === 'gstField') {
            this.GST = event.target.value;
        } else if (field === 'rsdField') {
            this.RSD = event.target.value;
        } else if (field === 'FieldOwnDamagePremiumAddons') {
            this.FieldOwnDamagePremiumAddons = event.target.value;
        } else if (field === 'ThirdPartyPremiumsPACover') {
            this.ThirdPartyPremiumsPACover = event.target.value;
        } else if (field === 'IDVinput') {
            this.IDV = event.target.value;
        } else if (field === 'OwnDamagePremiuminput') {
            this.OwnDamagePremium = event.target.value;
        } else if (field === 'ThirdPartyPremiuminput') {
            this.ThirdPartyPremium = event.target.value;
        } else if (field === 'IDVinput2') {
            this.IDV2 = event.target.value;
        } else if (field === 'OwnDamagePremiuminput2') {
            this.OwnDamagePremium2 = event.target.value;
        } else if (field === 'ThirdPartyPremiuminput2') {
            this.ThirdPartyPremium2 = event.target.value;
        } else if (field === 'IDVinput3') {
            this.IDV3 = event.target.value;
        } else if (field === 'OwnDamagePremiuminput3') {
            this.OwnDamagePremium3 = event.target.value;
        } else if (field === 'ThirdPartyPremiuminput3') {
            this.ThirdPartyPremium3 = event.target.value;
        } else if (field === 'IDVinput4') {
            this.IDV4 = event.target.value;
        } else if (field === 'OwnDamagePremiuminput4') {
            this.OwnDamagePremium4 = event.target.value;
        } else if (field === 'ThirdPartyPremiuminput4') {
            this.ThirdPartyPremium4 = event.target.value;
        } else if (field === 'IDVinput5') {
            this.IDV5 = event.target.value;
        } else if (field === 'OwnDamagePremiuminput5') {
            this.OwnDamagePremium5 = event.target.value;
        } else if (field === 'ThirdPartyPremiuminput5') {
            this.ThirdPartyPremium5 = event.target.value;
        }
        //for nominee detail fields
        else if(field === 'borrowerNameInput'){ 
            this.borrowerName = event.target.value;
        } else if(field === 'borrowerDOBInput'){ 
            this.borrowerDOB = event.target.value;
            this.validateDOB(this.borrowerDOB);
        } else if(field === 'borrowerRelationshipInput'){ 
            this.borrowerRelationship = event.target.value;
        } else if(field === 'borrowerAddressInput'){ 
            this.borrowerAddress = event.target.value;
        } else if(field === 'borrowerSpouseGenderInput'){ 
            this.borrowerSpouseGender = event.target.value;
        } else if(field === 'borrowerSpouseDOBInput'){ 
            this.borrowerSpouseDOB = event.target.value;
        } else if(field === 'borrowerFirstChildNameInput'){ 
            this.borrowerFirstChildName = event.target.value;
        } else if(field === 'borrowerFirstChildGenderInput'){ 
            this.borrowerFirstChildGender = event.target.value;
        } else if(field === 'borrowerFirstChildDOBInput'){ 
            this.borrowerFirstChildDOB = event.target.value;
        } else if(field === 'borrowerSecondChildNameInput'){ 
            this.borrowerSecondChildName = event.target.value;
        } else if(field === 'borrowerSecondChildGenderInput'){ 
            this.borrowerSecondChildGender = event.target.value;
        } else if(field === 'borrowerSecondChildDOBInput'){ 
            this.borrowerSecondChildDOB = event.target.value;
        } else if(field === 'borrowerThirdChildNameInput'){ 
            this.borrowerThirdChildName = event.target.value;
        } else if(field === 'borrowerThirdChildGenderInput'){ 
            this.borrowerThirdChildGender = event.target.value;
        } else if(field === 'borrowerThirdChildDOBInput'){ 
            this.borrowerThirdChildDOB = event.target.value;
        } else if(field === 'borrowerFatherDOBInput'){ 
            this.borrowerFatherDOB = event.target.value;
        } else if(field === 'borrowerMotherDOBInput'){
            this.borrowerMotherDOB = event.target.value;
        } else if(field === 'borrowerInsuDoneByInput'){ 
            this.borrowerInsuDoneBy = event.target.value;
        } else if(field === 'coBorrowerNameInput'){ 
            this.coBorrowerName = event.target.value;
        } else if(field === 'coBorrowerDOBInput'){ 
            this.coBorrowerDOB = event.target.value;
            this.validateDOB(this.coBorrowerDOB);
        } else if(field === 'coBorrowerRelationshipInput'){ 
            this.coBorrowerRelationship = event.target.value;
        } else if(field === 'coBorrowerAddressInput'){ 
            this.coBorrowerAddress = event.target.value;
        } else if(field === 'coBorrowerSpouseGenderInput'){ 
            this.coBorrowerSpouseGender = event.target.value;
        } else if(field === 'coBorrowerSpouseDOBInput'){ 
            this.coBorrowerSpouseDOB = event.target.value;
        } else if(field === 'coBorrowerFirstChildNameInput'){ 
            this.coBorrowerFirstChildName = event.target.value;
        } else if(field === 'coBorrowerFirstChildGenderInput'){ 
            this.coBorrowerFirstChildGender = event.target.value;
        } else if(field === 'coBorrowerFirstChildDOBInput'){ 
            this.coBorrowerFirstChildDOB = event.target.value;
        } else if(field === 'coBorrowerSecondChildNameInput'){ 
            this.coBorrowerSecondChildName = event.target.value;
        } else if(field === 'coBorrowerSecondChildGenderInput'){ 
            this.coBorrowerSecondChildGender = event.target.value;
        } else if(field === 'coBorrowerSecondChildDOBInput'){ 
            this.coBorrowerSecondChildDOB = event.target.value;
        } else if(field === 'coBorrowerThirdChildNameInput'){ 
            this.coBorrowerThirdChildName = event.target.value;
        } else if(field === 'coBorrowerThirdChildGenderInput'){ 
            this.coBorrowerThirdChildGender = event.target.value;
        } else if(field === 'coBorrowerThirdChildDOBInput'){ 
            this.coBorrowerThirdChildDOB = event.target.value;
        } else if(field === 'coBorrowerFatherDOBInput'){ 
            this.coBorrowerFatherDOB = event.target.value;
        } else if(field === 'coBorrowerMotherDOBInput'){ 
            this.coBorrowerMotherDOB = event.target.value;
        } else if(field === 'coBorrowerInsuDoneByInput'){ 
            this.coBorrowerInsuDoneBy = event.target.value;
        }

    }
    isRevokedLead;
    async connectedCallback() {
        await isRevokedLead({'loanApplicationId':this.recordid}).then(result=>{
            if(result){ this.isRevokedLead = true; }
        });
        getIstInsurancePremiumPaidByDDValues({
                loanApplicationId: this.recordid
            })
            .then(response => {
                console.debug("GetInsuranceDDValue : " + response);
                response.forEach(item => {
                    let pickVal = {
                        label: item,
                        value: item
                    };
                    console.debug(pickVal);
                    this.InstallmentsOptions = [...this.InstallmentsOptions, pickVal];
                    if (item.includes('By Bank (Funding)') || item.includes('BY CUSTOMER (UPFRONT)')) {
                        this.disableInstallments = true;
                        this.Installments = item;
                    }
                });

                this.isInstallmentsShow = false;
            });
        console.debug(this.recordid);
        loadInsuranceDetails({ loanApplicationId: this.recordid, dealId: this.dealId })
            .then(response => {
                console.debug(response);
                if (response) {
                    console.debug('loading insurance dertails');
                    let jsonObj = JSON.parse(response);
                    console.log('## jsonObj :: ', jsonObj);
					this.insuAppNumberRequired = jsonObj.isInsurancePresent;
					this.vehiclerecordid = jsonObj.vehicleID ? jsonObj.vehicleID : null;
                    this.firstyrInsurance = jsonObj.isInsurancePresent==false?true:false;//CISP-3111
					this.insuBusiDoneByBorroRequired = jsonObj.isInsurancePresentForBorro;
                    this.insuBusiDoneByCoBorRequired = jsonObj.isInsurancePresentForCobo;
                    this.disbursementrecordid = jsonObj.disbursementRecordId;
                    console.debug(this.disbursementrecordid);
                    this.InsuranceApplicationNumber = jsonObj.insuranceAppNo;
                    this.longtermpolicyavailable = jsonObj.longTermPolicyAvailable != null && jsonObj.longTermPolicyAvailable != '' ? jsonObj.longTermPolicyAvailable : this.longtermpolicyavailable;
                    this.policyAvailable = jsonObj.policyAvailable;
                    this.longtermpolicyowndamageyrs = jsonObj.longTermPolicyOwnDamageYrs;
                    this.FieldOwnDamagePremiumAddons = jsonObj.ownDamagePremiumAddons;
                    this.ThirdPartyPremiumsPACover = jsonObj.thirdPartyPremiumsPaCover;
                    this.Insurer = jsonObj.insurer;
                    this.RSD = jsonObj.rsd;
                    this.GST = jsonObj.gst;
                    this.IDV = jsonObj.firstYr_Idv;
                    this.OwnDamagePremium = jsonObj.firstYr_OwnDamagePremium;
                    this.ThirdPartyPremium = jsonObj.firstYr_ThirdPartyPremium;
                    this.IDV2 = jsonObj.secondYr_IDV;
                    this.OwnDamagePremium2 = jsonObj.secondYr_OwnDamagePremium;
                    this.ThirdPartyPremium2 = jsonObj.secondYr_ThirdPartyPremium;
                    this.IDV3 = jsonObj.thirdYr_IDV;
                    this.OwnDamagePremium3 = jsonObj.thirdYr_OwnDamagePremium;
                    this.ThirdPartyPremium3 = jsonObj.thirdYr_ThirdParty_Premium;
                    this.IDV4 = jsonObj.fourthYr_IDV;
                    this.OwnDamagePremium4 = jsonObj.fourthYr_OwnDamagePremium;
                    this.ThirdPartyPremium4 = jsonObj.fourthYr_ThirdPartyPremium;
                    this.IDV5 = jsonObj.fifthYr_Idv;
                    this.OwnDamagePremium5 = jsonObj.fifthYr_OwnDamagePremium;
                    this.ThirdPartyPremium5 = jsonObj.fifthYr_ThirdPartyPremium;
                    // console.debug(jsonObj.installments);
                    // console.debug(this.Installments);
                    this.Installments = jsonObj.installments;
                    if (this.longtermpolicyavailable.includes('No')) {
                        this.disablelongTermPolicy = true;
                        this.disablePolicyField = true;
                        this.requiredLongTermPolicyField = false;
                        this.requiredPolicyField = false;
                    }
                    if (this.policyAvailable.includes('No')) {
                        this.disablePolicyField = true;
                        this.requiredPolicyField = false;
                    }

                    //Add nominee details
                    this.isCoBorrowerPresent = jsonObj.isCoBorrowerPresent;
                    // if(this.isCoBorrowerPresent){//CISP-2548
                        this.nomineeGenderOptions = jsonObj.nomineeGenderOptions;
                        this.nomineeRelationshipOptions = jsonObj.nomineeRelationshipOptions;
                        this.nomineeInsDoneByOptions = jsonObj.nomineeInsDoneByOptions;
						this.nomineeInsDoneByOptionsCob = jsonObj.nomineeInsDoneByOptionsCob;
                        this.borrowerName = jsonObj.borrowerName;
                        this.borrowerDOB = jsonObj.borrowerDOB;
                        this.borrowerRelationship = jsonObj.borrowerRelationship;
                        this.borrowerAddress = jsonObj.borrowerAddress;
                        this.borrowerSpouseGender = jsonObj.borrowerSpouseGender;
                        this.borrowerSpouseDOB = jsonObj.borrowerSpouseDOB;
                        this.borrowerFirstChildName = jsonObj.borrowerFirstChildName;
                        this.borrowerFirstChildGender = jsonObj.borrowerFirstChildGender;
                        this.borrowerFirstChildDOB = jsonObj.borrowerFirstChildDOB;
                        this.borrowerSecondChildName = jsonObj.borrowerSecondChildName;
                        this.borrowerSecondChildGender = jsonObj.borrowerSecondChildGender;
                        this.borrowerSecondChildDOB = jsonObj.borrowerSecondChildDOB;
                        this.borrowerThirdChildName = jsonObj.borrowerThirdChildName;
                        this.borrowerThirdChildGender = jsonObj.borrowerThirdChildGender;
                        this.borrowerThirdChildDOB = jsonObj.borrowerThirdChildDOB;
                        this.borrowerFatherDOB = jsonObj.borrowerFatherDOB;
                        this.borrowerMotherDOB = jsonObj.borrowerMotherDOB;
                        this.borrowerInsuDoneBy = jsonObj.borrowerInsuDoneBy;
                        this.isPassengerVehicles = jsonObj.isPassengerVehicles;
                        this.isBoNomineeRequired = jsonObj.isBoNomineeRequired;
                        this.isBofamilyRequired = this.isPassengerVehicles ? !jsonObj.isBofamilyDisabled : false;
                        this.appBorrowerName = jsonObj.appBorrowerName;
                
                    if(this.isCoBorrowerPresent){//CISP-2548
                        this.coBorrowerName = jsonObj.coBorrowerName;
                        this.coBorrowerDOB = jsonObj.coBorrowerDOB;
                        this.coBorrowerRelationship = jsonObj.coBorrowerRelationship;
                        this.coBorrowerAddress = jsonObj.coBorrowerAddress;
                        this.coBorrowerSpouseGender = jsonObj.coBorrowerSpouseGender;
                        this.coBorrowerSpouseDOB = jsonObj.coBorrowerSpouseDOB;
                        this.coBorrowerFirstChildName = jsonObj.coBorrowerFirstChildName;
                        this.coBorrowerFirstChildGender = jsonObj.coBorrowerFirstChildGender;
                        this.coBorrowerFirstChildDOB = jsonObj.coBorrowerFirstChildDOB;
                        this.coBorrowerSecondChildName = jsonObj.coBorrowerSecondChildName;
                        this.coBorrowerSecondChildGender = jsonObj.coBorrowerSecondChildGender;
                        this.coBorrowerSecondChildDOB = jsonObj.coBorrowerSecondChildDOB;
                        this.coBorrowerThirdChildName = jsonObj.coBorrowerThirdChildName;
                        this.coBorrowerThirdChildGender = jsonObj.coBorrowerThirdChildGender;
                        this.coBorrowerThirdChildDOB = jsonObj.coBorrowerThirdChildDOB;
                        this.coBorrowerFatherDOB = jsonObj.coBorrowerFatherDOB;
                        this.coBorrowerMotherDOB = jsonObj.coBorrowerMotherDOB;
                        this.coBorrowerInsuDoneBy = jsonObj.coBorrowerInsuDoneBy;
                        this.isCoNomineeRequired = jsonObj.isCoNomineeRequired;
                        this.isCofamilyRequired = this.isPassengerVehicles ? !jsonObj.isCofamilyDisabled : false;
                        this.appCoborrowerName = jsonObj.appCoborrowerName;
                    }
                }
            })
            .catch(error => {
                this.tryCatchError = error;
                console.debug(error);
                this.errorInCatch();
            });
        // loadInsuranceDetails({
        //         loanApplicationId: this.recordid
        //     })
        //     .then(response => {
        //         console.debug('loading insurance dertails');
        //         console.debug((response));
        //         let jsonObj = JSON.parse(response);
        //         this.disbursementrecordid = jsonObj.disbursementRecordId;
        //         console.debug(this.disbursementrecordid);
        //         this.InsuranceApplicationNumber = jsonObj.insuranceAppNo;

        //         this.longtermpolicyavailable = jsonObj.longTermPolicyAvailable;
        //         console.debug('POLI AVAI' + jsonObj.policyAvailable);
        //         this.policyAvailable = jsonObj.policyAvailable;
        //         this.longtermpolicyowndamageyrs = jsonObj.longTermPolicyOwnDamageYrs;
        //         this.FieldOwnDamagePremiumAddons = jsonObj.ownDamagePremiumAddons;
        //         this.ThirdPartyPremiumsPACover = jsonObj.thirdPartyPremiumsPaCover;

        //         this.Insurer = jsonObj.insurer;
        //         this.RSD = jsonObj.rsd;
        //         this.GST = jsonObj.gst;
        //         this.IDV = jsonObj.firstYr_Idv;
        //         this.OwnDamagePremium = jsonObj.firstYr_OwnDamagePremium;
        //         this.ThirdPartyPremium = jsonObj.firstYr_ThirdPartyPremium;
        //         this.IDV2 = jsonObj.secondYr_IDV;
        //         this.OwnDamagePremium2 = jsonObj.secondYr_OwnDamagePremium;
        //         this.ThirdPartyPremium2 = jsonObj.secondYr_ThirdPartyPremium;
        //         this.IDV3 = jsonObj.thirdYr_IDV;
        //         this.OwnDamagePremium3 = jsonObj.thirdYr_OwnDamagePremium;
        //         this.ThirdPartyPremium3 = jsonObj.thirdYr_ThirdParty_Premium;
        //         this.IDV4 = jsonObj.fourthYr_IDV;
        //         this.OwnDamagePremium4 = jsonObj.fourthYr_OwnDamagePremium;
        //         this.ThirdPartyPremium4 = jsonObj.fourthYr_ThirdPartyPremium;
        //         this.IDV5 = jsonObj.fifthYr_Idv;
        //         this.OwnDamagePremium5 = jsonObj.fifthYr_OwnDamagePremium;
        //         this.ThirdPartyPremium5 = jsonObj.fifthYr_ThirdPartyPremium;
        //         this.Installments = jsonObj.installments;

        //     })

    }
    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
        let inputFields = this.template.querySelectorAll('.slds-form-element__control');
        if (this.disablefields) {
            for (let input of inputFields) {
                input.disabled = true;
            }
        }
        if(this.isRevokedLead){
            this.template.querySelectorAll('*').forEach(element=>{
                element.disabled = true;
            });
        }
    }
    async handleSubmit(event) {
        let isValid = true;
        //CISP-2490 -- start
       /* await isInsuranceProductSelected({ loanApplicationId: this.recordid })
        .then((response) => {
            console.log('resp is ',response)
            if(response === true)
            {
                this.isGPAorCOMBOSelected = true;
            }
        })
        .catch((err) => {
            console.log('error ',err)
        })
         if(this.isGPAorCOMBOSelected)
        {
            await isDocumentPresentForInsuranceApplication({loanApplicationId: this.recordid, dealId: this.dealId})
            .then((resp) => {
                if(resp === false) {
                    isValid = false;
                    const event = new ShowToastEvent({
                        title: 'Required Documents',
                        message: 'Please upload the Insurance Application Document.',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
            })
            let borrowerFields = this.template.querySelectorAll('lightning-input[data-name=borrowerFields]');
            borrowerFields.forEach( brwField => {
                if(brwField.name === 'borrowerNameInput') {
                    if(!brwField.checkValidity()){
                        brwField.reportValidity();
                        isValid = false;
                    }
                }
                else if(brwField.name === 'borrowerDOBInput') {
                    if(!brwField.checkValidity()){
                        brwField.reportValidity();
                        isValid = false;
                    }else if (!this.validateDOB(this.borrowerDOB)){
                        isValid = false;
                    }
                }
                else if(brwField.name === 'borrowerAddressInput') {
                    if(!brwField.checkValidity()){
                        brwField.reportValidity();
                        isValid = false;
                    }
                }
            })
            let comboboxFieldsValidation = this.template.querySelectorAll('lightning-combobox[data-name=insuranceFieldValidation]');
            comboboxFieldsValidation.forEach(inputField => {
                if (!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                }
            });
            if(this.isCoBorrowerPresent)
            {
                let coborrowerFields = this.template.querySelectorAll('lightning-input[data-name=coborrowerFields]');
                coborrowerFields.forEach( cobrwField => {
                    if(cobrwField.name === 'coBorrowerNameInput') {
                        if(!cobrwField.checkValidity()){
                            cobrwField.reportValidity();
                            isValid = false;
                        }
                    }
                    else if(cobrwField.name === 'coBorrowerDOBInput') {
                        if(!cobrwField.checkValidity()){
                            cobrwField.reportValidity();
                            isValid = false;
                        }
                    }else if (!this.validateDOB(this.coBorrowerDOB)){
                        isValid = false;
                    }
                    else if(cobrwField.name === 'coBorrowerAddressInput') {
                        if(!cobrwField.checkValidity()){
                            cobrwField.reportValidity();
                            isValid = false;
                        }
                    }
                })
                let comboboxFieldsValidationCbr = this.template.querySelectorAll('lightning-combobox[data-name=insuranceFieldValidationCoborrower]');
                comboboxFieldsValidationCbr.forEach(inputField => {
                    if (!inputField.checkValidity()) {
                        inputField.reportValidity();
                        isValid = false;
                    }
                });
            }
        } */
        //CISP-2490 -- end

        console.debug(this.template.querySelectorAll('lightning-input[data-name=insuranceField]'));
        //let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input[data-name=insuranceField]');
        inputFields.forEach(inputField => {
            console.log('inputField:', inputField);
            if(inputField.name === 'insuranceApplicationNoField'){
                if(this.insuAppNumberRequired && !inputField.checkValidity()){
                    inputField.reportValidity();
                    isValid = false;
                }
            } else if(inputField.name === 'borrowerInsuDoneByInput'){
                if(this.insuBusiDoneByBorroRequired && !inputField.checkValidity()){
                    inputField.reportValidity();
                    isValid = false;
                }
            } else if(inputField.name === 'coBorrowerInsuDoneByInput'){
                if(this.insuBusiDoneByCoBorRequired && !inputField.checkValidity()){
                    inputField.reportValidity();
                    isValid = false;
                }
            } else {
                if (!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                }
            }
        });
        let comboboxFields = this.template.querySelectorAll('lightning-combobox[data-name=insuranceField]');
        comboboxFields.forEach(inputField => {
            console.log('inputField:', inputField);
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        let inputData = {};
        inputData.disbursementRecordId = this.disbursementrecordid;
        console.debug('disbursement in save id ::' + this.disbursementrecordid);
        inputData.insuranceAppNo = this.InsuranceApplicationNumber;
        inputData.installments = this.Installments;
        inputData.longTermPolicyAvailable = this.longtermpolicyavailable;
        inputData.longTermPolicyOwnDamageYrs = this.longtermpolicyowndamageyrs;
        inputData.policyAvailable = this.policyAvailable;
        inputData.insurer = this.Insurer;
        inputData.rsd = this.RSD;
        inputData.ownDamagePremiumAddons = this.FieldOwnDamagePremiumAddons;
        inputData.thirdPartyPremiumsPaCover = this.ThirdPartyPremiumsPACover;
        inputData.gst = this.GST;
        inputData.firstYr_Idv = this.IDV;
        inputData.firstYr_OwnDamagePremium = this.OwnDamagePremium;
        inputData.firstYr_ThirdPartyPremium = this.ThirdPartyPremium;
        inputData.secondYr_IDV = this.IDV2;
        inputData.secondYr_OwnDamagePremium = this.OwnDamagePremium2;
        inputData.secondYr_ThirdPartyPremium = this.ThirdPartyPremium2;
        inputData.thirdYr_IDV = this.IDV3;
        inputData.thirdYr_OwnDamagePremium = this.OwnDamagePremium3;
        inputData.thirdYr_ThirdParty_Premium = this.ThirdPartyPremium3;
        inputData.fourthYr_IDV = this.IDV4;
        inputData.fourthYr_OwnDamagePremium = this.OwnDamagePremium4;
        inputData.fourthYr_ThirdPartyPremium = this.ThirdPartyPremium4;
        inputData.fifthYr_Idv = this.IDV5;
        inputData.fifthYr_OwnDamagePremium = this.OwnDamagePremium5;
        inputData.fifthYr_ThirdPartyPremium = this.ThirdPartyPremium5;

        //Add nominee details
        inputData.isCoBorrowerPresent = this.isCoBorrowerPresent;
        // if(this.isCoBorrowerPresent){//CISP-2548
            inputData.borrowerName = this.borrowerName;
            inputData.borrowerDOB = this.borrowerDOB;
            inputData.borrowerRelationship = this.borrowerRelationship;
            inputData.borrowerAddress = this.borrowerAddress;
            inputData.borrowerSpouseGender = this.borrowerSpouseGender;
            inputData.borrowerSpouseDOB = this.borrowerSpouseDOB;
            inputData.borrowerFirstChildName = this.borrowerFirstChildName;
            inputData.borrowerFirstChildGender = this.borrowerFirstChildGender;
            inputData.borrowerFirstChildDOB = this.borrowerFirstChildDOB;
            inputData.borrowerSecondChildName = this.borrowerSecondChildName;
            inputData.borrowerSecondChildGender = this.borrowerSecondChildGender;
            inputData.borrowerSecondChildDOB = this.borrowerSecondChildDOB;
            inputData.borrowerThirdChildName = this.borrowerThirdChildName;
            inputData.borrowerThirdChildGender = this.borrowerThirdChildGender;
            inputData.borrowerThirdChildDOB = this.borrowerThirdChildDOB;
            inputData.borrowerFatherDOB = this.borrowerFatherDOB;
            console.log('this.borrowerMotherDOB : ' + this.borrowerMotherDOB);
            inputData.borrowerMotherDOB = this.borrowerMotherDOB;
            console.log('inputData.borrowerMotherDOB : ' + inputData.borrowerMotherDOB);
            inputData.borrowerInsuDoneBy = this.borrowerInsuDoneBy;

            // CISP-2548
        if(this.isCoBorrowerPresent){
            inputData.coBorrowerName = this.coBorrowerName;
            inputData.coBorrowerDOB = this.coBorrowerDOB;
            inputData.coBorrowerRelationship = this.coBorrowerRelationship;
            inputData.coBorrowerAddress = this.coBorrowerAddress;
            inputData.coBorrowerSpouseGender = this.coBorrowerSpouseGender;
            inputData.coBorrowerSpouseDOB = this.coBorrowerSpouseDOB;
            inputData.coBorrowerFirstChildName = this.coBorrowerFirstChildName;
            inputData.coBorrowerFirstChildGender = this.coBorrowerFirstChildGender;
            inputData.coBorrowerFirstChildDOB = this.coBorrowerFirstChildDOB;
            inputData.coBorrowerSecondChildName = this.coBorrowerSecondChildName;
            inputData.coBorrowerSecondChildGender = this.coBorrowerSecondChildGender;
            inputData.coBorrowerSecondChildDOB = this.coBorrowerSecondChildDOB;
            inputData.coBorrowerThirdChildName = this.coBorrowerThirdChildName;
            inputData.coBorrowerThirdChildGender = this.coBorrowerThirdChildGender;
            inputData.coBorrowerThirdChildDOB = this.coBorrowerThirdChildDOB;
            inputData.coBorrowerFatherDOB = this.coBorrowerFatherDOB;
            inputData.coBorrowerMotherDOB = this.coBorrowerMotherDOB;
            inputData.coBorrowerInsuDoneBy = this.coBorrowerInsuDoneBy;
        }
        console.debug('JSON to save ' + JSON.stringify(inputData));
        console.debug('Record Id :: ' + this.recordid);
        if((this.isBoNomineeRequired && (!this.borrowerName || !this.borrowerDOB || !this.borrowerRelationship || !this.borrowerAddress)) || (this.isCoNomineeRequired && (!this.coBorrowerName || !this.coBorrowerDOB || !this.coBorrowerRelationship || !this.coBorrowerRelationship || !this.coBorrowerAddress))){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please fill All the Fields in the Nominee Details',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }else if((this.isNomineRequired && this.appBorrowerName && this.borrowerName && (this.appBorrowerName.trim() == this.borrowerName.trim())) || (this.coBorrowerName && this.appCoborrowerName && this.coBorrowerName && (this.appCoborrowerName.trim() == this.coBorrowerName.trim()))){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'applicant himself/herself cannot be selected as nominee',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }else if(this.borrowerRelationship && this.borrowerRelationship == 'APPLICANT'){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Nominee - borrower relationship cannot be Applicant',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (isValid) {
            this.isSpinnerMoving = true;
            handleInsuranceSubmit({
                inputJson: JSON.stringify(inputData),
                recordId: this.recordid,
                dealId:this.dealId,
            }).then(result => {
                console.debug('result --', result);
                this.isSpinnerMoving = false;
                if (result.includes('success')) {
                    const evt = new ShowToastEvent({
                        title: 'success',
                        message: 'Insurance Details Updated Successfully',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.navigateToNextTab();

                } else if (result.includes('error')) {
                    const evt = new ShowToastEvent({
                        title: 'error',
                        message: 'Error Occured' + result,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                }

            })
            .catch(error => {
                this.tryCatchError = error;
                console.debug(error);
                this.errorInCatch();
            });
        } else {
            const evt = new ShowToastEvent({
                title: "Error",
                message: this.label.mandotoryDetailsNotProvide,
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }


    }

    navigateToNextTab() {
        this.dispatchEvent(
            new CustomEvent('successfullysubmitted', {
                detail: this.disbursementrecordid
            })
        );
    }

    changeUploadInsuranceDocument() {
        this.uploadInsuranceDocFlag = false;
        InactiveInsuranceApplicationDocument({ loanApplicationId: this.recordid, dealId: this.dealId })
            .then(response => {}).catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
    }

    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }

    validateDOB(param){
        let isEligible = true;
        let dateDOB = new Date(param);
        const date = new Date();
        let age = date.getFullYear() - dateDOB.getFullYear();
        if (date.getMonth() < dateDOB.getMonth() || (date.getMonth() == dateDOB.getMonth() && date.getDate() < dateDOB.getDate())) {
            age--;
        }
        if(age && age < 18){
            isEligible = false;
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Nominee Age should be more than 18yrs',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
        return isEligible; 
    }
}