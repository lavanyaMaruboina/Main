/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_NeSLAgreementStatusRequest class 
Apex Class:    IND_NeSLAgreementStatusRequest
History
Date            Author              Comments
-------------------------------------------------------------
02-01-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest
public class IND_NeSLAgreementStatusService_Test {
    
    
    // @Method:		TestServiceMetthod
    // @Created by:	Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_NeSLAgreementStatusRequest classs
    // @Param:		''	
    // @Return: 	''  
    @isTest
    public static void testIND_NeSLAgreementStatusService(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                              TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com');
            insert u;
            System.runAs(u) 
            {
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                opgd1.Vehicle_Type__c = 'New';
                opgd1.Parent_Deal_number__c = 'DL109939';
                opgd1.Lead_number__c = 'L109939';
                opgd1.Deal_Number__c = 'L109939';
                insert opgd1;
                
                RequestWrapper reqWrapper = new RequestWrapper();
                reqWrapper.applicantId = opgd1.Id;
                
                List<Applicant__c> appList = new List<Applicant__c>();
                
                Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
                applicant.Opportunity__c=opgd1.Id;
                applicant.Applicant_Type__c  = null;
                applicant.Scorecard_Decision__c = 'Red';
                appList.add(applicant);
                insert appList;
                applicant.Opportunity__r = opgd1;  
                Test.StartTest();
                IND_NeSLAgreementStatusService.getNeSLAgreementStatusRequest(appList[0],opgd1.id);
                Test.StopTest();
            }
            
        } catch(Exception ex){
            System.debug('Ex--'+ex.getMessage());
        }
        
    }
    
}