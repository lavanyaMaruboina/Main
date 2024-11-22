@isTest
public class IND_PerfiosBSTransStatusResponseTest {

     @isTest
    public static void verifyIND_PerfiosBSTransactionStatusResponse(){
       IND_PerfiosBSTransactionStatusResponse objResp = new  IND_PerfiosBSTransactionStatusResponse();

        objResp.ClientTransactionId = '';
        objResp.perfiosTransactionId = '';
        objResp.Status = '';
        objResp.error_message = '';
        objResp.error_code = '';
         objResp.files_Availabilty = '';
         objResp.Reason = '';
        

        System.assert( objResp.Status == '');
    }

}