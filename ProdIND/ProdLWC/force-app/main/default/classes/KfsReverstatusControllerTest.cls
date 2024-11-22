@IsTest
public class KfsReverstatusControllerTest {
  @isTest
    static void doReverseStatusCallout_Test(){
    try{
         Key_Fact_Statement__c kfs = new Key_Fact_Statement__c ();
            kfs.Keyfact_Consent_Not_Accepted__c = true;
            kfs.Keyfact_Consent_Need_Clarification__c = false;
            kfs.Keyfact_Consent_Accepted__c= false;
            kfs.Keyfact_Consent_Received_Time__c = system.now();
                insert kfs;
    Key_Fact_Statement__c opp = [SELECT id,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Received_Time__c FROM Key_Fact_Statement__c Limit 1];            
    List<KfsReverstatusController.FlowInputs> fIptList = new List<KfsReverstatusController.FlowInputs>(); 
    KfsReverstatusController.FlowInputs fIpts = new KfsReverstatusController.FlowInputs(); 
        fIpts.keyfactId = opp.id;
        fIpts.status = 'Accept';
        fIptList.add(fIpts);
        Test.startTest();
        KfsReverstatusController.doSynergyReverseStatusCallout(fIptList);
        Test.stopTest();            
    }  
        catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
        }
                             }
    
}