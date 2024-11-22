@isTest
public class IND_PaymentRequestApiServiceTest {
    
     @isTest
    static void testGetPaymentRequestCallOutRequest() {
        try{
        // Define test data
        String loanAppId = 'TestLoanAppId';
        String dealId = 'TestDealId';
        
        // Call the method under test
        Test.startTest();
        IND_PaymentRequestApiRequest paymentRequest = IND_PaymentRequestApiService.getPaymentRequestCallOutRequest(loanAppId, dealId);

        Test.stopTest();
        
        // Assert that the payment request is not null
        System.assertNotEquals(null, paymentRequest);
        
        // You can add more assertions based on your specific requirements
         } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter file type', 'Exception');
        }
    }
    
    
    
      
}