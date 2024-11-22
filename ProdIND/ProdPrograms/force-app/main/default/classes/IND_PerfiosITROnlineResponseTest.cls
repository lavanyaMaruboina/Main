@isTest
public class IND_PerfiosITROnlineResponseTest {
	@isTest
    public static void verifyIND_PerfiosITROnlineResponse(){
        IND_PerfiosITROnlineResponse res=new IND_PerfiosITROnlineResponse();
        System.assertEquals(res.clientTransactionId, null);
        System.assertEquals(res.expires, null);
        System.assertEquals(res.generateLinkId, null);
        System.assertEquals(res.url, null);
    }
}