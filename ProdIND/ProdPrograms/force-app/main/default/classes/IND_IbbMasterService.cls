/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for the IBB Master
Test Class: IND_IbbMasterServiceTest
History
Date            Author              Comments
------------------------------------------------------------- 
16-12-2021    Aman Mundhada           Created
------------------------------------------------------------*/
public class IND_IbbMasterService {
    /*
* @Method:      getIbbMasterCallOutRequest
* @Created by:  Aman Mundhada 
* @Description: Method to return Request for IBB Master
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_IbbMasterRequest 
*/
    public static IND_IbbMasterRequest getIbbMasterCallOutRequest(RequestWrapper requestWrapper){
        try
        {    
            IND_IbbMasterRequest iBBMasterRequest = new IND_IbbMasterRequest(requestWrapper);
            return iBBMasterRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_IbbMasterService', 'getIbbMasterCallOutRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
}