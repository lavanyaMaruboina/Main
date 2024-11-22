@isTest
public class IND_IHMReceiptResponseTest {

    @isTest
    public static void verifyIND_IHMReceiptResponse(){
        IND_IHMReceiptResponse.Response objResp = new IND_IHMReceiptResponse.Response();
			objResp.content = new List<String>{'Test'};
            objResp.respDesc = 'test';
        objResp.status = 'test';
        
        IND_IHMReceiptResponse result = new IND_IHMReceiptResponse();
        result.response = objResp;
        System.assert(result.response.status == 'test');
    }
    
   
}