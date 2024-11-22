// Author: Haarika Chodisetti
// Company: Salesforce
// Description: Parent component for Business Executive functionality
import { LightningElement,api,wire,track } from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import SUB_STAGE_FIELD from "@salesforce/schema/Opportunity.Sub_Stage__c";
import OWNERID_FIELD from "@salesforce/schema/Opportunity.OwnerId";
import fetchApplicationDetails from '@salesforce/apex/BusinessExecutiveScreenController.fetchApplicationDetails';
import moveToCreditProcessing from '@salesforce/apex/BusinessExecutiveScreenController.moveToCreditProcessing';
import cvoUserExists from '@salesforce/apex/BusinessExecutiveScreenController.cvoUserExists'; /* Added for CISP- 9783 */
import doVKCDocumentDownload from '@salesforce/apex/D2C_IntegrationEngine.doVKCDocumentDownload';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLoanApplicationStageNameMetaData from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageNameMetaData';

// added by Aman to show Tranfer button to all except Integration user

import strUserId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/Opportunity.Owner.Profile.Name';
import {getRecord} from 'lightning/uiRecordApi';

export default class BusinessExecutiveScreen extends LightningElement {
    @api recordId;
    applicantId;
    showOverlayMenu = false;
    showPreInitialOffer = true;
    showPostInitialOffer = false;
    //prashanth
    productType;
    vehicleType;
    sanctionStatus;
    vkycDone = true;
    //forUsedVehicleType = false;
    showVehicleValuation = false;
    showVehicleInsurance = false;
    showInsurance = false;
    vehicleDetailId;
    currentStage;
    currentSubStage;
    lastStage;
    isTransferVisible;
    isVKYC = false;
    isETB = false;
    showAssetDetails;
    activeTab = 'preInitialOffer';
    showOtherPages = false;
    vkycDisabled = false;
    isPreApproved = false;
    data;
    blcode;


    //added by Aman
    @track profiledata;
    @track ownerId;

            //Added by Aman
  
            @wire(getRecord, { recordId: '$recordId', fields: [OWNERID_FIELD,PROFILE_NAME_FIELD] })
            owner({data,error}){
                if(data){
                    
                    this.ownerId = data.fields.OwnerId.value;
                    this.profiledata =data.fields.Owner.value.fields.Profile.value.fields.Name.value; 
                }else if(error){
                    let message = 'Unknown error';
                    if (Array.isArray(error.body)) {
                        message = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        message = error.body.message;
                    }
                }
            }


    async connectedCallback() {
        this.isLoading = true;
        //prashanth
        await fetchApplicationDetails({ loanApplicationId: this.recordId }).then(result => {
            console.log('result--:', result);
            console.log(this.recordId);
            this.data = result;
            this.applicantId = result.applicant.Id;
            this.productType = result.applicant.Opportunity__r.Product_Type__c;
            this.vehicleType = result.applicant.Opportunity__r.Vehicle_Type__c;
            this.sanctionStatus = result.applicant.Opportunity__r.Sanction_Status__c;
            this.blcode = result.applicant.Opportunity__r.AccountId;
            if(result.applicant.Opportunity__r.VKYC_Doc_Urls__c && !result.applicant.Opportunity__r.VKYC_Doc_Downloaded__c){
                this.vkycDone = false;
            }
            this.activeTab = result.applicant.Opportunity__r.Is_Pre_Approved__c ? 'preApprovedOffer' : this.activeTab;
            this.isPreApproved = result.applicant.Opportunity__r.Is_Pre_Approved__c;
            this.isETB = result.applicant.Opportunity__r.Is_ETB__c;
            this.isVKYC = result.applicant.Opportunity__r.VKYC_Doc_Urls__c != null;

            this.vehicleDetailId = result.vehicleDetail ? result.vehicleDetail.Id : null;
            const vehicleTypesToShowOtherPages = ['USED', 'REFINANCE'];
            if(this.productType === 'Passenger Vehicles' && this.vehicleType && vehicleTypesToShowOtherPages.includes(this.vehicleType?.toUpperCase())){
                this.showOtherPages = true;
            }
            let insuranceExpiring = result.vehicleDetail ? result.vehicleDetail.Insurance_expiring_within_60_days__c : false;
            this.showInsurance = vehicleTypesToShowOtherPages.includes(this.vehicleType?.toUpperCase()) && insuranceExpiring;
            // if(this.productType == 'Passenger Vehicles' && this.vehicleType == 'Used'){
            //     this.forUsedVehicleType = true;
            // }
            this.currentStage = result.applicant.Opportunity__r.StageName;
            this.currentSubStage = result.applicant.Opportunity__r.Sub_Stage__c;
            this.lastStage = result.applicant.Opportunity__r.LastStageName__c
            this.isLoading = false;
            getLoanApplicationStageNameMetaData().then(response => {
                 console.log(' result ', result, ' check ', this.currentStage);
                 console.log(' result profile', this.profiledata);
                const res = response.includes(this.currentStage);
                console.log(' result profile check', this.ownerId);
                const allowedProfile = this.profiledata.toLowerCase().includes('integration');
                console.log(' result profile check', this.ownerId);
               //  this.isTransferVisible = res; 
               this.isTransferVisible = !allowedProfile?true:false;

            }).catch(error => {
                this.isLoading = false;
                console.log('error' + JSON.stringify(error));
            });

        }).catch(error => {
            this.isLoading = false;
            console.log('error ==', JSON.stringify(error));
        });
    }

    openOverlayMneu() {
        this.showOverlayMenu = true;
    }


    get isVKYCVisible(){
        return this.isVKYC;// && this.isETB;
    }


    handleVkyc(){
        this.isLoading = true;
        doVKCDocumentDownload({loanId : this.recordId })
        .then(result => {
            if(result === 'success'){
                this.vkycDone = true;
                const event = new ShowToastEvent({
                    title: 'Downloaded',
                    message: "V-KYC documents downloaded successfully.",
                    variant: 'success'
                });
                this.dispatchEvent(event);
            }else if(result === 'downloaded'){
                this.vkycDisabled = true;
                const event = new ShowToastEvent({
                    title: 'Already Downloaded',
                    message: "V-KYC documents have already been downloaded.",
                    variant: 'warning'
                });
                this.dispatchEvent(event);
            }else if(result === 'urlMissing'){
                const event = new ShowToastEvent({
                    title: 'URL Missing',
                    message: "Could not download V-KYC documents because document urls are not available yet.",
                    variant: 'warning'
                });
                this.dispatchEvent(event);
            }else if(result === 'retryExhausted'){
                this.vkycDisabled = true;
                const event = new ShowToastEvent({
                    title: 'Retry Exhausted',
                    message: "You have exhausted all the retry attempts. Please contact System Administrator",
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: "Could not download V-KYC documents. Please contact administrator",
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
            console.log(result);
            this.isLoading = false;
            
        }).catch(error => {
            this.isLoading = false;
            console.log('error ==', JSON.stringify(error));
            const event = new ShowToastEvent({
                title: 'Error',
                message: "Could not download V-KYC documents. "+ JSON.stringify(error),
                variant: 'error'
            });
            this.dispatchEvent(event);
        });
    }

    closeOverlayMenu() {
        this.showOverlayMenu = false;
    }

    handlePreInitialOffer(){
        this.activeTab = 'preInitialOffer';
        this.closeOverlayMenu();
    }

    handlePostInitialOffer(){
        this.activeTab = 'postInitialOffer';
        this.closeOverlayMenu();
    }

    handlePreApprovedOffer(){
        this.activeTab = 'preApprovedOffer';
        this.closeOverlayMenu();
    }

    handleCreditProcessing(){
        if(!this.sanctionStatus){
            const event = new ShowToastEvent({
                title: 'Error',
                message: "Cannot be moved to Credit Processing stage as Final Offer is not generated yet.",
                variant: 'error'
            });
            this.dispatchEvent(event);
        }else if(!this.vkycDone){
            const event = new ShowToastEvent({
                title: 'Error',
                message: "Cannot be moved to Credit Processing stage. Please download the V-KYC documents first.",
                variant: 'error'
            });
            this.dispatchEvent(event);
        }else{
            this.isLoading = true;
            const fields = {};

            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[STAGE_FIELD.fieldApiName] = 'Credit Processing';
            fields[SUB_STAGE_FIELD.fieldApiName] = 'View Application Details';
                
            const recordInput = {
            fields: fields
            };
            /* CISP- 9783 START -- Checks if a CVO user exists. If they do, onlynthen try update the stage*/
            cvoUserExists({loanApplicationId:this.recordId}).then((result)=>{
                console.log('cvoUserExists? ',JSON.stringify(result));
                if(result == true){
                    console.log('exists');
                    moveToCreditProcessing({loanApplicationId:this.recordId})
                .then((record) => {
                /*CISP-7004 - start */
                this.isLoading = false;
                const stage_update_response = JSON.stringify(record);
                console.log('here in record: '+stage_update_response);
                console.log('unstringified record: '+record);
                const vkyc_rejected = 'Cannot proceed ahead since vKYC is Rejected!';
                const vkyc_isBlank = 'Cannot proceed ahead since vKYC is not Completed!';
                
                
                if(record === 'success'){
                    console.log('If > success')
                    this.isLoading = false;
                    const stageChangedEvent = new CustomEvent('stagechangedtocreditprocessing', {});
                    this.dispatchEvent(stageChangedEvent);
                }
                else if(stage_update_response.includes(vkyc_rejected)){
                    console.log('Else If > Error and VKYC Rejected Issue')
                    this.isLoading = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: vkyc_rejected,
                        variant: 'error'
                    }));
                }else if(stage_update_response.includes(vkyc_isBlank)){
                    console.log('Else If > Error and VKYC is blank Issue')
                    this.isLoading = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: vkyc_isBlank,

                        variant: 'error'
                    }));
                }
                else{
                    console.log('Else > Error and Unknon Issue')
                    this.isLoading = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'An error occured while moving to credit processing',
                        message: stage_update_response,
                        variant: 'error'
                    }));
                }
                /*CISP-7004 -end */
                //const stageChangedEvent = new CustomEvent('stagechangedtocreditprocessing', {});
                //this.dispatchEvent(stageChangedEvent);
            })
            /*.catch((error)=>{
                console.log('here in error: '+JSON.stringify(error));
                this.isLoading = false;
                });*/
                /*.catch((error)=>{
                    console.log('here in error: '+JSON.stringify(error));
                    this.isLoading = false;
                });*/
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: "Cannot move to Credit Processing since no CVO users were found to assign this Loan Application. Please configure a CVO user and try again!",
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
        });
        /* CISP- 9783 END*/

        }
        this.closeOverlayMenu();
    }

    //prashanth
    handleVehicleValuation(){
        this.handleNavigation('vehicleValuation');
        this.closeOverlayMenu();
    }

    handleVehicleInsurance(){
        this.handleNavigation('vehicleInsurance');
        this.closeOverlayMenu();
    }
    handleAssetDetails(){
        this.handleNavigation('assetDetails');
        this.closeOverlayMenu();
    }
    handleVehicleDedupe(){
        this.handleNavigation('vehicleDedupe');
        this.closeOverlayMenu();
    }
    handleInsuranceDetails(){
        this.handleNavigation('insuranceDetails');
        this.closeOverlayMenu();
    }
    refreshPage(){
        
        setTimeout(function() {  
            console.log('here--');
            const evt = new ShowToastEvent({
                title: 'Sucess',
                message: 'Recalled sucessfully',
                variant: 'success',
            });
            this.dispatchEvent(evt);  
        }, 200);
        window.setTimeout(() => {
            window.location.reload(true);
        }, 200);
          
    }

    async handleNavigation(activeviewappsubtab) {
        await fetchApplicationDetails({ loanApplicationId: this.recordId }).then(result => {
            this.data = result;
            let showError = false;
            if(activeviewappsubtab == 'vehicleDedupe' && !(this.data.applicant.Opportunity__r.Vehicle_Registration_Number__c != null || this.data.applicant.Opportunity__r.Sub_Stage__c == 'Vehicle Dedupe')){
                showError = true
            }else if (activeviewappsubtab == 'assetDetails' && !(this.data.applicant.Opportunity__r.StageName == 'Asset Details' || this.data.vehicleDetail?.Engine_number__c != null)){
                showError = true
            }else if(activeviewappsubtab == 'vehicleInsurance' && !(this.data.applicant.Opportunity__r.StageName == 'Vehicle Insurance' || this.data.vehicleDetail?.Ins_Expiry_date__c != null)){
                showError = true
            }else if(activeviewappsubtab == 'vehicleValuation' && !(this.data.applicant.Opportunity__r.StageName == 'Vehicle Valuation' || this.data.vehicleDetail?.Insurance_declared_value__c != null)){
                showError = true;
            }else if(activeviewappsubtab == 'insuranceDetails' && !(this.data.applicant.Opportunity__r.Sub_Stage__c == 'Insurance Details' || this.data.insDetials != null || this.data.vehicleDetail?.Insurance_declared_value__c != null)){
                showError = true;
            }else{
                this.activeTab = activeviewappsubtab;
            }
            if(showError){
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please submit the previous tab first',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('error ==', JSON.stringify(error));
        });
        
        // if((activeviewappsubtab == 'vehicleDedupe' && this.lastStage != 'Vehicle Valuation' && this.currentSubStage != 'Vehicle Dedupe') ||
        //    (activeviewappsubtab == 'assetDetails' && this.lastStage != 'Vehicle Valuation' && this.currentStage != 'Asset Details') ||
        //    (activeviewappsubtab == 'vehicleInsurance' && this.lastStage != 'Vehicle Valuation' && this.currentStage != 'Vehicle Insurance') ||
        //    (activeviewappsubtab == 'vehicleValuation' && this.lastStage != 'Vehicle Valuation' && this.currentStage != 'Vehicle Valuation') ||
        //    (activeviewappsubtab == 'insuranceDetails' && this.lastStage != 'Vehicle Valuation' && this.currentStage != 'Insurance Details')){
        //     const evt = new ShowToastEvent({
        //         title: 'Warning',
        //         message: 'Please submit the previous tab first',
        //         variant: 'warning',
        //     });
        //     this.dispatchEvent(evt);
        // }else{
        //     this.activeTab = activeviewappsubtab;
        // }
        
    }
    handleActiveTab(event) {
        let activeviewappsubtab = event.target.value;
        this.handleNavigation(activeviewappsubtab);
    }

    checkInsurance(event) {
        fetchApplicationDetails({ loanApplicationId: this.recordId }).then(result => {
            const vehicleTypesToShowOtherPages = ['USED', 'REFINANCE'];
            let insuranceExpiring = result.vehicleDetail ? result.vehicleDetail.Insurance_expiring_within_60_days__c : false;
            this.showInsurance = vehicleTypesToShowOtherPages.includes(this.vehicleType?.toUpperCase()) && insuranceExpiring;
        }).catch(error => {
            this.isLoading = false;
            console.log('error ==', JSON.stringify(error));
        });
    }

    @api submit(event) {
        console.log('enteredsubmit');
        let screenValue = event.detail;
        this.lastStageName = screenValue;
        console.log('enteredsubmit',screenValue);
        if (screenValue === 'Asset Details') {
            this.activeTab = 'assetDetails';
            this.currentStage = 'Asset Details';
        }
        if (screenValue === 'Vehicle Insurance') {
            this.activeTab = 'vehicleInsurance';
            this.currentStage = 'Vehicle Insurance';
        }
        if (screenValue === 'Vehicle Valuation') {
            this.activeTab = 'vehicleValuation';
            this.currentStage = 'Vehicle Valuation';
        }
        if (screenValue === 'Post Initial Offer') {
            if(this.isPreApproved){
                this.activeTab = 'preApprovedOffer';
            }else{
                this.activeTab = 'postInitialOffer';
            }
            
        }
        if (screenValue === 'Loan Details' && !this.showInsurance) {
            this.activeTab = 'postInitialOffer';
            this.lastStage = 'Vehicle Valuation'
            //this.handleCreditProcessing();//So that journey moves to credit processing
        }else if(screenValue === 'Loan Details' && this.showInsurance){
            this.isLoading = true;
            const fields = {};

            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[STAGE_FIELD.fieldApiName] = 'Loan Initiation';
            fields[SUB_STAGE_FIELD.fieldApiName] = 'Insurance Details';
                
            const recordInput = {
            fields: fields
            };
            updateRecord(recordInput)
            .then((record) => {
                this.isLoading = false;
                this.activeTab = 'insuranceDetails';
                this.lastStage = 'Insurance Details'
            })
            .catch((error)=>{
                this.isLoading = false;
            });
        }
        console.log('out asset details');

    }
    
}