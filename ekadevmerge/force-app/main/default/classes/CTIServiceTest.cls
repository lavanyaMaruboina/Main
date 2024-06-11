@isTest
public class CTIServiceTest {
  
    @testSetup
    static void testContactSetup(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Field Sales Team' LIMIT 1]; 	
        
        User usr = new User(LastName = 'User1',
                            FirstName='Testing',
                            Alias = 'tuser',
                            Email = 'testing.user1@abc.com',
                            Username = 'testing.user1@abc.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;

        system.runAs(usr){
            Account testAccount=new Account(name='Eka Account');
            insert testAccount;

            Contact c = new Contact();
            c.AccountId = testAccount.ID;
            c.FirstName = 'ContactFName';
            c.LastName = 'ContactLName';
            c.Phone = '9988776655';
            c.email = 'testContact@test.com';
            insert c;

            Opportunity o = new Opportunity();
            o.Phone__c = '9988776655';
            o.Name = 'OppName';
            o.AccountId = testAccount.ID;
            o.StageName = 'Prospecting';
            o.CloseDate = system.Today()+3;
            insert o;
        }

    }

    @isTest
    public static void testHandleCTICall200(){
        User u = [select id from user where name = 'Testing User1'];
        Test.startTest();
        system.runAs(u){
           Opportunity opp = [Select Id, Phone__c, Name from Opportunity where Name = 'OppName'];
           Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'success')); 
           CTIResponsetWrpper res = CTIServiceConsumer.handleCTICall(opp.Id);
           System.debug('Response from test '+res);
           System.assertEquals(res.phoneNumber, '123456789');
           System.assertEquals(res.isSaved, 'Y');
        }
        Test.stopTest();

    }
    @isTest
    public static void testConnectCTIDialer200Error(){
        User u = [select id from user where name = 'Testing User1'];
        Test.startTest();
        system.runAs(u){
           Opportunity opp = [Select Id, Phone__c, Name from Opportunity where Name = 'OppName'];
           Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, '')); 
           CTIResponsetWrpper res = CTIServiceConsumer.handleCTICall(opp.Id);
           System.debug('Response from test '+res);
           System.assertEquals(res.phoneNumber, null);
           System.assertEquals(res.isSaved, 'N');
        }
        Test.stopTest();

    }

    @isTest
    public static void testConnectCTIDialer400(){
        User u = [select id from user where name = 'Testing User1'];
        Test.startTest();
        system.runAs(u){
           Opportunity opp = [Select Id, Phone__c, Name from Opportunity where Name = 'OppName'];
           Test.setMock(HttpCalloutMock.class, new MockHttpResponse(400, '')); 
           CTIResponsetWrpper res = CTIServiceConsumer.handleCTICall(opp.Id);
           System.debug('Response from test '+res);
           System.assertEquals(res.message, 'Internal Server Error. Please contact Administrator.');
           System.assertEquals(res.isSaved, 'N');
        }
        Test.stopTest();

    }

    @isTest
    public static void testConnectCTIDialerException(){
        User u = [select id from user where name = 'Testing User1'];
        Test.startTest();
        system.runAs(u){
          Opportunity opp = [Select Id, Phone__c, Name from Opportunity where Name = 'OppName'];
           Test.setMock(HttpCalloutMock.class, new MockHttpResponse(400, '')); 
           CTIServiceConsumer.isTest=true;
           CTIResponsetWrpper res = CTIServiceConsumer.handleCTICall(opp.Id);
           System.debug('Response from test '+res);
           System.assertEquals(res.isSaved, 'N');
        }
        Test.stopTest();

    }
              
}