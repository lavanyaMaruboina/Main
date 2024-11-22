import { LightningElement, wire, api, track } from "lwc";
import getApplicantData from "@salesforce/apex/beScreensController.getApplicantData";
import getRefreshedApplicantData from "@salesforce/apex/beScreensController.getRefreshedApplicantData";

export default class BePreApprovedScreen extends LightningElement {

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
    @track insurances = [];
    isSpinnerMoving = false;
    connectedCallback(){
      this.isSpinnerMoving = true;
      getApplicantData({ 'recordId': this.appId})
      .then((data) =>{
      //console.log("wired : ", this.appId);
      if (data) {
        this.applicantData = JSON.parse(JSON.stringify(data));
        //this.productType();
        var that = this;
        setTimeout(function () {
          //that.validateFields();
        }, 100);
  
        this.error = undefined;
        this.isSpinnerMoving = false;
      } else {
        this.isSpinnerMoving = false;
        this.error = error;
        this.applicantData = undefined;
      }
    }).catch(error=>{
        this.error = error;
        this.applicantData = undefined;
        this.isSpinnerMoving = false;
    });

    }
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
    get productType(){
        let val;
        if(this.applicantData?.initialOfferDetails){
            console.log('this.applicantData.initialOfferDetails ',JSON.stringify(this.applicantData.initialOfferDetails));

            val = this.applicantData.initialOfferDetails.Product_Type__c+' '+this.applicantData.initialOfferDetails.Vehicle_Type__c;  
            //val=      
            if(val === 'Two Wheeler New')   
                this.twoWheeler = true;
            else if(val === 'Passenger Vehicles Used'){
                this.PVUsed = true;
                this.etb = false;
            }            
            else if(this.applicantData.initialOfferDetails.Vehicle_Type__c === 'Refinance'){
                this.refinance = true;
                this.etb = false;
            }
            else if(this.applicantData.initialOfferDetails.LeadSource == 'Droom'){
                this.aggregator = true;
            }
          
        }
        console.log('final val', val);
        return val;
    }

    getRefreshedDetails() {
        getRefreshedApplicantData({ recordId: this.appId })
          .then((data) => {
            console.log(JSON.parse(JSON.stringify(data)));
            this.applicantData = JSON.parse(JSON.stringify(data));
          })
          .error((error) => {
            console.log(error);
          });
      }

      get initialOffer() {
        return this.applicantData?.initialOfferDetails == null
          ? {}
          : this.applicantData.initialOfferDetails;
      }

      

      get applicant() {
        if (this.applicantData?.applicant) {
          if (
            this.applicantData.applicant.Contact_number__c != null &&
            this.applicantData.applicant.Contact_number__c ===
              this.applicantData.applicant.Whatsapp_number__c
          ) {
            this.applicantData.applicant.areWhatsappMobileSame = true;
          }
        }
        return this.applicantData?.applicant == null
          ? {}
          : this.applicantData.applicant;
      }

      get panNumber() {
        return (this.applicant.PAN_No__c != null && this.applicant.PAN_No__c != undefined) ? this.applicant.PAN_No__c.toUpperCase(): this.applicant.PAN_No__c;
      }

      get poaDocument() {
        return this.applicantData?.poaDetails == null
          ? {}
          : this.applicantData.poaDetails;
      }


      get currentDocument(){
        //console.log('appid',this.applicantData);
        return this.applicantData?.currentAddressDetails == null?{}:this.applicantData.currentAddressDetails;
      }

      get permanentDocument(){
        return this.applicantData?.permanentAddressDetails == null?{}:this.applicantData.permanentAddressDetails;
    }

    get isETB(){
        return this.applicantData?.initialOfferDetails?.Is_ETB__c == true ? true : false;
    }

    get showPostOfferKYC(){
        return this.applicantData?.initialOfferDetails?.Is_ETB__c == false ? false : this.applicantData?.initialOfferDetails?.RE_KYC_Stage__c == 'PostInitialOffer'?true:false;
    }

    get aadharDocument(){
        return this.applicantData?.aadharAddressDetails == null?{}:this.applicantData.aadharAddressDetails;
    }
    get incomeDetails(){
        return this.applicantData?.incomeDetails == null?{}:this.applicantData.incomeDetails;
    }

    get isMarried(){
        return this.applicantData?.applicant == null?{}:(this.applicantData.applicant.Marital_status__c).toUpperCase() === 'MARRIED' ?true:false;
    }

    get executiveName() {
      return this.applicantData?.applicant?.Opportunity__r == null ? {} : this.applicantData.applicant.Opportunity__r.Owner.Name; 
    }

    get executiveNumber() {
      return this.applicantData?.applicant?.Opportunity__r  == null ? {} : this.applicantData.applicant.Opportunity__r.Owner.MobilePhone; 
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

      get finalTermDetails(){
        return this.applicantData?.finalTermDetails == null?{}:this.applicantData.finalTermDetails;
  
    }

    get statusOfVKYC() { return this.applicantData?.initialOfferDetails?.VKYC_Doc_Downloaded__c ? 'Documents Downloaded' : 'Not Downloaded'; }

    get insuranceDetails(){ 
        if(this.applicantData?.insuranceDetails) {
            console.log('insuranceDetails: ',JSON.stringify(this.applicantData.insuranceDetails));
            this.applicantData.insuranceDetails.forEach(e=>{
              e.isFunded = e.Funded_Non_funded__c == 'Funded';
            });
            this.insurances = this.applicantData.insuranceDetails;
        }
        console.log('this.insurances: ',this.insurances);
        return this.applicantData?.insuranceDetails != null && this.applicantData?.insuranceDetails != undefined && this.applicantData.insuranceDetails.length > 0;
    }
    get isSTPCustomer(){
        return this.applicantData?.initialOfferDetails?.Sanction_Status__c == 'Non-STP'?false:true;
    }
    get finalTermDetails(){
        return this.applicantData?.finalTermDetails == null?{}:this.applicantData.finalTermDetails;
  
    }
    get sanctionStatus() { return this.applicantData?.initialOfferDetails?.Sanction_Status__c == 'STP' ? 'Final Sanction' : 'In Principle Offer'; }
    
    get fiTriggered() {
        //*If all blank then show No
        if((this.finalTermDetails.FIwaiver_currentAddress__c == null || this.finalTermDetails.FIwaiver_currentAddress__c == undefined || this.finalTermDetails.FIwaiver_currentAddress__c == '') &&
        (this.finalTermDetails.FIwaiver_offAddress__c == null || this.finalTermDetails.FIwaiver_offAddress__c == undefined || this.finalTermDetails.FIwaiver_offAddress__c == '') &&
        (this.finalTermDetails.FIwaiver_presentAddress__c == null || this.finalTermDetails.FIwaiver_presentAddress__c == undefined || this.finalTermDetails.FIwaiver_presentAddress__c == '')){
            return 'No';
        }

        //*If any one of them is different then “Yes (Not Waived)”
        if((this.finalTermDetails.FIwaiver_currentAddress__c == 'Waived' || this.finalTermDetails.FIwaiver_offAddress__c == 'Waived' || this.finalTermDetails.FIwaiver_presentAddress__c == 'Waived') &&
        (this.finalTermDetails.FIwaiver_currentAddress__c != this.finalTermDetails.FIwaiver_offAddress__c && this.finalTermDetails.FIwaiver_offAddress__c != this.finalTermDetails.FIwaiver_presentAddress__c)) {
            return 'Yes (Not Waived)';
        }

        if(this.finalTermDetails.FIwaiver_currentAddress__c == 'Waived' && this.finalTermDetails.FIwaiver_offAddress__c == 'Waived' && this.finalTermDetails.FIwaiver_presentAddress__c == 'Waived') {
            return 'Yes (Waived)';
        }
        return '';
    }
    get finalOfferGenerated(){
        return this.applicantData?.initialOfferDetails?.Sanction_Status__c != null?true:false;
    }
    get MMV(){
        return this.applicantData?.vehicleDetails == null?{}:this.applicantData.vehicleDetails? this.applicantData.vehicleDetails.Make__c+' '+this.applicantData.vehicleDetails.Model__c+' '+this.applicantData.vehicleDetails.Variant__c:null;
    }
    
    
}