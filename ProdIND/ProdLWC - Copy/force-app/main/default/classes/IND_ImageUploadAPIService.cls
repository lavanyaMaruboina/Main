/*------------------------------------------------------------
Author:        Divya Jawale
Company:        Persistent Systems
Description:   This class is service class for the Image Upload API 
Test Class:    IND_ImageUploadAPIService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
22-11-2021      Divya Jawale      Created
------------------------------------------------------------*/
   /*
* @Method:      getImageUploadAPIRequestRequest
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Document Upload API
* @Param:       String - Document and String - imageType
* @Return:      Object - IND_ImageUploadAPIRequest type request
*/
public class IND_ImageUploadAPIService {
   
    
     public static IND_ImageUploadAPIRequest getImageUploadAPIRequestRequest(String documentId,String imageType,String loanAppId){
        try
        {
            IND_ImageUploadAPIRequest request = new IND_ImageUploadAPIRequest(documentId, imageType, loanAppId);            
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ImageUploadAPIService', 'getImageUploadAPIRequestRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        }  
    }
}