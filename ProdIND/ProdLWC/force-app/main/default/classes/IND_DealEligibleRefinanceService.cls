/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is service class for the Deal Eligible Refinance API 
Test Class:    IND_DealEligibleRefinanceService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
22-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_DealEligibleRefinanceService {
/*
    * @Method:      getDealEligibleRefinance
    * @Created by:  Divya Jawale
    * @Description: This method will returns valid requestEPFO Auth API
    * @Param:       Object - Opportunity
    * @Return:      IND_DealEligibleRefinanceRequest type request
    */
    public static IND_DealEligibleRefinanceRequest getDealEligibleRefinance(Opportunity opp, String dealNumber){
        try{
            IND_DealEligibleRefinanceRequest request = new IND_DealEligibleRefinanceRequest(opp,dealNumber);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DealEligibleRefinanceService', 'getDealEligibleRefinance', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}