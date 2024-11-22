/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the APD Pending API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_APDPendingResponse extends ParentAPIResponse {
   
   public Response response;
   public class UserRCPendings {
       public final String Name{get;set;}
		public final String Segment_Code{get;set;}
		public final String Deal_Count{get;set;}
		public final String Count_1_30{get;set;}
		public final String Count_31_60{get;set;}
		public final String Count_61_90{get;set;}
		public final String Count_Above_90{get;set;}
		public final String Total_Count{get;set;}
		public final String Doc_Type{get;set;}
	}

	public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	} 
	public class Content {
		public final User_APD_Pending User_APD_Pending{get;set;}
		public final Dealer_APD_Pending Dealer_APD_Pending{get;set;}
	} 
	public class DealerInsurancePending {
		public final String Name{get;set;}
		public final String Deposit_Avl{get;set;}
		public final String Count_1_30{get;set;}
		public final String SOH_1_30{get;set;}
		public final String Count_31_60{get;set;}
		public final String SOH_31_60{get;set;}
		public final String Count_61_90{get;set;}
		public final String SOH_61_90{get;set;}
		public final String Count_Above_90{get;set;}
		public final String SOH_Above_90{get;set;}
		public final String Total_Count{get;set;}
		public final String Doc_Type{get;set;}
	}

	public class User_APD_Pending {
		public final List<UserRCPendings> UserRCPendings{get;set;}
		public final List<UserInsurancePending> UserInsurancePending{get;set;}
	}

	public class Dealer_APD_Pending {
		public final List<DealerRCPending> DealerRCPending{get;set;}
		public final List<DealerInsurancePending> DealerInsurancePending{get;set;}
	}

	public class UserInsurancePending {
		public final String Name{get;set;}
		public final String Segment_Code{get;set;}
		public final String Deposit_Avl{get;set;}
		public final String Count_1_30{get;set;}
		public final String SOH_1_30{get;set;}
		public final String Count_31_60{get;set;}
		public final String SOH_31_60{get;set;}
		public final String Count_61_90{get;set;}
		public final String SOH_61_90{get;set;}
		public final String Count_Above_90{get;set;}
		public final String SOH_Above_90{get;set;}
		public final String Total_Count{get;set;}
		public final String Doc_Type{get;set;}
	}

	public class DealerRCPending {
		public final String Name{get;set;}
		public final String Deal_Count{get;set;}
		public final String Count_1_30{get;set;}
		public final String Count_31_60{get;set;}
		public final String Count_61_90{get;set;}
		public final String Count_Above_90{get;set;}
		public final String Total_Count{get;set;}
		public final String Doc_Type{get;set;}
	}
 
}