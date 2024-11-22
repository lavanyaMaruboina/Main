/**
* @Name         assetVerificationTriggerHandler
* @Author       Aakash J
* @Company      Salesforce
* @Description  This class will be called from assetVerificationTrigger when Tractor Asset Verification record is been updated 
* Inputs:       None
* Test Class:   
* History:
*/
public class assetVerificationTriggerHandler {
    
    public static void updateCaseStatus(List<Id> assetVerificationIds) {
        List<Case> casesToUpdate = new List<Case>();
        
        for (Id accountId : assetVerificationIds) {
            Case casRec = [SELECT Id, (SELECT Id, Status__c  FROM Asset_Verifications__r WHERE Status__c != 'Completed') FROM Case Where Id = :assetVerificationIds LIMIT 1];
            
            if (casRec.Asset_Verifications__r.isEmpty()) {
                casRec.Status  = 'Completed';
                casesToUpdate.add(casRec);
            } else {
                casRec.Status  = 'In Progress';
                casesToUpdate.add(casRec);
            }
        }
        
        if(!casesToUpdate.isEmpty()){
        	update casesToUpdate;    
        }
        
    }
/*
* @Method:      updateIsPSVerifiedAsset
* @Created by:  Santhosh Guhan 
* @User Story: SFTRAC -99
* @Description: Method to update the IS PS Verified Asset Flag in Asset Verification object
* @Param:       List<Asset_Verification__c> assVer, Set<Id> caseIds
* @Return:     Void
*/ 
    public static void updateIsPSVerifiedAsset(List<Asset_Verification__c> assVer, Set<Id> caseIds){
        Map<id,case> caseMap = new Map<id,case>([Select Id, Loan_Application__r.StageName from Case where Id IN:caseIds and Loan_Application__r.Sanction_Date__c != NULL]);
        for(Asset_Verification__c avRec:assVer){
            if(!caseMap.isempty() && caseMap.containskey(avRec.Case__c)){
                avRec.Is_Post_Sanction_Verified_Asset__c = true;
            }
            } 
    }
}