import { LightningElement,api,track } from 'lwc';
import getAllRCUDocs from '@salesforce/apex/RCUSummaryReportController.getAllRCUDocs';

export default class IND_LWC_TractorRCUDocuments extends LightningElement {
    @api recordId;
    @track documents = [];
    connectedCallback(){
        getAllRCUDocs({'loanApplicationId' : this.recordId}).then(result=>{
            if(result && result.length > 0){
                this.documents = result;
            }
        }).catch(error=>{
            console.log(error);
        });
    }
}