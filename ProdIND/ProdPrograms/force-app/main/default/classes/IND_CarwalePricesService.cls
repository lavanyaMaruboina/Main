/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the CarWale Prices response
Test Class: IND_CarwalePricesService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
21-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_CarwalePricesService {
    
/*
    * @Method:      getCarwalePricesCallOutRequest
    * @Created by:  Satyam More
    * @Description: This method will returns valid request Carwale Prices API
    * @Param:       Object - Applicant Object 
    * @Return:      Object - IND_CarwalePricesRequest type request
    */
    
public static IND_CarwalePricesRequest getCarwalePricesCallOutRequest(RequestWrapper requestWrapper, String loanAppId){
        try
        {
            IND_CarwalePricesRequest carwalePricesRequest = new IND_CarwalePricesRequest(requestWrapper,loanAppId);
            return carwalePricesRequest;
        }
        catch(Exception ex){
                        ErrorLoggerUtil.logErrorEvent('IND_CarwalePricesService', 'getCarwalePricesCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
}