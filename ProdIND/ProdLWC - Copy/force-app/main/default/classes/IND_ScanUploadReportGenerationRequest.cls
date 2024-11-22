/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the IND_ScanUploadReportGenerationRequest
Test Class: IND_ScanUploadReportGenerationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2021    Aman Mundhada           Created
------------------------------------------------------------*/
public class IND_ScanUploadReportGenerationRequest extends ParentAPIRequest {
    
    //constructor
    // @Method:      IND_ScanUploadReportGenerationRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor
    // Param:		''
    // @Return:     ''   
    
    public IND_ScanUploadReportGenerationRequest(){
        
        validate(System.Label.ScanUploadReportGeneration);
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
        return true;
    }
}