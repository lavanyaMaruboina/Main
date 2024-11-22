import { LightningElement,api, track } from 'lwc';
import loadVehicleDetailsDataForTractor from '@salesforce/apex/IND_ValuationIDVCntrl.loadVehicleDetailsDataForTractor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ValuationIDV from '@salesforce/label/c.Valuation_IDV';

export default class IND_LWC_ValuationIDVTractorParent extends LightningElement {
    @api recordId;
    @track vehicleDetailList =[];
    @track tryCatchError ='';
    @api isRevokedLoanApplication
    @api checkleadaccess;
    @api isTractor;
    @api subStage;
    @track vehiclePresent = false;

    label={
        ValuationIDV
    };
    connectedCallback(){
        this.init();
    }


    async init(){
        await loadVehicleDetailsDataForTractor({ loanApplicationId: this.recordId })
            .then(response => {
                let result = JSON.parse(response);
                this.vehicleDetailList = result.filter(ele => ele.vehicleSubType != 'Implement');
                if(this.vehicleDetailList.length == 0){
                    this.subStage = true;
                    this.vehiclePresent = false;
                }else{
                    this.vehiclePresent = true;
                }
            })
            .catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
    }

    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body.message,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }

    handleSubmit(){
        // if all check eligiblity buttons are disabled.

        let allChilds = this.template.querySelectorAll('c-i-n-d-_-l-w-c-_-valuation-i-d-v');

        console.log('All childs length'+allChilds.length);
        let countSavedRecords =0;
        allChilds.forEach(each =>{
            if(each.recordSaved == true){
                countSavedRecords++;
            }
        })

        if(countSavedRecords == allChilds.length ){
            console.log('Able to change the stage :'+countSavedRecords);
            this.dispatchEvent(new CustomEvent('valuationidvevent', { detail: this.label.ValuationIDV }));
        }
        else{
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Please Save all Valuation details first',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
    }
}