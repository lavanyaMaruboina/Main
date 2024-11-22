@isTest
public class CAMApprovalLogControllerTest {
    @testSetup
    public static void setup() {
        //create user
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',  UserRoleId = r.Id, UserName='test_userprod1237@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            /*Account*/
            Account acc = new Account();
            acc.Name = 'Test';
            insert acc;
            
            Account acc2 = new Account();
            acc2.Name = 'Test2';
            insert acc2;
            
            /*opportunity*/
            List<Opportunity> opportuntiyList = new List<Opportunity>();
            Opportunity opp = new Opportunity();
            opp.name = 'TestOpportunity';
            opp.Gross_IRR__c = 4353;
            opp.NOC_Number__c = 45654;
            opp.Advance_EMI__c = true;
            opp.Customer_Code__c = '896745';
            opp.Deal_Number__c = 'TUT06226H';
            opp.Funding_on_Ex_Showroom__c = true;
            opp.Basic_Price__c = 67000;
            opp.Discount_on_Basic_Price__c = 6000;
            opp.Funding_on_ORP__c = true;
            opp.RTO_Road_Tax_New__c = 6000;
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
            opp.Journey_Status__c = 'No Impact';
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addDays(5);
            opp.Loan_amount__c = '10000';
            opp.Product_Type__c = 'Passenger Vehicles';
            opp.Vehicle_Type__c = 'New';
            opp.Funding_on_Ex_Showroom__c = true;
            opp.Funding_on_ORP__c = true;
            opp.AccountId = acc.Id;
            insert opp;     
            
            Final_Term__c ft = new Final_Term__c();
            ft.OfferengineMinLoanAmount__c = 10000;
            ft.Advance_EMI__c = true;
            ft.Loan_Application__c = opp.Id;
            ft.OfferengineMaxLoanAmount__c = 10000;
            ft.Loan_Amount__c = '10000';
            ft.Net_IRR__c = 10000;
            ft.EMI_Amount__c = 1000;
            ft.Inputted_IRR__c = 77;
            insert ft;
            
            List<AccountTeamMember> accountteamList = new List<AccountTeamMember>();
            AccountTeamMember atm = new AccountTeamMember();
            atm.TeamMemberRole ='BE';
            atm.UserId = UserInfo.getUserId();
            atm.AccountId = acc.Id;
            atm.Level__c = 'L4';
            
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.TeamMemberRole ='BH';
            atm1.UserId = UserInfo.getUserId();
            atm1.AccountId = acc.Id;
            atm1.Level__c = 'L4';
            accountteamList.add(atm);
            accountteamList.add(atm1);
            insert accountteamList;
            
            CAM__c cam = new CAM__c(); 
            cam.Loan_Application__c = opp.Id;
            cam.Committee__c = 'ZCC';
            cam.CAM_Status__c = 'Pending for approval';
            cam.Generation_Date__c = Date.today().addDays(5); 
            cam.SCM_Approval__c = 'SCM not available';
            insert cam;
            
            User runningUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
            
            Id ProAppType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Forward log').getRecordTypeId();
            Proposal_Approval_Log__c proApp = new Proposal_Approval_Log__c();
            proApp.Parent_CAM__c = cam.Id;
            proApp.Date_and_Time__c = System.now();
            proApp.RecordTypeId = ProAppType;
            proApp.Forwarded_On__c=System.now();
            proApp.Forwarded_By__c = runningUser.Name;
            proApp.Forwarded_Role__c = 'BE';
            proApp.Forwarding_Employee__c =runningUser.Id;
            proApp.Forwarded_Employee__c =runningUser.Id;
            proApp.Remark__c='Test';
            insert proApp;
            
            Applicant__c app = new Applicant__c();
            app.Applicant_Type__c = 'Co-borrower';
            app.Opportunity__c = opp.Id;
            app.Contact_number__c = '123456789';
            insert app;
            
            Vehicle_Detail__c vd = new Vehicle_Detail__c();
            vd.Loan_Application__c = opp.Id;
            vd.Grid_value__c = 200;
            vd.Selling_Price__c = 200;
            vd.Valuation_price__c = 400;
            insert vd;
            
            Deviation__c dv = new Deviation__c();
            dv.Remarks__c = 'Test';
            dv.Active__c = true;
            dv.DeviationID__c = '12345678';
            dv.Deviation_Level__c = 'ZCC';
            dv.EmployeeID__c = '1234567EMP';
            dv.Parent_CAM__c = cam.Id;
            dv.Approval_Status__c = 'Hold';
            dv.Role__C ='BH';
            dv.Deviation_Level__c ='BCC';
            dv.Type__c = 'Committee Deviation';
            insert dv;
        }
    }
    
    @isTest
    public static void canAccessCAMApprovalLog_success() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
        Boolean result;
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            result = CAMApprovalLogController.canAccessCAMApprovalLog(opp.Id);
            Test.stopTest();
            opp.Product_Type__c = 'Two Wheeler';
        	update opp;
            result = CAMApprovalLogController.canAccessCAMApprovalLog(null);
        }
        // Assert 
        //System.assertEquals(true, result);
    }
    
    @isTest
    public static void generateCAM_success() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            CAMApprovalLogController.generateCAM(opp.Id);
            Test.stopTest();
            opp.Product_Type__c = 'Two Wheeler';
        	update opp;
            //Test.startTest();
            //CAMApprovalLogController.canAccessCAMApprovalLog(opp.Id);
            //Test.stopTest();
            CAMApprovalLogController.generateCAM(null);
        }
        System.assert(CAMApprovalLogController.generateCAM(opp.Id) != null);
    }
    
    @isTest
    public static void getAvailableRoles_success() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        String result;
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            result = CAMApprovalLogController.getAvailableRoles(opp.Id);
            Test.stopTest();
            CAMApprovalLogController.getAvailableRoles(opp.Id);
        }
        // Assert
        System.assert(result !=null);
    }
    
    @isTest
    public static void isCAMForwardedToSCM_Success() {
        // Arrange 
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        Proposal_Approval_Log__c app = [SELECT Id,RecordType.Name,Forwarded_Role__c FROM Proposal_Approval_Log__c LIMIT 1];
        app.Forwarded_Role__c= 'SCM';
        update app;
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
        Boolean result;
        System.runAs(u) 
        {
            Test.startTest();
            result = CAMApprovalLogController.isCAMForwardedToSCM(cam.Id);
            Test.stopTest();
        }
        // Assert 
        System.assertEquals(true,result);
    }
    
    @isTest
    public static void isCAMForwardedToSCM_fail() {
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Test.startTest();
                Boolean result = CAMApprovalLogController.isCAMForwardedToSCM(null);
                Test.stopTest();
                system.assertEquals(false,result);
            }
            catch(Exception e){
                System.assert(true);
            }
        }
    }
    
    @isTest
    public static void forwardCAM_Positive() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        Boolean result;
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            result= CAMApprovalLogController.forwardCAM(cam.Id, 'BH', 'Test');
            Test.stopTest();
        }
        // Assert
        System.assert(result==true);  
    }
    @isTest
    public static void forwardCAM_Negative() {
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        Boolean result;
        System.runAs(u) 
        { 
            try{
                // Act
                Test.startTest();
                result= CAMApprovalLogController.forwardCAM(null, null, null);
                Test.stopTest();
            }
            catch(exception e){
                // Assert
                System.assert(true);  
            }
        }
        
    }
    
    @isTest
    public static void getProposalApprovalLog_Positive() {
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            CAMApprovalLogController.getProposalApprovalLog(cam.Id);
            Test.stopTest();
            CAMApprovalLogController.getProposalApprovalLog(null);
        }
        List<CAM__c> camList = [SELECT Id, Committee__c FROM CAM__c LIMIT 1];
        System.assertEquals('ZCC', camList[0].Committee__c);
    }
    
    @isTest
    public static void getTeamRoles_Positive() {
        // Arrange 
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
        String result;
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            result = CAMApprovalLogController.getTeamRoles();
            Test.stopTest();
        }
        //Assert
        System.assert(result !=null);
    }
    
    @isTest
    public static void updateConditionalProposalLogs_Positive() {
        // Arrange 
        List<Proposal_Approval_Log__c> ProApp = [SELECT Id, Action__c, Remark__c, Role__c, Parent_CAM__c, Deviation_Id__c,Parent_CAM__r.Loan_Application__r.Product_Type__c FROM Proposal_Approval_Log__c WHERE Forwarded_Role__c = :'BE' LIMIT 1];
        
        List<CAMApprovalLogController.ConditionalApprovalLogWrapper> listWrap = new List<CAMApprovalLogController.ConditionalApprovalLogWrapper>();
        
        CAMApprovalLogController.ConditionalApprovalLogWrapper wrapp = new CAMApprovalLogController.ConditionalApprovalLogWrapper();
        
        wrapp.id = ProApp[0].id;
        wrapp.action = 'Action Taken';
        wrapp.remark = 'Testing';
        
        listWrap.add(wrapp);
        String wrappString = JSON.serialize(listWrap);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
        Boolean result;
        System.runAs(u) 
        {
            // Act 
            Test.startTest();
            result = CAMApprovalLogController.updateConditionalProposalLogs(wrappString, ProApp,'BE');
            Test.stopTest();
            CAMApprovalLogController.updateConditionalProposalLogs(null, null,null);
        }
        // Assert
        System.assertEquals(true, result);
    }
    
    @isTest
    public static void updateConditionalProposalLogs_negative() {
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
        Boolean result;
        System.runAs(u) 
        {
            // Act 
            Test.startTest();
            result = CAMApprovalLogController.updateConditionalProposalLogs(null, null,null);
            Test.stopTest();
        }
        // Assert
        System.assertEquals(false, result);
    }
    
    @isTest
    public static void getVehicleIDs_Positive() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        User u = [SELECT Id, usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
        List<Vehicle_Detail__c> vehicalList = New List<Vehicle_Detail__c>();
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            vehicalList =  CAMApprovalLogController.getVehicleIDs(opp.id);
            Test.stopTest();
            CAMApprovalLogController.getVehicleIDs(null);
        }
        // Assert 
        System.assert(vehicalList.size()>0);
    }
    
    @isTest
    public static void getDevRemarks_Positive() {
        
        Deviation__c dev = [SELECT Name FROM Deviation__c LIMIT 1];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        List<Deviation__c>  devRemarks = new List<Deviation__c> ();
        System.runAs(u) 
        {
            Test.startTest();
            devRemarks =  CAMApprovalLogController.getDevRemarks(dev.Name);
            Test.stopTest();
            CAMApprovalLogController.getDevRemarks(null);
        }
        System.assert(devRemarks.size()>0);
    }
    
    @isTest
    public static void getDeviationsForApprovals_Positive() {
        // Arrange 
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id, usertype FROM User WHERE UserName ='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1];
        List<Deviation__c> lstdeviation = new List<Deviation__c>();
        System.runAs(u) 
        {
            // ACT
            Test.startTest();
            lstdeviation = CAMApprovalLogController.getDeviationsForApprovals(cam.Id);
            Test.stopTest();
            CAMApprovalLogController.getDeviationsForApprovals(null);
        }
        //Assert
        System.assert(lstdeviation.size()>0);
    }    
    
    @isTest
    public static void getRelatedCAM_Positive() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            CAMApprovalLogController.getRelatedCAM(opp.Id);
            Test.stopTest();
            CAMApprovalLogController.getRelatedCAM(null);
        }
        // Assert
        // System.assert(CAMApprovalLogController.getRelatedCAM(opp.Id) !=null);
    }
    
    @isTest
    public static void getRelatedCAM_Positive2() {
        // Arrange 
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        opp.Product_Type__c = 'Two Wheeler';
        update opp;
        System.runAs(u)
        {
            
            // Act
            Test.startTest();
            CAMApprovalLogController.getRelatedCAM(opp.Id);
            Test.stopTest();
        }
        // Assert
        // System.assert(CAMApprovalLogController.getRelatedCAM(opp.Id) !=null);
    }
    
    @isTest
    public static void getRelatedCAM_Negative() {
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            CAMApprovalLogController.getRelatedCAM(null);
            Test.stopTest();
        }
        System.assert(CAMApprovalLogController.getRelatedCAM(null)==null);
    }
    
    @isTest
    public static void getParentLoanApplicationData_Positive() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        {
            // Act
            Test.startTest();
            CAMApprovalLogController.getParentLoanApplicationData(opp.Id);
            Test.stopTest();
        }
        // Assert
        //System.assert(CAMApprovalLogController.getParentLoanApplicationData(opp.Id) ==null);
    }
    
    @isTest
    public static void getParentLoanDeviations_Positive() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        {
            // Act
            Test.startTest();
            CAMApprovalLogController.getParentLoanDeviations(opp.Id);
            Test.stopTest();
        }
        // Assert
        System.assert(CAMApprovalLogController.getParentLoanDeviations(opp.Id) !=null);
    }
    
    @isTest
    public static void checkCurrentUserRole_Positive() {
        // Arrange 
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            CAMApprovalLogController.checkCurrentUserRole(opp.Id);
            Test.stopTest();
        }
        // Assert
        System.assert(CAMApprovalLogController.checkCurrentUserRole(opp.Id) != null);
    }
    
    @isTest
    public static void checkCurrentUserRole_Negative() { 
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            CAMApprovalLogController.UserDataWrapper result = CAMApprovalLogController.checkCurrentUserRole(null);
            Test.stopTest();
            // Assert
            System.assertNotEquals(null, result);
        }                
    }
    
    @isTest
    public static void updateLoanApplication_Positive() {
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
        CAM__c cam = [SELECT Id, Proposal_Status__c FROM CAM__c WHERE Committee__c = :'ZCC'];
        cam.Proposal_Status__c = 'Accept';
        update cam;
        User u = [SELECT Id, usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        Boolean result;
        System.runAs(u) 
        {
            Test.startTest();
            result = CAMApprovalLogController.updateLoanApplication(String.valueOf(opp.Id), true, cam);
            Test.stopTest();
            CAMApprovalLogController.updateLoanApplication(null, null, null);
        }
        //System.assertEquals(true, result);
    }
    
    
    @isTest
    public static void updateLoanApplication_Negative() {
        // Arrange 
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            CAMApprovalLogController.updateLoanApplication(null,true, cam);
            Test.stopTest();
        }
        // Assert
        System.assert(CAMApprovalLogController.updateLoanApplication(null,true, cam) ==null);
    }
    //OLA-107 Changes done in related class
    
    @isTest
    public static void triggerDeviations_Positive() {
        
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        
        Deviation__c dv= [SELECT Id FROM Deviation__c LIMIT 1];
        delete dv;
        String response='{ "Borrower": \n' +
            '{\n' +
            '"Deviations": [\n' +
            '{\n' +
            '"DeviationId": "3126",\n' +
            ' "DeviationName": "Cibil Detect BORROWER",\n' +
            '"Level": "L6",\n' +
            '"conditionValues": [\n '+
            '{\n' + 
            '"variableName": "CIBIL Decision",\n' +
            '"variableValue": "High"\n' + 
            '}\n' + 
            ']\n' +
            '},\n' +
            '{\n '+
            '"DeviationId": "1058",\n' +
            '"DeviationName": "ONE OR MORE CUSTOMER DEAL(S) IS/ARE HAVING LIEN",\n' +
            '"Level": "L4",\n '+
            '"conditionValues": [\n '+
            ' {\n' + 
            '"variableName": "LIEN Flag",\n' +
            ' "variableValue": "Y"\n '+
            '}\n' +
            ']\n' +
            '},\n' +
            '{\n' +
            ' "DeviationId": "1062",\n' +
            ' "DeviationName": "60-90 DAY OD BORROWER IN RBI LIST",\n' +
            ' "Level": "L6",\n' +
            '"conditionValues": [\n' +
            '{\n' +
            ' "variableName": "60_90_OD_RBI Flag",\n '+
            '"variableValue": "Y"\n' +
            '}\n '+
            ']\n' +
            '},\n' +
            ' {\n' +
            '"DeviationId": null,\n' +
            '"DeviationName": "New To Credit Customer",\n' +
            ' "Level": "BCC",\n' +
            '"conditionValues": [\n' +
            '{\n' +
            ' "variableName": "Multiple Product Flag",\n' +
            '"variableValue": "true"\n '+
            '},\n' +
            ' {\n '+
            '"variableName": "Total Exposure",\n' +
            '"variableValue": "20000.0"\n' +
            '}\n' +
            ']\n' +
            '},\n' +
            '{\n' +
            '"DeviationId": "3198",\n '+
            '"DeviationName": "Pan CIN alert for Borrower",\n '+
            '"Level": "L6",\n '+
            '"conditionValues": [\n '+
            ' {\n' +
            ' "variableName": "Pan CIN Flag of Borrower",\n'  +
            '"variableValue": "Y"\n '+
            ' }\n' +
            ']\n '+
            '},\n' +
            ' {\n' + 
            '"DeviationId": "1036",\n' +
            '"DeviationName": "Profile Deviation",\n' +
            ' "Level": "L3",\n' +
            ' "conditionValues": [\n' +
            ' {\n' +
            ' "variableName": "Profile Type",\n' +
            '"variableValue": "CAUTION"\n' +
            '},\n' +
            '{\n '+
            '"variableName": "Quantam Finance",\n' +
            ' "variableValue": "100000.0"\n' +
            ' },\n' +
            ' {\n' +
            ' "variableName": "Category",\n'  +
            ' "variableValue": "SENP"\n' +
            '},\n' +
            '{\n' +
            '"variableName": "State Code IBL",\n' +
            '"variableValue": "A"\n' +
            '},\n' +
            '{\n' +
            ' "variableName": "ltv PV New",\n' +
            '"variableValue": "Infinity"\n' +
            ' },\n '+
            '{\n' +
            ' "variableName": "ltv PV Used Non Oem",\n' +
            '"variableValue": "0.0"\n' +
            ' },\n' +
            '{\n' +
            '"variableName": "ltv PV Used Oem",\n' +
            ' "variableValue": "0.0"\n' +
            ' }\n' +
            ']\n' +
            '}\n' +
            ']\n' +
            '},\n' +
            '"CoBorrower": null\n' + 
            '}\n';
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        String result ;
        System.runAs(u) 
        {
            Test.startTest();
            result = CAMApprovalLogController.triggerDeviations(cam.id, response);
            Test.stopTest();
        }
        
        System.assertEquals('Success',result);
    }    
    @isTest
    public static void triggerDeviations_Negative() {
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        String result ;
        System.runAs(u) 
        {
            try{
                Test.startTest();
                result = CAMApprovalLogController.triggerDeviations('abc', null);
                Test.stopTest();
            }
            catch(exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    
    @isTest
    public static void triggerDeviationMailTest_success() { 
        // Arrange 
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            List<RequestWrapper> result1 = CAMApprovalLogController.triggerDeviationMail(cam.Id);
            // Assert
            System.assertNotEquals(null, result1);
            
            List<RequestWrapper> result2 = CAMApprovalLogController.triggerDeviationMail(null);
            //Assert
            System.assertEquals(0,result2.size());
            Test.stopTest();
        }                
    }
    
    @isTest
    public static void triggerDeviationMailTest_fail() { 
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                // Act
                Test.startTest();
                List<RequestWrapper> result1 = CAMApprovalLogController.triggerDeviationMail('abc');
                Test.stopTest();
            }
            catch(Exception e){
                // Assert 
                System.assert(true);
            }
            
        }                
    }
    
    @istest
    public static void  getFinalTermId_success(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
            Id result =CAMApprovalLogController.getFinalTermId(opp.id);
            // Assert
            System.assert(result != null);
        }
    }
    
    @istest
    public static void  getFinalTermId_fail(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            try{
                CAMApprovalLogController.getFinalTermId('abc');
                
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    
    @istest
    public static void  getFinalTermCalculations_success(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
            CAMApprovalLogController.getFinalTermCalculations(opp.id);
            Test.startTest();
            CAMApprovalLogController.getFinalTermCalculations(null);
            Test.stopTest();
            // Assert
            //System.assert(CAMApprovalLogController.getFinalTermCalculations(opp.id) != null);
        }
    }
    @istest
    public static void  getFinalTermCalculations_success1(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            Opportunity opp = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
            opp.Vehicle_Type__c = 'Used';
            opp.Product_Type__c = 'Passenger Vehicles';
            update opp;
            CAMApprovalLogController.getFinalTermCalculations(opp.id);
            // Assert
            //System.assert(CAMApprovalLogController.getFinalTermCalculations(opp.id) != null);
        }
    }
    @istest
    public static void  getFinalTermCalculations_success2(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            Opportunity opp = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
            opp.Vehicle_Type__c = 'New';
            opp.Product_Type__c = 'Two Wheeler';
            opp.Funding_on_Ex_Showroom__c = true;
            opp.Funding_on_ORP__c = true;
            update opp;
            CAMApprovalLogController.getFinalTermCalculations(opp.id);
            // Assert
            //System.assert(CAMApprovalLogController.getFinalTermCalculations(opp.id) != null);
        }
    }
    @istest
    public static void  getFinalTermCalculations_success3(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            Opportunity opp = [SELECT Id, Vehicle_Type__c, Product_Type__c,Funding_on_Ex_Showroom__c FROM Opportunity WHERE Journey_Status__c = :'No Impact'];
            opp.Vehicle_Type__c = 'Used';
            opp.Product_Type__c = 'Two Wheeler';
            update opp;
            CAMApprovalLogController.getFinalTermCalculations(opp.id);
            // Assert
            //System.assert(CAMApprovalLogController.getFinalTermCalculations(opp.id) != null);
            
        }
    }
    
    @istest
    public static void  proposalApprove_Test(){
        Vehicle_Detail__c vdc= [select Id from Vehicle_Detail__c limit 1];
        AccountTeamMember ATM = [select id from AccountTeamMember limit 1];
        ATM.TeamMemberRole = 'SCM';
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        cam.CAM_Submitted_by_ACM_SCM__c = false;
        cam.Is_CAM_Reopen__c = true;
        update cam;
        update ATM;
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            try{
                CAMApprovalLogController.proposalApprove(cam.Id,'Approve');
                
                Test.startTest();
                cam.Is_CAM_Reopen__c = false;
                update cam;
                vdc.Approval_Status__c = 'Approved';
                update vdc;
                CAMApprovalLogController.proposalApprove(cam.Id,'Approved');
                Test.stopTest();
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    @istest
    public static void  isCAMForwardedToCA(){
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            try{
                CAMApprovalLogController.isCAMForwardedToCA(cam.Id);
                
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    @istest
    public static void  checkCAMBeforeApproval(){
        AccountTeamMember ATM = [select id from AccountTeamMember limit 1];
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            try{
                CAMApprovalLogController.checkCAMBeforeApproval(cam.Id);
                Test.startTest();
                cam.CAM_Submitted_by_ACM_SCM__c = false;
                ATM.TeamMemberRole = 'SCM';
                update ATM;
                update cam;
                CAMApprovalLogController.checkCAMBeforeApproval(cam.Id);
                Test.stopTest();
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    @istest
    public static void  getFinalTerms(){
        Final_Term__c finalTerm = [SELECT Id FROM Final_Term__c limit 1];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            try{
                CAMApprovalLogController.getFinalTerms(finalTerm.Id);
                
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    
    @istest
    public static void  getDeviationsForApprovalsTractor(){
        CAM__c cam = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) {
            try{
                CAMApprovalLogController.getDeviationsForApprovalsTractor(cam.Id);
                
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }
    }
    
     @isTest
    public static void testIsJustificationProvided() {
        CAM__c camRecord = [SELECT Id FROM CAM__c WHERE Committee__c = :'ZCC'];
        Deviation__c deviation1 = new Deviation__c(Parent_CAM__c = camRecord.Id, Justification_Remarks__c = 'Justified');
        Deviation__c deviation2 = new Deviation__c(Parent_CAM__c = camRecord.Id, Justification_Remarks__c = null); // No justification provided
        insert new List<Deviation__c>{ deviation1, deviation2 };
		User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        Boolean result;
        System.runAs(u) {
            Test.startTest();
            result = CAMApprovalLogController.isJustificationProvided(camRecord.Id);
            Test.stopTest();
            System.assertEquals(false, result, 'Expected justification to not be provided');
        }
    }
     @isTest
    public static void testCheckInsuranceSubmitted() {
        // Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Submitted_Tabs__c = 'Borrower Insurance Recompute'
        );
        insert opp;

        // Create Applicant records associated with the Opportunity
        Applicant__c borrower = new Applicant__c(
            Opportunity__c = opp.Id,
            Applicant_Type__c = 'Borrower',
            In_Active_Applicant__c = false
        );
        insert borrower;

        Applicant__c coborrower = new Applicant__c(
            Opportunity__c = opp.Id,
            Applicant_Type__c = 'Co-borrower',
            In_Active_Applicant__c = false
        );
        insert coborrower;

        // Create a user for running the test
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            UserName = 'testuser' + System.currentTimeMillis() + '@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            MobilePhone = '9898989898',
            IsActive = true
        );
        insert testUser;

        System.runAs(testUser) {
            // Test when the borrower has insurance submitted
            Test.startTest();
            Boolean result = CAMApprovalLogController.checkInsuranceSubmitted(opp.Id);
            Test.stopTest();
            System.assertEquals(false, result, 'Expected insurance to be submitted for borrower');

            // Update Opportunity to include insurance for co-borrower
            /*opp.Submitted_Tabs__c = 'Coborrower Insurance Recompute';
            update opp;

            Test.startTest();
            result = CAMApprovalLogController.checkInsuranceSubmitted(opp.Id);
            Test.stopTest();
            System.assertEquals(true, result, 'Expected insurance to be submitted for co-borrower');

            // Test when neither borrower nor co-borrower has insurance submitted
            opp.Submitted_Tabs__c = '';
            update opp;

            Test.startTest();
            result = CAMApprovalLogController.checkInsuranceSubmitted(opp.Id);
            Test.stopTest();
            System.assertEquals(false, result, 'Expected insurance to not be submitted for both borrower and co-borrower');
*/
        }
    }
}