/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This class is controller class for CONVOX API related functionalities
Test Class:    conVoxAPIHandlerTest
History
Date            Author              Comments
-------------------------------------------------------------
16-08-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
public class conVoxAPIHandler {
    Public static List<Integration_Log__c> intLogRecords = new List<Integration_Log__c>();
    /*
     * @Method:      callApi
     * @Created by:  Haarika Chodisetti
     * @Description: prepares body for GETLISTALL api, calls invokeAPI and then channelise the given task
     * @Param:       task (String) - API methods,
                     mobile  (String) - Applicant Contact Number,
                     applicantId (Id) - Applicant record id
     * @Return:     
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    @future (callout=true)
	public static void callApi(String task,String mobile,Id applicantId) {
        callApibodyWrapper mainBody = new callApibodyWrapper();
         
        mainBody.action = IntegrationConstants.CONVOX_GETLISTALL;
        mainBody.process = IntegrationConstants.CONVOX_PROCESS;
        
        String JSONMainBody = JSON.serialize(mainBody);
        
        HttpResponse response = invokeAPI(JSONMainBody);
        if(response?.getStatusCode() == 200) {
    		resultWrapper result = new resultWrapper();
            String ResponseString = getDecryptedResponse(response.getBody());
            system.debug('ResponseString: '+ResponseString);
            resultWrapper res = (resultWrapper) JSON.deserialize(ResponseString, resultWrapper.class);
            
            //resultWrapper res = (resultWrapper) JSON.deserialize(response.getBody(), resultWrapper.class);
            String[] params = 
            res.ActiveListID.split('-');
            if(task == IntegrationConstants.CONVOX_DATAUPLOAD && params[0]!= null){
                dataUpload(mobile,applicantId,params[0]);
            }
            else if(task == IntegrationConstants.CONVOX_DELETELEAD){
                deleteLead(params[0]);
            }
		}
        saveIntegrationLog(intLogRecords);
    }

    /*
     * @Method:      callApi
     * @Created by:  Haarika Chodisetti
     * @Description: prepares body for DATAUPLOAD api and calls invokeAPI
     * @Param:       mobile  (String) - Applicant Contact Number,
                     listId (Id) - list id of process
     * @Return:      
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static void dataUpload(String mobile,Id applicantId, String listId) {
        dataUploaddataWrapper subBody = new dataUploaddataWrapper();
        dataUploadbodyWrapper mainBody = new dataUploadbodyWrapper();
        subBody.mobile = mobile;
        subBody.info_1 = applicantId;
        String JSONSubBody = JSON.serialize(subBody);
        
        mainBody.process = IntegrationConstants.CONVOX_PROCESS;
        mainBody.list_id = listId;
        mainBody.action = IntegrationConstants.CONVOX_DATAUPLOAD;
        mainBody.data = new List<dataUploaddataWrapper>{subBody};
        mainBody.refno = '1234';
        mainBody.batch_id = '1234';
        String JSONMainBody = JSON.serialize(mainBody);
        
        HttpResponse response = invokeAPI(JSONMainBody);

        String ResponseString = getDecryptedResponse(response.getBody());
        system.debug('ResponseString: '+ResponseString);
        Object JSONParsed =JSON.deserializeUntyped(ResponseString);
        system.debug('JSONParsed: '+JSONParsed);

	}
    
    /*
     * @Method:      deleteLead
     * @Created by:  Haarika Chodisetti
     * @Description: prepares body for DELETELEAD api and calls invokeAPI
     * @Param:       listId (Id) - list id of process
     * @Return:
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static void deleteLead(String listId) {
        Set<String> dispositions = IntegrationConstants.TO_BE_DELETED_DISPOSITIONS;
        String subDisp = IntegrationConstants.TO_BE_DELETED_SUBDISPOSITION;
        String strAppIds = '';
        String strAppPhoneNumbers = '';
        List<Opportunity> completedOpps = [SELECT Id FROM Opportunity WHERE LeadSource = 'D2C' 
        AND D2C_Stage__c != 'Pre Initial Offer' AND CreatedDate = TODAY ];

        for(Applicant__c app: [SELECT Id,Name,Contact_number__c FROM Applicant__c WHERE Disposition__c IN: dispositions OR Sub_Disposition__c =: subDisp OR Opportunity__c IN : completedOpps]){
            if(strAppIds.length()==0){
                strAppIds = app.Id;
                strAppPhoneNumbers = app.Contact_number__c;
                continue;
            }
            strAppIds += ','+app.Id;
            strAppPhoneNumbers += ','+app.Contact_number__c;
        }
        system.debug('strAppIds: '+strAppIds);
        deleteLeadbodyWrapper mainBody = new deleteLeadbodyWrapper();
        mainBody.action = IntegrationConstants.CONVOX_DELETELEAD;
        mainBody.phone_number = strAppPhoneNumbers;
        mainBody.info_1 = strAppIds;
        mainBody.list_id = listId;

        String JSONMainBody = JSON.serialize(mainBody);
        
		HttpResponse response = invokeAPI(JSONMainBody);
        
        String ResponseString = getDecryptedResponse(response.getBody());
        system.debug('ResponseString: '+ResponseString);
        Object JSONParsed =JSON.deserializeUntyped(ResponseString);
        system.debug('JSONParsed: '+JSONParsed);

    }

    /*
     * @Method:      invokeAPI
     * @Created by:  Haarika Chodisetti
     * @Description: calls different apis with the passed body
     * @Param:       body - body of requests
     * @Return:      HttpResponse 
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static HttpResponse invokeAPI(string body){
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(body, System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';
        String finalBody='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
        HttpResponse response;
        try{
            System.debug('finalBody : '+finalBody);
            ConVox_Configuration__c configValues = ConVox_Configuration__c.getInstance();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(50000);
            request.setMethod(IntegrationConstants.METHOD_POST);
            request.setHeader(IntegrationConstants.CONTENT_TYPE, IntegrationConstants.CONVOX_CONTENT_TYPE_JSON);
            request.setHeader(IntegrationConstants.CONVOX_ACCESS_TOKEN_HEADER, System.Label.ConVox_AccessToken);
            request.setEndpoint(configValues.EndPoint__c);
            request.setBody(finalBody);
            response = http.send(request);
            intLogRecords.add(
                new Integration_Log__c(
                    Service_Name__c = 'ConVox:'+((Map<String, Object>)JSON.deserializeUntyped(body))?.get('action')?.toString(),
                    Encrypted_request__c = request.getBody(),
                    Encrypted_response__c = response.getBody(),
                    Original_request__c = body,
                    Original_response__c = getDecryptedResponse(response.getBody()),
                    Status__c = response.getStatus()
                )
            );
            system.debug('response: '+response.getBody());
            return response;
        }catch(Exception e){
            intLogRecords.add(
                new Integration_Log__c(
                    Service_Name__c = 'ConVox:'+((Map<String, Object>)JSON.deserializeUntyped(body))?.get('action')?.toString(),
                    Encrypted_request__c = finalBody,
                    Encrypted_response__c = '',
                    Original_request__c = body,
                    Original_response__c = '',
                    Status__c = response?.getStatus()
                )
            );
            return null;
        }
    }

    public static String getDecryptedResponse(String response){
        response = response.remove('\\').trim();
        if(response.contains('JData')){
            return IntegrationUtilities.getPlainTextForLog(response);
        }else{
            return IntegrationUtilities.getDecryptedResponse(response, System.Label.privateKey, System.Label.ivkey);
        }
    }


    /*
     * @Method:      saveIntegrationLog
     * @Created by:  Haarika Chodisetti
     * @Description: saves Integration_Log__c record
     * @Param:       HttpRequest request,
                     HttpResponse response
     * @Return:      
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static void saveIntegrationLog(List<Integration_Log__c> intLogRecords){
        if (Schema.sObjectType.Integration_Log__c.isCreateable() || Schema.sObjectType.Integration_Log__c.isUpdateable()){
            upsert intLogRecords;
        }
    }

    //Haarika - 16-08-2022 - To store body of DATAUPLOAD api
    public class dataUploadbodyWrapper{
        public String process { get; set; }
        public String list_id { get; set; }
        public List<dataUploaddataWrapper> data{ get; set; }
        public String action { get; set; }
        public String refno { get; set; }
        public String batch_id { get; set; }
    }
    
    //Haarika - 16-08-2022 - To store data field of DATAUPLOAD api's body
    public class dataUploaddataWrapper{
        public String mobile { get; set; }
        public String info_1 { get; set; }
    }
    
    //Haarika - 16-08-2022 - To store body of DELETELEAD api
    public class deleteLeadbodyWrapper{
        public String action { get; set; }
        public String phone_number { get; set; }
        public String info_1 { get; set; }
        public String list_id { get; set; }
    }

    //Haarika - 16-08-2022 - To store body of GETLISTALL api
    public class callApibodyWrapper{
        public String action { get; set; }
        public String process { get; set; }
    }

    //Haarika - 16-08-2022 - To store result of GETLISTALL api
    public class resultWrapper{
        public String status { get; set; }
        public String message { get; set; }
        public String ActiveListID { get; set; }
        public String DeActiveListID { get; set; }
    }
}