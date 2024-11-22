import { LightningElement, wire, api, track  } from 'lwc';
import KycAddress1Pattern from '@salesforce/label/c.KycAddress1Pattern';
import KycAddress2Pattern from '@salesforce/label/c.KycAddress2Pattern';
import AddressValidation1 from '@salesforce/label/c.AddressValidation1';
import AddressValidation2 from '@salesforce/label/c.AddressValidation2';
import AddressValidation3 from '@salesforce/label/c.AddressValidation3';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import getStateMasterData from '@salesforce/apex/Utilities.getStateMasterData';
import getCityStateMaster from '@salesforce/apex/Utilities.getCityStateMaster';
import getDistrictsByState from '@salesforce/apex/Utilities.getDistrictsByState';
import getBeneOfficeAddress from '@salesforce/apex/Ind_Demographic.getBeneOfficeAddress';
import getBorrowerOfficeAddress from '@salesforce/apex/Ind_Demographic.getBorrowerOfficeAddress';

export default class Lwc_los_beneficiaryOfficeAddress extends LightningElement {
    label = {KycAddress1Pattern,KycAddress2Pattern,AddressValidation1,AddressValidation2,AddressValidation3,RegEx_Alphabets_Only
    }
    allStateData;
    cityValue;
    districtValue;
    minCurrentState;
    maxCurrentState;
    beneAddressLine1value;
    beneAddressLine2value;
    beneStateValue;
    beneDistrictValue;
    beneCityValue;
    benePinCodeValue;
    @api appId;
    @api recordId;
    isDisabled = false;
    borrowerOffice =false ;
    isCheckDisabled = false;
    isLoading = false;

    @wire(getStateMasterData) wiredStateMaster({ error, data }) {
        if (data) {
            let finalArrayTopush = [];
            if (data.length > 0) {
                for (let index = 0; index < data.length; index++) {
                    let stateValue = {};
                    stateValue.label = data[index].Name;
                    stateValue.value = data[index].Name;
                    stateValue.id = data[index].Id;
                    stateValue.stateMinValue = data[index].Pincode__c;
                    stateValue.stateMaxValue = data[index].Pincode_Starting_Max__c;
                    finalArrayTopush.push(stateValue);
                }
            }
            this.allStateData = finalArrayTopush;
        } if (error) {
            this.showToastMessage('', 'Error in fetching State details', 'error');
        }
    }
    async connectedCallback(){
    console.log('appId---'+this.appId);
    this.isLoading = true;
        await getBeneOfficeAddress({applicantId:this.appId}).then(data=>{console.log('data-----'+JSON.stringify(data))
        if(data){
            console.log('dist------'+data[0].Beneficiary_Office_District__c);
            console.log('city------'+data[0].Beneficiary_Office_City__c);
            console.log('state------'+data[0].Beneficiary_Office_State__c);


        this.beneAddressLine1value = data[0].Beneficiary_Office_Address_Line_1__c;
        this.beneAddressLine2value = data[0].Beneficiary_Office_Address_Line_2__c;
        this.beneStateValue = data[0].Beneficiary_Office_State__c;
        getDistrictsByState({ stateName: this.beneStateValue }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }
            this.districtValue = cityData;
            this.beneDistrictValue = data[0].Beneficiary_Office_District__c;
         }).catch(error => { this.isLoading = false;});
        getCityStateMaster({ stateName: this.beneStateValue }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }

            this.cityValue = cityData;
            this.beneCityValue = data[0].Beneficiary_Office_City__c;
            }).catch(error => {this.isLoading = false;}); 
        this.benePinCodeValue = data[0].Beneficiary_Office_Pincode__c;
        this.isDisabled = true;
        this.isCheckDisabled = true;
        this.isLoading = false;
        }
    }).catch(error=>{this.isLoading = false;});
    this.isLoading = false;
    }
    /*@wire(getBeneOfficeAddress,{applicantId:this.appId}) wiredBeneAddress({data,error}){
        if(data){
            console.log('data-----'+data.Beneficiary_Office_Address_Line_1__c);
        }
    } */
    async handlecheckborrower(event){
        this.isLoading = true;
       this.borrowerOffice = event.target.checked;
       console.log('checked---'+this.borrowerOffice);
       console.log('recordId-----'+this.recordId);
       if(this.borrowerOffice){
       await getBorrowerOfficeAddress({loanId:this.recordId}).then((data)=>{console.log(data)
       if(data){
        this.beneAddressLine1value = data.KYC_Address_Line_1__c;
        this.beneAddressLine2value = data.KYC_Address_Line_2__c;
        this.beneStateValue = data.KYC_State__c;
        this.benePinCodeValue = data.KYC_Pin_Code__c;
        getDistrictsByState({ stateName: this.beneStateValue }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }
            this.districtValue = cityData;
            this.beneDistrictValue = data.KYC_District__c;
            this.dispatchEvent(new CustomEvent('getdistrictvalue', { detail: this.beneDistrictValue }));
         }).catch(error => {this.isLoading = false});
         getCityStateMaster({ stateName: this.beneStateValue }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }

            this.cityValue = cityData;
            this.beneCityValue = data.KYC_City__c;
            this.dispatchEvent(new CustomEvent('getcityvalue', { detail: this.beneCityValue }));
            this.isLoading = false;
            }).catch(error => {this.isLoading = false}); 
       }}).catch(error =>{this.isLoading = false});
       this.isDisabled = true;
    } else {
        this.beneAddressLine1value = null;
        this.beneAddressLine2value = null;
        this.beneCityValue = null;
        this.beneDistrictValue = null;
        this.beneStateValue = null;
        this.benePinCodeValue = null;
        this.isDisabled = false;
        this.dispatchEvent(new CustomEvent('getcityvalue', { detail: this.beneCityValue }));
        this.dispatchEvent(new CustomEvent('getdistrictvalue', { detail: this.beneDistrictValue }));

    }
    this.dispatchEvent(new CustomEvent('getaddress1value', { detail: this.beneAddressLine1value }));
    this.dispatchEvent(new CustomEvent('getaddress2value', { detail: this.beneAddressLine2value }));
    this.dispatchEvent(new CustomEvent('getstatevalue', { detail: this.beneStateValue }));
    this.dispatchEvent(new CustomEvent('getpincodevalue', { detail: this.benePinCodeValue }));
    this.isLoading = false;
    }
    handleBeneficiaryAddress(event) {
        this.isLoading = true;
        let inputLabel = event.target.label;
        let address1;
        let address2;
        let state;
        let district;
        let city;
        let pincode;
        console.log('start-----'+inputLabel);
        if (inputLabel && inputLabel == 'beneAddressLine1') {
            this.beneAddressLine1value = event.target.value;
            address1 = this.template.querySelector('lightning-input[data-id=beneAddressLine1]');
        }else if(inputLabel && inputLabel == 'beneAddressLine2'){
            this.beneAddressLine2value = event.target.value;
            address2 = this.template.querySelector('lightning-input[data-id=beneAddressLine2]');
        } else if(inputLabel && inputLabel == 'beneState'){
            this.beneStateValue = event.target.value;
            this.dispatchEvent(new CustomEvent('getstatevalue', { detail: this.beneStateValue }));
            this.beneCityValue = null;
            this.beneDistrictValue = null;
            getDistrictsByState({ stateName: this.beneStateValue }).then(response => {
                let cityData = [];
                if (response && response.length > 0) {
                    for (let index = 0; index < response.length; index++) {
                        let cityObject = {};
                        cityObject.label = response[index].Name;
                        cityObject.value = response[index].Name;
                        cityObject.id = response[index].Id;
                        cityData.push(cityObject);
                    }
                }
                this.districtValue = cityData;
             }).catch(error => {this.isLoading = false;});
            getCityStateMaster({ stateName: this.beneStateValue }).then(response => {
                let cityData = [];
                if (response && response.length > 0) {
                    for (let index = 0; index < response.length; index++) {
                        let cityObject = {};
                        cityObject.label = response[index].Name;
                        cityObject.value = response[index].Name;
                        cityObject.id = response[index].Id;
                        cityData.push(cityObject);
                    }
                }
    
                this.cityValue = cityData;
                this.isLoading = false;
                }).catch(error => {this.isLoading = false;}); 
        } else if(inputLabel && inputLabel == 'beneDistrict'){
            this.beneDistrictValue = event.target.value;
            district = this.template.querySelector('lightning-input[data-id=beneDistrictId]');
            this.dispatchEvent(new CustomEvent('getdistrictvalue', { detail: this.beneDistrictValue }));
        } else if(inputLabel && inputLabel == 'beneCity'){
            this.beneCityValue = event.target.value;
            city = this.template.querySelector('lightning-input[data-id=beneCityId]');
            this.dispatchEvent(new CustomEvent('getcityvalue', { detail: this.beneCityValue }));
        } else if(inputLabel && inputLabel == 'benePinCode'){
            this.benePinCodeValue = event.target.value;
            pincode = this.template.querySelector('lightning-input[data-id=benePinCodeId]');
            if (this.benePinCodeValue && this.benePinCodeValue.length >= 2) {
                for (let index = 0; index < this.allStateData.length; index++) {
                    if (this.allStateData[index].value == this.beneStateValue) {
                        this.minCurrentState = this.allStateData[index].stateMinValue;
                        this.maxCurrentState = this.allStateData[index].stateMaxValue;
                    }
                }
                if (parseInt(this.benePinCodeValue.substring(0, 2)) < this.minCurrentState || parseInt(this.benePinCodeValue.substring(0, 2)) > this.maxCurrentState) {
                    pincode.setCustomValidity("Invalid pin code");
                } else {
                    pincode.setCustomValidity("");
                }
                if(pincode.reportValidity()){
                    console.log('pincode'+this.benePinCodeValue);
                    this.dispatchEvent(new CustomEvent('getpincodevalue', { detail: this.benePinCodeValue }));
                }
            }
        } 
        if(address1 != null){
       let addressL1 = address1.value;
        if (addressL1.length < 10) {
            address1.setCustomValidity(AddressValidation3);
        } else if (addressL1.length > 40) {
            address1.setCustomValidity(AddressValidation2);
        } else {
            address1.setCustomValidity("");
        }
        if(address1.reportValidity()){
            console.log('beneadd1-----'+this.beneAddressLine1value);
            this.dispatchEvent(new CustomEvent('getaddress1value', { detail: this.beneAddressLine1value }));
        }
        }
        if(address2 != null){
        let addressL2 = address2.value;
        if (addressL2.length < 10) {
            address2.setCustomValidity(AddressValidation3);
        } else if (addressL2.length > 40) {
            address2.setCustomValidity(AddressValidation2);
        } else {
            address2.setCustomValidity("");
        } 
        if(address2.reportValidity()){
            console.log('beneadd2-----'+this.beneAddressLine2value);
            this.dispatchEvent(new CustomEvent('getaddress2value', { detail: this.beneAddressLine2value }));
        }
     }   
     this.isLoading = false;
    } 

}