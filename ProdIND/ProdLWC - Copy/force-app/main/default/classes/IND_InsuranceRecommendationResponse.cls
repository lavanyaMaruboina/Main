/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the Insurance Recommendation response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
18-01-2022      Divya Jawale     Created
------------------------------------------------------------*/
public class IND_InsuranceRecommendationResponse extends ParentAPIResponse {
    public final String Application_No;
	public final String Vehicle_ID;
	public List<Ins_Product> Ins_Product;
	public final String Status_Flag;
	public final String Error_Code;
	public final String Error_Description;

	public class Ins_Product {
		public final String Ins_Product;
		public final String Plan_Code;
		public final String Plan_Name;
		public final String Sum_Insured;
		public final String Premium;
		public final String LHC;
		public final String Plan_Recommend;
		public final String Disable_Funding;
		public final String Funding_Option;
	}
}