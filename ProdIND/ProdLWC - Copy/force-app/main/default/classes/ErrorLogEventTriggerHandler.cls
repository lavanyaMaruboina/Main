/**
* @author: Manish Baldota.
* @company: Persistent Systems
* @description: This handler is being used with ErrorLogEventTrigger to create the Error Log record from Platform Event.
* Test Class: NA
* History:
* 08/12/2021  Added by Manish Baldota 
*/
public with sharing class ErrorLogEventTriggerHandler extends TriggerHandler{
    //Global Variable for to be used for Casting the Sobject details
    List<ErrorLogEvent__e> newList;
    List<ErrorLogEvent__e> oldList;
    Map<Id,ErrorLogEvent__e> newMap;
    Map<Id,ErrorLogEvent__e> oldMap;
    /**
    * @author: Manish Baldota
    * @company: Persistent System
    * @description: This contructor is being used to assign the Trigger context variable to manupulate those later.
    * Inputs: ''
    * Returns: 
    * History:
    * 12/08/2021 Manish Baldota Initial Developement 
    */
    public ErrorLogEventTriggerHandler(){
        newList = (List<ErrorLogEvent__e>)Trigger.new;
        oldList = (List<ErrorLogEvent__e>)Trigger.old;
        newMap = (MAP<Id,ErrorLogEvent__e>)Trigger.newMap;
        oldMap = (MAP<Id,ErrorLogEvent__e>)Trigger.oldMap;
    }   
    /**
    * @author: Manish Baldota
    * @company: Persistent System
    * @description: This method is being used to handle the after insert event of trigger.
    * Inputs: ''
    * Returns: 
    * History:
    * 12/08/2021 Manish Baldota Initial Developement 
    */
    public override void afterInsert() {
    	List<Error_Log__c> logList = new List<Error_Log__c>(); 
        for(ErrorLogEvent__e event : newList){
            logList.add(ErrorLoggerUtil.createErrorLogRecord(event));
        }
        if(!logList.isEmpty() && logList != null && logList.size()>0 && Schema.sObjectType.ErrorLogEvent__e.isCreateable()){
            Database.insert(logList,false);
        }
    }
}