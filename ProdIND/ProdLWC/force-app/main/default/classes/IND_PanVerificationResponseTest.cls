@isTest
public class IND_PanVerificationResponseTest {

    
     @isTest
    public static void verifyIND_PanVerificationResponse(){
        IND_PanVerificationResponse.Response objResp = new  IND_PanVerificationResponse.Response();
        IND_PanVerificationResponse.Content objContent = new IND_PanVerificationResponse.Content();
        System.assertEquals(objContent.NSDLPANStatusDesc, null);
        System.assertEquals(objContent.NSDLReturnCdDesc, null);
        System.assertEquals(objContent.NSDLPANStatus, null);
        System.assertEquals(objContent.Name, null);
        System.assertEquals(objContent.ID, null);
        System.assertEquals(objContent.IDNSDLNameMatch, null);
        objResp.content = new List<IND_PanVerificationResponse.Content>{objContent};
            objResp.respDesc = 'dummy response';
        objResp.status = 'test Status';
        
        IND_PanVerificationResponse result = new IND_PanVerificationResponse();
        result.response = objResp;
        System.assert(result.response.status == 'test Status');
    }
}