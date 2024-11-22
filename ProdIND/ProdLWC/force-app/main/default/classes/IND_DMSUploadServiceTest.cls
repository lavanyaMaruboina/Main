/*------------------------------------------------------------
Author:        Yugandhar
Company:       Persistent Systems
Description:   Test class created to validate the IND_DMSUploadRequest IND_DMSUploadService IND_DMSUploadResponse class
History
Date            Author              Comments
-------------------------------------------------------------
30-12-2021      Yugandhar       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_DMSUploadServiceTest {    
    @testSetup
    static void testDataSetup(){
        //create user        
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];     
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1_userprod123@indusbank.com');
        insert u;
        System.runAs(u) 
        {         
            // Create Opportunity
            Opportunity opp1 = TestDataUtility.createTestLoanApplication(false);
            opp1.Product_Type__c = 'Tractor';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp1;
            }
            // Create Opportunity
            Opportunity opp2 = TestDataUtility.createTestLoanApplication(false);
            opp2.Product_Type__c = 'Two wheeler';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp2;
            }
            
            // Create Applicant
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp1.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'Payment Request';
            insert dl;
            system.debug('Deal Number==> '+dl);
            
          
            //Create vehicle 
            Vehicle_Detail__c vehicle  = TestDataUtility.createTestVehicleDetailForIbb(false,opp1);
            vehicle.Deal_Number__c = dl.Id;
            insert vehicle;
            
            
            // Create Document
            Documents__c doc = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp1);
            doc.Document_Type__c = 'RC Document';
            doc.Vehicle_Detail__c = vehicle.Id;
            doc.Document_Side__c = 'Front';
            doc.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc.Is_Active__c = true;
            doc.Name = 'RC Document';
            doc.Aadhar_Source__c = 'OTP';
            doc.Opportunity_Relation__c = opp1.Id;
            insert doc;
            
            //Create Content Version
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cd = new ContentDocumentLink();
            cd.LinkedEntityId = doc.Id;
            cd.ContentDocumentId = documents[0].Id;
            cd.ShareType = 'V';
            cd.Visibility = 'AllUsers';
            insert cd;
            
           
            
        }
    }
    
    
    
    @isTest
    public static void testIND_DMSUploadService()
    {        
        try{               
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                        
            
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1]; 
            String loanAppId = applicant.Opportunity__c;
            list<Documents__c> docList = [Select Id,Opportunity_Relation__r.name,Document_Type__c,Document_Side__c from Documents__c where Opportunity_Relation__c = :loanAppId and is_Active__c = true];
            System.debug('docList in test class ---> ' + docList);
            Deal_Number__c dn = [Select Id from Deal_Number__c LIMIT 1];
            Continuation con = (Continuation)IntegrationEngine.doDMSUploadCallout(loanAppId,'RC Document',dn.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ninabMN1U/RWDGxHX+ESJ7oryk6Un21cZCVD//ao/FoA1khA3l8GRQHysCn+GzvygTrD2XhB+GnaAJzsVElNY7D"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            String dmsUploadCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
                dmsUploadCallOutResponse = (String)IntegrationEngine.processDMSCalloutAPIResponse(labels, IntegrationEngine.continuationState);
            }            
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Document Upload","content":["237418461"]}}';
            System.assertEquals(responseExpected, dmsUploadCallOutResponse);
            
        } catch(Exception ex){
            //System.assert(ex.getMessage().contains('RC Document is not uploaded'));
        }
    }
     @isTest
    public static void testIND_DMSUploadService1()
    {        
        try{               
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                        
            
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1]; 
            String loanAppId = applicant.Opportunity__c;
            list<Documents__c> docList = [Select Id,Opportunity_Relation__r.name,Document_Type__c,Document_Side__c from Documents__c where Opportunity_Relation__c = :loanAppId and is_Active__c = true];
            System.debug('docList in test class ---> ' + docList);
            Deal_Number__c dn = [Select Id from Deal_Number__c LIMIT 1];
            Continuation con = (Continuation)IntegrationEngine.doDMSUploadCallout(loanAppId,'RC Document',dn.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ninabMN1U/RWDGxHX+ESJ7oryk6Un21cZCVD//ao/FoA1khA3l8GRQHysCn+GzvygTrD2XhB+GnaAJzsVElNY7D"}');
            response.setStatusCode(250);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            String dmsUploadCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
                dmsUploadCallOutResponse = (String)IntegrationEngine.processDMSCalloutAPIResponse(labels, IntegrationEngine.continuationState);
            }            
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Document Upload","content":["237418461"]}}';
            //System.assertEquals(responseExpected, dmsUploadCallOutResponse);
            
        } catch(Exception ex){
            //System.assert(ex.getMessage().contains('RC Document is not uploaded'));
        }
    }
    
    @isTest
    public static void testIND_DMSUploadService2()
    {        
        try{               
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                        
            
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1]; 
            
            String loanAppId = applicant.Opportunity__c;
                        Deal_Number__c dn = [Select Id from Deal_Number__c LIMIT 1];
            Continuation con = (Continuation)IntegrationEngine.doDMSUploadCallout(loanAppId,'RC Document',dn.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"JEEek/uTJUwb1sXkbveegjEkRDq8jyAVePfxxx/AtR3YIib4aBBlx+w6EeKKpzQm"}');
            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            String dmsUploadCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
                dmsUploadCallOutResponse = (String)IntegrationEngine.processDMSCalloutAPIResponse(labels, IntegrationEngine.continuationState);
            }
            Test.stopTest();
            String responseExpected ='{"body":null,"response":null}';
            System.assertEquals(responseExpected, dmsUploadCallOutResponse);
            
        } catch(Exception ex){
            //System.assert(ex.getMessage().contains('RC Document is not uploaded'));
        }
    }    
    
    @isTest
    public static void testIND_DMSUploadResponseTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                        
        Test.startTest();
        System.runAs(u)
        {
            IND_DMSUploadResponse dmsResponse = new IND_DMSUploadResponse();
            IND_DMSUploadResponse.ResponseData response = new IND_DMSUploadResponse.ResponseData();
            response.status = '200';
            response.respDesc = 'Test';
            response.content = new List<String>{'Test'};
                dmsResponse.response = response;
            System.assertEquals(dmsResponse.response.status, '200');
        }
        Test.stopTest();
    }   
    
    @isTest
    public static void validateException1(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];  
            Opportunity opp = [SELECT id, name FROM opportunity where Product_Type__c = 'Two Wheeler'  LIMIT 1];
            Deal_Number__c dl = [Select Id from Deal_Number__c limit 1];
            Documents__c doc = [Select Id,Document_Type__c from Documents__c limit 1];
            
            System.runAs(u)
            {
                IND_DMSUploadRequest result = IND_DMSUploadService.getDMSUploadRequest(opp.Id, doc.Document_Type__c,dl.Id);
                System.assertNotEquals(null, result);
            }
        }catch(Exception pEx){
            System.debug(pEx.getMessage());
        }
        
    } 
    
    @isTest
    public static void validateException(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];  
            Opportunity opp = [SELECT id, name FROM opportunity where Product_Type__c = 'Tractor' LIMIT 1];
            Deal_Number__c dl = [Select Id from Deal_Number__c limit 1];
            Documents__c doc = [Select Id,Document_Type__c from Documents__c limit 1];
            
            System.runAs(u)
            {
                IND_DMSUploadRequest result = IND_DMSUploadService.getDMSUploadRequest(opp.Id, doc.Document_Type__c,dl.Id);
                System.assertNotEquals(null, result);
            }
        }catch(Exception pEx){
            System.debug(pEx.getMessage());
        }
        
    }    
}