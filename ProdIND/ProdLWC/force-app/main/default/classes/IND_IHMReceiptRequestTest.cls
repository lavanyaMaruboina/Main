@isTest
public class IND_IHMReceiptRequestTest {
    
    @isTest
    public static void verifyIND_IHMReceiptRequest(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test1_userprod123@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            opgd1.Product_Type__c = 'Tractor';
            opgd1.Vehicle_Type__c = 'New';
            opgd1.Parent_Deal_number__c = 'DL109939';
            opgd1.Lead_number__c = 'L109939';
            opgd1.Deal_Number__c = 'L109939';
            insert opgd1;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opgd1.Id;
            applicant.Applicant_Type__c  = null;
            applicant.Scorecard_Decision__c = 'Red';
            insert applicant;
            applicant.Opportunity__r = opgd1;  
            
              Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opgd1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            //dl.Sub_Stage__c = 'test';
            insert dl;
            
            Test.startTest();
            IND_IHMReceiptRequest result = new IND_IHMReceiptRequest(applicant, opgd1.Id,dl.Id);
            Boolean isValid = result.validate(System.Label.IHMReceipt);
            System.assert(isValid);
            
            Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
            System.assert(!resultHeadersMap.isEmpty());
            Test.stopTest();
        }
    } 
}