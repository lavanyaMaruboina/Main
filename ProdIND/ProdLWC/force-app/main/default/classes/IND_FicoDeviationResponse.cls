/*------------------------------------------------------------
Author:        Prathik
Company:       Persistent Systems
Description:   This class is wrapper class for the IND Fico Ddeviation API response
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Prathik Created		Created
03-07-2021      Bhushan Charde      Modified - Change in request
------------------------------------------------------------*/
public class IND_FicoDeviationResponse  extends ParentAPIResponse {    
    public Borrower Borrower;
	public Borrower CoBorrower;
	public Borrower Beneficiary;
	public Borrower Guarantor;
	public String netLTV;// CISP-2491
	public String grossltv;// CISP-2491

	public class ConditionValues {
		public String variableName;
		public String variableValue;
	}

	public class Deviations {
		public String DeviationId;
		public String DeviationName;
		public String Level;
		public string displayDeviation; // CISP -3987
		public List<ConditionValues> conditionValues;
	}

	public class Borrower {
		public List<Deviations> Deviations;
	}
   
     public static IND_FicoDeviationResponse parse(String json) {
		return (IND_FicoDeviationResponse) System.JSON.deserialize(json, IND_FicoDeviationResponse.class);
	}
}