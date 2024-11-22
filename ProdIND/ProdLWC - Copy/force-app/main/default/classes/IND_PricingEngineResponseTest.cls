@isTest
public class IND_PricingEngineResponseTest {
	 @isTest
    public static void verifyIND_PricingEngineResponse(){
        
        IND_PricingEngineResponse res=new IND_PricingEngineResponse();
        System.assertEquals(res.Threshold_Net_IRR, null);
    }
}