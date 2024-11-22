import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apexContinuation/PersonalDetailsforCAM.getRecordsVarientnew';
import doCarwalePricesCallout from '@salesforce/apexContinuation/IntegrationEngine.doCarwalePricesCallout';
import getDetailsloan from '@salesforce/apex/PersonalDetailsforCAM.getDetailsforLoan';
import getDetailsvarientcode from '@salesforce/apex/PersonalDetailsforCAM.getDetailsvarientcode';
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import noResponseAPI from '@salesforce/label/c.noResponseAPI';
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import calculatePrices from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.calculatePrices';
import vehicleDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getVehicleDetails'; //CISP-15787
import doLTVEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doLTVEngineCallout';
import doLTVEngineCalloutNew from '@salesforce/apexContinuation/DSA_IntegrationEngine.doLTVEngineCallout';//D2C Changes Swapnil
import doPricingEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doPricingEngineCallout';
import doPricingEngineCalloutNew from '@salesforce/apexContinuation/DSA_IntegrationEngine.doPricingEngineCallout';//D2C Changes Swapnil
import { updateRecord } from 'lightning/uiRecordApi';
import createFinalTermRecord from '@salesforce/apex/FinalTermscontroller.createFinalTermRecord';
import { refreshApex } from '@salesforce/apex';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import getRelatedVariantList from '@salesforce/apex/IND_AssetDetailsCntrl.getRelatedVariantList';
import getRelatedModelListTractor from '@salesforce/apex/Utilities.getRelatedModelList'; 
import getRelatedVariantListTractor from '@salesforce/apex/Utilities.getRelatedVariantList';
import exshowroomcarwale from '@salesforce/schema/Opportunity.Ex_showroom_price_carwale__c';
import ORPcarwale from '@salesforce/schema/Opportunity.On_Road_price_carwale__c';
import carwaleID from '@salesforce/schema/Opportunity.Id';
import LtvEngine_Ltv from '@salesforce/schema/Final_Term__c.LtvEngine_Ltv__c';
import PricingEngine_thresholdNetrr from '@salesforce/schema/Final_Term__c.PricingEngine_thresholdNetrr__c';

import Vehicle_ID_FIELD from '@salesforce/schema/Vehicle_Detail__c.Id';
import Vehicle_Varient from '@salesforce/schema/Vehicle_Detail__c.Variant__c';
import Variant_Code from '@salesforce/schema/Vehicle_Detail__c.Variant_Code__c';
import base_price from '@salesforce/schema/Vehicle_Detail__c.Base_Price__c';
import oppId_field from '@salesforce/schema/Opportunity.Id';
import Dealer_Disc_to_Customer from '@salesforce/schema/Opportunity.Dealer_Disc_to_Customer__c';
import Discount_on_Basic_Price from '@salesforce/schema/Opportunity.Discount_on_Basic_Price__c';
import GST_Amount from '@salesforce/schema/Opportunity.GST_Amount__c';
import X1st_yr_Insurance_Premium from '@salesforce/schema/Opportunity.X1st_yr_Insurance_Premium__c';
import Other_charges from '@salesforce/schema/Opportunity.Other_charges__c';
import Required_Loan_amount from '@salesforce/schema/Opportunity.Required_Loan_amount__c';
import Funding_on_Ex_Showroom from '@salesforce/schema/Opportunity.Funding_on_Ex_Showroom__c';
import Funding_on_ORP from '@salesforce/schema/Opportunity.Funding_on_ORP__c';
import Ex_showroom_price from '@salesforce/schema/Opportunity.Ex_showroom_price__c';
import Basic_Price from '@salesforce/schema/Opportunity.Basic_Price__c';
import RTO_Road_Tax_TW from '@salesforce/schema/Opportunity.RTO_Road_Tax_New__c';
import On_Road_price from '@salesforce/schema/Opportunity.On_Road_price__c';
import Invoice_Price from '@salesforce/schema/Vehicle_Detail__c.Invoice_Price__c';//SFTRAC-1335
import RTO_Road_Tax_Error from '@salesforce/label/c.RTO_Road_Tax_Error';
import RTO_Road_Tax_Carwale from '@salesforce/schema/Opportunity.RTO_Road_Tax__c'; // CISP-116
import checkRetryExhausted from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.checkRetryExhausted';// CISP-2346
import RetryExhausted from '@salesforce/label/c.Retry_Exhausted';// CISP-2346
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import getPurchaseprice from '@salesforce/apex/IND_OfferScreenController.getPurchaseprice'; //SFTRAC-1299
export default class LWC_incomedetailsVarient extends LightningElement {
    activeSections = ['Change Varient'];
    @api recordId;
    @api index;
    @api appId;
    @api vehicleRecordId;
    @track lstRecords = [];
    @track fields;
    @track Modelchange = true;//SFTRAC-1218
    @track Varientchange = true;
    @track Make;
    @track Model;
    @track Variant;
    @track VarientId;
    @track runoffer = true;
    @track BasicPrice;
    @track GSTAmount;
    @track BasePrices = 0;//CISP-2522
    @track TotalfundedPremium = 0;//CISP-2522
    @track pricedetails = true;
    @track DealerDisctoCustomer;
    @track Exshowroomprice;
    @track Exshowroompricecarwale;
    @track RTORoadTax;
    @track Othercharges;
    @track X1styrInsurancePremium;
    @track OnRoadprice;
    @track callDoLtvEngineCallout;
    @track variantCode;
    @track OnRoadpricecarwale;
    carDetails;
    @track isModalOpen = false;
    productTypeDetail;
    @track cityId = '';
    @track leadId = '';
    @api substage;
    vehicleTypeNo;
    displayGetPricefields;
    disabledonRoadPriceCarwale;
    disabledrtoRoadTax;
    disabledExShowroomPriceCarwale;
    disableGetPrice;
    @track FundingonExShowroom;
    @track FundingonExShowroomboolean;
    @track FundingonORP;
    @track FundingonORPboolean;
    @track RequiredLoanamount;
    @track isLoading = false;
    @track onvariantchangedtrue=true;
    advanceEMi = false;
    temp;
    checkServiceChargesValue;
    schemeOptionsValue;
    @track schemeOptions;
    checkMfrExpReimburseAmt;
    checkDealerExpReimburseAmount;
    checkDealerDiscounttoCustomer;
    checkNonDlrDsmIncentiveOne;
    @track emptyvalue=false;
    //Details fetch for Field Validation.
    loanAmountDetail;
    requiredTenureDetails;
    requiredLoanAmount;
    productTypeDetail;
    vehicleSubCategoryDetail;
    vehicleTypeDetail;
    makeCode;
    isPA //D2C Change
    dealerQuotedORP // D2C Change
    //values fetch from metadata for validation
    @track oldvarient;
    @track newvarient;
    @track newVarientCode;
    monitoriumDaysValue = null;
    value = '';
    initialD2CSave = false;


    dsmNameTwoValue;
    ltv;
    thresholdNetIRR;
    dsmIncentiveTwoValue;
    branchValue;
    schemeData;
    @track monitoriumDaysDisabled = false;
    @track ecsOption;
    @track ecsValue;
    @track referredbyValue;
    @track serviceChargesValue;
    @track mainResult;

    @track appId;
    @track finalTermId;
    @track modelOptionsList = [];//SFTRAC-1218
    @track variantOptionsList = [];
    @api showUpload;
    @api showDocView;
    @api isVehicleDoc;
    @api isAllDocType;
    @track uploadViewDocFlag = false;
    leadSource;//D2C Changes Swapnil
    performanceUp;//OLA-140
    famesub;//OLA-140
    @track productSegment; //CISP-15787
    eScooter = false; //CISP-15787
    ids;
    vehicleTypeName;
    isTWNew;
    rtoRoaTaxVal = 0;
    // CISP-2346
    @track isCarWaleApiFailed = false;
    @track isPassengerVehicle = false;
    @track isRtoRoadTaxFieldEnable = false;



    //CISP-4730 START
    isAPIFailed;
    retryCount;
    //CISP-4730 END
    get isRequiredLoanAmountDisabled(){//D2C Change Raman
        if(this.leadSource === 'D2C' && this.productTypeDetail == 'Two Wheeler'){
            return false;
        }else{
            return this.onvariantchangedtrue;
        }
    }
    @track isTractor = false;
    @track accordionLabel = "Change Variant - ";
    @track invoiceAmount;
    
    isRtoRoadTaxFieldEnableFunction(){
        if(this.isTWNew || (this.isCarWaleApiFailed && this.isPassengerVehicle) || (this.isPassengerVehicle && this.leadSource == 'D2C')){
            this.isRtoRoadTaxFieldEnable = true;
        }else{
            this.isRtoRoadTaxFieldEnable = false;
        }
    }
    // CISP-2346-START
    @track leadSource;
    async connectedCallback(){
        if(this.isTractor){
            this.disableGetPrice = true;
        }
        await fetchLoanDetails({ opportunityId: this.recordId }).then(result => {
            this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
            if(result?.loanApplicationDetails){
                this.productTypeDetail = result?.loanApplicationDetails[0]?.Product_Type__c;
                this.isTractor = this.productTypeDetail == 'Tractor';
            }

            if(this.leadSource=='OLA'){
                this.disableEverything();
            }
            //CISP-4730 START
            if (result?.retryCountDetails) {
                this.isAPIFailed = result?.retryCountDetails[0]?.IsAPIFailed__c;
                this.retryCount = result?.retryCountDetails[0]?.Count__c;
            } else {
                this.isAPIFailed = false;
                this.retryCount = 0;
            }
            if (this.isAPIFailed === true && this.retryCount >= 3) {
                this.isCarWaleApiFailed = true;
            } else if (this.isAPIFailed === false && this.retryCount >= 3) {
                this.isCarWaleApiFailed = false;
            }
            //CISP-4730 START END
        });//Ola Integration changes
        await getDetailsloan({ opportunityId: this.recordId }).then(data=>{
            console.log('data to test',data);
            if (data) {
                console.log('fetchData: ',data);
                this.leadSource = data.leadSource;//D2C Changes Swapnil
                this.productTypeDetail = data.productTypestr;
                this.cityId = data.citycode;
                this.isPA = data.isPA;//D2C Changes Raman
                this.leadId = data.name;
                this.appId = data.applicantId;
                this.variantCode = data?.variantcode;
                this.vehicleTypeName = data?.vehicleTypeStr;
                if(this.productTypeDetail == 'Two Wheeler' && this.vehicleTypeName == 'New'){
                    console.log('when product type two wheeler and new  : ');
                    this.isTWNew = true;
                } else {
                    this.isTWNew = false;
                }

                if(this.leadSource === 'D2C' && (this.productTypeDetail == PassengerVehicles || this.isTractor)){
                    this.onvariantchangedtrue = false;
                }
                if(this.productTypeDetail  == 'Two Wheeler'){
                    this.disableFundingOnExShowroom = true;
                    this.disableFundingOnORP = true;
                    this.FundingonORPboolean=true;
                }
                // CISP-2346
                if(this.productTypeDetail == PassengerVehicles){
                    this.isPassengerVehicle = true;
                }
                this.isRtoRoadTaxFieldEnableFunction();
                // CISP-2346
            }
            this.fetchgetRecords();
        }).catch(error=>{
            console.log(error);
            this.lstRecords = [];
        })
        await vehicleDetails({oppId: this.recordId})
        .then((response) => {
            console.log('vehicleDetails::',response);
            this.productSegment = response.Product_Segment__c;
            if(this.productSegment != null && this.productSegment != '' && this.productSegment.toLowerCase() ==='ESCOOTER'.toLowerCase()){
                this.eScooter = true;
            }
        })
        .catch((error) => {
        if(!this.isTractor){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
        });
         //CISP-6540
          // if(this.productTypeDetail == 'Passenger Vehicles' && this.isRtoRoadTaxFieldEnable){//CISP-4730
           //  this.template.querySelector(`lightning-input[data-id="rtoRoaTaxVal"]`).disabled = false;
           // }
        //CISP-6540
    }
    // CISP-2346-END
    renderedCallback(){
        if(this.isTractor){
            this.disableGetPrice = true;
        }
        if(this.substage) {
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
         element.disabled = true
           );
      }
        if(this.leadSource=='OLA'){
            this.disableEverything();
        }
      if(this.leadSource === 'D2C' && this.Exshowroomprice != 0 && (this.BasicPrice == 0 || this.GSTAmount == 0)){
        this.updateD2CDetails();
      } if(this.productTypeDetail == 'Passenger Vehicles'){
        this.docalculateORP();
       }
    }

    async updateD2CDetails(){
        this.initialD2CSave = true;
        if (Exshowroomprice && this.eScooter) {
            this.BasicPrice = (parseFloat(this.Exshowroomprice)/1.05263).toFixed(0);
            this.GSTAmount = parseFloat(this.Exshowroomprice) -  parseFloat(this.BasicPrice);
        }else{
        this.BasicPrice = (parseFloat(this.Exshowroomprice)/1.28).toFixed(0);
        this.GSTAmount = parseFloat(this.Exshowroomprice) -  parseFloat(this.BasicPrice);
    }
        const oppfields1 = {};
        oppfields1[oppId_field.fieldApiName] = this.recordId;
        oppfields1[Basic_Price.fieldApiName] = this.BasicPrice;
        await this.updateRecordDetailsfields(oppfields1,'Basic price');
        const oppfields2 = {};
        oppfields2[oppId_field.fieldApiName] = this.recordId;
        oppfields2[GST_Amount.fieldApiName] = (this.GSTAmount != null && this.GSTAmount != undefined && this.GSTAmount != '') ? Math.ceil(this.GSTAmount) : this.GSTAmount;
        await this.updateRecordDetailsfields(oppfields2,'GST Amount');
        this.initialD2CSave = false;
    }

    fetchgetRecords() {
        if(this.recordId){//CISP-60
        getRecords({ 'opp': this.recordId, 'vRecordId' : this.vehicleRecordId }).then(data => {
            for (var key in data) {
                this.lstRecords.push({ value: data[key], key: key });
                console.log('data[key] getRecords(): ',data[key]);
            }
            this.Make = data["Make__c"];
            this.Model = data["Model__c"];
            // this.variantOptionsList= { label: data["Variant__c"], value: data["Variant__c"] };
            this.variantOptionsList.push(data["Variant__c"]);
            this.Variant = data["Variant__c"];
            this.accordionLabel += data["Variant__c"];

            this.BasicPrice = data["Basic_Price__c"];
            this.BasePrices = data["Base_Prices__c"];//CISP-2522
            this.TotalfundedPremium = data["Total_Funded_Premium__c"];//CISP-2522
            this.GSTAmount = data["GST_Amount__c"];
            this.DealerDisctoCustomer = data["Discount_on_Basic_Price__c"];
            this.Exshowroomprice = data["Ex_showroom_price__c"];
            this.Exshowroompricecarwale = data["Ex_showroom_price_carwale__c"];
            this.RTORoadTax = data["RTO_Road_Tax_New__c"] ? data["RTO_Road_Tax_New__c"] : data["RTO_Road_Tax__c"];//CISP-7077 - Need to deploy in Prod this line;
            this.rtoRoaTaxVal = data["RTO_Road_Tax_New__c"];
            this.Othercharges = data["Other_charges__c"];
            this.X1styrInsurancePremium = data["X1st_yr_Insurance_Premium__c"];
            this.OnRoadprice = data["On_Road_price__c"];
            this.OnRoadpricecarwale = data["On_Road_price_carwale__c"];
            this.FundingonExShowroom = data["Funding_on_Ex_Showroom__c"];
            this.FundingonORP = data["Funding_on_ORP__c"];
            this.gstPercentageValue = data["GstPercentage__c"];
            this.performanceUp = data["Performance_Upgrade__c"];
            this.famesub = data["FAME_Subsidy__c"];
            this.invoiceAmount = data["Invoice_Price__c"];
            console.log("this.performanceUp" + this.performanceUp + "this.famesub" + this.famesub);
            this.dealerQuotedORP = data['Dealer_Quoted_On_Road_Price__c'];// D2C Change
            if(this.FundingonExShowroom=='True' || this.FundingonExShowroom=='true'){
                this.FundingonExShowroomboolean=true;
            }else{
                this.FundingonExShowroomboolean=false;
            }
            if(this.FundingonORP=='True' || this.FundingonORP=='true'){
                this.FundingonORPboolean=true;
            }else{
                this.FundingonORPboolean=false;
            }
            this.RequiredLoanamount = data["Required_Loan_amount__c"];
            this.VarientId = data["Id"];
            this.appId = data["appId"];
            this.oldvarient = data["Variant__c"];
            //Undefined and empty String Check
            if (this.BasicPrice === undefined || this.BasicPrice === '') {
                this.BasicPrice = 0;
            }
            if (this.GSTAmount === undefined || this.GSTAmount === '') {
                this.GSTAmount = 0;
            }
            if (this.DealerDisctoCustomer === undefined || this.DealerDisctoCustomer === '') {
                this.DealerDisctoCustomer = 0;
            }
            if (this.Exshowroomprice === undefined || this.Exshowroomprice === '') {
                this.Exshowroomprice = 0;
            }
            if (this.Exshowroompricecarwale === undefined || this.Exshowroompricecarwale === '') {
                this.Exshowroompricecarwale = 0;
            }
            if (this.RTORoadTax === undefined || this.RTORoadTax === '') {
                this.RTORoadTax = 0;
            }
            if (this.Othercharges === undefined || this.Othercharges === '') {
                this.Othercharges = 0;
            }
            if (this.X1styrInsurancePremium === undefined || this.X1styrInsurancePremium === '') {
                this.X1styrInsurancePremium = 0;
            }
            if (this.OnRoadprice === undefined || this.OnRoadprice === '') {
                this.OnRoadprice = 0;
            }
            if (this.OnRoadpricecarwale  === undefined || this.OnRoadpricecarwale  === '') {
                this.OnRoadpricecarwale = 0;
            }
            if (this.performanceUp  === undefined || this.performanceUp  === '') {
                this.performanceUp = 0;
            }
            if (this.famesub  === undefined || this.famesub  === '') {
                this.famesub = 0;
            }
            if(this.isTractor){
                getRelatedModelListTractor({ sMake: data["Make_Code__c"], vehicleSubType: data["Vehicle_SubType__c"]}).then(response => {
                    console.log('getRelatedModelList():: ',response);
                    this.modelOptionsList = response.map(function (obj) {
                        return { label: obj.label, value: obj.value };
                    });
                }).catch(error => {
                    console.log('Error in getting related Model:: ', error);
                });
            }

            if(this.isTractor){
                getRelatedVariantListTractor({ sModel: data["Model_Code__c"],loanApplicationId:this.recordId}).then(response => {
                    this.variantOptionsList = response.map(function (obj) {
                        return { label: obj.Name, value: obj.Variant_Code__c };//CISP-2794
                    });
                }).catch(error => {
                    console.log('Error in getting related Variant:: ', error);
                });
            }else{
                getRelatedVariantList({ 'sModel': data["Model_Code__c"] }).then(response => {//CISP-2952
                    console.log('getRelatedVariantList():: ',response);
                    this.variantOptionsList = response.map(function(obj) {
                        return { label: obj.Name, value: obj.Variant_Code__c };
                    });
                }).catch(error => {
                    console.log('Error in getRelatedVariantList():: ', error);
                });
            }

           if(!this.isTractor){
                if(this.isRtoRoadTaxFieldEnable){
                    this.calculateORP();
                }else{
                    this.calculateORPCarWale();
                }
                this.calculateAllValues();
            }
        }).catch(error => {
            console.log(error);
            this.lstRecords = [];
        });
    }
}
getRelatedVariantList(){
    if(this.isTractor){
        getRelatedVariantListTractor({ sModel: this.modelCode,loanApplicationId:this.recordId}).then(response => {
            this.variantOptionsList = response.map(function (obj) {
                return { label: obj.Name, value: obj.Variant_Code__c };//CISP-2794
            });
        }).catch(error => {
            console.log('Error in getting related Variant:: ', error);
        });
    }else{
        getRelatedVariantList({ sModel: this.modelCode, vehicleType: this.vehicleType }).then(response => {//CISP-2952 & CISP-4778
            console.log('getRelatedVariantList():: ',response);
            this.variantOptionsList = response.map(function(obj) {
                return { label: obj.Name, value: obj.Variant_Code__c };
            });
        }).catch(error => {
            console.log('Error in getRelatedVariantList():: ', error);
        });
    }
}

docalculateORP(){
    let rtoval = this.isRtoRoadTaxFieldEnable ? this.rtoRoaTaxVal: this.RTORoadTax
    if(this.leadSource!='OLA' && this.OnRoadprice){this.OnRoadprice = parseFloat(this.Exshowroomprice) + parseFloat(rtoval) + parseFloat(this.X1styrInsurancePremium) + parseFloat(this.Othercharges);
    }
}

//SFTRAC-1218
async modelChangeclick(event){
    this.Model = event.target.value;
    this.Variant = null;
    this.variantOptionsList = null;
    this.modelCode =  event.target.value;
    if(this.isTractor){
        let model = await event.target.options.find(opt => opt.value === event.detail.value).label;
        this.vehiclefieldsTF['Model__c']  = model;
        this.vehiclefieldsTF['Model_Code__c']  = this.modelCode;
    }  
    if(this.modelCode){
        this.getRelatedVariantList();
    }  
}
//SFTRAC-1218

    async varientchangeclick(eve) {
        this.emptyvalue=false;
        this.newvarient = eve.target.options.find(opt => opt.value === eve.detail.value).label;
        this.newvarientCode = eve.target.value;
        if(this.newvarient =='' || this.newvarient=== this.oldvarient){
            this.emptyvalue=true;
        }
        this.isModalOpen = true;
        if(this.isTractor){//SFTRAC-1218
            let varient = await eve.target.options.find(opt => opt.value === eve.detail.value).label;
            this.vehiclefieldsTF['Variant__c']  = varient;
            this.vehiclefieldsTF['Variant_Code__c']  = this.newVarientCode;
        } //SFTRAC-1218
    }

    //SFTRAC-1218
    get modelOptions() {
        return this.modelOptionsList;
    }
    //SFTRAC-1218

    get variantOptions() {
        return this.variantOptionsList;
    }
    varientsave() {
        this.isLoading = true;
        this.onvariantchangedtrue=false;
        if(this.emptyvalue==false){
            this.pricedetails = false;
        }
        if(!this.isTractor){//SFTRAC-1218
            this.oldvarient = this.newvarient;
            const vehicledetails = {};
            vehicledetails[Vehicle_ID_FIELD.fieldApiName] = this.VarientId;
            vehicledetails[Vehicle_Varient.fieldApiName] = this.newvarient;
            vehicledetails[Variant_Code.fieldApiName] = this.newVarientCode;
            this.updateRecordDetails(vehicledetails);
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Varient Updated',
                variant: 'Success',
            });
            this.dispatchEvent(event);
        }//SFTRAC-1218
        else if(this.isTractor){
            this.saveVarientDetails();
        }
        this.Exshowroompricecarwale = 0;
        this.RTORoadTax = 0;
        this.OnRoadpricecarwale = 0;
        this.runoffer=true;
        this.isLoading = false;
       // this.Varientchange = true;
        this.isModalOpen = false;
        if(this.productTypeDetail == 'Tractor'){this.accordionLabel = "Change Variant - "+this.newvarient;}
        let eventObj = new CustomEvent('updateofferaccordionlabel',{ detail: {'accordionLabelChange':this.newvarient,'index':this.index} }); this.dispatchEvent(eventObj); 
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
     closeModalVarient(){//CISP-7452
        this.variantOptionsList.forEach(item => {
            if(item.label == this.oldvarient){
                this.Variant = item.value;
            }
        })
          this.isModalOpen = false;
    }//CISP-7452

    @api handle_ChangeVar(event) {
        if(this.isTractor){
            this.Modelchange = false;
        }
        this.Varientchange = false;
        let ev = new CustomEvent('parentmethoddisabled',{ detail: {'index':this.index} });
        this.dispatchEvent(ev);
    }
    //SFTRAC-1218
    @api saveVarientDetails() {
        if(this.vehiclefieldsTF && JSON.stringify(this.vehiclefieldsTF) !== "{}"){
            this.vehiclefieldsTF[Vehicle_ID_FIELD.fieldApiName] = this.vehicleRecordId;
            let fields = {}
            fields = this.vehiclefieldsTF;
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                this.vehiclefieldsTF = {}
                this.oldvarient = this.newvarient;
                this.showToastMessage('Success', 'Varient Updated', 'success');
            }).catch(error=>{})
        }
    }//SFTRAC-1218

    @api handlesubmits() {

        submitrec()
            .then(result => {
                //console.log('@@');
            })
            .catch(error => {
                this.error = error;
            });
    }
    async handleGetPriceButtons() {
        // this.cityId = '176';
        this.runoffer = false;
        getDetailsvarientcode({ 'opportunityId': this.recordId })
        .then(data => {
            console.log('data', data);
            this.variantCode = data;
        })
        .catch(error => {
            console.log(error);
            this.lstRecords = [];
        });
        console.log('this.variantCode', this.variantCode);
        if (this.productTypeDetail === PassengerVehicles) {
            this.vehicleTypeNo = '1';
        }
        else {
            this.vehicleTypeNo = '2';
        }
        let carDetails = {
            'vehicleType': this.vehicleTypeNo,
            'CityId': this.cityId,
            'VariantCode': this.variantCode,
            'leadId': this.leadId,
            "loanApplicationId": this.recordId
        };

        console.log("doCarwalePricesCallout():: ", carDetails);
        this.isLoading = true;
        // CISP-2346 -- Added check Retry count.
        await checkRetryExhausted({ loanApplicationId: this.recordId }).then(result => {
            let response = JSON.parse(result);
            console.log('Retry Response:: ', response);

            if (response.message === RetryExhausted) {
                this.isLoading = false;
                this.showToastMessage('Error', response.message, 'Error');
                this.disableGetPrice = true;
                this.isCarWaleApiFailed = true;//CISP-2346
                this.isRtoRoadTaxFieldEnableFunction();//CISP-2346
            } else if(this.isTractor == false){
                doCarwalePricesCallout({ 'CarwalePrices': JSON.stringify(carDetails),productType: this.productTypeDetail }).then(result => {//CISP-654
                    const obj = JSON.parse(result);
                    console.log("doCarwalePricesCallout() response:: ", obj);
                    if(this.productTypeDetail === PassengerVehicles){//CISP-654
                        if (obj.response.status === 'Failure') {
                            this.showToastMessage('Error',obj.response.status,'error');
                            // this.displayGetPricefields = true;
                            this.isCarWaleApiFailed = true;//CISP-2346
                            this.isRtoRoadTaxFieldEnableFunction();//CISP-2346
                        } else if (obj.response.status === 'SUCCESS') {
                            this.showToastMessage('Success',obj.response.status,'success');
                            this.isCarWaleApiFailed = false;//CISP-2346
                            this.isRtoRoadTaxFieldEnableFunction();//CISP-2346
                            this.isLoading = false;
                            this.displayGetPricefields = true;
                            let pricesList = obj?.response?.content[0]?.pricesList;
                                console.log('priceArray :: ',pricesList);
                                for(let i = 0;i<pricesList.length;i++){
                                    if(pricesList[i].name === 'RTO') {
                                        this.RTORoadTax = pricesList[i].value;
                                    } else if(pricesList[i].name === 'Ex-showroom' || pricesList[i].name === 'Ex-Showroom Price') {
                                        this.Exshowroompricecarwale = pricesList[i].value;
                                    } else if(pricesList[i].name === 'Insurance (Comprehensive)' || pricesList[i].name === 'Insurance') {
                                        this.onRoadPricecarwale = pricesList[i].value;
                                    }
                                }
                            //this.Exshowroompricecarwale = obj.response.content[0].pricesList[0].value;
                            //this.RTORoadTax = obj.response.content[0].pricesList[1].value;
                            const subsc = parseInt(this.onRoadPricecarwale) + parseInt(this.Exshowroompricecarwale)+ parseInt(this.Othercharges);
                            this.OnRoadpricecarwale = subsc;
                            this.disableGetPrice = true;
                            this.Modelchange = true;//SFTRAC-1218
                            this.Varientchange = true;
                            const carwalefields = {};
                            carwalefields[exshowroomcarwale.fieldApiName] = this.Exshowroompricecarwale;
                            carwalefields[ORPcarwale.fieldApiName] = this.OnRoadpricecarwale;
                            carwalefields[carwaleID.fieldApiName] = this.recordId;
                            carwalefields[RTO_Road_Tax_TW.fieldApiName] = this.RTORoadTax; // CISP-116
                            this.updateRecordDetails(carwalefields);
                            this.fromApi= true;
                        } else {
                            this.isCarWaleApiFailed = true;//CISP-2346
                            this.isRtoRoadTaxFieldEnableFunction();//CISP-2346
                            console.log('in else part')
                            this.showToastMessage('Error', noResponseAPI, 'error');
                            this.isLoading = false;
                        }
                    }else{//CISP-654
                        if(obj){
                            this.isLoading = false;
                            //this.showToastMessage(SuccessMessage, 'Success', 'success');//Commented this as variable SuccessMessage is not defined
                            this.showToastMessage('Success','Price details fetched successfully.','success');//D2C fix
                            this.displayGetPricefields = true;
                            this.isCarWaleApiFailed = false;//CISP-2346
                            this.isRtoRoadTaxFieldEnableFunction();//CISP-2346
                            this.RTORoadTax = obj?.rto?.value;//CISP-2346
                            this.Exshowroompricecarwale = obj?.exShowroom?.value;
                            this.OnRoadpricecarwale = obj?.insuranceComprehensive?.value; //Fix Fron D2C 
                            if(this.leadSource === 'D2C'){
                                const subsc = parseInt(this.OnRoadpricecarwale) + parseInt(this.Exshowroompricecarwale)+ parseInt(this.Othercharges);
                                this.OnRoadpricecarwale = subsc;
                            }
                            const carwalefields = {};
                            carwalefields[exshowroomcarwale.fieldApiName] = this.Exshowroompricecarwale;
                            carwalefields[ORPcarwale.fieldApiName] = this.OnRoadpricecarwale;
                            carwalefields[carwaleID.fieldApiName] = this.recordId;
                            carwalefields[RTO_Road_Tax_Carwale.fieldApiName] = this.RTORoadTax; // CISP-116
                            this.updateRecordDetails(carwalefields);
                            this.fromApi= true;
                        }else{
                            this.isLoading = false;
                            this.isCarWaleApiFailed = true;
                        }
                    }
                    //CISP-654
                }).catch(error => {
                    console.log('in catch part',error)
                    this.showToastMessage('Error', noResponseAPI, 'error');
                    this.isLoading = false;
                });// CISP-2346
            }// CISP-2346
        });
    }

    @track vehiclePurchaseprice;
    async runEligibilityEngine() {
        this.onvariantchangedtrue=true;
        this.isLoading = true;
        this.runoffer=true;
        this.pricedetails=true;
        if(this.isTractor){//SFTRAC-1299
            let getResponse = await getPurchaseprice({ loanApplicationId: this.recordId, 'vehicleId' : this.vehicleRecordId });
            this.vehiclePurchaseprice = parseInt(getResponse, 10);
        }

        await createFinalTermRecord({ loanApplicationId: this.recordId ,vehicleId:this.vehicleRecordId}).then(responses => {
                const obj = JSON.parse(responses);
                console.log('obj.finalTermId  ', obj.finalTermId);
                this.finalTermId = obj.finalTermId;
            //CISP-2346
            this.Modelchange = true;//SFTRAC-1218
            this.Varientchange = true;
            let ele = this.template.querySelector(`lightning-input[data-id="rtoRoaTaxVal"]`);
            if(ele){
                ele.disabled = true;
            }
            // CISP-2346

            let elemRtoCarWale = this.template.querySelector('lightning-input[data-name=rtoCarWale]');
            console.log('elemRtoCarWale ', elemRtoCarWale);
            if(elemRtoCarWale){
                elemRtoCarWale.disabled = true;
            }
            // CISP-2346-END
                console.log('this.finalTermId  ', this.finalTermId);
                if(this.isTractor){
                    const newMaxLoanAmount = (0.95 * this.vehiclePurchaseprice);
                    const usedRefMaxLoanAmount = (0.90 * this.vehiclePurchaseprice);
                    if ((parseInt(this.RequiredLoanamount) > newMaxLoanAmount) && this.vehicleTypeName == 'New') {
                        this.showToastMessage('Error', 'Loan amount cannot exceed 95% of the vehicle purchase price', 'error');
                        this.runoffer=false;
                        this.disablebasicprice = false; 
                        this.disablegst = false; 
                        this.onvariantchangedtrue = false;
                    }else if (parseInt(this.RequiredLoanamount) > usedRefMaxLoanAmount && (this.vehicleTypeName == 'Used' || this.vehicleTypeName == 'Refinance')) {
                        this.showToastMessage('Error', 'Loan amount cannot exceed 90% of the vehicle purchase price', 'error');
                        this.runoffer=false;
                        this.disablebasicprice = false; 
                        this.disablegst = false; 
                        this.onvariantchangedtrue = false;
                    }else{
                        let ev = new CustomEvent('childmethod',{ detail: {'loanAmount':this.RequiredLoanamount,'index':this.index} });
                        this.dispatchEvent(ev);
                    }

                    this.isLoading = false;
                }    
                if(this.leadSource == 'D2C' || this.leadSource == 'Hero'){//START Only to run Offer engine // CISH-4
                    let ev = new CustomEvent('childmethod',
                        { detail: this.finalTermId }
                    );
                    this.dispatchEvent(ev);
                    this.isLoading = false;
                }// END to run Offer engine    
                console.log('this.recordId  ', this.recordId);
                console.log('this.appId  ', this.appId);
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                console.log('error. ', error);
            });
        console.log('start of doLTVEngineCallout');
        //START D2C Changes Swapnil
        let ltvEngineMethod = doLTVEngineCallout;
        /*if(this.leadSource === 'D2C'){
            ltvEngineMethod = doLTVEngineCalloutNew;
        }*/
        //END D2C Changes Swapnil
        if(this.leadSource != 'D2C' && this.leadSource != 'Hero' && !this.isTractor){//CISH-4
        ltvEngineMethod({ applicantId: this.appId, loanAppId: this.recordId }).then(result => {
                const obj = JSON.parse(result);
                console.log('doLTVEngineCallout() response:: ', obj);
                //this.ltv = this.leadSource === 'D2C' ? obj?.application?.applicationDecision?.ltv : obj.LTV; //D2C Changes Swapnil for new BRE the response format is different
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                FinalTermFields[LtvEngine_Ltv.fieldApiName] = this.ltv;
                console.log('update of doLTVEngineCallout');
                this.updateRecordDetails(FinalTermFields);
                if(!(this.isPA == true && this.leadSource == 'D2C')){
                    this.calldoPricingEngineCallout();
                }else if((this.isPA == true && this.leadSource == 'D2C')){

                    let ev = new CustomEvent('childmethod',
                        { detail: this.finalTermId }
                    );
                    this.dispatchEvent(ev);
                    this.isLoading = false;
                }
                
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                console.log('error. ', error);
            });
        }
    }
    calldoPricingEngineCallout() {
        //START D2C Changes Swapnil
        let pricingEngineMethod = doPricingEngineCallout;
        /*if(this.leadSource === 'D2C'){
            pricingEngineMethod = doPricingEngineCalloutNew;
        }*/
        //END D2C Changes Swapnil
        pricingEngineMethod({ applicantId: this.appId, loanAppId: this.recordId }).then(result => {
                const obj = JSON.parse(result);
                console.log('doPricingEngineCallout() response:: ', obj);
                this.thresholdNetIRR = this.leadSource === 'D2C' ? obj.application.applicationDecision.prescribedRate : obj.Threshold_Net_IRR; //D2C Changes Swapnil for new BRE the response format is different
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                FinalTermFields[PricingEngine_thresholdNetrr.fieldApiName] = this.thresholdNetIRR;
                console.log('update of calldoPricingEngineCallout');
                this.updateRecordDetails(FinalTermFields);
                let ev = new CustomEvent('childmethod',
                    { detail: this.finalTermId }
                );
                this.dispatchEvent(ev);
                this.isLoading = false;
                // this.calldoOfferEngineCallout();
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                console.log('error. ', error);
            });

    }
    onbasepricechange(event){
         this.BasicPrice=event.target.value;
        // let exShowroom=Number(this.GSTAmount) + Number(this.BasicPrice);//CISP-4291
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] =this.recordId;
        oppfields[Basic_Price.fieldApiName] =this.BasicPrice;
       // oppfields[Ex_showroom_price.fieldApiName]= exShowroom;//CISP-4291
        this.updateRecordDetails(oppfields);
        const vehiclefields={};
        vehiclefields[Vehicle_ID_FIELD.fieldApiName] = this.VarientId;
        vehiclefields[base_price.fieldApiName] = this.BasicPrice;
        this.updateRecordDetailsfields(vehiclefields,'Basic Price');
    }
    //SFTRAC-1335
    onInvoicePricechange(event){
        this.invoiceAmount=event.target.value;
        if(this.isTractor){
            const vehiclefields={};
            vehiclefields[Vehicle_ID_FIELD.fieldApiName] = this.VarientId;
            vehiclefields[Invoice_Price.fieldApiName] = this.invoiceAmount;
            this.updateRecordDetailsfields(vehiclefields,'Invoice Price');
        }    
   }
    
    ongstchange(event){
        this.GSTAmount=event.target.value;
        // let exShowroom=Number(this.GSTAmount) + Number(this.BasicPrice);//CISP-4291
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        let GSTAmountValue = event.target.value;
        oppfields[GST_Amount.fieldApiName] = (GSTAmountValue != null && GSTAmountValue != undefined && GSTAmountValue != '') ? Math.ceil(GSTAmountValue) : GSTAmountValue;
        // oppfields[Ex_showroom_price.fieldApiName] = exShowroom;//CISP-4291
        this.updateRecordDetailsfields(oppfields,'GST Amount');
    }
    
    ondealerdiscountchange(event){
        this.DealerDisctoCustomer=event.target.value;
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[Discount_on_Basic_Price.fieldApiName] = event.target.value;
        this.updateRecordDetailsfields(oppfields,'Discount Amount');
    }
    
    onotherchargeschange(event){
        this.Othercharges=event.target.value;
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[Other_charges.fieldApiName] = event.target.value;
        this.updateRecordDetailsfields(oppfields,'Other charges');
        if(this.isRtoRoadTaxFieldEnable){//CISP-2346
            this.calculateORP();
        }else{//CISP-4730
            this.calculateORPCarWale();
        }
    }
    
    insurancecpremiumchange(event){
        this.X1styrInsurancePremium=event.target.value;
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[X1st_yr_Insurance_Premium.fieldApiName] = event.target.value;
        this.updateRecordDetailsfields(oppfields,'Insurance Premium');
        if(this.isRtoRoadTaxFieldEnable){//CISP-2346
            this.calculateORP();
        }else{//CISP-4730
            this.calculateORPCarWale();
        }
    }
    
    fundingonexshowroomchange(event){
        this.FundingonExShowroomboolean=event.target.value;
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[Funding_on_Ex_Showroom.fieldApiName] = event.target.value;
        this.updateRecordDetailsfields(oppfields,'Funding on Ex Showroom');
    }
    
    fundingonorpchange(event){
        this.FundingonORPboolean=event.target.value;
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[Funding_on_ORP.fieldApiName] = event.target.value;
        this.updateRecordDetailsfields(oppfields,'Funding on ORP');
        // CISP-2346
        if(this.isRtoRoadTaxFieldEnable){
            this.otherCharges = 0;
            this.calculateORP();
            this.calculateORPCarWale();
        }
        // CISP-2346
    }
    
    onloanchange(event){
        this.RequiredLoanamount=event.target.value;
        // if(this.RequiredLoanamount > parseInt(this.OnRoadprice,10)) {  //Start CISP-2522
            //     elem.setCustomValidity('Please enter value less than On Road Price '+this.OnRoadprice);    
            // }
            if (this.vehicleTypeName.toLowerCase() === 'New'.toLowerCase() && (this.FundingonExShowroom=='True' || this.FundingonExShowroom=='true') && this.Exshowroomprice!=null && ((parseFloat(this.RequiredLoanamount) + parseFloat(this.TotalfundedPremium)) > parseFloat(this.Exshowroomprice))) {//CISP-2347
                elem.setCustomValidity('Please enter value less than Ex Showroom Price '+this.Exshowroomprice);
            }
            else if (this.vehicleTypeName.toLowerCase() === 'New'.toLowerCase() && (this.FundingonORP=='True' || this.FundingonORP=='true') && this.OnRoadprice!=null && ((parseFloat(this.RequiredLoanamount) + parseFloat(this.TotalfundedPremium)) > parseFloat(this.OnRoadprice))) {//CISP-2347
                elem.setCustomValidity('Please enter value less than On Road Price '+this.OnRoadprice);
            }
            else if ((this.vehicleTypeName.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeName.toLowerCase() === 'Used'.toLowerCase()) && this.BasePrices!=null && ((parseFloat(this.RequiredLoanamount) + parseFloat(this.TotalfundedPremium)) > parseFloat(this.BasePrices))) {//CISP-2347
            elem.setCustomValidity('Please enter value less than Base Price '+ this.BasePrices);
            }//End CISP-2522
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[Required_Loan_amount.fieldApiName] = event.target.value;
        this.updateRecordDetailsfields(oppfields,'Required Loan Amount');
    }
    /* calldoOfferEngineCallout() {
         let offerEngineRequestString = {
             'loanApplicationId':this.recordId,
             'currentScreen':'Offer'
             };
         doOfferEngineCallout({ offerEngineRequestString : JSON.stringify(offerEngineRequestString) })
             .then(result => {
                 const obj = JSON.parse(result);
                 console.log('doOfferEngineCallout data ', obj);
                 this.iconButtonCaptureUpload = true;
                 this.imageUploadRedCross = false;
                 const FinalTermFields = {};
                 FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                 FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI;
                 FinalTermFields[Tenure.fieldApiName] = obj.Tenure;
                 FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt;
                 FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR
                 FinalTermFields[Required_CRM_IRR.fieldApiName] = obj.CRM_IRR;
                 FinalTermFields[OfferengineMaxTenure.fieldApiName] = obj.Max_Tenure_Slider;
                 FinalTermFields[OfferengineMinTenure.fieldApiName] = obj.Min_Tenure_Slider;
                 FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = obj.OfferengineMinLoanAmount__c;
                 FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = obj.Max_Loan_Amt_Slider;
                 this.updateRecordDetails(FinalTermFields);
                 const event = new ShowToastEvent({
                     title: 'Success',
                     variant: 'Success',
                 });
                 this.dispatchEvent(event);
             })
             .catch( error => {
                 const event = new ShowToastEvent({
                     title: 'Error',
                     variant: 'error',
                     message:error.body.message,
                 });
                 this.dispatchEvent(event);
              console.log('error. ',error);
              });
     }*/
     async updateRecordDetailsfields(fields,valuestring) {
        const recordInput = { fields };
        const methodval=valuestring;
        await updateRecord(recordInput)
            .then(() => {
                const event = new ShowToastEvent({
                    title: methodval+' value Updated',
                    variant: 'Success',
                    mode: 'dismissible',
                });
                if(this.initialD2CSave == false){
                    this.dispatchEvent(event);
                }
                
                console.log('after update', recordInput);
                return true;
            })
            .catch(error => {
                console.log('Error in update', error);
            });
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        console.log('before update ', recordInput);
        await updateRecord(recordInput)
            .then(() => {
                console.log('inside update');
            })
            .catch(error => {
                console.log('record update fail in catch', JSON.stringify(fields));
                //console.log('record update Fields: ', fields);
                //console.log('record update error', error);
            });
    }
    handleExshowPriceChange(){
        let exshowpriceTWNew = this.template.querySelector('lightning-input[data-id=exshowpriceTWNew]').value;
        if(this.leadSource === 'D2C'){
            this.Exshowroomprice = exshowpriceTWNew;
        }
        exshowpriceTWNew = exshowpriceTWNew?exshowpriceTWNew:0;
        
        console.log('exshowpriceTWNew--- : ',exshowpriceTWNew);
        if (exshowpriceTWNew && this.eScooter) {
            this.BasicPrice = (parseFloat(exshowpriceTWNew)/1.05).toFixed(0);
            this.GSTAmount = parseFloat(exshowpriceTWNew) -  parseFloat(this.BasicPrice); 
        }else if(exshowpriceTWNew){
        this.BasicPrice = (parseFloat(exshowpriceTWNew)/1.28).toFixed(0);
        this.GSTAmount = parseFloat(exshowpriceTWNew) -  parseFloat(this.BasicPrice);
        
        }else{
            this.BasicPrice = 0;
            this.GSTAmount = 0;
            
        }
        this.calculateORP();
        this.calculateORPCarWale();
        console.log('this.basicPrice : ',this.basicPrice); 
        if(this.leadSource === 'D2C'){//D2C Change Raman
            this.runoffer = false;
        }
    }
    TWRtoChange(event){
        this.rtoRoaTaxVal=event.target.value;
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[RTO_Road_Tax_TW.fieldApiName] = event.target.value;
        if(parseFloat(event.target.value <=0)){
            const event = new ShowToastEvent({
                title: 'warning',
                message: RTO_Road_Tax_Error,
                variant: 'warning',
            });
            this.dispatchEvent(event);
                return;
        }
        this.updateRecordDetailsfields(oppfields,'RTO Value');
    }
    exshowroomPriceChange(event){
        this.Exshowroomprice=event.target.value;
        const oppfields = {};
        oppfields[oppId_field.fieldApiName] = this.recordId;
        oppfields[Ex_showroom_price.fieldApiName] = event.target.value;
        this.updateRecordDetailsfields(oppfields,'Ex showroom price');
        const oppfields1 = {};
        oppfields1[oppId_field.fieldApiName] = this.recordId;
        oppfields1[Basic_Price.fieldApiName] = this.BasicPrice;
        this.updateRecordDetailsfields(oppfields1,'Basic price');
        const oppfields2 = {};
        oppfields2[oppId_field.fieldApiName] = this.recordId;
        oppfields2[GST_Amount.fieldApiName] = (this.GSTAmount != null && this.GSTAmount != undefined && this.GSTAmount != '') ? Math.ceil(this.GSTAmount) : this.GSTAmount;
        this.updateRecordDetailsfields(oppfields2,'GST Amount');
    }
    handleRTOChange(event){
        console.log('OUTPUT handleRTOChange: ',);
        let rtoRoaTaxVal = event.target.value; //CISP-6540 start  
        if(this.productTypeDetail == PassengerVehicles){
            this.rtoRoaTaxVal = rtoRoaTaxVal;
            const carwalefields = {};
            carwalefields[carwaleID.fieldApiName] = this.recordId;
            carwalefields[RTO_Road_Tax_TW.fieldApiName] = this.rtoRoaTaxVal;
        this.updateRecordDetails(carwalefields);
             if(this.isRtoRoadTaxFieldEnable){
                 this.calculateORP();
             }else{//CISP-4730
               this.calculateORPCarWale();
         } ////CISP-6540 end
    } else{

        this.rtoRoaTaxVal = rtoRoaTaxVal;
        if(this.isRtoRoadTaxFieldEnable){//CISP-2346
            this.calculateORP();
            this.calculateORPCarWale();
        }
       
     } if(this.leadSource === 'D2C'){//D2C Change Raman
            this.runoffer = false;
        }
    }
      //CISP-6540
      handleRTOChangeCar(event){
        let RTORoadTax = event.target.value;   
        this.RTORoadTax = RTORoadTax;
        const carwalefields = {};
        carwalefields[carwaleID.fieldApiName] = this.recordId;
        carwalefields[RTO_Road_Tax_TW.fieldApiName] = this.RTORoadTax;
        this.updateRecordDetails(carwalefields);
        if(this.isRtoRoadTaxFieldEnable){
            this.calculateORP();
            this.calculateORPCarWale();
        }
    }
    //CISP-6540

    // CISP-2346-START
    // handleCarWaleRTOChange(event){
    //     let rtoRoaTaxVal = event.target.value;
    //     this.RTORoadTax = rtoRoaTaxVal;
    //     const carwalefields = {};
    //     carwalefields[carwaleID.fieldApiName] = this.recordId;
    //     carwalefields[RTO_Road_Tax_Carwale.fieldApiName] = this.RTORoadTax;
    //     this.updateRecordDetails(carwalefields);
    //     if(this.isRtoRoadTaxFieldEnable){
    //         this.calculateORP();
    //         this.calculateORPCarWale();
    //     }
    // }
    // CISP-2346-END

    calculateORP(){
        console.log('Exshowroom + RTO road tax + 1st year insurance premium + other charges : ',);        
        let exshowpriceTWNew = this.Exshowroomprice?this.Exshowroomprice:0;//CISP-2346//CISP-2556
        exshowpriceTWNew = exshowpriceTWNew?exshowpriceTWNew:0;
        this.X1styrInsurancePremium = this.X1styrInsurancePremium?this.X1styrInsurancePremium:0;
        
        this.rtoRoaTaxVal = this.rtoRoaTaxVal?this.rtoRoaTaxVal:0;
        this.Othercharges = this.Othercharges?this.Othercharges:0;
        console.log('exshowpriceTWNew : ',exshowpriceTWNew);
        console.log('rtoRoaTaxVal : ',this.rtoRoaTaxVal);
        console.log('Othercharges : ',this.Othercharges);
        if(this.leadSource!='OLA'){this.OnRoadprice = parseFloat(exshowpriceTWNew) + parseFloat(this.rtoRoaTaxVal) + parseFloat(this.X1styrInsurancePremium) + parseFloat(this.Othercharges);}//OLA-90
        // D2C Change
        if(this.leadSource == 'D2C' && (this.Exshowroomprice == 0 || !this.Exshowroomprice) && this.dealerQuotedORP){
            this.OnRoadprice = parseFloat(this.dealerQuotedORP) + parseFloat(this.X1styrInsurancePremium);
        }
        //EO D2C Change
        console.log('this.onRoadPrice : ',this.OnRoadprice);
        const carwalefields = {};      
        carwalefields[On_Road_price.fieldApiName] = this.OnRoadprice;
        carwalefields[carwaleID.fieldApiName] = this.recordId;
        this.updateRecordDetails(carwalefields);
        if(this.OnRoadprice){
            let ev = new CustomEvent('updateorpamount',{ detail: this.OnRoadprice });
            this.dispatchEvent(ev);
        }
    }
    calculateORPCarWale(){
        console.log('Exshowroom + RTO Road tax carwale + 1st year insurance premium + other charges : ',);
        let exshowpriceTWNew = this.Exshowroompricecarwale?this.Exshowroompricecarwale:0;//CISP-2346//CISP-2556
        exshowpriceTWNew = exshowpriceTWNew?exshowpriceTWNew:0;
        this.X1styrInsurancePremium = this.X1styrInsurancePremium?this.X1styrInsurancePremium:0;
        console.log('this.rtoRoadTax : ',this.RTORoadTax);
        this.RTORoadTax = this.RTORoadTax?this.RTORoadTax:0;
        this.Othercharges = this.Othercharges?this.Othercharges:0;
        
        this.OnRoadpricecarwale = parseFloat(exshowpriceTWNew) + parseFloat(this.RTORoadTax) + parseFloat(this.X1styrInsurancePremium) + parseFloat(this.Othercharges);
        
        const carwalefields = {};      
        carwalefields[ORPcarwale.fieldApiName] = this.OnRoadpricecarwale;
        carwalefields[carwaleID.fieldApiName] = this.recordId;
        this.updateRecordDetails(carwalefields);
    }

    calculateAllValues() {
    if(this.leadSource=='OLA'){
        this.RTORoadTax = this.rtoRoaTaxVal;//OLA-140
    }
    if (this.BasicPrice === '' || this.GSTAmount === '' || this.DealerDisctoCustomer === '' || this.Exshowroompricecarwale === '' || this.X1styrInsurancePremium === '' || this.Othercharges === '' || this.RTORoadTax === '') {
            console.log('Blocking calculations - required fields empty');
            return;
        } else {
            let detail = {
                basicPricedetail: parseInt(this.BasicPrice, 10),
                gstAmountdetail: parseInt(this.GSTAmount, 10),
                discountOnBasicPriceDetail: parseInt(this.DealerDisctoCustomer, 10),
                exShowroomPriceCarwaledetail: parseInt(this.Exshowroompricecarwale, 10),
                insurancePremiumDeatil: parseInt(this.X1styrInsurancePremium, 10),
                otherChargesDetail: parseInt(this.Othercharges, 10),
                rtoRoadTaxDetail: parseInt(this.RTORoadTax, 10),
                rtoRoaTaxVal: parseInt(this.rtoRoaTaxVal, 10),//CISP-2346
            };

            calculatePrices({ detail: JSON.stringify(detail) }).then(result => {
                let response = JSON.parse(result);
                console.log('response calculatePrices', response);
                this.Exshowroomprice = response.exShowroomPriceOne;
                if (this.fromApi) {
                    this.Exshowroompricecarwale = response.exShowroomPriceTwo;
                    this.OnRoadpricecarwale = response.onRoadPriceTwo;
                }
                if(!this.isRtoRoadTaxFieldEnable){
                    this.OnRoadprice = response.onRoadPriceOne;
                }
                //this.finalPrice = response.finalPrice; //Calculation Only
                //CISP-4730
                const oppfields = {};
                if(this.leadSource=='OLA'){
                    this.OnRoadprice = this.OnRoadprice//OLA-189
                   // this.OnRoadprice = this.OnRoadprice + parseInt(this.performanceUp) - parseInt(this.famesub);//OLA-140
                }
                oppfields[oppId_field.fieldApiName] = this.recordId;
                oppfields[Ex_showroom_price.fieldApiName] = this.Exshowroomprice;
                oppfields[On_Road_price.fieldApiName]= this.OnRoadprice ;
                this.updateRecordDetailsfields(oppfields,'Ex Showroom and On-Road Price');
                // D2C Change
                if(this.leadSource == 'D2C' && (this.Exshowroomprice == 0 || !this.Exshowroomprice) && this.dealerQuotedORP){
                    this.OnRoadprice = parseFloat(this.dealerQuotedORP) + parseFloat(this.X1styrInsurancePremium);
                }
                //EO D2C Change
            }).catch(error => {
                console.log("Error in calculating Carwale Prices:: ", error);
            });
        }
    }
    @track vehiclefieldsTF = {}//SFTRAC-1218
    calculateAllValuesTractor(event) {
        let value  = event.target.value;
        let fieldAPIName = event.target.dataset.name;
        if(fieldAPIName == 'Loan_Amount__c' && event.target.value){
            this.RequiredLoanamount = parseInt(event.target.value);
        }
        this.vehiclefieldsTF[fieldAPIName] = value ;
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }

    enableOfferEngine(){
        if(this.leadSource === 'D2C' || this.isTractor){//D2C Change Raman
            this.runoffer = false;
            if(this.isTractor){//SFTRAC-1439
                let ev = new CustomEvent('parentmethodaccept');
                this.dispatchEvent(ev);
            }
        }
    }

    disableEverything(){
        
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => element.disabled = true);

    }

    @api handleFailedOfferEngine(){//Start CISP-60
        this.runoffer=false;
        this.pricedetails=false;
    }//End CISP-60
}