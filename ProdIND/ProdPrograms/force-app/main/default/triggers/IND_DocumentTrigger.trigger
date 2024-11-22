/**
* @author: Raj Gupta.
* @company: Persistent Systems
* @description: this trigger is use to update two fields on Document object according to condition.
* Test Class: DocumentTriggerTest
* History:
* 28/10/2012  Added by Raj for Initial (IND-309). 
*/

//This trigger will update the value of Name Mismatch and Name Mismatch Percentage field on document Object : Raj Gupta
//jira :- IND-309
trigger IND_DocumentTrigger on Documents__c (before insert, after insert, before update,after update, 
                                  before delete, after delete, after undelete) 
{  
    
    TriggerSwitch__c triggerCustomSettingElement = TriggerSwitch__c.getInstance('IND_DocumentTrigger');  
    if(triggerCustomSettingElement != null && triggerCustomSettingElement.Active__c){
        new DocumentTriggerHandler().run();
}
}