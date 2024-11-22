@isTest
public class IND_ProductivityService_Test {
    @isTest
    public static void getProductivityRequestTest(){
        Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New');
        insert opp;
        
        Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
        insert app;
        
        Test.startTest();
        IND_ProductivityRequest indProductivityReq = IND_ProductivityService.getProductivityRequest(app.Id, opp.Id);
        Test.stopTest();
    }
    @isTest
    public static void getProductivityRequestTest1(){
        Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New');
        insert opp;
        
        Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
        insert app;
        
        Test.startTest();
        try{
            IND_ProductivityRequest indProductivityReq1 = IND_ProductivityService.getProductivityRequest(null, '');
        }catch(Exception ex){
            System.debug('Exception is -> '+ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void productivityResponseTest() {
        ParentAPIResponse parentApiResponse = new ParentAPIResponse();
        IND_ProductivityResponse productivityResponse = new IND_ProductivityResponse();
        productivityResponse.response = new IND_ProductivityResponse.Response();
        productivityResponse.response.status = 'Success';
        productivityResponse.response.respDesc = 'Test Description';

        IND_ProductivityResponse.Content content = new IND_ProductivityResponse.Content();
        String str = content.Productivity;
        productivityResponse.response.content = new List<IND_ProductivityResponse.Content>{content};
    }
   
    @isTest
    public static void getHttpRequestHeadersTest() {
       Test.startTest();
        IND_ProductivityRequest productivityReq = new IND_ProductivityRequest('test', null);
        Map<String, String> mapOfGetHeaderRec = productivityReq.getHttpRequestHeaders();
       Test.stopTest();
    }
}