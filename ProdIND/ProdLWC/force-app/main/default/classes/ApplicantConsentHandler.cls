public class ApplicantConsentHandler {
    public static void updateConsentReceived(List<Applicant__c> newApplicants, List<Applicant__c> oldApplicants) {
        List<Applicant__c> applicantsToUpdate = new List<Applicant__c>();

        for (Integer i = 0; i < newApplicants.size(); i++) {
            Applicant__c newApplicant = newApplicants[i];
            Applicant__c oldApplicant = oldApplicants[i];

            if ((newApplicant.Consent_Sent__c != null && oldApplicant.Consent_Sent__c == null) || (newApplicant.Consent_Sent__c != oldApplicant.Consent_Sent__c)) {
                Applicant__c updatedApplicant = new Applicant__c(Id = newApplicant.Id);
                updatedApplicant.Consent_Received__c = true; // Update the flag
                applicantsToUpdate.add(updatedApplicant);
            }
            if ((newApplicant.Application_Form_SMS_Sent__c != null && oldApplicant.Application_Form_SMS_Sent__c == null) || (newApplicant.Application_Form_SMS_Sent__c != oldApplicant.Application_Form_SMS_Sent__c)) {
                Applicant__c applicationConsent = new Applicant__c(Id = newApplicant.Id);
                applicationConsent.Application_Consent_Received__c = true; 
                applicationConsent.Application_Consent_SMS_Sent_Time__c = DateTime.now();
                applicantsToUpdate.add(applicationConsent);
            }
            if ((newApplicant.Insurance_Consent_OTP_Time__c != null && oldApplicant.Insurance_Consent_OTP_Time__c == null) || (newApplicant.Insurance_Consent_OTP_Time__c  != oldApplicant.Insurance_Consent_OTP_Time__c) ) {
                Applicant__c applicationConsentInsurance = new Applicant__c(Id = newApplicant.Id);
                applicationConsentInsurance.Insurance_Consent_Received__c = true; 
                applicationConsentInsurance.Insurance_consent_sent_on__c = DateTime.now();
                applicantsToUpdate.add(applicationConsentInsurance);
            }
            
        }

        if (!applicantsToUpdate.isEmpty()) {
            update applicantsToUpdate;
        }
    }
}