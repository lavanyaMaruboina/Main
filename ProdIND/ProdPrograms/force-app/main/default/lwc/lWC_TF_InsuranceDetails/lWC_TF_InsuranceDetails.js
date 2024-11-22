import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getAssetTabList from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getAssetTabList';
import isApplicantInsuranceApplicable from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.isApplicantInsuranceApplicable';
import fetchOppourtunityData from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchOppourtunityData';
import SUB_STAGE_FIELD from '@salesforce/schema/Opportunity.Sub_Stage__c';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import updateVehicleDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.updateVehicleDetails';


export default class LWC_TF_InsuranceDetails extends NavigationMixin(LightningElement) {
    @api isRevokedLoanApplication;
    @api recordId;
    @api isCalledFromL1;
    @api currentStage;
    @api isCalledFromL2;
    @track _activeTab;
    @api set activeTab(value){
        this._activeTab = value;
        this.checkApplicantEligibility();
    }
    get activeTab(){
        return this._activeTab;
    }
    @api tablength;
    @api applicantId;
    isdisabled;
    @track showChildComponent = false;

    @track activeTabId
    @track assetTabList = [];
    assetLength;
    lastItem;
    nonIndividual = false;
    enableNext = false;
    stageName;
    subStage;

    async connectedCallback(){
        await fetchOppourtunityData({ loanApplicantionId: this.recordId })
        .then(result => {
            this.customerType = result[0].Customer_Type__c;
            this.productType = result[0].Product_Type__c;
            this.stageName = result[0].StageName;
            this.subStage = result[0].Sub_Stage__c;
            if(this.customerType =='Non-Individual' && this.productType == 'Tractor'){
                this.nonIndividual = true;
            }
        });
        await this.checkApplicantEligibility();
        await getAssetTabList({opportunityId: this.recordId}).then(data=>{
            if (data){
                if(data.length > 0){
                    this.activeTabId = data[0].id;
                }
                this.assetTabList = data;  
                this.assetLength = this.assetTabList.length; 
                this.lastItem = Number(this.assetLength) - 1;
            }
            this.showChildComponent = true;  
        }).catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({title: 'Error!', message: error?.body?.message, variant: error})
            );
            this.showChildComponent = true;
        });
    }

    //SFTRAC-176 Start
    @track isdisabled = false;
    async checkApplicantEligibility(){
        this.isdisabled = false;
        await isApplicantInsuranceApplicable({loanapplicationId: this.recordId, applicantId: this.applicantId}).then(response => {
            if(response){
                this.isdisabled = true;
                this.disableEverything();
            }
        }).catch(error => {});
    }
    //SFTRAC-176 End

    async handleActive(event){
        let childInsuranceCmps = this.template.querySelectorAll('c-l-w-c_-t-f_-insurance-details_-child');
        if(childInsuranceCmps && childInsuranceCmps.length > 0){
            for (let index = 0; index < childInsuranceCmps.length; index++) {
                const cmp = childInsuranceCmps[index];
                await cmp.refreshNomineeDetails();
            }
        }
        this.activeTabId = event?.target?.value;
        if(this.assetTabList[this.lastItem].id== this.activeTabId && this.nonIndividual){
            if((this.isCalledFromL1 && this.stageName == 'Insurance Details') || (this.isCalledFromL2 && this.subStage == 'Insurance') ){
            this.enableNext = true;
                }        
        } else {
            this.enableNext = false;
        }
        await this.checkApplicantEligibility();
    }
    handlebeneficiaryNext(){
       /* const oppFields = {};
        oppFields[OPP_ID_FIELD.fieldApiName]=this.recordId;
        if(this.isCalledFromL2){
        oppFields[SUB_STAGE_FIELD.fieldApiName]= 'Risk Summary';
        }
        if(this.isCalledFromL1){
        oppFields[STAGE_FIELD.fieldApiName]= 'Customer Code Addition';
        }
        this.updateRecordDetails(oppFields); */
        let journeyOfLead= this.isCalledFromL1 == 'true' ? 'L1' : this.isCalledFromL2 == 'true' ? 'L2' : '';
        updateVehicleDetails({loanApp:this.recordId,leadStage:journeyOfLead});
        window.location.reload();
        	
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        console.log('before update ', recordInput);
        await updateRecord(recordInput)
            .then(() => {
                console.log('record  is updated successfully');
            })
            .catch(error => {
                console.log('record update error', error);
            });
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    handleOnfinish(event) {
        const evnts = new CustomEvent('customcodevaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

    //SFTRAC-2243 Start
    @track showFileUploadAndView=false;
    viewUploadViewFloater(){ this.showFileUploadAndView=true; }
    closeUploadViewFloater(event){ this.showFileUploadAndView=false; }
    //SFTRAC-2243 End
}