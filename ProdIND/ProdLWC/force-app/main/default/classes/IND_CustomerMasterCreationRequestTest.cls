@isTest
public class IND_CustomerMasterCreationRequestTest {
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,User_Id__c='100068_SCB12123', 
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');
        insert u;
        System.runAs(u) 
        {
            //Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.LeadSource ='D2C';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }  
            
            //Create Applicant
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_Code__c = '12345';
            applicant.Gender__c = 'FEMALE';
            applicant.Marital_status__c = 'MARR';
            applicant.Customer_Qualification__c = 'B1';
            applicant.Legal_Entity_Identifier__c = 'Individual';
            applicant.Preferred_address_for_communication__c = 'Office Address';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Income_Details__c incomeDetailobj = TestDataUtility.createTestIncomeDetails(false,applicant);
            incomeDetailobj.Income__c = 23456;
            incomeDetailobj.Office_Address_Line_1__c = 'Test wertyu';
            incomeDetailobj.Office_Address_Line_2__c = 'Test wertyu';
            incomeDetailobj.Office_City__c = 'Delhi';
            incomeDetailobj.Office_District__c = 'East';
            incomeDetailobj.Office_State__c = 'Delhi';
            incomeDetailobj.Office_PinCode__c = '110090';
            insert incomeDetailobj;
            
            //Create CIBIL_Details__c
            CIBIL_Details__c cibil = new CIBIL_Details__c(CIC_No__c='12345',Applicant__c = applicant.Id,Score__c='700');
            insert cibil;

            List<Case> casList = new List<Case>();
            Case case_s = new Case();
            case_s.Origin = 'Email';
            case_s.Subject = 'disableInitiateAML';
            case_s.Loan_Application__c = opp.Id;
            case_s.Status = 'Closed';
            case_s.OwnerId = u.Id;
            case_s.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId();
            casList.add(case_s);
            Case case_s2 = new Case();
            case_s2.Origin = 'Email';
            case_s2.Subject = 'disableInitiateAML';
            case_s2.Loan_Application__c = opp.Id;
            case_s2.Status = 'Closed';
            case_s2.OwnerId = u.Id;
            casList.add(case_s2);
            Case case_s3 = new Case();
            case_s3.Origin = 'Email';
            case_s3.Subject = 'disableInitiateAML';
            case_s3.Loan_Application__c = opp.Id;
            case_s3.Status = 'Closed';
            case_s3.OwnerId = u.Id;
            casList.add(case_s3);
            Case case_s4 = new Case();
            case_s4.Origin = 'Email';
            case_s4.Subject = 'disableInitiateAML';
            case_s4.Loan_Application__c = opp.Id;
            case_s4.Status = 'Closed';
            case_s4.OwnerId = u.Id;
            casList.add(case_s4);
            Case case_s5 = new Case();
            case_s5.Origin = 'Email';
            case_s5.Subject = 'disableInitiateAML';
            case_s5.Loan_Application__c = opp.Id;
            case_s5.Status = 'Closed';
            case_s5.OwnerId = u.Id;
            casList.add(case_s5);
            insert casList;
            
            //Content Version
            ContentVersion cvn1 = new ContentVersion();
            cvn1.PathOnClient = 'testpath1';
            cvn1.Title = 'testtitle1';
            cvn1.VersionData = Blob.valueOf('Test Content');
            cvn1.Document_Side_fileupload__c = 'Front';
           // cvn1.IsLatest = true;
            insert cvn1;
            
            // Create Documents__c
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc1.Document_Type__c = System.Label.PanCards;
            doc1.is_Active__c = true;
             doc1.PAN_No__c = 'ANPK1923SD';
            doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc1.Aadhar_Source__c = 'OTP'; 
            doc1.Case__c = casList[0].Id;        
            docList.add(doc1);
            
            Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc2.Document_Type__c = System.Label.VoterIdCard;
            doc2.is_Active__c = true;
            doc2.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc2.Aadhar_Source__c = 'OTP';  
            doc2.Case__c = casList[1].Id;
            doc2.KYC_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            docList.add(doc2);
            
            Documents__c doc3 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc3.Document_Type__c = 'Form 60';
            doc3.is_Active__c = true;
            doc3.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc3.Aadhar_Source__c = 'OTP';     
            doc3.Case__c = casList[2].Id;
            docList.add(doc3);
            
            Documents__c doc4 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc4.Document_Type__c = System.Label.AadhaarCard;
            doc4.is_Active__c = true;
            doc4.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            doc4.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc4.Aadhar_Source__c = 'Scan and Upload';
            doc4.Proof_of_Address_POA__c = true;
            doc4.Case__c = casList[3].Id;
            docList.add(doc4);
            
            Documents__c doc61 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc61.Document_Type__c = System.Label.AadhaarCard;
            doc61.is_Active__c = true;
            doc61.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            doc61.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc61.Aadhar_Source__c = 'OTP';
            doc61.Proof_of_Address_POA__c = true;
            doc61.Case__c = casList[3].Id;
            docList.add(doc61);
            
            Documents__c doc62 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc62.Document_Type__c = System.Label.AadhaarCard;
            doc62.is_Active__c = true;
            doc62.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            doc62.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc62.Aadhar_Source__c = 'Scan and Upload';
            doc62.Proof_of_Address_POA__c = true;
            doc62.Proof_of_Identity_POI__c = true;
            doc62.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            docList.add(doc62);
            
            Documents__c doc12 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc12.Document_Type__c = System.Label.PanCards;
            doc12.is_Active__c = true;
            doc12.PAN_No__c = 'ANPK1923SD';
            doc12.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc12.Aadhar_Source__c = 'OTP'; 
            doc12.Gender__c = 'FEMALE';
            docList.add(doc12);
            
            
            Documents__c doc22 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc22.Document_Type__c = 'Voter Id';
            doc22.is_Active__c = true;
            doc22.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc22.Aadhar_Source__c = 'OTP';  
            doc22.Gender__c = 'FEMALE';
            doc22.KYC_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            docList.add(doc22);
            
            Documents__c doc32 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc32.Document_Type__c = 'Form 60';
            doc32.is_Active__c = true;
            doc32.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc32.Aadhar_Source__c = 'OTP';  
            doc32.Gender__c = 'MALE';
            docList.add(doc32);  
            
            Documents__c doc42 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc42.Document_Type__c = 'Aadhaar';
            doc42.is_Active__c = true;
            doc42.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            doc42.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc42.Permanent_Residential_Address_Proof__c = true;
            doc42.Aadhar_Source__c = 'Scan and Upload';
            doc42.Proof_of_Address_POA__c = true;
            docList.add(doc42);
            
            //Content Version
            ContentVersion cvn2 = new ContentVersion();
            cvn2.PathOnClient = 'testpath1';
            cvn2.Title = 'testtitle1';
            cvn2.VersionData = Blob.valueOf('Test Content');
            cvn2.Document_Side_fileupload__c = 'Front';
            cvn2.FirstPublishLocationId = doc4.Id;
            // cvn2.IsLatest = true;
            insert cvn2;
            
            Documents__c doc5 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc5.Document_Type__c = 'Passport';
            doc5.is_Active__c = true;
            doc5.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc5.Aadhar_Source__c = 'OTP'; 
            doc5.Salutation__c = 'Mr.';
            doc5.Proof_of_Identity_POI__c = true;
            doc5.Passport_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            docList.add(doc5);
            
            Documents__c doc51 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc51.Document_Type__c = System.Label.PassportCard;
            doc51.is_Active__c = true;
            doc51.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc51.Aadhar_Source__c = 'OTP'; 
            doc51.Salutation__c = '';
            doc51.Passport_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            doc51.Proof_of_Identity_POI__c = true;
            doc51.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            
            docList.add(doc51);
            
            Documents__c doc52 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc52.Document_Type__c = System.Label.PassportCard;
            doc52.is_Active__c = true;
            doc52.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc52.Aadhar_Source__c = 'OTP'; 
            doc52.Salutation__c = 'Mr.';
            doc52.Proof_of_Identity_POI__c = true;
            doc52.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            
            doc52.Case__c = casList[4].Id;
            doc52.Passport_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            docList.add(doc52);
            
            Documents__c doc53 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc53.Document_Type__c = System.Label.VoterIdCard;
            doc53.is_Active__c = true;
            doc53.Salutation__c = 'Mr.';
            doc53.Proof_of_Identity_POI__c = true;
            doc53.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            
            doc53.Case__c = casList[4].Id;
            doc53.KYC_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            docList.add(doc53);
            
            Documents__c doc531 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc531.Document_Type__c = 'Customer Image';
            doc531.is_Active__c = true;
            doc531.Aadhar_Source__c = 'OTP'; 
            doc531.Salutation__c = 'Mr.';
            doc531.KYC_Address_Line_1__c = 'Test Address';
            doc531.KYC_Address_Line_2__c = 'Test Address';
            doc531.KYC_City__c = 'Delhi';
            doc531.KYC_State__c = 'Delhi';
            doc531.KYC_Pin_Code__c = '110090';
            doc531.Permanent_Residential_Address_Proof__c = true;
            doc531.Case__c = casList[4].Id;
            docList.add(doc531);
            
            Documents__c doc54 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc54.Document_Type__c = 'Customer Image';
            doc54.is_Active__c = true;
            doc54.Aadhar_Source__c = 'OTP'; 
            doc54.Salutation__c = 'Mr.';
            doc54.KYC_Address_Line_1__c = 'Test Address';
            doc54.KYC_Address_Line_2__c = 'Test Address';
            doc54.KYC_City__c = 'Delhi';
            doc54.KYC_State__c = 'Delhi';
            doc54.KYC_Pin_Code__c = '110090';
            doc54.Current_Residential_Address_Proof__c = true;
            doc54.Case__c = casList[4].Id;
            docList.add(doc54);
            
            
            Documents__c doc6 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc6.Document_Type__c = 'Electronic Bill';
            doc6.is_Active__c = true;
            doc6.Aadhar_Source__c = 'OTP'; 
            doc6.Salutation__c = 'Mr.';
            doc6.KYC_Address_Line_1__c = 'Test Address';
            doc6.KYC_Address_Line_2__c = 'Test Address';
            doc6.KYC_City__c = 'Delhi';
            doc6.KYC_State__c = 'Delhi';
            doc6.KYC_Pin_Code__c = '110090';
            doc6.Current_Residential_Address_Proof__c = true;
            doc6.Case__c = casList[4].Id;
            docList.add(doc6);
            
            Documents__c dfks1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            dfks1.Document_Type__c = System.Label.DrivingLicences;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.is_Active__c = true;
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.KYC_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            dfks1.Case__c = casList[4].Id;
            docList.add(dfks1);

            insert docList;
            
            List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();
            
            String contentid = [select contentdocumentid from contentversion where id =: cvn1.id].ContentDocumentId;
            for(Documents__c doc : docList){
                ContentDocumentLink contentLink = new ContentDocumentLink();
                contentLink.LinkedEntityId = doc.id;
                contentLink.ContentDocumentId = contentid;
                contentLink.ShareType = 'I';
                contentLink.Visibility = 'AllUsers';
                contentLinkList.add(contentLink);
            }
            
            insert contentLinkList;
        }
    }
    
    @isTest
    public static void verifyIND_CustomerMasterCreationRequest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        //System.runAs(u) 
        //{
            try
            {
                Test.startTest();
                Applicant__c applicant = [SELECT Id, Opportunity__c,Opportunity__r.Is_Pre_Approved__c,Opportunity__r.Product_Type__c,Opportunity__r.LeadSource,
                                          Opportunity__r.Customer_Type__c,Opportunity__r.OwnerId,Opportunity__r.Lead_number__c,Opportunity__r.VKYC_status__c,
                                          Opportunity__r.VKYC_Doc_Downloaded__c ,Opportunity__r.VKYC_Doc_Urls__c,Opportunity__r.Agent_BL_code__c,
                                          Opportunity__r.Profile__c,
                                          Applicant_Type__c,Customer_Code__c, Contact_number__c, Email_Id__c,Whatsapp_number__c,Application_Consent_SMS_Sent_Time__c,
                                          Legal_Entity_Identifier__c,Is_Address_Declaration__c,
                                          applicant_number__c,Communication_language__c,Name,Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,
                                          Spouse_Name__c,Customer_Last_Name__c,Preferred_address_for_communication__c,Marital_status__c,Profile__c
                                          FROM Applicant__c LIMIT 1];                   
                
                IND_CustomerMasterCreationRequest result = new IND_CustomerMasterCreationRequest(applicant, 'test', 'test', 'test');
                Boolean isValid = result.validate(System.Label.CustomerMasterCreation);
                System.assert(isValid);
                
                IND_CustomerMasterCreationRequest.DocumentInfo df1 = new IND_CustomerMasterCreationRequest.DocumentInfo();
                df1.Document_Type = 'aadhar';
                df1.Record_Id = 'test123';
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                Test.stopTest();
            }
            catch(Exception e)
            {
                
            }
       // }
    }
    
    @isTest
    public static void verifyIND_CustomerMasterCreationRequest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Test.startTest();

                 Applicant__c applicant = [SELECT Id, Opportunity__c,Opportunity__r.Is_Pre_Approved__c,Opportunity__r.Product_Type__c,Opportunity__r.LeadSource,
                                          Opportunity__r.Customer_Type__c,Opportunity__r.OwnerId,Opportunity__r.Lead_number__c,Opportunity__r.VKYC_status__c,
                                          Opportunity__r.VKYC_Doc_Downloaded__c ,Opportunity__r.VKYC_Doc_Urls__c,Opportunity__r.Agent_BL_code__c,
                                          Opportunity__r.Profile__c,Opportunity__r.Contact_number__c,
                                          Applicant_Type__c,Customer_Code__c, Contact_number__c, Email_Id__c,Whatsapp_number__c,Application_Consent_SMS_Sent_Time__c,
                                          Legal_Entity_Identifier__c,Is_Address_Declaration__c,Gender__c,Voter_ID_No__c,
                                          applicant_number__c,Communication_language__c,Name,Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,
                                          Spouse_Name__c,Customer_Last_Name__c,Preferred_address_for_communication__c,Marital_status__c,Profile__c
                                          FROM Applicant__c LIMIT 1];  
                
                System.debug([SELECT Salutation__c,Document_Side__c,KYC_No__c,KYC_DOB__c,PAN_No__c,KYC_Name__c,KYC_Address_Line_1__c,
                                                                       KYC_Address_Line_2__c,KYC_City__c,KYC_District__c,KYC_State__c,KYC_Pin_Code__c,Current_Residential_Address_Proof__c,
                                                                       Document_Type__c, Case__c, Case__r.OwnerId, Case__r.ClosedDate, RecordType.Name,Permanent_Residential_Address_Proof__c,
                                                                       Proof_of_Address_POA__c, Proof_of_Identity_POI__c, Passport_No__c, KYC_Expiry_Date__c,CreatedById,createdDate
                                                                       FROM Documents__c WHERE Applicant__c = :applicant.Id and is_Active__c = true WITH SECURITY_ENFORCED]);
                
                IND_CustomerMasterCreationRequest result = new IND_CustomerMasterCreationRequest(applicant, 'test', 'test', 'test');
                Boolean isValid = result.validate(System.Label.CustomerMasterCreation);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                Test.stopTest();
            }
            catch(Exception e)
            {
               // System.assert(e.getMessage().contains('Customer Salutation is required'));
            }
        }
    }
    
    @isTest
    public static void verifyIND_CustomerMasterCreationRequest12(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Test.startTest();
                 Applicant__c applicant = [SELECT Id, Opportunity__c,Opportunity__r.Is_Pre_Approved__c,Opportunity__r.Product_Type__c,Opportunity__r.LeadSource,
                                          Opportunity__r.Customer_Type__c,Opportunity__r.OwnerId,Opportunity__r.Lead_number__c,Opportunity__r.VKYC_status__c,
                                          Opportunity__r.VKYC_Doc_Downloaded__c ,Opportunity__r.VKYC_Doc_Urls__c,Opportunity__r.Agent_BL_code__c,
                                          Opportunity__r.Profile__c,Opportunity__r.Contact_number__c,
                                          Applicant_Type__c,Customer_Code__c, Contact_number__c, Email_Id__c,Whatsapp_number__c,Application_Consent_SMS_Sent_Time__c,
                                          Legal_Entity_Identifier__c,Is_Address_Declaration__c,Gender__c,Voter_ID_No__c,
                                          applicant_number__c,Communication_language__c,Name,Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,
                                          Spouse_Name__c,Customer_Last_Name__c,Preferred_address_for_communication__c,Marital_status__c,Profile__c
                                          FROM Applicant__c LIMIT 1];  

                
                System.debug([SELECT Salutation__c,Document_Side__c,KYC_No__c,KYC_DOB__c,PAN_No__c,KYC_Name__c,KYC_Address_Line_1__c,
                                                                       KYC_Address_Line_2__c,KYC_City__c,KYC_District__c,KYC_State__c,KYC_Pin_Code__c,Current_Residential_Address_Proof__c,
                                                                       Document_Type__c, Case__c, Case__r.OwnerId, Case__r.ClosedDate, RecordType.Name,Permanent_Residential_Address_Proof__c,
                                                                       Proof_of_Address_POA__c, Proof_of_Identity_POI__c, Passport_No__c, KYC_Expiry_Date__c,CreatedById,createdDate
                                                                       FROM Documents__c WHERE Applicant__c = :applicant.Id and is_Active__c = true WITH SECURITY_ENFORCED]);
                
                IND_CustomerMasterCreationRequest result = new IND_CustomerMasterCreationRequest(applicant, 'test', 'test', 'test');
                Boolean isValid = result.validate(System.Label.CustomerMasterCreation);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                Test.stopTest();
            }
            catch(Exception e)
            {
               // System.assert(e.getMessage().contains('Customer Salutation is required'));
            }
        }
    }
    
  /*  @isTest
    public static void testreq3(){
        
         Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
           
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',
					TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
					UserName='standarduser4@testorg1.com.psdev1');
            insert u;
        
        system.runAs(u){
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.OwnerId = userInfo.getUserId();
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                insert apga1;
        
             /*   case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 cs3.OwnerId = UserInfo.getUserId();
                // cs3.ClosedDate = datetime.newInstance(2014, 9, 15, 12, 30, 0);
                 insert cs3; 
        
                Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apga1.Id;
                 dfks1.Opportunity_Relation__c = opga1.Id;
              //   dfks1.Case__c = cs3.Id;
                 dfks1.Document_Type__c = 'PAN';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'PAN';
                 insert dfks1;
        
                  Test.startTest();
                       IND_CustomerMasterCreationRequest cr1 = new IND_CustomerMasterCreationRequest(apga1,'1','1','nlr');
                  Test.stopTest();
    }
  }   */
    
     @isTest
    public static void verifyIND_CustomerMasterCreationRequest1ElseCases(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Opportunity opp = [SELECT id,VKYC_status__c,VKYC_Doc_Downloaded__c,VKYC_Doc_Urls__c from Opportunity LIMIT 1];
                opp.VKYC_status__c = 'NA';
                opp.VKYC_Doc_Downloaded__c = true;
                opp.VKYC_Doc_Urls__c  = 'testurl';
                
                update opp;
                
                Test.startTest();
                Applicant__c applicant = [SELECT Id, Opportunity__c,Opportunity__r.Is_Pre_Approved__c,Opportunity__r.Product_Type__c,Opportunity__r.LeadSource,
                                          Opportunity__r.Customer_Type__c,Opportunity__r.OwnerId,Opportunity__r.Lead_number__c,Opportunity__r.VKYC_status__c,
                                          Opportunity__r.VKYC_Doc_Downloaded__c ,Opportunity__r.VKYC_Doc_Urls__c,Opportunity__r.Agent_BL_code__c,
                                          Opportunity__r.Profile__c,
                                          Applicant_Type__c,Customer_Code__c, Contact_number__c, Email_Id__c,Whatsapp_number__c,Application_Consent_SMS_Sent_Time__c,
                                          Legal_Entity_Identifier__c,Is_Address_Declaration__c,
                                          applicant_number__c,Communication_language__c,Name,Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,
                                          Spouse_Name__c,Customer_Last_Name__c,Preferred_address_for_communication__c,Marital_status__c,Profile__c
                                          FROM Applicant__c LIMIT 1];  
                
                applicant.Is_Address_Declaration__c = true;
                applicant.Preferred_address_for_communication__c = 'Permanent Address';
                update applicant;
                
                IND_CustomerMasterCreationRequest result = new IND_CustomerMasterCreationRequest(applicant, 'test', 'test', 'test');
                Boolean isValid = result.validate(System.Label.CustomerMasterCreation);
                System.assert(isValid);
                
                //Updating opp stage to generate opphistory record
                opp.StageName  =  'Asset Details';
                update opp;
                
                //requery to fetch latest opp data
                Applicant__c applicant2 = [SELECT Id, Opportunity__c,Opportunity__r.Is_Pre_Approved__c,Opportunity__r.Product_Type__c,Opportunity__r.LeadSource,
                                           Opportunity__r.Customer_Type__c,Opportunity__r.OwnerId,Opportunity__r.Lead_number__c,Opportunity__r.VKYC_status__c,
                                           Opportunity__r.VKYC_Doc_Downloaded__c ,Opportunity__r.VKYC_Doc_Urls__c,Opportunity__r.Agent_BL_code__c,
                                           Opportunity__r.Profile__c,
                                           Applicant_Type__c,Customer_Code__c, Contact_number__c, Email_Id__c,Whatsapp_number__c,Application_Consent_SMS_Sent_Time__c,
                                           Legal_Entity_Identifier__c,Is_Address_Declaration__c,
                                           applicant_number__c,Communication_language__c,Name,Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,
                                           Spouse_Name__c,Customer_Last_Name__c,Preferred_address_for_communication__c,Marital_status__c,Profile__c
                                           FROM Applicant__c LIMIT 1];  
                
                IND_CustomerMasterCreationRequest result2 = new IND_CustomerMasterCreationRequest(applicant2, 'test', 'test', 'test');

                
                IND_CustomerMasterCreationRequest.DocumentInfo df1 = new IND_CustomerMasterCreationRequest.DocumentInfo();
                df1.Document_Type = 'aadhar';
                df1.Record_Id = 'test123';
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                Test.stopTest();
            }
            catch(Exception e)
            {
                
            }
        }
    }
}