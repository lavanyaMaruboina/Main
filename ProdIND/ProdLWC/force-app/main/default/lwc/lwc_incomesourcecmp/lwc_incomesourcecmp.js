import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apex/PersonalDetailsforCAM.Getincomerecords';
import { NavigationMixin } from 'lightning/navigation';
import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';
import { updateRecord } from 'lightning/uiRecordApi';
import incomeid from '@salesforce/schema/Income_Details__c.Id';
import abbconsidered from '@salesforce/schema/Income_Details__c.ABB_to_be_considered__c';
import remarks from '@salesforce/schema/Income_Details__c.Remarks__c';
import incomevalue from '@salesforce/schema/Income_Details__c.Income__c';
import checked_Entered_Income from '@salesforce/schema/Income_Details__c.Checked_entered_income__c';
import retriveFiles from '@salesforce/apex/PersonalDetailsforCAM.retriveFiles';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_incomesourcecmp extends NavigationMixin(LightningElement) {
    activeSections = ['BankStatement','Income source', 'ITR', 'GST'];
    @api recordId;
    @api appId;
    @api substage;
    @track keylist;
    @track incomeidremarks;
    @track incomeremarks;
    @track CheckedEnteredIncome;
    @track ITR=false;
    @track GST=false;
    @track sal=false;
    @track salariedacc=[];
    @track GSTacc=[];
    @track incomeITR=[];
    @track incomeitrid;
    @track incomegstid;
    @track bankdetails=[];
    @track abbdetails=[];
    @track incomeperfios;
    @track totalitr=0;
    @track incomefromfi;
    @track ITRincomevalues=[];
    @track GSTincomevalues=[];
    @track itrchange=false;
    @track gstchange=false;
    @track salchange=false;
    @track isShowModal=false;
    @wire(getRecords, { opp: '$recordId', app: '$appId' }) fetchData(value) {
        const {data,error } = value;        
        if (data) {
            if(data.Incomesalaried!=null){
                this.sal=true;
                for (let key in data.Incomesalaried) {
                    this.salariedacc.push({ value: data.Incomesalaried[key], key: key });
                }
            }
            if(data.IncomeITR!=null){
                this.ITR=true;
                for (let key in data.IncomeITR) {
                    this.incomeITR.push({ value: data.IncomeITR[key], key: key });
                }
            }
            if(data.IncomeGSTval!=null){
                this.GST=true;
                for (let key in data.IncomeGSTval) {
                    this.GSTacc.push({ value: data.IncomeGSTval[key], key: key });
                }
            }

            if(data.ITRincome!=null){
                for (let key in data.ITRincome) {
                    if(data.ITRincome[key]){
                        this.ITRincomevalues.push({ value: data.ITRincome[key], key: key });
                        this.totalitr= this.totalitr+data.ITRincome[key];
                    }
                }
            }

            if(data.incomefromperfiosITR!=null){
                this.incomeperfios=data.incomefromperfiosITR;
            }
            if(data.itrremarks!=null){
                    this.incomeremarks=data.itrremarks;
            }
            if(data.incomeId!=null){
                    this.incomeidremarks=data.incomeId;
            }
            if(data.gstId!=null){
                this.incomegstid=data.gstId;
            }
        if(data.itrId!=null){
            this.incomeitrid=data.itrId;
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
    Abbchanged(event) {
        //alert(event.target.dataset.id);
        let feedback = this.template.querySelector('.AbbtobeConsider');
        console.log('feedback', feedback);
        if (feedback) {
            if (/^[0-9]*$/.test(event.target.value)) {
                feedback.setCustomValidity('');
                //this.inputWrapper[event.target.name].value = event.target.value;
                const oppfields = {};
                oppfields[incomeid.fieldApiName] = event.target.dataset.id;
                oppfields[abbconsidered.fieldApiName] = event.target.value;
                this.updateRecordDetails(oppfields);
            } else {
                feedback.setCustomValidity('Please enter Numbers only');
            }
            feedback.reportValidity();
        }
    }
    async checkPerfiosCondition() {
        var perfiosVal = parseFloat(this.incomeperfios);
        var totalSalVal = parseFloat(this.totalitr);
        var tenPercentLessVal = perfiosVal - ((perfiosVal * 10) / 100);
        var tenPercentGreaterVal = perfiosVal + ((perfiosVal * 10) / 100);

        if(this.CheckedEnteredIncome==='false' && (totalSalVal > tenPercentGreaterVal || totalSalVal < tenPercentLessVal)){
            this.isShowModal=true;
        }else{
            return false;
        }

    }
    remarksonchangeitr(event){
        this.itrchange=true;
        const oppfields = {};
        this.incomeremarks=event.target.value;
        oppfields[incomeid.fieldApiName] = this.incomeidremarks;
        oppfields[remarks.fieldApiName] = this.incomeremarks;
        this.updateRecordDetails(oppfields);
        this.checkPerfiosCondition();
    }
    Avgchangestotalincome(event){
        const oppfields = {};
        oppfields[incomeid.fieldApiName] = event.target.dataset.id;
        oppfields[incomevalue.fieldApiName] = event.target.value * 12;
        this.updateRecordDetailsavg(oppfields);
        const evnt=new CustomEvent('incomechange',{detail:'true'});
        this.dispatchEvent(evnt);
    }
    handleonincomechange(){
        const evnt=new CustomEvent('incomechange',{detail:'true'});
        this.dispatchEvent(evnt);
    }



    saveIncomedetails(){
        const FinalTermFields = {};
        FinalTermFields[incomeid.fieldApiName] = this.incomeidremarks;
        FinalTermFields[checked_Entered_Income.fieldApiName] = true;
            console.log('FinalTerm::'+JSON.stringify(FinalTermFields));
        this.updateRecordDetails(FinalTermFields);
            this.isShowModal=false;
    }
    previewImage(event) {
        console.log('income record id => ',event.target.dataset.id);
        retriveFiles({incomeObjId : event.target.dataset.id})
            .then(result => {
                console.log('file id in retriveFiles => ', result);
            if(result !== null){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state: {
                            selectedRecordId: result
                        }
                    });
            }else{
                    const event = new ShowToastEvent({
                        title: 'Warning',
                    message : 'No bank statement is available for this income source.',
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
            })
        .catch(error =>{
                console.log('error in retriveFiles =>', error);
            })
    }
    previewImageitr(event) {
        console.log('income record id => ',event.target.dataset.id);
        retriveFiles({incomeObjId : event.target.dataset.id})
            .then(result => {
                console.log('file id in retriveFiles => ', result);
            if(result !== null){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state: {
                            selectedRecordId: result
                        }
                    });
            }else{
                    const event = new ShowToastEvent({
                        title: 'Warning',
                    message : 'No ITR is available for this income source.',
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
            })
        .catch(error =>{
                console.log('error in retriveFiles =>', error);
            })
    }
     renderedCallback(){
        if(this.substage){
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
                element.disabled = true
            );
        }
    }
    previewImagegst(event) {
        console.log('income record id => ',event.target.dataset.id);
        retriveFiles({incomeObjId : event.target.dataset.id})
            .then(result => {
                console.log('file id in retriveFiles => ', result);
            if(result !== null){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state: {
                            selectedRecordId: result
                        }
                    });
            }else{
                    const event = new ShowToastEvent({
                        title: 'Warning',
                    message : 'No GST is available for this income source.',
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
            })
        .catch(error =>{
                console.log('error in retriveFiles =>', error);
            })
    }
    hideModalBox(){
        this.isShowModal=false;
    }
}