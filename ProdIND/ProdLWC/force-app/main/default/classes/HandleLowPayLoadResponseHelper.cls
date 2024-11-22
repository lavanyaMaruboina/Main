/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems
Description:   This class is for Low_Payload_Response__e subscriber trigger event helper.
Inputs:        None 
Test Class:    IntegrationEngineTest 
History
Date            Author              Comments
-------------------------------------------------------------
1-10-2021      Santhosh Mothe       Created
------------------------------------------------------------*/
public class HandleLowPayLoadResponseHelper extends TriggerHandler{

    //Global Variable for to be used for Casting the Sobject details
    List<Low_Payload_Response__e> newLowPayloadResponseList;
    List<Low_Payload_Response__e> oldLowPayloadResponseList;
    Map<Id,Low_Payload_Response__e> newLowPayloadResponseMap;
    Map<Id,Low_Payload_Response__e> oldLowPayloadResponseMap;
    
    /*
* @Method:      HandleLowPayLoadResponseHelper
* @Created by:  Santhosh Mothe
* @Description: Constructor to initiate global variables
*/
    public HandleLowPayLoadResponseHelper(){
        newLowPayloadResponseList = (List<Low_Payload_Response__e>)Trigger.new;
        oldLowPayloadResponseList = (List<Low_Payload_Response__e>)Trigger.old;
        newLowPayloadResponseMap = (MAP<Id,Low_Payload_Response__e>)Trigger.newMap;
        oldLowPayloadResponseMap = (MAP<Id,Low_Payload_Response__e>)Trigger.oldMap;
    }
    /*
* @Method:      HandleLowPayLoadResponseHelper
* @Created by:  Santhosh Mothe
* @Description: afterInsert to after trigger execution
*/
    public override void afterInsert() {
        system.debug('*****************HandleLowPayLoadResponseHelper************************');
        List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
        //Map<String, String> refIdRespMap= new Map<String, String>();
        Integer  counter = 0;
        AsyncPayloadReponse[] AsyncPayloadReponses = new AsyncPayloadReponse[]{};
        
        for(Low_Payload_Response__e evt: newLowPayloadResponseList){
            counter++;
            if (counter >=  200) { 
                break;
            }
            else{
                //refIdRespMap.put(evt.Reference_Id__c, evt.Response__c);
               AsyncPayloadReponse asyncPayload = new AsyncPayloadReponse(evt.Reference_Id__c, evt.Response__c, evt.Response_Ext__c);
            
               AsyncPayloadReponses.add(asyncPayload);
            }
            
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(evt.ReplayId);
        }
        //system.debug('HandleLowPayLoadResponseHelper************afterInsert******refIdRespMap************ '+refIdRespMap);
        IntegrationUtilities.handleLowPayloadResponse(AsyncPayloadReponses);
        System.debug('LowPayloadResponse_For_EnachTest'+ newLowPayloadResponseList);
        ENACHController.eNachEventHandler(newLowPayloadResponseList);
        ENACHController.criffEventHandler(newLowPayloadResponseList); //SFTRAC-410
        HandleOlaFicoResponseEvent.olaFicoResponseEventHandler(newLowPayloadResponseList);//OLA-7
    }
}