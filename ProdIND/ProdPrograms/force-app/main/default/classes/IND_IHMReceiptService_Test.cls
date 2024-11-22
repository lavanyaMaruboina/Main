/*------------------------------------------------------------
Author:        Bharath Moka
Company:       Persistent Systems
Description:   Test class for IND_IHMReceipteRequest class 
Apex Class:    IND_IHMReceiptRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Bharath Moka      Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_IHMReceiptService_Test 
{
    @isTest
    public static void getIHMReceiptRequestTest(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive' Limit 1];
       User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test1_userprod123@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            insert opgd1;
            
             
            
            RequestWrapper reqWrapper = new RequestWrapper();
            reqWrapper.applicantId = opgd1.Id;
            
            List<Applicant__c> appList = new List<Applicant__c>();
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opgd1.Id;
            appList.add(applicant);
            insert appList;

            Test.StartTest();
            try{
               
                IND_IHMReceiptService.getIHMReceiptRequest(appList[0],opgd1.id,null);
                 System.assert(false, 'Expected IND_Exception to be thrown');
                    
            }catch(Exception e)
            {                
                System.assert(e.getMessage().contains('Please enter the Deal Number'));
            }
          Test.StopTest();
        }    
    }
    
  
}