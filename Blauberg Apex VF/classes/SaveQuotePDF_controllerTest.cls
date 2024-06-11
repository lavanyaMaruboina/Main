@isTest
private class SaveQuotePDF_controllerTest {

     @isTest
    static void testSendMailMethod() {
        // Create test data
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;

        Opportunity testOpp = new Opportunity(
            StageName = 'Initial',
            Name = 'Test Opportunity',
            CloseDate = System.today(),
            AccountId = testAcc.Id
        );
        insert testOpp;

        // Create a product
        Product2 pro = new Product2(Name = 'Test Product', StockKeepingUnit='T1-000991');
        insert pro;

        // Define standard price for the product
        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pro.Id,
            UnitPrice = 100, // Standard price
            IsActive = true
        );
        insert standardPBE;

        // Create custom pricebook
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Price Book',
            IsActive = true
        );
        insert customPricebook;

        // Create custom price for the product in the custom pricebook
        PricebookEntry customPBE = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            UnitPrice = 120, // Custom price
            Product2Id = pro.Id,
            IsActive = true
        );
        insert customPBE;

        // Create Quote with custom pricebook
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            ContactId = testContact.Id,
            OpportunityId = testOpp.Id,
            ExpirationDate = Date.today().addDays(30),
            Pricebook2Id = customPricebook.Id, // Use custom pricebook
            Email ='test@gmail.com'
        );
        insert testQuote;

        // Create Quote Line Item referencing the custom price
        QuoteLineItem customQuoteline = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = customPBE.Id, // Use custom pricebook entry
            Quantity = 1,
            UnitPrice = 45
        );
        insert customQuoteline;
        Test.startTest();
        // Set up the PageReference without using getContent()
        PageReference pageRef = new PageReference('/apex/QuotePDFGenerator');
        pageRef.getParameters().put('Id', testQuote.Id);
        Test.setCurrentPage(pageRef);

        // Instantiate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        SaveQuotePDF_controller controller = new SaveQuotePDF_controller(sc);

    
        controller.sendMailMethod();
        
        Test.stopTest();

    } 

    @isTest
    static void testAttachAndSaveMethod() {
        // Create test data
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        
        Opportunity testOpp = new Opportunity(
            StageName = 'Initial',
            Name = 'Test Opportunity',
            CloseDate = System.today(),
            AccountId = testAcc.Id
        );
        insert testOpp;

        // Create a product
        Product2 pro = new Product2(Name = 'Test Product', StockKeepingUnit='T1-000991');
        insert pro;

        // Define standard price for the product
        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pro.Id,
            UnitPrice = 100, // Standard price
            IsActive = true
        );
        insert standardPBE;

        // Create custom pricebook
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Price Book',
            IsActive = true
        );
        insert customPricebook;

        // Create custom price for the product in the custom pricebook
        PricebookEntry customPBE = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            UnitPrice = 120, // Custom price
            Product2Id = pro.Id,
            IsActive = true
        );
        insert customPBE;

        // Create Quote with custom pricebook
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            ContactId = testContact.Id,
            OpportunityId = testOpp.Id,
            ExpirationDate = Date.today().addDays(30),
            Pricebook2Id = customPricebook.Id, // Use custom pricebook
            Email ='test@gmail.com'
        );
        insert testQuote;

        // Create Quote Line Item referencing the custom price
        QuoteLineItem customQuoteline = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = customPBE.Id, // Use custom pricebook entry
            Quantity = 1,
            UnitPrice = 45
        );
        insert customQuoteline;

        Test.startTest();

        // Set up the PageReference
        PageReference pageRef = Page.QuotePDFGenerator;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testQuote.Id);

        // Instantiate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        SaveQuotePDF_controller controller = new SaveQuotePDF_controller(sc);

        // Call the method to be tested
        controller.attachAndSave();

        // Add assertions to verify the behavior of the attachAndSave method

        Test.stopTest();
    }

    @isTest
    static void testCancelGenerationMethod() {
        // Create test data
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        
        Opportunity testOpp = new Opportunity(
            StageName = 'Initial',
            Name = 'Test Opportunity',
            CloseDate = System.today(),
            AccountId = testAcc.Id
        );
        insert testOpp;

        // Create a product
        Product2 pro = new Product2(Name = 'Test Product', StockKeepingUnit='T1-000991');
        insert pro;

        // Define standard price for the product
        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pro.Id,
            UnitPrice = 100, // Standard price
            IsActive = true
        );
        insert standardPBE;

        // Create custom pricebook
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Price Book',
            IsActive = true
        );
        insert customPricebook;

        // Create custom price for the product in the custom pricebook
        PricebookEntry customPBE = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            UnitPrice = 120, // Custom price
            Product2Id = pro.Id,
            IsActive = true
        );
        insert customPBE;

        // Create Quote with custom pricebook
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            ContactId = testContact.Id,
            OpportunityId = testOpp.Id,
            ExpirationDate = Date.today().addDays(30),
            Pricebook2Id = customPricebook.Id, // Use custom pricebook
            Email ='test@gmail.com'
        );
        insert testQuote;

        // Create Quote Line Item referencing the custom price
        QuoteLineItem customQuoteline = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = customPBE.Id, // Use custom pricebook entry
            Quantity = 1,
            UnitPrice = 45
        );
        insert customQuoteline;

        Test.startTest();

        // Set up the PageReference
        PageReference pageRef = Page.QuotePDFGenerator;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testQuote.Id);

        // Instantiate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        SaveQuotePDF_controller controller = new SaveQuotePDF_controller(sc);

        // Call the method to be tested
        PageReference result = controller.cancelGeneration();

        Test.stopTest();
    }
}