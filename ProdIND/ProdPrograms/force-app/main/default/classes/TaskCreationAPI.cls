/**
* @Name         TaskCreationAPI
* @Author       Siddhesh Jawale
* @Company      Salesforce
* @Description  This is a web service class to create a Task
* Inputs:       Task Fields
* Test Class:   TaskCreationAPITest
*/
@RestResource(urlMapping='/saveCallDetails/*')
global with sharing class TaskCreationAPI {
    
    @HttpPost
    global static void createTask() {
        ResponseWrapper response = new ResponseWrapper();
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        try {
            //Request
            RestRequest req  = RestContext.request;
            
            //encrypted request
            String stringEncryptedRequest=req.requestBody.toString();
            //decrypt the encrypted request
            String taskResponseString = IntegrationUtilities.getPlainTextForLog(stringEncryptedRequest);
            TaskWrapper reqData = (TaskWrapper) JSON.deserialize(taskResponseString, TaskWrapper.class);
            //TaskWrapper reqData = (TaskWrapper) JSON.deserialize(req.requestBody.toString(), TaskWrapper.class);
            
            if(String.isBlank(reqData.Disposition) || String.isBlank(reqData.Sub_Disposition) || String.isBlank(reqData.Status)) {
                response.success = FALSE;
                response.errors.add('Disposition, Sub-Disposition, Status cannot be blank');
            } else if(String.isBlank(reqData.WhatId)){
                response.success = FALSE;
                response.errors.add('What Id must be set to Applicant Id.');
            }else {
                Task t = new Task();
                t.Subject = reqData.Subject;
                t.Status = reqData.Status;
                t.callstatus__c = reqData.CallStatus;
                t.call_type__c = reqData.call_type;
                t.ActivityDate = reqData.Activitydate != null ? Date.valueOf(reqData.Activitydate): null;
                t.CallObject = reqData.CallObject;
                t.customer_phone__c = reqData.customer_phone;
                t.recording_file__c = reqData.recording_file;
                t.agent_id__c  = reqData.agent_id;
                t.did_num__c = reqData.did_num;
                t.extension_num__c = reqData.extension_num;
                t.process_name__c = reqData.process_name;
                t.queue_name__c = reqData.queue_name;
                t.WhatId = reqData.WhatId;
                t.isCTI_activity__c = reqData.isCTI_activity != null ? Boolean.valueOf(reqData.isCTI_activity) : false;
                t.CallDisposition = reqData.CallDisposition;
                t.disposition__c = reqData.Disposition;
                t.sub_disposition__c = reqData.Sub_Disposition;
                t.CallDurationInSeconds = String.isNotBlank(reqData.CallDurationInSeconds) ? Integer.valueOf(reqData.CallDurationInSeconds) : null;
                t.Remarks__c = reqData.remarks;
                t.Followup_time__c = reqData.followupTime;//Datetime.parse(reqData.followupTime);
                
                if(String.isNotBlank(t.extension_num__c)) {
                    List<User> users = [SELECT Id FROM User WHERE MobilePhone =: t.extension_num__c LIMIT 1];
                    if(users.size() > 0) {
                        t.ownerId = users[0].Id;
                    }
                }
                
                insert t;
                response.id = t.Id;
                
                
            }
            
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('TaskCreationAPI', 'createTask', System.Label.Apex, e, null);
            response.success = FALSE;
            response.errors.add(e.getMessage() + ' - ' + e.getStackTraceString());
        }
        String decryptedResponse = JSON.serialize(response);
        //encrypting the response
        String encryptedResponse = IntegrationUtilities.getEncryptedRequest(decryptedResponse,System.Label.privateKey,System.Label.ivkey); 
        //setting the response body
        String jdataRequest1 = '"JData":';                    
        String body1='{'+jdataRequest1 + '"'+encryptedResponse+'"'+'}';
        RestContext.response.responseBody = Blob.valueOf(body1);
        //RestContext.response.responseBody = Blob.valueOf(Json.serialize(response));
    }
    
    public class TaskWrapper{
        public String Subject;
        public String Status;
        public String CallStatus;
        public String call_type;
        public String Activitydate;
        public String CallObject;
        public String customer_phone;
        public String recording_file;
        public String agent_id;
        public String did_num;
        public String extension_num;
        public String process_name;
        public String queue_name;
        public String WhatId;
        public String isCTI_activity;
        public String CallDisposition;
        public String Disposition;
        public String Sub_Disposition;
        public String CallDurationInSeconds;
        public String remarks;
        public DateTime followupTime;
    }
    
    public class ResponseWrapper{
        public String id;
        public Boolean success;
        public List<String> errors;
        
        public ResponseWrapper() { this.success = TRUE; this.errors = new List<String>(); }
    }
}