/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the IND_ScanUploadInitiateRequest
Test Class: IND_ScanUploadInitiateService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
03-01-2021    Aman Mundhada           Created
------------------------------------------------------------*/


public class IND_ScanUploadInitiateRequest  extends ParentAPIRequest {
    //request paramaters for IND_ScanUploadInitiateRequest
    public Payload payload {get;set;}
    public class Payload{
        public final String Lead_Id {get;set;}
        public final String Maker_Id {get;set;}
        public final String loanAmount {get;set;}
        public final String loanDuration {get;set;}
        public final String loanType {get;set;}
        public final String processingType {get;set;}
        public final String acceptancePolicy {get;set;}
        public final String uploadingScannedStatements {get;set;}
        public final String yearMonthFrom {get;set;}
        public final String yearMonthTo {get;set;}
        public final String productType {get;set;}
        public final String employmentType {get;set;}
        public final String employerName {get;set;}
    }
    
    //constructor
    // @Method:      IND_ScanUploadInitiateRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor
    // Param:		 Object RequestWrapper
    // @Return:     ''
    public IND_ScanUploadInitiateRequest(RequestWrapper requestWrapper){
        this.payload = new Payload();
        payload.Lead_Id= requestWrapper.leadId==null?'':requestWrapper.leadId; 
        payload.Maker_Id=IntegrationUtilities.getMakerId();
        payload.loanAmount=requestWrapper.loanAmount==null?'':requestWrapper.loanAmount;
        payload.loanDuration=requestWrapper.tenure==null?'':requestWrapper.tenure;
        payload.loanType=System.label.VehicleLoanType;
        payload.processingType= 'STATEMENT'; 
        payload.acceptancePolicy= 'atLeastOneTransactionInRange';
        payload.uploadingScannedStatements= 'true';
        payload.yearMonthFrom= requestWrapper.yearMonthFrom==null?'':requestWrapper.yearMonthFrom; 
        payload.yearMonthTo=  requestWrapper.yearMonthTo==null?'':requestWrapper.yearMonthTo;
        payload.employmentType= requestWrapper.employmentType==null?'':requestWrapper.employmentType;
        payload.productType= 'CV';
        payload.employerName=requestWrapper.employerName==null?'':requestWrapper.employerName;
        
        validate(System.Label.ScanUploadInitiate);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Aman Mundhada
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.  
    Public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      validate
    // @Created by:  Aman Mundhada
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.  
    public override boolean validate(String serviceName){
        if(String.isBlank(this.payload.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        
        if(String.isBlank(this.payload.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        }    
        
        if(String.isBlank(this.payload.loanAmount)){
            throw new IND_Exception(System.Label.Amountmessage);
        }    
        if(String.isBlank(this.payload.loanDuration)){
            throw new IND_Exception(System.Label.LoanDuration_Error);
        }  
        
        if(String.isBlank(this.payload.loanType)){
            throw new IND_Exception(System.Label.LoanType);
        }  
        if(String.isBlank(this.payload.processingType)){
            throw new IND_Exception(System.Label.ProcessingType);
        }  
        
        if(String.isBlank(this.payload.acceptancePolicy)){
            throw new IND_Exception(System.Label.AcceptancePolicy);
        }  
        
        if(String.isBlank(this.payload.uploadingScannedStatements)){
            throw new IND_Exception(System.Label.UploadingScannedStatements);
        }  
        
        if(String.isBlank(this.payload.yearMonthFrom)){
            throw new IND_Exception(System.Label.YearMonthFrom);
        } 
        
        if(String.isBlank(this.payload.yearMonthTo)){
            throw new IND_Exception(System.Label.YearMonthTo);
        } 
        
        if(String.isBlank(this.payload.employmentType)){
            throw new IND_Exception(System.Label.EmploymentType);
        } 
        
        if(String.isBlank(this.payload.productType)){
            throw new IND_Exception(System.Label.ProductType);
        } 
        
        if(String.isBlank(this.payload.employerName)){
            throw new IND_Exception(System.Label.EmployerName);
        } 
        return true;
    }
    
}