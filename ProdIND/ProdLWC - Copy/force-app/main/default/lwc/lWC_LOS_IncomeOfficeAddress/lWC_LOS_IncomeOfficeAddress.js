import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import KYC_Pin_Code_ErrorMessage from '@salesforce/label/c.KYC_Pin_Code_ErrorMessage';
import KYC_Address_ErrorMessage from '@salesforce/label/c.KYC_Address_ErrorMessage';
import Address_Pattern from '@salesforce/label/c.Address_Pattern';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import firstNameError from '@salesforce/label/c.Name_Er';
import Pin_code_Pattern from '@salesforce/label/c.Pin_code_Pattern';
import All_Details_Stored_Sucessfully from '@salesforce/label/c.All_Details_Stored_Sucessfully';
import Mandatory_fields_are_not_entered from '@salesforce/label/c.Mandatory_fields_are_not_entered';
import KycAddress1Pattern from '@salesforce/label/c.KycAddress1Pattern';
import KycAddress2Pattern from '@salesforce/label/c.KycAddress2Pattern';
import AddressValidation1 from '@salesforce/label/c.AddressValidation1';
import AddressValidation2 from '@salesforce/label/c.AddressValidation2';
import AddressValidation3 from '@salesforce/label/c.AddressValidation3';
import AddressnotValid from '@salesforce/label/c.AddressnotValid';
import getStateMasterData from '@salesforce/apex/Utilities.getStateMasterData';
import getCityStateMaster from '@salesforce/apex/Utilities.getCityStateMaster2';
import getDistrictsByState from '@salesforce/apex/Utilities.getDistrictsByState';
//import getAddress from '@salesforce/apex/Ind_CustomerAdditionalDetailsCtrl.getAddress';
//import getInputsForIncomeDetails from '@salesforce/apex/Ind_IncomeDetailsCtrl.getInputsForIncomeDetails';
import saveApplicant from '@salesforce/apex/Ind_ApplicantService.savePrimaryOfficeAddress';
import getApplicantCurrentResidentialAddress from '@salesforce/apex/Ind_ApplicantService.getApplicantCurrentResidentialAddress';
import getSavedDetails from '@salesforce/apex/Ind_ApplicantService.getSavedDetails';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
export default class LWC_LOS_IncomeOfficeAddress extends LightningElement {
    @api recordId;
    @api applicantId;
    @api currentStage;
    @api tabValue;
    @api checkleadaccess;//coming from tabloanApplication

    @track isChecked = false;
    @track textDisable = false;
    @track textEmployeeDisable = false;
    @track checkboxDisable = false;

    @track allStateData;
    @track cityValue;
    @track districtValue;

    @track formdata = {};
    @track userdata;
    @track isLoading = false;
    @track employerName;
    @track lastStage;
    @track currentStageName;
    @track isOfficeCheck = false;
    @api fromHome;

    label = {
        KYC_Pin_Code_ErrorMessage,
        KYC_Address_ErrorMessage,
        Address_Pattern,
        RegEx_Alphabets_Only,
        firstNameError,
        Pin_code_Pattern,
        KycAddress1Pattern,
        KycAddress2Pattern,
        AddressValidation1,
        AddressValidation2,
        AddressValidation3,
        AddressnotValid
    }

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
            console.log('wiredStateMaster- error:: ', error);
        }
    }

    get allStateDataOptionsList() {
        return this.allStateData;
    }

    get districtValueOptionsList(){
        return this.districtValue;
    }

    get cityValueOptionsList(){
        return this.cityValue;
    }

    async connectedCallback() {
        console.log('applicantId and OppId => ', this.applicantId,'',this.recordId);
        console.log('response fromHome - ', this.fromHome);
        //Fetching the data from current residence document.
        await getApplicantCurrentResidentialAddress({ applicantId: this.applicantId }).then(response => {
            this.userdata = response;
            console.log('user data in connected callback => ', this.userdata);
        }).catch(error => {
            console.log('error in getApplicantCurrentResidentialAddress =>', error);
        });

        //Fetching the saved data.
        await getSavedDetails({ applicantId: this.applicantId , loanApplicationId: this.recordId})
        .then(result => {
            const response = JSON.parse(result);
            console.log('response of getSavedDetails =>', response , ' ', response.isOfficeCumCheckbox);
            
            this.employerName = response.employerName;
            this.isChecked = response.isOfficeCumCheckbox;
            if(response.addLineOne != null){
                this.checkboxDisable = true;
                this.formdata.street = response.addLineOne;
                this.formdata.addLine = response.addLineTwo;
                this.formdata.state = response.state.toUpperCase();//D2C 
                if(response.district){
                    let distObject = [];
                    distObject.push({ label: response.district, value: response.district });
                    this.districtValue = distObject;
                    this.formdata.district = response.district;
                }
                if(response.city){
                    let cityObject = [];
                    cityObject.push({ label: response.city, value: response.city });
                    this.cityValue = cityObject;
                    this.formdata.city = response.city;
                }
                this.formdata.pincode = response.pinCode;
                console.log('response ', response.isOfficeAddressSubmitted);
                if(response.isOfficeAddressSubmitted){
                    this.textDisable = true;
                }
                this.lastStage = result?.lastStage;
                this.currentStageName = result?.currentStageName;
            }
        })
        .catch(error =>{
            console.log('error in getSavedDetails =>',error);
        })
        this.callAccessLoanApplication();
    }

    //M4
    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordId , stage: 'Income Details'}).then(response => {
            console.log('accessLoanApplication Response:: ', response);
            if(!response){ 
                this.disableEverything();
                console.log('here 2');
                if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                    const evt = new ShowToastEvent({
                        title: ReadOnlyLeadAccess,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    console.log('from tab loan');
                    this.disableEverything();
                }
            }
            console.log('accessLoanApplication Response:: ', response);
            /*if(response==true)
            {
                if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                    const evt = new ShowToastEvent({
                        title: ReadOnlyLeadAccess,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    console.log('from tab loan');
                    this.disableEverything();
                }
            }*/
          }).catch(error => {
              console.log('Error in accessLoanApplication:: ', error);
          });
    }
//M4

    renderedCallback() {
        console.log('isChecked = ', this.isChecked);
        if (this.isChecked) {
            let formdataAddressTwoInput = this.template.querySelector('lightning-input[data-id=addressLineTwoId]');
            formdataAddressTwoInput.reportValidity();

            let formdataAddressInput = this.template.querySelector('lightning-input[data-id=addressLineOneId]');
            formdataAddressInput.reportValidity();

            let formdataAddressPinCodeInput = this.template.querySelector('lightning-input[data-id=addressPinCodeId]');
            formdataAddressPinCodeInput.reportValidity();

            let formdataAddressDistrict = this.template.querySelector('lightning-combobox[data-id=addressDistrictId]');
            formdataAddressDistrict.reportValidity();

            let formdateCityInput = this.template.querySelector('lightning-combobox[data-id=addressCityId]');
            formdateCityInput.reportValidity();

            let formdateStateInput = this.template.querySelector('lightning-combobox[data-id=kycStateDataId]');
            formdateStateInput.reportValidity();
        }

        if (this.currentStage === 'Credit Processing' || this.currentStageName === 'Loan Initiation' || this.currentStageName === 'Additional Details' || this.currentStageName === 'Vehicle Valuation' || this.currentStageName === 'Vehicle Insurance' || this.currentStageName === 'Loan Details' || (this.currentStageName === 'Income Details' && this.lastStage !== 'Income Details')) {
           
            this.disableEverything();
        }
    }

    addressLineOne(event) {
        this.formdata.street = event.target.value;
        let address1 = this.template.querySelector('lightning-input[data-id=addressLineOneId]');
        let addressL1 = address1.value;
        let address1Regex = /^(?=.{10,40}$)(^([A-Za-z0-9-_.,:;#\/']+[A-Za-z0-9-_.,:;#\/' ]*$)\2?(?!\2))+$/;

        if (addressL1.length < 10) {
            address1.setCustomValidity(AddressValidation3);
        } else if (addressL1.length > 40) {
            address1.setCustomValidity(AddressValidation2);
        } else if(!address1Regex.test(addressL1)){
            address1.setCustomValidity(AddressnotValid);
        } else {
            address1.setCustomValidity("");
        }
        address1.reportValidity();
    }

    addressLineTwo(event) {
        this.formdata.addLine = event.target.value;
        let address2 = this.template.querySelector('lightning-input[data-id=addressLineTwoId]');
        let addressL2 = address2.value;
        let address2Regex = /^(?=.{3,40}$)(^([A-Za-z0-9-_.,:;#\/']+[A-Za-z0-9-_.,:;#\/' ]*$)\2?(?!\2))+$/;

        if (addressL2.length < 3) {
            address2.setCustomValidity(AddressValidation1);
        } else if (addressL2.length > 40) {
            address2.setCustomValidity(AddressValidation2);
        } else if(!address2Regex.test(addressL2)){
            address2.setCustomValidity(AddressnotValid);
        } else {
            address2.setCustomValidity("");
        }
        address2.reportValidity();
    }

    handleCheckbox(event) {
        this.isChecked = event.target.checked;
        this.dispatchEvent(new CustomEvent('getcheckboxvalue', { detail: this.isChecked }));

        if (this.isChecked) {
            if (this.userdata != undefined) {
                this.textDisable = true;
                this.dispatchEvent(new CustomEvent('getdisablecheckboxvalue', { detail: this.checkboxDisable }));
                
                const userData = JSON.parse(JSON.stringify(this.userdata))
    
                this.formdata.street = userData.KYC_Address_Line_1__c;
                this.formdata.addLine = userData.KYC_Address_Line_2__c;
                this.formdata.pincode = userData.KYC_Pin_Code__c;
                
                this.formdata.state = userData.KYC_State__c.toUpperCase();

                if (userData.KYC_District__c) {
                    let distObject = [];
                    distObject.push({ label: userData.KYC_District__c.toUpperCase(), value: userData.KYC_District__c.toUpperCase() });
                    this.districtValue = distObject;
                    this.formdata.district = userData.KYC_District__c.toUpperCase();
                }
                else if(userData.KYC_City__c){
                    let distObject = [];
                    distObject.push({ label: userData.KYC_City__c.toUpperCase(), value: userData.KYC_City__c.toUpperCase() });
                    this.districtValue = distObject;
                    this.formdata.district = userData.KYC_City__c.toUpperCase();
                }

                if(userData.KYC_City__c){
                    let cityObject = [];
                    cityObject.push({ label: userData.KYC_City__c.toUpperCase(), value: userData.KYC_City__c.toUpperCase()});
                    this.cityValue = cityObject;
                    this.formdata.city = userData.KYC_City__c.toUpperCase();
                }
            } else {
                this.showToastMessage('', 'Data not present in Documents', 'error');
            }
        }
        else {
            this.textDisable = false;
            this.formdata = {};
        }
    }

    // businessName(event) {
    //     this.employerName = event.target.value;
    //     let formdataNameInput = this.template.querySelector('lightning-input[data-id=employeeNameId]');
    //     let formdataName = formdataNameInput.value;
    //     this.formdata.name = formdataName;
    //     formdataNameInput.reportValidity();
    // }

    addressState(event) {
        this.formdata.state = event.target.value;

        for (let index = 0; index < this.allStateData.length; index++) {
            if (this.allStateData[index].value == this.formdata.state) {
                this.minCurrentState = this.allStateData[index].stateMinValue;
                this.maxCurrentState = this.allStateData[index].stateMaxValue;
            }
        }

        let formdataAddressPinCodeInput = this.template.querySelector('lightning-input[data-id=addressPinCodeId]');

        if (this.formdata.state) {
            formdataAddressPinCodeInput.disabled = false;
            this.validatePincode();
        } else {
            formdataAddressPinCodeInput.disabled = true;
        }

        this.stateMaster(this.formdata.state, null);

        this.isLoading = true;

        getDistrictsByState({ stateName: this.formdata.state }).then(response => {
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
            this.isLoading = false;
        }).catch(error => {
            this.errorData = JSON.stringify(error);
            this.isError = true;
            this.isLoading = false;
        });
    }

    addressDistrict(event) {
        this.formdata.district = event.target.value;
    }

    addressCity(event) {
        this.formdata.city = event.target.value;
    }

    addressPinCode(event) {
        this.formdata.pincode = event.target.value;
        let formdataAddressPinCodeInput = this.template.querySelector('lightning-input[data-id=addressPinCodeId]');
        let formdataAddressPinCode = formdataAddressPinCodeInput.value;
        this.formdata.pincode = formdataAddressPinCode;
        formdataAddressPinCodeInput.reportValidity();
        this.validatePincode();
    }

    validatePincode() {
        if (this.formdata.pincode && this.formdata.pincode.length >= 2) {
            if (parseInt(this.formdata.pincode.substring(0, 2)) < this.minCurrentState || parseInt(this.formdata.pincode.substring(0, 2)) > this.maxCurrentState) {
                let formdataAddressPinCodeInput = this.template.querySelector('lightning-input[data-id=addressPinCodeId]');
                formdataAddressPinCodeInput.setCustomValidity("Invalid pin code");
                formdataAddressPinCodeInput.reportValidity();
            } else {
                let formdataAddressPinCodeInput = this.template.querySelector('lightning-input[data-id=addressPinCodeId]');
                formdataAddressPinCodeInput.setCustomValidity("");
            }
        }
    }

    stateMaster(State, city) {
        getCityStateMaster({ stateName: State }).then(response => {
            let cityData = [];

            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;

                    cityData.push(cityObject);
                    if (index == (response.length - 1) && city != null) {
                        this.formdata.city = city;
                    }
                }
            }

            this.cityValue = cityData;
            this.isLoading = false;
        }).catch(error => {
            console.log('getCityStateMaster - error:: ', error);
            this.isLoading = false;
        });
    }

    showToastMessage(title, message, variant) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
            }));
        }
    }

    @api checkForOfficeAddressValidy() {
        let formdataNameInput = this.template.querySelector('lightning-input[data-id=employeeNameId]');
        let formdataAddressInput = this.template.querySelector('lightning-input[data-id=addressLineOneId]');
        let formdataAddressTwoInput = this.template.querySelector('lightning-input[data-id=addressLineTwoId]');
        let formdataAddressPinCodeInput = this.template.querySelector('lightning-input[data-id=addressPinCodeId]');
        let formdataAddressDistrict = this.template.querySelector('lightning-combobox[data-id=addressDistrictId]');

        let formdateCityInput = this.template.querySelector('lightning-combobox[data-id=addressCityId]');
        let formdateStateInput = this.template.querySelector('lightning-combobox[data-id=kycStateDataId]');

        formdataNameInput.reportValidity();
        formdataAddressInput.reportValidity();
        formdataAddressTwoInput.reportValidity();
        formdataAddressPinCodeInput.reportValidity();
        formdataAddressDistrict.reportValidity();
        formdateCityInput.reportValidity();
        formdateStateInput.reportValidity();

        if (formdataNameInput.validity.valid === false || formdataAddressInput.validity.valid === false || formdataAddressTwoInput.validity.valid === false || formdataAddressPinCodeInput.validity.valid === false || formdataAddressDistrict.validity.valid === false || formdateCityInput.validity.valid === false || formdateStateInput.validity.valid === false) {
            this.showToastMessage('', Mandatory_fields_are_not_entered, 'error');
            return false;
        } else if (formdataNameInput.validity.valid === true || formdataAddressInput.validity.valid === true || formdataAddressTwoInput.validity.valid === true || formdataAddressPinCodeInput.validity.valid === true || formdataAddressDistrict.validity.valid === true || formdateStateInput.validity.valid === true) {
            this.updateSaveDeatails();
            return true;
        }
    }

    @api saveDetails(){
        this.fromHome = true;
        this.updateSaveDeatails();
    }
          
        updateSaveDeatails(){
        console.log('from home ',this.fromHome );
        if(!this.fromHome){
            this.isOfficeCheck = true;
        }
        let officeDetailData = {
            applicantId: this.applicantId,
            name: this.employerName,
            street: this.formdata.street,
            addLine: this.formdata.addLine,
            pincode: this.formdata.pincode,
            city: this.formdata.city,
            district: this.formdata.district,
            state: this.formdata.state,
            checkboxVal : this.isChecked,
            isOfficeAddressSubmitted : this.isOfficeCheck
        };

        saveApplicant({ addressDetailsString: JSON.stringify(officeDetailData) }).then(result => {
            this.showToastMessage('', All_Details_Stored_Sucessfully, 'success');
            this.textDisable = true;
            return true;
        }).catch(error => {
            console.log('saveApplicant - error:: ', error);
        });
    }
    
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
}