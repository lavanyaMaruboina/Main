import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apex/PersonalDetailsforCAM.Getincomerecordssalaried';
import { NavigationMixin } from 'lightning/navigation';
import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';
import { updateRecord } from 'lightning/uiRecordApi';
import incomeid from '@salesforce/schema/Income_Details__c.Id';
import incomevalue from '@salesforce/schema/Income_Details__c.Income__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import remarks from '@salesforce/schema/Income_Details__c.Remarks__c';
import checked_Entered_Income from '@salesforce/schema/Income_Details__c.Checked_entered_income__c';

export default class Lwc_incomeresorcecmp extends NavigationMixin(LightningElement) {
    activeSections = ['Income source'];
    @api recordId;
    @api appId;
    @api bankno;
    @track incomeidremarks;
    @track incomeremarks;
    @track keylist;
    @track incomefromfi;
    @track CheckedEnteredIncome;
    @api substage;
    @track incomeperfios;
    @track totalsal=0;
    @track salariedacc=[];
    @track incomevals=[];
       @wire(getRecords, { opp: '$recordId', app: '$appId',bankno: '$bankno' }) fetchData(value) {
        const {data,error } = value;        
        if (data) {
            console.log('data of getRecords =>',data);
            if(data.IncomeSalary != null){
                for (let key in data.IncomeSalary) {
                    this.salariedacc.push({ value: data.IncomeSalary[key], key: key });
                    }
            }
           
            if(data.salaryincome != null){
                for (let key in data.salaryincome) {
                    this.incomevals.push({ value: data.salaryincome[key], key: key });
                    this.totalsal= this.totalsal+data.salaryincome[key];
                    }
            }
            if(data.incomefromperfiosSal!=null){
                this.incomeperfios=data.incomefromperfiosSal;
            }
            if(data.salremarks!=null){
                this.incomeremarks=data.salremarks;
            }
            if(data.incomeId!=null){
                this.incomeidremarks=data.incomeId;
            }
            if(data.FIincome!=null){
                this.incomefromfi=data.FIincome;
            }
            if(data.checkedincome!=null){
                this.CheckedEnteredIncome=data.checkedincome;
            }
            }
        else if (error) {
            console.log('error in getRecords=> ',error);
        }
    }

    renderedCallback(){
        if(this.substage){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
         element.disabled = true
           );
      }
    }
    get getincomeavailable(){
        if(Is_Income_Credited_In_Bank_Account__c==true){
            return Yes;
        }else{
            return No;
        }
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                const event = new ShowToastEvent({
                    title: 'Record Updated',
                    variant: 'Success',
                });
                this.dispatchEvent(event);
                console.log('after update', recordInput);
            })
            .catch(error => {
                this.isSpinnerMoving = false;
                console.log('Error in update', error);
            });
    }
    async updateRecordDetailsavg(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                const event = new ShowToastEvent({
                    title: 'Record Updated Please click on Submit',
                    variant: 'Success',
                });
                this.dispatchEvent(event);
                console.log('after update', recordInput);
                return true;
            })
            .catch(error => {
                this.isSpinnerMoving = false;
                console.log('Error in update', error);
            });
    }
    Avgchangestotalincome(event){ 
        const evnt=new CustomEvent('incomechange',{detail:'true'});
        this.dispatchEvent(evnt);
        const oppfields = {};
        oppfields[incomeid.fieldApiName] = event.target.dataset.id;
        oppfields[incomevalue.fieldApiName] = event.target.value * 12;
        this.updateRecordDetailsavg(oppfields);
    }
    async checkPerfiosCondition(){
        var perfiosVal=parseFloat(this.incomeperfios);
        var totalSalVal=parseFloat(this.totalsal);
        var tenPercentLessVal=perfiosVal -((perfiosVal * 10)/100);
        var tenPercentGreaterVal=perfiosVal +((perfiosVal * 10)/100);
       
        if(this.CheckedEnteredIncome==='false' && (totalSalVal > tenPercentGreaterVal || totalSalVal < tenPercentLessVal)){
            
            const evnt=new CustomEvent('itrchange');
            this.dispatchEvent(evnt);
            return true;
        }else{
            return false;
        }
    }
    remarksonchangeitr(event){
        const oppfields = {};
        this.incomeremarks=event.target.value;
        oppfields[incomeid.fieldApiName] = this.incomeidremarks;
        oppfields[remarks.fieldApiName] = this.incomeremarks;
        this.updateRecordDetails(oppfields);
        this.checkPerfiosCondition();
    }
    @api saveIncomedetails(){
       
            const FinalTermFields = {};
            FinalTermFields[incomeid.fieldApiName] = this.incomeidremarks;
            FinalTermFields[checked_Entered_Income.fieldApiName] = true;
            console.log('FinalTerm::'+JSON.stringify(FinalTermFields));
            this.updateRecordDetails(FinalTermFields);        
        
    }
}