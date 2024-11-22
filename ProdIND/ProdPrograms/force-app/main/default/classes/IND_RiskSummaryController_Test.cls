/**
* @author Sivakumar Gudipati
* @company Persistent Systems
* @description A  Test class for the IND_RiskSummaryController class
* History:
  Modified by Siva
*/

@IsTest 
public class IND_RiskSummaryController_Test {
    
    @testSetup static void testDataMethod(){
        
        Opportunity opc1 = new Opportunity(StageName = 'Qualification', CloseDate = Date.newInstance(2021, 1, 11), 
                                            Name = 'testone');
        insert opc1;
             
        List<Applicant__c> lstApl = new List<Applicant__c>();
        
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655'));
        }
        insert lstApl;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.LTV_as_per_LTV_engine__c = 'testltv';
        ft1.PricingEngine_thresholdNetrr__c = 5;
        insert ft1;
    }
    
    @isTest
    public static void getApplicantsTest(){
        
       Opportunity opp = [select id from Opportunity where Name = 'testone'];
        
       Test.startTest();
       IND_RiskSummaryController.getApplicants(opp.Id);
       Test.stopTest();
    }
    
     @isTest
    public static void updateRiskSummaryDataTest(){
        
        Final_Term__c ft = [SELECT Id, Loan_Application__c, LTV_as_per_LTV_engine__c, PricingEngine_thresholdNetrr__c
            FROM Final_Term__c][0];
            
        Opportunity opp = [SELECT Id, StageName, CloseDate, Name FROM Opportunity][0];
        
        Test.startTest();
        IND_RiskSummaryController.updateRiskSummaryData(JSON.serialize(ft), JSON.serialize(opp));
        IND_RiskSummaryController.updateRiskSummaryData(null, JSON.serialize(opp));
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void retryAttemptsExastedTest1(){
        Opportunity opp = [select id from Opportunity where Name = 'testone' limit 1];        
        Test.startTest();
        IND_RiskSummaryController.retryAttemptsExasted(opp.id);
        Test.stopTest();     
    }
   
    
    @isTest
    public static void retryAttemptsExastedTest2(){
        Opportunity opp = [select id from Opportunity where Name = 'testone' limit 1];
        Retry_Count__c rc = new Retry_Count__c(Loan_Application_Id__c = opp.id,Service_Name__c ='AML',Count__c = 5);
        insert rc;
        
        Test.startTest();
        IND_RiskSummaryController.retryAttemptsExasted(opp.id);
        Test.stopTest();
    }
    
    @isTest
    public static void retryAttemptsExastedTest3(){
        Opportunity opp = [select id from Opportunity where Name = 'testone' limit 1];
        Retry_Count__c rc = new Retry_Count__c(Loan_Application_Id__c = opp.id,Service_Name__c ='AML',Count__c = 1);
        insert rc;
        
        Test.startTest();
        IND_RiskSummaryController.retryAttemptsExasted(opp.id);
        Test.stopTest();
    }
}