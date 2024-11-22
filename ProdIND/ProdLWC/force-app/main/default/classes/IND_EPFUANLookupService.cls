/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is service class for the EPF UAN Lookup API 
Test Class:    IND_EPFUANLookupService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
21-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_EPFUANLookupService {
/*
    * @Method:      getEPFUANLookupCallOutRequest
    * @Created by:  Divya
    * @Description: This method will returns valid requestEPFO Auth API
    * @Param:       Object - Applicant Object 
    * @Return:      Object - IND_EPFUANLookupRequest type request
    */
    public static IND_EPFUANLookupRequest getEPFUANLookupCallOutRequest(Applicant__c app,String loanAppId){
        try{
            IND_EPFUANLookupRequest request = new IND_EPFUANLookupRequest(app,loanAppId);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_EPFUANLookupService', 'getEPFUANLookupCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}