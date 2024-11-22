@isTest
public class IND_SMSResponseTest 
{    
    @isTest
    public static void verifyIND_SMSResponse(){
        IND_SMSResponse.Response objResp = new  IND_SMSResponse.Response();
        IND_SMSResponse.Content objContent = new IND_SMSResponse.Content();
        System.assertEquals(objContent.Transaction_Id, null);
        objResp.content = new List<IND_SMSResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        objResp.respDesc = '';
        
        IND_SMSResponse result = new IND_SMSResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }   
}