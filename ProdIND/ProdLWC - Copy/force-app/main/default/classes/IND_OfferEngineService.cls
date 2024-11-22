/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Offer Engine API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
28-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_OfferEngineService {

    public static IND_OfferEngineRequest getOfferEngineCallOutRequest(RequestWrapper requestWrapper,List<Final_Term__c> finalTerm,String loadAppId){
        try
        {
             IND_OfferEngineRequest offerEngineRequest = new IND_OfferEngineRequest(requestWrapper, finalTerm);
             return offerEngineRequest;
        }
        catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_OfferEngineService', 'getOfferEngineCallOutRequest', System.Label.Apex, ex, loadAppId);
             throw new IND_Exception(ex.getMessage());           
     } 

    }
    
}