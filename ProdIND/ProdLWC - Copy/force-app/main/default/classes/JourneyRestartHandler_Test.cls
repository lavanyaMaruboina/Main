@isTest
public class JourneyRestartHandler_Test {
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',
                          MobilePhone='8234567890');
        insert u;
        System.runAs(u) 
        {
            
            Account acc = new Account();
            acc.Name = 'test account';
            acc.State__c = 'MAHARASHTRA';
            acc.Phone = '+914335225';
            insert acc;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false); 
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.PassengerVehicles;
            opp.Sanction_Status__c = System.Label.nonStp;  
            opp.Agent_BL_code__c = 'AHZ';
            opp.Deal_Number__c = null; 
            opp.AccountId = acc.Id;
            opp.Required_ROI__c = 9;
            opp.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp.Product_Type__c =  system.label.TwoWheeler;
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            oppList.add(opp);  
            
            insert oppList;
            
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Name = 'testapplicant1';
            applicant1.Father_s_name__c = 'fsfdsf';
            applicant1.Opportunity__c = oppList[0].Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicant1.Contact_Number__c = '+9123456789';
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.Email_Id_2__c = 'test2@abc.com';
            applicant1.Email_Id_1__c = 'test1@abc.com';
            applicant1.Email_Id__c = 'test@abc.com';
            applicant1.applicant_Type__c = System.Label.Borrower;
            applicant1.In_Active_Applicant__c = false;
            applicantList.add(applicant1);
            
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt1(false);
            applicant2.Name = 'testapplicant1';
            applicant2.Father_s_name__c = 'fsfdsf';
            applicant2.Opportunity__c = oppList[0].Id;
            applicant2.Scorecard_Decision__c = 'Light Red';
            applicant2.Contact_Number__c = '+9123456789';
            applicant2.Applicant_Type__c = System.Label.CoBorrower;
            applicant2.Email_Id_2__c = 'test2@abc.com';
            applicant2.Email_Id_1__c = 'test1@abc.com';
            applicant2.Email_Id__c = 'test@abc.com';
            applicantList.add(applicant2);
            
            INSERT applicantList;
            
            Customer_Dedupe_Response__c customerDedupe1 = new Customer_Dedupe_Response__c();
            customerDedupe1.Applicant__c = applicantList[0].Id;
            insert customerDedupe1;
            
            Customer_Dedupe_Response__c customerDedupe2 = new Customer_Dedupe_Response__c();
            customerDedupe2.Applicant__c = applicantList[1].Id;
            insert customerDedupe2;

            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            
            List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c();
            vehicleDetail.Vehicle_Type__c = 'New';
            vehicleDetail.Finance_Amount__c = null;
            vehicleDetail.Eligible_Loan_Amount__c =  null;
            vehicleDetail.Dealer_Sub_dealer_name__c =  null;
            vehicleDetail.Vehicle_Registration_number__c =  null;
            vehicleDetail.Make__c =  null;
            vehicleDetail.Model__c =  null;
            vehicleDetail.Variant_Code__c =  null;
            vehicleDetail.Variant__c =  null;
            vehicleDetail.Ben_Code__c =  'testveh';
            vehicleDetail.Ins_Expiry_date__c =  null;
            vehicleDetail.Purpose_of_Purchase__c =  null;
            vehicleDetail.Variant__c = 'test variant';
            vehicleDetail.Make__c = 'Test make';
            vehicleDetail.Model__c = 'test Model';
            vehicleDetail.Dealer_Sub_dealer_name__c = 'test dealer';
            vehicleDetail.Engine_number__c = '443243432';
            vehicleDetail.Chassis_number__c = '543543422';
            vehicleDetail.Loan_Application__c = oppList[0].Id;
            vehicleDetailList.add(vehicleDetail);
            insert vehicleDetailList;
            
            List<Final_Term__c> finalTermList = new List<Final_Term__c>();
            Final_Term__c finalTerm = new Final_Term__c();
            finalTerm.Loan_Amount__c = '230000';
            finalTerm.Tenure__c = '3';
            finalTerm.Holiday_period__c  = '30';
            finalTerm.Advance_EMI__c = true;
            finalTerm.EMI_Amount__c = 23456;
            finalTerm.CRM_IRR__c = 545643 ;
            finalTerm.Service_charges__c = '553432';
            finalTerm.Documentation_charges__c = '545435';
            finalTerm.Stamping_charges__c = null;
            finalTerm.Installment_Type__c = 'Equated';
            finalTerm.Loan_Application__c = oppList[0].Id;
            finalTermList.add(finalTerm);
            
            insert finalTermList;
            
            Case caseObj1 = new Case();
            caseObj1.Status = 'Closed';
            caseObj1.Origin = 'Phone';
            caseObj1.Loan_Application__c = oppList[0].Id;
            caseObj1.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.CMURequest).getRecordTypeId();
            insert caseObj1;
            
            Case caseObj2 = new Case();
            caseObj2.Status = 'New';
            caseObj2.Origin = 'Phone';
            caseObj2.Loan_Application__c = oppList[0].Id;
            caseObj2.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.TVR).getRecordTypeId();
            insert caseObj2;
            
            List<Documents__c> docList = new List<Documents__c>();
            
            Documents__c doc531 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant1, opp);
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
            doc531.Case__c = caseObj1.Id;
            
            docList.add(doc531);
            
            Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant2, opp);
            doc2.Document_Type__c = 'Customer Image';
            doc2.is_Active__c = true;
            doc2.Aadhar_Source__c = 'OTP'; 
            doc2.Salutation__c = 'Mr.';
            doc2.KYC_Address_Line_1__c = 'Test Address';
            doc2.KYC_Address_Line_2__c = 'Test Address';
            doc2.KYC_City__c = 'Delhi';
            doc2.KYC_State__c = 'Delhi';
            doc2.KYC_Pin_Code__c = '110090';
            doc2.Permanent_Residential_Address_Proof__c = true;
            doc2.Case__c = caseObj1.Id;
            
            docList.add(doc2);
            insert docList;
            
            List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();
            
            String contentid = [select contentdocumentid from contentversion where id =: content.id].ContentDocumentId;
            for(Documents__c doc : docList){
                ContentDocumentLink contentLink = new ContentDocumentLink();
                contentLink.LinkedEntityId = doc.id;
                contentLink.ContentDocumentId = contentid;
                contentLink.ShareType = 'I';
                contentLink.Visibility = 'AllUsers';
                contentLinkList.add(contentLink);
            }
            
            insert contentLinkList;
            
            CIBIL_Details__c cbd1 = new CIBIL_Details__c();
            cbd1.Applicant__c = applicant1.Id;
            cbd1.CIC_No__c = 'testcbd';
            insert cbd1;
                       
        }
    }
    
    @isTest
    public static void Journey_Restart_BorrowerTest(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        string applicantId = [Select Id from Applicant__c where Name = 'testapplicant1' limit 1].Id;
        string returnData = JourneyRestartHandler.JourneyRestart(loanApplicationId,applicantId,'Journey_Restart_Borrower','Journey Restart Borrower');   
        Assert.isTrue(returnData != null);
        
        //Negetive
        string returnData2 = JourneyRestartHandler.JourneyRestart('','','Journey_Restart_Borrower','Journey Restart Borrower');   
        
    }
    @isTest
    public static void CMU_RejectBorrowerTest(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        string applicantId = [Select Id from Applicant__c where Name = 'testapplicant1' limit 1].Id;
        string returnData = JourneyRestartHandler.JourneyRestart(loanApplicationId,applicantId,'CMU_Reject_Borrower','CMU Reject Borrower');
        Assert.isTrue(returnData != null);
        
        //Negetive
        string returnData2 = JourneyRestartHandler.JourneyRestart('','','CMU_Reject_Borrower','CMU Reject Borrower');   
    }
    @isTest
    public static void CMUrejectCoBorrowerTest(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        string applicantId = [Select Id from Applicant__c where Name = 'testapplicant1' limit 1].Id;
        string returnData = JourneyRestartHandler.JourneyRestart(loanApplicationId,applicantId,'CMU_reject_Co_Borrower','CMU reject Co Borrower');
        Assert.isTrue(returnData != null);
        
         //Negetive
        string returnData2 = JourneyRestartHandler.JourneyRestart('','','CMU_reject_Co_Borrower','CMU reject Co Borrower');
    }
    @isTest
    public static void JourneyRestartTest(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        string applicantId = [Select Id from Applicant__c where Name = 'testapplicant1' limit 1].Id;
        string returnData = JourneyRestartHandler.JourneyRestart(loanApplicationId,applicantId,'Journey_Restart_Coborrower','Journey Restart Coborrower');
        Assert.isTrue(returnData != null);
        
        //Negetive
        string returnData2 = JourneyRestartHandler.JourneyRestart('','','Journey_Restart_Coborrower','Journey Restart Coborrower');

    }
    @isTest
    public static void Journey_Restart_Borrower_TractorTest(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        string applicantId = [Select Id from Applicant__c where Name = 'testapplicant1' limit 1].Id;
        string returnData = JourneyRestartHandler.JourneyRestart(loanApplicationId,applicantId,'Journey_Restart_Borrower_Tractor','Journey Restart Borrower Tractor');
        Assert.isTrue(returnData != null);
        //Negetive
        string returnData2 = JourneyRestartHandler.JourneyRestart('','','Journey_Restart_Borrower_Tractor','Journey Restart Borrower Tractor');
        
    }
    @isTest
    public static void Journey_Restart_Non_Borrower_TractorTest(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        string applicantId = [Select Id from Applicant__c where Name = 'testapplicant1' limit 1].Id;
        string returnData = JourneyRestartHandler.JourneyRestart(loanApplicationId,applicantId,'Journey_Restart_NonBorrower_Tractor','Journey Restart Non Borrower Tractor');
        Assert.isTrue(returnData != null);
        
        //Negetive
        string returnData2 = JourneyRestartHandler.JourneyRestart('','','Journey_Restart_NonBorrower_Tractor','Journey Restart Non Borrower Tractor');

    }
}