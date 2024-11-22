/**
* @Name         DateTimeHandle
* @Author       Ruchi Jain
* @Company      Persistent Systems
* @Description   A  class for the visiualforce Page
* Inputs:       None
* Test Class:   DateTimeHandleTest
* History:
* 27/10/2021 Ruchi Jain Added enableCheckbox method. 
*/
public class DateTimeHandle {
    /**
* @description to store error description
*/
    public string errorDescription {get;set;}
    public string successMessage {get;set;}
    public boolean hasError {get;set;}
	public boolean showWspRegisteredContent {get;set;}
    public  VfPageContent__mdt vfMetadata {get;set;}
    public string metadataContent1 {get;set;}
    public string metadataContent2 {get;set;}
    public string metadataContent3 {get;set;}
    public string currentRecordId {get; set;}
    public string otp {get; set;}//CISP-2927
     public Boolean buttonDisabled {get; set;}
     public string leadNumber {get; set;}
    public string sourcerCode {get; set;}
    public string sourcerName {get; set;}

    /**
* @description constructor for the class
*/
    public DateTimeHandle(ApexPages.StandardController controller) {
        hasError = false;
        errorDescription = null;
        successMessage = null;
        showWspRegisteredContent=true;
        buttonDisabled=false;
        VfPageContent__mdt vfMetadata=[select id,WspNotRegistered__c,WspRegisteredContent__c from VfPageContent__mdt where Label ='BodyContent'];
       	//Custom Metadata's getInstance() doesn't retrieve complete long text area fields 
        metadataContent1=vfMetadata.WspNotRegistered__c.substringBefore('I / We note that');
        metadataContent2=vfMetadata.WspNotRegistered__c.substringBetween('any specific consent.','I / We are aware');
        metadataContent3=vfMetadata.WspNotRegistered__c.substringBetween('towards the same.','I also agree');
        Applicant__c app = new Applicant__c();
       currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
       otp  = ApexPages.CurrentPage().getparameters().get('otp');//CISP-2927

        if(currentRecordId != null && otp != null){   //CISP-2927         
            app = [Select Id,Opportunity__r.Name,Opportunity__r.Owner.Name,Opportunity__r.Owner.Username, Consent_Received__c,Consent_Sent__c,Register_for_WhatsApp_Banking__c,OTP_for_borrower__c from Applicant__c WHERE Id = :currentRecordId limit 1];
            //As this is a Vf page Controller, this will be used by Guest user, thus not included with SECURITY_ENFORCED
            system.debug('to check : '+app.Id);
             leadNumber = app.Opportunity__r.Name;
            sourcerName = app.Opportunity__r.Owner.Name;
            sourcerCode = app.Opportunity__r.Owner.Username.substringBefore('@');
            Long currentDateTime = DateTime.now().getTime(); 
            Long consentSentOnDate = app.Consent_Sent__c.getTime();
            Long difference = (currentDateTime-consentSentOnDate)/60000;
            if(difference < 30 && app.Consent_Received__c && app?.OTP_for_borrower__c == otp){//CISP-2927
                hasError = true;
                errorDescription = System.label.ConsentReceived;
            }
            else if(difference >= 30 || app?.OTP_for_borrower__c != otp){//CISP-2927
                hasError = true;
               errorDescription = 'Time Expired!';
            }
              if(app.Register_for_WhatsApp_Banking__c){
                metadataContent1=vfMetadata.WspNotRegistered__c.substringBefore('I / We note that');
                metadataContent2=vfMetadata.WspNotRegistered__c.substringBetween('any specific consent.','I / We are aware');
                metadataContent3=vfMetadata.WspNotRegistered__c.substringAfter('towards the same.');
            }
            
        }else{
            hasError = true;
            errorDescription = System.label.NoRecord;
        }
       
    }
 
     /*
* @Method:      enableCheckbox
* @Created by: Ruchi Jain
* @Description: for enabling Consent Recieved Checkbox if current date & time is more than 30 min of Consent Sent field
* @Param:       None
* @Return:      None
*/
    public void enableCheckbox(){
        try{
           
            Applicant__c applicantObject = [Select Id, Consent_Sent__c,Register_for_WhatsApp_Banking__c, Consent_Received__c from Applicant__c WHERE Id = :currentRecordId limit 1];
            	
            Long currentDateTime = DateTime.now().getTime(); 
            Long consentSentOnDate = applicantObject.Consent_Sent__c.getTime();
            Long difference = (currentDateTime-consentSentOnDate)/60000;
            
            if(applicantObject.Consent_Received__c){
                    successMessage = null;
                    hasError = true;
                    errorDescription = System.label.ConsentReceived;
                }
            else if(difference < 30){
                applicantObject.Consent_Received__c = true;
               // if(Schema.sObjectType.Applicant__c.isCreateable()){
                    update applicantObject;
               // }
                if(buttonDisabled==true){
                    successMessage = null;
                    hasError = true;
                    errorDescription = System.label.ConsentReceived;
                }
                else if(applicantObject.Consent_Received__c == true && buttonDisabled==false){
                  successMessage = System.label.ConsentAccepted;
                  errorDescription = null;
                  buttonDisabled=true;
                }
            }else{
                hasError = true;
                errorDescription =  System.label.ConsentNotRecieved;
                successMessage = null;
            }
            if(applicantObject.Register_for_WhatsApp_Banking__c){
                showWspRegisteredContent=true;
            }
            if(Test.isRunningTest()){
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }
        catch(Exception e){
            system.debug('exc '+e.getMessage());
            ErrorLoggerUtil.logErrorEvent('DateTimeHandle', 'enableCheckbox', System.Label.Apex, e);
			throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
}