/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is use to provide the details to CMU customer dedupe lightning web component.
Test Class:    LWC_LOS_CMUCustomerDedupe_cntrltest
History
Date            Author              Comments
-------------------------------------------------------------
02-16-2021      Manish Baldota       Created
------------------------------------------------------------*/
public with sharing class LWC_LOS_CMUCustomerDedupe_cntrl {

    // @Method:      handleChangeOwnerProcess
    // @Created by:  Manish Baldota
    // @Description: Method to handle the business logic of CMU owner change.
    // @Param:       String : caseId  
    // @Return:  
    @AuraEnabled
    public static ApplicantWrapper getRecordDetails(String caseId) {
        try{
            if(caseId != null){
                ApplicantWrapper applicantWrapper = new ApplicantWrapper();
                Case returnCase = [SELECT Id,Loan_Application__c,Loan_Application__r.Product_Type__c FROM Case WHERE Id=: caseId 
                                    WITH SECURITY_ENFORCED Limit 1];
                applicantWrapper.caseRecord=returnCase;
                List<Applicant__c> finalApplicants = new List<Applicant__c>();
                List<Applicant__c> validatedApplicantList = new List<Applicant__c>();
                Map<String,String> applicantDedupeMap = new Map<String,String>();
                List<Applicant__c> applicantDetails = [SELECT Id,Applicant_Type__c,Name,Opportunity__c,(select Id,IND_isNewCustomer__c from Customer_Dedupe_Response__r) FROM Applicant__c WHERE Opportunity__c =: returnCase.Loan_Application__c AND In_Active_Applicant__c = false AND Opportunity__r.StageName != 'Journey Stop' AND isCodeValidateBySalesUser__c=false WITH SECURITY_ENFORCED];//CISP-3447 (For cmu user can check the dedupe response)// CISP-10782 (Added isCodeValidateBySalesUser__c)
                if(applicantDetails.size()>0){
                    for(Applicant__c app : applicantDetails){
                        if(app.Customer_Dedupe_Response__r.size() > 0 && app.Customer_Dedupe_Response__r[0].IND_isNewCustomer__c){
                           continue; 
                        }
                        finalApplicants.add(app);
                    }
                }
                applicantWrapper.applicantDetails=finalApplicants;
                List<Applicant__c> validatedApplicantDetails = [SELECT Id,Applicant_Type__c,Name,Opportunity__c,Customer_Code__c,isCodeValidateBySalesUser__c,(select Id,IND_isNewCustomer__c,Dedupe_Journey_Status_Reason__c FROM Customer_Dedupe_Response__r) FROM Applicant__c WHERE Opportunity__c =: returnCase.Loan_Application__c AND In_Active_Applicant__c = false AND Opportunity__r.StageName != 'Journey Stop' WITH SECURITY_ENFORCED];
                if(validatedApplicantDetails.size()>0){
                    for(Applicant__c app : validatedApplicantDetails){
                        if(app.Customer_Dedupe_Response__r.size() > 0 &&(app.Customer_Dedupe_Response__r[0].IND_isNewCustomer__c || app.isCodeValidateBySalesUser__c)){
                            validatedApplicantList.add(app);
                        }
                    }
                }
                
                if(validatedApplicantList.size()>0){
                    for(Applicant__c app : validatedApplicantList){
                        applicantDedupeMap.put(app.Applicant_Type__c,app.Customer_Dedupe_Response__r[0].Dedupe_Journey_Status_Reason__c);
                    }
                }
                applicantWrapper.applicantDedupeMap = applicantDedupeMap;
                applicantWrapper.validatedApplicantList=validatedApplicantList;
                return applicantWrapper;
            }else{
                throw new IND_Exception('Case is not available.');
            }
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWC_LOS_CMUCustomerDedupe_cntrl', 'handleChangeOwnerProcess', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    public class ApplicantWrapper{
        @AuraEnabled
        public Case caseRecord{get;set;}
        @AuraEnabled
        public List<Applicant__c> applicantDetails{get;set;}
        @AuraEnabled
        public List<Applicant__c> validatedApplicantList{get;set;}
        @AuraEnabled
        public Map<String,String> applicantDedupeMap{get;set;}
    }
    // @Method:      handleJourneyStop
    // @Created by:  Manish Baldota
    // @Description: Method to handle the business logic of CMU owner change.
    // @Param:       String : handleJourneyStop //Loan Application Id  
    // @Return:  
/*    @AuraEnabled    public static void handleJourneyStop(String applicationId,String caseId) {

        try{
            if(applicationId != null){
                Opportunity opp = new Opportunity(Id = applicationId);
                opp.StageName = 'Journey Stop';
                opp.Journey_Stop_Reason__c = System.label.CMUJourneyStopReason;
                if (Schema.sObjectType.Opportunity.isUpdateable()) {
                    UPDATE opp;
				}
            }
            if(caseId != null){
                Case caseToClose = new Case(Id = caseId);
                caseToClose.Status = 'Closed';
                if (Schema.sObjectType.Case.isUpdateable()) {
                    UPDATE caseToClose;
				}
            }
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWC_LOS_CMUCustomerDedupe_cntrl', 'handleChangeOwnerProcess', System.Label.Apex, e, applicationId);
            throw new IND_Exception(e.getMessage());
        }
    } */

    //CISP-4376 start
    @AuraEnabled
    public static List<Applicant__c> checkCustomerResponseAvailable(String oppId) {
        try{           
            List<Applicant__c> applicantDetails = [SELECT Id,isAllRowSelected__c,isCodeValidateBySalesUser__c,Applicant_Type__c,Opportunity__c,(select Id, response__c,Dedupe_Journey_Status_Reason__c from Customer_Dedupe_Response__r)  FROM Applicant__c WHERE Opportunity__c =: oppId AND In_Active_Applicant__c = false AND Opportunity__r.StageName != 'Journey Stop' WITH SECURITY_ENFORCED];//CISP-3447 (For cmu user can check the dedupe response)
            if(!applicantDetails.isEmpty()){
                return applicantDetails;
            }
            return null;
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWC_LOS_CMUCustomerDedupe_cntrl', 'handleChangeOwnerProcess', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }//CISP-4376

    @AuraEnabled
    public static Boolean checkCaseClosed(String caseId) {
        try{           
            Case returnCase = [SELECT Id,Loan_Application__c,status,Loan_Application__r.Is_Customer_Dedupe_Submit__c FROM Case WHERE Id=: caseId 
                                    WITH SECURITY_ENFORCED Limit 1];
            if(returnCase.Status == 'Closed' || returnCase.Loan_Application__r.Is_Customer_Dedupe_Submit__c == true){ //Disable submit button 
                return true;
            }  
            return false;
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWC_LOS_CMUCustomerDedupe_cntrl', 'handleChangeOwnerProcess', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }
}