@isTest
public class IND_ValidateRecentLeadResponseTest {
    
 @isTest
    public static void verifyIND_ValidateRecentLeadResponse(){
        IND_ValidateRecentLeadResponse.Response objResp = new  IND_ValidateRecentLeadResponse.Response();
        IND_ValidateRecentLeadResponse.Content objContent = new IND_ValidateRecentLeadResponse.Content();
        
        
        System.assertEquals(objContent.PG_Application_No, null);
        System.assertEquals(objContent.PG_cust_dedupe, null);
        
        
        objResp.content = new List<IND_ValidateRecentLeadResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_ValidateRecentLeadResponse result = new IND_ValidateRecentLeadResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }

}