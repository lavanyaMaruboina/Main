trigger generateUniqueLeadNumber on Opportunity (after insert, after update) {
    UniqueLeadNumberHandler.generateLeadNumber(trigger.newmap);
}