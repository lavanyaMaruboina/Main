/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is service class for the MFC Valuation API 
Test Class:    IND_MFCValuationService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
20-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
   /*
* @Method:      getMFCValuationRequestCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Document Upload API
* @Param:       Object - Opportunity
* @Return:      Object - IND_MFCValuationRequest type reponse
*/
public class IND_MFCValuationService {
 public static IND_MFCValuationRequest getMFCValuationRequestCallout(RequestWrapper requestWrapper){
        try
        {
            IND_MFCValuationRequest request = new IND_MFCValuationRequest(requestWrapper);            
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_MFCValuationService', 'getMFCValuationRequestCallout', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());          
        }  
    }
}