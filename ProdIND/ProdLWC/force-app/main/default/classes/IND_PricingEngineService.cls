/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to Pricing Engine API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_PricingEngineService {
   /* @Method:      getPricingEngineRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for CAM Portfolio API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_PricingEngineRequest */
	
    public static IND_PricingEngineRequest getPricingEngineRequest(Opportunity opp,String loanAppId,RequestWrapper requestWrapper){
        try{
            IND_PricingEngineRequest pricingEngineRequest = new IND_PricingEngineRequest(opp,loanAppId,requestWrapper);
            return pricingEngineRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PricingEngineRequest', 'getPricingEngineRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}