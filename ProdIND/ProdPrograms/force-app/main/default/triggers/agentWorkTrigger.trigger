trigger agentWorkTrigger on AgentWork (before insert, after insert, before update,after update, 
                                  before delete, after delete, after undelete) 
{  
    TriggerSwitch__c triggerCustomSettingElement = TriggerSwitch__c.getInstance('AgentWorkTrigger');  
    if(triggerCustomSettingElement != null && triggerCustomSettingElement.Active__c){
        new AgentWorkTriggerHandler().run();
    }
}