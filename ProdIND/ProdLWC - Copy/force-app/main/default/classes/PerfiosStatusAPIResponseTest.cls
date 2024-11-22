@isTest
public class PerfiosStatusAPIResponseTest {
	@isTest
    public static void verifyPerfiosStatusAPIResponse(){
        PerfiosStatusAPIResponse result=new PerfiosStatusAPIResponse();
    	System.assertEquals(result.perfiosTransactionId, null);
        System.assertEquals(result.clientTransactionId, null);
        System.assertEquals(result.error_code, null);
        System.assertEquals(result.error_message, null);
        System.assertEquals(result.status, null);
    }
}