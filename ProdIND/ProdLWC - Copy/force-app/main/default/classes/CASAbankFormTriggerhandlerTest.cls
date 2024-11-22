/*------------------------------------------------------------
Author:        Sushil B
Company:       Manureva Solutions
Description:   Test class for on CASAbankFormTriggerhandler.
Inputs:        None 
Test Classes:  NA
History
Date            Author              Comments
-------------------------------------------------------------
29-06-2022      Sushil B            Created
------------------------------------------------------------*/
@IsTest
public class CASAbankFormTriggerhandlerTest {
    
    @testSetup
    static void setupTestData(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          timezonesidkey='america/los_angeles',username='test_userprod123987@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = new Opportunity();
            opp.Name = 'VDR Test';
            opp.CloseDate = Date.today();
            opp.StageName='Disbursement Request Preparation';
            opptyList.add(opp);
            if(Schema.sObjectType.Opportunity.isCreateable())
            	insert opptyList;
        }
    }          
    
    
    @IsTest
    public static void test_generateUniqueFormNumber(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123987@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            test.startTest();
            //create CASA_Bank_Form__c records
            Opportunity opp = [Select Id From Opportunity LIMIT 1];
            CASA_Bank_Form__c  CASA = new CASA_Bank_Form__c();
            CASA.Name = 'sawesdgfgh';
            CASA.Saving_Account_opened_for__c='Borrower';
            CASA.Saving_Account_opening_form_No__c='3500000016';
            CASA.Loan_Application__c = opp.Id;
            insert CASA;
            CASA_Bank_Form__c casaAfter = [Select Id, Saving_Account_opening_form_No__c From CASA_Bank_Form__c Where Id =: CASA.Id];
            System.assertNotEquals(null, casaAfter);
            System.assertEquals('3500000017', casaAfter.Saving_Account_opening_form_No__c);
            test.stopTest();
        }
    }
    
}