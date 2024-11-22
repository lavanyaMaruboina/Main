/*------------------------------------------------------------
Author: Swapnil Prajapati
Description: This class is wrapper class for the Gating Screening-Check Eligibility response for DSA
*/

public class IND_GatingScreeningResponseDSA extends ParentAPIResponse {
    public Application application { get; set; } 

    public class ApplicationDecision {
        public String gatingScreeningOutcome { get; set; }
 
    }  
    public class Application {
        public ApplicationDecision applicationDecision { get; set; }
    }
}