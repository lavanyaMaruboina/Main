trigger ContactAmountTrigger on Order (after insert, after update, after delete, after undelete) {
    Set<Id> contactIds = new Set<Id>();
    
    for (Order o : Trigger.isDelete ? Trigger.old : Trigger.new) {
        if (o.Contact__c != null) {
            contactIds.add(o.Contact__c);
        }
    }
    
    if (!contactIds.isEmpty()) {
        ContactTotalAmountController.updateContactAmount(contactIds);
    }
}