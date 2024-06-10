import { LightningElement, track, wire } from 'lwc';
import search from '@salesforce/apex/AccountSearchController.search';
import updateContacts from '@salesforce/apex/AccountSearchController.updateContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'First Name', fieldName: 'FirstName', editable: true },
    { label: 'Last Name', fieldName: 'LastName', editable: true },
    { label: 'Email', fieldName: 'Email', type: 'email', editable: true }
];

export default class LatestUpdateContact extends LightningElement {
   @track searchKey = '';
    @track contactDetails;
    @track draftValues = [];

    columns = [
        { label: 'First Name', fieldName: 'FirstName', editable: true },
        { label: 'Last Name', fieldName: 'LastName', editable: true },
        { label: 'Email', fieldName: 'Email', type: 'email', editable: true },
        { label: 'Phone', fieldName: 'Phone', type: 'phone', editable: true }
    ];

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.fetchContacts();
    }

    fetchContacts() {
        if (this.searchKey) {
            search({ searchKey: this.searchKey })
                .then(result => {
                    this.contactDetails = result;
                })
                .catch(error => {
                    this.showToast('Error', 'Error fetching contacts', 'error');
                    console.error('Error fetching contacts:', error);
                });
        }
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        updateContacts({ contactsToUpdate: updatedFields })
            .then(() => {
                this.showToast('Success', 'Contacts updated successfully', 'success');
                this.draftValues = [];
                return this.fetchContacts();
            })
            .catch(error => {
                this.showToast('Error', 'Error updating contacts', 'error');
                console.error('Error updating contacts:', error);
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}