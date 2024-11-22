/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   Trigger for MIS_RC_Limit_Dt__c
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
19-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
trigger DSA_RC_Limit_Dt on MIS_RC_Limit_Dt__c (before insert, after insert, before update, after update) {
    if(Trigger.isInsert && Trigger.isAfter){
        DSA_RC_Limit_Dt_Handler.AfterInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        DSA_RC_Limit_Dt_Handler.AfterUpdate(Trigger.newmap, Trigger.oldmap);
    }
}