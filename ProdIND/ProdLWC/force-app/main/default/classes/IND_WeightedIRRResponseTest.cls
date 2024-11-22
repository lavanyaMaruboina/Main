@isTest
public class IND_WeightedIRRResponseTest {
    
    @isTest
    public static void verifyIND_WeightedIRRResponse(){
        IND_WeightedIRRResponse.Response objResp = new  IND_WeightedIRRResponse.Response();
        IND_WeightedIRRResponse.Content objContent = new IND_WeightedIRRResponse.Content();
        
        System.assertEquals(objContent.Weighted_IRR, null);
        
        objResp.content = new List<IND_WeightedIRRResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_WeightedIRRResponse result = new IND_WeightedIRRResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    
    
}