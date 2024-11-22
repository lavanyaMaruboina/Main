@isTest
public class IND_WebSessionAuthorizeTokenResponseTest {
@isTest
    public static void verifyIND_WebSessionAuthorizeTokenResponse(){
        IND_WebSessionAuthorizeTokenResponse obj =new IND_WebSessionAuthorizeTokenResponse();
        System.assertEquals(obj.SessionId, null);
         System.assertEquals(obj.Cibil_Report_Url, null);
    }
}