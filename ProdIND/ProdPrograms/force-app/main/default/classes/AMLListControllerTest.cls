@isTest
public class AMLListControllerTest {
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Credit Head'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123Head2323442444214444567@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            // Create Opportunity            
            Opportunity opp = new Opportunity();
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = 'STP';
            opp.AML_Check_status__c ='Rejected';
            opp.Lead_Number__c='L-10122021-1685';
            opp.Whatsapp_number__c='1231231231';
            opp.Contact_number__c = '9743514830';
            opp.Name = 'abc';
            opp.StageName = 'Closed won';
            opp.CloseDate = system.today();
            insert opp; 
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            //Create Applicant__c Data            
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicant1.Contact_number__c = '8433211058';
            applicant1.Whatsapp_number__c = '9567243123';
            
            insert applicant1;                        
            
            // Create Case1
            Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            Case cse1 = TestDataUtility.createTestCase(false,opp,applicant1);
            cse1.RecordTypeId = amlRecordTypeId;
            cse1.Status = System.label.Pendingcredithead;
            insert cse1;
            
            // Create Case2
            Case cse2 = TestDataUtility.createTestCase(false,opp,applicant1);
            cse2.RecordTypeId = amlRecordTypeId;
            cse2.Status = 'Closed';
            
            insert cse2;
            
            //Create Documents__c records            
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_Document_Eligible__c='No';
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'AML';
            doc1.Additional_Document__c = true;
            
            insert doc1;
            
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = opp.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl; 
            
            //  Create AML_Check__c
            AML_Check__c amls = new AML_Check__c(Matched_base__c ='MatchedBase', Credit_Head__c = true, List_Name__c='list', Name__c='Test',Name_Score__c=0.1, ML_Id__c = 'Id', 
                                                 Nationality__c ='Nationality',Nationality_Score__c = 0.2, ML_Address__c='Address', ML_City__c = 'city', ML_Date_Of_Birth__c = String.valueOf(date.newInstance(1901, 01, 01)),
                                                 ML_Description__c = 'description', CA_Decision__c = 'Positive', Remarks_Credit_Analyst__c = 'Remarks', CH_Decision__c = 'Decision' ,
                                                 Remarks_Credit_Head__c = 'RemarksCredit' ,Documents__c =doc1.id,CMU_Decision__c='Cmu Decision',Remarks_CMU__c='RemarksCmu', 
                                                 BE_CVO_Decision__c ='CvoDecision', Remarks_BE_CVO__c='RemarksBeSCvo', Score__c = 0.3, Case__c = cse1.id,
                                                 Loan_Application__c=opp.id, Content_Document_Id__c = documents[0].Id); 
            insert amls; 
            
            // Create CAM__c     
            CAM__c cam = new CAM__c();
            cam.Loan_Application__c = opp.Id;
            cam.BE_CVO_Remark__c = 'testbe';
            cam.Conditional_Approval__c = 'testapprov';
            cam.Proposal_Status__c = 'testproposal';
            insert cam;                                    

            // Integration_Configuration__mdt
            Integration_Configuration__mdt metadataApi = new Integration_Configuration__mdt(IsStub_Required__c=true);            
        }        
    }
    
    @isTest 
    public static void AMLListControllerTest(){
        try
        {    
            Test.startTest();  
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Head2323442444214444567@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                PageReference pageRef = Page.AMLList; 
                pageRef.getParameters().put('id', String.valueOf([select id from cam__c limit 1].Id));
                Test.setCurrentPage(pageRef);
                AMLListController objAMLListController = new AMLListController();
                
                ViewCamController vcObj = new ViewCamController();
                AMLListController obj = new AMLListController(vcObj);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
 
    @istest
    static void getAmlCheckListTest(){
        try
        {                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Head2323442444214444567@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                                
                AMLListController aml1 = new AMLListController();
                List<AML_Check__c> result1 = aml1.getAmlCheckList();
                System.assertEquals(null, result1);
                
                PageReference pageRef = Page.IBLCAMPage;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('id', String.valueOf([select id from cam__c limit 1].Id));
                ApexPages.currentPage().getParameters().put('c_loanappid', [select id from Opportunity limit 1].Id);
                AMLListController aml2 = new AMLListController();
                List<AML_Check__c> result2 = aml2.getAmlCheckList();
                System.assertNotEquals(null, result2);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @istest
    static void getItemsTest(){
        try
        {                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Head2323442444214444567@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                                
                AMLListController aml1 = new AMLListController();
                List<SelectOption> result = aml1.getItems();
                System.assertNotEquals(null, result);                  
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @istest
    static void approveAMLTest(){
        try
        {                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Head2323442444214444567@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                                
                PageReference pageRef = Page.IBLCAMPage;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('id', String.valueOf([select id from cam__c limit 1].Id));
                ApexPages.currentPage().getParameters().put('c_loanappid', [select id from Opportunity limit 1].Id);
                AMLListController aml = new AMLListController();
                aml.approveAML(); 

            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @istest
    static void rejectAMLTest(){
        try
        {                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Head2323442444214444567@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                                
                PageReference pageRef = Page.IBLCAMPage;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('id', String.valueOf([select id from cam__c limit 1].Id));
                ApexPages.currentPage().getParameters().put('c_loanappid', [select id from Opportunity limit 1].Id);
                AMLListController aml = new AMLListController();
                Object result1 = aml.rejectAML();
               	System.assertNotEquals(null, result1);
                
                Opportunity opp = [select id from Opportunity limit 1];
                opp.Sanction_Status__c = 'NON-STP';
                update opp;
                Object result2 = aml.rejectAML();

                HttpResponse response = new HttpResponse();
                String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuVrKDeBNiojndyKtLQoX7upFsTrRkJmZJNIgdkS7hNrJigY5/m9JrXCt+K6YQwxMDFlsL3BshrRI8XlQdZTrUgYg=="}'; 
                response.setBody(body);
                response.setStatusCode(200);
                

                String continuationLabel = aml.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
             
                Object continuationState= aml.continuationState; 
                
                System.debug('labels===>'+labels);
                System.debug('continuationState===>'+continuationState);
                
               
                    Test.setContinuationResponse(continuationLabel, response);
                    Object result3 = aml.processSMSGatewayResponse(labels, aml.continuationState);

                    System.assertNotEquals(null, result3);    
                System.assertNotEquals(null, result2);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }   
}