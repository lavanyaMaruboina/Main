// headerWithSearch.js
import { LightningElement, track } from 'lwc';
import logoResource from '@salesforce/resourceUrl/Logo360';

export default class Pharma360Header extends LightningElement {
    @track logoUrl = logoResource;

    handleSearch(event) {
        const searchKey = event.target.value;
        console.log('Search Key:', searchKey);
    }

}