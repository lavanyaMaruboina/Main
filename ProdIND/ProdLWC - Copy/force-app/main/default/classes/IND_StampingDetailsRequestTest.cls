@isTest
public class IND_StampingDetailsRequestTest {
    
    @testSetUp
    static void testData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');
        insert u;
        System.runAs(u) 
        {
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            opgd1.Vehicle_Type__c = 'New';
            opgd1.Required_Loan_amount__c  = 10000;
            opgd1.Product_Type__c = 'Tractor';
            insert opgd1;
            
            Deal_Number__c dealNumber = TestDataUtility.createDealNumber(true,opgd1);
            
            
            InsuranceDetails__c insDetail = TestDataUtility.createInsuranceDetails(false,opgd1);
            insDetail.Amount__c = 26564;
            insDetail.Funded_Non_funded__c = 'Funded';
            insert insDetail;
            
            
            Final_Term__c ft2 = new Final_Term__c();
            ft2.CRM_IRR__c = 120;
            ft2.Loan_Application__c = opgd1.Id;
            ft2.Holiday_period__c='30';
            ft2.EMI_Amount__c= 10000;
            ft2.FIwaiver_offAddress__c = 'Not Waived';
            ft2.Loan_Amount__c = '1500000345';
            ft2.Tenure__c='56';
            insert ft2;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opgd1.Id;
            applicant.Applicant_Type__c  = null;
            applicant.Scorecard_Decision__c = 'Red';
            insert applicant;
            applicant.Opportunity__r = opgd1;  
        }
    }
    
    @isTest
    public static void verifyIND_StampingDetailsRequest(){
        Test.startTest();
        Opportunity opp = [SELECT Id,Product_Type__c,Deal_Number__c FROM Opportunity LIMIT 1];
        opp.Deal_Number__c = '12345';
        opp.Product_Type__c = 'Two Wheeler';
        update opp;
        Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
        Applicant__c applicant  = [SELECT Id,Opportunity__c,Applicant_Type__c,Scorecard_Decision__c FROM Applicant__c LIMIT 1];
        
        
        IND_StampingDetailsRequest result = new IND_StampingDetailsRequest(applicant, opp, '12345',dealNumber.Id);
        Boolean isValid = result.validate(System.Label.StampingDetails);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void verifyIND_StampingDetailsRequest1(){
        Test.startTest();
        Opportunity opp = [SELECT Id,Product_Type__c,Deal_Number__c FROM Opportunity LIMIT 1];
        Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
        Applicant__c applicant  = [SELECT Id,Opportunity__c,Applicant_Type__c,Scorecard_Decision__c FROM Applicant__c LIMIT 1];
        
        Vehicle_Detail__c vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false,opp);
        vehicleDetail.Deal_Number__c = dealNumber.Id;
        insert vehicleDetail;
        
        Final_Term__c ft2 = [SELECT Id,Vehicle_Detail__c FROM Final_Term__c WHERE Loan_Application__c = :opp.Id LIMIT 1];
        ft2.Vehicle_Detail__c = vehicleDetail.Id;
        update ft2;
        
        
        IND_StampingDetailsRequest result = new IND_StampingDetailsRequest(applicant, opp, '12345',dealNumber.Id);
        Boolean isValid = result.validate(System.Label.StampingDetails);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void verifyIND_StampingDetailsRequest2(){
        try{
        Test.startTest();
        Opportunity opp = [SELECT Id,Product_Type__c,Deal_Number__c FROM Opportunity LIMIT 1];
        Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
        Applicant__c applicant  = [SELECT Id,Opportunity__c,Applicant_Type__c,Scorecard_Decision__c FROM Applicant__c LIMIT 1];
        
        Vehicle_Detail__c vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false,opp);
        vehicleDetail.Deal_Number__c = dealNumber.Id;
        insert vehicleDetail;
        
        Final_Term__c ft2 = [SELECT Id,Vehicle_Detail__c FROM Final_Term__c WHERE Loan_Application__c = :opp.Id LIMIT 1];
        ft2.Vehicle_Detail__c = vehicleDetail.Id;
        update ft2;
        
        
        IND_StampingDetailsRequest result = new IND_StampingDetailsRequest(applicant, opp, null,dealNumber.Id);
        Boolean isValid = result.validate(System.Label.StampingDetails);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        Test.stopTest();
        }
        catch(Exception ex){
            System.debug('Exception:::'+ex.getmessage());
            System.assertEquals('Please Provide Geo State Code',ex.getMessage());
        }
    }
}