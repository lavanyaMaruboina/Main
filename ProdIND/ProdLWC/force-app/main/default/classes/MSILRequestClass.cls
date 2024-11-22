public class MSILRequestClass {

    public class LeadExistingRelationship {
		public String leadVehicleType;
		public String ExistingCustomerStatus;
		public String CustomerCode;
		public String DealNumber;
		public Object CustomerDataJSON;
		public String MakeCode;
		public String MakeName;
		public String ModelCode;
		public String ModelName;
		public String ManufacturerCode;
		public String Product;
		public String VariantCode;
		public String VariantName;
	}

	public MetaData metaData;
	public LeadExistingRelationship leadExistingRelationship;
	public LeadDetails leadDetails;
	public MSIL_UserData MSIL_UserData;
	public List<String> DocTypeIds;

	public class MakeData {
		public String id;
		public String make_code;
		public String make_name;
		public String manufacturer_code;
		public String model_code;
		public String model_name;
		public String product;
		public String variant_code;
		public String variant_name;
	}

	public class LeadDetails {
		public String TimeFrame;
		public String leadStatus;
		public String Product;
		public String Make;
		public String FinanceAmount;
		public String Mobile;
		public String Name;
		public String LeadSource;
		public String Model;
		public String VariantCount;
		public String VehicleCount;
		public String Dealer;
		public MakeData MakeData;
		public MakeData ModelData;
		public DealerData DealerData;
	}

	public class MetaData {
		public ApplicationInfo applicationInfo;
	}

	public class DealerData {
		public String Ben_Name;
		public String Ben_code;
		public String Beneficiary_Type;
		public String Dealership_Nature;
		public String GST_Number;
		public String Product;
		public String Used_Flag;
		public String bl_code;
		public String id;
		public String manufacturer_code;
	}

	public class MSIL_UserData {
		public String Salutation;
		public String FirstName;
		public String LastName;
		public String Gender;
		public Date DateofBirth;
		public String Profession;
		public String employmentType;
		public String CustomerQualification;
		public String noOfDependents;
		public String PANNumber;
		public String Mobile;
		public String email;
		public String MaritalStatus;
		public String Payslip;
		public String Curr_Resi_Address_Line_1;
		public String Curr_Resi_Address_Line_2;
		public String Curr_Resi_City;
		public String Curr_Resi_Pin_code;
		public String Curr_Resi_State;
		public String YearsInResidence;
		public String Off_Address_Line_1;
		public String Off_Address_Line_2;
		public String Off_City;
		public String Off_Pin_code;
		public String Off_State;
		public Decimal FinanceROI;// CISP-2358
		public Decimal FinanceVehicleTenor;
		public String Employee_Name;
		public String Branch_Name;
		public String Send_SMS_To;
	}

	public class ApplicationInfo {
		public String IIModuleID;
		public String Lead_Sourced_Through;
		public String agentId;
		public String agentBLCode;
	}
    public  MSILRequestClass parseJSON(String json) {
        return (MSILRequestClass) System.JSON.deserialize(json, MSILRequestClass.class);
    }
}