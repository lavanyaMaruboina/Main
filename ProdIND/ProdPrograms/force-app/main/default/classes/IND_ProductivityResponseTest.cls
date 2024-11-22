@isTest
public class IND_ProductivityResponseTest {
    
    @isTest
    public static void verifyIND_ProductivityResponse(){
        IND_ProductivityResponse.Response objResp = new  IND_ProductivityResponse.Response();
        IND_ProductivityResponse.Content objContent = new IND_ProductivityResponse.Content();
        
        System.assertEquals(objContent.Productivity, null);
        
        objResp.content = new List<IND_ProductivityResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_ProductivityResponse result = new IND_ProductivityResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    
    
}