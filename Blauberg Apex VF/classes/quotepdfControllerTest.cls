@isTest
private class quotepdfControllerTest {
    @isTest
    static void testQuotepdfController() {
 
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser4565@example.com',
            Alias = 'tuser45',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Account testAcc = new Account(Name = 'Lavanya Acc');
        insert testAcc;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        Opportunity testOpp = new Opportunity(
            StageName = 'Initial',
            Name = 'lavanya test',
            CloseDate = system.today(),
            AccountId = testAcc.Id 
        );
        insert testOpp;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
    
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            ContactId = testContact.Id,
            OpportunityId = testOpp.Id,
            ExpirationDate = Date.today().addDays(30),
            Pricebook2Id = standardPricebook.Id,
            Email ='test@gmail.com'
        );
        insert testQuote;
        
        Product2 pro = new Product2(Name = 'iPhone X',StockKeepingUnit='T1-000991');
        Insert pro;
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe1;
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Price Book',
            IsActive = true
        );
        insert customPricebook;
        QuoteLineItem standardQuoteline = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = pbe1.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert standardQuoteline;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Price_Ex_Vat__c = 50.00,
            Price_Inc_Vat__c = 60.00
       
        );
        insert testProduct;
        
        QuoteLineItem testLineItem = new QuoteLineItem(
            QuoteId = testQuote.Id,
            Product2Id = testProduct.Id,
            Quantity = 2,
            UnitPrice = 50.00,
            PricebookEntryId=pbe1.Id
     
        );
        insert testLineItem;

        Test.startTest();
        PageReference pageRef = Page.QuotePDFGenerator; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testQuote.Id);
   
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        quotepdfController controller = new quotepdfController(sc);
        controller.preapredBy = UserInfo.getUserName();
        controller.selectedNumber = 3;
        controller.projectReference = 'test';
        controller.referenceBy = 'tets';
        controller.resumeIndex = 3;
        controller.email='test3@gmail.com';
        controller.billTo = 'Hyderabad';
        controller.shipTo = 'India';
        controller.createdDate = System.today();
        controller.expiryDate = System.today();
        System.assertNotEquals(null, controller.optionalLineGroups);
     
         //System.assertNotEquals(null, controller.optionalLineGroups);

  
       /* testQuote.Pricebook2Id = customPricebook.Id;
        update testQuote;
        controller = new quotepdfController(sc);
        controller.preapredBy = UserInfo.getUserName();
        controller.selectedNumber = 3;
        controller.projectReference = 'test';
        controller.referenceBy = 'test';

        System.assertNotEquals(null, controller.optionalLineGroups);*/
        
        Test.stopTest();
    }
     
    
}