@isTest(SeeAllData=false)
public class IND_AadhaarVault_ServiceTest {
@isTest 
    public static void testAadhaarVaultService(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
             String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Continuation con = (Continuation)IntegrationEngine.doAadhaarVaultAPICallout(loanAppId,'923140598388',applicant.Id);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"Jd74E460EqQDtFarZEyllhrz6kSx2PQd7Gxd6R0DamgBAmuyNkmbGEV47U4EAbqFLwYAc8R8O7qWtIMkCkHZRVeaZpuBu7vhjODYJjbO9YvNXocg4yGxXmCFz6PQLZUgl7m2Aq5fWnMwa2oGfBiCLDFWXdD1hmbk+iZ5r80ms3d/PI8M/Dj8Xoev+UASgj5nchJ3noOirDRAlBqA2ZchNwVl0T9ybEo9+bVh+J2Q+Mw="');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processAadhaarVaultAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response": {"status": "SUCCESS","respDesc": "Get_AadhaarVault_TokenReturn","content": [{"Status": "Success","Message": "","UID_Token_No": "01000733Vg0ul5keYMhioWDhDaxR8as2fEIrast3drsVrE33TtaCGUoRDqi1dHmbVVihYorT","Vault_Reference_No": "348346800673"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    @isTest
    public static void getAadhaarVaultTest(){
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                insert opgd1;
                
                Applicant__c apgd1 = new Applicant__c();
                apgd1.Opportunity__c = opgd1.Id;
                apgd1.Contact_number__c = '9743514830';
                apgd1.Applicant_Type__c = 'Borrower';
                insert apgd1;
        
                Test.startTest();
                try{
                    IND_AadhaarVault_Service.getAadhaarVault(opgd1.Id,'923140598388');
                    IND_AadhaarVault_Request indReq = new IND_AadhaarVault_Request(opgd1.Id,'923140598388');
                     indReq.getHttpRequestHeaders();
                }catch(Exception ex){
                   System.debug('error ---> ' + ex.getMessage());
                }
                    
                Test.stopTest();
                
    } 
    
    @isTest
    public static void getAadhaarVaultTest1(){
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                insert opgd1;
               
                Test.startTest();
                try{
                    IND_AadhaarVault_Service.getAadhaarVault(opgd1.Id,'');
                }catch(Exception ex){
                   System.debug('error ---> ' + ex.getMessage());
                }
                    
                Test.stopTest();
                
    } 
     
}