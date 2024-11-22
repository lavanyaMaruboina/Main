import { LightningElement, api } from 'lwc';

export default class IND_LWC_TVRNomineeAndReference extends LightningElement {
    @api eachApplicant;
    @api borrowerAvailable;
    @api showCoborrowerNominee;
    connectedCallback(){
       console.log(this.borrowerAvailable, this.showCoborrowerNominee); 
    }
}