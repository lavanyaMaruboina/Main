/*------------------------------------------------------------
Author:        Swapnil Prajapati
Description:   This class is wrapper class for the LTV Engine API response for DSA
*/
public class IND_LTVEngineResponseDSA extends ParentAPIResponse { 
	public cls_application application;

	class cls_application {
		public cls_applicationDecision applicationDecision;
	}

	class cls_applicationDecision {
		public Double ltv;	//65 
	}
  
    
}