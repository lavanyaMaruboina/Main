@isTest
public class IND_PerfiosGSTOnlineResponseTest {

    
      @isTest
    public static void verifyIND_PerfiosGSTOnlineResponse(){
        IND_PerfiosGSTOnlineResponse objResp = new  IND_PerfiosGSTOnlineResponse();

        objResp.expires = '';
        objResp.generateLinkId = '';
         objResp.clientTransactionId = '';
         objResp.url = '';
     //    objResp.generateLinkId = '';
         objResp.transactionId = '';
         objResp.success = '';
        

        System.assert(objResp.success == '');
    }
    
    
    
}