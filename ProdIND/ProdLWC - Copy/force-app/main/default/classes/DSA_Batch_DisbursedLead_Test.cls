@isTest
public class DSA_Batch_DisbursedLead_Test {
    @testSetup static void setup() {
        Account acc = new Account(Name='test');
        //acc.IsPersonAccount = TRUE;
        insert acc;
        Contact con = new Contact();
        con.Phone = '93252344';
        con.LastName = 'abc';
        con.AccountId = acc.id;
        insert con; 
    }
    @isTest
    public static void testDSA_Batch_DisbursedLead(){
        Contact con = [Select Id from Contact]; 
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='DSA Community User' Limit 1];
        //system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = portalProfile.Id,
                          MobilePhone = '9701498575',Maker_Id__c = '1001',User_Id__c = '29927_MO',
                          TimeZoneSidKey='America/Los_Angeles',
                          //UserRoleId = role.id,
                          ContactId = con.Id,
                          employeenumber = '1',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u;
        system.runAs(u){
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Product_Type__c ='Passenger Vehicles';
            opgd1.Vehicle_Type__c ='Used';
            opgd1.Name = 'testone';
            insert opgd1;
            Final_Term__c finalTerm = new Final_Term__c(
                Loan_Amount__c = '1000000',
                Referrer_Name__c = '1',
                Tenure__c = '60',
                Net_IRR__c = 7,
                EMI_Amount__c = 10000,
                Referrer_Ben_Code__c ='1',
                Loan_Application__c = opgd1.Id);
            Insert finalTerm;
            
            Test.startTest();
            DSA_Batch_DisbursedLead c = new DSA_Batch_DisbursedLead();
            Database.executeBatch(c);
            Test.stopTest();
        }          
    }
}