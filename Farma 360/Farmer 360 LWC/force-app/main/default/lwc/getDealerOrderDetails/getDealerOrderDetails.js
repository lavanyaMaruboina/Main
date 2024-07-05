import { refreshApex } from '@salesforce/apex';
import collectproductsData from '@salesforce/apex/AddProductsComponent.collectproductsData';
import createOrder from '@salesforce/apex/AddProductsComponent.createOrder';
import getOpportunityLineItems from '@salesforce/apex/AddProductsComponent.getOpportunityLineItems';
import getOrderList from '@salesforce/apex/AddProductsComponent.getOrderDetailsByContactId';
import getDealerOrderList from '@salesforce/apex/AddProductsComponent.getOrderDetailsByDealerId'; // kareem created
import getOrderDetailsEndDate from '@salesforce/apex/AddProductsComponent.getOrderDetailsEndDate';
//import getOrderStatus from '@salesforce/apex/AddProductsComponent.getOrderStatus';
import getDealerDetails from '@salesforce/apex/AddProductsComponent.getDealerDetails';
import getOrdersByContactId from '@salesforce/apex/AddProductsComponent.getOrdersByContactId';
import getPrescriptionDetails from '@salesforce/apex/AddProductsComponent.getPrescriptionDetails';
import orderLineItems from '@salesforce/apex/AddProductsComponent.orderLineItems';
import pPbIds from '@salesforce/apex/AddProductsComponent.pPbIds';
import saveOrderLineDetails from '@salesforce/apex/AddProductsComponent.saveOrderLineDetails';
import searchContacts from '@salesforce/apex/AddProductsComponent.searchContacts';
import updateOrderLineItems from '@salesforce/apex/AddProductsComponent.updateOrderLineItems';
import LightningAlert from 'lightning/alert';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';

export default class GetDealerOrderDetails extends LightningElement {

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
    @api accountId;
    @track orderDetails;
    @track dealerOrderDetails; // Kareem Created
    @track orderForm = false;

    @track accounts = [];
    @track contacts = [];
    @track accountName = '';
    //@track accountId = ''; // 001QH00000kfXvBYAU

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
    @track orderStatus;
    @track addOrderNumber;

    selectedOption='Draft';

  @track orderStart = this.getCurrentDate();

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
   @track showPrescriptionData=false;
   @track accountOrderList;
   @track accountOrderName='';


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
    @wire(getDealerDetails, { accountId: '$accountId' })
    wiredDealerDetails({ error, data }) {
        console.log('Wire method called>>>')
        if (data) {
            console.log('Wire method inside>>>', this.data);
            this.accountOrderList = [data];
            this.accountOrderName = data.Name;
       
        } else if (error) {
            console.error('Error fetching Dealer details:', error);
        }
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

    @wire(getOrderList, { contactId: '$contactId' })
    getOrderListDetail(result) { 
        //this.backupResponseFromWire = result;
        if (result.data) {
            this.orderDetails = result.data;
            console.log('Order Details >>>>', JSON.stringify(this.orderDetails));
        } else if (result.error) {
            this.orderDetails = undefined;
        }
    }

    //@track accountName;

    @wire(getDealerOrderList, { accountId: '$accountId' })
    getOrderDetailsByDealer(result) { 
        this.backupResponseFromWire = result;
        if (result.data) {
            this.dealerOrderDetails = result.data.map(order => ({
                ...order,
                effectiveDateFormatted: this.formatDate(new Date(order.EffectiveDate)),
                endDateFormatted: this.formatDate(new Date(order.EndDate)),
                statusDraft: this.checkStatusDraft(order.Status),
                canAddProducts: order.Status === 'Draft'
            }));
            if (this.dealerOrderDetails.length > 0) {
                this.contactName = this.orderDetails[0].ContactName;
        
            }
            console.log('Dealer Order Details >>>>', JSON.stringify(this.dealerOrderDetails));
        } else if (result.error) {
            this.dealerOrderDetails = undefined;
            this.accountName = ''; 
        }
    }

    checkStatusDraft(status) {
        return status === 'Draft';
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

    // @track accountName;

    // @wire(getDealerOrderList, { accountId: '$accountId' })
    // getOrderDetailsByDealerId(result) {
    //     this.backupResponseFromWire = result;
    //     if (result.data) {
    //         this.dealerOrderDetails = result.data.map(order => ({
    //             ...order,
    //             accountName: order.Account ? order.Account.Name : ""
    //         }));
    //         if (this.dealerOrderDetails.length > 0) {
    //             this.accountName = this.dealerOrderDetails[0].AccountName;
    //            // console.log('Dealer Name>>', this.accountName);
    //         }
    //         console.log('Dealer Order Details >>>>', JSON.stringify(this.dealerOrderDetails));
    //     } else if(result.error) {
    //         this.dealerOrderDetails = undefined;
    //     }
    // }

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

    handleContactSearch(event) {
        this.contactName = event.target.value;
        if (this.contactName.length > 2) {
            searchContacts({ searchTerm: this.contactName })
                .then(result => {
                    this.contacts = result;
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
            this.contacts = [];
        }
    }


    selectContact(event) {
        this.contactId = event.target.dataset.id;
        this.contactName = event.target.label;
        console.log('selected contact Id>>', this.contactId);
        this.getPrescription();
        this.contacts = [];
        
    }

    @track ordersRelatedToContact;
    @track isModalOpen =false;

    //Keval
    getPrescription() {
        getOrdersByContactId({ contactId: this.contactId })
            .then((result) => {
                this.ordersRelatedToContact = result;
                this.isModalOpen = true;
                console.log('Fetched orders:', JSON.stringify(this.ordersRelatedToContact));
            })
            .catch((error) => {
                console.error('Error fetching orders:', error);
            });
    }

    

    //Keval
    @track selectedOrderNumbers = [];
    @track sectedPrescritpionDescription = '';

    handlePrescriptionChange(event){
        this.sectedPrescritpionDescription = event.target.value;
    }

    closeModal() {
        this.isModalOpen = false;

        console.log('this.selectedOrderNumbers>>>'+this.selectedOrderNumbers);
        console.log('this.ordersRelatedToContact>>>'+JSON.stringify(this.ordersRelatedToContact));

        this.sectedPrescritpionDescription = this.getSelectedOrderNames(this.ordersRelatedToContact,this.selectedOrderNumbers);
        console.log('we got the descritpion>>'+this.sectedPrescritpionDescription);
    }

    getSelectedOrderNames(orders, selectedNumbers) {

        console.log('the received ids1>>'+selectedNumbers);
        console.log('the received ids2>>'+JSON.stringify(orders));
        
        const selectedOrders = orders.filter(order => selectedNumbers.includes(order.Id));
        console.log('selectedOrders>>>'+selectedOrders);

        const selectedOrderNames = selectedOrders.map(order => order.OrderNumber);
        console.log('selectedOrders>>>'+selectedOrderNames);
        return selectedOrderNames.join(', ');

    }

    handleCheckboxChange(event) {

        const checkedOrderNumber = event.target.value;
        if (event.target.checked) {

            console.log('adding order ids');

            if (!this.selectedOrderNumbers.includes(checkedOrderNumber)) {
                this.selectedOrderNumbers.push(checkedOrderNumber);
            }

            
        } else {
            const index = this.selectedOrderNumbers.indexOf(checkedOrderNumber);
            if (index !== -1) {
                this.selectedOrderNumbers.splice(index, 1);
            }
        }
        console.log('Selected Order Numbers:', JSON.stringify(this.selectedOrderNumbers));

        this.addQuantityForSelectedOrderProducts();
        //console.log('selectedOrderProducts>>',JSON.stringify(this.selectedOrderProducts));
    }


    @track selectedOrderProducts;

    //Sudarshan N B
    addQuantityForSelectedOrderProducts() {

        console.log('the addQuantityForSelectedOrderProducts is running>>');

        let productQuantities = {};

        this.ordersRelatedToContact.forEach(order => {
            if (this.selectedOrderNumbers.includes(order.Id)) {
                order.OrderItems.forEach(orderItem => {
                    let productId = orderItem.Product2Id; 
                    let quantity = orderItem.Quantity; 

                    if (!productQuantities[productId]) {
                        productQuantities[productId] = 0;
                    }

                    productQuantities[productId] += quantity;
                });
            }
        });

        console.log('the productQuantities>>',JSON.stringify(productQuantities));

        // Map over dataTableColumns to add the quantity field to each product
        this.dataTableColumns =  this.dataTableColumns.map(product => {
            let productId = product.Id;
            let quantity = productQuantities[productId] || 0;

            return { ...product, count: quantity };
        }).sort((a, b) => b.count - a.count);

        console.log('the this.dataTableColumns>>',JSON.stringify(this.dataTableColumns));
        
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
            Contact__c : this.contactId,
            Status: this.selectedStatus,
            EffectiveDate: this.orderStart,
            EndDate: this.endDate,
            //AccountId: this.accountId,
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
        
       createOrder({ order: fields, selectedPrescriptions : this.selectedOrderNumbers, description: this.sectedPrescritpionDescription})
            .then(result => {
                this.orderDetails = [...this.orderDetails, result];
                this.createId = result.Id; 
                console.log('Create Order Id : ', this.createId);
                console.log('Order Fields result : ', result);
                console.log('Order Fields : ', this.orderDetails);
                this.orderForm = false;
                //this.showProductData = true;  
                this.orderForm =false;
                this.OrderDatatable = true;
                this.OrderDetailsForm = false;
                this.showEditView = false;
                this.showOpportunityLineItems =false;
                this.showSavedItems =false;
                console.log('refrereshing apex1');
                this.saveLineItems();
                this.refreshNewData();
            })
            .catch(error => {
                console.error(error);
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
        this.shippingStreet = '';
        this.shippingCity = '';
        this.shippingState = '';
        this.shippingCountry = '';
        this.shippingPostalCode = '';
        this.contactId = '';
        this.contactName = ''; 
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
    let listname = event.currentTarget.dataset.listname;
    console.log('listname>>',listname);
    var product = this[listname].find(prod => prod.Id === productId);
    console.log('Product Increament => 421',product);
    
    if (product) {
        product.count++;
    }
    this[listname] = [...this[listname]]; 
    console.log('data table of products Increment=>425, ', JSON.stringify(this[listname]));
}

decrementCount(event) {
    var productId = event.currentTarget.dataset.id;
    let listname = event.currentTarget.dataset.listname;
    var product = this[listname].find(prod => prod.Id === productId);
    console.log('Product Decrement => 421',product);
    
    if (product && product.count > 0) {
        product.count--;
    }
    this[listname] = [...this[listname]]; 
    console.log('data table of products Decrement=>425', JSON.stringify(this[listname]));

}

handleCountChange(event) {
    var productId = event.currentTarget.dataset.id;
    let listname = event.currentTarget.dataset.listname;
    var product = this[listname].find(prod => prod.Id === productId);
        if (product) {
            console.log(event.target.value);
            //alert(event.target.value);
            product.count = event.target.value;
            
        }
        this[listname] = [...this[listname]];


            console.log('dataTableColumns===>', JSON.stringify(this[listname]));
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

    getSearchdata(event) {
        this.searchInput = event.target.value;
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
                
            })).sort((a, b) => b.count - a.count);

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
    @track orderProductList = null;

    handleCardClick(event) {
        this.orderId = event.currentTarget.dataset.id;
       console.log('Record ID>>>>>> Card Click:', this.orderId);
    }

    handleAddProducts(event) {
        
        const orderId = event.currentTarget.dataset.id; 
        this.orderIdToCreateLineItem = orderId;

        console.log('Order Got:', this.orderIdToCreateLineItem);
        this.fetchOrderDetails(this.orderIdToCreateLineItem);

        // if(this.checkEndDate()) {
        //     this.showSuccessOrderDeliverAlert();
        //   //alert('Order has been Delivered');
        //     this.showProductData = false;
        
        // }
        this.showProductData = true;
        this.showEditView = false;
        this.showProductsDetails = false;
        this.OrderDetailsForm = false;
        this.OrderDatatable = false;

        console.log('Record ID>>>>>> Button click:', this.orderIdToCreateLineItem);  
        
    }

    @track orderItem;
    @track ordersNumber;
    @track productQuantity;

    fetchOrderItemDetails(orderIdToCreateLineItem) {
        getPrescriptionDetails({ orderIdToFetchLineItem : orderIdToCreateLineItem })
            .then(data => {
                if (data) {
                    this.orderItem = data.sort((a, b) => b.Quantity - a.Quantity);
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
                    //this.ordersNumber = data[0]?.Order?.OrderNumber;
                    
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }

    handleViewProducts(event) {
        const orderId = event.currentTarget.dataset.id; 
        this.orderIdToCreateLineItem = orderId;

        
        const order = this.dealerOrderDetails.find(order => order.Id === orderId);
        this.ordersNumber = order ? order.orderNumber : undefined;

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
    @track orderEndDate ='';
    
    fetchOrderDetails(orderIdToCreateLineItem) {
        getOrderDetailsEndDate({ orderIdToCreateLineItem })
            .then(data => {
                if (data) {
                    console.log('Fetched Order details', JSON.stringify(data));
                    //this.orderStatus = data[0].Status;
                    //this.addOrderNumber =data[0].OrderNumber;
                    //this.addOrderNumber = data[0]?.Order?.OrderNumber;
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
                    this.orderProductList = this.allProducts.map(product => {
                        let productId = product.Id; 
                        let quantity = productQuantities[productId] || 0;
            
                        return { ...product, count:quantity };
                    }).sort((a, b) => b.count - a.count);



                    // adding the order items to the product data
                    // this.orderProductList = data.map(item => {
                                   
                    //     return { count: item.Quantity, Name: item.Product2.Name, Id: item.Product2.Id,  UnitPrice : item.UnitPrice, Description: item.Description, itemId:item.Id};
                    // });

                    console.log('this.orderProductList1>>>',JSON.stringify(this.orderProductList));

                   if (this.checkStatusDraft()) {
                        this.showProductData = true;
                        this.OrderDatatable = false;
                        // alert('Order has been Delivered');
                        this.showSuccessOrderDeliverAlert();
                    }
    
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }  
  
    
   
    // fetchOrderStatus(orderIdToCreateLineItem) {
    //     getOrderStatus({ orderIdToCreateLineItem })
    //         .then(data => {
    //             if (data) {
    //                 console.log('Fetched Order Status', JSON.stringify(data));
    //                 this.orderStatus = data;
    //             }
    //         })
    //         .catch(error => {
    //             console.error('Error fetching order status:', error);
    //         });
    // }


    // checkEndDateToday() {
    //     const today = new Date().toISOString().split('T')[0];
    //     console.log('today date ===>', today);
    //     console.log('today date current End Date ===>', this.orderEndDate);
    //     return this.orderEndDate <= today;
    // } 


    saveLineItems(event) {    
        let orderIdToCreateLineItem = '';   
        if (this.createId) { 
            orderIdToCreateLineItem = this.createId;
            console.log('New Order Id', orderIdToCreateLineItem);
        } else {
            orderIdToCreateLineItem = this.orderIdToCreateLineItem;
            console.log('Selected Order Id>>.', orderIdToCreateLineItem);
        }
    
        console.log('Created Id=> 1', orderIdToCreateLineItem);

        console.log('orderProductList Id=> 1', this.dataTableColumns);
    
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
                //alert('Order Line Item Added Successfully');
                this.showSuccessOrderAlert();
                console.log('template true>>>', this.OrderDatatable);
                this.refreshNewData();
            })
            .catch(error => {
                this.showErrorAlert();
                console.error('Error saving order items:', error);
            });
    }

    saveOrderProducts(event) {    
        let orderIdToCreateLineItem = '';   
        if (this.createId) { 
            orderIdToCreateLineItem = this.createId;
            console.log('New Order Id1', orderIdToCreateLineItem);
        } else {
            orderIdToCreateLineItem = this.orderIdToCreateLineItem;
            console.log('Selected Order Id1>>.', orderIdToCreateLineItem);
        }
    
        console.log('Created Id=>1 ', orderIdToCreateLineItem);
    
        const orderItems = this.orderProductList
        .filter(item => item.count !== 0 && item.count !== null && item.count !== undefined)
        .map(item => ({
            Id: item.itemId,
            OrderId: orderIdToCreateLineItem,
            Product2Id: item.Id,
            Quantity: item.count
            //UnitPrice: item.UnitPrice,
            //Description: item.LineDescription
            //PricebookEntryId: this.pricebookId
        }));
    
        console.log('Filtered Order Items1:', JSON.stringify(orderItems));
        console.log('Order Items to save1:', JSON.stringify(orderItems));

        updateOrderLineItems({ orderlineitems: orderItems })
            .then(() => {
                this.OrderDatatable = true;
                this.showOrderDataTable = false;
                this.orderForm = false;
                this.showEditView = false;
                this.showProductData = false;
                this.OrderDetailsForm = false;
                //alert('Order Line Item Added Successfully');
                this.showSuccessOrderAlert();
                console.log('template true>>>', this.OrderDatatable);
                this.refreshNewData();
            })
            .catch(error => {
                this.showErrorAlert();
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
        //earasing the Order details;
        this.orderProductList = null;

        this.OrderDatatable=true;
        this.showEditView = false;
        this.showProductData = false;
        this.showOrderDataTable =false;
        this.orderForm = false;
        this.OrderDetailsForm = false;
    }
    showErrorAlert(headerLabel, bodyMessage) {
        LightningAlert.open({
            message: bodyMessage,
            theme: 'error',
            label: headerLabel,
        });
    }

    showSuccessOrderAlert() {
        LightningAlert.open({
            message: 'Order is created successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
    showSuccessOrderDeliverAlert(){
        LightningAlert.open({
            message: 'Order has been Delivered',
            theme: 'Success',
            label: 'Success',
        });
    }


}