/**
* @Name         ApplicantResourceBiometric
* @Author       Khushiram
* @Company      Persistent Systems
* @Description  PATCH Method to update Applicant using REST Api
* Inputs:       None
* Test Class:   
* History: 
*/

// Setting up the Request URL
@RestResource(urlMapping='/ApplicantBiometricAPI/*')
global with sharing class ApplicantResourceBiometric{
  // PATCH Method
  @HTTPPatch
  global static void updateApplicant() {
    try{
      RestRequest applicantRequest = RestContext.request;
      String applicantUpdateResponseString = applicantRequest.requestBody.toString();    
      String applicantRequestURI = applicantRequest.requestURI;
      String applicantId = applicantRequestURI.substring(applicantRequestURI.lastIndexOf('/') + 1);
      
      // Getting the request body from the request
      String requestBody = applicantRequest.requestBody.toString();
      
      Applicant__c applicant;
      
      
      ApplicantUpdateWrapper[] errs;
      if(String.isNotEmpty(applicantId)) {
        
      applicant = (Applicant__c) JSON.deserialize(requestBody, Applicant__c.class);
      applicant.Id = applicantId;
      System.debug('applicant value' +applicant.PID_Block__c);
      System.debug('applicant value22' +Applicant__c.fields);
	  //Applicant__c appObj = [Select id, from Applicant__c where id = applicant.id];
      if (Schema.sObjectType.Applicant__c.isUpdateable()){
        System.debug('applicant value update' +applicant.PID_Block__c);
        update applicant;
      }
         
	 System.debug('applicant value sd' +applicant.PID_Block__c); 
          
      if(applicant.PID_Block__c != null && (String.isNotEmpty(applicant.PID_Block__c)) && applicant.PID_Block__c !=' ' && (String.isNotBlank(applicant.PID_Block__c)) ){
        String successMsg = 'Lead record updated successfully ';
        RestContext.response.statusCode = 200;
        errs = new ApplicantUpdateWrapper[]{ 
          new ApplicantUpdateWrapper('200', successMsg)
        };
      }
      else if(applicant.PID_Block_Error_Response__c != null && (applicant.PID_Block__c == null || String.isEmpty(applicant.PID_Block__c) || applicant.PID_Block__c =='')){
        String successMsg = 'Biometric device is not working properly please try again ';
        RestContext.response.statusCode = 200;
        errs = new ApplicantUpdateWrapper[]{ 
          new ApplicantUpdateWrapper('200', successMsg)
        };
      }
      else{
        //String successMsg = 'Something went wrong please try again';
        RestContext.response.statusCode = 200;
        errs = new ApplicantUpdateWrapper[]{ 
          //new LeadCustomErrorHandler('200', successMsg)
        };
      }

      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
      //Utility.insertAPILog('RD_Service_Log__c','LeadAPI', applicantId, applicantUpdateResponseString, JSON.serialize(errs), 'https://kotak--klmsdev1.my.salesforce.com/services/apexrest/LeadAPI/');
    }}
    catch(Exception e){
      RestContext.response.statusCode = 200;
        ApplicantUpdateWrapper[] errs = new ApplicantUpdateWrapper[]{ 
        new ApplicantUpdateWrapper('200', e.getMessage())
          
      };  
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    } 
  }
    
    
    public class ApplicantUpdateWrapper {
        public String errorCode;
        public String message;
        
        public ApplicantUpdateWrapper(String errorCode, String message){
            this.errorCode = errorCode;
            this.message = message;
      }
    }
}