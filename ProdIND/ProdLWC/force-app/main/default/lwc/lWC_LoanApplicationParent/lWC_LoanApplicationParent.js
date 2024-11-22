import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import OPPORTUNITY_LEAD_SOURCE from '@salesforce/schema/Opportunity.LeadSource';
import OPPORTUNITY_STAGE from '@salesforce/schema/Opportunity.StageName';

export default class LWC_LoanApplicationParent extends LightningElement {
    @api recordId;
    @track isLoading = false;
    isVlosPage = false;
    isD2CPage = false;
    postFinalOfferStages = ['Credit Processing', 'Disbursement Request Preparation', 'CAM and Approval', 'Post Sanction Checks and Documentation', 'Pre Disbursement Check', 'Revoke'];
    //OLA-255 - START
    constructor()
    {
        super();
        window.addEventListener("contextmenu", e => e.preventDefault());
        function ctrlShiftKey(e, keyCode) {
            return e.ctrlKey && e.shiftKey && e.keyCode == keyCode.charCodeAt(0);
          }
        window.onkeydown = (e) => {
            // Disable F12, Ctrl + Shift + I, Ctrl + Shift + J, Ctrl + U
            if (
              e.keyCode == 123 ||
              ctrlShiftKey(e, 'I') ||
              ctrlShiftKey(e, 'J') ||
              ctrlShiftKey(e, 'C') ||
              (e.ctrlKey && e.keyCode == 'U'.charCodeAt(0))
            )
              e.preventDefault();
          };
    }
    //OLA-255 - END

    @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_LEAD_SOURCE, OPPORTUNITY_STAGE] })
    wiredOpportunity({ error, data }) {
        if (data) {
            if(data.fields.LeadSource.value=='D2C' && !this.postFinalOfferStages.includes(data.fields.StageName.value)){
                this.isD2CPage = true;
                this.isVlosPage = false;
            }else{
                this.isD2CPage = false;
                this.isVlosPage = true;
            }
        } else if (error) {
            this.error = error;
        }
    }

    handleCreditProcessingStageChanged(){
        this.isD2CPage = false;
        this.isVlosPage = true;
        location.reload()

    }

}