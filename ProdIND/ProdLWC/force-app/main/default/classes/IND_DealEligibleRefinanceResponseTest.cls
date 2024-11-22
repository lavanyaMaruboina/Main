@isTest
public class IND_DealEligibleRefinanceResponseTest {
    
    
         @isTest
    public static void verifyIND_DealEligibleRefinanceResponse(){
        IND_DealEligibleRefinanceResponse.Response objResp = new  IND_DealEligibleRefinanceResponse.Response();
        IND_DealEligibleRefinanceResponse.Content objContent = new IND_DealEligibleRefinanceResponse.Content();
        
        objContent.DealNumber='';
        objContent.Product='';
        objContent.RefinanceEligible='';
        objContent.EligibilityAmount='';
        objContent.Tenure_In_Months='';
        

        objResp.content = new List<IND_DealEligibleRefinanceResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        

        
        IND_DealEligibleRefinanceResponse result = new IND_DealEligibleRefinanceResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    

}