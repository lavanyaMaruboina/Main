trigger HandleOlaBREResponse on Ola_BRE_Response_Payload__e (after insert) {
    TriggerSwitch__c triggerCustomSettingElement = TriggerSwitch__c.getInstance('HandleOlaBREResponse');  
    if(triggerCustomSettingElement != null && triggerCustomSettingElement.Active__c){
        new HandleOlaBREResponseHelper().run();
    }
}