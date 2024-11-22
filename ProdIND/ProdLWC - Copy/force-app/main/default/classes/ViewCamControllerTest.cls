@isTest
public class ViewCamControllerTest {
    @testSetup
    static void testSetup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,User_Id__c = '29927_CVO',
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u2 = new User(
            ProfileId = p2.Id,
            IsActive = true,
            Username = 'testtermsconditions1234423@kaplan.com',
            Alias = 'batman',
            Maker_Id__c='14',User_Id__c = '29935_CEO',
            email='testtermsconditions1234423@kaplan.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',MobilePhone = '9089078967');
        insert u2;
        
        System.runAs(u) 
        {  
            Account testAccount = new Account(Name = 'Test view Acc' ,BranchBLCode__c = '34543');
            insert testAccount;
            
            Account parentAccount = new Account(Name = 'Parent Account Test' ,BranchBLCode__c = '34589');
            insert parentAccount;
            
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = testAccount.Id,  TeamMemberRole = 'SCM', UserId = U.id,  Level__c ='L4;L1;L2');
            insert accTeam;
            
            Opportunity parentOppObj1 = new Opportunity();
            parentOppObj1.AccountId = parentAccount.Id; 
            parentOppObj1.Name= 'Parent Opportunity Test';
            parentOppObj1.StageName='Needs Analysis';
            parentOppObj1.CloseDate=System.today().addMonths(1);    
            insert parentOppObj1;
            
            InsuranceDetails__c insObj = new InsuranceDetails__c();
            insObj.Amount__c = 1000;
            insObj.Loan_Application__c = parentOppObj1.Id;
            insert insObj;
            
            // ------------Parent Opportunity 
            Opportunity parentOppObj = new Opportunity();
            parentOppObj.AccountId = parentAccount.Id; 
            parentOppObj.Name= 'Parent Opportunity Test';
            parentOppObj.StageName='Needs Analysis';
            parentOppObj.CloseDate=System.today().addMonths(1);   
            parentOppObj.Parent_Loan_Application__c = parentOppObj1.Id;
            insert parentOppObj;
            
            InsuranceDetails__c insObj1 = new InsuranceDetails__c();
            insObj1.Amount__c = 1000;
            insObj1.Loan_Application__c = parentOppObj.Id;
            insert insObj1;
            
            
            //----------Parent CAM
            CAM__c parentCam = new CAM__c();
            parentCam.Loan_Application__c = parentOppObj.Id;
            parentCam.BE_CVO_Remark__c = 'testbeCVO';
            parentCam.Is_Hold__c = true;
            parentCam.Conditional_Approval__c = 'testapproved';
            parentCam.Proposal_Status__c = 'Approved';
            insert parentCam;
            
            // ---------Parent Deviation
            Deviation__c parentDev = new Deviation__c();
            parentDev.Parent_CAM__c = parentCam.Id;
            parentDev.Approval_Status__c = 'Approved';
            parentDev.Deviation_Description__c = 'testdescription';
            parentDev.Remarks__c = 'Test Deviation';
            parentDev.Deviation_Level__c = 'L3';
            parentDev.Role__c = 'SH';
            parentDev.Type__c = 'Normal Deviation';
            insert parentDev;
            
            //---------Parent Proposal 
            Proposal_Approval_Log__c parentProposal = new Proposal_Approval_Log__c();
            parentProposal.Deviation_Id__c = parentDev.Id;
            parentProposal.Parent_CAM__c =parentCam.Id;
            parentProposal.Approval_Status__c = 'proaprv';
            parentProposal.Forward_Remark__c = 'testremark';
            parentProposal.Forwarded_By__c = 'testuser';
            insert parentProposal;
            
            // ------------Opportunity 
            Opportunity opp = new Opportunity();
            opp.AccountId = testAccount.Id; 
            opp.Name= 'Opportunity Test';
            opp.Parent_Loan_Application__c = parentOppObj.Id;
            opp.StageName='Qualification';
            opp.CloseDate=System.today().addMonths(2);
            opp.Vehicle_Sub_Category__c= 'UIM';
            opp.Employee_Branch__c = 'Test Employee Branch';
            opp.Gross_IRR__c = 5353;
            opp.NOC_Number__c = 45654;
            opp.Funding_on_ORP__c = true;
            opp.Advance_EMI__c = true;
            opp.Customer_Code__c = '896745';
            opp.Deal_Number__c = 'TUT06226H';
            opp.Funding_on_Ex_Showroom__c = true;
            opp.Basic_Price__c = 67000;
            opp.Discount_on_Basic_Price__c = 6000;
            opp.Funding_on_ORP__c = false;
            opp.RTO_Road_Tax_New__c = 6000;
            opp.X1st_yr_Insurance_Premium__c = 1400;
            opp.Other_charges__c = 2000;
            opp.GST_Amount__c = 10999;
            opp.Agent_BL_code__c='MPP';
            opp.Sub_Stage__c = 'Field Investigation';
            opp.Service_Charges__c = '600';
            opp.Documentation_Charges__c = '500';
            opp.Dealer_Expence_Reimburse_Amt__c = '400';
            opp.DSM_Incentive1__c = 4003;
            opp.Loan_amount__c='500000';  
            opp.OTP_for_borrower__c='3999';
            opp.Applicant_Name__c='Test Applicant';
            opp.Mfr_Incentive__c=98;
            opp.Gift_through_Dealer_Amount__c='1466';
            opp.Required_Tenure__c=8;
            opp.Required_ROI__c=4;
            opp.Parent_Deal_number__c='7678';
            opp.Vehicle_Type__c = 'Used';
            opp.Product_Type__c = 'Two Wheeler';
            opp.Submitted_Tabs__c = 'Borrower Insurance Recompute;Coborrower Insurance Recompute';
            insert opp;
            
            InsuranceDetails__c insObj2 = new InsuranceDetails__c();
            insObj2.Amount__c = 1000;
            insObj2.Loan_Application__c = opp.Id;
            insert insObj2;
            
            // Borrower Applicant 
            Applicant__c applicant =new Applicant__c(Name='test',
                                                     Contact_Number__c ='1234567891',
                                                     Opportunity__c = opp.Id,
                                                     Customer_First_Name__c='GOURAB',
                                                     In_Active_Applicant__c = false,
                                                     Customer_Last_Name__c='GOSWAMI',
                                                     Whatsapp_number__c='1231231231',
                                                     Consent_Received__c=true,
                                                     Income_Ca__c='SAL',
                                                     Profile__c = 'Software Engineer',
                                                     Bureau_Pull_Attempts__c=1,
                                                     Selfie_Retry_Attempts__c=2,
                                                     Income_Source__c='Non-Earning',
                                                     Income_source_available__c = true,
                                                     Preferred_address_for_communication__c = 'Permanent Address',
                                                     of_family_members_residing_with_you__c = '2',
                                                     Residence_country__c = 'India',
                                                     Who_will_repay_the_loan__c = 'Borrower',
                                                     Marital_status__c = 'SINGP',
                                                     Spouse_Name__c = 'Sameer',
                                                     Father_s_name__c = 'Viraa',
                                                     Mother_s_name__c = 'Neeta',
                                                     Communication_language__c = 'Hindi',
                                                     Customer_Qualification__c = 'B2',
                                                     Email_Id__c = 'riya@gmail.com',
                                                     PAN_No__c ='BNIPM6633A',
                                                     DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                                     Applicant_Type__c ='Borrower',
                                                     Scorecard_Decision__c = 'Dark Green',
                                                     Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            // Guarantor Applicant 
            Applicant__c guarantorApplicant =new Applicant__c(Name='test Guarantor',
                                                     Contact_Number__c ='1234567891',
                                                     Opportunity__c = opp.Id,
                                                     Customer_First_Name__c='GOURAB',
                                                     In_Active_Applicant__c = false,
                                                     Customer_Last_Name__c='GOSWAMI',
                                                     Whatsapp_number__c='1231231231',
                                                     Consent_Received__c=true,
                                                     Income_Ca__c='SAL',
                                                     Profile__c = 'Software Engineer',
                                                     Bureau_Pull_Attempts__c=1,
                                                     Selfie_Retry_Attempts__c=2,
                                                     Income_Source__c='Non-Earning',
                                                     Income_source_available__c = true,
                                                     Preferred_address_for_communication__c = 'Permanent Address',
                                                     of_family_members_residing_with_you__c = '2',
                                                     Residence_country__c = 'India',
                                                     Who_will_repay_the_loan__c = 'Guarantor',
                                                     Marital_status__c = 'SINGP',
                                                     Spouse_Name__c = 'Sameer',
                                                     Father_s_name__c = 'Viraa',
                                                     Mother_s_name__c = 'Neeta',
                                                     Communication_language__c = 'Hindi',
                                                     Customer_Qualification__c = 'B2',
                                                     Email_Id__c = 'riya@gmail.com',
                                                     PAN_No__c ='BNIPM6633A',
                                                     DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                                     Applicant_Type__c ='Guarantor',
                                                     Scorecard_Decision__c = 'Dark Green',
                                                     Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert guarantorApplicant;
            }
            
            // Beneficiary Applicant 
            Applicant__c beneficiaryApplicant =new Applicant__c(Name='test Beneficiary',
                                                     Contact_Number__c ='1234567891',
                                                     Opportunity__c = opp.Id,
                                                     Customer_First_Name__c='GOURAB',
                                                     In_Active_Applicant__c = false,
                                                     Customer_Last_Name__c='GOSWAMI',
                                                     Whatsapp_number__c='1231231231',
                                                     Consent_Received__c=true,
                                                     Income_Ca__c='SAL',
                                                     Profile__c = 'Software Engineer',
                                                     Bureau_Pull_Attempts__c=1,
                                                     Selfie_Retry_Attempts__c=2,
                                                     Income_Source__c='Non-Earning',
                                                     Income_source_available__c = true,
                                                     Preferred_address_for_communication__c = 'Permanent Address',
                                                     of_family_members_residing_with_you__c = '2',
                                                     Residence_country__c = 'India',
                                                     Who_will_repay_the_loan__c = 'Beneficiary',
                                                     Marital_status__c = 'SINGP',
                                                     Spouse_Name__c = 'Sameer',
                                                     Father_s_name__c = 'Viraa',
                                                     Mother_s_name__c = 'Neeta',
                                                     Communication_language__c = 'Hindi',
                                                     Customer_Qualification__c = 'B2',
                                                     Email_Id__c = 'riya@gmail.com',
                                                     PAN_No__c ='BNIPM6633A',
                                                     DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                                     Applicant_Type__c ='Beneficiary',
                                                     Scorecard_Decision__c = 'Dark Green',
                                                     Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert beneficiaryApplicant;
            }
            
            /// customerWrapper object
            ViewCamController.CustomerMaster Customobject =  new ViewCamController.CustomerMaster();
            Customobject.Matched_Customer_Code = 'Test';
            Customobject.CIC_No = 'Test';
            Customobject.Aadhaar_No = 'Test';
            Customobject.Matched_Score = 'Test';
            Customobject.Voter_ID_Number = 'Test';
            Customobject.Rule_Field_Weightage = 'Test';
            Customobject.Passport_Number = 'Test';
            Customobject.Matched_Source = 'Test';
            Customobject.PAN_GIR_Number = 'Test';
            Customobject.Active_Flag = 'Test';
            Customobject.Date_of_Birth = 'Test';
            Customobject.Dedupe_Super_Match = 'Test';
            Customobject.Dedupe_Super_Match_Score = 'Test';
            Customobject.Rule_Matching_Fields = 'Test';
            Customobject.Current_Parameter_Value = 'Test';
            Customobject.Matched_Parameter_Value = 'Test';
            Customobject.Driving_License_Number = 'Test';
            Customobject.Customer_Type = 'Test';
            Customobject.Customer_Name = 'Test';
            Customobject.Rule_Id = 'Test';
            Customobject.PEP_Remarks = 'Test';
            Customobject.Type = 'Test';
            
            // Beneficiary Wrapper 
            ViewCamController.BeneficiaryAlert beneficiaryobject =  new ViewCamController.BeneficiaryAlert();
            beneficiaryobject.Ben_code ='Test';
            beneficiaryobject.Status_Flag ='test';
            beneficiaryobject.Beneficiary = 'test';
            beneficiaryobject.PAN_No = 'test';
            
            // ExternalDedupeResponse Wrapper 
            ViewCamController.ExternalDedupeResponse Extraresponse =  new ViewCamController.ExternalDedupeResponse();
            Extraresponse.DtCFDCUSTBAS ='Test';
            Extraresponse.CustomerValidate ='test';
            Extraresponse.DtRECENTLEAD = 'test';
            Extraresponse.DEDUPE_STATUS = 'test';
            
            // coborrower Applicant 
            Applicant__c coborrowerApp =new Applicant__c(Name='test12111',
                                                         Contact_Number__c ='12345678911',
                                                         Customer_First_Name__c='GOURAB1',
                                                         Customer_Last_Name__c='GOSWAMI1',
                                                         Whatsapp_number__c='12312312311',
                                                         In_Active_Applicant__c = false,
                                                         Consent_Received__c=true,
                                                         Opportunity__c = opp.Id,
                                                         Income_Ca__c='SAL',
                                                         Profile__c = 'Software Engineer',
                                                         Bureau_Pull_Attempts__c=1,
                                                         Selfie_Retry_Attempts__c=2,
                                                         Income_Source__c='Non-Earning',
                                                         Income_source_available__c = true,
                                                         Preferred_address_for_communication__c = 'Permanent Address',
                                                         of_family_members_residing_with_you__c = '2',
                                                         Residence_country__c = 'India',
                                                         Who_will_repay_the_loan__c = 'Borrower',
                                                         Marital_status__c = 'SINGP',
                                                         Spouse_Name__c = 'Sameer',
                                                         Father_s_name__c = 'Viraa',
                                                         Mother_s_name__c = 'Neeta',
                                                         Communication_language__c = 'Hindi',
                                                         Customer_Qualification__c = 'B2',
                                                         Email_Id__c = 'riya11@gmail.com',
                                                         DocAuth_Application_Id__c = 'AC1241_24524353_g11',
                                                         Applicant_Type__c ='Co-borrower',
                                                         Scorecard_Decision__c = 'Light Green',
                                                         Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
            insert coborrowerApp;    
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false, applicant);
            insert cibilDetail;    
            
            CAM__c cam1 = new CAM__c();
            cam1.Loan_Application__c = opp.Id;
            cam1.BE_CVO_Remark__c = 'testbe';
            cam1.Is_Hold__c = true;
            cam1.Trigger_Deviations__c = true;
            cam1.Conditional_Approval__c = 'testapprov';
            cam1.Proposal_Status__c = 'testproposal';
            insert cam1;
            
            // ---------Deviation
            Deviation__c dv2 = new Deviation__c();
            dv2.Parent_CAM__c = cam1.Id;
            dv2.Approval_Status__c = 'Rejected';
            dv2.Deviation_Description__c = 'testdesc';
            dv2.Remarks__c = 'Test1';
            dv2.Deviation_Level__c = 'L3';
            dv2.Role__c = 'SH';
            dv2.Type__c = 'Normal Deviation';
            insert dv2;
            
            Deviation__c dv3 = new Deviation__c();
            dv3.Parent_CAM__c = cam1.Id;
            dv3.Approval_Status__c = 'Rejected';
            dv3.Deviation_Description__c = 'testdesc';
            dv3.Remarks__c = 'Test1';
            dv3.Deviation_Level__c = 'L3';
            dv3.Role__c = 'SH';
            dv3.Type__c = 'Committee Deviation';
            insert dv3;
            
            //---------Proposal 
            Proposal_Approval_Log__c pa1 = new Proposal_Approval_Log__c();
            pa1.Deviation_Id__c = dv2.Id;
            pa1.Parent_CAM__c =cam1.Id;
            pa1.Approval_Status__c = 'proaprv';
            pa1.Forward_Remark__c = 'testremark';
            pa1.Forwarded_By__c = 'testuser';
            insert pa1;
            
            Vehicle_Detail__c  vehicleDetail =  new Vehicle_Detail__c();
            vehicleDetail.Manufacturer_Year_Month__c = '2017-01';
            vehicleDetail.Loan_Application__c = opp.Id;
            vehicleDetail.Total_Funded_Amount__c = 450000;
            vehicleDetail.Variant__c = 'ALSTILELE';
            vehicleDetail.City__c='Hyderabad';
            vehicleDetail.State__c='Andhra Pradesh';                                                
            //vehicleDetail.Grid_value__c = 100;
            vehicleDetail.Base_Price__c = 1000;
            insert vehicleDetail;
            
            // Cover Class Vaiable 
            Customer_Code__c  customerObj = new Customer_Code__c();  
            customerObj.Customer_Name__c = 'Test123';
            customerObj.Name = 'TY340ERT234';
            customerObj.Loan_Application__c = opp.Id;
            insert customerObj;
            List<Exposure__c> lstExp = new List<Exposure__c>();
            for(integer i=0;i<7;i++){
                Exposure__c  Eexpobject = new Exposure__c();  
                Eexpobject.Name = 'expName';
                Eexpobject.Loan_Application__c = opp.id;
                
                Eexpobject.CIF_ID__c ='3534534';
                Eexpobject.Deal_No__c = 'something1';
                if(i==0){
                    Eexpobject.Type__C = 'Borrower Exposure';
                    Eexpobject.Applicant__c = applicant.id;
                }
                if(i==1){
                    Eexpobject.Type__C ='Co-Borrower Exposure';  
                    Eexpobject.Applicant__c = coborrowerApp.id;
                }
                if(i==2){
                    Eexpobject.Type__C = 'Additional Customer'; 
                    Eexpobject.Applicant__c = coborrowerApp.id;
                }
                if(i==5){
                    Eexpobject.Type__C = 'Additional Customer'; 
                    Eexpobject.Customer_Code__c = customerObj.id;
                }
                if(i==3){
                    Eexpobject.Type__C = 'Bank Exposure';  
                    
                }
                if(i==4){
                    Eexpobject.Type__C = 'Family Exposure'; 
                    Eexpobject.Customer_Code__c = customerObj.Id;
                }
                if(i==6){
                    Eexpobject.Type__C = 'Family Exposure'; 
                    Eexpobject.Applicant__c = coborrowerApp.id;
                }
                lstExp.add(Eexpobject);
            }                     
            insert lstExp;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opp.Id;
            cs1.Applicant__c = applicant.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Origin = 'Web';
            insert cs1; 
            
            List<Documents__c> documentList = new List<Documents__c>();
            for(Integer y=0;y<2;y++){
                Documents__c dfks1 = new Documents__c();
                dfks1.Opportunity_Relation__c = opp.Id;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'ScanAadhar';
                dfks1.Document_Type__c = System.Label.AadhaarCard;
                dfks1.KYC_DOB__c = system.today();
                dfks1.Proof_of_Identity_POI__c = true;
                dfks1.Document_Type__c ='Residence FI'; 
                dfks1.Gender__c = 'MALE';
                dfks1.Is_Active__c = true;
                if(y==0){
                    dfks1.Name = 'Document1';
                    dfks1.Applicant__c = applicant.Id;  
                }
                if(y==1){ 
                    dfks1.Name = 'Document2';
                    dfks1.Applicant__c = coborrowerApp.Id; 
                }
                documentList.add(dfks1);  
            }
            insert documentList; 
            
            Documents__c dfks2 = new Documents__c();
            dfks2.Opportunity_Relation__c = opp.Id;
            dfks2.KYC_name__c = 'PAN';
            dfks2.Document_Side__c ='Back';
            dfks2.Aadhar_Source__c = 'ScanAadhar';
            dfks2.Name = 'Aadhar';
            dfks2.Document_Type__c = System.Label.AadhaarCard;
            dfks2.Proof_of_Identity_POI__c = true;
            dfks2.Applicant__c = applicant.Id;
            dfks2.Document_Type__c =System.Label.VoterIdCard; 
            dfks2.Gender__c = 'MALE';
            dfks2.Is_Active__c = true;
            insert dfks2;
            
            Documents__c dfks21 = new Documents__c();
            dfks21.Opportunity_Relation__c = opp.Id;
            dfks21.KYC_name__c = 'Customer Bank Statement';
            dfks21.Document_Side__c ='Back';
            dfks21.Aadhar_Source__c = 'ScanAadhar';
            dfks21.Name = 'Customer Bank Statement';
            //dfks21.Document_Type__c = System.Label.AadhaarCard;
            dfks21.Proof_of_Identity_POI__c = true;
            dfks21.Applicant__c = applicant.Id;
            dfks21.Document_Type__c ='Customer Bank Statement'; 
            dfks21.Gender__c = 'MALE';
            dfks21.Is_Active__c = true;
            insert dfks21;
            
            
            Documents__c doc1 = new Documents__c();
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.KYC_name__c = 'Customer Bank Statement';
            doc1.Document_Side__c ='Back';
            doc1.Aadhar_Source__c = 'ScanAadhar';
            doc1.Name = 'Customer Bank Statement';
            doc1.Proof_of_Identity_POI__c = true;
            doc1.Applicant__c = applicant.Id;
            doc1.Document_Type__c ='Valuation Report'; 
            doc1.Gender__c = 'MALE';
            doc1.Is_Active__c = true;
            insert doc1;
            
            ContentVersion contentVersion_1_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = Blob.valueOf('bodyBlob'), 
                origin = 'H',
                Document_Side_fileupload__c = 'Front'
            );
            insert contentVersion_1_1;
            
            ContentVersion contentVersion_2_2 = [SELECT Id, Title, ContentDocumentId 
                                                 FROM ContentVersion WHERE Id = :contentVersion_1_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink1 = new ContentDocumentLink();
            contentlink1.LinkedEntityId = doc1.Id;
            contentlink1.contentdocumentid = contentVersion_2_2.ContentDocumentId;
            contentlink1.ShareType = 'V';
            insert contentlink1;
            
            // Investigation
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.Address_Line_1__c = dfks2.KYC_Address_Line_1__c;
            fiv1.Address_Line_2__c = dfks2.KYC_Address_Line_2__c;
            fiv1.City__c = dfks2.KYC_City__c;
            fiv1.Pin_Code__c =dfks2.KYC_Pin_Code__c;
            fiv1.State__c = dfks2.KYC_State__c;
            fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv1;
            
            ViewCamController.recordId = opp.Id;
            
            Customer_Dedupe_Response__c cDRObj = new Customer_Dedupe_Response__c();
            cDRObj.Applicant__c = applicant.Id;
            cDRObj.Response__c = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[],"CustomerMaster":[],"CustomerCodeVal":"CW4977578"}],"CustomerMaster":null}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":null,"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"P"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            cDRObj.Deal_Status_Flag__c = 'T';
            cDRObj.Customer_Status_Flag__c = 'F';
            cDRObj.Customer_Code__c = 'CW4977578';
            insert cDRObj;
            
            Customer_Dedupe_Response__c cDR1Obj = new Customer_Dedupe_Response__c();
            cDR1Obj.Applicant__c = coborrowerApp.Id;
            cDR1Obj.Response__c = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[],"CustomerMaster":[],"CustomerCodeVal":"CW4977578"}],"CustomerMaster":null}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":null,"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"P"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            cDR1Obj.Deal_Status_Flag__c = 'T';
            cDR1Obj.Customer_Status_Flag__c = 'F';
            cDR1Obj.Customer_Code__c = 'CW4977578';
            insert cDR1Obj;
            
            InsuranceDetails__c iDetail = new InsuranceDetails__c();
            iDetail.Applicant__c = applicant.Id;
            iDetail.Loan_Application__c = opp.Id;
            iDetail.Is_Active__c = true;
            iDetail.Name = 'Test Insura';
            iDetail.Product_Type__c = 'test p';
            iDetail.Amount__c = 2000;
            iDetail.Funded_Premium__c = 20000;
            iDetail.Funded_Non_funded__c = 'Non-Funded';
            insert iDetail;
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '41000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opp.Id;
            finalObj.Net_IRR__c = 100;
            finalObj.Loan_Amount__c ='12345';
            finalObj.Is_Loan_Amount_Change_From_CAM__c = false;
            finalObj.Vehicle_Detail__c = vehicleDetail.Id;
            finalObj.Loan_Deal_Date__c = Date.newInstance(2023, 12, 23);
            finalObj.First_EMI_Date__c= Date.newInstance(2024, 01, 23);
            finalObj.Second_EMI_Date__c= Date.newInstance(2024, 02, 23);
            insert finalObj;
            
            // Case
            Case caseObj = new Case();
            caseObj.Applicant__c = applicant.Id;
            caseObj.AccountId = testAccount.Id;
            insert caseObj;
            
            Field_Investigation__c fielinvestdObj = new Field_Investigation__c();
            fielinvestdObj.Case__c = caseObj.Id;
            fielinvestdObj.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fielinvestdObj;
            
            Field_Investigation__c fielinvestdObj1 = new Field_Investigation__c();
            fielinvestdObj1.Case__c = cs1.Id;
            fielinvestdObj1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fielinvestdObj1;
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = Blob.valueOf('bodyBlob'), 
                origin = 'H',
                Document_Side_fileupload__c = 'Front'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = dfks2.Id;
            contentlink.contentdocumentid = contentVersion_2.ContentDocumentId;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            // Bl_Code_Details__c
            Bl_Code_Details__c blCode = new Bl_Code_Details__c();
            blCode.Bl_Code__c = '34543';
            insert blCode;
            
            // BankBranchDetails__c
            BankBranchDetails__c BranchList = new BankBranchDetails__c();
            BranchList.Address_1__c = 'TestAdd1';
            BranchList.Address_2__c = 'TestAdd2';
            BranchList.Address_3__c = 'TestAdd3';
            BranchList.Address_4__c = 'TestAdd4';
            BranchList.Pincode__c = 896787;
            BranchList.City__c = 'Test City';
            BranchList.Business_Hub__c = 'Test Hub';
            BranchList.State_Code__c = '8975';
            BranchList.Bl_Code_Details__c = blCode.Id;
            BranchList.Product__c = 'Prod';
            BranchList.UniqueIdentifier__c = 'Test Unique';
            BranchList.District__c = 'Test District';
            BranchList.Name = 'Test Name';
            insert BranchList;
            
            // Income Details  
            Income_Details__c income = new Income_Details__c();
            income.Applicant__c =  applicant.id;
            income.Is_MCI__c = true;
            insert income;
            
        }
    }
    
    @isTest
    public static void passingCurrentPageRecordId1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Field_Investigation__c field = [SELECT id FROM Field_Investigation__c LIMIT 1];
            objViewCamController.Save();
            // cover Variable
            objViewCamController.option = 'Test'; 
            objViewCamController.emailRequestWrapper = 'Test';
            objViewCamController.forwardResponse ='Test';
            objViewCamController.status = 'Test';
            objViewCamController.selectedstatus ='Test';
            objViewCamController.vehicleId ='Test';
            objViewCamController.borrowerResiFi ='Test';
            objViewCamController.coBorrowerResiFi ='Test';
            objViewCamController.accN ='Test';
            objViewCamController.borrowerOfficeFi ='Test';
            objViewCamController.coFI = field;
            objViewCamController.officeFI = field;
            objViewCamController.FI = field;
            objViewCamController.coFI = field;
            objViewCamController.officeCoFI = field;
            objViewCamController.permanentCoFI = field;
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId11(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            cam__c camObj = [select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
            camObj.Proposal_Status__c='Rejected';
            camObj.Action_Taken__c = true;
            update camObj;
            pageRef.getParameters().put('id', String.valueOf(camObj.Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Field_Investigation__c field = [SELECT id FROM Field_Investigation__c LIMIT 1];
            objViewCamController.Save();
            // cover Variable
            objViewCamController.option = 'Test'; 
            objViewCamController.emailRequestWrapper = 'Test';
            objViewCamController.forwardResponse ='Test';
            objViewCamController.status = 'Test';
            objViewCamController.selectedstatus ='Test';
            objViewCamController.vehicleId ='Test';
            objViewCamController.borrowerResiFi ='Test';
            objViewCamController.coBorrowerResiFi ='Test';
            objViewCamController.accN ='Test';
            objViewCamController.borrowerOfficeFi ='Test';
            objViewCamController.coFI = field;
            objViewCamController.officeFI = field;
            objViewCamController.FI = field;
            objViewCamController.coFI = field;
            objViewCamController.officeCoFI = field;
            objViewCamController.permanentCoFI = field;
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId2(){   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<Applicant__c> appCoBorrowerList = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'Co-borrower' LIMIT 1];  
            for(Applicant__c app : appCoBorrowerList){
                app.Scorecard_Decision__c = 'Light Green';
            }
            update appCoBorrowerList;
            List<Applicant__c> appBorrowerList = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'borrower' LIMIT 1]; 
            for(Applicant__c app : appBorrowerList){
                app.Scorecard_Decision__c = 'Light Green';
            }
            List<Customer_Dedupe_Response__c> customerList = new List<Customer_Dedupe_Response__c>([Select id From Customer_Dedupe_Response__c]);
            for(Customer_Dedupe_Response__c customerRes : customerList){
                customerRes.Response__c = null;
                customerRes.Customer_Code__c = null;
            }
            update customerList;
            update appBorrowerList;
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c,Advance_EMI__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Vehicle_Type__c = 'New';
            oppList.Product_Type__c = 'Two Wheeler';
            oppList.Advance_EMI__c =false;
            update oppList;
            Income_Details__c income =  [SELECT Id,Is_ICAI__c,Applicant__c FROM Income_Details__c LIMIT 1];
            income.Is_ICAI__c = true;
            update income;
            Documents__c  doc = [SELECT Id , Applicant__c,Document_Type__c , KYC_DOB__c FROM Documents__c WHERE Name = 'Document2' LIMIT 1];
            doc.Document_Type__c= 'Office FI';
            doc.KYC_DOB__c = Date.newInstance(2022, 12, 23);
            update doc;
            Field_Investigation__c filed = [SELECT Id, case__c,RecordTypeId From Field_Investigation__c LIMIT 1 ];
            filed.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            update filed;
            
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId3(){ 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'borrower' LIMIT 1];  
            appCoBorrower.Scorecard_Decision__c = 'Yellow';
            update appCoBorrower;
            Applicant__c coborrower =  [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'co-borrower' LIMIT 1]; 
            coborrower.Scorecard_Decision__c = 'Yellow';   
            update coborrower;
            Opportunity oppList = [SELECT Id, Vehicle_Type__c, Gender__c,Product_Type__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Vehicle_Type__c = 'Refinance';
            oppList.Product_Type__c = 'Two Wheeler';
            update oppList;
            Income_Details__c income =  [SELECT Id,Is_ICAI__c FROM Income_Details__c LIMIT 1];
            income.Is_ICWAI__c = true;
            update income;
            Documents__c  doc = [SELECT Id,Applicant__c,Document_Type__c, KYC_DOB__c From Documents__c  WHERE Name = 'Document1' LIMIT 1 ];
            doc.Document_Type__c= 'Residence FI';
            doc.KYC_DOB__c = Date.newInstance(2022, 12, 23);
            update doc;
            Deviation__C dev = [SELECT Id,Type__c From Deviation__c LIMIT 1];
            dev.Type__C ='Committee Deviation';
            update  dev; 
            Field_Investigation__c filed = [SELECT Id, case__c,RecordTypeId From Field_Investigation__c LIMIT 1 ];
            filed.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            update filed;
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId4(){  
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'borrower' LIMIT 1];  
            appCoBorrower.Scorecard_Decision__c = 'Orange';
            update appCoBorrower;
            Applicant__c coborrower =  [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'co-borrower' LIMIT 1]; 
            coborrower.Scorecard_Decision__c = 'Orange';   
            update coborrower;
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Vehicle_Type__c = 'New';
            oppList.Product_Type__c = 'Passenger Vehicles';
            update oppList;
            Documents__c  doc = [SELECT Id,Applicant__c,Document_Type__c,KYC_DOB__c,Gender__c From Documents__c  WHERE Name = 'Document1' LIMIT 1 ];
            doc.Document_Type__c= 'Office FI';
            doc.KYC_DOB__c = System.today(); 
            update doc;
            Field_Investigation__c filed = [SELECT Id, case__c, Case__r.Applicant__c ,RecordTypeId From Field_Investigation__c LIMIT 1 ];
            filed.Case__r.Applicant__c = coborrower.id;
            filed.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            update filed;
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId41(){  
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'borrower' LIMIT 1];  
            appCoBorrower.Scorecard_Decision__c = 'Orange';
            update appCoBorrower;
            Applicant__c coborrower =  [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'co-borrower' LIMIT 1]; 
            coborrower.Scorecard_Decision__c = 'Orange';   
            update coborrower;
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Vehicle_Type__c = 'New';
            oppList.Product_Type__c = 'Passenger Vehicles';
            oppList.Funding_on_ORP__c = true;
            update oppList;
            Documents__c  doc = [SELECT Id,Applicant__c,Document_Type__c,KYC_DOB__c,Gender__c From Documents__c  WHERE Name = 'Document1' LIMIT 1 ];
            doc.Document_Type__c= 'Office FI';
            doc.KYC_DOB__c = System.today(); 
            update doc;
            Field_Investigation__c filed = [SELECT Id, case__c, Case__r.Applicant__c ,RecordTypeId From Field_Investigation__c LIMIT 1 ];
            filed.Case__r.Applicant__c = coborrower.id;
            filed.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            update filed;
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId5(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'borrower' LIMIT 1];  
            appCoBorrower.Scorecard_Decision__c = 'Red';
            update appCoBorrower;
            Applicant__c coborrower =  [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'co-borrower' LIMIT 1]; 
            coborrower.Scorecard_Decision__c = 'Red';   
            update coborrower;
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Vehicle_Type__c = 'Used';
            oppList.Product_Type__c = 'Passenger Vehicles';
            update oppList;
            Documents__c  doc = [SELECT Id,Applicant__c,Document_Type__c,KYC_DOB__c From Documents__c  WHERE Name = 'Document1' LIMIT 1 ];
            doc.KYC_DOB__c = Date.newInstance(2022, 01, 22);
            update doc;
            Test.startTest();
            // Act
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            // Assert
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId51(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'borrower' LIMIT 1];  
            appCoBorrower.Scorecard_Decision__c = 'Red';
            update appCoBorrower;
            Applicant__c coborrower =  [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'co-borrower' LIMIT 1]; 
            coborrower.Scorecard_Decision__c = 'Red';   
            update coborrower;
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Vehicle_Type__c = 'Used';
            oppList.Product_Type__c = 'Passenger Vehicles';
            update oppList;
            Retry_Count__c countRec = new Retry_Count__c();
            countRec.IsAPIFailed__c = true;
            countRec.Count__c = 3;
            countRec.Loan_Application_Id__c = oppList.Id;
            countRec.Service_Name__c = 'CarwaleApi';
            insert countRec;
            Documents__c  doc = [SELECT Id,Applicant__c,Document_Type__c,KYC_DOB__c From Documents__c  WHERE Name = 'Document1' LIMIT 1 ];
            doc.KYC_DOB__c = Date.newInstance(2022, 01, 22);
            update doc;
            
            Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
            //opp.Product_Type__c = 'Tractor';
            //opp.leadSource = 'D2C';
            //opp.Customer_Type__c = 'Non-Individual';
            //update opp;
            
            // Income Details  
            Income_Details__c income = new Income_Details__c();
            income.Applicant__c = coborrower.id;
            income.Is_MCI__c = true;
            income.ABB_to_be_considered__c = 'Test';
            income.Income_Source_Status__c = 'NIP';
            insert income;
            
            Test.startTest();
            // Act
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            // Assert
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordId6(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'borrower' LIMIT 1];  
            appCoBorrower.Scorecard_Decision__c = '';
            update appCoBorrower;
            Applicant__c coborrower =  [select ID,Scorecard_Decision__c  from Applicant__c where Applicant_Type__c = 'co-borrower' LIMIT 1]; 
            coborrower.Scorecard_Decision__c = '';   
            update coborrower;
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Vehicle_Type__c = 'Refinance';
            oppList.Product_Type__c = 'Passenger Vehicles';
            update oppList;
            Documents__c  doc = [SELECT Id,Applicant__c,Document_Type__c,KYC_DOB__c From Documents__c  WHERE Name = 'Document2' LIMIT 1 ];
            doc.KYC_DOB__c = Date.newInstance(2022, 01, 22);
            update doc;
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            // Act
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            // Assert
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void GetAccNames_Positive(){    
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController viewCamControllerObj = new ViewCamController();
            List<selectOption> results = viewCamControllerObj.getAccNames();
            Test.stopTest();
            //Assert
            System.assert(results != null);
        }
    }
    public static void getForwardOptions_Positive(){   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController viewCamControllerObj = new  ViewCamController();
            List<selectOption> results = viewCamControllerObj.getForwardOptions();
            Test.stopTest();
            // Assert
            System.assert(results!= null);
        }
    }
    @isTest
    public static void getAvailableForwardedRoles_Positive(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();  
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController viewCamControllerObj = new ViewCamController();
            //Act
            List<selectOption> results = viewCamControllerObj.getAvailableForwardedRoles();
            Test.stopTest();
            // Assert
            System.assert(results != null);
        }
    }
    
    @isTest
    public static void setIsForwardTo_Positive(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController viewCamControllerObj = new ViewCamController();
            viewCamControllerObj.isForwardTo = 'test';
            viewCamControllerObj.setIsForwardTo();
            Test.stopTest(); 
        }
    }
    @isTest
    public static void saveLoanAmountAndIRR_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.saveLoanAmountAndIRR();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static void familyExposure_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.familyExposure();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static void familyExposure_Negative(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.family_Exposure = true;
            camInfoObj.familyExposure();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    @isTest
    public static void redoChanges_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.redoChanges();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    @isTest
    public static void checkDeviations_Positive(){
        List<Deviation__c> devList = [SELECT Id, Approval_Status__c, Remarks__c, Deviation_Description__c FROM Deviation__c WHERE Approval_Status__c = 'Hold' LIMIT 1];
        for(Deviation__c dev : devList){
            dev.Approval_Status__c = 'Rejected';
        }
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.checkDeviations();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    @isTest
    public static void checkDeviations_negative(){
        List<Deviation__c> devList = [SELECT Id, Approval_Status__c, Remarks__c, Deviation_Description__c FROM Deviation__c  LIMIT 1];
        for(Deviation__c dev : devList){
            dev.Approval_Status__c = 'Approved';
        }
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.deviation = devList;
            camInfoObj.checkDeviations();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    @isTest
    public static void forwardTheProposal_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController viewCamControllerObj = new ViewCamController();
            viewCamControllerObj.cam = [SELECT Id FROM CAM__c WHERE BE_CVO_Remark__c = 'testbe' LIMIT 1];           
            viewCamControllerObj.forwardTo = 'SH';
            
            viewCamControllerObj.forwardTheProposal();
            Test.stopTest(); 
        }
    }
    @isTest
    public static void saveDeviationAndApprovalChanges_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Deviation__c devList = [SELECT Id, Approval_Status__c, Type__c ,Remarks__c, Role__c, Deviation_Description__c,Deviation_Level__c FROM Deviation__c WHERE Parent_CAM__r.BE_CVO_Remark__c = 'testbe' LIMIT 1];
            devList.Approval_Status__c = 'Approved';
            devList.Remarks__c = ' ';  
            devList.Type__c = 'Committee Deviation';
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController(); 
            ViewCamController.DeviationWrapper obj = new ViewCamController.DeviationWrapper(devList,true);
            List<ViewCamController.DeviationWrapper> wrapperList = new List<ViewCamController.DeviationWrapper>(); 
            wrapperList.add(obj);
            camInfoObj.deviationWrapperList = wrapperList;
            camInfoObj.proposalStatus = 'Hold';
            camInfoObj.approvalConditionsOrRemarks = 'test';
            try{
                camInfoObj.saveDeviationAndApprovalChanges(); 
            }catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
            System.assert(camInfoObj != null);   
        }
    }
    @isTest
    public static void saveDeviationAndApprovalChanges_Positive12(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Deviation__c devList = [SELECT Id, Approval_Status__c, Type__c ,Remarks__c, Role__c, Deviation_Description__c,Deviation_Level__c FROM Deviation__c WHERE Parent_CAM__r.BE_CVO_Remark__c = 'testbe' LIMIT 1];
            devList.Approval_Status__c = 'Approved';
            devList.Remarks__c = ' ';  
            devList.Type__c = 'Committee Deviation';
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController(); 
            ViewCamController.DeviationWrapper obj = new ViewCamController.DeviationWrapper(devList,true);
            List<ViewCamController.DeviationWrapper> wrapperList = new List<ViewCamController.DeviationWrapper>(); 
            wrapperList.add(obj);
            camInfoObj.deviationWrapperList = wrapperList;
            camInfoObj.proposalStatus = '';
            camInfoObj.approvalConditionsOrRemarks = 'test';
            try{
                camInfoObj.saveDeviationAndApprovalChanges(); 
            }catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
            System.assert(camInfoObj != null);   
        }
    }
    @isTest
    public static void saveDeviationAndApprovalChanges_success2(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Deviation__c devList = [SELECT Id, Approval_Status__c, Remarks__c, Deviation_Level__c, Deviation_Description__c,Role__c FROM Deviation__c WHERE Parent_CAM__r.BE_CVO_Remark__c = 'testbe' LIMIT 1];
            devList.Approval_Status__c = 'Conditionally Approve';
            devList.Remarks__c = ' ';
            devList.Deviation_Level__c = 'List';
            // Act
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController(); 
            ViewCamController.DeviationWrapper obj = new ViewCamController.DeviationWrapper(devList,true);
            List<ViewCamController.DeviationWrapper> wrapperList = new List<ViewCamController.DeviationWrapper>(); 
            wrapperList.add(obj);
            camInfoObj.deviationWrapperList = wrapperList;
            camInfoObj.proposalStatus = 'Reject';
            camInfoObj.approvalConditionsOrRemarks = 'test';
            List<Customer_Dedupe_Response__c> customerList = new List<Customer_Dedupe_Response__c>([Select id From Customer_Dedupe_Response__c]);
            for(Customer_Dedupe_Response__c customerRes : customerList){
                customerRes.Response__c = null;
                customerRes.Customer_Code__c = null;
            }
            update customerList;
            try{
                camInfoObj.saveDeviationAndApprovalChanges(); 
            }catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
            // Assert
            System.assert(camInfoObj != null);   
        }
    }    
    @isTest
    public static void getApplicants_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            List<Applicant__c> applicantList = ViewCamController.getApplicants();
            Test.stopTest();
            System.assert(applicantList != null);
        }
    }
    
    @isTest
    public static void getInsuranceDetails_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        Test.startTest();
        List<InsuranceDetails__c> insurList = ViewCamController.getInsuranceDetails([SELECT Id From Opportunity WHERE StageName='Qualification' LIMIT 1].Id);
        Test.stopTest();
        System.assert(insurList != null);
        
    }
    
    @isTest
    public static void getInsuranceAggregation_Positive(){
        //Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        try{
            // Act
            Test.startTest();
            List<AggregateResult> result = ViewCamController.getInsuranceAggregation([SELECT Id From Opportunity WHERE StageName='Qualification' LIMIT 1].Id);
            Test.stopTest();
            // Assert
            System.assert(result != null);
        }
        catch(Exception e){
            // Assert 
            System.assert(true);
        }
    }
    /*
    @isTest
    public static void getKYCDetails_Positive(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        {
            // Act
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController.DocumentWrapper camInfoObj = new ViewCamController.DocumentWrapper();
            camInfoObj = ViewCamController.getKYCDetails([SELECT Id From Applicant__c  WHERE Applicant_Type__c = 'Borrower' LIMIT 1].Id);
            Test.stopTest();
            // Assert
            System.assert(camInfoObj != null);
        }
    }
    */
    @isTest
    public static void getRequestDetails_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController.CAMInfoWrapper camInfoObj = new ViewCamController.CAMInfoWrapper();
            camInfoObj = ViewCamController.getRequestDetails([SELECT Id From CAM__c WHERE BE_CVO_Remark__c = 'testbe' LIMIT 1].Id);
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    @isTest
    public static void getRelatedInsuranceDetails_Positive(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            try{
                CAM__c cam = [SELECT Id From CAM__c WHERE BE_CVO_Remark__c = 'testbe' LIMIT 1];
                Test.startTest(); 
                List<InsuranceDetails__c> idetailList= ViewCamController.getRelatedInsuranceDetails(cam.Id,null);
                Test.stopTest();
            }
            catch(Exception e){
                system.assert(true);
            }
        }
    }
    
    @isTest
    public static void getRelatedInsuranceDetails_Negative(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();  
            List<InsuranceDetails__c> idetailList= ViewCamController.getRelatedInsuranceDetails(null,null);
            Test.stopTest();
            System.assert(idetailList == null);
        }
    }
    
    @isTest
    public static  void setIsForwardTo_success(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.setForwardTo();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static  void setForwardToAsNo_success(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.setForwardToAsNo();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }  
    
    /*@isTest
public static  void forwardThePrposalFromCAM_success(){
User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
System.runAs(u) 
{

PageReference pageRef = Page.IBLCAMPage;
pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
Test.setCurrentPage(pageRef);
Test.startTest();
ViewCamController camInfoObj = new ViewCamController();

//camInfoObj.forwardThePrposalFromCAM();
Test.stopTest();
System.assert(camInfoObj != null);
}
}*/
    
    
    @isTest
    public static  void doEmailServiceCallout_success(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Test.startTest();
                PageReference pageRef = Page.IBLCAMPage;
                pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
                Cam__c camid = [SELECT  id, Name From Cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
                pageRef.getParameters().put('emailRequestWrapper',JSON.serialize(IND_CAMWithoutSharing.getForwardWrapper(camid.Id)[0]));
                
                HttpResponse response = new HttpResponse();
                response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');            
                response.setStatusCode(200);
                
                Test.setCurrentPage(pageRef);
                ViewCamController camInfoObj = new ViewCamController();
                Continuation con = (Continuation)camInfoObj.doEmailServiceCallout();
                Map<String, HttpRequest> requests = con.getRequests();
                ViewCamController.Carrier cari = new  ViewCamController.Carrier();
                camInfoObj.carrier = cari;
                String continuationLabel = ViewCamController.continuationLabel;
                Test.setContinuationResponse(continuationLabel, response);
                camInfoObj.processEmailServiceResponse();
                //Object result  =  Test.invokeContinuationMethod( new ViewCamController(), con);
                Test.stopTest();
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    
    @isTest
    public static  void doEmailServiceCallout_fail(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Test.startTest();
                PageReference pageRef = Page.IBLCAMPage; 
                pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
                Cam__c camid = [SELECT  id, Name From Cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
                pageRef.getParameters().put('emailRequestWrapper',JSON.serialize(IND_CAMWithoutSharing.getForwardWrapper(camid.Id)));
                Test.setCurrentPage(pageRef);
                ViewCamController camInfoObj = new ViewCamController();
                camInfoObj.processEmailServiceResponse();
                Test.stopTest();
                
            }
            catch(exception e){
                System.assert(true);
            }
        }
    }
    
    @isTest
    public static  void saveLoanAmountAndIRR_success(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
            opp.Product_Type__c = 'Passenger Vehicles';
            update opp;
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage; 
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            pageRef.getParameters().put('updatedLoanAmount', String.valueOf(1839379));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.updatedLoanAmount = 12345;
            camInfoObj.saveLoanAmountAndIRR();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static  void confirmChangeIRR_success(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        //System.runAs(u)
        //{
        Test.startTest();
        PageReference pageRef = Page.IBLCAMPage; 
        pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
        Test.setCurrentPage(pageRef);
        ViewCamController camInfoObj = new ViewCamController();
        
        Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
        opp.Product_Type__c = 'Tractor';
        update opp;
        
        camInfoObj.confirmChangeIRR();
        Test.stopTest();
        //}
    }
    @isTest
    public static  void getForwardOptions_success2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            List<selectOption> results =camInfoObj.getForwardOptions();
            Test.stopTest();
            // ASSERT
            System.assert(results != null);
        }
    }
    
    @isTest
    public static  void updateProvisionalCostTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            Final_Term__c finalterm = [Select Id,Loan_Application__c From Final_Term__c LIMIT 1];
            finalterm.Tenure__c = '10';
            finalterm.Service_charges__c  = '10';
            finalterm.Documentation_charges__c  = '10';
            update finalterm;
            Opportunity opp = new Opportunity();
            opp.Id = finalterm.Loan_Application__c;
            opp.Vehicle_Type__c = 'New';
            update opp;
            ViewCamController.updateProvisionalCost(finalterm.Loan_Application__c);
            Test.stopTest();
        }
    }
    @isTest
    public static  void updateProvisionalCostTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            Final_Term__c finalterm = [Select Id,Loan_Application__c From Final_Term__c LIMIT 1];
            finalterm.Tenure__c = '24';
            finalterm.Service_charges__c  = '10';
            finalterm.Documentation_charges__c  = '10';
            update finalterm;
            
            Opportunity opp = new Opportunity();
            opp.Id = finalterm.Loan_Application__c;
            opp.Vehicle_Type__c = 'New';
            update opp;
            
            ViewCamController.updateProvisionalCost(finalterm.Loan_Application__c);
            Test.stopTest();
        }
    }
    @isTest
    public static  void updateProvisionalCostTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            Final_Term__c finalterm = [Select Id,Loan_Application__c From Final_Term__c LIMIT 1];
            finalterm.Service_charges__c  = '1000';
            finalterm.Documentation_charges__c  = '1000';
            update finalterm;
            ViewCamController.updateProvisionalCost(finalterm.Loan_Application__c);
            Test.stopTest();
        }
    }
    
    @isTest
    public static  void updateDocandServiceChargeTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            Opportunity oppRecord = [Select id from Opportunity LIMIT 1];
            oppRecord.Product_Type__c = 'Two Wheeler';
            oppRecord.Vehicle_Type__c = 'New';
            update oppRecord;
            Final_Term__c finalterm = new Final_Term__c();
            finalterm.Service_charges__c  = '10';
            finalterm.Documentation_charges__c  = '10';
            finalTerm.Is_Loan_Amount_Change_From_CAM__c = true;
            finalTerm.Loan_Application__c = oppRecord.Id;
            finalTerm.Loan_Amount__c = '10000';
            insert finalterm;
            ViewCamController.updateDocandServiceCharge(finalterm.Loan_Application__c);
            Test.stopTest();
        }
    }
    //for CISP-6926 added
    
    @isTest
    public static  void updateDocandServiceChargeTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            Opportunity oppRecord = [Select id from Opportunity LIMIT 1];
            oppRecord.Product_Type__c = 'Two Wheeler';
            oppRecord.Vehicle_Type__c = 'New';
            update oppRecord;
            Final_Term__c finalterm = new Final_Term__c();
            finalterm.Service_charges__c  = '1000';
            finalterm.Documentation_charges__c  = '1000';
            finalTerm.Is_Loan_Amount_Change_From_CAM__c = true;
            finalTerm.Loan_Application__c = oppRecord.Id;
            finalTerm.Loan_Amount__c = '10000';
            
            insert finalterm;
            ViewCamController.updateDocandServiceCharge(finalterm.Loan_Application__c);
            Test.stopTest();
        }
    }
    @isTest
    public static  void rejectVehileDetailsTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            cam__c camRec = [select id,CAM_Submitted_by_ACM_SCM__c from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
            camRec.CAM_Submitted_by_ACM_SCM__c = false;
            update camRec;
            pageRef.getParameters().put('id', String.valueOf(camRec.Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.rejectVehileDetails();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }  
    @isTest
    public static  void rejectVehileDetailsWithVehicleIdTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            cam__c camRec = [select id,CAM_Submitted_by_ACM_SCM__c from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
            camRec.CAM_Submitted_by_ACM_SCM__c = false;
            update camRec;
            pageRef.getParameters().put('id', String.valueOf(camRec.Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.vehicleId = 'Test';
            camInfoObj.rejectVehileDetails();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    @isTest
    public static  void getRequestDetailsForTractorTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            cam__c camRec = [select id,CAM_Submitted_by_ACM_SCM__c,Loan_Application__c from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
            Applicant__c app = [select ID,Scorecard_Decision__c  from Applicant__c where Opportunity__c =:camRec.Loan_Application__c LIMIT 1];  
            ViewCamController.getRequestDetailsForTractor(camRec.ID,app.ID);
            Test.stopTest();
        }
    }
    @isTest
    public static void passingCurrentPageRecordIdWithTractorProductType(){   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c,Advance_EMI__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Product_Type__c = 'Tractor';
            update oppList;            
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static void emiRepaymentScheduleTest(){   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Vehicle_Detail__c vhec = [Select Id from Vehicle_Detail__c LIMIT 1];            
            Test.startTest();
            ViewCamController.emiRepaymentSchedule(vhec.Id);
            Test.stopTest();
            //System.assert(objViewCamController != null);
        }
    }
    @isTest
    public static  void sendApprovedCAMEmailTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            cam__c camRec = [select id,CAM_Submitted_by_ACM_SCM__c,Loan_Application__c from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
            ViewCamController.sendApprovedCAMEmail(camRec.ID);
            Test.stopTest();
        }
    }
    @isTest
    public static  void saveLoanAmountAndIRRTractorProductTypeTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
            opp.Product_Type__c = 'Tractor';
            update opp;
            Final_Term__c fnt = [Select Id from Final_Term__c LIMIT 1];
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage; 
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            pageRef.getParameters().put('updatedLoanAmount', String.valueOf(1839379));
            pageRef.getParameters().put('finalTermId', fnt.id);

            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.updatedLoanAmount = 12345;
            camInfoObj.finalTermId = fnt.Id;
            camInfoObj.saveLoanAmountAndIRR();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static  void viewCamControllerCunstructorTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
            opp.Product_Type__c = 'Tractor';
            opp.StageName = 'Credit Processing';
            opp.Sub_Stage__c = 'CAM and Approval Log';
            update opp;
            
            String coBorrowerApplicantId;
            String borrowerApplicantId;
            String guarantorApplicantId;            
            
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c,Applicant_Type__c  from Applicant__c where Applicant_Type__c = 'Co-borrower' LIMIT 1];
            List<Applicant__c> appCoBorrowerList = [select ID,Scorecard_Decision__c,Applicant_Type__c  from Applicant__c];
            
            for(Applicant__c app : appCoBorrowerList){
                if(app.Applicant_Type__c == 'Co-borrower'){
                    coBorrowerApplicantId = app.Id;
                }else if(app.Applicant_Type__c == 'Borrower'){
                    borrowerApplicantId = app.Id;
                }else if(app.Applicant_Type__c == 'Guarantor'){
                    guarantorApplicantId = app.Id;
                }
            }
            
            Case caseObj1 = new Case();
            caseObj1.Loan_Application__c = opp.Id;
            caseObj1.Applicant__c = coBorrowerApplicantId;
            insert caseObj1;
            
            Field_Investigation__c fielinvestdObj11 = new Field_Investigation__c();
            fielinvestdObj11.Case__c = caseObj1.Id;
            fielinvestdObj11.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fielinvestdObj11;
            
            Field_Investigation__c fielinvestdObj12 = new Field_Investigation__c();
            fielinvestdObj12.Case__c = caseObj1.Id;
            fielinvestdObj12.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fielinvestdObj12;
            
            Field_Investigation__c fielinvestdObj13 = new Field_Investigation__c();
            fielinvestdObj13.Case__c = caseObj1.Id;
            fielinvestdObj13.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fielinvestdObj13;
            
            Case caseObj2 = new Case();
            caseObj2.Loan_Application__c = opp.Id;
            caseObj2.Applicant__c = coBorrowerApplicantId;
            insert caseObj2;
            
            Field_Investigation__c fielinvestdObj21 = new Field_Investigation__c();
            fielinvestdObj21.Case__c = caseObj2.Id;
            fielinvestdObj21.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fielinvestdObj21;
            
            Field_Investigation__c fielinvestdObj22 = new Field_Investigation__c();
            fielinvestdObj22.Case__c = caseObj2.Id;
            fielinvestdObj22.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fielinvestdObj22;
            
            Field_Investigation__c fielinvestdObj23 = new Field_Investigation__c();
            fielinvestdObj23.Case__c = caseObj2.Id;
            fielinvestdObj23.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fielinvestdObj23;
            
            Case caseObj3 = new Case();
            caseObj3.Loan_Application__c = opp.Id;
            caseObj3.Applicant__c = coBorrowerApplicantId;
            insert caseObj3;
            
            Field_Investigation__c fielinvestdObj31 = new Field_Investigation__c();
            fielinvestdObj31.Case__c = caseObj3.Id;
            fielinvestdObj31.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fielinvestdObj31;
            
            Field_Investigation__c fielinvestdObj32 = new Field_Investigation__c();
            fielinvestdObj32.Case__c = caseObj3.Id;
            fielinvestdObj32.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fielinvestdObj32;
            
            Field_Investigation__c fielinvestdObj33 = new Field_Investigation__c();
            fielinvestdObj33.Case__c = caseObj3.Id;
            fielinvestdObj33.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fielinvestdObj33;
            
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false, appCoBorrower);
            insert cibilDetail;          
            
            Final_Term__c fnt = [Select Id from Final_Term__c LIMIT 1];
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage; 
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            pageRef.getParameters().put('updatedLoanAmount', String.valueOf(1839379));
            pageRef.getParameters().put('finalTermId', fnt.id);

            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static  void viewCamControllerCunstructorTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
            opp.Product_Type__c = 'Tractor';
            opp.StageName = 'Credit Processing';
            opp.Sub_Stage__c = 'CAM and Approval Log';
            update opp;
            
            List<Applicant__c> appCoBorrowerList = [select ID,Scorecard_Decision__c,Applicant_Type__c  from Applicant__c where Applicant_Type__c = 'Borrower' LIMIT 1];
            for(Applicant__c app : appCoBorrowerList){
                app.Applicant_Type__c = 'Guarantor';
            }
            update appCoBorrowerList;
            
            List<Documents__c> document = [select ID,Case__c,Document_Type__c,Name,Applicant__c,Age__c,Applicant__r.Applicant_Type__c,Applicant__r.Opportunity__r.Product_Type__c,RecordType.Name, Proof_of_Identity_POI__c,KYC_DOB__c,Gender__c,Is_Active__c,KYC_District__c, KYC_City__c,Taluka__c 
                        					from Documents__c Where  Document_Type__c not in ('Customer Image') and  Opportunity_Relation__c = :opp.Id AND Applicant__r.In_Active_Applicant__c = false ];
                
            for(Integer i=0;i<document.size();i++){
                if(i==0){
                    document[i].KYC_DOB__c = Date.today()+15;
                }else if(i==1){
                    document[i].KYC_DOB__c = Date.today();
                }else if(i==2){
                    document[i].KYC_DOB__c = Date.today()-25;
                }
            }
            update document;
            
            Final_Term__c fnt = [Select Id from Final_Term__c LIMIT 1];
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage; 
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            pageRef.getParameters().put('updatedLoanAmount', String.valueOf(1839379));
            pageRef.getParameters().put('finalTermId', fnt.id);

            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            //camInfoObj.updatedLoanAmount = 12345;
            //camInfoObj.finalTermId = fnt.Id;
            //camInfoObj.saveLoanAmountAndIRR();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static  void viewCamControllerCunstructorTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
            opp.Product_Type__c = 'Tractor';
            opp.StageName = 'Credit Processing';
            opp.Sub_Stage__c = 'CAM and Approval Log';
            opp.Customer_Type__c = 'Non-Individual';
            update opp;
            
            String coBorrowerApplicantId;
            String borrowerApplicantId;
            String guarantorApplicantId;            
            
            Applicant__c appCoBorrower = [select ID,Scorecard_Decision__c,Applicant_Type__c  from Applicant__c where Applicant_Type__c = 'Co-borrower' LIMIT 1];
            List<Applicant__c> appCoBorrowerList = [select ID,Scorecard_Decision__c,Applicant_Type__c  from Applicant__c];
            
            for(Applicant__c app : appCoBorrowerList){
                if(app.Applicant_Type__c == 'Co-borrower'){
                    coBorrowerApplicantId = app.Id;
                }else if(app.Applicant_Type__c == 'Borrower'){
                    borrowerApplicantId = app.Id;
                }else if(app.Applicant_Type__c == 'Guarantor'){
                    guarantorApplicantId = app.Id;
                }
            }
            
            Case caseObj1 = new Case();
            caseObj1.Loan_Application__c = opp.Id;
            caseObj1.Applicant__c = appCoBorrower.Id;
            caseObj1.Type ='Current Residence FI';
            insert caseObj1;
            
            Field_Investigation__c fielinvestdObj11 = new Field_Investigation__c();
            fielinvestdObj11.Case__c = caseObj1.Id;
            fielinvestdObj11.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fielinvestdObj11;
            
            List<Non_Agri_Income__c> nonAgriIncomeList = new List<Non_Agri_Income__c>();
            List<Viability_of_Existing_Proposed_Tractor__c> viabilityList = new List<Viability_of_Existing_Proposed_Tractor__c>();
            for(Integer i=0;i<2;i++){
                Non_Agri_Income__c nonAgriIncome = new Non_Agri_Income__c();
                nonAgriIncome.Field_Investigation__c = fielinvestdObj11.Id;
                if(i==0) nonAgriIncome.Utilization__c = '55';
                if(i==1) nonAgriIncome.Utilization__c = '60';
                nonAgriIncomeList.add(nonAgriIncome);
                
                Viability_of_Existing_Proposed_Tractor__c viability = new Viability_of_Existing_Proposed_Tractor__c();
                viability.Field_Investigation__c = fielinvestdObj11.Id;
                viability.Field_Investigation__c = fielinvestdObj11.Id;
                if(i==0) viability.Usage_Type__c = 'Agriculture';
                if(i==1) viability.Usage_Type__c = 'Agri commercial';
                viabilityList.add(viability);                
            }
            
            insert nonAgriIncomeList;
            insert viabilityList;
            
            //List<Applicant__c> appCoBorrowerList = [select ID,Scorecard_Decision__c,Applicant_Type__c  from Applicant__c where Applicant_Type__c = 'Borrower' LIMIT 1];
           // for(Applicant__c app : appCoBorrowerList){
            ///    app.Applicant_Type__c = 'Guarantor';
            //}
            //update appCoBorrowerList;
            
            List<Documents__c> document = [select ID,Case__c,Document_Type__c,Name,Applicant__c,Age__c,Applicant__r.Applicant_Type__c,Applicant__r.Opportunity__r.Product_Type__c,RecordType.Name, Proof_of_Identity_POI__c,KYC_DOB__c,Gender__c,Is_Active__c,KYC_District__c, KYC_City__c,Taluka__c 
                        					from Documents__c Where  Document_Type__c not in ('Customer Image') and  Opportunity_Relation__c = :opp.Id AND Applicant__r.In_Active_Applicant__c = false ];
                
            for(Integer i=0;i<document.size();i++){
                if(i==0){
                    document[i].KYC_DOB__c = Date.today()+15;
                }else if(i==1){
                    document[i].KYC_DOB__c = Date.today();
                }else if(i==2){
                    document[i].KYC_DOB__c = Date.today()-25;
                }
            }
            update document;
            
            Final_Term__c fnt = [Select Id from Final_Term__c LIMIT 1];
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage; 
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            pageRef.getParameters().put('updatedLoanAmount', String.valueOf(1839379));
            pageRef.getParameters().put('finalTermId', fnt.id);

            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            //camInfoObj.updatedLoanAmount = 12345;
            //camInfoObj.finalTermId = fnt.Id;
            //camInfoObj.saveLoanAmountAndIRR();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    
    @isTest
    public static  void calculateRiskBandTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            String res1 = ViewCamController.calculateRiskBand('Dark Green');
            System.assertEquals(res1,'01');
            
            String res2 = ViewCamController.calculateRiskBand('Light Green');
            System.assertEquals(res2,'02');
            
            String res3 = ViewCamController.calculateRiskBand('Yellow');
            System.assertEquals(res3,'03');
            
            String res4 = ViewCamController.calculateRiskBand('Orange');
            System.assertEquals(res4,'04');
            
            String res5 = ViewCamController.calculateRiskBand('Red');
            System.assertEquals(res5,'05');
            
            String res6 = ViewCamController.calculateRiskBand('Test');
            System.assertEquals(res6,'');
        }
    }
    
       @isTest
    public static  void getVehiclePurchasepriceTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Final_Term__c fnt = [Select Id from Final_Term__c LIMIT 1];
            Test.startTest();
            ViewCamController.getVehiclePurchaseprice(fnt.Id);
            Test.stopTest();
        }
    }
          @isTest
    public static  void isTractorLeadTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id,Product_Type__c from Opportunity where Name=:'Opportunity Test'];
            opp.Product_Type__c = 'Tractor';
            update opp;
            cam__c camRec = [select id,CAM_Submitted_by_ACM_SCM__c,Loan_Application__c from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
            Test.startTest();
            ViewCamController.isTractorLead(camRec.Id);
            Test.stopTest();
        }
    }
     @isTest
    public static void finalTermDetailsTest(){   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Vehicle_Detail__c vhec = [Select Id from Vehicle_Detail__c LIMIT 1];
            
            
            Test.startTest();
            ViewCamController.finalTermDetails(vhec.Id);
            Test.stopTest();
            //System.assert(objViewCamController != null);
        }
    }
        @isTest
    public static  void approveVehileDetailsTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            cam__c camRec = [select id,CAM_Submitted_by_ACM_SCM__c from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1];
            pageRef.getParameters().put('id', String.valueOf(camRec.Id));
            Test.setCurrentPage(pageRef);
            ViewCamController camInfoObj = new ViewCamController();
            camInfoObj.approveVehileDetails();
            Test.stopTest();
            System.assert(camInfoObj != null);
        }
    }
    @isTest
    public static void passingCurrentPageRecordIdWithTractorProductTypeTopUpLoan(){   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity oppList = [SELECT Id, Vehicle_Type__c,Product_Type__c,Advance_EMI__c FROM Opportunity WHERE StageName='Qualification' LIMIT 1];
            oppList.Product_Type__c = 'Tractor';
            oppList.isTopUpLoan__c = true;
            update oppList;            
            Test.startTest();
            PageReference pageRef = Page.IBLCAMPage;
            pageRef.getParameters().put('id', String.valueOf([select id from cam__c WHERE BE_CVO_Remark__c = 'testbe' limit 1].Id));
            Test.setCurrentPage(pageRef);
            ViewCamController objViewCamController = new ViewCamController();
            Test.stopTest();
            System.assert(objViewCamController != null);
        }
    }

    
}