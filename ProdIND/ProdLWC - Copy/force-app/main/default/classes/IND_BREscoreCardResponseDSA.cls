public class IND_BREscoreCardResponseDSA extends ParentAPIResponse{
     
    public Application application {get;set;} 
    
    public class ApplicationDecision {
        public String riskBand {get;set;}  
    }
    public class Application {
        public ApplicationDecision applicationDecision {get;set;}   
    }
    
}