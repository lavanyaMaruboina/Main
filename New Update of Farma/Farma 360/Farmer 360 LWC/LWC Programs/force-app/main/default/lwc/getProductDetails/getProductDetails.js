import collectproductsData from '@salesforce/apex/AddProductsComponent.collectproductsData';
import getOpportunityLineItems from '@salesforce/apex/AddProductsComponent.getOpportunityLineItems';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';

export default class GetProductDetails extends LightningElement {
    @api orderId;
    @api createId;
    @track showProductData = true;
    @track showEditView = false;
    @track showOpportunityLineItems = false;
    @track showSavedItems = false;
    @track showOrderDataTable =false;
    @track columns = [
        { label: 'Product Name', fieldName: 'Name' },
        { label: 'Product Code', fieldName: 'ProductCode' },
        { label: 'Product Family', fieldName: 'Family' },
        { label: 'List Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Product Description', fieldName: 'Description' }
    ];
    @track editColumns = [
        { label: 'Product', fieldName: 'Name' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number', editable: true },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'List Price', fieldName: 'ListPrice', type: 'currency' },
        { label: 'Line Description', fieldName: 'LineDescription', type: 'text', editable: true }
    ];
    @track opportunityLineItemColumns = [
        { label: 'Product Name', fieldName: 'ProductName' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Description', fieldName: 'Description' }
    ];
    @track savedColumns = [
        { label: 'Product', fieldName: 'Name' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'List Price', fieldName: 'ListPrice', type: 'currency' },
        { label: 'Line Description', fieldName: 'LineDescription' }
    ];
    @track selectedRows = [];
    @track selectedEditRows = [];
    @track dataTableColumns = [];
    @track productLineItems = [];
    @track draftValues = [];
    @track opportunityLineItems = [];
    @track savedLineItems = [];
    @track error;
    @api recordId;
    searchInput = '';

    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getOpportunityLineItems, { opportunityId: '$recordId' })
    wiredOpportunityLineItems({ error, data }) {
        if (data) {
            this.opportunityLineItems = data.map(item => ({
                Id: item.Id,
                ProductName: item.ProductName,
                Quantity: item.Quantity,
                UnitPrice: item.UnitPrice,
                Description: item.Description
            }));
            this.showOpportunityLineItems = true;
        } else if (error) {
            console.error('Error retrieving opportunity line items:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error retrieving opportunity line items',
                    variant: 'error'
                })
            );
        }
    }

    connectedCallback() {
        const invokeMethod = this.currentPageReference && this.currentPageReference.state.c__invokeMethod;
        if (invokeMethod) {
            this.addProductsModal();
        }
    }

    @api
    addProductsModal() {
        this.showProductData = true;
    }

    getSearchdata(event) {
        this.searchInput = event.target.value;
    }

    @wire(collectproductsData, { searchkey: '$searchInput' })
    wiredProducts({ error, data }) {
        if (data) {
            this.dataTableColumns = data.map(item => ({
                Id: item.Id,
                Name: item.Name,
                ProductCode: item.ProductCode,
                Family: item.Family,
                Description: item.Description,
                UnitPrice: item.UnitPrice
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dataTableColumns = [];
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        console.log('Selected Rows:', this.selectedRows);
    }

    ShowSelectedLineItems() {
        if (this.selectedRows.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select at least one product.',
                    variant: 'error'
                })
            );
            return;
        }

        this.productLineItems = this.selectedRows.map(item => ({
            ...item,
            Quantity: '',
            LineDescription: '',
            ListPrice: item.UnitPrice
        }));
        console.log('Product Line Items:', this.productLineItems);

        this.showProductData = false;
        this.showEditView = true;
        this.showOrderDataTable = false;
    }

    handleCellChange(event) {
        const updatedDraftValues = event.detail.draftValues;
        updatedDraftValues.forEach(updatedItem => {
            const index = this.productLineItems.findIndex(item => item.Id === updatedItem.Id);
            if (index !== -1) {
                this.productLineItems[index] = { ...this.productLineItems[index], ...updatedItem };
            }
        });
        console.log('Updated Product Line Items:', this.productLineItems);
    }

  saveLineItems() {
    console.log('orderId=> ', this.orderId);
      const pricebookEntryId = '<YOUR_PRICEBOOKENTRY_ID>';

    const orderItems = this.productLineItems.map(item => ({
        OrderId: this.createId !== null && this.createId !== undefined ? this.createId : (this.orderId !== null && this.orderId !== undefined ? this.orderId : null),
        Product2Id: item.Id,
        Quantity: item.Quantity,
        UnitPrice: item.UnitPrice,
        Description: item.LineDescription,
        
        PricebookEntryId: pricebookEntryId
    }));

    console.log('Order Items to save:', JSON.stringify(orderItems));

    saveOrderLineItems({ orderItems: orderItems })
        .then(() => {
           
            this.showEditView = false;
            this.showProductData = false;
            this.showOrderDataTable = true;
        })
        .catch(error => {
        
            console.error('Error saving order items:', error);
        });
}


    cancelEdit() {
        this.showEditView = false;
        this.showProductData = true;
        this.showOrderDataTable =false;
    }
}