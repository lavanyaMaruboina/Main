/* 
 @File Name : ENACHController.cls 
 @Description :  Controller class for ENACH
 @Author : Yogesh Rao 
 @Last Modified By : Yogesh Rao 
 @Last Modified On : 28 April 2022 
 @Modification Log : 
 ============================================================================== 
 Ver        Date          Author       Modification 
 ============================================================================== 
 1.0     28 April 2022    Yogesh Rao   Initial Version 
*/
public with sharing class ENACHController {
    /* 
     @description :   Method to check if retry count is exhausted
     @param :  String loanApplicationId
     @param :  String serviceName
     @return : Boolean
    */
    @AuraEnabled
    public static Boolean checkRetryExhausted(String loanApplicationId, String serviceName, String dealId) {
      try {
        if (loanApplicationId != null) {
          //CISP-4181 Added filter of User_Id__c field for fetching Retry_Count__c record
          List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :serviceName AND User_Id__c =: UserInfo.getUserId() AND Vehicle_Detail__r.Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
          if (!retryCountList.isEmpty()) {
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(serviceName);
            if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
              return true;
            }
          }
        }
        return false;
      } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('ENACHController', System.Label.CheckRetryExhausted, System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
      }
    }
    /* 
    @description :   Method to increase retry count
    @param :  String loanApplicationId
    @param :  String serviceName
    @return : Boolean 
   */
    @AuraEnabled
    public static Boolean retryCountIncrease(String loanApplicationId, String serviceName, String dealId) {
      try {
        if (loanApplicationId != null) {
          //CISP-4181 Added filter of User_Id__c field for fetching Retry_Count__c record
          List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :serviceName AND User_Id__c =: UserInfo.getUserId() AND Vehicle_Detail__r.Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
          if (!retryCountList.isEmpty()) {
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(serviceName);
            Decimal count =  retryCountList[0].Count__c == null ? 0 : retryCountList[0].Count__c;
            if (count < metadata.Number_Of_Attempts__c) {
              retryCountList[0].Count__c += 1;
              if (Schema.sObjectType.Retry_Count__c.isUpdateable()) {
                update retryCountList;
              } else {
                throw new AuraHandledException(System.Label.Retrycountnotupdate);
              }
              if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                return true;
              }
            }
          } else {
            List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id from Vehicle_Detail__c Where Deal_Number__c =: dealId LIMIT 1]);
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Loan_Application_Id__c = loanApplicationId;
            retryCount.Service_Name__c = serviceName;
            retryCount.Vehicle_Detail__c = vehicleList.size() > 0 ?  vehicleList[0].Id : null;
            retryCount.User_Id__c = UserInfo.getUserId(); //CISP-4181 Populate User Id field while inserting retry count object
            retryCount.Count__c = 1;
            if (Schema.sObjectType.Retry_Count__c.isCreateable()) {
              insert retryCount;
            } else {
              throw new AuraHandledException(System.Label.Retrycountnotinserted);
            }
          }
        }
        return false;
      } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('ENACHController', 'retryCountIncrease', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
      }
    }
  
    /* 
     @description :   Method to handle ENACH and SI Platform Event
     @param :  List<Low_Payload_Response__e> newLowPayloadResponseList
     @return : Void
    */
    public static void eNachEventHandler(List<Low_Payload_Response__e> newLowPayloadResponseList) {
      Map<Id, Repayments__c> repaymentsToUpdate = new Map<Id, Repayments__c>();
      Map<String, Repayments__c> loanAppVsRepayment = getRepaymentId(newLowPayloadResponseList);
System.debug('Enach_debug_1'+ loanAppVsRepayment);
      Set<String> loanAppIds = new Set<String>();
      Set<Id> dealIds = new Set<Id>();
      Map<Id, Loan_Application_Transaction_History__c> transactionHistoryToUpdate = new Map<Id, Loan_Application_Transaction_History__c>();
      try {
        Boolean isStatusSuccess = true;
        for (Low_Payload_Response__e event : newLowPayloadResponseList) {
          String leadId = event.Reference_Id__c != null ? event.Reference_Id__c.split('-')[0] : '';
          if (event.SVC_Name__c == 'ENACH Registration Status' && loanAppVsRepayment.get(leadId)!=null && loanAppVsRepayment.get(leadId).Repayment_Method__c =='N') {
            Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(event.Response__c);
            String encryptedResp = (String) resp.get('JData');
            String decryptedResp = IntegrationUtilities.getDecryptedResponse(encryptedResp, System.Label.privateKey, System.Label.ivkey);
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(decryptedResp);
            System.debug('Enach_debug_2'+ response);
            String npciStatusObj = response.containsKey('npcistatus') ? (String)response.get('npcistatus') : null;
            String errorCodeCheck = response.containsKey('error_code') ? (String)response.get('error_code') : null;
             //CISP-15151 Only update the repayment record if the E_NACH_API_Status__c is not success
            if(loanAppVsRepayment.get(leadId).E_NACH_API_Status__c != 'ENACH Registration Success') {
             System.debug('Enach_debug_3'+ npciStatusObj);
            if (npciStatusObj == 'failed') {
             System.debug('Enach_debug_4'+ npciStatusObj);
              isStatusSuccess = false;
              repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, E_NACH_API_Status__c = 'ENACH Registration Failed', Message__c = (String) response.get('message')));
            } else if(errorCodeCheck == 'E0005'){
              isStatusSuccess = false;
              repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, E_NACH_API_Status__c = 'Customer Action On ENACH Pending', Message__c = (String) response.get('message')));    
            } else if(String.isBlank(npciStatusObj) && String.isBlank(errorCodeCheck) ) {
            System.debug('Enach_debug_5'+ npciStatusObj);
              isStatusSuccess = false;
              repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, E_NACH_API_Status__c = 'Response From NPCI Pending', Message__c = (String) response.get('message')));
            } 
            else {
             System.debug('Enach_debug_6'+ npciStatusObj);
              loanAppIds.add(leadId);//To update Loan Transaction History
              repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, E_NACH_API_Status__c = 'ENACH Registration Success', Message__c = (String) response.get('message')));
              dealIds.add(loanAppVsRepayment.get(leadId).Deal_Number__c);
            }
            }
            //CISP-15151 END
          } else if (event.SVC_Name__c == 'SIStatus' && loanAppVsRepayment.get(leadId)!=null && loanAppVsRepayment.get(leadId).Repayment_Method__c =='I') {
            Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(event.Response__c);
            String encryptedResp = (String) resp.get('JData');
            String decryptedResp = IntegrationUtilities.getDecryptedResponse(encryptedResp, System.Label.privateKey, System.Label.ivkey);
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(decryptedResp);
            Map<String, Object> respObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(response.get('response')));
            if ((String) respObj.get('status') == 'SUCCESS') {
              loanAppIds.add(leadId);//To update Loan Transaction History
              ENACHController.SIResponseWrapper siWrapper = (ENACHController.SIResponseWrapper) JSON.deserialize(decryptedResp, ENACHController.SIResponseWrapper.class);
              if(siWrapper?.response?.content[0].Status == 'Customer not initiated for the Standing Instruction' || siWrapper?.response?.content[0].Status == 'Customer registration for the Standing Instruction is pending'){
                isStatusSuccess = false;
                repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, SI_Status__c = 'In Progress', Message__c = 'Customer registration for the Standing Instruction is pending'));
              }else if(siWrapper?.response?.content[0].Status == 'Customer registration for the Standing Instruction got failed'){
                isStatusSuccess = false;
                repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, SI_Status__c = 'FAILED', Message__c = siWrapper?.response?.content[0].Status));
              }else if(siWrapper?.response?.content[0].Status == 'Customer registered for the Standing Instruction'){
                repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, SI_Status__c = 'SUCCESS', Message__c = siWrapper?.response?.content[0].Status));
                dealIds.add(loanAppVsRepayment.get(leadId).Deal_Number__c);
              }
            } else {
              isStatusSuccess = false;
              repaymentsToUpdate.put(loanAppVsRepayment.get(leadId).Id, new Repayments__c(Id = loanAppVsRepayment.get(leadId).Id, SI_Status__c = 'Response is awaited', Message__c = (String) respObj.get('respDesc')));
            }
          }
        }
        if (!repaymentsToUpdate.isEmpty()) {
          System.debug('Enach_debug_7'+ repaymentsToUpdate);
          update repaymentsToUpdate.values();
        }
        if(!loanAppIds.isEmpty() && isStatusSuccess){
          Set<Id> loanIds = new Set<Id>();
          for (Opportunity loan : [SELECT Id FROM Opportunity WHERE Id IN:loanAppIds WITH SECURITY_ENFORCED]) {
            loanIds.add(loan.Id);
          }
          if(dealIds.size() > 0){
            for (Loan_Application_Transaction_History__c each : [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c IN:loanIds AND Deal_Number__c IN : dealIds AND (Name =: System.Label.Repayment_Mandate OR Screen__c =: System.Label.Repayment_Mandate) AND Module__c =: System.Label.Post_Sanction_Checks_and_Documentation WITH SECURITY_ENFORCED]) {
              if (!each.Submitted_Flag__c) {
                transactionHistoryToUpdate.put(each.Id, new Loan_Application_Transaction_History__c(Id = each.Id, Submitted_Flag__c = true));
              }
            }
          }else{
          for (Loan_Application_Transaction_History__c each : [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c IN:loanIds AND (Name =: System.Label.Repayment_Mandate OR Screen__c =: System.Label.Repayment_Mandate) AND Module__c =: System.Label.Post_Sanction_Checks_and_Documentation WITH SECURITY_ENFORCED]) {
            if (!each.Submitted_Flag__c) {
              transactionHistoryToUpdate.put(each.Id, new Loan_Application_Transaction_History__c(Id = each.Id, Submitted_Flag__c = true));
            }
          }
          }
          if (!transactionHistoryToUpdate.isEmpty()) {
            update transactionHistoryToUpdate.values();
          }
        }
      } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('ENACHController', 'eNachEventHandler', System.Label.Apex, e);
        throw new ENACHControllerException(System.Label.ExceptionMessage);
      }
    }
    /* @Method : submitENACH
       @description :   Method to update Loan_Application_Transaction_History__c after ENACH is completed
       @param :  String loanApplicationId
       @return : Void 
      */
    @AuraEnabled
    public static void submitENACH(String loanApplicationId) {
      try {
        Map<Id, Loan_Application_Transaction_History__c> listToUpdate = new Map<Id, Loan_Application_Transaction_History__c>();
        for (Loan_Application_Transaction_History__c each : [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :loanApplicationId AND Name =: System.Label.Repayment_Mandate WITH SECURITY_ENFORCED]) {
          if (!each.Submitted_Flag__c) {
            listToUpdate.put(each.Id, new Loan_Application_Transaction_History__c(Id = each.Id, Submitted_Flag__c = true));
          }
        }
        if (!listToUpdate.isEmpty() && Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()) {
          update listToUpdate.values();
        }
      } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('ENACHController', 'submitENACH', System.Label.Apex, e,loanApplicationId);
        throw new ENACHControllerException(System.Label.ExceptionMessage); 
      }
    }
  
    /* 
     @description :   Method to get repaymentIds
     @param :  List<Low_Payload_Response__e>
     @return : Map<Id,Id> mapOfLoanApplicationIdVsRepaymentId
    */
    public static Map<String, Repayments__c> getRepaymentId(List<Low_Payload_Response__e> newLowPayloadResponseList) {
      Set<String> loanAppNum = new Set<String>();
      Map<String, Repayments__c> loanAppVsRepayment = new Map<String, Repayments__c>();
      for (Low_Payload_Response__e each : newLowPayloadResponseList) {
        if(each.Reference_Id__c !=null){
          String leadId = each.Reference_Id__c != null ? each.Reference_Id__c.split('-')[0] : '';
          loanAppNum.add(leadId);
        }
      }
      if(!loanAppNum.isEmpty()){
        for(Opportunity each:[SELECT Id,Loan_Application_Number__c,(SELECT Id,Repayment_Method__c, E_NACH_API_Status__c,Deal_Number__c FROM Repayments__r LIMIT 1) FROM Opportunity WHERE Id IN:loanAppNum WITH SECURITY_ENFORCED]){//CISP-15151 Added E_NACH_API_Status__c field
          if(each.Repayments__r!=null){
            loanAppVsRepayment.put(each.Id,each.Repayments__r[0]);
          }
        }
      }
      return loanAppVsRepayment;
    }
    /* //SFTRAC-401- Aakash
     @description :   Method to get getApplicantId
     @param :  List<Low_Payload_Response__e>
     @return : Map<Id,Id> applicantMap 
    */
  
    public static void criffEventHandler(List<Low_Payload_Response__e> newLowPayloadResponseList) {
  
      Map<Id, Applicant__c> applicantToUpdate = new Map<Id, Applicant__c>();
      Set<String> applicantSet = new Set<String>();
      Map<String, String> applicantMap = new Map<String, String>();
      Map<String, String> loanApplicationMap = new Map<String, String>();
      Set<String> loanAppIds = new Set<String>();
      Set<String> referenceIdSet = new Set<String>();
      for (Low_Payload_Response__e each : newLowPayloadResponseList) {
        if(each.Reference_Id__c !=null){
          String applicantId = each.Reference_Id__c != null ? each.Reference_Id__c.split('-')[0] : '';
          applicantSet.add(applicantId);
          String referenceId = each.Reference_Id__c != null ? each.Reference_Id__c : '';
          referenceIdSet.add(referenceId);
        }
      }
  
      String cicNoValue;
  
      if(!applicantSet.isEmpty()){
        for(Applicant__c each:[SELECT Id, Opportunity__c,CIC_No__c,Applicant_Type__c FROM Applicant__c WHERE Id IN:applicantSet WITH SECURITY_ENFORCED]){
          applicantMap.put(each.Id,each.Id);
          loanApplicationMap.put(each.Id,each.Opportunity__c);
          if(each.Applicant_Type__c == 'Borrower' && each.CIC_No__c != ''){
            cicNoValue = each.CIC_No__c;
          }
        }
      }
  
      for (Low_Payload_Response__e eventRec : newLowPayloadResponseList) {
        String appliId = eventRec.Reference_Id__c != null ? eventRec.Reference_Id__c.split('-')[0] : '';
        if (eventRec.SVC_Name__c == System.Label.GetCRIFReport && applicantMap.get(appliId)!=null) {
          Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(eventRec.Response__c);
          String encryptedResp = (String) resp.get('JData');
          String decryptedResp = IntegrationUtilities.getDecryptedResponse(encryptedResp, System.Label.privateKey, System.Label.ivkey);
          Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(decryptedResp);
          Map<String, Object> respObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(response.get('response')));
          if ((String) respObj.get('status') == 'SUCCESS') {
            loanAppIds.add(loanApplicationMap.get(appliId));//To update Loan Transaction History
            //Create a Response Wrappper for 
            ENACHController.CRIFFResponseWrapper criffWrapper = (ENACHController.CRIFFResponseWrapper) JSON.deserialize(decryptedResp, ENACHController.CRIFFResponseWrapper.class);
            String criffURL = criffWrapper != null && criffWrapper.response != null && criffWrapper.response.content != null && criffWrapper.response.content[0].Reporturl != '' ? criffWrapper?.response?.content[0].Reporturl+'/?CIC_No='+cicNoValue : '';
            applicantToUpdate.put(applicantMap.get(appliId), new Applicant__c(Id = applicantMap.get(appliId), CRIFF_Report_URL__c = criffURL));
          }
        }
      }
  
      if(!applicantToUpdate.isEmpty()) {
        update applicantToUpdate.values();
      }
    }
    @AuraEnabled
    public static List<Integration_Log__c> enachJournyStatusHistory(String loanApplicationId){//CISP-21804
      try{
        List<Integration_Log__c> enachJournyStatusHistory = new List<Integration_Log__c>();
       List<Integration_Log__c> enachStatusData=[SELECT Id,Service_Name__c,Loan_Application__c,Original_response__c,Original_request__c FROM Integration_Log__c where Service_Name__c ='ENACH Registration Status' and Loan_Application__c=:loanApplicationId ORDER BY CreatedDate DESC];
        for(Integration_Log__c intList : enachStatusData){
           if(intList.Original_response__c != null && intList.Original_response__c != ''){
            enachJournyStatusHistory.add(intList);
           }
        }
        if(enachJournyStatusHistory != null && enachJournyStatusHistory.size()>0){
     return enachJournyStatusHistory;
    }else{
        return null;
    }
  }Catch(Exception e){
    ErrorLoggerUtil.logErrorEvent('ENACHController', 'enachJournyStatusHistory', 'Class', e);
    throw new AuraHandledException(System.Label.ExceptionMessage);
  } 
    }//CISP-21804 
    public class SIResponseWrapper {
      Response response;
    }
  
    public class Response {
      String status;
      String respDesc;
      List<Content> content;
    }
  
    public class Content {
      String Deal_No;
      String Status;
    }
    //SFTRAC-410 Starts
    public class CRIFFResponseWrapper {
      CriffResponse response;
    }
  
    public class CriffResponse {
      String status;
      String respDesc;
      List<CriffContent> content;
    }
  
    public class CriffContent {
      String Isreportgenerated;
      String Reporturl;
    }
    //SFTRAC-410 Ends
  
    public class ENACHControllerException extends Exception {}
  }