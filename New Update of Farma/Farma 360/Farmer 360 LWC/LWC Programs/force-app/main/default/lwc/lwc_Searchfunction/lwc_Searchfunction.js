import { LightningElement, wire } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountController.searchAccounts';

export default class SearchAccount extends LightningElement {
    searchTerm = '';
    
    @wire(searchAccounts, { searchTerm: '$searchTerm' })
    accounts;

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }
}