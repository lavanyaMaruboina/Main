import { LightningElement, api, track} from 'lwc';

export default class ViewRiskBand extends LightningElement {
    @track isModalOpen = false;
    @api applicantType;
    @api riskBand;
    @api openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
}