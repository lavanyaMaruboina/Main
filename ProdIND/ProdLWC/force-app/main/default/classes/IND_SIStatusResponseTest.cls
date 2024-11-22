@isTest
public class IND_SIStatusResponseTest {

    
     @isTest
    public static void IND_SIStatusResponse(){
        IND_SIStatusResponse.Response objResp = new  IND_SIStatusResponse.Response();
        IND_SIStatusResponse.Content objContent = new IND_SIStatusResponse.Content();
        
        
        objContent.Deal_No='';
        objContent.Status='';
        
   
        objResp.content = new List<IND_SIStatusResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_SIStatusResponse result = new IND_SIStatusResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    
    
}