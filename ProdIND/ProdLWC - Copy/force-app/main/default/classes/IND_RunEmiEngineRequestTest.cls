@isTest
public class IND_RunEmiEngineRequestTest {
    
    @isTest
    public static void verifyIND_RunEmiEngineRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG-001';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.leadId = opgd1.Lead_number__c;
        requestWrapper.applicantNumber = 'A001';
        requestWrapper.loanApplicationId = opgd1.ID;
        requestWrapper.cicNo = 'C001';
        
        
        IND_RunEmiEngineRequest result = new IND_RunEmiEngineRequest(requestWrapper, opgd1.ID);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
    }
    
    
}