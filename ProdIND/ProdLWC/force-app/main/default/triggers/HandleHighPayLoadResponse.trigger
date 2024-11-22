trigger HandleHighPayLoadResponse on High_Payload_Response__e (after Insert) {
    
    system.debug('*****************HandleHighPayLoadResponse************************');
    List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
    //Map<String, String> refIdRespMap= new Map<String, String>();
    Integer  counter = 0;
    AsyncPayloadReponse[] AsyncPayloadReponses = new AsyncPayloadReponse[]{};
    
    
    for(High_Payload_Response__e  evt: trigger.new){
        
        counter++;
        System.debug('Counter = '+ counter);    
        if (counter >=  200) { 
            break;
        }
        else{
            System.debug('Received event Reference_Id__c=' + evt.Reference_Id__c);
            AsyncPayloadReponse asyncPayload = new AsyncPayloadReponse(evt.Reference_Id__c, evt.Response__c, evt.Response_Ext__c);
            
            AsyncPayloadReponses.add(asyncPayload);
            //refIdRespMap.put(evt.Reference_Id__c, evt.Response__c);
            system.debug('Replay id is ---'+evt.ReplayId);
        }
        
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(evt.ReplayId);
        
    }
    
    IntegrationUtilities.highPayloadResponse(AsyncPayloadReponses);
   
}