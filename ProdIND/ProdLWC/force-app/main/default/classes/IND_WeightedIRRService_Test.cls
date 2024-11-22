/*------------------------------------------------------------
Author:        Prashant Dixit
Description:   This Test class is used for code coverage of IND_WeightedIRRService, IND_WeightedIRRRequest & IND_WeightedIRRResponse     
History
Date            Author              Comments
-------------------------------------------------------------
28-12-2023      Prashant Dixit      Created
------------------------------------------------------------*/
@isTest
public class IND_WeightedIRRService_Test {
    @isTest
    public static void getWeightedIRRRequestTest(){ 
        Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New');
        insert opp;
        
        Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
        insert app;
        
        Test.startTest();
        IND_WeightedIRRRequest indWeightRRReq = IND_WeightedIRRService.getWeightedIRRRequest(app.Id, opp.Id);
        Test.stopTest();
    }
    @isTest
    public static void getWeightedIRRRequestTest1(){
        Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New');
        insert opp;
        
        Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
        insert app;
        
        Test.startTest();
        try{
            IND_WeightedIRRRequest indWeightRRReq1 = IND_WeightedIRRService.getWeightedIRRRequest(null, '');
        }catch(Exception ex){
            System.debug('Exception is -> '+ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void weightedIRRResponseTest() {
        ParentAPIResponse parentApiResponse = new ParentAPIResponse();
        IND_WeightedIRRResponse weightedIRRResponse = new IND_WeightedIRRResponse();
        weightedIRRResponse.response = new IND_WeightedIRRResponse.Response();
        weightedIRRResponse.response.status = 'Success';
        weightedIRRResponse.response.respDesc = 'Test Description';

        IND_WeightedIRRResponse.Content content = new IND_WeightedIRRResponse.Content();
        String str = content.Weighted_IRR;
        weightedIRRResponse.response.content = new List<IND_WeightedIRRResponse.Content>{content};
    }
   
    @isTest
    public static void getHttpRequestHeadersTest() {
       Test.startTest();
        IND_WeightedIRRRequest weightedIRRReq = new IND_WeightedIRRRequest('test', null);
        Map<String, String> mapOfGetHeaderRec = weightedIRRReq.getHttpRequestHeaders();
       Test.stopTest();
    }
}