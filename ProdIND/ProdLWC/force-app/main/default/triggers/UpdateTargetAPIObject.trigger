trigger UpdateTargetAPIObject on Integration_Log__c (before insert, after insert, before update,after update, 
                                  before delete, after delete, after undelete) {
    
    TriggerSwitch__c triggerCustomSettingElement = TriggerSwitch__c.getInstance('UpdateTargetAPIObject');  
    if(triggerCustomSettingElement != null && triggerCustomSettingElement.Active__c){
        
        new UpdateTargetAPIObjectHelper().run();
    }
    
}