public without sharing class OrderPDFController {

    public Order orderData { get; private set; }
    public User currentUser { get; set; }
    public List<OrderItem> orderLineItems { get; private set; }
    public String contactName { get; private set; }
    public Date todayDate { get; private set; }
    public String introSection { get; private set; }
    public String deliverySection { get; private set; }
    public String termsAndConditions { get; private set; }
    public String exclusionsSection { get; private set; }

    public OrderPDFController(ApexPages.StandardController controller) {
        Order_PDF_Generator__mdt[] notesRecords = [SELECT Intro__c, Delivery_Section__c, TermsAndConditions__c, Exclusions_Section__c FROM Order_PDF_Generator__mdt LIMIT 1];
        if (!notesRecords.isEmpty()) {
            introSection = notesRecords[0].Intro__c;
            deliverySection = notesRecords[0].Delivery_Section__c;
            termsAndConditions = notesRecords[0].TermsAndConditions__c;
            exclusionsSection = notesRecords[0].Exclusions_Section__c;
        }
             String recordId='801QH000010Ev7ZYAS';
        //String recordId = ApexPages.currentPage().getParameters().get('Id');
        
        orderData = [SELECT Id, Name, EndDate, OrderNumber, TotalAmount, Type, BillingAddress, EffectiveDate, Status, 
                            Contact__r.Name,Contact__r.Email, Account.Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                            BillingCountry,Contact__r.MailingStreet, Contact__r.MailingCity,Contact__r.MailingState,Contact__r.MailingPostalCode,Contact__r.MailingCountry 
                     FROM Order WHERE Id = :recordId LIMIT 1];
        
        contactName = '';
        if (orderData != null) {
            contactName = orderData.Contact__r.Name;
        }
        
        currentUser = [SELECT Name, Email, Phone, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        
        orderLineItems = [SELECT Id, Product2Id, Product2.Name, Quantity, UnitPrice,ListPrice,Product2.ProductCode,TotalPrice, Product2.Description, Product2.Family
                          FROM OrderItem WHERE OrderId = :recordId AND  Product2.Family='India'];
        
        /*if (orderLineItems.Description != null){
            Description = orderLineItems.Description;
        }
        else{
             Description = orderLineItems.Description;
        }*/
        
        todayDate = System.today();
    }
}