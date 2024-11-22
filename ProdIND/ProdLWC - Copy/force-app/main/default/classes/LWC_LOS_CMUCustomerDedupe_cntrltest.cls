@isTest
public class LWC_LOS_CMUCustomerDedupe_cntrltest {
    
    @testSetup 
    static void testDataSetup(){
        Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
            
                 case cs1 = new case();
                 cs1.Loan_Application__c = opga1.Id;
                 cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs1.Status = 'Pending-Off Role Employee App';
                 cs1.Origin = 'Web';
                 insert cs1; 
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = cs1.Loan_Application__c;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.In_Active_Applicant__c = false;
                apga1.Customer_Code__c = '';
                apga1.Invalid_Customer_Code__c = '';
                apga1.isCodeValidateBySalesUser__c=false;
                insert apga1;
            
            	Customer_Dedupe_Response__c customerDedupe = new Customer_Dedupe_Response__c();
            	customerDedupe.Applicant__c = apga1.Id;
                customerDedupe.IND_isNewCustomer__c = false;
            	insert customerDedupe;
    }
     @isTest
    public static void getRecordDetailsTest(){
        try{
                
            List<Case> caseList = [SELECT Id from Case LIMIT 1];
                Test.startTest();
                      LWC_LOS_CMUCustomerDedupe_cntrl.getRecordDetails(caseList[0].Id);
                Test.stopTest();
                
                
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    
    @isTest
    public static void getRecordDetailsexceptionTest1()
    {
        try
        {
             Test.startTest();
                      LWC_LOS_CMUCustomerDedupe_cntrl.getRecordDetails(null);
                Test.stopTest();  
        }//try close
        catch(Exception e)
        {
            System.assertEquals('Case is not available.', e.getMessage());
        }//catch close
    }//method close

    @isTest
    public static List<Applicant__c> checkCustomerResponseAvailableTest(){
        try{
            List<Opportunity> oppList = [SELECT Id from opportunity LIMIT 1];
            Test.startTest();
                List<Applicant__c> appList = LWC_LOS_CMUCustomerDedupe_cntrl.checkCustomerResponseAvailable(oppList[0].Id);
            Test.stopTest();
            return appList;
        }
        catch(Exception e)
        {
            System.debug('Record not available.'+ e.getMessage());
            return null;
        }
    }
    @isTest
     public static List<Applicant__c> checkCustomerResponseAvailableTest1(){
        try{
            Test.startTest();
                List<Applicant__c> appList = LWC_LOS_CMUCustomerDedupe_cntrl.checkCustomerResponseAvailable(null);
            Test.stopTest();
            return appList;
        }
        catch(Exception e)
        {
            System.debug('Record not available.'+ e.getMessage());
            return null;
        }
    }
    
    @isTest
    public static void checkCaseClosedTest(){
        try{
                
            List<Case> caseList = [SELECT Id from Case LIMIT 1];
            caseList[0].status = 'Closed';
            update caseList;
                Test.startTest();
                      LWC_LOS_CMUCustomerDedupe_cntrl.checkCaseClosed(caseList[0].Id);
                Test.stopTest();
                
                
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    
}//class close