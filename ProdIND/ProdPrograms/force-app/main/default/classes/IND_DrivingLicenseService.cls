/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for the Driving License API
Test Class: IND_DrivingLicenseService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
10-11-2021    Aman Mundhada            Created
------------------------------------------------------------*/

public class IND_DrivingLicenseService {
    
/*
* @Method:      getDlCallOutRequest
* @Created by:  Aman Mundhada
* @Description: Method to return Request for Driving License API
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_DrivingLicenseRequest 
*/
     public static IND_DrivingLicenseRequest getDlCallOutRequest(RequestWrapper requestWrapper){
        try
        {    
            IND_DrivingLicenseRequest dlRequest = new IND_DrivingLicenseRequest(requestWrapper);
            return dlRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DrivingLicenseService', 'getDlCallOutRequest', System.Label.Apex, ex, requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
    
    
}