import { LightningElement, track } from 'lwc';
import search from '@salesforce/apex/AccountSearchController.searchinventory';
import searchAccounts from '@salesforce/apex/AccountSearchController.searchAccounts';
import searchDealerInventory from '@salesforce/apex/AccountSearchController.searchDealerInventory';
import { NavigationMixin } from 'lightning/navigation';

export default class InventoryForm extends NavigationMixin(LightningElement) {
    @track error;

    @track accountData = [];
    @track inventoryData = [];
    @track isInventorySearchDisabled = false;
    @track selectedAccountName = '';
    @track selectedAccountId = '';
    @track selectedInventory = null;
    @track isInventorySelected = false;

    accountColumns = [
        { fieldName: 'Name', type: 'button', typeAttributes: { label: { fieldName: 'Name' }, name: 'select_account', variant: 'base' } }
    ];

    inventoryColumns = [
        {
            label: 'Inventory Name', 
            fieldName: 'Name', 
            type: 'button', 
            typeAttributes: { 
                label: { fieldName: 'Name' }, 
                name: 'navigate_to_inventory', 
                variant: 'base'
            }
        },
        { label: 'Quantity', fieldName: 'Quntity__c' },
        { label: 'Active', fieldName: 'Active__c' }
    ];

    handleAccountSearch(event) {
        const searchKey = event.target.value;
        if (searchKey) {
            searchAccounts({ searchKey })
                .then(result => {
                    this.accountData = result;
                })
                .catch(error => {
                    this.accountData = [];
                    console.error('Error fetching accounts:', error);
                });
        } else {
            this.accountData = [];
            this.clearOtherEvents();
        }
    }
    
    clearOtherEvents() {
        console.log('Clearing other events or refreshing data.');
        this.fetchDefaultData();
    }

    handleAccountSelect(event) {
        const accountName = event.detail.row.Name;
        const accountId = event.detail.row.Id;
        this.selectedAccountName = accountName;
        this.selectedAccountId = accountId;
        this.isInventorySearchDisabled = true;
        this.accountData = []; 
        
        searchDealerInventory({ accountId: this.selectedAccountId, searchKey: '' })
        .then(result => {
            this.inventoryData = result;
            console.log('result: '+ result)
        })
        .catch(error => {
            this.inventoryData = [];
            console.error('Error fetching inventory:', error);
        });
    }

    handleInventorySearch(event) {
        const searchKey = event.target.value;
        if (searchKey && this.selectedAccountId) {
            searchDealerInventory({ accountId: this.selectedAccountId, searchKey })
            .then(result => {
                this.inventoryData = result;
                console.log('Inventory: '+ result)
            }) 
                .catch(error => {
                    this.inventoryData = [];
                    console.error('Error fetching contacts:', error);
                });
        } else {
            this.inventoryData = [];
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        switch (actionName) {
            case 'navigate_to_inventory':
                this.selectedInventory = event.detail.row;
                console.log('event: '+ event.detail.row )
                this.isInventorySelected = true;
                break;
        }
    }

    goBack() {
        this.isInventorySelected = false;
    }

}