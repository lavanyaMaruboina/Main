import { LightningElement,track,api, wire} from 'lwc';
import approvedByRole from '@salesforce/apex/ProposalStatusClass.getAccountRole';

import allState from '@salesforce/apex/ProposalStatusClass.getAllState';
import getBLCode from '@salesforce/apex/ProposalStatusClass.blCodeMapping';
import filter from '@salesforce/apex/ProposalStatusClass.searchLogs';
import getCurrentUserProductType from '@salesforce/apex/ProposalStatusClass.getCurrentUserProductType';
import getForwardedProposals from '@salesforce/apex/ProposalStatusClass.getForwardedProposals';


import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import Opportunity from '@salesforce/schema/Opportunity';
import AccountTeamMember from '@salesforce/schema/AccountTeamMember';
import Cam from '@salesforce/schema/CAM__c';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import Committee_Field from '@salesforce/schema/CAM__c.Committee__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Lightning_IBL_Incident_Management_URL from '@salesforce/label/c.Lightning_IBL_Incident_Management_URL';


export default class IND_LWC_ProposalPendingForApproval extends NavigationMixin(LightningElement) {

    @track camRecId;
    @api proposalList=[];
    @api camData;
    @api camIdVsCamObjMap;
    @track error;
    @api recordId;
    @track proposalNotApprovedBySCMList=[]; //D
    @track proposalHoldByYouList=[]; //D
    @track proposalForwardedByYouList=[]; //D
    
   @track productOptions =[
    { label: 'ALL', value: 'ALL' },
    { label: 'Two Wheeler', value: 'Two Wheeler' },
    { label: 'Passenger Vehicles', value: 'Passenger Vehicles'},
    { label: 'Tractor', value: 'Tractor'}];
   @track categoryOptions = [
    { label: 'ALL', value: 'ALL' },
    { label: 'New', value: 'New' },
    { label: 'Used', value: 'Used' },
    { label: 'Refinance', value: 'Refinance' }];
   @track committeeOptions;
   @track approvedByOptions;
   @track pendingWithValue;//CISP-2864
   @track approvedByOptionsToShow;
   @track stateOptions ;
   @track BLCodeOptions ;
   @track daysPendingOptions=[
    { label: '0', value: '0' },
    { label: '1', value: '1' },
    { label: '2', value: '2' },
    { label: '3-7', value: '3' },
    { label: '>7', value: '7' }
   ];//CISP-2863

    @track productValue;
    @track categoryValue;
    @track stateValue='';
    @track stateList=[];
    @track BLCodeValue;
    @track committeeValue;
    @track daysPending;
    @track appNo;
    @track leadNo;//CISP-7949
    @track approvedBy='SCM';
   
    @track makeOptionsListWithUrl = [];
    @track holdByList = [];
    @track forwardedByList = [];
    @track NotAprrovedBySCMList = [];
    @track pendingWithOptions = [];//CISP-2864
    currentPageReference = null;
    urlStateParameters = null;
    isTwoWheeler = false;

    handleReportanIncidentClick(){
        let currentUrl = window.location.href;
        if(currentUrl && currentUrl.includes('/partners/')){
            currentUrl = currentUrl.split('/partners/')[0];
            window.open(currentUrl+'/partners/s/ibl-incident-management', '_blank');
        }
        else{
            window.open(Lightning_IBL_Incident_Management_URL, '_blank');
        }       
    }
    @wire(allState, {})
    retrieve_States({error,data}){
        let arr=[];
        if(data){
            for(var i=0;i < data.length ;i++){
                arr.push({label: data[i].Name , value: data[i].CFD_State_Code__c})
            }
            this.stateOptions = arr;
            
        } else if(error){
            console.error('error:', error);
        }      
    }

    //D
    @wire(approvedByRole, {})
    retrieve_ApprovedBy({error,data}){
        let arr=[];
        if(data){
            for (const key in data) {
                if (key === 'ALL') {
                    const value = data[key];
                    for(var i=0;i < value.length ;i++){
                        if (!arr.find(opt => opt.label === value[i])) {//CISP-2864
                            arr.push({label: value[i] , value: value[i]})
                        }//CISP-2864
                    }
                }
            }
            this.pendingWithOptions = arr;//CISP-2864            
            this.approvedByOptions = data;          
            this.approvedByOptionsToShow = arr;          
        }
        else if (error){
          console.error('error ', error);
        }      

    }
    
    @wire(getObjectInfo, { objectApiName: Opportunity })
       opportunityObjectinfo;

    @wire(getObjectInfo, { objectApiName: Cam })
       CAMObjectinfo;

    @wire(getObjectInfo, { objectApiName: AccountTeamMember })
       AccountTeamRoleinfo;

    @wire(getPicklistValues,{
            recordTypeId: "$CAMObjectinfo.data.defaultRecordTypeId", 
            fieldApiName:Committee_Field })
        fetchCommitteePicklist({error,data}){
            if(data!==undefined){
                this.committeeOptions=data.values;
            }else{

            }
        }

    showToast(info) {
        const event = new ShowToastEvent({
            title: 'Message',
            message: info,
            variant: 'Error'
        });
        this.dispatchEvent(event);
    }
    
    handleProductOptions(event){
        this.productValue=event.detail.value;
        let arr=[];
        if(this.approvedByOptions && this.productValue){
            for (const key in this.approvedByOptions) {
                if (key === this.productValue) {
                    const value = this.approvedByOptions[key];
                    for(var i=0;i < value.length ;i++){
                        arr.push({label: value[i] , value: value[i]})
                    }
                }
            }       
            this.approvedByOptionsToShow = arr;          
        }
    }
    handleCategoryOptions(event){
        this.categoryValue=event.detail.value;
    }
    
    handleCommitteeOptions(event){
        this.committeeValue=event.detail.value;
    }

    handleDaysPendingOptions(event){
        this.daysPending=event.detail.value;
    }
    handleStateOptions(event){
        try {
            this.stateValue=event.detail.value;
            getBLCode({stateKey: this.stateValue})
            .then(data=>{
                let arr=[];
                this.BLCodeOptions = arr;          
                if(data){
                    for(var i=0;i < data.length ;i++){
                        if (data[i].Bl_Code__c) {
                            arr.push({label: data[i].Bl_Code__c , value: data[i].Bl_Code__c})
                        }
                    }
                    this.BLCodeOptions = arr;          
                }     
            })
            .catch(error=>{
                console.error(error);
            })
        } catch (error) {
            console.error(error);
        }
    }

    handleBLCodeOptions(event){
        this.BLCodeValue=event.detail.value;
    }

    handleLeadNoOptions(event){//CISP-7949
        this.leadNo=event.target.value;
    }

    handleApprovedByOptions(event){
        this.approvedBy=event.detail.value;
    }
    handlePendingWithOptions(event){//Start CISP-2864
        this.pendingWithValue=event.detail.value;
    }//End CISP-2864
    
    connectedCallback(){
        getCurrentUserProductType()
        .then(res => {
            if (res) {
                this.productValue = res;
                this.searchClick();
            }
        }).catch(error => {
            console.error('error:: ', error);
            
        });
        
    }

    handleRefreshClick(event){
        eval("$A.get('e.force:refreshView').fire();");
    }
    @track forwardedProposalLst; //SFTRAC-2023
    forwardProposalVisible = false; //SFTRAC-2023

    async searchClick(){
        this.forwardProposalVisible = this.productValue == 'Tractor' ? true: false; //SFTRAC-2023
        try {
            let stateName;
            if (this.stateOptions && this.stateOptions.length > 0) {
                this.stateOptions.forEach(state=>{
                    if(state.value== this.stateValue ){
                        stateName = state.label;
                    }
                });
            }
            //SFTRAC-2023 Start
            getForwardedProposals().then( data => {
                console.log('getForwardedProposals OUTPUT : '+JSON.stringify(data));
                this.forwardedProposalLst = data;
                // this.forwardProposalVisible = data[0].isVisible;
            }).catch(err=>{
                console.error('getForwardedProposals error:: ', JSON.stringify(err));
                return null;
            });
            //SFTRAC-2023 End
            this.camData = await filter({productName:this.productValue,Category:this.categoryValue,State:this.stateValue,BLCode:this.BLCodeValue,committee:this.committeeValue,daysPending:this.daysPending,leadNum:this.leadNo,approvedBy:this.approvedBy,stateName:stateName,pendingWith:this.pendingWithValue})//CISP-2864 && //CISP-7949
                .then(res => {
                    return res;
                }).catch(error => {
                    console.error('error:: ', error);
                    return null;
                });
            if(this.camData){
                let camIdVsDeviationList = this.camData.camIdVsDeviationListMap;
                let loanApplicationVsBankBranch = this.camData.loanApplicationVsBankBranch;
                let loanIdVsVehicleDetail = this.camData.loanIdVsVehicleDetail;
                let loanIdVsTotalExposure = this.camData.loanIdVsTotalExposure;
                let camIdVsCamObj = this.camData.camIdVsCamObjMap;
                let camIdVsForwardedUserList = this.camData.camIdVsForwardedUserMap
                let camIdVsApprovalByStatus = this.camData.camIdVsApprovalByStatus
                let camIdVsIsHoldMap = this.camData.camIdVsIsHoldMap
                this.camIdVsCamObjMap = camIdVsCamObj;
                let currentUserId = this.camData.currentUserId;
                let forwardedOnlyList = this.camData.forwardToYouProposalList;
                let holdedCamList = this.camData.camIdSet;
                let forwardedByProposalList = this.camData.forwardedByProposalList;//CISP-2532
                let pendingProposals = [];
                this.proposalList = [];
                let camIdSet = [];//CISP-2532
                if(camIdVsDeviationList){
                    for(let camId in camIdVsDeviationList){
                        if(holdedCamList && !holdedCamList.includes(camId)){
                            const value = camIdVsDeviationList[camId];
                            let obj = Object.create(camIdVsCamObj[camId]);
                            if(camIdVsApprovalByStatus && camIdVsApprovalByStatus[camId]){
                                obj.approvalDone = camIdVsApprovalByStatus[camId];
                            }
                            if(camIdVsIsHoldMap && camIdVsIsHoldMap[camId]){
                                obj.isHoldByOthers = camIdVsIsHoldMap[camId];
                            }
                            if(loanApplicationVsBankBranch && loanApplicationVsBankBranch[camIdVsCamObj[camId].Loan_Application__c]){
                                obj.branchName = loanApplicationVsBankBranch[camIdVsCamObj[camId].Loan_Application__c].Name;
                            }
                            if(loanIdVsVehicleDetail && loanIdVsVehicleDetail[camIdVsCamObj[camId].Loan_Application__c]){
                                obj.variant = loanIdVsVehicleDetail[camIdVsCamObj[camId].Loan_Application__c].Variant__c;
                                if (camIdVsCamObj[camId].Loan_Application__r.Product_Type__c === 'Two Wheeler') {
                                    obj.segment = loanIdVsVehicleDetail[camIdVsCamObj[camId].Loan_Application__c].Product_Segment__c;
                                    this.isTwoWheeler = true;
                                }
                            }
                            if(loanIdVsTotalExposure && loanIdVsTotalExposure[camIdVsCamObj[camId].Loan_Application__c]){
                                obj.TotalExposure = loanIdVsTotalExposure[camIdVsCamObj[camId].Loan_Application__c];
                            }
                            obj.URL = '/apex/IBLCAMPage' + '?id='+camId;
                            let currentUserRole = this.camData.accountIdVsTeamMemberMap[obj.Loan_Application__r.AccountId].TeamMemberRole;
                            obj.daysPending = obj.No_of_Days_Pending__c;
                            if (parseInt(obj.daysPending) > 3) {//Strat CISP-2863
                                obj.rowStyle =  'background:red;';
                            }else{
                                obj.rowStyle = null;
                            }//Start CISP-2863
                            if(camIdVsForwardedUserList[camId] && camIdVsForwardedUserList[camId].includes(currentUserId)){
                                obj.Status = 'Forwarded To You, Action Pending';
                                obj["CAMPosition"] = 'Forwarded';
                                if (camIdVsCamObj[camId].Action_Taken__c) {
                                    obj.Status = 'Ratification Pending';
                                }
                            }
                            else{
                                obj.Status = 'Action Pending';
                                obj["CAMPosition"] = 'Direct';
                                if (camIdVsCamObj[camId].Action_Taken__c) {
                                    obj.Status = 'Ratification Pending';
                                }
                            }
                            if(forwardedByProposalList && !forwardedByProposalList.includes(camId) && !camIdSet.includes(camId)){//Start CISP-2532
                                camIdSet.push(camId);
                                pendingProposals.push(obj);
                            }//End CISP-2532
                        }
                    }
                }
                if(forwardedOnlyList){
                    for(let camId in camIdVsCamObj){
                        if(holdedCamList && !holdedCamList.includes(camId)){
                            let camObj = Object.create(camIdVsCamObj[camId]);
                            if(camIdVsApprovalByStatus && camIdVsApprovalByStatus[camId]){
                                camObj.approvalDone = camIdVsApprovalByStatus[camId];
                            }
                            if(camIdVsIsHoldMap && camIdVsIsHoldMap[camId]){
                                camObj.isHoldByOthers = camIdVsIsHoldMap[camId];
                            }
                            if(loanIdVsVehicleDetail && loanIdVsVehicleDetail[camIdVsCamObj[camId].Loan_Application__c]){
                                camObj.variant = loanIdVsVehicleDetail[camIdVsCamObj[camId].Loan_Application__c].Variant__c;
                                if (camIdVsCamObj[camId].Loan_Application__r.Product_Type__c === 'Two Wheeler') {
                                    camObj.segment = loanIdVsVehicleDetail[camIdVsCamObj[camId].Loan_Application__c].Product_Segment__c;
                                    this.isTwoWheeler = true;
                                }
                            }
                            if(loanIdVsTotalExposure && loanIdVsTotalExposure[camIdVsCamObj[camId].Loan_Application__c]){
                                camObj.TotalExposure = loanIdVsTotalExposure[camIdVsCamObj[camId].Loan_Application__c];
                            }
                            if(loanApplicationVsBankBranch && loanApplicationVsBankBranch[camIdVsCamObj[camId].Loan_Application__c]){//Start CISP-2841
                                camObj.branchName = loanApplicationVsBankBranch[camIdVsCamObj[camId].Loan_Application__c].Name;
                            }//End CISP-2841
                            camObj.URL = '/apex/IBLCAMPage' + '?id='+camId;
                            camObj.daysPending = camObj.No_of_Days_Pending__c;
                            if (parseInt(camObj.daysPending) > 3) {//Strat CISP-2863
                                camObj.rowStyle =  'background:red;';
                            }else{
                                camObj.rowStyle = null;
                            }//Start CISP-2863
                            forwardedOnlyList.forEach(element => {
                                if(element.Parent_CAM__c==camId && (!camIdVsDeviationList[camId] || camIdVsDeviationList[camId].length==0)){
                                    camObj.Status = 'Forwarded To You';
                                    camObj["CAMPosition"] = 'Forwarded';
                                    if(forwardedByProposalList && !forwardedByProposalList.includes(camId) && !camIdSet.includes(camId)){//Start CISP-2532
                                    camIdSet.push(camId);
                                    pendingProposals.push(camObj);
                                    }//End CISP-2532
                                }
                            });
                        }
                    }
                }
                this.proposalList = pendingProposals;
    
                this.template.querySelector('c-i-n-d-_-l-w-c-_-proposal-on-hold-by-you').fetchHoldProposal(this.approvedBy,loanApplicationVsBankBranch,loanIdVsVehicleDetail,this.daysPending,this.pendingWithValue);//Start CISP-2864
                this.template.querySelector('c-i-n-d-_-l-w-c-_-proposal-forward-by-you').fetchForwardProposal(this.camIdVsCamObjMap,camIdVsIsHoldMap,loanApplicationVsBankBranch,loanIdVsVehicleDetail,this.pendingWithValue,loanIdVsTotalExposure);
                this.template.querySelector('c-i-n-d-_-l-w-c-_-proposal-not-approved').fetchNonApprovalProposal(this.camIdVsCamObjMap,this.camData.accountIdVsTeamMemberMap,camIdVsForwardedUserList,forwardedOnlyList,currentUserId,camIdVsIsHoldMap,loanApplicationVsBankBranch,loanIdVsVehicleDetail,this.pendingWithValue, loanIdVsTotalExposure);//End CISP-2864
            }
        } catch (error) {
            console.error('error from searchClick ',error);
        }
    }

}