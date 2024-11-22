/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class contains methods related to UIDAI OTP Response Wrapper.
Inputs:        None 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
9-12-2021      Bhushan Charde       Created
9-30-2021      Bhushan Charde       Modified - response structure changed
------------------------------------------------------------*/
public class IND_UidaiOTPResponse extends ParentAPIResponse{
    
    public KycResponse kycResponse{get;set;}

	public class TransactionInfo {
		public final String Pan{get;set;}
		public final String Proc_Code{get;set;}
		public final String Transm_Date_time{get;set;}
		public final String Stan{get;set;}
		public final String Local_Trans_Time{get;set;}
		public final String Local_date{get;set;}
		public final String AcqId{get;set;}
		public final String RRN{get;set;}
		public final String ResponseCode{get;set;}
		public final String ResponseMsg{get;set;}
		public final String CA_Tid{get;set;}
		public final String CA_ID{get;set;}
		public final String CA_TA{get;set;}
	}

	public class KycResponse {
		public final TransactionInfo TransactionInfo{get;set;}
		public final UidData UidData{get;set;}
	}

	public class UidData {
		public final String txn{get;set;}
	}
}