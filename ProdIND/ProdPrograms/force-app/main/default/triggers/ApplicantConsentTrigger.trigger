trigger ApplicantConsentTrigger on Applicant__c (after update) {
    // Check if the consent has been sent
    TriggerSwitch__c triggerCustomSettingElement = TriggerSwitch__c.getInstance('ApplicantConsentTrigger');  
    if(triggerCustomSettingElement != null && triggerCustomSettingElement.Active__c){
        ApplicantConsentHandler.updateConsentReceived(Trigger.new, Trigger.old);
    }
    // if (Trigger.isUpdate) {
    //     ApplicantConsentHandler.updateConsentReceived(Trigger.new, Trigger.old);
    // }
}