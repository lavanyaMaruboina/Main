@isTest
public class IND_ScanUploadInitiateRequestTest {

    
    
    @isTest
    public static void verifyIND_ScanUploadInitiateRequest(){
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.loanAmount = '1500000';
        reqWrapper.tenure = '5';
        reqWrapper.yearMonthFrom = '05-05';
        reqWrapper.yearMonthTo = '05-05';
        reqWrapper.employmentType = 'PERM';
        reqWrapper.employerName = 'John';
        
        
        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);
        Boolean isValid = result.validate(System.Label.ScanUploadInitiate);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    } 
    
        @isTest
    public static void verifyIND_ScanUploadInitiateRequest2(){
        try{     
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.tenure = '5';
        reqWrapper.yearMonthFrom = '05-05';
        reqWrapper.yearMonthTo = '05-05';
        reqWrapper.employmentType = 'PERM';
        reqWrapper.employerName = 'John';
        
        
        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Amountmessage);
        }
    } 
    
     @isTest
    public static void verifyIND_ScanUploadInitiateRequest3(){
        try{     
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.loanAmount = '1500000';
        reqWrapper.yearMonthFrom = '05-05';
        reqWrapper.yearMonthTo = '05-05';
        reqWrapper.employmentType = 'PERM';
        reqWrapper.employerName = 'John';
        
        
        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.LoanDuration_Error);
        }
    } 
    
       @isTest
    public static void verifyIND_ScanUploadInitiateRequest4(){
        try{     
      
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.loanAmount = '1500000';
        reqWrapper.tenure = '5';
        reqWrapper.yearMonthTo = '05-05';
        reqWrapper.employmentType = 'PERM';
        reqWrapper.employerName = 'John';
        
        
        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.YearMonthFrom);
        }
    } 
    
       @isTest
    public static void verifyIND_ScanUploadInitiateRequest5(){
        try{     
      
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.loanAmount = '1500000';
        reqWrapper.tenure = '5';
        reqWrapper.yearMonthFrom = '05-05';
        reqWrapper.employmentType = 'PERM';
        reqWrapper.employerName = 'John';
        
        
        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.YearMonthTo);
        }
    } 
    
       @isTest
    public static void verifyIND_ScanUploadInitiateRequest6(){
        try{     
      
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.loanAmount = '1500000';
        reqWrapper.tenure = '5';
        reqWrapper.yearMonthFrom = '05-05';
        reqWrapper.yearMonthTo = '05-05';
        reqWrapper.employerName = 'John';
        
        
        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.EmploymentType);
        }
    } 
    
     @isTest
    public static void verifyIND_ScanUploadInitiateRequest8(){
        try{     
      
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.loanAmount = '1500000';
        reqWrapper.tenure = '5';
        reqWrapper.yearMonthFrom = '05-05';
        reqWrapper.yearMonthTo = '05-05';
        reqWrapper.employmentType = 'PERM';

        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.EmployerName);
        }
    } 
    
     @isTest
    public static void verifyIND_ScanUploadInitiateRequest9(){
        try{     
      
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.loanAmount = '1500000';
        reqWrapper.tenure = '5';
        reqWrapper.yearMonthFrom = '05-05';
        reqWrapper.yearMonthTo = '05-05';
        reqWrapper.employmentType = 'PERM';
        reqWrapper.employerName = 'John';

        IND_ScanUploadInitiateRequest result = new IND_ScanUploadInitiateRequest(reqWrapper);

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.LeadId);
        }
    } 
}