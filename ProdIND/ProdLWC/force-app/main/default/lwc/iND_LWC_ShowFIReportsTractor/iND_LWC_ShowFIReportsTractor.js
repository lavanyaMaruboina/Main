import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
export default class IND_LWC_ShowFIReportsTractor extends LightningElement {
    @api callingFromFIScreen;
    @api currentCaseId;
    @track errorMsg;
    isPreview = false;
    @wire(CurrentPageReference)
    currentPageReference;
    connectedCallback() {
        if(this.currentPageReference?.state){
            this.currentCaseId = this.currentPageReference.state.currentCaseId;
            this.callingFromFIScreen = this.currentPageReference.state.callingFromFIScreen;
        }
        if (!this.currentCaseId || this.currentCaseId == 'null') {
            this.errorMsg = 'No FI Report Found!.';
        }
        else {
            this.isPreview = true;
        }
    }
    handleCloseButton() {
        this.isPreview = false;
    }
}