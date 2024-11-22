@RestResource(urlMapping='/OlaInvoiceDocUpload/')
global with sharing class OlaInvoiceDocUploadAPI { 
    @HTTPPost
    global static void updateInvoiceDetails(){
        
        Boolean errorFlag = false;
        String errorMsg = '';
        RestRequest req  = RestContext.request;
        String payload = req.requestBody.toString();
        ResponseWrapper response = new responseWrapper();
        RequestWrapper jsonParsed = new RequestWrapper();
        String decryptedReqBody = IntegrationUtilities.getDecryptedResponse(payload,System.Label.privateKey,System.Label.ivkey);
        String encryptedResponse = '';
        String jdataRequest = '"JData":';   
        String loanId = ''; 

        try{
            jsonParsed =(RequestWrapper)JSON.deserialize(decryptedReqBody , RequestWrapper.class);
            //request validation start here
            if(jsonParsed.applicationNumber==null){
                errorFlag = true;
                errorMsg = 'applicationNumber is missing in the request';
            } else if(jsonParsed.documentType==null){
                errorFlag = true;
                errorMsg = 'documentType is missing in the request';
            } else if(jsonParsed.base64EncodedImage==null){
                errorFlag = true;
                errorMsg = 'base64EncodedImage is missing in the request';
            } else if(jsonParsed.fileName==null){
                errorFlag = true;
                errorMsg = 'fileName is missing in the request';
            } else if(jsonParsed.documentType!='Vehicle and charger invoice' && jsonParsed.documentType!='Downpayment receipt' && jsonParsed.documentType!='Registration invoice' && jsonParsed.documentType!='Split payment receipt' && jsonParsed.documentType!='Advanced payment receipt'){//OLA-215
                errorFlag = true;
                errorMsg = 'documentType value is wrong in the request, please use a valid value';
            }else{
                errorFlag = false;
                errorMsg = '';
            } 
            
            if(!errorFlag){
                List<Opportunity> latestOpp = [select Id,name from Opportunity where name=:jsonParsed.applicationNumber order by CreatedDate DESC limit 1];//OLA-275
                String soqlInvoice = 'SELECT id, Loan_Application__c, Documents__c FROM Invoice_Details__c WHERE Loan_Application__r.Lead_number__c= \'' + String.escapeSingleQuotes(jsonParsed.applicationNumber) + '\' and Loan_Application__c=\'' +String.escapeSingleQuotes(latestOpp[0].Id) + '\' LIMIT 1';//OLA-275
                String soqlIHM = 'SELECT id FROM IHM__c WHERE Loan_Application__r.Lead_number__c= \'' + String.escapeSingleQuotes(jsonParsed.applicationNumber) + '\' and Loan_Application__c= \'' +String.escapeSingleQuotes(latestOpp[0].Id) + '\' LIMIT 1';//OLA-275
                List<Invoice_Details__c> invoiceDetail = Database.query(soqlInvoice);
                List<Applicant__c> applcnt = [Select id from Applicant__c where Opportunity__c = :invoiceDetail.get(0).Loan_Application__c limit 1];
                List<IHM__c> ihmDetail = Database.query(soqlIHM);

                List<Documents__c> existingtInvoice = [Select id from Documents__c where Document_Type__c = 'IHM Receipt' and Opportunity_Relation__c=:invoiceDetail.get(0).Loan_Application__c Limit 1];

                Documents__c docObject= new Documents__c(Name = jsonParsed.documentType, is_Active__c=true);
                docObject.Applicant__c=applcnt.get(0).id;
                docObject.Opportunity_Relation__c=invoiceDetail.get(0).Loan_Application__c;
                loanId = invoiceDetail.get(0).Loan_Application__c;
                docObject.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
                if(jsonParsed.documentType=='Vehicle and charger invoice')
                    docObject.Document_Type__c = 'Invoice';
                if(jsonParsed.documentType=='Downpayment receipt'){
                    docObject.Document_Type__c = 'IHM Receipt';
                    docObject.id = (existingtInvoice.size()>0) ? existingtInvoice.get(0).id : docObject.id;
                }
                if(jsonParsed.documentType=='Registration invoice'){
                    docObject.Document_Type__c = 'RTO';
                }
                if(jsonParsed.documentType=='Split payment receipt'){//OLA-215
                    docObject.Document_Type__c = 'SPR';
                }
                if(jsonParsed.documentType=='Advanced payment receipt'){
                    docObject.Document_Type__c = 'APR';
                }//OLA-215
                    
                upsert docObject;

                if(docObject.Document_Type__c=='Invoice'){
                    invoiceDetail.get(0).Documents__c = docObject.id;
                    update invoiceDetail;
                }

                Blob body = EncodingUtil.base64Decode(jsonParsed.base64EncodedImage);

                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = invoiceDetail.get(0).Loan_Application__c+'_'+jsonParsed.documentType;
                cVersion.Origin = 'C';//CISP-2906
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = jsonParsed.fileName+'_'+jsonParsed.documentType+'_'+DateTime.now().millisecond();
                cVersion.VersionData = body;
                //cVersion.Document_Type__c = documentType;
                Insert cVersion;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = docObject.id;//link with invoice or IHM based on document type
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                Insert cDocLink;
                
                ContentDistribution cd = new ContentDistribution();
                cd.Name = cVersion.Title;
                cd.ContentVersionId = cVersion.id;
                cd.PreferencesAllowViewInBrowser= false;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                Insert cd; 

                RestContext.response.statusCode = 200;
                response.message = 'Invoice uploaded sucessfully';
                response.statusCode = '200';
                encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                RestContext.response.addHeader('Content-Type', 'application/json');

                IntegrationUtilities.createIntegrationLogger(payload, jsonParsed.toString(), 'Record created', '', 'OLA Request', '', loanId, System.Label.Success);
            } else{
                RestContext.response.statusCode = 400;
                response.message = errorMsg;
                response.statusCode = '400';
                encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                RestContext.response.addHeader('Content-Type', 'application/json');
            }
        } catch(Exception e){
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
            IntegrationUtilities.createIntegrationLogger(payload, jsonParsed.toString(), error, '', 'OLA Request', '', loanId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('OlaInvoiceDocUploadAPI', 'updateInvoiceDetails', System.Label.Apex, e,loanId);
            
        }

    }
    public class ResponseWrapper{
        Public String message;
        Public String statusCode;
    }

    Public class RequestWrapper{
        Public String applicationNumber;
        Public String documentType;
        Public String base64EncodedImage;
        Public String fileName;
    }
}