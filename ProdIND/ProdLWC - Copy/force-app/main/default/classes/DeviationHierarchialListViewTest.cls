@isTest
public class DeviationHierarchialListViewTest {
    @testSetup
    static void testSetup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u2 = new User(
            ProfileId = p2.Id,
            IsActive = true,
            Username = 'testtermsconditions1234423@kaplan.com',
            Alias = 'batman',
            Maker_Id__c='14',
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
            
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = testAccount.Id,  TeamMemberRole = 'SH', UserId = U.id,  Level__c ='L4;L1;L2');
            insert accTeam;
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = parentAccount.Id,  TeamMemberRole = 'PNH', UserId = U.id,  Level__c ='L3');
            insert accTeam1;
            // ------------Parent Opportunity 
            Opportunity parentOppObj = new Opportunity();
            parentOppObj.AccountId = parentAccount.Id; 
            parentOppObj.Name= 'Parent Opportunity Test';
            parentOppObj.StageName='Needs Analysis';
            parentOppObj.CloseDate=System.today().addMonths(1);
            parentOppObj.Vehicle_Type__c = 'New';
            insert parentOppObj;
            
            
            //----------Parent CAM
            CAM__c parentCam = new CAM__c();
            parentCam.Loan_Application__c = parentOppObj.Id;
            parentCam.BE_CVO_Remark__c = 'testbeCVO';
            parentCam.Is_Hold__c = true;
            parentCam.Conditional_Approval__c = 'testapproved';
            parentCam.Proposal_Status__c = 'Approved';
            parentCam.Trigger_Deviations__c = true;
            insert parentCam;
            
            // ---------Parent Deviation
            Deviation__c parentDev = new Deviation__c();
            parentDev.Parent_CAM__c = parentCam.Id;
            parentDev.Approval_Status__c = 'Approved';
            parentDev.Deviation_Description__c = 'testdescription';
            parentDev.Remarks__c = 'Test Deviation';
            parentDev.Deviation_Level__c = 'L3';
            parentDev.Role__c = 'PNH';
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
            //opp.Parent_Loan_Application__c = parentOppObj.Id;
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
            insert opp;
            
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
            dv2.Role__c = 'PVNSM';
            dv2.Type__c = 'Normal Deviation';
            insert dv2;
            // ---------Deviation
            Deviation__c dv3 = new Deviation__c();
            dv3.Parent_CAM__c = cam1.Id;
            dv3.Approval_Status__c = 'Rejected';
            dv3.Deviation_Description__c = 'testdesc';
            dv3.Remarks__c = 'Test1';
            dv3.Deviation_Level__c = 'L3';
            dv3.Role__c = 'SH';
            dv3.Type__c = 'Normal Deviation';
            insert dv3;
            
            // ---------Deviation
            Deviation__c dv4 = new Deviation__c();
            dv4.Parent_CAM__c = cam1.Id;
            dv4.Approval_Status__c = 'Rejected';
            dv4.Deviation_Description__c = 'testdesc';
            dv4.Remarks__c = 'Test1';
            dv4.Deviation_Level__c = 'L3';
            dv4.Role__c = 'NPH';
            dv4.Type__c = 'Normal Deviation';
            insert dv4;
            
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
            vehicleDetail.Variant__c = 'ALSTILELE';
            vehicleDetail.City__c='Hyderabad';
            vehicleDetail.State__c='Andhra Pradesh';                                                
            vehicleDetail.Base_Price__c = 1000;
            insert vehicleDetail;
            
            // Cover Class Vaiable 
            Customer_Code__c  customerObj = new Customer_Code__c();  
            customerObj.Customer_Name__c = 'Test123';
            customerObj.Name = 'TY340ERT234';
            customerObj.Loan_Application__c = opp.Id;
            insert customerObj;
            List<Exposure__c> lstExp = new List<Exposure__c>();
            for(integer i=0;i<5;i++){
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
                    Eexpobject.Customer_Code__c = customerObj.Id;
                }
                if(i==3){
                    Eexpobject.Type__C = 'Bank Exposure';  
                    
                }
                if(i==4){
                    Eexpobject.Type__C = 'Family Exposure'; 
                    Eexpobject.Customer_Code__c = customerObj.Id;
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
            insert dfks2;
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
            cDRObj.Response__c = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":["abs"],"NPA":[],"Dealstatus":[{"Status_Flag":"R","Deal_No":"DRR02208G"}],"CustomerStatus":[{"Active_Flag":"F","Cross_Dedupe_Match_Id":"70281859"}],"CustomerMaster":[{"Aadhaar_No":"960294577157","Driving_License_Number":"HR-1520110022018","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"EQPPP2407F","Date_of_Birth":"18-04-1990 00:00:00","Customer_Type":"10","Customer_Name":"PAWAN","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW4977578"},{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[{"Status_Flag":"L","Deal_No":"DRR02208G"}],"CustomerStatus":[{"Active_Flag":"Y","Cross_Dedupe_Match_Id":"70281859"}],"CustomerMaster":[{"Aadhaar_No":"960294577157","Driving_License_Number":"HR-1520110022018","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"EQPPP2407F","Date_of_Birth":"18-04-1990 00:00:00","Customer_Type":"10","Customer_Name":"PAWAN","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW4977578"}],"CustomerMaster":[{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"ADHAR100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Y","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"960294577157","Current_Parameter_Value":"960294577157","Rule_Matching_Fields":"AADHAAR_NO","Matched_Customer_Code":"CW4977578","CIC_No":"CW4977578"},{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Y","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"EQPPP2407F","Current_Parameter_Value":"EQPPP2407F","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW4977578","CIC_No":"CW4977578"}]}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":null,"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"P"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            cDRObj.Deal_Status_Flag__c = 'T';
            cDRObj.Customer_Status_Flag__c = 'F';
            cDRObj.Customer_Code__c = 'CW4977578';
            insert cDRObj;
            
            Customer_Dedupe_Response__c cDR1Obj = new Customer_Dedupe_Response__c();
            cDR1Obj.Applicant__c = coborrowerApp.Id;
            cDR1Obj.Response__c = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":["abs"],"NPA":[],"Dealstatus":[{"Status_Flag":"R","Deal_No":"DRR02208G"}],"CustomerStatus":[{"Active_Flag":"F","Cross_Dedupe_Match_Id":"70281859"}],"CustomerMaster":[{"Aadhaar_No":"960294577157","Driving_License_Number":"HR-1520110022018","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"EQPPP2407F","Date_of_Birth":"18-04-1990 00:00:00","Customer_Type":"10","Customer_Name":"PAWAN","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW4977578"},{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[{"Status_Flag":"L","Deal_No":"DRR02208G"}],"CustomerStatus":[{"Active_Flag":"Y","Cross_Dedupe_Match_Id":"70281859"}],"CustomerMaster":[{"Aadhaar_No":"960294577157","Driving_License_Number":"HR-1520110022018","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"EQPPP2407F","Date_of_Birth":"18-04-1990 00:00:00","Customer_Type":"10","Customer_Name":"PAWAN","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW4977578"}],"CustomerMaster":[{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"ADHAR100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Y","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"960294577157","Current_Parameter_Value":"960294577157","Rule_Matching_Fields":"AADHAAR_NO","Matched_Customer_Code":"CW4977578","CIC_No":"CW4977578"},{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Y","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"EQPPP2407F","Current_Parameter_Value":"EQPPP2407F","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW4977578","CIC_No":"CW4977578"}]}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":null,"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"P"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
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
        DeviationHierarchialListViewController.DeviationWrapper wrapperdataList = new DeviationHierarchialListViewController.DeviationWrapper();
        wrapperdataList.applicantName ='Test Applicant';
        wrapperdataList.cam = 'Test Cam';
        wrapperdataList.camLink = 'Test camLink';
        wrapperdataList.deviationDescription = 'Test description';
        wrapperdataList.deviationLevel = 'L4';
        wrapperdataList.deviationTriggeredTo = 'SH';
        wrapperdataList.isHighlighted = true;
        wrapperdataList.loanApplication = 'Test App';
        wrapperdataList.style = 'Test style';
    }
    
    @isTest
    public static  void getDeviationHierarchyList_success(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            List<DeviationHierarchialListViewController.DeviationWrapper> deviationWrapperList = DeviationHierarchialListViewController.getDeviationHierarchyList();
            Test.stopTest();
            System.assert(deviationWrapperList != null);
        }
    }
    @isTest
    public static  void getDeviationHierarchyList_failure(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='testtermsconditions1234423@kaplan.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Test.startTest();
                List<DeviationHierarchialListViewController.DeviationWrapper> deviationWrapperList = DeviationHierarchialListViewController.getDeviationHierarchyList();
                Test.stopTest();
                System.assert(deviationWrapperList != null);
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
}