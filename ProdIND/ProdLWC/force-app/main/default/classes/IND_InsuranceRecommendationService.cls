/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is service class for the Insurance Recommendation API 
Test Class:    IND_InsuranceRecommendationService_Test
History
Date            Author              Comments
-------------------------------------------------------------
18-01-2022      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_InsuranceRecommendationService {
   /*
    * @Method:      getInsuranceRecommendationCallout
    * @Created by:  Divya
    * @Description: This method will returns valid  Insurance Recommendation API
    * @Param:       wrapper - RequestWrapper
    * @Return:      Object - IND_InsuranceRecommendationRequest type request
    */
    public static IND_InsuranceRecommendationRequest getInsuranceRecommendationCallout(RequestWrapper requestwrapper){
        try{
            IND_InsuranceRecommendationRequest request = new IND_InsuranceRecommendationRequest(requestwrapper);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceRecommendationService', 'getInsuranceRecommendationCallout', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}