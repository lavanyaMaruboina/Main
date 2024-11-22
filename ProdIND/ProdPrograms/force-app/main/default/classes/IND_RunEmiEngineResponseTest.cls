@isTest
public class IND_RunEmiEngineResponseTest {
@isTest
    public static void verifyIND_RunEmiEngineResponse(){
         
        IND_RunEmiEngineResponse result=new IND_RunEmiEngineResponse();
        System.assertEquals(result.emiRanges, null);
        
        IND_RunEmiEngineResponse.EmiRanges resEmiRanges=new IND_RunEmiEngineResponse.EmiRanges();
        System.assertEquals(resEmiRanges.Loan_Type, null);
        System.assertEquals(resEmiRanges.Outstanding_Amt, null);
        System.assertEquals(resEmiRanges.Upper_Emi_Cap, null);
        System.assertEquals(resEmiRanges.Lower_Emi_Cap, null);
        System.assertEquals(resEmiRanges.Remaining_Months, null);
    }
}