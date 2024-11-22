/* 
 @File Name : PostSanctionController.cls 
 @Description :  Controller class for iND_LWC_PSChecksAndDoc
 @Author : Yogesh Rao 
 @Last Modified By : Yogesh Rao 
 @Last Modified On : 16 May 2022 
 @Modification Log : 
 ============================================================================== 
 Ver        Date          Author       Modification 
 ============================================================================== 
 1.0     16 May 2022    Yogesh Rao   Initial Version 
   */
public with sharing class PostSanctionController {
  /* 
     @description :   Method to get completed loan transaction history records
     @param :  String loanApplicationId
     @return : Map<String, Boolean>
    */
  @AuraEnabled
  public static Map<String, Boolean> getLoanTransactions(String loanApplicationId,String module, String dealId) {
    Map<String, Boolean> mapOfScreenVsStatus = new Map<String, Boolean>();
    //CISP-57 OR INDI-4606 - START
    if(module == 'Pre Disbursement Check'){
      mapOfScreenVsStatus.put('CAM and Conditional Approval',false);
    }else if(module == 'Post Sanction Checks and Documentation'){
      mapOfScreenVsStatus.put('Structured EMI',false);
    }
    mapOfScreenVsStatus.put('Vehicle Inspection and RC Check',false);
    mapOfScreenVsStatus.put('Security Mandate',false);
    mapOfScreenVsStatus.put('Additional Documents',false);
    mapOfScreenVsStatus.put('Invoice',false);
    mapOfScreenVsStatus.put('IHM',false);
    mapOfScreenVsStatus.put('Loan Agreement',false);
    mapOfScreenVsStatus.put('Repayment Mandate',false);
    mapOfScreenVsStatus.put('RTO, DPN, POA Documents Upload',false);
    // CISP-57 OR INDI-4606 - END
    try {
      for (Loan_Application_Transaction_History__c each : [SELECT Id, Screen__c, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :loanApplicationId AND Module__c = :module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]) {
        if (each.Screen__c != null) {
          mapOfScreenVsStatus.put(each.Screen__c, each.Submitted_Flag__c);
        }
      }
      return mapOfScreenVsStatus;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static string getCurrentSubStage(String loanApplicationId) {
    try {
      if(loanApplicationId!=null && String.isNotBlank(loanApplicationId)){
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = [SELECT StageName,Sub_Stage__c FROM Opportunity WHERE Id =:loanApplicationId LIMIT 1];
        return opportunityList[0].Sub_Stage__c;
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static Opportunity getLeadProductType(String loanApplicationId) {
    try {
      if(loanApplicationId!=null && String.isNotBlank(loanApplicationId)){
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = [SELECT StageName,Product_Type__c,Vehicle_Type__c, LeadSource FROM Opportunity WHERE Id =:loanApplicationId LIMIT 1];
        return opportunityList[0];
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}