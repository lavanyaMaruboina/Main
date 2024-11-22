// Author: Haarika Chodisetti
// Company: Salesforce
// Description: Child component for Business Executive Post Initial Offer functionality
import { LightningElement, wire, api, track } from 'lwc';
import getApplicantData from '@salesforce/apex/beScreensController.getApplicantData';
import getRefreshedApplicantData from '@salesforce/apex/beScreensController.getRefreshedApplicantData';
//START-Labels
import D2C_E_Statement_Upload from "@salesforce/label/c.D2C_E_Statement_Upload";
import D2C_GST_Document_Upload from "@salesforce/label/c.D2C_GST_Document_Upload";
import D2C_ITR_V_Document_Upload from "@salesforce/label/c.D2C_ITR_V_Document_Upload";
import D2C_Net_Banking from "@salesforce/label/c.D2C_Net_Banking";
import D2C_Online_GST_login from "@salesforce/label/c.D2C_Online_GST_login";
import D2C_Online_ITR_login from "@salesforce/label/c.D2C_Online_ITR_login";
import D2C_OnlineBankingCredentials from "@salesforce/label/c.D2C_OnlineBankingCredentials";

export default class LightningExampleAccordionMultiple extends LightningElement {
    label = {
        D2C_E_Statement_Upload,
        D2C_GST_Document_Upload,
        D2C_ITR_V_Document_Upload,
        D2C_Net_Banking,
        D2C_Online_GST_login,
        D2C_Online_ITR_login,
        D2C_OnlineBankingCredentials
    };
    activeSections = ['loginDetails'];
    activeSectionsMessage = '';
    recordId;
    @track applicantData;
    @track refreshedData;
    @track error;
    @api appId;
    twoWheeler = false;
    PVUsed = false;
    PV = false;
    refinance = false;
    etb = true;
    aggregator = false;
     isAggregator = false; //CFDI-634
    LeadSource='';
    otherDealers = false;
    incomeMethod = false;
    itrMethod = false;
    gstMethod = false;
    abbMethod = false;
    incomeMethodEStatementUpload;
    incomeMethodOnlineBankingCreds;
    gstMethodDocument;
    gstMethodOnline;
    abbMethodEStatementUpload;
    abbMethodNetBanking;
    itrMethodITRV;
    itrMethodOnline;
    @track insurances = [];
    
    renderedCallback(){
        if(this.applicantData?.initialOfferDetails?.Sanction_Status__c == null || this.applicantData?.initialOfferDetails?.Sanction_Status__c == undefined || this.applicantData?.initialOfferDetails?.Sanction_Status__c ==''){
        this.template.querySelector('lightning-input[data-id=removeVal]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal1]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal2]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal3]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal4]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal5]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal6]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal7]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal8]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal9]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal10]').value='';
        this.template.querySelector('lightning-input[data-id=removeVal11]').value='';
    }
    }
    isSpinnerMoving = false;
    connectedCallback(){
    this.isSpinnerMoving = true;
    getApplicantData({ 'recordId': this.appId})
    .then((data) =>{
        if (data) {
            console.log('RNData-->'+data?.initialOfferDetails?.Sanction_Status__c)  
        /* for (let i = 0; i < finalAcceptance.length; ++i) {
            finalAcceptance[i].value = "green";
          }*/
                this.applicantData = JSON.parse(JSON.stringify(data));
            this.productType();
            var that = this;
            setTimeout(function() {
                that.validateFields();
            }, 100);
            if(this.applicantData?.incomeDetails?.Capture_Income_Method__c != null){
                this.incomeMethod = true;
                if(this.applicantData?.incomeDetails.Capture_Income_Method__c === 'Online via link'){
                  this.incomeMethodOnlineBankingCreds = true;
                }else if(this.applicantData?.incomeDetails.Capture_Income_Method__c === 'Upload online via link'){
                  this.incomeMethodEStatementUpload = true;
                }
            }else if(this.applicantData?.incomeDetails?.Capture_ITR_Method__c != null){
                this.itrMethod = true;
                if(this.applicantData?.incomeDetails.Capture_ITR_Method__c === 'Online via link'){
                    this.itrMethodOnline = true;
                }else if(this.applicantData?.incomeDetails.Capture_ITR_Method__c === 'Upload online via link'){
                    this.itrMethodITRV = true;
                }
            }else if(this.applicantData?.incomeDetails?.Capture_GST_Method__c != null){
                this.gstMethod = true;
                if(this.applicantData?.incomeDetails.Capture_GST_Method__c === 'Online via link'){
                    this.gstMethodOnline = true;
                }else if(this.applicantData?.incomeDetails.Capture_GST_Method__c === 'Upload online via link'){
                    this.gstMethodDocument = true;
                }
            }else if(this.applicantData?.incomeDetails?.ABB_Method__c != null){
                this.abbMethod = true;
                if(this.applicantData?.incomeDetails.ABB_Method__c === 'Online via link'){
                    this.abbMethodNetBanking = true;
                }else if(this.applicantData?.incomeDetails.ABB_Method__c === 'Upload online via link'){
                    this.abbMethodEStatementUpload = true;
                }
            }
            if(this.applicantData?.incomeDetails?.Is_Self_Employed__c == true && this.applicantData?.incomeDetails?.ABB_Method__c != null){
                this.abbMethod = true;
                if(this.applicantData?.incomeDetails.ABB_Method__c === 'Online via link'){
                    this.abbMethodNetBanking = true;
                }else if(this.applicantData?.incomeDetails.ABB_Method__c === 'Upload online via link'){
                    this.abbMethodEStatementUpload = true;
                }
            }
            this.error = undefined;
            this.template.querySelector('lightning-input[data-id=removeVal10]').value=this.applicantData?.initialOfferDetails?.Sanction_Status__c == 'STP' ? 'Final Sanction' : 'In Principle Offer';
            this.isSpinnerMoving = false;
        } else {
            this.isSpinnerMoving = false;
            this.error = error;
            this.applicantData = undefined;
        }
    }).catch(error=>{
        this.isSpinnerMoving = false;
        this.error = error;
        this.applicantData = undefined;
    });

    }
    

    getRefreshedDetails(){
        getRefreshedApplicantData({ recordId: this.appId})
        .then(data => {
            this.applicantData = JSON.parse(JSON.stringify(data));
        })
        .catch(error =>{
            console.log(error);
        })
    }

    get salaried(){
        let ans;
        if(this.applicantData?.applicant){
            ans = this.applicantData.applicant.Income_Ca__c === 'SAL';
        }  
        return ans;
    }

    productType(){
        let val;
        if(this.applicantData?.initialOfferDetails){
            console.log('this.applicantData.initialOfferDetails ',JSON.stringify(this.applicantData.initialOfferDetails));
            val = this.applicantData.initialOfferDetails.Product_Type__c+' '+this.applicantData.initialOfferDetails.Vehicle_Type__c;    
            if(val === 'Two Wheeler New')   
                this.twoWheeler = true;
            else if(val === 'Passenger Vehicles Used'){
                this.PVUsed = true;
                this.etb = false;
            }            
            else if(this.applicantData.initialOfferDetails.Vehicle_Type__c === 'Refinance'){
                this.refinance = true;
                console.log('this.refinance-->'+this.refinance);
                this.etb = false;
            }
            else if(this.applicantData.initialOfferDetails.LeadSource == 'Droom'){
                this.aggregator = true;
            }
                
          
        }
    }
    get isAggregatorval(){
        console.log('lead-->'+this.applicantData?.initialOfferDetails?.LeadSource);
        console.log('lead1-->'+this.applicantData?.initialOfferDetails?.Aggregator_Source__c );
        return this.applicantData?.initialOfferDetails?.LeadSource=='D2C' &&  this.applicantData?.initialOfferDetails?.Aggregator_Source__c ? true:false  //CFDI-634
    }
    get isSTPCustomer(){
        return this.applicantData?.initialOfferDetails?.Sanction_Status__c == 'Non-STP'?false:true;
    }

    get finalOfferGenerated(){
        return this.applicantData?.initialOfferDetails?.Sanction_Status__c != null?true:false;
    }

    validateFields() {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if((element.value == null || element.value == "") && element.type != "checkbox" && !element.className.includes("auto-filled")){
                element.className='invalid';
            }
        });
    }

    get applicant(){
        console.log('this.applicantData1 : ',JSON.stringify(this.applicantData));
        if(this.applicantData?.applicant){
            if(this.applicantData.applicant.Contact_number__c != null && this.applicantData.applicant.Contact_number__c === this.applicantData.applicant.Whatsapp_number__c){
                this.applicantData.applicant.areWhatsappMobileSame = true;
            }
            //console.log('values are : ',this.applicantData.applicant.Income_Ca__c,' ',this.applicantData.applicant.Profile__c);
        }

        return this.applicantData?.applicant == null?{}:this.applicantData.applicant;
    }
    
    get isMarried(){
        return this.applicantData?.applicant == null?{}:(this.applicantData.applicant?.Marital_status__c)?.toUpperCase() === 'MARRIED' ?true:false;
    }
    

    get aadharDocument(){
        return this.applicantData?.aadharAddressDetails == null?{}:this.applicantData.aadharAddressDetails;
    }
    get currentDocument(){
        return this.applicantData?.currentAddressDetails == null?{}:this.applicantData.currentAddressDetails;
    }
    get permanentDocument(){
        return this.applicantData?.permanentAddressDetails == null?{}:this.applicantData.permanentAddressDetails;
    }

    get isPV(){
      return this.applicantData.initialOfferDetails.Product_Type__c === 'Passenger Vehicles';
    }

    get vehicleDetails(){
        if(this.applicantData?.vehicleDetails){
            if(this.applicantData.vehicleDetails.Dealer_Sub_dealer_name__c == 'Others')
                this.otherDealers = true;
        }
        
        return this.applicantData?.vehicleDetails == null?{}:this.applicantData.vehicleDetails;
    }

    get MMV(){
        return this.applicantData?.vehicleDetails == null?{}:this.applicantData.vehicleDetails? this.applicantData.vehicleDetails.Make__c+' '+this.applicantData.vehicleDetails.Model__c+' '+this.applicantData.vehicleDetails.Variant__c:null;
    }
    
    get incomeDetails(){
        return this.applicantData?.incomeDetails == null?{}:this.applicantData.incomeDetails;
    }

    get insuranceDetails(){ 
        if(this.applicantData?.insuranceDetails) {
            console.log('insuranceDetails: ',JSON.stringify(this.applicantData.insuranceDetails));
            this.applicantData.insuranceDetails.forEach(e=>{
                e.isFunded = e.Funded_Non_funded__c == 'Funded';
                if(!e.Insurance_Plan_Name__c || e.Insurance_Plan_Name__c === 'MOTOR'){
                    e.Insurance_Plan_Name__c = e.Insurance_Plan__c == 'MOTOR-TATA'?'TATA AIG MOTOR':'CHOLA MS MOTOR';
                }
            });
            this.insurances = this.applicantData.insuranceDetails;
            console.log('insuranceDetails2: ',JSON.stringify(this.insurances));
        }
        console.log('this.insurances: ',this.insurances);
        return this.applicantData?.insuranceDetails != null && this.applicantData?.insuranceDetails != undefined && this.applicantData.insuranceDetails.length > 0;
    }

    get finalTermDetails(){
        return this.applicantData?.finalTermDetails == null?{}:this.applicantData.finalTermDetails;
  
    }
    get existingEMIDetails(){
        return this.applicantData?.existingEMIDetails == null?{}:this.applicantData.existingEMIDetails;
    }

    get documentDetails(){
        return this.applicantData?.documentDetails == null?{}:this.applicantData.documentDetails;
    }

    get initialOffer(){
        return this.applicantData?.initialOfferDetails == null?{}:this.applicantData.initialOfferDetails;
    }

    get businessAddrDiffFromResAddr(){
        return !(this.applicantData?.incomeDetails?.Is_this_Current_Residence_Cum_office__c || this.applicantData?.incomeDetails?.Is_this_Permanent_Residence_Cum_office__c);
    }

    get isETB(){
        return this.applicantData?.initialOfferDetails?.Is_ETB__c == true ? true : false;
    }

    get isReKYC(){
        return this.applicantData?.initialOfferDetails?.RE_KYC_Stage__c != null ? true : false;
    }

    get showPostOfferKYC(){
        return this.applicantData?.initialOfferDetails?.Is_ETB__c == false ? false : this.applicantData?.initialOfferDetails?.RE_KYC_Stage__c == 'PostInitialOffer'?true:false;
    }

    get isTwoWheeler(){
        return this.applicantData?.initialOfferDetails?.Vehicle_Type__c === 'Two Wheeler';
    }
  
    get showGSTNumber(){
      return this.incomeDetails?.Capture_GST_Method__c != null;
    }

    get currSameAsAadhar(){
        return this.aadharDocument.Current_Residential_Address_Proof__c;
    }

    get permSameAsAadhar(){
        return this.aadharDocument.Permanent_Residential_Address_Proof__c;
    }

    get currSameAsBank(){
        return this.aadharDocument.Is_Address_As_per_Bank__c && this.aadharDocument.Current_Residential_Address_Proof__c;
    }

    get permSameAsBank(){
        return this.aadharDocument.Is_Address_As_per_Bank__c && this.aadharDocument.Permanent_Residential_Address_Proof__c;
    }

    get statusOfVKYC() { return this.applicantData?.initialOfferDetails?.VKYC_status__c ? this.applicantData?.initialOfferDetails?.VKYC_status__c : '';}

    get sanctionStatus() { return this.applicantData?.initialOfferDetails?.Sanction_Status__c == 'STP' ? 'Final Sanction' : 'In Principle Offer'; }

    get fiTriggered() {
        //*If all blank then show No
        if((this.finalTermDetails.FIwaiver_currentAddress__c == null || this.finalTermDetails.FIwaiver_currentAddress__c == undefined || this.finalTermDetails.FIwaiver_currentAddress__c == '') &&
        (this.finalTermDetails.FIwaiver_offAddress__c == null || this.finalTermDetails.FIwaiver_offAddress__c == undefined || this.finalTermDetails.FIwaiver_offAddress__c == '') &&
        (this.finalTermDetails.FIwaiver_presentAddress__c == null || this.finalTermDetails.FIwaiver_presentAddress__c == undefined || this.finalTermDetails.FIwaiver_presentAddress__c == '')){
            return 'No';
        }

        //*If any one of them is different then “Yes (Not Waived)”
        if((this.finalTermDetails.FIwaiver_currentAddress__c == 'Not Waived' || this.finalTermDetails.FIwaiver_offAddress__c == 'Not Waived' || this.finalTermDetails.FIwaiver_presentAddress__c == 'Not Waived')) {
            return 'Yes (Not Waived)';
        }

        if(this.finalTermDetails.FIwaiver_currentAddress__c == 'Waived' && this.finalTermDetails.FIwaiver_offAddress__c == 'Waived' && this.finalTermDetails.FIwaiver_presentAddress__c == 'Waived') {
            return 'Yes (Waived)';
        }
        return '';
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
}