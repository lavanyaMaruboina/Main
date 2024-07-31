public without sharing class AddProductsComponent {
    
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> collectproductsData(String searchkey) {
        String searchTerm = searchkey + '%';
        
        List<Product2> products = [
            SELECT Id, Name, ProductCode, Description, Family,
            (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = true LIMIT 1)
            FROM Product2 
            WHERE (Name LIKE :searchTerm OR ProductCode LIKE :searchTerm) 
            AND IsActive = true
            AND Family = 'India'
        ];
        
        List<ProductWrapper> productList = new List<ProductWrapper>();
        for (Product2 product : products) {
            Decimal unitPrice = (product.PricebookEntries.isEmpty()) ? null : product.PricebookEntries[0].UnitPrice;
            productList.add(new ProductWrapper(product, unitPrice));
        }
        system.debug('productList : '+productList);
        return productList;
    }
    
    @AuraEnabled
    public static List<OpportunityLineItemWrapper> getOpportunityLineItems(String opportunityId) {
        List<OpportunityLineItemWrapper> lineItems = new List<OpportunityLineItemWrapper>();
        for (OpportunityLineItem oli : [SELECT Id,name, Product2Id,product2.name, Quantity, UnitPrice, Description FROM OpportunityLineItem WHERE OpportunityId = :opportunityId]) {
            lineItems.add(new OpportunityLineItemWrapper(oli));
        }
        System.debug('lineItems=> '+lineItems);
        return lineItems;
    }
    
    // @AuraEnabled
    // public static void saveOrderItems(List<OrderItemWrapper> orderItems) {
    //     try {
    //         List<OrderItem> orderItemsToInsert = new List<OrderItem>();
    //         for (OrderItemWrapper wrapper : orderItems) {
    //             OrderItem item = new OrderItem();
    //             item.OrderId = wrapper.orderId;
    //             item.Product2Id = wrapper.productId;
    //             item.Quantity = wrapper.quantity;
    //             item.UnitPrice = wrapper.unitPrice;
    //             item.Description = wrapper.lineDescription;
    //             // Set additional fields as necessary
    //             orderItemsToInsert.add(item);
    //         }
    //         insert orderItemsToInsert;
    //         System.debug(orderItemsToInsert);
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    
    //=========================== Start Order Line Items ================================
    
    //   @AuraEnabled
    // public static void orderLineItems(List<OrderItem> orderlineitems) {
    //     try {
    
    //         PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2.IsStandard = true LIMIT 1];
    
    // }
    // }
    @AuraEnabled(cacheable=true)
    public static String pPbIds()
    {
        PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2.IsStandard = true LIMIT 1];
        return pbEntry.Id;
        
    }
    
    //=====================================================
    @AuraEnabled
    public static void orderLineItems(List<OrderItem> orderlineitems) {

        list<OrderItem> itemsToInsert = new list<OrderItem>();
        list<OrderItem> itemsToUpdate = new list<OrderItem>();

        System.debug('orderlineitems =====>'+orderlineitems);
        try {
            
            Set<Id> productIds = new Set<Id>();
            for (OrderItem ol : orderlineitems) {
                productIds.add(ol.Product2Id);
                
                System.debug('productIds =====>'+productIds);
                System.debug('productIdsOLL =====>'+ol);
            }

            map<Id,Id> mapProdIdToItemId = new map<Id,Id>();

            for(Orderitem item: [SELECT Id, Product2Id FROM OrderItem WHERE Product2Id IN:productIds AND OrderId = :orderlineitems[0].OrderId]){
                mapProdIdToItemId.put(item.Product2Id, item.Id);
            }

            
            Map<Id, PricebookEntry> productIdToPricebookEntryMap = new Map<Id, PricebookEntry>();
            for (PricebookEntry pbEntry : [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds AND Pricebook2.IsStandard = true]) {
                
                productIdToPricebookEntryMap.put(pbEntry.Product2Id, pbEntry);
                System.debug('pbEntry =====>'+pbEntry);
                
            }

            Pricebook2 stdPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
            
            
            for (OrderItem ol : orderlineitems) {
                PricebookEntry pbEntry = productIdToPricebookEntryMap.get(ol.Product2Id);
                if (pbEntry != null) {
                    ol.PricebookEntryId = pbEntry.Id;
                } else {
                    throw new AuraHandledException('Pricebook Entry not found for Product with ID: ' + ol.Product2Id);
                }

                If(mapProdIdToItemId.containsKey(ol.Product2Id)){
                    ol.Id = mapProdIdToItemId.get(ol.Product2Id);
                    itemsToUpdate.add(ol);
                }else{
                    itemsToInsert.add(ol);
                }

            }
            
            
            if (orderlineitems.size() > 0 && orderlineitems[0].OrderId != null) {
                
                Order orderRecord = new Order();
                orderRecord.Id = orderlineitems[0].OrderId;
                orderRecord.Pricebook2Id = stdPriceBook.Id;

                update orderRecord;
            } else {
                throw new AuraHandledException('Order is missing for the Order Items.');
            }

            If(itemsToUpdate.size()>0){
                update itemsToUpdate;
            }
            If(itemsToInsert.size()>0){
                insert itemsToInsert;
            }
            
            
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Update Order Line items
    @AuraEnabled
    public static void updateOrderLineItems(List<OrderItem> orderlineitems) {

        list<OrderItem> itemsToInsert = new list<OrderItem>();
        list<OrderItem> itemsToUpdate = new list<OrderItem>();

        System.debug('orderlineitems 123=====>'+orderlineitems);

        try {
            
            Set<Id> productIds = new Set<Id>();
            for (OrderItem ol : orderlineitems) {
                productIds.add(ol.Product2Id);
                
                System.debug('productIds =====>'+productIds);
                System.debug('productIdsOLL =====>'+ol);
            }

            map<Id,Id> mapProdIdToItemId = new map<Id,Id>();

            for(Orderitem item: [SELECT Id, Product2Id FROM OrderItem WHERE Product2Id IN:productIds AND OrderId = :orderlineitems[0].OrderId]){
                mapProdIdToItemId.put(item.Product2Id, item.Id);
            }

            system.debug('mapProdIdToItemId>>'+mapProdIdToItemId);

            
            Map<Id, PricebookEntry> productIdToPricebookEntryMap = new Map<Id, PricebookEntry>();
            for (PricebookEntry pbEntry : [SELECT Id, Pricebook2Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :productIds AND Pricebook2.IsStandard = true]) {
                
                productIdToPricebookEntryMap.put(pbEntry.Product2Id, pbEntry);
                System.debug('pbEntry =====>'+pbEntry);
                
            }

            Pricebook2 stdPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
            
            system.debug('stdPriceBook>>'+stdPriceBook);

            for (OrderItem ol : orderlineitems) {
                PricebookEntry pbEntry = productIdToPricebookEntryMap.get(ol.Product2Id);
                if (pbEntry != null) {
                    ol.PricebookEntryId = pbEntry.Id;
                    ol.UnitPrice = pbEntry.UnitPrice;
                } else {
                    throw new AuraHandledException('Pricebook Entry not found for Product with ID: ' + ol.Product2Id);
                }

                If(mapProdIdToItemId.containsKey(ol.Product2Id)){
                    ol.Id = mapProdIdToItemId.get(ol.Product2Id);
                    itemsToUpdate.add(ol);
                }else{
                    itemsToInsert.add(ol);
                }

            }
            
            
            if (orderlineitems.size() > 0 && orderlineitems[0].OrderId != null) {
                
                Order orderRecord = new Order();
                orderRecord.Id = orderlineitems[0].OrderId;
                orderRecord.Pricebook2Id = stdPriceBook.Id;

                update orderRecord;
            } else {
                throw new AuraHandledException('Order is missing for the Order Items.');
            }

            If(itemsToUpdate.size()>0){
                update itemsToUpdate;
            }
            If(itemsToInsert.size()>0){
                insert itemsToInsert;
            }
            
            
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getStatusPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String contactId) {
        System.debug('searchAccounts method called with contactId: ' + contactId);
    
        // Fetch the contact's pincode
        Contact contact = [SELECT Id, MailingPostalCode FROM Contact WHERE Id = :contactId LIMIT 1];
        System.debug('Fetched contact: ' + contact);
    
        List<Account> accounts = new List<Account>();
    
        // If the contact's pincode is found, fetch matching accounts
        if (contact != null && contact.MailingPostalCode != null) {
            System.debug('Contact\'s MailingPostalCode: ' + contact.MailingPostalCode);
            accounts = [SELECT Id, Name FROM Account WHERE ShippingPostalCode = :contact.MailingPostalCode LIMIT 10];
            System.debug('Fetched accounts with matching pincode: ' + accounts);
        }
    
        // If no accounts found with the same pincode, fetch accounts in descending order of postal code
        if (accounts.isEmpty()) {
            System.debug('No accounts found with matching pincode. Fetching accounts in descending order of postal code.');
            accounts = [SELECT Id, Name FROM Account ORDER BY ShippingPostalCode DESC LIMIT 10];
            System.debug('Fetched accounts in descending order of postal code: ' + accounts);
        }
    
        return accounts;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        return [SELECT Id, Name FROM Contact WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }
    //Order Details
    @AuraEnabled
    public static Order createOrder(Order order, List<string> selectedPrescriptions, string description) {
        try {
            
            List<Prescription_for_Order__c> orderPrescription = new List<Prescription_for_Order__c>();
            
            order.Type__c = 'Order';
            system.debug('description>>'+description);
            order.Prescriptions__c = (string)description;
            insert order;

            set<string> addedPrescriptions = new set<string>();

            For(string prescriptionId : selectedPrescriptions){

                If(!addedPrescriptions.contains(prescriptionId)){
                    Prescription_for_Order__c prOrder = new Prescription_for_Order__c(
                                                                    Order__c = order.id,
                                                                    Prescription__c = prescriptionId
                                                                );

                    orderPrescription.add(prOrder);
                    addedPrescriptions.add(prescriptionId);
                } 
            }
            
            Insert orderPrescription;
            
            return [SELECT Id FROM Order WHERE Id = :order.Id]; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrderDetailsByContactId(Id contactId) {
        try {
            return [SELECT Id, Name,Total_Products__c,Comments_on_prescription__c, EndDate, OrderNumber,TotalAmount, Type, ShippingAddress, EffectiveDate, Status, Contact__r.Name, Account.Name,Contact__c
                    FROM Order 
                    WHERE Contact__c = :contactId ORDER BY Createddate Desc LIMIT 5];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        
    @AuraEnabled
    public static List<OrderItem> getPrescriptionDetails(Id orderIdToFetchLineItem) {
        try {
            system.debug('id received: '+orderIdToFetchLineItem);
            return [select id, Product2.Name, Quantity,Order.OrderNumber from OrderItem where OrderId =: orderIdToFetchLineItem];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<OrderItem> getOrderDetailsEndDate(Id orderIdToCreateLineItem) {
        try {
            return [
                SELECT Id, Product2.Name, Quantity, UnitPrice, Description, Order.OrderNumber
                FROM OrderItem
                WHERE OrderId = :orderIdToCreateLineItem
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getOrderStatus(Id orderId) {
        Order order = [SELECT Status FROM Order WHERE Id = :orderId LIMIT 1];
        return order.Status;
    }
    
    
    
    // @AuraEnabled(cacheable=true)
    // public static List<Order> getOrderDetailsByDealerId(Id accountId) {
    //     try {
    //         return [SELECT Id, Name,Total_Products__c, EndDate, OrderNumber,TotalAmount, Type, ShippingAddress, EffectiveDate, Status, Contact__r.Name, Account.Name
    //                 FROM Order 
    //                 WHERE AccountId = :accountId ORDER BY Createddate Desc LIMIT 5];
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrderDetailsByDealerId(Id accountId) {
        try {
            return [SELECT Id, Name, EndDate, OrderNumber,TotalAmount, Type, ShippingAddress, EffectiveDate, Status, Contact__r.Name, Account.Name,Contact__c
                    FROM Order 
                    WHERE AccountId = :accountId AND Type__c = 'Order' ORDER BY Createddate Desc LIMIT 5];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void saveOrderLineDetails(List<Order_Line_Item__c> data) {
        update data;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrdersByContactId(Id contactId) {
        if (contactId == null) {
            throw new IllegalArgumentException('Contact ID cannot be null');
        }
        return [
            SELECT Id, Name, Status, OrderNumber,
            (SELECT Id, Product2.Name, Quantity
             FROM OrderItems)
            FROM Order
            WHERE Contact__c = :contactId AND  Type__c = 'Prescription' ORDER BY CreatedDate DESC
            LIMIT 3
        ];
    }
    
    @AuraEnabled
    public static List<OrderLineItemWrapper> getOrderLineItems(String orderId) {
        List<OrderLineItemWrapper> lineItems = new List<OrderLineItemWrapper>();
        for (OrderItem oli : [SELECT Id, Product2Id, Product2.Name, Quantity, UnitPrice, Description FROM OrderItem WHERE OrderId = :orderId]) {
            lineItems.add(new OrderLineItemWrapper(oli));
        }
        System.debug('lineItems=> '+lineItems);
        return lineItems;
    }
    //==================== End Oder line Items =====================================
    
    public class ProductWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ProductCode;
        @AuraEnabled public String Description;
        @AuraEnabled public String Family;
        @AuraEnabled public Decimal UnitPrice;
        
        public ProductWrapper(Product2 product, Decimal unitPrice) {
            this.Id = product.Id;
            this.Name = product.Name;
            this.ProductCode = product.ProductCode;
            this.Description = product.Description;
            this.Family = product.Family;
            this.UnitPrice = unitPrice;
        }
    }
    
    public class OpportunityLineItemWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id Product2Id;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public String Description;
        
        public OpportunityLineItemWrapper(OpportunityLineItem oli) {
            this.Id = oli.Id;
            this.Product2Id = oli.Product2Id;
            this.Quantity = oli.Quantity;
            this.UnitPrice = oli.UnitPrice;
            this.Description = oli.Description;
        }
    }
    
    public class OrderLineItemWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id Product2Id;
        @AuraEnabled public String ProductName;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public String Description;
        
        public OrderLineItemWrapper(OrderItem oli) {
            this.Id = oli.Id;
            this.Product2Id = oli.Product2Id;
            this.ProductName = oli.Product2.Name;
            this.Quantity = oli.Quantity;
            this.UnitPrice = oli.UnitPrice;
            this.Description = oli.Description;
        }
    }
    public class OrderLineItemInput {
        @AuraEnabled public Id OrderId;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public String Description;
        @AuraEnabled public Id PricebookEntryId;
    }
    
    @AuraEnabled(cacheable=true)
    public static Account getDealerDetails(Id accountId) {
        try {
            return [SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
            LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}