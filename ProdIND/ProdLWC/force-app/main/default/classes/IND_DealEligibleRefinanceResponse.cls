/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is wrapper class for the Deal Eligible Refinance API response 
Test Class:    IND_DealEligibleRefinanceService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
22-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_DealEligibleRefinanceResponse extends ParentAPIResponse {
 public Response response; 
    public class Response {
        public String status;
        public String respDesc;
        public List<Content> content;
    } 
    public class Content {
        public String DealNumber;
        public String Product;
        public String RefinanceEligible;
        public String EligibilityAmount;
        public String Tenure_In_Months;
        public String TopUp_Refin;
    }
}