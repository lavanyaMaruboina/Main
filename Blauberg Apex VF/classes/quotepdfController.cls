public without sharing class quotepdfController {
    public String introSection { get; private set; }
    public String deliverySection { get; private set; }
    public String termsAndConditions { get; private set; }
    public String exclusionsSection { get; private set; }
    public Quote quoteData { get; private set; }
    public User currentUser { get; set; }
    public static List<QuoteLineItem> quoteLineItemsWithout { get; private set; }
    public static List<QuoteLineItem> quoteLineItemsWith { get; private set; }
    public String contactName { get; private set; }
    public String contactEmail { get; private set; }
    public Quote quotationData { get; set; }
    public String projectName { get; private set; }
    public Date todayDate { get; private set; }
    public Integer selectedNumber { get; set; }
    public string referenceBy { get; set; }
    public string projectReference { get; set; }
    public Datetime createdDate { get; set; }
    public Datetime expiryDate { get; set; }
    public string billTo { get; set; }
    public string preapredBy { get; set; }
    public string email { get; set; }
    public string shipTo { get; set; }
    public string VATNumber { get; set; }
    public String blauberg1_Site { get; set; }
    public String blauberg2_Site{ get; set; }
    public String blauberg1_Site_Title { get; set; }
    public String blauberg2_Site_Title{ get; set; }
    public Integer resumeIndex { get; set; }
    public List<QuoteLineItem> lineItemsWithoutOptionalLines { get; set; }
    public List<OptionalLineGroup> optionalLineGroups { get; private set; }
    
    public quotepdfController(ApexPages.StandardController controller) {
        QuotePDF__mdt[] notesRecords = [SELECT Intro__c,Delivery_Section__c,TermsAndConditions__c,Exclusions_Section__c FROM QuotePDF__mdt LIMIT 1];
        if (!notesRecords.isEmpty()) {
            introSection = notesRecords[0].Intro__c;
            deliverySection = notesRecords[0].Delivery_Section__c;
            termsAndConditions = notesRecords[0].TermsAndConditions__c;
            exclusionsSection= notesRecords[0].Exclusions_Section__c;
        }
        
        //String recordID='0Q0UF000000AUo10AG';
        String recordId = ApexPages.currentPage().getParameters().get('Id');
        quoteData = [SELECT Id, Name, Owner.Name, Owner.Email, Owner.UserRole.Name, Owner.Phone,
                     BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                     BillingName, ShippingCity, ShippingCountry, ShippingName, ShippingPostalCode,
                     ShippingState, ShippingStreet, ContactId, Description, CreatedDate, QuoteNumber,
                     Quote_Ref__c, Contact.Name, Project_Reference__c, ShippingAddress, BillingAddress,
                     ExpirationDate, Contact.Email, OwnerId, TotalPrice,ShippingHandling,Grand_Total__c,VAT__c
                     FROM Quote WHERE Id =: recordId LIMIT 1]; 
        
        blauberg1_Site = Label.blauberg1_Site;
        blauberg2_Site = Label.blauberg2_Site;
        blauberg1_Site_Title = Label.blauberg1_Site_Title;
        blauberg2_Site_Title = Label.blauberg2_Site_Title;
        
        currentUser = [SELECT Name, Email FROM User WHERE Id = :UserInfo.getUserId()];
        
        contactName = '';
        contactEmail = '';
        if (quoteData != null) {
            contactName = quoteData.Contact.Name;
            contactEmail = quoteData.Contact.Email;
        }
        
        currentUser = [SELECT Name, Email, Phone, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        
        todayDate = System.today();   
        lineItemsWithoutOptionalLines = new List<QuoteLineItem>();
        
        try {
            
            quoteLineItemsWith = [SELECT Id, QuoteId, Product2.Name,Product2.ProductCode, Product2.Description, Product2.Price_Ex_Vat__c, Product2.Price_Inc_Vat__c, ListPrice,
                                  TotalPrice, Subtotal, Discount, Quantity, Optional_Line__c 
                                  FROM QuoteLineItem 
                                  WHERE QuoteId = :quoteData.id AND Optional_Line__c != null];
            System.debug('quoteLineItems---------------- ' + quoteLineItemsWith);
            quoteLineItemsWithout = [SELECT QuoteId,Product2.Name,Product2.ProductCode,Product2.Description,Product2.Price_Ex_Vat__c,Product2.Price_Inc_Vat__c,ListPrice,
                                     TotalPrice,Subtotal,Discount,Quantity,Optional_Line__c FROM QuoteLineItem WHERE QuoteId = :quoteData.id AND Optional_Line__c = null ORDER BY Optional_Line__c];
            System.debug('quoteLineItems---------------- ' + quoteLineItemsWithout);
            optionalLineGroups = new List<OptionalLineGroup>();
            Map<String, OptionalLineGroup> groupMap = new Map<String, OptionalLineGroup>();
            for (QuoteLineItem item : quoteLineItemsWith) {
                String optionalLine = item.Optional_Line__c;
                if (!groupMap.containsKey(item.Optional_Line__c)) {
                    groupMap.put(item.Optional_Line__c, new OptionalLineGroup(item.Optional_Line__c));
                }
                groupMap.get(item.Optional_Line__c).items.add(item);
            }
            optionalLineGroups.addAll(groupMap.values());
            for (QuoteLineItem item : quoteLineItemsWithout) {
                lineItemsWithoutOptionalLines.add(item);
            }
            
        } catch(Exception e) {
            System.debug('Exception Error: ' + e.getMessage());
        }
        
    }
    public class OptionalLineGroup {
        public String optionalLine { get; set; }
        public List<QuoteLineItem> items { get; set; }
        
        public OptionalLineGroup(String optionalLine) {
            this.optionalLine = optionalLine;
            items = new List<QuoteLineItem>();
        }
    }   
}