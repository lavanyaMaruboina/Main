@isTest
public class customerDedupeRevisedClassTest {
 @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',
                          MobilePhone='8234567890');
        insert u;
        System.runAs(u) 
        {
            
            Account acc = new Account();
            acc.Name = 'test account';
            acc.State__c = 'MAHARASHTRA';
            acc.Phone = '+914335225';
            insert acc;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false); 
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.PassengerVehicles;
            opp.Sanction_Status__c = System.Label.nonStp;  
            opp.Agent_BL_code__c = 'AHZ';
            opp.Deal_Number__c = null; 
            opp.AccountId = acc.Id;
            opp.Required_ROI__c = 9;
            opp.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp.Product_Type__c =  system.label.TwoWheeler;
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            oppList.add(opp);  
            
            Opportunity opp1= TestDataUtility.createTestOpportunityForOcr(false);
            oppList.add(opp1);
            insert oppList;
            
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Name = 'testapplicant1';
            applicant1.Father_s_name__c = 'fsfdsf';
            applicant1.Opportunity__c = oppList[0].Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicant1.Contact_Number__c = '+9123456789';
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.Email_Id_2__c = 'test2@abc.com';
            applicant1.Email_Id_1__c = 'test1@abc.com';
            applicant1.Email_Id__c = 'test@abc.com';
            applicantList.add(applicant1);
            
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt1(false);
            applicant2.Name = 'testapplicant1';
            applicant2.Father_s_name__c = 'fsfdsf';
            applicant2.Opportunity__c = oppList[0].Id;
            applicant2.Scorecard_Decision__c = 'Light Red';
            applicant2.Contact_Number__c = '+9123456789';
            applicant2.Applicant_Type__c = System.Label.CoBorrower;
            applicant2.Email_Id_2__c = 'test2@abc.com';
            applicant2.Email_Id_1__c = 'test1@abc.com';
            applicant2.Email_Id__c = 'test@abc.com';
            applicantList.add(applicant2);
            
            INSERT applicantList;          
        }
    }
    
    @isTest
    public static void withdrawnLeadBasedOnDecisionTest(){
        try{
            String loanApplicationNo = [Select id,Lead_Number__c From Opportunity LIMIT 1].Lead_Number__c;
            String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            customerDedupeRevisedClass.withdrawnLeadBasedOnDecision(loanApplicationNo,'Yes',applicantId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void withdrawnLeadBasedOnDecisionTest1(){
        try{
            List<Opportunity> oppList  = [Select id,Lead_Number__c From Opportunity];
            String leadNumberData = '';
            for(Opportunity opp : oppList){
                leadNumberData = opp.Lead_number__c + ',' + leadNumberData;
            }
            String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            customerDedupeRevisedClass.withdrawnLeadBasedOnDecision(leadNumberData,'Yes',applicantId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
     @isTest
    public static void withdrawnLeadsTest(){
        try{
            List<Opportunity> oppList = [Select id,Lead_Number__c From Opportunity];
            customerDedupeRevisedClass.withdrawnLeads(oppList);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void updateApplicantRecordTest(){
        try{
           	String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            customerDedupeRevisedClass.updateApplicantRecord(applicantId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }

     @isTest
    public static void updateApplicantIsAllRecordValidTest(){
        try{
           	String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            customerDedupeRevisedClass.updateApplicantIsAllRecordValid(applicantId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void salesUserValidateAnyCodeTest(){
        try{
           	String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            customerDedupeRevisedClass.salesUserValidateAnyCode(applicantId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void updateJourneyStopTest(){
        try{
           	List<Opportunity> oppList = [Select id,Lead_Number__c From Opportunity LIMIT 1];
            customerDedupeRevisedClass.updateJourneyStop(oppList[0].Id);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void TradeCertificateValidationTest(){
        try{
                Opportunity opds1 = new Opportunity();
                opds1.StageName = 'Qualification';
                opds1.CloseDate = Date.newInstance(2021, 1, 11);
                opds1.Name = 'testone';
                opds1.Agent_BL_code__c = 'AG-00';
                opds1.Product_Type__c = 'Two Wheeler';
                opds1.Vehicle_Type__c = 'New';
              //  opds1.Agent_BL_code__c = 'AG-001';
                insert opds1;
            
                Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
              //  bcd1.Address_1__c = 'testadd';
              //  bcd1.Address_2__c = 'testadd2';
                bcd1.Bl_Code__c = opds1.Agent_BL_code__c;
                bcd1.Name = 'test';
                insert bcd1;
            
                VehicleTypeCategory__mdt vtc1 = new VehicleTypeCategory__mdt();
                vtc1.vehicleType__c = opds1.Vehicle_Type__c;
                vtc1.productType__c = opds1.Product_Type__c;
                vtc1.Product_Code__c = 'test123';
                
            
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Make';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'PASSENGER VEHICLES';
                prd1.ProductCode = vtc1.Product_Code__c;
                insert prd1;
        
               Trade_Certificate_Fee_master__c tcf1 = new Trade_Certificate_Fee_master__c();
               tcf1.Active_Flag__c = true;
               tcf1.Bl_Code__c = bcd1.Id;
               tcf1.Fee__c = 10000.00;
               tcf1.Unique_Identifier__c = '5';
               tcf1.ProductCode__c = prd1.Id;
               tcf1.Product__c = 're';
               insert tcf1;
            
               Test.startTest();
                      customerDedupeRevisedClass.TradeCertificateValidation(opds1.Id);
                      customerDedupeRevisedClass.TradeCertificateValidation('test');
               Test.stopTest();
            
        } catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    

}