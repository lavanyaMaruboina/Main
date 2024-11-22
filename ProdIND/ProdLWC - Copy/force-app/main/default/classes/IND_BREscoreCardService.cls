/*------------------------------------------------------------
Author:        nagendra pindipolu
Company:       Persistent
Description:   This class is service class to IND_IBL BRE API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      nagendra pindipolu      Created
------------------------------------------------------------*/
public class IND_BREscoreCardService {
     public static IND_BREscoreCardRequest getBREscoreCardRequest(Applicant__c app,Documents__c doc,String loanAppId){
        try{
            IND_BREscoreCardRequest brescoreCardRequest = new IND_BREscoreCardRequest(app,doc,loanAppId);
            return brescoreCardRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_BREscoreCardRequest', 'getBREscoreCardRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    } 
}