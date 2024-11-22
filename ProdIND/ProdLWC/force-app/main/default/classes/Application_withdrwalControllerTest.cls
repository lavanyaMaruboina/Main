@isTest
public class Application_withdrwalControllerTest {
    @isTest
    public static void getApplicationTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Withdrawn';
            opp.Withdrawal_Reason__c = 'Financial terms not agreed to';
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
                  Application_withdrwalController.getApplication(opp.Id,opp.Withdrawal_Reason__c);
            Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void gattingCheckEligibilityAPITest(){
        Test.startTest();
             IntegrationUtilities.gattingCheckEligibilityAPI();
        Test.stopTest();
    }
    
    @isTest
    public static void getAPIKeysTest(){
        Test.startTest();
             IntegrationUtilities.getAPIKeys('pkey');
             IntegrationUtilities.getAPIKeys('iv');
             IntegrationUtilities.getAPIKeys('');
        Test.stopTest();
    }
    
    @isTest
    public static void getCoborrowerNameTest(){
        Test.startTest();
             IntegrationUtilities.getCoborrowerName('Co Borrower');
        Test.stopTest();
    }
    
    @isTest
    public static void getCicNoTest(){
        Test.startTest();
             IntegrationUtilities.getCicNo();
        Test.stopTest();
    }
    
    @isTest
    public static void getMakerIdTest(){
        Test.startTest();
              IntegrationUtilities.getMakerId();
        Test.stopTest();
    }
    
    @isTest
    public static void getAPIConfigurationTest(){
        Test.startTest();
            //  IntegrationUtilities.getAPIConfiguration('ADAuthentication');
        Test.stopTest();
    }
    
    @isTest
    public static void getStubResponseTest(){
        Test.startTest();
             IntegrationUtilities.getStubResponse('APD Pending');
        Test.stopTest();
    }
    
    @isTest
    public static void getStubResponseTest1(){
        Test.startTest();
             IntegrationUtilities.getStubResponse('test');
        Test.stopTest();
    }
    
 }