/*------------------------------------------------------------
Author:        Sushil B
Company:       Manureva Solutions
Description:   Test class for on CreateDealNumberBeforeInsert.
Inputs:        None 
Test Classes:  NA
History
Date            Author              Comments
-------------------------------------------------------------
29-06-2022      Sushil B            Created
------------------------------------------------------------*/
@IsTest
public class CreateDealNumberBeforeInsertTest {
    @testSetup
    static void setupTestData(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          timezonesidkey='america/los_angeles',username='test_userprod27@indusbank.com',MobilePhone = '9089078967');
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
    static void Test_CreateDealNumberBeforeInser(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod27@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try {
                Test.startTest();
                //Create Deal_Number__c
                Deal_Number__c dn = new Deal_Number__c();
                dn.DNField1__c = '9';
                dn.DNField2__c = '9';
                dn.DNField3__c = '99999';
                RecursiveTriggerHandler.isFirstTime = true;
                insert dn;
                Deal_Number__c dealNumAfter = [Select Id, DNField1__c, DNField2__c, DNField3__c From Deal_Number__c Where Id =:dn.Id];
                System.assertNotEquals(null, dealNumAfter);
                System.assertNotEquals(null, dealNumAfter.DNField1__c);
                System.assertNotEquals(null, dealNumAfter.DNField2__c);
                System.assertNotEquals(null, dealNumAfter.DNField3__c);
                System.assertEquals(false, RecursiveTriggerHandler.isFirstTime);
                Test.stopTest();
            } catch (Exception e) {
                System.debug(e);
            }
        }
    }
}