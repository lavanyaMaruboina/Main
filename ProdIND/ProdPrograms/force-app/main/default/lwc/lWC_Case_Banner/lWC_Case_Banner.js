import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRCUCaseDetails from '@salesforce/apex/RCUCaseController.getRCUCaseDetails';
import getCurrentUserContactAccId from '@salesforce/apex/RCUCaseController.getCurrentUser';
import updateCaseOwner from '@salesforce/apex/RCUCaseController.updateCaseOwner';
import USER_NAME from '@salesforce/schema/User.Name';
import userId from '@salesforce/user/Id';

import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';



export default class LWC_Case_Banner extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowModal = false;
    @track modalHeader = '';
    @track caseStatus='';
    @track isSubmitVisible= false;
    @track caseSubject='Case';
    @track caseOwner = '';
    @track caseNumber = '';
    isShowCaseAssigmentModal= false;
    caseAssigmentModal = 'Case Assigment';
    USER_NAME_FIELD = USER_NAME.fieldApiName;
    filterName=['Contact.AccountId'];
    filterValue =[];
    @track userId =userId;
    selectedValueId;


    connectedCallback() {
        console.log('Case Id ->'+this.recordId);
        getRCUCaseDetails({'recordId' : this.recordId}).then(result =>{
            if(result){
                console.log('result init==>',result);
                this.caseStatus = result?.Status;
                this.caseNumber = result?.CaseNumber;
                this.caseOwner =  result?.Owner.Name;
                this.isSubmitVisible = this.caseStatus=='In Progress'? true:false;
                console.log('isStatusInProgress',this.isStatusInProgress);

                this.caseSubject =this.caseSubject +'-'+ result?.Subject;
            }
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error getting while fething the RCU Case data!',
                variant: 'error', 
            });
            this.dispatchEvent(evt);
        });

        console.log('getCu',this.userId);
        getCurrentUserContactAccId({'userId' : this.userId}).then(result =>{
            console.log('getCurrentUserContactAccId : ',this.userId);
            if(result){
                console.log('result getCurrentUserContactAccId==>',result);
               this.filterValue =[result.Contact.AccountId];
            }
            else{
                console.log('else getCurrentUserContactAccId==>',result);  
            }
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error getting while User Detail data!',
                variant: 'error', 
            });
            this.dispatchEvent(evt);
        });

    }

    handleSubmitClick(event){
        this.isShowModal = true;
        this.modalHeader='Submit for Approval';
        console.log('submit click');   

    }
    hideModalBox() {  
        this.isShowModal = false;
        this.isShowCaseAssigmentModal = false;
    }
    handleCaseAssignment(){
        this.isShowCaseAssigmentModal = true;
    }
    selectedLookupHandler(event){
        console.log('onSelect==>',event.detail.selectedValueName);
        console.log('onSelect22==>',event.detail.selectedValueId);
        this.selectedValueId = event.detail.selectedValueId;
    }
    handleChangeOwner(event){
        updateCaseOwner({'recordId':this.recordId, 'ownerId': this.selectedValueId}).then(result=>{
            console.log('Result--->',result);
            if(result == 'Success'){
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Case owner updated",
                    variant: "success",
                }),
                );
                this.isShowCaseAssigmentModal=false;
                this.navigateToHomePage();
            }
            
        }).catch(error => {
                console.error('error--->',error);
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Error updating record",
                    message: error.body.message,
                    variant: "error",
                    }),
                );
        });
    
    }
        navigateToHomePage() {
        isCommunity()
            .then(response => {
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
            .catch(error => {
            });

    }
}