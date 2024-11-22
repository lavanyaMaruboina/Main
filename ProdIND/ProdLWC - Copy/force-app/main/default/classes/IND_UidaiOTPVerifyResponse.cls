/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class contains methods related to UIDAI OTP Verify Response Wrapper.
Inputs:        None 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
9-12-2021      Bhushan Charde       Created
------------------------------------------------------------*/
public class IND_UidaiOTPVerifyResponse extends ParentAPIResponse{
	
    public KycResponse kycResponse;

	public class TransactionInfo {
		public final String Pan;
		public final String Proc_Code;
		public final String Transm_Date_time;
		public final String Stan;
		public final String Local_Trans_Time;
		public final String Local_date;
		public final String AcqId;
		public final String RRN;
		public final String ResponseCode;
		public final String ResponseMsg;
		public final String CA_Tid;
		public final String CA_ID;
		public final String CA_TA;
	}

	public class KycResponse {
		public final TransactionInfo TransactionInfo;
		public final UidData UidData;
	}

	public class UidData {
		public final String tkn;
		public final String txn;
		public final String uid;
		public final String dob;
		public final String gender;
		public final String name;
		public final String email;
		public final String phone;
		public final String dist;
		public final String house;
		public final String lm;
		public final String co;
		public final String subdist;
		public final String po;
		public final String loc;
		public final String pc;
		public final String state;
		public final String street;
		public final String vtc;
		public final String Pht;
	}

}