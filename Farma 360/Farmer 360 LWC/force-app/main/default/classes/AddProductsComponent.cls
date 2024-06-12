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
    System.debug('orderlineitems =====>'+orderlineitems);
    try {
      
        Set<Id> productIds = new Set<Id>();
        for (OrderItem ol : orderlineitems) {
            productIds.add(ol.Product2Id);

            System.debug('productIds =====>'+productIds);
            System.debug('productIdsOLL =====>'+ol);
        }

        Map<Id, PricebookEntry> productIdToPricebookEntryMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbEntry : [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds]) {
            
            productIdToPricebookEntryMap.put(pbEntry.Product2Id, pbEntry);
            System.debug('pbEntry =====>'+pbEntry);
            
        }

       
        for (OrderItem ol : orderlineitems) {
            PricebookEntry pbEntry = productIdToPricebookEntryMap.get(ol.Product2Id);
            if (pbEntry != null) {
                ol.PricebookEntryId = pbEntry.Id;
            } else {
                throw new AuraHandledException('Pricebook Entry not found for Product with ID: ' + ol.Product2Id);
            }
        }

       
        if (orderlineitems.size() > 0 && orderlineitems[0].OrderId != null) {
          
            Order orderRecord = [SELECT Id FROM Order WHERE Id = :orderlineitems[0].OrderId LIMIT 1];
            orderRecord.Pricebook2Id = productIdToPricebookEntryMap.values().isEmpty() ? null : productIdToPricebookEntryMap.values().get(0).Pricebook2Id;
            update orderRecord;
        } else {
            throw new AuraHandledException('Order is missing for the Order Items.');
        }

        insert orderlineitems;
    } catch (Exception e) {
        System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
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
public static List<Account> searchAccounts(String searchTerm) {
    return [SELECT Id, Name FROM Account WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
}
 //Order Details
 @AuraEnabled
 public static Order createOrder(Order order) {
     try {
         insert order;
         return [SELECT Id FROM Order WHERE Id = :order.Id]; 
     } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
     }
 }
 @AuraEnabled(cacheable=true)
    public static List<Order> getOrderDetailsByContactId(Id contactId) {
        try {
            return [SELECT Id, Name, EndDate, OrderNumber,TotalAmount, Type, BillingAddress, EffectiveDate, Status, Contact__r.Name, Account.Name
                    FROM Order 
                    WHERE Contact__c = :contactId ORDER BY Createddate Desc LIMIT 5];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
      
    @AuraEnabled
    public static void saveOrderLineDetails(List<Order_Line_Item__c> data) {
        update data;
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


   }