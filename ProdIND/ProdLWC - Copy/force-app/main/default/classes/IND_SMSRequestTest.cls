@isTest
public class IND_SMSRequestTest {
    
    @isTest
    public static void verifyIND_SMSRequest(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='testIbluser1235@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            opgd1.Product_Type__c = 'Two Wheeler';
            opgd1.Vehicle_Type__c = 'New';
            insert opgd1;
            
            RequestWrapper reqWrapper = new RequestWrapper();
            reqWrapper.applicantId = opgd1.Id;
            reqWrapper.leadId = 'L00001';
            reqWrapper.whatsappNo = '9898989898';
            reqWrapper.otpForBorrower = 'test';
            reqWrapper.flag = 'OTP';
             reqWrapper.loanApplicationId = opgd1.Id;
             reqWrapper.fromproCredit = false;
             reqWrapper.mobileNumber='9999999999';
            
            
            
            IND_SMSRequest result = new IND_SMSRequest(reqWrapper);
            Boolean isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
            System.assert(!resultHeadersMap.isEmpty());
            
            reqWrapper.flag = 'INC';
            reqWrapper.productType = System.Label.Tractor;
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'INC';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'LAS';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'ENH';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'CASA';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'SI_Online';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'ENACH';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'SA';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'AML';
            result = new IND_SMSRequest(reqWrapper);
            isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);
            
            reqWrapper.flag = 'KFS';
            result = new IND_SMSRequest(reqWrapper);
           	isValid = result.validate(System.Label.SMSGateway);
            System.assert(isValid);

        }
    }    
}