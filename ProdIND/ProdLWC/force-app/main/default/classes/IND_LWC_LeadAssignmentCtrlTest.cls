/*
* @Name         IND_LWC_LeadAssignmentCtrlTest
* @Author       Nitin Sehgal
* @Company      Persistent Systems
* @Description  This class is used as a test class for IND_LWC_LeadAssignmentCtrl main class..
* Inputs:       None
* History:
*/

@isTest(SeeAllData=false)
public class IND_LWC_LeadAssignmentCtrlTest {
    
    @testSetup 
    static void Setup() {
        //Creating the test user role.
        UserRole userRole1 = new UserRole(DeveloperName = 'NPH_CL1', Name = 'NPH (CL)');
        insert userRole1;
        
        //Creating the test user role.
        UserRole userRole2 = new UserRole(DeveloperName = 'HHEAD1', Name = 'HHEAD', ParentRoleId = userRole1.Id);
        insert userRole2;        
        
        //Creating the test user.
        User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            MobilePhone = '9701498575',
            TimeZoneSidKey = 'Asia/Colombo',
            EmailEncodingKey = 'UTF-8',
            Maker_Id__c = '123',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRole1.Id
        );
        insert u1;
        
        //Creating the test user.
        User u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'lastName',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Colombo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Maker_Id__c = '123',
            MobilePhone = '9701498575',
            UserRoleId = userRole2.Id
        );
        insert u2;
        
    }
    
    /* 
    * Test method for filterUserList  method.
    * Added By : Nitin Sehgal.
    */
    @isTest
    public static void testFilterUserList(){
        try{
        Account testAccount = new Account(Name='Test Account');
        	insert testAccount;
            User ususerRole1 = [Select Id from User where lastName = 'last'];
            User ususerRole2 = [Select Id from User where lastName = 'lastName'];
            Opportunity opp = new Opportunity();
            System.runAs(ususerRole2){
                opp.Name= 'Opportunity';
                opp.StageName='Loan Initiation';
                opp.CloseDate=System.today().addMonths(1);
                opp.AccountId= testAccount.Id;
                opp.Product_Type__c = 'Two Wheeler';
                insert opp;
            }
            Opportunity opp1 = [SELECT ID, Owner.UserRoleId, OwnerId FROM Opportunity WHERE name = 'Opportunity'];
            Test.startTest();
        	List<User> usrs = IND_LWC_LeadAssignmentCtrl.filterUserList(opp1.Id, 'last');
            List<User> usrsException = IND_LWC_LeadAssignmentCtrl.filterUserList(null, 'last');
            Test.stopTest();
        	System.assertEquals(null, usrs);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
   
    /* 
    * Test method for recordHierarchyCheck method.
    * Added By : Nitin Sehgal.
    */
    @isTest
    public static void testIfUserIsHigherInHierarchy(){
        try{
            Account testAccount = new Account(Name='Test Account');
        	insert testAccount;
            User ususerRole1 = [Select Id from User where lastName = 'last'];
            User ususerRole2 = [Select Id from User where lastName = 'lastName'];
            Opportunity opp = new Opportunity();
            System.runAs(ususerRole2){
                opp.Name= 'Opportunity';
                opp.StageName='Loan Initiation';
                opp.CloseDate=System.today().addMonths(1);
                opp.AccountId= testAccount.Id;
                opp.Product_Type__c = 'Two Wheeler';
                insert opp;
            }
            Opportunity opp1 = [SELECT ID, Owner.UserRoleId, OwnerId FROM Opportunity WHERE name = 'Opportunity'];
            System.runAs(ususerRole1){
                //Checking if the user is above in the role hierarchy or opportunity owner
                Test.startTest();
                Boolean isHigherInHierarchy = IND_LWC_LeadAssignmentCtrl.recordHierarchyCheck(opp1.Owner.UserRoleId, opp1.OwnerId);
                Boolean isHigherInHierarchyException = IND_LWC_LeadAssignmentCtrl.recordHierarchyCheck(opp1.Owner.UserRoleId, null);
                Test.stopTest();
                system.assertEquals(true,isHigherInHierarchy);
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    /* 
    * Test method for leadAssignment method.
    * Added By : Nitin Sehgal.
    */
    @isTest
    public static void testLeadAssignment(){
        try{
            Account testAccount = new Account(Name='Test Account');
        	insert testAccount;
            //Creating custom setting configuration
            /*
            Lead_Assignment_Roles__mdt objSysConfig = new Lead_Assignment_Roles__mdt();
            objSysConfig.Eligible_Roles__c = 'MO,MA';
            objSysConfig.Label = 'MO';
            insert objSysConfig;
            
            System_Configuration__c sysConfig = new System_Configuration__c();
            sysConfig.Name = 'System Configuration';
            sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
            sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
            sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
            sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
            insert sysConfig;
			*/
            
            User ususerRole1 = [Select Id from User where lastName = 'last'];
            User ususerRole2 = [Select Id from User where lastName = 'lastName'];
            Opportunity opp = new Opportunity();
            System.runAs(ususerRole2){
                opp.Name= 'Opportunity';
                opp.StageName='Loan Initiation';
                opp.CloseDate=System.today().addMonths(1);
                opp.AccountId= testAccount.Id;
                opp.Product_Type__c = 'Two Wheeler';
                insert opp;
            }
            Opportunity opp1 = [SELECT ID, Owner.UserRoleId, OwnerId FROM Opportunity WHERE name = 'Opportunity'];
            System.runAs(ususerRole1){
                /*
                //Checking if the user is above in the role hierarchy or opportunity owner
                Boolean isHigherInHierarchy = IND_LWC_LeadAssignmentCtrl.recordHierarchyCheck(opp1.Owner.UserRoleId, opp1.OwnerId);
                // Getting the filtered list based on roles and custom settings
                List<User> usrs = IND_LWC_LeadAssignmentCtrl.filterUserList(opp1.Id, 'last'); */               
                Test.startTest();
                //Assigning the opportunity to the user
                Boolean isAssigned = IND_LWC_LeadAssignmentCtrl.leadAssignment(opp.Id, ususerRole1.Id);
                Boolean isAssignedException = IND_LWC_LeadAssignmentCtrl.leadAssignment(null, null);
                Test.stopTest();
                system.assertEquals(true,isAssigned);
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    /** 
    * Test method for leadRecall method.
    * Added By : Nitin Sehgal.
    */
    @isTest
    public static void testLeadRecall(){
        try{
            Account testAccount = new Account(Name='Test Account');
        	insert testAccount;
            //Creating custom setting configuration
            System_Configuration__c sysConfig = new System_Configuration__c();
            sysConfig.Name = 'System Configuration';
            sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
            sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
            sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
            sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
            insert sysConfig;
            
            User ususerRole1 = [Select Id from User where lastName = 'last'];
            User ususerRole2 = [Select Id from User where lastName = 'lastName'];
            Opportunity opp = new Opportunity();
            System.runAs(ususerRole2){
                opp.Name= 'Opportunity';
                opp.StageName='Loan Initiation';
                opp.CloseDate=System.today().addMonths(1);
                opp.AccountId= testAccount.Id;
                opp.Product_Type__c = 'Two Wheeler';
                insert opp;
            }
            Opportunity opp1 = [SELECT ID, Owner.UserRoleId, OwnerId FROM Opportunity WHERE name = 'Opportunity'];
            System.runAs(ususerRole1){
                /*
                //Checking if the user is above in the role hierarchy or opportunity owner
                Boolean isHigherInHierarchy = IND_LWC_LeadAssignmentCtrl.recordHierarchyCheck(opp1.Owner.UserRoleId, opp1.OwnerId);
                // Getting the filtered list based on roles and custom settings
                List<User> usrs = IND_LWC_LeadAssignmentCtrl.filterUserList(opp1.Id, 'last');
                */
				
                Test.startTest();  
                //Assigning the opportunity to the use
                Boolean isAssigned = IND_LWC_LeadAssignmentCtrl.leadAssignment(opp.Id, ususerRole1.Id);
                Boolean isRecalled = IND_LWC_LeadAssignmentCtrl.leadRecall(opp.Id, ususerRole2.Id);
                Boolean isRecalledException = IND_LWC_LeadAssignmentCtrl.leadRecall(null,ususerRole1.Id);
                Test.stopTest();
                system.assertEquals(true,isAssigned);
                system.assertEquals(false,isRecalled);
            }
            System.runAs(ususerRole2){
                Boolean isRecalled = IND_LWC_LeadAssignmentCtrl.leadRecall(opp.Id, opp1.OwnerId);
                system.assertEquals(true,isRecalled);
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}