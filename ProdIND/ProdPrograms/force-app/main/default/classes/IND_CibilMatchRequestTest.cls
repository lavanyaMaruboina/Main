@isTest
public class IND_CibilMatchRequestTest {

    @isTest
    public static void verifyIND_CibilMatchRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        IND_CibilMatchRequest result = new IND_CibilMatchRequest(applicant);
        Boolean isValid = result.validate(System.Label.DocumentReport);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        String error = '';
        try{
            result = new IND_CibilMatchRequest(null);
        }catch(Exception pEx){
            error = pEx.getMessage();
            System.debug('error ==>'+error);
        }
        System.assert(error.contains('Script-thrown exception')) ;       
    }
    
    
}