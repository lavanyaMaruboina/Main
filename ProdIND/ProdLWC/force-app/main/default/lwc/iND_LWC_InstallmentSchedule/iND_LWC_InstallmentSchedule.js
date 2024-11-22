import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getRecentEMIdetails from '@salesforce/apex/InstallmentScheduleController.getRecentEMIdetails';
import getFinalTermsLoandetails from '@salesforce/apex/InstallmentScheduleController.getFinalTermsLoandetails';
import getFirstStructureEMI from '@salesforce/apex/InstallmentScheduleController.getFirstStructureEMI';
import getStructeredEMIexceptFirst from '@salesforce/apex/CaptureStructureEMI.getStructeredEMIexceptFirst';
import addupdateStructuredEMI from '@salesforce/apex/CaptureStructureEMI.addupdateStructuredEMI';
import updateStructuredEMI from '@salesforce/apex/CaptureStructureEMI.updateStructuredEMI';
import { deleteRecord } from 'lightning/uiRecordApi';
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';
export default class IND_LWC_InstallmentSchedule extends NavigationMixin(LightningElement) {
    @api recordId;
    Regex_NumberOnly = Regex_NumberOnly;
    @api showInstallmentModel=false;
    @api fromCAMPage=false;
    isLoading = false;
    showEquated = false;
    showStructured = false;
    isInstallmentGreater = false;
    tenure = 0;
    @track financeAmount = 0;
    @track totalPrinciple = 0;
    closingPrincipal = 0;
    @track totalPaybleEMI = [];
    keyIndex = 0;
    @track itemList= [];
    balanceAmount = 0;
    totalSumAmount = 0;
    interest = 0;
    disableSubmit = false;
    disableAddRow=false;
    disableRemoveRow=false;
    installmentType;
    @track firstEMIDate;
    @track secondEMIDate;
    lastEMIAmount=0;
    cashflow =[];
    loanDealDate;
    lastdate;
    keyIndex = 0;
    @api isValueChange ;
    cRMIRR;
    tenure;
    fromMonth;
    toMonth;
    installments;
    finalNPR = 0;
    emi;
    readOnly=false;
    discreapancyScreen=false;
    isStructuredType = false;
    nextOpenPrincipal=0;
    nextInstallment=0;
    @api forIncomeScreen = false;
    @api installmentFrequency;
    @track fromLabel = 'From Month';
    @track toLabel =  'To Month';
    @track itemList = [
        {
            id: 0,
            fromMonth: 2,
            toMonth: 2,
            installments: 2,
            emi:"",
            sfId:"",
            dueDate: "",
            interestComp: "",
            OpenPrincipal: "",
            installmentComp: "",

        }
    ];
    productTypeDetail;
    
   async connectedCallback(){
    await getFinalTermsLoandetails({loanId : this.recordId}).then(res =>{
        if(res && res?.length > 0){
            this.installmentType = res[0].Installment_Type__c;
            if(res[0].Installment_Type__c?.includes('Structured')){
                const stageNames = ['Final Offer','Post Sanction Checks and Documentation','Pre Disbursement Check','Disbursement Request Preparation'];
                const subStages = ['CAM and Approval Log','Sanction of Application'];
                if(stageNames.includes(res[0].Loan_Application__r.StageName) || subStages.includes(res[0].Loan_Application__r.Sub_Stage__c)){
                    this.readOnly =true;
                }
                this.isStructuredType = true;
                this.financeAmount = res[0].Loan_Amount__c;
                this.tenure = res[0].Tenure__c;
                this.totalPrinciple = res[0].Offer_Agreement_Amount__c;
                this.firstEMIDate = res[0].First_EMI_Date__c;
                this.secondEMIDate = res[0].Second_EMI_Date__c;
                this.loanDealDate = res[0].Loan_Deal_Date__c;
                this.emi=res[0].EMI_Amount__c;
                this.financeAmount = parseFloat(res[0].Loan_Amount__c) + parseFloat(res[0].Loan_Application__r.Total_Funded_Premium__c);
                this.cRMIRR=res[0].CRM_IRR__c;
                this.tenure=res[0].Tenure__c;
                let holidayPeriod = res[0].Holiday_period__c;
                if(parseInt(holidayPeriod) == 30){
                    this.tenure = (parseFloat(this.tenure) -1);
                }else{
                    this.tenure = parseFloat(this.tenure)
                }
            }else{
                this.getRecentEMIdetails();
            }
        }
    });

    if(this.installmentType && this.installmentType == 'Structured'){
      await getFirstStructureEMI({ loanId: this.recordId})
      .then(result => {
          if(result!=null){
              this.fromMonth = result.From_Month__c;
              this.toMonth=result.To_Month__c;
              this.installments=result.Number_of_Installments__c;
              this.emi=result.EMI_Amount__c;
              let seconddate = new Date(result.EMI_Due_Date__c);
              let emiDate = seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
              this.dueDate=emiDate;
              this.lastdate = result.EMI_Due_Date__c;
              this.calculateAmounts(parseFloat(this.emi),parseFloat(this.financeAmount),this.loanDealDate,result.EMI_Due_Date__c, 1);
          }
      })
      .catch(error => {
          this.error = error;
      });
    await getStructeredEMIexceptFirst({ loanApplicationId: this.recordId, dealId: null })
      .then(result => {
          if(result!=null && result.length>0){
              this.itemList.shift();
          for(let n = 0; n < result.length; n++){
              let seconddate = new Date(result[n].EMI_Due_Date__c);
              let emiDate = seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
              var newItem = [{ id: n ,fromMonth:result[n].From_Month__c,toMonth:result[n].To_Month__c,installments:result[n].Number_of_Installments__c,emi:result[n].EMI_Amount__c,sfId:result[n].Id,dueDate:emiDate}];
              this.itemList = this.itemList.concat(newItem);
              this.keyIndex=n;
           }
           console.log(this.itemList.length,'this.itemList1',this.tenure,'this.tenure123');
        //    this.itemList.forEach(item => {
        //     if(this.tenure == this.itemList.length + 1){
        //         item.isDisable = false;
        //         this.itemList[this.itemList.length-1].isDisable = true;
        //     }
        //    })
           this.calculateAmountsForOtherEMI(result);
      }else{
        if(this.secondEMIDate){
            let seconddate = new Date(this.secondEMIDate);
                  let emiDate = seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
            this.itemList = [
                {

                    id: 0,
                    fromMonth: 2,
                    toMonth: 2,
                    installments: 2,
                    emi:"",
                    sfId:"",
                    dueDate: emiDate ? emiDate : "",
                    interestComp: "",
                    OpenPrincipal: "",
                    installmentComp: "",
                    isDisable:false
                }
            ];
        }
      }
      })
      .catch(error => {
          this.error = error;
      });
   }
   }
   async calculateAmountsForOtherEMI(result){//CISP-23150 start
    console.log('listValues',result);
    for(let n = 0; n < result.length-1; n++){
        await this.calculateAmounts(parseFloat(result[n].EMI_Amount__c),parseFloat(this.nextOpenPrincipal),this.lastdate,result[n].EMI_Due_Date__c, result[n].To_Month__c);
        this.lastdate = result[n].EMI_Due_Date__c;
    }
   }//CISP-23150 end 

   async getRecentData(){
    await getStructeredEMIexceptFirst({ loanApplicationId: this.recordId, dealId: null })
      .then(result => {
        this.itemList = []; //Unit Fix
          if(result!=null && result.length>0){
              this.itemList.shift();
          for(let n = 0; n < result.length; n++){
              let seconddate = new Date(result[n].EMI_Due_Date__c);
              let emiDate = seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
              var newItem = [{ id: n ,fromMonth:result[n].From_Month__c,toMonth:result[n].To_Month__c,installments:result[n].Number_of_Installments__c,emi:result[n].EMI_Amount__c,sfId:result[n].Id,dueDate:emiDate,isDisable:false}];
              this.itemList = this.itemList.concat(newItem);
              this.keyIndex=n;
           }
        //    this.itemList.forEach(item => {
        //     if(this.tenure == this.itemList.length + 1){
        //         item.isDisable = false;
        //         this.itemList[this.itemList.length-1].isDisable = true;
        //     }
        //    })
        }}).catch(error=>{
            console.log('getStructeredEMIexceptFirst Error: '+error);
        })
      
   }
   async getDaysDifference(firstdate, secondate){
    var date1 = new Date(firstdate);
    var date2 = new Date(secondate);
    var differenceInMs = date2 - date1;
    var differenceInDays = differenceInMs / (1000 * 60 * 60 * 24);
    return differenceInDays.toFixed(0);
   }

   async getRecentEMIdetails(){
    await getRecentEMIdetails({loanId : this.recordId}).then(res =>{
        if(res && res?.length > 0){
            // this.disableSubmit = this.fromCAMPage;
            if(res[0].Installment_Type__c?.includes('Equated')){
                this.totalPaybleEMI = res;
                this.showEquated = true;
            }
        }
        // else{
        //     this.disableSubmit = true;
        // }
    });
   }
    closeModel(){
        if (this.fromCAMPage) {
            self.close();
        }else{
        this.dispatchEvent(new CustomEvent('close'));
        }
    }
    handleInsSubmit(){
        if(!this.readOnly && this.isStructuredType){
            this.saveDataFromHandleSubmit(true);
        }else{
            this.dispatchEvent(new CustomEvent('submit'));
        }
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    async calculateAmounts(installmentAmount, opPrincipal, firstdate, secondate, toValue){
        console.log('calculateAmounts--',installmentAmount,' ',opPrincipal,' ',firstdate,' ', secondate,' ',toValue)
        let interestComp = await this.interestCalculation(installmentAmount, opPrincipal, firstdate, secondate, toValue);
    
        // let interestComp = discountRate/leapYearVal*(daysDiff)*opPrincipal;

        let principalComp = installmentAmount - interestComp;
        let closingPrincipal = opPrincipal - principalComp;
        this.nextOpenPrincipal = closingPrincipal;
        let dateComp = new Date(toValue == 1 ? this.secondEMIDate : secondate);
        let nextDate = new Date(
            (dateComp.getFullYear()),
            (dateComp.getMonth() + (toValue == 1 ? 0 : 1)),
            (dateComp.getDate())
          );
        // let nextDaysDiff = await this.getDaysDifference(secondate, nextDate);
        this.nextInterestCom = await this.interestCalculation(installmentAmount, this.nextOpenPrincipal, secondate, nextDate, toValue);
        this.nextInstallment = this.nextOpenPrincipal+ this.nextInterestCom;
        console.log(this.nextInstallment,'this.nextInstallment');
    }

    async interestCalculation(installmentAmount, opPrincipal, firstdate, secondate, toValue){

        let daysDiff = await this.getDaysDifference(firstdate, secondate);
        let discountRate =parseFloat(this.cRMIRR)/100;
        let leapYear = secondate !=null ? new Date(secondate).getYear(): 0;
        let leapYearVal;
        if (leapYear % 4 == 0) {
            leapYearVal = 366;
        } else {
            leapYearVal = 365;
        }
        let interestComp;

        if(new Date(firstdate).getMonth() + 1 == 12 && new Date(secondate).getMonth() + 1 == 1 && (new Date(secondate).getYear() %4 == 0 || new Date(firstdate).getYear() %4 == 0)){

            let initialDays = 31 - new Date(firstdate).getDate();
            initialDays++;
            let remainingDays = new Date(secondate).getDate() - 1;
            if(new Date(firstdate).getYear() %4 == 0){
                interestComp = ((opPrincipal * discountRate)/366)*(initialDays) + ((opPrincipal * discountRate)/365)*(remainingDays);
            } 
            else if(new Date(secondate).getYear() %4 == 0){
                interestComp = ((opPrincipal * discountRate)/365)*(initialDays) + ((opPrincipal * discountRate)/366)*(remainingDays);
            }

        } else {
            interestComp = ((opPrincipal * discountRate)/leapYearVal)*(daysDiff);
        }
        interestComp = interestComp;
        return interestComp;

    }
    async addRow(event) {
        this.isLoading = true;
        this.disableAddRow = true;
        if(await this.isInputValid()) {
            if(parseInt(this.tenure) == (this.itemList.length +1)){
                this.dispatchEvent(ShowToastEvent({
                    title: "Error",
                    message: 'Can not add row more than Tenure',
                    variant: 'error',
                }));
                return;
            }
            this.isValueChange = true;
            let toVal = this.template.querySelectorAll(".toCmp");
            let fromVal = this.template.querySelectorAll(".fromCmp");
            let dueDateVal = this.template.querySelectorAll(".dueDateComp");
            let emiCompVal = this.template.querySelectorAll(".emiComp");
            var index=event.target.dataset.targetId;
            let toValue=toVal[index].value;
            let fromValue=fromVal[index].value;
            let emiDueDateValue=dueDateVal[index].value;
            let emiCompValue=emiCompVal[index].value;
            if(parseFloat(emiCompValue) < parseFloat(this.nextInterestCom)){
                this.dispatchEvent(ShowToastEvent({
                    title: "Error",
                    message: 'EMI mentioned in period '+fromValue +' is lesser than the interest computed. Please modify EMI or period considered',
                    variant: 'error',
                }));
                return;
            }
            if(parseFloat(emiCompValue) > parseFloat(this.financeAmount)){
                this.dispatchEvent(ShowToastEvent({
                    title: "Error",
                    message: 'EMI mentioned in period '+ fromValue +' is greater than the loan amount. Please modify EMI amount.',
                    variant: 'error',
                }));
                return;
            }

            let seconddate;
            let dateComponents = emiDueDateValue.split('-');
            seconddate = new Date(dateComponents[2], dateComponents[1], dateComponents[0]);
            let emiDate = seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
            this.itemList[parseInt(fromValue)-2].installmentComp = Math.floor(this.nextInstallment);
            this.itemList[parseInt(fromValue)-2].interestComp = Math.floor(this.nextInterestCom);
            this.itemList[parseInt(fromValue)-2].OpenPrincipal = Math.floor(this.nextOpenPrincipal);

            //let itemVal=JSON.stringify(this.itemList.filter(item => !item.hasOwnProperty('sfId') || (item.hasOwnProperty('sfId') && item.sfId != '')));//CISP-23163 or CISP-23150
            //console.log('UNIQUE Item List To Update >>> '+itemVal);
            await addupdateStructuredEMI({ itemList:JSON.stringify(this.itemList),recordId: this.recordId, submittedFalg:false, dealId: null });
            let newItem;

            console.log(toValue,'toValue');
            console.log(this.tenure,'this.tenure');
            console.log(fromValue,'fromValue');

            if(parseInt(toValue)!= parseInt(this.tenure) && parseInt(fromValue) < parseInt(this.tenure)){
                var length=this.itemList.length;
                length=parseInt(length)-1;
                var toMon=this.itemList[length].toMonth ;
                var newFromValue=parseInt(toMon) + 1;
                var emiValue;
                await this.calculateAmounts(parseFloat(emiCompValue),parseFloat(this.itemList[parseInt(fromValue)-2].OpenPrincipal), this.lastdate, seconddate.getFullYear() +'-'+(seconddate.getMonth()) + '-' + seconddate.getDate(),parseInt(toValue));                
                if(newFromValue == parseInt(this.tenure)){
                    emiValue = Math.floor(this.nextInstallment);
                }
                this.lastdate = seconddate;
                ++this.keyIndex;
                newItem = [{ id: this.keyIndex ,fromMonth:newFromValue, toMonth:newFromValue, installments:newFromValue, dueDate:emiDate,emi:(emiValue ? emiValue :""),isDisable:false}];
                console.log(newItem,'newItem');
                await this.getRecentData();
                this.itemList = this.itemList.concat(newItem);
                this.isLoading = false;
                this.disableAddRow = false;
                // this.itemList.forEach(item => {
                //     if(this.tenure == this.itemList.length + 1){
                //         item.isDisable = false;
                //         this.itemList[this.itemList.length-1].isDisable = true;
                //     }
                //    })        
            }
        } else {
            this.isLoading = false;
            this.disableAddRow = false;
        }
    }

    async removeRow(event) {
        try {
        let targetId = event.target.dataset.targetId;
        this.isValueChange = true;
        if(this.itemList.length >= 2){
            // await this.getRecentData(); //Unit Fix
            console.log('targetId',targetId);
            if(this.itemList[targetId].sfId){
                let res = deleteRecord(this.itemList[targetId].sfId);
            }
            const index = this.itemList.findIndex(item => item.id == targetId);
            if (index !== -1) {
                this.itemList.splice(index, 1);
                for (let i = index; i < this.itemList.length; i++) {
                this.itemList[i].id--;
                this.itemList[i].fromMonth--;
                this.itemList[i].toMonth--;
                this.itemList[i].installments--;
                let [date,month, year] = this.itemList[i].dueDate.split('-');
                date = parseInt(date)
                month = parseInt(month);
                year = parseInt(year);
                month--;
                if (month === 0) {
                month = 12;
                year--;
                }
                this.itemList[i].dueDate = `${date}-${month}-${year}`;
                }
            }
            console.log('list',JSON.stringify(this.itemList));
            this.itemList = this.itemList.filter(item => item.hasOwnProperty('emi') && (item.emi != undefined && item.emi != ""));
            let itemVal = JSON.stringify(this.itemList.filter(item => item.hasOwnProperty('sfId') && item.sfId != ''));//CISP-23163
            console.log('DATABase Delete Operation >>'+itemVal);
            let result = await updateStructuredEMI({ itemList:itemVal,recordId: this.recordId });
            // this.itemList.forEach(item => {
            //     if(this.tenure == this.itemList.length + 1){
            //         item.isDisable = false;
            //         this.itemList[this.itemList.length-1].isDisable = true;
            //     }
            //    })    
        }
        } catch (error) {
            console.error(error);
        }
    }

    changeHandlerOnToMonth(event){
        this.isValueChange = true;
        let toVal = this.template.querySelectorAll(".toCmp");   
        var toMon=event.target.value;
        var index=event.target.dataset.targetId;
        let toValue=toVal[index].value;
        var toMonName=event.target.name;
        var fromMon=this.itemList[index].fromMonth;
        var emi=(toMon-fromMon)+1;
        this.itemList[index].installments = emi;
        this.itemList[index].toMonth = toMon;
        if(parseInt(fromMon)>parseInt(toValue)){
            toVal[index].setCustomValidity('ToMonth must be greater than From Month');
          }
          else if(parseInt(toValue)> parseInt(this.tenure)){
            toVal[index].setCustomValidity('ToMonth not be greater than Tenure');
          }else{
            toVal[index].setCustomValidity('');
          }
          toVal[index].reportValidity();
            var toMon=this.itemList[index].toMonth ;
            var newFromValue=parseInt(toMon) + 1;
            let plusOne = parseInt(index) +1;
            var length=this.itemList.length;
            if(length > plusOne){
            this.itemList[plusOne].fromMonth = newFromValue;
            var tonextMon=this.itemList[plusOne].toMonth ;
            var ins=(tonextMon-newFromValue)+1;
            this.itemList[plusOne].installments = ins;
        }
    }
    changeHandlerOnInstallment(event){
        this.isValueChange = true;
        var installment=event.target.value;
        var index=event.target.dataset.targetId;
        var fromMon=this.itemList[index].fromMonth;
        var toMon=fromMon + (installment-1);
        this.itemList[index].toMonth = toMon;
        this.itemList[index].installments = installment;
        
    }
    changeHandlerOnFromMonth(event){
        this.isValueChange = true;
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
    async isInputValid() {
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
        this.disableAddRow = false;
        let emiVal = this.template.querySelectorAll(".emiComp");
        this.isValueChange = true;
        var emi=event.target.value;
        var index=event.target.dataset.targetId;
        this.emiBeforeChange = this.itemList[index].emi;
        this.itemList[index].emi =emi;

        if(parseInt(event.target.value) <0){//CISP-22130
            emiVal[index].setCustomValidity("You can not enter negative value");
        }else{
            emiVal[index].setCustomValidity("");
        }
        emiVal[index].reportValidity();
    }

    removeNextRows(event){try {
        var index=event.target.dataset.targetId;
        if(this.emiBeforeChange && this.itemList[index].emi && this.emiBeforeChange !== this.itemList[index].emi){
            this.emiBeforeChange=null;
            let removeList = this.itemList.splice((parseInt(index)+1));
            let removedList =JSON.parse(JSON.stringify(removeList));
            removedList.forEach(element => {
                if(element.sfId){
                    deleteRecord(element.sfId);
                }
            });
            this.keyIndex = JSON.parse(JSON.stringify(this.itemList)).length-1;            
        }
            
    } catch (error) {
        console.error(error);
    }
    }

    isSubmitDisabled = false;
    structureEMIRecordsCreated = false;
    async saveDataFromHandleSubmit(submitFalg){
        this.isSubmitDisabled = true;
        let isSuccess = false;
        // this.npvCalculation();
        var length=this.itemList.length;
        console.log('length--', this.itemList.length);
        length=parseInt(length)-1;
        let emiCompVal = this.template.querySelectorAll(".emiComp");//CISP-22130 start
        let emiList=[];
         emiCompVal.forEach(number =>{ if(number.value < 0){ emiList.push(number)}});
        console.log('res',emiList.length);
        if(emiList.length >0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please enter the data properly',
                    variant: 'error',
                }),
            );
            return null;
        }//CISP-22130 end
        var lastMonthToVal=this.itemList[length].toMonth;
        if(lastMonthToVal==parseInt(this.tenure)){
        if(this.discreapancyScreen==false){
            var isVal = false;
            var itemVal=JSON.stringify(this.itemList);
            if(this.structureEMIRecordsCreated == false){
            let result = await addupdateStructuredEMI({ itemList:itemVal,recordId: this.recordId, submittedFalg:submitFalg, dealId: null });
            if(result!=null){
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
                        this.dispatchEvent(new CustomEvent('submit'));
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
}