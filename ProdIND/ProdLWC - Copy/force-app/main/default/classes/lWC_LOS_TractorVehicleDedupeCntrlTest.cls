@isTest
public class lWC_LOS_TractorVehicleDedupeCntrlTest {
@isTest
    public static void updateVehicleDedupeRetryCountTest(){
      
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'Test';
            opp.Product_Type__c='Tractor';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
        	insert opp;
        
           Retry_Count__c retryCount = new Retry_Count__c( 
                                                       Service_Name__c = 'CarwaleApi',
                                                       Count__c = 4,
                                                       Loan_Application_Id__c = opp.Id,
               										   Module__c = 'Vehicle Dedupe API'
                                                      );
          insert retryCount;
        Test.startTest();
        String result1 = lWC_LOS_TractorVehicleDedupeCntrl.updateVehicleDedupeRetryCount('CarwaleApi',opp.Id);
        System.assertEquals('Retry attempts are exhausted.', result1);
         String result2 = lWC_LOS_TractorVehicleDedupeCntrl.updateVehicleDedupeRetryCount(null,opp.Id);
          System.assertEquals('Success', result2);
        
        Test.stopTest();
      
    }
    @isTest
     public static void updateVehicleDedupeRetryCountTest1(){
      
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'Test';      
            opp.Product_Type__c='Tractor';
        	insert opp;
        
           Retry_Count__c retryCount = new Retry_Count__c( 
                                                       Service_Name__c = 'CarwaleApi',
                                                       Count__c = 1,
                                                       Loan_Application_Id__c = opp.Id,
               										   Module__c = 'Vehicle Dedupe API'
                                                      );
          insert retryCount;
        Test.startTest();
        String result1=lWC_LOS_TractorVehicleDedupeCntrl.updateVehicleDedupeRetryCount('CarwaleApi',opp.Id);
         System.assertEquals('Success', result1);
         String result2 = lWC_LOS_TractorVehicleDedupeCntrl.updateVehicleDedupeRetryCount('CarwaleApi',null);
         System.assertEquals('Failure', result2);
        Test.stopTest();
      
    }
}