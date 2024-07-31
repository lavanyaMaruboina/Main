public with sharing class OrderDetailsRelatedProducts {
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
@AuraEnabled(cacheable=true)
public static List<String> getStatusPicklistValues() {
    List<String> picklistValues = new List<String>();
    Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
    for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
        picklistValues.add(entry.getLabel());
    }
    return picklistValues;
}
@AuraEnabled
public static void saveOrderLineDetails(List<Order_Line_Item__c> data) {
    update data;
}
@AuraEnabled(cacheable=true)
public static List<Account> searchAccounts(String searchTerm) {
    return [SELECT Id, Name FROM Account WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
}
}