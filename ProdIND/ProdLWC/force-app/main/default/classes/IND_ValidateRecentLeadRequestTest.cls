@isTest
public class IND_ValidateRecentLeadRequestTest {
    
    @isTest
    public static void verifyIND_ValidateRecentLeadRequest(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
          IND_ValidateRecentLeadRequest result = new IND_ValidateRecentLeadRequest('sCICNo',  'sLeadNo',  opgd1.Id);
     //   Boolean isValid = result.validate(System.Label.ValidateRecentLead);
      //  System.assert(isValid);
        
          Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
     //   System.assert(!resultHeadersMap.isEmpty()); 
        
    }    
    
    
    
}