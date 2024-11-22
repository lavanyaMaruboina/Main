/*------------------------------------------------------------
 Author:        Gaurav Rawat
 Company:       Manras
 Description:   IND_GetFinalOfferDetails class is used to get the final offer details. 
 Apex Class :   IND_GetFinalOfferDetails
 Test Class:    IND_GetFinalOfferDetailsTestClass
 History 
 Date            Author              Comments
 -------------------------------------------------------------
 09/01/2022     Gaurav Rawat       Initial Creation
 ------------------------------------------------------------*/
 public with sharing class IND_GetFinalOfferDetails{
  /*
   * @Method:      getFinalOfferDetails
   * @Created by:  Gaurav Rawat
   * @Description: This method return Final Term details in a wrappper
   * @Param:       String - Final term ID
   * @Return:      FinalOfferDetails - Wrapper data
   */
  @AuraEnabled(cacheable = true)
  public static FinalOfferDetails getFinalOfferDetails(String loanId){
    try{
      Opportunity loanApplication = [select Journey_Status__c,Product_Type__c,LeadSource from Opportunity where Id =:loanId WITH SECURITY_ENFORCED LIMIT 1];
      FinalOfferDetails finalOfferDetails = new FinalOfferDetails();
      List<Final_Term__c> finaltermsList = new List<Final_Term__c>([SELECT id,Loan_Amount__c, Loan_Application__c,Loan_Application__r.Application_number__c,Tenure__c, CRM_IRR__c, EMI_Amount__c,Loan_Application__r.Total_Funded_Premium__c,Gross_IRR__c,Net_IRR__c,Holiday_period__c FROM Final_Term__c WHERE Loan_Application__c=:loanId WITH SECURITY_ENFORCED LIMIT 1]);

      for(Applicant__c applicant : [Select Id,Contact_Number__c,Name From Applicant__c Where Opportunity__c = :loanId AND Applicant_Type__c = : System.Label.Borrower AND In_Active_Applicant__c = false  WITH SECURITY_ENFORCED LIMIT 10]){
        finalOfferDetails.loanApplicationName = applicant.Name;
        finalOfferDetails.loanApplicationContactNumber = applicant.Contact_number__c;
      }
      if(finaltermsList.size() == 1){
        finalOfferDetails.loanApplicationNumber = finaltermsList[0].Loan_Application__r.Application_number__c;
        finalOfferDetails.offerLoanAmount = Decimal.valueOf(finaltermsList[0].Loan_amount__c) + finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c;
          finalOfferDetails.offerTenure = finaltermsList[0].Tenure__c;
          finalOfferDetails.offerIRR = finaltermsList[0].CRM_IRR__c;
          finalOfferDetails.offerEMI = finaltermsList[0].EMI_Amount__c;
          finalOfferDetails.numberOfInstallmentValue = finaltermsList[0].Holiday_period__c == '30' ? String.valueof(Integer.valueOf(finaltermsList[0].Tenure__c) - 1) : finaltermsList[0].Holiday_period__c == '0' ? finaltermsList[0].Tenure__c : '';
          if(loanApplication.LeadSource=='OLA'){finalOfferDetails.numberOfInstallmentValue = finaltermsList[0].Tenure__c;}//OLA-139
          finalOfferDetails.netIRRValue = String.valueOf(finaltermsList[0].Net_IRR__c);
          finalOfferDetails.grossIRRValue = finaltermsList[0].Gross_IRR__c;
      }
      finalOfferDetails.isProductTypePV = loanApplication.Product_Type__c == 'Passenger Vehicles' ? true : false;
      finalOfferDetails.JourneyStatus = loanApplication.Journey_Status__c;
      List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select id, Make__c, Model__c, Variant__c From Vehicle_Detail__c Where Loan_Application__c = :loanId With SECURITY_ENFORCED LIMIT 1]);
     
        if (vehicleList.size() > 0){
        String makeModelVariantStr = vehicleList[0].Variant__c;//CISP-2744 - removed the Make and Model from Concatenation
        finalOfferDetails.makeModelVariant = makeModelVariantStr.trim();
      }
        return finalOfferDetails;
    }
      catch (Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'getFinalOfferDetails', System.Label.Apex, e, loanId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }


  /*
   * @Method:      getFinalOfferDetailsForTractor
   * @Created by:  Utkarsh Maurya
   * @Description: This method return Final Term details in a wrappper
   * @Param:       String - Final term ID
   * @Return:      FinalOfferDetails - Wrapper data
   */
  @AuraEnabled
  public static FinalOfferDetails getFinalOfferDetailsForTractor(String loanId){
    try{
      Opportunity loanApplication = [select Journey_Status__c,Product_Type__c,LeadSource from Opportunity where Id =:loanId WITH SECURITY_ENFORCED LIMIT 1];
      FinalOfferDetails finalOfferDetails = new FinalOfferDetails();
      List<Final_Term__c> finaltermsList = new List<Final_Term__c>([SELECT id,Loan_Amount__c, Loan_Application__c,Loan_Application__r.Application_number__c,Tenure__c, CRM_IRR__c, EMI_Amount__c,Loan_Application__r.Total_Funded_Premium__c,Gross_IRR__c,Net_IRR__c,Required_CRM_IRR__c,No_of_Installment__c, Vehicle_Detail__r.Make__c, Vehicle_Detail__r.Model__c, Vehicle_Detail__r.Variant__c, Vehicle_Detail__r.Approval_Status__c,Vehicle_Detail__r.Total_Funded_Amount__c, Vehicle_Detail__r.Installment_Type__c, Loan_Application__r.Product_Type__c, Derived_CRM_IRR__c FROM Final_Term__c WHERE Loan_Application__c=:loanId AND Vehicle_Detail__r.Approval_Status__c ='Approved' WITH SECURITY_ENFORCED ORDER BY Vehicle_Detail__r.CreatedDate ASC LIMIT 10]);

      for(Applicant__c applicant : [Select Id,Contact_Number__c,Name , Opportunity__r.Application_number__c From Applicant__c Where Opportunity__c = :loanId AND Applicant_Type__c = : System.Label.Borrower AND In_Active_Applicant__c = false  WITH SECURITY_ENFORCED LIMIT 10]){
        finalOfferDetails.loanApplicationName = applicant.Name;
        finalOfferDetails.loanApplicationContactNumber = applicant.Contact_number__c;
        finalOfferDetails.loanApplicationNumber = applicant.Opportunity__r.Application_number__c;

      }

      List<MMVDetails> mmvDetailList = new List<MMVDetails>();

      if(finaltermsList.size() != 0){
        for(Final_Term__c finalTerm: finaltermsList){
          MMVDetails mmvDetail = new MMVDetails();

          mmvDetail.offerLoanAmount = Decimal.valueOf(finalTerm.Loan_amount__c) + (finalTerm.Vehicle_Detail__r.Total_Funded_Amount__c == null ? 0 : finalTerm.Vehicle_Detail__r.Total_Funded_Amount__c);
          mmvDetail.offerTenure = finalTerm.Tenure__c;
          mmvDetail.offerIRR = finalTerm.Required_CRM_IRR__c !=null? Decimal.valueof(finalTerm.Required_CRM_IRR__c ): null;
          if(finalTerm.Vehicle_Detail__r.Installment_Type__c == 'Structured' && finalTerm.Loan_Application__r.Product_Type__c == System.label.Tractor){
            mmvDetail.offerDerivedIrr = finalTerm.Derived_CRM_IRR__c !=null? Decimal.valueof(finalTerm.Derived_CRM_IRR__c ): null; //SFTRAC-2301
          }
          mmvDetail.offerEMI = finalTerm.EMI_Amount__c;
          mmvDetail.numberOfInstallmentValue = finalTerm.No_of_Installment__c == null ? '' : String.valueOf(finalTerm.No_of_Installment__c);
          mmvDetail.netIRRValue = String.valueOf(finalTerm.Net_IRR__c);
          mmvDetail.grossIRRValue = finalTerm.Gross_IRR__c;
          mmvDetail.approvalStatus = finalTerm.Vehicle_Detail__r.Approval_Status__c;
          String makeModelVariantStr = finalTerm.Vehicle_Detail__r.Variant__c;
          mmvDetail.makeModelVariant = makeModelVariantStr.trim();
          mmvDetailList.add(mmvDetail);
        }
        finalOfferDetails.MMVDetailsList = mmvDetailList;

      }
      finalOfferDetails.isProductTypePV = loanApplication.Product_Type__c == 'Passenger Vehicles' ? true : false;
      finalOfferDetails.JourneyStatus = loanApplication.Journey_Status__c;

        return finalOfferDetails;
    }
      catch (Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'getFinalOfferDetailsForTractor', System.Label.Apex, e, loanId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }



/*
* @Class:      FinalOfferDetails
* @Created by:  Gaurav Rawat 
* @Description: This class is used to get the final offer details.
*/
  // Wrapper class for final offer details
  public class FinalOfferDetails{
    @AuraEnabled
    public String loanApplicationName{ get; set; }
    @AuraEnabled
    public String loanApplicationNumber{ get; set; }
    @AuraEnabled
    public String loanApplicationContactNumber{ get; set; }
    @AuraEnabled
    public String makeModelVariant{ get; set; }
    @AuraEnabled
    public Decimal offerLoanAmount{ get; set; }
    @AuraEnabled
    public String offerTenure{ get; set; }
    @AuraEnabled
    public Decimal offerIrr{ get; set; }
    @AuraEnabled
    public Decimal offerEmi{ get; set; }
    @AuraEnabled
    public String numberOfInstallmentValue{ get; set; }
    @AuraEnabled
    public String netIRRValue{ get; set; }
    @AuraEnabled
    public Decimal grossIRRValue{ get; set; }
    @AuraEnabled
    public Boolean isProductTypePV{ get; set; }
    @AuraEnabled
    public String JourneyStatus{ get; set; }
    @AuraEnabled
    public List<MMVDetails> MMVDetailsList{ get; set; }

  }


  public class MMVDetails{
    @AuraEnabled
    public String makeModelVariant{ get; set; }
    @AuraEnabled
    public Decimal offerLoanAmount{ get; set; }
    @AuraEnabled
    public String offerTenure{ get; set; }
    @AuraEnabled
    public Decimal offerIrr{ get; set; }
    @AuraEnabled
    public Decimal offerDerivedIrr{ get; set; } //SFTRAC-2301
    @AuraEnabled
    public Decimal offerEmi{ get; set; }
    @AuraEnabled
    public String numberOfInstallmentValue{ get; set; }
    @AuraEnabled
    public String netIRRValue{ get; set; }
    @AuraEnabled
    public Decimal grossIRRValue{ get; set; }
    @AuraEnabled
    public String approvalStatus{ get; set; }
  }

  /*
   * @Method:      triggerSanctionCommunication
   * @Created by:  Gaurav Rawat
   * @Description: This method validate the loan application record.
   * @Param:       String - loanApplicationId
   * @Return:      List<String>
   */
  @AuraEnabled
  public static List<String> triggerSanctionCommunication(String loanAppId){
    try{
      Opportunity loanApplication = [Select id, Consent_Received__c, StageName, Sanction_Status__c, Sanction_Message_Triggered__c,AML_Check_status__c, AML_Check_Completed__c,IsRejected__c,Lead_Number__c,LeadSource,Is_Customer_Dedupe_Submit__c,Product_Type__c,Customer_type__c From Opportunity Where Id = :loanAppId WITH SECURITY_ENFORCED LIMIT 1];// INDI-4707 -- Added Lead_Number__c field in the query.
      List<String> resultList = new List<String>();

      if(loanApplication.StageName != System.Label.Credit_Processing){//CISP-2334
        resultList.add(System.Label.SanctionJourneyErrorMsg);
        return resultList;
      }else{
        //String kycRecordTypeId = (String) Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.KYC).getRecordTypeId();//CISP-2495
        Map<String,Documents__c> borrowerDoumentMap = new Map<String,Documents__c>();
        Map<String,Documents__c> coBorrowerDoumentMap = new Map<String,Documents__c>();

        Map<Id, DocumentWrappers> applicantDocMap = new Map<Id, DocumentWrappers>();
        Boolean documentCompleted = false;
        if(loanApplication.Product_Type__c == 'Tractor'){

          for(Documents__c document : [Select Id,Document_Type__c,Proof_of_Address_POA__c,Proof_of_Identity_POI__c,Applicant__c ,Applicant__r.Applicant_Type__c, Opportunity_Relation__r.Customer_Type__c From Documents__c Where Opportunity_Relation__c = : loanAppId  AND Applicant__r.Opportunity__c =: loanAppId AND is_Active__c = true AND Applicant__r.In_Active_Applicant__c = false With SECURITY_ENFORCED LIMIT 100]){
              DocumentWrappers documentWrapper = new DocumentWrappers();
              if(document.Proof_of_Address_POA__c){
                  documentWrapper.presentPOA = true;
              }
              if(document.Proof_of_Identity_POI__c){
                  documentWrapper.presentPOI = true;
              }
              if(document.Document_Type__c == 'PAN'){
                  documentWrapper.presentPAN = true;
              }
              if(document.Document_Type__c == 'Form 60'){
                  documentWrapper.presentForm60 = true;
              }
              documentWrapper.applicantType = document.Applicant__r.Applicant_Type__c ;
              documentWrapper.customerType = document.Opportunity_Relation__r.Customer_Type__c;

              
              if(applicantDocMap.containsKey(document.Applicant__c)){
                  DocumentWrappers docWrap = (DocumentWrappers) applicantDocMap.get(document.Applicant__c);
                  docWrap.presentPOA = documentWrapper.presentPOA == true ? true : docWrap.presentPOA;
                  docWrap.presentPOI = documentWrapper.presentPOI == true ? true : docWrap.presentPOI;
                  docWrap.presentPAN = documentWrapper.presentPAN == true ? true : docWrap.presentPAN;
                  docWrap.presentForm60 = documentWrapper.presentForm60 == true ? true : docWrap.presentForm60; 
                  applicantDocMap.put(document.Applicant__c , docWrap);
              }
              else{
                  applicantDocMap.put(document.Applicant__c , documentWrapper);
              }
          }
          for(Id applicantId : applicantDocMap.keySet()){
            if(applicantDocMap.containsKey(applicantId) && applicantDocMap.get(applicantId).customerType == 'Individual'){
              if(applicantDocMap.get(applicantId).presentPOA == true && applicantDocMap.get(applicantId).presentPOI == true && (applicantDocMap.get(applicantId).presentPAN == true || applicantDocMap.get(applicantId).presentForm60 == true)){
                  documentCompleted = true; 
              }
              else{
                  documentCompleted = false;
                  break;
              }       
            }else if(applicantDocMap.containsKey(applicantId) && applicantDocMap.get(applicantId).customerType == 'Non-Individual'){
                if(applicantDocMap.get(applicantId).applicantType == System.Label.Borrower && applicantDocMap.get(applicantId).presentPAN == true){
                    documentCompleted = true; 
                }else if(applicantDocMap.get(applicantId).presentPOA == true && applicantDocMap.get(applicantId).presentPOI == true && (applicantDocMap.get(applicantId).presentPAN == true || applicantDocMap.get(applicantId).presentForm60 == true)){
                    documentCompleted = true; 
                }else{
                  documentCompleted = false;
                    break;
                }
            }        
        }
    }else{
        for(Documents__c document : [Select Id,Document_Type__c,Proof_of_Address_POA__c,Proof_of_Identity_POI__c,Applicant__r.Applicant_Type__c From Documents__c Where Opportunity_Relation__c = : loanAppId  AND is_Active__c = true AND Applicant__r.In_Active_Applicant__c = false With SECURITY_ENFORCED LIMIT 100]){//CISP-2495 - Removed recordType filter.
          if(document.Applicant__r.Applicant_Type__c == System.label.Borrower){
            if(document.Proof_of_Address_POA__c){
              borrowerDoumentMap.put('POA', document);
            }
            if(document.Proof_of_Identity_POI__c){
              borrowerDoumentMap.put('POI', document);
            }
            if(document.Document_Type__c == 'PAN'){
              borrowerDoumentMap.put('PAN', document);
            }
            if(document.Document_Type__c == 'Form 60'){
              borrowerDoumentMap.put('Form 60', document);
            }
          }
          if(document.Applicant__r.Applicant_Type__c == System.label.Coborrower){
            if(document.Proof_of_Address_POA__c){
              coBorrowerDoumentMap.put('POA', document);
            }
            if(document.Proof_of_Identity_POI__c){
              coBorrowerDoumentMap.put('POI', document);
            }
            if(document.Document_Type__c == 'PAN'){
              coBorrowerDoumentMap.put('PAN', document);
            }
            if(document.Document_Type__c == 'Form 60'){
              coBorrowerDoumentMap.put('Form 60', document);
           }
        }
       }
      }
      System.debug('borrowerDoumentMap ' + borrowerDoumentMap);
      System.debug('coBorrowerDoumentMap ' + coBorrowerDoumentMap);
      if(
          ((
            ((borrowerDoumentMap.containsKey('POA') && borrowerDoumentMap.containsKey('POI')) || loanApplication.Customer_type__c == 'Non-Individual') && 
            (borrowerDoumentMap.containsKey('PAN') || borrowerDoumentMap.containsKey('Form 60'))
          ) 
         &&
          (
            (coBorrowerDoumentMap.isEmpty()) || 
            (
              coBorrowerDoumentMap.containsKey('POA') && coBorrowerDoumentMap.containsKey('POI') && 
              (
                coBorrowerDoumentMap.containsKey('PAN') || coBorrowerDoumentMap.containsKey('Form 60')
              )
            )
          )) || (documentCompleted == true && loanApplication.Product_Type__c == 'Tractor')
      ){
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();

      if(loanApplication.Product_Type__c == 'Tractor'){

          Set<Id> approvedVehicle = new Set<Id>();
          List<Vehicle_Detail__c> approvedVehicleList = new List<Vehicle_Detail__c>([Select Id, Make__c, Model__c, Variant__c From Vehicle_Detail__c Where Loan_Application__c = :loanAppId AND Approval_Status__c ='Approved' With SECURITY_ENFORCED LIMIT 10]);
          for(Vehicle_Detail__c vd : approvedVehicleList){
            approvedVehicle.add(vd.Id);
          }
          finalTermList = [Select Id, Name From Final_Term__c Where Loan_Application__c = :loanAppId AND Vehicle_Detail__c IN : approvedVehicle WITH SECURITY_ENFORCED LIMIT 10];
          if(approvedVehicleList.size() > finalTermList.size()){
            resultList.add(System.Label.finalTermMissing.toLowerCase());
            return resultList;
          }
        
        }
        else{
          finalTermList = [Select Id, Name From Final_Term__c Where Loan_Application__c = :loanAppId WITH SECURITY_ENFORCED LIMIT 1];
          if (finalTermList.size() == 0){
            resultList.add(System.Label.finalTermMissing.toLowerCase());
            return resultList;
          }
        }
      if(loanApplication.IsRejected__c){
        resultList.add(System.Label.LoanApplicationRejectedMsg);
        return resultList;
      }
      if (loanApplication.Sanction_Status__c == '' || loanApplication.Sanction_Status__c == null){
        resultList.add(String.valueof(false));
        return resultList;
      }
      Map<Id, Applicant__c> applicantMap = new Map<Id, Applicant__c>([Select id, Opportunity__c,Opportunity__r.Lead_number__c,Opportunity__r.LeadSource, Name, Applicant_Type__c, Application_Consent_Received__c,Insurance_Consent_Received__c, Consent_Received__c, Email_Id__c,IND_Customer_Master_Updation_Status__c,IND_Customer_Master_Creation_Status__c,(Select Id From Insurance_Details__r),Opportunity__r.Product_Type__c,IsPrimary__c,Opportunity__r.Customer_Type__c,Opportunity__r.Entity_Type__c From Applicant__c Where Opportunity__c = :loanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 10]);
      if (applicantMap.values().size() == 0){
        resultList.add(String.valueof(false));
        return resultList;
      }
      // validate for the STP loan Application.
      if (loanApplication.Sanction_Status__c == System.Label.STP){
        for (Applicant__c applicant : applicantMap.values()){
            if (applicant.Consent_Received__c == true && (applicant.Applicant_Type__c == System.Label.Borrower || applicant.Applicant_Type__c == System.Label.CoBorrower) && applicant.Email_Id__c != null){
            resultList.add(String.valueof(true));
          } else{
            resultList.add(String.valueof(false));
          }
        }
        if (!resultList.contains(String.valueof(false))){

          if(loanApplication.Product_Type__c == 'Tractor'){
            loanApplication.Sanction_Date__c = date.today();
            update loanApplication;
            resultList.add(System.Label.Approved.toLowerCase());
              return resultList;
          }
          else{
            if (Schema.sObjectType.Opportunity.isUpdateable()){
              for (Applicant__c applicant : applicantMap.values()){
                // Send an sms for the valid applicant using sms api.
                String app_str = smsWrapper(applicant);
                if (!Test.isRunningTest())
                  Object obj = IntegrationEngine.doSmsGatewayAPI(app_str);
              }
              // Updated the loan application and flow will run and send an email.
              loanApplication.Sanction_Message_Triggered__c = true;
              loanApplication.Sanction_Date__c = date.today();
              update loanApplication;
              resultList.add(System.Label.Approved.toLowerCase());
              return resultList;
            } else{
              resultList.add(String.valueof(false));
              return resultList;
            }
          }
         
        }else{
          return resultList;
        }
      } else if (loanApplication.Sanction_Status__c == System.Label.nonStp){
        // validate for the Non-STP loan Application.
        // RecordTypeId of Case object.
        String tvrRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.TVR).getRecordTypeId();
        String amlRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.AML_Check).getRecordTypeId();
        List<String> errorList = new List<String>();
        List<Case> amlCaseList = new List<Case>([Select Id, Status, Applicant__c,Owner.Profile.Name From Case Where Loan_Application__c = :loanApplication.Id AND RecordTypeId = :amlRecordTypeId LIMIT 100]);
        List<Case> amlCaseListTractor = new List<Case>([Select Id, Status, Applicant__c,Case_Owner_Custom__c,Loan_Application__r.Product_Type__c,Owner.Profile.Name From Case Where Loan_Application__c = :loanApplication.Id AND RecordTypeId = :amlRecordTypeId and Status != 'Closed' AND Loan_Application__r.Product_Type__c =: Label.Tractor LIMIT 100]);
        Set<String> profileNames = new Set<String>(); 
         for (Case amlCase : amlCaseList) {
         profileNames.add(amlCase.Owner.Profile.Name);
        }
        if ((amlCaseList.size() > 0 && loanApplication.AML_Check_status__c != System.Label.Approved) || (amlCaseListTractor.size() > 0)) {
        for (String profileName : profileNames) {
       if(profileName == 'CMU' || (amlCaseListTractor.size() > 0 && amlCaseListTractor[0].Status == 'Pending with CMU')){ 

        String errorMessage = System.Label.SanctionAMLErrorMsg + ' CMU ' +'for action';
        errorList.add(errorMessage);
          
          }else if(profileName == 'IBL National Credit Manager'){
            String errorMessage = System.Label.SanctionAMLErrorMsg + ' ' +'NCM for action';
            errorList.add(errorMessage);
            }else if(profileName == 'IBL Credit Analyst'){ //CISP-9742 START
            String errorMessage = System.Label.SanctionAMLErrorMsg + ' ' +'Credit Analyst for action';
            errorList.add(errorMessage); //CISP-9742 END
          }else if(profileName == 'IBL Credit Head'){
            String errorMessage = System.Label.SanctionAMLErrorMsg + ' ' +'Credit Head for action';
            errorList.add(errorMessage);
          }else if(profileName == 'IBL Business Executive' || profileName == 'IBL TF Business Executive' || profileName == 'IBL CVO' || profileName == 'IBL TF CVO' || profileName == 'IBL Partner Community CVO' || profileName == 'IBL Partner Community TF CVO'){
            errorList.add('Unable to trigger sanction communication since AML case is Pending for CVO / BE action to be taken');
          }else if(profileName == 'IBL State Credit Manager'){ 
            String errorMessage = System.Label.SanctionAMLErrorMsg + ' ' +'SCM for action';
            errorList.add(errorMessage);
          }else{
            String errorMessage = System.Label.SanctionAMLErrorMsg + ' ' +'CMU Queue for action';//CISP-14029
            errorList.add(errorMessage);
          }
          }
            return errorList;
        }
        if(loanApplication.Product_Type__c != 'Tractor'){
          for (TeleVerification__c tvr : [Select id,Case__r.Status From TeleVerification__c Where Loan_Application__c = :loanAppId AND Case__r.RecordTypeId =:tvrRecordTypeId AND Loan_Application__r.Product_Type__c  != 'Passenger Vehicles' WITH SECURITY_ENFORCED LIMIT 100]){
            if (tvr.Case__r.status != System.Label.Pass){
              errorList.add(System.Label.SanctionTVRErrorMsg);
              return errorList;
            }
          }
        }
        
        for (CAM__C cam : [Select id, Proposal_Status__c from CAM__C where Loan_Application__c = :loanAppId WITH SECURITY_ENFORCED LIMIT 100]){
          if (cam.Proposal_Status__c != System.Label.Accept){
            errorList.add(System.Label.SanctionCAMErrorMsg);
            return errorList;
          }
        }

        Boolean isAllCMUCasesClosed =  true;
        String cmuRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.CMURequest).getRecordTypeId();
        for(Case caseObj : [Select Id,Status From Case Where Loan_Application__c = :loanAppId AND RecordTypeId = :cmuRecordTypeId With SECURITY_ENFORCED LIMIT 100]){
          //INDI-4707 - START
          if(caseObj.Status == 'Pending with CMU'){
            isAllCMUCasesClosed = false;
            errorList.add(System.Label.SanctionKYCErrorMsg.replace('{0}', loanApplication.Lead_Number__c));
          }else if(caseObj.Status == 'Pending with Sales'){
            isAllCMUCasesClosed = false;
            errorList.add(System.Label.SanctionKYCSalesErrorMsg);
          }else if(caseObj.Status != 'Closed'){ // CISP-136 -- Added new if condition for not closed status - START
            isAllCMUCasesClosed = false;
            errorList.add(System.Label.SanctionKYCErrorMsgOld);
          }// CISP-136 -- Added new if condition for not closed status - END
          //INDI-4707 - END
        }
        if(!isAllCMUCasesClosed){
          return errorList; // INDI-4707 Removed add error message from here.
        }
        
        String offRoleRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Off_Role_Emp_Approval).getRecordTypeId();
        Boolean offRoleEmpApproval = true;
        for(Case caseRef : [Select Id,Status,Loan_Application__r.Approval_of_app_sourced_by_off_roll_emp__c From Case Where Loan_Application__c = :loanAppId AND RecordTypeId = :offRoleRecordTypeId With SECURITY_ENFORCED LIMIT 100]){
          if(caseRef.Status != System.Label.Closed || !caseRef.Loan_Application__r.Approval_of_app_sourced_by_off_roll_emp__c){
            offRoleEmpApproval = false;
          } 
        }
        if(!offRoleEmpApproval){
          errorList.add(System.Label.SanctionOffRoleErrorMsg);
          return errorList;
        }
        for (Applicant__c applicant : applicantMap.values()){
          if(applicant.Opportunity__r.Product_Type__c == Label.Tractor){
            if(!applicant.Application_Consent_Received__c && applicant.Applicant_Type__c == System.Label.Beneficiary && applicant.IsPrimary__c == true && applicant.Opportunity__r.Customer_Type__c == 'Non-Individual'){
              errorList.add(System.Label.SanctionAppFormConsentErrorMsg);
              break;
            }else if(!applicant.Application_Consent_Received__c && applicant.Applicant_Type__c == System.Label.Beneficiary && applicant.IsPrimary__c == true && applicant.Opportunity__r.Customer_Type__c == 'Non-Individual' && applicant.Opportunity__r.Entity_Type__c == 'Proprietorship'){
              errorList.add(System.Label.SanctionAppFormConsentErrorMsg);
              break;
            }else if(!applicant.Application_Consent_Received__c && applicant.Opportunity__r.Customer_Type__c == 'Individual'){
              errorList.add(System.Label.SanctionAppFormConsentErrorMsg);
              break;
            }
            if (!applicant.Insurance_Consent_Received__c && applicant.Insurance_Details__r.size() > 0){
              errorList.add(System.Label.SanctionInsConsentErrorMsg);
              break;
            }
          }else{
            if (!applicant.Application_Consent_Received__c){
              errorList.add(System.Label.SanctionAppFormConsentErrorMsg);
            }
            if (!applicant.Insurance_Consent_Received__c && applicant.Insurance_Details__r.size() > 0){
              errorList.add(System.Label.SanctionInsConsentErrorMsg);
            }
          }
        }
        if (errorList.size() > 0){
          return errorList;
        }

        if(loanApplication.Product_Type__c == 'Tractor'){
          loanApplication.Sanction_Date__c = date.today();
          update loanApplication;
          resultList.add(System.Label.Approved.toLowerCase());
          return resultList;
        }
        else{
          if (Schema.sObjectType.Opportunity.isUpdateable()){
            for (Applicant__c applicant : applicantMap.values()){
              // Send an sms for the valid applicant using sms api.
              String app_str = smsWrapper(applicant);
              if (!Test.isRunningTest())
                Object obj = IntegrationEngine.doSmsGatewayAPI(app_str);
            }
            // Updated the loan application and flow will run and send an email.
            loanApplication.Sanction_Message_Triggered__c = true;
            loanApplication.Sanction_Date__c = date.today();
            update loanApplication;
            resultList.add(System.Label.Approved.toLowerCase());
            return resultList;
          }else{
            resultList.add(String.valueof(false));
            return resultList;
          }
        }
        
      }
     }else{
        resultList.add(System.Label.OriginalKycDocumentNotAvailable);
        return resultList;
      }     
      resultList.add(String.valueof(false));
      return resultList;
    }
    } 
      catch (Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'triggerSanctionCommunication', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }

/*
* @Method:      smsWrapper
* @Created by:  Gaurav Rawat 
* @Description: This method is used to get the final term record id.
* @Param:       Applicant__c - applicant
* @Return:      String - Wrapperclass
*/
  public static String smsWrapper(Applicant__c applicant){
    Wrapperclass obj = new Wrapperclass(applicant);
    String smsStr = JSON.serialize(obj);
    return smsStr;
  }
/*
* @Class:      Wrapperclass
* @Created by:  Gaurav Rawat 
* @Description: This class is used to wrap the applicant object and send it to the sms api.
*/
  // Wrapper class for the sms api.
  public class Wrapperclass{
    public string loanApplicationId;
    public string flag;
    public string applicantId;
    public string applicationNo;
    public Wrapperclass(Applicant__c app){
      this.loanApplicationId = app.Opportunity__c;
      this.flag = System.Label.SA_Flag;
      this.applicantId = app.Id;
      this.applicationNo = app.Opportunity__r.Lead_number__c;
    }

  }

/*
* @Method:      getFinalTermRecordId
* @Created by:  Gaurav Rawat 
* @Description: This method is used to get the final term record id.
* @Param:       String - loanAppId
* @Return:      String - Final_Term__c.Id
*/
  @AuraEnabled
  public static String getFinalTermRecordId(String loanId){
    try{
      List<Final_Term__c> finalTermList = new List<Final_Term__c>([Select Id, name From Final_Term__c Where Loan_Application__c = :loanId WITH SECURITY_ENFORCED LIMIT 1]);
      if (finalTermList.size() > 0){
        return finalTermList[0].Id;
      }
      return null;
    } catch (Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'getFinalTermRecordId', System.Label.Apex, e, loanId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
/*
* @Method:      getOppRecord
* @Created by:  Gaurav Rawat 
* @Description: This method is used to get the opp term record.
* @Param:       String - loanAppId
* @Return:      List<Opportunity>
*/
  @AuraEnabled
  public static List<Opportunity> getOppRecord(String loanId){
      return [Select Product_Type__c From Opportunity Where Id = :loanId WITH SECURITY_ENFORCED LIMIT 1];
  }

/*
* @Method:      getDisabledBtn
* @Created by:  Gaurav Rawat 
* @Description: This method is used to check the trigger button is disabled or not.
* @Param:       String - loanAppId
* @Return:      BtnDisableWrapper -- btnDisableWrapperObj
*/
  @AuraEnabled
  public static BtnDisableWrapper getDisabledBtn(String loanAppId){
    try{
      BtnDisableWrapper btnDisableWrapperObj = new BtnDisableWrapper();
      Boolean triggerDisabled = false;
      Boolean submitDisabled = false;
      Integer tabSequence = 0;
      String subStage = null;

      for (Opportunity loanApp : [Select Id, Sanction_Message_Triggered__c, Sanction_Date__c, StageName, Sub_Stage__c From Opportunity Where id = :loanAppId With SECURITY_ENFORCED LIMIT 1]){
        if (loanApp.Sanction_Message_Triggered__c == true){
          triggerDisabled = true;
        }
        subStage = loanApp.Sub_Stage__c;
      }
      
      if (subStage != null){
        for (Webapp_Tab_Settings__mdt webApp : [Select Id, Label, Sanction_Status__c, Stage__c, Sub_Stage__c, Tab_Sequence__c,Vehicle_Category__c, Product_Type__c from Webapp_Tab_Settings__mdt where Sub_Stage__c = :subStage With SECURITY_ENFORCED LIMIT 100]){
          tabSequence = Integer.valueof(webApp.Tab_Sequence__c);
        }
      }
      submitDisabled = tabSequence > 12 ? true : subStage != 'Sanction of Application' ? true :  false;
      btnDisableWrapperObj.triggerDisabled = triggerDisabled;
      btnDisableWrapperObj.submitDisabled = submitDisabled;
      return btnDisableWrapperObj;
    } catch (Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'getDisabledBtn', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }

/*
* @Class:      BtnDisableWrapper
* @Created by:  Gaurav Rawat
*/
  public class BtnDisableWrapper{
    @AuraEnabled
    public Boolean triggerDisabled{get;set;}
    @AuraEnabled
    public Boolean submitDisabled{get;set;}
  }
   /*
* @Method:      initilizeEmailRequestWrapper
* @Created by:  Gaurav Rawat 
* @Description: This method is used to initialize the email request wrapper.
* @Param:       String - loanAppId
* @Return:      List<RequestWrapper> - emailRequestWrapperList
*/
  @AuraEnabled
  public static List<RequestWrapper> initilizeEmailRequestWrapper(String loanAppId){
    try{
      List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
      for(Applicant__c applicant : [Select Id,Opportunity__c,Opportunity__r.Lead_Number__c,Email_Id__c,Customer_First_Name__c FROM Applicant__c WHERE Opportunity__c = :loanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 10]){
        RequestWrapper emailRequestWrapper = new RequestWrapper();
        emailRequestWrapper.loanApplicationId = applicant.Opportunity__c;
        emailRequestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c;
        emailRequestWrapper.emailTo = applicant.Email_Id__c;
        emailRequestWrapper.emailCC =  applicant.Email_Id__c;
        emailRequestWrapper.emailSubject = System.Label.SanctionApplicationEmailTitle.replace('{!Applicant__c.Customer_First_Name__c}', applicant.Customer_First_Name__c);
        emailRequestWrapper.emailBody = System.Label.Sanction_of_Application_Email.replace('{!Opportunity.Lead_number__c}', applicant.Opportunity__r.Lead_Number__c);
        emailRequestWrapperList.add(emailRequestWrapper);
      }
      return emailRequestWrapperList;
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'initilizeEmailRequestWrapper', System.Label.Apex, e,loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
/*
* @Method:      isConsentReceived
* @Created by:  Gaurav Rawat 
* @Description: This method is used to check the application consent and insurance consent received or not.
* @Param:       String - loanApplicationId
* @Return:      ConsentReceivedWrapper
*/
  @AuraEnabled
  public static List<ConsentReceivedWrapper> isConsentReceived(String loanApplicationId){
    try {
      List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>();
      for(Vehicle_Detail__c vehicleObj : [Select id,(Select Id,Applicant__c from Insurance_Details__r WHERE Applicant__r.Insurance_Consent_Received__c = false) from Vehicle_Detail__c where Loan_Application__c =: loanApplicationId AND Loan_Application__r.Product_Type__c =: System.Label.Tractor LIMIT 5]){
        if(vehicleObj.Insurance_Details__r.size() > 0){
          vehicleList.add(vehicleObj);
        }
      }
      List<Applicant__c> applicantList  = new List<Applicant__c>();
      Opportunity  opty = [SELECT Id,Product_Type__c,Customer_Type__c,Entity_Type__c FROM Opportunity WHERE Id =:loanApplicationId];
      if(opty != null && opty.Product_Type__c == Label.Tractor && opty.Customer_Type__c == 'Non-Individual' && opty.Entity_Type__c == 'Proprietorship'){
        applicantList = [Select Id,Applicant_Type__c,Insurance_Consent_Received__c,Application_Consent_Received__c,(Select Id,Vehicle_Detail__c From Insurance_Details__r) from Applicant__c where Opportunity__r.Id = :loanApplicationId and In_Active_Applicant__c =false AND ((Applicant_Type__c = 'Borrower') OR (Applicant_Type__c = 'Beneficiary' AND IsPrimary__c = true))];
      }else if(opty != null && opty.Product_Type__c == Label.Tractor && opty.Customer_Type__c == 'Non-Individual'){
        applicantList = [Select Id,Applicant_Type__c,Insurance_Consent_Received__c,Application_Consent_Received__c,(Select Id,Vehicle_Detail__c From Insurance_Details__r) from Applicant__c where Opportunity__r.Id = :loanApplicationId and In_Active_Applicant__c =false AND Applicant_Type__c = 'Beneficiary' AND IsPrimary__c = true];
      }else{
        applicantList = [Select Id,Applicant_Type__c,Insurance_Consent_Received__c,Application_Consent_Received__c,(Select Id,Vehicle_Detail__c From Insurance_Details__r) From Applicant__c WHERE Opportunity__c = :loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 100];
      }

      List<ConsentReceivedWrapper> consentReceivedWrapperList = new List<ConsentReceivedWrapper>();
      for(Applicant__c applicant : applicantList){
        ConsentReceivedWrapper consentReceivedWrapper = new ConsentReceivedWrapper();
        consentReceivedWrapper.applicationConsentReceived = applicant.Application_Consent_Received__c;
        consentReceivedWrapper.insuranceConsentReceived = applicant.Insurance_Details__r.size() > 0 ? applicant.Insurance_Consent_Received__c : true;
        consentReceivedWrapper.applicantType = applicant.Applicant_Type__c;
        consentReceivedWrapper.vehicleListWrapper = vehicleList;
        consentReceivedWrapper.applicantId = applicant.Id;
        consentReceivedWrapperList.add(consentReceivedWrapper);
      }
      return consentReceivedWrapperList;
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'isConsentReceived', System.Label.Apex, e,loanApplicationId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
   /*
* @Class:      ConsentReceivedWrapper
* @Created by:  Gaurav Rawat 
*/
  public class ConsentReceivedWrapper{
    @auraEnabled
    public Boolean applicationConsentReceived{get;set;}
    @auraEnabled
    public Boolean insuranceConsentReceived{get;set;}
    @auraEnabled
    public String applicantType{get;set;}
    @auraEnabled
    public String applicantId{get;set;}
    @auraEnabled
    public List<Vehicle_Detail__c> vehicleListWrapper{get;set;}
  }
  /*
* @Method:      getapplicationDetails
* @Created by:  Abhishek Yadav
* @Description: This method return Applicant Application Consent Received & Application Consent Received  details in a wrappper
* @Param:       String - loanApplicationId
* @Return:      applicantDetails - Wrapper data
*/
    @AuraEnabled(cacheable = true)
    public static applicantDetails getApplicantDetails(String loanId){
        try {
            applicantDetails applicantDetails = new applicantDetails();
           
            Map<String,String> borrowerCoborrowerMap = new Map<String,String>();
            Boolean isTractor = false;
            for(Applicant__c applicants : [SELECT Id,Applicant_Type__c,Application_Consent_Received__c,Insurance_Consent_Received__c,Opportunity__r.Product_Type__c ,(Select Id From Insurance_Details__r),IsPrimary__c,Opportunity__r.Customer_Type__c,Opportunity__r.Entity_Type__c FROM Applicant__c WHERE Opportunity__c = :loanId AND   In_Active_Applicant__c = false  WITH SECURITY_ENFORCED]){ // (Opportunity__r.Product_Type__C + In_Active_Applicant__c = false --- CISP-18025 - bug OR SFTRAC-376 )
              if(applicants.Opportunity__r.Product_Type__c == Label.Tractor){
                isTractor = true;
                if(((applicants.Applicant_Type__c == System.Label.Borrower || (applicants.Applicant_Type__c == System.Label.CoBorrower)) && applicants.Opportunity__r.Customer_Type__c == 'Individual') || (applicants.Applicant_Type__c == System.Label.Beneficiary && applicants.Opportunity__r.Customer_Type__c == 'Non-Individual' && applicants.IsPrimary__c == true)){
                  if(applicants.Insurance_Details__r.size() > 0 && applicants.Insurance_Consent_Received__c == false){
                    if(borrowerCoborrowerMap.containsKey('tractorInsuranceformconsent')){
                      String insStr = borrowerCoborrowerMap.get('tractorInsuranceformconsent') + ', ' + applicants.Applicant_Type__c + ' - Pending';
                      borrowerCoborrowerMap.put('tractorInsuranceformconsent',insStr);
                    }else{
                      borrowerCoborrowerMap.put('tractorInsuranceformconsent',applicants.Applicant_Type__c + ' - Pending');
                    }
                  }else if(applicants.Insurance_Details__r.size() > 0 && applicants.Insurance_Consent_Received__c == true){
                    if(borrowerCoborrowerMap.containsKey('tractorInsuranceformconsent')){
                      String insStr = borrowerCoborrowerMap.get('tractorInsuranceformconsent') + ', ' + applicants.Applicant_Type__c + ' - Completed';
                      borrowerCoborrowerMap.put('tractorInsuranceformconsent',insStr);
                    }else{
                      borrowerCoborrowerMap.put('tractorInsuranceformconsent',applicants.Applicant_Type__c + ' - Completed');
                    }
                  }else{
                    if(borrowerCoborrowerMap.containsKey('tractorInsuranceformconsent')){
                      String insStr = borrowerCoborrowerMap.get('tractorInsuranceformconsent') + ', ' + applicants.Applicant_Type__c + ' - NA';
                      borrowerCoborrowerMap.put('tractorInsuranceformconsent',insStr);
                    }else{
                      borrowerCoborrowerMap.put('tractorInsuranceformconsent',applicants.Applicant_Type__c + ' - NA');
                    }
                  }
                }
              }
                if(applicants.Applicant_Type__c == System.Label.Borrower){
                  if(applicants.Opportunity__r.Product_Type__c == 'Tractor'){
                    if((applicants.Opportunity__r.Customer_Type__c == 'Individual') || (applicants.Opportunity__r.Customer_Type__c == 'Non-Individual' && applicants.Opportunity__r.Entity_Type__c == 'Proprietorship')){
                      borrowerCoborrowerMap.put('borrowerApplicationformconsent',applicants.Application_Consent_Received__c == true ? 'Borrower - Completed' : 'Borrower - Pending');
                    }
                  }else{
                  applicantDetails.borrowerApplicantId = applicants.Id;
                    borrowerCoborrowerMap.put('borrowerApplicationformconsent',applicants.Application_Consent_Received__c == true ? 'Borrower - Completed' : 'Borrower - Pending');
                     borrowerCoborrowerMap.put('borrowerInsuranceformconsent',applicants.Insurance_Details__r.size() > 0 && applicants.Insurance_Consent_Received__c == true ? 'Borrower - Completed' : applicants.Insurance_Details__r.size() > 0 && applicants.Insurance_Consent_Received__c == false ? 'Borrower - Pending' : 'Borrower - NA');
                  }
                }else if(applicants.Applicant_Type__c == System.Label.CoBorrower){
                  applicantDetails.coBorrowerApplicantId = applicants.Id;
                  if(applicants.Opportunity__r.Product_Type__c == 'Tractor'){
                      
                    
                    if(!borrowerCoborrowerMap.containsKey('coBorrowerApplicationformconsent') && applicants.Opportunity__r.Customer_Type__c == 'Individual'){
                        borrowerCoborrowerMap.put('coBorrowerApplicationformconsent' , applicants.Application_Consent_Received__c == true ? 'Coborrower - Completed' : 'Coborrower - Pending');
                    }
                    else if(applicants.Opportunity__r.Customer_Type__c == 'Individual'){
                        borrowerCoborrowerMap.put('coBorrowerApplicationformconsent' , borrowerCoborrowerMap.get('coBorrowerApplicationformconsent')+', '+ (applicants.Application_Consent_Received__c == true ? 'Coborrower - Completed' : 'Coborrower - Pending'));
                    }             
                 }
                  else{
                    borrowerCoborrowerMap.put('coBorrowerApplicationformconsent' ,applicants.Application_Consent_Received__c == true ? 'Coborrower - Completed' : 'Coborrower - Pending');
                    borrowerCoborrowerMap.put('coBorrowerInsuranceformconsent',applicants.Insurance_Details__r.size() > 0 && applicants.Insurance_Consent_Received__c == true ? 'Coborrower - Completed' : applicants.Insurance_Details__r.size() > 0 && applicants.Insurance_Consent_Received__c == false ? 'Coborrower - Pending' : 'Coborrower - NA');
              
                  }
                }else if(applicants.Applicant_Type__c == System.Label.Beneficiary && applicants.IsPrimary__c == true && applicants.Opportunity__r.Product_Type__c == Label.Tractor && applicants.Opportunity__r.Customer_Type__c == 'Non-Individual' && applicants.Opportunity__r.Entity_Type__c == 'Proprietorship'){
                  borrowerCoborrowerMap.put('beneficiaryApplicationformconsent' ,applicants.Application_Consent_Received__c == true ? 'Beneficiary - Completed' : 'Beneficiary - Pending');
                }else if(applicants.Applicant_Type__c == System.Label.Beneficiary && applicants.IsPrimary__c == true && applicants.Opportunity__r.Product_Type__c == Label.Tractor && applicants.Opportunity__r.Customer_Type__c == 'Non-Individual'){
                  borrowerCoborrowerMap.put('beneficiaryApplicationformconsent' ,applicants.Application_Consent_Received__c == true ? 'Beneficiary - Completed' : 'Beneficiary - Pending');
                }else if(applicants.Applicant_Type__c == System.Label.Guarantor && applicants.Opportunity__r.Product_Type__c == Label.Tractor && applicants.Opportunity__r.Customer_Type__c == 'Individual'){
                  borrowerCoborrowerMap.put('guarantorApplicationformconsent' ,applicants.Application_Consent_Received__c == true ? 'Guarantor - Completed' : 'Guarantor - Pending');
                }
            }
            applicantDetails.applicationformconsent = !borrowerCoborrowerMap.containsKey('coBorrowerApplicationformconsent') ? borrowerCoborrowerMap.get('borrowerApplicationformconsent') : (borrowerCoborrowerMap.get('borrowerApplicationformconsent')+', '+borrowerCoborrowerMap.get('coBorrowerApplicationformconsent'));
            if(borrowerCoborrowerMap.containsKey('beneficiaryApplicationformconsent')){
              applicantDetails.applicationformconsent = String.isNotBlank(applicantDetails.applicationformconsent) ? applicantDetails.applicationformconsent + ', ' + borrowerCoborrowerMap.get('beneficiaryApplicationformconsent') : borrowerCoborrowerMap.get('beneficiaryApplicationformconsent');
            }
            if(borrowerCoborrowerMap.containsKey('guarantorApplicationformconsent')){
              applicantDetails.applicationformconsent = applicantDetails.applicationformconsent + ', ' + borrowerCoborrowerMap.get('guarantorApplicationformconsent');
            }
            if(isTractor){
              applicantDetails.insuranceformconsent = borrowerCoborrowerMap.containsKey('tractorInsuranceformconsent') ? borrowerCoborrowerMap.get('tractorInsuranceformconsent') : '';
            }else{
            applicantDetails.insuranceformconsent = borrowerCoborrowerMap.containsKey('borrowerInsuranceformconsent') && !borrowerCoborrowerMap.containsKey('coBorrowerInsuranceformconsent') ? borrowerCoborrowerMap.get('borrowerInsuranceformconsent') : !borrowerCoborrowerMap.containsKey('borrowerInsuranceformconsent') && borrowerCoborrowerMap.containsKey('coBorrowerInsuranceformconsent') ? borrowerCoborrowerMap.get('coBorrowerInsuranceformconsent') : (borrowerCoborrowerMap.get('borrowerInsuranceformconsent')+', '+borrowerCoborrowerMap.get('coBorrowerInsuranceformconsent'));
            System.debug('applicantDetails  '+applicantDetails);
            }
            return applicantDetails;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'getApplicantDetails', System.Label.Apex, e,loanId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
* @Class:      applicantDetails
* @Created by:  Abhishek Yadav
* @Description: This class is used to get the Applicant details.
*/
    // Wrapper class for application form details
    public class applicantDetails {
        @AuraEnabled
        public String borrowerApplicantId{get;set;}
        @AuraEnabled
        public String coBorrowerApplicantId{get;set;}
        @AuraEnabled
        public String applicationformconsent{get;set;}
        @AuraEnabled
        public String insuranceformconsent{get;set;}
        
    }
// @Created by: Gaurav Rawat
// @Description: Used to check documents
    public class DocumentWrappers{
      public boolean presentPOA;
      public boolean presentPOI;
      public boolean presentPAN;
      public boolean presentForm60;  
      public String customerType;
      public String applicantType;           
  }
}