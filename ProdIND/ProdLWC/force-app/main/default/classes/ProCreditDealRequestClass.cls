public class ProCreditDealRequestClass {
    public String Source;
	public String Product;
	public String Maker_Id;
	public DealNumbers[] DealNumbers;
	public String Unique_Id;
	public String Entity_Type;
    public class DealNumbers {
		public String Deal_No;
	}
	public ProCreditDealRequestClass parseJSON(String json){
		return (ProCreditDealRequestClass) System.JSON.deserialize(json, ProCreditDealRequestClass.class);
	}

	public static void testParse(){
		String json='{"Source": "Procredit","Product": "H","Unique_Id":"987654","Entity_Type":"IND","Maker_Id": "123","DealNumbers": [{"Deal_No": "TTM01037S"}]}';
		ProCreditDealRequestClass obj = new ProCreditDealRequestClass();
		obj.parseJSON(json);
	}
}