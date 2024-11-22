public with sharing class IND_PricingEngineResponseDSA extends ParentAPIResponse{

	public Application application {get;set;}

	public class ApplicationDecision {
		public String prescribedRate {get;set;}
	}
 
	public class Application {
		public ApplicationDecision applicationDecision {get;set;}
	}
}