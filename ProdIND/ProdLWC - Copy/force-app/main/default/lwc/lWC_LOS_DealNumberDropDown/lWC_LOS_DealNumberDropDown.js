import { LightningElement, api, track } from 'lwc';
import getDealNumbers from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getDealNumbers';
import FORM_FACTOR from "@salesforce/client/formFactor";

export default class LWC_LOS_DealNumberDropDown extends LightningElement {
    @track isDesktop;
    get options() {
        return this.dealNumberOptions !== undefined && this.dealNumberOptions !== null ? this.dealNumberOptions : [];
    }
    @api recordId;
    @api screenName;
    @track dealNumberOptions =[];
    @track selectedDealNumber = '';
    @track showDealNumberDropDown = false;
    async handleDealNumberChange(event) {
        this.selectedDealNumber = event.target.value;
        const evnt = new CustomEvent('selectdealnumber', { detail: this.selectedDealNumber}); 
        this.dispatchEvent(evnt);
        await this.init(false);
    }

    async connectedCallback(){
        console.log('dealNumber ConnectedCallBack');
        await this.init(true);
        this.isDesktop = FORM_FACTOR === "Large" ? true:false;
    }

    get layoutSize(){
        return this.isDesktop == true?"4":"12";
    }

    async init(reRenderParentCmp){
        await getDealNumbers({ loanApplicationId: this.recordId }).then(result => {
            if(result && result.productType == 'Tractor'){
                this.dealNumberOptions = result?.dealNumberWrapperList.map(deal => ({
                    label: deal.dealNumber,
                    value: deal.dealId,
                    isAllPostScreensSubmitted : deal.isAllPostScreensSubmitted,
                    isAllPreScreensSubmitted : deal.isAllPreScreensSubmitted,
                    isPayamentRequestCompleted : deal.isPayamentRequestCompleted,
                    isTickMark : this.screenName == 'Post Sanction Checks and Documentation' ? deal.isAllPostScreensSubmitted : this.screenName == 'Pre Disbursement Check' ? deal.isAllPreScreensSubmitted : this.screenName == 'Disbursement Request Preparation' ? deal.isPayamentRequestCompleted : false,
                }));
                if(this.dealNumberOptions.length > 0 && reRenderParentCmp == true){
                    this.selectedDealNumber = this.dealNumberOptions[0].value;
                    const evnt = new CustomEvent('selectdealnumber', { detail: this.selectedDealNumber}); 
                    this.dispatchEvent(evnt);
                }
                this.showDealNumberDropDown = true;
            }
        }).catch(error=>{
            console.log('Error dealNumber '+JSON.stringify(error))
        })
    }
}