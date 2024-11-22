/* 
* @Name         RepaymentScreenController
* @Author       Yogesh
* @Company      
* @Description  This class is used for Repayment Screen
* Inputs:       None
* Test Class:   RepaymentScreenControllerTest	
* History:
* Dated                      Modified By           Description
*                            Gaurav Rawat
*/
public with sharing class RepaymentScreenController {
  /*
   * @Method Name: displayRepaymentInfo
   * @Created by:  Yogesh
   * @description: Get Repayments__c data
   * @Param:       String - loanAppId
   * @Return:      Repayments__c
   */
 @AuraEnabled
 public static Repayments__c displayRepaymentInfo(String loanAppId, String dealId) {
   try {
     List<Repayments__c> repaymentDetails = new List<Repayments__c>();
     repaymentDetails = [SELECT Id, URL__c, Repayments_Captured_Correctly__c, Repayment_Remarks__c, Message__c, Account_Number__c, E_NACH_API_Status__c, Initiate_E_NACH_Btn_Click_Date_And_Time__c FROM Repayments__c WHERE Loan_Application__c = :loanAppId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
     if (repaymentDetails.size() > 0) {
       return repaymentDetails[0];
     }
     return null;
   } catch (Exception ex) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'displayRepaymentInfo', System.Label.Apex, ex, loanAppId);
     throw new IND_Exception(ex.getMessage());
   }
 }
/*
   * @Method Name: getRepaymentToBeDoneBy
   * @Created by:  Yogesh
   * @description: This method return the applicant record who is going to do the repayment
   * @Param:       String - loanApplicationId
   * @Return:      Applicant__c
   */
 @AuraEnabled
 public static IsWillingDoneByWrapper getRepaymentToBeDoneBy(String loanApplicationId) {
   try {
     IsWillingDoneByWrapper isWillingWrapperObj = new IsWillingDoneByWrapper();
     List<Applicant__c> applicantDetails = new List<Applicant__c>();
    //  CISP-2474/CISP-2497 - START
     applicantDetails = [SELECT Id, Name,Would_you_like_to_open_a_bank_account__c, Willing_to_open_Bank_Account_with_IIB__c,Who_will_repay_the_loan__c,Applicant_Type__c, Opportunity__r.LeadSource, Opportunity__r.Deal_Number__c, Email_Id__c, Contact_number__c, Customer_Code__c, Opportunity__r.Product_Type__c, Opportunity__r.StageName
                       FROM Applicant__c WHERE Opportunity__c = :loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
      Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c>();
     for(Applicant__c applicant : applicantDetails){
        if(!applicantMap.containsKey(applicant.Applicant_Type__c)){
          applicantMap.put(applicant.Applicant_Type__c,applicant);
        }
     }
     if (applicantDetails.size() > 0) {
      String willingValue = '';
      if(applicantMap.containsKey(System.Label.Borrower)){
        Applicant__c app = applicantMap.get(System.Label.Borrower);
        willingValue = app.Who_will_repay_the_loan__c;
        if(app.Willing_to_open_Bank_Account_with_IIB__c || app.Would_you_like_to_open_a_bank_account__c){
            isWillingWrapperObj.isApplWillingToOpenAcc = true;
        }
        if(app.Would_you_like_to_open_a_bank_account__c){
            isWillingWrapperObj.isWouldYouLikeBankAccount = true;
        }
      }
      if(applicantMap.containsKey(System.Label.coBorrower)){
        Applicant__c app = applicantMap.get(System.Label.coBorrower);
        // willingValue = app.Who_will_repay_the_loan__c;
        if(app.Willing_to_open_Bank_Account_with_IIB__c || app.Would_you_like_to_open_a_bank_account__c){
          isWillingWrapperObj.isApplWillingToOpenAcc = true;
        }
        if(app.Would_you_like_to_open_a_bank_account__c){
          isWillingWrapperObj.isWouldYouLikeBankAccount = true;
      }
      }
       isWillingWrapperObj.repaymentDoneBy = applicantMap.containsKey(willingValue) ? applicantMap.get(willingValue).Name : '';
       isWillingWrapperObj.applicantId = applicantMap.containsKey(willingValue) ? (String)applicantMap.get(willingValue).Id : '';
       isWillingWrapperObj.applicantEmail = applicantMap.containsKey(willingValue) ? applicantMap.get(willingValue).Email_Id__c : '';
       isWillingWrapperObj.applicantPhone = applicantMap.containsKey(willingValue) ? (String)applicantMap.get(willingValue).Contact_number__c	 : '';
       isWillingWrapperObj.customerCode = applicantMap.containsKey(willingValue) ? (String)applicantMap.get(willingValue).Customer_Code__c	 : '';

      //  CISP-2474/CISP-2497 - END
      isWillingWrapperObj.leadSource = applicantDetails[0].Opportunity__r?.LeadSource;//D2C Swapnil

      isWillingWrapperObj.productType = applicantDetails[0].Opportunity__r?.Product_Type__c;
      isWillingWrapperObj.stageName = applicantDetails[0].Opportunity__r?.StageName;

     }
     return isWillingWrapperObj;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'getRepaymentToBeDoneBy', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }
/**
* Class Name : IsWillingDoneByWrapper
* @ Author: Gaurav
* @ Description: Wrapper for the repaymentDone by and isApplWillingToOpenAcc wrap the data
*/

 public class IsWillingDoneByWrapper{
   @AuraEnabled
   public String repaymentDoneBy{get;set;}
   @AuraEnabled
   public Boolean isApplWillingToOpenAcc{get;set;}
   @AuraEnabled
   public Boolean isWouldYouLikeBankAccount{get;set;}
   @AuraEnabled
   public String applicantId{get;set;}
   //D2C Added leadSource - Swapnil
   @AuraEnabled
   public String leadSource{get;set;}

   @AuraEnabled
   public String applicantPhone{get;set;}
   @AuraEnabled
   public String applicantEmail{get;set;}
   @AuraEnabled
   public String customerCode{get;set;}
   @AuraEnabled
   public String productType{get;set;}
   @AuraEnabled
   public String stageName{get;set;}
 }
  /*
   * @Method Name: getLoanAmount
   * @Created by:  Yogesh
   * @description: This method return the Opportunity record and get the Loan Amount from it
   * @Param:       String - loanApplicationId
   * @Return:      Opportunity
   */
 @AuraEnabled
 public static Final_Term__c getLoanAmount(String loanApplicationId,String dealId) {
   try {
     //Applicant__c applicantDetails = new Applicant__c();
     Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     List<Final_Term__c> finaTermList = new List<Final_Term__c>();
     if(oppRec.Product_Type__c == System.Label.Tractor){
      List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
      finaTermList = [SELECT Id,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c 
                        FROM Final_Term__c 
                        WHERE Loan_Application__c=:loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id
                        WITH SECURITY_ENFORCED 
                        LIMIT 1 ];
     }else{
      finaTermList = [SELECT Id,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c 
                        FROM Final_Term__c 
                        WHERE Loan_Application__c=:loanApplicationId 
                        WITH SECURITY_ENFORCED 
                        LIMIT 1 ];
     }
     
     if (finaTermList.size() > 0) {
       return finaTermList[0];
     }
     return null;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'getLoanAmount', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }
    /*
   * @Method Name: createRepaymentRecord
   * @Created by:  Yogesh
   * @description: This method create the Repayment record
   * @Param:       String - loanApplicationId
   * @Param        Object - data
   * @Return:      Opportunity
   */
 @AuraEnabled
 public static Repayments__c createRepaymentRecord(String loanApplicationId, Object data,String dealId) {
   try {
     Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     if (loanApplicationId != null) {
       List<Repayments__c> repaymentList = new List<Repayments__c>();
       if(oppRec.Product_Type__c == System.Label.Tractor){
        repaymentList = [
         SELECT
           Id,
           Loan_Application__r.StageName,
           Is_Cancelled_Cheque_legible__c,
           ACH_Form_filled_correctly__c,
           Is_SI_form_Legible__c,
           SI_Form_filled_correctly__c,
           Authorization_mode_available__c,
           Repayments_Captured_Correctly__c,
           E_NACH_API_Status__c,
           Is_Netbanking_available_with_customer__c,
           Is_debit_card_available_with_customer__c,
           Repayment_Method__c,
           Until_Cancelled__c,
           End_Date__c,
           Frequency__c,
           Bank_Master__c,
           Bank_Master__r.Name,
           IFSC_Code__c,
           Account_Number__c,
           Remarks__c,
           RecordType.DeveloperName,
           SB_Or_CAis_ticked_appropriately__c,
           Repayment_Method_Retry_Count__c,
           Created_Date__c
         FROM Repayments__c
         WHERE Loan_Application__c = :loanApplicationId AND Deal_Number__c =: dealId
           WITH SECURITY_ENFORCED
       ];
       }else{
        repaymentList = [
         SELECT
           Id,
           Loan_Application__r.StageName,
           Is_Cancelled_Cheque_legible__c,
           ACH_Form_filled_correctly__c,
           Is_SI_form_Legible__c,
           SI_Form_filled_correctly__c,
           Authorization_mode_available__c,
           Repayments_Captured_Correctly__c,
           E_NACH_API_Status__c,
           Is_Netbanking_available_with_customer__c,
           Is_debit_card_available_with_customer__c,
           Repayment_Method__c,
           Until_Cancelled__c,
           End_Date__c,
           Frequency__c,
           Bank_Master__c,
           Bank_Master__r.Name,
           IFSC_Code__c,
           Account_Number__c,
           Remarks__c,
           RecordType.DeveloperName,
           SB_Or_CAis_ticked_appropriately__c,
           Repayment_Method_Retry_Count__c,
           Created_Date__c
         FROM Repayments__c
         WHERE Loan_Application__c = :loanApplicationId
           WITH SECURITY_ENFORCED
       ];
       }
       
       if (!repaymentList.isEmpty() && data == null) {
         return repaymentList[0];
       } else if (data != null) {
         Repayments__c repayment = (Repayments__c) JSON.deserialize(JSON.serialize(data), Repayments__c.class);
         if(oppRec.Product_Type__c == System.Label.Tractor){
          repayment.Deal_Number__c = dealId;
         }
         if(Schema.sObjectType.Repayments__c.isUpdateable() && Schema.sObjectType.Repayments__c.isCreateable()){
             upsert repayment;
         }
         return repayment;
       }
     }
     return null;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'createRepaymentRecord', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }
 @AuraEnabled
 public static Map<String,Object> getBankAndChequeDocForRepayment(String loanApplicationId,String dealId){
  try {
    Boolean isCommunityUser = false;
    Map<String,Object> mapObj = new Map<String,Object>();
    List<Profile> profileList = new List<Profile>([SELECT Id, Name,UserType FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1]);
    List<Vehicle_Detail__c> VehicleLst = new List<Vehicle_Detail__c>();
      Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
      if(oppRec.Product_Type__c == System.Label.Tractor){
      VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c = :loanApplicationId ];
      }else{
      VehicleLst = [SELECT Id FROM Vehicle_Detail__c  WHERE Loan_Application__c = :loanApplicationId ];
      }
      for(Documents__c doc : [SELECT ID,Name from Documents__c where isUploadedOnRepaymentScreen__c = true AND Opportunity_Relation__c =: loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id AND is_Active__c=true]){
       mapObj.put(doc.Name,doc.Id);
      }
      if(profileList[0].UserType == 'PowerPartner'){
        isCommunityUser = true;
      }
      mapObj.put('isCommunityUser',isCommunityUser);
      return mapObj;
  } catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
  }
 }
 @AuraEnabled
 public static string createBankAndChequeDoc(String docType,String loanApplicationId, String dealId, String applicantId ){
  try {
    if(applicantId!=null && docType!=null && loanApplicationId!=null ){
      list<Documents__c> docUpdList = new list<Documents__c>();
      List<Vehicle_Detail__c> VehicleLst = new List<Vehicle_Detail__c>();
      Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
      if(oppRec.Product_Type__c == System.Label.Tractor){
      VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c = :loanApplicationId ];
      }else{
      VehicleLst = [SELECT Id FROM Vehicle_Detail__c  WHERE Loan_Application__c = :loanApplicationId ];
      }
        ID personAccountRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
    
        for(Documents__c doc : [Select Id from Documents__c where Document_Type__c = :docType and Opportunity_Relation__c = :loanApplicationId and Applicant__c =:applicantId and Vehicle_Detail__c =: VehicleLst[0].Id AND isUploadedOnRepaymentScreen__c = true WITH SECURITY_ENFORCED]) {
          doc.is_Active__c = false;
          docUpdList.add(doc);
        }
        if(!docUpdList.isEmpty()) {
          update docUpdList;
        } 
        Documents__c docObject= new Documents__c(Name = docType,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId);
        docObject.RecordTypeId = personAccountRecordType;
        docObject.Document_Type__c=docType;
        docObject.is_Active__c=true;
        docObject.Vehicle_Detail__c = VehicleLst[0].Id;
        docObject.isUploadedOnRepaymentScreen__c = true;
       
        if (Schema.sObjectType.Documents__c.isCreateable()){
            insert docObject;
        }
        
        if(Test.isRunningTest())
        {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return docObject.id;
    }
    return null;         
    
} catch(Exception e){
  ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'createBankAndChequeDoc', System.Label.Apex, e, loanApplicationId);
  throw new IND_Exception(e.getMessage());
}
 }

 @AuraEnabled
 public static void updateRetryPennyDropAttempts(String loanApplicationId,String dealId){
  try {
    List<Vehicle_Detail__c> VehicleLst = new List<Vehicle_Detail__c>();
    Integer pennyDropAttempts = 0;
    Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     if(oppRec.Product_Type__c == System.Label.Tractor){
      VehicleLst = [SELECT Id,Penny_Drop_Api_Attempts__c FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c = :loanApplicationId ];
     }else{
      VehicleLst = [SELECT Id ,Penny_Drop_Api_Attempts__c FROM Vehicle_Detail__c  WHERE Loan_Application__c = :loanApplicationId ];
     }
     if(VehicleLst.size() >0){
      VehicleLst[0].Penny_Drop_Api_Attempts__c  = 0;
      update VehicleLst;
     }
    
  } catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
  }
 }
 @AuraEnabled
 public static string checkPennyDropApiAttempts(String loanApplicationId,String dealId){
  try {
    String msg = '';
    List<Vehicle_Detail__c> VehicleLst = new List<Vehicle_Detail__c>();
    Integer pennyDropAttempts = 0;
    Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     if(oppRec.Product_Type__c == System.Label.Tractor){
      VehicleLst = [SELECT Id,Penny_Drop_Api_Attempts__c FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c = :loanApplicationId ];
     }else{
      VehicleLst = [SELECT Id ,Penny_Drop_Api_Attempts__c FROM Vehicle_Detail__c  WHERE Loan_Application__c = :loanApplicationId ];
     }
     if(VehicleLst.size() >0){
        if(VehicleLst[0].Penny_Drop_Api_Attempts__c == null){
          VehicleLst[0].Penny_Drop_Api_Attempts__c = pennyDropAttempts + 1;
          msg = System.label.SuccessMessage;
        }else if (VehicleLst[0].Penny_Drop_Api_Attempts__c < 3){
          VehicleLst[0].Penny_Drop_Api_Attempts__c = VehicleLst[0].Penny_Drop_Api_Attempts__c + 1;
          msg = System.label.SuccessMessage;
        }else if(VehicleLst[0].Penny_Drop_Api_Attempts__c >= 3){
          msg = System.Label.Retry_Exhausted;
        }
        if(Schema.sObjectType.Vehicle_Detail__c.isUpdateable()){
          update VehicleLst;
        }
     }
    return msg;
  } catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
  }
 }
 @AuraEnabled
 public static string isPennyDropApiExhausted(String loanApplicationId,String dealId){
  try {
    String msg = '';
    List<Vehicle_Detail__c> VehicleLst = new List<Vehicle_Detail__c>();
    Integer pennyDropAttempts = 0;
    Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     if(oppRec.Product_Type__c == System.Label.Tractor){
      VehicleLst = [SELECT Id,Penny_Drop_Api_Attempts__c FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c = :loanApplicationId ];
     }else{
      VehicleLst = [SELECT Id ,Penny_Drop_Api_Attempts__c FROM Vehicle_Detail__c  WHERE Loan_Application__c = :loanApplicationId ];
     }
     if(VehicleLst.size() >0){
        if(VehicleLst[0].Penny_Drop_Api_Attempts__c == null){
          msg = System.label.SuccessMessage;
        }else if (VehicleLst[0].Penny_Drop_Api_Attempts__c < 3){
          msg = System.label.SuccessMessage;
        }else if(VehicleLst[0].Penny_Drop_Api_Attempts__c >= 3){
          msg = System.Label.Retry_Exhausted;
        }
     }
    return msg;
  } catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
  }
 }

  /*
   * @Method Name: getFinalTermRecord
   * @Created by:  Yogesh
   * @description: Get the Final Term record details related to the loan application
   * @Param:       String - loanApplicationId
   * @Return:      Final_Term__c
   */
 @AuraEnabled
 public static Final_Term__c getFinalTermRecord(String loanApplicationId,String dealId) {
   try {
     List<Final_Term__c> ftDetails = new List<Final_Term__c>();
     Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     if(oppRec.Product_Type__c == System.Label.Tractor){
      List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
      ftDetails = [SELECT Id, EMI_Amount__c,Holiday_period__c, Tenure__c, Repayment_mode__c,Installment_Frequency__c 
                    FROM Final_Term__c 
                    WHERE Loan_Application__c = :loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id
                    WITH SECURITY_ENFORCED];
     }else{
      ftDetails = [SELECT Id, EMI_Amount__c,Holiday_period__c, Tenure__c, Repayment_mode__c 
                    FROM Final_Term__c 
                    WHERE Loan_Application__c = :loanApplicationId 
                    WITH SECURITY_ENFORCED];
     }

     if (ftDetails.size() > 0) {
       return ftDetails[0];
     }
     return null;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'getFinalTermRecord', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }
  /*
   * @Method Name: getlstEMIDueDate
   * @Created by:  Yogesh
   * @description: This method return the loan Agreement record and get the EMI Due Date from it.
   * @Param:       String - loanApplicationId
   * @Return:      Loan_Agreement__c
   */
 @AuraEnabled
 public static Loan_Agreement__c getlstEMIDueDate(String loanApplicationId, String dealId) {
   try {
     List<Loan_Agreement__c> loanAgreementDetails = new List<Loan_Agreement__c>();
     Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     if(oppRec.Product_Type__c == System.Label.Tractor){
      loanAgreementDetails = [SELECT Id, Ist_EMI_Due_Date__c 
                                FROM Loan_Agreement__c 
                                WHERE Loan_Application__c = :loanApplicationId AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED];
     }else{
      loanAgreementDetails = [SELECT Id, Ist_EMI_Due_Date__c 
                                FROM Loan_Agreement__c 
                                WHERE Loan_Application__c = :loanApplicationId 
                                WITH SECURITY_ENFORCED];
     }
     
     if (loanAgreementDetails.size() > 0) {
       return loanAgreementDetails[0];
     }
     return null;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'getlstEMIDueDate', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }
 /* 
   * @Method Name: getAuthorizationMode
    @description :   Method to get authorization mode
    @param :  String bankName
    @return : String 
   */
 @AuraEnabled
 public static String getAuthorizationMode(String bankName) {
   try {
     return [SELECT Authorization_Mode_Flag__c FROM Bank_Authorization_Mode_Master__c WHERE Bank_Name__c = :bankName and Authorization_Mode_Flag__c!= null WITH SECURITY_ENFORCED limit 1]?.Authorization_Mode_Flag__c;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'getAuthorizationMode', System.Label.Apex, e, bankName);
     throw new IND_Exception(e.getMessage());
   }
 }
 /* 
   * @Method Name: validateACHDocs
    @description :   Method to validate ACH mandate and Cancelled Cheque are available
    @param :  String loanApplicationId
    @return : String
   */
 @AuraEnabled
 public static String validateACHDocs(String loanApplicationId) {
   String isAllDocsAvailable = '';
   List<ContentDocument> listOfACHMandateContentDocs = new List<ContentDocument>(); //List of ACH Mandate Content Documents
   List<ContentDocument> listOfCancelledCheqContentDocs = new List<ContentDocument>(); //List of Cancelled Cheque Content Documents
   try {
     Map<String, Object> achMandateWrap = IND_DatatableCntrl.getACHDocuments(loanApplicationId, 'ACH Mandate Form', 100); // get the ACH Mandate Form
     listOfACHMandateContentDocs = (List<ContentDocument>) achMandateWrap.get('records');
     Map<String, Object> cancelledCheqWrap = IND_DatatableCntrl.getACHDocuments(loanApplicationId, 'Cancelled Cheque', 100); // get the Cancelled Cheque
     listOfCancelledCheqContentDocs = (List<ContentDocument>) cancelledCheqWrap.get('records');
     if(listOfACHMandateContentDocs.size() > 0 && listOfCancelledCheqContentDocs.size() > 0) { // if both the documents are available
       isAllDocsAvailable = System.Label.AchChequeAvailable;
     } else if(listOfACHMandateContentDocs.size() > 0 && listOfCancelledCheqContentDocs.size() == 0) { // if only ACH mandate is available
       isAllDocsAvailable = System.Label.AchMandateAvailable;
     } else if(listOfACHMandateContentDocs.size() == 0 && listOfCancelledCheqContentDocs.size() > 0) { // if only Cancelled Cheque is available
       isAllDocsAvailable = System.Label.ChequeMandateAvailable;
     } else {
       isAllDocsAvailable = System.Label.AchChequeNotAvailable;
     }
     return isAllDocsAvailable;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'validateACHDocs', System.Label.Apex, e, null);
     throw new IND_Exception(e.getMessage());
   }
 }
 /* 
 @Method Name: deactivateOldDocs
  @description :   Method to deactived all the ACH docs
  @param :  String loanApplicationId
  @param :  String newDocId
  @param : String docType
  @return : void
 */
 @AuraEnabled
 public static void deactivateOldDocs(String loanApplicationId, String newDocId, String docType) {
   try {
     List<Documents__c> docListToUpdate = new List<Documents__c>();
     for (Documents__c doc : [SELECT Id, is_Active__c FROM Documents__c WHERE Opportunity_Relation__c = :loanApplicationId AND Id != :newDocId AND Document_Type__c = :docType WITH SECURITY_ENFORCED]) {
       if (doc.is_Active__c) {
         docListToUpdate.add(new Documents__c(Id = doc.Id, is_Active__c = false));
       }
     }
     if (!docListToUpdate.isEmpty() && Schema.sObjectType.Documents__c.isUpdateable()) {
       update docListToUpdate;
     }
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'deactivateOldDocs', System.Label.Apex, e, null);
     throw new IND_Exception(e.getMessage());
   }
 }
 /* 
   @Method Name: createOtherDocument
    @description :   Method to create documents
    @param :  String docTyp
    @param :  String applicantId
    @param :  String loanApplicationId
    @param :  String repaymetId
    @return : String
   */
 @AuraEnabled
 public static String createOtherDocument(String docType, String applicantId, String loanApplicationId, String repaymetId, String vehicleId) {
   try {
     Map<String, Integer> preferenceOrderMap = new Map<String, Integer>();
     if (applicantId != null && docType != null && loanApplicationId != null && repaymetId != null) {
       Id personAccountRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
       Documents__c docObject = new Documents__c(Name = docType, Applicant__c = applicantId, Opportunity_Relation__c = loanApplicationId, Repayment__c = repaymetId);
       docObject.RecordTypeId = personAccountRecordType;
       docObject.Document_Type__c = docType;
       docObject.is_Active__c = true;
       if(String.isNotBlank(vehicleId)){
        docObject.Vehicle_Detail__c = vehicleId;
       }
       if (docType != System.Label.CustomerImageDocumentType) { // if the document type is not Customer Image
         for (POI_Preference__mdt mdtElement : POI_Preference__mdt.getAll().values()) { // get the preference POI_Preference__mdt and
           preferenceOrderMap.put(mdtElement.MasterLabel, (Integer) mdtElement.Preference_Order__c);
         }
         docObject.Proof_of_Identity_POI__c = true;
         List<Documents__c> documentsList = new List<Documents__c>();
         if(String.isNotBlank(vehicleId)){
          documentsList = [SELECT Id, Name FROM Documents__c WHERE Applicant__c = :applicantId AND Document_Type__c != :System.Label.CustomerImageDocumentType AND Vehicle_Detail__c =: vehicleId WITH SECURITY_ENFORCED];
         }else{
          documentsList = [SELECT Id, Name FROM Documents__c WHERE Applicant__c = :applicantId AND Document_Type__c != :System.Label.CustomerImageDocumentType WITH SECURITY_ENFORCED];
         }
         if (!documentsList.isEmpty() && documentsList.size() > 0) {
           for (Documents__c doc : documentsList) {
             if (preferenceOrderMap.get(doc.Name) > preferenceOrderMap.get(docType)) { // if the preference order is greater than the current document type
               doc.Proof_of_Identity_POI__c = false;
             } else { // if the preference order is less than the current document type
               docObject.Proof_of_Identity_POI__c = false;
             }
           }
         }
         if (Schema.sObjectType.Documents__c.isUpdateable()) {
           update documentsList;
         }
       }
       if (Schema.sObjectType.Documents__c.isCreateable()) {
         insert docObject;
       }

       if (Test.isRunningTest()) {
         throw new AuraHandledException(System.Label.ExceptionMessage);
       }
       return docObject.id;
     } else {
       return null;
     }
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'createDocument', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }
 /* 
   @Method Name: isLoanAgreementSubmitted
    @description :   Method to to check if loanAgreement is submitted
    @param :  String loanApplicationId
    @return : boolean
   */
 @AuraEnabled
 public static Boolean isLoanAgreementSubmitted(String loanApplicationId, String dealId) {
   Boolean isLoanAggSubmitted = true;//CISP-143 Removed willingAccount attribute from here.
   try {
     String module = '';
     for(Opportunity loanApp : [SELECT Id, StageName FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED]) {
       module = loanApp.StageName;
     }
     //CISP-143 Removed for loop from here.
     if(module == 'Post Sanction Checks and Documentation'){ // if the module is Post Sanction Checks and Documentation
      //CISP-143 Removed willingAccount attribute from the if condition.
       for (Loan_Application_Transaction_History__c lonaAppHis : [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :loanApplicationId AND ( Name = 'Loan Agreement' OR Screen__c ='Loan Agreement' ) AND Module__c=:module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]) {
         if (!lonaAppHis.Submitted_Flag__c) {
           isLoanAggSubmitted = false;
           break;
         }
       }
     }
     return isLoanAggSubmitted;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'isLoanAgreementSubmitted', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }
 /* 
 @Method Name: updateLoanTransaction
  @description :   To Update Loan Transaction History Record
  @param :  String loanApplicationId
  @param :  String module
  @param :  String dealId
  @return : Void 
 */

 @AuraEnabled
 public static void updateLoanTransaction(String loanApplicationId, String module, String dealId) {
   try {
     Map<Id, Loan_Application_Transaction_History__c> listToUpdate = new Map<Id, Loan_Application_Transaction_History__c>();
     for (Loan_Application_Transaction_History__c each : [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :loanApplicationId AND ( Name = 'Repayment Mandate' OR Screen__c ='Repayment Mandate' ) AND Module__c=:module AND Deal_NUmber__c=:dealId WITH SECURITY_ENFORCED]) { // get the Loan_Application_Transaction_History__c record for the loan application
       if (!each.Submitted_Flag__c) {
         listToUpdate.put(each.Id, new Loan_Application_Transaction_History__c(Id = each.Id, Submitted_Flag__c = true));
       }
     }
     if (!listToUpdate.isEmpty() && Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()) {
       update listToUpdate.values();
     }
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'updateLoanTransaction', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage()); 
   }
 }

 /* 
 @Method Name: isCheckReadOnly
  @description :   To check Loan Transaction History Record submitted or not
  @param :  String loanApplicationId
  @return : IsEnableWrapper 
 */
 @AuraEnabled
 public static IsEnableWrapper isCheckReadOnly(String loanApplicationId, String dealId) {
   Boolean isCheckReadOnly = true;
   try {
     IsEnableWrapper isEnableWrapperObj = new IsEnableWrapper();
     String module = '';
     Opportunity oppRecord = [SELECT Id, StageName, Product_Type__c FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
     isEnableWrapperObj.stageName = oppRecord.StageName;
     if(oppRecord != null && oppRecord.stageName == 'Post Sanction Checks and Documentation'){ // if the module is Post Sanction Checks and Documentation
       module = 'Post Sanction Checks and Documentation';
       for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c =: loanApplicationId AND Module__c =: module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]){ // get the Loan_Application_Transaction_History__c record for the loan application
           if(history.Screen__c == System.Label.Repayment_Mandate && !history.Submitted_Flag__c){
             isCheckReadOnly = false;
           }   
         }
     }else if(oppRecord != null && oppRecord.stageName == 'Pre Disbursement Check'){ // if the sub stage is Pre Disbursement Check
       module = 'Pre Disbursement Check';
       List<Profile> profileList = new List<Profile>([SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1]);
       String profileName = profileList[0].Name;
       for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c =: loanApplicationId AND Module__c =: module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]){
         if(history.Screen__c == System.Label.Repayment_Mandate && !history.Submitted_Flag__c && (profileName == 'IBL Partner Community CVO' || profileName == 'IBL CVO' || (oppRecord.Product_Type__c == System.Label.Tractor && (profileName == 'IBL TF Payment Executive' || profileName == 'IBL TF Internal Payment Executive')))){ // if the profile is IBL Partner Community CVO or IBL CVO// IBL TF Payment Executive for tractor // IBL TF Internal Payment Executive

           isCheckReadOnly = false;
         }   
       }
     }
     //CISP-1223
     isEnableWrapperObj.isAchScreenSubmitted = false;
     
     List<Repayments__c> repList = new List<Repayments__c>();

     if(oppRecord.Product_Type__c == System.Label.Tractor){
      repList = [SELECT Id,EMl_Amt_Is_filled_correctly__c 
                  FROM Repayments__c 
                  WHERE Loan_Application__c =: loanApplicationId AND Deal_Number__c =: dealId
                  WITH SECURITY_ENFORCED];
     }else{
      repList = [SELECT Id,EMl_Amt_Is_filled_correctly__c 
                  FROM Repayments__c 
                  WHERE Loan_Application__c =: loanApplicationId 
                  WITH SECURITY_ENFORCED];
     }

     for(Repayments__c repayment : repList){
      if(repayment.EMl_Amt_Is_filled_correctly__c == 'Yes'){
        isEnableWrapperObj.isAchScreenSubmitted = true;
      }
     }
     //CISP-1223
     isEnableWrapperObj.isCheckReadOnly = isCheckReadOnly;
     return isEnableWrapperObj;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'isLoanTransactionSubmitted', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }   
 }

 /*
 @Class Name: IsEnableWrapper
  @description :   Wrapper for the Loan Transaction History Record submitted or not and stage name
 */
 public class IsEnableWrapper {
   @AuraEnabled
   public boolean isCheckReadOnly{get;set;}
   @AuraEnabled
   public string stageName{get;set;}
   @AuraEnabled
   public Boolean isAchScreenSubmitted{get;set;}//CISP-1223
 }

 /*
 @Method Name: documentRecordId
  @description :   To get the document record id
  @param :  String loanApplicationId
  @param :  String docType
  @return : String
 */
 @AuraEnabled
 public static String documentRecordId(String loanApplicationId,String docType, String dealId){
   try {
     String documentId = '';
     String applicantId = '';    //  CISP-2474/CISP-2497-START
     List<Applicant__c> applicantList = new List<Applicant__c>(
       [SELECT Id, Name, Applicant_Type__c,Who_will_repay_the_loan__c FROM Applicant__c WHERE Opportunity__c = :loanApplicationId  AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]
     );

     Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c>();
     for(Applicant__c applicant : applicantList){
        if(!applicantMap.containsKey(applicant.Applicant_Type__c)){
          applicantMap.put(applicant.Applicant_Type__c,applicant);
        }
     }
     String willingValue = '';
     if(applicantMap.containsKey(System.Label.Borrower)){
      willingValue = applicantMap.get(System.Label.Borrower).Who_will_repay_the_loan__c;
     }
     if(applicantMap.containsKey(willingValue)){
      applicantId = applicantMap.get(willingValue).Id;
     }

     Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
     if(opp.Product_Type__c == 'Tractor'){
      List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
      for(Documents__c doc : [SELECT Id, Name, Document_Type__c, is_Active__c, Is_Document_Eligible__c, Correctly_Captured__c, Remarks__c from Documents__c where Opportunity_Relation__c =: loanApplicationId AND Applicant__c =: applicantId AND is_Active__c = true AND Vehicle_Detail__c =: VehicleLst[0].Id order by createdDate desc]){
        if(doc.Document_Type__c == docType){
          documentId = doc.Id;
          break;
        }
      } 
     }else{
      //  CISP-2474/CISP-2497-END
      for(Documents__c doc : [SELECT Id, Name, Document_Type__c, is_Active__c, Is_Document_Eligible__c, Correctly_Captured__c, Remarks__c from Documents__c where Opportunity_Relation__c =: loanApplicationId AND Applicant__c =: applicantId AND is_Active__c = true order by createdDate desc]){
        if(doc.Document_Type__c == docType){
          documentId = doc.Id;
          break;
        }
      } 
     }
     return documentId;
   } catch (Exception e) {
     ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'isLoanTransactionSubmitted', System.Label.Apex, e, loanApplicationId);
     throw new IND_Exception(e.getMessage());
   }
 }

 //CISP-1223 - START
 /* 
 @Method Name: unsubmitLoanTransaction
  @description :   To Unsubmit Loan Transaction History Record
  @param :  String loanApplicationId
  @param :  String module
  @return : Void 
 */

  @AuraEnabled
  public static void unsubmitLoanTransaction(String loanApplicationId, String module, String dealId) {
    try {
      Map<Id, Loan_Application_Transaction_History__c> listToUpdate = new Map<Id, Loan_Application_Transaction_History__c>();
      for (Loan_Application_Transaction_History__c each : [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :loanApplicationId AND ( Name = 'Repayment Mandate' OR Screen__c ='Repayment Mandate' ) AND Module__c=:module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]) { // get the Loan_Application_Transaction_History__c record for the loan application
        if (each.Submitted_Flag__c) {
          listToUpdate.put(each.Id, new Loan_Application_Transaction_History__c(Id = each.Id, Submitted_Flag__c = false));
        }
      }
      if (!listToUpdate.isEmpty() && Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()) {
        update listToUpdate.values();
      }
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'unsubmitLoanTransaction', System.Label.Apex, e, loanApplicationId);
      throw new IND_Exception(e.getMessage()); 
    }
  }

  @AuraEnabled
  public static Boolean runningInstance(){
    return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;  
  }
  @AuraEnabled
  public static void submitLoanTransaction(String loanApplicationId, String module, String dealId) {
    try {
      Map<Id, Loan_Application_Transaction_History__c> listToUpdate = new Map<Id, Loan_Application_Transaction_History__c>();
      for (Loan_Application_Transaction_History__c each : [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :loanApplicationId AND ( Name = 'Repayment Mandate' OR Screen__c ='Repayment Mandate' ) AND Module__c=:module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]) { // get the Loan_Application_Transaction_History__c record for the loan application
        if (!each.Submitted_Flag__c) {
          listToUpdate.put(each.Id, new Loan_Application_Transaction_History__c(Id = each.Id, Submitted_Flag__c = true));
        }
      }
      if (!listToUpdate.isEmpty() && Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()) {
        update listToUpdate.values();
      }
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('RepaymentScreenController', 'submitLoanTransaction', System.Label.Apex, e, loanApplicationId);
      throw new IND_Exception(e.getMessage()); 
    }
  }
  //CISP-1223 - END

  @AuraEnabled
  public static string getVehicleId(String loanApplicationId, String module, String dealId) {
    if(String.isNotBlank(dealId)){
      return [Select Id From Vehicle_Detail__c WHERE Deal_Number__c =: dealId and Loan_Application__c =: loanApplicationId LIMIT 1].Id;
    }
    return [Select Id From Vehicle_Detail__c WHERE Loan_Application__c =: loanApplicationId LIMIT 1].Id;
  }

  //CISP-23361 - Start
  @AuraEnabled
  public static List<Pennydrop_Validation__mdt> getAllPennyDropValidations(){
      try {
        List<Pennydrop_Validation__mdt> pennyDropFailures=[SELECT Id,Label,DeveloperName,Status_Code__c,Status_Description__c,is_Allowed__c	 from Pennydrop_Validation__mdt WHERE is_Allowed__c	= false WITH SECURITY_ENFORCED limit 100 ];
          return pennyDropFailures;
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  } 
  //CISP-23361 - End

}