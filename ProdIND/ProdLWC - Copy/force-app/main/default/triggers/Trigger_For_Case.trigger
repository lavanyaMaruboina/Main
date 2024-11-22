//Here we are created OpportunityTeamMember Added By nidhi dhote:
trigger Trigger_For_Case on Case (before insert, after insert, before update,after update, 
                                  before delete, after delete, after undelete) 
{  
    TriggerSwitch__c triggerCustomSettingElement = TriggerSwitch__c.getInstance('Trigger_For_Case');  
    if(triggerCustomSettingElement != null && triggerCustomSettingElement.Active__c){
        new CaseTriggerHandler().run();
    }
}