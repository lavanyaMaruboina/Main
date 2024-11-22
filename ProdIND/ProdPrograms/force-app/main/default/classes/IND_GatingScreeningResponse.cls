/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the Gating Screening-Check Eligibility response
Test Class:	IND_GatingScreeningServiceTest
History
Date            Author              Comments
------------------------------------------------------------- 
11-11-2021    Aman Mundhada            Created
------------------------------------------------------------*/

public class IND_GatingScreeningResponse extends ParentAPIResponse {
	public String gatingScreeningOutcome;
	public String finalDecision;
	public string finalDisplayReason;//CISP-113/CISP-2425
}