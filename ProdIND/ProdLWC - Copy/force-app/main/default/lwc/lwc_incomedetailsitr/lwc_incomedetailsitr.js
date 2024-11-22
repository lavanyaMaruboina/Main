import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apex/PersonalDetailsforCAM.getincomedetailborrower';
import submitrec from '@salesforce/apex/PersonalDetailsforCAM.Submithandleritr';
import fetchincomes from '@salesforce/apex/PersonalDetailsforCAM.FetchIncomes';
import fetchavginc from '@salesforce/apex/PersonalDetailsforCAM.fetchavginc';
import Itrfile from '@salesforce/apex/PersonalDetailsforCAM.retriveFilesitr';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import Gstfile from '@salesforce/apex/PersonalDetailsforCAM.retriveFilesgst';
import AppId from '@salesforce/label/c.AppId';
import income_ID_Field from '@salesforce/schema/Income_Details__c.Id';
import checked_Entered_Income from '@salesforce/schema/Income_Details__c.Checked_entered_income__c';
export default class Lwc_incomedetailsitr extends NavigationMixin(LightningElement) {
    activeSections = ['BankStatement','Income source', 'ITR', 'GST'];
    @api recordId;
    @api appId;
    @api bankname;
    @api bankrecords;
    @track lstRecords = [];
    @track lstRecordsITR = [];
    @track lstRecordsGST = [];
    @track incomesalaried = [];
    @track incomeITR = [];
    @track incomeGST = [];
    @track totalincomesal = [];
    @track totalincomeITR;
    @track fetchavgincome=true;
    @track fetchavgincomeval=true;
    @track primaryincome=false;
    @track totalincomeGST;
    @track incomeperfios;
    @track incomeId;
    @track itr;
    @track filenotfound = false;

    @track filenotfoundgst = false;
    @track filenotfounditr = false;
    @track sal;
    @track gst;
    @track filesvalue;
    @track filesvalueitr;
    @track filesvaluegst;
    @track incomevalue;
    @track remarksGST; 
    @track remarksitr;
    @track CheckedEnteredIncome;
    @track Cust;
    @track remarksincome;
    @track isShowModal=false;

    @wire(getRecords, { opp: '$recordId', app: '$appId' }) fetchData(value) {
        const {data,error } = value;        
        if (data) {
            console.log('data of getRecords =>',data);
            for (let key in data) {
                if (key == "Salaried") {
                    var conts = data[key];
                    for (var keys in conts) {
                        var dataval = conts[keys];
                        for (var keyval in dataval) {
                            this.lstRecords.push({ value: dataval[keyval], key: keyval });
                            if(keyval=='primaryinc' && dataval[keyval]=='true'){
                                this.primaryincome=true;
                            }
                        }
                    }
                    this.sal = true;
                    
                } else if (key == "ITR") {
                    var conts = data[key];
                    for (var keys in conts) {
                        var dataval = conts[keys];
                        for (var keyval in dataval) {
                            this.lstRecordsITR.push({ value: dataval[keyval], key: keyval });
                        }
                    }
                    this.itr = true;
                } else if (key == "GST") {
                    var conts = data[key];
                    for (var keys in conts) {
                        var dataval = conts[keys];
                        for (var keyval in dataval) {
                            this.lstRecordsGST.push({ value: dataval[keyval], key: keyval });
                        }
                    }
                    this.gst = true;
                }
            }
            this.fetchincomesmethod();
        }
        else if (error) {
            console.log('error in getRecords=> ',error);
            this.lstRecords = [];
        }
    }
    Avgchangestotalincome(event) {

    }

    @api fetchincomesmethod() {
        fetchincomes({ 'opp': this.recordId, 'app': this.appId, 'bank': this.bankname })
            .then(data => {
                console.log('data of fetchincomes =>',data);
                for (let key in data) {
                    if (key == "salaried") {
                        this.incomesalaried.push({ value: data[key], key: key });
                    }
                    if (key == "ITR") {
                        this.incomeITR.push({ value: data[key], key: key });
                    }
                    if (key == "GST") {
                        this.incomeGST.push({ value: data[key], key: key });
                    }
                    if (key == "totalincome") {
                        var con = data[key];
                        for (var keys in con) {
                            this.totalincomesal = con[keys];
                        }
                    }
                    if (key == "totalitr") {
                        var con = data[key];
                        for (var keys in con) {
                            this.totalincomeITR = con[keys];
                        }
                    }
                    if (key == "totalgst") {
                        var con = data[key];
                        for (var keys in con) {
                            this.totalincomeGST = con[keys];
                        }
                    }
                    if (key == "incomeperfios") {
                        var con = data[key];
                        for (var keys in con) {
                            this.incomeperfios = con[keys];
                        }
                    }
                    if (key == "incomeId") {
                        var con = data[key];
                        for (var keys in con) {
                            this.incomeId = con[keys];
                        }
                    }
                    if (key == "CheckedEnteredIncome") {
                        var con = data[key];
                        for (var keys in con) {
                            this.CheckedEnteredIncome = con[keys];
                        }
                    }
                }
            })
            .catch(error => {
                console.log('error in fetchincomes => ',error);
            });
    }

    // @wire(Itrfile, { applicationId: '$recordId', app: '$appId' })
    // wiredResult({ data, error }) {
    //     console.log('itr file data => ', data);
    //     if (data === null) {
    //         this.filenotfounditr = true;
    //         console.log('this.filenotfound', data);
    //     } else {
    //         this.filesvalueitr = data;
    //     }
    //     if (error) {
    //         console.log('error in Itrfile =>',error);
    //     }
    // }

    connectedCallback(){
        console.log('application id and applicant id =>',this.recordId , ' ', this.appId);
        Itrfile({applicationId: this.recordId, app: this.appId})
        .then(result => {
            console.log('result of itr file => ',result);
            if(result !== null){
                this.filesvalueitr = result;
            }
        })
        .catch(error =>{
            console.log('error in itr file ', error);
        })

        fetchavginc({opp: this.recordId})
        .then(result => {
            console.log('result of avginc => ',result);
            if(result !== null){
                this.fetchavgincomeval = result;
            }
        })
        .catch(error =>{
            console.log('error in itr file ', error);
        })
    }

    @wire(Gstfile, { applicationId: '$recordId', app: '$appId' })
    wiredResult({ data, error }) {
        console.log('gst file data =>', data);
        if (data === null) {
            this.filenotfoundgst = true;
            console.log('this.filenotfound', data);
        } else {
            this.filesvaluegst = data;
        }
        if (error) {
            console.log('error in gst file =>',error);
        }
    }

    @api handlesubmitsoffer() {
        if (this.sal == true) {
            console.log('this.remarksincome =>' + this.remarksincome);
            submitrec({ 'application': this.recordId, 'income': this.remarksincome, 'sal': true, 'itr': false, 'gst': false })
                .then(result => {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'Success',
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: '' + error,
                        variant: 'Error',
                    });
                    this.dispatchEvent(event);
                });
        }
        if (this.itr == true) {
            submitrec({ 'application': this.recordId, 'app': this.appId, 'income': this.remarksitr, 'sal': false, 'itr': true, 'gst': false })
                .then(result => {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'Success',
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: '' + error,
                        variant: 'Error',
                    });
                    this.dispatchEvent(event);
                });
        }
        if (this.gst == true) {
            submitrec({ 'application': this.recordId, 'app': this.appId, 'income': this.remarksGST, 'sal': false, 'itr': false, 'gst': true })
                .then(result => {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'Success',
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: '' + error,
                        variant: 'Error',
                    });
                    this.dispatchEvent(event);
                });
        }
    }

    remarksonchangeincome(event) {
        this.remarksincome = event.target.value;
        const evnt=new CustomEvent('remarkchange',{detail:'true'});
        this.dispatchEvent(evnt);
    }

    remarksonchangegst(event) {
        this.remarksGST = event.target.value;
    }
    
    remarksonchangeitr(event) {
        this.remarksitr = event.target.value;
    }

    previewImageitr(event) {
        console.log('itr file record id => ',event.target.dataset.id);
        if(event.target.dataset.id === null || event.target.dataset.id === undefined ){
            const event = new ShowToastEvent({
                title: 'Warning',
                message : 'No ITR document is available for this income source.',
                variant: 'warning',
            });
            this.dispatchEvent(event);
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: event.target.dataset.id
                }
            })
        }
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
    previewImagegst(event) {
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }
    @api checkPerfiosCondition(){
        var perfiosVal=parseFloat(this.incomeperfios);
        var totalSalVal=parseFloat(this.totalincomesal);
        var tenPercentLessVal=perfiosVal -((perfiosVal * 10)/100);
        var tenPercentGreaterVal=perfiosVal +((perfiosVal * 10)/100);
       
        if(this.CheckedEnteredIncome==='false' && (totalSalVal > tenPercentGreaterVal || totalSalVal < tenPercentLessVal)){
            return true;
        }else{
            return false;
        }
    }
    Abbchanged(event) {
        this.abbtoconsider = event.target.value;
            this.submitclick=false;
            this.onchangeclick = true;
    }

    CoAbbchanged(event) {
        this.Coabbtoconsider = event.target.value;
        this.submitclick = false;
        this.onchangeclick = true;
    }
    @api saveIncomedetails(){
        const FinalTermFields = {};
        FinalTermFields[income_ID_Field.fieldApiName] = this.incomeId;
        FinalTermFields[checked_Entered_Income.fieldApiName] = true;
        console.log('FinalTerm::'+JSON.stringify(FinalTermFields));
        this.updateRecordDetails(FinalTermFields);
        
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
               this.fetchincomesmethod();
                return true;
            })
            .catch(error => {
               console.log('Error in update', error); });
    }
    
}