@isTest
public class ForwardToMailTest {
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='testUser1@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            //Create Account
            Account au1 = new Account();
            au1.Name = 'test';
            insert au1;
            
            // Create Opportunity
            Opportunity opgr1 = new Opportunity();
            opgr1.AccountId = au1.Id;
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;               
            
            // Create Applicant__c
            Applicant__c apgr1 = new Applicant__c();
            apgr1.Opportunity__c = opgr1.Id;
            apgr1.Contact_number__c = '9743514830';
            apgr1.Applicant_Type__c = 'Borrower';
            insert apgr1;
            
            //Create Cam
            CAM__c cam1 = new CAM__c();
            cam1.Active__c = true;
            cam1.Loan_Application__c = opgr1.Id;
            insert cam1;                        
            
            //Create Account Team Member
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = opgr1.AccountId;
            atm1.TeamMemberRole = 'FI';
            atm1.UserId = u.Id;
            insert atm1;
            
            //Create Deviation
            Deviation__c d1 = new Deviation__c();
            d1.Parent_CAM__c = cam1.Id;
            d1.Role__c = atm1.TeamMemberRole;
            insert d1;
        }
    }
    
    @isTest
    public static void emailCallOutTest()
    {        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='testUser1@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            CAM__c cam = [SELECT Id FROM CAM__c];
            String result = ForwardToMail.emailCallOut(cam.Id,'FI');
            System.assertEquals('Success', result);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void emailDeviationCalloutTest(){                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='testUser1@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            CAM__c cam = [SELECT Id FROM CAM__c];
            ForwardToMail.emailDeviationCallout(cam.Id);
                        
            Integer invocations = Limits.getEmailInvocations();
            system.assertEquals(0, invocations);
        }        
        Test.stopTest();
    }
}