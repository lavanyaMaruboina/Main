// Author: Haarika Chodisetti
// Company: Salesforce
// Description: Parent component for ConVox CTI functionality
import { LightningElement,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class CtiApplicantView extends LightningElement {
    applicantId;
    //Haarika - 08-08-22 - To get the applicant Id from the url
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
        const urlValue = currentPageReference.state.c__applicantId;
        if (urlValue) {
            this.applicantId = urlValue;
        } 
       }
    }
}