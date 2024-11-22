/*------------------------------------------------------------
Author:        Chowdesha N
Company:       Persistent Systems
Description:   This class is wrapper class for the CSRVahanFIwaiver API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Chowdesha N     Created
------------------------------------------------------------*/
public class Ind_CSRVahanFIwaiverResponse extends ParentAPIResponse {

    
    public FiBorrower fiBorrower;
	public FiCoBorrower fiCoBorrower;

	public class FiBorrower {
		public String Off_Addresss_Fi;
		public String Curr_Resi_Addresss_Fi;
		public String Perm_Resi_Addresss_Fi;
	}
    
    public class FiCoBorrower {
		public String Off_Addresss_Fi;
		public String Curr_Resi_Addresss_Fi;
		public String Perm_Resi_Addresss_Fi;
	}
    
    
}