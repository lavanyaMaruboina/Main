/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is wrapper class for the CIBIL Response 
Test Class:    CIBILResponseTest 
History
Date            Author              Comments
-------------------------------------------------------------
27-10-2021      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_CIBILResponse extends ParentAPIResponse {

    public Data Data ; 
    
    public class Data {
		public String IsSuccess ; 
		public String StatusCode ; 
		public String StatusDescription ; 
		public String Cibil_Report_URl ; 
		public Application_Cibil_Details[] Application_Cibil_Details ; 
		public Cibil_LoanAccount_Details[] Cibil_LoanAccount_Details ; 
		public Cibil_TimeLine_Details[] Cibil_TimeLine_Details ; 
		public Cibil_ADE_Details[] Cibil_ADE_Details ; 
		public OverDueDocs_Details[] OverDueDocs_Details ; 
        public String Equifax_Generated;
        public String Equifax_Report_URl;
	}
    
    	public class Application_Cibil_Details {
		public String Lead_Id ; 
		public String Entity_Type ; 
		public String Type ; 
		public String CIC_No ; 
		public String Score ; 
		public String HighCredit_Or_SanctionedAmount ; 
		public String Current_Balance ; 
		public String RecentDate ; 
		public String OldestDate ; 
		public String Amount_Overdue ; 
		public String CibilDecision ; 
		public String Month_Overdue ; 
		public String NoOfEnLtSixMon ; 
		public String WrittenoffAmountTotal ; 
		public String SuitFiledOrWilfulDefault ; 
		public String CRIFScore_Desc ; 
	}
	
	public class Cibil_LoanAccount_Details {
		public String Lead_Id ; 
		public String CIC_No ; 
		public String Account_Type ; 
		public String Account_Type_Desc ; 
		public String Ownership ; 
		public String OpenDate ; 
		public String LastPaymentDate ; 
		public String HighCredit ; 
		public String CurrentBalance ; 
		public String AmountOverdue ; 
		public String WrittenoffAmountTotal ; 
		public String ReasonforOverdue ; 
		public String FinancierCode ; 
		public String FinanicerName ; 
		public String Maker_Id ; 
		public String Maker_Date ; 
		public String Expousure_Flag ; 
		public Enquiry_Amount Enquiry_Amount ; 
	}
	
	public class Cibil_TimeLine_Details {
		public String Date_Processed ; 
		public String Date_Z ; // in json: Date
		public String Lead_Id ; 
		public String ADE_CIC_No ; 
		public String Customer_Code ; 
		public String Deal_No ; 
		public String CIBIL_Version ; 
		public String Score ; 
		public String Arrow_Type ; 
		public String CIBIL_Detect_Decision ; 
		public String Customer_Role ; 
		public String Inprinciple_Decision ; 
		public String Final_Decision ; 
	}
	
	
	
	public class Cibil_ADE_Details {
		public String ADE_CIC_No ; 
		public String ADE_CIBIL_Enquiry ; 
		public String ADE_CIBIL_Score ; 
		public String ADE_Data_Mismatch ; 
		public String ADE_Empty_Request ; 
		public String ADE_Empty_Response ; 
		public String CIBIL_Flag ; 
		public String ADE_CIBIL_Score_Remarks ; 
		public String ADE_CIBIL_Detect_Remarks ; 
		public String Entity_type ; 
		public String Type ; 
		public String BRE_Decision ; 
		public String FI_Decision ; 
		public String Cibil_Approval_Justification ; 
		public String Product ; 
		public String Vehicle_Id ; 
	}
	
	public class Enquiry_Amount {
		public String CIC_No ; 
		public String Enquiring_Member_ShortName ; 
		public String Enquiry_Amount ; 
		public String Date_Of_Enquiry ; 
	}
	
	public class OverDueDocs_Details {
		public String Docs_ID ; 
		public String Lead_Id ; 
		public String PreDocs_TypeID ; 
		public String PreDocs_Type ; 
		public String Filename ; 
		public String Filestring ; 
		public String Fileformat ; 
		public String Maker_ID ; 
		public String Maker_Date ; 
		public String Doc_Category ; 
		public String Approval_Flag ; 
		public String Verified_Flag ; 
		public String Verified_By ; 
		public String Verified_On ; 
		public String Verification_Remarks ; 
		public String Uploading_Flag ; 
		public String RCU_RB ; 
	}

}