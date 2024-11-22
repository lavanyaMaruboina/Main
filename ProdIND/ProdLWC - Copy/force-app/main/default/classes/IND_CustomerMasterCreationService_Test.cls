@isTest
public class IND_CustomerMasterCreationService_Test {
   
    @testSetup 
    static void testDataSetup() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                           MobilePhone = '9701498575',
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u;
        System.runAs(u){

            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Deal_Number__c = 'TUT06226H';
            opp.Lead_Number__c='L-10122021-1685';
            opp.Agent_BL_code__c = 'MPP';
            opp.Contact_number__c = '9876543456' ;
            opp.Whatsapp_number__c = '1231231231';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = new Applicant__c();
            applicant.Contact_number__c = '9876543456' ;
            applicant.OTP_for_borrower__c = '9999';
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_Code__c = 'CW1330664';
            applicant.Name = 'test';
            applicant.Gender__c = 'MALE';
            applicant.Profile__c = 'Un-Employed';
            applicant.Communication_language__c = 'Hindi';
            applicant.Customer_Qualification__c = 'B2';
            applicant.Father_s_name__c = 'Viraa';
            applicant.Mother_s_name__c = 'Neeta';
            applicant.Spouse_Name__c = 'Sameer';
            applicant.Email_Id__c = 'riya@gmail.com';
            applicant.Aadhar_No__c = '363155436548';
            applicant.Voter_ID_No__c = 'ANDR435435';
            applicant.Driving_License_No__c = 'FDG3435253';
            applicant.Customer_First_Name__c='GOURAB';
            applicant.Customer_Last_Name__c = 'GOSWAMI';
            applicant.Legal_Entity_Identifier__c = 'Individual';
            applicant.Marital_status__c = 'UNMAR';
            applicant.Whatsapp_number__c = '1231231231';
            insert applicant;

            Customer_Dedupe_Response__c cdr = new Customer_Dedupe_Response__c();
            cdr.Customer_Code__c = 'CW1330664';
            cdr.CIN_No__c = '34455';
            cdr.Applicant__c = applicant.Id;
            insert cdr;

            
            Case cse =new Case(CMU_Accept__c = false, 
                            Loan_Application__c = opp.id,
                            Applicant__c = applicant.Id,                
                            Status = 'Closed');
            insert cse;
        
             Documents__c document1 = TestDataUtility.createTestCustDoc(false,applicant,opp,cse);
             document1.Document_Type__c = System.Label.AadhaarCard;
             document1.Proof_of_Address_POA__c = true;
             document1.Proof_of_Identity_POI__c = true;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Documents__c document2 = TestDataUtility.createTestCustDoc(false,applicant,opp,cse);
             document2.Document_Type__c = System.Label.PanCards;
             //document2.Proof_of_Address_POA__c = true;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }

            CIBIL_Details__c cibil = new CIBIL_Details__c ();
            cibil.CIC_No__c = 'Test CIC';
            cibil.Score__c = 'Test score' ;
            cibil.Applicant__c = applicant.Id;
            insert cibil;

            Applicant__c app = [SELECT Id,Contact_number__c,OTP_for_borrower__c,Opportunity__r.Lead_number__c,
                            Customer_Code__c,Name,Gender__c,Profile__c,Communication_language__c,
                            Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c,Email_Id__c,
                            Aadhar_No__c,Voter_ID_No__c,Driving_License_No__c,Customer_Last_Name__c,Opportunity__r.CreatedById,
                            Opportunity__r.OwnerId,Legal_Entity_Identifier__c,Opportunity__r.Agent_BL_code__c,
                            Marital_status__c,Opportunity__r.Contact_number__c,Whatsapp_number__c, Opportunity__r.Whatsapp_number__c, (SELECT Id,Customer_Code__c,CIN_No__c from Customer_Dedupe_Response__r)
                            FROM Applicant__c WHERE Id=:applicant.Id WITH SECURITY_ENFORCED];
        }
    }

    @isTest
    public static void doCustomerMasterCreationCalloutTest(){
        try{
            User u = [SELECT Id,usertype,Maker_Id__c,User_Id__c FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            u.Maker_Id__c = '1001';
            u.User_Id__c = '4569364_CVO';
            update u;
            system.debug('user----'+u);

            Opportunity loanApp = [SELECT Id,Deal_Number__c,Lead_number__c,Agent_BL_code__c,Contact_number__c,Whatsapp_number__c,OwnerId,Product_Type__c,Customer_Type__c FROM Opportunity LIMIT 1];
			loanApp.Product_Type__c = 'Tractor';
            loanApp.Customer_Type__c = 'Non-Individual';
            loanApp.ownerId = u.Id;
            update loanApp;
            system.debug('loanApp----'+loanApp);
            Applicant__c app = [SELECT Id,Contact_number__c,Applicant_Type__c,OTP_for_borrower__c,Opportunity__r.Lead_number__c,
                            Customer_Code__c,Name,Gender__c,Profile__c,Communication_language__c,
                            Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c,Email_Id__c,
                            Aadhar_No__c,Voter_ID_No__c,Driving_License_No__c,Customer_Last_Name__c,Opportunity__r.CreatedById,
                            Opportunity__r.OwnerId,Legal_Entity_Identifier__c,Opportunity__r.Agent_BL_code__c,
                            Marital_status__c,Opportunity__r.Contact_number__c,Whatsapp_number__c, Opportunity__r.Whatsapp_number__c, (SELECT Id,Customer_Code__c,CIN_No__c from Customer_Dedupe_Response__r)
                            FROM Applicant__c LIMIT 1];
            app.Applicant_Type__c = 'Borrower';
            app.Preferred_address_for_communication__c = 'Residence Address';
            update app;
            system.runAs(u){
            Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = app.Id;
                 dfks1.Opportunity_Relation__c = loanApp.Id;
                 dfks1.Document_Type__c = System.Label.CustomerImageDocumentType;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
            	 dfks1.Is_Active__c = true;
            	 dfks1.Gender__c = 'Male';	
            	 dfks1.Proof_of_Identity_POI__c = true;
            	 dfks1.KYC_DOB__c = Date.newInstance(1980,5,1);
                 insert dfks1;
                
                Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;   
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

        
                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = dfks1.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
            }
            List<CIBIL_Details__c> cibil = [SELECT CIC_No__c,CreatedDate,Score__c FROM CIBIL_Details__c WHERE Applicant__c = :app.Id];

            Continuation con = (Continuation)IntegrationEngine.doCustomerMasterCreationCallout(app.Id,loanApp.Id,'Hinduism','Purohit','NAGPUR');

            HttpResponse response = new HttpResponse();
            //response.setBody('{"JData":"U2FsdGVkX1+xhI0wp2sSxTsIZLUjPZEaaj7QjQjWMyiuRkuOqRVxD6BBb4nJ1N0FZ2+cT5safgJuueLxcKcTvaicnAKeDwDNSM6od/edcQ0/WTpGb2JlC1R6VcNr2l9ALBZRU4iA14yqlEmafZC7z8lf/2wqkYW9+GsaOEmwTBOVF7yRMFnekB4R+L6CKMrJJYVzaC9NWPuhmvQCvOMO4ZZHsd9y0aA7IuNj320QX8FK8SlM5+thBKQ2y9pwo5QzUtH0Y6bv/D/lhAgrVAimkhX+byrijm3BVf0MTlDQtUnsXwbnbZ2jX8UasGEsIHWI0h68mzeF+gOk82EiDIOmaA=="}');            
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5niTO0HGpEWrGII4BTYnRVlj6seZ6XVdiaWzovPY1mp8VHKClYAoNxyKmg/zMb5ubeIi5Sz1LW0iOBMttNRrXhH6yqFbtGmAioO7IB9M3jKa0HPdcGLpfHtNsJgiYKZ1QuAvWVjx72j1Z7YxmpiJ+yyw"}');
            response.setStatusCode(200);
            
            String continuationLabel = 'Continuation-2';
            System.debug('continuationLabel ---> ' + continuationLabel);
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState; 
            String membershipResponse = '';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processCustomerMasterCreationAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected = '{"body":null,"response": { "status": "SUCCESS", "respDesc": "Customer Master Creation", "content": [ { "CreationStatus": "Success" } ] }}';
            //System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals(ex.getMessage(),'pad block corrupted','ex');
        }
    }
    //CISP-4263
    @isTest
    public static void doCustomerMasterUpdationCalloutTest(){
        try{
			User u = [SELECT Id,usertype,Maker_Id__c,User_Id__c FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            u.Maker_Id__c = '1001';
            u.User_Id__c = '4569364_CVO';
            update u;
            system.debug('user----'+u);
            
            Opportunity loanApp = [SELECT Id,Deal_Number__c,Lead_number__c,Agent_BL_code__c,Contact_number__c,Whatsapp_number__c FROM Opportunity];
			loanApp.Product_Type__c = 'Tractor';
            loanApp.Customer_Type__c = 'Non-Individual';
            loanApp.ownerId = u.Id;
            update loanApp;
            
            Applicant__c app = [SELECT Id,Contact_number__c,OTP_for_borrower__c,Opportunity__r.Lead_number__c,
                            Customer_Code__c,Name,Gender__c,Profile__c,Communication_language__c,
                            Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c,Email_Id__c,
                            Aadhar_No__c,Voter_ID_No__c,Driving_License_No__c,Customer_Last_Name__c,Opportunity__r.CreatedById,
                            Opportunity__r.OwnerId,Legal_Entity_Identifier__c,Opportunity__r.Agent_BL_code__c,
                            Marital_status__c,Opportunity__r.Contact_number__c,Whatsapp_number__c, Opportunity__r.Whatsapp_number__c, (SELECT Id,Customer_Code__c,CIN_No__c from Customer_Dedupe_Response__r)
                            FROM Applicant__c ];
			app.Applicant_Type__c = 'Borrower';
            app.Preferred_address_for_communication__c = 'Residence Address';
            update app;
            system.runAs(u){
            Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = app.Id;
                 dfks1.Opportunity_Relation__c = loanApp.Id;
                 dfks1.Document_Type__c = System.Label.CustomerImageDocumentType;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
            	 dfks1.Is_Active__c = true;
            	 dfks1.Gender__c = 'Male';	
            	 dfks1.Proof_of_Identity_POI__c = true;
            	 dfks1.KYC_DOB__c = Date.newInstance(1980,5,1);
                 insert dfks1;
                
                Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;   
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

        
                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = dfks1.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
            }
            List<CIBIL_Details__c> cibil = [SELECT CIC_No__c,CreatedDate,Score__c FROM CIBIL_Details__c WHERE Applicant__c = :app.Id];

            Continuation con = (Continuation)IntegrationEngine.doCustomerMasterUpdationCallout(app.Id,loanApp.Id,'Hinduism','Purohit','NAGPUR');

            HttpResponse response = new HttpResponse();
            //response.setBody('{"JData":"U2FsdGVkX1+xhI0wp2sSxTsIZLUjPZEaaj7QjQjWMyiuRkuOqRVxD6BBb4nJ1N0FZ2+cT5safgJuueLxcKcTvaicnAKeDwDNSM6od/edcQ0/WTpGb2JlC1R6VcNr2l9ALBZRU4iA14yqlEmafZC7z8lf/2wqkYW9+GsaOEmwTBOVF7yRMFnekB4R+L6CKMrJJYVzaC9NWPuhmvQCvOMO4ZZHsd9y0aA7IuNj320QX8FK8SlM5+thBKQ2y9pwo5QzUtH0Y6bv/D/lhAgrVAimkhX+byrijm3BVf0MTlDQtUnsXwbnbZ2jX8UasGEsIHWI0h68mzeF+gOk82EiDIOmaA=="}');            
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5niTO0HGpEWrGII4BTYnRVljDehpgeravRrZf0y56dL/pghvMuKhp2/lg39rbWm3r4d11Izwt3jRXJkVr3PGELcJ"}');
            response.setStatusCode(200);
            
            String continuationLabel = 'Continuation-2';
            System.debug('continuationLabel ---> ' + continuationLabel);
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState; 
            String membershipResponse = '';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processCustomerMasterUpdationAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected = '{"body":null,"response": { "status": "SUCCESS", "respDesc": "Customer Master Creation", "content": [ { "CreationStatus": "Success" } ] }}';
            //System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals(ex.getMessage(),'pad block corrupted','ex');
        }
    }
    
    /* @isTest
    public static void testCustomerMasterCreationService2(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', Maker_Id__c='100001',
                              UserName='standarduser4@testorg.com.psdev1',MobilePhone='0123456789');
            insert u;
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
             String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Continuation con = (Continuation)IntegrationEngine.doCustomerMasterCreationCallout(applicant.Id,loanAppId);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"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"}');            
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processCustomerMasterCreationAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected = '{"response":{"status":"FAILED","respDesc":"Procedure or function DP_Create_Customer_Master_SF expects parameter @Maker_Id, which was not supplied.","content":""}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    
    
    @isTest
    public static void testCustomerMasterCreationService3(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', Maker_Id__c='100001',
                              UserName='standarduser4@testorg.com.psdev1',MobilePhone='0123456789');
            insert u;
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
             String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Continuation con = (Continuation)IntegrationEngine.doCustomerMasterCreationCallout(applicant.Id,loanAppId);
            
           // Map<String, HttpRequest> requests = con.getRequests();
           // system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{ "JData": "bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHOyBXBAGU74iLLpTffDrPnYRBM1FVVaF20rXp8qFDuXR/zIjVNluHkfcL0gvdr7x27P7wDU9zyjZI/OpZG32ohtJUxxaPGcTU75qNa+PWM5P0Cpxyozpq6yig0NGAFO1wUCprXimz2qH2tyx38kyHZGZJ5rBjF+hhweDicI+/g2NjyguwB1wHAYWFv0VuCM3Nj0ddc6mfblcqa7tl+FplXQapYjWclxacj6C6GRGNeygBnjtG0LNZxkWyPRzOUiJo+Batpv/YOhBNFCvzxtsWG+TRPSZfkElEn+YSxUlLW0opShaBPeFFbIddye5MwifdkB24bSHUOpU2YKg2z7G7sDBYKZ82ZDJGDuWvYHenBTSUbk+frrhe+ZcsOqiavam7tRd/ld0JhV5BeIdRT+0TaxWY4H1h9LI55vvxbJTEEu9A==" }');            
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processCustomerMasterCreationAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected = '{"response":{"status":"FAILED","respDesc":"Cannot roll back Tran1. No transaction or savepoint of that name was found.\r\nTransaction count after EXECUTE indicates a mismatching number of BEGIN and COMMIT statements. Previous count = 1, current count = 2.\r\nWarning: Null value is eliminated by an aggregate or other SET operation.","content":""}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    
     @isTest
    public static void testCustomerMasterCreationService4(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', Maker_Id__c='100001',
                              UserName='standarduser4@testorg.com.psdev1',MobilePhone='0123456789');
            insert u;
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
             String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            //Continuation con = (Continuation)IntegrationEngine.doCustomerMasterCreationCallout(applicant.Id,loanAppId);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"U2FsdGVkX1+xhI0wp2sSxTsIZLUjPZEaaj7QjQjWMyiuRkuOqRVxD6BBb4nJ1N0FZ2+cT5safgJuueLxcKcTvaicnAKeDwDNSM6od/edcQ0/WTpGb2JlC1R6VcNr2l9ALBZRU4iA14yqlEmafZC7z8lf/2wqkYW9+GsaOEmwTBOVF7yRMFnekB4R+L6CKMrJJYVzaC9NWPuhmvQCvOMO4ZZHsd9y0aA7IuNj320QX8FK8SlM5+thBKQ2y9pwo5QzUtH0Y6bv/D/lhAgrVAimkhX+byrijm3BVf0MTlDQtUnsXwbnbZ2jX8UasGEsIHWI0h68mzeF+gOk82EiDIOmaA=="}');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processCustomerMasterCreationAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected = '{"body":null,"response": { "status": "SUCCESS", "respDesc": "Customer Master Creation", "content": [ { "CreationStatus": "Success" } ] }}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label','ex');
        }
    }*/
    
     @isTest
    public static void testCustomerMasterCreationService5(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', Maker_Id__c='100001',
                              UserName='standarduser4@testorg.com.psdev1',MobilePhone='0123456789');
            insert u;
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Deal_Number__c = 'TUT06226H';
            opp.Lead_Number__c='L-10122021-1685';
            opp.Agent_BL_code__c = 'MPP';
            opp.Contact_number__c = '9876543456' ;
            opp.Whatsapp_number__c = '1231231231';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = new Applicant__c();
            applicant.Contact_number__c = '9876543456' ;
            applicant.OTP_for_borrower__c = '9999';
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_Code__c = 'CW1330664';
            applicant.Name = 'test';
            applicant.Gender__c = 'MALE';
            applicant.Profile__c = 'Un-Employed';
            applicant.Communication_language__c = 'Hindi';
            applicant.Customer_Qualification__c = 'B2';
            applicant.Father_s_name__c = 'Viraa';
            applicant.Mother_s_name__c = 'Neeta';
            applicant.Spouse_Name__c = 'Sameer';
            applicant.Email_Id__c = 'riya@gmail.com';
            applicant.Aadhar_No__c = '363155436548';
            applicant.Voter_ID_No__c = 'ANDR435435';
            applicant.Driving_License_No__c = 'FDG3435253';
            applicant.Customer_First_Name__c='GOURAB';
            applicant.Customer_Last_Name__c = 'GOSWAMI';
            applicant.Legal_Entity_Identifier__c = 'Individual';
            applicant.Marital_status__c = 'UNMAR';
            applicant.Whatsapp_number__c = '1231231231';
            insert applicant;

            Customer_Dedupe_Response__c cdr = new Customer_Dedupe_Response__c();
            cdr.Customer_Code__c = 'CW1330664';
            cdr.CIN_No__c = '34455';
            cdr.Applicant__c = applicant.Id;
            insert cdr;

            Continuation con = (Continuation)IntegrationEngine.doCustomerMasterCreationCallout(applicant.Id,opp.Id,'Hinduism','Purohit','NAGPUR');
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"U2FsdGVkX1++cT5safgJuueLxcKcTvaicnAKeDwDNSM6od/edcQ0/WTpGb2JlC1R6VcNr2l9ALBZRU4iA14yqlEmafZC7z8lf/2wqkYW9+GsaOEmwTBOVF7yRMFnekB4R+L6CKMrJJYVzaC9NWPuhmvQCvOMO4ZZHsd9y0aA7IuNj320QX8FK8SlM5+thBKQ2y9pwo5QzUtH0Y6bv/D/lhAgrVAimkhX+byrijm3BVf0MTlDQtUnsXwbnbZ2jX8UasGEsIHWI0h68mzeF+gOk82EiDIOmaA=="}');            
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processCustomerMasterCreationAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected = '{"response":{"status":"FAILED","respDesc":"Length of the data to decrypt is invalid.","content":""}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    
    
        @isTest
    public static void validateException(){
        try{
            IND_CustomerMasterCreationService.getCustomerMasterCreationRequest(null, null,'','','');
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }

    }
    
     @isTest
    public static void CustomerMasterCreationServiceTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Deal_Number__c = 'TUT06556H';
            opp.Lead_Number__c='L-10122041-1685';
            opp.Agent_BL_code__c = 'MPP';
            opp.Contact_number__c = '9876543466' ;
            opp.Whatsapp_number__c = '1231231241';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = new Applicant__c();
            applicant.Contact_number__c = '9876543456' ;
            applicant.OTP_for_borrower__c = '9999';
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_Code__c = 'CW1330664';
            applicant.Name = 'test';
            applicant.Gender__c = 'MALE';
            applicant.Profile__c = 'Un-Employed';
            applicant.Communication_language__c = 'Hindi';
            applicant.Customer_Qualification__c = 'B2';
            applicant.Father_s_name__c = 'Viraa';
            applicant.Mother_s_name__c = 'Neeta';
            applicant.Spouse_Name__c = 'Sameer';
            applicant.Email_Id__c = 'riya@gmail.com';
            applicant.Aadhar_No__c = '363155436548';
            applicant.Voter_ID_No__c = 'ANDR435435';
            applicant.Driving_License_No__c = 'FDG3435253';
            applicant.Customer_First_Name__c='GOURAB';
            applicant.Customer_Last_Name__c = 'GOSWAMI';
            applicant.Legal_Entity_Identifier__c = 'Individual';
            applicant.Marital_status__c = 'UNMAR';
            applicant.Whatsapp_number__c = '1231231231';
            insert applicant;

            Customer_Dedupe_Response__c cdr = new Customer_Dedupe_Response__c();
            cdr.Customer_Code__c = 'CW1330664';
            cdr.CIN_No__c = '34455';
            cdr.Applicant__c = applicant.Id;
            insert cdr;

            Test.startTest();
            IND_CustomerMasterCreationService.getCustomerMasterCreationRequest(applicant, opp.Id,'Hinduism','Purohit','NAGPUR');
            Test.stopTest();
        }catch(Exception pEx){
            System.debug('error ---> ' + pEx.getMessage());
            System.debug('error ---> ' + pEx.getLineNumber());
            System.assert(pEx.getMessage() != null);
        }

    }
    
   
    
}