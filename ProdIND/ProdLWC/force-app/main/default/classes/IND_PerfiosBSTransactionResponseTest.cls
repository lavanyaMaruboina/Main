@isTest
public class IND_PerfiosBSTransactionResponseTest {
	@isTest
    public static void verifyIND_PerfiosBSTransactionStatusResponse(){
        IND_PerfiosBSTransactionStatusResponse result1=new IND_PerfiosBSTransactionStatusResponse();
        System.assertEquals(result1.ClientTransactionId, null);
        System.assertEquals(result1.perfiosTransactionId, null);
        System.assertEquals(result1.Status, null);
        System.assertEquals(result1.error_message, null);
        System.assertEquals(result1.error_code, null);
	    System.assertEquals(result1.files_Availabilty, null);
        System.assertEquals(result1.Reason, null);

    }
}