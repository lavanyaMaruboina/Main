/**
* Enhancement  CISP-2511, CISP-2869
* Name         IND_LWC_DeviationHierarchialListView
* Author       Rajat Jaiswal
* Description  This component is used to showing all Loan Applications which in committee role hierarchy.
**/
import { LightningElement, track } from 'lwc';
import getDeviationHierarchyList  from '@salesforce/apex/DeviationHierarchialListViewController.getDeviationHierarchyList';

export default class IND_LWC_DeviationHierarchialListView extends LightningElement {
    deviationList = [];
    @track originalDeviationList = [];
    @track searchKey = '';
    connectedCallback(){
        getDeviationHierarchyList()
        .then(result =>{
            console.log('result',result);
            if (result && result.length > 0) {
                result.forEach(element => {
                    element.camLink = '/apex/IBLCAMPage' + '?id='+element.camLink;
                    element.loanApplicationId = '/'+element.loanApplicationId;
                });
                this.deviationList = result;
                this.originalDeviationList = result;
            }else {
                console.error('No Record Found');
            }
        })
        .catch(error => {
            console.error('Error in getDeviationHierarchyList ==>>',error);
        });
    }
    handleSearchLoanApplication(event){
        try {
            this.searchKey = event.target.value;
            if(this.searchKey){
                let tempList = this.originalDeviationList;
                let desiredLoanApplication = tempList.filter(element=>element.loanApplication.includes(this.searchKey));
                this.deviationList = [];
                if(desiredLoanApplication){
                    this.deviationList =desiredLoanApplication;
                }
            }else{
                this.deviationList = this.originalDeviationList;
            }
        } catch (error) {
            console.error(error);
        }
    }
}