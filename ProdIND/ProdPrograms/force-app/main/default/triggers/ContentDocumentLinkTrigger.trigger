/*------------------------------------------------------------
Author:        Sushil B
Company:       Manureva Solutions
Description:   Trigger on ContentDocumentLink object.
Inputs:        None 
Test Classes:  ContentDocumentLinkTriggerHandlerTest
History
Date            Author              Comments
-------------------------------------------------------------
28-06-2022      Sushil B            Created
------------------------------------------------------------*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            ContentDocumentLinkTriggerHandler.handleBeforeInsert(trigger.new);
        }
    }

    if(trigger.isAfter){
        if(trigger.isInsert){
            ContentDocumentLinkTriggerHandler.handleAfterInsert(trigger.new);
            
            //Deactivating old document if we have old document with same document type fo applicant
           ContentDocumentLinkTriggerHandler.deactivateDuplicateDocument(trigger.new);
        }
    }
}