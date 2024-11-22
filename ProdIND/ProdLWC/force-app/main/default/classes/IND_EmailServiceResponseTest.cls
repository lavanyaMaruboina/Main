@isTest
public class IND_EmailServiceResponseTest {

    @isTest
    public static void verifyIND_EmailServiceResponse(){
        IND_EmailServiceResponse.Response objResp=new IND_EmailServiceResponse.Response();
            objResp.content = new List<String>{'Test'};
            objResp.respDesc = 'test';
            objResp.status = 'test';
        
        IND_EmailServiceResponse result =new IND_EmailServiceResponse();
        result.response=objResp;
        System.assert(result.response.status == 'test');
        
        
    }
}