/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Run Emi Engine response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
27-12-2021    Satyam More            Created
1-4-2022      Santhosh Mothe		 Modified
------------------------------------------------------------*/

public class IND_RunEmiEngineResponse extends ParentAPIResponse {
    
    public List<EmiRanges> emiRanges;

	public class EmiRanges {
		public String Loan_Type;
		public String Outstanding_Amt;
		public String Upper_Emi_Cap;
		public String Lower_Emi_Cap;
		public String Remaining_Months;
	}

    
}