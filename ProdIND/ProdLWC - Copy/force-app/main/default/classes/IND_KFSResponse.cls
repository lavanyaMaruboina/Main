public class IND_KFSResponse extends ParentAPIResponse{
    public String Lead_No;	//L28062404498
	public String Deal_No;	//AA7H74526
	public String Sub_Dealer;	//I. B. MOT
	public ApplicantDetails[] ApplicantDetails;
	public VehicleDetails[] VehicleDetails;
	public FinalTerms[] FinalTerms;
	public InstalmentSchedule[] InstalmentSchedule;
	public AddressDetails[] AddressDetails;
	public MMVDetails[] MMVDetails;
	public GSTDetails[] GSTDetails;
	public class ApplicantDetails {
		public String ApplicantType;	//BORROWER
		public String Customer_Name;	//JADEJA 
		public String Customer_Code;	//77303658
		public String Passport_Number;	//
		public String PAN_GIR_Number;	//CZQPJ0484E
		public String Voter_ID_Number;	//TYH2199354
		public String Customer_Salutation;	//MR
		public String Passport_Expiry_Date;	//
		public String Date_of_Birth;	//19-02-2005 00:00:00
		public String Driving_License_Number;	//
		public String Driving_License_Expiry_Date;	//
		public String Aadhaar_No;	//
		public String FORM60;	//
		public String SurName;	//KARMDIPSINH
		public String Regn_Incorp_Date;	//
		public String CKYC_ID;
		public String UCIC;
		public String Customer_Type;
	}
	public class VehicleDetails {
		public String Engine_No;	//
		public String Chassis_no;	//
		public String Vehicle_Reg_No;	//
		public String Deal_No;	//AA7H74526
		public String Valuation_Charges;

		public String GPA_Type;	//
		public String GPA_Type_G;	//AA7H74526
		public String GPA_Premium;	//
		public String GPA_Premium_G;	//
		
		public String LI_Fund_Type;
		public String LI_Fund_Type_G;	//
		public String LI_Prm;	//
		public String LI_Prm_G;	//
		public String Combo_Fund_Type;	//AA7H74526
		public String Combo_Fund_Type_G;
		public String Combo_Product;	//

		public String Combo_Product_G;	//

		public String Combo_Premium;	//
		public String Combo_Premium_G;	//AA7H74526

		public String Subh_Raksha_Prm;
		public String Subh_Raksha_Prm_G;	//

		public String Health_Fund_Type;	//
		public String Health_Fund_Type_G;	//

		public String Health_Premium;	//AA7H74526
		public String Health_Premium_G;

		public String Flexi_Fund_Type;	//
		public String Flexi_Fund_Type_G;	//
		public String Flexi_Prm;	//AA7H74526
		public String Flexi_Prm_G;

		public String TATA_EMI_Fund_Type;
		public String TATA_EMI_Premium;	//
		public String Ins_Prm_I;	//
		public String Ins_Premium;
		public String Motor_Fund_Type;	//
		public String Ins_Prm_Paid_I;	
		public String Install_Pattern_Type;
	}
	public class FinalTerms {
		public String Deal_No;	//AA7H74526
		public String Fin_Amt;	//89000.0000
		public String Gross_IRR;	//20.9300
		public String Deal_Period;	//36
		public String Moratorium;	//30
		public String Advance_EMI_Nos;	//0
		public String CRM_IRR;	//19.8500
		public String First_EMI_Date;	//07-09-2024 00:00:00
        public String Second_EMI_Date;
		public String Net_Disburse_Amt;	//87277.0000
		public String Gross_LTV;	//76.7200
		public String Vehicle_Sub_Category;	//New
		public String Vehicle_Category;
		public String Product;	//H
		public String Mfg_Year;	//0
		public String Service_Charges;	//750.0000
		public String Doc_Charges;	//750.0000
		public String Stamping_Charges;	//223.0000
		public String MCLR;
		public String APR;
		public String Periodicity;	//223.0000
		public String Agreement_Value;
		public String Finance_Charges;
		public String Instalment_Nos;
		public String Invoice_Amt;


		public String IHM_Computed;
		public String Eff_from_date;
		public String Fin_Amt_Chasis;
		public String Bl_Name;
		public String Bl_Code;
		public String Sold_By_Dealer_Name;

		public String Net_Disburse_Amt_Apr;
		public String Deal_Date;


	}
	public class InstalmentSchedule {
		public String Deal_No;	//AA7H74526
		public String From_No;	//1
		public String To_No;	//1
		public String Instal_Nos;	//1
		public String Instal_Amt;	//3370.0000
		public String Insur_Amt;	//
		public String EMI;	//3370.0000
		public String Health_Amt;	//
		public String Hospital_Cash_Amt;	//
		public String POSB_Charges;	//
		public String Combo_Amt;	//
		public String Instal_Date;	//07-09-2024 00:00:00
		public String RD_Amount;	//
		public String Interest;
		public String Principal;	//07-09-2024 00:00:00
		public String Balance;
	}
	public class AddressDetails {
		public String Customer_Code;	//77303658
		public String Address_Flag;	//O
		public String Address_Line_1;	//Vrundavan society
		public String Address_Line_2;	//Vivek pavbhaji same dhrol jamnagar
		public String Address_Line_3;	//Vivek pavbhaji same dhrol jamnagar
		public String Address_Line_4;	//JAMNAGAR
		public String State;	//GUJARAT
		public String District;	//JAMNAGAR
		public String Pin_code;	//361210
		public String City;	//JAMNAGAR
		public String Mobile_Number;	//9773237573
		public String Communication_Address_Flag;	//
	}
	public class MMVDetails {
		public String Deal_No;	//AA7H74526
		public String Product_Code;	//1
		public String Product_Name;	//1
		public String Product_Varient_code;	//1
		public String Product_Variant_Name;	//3370.0000
		public String Make;
		public String Beneficiary_Code;
	}

	public class GSTDetails {
		public String Deal_No;	//AA7H74526
		public String Nature;	//1
		public String GST_Value;	//1
		public String Document_Value;	//1
		public String GST_Number;
	}
	 public static IND_KFSResponse parse(String json){
		return (IND_KFSResponse) System.JSON.deserialize(json, IND_KFSResponse.class);
	}
	public static void testParse(){
		String json = '{' +
    ' "Lead_No": "AC7146403_27433541226",' +
    ' "Deal_No": "DDU03502D",' +
    ' "Sub_Dealer": "BEN002224",' +
    ' "ApplicantDetails": [' +
    ' {' +
    ' "ApplicantType": "BORROWER",' +
    ' "Customer_Name": "S TWO S CARRIERS LLP",' +
    ' "Customer_Code": "77852545",' +
    ' "Passport_Number": "",' +
    ' "PAN_GIR_Number": "AFAFS8414F",' +
    ' "Voter_ID_Number": "",' +
    ' "Customer_Salutation": "MS",' +
    ' "Passport_Expiry_Date": "",' +
    ' "Date_of_Birth": "01-01-1900 00:00:00",' +
    ' "Driving_License_Number": "",' +
    ' "Driving_License_Expiry_Date": "",' +
    ' "Aadhaar_No": "",' +
    ' "FORM60": "",' +
    ' "SurName": "",' +
    ' "Regn_Incorp_Date": "04-07-2023 05:30:00",' +
    ' "CKYC_ID": "",' +
    ' "UCIC": "106454229",' +
	' "Customer_Type": "10"' +
    ' },' +
    ' {' +
    ' "ApplicantType": "GUARANTOR",' +
    ' "Customer_Name": "SACHIDA NAND PRASAD",' +
    ' "Customer_Code": "CU7830675",' +
    ' "Passport_Number": "",' +
    ' "PAN_GIR_Number": "AWYPP6280F",' +
    ' "Voter_ID_Number": "",' +
    ' "Customer_Salutation": "MR",' +
    ' "Passport_Expiry_Date": "",' +
    ' "Date_of_Birth": "15-09-1982 00:00:00",' +
    ' "Driving_License_Number": "",' +
    ' "Driving_License_Expiry_Date": "",' +
    ' "Aadhaar_No": "1760",' +
    ' "FORM60": "",' +
    ' "SurName": "",' +
    ' "Regn_Incorp_Date": "",' +
    ' "CKYC_ID": "10007040029176",' +
    ' "UCIC": "106454229",' +
	' "Customer_Type": "10"' +
    ' },' +
    ' {' +
    ' "ApplicantType": "RELATION",' +
    ' "Customer_Name": "SUNITA",' +
    ' "Customer_Code": "CW4087017",' +
    ' "Passport_Number": "",' +
    ' "PAN_GIR_Number": "CFRPD7178E",' +
    ' "Voter_ID_Number": "",' +
    ' "Customer_Salutation": "MRS",' +
    ' "Passport_Expiry_Date": "",' +
    ' "Date_of_Birth": "02-01-1988 00:00:00",' +
    ' "Driving_License_Number": "",' +
    ' "Driving_License_Expiry_Date": "",' +
    ' "Aadhaar_No": "4912",' +
    ' "FORM60": "",' +
    ' "SurName": "DEVI",' +
    ' "Regn_Incorp_Date": "",' +
    ' "CKYC_ID": "60013034175784",' +
    ' "UCIC": "106454229",' +
	' "Customer_Type": "10"' +
    ' }' +
    ' ],' +
    ' "VehicleDetails": [' +
    ' {' +
    ' "Engine_No": "5LNGDICR34FVX105196",' +
    ' "Chassis_no": "MAT835203R1F18044",' +
    ' "Vehicle_Reg_No": "HR55AB4001",' +
    ' "Deal_No": "DDU03502D",' +
    ' "Valuation_Charges": "0.0000",' +
    ' "GPA_Type": " ", ' +
    ' "GPA_Premium": "0.0000",' +
    ' "GPA_Type_G": " ", ' +
    ' "GPA_Premium_G": "0.0000",' +
    ' "LI_Fund_Type": "B",' +
    ' "LI_Prm": "50123.0000",' +
    ' "LI_Fund_Type_G": " ", ' +
    ' "LI_Prm_G": "0.0000",' +
    ' "Combo_Fund_Type": "",' +
    ' "Combo_Product": "",' +
    ' "Combo_Premium": "0.0000",' +
    ' "Combo_Fund_Type_G": "",' +
    ' "Combo_Product_G": "",' +
    ' "Combo_Premium_G": "0.0000",' +
    ' "Subh_Raksha_Prm": "0.0000",' +
    ' "Subh_Raksha_Prm_G": "0.0000",' +
    ' "Health_Fund_Type": "",' +
    ' "Health_Premium": "0.0000",' +
    ' "Health_Fund_Type_G": "",' +
    ' "Health_Premium_G": "0.0000",' +
    ' "TATA_EMI_Fund_Type": "",' +
    ' "TATA_EMI_Premium": "0.0000",' +
    ' "Flexi_Fund_Type": "",' +
    ' "Flexi_Prm": "0.0000",' +
    ' "Flexi_Fund_Type_G": "",' +
    ' "Flexi_Prm_G": "0.0000",' +
    ' "Ins_Prm_I": "68187.0000",' +
    ' "Ins_Premium": "0.0000",' +
    ' "Motor_Fund_Type": "C",' +
    ' "Ins_Prm_Paid_I": "D",' +
    ' "Install_Pattern_Type": "S"' +
    ' }' +
    ' ],' +
    ' "FinalTerms": [' +
    ' {' +
    ' "Deal_No": "DDU03502D",' +
    ' "Fin_Amt": "3250123.0000",' +
    ' "Gross_IRR": "9.9100",' +
    ' "Deal_Period": "60",' +
    ' "Moratorium": "60",' +
    ' "Advance_EMI_Nos": "0",' +
    ' "CRM_IRR": "9.8100",' +
    ' "First_EMI_Date": "15-11-2024 00:00:00",' +
    ' "Net_Disburse_Amt": "3190900.0000",' +
    ' "Gross_LTV": "94.2000",' +
    ' "Vehicle_Sub_Category": "NEW",' +
    ' "Product": "D",' +
    ' "Mfg_Year": "0",' +
    ' "Service_Charges": "0.0000",' +
    ' "Doc_Charges": "9000.0000",' +
    ' "Stamping_Charges": "100.0000",' +
    ' "APR": "11.9990203672681",' +
    ' "MCLR": "10.5500",' +
    ' "Customer_Code": "77852545",' +
    ' "Gurantor_Code": "CU7830675",' +
    ' "Periodicity": "M",' +
    ' "Agreement_Value": "4127657.0000",' +
    ' "Finance_Charges": "877534.0000",' +
    ' "Vehicle_Category": "N",' +
    ' "Instalment_Nos": "58",' +
    ' "Invoice_Amt": "3400000.0000",' +
    ' "IHM_Computed": "209100.0000",' +
    ' "Eff_from_date": "23-09-2024 00:00:00",' +
    ' "Fin_Amt_Chasis": "3000000.0000",' +
    ' "Bl_Name": "GURGAON_DDU",' +
    ' "Bl_Code": "DDU ",' +
    ' "Sold_By_Dealer_Name": "M.G.MOTORS",' +
	' "Deal_Date": "",' +
    ' "Net_Disburse_Amt_Apr": "1"' +
    ' }' +
    ' ],' +
    ' "InstalmentSchedule": [' +
    ' {' +
    ' "Deal_No": "DDU03502D",' +
    ' "From_No": "1",' +
    ' "To_No": "1",' +
    ' "Instal_Nos": "1",' +
    ' "Instal_Amt": "71166.0000",' +
    ' "Insur_Amt": "",' +
    ' "EMI": "71166.0000",' +
    ' "Health_Amt": "",' +
    ' "Hospital_Cash_Amt": "",' +
    ' "POSB_Charges": "",' +
    ' "Combo_Amt": "",' +
	' "Interest": "11",' +
	' "Principal": "1",' +
	' "Balance": "1",' +
    ' "Instal_Date": "15-11-2024 00:00:00",' +
    ' "RD_Amount": ""' +
	' }' +
    ' ],' +
	' "AddressDetails": [' +
    '{' +
    ' "Customer_Code": "77852545",' +
    ' "Address_Flag": "P",' +
    ' "Address_Line_1": "",' +
    ' "Address_Line_2": "",' +
    ' "Address_Line_3": "",' +
    ' "Address_Line_4": "",' +
    ' "State": "",' +
    ' "District": "",' +
    ' "Pin_code": "",' +
    ' "City": "",' +
    ' "Mobile_Number": "9543822122",' +
    ' "Communication_Address_Flag": ""' +
    ' },' +
    ' {' +
    ' "Customer_Code": "77852545",' +
    ' "Address_Flag": "R",' +
    ' "Address_Line_1": "",' +
    ' "Address_Line_2": "",' +
    ' "Address_Line_3": "",' +
    ' "Address_Line_4": "",' +
    ' "State": "",' +
    ' "District": "",' +
    ' "Pin_code": "",' +
    ' "City": "",' +
    ' "Mobile_Number": "9543822122",' +
    ' "Communication_Address_Flag": ""' +
    ' },' +
    ' {' +
    ' "Customer_Code": "77852545",' +
    ' "Address_Flag": "O",' +
    ' "Address_Line_1": "First floor,shop no-3,Rewari sohna road",' +
    ' "Address_Line_2": "Near gaurav fuels,Dharuhera,rewari",' +
    ' "Address_Line_3": "Near gaurav fuels,Dharuhera,rewari",' +
    ' "Address_Line_4": "",' +
    ' "State": "HARYANA",' +
    ' "District": "REWARI",' +
    ' "Pin_code": "123106",' +
    ' "City": "Rewari",' +
    ' "Mobile_Number": "9543822122",' +
    ' "Communication_Address_Flag": "C"' +
    ' },' +
    ' {' +
    ' "Customer_Code": "CU7830675",' +
    ' "Address_Flag": "R",' +
    ' "Address_Line_1": "TOWER- 06",' +
    ' "Address_Line_2": "FALT NO-601",' +
    ' "Address_Line_3": "VIPAUL GARDEN",' +
    ' "Address_Line_4": "DHARUHERA",' +
    ' "State": "HARYANA",' +
    ' "District": "GURGAON",' +
    ' "Pin_code": "122001",' +
    ' "City": "GURGAON",' +
    ' "Mobile_Number": "9543822122",' +
    ' "Communication_Address_Flag": "C"' +
    ' },' +
    ' {' +
    ' "Customer_Code": "CW4087017",' +
    ' "Address_Flag": "R",' +
    ' "Address_Line_1": "Dumariya Anchal Gopalganj",' +
    ' "Address_Line_2": "Dis-Dumariya",' +
    ' "Address_Line_3": "Dis-Dumariya",' +
    ' "Address_Line_4": "",' +
    ' "State": "BIHAR",' +
    ' "District": "GOPALGANJ",' +
    ' "Pin_code": "841428",' +
    ' "City": "Dumariya",' +
    ' "Mobile_Number": "9471004329",' +
    ' "Communication_Address_Flag": ""' +
    ' },' +
    ' {' +
    ' "Customer_Code": "CW4087017",' +
    ' "Address_Flag": "O",' +
    ' "Address_Line_1": "Dumariya Anchal Gopalganj",' +
    ' "Address_Line_2": "Dis-Dumariya",' +
    ' "Address_Line_3": "Dis-Dumariya",' +
    ' "Address_Line_4": "",' +
    ' "State": "BIHAR",' +
    ' "District": "GOPALGANJ",' +
    ' "Pin_code": "841428",' +
    ' "City": "Dumariya",' +
    ' "Mobile_Number": "9471004329",' +
    ' "Communication_Address_Flag": ""' +
    ' },' +
    ' {' +
    ' "Customer_Code": "CW4087017",' +
    ' "Address_Flag": "P",' +
    ' "Address_Line_1": "Dumariya Anchal Gopalganj",' +
    ' "Address_Line_2": "Dis-Dumariya",' +
    ' "Address_Line_3": "Dis-Dumariya",' +
    ' "Address_Line_4": "",' +
    ' "State": "BIHAR",' +
    ' "District": "GOPALGANJ",' +
    ' "Pin_code": "841428",' +
    ' "City": "Dumariya",' +
    ' "Mobile_Number": "9471004329",' +
    ' "Communication_Address_Flag": "C"' +
    ' }' +
    ' ],' +
	' "MMVDetails": [' +
	'{' +
    ' "Deal_No": "DDU03502D",' +
    ' "Product_Code": "TATL2821G",' +
    ' "Product_Name": "TATA LPT 2821/68 BS6 TRUCK COWL CHASSIS",' +
    ' "Product_Varient_code": "TMLL2821G",' +
    ' "Product_Variant_Name": "TATA LPT 2821/68 BS6 TRUCK COWL CHASSIS",' +
    ' "Make": "TATA",' +
    ' "Beneficiary_Code": "BEN002224"' +
    ' },' +
    ' {' +
    ' "Deal_No": "DDU03502D",' +
    ' "Product_Code": "TATL2821G",' +
    ' "Product_Name": "TATA LPT 2821/68 BS6 TRUCK COWL CHASSIS",' +
    ' "Product_Varient_code": "TMLL2821G",' +
    ' "Product_Variant_Name": "TATA LPT 2821/68 BS6 TRUCK COWL CHASSIS",' +
    ' "Make": "TATA",' +
    ' "Beneficiary_Code": "PAYTOCUST"' +
    ' }' +
    ' ],' +
	' "GSTDetails": [' +
    '{' +
    ' "Deal_No": "DDU03502D",' +
    ' "Nature": "DOC_CHRGS",' +
    ' "GST_Value": "1372.8800",' +
    ' "Document_Value": "7627.1200",' +
	' "GST_Number": "7627"' +
    ' }'+
    ' ]' +
	' }';
	IND_KFSResponse obj = parse(json);
	}
}