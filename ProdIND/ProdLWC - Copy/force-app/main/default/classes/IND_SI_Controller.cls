/* 
 @File Name : IND_SI_Controller.cls 
 @Description :  Controller class for Online/Offline SI Repayment Mandate
 @Author : Yogesh Rao 
 @Last Modified By : Yogesh Rao 
 @Last Modified On : 08 May 2022 
 @Modification Log : 
 ============================================================================== 
 Ver        Date          Author       Modification 
 ============================================================================== 
 1.0     08 May 2022    Yogesh Rao   Initial Version 
*/
public with sharing class IND_SI_Controller {
  /* 
     @description :   Method to Generate/Get SI URL
     @param :  String loanId
     @param :  String applicantId
     @param :  String repaymentId 
     @return : Url
    */
  @AuraEnabled
  public static string getSIUrl(String loanId, String applicantId, String repaymentId) {
    String staticUrl = System.Label.SI_Static_URL;
    String requestBody;
    String url;
    try {
      requestBody = generateSIRequest(loanId, applicantId, repaymentId);
      url = staticUrl + getEncryptedString(requestBody);
      url = url + '&source=sf'; 
      return url;
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('IND_SI_Controller','getSIUrl', System.Label.Apex, e,loanId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }

  /* 
     @description :   Method to form request body
     @param :  String loanId
     @param :  String applicantId
     @param :  String repaymentId
     @return :  JSON request string
    */
  public static String generateSIRequest(String loanId, String applicantId, String repaymentId) {
    try{
      List<Repayments__c> repayment = [SELECT Frequency__c, EMI_Amount__c, Created_Date__c, End_Date__c,Until_Cancelled__c FROM Repayments__c WHERE Id = :repaymentId WITH SECURITY_ENFORCED];
      List<Opportunity> loan = [SELECT Deal_Number__c, Customer_Code__c, Loan_Application_Number__c FROM Opportunity WHERE Id = :loanId WITH SECURITY_ENFORCED];
      List<Applicant__c> appl = [SELECT Contact_number__c,Customer_Code__c FROM Applicant__c WHERE Id = :applicantId WITH SECURITY_ENFORCED];
      User currentUser = [SELECT Maker_Id__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
      if (repayment.isEmpty() || loan.isEmpty() || appl.isEmpty()) {
        throw new IND_Exception('Repayment, Loan, Applicant is mandatory');
      }
      validateFields(repayment[0], loan[0], appl[0]);
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
      gen.writeStringField('AppNo', String.valueOf(loan[0].Deal_Number__c));
      gen.writeStringField('Customer_Code', String.valueOf(appl[0].Customer_Code__c));
      gen.writeStringField('DealNo', String.valueOf(loan[0].Deal_Number__c));
      gen.writeStringField('Debit_Frequency', String.valueOf(repayment[0].Frequency__c));
      gen.writeStringField('EMI_Amount', String.valueOf(repayment[0].EMI_Amount__c));
      gen.writeStringField('Reference_No', String.valueOf(loan[0].Loan_Application_Number__c));
      gen.writeStringField('EMI_Start_Date', String.valueOf(repayment[0].Created_Date__c));
      gen.writeStringField('EMI_End_Date', String.valueOf(repayment[0].End_Date__c));
      gen.writeNumberField('MakerId', Integer.valueOf(currentUser.Maker_Id__c));
      gen.writeStringField('MobileNumber', String.valueOf(appl[0].Contact_number__c));
      gen.writeEndObject();
      return gen.getAsString();
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_SI_Controller','generateSIRequest', System.Label.Apex, e,loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
  /* 
     @description :   Method to get Encoded Cipher Text
     @param :  String jsonString
     @return : Cipher Text
    */
  public static String getEncryptedString(String jsonString) {
    try{
      String key = System.Label.SI_Request_Private_Key;
      Blob privateKey = Blob.valueOf(IntegrationUtilities.getAPIKeys(System.Label.privateKey));
      Blob ivkey = Blob.valueOf(IntegrationUtilities.getAPIKeys(System.Label.ivkey)); 
      String encodedCipherText = EncodingUtil.base64Encode(Crypto.encrypt('AES256', privateKey, ivKey, Blob.valueOf(jsonString)));
      encodedCipherText = encodedCipherText.replace('+', '_');
      encodedCipherText = encodedCipherText.replace('/', '-');
      encodedCipherText = encodedCipherText.replace('=', '%24');
      return encodedCipherText;
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_SI_Controller','getEncryptedString', System.Label.Apex, e);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
  /* 
     @description :   Method to validate fields, before creating request
     @param :  Repayments__c repayment
     @param :  Opportunity loan
     @param :  Applicant__c appl
     @return : Void
    */
  public static void validateFields(Repayments__c repayment, Opportunity loan, Applicant__c appl) {
    try{
      if (repayment?.Frequency__c == null) {
        throw new IND_Exception('Debit Frequency is mandatory');
      }
      if (repayment?.EMI_Amount__c == null) {
        throw new IND_Exception('EMI Amount is mandatory');
      }
      if (repayment?.Created_Date__c == null) {
        throw new IND_Exception('EMI Start Date is mandatory');
      }
      if (repayment?.End_Date__c == null) {
        throw new IND_Exception('EMI End Date is mandatory');
      }
      if (loan?.Deal_Number__c == null) {
        throw new IND_Exception('Deal Number is mandatory');
      }
      if (appl?.Customer_Code__c == null) {
        throw new IND_Exception('Customer Code is mandatory');
      }
      if (loan?.Loan_Application_Number__c == null) {
        throw new IND_Exception('Loan Application Number is mandatory');
      }
      if (appl?.Contact_number__c == null) {
        throw new IND_Exception('Applicant Contact Number is mandatory');
      }
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('IND_SI_Controller','validateFields', System.Label.Apex, e,loan.Id);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }

  /* 
     @description :   Method to validate SI Docs
     @param :  String loanApplicationId
     @return : Boolean
    */
  @AuraEnabled
  public static Boolean validateSIDocs(String loanApplicationId) {
    Boolean isAllDocsAvailable = true;
    List<ContentDocument> listOfSIFormDocs = new List<ContentDocument>();
    try {
      Map<String, Object> siWrap = IND_DatatableCntrl.getACHDocuments(loanApplicationId, 'SI Form', 100);
      listOfSIFormDocs = (List<ContentDocument>) siWrap.get('records');
      if (listOfSIFormDocs.size() == 0) {
        isAllDocsAvailable = false;
      }
      return isAllDocsAvailable;
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('IND_SI_Controller', 'validateSIDocs', System.Label.Apex, e, loanApplicationId);
      throw new IND_Exception(e.getMessage());
    }
  }
}