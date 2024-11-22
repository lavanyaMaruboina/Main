@isTest
public class IND_NeSLAgreementStatusRequest_Test {
    @isTest
    public static void verifyIND_NeSLAgreementStatusRequest(){
        try{
            //create user
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                              TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com');
            insert u;
            System.runAs(u) 
            {
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                opgd1.Product_Type__c = 'Two Wheeler';
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
                
                //Deal_Number__c dl=TestDataUtility.createDealNumber(false,opgd1);
                //insert dl;
                
                Test.startTest();
                IND_NeSLAgreementStatusRequest result = new IND_NeSLAgreementStatusRequest(applicant, opgd1.Id);
                Boolean isValid = result.validate(System.Label.NeSLAgreementStatus);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                Test.stopTest();
            }
        }catch(Exception ex){
           System.debug('Ex-' + ex.getMessage());
        }
    } 
}