@isTest
public class IND_GatingScreeningResponseTest {
	@isTest
    public static void verifyIND_GatingScreeningResponseTest(){
    IND_GatingScreeningResponse result = new IND_GatingScreeningResponse();
    	result.finalDecision='Test';
        result.gatingScreeningOutcome='Test';
        result.finalDisplayReason ='test';
        
        System.assertEquals(result.finalDecision,'Test' );
        
    }
 }