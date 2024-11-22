import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLADetails from '@salesforce/apex/CaptureStructureEMI.getLADetails';
import getFirstMonthStructeredEMI from '@salesforce/apex/CaptureStructureEMI.getFirstMonthStructeredEMI';
import getStructeredEMIexceptFirst from '@salesforce/apex/CaptureStructureEMI.getStructeredEMIexceptFirst';
import addupdateStructuredEMI from '@salesforce/apex/CaptureStructureEMI.addupdateStructuredEMI';
import checkIfReadOnly from '@salesforce/apex/CaptureStructureEMI.checkIfReadOnly';
import isFTStructuredType from '@salesforce/apex/CaptureStructureEMI.isFTStructuredType';
import { deleteRecord } from 'lightning/uiRecordApi';
import getFinalTermRecord from '@salesforce/apex/CaptureStructureEMI.getFinalTermRecord';

import fetchProductType from '@salesforce/apex/FinalTermscontroller.fetchProductType';


export default class IND_LWC_StructuredEMI extends LightningElement {
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
    //recordId1='00671000001Kmj3AAC';
    @api recordId;
    @api forIncomeScreen = false;
    @api installmentFrequency;
    @track fromLabel = 'From Month';
    @track toLabel =  'To Month';
    @track itemList = [
        {
            id: 0,
            fromMonth: 2,
            toMonth:"",
            installments:"",
            emi:"",
            sfId:"",

        }
    ];
    productTypeDetail;
    isTractor=false;

    connectedCallback(){

        /*SFTRAC - 100 :SahilM Start */ 
        let result = fetchProductType({loanAppId: this.recordid}); 
        let oppObj = result ? result[0] : null;
        this.productTypeDetail = oppObj?.Product_Type__c;
        this.isTractor = this.productTypeDetail == 'Tractor'?true:false;
        console.log('isTractor'+this.isTractor);
        /*SFTRAC - 100 :SahilM  Close */ 
        // added by poonam 
        isFTStructuredType({ loanApplicationId: this.recordId, dealId: this.dealId })
          .then(result => {
            console.log('Result in isFTStructuredType', result);
            if(result == true){
                this.isStructuredType = true;
                   checkIfReadOnly({ lAId: this.recordId, dealId: this.dealId })
                .then(result => {
                    console.log('checkIfReadOnly : ',);
                    if(result!=null){
                        console.log('result ----  : ',result);
                        this.readOnly=result;
                    }
                    })
                    .catch(error => {
                        this.error = error;
                    });
            }else{
                this.isStructuredType = false;
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
        
        if(this.forIncomeScreen){
            if(this.installmentFrequency.includes('Quarter')){
                this.toLabel = 'To Quarter';
                this.fromLabel = 'From Quarter';
            }
            else if(this.installmentFrequency.includes('Month')){
                this.toLabel = 'To Month';
                this.fromLabel = 'From Month';
            }
            else {
                this.toLabel = 'To '+this.installmentFrequency;
                this.fromLabel = 'From '+this.installmentFrequency;
            }
            
            this.readOnly = false;
        }    

           /* getLADetails({ loanApplicationId: this.recordId })
                .then(result => {
                    console.log('getLADetails-- : ',result);
                if(result!=null){
                    this.financeAmount = result.Finance_Amount__c;// Changed By Poonam (Field change from Amount to Finance_amount)
                    this.cRMIRR=result.CRM_IRR__c;
                    this.tenure=result.Required_Tenure__c;
                }
                })
                .catch(error => {
                    this.error = error;
                });*/

                getFinalTermRecord({ loanApplicationId: this.recordId, dealId: this.dealId})
                  .then(result => {
                    console.log('Result in getFinalTermRecord', result);
                    if(result!=null){
                        this.fromMonth = 1;
                        this.toMonth= 1;
                        this.installments=1;
                        this.emi=result.EMI_Amount__c;
                        this.financeAmount = parseFloat(result.Loan_Amount__c) + parseFloat(result.Loan_Application__r.Total_Funded_Premium__c);
                        this.cRMIRR=result.CRM_IRR__c;
                        this.tenure=result.Tenure__c;
                        let holidayPeriod = result.Holiday_period__c;
                        if(parseInt(holidayPeriod) == 30){
                            console.log('OUTPUT : ',);
                            this.tenure = (parseFloat(this.tenure) -1);
                        }else{
                            this.tenure = parseFloat(this.tenure)
                        }
                        console.log('financeAmount' ,  this.financeAmount);
                        console.log('final tenure' ,  this.tenure);
                    }
                  })
                  .catch(error => {
                    console.error('Error:', error);
                });
                getFirstMonthStructeredEMI({ loanApplicationId: this.recordId, dealId: this.dealId })
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
                });
            getStructeredEMIexceptFirst({ loanApplicationId: this.recordId, dealId: this.dealId })
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
                }
                })
                .catch(error => {
                    this.error = error;
                });
            
        
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

        if(this.isInputValid()) {
            this.isValueChange = true;
        //Added by Poonam to check if tovalue is equal to tenure then add button not create new row 
        let toVal = this.template.querySelectorAll(".toCmp");
        let fromVal = this.template.querySelectorAll(".fromCmp");
        var index=event.target.dataset.targetId;
        let toValue=toVal[index].value;
        let fromValue=fromVal[index].value;
        console.log('OUTPUT toValue: ',toValue);
        console.log('OUTPUT fromValue: ',fromValue);
        console.log('OUTPUT tenure: ',this.tenure);
        if(parseInt(toValue)!= parseInt(this.tenure) && parseInt(fromValue) < parseInt(this.tenure)){
            var length=this.itemList.length;
            length=parseInt(length)-1;
            var toMon=this.itemList[length].toMonth ;
            var newFromValue=parseInt(toMon) + 1;
            ++this.keyIndex;
            var newItem = [{ id: this.keyIndex ,fromMonth:newFromValue}];
            this.itemList = this.itemList.concat(newItem);
            }
        }else{
            console.log('in else : ',);
        }
        
    }

    removeRow(event) {
        this.isValueChange = true;
        console.log('remove row event call : ',this.itemList);
        if(this.itemList.length >= 2){
            let targetId = event.target.dataset.targetId;
            console.log('targetId : ',targetId);
            if(this.itemList[targetId].sfId){
                deleteRecord(this.itemList[targetId].sfId);
            }
        }
        
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                console.log('in remove row : ',);
                console.log('element.id : ',element.id);
                console.log('event.target.id : ',event.target.id);
                return parseInt(element.id) !== parseInt(event.target.id);
                
            });
            this.npvCalculation();
        }
        //this.keyIndex = this.itemList.length;
       
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
            toVal[index].setCustomValidity('ToMonth must be greater than From Month');
          }
          //added by Poonam 
          else if(parseInt(toValue)> parseInt(this.tenure)){
            toVal[index].setCustomValidity('ToMonth not be greater than Tenure');
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
            frmVal[index].setCustomValidity("From Month should be one month greater than the previous To month");
        }
        frmVal[index].reportValidity();
    }
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    changeHandlerOnEMI(event){
        this.isValueChange = true;
        var emi=event.target.value;
        var index=event.target.dataset.targetId;
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
        npvList.push(this.emi);
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
        var discountRate =parseFloat(this.cRMIRR)/100; //10%  rate 
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
        console.log('myTrunc : ',myTrunc);
        if(myTrunc == parseFloat(this.financeAmount)){
            //alert('Inside if::'+myTrunc);
            this.discreapancyScreen=false;
        }else{
            //alert('Inside else::'+myTrunc);
            this.discreapancyScreen=true;
        }
        
    }
    isSubmitDisabled = false;
    structureEMIRecordsCreated = false;
    async saveDataFromHandleSubmit(submitFalg){
        this.isSubmitDisabled = true;
        let isSuccess = false;
        this.npvCalculation();
        var length=this.itemList.length;
        console.log('submit length : ',length);
        console.log('submit this.itemList : ',this.itemList);
        length=parseInt(length)-1;
        var lastMonthToVal=this.itemList[length].toMonth;
        if(lastMonthToVal==parseInt(this.tenure)){
        if(this.discreapancyScreen==false){
            var isVal = false;
            var itemVal=JSON.stringify(this.itemList);
            //alert('Inside::'+isVal);
            if(this.structureEMIRecordsCreated == false){
            let result = await addupdateStructuredEMI({ itemList:itemVal,recordId: this.recordId, submittedFalg:submitFalg, dealId: this.dealId });
            // .then(result => {
            if(result!=null){
                console.log('OUTPUT :result ',);
                isVal=result;                
                if (isVal==true) {
                    this.structureEMIRecordsCreated = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records Submitted Successfully',
                            variant: 'success',
                        }),
                    );
                    if(submitFalg == true)
                        this.readOnly=true;
                    else
                        this.readOnly=false;
                        this.isValueChange = false; 
                         
                } else {
                    this.structureEMIRecordsCreated = false;
                    isSuccess = false;
                    this.isSubmitDisabled = false;
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
            }
    //     })
    //    .catch(error => {
    //        this.error = error;
    //    });
       isSuccess = true;
        }else{
            isSuccess = false;
            this.isSubmitDisabled = false;
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
    @api
    handleSubmitFromParent(){
        console.log('save from parent : ',);
        this.saveDataFromHandleSubmit(false);
    }

    handleSubmit(){
        console.log('save inline : ',);
        this.saveDataFromHandleSubmit(true);
    }
}