@isTest
public class IND_ENACHRegistrationStatusRequestTest {
    @isTest
    public static void testOne(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
        
            RequestWrapper reqWrapper = new RequestWrapper();
            reqWrapper.customerCode = 'CU00011';
            reqWrapper.dealNumber = 'L0001';
            reqWrapper.enachStatus = 'test';
           
           Test.startTest();
             IND_ENACHRegistrationStatusRequest sr1 = new IND_ENACHRegistrationStatusRequest(reqWrapper);
             Map<String,String> rMap1 = sr1.getHttpRequestHeaders();
           Test.stopTest();
    }
}