/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Vahan Vehicle Valuation API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
20-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_VahanVehicleValuationService {
/*
* @Method:      getVahanVehicleValuationCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process the Vahan Vehicle Valuation API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_VahanVehicleValuationRequest type request
*/
    
   public static IND_VahanVehicleValuationRequest getVahanVehicleValuationCallOutRequest(RequestWrapper requestWrapper, String loanAppId){
        try
        {
            IND_VahanVehicleValuationRequest vahanVehicleValuationRequest = new IND_VahanVehicleValuationRequest(requestWrapper,loanAppId);
            return vahanVehicleValuationRequest;
        }
        catch(Exception ex){
                        ErrorLoggerUtil.logErrorEvent('IND_VahanVehicleValuationService', 'getVahanVehicleValuationCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
    
}