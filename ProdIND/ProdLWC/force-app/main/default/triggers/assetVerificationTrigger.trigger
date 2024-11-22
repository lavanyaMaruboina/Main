/**
* @Name         assetVerificationTrigger
* @Author       Aakash J
* @Company      Salesforce
* @Description  Trigger for Asset Verification Records 
* Inputs:       None
* Test Class:   
* History:
*/
trigger assetVerificationTrigger on Asset_Verification__c (after insert, after update, before update, after delete, after undelete) {
    
    List<Id> assetVerificationIds = new List<Id>();
    Set<Id> caseIds = new Set<Id>();
    List<Asset_Verification__c> assVerCompleted = new List<Asset_Verification__c>();

    if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isUndelete)) {
        for (Asset_Verification__c avRec : Trigger.new) {
            assetVerificationIds.add(avRec.Case__c);
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate){ //SFTRAC-99
        for(Asset_Verification__c avRec:Trigger.new){
            if(avRec.status__c != Trigger.oldmap.get(avRec.id).status__c && avRec.status__c == 'Completed'){
                            assVerCompleted.add(avRec);
                            caseIds.add(avRec.Case__c);
                             }
            }
            
    }

    if (Trigger.isDelete) {
        for (Asset_Verification__c avRec : Trigger.old) {
            assetVerificationIds.add(avRec.Case__c);
        }
    }

    assetVerificationTriggerHandler.updateCaseStatus(assetVerificationIds);
    if(!assVerCompleted.isEmpty()){ //SFTRAC-99
    assetVerificationTriggerHandler.updateIsPSVerifiedAsset(assVerCompleted,caseIds); }

}