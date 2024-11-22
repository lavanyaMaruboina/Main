import { LightningElement, api } from 'lwc';

export default class Ind_lwc_modal extends LightningElement {

    @api header;
    @api message;

    connectedCallback(){
       // document.body.setAttribute("style", "overflow:hidden !important;");
    }

    closemodal() {
        this.dispatchEvent(new CustomEvent("hide"));
      }
    
      confirm() {
        this.dispatchEvent(new CustomEvent("ok"));
      }
}