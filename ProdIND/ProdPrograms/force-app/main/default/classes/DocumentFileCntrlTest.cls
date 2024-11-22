@IsTest
public class DocumentFileCntrlTest {
    @testSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test12_userprod1234@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            opp.Product_Type__c='Passenger Vehicles';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            opptyList.add(opp);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicantList.add(applicant1);
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicantList;
            }
            // List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_Document_Eligible__c='No';
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            doc1.Additional_Document__c = true;
            // docList.add(doc1);
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert doc1;
            }
            ContentVersion contentVersion1 = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion1; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc1.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;

            Documents__c doc2 = new Documents__c( Applicant__c =applicantList[0].id,
                                                     Name= 'Customer Image',
                                                     Opportunity_Relation__c=opp.Id,
                                                     DocAuth_Passed__c = true,
                                                     KYC_DOB__c= Date.newInstance(1991, 06, 05 ),
                                                     Selfie_report_Pass__c = true,
                                                     Golden_Source_Pass__c = true,
                                                     Proof_of_Identity_POI__c = true,
                                                     Name_Mismatch_Percentage__c = 00,
                                                     Is_Photocopy__c=true,
                                                     Document_Type__c='Customer Image',
                                                     Name_Mismatch_Pass__c = true,
                                                    is_Active__c=true);
            insert doc2;
            
            ContentVersion contentVersion2 = new ContentVersion(
                Title          = 'testname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content 2'),
                IsMajorVersion = true);
            insert contentVersion2; 
            List<ContentDocument> documentss = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl2 = new ContentDocumentLink();
            cdl2.LinkedEntityId = doc2.Id;
            cdl2.ContentDocumentId = documentss[0].Id;
            cdl2.ShareType = 'V';
            cdl2.Visibility = 'AllUsers';
            insert cdl2;


           //Create Retry_Count__c records
           List<Retry_Count__c> rtCountList = new List<Retry_Count__c>();
           Retry_Count__c retryCount1 = new Retry_Count__c();
           retryCount1.Service_Name__c = System.Label.CMU_Front;
           retryCount1.Count__c = 0;
           retryCount1.Loan_Application_Id__c = opp.Id;
           retryCount1.Applicant__c=applicantList[0].id;
           retryCount1.User_Id__c = u.Id;
           rtCountList.add(retryCount1);

           Retry_Count__c retryCount2 = new Retry_Count__c();
           retryCount2.Service_Name__c = System.Label.CMU_Back;
           retryCount2.Count__c = 0;
           retryCount2.Loan_Application_Id__c = opp.Id;
           retryCount2.User_Id__c = u.Id;
           retryCount2.Applicant__c=applicantList[0].id;
           rtCountList.add(retryCount2);
           if(Schema.sObjectType.Retry_Count__c.isCreateable()){
               insert rtCountList;
           }
           

        }
    }
    @IsTest
    public static void test_getRelatedFile(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test12_userprod1234@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Documents__c docId =[Select Id From Documents__c LIMIT 1];
                Documents__c docId2 =[Select Id From Documents__c WHERE Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
                String addnlDataStringNeg = DocumentFileCntrl.getRelatedFile(docId.Id);
                String getImageFile = DocumentFileCntrl.getImageFile(docId2.Id);
                DocumentFileCntrl.getPOIdetails(docId2.Id);
                //System.assertEquals('{"docDetails":[]}', addnlDataStringNeg);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }
    @IsTest
    public static void test_getRelatedDocumentDetails(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test12_userprod1234@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Documents__c docId =[Select Id From Documents__c LIMIT 1];
                DocumentFileCntrl.DocumentDataWrapper wrapperObj = new DocumentFileCntrl.DocumentDataWrapper();
                wrapperObj = DocumentFileCntrl.getRelatedDocumentDetails(docId.Id);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }
    @IsTest
    public static void test_retryCountIncrease(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test12_userprod1234@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Documents__c docRec =[Select Id,Opportunity_Relation__c From Documents__c LIMIT 1];
                Boolean haveRetryAttemt = DocumentFileCntrl.retryCountIncrease(docRec.Opportunity_Relation__c, System.Label.CMU_Front);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }
    @IsTest
    public static void test_retryCountIncrease_Negative(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test12_userprod1234@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Documents__c docRec =[Select Id,Opportunity_Relation__c From Documents__c LIMIT 1];
                Boolean haveRetryAttemt = DocumentFileCntrl.retryCountIncrease(docRec.Opportunity_Relation__c, 'Test');
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }
    @IsTest
    public static void test_getImageFile(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test12_userprod1234@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Documents__c docRec =[Select Id,Opportunity_Relation__c From Documents__c Where Name != 'Customer Image' LIMIT 1];
                DocumentFileCntrl.getImageFile(docRec.Id);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }
    @IsTest
    public static void test_getPOIdetails(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test12_userprod1234@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Documents__c docRec =[Select Id,Opportunity_Relation__c From Documents__c Where Applicant__c != null LIMIT 1];
                docRec.Proof_of_Identity_POI__c = true;
                update docRec;
                DocumentFileCntrl.getPOIdetails(docRec.Id);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }

    @IsTest
    public static void test_deleteDocumentRecord(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test12_userprod1234@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Documents__c docId =[Select Id From Documents__c LIMIt 1];
                ContentVersion uploadedImage = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
                List<String> docList = new List<String>();
                docList.add(uploadedImage.ContentDocumentId);
                DocumentFileCntrl.deleteDocumentRecord(docId.Id, JSON.serialize(docList));
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }
}