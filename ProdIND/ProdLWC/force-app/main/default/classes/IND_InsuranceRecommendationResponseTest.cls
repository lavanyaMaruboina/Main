@isTest
public class IND_InsuranceRecommendationResponseTest {
@isTest
    public static void verifyIND_InsuranceRecommendationResponse(){
         
        IND_InsuranceRecommendationResponse.Ins_Product resIns_Product=new IND_InsuranceRecommendationResponse.Ins_Product();
        System.assertEquals(resIns_Product.Ins_Product, null);
        System.assertEquals(resIns_Product.Plan_Code, null);
        System.assertEquals(resIns_Product.Plan_Name, null);
        System.assertEquals(resIns_Product.Sum_Insured, null);
        System.assertEquals(resIns_Product.Premium, null);
         System.assertEquals(resIns_Product.LHC, null);
        System.assertEquals(resIns_Product.Plan_Recommend, null);
        System.assertEquals(resIns_Product.Disable_Funding, null);
        System.assertEquals(resIns_Product.Funding_Option, null);
        
        IND_InsuranceRecommendationResponse result=new IND_InsuranceRecommendationResponse();
        System.assertEquals(result.Application_No, null);
        System.assertEquals(result.Vehicle_ID, null);
        System.assertEquals(result.ins_Product, null);
        System.assertEquals(result.Status_Flag, null);
        System.assertEquals(result.Error_Code, null);
        System.assertEquals(result.Error_Description, null);
       
    }
}