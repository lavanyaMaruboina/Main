/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems 
Description:   This class is service class for the Insurace Premium API 
Test Class:    IND_InsurancePremiumResponse 
History
Date            Author              Comments
-------------------------------------------------------------
19-01-2022      Santhosh Mothe      Created
------------------------------------------------------------*/
public class IND_InsurancePremiumResponse extends ParentAPIResponse{
	
    public String Application_No{get;set;}
	public String Vehicle_ID{get;set;}
	// public String Premium{get;set;}
	// public String LHC{get;set;}
	public List<Premium_Details> Premium_Details{get;set;}
	public String Status_Flag{get;set;}
	public String Error_Code{get;set;}
	public String Error_Description{get;set;}
    /*
	public String Premium;
	public String LHC;
	public String Status_Flag;
	public String Error_Code;
	public String Error_Description; */
	
    public class Premium_Details {
		public String Ins_Product{get;set;}
		public String Plan_Code{get;set;}
		public String Premium{get;set;}
		public String Combo_LI_Premium{get;set;}
		public String Combo_EMI_Premium{get;set;}
	}
}