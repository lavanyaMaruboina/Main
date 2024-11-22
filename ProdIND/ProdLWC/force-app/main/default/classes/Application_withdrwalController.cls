public with sharing class Application_withdrwalController {
    @AuraEnabled
    public static Boolean getApplication(String oppId, String reason){
        try {
            Opportunity Opp=[SELECT ID,Withdrawal_Reason__c,Applicant__c,DSA_Sub_Stage__c,LeadSource
                                FROM Opportunity WHERE Id=:oppId];//CISP-12695

            List<Applicant__c> app=[SELECT ID,Application_Consent_OTP__c, Insurance_Consent_OTP__c 
                                FROM Applicant__c WHERE Opportunity__c=:oppId];
            List<Case> amlCases = [SELECT Id, Status FROM Case WHERE Loan_Application__c = :oppId AND RecordType.DeveloperName = 'AML_Check'];  //CISP-7506                  

            opp.Withdrawal_Reason__c=reason;
            opp.StageName='Withdrawn';
            if(opp.LeadSource == 'DSA'){
                opp.DSA_Sub_Stage__c ='Withdrawn';//CISP-12695
                }
            upsert opp;


            if(app!= null){
                for(Applicant__c apps : app){
                    apps.Application_Consent_OTP__c= System.Label.Insurance_Conset_OTP;
                    apps.Insurance_Consent_OTP__c= System.Label.Insurance_Conset_OTP;
                }
                
                update app;

                for (Case record : amlCases) { //CISP-7506
                    record.Status = 'Closed';
                }

                update amlCases;//CISP-7506
            }          
            updateCaseStatus(oppId);
            return true;    
        }catch(DmlException e) {
           System.debug('An unexpected error has occurred: ' + e.getMessage());
           return false;
        }
    }
    public static void updateCaseStatus(string loanApllicationId){
        if(string.IsNotBlank(loanApllicationId)){
            Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            List<Case> cases = [SELECT Id,Status,IsClosed FROM Case WHERE Loan_Application__c = :loanApllicationId AND RecordTypeId = :amlRecordTypeId WITH SECURITY_ENFORCED];
            if(!cases.isEmpty()){
                List<Case> updatedCases = new List<Case>();
                for(Case cs:cases ){
                    if(!cs.IsClosed){
                        Case cas = new Case();
                        cas.Id = cs.Id;
                        cas.Status = 'Closed';
                        updatedCases.add(cas);
                    }
                }
                if(!updatedCases.isEmpty()){
                    Update updatedCases;
                }
            }
        }
    }
}