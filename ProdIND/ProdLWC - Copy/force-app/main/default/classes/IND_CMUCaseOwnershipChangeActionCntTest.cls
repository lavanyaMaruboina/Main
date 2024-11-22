@isTest
public class IND_CMUCaseOwnershipChangeActionCntTest {
    @isTest
    public static void getUserListTest1(){
        try{
            UserRole r = [select id,Name,DeveloperName from UserRole where DeveloperName = 'CMU_Team_Lead'];
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                              TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123364555222999@indusbank.com',MobilePhone = '9089078967',UserRoleId = r.Id);
            insert u;
            System.runAs(u) 
            {
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
                
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
                
                Test.startTest();
                IND_CMUCaseOwnershipChangeActionCntrl.getUserList(cs3.Id);
                update u;
                IND_CMUCaseOwnershipChangeActionCntrl.getUserList(cs3.Id);
                Test.stopTest();
                IND_CMUCaseOwnershipChangeActionCntrl.getUserList(null);
            }    
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateOwnerTest1(){
        try{
            Opportunity opfv1 = new Opportunity();
            opfv1.StageName = 'Credit Processing';
            opfv1.CloseDate = Date.newInstance(2021, 1, 11);
            opfv1.Name = 'testone';
            insert opfv1;
            
            Applicant__c apfv1 = new Applicant__c();
            apfv1.Opportunity__c = opfv1.Id;
            apfv1.Contact_number__c = '9743514830';
            apfv1.Applicant_Type__c = 'Borrower';
            apfv1.In_Active_Applicant__c = false;
            insert apfv1;
            
            case cs3 = new case();
            cs3.Loan_Application__c = opfv1.Id;
            cs3.Applicant__c = apfv1.Id;
            cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs3.Status = 'Pending-Off Role Employee App';
            cs3.Origin = 'Web';
            cs3.Type = System.Label.Case_Current_Residence_FI_Type;
            insert cs3; 
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                              TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123364555222999@indusbank.com',MobilePhone = '9089078967');
            insert u;
            
            List<User> usrList = new List<User>();
            usrList.add(u);
            
            IND_CMUCaseOwnershipChangeActionCntrl.ResponseWrapper rw1 = new IND_CMUCaseOwnershipChangeActionCntrl.ResponseWrapper();
            //  rw1.userList = usrList;
            
            Test.startTest();
            IND_CMUCaseOwnershipChangeActionCntrl.updateOwner(cs3.Id,UserInfo.getUserId());
            IND_CMUCaseOwnershipChangeActionCntrl.updateOwner(null, null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getUserListTest2(){
        try{
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                              TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123364555222999@indusbank.com',MobilePhone = '9089078967');
            insert u;
            System.runAs(u) 
            {
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
                
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
                
                Test.startTest();
                IND_CMUCaseOwnershipChangeActionCntrl.getUserList(null);
                IND_CMUCaseOwnershipChangeActionCntrl.updateOwner(cs3.Id,cs3.Id);
                Test.stopTest();
            }    
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
}