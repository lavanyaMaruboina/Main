trigger RequestIDOnboardingFor on Opportunity (after insert,after update) {
    if((Trigger.isAfter) && ((Trigger.isInsert) || (Trigger.isUpdate)))
    {

    List<Id> opportunityIdsToUpdate = new List<Id>();
    for (Opportunity opp : Trigger.new) {
        if ((opp.RecordType.DeveloperName == 'EMR') || (opp.RecordType.DeveloperName == 'HXNG')) {
            
            opportunityIdsToUpdate.add(opp.Id);
        }
    }
    if (!opportunityIdsToUpdate.isEmpty()) {
        List<Request_For_ID__c> requestForIdList = [SELECT Id, Onboarded_For__c FROM Request_For_ID__c WHERE Onboarded_For__c IN :opportunityIdsToUpdate];

        // Update the Onboarding field for each Request for ID record
        for (Request_For_ID__c requestForId : requestForIdList) {
            // Perform any logic you need here to update the Onboarding field
            requestForId.Onboarded_For__c = 'YourNewValue';
        }

        // Update the Request for ID records
        update requestForIdList;
    }
}

    }