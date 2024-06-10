import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import collectproductsData from '@salesforce/apex/AddProductsComponent.collectproductsData';
import createOrder from '@salesforce/apex/AddProductsComponent.createOrder';
import getOpportunityLineItems from '@salesforce/apex/AddProductsComponent.getOpportunityLineItems';
import getOrderList from '@salesforce/apex/AddProductsComponent.getOrderDetailsByContactId';
import getStatusPicklistValues from '@salesforce/apex/AddProductsComponent.getStatusPicklistValues';
import orderLineItems from '@salesforce/apex/AddProductsComponent.orderLineItems';
import pPbIds from '@salesforce/apex/AddProductsComponent.pPbIds';
import saveOrderLineDetails from '@salesforce/apex/AddProductsComponent.saveOrderLineDetails';
import searchAccounts from '@salesforce/apex/AddProductsComponent.searchAccounts';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GetContactOrderDetails extends NavigationMixin(LightningElement) {

    orderObj = {
        id : '',
        OrderNumber: '',
        statusField: '',
        startDateField: '',
        endDateField: ''
    };

    @track data;
    @track contactName = '';
    @api contactId;
    @track orderDetails;
    @track orderForm = false;
    //@track orderDetailsVisible = true;
    @track accounts = [];
    @track accountName = '';
    @track accountId = '';
    @track statusOptions = [
        { label: 'Draft', value: 'Draft' },
        { label: 'New', value: 'New' },
        { label: 'Accepted', value: 'Accepted' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'On Hold', value: 'On Hold' },
        { label: 'Shipped', value: 'Shipped' },
        { label: 'Cancel', value: 'Cancel' }
    ];
  //  @track statusOptions = []; 
    @track contactName = '';
    @track draftValues = [];
    @track isorderObj = false;
    @track selectedRows = [];
    @track OrderDetailsForm = false;
    @track OrderDatatable = true;
    @track selectedStatus = 'New';
    defaultStatusSet = false;
    @track addProductsDetails = false;
    @track showProductsDetails = false;
    @track productLineItems = [];
    @track showEditView = false;
    wiredOrderLineData;
    @track showAddProductsDetails = false;
    @track createId='';

    selectedOption='';
  //  selectedStatus = 'New';
    orderStart = '';
    endDate = '';
    billingStreet = '';
    billingCity = '';
    billingState = '';
    billingCountry = '';
    billingPostalCode = '';
    OrderNumber= '';
    statusField= '';
    EffectiveDate= '';
    EndDate= '';
    orderAmount ='';
    @track pricebookId;
   // @track OrderDatatable=false;
   backupResponseFromWire;

   


    columns = [
        { label: 'Order Number', fieldName: 'OrderNumber' , type:'text'},
        { label: 'Status', fieldName: 'Status' },
        { label: 'Order Start Date', fieldName: 'EffectiveDate', type: 'date' },
        { label: 'End Date', fieldName: 'EndDate', type: 'date' },
    ];

    editColumns = [
        { label: 'Product', fieldName: 'Name' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number', editable: true, required: true},
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'List Price', fieldName: 'ListPrice', type: 'currency' },
        { label: 'Line Description', fieldName: 'LineDescription', type: 'text', editable: true }
    ];

    @wire(pPbIds)
    wiredPricebookIds({ error, data }) {
        if (data) {
            this.pricebookId = data;
            console.log('pPbIds', this.pricebookId);
        } else if (error) {
            console.error('Error retrieving pricebook ids', error);
        }
    }

    @wire(getOrderList, { contactId: '$contactId' })
    getOrderListDetail(result) { 
        this.backupResponseFromWire = result;
        if (result.data) {
            this.orderDetails = result.data;
            console.log('Order Details >>>>', JSON.stringify(this.orderDetails));
        } else if (result.error) {
            this.orderDetails = undefined;
        }
    }

    @wire(getStatusPicklistValues)
    wiredStatusPicklistValues({ error, data }) {
        if (data) {
            this.statusOptions = Object.keys(data).map(key => ({ label: data[key], value: key }));
            console.log('statusOptions : ', this.statusOptions);
            console.log('selectedStatus :'+ this.selectedStatus);
           
             

        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error fetching picklist values',
                    message: 'erro message',
                    variant: 'error',
                }),
            );
        }
    }
   
    
    // fetchPricebookId(productName) {
    //     getPricebookId({ productName: '$productName' })
    //         .then(result => {
    //             // Use the fetched Price Book ID
    //             this.pricebookId = result;
    //         })
    //         .catch(error => {
    //             // Handle any errors
    //             console.error('Error fetching Price Book ID: ', error);
    //         });
    // }

    

    handleCreateOrder() {
        this.orderForm = true;
       
        console.log('data : '+ this.orderDetails);
        if (this.orderDetails && this.orderDetails.length > 0) {
            this.contactName = this.orderDetails[0].Contact__r.Name;
        }
        // this.orderDetailsVisible = false;
        this.OrderDatatable = false;
        this.OrderDetailsForm =false;
        this.addProductsDetails =false;
        this.showEditView=false;
        
    
    }

    handleAccountSearch(event) {
        this.accountName = event.target.value;
        if (this.accountName.length > 2) {
            searchAccounts({ searchTerm: this.accountName })
                .then(result => {
                    this.accounts = result;
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error searching accounts',
                            message: 'erro message',
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.accounts = []; // Clear the accounts list if search term length is less than 3
        }
    }

    selectAccount(event) {
        this.accountId = event.target.dataset.id;
        this.accountName = event.target.label;
        this.accounts = [];
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
         this.selectedOption = this.statusOptions.find(option => option.value === this.selectedStatus);
        if (this.selectedOption) {
            console.log('In handle status change: ' + this.selectedOption.label);
        }

    }

     handleFieldChange(event) {
        const field = event.target.dataset.field;
        if (field === 'Start Date') {
            this.EffectiveDate = event.target.value;
        } else if (field === 'End Date') {
            this.EndDate = event.target.value;
        }
        else if (field === 'Order Amount') {
            this.TotalAmount = event.target.value;
        }
    }

    handleOrderStartChange(event) {
        this.orderStart = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    handleContactChange(event) {
        this.contactName = event.target.value;
        console.log('contactName :'+ event.target.value )
    }

    handleBack(event) {
        this.orderForm = false;
        this.OrderDatatable = true;
        this.OrderDetailsForm = false;
        this.addProductsDetails = false;
        this.showProductsDetails = false;
        this.showEditView = false;
    }

    addressChange(event) {
        this.billingStreet = event.target.street;
        this.billingCity = event.target.city;
        this.billingState = event.target.province;
        this.billingCountry = event.target.country;
        this.billingPostalCode = event.target.postalCode;
    }

    handleSave() {
        console.log('accountId : '+ this.accountId)
        if (!this.accountId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Account Name is required',
                    variant: 'error',
                }),
            );
            return;
        }
      //  ======== Validation for Start Date and end date ===========
         if (this.endDate && this.orderStart) {
            const endDate = new Date(this.endDate);
            const startDate = new Date(this.orderStart);
            if (endDate < startDate) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Order End Date cannot be earlier than Order Start Date',
                        variant: 'error'
                    })
                );
                return;
            }
        }
        //  ======== Validation for Start Date and end date ===========

        const fields = {
            AccountId: this.accountId,
            Status: this.selectedOption.label,
            EffectiveDate: this.orderStart,
            EndDate: this.endDate,
            //orderAmount: this.orderAmount,
            Contact__c: this.contactId,
            BillingStreet: this.billingStreet,
            BillingCity: this.billingCity,
            BillingState: this.billingState,
            BillingCountry: this.billingCountry,
            BillingPostalCode: this.billingPostalCode
        };

        console.log('fields :'+ fields)
        for (const [label, value] of Object.entries(fields)) {
            console.log(`${label}: ${value}`);
        }
        console.log('fields in String:', JSON.stringify(fields, null, 2));
        
       createOrder({ order: fields })
            .then(result => {
                this.orderDetails = [...this.orderDetails, result];
                this.createId = result.Id; 
                console.log('Create Order Id : ', this.createId);
                console.log('Order Fields result : ', result);
                console.log('Order Fields : ', this.orderDetails);
                //            this[NavigationMixin.Navigate]({
                //           "type": "standard__webPage",
                //           "attributes": {
                //           "url": "/orderdetails"
                //     }
                // });
                this.orderForm = false;
                this.showProductData = true;  
                this.orderForm =false;
                this.OrderDatatable = false;
                this.OrderDetailsForm = false;
                this.showEditView = false;
                this.showOpportunityLineItems =false;
                this.showSavedItems =false;

                console.log('refrereshing apex1');
                //this.clearNewOrderData();
                this.refreshNewData();
                
                
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating order',
                        message: 'Unknown error',
                        variant: 'error',
                    }),
                );
            });
    }


    refreshNewData(){
        console.log('refrereshing apex2');
        return refreshApex(this.backupResponseFromWire);
    }

    clearNewOrderData(){
         this.accountId = '';
            this.selectedOption = '';
            this.orderStart = '';
          this.endDate = '';
            this.billingStreet = '';
             this.billingCity = '';
      this.billingState = '';
          this.billingCountry = '';
            this.billingPostalCode = '';
    }

        handleCellChange(event) {
            const updatedFields = event.detail.draftValues;
            this.draftValues = [...updatedFields];
        }

        @api orderDetails;

        handleCardClick(event) {
             this.orderId = event.currentTarget.dataset.id;
            console.log('Record ID>>>>>> Card Click:', this.orderId);
        }

    handleOrderRowSelection(event) {
        this.OrderDetailsForm = true;
        this.selectedRows = event.detail.selectedRows[0];
        console.log('selectedRows :' + this.selectedRows);
        this.selectedOrderDetails = this.selectedRows.Id;
        console.log('Selected Order Id: ' + this.selectedOrderDetails);
        
        this.OrderNumber = this.selectedRows.OrderNumber;
        console.log('OrderNumber: ' + this.selectedRows.OrderNumber);
        console.log('OrderNumber: ' + this.OrderNumber);

        this.statusField = this.selectedRows.Status;
        console.log('statusField: ' + this.selectedRows.Status);
        console.log('statusField: ' + this.statusField);

        this.EffectiveDate = this.selectedRows.EffectiveDate ? new Date(this.selectedRows.EffectiveDate).toLocaleDateString('en-GB') : null;

        console.log('EffectiveDate: ' + this.selectedRows.EffectiveDate);
        console.log('EffectiveDate: ' + this.EffectiveDate);

        this.EndDate = this.selectedRows.EndDate ? new Date(this.selectedRows.EndDate).toLocaleDateString('en-GB') : null;
        console.log('EndDate: ' + this.selectedRows.EndDate);
        console.log('EndDate: ' + this.EndDate);

        // Close the order table and open the detail order page
        //this.orderDetailsVisible = false;
        this.isorderObj = true;
        this.OrderDatatable = false;
        
    }





        handleShowProducts() {
        this.showEditView = true;
        this.addProductsDetails = false;
        this.showProductsDetails = true;
        this.getProductLineItems(this.selectedRows.Id);
    }

     //================== Edit functionality in Harvest Datatable ========================================
      @wire(orderLineItems, { orderId: '$selectedOrderDetails' })
    wiredOrderLineDetails(result) {
        this.wiredOrderLineData = result;
        if (result.data) {
            this.productLineItems = result.data;
            console.log('productLineItems====>425', this.productLineItems);
           
        } else if (result.error) {
            this.productLineItems = result.error;
            
        }
    }



    // handleHarvestCellChange(event) {
    //     const { draftValues } = event.detail;
    //     this.harvestDraftValues = draftValues;
    // }

      handleCellOrdelineChange(event) {
        const updatedDraftValues = event.detail.draftValues;
        updatedDraftValues.forEach(updatedItem => {
            const index = this.productLineItems.findIndex(item => item.Id === updatedItem.Id);
            if (index !== -1) {
                this.productLineItems[index] = { ...this.productLineItems[index], ...updatedItem };
            }
        });
        console.log('Updated Product Line Items:', this.productLineItems);
    }
    

     saveEditOrderLineDetails(event) {
        const updatedFields = event.detail.draftValues;
        saveOrderLineDetails({ data: updatedFields })
            .then(() => {
                this.harvestDraftValues = [];
                return refreshApex(this.wiredHarvestDetailsResult);
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleBackHarvest(event){
        
        this.LandDetailsForm = false;
        this.LandDatatable = false;
        this.isHarvestFormOpen = false;
        this.isHarvestDataOpen = true
        
    
    }

    //================================ end================
//============================================= Add Product Details ======================================
    @track showProductData = false;
    @track showEditView = false;
    @track showOpportunityLineItems = false;
    @track showSavedItems = false;
   // @track createId='';
    @track selectedOrderDetails='';
    

    @track productColumns = [
        { label: 'Product Name', fieldName: 'Name', cellAttributes: { alignment: 'right' } },
        { label: 'Product Code', fieldName: 'ProductCode', cellAttributes: { alignment: 'right' } },
        { label: 'Product Family', fieldName: 'Family', cellAttributes: { alignment: 'right' } },
        { label: 'List Price', fieldName: 'UnitPrice', type: 'currency', cellAttributes: { alignment: 'right' } },
        { label: 'Product Description', fieldName: 'Description', cellAttributes: { alignment: 'right' } }
    ];
    @track editProductColumns = [
        { label: 'Product', fieldName: 'Name', cellAttributes: { alignment: 'right' } },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number', editable: true, cellAttributes: { alignment: 'right' } },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency', cellAttributes: { alignment: 'right' } },
        { label: 'List Price', fieldName: 'ListPrice', type: 'currency', cellAttributes: { alignment: 'right' } },
        { label: 'Line Description', fieldName: 'LineDescription', type: 'text', editable: true, cellAttributes: { alignment: 'right' } }
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
    @track OrderId = '';


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

    // @api
    // addProductsModal() {
    //     this.showProductData = true;
    // }

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
        console.log('Selected Rows:', JSON.stringify(this.selectedRows));
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

    @track orderIdToCreateLineItem = '';
    @track orderId='';

    handleCardClick(event) {
        this.orderId = event.currentTarget.dataset.id;
       console.log('Record ID>>>>>> Card Click:', this.orderId);
    }

    handleAddProducts(event) {
        const orderId = event.currentTarget.dataset.id; // Correctly retrieve the order ID
        this.orderIdToCreateLineItem = orderId;

        this.showEditView = false;
        this.showProductsDetails = false;
        this.showProductData = true;
        this.OrderDetailsForm = false;
        this.OrderDatatable = false;

        console.log('Record ID>>>>>> Button click:', this.orderIdToCreateLineItem);
    }

    
    saveLineItems() {
        // Check if `createId` is present and assign it to `orderIdToCreateLineItem`
        if (this.createId) {
            this.orderIdToCreateLineItem = this.createId;            
        }

        console.log('Created Id=>', this.orderIdToCreateLineItem);
        console.log('New Order Id', this.createId);

        // Create order items to save
        const orderItems = this.productLineItems.map(item => ({
            OrderId: this.orderIdToCreateLineItem,
            Product2Id: item.Id,
            Quantity: item.Quantity,
            UnitPrice: item.UnitPrice,
            Description: item.LineDescription
            // PricebookEntryId: this.pricebookId
        }));

        console.log('Order Items to save:', JSON.stringify(orderItems));

        // Save order line items
        orderLineItems({ orderlineitems: orderItems })
            .then(() => {
                this.OrderDatatable = true;
                this.showOrderDataTable = false;
                this.orderForm = false;
                this.showEditView = false;
                this.showProductData = false;
                this.OrderDetailsForm = false;
                alert('Order Line Item Added Successfully');

                this.refreshNewData();
            })
            .catch(error => {
                console.error('Error saving order items:', error);
            });
    }

    cancelEdit() {
        this.showEditView = false;
        this.showProductData = true;
        this.showOrderDataTable =false;
        this.orderForm = false;
        this.OrderDatatable = false;
        this.OrderDetailsForm = false;
        
    }
    backToOrderDataTable(){
        this.OrderDatatable=true;
        this.showEditView = false;
        this.showProductData = false;
        this.showOrderDataTable =false;
        this.orderForm = false;
        this.OrderDetailsForm = false;
    }
    
    }