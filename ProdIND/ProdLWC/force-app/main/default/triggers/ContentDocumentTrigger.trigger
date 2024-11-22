trigger ContentDocumentTrigger on ContentDocument (before delete,before update,before insert) {
    if(trigger.isBefore && trigger.isDelete){
        ContentDocumentTriggerHandler.handleBeforeDelete(trigger.old);
    }
    if(trigger.isBefore && trigger.isUpdate){
        ContentDocumentTriggerHandler.handleBeforeUpdate(trigger.new);
    }
}