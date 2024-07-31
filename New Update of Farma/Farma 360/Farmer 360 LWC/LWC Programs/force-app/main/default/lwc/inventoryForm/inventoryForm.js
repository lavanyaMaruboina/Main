import searchAccounts from '@salesforce/apex/AccountSearchController.searchAccounts';
import searchAccountsIn from '@salesforce/apex/AccountSearchController.searchAccountsIn';
import { LightningElement, track } from 'lwc';
//import searchInventoryIn from '@salesforce/apex/AccountSearchController.searchInventoryIn';
import searchDealerInventory from '@salesforce/apex/AccountSearchController.searchDealerInventory';
import { NavigationMixin } from 'lightning/navigation';

export default class InventoryForm extends NavigationMixin(LightningElement) {
    @track error;

    @track accountData = [];
    @track inventoryData = [];
    @track isInventorySearchDisabled = false;
    @track selectedAccountName = '';
    @track selectedAccountNameIn = '';
    @track selectedAccountId = '';
    @track selectedAccountIdIn = '';
    @track selectedInventory = null;
    @track selectedInventoryAcc = null;
    @track isInventorySelected = false;
    @track isInventoryAccSelected = false;
    @track accountDataIn = false;
    @track searchWithDealerName = true; 
    @track searchWithInventoryName = false;

    @track accountData = [];

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
        //{ label: 'Active', fieldName: 'Active__c' }
    ];

    showSearch = false;

    handleAccountSearch(event) {
        const searchKey = event.target.value;
        if (searchKey) {
            searchAccounts({ searchKey })
                .then(result => {
                    this.accountData = result;
                    if (result.length > 0) {
                        this.showSearch = true;
                    } else {
                        this.showSearch = false;
                    }
                })
                .catch(error => {
                    this.accountData = [];
                    this.showSearch = false;
                    console.error('Error fetching accounts:', error);
                });
        } else {
            this.accountData = [];
            this.showSearch = false;
            this.clearOtherEvents();
        }
    }

    searchDataHandler(event) {
    }
    searchFocusHandler() {
        this.showSearch = true;
    }

    searchBlurHandler() {
        setTimeout(() => {
            this.showSearch = false; // Hide the flyout
        }, 400);
    }
    handleSearchKeyUp(event) {
        this.handleAccountSearch(event);
    }
    clearOtherEvents() {
        // Add any additional logic to clear other events if needed
    }
    

    handleAccountSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedAccount = this.accountData.find(account => account.Id === selectedId);
        this.selectedAccountName = selectedAccount.Name;
        this.selectedAccountId = selectedId;
        this.isInventorySearchDisabled = true;
        this.accountData = [];

    searchDealerInventory({ accountId: this.selectedAccountId, searchKey: '' })
            .then(result => {
                this.inventoryData = result;
                console.log('result: >>>>' + JSON.stringify(result));
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
                console.log('Inventory: '+ JSON.stringify(this.this.inventoryData))
            }) 
                .catch(error => {
                    this.inventoryData = [];
                    console.error('Error fetching contacts:', error);
                });
        } else {
            
            this.inventoryData = [];
        }
    }

    @track selectedInventoryId ='';

   handleProductSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        this.selectedInventoryId = selectedId;
        
        // Find the selected inventory from inventoryData
        this.selectedInventory = this.inventoryData.find(inventory => inventory.Id === selectedId);
        console.log('Selected Inventory:', this.selectedInventory);
        
        this.isInventorySelected = true;
    }

    goBack() {
        this.isInventorySelected = false;
    }

    @track selectedAccInventoryId ='';

    handleInventoryProductSelect(event) {
         const selectedInventoryId = event.currentTarget.dataset.id;
         this.selectedAccInventoryId = selectedInventoryId;
         
         // Find the selected inventory from inventoryData
         this.selectedInventoryAcc = this.accountDataIn.find(inventory => inventory.Id === selectedInventoryId);
         console.log('Selected Inventory:', this.selectedInventoryAcc);
         
         this.isInventoryAccSelected = true;
         this.accountDataIn =false;
     }
 
     goInventoryBack() {
         this.isInventoryAccSelected = false;
         this.accountDataInventory = true;
         this.isInventorySelected = false;
     }


    // Inventory search

    showSearchIn = false;
    accountDataIn = [];
    
    handleAccountSearchIn(event) {
        const searchKey = event.target.value;
        if (searchKey) {
            searchAccountsIn({ searchKey })
                .then(result => {
                    this.accountDataIn = result;
                    console.log('Dealer Data>>', JSON.stringify(this.accountDataIn));
                    this.showSearchIn = result.length > 0;
                })
                .catch(error => {
                    this.accountDataIn = [];
                    this.showSearchIn = false;
                    console.error('Error fetching inventories:', error);
                });
        } else {
            this.accountDataIn = [];
            this.showSearchIn = false;
            this.clearOtherEventsIn();
        }
    }
    
    searchFocusHandlerIn() {
        this.showSearchIn = true;
    }
    
    searchBlurHandlerIn() {
        setTimeout(() => {
            this.showSearchIn = false;
        }, 400);
    }
    
    clearOtherEventsIn() {
        // Add any additional logic to clear other events if needed
    }
    
    handleSearchKeyUpIn(event) {
        this.handleAccountSearchIn(event);
    }

    handleAccountSelectIn(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedAccount = this.accountDataIn.find(inventory => inventory.Id === selectedId);
        // this.selectedAccountName = selectedAccount.Name;
        this.selectedAccountIdIn = selectedId;
        console.log('selected Inventory>>', this.selectedAccountIdIn);

        this.inventoryDataIn = [];

    searchInventoryIn({ accountIdIn: this.selectedAccountIdIn})
            .then(result => {
                this.inventoryDataIn = result;
                console.log('result:Inventory data >>>>' + JSON.stringify(result));
            })
            .catch(error => {
                this.inventoryDataIn = [];
                console.error('Error fetching inventory:', error);
            });
    }

    showDealerInven(){
        this.searchWithInventoryName = true;
        this.searchWithDealerName = false;
    }
    showProductInven(){
        this.searchWithInventoryName = false;
        this.searchWithDealerName = true;
    }

}