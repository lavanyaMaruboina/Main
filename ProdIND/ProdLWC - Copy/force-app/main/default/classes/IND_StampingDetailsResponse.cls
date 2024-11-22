/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the StampingDetails API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public with sharing class IND_StampingDetailsResponse extends ParentAPIResponse {
    
    public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public final String Status_Code{get;set;}
		public final String Status_Description{get;set;}
		public final Object Esign_Link{get;set;}
        public final List<Dt_Stamping_Agree_Master> Dt_Stamping_Agree_Master{get;set;}
		public final List<StampedForDDL> StampedForDDL{get;set;}
		public final List<StampedForDDL> StampTypeDDL{get;set;}
		public final List<StampTowardsDDL> StampTowardsDDL{get;set;}
	} 
    
	public class StampedForDDL {
		public final String Display;
		public final String Data;
		public final String Product;
		public final String Active_Flag;
	}

	public class StampTowardsDDL {
		public final String Text;
		public final String Value;
	}

	public class Dt_Stamping_Agree_Master {
		public final String Document_Type;
		public final String Document_Template_ID;
		public final String StampDuty_Amount;
		public final String NESL_ESigning_Applicable_Flag;
		public final String NESL_EStamp_Applicable_Flag;
		public final String NESL_ESigning_Manual_Override_Flag;
		public final String NESL_Digital_EStamp_Required_Flag;
		public final String SHCIL_EStamp_Flag;
		public final String Franking_Flag;
		public final String Adhesive_Flag;
		public final String Stamp_Paper_Flag;
		public final String Cess_OnStampdutyAmount;
	}
 

	    
}