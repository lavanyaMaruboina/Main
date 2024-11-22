trigger HandleLowPayLoadResponse on Low_Payload_Response__e (after insert) {
    
    
    TriggerSwitch__c triggerCustomSettingElement = TriggerSwitch__c.getInstance('HandleLowPayLoadResponse');  
    if(triggerCustomSettingElement != null && triggerCustomSettingElement.Active__c){
        new HandleLowPayLoadResponseHelper().run();
    }
    /*                                  
    system.debug('*****************HandleLowPayLoadResponse************************');
    List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
    Map<String, String> refIdRespMap= new Map<String, String>();
    Integer  counter = 0;
    
    for(Low_Payload_Response__e  evt: trigger.new){
        
        counter++;
        System.debug('Counter = '+ counter);    
        if (counter >=  200) { 
            break;
        }
        else{
            System.debug('Received event Reference_Id__c=' + evt.Reference_Id__c);
            refIdRespMap.put(evt.Reference_Id__c, evt.Response__c);
            system.debug('Replay id is ---'+evt.ReplayId);
        }
        
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(evt.ReplayId);
        
    }
    
    IntegrationUtilities.handlePayloadResponse(refIdRespMap);*/
    
}