@isTest
public class IND_MembershipRequestTest {
    
    @isTest
    public static void verifyIND_MembershipRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        IND_MembershipRequest.inputRequest objInputReq = new IND_MembershipRequest.inputRequest();
        objInputReq.MembershipType = System.label.Membership_mci;
        objInputReq.MembershipId = 'Test1';
        objInputReq.year_of_reg  = '1995';
        objInputReq.medical_council  = 'Test1';
        
        
        IND_MembershipRequest result = new IND_MembershipRequest(applicant, JSON.serialize(objInputReq), opgd1.Id );
        Boolean isValid = result.validate(System.Label.Membership);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        
    }
}