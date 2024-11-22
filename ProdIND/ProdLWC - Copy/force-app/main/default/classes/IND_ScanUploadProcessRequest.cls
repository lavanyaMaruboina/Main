/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the IND_ScanUploadProcessRequest
Test Class: IND_ScanUploadProcessService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2021    Aman Mundhada           Created
------------------------------------------------------------*/
public class IND_ScanUploadProcessRequest extends ParentAPIRequest {
    //request paramaters for IND_ScanUploadProcessRequest
    public Payload payload;
    public class Payload{
        public String fileId;
        public String institutionId;
        public String password;
    }   
    
    //constructor
    // @Method:      IND_ScanUploadProcessRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor
    // Param:		 Object RequestWrapper
    // @Return:     ''
    public IND_ScanUploadProcessRequest(RequestWrapper requestWrapper){
        this.payload = new Payload();
        payload.fileId=requestWrapper.fileId==null?'':requestWrapper.fileId;
        payload.institutionId=requestWrapper.institutionId==null?'':requestWrapper.institutionId;
        payload.password= requestWrapper.password==null?'':requestWrapper.password;
        
        validate(System.Label.ScanUploadProcess);
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
        if(String.isBlank(this.payload.fileId)){
            throw new IND_Exception(System.Label.FileId);
        }
        
        if(String.isBlank(this.payload.institutionId)){
            throw new IND_Exception(System.Label.InstitutionId);
        }    
        return true;
    }
}