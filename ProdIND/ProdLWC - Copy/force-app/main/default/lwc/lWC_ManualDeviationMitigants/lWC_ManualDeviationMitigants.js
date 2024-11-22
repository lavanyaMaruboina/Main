import { LightningElement, wire,track,api } from 'lwc';

import getdeviMasterRecords from '@salesforce/apex/IND_CAMWithoutSharing.getdeviMasterRecords';
import saveDeviationRec from '@salesforce/apex/lWC_ManualDeviationMitigantsCntrl.saveDeviationRec';
import fetchManulaDeviationRecords from '@salesforce/apex/lWC_ManualDeviationMitigantsCntrl.fetchManulaDeviationRecords';
import fetchMitigantRecords from '@salesforce/apex/lWC_ManualDeviationMitigantsCntrl.fetchMitigantRecords';

import getmitigantsMasterRecords from '@salesforce/apex/IND_CAMWithoutSharing.getmitigantsMasterRecords';
import saveMitigantRec from '@salesforce/apex/lWC_ManualDeviationMitigantsCntrl.saveMitigantRec';
import getOpportunity from '@salesforce/apex/lWC_ManualDeviationMitigantsCntrl.getOpportunity';
import sendApprovalCAMReqAPI from '@salesforce/apex/IND_CAMWithoutSharing.sendApprovalCAMReqAPI';
import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';
import { deleteRecord } from 'lightning/uiRecordApi';
import isJustificationProvided from '@salesforce/apex/CAMApprovalLogController.isJustificationProvided';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_ManualDeviationMitigants extends LightningElement {
    //For Master Deviation
    @track isSpinner = false;
    @api isRevokedLoanApplication;
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @track isMitigantDisabled = false;
    @track dMobjRow = [];
    @track isManualDeviation = false;
    masterDeviationList = [];
    devialionNameOption =[];

    //For Master Mitigants
    @track mMobjRow = [];
    @track isMitigants = false;
    masterMitigantsList = [];
    mitigantsNameOption =[];

    error;
    typeOptions;
    industryOptions;

    @track isManualModalOpen = false;
    //@api camRecId ='a0HC2000000A4LhMAK';
    @api camRecId;
    @api isSubmitforApproval = false;
    @api disableChildButton;
    @api recordId;
    _isCAMApproved;
    @api set isCAMApproved(value){
        this._isCAMApproved = value;
    }
    get isCAMApproved(){
        return this._isCAMApproved;
    }
    _disableDeviationBtn;
    @api set disableDeviationBtn(value){
        this._disableDeviationBtn = value;
    }
    get disableDeviationBtn(){
        return this._disableDeviationBtn;
    }
    get getModalHeader(){
        return  (this.isManualDeviation == true) ? 'Manual Deviation' : (this.isMitigants == true)  ? 'Mitigant' : 'Update';
    }
    @api fromParent;//SFTRAC-163
    disableEveryThing = false;
    async connectedCallback() {
        await getOpportunity({'recordId' : this.recordId}).then(result=>{
            if(result){
                if(result.StageName != 'Credit Processing' || result.Sub_Stage__c != 'CAM and Approval Log'){
                    this.isMitigantDisabled = true;
                    this.isCAMApproved = true;
                }
            }
        }).catch(error=>{});
    }
    async init(){
        this.dMobjRow = [];
        this.mMobjRow = [];
        try{
            let manualDeviationList = await fetchManulaDeviationRecords({'camRecId' : this.camRecId});
            if(manualDeviationList && manualDeviationList.length > 0){
                for (let index = 0; index < manualDeviationList.length; index++) {
                    const element = manualDeviationList[index];
                    this.dMobjRow.push({
                        'Parameter' : element.Deviation_Description__c,
                        'Deviation_Id' : element.DeviationID__c,
                        'Source' : element.Source__c,
                        'Deviation_Level' : element.Deviation_Level__c,
                        'isDisabled':true,
                        'recordId':element.Id,
                    });
                }
            }else{
                this.dMobjRow = [{
                    'Parameter' : null,
                    'Deviation_Id' : null,
                    'Source' : null,
                    'Deviation_Level' : null,
                    'isDisabled' : false,
                    'recordId':0,
                }];
            }
            let mtigantList = await fetchMitigantRecords({'camRecId' : this.camRecId});
            if(mtigantList && mtigantList.length > 0){
                for (let index = 0; index < mtigantList.length; index++) {
                    const element = mtigantList[index];
                    this.mMobjRow.push({
                        'Description' : element.Description__c,
                        'Name' : element.Name,
                        'isDisabled':true,
                        'recordId':element.Id,
                        'Id': await this.masterMitigantsList.find(item => (item.Description === element.Description__c && item.Name === element.Name)).Id,
                    });
                }
            }else{
                this.mMobjRow = [{
                    'Description' : null,
                    'Name' : null,
                    'isDisabled': false,
                    'recordId':0,
                    'Id':null,
                }];
            }
        }catch{error}{}
    }

    //Wire method to get Master deviation records
    @wire(getdeviMasterRecords)
    alldeviMasterRecords(result){
        let data = result.data;
        let error = result.error;
        if(data){
            if(data.length>0){
                this.masterDeviationList = data;
                data.forEach(val => {
                    this.devialionNameOption = [...this.devialionNameOption, { value: val.Parameter , label: val.Parameter }];
                });
            }
        }else if(error){
        }
    }

    handleAddRow() {
        let newEntry = {
            'Parameter' : null,
            'Deviation_Id' : null,
            'Source' : null,
            'Deviation_Level' : null,
            'recordId' : this.dMobjRow ? this.dMobjRow.length : 0,
        };
        if(this.dMobjRow && this.dMobjRow.length == this.devialionNameOption.length){
            this.showMessageToast("You can't add move rows","Info","info");
        }else if ( this.dMobjRow ) {
            this.dMobjRow = [...this.dMobjRow, newEntry ];
        } else {
            this.dMobjRow = [ newEntry ];
        }
    }

    handleRemoveRow( event ) {
        const recordid = event.target.dataset.recordId;
        if(recordid && recordid.length < 3){
            this.dMobjRow = this.dMobjRow.filter((item, index) => item.recordId != parseInt(recordid));
        }else{
            deleteRecord(recordid).then(()=>{
                this.dMobjRow = this.dMobjRow.filter((item, index) => item.recordId != recordid);
            }).catch(error=>{})
        }
    }

    handleChange( event ) {
        let strIndex = event.target.dataset.recordId;

        let currentRec = this.dMobjRow[strIndex];
        
        const foundItem = this.masterDeviationList.find(item => item.Parameter === event.target.value);
        const duplicateItem = this.dMobjRow.find(item => item.Parameter === event.target.value);

        if(duplicateItem){
            this.showMessageToast('You are trying to add duplicate Deviation','Error','Error');
        }else{
            if (foundItem) {
                currentRec.Deviation_Id = foundItem.Deviation_Id;
                currentRec.Parameter = foundItem.Parameter;
                currentRec.Source = foundItem.Source;
                currentRec.Deviation_Level = foundItem.Deviation_Level;
            }
            this.dMobjRow[strIndex] = currentRec;
            this.dMobjRow = [...this.dMobjRow];
        }
        
    }

    async saveRows() {
        this.isSpinner = true;
        let foundItem = await this.dMobjRow.find(item =>  (item.Parameter == null));
        if(this.dMobjRow && this.dMobjRow.length == 0){
            this.showMessageToast('Add any devivation or close the modal!','Warning','warning');
            this.isSpinner = false;
        }else if(foundItem){
            this.showMessageToast('Fill mandatory fields or close the modal!','Warning','warning');
            this.isSpinner = false;
        }else{
            saveDeviationRec({ listofDeviation : this.dMobjRow, camRecId : this.camRecId}).then(result => {
                this.isManualModalOpen = false;
                this.isManualDeviation = false;
                this.isSpinner = false;
                if(result == 'Successful'){
                    this.showMessageToast('Deviation Successfull Saved','Success','Success');
                }else{
                    this.showMessageToast(`${result}`,'Info','info');
                }
                }).catch(error => {
                    this.isManualModalOpen = false;
                    this.isManualDeviation = false;
                    this.isSpinner = false;
                    this.showMessageToast('Deviation record failed to Saved','Error','error');
            });
        }
    }

    @wire(getmitigantsMasterRecords)
    allmitigMasterRecords(result){
        let data = result.data;
        let error = result.error;
        if(data){
            if(data.length>0){
                this.masterMitigantsList = data;
                data.forEach(val => {
                    this.mitigantsNameOption = [...this.mitigantsNameOption, { value: val.Id , label: val.Name }];
                });
            }
        }else if(error){}
    }

    handleAddRowMitigant() {
        let newMitiEntry = {
            'Description' : null,
            'Name' : null,
            'recordId' : this.mMobjRow ? this.mMobjRow.length : 0,
            'Id' : null,
        };

        if(this.mMobjRow && this.mMobjRow.length == this.mitigantsNameOption.length){
            this.showMessageToast("You can't add move rows","Info","info");
        }else if ( this.mMobjRow ) {
            this.mMobjRow = [...this.mMobjRow, newMitiEntry ];
        } else {
            this.mMobjRow = [ newMitiEntry ];
        }
    }

    handleRemoveRowMitigant( event ) {
        const recordid = event.target.dataset.recordId;
        if(recordid && recordid.length < 3){
            this.mMobjRow = this.mMobjRow.filter((item, index) => item.recordId != parseInt(recordid));
        }else{
            deleteRecord(recordid).then(()=>{
                this.mMobjRow = this.mMobjRow.filter((item, index) => item.recordId != recordid);
            }).catch(error=>{
                this.showMessageToast("Something went wrong!","Error","error");
            })
        }
    }

    handleMitigantChange( event ) {
        let strIndex = event.target.dataset.recordId;

        let currentRec = this.mMobjRow[strIndex];
        
        const duplicateItem = this.mMobjRow.find(item => item.Id === event.target.value);

        if(duplicateItem){
            this.showMessageToast('You are trying to add duplicate Mitigants','Error','Error');
        }else{
            const foundItem = this.masterMitigantsList.find(item => item.Id === event.target.value);
            if (foundItem) {
                currentRec.isDisabled = true;
                currentRec.Description = foundItem.Description;
                currentRec.Name = foundItem.Name;
                currentRec.Id = foundItem.Id;
            }
            this.mMobjRow[strIndex] = currentRec;
            this.mMobjRow = [...this.mMobjRow];
        }
    }

    async saveMitigantRows() {
        this.isSpinner = true;
        let foundItem = await this.mMobjRow.find(item =>  (item.Name == null));
        if(this.mMobjRow && this.mMobjRow.length == 0){
            this.showMessageToast('Add any mitigant or close the modal!','Warning','warning');
            this.isSpinner = false;
        }else if(foundItem){
            this.showMessageToast('Fill mandatory fields or close the modal!','Warning','warning');
            this.isSpinner = false;
        }else{
            saveMitigantRec({ listofMitigant : this.mMobjRow, camRecId : this.camRecId}).then(result => {
                this.isManualModalOpen = false;
                this.isMitigants = false;
                this.isSpinner = false;
                this.showMessageToast('Mitigant Successfull Saved','Success','Success');
                }).catch(error => {
                    console.log('error ',error);
                    this.showMessageToast('Mitigant record failed to Saved','Error','error');
            });
        }
    }

    // Mitigants Logic End
    async handleManualDeviation(){
        await this.init();
        this.isManualModalOpen = true;
        this.isManualDeviation = true;
        this.isMitigants = false;
        this.isSubmitforApproval = false;
        //this.handleAddRow();
    }
    async handleMitigants(){
        await this.init();
        this.isManualModalOpen = true;
        this.isManualDeviation = false;
        this.isMitigants = true;
        this.isSubmitforApproval = false;
    }

    get manualDeviation() {
        let options = [
            { label: 'MD1', value: 'MD1' },
            { label: 'MD2', value: 'MD2' },
            
        ];
        return options;
    }

    get mitigantsOpp() {
        let options = [
            { label: 'M1', value: 'M1' },
            { label: 'M2', value: 'M2' },
            
        ];
        return options;
    }

    closeModal() {
        this.isManualModalOpen = false;
        this.isManualDeviation = false;
        this.isMitigants = false;
        this.isSubmitforApproval = false;
        this.dMobjRow = [];
        this.mMobjRow = [];
    }

    async handleSubmitforApproval(){
        let res = await isJustificationProvided({'camId' : this.camRecId})
        if(!res){
            this.dispatchEvent(new ShowToastEvent({title: 'Warning',message: "Please enter justification remarks for all deviations!",variant: 'warning',}))
        }else{
            this.isSubmitforApproval = true;
            sendApprovalCAMReqAPI({ camRecId : this.camRecId}).then(response => {
                if (response) {
                    response.forEach(emailRequestWrapper => {
                        doEmailServiceCallout({ emailService: JSON.stringify(emailRequestWrapper) }).then(result => {
                            result = JSON.parse(result);
                            if (result && result.response && result.response.status == 'SUCCESS') {
                                this.showMessageToast('Email Successfull sent','Success','Success');
                                //SFTRAC-163
                                if(this.fromParent){
                                    const selectEvent = new CustomEvent('approvalsuccess', {
                                        detail: true
                                    });
                                    this.dispatchEvent(selectEvent);
                                }
                            }
                        }).catch(error => {
                            this.showMessageToast('Email Not sent, please try after sometime or contact Admin','Error','Error');
                        });   
                    })   
                }
            }).catch(error => {console.log('error in email sendApprovalCAMReqAPI ',error);});
        }
    }

    showMessageToast(message, title, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
    get fromNotParent(){
        return !this.fromParent;
    }
}