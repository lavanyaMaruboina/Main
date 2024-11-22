/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the IND_ScanUploadReportGenerationRequest
Test Class: IND_ScanUploadReportGenerationService_Test
History 
Date            Author              Comments
------------------------------------------------------------- 
04-01-2021    Satyam More           Created
------------------------------------------------------------*/

public class IND_ITRSUCompleteTransactionRequest extends ParentAPIRequest {
    
    //constructor
    // @Method:      IND_ITRSUCompleteTransactionRequest
    // @Created by:  Satyam More
    // @Description: Contructor
    // Param:		''
    // @Return:     ''  
    
    public IND_ITRSUCompleteTransactionRequest(){
        
        validate(System.Label.ITRScanUploadCompleteTransaction);
    }
    
//Method to get the HTTP request header data
    Public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = new Map<String,String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('IBL-Client-Id', System.Label.IBM_Client_ID);
        requestHeaderMap.put('IBL-Client-Secret', System.Label.IBM_Client_Secret);
        return requestHeaderMap;
    }

     //Method to validate the request data
    public override boolean validate(String serviceName){
        return true;
    }
}