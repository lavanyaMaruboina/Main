@isTest
public class PostSanctionControllerTest 
{
	@testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank1.com',MobilePhone = '9089078967');
        insert u;
        List<TeleVerification__c> lstTVR =new  list<TeleVerification__c>();
        System.runAs(u) 
        {
            // Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.StageName = 'Post Sanction Checks and Documentation';
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp;         

            //Create Loan Application Transaction History
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Name = 'Invoice', 
                                                                                                             Screen__c = 'Invoice',
                                                                                                             Module__c = 'Post Sanction Checks and Documentation',
                                                                                                             Submitted_Flag__c = true,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            
                               
                              
            
        }             
    }
    
    @isTest
    public static void getLoanTransactionsTest()
    {               
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];          
            Map<String, Boolean> result = PostSanctionController.getLoanTransactions(opp.Id, 'Post Sanction Checks and Documentation', 'Dealer');
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
      @isTest
    public static void getLoanTransactionsTest1()
    {               
        Test.startTest();
      
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Map<String, Boolean> result = PostSanctionController.getLoanTransactions(opp.Id, 'Pre Disbursement Check', 'Dealer');
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getCurrentSubStageTest()
    {               
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];          
            String result1 = PostSanctionController.getCurrentSubStage(opp.Id);
            System.assertNotEquals(null,result1);
            String result2 = PostSanctionController.getCurrentSubStage(null);
            System.assertEquals(null,result2);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getLeadProductTypeTest()
    {               
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];          
            Opportunity result1 = PostSanctionController.getLeadProductType(opp.Id);
            System.assertNotEquals(null,result1);
            Opportunity result2 = PostSanctionController.getLeadProductType(null);
            System.assertEquals(null,result2);
        }
        Test.stopTest();                     
    }
}