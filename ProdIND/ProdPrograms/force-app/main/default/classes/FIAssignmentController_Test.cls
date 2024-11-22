//Yugandhar
@isTest
public class FIAssignmentController_Test {
    @isTest
    public static void getLoanApplicationDetailsTest(){
        
                Opportunity opgl1 = new Opportunity();
                opgl1.StageName = 'Qualification';
                opgl1.CloseDate = Date.newInstance(2021, 1, 11);
                opgl1.Name = 'testone';
                insert opgl1;
        
                Test.startTest();
                    FIAssignmentController.getLoanApplicationDetails(opgl1.Id,System.Label.Opportunity);
                Test.stopTest();
    }
    
    @isTest
    public static void getLoanApplicationDetailsTest1(){
        
                Opportunity opgl2 = new Opportunity();
                opgl2.StageName = 'Qualification';
                opgl2.CloseDate = Date.newInstance(2021, 1, 11);
                opgl2.Name = 'testone';
                insert opgl2;
        
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = opgl2.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                insert apt1;
        
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Make';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'PASSENGER VEHICLES';
                insert prd1;
        
                Case c1 = new Case();
                c1.Loan_Application__c = opgl2.Id;
                c1.ProductId = prd1.Id;
                c1.Applicant__c = apt1.Id;
                c1.Origin = 'Email';
                insert c1;
        
                Test.startTest();
                    FIAssignmentController.getLoanApplicationDetails(c1.Id,'Case');
                Test.stopTest();
    }
    
    @isTest
    public static void assignmentFIAppTest(){
                Account accVal = new Account(Name='Test Account');
                insert accVal;
            
                Opportunity opgl2 = new Opportunity();
                opgl2.StageName = system.label.Credit_Processing;
                opgl2.CloseDate = Date.newInstance(2021, 1, 11);
                opgl2.Name = 'testone';
                opgl2.Product_Type__c = system.label.PassengerVehicles;
                opgl2.Sub_Stage__c = system.label.View_Application_Details;
                opgl2.View_Application_Sub_Stages__c = 'Lead/KYC Details';
                insert opgl2;
        
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = opgl2.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                apt1.In_Active_Applicant__c = false;
                insert apt1;
        
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Make';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'PASSENGER VEHICLES';
                insert prd1;
        
                Case c1 = new Case();
                c1.Loan_Application__c = opgl2.Id;
                c1.ProductId = prd1.Id;
                c1.Applicant__c = apt1.Id;
                c1.Origin = 'Email';
                c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                insert c1;
                 
        		AccountTeamMember atm1 = new AccountTeamMember();
                atm1.AccountId = accVal.Id;
                atm1.TeamMemberRole = 'CVO';
                atm1.UserId = UserInfo.getUserId();
                insert atm1;
        
                Test.startTest();
                     FIAssignmentController.assignmentFIApp('test123',opgl2.Id,UserInfo.getUserId(),UserInfo.getUserId(),True,accVal.Id);
                Test.stopTest();
    }
    
    @isTest
    public static void assignmentFIAppTest2(){
        try{	
            	Account accVal = new Account(Name='Test Account');
        		insert accVal;
            
                Opportunity opgl2 = new Opportunity();
                opgl2.StageName = system.label.Credit_Processing;
                opgl2.CloseDate = Date.newInstance(2021, 1, 11);
                opgl2.Name = 'testone';
                opgl2.Product_Type__c = system.label.PassengerVehicles;
                opgl2.Sub_Stage__c = system.label.View_Application_Details;
                opgl2.View_Application_Sub_Stages__c = 'Lead/KYC Details';
                insert opgl2;
        
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = opgl2.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                apt1.In_Active_Applicant__c = false;
                insert apt1;
        
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Make';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'PASSENGER VEHICLES';
                insert prd1;
        
                Case c1 = new Case();
                c1.Loan_Application__c = opgl2.Id;
                c1.ProductId = prd1.Id;
                c1.Applicant__c = apt1.Id;
                c1.Origin = 'Email';
            //    c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                insert c1;
        
                Test.startTest();
                     FIAssignmentController.assignmentFIApp(c1.Id,opgl2.Id,UserInfo.getUserId(),UserInfo.getUserId(),false,accVal.Id);
                     FIAssignmentController.assignmentFIApp('test12','test12',UserInfo.getUserId(),UserInfo.getUserId(),false,accVal.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
   
    @isTest
    public static void applicationAssignmentTWTest(){
        try{
        
        Account au1 = new Account();
        au1.Name = 'test';
        au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert au1;
            
        Opportunity optg1 = new Opportunity();
        optg1.AccountId = au1.Id;
        optg1.StageName = 'Qualification';
        optg1.CloseDate = Date.newInstance(2021, 1, 11);
        optg1.Name = 'testone';
        optg1.OwnerId = UserInfo.getUserId();
        optg1.Product_Type__c = System.Label.TwoWheeler;
        insert optg1;
        
        Applicant__c apt1 = new Applicant__c();
        apt1.Opportunity__c = optg1.Id;
        apt1.Contact_number__c = '9743514830';
        apt1.Applicant_Type__c = 'Borrower';
        apt1.In_Active_Applicant__c = false;
        insert apt1;
        
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.AccountId = optg1.AccountId;
	    atm1.TeamMemberRole = 'CVO';
        atm1.UserId = UserInfo.getUserId();
        insert atm1;
        
        Test.startTest();
              FIAssignmentController.applicationAssignmentTW(optg1.Id,true);
              FIAssignmentController.applicationAssignmentTW(optg1.Id,false);
              FIAssignmentController.applicationAssignmentTW('test',true);
        Test.stopTest();
        }catch(Exception e){
          //  System.assertEquals('Script-thrown exception', e.getMessage());
        }   

    }
    
     @isTest
    public static void applicationAssignmentTWTest1(){
        try{
    
        Opportunity optg1 = new Opportunity();
    //    optg1.AccountId = au2.Id;
        optg1.StageName = 'Qualification';
        optg1.CloseDate = Date.newInstance(2021, 1, 11);
        optg1.Name = 'testone';
        optg1.OwnerId = UserInfo.getUserId();
     //   optg1.Product_Type__c = System.Label.TwoWheeler;
        insert optg1;
   
            
        Test.startTest();
              FIAssignmentController.applicationAssignmentTW(optg1.Id,true);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }   

    }
    
    @isTest
    public static void assignFITest(){
        try{
              Account au1 = new Account();
              au1.Name = 'test';
              au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
              insert au1;
            
              Opportunity opds1 = new Opportunity();
              opds1.AccountId = au1.Id;
              opds1.StageName = 'Qualification';
              opds1.CloseDate = Date.newInstance(2021, 1, 11);
              opds1.Name = 'testone';
              insert opds1;
            
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = opds1.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                apt1.In_Active_Applicant__c = false;
                insert apt1;
        
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Make';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'PASSENGER VEHICLES';
                insert prd1;
        
                Case c1 = new Case();
                c1.Loan_Application__c = opds1.Id;
                c1.ProductId = prd1.Id;
                c1.Applicant__c = apt1.Id;
                c1.Origin = 'Email';
                c1.Status = 'FI Assigned';
                c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                insert c1;
                 
                AccountTeamMember atm1 = new AccountTeamMember();
                atm1.AccountId = opds1.AccountId;
		        atm1.TeamMemberRole = 'FI';
                atm1.UserId = UserInfo.getUserId();
                atm1.FI_Executive_Counter__c = 3;
                insert atm1;
            
              Opportunity opds2 = new Opportunity();
            //  opds1.AccountId = au1.Id;
              opds2.StageName = 'Qualification';
              opds2.CloseDate = Date.newInstance(2021, 1, 11);
              opds2.Name = 'testone';
              insert opds2;
                 
                Test.startTest();
                  //  FIAssignmentController.assignFI(opds1, UserInfo.getUserId());
                  //  FIAssignmentController.assignFI(null, UserInfo.getUserId());
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void assignFITest1(){
        try{
              Account au1 = new Account();
              au1.Name = 'test';
              au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
              insert au1;
            
              Opportunity opds1 = new Opportunity();
              opds1.AccountId = au1.Id;
              opds1.StageName = 'Qualification';
              opds1.CloseDate = Date.newInstance(2021, 1, 11);
              opds1.Name = 'testone';
              insert opds1;
            
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = opds1.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                apt1.In_Active_Applicant__c = false;
                insert apt1;
        
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Make';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'PASSENGER VEHICLES';
                insert prd1;
        
                Case c1 = new Case();
                c1.Loan_Application__c = opds1.Id;
                c1.ProductId = prd1.Id;
                c1.Applicant__c = apt1.Id;
                c1.Origin = 'Email';
                c1.Status = 'FI Assigned';
                c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                insert c1;
                 
           /*     AccountTeamMember atm1 = new AccountTeamMember();
                atm1.AccountId = opds1.AccountId;
		        atm1.TeamMemberRole = 'FI';
                atm1.UserId = UserInfo.getUserId();
                insert atm1; */
                 
                Test.startTest();
                  //  FIAssignmentController.assignFI(opds1, UserInfo.getUserId());
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLowestCounterFIExecutiveTest(){
        
        Map<Id, Decimal> userToCount = new Map<Id, Decimal>();
        userToCount.put(UserInfo.getUserId(),0);
        
        Test.startTest();
           //  FIAssignmentController.getLowestCounterFIExecutive(userToCount);
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateAccountTeamMemberFIExecutiveCounterTest(){
        try{
        Account au1 = new Account();
        au1.Name = 'test';
        au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert au1;
        
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.AccountId = au1.Id;
		atm1.TeamMemberRole = 'FI';
        atm1.UserId = UserInfo.getUserId();
        atm1.FI_Executive_Counter__c = 3;
        insert atm1;
        atmList.add(atm1);
        
        Test.startTest();
            FIAssignmentController.UpdateAccountTeamMemberFIExecutiveCounter(atmList);
            FIAssignmentController.UpdateAccountTeamMemberFIExecutiveCounter(null);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
    }
    
    @isTest
    public static void checkUserRoleTest(){
        
        Account au1 = new Account();
        au1.Name = 'test';
        au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert au1;
            
        Opportunity optg1 = new Opportunity();
        optg1.AccountId = au1.Id;
        optg1.StageName = 'Qualification';
        optg1.CloseDate = Date.newInstance(2021, 1, 11);
        optg1.Name = 'testone';
        optg1.OwnerId = UserInfo.getUserId();
        optg1.Product_Type__c = System.Label.TwoWheeler;
        optg1.Vehicle_Type__c = System.Label.Refinance;
        insert optg1;
        
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.AccountId = optg1.AccountId;
	    atm1.TeamMemberRole = 'MO';
        atm1.UserId = UserInfo.getUserId();
        insert atm1;
        
        Test.startTest();
             FIAssignmentController.checkUserRole(optg1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void checkUserRoleTest1(){
        
        Account au1 = new Account();
        au1.Name = 'test';
        au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert au1;
            
        Opportunity optg2 = new Opportunity();
        optg2.AccountId = au1.Id;
        optg2.StageName = 'Qualification';
        optg2.CloseDate = Date.newInstance(2021, 1, 11);
        optg2.Name = 'testone';
        optg2.OwnerId = UserInfo.getUserId();
        optg2.Product_Type__c = System.Label.TwoWheeler;
        optg2.Vehicle_Type__c = System.Label.Refinance;
        insert optg2;
        
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.AccountId = optg2.AccountId;
	    atm1.TeamMemberRole = 'CVO';
        atm1.UserId = UserInfo.getUserId();
        insert atm1;
        
        Test.startTest();
             FIAssignmentController.checkUserRole(optg2.Id);
        Test.stopTest();
    }
         
}