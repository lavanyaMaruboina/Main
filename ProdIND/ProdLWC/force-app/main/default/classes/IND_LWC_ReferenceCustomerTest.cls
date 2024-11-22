@isTest
public class IND_LWC_ReferenceCustomerTest {
 @testSetup static void setup() {
     
     Opportunity opp = TestDataUtility.createTestLoanApplication(false);
     opp.Product_Type__c = 'Tractor';
     insert opp;
             
     Applicant__c applicant = TestDataUtility.createTestApplicant(false);
     applicant.Opportunity__c = opp.Id;
     insert applicant;
     
      Customer_Reference__c testCustomerReference = new Customer_Reference__c(
            Applicant__c = applicant.Id
        );
        insert testCustomerReference;
     
       
    }
    
   @isTest 
    public static void getReferenceCustomerOfApplicantTest() {
       
       Applicant__c app = [Select Id from Applicant__c limit 1];
       Test.startTest();
       List<Customer_Reference__c> customerResult = IND_LWC_ReferenceCustomer.getReferenceCustomerOfApplicant(app.Id,true);
       Test.stopTest();
    }
    
     @isTest 
    public static void getReferenceCustomerOfApplicantTest1() {
       
       Applicant__c app = [Select Id from Applicant__c limit 1];
       Test.startTest();
       List<Customer_Reference__c> customerResult = IND_LWC_ReferenceCustomer.getReferenceCustomerOfApplicant(app.Id,false);
       Test.stopTest();
    }
    
    @isTest 
    public static void updateReferedCustomerOfApplicantTest() {
        
       Applicant__c app = [Select Id from Applicant__c limit 1];
       Customer_Reference__c customerRef = [Select  Id from Customer_Reference__c limit 1];
       String jsonStr ='[{"Id": "' + customerRef.Id + '","Feedback": "Test"}]';
         
       Test.startTest();
       String customerResult = IND_LWC_ReferenceCustomer.updateReferedCustomerOfApplicant(jsonStr,app.Id);
       Test.stopTest();
    }
    
    @isTest 
    public static void updateReferedCustomerOfApplicantTest1() {
        
       Applicant__c app = [Select Id from Applicant__c limit 1];
       Customer_Reference__c customerRef = [Select  Id from Customer_Reference__c limit 1];
       String jsonStr ='[{"Id": "' + customerRef.Id + '","Feedback": ""}]';
          
       Test.startTest();
       String customerResult = IND_LWC_ReferenceCustomer.updateReferedCustomerOfApplicant(jsonStr,app.Id);
       Test.stopTest();
    }

}