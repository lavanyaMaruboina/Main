/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems 
Description:   This class is service class for the Customer Name Search API 
Test Class:    IND_CustomerNameSearchService_Test 
History			
Date            Author              Comments
-------------------------------------------------------------
12-01-2022      Bhushan Charde      Created
14-03-2022		Santhosh Mothe		loan app tracking
------------------------------------------------------------*/
public class IND_CustomerNameSearchService {
    /*
* @Method:      getCustomerNameSearchRequest
* @Created by:  Bhushan Charde
* @Description: This method will returns valid request Customer Name Search API
* @Param:       Object - Applicant Object 
* @Return:      Object - IND_CustomerNameSearchService type request
*/
    public static IND_CustomerNameSearchRequest getCustomerNameSearchRequest(RequestWrapper requestWrapper, String loanAppId){
        try{
            IND_CustomerNameSearchRequest searchRequest = new IND_CustomerNameSearchRequest(requestWrapper, loanAppId);
            return searchRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CustomerNameSearchService', 'getCustomerNameSearchRequest', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    } 
}