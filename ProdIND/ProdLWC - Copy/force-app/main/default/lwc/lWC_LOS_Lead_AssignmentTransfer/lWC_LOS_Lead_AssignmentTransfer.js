import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Id from '@salesforce/user/Id';
import LoanApphistory from '@salesforce/schema/Loan_Application_Transaction_History__c';
import Type_FIELD from '@salesforce/schema/Loan_Application_Transaction_History__c.Type__c';
import ModuleName_FIELD from '@salesforce/schema/Loan_Application_Transaction_History__c.Module_Name__c';
import getLoanApplicationTransactionHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationTransactionHistory';
import createLoanTransferHistoryRecord from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createLoanTransferHistoryRecord';
import doSmsCallout from "@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout";//CISP-6945
import reaclltranferedApplictaion from '@salesforce/apex/Recall_application.reaclltranferedApplictaion';
import getUserRole from '@salesforce/apex/Recall_application.getUserRole';
import getLoanAppTranHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanAppTranHistory';
import getLoanApplicationStageName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageName';
import checkLoanApplicationTransactionHistory from '@salesforce/apex/Recall_application.checkLoanApplicationTransactionHistory';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//CISP-6945
import State__c from '@salesforce/schema/Account.State__c';
import getBranchesOfState from '@salesforce/apex/iND_CustomLookup.getBranchesOfState';
import userId from '@salesforce/user/Id';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class LWC_LOS_Lead_AssignmentTransfer extends LightningElement {

    @track isView = true;
    @track moduleOptions;
    @track typeOptions;
    @track selectedModlue;
    @track selectedType;
    @api recordId;
    @track selectedrecordName;
    @track selectedRecordId;
    @track isDisabled = true;
    @track isModalOpen = false;
    @api currentStage;
    @track isTransferDisabled = false;
    @track isLoading = false;

    @track isRecall = false;
    @track isTransfer = false;
    @track flag = false;
    @track role;
    isRecallDisabled=false;
    @api checkleadaccess;//coming from tabloanApplicationss
    @api agentbl; //CISP:2861
    isLargeScreen = true;
    @wire(getObjectInfo, { objectApiName: LoanApphistory })
    LoanApphistoryMetadata;
    // CISP-3497
    stateOptions;
    selectedState;
     isStateSelected;
     state_Filter_Field=[];
    branchOptions;
    selectedBranch;
    @api typeofproduct //CISP-3497
    @wire(getObjectInfo, { objectApiName: 'Account' })
    AccountInfo;
    applicantId;//CISP-6945
    leadSource;//CISP-6945
    customerName;//CISP-6945
    leadnumber;//CISP-6945
    contactNumber;//CISP-6945

    @wire(getPicklistValues, { recordTypeId: '$LoanApphistoryMetadata.data.defaultRecordTypeId', fieldApiName: Type_FIELD })
    typePicklist({ data, error }) {
        if (data) {
            //  alert('data is'+JSON.stringify(data))
            this.typeOptions = data.values;
        } if (error) {
            //  alert('error is'+JSON.stringify(error))
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$LoanApphistoryMetadata.data.defaultRecordTypeId', fieldApiName: ModuleName_FIELD })
    ModulePicklist({ data, error }) {
        if (data) {
            // alert('data is'+JSON.stringify(data))
            this.moduleOptions = data.values;
        } if (error) {
            // alert('error is'+JSON.stringify(error))
        }
    };

    // CISP-3497
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: State__c })
    statePicklist({ data, error }) {
        if (data) {
            // alert('data is'+JSON.stringify(data))
            console.log('state : ',data.values)
            this.stateOptions = data.values;
        } if (error) {
             alert('error is'+JSON.stringify(error))
        }
    };
    // CISP-3497
     selectedStateHandler(event) {
        this.isStateSelected = true;
        this.selectedState = event.detail.selectedValueName;
        console.log('selected state: ',this.selectedState)
          // CISP-3497
          getBranchesOfState({State:this.selectedState,productType:this.typeofproduct, leadId:this.recordId}).then(result => {
            let lstOption = [];
            for(let i=0 ; i<result.length; i++){
              //var rec =  result[i].Account;
              lstOption.push({value: result[i].Id,label: result[i].Name });
            }
               this.branchOptions = lstOption;
               console.log('branchOptions ',this.branchOptions);
        }).catch(error => {this.error = error;
            console.log('error ',error);
                });
            
    }
     clearStateHandler(event) {
        this.isStateSelected = false;
        this.selectedState = event.detail.selectedValueName;
        this.branchOptions=[];
        try {
            if(this.template.querySelectorAll('c-generic-custom-lookup')){
                this.template.querySelectorAll('c-generic-custom-lookup').forEach(element => {
                    element.clearRecords();
                    element.clearSearchTerm();
                });
            }
        } catch (error) {
            console.log(error);
        }
    }
    // CISP-3497
    handleBranchChange(event) {
        this.selectedBranch = event.target.value;
        console.log('selected branch: ',this.selectedBranch)
    }

    openModal()
    {//CISP:2861 If agent brach code is null then dont show th pop up , show error
        console.log('The value of the agent BL code in lead transfter'+this.agentbl);
        //this.typeofproduct = this.typeofproduct=='Two Wheeler' ? 'TW' : 'PV';
        this.typeofproduct = this.typeofproduct=='Two Wheeler' ? 'TW' : this.typeofproduct == 'Tractor' ? 'Tractor': 'PV' ; //SFTRAC-2340 issue because of CISP-3497
        console.log('OUTPUT typeofproduct: ',this.typeofproduct);
        if(this.agentbl)
        {
            this.isModalOpen = true;
            this.flag = true; 
        }
        else{
            const evt = new ShowToastEvent({
                variant: 'error',mode: 'sticky', message:'Please enter the branch code first'});
            this.dispatchEvent(evt);
        }
       
    }
    closeModal() {
        this.isStateSelected = false;
        this.selectedType = '';
        this.selectedState = '';
        this.selectedBranch = '';
        this.branchOptions = [];
        if(this.template.querySelectorAll('c-generic-custom-lookup')){
            this.template.querySelectorAll('c-generic-custom-lookup').forEach(element => {
                element.clearRecords();
                element.clearSearchTerm();
            });
        }
        this.isModalOpen = false;
    }

    async connectedCallback() {
        if(this.typeofproduct == 'Two Wheeler'){
            this.isRecallDisabled = true;
        }
        // alert('loan  id is '+this.recordId);
        // alert('stage is '+this.currentStage);
        if (FORM_FACTOR === 'Large') {
            this.isLargeScreen = true;
        }else{
            this.isLargeScreen = false;
        }
        this.isDisabled = true;
        await getLoanApplicationTransactionHistory({ loanId: this.recordId, stage: this.currentStage })
            .then(result => {
                console.log('result inside 1st if', result);
                if (result == true) {
                    getLoanAppTranHistory({ loanId: this.recordId, stage: this.currentStage }).then(result => {
                        console.log('result inside if', result);
                        this.isTransfer = result;
                        this.isTransferDisabled = result;
                        this.isRecall = result;
                        if(this.typeofproduct == 'Two Wheeler'){
                            this.isRecallDisabled = true;
                        }
                    })
                        .catch(error => {
                            alert('error isd' + JSON.stringify(error));
                        });
                }else{
                    console.log('result inside else', result);

                        this.isTransfer = true;
                        this.isTransferDisabled = result;
                        this.isRecall = result;
                        if(this.typeofproduct == 'Two Wheeler'){
                            this.isRecallDisabled = true;
                        }
                }

                //  alert('result isd'+ JSON.stringify(result));
            })
            .catch(error => {
                alert('error isd' + JSON.stringify(error));
            });

            console.log('this.checkleadaccess ',this.checkleadaccess);
            if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                console.log('from tab loan');
                this.isTransferDisabled=true;
                this.isRecallDisabled=true;
            }
            await fetchLoanDetails({ opportunityId: this.recordId }).then(result => {//CISP-6945 start
                if(result?.loanApplicationDetails && result?.loanApplicationDetails.length > 0){
                this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
                this.leadnumber = result?.loanApplicationDetails[0]?.Lead_number__c;
                this.customerName = result?.loanApplicationDetails[0]?.Applicants__r[0].Name;
                this.contactNumber = result?.loanApplicationDetails[0]?.Contact_number__c;
                this.applicantId = result?.loanApplicationDetails[0]?.Applicants__r[0]?.Id;
                }
                
            });  //CISP-6945 end  
           

    }

    renderedCallback()  //Added this to refresh the stage of opprtunity CISP: 2898
    {  console.log('I am in rendercall back ')
        if(this.recordId){
            getLoanApplicationStageName({loanApplicationId: this.recordId}).then(result =>{
            this.currentStage= result;
            console.log('The current stage is ',this.currentStage)
            }).catch(error => {
                alert('error isd' + JSON.stringify(error));
            });
        }
    }
    
    handleTypeChange(event) {
        var Picklist_Value = event.target.value;
        this.selectedType = Picklist_Value;
        this.selectedModlue = this.currentStage;
        console.log('  this.currentStage', this.currentStage);
        console.log('  this.selectedModlue', this.selectedModlue);

        if (Picklist_Value == 'Module') {
            this.isDisabled = true;
        } else {
            this.isDisabled = true;
        }
    }
    handleModuleChange(event) {
        this.selectedModlue = event.target.value;
    }

    handleClick(event) {
    }

    handleSubmit(event) { //CISP: 2861

        if(this.selectedType ==null)
        {
            this.isLoading = true; 
            const evt = new ShowToastEvent({
               message:'Please select the Type first!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }
        // CISP-3497
        else if(this.selectedState==null)
        {
            this.isLoading = true; 
            const evt = new ShowToastEvent({
               message:'Please select the State first!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }
        // CISP-3497
        else if(this.selectedBranch==null)
        {
            this.isLoading = true; 
            const evt = new ShowToastEvent({
               message:'Please select the Branch first!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }

        else if(this.selectedRecordId==null)
        {
            this.isLoading = true; 
            const evt = new ShowToastEvent({
               message:'Please select the user first!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }

        else if(this.selectedType !=null && this.selectedRecordId !=null)
        {

        
        //alert('selected Module ' + this.selectedModlue)
        //alert('selected type ' + this.selectedType)

        /* getUserRole({ new_owner: this.selectedRecordId, loanID: this.recordId })
            .then(result => {
                console.log('getUserRole', result);
                this.role = result;
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            });*/ //Commented by Ruchi,as discussed with Manish ,due to causing error ind-2513
        this.isLoading = true;
        this.isModalOpen = false;
        createLoanTransferHistoryRecord({ loanId: this.recordId, stage: this.currentStage, new_owner: this.selectedRecordId, lType: this.selectedType, mod: this.selectedModlue, branch: this.selectedBranch }) // CISP-3497
            .then(result => {
                if (result == true) {
                    if(this.leadSource == 'D2C'){//CISP-6945 strat
                        let smsRequestString = {
                            'applicantId': this.applicantId,
                            'loanApplicationId': this.recordId,
                            'flag': 'LTS',
                            'contactNumber' :this.contactNumber,
                            'name'  :this.customerName,
                            'selectedUser' : this.selectedRecordId
                        };
                        doSmsCallout({ //await
                            smsRequestString: JSON.stringify(smsRequestString)
                        })
                            .then(() => {
                                if (result === "SUCCESS") {
                                    const evt = new ShowToastEvent({
                                        title: 'SMS sent sucessfully',
                                        variant: 'success',
                                });
                                }
                            }).catch(error => {
                                this.error = error;
                                console.log('Consent ERROR' + JSON.stringify(error));
                            });
                        }//CISP-6945 end
                    this.isTransferDisabled = result;
                    const evt = new ShowToastEvent({
                        title: this.selectedType + ' Submitted sucessfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    
                    this.dispatchEvent(new CustomEvent('recallnavigation'));//refreshes the page
                    /*const showevt = new ShowToastEvent({
                        title: 'When new owner accepts the Lead Assignment, comeback to this page or refresh this page.',
                        variant: 'success',
                    });
                    this.dispatchEvent(showevt);*/
                    this.isModalOpen = false;
                    this.isRecall = true;
                    if(this.typeofproduct == 'Two Wheeler'){
                        this.isRecallDisabled = true;
                    }
                    this.isLoading = false;

                }
            })
            .catch(error => {
                console.log('error', error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            });
    }
    this.isLoading = false;
}

    onRecordSelection(event) {
        this.selectedrecordName = event.detail.selectedValue;
        console.log('The selected record name is '+ this.selectedrecordName)

        this.selectedRecordId = event.detail.selectedRecordId;
        console.log('The selected record name id is '+ this.selectedRecordId)

    }

    async handleRecall() {
        console.log('handleRecall');
        this.isLoading = true;
        await checkLoanApplicationTransactionHistory({ loanId: this.recordId, stage: this.currentStage })
            .then(result => {
                console.log('result', result);
                if (result == true) {
                    reaclltranferedApplictaion({ loanId: this.recordId })
                        .then(response => {
                            console.log(response);
                            this.isLoading = false;
                            if (response == true) {
                                console.log('proxy');
                                const evt = new ShowToastEvent({
                                    title: 'Sucess',
                                    message: 'Recalled sucessfully',
                                    variant: 'success',
                                });
                                this.dispatchEvent(evt);
                                this.isTransferDisabled = false;
                                this.isRecall = false;
                                this.dispatchEvent(new CustomEvent('recallnavigation'));
                            }
                        })
                        .catch(error => {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                            });
                            this.dispatchEvent(evt);
                            this.isLoading = false;
                            console.log('error', error);
                        });
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'You Cannot Recall this module',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                alert('error isd' + JSON.stringify(error));
            });


    }
}