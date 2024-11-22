@isTest
public class Ind_CSRVahanFIwaiverRequestTest {
    
    
    @isTest
    public static void verifyIND_CSRVahanFIwaiverRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Ind_CSRVahanFIwaiverRequest result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            applicant.Opportunity__r.Vehicle_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.VehicleType));
        
        try{
            applicant.Opportunity__r.Product_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.Product));
        
        
    }
    
    @isTest
    public static void verifyIND_CSRVahanFIwaiverRequest1(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Orange';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Ind_CSRVahanFIwaiverRequest result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            applicant.Opportunity__r.Vehicle_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.VehicleType));
        
        try{
            applicant.Opportunity__r.Product_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.Product));
        
        
    }
    
     @isTest
    public static void verifyIND_CSRVahanFIwaiverRequest2(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Yellow';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Ind_CSRVahanFIwaiverRequest result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            applicant.Opportunity__r.Vehicle_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.VehicleType));
        
        try{
            applicant.Opportunity__r.Product_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.Product));
        
        
    }
    
     @isTest
    public static void verifyIND_CSRVahanFIwaiverRequest3(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Light Green';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Ind_CSRVahanFIwaiverRequest result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            applicant.Opportunity__r.Vehicle_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.VehicleType));
        
        try{
            applicant.Opportunity__r.Product_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.Product));
        
        
    }
    
     @isTest
    public static void verifyIND_CSRVahanFIwaiverRequest4(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Dark Green';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Ind_CSRVahanFIwaiverRequest result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            applicant.Opportunity__r.Vehicle_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.VehicleType));
        
        try{
            applicant.Opportunity__r.Product_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.Product));
        
        
    }
    
     @isTest
    public static void verifyIND_CSRVahanFIwaiverRequest5(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Co-borrower';
        applicant.Scorecard_Decision__c = 'Dark Green';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Ind_CSRVahanFIwaiverRequest result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            applicant.Opportunity__r.Vehicle_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.VehicleType));
        
        try{
            applicant.Opportunity__r.Product_Type__c = null;
            result = new Ind_CSRVahanFIwaiverRequest(reqWrapper, appList);
            result.validate(System.Label.CSRVahanFIwaiver);
        }catch(Exception ex){
            errorMessage = ex.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.Product));
        
        
    }
    
    
}