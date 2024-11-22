import { LightningElement,api,track, wire } from 'lwc';
import getFIRecord from '@salesforce/apex/IND_LWC_FICasePageCntrl.getFIRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TRACTOR from '@salesforce/label/c.Tractor';

export default class IND_LWC_FICasePage extends LightningElement {
    @api recordId;
    @track fiDetails;
    @track showResidenceFIComponent = false;
    @track showOfficeFIComponent = false;
    @track isTractorProduct=false;
    @track callingFromFIScreen = false;
    
    @wire(getFIRecord, {caseId: '$recordId'})
    wiredResult({data, error}){ 
        if(data){
            this.fiDetails = data;
            if(this.fiDetails.Case__r.Product_Type__c != null && this.fiDetails.Case__r.Product_Type__c == TRACTOR){
                this.isTractorProduct = true;
                this.callingFromFIScreen = true;
            }
           else{ 
            if(this.fiDetails.RecordType.Name === 'Office'){
                this.showOfficeFIComponent = true;
            }else{
                this.showResidenceFIComponent = true;
            }
            }
            
        }else if(error){
            console.log('Error::',error);
            if(error.body.message) {
                this.showToast('Error!',error.body.message,'error','sticky');
            } else {
                this.showToast('Error!','Something went wrong, Please contact System Administrator','error','sticky');
            }
        }
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }


}