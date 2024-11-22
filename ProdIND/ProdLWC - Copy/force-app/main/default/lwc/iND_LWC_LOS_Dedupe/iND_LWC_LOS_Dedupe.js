import { LightningElement,track } from 'lwc';
import vehicleDedupe from '@salesforce/apex/LwcLOSLoanApplicationCntrl.vehicleDedupe'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ExternalId from '@salesforce/schema/Product2.ExternalId';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import Incomemessage from '@salesforce/label/c.Incomemessage';
import Income5000 from '@salesforce/label/c.Income5000';
import Income5000000 from '@salesforce/label/c.Income5000000';
import Amountmessage from '@salesforce/label/c.Amountmessage';
import Loanamount10000 from '@salesforce/label/c.Loanamount10000';
import Loanamount175000 from '@salesforce/label/c.Loanamount175000';



export default class IND_LWC_LOS_Dedupe extends LightningElement {

    //Flag to make the input fields disabled.
    isCustomerCodeDisabled = false;
    isParentDealNumberDisabled = false;
    isVehicleRegisterationNumberDisabled = false;
    isNOCNumberDisabled = false;
    isVerifyVehicleSubCategoryButtonDisabled = true;

    //Flag to make the vehicle dedupe input fields template and subCategory combobox visible.
    vehicleDedupeTemplate = false;
    subCategoryComboboxTemplate = false;


    //Attribute for holding the values of requuired input fields entered by users.
    customerCodeValue = 'ABC123ABC'; 
    parentDealNumberValue = '';
    vehicleRegisterationNumberValue = '';
    nocNumberValue = '';

    //Attribute to hold the value of Vehicle Type from Picklist.
    vehicleType = '';

    //Attribute to hold the value of Vehicle Sub Category Type from Picklist.
    vehicleSubCategoryType = '';

    //List for holding the value of dependent picklist.
    @track vehicleSubCategory=[{ label: '--None--', value: 'none' }];
    
    //Options for Vehicle Type Dropdown
    get vehicleTypeOptions() {
        return [
            { label: 'New', value: 'new' },
            { label: 'Used', value: 'used' },
            { label: 'External Refinance', value: 'externalRefinance' },
            { label: 'Internal Refinance', value: 'internalRefinance' },
        ];
    }

    //Options for Vehicle SubCategory Dropdown.
    get vehicleSubCategoryOptions() {
        return this.vehicleSubCategory;
    }


    //Vehicle Type Value Change Handler
    handleVehicleTypeChange(event) {
        this.vehicleType = event.detail.value;
        if(this.vehicleType == 'new'){
            this.subCategoryComboboxTemplate = false;
            this.vehicleDedupeTemplate = false;
        }
        else if(this.vehicleType == 'used'){
            this.subCategoryComboboxTemplate = true;
            this.vehicleSubCategory = [ { label: 'UOM - Customer buying a loan free car from seller/dealer/DSA', value: 'UOM' },
            { label: 'UOB - Customer buying a used car with an existing loan from seller/dealer/DSA', value: 'UOB' },
            { label: 'UPD - Customer buying used car from OEM based dealers like True Value', value: 'UPD' },
            { label: 'URS - Customer buying a repo car from CFD', value: 'URS' },
            { label: 'URV - Customer buying a CFD financed car from seller', value: 'URV' },
            { label: 'UEB - Customer buying a CFD financed car from seller through a broker', value: 'UEB' },];
        }
        else if(this.vehicleType == 'externalRefinance'){
            this.subCategoryComboboxTemplate = true;

            this.vehicleSubCategory = [{ label: 'UPB - Customer wants to transfer their existing car loan to CFD and take addiotnal loan amount if required', value: 'UPB' },
            { label: 'UPO - Customer needs a loan on their own loan free car', value: 'UPO' },]
        }
        else if(this.vehicleType == 'internalRefinance'){
            this.subCategoryComboboxTemplate = true;

            this.vehicleSubCategory = [ { label: 'UIM - CFD customer requesting top up on their own CFD financed car', value: 'UIM' },
            { label: 'RLY - CFD customer requesting refinance on their own CFD financed car', value: 'RLY' },
            { label: 'RLN - CFD customer needs refinance on their loan completed CFD financed car', value: 'RLN' }]
        }
        else {
            return this.vehicleSubCategory;
        }
    }


    //Vehicle SubCategroy Value Change Handler.
    handleVehicleSubCategoryChange(event) {
        this.vehicleDedupeTemplate = true;
        this.vehicleSubCategoryType = event.detail.value;
        //this.vehicleRegisterationNumberValue = 'TN09C3K1234';

        if(this.vehicleSubCategoryType == 'UOM'){
            this.isCustomerCodeDisabled = false;          
            this.isParentDealNumberDisabled = true;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

            this.vehicleRegisterationNumberValue = 'TN09C3K0001';
            console.log(this.vehicleRegisterationNumberValue);
            
        }
        else if(this.vehicleSubCategoryType == 'UOB'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

            this.vehicleRegisterationNumberValue = 'TN09C3K0002';
            console.log(this.vehicleRegisterationNumberValue);
            
        }
        else if(this.vehicleSubCategoryType == 'UPD'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

            this.vehicleRegisterationNumberValue = 'TN09C3K0003';
            console.log(this.vehicleRegisterationNumberValue);

        }
        else if(this.vehicleSubCategoryType == 'URS'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

            this.vehicleRegisterationNumberValue = 'TN09C3K1234';
            console.log(this.vehicleRegisterationNumberValue);

        }
        else if(this.vehicleSubCategoryType == 'URV'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

            this.vehicleRegisterationNumberValue = 'TN09C3K1234';
            console.log(this.vehicleRegisterationNumberValue);

        }
        else if(this.vehicleSubCategoryType == 'UEB'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = false;

            this.vehicleRegisterationNumberValue = 'TN09C3K0009';
            console.log(this.vehicleRegisterationNumberValue);

        }
        else if(this.vehicleSubCategoryType == 'UPB'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = false;

            this.vehicleRegisterationNumberValue = 'TN09C3K1234';
            console.log(this.vehicleRegisterationNumberValue);

        }
        else if(this.vehicleSubCategoryType == 'UPO'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = true;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

            this.vehicleRegisterationNumberValue = 'TN09C3K1234';
            console.log(this.vehicleRegisterationNumberValue);

        }
        
        else if(this.vehicleSubCategoryType == 'UIM'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

    
            this.vehicleRegisterationNumberValue = 'TN09C3K1234';
            console.log(this.vehicleRegisterationNumberValue);


        }
        else if(this.vehicleSubCategoryType == 'RLY'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = true;

            this.vehicleRegisterationNumberValue = 'TN09C3K1234';
            console.log(this.vehicleRegisterationNumberValue);

        }
        else if(this.vehicleSubCategoryType == 'RLN'){
            this.isCustomerCodeDisabled = false;
            this.isParentDealNumberDisabled = false;
            this.isVehicleRegisterationNumberDisabled = false;
            this.isNOCNumberDisabled = false;

            this.vehicleRegisterationNumberValue = 'TN09C3K1234';
            console.log(this.vehicleRegisterationNumberValue);

        }   

        //Resetting the field values of dependent pickilist value changes.
        this.template.querySelectorAll('[data-id="dedupeInput"]')
        .forEach((input) => {
            input.value = '';
           
        })
    }

    //On Blur Handler for Input field.Also getting the values of input fields to pass them in vehicleDedupe method.
    handleDedupeInputField(event){
        //this.isVerifyVehicleSubCategoryButtonDisabled = true;
        const label = event.target.label;
        if(label == 'Customer Code'){
            this.customerCodeValue = event.target.value;
        }
        else if(label == 'Parent Deal Number'){
            this.parentDealNumberValue = event.target.value;
        }
        else if(label == 'Vehicle Registration Number'){
            this.vehicleRegisterationNumberValue = event.target.value;
        }
        else if(label == 'NOC Number'){
            this.nocNumberValue = event.target.value;
        }
    }
    


    // Attribute for holding the value of spinner tag.
    isSpinnerMoving = false;
    //Attribute for condition : when to execute the apex method and when not to.
    callVehicleDedupe = true;
    //List to store the required field.
    @track dedupeInputFieldValues = [];

    //Start of Verify Vehicle Sub-Category Button Click Handler
    handleVehicleSubCategory(event){
        // Making this true as and when the button will be clicked.
        this.callVehicleDedupe = true;
        
        //Checking validation for required value.If validation fails showing toast event sand making callDedupeVehicle false, so that server call doesn't happen.
        this.template.querySelectorAll('[data-id="dedupeInput"]').forEach((input) => {
            if(this.vehicleSubCategoryType == 'UEB' || this.vehicleSubCategoryType == 'UPB'){
                if(input.label != 'NOC Number' && input.disabled == false && input.value.length == 0){
                    const evt = new ShowToastEvent({
                        title: 'Missing Required Value(s)',
                        message: 'Please Enter Required Field Values '+input.label,
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    //Stopping server call by make it false.
                    this.callVehicleDedupe = false;
                }
            }
            else{
                if(input.disabled == false && input.value.length == 0){
                    const evt = new ShowToastEvent({
                        title: 'Missing Required Value(s)',
                        message: 'Please Enter Required Field Values '+input.label,
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    //Stopping server call by make it false.
                    this.callVehicleDedupe = false;
                }
            }
        })
        
        
        //Call the apex method iff all the required fields have some value.
        if(this.callVehicleDedupe == true){
            // To show the spinner.
            this.isSpinnerMoving = true;
            //Calling the apex method of LwcLOSLoanApplicationCntrl
            vehicleDedupe({customerCode: this.customerCodeValue, parentDealNumber : this.parentDealNumberValue , vehicleRegisterationNumber : this.vehicleRegisterationNumberValue, nocNumber : this.nocNumberValue})
            .then(result =>{
                let response = JSON.parse(result);
                if(response.Status  == true){
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Vehicle Dedupe is successfull.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    //Disbaling the input fields if the dedupe is successfull.
                    this.isCustomerCodeDisabled = true;
                    this.isParentDealNumberDisabled = true;
                    this.isVehicleRegisterationNumberDisabled = true;
                    this.isNOCNumberDisabled = true;
                }
                else{
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Vehicle Dedupe is unsuccessfull.Please enter your details again.',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                }
                //To stop the
                this.isSpinnerMoving = false;
            })
            .error(error =>{
                this.error = error;
                this.isSpinnerMoving = false;
            });
        }
    }  
    // End of handleVehicleSubCategory handler.

    //Added By Naga Puppala start
    incomeSrcValue = '';
    declaredIncome = '';   //Added By Naga Puppala 
    loanAmount = '';   //Added By Naga Puppala 
    showIncomeError = false;
    get incomeSourceOptions(){
        return [
            {label: 'Earning', value: 'Earning'},
            {label: 'Non-Earning', value: 'Non-Earning'}
        ]

    }

    validateIncomeField(event){
        if(event.keyCode === 69 || event.keyCode === 77 ||  event.keyCode == 75 || event.keyCode == 66 || event.keyCode == 84 || event.keyCode == 190){
            event.preventDefault();
        }
        let value = event.target.value;
        if (value && (!/^[0-9]+$/.test(value) || event.keyCode == 0)) {
            this.declaredIncome = value.replace(/\D/g, '');
        }
    }

    validateInput(event){
        let name = event.target.name;
        let value = event.target.value;
        console.log(name + ' ' + value);
        let elem = this.template.querySelector(".incomeDec");
        elem.setCustomValidity("");
        //if(value && (value < 5000 || value > 5000000)){
        if(value && (value < parseInt(Income5000) || value > parseInt(Income5000000))){
            elem.setCustomValidity(Incomemessage);
        }
        elem.reportValidity();
       
    }

    validateLoanAmountField(event){
        if(event.keyCode === 69 || event.keyCode === 77 ||  event.keyCode == 75 || event.keyCode == 66 || event.keyCode == 84){
            event.preventDefault();
        }
        
    }

    validateLoanAmt(event){
        let name = event.target.name;
        let value = event.target.value;
        console.log(name + ' ' + value);
        let elem = this.template.querySelector(".loanAmt");
        elem.setCustomValidity("");
        if(value && (value < parseInt(Loanamount10000) || value > parseInt(Loanamount175000))){
            elem.setCustomValidity(Amountmessage);
        }
        elem.reportValidity();
       
    }
    //Added By Naga Puppala end
    
}