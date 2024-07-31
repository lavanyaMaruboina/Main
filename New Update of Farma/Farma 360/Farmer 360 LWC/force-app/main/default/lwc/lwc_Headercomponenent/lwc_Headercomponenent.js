import { LightningElement, track } from 'lwc';
import logoResource from '@salesforce/resourceUrl/Logo360';
import search from '@salesforce/apex/AccountSearchController.search';

export default class HeaderWithSearch extends LightningElement {
    @track logoUrl = logoResource;
    @track personAccounts;
    @track leads;
    @track error;
    @track showModal = false; // Track modal visibility

    accountColumns = [
        { label: 'Account Name', fieldName: 'Name', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },
        { label: 'Industry', fieldName: 'Industry', type: 'text' }
    ];

    leadColumns = [
        { label: 'Lead Name', fieldName: 'Name', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },
        { label: 'Company', fieldName: 'Company', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' }
    ];

    handleSearchChange(event) {
        const searchTerm = event.target.value;
        if (searchTerm.length > 2) {
            search({ searchTerm })
                .then(result => {
                    console.log("result=>",result);
                    this.personAccounts = result.personAccounts;
                    this.leads = result.leads;
                    this.error = undefined;
                    this.showModal = true; // Show the modal
                })
                .catch(error => {
                    this.error = error;
                    this.personAccounts = undefined;
                    this.leads = undefined;
                });
        } else {
            this.personAccounts = undefined;
            this.leads = undefined;
            this.showModal = false; // Hide the modal
        }
    }

    handleCloseModal() {
        this.showModal = false; // Close the modal
    }
    handleRowAction(event) {
        const row = event.detail.row;
        const rowActionName = event.detail.action.name;
        if (rowActionName === 'view') {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    objectApiName: row.sobjectType,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, '_blank');
            });
        }
    }
}