import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Message_CVO_User_Access from '@salesforce/label/c.Message_CVO_User_Access';
import Message_No_Transaction_HIstory from '@salesforce/label/c.Message_No_Transaction_HIstory';
import UpdateToastMsg from '@salesforce/label/c.UpdateToastMsg';
import Message_remark from '@salesforce/label/c.Message_remark';
import Please_fill_all_the_mandatory_fields from '@salesforce/label/c.Please_fill_all_the_mandatory_fields';
import updateCAM from '@salesforce/apex/CAMController.updateCAM';
import getRelatedCam from '@salesforce/apex/CAMController.getRelatedCAM';
//CISP-2610-START
import loanApplicationRevoke from '@salesforce/apex/IND_RevokeController.loanApplicationRevoke';
import upsertRecordDetails from '@salesforce/apex/IND_RevokeController.upsertRecordDetails';
import updateClonedLoanApplicationOwner from '@salesforce/apex/IND_RevokeController.updateClonedLoanApplicationOwner';
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';

import CIBIL_DETAILS_OBJECT from '@salesforce/schema/CIBIL_Details__c';
import CIBIL_MAKER_DATE from '@salesforce/schema/CIBIL_Details__c.Maker_Date__c';
import AMOUNT_OVERDUE_FIELD from '@salesforce/schema/CIBIL_Details__c.Amount_Overdue__c';
import CIBIL_APPLICANT_FIELD from '@salesforce/schema/CIBIL_Details__c.Applicant__c';
import CIBIL_DECISION_FIELD from '@salesforce/schema/CIBIL_Details__c.Cibil_Decision__c';
import CIBIL_REPORT_URI_FIELD from '@salesforce/schema/CIBIL_Details__c.CIBIL_Report_URl__c';
import CIC_NO_FIELD from '@salesforce/schema/CIBIL_Details__c.CIC_No__c';
import CRIF_SCORE_DESC_FIELD from '@salesforce/schema/CIBIL_Details__c.CRIF_Score_Desc__c';
import CURRENT_BALANCE_FIELD from '@salesforce/schema/CIBIL_Details__c.Current_Balance__c';
import ENTITY_FIELD from '@salesforce/schema/CIBIL_Details__c.Entity_Type__c';
import EQUIFAX_REPORT_URL_FIELD from '@salesforce/schema/CIBIL_Details__c.Equifax_Report_URl__c';
import HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD from '@salesforce/schema/CIBIL_Details__c.HighCredit_Or_SanctionedAmount__c';
import MONTH_OVERDUE_FIELD from '@salesforce/schema/CIBIL_Details__c.Month_Overdue__c';
import NOOFENLTSIXMON_FIELD from '@salesforce/schema/CIBIL_Details__c.NoOfEnLtSixMon__c';
import OLDEST_DATE_FIELD from '@salesforce/schema/CIBIL_Details__c.Oldest_Date__c';
import RECENT_DATE_FIELD from '@salesforce/schema/CIBIL_Details__c.Recent_Date__c';
import SCORE_FIELD from '@salesforce/schema/CIBIL_Details__c.Score__c';
import SUITFILEDORWILFULDEFAULT_FIELD from '@salesforce/schema/CIBIL_Details__c.SuitFiledOrWilfulDefault__c';
import TYPE_FIELD from '@salesforce/schema/CIBIL_Details__c.Type__c';
import WRITTENOFFAMOUNTTOTAL_FIELD from '@salesforce/schema/CIBIL_Details__c.WrittenoffAmountTotal__c';

import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Bureau_Pull_Match__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Match__c';
import Bureau_Pull_Message__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Message__c';
import isTractorLoanApplication from '@salesforce/apex/IND_RevokeController.isTractorLoanApplication';//SFTRAC-166
//CISP-2610-END
import storingCIBILDetails from '@salesforce/apex/ExternalCAMDataController.storingCIBILDetails';

export default class IND_LWC_preDisbursementCheck extends  NavigationMixin(LightningElement){
    @api dealId = '';
    @api recordId;
    remarks;
    conditionalApproval;
    conditionalApprovalPickList = [{ label: 'Yes', value: 'Yes' },{ label: 'No', value: 'No' }];
    disablesubmit = true;
    camId;
    disableView = true;
    showComponent = false;
    disableAll = true;
    isTractorApp = false;@track isPELead = false; @track showRevokeModalForTractor = false; @track revokeTypeValue ;//SFTRAC-166
    get revokeReasonVal(){
        let revokeValues = [];
        if(this.isPELead){revokeValues.push({ label: 'Pay-in and Payout changes', value: 'payandpayoutchanges' });return revokeValues;    }
        else{
        revokeValues.push({ label: 'Remove Co-Borrower/Add Co-Borrower', value: 'removecoborroweraddcoborrower' },{ label: 'Asset modifications', value: 'assetmodifications' },{ label: 'Any Loan information changes', value: 'anyloaninformationchanges' });return revokeValues;}
    }
    handleRevokeTypeChange(event){
        this.revokeTypeValue = event.target.value;}//SFTRAC-166
    connectedCallback() {
        getRelatedCam({loanAppId: this.recordId, dealId: this.dealId})
        .then(data => {
            if(data){
                console.log('data : ',data);
                this.camId = data.camObj ? data.camObj.Id : null;
                if(this.camId){
                    this.disableView = false;
                    if(data.camObj && data.camObj.CAM_conditional_approval_requirement__c && data.camObj.CAM_Conditional_approval_remarks__c){
                        this.conditionalApproval = data.camObj.CAM_conditional_approval_requirement__c
                        this.remarks = data.camObj.CAM_Conditional_approval_remarks__c;
                        this.disableAll = true
                    }
                }
                if(data.transactionHistoryList && data.transactionHistoryList.length>0 ){
                    this.showComponent = true;
                   if( data.transactionHistoryList[0].Submitted_Flag__c == true){
                        this.disableAll = true;
                        this.disablesubmit = true;
                   }
                   if( data.transactionHistoryList[0].Submitted_Flag__c == false && data.checkProfile){
                    this.disableAll = false;
                    this.disablesubmit = false;
                   }
               }
                }
                /*else if(!data.checkProfile || data.checkProfile == false){
                    this.showToastWarning(Message_CVO_User_Access);
                }*/
                else if(!data.transactionHistoryList){
                    this.showToastWarning(Message_No_Transaction_HIstory);
                }
            
        })
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
       //SFTRAC-166 
        isTractorLoanApplication({ loanApplicationId: this.recordId })
        .then(result => {
          console.log('Result', result);
          let data = JSON.parse(result);
          this.isTractorApp = data?.productType == 'Tractor' ? true : false;
          this.isPELead = (data?.profileName == 'IBL TF Payment Executive' || data?.profileName == 'IBL TF Internal Payment Executive') ? true : false;
          console.log('OUTPUT isTractorApp: ',this.isTractorApp);
          if(!this.isTractorApp){
            this.conditionalApprovalPickList.push({ label: 'N/A', value: 'N/A' });
          }
        })
        .catch(error => {
          console.error('Error:', error);
      });
    }
    renderedCallback(){
      if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @api isRevokedLoanApplication;//CISP-2735
    //CISP-2735-END
    
    showToastWarning(info) {
        const evt = new ShowToastEvent({
            title: "Warning",
            message: info,
            variant: "warning"
        });
        this.dispatchEvent(evt);
    }
    closeRevokeModal(event){this.showRevokeModalForTractor = false;}
    handleconditionalApprovalvalue(event){
       this.conditionalApproval = event.target.value;
       //CISP-2610-START
       if(this.conditionalApproval == 'No'){
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: 'The case will be revoked and moved to asset details.',//CISP-2610
                variant: 'warning',
            }),
        );
       }
    //    CISP-2610-END
       if(this.camId){
        this.disablesubmit = false;
       }
       
    }

    handleInputFieldChange(event){
       this.remarks = event.target.value;
    }
     
    viewCam(event){
        if(this.camId){
            let currentUrl = window.location.href;
            if(currentUrl && currentUrl.includes('/s/')){
                currentUrl = currentUrl.split('/s/')[0];
                window.open(currentUrl+'/apex/IBLCAMPage' + '?id=' + this.camId +'&readOnly='+true , '_blank');
            }
            else{
                window.open('/apex/IBLCAMPage' + '?id=' + this.camId +'&readOnly='+true, '_blank');
            }
        }
    }
    
    onSubmitClickEventNew(event){
        if(this.conditionalApproval == 'No' && this.isTractorApp){
            this.showRevokeModalForTractor = true
        }else{
            this.onSubmitClickEvent(event);
        }
    }

    revokeModalCall(event){
        if(this.isTractorApp){
            this.onSubmitClickEvent(event);
        }
    }
    
    async onSubmitClickEvent(event){//CISP-2610
        if(this.isTractorApp && (!this.conditionalApproval || !this.remarks)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: Please_fill_all_the_mandatory_fields,
                    variant: 'warning',
                }),
            );
            return;
        }
        if(this.conditionalApproval == 'No' && !this.remarks) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Remark field Mandatory',
                    message: Message_remark,
                    variant: 'error',
                }),
            );
        } else {
            await updateCAM({//CISP-2610
                camId: this.camId, 
                approvalRequirement: this.conditionalApproval, 
                remarks:this.remarks, 
                loanApplicationId:this.recordId,
                dealId: this.dealId
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: UpdateToastMsg,
                        variant: 'success',
                    }),
                );
                this.disablesubmit = true;
                this.disableAll = true;
            })
            .catch(error => {
                console.error('error in record creation ', error);
            });
            //CISP-2610-START
            if(this.conditionalApproval == 'No'){
                //SFTRAC-166 start
                if(this.isTractorApp && this.revokeTypeValue == ''){
                    this.showToastMessage('Info!','Please select revoke reason','info');
                    return null;
                }//SFTRAC-166
                let responseObj;
                let revokeTyepVal;
                revokeTyepVal = this.isTractorApp == true ? this.revokeTypeValue : 'General Revoke';
                let response = await loanApplicationRevoke({ loanApplicationId : this.recordId, revokeType : revokeTyepVal, newOwnerId : ''});
                    if (response) {
                        responseObj = JSON.parse(response);
                        if(revokeTyepVal == 'General Revoke'){
                        if(responseObj.clonedApplicantsId.clonedPrimaryApplicantId){
                            await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedPrimaryApplicantId);
                        }
                        if(responseObj.clonedApplicantsId.clonedSecondaryApplicantId){
                            await this.cibilReportCalloutAPI(responseObj.clonedLoanApplicationId,responseObj.clonedApplicantsId.clonedSecondaryApplicantId);
                        }
                        if(responseObj.clonedLoanApplicationId){
                            await updateClonedLoanApplicationOwner({loanApplicationId : this.recordId,clonedLoanAppId:responseObj.clonedLoanApplicationId, newOwnerId : ''});
                        }
                        }
                        const event = new ShowToastEvent({
                            title: 'Message',
                            message: 'Application Revoked Successfully',
                            variant: 'Success'
                        });
                        this.dispatchEvent(event);
                        // window.location.assign('/'+this.recordId);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordId,
                                objectApiName: 'Opportunity',
                                actionName: 'view',
                            },
                        });
                    }
            }
            //CISP-2610-END
        }
        this.showRevokeModalForTractor = false;
    }

    showToastMessage(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    //CISP-2610-START
    async cibilReportCalloutAPI(loanApplicationId,applicantId) {
        let cibilRequest = {
            applicantId: applicantId,
            loanApplicationId: loanApplicationId,
            dealId: this.dealId
        }

        await doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
            .then(res => {
                console.log('res=>', res);

                const result = JSON.parse(res);
                console.log('Bureau Pull API Response:==>', (result.Data.Application_Cibil_Details));
                console.log('Bureau Pull API Response:==>', result);

                const cibilFields = {};
                if (result.Data && result.Data.StatusCode == 200 && (result.Data.Application_Cibil_Details).length) {

                    cibilFields[AMOUNT_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Amount_Overdue;
                    cibilFields[CIBIL_DECISION_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CibilDecision;
                    cibilFields[CIC_NO_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CIC_No;
                    cibilFields[CRIF_SCORE_DESC_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CRIFScore_Desc;
                    cibilFields[CURRENT_BALANCE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Current_Balance;
                    cibilFields[ENTITY_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Entity_Type;
                    cibilFields[HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].HighCredit_Or_SanctionedAmount;
                    cibilFields[MONTH_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Month_Overdue;
                    cibilFields[NOOFENLTSIXMON_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].NoOfEnLtSixMon;
                    if(result.Data.Application_Cibil_Details[0].OldestDate){
                        cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].OldestDate));
                    }
                    if(result.Data.Application_Cibil_Details[0].RecentDate){
                        cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].RecentDate));
                    }
                    cibilFields[SCORE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Score;
                    cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
                    cibilFields[TYPE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Type;
                    cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;
                    
                    if((result.Data.Cibil_LoanAccount_Details).length){
                        if((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')){
                            let makerDate =  result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                            let makerDateConversion = makerDate.substring(0, makerDate.lastIndexOf(' '));
                            cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? makerDateConversion.split("-").reverse().join("-") : '';
                       }
                    }
                    
                    if (result.Data.Equifax_Report_URl) {
                        cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] = result.Data.Equifax_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                    }
                    if (result.Data.Cibil_Report_URl) {
                        cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] = result.Data.Cibil_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                    }

                    cibilFields[CIBIL_APPLICANT_FIELD.fieldApiName] = applicantId;
                    this.upsertRecordDetailsHandler(loanApplicationId,CIBIL_DETAILS_OBJECT.objectApiName, cibilFields);

                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                    applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                    applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                    this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                }else{
                    this.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                    applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true : false;
                    applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                    this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                    storingCIBILDetails({ loanAppId: loanApplicationId, apiResponse: JSON.stringify(result.Data), applicantId: applicantId}).then({});
                }

            }).catch(error => {
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                applicantsFields[Bureau_Pull_Match__c.fieldApiName] = false;
                applicantsFields[Bureau_Pull_Message__c.fieldApiName] = error.body.message;
                this.upsertRecordDetailsHandler(loanApplicationId,APPLICANT_OBJECT.objectApiName, applicantsFields);
                console.log('error 249 ', error);
            });
    }

    async upsertRecordDetailsHandler(loanApplicationId,objectApiName, fields) {
        console.table('fields ', fields)
        await upsertRecordDetails({ loanApplicationId:loanApplicationId, fields: JSON.stringify(fields), objectApiName: objectApiName })
        .then(obj => {
            console.log('record upsertRecordDetails successfully', JSON.stringify(fields));
        })
        .catch(error => {
            console.log('error in record upsertRecordDetails ', error);
        });
    }

    //CISP-2610-END

}