@isTest
public class IND_CrosscoreRequestTest {
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
            opp.Customer_Type__c = 'Individual';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            } 
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opp.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Beneficiary';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'T-authTest';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            //Create Applicant
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_Code__c = '12345';
            applicant.Gender__c = 'FEMALE';
            applicant.In_Active_Applicant__c = false;
            applicant.Applicant_Type__c = 'Borrower';
            applicant.Marital_status__c = 'MARR';
            applicant.Customer_Qualification__c = 'B1';
            applicant.Legal_Entity_Identifier__c = 'Individual';
            applicant.Preferred_address_for_communication__c = 'Office Address';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }

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
            doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc1.Aadhar_Source__c = 'OTP'; 
            doc1.Case__c = casList[0].Id; 
            doc1.PAN_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            doc1.Gender__c = 'FEMALE';
            doc1.KYC_DOB__c = Date.newInstance(2022, 06, 16);
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
            doc12.PAN_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
            doc12.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc12.Aadhar_Source__c = 'OTP'; 
            doc12.Gender__c = 'FEMALE';
            doc12.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            docList.add(doc12);
            
            
            Documents__c doc22 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc22.Document_Type__c = System.Label.VoterIdCard;
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
            doc42.Document_Type__c = System.Label.AadhaarCard;
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
            doc5.Document_Type__c = System.Label.PassportCard;
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
            dfks1.Case__c = casList[3].Id;
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
    public static void verifyIND_IND_CrosscoreRequest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opks1 = [Select id From Opportunity limit 1];
            List<Applicant__c> apks1 = [SELECT Id FROM Applicant__c WHERE Applicant_Type__c = 'Beneficiary'];
            
            List<String> beneficiaryIds = new List<String>();
            beneficiaryIds.add(apks1[0].Id);

            try
            {
                Test.startTest(); 
                IND_CrosscoreRequest result = new IND_CrosscoreRequest(opks1.Id, beneficiaryIds, 'test');
                Boolean isValid = result.validate(System.Label.Crosscore);
                System.assert(isValid);
                Test.stopTest();
            }
            catch(Exception e)
            {
                  System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
   	@isTest
    public static void verifyIND_IND_CrosscoreRequestNonIndividualOppTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opks1 = [Select id,Customer_Type__c From Opportunity limit 1];
            List<Applicant__c> apks1 = [SELECT Id FROM Applicant__c WHERE Applicant_Type__c = 'Beneficiary'];
            
            opks1.Customer_Type__c = 'Non-Individual';
            update opks1; 
            List<String> beneficiaryIds = new List<String>();
            beneficiaryIds.add(apks1[0].Id);
            
            try
            {
                Test.startTest(); 
                IND_CrosscoreRequest result = new IND_CrosscoreRequest(opks1.Id, beneficiaryIds, 'test');
                Boolean isValid = result.validate(System.Label.Crosscore );
                System.assert(isValid);
                Test.stopTest();
            }
            catch(Exception e)
            {
                  System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
}