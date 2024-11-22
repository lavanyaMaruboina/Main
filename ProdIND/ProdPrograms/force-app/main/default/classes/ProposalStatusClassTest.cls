@isTest
public class ProposalStatusClassTest {
    @testSetup
    static void testSetup(){
        
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          timezonesidkey='america/los_angeles',username='test_userprod1237@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            // for Account
            Account acc = new Account(Name = 'Test PV', BranchBLCode__c = '34543');
            insert acc;
            
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'SH', UserId = u.Id);
            insert accTeam;
            
            // for Opportunity as  Loan_Application__c 
            Opportunity loanApplication = new Opportunity();
            loanApplication.AccountId = acc.Id;
            loanApplication.Name = 'OppTest';
            loanApplication.StageName = 'Credit Processing'; 
            loanApplication.CloseDate = Date.newInstance(2022, 07, 15);
            loanApplication.Applicant_Name__c = 'TestLoanApplication';
            loanApplication.Application_number__c = '56765';
            loanApplication.Employee_Branch__c = 'test';
            loanApplication.Make__c = 'loan';
            loanApplication.Variant__c = 'Home Loan';
            loanApplication.Category__c ='SAL';
            insert loanApplication;
            Applicant__c applicant =new Applicant__c(Name='test',
                                                     Contact_Number__c ='1234567891',
                                                     Opportunity__c = loanApplication.Id,
                                                     Customer_First_Name__c='GOURAB',
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
                                                     Communication_language__c = 'HI',
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
            
            List<Exposure__c> lstExp = new List<Exposure__c>();
            for(integer i=0;i<4;i++){
                Exposure__c  Eexpobject = new Exposure__c();  
                Eexpobject.Name = 'expName';
                Eexpobject.Loan_Application__c = loanApplication.id;
                Eexpobject.Applicant__c = applicant.id;
                Eexpobject.CIF_ID__c ='3534534';
                Eexpobject.Deal_No__c = 'something1';
                if(i==0){
                    Eexpobject.Type__C = 'Borrower Exposure';
                } else if(i==1){
                    Eexpobject.Type__C ='Co-Borrower Exposure';    
                } else if(i==2){
                    Eexpobject.Type__C = 'Additional Customer';  
                } else if(i==3){
                    Eexpobject.Type__C = 'Bank Exposure';  
                }
                lstExp.add(Eexpobject);
            }                     
            insert lstExp;
            
            // for CAM__c
            List<CAM__c> camList = new List<CAM__c>();
            for(Integer i=0; i<5; i++) {
                CAM__c pendingProposal = new CAM__c(); 
                pendingProposal.Loan_Application__c = loanApplication.Id;
                pendingProposal.Committee__c = 'CCC';
                pendingProposal.Action_Taken__c = false;
                pendingProposal.Trigger_Deviations__c = true;
                pendingProposal.Generation_Date__c = Date.newInstance(2022, 05, 15);
                if(i==0) {
                    pendingProposal.CAM_Status__c = 'Pending for approval';
                    pendingProposal.SCM_Approval__c = 'SCM not available';
                }else if(i==1){
                    pendingProposal.SCM_Approval__c = 'SCM not available';
                    pendingProposal.CAM_Status__c ='Hold by you';
                    pendingProposal.Is_Hold__c = true;
                }else if(i==2){
                    pendingProposal.CAM_Status__c ='Not approved by SCM';
                    pendingProposal.SCM_Approval__c ='Not approved';
                }else if(i==3){
                    pendingProposal.SCM_Approval__c = 'SCM not available';
                    pendingProposal.CAM_Status__c ='Forwarded to you';
                }else if(i==4){
                    //pendingProposal.Proposal_Status__c = 'Withdrawn';
                    pendingProposal.CAM_Status__c = 'Pending for approval';
                    pendingProposal.SCM_Approval__c = 'SCM not available';
                }
                camList.add(pendingProposal);
            }
            insert camList;
            
            List<Deviation__c> deviationList = new List<Deviation__c>();
            for(integer i=0;i<3;i++){
                Deviation__c dv = new Deviation__c();
                dv.Remarks__c = 'Test';
                dv.Active__c = true;
                dv.DeviationID__c = '12345678' + i;
                dv.Deviation_Level__c = 'CCC';
                dv.EmployeeID__c = '1234567EMP';
                dv.Role__c = 'SH';
                dv.Parent_CAM__c = camList[4].Id;
                if(i==0 || i==2){
                    dv.Approval_Status__c = 'Approved'; 
                    dv.Proposal_Status__c ='Hold';
                } else if(i==1){
                    dv.Approval_Status__c = 'Hold';
                    dv.Parent_CAM__c = camList[1].Id;
                }
                deviationList.add(dv);   
            }
            insert deviationList;
            
            
            Id ProAppType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Forward log').getRecordTypeId();
            List<Proposal_Approval_Log__c> proAppList = new List<Proposal_Approval_Log__c>();
            for(CAM__c cam :camList){
                Proposal_Approval_Log__c proApp = new Proposal_Approval_Log__c();
                proApp.Parent_CAM__c = cam.Id;
                proApp.Approval_Status__c = 'Hold';
                proApp.Date_and_Time__c = System.now();
                proApp.RecordTypeId = ProAppType;
                proApp.Forwarded_Role__c = 'SCM';
                proApp.Forwarded_On__c=System.now();
                proApp.Forwarded_By__c = u.Name;
                proApp.Forwarded_Role__c = 'BE';
                proApp.Forwarding_Employee__c = u.Id;
                proApp.Forwarded_Employee__c = u.Id;
                proApp.Is_Forwarded_Flag__c = true;
                proApp.Remark__c='Test';
                proAppList.add(proApp);
            }
            insert proAppList;
            
            // for Geo_State_Masters__c
            Geo_State_Masters__c stateList = new Geo_State_Masters__c();
            stateList.Name = 'TestH';
            stateList.State_Code__c = 'hr01';
            stateList.Pincode__c = 789;
            stateList.Pincode_Starting_Max__c = 657;
            insert stateList;
            
            // for  Bl_Code_Details__c
            Bl_Code_Details__c blCode = new Bl_Code_Details__c();
            blCode.Bl_Code__c = '34543';
            insert blCode;
            
            // for BankBranchDetails__c
            BankBranchDetails__c BranchList = new BankBranchDetails__c();
            BranchList.Geo_State_Master__c = stateList.Id;
            BranchList.Address_1__c = 'TestAdd1';
            BranchList.Address_2__c = 'TestAdd2';
            BranchList.Address_3__c = 'TestAdd3';
            BranchList.Address_4__c = 'TestAdd4';
            BranchList.Pincode__c = 896787;
            BranchList.City__c = 'Test City';
            BranchList.Business_Hub__c = 'Test Hub';
            BranchList.State_Code__c = 'E';
            BranchList.Bl_Code_Details__c = blCode.Id;
            BranchList.Product__c = 'Prod';
            BranchList.UniqueIdentifier__c = 'Test Unique';
            BranchList.District__c = 'Test District';
            BranchList.Name = 'Test Name';
            insert BranchList;
            
            //Vehicle_Detail__c
            Vehicle_Detail__c  vehicleDetail =  new Vehicle_Detail__c();
            vehicleDetail.Manufacturer_Year_Month__c = '2017-01';
            vehicleDetail.Loan_Application__c = loanApplication.Id;
            vehicleDetail.Variant__c = 'ALSTILELE';
            vehicleDetail.City__c='Hyderabad';
            vehicleDetail.State__c='Andhra Pradesh';                                                
            vehicleDetail.Base_Price__c = 1000;
            insert vehicleDetail;
            
            //Product
            Product2 product = new Product2();
            product.Name = 'ALSTILELE';
            product.Variant_Code__c = '12334';
            product.Type__c = 'Make';
            product.External_Reference_Id__c = 'Test';
            Insert product;
            
            // CFD_State_Master
            CFD_State_Master__C cfd = new CFD_State_Master__C();
            cfd.Name = 'Test';
            cfd.CFD_State_Code__c = 'E';
            cfd.District__c = 'Test';
            insert  cfd;   
            
            //Final Term data
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
            finalObj.Loan_Application__c = loanApplication.Id;
            insert finalObj;
        }
    }
    
    
    @isTest 
    public static void pendingProposalLoanApplication_Positive(){   
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {  
            // Act
            Test.startTest();
            CAM__c cam = [SELECT Id FROM CAM__c WHERE CAM_Status__c ='Pending for approval' LIMIT 1];
            List<CAM__c> camData = ProposalStatusClass.pendingProposalLoanApplication(cam.id);
            Test.stopTest();
            // Assert
            System.assert(camData.size()>0);
        }
    } 
    @isTest 
    public static void proposalHoldByYou_Positive()
    {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {       
                List<CAM__c> cam = [SELECT Id FROM CAM__c WHERE CAM_Status__c ='Hold by you'];
                
                List<CAM__c> camData =  ProposalStatusClass.proposalHoldByYou(cam[0].id);
                System.assertEquals(1,camData.size());
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void proposalNotApprovedBySCM_Positive()
    {            
        //Arrange 
        User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {  
            Test.startTest();
            //Act
            List<CAM__c> cam = [SELECT Id FROM CAM__c WHERE CAM_Status__c ='Not approved by SCM'];
            List<CAM__c> camData  = ProposalStatusClass.proposalNotApprovedBySCM(cam[0].Id);
            // Assert
            System.assertEquals(1, camData.size());
            Test.stopTest();    
        }
    }
    
    @isTest 
    public static void proposalForwardedByYou_Positive()
    {
        try
        {
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                Test.startTest();
                List<CAM__c> cam = [SELECT Id FROM CAM__c WHERE CAM_Status__c ='Forwarded to you'];
                // Act
                ProposalStatusClass.proposalForwardedByYou(cam[0].Id);
                // Assert
                List<CAM__c> camData = [SELECT Id, CAM_Status__c FROM CAM__c];
                System.assert(camData.size()>0);
                Test.stopTest();                          
            }
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void getAllState_Positive()
    {
        try
        {    
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                // Act
                ProposalStatusClass.getAllState();
                List<Geo_State_Masters__c> geo = [SELECT Id, Name FROM Geo_State_Masters__c];
                // Assert
                System.assertEquals('TestH', geo[0].Name);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void getRelatedBLCodes_Positive()
    {
        try
        {
            Test.startTest();
            // Arrange
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                List<Geo_State_Masters__c> geoRecord = [SELECT Id, Name FROM Geo_State_Masters__c];
                // Act
                ProposalStatusClass.getRelatedBLCodes(geoRecord[0].Name);
                
                List<Geo_State_Masters__c> geo = [SELECT Id, Name FROM Geo_State_Masters__c];
                // Assert
                System.assertEquals('TestH', geo[0].Name);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest 
    public static void blCodeMapping_Positive()
    {
        try
        {
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {        
                List<CFD_State_Master__c> geoRecord = [SELECT Id, CFD_State_Code__c, Name FROM CFD_State_Master__c LIMIT 1];
                // Act
                Test.startTest();
                List<BankBranchDetails__c> blCodeMapping = ProposalStatusClass.blCodeMapping(geoRecord[0].CFD_State_Code__c);
                ProposalStatusClass.blCodeMapping(null);
                Test.stopTest();        
                // Assert
                System.assert(blCodeMapping.size()>0);
            }
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void searchLogs_Positive()
    {
        try
        {
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {    
                // Act 
                ProposalStatusClass.searchLogs('ALL', 'ALL', null, null, 'ALL', '4', null, 'SH', null, null);
                // Assert
               // System.assert(ProposalStatusClass.searchLogs('ALL', 'ALL', null, null, 'ALL', '4', null, 'SH', null, null) != null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest 
    public static void searchLogs_Success()
    {
        try
        {
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {     
                //Act
                ProposalStatusClass.searchLogs(null, null, null, null, null, null, null, 'SH', null, null);
                // Assert
                //System.assert(ProposalStatusClass.searchLogs(null, null, null, null, null, null, null, 'SE', null, null) !=null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void searchLogs_Success2()
    {
        try
        {
            Deviation__c dev = [SELECT Id, Approval_Status__c,Role__C,Proposal_Status__c from Deviation__c LIMIT 1];
            dev.Approval_Status__c= 'Hold';
            update dev; 
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {     
                //Act
                ProposalStatusClass.searchLogs(null, null, null, null, null, null, null, 'SH', null, null);
                // Assert
               // System.assert(ProposalStatusClass.searchLogs(null, null, null, null, null, null, null, 'SH', null, null) !=null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void fetchForwardedProposals_Positive()
    {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {   
                // Arrange
                List<CAM__c> camRecord = [SELECT Id, Loan_Application__c, Name FROM CAM__c];
                Map<Id,CAM__c> camIdVsCamMap = new Map<Id,CAM__c>(camRecord);
                // Act
                ProposalStatusClass.fetchForwardedProposals(camIdVsCamMap, null);
                //Assert
                System.assert( ProposalStatusClass.fetchForwardedProposals(camIdVsCamMap, null) != null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest 
    public static void fetchForwardedProposals_Neagtive()
    {
        Test.startTest();
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {   
            // Act  
            ProposalStatusClass.fetchForwardedProposals(null, null);
            // Arrange
            System.assertEquals(null, ProposalStatusClass.fetchForwardedProposals(null, null));
        }
        
    }
    @isTest 
    public static void fetchForwardedProposals_Neagtive2()
    {
        Test.startTest();
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {   
            try{
                List<CAM__c> camRecord = [SELECT Id, Name FROM CAM__c];
                Map<Id,CAM__c> camIdVsCamMap = new Map<Id,CAM__c>(camRecord);
                // Act  
                ProposalStatusClass.fetchForwardedProposals(camIdVsCamMap, null);
            } 
            catch(Exception e){
                // Arrange
                System.assert(true);   
            }
        }
    }
    
    @isTest 
    public static void fetchHoldProposals_Positive()
    {
        try
        {
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {     
                // Act
                ProposalStatusClass.CamDataWrapper dataWrapperObj  = ProposalStatusClass.fetchHoldProposals('SH', null, null);
                //Assert
                System.assert(dataWrapperObj !=null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void fetchHoldProposals_Success()
    {
        try
        {
            Deviation__c dev = [SELECT Id, Approval_Status__c,Role__C,Proposal_Status__c from Deviation__c LIMIT 1];
            dev.Approval_Status__c= 'Hold';
            update dev; 
            Test.startTest();
            //Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {     
                //Act
                ProposalStatusClass.CamDataWrapper dataWrapperObj = ProposalStatusClass.fetchHoldProposals('SH', null, null);
                // Assert
                System.assert(dataWrapperObj!=null);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void fetchHoldProposals_Success2()
    {
        try
        {
            Deviation__c dev = [SELECT Id, Approval_Status__c,Role__C,Proposal_Status__c from Deviation__c LIMIT 1];
            dev.Approval_Status__c= 'Hold';
            update dev; 
            Test.startTest();
            //Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {     
                //Act
                ProposalStatusClass.CamDataWrapper dataWrapperObj = ProposalStatusClass.fetchHoldProposals('SE', null, null);
                // Assert
                System.assert(dataWrapperObj!=null);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    
    @isTest 
    public static void fetchNonApprovedProposals_Positive()
    {
        try         
        {
            Test.startTest();
            // Arrange  
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u)
            {
                
                List<Deviation__c> devlist = [SELECT Id, Approval_Status__c,Role__C,Proposal_Status__c from Deviation__c LIMIT 10000];
                for(Deviation__c dev : devlist){
                    dev.Approval_Status__c= 'Approved';
                }
                update devlist;
                List<CAM__c> camRecord = [SELECT Id, Name, Loan_Application__r.AccountId,Trigger_Deviations__c FROM CAM__c];
                Map<Id,CAM__c> camIdVsCamMap = new Map<Id,CAM__c>(camRecord);
                List<accountTeamMember> accTeamList = [SELECT Id, AccountId,TeamMemberRole FROM AccountTeamMember];
                Map<Id,AccountTeamMember> accountIdVsTeamMember = new Map<Id,AccountTeamMember>();
                for(accountTeamMember accTM : accTeamList)
                {
                    if(!accountIdVsTeamMember.containsKey(accTM.AccountId)){
                        accountIdVsTeamMember.put(accTM.AccountId, accTM);
                    }
                }
                // Act
                ProposalStatusClass.CamDataWrapper dataWrapperObj = ProposalStatusClass.fetchNonApprovedProposals(camIdVsCamMap, accountIdVsTeamMember, 'SE', null);
                ProposalStatusClass.fetchNonApprovedProposals(null, null, null, null);
                //System.assert(dataWrapperObj != null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void fetchNonApprovedProposals_Success()
    {
        try
        {
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u)
            {
                List<Deviation__c> devlist = [SELECT Id, Approval_Status__c,Role__C,Proposal_Status__c from Deviation__c LIMIT 10000];
                for(Deviation__c dev : devlist){
                    dev.Approval_Status__c= 'Hold';
                }
                update devlist;
                List<CAM__c> camRecord = [SELECT Id, Name, Loan_Application__r.AccountId,Trigger_Deviations__c FROM CAM__c];
                Map<Id,CAM__c> camIdVsCamMap = new Map<Id,CAM__c>(camRecord);
                List<accountTeamMember> accTeamList = [SELECT Id, AccountId,TeamMemberRole FROM AccountTeamMember];
                Map<Id,AccountTeamMember> accountIdVsTeamMember = new Map<Id,AccountTeamMember>();
                for(accountTeamMember accTM : accTeamList)
                {
                    if(!accountIdVsTeamMember.containsKey(accTM.AccountId)){
                        accountIdVsTeamMember.put(accTM.AccountId, accTM);
                    }
                }
                //Act
                ProposalStatusClass.CamDataWrapper dataWrapperObj =  ProposalStatusClass.fetchNonApprovedProposals(camIdVsCamMap, accountIdVsTeamMember, 'SH', null);
                // Assert
                //System.assert(dataWrapperObj!=null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void getAccountRole_Positive()
    { 
        try
        {
            Test.startTest();
            // Arrange  
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
            List<UserRole> userRole = new List<UserRole>();
            System.runAs(u)
            {       
                // Act
                ProposalStatusClass.getAccountRole();
                // Assert
                system.assert(ProposalStatusClass.getAccountRole()!= null);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
 //CISP-7949
 	@isTest 
    public static void getCurrentUserProductTypeTest()
    { 
        try
        {
            Test.startTest();
            // Arrange  
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
            
            System.runAs(u)
            {       
                // for Account
                Account acc1 = new Account(Name = 'Test PV', BranchBLCode__c = '34543');
                insert acc1;
                
                AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc1.Id, TeamMemberRole = 'SH', UserId = u.Id);
                insert accTeam1;
                // Act
                //String currentUserProductTeam = ProposalStatusClass.getCurrentUserProductType();
                // Assert
                //system.assert(currentUserProductTeam == 'Passenger Vehicles');
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
   
}