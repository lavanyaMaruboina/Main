@RestResource(urlMapping='/OlaInvoiceUpdate/')
global with sharing class OlaInvoiceUpdateAPI { 
    @HTTPPut
    global static void updateInvoiceDetails(){
        
        Boolean errorFlag = false;
        String errorMsg = '';
        RestRequest req  = RestContext.request;
        String leadPayload = req.requestBody.toString();
        ResponseWrapper response = new responseWrapper();
        RequestWrapper jsonParsed = new RequestWrapper();
        String decryptedReqBody = IntegrationUtilities.getDecryptedResponse(leadPayload,System.Label.privateKey,System.Label.ivkey);
        String encryptedResponse = '';
        String jdataRequest = '"JData":';    
        String loanId = '';

        try{
            jsonParsed =(RequestWrapper)JSON.deserialize(decryptedReqBody , RequestWrapper.class);

            //request validation start
            if(jsonParsed.applicationNumber==null){
                errorFlag = true;
                errorMsg = 'applicationNumber is missing in the request';
            } else if(jsonParsed.invoiceNumber==null){
                errorFlag = true;
                errorMsg = 'invoiceNumber is missing in the request';
            } else if(jsonParsed.invoiceDate==null){
                errorFlag = true;
                errorMsg = 'invoiceDate is missing in the request';
            } else if(jsonParsed.model==null){
                errorFlag = true;
                errorMsg = 'model is missing in the request';
            } else if(jsonParsed.engineNumber==null){
                errorFlag = true;
                errorMsg = 'engineNumber is missing in the request';
            } else if(jsonParsed.registrationNumber==null){
                errorFlag = true;
                errorMsg = 'registrationNumber is missing in the request';
            } else if(jsonParsed.chassisNumber==null){
                errorFlag = true;
                errorMsg = 'chassisNumber is missing in the request';
            } else if(jsonParsed.invoiceCharger==null){
                errorFlag = true;
                errorMsg = 'invoiceCharger is missing in the request';
            } else if(jsonParsed.ihmReceiptNo==null){
                errorFlag = true;
                errorMsg = 'ihmReceiptNo is missing in the request';
            } else if(jsonParsed.ihmReceiptDate==null){
                errorFlag = true;
                errorMsg = 'ihmReceiptDate is missing in the request';
            } else{
                errorFlag = false;
                errorMsg = '';
            }

            if(!errorFlag){
                String applicationNo = jsonParsed.applicationNumber;
                List<Opportunity> latestOpp = [select Id,name from Opportunity where name=:jsonParsed.applicationNumber order by CreatedDate DESC limit 1];//OLA-275    
                String soqlInvoice = 'SELECT id, Tax_Invoice_No__c, Tax_Invoice_Date__c,Loan_Application__c  FROM Invoice_Details__c WHERE Loan_Application__r.Lead_number__c= \'' + String.escapeSingleQuotes(applicationNo) + '\' and Loan_Application__c=\'' + String.escapeSingleQuotes(latestOpp[0].Id) + '\' LIMIT 1';//OLA-275
                String soqlVehicle = 'SELECT id, Model__c, Engine_number__c, Vehicle_Registration_number__c FROM Vehicle_Detail__c WHERE Loan_Application__r.Lead_number__c= \'' + String.escapeSingleQuotes(applicationNo) + '\' and Loan_Application__c=\'' + String.escapeSingleQuotes(latestOpp[0].Id) + '\' LIMIT 1';//OLA-275
                String soqlIHM = 'SELECT id, Total_IHM_paid_to_dealer_A__c FROM IHM__c WHERE Loan_Application__r.Lead_number__c= \'' + String.escapeSingleQuotes(applicationNo) + '\' and Loan_Application__c=\'' + String.escapeSingleQuotes(latestOpp[0].Id) + '\' LIMIT 1';//OLA-275
                String soqlApplicant = 'SELECT id FROM Applicant__c WHERE Opportunity__r.Lead_number__c= \'' + String.escapeSingleQuotes(applicationNo) + '\' and Opportunity__c=\'' + String.escapeSingleQuotes(latestOpp[0].Id) + '\' LIMIT 1';//OLA-275
                String soqlLoanDisb = 'Select id from LoanDisbursementDetails__c where Parent_Loan_Application__r.Lead_number__c=\''+ String.escapeSingleQuotes(applicationNo) + '\' and Parent_Loan_Application__c=\'' + String.escapeSingleQuotes(latestOpp[0].Id) + '\' LIMIT 1';//OLA-275
                List<Invoice_Details__c> invoiceDetail = Database.query(soqlInvoice);
                List<Vehicle_Detail__c> vehicleDetail = Database.query(soqlVehicle);
                List<IHM__c> ihmDetails = Database.query(soqlIHM);
                List<Applicant__c> applicantDetails = Database.query(soqlApplicant);
                List<LoanDisbursementDetails__c> loanDisbList = Database.query(soqlLoanDisb);

                if(invoiceDetail.size()==0){
                    errorFlag = true;
                    errorMsg = 'Invoice detail not found for the given application number.';
                    RestContext.response.statusCode = 400;
                    response.message = errorMsg;
                    response.statusCode = '400';
                    encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                    RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                    RestContext.response.addHeader('Content-Type', 'application/json');
                } else if(vehicleDetail.size()==0){
                    errorFlag = true;
                    errorMsg = 'Vehicle detail not found for the given application number.';
                    RestContext.response.statusCode = 400;
                    response.message = errorMsg;
                    response.statusCode = '400';
                    encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                    RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                    RestContext.response.addHeader('Content-Type', 'application/json');
                } else {
                    invoiceDetail.get(0).Tax_Invoice_No__c = jsonParsed.invoiceNumber;
                    invoiceDetail.get(0).Tax_Invoice_Date__c = jsonParsed.invoiceDate;
                    invoiceDetail.get(0).Chassis_No__c = jsonParsed.chassisNumber;
                    invoiceDetail.get(0).Invoice_Charger__c = jsonParsed.invoiceCharger;
                    invoiceDetail.get(0).Engine_No__c = jsonParsed.engineNumber;
                    loanId = invoiceDetail.get(0).Loan_Application__c;
                    update invoiceDetail;

                    //vehicleDetail.get(0).Model__c = jsonParsed.model;
                    vehicleDetail.get(0).Engine_number__c = jsonParsed.engineNumber;
                    vehicleDetail.get(0).Vehicle_Registration_number__c = jsonParsed.registrationNumber;
                    update vehicleDetail;

                    LoanDisbursementDetails__c loanDisDetails = new LoanDisbursementDetails__c();
                    loanDisDetails.Chassis_No__c = jsonParsed.chassisNumber;
                    loanDisDetails.Engine_No__c = jsonParsed.engineNumber;
                    if(loanDisbList.size()>0){
                        loanDisDetails.id = loanDisbList.get(0).id;
                        update loanDisDetails;
                    }

                    List<Documents__c> existingtInvoice = [Select id from Documents__c where Document_Type__c = 'IHM Receipt' and Opportunity_Relation__c=:invoiceDetail.get(0).Loan_Application__c Limit 1];

                    Documents__c docObject= new Documents__c(Name = 'IHM', is_Active__c=false);
                    
                    docObject.Opportunity_Relation__c=invoiceDetail.get(0).Loan_Application__c;
                    docObject.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
                    docObject.Document_Type__c = 'IHM Receipt';
                    docObject.IHM_receipt_number__c = jsonParsed.ihmReceiptNo;
                    docObject.IHM_receipt_date__c = jsonParsed.ihmReceiptDate;
                    docObject.id = (existingtInvoice.size()>0) ? existingtInvoice.get(0).id : docObject.id;
                    docObject.IHM_amount_as_per_receipt__c = ihmDetails.size()>0 ? ihmDetails.get(0).Total_IHM_paid_to_dealer_A__c : docObject.IHM_amount_as_per_receipt__c;
                    if(existingtInvoice.size()==0){
                        docObject.Applicant__c = applicantDetails.size()>0 ? applicantDetails.get(0).id : '';//adding required fields
                        insert docObject;
                    } else {
                        update docObject;
                    }

                    RestContext.response.statusCode = 200;
                    response.message = 'Invoice updated sucessfully';
                    response.statusCode = '200';
                    encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                    RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), 'Record created', '', 'OLA Request', '', loanId, System.Label.Success);
                }
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
            RestContext.response.addHeader('Content-Type', 'application/json');
            encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
            RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');

            String deserror = 'Something went wrong ---> '+e.getMessage()+ ' Exception line number-->'+e.getLineNumber();
            String error = '{ "response": { "status": "FAILED", "respDesc": "'+deserror+'"} }';
            IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), error, '', 'OLA Request', '', loanId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('OlaInvoiceUpdateAPI', 'updateInvoiceDetails', System.Label.Apex, e,loanId);
            
        }
    }

    public class ResponseWrapper{
        Public String message;
        Public String statusCode;
    }

    Public class RequestWrapper{
        Public String applicationNumber;
        Public String invoiceNumber;
        Public Date invoiceDate;
        Public String model;
        Public String engineNumber;
        Public String registrationNumber;
        Public String chassisNumber;
        Public String invoiceCharger;
        Public String ihmReceiptNo;
        Public Date ihmReceiptDate;
        
    }
}