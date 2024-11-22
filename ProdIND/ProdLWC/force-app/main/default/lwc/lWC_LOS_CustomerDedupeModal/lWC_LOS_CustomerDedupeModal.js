import { LightningElement, api} from 'lwc';

export default class LWC_LOS_CustomerDedupeModal extends LightningElement {
    @api msg;
    @api showcancelbtn;
    @api modalspinner;

    handleModalOkAction() {
         this.dispatchEvent(new CustomEvent('modalok'));
    }

    handleModalCloseAction() {
        this.dispatchEvent(new CustomEvent('modalcancel'));
    }
}