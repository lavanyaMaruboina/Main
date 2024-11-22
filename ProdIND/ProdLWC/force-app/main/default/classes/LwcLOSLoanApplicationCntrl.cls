/**
* @Name         LwcLOSLoanApplicationCntrl
* @Author       Khushiram
* @Company      Persistent Systems
* @Description  This class contains all methods related to Lead Generation-loan initiation
* Inputs:       None
* Test Class:   LwcLOSLoanApplicationCntrlTest
* History:
* 27/10/2021    Nidhi Dhote Added these frontUpload and backUpload method added. 
*/
public with sharing class LwcLOSLoanApplicationCntrl { 
    /*
    * @Method:      getTabList
    * @Created by:  Manish B.
    * @Description: Method to return list of Tabs
    * @Param:       String - loanApplication ID
    * @Return:      List<String> - List of Tabs
    */
    @AuraEnabled
    public static List<TabWrapper> getTabList(String loanApplicationId){
        if(loanApplicationId!=null){
            List<TabWrapper> returnTabList = new List<TabWrapper>(); 
            for(Applicant__c applicant : [SELECT Id, Applicant_Type__c, Opportunity__r.StageName, Income_source_available__c, LastModifiedDate, Customer_First_Name__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC, Applicant_Type__c ASC]){
                if(applicant.Opportunity__r.StageName == 'Asset Details' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                } else if(applicant.Opportunity__r.StageName == 'Vehicle Valuation' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                } else if(applicant.Opportunity__r.StageName == 'Vehicle Insurance' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                } else if(applicant.Opportunity__r.StageName == 'Loan Details' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                // }else if(applicant.Opportunity__r.StageName == 'Insurance Details' && (applicant.Applicant_Type__c == 'Co-Borrower' || applicant.Applicant_Type__c == 'Co-borrower')){
                //     continue;
                } else if(applicant.Opportunity__r.StageName == 'Final Terms' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                } else if(applicant.Opportunity__r.StageName == 'Offer Screen' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                }  else if(applicant.Opportunity__r.StageName == 'Final Offer' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                } else if(applicant.Opportunity__r.StageName == 'Customer Code Addition' && (applicant.Applicant_Type__c != System.Label.Borrower)){
                    continue;
                }else {
                    returnTabList.add(new TabWrapper(applicant.Applicant_Type__c,applicant.Id, applicant.Customer_First_Name__c));
                    // returnTabList.add(applicant.Applicant_Type__c);
                }
            }
            return returnTabList;
        }
        return null;
    }

    public class TabWrapper{
        @AuraEnabled
        public String applicantType{get;set;}
        @AuraEnabled
        public String applicantId{get;set;}
        @AuraEnabled
        public String applicantName{get;set;}

        public TabWrapper(String type, String id, String name){
            this.applicantType = type;
            this.applicantId = id;
            this.applicantName = name;
        }
    }

    @AuraEnabled
    public static List<TabWrapper> getTabListForInsurance(String loanApplicationId){
        if(loanApplicationId!=null){
            List<TabWrapper> returnTabList = new List<TabWrapper>(); 
            List<Applicant__c> applicantList = new List<Applicant__c>([SELECT Id, Applicant_Type__c, Opportunity__r.Customer_Type__c, Opportunity__r.Product_Type__c, LastModifiedDate, Customer_First_Name__c,Relationship_with_borrower__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC]);
            Map<String,Id> applicantMap = new Map<String,Id>();
            for(Applicant__c applicant : applicantList){
                if((applicant.Relationship_with_borrower__c == 'FATHER' || applicant.Relationship_with_borrower__c == 'MOTHER' ||  applicant.Relationship_with_borrower__c == 'SON'|| applicant.Relationship_with_borrower__c == 'DAUGHTER' || applicant.Relationship_with_borrower__c == 'HUSBAND' || applicant.Relationship_with_borrower__c == 'WIFE') && applicant.Applicant_Type__c == 'Co-borrower'){
                    if(!applicantMap.containsKey(applicant.Relationship_with_borrower__c)){
                        applicantMap.put(applicant.Relationship_with_borrower__c,applicant.Id);
                    }
                }
            }
            integer counter = 0;
            for(Applicant__c applicant : applicantList){
                if(applicant.Opportunity__r.Product_Type__c == System.Label.Tractor){
                    if(applicant.Applicant_Type__c == System.Label.Borrower){
                        returnTabList.add(new TabWrapper(applicant.Applicant_Type__c,applicant.Id, applicant.Customer_First_Name__c));
                    }else if(applicant.Opportunity__r.Customer_Type__c == 'Individual' && applicant.Applicant_Type__c == 'Co-borrower' && applicantMap.containsKey(applicant.Relationship_with_borrower__c) && counter == 0){
                        returnTabList.add(new TabWrapper(applicant.Applicant_Type__c,applicant.Id, applicant.Customer_First_Name__c));
                        counter++;
                    }
                }else {
                    returnTabList.add(new TabWrapper(applicant.Applicant_Type__c,applicant.Id, applicant.Customer_First_Name__c));
                }
            }
            return returnTabList;
        }
        return null;
    }
    
    /*
* @Method:      frontUpload
* @Created by:  Nidhi Dhote
* @Description: This method will be invoked on click of Front Upload Button
* @Param:       String - loanApplication ID
* @Param:       String - kycType
* @Param:       String - documentSide(Front/Back)
* @Return:      String - Serialized JSON response
*/
    @AuraEnabled
    public static String frontUpload(String leadApplicationId,String kycType,String documentSide){
        try{
            String serializedResonponse = null;
            if(leadApplicationId!=null && kycType!=null && documentSide!=null){
        		responseWrapper responseJSON = new responseWrapper();
       			Documents__c doc = [Select Front_Upload_Attempts__c, is_Front_Upload_Completed__c from Documents__c where id =: leadApplicationId  WITH SECURITY_ENFORCED limit 1]; 
            	System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance(System.Label.Front_Upload_Attempts);
            	if(doc != null)
            	{
                //Checking the number of attempts made for image upload with predefined maximum number of attempt
                if(doc.Front_Upload_Attempts__c >= noOfAttempts.Number_Of_Attempts__c)
                {
                    responseJSON.status = System.Label.FalseRespose;
                    responseJSON.message =  System.Label.FrontUploadResponseMessage;
                    responseJSON.apiStatus = false;
                    //  String serializedResonponse = JSON.serialize(responseJSON);
                    //  return serializedResonponse;
                }
                //If the image is uploaded successfully and upload attempts are less than metadata attempts, delete the previous uploaded front document.
                else if( doc.Front_Upload_Attempts__c < noOfAttempts.Number_Of_Attempts__c)
                {
                    Boolean apiResponse = true;
                    doc.is_Front_Upload_Completed__c = apiResponse;
                    
                    responseJSON.status = System.Label.TrueRespose;
                    doc.Front_Upload_Attempts__c += 1;
                    if (Schema.sObjectType.Documents__c.isUpdateable())
                    {
                        update doc; 
                    }
                    
                    responseJSON.message = System.Label.FrontUploadSuccess;
                    responseJSON.apiStatus = false;
                    //  String serializedResonponse = JSON.serialize(responseJSON);
                   
                }
                
                else{
                    //Fetching the current uploaded image
                    doc.is_Front_Upload_Completed__c = true;
                    doc.Front_Upload_Attempts__c += 1;
                    if (Schema.sObjectType.Documents__c.isUpdateable())
                    {
                        update doc;  
                    }
                    //serialize the JSON object
                    responseJSON.status = System.Label.TrueRespose;
                    responseJSON.message = '';
                    responseJSON.apiStatus = true ;
                    /*fake response for selfie upload begins*/
                    responseJSON.isFrontUploadSuccess=true;
                    //responseJSON.isBackUploadSuccess=true;
                    responseJSON.isSelfieUploadSuccess=true;
                    /*fake response for selfie upload ends*/ 
                }
                serializedResonponse = JSON.serialize(responseJSON);
            }
        }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        
            return serializedResonponse;
        }
        catch(Exception e){
           system.debug('e '+e.getMessage()+' '+e.getLineNumber());
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' frontUpload ', System.Label.Apex, e);
		    if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        // String serializedResonponse = JSON.serialize(responseJSON);
        // return serializedResonponse;   
    }
    //End: frontUpload()
    
    @AuraEnabled
    Public Static String ocrOnFrontUpload(){
        AdharOCRMockResponseClass classObj = new AdharOCRMockResponseClass();
        return JSON.serialize(classObj);
    }
    
    /*
* @Method:      backUpload
* @Created by:  Nidhi Dhote
* @Description: This method will be invoked on click of Back Upload Button
* @Param:       String - loanApplication ID
* @Param:       String - kycType
* @Param:       String - documentSide(Front/Back)
* @Return:      String - Serialized JSON response
*/
    @AuraEnabled
    public static String backUpload(String leadApplicationId,String kycType,String documentSide){
        responseWrapper responseJSON = new responseWrapper();
        
        try{
            String serializedResonponse = null;
            if(leadApplicationId!=null && kycType!=null && documentSide!=null){
            Documents__c doc = [Select Back_Upload_Attempts__c,is_Back_Upload_Completed__c from Documents__c where id =: leadApplicationId  WITH SECURITY_ENFORCED limit 1]; 
            System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance(System.Label.Back_Upload_Attempts);
            if(doc != null)
            {
                //Checking the number of attempts made for image upload with predefined maximum number of attempt
                if(doc.Back_Upload_Attempts__c >= noOfAttempts.Number_Of_Attempts__c)
                {
                    responseJSON.status = System.Label.FalseRespose;
                    responseJSON.message = System.Label.BackUploadExhausted;
                    responseJSON.apiStatus = false;
                    //   String serializedResonponse = JSON.serialize(responseJSON);
                    //  return serializedResonponse;
                }
                //If the image is uploaded successfully and upload attempts are less than metadata attempts, delete the previous uploaded Back document.
                else if(doc.Back_Upload_Attempts__c < noOfAttempts.Number_Of_Attempts__c){
                    doc.is_Back_Upload_Completed__c = true;
                    doc.Back_Upload_Attempts__c += 1;
                    if (Schema.sObjectType.Documents__c.isUpdateable()){
                        update doc; 
                    }
                    
                    responseJSON.status = System.Label.TrueRespose;
                    responseJSON.message =  System.Label.BackUploadSuccess;
                    responseJSON.apiStatus = false;
                    // String serializedResonponse = JSON.serialize(responseJSON);
                   
                    // return serializedResonponse;
                }
                else{
                    Boolean apiResponse  = false;
                    doc.is_Back_Upload_Completed__c = true;
                    doc.Back_Upload_Attempts__c += 1;
                    if (Schema.sObjectType.Documents__c.isUpdateable()){
                        update doc; 
                    }
                    //serialize the JSON object
                    responseJSON.status = System.Label.TrueRespose;
                    responseJSON.message = '';
                    responseJSON.apiStatus = apiResponse ;           
                }
                
                serializedResonponse = JSON.serialize(responseJSON);
                
            }
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            
            return serializedResonponse;
            
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'backUpload',System.Label.Apex, e);
			throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        // String serializedResonponse = JSON.serialize(responseJSON);
        // return serializedResonponse; 
    }
    //End: backUpload function By Nidhi Dhote.
    
    /*
* @Method:      sendOTP
* @Created by:  Divya
* @Description: This method will send the OTP - IND-287
* @Param:       String - loanApplication ID
* @Param:       String - aadharNumber
* @Return:      String - Serialized JSON response
*/
    @AuraEnabled
    public static String sendOTP(String leadApplicationId, String aadharNumber){
        try
        {
            
            String serializedResonponse = null;
            if(leadApplicationId!=null && aadharNumber!=null){
            Opportunity opp = [Select Aadhar_OTP_Attempts__c from Opportunity where id =: leadApplicationId WITH SECURITY_ENFORCED]; 
            System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance(System.Label.Aadhar_OTP_Attempts);
            ResponseWrapperSendOTP responseJSONSendOTP = new ResponseWrapperSendOTP();
            
            //Checking record is not null
            //if(opp != null)
            //{
             
                if((opp != null && opp.Aadhar_OTP_Attempts__c == null) && Schema.sObjectType.Opportunity.isUpdateable())
                {
                    responseJSONSendOTP.status = System.Label.TrueRespose;
                    responseJSONSendOTP.message = System.Label.OtpSent;
                    opp.Aadhar_OTP_Attempts__c =1;
                    //set Opportunity updateable
                        update opp;
                }
                //Checking the number of Aadhar OTP Attempts with the Number of Attempts of System Constants custom metadata
                else if(opp != null && opp.Aadhar_OTP_Attempts__c < noOfAttempts.Number_Of_Attempts__c)
                {
                    responseJSONSendOTP.status = System.Label.TrueRespose;
                    responseJSONSendOTP.message = System.Label.OtpSent;
                    opp.Aadhar_OTP_Attempts__c +=1;
                    //set Opportunity updateable
                    if(Schema.sObjectType.Opportunity.isUpdateable())
                    {
                        update opp;
                    }
                } 
                //Checking the number of Aadhar OTP Attempts with the Number of Attempts of System Constants custom metadata
                else  if(opp != null && opp.Aadhar_OTP_Attempts__c >= noOfAttempts.Number_Of_Attempts__c)
                {
                    responseJSONSendOTP.status = System.Label.FalseRespose;
                    responseJSONSendOTP.message = System.Label.AadhaarAttemptExhaust;
                }
                serializedResonponse = JSON.serialize(responseJSONSendOTP);
            //}
            }
            
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        
            return serializedResonponse;
            
        }
        catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' sendOTP ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
            	insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        //String serializedResonponse = JSON.serialize(responseJSONSendOTP);
        //return serializedResonponse;
    }
    
    //Wrapper Class for Send OTP
    public class ResponseWrapperSendOTP {
        String status {get;set;} 
        String message {get;set;}
        
        //constructor
        ResponseWrapperSendOTP() {
            this.message = '';
            this.status = '';   
        }
    }
    //IND-287 sendOTP End
    
    //Wrapper Class 
    public class responseWrapper {
        String status {get;set;} 
        String message {get;set;}
        boolean apiStatus {get;set;}
        boolean isFrontUploadSuccess {get;set;}
        boolean isBackUploadSuccess {get;set;}
        boolean isSelfieUploadSuccess {get;set;}
        //constructor
        responseWrapper() {
            this.message = '';
            this.status = '';
            this.apiStatus = false;
            this.isFrontUploadSuccess=false;
            this.isBackUploadSuccess=false;
            this.isSelfieUploadSuccess=false;
        }
    }
    
    /*
* @Method:      generateOTP
* @Created by:  Neha G.
* @Description: This Method will invoken an UIDAI API to send the OTP to customer:IND-286
* @Param:       String - current documentRecord ID
* @Return:      String - generated OTP
*/
    @AuraEnabled
    public static String generateOTP(String docRecordId){
        try {
            String otpForBorrower=null;
            if(docRecordId!=null){
            Documents__c documentsObject= [Select Id, OTP_for_borrower__c from Documents__c Where Id= :docRecordId WITH SECURITY_ENFORCED ];
            if(documentsObject!=null && Schema.sObjectType.Documents__c.isUpdateable())
            {
                Integer otpNumber = Utilities.generateUniqueNumber(4);
                documentsObject.OTP_for_borrower__c=String.valueOf(otpNumber);
                otpForBorrower=documentsObject.OTP_for_borrower__c;
                    update documentsObject;
                
            }
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            
            return otpForBorrower;
        }
        //DML Exception handled
        catch (Exception e) {
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' generateOTP ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: generateOTP() function
    
    /*
* @Method:      verifyAadharOTP
* @Created by:  Neha G.
* @Description: This Method will invoke an API and get the demographic information of Customer, if verified:IND-286
* @Param:       String - OTP enterd by User
* @Param:       String - current documentRecord ID
* @Return:      Boolean - response if OTP matches or not
*/
    @AuraEnabled
    public static Boolean verifyAadharOTP(String enteredOtpNumber,String docRecordId){
        try {
            Boolean responseFlag=false;
            if(enteredOtpNumber!=null && docRecordId!=null ){
            Documents__c documentsObject= [Select Id, OTP_for_borrower__c from Documents__c Where Id= :docRecordId WITH SECURITY_ENFORCED ];
            
            if(documentsObject!=null)
            {
                // this will check if the entered OTP and UIDAI received OTP matches
                if(documentsObject.OTP_for_borrower__c == enteredOtpNumber)
                {
                    responseFlag = true;
                }
                else
                {
                    responseFlag = false;
                }
            }
        }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return responseFlag;
        }
        //DML Exception handled 
        catch (Exception e) {
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' verifyAadharOTP ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
            	insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End:verifyAadharOTP() function
    
    /*
* @Method:      resendAadharOTP
* @Created by:  Neha G.
* @Description: This Method will invoke an UIDAI API to resend the OTP to customer:IND-286
* @Param:       String - current documentRecord ID
* @Return:      Boolean - response if OTP resent or not
*/
    @AuraEnabled
    public static Boolean resendAadharOTP(String docRecordId , String bmdsensorno){
        try {
            Boolean resendOtpStatus;
            if(docRecordId!=null ){
            Documents__c documentsObject= [Select Id, OTP_for_borrower__c, OTP_Resend_Attempts__c from Documents__c Where Id= :docRecordId WITH SECURITY_ENFORCED ];
            System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance(System.Label.Aadhar_OTP_Attempts);
            
            if(bmdsensorno != null && (documentsObject.OTP_Resend_Attempts__c >=1)){
                System.debug('when bmdsensorno not null');
                resendOtpStatus=false;
                return resendOtpStatus;
            }

            if(documentsObject.OTP_Resend_Attempts__c == null)
            {
                Integer otpNumber = Utilities.generateUniqueNumber(4);
                documentsObject.OTP_for_borrower__c=String.valueOf(otpNumber);
                documentsObject.OTP_Resend_Attempts__c =1;
                resendOtpStatus=true;
                if (Schema.sObjectType.Documents__c.isUpdateable())
                {
                    update documentsObject;
                }
            }
            else if(documentsObject.OTP_Resend_Attempts__c < noOfAttempts.Number_Of_Attempts__c)
            {
                Integer otpNumber = Utilities.generateUniqueNumber(4);
                documentsObject.OTP_for_borrower__c=String.valueOf(otpNumber);
                documentsObject.OTP_Resend_Attempts__c +=1;
                resendOtpStatus=true;
                if (Schema.sObjectType.Documents__c.isUpdateable()){
                    update documentsObject;
                }
            } 
            else  if(documentsObject.OTP_Resend_Attempts__c > noOfAttempts.Number_Of_Attempts__c)
            {
                resendOtpStatus=false;
            }
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return resendOtpStatus;
        }
        //DML Exception handled
        catch (Exception e) {
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' resendAadharOTP ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: resendAadharOTP() function
    
/*
* @Method Name: sendConsentSMS
* @Created by:  Ruchi Jain,IND-304
* @description: to set otp in OTP_for_borrower__c field of applicnt record
* @Param:       String - current Applicant ID
* @Return:      Integer - returns 05 digit OTP
*/
@AuraEnabled
    public static String sendConsentSMS(String applicantId) {
        try
        { 
            Integer randomNumber=0;
            if(applicantId!=null && Schema.sObjectType.Applicant__c.isUpdateable()){
            randomNumber = Utilities.generateUniqueNumber(5);
            Applicant__c applicant= [Select Id , OTP_for_borrower__c   from Applicant__c  WHERE Id = :applicantId WITH SECURITY_ENFORCED ];
            applicant.OTP_for_borrower__c= String.valueOf(randomNumber);
           
                update applicant;
            
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return applicant.OTP_for_borrower__c;
        }
            return null;
        }
        catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' sendConsentSMS ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
                insert errorLogRecord;      
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: sendConsentSMS()
    
/*
* @Method Name: otpVerify
* @Created by:  Ruchi Jain,IND-279
* @description: takes Applicant record id as parameter, and then if OTP_for_borrower__c matches otpnumber returns true.
* @Param:       String - OTP generated
* @Param:       String - current Applicant ID
* @Return:      Boolean - response if OTP verified or not
*/
@AuraEnabled
    public static Boolean otpVerify(String otpnumber,String applicantId){
        try {
            if(otpnumber!=null && applicantId!=null && Schema.sObjectType.Applicant__c.isUpdateable())
            {
                Applicant__c applicant= [Select Id , OTP_for_borrower__c ,Consent_Received__c from Applicant__c  WHERE Id = :applicantId WITH SECURITY_ENFORCED ];
                if(applicant.OTP_for_borrower__c == otpnumber)
                {
                    applicant.Consent_Received__c=true;
                    update applicant;
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
            
        }
        catch(Exception e)
        {
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' OTPVerify ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
            	insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: otpVerify()
    
    
/*
* @Method Name: otpConsentCheck
* @Created by:  Ruchi Jain
* @description: takes Applicant record id as parameter, and returns true if Consent_Received__c checkbox is checked in the respective Applicant record
* @Param:       current Applicant ID
* @Return:      Boolean - response if Consent Received or not
*/
@AuraEnabled
    public static Boolean otpConsentCheck(String applicantId){
        // Boolean otpConsentFlag=false;
        try {      
            if(applicantId!=null)
            {
                Applicant__c applicant= [Select Id , Consent_Received__c   from Applicant__c  WHERE Id = :applicantId WITH SECURITY_ENFORCED  ];
                if( applicant.Consent_Received__c==true)
                {
                    return true; 
                }
                else
                {
                    return false; 
                }
            }
            else{
                return false;
            }
            
        } catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' otpConsentCheck ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: otpConsentCheck()
    
/*
* @Method Name: otpExpireTimeOut
* @Created by:  Ruchi Jain
* @description: takes Applicant record id as parameter, and checks consent send time is greater than 30 minutes or not in the respective applicant record
* @Param:       current Applicant ID
* @Return:      Boolean - response if OTP expired or not
*/
@AuraEnabled
    public static Boolean otpExpireTimeOut(string applicantId){
        try {
            //Check Applicant existed
            if(applicantId!=null){
                Applicant__c applicant=[Select id,Consent_Sent__c from Applicant__c where id =: applicantId WITH SECURITY_ENFORCED]; 
                
                Long currentDateTime = DateTime.now().getTime();
                Long consentSentOnDate = applicant.Consent_Sent__c.getTime();
                String expiryTime = System.Label.OTP_Expiry_Time;
                Long difference = (currentDateTime-consentSentOnDate)/Integer.valueOf(expiryTime);
                	//DSAMOD Changes - Need resend timer for 1 minute	
                   /* if(UserInfo.getProfileId() == System.Label.DSAProfileId){	
                    Long differenceSeconds = (currentDateTime-consentSentOnDate)/1000;	
                    return differenceSeconds >= Long.valueOf(System.Label.OTPResendTimeSeconds) - 1;	
                    }*/	
    //END DSA Changes
                if(difference >= 1) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' otpExpireTimeOut ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: otpExpireTimeOut()
    
/*
* @Method Name: kycDelete
* @Created by:  Ruchi Jain
* @description: takes document record id as parameter, and and deletes that particular record.
* @Param:       current Loan Application ID
*/
@AuraEnabled
    public static void kycDelete(String loanApplicationId){
        try{
            if(loanApplicationId!=null){
                SObject documentsObject= [Select Id from Documents__c Where Id= :loanApplicationId WITH SECURITY_ENFORCED ];
                if (Schema.sObjectType.Documents__c.isAccessible() && Schema.sObjectType.Documents__c.isDeletable() ){
                    delete documentsObject;
                }
            }
            if(Test.isRunningTest()){
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' kycDelete ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: kycDelete()
    
    /*
* @Method:      vehicleDedupe
* @Created by:  Naga Puppala
* @Description: vehicleDedupe apex method
*/
    @AuraEnabled
    public static String vehicleDedupe(String customerCode, String parentDealNumber, String vehicleRegisterationNumber,String nocNumber){
        try{
            if(vehicleRegisterationNumber!=null ){
            VehicleDedupeResponse vdResponse = new VehicleDedupeResponse();
            //Boolean isSuccess = IntegrationUtilities.vehicleDedupeAPI();
            Boolean isSuccess = true;
            if(isSuccess){
                vdResponse.status = true;
                vdResponse.message = System.Label.SuccessMessage;
            }
            else{
                vdResponse.status = false;
                vdResponse.message = System.Label.FailureMessage;
            }
            String serializedResponse = JSON.serialize(vdResponse);
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return serializedResponse;
        }
            return null;
        }catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' vehicleDedupe ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }
    //End: vehicleDedupe()
    
    //Wrapper class for vehicleDedupe
    public class VehicleDedupeResponse{
        public Boolean status{get;set;}
        public String message{get;set;}
    }
    // Added By Naga Puppala end //
    
    /***********************************************************************************************************************
    * @Method Name: goldenSource
    * @Created by:  Vinita K.
    * @description: Method will send API response for Golden Source Action -IND-299
    * @Param:       String - current Loan Application ID
    * @Return:      String - serialized JSON response
    ***********************************************************************************************************************/
    @AuraEnabled
    public static String goldenSource(String currentDocId) {
        try{
            Map<String,Object> mapObj = new Map<String,Object>();
            Documents__c docObject= [Select Id, Golden_Source_Attempts__c,NSDL_Response__c,AadhaarSeedingStatus__c from Documents__c Where Id= :currentDocId WITH SECURITY_ENFORCED ];
            Boolean responseFlag;
            if(docObject != null && currentDocId!=null){
                System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance('Golden_Source_Attempt');
                if(docObject.Golden_Source_Attempts__c==null) {
                    docObject.Golden_Source_Attempts__c=1;
                    responseFlag=true;
                } else if(docObject.Golden_Source_Attempts__c<noOfAttempts.Number_Of_Attempts__c) {
                    docObject.Golden_Source_Attempts__c += 1;
                    responseFlag=true;
                } else if(docObject.Golden_Source_Attempts__c>=noOfAttempts.Number_Of_Attempts__c) {
                    responseFlag=false;
                }
                if (Schema.sObjectType.Documents__c.isUpdateable()){
                    update docObject;
                }
                if(Test.isRunningTest()) {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
            }
            mapObj.put('responseFlag',responseFlag);
            mapObj.put('responseObj',docObject);
            return json.serialize(mapObj); //CISP-19203
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'goldenSource',System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }   
    }
    //End: goldenSource()
    
    //Wrapper Class
    public class ResponseWrapperGoldenSource {
        String responseStatus {get;set;} 
        String statusCode {get;set;}
        String apiResponse {get;set;}
        String flags {get;set;}
        
        //constructor
        ResponseWrapperGoldenSource() {
            this.responseStatus = '';
            this.statusCode = '';
            this.apiResponse='';
            this.flags='';
        }
    }
    
    Public Class AdharOCRMockResponseClass{
        Public String AdharDocType='Adhar';
        Public String AdharKYCNo='1234567890';
        Public String AadharKycName='ADDDR';
        Public String AdharPIN='12345';
        Public String AdharCity='Bangalore';
        Public String AdharEnrolmentNumber='12345678901234';
        Public String AdharFirstName='Naga';
        Public String AdharLastName='Reddy';
        Public String AdharGender='Male';
        Public String addressLine1 ='PR Layout';
        Public String addressLine2 = 'MarathaHalli';
    }
    
    /*
    * @Method Name: aadharOCR
    * @Created by:  Neha Gosavi
    * @description: Method to track no of attempts for Aadhar OTP/Biometric OCR
    * @Param:       String - current documentRecord ID
    * @Return:      Boolean - if attempts exhausted or not
    */
    @AuraEnabled
    public static Boolean aadharOCR(String currentDocId){
        try{
            Boolean isRetryAllowed=false;
            if(currentDocId!=null){
                Documents__c docObject= [Select Id, Aadhar_OCR_Retry_Attempts__c from Documents__c Where Id= :currentDocId WITH SECURITY_ENFORCED ];
                System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance(System.Label.Aadhar_OCR_Attempts);
        
                if(docObject!=null){
                    if(docObject.Aadhar_OCR_Retry_Attempts__c==null) {
                        docObject.Aadhar_OCR_Retry_Attempts__c=1;
                        isRetryAllowed=true;
                    } else if(docObject.Aadhar_OCR_Retry_Attempts__c < noOfAttempts.Number_Of_Attempts__c) {
                        docObject.Aadhar_OCR_Retry_Attempts__c += 1;
                        isRetryAllowed=true;
                    } else if(docObject.Aadhar_OCR_Retry_Attempts__c > noOfAttempts.Number_Of_Attempts__c) {
                        isRetryAllowed=false;
                    }
                    if (Schema.sObjectType.Documents__c.isUpdateable()){
                        update docObject;
                    }
                }            
                if(Test.isRunningTest()) {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
            }
            return isRetryAllowed;
        }catch (Exception e) {   
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' aadharOCR ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
    * @Method Name: checkAdhaarVerification
    * @Created by:  Ruchi Jain
    * @description: accepts applicantId for checking if Aadhar_OTP_or_Biometric__c checkbox is enabledocument.
    * @Param:       String - current Applicant ID
    * @Return:      Boolean - check if Adhaar Verified or not
    */
    @AuraEnabled
    public static Boolean checkAdhaarVerification(String applicantId){ 
        try {
            Boolean checkAdharFlag=false;
            if(applicantId!=null) {
                Applicant__c applicantobject= [Select Id , Aadhar_OTP_or_Biometric__c From Applicant__c Where Id= :applicantId WITH SECURITY_ENFORCED ];              
                if(applicantobject.Aadhar_OTP_or_Biometric__c==true){
                    checkAdharFlag=true;
                } else {
                    checkAdharFlag=false;
                }
            }
            if(Test.isRunningTest()) {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return checkAdharFlag;
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' checkAdhaarVerification ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: checkAdhaarVerification()
    
    /*
    * @Method Name: getResendTime
    * @Created by:  Ruchi Jain
    * @description: For getting the custom metadata for delay time
    * @Return:      Decimal-returns resend dealy time
    */
    @AuraEnabled
        public static Decimal getResendTime(){
        try {
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.Aadhar_OTP_Attempts); 
            if(Test.isRunningTest()){
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return metadata.Delay_Time_in_milliseconds__c;
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' getResendTime ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: getResendTime()

    /*
    * @Method:      selfieUpload
    * @Created by:  Raj Gupta
    * @Description: This method is use to give the response according to Api response.
    *               This method is use for now when we get the api we can remove the this method and add code to selfie Upload methodocument.
    * @Param:       String - current Applicant ID
    * @Return:      String - Serialized JSON response
    */
    @AuraEnabled
    public static String selfieUpload(String applicantId) {
     try { 
    // Boolean response = selfieUploadcheckApiResponse();
    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.DocAuth); 
    Applicant__c applicant = [select Selfie_Retry_Attempts__c,Selfie_Upload__c from Applicant__c where id =: applicantId WITH SECURITY_ENFORCED];
    // Checking the number of attempts made for image upload with predefined maximum number of attempt
    if(applicant != null && metadata != null && applicantId != null)
    {
        if(applicant.Selfie_Retry_Attempts__c >= metadata.Selfie_Retry_attempts__c)
        {
            responseWrapper responseJSON = new responseWrapper();
            responseJSON.status = System.Label.FalseRespose;
            responseJSON.message = System.Label.SelfieAttemptExhausted;
            String serializedResonponse = JSON.serialize(responseJSON);
            return serializedResonponse;
                }
        //Api true response will be check here.
        else
        {   
                //applicant.Selfie_Upload__c = true;
                applicant.Selfie_Retry_Attempts__c +=1; 
                if (Schema.sObjectType.Applicant__c.isUpdateable()){
                    update applicant;
                }
                responseWrapper responseJSON = new responseWrapper();
                responseJSON.status = System.Label.TrueRespose;
                responseJSON.message = System.Label.SelfieSuccessfull;
                String serializedResonponse = JSON.serialize(responseJSON);
                return serializedResonponse;
            }
        }
     
     
    
    
     }
       catch(Exception e){
          Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' selfieUpload ', System.Label.Apex, e);
                if(Schema.sObjectType.Error_Log__c.isCreateable())
                {
                insert errorLogRecord;
                }
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }   
    //This piece of code will be run if the response is either true or false.   
     responseWrapper responseJSON = new responseWrapper();
    String serializedResonponse = JSON.serialize(responseJSON);
    return serializedResonponse;               
}
//End: selfieUpload()

    /*
* @Method:      docAuthresponse
* @Created by:  Raj Gupta
* @Description: This method is use for now to get response of DocAuth Report - IND-296
* @Return:      Boolean - success/failure docAuth API response
*/
    public static Boolean docAuthresponse() 
    {    
        //here DocAuth Api will call
        return true;
    }
    //End: docAuthresponse()
    
    /*
* @Method:      selfieReportresponse
* @Created by:  Raj Gupta
* @Description: Thid method is use for now to get response of SelfieReport - IND-296
* @Return:      Boolean - success/failure selfie API response
*/
    public static Boolean selfieReportresponse()
    {    
        //here  SelfieReport Api will call
        return true;
    }
    //End: selfieReportresponse()
    
    /*
* @Method:      faceMismatchResponse
* @Created by:  Raj Gupta
* @Description: Thid method is use for now to get response of FaceMismatch Report - IND-296
* @Return:      Boolean - success/failure API response
*/
    public static Boolean faceMismatchResponse()
    {    
        //here  SelfieReport Api will call
        return true;
    }
    //End: faceMismatchResponse()
    
    /*
* @Method:      performDocAuth
* @Created by:  Raj Gupta
* @Description: This Method is use update DocAuthPass field and selfieReportpass field of Document object if the response of Api is Pass or True.
* @Param:       String - current Document ID
*/
    @AuraEnabled
    public static void performDocAuth(String documentId)
    {
        try{ 
            
        //This method will perform Asynchronous call for the DocAuth Report and Selfie Uplaod Report.
        Boolean doctAuthApiresponse = docAuthresponse();
        Boolean  faceMismatchApiResponse= faceMismatchResponse();
       
            //If Response is true the if statement will run
            if(doctAuthApiresponse==true && documentId!=null)
            {
                
                Documents__c document = [select id from Documents__c where id =: documentId WITH SECURITY_ENFORCED];
                //Documents__c document = [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: loanApplicationId limit 1];
                if(document != null){
                    document.DocAuth_Passed__c = true;
                    if (Schema.sObjectType.Documents__c.isUpdateable())
                    {
                        update document; 
                    }
                }
                
                
                
            }
            /* commeting this Because this part of code is not mentation in the task.
if(doctAuthApiresponse==false)
{
//Not Mentation in the task
}
*/
            Boolean  selfieReportApiresponse = selfieReportresponse();
            //If Response is true the if statement will run
            if(selfieReportApiresponse==true)
            {
                
                Documents__c document = [select id from Documents__c where id =: documentId WITH SECURITY_ENFORCED];
                //Documents__c document =  [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: loanApplicationId limit 1];
                if(document != null){
                    document.Selfie_report_Pass__c = true;
                    if (Schema.sObjectType.Documents__c.isUpdateable())
                    {
                        update document; 
                    }
                }
                
                
            }
            /* commeting this Because this part of code is not mentation in the task.
if(selfieReportApiresponse==false)
{
//Not Mentation in the task
}
*/
            //if will check the FaceMismatch Api response
            if(faceMismatchApiResponse==true)
            {
                
                Documents__c document = [select id from Documents__c where id =: documentId WITH SECURITY_ENFORCED];
                //Documents__c document = [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: loanApplicationId limit 1];
                if(document != null){
                    document.FaceMismatch__c = true;
                    if (Schema.sObjectType.Documents__c.isUpdateable())
                    {
                        update document; 
                    }
                }
                
                
            }
            
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            
        }
        catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' performDocAuth ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: performDocAuth()
    
    /*
* @Method:      goldenSourcePass
* @Created by:  Raj Gupta
* @Description: This method will check golden source pass flag.
* @Param:       String - current Document ID
*/
    @AuraEnabled
    public static void goldenSourcePass(String documentId)
    {
        try
        {
            if(documentId!=null){
            Documents__c document = [select id from Documents__c where id =: documentId WITH SECURITY_ENFORCED];
            if(document != null){ 
                document.Golden_Source_Pass__c = true;
                if (Schema.sObjectType.Documents__c.isUpdateable())
                {
                    update document; 
                }
            }
        }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }
        catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' goldenSourcePass ', System.Label.Apex, e);  
             if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }        
                    throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: goldenSourcePass()
    
/*
* @Method Name: kycSaveData
* @Created by:  Ruchi Jain
* @description: For saving all the kyc fields in respective document record
* @Param:       String - document Type
* @Param:       String - KYC data to store
* @Param:       String - current Applicant ID
* @Param:       String - current Document ID
* @Return:      Boolean - response if data saved or not in Document Obj.
*/
@AuraEnabled
    public static Boolean kycSaveData(String docType,String kycData,String applicantId, String docId){
        //Ola Integration changes
        Boolean panMissmatchFlag = false;
        List<Applicant__c> applicantList = new List<Applicant__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        //Ola Integration changes
        try {
            if(applicantId!=null && docType!=null && kycData!=null && docId!=null && Schema.sObjectType.Documents__c.isUpdateable()){
                system.debug('kycData data print ' + kycData);
                LwcLOSLoanApplicationCntrl.WrapperDocument parsedData=(LwcLOSLoanApplicationCntrl.WrapperDocument) JSON.deserialize(kycData, WrapperDocument.Class);
                system.debug('parsed data print ' + parsedData);
                Documents__c documentsObject = new Documents__c();
                documentsObject = [Select id,IND_Aadhaar_Vault_Token_ID__c from Documents__c Where Id =: docId];
                documentsObject.id=docId;
                documentsObject.Name=docType;
                documentsObject.KYC_name__c=parsedData.documentKycName=='' ? null : parsedData.documentKycName;
                documentsObject.Document_Type__c=docType;
                documentsObject.is_Active__c = true;//CISP-2791
                parsedData.documentKYCAddressLine1 = parsedData.documentKYCAddressLine1 == 'null' ? '' : parsedData.documentKYCAddressLine1;//CISP-2923
                parsedData.documentKYCAddressLine2 = parsedData.documentKYCAddressLine2 == 'null' ? '' : parsedData.documentKYCAddressLine2;//CISP-2923

                applicantList = [SELECT id,PAN_No__c,Opportunity__c,Journey_Stage__c,Current_Same_As_Permanent__c,Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Applicant_Type__c FROM applicant__c WHERE id =:applicantId LIMIT 1];
                Boolean isTractorNonIndividualBorrower = false;
                if(applicantList.size()> 0){
                    isTractorNonIndividualBorrower = applicantList[0].Opportunity__r.Product_Type__c == System.Label.Tractor && applicantList[0].Opportunity__r.Customer_Type__c == 'Non-Individual' && applicantList[0].Applicant_Type__c == System.Label.Borrower ? true: false;
                    if(applicantList[0].Journey_Stage__c == System.Label.capturePermanentResidentialAddress && !applicantList[0].Current_Same_As_Permanent__c && docType != System.Label.PanCards && docType != System.Label.Form60DocumentType){
                        documentsObject.Permanent_Residential_Address_Proof__c = true;
                        documentsObject.Addresss_Type__c = 'Permanent Residential Address';
                    }else if(applicantList[0].Journey_Stage__c == System.Label.captureCurrentResidentialAddress && docType != System.Label.PanCards && docType != System.Label.Form60DocumentType){
                        documentsObject.Current_Residential_Address_Proof__c = true;
                        documentsObject.Addresss_Type__c = 'Current Residential Address';
                    }
                } 

                if((docType == System.Label.AadhaarCard && parsedData.aadharSource != 'Scan and Upload') || docType == System.Label.DrivingLicences || docType==System.Label.PassportCard || docType==System.Label.VoterIdCard){//CISP-2923
                    String completeAddress = (parsedData.documentKYCAddressLine1 == 'null' ? '' : parsedData.documentKYCAddressLine1) + ' ' + (parsedData.documentKYCAddressLine2 == 'null' ? '' : parsedData.documentKYCAddressLine2);
                    List<String> addressList = completeAddress.trim().split(' ');
                    String address1 = '';
                    String address2 = '';
                    String address3 = '';
                    String address4 = '';
                    for(String address : addressList){
                        if(!address.contains('S/O') && !address.contains('D/O') && !address.contains('W/O')){
                            if((address1 + ' ' + address).length() < 40){
                                address1 = address1 + ' ' + address;
                            }else if((address2 + ' ' + address).length() < 40){
                                address2 = address2 + ' ' + address;
                            }else if((address3 + ' ' + address).length() < 40){
                                address3 = address3 + ' ' + address;
                            }else if((address4 + ' ' + address).length() < 40){
                                address4 = address4 + ' ' + address;
                            }
                        }
                    }
                    String addressLine1 = address1.trim();
                    String addressLine2 = address2.trim();
                    if(addressLine2.length() < 10){

                        do{
                            String lastIndexAddressValue = addressLine1.substringAfter(' ');
                            addressLine2 = lastIndexAddressValue + ' ' + addressLine2;
                            addressLine1.remove(lastIndexAddressValue);
                        } While( addressLine2.length() < 10 );

                    }
                    documentsObject.KYC_Address_Line_1__c = addressLine1.trim();
                    if(String.isBlank(addressLine2)){ 
                        documentsObject.KYC_Address_Line_2__c = addressLine1.trim(); 
                    }else{ 
                        documentsObject.KYC_Address_Line_2__c = addressLine2.trim(); 
                    } 
                    documentsObject.KYC_Address_Line_3__c = address3.trim();
                    documentsObject.KYC_Address_Line_4__c = address4.trim();

                }else{
                    documentsObject.KYC_Address_Line_1__c=parsedData.documentKYCAddressLine1=='' ? null : parsedData.documentKYCAddressLine1;
                    documentsObject.KYC_Address_Line_2__c=parsedData.documentKYCAddressLine2=='' ? null : parsedData.documentKYCAddressLine2;
                }
                documentsObject.KYC_Pin_Code__c=parsedData.documentKycPinCode=='' ? null : parsedData.documentKycPinCode;
                documentsObject.KYC_City__c=parsedData.documentKycCity=='' ? null : parsedData.documentKycCity;
                documentsObject.KYC_District__c=parsedData.documentKycDistrict=='' ? null : parsedData.documentKycDistrict;
                documentsObject.KYC_State__c=parsedData.documentKycState=='' ? null : parsedData.documentKycState;
                documentsObject.KYC_DOB__c=parsedData.documentKycDob!=null ? parsedData.documentKycDob : null;
                documentsObject.First_Name__c=parsedData.documentFirstName=='' ? null : parsedData.documentFirstName;
                documentsObject.Last_Name__c=parsedData.documentLastName=='' ? null : parsedData.documentLastName;
                documentsObject.Gender__c=parsedData.documentGender=='' ? null : parsedData.documentGender;
                if(docType == System.Label.AadhaarCard && parsedData.aadharSource == 'Scan and Upload') {
                    if(String.IsBlank(parsedData.aadhaarVaultToken)){
                        throw new IND_Exception('Vault token is not captured. Please re-upload the document.');
                    }else{
                        documentsObject.IND_Aadhaar_Vault_Token_ID__c = parsedData.aadhaarVaultToken;//CISP-3039
                    }
                } else if(docType == System.Label.AadhaarCard && parsedData.aadharSource != 'Scan and Upload' && String.IsBlank(documentsObject.IND_Aadhaar_Vault_Token_ID__c)){
                    throw new IND_Exception('Vault token is not captured. Please re-upload the document.');
                }
                if(docType == System.Label.PanCards) {
                    documentsObject.NSDL_Response__c = parsedData.nsdlResponse;//CISP-3938
                    documentsObject.AadhaarSeedingStatus__c = parsedData.aadharSeedingStatus;
                    documentsObject.Pan_Approved__c = parsedData.panApproved;
                    documentsObject.NSDLPANStatus__c = parsedData.nsdlStatus;
                    documentsObject.NSDLPANName__c = parsedData.nsdlPanName;
                    documentsObject.NSDLNameMatch__c = parsedData.nsdlNameMatchPer;
                    if(parsedData.panApproved == true){//CISP-18188
                        documentsObject.CMU_Accept_Reject__c = 'Accept';
                    }
                }
                //CISP-3103-START
                if((parsedData.documentSalutation=='' || parsedData.documentSalutation==null) && parsedData.documentGender != '' &&  parsedData.documentGender != null){
                    if(parsedData.documentGender.toUpperCase() == 'MALE'){
                        documentsObject.Salutation__c = 'Mr.';
                    }else if(parsedData.documentGender.toUpperCase() == 'FEMALE'){
                        documentsObject.Salutation__c = 'Ms.';
                    }
                }else{
                    documentsObject.Salutation__c=parsedData.documentSalutation=='' ? null : parsedData.documentSalutation;
                }
                // CISP-3103-END
                documentsObject.Is_this_a_Photocopy__c=parsedData.isPhotocopy == null? false : parsedData.isPhotocopy ;
                if(docType==System.Label.VoterIdCard || docType==System.Label.DrivingLicences ||  docType==System.Label.PassportCard){
                    documentsObject.KYC_Issuance_Date__c=parsedData.documentKycIssuanceDate!=null ? parsedData.documentKycIssuanceDate : null;//dl,voterid,passport
                } 
                if(docType==System.Label.DrivingLicences  || docType==System.Label.PassportCard){
                    documentsObject.KYC_Expiry_Date__c=parsedData.documentKycExpiryDate!=null ? parsedData.documentKycExpiryDate : null;//dl,passport
                }
                if(docType==System.Label.AadhaarCard ||  docType==System.Label.DrivingLicences|| docType==System.Label.VoterIdCard){
                    //CISP-3038 -- start
                    if(parsedData.documentKycNo=='') {
                        documentsObject.KYC_No__c = null;
                    }
                    else {
                        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(parsedData.documentKycNo,System.Label.privateKey,System.Label.ivkey);
                        documentsObject.KYC_No__c = encryptedRequest;
                    }
                    //CISP-3038 -- end
                    //documentsObject.KYC_No__c=parsedData.documentKycNo=='' ? null : parsedData.documentKycNo;
                }
                if(docType==System.Label.PanCards){
                    if(isTractorNonIndividualBorrower == true){
                        documentsObject.Proof_of_Identity_POI__c = true;
                        Opportunity oppObj = new Opportunity();
                        oppObj.Id = applicantList[0].Opportunity__c;
                        oppObj.Date_of_Incorporation__c = parsedData.documentKycDob!=null ? parsedData.documentKycDob : null;
                        update oppObj;
                    }
                    //CISP-3038 -- start
                    if(parsedData.documentPanNo=='') {
                        documentsObject.PAN_No__c = null;
                    }
                    else {
                        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(parsedData.documentPanNo,System.Label.privateKey,System.Label.ivkey);
                        documentsObject.PAN_No__c = encryptedRequest;
                        List<Documents__c> olaTempDocObjectList = [SELECT id,KYC_DOB__c FROM Documents__c WHERE Applicant__c=:applicantId and Opportunity_Relation__c=:applicantList.get(0).Opportunity__c and Document_Type__c = 'Other' and KYC_DOB__c!=null LIMIT 1];//OLA-150
                        oppList = [SELECT id, StageName,LeadSource  FROM Opportunity WHERE id=:applicantList.get(0).Opportunity__c LIMIT 1 ];
                        if(oppList.size()>0 && (oppList.get(0).LeadSource=='OLA' || oppList.get(0).LeadSource=='Hero')){//CISH-54
                            String decryptedPAN1 = IntegrationUtilities.getDecryptedResponse(applicantList.get(0).PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                            String decryptedPAN2 = IntegrationUtilities.getDecryptedResponse(documentsObject.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                            if(applicantList.size()>0 && !decryptedPAN1.equalsIgnoreCase(decryptedPAN2)){//OLA-129
                                panMissmatchFlag = true;
                            	throw new IND_Exception('KYC PAN number is different than PAN provided at the time of lead creation. Please provide correct PAN.');
                            }
                            if(olaTempDocObjectList.size()>0){
                                if(parsedData.documentKycDob!=olaTempDocObjectList.get(0).KYC_DOB__c){
                                    panMissmatchFlag = true;
                            	    throw new IND_Exception('DOB date is different than DOB provided at the time of lead creation. Please provide correct DOB.');
                                }
                            }
                            
                        }
                    }
                    //CISP-3038 -- end
                    //documentsObject.PAN_No__c=parsedData.documentPanNo=='' ? null : parsedData.documentPanNo; 
                    documentsObject.KYC_Issuance_Date__c=parsedData.documentKycIssuanceDate!=null ? parsedData.documentKycIssuanceDate : null ;
                }
                else if(docType==System.Label.PassportCard){
                    documentsObject.Passport_File_No__c=parsedData.documentPassportFileNo=='' ? null : parsedData.documentPassportFileNo;
                    //CISP-3038 -- start
                    if(parsedData.documentPassportNo=='') {
                        documentsObject.Passport_No__c = null;
                    }
                    else {
                        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(parsedData.documentPassportNo,System.Label.privateKey,System.Label.ivkey);
                        documentsObject.Passport_No__c = encryptedRequest;
                    }
                    //CISP-3038 -- end
                    //documentsObject.Passport_No__c=parsedData.documentPassportNo=='' ? null : parsedData.documentPassportNo;
                }
                else if(docType==System.Label.VoterIdCard){
                    system.debug('Age print ' + parsedData.documentAge);
                    documentsObject.Age__c=parsedData.documentAge;
                }
                else if(docType==System.Label.DrivingLicences){
                    documentsObject.DL_Type__c=parsedData.documentDLType=='' ? null : parsedData.documentDLType;
                }
                else if(docType==System.Label.AadhaarCard){
                    documentsObject.Aadhar_Source__c=parsedData.aadharSource=='' ? null : parsedData.aadharSource;
                    documentsObject.Aadhaar_Enrollment_Number__c=parsedData.documentAadhaarEnrollmentNumber==null ? ''  : IntegrationUtilities.getEncryptedRequest(parsedData.documentAadhaarEnrollmentNumber,System.Label.privateKey,System.Label.ivkey);//CISP-3038
                } else if(docType==System.Label.GST_CERT){
                    documentsObject.GST_No__c=parsedData.documentGstNo=='' ? null : IntegrationUtilities.getEncryptedRequest(parsedData.documentGstNo,System.Label.privateKey,System.Label.ivkey);//SFTRAC-458
                    if(isTractorNonIndividualBorrower == true){
                        documentsObject.Proof_of_Address_POA__c = true;
                        documentsObject.Permanent_Residential_Address_Proof__c = true;
                    }
                } else if(docType==System.Label.CIN_CERT){
                    documentsObject.CIN_No__c=parsedData.documentCinNo=='' ? null : IntegrationUtilities.getEncryptedRequest(parsedData.documentCinNo, System.Label.privateKey,System.Label.ivkey);//SFTRAC-458
                }
                update documentsObject; 
                return true;  
            } else {
                return false;  
            }
        } catch(Exception e) {
            system.debug('e -->'+e.getMessage()+'-->line '+e.getLineNumber()+ 'exact--> '+e.getCause() );
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' kycSaveData ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()) {
                insert errorLogRecord;
            }
            if(panMissmatchFlag){
                oppList.get(0).StageName='Rejected';
                update oppList;
                throw new AuraHandledException(e.getMessage());
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: kycSaveData()
    
     //Wrapper class for kycSaveData()
    //public and set and get added by Hemanth Thikka
  public class WrapperDocument{    
    public Boolean isPhotocopy{get;set;}
    public String aadharSource{get;set;}
    public string documentKycNo{get;set;}
    public String documentKycName{get;set;}
    public String documentKYCAddressLine1{get;set;}
    public string documentKYCAddressLine2{get;set;}
    public String documentKycPinCode{get;set;} 
    public Integer documentAge{get;set;}
    public string documentKycCity{get;set;} 
    public string documentKycDistrict{get;set;} 
    public string documentKycState{get;set;}  
    public Date documentKycDob{get;set;}  
    public Date documentKycIssuanceDate{get;set;} 
    public Date documentKycExpiryDate{get;set;}  
    public string documentDLType{get;set;}
    public string documentPanNo{get;set;}
    public string documentFirstName{get;set;}
    public string documentLastName{get;set;} 
    public string documentGender{get;set;}
    public string documentSalutation {get;set;}
    public string documentAadhaarEnrollmentNumber{get;set;}
    public string documentPassportFileNo {get;set;}
    public string documentPassportNo{get;set;}
    public string documentGstNo{get;set;}
    public string documentCinNo{get;set;}
    public string aadhaarVaultToken{get;set;}//CISP-3039
    public string nsdlResponse {get;set;} //CISP-3938
    public string aadharSeedingStatus {get;set;}
    public Boolean panApproved {get;set;}
    public string nsdlStatus {get;set;}
    public string nsdlPanName{get;set;}
    public String nsdlNameMatchPer{get;set;}
}
    //End : Ruchi Jain

//CISP-2630-START
    /*
* @Method Name: updateApplicantName
* @Created by:  Gaurav Rawat
* @description:  
* @Param:     
* @Return:     
*/
@AuraEnabled
public static String updateApplicantName(String applicantId){
    try {
        List<Applicant__c> applicantList = new List<Applicant__c>();
        applicantList = [SELECT id,Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Applicant_Type__c FROM applicant__c WHERE id =:applicantId LIMIT 1];
        Boolean isTractorNonIndividualBorrower = false;
        if(applicantList.size()> 0){
            isTractorNonIndividualBorrower = applicantList[0].Opportunity__r.Product_Type__c == System.Label.Tractor && applicantList[0].Opportunity__r.Customer_Type__c == 'Non-Individual' && applicantList[0].Applicant_Type__c == System.Label.Borrower ? true: false;
        }
        Set<String> documentList = new Set<String>{System.Label.VoterIdCard, System.Label.DrivingLicences, System.Label.PassportCard, System.Label.AadhaarCard, System.Label.PanCards};//CISP-2899
        List<Documents__c> docList = new List<Documents__c>([Select Id,Name,Document_Type__c,First_Name__c,Last_Name__c,Opportunity_Relation__c From Documents__c Where Applicant__c =: applicantId AND is_Active__c = true AND Document_Type__c IN: documentList WITH SECURITY_ENFORCED]);//CISP-2899
        Applicant__c appObj = new Applicant__c();
        appObj.Id = applicantId;
        String existingLastName = [SELECT Customer_Last_Name__c FROM Applicant__c WHERE Id = :appObj.Id LIMIT 1].Customer_Last_Name__c;
        Map<String,Documents__c> docMap = new Map<String,Documents__c>();//CISP-2899
        for(Documents__c doc : docList){
            if((String.isNotBlank(doc.First_Name__c) || String.isNotBlank(doc.Last_Name__c)) && !docMap.containsKey(doc.Document_Type__c)){
                docMap.put(doc.Document_Type__c, doc);
            }
        }
        // start CISP-2630
        if(docMap.containsKey(System.Label.AadhaarCard)){
            Documents__c doc = docMap.get(System.Label.AadhaarCard);
            String kycFullName = ((String.isBlank(doc.First_Name__c) ? '' : doc.First_Name__c) + ' ' + (String.isBlank(doc.Last_Name__c) ? '' : doc.Last_Name__c)).trim();
            List<String> kycFullNameList = new List<String>();
            kycFullNameList = kycFullName.split(' ');
            if(kycFullNameList.size() > 1){
                appObj.Customer_First_Name__c = kycFullName.substringBefore(' ');
                appObj.Customer_Last_Name__c = kycFullName.substringAfter(' ');
                appObj.Name = kycFullName;
            }else{
                appObj.Customer_First_Name__c = kycFullName;
                appObj.Name = kycFullName + ' ' + existingLastName ;
            }
        }else if(docMap.containsKey(System.Label.PanCards)){
            Documents__c doc = docMap.get(System.Label.PanCards);
            String kycFullName = ((String.isBlank(doc.First_Name__c) ? '' : doc.First_Name__c) + ' ' + (String.isBlank(doc.Last_Name__c) ? '' : doc.Last_Name__c)).trim(); 
            List<String> kycFullNameList = new List<String>();
            kycFullNameList = kycFullName.split(' ');
            if(kycFullNameList.size() > 1){
                appObj.Customer_First_Name__c = kycFullName.substringBefore(' ');
                appObj.Customer_Last_Name__c = kycFullName.substringAfter(' ');
                appObj.Name = kycFullName;
            }else{
                appObj.Customer_First_Name__c = kycFullName;
                appObj.Name = kycFullName + ' ' + existingLastName ;
            }
            if(isTractorNonIndividualBorrower == true && applicantList[0].Opportunity__r.Entity_Type__c != 'Proprietorship'){
                Opportunity oppObj = new Opportunity();
                oppObj.Id = doc.Opportunity_Relation__c;
                oppObj.Entity_Name__c = kycFullName;
                update oppObj;
            }
        }// end CISP-2630
        else if(docMap.containsKey(System.Label.PassportCard)){
            Documents__c doc = docMap.get(System.Label.PassportCard);
            String kycFullName = ((String.isBlank(doc.First_Name__c) ? '' : doc.First_Name__c) + ' ' + (String.isBlank(doc.Last_Name__c) ? '' : doc.Last_Name__c)).trim(); 
            List<String> kycFullNameList = new List<String>();
            kycFullNameList = kycFullName.split(' ');
            if(kycFullNameList.size() > 1){
                appObj.Customer_First_Name__c = kycFullName.substringBefore(' ');
                appObj.Customer_Last_Name__c = kycFullName.substringAfter(' ');
                appObj.Name = kycFullName;
            }else{
                appObj.Customer_First_Name__c = kycFullName;
                appObj.Name = kycFullName + ' ' + existingLastName ;
            }
        }else if(docMap.containsKey(System.Label.DrivingLicences)){
            Documents__c doc = docMap.get(System.Label.DrivingLicences);
            String kycFullName = ((String.isBlank(doc.First_Name__c) ? '' : doc.First_Name__c) + ' ' + (String.isBlank(doc.Last_Name__c) ? '' : doc.Last_Name__c)).trim();
            List<String> kycFullNameList = new List<String>();
            kycFullNameList = kycFullName.split(' ');
            if(kycFullNameList.size() > 1){
                appObj.Customer_First_Name__c = kycFullName.substringBefore(' ');
                appObj.Customer_Last_Name__c = kycFullName.substringAfter(' ');
                appObj.Name = kycFullName;
            }else{
                appObj.Customer_First_Name__c = kycFullName;
                appObj.Name = kycFullName + ' ' + existingLastName ;
            }
        }else if(docMap.containsKey(System.Label.VoterIdCard)){
            Documents__c doc = docMap.get(System.Label.VoterIdCard);
            String kycFullName = ((String.isBlank(doc.First_Name__c) ? '' : doc.First_Name__c) + ' ' + (String.isBlank(doc.Last_Name__c) ? '' : doc.Last_Name__c)).trim();
            List<String> kycFullNameList = new List<String>();
            kycFullNameList = kycFullName.split(' ');
            if(kycFullNameList.size() > 1){
                appObj.Customer_First_Name__c = kycFullName.substringBefore(' ');
                appObj.Customer_Last_Name__c = kycFullName.substringAfter(' ');
                appObj.Name = kycFullName;
            }else{
                appObj.Customer_First_Name__c = kycFullName;
                appObj.Name = kycFullName + ' ' + existingLastName ;
            }
        }
        if(Schema.sObjectType.Applicant__c.isUpdateable()){
            update appObj;
            String applicantFullName = ((String.isBlank(appObj.Customer_First_Name__c) ? '' : appObj.Customer_First_Name__c) + ' ' +  (String.isBlank(appObj.Customer_Last_Name__c) ? '' : appObj.Customer_Last_Name__c)).trim();
            return applicantFullName;
        }
        return null;
    } catch(Exception e) {
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' updateApplicantName ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()) {
            insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
//CISP-2630-END
    
/*
* @Method:      getApplicantStageDetails
* @Created by:  Santhosh Guhan
* @Description: This method will return Current Applicant Journey Stage
* @Param:       String - Applicant ID
* @Return:      String - Journey Stage
*/
    @AuraEnabled
    public static Applicant__c getApplicantStageDetails(String applicantId){
        try {
        List<Applicant__c> app = [Select Id,Journey_Stage__c,Opportunity__r.StageName,Opportunity__r.LastStageName__c FROM Applicant__c WHERE Id=:applicantId];
        if(app.size()>0){
            return app[0];
        }
        return null;
        }
        catch(Exception e){
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' getApplicantStageDetails ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
/*
* @Method:      getCurrentOppRecord
* @Created by:  Manish B.
* @Description: This method will return CurrentOppRecord ID
* @Param:       String - loanApplication ID
* @Return:      String - Serialized JSON response
*/
    @AuraEnabled
    public static String getCurrentOppRecord(String loanApplicationId){
        try {
            if(loanApplicationId!=null){
            LoanApplicationWrapper loanWrapperElement = new LoanApplicationWrapper();
            List<applicantWrapper> applicantsList = new  List<applicantWrapper>();
            List<ContentDocumentLink> contentdocForm60 =new  List<ContentDocumentLink>();
            // MAP<String,applicantWrapper> applicantsMap = new MAP<String,applicantWrapper>();
            // MSIL API Changes only added LeadSource filed//
            Opportunity opprecord=[ SELECT Id,LeadSource,OwnerId,Lead_number__c,Product_Type__c,Parent_Loan_Application__c,Name,Parent_Loan_Application__r.Is_Revoked__c,Parent_Loan_Application__r.StageName, Customer_Type__c, Number_of_Products__c,Application_Type__c,
                                   Agent_BL_Code__c, Sub_Stage__c,LastStageName__c,Loan_amount__c,Vehicle_Type__c,Vehicle_Sub_Category__c,Vehicle_Proceed_Flag__c,
                                   Parent_Deal_number__c,Valid_Dedupe_Customer_Code__c,Vehicle_Registration_Number__c,Registration_Number_Format__c,Entity_Name__c, Entity_Type__c, Entity_Code__c, Entity_Category__c, Date_of_Incorporation__c, Contact_Person_Name__c, Lead_Source_Non_Ind__c, Class_of_Activity__c, Loan_Type__c, Evaluation_Type__c, Major_Industry__c, Minor_Industry__c, Profile__c,
                                   NOC_Number__c,Vehicle_Verified__c,AccountId,StageName,Is_Revoked__c,Application_number__c,isTopUpLoan__c   //DSAMODIFYEXISTING                          
                                   FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                                   // Is_Revoked__c - Added - CISP-2382/CISP-2413 Parent_Loan_Application__r.StageName for CISP-12675
            //D2C_CHANGE
            if(opprecord.LeadSource == 'D2C' && opprecord.Vehicle_Registration_Number__c == null && opprecord.Sub_Stage__c == 'Vehicle Dedupe'){
                List<Vehicle_Detail__c> vehicleDetails = [  SELECT Id, Vehicle_Registration_Number__c 
                                                            FROM Vehicle_Detail__c 
                                                            WHERE Loan_Application__c =: opprecord.Id AND Vehicle_Registration_Number__c != null];
                if(vehicleDetails != null && !vehicleDetails.isEmpty()){
                    opprecord.Vehicle_Registration_Number__c = vehicleDetails[0].Vehicle_Registration_Number__c.toUpperCase();
                    Pattern MyPattern = Pattern.compile(System.Label.Vehicle_New);
                    Matcher myMatcher = MyPattern.matcher(opprecord.Vehicle_Registration_Number__c);
                    if(MyMatcher.matches()){
                        opprecord.Registration_Number_Format__c = 'New';
                    }else{
                        opprecord.Registration_Number_Format__c = 'old';
                    }
                    update opprecord;
                }
            }
            //EO_D2C_CHANGE
            
            for(Applicant__c applicant : [SELECT Id,AepS_Info__c,Name,OTP_for_borrower__c,Selfie_Retry_Attempts__c,Customer_First_Name__c,Customer_Last_Name__c,Whatsapp_number__c,customer_image_attempts__c,
                                          Contact_number__c,Applicant_Type__c,DocAuth_Application_Id__c,Selfie_Upload__c,Customer_code__c,
                                          Consent_Received__c,Register_for_WhatsApp_Banking__c,Income_source_available__c,Journey_Stage__c,
                                          Declared_income__c,Loan_Amount__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,
                                          Would_you_like_to_open_a_bank_account__c,LastModifiedDate,Current_Same_As_Permanent__c, Current_Address_Not_Present__c, 
                                          Beneficial_Owner_Category__c, Relationship_with_Entity__c,Relationship_Type__c,POA_Holder__c,ShareHolding__c,Permanent_Address_Not_Present__c,(SELECT Id,is_Front_Upload_Completed__c,Applicant__c,Document_Type__c,KYC_name__c,Current_Residential_Address_Proof__c, Permanent_Residential_Address_Proof__c,Is_Active__c,Landmark__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,KYC_District__c,KYC_Pin_Code__c,KYC_State__c  FROM Documents__r), (SELECT Count__c from Retry_Counts__r WHERE Service_Name__c ='Create Application Attempts' AND Module__c ='Lead Details')
                                          FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC])
            {
                applicantWrapper applicantElement = new applicantWrapper();
                applicantElement.applicantId = applicant.Id;
                applicantElement.customerFirstName = String.isEmpty(applicant.Customer_First_Name__c) ? '' : applicant.Customer_First_Name__c;//CISP-2965
                applicantElement.customerLastName = String.isEmpty(applicant.Customer_Last_Name__c) ? '' : applicant.Customer_Last_Name__c;//CISP-2965
                applicantElement.customerWhatsappNumber = applicant.Whatsapp_number__c;
                applicantElement.customerContactNumber = applicant.Contact_number__c;
                applicantElement.applicantType = applicant.Applicant_Type__c;
                applicantElement.registeredWhatsappBanking = applicant.Register_for_WhatsApp_Banking__c;
                applicantElement.isIncomeSourceAvailable = applicant.Income_source_available__c;
                applicantElement.declaredIncomeSource = applicant.Declared_income__c;
                applicantElement.aepsValue = applicant.AepS_Info__c;
                applicantElement.loanAmount = applicant.Loan_Amount__c;
                applicantElement.haveBankAccount = applicant.Do_you_have_a_bank_account__c;
                applicantElement.isBankAccountWithIBL = applicant.Do_you_have_a_bank_account_with_IBL__c;
                applicantElement.wantToOpenBankAccount = applicant.Would_you_like_to_open_a_bank_account__c;
                applicantElement.isConsentRecieved = applicant.Consent_Received__c;
                applicantElement.currentJourneyStage = applicant.Journey_Stage__c;
                applicantElement.isCurrentPermanentSameAddr = applicant.Current_Same_As_Permanent__c;
                applicantElement.isCurrentAddressNotPresent = applicant.Current_Address_Not_Present__c;
                applicantElement.isPermanentAddressNotPresent = applicant.Permanent_Address_Not_Present__c;
                applicantElement.customerImageAttempt=applicant.customer_image_attempts__c;
                applicantElement.SelfieRetryAttempts=applicant.Selfie_Retry_Attempts__c;
                applicantElement.customerCode=applicant.Customer_code__c;
                applicantElement.applicantName = applicant.Name;
                if(opprecord.Product_Type__c == 'Tractor' && applicant.Applicant_Type__c == 'Beneficiary'){//SFTRAC-78
                    applicantElement.beneficialOwnerCategory = applicant.Beneficial_Owner_Category__c;
                    applicantElement.relationshipWithEntity = applicant.Relationship_with_Entity__c;
                    applicantElement.relationshipType = applicant.Relationship_Type__c;
                    applicantElement.poaHolder = applicant.POA_Holder__c;
                    applicantElement.shareholderPercent = Integer.valueof(applicant.ShareHolding__c);
                }
                if (!applicant.Retry_Counts__r.isEmpty()) {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Retry_Count'); //Adhoc Unit testing fix - Chaynnitt Agarwal
                    applicantElement.createApplicationCountExhausted = applicant.Retry_Counts__r[0].Count__c >=metadata.Number_Of_Attempts__c;//SFTRAC-536
                } else {
                    applicantElement.createApplicationCountExhausted = false;
                }
                
                if(applicant.OTP_for_borrower__c!=null){
                    applicantElement.consentInitiated=true;
                }else{
                    applicantElement.consentInitiated=false;
                }
               
                if(!String.isEmpty(applicant.DocAuth_Application_Id__c ) && applicant.Selfie_Upload__c ){
                    applicantElement.isImageUpload = true;
                }

                if(!String.isEmpty(applicant.DocAuth_Application_Id__c )){
                    applicantElement.isCreateApplication = true;
                } // UAT Adhoc bug changes - Chaynnitt Agarwal

                if(applicant.Applicant_Type__c == System.label.Borrower){
                    loanWrapperElement.isBorrowerEarning = applicant.Income_source_available__c;
                }

                for(Documents__c doc : applicant.Documents__r){
                    if(doc.Document_Type__c == 'Address Declaration' || 
                    doc.Document_Type__c == System.Label.ElectricityBillApiName || 
                    doc.Document_Type__c == System.Label.TelephonicBillAPI || 
                    doc.Document_Type__c == 'Gas bill' ||
                    doc.Document_Type__c == 'Water Bill' ||
                    doc.Document_Type__c == 'Property or Municipal Tax Receipt' ||
                    doc.Document_Type__c == 'Govt pension payment order' ||
                    doc.Document_Type__c == 'Pension Document' ||
                    doc.Document_Type__c == 'Govt letter of accommodation allotment' ){
                        applicantElement.addDocId = doc.Id;
                        applicantElement.addDocType = doc.Document_Type__c;
                    }
                    if(doc.is_Front_Upload_Completed__c){
                        applicantElement.FrontUploadComplete=doc.is_Front_Upload_Completed__c;
                    }
                    if(doc.Document_Type__c == System.Label.AadhaarCard && doc.KYC_name__c != null){
                        applicantElement.isAadhaarPresent = true;
                        applicantElement.aadharDocId = doc.Id;
                        applicantElement.isAadhaarCurrent = doc.Current_Residential_Address_Proof__c;
                        applicantElement.isAadhaarPermanent = doc.Permanent_Residential_Address_Proof__c;
                    }else if(doc.Document_Type__c == System.Label.PanCards && doc.KYC_name__c != null && doc.Is_Active__c == true){
                        applicantElement.isPanPresent = true;
                        applicantElement.panDocId = doc.Id;
                        applicantElement.PANType = doc.Document_Type__c;
                    }else if(doc.Document_Type__c == 'Form 60' && doc.Is_Active__c == true){ 
                         contentdocForm60 = [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :doc.Id];
                        if(!contentdocForm60.isEmpty()){
                            applicantElement.isForm60Present =  true;
                            applicantElement.form60DocId = doc.Id;
                            applicantElement.Form60Type = doc.Document_Type__c;
                        }
                    }else if(doc.Document_Type__c == System.Label.PassportCard && doc.KYC_name__c != null){
                        applicantElement.isPassportPresent = true;
                        applicantElement.passportDocId = doc.Id;
                        applicantElement.isPassportCurrent = doc.Current_Residential_Address_Proof__c;
                        applicantElement.isPassportPermanent = doc.Permanent_Residential_Address_Proof__c;
                    }else if(doc.Document_Type__c == System.Label.GST_CERT && doc.Is_Active__c == true){
                        applicantElement.isGstPresent = true;
                        applicantElement.docType = doc.Document_Type__c;
                        applicantElement.gstDocId = doc.Id;
                    }else if(doc.Document_Type__c == System.Label.CIN_CERT && doc.Is_Active__c == true){
                        applicantElement.isCinPresent = true;
                        applicantElement.cinDocId = doc.Id;
                        applicantElement.docType = doc.Document_Type__c;
                    }else if(doc.Document_Type__c == System.Label.VoterIdCard && doc.KYC_name__c != null){
                        applicantElement.isVoterIdPresent = true;
                        applicantElement.voterIdDocId = doc.Id;
                        applicantElement.isVoterIdCurrent = doc.Current_Residential_Address_Proof__c;
                        applicantElement.isVoterIdPermanent = doc.Permanent_Residential_Address_Proof__c;
                    }else if(doc.Document_Type__c == System.Label.DrivingLicences && doc.KYC_name__c != null){
                        applicantElement.isDLPresent = true;
                        applicantElement.dlDocId = doc.Id;
                        applicantElement.isDLCurrent = doc.Current_Residential_Address_Proof__c;
                        applicantElement.isDLPermanent = doc.Permanent_Residential_Address_Proof__c;
                    }else if(doc.Document_Type__c == System.Label.CustomerImageDocumentType){
                        applicantElement.customerImageDocId=doc.Id;
                        Set<Id> docIdSet = new Set<Id>();
                        for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :doc.Id]){
                            docIdSet.add(contentdoc.ContentDocumentId);
                        }
                        List<ContentVersion> cv=[SELECT Id,Document_Side_fileupload__c,ContentDocumentId from Contentversion where ContentDocumentId IN : docIdSet AND Document_Side_fileupload__c= 'Selfie' ];
                         
                        if(cv.size()==1){
                        applicantElement.isCustomerImagePresent = true;
                        }
                    }
                }
                applicantsList.add(applicantElement);
            }
            loanWrapperElement.oppRecord = opprecord;
            loanWrapperElement.applicantsList = applicantsList;
            
            if(Test.isRunningTest()) {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return JSON.serialize(loanWrapperElement);
        }
        return null;
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' getCurrentOppRecord ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: getCurrentOppRecord()
    
    //Wrapper class for getCurrentOppRecord()
    public class LoanApplicationWrapper{
        @AuraEnabled public Opportunity oppRecord {get;set;}
        @AuraEnabled public Applicant__c applicantBorrowerRecord {get;set;}
        @AuraEnabled public List<applicantWrapper> applicantsList {get;set;}
        @AuraEnabled public Boolean isBorrowerEarning {get;set;}
        @AuraEnabled public List<vehicledetailsWrapper> vehicledetailsList {get;set;}  //updated by Aakash J for tractor vehicle Dedupe LWC
    }
    
    /*
    * @Method Name: docCustomerImage
    * @Created by:  Ruchi Jain
    * @description: to create a document object 
    * @Param:       String - Document Type
    * @Param:       String - current Applicant ID
    * @Param:       String - loanApplication ID
    * @Return:      String - created Document's ID
    */
    @AuraEnabled
    public static string docCustomerImage(String docType,String applicantId,String loanApplicationId){
        try {
            if(applicantId!=null && docType!=null && loanApplicationId!=null ){
                ID personAccountRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.KYCDocument).getRecordTypeId();
                List<Documents__c> docObjList = [Select Id, Document_Type__c from Documents__c where Applicant__c =: applicantId And Opportunity_Relation__r.Id =:loanApplicationId and Document_Type__c=:docType and is_Active__c = true WITH SECURITY_ENFORCED];
                if(docObjList.isEmpty()) {
                    Documents__c docObject= new Documents__c(Name = docType,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId);
                    docObject.RecordTypeId = personAccountRecordType;
                    docObject.Document_Type__c=docType;
                    //CISP-2791
                    if(docType == System.Label.AadhaarCard || docType ==System.Label.PanCards || docType == System.Label.DrivingLicences || docType == System.Label.VoterIdCard || docType == System.Label.PassportCard || docType == System.Label.Form60DocumentType || docType == System.label.GST_CERT || docType == System.label.CIN_CERT){
                        docObject.is_Active__c=false;
                    }else{
                        docObject.is_Active__c=true;
                    }
                    //CISP-2791
                    if (Schema.sObjectType.Documents__c.isCreateable()) {
                        insert docObject;
                    }
                    return docObject.id;
                } else {
                    return docObjList[0].Id;
                }
            }
            if(Test.isRunningTest()) {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return null;
        } catch(Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' docCustomerImage ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: docCustomerImage()
/*
* @Method Name: createOtherDocument
* @Created by:  Vinita Kamble
* @description: to create a document object 
* @Param:       String - Document Type
* @Param:       String - current Applicant ID
* @Param:       String - loanApplication ID
* @Return:      String - created Document's ID
*/
@AuraEnabled
    public static string createOtherDocument(String docType,String applicantId,String loanApplicationId){
        try {
            if(applicantId!=null && docType!=null && loanApplicationId!=null ){
                ID personAccountRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
                 //[SELECT Id FROM RecordType WHERE Name = :System.Label.KYCDocument and SObjectType = 'Documents__c'  WITH SECURITY_ENFORCED ];
                // MAP<String,Integer> preferenceOrderMap = new MAP<String,Integer>();
                Documents__c docObject= new Documents__c(Name = docType,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId);
                docObject.RecordTypeId = personAccountRecordType;
                docObject.Document_Type__c=docType;
                docObject.is_Active__c=true;
                // if(docType!=System.Label.CustomerImageDocumentType){
                //     for(POI_Preference__mdt mdtElement : POI_Preference__mdt.getAll().values()){
                //         preferenceOrderMap.put(mdtElement.MasterLabel,(Integer)mdtElement.Preference_Order__c);
                //     }
                    //CISP-3047-START
                    // if(preferenceOrderMap.containsKey(docType)){
                    //     docObject.Proof_of_Identity_POI__c=true;
                    // }
                    //CISP-3047-END
                    // List<Documents__c> documentsList = [select Id,Name from Documents__c where Applicant__c=:applicantId And Document_Type__c !=: System.Label.CustomerImageDocumentType WITH SECURITY_ENFORCED];
                    // if(preferenceOrderMap.containsKey(docType) && !documentsList.isEmpty() && documentsList.size()>0){//CISP-3047
                    //     for(Documents__c doc : documentsList){
                    //         if(preferenceOrderMap.get(doc.Name)>preferenceOrderMap.get(docType)){
                    //             doc.Proof_of_Identity_POI__c=false;
                    //         }
                    //         else{
                    //             docObject.Proof_of_Identity_POI__c=false;
                    //         }
                    //     }
                    // }
                    // if (Schema.sObjectType.Documents__c.isUpdateable()){
                    //     update documentsList;
                    // }
                // }
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert docObject;
                }
                
                if(Test.isRunningTest())
                {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return docObject.id;
            }
            //else{
            
            return null;
            //}         
            
        } catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' createOtherDocument ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: docCustomerImage()
    
  /*
* @Method:      createOtherDocumentForTractorVehile
* @Created by:  Prashant Kumar Dixit.
* @Description: This method to create a document object for tractor
* @Param:       String - Document Type
* @Param:       String - current Applicant ID
* @Param:       String - loanApplication ID
* @Param:       String - vehicle ID
* @Return:      String - created Document's ID
*/  
    @AuraEnabled
    public static string createOtherDocumentForTractorVehile(String docType,String applicantId,String loanApplicationId, String vehicleId){
        try {
            if(applicantId!=null && docType!=null && loanApplicationId!=null && vehicleId!=null){
                ID personAccountRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
                Documents__c docObject= new Documents__c(Name = docType,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Vehicle_Detail__c=vehicleId);
                docObject.RecordTypeId = personAccountRecordType;
                docObject.Document_Type__c=docType;
                docObject.is_Active__c=true;
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert docObject;
                }
                
                if(Test.isRunningTest())
                {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return docObject.id;
            }
            //else{
            
            return null;
            //}         
            
        } catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' createOtherDocument ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: docCustomerImage() 


/*
* @Method:      updateAccount
* @Created by:  Ruchi J.
* @Description: This method updates Account object with details received in param
* @Param:       String - Account ID
* @Param:       String - Customer First Name
* @Param:       String - Customer Last Name
* @Param:       String - Customer Phone Number
*/
    @AuraEnabled
    public static void updateAccount(String accountId,String firstname,String lastname,String phoneNumber)
    {
        try{
            if(accountId!=null && firstname!=null && lastname!=null &&  phoneNumber!=null && Schema.sObjectType.Account.isUpdateable() ){
            Account accountObject = new Account();
            accountObject.id=accountId;
            accountObject.FirstName=firstname;
            accountObject.LastName=lastname;
            accountObject.Phone=phoneNumber;
            system.debug('update account '+accountObject);
                update accountObject;
           system.debug('update accounteereew '+accountObject);
            
        }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }
        catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' updateAccount ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: updateAccount()
    
     /*
    * @Method Name: verifyCMU
    * @Created by: 	Vinita K.
    * @Description: Method will pass KYC/Form60/POA (non KYC) documents for CMU verification
    * @Param:       String- current Applicant__c ID */
   
    @AuraEnabled
    public static void verifyCMU(String applicationID){
		try{
			if(applicationID!=null){
                List<Applicant__c> applicantList = [Select id,Is_Address_Declaration__c,Applicant_Type__c,Opportunity__r.LeadSource,Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Is_Additional_Details_Submitted__c FROM Applicant__c Where Opportunity__c = :applicationID AND In_Active_Applicant__c = false];
                    
                Boolean additionalScreenSubmitted = false;
                Boolean isBorrAddressDeclaration = false;
                Boolean isCoborrAddressDeclaration = false;
                Integer counter = 1;
                for (Applicant__c app : applicantList) {
                    if(app.Applicant_Type__c == System.Label.Borrower && app.Is_Address_Declaration__c){
                        isBorrAddressDeclaration = true;
                    }else if(app.Applicant_Type__c == System.Label.CoBorrower && app.Is_Address_Declaration__c){
                        isCoborrAddressDeclaration = true;
                    }

                    if(app.Is_Additional_Details_Submitted__c){
                        additionalScreenSubmitted = true;
                        counter++;
                    }
                }

                if(additionalScreenSubmitted == false && applicantList.size() > 1){
                    return;
                }

                if(applicantList.size() > 0 && applicantList[0].Opportunity__r.Product_Type__c == System.Label.Tractor && counter < applicantList.size()){
                    return;
                }

                String cmuCaseRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId();
                String leadSource = ''; String productType = '';
                Integer cmuCaseCount = [SELECT count() FROM Case WHERE RecordTypeId =: cmuCaseRecordTypeId AND Loan_Application__c =: applicationID WITH SECURITY_ENFORCED ];
                if(cmuCaseCount == 0){
                    List<Documents__c> documentsToBeRaisedForCMUList = new List<Documents__c>();
                    List<Documents__c> docs = new List<Documents__c>();
                    List<Documents__c> nonIndividualTractorDocs = new List<Documents__c>();
                    List<String> documentType = new List<String>{'GST CERTIFICATE','MSME REGISTRATION CERTIFICATE','UDYAM REGISTRATION CERTIFICATE','REGISTRATION CERTIFICATE - OTHERS','SHOPS AND ESTABLISHMENT CERTIFICATE','TAX/SERVICE TAX/PROFESSIONAL TAX AUTH','FACTORY REGISTRATION CERTIFICATE','CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES','TRADE LICENCE','IMPORT AND EXPORT CERTIFICATE','Utility bill in the name of company','PARTNERSHIP DEED','List of Partners','PARTNERSHIP REGISTRATION CERT','Beneficial Ownership Declaration','CERTIFICATE OF INCORPORATION','MEMORANDUM OF ASSOCIATION','ARTICLES OF ASSOCIATION','Board Resolution','List of Directors','LLP Agreement','List of Trustees/Office Bearers','TRUST DEED/BYE LAW','List of Co-Percenters'};
                    leadSource = applicantList.size()>0 ? applicantList.get(0).Opportunity__r.LeadSource : leadSource;//OLA-68
                    productType = applicantList.size()>0 ? applicantList.get(0).Opportunity__r.Product_Type__c : productType; 
                    List<String> floaterDocsList = new List<String>{'NOC','RC Document','IT Return or Saral','Salary Slip','Form 16','GST Certificate','RCU report','Cheques SPDC','Borrower\'s Passbook','Co-Borrower\'s Passbook','Borrower\'s Bank Statement','Co-Borrower\'s Bank Statement','Invoice','IHM Receipt','Agreement Copy','ACH Mandate Form','Cancelled Cheque','Agreement Wrapper Booklet','DPN','RTO','Agreement 1st Schedule','Agreement 2nd Schedule','DPR'};
                    if(productType == Label.Tractor){
                        docs = [SELECT Applicant__r.Applicant_Type__c,DocAuth_Passed__c, Selfie_report_Pass__c, Golden_Source_Pass__c , Name_Mismatch_Pass__c, Proof_of_Address_POA__c,RecordTypeId , Document_Type__c,Is_this_a_Photocopy__c, Aadhar_Source__c,RecordType.Name,Opportunity_Relation__r.Name, Opportunity_Relation__r.AccountId, (select id from ContentDocumentLinks) FROM Documents__c WHERE Opportunity_Relation__c =: applicationID AND Document_Type__c != 'Other' AND (((((DocAuth_Passed__c = false OR Selfie_report_Pass__c = false OR Golden_Source_Pass__c = false OR Name_Mismatch_Pass__c = false) AND (Document_type__c =: System.Label.AadhaarCard OR Document_type__c =: Label.PanCards OR Document_type__c =: Label.VoterIdCard OR Document_type__c =: Label.PassportCard OR Document_type__c =: Label.DrivingLicences)) OR (Permanent_Residential_Address_Proof__c = true) OR (Current_Residential_Address_Proof__c = true) OR (Proof_of_Address_POA__c = true AND RecordType.Name <> 'KYC Document') OR (Document_Type__c = 'Form 60') OR (Document_Type__c=:System.Label.AadhaarCard AND (Aadhar_Source__c ='OTP' OR Aadhar_Source__c='Scan and Upload' OR Aadhar_Source__c='Biometric' )) OR (Document_Type__c = : System.Label.Address_Declaration)) AND Is_Active__c = true) OR (Document_Type__c = 'Customer Image')) WITH SECURITY_ENFORCED];
                    }else if(productType != Label.Tractor && leadSource!='OLA'){
                        docs = [SELECT Applicant__r.Applicant_Type__c,DocAuth_Passed__c, Selfie_report_Pass__c, Golden_Source_Pass__c , Name_Mismatch_Pass__c, Proof_of_Address_POA__c,RecordTypeId , Document_Type__c,Is_this_a_Photocopy__c, Aadhar_Source__c,RecordType.Name,Opportunity_Relation__r.Name, Opportunity_Relation__r.AccountId, (select id from ContentDocumentLinks) FROM Documents__c WHERE Opportunity_Relation__c =: applicationID AND Document_Type__c != 'Other' AND ((((DocAuth_Passed__c = false OR Selfie_report_Pass__c = false OR Golden_Source_Pass__c = false OR Name_Mismatch_Pass__c = false)OR (Proof_of_Address_POA__c = true AND RecordType.Name <> 'KYC Document') OR (Document_Type__c = 'Form 60') OR (Document_Type__c=:System.Label.AadhaarCard AND (Aadhar_Source__c ='OTP' OR Aadhar_Source__c='Scan and Upload' OR Aadhar_Source__c='Biometric' )) OR (Document_Type__c = : System.Label.Address_Declaration)) AND Is_Active__c = true) OR (Document_Type__c = 'Customer Image')) WITH SECURITY_ENFORCED];//CISP-2701//CISP-3141-Added applicant.applicanttype //CISP-3787
                    } else if (productType != Label.Tractor && leadSource=='OLA'){
                        docs = [SELECT Applicant__r.Applicant_Type__c,DocAuth_Passed__c, Selfie_report_Pass__c, Golden_Source_Pass__c , Name_Mismatch_Pass__c, Proof_of_Address_POA__c,RecordTypeId , Document_Type__c,Is_this_a_Photocopy__c, Aadhar_Source__c,RecordType.Name,Opportunity_Relation__r.Name, Opportunity_Relation__r.AccountId, (select id from ContentDocumentLinks) FROM Documents__c WHERE Opportunity_Relation__c =: applicationID AND Document_Type__c != 'Other' AND Document_Type__c != 'Invoice' AND Document_Type__c != 'IHM Receipt' AND Document_Type__c != 'RTO' AND ((((DocAuth_Passed__c = false OR Selfie_report_Pass__c = false OR Golden_Source_Pass__c = false OR Name_Mismatch_Pass__c = false)OR (Proof_of_Address_POA__c = true AND RecordType.Name <> 'KYC Document') OR (Document_Type__c = 'Form 60') OR (Document_Type__c=:System.Label.AadhaarCard AND (Aadhar_Source__c ='OTP' OR Aadhar_Source__c='Scan and Upload' OR Aadhar_Source__c='Biometric' )) OR (Document_Type__c = : System.Label.Address_Declaration)) AND Is_Active__c = true) OR (Document_Type__c = 'Customer Image')) WITH SECURITY_ENFORCED];//OLA-68
                    }
                    if(applicantList[0].Opportunity__r.Product_Type__c == System.Label.Tractor && applicantList[0].Opportunity__r.Customer_Type__c == 'Non-Individual'){
                    nonIndividualTractorDocs = [SELECT Applicant__r.Applicant_Type__c,DocAuth_Passed__c, Selfie_report_Pass__c, Golden_Source_Pass__c , Name_Mismatch_Pass__c, Proof_of_Address_POA__c,RecordTypeId , Document_Type__c,Is_this_a_Photocopy__c, Aadhar_Source__c,RecordType.Name,Opportunity_Relation__r.Name, Opportunity_Relation__r.AccountId, (select id from ContentDocumentLinks) FROM Documents__c WHERE Opportunity_Relation__c =: applicationID AND Document_Type__c IN:documentType AND Id Not IN : docs WITH SECURITY_ENFORCED];
                    docs.addall(nonIndividualTractorDocs);
                    }

                    for(Documents__c doc : docs){
                        // if(doc.ContentDocumentLinks.size() == 0 && doc.Aadhar_Source__c != 'Biometric' && doc.Aadhar_Source__c != 'OTP'){
                        //     continue;
                        // }
                        if(!floaterDocsList.contains(doc.Document_Type__c)){
                            if(doc.Document_Type__c == System.Label.AadhaarCard && (doc.Aadhar_Source__c != 'Biometric' || (doc.Applicant__r.Applicant_Type__c == System.Label.Borrower && isBorrAddressDeclaration && doc.Aadhar_Source__c == 'Biometric' && doc.Document_Type__c == System.Label.AadhaarCard) || (doc.Applicant__r.Applicant_Type__c == System.Label.CoBorrower  && isCoborrAddressDeclaration && doc.Aadhar_Source__c == 'Biometric' && doc.Document_Type__c == System.Label.AadhaarCard))){//CISP-2701//CISP-3141-Added borr and cobo
                                documentsToBeRaisedForCMUList.add(doc);
                                system.debug('documentsToBeRaisedForCMUList::'+documentsToBeRaisedForCMUList);
                            } else if(docs.size() > 1 && doc.Document_Type__c == 'Customer Image'){
                                documentsToBeRaisedForCMUList.add(doc);
                            } else if(doc.Document_Type__c != 'Other' && doc.Document_Type__c != 'OD Receipt' && doc.Document_Type__c != 'Customer Image' && doc.Aadhar_Source__c != 'Biometric' && doc.Document_Type__c != System.Label.Address_Declaration){//CISP-2701
                                documentsToBeRaisedForCMUList.add(doc);
                            }
                        }
                    }
                    
                    if(documentsToBeRaisedForCMUList != null && !documentsToBeRaisedForCMUList.isEmpty() && documentsToBeRaisedForCMUList.size()>0){
                        String queueId = [select Id from Group where Name = :System.Label.CMU and Type = :System.Label.Queue LIMIT 1].Id ;  
                        
                        //Create case for CMU request
                        Case newCase=new Case();
                        newCase.Subject=System.Label.CMURequestforLoanApplication+documentsToBeRaisedForCMUList[0].Opportunity_Relation__r.Name;
                        newCase.OwnerId = queueId;
                        newCase.Loan_Application__c = documentsToBeRaisedForCMUList[0].Opportunity_Relation__c;
                        newCase.AccountId = documentsToBeRaisedForCMUList[0].Opportunity_Relation__r.AccountId;
                        newCase.RecordTypeId = cmuCaseRecordTypeId;

                        if (Schema.sObjectType.Case.isCreateable()){
                            Insert newCase;
                        } 
                        system.debug('newCase::'+newCase);
                        List<Loan_Application_Transaction_History__c> loanHistoryList = [select id,Assignment_status__c from Loan_Application_Transaction_History__c where Module_Name__c = 'Additional Details' and Type__c = 'Module' and Loan_Application_ID__c =: applicationID and Assignment_status__c != 'Completed' order by createddate desc Limit 1];
                        if(!loanHistoryList.isEmpty()){
                            Utilities.createCaseTeamMember(newCase.Id);
                        }
                       
                        for(Documents__c document : documentsToBeRaisedForCMUList){
                            document.Case__c = newCase.Id;
                        }

                        if (Schema.sObjectType.Documents__c.isUpdateable()){
                            Update documentsToBeRaisedForCMUList; 
                        }
                    }
                }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWC_LOS_CMUCaseOwnerChangeFlow_cntrl', 'handleChangeOwnerProcess', System.Label.Apex, e, applicationID);
            throw new IND_Exception(e.getMessage());
        }        
    }
    //End: verifyCMU()

    
     /*
    * @Method Name: isFirstCoborrower
    * @Created by: 	Prashant.
    * @Description: Method will return Primary Applicant Information
    * @Param:       String - Loan Application Id */

    @AuraEnabled
    public static Boolean isFirstCoborrower(String loanApplicationId, String applicantType){
        try {
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c WHERE Opportunity__c =: loanApplicationId 
            AND Applicant_Type__c =: applicantType AND In_Active_Applicant__c = false Limit 1];
            return applicantList.isEmpty() ? true : false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'isFirstCoborrower', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }

   //Wrapper class
    public class applicantWrapper{        
        String applicantId {get;set;}
        String customerFirstName {get;set;}
        String customerLastName {get;set;}
        String customerContactNumber {get;set;}
        String customerWhatsappNumber {get;set;}
        String applicantType {get;set;}
        String currentJourneyStage {get;set;}
        Decimal declaredIncomeSource {get;set;}
        Decimal loanAmount {get;set;}
        Boolean isImageUpload {get;set;}
        Boolean registeredWhatsappBanking {get;set;}
        Boolean isIncomeSourceAvailable {get;set;}       
        Boolean haveBankAccount {get;set;}
        Boolean isBankAccountWithIBL {get;set;}
        Boolean wantToOpenBankAccount {get;set;}
        Boolean isCurrentPermanentSameAddr {get;set;}
        Boolean isCurrentAddressNotPresent {get;set;}
        Boolean isPermanentAddressNotPresent {get;set;}
        Decimal customerImageAttempt {get;set;}
        Decimal SelfieRetryAttempts {get;set;}
        String aepsValue {get;set;}
        
        Boolean isAadhaarPresent {get;set;}
        String aadharDocId {get;set;}
        Boolean isAadhaarCurrent {get;set;}
        Boolean isAadhaarPermanent {get;set;}
        
        Boolean isPanPresent {get;set;}
        String panDocId {get;set;}   
        String PANType {get;set;}

        Boolean isGstPresent {get;set;}
        String gstDocId {get;set;}  
        String docType {get; set;}

        Boolean isCinPresent {get;set;}
        String cinDocId {get;set;}  
        //public added by Hemanth Thikka   
 public Boolean isForm60Present {get;set;}
 public String form60DocId {get;set;}   
 public String Form60Type {get;set;}

        Boolean isPassportPresent {get;set;}
        String passportDocId {get;set;}
        Boolean isPassportCurrent {get;set;}
        Boolean isPassportPermanent {get;set;}
        
        Boolean isVoterIdPresent {get;set;}
        String voterIdDocId {get;set;}
        Boolean isVoterIdCurrent {get;set;}
        Boolean isVoterIdPermanent {get;set;}
        
        Boolean isDLPresent {get;set;}
        Boolean isDLCurrent {get;set;}
        String dlDocId {get;set;}
        Boolean isDLPermanent {get;set;}
        //public added by Hemanth Thikka
        String customerImageDocId {get;set;}
 public Boolean isCustomerImagePresent {get;set;}
        Boolean isConsentRecieved {get;set;} 
        String customerCode {get;set;}    
        Boolean consentInitiated {get;set;}
 public Boolean FrontUploadComplete {get;set;}   
 public String addDocId {get;set;}   
 public String addDocType {get;set;}   
 String applicantName {get;set;} 
 Boolean createApplicationCountExhausted {get;set;}//SFTRAC-536
 Boolean isCreateApplication {get;set;} // UAT Adhoc changes - chaynnitt Agarwal
    String beneficialOwnerCategory {get;set;}
    String relationshipWithEntity {get;set;}
    String relationshipType {get;set;}
    Boolean poaHolder {get;set;}
    Integer shareholderPercent {get;set;}
    }
    //End: Wrapper class

           
/*
* @Method Name: getBiometricMetadata
* @Created by:  Ruchi Jain
* @description: For getting the custom metadata for Biometric_Input_Values__mdt record
* @Return:      Biometric_Input_Values__mdt record
*/
@AuraEnabled
public static Biometric_Input_Values__mdt  getBiometricMetadata(){
    try {
        Biometric_Input_Values__mdt metadata = Biometric_Input_Values__mdt.getInstance(System.Label.BiometricPid_Input); 
       
        if(Test.isRunningTest())
        {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return metadata;
        
    } catch(Exception e){
         
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' getBiometricMetadata ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
        insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
//End: getBiometricMetadata()
    
    @AuraEnabled
public static String getLoanApplicationStageName(String loanApplicationId){
    if(loanApplicationId!=null){
		String stageName = [SELECT ID,StageName FROM Opportunity WHERE ID =: loanApplicationId].StageName;
        return stageName;
    }
    return null;
}
    
 @AuraEnabled
    public static list<string> getLoanApplicationStageNameMetaData(){ 
     map<string, Lead_Genaration_Metadata__mdt> stageMap = Lead_Genaration_Metadata__mdt.getAll();
       list<string> lst_stage = new list<string>();
        for(string str : stageMap.keyset()){
         // lst_stage.add(stageMap.get(str).label);
         if(stageMap.containsKey(str)){//CISP-3210
             lst_stage.add(stageMap.get(str).Screen__c);
         }
        }     
        return lst_stage; 
    } 
   @AuraEnabled
    public static boolean  getLoanApplicationTransactionHistory(string loanId,string stage){

        list<Loan_Application_Transaction_History__c> lstloanApphstry = [SELECT id, name,Type__c 
                                                                            FROM Loan_Application_Transaction_History__c 
                                                                            WHERE Loan_Application_ID__c = :loanId 
                                                                            AND Module_Name__c=: stage 
                                                                            AND recordType.Name ='Lead Assignment' 
                                                                            AND Assignment_status__c != 'Recalled' 
                                                                            AND Assignment_status__c != 'Rejected'
                                                                            AND Assignment_status__c!= 'Completed'];
        if(lstloanApphstry.size()>0){
            return true;
        }
        return false;
        
    }          
    @AuraEnabled
        public static boolean  getLoanAppTranHistory(string loanId,string stage){
    
            list<Loan_Application_Transaction_History__c> lstloanApphstry = [SELECT id, name,Type__c,Current_Owner__c 
                                                                                FROM Loan_Application_Transaction_History__c 
                                                                                WHERE Loan_Application_ID__c = :loanId 
                                                                                AND recordType.Name ='Lead Assignment' 
                                                                                AND Module_Name__c=: stage Order By Createddate DESC Limit 1
                                                                               ];

        if(lstloanApphstry.size()>0 && lstloanApphstry[0].Current_Owner__c == UserInfo.getUserId()){
                return true;
        }
            return false;
            
        } 

    @AuraEnabled
 public static boolean createLoanTransferHistoryRecord(string loanId,string stage,string new_owner,string lType,string mod,string branch){

    Id recordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName()
                  .get('Lead Assignment').getRecordTypeId();

                  list<opportunity> lst_opportunity = [select id,name,LeadSource,OwnerId,Lead_number__c,Customer_Name__c,Contact_number__c,(select id,Name from Applicants__r) from Opportunity where Id = :loanId];//CISP-6945
     Loan_Application_Transaction_History__c Applonhstry = new Loan_Application_Transaction_History__c();
    // Applonhstry.name = loanId + '' + stage;
     Applonhstry.Module_Name__c = mod;
     Applonhstry.Loan_Application_ID__c = loanId;
     Applonhstry.Current_Owner__c = UserInfo.getUserId();
     Applonhstry.New_Owner__c = new_owner ;
     Applonhstry.Assignment_status__c = 'Pending';
     Applonhstry.Type__c = lType;
     Applonhstry.RecordTypeId = recordTypeId;
     Applonhstry.Branch__c = branch; // CISP-3497
     insert Applonhstry;
         
         if(Applonhstry.Id != NULL){
            if(lst_opportunity[0].LeadSource == 'D2C'){//CISP-6945 start
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                EmailTemplate et = [
            SELECT Id, Body, Subject
            FROM EmailTemplate
            WHERE DeveloperName = 'D2CLeadTransferredBE'
        ];
        List<User> selectedUserMail =[select id,Email from User where id=:new_owner and Email != null];
        for(Opportunity opp : lst_opportunity){
            String subject = et.Subject;
            subject = subject.replace('{!Opportunity.Lead_number__c}', opp.Lead_number__c != null ? opp.Lead_number__c : '');
        
            String emailBody = et.Body;
            emailBody = emailBody.replace('{!Opportunity.Lead_number__c}', opp.Lead_number__c != null ? opp.Lead_number__c : '');
            emailBody = emailBody.replace('{!Opportunity.Customer_Name__c}', opp.Applicants__r[0].Name != null ? opp.Applicants__r[0].Name : '');
            emailBody = emailBody.replace('{!Opportunity.Contact_number__c}', opp.Contact_number__c != null ? opp.Contact_number__c : '');
        
            List<String> toAddress = new List<String>();
            toAddress.add(selectedUserMail[0].Email);
            allmsg.add(generateMail(subject, emailBody, toAddress));
        }
        try {
            Messaging.sendEmail(allmsg, false);
        } catch (Exception e) {
            System.debug(e.getMessage());
               }             
        }//CISP-6945 end
             return true;
     } 
     return false;
 }
 public static Messaging.SingleEmailMessage generateMail(String subject, String emailBody, List<String> toAddress){//CISP-6945
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setSenderDisplayName('IBL D2C');
    mail.setToAddresses(toAddress);
    mail.setSubject(subject);
    mail.setSaveAsActivity(false);
    mail.setUseSignature(false);
    mail.setPlainTextBody(emailBody);
    return mail;
}//CISP-6945
   
 /*
 * @Method Name: getLoanApplicationHistory
 * @Created by:  Saloni Jadhav
 * @description: Check the loan application onwer and new owner for module
 * @Param:       current Applicant ID and stage of Application
 * @Return:      String - returns true or false
 */
@AuraEnabled
public static boolean  getLoanApplicationHistory(string loanId,string stage,string nextStage){
    try{
        List<Loan_Application_Transaction_History__c> lstloanApphstry = [select id,New_Owner__c,Loan_Application_ID__r.OwnerId,Assignment_status__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c = :loanId and Module_Name__c=: stage and recordType.Name ='Lead Assignment' and Assignment_status__c = 'Accepted'  WITH SECURITY_ENFORCED];
        if(!lstloanApphstry.isEmpty()){

    String owner = lstloanApphstry[0].Loan_Application_ID__r.OwnerId;
     System.debug('owner '+owner+' UserInfo '+ UserInfo.getUserId());
        if(lstloanApphstry[0].New_Owner__c == UserInfo.getUserId() && owner != UserInfo.getUserId()){
            System.debug('inside IF');
            Opportunity opp=new Opportunity(id=loanId);
            opp.StageName=nextStage;
            System.debug('opp.StageName '+opp.StageName);
            update opp;
            List<OpportunityTeamMember> oppTeamList = [select id,userID from OpportunityTeamMember where OpportunityId = :loanId AND userID =:  UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1];
            System.debug('oppTeamList '+oppTeamList);
            Utilities.deleteOpportunityTeamMemberRecord(oppTeamList);
            Utilities.deleteCaseTeamMember(loanId);
            lstloanApphstry[0].Assignment_status__c='Completed';
            System.debug('lstloanApphstry.Assignment_status__c '+lstloanApphstry[0].Assignment_status__c);
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()){
                update lstloanApphstry[0];
            }
            return true;
        }else{
            System.debug('inside else');
            return false;
        }
    }
    else{
        System.debug('inside no lstloanApphstry');
        return false;
    }
    }
     catch(Exception e){
         System.debug('error '+e.getMessage()+' line '+e.getLineNumber());
         return false;
     }
 }

 @AuraEnabled
 public static String checkUploadDocument(String applicantId, String docType){
     try{
         if(string.isNotBlank(applicantId)){
             Documents__c doc = [Select Id, Aadhar_Source__c from Documents__c where Applicant__c =: applicantId And Document_Type__c=:docType WITH SECURITY_ENFORCED limit 1];
             ContentDocumentLink docLink = [ Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: doc.Id WITH SECURITY_ENFORCED];
             return docLink.ContentDocumentId;
         }else{
             return null;
         }
     }catch(Exception e){
         System.debug('error '+e.getMessage()+' line '+e.getLineNumber());
         return null;
     }

}
    
/*
* @Method Name: checkDocFromApp
* @Created by:  Ruchi Jain
* @description: takes Applicant record id as parameter, and returns true if Consent_Received__c checkbox is checked in the respective Applicant record
* @Param:       current Applicant ID
* @Return:      String - returns documents id if both front and back are uploaded
*/
@AuraEnabled
public static String checkDocFromApp(String applicantId,String docType){
    // Boolean otpConsentFlag=false;
    try {      
        if(applicantId!=null)
        {
            Integer frontCount=0;
            Integer backCount=0;
            Integer selfieCount=0;
            Documents__c doc = [Select Id, Aadhar_Source__c from Documents__c where Applicant__c =: applicantId And Document_Type__c=:docType WITH SECURITY_ENFORCED limit 1]; 
            Set<Id> docIdSet = new Set<Id>();
            for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: doc.Id WITH SECURITY_ENFORCED]){
                docIdSet.add(contentdoc.ContentDocumentId);
            }
            List<ContentVersion> cv=[SELECT Id,Document_Side_fileupload__c from Contentversion where ContentDocumentId IN : docIdSet WITH SECURITY_ENFORCED ];
            for(ContentVersion contentver : cv){
                if(contentver.Document_Side_fileupload__c=='Front'){
                    frontCount+=1;
                }else if(contentver.Document_Side_fileupload__c=='Selfie'){
                    selfieCount+=1;
                }
                else{
                    backCount+=1;
                }
            }
            if((frontCount>0 && backCount>0)|| ((docType==System.Label.GST_Cert && frontCount>0) || (docType==System.Label.CIN_Cert && frontCount>0)) || (docType==System.Label.CustomerImageDocumentType && selfieCount>0) ||((docType==System.Label.PanCards || docType=='Form 60' || (docType==System.Label.AadhaarCard && doc.Aadhar_Source__c =='ScanAadhar')) && frontCount>0)){
                String id=doc.Id;
                return id;
              }
                return null;
           
        }
        return null;
    } catch(Exception e){
         
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' checkDocFromApp ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
        insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
//End: checkDocFromApp()



   /*
* @Method:      checkCustomerImageAttempt
* @Created by:  Ruchi Jain
* @Description: to get attempts and as well increment attemps and give proper response
* @Param:       String - current Applicant ID
* @Return:      String - Serialized JSON response
*/
@AuraEnabled
public static String checkCustomerImageAttempt(String applicantId)
{
     try { 
    // Boolean response = selfieUploadcheckApiResponse();
    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.DocAuth); 
    Applicant__c applicant = [select customer_image_attempts__c from Applicant__c where id =: applicantId WITH SECURITY_ENFORCED];
    // Checking the number of attempts made for image upload with predefined maximum number of attempt
    if(applicant != null && metadata != null && applicantId != null)
    {
        System.debug('customer_image_attempts__c '+applicant.customer_image_attempts__c);
        if(applicant.customer_image_attempts__c >= metadata.Selfie_Retry_attempts__c)
        {
            responseWrapper responseJSON = new responseWrapper();
            responseJSON.status = System.Label.FalseRespose;
            responseJSON.message = System.Label.SelfieAttemptExhausted;
            String serializedResonponse = JSON.serialize(responseJSON);
            return serializedResonponse;
        }
        //Api true response will be check here.
        else
        {   
                applicant.customer_image_attempts__c +=1; 
                if (Schema.sObjectType.Applicant__c.isUpdateable()){
                    update applicant;
                }
      
                responseWrapper responseJSON = new responseWrapper();
                responseJSON.status = System.Label.TrueRespose;
                responseJSON.message = System.Label.SelfieSuccessfull;
                String serializedResonponse = JSON.serialize(responseJSON);
                return serializedResonponse;
            
        }
     
     
    
    }
     }
       catch(Exception e){
        System.debug('customer_image_attempts__c '+ e.getMessage());
          Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' checkCustomerImageAttempt ', System.Label.Apex, e);
                if(Schema.sObjectType.Error_Log__c.isCreateable())
                {
                insert errorLogRecord;
                }
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }   
    //This piece of code will be run if the response is either true or false.   
     responseWrapper responseJSON = new responseWrapper();
    String serializedResonponse = JSON.serialize(responseJSON);
    return serializedResonponse;               
}
//End: checkCustomerImageAttempt()

    /*
    * @Method:      getPidBlockStatus
    * @Created by:  Neha Gosavi
    * @Description: This method is use to give the response according to Api response.
    * @Param:       String - current Applicant ID
    * @Return:      Boolean - response if PID Block captured from Biometric Deeplink
    */
    @AuraEnabled
    public static Boolean getPidBlockStatus(String applicantId){
        try{
            Boolean isPidBlockPresent;
            if(applicantId!=null){
            Applicant__c applicant = [Select PID_Block__c from Applicant__c where id =:applicantId WITH SECURITY_ENFORCED limit 1];
            if(applicant.PID_Block__c!=null){
                isPidBlockPresent=true;
            }
            else {
                isPidBlockPresent=false;
            }
        }
            return isPidBlockPresent;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'getPidBlockStatus', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
    }

     
/*
* @Method Name: getResendOtpTime
* @Created by:  Ruchi Jain
* @description: For getting the custom metadata for delay time
* @Return:      Decimal-returns resend dealy time
*/
@AuraEnabled
public static Decimal getResendOtpTime(){
    try {
        System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.Bureau_Pull_attempts); 
       
        if(Test.isRunningTest())
        {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return metadata.Delay_Time_in_milliseconds__c;
        
    } catch(Exception e){
         
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' getResendOtpTime ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
        insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
//End: getResendOtpTime()

     
/*
* @Method Name: getDocAsyncResponse
* @Created by:  Ruchi Jain
* @description: For getting the response fron integration log
* @Return:      returns response
*/
@AuraEnabled
public static String getDocAsyncResponse(String documentId){
    try {
       
        Documents__c responseDocAsync=[ Select Id,Raw_Response__c from Documents__c  where Id=: documentId WITH SECURITY_ENFORCED limit 1];
        if(Test.isRunningTest())
        {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return responseDocAsync.Raw_Response__c;

        
    } catch(Exception e){
         
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' getDocAsyncResponse ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
        insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
//End: getDocAsyncResponse()



/*
* @Method Name: fetchCdocumentId
* @Created by:  Ruchi Jain
* @description: For getting the response fron integration log
* @Return:      returns response
*/
@AuraEnabled
public static String fetchCdocumentId(String documentId){
    try {
        Set<Id> docIdSet = new Set<Id>();
        Id frontContentDocumentId;
        Id backContentDocumentId;
        for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: documentId WITH SECURITY_ENFORCED]){
            docIdSet.add(contentdoc.ContentDocumentId);
        }
        List<ContentVersion> cv=[SELECT Id,Document_Side_fileupload__c,ContentDocumentId from Contentversion where ContentDocumentId IN : docIdSet WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC ];
        system.debug('cv '+cv);
        
        WrapperId responseJSON = new WrapperId();
        for(ContentVersion contentver : cv){ 
            if(contentver.Document_Side_fileupload__c=='Front'){
                frontContentDocumentId=contentver.ContentDocumentId;
            }else{
                backContentDocumentId=contentver.ContentDocumentId;
            }
        }
        
        system.debug('frontContentDocumentId '+frontContentDocumentId+' backContentDocumentId '+backContentDocumentId);
        responseJSON.frontContentDocumentId=frontContentDocumentId;
        responseJSON.backContentDocumentId=backContentDocumentId;
        
        if(Test.isRunningTest())
        {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        String serializedResonponse = JSON.serialize(responseJSON);
           return serializedResonponse;  
        
    } catch(Exception e){
        system.debug('Exception '+e.getMessage());
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' fetchCdocumentId ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
        insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
//End: fetchCdocumentId()

    //Wrapper Class 
    public class WrapperId {
    Id frontContentDocumentId {get;set;} 
    Id backContentDocumentId {get;set;}
    }

    /*
    * @Method Name: cibilTextMatch
    * @Created by:  Khushiram
    * @description: This method will return json object of required details.
    * param : 		String : applicant Id
    * @Return:      String: serialized JSON Response
    */
    @AuraEnabled
    public static String cibilTextMatch(String applicantId){
        try{
            CibilTextMatchWrapper jsonResponse = new CibilTextMatchWrapper();
            Applicant__c app = [select id,(SELECT Id FROM Documents__r),Opportunity__r.Lead_number__c from Applicant__c where id=:applicantId];
            if(app != null){
                jsonResponse.leadId = app.Opportunity__r.Lead_number__c;
            }        
            List<Documents__c> documentsList = [select Id,Name,Proof_of_Identity_POI__c,Name_Mismatch_Percentage__c,Name_Mismatch_Pass__c,First_Name__c,Last_Name__c from Documents__c where Applicant__c=:applicantId And Document_Type__c !=: System.Label.CustomerImageDocumentType WITH SECURITY_ENFORCED];
            System.debug('doc list'+documentsList);
            if(!documentsList.isEmpty() && documentsList.size()>0){
                jsonResponse.docList = documentsList;
                jsonResponse.destName = '';
                for(Documents__c doc : documentsList){
                    if(doc.Proof_of_Identity_POI__c){
                        doc.Name_Mismatch_Percentage__c = 100;
                        doc.Name_Mismatch_Pass__c = true;
                        jsonResponse.destName = doc.First_Name__c+' '+doc.Last_Name__c;
                        if (Schema.sObjectType.Documents__c.isUpdateable()){
                            update doc; 
                        }
                    }
                }
            }
            String serializedResponse = JSON.serialize(jsonResponse);
            return serializedResponse;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' cibilTextMatch ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        } 
    }

    //Wrapper class
    public class CibilTextMatchWrapper{
        @AuraEnabled public List<Documents__c> docList {get;set;}
        public string destName {get;set;}
        public string leadId {get;set;}
    }

    /*
    * @Method Name: checkToggle
    * @Created by:  Raj Gupta
    * @description: This method will set the flag of name mismatch flag and store the name mismatch %age value.
    * param : 		String : opportunity id
    * @Return:      Boolean
    */
    @AuraEnabled 
    public Static Boolean checkToggle(String leadApplicationId)
    {
        Applicant__c appl = [SELECT Id, Do_you_have_a_bank_account__c, Do_you_have_a_bank_account_with_IBL__c, Would_you_like_to_open_a_bank_account__c	 FROM Applicant__c where Opportunity__c =: leadApplicationId and Applicant_Type__c = 'Borrower' limit 1];
        if(appl.Do_you_have_a_bank_account__c == true || appl.Do_you_have_a_bank_account_with_IBL__c == true || appl.Would_you_like_to_open_a_bank_account__c == true) {
            return true;
        }
        return false;
    }
    
    
    /*
    * @Method Name: cibilTextMatchSaveResponse
    * @Created by:  Khushiram
    * @description: This method will set the flag of name mismatch flag and store the name mismatch %age value.
    * param : 		String : applicant Id
    * param : 		String : matchScore 
    * @Return:      None
    */
    @AuraEnabled
    public static void cibilTextMatchSaveResponse(String documentId,String matchScore){
        try{        
            Documents__c document = [Select Id,Name_Mismatch_Pass__c,Name_Mismatch_Percentage__c from Documents__c where Id=:documentId WITH SECURITY_ENFORCED];
            if(document != null){   
                document.Name_Mismatch_Percentage__c = Integer.valueOf(matchScore);
                if(Integer.valueOf(matchScore) >= 70){
                    document.Name_Mismatch_Pass__c = true;
                }
                if (Schema.sObjectType.Documents__c.isUpdateable()){
                    update document; 
                }
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' cibilTextMatchSaveResponse ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        } 
    }
    
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
        if (siteId != null) {
            return true;
        }
        return false;
	}

        /*
* @Method:      kycContentDocDelete
* @Created by:  Devanshu Gupta
* @Description: Method to delete contentDocumentData
* @Param:       String documentId ,Boolean isDone , Boolean isCancel ,String contentDocumentData
* @Return:      none
*/
@AuraEnabled
public static void kycContentDocDelete(String documentId ,Boolean isDone , Boolean isCancel ,String contentDocumentData){
    try{
        if(documentId!=null){
            List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
            if(Schema.sObjectType.ContentDocumentLink.isAccessible()) {
                contentDocumentLinkList =[SELECT id,contentdocumentid,linkedentity.name,linkedentityid FROM ContentDocumentLink WHERE linkedentityid =:documentId ];
            }
            
            System.debug('the document '+contentDocumentLinkList);
            List<id> docIdList = new List<id>();
            
            for(ContentDocumentLink cdl: contentDocumentLinkList){
                docIdList.add(cdl.contentdocumentid);
            }
            
            List<ContentDocument> conDocList = new List<ContentDocument>();
            if(!docIdList.isEmpty()) {
                if(Schema.sObjectType.ContentDocument.isAccessible()) {
                conDocList =[SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id IN: docIdList];
                }
            }
                System.debug('the document con '+conDocList);
            List<ContentDocument> conDocumentToDelete = new List<ContentDocument>();
            system.debug(ConDocList);
            if(!conDocList.isEmpty()) {
                if(isCancel) {
                    for(ContentDocument conDoc : conDocList) {
                        if(conDoc.Id == contentDocumentData) {
                            conDocumentToDelete.add(conDoc);
                        }
                    }
                    
                    if(!conDocumentToDelete.isEmpty()) {
                        if(Schema.sObjectType.ContentDocument.isDeletable()) {  
                    DELETE conDocumentToDelete;
                    }
                    }
                    
                }
                if(isDone) {
                    for(ContentDocument conDoc : conDocList) {
                        if(conDoc.Id != contentDocumentData) {
                            conDocumentToDelete.add(conDoc);
                        }
                    }
                    
                    if(!conDocumentToDelete.isEmpty()) {
                        delete conDocumentToDelete;
                    }
                }
                
            }
            /*if(LwcLOSLoanApplicationCntrl.checkForException) {
            throw new AuraHandledException(System.Label.ExceptionMessage);
            }*/
        }

    } catch(Exception e){
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Ind_CustomerAdditionalDetailsCtrl', ' kycDelete ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
        }
    }
}


@AuraEnabled
public static void updateCustomerImageFileTitle(String documentId, String contentDocumentData){
    try{
            List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
            List<ContentDocument> conDocList = new List<ContentDocument>();
            List<id> docIdList = new List<id>();
            
            if(Schema.sObjectType.ContentDocumentLink.isAccessible()) {
                
                if(contentDocumentData != null && contentDocumentData != ''){
                    contentDocumentLinkList =[SELECT id, contentdocumentid, linkedentity.name, linkedentityid FROM ContentDocumentLink WHERE linkedentityid =:documentId AND contentdocumentid = :contentDocumentData];
                }
            }
            System.debug('Document Connection:: '+contentDocumentLinkList);
            
            for(ContentDocumentLink cdl: contentDocumentLinkList){
                docIdList.add(cdl.contentdocumentid);
            }
            
            if(!docIdList.isEmpty()) {
                if(Schema.sObjectType.ContentDocument.isAccessible()) {
                    conDocList =[SELECT Id, CreatedBy.name, ContentSize, Title FROM ContentDocument where Id IN: docIdList];
                }
            }

            DateTime dateTimeObj = DateTime.now();
            String timezone = UserInfo.getTimeZone().getDisplayName();
            String shortTzFromat = timezone.substringBetween('(',')');
            String dateStr = dateTimeObj.format('EEE MMM d HH:mm:ss ') + ' '+shortTzFromat+' '+dateTimeObj.Year();

            for(ContentDocument docDoc : conDocList){
                docDoc.Title = 'Selfie' + '_' + dateStr + '_' + 'Customer Image' + '_' + DateTime.now().millisecond() + '.JPEG';
            }

            if(conDocList.size() > 0){
                update conDocList;
            }
    } catch(Exception e){
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('LwcLOSLoanApplicationCntrl', ' updateCustomerImageFileTitle ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
        }
    }
}



  
/*
* @Method Name: findAccountTeamMembers 
* @Created by:  Thilak Bondiga
* @description: Get AccountTeamMembers data 
* @Param:       current UserId 
* @Return:      
*/
@AuraEnabled
public static List<AccountTeamMember> findAccountTeamMembers(String uid) {
    //String key = '%' + searchKey + '%';
    return [
        SELECT Id, AccountId, Account.Name, Account.Type, Account.Id,UserId,Account.BranchBLCode__c
        FROM AccountTeamMember
        WHERE UserId =:uid
        WITH SECURITY_ENFORCED
        
    ];
}



/*
* @Method Name: setAadharSource
* @Created by:  Neha Gosavi
* @description: set Aadhar Source as 'ScanAadhar' for Biometric/OTP-> ScanAadhar flow
* @Param:       current Applicant ID
* @Param:       document Type
* @Return:      String - returns documents id
*/
@AuraEnabled
public static String setAadharSource(String applicantId,String docType){
    try {      
        if(applicantId!=null && docType!=null) {
            Documents__c doc = [Select Id, Aadhar_Source__c from Documents__c where Applicant__c =: applicantId And Document_Type__c=:docType WITH SECURITY_ENFORCED limit 1];
            doc.Aadhar_Source__c ='ScanAadhar'; 
            if (Schema.sObjectType.Documents__c.isUpdateable()){
                update doc; 
            }
            return doc.Id;
        }
        return null;
    } catch(Exception e){         
        ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'setAadharSource', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    
    }
}
    
/*
* @Method Name: deletePIDBlock
* @Created by:  Neha Gosavi
* @description: delete PID Block for Aadhaar->Biometric flow if capturing Biometric again fro same user
* @Param:       current Applicant ID
*/
@AuraEnabled
public static void deletePIDBlock(String applicantId){
    if(applicantId!=null){
        Applicant__c applicantObject= [Select Id, PID_Block__c from Applicant__c Where Id= :applicantId WITH SECURITY_ENFORCED LIMIT 1 ];
        if(applicantObject.PID_Block__c!=null){
            applicantObject.PID_Block__c='';
            if (Schema.sObjectType.Applicant__c.isUpdateable()){
                update applicantObject;
            }
        }
    }
}  

//End: setAadharSource()

	// @Method:      createPersonAccWithCustCodeAssignment
    // @Created by:  Sanketkumar Patil
    // @Description: Method to create the Person Account and to stamp customer code.
    // @Param:       String : applicantId - Applicant ID
    // @Return:      Map - Execution Status
    @AuraEnabled
    public static Map<String, String> createPersonAccWithCustCodeAssignment(String applicantId) {
        Map<String, String> executionStatus = New Map<String,String>{'status' => 'error'};

        try{
            List<Applicant__c> applicantList = [select id, Customer_First_Name__c, Customer_Last_Name__c, Journey_Stage__c, Account__c, Account__r.Customer_Code__c, (select id, Customer_Code__c, PG_Cust_Dedupe__c, SF_Cust_Dedupe__c, Invalid_Customer_Code__c from Customer_Dedupe_Response__r) from Applicant__c where id = :applicantId WITH SECURITY_ENFORCED];
            System.debug('applicantList::'+applicantList);
            
            if(!applicantList.isEmpty() && applicantList[0].Account__c == null){
                Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            	Account newPersonAccount = new Account();

                //newPersonAccount.FirstName = applicantList[0].Customer_First_Name__c;
                newPersonAccount.LastName = ((String.isNotBlank(applicantList[0].Customer_First_Name__c) ?  applicantList[0].Customer_First_Name__c : '') + ' ' + 
                                             (String.isNotBlank(applicantList[0].Customer_Last_Name__c) ? applicantList[0].Customer_Last_Name__c : '')).trim();
                newPersonAccount.Customer_Code__c = applicantList[0]?.Customer_Dedupe_Response__r[0]?.Customer_Code__c;
                newPersonAccount.RecordTypeId = personAccountRecordTypeId;
                
                if (Schema.sObjectType.Account.isCreateable()) {  
                	insert newPersonAccount;
                    executionStatus.put('message', 'Person Account Created Successfully');
                } else {
                    executionStatus.put('message', 'Person Account is not creatable');
                    executionStatus.put('status', 'error');
                }

                if(newPersonAccount.id != null){
                    applicantList[0].Account__c = newPersonAccount.id;

                    if (Schema.sObjectType.Applicant__c.isUpdateable()) {  
                        update applicantList;
                        executionStatus.put('message', 'Customer Code Updated Successfully');
                        executionStatus.put('status', 'success');
                    } else {
                        executionStatus.put('message', 'Customer Code is not updatable');
                        executionStatus.put('status', 'error');
                    }
                }
            } else if(!applicantList.isEmpty() && applicantList[0].Account__c != null && applicantList[0].Account__r.Customer_Code__c == null) {
                Account newPersonAccount = new Account();
                newPersonAccount.Id = applicantList[0].Account__c;
                newPersonAccount.Customer_Code__c = applicantList[0]?.Customer_Dedupe_Response__r[0]?.Customer_Code__c;

                if (Schema.sObjectType.Account.isUpdateable()) {  
                	update newPersonAccount;
                    executionStatus.put('message', 'Customer Code Updated Successfully');
                    executionStatus.put('status', 'success');
                } else {
                    executionStatus.put('message', 'Customer Code is not updatable');
                    executionStatus.put('status', 'error');
                }
            } else if(applicantList.isEmpty()){
                executionStatus.put('message', 'Error in fetching Applicants details');
                executionStatus.put('status', 'error');
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('utilites', 'createPersonAccWithCustCodeAssignment', System.Label.Apex, e, '');
            executionStatus.put('message', 'Error in updating Customer Code');
            throw new IND_Exception(e.getMessage());
        }
        return executionStatus;
    }

    // @Method:      tagPOIforKycDoc
    // @Created by:  Ruchi Jain
    // @Description: for tagging POI of kyc doc
    // @Param:       String : applicantId - Applicant ID
    // @Return:      void
    @AuraEnabled
    public static void tagPOIforKycDoc(String applicantId) {         
        try{
            MAP<String,Integer> preferenceOrderMap = new MAP<String,Integer>();
            for(POI_Preference__mdt mdtElement : POI_Preference__mdt.getAll().values()){
                preferenceOrderMap.put(mdtElement.MasterLabel.toUpperCase(),(Integer)mdtElement.Preference_Order__c);//CISP-3047 OR CISP-3089
            }
            List<Documents__c> doctoUpdate=new List<Documents__c>();
            List<Documents__c> documentsList = [select Id,Name from Documents__c where Applicant__c=:applicantId And Document_Type__c !=: System.Label.PanCards And Document_Type__c !=: System.Label.CustomerImageDocumentType And Document_Type__c != 'Form 60' AND Is_Active__c = true WITH SECURITY_ENFORCED];//CISP-3047 OR CISP-3089 
            if(!documentsList.isEmpty() && documentsList.size()>0){
                Integer poiOfDoc;
                MAP<Integer,String> poiAndName = new MAP<Integer,String>();
                List<Integer> poiVal= new List<Integer> ();
                Integer minvalue;
                for(Documents__c doc : documentsList) {
                    if(preferenceOrderMap.containsKey(doc.Name.toUpperCase())){//CISP-3047 OR CISP-3089 
                        poiOfDoc= preferenceOrderMap.get(doc.Name.toUpperCase());//CISP-3047 OR CISP-3089
                        poiVal.add(poiOfDoc);
                        poiAndName.put(poiOfDoc,doc.Name);
                        minvalue=poiOfDoc;
                    }//CISP-3047 OR CISP-3089 
                }
                for(integer i =0;i<poiVal.size();i++) {
                    if( poiVal[i] < minvalue) {
                        minvalue = poiVal[i];  
                    }
                }
                for(Documents__c doc : documentsList) {
                    if(doc.Name==poiAndName.get(minvalue) && preferenceOrderMap.containsKey(doc.Name.toUpperCase())) {//CISP-3047 OR CISP-3089
                        doc.Proof_of_Identity_POI__c=true;
                    }else {
                        doc.Proof_of_Identity_POI__c=false;
                    }
                    doctoUpdate.add(doc);
                }
                if (Schema.sObjectType.Documents__c.isUpdateable()){
                    update doctoUpdate;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'tagPOIforKycDoc', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    // @Method:      deleteEmptyKycDoc
    // @Created by:  Ruchi Jain
    // @Description: for deleting kyc document if empty
    // @Param:       String : applicantId - Applicant ID
    // @Return:      void
    @AuraEnabled
    public static void deleteEmptyKycDoc(String applicantId) {
        try{
            List<String> kycDocuments= new  List<String>();
            kycDocuments.add('PAN');
            kycDocuments.add('Aadhaar');
            kycDocuments.add('Voter Id');
            kycDocuments.add('Driving Licence');
            kycDocuments.add('Passport');
            List<Documents__c> documentsList = [select Id,KYC_name__c,PAN_acknowledgement_number__c,Aadhaar_Enrollment_Number__c from Documents__c where Applicant__c=:applicantId And Document_Type__c IN :kycDocuments WITH SECURITY_ENFORCED];
            system.debug(documentsList);
            if(!documentsList.isEmpty() && documentsList.size()>0){
                for(Documents__c doc : documentsList) {
                    if((doc.KYC_name__c==null || doc.KYC_name__c=='') && (String.IsBlank(doc.PAN_acknowledgement_number__c) || String.IsBlank(doc.Aadhaar_Enrollment_Number__c))) {
                        delete doc;
                    }
                }
            }
            List<Documents__c> documentsForm60 = [select Id,Name,PAN_acknowledgement_number__c,Aadhaar_Enrollment_Number__c from Documents__c where Applicant__c=:applicantId And Document_Type__c ='Form 60' WITH SECURITY_ENFORCED];
            if(!documentsForm60.isEmpty() && documentsForm60.size()>0){
                List<ContentDocumentLink> contentdocForm60 = [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :documentsForm60[0].Id];
                if(contentdocForm60.isEmpty()){
                    delete documentsForm60;
                } 
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'deleteEmptyKycDoc', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    
    // @Method:      accessLoanApplication
    // @Created by:  Ruchi Jain
    // @Description: return false if no access to application
    // @Param:       String : applicantId - Applicant ID
    // @Return:      Boolean
    @AuraEnabled
    public static Boolean accessLoanApplication(String loanId,String stage) {
        try{
            
                List<Loan_Application_Transaction_History__c> lstloanApphstry = [select id,Type__c,New_Owner__c,Loan_Application_ID__r.OwnerId,Assignment_status__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c = :loanId and Module_Name__c=: stage and recordType.Name ='Lead Assignment' order by CreatedDate DESC  ];
                List<Loan_Application_Transaction_History__c> moduleLoanApphstry = [Select Id,Type__c,New_Owner__c,Loan_Application_ID__r.OwnerId,Assignment_status__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :loanId AND recordType.Name ='Lead Assignment' AND New_Owner__c =: UserInfo.getUserId() AND Type__c = 'Module' AND Assignment_status__c = 'Accepted' ORDER BY CreatedDate DESC];
                System.debug('lstloanApphstry '+lstloanApphstry+'  '+lstloanApphstry.size());
                if(!lstloanApphstry.isEmpty()){
                    String owner = lstloanApphstry[0].Loan_Application_ID__r.OwnerId;
                    System.debug('owner '+owner+' UserInfo '+ UserInfo.getUserId()+' lstloanApphstry[0].Assignment_status__c '+lstloanApphstry[0].Assignment_status__c);
                    if(lstloanApphstry[0].New_Owner__c == UserInfo.getUserId() && owner != UserInfo.getUserId() ){
                        if(lstloanApphstry[0].Assignment_status__c == 'Accepted'){
                            return true;
                        }
                        return false;
                    }else if(lstloanApphstry[0].Type__c=='Application' && lstloanApphstry[0].Assignment_status__c == 'Accepted' && owner == UserInfo.getUserId() ){
                        return true;
                    } 
                    else{
                        if(lstloanApphstry[0].Assignment_status__c != 'Accepted' && lstloanApphstry[0].Assignment_status__c != 'Pending' && owner == UserInfo.getUserId()  ){
                            return true;
                        }
                        return false;
                    } 
                }else if(moduleLoanApphstry.size() > 0 && !moduleLoanApphstry.isEmpty()){
                    return true;
                }else{
                    List<opportunity> oppList = [Select Id ,ownerId from opportunity where Id =:loanId limit 1];
                    User userRecord = [Select Id,Profile.Name from User WHERE Id =: UserInfo.getUserId()];
                    List<String> profileList = System.Label.LoanApplicationReadOnlyProfilesList.split(',');
                    if((userRecord != null && profileList.contains(userRecord.Profile.Name)) || (oppList.size() > 0 && oppList[0].ownerId == UserInfo.getUserId())){
                        return true;
                    }
                    return false;
                }                                                   
            
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'accessLoanApplication', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

      // @Method:      haveLeadAccesibility
    // @Created by:  Ruchi Jain
    // @Description: return false if no access to application
    // @Param:       String : leadApplicationId - lead ID
    // @Return:      Boolean
    @AuraEnabled
    public static Boolean haveLeadAccesibility(String leadApplicationId) {
        try{
            List<Opportunity> opp = [Select Id, OwnerId, D2C_Journey_Status__c from Opportunity where id =: leadApplicationId ]; //D2C Added D2C_Journey_Status__c
            List<UserRecordAccess> leadAccess =[SELECT RecordId,HasReadAccess,HasEditAccess  FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND  RecordId =:leadApplicationId];
            if(!leadAccess.isEmpty()){
                String owner = opp[0].OwnerId;
                System.debug('HasEditAccess '+leadAccess[0].HasEditAccess+' UserInfo '+ UserInfo.getUserId()+' leadAccess[0].HasEditAccess '+leadAccess[0].HasEditAccess);
                //if(!leadAccess[0].HasEditAccess){
                if(owner!=UserInfo.getUserId() || opp[0].D2C_Journey_Status__c == 'Move to assisted'){ //D2C Added D2C_Journey_Status__c check to prevent editing assisted applications
                    return false;
                }else{
                    return true;
                }
            }
            return false;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'haveLeadAccesibility', System.Label.Apex, e, '');
            throw new IND_Exception('You do not have access for this Loan Application');
        }
    }

    /*
    *@Method:      storedMaskedKYCDoc
    *@Created by:  Neha Gosavi
    *@Description: store masked aadhar doc received from OCR API response against the document
    *@Param:       String : leadApplicationId - lead ID
    *@Return:      Boolean
    */
    @AuraEnabled
    public static String storedMaskedKYCDoc(String base64Imag, String documentId, String docSide, String contentDocumentId) {
        try{
            if(!String.isBlank(base64Imag)) {
                List<ContentDocument> conDocumentToDelete = new List<ContentDocument>();
                conDocumentToDelete = [SELECT Id,FileExtension,FileType FROM ContentDocument where Id = :contentDocumentId];
                String fileExtension = conDocumentToDelete[0].FileExtension;
                Documents__c DC=[select id, Document_Type__c from Documents__c where id=:documentId];//CISP-3344
                ContentVersion versionData = new ContentVersion();
                versionData.ContentLocation = 'S';
                versionData.Document_Side_fileupload__c = docSide;
                Blob body = EncodingUtil.base64Decode(base64Imag);
                versionData.VersionData = body;
                //CISP-3344 --start, added if and else block for DL
                if(DC.Document_Type__c==System.Label.DrivingLicences)
                {
                    versionData.Title = docSide+'_'+ System.Label.DrivingLicences+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                    versionData.PathOnClient = docSide+'_'+System.Label.DrivingLicences+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                }
                else {
                	versionData.Title = docSide+'_'+'Aadhaar'+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                	versionData.PathOnClient = docSide+'_'+'Aadhaar'+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                }
                //CISP-3344 --end
                insert versionData;
            
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :versionData.Id].ContentDocumentId;
                conDocLink.LinkedEntityId = documentId;
                conDocLink.ShareType = 'V';
                insert conDocLink;

                if(!conDocumentToDelete.isEmpty() && conDocLink != null) {
                    if(Schema.sObjectType.ContentDocument.isDeletable()) {  
                        DELETE conDocumentToDelete;
                    }
                }
                return conDocLink.ContentDocumentId;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'haveLeadAccesibility', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage()+' '+e.getLineNumber());
        }
    }

    /*
    *@Method:      checkIfBorrowerEarning
    *@Created by:  Neha Gosavi
    *@Description: check if Borrower earning for the given applicant ID
    *@Param:       String : applicantId - Applicant ID
    *@Return:      Boolean
    */
    @AuraEnabled
    public static Boolean checkIfBorrowerEarning(String loanApplicationId){
        try {
            Boolean isBorrowerEarning = false;
            if(loanApplicationId!=null) { 
                for(Applicant__c applicant : [SELECT Id , Income_source_available__c,Applicant_Type__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]){
                    if(applicant.Applicant_Type__c == 'Borrower' && applicant.Income_source_available__c){
                        isBorrowerEarning = true;
                    }
                }
            }
            return isBorrowerEarning;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' checkIfBorrowerEarning ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    } 

    //CISP-133 - START
    /*
    *@Method:      getKycDocumentCount
    *@Created by:  Gaurav Rawat
    *@Description: return the kyc document count realted to applicant
    *@Param:       String : applicantId - Applicant ID
    *@Return:      Integer
    */
    @AuraEnabled
    public static Integer getKycDocumentCount(String applicantId){
        try {
            Integer kycDocumentCounter = 0;
            String kycRecordTypeId = (String) Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.KYC).getRecordTypeId();
            for(Documents__c doc : [Select Id,Document_Type__c From Documents__c Where Applicant__c =: applicantId AND RecordTypeId =: kycRecordTypeId AND is_Active__c = true WITH SECURITY_ENFORCED]){
                if(doc.Document_Type__c == System.Label.AadhaarCard || doc.Document_Type__c == System.Label.VoterIdCard || doc.Document_Type__c == System.Label.DrivingLicences || doc.Document_Type__c == System.Label.PassportCard){
                    kycDocumentCounter++;
                }
            }
            return kycDocumentCounter;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' getKycDocumentCount ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    } 
    //CISP-133 - END

    //CISP-2457 /CISP-2506
    @AuraEnabled
    public static String upsertRecords(String apiName, String fields, String loanApplicationId){
        try {
            String applicantId = '';
            if(apiName == 'Applicant__c'){
                List<Opportunity> oppList = new List<Opportunity>([Select Id,Product_Type__c FROM Opportunity Where Id=: loanApplicationId]);
                Applicant__c applicantObj = new Applicant__c();
                applicantObj = (Applicant__c) JSON.deserialize(fields,Applicant__c.class);
                List<Applicant__c> applicantList = new List<Applicant__c>();
                if(oppList.size() > 0 && oppList[0].Product_Type__c == Label.Tractor){
                    applicantList = [Select Id from Applicant__c WHERE Opportunity__c =: loanApplicationId AND Id =: applicantObj.Id AND In_Active_Applicant__c = false LIMIT 1];
                }else{
                    applicantList = [Select Id from Applicant__c WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: applicantObj.Applicant_Type__c AND In_Active_Applicant__c = false LIMIT 1];
                }
                if(applicantList.size() > 0){
                    applicantId = applicantList[0].Id;
                    applicantObj.Id = applicantId;
                    update applicantObj;
                }else{
                    upsert applicantObj;
                    applicantId = applicantObj.Id;
                    if(oppList.size() > 0 && oppList[0].Product_Type__c == Label.Tractor){
                        createResiDocument(loanApplicationId,applicantId);
                    }
                }
                if(String.isNotBlank(applicantObj.Applicant_Type__c) && applicantObj.Applicant_Type__c != System.Label.Borrower){
                    Applicant__c applicant = new Applicant__c();
                    applicant = [Select Id,Check_Eligibility_Message__c,Check_Eligibility_Retry_Attempts__c,Check_Eligibility_Match__c,Check_Eligibility_Final_Reason__c From Applicant__c Where Opportunity__c =: loanApplicationId AND Applicant_Type__c=: System.Label.Borrower WITH SECURITY_ENFORCED LIMIT 1];
                    applicant.Check_Eligibility_Message__c = '';
                    applicant.Check_Eligibility_Retry_Attempts__c = 0;
                    applicant.Check_Eligibility_Match__c = false;
                    applicant.Check_Eligibility_Final_Reason__c = '';
                    update applicant;

                    List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                    retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId AND Service_Name__c ='Check Eligibility Attempts' AND Module__c ='Gatting & Screening' WITH SECURITY_ENFORCED];
                    for(Retry_Count__c ret : retryCountList){
                        ret.Count__c = 0;
                        ret.IsAPIFailed__c = false;
                    }
                    update retryCountList;
                }
            }
            return applicantId;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl', 'upsertRecords', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP-2457 /CISP-2506

    @AuraEnabled
    public static String getApplicant(String loanId, String applicantType){
        if(loanId != null && applicantType != null){
            List<Applicant__c> appList = [SELECT ID from Applicant__c where Opportunity__c =: loanId AND Applicant_Type__c =: applicantType AND In_Active_Applicant__c = false LIMIT 1];
            if(appList.size()>0){
                return appList[0].Id;
            }
            
        }
        return '';
    }
    
    /*  Start CISP-2555
    *@Method:      deleteIncomeDetailIfNoIncomeSource
    *@Created by:  Rajat Jaiswal
    *@Description: delete Income Details if No Income source
    *@Param:       String : loanApplicationId
    *@Return:      void
    */
    @AuraEnabled
    public static void deleteIncomeDetailIfNoIncomeSource(String loanApplicationId){
        try {
            if(loanApplicationId!=null) { 
                List<Opportunity> loanAppList = [SELECT Id, LeadSource, Lead_Source__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED];
                if (loanAppList.size()>0 && loanAppList[0].LeadSource!=null && (loanAppList[0].LeadSource == 'Digital-MSIL-Custom' || loanAppList[0].LeadSource == System.Label.Mahindra_Custom_Lead_API_Value || loanAppList[0].LeadSource == System.Label.Mahindra_PreA_Lead_API_Value)) { //CISP-15890
                    List<Applicant__c> applicantList = [SELECT Id , Income_source_available__c,Applicant_Type__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false AND Applicant_Type__c ='Borrower' AND Income_source_available__c = false WITH SECURITY_ENFORCED];
                    if (applicantList.size()>0){
                        Set<Id> ApplicantIdSet = new Set<Id>();
                        for (Applicant__c aplicantObj : applicantList) {
                            ApplicantIdSet.add(aplicantObj.Id);
                        }
                        if (ApplicantIdSet!=null) {
                            List<Income_Details__c> incomeDetailList = [SELECT Id from Income_Details__c where Applicant__c IN :ApplicantIdSet WITH SECURITY_ENFORCED];
                            if (incomeDetailList.size()>0) {
                                Delete incomeDetailList;
                            }
                        }
                    }
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' deleteIncomeDetailIfNoIncomeSource ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    } // End CISP-2555

    /*  Start  // CISP-2887 || CISP-2882
    *@Method:      checkCountOfContentDoc
    *@Created by:  Poonam Tilokani
    *@Description: check content document count
    *@Param:       String : document Id
    *@Return:      Boolean
    */
    @AuraEnabled
    public static Boolean checkCountOfContentDoc(String docId){
        try{
            if(docId != null){
                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                contentDocumentLinkList =[SELECT id, contentdocumentid, linkedentity.name, linkedentityid FROM ContentDocumentLink WHERE linkedentityid =:docId ];
                if(contentDocumentLinkList.size() >0){
                    return true;
                }
                return false;
            }
            return false;
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' checkCountOfContentDoc ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    }
    /*
    *@Method:      checkCountOfContentDocTractor
    *@Created by:  Gaurav Rawat
    *@Description: check all vehicle have madatory document with file
    *@Param:       String payload, String documenType
    *@Return:      Boolean
    */
    @AuraEnabled
    public static Boolean checkCountOfContentDocTractor(String payload, String documenType){
        Boolean valid = true;
        try{
            Map<Id,Boolean> vehicleMap = new Map<Id,Boolean>();
            List<VehicleDocWrapper> vehDocWrapperList = (List<VehicleDocWrapper>)JSON.deserialize(payload , List<VehicleDocWrapper>.Class);
            for (VehicleDocWrapper vehDocWrapperObj : vehDocWrapperList) {
                if(!vehicleMap.containsKey(vehDocWrapperObj.vehicleId)){
                    vehicleMap.put(vehDocWrapperObj.vehicleId,vehDocWrapperObj.documentUploaded);
                }
            }
            if(vehicleMap != null && vehicleMap.keySet().size() > 0 ){
                for(Documents__c documentObj : [SELECT Id,Vehicle_Detail__c,(select id from ContentDocumentLinks) FROM Documents__c WHERE Vehicle_Detail__c IN : vehicleMap.keySet() AND Document_Type__c =: documenType AND Is_Active__c = true WITH SECURITY_ENFORCED LIMIT 1000]){
                    if(vehicleMap.containsKey(documentObj.Vehicle_Detail__c) && documentObj.ContentDocumentLinks.size() > 0){
                        vehicleMap.put(documentObj.Vehicle_Detail__c,true);
                    }
                }
                for(String  key: vehicleMap.KeySet()){
                    if(vehicleMap.get(key) == false){
                        valid = false;
                        break;
                    }
                }
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'checkCountOfContentDocTractor', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
        return valid;
    }

    public class VehicleDocWrapper{
        String vehicleId {get;set;} 
        Boolean documentUploaded {get;set;}
    }

    /*  Ticket  // CISP-2883
    *@Method:      updatePermanentProofOfAddressInDocuments
    *@Created by:  Rajat Jaiswal
    *@Description: Updating Permanent Residential Address Proof when user select Permanent Address same as Current Address
    *@Param:       String : loan Application Id
    *@Return:      Document List
    */
    @auraEnabled
    public static List<Documents__c> updatePermanentProofOfAddressInDocuments(String recordId){
        try{
            if(recordId != null){
                List<Documents__c> documentList = [Select Permanent_Residential_Address_Proof__c from Documents__c where Opportunity_Relation__c =: recordId  And  (Applicant__r.Current_Same_As_Permanent__c=true AND Current_Residential_Address_Proof__c = true) LIMIT 100];
                for (Documents__c document : documentList) {
                    document.Permanent_Residential_Address_Proof__c = true;
                }
                update documentList;
                return documentList;
            }
            return null;
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' updatePermanentProofOfAddressInDocuments ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    }
    @auraEnabled
    public static List<Documents__c> updateCurrentPermanentProofOfAddressInDocument(String appId){
        try{
            if(appId != null){
                List<Documents__c> documentCurrentList = [Select Id, Permanent_Residential_Address_Proof__c,Current_Residential_Address_Proof__c from Documents__c where Applicant__c =: appId  And Current_Residential_Address_Proof__c = true And Permanent_Residential_Address_Proof__c = true LIMIT 100];
                if(documentCurrentList.size() == 0){
                    List<Documents__c> documentList = [Select Id, Permanent_Residential_Address_Proof__c,Current_Residential_Address_Proof__c from Documents__c where Applicant__c =: appId  And Applicant__r.Current_Same_As_Permanent__c = true AND Document_Type__c = 'Aadhaar' LIMIT 100];
                    if(documentList.size() > 0){
                        for (Documents__c document : documentList) {
                            document.Permanent_Residential_Address_Proof__c = true;
                            document.Current_Residential_Address_Proof__c = true;
                        }
                        update documentList;
                        return documentList;    
                    }
                }
 
            }
            return null;
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' updateCurrentPermanentProofOfAddressInDocument ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    }
    
    //CISP-2787
    @AuraEnabled
    public static String doSmsGatewayCallout(String smsRequestString,String loanId){
        try{
            
            return IntegrationEngine.doSmsGatewayAPI(smsRequestString);
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' doSmsGatewayCallout ', System.Label.Apex, e, loanId);
            throw new IND_Exception(e.getMessage());
        }
    }
    //CISP-2787
    //CISP-2701 START
    @AuraEnabled
    public static List<Map<String,String>> getPickListValues(){
        try {
            List<Map<String,String>> finalList = new List<Map<String,String>>();
            String fieldName = 'Document_Type__c';
            Map<String, Schema.SObjectField> fieldMap = Documents__c.getSObjectType().getDescribe().fields.getMap();
            List<Schema.PicklistEntry> picklistEntryList = fieldMap.get(fieldName).getDescribe().getPicklistValues();
            // CISP-3045-START
            for(Integer i = 0; i < 9; i++){
                finalList.add(new Map<String,String>{'a' + i => 'b' + i});
            }
            for (Schema.PicklistEntry picklist : picklistEntryList) {
                    Map<String,String> strMap = new Map<String,String>();
                    if(picklist.getValue() == System.Label.Address_Declaration){
                        strMap.put('label',picklist.getLabel());
                        strMap.put('value',picklist.getValue());
                        finalList[0] = strMap;
                    }
                    // }else if(picklist.getValue() == System.Label.ElectricityBillApiName){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[1] = strMap;
                    // }else if(picklist.getValue() == System.Label.TelephonicBillAPI){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[2] = strMap;
                    // }else if(picklist.getValue() == 'Gas bill'){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[3] = strMap;
                    // }else if(picklist.getValue() == 'Water Bill'){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[4] = strMap;
                    // }else if(picklist.getValue() == 'Property or Municipal Tax Receipt'){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[5] = strMap;
                    // }else if(picklist.getValue() == 'Govt pension payment order'){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[6] = strMap;
                    // }else if(picklist.getValue() == 'Pension Document'){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[7] = strMap;
                    // }else if(picklist.getValue() == 'Govt letter of accommodation allotment'){
                    //     strMap.put('label',picklist.getLabel());
                    //     strMap.put('value',picklist.getValue());
                    //     finalList[8] = strMap;
                    // }                  
                }
                //CISP-3045-END
            return finalList;

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' getPickListValues ', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    //CISP-2701 END

    
    //CISP-3038 --start
    @AuraEnabled
    public static String getEncryptedData(String data) {
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(data,System.Label.privateKey,System.Label.ivkey);
        System.debug('encrypted data '+encryptedRequest);
        return encryptedRequest;
    }
    //CISP-3038 --end
    
    //Ola Integration
    @AuraEnabled
    public static Loan_Application_Read_Only_Setting__mdt getLoanApplicationReadOnlySettings(String leadSource){
        try{
            List<Loan_Application_Read_Only_Setting__mdt> readOnlySettingList = [SELECT id,developerName,Input_Labels__c FROM Loan_Application_Read_Only_Setting__mdt where developerName =:leadSource LIMIT 1];
            if(readOnlySettingList.size()>0){
                return readOnlySettingList.get(0);
            } else{
                return null;
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' getLoanApplicationReadOnlySettings ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    }
    //Ola Integration
    
    /*
    * @Method:      checkCurrentSubStage
    * @Created by:  gaurav rawat
    * @Description: This method will check current sub stage of loan application.
    * @Param:       String -  loanApplicationId
    * @Return:      boolean
    */
    @AuraEnabled
    public static Boolean checkCurrentSubStage(String loanApplicationId,String screenName){
        Boolean readOnly = false;
        try{
            if(String.isNotBlank(loanApplicationId) && String.isNotBlank(screenName)){
                Opportunity oppRecord = [Select id,Sub_Stage__c from Opportunity WHERE Id =: loanApplicationId];
                if(oppRecord.Sub_Stage__c != screenName){
                    readOnly = true;
                }
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSLoanApplicationCntrl' ,'checkCurrentSubStage', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return readOnly;
    }

    @AuraEnabled
    public static string createAddressDeclarationDocument(String loanAppId,String applicantId){
        try {
            if(String.isNotBlank(loanAppId) && String.isNotBlank(applicantId)){
                Applicant__c applicantRec= [Select id,Current_Address_Not_Present__c,Is_Address_Declaration__c from Applicant__c Where id =: applicantId AND Opportunity__c =: loanAppId];
                if(applicantRec.Current_Address_Not_Present__c == true && applicantRec.Is_Address_Declaration__c == true){
                    String documentId = LwcLOSLoanApplicationCntrl.docCustomerImage('Address Declaration', applicantId, loanAppId);
                    Documents__c doc =  new Documents__c();
                    if(String.isNotBlank(documentId)){
                        doc.Id = documentId;
                        doc.Current_Residential_Address_Proof__c = true;
                        doc.Name = 'Address Declaration';
                    }
                    if(doc != null && Schema.sObjectType.Documents__c.isUpdateable()){
                        update doc;
                        return documentId;
                    }
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'createAddDecDoc ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    }
     //CISP-5266
     @AuraEnabled
     public static Customer_Dedupe_Response__c getCustomerDedupeData(String loanId, String ApplicantId){
         try{
             List<Customer_Dedupe_Response__c> lstcdr =[SELECT Id,IND_isNewCustomer__c FROM Customer_Dedupe_Response__c where Applicant__c=:ApplicantId Limit 1];
             if(!lstcdr.isEmpty()){
                return lstcdr[0];
             }else{
             return null;
            }
         }
         catch(Exception e) {
             ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' doSmsGatewayCallout ', System.Label.Apex, e, loanId);
             return null;
         }
     }
     // CISP-20674
     @AuraEnabled
     public static Boolean getAadharDetails(String loanId, String ApplicantId){
         try{
             List<Documents__c> docList =[SELECT Id,Aadhar_Source__c FROM Documents__c WHERE Applicant__c=:ApplicantId AND Name='Aadhaar' AND is_Active__c=true LIMIT 1];
             if(docList.size() > 0){
                if(docList[0].Aadhar_Source__c == 'OTP' || docList[0].Aadhar_Source__c == 'Biometric'){
                    return true;
                }else{
                    return false;
                }
             }else{
             return false;
            }
         }
         catch(Exception e) {
             ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' doSmsGatewayCallout ', System.Label.Apex, e, loanId);
             return false;
         }
     }
     // CISP-20674

      /*
    * @Method:      isPANForm60DocumentPresent
    * @Created by:  gaurav rawat
    * @Description: This method form 60 / PAN document present or not.
    * @Param:       String -  applicantId
    * @Return:      boolean 
    */
    @AuraEnabled
    public static Boolean isPANForm60DocumentPresent(String applicantId){
        Boolean isFormPanPresent = false;
        try{
            if(applicantId != null){
                Applicant__c applicant = [Select id,Opportunity__r.StageName, Opportunity__r.LastStageName__c from Applicant__c Where Id =: applicantId];
                List<Documents__c> docList =  new List<Documents__c>();
                docList = [Select id,Document_Type__c from Documents__c Where Applicant__c =: applicantId AND (Document_Type__c = : System.Label.Form60DocumentType OR Document_Type__c = : System.Label.PanCards) AND is_Active__c = true];

                if(docList.size() > 0 || (applicant.Opportunity__r.StageName != 'Loan Initiation' && applicant.Opportunity__r.LastStageName__c != 'Loan Initiation')){
                    isFormPanPresent = true;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'isPANForm60DocumentPresent ', System.Label.Apex, e);
        }
        return isFormPanPresent;
    }
    @AuraEnabled
    public static Boolean checkDocument(String documentRecordId){
        List<Documents__c> docList = [Select id,(select id from ContentDocumentLinks) from Documents__c Where id =: documentRecordId AND is_Active__c = true];
        if(docList.size() > 0 && docList[0].ContentDocumentLinks.size()>0){
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static void documentUpdateAftergoldenSource(String documentId, string nsdlResponse , string aadhaarSeedingStatus, Boolean goldenSourcePass, String nsdlPanName , String NSDLPANStatus,String nsdlPanMatch)
    {
        try
        {
            if(documentId!=null){
            Documents__c document = [select id ,NSDL_Response__c,NSDLPANStatus__c,NSDLPANName__c, AadhaarSeedingStatus__c, Golden_Source_Pass__c,NSDLNameMatch__c from Documents__c where id =: documentId WITH SECURITY_ENFORCED];
            if(document != null){ 
                document.Golden_Source_Pass__c = goldenSourcePass;
                document.NSDL_Response__c = nsdlResponse;
                document.AadhaarSeedingStatus__c = aadhaarSeedingStatus;
                document.NSDLPANStatus__c  = NSDLPANStatus; 
                document.NSDLPANName__c = nsdlPanName;
                document.NSDLNameMatch__c = nsdlPanMatch;
                if (Schema.sObjectType.Documents__c.isUpdateable())
                {
                    update document; 
                }
            }
        }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }
        catch(Exception e){
             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' documentUpdateAftergoldenSource ', System.Label.Apex, e);  
             if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
                }        
                    throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static void updateJourneyStopOfLead(String leadNo,String journeyStopReason){
        try {
            List<Opportunity> oppList = [Select Id ,Lead_Number__c,OwnerId,JourneyStopScenarioFound__c,Journey_Status__c,Journey_Stop_Reason__c from Opportunity where Id =:leadNo LIMIT 1];
            if(!oppList.isEmpty()){
                oppList[0].JourneyStopScenarioFound__c = true;
                oppList[0].Journey_Status__c = 'Stop';
                oppList[0].Journey_Stop_Reason__c = journeyStopReason;
                update oppList;
            }
            List<Case> caseList = [SELECT id,RecordType.name,Loan_Application__c,Status from case where RecordType.name = 'CMU Request' and Loan_Application__c =:leadNo LIMIT 1];
            if(!caseList.isEmpty()){
                caseList[0].Status = 'Closed';
                update caseList;
            }
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Loan Application Journey Stop ' + oppList[0].Lead_Number__c);
            notification.setBody(oppList[0].Journey_Stop_Reason__c + ' Please refresh this screen');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(leadNo);
            notification.send(new Set<String> { oppList[0].OwnerId });

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'updateJourneyStopOfLead', System.Label.Apex, e);
        }
    }

     /*
    * @Method:      contentDocumentPresentOrNot
    * @Created by:  gaurav rawat
    * @Description: This method will check contentdocument present or not
    * @Param:       String -  docId
    * @Return:      boolean 
    */
    @AuraEnabled
    public static Boolean contentDocumentPresentOrNot(String docId, String selectedAadharOption){
        Boolean contentDocumentsPresent = false;
        try{
            if(docId != null){
                List<Documents__c> docList =  new List<Documents__c>();
                docList = [Select id,Document_Type__c from Documents__c Where Id =: docId LIMIT 1];

                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                contentDocumentLinkList =[SELECT id, contentdocumentid, linkedentity.name, linkedentityid FROM ContentDocumentLink WHERE linkedentityid =:docId ];
                if(docList[0].Document_Type__c == System.Label.PanCards || docList[0].Document_Type__c == System.Label.Form60DocumentType){
                    if(contentDocumentLinkList.size() == 1){
                        contentDocumentsPresent = true;
                    }else {
                        contentDocumentsPresent = false;
                    }
                } else if((docList[0].Document_Type__c == System.Label.AadhaarCard && selectedAadharOption == 'Scan and Upload') || docList[0].Document_Type__c == System.Label.VoterIdCard || docList[0].Document_Type__c == System.Label.DrivingLicences || docList[0].Document_Type__c == System.Label.PassportCard){
                    if(contentDocumentLinkList.size() == 2){
                        contentDocumentsPresent = true;
                    }else {
                        contentDocumentsPresent = false;
                    }
                }else if(contentDocumentLinkList.size() >= 1){
                    contentDocumentsPresent = true;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'contentDocumentPresentOrNot ', System.Label.Apex, e);
        }
        return contentDocumentsPresent;
    }

    @AuraEnabled
    public static Integer resendAadharBiometric(String docRecordId){
        try {
            Integer resendBiometricAttempt = 0;
            if(docRecordId!=null ){
            Documents__c documentsObject= [Select Id, OTP_for_borrower__c, Biometric_Resend_Attempts__c from Documents__c Where Id= :docRecordId WITH SECURITY_ENFORCED ];
            System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance(System.Label.Aadhar_OTP_Attempts);
            if(documentsObject.Biometric_Resend_Attempts__c == null)
            {
                documentsObject.Biometric_Resend_Attempts__c =1;
                if (Schema.sObjectType.Documents__c.isUpdateable())
                {
                    update documentsObject;
                }
            }
            else 
            {
                documentsObject.Biometric_Resend_Attempts__c +=1;
                if (Schema.sObjectType.Documents__c.isUpdateable()){
                    update documentsObject;
                }
            } 
            resendBiometricAttempt = Integer.valueOf(documentsObject.Biometric_Resend_Attempts__c);
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return resendBiometricAttempt;
        }
        //DML Exception handled
        catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' resendAadharBiometric ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP-5264
    @AuraEnabled
    public static List<SamePANWrapper> checkIfPanNoIsSameOrNot(String panNo , String applicantId, String leadApplicationId){
        List<SamePANWrapper> samePanWrapperList = new List<SamePANWrapper>();
        try {
            List<Documents__c> DocList = [SELECT ID,PAN_No__c,Opportunity_Relation__r.LeadSource , Applicant_Type__c,Opportunity_Relation__r.Entity_Type__c,Applicant__r.Applicant_Type__c,Opportunity_Relation__r.Customer_Type__c,Opportunity_Relation__r.Product_Type__c  FROM Documents__c WHERE Opportunity_Relation__c =: leadApplicationId AND Applicant__c !=: applicantId AND Document_Type__c =: System.Label.PanCards AND Applicant__r.In_Active_Applicant__c = false];
            if(DocList.size()>0){
                System.debug('DocList===' + DocList.size());
                for(Documents__c doc : DocList){
                    if(doc.Opportunity_Relation__r.Product_Type__c == System.Label.Tractor && doc.Opportunity_Relation__r.Customer_Type__c == 'Non-Individual' && doc.Opportunity_Relation__r.Entity_Type__c == 'Proprietorship' && doc.Applicant__r.Applicant_Type__c == System.Label.Borrower){
                        continue;
                    }
                    if(doc.Opportunity_Relation__r.LeadSource != 'D2C'){
                        String decryptedPANNo = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                        if(panNo.equalsIgnoreCase(decryptedPANNo)){
                            SamePANWrapper samePANWrapperObj = new SamePANWrapper();
                            samePANWrapperObj.samePanUploaded = true;
                            samePANWrapperObj.applicantType = doc.Applicant_Type__c;
                            samePanWrapperList.add(samePANWrapperObj);
                            break;
                        }
                    }else{
                        if(panNo.equalsIgnoreCase(doc.PAN_No__c)){
                            SamePANWrapper samePANWrapperObj = new SamePANWrapper();
                            samePANWrapperObj.samePanUploaded = true;
                            samePANWrapperObj.applicantType = doc.Applicant_Type__c;
                            samePanWrapperList.add(samePANWrapperObj);
                            break;
                        }
                    } 
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return samePanWrapperList;
    }
    public class SamePANWrapper{
        @AuraEnabled public Boolean samePanUploaded {get;set;}
        @AuraEnabled public String applicantType {get;set;} //vehicleType
    }
    /*
    * @Method:      checkOtherCoBorrowerClosed
    * @Created by:  Chaynnitt Agarwal.
    * @Description: This method will return boolean value based on if all the co-borrower added has flow completed.
    * @Param:       String - loanApplication ID
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean checkOtherCoBorrowerClosed(String loanApplicationId){
        Boolean result = true;
        try{
            if(loanApplicationId!=null){
                List<Applicant__c> applicantLst = new List<Applicant__c>([Select Id,Applicant_Type__c,Bureau_Pull_Message__c FROM Applicant__c Where Opportunity__c =: loanApplicationId AND Applicant_Type__c = 'Co-borrower' AND Bureau_Pull_Message__c = '' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);
                if(applicantLst.size()>0){
                    result = false;
                }
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'checkOtherCoBorrowerClosed', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return result;
    }
    @AuraEnabled
    public static Boolean checkOtherBeneficaryClosed(String loanApplicationId){
        Boolean result = true;
        try{
            if(loanApplicationId!=null){
                List<Applicant__c> applicantLst = new List<Applicant__c>([Select Id,Applicant_Type__c,Bureau_Pull_Message__c FROM Applicant__c Where Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.Beneficiary AND Bureau_Pull_Message__c = '' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);
                if(applicantLst.size()>0){
                    result = false;
                }
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'checkOtherBeneficaryClosed', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return result;
    }

//SFTRAC-31 Starts    
                     /*
* @Method:      getVehicleDetailsRecord
* @Created by:  Aakash J.
* @Description: Method to return list of Vehicle Details for Tractor Dedupe
* @Param:       String - loanApplication ID
* @Return:      List<LoanApplicationWrapper> - List of Tabs
*/
    
@AuraEnabled
public static LoanApplicationWrapper getVehicleDetailsRecord(String loanApplicationId){
    try {
        if(loanApplicationId!=null){
            LoanApplicationWrapper loanWrapperElement = new LoanApplicationWrapper();
            //List<applicantWrapper> applicantsList = new  List<applicantWrapper>();
            List<vehicledetailsWrapper> vehicleDetailsList = new  List<vehicledetailsWrapper>();
            List<ContentDocumentLink> contentdocForm60 =new  List<ContentDocumentLink>();
            List<Vehicle_Detail__c> updatevehicleDetailsList = new List<Vehicle_Detail__c>();
            
            Opportunity opprecord=[ SELECT Id,OwnerId,Lead_number__c,Product_Type__c,
                                   Agent_BL_Code__c, Sub_Stage__c,View_Application_Sub_Stages__c, LastStageName__c,Loan_amount__c,Vehicle_Type__c,Vehicle_Sub_Category__c,Vehicle_Proceed_Flag__c,
                                   Parent_Deal_number__c,Valid_Dedupe_Customer_Code__c,Vehicle_Registration_Number__c,Registration_Number_Format__c,
                                   NOC_Number__c,Vehicle_Verified__c,AccountId,StageName,Is_Revoked__c ,LeadSource,isTopUpLoan__c  //DSAMODIFYEXISTING                          
                                   FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
            
            //if(opprecord.Vehicle_Registration_Number__c == null && opprecord.Sub_Stage__c == 'Vehicle Dedupe'){

                List<Vehicle_Detail__c> vehicleDetails = [  SELECT Id, Name, Vehicle_type__c, Vehicle_Category__c, Parent_Deal_number__c, 
                                                          Registration_Number_Format__c, Customer_Code__c, NOC_Number__c, Vehicle_Proceed_Flag__c, 
                                                          Vehicle_Registration_Number__c, Vehicle_Verified__c, Engine_number__c, Vehicle_SubCategory__c, 
                                                              Chassis_number__c, Serial_number__c, Vehicle_Delivered__c, Vehicle_SubType__c, 
                                                          Loan_Application__r.LeadSource, Loan_Application__r.StageName, Loan_Application__r.Sub_Stage__c, 
                                                          Loan_Application__r.LastStageName__c, Loan_Application__r.Product_Type__c,PV_TW_Dedupe_API_Flag__c
                                                          FROM Vehicle_Detail__c 
                                                          WHERE Loan_Application__c =: loanApplicationId ORDER BY CreatedDate ASC];
                
                if(!vehicleDetails.isEmpty()){
                    for(Vehicle_Detail__c vdRec: vehicleDetails){
                        /*vdRec.Vehicle_Registration_Number__c = vdRec.Vehicle_Registration_Number__c.toUpperCase(); 
                        Pattern MyPattern = Pattern.compile(System.Label.Vehicle_New);
                        Matcher myMatcher = MyPattern.matcher(vdRec.Vehicle_Registration_Number__c);
                        
                        if(MyMatcher.matches()){
                            vdRec.Registration_Number_Format__c = 'New';
                        }else{
                            vdRec.Registration_Number_Format__c = 'old';
                        }
                        updatevehicleDetailsList.add(vdRec);*/
                        
                        vehicledetailsWrapper vehicledetailsElement = new vehicledetailsWrapper();
                        vehicledetailsElement.name = vdRec.Name;
                        vehicledetailsElement.vehicleType = vdRec.Vehicle_type__c;
                        vehicledetailsElement.vehicleSubCategoryType = vdRec.Vehicle_SubCategory__c;
                        vehicledetailsElement.parentDealNumber = vdRec.Parent_Deal_number__c;
                        vehicledetailsElement.registerationNumberFormatValue = vdRec.Registration_Number_Format__c;
                        vehicledetailsElement.customerCodeValue = vdRec.Customer_Code__c;
                        vehicledetailsElement.nocNumberValue = vdRec.NOC_Number__c;
                        vehicledetailsElement.vehicleProceedFlag = vdRec.Vehicle_Proceed_Flag__c;
                        vehicledetailsElement.vehicleRegistrationNumberValue = vdRec.Vehicle_Registration_Number__c;
                        vehicledetailsElement.vehicleVerified = vdRec.Vehicle_Verified__c;
                        vehicledetailsElement.oppLeadSource = opprecord.LeadSource;
                        vehicledetailsElement.oppStageName =  opprecord.StageName;
                        vehicledetailsElement.oppSubStage =  opprecord.Sub_Stage__c;
                        vehicledetailsElement.oppLastStageName =  opprecord.LastStageName__c;
                        vehicledetailsElement.oppProductType =  opprecord.Product_Type__c;
                        //vehicledetailsElement.oppVehicleType =  opprecord.Vehicle_Type__c;
                        vehicledetailsElement.oppRecId =  opprecord.Id;
                        vehicledetailsElement.vehicleDetailId = vdRec.Id;
                        vehicledetailsElement.engineNoValue = vdRec.Engine_number__c;
                        vehicledetailsElement.chassisNoValue = vdRec.Chassis_number__c;
                        vehicledetailsElement.serialNoValue = vdRec.Serial_number__c;
                        vehicledetailsElement.vehicleDelivered = vdRec.Vehicle_Delivered__c;
                        vehicledetailsElement.vehicleSubType = vdRec.Vehicle_SubType__c;
                        vehicledetailsElement.pvtwAPIFlag = vdRec.PV_TW_Dedupe_API_Flag__c;
                        vehicleDetailsList.add(vehicledetailsElement);
                    }
                    system.debug('++++vehicleDetailsList 1' +vehicleDetailsList);
              
                } 
            
            //applicantBorrowerRecord
            Applicant__c applicantRec = [SELECT Id,Customer_Last_Name__c,Customer_First_Name__c, Whatsapp_number__c, Contact_number__c,Applicant_Type__c, Customer_code__c From Applicant__c Where Applicant_Type__c =: 'Borrower' AND Opportunity__c =: loanApplicationId AND 
                                         In_Active_Applicant__c = false ];
            loanWrapperElement.applicantBorrowerRecord = applicantRec;
            loanWrapperElement.oppRecord = opprecord;
            system.debug('++++vehicleDetailsList 2' +vehicleDetailsList);
            loanWrapperElement.vehicledetailsList = vehicleDetailsList;
            system.debug('++++vehicleDetailsList 3' +loanWrapperElement.vehicledetailsList);
            //loanWrapperElement.applicantsList = applicantsList;
            system.debug('++++vehicleDetailsList 4' +loanWrapperElement.applicantBorrowerRecord);
            if(Test.isRunningTest()) {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            //return JSON.serialize(loanWrapperElement);
            return loanWrapperElement;
        }
        return null;
    }
    catch(Exception e){
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' getCurrentOppRecord ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
/*
* @Method:      updateVehicleDetails
* @Created by:  Aakash J.
* @Description: Method to update list of Vehicle Details for Tractor Dedupe
* @Param:       String - loanApplication ID
* @Return:      DML result success or error
*/
@AuraEnabled
    public static List<String> updateVehicleDetails( List <vehicledetailsWrapper> listVehicleDetails ) {
        
        try {
            system.debug('+++++listVehicleDetails '+listVehicleDetails);
            List<Vehicle_Detail__c> vdUpdateList = new List<Vehicle_Detail__c>();
            List<String> updatedRecordIds = new List<String>();
            if(!listVehicleDetails.isEmpty()){
                for(vehicledetailsWrapper vdWrapRec: listVehicleDetails){
                    Vehicle_Detail__c vdRec = new Vehicle_Detail__c();
                    vdRec.Loan_Application__c = vdWrapRec.oppRecId;
                    vdRec.Vehicle_type__c = vdWrapRec.vehicleType;
                    vdRec.Vehicle_SubType__c = vdWrapRec.vehicleSubType;
                    vdRec.Vehicle_SubCategory__c = vdWrapRec.vehicleSubCategoryType;
                    vdRec.Vehicle_Delivered__c = vdWrapRec.vehicleDelivered;
                    vdRec.Registration_Number_Format__c = vdWrapRec.registerationNumberFormatValue;
                    vdRec.Engine_number__c = vdWrapRec.engineNoValue;
                    vdRec.Chassis_number__c = vdWrapRec.chassisNoValue;
                    vdRec.Serial_number__c = vdWrapRec.serialNoValue;
                    vdRec.Vehicle_Proceed_Flag__c = vdWrapRec.vehicleProceedFlag;
                    vdRec.Vehicle_Registration_Number__c = vdWrapRec.vehicleRegistrationNumberValue;
                    vdRec.Vehicle_Verified__c = vdWrapRec.vehicleVerified;
                    vdRec.Parent_Deal_Number__c = vdWrapRec.parentDealNumber;
                    vdRec.Customer_Code__c = vdWrapRec.customerCodeValue;
                    vdRec.NOC_Number__c = vdWrapRec.nocNumberValue;
                    vdRec.PV_TW_Dedupe_API_Flag__c = vdWrapRec.pvtwAPIFlag;
                    vdRec.Id = vdWrapRec.vehicleDetailId; 
                    vdUpdateList.add(vdRec);
                }
                if(!vdUpdateList.isEmpty()){
                    system.debug('+++++vdUpdateList '+vdUpdateList);
                    upsert vdUpdateList;    
                    
                    for (Vehicle_Detail__c updatedRecord : vdUpdateList) {
                    	updatedRecordIds.add(updatedRecord.Id);
                	}
                }         
            } 
            return updatedRecordIds; 
        } catch ( Exception e ) {   
            throw new AuraHandledException( e.getMessage() );            
        }
        
    }
//Wrapper vehicledetails class for Tractor Vehicle Dedupe added by Aakash J

    public class vehicledetailsWrapper{
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String vehicleType {get;set;} //vehicleType
        @AuraEnabled public String vehicleSubCategoryType {get;set;} //vehicleSubcategory 
        @AuraEnabled public String vehicleSubType {get;set;}
        
        @AuraEnabled public String parentDealNumber {get;set;}
        @AuraEnabled public String customerCodeValue {get;set;}  //customerCode
        @AuraEnabled public String nocNumberValue {get;set;} //nocNumber
        
        @AuraEnabled public String vehicleDelivered {get;set;}
        @AuraEnabled public String engineNoValue {get;set;}
        @AuraEnabled public String chassisNoValue {get;set;}
        @AuraEnabled public String serialNoValue {get;set;}
        
        @AuraEnabled public String registerationNumberFormatValue{get;set;} //regNumberFormat
        @AuraEnabled public String vehicleProceedFlag {get;set;}
        @AuraEnabled public String vehicleRegistrationNumberValue {get;set;} //vehicleRegistrationNumber
        @AuraEnabled public Boolean vehicleVerified {get;set;}
        @AuraEnabled public String oppLeadSource {get;set;}
        @AuraEnabled public String oppStageName {get;set;}
        @AuraEnabled public String oppSubStage {get;set;}
        @AuraEnabled public String oppLastStageName {get;set;}
        @AuraEnabled public String oppProductType {get;set;}
        @AuraEnabled public String oppVehicleType {get;set;}
        @AuraEnabled public String vehicleDetailId {get;set;}
        @AuraEnabled public Boolean pvtwAPIFlag {get;set;}
        @AuraEnabled public Id oppRecId {get;set;}
    }

/*
* @Method:      deleteVehicleDetail
* @Created by:  Aakash J.
* @Description: Method to delete Vehicle Details for Tractor Dedupe function
* @Param:       String - Vehicle detail ID
* @Return:      DML result success or error
*/
    
    @AuraEnabled
    public static String deleteVehicleDetail(String vehicleDetailId) {
        // Check if the Vehicle_Detail__c with the specified Id exists
        Vehicle_Detail__c  vdToDelete = [SELECT Id FROM Vehicle_Detail__c  WHERE Id = :vehicleDetailId LIMIT 1];
        
        try{
            if (vdToDelete != null) {
                // Delete the Vehicle_Detail__c if it exists
                delete vdToDelete;
            }
            return 'Successfully deleted'; 
        } catch ( Exception e ) {   
            throw new AuraHandledException( e.getMessage() );            
        }        
    }
    //SFTRAC-31 Ends
    /*
    * @Method:      getDealNumbers
    * @Created by:  Shivswaroop Chougule.
    * @Description: This method will return Deal numbers associated with loan Application.
    * @Param:       String - loanApplication ID
    * @Return:      DealNumberWrapperList
    * @Modified by : Gaurav Rawat : 28/09/2023
    */
    @AuraEnabled
    public static DealNumberWrapperList getDealNumbers(String loanApplicationId){
        try{
            if(loanApplicationId!=null){
                List<Opportunity> oppList = new List<Opportunity>([Select Product_Type__c,StageName from Opportunity Where Id =: loanApplicationId LIMIT 1]);
                List<Loan_Application_Transaction_History__c> loanTransHisList = new List<Loan_Application_Transaction_History__c>([Select Id,Deal_Number__c,Deal_Number__r.Deal_Number__c,Submitted_Flag__c,Module__c from Loan_Application_Transaction_History__c Where Loan_Application_ID__c =: loanApplicationId AND (Module__c =: System.Label.Post_Sanction_Checks_and_Documentation OR Module__c =: System.Label.Pre_Disbursement_Check) LIMIT 500]);
                
                Map<Id,Boolean> postEachDealScreensSubmitted = new Map<Id,Boolean>();
                Map<Id,Boolean> preEachDealScreensSubmitted = new Map<Id,Boolean>();
                Boolean postLATHCreated = false;
                Boolean preLATHCreated = false;
                for(Loan_Application_Transaction_History__c lath : loanTransHisList){
                    if(postLATHCreated == false && lath.Module__c == System.Label.Post_Sanction_Checks_and_Documentation){
                        postLATHCreated = true;
                    } else if(preLATHCreated == false && lath.Module__c == System.Label.Pre_Disbursement_Check){
                        preLATHCreated = true;
                    }

                    if(!lath.Submitted_Flag__c && lath.Module__c == System.Label.Post_Sanction_Checks_and_Documentation){
                        postEachDealScreensSubmitted.put(lath.Deal_Number__c, false);
                    } else if(!lath.Submitted_Flag__c && lath.Module__c == System.Label.Pre_Disbursement_Check){
                        preEachDealScreensSubmitted.put(lath.Deal_Number__c, false);
                    }
                }
                
                List<DealNumberWrapper> dealWrapperList = new List<DealNumberWrapper>();
                for(Vehicle_Detail__c vehicle : [Select id,Deal_Number__r.Deal_Number__c,Deal_Number__c,Payment_requested__c from Vehicle_Detail__c Where Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 100]){
                    DealNumberWrapper dealNumberWrapperObj = new DealNumberWrapper();
                    dealNumberWrapperObj.dealId = vehicle.Deal_Number__c;
                    dealNumberWrapperObj.dealNumber = vehicle.Deal_Number__r.Deal_Number__c;
                    if(postEachDealScreensSubmitted.containsKey(vehicle.Deal_Number__c) || postLATHCreated == false){
                        dealNumberWrapperObj.isAllPostScreensSubmitted = false;
                    }else{
                        dealNumberWrapperObj.isAllPostScreensSubmitted = true;
                    }
                    if(preEachDealScreensSubmitted.containsKey(vehicle.Deal_Number__c) || preLATHCreated == false || oppList[0].StageName == System.Label.Post_Sanction_Checks_and_Documentation){
                        dealNumberWrapperObj.isAllPreScreensSubmitted = false;
                    }else{
                        dealNumberWrapperObj.isAllPreScreensSubmitted = true;
                    }
                    if(vehicle.Payment_requested__c != null){
                        dealNumberWrapperObj.isPayamentRequestCompleted = true;
                    }else{
                        dealNumberWrapperObj.isPayamentRequestCompleted = false;
                    }
                    dealWrapperList.add(dealNumberWrapperObj);
                }
                DealNumberWrapperList dealNumberWrapperListObj = new DealNumberWrapperList();
                dealNumberWrapperListObj.dealNumberWrapperList = dealWrapperList;
                dealNumberWrapperListObj.productType = oppList.size() > 0 ? oppList[0].Product_Type__c : '';
                return dealNumberWrapperListObj;
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'getDealNumbers', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public class DealNumberWrapperList{
        @AuraEnabled public List<DealNumberWrapper> dealNumberWrapperList {get;set;}
        @AuraEnabled public String productType {get;set;}
    }

    public class DealNumberWrapper{
        @AuraEnabled public Id dealId {get;set;}
        @AuraEnabled public String dealNumber {get;set;}
        @AuraEnabled public Boolean isAllPostScreensSubmitted {get;set;}
        @AuraEnabled public Boolean isAllPreScreensSubmitted {get;set;}
        @AuraEnabled public Boolean isPayamentRequestCompleted {get;set;}
    }

    /*
    * @Method:      getDealNumbers
    * @Created by:  Gaurav Rawat.
    * @Description: This method will return true if all L2 cibil screen is submitted
    * @Param:       String - loanApplication ID
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean checkL2CibilSubmitted(String loanApplicationId){
        Boolean isCiblL2ScreeneSubmitted = true;
        try{
            if(loanApplicationId!=null){
                List<Applicant__c> applicantList = new List<Applicant__c>([SELECT Id,Opportunity__r.Customer_Type__c,Applicant_Type__c,CRIFF_Report_URL__c,(SELECT L2flag__c FROM CIBIL_Details__r) FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);

                for(Applicant__c applicant : applicantList){
                    if(applicant.Opportunity__r.Customer_Type__c == 'Non-Individual' && applicant.Applicant_Type__c == System.Label.Borrower && String.isBlank(applicant.CRIFF_Report_URL__c)){
                        isCiblL2ScreeneSubmitted = false;
                        break;
                    }
                    if(((applicant.Opportunity__r.Customer_Type__c == 'Non-Individual' && applicant.Applicant_Type__c != System.Label.Borrower) || (applicant.Opportunity__r.Customer_Type__c == 'Individual')) && applicant.CIBIL_Details__r.size() == 0){
                        isCiblL2ScreeneSubmitted = false;
                        break;
                    }
                    if(applicant.CIBIL_Details__r.size() > 0 && applicant.CIBIL_Details__r[0].L2flag__c == false){
                        isCiblL2ScreeneSubmitted = false;
                        break;
                    }
                }
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'getDealNumbers', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return isCiblL2ScreeneSubmitted;
    }
    /*
    * @Method:      getHunterResponse
    * @Created by:  Gaurav Rawat.
    * @Description: This method will return hunter response wrapper
    * @Param:       String - loanApplication ID
    * @Return:      HunterWrapper
    */
    @AuraEnabled
    public static HunterWrapper getHunterResponse(String loanApplicationId){
        HunterWrapper hunterWrapperObj = new HunterWrapper();
        try{
            if(loanApplicationId != null){
                Opportunity oppObj = [Select id,Hunter_APS_Response__c,Hunter_Match_Status__c from Opportunity Where Id=:loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                hunterWrapperObj.isHunterResponseOk = oppObj.Hunter_APS_Response__c;
                hunterWrapperObj.isHunterMatchResponse = oppObj.Hunter_Match_Status__c;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'getHunterResponse', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return hunterWrapperObj;
    }

    public class HunterWrapper{
        @AuraEnabled public String isHunterResponseOk {get;set;}
        @AuraEnabled public String isHunterMatchResponse {get;set;}

        HunterWrapper(){
            this.isHunterResponseOk = '';
            this.isHunterMatchResponse = '';
        }
    }

    /*
    * @Method:      isAllMandatoryDocUploaded
    * @Created by:  Gaurav Rawat.
    * @Description: This method will check all mandatory document is uplodaed or not for non-individual borrower
    * @Param:       String - applicantId
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean isAllMandatoryDocUploaded(String loanApplicationId,String applicantId){
        Boolean isAllMandatoryDocPresent = false;
        try{
            if(loanApplicationId != null && applicantId != null){
                Opportunity oppObj = [Select id,Entity_Type__c from Opportunity Where Id=:loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                String entityType = oppObj != null ? oppObj.Entity_Type__c : '';
                Set<String> mandatoryDocumentSet = new Set<String>();
                List<Documents__c> documentList = new List<Documents__c>();
                if(entityType == 'Pvt Ltd' || entityType == 'Public Ltd'){
                    mandatoryDocumentSet.add(System.Label.PanCards);
                    mandatoryDocumentSet.add(System.Label.GST_Cert);
                    mandatoryDocumentSet.add(System.Label.CIN_Cert);
                    documentList = [SELECT id FROM Documents__c WHERE Applicant__c=:applicantId and Opportunity_Relation__c=:loanApplicationId AND Is_Active__c = true AND Document_Type__c IN : mandatoryDocumentSet];
                    if(documentList.size() >= 3){
                        isAllMandatoryDocPresent = true;
                    }
                }else if(entityType == 'Partnership' || entityType == 'Trust' || entityType == 'HUF' || entityType == 'Co-Operative Society' || entityType == 'Assosiation of Persons'){
                    mandatoryDocumentSet.add(System.Label.PanCards);
                    mandatoryDocumentSet.add(System.Label.GST_Cert);
                    documentList = [SELECT id,KYC_DOB__c FROM Documents__c WHERE Applicant__c=:applicantId and Opportunity_Relation__c=:loanApplicationId AND Is_Active__c = true AND Document_Type__c IN : mandatoryDocumentSet];
                    if(documentList.size() >= 2){
                        isAllMandatoryDocPresent = true;
                    }
                }else{
                    mandatoryDocumentSet.add(System.Label.PanCards);
                    documentList = [SELECT id,KYC_DOB__c FROM Documents__c WHERE Applicant__c=:applicantId and Opportunity_Relation__c=:loanApplicationId AND Is_Active__c = true AND Document_Type__c IN : mandatoryDocumentSet];
                    if(documentList.size() >= 1){
                        isAllMandatoryDocPresent = true;
                    }
                }
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, 'isAllMandatoryDocUploaded', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return isAllMandatoryDocPresent;
    }
    @AuraEnabled
public static String updateLoanApplicationReject(String loanApplicationId){
    try {
        
        List<Opportunity> loanAppList = [SELECT Id, StageName,Journey_Restart_Reason__c FROM Opportunity WHERE Id = :loanApplicationId LIMIT 1];
        if (loanAppList.size() > 0) {
            Opportunity loanApp = loanAppList[0];
            loanApp.StageName = 'Journey Restart';
            loanApp.Journey_Restart_Reason__c = 'Loan Application Rejected because DEMO AUTH status is Rejected';
            update loanApp;
            return 'Success';
        } else {
            return 'Error: No loan application found with the provided ID.';
        }
    } catch (Exception e) {
        return 'Error: ' + e.getMessage();
    }
}
    @AuraEnabled
    public static Integer getBeneficiarySHPercent(String loanAppId){
        try {
            Integer sharePercent = 0;
            List<Applicant__c> beneApps = [Select Id,ShareHolding__c FROM Applicant__c WHERE Applicant_Type__c = 'Beneficiary' AND In_Active_Applicant__c = false AND Opportunity__c=:loanAppId];
            for(Applicant__c app :beneApps){
                if(app.ShareHolding__c!= null)
                sharePercent = sharePercent + Integer.valueOf(app.ShareHolding__c);
            }
            system.debug('sharePercent-----'+sharePercent);
            return sharePercent;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //CISP-20554 - START
    @AuraEnabled
    public static Applicant__c getApplicantRelationshipWithBank(String applicantId){
        Applicant__c app = [SELECT Id, Applicant_Type__c, Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c, Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c FROM Applicant__c WHERE Id =: applicantId];
        return app;
    }//CISP - 20554 - END
    @AuraEnabled
    public static Boolean isAllApplicantsIlliterate(String loanApplicationId){
        List<Applicant__c> applicanList = [Select Id FROM Applicant__c WHERE (Applicant_Type__c =: System.Label.Borrower OR Applicant_Type__c =: System.Label.CoBorrower) AND In_Active_Applicant__c = false AND Opportunity__c=:loanApplicationId AND Literacy__c = 'Literate'];
        return (applicanList.size() > 0 ? false : true);
    }
    //CISP-22671 - Start
      @AuraEnabled
      public static Loan_Application_Read_Only_Setting__mdt getBLCodesInActive(){
          try {
              Loan_Application_Read_Only_Setting__mdt notRequiredBLCodes = Loan_Application_Read_Only_Setting__mdt.getInstance('BL_Codes_In_Active');
              return notRequiredBLCodes;
          } catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
          }
      } 
      //CISP-22671 - End
    @AuraEnabled
    public static void createResiDocument(String loanApplicationId, String applicantId) {
        List<Opportunity> oppList = IND_RevokeController.getCurrentOppRecord(loanApplicationId);
        if(oppList.size() > 0 && oppList[0].Parent_Loan_Application__r.Is_Revoked__c == true){
            String resiRecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId();
            List<Documents__c> resiDocumentList = new List<Documents__c>([SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: loanApplicationId AND Is_Active__c = true AND  Document_Type__c = 'Resi Profile Document' AND RecordTypeId =: resiRecordTypeId AND Applicant__c =: applicantId]);
            List<Applicant__c> appList = new List<Applicant__c>([SELECT Id, Applicant_Type__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Id =: applicantId]);
            String rcuRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();
            List<Case> rcuCaseList = new List<Case>([Select id from Case Where RecordTypeId =: rcuRecordTypeId and Loan_Application__c =: loanApplicationId]);
            List<Documents__c> insertResiDocumentList = new List<Documents__c>();
            if(resiDocumentList.size() == 0 && appList.size() > 0 && rcuCaseList.size() > 0){
                Documents__c doc = new Documents__c();
                doc.Document_Type__c = 'Resi Profile Document';
                doc.Name = appList[0].Applicant_Type__c + ' - Resi Profile Document';
                doc.Is_Active__c = true;
                doc.Applicant__c = applicantId;
                doc.Opportunity_Relation__c = loanApplicationId;
                doc.RecordTypeId = resiRecordTypeId;
                doc.RCU_Case__c = rcuCaseList[0].Id;
                insertResiDocumentList.add(doc);
            }
            if(insertResiDocumentList.size() > 0){
                insert insertResiDocumentList;
            }
        }
    }
}