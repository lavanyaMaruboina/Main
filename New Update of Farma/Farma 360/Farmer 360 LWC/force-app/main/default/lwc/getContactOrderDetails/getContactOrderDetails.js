import { refreshApex } from '@salesforce/apex';
import collectproductsData from '@salesforce/apex/AddProductsComponent.collectproductsData';
import createOrder from '@salesforce/apex/AddProductsComponent.createOrder';
import getOpportunityLineItems from '@salesforce/apex/AddProductsComponent.getOpportunityLineItems';
import getOrderList from '@salesforce/apex/AddProductsComponent.getOrderDetailsByContactId';
import getOrderDetailsEndDate from '@salesforce/apex/AddProductsComponent.getOrderDetailsEndDate';
import getPrescriptionDetails from '@salesforce/apex/AddProductsComponent.getPrescriptionDetails';
import orderLineItems from '@salesforce/apex/AddProductsComponent.orderLineItems';
import pPbIds from '@salesforce/apex/AddProductsComponent.pPbIds';
import saveOrderLineDetails from '@salesforce/apex/AddProductsComponent.saveOrderLineDetails';
import searchAccounts from '@salesforce/apex/AddProductsComponent.searchAccounts';
import LightningAlert from 'lightning/alert';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';


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

    @track accounts = [];
    @track accountName = '';
    @track accountId = '';

    @track contactName = '';
    @track draftValues = [];
    @track isorderObj = false;
    @track selectedRows = [];
    @track OrderDetailsForm = false;
    @track OrderDatatable = true;
    @track selectedStatus = 'Draft';
    defaultStatusSet = false;
    @track addProductsDetails = false;
    @track showProductsDetails = false;
    @track productLineItems = [];
    @track showEditView = false;
    wiredOrderLineData;
    @track showAddProductsDetails = false;
    @track createId='';

    selectedOption='Draft';

  @track orderStart = this.getCurrentDate();
  @track Comments= '';

  @track showModal = false;
    endDate = '';
    shippingStreet = '';
    shippingCity = '';
    shippingState = '';
    shippingCountry = '';
    shippingPostalCode = '';
    OrderNumber= '';
    statusField= '';
    EffectiveDate= '';
    EndDate= '';
    orderAmount ='';
    @track pricebookId;
  
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
    getSearchdata(event) {
        this.searchInput = event.target.value;
    }


    checkEndDate() {
        const today = new Date().toISOString().split('T')[0]; 
        console.log('today date ===>',today);
        console.log('today date current ===>',this.selectedRows.EndDate);
        return this.selectedRows.EndDate === today;
    }
    


    @wire(pPbIds)
    wiredPricebookIds({ error, data }) {
        if (data) {
            this.pricebookId = data;
            console.log('pPbIds', this.pricebookId);
        } else if (error) {
            console.error('Error retrieving pricebook ids', error);
        }
    }

    contactName = '';

    @wire(getOrderList, { contactId: '$contactId' })
    getOrderListDetail(result) {
        this.backupResponseFromWire = result;
        if (result.data) {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
    
            this.orderDetails = result.data.map(order => {
                const effectiveDate = new Date(order.EffectiveDate);
                effectiveDate.setHours(0, 0, 0, 0);
    
                return {
                    ...order,
                    ContactName: order.Contact__r ? order.Contact__r.Name : "",
                    effectiveDateFormatted: this.formatDate(effectiveDate),
                    canAddProducts: effectiveDate >= today
                };
            });
    
            if (this.orderDetails.length > 0) {
                this.contactName = this.orderDetails[0].ContactName;
            }
    
            console.log('Order Details >>>>', JSON.stringify(this.orderDetails));
        } else if (result.error) {
            this.orderDetails = undefined;
        }
    }
    

    formatDate(date) {
        let day = date.getDate();
        let month = date.getMonth() + 1; 
        let year = date.getFullYear();
    
        if (day < 10) {
            day = '0' + day;
        }
        if (month < 10) {
            month = '0' + month;
        }
    
        return `${day}-${month}-${year}`;
    }

    handleCreateOrder() {
        this.orderForm = true;
       
        console.log('data : '+ this.orderDetails);
        if (this.orderDetails && this.orderDetails.length > 0) {
            this.contactName = this.orderDetails[0].Contact__r.Name;
        }
       
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
            this.accounts = [];
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
            console.log('this.EndDate==>'+this.EndDate);
        }
        else if (field === 'Order Amount') {
            this.TotalAmount = event.target.value;
        }
    }
    getCurrentDate() {
        const today = new Date();
        const yyyy = today.getFullYear();
        let mm = today.getMonth() + 1; 
        let dd = today.getDate();

        if (dd < 10) dd = '0' + dd;
        if (mm < 10) mm = '0' + mm;

        return `${yyyy}-${mm}-${dd}`;
    }

    handleOrderStartChange(event) {
        this.orderStart = event.target.value;
    }

    handleCommentChange(event) {
        this.Comments = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.endDateId = event.target.dataset.id;
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
        this.shippingStreet = event.target.street;
        this.shippingCity = event.target.city;
        this.shippingState = event.target.province;
        this.shippingCountry = event.target.country;
        this.shippingPostalCode = event.target.postalCode;
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

        const fields = {
            AccountId: this.accountId,
            Status: this.selectedStatus,
            EffectiveDate: this.orderStart,
            Comments_on_prescription__c: this.Comments,
            EndDate: this.endDate,
            Contact__c: this.contactId,
            ShippingStreet: this.shippingStreet,
            ShippingCity: this.shippingCity,
            ShippingState: this.shippingState,
            ShippingCountry: this.shippingCountry,
            ShippingPostalCode: this.shippingPostalCode
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
            
                this.orderForm = false;
                this.showProductData = true;  
                this.orderForm =false;
                this.OrderDatatable = false;
                this.OrderDetailsForm = false;
                this.showEditView = false;
                this.showOpportunityLineItems =false;
                this.showSavedItems =false;

                console.log('refrereshing apex1');
                this.saveLineItems();
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
        this.Comments = '';
        this.endDate = '';
        this.shippingStreet = '';
        this.shippingCity = '';
        this.shippingState = '';
        this.shippingCountry = '';
        this.shippingPostalCode = '';
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
            console.log('productLineItems====>425', JSON.stringify(this.productLineItems));
           
        } else if (result.error) {
            this.productLineItems = result.error;
            

        }
    }

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
  
    @track selectedOrderDetails='';
  
  
   incrementCount(event) {
    var productId = event.currentTarget.dataset.id;
    var product = this.dataTableColumns.find(prod => prod.Id === productId);
    console.log('Product Increament => 421',product);
    
    if (product) {
        product.count++;
    }
    this.dataTableColumns = [...this.dataTableColumns]; 
    console.log('data table of products Increment=>425', JSON.stringify(this.dataTableColumns));
}

decrementCount(event) {
    var productId = event.currentTarget.dataset.id;
    var product = this.dataTableColumns.find(prod => prod.Id === productId);
    console.log('Product Decrement => 421',product);
    
    if (product && product.count > 0) {
        product.count--;
    }
    this.dataTableColumns = [...this.dataTableColumns]; 
    console.log('data table of products Decrement=>425', JSON.stringify(this.dataTableColumns));

}

handleCountChange(event) {
    var productId = event.currentTarget.dataset.id;
    var product = this.dataTableColumns.find(prod => prod.Id === productId);
    if (product) {
        console.log(event.target.value);
        //alert(event.target.value);
        product.count = event.target.value;
        
    }
    this.dataTableColumns = [...this.dataTableColumns];


        console.log('dataTableColumns===>', JSON.stringify(this.dataTableColumns));
    }
    
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
    @track productId = '';


    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
     

        const productIndex = this.products.findIndex(p => p.Id === row.Id);
        if (productIndex !== -1) {
            if (actionName === 'incrementCount') {
                this.products[productIndex].Quantity += 1;
            } else if (actionName === 'decrementCount') {
                if (this.products[productIndex].Quantity > 0) {
                    this.products[productIndex].Quantity -= 1;
                }
            }
        }


        this.products = [...this.products];

    }
   
    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getOpportunityLineItems, { opportunityId: '$recordId' })
    wiredOpportunityLineItems({ error, data }) {
        if (data) {
            this.opportunityLineItems = data.map(item => ({
                Id: item.Id,
                ProductName: item.ProductName,
                Quantity: item.count,
                UnitPrice: item.UnitPrice,
                Description: item.Description
                
            }));
            console.log('data =====>532',JSON.stringify(this.opportunityLineItems));
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

   

    @track allProducts;

    @wire(collectproductsData, { searchkey: '$searchInput' })
    wiredProducts({ error, data }) {
        if (data) {
            this.dataTableColumns = data.map(item => ({
                Id: item.Id,
                Name: item.Name,
                ProductCode: item.ProductCode,
                Family: item.Family,
                Description: item.Description,
                UnitPrice: item.UnitPrice,
                count : 0
                
            }));
            this.allProducts = this.dataTableColumns;
            console.log('product===>582', JSON.stringify(this.dataTableColumns ));
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

@track orderProductList = null;

    handleAddProducts(event) {
        const orderId = event.currentTarget.dataset.id; 
        this.orderIdToCreateLineItem = orderId;
        console.log('Order Got:', this.orderIdToCreateLineItem);
        this.fetchOrderDetails(this.orderIdToCreateLineItem);

        // if(this.checkEndDate()) {
        //     this.showOrderDeliveredAlert();
        //   alert('Order has been Delivered');
        //   this.showProductData = false;
        
        // }
        this.showProductData = true;
        this.showEditView = false;
        this.showProductsDetails = false;
        this.OrderDetailsForm = false;
        this.OrderDatatable = false;
        console.log('Record ID>>>>>> Button click:', this.orderIdToCreateLineItem);  
        
    }

    handleViewProducts(event) {
        const orderId = event.currentTarget.dataset.id; 
        this.orderIdToCreateLineItem = orderId;
        console.log('Order Got:', this.orderIdToCreateLineItem);
        this.fetchOrderItemDetails(this.orderIdToCreateLineItem);

        // if(this.checkEndDate()) {
        //     this.showOrderDeliveredAlert();
        //   //alert('Order has been Delivered');
        //   this.showProductData = false;
        
        // }
        this.showPrescriptionData = true;
        this.showEditView = false;
        this.showProductsDetails = false;
        this.OrderDetailsForm = false;
        this.OrderDatatable = false;
        console.log('Record ID>>>>>> Button click:', this.orderIdToCreateLineItem);  
        
    }
    handleBacktoPrescription(){
        this.showPrescriptionData = false;
        this.showEditView = false;
        this.showProductsDetails = false;
        this.OrderDetailsForm = false;
        this.OrderDatatable = true;

    }




    @track orderEndDate = '';
    @track allProducts;
    @track addOrderNumber;

    fetchOrderDetails(orderIdToCreateLineItem) {
        getOrderDetailsEndDate({ orderIdToCreateLineItem })
            .then(data => {
                if (data && data.length > 0) {
                    console.log('passing Id to check date: ', orderIdToCreateLineItem);
                    console.log('Fetched Order details', JSON.stringify(data));
                    this.addOrderNumber = data.length > 0 ? data[0].Order.OrderNumber : '';
                    let productQuantities = {};
                    data.forEach(orderProduct => {
                        let productId = orderProduct.Product2.Id;
                        let quantity = orderProduct.Quantity;
            
                        if (!productQuantities[productId]) {
                            productQuantities[productId] = 0;
                        }
            
                        productQuantities[productId] += quantity;
                    });
            
                    // Create a new list of products with added quantity field
                    this.dataTableColumns = this.allProducts.map(product => {
                        let productId = product.Id; 
                        let quantity = productQuantities[productId] || 0;
            
                        return { ...product, count: quantity };
                    }).sort((a, b) => b.count - a.count);

                    console.log('this.dataTableColumns Lavanya>>>',JSON.stringify(this.dataTableColumns));
                    this.orderEndDate = data[0].EffectiveDate; // Use EffectiveDate if that's the correct field
                    console.log('today date from apex keval ===>', this.orderEndDate);
                    if (this.checkEndDateToday()) {
                        this.showProductData = false;
                        this.OrderDatatable = true;
                        // alert('Order has been Delivered');
                        this.showOrderDeliveredAlert();
                    }
                    this.refreshApexPrescription();
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }

    @track displayedDataTableColumns = [];
    searchInput = '';

    getSearchdataInProduct(event) {
        console.log('I am called');
        // this.searchInput = event.target.value.toLowerCase();
        // this.filterDataTableColumns();
    }

    filterDataTableColumns() {
        if (!this.searchInput) {
            console.log('I am inside');
            this.displayedDataTableColumns = [...this.dataTableColumns];
        } else {
            this.displayedDataTableColumns = this.dataTableColumns.filter(product => 
                product.Name.toLowerCase().includes(this.searchInput)
            );
        }
        console.log('Filtered dataTableColumns:', JSON.stringify(this.displayedDataTableColumns));
    }


    refreshApexPrescription() {
        // Refresh Apex data for PrescriptionItem and orderDetails
        refreshApex(this.PrescriptionItem)
        .then(() => {
            console.log('Successfully refreshed PrescriptionItem:', this.PrescriptionItem);
        })
        .catch(error => {
            console.error('Error refreshing PrescriptionItem:', error);
        });
        refreshApex(this.orderDetails);
        //refreshApex(this.dataTableColumns);
        console.log('refreshApex(this.orderDetails)==>',refreshApex(this.orderDetails));
    }
    checkEndDateToday() {
        const today = new Date().toISOString().split('T')[0];
        console.log('today date ===>', today);
        console.log('today date current End Date ===>', this.orderEndDate);
        return this.orderEndDate <= today;
    }



    @track PrescriptionItem;
    @track prescriptionNumber;
    @track productQuantity;
    
    fetchOrderItemDetails(orderIdToCreateLineItem) {
        getPrescriptionDetails({ orderIdToFetchLineItem : orderIdToCreateLineItem })
            .then(data => {
                if (data) {
                    this.PrescriptionItem = data;
                    console.log('fetch Order Item Details', JSON.stringify(data));
                    // this.orderEndDate = data[0].EndDate;
                    // console.log('today date current 605===>',this.orderEndDate);
                    // if(this.checkEndDateToday()) {
                    //     this.showProductData = false;
                    //     this.OrderDatatable = true;
                    //     //alert('Order has been Delivered');
                    //     this.showOrderDeliveredAlert();
    
                    // }
                    this.productQuantity = data[0].Quantity;
                    this.prescriptionNumber = data[0]?.Order?.OrderNumber;
                    
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }

    saveLineItems(event) {    
        let orderIdToCreateLineItem = '';   
        if (this.createId) { 
            orderIdToCreateLineItem = this.createId;
            console.log('New Order Id', orderIdToCreateLineItem);
        } else {
            orderIdToCreateLineItem = this.orderIdToCreateLineItem;
            console.log('Selected Order Id>>.', orderIdToCreateLineItem);
        }
    
        console.log('Created Id=> ', orderIdToCreateLineItem);
    
        const orderItems = this.dataTableColumns
        .filter(item => item.count !== 0 && item.count !== null && item.count !== undefined)
        .map(item => ({
            OrderId: orderIdToCreateLineItem,
            Product2Id: item.Id,
            Quantity: item.count,
            UnitPrice: item.UnitPrice,
            Description: item.LineDescription
            //PricebookEntryId: this.pricebookId
        }));
    
        console.log('Filtered Order Items:', JSON.stringify(orderItems));
        console.log('Order Items to save:', JSON.stringify(orderItems));

        orderLineItems({ orderlineitems: orderItems })
            .then(() => {
                this.OrderDatatable = true;
                this.showOrderDataTable = false;
                this.orderForm = false;
                this.showEditView = false;
                this.showProductData = false;
                this.OrderDetailsForm = false;
                this.showSuccessAlertPrescription();
                //alert('Order Line Item Added Successfully');
                console.log('template true>>>', this.OrderDatatable);
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
      // Method to show an error alert
      showErrorAlert(headerLabel, bodyMessage) {
        LightningAlert.open({
            message: bodyMessage,
            theme: 'error',
            label: headerLabel,
        });
    }
    //Method to show success land
    showSuccessAlertPrescription() {
        LightningAlert.open({
            message: 'Prescription Save Successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
    showOrderDeliveredAlert() {
        LightningAlert.open({
            message: 'Prescription has been Delivered',
            theme: 'Warning',
            label: 'Warning',
        });
    }
    
    }