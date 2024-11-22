import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFirstMonthStructeredEMI from '@salesforce/apex/CaptureStructureEMI.getFirstMonthStructeredEMI';
import getStructeredEMIexceptFirst from '@salesforce/apex/CaptureStructureEMI.getStructeredEMIexceptFirst';
import addupdateStructuredEMI from '@salesforce/apex/CaptureStructureEMI.addupdateStructuredEMI';
import checkIfReadOnly from '@salesforce/apex/CaptureStructureEMI.checkIfReadOnly';
import { deleteRecord } from 'lightning/uiRecordApi';
import getFinalTermRecord from '@salesforce/apex/CaptureStructureEMI.getFinalTermRecord';

import fetchProductType from '@salesforce/apex/FinalTermscontroller.fetchProductType';


export default class IND_LWC_StructuredEMI extends LightningElement {
    @api vehicleId = '';
    @api dealId = '';
    keyIndex = 0;
    @api isValueChange ;
    financeAmount;
    cRMIRR;
    tenure;
    fromMonth;
    toMonth;
    installments;
    finalNPR = 0;
    emi;
    readOnly=true;
    discreapancyScreen=false;
    isStructuredType = false;
    allowedSubmit = false;
    @api loanAgreementAmt;
    read;
    //recordId1='00671000001Kmj3AAC';
    @api recordId;
    @api forIncomeScreen = false;
    @api installmentFrequency;
    @track fromLabel = 'From Installment';
    @track toLabel =  'To Installment';
    @track itemList = [
        {
            id: 0,
            fromMonth: 1,
            toMonth:"",
            installments:"",
            emi:"",
            sfId:"",

        }
    ];
    @track finalList = [{id: 0,
        fromMonth: 1,
        toMonth:"",
        installments:"",
        emi:"",
        sfId:"",}];

    productTypeDetail;
    isTractor=false;
    totalEMI = 0;
    index = 0;
    openingPrincipal = 0;
    emiamount = 0;
    increment;
    @api readMode;
    requiredCRMIRR;

    async connectedCallback(){
       // this.openingPrincipal = this.loanAgreementAmt;
        console.log('insfreqcc----'+this.installmentFrequency);
                await getFinalTermRecord({ loanApplicationId: this.recordId, vehicleId: this.vehicleId, l1stage: true})
                  .then(result => {
                    console.log('Result in getFinalTermRecord', result);
                    if(result!=null){
                        this.fromMonth = 1;
                        this.toMonth= 1;
                        this.installments=1;
                        //this.emi=result.EMI_Amount__c;
                        this.financeAmount = parseFloat(result.Loan_Amount__c) + parseFloat(result.Loan_Application__r.Total_Funded_Premium__c);
                        this.openingPrincipal = this.financeAmount;
                        this.cRMIRR=result.CRM_IRR__c;
                        this.requiredCRMIRR = result.Required_CRM_IRR__c;
                        this.tenure=result.Tenure__c;
                        this.increment = Number(result.Tenure__c) / Number(this.installmentFrequency);
                        let holidayPeriod = result.Holiday_period__c;
                        if(parseInt(holidayPeriod) == 30 && Number(this.installmentFrequency) == 1){
                            console.log('OUTPUT : ',);
                            this.increment = (parseFloat(this.increment) -1);
                        }else{
                            this.increment = parseFloat(this.increment)
                        }
                        console.log('financeAmount' ,  this.financeAmount);
                        console.log('final tenure' ,  this.increment);
                    }
                  })
                  .catch(error => {
                    console.error('Error:', error);
                });
             /*   await getFirstMonthStructeredEMI({ loanApplicationId: this.recordId, vehicleId: this.vehicleId, l1stage: true})
                .then(result => {
                    console.log('Result in getFirstMonthStructeredEMI', result);
                    if(result!=null){
                        this.fromMonth = result.From_Month__c;
                        this.toMonth=result.To_Month__c;
                        this.installments=result.Number_of_Installments__c;
                        this.emi=result.EMI_Amount__c;
                    }
                })
                .catch(error => {
                    this.error = error;
                }); */
           await  getStructeredEMIexceptFirst({ loanApplicationId: this.recordId, vehicleId: this.vehicleId, l1stage: true })
                .then(result => {
                    console.log('Result in getStructeredEMIexceptFirst **', result);
                    if(result!=null && result.length>0){
                        this.itemList.shift();
                    for(let n = 0; n < result.length; n++){
                        var newItem = [{ id: n ,fromMonth:result[n].From_Month__c,toMonth:result[n].To_Month__c,installments:result[n].Number_of_Installments__c,emi:result[n].EMI_Amount__c,sfId:result[n].Id}];
                        this.itemList = this.itemList.concat(newItem);
                        this.keyIndex=n;;
                    }
                    console.log('this.itemList in connected callback: ',this.itemList);
                    var lastRow = [];
                    lastRow = this.itemList.filter(element => element.fromMonth == this.increment);
                    console.log('lastRow------'+lastRow[0].emi);
                    this.template.querySelector("[data-id='lastEMIId']").value = lastRow[0].emi;
                    this.itemList = this.itemList.filter(element => {if(element.fromMonth != this.increment) return element});
                    this.isSubmitDisabled = true;
                    this.isDisableEMI = true;
                    this.isDisableTo = true;
                }
                })
                .catch(error => {
                    this.error = error;
                });
                if(this.readMode == 'true'){
                    this.read = true;
                    this.disableEverything();
                }
            
        
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
        if(this.forIncomeScreen){
            this.readOnly = false;
        } 
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @api isRevokedLoanApplication;//CISP-2735
    //CISP-2735-END
    addRow(event) {
        var index=event.target.dataset.targetId;
        if(this.isInputValid(index)) {
            this.isValueChange = true;
        //Added by Poonam to check if tovalue is equal to tenure then add button not create new row 
        let toVal = this.template.querySelectorAll(".toCmp");
        let fromVal = this.template.querySelectorAll(".fromCmp");
        var index=event.target.dataset.targetId;
        let toValue=toVal[index].value;
        let fromValue=fromVal[index].value;
        let emiValue = this.template.querySelectorAll("[data-id='validateEMIId']");
        console.log('entering1-----');
        let installments = this.template.querySelectorAll("[data-id='noInstallmentsId']");
        console.log('entering2-----');
        let installmentNos = installments[index].value;
        let singleEMI = emiValue[index].value;
        this.emiamount = emiValue[index].value * installments[index].value;
        console.log('OUTPUT toValue: ',toValue);
        console.log('OUTPUT fromValue: ',fromValue);
        console.log('OUTPUT tenure: ',this.increment);
            this.calculateInterest(this.openingPrincipal,this.requiredCRMIRR,singleEMI,this.installmentFrequency,installmentNos);
            if(emiValue[index].value < this.interestPart){
                emiValue[index].setCustomValidity('EMI Amount cannot be less than the interest amount');
            } else {
                emiValue[index].setCustomValidity('');
                this.calculateAmort(this.openingPrincipal,this.requiredCRMIRR,singleEMI,this.installmentFrequency,installmentNos);
                if(parseInt(toValue)!= parseInt(this.increment - 1) && parseInt(fromValue) < parseInt(this.increment - 1)){
            var length=this.itemList.length;
            length=parseInt(length)-1;
            var toMon=this.itemList[length].toMonth ;
            var newFromValue=parseInt(toMon) + 1;
            ++this.keyIndex;
            var newItem = [{ id: this.keyIndex ,fromMonth:newFromValue}];
            this.itemList = this.itemList.concat(newItem);
                  /*  console.log('Opening Principal'+this.openingPrincipal);
                    console.log('emiamount-----'+this.emiamount);
                    console.log('crm---'+this.cRMIRR);
                    console.log('insfreq----'+this.installmentFrequency);
                    this.calculateInterest(this.openingPrincipal,this.cRMIRR,singleEMI,this.installmentFrequency,installmentNos);
                    if(emiValue[index].value < this.interestPart){
                        console.log('emi is less than interest');
                        emiValue[index].setCustomValidity('EMI Amount cannot be less than the interest amount');
                    } else {
                        emiValue[index].setCustomValidity('');
                        this.calculateAmort(this.openingPrincipal,this.cRMIRR,singleEMI,this.installmentFrequency,installmentNos);
                        toVal[index].disabled = true;
                        emiValue[index].disabled = true;
                    }
                    emiValue[index].reportValidity(); */
                    }
                    else {
                        
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Warning',
                                message: 'You cannot add further rows. Last row will be autocalculated',
                                variant: 'info',
                            }),
                        );
                    }
                    toVal[index].disabled = true;
                    emiValue[index].disabled = true;
                
            }
            emiValue[index].reportValidity();
        
        }else{
            console.log('in else : ',);
        }
        
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
    handleReset(){
        this.itemList = [
            {
                id: 0,
                fromMonth: 1,
                toMonth:"",
                installments:"",
                emi:"",
                sfId:"",
    
            }
        ];
        let toVal = this.template.querySelectorAll(".toCmp");
        let emiValue = this.template.querySelectorAll("[data-id='validateEMIId']");
        toVal[0].disabled = false;
        emiValue[0].disabled = false;
        this.index = 0;
        this.lastEMI = '';
        this.openingPrincipal = this.financeAmount;
        this.finalList = [{id: 0,
            fromMonth: 1,
            toMonth:"",
            installments:"",
            emi:"",
            sfId:"",}];
    }
    changeHandlerOnToMonth(event){
        this.isValueChange = true;
        console.log('changeHandlerOnToMonth : ',);
        let toVal = this.template.querySelectorAll(".toCmp");   
        var toMon=event.target.value;
        console.log('toMon : ',toMon);
        var index=event.target.dataset.targetId;
        console.log('index : ',index);
        let toValue=toVal[index].value;
        console.log('toValue : ',toValue);
        var toMonName=event.target.name;
        var fromMon=this.itemList[index].fromMonth;
        console.log('fromMon : ',fromMon);
        var emi=(toMon-fromMon)+1;
        this.itemList[index].installments = emi;
        this.itemList[index].toMonth = toMon;
        if(parseInt(fromMon)>parseInt(toValue)){
            toVal[index].setCustomValidity('To Installment must be greater than From Installment');
          }
          //added by Poonam 
          else if(parseInt(toValue)>= parseInt(this.increment)){
            toVal[index].setCustomValidity('To Installment cannot be greater than Total number of Installments');
          }else{
            toVal[index].setCustomValidity('');
          }
          toVal[index].reportValidity();

          //if(this.isInputValid()) {
              console.log('in input valid : ',);
            var toMon=this.itemList[index].toMonth ;
            var newFromValue=parseInt(toMon) + 1;
            let plusOne = parseInt(index) +1;
            var length=this.itemList.length;
            console.log('length : ',length);
            console.log('plusOne : ',plusOne);
            if(length > plusOne){
            console.log('OUTPUT ----: ',);
            this.itemList[plusOne].fromMonth = newFromValue;
            var tonextMon=this.itemList[plusOne].toMonth ;
            var ins=(tonextMon-newFromValue)+1;
            this.itemList[plusOne].installments = ins;
            this.npvCalculation();
          //}
        }
        else{ 
            this.npvCalculation();
        }
        //this.npvCalculation();
    }
    changeHandlerOnInstallment(event){
        this.isValueChange = true;
        var installment=event.target.value;
        var index=event.target.dataset.targetId;
        var fromMon=this.itemList[index].fromMonth;
        var toMon=fromMon + (installment-1);
        this.itemList[index].toMonth = toMon;
        this.itemList[index].installments = installment;
        //this.npvCalculation();
        
    }
    changeHandlerOnFromMonth(event){
        this.isValueChange = true;
        console.log('changeHandlerOnFromMonth : ',event);
        let frmVal = this.template.querySelectorAll(".fromCmp");
        var index=event.target.dataset.targetId;
        let frmValue=frmVal[index].value;
        var previousIndex=parseInt(index) - 1;
        var prevToMonth=this.itemList[previousIndex].toMonth;
        if((parseInt(frmValue)-parseInt(prevToMonth))==1){
            frmVal[index].setCustomValidity("");
        }else{
            frmVal[index].setCustomValidity("From Installment should be one number greater than the previous To Installment");
        }
        frmVal[index].reportValidity();
    }
    isInputValid(index) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
       /* inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        }); */

        if(!inputFields[index].checkValidity()) {
            inputFields[index].reportValidity();
                isValid = false;
            }
        return isValid;
    }
    changeHandlerOnEMI(event){
        this.isValueChange = true;
        var emi=event.target.value;
        var index=event.target.dataset.targetId;
        this.index = index;
        this.itemList[index].emi =emi;
        console.log('changeHandlerOnEMI emi : ',emi);
        //alert('VALUE::'+JSON.stringify(this.itemList[this.keyIndex]));
        this.npvCalculation();
    }
    /*renderedCallback(){
        this.npvCalculation();
    }*/
    npvCalculation(){
        var npvList=[];
        this.finalNPR=0;
       // npvList.push(this.emi);
        for(let n = 0; n < this.itemList.length; n++){
            if(this.itemList[n].installments!=null){
                var instalment=this.itemList[n].installments;
                for(let i = 0; i < instalment; i++){
                    // Added By Poonam to solve NAN problem
                    if(!isNaN(parseFloat(this.itemList[n].emi))){
                        console.log('inside if : ',);
                        npvList.push(parseFloat(this.itemList[n].emi));
                    }
                    else{
                        console.log('inside else : ',);
                        npvList.push(parseInt(0));
                    }

                }
                //alert('LIST::'+npvList);
            }
        }
        console.log('npvList : ',npvList);
        this.totalEMI = 0;
        for(let i=0; i<npvList.length; i++){ 
        this.totalEMI += npvList[i];
        }
      /*  var discountRate =parseFloat(this.cRMIRR)/100; //10%  rate 
        console.log('discRate1',discountRate);
        discountRate = discountRate/12;
        var finalDiscountRate = 1+discountRate; //1+0.1  (1+ R/100) 
        for(let i=0; i<npvList.length; i++){ 
            this.finalNPR += npvList[i]/Math.pow(finalDiscountRate,i+1); 
        } 
        this.finalNPR  = parseFloat(this.finalNPR);
        console.log('typeof(this.finalNPR) : ',typeof(this.finalNPR));
        console.log('parseFloat(this.financeAmount) : ',typeof(parseFloat(this.financeAmount)));
        var myTrunc = Math.trunc(this.finalNPR);
        console.log('finalNPR : ',this.finalNPR);
        console.log('myTrunc : ',myTrunc); */
        var diff = Number(this.loanAgreementAmt) - Number(this.totalEMI);
        let x = Math.sign(diff);
        let remEMI = this.template.querySelectorAll("[data-id='validateEMIId']");
       // let remEMI = this.template.querySelectorAll(".textLastEMI");
        if(x== '-1' || diff == 0){
        remEMI[this.index].setCustomValidity('Last EMI cannot be negative or zero');
        } else {
        remEMI[this.index].setCustomValidity('');
        }
        remEMI[this.index].reportValidity();
        diff = Math.ceil(diff);
       // remEMI.reportValidity();
        this.lastEMI = diff;
        this.allowedSubmit = true;
      /*  if(diff == 0){
            //alert('Inside if::'+myTrunc);
            this.discreapancyScreen=false;
        }else{
            //alert('Inside else::'+myTrunc);
            this.discreapancyScreen=true;
        } */
        
    }
    isSubmitDisabled = false;
    saveDataFromHandleSubmit(submitFalg){
        this.isSubmitDisabled = true;
        this.isDisableEMI = true;
        this.isDisableTo = true;
        let isSuccess = false;
        this.npvCalculation();
        let lastFrom = this.increment;
        let LastTo = this.increment;
        let LastEMI = this.template.querySelector("[data-id='lastEMIId']").value;
        var initialLength=this.itemList.length;
        var lastItem = [{ id: Number(initialLength)+1 ,fromMonth:lastFrom,toMonth:LastTo,installments:"1",emi:LastEMI}];
        console.log('lastItem------'+JSON.stringify(lastItem));
        //this.finalList.shift();
        this.finalList = [];
        this.finalList = this.finalList.concat(this.itemList);
        this.finalList = this.finalList.concat(lastItem);
       // this.itemList = this.itemList.concat(lastItem);
        console.log('final list--------'+JSON.stringify(this.finalList));
        var length=this.itemList.length;
        console.log('submit length : ',length);
        console.log('submit this.itemList : ',this.itemList);
        length=parseInt(length)-1;
        var lastMonthToVal=this.itemList[length].toMonth;
        if(lastMonthToVal==parseInt(this.increment -1)){
        if(this.allowedSubmit==true){
            var isVal = false;
            var itemVal=JSON.stringify(this.finalList);
            //alert('Inside::'+isVal);
            addupdateStructuredEMI({ itemList:itemVal,recordId: this.recordId, submittedFalg:submitFalg,dealId: this.dealId, vehicleId: this.vehicleId })
            .then(result => {
            if(result!=null){
                console.log('OUTPUT :result ',);
                isVal=result;                
                if (isVal==true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records Submitted Successfully',
                            variant: 'success',
                        }),
                    );
                    const selectEvent = new CustomEvent('mycustomevent', {
                        detail: false
                    });
                    this.dispatchEvent(selectEvent);
                    if(submitFalg == true)
                        this.readOnly=true;
                    else
                        this.readOnly=false;
                        this.isValueChange = false; 
                         
                } else {
                    isSuccess = false;
                    this.isSubmitDisabled = false;
                    this.isDisableEMI = false;
                    this.isDisableTo = false;
                    this.isValueChange = false;   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: 'Please enter the data properly',
                            variant: 'error',
                        }),
                    );
                }
            }
        })
       .catch(error => {
           this.error = error;
       });
       isSuccess = true;
        }else{
            isSuccess = false;
            this.isSubmitDisabled = false;
            this.isDisableEMI = false;
            this.isDisableTo = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please match loan amount to continue with the journey.',
                    variant: 'error',
                }),
            );
        }
    }else{
        isSuccess = false;
        this.isSubmitDisabled = false;
        this.isDisableEMI = false;
        this.isDisableTo = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating record',
                message: 'Last row should be similar to tenure',
                variant: 'error',
            }),
        );
    }
    if(submitFalg == false){
    const actionResultEvent = new CustomEvent("submitresultaction", {
        detail: {isSuccess: isSuccess}
      });
  
      // Dispatches the event.
      this.dispatchEvent(actionResultEvent);
    }

    }

    handleSubmit(){
        console.log('save inline : ',);
        this.saveDataFromHandleSubmit(true);
    }
}