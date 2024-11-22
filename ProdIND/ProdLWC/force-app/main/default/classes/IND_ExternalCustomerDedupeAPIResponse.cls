/*------------------------------------------------------------
Author:        Sharad Kathane
Company:       Persistent Systems
Description:   This class is wrapper class for the ExternalCustomerDedupeAPI response 
Test Class:    IND_ExternalCustomerDedupeAPIResponseTest 
History
Date            Author              Comments
-------------------------------------------------------------
28-10-2021      Sharad Kathane      Created
------------------------------------------------------------*/
public class IND_ExternalCustomerDedupeAPIResponse  extends ParentAPIResponse {
public Response response{get;set;}

	public class DtRECENTLEAD {
		public final String SOURCE_CIC_NO{get;set;}
		public final String MATCHED_CIC_NO{get;set;}
		public final  String MATCHED_LEAD_NAME{get;set;}
		public final  String MATCHED_LEAD_DATE{get;set;}
		public final  String MATCHED_SCORE{get;set;}
		public final  String MATCHED_CRITERIA{get;set;}
	}

	public class DtCFDCUSTBAS {
		public final  String SOURCE_CIC_NO{get;set;}
		public final  String MATCH_ECIF{get;set;}
		public final  String MATCHED_CUSTOMER_NAME{get;set;}
		public final  String MATCHED_CUSTOMER_CODE{get;set;}
		public final  String MATCHED_SOURCE{get;set;}
		public final  String MATCHED_SCORE{get;set;}
		public final  String MATCHED_CRITERIA{get;set;}
		public final  String CONFIDENCE_LEVEL{get;set;}
	}

	public class CustomerMaster {
		public final  String Customer_Name{get;set;}
		public final  String Customer_Type{get;set;}
		public final  String Date_of_Birth{get;set;}
		public final  String PAN_GIR_Number{get;set;}
		public final  String Passport_Number{get;set;}
		public final  String Voter_ID_Number{get;set;}
		public final  String Driving_License_Number{get;set;}
		public final  String Aadhaar_No{get;set;}
	}

	public class BeneficiaryAlert {
		public final  Object Ben_code{get;set;}
		public final  Object Beneficiary{get;set;}
		public final  Object Status_Flag{get;set;}
		public final  Object PAN_No{get;set;}
	}

	public class CustomerValidate {
		public final  String CustomerCodeVal{get;set;}
		public final  List<CustomerMaster> CustomerMaster{get;set;}
		public final  List<CustomerStatus> CustomerStatus{get;set;}
		public final  List<Dealstatus> Dealstatus{get;set;}
		public final  List<NPA> NPA{get;set;}
		public final  List<Restructure> Restructure{get;set;}
		public final  List<NPA> Gecl{get;set;}
		public final  List<NPA> ARC{get;set;}
		public final  List<NPA> PanAlert{get;set;}
		public final  List<NPA> CINAlert{get;set;}
		public final  BeneficiaryAlert BeneficiaryAlert{get;set;}
	}

	public class Data {
		public final  ExternalDedupeResponse ExternalDedupeResponse{get;set;}
		public final  List<InternalDedupeResponse> InternalDedupeResponse{get;set;}
	}

	public class CustomerMaster_Z {
		public final  String CIC_No{get;set;}
		public final  String Matched_Customer_Code{get;set;}
		public final  String Rule_Matching_Fields{get;set;}
		public final  String Current_Parameter_Value{get;set;}
		public final  String Matched_Parameter_Value{get;set;}
		public final  String Matched_Score{get;set;}
		public final  String Rule_Field_Weightage{get;set;}
		public final  String Matched_Source{get;set;}
		public final  String Active_Flag{get;set;}
		public final  String Dedupe_Super_Match{get;set;}
		public final  String Dedupe_Super_Match_Score{get;set;}
		public final  String Rule_Id{get;set;}
		public final  String Type{get;set;}
		public final  String PEP_Remarks{get;set;}
		public final  Object Customer_Name{get;set;}
		public final  Object Customer_Type{get;set;}
		public final  Object Date_of_Birth{get;set;}
		public final  Object PAN_GIR_Number{get;set;}
		public final  Object Passport_Number{get;set;}
		public final  Object Voter_ID_Number{get;set;}
		public final  Object Driving_License_Number{get;set;}
		public final  Object Aadhaar_No{get;set;}
	}

	public class InternalDedupeResponse {
		public final  List<CustomerMaster_Z> CustomerMaster{get;set;}
		public final  List<CustomerValidate_Z> CustomerValidate{get;set;}
	}

	public class CustomerMaster_Y {
		public final  Object CIC_No{get;set;}
		public final  Object Matched_Customer_Code{get;set;}
		public final  Object Rule_Matching_Fields{get;set;}
		public final  Object Current_Parameter_Value{get;set;}
		public final  Object Matched_Parameter_Value{get;set;}
		public final  Object Matched_Score{get;set;}
		public final  Object Rule_Field_Weightage{get;set;}
		public final  Object Matched_Source{get;set;}
		public final  Object Active_Flag{get;set;}
		public final  Object Dedupe_Super_Match{get;set;}
		public final  Object Dedupe_Super_Match_Score{get;set;}
		public final  Object Rule_Id{get;set;}
		public final  Object Type{get;set;}
		public final  Object PEP_Remarks{get;set;}
		public final  String Customer_Name{get;set;}
		public final  String Customer_Type{get;set;}
		public final  String Date_of_Birth{get;set;}
		public final  String PAN_GIR_Number{get;set;}
		public final  String Passport_Number{get;set;}
		public final  String Voter_ID_Number{get;set;}
		public final  String Driving_License_Number{get;set;}
		public final  String Aadhaar_No{get;set;}
	}

	public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public class CustomerValidate_Z {
		public final  String CustomerCodeVal{get;set;}
		public final  List<CustomerMaster_Y> CustomerMaster{get;set;}
		public final  List<CustomerStatus> CustomerStatus{get;set;}
		public final  List<Dealstatus> Dealstatus{get;set;}
		public final  List<NPA> NPA{get;set;}
		public final  List<Restructure> Restructure{get;set;}
		public final  List<NPA> Gecl{get;set;}
		public final  List<NPA> ARC{get;set;}
		public final  List<NPA> PanAlert{get;set;}
		public final  List<NPA> CINAlert{get;set;}
		public final  BeneficiaryAlert BeneficiaryAlert{get;set;}
	}

	public class Content {
		public final  Data Data{get;set;}
		public final  String ErrorDesc{get;set;}
	}

	public class CustomerStatus {
		public final  String Cross_Dedupe_Match_Id{get;set;}
		public final  String Active_Flag{get;set;}
	}

	public class Restructure {
		public final  String Deal_Restructured{get;set;}
	}

	public class Dealstatus {
		public final  String Deal_No{get;set;}
		public final  String Status_Flag{get;set;}
	}

	public class ExternalDedupeResponse {
		public final String DEDUPE_STATUS{get;set;}
		public final  List<DtCFDCUSTBAS> DtCFDCUSTBAS{get;set;}
		public final  List<DtRECENTLEAD> DtRECENTLEAD{get;set;}
		public final  List<CustomerValidate> CustomerValidate{get;set;}
	}

	public class NPA {
	}


}