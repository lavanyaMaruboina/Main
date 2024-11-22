public class Customer_Dedup_Response_Parser{
	public cls_response response;
	public class cls_response {
		public String status;	//SUCCESS
		public String respDesc;	//IxsightEnquiry
		public cls_content[] content;
	}
	public class cls_content {
		public cls_Data Data;
		public String ErrorDesc;	//
	}
	public class cls_Data {
		public cls_ExternalDedupeResponse ExternalDedupeResponse;
		public cls_InternalDedupeResponse[] InternalDedupeResponse;
		//below 3 fields are added as per latest dedupe API shared by IBL
		public cls_Customer_Enquire_Dt Customer_Enquire_Dt;
		public String reponseMessage;
		public String status;
		public cls_NonCFD_NPA NonCFD_NPA;//CISP-4493
	}
	public class cls_NonCFD_NPA{
		public String REFERENCE_NO;	//CISP-4493
		public String NPATYPE;	//CISP-4493
	}
	public class cls_ExternalDedupeResponse {
		public String DEDUPE_STATUS;	//M
		public cls_DtCFDCUSTBAS[] DtCFDCUSTBAS;
		public cls_DtRECENTLEAD[] DtRECENTLEAD;
		public cls_CustomerValidate[] CustomerValidate;
	}
	public class cls_DtCFDCUSTBAS {
		public String SOURCE_CIC_NO;	//2022268275545880078
		public String MATCH_ECIF;	//3095268
		public String MATCHED_CUSTOMER_NAME;	//S DEIVARAJ
		public String MATCHED_CUSTOMER_CODE;	//CU0503174
		public String MATCHED_SOURCE;	//CFD
		public String MATCHED_SCORE;	//100
		public String MATCHED_CRITERIA;	//VOTERID100
		public String CONFIDENCE_LEVEL;	//1
	}
	public class cls_DtRECENTLEAD {
		public String SOURCE_CIC_NO;	//2022268275545880078
		public String MATCHED_CIC_NO;	//991102194599513090
		public String MATCHED_LEAD_NAME;	//DEIVARAJ S
		public String MATCHED_LEAD_DATE;	//12/15/2021 13:55:28
		public String MATCHED_SCORE;	//100
		public String MATCHED_CRITERIA;	//PAN100
	}
	public class cls_CustomerValidate {
		public String CustomerCodeVal;	//CU0503174
		public cls_CustomerMaster[] CustomerMaster;
		public cls_CustomerStatus[] CustomerStatus;
		public cls_Dealstatus[] Dealstatus;
		public cls_NPA[] NPA;
		public cls_Restructure[] Restructure;
		public cls_Gecl[] Gecl;
		public cls_ARC[] ARC;
		public cls_PanAlert[] PanAlert;
		public cls_CINAlert[] CINAlert;
		public cls_BeneficiaryAlert BeneficiaryAlert;
	}
	public class cls_CustomerMaster {
		public String CIC_No;
		public String Matched_Customer_Code;
		public String Rule_Matching_Fields;
		public String Current_Parameter_Value;
		public String Matched_Parameter_Value;
		public String Matched_Score;
		public String Rule_Field_Weightage;
		public String Matched_Source;
		public String Active_Flag;
		public String Dedupe_Super_Match;
		public String Dedupe_Super_Match_Score;
		public String Rule_Id;
		public String Type;
		public String PEP_Remarks;
		public String Customer_Name;	//S DEIVARAJ
		public String Customer_Type;	//10
		public String Date_of_Birth;	//27-06-1986 00:00:00
		public String PAN_GIR_Number;	//
		public String Passport_Number;	//
		public String Voter_ID_Number;	//CKK1913391
		public String Driving_License_Number;	//
		public String Aadhaar_No;	//
	}
	public class cls_CustomerStatus {
		public String Cross_Dedupe_Match_Id;	//3095268
		public String Active_Flag;	//Z
	}
	public class cls_Dealstatus {
		public String Deal_No;	//TTU05950H
		public String Status_Flag;	//Z
	}
	public class cls_NPA {
        public String REFERENCE_NO;
        public String NPATYPE;
	}
	public class cls_Restructure {
		public String Deal_Restructured;	//Yes
	}
	public class cls_Gecl {
       	public String Deal_No;
        public String Status_Flag;
	}
	public class cls_ARC {
        public String Deal_No;
        public String ARC_Reference_No;
        public String ARC_Buyer_Name;
        public String ARC_Sale_Date;
	}
	public class cls_PanAlert {
        public String PAN;
        public String Customer_Name;
        public String Listing;
        public String Remarks;
        public String Source_Report_Date;
	}
	public class cls_CINAlert {
        public String PAN;
        public String Customer_Name;
        public String Listing;
        public String Remarks;
        public String Source_Report_Date;
	}
	public class cls_BeneficiaryAlert {
		public String Ben_code;
		public String Beneficiary;
		public String Status_Flag;
		public String PAN_No;
	}
	public class cls_InternalDedupeResponse {
		public cls_CustomerMaster[] CustomerMaster;
		public cls_CustomerValidate[] CustomerValidate;
	}

	public class cls_Customer_Enquire_Dt {
		public String cifId;
		public String PAN;
		public String DOBorDOI;
		public String firstName;
		public String lastName;
		public String gender;
		public String maritalStatus;
		public String phoneNumber;
		public String kycDate;
		public String nextKYCdate;
	}

	public static Customer_Dedup_Response_Parser parse(String json){
		return (Customer_Dedup_Response_Parser) System.JSON.deserialize(json, Customer_Dedup_Response_Parser.class);
	}
}