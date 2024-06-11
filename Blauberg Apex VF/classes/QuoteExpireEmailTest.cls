@isTest
public class QuoteExpireEmailTest {
    @isTest
    static void testBatchExecution() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@example.com');
        insert testContact;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            AccountId = testAcc.Id);
        insert opp;
        Quote quotes = new Quote(
            Name = 'Test Quote ',
            ExpirationDate = System.today(), 
            Lead_time__c = 'In stock - Next Day', 
            Description = 'Test Description ',
            ContactId = testContact.Id,
            OpportunityId = opp.Id,
            
            Email = 'test34@gmail.com');
        insert quotes;

        Test.startTest();
        QuotationExpireDate1 batchInstance = new QuotationExpireDate1();
        Database.executeBatch(batchInstance);
        Test.stopTest();

    }
}