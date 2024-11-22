@isTest
public class IND_ITRScanUploadInitiateRequestTest {

    @isTest
    public static void verifyIND_ITRScanUploadInitiateRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Lead_Number__c = 'L-10122021-9999';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
       
        IND_ITRScanUploadInitiateRequest result = new IND_ITRScanUploadInitiateRequest( applicant,opgd1.Id,'ACHPM5784F');
        Boolean isValid = result.validate(System.Label.ITRScanUploadInitiate);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
    }
    
     @isTest
    public static void verifyIND_ITRScanUploadInitiateRequest2(){
        try{ 
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
        
       
        IND_ITRScanUploadInitiateRequest result = new IND_ITRScanUploadInitiateRequest( applicant,opgd1.Id,'ACHPM5784F');
        Boolean isValid = result.validate(System.Label.ITRScanUploadInitiate);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
         } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.LeadId);
        }
        
    }
    
      @isTest
    public static void verifyIND_ITRScanUploadInitiateRequest3(){
        try{ 
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Lead_Number__c = 'L-10122021-9999';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
       
        IND_ITRScanUploadInitiateRequest result = new IND_ITRScanUploadInitiateRequest( applicant,opgd1.Id,'');
        Boolean isValid = result.validate(System.Label.ITRScanUploadInitiate);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
         } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.PAN_Number);
        }
        
    }

}