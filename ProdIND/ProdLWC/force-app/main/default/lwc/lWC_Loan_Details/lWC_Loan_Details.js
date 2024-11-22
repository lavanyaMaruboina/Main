import {
    LightningElement,
    api,
    track
} from 'lwc';
export default class LWC_Loan_Details extends LightningElement {
    showdetails = false;
    @track selectedValue;
    @track options;
    value = [];
    valuemotor = [];
    @track selectedOption;

    showexorpDetails = false;

    onrequiredTenuredChange(event) {
        this.selectedValue = parseInt(event.target.value);
    }
   
    get selectedValues() {
        return this.value.join(',');
    }

    get option() {
        return [{
                label: 'Yes',
                value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            },
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }

    handleChange(e) {
        this.value = e.detail.value;
    }
    onchangeorp(event) {
        //alert(event.target.checked);
        this.showexorpDetails = event.target.checked;
    }

    connectedCallback() {
        var TenuredLst = new Array();
        for (let i = 1; i <= 72; i++) {
            TenuredLst.push({
                label: parseInt(i),
                value: parseInt(i)
            });
        }
        this.options = TenuredLst;
    }
    handleClick() {
        this.showdetails = !this.showdetails;
    }

    handleCustomValidationRequriedLoanamountBorrower() {
        let RequiredLoanId = this.template.querySelector("[data-id='RequiredLoanId']");
        let RequiredLoanIdvalue = RequiredLoanId.value;
        if (RequiredLoanIdvalue == '' || RequiredLoanIdvalue == null)
            RequiredLoanId.setCustomValidity("Complete this field");
        else
            RequiredLoanId.setCustomValidity("");
        RequiredLoanId.reportValidity();
    }

    handleCustomValidationRequiredTenuredIdBorrower() {
        let RequiredTenuredId = this.template.querySelector("[data-id='RequiredTenuredId']");
        let RequiredTenuredvalue = RequiredTenuredId.value;
        if (RequiredTenuredvalue == '' || RequiredTenuredvalue == null)
            RequiredTenuredId.setCustomValidity("Complete this field");
        else
            RequiredTenuredId.setCustomValidity("");
        RequiredTenuredId.reportValidity();
    }

    handleCustomValidationBasicPriceIdBorrower() {
        let BasicPriceId = this.template.querySelector("[data-id='BasicPriceId']");
        let BasicPriceIdValue = BasicPriceId.value;
        if (BasicPriceIdValue == '' || BasicPriceIdValue == null)
            BasicPriceId.setCustomValidity("Complete this field");
        else
            BasicPriceId.setCustomValidity("");
        BasicPriceId.reportValidity();
    }

    handleCustomValidationRequiredROIIdBorrower() {
        let RequiredROIId = this.template.querySelector("[data-id='RequiredROIId']");
        let RequiredROIIdvalue = RequiredROIId.value;
        if (RequiredROIIdvalue == '' || RequiredROIIdvalue == null)
            RequiredROIId.setCustomValidity("Complete this field");
        else
            RequiredROIId.setCustomValidity("");
        RequiredROIId.reportValidity();
    }

    handleCustomValidation1styrpremIdBorrower() {
        let styrpremId = this.template.querySelector("[data-id='1styrpremId']");
        let styrpremIdvalue = styrpremId.value;
        if (styrpremIdvalue == '' || styrpremIdvalue == null)
            styrpremId.setCustomValidity("Complete this field");
        else
            styrpremId.setCustomValidity("");
        styrpremId.reportValidity();
    }

    handleCustomValidationMotorInsurancepremiumIdBorrower() {
        let MotorInsurancepremiumId = this.template.querySelector("[data-id='MotorInsurancepremiumId']");
        let MotorInsurancepremiumIdvalue = MotorInsurancepremiumId.value;
        if (MotorInsurancepremiumIdvalue == '' || MotorInsurancepremiumIdvalue == null)
            MotorInsurancepremiumId.setCustomValidity("Complete this field");
        else
            MotorInsurancepremiumId.setCustomValidity("");
        MotorInsurancepremiumId.reportValidity();
    }

    handleCustomValidationGSTamountIDBorrower() {
        let GSTamountID = this.template.querySelector("[data-id='GSTamountID']");
        let GSTamountIDvalue = GSTamountID.value;
        if (GSTamountIDvalue == '' || GSTamountIDvalue == null)
            GSTamountID.setCustomValidity("Complete this field");
        else
            GSTamountID.setCustomValidity("");
        GSTamountID.reportValidity();
    }

    handleCustomValidationDiscountonBasicpriceIDBorrower() {
        let DiscountonBasicpriceID = this.template.querySelector("[data-id='DiscountonBasicpriceID']");
        let DiscountonBasicpriceIDvalue = DiscountonBasicpriceID.value;
        if (DiscountonBasicpriceIDvalue == '' || DiscountonBasicpriceIDvalue == null)
            DiscountonBasicpriceID.setCustomValidity("Complete this field");
        else
            DiscountonBasicpriceID.setCustomValidity("");
        DiscountonBasicpriceID.reportValidity();
    }

    handleCustomValidationExshowroompriceIdBorrower() {
        let ExshowroompriceId = this.template.querySelector("[data-id='ExshowroompriceId']");
        let ExshowroompriceIdvalue = ExshowroompriceId.value;
        if (ExshowroompriceIdvalue == '' || ExshowroompriceIdvalue == null)
            ExshowroompriceId.setCustomValidity("Complete this field");
        else
            ExshowroompriceId.setCustomValidity("");
        ExshowroompriceId.reportValidity();
    }

    handleCustomValidationExshowroompriceCarwaleIdBorrower() {
        let ExshowroompriceCarwaleId = this.template.querySelector("[data-id='ExshowroompriceCarwaleId']");
        let ExshowroompriceCarwaleIdvalue = ExshowroompriceCarwaleId.value;
        if (ExshowroompriceCarwaleIdvalue == '' || ExshowroompriceCarwaleIdvalue == null)
            ExshowroompriceCarwaleId.setCustomValidity("Complete this field");
        else
            ExshowroompriceCarwaleId.setCustomValidity("");
        ExshowroompriceCarwaleId.reportValidity();
    }

    handleCustomValidationOnroadpriceIdBorrower() {
        let OnroadpriceId = this.template.querySelector("[data-id='OnroadpriceId']");
        let OnroadpriceIdvalue = OnroadpriceId.value;
        if (OnroadpriceIdvalue == '' || OnroadpriceIdvalue == null)
            OnroadpriceId.setCustomValidity("Complete this field");
        else
            OnroadpriceId.setCustomValidity("");
        OnroadpriceId.reportValidity();
    }

    handleCustomValidationOnroadpriceCarwaleIdBorrower() {
        let OnroadpriceCarwaleId = this.template.querySelector("[data-id='OnroadpriceCarwaleId']");
        let OnroadpriceCarwalevalue = OnroadpriceCarwaleId.value;
        if (OnroadpriceCarwalevalue == '' || OnroadpriceCarwalevalue == null)
            OnroadpriceCarwaleId.setCustomValidity("Complete this field");
        else
            OnroadpriceCarwaleId.setCustomValidity("");
        OnroadpriceCarwaleId.reportValidity();
    }

    
    
    
    handleCustomValidationfundingIDBorrower() {
        let fundingID = this.template.querySelector("[data-id='fundingID']");
        let fundingIDValue = fundingID.checked;
        if (fundingIDValue == false)
            fundingID.setCustomValidity("Complete this field");
        else
            fundingID.setCustomValidity("");
        fundingID.reportValidity();
    }

    handleCustomValidationCSDIdBorrower() {
        let csdID = this.template.querySelector("[data-id='csdID']");
        let csdIDvalue = csdID.value;
        if (parseInt(csdIDvalue.length) == 0)
            csdID.setCustomValidity("Complete this field");
        else{
            csdID.setCustomValidity("");
        }
        csdID.reportValidity();
    }

    

    handlesaveBorrower() {
        //REQURIED FIELD VALIDATION LOGIC (START...)
        this.handleCustomValidationRequriedLoanamountBorrower();
        this.handleCustomValidationRequiredTenuredIdBorrower();
        this.handleCustomValidationBasicPriceIdBorrower();
        this.handleCustomValidationfundingIDBorrower();
        this.handleCustomValidationRequiredROIIdBorrower();
        this.handleCustomValidation1styrpremIdBorrower();
        this.handleCustomValidationMotorInsurancepremiumIdBorrower();
        this.handleCustomValidationGSTamountIDBorrower();
        this.handleCustomValidationDiscountonBasicpriceIDBorrower();
        this.handleCustomValidationExshowroompriceIdBorrower();
        this.handleCustomValidationExshowroompriceCarwaleIdBorrower();
        this.handleCustomValidationOnroadpriceIdBorrower();
        this.handleCustomValidationOnroadpriceCarwaleIdBorrower();
        this.handleCustomValidationCSDIdBorrower();
        // END OF REQURIED FILED VALIDATION LOGIC...
    }
    handlesavecoBorrower(){
        //REQURIED FIELD VALIDATION LOGIC (START...)
       /* this.handleCustomValidationRequriedLoanamountBorrower();
        this.handleCustomValidationRequiredTenuredIdBorrower();
        this.handleCustomValidationBasicPriceIdBorrower();
        this.handleCustomValidationfundingIDBorrower();
        this.handleCustomValidationRequiredROIIdBorrower();
        this.handleCustomValidation1styrpremIdBorrower();
        this.handleCustomValidationMotorInsurancepremiumIdBorrower();
        this.handleCustomValidationGSTamountIDBorrower();
        this.handleCustomValidationDiscountonBasicpriceIDBorrower();
        this.handleCustomValidationExshowroompriceIdBorrower();
        this.handleCustomValidationExshowroompriceCarwaleIdBorrower();
        this.handleCustomValidationOnroadpriceIdBorrower();
        this.handleCustomValidationOnroadpriceCarwaleIdBorrower();
        this.handleCustomValidationCSDIdBorrower();*/
    }

}