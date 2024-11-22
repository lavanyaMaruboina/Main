@isTest
public class IND_OfferEngineResponseTest {
@isTest
    public static void verifyIND_OfferEngineResponse(){
         IND_OfferEngineResponse obj1 =new IND_OfferEngineResponse();
        System.assertEquals(obj1.Min_Loan_Amt_Slider, null);
        System.assertEquals(obj1.Max_Loan_Amt_Slider, null);
        System.assertEquals(obj1.Loan_Amt, null);
        System.assertEquals(obj1.Min_Tenure_Slider, null);
        System.assertEquals(obj1.Max_Tenure_Slider, null);
        System.assertEquals(obj1.Tenure, null);
        System.assertEquals(obj1.EMI, null);
        System.assertEquals(obj1.CRM_IRR, null);
        System.assertEquals(obj1.Net_Pay_Ins, null);
        System.assertEquals(obj1.Net_Pay_Outs, null);
        System.assertEquals(obj1.Gross_IRR_Offered, null);
        System.assertEquals(obj1.Net_IRR_Offered, null);
        System.assertEquals(obj1.Stop_Journey_Flag, null);
        System.assertEquals(obj1.Final_CRM_IRR, null);
        System.assertEquals(obj1.Final_Gross_IRR, null);
        System.assertEquals(obj1.Imputed_IRR_Offered, null);
        System.assertEquals(obj1.Final_Net_IRR, null);
        
    }

}