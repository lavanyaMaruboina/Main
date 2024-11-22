@isTest
public class IND_SelfieReportRequestTest {
    
    @isTest
    public static void verifyIND_SelfieReportRequest(){
        
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
        applicant.DocAuth_Application_Id__c = '26936577';
        insert applicant; 
        applicant.Opportunity__r = opgd1;  
        
        IND_SelfieReportRequest result = new IND_SelfieReportRequest(applicant.Id);
        Boolean isValid = result.validate(System.Label.Selfie_Report);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            result = new IND_SelfieReportRequest(null);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        System.assert(String.isNotBlank(errorMessage));
        
    }
    
    
}