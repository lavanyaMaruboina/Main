import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import getLoanDisbursementRecord from '@salesforce/apex/LoanDisbursementController.getLoanDisbursementRecord';
import getDealNumberDetails from '@salesforce/apex/LoanDisbursementController.getDealNumberDetails';
import GetLoanApplicantDetails from '@salesforce/apex/LoanDisbursementController.getLoanApplicantDetails';
import IsValidUser from '@salesforce/apex/LoanDisbursementController.isValidUser';
import Loan_Disbursement from '@salesforce/label/c.Loan_Disbursement';
import RC_Upload from '@salesforce/label/c.RC_Upload';
import RCU from '@salesforce/label/c.RCU';
import Payment_Request from '@salesforce/label/c.Payment_Request';
import Business_Payment from '@salesforce/label/c.Business_Payment';
import Insurance_Details from '@salesforce/label/c.Insurance_Detail';
import NewUsed_Vehicles from '@salesforce/label/c.New_Used_Vehicles';
import Beneficiary_Details from '@salesforce/label/c.Beneficiary_Details';
import Key_Fact_Statement from '@salesforce/label/c.Key_Fact_Statement';
import Tractor from '@salesforce/label/c.Tractor';
import ParentLoanApp_Field from '@salesforce/schema/Opportunity.Id';
import LoanApplicationStage_Field from '@salesforce/schema/Opportunity.StageName';
import LoanApplicationSubStage_Field from '@salesforce/schema/Opportunity.Sub_Stage__c';
import LoanApplicationApplicant_Field from '@salesforce/schema/Opportunity.Applicant__c';
import LoanApplicationProdType_Field from '@salesforce/schema/Opportunity.Product_Type__c';
const OPPORTUNITY_FIELDS = [ParentLoanApp_Field, LoanApplicationStage_Field, LoanApplicationSubStage_Field, LoanApplicationApplicant_Field, LoanApplicationProdType_Field];

export default class IND_LWC_LoanDisbursement extends NavigationMixin(LightningElement) {
    label = {
        Loan_Disbursement,
        Business_Payment,
        Insurance_Details,
        NewUsed_Vehicles,
        Beneficiary_Details,
        RC_Upload,
        RCU,
        Payment_Request,
        Key_Fact_Statement
    }
    @api disbursementrecordid;
    @api recordid;
    @track loanapplicantid;
    @track loanapplicantdetails;
    @track loanApplication;
    @track currentappstage;
    @track currentappsubstage;
    @track tabs = ["rcu", "rcupload", "paymentrequest"];
    @track loanpage = false;
    @track activeviewappsubtab = undefined;
    @track currentSubTab = Business_Payment;
    @track activeMainTab = Payment_Request;
    @track applicantTypeList = []
    @track disableBusinessPaymentFields = false;
    @track disableInsuranceFields = false;
    @track disableNewUsedVehicleFields = false;
    @track disableBenefeciaryFields = false;
    @track validUser = true;
    @track isVisible = false;
    @track rcuVisible = false;
    disableRC = false;
    prodType;

    @api nextTab = [];
    @track activeTab;

    @track disableKeyFactFields = false;


    @track mainTablist = {
        "rcu": true,
        "rcupload": true,
        "paymentrequest": true
    };

    @track viewappsubtabs = {
        "bussinesspayment": true,
        "insurancedetails": false,
        "neworusedvehicle": false,
        "beneficiarydetails": false,
        "keyfactstatement" : false
    };
    async getLoanDisbursementDetailHandler(){
        this.disbursementrecordid = '';
        await getLoanDisbursementRecord({
            "loanApplicationId": this.recordid,
            "dealId": this.dealId
        }).then(data=>{
        if (data) {
            this.disbursementrecordid = data.Id;
        }
        this.renderChilds = true;
        }).catch(error=>{
            console.error(error);
        });
    }
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
            if (this.prodType != Tractor && this.loanApplication.fields.StageName && this.loanApplication.fields.Sub_Stage__c) {
                this.getLoanDisbursementDetailHandler();
                this.currentappstage = this.loanApplication.fields.StageName.value;
                this.currentappssubtage = this.loanApplication.fields.Sub_Stage__c.value;

                if (this.loanApplication.fields.StageName.value.includes('Disbursement Request Preparation')) {
                    if (this.loanApplication.fields.Sub_Stage__c.value.includes('Business Payment Details')) {
                        this.activeTab = Insurance_Details;
                        this.currentSubTab = Insurance_Details;
                        this.viewappsubtabs.insurancedetails = true;
                        this.disableBusinessPaymentFields = true;
                    } else if (this.loanApplication.fields.Sub_Stage__c.value.includes('Insurance Details')) {
                        this.activeTab = NewUsed_Vehicles;
                        this.currentSubTab = NewUsed_Vehicles;
                        this.viewappsubtabs.insurancedetails = true;
                        this.viewappsubtabs.neworusedvehicle = true;
                        this.disableBusinessPaymentFields = true;
                        this.disableInsuranceFields = true;
                    } else if (this.loanApplication.fields.Sub_Stage__c.value.includes('New/Used Vehicle Details')) {
                        this.activeTab = Beneficiary_Details;
                        this.currentSubTab = Beneficiary_Details;
                        this.viewappsubtabs.insurancedetails = true;
                        this.viewappsubtabs.neworusedvehicle = true;
                        this.viewappsubtabs.beneficiarydetails = true;
                        this.disableBusinessPaymentFields = true;
                        this.disableInsuranceFields = true;
                        this.disableNewUsedVehicleFields = true;
                    } else if (this.loanApplication.fields.Sub_Stage__c.value.includes('Beneficiary Details')) {
                        this.activeTab = Key_Fact_Statement;
                        this.currentSubTab = Key_Fact_Statement;
                        this.viewappsubtabs.insurancedetails = true;
                        this.viewappsubtabs.neworusedvehicle = true;
                        this.viewappsubtabs.beneficiarydetails = true;
                        this.disableBusinessPaymentFields = true;
                        this.disableInsuranceFields = true;
                        this.viewappsubtabs.keyfactstatement = true;
                        this.disableNewUsedVehicleFields = true;
                        this.disableBenefeciaryFields = true;
                    } else if(this.loanApplication.fields.Sub_Stage__c.value.includes('Key Fact Statement')){
                        this.activeTab = Key_Fact_Statement;
                        this.currentSubTab = Key_Fact_Statement;
                        this.viewappsubtabs.insurancedetails = true;
                        this.viewappsubtabs.neworusedvehicle = true;
                        this.viewappsubtabs.beneficiarydetails = true;
                        this.viewappsubtabs.keyfactstatement = true;
                        this.disableBusinessPaymentFields = true;
                        this.disableInsuranceFields = true;
                        this.disableNewUsedVehicleFields = true;
                        this.disableBenefeciaryFields = true;
                    }else {
                        this.activeTab = Business_Payment;
                        this.currentSubTab = Business_Payment;
                        this.viewappsubtabs.bussinesspayment = true;
                        this.disableBusinessPaymentFields = false;
                        this.disableInsuranceFields = false;
                        this.disableNewUsedVehicleFields = false;
                        this.disableBenefeciaryFields = false;
                    }

                    console.log('this.activeTab ', this.activeTab);
                    console.log('this.currentSubTab ', this.loanApplication.fields.StageName.value);
                    console.log('this.currentSubTab ', this.loanApplication.fields.Sub_Stage__c.value);
                    if (this.loanApplication.fields.Sub_Stage__c.value.includes(RC_Upload)) {
                        this.activeMainTab = RC_Upload;
                        this.activeTab = Beneficiary_Details;
                        this.currentSubTab = Beneficiary_Details;
                        this.viewappsubtabs.insurancedetails = true;
                        this.viewappsubtabs.neworusedvehicle = true;
                        this.viewappsubtabs.beneficiarydetails = true;
                        this.disableBusinessPaymentFields = true;
                        this.viewappsubtabs.keyfactstatement = true;
                        this.disableInsuranceFields = true;
                        this.disableNewUsedVehicleFields = true;
                        this.disableBenefeciaryFields = true;
                    }
                }

                if (this.currentappstage && this.currentappssubtage) {
                    this.isVisible = true;
                }
                console.log('this.currentappstage ', this.currentappstage);
                console.log('this.currentappstage ', this.isVisible);
            }

        }
    }
    // @wire(GetLoanDisbursementDetails, { loanApplicationId: '$recordid' })
    // wiredRecord({ error, data }) {
    //     if (error) {
    //         let message = 'Unknown error';
    //         if (Array.isArray(error.body)) {
    //             message = error.body.map(e => e.message).join(', ');
    //         } else if (typeof error.body.message === 'string') {
    //             message = error.body.message;
    //         }
    //         console.debug(message);
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error loading loan application',
    //                 message,
    //                 variant: 'error',
    //             }),
    //         );
    //     } else if (data) {
    //         console.debug(data);
    //     }
    // }
    productType;
    connectedCallback() {
        IsValidUser({ loanApplicationId: this.recordid })
            .then(response => {
                console.debug(response);
                this.validUser = response.isValid;
                if (!this.validUser) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Access Denied!',
                            message: "You do not have enough permissions.",
                            variant: 'error',
                        }),
                    );
                }
                // CISP-4770 - 5704
                if ((response.profile == "IBL Business Executive") && response.productType && response.productType == 'Passenger Vehicles') {
                    this.disableBusinessPaymentFields = true;
                    this.disableBenefeciaryFields = true;
                    this.disableInsuranceFields = true;
                    this.disableNewUsedVehicleFields = true;
                    //this.disableRC = true;
                }
            GetLoanApplicantDetails({ loanApplicationId: this.recordid })
                .then(response => {
                    if (response) {
                        this.loanapplicantdetails = response;
                        this.loanapplicantid = this.loanapplicantdetails[0].Id;
                        console.debug(response);
                        console.debug(this.loanapplicantid);
                        //this.loanapplicantid = this.loanapplicantdetails[0].Id;
                    }
                }).catch(error => {
                    console.error(error);
                });


                this.productType = response.productType;
            })
            .catch(error => {
                console.error(error);
            });
    }
    async init() {
        try{
            this.viewappsubtabs = {
                "bussinesspayment": true,
                "insurancedetails": false,
                "neworusedvehicle": false,
                "beneficiarydetails": false,
                "keyfactstatement" : false
            };
            this.mainTablist = {
                "rcu": true,
                "rcupload": true,
                "paymentrequest": true
            };
            this.disableBusinessPaymentFields = false;
            this.disableInsuranceFields = false;
            this.disableNewUsedVehicleFields = false;
            this.disableBenefeciaryFields = false;
            this.disableKeyFactFields = false;
            await getDealNumberDetails({loanApplicationId: this.recordid, dealId: this.dealId}).then(result=>{
                if(result){
                    if (result.Loan_Application__r.Product_Type__c == Tractor && result.Loan_Application__r.StageName) {
                        this.getLoanDisbursementDetailHandler();
                        this.currentappstage = result.Loan_Application__r.StageName;
                        this.currentappssubtage = result.Sub_Stage__c ? result.Sub_Stage__c : Business_Payment;
        
                        if (result.Loan_Application__r.StageName.includes('Disbursement Request Preparation')) {
                            if (result.Sub_Stage__c && result.Sub_Stage__c.includes('Business Payment Details')) {
                                this.activeTab = Insurance_Details;
                                this.currentSubTab = Insurance_Details;
                                this.viewappsubtabs.insurancedetails = true;
                                this.disableBusinessPaymentFields = true;
                            } else if (result.Sub_Stage__c && result.Sub_Stage__c.includes('Insurance Details')) {
                                this.activeTab = NewUsed_Vehicles;
                                this.currentSubTab = NewUsed_Vehicles;
                                this.viewappsubtabs.insurancedetails = true;
                                this.viewappsubtabs.neworusedvehicle = true;
                                this.disableBusinessPaymentFields = true;
                                this.disableInsuranceFields = true;
                            } else if (result.Sub_Stage__c && result.Sub_Stage__c.includes('New/Used Vehicle Details')) {
                                this.activeTab = Beneficiary_Details;
                                this.currentSubTab = Beneficiary_Details;
                                this.viewappsubtabs.insurancedetails = true;
                                this.viewappsubtabs.neworusedvehicle = true;
                                this.viewappsubtabs.beneficiarydetails = true;
                                this.disableBusinessPaymentFields = true;
                                this.disableInsuranceFields = true;
                                this.disableNewUsedVehicleFields = true;
                            } else if (result.Sub_Stage__c && result.Sub_Stage__c.includes('Beneficiary Details')) {
                                this.activeTab = Key_Fact_Statement;
                                this.currentSubTab = Key_Fact_Statement;
                                this.viewappsubtabs.insurancedetails = true;
                                this.viewappsubtabs.neworusedvehicle = true;
                                this.viewappsubtabs.beneficiarydetails = true;
                                this.disableBusinessPaymentFields = true;
                                this.viewappsubtabs.keyfactstatement = true;
                                this.disableInsuranceFields = true;
                                this.disableNewUsedVehicleFields = true;
                                this.disableBenefeciaryFields = true;
                            }else if(result.Sub_Stage__c && result.Sub_Stage__c.includes('Key Fact Statement')){
                                this.activeTab = Key_Fact_Statement;
                                this.currentSubTab = Key_Fact_Statement;
                                this.viewappsubtabs.insurancedetails = true;
                                this.viewappsubtabs.neworusedvehicle = true;
                                this.viewappsubtabs.beneficiarydetails = true;
                                this.viewappsubtabs.keyfactstatement = true;
                                this.disableBusinessPaymentFields = true;
                                this.disableInsuranceFields = true;
                                this.disableNewUsedVehicleFields = true;
                                this.disableBenefeciaryFields = true;
                            } else {
                                this.activeTab = Business_Payment;
                                this.currentSubTab = Business_Payment;
                                this.viewappsubtabs.bussinesspayment = true;
                                this.disableBusinessPaymentFields = false;
                                this.disableInsuranceFields = false;
                                this.disableNewUsedVehicleFields = false;
                                this.disableBenefeciaryFields = false;
                                this.disableKeyFactFields = false;
                            }
        
                            if (result.Sub_Stage__c && result.Sub_Stage__c.includes(RC_Upload)) {
                                this.activeMainTab = RC_Upload;
                                this.activeTab = Beneficiary_Details;
                                this.currentSubTab = Beneficiary_Details;
                                this.viewappsubtabs.insurancedetails = true;
                                this.viewappsubtabs.neworusedvehicle = true;
                                this.viewappsubtabs.beneficiarydetails = true;
                                this.disableBusinessPaymentFields = true;
                                this.viewappsubtabs.keyfactstatement = true;
                                this.disableInsuranceFields = true;
                                this.disableNewUsedVehicleFields = true;
                                this.disableBenefeciaryFields = true;
                            }
                        }
        
                        if (this.currentappstage && this.currentappssubtage) {
                            this.isVisible = true;
                        }
                    }
                }
            }).catch(error=>{
                console.log(error);
            });
        }catch(error){
            console.log(error);
        }
        GetLoanApplicantDetails({ loanApplicationId: this.recordid })
            .then(response => {
                if (response) {
                    this.loanapplicantdetails = response;
                    this.loanapplicantid = this.loanapplicantdetails[0].Id;
                    console.debug(response);
                    console.debug(this.loanapplicantid);
                    //this.loanapplicantid = this.loanapplicantdetails[0].Id;
                }
            }).catch(error => {
                console.error(error);
            });
    }
    handleMainActiveTab(event) {
        console.debug('acitve tab == > ', this.activeTab, ' ', this.activeMainTab);
        this.activeMainTab = event.target.value;
        //alert(this.activeMainTab);      
        if ((this.activeMainTab == 'RCU' && !this.mainTablist.rcu) ||
            (this.activeMainTab == 'RC Upload' && !this.mainTablist.rcupload) ||
            (this.activeMainTab == 'Payment Request' && !this.mainTablist.paymentrequest)
        ) {
            console.debug('Inside if condition');
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please submit the previous tab first',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    handleActiveSubTab(event) {
        this.activeviewappsubtab = event.target.value;
        if ((this.activeviewappsubtab === this.label.Business_Payment && !this.viewappsubtabs.bussinesspayment) ||
            (this.activeviewappsubtab === this.label.Insurance_Details && !this.viewappsubtabs.insurancedetails) ||
            (this.activeviewappsubtab === this.label.NewUsed_Vehicles && !this.viewappsubtabs.neworusedvehicle) ||
            (this.activeviewappsubtab === this.label.Beneficiary_Details && !this.viewappsubtabs.beneficiarydetails) ||
            (this.activeviewappsubtab === this.label.Key_Fact_Statement && !this.viewappsubtabs.keyfactstatement)) {
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please submit the ' + this.currentSubTab + ' tab first',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    handleTabSwitch(event) {
        this.disbursementrecordid = event.detail;
        // let tab = this.template.querySelectorAll('lightning-tabset');
        // tab.forEach(element => {
        //     if (element.activeTabValue == Business_Payment) {
        //         this.currentSubTab = Insurance_Details;
        //         this.viewappsubtabs.insurancedetails = true;
        //         element.activeTabValue = Insurance_Details;
        //         this.disableBusinessPaymentFields = true;
        //     } else if (element.activeTabValue == Insurance_Details) {
        //         this.currentSubTab = NewUsed_Vehicles;
        //         this.viewappsubtabs.neworusedvehicle = true;
        //         element.activeTabValue = NewUsed_Vehicles;
        //         this.disableBusinessPaymentFields = true;
        //         this.disableInsuranceFields = true;
        //     } else if (element.activeTabValue == NewUsed_Vehicles) {
        //         this.currentSubTab = Beneficiary_Details;
        //         this.viewappsubtabs.beneficiarydetails = true;
        //         element.activeTabValue = Beneficiary_Details;
        //         this.disableBusinessPaymentFields = true;
        //         this.disableInsuranceFields = true;
        //         this.disableNewUsedVehicleFields = true;
        //     } else if (this.currentSubTab == Beneficiary_Details) {
        //         //element.activeTabValue = RC_Upload;
        //     }
        // });
        eval("$A.get('e.force:refreshView').fire();");
    }

    @track dealId = null;
    @track renderChilds;
    async dealNumberHandler(event){
        if(event.detail){ 
            this.renderChilds = false;
            this.dealId = event.detail;
            setTimeout(() => {
                this.init();
            }, 1000);
        }
    }

}