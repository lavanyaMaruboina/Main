@IsTest
public class OlaInvoiceDocUploadAPITest {
    // InThis Method we create the opportunity and Invoice and Ihm and Applicant and pass The sample RequestData
    static testmethod void invoiceDocUpload(){
        Test.startTest();
        Opportunity opp=new Opportunity();
        opp.name='jhon doe';
        opp.CloseDate=system.Today();
        opp.StageName='Qualification';
        opp.Application_number__c='A123456789';
        opp.Lead_number__c = 'A123456789';
        insert opp;
        Invoice_Details__c inv =new Invoice_Details__c();
        inv.Tax_Invoice_No__c='9283yekjd';
        inv.Loan_Application__c=opp.Id;
        inv.Tax_Invoice_Date__c=date.newInstance(1996,02,03);
        insert inv; 
        IHM__c ih= new IHM__c();
        ih.Loan_Application__c=opp.Id;
        insert ih;
        Applicant__c app=new Applicant__c();
        app.Opportunity__c=opp.Id;
        insert app;
        /**Vehicle_Detail__c  veh =new Vehicle_Detail__c();
veh.Loan_Application__c=opp.Id;
veh.Model__c = '7931iusd';
veh.Engine_number__c='912873ighaskd';
veh.Vehicle_Registration_number__c ='ksd82736ekj';
insert veh;**/        
        string olaInvoiceUploadjson='{\"applicationNumber\":\"A123456789\",\"documentType\":\"Vehicle and charger invoice\",\"fileName\":\"TestInvoiceFile\",\"base64EncodedImage\":\"7931iusd\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaInvoiceUploadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceDocUploadAPI.updateInvoiceDetails();
        Test.stopTest();
        
    }
    //In This ethod we are passing the ApplicationNumber Value Is Null 
    static testmethod void invoiceApplicationNumberCheck(){
        Test.startTest();
        string olaInvoiceUploadjson='{\"applicationNumber\":null,\"documentType\":\"Vehicle and charger invoice\",\"fileName\":\"TestInvoiceFile\",\"base64EncodedImage\":\"7931iusd\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaInvoiceUploadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceDocUploadAPI.updateInvoiceDetails();
        Test.stopTest();
        
    }
    //In This Method we are passing the documentType Value Is Null 
    static testmethod void invoiceDocumentTypeCheck(){
        Test.startTest();
        string olaInvoiceUploadjson='{\"applicationNumber\":\"A123456789\",\"documentType\":null,\"fileName\":\"TestInvoiceFile\",\"base64EncodedImage\":\"7931iusd\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaInvoiceUploadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceDocUploadAPI.updateInvoiceDetails();
        Test.stopTest();
        
    }
    //In This Method we are passing the FileName Value Is Null. 
    static testmethod void invoiceFileNameCheck(){
        Test.startTest();
        string olaInvoiceUploadjson='{\"applicationNumber\":\"A123456789\",\"documentType\":\"Vehicle and charger invoice\",\"fileName\":null,\"base64EncodedImage\":\"7931iusd\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaInvoiceUploadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceDocUploadAPI.updateInvoiceDetails();
        Test.stopTest();
        
    }
    //In This Method we are Passing the base64EncodedImage value is Null. 
    static testmethod void invoiceBase64EncodedImageCheck(){
        Test.startTest();
        string olaInvoiceUploadjson='{\"applicationNumber\":\"A123456789\",\"documentType\":\"Vehicle and charger invoice\",\"fileName\":\"TestInvoiceFile\",\"base64EncodedImage\":null}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaInvoiceUploadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceDocUploadAPI.updateInvoiceDetails();
        Test.stopTest();
        
    }
    // In This Method documentType Is Text datatype. but we are passing the Number Here.
    /* static testmethod void wrongValueDocumentTypecheck(){
string olaInvoiceUploadjson='{\"applicationNumber\":\"A123456789\",\"documentType\":\"1345455236365\",\"fileName\":\"TestInvoiceFile\",\"base64EncodedImage\":\"7931iusd\"}';
RestRequest request = new RestRequest();
RestResponse response = new RestResponse();
request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
system.debug('request.requestURI---' + request.requestURI);
request.httpMethod = 'Post';
request.requestBody = Blob.valueof(olaInvoiceUploadjson);
request.addHeader('Content-Type', 'application/json');
RestContext.request = request;
RestContext.response =response;
OlaInvoiceDocUploadAPI.updateInvoiceDetails();
Test.stopTest();
}*/
}