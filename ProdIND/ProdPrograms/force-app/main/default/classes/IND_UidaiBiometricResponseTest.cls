@isTest
public class IND_UidaiBiometricResponseTest {

    
          @isTest
    public static void verifyIND_UidaiBiometricResponse(){
        List<String> resList = new List<String>();
        resList.add('testone');
        
        IND_UidaiBiometricResponse.Response objResp = new  IND_UidaiBiometricResponse.Response();
      
       // objResp.content = new List<IND_UidaiBiometricResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        objResp.content = resList;
        
        IND_UidaiBiometricResponse result = new IND_UidaiBiometricResponse();
        result.response = objResp;
        System.assert(objResp.status== '');
    }
    
}