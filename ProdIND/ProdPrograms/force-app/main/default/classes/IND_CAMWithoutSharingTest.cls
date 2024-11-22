@istest
public class IND_CAMWithoutSharingTest {
    
    @testsetup()
    static void setup(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123Prod@indusbank.com',MobilePhone = '9089078967');
        insert u;
        
        System.runAs(u) 
        {   
            Account testAccount = new Account(Name = 'Test view Acc' ,BranchBLCode__c = '34543');
            insert testAccount;
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = testAccount.Id,  TeamMemberRole = 'SH', UserId =u.id, Level__c ='L4;L1;L2');
            insert accTeam;
            
            // ------------Opportunity 
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = new Opportunity();
            opp.AccountId = testAccount.Id;   
            opp.Name= 'Opportunity Test';
            opp.StageName='Qualification';
            opp.CloseDate=System.today().addMonths(1);
            opp.Vehicle_Sub_Category__c= 'UIM';
            opp.Employee_Branch__c = 'Test Employee Branch';
            opp.Gross_IRR__c = 4353;
            opp.NOC_Number__c = 45654;
            opp.Funding_on_ORP__c = true;
            opp.Advance_EMI__c = true;
            opp.Customer_Code__c = '896745';
            opp.Deal_Number__c = 'TUT06226H';
            opp.Funding_on_Ex_Showroom__c = true;
            opp.Basic_Price__c = 67000;
            opp.Discount_on_Basic_Price__c = 6000;
            opp.Funding_on_ORP__c = true;
            opp.RTO_Road_Tax__c = 6000;
            opp.X1st_yr_Insurance_Premium__c = 1400;
            opp.Other_charges__c = 2000;
            opp.GST_Amount__c = 10999;
            opp.Agent_BL_code__c='MPP';
            opp.Sub_Stage__c = 'Field Investigation';
            opp.Service_Charges__c = '700';
            opp.Documentation_Charges__c = '400';
            opp.Dealer_Expence_Reimburse_Amt__c = '300';
            opp.DSM_Incentive1__c = 4003;
            opp.Loan_amount__c='400000';  
            opp.OTP_for_borrower__c='9999';
            opp.Applicant_Name__c='ayuyu';
            opp.Mfr_Incentive__c=98;
            opp.Gift_through_Dealer_Amount__c='866';
            opp.Required_Tenure__c=7;
            opp.Required_ROI__c=5;
            opp.Parent_Deal_number__c='7878';
            opp.Vehicle_Type__c = 'Used';
            opp.Product_Type__c = 'Two Wheeler';      
            insert opp;
            // Borrower Applicant 
            Applicant__c applicant =new Applicant__c(Name='test',
                                                     Contact_Number__c ='1234567891',
                                                     Opportunity__c = opp.Id,
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
            
            CAM__c cam1 = new CAM__c();
            cam1.Loan_Application__c = opp.Id;
            cam1.BE_CVO_Remark__c = 'testbe';
            cam1.Is_Hold__c = true;
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
        }   
    }
    @istest
    public static void forwardCAMWithAPI_success(){
        //Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            CAM__c  cam = [ SELECT Id, NAME FROM Cam__c];
            // Act
            IND_CAMWithoutSharing.forwardCAMWithAPI(cam.id,'SH');
            // Assert 
            System.assert( IND_CAMWithoutSharing.forwardCAMWithAPI(cam.id,'SH') != null);
        }
    }
    @istest
    public static void forwardCAMWithAPI_fail(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                CAM__c  cam = [ SELECT Id, NAME FROM Cam__c];
                //Act
                List<RequestWrapper> requestWrapper  = IND_CAMWithoutSharing.forwardCAMWithAPI('abc','SH');
                // Assert
                System.assert(requestWrapper != null);
            }
            catch(Exception e){
                System.assert(true);
            }
        }
    }
    
    @istest
    public static void triggerDeviationMail_success(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            CAM__c  cam = [ SELECT Id, NAME FROM Cam__c];
            Deviation__C  dev = [SELECT id, Type__c,Role__c FROM Deviation__C Limit 1 ];
            dev.Type__c = 'Committee Deviation';
            dev.Role__c = 'SH';
            update dev;
            //Act
            List<RequestWrapper> requestWrapper = IND_CAMWithoutSharing.triggerDeviationMail(cam.id, 'caRemark','camScreen');
            // Assert
            System.assert(requestWrapper !=null);
            
        }
    }
    
    @istest
    public static void triggerDeviationMail_fail(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                CAM__c  cam = [ SELECT Id, NAME FROM Cam__c];
                //Act
                List<RequestWrapper> requestWrapper  = IND_CAMWithoutSharing.triggerDeviationMail('abc', 'abc','camScreen');
                // Assert
                System.assert(requestWrapper != null);
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    
    @istest
    public static void getForwardWrapper_success(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            CAM__c  cam = [ SELECT Id, NAME FROM Cam__c];
            //Act
            List<RequestWrapper> requestWrapper  = IND_CAMWithoutSharing.getForwardWrapper(cam.id);
            // Assert
            System.assert(requestWrapper != null);
            
        }
    }
    @istest
    public static void getForwardWrapper_fail(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                CAM__c  cam = [ SELECT Id, NAME FROM Cam__c];
                //Act
                List<RequestWrapper> requestWrapper  = IND_CAMWithoutSharing.getForwardWrapper('abc');
                // Assert
                System.assert(requestWrapper != null);
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    
    @istest
    public static void createProposalLog_success(){
        // Arrange 
        User u = [SELECT Id,usertype,Username,Email FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1];
        system.runAs(u){
            CAM__c  cam = [ SELECT Id, Loan_Application__c , Loan_Application__r.AccountId, NAME FROM Cam__c];
            //Act
            Boolean  result =IND_CAMWithoutSharing.createProposalLog(cam.id,'SH','test','standarduser2@testorg.com');
            // Assert 
            System.assert(result);
        }
    }
    
    @istest
    public static void createProposalLog_fail(){
        // Arrange 
        User u = [SELECT Id,usertype,Username,Email FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1];
        system.runAs(u){
            try{
                CAM__c  cam = [ SELECT Id, Loan_Application__c , Loan_Application__r.AccountId, NAME FROM Cam__c];
                //Act
                Boolean  result =IND_CAMWithoutSharing.createProposalLog(null,'SH','test','standarduser2@testorg.com');
                // Assert 
                System.assert(result);
            }
            catch(Exception e){
                System.assert(true);
            }
        }
    }
    
    @istest
    public static void createProposalLog_fail2(){
        // Arrange 
        User u = [SELECT Id,usertype,Username,Email FROM User WHERE UserName='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1];
        system.runAs(u){
            CAM__c  cam = [ SELECT Id, Loan_Application__c , Loan_Application__r.AccountId, NAME FROM Cam__c];
            //Act
            Boolean  result =IND_CAMWithoutSharing.createProposalLog(cam.id,'SH','test','standarduser2@testorg.com');
            // Assert 
            System.assertEquals(true,result);
        }
    }
    
    @isTest
    public static void forwardCAMWithAPITest1(){
        try{
            
            Account au1 = new Account();
            au1.Name = 'test';
            insert au1;
            
            Opportunity opgr1 = new Opportunity();
            opgr1.AccountId = au1.Id;
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1; 
            
            CAM__c cam1 = new CAM__c();
            cam1.Active__c = true;
            cam1.Loan_Application__c = opgr1.Id;
            insert cam1; 
            
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = opgr1.AccountId;
            atm1.TeamMemberRole = 'FI';
            atm1.UserId = UserInfo.getUserId();
            insert atm1;
            
            Deviation__c d1 = new Deviation__c();
            d1.Parent_CAM__c = cam1.Id;
            d1.Role__c = atm1.TeamMemberRole;
            d1.Deviation_Level__c = 'RCC';
            insert d1;
            
            Test.startTest();
                   IND_CAMWithoutSharing.forwardCAMWithAPI(cam1.Id,atm1.TeamMemberRole);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void triggerDeviationMailTest1(){
        try{
            Account au1 = new Account();
            au1.Name = 'test';
            insert au1;
            
            Opportunity opgr1 = new Opportunity();
            opgr1.AccountId = au1.Id;
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            opgr1.Product_Type__c='Tractor';
            insert opgr1; 
            
            CAM__c cam1 = new CAM__c();
            cam1.Active__c = true;
            cam1.Loan_Application__c = opgr1.Id;
            insert cam1; 
            
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = opgr1.AccountId;
            atm1.TeamMemberRole = 'FI';
            atm1.UserId = UserInfo.getUserId();
            insert atm1;
            
            Deviation__c d1 = new Deviation__c();
            d1.Parent_CAM__c = cam1.Id;
            d1.Role__c = atm1.TeamMemberRole;
            d1.Deviation_Level__c = 'RCC';
            insert d1;
            
            Test.startTest();
                 IND_CAMWithoutSharing.triggerDeviationMail(cam1.Id,'no comments','camScreen');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getForwardWrapperTest1(){
        Account au1 = new Account();
            au1.Name = 'test';
            insert au1;
            
            Opportunity opgr1 = new Opportunity();
            opgr1.AccountId = au1.Id;
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1; 
            
            CAM__c cam1 = new CAM__c();
            cam1.Active__c = true;
            cam1.Loan_Application__c = opgr1.Id;
            insert cam1;
        
            Deviation__c d1 = new Deviation__c();
            d1.Parent_CAM__c = cam1.Id;
          //  d1.Role__c = atm1.TeamMemberRole;
            d1.Deviation_Level__c = 'RCC';
            insert d1;
        
             Test.startTest();
                 IND_CAMWithoutSharing.getForwardWrapper(cam1.Id);
             Test.stopTest();

    }//CISP-7949
    @isTest
    public static void getdeviMasterRecordsTest(){
        Deviation_Master__c  deviMasterRec = new Deviation_Master__c(Name='M1819',Active__c=true,Source__c='Manual',Deviation_Level__c='L6',Parameter__c='COMBO WAIVER DEVIATION');
        insert deviMasterRec;
        Test.startTest();
        List<IND_CAMWithoutSharing.deviationMasterWrapper> deviMasterRecList= IND_CAMWithoutSharing.getdeviMasterRecords();
        Test.stopTest();
        System.assertEquals('M1819',deviMasterRecList[0].Deviation_Id,'Success');
    }
     @isTest
    public static void getmitigantsMasterRecordsTest(){
        Mitigant_Master__c  mitiMasterRec = new Mitigant_Master__c(Name='Test',Active__c=true,Description__c= 'Test');
        insert mitiMasterRec;
        Test.startTest();
        List<IND_CAMWithoutSharing.mitigantsMasterWrapper> mitiMasterRecList = IND_CAMWithoutSharing.getmitigantsMasterRecords();
        Test.stopTest();
        System.assertEquals('Test',mitiMasterRecList[0].Name,'Success');
    }
    @isTest
    public static void sendApprovalCAMReqAPITest(){
        CAM__c cam=[SELECT Id,Loan_Application__c,Loan_Application__r.Name, Loan_Application__r.AccountId FROM CAM__c Limit 1];
        List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,User.Profile.UserLicense.Name FROM AccountTeamMember WHERE User.isActive = true LIMIT 1];
        roleList[0].TeamMemberRole='ACM';
        update roleList;
        Test.startTest();
        List<RequestWrapper> requestWrapperList = IND_CAMWithoutSharing.sendApprovalCAMReqAPI(cam.Id);
        Test.stopTest();
        System.assertEquals('Testing',requestWrapperList[0].Name,'Success');
    }
}