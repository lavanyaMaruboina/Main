/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is handler class for MIS_RC_Limit_Dt__c
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
19-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
public class DSA_RC_Limit_Dt_Handler {

    public static void AfterInsert(List<MIS_RC_Limit_Dt__c> newlst){ 
       // DSA_RC_Limit_Dt_Helper.shareLeadToDSA(newlst);  
        DSA_RC_Limit_Dt_Helper.updateDisbursedfield(newlst);
        
    }
    public static void AfterUpdate(Map<Id,MIS_RC_Limit_Dt__c> newMap, Map<Id,MIS_RC_Limit_Dt__c> oldMap){
       DSA_RC_Limit_Dt_Helper.updateDisbursedfield(newMap, oldMap); 
    }
    
}