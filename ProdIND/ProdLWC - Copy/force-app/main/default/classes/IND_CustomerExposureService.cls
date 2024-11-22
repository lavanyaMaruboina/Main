/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to Customer Exposure API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_CustomerExposureService {
   /* @Method:    getCustomerExposureRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for Deal Master API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_CustomerExposureRequest type reponse */
    public static IND_CustomerExposureRequest getCustomerExposureRequest(List<String> lstCustCodes,String loanAppId){
        try{
            IND_CustomerExposureRequest customerExposureRequest = new IND_CustomerExposureRequest(lstCustCodes,loanAppId);//only validation and setting headers
            return customerExposureRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CustomerExposureRequest', 'getCustomerExposureRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}