@isTest
public class IND_ReferenceRelationMasterRequestTest {
    
@isTest
    public static void ReferenceRelationMasterRequestTest(){
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Borrower';
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;

        Applicant__c applicant1 = TestDataUtility.createTestApplicantForSMS(false);
        applicant1.Opportunity__c = opgd1.Id;
        applicant1.Applicant_Type__c  = 'Co-Borrower';
        applicant1.Scorecard_Decision__c = 'Red';
        insert applicant1;
            
        IND_ReferenceAndRelationMasterRequest result =  IND_ReferenceAndRelationMasterService.getReferenceAndRelationMasterRequest(opgd1.Id,'');
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
            IND_ReferenceAndRelationMasterRequest result1 =  IND_ReferenceAndRelationMasterService.getReferenceAndRelationMasterRequest(null,'');
     }catch(Exception ex){
          system.debug('Exception --' + ex);
        }
    }
}