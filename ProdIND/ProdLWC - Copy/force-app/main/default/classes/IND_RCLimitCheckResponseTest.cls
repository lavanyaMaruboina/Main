@isTest
public class IND_RCLimitCheckResponseTest {
 @isTest
    public static void verifyIND_RCLimitCheckResponse(){
        
        IND_RCLimitCheckResponse.Response resResponse=new IND_RCLimitCheckResponse.Response();
        System.assertEquals(resResponse.content, null);
        System.assertEquals(resResponse.respDesc, null);
        System.assertEquals(resResponse.status, null);
        
        IND_RCLimitCheckResponse.Content resContent=new IND_RCLimitCheckResponse.Content();
        System.assertEquals(resContent.No_Of_Proposals_Available, null);
        System.assertEquals(resContent.Available_Disbursal_Amount, null);
        System.assertEquals(resContent.Pending_Flag, null);
    	System.assertEquals(resContent.Payment_To_DSA_Flag, null);
        System.assertEquals(resContent.RC_Limit_Cleared_Flag, null);
        
        IND_RCLimitCheckResponse result=new IND_RCLimitCheckResponse();
        System.assertEquals(result.response, null);
        
    }
}