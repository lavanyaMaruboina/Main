public class KfsReverstatusController {
        @InvocableMethod(label = 'KFS Reverse Status API')
  public static void doSynergyReverseStatusCallout(List<FlowInputs> loanAppId){
 
          List<Key_Fact_Statement__c> keyfactList = [SELECT id,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Received_Time__c FROM Key_Fact_Statement__c WHERE id=:loanAppId[0].keyfactId WITH SECURITY_ENFORCED limit 1];
     
    if((keyfactList.size()>0) && (keyfactList[0].Keyfact_Consent_Not_Accepted__c == true || keyfactList[0].Keyfact_Consent_Need_Clarification__c == true || keyfactList[0].Keyfact_Consent_Accepted__c == true ) && keyfactList[0].Keyfact_Consent_Received_Time__c != null){
      
            System.enqueueJob(new IND_ReverseStatusCalloutKFSQueueable(loanAppId[0].keyfactId,loanAppId[0].status));
       
   		 }
}

public class FlowInputs{

    @InvocableVariable
    public String LoanId;
    
    @InvocableVariable
    public String status; 
    
    @InvocableVariable
    public String keyfactId;

    // @InvocableVariable
    // public String DealNo;
   }

}