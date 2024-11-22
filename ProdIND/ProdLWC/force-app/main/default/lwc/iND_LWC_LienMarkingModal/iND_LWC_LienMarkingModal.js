import { LightningElement, api, wire } from 'lwc';
import getExposures from '@salesforce/apex/IND_LWC_LienMarkingModalController.getExposures';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; 
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import Lien_Marking_Email from '@salesforce/label/c.Lien_Marking_Email';
import Lien_Marking_Success_Message from '@salesforce/label/c.Lien_Marking_Success_Message';
import Lien_Marking_Error_Messge from '@salesforce/label/c.Lien_Marking_Error_Messge';
import Lien_Marking_Email_Subject from '@salesforce/label/c.Lien_Marking_Email_Subject';
import Lien_Marking_Email_Body from '@salesforce/label/c.Lien_Marking_Email_Body';
import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';
import LightningAlert from 'lightning/alert';


export default class IND_LWC_LienMarkingModal extends LightningElement {
    @api recordId;
    lienMarkingRequestedByVal;
    lienMarkingFromDateVal;
    lienMarkingToDateVal;
    lienMarkingReasonRemarksVal;
    loggedInUserEmail;
    error;
    name;
    showModal = true;
    selectedDealNos = [];
    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, EMAIL_FIELD] }) 
    wireuser({ error, data }) {
        if (error) {
            this.error = error ; 
        } else if (data) {
            this.lienMarkingRequestedByVal = data.fields.Name.value;
            this.loggedInUserEmail = data.fields.Email.value;
        }
     }
    existingLoanDetails = [];
    columns = [
        { label: 'Deal No', fieldName: 'Deal_No__c', type : 'text' },
        { label: 'Deal Date', fieldName: 'Deal_Date__c', type: 'date' },
        { label: 'Product Variant Name', fieldName: 'Product_Variant_Name__c', type: 'text' },
        { label: 'Finance Amount', fieldName: 'Finance_Amt__c', type: 'currency' }
    ];

    handleCancel() {
        this.showModal = false;
    }
    connectedCallback() {
        console.log('lien Marking ----');
        getExposures({ loanApplicationId: this.recordId })
            .then(response => {
                if (response) {
                    this.existingLoanDetails = response;
                }
            }).catch(error => {
                console.error(error);
            });
    }

    handleInputFieldChange(event) {
        let name = event.target.name;
        switch (name) {
            case 'lienMarkingFromDate':
                this.lienMarkingFromDateVal = event.detail.value;
                break;
            case 'lienMarkingToDate':
                this.lienMarkingToDateVal = event.detail.value;
                break;    
            case 'lienMarkingReasonRemarks':
                this.lienMarkingReasonRemarksVal = event.detail.value;
                break; 
            default:
                break;
        }
    }

    handleSend() {
        let body = Lien_Marking_Email_Body.replace('{!selectedLoanDetails}', this.selectedDealNos.join(',')).replace('{!usedName}', this.lienMarkingRequestedByVal).replace('{!fromDate}', this.lienMarkingFromDateVal).replace('{!toDate}', this.lienMarkingToDateVal).replace('{!remarks}', this.lienMarkingReasonRemarksVal).replace('undefined', '');
        
        let emailRequestWrapper={
            'leadId': this.recordId,
            'emailTo': Lien_Marking_Email,
            'emailCC': this.loggedInUserEmail,
            'emailSubject': Lien_Marking_Email_Subject,
            'emailBody' : body,
            'loanApplicationId': this.recordId
        };
        doEmailServiceCallout({emailService : JSON.stringify(emailRequestWrapper)}).then(result=>{
            if (result.includes('SUCCESS')) {
                LightningAlert.open({
                    message: Lien_Marking_Success_Message,
                    theme: 'success', // a red theme intended for error states
                    label: 'Success!', // this is the header text
                });
            } else{
                LightningAlert.open({
                    message: Lien_Marking_Error_Messge,
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            }
            this.handleCancel();
        }).catch(error=>{});
    }

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        let selectedDeals = [];
        selectedRows.forEach(element => {
            selectedDeals.push(element.Deal_No__c);
        });
        this.selectedDealNos = selectedDeals;
    }
}