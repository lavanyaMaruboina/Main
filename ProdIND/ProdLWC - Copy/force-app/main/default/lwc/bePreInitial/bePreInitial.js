// Author: Haarika Chodisetti
// Company: Salesforce
// Description: Child component for Business Executive Pre Initial Offer functionality
import { LightningElement, wire, api, track } from 'lwc';
import getApplicantData from '@salesforce/apex/CTIApplicantViewController.getApplicantData';
import getRefreshedApplicantData from '@salesforce/apex/CTIApplicantViewController.getRefreshedApplicantData';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class bePreInitial extends LightningElement {
    activeSections = ['loginDetails'];
    activeSectionsMessage = '';
    recordId;
    @track applicantData;
    @track refreshedData;
    @track error;
    @api appId;
    twoWheeler = false;
    PV = false;
    refinance = false;
    etb = true;
    aggregator = false;

    @wire(getApplicantData, { recordId: '$appId'})
    wiredApplicant({ error, data }) {
        console.log('wired : ',this.appId);
        if (data) {
            this.applicantData = JSON.parse(JSON.stringify(data));
            var that = this;
            setTimeout(function() {
                that.validateFields();
            }, 100);
            
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.applicantData = undefined;
        }
    }
    

    getRefreshedDetails(){
        getRefreshedApplicantData({ recordId: this.recordId})
        .then(data => {
            this.applicantData = JSON.parse(JSON.stringify(data));
        })
        .error(error =>{
            console.log(error);
        })
    }

    get productType(){
        let val;
        if(this.applicantData?.initialOfferDetails){
            console.log('this.applicantData.initialOfferDetails ',this.applicantData.initialOfferDetails);

            val = this.applicantData.initialOfferDetails.Product_Type__c+' '+this.applicantData.initialOfferDetails.Vehicle_Type__c;    
            if(val === 'Two Wheeler New')   
                this.twoWheeler = true;
            else if(val === 'Passenger Vehicles Used'){
                this.PV = true;
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
        return val;
    }

    validateFields() {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if((element.value == null || element.value == "") && element.type != "checkbox" && !element.className.includes("auto-filled")){
                element.className='invalid';
            }
        });
    }

    // get aadharNo(){
    //     let val;
    //     let res;
    //     console.log('val appData: '+ this.applicantData);
    //     if(this.applicantData?.applicant){
    //         val = this.applicantData.applicant.Aadhar_No__c;
    //         //console.log('val : '+ val);

    //         const x = val.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
    //         res = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);

    //     }
    //     return res;
    //     //return 'XXXX-XXXX-XXX-' + val.right(4);

    //     // const x = val.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
    //     // return !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
    // }

    get applicant(){
        if(this.applicantData?.applicant){
            if(this.applicantData.applicant.Contact_number__c != null && this.applicantData.applicant.Contact_number__c === this.applicantData.applicant.Whatsapp_number__c){
                this.applicantData.applicant.areWhatsappMobileSame = true;
            }
        }
        return this.applicantData?.applicant == null?{}:this.applicantData.applicant;
    }

    showToast(toastTitle, message, variant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    
    get aadharDocument(){
        return this.applicantData?.aadharAddressDetails == null?{}:this.applicantData.aadharAddressDetails;
    }

    get vehicleDetails(){
        return this.applicantData?.vehicleDetails == null?{}:this.applicantData.vehicleDetails;
    }

    get incomeDetails(){
        return this.applicantData?.incomeDetails == null?{}:this.applicantData.incomeDetails;
    }

    get existingEMIDetails(){
        return this.applicantData?.existingEMIDetails == null?{}:this.applicantData.existingEMIDetails;
    }

    get initialOffer(){
        return this.applicantData?.initialOfferDetails == null?{}:this.applicantData.initialOfferDetails;
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