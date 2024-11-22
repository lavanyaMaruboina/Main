import { LightningElement,api } from 'lwc';
import getRequestDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getRequestDetails';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import Borrower from '@salesforce/label/c.Borrower';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import validateFoir from '@salesforce/apex/Ind_ExistingEMICtrl.validateFoir';

export default class IND_LWC_RunEMIEngine extends LightningElement {
@api recordId;
@api isTw;
@api isPv;
currentStage = 'Credit Processing';
    applicantTypeList = [];
    activeTabValue = 'Borrower';   
    showRunEMIModel = false;
    tabListCount;
    applicantId;
    borrowerApplicantId;
    coBorrowerApplicantId;
    label={Borrower,CoBorrower};
// @api openModal(){
//     this.showRunEMIModel =true;
// }
closeFoirCalculate(){
    //this.dispatchEvent(new CustomEvent('closefoircalculate'));
    //this.showRunEMIModel = false;
    let ev = new CustomEvent('close');
    this.dispatchEvent(ev);
}
@api async validateFOIR(){
    this.showSpinner = true;
    let validBool = false;
     await validateFoir({oppId: this.recordId }).then(response => {
        console.log('validateFoir__'+JSON.stringify(response));
        if(response?.borrowerAllowed === 'false'){
            this.showToastMessage('', 'Calculate FOIR for Borrower', 'error');
            this.showSpinner = false;
            validBool =  false;
        } else if(response?.coBorrowerAllowed === 'false'){
            this.showToastMessage('', 'Calculate FOIR for Co-borrower', 'error');
            this.showSpinner = false;
            validBool = false;
        }else{
            this.showSpinner = false;
            validBool = true;
        }
    }).catch(error => {
        console.error('error in validateFOIR =>', error);
        this.showToastMessage('Error in validating FOIR', error, 'error');
        this.showSpinner = false;
    });
    console.log('validateFoir__bool'+validBool);
    return validBool;
}//En
connectedCallback(){
    console.log('INit');
    console.log('INit pv__'+this.isPv);
    if(this.recordId){
        console.log('connectedCallback___runemi'+this.recordId);
        getRequestDetails({ oppId: this.recordId })
        .then(response => {
          if (response) {
            console.log(response);
            this.applicantTypeList = response.appList;
            this.activeTabValue = this.applicantTypeList[0];
            this.borrowerApplicantId = response.applicantId;
            this.applicantId = response.applicantId;
            this.tabListCount = this.applicantTypeList.length;
            if(response?.coBorrowerApplicantId){
                this.coBorrowerApplicantId = response.coBorrowerApplicantId;
            }
          }
        }).catch(error => {
            console.error('error in getRequestDetails_MTD =>', error);
        });
    }else{
        console.log('connectedCallback___runemi else');
    }
}
// navigateCoborrower() {
//     this.activeTabValue = CoBorrower;
//     this.applicantId = this.coBorrowerApplicantId;
// }

handleActiveSecondSubTab(event) {
    this.activeTabValue = event.target.value;
    console.log('this.activeTabValue___'+this.activeTabValue);
    if(this.activeTabValue == this.label.Borrower){
        this.applicantId = this.borrowerApplicantId;
        console.log('this.applicantId__b'+this.applicantId);
    }
    if(this.activeTabValue == this.label.CoBorrower){
        this.applicantId = this.coBorrowerApplicantId;
        console.log('this.applicantId__cb'+this.applicantId);
    }
}

showToastMessage(title, message, variant) {
    if (title) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    } else {
        this.dispatchEvent(new ShowToastEvent({
            message: message,
            variant: variant,
        }));
    }
}

}