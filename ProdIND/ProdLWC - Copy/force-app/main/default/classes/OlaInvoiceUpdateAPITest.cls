@IsTest
public class OlaInvoiceUpdateAPITest {
    //In This Method Inser The Opportunity and Invoice and Vehicle Details and pass SampleRequest. 
    static testMethod void invoiceUpdateRequest(){
        Test.startTest();
        Opportunity opp=new Opportunity();
        opp.name='jhon doe';
        opp.CloseDate=system.Today();
        opp.StageName='Qualification';
        opp.Application_number__c='A123456789';
        insert opp;
        
        Opportunity opp1=new Opportunity();
        opp1.name='jhon test';
        opp1.CloseDate=system.Today();
        opp1.Lead_number__c='32323';
        opp1.StageName='Qualification';
        opp1.Application_number__c='A123456789';
        insert opp1;
        Invoice_Details__c inv =new Invoice_Details__c();
        inv.Tax_Invoice_No__c='9283yekjd';
        inv.Loan_Application__c=opp.Id;
        inv.Tax_Invoice_Date__c=date.newInstance(1996,02,03);
        insert inv; 
        Invoice_Details__c inv1 =new Invoice_Details__c();
        inv1.Tax_Invoice_No__c='9283yekjd';
        inv1.Loan_Application__c=opp1.Id;
        inv1.Tax_Invoice_Date__c=date.newInstance(1996,02,03);
        insert inv1; 
        Vehicle_Detail__c  veh =new Vehicle_Detail__c();
        veh.Loan_Application__c=opp.Id;
        veh.Model__c = '7931iusd';
        veh.Engine_number__c='912873ighaskd';
        veh.Vehicle_Registration_number__c ='ksd82736ekj';
        insert veh;
        //Test.startTest();
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    // In This Method.ApplicationNumber value Passing 'null'.
    static testmethod void invoiceApplicationNumberCheck(){
        Test.startTest();
        string olainvoicejson='{\"applicationNumber\":null,\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    // In This Method.InvoiceNumber value Passing 'null'.
    static testmethod void invoiceInvoiceNumberCheck(){
        Test.startTest();
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":null,\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    // In This Method.InvoiceDate value Passing 'null'.
    static testmethod void invoiceInvoiceDateCheck(){
        Test.startTest();
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":null,\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    // In This Method.Model value Passing 'null'.
    static testmethod void invoiceModelCheck(){
        Test.startTest();
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":null,\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    //In This Method.EngineNumber value Passing 'null'.
    static testmethod void invoiceEngineNumberCheck(){
        Test.startTest();
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":null,\"registrationNumber\":\"ksd82736ekj\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    // In This Method.RegistrationNumber value Passing 'null'.
    static testmethod void invoiceRegistrationNumber(){
        Test.startTest();
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":null}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    //In This Method.In Place of the Date field we passing the Text value to the 'InvoiceDate'.
    static testmethod void invoiceDateWrongValPass(){
        list<Invoice_Details__c> inv=[select Id from Invoice_Details__c];
        delete inv;
        Test.startTest();
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"sygsj\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    
    static testmethod void invoiceEngineNumberCheck1(){
        Test.startTest();
        
        Opportunity opp1=new Opportunity();
        opp1.name='jhon test';
        opp1.CloseDate=system.Today();
        opp1.Lead_number__c='32323';
        opp1.StageName='Qualification';
        opp1.Lead_number__c='A123456789';
        insert opp1;
        
        Invoice_Details__c inv1 =new Invoice_Details__c();
        inv1.Tax_Invoice_No__c='9283yekjd';
        inv1.Loan_Application__c=opp1.Id;
        inv1.Tax_Invoice_Date__c=date.newInstance(1996,02,03);
        insert inv1; 
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\",\"invoiceCharger\":\"912873ighaskd\",\"ihmReceiptNo\":\"912873ighaskd\",\"ihmReceiptDate\":\"1996-02-03\",\"chassisNumber\":\"912873ighas\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    
    static testmethod void invoiceEngineNumberCheck2(){
        Test.startTest();
        
        Opportunity opp1=new Opportunity();
        opp1.name='jhon test';
        opp1.CloseDate=system.Today();
        opp1.Lead_number__c='32323';
        opp1.StageName='Qualification';
        opp1.Lead_number__c='A123456789';
        insert opp1;
        
        Invoice_Details__c inv1 =new Invoice_Details__c();
        inv1.Tax_Invoice_No__c='9283yekjd';
        inv1.Loan_Application__c=opp1.Id;
        inv1.Tax_Invoice_Date__c=date.newInstance(1996,02,03);
        insert inv1; 
        
        Vehicle_Detail__c  veh =new Vehicle_Detail__c();
        veh.Loan_Application__c=opp1.Id;
        veh.Model__c = '7931iusd';
        veh.Engine_number__c='912873ighaskd';
        veh.Vehicle_Registration_number__c ='ksd82736ekj';
        insert veh;
        
        string olainvoicejson='{\"applicationNumber\":\"A123456789\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\",\"invoiceCharger\":\"912873ighaskd\",\"ihmReceiptNo\":\"912873ighaskd\",\"ihmReceiptDate\":\"1996-02-03\",\"chassisNumber\":\"912873ighas\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
    
        static testmethod void invoiceEngineNumberCheck3(){
        Test.startTest();       
        string olainvoicejson='{\"applicationNumber\":\"A123456799\",\"invoiceNumber\":\"9283yekjd\",\"invoiceDate\":\"1996-02-03\",\"model\":\"7931iusd\",\"engineNumber\":\"912873ighaskd\",\"registrationNumber\":\"ksd82736ekj\",\"invoiceCharger\":\"912873ighaskd\",\"ihmReceiptNo\":\"912873ighaskd\",\"ihmReceiptDate\":\"1996-02-03\",\"chassisNumber\":\"912873ighas\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/OlaInvoiceUpdate/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olainvoicejson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OlaInvoiceUpdateAPI.updateInvoiceDetails();
        Test.stopTest();
    }
}