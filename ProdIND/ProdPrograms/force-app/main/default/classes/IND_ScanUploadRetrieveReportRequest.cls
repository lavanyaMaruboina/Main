/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the IND_ScanUploadRetrieveReport API
Test Class: IND_ScanUploadRetrieveReportService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
11-02-2021    Aman Mundhada           Created
------------------------------------------------------------*/
public class IND_ScanUploadRetrieveReportRequest extends ParentAPIRequest{

        //constructor
    // @Method:      IND_ScanUploadRetrieveReportRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor
    // Param:		''
    // @Return:     ''  
    
    public IND_ScanUploadRetrieveReportRequest(){
        
        validate(System.Label.ScanUploadRetrieveReport);
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