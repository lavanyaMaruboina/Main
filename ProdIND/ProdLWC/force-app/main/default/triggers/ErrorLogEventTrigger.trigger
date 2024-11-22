/**
* @author: Manish Baldota.
* @company: Persistent Systems
* @description: Trigger for Error Log platform event to create the record after event is published.
* Test Class: NA
* History:
* 08/12/2021  Added by Manish Baldota 
*/
trigger ErrorLogEventTrigger on ErrorLogEvent__e (after insert) 
{  
 	new ErrorLogEventTriggerHandler().run();
}