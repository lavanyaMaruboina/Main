/*
* User Story : SFTRAC-152
* Developer Name : Rajat Jaiswal
* Description : Component used for EMI calculator based on Structure and Equated Installment Type.
* LWC : LWC_EMI_CalculatorTractor
*/
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import gradedRepaymentSchedule from '@salesforce/apex/EMI_CalculatorController.gradedRepaymentSchedule';
import emiRepaymentSchedule from '@salesforce/apex/IND_OfferScreenController.emiRepaymentSchedule'; 
import calculateGrossNetIRR from '@salesforce/apex/EMI_CalculatorController.calculateGrossNetIRR';
import calculateCRMIRR from '@salesforce/apex/EMI_CalculatorController.calculateCRMIRR';    //SFTRAC-2064
export default class LWC_EMI_CalculatorTractor extends LightningElement {

    @track getVariantValue;
    @track inputFieldsValues = {};
    keyIndex = 0;
    @track itemList=[]; 
    moratoriumInDaysValue;
    totalPrinciple = 0;
    divider = 1200;
    numberOfInstallmentsValue =0;
    cashFlows = [];
    @track totalPaybleEMI = [];
    tenureValue;
    netIRR;
    crmIRR;
    grossIRR;
    frequencyValue;
    showEquated = false;
    showAmort = false;
    showStructured = false;
    isParameterChange = false;
    balanceAmount = 0;
    totalSumAmount = 0;
    isInstallmentGreater = false;
    currentIndex;
    interest;
    advanceEMI;
    disabledMID = false;
    product;
    advanceEMIValue;
    irrCashFlows = [];
    payin;
    payout;
    firstEMIDate;
    secondEMI = '';
    isSpinnerMoving = false;
    openingPrincipal = 0;
    interestPart;
    disableAdd = false;
    disableCompute = false;

    handlerAddRow(){
        if(this.itemList?.length > 0 && (!this.itemList[this.itemList.length - 1].fromMonth || !this.itemList[this.itemList.length - 1].toMonth || !this.itemList[this.itemList.length - 1].emiPayable)){
            this.dispatchEvent(ShowToastEvent({
                title: "warning",
                message: 'Please enter values in current row first!!!',
                variant: 'warning',
            }));
            return;
        }else if(this.itemList?.length > 0 && this.totalSumAmount && this.totalPrinciple && Number(this.totalSumAmount) >= Number(this.totalPrinciple)){
            this.dispatchEvent(ShowToastEvent({
                title: "warning",
                message: 'Total Entered Amount exceeds Agreement Amount. So you can\'t create new Row',
                variant: 'warning',
            }));
            return;
        }else if(this.inputFieldsValues.installmentType == 'STRUCTURED' && this.itemList && this.isInstallmentGreater){
            this.dispatchEvent(ShowToastEvent({
                title: "warning",
                message: 'Total entered Installments exceeds No of Installments. So you can\'t create new Row',
                variant: 'warning',
            }));
            return;
        }
        else if(this.itemList?.length == 1 && this.inputFieldsValues.installmentType == 'STRUCTURED' && Number(this.interest) > Number(this.itemList[0].emiPayable)){ //SFTRAC-527
            this.dispatchEvent(ShowToastEvent({
                title: "warning",
                message: 'Installment is less than the Interest amount. So you can\'t create new Row',
                variant: 'warning',
            }));
            return;
        }else{
            let objTable={
                Id: ++this.keyIndex,
                fromMonth: '',
                toMonth:'',
                emiPayable:'',
                totalAmount:'',
                readOnly : false
            }
            if(this.itemList.length > 0){
                this.itemList[this.itemList.length - 1].readOnly = true;
            }
            this.itemList.push(objTable);
        }
        
        
    }
    handlerRemoveRow(){
        if (this.itemList.length >= 2) {
            --this.keyIndex;
            this.itemList = this.itemList.filter(fil => fil.Id!=this.itemList.length);
        }
    }
    handleReset(){
        this.itemList = [];
        let objTable= [
            {
                Id: ++this.keyIndex,
                fromMonth: '',
                toMonth:'',
                emiPayable:'',
                totalAmount:'',
                readOnly : false
    
            }
        ];
        this.itemList.push(objTable);   

        this.openingPrincipal = this.inputFieldsValues.financeAmount || 0;
    }
    changeHandlerOnFromMonth(event){
        this.currentIndex = event.target.dataset.targetId;
        var index = event.target.dataset.targetId;
      let fromMonthValue = this.template.querySelectorAll("[data-id='validateFromCmp']");
      let toMonthValue = this.template.querySelectorAll("[data-id='validateToCmp']");
      let emiValue = this.template.querySelectorAll("[data-id='validateEMIId']");
      if(this.currentIndex != 0){
        let previousIndex = --this.currentIndex;
        if(Number(event.target.value) <= Number(this.itemList[previousIndex].toMonth))
        {
            this.disableAdd = true;
            toMonthValue[index].disabled = true;
            emiValue[index].disabled = true;
            fromMonthValue[index].setCustomValidity('From Installment should be greater than the previous To Installment');
        } else {
            this.disableAdd = false;
            toMonthValue[index].disabled = false;
            emiValue[index].disabled = false;
            fromMonthValue[index].setCustomValidity('');
        }
        fromMonthValue[index].reportValidity();
        this.itemList[event.target.dataset.targetId].fromMonth = event.target.value;
      }
      else{
      this.itemList[event.target.dataset.targetId].fromMonth = event.target.value;
      } 
      this.isParameterChange = true;
      this.calculateTotalSumAmount();
    }
    changeHandlerOnToMonth(event){
      this.currentIndex = event.target.dataset.targetId;
      this.itemList[event.target.dataset.targetId].toMonth = event.target.value;
      let emiValue = this.template.querySelectorAll("[data-id='validateEMIId']");
      var index = event.target.dataset.targetId;
      let toMonthValue = this.template.querySelectorAll("[data-id='validateToCmp']");
        if(Number(this.numberOfInstallmentsValue) < Number(this.itemList[index].toMonth)){
            this.disableAdd = true;
            this.disableCompute = true;
            emiValue[index].disabled = true;
            toMonthValue[index].setCustomValidity('To Installment cannot be greater than No of Installment');
        }else{
            this.disableAdd = false;
            this.disableCompute = false;
            emiValue[index].disabled = false;
            toMonthValue[index].setCustomValidity('');
        }
        toMonthValue[index].reportValidity();
      this.isParameterChange = true;
      this.calculateTotalSumAmount();

    }
    changeHandlerOnEmiPayable(event){
        var index = event.target.dataset.targetId;
        let emiValue = this.template.querySelectorAll("[data-id='validateEMIId']");
        var emiPayable = event.target.value; 

        if(index==0){ //SFTRAC-527
            this.interest = ((Number(this.totalPrinciple) - Number(this.inputFieldsValues.financeAmount))/Number(this.inputFieldsValues.tenure));
           // var emiPayable = event.target.value; 
            if(this.interest > emiPayable){
                this.dispatchEvent(ShowToastEvent({
                    title: "warning",
                    message: 'Installment cannot be less than the interest amount',
                    variant: 'warning',
                }));
            }
        }
        this.calculateInterest(this.openingPrincipal,this.requiredCRMIRR,emiPayable,this.frequencyValue,this.numberOfInstallmentsValue);
            if(emiValue[index].value < this.interestPart){
                this.disableAdd = true;
                emiValue[index].setCustomValidity('EMI Amount cannot be less than the interest amount');
            } else {
                this.disableAdd = false;
                emiValue[index].setCustomValidity('');
            }
            emiValue[index].reportValidity();
        this.calculateAmort(this.openingPrincipal,this.requiredCRMIRR,emiPayable,this.frequencyValue,this.numberOfInstallmentsValue);
        this.itemList[event.target.dataset.targetId].emiPayable = event.target.value;   
        this.isParameterChange = true;
        this.calculateTotalSumAmount();
    }
calculateInterest(openingPrincipal,crmIRR,emi,frequency,installments){
    var interest = (crmIRR/36500)*frequency*openingPrincipal*31;
    this.interestPart = interest * 1.05;
}
calculateAmort(openingPrincipal,crmIRR,emi,frequency,installments){
    for(let i = 0; i < installments; i++){
        var ist = (crmIRR/36500)*frequency*openingPrincipal*31;
        var principal = Number(emi) - Number(ist);
        var cp = Number(openingPrincipal) - Number(principal);
        openingPrincipal = cp;

    }
    this.openingPrincipal = openingPrincipal;
    }
    calculateTotalSumAmount(){
        let totalValue = 0;
        let emiTotalvalue = 0;
        for(let i=Number(this.itemList[Number(this.currentIndex)].fromMonth); i<=Number(this.itemList[Number(this.currentIndex)].toMonth); i++){
            emiTotalvalue += Number(this.itemList[Number(this.currentIndex)].emiPayable);
        }
        this.itemList[Number(this.currentIndex)].totalAmount = emiTotalvalue;
        for(let i=0; i<this.itemList.length; i++){
            totalValue += Number(this.itemList[i].totalAmount);
            if(this.numberOfInstallmentsValue && (Number(this.numberOfInstallmentsValue) <= Number(this.itemList[i].toMonth))){
                console.log('entergre 1----');
                this.isInstallmentGreater = true;
            }else{
                this.isInstallmentGreater = false;
            }
        }
        this.totalSumAmount = totalValue;
        this.balanceAmount =  Number(this.totalPrinciple) - Number(this.totalSumAmount);
        this.calculateMonthlyEMI();
    }
    changeHandlerOnTotalAmount(event){
        this.totalAmount = event.target.value;
    }

    handleInputChange(event){
        try {
            let inputFieldName = event.target.name;
            let inputFieldValue = event.target.value;
            this.isParameterChange = true;
            this.itemList=[];
            this.balanceAmount = 0;
            this.totalSumAmount = 0;
            this.totalPrinciple =0;
            if(inputFieldName == 'product'){
                this.product = event.target.value;
            }
            if(inputFieldName == 'variantInstallmentType'){
                this.getVariantValue = event.target.value;
                if(this.getVariantValue == 'Monthly'){
                    this.inputFieldsValues.moratoriumInDays = this.moratoriumInDaysValue = '30';
                    this.frequencyValue = '1';
                }else if(this.getVariantValue == 'Bi-Monthly'){
                    this.inputFieldsValues.moratoriumInDays = this.moratoriumInDaysValue = '60';
                    this.frequencyValue = '2';
                }else if(this.getVariantValue == 'Quartely'){
                    this.inputFieldsValues.moratoriumInDays = this.moratoriumInDaysValue = '90';
                    this.frequencyValue = '3';
                }else if(this.getVariantValue == 'Half-Yearly'){
                    this.inputFieldsValues.moratoriumInDays = this.moratoriumInDaysValue = '180';
                    this.frequencyValue = '6';
                }
            }
            this.inputFieldsValues[inputFieldName] = inputFieldValue;
            if(inputFieldName == 'moratoriumInDays'){
                this.moratoriumInDaysValue = event.target.value;
            }
            if(inputFieldName == 'advanceEMINumbers'){
                this.advanceEMI = event.target.value;
                if(this.advanceEMI != '1' && this.advanceEMI != '0' && this.advanceEMI != ''){
                    this.dispatchEvent(ShowToastEvent({
                        title: "Error",
                        message: 'Invalid Number, Advance EMI could either be 0 or 1',
                        variant: 'Error',
                    }));
                    this.advanceEMI = '';
                    return;
                }
                if(this.advanceEMI == '1' && this.getVariantValue != 'Monthly' && this.product == 'T'){
                    this.dispatchEvent(ShowToastEvent({
                        title: "Error",
                        message: 'Only Monthly Frequency can have Advance EMIs for Tractor Loan Applications',
                        variant: 'Error',
                    }));
                    return;
                }

                if(this.advanceEMI == '1' ){
                    this.inputFieldsValues.moratoriumInDays = this.moratoriumInDaysValue = '0';
                    this.disabledMID = true;
                    this.advanceEMIValue = true;
                } else {
                    this.disabledMID = false;
                    this.advanceEMIValue = false;
                }
                
            }
            this.calculateNoOfInstallments();
            if(event.target.name =='installmentType'){
                if(this.inputFieldsValues.installmentType == 'STRUCTURED'){
                    this.showEquated = false;
                    this.showStructured = true;
                    this.itemList=[];
                }else if (this.inputFieldsValues.installmentType==='EQUATED') {
                    this.showEquated = false;
                    this.showStructured = false;
                    this.itemList=[];
                }
            }
            if(event.target.name =='totalPayInsIncludingGST'){
                this.payin = event.target.value;
            }
            if(event.target.name =='totalPayOuts'){
                this.payout = event.target.value;
            }
            let tempPriciple = this.inputFieldsValues.financeAmount || 0;
            this.openingPrincipal = this.inputFieldsValues.financeAmount || 0;
            let tempInterest = this.inputFieldsValues.ROI || 0;
            this.requiredCRMIRR = this.inputFieldsValues.ROI || 0;
            let tempTime = this.tenureValue = this.inputFieldsValues.tenure || 0;
           // this.totalPrinciple = Number(tempPriciple) + Number(tempPriciple)*Number(tempInterest)*Number(tempTime)/this.divider;
            if(!this.inputFieldsValues.financeAmount || !this.inputFieldsValues.ROI || !this.inputFieldsValues.tenure){
               this.totalPrinciple = 0;
            }
           // this.calculateMonthlyEMI();
            this.calculateRepaymentDate();
        } catch (error) {
            console.error(error);
        }
    }
    calculateRepaymentDate(){
        
    }
    calculateMonthlyEMI(){
        this.cashFlows =[];
        if(this.totalPrinciple && this.numberOfInstallmentsValue){
            this.totalMonthlyPayment = this.totalPrinciple/this.numberOfInstallmentsValue;
        }
        if(this.totalMonthlyPayment){
            this.totalMonthlyPayment = Number(this.totalMonthlyPayment).toFixed();
        }
        if(this.inputFieldsValues.installmentType != 'STRUCTURED'){
            if(this.totalMonthlyPayment && this.inputFieldsValues.tenure){
                let arr = new Array(Number(this.numberOfInstallmentsValue)).fill(Number(this.totalMonthlyPayment).toFixed());
                this.cashFlows = [...arr];
            }
        }
    }
    calculateNoOfInstallments(){
        if(this.inputFieldsValues.variantInstallmentType && this.inputFieldsValues.tenure){
            let tempInstallmentValue =0;
            if(this.inputFieldsValues.variantInstallmentType == 'Monthly'){
                tempInstallmentValue = (this.inputFieldsValues.tenure*12)/12;
            }else if(this.inputFieldsValues.variantInstallmentType == 'Bi-Monthly'){
                tempInstallmentValue = (this.inputFieldsValues.tenure*6)/12;
            }else if(this.inputFieldsValues.variantInstallmentType == 'Quartely'){
                tempInstallmentValue = (this.inputFieldsValues.tenure*4)/12;
            }else if(this.inputFieldsValues.variantInstallmentType == 'Half-Yearly'){
                tempInstallmentValue = (this.inputFieldsValues.tenure*2)/12;
            }
            if(this.inputFieldsValues.variantInstallmentType == 'Monthly' && this.inputFieldsValues.moratoriumInDays && (Number(this.inputFieldsValues.moratoriumInDays)==30)){
                this.numberOfInstallmentsValue = tempInstallmentValue-1;
            }else{
                this.numberOfInstallmentsValue = tempInstallmentValue;
            }
            if(Number(this.inputFieldsValues.tenure)==0){
                this.numberOfInstallmentsValue = 0;
            }
        }
    }
    calculateCashFlow(){
        if(this.inputFieldsValues.installmentType == 'STRUCTURED'){
            this.cashFlows = [];
            const tempList = JSON.parse(JSON.stringify(this.itemList));
            for (let i = 0; i < tempList.length; i++) {
                for (let index = Number(tempList[i].fromMonth); index <= Number(tempList[i].toMonth); index++) {                    
                    this.cashFlows.push(Number(tempList[i].emiPayable));
                }
            }
        }
    }
    async handlerComputeIRR(){
        try {
            this.calculateCashFlow();
            if(!this.validityCheck('.emiFields')){
                this.dispatchEvent(ShowToastEvent({
                    title: "Requried",
                    message: 'Fill all the details',
                    variant: 'Error',
                }));
                return;
            }
            else if(!this.isParameterChange){
                this.dispatchEvent(ShowToastEvent({
                    title: "Requried",
                    message: 'Parameters not changed!!!',
                    variant: 'Error',
                }));
                return;
            }
           /* else if(this.inputFieldsValues.moratoriumInDays == '0'  ){
                this.dispatchEvent(ShowToastEvent({
                    title: "warning",
                    message: 'Choose any other Moratorium. Currently, we are not providing loans on 0 morataium Days!!!',
                    variant: 'warning',
                }));
                return;
            } */
            else if(this.inputFieldsValues.installmentType == 'STRUCTURED' && (!this.itemList || this.itemList?.length == 0 || (this.itemList && this.totalSumAmount && this.totalPrinciple && Number(this.totalSumAmount) < Number(this.totalPrinciple)))){
                this.dispatchEvent(ShowToastEvent({
                    title: "warning",
                    message: 'Add Structured Installments data!!!',
                    variant: 'warning',
                }));
                return;
            }
            else if(this.inputFieldsValues.installmentType == 'STRUCTURED' && (this.itemList && this.totalSumAmount && this.totalPrinciple && Number(this.totalSumAmount) > Number(this.totalPrinciple))){
                this.dispatchEvent(ShowToastEvent({
                    title: "warning",
                    message: 'Total Entered Amount exceeds Agreement Amount. So you can\'t Compute IRR!!!',
                    variant: 'warning',
                }));
                return;
            }
          /*  else if(this.inputFieldsValues.installmentType == 'STRUCTURED' && this.itemList && this.isInstallmentGreater){
                this.dispatchEvent(ShowToastEvent({
                    title: "warning",
                    message: 'Total entered Installments exceeds No of Installments. So you can\'t Compute IRR!!!',
                    variant: 'warning',
                }));
                return;
            } */
            else if(this.isParameterChange){
                this.totalPaybleEMI = [];
                this.showEquated = false;
               let financeAmount = this.inputFieldsValues.financeAmount || 0;
               const currentDate = new Date();
               let repaymentDate = new Date();
               const loanDealDate = new Date().toISOString().split('T')[0];
               const X1stDate = new Date(loanDealDate);
               if(this.advanceEMIValue == false){
               const monthsToAdd = this.moratoriumInDaysValue ? parseInt(this.moratoriumInDaysValue)/30 : 0;
               this.firstEMIDate = new Date(X1stDate.setMonth(X1stDate.getMonth() + monthsToAdd));
               const targetFirstDate =  this.firstEMIDate.getDate() <= 15 ? 7 : 15;
               this.firstEMIDate = new Date(this.firstEMIDate.setDate(targetFirstDate));
               }else{
               this.firstEMIDate = loanDealDate;
               }
               if (this.getVariantValue == 'Monthly') {
               this.secondEMI = new Date(X1stDate.setMonth(X1stDate.getMonth() + 1));
               const targetSecondDate =  this.secondEMI.getDate() <= 15 ? 7 : 15;
               this.secondEMI = new Date(this.secondEMI.setDate(targetSecondDate));
               } else if (this.getVariantValue == 'Bi-Monthly') {
               this.secondEMI = new Date(X1stDate.setMonth(X1stDate.getMonth() + 2));
               console.log('secondEMI---+'+this.secondEMI);
               const targetSecondDate =  this.secondEMI.getDate() <= 15 ? 7 : 15;
               this.secondEMI = new Date(this.secondEMI.setDate(targetSecondDate));
               console.log('secondEMI2---+'+this.secondEMI);
               } else if (this.getVariantValue == 'Quartely') {
               this.secondEMI = new Date(X1stDate.setMonth(X1stDate.getMonth() + 3));
               const targetSecondDate =  this.secondEMI.getDate() <= 15 ? 7 : 15;
               this.secondEMI = new Date(this.secondEMI.setDate(targetSecondDate));
               } else if (this.getVariantValue == 'Half-Yearly') {
               this.secondEMI = new Date(X1stDate.setMonth(X1stDate.getMonth() + 6));
               const targetSecondDate =  this.secondEMI.getDate() <= 15 ? 7 : 15;
               this.secondEMI = new Date(this.secondEMI.setDate(targetSecondDate));
               } else {
               this.secondEMI = X1stDate;
               const targetSecondDate =  this.secondEMI.getDate() <= 15 ? 7 : 15;
               this.secondEMI = new Date(this.secondEMI.setDate(targetSecondDate));
               }
               this.isSpinnerMoving = true;
                if(this.inputFieldsValues.installmentType == 'EQUATED'){
                await emiRepaymentSchedule({principal:this.inputFieldsValues.financeAmount,irr:this.inputFieldsValues.ROI,loanDate:loanDealDate,increment:Number(this.tenureValue),frequency:this.frequencyValue,repaymentDate:this.firstEMIDate,secondEMI:this.secondEMI,advanceEMI:this.advanceEMIValue}).then((result) => {
                    this.showEquated = true;
                    this.showAmort = true;
                    this.showStructured = false;
                    this.balanceAmount = 0;
                    this.totalSumAmount = 0;
                    this.itemList=[];
                    this.totalPaybleEMI = result;
                    if (result?.length >0) {
                        this.crmIRR = this.inputFieldsValues.ROI;
                        this.totalMonthlyPayment = result[1].instalmentAmount;
                        this.isParameterChange = false; 
                        this.irrCashFlows = [];
                        for(let res of result){
                            this.irrCashFlows.push(Number(res.instalmentAmount));
                            this.totalPrinciple = Number(this.totalPrinciple)+Number(res.instalmentAmount);
                        }
                        }
                    })
                await this.calculateGrossNetIRRMethod();
                }
               else {
               await gradedRepaymentSchedule({cashFlows:this.cashFlows,principal:financeAmount,irr:this.inputFieldsValues.ROI,loanDate:loanDealDate,increment:Number(this.tenureValue),day:0,frequency:this.frequencyValue,repaymentDate:this.firstEMIDate,secondEMI:this.secondEMI}).then((result)=>{
                    console.log('#### result',result);
                    if (this.inputFieldsValues.installmentType==='EQUATED') {
                        this.showEquated = true;
                        this.showStructured = false;
                        this.balanceAmount = 0;
                        this.totalSumAmount = 0;
                        this.itemList=[];
                    }
                    this.totalPaybleEMI = result;
                    this.showAmort = true;
                    if (result?.length >0) {
                       // this.netIRR = result[0].irr;
                        //this.crmIRR = result[0].irr;
                       // this.grossIRR = result[0].irr;
                        this.isParameterChange = false;
                        this.irrCashFlows = [];
                        for(let res of result){
                            this.irrCashFlows.push(Number(res.instalmentAmount));
                            this.totalPrinciple = Number(this.totalPrinciple)+Number(res.instalmentAmount);
                        }
                    }
               }).catch((error)=>{
                  console.error(error);
                  this.isSpinnerMoving = false;
               });
               await this.calculateGrossNetIRRMethod();
               await this.calculateCRMIRRMethod();  //SFTRAC-2064
            }
            this.isSpinnerMoving = false;
            }
        } catch (error) {
            console.error(error);
            this.isSpinnerMoving = false;
        }
    }
    //SFTRAC-2064 Start
    calculateCRMIRRMethod(){
        calculateCRMIRR({cashFlows: this.irrCashFlows, principal: this.inputFieldsValues.financeAmount, 
                              frequency: this.frequencyValue, installmentType: this.inputFieldsValues.installmentType}).then((result) => {
            this.crmIRR = result.crmirr;
        }).catch((error) => { this.isSpinnerMoving = false; });
    }
    //SFTRAC-2064 End

    calculateGrossNetIRRMethod(){
    calculateGrossNetIRR({cashFlows:this.irrCashFlows,principal:this.inputFieldsValues.financeAmount,frequency:this.frequencyValue,payIn:this.payin,payOut:this.payout,installmentType:this.inputFieldsValues.installmentType}).then((result)=>{
        this.grossIRR = result.grossirr;
        this.netIRR = result.netirr;
    }).catch((error)=>{
        this.isSpinnerMoving = false;
     });
    } 

    get isEmiCalculated(){
        return this.totalPaybleEMI?.length>0;
    }
    get products(){
        return [
            {label : 'NULL' , value : 'NULL'},
            {label : 'H' , value : 'H'},
            {label : 'S' , value : 'S'},
            {label : 'T' , value : 'T'},
            {label : 'G' , value : 'G'},
            {label : 'C' , value : 'C'},
            {label : 'L' , value : 'L'},
            {label : 'D' , value : 'D'},
            {label : 'E' , value : 'E'},
        ];
    }
    get variantInstallmentTypeOptions(){
        return [
            {label : 'Monthly' , value : 'Monthly'},
            {label : 'Bi-Monthly' , value : 'Bi-Monthly'},
            {label : 'Quartely' , value : 'Quartely'},
            {label : 'Half-Yearly' , value : 'Half-Yearly'},
        ];
    }
    get tenureOptions(){
        return this.getOptions(84, 5);
    }
    getOptions(num, skip){
        let tenureList = [];
        for (let i = 0; i <= num; i++) {
            let element = {label : String(i) , value : String(i)};
            tenureList.push(element);
            i += skip;
        }
        return tenureList;
    }
    get moratoriumInDaysOptions(){
        if(this.getVariantValue == 'Monthly'){
          return [
            {label : '0' , value : '0'},
            {label : '30' , value : '30'},
           ];
        }
        else if(this.getVariantValue == 'Bi-Monthly'){
             return [
            {label : '30' , value : '30'},
            {label : '60' , value : '60'},
        ];
        }
        else if(this.getVariantValue == 'Quartely'){
          return [
            {label : '30' , value : '30'},
            {label : '60' , value : '60'},
            {label : '90' , value : '90'},
          ];
        }
        else if(this.getVariantValue == 'Half-Yearly'){
          return [
            {label : '30' , value : '30'},
            {label : '60' , value : '60'},
            {label : '90' , value : '90'},
            {label : '120' , value : '120'},
            {label : '150' , value : '150'},
            {label : '180' , value : '180'},
          ];
        }
       
    }
    get installmentTypeOptions(){
        return [
            {label : 'EQUATED' , value : 'EQUATED'},
            {label : 'STRUCTURED' , value : 'STRUCTURED'}
        ];
    }
    
    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }
}