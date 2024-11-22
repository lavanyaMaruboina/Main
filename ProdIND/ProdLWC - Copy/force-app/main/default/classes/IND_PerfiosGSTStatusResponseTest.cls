@isTest
public class IND_PerfiosGSTStatusResponseTest {
    
        @isTest
    public static void verifyIND_PerfiosGSTStatusResponse(){
        IND_PerfiosGSTStatusResponse objResp = new  IND_PerfiosGSTStatusResponse();

        objResp.perfiosTransactionId = '';
        objResp.clientTransactionId = '';
        objResp.error_code = '';
        objResp.error_message = '';
        objResp.status = '';

        System.assert( objResp.status == '');
    }
    

}