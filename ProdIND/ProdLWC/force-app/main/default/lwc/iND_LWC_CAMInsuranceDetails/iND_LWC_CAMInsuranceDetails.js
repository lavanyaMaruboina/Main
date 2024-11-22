import { LightningElement, api } from 'lwc';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
// import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';

export default class IND_LWC_CAMInsuranceDetails extends NavigationMixin(LightningElement) {
    @api recordId;
    @api fromCAMPage = false;
    coApplicantId;
    applicantId;
    loanApplicationId;
    // applicantType = 'Borrower';
    currentStage = 'Credit Processing';
    getcreditvalue ='blank';
    applicantTypeList = [];
    activeTabValue = 'Borrower';   
    showInsuranceModel = false;
    fromCAMLog=false;
    tabListCount;
    connectedCallback() {
        console.log(this.recordId);
        if(this.recordId){
            getRequestDetails_MTD({ camId: this.recordId })
            .then(response => {
              if (response) {
                console.log(response);
                this.applicantTypeList = response.appList;
                this.activeTabValue = this.applicantTypeList[0];
                this.tabListCount = this.applicantTypeList.length;
                this.loanApplicationId = response.loanAppId;
                console.log('recordId', this.recordId, this.applicantTypeList, this.loanApplicationId);
                if(this.fromCAMPage){
                    this.showInsuranceModel =true;
                }
              }
            }).catch(error => {
                console.error('error in getRequestDetails_MTD =>', error);
            });
        }      
    }

    @api openModal(){
        this.showInsuranceModel =true;
        this.fromCAMLog=true;
    }
    closeInsRecompute(){
        if (this.fromCAMPage) {
            self.close();
        }else{
            this.dispatchEvent(new CustomEvent('closeinsrecompute'));
            this.showInsuranceModel = false;
            this.fromCAMLog = false;
        }
    }
    @api submit(){
        this.showInsuranceModel = false;
        this.fromCAMLog = false;
        this.dispatchEvent(new CustomEvent('closeinsrecompute'));
    }
    navigateCoborrower() {
        this.activeTabValue = CoBorrower;
    }
    
    handleActiveSecondSubTab(event) {
        this.tab = CoBorrower;
        this.activeTabValue = event.target.value;
    }
}