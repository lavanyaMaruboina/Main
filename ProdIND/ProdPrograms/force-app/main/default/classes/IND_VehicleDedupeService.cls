/*------------------------------------------------------------
Author: Sharad Kathane
Company: Persistent Systems
Description: This class is service class for the Vehicle Dedupe API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
27-10-2021    Sharad Kathane            Created
------------------------------------------------------------*/

public class IND_VehicleDedupeService {
    
    /*
* @Method:      getVehicleDedupeCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process the Vehicle Dedupe API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_VehicleDedupeRequest type request
*/
    
    public static IND_VehicleDedupeRequest getVehicleDedupeCallOutRequest(RequestWrapper requestWrapper){
        try
        {
            IND_VehicleDedupeRequest vehiclededupeRequest = new IND_VehicleDedupeRequest(requestWrapper);
            return vehiclededupeRequest;
        }
        catch(Exception ex){
                        ErrorLoggerUtil.logErrorEvent('IND_VehicleDedupeService', 'getVehicleDedupeCallOutRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
}