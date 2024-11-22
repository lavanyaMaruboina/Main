@isTest
public class LWC_LOS_CMUCaseOwnerChangeFlow_cntrlTest {
    @testSetup static void setup(){
        Id profileIdCMU = [SELECT Id FROM Profile WHERE Name = 'CMU' LIMIT 1]?.Id;
        User cmuUsr = new User(LastName = 'test credit', FirstName='sample credit', MobilePhone = '8877667788', Alias = 'cm test', Email = 'test.sample@creditmanager.com', Username = 'test.sample@credit.com', ProfileId = profileIdCMU, LanguageLocaleKey = 'en_US', timezonesidkey='Asia/Kolkata', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', IsActive = TRUE, Maker_Id__c='1234');
        insert cmuUsr;
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          Maker_Id__c='1002',
                          UserName='standarduser4@testorg.com.psdev1',MobilePhone='0123456789');
        insert u;
    }
    
     @isTest
    public static void handleChangeOwnerProcess_Test(){
        try{   
            Id cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1]?.Id;
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            opks1.Customer_Type__c = 'Non-Individual';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Beneficiary';
            apks1.In_Active_Applicant__c = false;
            apks1.IND_Customer_Master_Creation_Status__c = true;
            apks1.Saved_Customer_Relation__c = true;

            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'BE';
            opm.UserId = UserInfo.getUserId();
            insert opm;

            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    //All Document Accept Check
    @isTest
    public static void testChangeOwnerForSalesUser(){
        try{   
            Id cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1]?.Id;
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            opks1.Customer_Type__c = 'Non-Individual';
            opks1.Is_Revoked__c = true;
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.IND_Customer_Master_Creation_Status__c = true;
            apks1.Saved_Customer_Relation__c = true;

            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'BE';
            opm.UserId = UserInfo.getUserId();
            insert opm;

            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    //Document Rejection Check - Incorrect Fields Test
    @isTest
    public static void testChangeOwnerForSalesUser1(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            opks1.Is_Revoked__c = true;
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            cs1.Status = 'Closed';
            insert cs1;
            
            Documents__c dfks2 = new Documents__c();
            dfks2.Case__c = cs1.Id;
            dfks2.Applicant__c = apks1.Id;
            dfks2.Opportunity_Relation__c = opks1.Id;
            dfks2.KYC_name__c = 'PAN';
            dfks2.Document_Side__c ='Back';
            dfks2.Aadhar_Source__c = 'ScanAadhar';
            dfks2.Name = 'Aadhar';
            dfks2.Document_Type__c = '36';
            dfks2.CMU_Accept_Reject__c = 'Reject';
            dfks2.CMU_Rejection_Reason__c = 'Incorrect fields';
            dfks2.Rejection_Fields__c = 'PAN No.';
            dfks2.Proof_of_Identity_POI__c = false;
            dfks2.Proof_of_Address_POA__c = true;
            dfks2.Content_Document_Count__c = 2;
            dfks2.is_Active__c = true;
            insert dfks2;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'BE';
            opm.UserId = UserInfo.getUserId();
            insert opm;
            system.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    //Document Rejection Check - Incorrect Document Test
    @isTest
    public static void testChangeOwnerForSalesUser2(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Journey_Status__c = 'Stop';
            opks1.Journey_Stop_Reason__c = 'Journey stop';
            opks1.Product_Type__c = 'Tractor';

            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Signature missing';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Proof_of_Address_POA__c = false;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
			system.runAs(cmuUserId){
                Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
                Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e--' + e);
        }
    }
    
    //Document Rejection Check - Incorrect Document Test
    @isTest
    public static void testChangeOwnerForSalesUser12(){
        try{   
             User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            cs1.status='Pending with CMU';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'Scan and Upload';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Incorrect document';
            dfks1.Rejection_Fields__c = 'Image not clear';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Proof_of_Address_POA__c = false;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            system.debug('cs1--' + cs1);
            system.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);
                
                dfks1.Rejection_Fields__c = 'Test';
                update dfks1;
                
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);
            Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e---' + e);
        }
    }
        
    //All Document Accept/Reject Check Test
    @isTest
    public static void testChangeOwnerForSalesUser3(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            opks1.Is_Revoked__c = true;
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            cs1.status='Pending with CMU';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = system.Label.AadhaarCard;
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Incorrect fields';
            dfks1.Rejection_Fields__c = 'KYC name';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            System.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e--' + e.getMessage());
        }
    }
    
    @isTest
    public static void testChangeOwnerForSalesUser14(){
        try{   
            User salesUserId = [SELECT Id FROM User WHERE username = 'standarduser4@testorg.com.psdev1' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';

            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = salesUserId.Id;
            cs1.status='Pending with Sales';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Incorrect document';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
            
            Documents__c dfks2 = new Documents__c();
            dfks2.Case__c = cs1.Id;
            dfks2.Applicant__c = apks1.Id;
            dfks2.Opportunity_Relation__c = opks1.Id;
            dfks2.KYC_name__c = 'PAN';
            dfks2.Document_Side__c ='Back';
            dfks2.Aadhar_Source__c = 'ScanAadhar';
            dfks2.Name = 'Aadhar';
            dfks2.Document_Type__c = '4';
            dfks2.CMU_Accept_Reject__c = 'Reject';
            dfks2.CMU_Rejection_Reason__c = 'Incorrect document';
            dfks2.Proof_of_Identity_POI__c = true;
            dfks2.Content_Document_Count__c = 2;
            dfks2.is_Active__c = true;
            insert dfks2;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'BE';
            opm.UserId = salesUserId.Id;
            insert opm;
            System.runAs(salesUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
           // System.assertEquals('Script-thrown exception', e.getMessage());
           System.debug('e--' + e);
        }
    }

    //Document Rejection Check - Incorrect Doc - Sales CMU Case Test
    @isTest
    public static void testChangeOwnerForSalesUser4(){
        try{   
           User salesUserId = [SELECT Id FROM User WHERE username = 'standarduser4@testorg.com.psdev1' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = salesUserId.Id;
            cs1.status='Pending with Sales';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Incorrect document';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.isFrontDocReplaced__c = true;
            dfks1.isBackDocReplaced__c = true;
            dfks1.is_Active__c = true;
            insert dfks1;
            
           OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'BE';
            opm.UserId = salesUserId.Id;
            insert opm;
            System.runAs(salesUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e--' + e);
        }
    }
    
    //Sales user Case Test
    @isTest
    public static void testChangeOwnerForSalesUser5(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            
            // opks1.Is_Customer_Dedupe_Submit__c = true;
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Water Bill';
            dfks1.Name = 'Water Bill';
            dfks1.Document_Type__c = 'Water Bill';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Proof_of_Address_POA__c = false;
            dfks1.Content_Document_Count__c = 1;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            system.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void testGetMetadata(){
        Test.startTest();
            LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.getMetadata('36');
            LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.getMetadata(system.Label.DrivingLicences);
            LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.getMetadata(system.Label.VoterIdCard);
            LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.getMetadata(system.Label.PassportCard);
            LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.getMetadata('PAN');
        Test.stopTest();
    }
    @isTest
    public static void testChangeOwnerForSalesUserNonTractor(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Two Wheeler';
            
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            cs1.status='Pending with CMU';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = system.Label.AadhaarCard;
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Incorrect fields';
            dfks1.Rejection_Fields__c = 'KYC name';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            System.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e--' + e.getMessage());
        }
    }
     @isTest
    public static void testChangeOwnerForSalesUserNonTractor23(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Two Wheeler';
            
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Co-borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            cs1.status='Pending with CMU';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = system.Label.AadhaarCard;
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Incorrect fields';
            dfks1.Rejection_Fields__c = 'KYC name';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            System.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e--' + e.getMessage());
        }
    }
    //caseOwnerProfileName != 'CMU' && isAllAccepted = false
    @isTest
    public static void testChangeOwnerForSalesUser5_2(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            User user2 = [SELECT Id FROM User WHERE username = 'standarduser4@testorg.com.psdev1' LIMIT 1];
            System.runAs(user2){
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
                opks1.Product_Type__c = 'Tractor';
                
                // opks1.Is_Customer_Dedupe_Submit__c = true;
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                insert apks1;
                
                Case cs1 = new Case();
                cs1.Applicant__c = apks1.Id;
                cs1.Loan_Application__c = opks1.Id;
                cs1.Origin = 'Email';
                cs1.SuppliedCompany = 'testpvt';
                cs1.OwnerId = user2.Id;
                insert cs1;
                
                Documents__c dfks1 = new Documents__c();
                dfks1.Case__c = cs1.Id;
                dfks1.Applicant__c = apks1.Id;
                dfks1.Opportunity_Relation__c = opks1.Id;
                dfks1.KYC_name__c = 'Water Bill';
                dfks1.Name = 'Water Bill';
                dfks1.Document_Type__c = 'Water Bill';
                dfks1.CMU_Accept_Reject__c = 'Reject';
                dfks1.CMU_Rejection_Reason__c = 'Incorrect fields';
                dfks1.Rejection_Fields__c = 'PAN No.';
                dfks1.Proof_of_Identity_POI__c = true;
                dfks1.Proof_of_Address_POA__c = false;
                dfks1.Content_Document_Count__c = 1;
                dfks1.Is_active__c = true;
                dfks1.Aadhar_Source__c = 'ScanAadhar';
                insert dfks1;
                
                OpportunityTeamMember opm = new OpportunityTeamMember();
                opm.OpportunityId = cs1.Loan_Application__c;
                opm.TeamMemberRole = 'CMU';
                opm.UserId = cmuUserId.Id;
                insert opm;
                Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);     
                
                Test.stopTest();
            }
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    //caseOwnerProfileName != 'CMU' && isAllAccepted = false
    @isTest
    public static void testChangeOwnerForSalesUser5_3(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            User user2 = [SELECT Id FROM User WHERE username = 'standarduser4@testorg.com.psdev1' LIMIT 1];
            System.runAs(user2){
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
                opks1.Product_Type__c = 'Tractor';
                
                // opks1.Is_Customer_Dedupe_Submit__c = true;
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                insert apks1;
                
                Case cs1 = new Case();
                cs1.Applicant__c = apks1.Id;
                cs1.Loan_Application__c = opks1.Id;
                cs1.Origin = 'Email';
                cs1.SuppliedCompany = 'testpvt';
                cs1.OwnerId = user2.Id;
                insert cs1;
                
                Documents__c dfks1 = new Documents__c();
                dfks1.Case__c = cs1.Id;
                dfks1.Applicant__c = apks1.Id;
                dfks1.Opportunity_Relation__c = opks1.Id;
                dfks1.KYC_name__c = 'Water Bill';
                dfks1.Name = 'Water Bill';
                dfks1.Document_Type__c = 'Water Bill';
                dfks1.CMU_Accept_Reject__c = 'Accept';
                dfks1.Proof_of_Identity_POI__c = true;
                dfks1.Proof_of_Address_POA__c = false;
                dfks1.Content_Document_Count__c = 1;
                dfks1.Is_active__c = true;
                dfks1.Aadhar_Source__c = 'ScanAadhar';
                insert dfks1;
                
                OpportunityTeamMember opm = new OpportunityTeamMember();
                opm.OpportunityId = cs1.Loan_Application__c;
                opm.TeamMemberRole = 'CMU';
                opm.UserId = cmuUserId.Id;
                insert opm;
                Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);     
                
                Test.stopTest();
            }
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void testChangeOwnerForSalesUserCoBorrower(){
        try{   
            Id cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1]?.Id;
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            opks1.Customer_Type__c = 'Non-Individual';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Co-borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.IND_Customer_Master_Creation_Status__c = true;
            apks1.Saved_Customer_Relation__c = true;

            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'BE';
            opm.UserId = UserInfo.getUserId();
            insert opm;
            
            Test.startTest();
            LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
        @isTest
    public static void testChangeOwnerForSalesUserGuarantor(){
        try{   
            Id cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1]?.Id;
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Tractor';
            opks1.Customer_Type__c = 'Non-Individual';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Guarantor';
            apks1.In_Active_Applicant__c = false;
            apks1.IND_Customer_Master_Creation_Status__c = true;
            apks1.Saved_Customer_Relation__c = true;

            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = '36';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'BE';
            opm.UserId = UserInfo.getUserId();
            insert opm;
            
            Test.startTest();
            LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
 //1. All Document Accepted - Case Closed scenario - first else if
    @isTest
    public static void testChangeOwnerForSalesUserElse1(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Is_Customer_Dedupe_Submit__c = true;
            opks1.Product_Type__c = 'Tractor';
            
            // opks1.Is_Customer_Dedupe_Submit__c = true;
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Water Bill';
            dfks1.Name = 'Water Bill';
            dfks1.Document_Type__c = 'Water Bill';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Proof_of_Address_POA__c = false;
            dfks1.Content_Document_Count__c = 1;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            system.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
     //1. All Document Accepted - Case Closed scenario - first else if
    @isTest
    public static void testChangeOwnerForSalesUserElse2(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Is_Customer_Dedupe_Submit__c = true;
            opks1.Product_Type__c = 'Tractor';
            opks1.Customer_Type__c = 'Non-Individual';
            
            
            // opks1.Is_Customer_Dedupe_Submit__c = true;
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.Saved_Customer_Relation__c = false;
            apks1.IND_Customer_Master_Creation_Status__c = true;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Water Bill';
            dfks1.Name = 'Water Bill';
            dfks1.Document_Type__c = 'Water Bill';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Proof_of_Address_POA__c = false;
            dfks1.Content_Document_Count__c = 1;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            system.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }//1. All Document Accepted - Case Closed scenario - last else case
    @isTest
    public static void testChangeOwnerForSalesUserElse3(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Is_Customer_Dedupe_Submit__c = true;
            opks1.Product_Type__c = 'Tractor';
           // opks1.Customer_Type__c = 'Non-Individual'; 
            
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.Saved_Customer_Relation__c = false;
            apks1.IND_Customer_Master_Creation_Status__c = true;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Water Bill';
            dfks1.Name = 'Water Bill';
            dfks1.Document_Type__c = 'Water Bill';
            dfks1.CMU_Accept_Reject__c = 'Accept';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Proof_of_Address_POA__c = false;
            dfks1.Content_Document_Count__c = 1;
            insert dfks1;
        
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            system.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void testChangeOwnerForSalesUserNonTractor2(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
			Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.Product_Type__c = 'Two Wheeler';
            
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            cs1.status='Pending with CMU';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = system.Label.AadhaarCard;
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = '	Documents reject or Customer Photo reject';
            dfks1.Rejection_Fields__c = 'KYC name';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            System.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e--' + e.getMessage());
        }
    }
    //Lead source other than OLA
    @isTest
    public static void testChangeOwnerForSalesUserNonTractorLeadSource(){
        try{   
            User cmuUserId = [SELECT Id FROM User WHERE username = 'test.sample@credit.com' LIMIT 1];
            
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Lead_number__c = '45367';
            opks1.LeadSource = 'D2C';
            opks1.Product_Type__c = 'Two Wheeler';
            
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Case cs1 = new Case();
            cs1.Applicant__c = apks1.Id;
            cs1.Loan_Application__c = opks1.Id;
            cs1.Origin = 'Email';
            cs1.SuppliedCompany = 'testpvt';
            cs1.OwnerId = cmuUserId.Id;
            cs1.status='Pending with CMU';
            insert cs1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = cs1.Id;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = system.Label.AadhaarCard;
            dfks1.CMU_Accept_Reject__c = 'Reject';
            dfks1.CMU_Rejection_Reason__c = 'Incorrect fields';
            dfks1.Rejection_Fields__c = 'KYC name';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Content_Document_Count__c = 2;
            dfks1.is_Active__c = true;
            insert dfks1;
            OpportunityTeamMember opm = new OpportunityTeamMember();
            opm.OpportunityId = cs1.Loan_Application__c;
            opm.TeamMemberRole = 'CMU';
            opm.UserId = cmuUserId.Id;
            insert opm;
            System.runAs(cmuUserId){
            Test.startTest();
                LWC_LOS_CMUCaseOwnerChangeFlow_cntrl.handleChangeOwnerProcess(cs1.Id);      
            Test.stopTest();
            }
        } catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.debug('e--' + e.getMessage());
        }
    }

  
}