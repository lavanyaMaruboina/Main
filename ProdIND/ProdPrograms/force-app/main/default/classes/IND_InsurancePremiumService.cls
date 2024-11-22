/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems 
Description:   This class is service class for the Insurace Premium API 
Test Class:    IND_InsurancePremiumService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
12-01-2022      Santhosh Mothe      Created
------------------------------------------------------------*/
public class IND_InsurancePremiumService {
    /*
* @Method:      getInsurancePremiumRequest
* @Created by:  Santhosh Mothe
* @Description: This method will returns valid request InsurancePremium API
* @Param:       Object - Applicant Object 
* @Return:      Object - IND_InsurancePremiumService type request
*/
     public static IND_InsurancePremiumRequest getInsurancePremiumRequest(Applicant__c app,String Ins_Product, String Plan_Code,String loanAppId){
        try{
            IND_InsurancePremiumRequest insurancePremiumRequest = new IND_InsurancePremiumRequest(app,Ins_Product,Plan_Code,loanAppId);
            return insurancePremiumRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_InsurancePremiumRequest', 'getInsurancePremiumRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }

    public static IND_InsurancePremiumRequest getInsurancePremiumRequest(Applicant__c app,String Ins_Product, String Plan_Code,String loanAppId, String assetId){
        try{
            IND_InsurancePremiumRequest insurancePremiumRequest = new IND_InsurancePremiumRequest(app,Ins_Product,Plan_Code,loanAppId,assetId);
            return insurancePremiumRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_InsurancePremiumRequest', 'getInsurancePremiumRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
}