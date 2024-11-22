@isTest
public class IND_EmailCheckRequestTest {
    
       
    @isTest
    public static void verifyIND_EmailCheckRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        reqWrapper.email = 'test@example.com';
        
        
        IND_EmailCheckRequest result = new IND_EmailCheckRequest(reqWrapper, opgd1.Id);
        Boolean isValid = result.validate(System.Label.EmailCheck);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
    } 

}