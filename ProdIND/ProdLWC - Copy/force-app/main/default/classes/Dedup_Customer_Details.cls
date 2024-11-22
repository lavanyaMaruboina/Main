public class Dedup_Customer_Details {
	public String Customer_Name;	//PRODIGY BUSINESS SOLUTIONS
	public String Customer_Type;	//30
	public String Date_of_Birth;	//2/15/1974 12:00:00 AM
	public String PAN_GIR_Number;	//ATQPK4947F
	public String Passport_Number;	//EC4744643
	public String Voter_ID_Number;	//DL/01/001/000000
	public String Driving_License_Number;	//1/234/56/X
	public String Aadhaar_No;	//999999990019
	public String Entity;	//Individual
	public String CustomerCodeVal;	//CU7667071
	public static Dedup_Customer_Details parse(String json){
		return (Dedup_Customer_Details) System.JSON.deserialize(json, Dedup_Customer_Details.class);
	}
}