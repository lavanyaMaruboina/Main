import { LightningElement,api,wire,track } from 'lwc';
import getVehicleDetails from '@salesforce/apex/FinalTermscontroller.getVehicleDetails';
import getFinalTermSuccessApis from '@salesforce/apex/FinalTermscontroller.getFinalTermSuccessApis';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import SUB_STAGE_FEILD from '@salesforce/schema/Opportunity.Sub_Stage__c';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import { NavigationMixin } from 'lightning/navigation';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import {getRecord,updateRecord,getFieldValue} from 'lightning/uiRecordApi';
import FinalTerms from '@salesforce/label/c.FinalTerms';
import isGotoNextScreen from '@salesforce/apex/FinalTermscontroller.isGotoNextScreen';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
const fields = [SUB_STAGE_FEILD];
export default class Lwc_TF_FinalTermsScreen extends NavigationMixin(LightningElement) {
    @api recordid;
    @api isRevokedLoanApplication;
    @api activetab;
    @api tabValue;
    @api checkLeadAccess;
    @api currentStage;
    vehicleDetails;
    numberOfVehicles;
    finaltermSucess;
    isEnableNext = false;//SFTRAC-84
    isCreditProcessing = false;//SFTRAC-84
    @wire(getRecord, { recordId: "$recordid", fields })
    loanApplicationData;
    activeVehicle = [];
    async connectedCallback(){console.log('tabValue sftrac',this.tabValue,this.currentStage,this.activetab);
        this.isCreditProcessing = this.currentStage == 'Credit Processing'?true:false; 
        await getVehicleDetails({loanApplicationId: this.recordid})
        .then(result => {
            console.log('## result',JSON.parse(JSON.stringify(result)));
            if(result){
                this.vehicleDetails = result;
                this.numberOfVehicles = result.length;
                for (let index = 0; index < result.length; index++) {
                    const element = result[index];
                    if(element.Change_Pay_IN_Pay_OUT__c){
                        this.activeVehicle.push(element.Id);
                    }
                }
            }
        });
    }
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    switchScreen(event){
        let nextStage = event.detail;
        this.dispatchEvent(new CustomEvent('submitnavigation', {
            detail: nextStage
        }));
    }
    async updateRecordDetails(fields) { 
        let result = false;
        const recordInput = {
            fields
        };
        await updateRecord(recordInput).then(() => {
            result = true;
        }).catch(error => {
            console.log('error : ', error);
            this.showToast("Error", 'Data not Saved', 'error');
            result = false;
        });
        return result;
    }
    callLoanApplicationHistory(nextStage) {
        getLoanApplicationHistory({
            loanId: this.recordid,
            stage: 'Final Terms',
            nextStage: nextStage
        }).then(response => {
            if (response) {
                this.navigateToHomePage();
            } else {
                //window.location.reload();
                this.dispatchEvent(new CustomEvent('submitnavigation', {
                    detail: nextStage
                }));
            }
        });
    }
    navigateToHomePage() {
        isCommunity().then(response => {
            if (response) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'home'
                    },
                });
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Home'
                    }
                });
            }
        })
    }            
    handleFinaltermAllApiSucess(event){
        console.log('handleFinaltermAllApiSucess');
        let nextStage = 'Offer Screen';
        const oppFields = {};
        oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        oppFields[STAGENAME.fieldApiName] = nextStage;
        oppFields[LASTSTAGENAME.fieldApiName] = nextStage;
        let result = this.updateRecordDetails(oppFields);
        if(result){
            this.callLoanApplicationHistory(nextStage);
        }
    }
    get isNotCreditProcessing(){
        return this.currentStage!=='Credit Processing';
    }
    handleInsurancevaleve(event){
        const evnts = new CustomEvent('insurancevaleve', {
			detail: event.detail
		});
		this.dispatchEvent(evnts);
    }
    async handleOnfinishNext(event){
        try{
            console.log('## called 1',this.subStage);
            if(this.subStage && this.subStage !== FinalTerms){
               // this.dispatchEvent(new CustomEvent('navigatetoinsuraancetab'));
                this.dispatchEvent(new CustomEvent('insurancevaleve'));
            }else{
                let result = await isGotoNextScreen({loanApplicationId: this.recordid});
                console.log('r' + result);
                if(result){
                    this.dispatchEvent(new CustomEvent('submitnavigation', {
                        detail:FinalTerms
                    }));
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Please click on check eligibility button first',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                }
            }
        }catch(e){
            console.log('## exception', e);
        } 
    }
    get subStage() {
        return getFieldValue(this.loanApplicationData.data, SUB_STAGE_FEILD);
    }

    //SFTRAC-2243 Start
    @track showFileUploadAndView=false;
    viewUploadViewFloater(){ this.showFileUploadAndView=true; }
    closeUploadViewFloater(event){ this.showFileUploadAndView=false; }
    //SFTRAC-2243 End
}