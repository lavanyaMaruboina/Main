@isTest
public class IND_NeSLEAgreementResponseTest {

    @isTest
    public static void verifyIND_NeSLEAgreementResponse(){
        IND_NeSLEAgreementResponse.Response objResp = new  IND_NeSLEAgreementResponse.Response();
        IND_NeSLEAgreementResponse.Content objContent = new IND_NeSLEAgreementResponse.Content();
        
        objContent.txnID ='';
         objContent.docImage ='';
        
        
        
        
        
        objResp.content = new List<IND_NeSLEAgreementResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_NeSLEAgreementResponse result = new IND_NeSLEAgreementResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    
    
}