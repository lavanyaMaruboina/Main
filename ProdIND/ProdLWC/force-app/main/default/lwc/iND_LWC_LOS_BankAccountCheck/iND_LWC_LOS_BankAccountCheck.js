import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IND_LWC_LOS_BankAccountCheck extends LightningElement {
    isBankAccountSelected =false;
    isBankOpenSelected =false;

    selectDeselectBankAccount(event){
        if (event.target.checked){
            this.isBankAccountSelected =true;
        }
        else{
            this.isBankAccountSelected =false; 
        } 
    }
    selectDeselectOpenAccount(event){
        if (event.target.checked){
            this.isBankOpenSelected =true;
        }else{
            this.isBankOpenSelected =false;
        }
    }
    handleClick(event) {
        /*if(this.isBankOpenSelected===false){
            this.showToast();
        }else{
            this.showToast1();
        }*/
    }
    showToast() {
        const event = new ShowToastEvent({
            title: 'Warning!',
            message: 'Journey cannot proceed without bank account',
            mode : 'sticky',
            variant : 'error'
        });
        this.dispatchEvent(event);
    }
    showToast1() {
        const event = new ShowToastEvent({
            title: 'success!',
            message: 'success',
            mode : 'sticky',
            variant : 'success'
        });
        this.dispatchEvent(event);
    }
}