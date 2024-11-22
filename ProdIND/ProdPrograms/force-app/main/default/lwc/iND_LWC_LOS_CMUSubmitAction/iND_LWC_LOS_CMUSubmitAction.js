import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import changeOwner from '@salesforce/apex/LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess';
import GetLoanApplicantDetails from '@salesforce/apex/DealNumberCustomerCode.getLoanApplicantDetails';
import doCustomerMasterCreationCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerMasterCreationCallout';
import doCustomerMasterUpdationCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerMasterUpdationCallout';//SFTRAC-395
import saveCustomerRelationDetails from '@salesforce/apex/IntegrationEngine.saveCustomerRelationDetails';
import getOppIdFromCase from '@salesforce/apex/DealNumberCustomerCode.getOppIdFromCase';
import updateApplicantCustomerCode  from '@salesforce/apex/DealNumberCustomerCode.updateApplicantCustomerCode';
import getProductType from '@salesforce/apex/DealNumberCustomerCode.getProductType';
import getCoborrowerGrtDetails from '@salesforce/apex/DealNumberCustomerCode.getCoborrowerGrtDetails';
import getDistrictOptions from '@salesforce/apex/DealNumberCustomerCode.getDistrictOptions';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import updateCRFlag from '@salesforce/apex/DealNumberCustomerCode.updateCRFlag';
import getCRFlag from '@salesforce/apex/DealNumberCustomerCode.getCRFlag';
import pleaseRetry from '@salesforce/label/c.Please_Retry';


export default class IND_LWC_LOS_CMUSubmitAction extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isCommunityUser;
    /*SFTRAC-395 - Start */
    @track ispopupOpen = false;
    @track isCoborrowerExists = false;
    @track borrCutomerCode;
    borrowerdistrict;
    borrowReligion;
    borrowCaste;
    borrowerCodeUpdateStatus=false;
    coborrowerCodeUpdateStatus=false;
    coborrowerCodecreateStatus= false;
    borrowerCodecreateStatus= false;
    borrowerLoanApplicantId;
    coBorrowerLoanApplicantId;
    @track coBorrCutomerCode;
    coborrowerdistrict;
    coBorrowReligion;
    coBorrowCaste;
    boolManageButtonBorr=true;
    boolManageButtoncoBorr=true;
    @track coBorrowerLoanApplicantDisabled = true;
    @track borrowerLoanApplicantDisabled = true;
    toggleSpinner = false;
    loanId;
    /*SFTRAC-395 - End */
    isTractor;
    activeApplicantSections = ['Borrower','Co-Borrower','Beneficiary','Guarantor'];
    borrowerButtonVisible;
    @track coBorrowerApplicantMap = [];
    coBorrowerId;
    tractorBorrowerId;
    tractorBorrCutomerCode;
    @track activeSections = [];
    @track borrCutomerCode;
    borrowerdistrict;
    borrowReligion;
    borrowCaste;
    borrowerCodeUpdateStatus=false;
    coborrowerCodeUpdateStatus=false;
    coborrowerCodecreateStatus= false;
    borrowerCodecreateStatus= false;
    borrowerLoanApplicantId;
    coBorrowerLoanApplicantId;
    @track coBorrCutomerCode;
    @track tractorGrtCutomerCode;
    @track guarantorApplicantList = [];
    guarantorButtonVisible = false;
    isBeneExists;
    beneCodeUpdateStatus = false;
    beneCodecreateStatus = false;
    beneLoanApplicantId;
    beneLoanApplicantDisabled = true;
    beneLabel;
    beneCutomerCode;
    @track beneApplicantMap = [];
    beneId;
    nonIndividualTractor;
    disableSaveCR = false;
    isSaveCR = false;



    async init(){ //SFTRAC-395
        await this.getLoanApplicantDetailsHandler();
        console.log('Record ID:: ', this.recordId);
        console.log('Is Community User:: ', this.isCommunityUser);
        if(this.nonIndividualTractor){//SFTRAC-78
        await getCRFlag({loanapp:this.loanId}).then(result=>{if(result==true){
            this.disableSaveCR = true;
            this.isSaveCR = true;
        }})
    }
        if(!this.isCommunityUser){
         /*if(this.nonIndividualTractor){
                if(this.isSaveCR){ */
            this.changeOwnerOnCmuSubmitAction();
              /*  } else {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Please save the customer relation details',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.ispopupOpen = true;
                }
            }else{
            this.changeOwnerOnCmuSubmitAction();
            }        
        }  */
    }
    }
    connectedCallback(){
        this.init(); //SFTRAC-395
        /*this.getLoanApplicantDetailsHandler();
        console.log('Record ID:: ', this.recordId);
        console.log('Is Community User:: ', this.isCommunityUser);
        if(!this.isCommunityUser){
            this.changeOwnerOnCmuSubmitAction();
        }*/
    }
    get generateBorrower(){ //SFTRAC-395
        if(this.borrCutomerCode && this.boolManageButtonBorr && !this.borrowerCodecreateStatus){
            return 'Update Customer Code (Borrower)';
        }else{
            this.boolManageButtonBorr=false;
            return 'Generate Customer Code (Borrower)';
        }
    }

    //This method is also called from LWC in case of community User
    @api changeOwnerOnCmuSubmitAction(){
        changeOwner({caseId : this.recordId}).then(response => {
            const res = JSON.parse(response);
            console.log('connectedCallback - Response::'+ response);
    
            const evt = new ShowToastEvent({
                title: res.message,
                message: res.reason,
                variant: 'success',
            });

            this.dispatchEvent(evt);
            if(res.message.includes('Please Generate Customer code')){ //SFTRAC-395
                this.ispopupOpen = true;
                //this.getLoanApplicantDetailsHandler();
            } else if (res.message.includes('Please Save Customer Relation')){ //SFTRAC-395
                this.ispopupOpen = true;
                //this.getLoanApplicantDetailsHandler();
            }
            if((!res.message.includes('Please re-upload the following documents')) && (!res.message.includes('Please Generate Customer code')) && (!res.message.includes('Please Save Customer Relation'))){
                eval("$A.get('e.force:refreshView').fire();");
                this.navigateToCaseHome();
            }
        }).catch(error => {
            console.log('error::',error)
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            eval("$A.get('e.force:refreshView').fire();");
        });        
    }
    async getLoanApplicantDetailsHandler(){
        await getOppIdFromCase({ caseId : this.recordId })
          .then(result => {
            console.log('Result', result);
            this.loanId = result;
          })
          .catch(error => {
            console.error('Error:', error);
        });

        await getProductType({ loanApplicationId : this.loanId}).then(result => {
            if(result == 'Tractor'){
                this.isTractor = true;
            }
        }).catch(error => {
            console.error('Error:', error);
        });

        await GetLoanApplicantDetails({ loanApplicationId: this.loanId }).then((data)=>{
            try{
                if (data) {
                    for (let applicant of data) {
                        console.log('res  ' ,applicant);
                        console.log(applicant.Applicant_Type__c);
                        if(applicant.Opportunity__r.Product_Type__c == 'Tractor' && applicant.Opportunity__r.Customer_Type__c == 'Non-Individual')
                        this.nonIndividualTractor = true;
                        if (applicant.Applicant_Type__c.includes('Borrower')) {
                            this.borrowerCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;//CISP-4263
                            this.borrowerCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;//CISP-5382
                            this.borrowerLoanApplicantId = applicant.Id;
                            this.borrowerButtonVisible = true;
                            this.borrowerLoanApplicantDisabled =this.borrowerCodeUpdateStatus || this.borrowerCodecreateStatus ? true: false //CISP_4263
                            
                            if (applicant.Customer_Code__c) {
                                this.borrCutomerCode = applicant.Customer_Code__c;
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        this.borrCutomerCode = res.Customer_Code__c;
                                    }
                                }
                            }
                            if (applicant.Documents__r) {
                                for (let res of applicant.Documents__r) {
                                    console.log(res);
                                        if(res.KYC_District__c){
                                            this.borrowerdistrict = res.KYC_District__c;
                                        }else if(res.KYC_City__c && (this.borrowerdistrict == '' || this.borrowerdistrict == null || this.borrowerdistrict == undefined)){
                                            this.borrowerdistrict = res.KYC_City__c;
                                        }
                                    
                                }
                                console.log(this.borrowerdistrict);
                                
                            }
                            if(applicant.Religion__c){
                                this.borrowReligion = applicant.Religion__c;
                            }
                            if(applicant.Caste__c){
                                this.borrowCaste = applicant.Caste__c;
                            }
                        } else if (applicant.Applicant_Type__c.includes('Co-borrower')) {
                            this.isCoborrowerExists = true;
                            this.coborrowerCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;//CISP-4263
                            this.coborrowerCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;//CISP-5382
                            this.coBorrowerLoanApplicantId = applicant.Id;
                            this.coBorrowerLoanApplicantDisabled=this.coborrowerCodeUpdateStatus || this.coborrowerCodecreateStatus? true: false //CISP_4263
                            this.coBorrowerLabel = 'Customer Code ('+applicant.Name+') - Coborrower';
                            this.coBorrCutomerCode = '';
                            if (applicant.Customer_Code__c) {
                                console.log(applicant.Customer_Code__c);
                                this.coBorrCutomerCode = applicant.Customer_Code__c;
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        console.log(res.Customer_Code__c);
                                        this.coBorrCutomerCode = res.Customer_Code__c;
                                    }
                                }
                            }
                            this.coBorrowerApplicantMap.push({key:this.coBorrowerLabel,customerCode:this.coBorrCutomerCode,id:applicant.Id,dis:this.coBorrowerLoanApplicantDisabled}); 
                            if (applicant.Documents__r) {
                                for (let res of applicant.Documents__r) {
                                        if(res.KYC_District__c){
                                            this.coborrowerdistrict = res.KYC_District__c;
                                        }else if(res.KYC_City__c && (this.coborrowerdistrict == undefined || this.coborrowerdistrict == '' || this.coborrowerdistrict == '')){
                                            this.coborrowerdistrict = res.KYC_City__c;
                                        }
                                }
                            }
                            if(applicant.Religion__c){
                                this.coBorrowReligion = applicant.Religion__c;
                            }
                            if(applicant.Caste__c){
                                this.coBorrowCaste = applicant.Caste__c;
                            }
                        }
                        else if (applicant.Opportunity__r.Product_Type__c == 'Tractor' && applicant.Applicant_Type__c.includes('Guarantor')){
                            console.log('entering--');
                            this.grtCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;//CISP-4263
                            this.grtCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;//CISP-5382
                            this.guarantorButtonVisible = true;
                            this.grtLoanApplicantDisabled =this.grtCodeUpdateStatus || this.grtCodecreateStatus ? true: false //CISP_4263
                            this.grtLabel = 'Customer Code ('+applicant.Name+') - Guarantor';
                            if (applicant.Customer_Code__c) {
                                console.debug(applicant.Customer_Code__c);
                                this.tractorGrtCutomerCode = applicant.Customer_Code__c;
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        console.debug(res.Customer_Code__c);
                                        this.tractorGrtCutomerCode = res.Customer_Code__c;
                                    }
                                }
                            }
                            this.guarantorApplicantList.push({key:this.grtLabel,customerCode:this.tractorGrtCutomerCode,id:applicant.Id,dis:this.grtLoanApplicantDisabled});
                        }
                        else if(applicant.Opportunity__r.Product_Type__c == 'Tractor' && applicant.Opportunity__r.Customer_Type__c == 'Non-Individual' && applicant.Applicant_Type__c.includes('Beneficiary')){
                            this.isBeneExists = true;
                            this.beneCodeUpdateStatus = applicant.IND_Customer_Master_Updation_Status__c;//CISP-4263
                            this.beneCodecreateStatus = applicant.IND_Customer_Master_Creation_Status__c;//CISP-5382
                            this.beneLoanApplicantId = applicant.Id;
                            this.beneLoanApplicantDisabled=this.beneCodeUpdateStatus || this.beneCodecreateStatus? true: false //CISP_4263
                            this.beneLabel = 'Customer Code ('+applicant.Name+') - Beneficiary';
                            this.beneCutomerCode = '';
                            if (applicant.Customer_Code__c) {
                                console.log(applicant.Customer_Code__c);
                                this.beneCutomerCode = applicant.Customer_Code__c;
                            }
                            if (applicant.Customer_Dedupe_Response__r) {
                                for (let res of applicant.Customer_Dedupe_Response__r) {
                                    if (res.Customer_Code__c) {
                                        console.log(res.Customer_Code__c);
                                        this.beneCutomerCode = res.Customer_Code__c;
                                    }
                                }
                            }
                            this.beneApplicantMap.push({key:this.beneLabel,customerCode:this.beneCutomerCode,id:applicant.Id,dis:this.beneLoanApplicantDisabled}); 
                        }
                        else {
                            this.borrowerLoanApplicantDisabled = true
                            this.coBorrowerLoanApplicantDisabled = true;
                        } 
                    }
                    console.log('beneexists---'+this.isBeneExists)
                    console.log('benemap--'+this.beneApplicantMap);
                }
            }catch(err){
                console.error(err);
            }
        }).catch(error=>{
            console.log("Error in getting loan application details",JSON.stringify(error));
        });
        
    }
    navigateToCaseHome(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'}
        });
    }
    handleGenerateBorrowerCode() {
        //CISP-4263
        this.borrowerLoanApplicantDisabled = true;
        let customerMaster = doCustomerMasterCreationCallout;
        let isCustomerMaster=false;
        
        
        if (this.borrowReligion!= null && this.borrowCaste!= null && this.borrowerdistrict!= null) {
            this.toggleSpinner = true;
            console.log(this.borrowerdistrict);
            //CISP-4263
            if(this.borrCutomerCode){
                customerMaster=  doCustomerMasterUpdationCallout;
                isCustomerMaster=true;
            }
            customerMaster({
                    applicantId: this.borrowerLoanApplicantId,
                    loanAppId: this.loanId,
                    religion: this.borrowReligion,
                    caste: this.borrowCaste,
                    district: this.borrowerdistrict
                })
                .then((result) => {
                    if (result) {
                        if(result != 'Customer code is already created.') {//CISP-3799
                        var res = JSON.parse(result);
                        try{
                        if ((res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code) ||(this.borrCutomerCode && res.response.status =='SUCCESS')) {
                            if(!this.borrCutomerCode){
                            var borrowerCutomerCode = res.response.content[0].Customer_Code;
                            this.borrCutomerCode = borrowerCutomerCode;
                        }
                            updateApplicantCustomerCode({
                                loanApplicationId: this.loanId,
                                applicantId: this.borrowerLoanApplicantId,
                                customerCode: this.borrCutomerCode,
                                customerMasterStatus: isCustomerMaster,
                                customerCreationStatus: this.boolManageButtonBorr,
                                religion: this.borrowReligion,
                                caste: this.borrowCaste,
                            })
                            .then((result) => {
                                    this.borrowerLoanApplicantDisabled = true;
                                    this.borrowerCodeUpdateStatus=true;
                            }).catch((error) => {
                                this.toggleSpinner = false;
                                console.log(error);
                                this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                                this.borrowerLoanApplicantDisabled = false;
                            });
                        } else {
                            this.borrowerLoanApplicantDisabled = false;
                            this.showError('Borrower Customer Code', pleaseRetry);
                        }
                        }catch(err){
                            this.showError('Borrower Customer Code', pleaseRetry);
                            this.borrowerLoanApplicantDisabled = false;
                        }
                    } else {//CISP-3799
                        this.showError('Borrower Customer Code', result);
                        this.borrowerLoanApplicantDisabled = false;
                    }//CISP-3799
                    } else {
                        this.showError('Borrower Customer Code', pleaseRetry);
                        this.borrowerLoanApplicantDisabled = false;
                    }
                    this.toggleSpinner = false;
                }).catch((error) => {
                    this.toggleSpinner = false;
                    console.log(error);
                    this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                    this.borrowerLoanApplicantDisabled = false;
                });
            
        } else {
            this.showError('Borrower Customer Code', 'District/Religion/Caste values are missing');
            this.borrowerLoanApplicantDisabled = false;
        }
    }
    handleGenerateCoBorrowerCode() {
        this.coBorrowerLoanApplicantDisabled = true;
        let customerMaster = doCustomerMasterCreationCallout;
        let isCustomerMaster=false;
        
        if (this.coBorrowReligion && this.coBorrowCaste &&  this.coborrowerdistrict) {
            this.toggleSpinner = true;
            //CISP-4263
            if(this.coBorrCutomerCode){
               customerMaster=  doCustomerMasterUpdationCallout;
               isCustomerMaster=true;
            }
            customerMaster({
                    applicantId: this.coBorrowerLoanApplicantId,
                    loanAppId: this.loanId,
                    religion: this.coBorrowReligion,
                    caste: this.coBorrowCaste,
                    district: this.coborrowerdistrict
                })
                .then((result) => {
                    if (result) {
                        if(result != 'Customer code is already created.') { //CISP-3799
                        var res = JSON.parse(result);
                        console.log(res);
                        if (res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code ||(this.coBorrCutomerCode && res.response.status =='SUCCESS')) {
                           if(!this.coBorrCutomerCode){
                            var coBorrowerCutomerCode = res.response.content[0].Customer_Code;
                            this.coBorrCutomerCode = coBorrowerCutomerCode;
                        }
                            updateApplicantCustomerCode({
                                loanApplicationId: this.loanId,
                                applicantId: this.coBorrowerLoanApplicantId,
                                customerCode: this.coBorrCutomerCode,
                                customerMasterStatus: isCustomerMaster,
                                customerCreationStatus: this.boolManageButtoncoBorr,
                                religion: this.coBorrowReligion,
                                caste: this.coBorrowCaste,
                            })
                            .then((result) => {
                                    this.coBorrowerLoanApplicantDisabled = true;
                                    this.coborrowerCodeUpdateStatus=true;
                           }).catch((error) => {
                                this.toggleSpinner = false;
                                console.log(error);
                                this.showError('Co-Borrower Customer Code', error.body ? error.body.message : '');
                                this.coBorrowerLoanApplicantDisabled = false;
                            });
                        } else {
                            this.showError('Co-Borrower Customer Code', pleaseRetry);
                            this.coBorrowerLoanApplicantDisabled = false;
                        }
                        } else { //CISP-3799
                            this.showError('Borrower Customer Code', result);
                            this.coBorrowerLoanApplicantDisabled = false;
                        } //CISP-3799
                    } else {
                        this.coBorrowerLoanApplicantDisabled = false;
                        this.showError('Co-Borrower Customer Code', pleaseRetry);
                    }
                    this.toggleSpinner = false;
                }).catch((error) => {
                    this.toggleSpinner = false;
                    this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                    this.coBorrowerLoanApplicantDisabled = false;
                });
        } else {
            this.showError('Borrower Customer Code', 'District/Religion/Caste values are missing');
            this.coBorrowerLoanApplicantDisabled = false;
        }

    }
    handleGenerateTractorBorrowerCode() {
        //this.tractorBorrowerId = event.target.value;
       // console.log('Id---'+ this.tractorBorrowerId);
        this.borrowerLoanApplicantDisabled = true;
        let customerMaster = doCustomerMasterCreationCallout;
        let isCustomerMaster=false;
        let tractorBoolManageButtonBorr = false;
        this.toggleSpinner = true;
        if(this.tractorBorrowerId){
         tractorBoolManageButtonBorr = true;
        }

       getCoborrowerGrtDetails({ loanApplicantId: this.borrowerLoanApplicantId }).then((data)=>{
        try{
           console.log(data);
            if (data) {
                for (let applicant of data) {
                            var religionField = applicant.Religion__c;
                            var casteField = applicant.Caste__c;
                            this.borrCutomerCode = applicant.Customer_Code__c;
                        
                        if (applicant.Documents__r) {
                           for (let res of applicant.Documents__r) {
                               var borrowerdistrict = res.KYC_District__c;
                               var tractorBorrowerDocId = res.Id;
                           }
                        }     
                       if (applicant.Customer_Dedupe_Response__r) {
                            for (let res of applicant.Customer_Dedupe_Response__r) {
                                if (res.Customer_Code__c) {
                                   this.borrCutomerCode = res.Customer_Code__c;     
                                }
                            }
                         }
                       }
           }
           if(this.borrCutomerCode){
               customerMaster=  doCustomerMasterUpdationCallout;
               isCustomerMaster=true;
            }
           if((religionField && casteField) || this.nonIndividualTractor){ 
               customerMaster({
                    applicantId: this.borrowerLoanApplicantId,
                    loanAppId: this.loanId,
                    religion: religionField,
                    caste: casteField,
                    district: borrowerdistrict
                })
                .then((result) => {
                    if (result) {
                        var res = JSON.parse(result);
                        console.debug(res);
                        if (res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code ||(this.borrCutomerCode && res.response.status =='SUCCESS')) {
                            if(!this.borrCutomerCode){ 
                            var borrowerCutomerCode = res.response.content[0].Customer_Code;
                            this.borrCutomerCode = borrowerCutomerCode;
                            }
                            updateApplicantCustomerCode({
                                loanApplicationId: this.loanId,
                                applicantId: this.borrowerLoanApplicantId,
                                customerCode: this.borrCutomerCode,
                                religion: religionField,
                                caste: casteField,
                                district: borrowerdistrict,
                                POADocumentId: tractorBorrowerDocId,
                                customerMasterStatus: isCustomerMaster,
                                customerCreationStatus: tractorBoolManageButtonBorr
                            })
                            .then((result) => {
                                if(res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code )
                                {
                                    this.showToast('Success !','Customer Code for Borrower Generated Successfully!!','success');

                                } else 
                                {
                                    this.showToast('Success !','Customer Code for Borrower Updated Successfully!!','success');
                                }
                                    this.borrowerLoanApplicantDisabled = true;
                                    this.borrowerCodeUpdateStatus=true;
                                    this.toggleSpinner = false;
                            }).catch((error) => {
                                this.errorMsg = error;
                                this.toggleSpinner = false;
                                console.debug('error---'+error);
                                this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                                this.borrowerLoanApplicantDisabled = false;
                            });
                        } else {
                            this.showError('Borrower Customer Code', pleaseRetry);
                            this.borrowerLoanApplicantDisabled = false;
                            this.toggleSpinner = false;
                        }
                    } else {
                        this.borrowerLoanApplicantDisabled = false;
                        this.showError('Borrower Customer Code', pleaseRetry);
                        this.toggleSpinner = false;
                    }
                    this.toggleSpinner = false;
                }).catch((error) => {
                    this.errorMsg = error;
                    this.toggleSpinner = false;
                    console.debug('error1---'+error);
                    this.showError('Borrower Customer Code', error.body ? error.body.message : '');
                    this.borrowerLoanApplicantDisabled = false;
                });
           }else {
            this.showError('Borrower Customer Code', mandotoryDetailsNotProvide);
            this.borrowerLoanApplicantDisabled = false;
            this.toggleSpinner = false;

        }

    }catch(err){
       console.error(err);
   }
}).catch(error=>{
   console.log("Error in getting loan applicant details",JSON.stringify(error));
});
}
handleGenerateTractorCoBorrowerCode(event) {
    this.coBorrowerId = event.target.value;
    this.coBorrowerLoanApplicantDisabled = true;
    let customerMaster = doCustomerMasterCreationCallout;
    let isCustomerMaster=false;
    let tractorBoolManageButtoncoBorr = false;
    this.toggleSpinner = true;


   getCoborrowerGrtDetails({ loanApplicantId: this.coBorrowerId }).then((data)=>{
    try{
       //console.log(data);
        if (data) {
            for (let applicant of data) {
                        var religionField = applicant.Religion__c;
                        var casteField = applicant.Caste__c;
                        this.coBorrCutomerCode = applicant.Customer_Code__c;
                    
                    if (applicant.Documents__r) {
                       for (let res of applicant.Documents__r) {
                           var coborrowerdistrict = res.KYC_District__c;
                           var tractorCoborrowerDocId = res.Id;
                       }
                    }     
                   if (applicant.Customer_Dedupe_Response__r) {
                        for (let res of applicant.Customer_Dedupe_Response__r) {
                            if (res.Customer_Code__c) {
                               this.coBorrCutomerCode = res.Customer_Code__c;     
                            }
                        }
                     }
                   }
       }
       if(this.coBorrCutomerCode){
           customerMaster=  doCustomerMasterUpdationCallout;
           tractorBoolManageButtoncoBorr = true;
           isCustomerMaster=true;
        }

       if(religionField && casteField){
           customerMaster({
                applicantId: this.coBorrowerId,
                loanAppId: this.loanId,
                religion: religionField,
                caste: casteField,
                district: coborrowerdistrict
            })
            .then((result) => {
                if (result) {
                    var res = JSON.parse(result);
                    if (res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code ||(this.coBorrCutomerCode && res.response.status =='SUCCESS')) {
                       if(!this.coBorrCutomerCode){ 
                       var coBorrowerCutomerCode = res.response.content[0].Customer_Code;
                        this.coBorrCutomerCode = coBorrowerCutomerCode;
                      
                        for(let cobcode of this.coBorrowerApplicantMap){
                           if(cobcode.id == this.coBorrowerId){
                               cobcode.customerCode = this.coBorrCutomerCode;
                           }
                       }
                   }                           
                        updateApplicantCustomerCode({
                            loanApplicationId: this.loanId,
                            applicantId: this.coBorrowerId,
                            customerCode: this.coBorrCutomerCode,
                            religion: religionField,
                            caste: casteField,
                            district: coborrowerdistrict,
                            POADocumentId: tractorCoborrowerDocId,
                            customerMasterStatus: isCustomerMaster,
                            customerCreationStatus: tractorBoolManageButtoncoBorr
                        })
                        .then((result) => {
                           for(let cobcode of this.coBorrowerApplicantMap){
                               if(cobcode.id == this.coBorrowerId){
                                   cobcode.dis = true;
                               }
                           }
                           if(res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code )
                           {
                               this.showToast('Success !','Customer Code for Co-Borrower Generated Successfully!!','success');

                           } else 
                           {
                               this.showToast('Success !','Customer Code for Co-Borrower Updated Successfully!!','success');
                           }
                                this.coBorrowerLoanApplicantDisabled = true;
                                this.coborrowerCodeUpdateStatus=true;
                                this.toggleSpinner = false;
                        }).catch((error) => {
                            this.errorMsg = error;
                            this.toggleSpinner = false;
                            console.debug(error);
                            this.showError('Co-Borrower Customer Code', error.body ? error.body.message : '');
                            for(let cobcode of this.coBorrowerApplicantMap){
                               if(cobcode.id == this.coBorrowerId){
                                   cobcode.dis = false;
                               }
                           }
                            this.coBorrowerLoanApplicantDisabled = false;
                        });
                    } else {
                        this.showError('Co-Borrower Customer Code', pleaseRetry);
                        this.coBorrowerLoanApplicantDisabled = false;
                        this.toggleSpinner = false;
                        for(let cobcode of this.coBorrowerApplicantMap){
                           if(cobcode.id == this.coBorrowerId){
                               cobcode.dis = false;
                           }
                       }
                    }
                } else {
                    this.coBorrowerLoanApplicantDisabled = false;
                    this.showError('Co-Borrower Customer Code', pleaseRetry);
                    this.toggleSpinner = false;
                    for(let cobcode of this.coBorrowerApplicantMap){
                       if(cobcode.id == this.coBorrowerId){
                           cobcode.dis = false;
                       }
                   }
                }
                this.toggleSpinner = false;
            }).catch((error) => {
                this.errorMsg = error;
                this.toggleSpinner = false;
                this.showError('Co-Borrower Customer Code!', error.body ? error.body.message : '');
                this.coBorrowerLoanApplicantDisabled = false;
                for(let cobcode of this.coBorrowerApplicantMap){
                   if(cobcode.id == this.coBorrowerId){
                       cobcode.dis = false;
                   }
               }
            });
       }else {
        this.showError('Co-Borrower Customer Code', mandotoryDetailsNotProvide);
        this.coBorrowerLoanApplicantDisabled = false;
        for(let cobcode of this.coBorrowerApplicantMap){
           if(cobcode.id == this.coBorrowerId){
               cobcode.dis = false;
           }
       }
        this.toggleSpinner = false;
    }

}catch(err){
   console.error(err);
}
}).catch(error=>{
console.log("Error in getting loan applicant details",JSON.stringify(error));
});
}

handleGenerateTractorBeneCode(event) {
    this.beneId = event.target.value;
    this.beneLoanApplicantDisabled = true;
    let customerMaster = doCustomerMasterCreationCallout;
    let isCustomerMaster=false;
    let tractorBoolManageButtonBene = false;
    this.toggleSpinner = true;


   getCoborrowerGrtDetails({ loanApplicantId: this.beneId }).then((data)=>{
    try{
       //console.log(data);
        if (data) {
            for (let applicant of data) {
                        var religionField = applicant.Religion__c;
                        var casteField = applicant.Caste__c;
                        this.beneCutomerCode = applicant.Customer_Code__c;
                    
                    if (applicant.Documents__r) {
                       for (let res of applicant.Documents__r) {
                           var beneDistrict = res.KYC_District__c;
                           var tractorBeneDocId = res.Id;
                       }
                    }     
                   if (applicant.Customer_Dedupe_Response__r) {
                        for (let res of applicant.Customer_Dedupe_Response__r) {
                            if (res.Customer_Code__c) {
                               this.beneCutomerCode = res.Customer_Code__c;     
                            }
                        }
                     }
                   }
       }
       if(this.beneCutomerCode){
           customerMaster=  doCustomerMasterUpdationCallout;
           tractorBoolManageButtonBene = true;
           isCustomerMaster=true;
        }

       if(religionField && casteField){
           customerMaster({
                applicantId: this.beneId,
                loanAppId: this.loanId,
                religion: religionField,
                caste: casteField,
                district: beneDistrict
            })
            .then((result) => {
                if (result) {
                    var res = JSON.parse(result);
                    if (res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code ||(this.beneCutomerCode && res.response.status =='SUCCESS')) {
                       if(!this.beneCutomerCode){ 
                       var beneficiaryCutomerCode = res.response.content[0].Customer_Code;
                        this.beneCutomerCode = beneficiaryCutomerCode;
                      
                        for(let becode of this.beneApplicantMap){
                           if(becode.id == this.beneId){
                            becode.customerCode = this.beneCutomerCode;
                           }
                       }
                   }                           
                        updateApplicantCustomerCode({
                            loanApplicationId: this.loanId,
                            applicantId: this.beneId,
                            customerCode: this.beneCutomerCode,
                            religion: religionField,
                            caste: casteField,
                            district: beneDistrict,
                            POADocumentId: tractorBeneDocId,
                            customerMasterStatus: isCustomerMaster,
                            customerCreationStatus: tractorBoolManageButtonBene
                        })
                        .then((result) => {
                           for(let becode of this.beneApplicantMap){
                               if(becode.id == this.beneId){
                                becode.dis = true;
                               }
                           }
                           if(res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code )
                           {
                               this.showToast('Success !','Customer Code for Beneficiary Generated Successfully!!','success');

                           } else 
                           {
                               this.showToast('Success !','Customer Code for Beneficiary Updated Successfully!!','success');
                           }
                                this.beneLoanApplicantDisabled = true;
                                this.beneCodeUpdateStatus=true;
                                this.toggleSpinner = false;
                        }).catch((error) => {
                            this.errorMsg = error;
                            this.toggleSpinner = false;
                            console.debug(error);
                            this.showError('Beneficiary Customer Code', error.body ? error.body.message : '');
                            for(let becode of this.beneApplicantMap){
                               if(becode.id == this.beneId){
                                becode.dis = false;
                               }
                           }
                            this.beneLoanApplicantDisabled = false;
                        });
                    } else {
                        this.showError('Beneficiary Customer Code', pleaseRetry);
                        this.beneLoanApplicantDisabled = false;
                        this.toggleSpinner = false;
                        for(let becode of this.beneApplicantMap){
                           if(becode.id == this.beneId){
                            becode.dis = false;
                           }
                       }
                    }
                } else {
                    this.beneLoanApplicantDisabled = false;
                    this.showError('Beneficiary Customer Code', pleaseRetry);
                    this.toggleSpinner = false;
                    for(let becode of this.beneApplicantMap){
                       if(becode.id == this.beneId){
                        becode.dis = false;
                       }
                   }
                }
                this.toggleSpinner = false;
            }).catch((error) => {
                this.errorMsg = error;
                this.toggleSpinner = false;
                this.showError('Beneficiary Customer Code!', error.body ? error.body.message : '');
                this.beneLoanApplicantDisabled = false;
                for(let becode of this.beneApplicantMap){
                   if(becode.id == this.beneId){
                    becode.dis = false;
                   }
               }
            });
       }else {
        this.showError('Beneficiary Customer Code', mandotoryDetailsNotProvide);
        this.beneLoanApplicantDisabled = false;
        for(let becode of this.beneApplicantMap){
           if(becode.id == this.beneId){
            becode.dis = false;
           }
       }
        this.toggleSpinner = false;
    }

}catch(err){
   console.error(err);
}
}).catch(error=>{
console.log("Error in getting loan applicant details",JSON.stringify(error));
});
}

handleGenerateTractorGrtCode(event) {
this.grtId = event.target.value;
this.grtLoanApplicantDisabled = true;
let customerMaster = doCustomerMasterCreationCallout;
let isCustomerMaster=false;
let tractorBoolManageButtonGrt = false;
this.toggleSpinner = true;


getCoborrowerGrtDetails({ loanApplicantId: this.grtId }).then((data)=>{
try{
console.log(data);
if (data) {
   for (let applicant of data) {
               var religionField = applicant.Religion__c;
               var casteField = applicant.Caste__c;
               this.tractorGrtCutomerCode = applicant.Customer_Code__c;
           
           if (applicant.Documents__r) {
              for (let res of applicant.Documents__r) {
                  var grtDistrict = res.KYC_District__c;
                  var tractorGrtDocId = res.Id;
              }
           }     
          if (applicant.Customer_Dedupe_Response__r) {
               for (let res of applicant.Customer_Dedupe_Response__r) {
                   if (res.Customer_Code__c) {
                       this.tractorGrtCutomerCode = res.Customer_Code__c;     
                   }
               }
            }
          }
}
if(this.tractorGrtCutomerCode){
  customerMaster=  doCustomerMasterUpdationCallout;
  tractorBoolManageButtonGrt = true;
  isCustomerMaster=true;
}

if(religionField && casteField){
  customerMaster({
       applicantId: this.grtId,
       loanAppId: this.loanId,
       religion: religionField,
       caste: casteField,
       district: grtDistrict
   })
   .then((result) => {
       if (result) {
           var res = JSON.parse(result);
           console.debug(res);
           if (res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code ||(this.tractorGrtCutomerCode && res.response.status =='SUCCESS')) {
               if(!this.tractorGrtCutomerCode){ 
               var grtCutomerCode = res.response.content[0].Customer_Code;
               this.tractorGrtCutomerCode = grtCutomerCode;
               for(let grtcode of this.guarantorApplicantList){
                   if(grtcode.id == this.grtId){
                       grtcode.customerCode = this.tractorGrtCutomerCode;
                   }
               }
               }
               updateApplicantCustomerCode({
                   loanApplicationId: this.loanId,
                   applicantId: this.grtId,
                   customerCode: this.tractorGrtCutomerCode,
                   religion: religionField,
                   caste: casteField,
                   district: grtDistrict,
                   POADocumentId: tractorGrtDocId,
                   customerMasterStatus: isCustomerMaster,
                   customerCreationStatus: tractorBoolManageButtonGrt
               })
               .then((result) => {
                   if(res.response.content && res.response.content.length > 0 && res.response.content[0].Customer_Code )
                           {
                               this.showToast('Success !','Customer Code for Guarantor Generated Successfully!!','success');

                           } else 
                           {
                               this.showToast('Success !','Customer Code for Guarantor Updated Successfully!!','success');
                           }
                           for(let grtcode of this.guarantorApplicantList){
                               if(grtcode.id == this.grtId){
                                   grtcode.dis = true;
                               }
                           }
                       this.grtLoanApplicantDisabled = true;
                       this.coborrowerCodeUpdateStatus=true;
                       this.toggleSpinner = false;
               }).catch((error) => {
                   this.errorMsg = error;
                   this.toggleSpinner = false;
                   console.debug(error);
                   this.showError('Guarantor Customer Code', error.body ? error.body.message : '');
                   for(let grtcode of this.guarantorApplicantList){
                       if(grtcode.id == this.grtId){
                           grtcode.dis = false;
                       }
                   }
                   this.grtLoanApplicantDisabled = false;
               });
           } else {
               this.showError('Guarantor Customer Code', pleaseRetry);
               this.grtLoanApplicantDisabled = false;
               for(let grtcode of this.guarantorApplicantList){
                   if(grtcode.id == this.grtId){
                       grtcode.dis = false;
                   }
               }
               this.toggleSpinner = false;
           }
       } else {
           this.grtLoanApplicantDisabled = false;
           this.showError('Guarantor Customer Code', pleaseRetry);
           for(let grtcode of this.guarantorApplicantList){
               if(grtcode.id == this.grtId){
                   grtcode.dis = false;
               }
           }
           this.toggleSpinner = false;
       }
       this.toggleSpinner = false;
   }).catch((error) => {
       this.errorMsg = error;
       this.toggleSpinner = false;
       this.showError('Guarantor Customer Code', error.body ? error.body.message : '');
       for(let grtcode of this.guarantorApplicantList){
           if(grtcode.id == this.grtId){
               grtcode.dis = false;
           }
       }
       this.grtLoanApplicantDisabled = false;
   });
}else {
this.showError('Guarantor Customer Code', mandotoryDetailsNotProvide);
for(let grtcode of this.guarantorApplicantList){
   if(grtcode.id == this.grtId){
       grtcode.dis = false;
   }
}
this.grtLoanApplicantDisabled = false;
this.toggleSpinner = false;
}

}catch(err){
console.error(err);
}
}).catch(error=>{
console.log("Error in getting loan applicant details",JSON.stringify(error));
});
}
renderedCallback(){ //SFTRAC-78
    if(this.nonIndividualTractor){
    GetLoanApplicantDetails({ loanApplicationId: this.loanId }).then((data)=>{
            if (data) {
                this.disableSaveCR = false;
                for (let applicant of data) {
                    console.log('customercode-----'+applicant.Customer_Code__c);  
                    if (applicant.Customer_Code__c == null || applicant.Customer_Code__c == '' || applicant.Customer_Code__c == undefined || this.isSaveCR == true) {
                        this.disableSaveCR = true;  
                        console.log('savecustomerrelation----'+this.disableSaveCR);
                    }
                    }
                }
            })
        }
}
handleSaveCR(){ //SFTRAC-78
    this.toggleSpinner = true;
    saveCustomerRelationDetails({borrCusCode: this.borrCutomerCode, loanapp: this.loanId }).then(result=>{console.log('result----'+result);
    if(result == 'success'){
        const toastevent = new ShowToastEvent({
            title: 'Success',
            message: 'Customer Relation Saved Successfully',
            variant: 'success'

        });
        this.dispatchEvent(toastevent);
       // this.disableSaveCR = true;
        updateCRFlag({loanapp: this.loanId}).then(result=>{this.isSaveCR = true;this.disableSaveCR = true;
            this.toggleSpinner = false;}).catch(error=>{this.toggleSpinner = false;})
    } else {
        const toastevent = new ShowToastEvent({
            title: 'Error',
            message: 'Save Customer Relation Details failed. Please try again',
            variant: 'error'

        });
        this.dispatchEvent(toastevent);
        this.toggleSpinner = false;
    }
}).catch(error=>{this.toggleSpinner = false;})
}
    showError(title, errorMessage) { //SFTRAC-395
        const evt = new ShowToastEvent({
            title: title,
            message: errorMessage,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
    showToast(title, message, variant){
        const toastevent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant

        });
        this.dispatchEvent(toastevent);
    }     
    handleSubmit(){ //SFTRAC-395
        if(this.nonIndividualTractor){ //SFTRAC-78
            if(this.isSaveCR){
        this.changeOwnerOnCmuSubmitAction();
            } else {
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please save the customer relation details',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            }
        }else{
        this.changeOwnerOnCmuSubmitAction();
        }
    }
}