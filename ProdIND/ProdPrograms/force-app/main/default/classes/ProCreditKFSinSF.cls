@RestResource(urlMapping='/v1/proCreditKFSinSF/*')
global class ProCreditKFSinSF {

    @HttpGet
    global static void getSmsUrl() {
        RestRequest request = RestContext.request;
        String uniqueId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        System.debug('unique__id__'+uniqueId);
        ProCredit_Deals__c pcd = [SELECT Id,SMS_URL__c,Error_Message__c FROM ProCredit_Deals__c WHERE Unique_Id__c=:uniqueId ORDER BY CreatedDate DESC LIMIT 1 ];
        String jdataRequest = '"JData":';
        ResponseWrapper response = new responseWrapper();
        if(pcd.SMS_URL__c!=null){
            response.message = pcd.SMS_URL__c;
            response.statusCode = '201';
            RestContext.response.statusCode = 201; 
        }else{
            response.message = pcd.Error_Message__c!=null ? pcd.Error_Message__c :'URL not generated, Please retrigger after sometime';
            response.statusCode = '500';
            RestContext.response.statusCode = 500; 
        }
        String encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
        RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
        RestContext.response.addHeader('Content-Type', 'application/json');
    }

@HttpPost
    global static void uploadLeadDetails(){
        Boolean errorFlag = false;
        String errorMsg = '';
        String jdataRequest = '"JData":';
        RestRequest req  = RestContext.request;
        ResponseWrapper response = new responseWrapper();
        // RequestWrapper jsonParsed = new RequestWrapper();
        List<String> dealNumbers = new List<String>();
        String leadPayload = req.requestBody.toString();
        System.debug('leadPayload___'+leadPayload);
        String decryptedReqBody = IntegrationUtilities.getDecryptedResponse(leadPayload,System.Label.privateKey,System.Label.ivkey);
        ProCreditDealRequestClass pcdrc = new ProCreditDealRequestClass();
        ProCredit_Deals__c pcd = new ProCredit_Deals__c();
        String entityType = '';
        try{ 
            pcdrc = pcdrc.parseJSON(decryptedReqBody);
            List<ProCreditDealRequestClass.DealNumbers> metaObj = new List<ProCreditDealRequestClass.DealNumbers>();
            metaObj = pcdrc.DealNumbers;
            for(ProCreditDealRequestClass.DealNumbers dn : metaObj){
                dealNumbers.add(dn.Deal_No);
            }

            entityType = pcdrc.Entity_Type;
            
            pcd.Maker_Id__c = pcdrc.Maker_Id;
            pcd.Product_Type__c = pcdrc.Product;
            pcd.Unique_Id__c = pcdrc.Unique_Id;
            pcd.Entity_Type__c = pcdrc.Entity_Type;
            insert pcd;

            Key_Fact_Statement__c kfsparent = new Key_Fact_Statement__c();
            kfsparent.ProCredit_Deal__c = pcd.Id;
            kfsparent.Keyfact_Consent_OTP__c = String.valueOf(Math.floor(Math.random() * 10000).intValue());
            //kfsparent.Keyfact_Consent_OTP__c = pcdrc.Unique_Id;
            kfsparent.Entity_Type__c = pcdrc.Entity_Type;
            kfsparent.Product_Type__c = pcdrc.Product;
            kfsparent.Maker_Id__c = pcdrc.Maker_Id;
            kfsparent.Unique_Id__c = pcdrc.Unique_Id;
            insert kfsparent;

           // if(dealNumbers.size() < 99){
            if(!Test.isRunningTest()){
                	DealNumberBatch batch = new DealNumberBatch(dealNumbers, pcd.Id, kfsparent.Id, entityType, true,pcdrc.Product);
            Database.executeBatch(batch,1);
            }
            

            response.message = 'Deal created successfully in Salesforce';
            response.statusCode = '201';
            RestContext.response.statusCode = 201; 
            System.debug('response__'+response);
            String encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
            RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            RestContext.response.addHeader('Content-Type', 'application/json');
            //}
        }
        catch(Exception ex){ 
            system.debug('exception --' + ex.getMessage()); 
            RestContext.response.statusCode = 400;
            response.message = 'Something went wrong';
            response.statusCode = '400';
            String encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
            RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            RestContext.response.addHeader('Content-Type', 'application/json');
            String deserror = 'Something went wrong ---> '+ex.getMessage()+ ' Exception line number-->'+ex.getLineNumber();
            String error = '{ "response": { "status": "FAILED", "respDesc": "'+deserror+'"} }';
            ErrorLoggerUtil.logErrorEventProCreditDeal('ProcreditDealTransferAPI', 'uploadLeadDetails', System.Label.Apex, ex,pcd.id);
        }


        /*
        String encryptedResponse = '';
        String jdataRequest = '"JData":';
        String kfsRequestString ='';
        ProCredit_Deals__c pcd = new ProCredit_Deals__c();
        try{
            jsonParsed =(RequestWrapper)JSON.deserialize(decryptedReqBody , RequestWrapper.class);
            if(jsonParsed.Application_No==null  || jsonParsed.Application_No == ''){
                errorFlag = true;
                errorMsg = 'Application No is missing in the request';
            }else if(jsonParsed.Deal_No==null  || jsonParsed.Deal_No == ''){
                errorFlag = true;
                errorMsg = 'Deal No is missing in the request';
            }else if(jsonParsed.Maker_Id==null  || jsonParsed.Maker_Id == ''){
                errorFlag = true;
                errorMsg = 'Maker Id is missing in the request';
            }else if(jsonParsed.Product_Type==null  || jsonParsed.Product_Type == ''){
                errorFlag = true;
                errorMsg = 'Product Type is missing in the request';
            }else if(jsonParsed.Unique_Id==null || jsonParsed.Unique_Id == ''){
                errorFlag = true;
                errorMsg = 'Unique Id is missing in the request';
            }else{
                errorFlag = false;
                errorMsg = '';
            }
            
            if(!errorFlag){
                // List<ProCredit_Deals__c> existingProCreditDeals = [SELECT Id FROM ProCredit_Deals__c WHERE Deal_Number__c=:jsonParsed.Deal_No LIMIT 1];
                // if(existingProCreditDeals.size() > 0){
                // }else{
                    pcd.Application_Number__c = jsonParsed.Application_No;
                    pcd.Deal_Number__c = jsonParsed.Deal_No;
                    pcd.Maker_Id__c = jsonParsed.Maker_Id;
                    pcd.Product_Type__c = jsonParsed.Product_Type;
                    pcd.Unique_Id__c = jsonParsed.Unique_Id;
                    insert pcd;
                    jsonParsed.pcdId = pcd.Id;
                jsonParsed.fromProCredit = true;
                kfsRequestString = JSON.serialize(jsonParsed);
                try{
                    Id ReverseStatusQueuejobID = System.enqueueJob(new IND_KFSProcreditQueueable(kfsRequestString));
                } catch(Exception ex) {
                    //ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doReverseStatusCallout', System.Label.Apex, ex,loanAppId[0].LoanId);
                    //throw ex;
                }
                response.message = 'Deal created successfully in Salesforce';
                response.statusCode = '201';
                RestContext.response.statusCode = 201; 
                encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                RestContext.response.addHeader('Content-Type', 'application/json');
                
                
            } else {
                RestContext.response.statusCode = 400;
                response.message = errorMsg;
                response.statusCode = '400';
                encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);  
                RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                RestContext.response.addHeader('Content-Type', 'application/json');
            }
        } catch(exception e){
            system.debug('exc '+e.getMessage());
            system.debug('exc '+e.getLineNumber());
            RestContext.response.statusCode = 400;
            response.message = 'Something went wrong';
            response.statusCode = '400';
            encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
            RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            RestContext.response.addHeader('Content-Type', 'application/json');
            String deserror = 'Something went wrong ---> '+e.getMessage()+ ' Exception line number-->'+e.getLineNumber();
            String error = '{ "response": { "status": "FAILED", "respDesc": "'+deserror+'"} }';
            ErrorLoggerUtil.logErrorEventProCreditDeal('ProcreditDealTransferAPI', 'uploadLeadDetails', System.Label.Apex, e,pcd.id);
        }

        */
    }

   /* public class RequestWrapper{
        public String Application_No;
        public String Deal_No;
        public String Maker_Id;
        public String Product_Type;
        public String Unique_Id;
        public Boolean fromProCredit = true;
        public String pcdId;
    }
    */

    public class ResponseWrapper{
        public String message;
        public String statusCode; 
    }
}