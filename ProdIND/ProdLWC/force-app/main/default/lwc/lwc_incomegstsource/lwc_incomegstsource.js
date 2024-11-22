import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apex/PersonalDetailsforCAM.GetincomerecordsGST';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import remarks from '@salesforce/schema/Income_Details__c.Remarks__c';
import incomeid from '@salesforce/schema/Income_Details__c.Id';
import incomevalue from '@salesforce/schema/Income_Details__c.Income__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checked_Entered_Income from '@salesforce/schema/Income_Details__c.Checked_entered_income__c';

export default class Lwc_incomegstsource extends NavigationMixin(LightningElement) {
    activeSections = ['Income source'];
    @api recordId;
    @api appId;
    @api gstno;
    @track keylist;
    @track incomeidremarks;
    @track incomeremarks;
    @track incomeperfios;
    @track totalgst=0;
    @track CheckedEnteredIncome;
    @api substage;
    @track gstacc=[];
    @track incomefromfi;
    @track incomevals=[];
       @wire(getRecords, { opp: '$recordId', app: '$appId',gstno: '$gstno' }) fetchData(value) {
        const {data,error } = value;        
        if (data) {
            console.log('data of getRecords =>',data);
            if(data.IncomeGST != null){
                for (let key in data.IncomeGST) {
                    this.gstacc.push({ value: data.IncomeGST[key], key: key });
                    }
            }
           
            if(data.GSTincome != null){
                for (let key in data.GSTincome) {
                    this.incomevals.push({ value: data.GSTincome[key], key: key });
                    this.totalgst= this.totalgst+data.GSTincome[key];
                    }
            }
            if(data.incomefromperfiosGST!=null){
                this.incomeperfios=data.incomefromperfiosGST;
            }
            if(data.gstremarks!=null){
                this.incomeremarks=data.gstremarks;
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

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                this.isSpinnerMoving = false;
                const event = new ShowToastEvent({
                    title: 'Record Updated',
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
    renderedCallback(){
        if(this.substage){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
         element.disabled = true
           );
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
    Avgchangestotalincome(event){
        const evnt=new CustomEvent('incomechangechild',{detail:'true'});
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
            const evnt=new CustomEvent('gstchange');
        this.dispatchEvent(evnt);
            return true;
        }else{
            return false;
        }
    }
    @api saveIncomedetails(){
       
        const FinalTermFields = {};
        FinalTermFields[incomeid.fieldApiName] = this.incomeidremarks;
        FinalTermFields[checked_Entered_Income.fieldApiName] = true;
        console.log('FinalTerm::'+JSON.stringify(FinalTermFields));
        this.updateRecordDetails(FinalTermFields);        
    
}
}