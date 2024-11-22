@isTest
public class IND_NeSLAgreementStatusResponseTest {

    @isTest
    public static void verifyIND_NeSLAgreementStatusResponse(){
        IND_NeSLAgreementStatusResponse.Response objResp = new  IND_NeSLAgreementStatusResponse.Response();
        IND_NeSLAgreementStatusResponse.Content objContent = new IND_NeSLAgreementStatusResponse.Content();
        
        objContent.Status_Code ='';
        objContent.Status_Description ='';
        objContent.Esign_Link ='';
        
        
        
        
        objResp.content = new List<IND_NeSLAgreementStatusResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_NeSLAgreementStatusResponse result = new IND_NeSLAgreementStatusResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    
    
}