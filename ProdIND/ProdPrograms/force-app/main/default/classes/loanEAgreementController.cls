/*------------------------------------------------------------
 Author:        Gaurav Rawat
 Company:       Manras
 Description:   loanEAgreementController is used to handle the loanEAgreement related requests. 
 Apex Class :   loanEAgreementController
 Test Class:    loanEAgreementControllerTest	
 History
 Date            Author              Comments
 -------------------------------------------------------------
 ------------------------------------------------------------*/
public with Sharing class loanEAgreementController {
	  /*
   * @Method:      getLoanEAgreementDetails
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to get the loanEAgreement details.
   * @Param:       String - loanAppId
   * @Return:      Loan_Agreement__c
   */
  @AuraEnabled(Cacheable=true)
  public static Loan_Agreement__c getLoanEAgreementDetails(String loanAppId, String dealId){
    try{
      Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
      Loan_Agreement__c objLoanAgreement = new Loan_Agreement__c();
      //Gaurav Changes
      List<Loan_Agreement__c> lstLoanAgreement = [Select ID,Loan_Application__c,Agreement_Booklet_Num__c,Loan_Application__r.StageName, Agreement_Type__c,BorrowerNesLCallCount__c,CoBorrowerNeslCallCount__c,Add_POA_SD_Initiation_method__c from Loan_Agreement__c where Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED  limit 1];
      if(oppRec.Product_Type__c == System.Label.Tractor){
        lstLoanAgreement = [SELECT ID,Loan_Application__c,Agreement_Booklet_Num__c,Loan_Application__r.StageName, Agreement_Type__c,BorrowerNesLCallCount__c,CoBorrowerNeslCallCount__c,Add_POA_SD_Initiation_method__c 
                              FROM Loan_Agreement__c 
                              WHERE Loan_Application__c =:loanAppId AND Deal_Number__c =: dealId
                              WITH SECURITY_ENFORCED  
                              LIMIT 1];
      }else{
        lstLoanAgreement = [SELECT ID,Loan_Application__c,Agreement_Booklet_Num__c,Loan_Application__r.StageName, Agreement_Type__c,BorrowerNesLCallCount__c,CoBorrowerNeslCallCount__c,Add_POA_SD_Initiation_method__c 
                              FROM Loan_Agreement__c 
                              WHERE Loan_Application__c =:loanAppId 
                              WITH SECURITY_ENFORCED  
                              LIMIT 1];
      }

      if(!lstLoanAgreement.isEmpty()){
          objLoanAgreement = lstLoanAgreement[0];   
      }

      return objLoanAgreement;
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('loanEAgreementController','getApplicantRecord', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
    /*
   * @Method:      getApplicant
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to get the applicant details.
   * @Param:       String - loanAppId
   * @Return:      List<Applicant__c>
   */
  @AuraEnabled(Cacheable=true)
  public static List<Applicant__c> getApplicant (string loanAppId){
    try{
      List<Applicant__c> lstLoanApplicant = new List<Applicant__c>([select id, Would_you_like_to_open_a_bank_account__c,CASA_Consent_OTP__c,Applicant_Type__c,Who_will_repay_the_loan__c from Applicant__c where Opportunity__c =: loanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);
      return lstLoanApplicant;
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('loanEAgreementController','getApplicant', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
    /*
   * @Method:      getMaxTryCount
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to get the max try count.
   * @Param:       
   * @Return:      Integer
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getMaxTryCount(){
    try{
      System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.NESL_EAgreementRetryCount);
      //CISP-2420 AND CISP-2418 - Added null check - START
      if(metadata != null){
        return Integer.valueOf(metadata.Number_Of_Attempts__c);
      }
      return 0;
      //CISP-2420 AND CISP-2418 - END
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('loanEAgreementController','getMaxTryCount', System.Label.Apex, e);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
      /*
   * @Method:      checkRetryExhausted
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to check the retry exhausted.
   * @Param:       String - loanApplicationId, String - serviceName, String - applicantId, String - applicantType, String - currentStageName
   * @Return:      Boolean
   */
  @AuraEnabled
public static Boolean checkRetryExhausted(String loanApplicationId, String serviceName,String applicantId,String applicantType,String currentStageName) {
  try {
    if (loanApplicationId != null) {
      List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :serviceName AND Applicant_Type__c =: applicantType AND User_Id__c =: UserInfo.getUserId() AND Module__c =: currentStageName WITH SECURITY_ENFORCED];
      if (!retryCountList.isEmpty()) {
        System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(serviceName);
        if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
          return true;
        }
      }
    }
    return false;
  } catch (Exception e) {
    ErrorLoggerUtil.logErrorEvent('loanEAgreementController', 'Loan E-Agreement', System.Label.Apex, e,loanApplicationId);
    throw new AuraHandledException(System.Label.ExceptionMessage);
  }
}

    /*
   * @Method:      retryCountIncrease
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to increase the retry count.
   * @Param:       String - loanApplicationId, String - serviceName, String - applicantId, String - applicantType, String - currentStageName
   * @Return:      List<Applicant__c>
   */
@AuraEnabled
public static Boolean retryCountIncrease(String loanApplicationId, String serviceName,String applicantId ,String applicantType,String currentStageName) {
  try {
    if (loanApplicationId != null) {
      List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :serviceName AND Applicant__c =: applicantId AND Applicant_Type__c =: applicantType AND User_Id__c =: UserInfo.getUserId() AND Module__c =: currentStageName WITH SECURITY_ENFORCED];
      if (!retryCountList.isEmpty()) {
        System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(serviceName);
        retryCountList[0].Count__c = retryCountList[0].Count__c == null ? 0 : retryCountList[0].Count__c;
        if (retryCountList[0].Count__c < metadata.Number_Of_Attempts__c) {
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
        Retry_Count__c retryCount = new Retry_Count__c();
        retryCount.Loan_Application_Id__c = loanApplicationId;
        retryCount.applicant__c = applicantId;
        retryCount.Service_Name__c = serviceName;
        retryCount.Module__c = currentStageName;
        retryCount.Applicant_Type__c = applicantType;
        retryCount.User_Id__c = UserInfo.getUserId();
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
    ErrorLoggerUtil.logErrorEvent('loanEAgreementController', 'retryCountIncrease', System.Label.Apex, e, loanApplicationId);
    throw new AuraHandledException(System.Label.ExceptionMessage);
  }
}
    /*
   * @Method:      getSubmittedCheck
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to get the Loan Application Histroy is submitted check.
   * @Param:       String - loanAppId
   * @Return:      boolean
   */
  @AuraEnabled(Cacheable=true)
  public static boolean getSubmittedCheck(string loanAppId, String dealId){
    try{
      boolean submitCheck = false;
      List<Loan_Application_Transaction_History__c> loanAppTrns = [Select id,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanAppId AND Screen__c =: System.Label.Loan_Agreement AND Module__c =: System.Label.Post_Sanction_Checks_and_Documentation AND Deal_Number__c =: dealId With SECURITY_ENFORCED ORDER BY LastModifiedDate  DESC];
      
      if(!loanAppTrns.isEmpty()){
          submitCheck = loanAppTrns[0].Submitted_Flag__c;
      }
      return submitCheck;
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('loanEAgreementController','getSubmittedCheck', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
   /*
   * @Method:      getInitiateAgreementDisable
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to get the Loan Application Histroy is submitted check.
   * @Param:       String - loanAppId
   * @Return:      boolean
   */
  @AuraEnabled(cacheable=true)
  public static boolean getInitiateAgreementDisable(String loanAppId, String dealId){
      try {
          Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];

          boolean initiateDisable = false;
          
          boolean submitCheck = false;
          for(Loan_Application_Transaction_History__c loanAppTrns : [Select id,Submitted_Flag__c from Loan_Application_Transaction_History__c
          where Loan_Application_ID__c=:loanAppId AND Module__c =: System.Label.Post_Sanction_Checks_and_Documentation AND Screen__c =: System.Label.Loan_Agreement AND Deal_Number__c =: dealId With SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1]){
              submitCheck = loanAppTrns.Submitted_Flag__c;
          }

          Boolean eSignForBorrower = false;
          Boolean eSignForCoBorrower = false;
          List<Loan_Agreement__c> loanAgreeList = new List<Loan_Agreement__c>();
          if(oppRec.Product_Type__c == System.Label.Tractor){
            loanAgreeList = [SELECT Id,e_agreement_Agreement_Signed_For_Co_Borr__c,e_agreement_Agreement_Signed_For_Borrowe__c 
                                FROM Loan_Agreement__c 
                                WHERE Loan_Application__c =: loanAppId AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED LIMIT 1];
          }else{
            loanAgreeList = [SELECT Id,e_agreement_Agreement_Signed_For_Co_Borr__c,e_agreement_Agreement_Signed_For_Borrowe__c 
                                FROM Loan_Agreement__c 
                                WHERE Loan_Application__c =: loanAppId 
                                WITH SECURITY_ENFORCED LIMIT 1];
          }

          for(Loan_Agreement__c loanAgree : loanAgreeList){
              eSignForBorrower = loanAgree.e_agreement_Agreement_Signed_For_Borrowe__c == 'Yes' ? true : false;
              eSignForCoBorrower = loanAgree.e_agreement_Agreement_Signed_For_Borrowe__c == 'Yes' ? true : false;
          }

          if(((eSignForBorrower == true && eSignForCoBorrower == true) || 
          (eSignForBorrower == true && eSignForCoBorrower == false)) && 
          submitCheck == false){
              initiateDisable =true;
          }
          return initiateDisable;
      } catch (Exception e) {
          ErrorLoggerUtil.logErrorEvent('loanEAgreementController', 'retryCountIncrease', System.Label.Apex, e, loanAppId);
          throw new AuraHandledException(System.Label.ExceptionMessage);
      }
  }

     /*
   * @Method:      updateLoanAppHistory
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to update the Loan Application Histroy.
   * @Param:       String - loanAppId
   * @Return:      boolean
   */
  @AuraEnabled
  public static boolean updateLoanAppHistory(String loanAppId){
    try{
      boolean submitCheck = false;
      List<Loan_Application_Transaction_History__c> loanAppTrns = [Select id,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanAppId AND Screen__c =: System.Label.Loan_Agreement AND Module__c =: System.Label.Post_Sanction_Checks_and_Documentation With SECURITY_ENFORCED ORDER BY LastModifiedDate  DESC];
      
      if(!loanAppTrns.isEmpty()){
          loanAppTrns[0].Submitted_Flag__c = false;
          submitCheck = true;
          return submitCheck;
      }
      return submitCheck;
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('loanEAgreementController','updateLoanAppHistory', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
     /*
   * @Method:      eAgreementValidate
   * @Created by:  Gaurav Rawat
   * @Description: This method is used to validate the eAgreement.
   * @Param:       String - loanAppId
   * @Return:      boolean
   */
  @AuraEnabled
  public static boolean eAgreementValidate(String loanAppId){
    try {
      Boolean isBorrower =  false;
      Boolean isCoBorrower = false; 
      for(Applicant__c applicant : [Select Id,Opportunity__c,Applicant_Type__c From Applicant__c Where Opportunity__c =: loanAppId AND In_Active_Applicant__c = false With SECURITY_ENFORCED]){
        if(applicant.Applicant_Type__c == System.Label.Borrower){
          isBorrower = true;
        }
        if(applicant.Applicant_Type__c == System.Label.CoBorrower){
          isCoBorrower = true;
        }
      }

      Boolean isBtnEnable = false;
      for(Loan_Agreement__c loanAgreement : [Select Id,Loan_Application__c,e_agreement_Agreement_Signed_For_Co_Borr__c,e_agreement_Agreement_Signed_For_Borrowe__c From Loan_Agreement__c Where Loan_Application__c =: loanAppId With SECURITY_ENFORCED]){
        if(isBorrower == true && isCoBorrower == true && loanAgreement.e_agreement_Agreement_Signed_For_Co_Borr__c == 'Yes' && loanAgreement.e_agreement_Agreement_Signed_For_Borrowe__c == 'Yes'){
            isBtnEnable = true;
        }else if(isBorrower == true && loanAgreement.e_agreement_Agreement_Signed_For_Borrowe__c == 'Yes'){
          isBtnEnable = true;
        }
      }
      return isBtnEnable;
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('loanEAgreementController', 'eAgreementValidate', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
}