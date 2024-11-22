@isTest
public class IND_SIStatusRequestTest {
    
        
    @isTest
    public static void verifyIND_SIStatusRequest(){
        
        
          Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.customerCode = 'CU00011';
        reqWrapper.dealNumber = 'L0001';
     //   reqWrapper.vehicleRegisterationNumber = 'MH12-9898989898';
     //   reqWrapper.product = 'testProduct';
     //   reqWrapper.category = 'TestCategory';
      //  reqWrapper.subCategory = 'TestSubCategory';
        
        
        IND_SIStatusRequest result = new IND_SIStatusRequest(reqWrapper);
        Boolean isValid = result.validate(System.Label.SIStatus);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
        
    }
    
    @isTest
    public static void getSIStatusRequestTest(){
          
        try{  
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
              //    IND_SIStatusService.getSIStatusRequest(app1,opp.Id);
                //  IND_SIStatusService.getSIStatusRequest(null,'test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

}