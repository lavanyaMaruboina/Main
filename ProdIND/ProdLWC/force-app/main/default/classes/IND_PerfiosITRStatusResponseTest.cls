@isTest
public class IND_PerfiosITRStatusResponseTest {
    @isTest
    public static void verifyIND_PerfiosITRStatusResponse(){
        
        IND_PerfiosITRStatusResponse res=new IND_PerfiosITRStatusResponse();
        System.assertEquals(res.perfiosTransactionId, null);
        System.assertEquals(res.clientTransactionId, null);
        System.assertEquals(res.status, null);
        System.assertEquals(res.error_code, null);
        System.assertEquals(res.error_message, null);
        }
}