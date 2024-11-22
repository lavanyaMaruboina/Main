@isTest
public class IND_EPFUANLookupRequestTest {
    
    @isTest
    
    public static void verifyIND_EPFUANLookupRequest(){
        
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Lead_number__c = '123';
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Borrower';
        applicant.Scorecard_Decision__c = 'Red';
        applicant.Contact_number__c = '9898989898';
        applicant.Gender__c = 'MALE';
        applicant.Marital_status__c = 'SINGp';
        applicant.Residence_country__c = 'India';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        IND_EPFUANLookupRequest objResult = new IND_EPFUANLookupRequest(applicant, opgd1.Id);
        Boolean result = objResult.validate();
        System.assert(result == true);
        Map<String,String> resultHeadersMap = objResult.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        
        
        
    }
    
}