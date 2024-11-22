/*
* @Name         IND_LWC_CreditAssessmentCntrl
* @Author       
* @Company      Persistent Systems
* @Description  This class contains all methods related to Credit Assessment.
* Inputs:       None
* Test Class:   IND_LWC_CreditAssessmentCntrlTest
*/

public with sharing class IND_LWC_CreditAssessmentCntrl {
    /*
    * @Method:      getUserRemarks
    * @Created by:  
    * @Description: This method will return the applicant record containing the remark feild value.
    * @Param:       String -  Applicantion ID
    * @Param:       String - Applicant Type
    * @Return:      object of applicant record.
    */
    @AuraEnabled
    public static Applicant__c getUserRemarks(String applicantId, String loanApplicationId){
        try{
            List<Applicant__c> saveSearchList = new List<Applicant__c>();
            saveSearchList = [SELECT Remarks__c,Opportunity__r.Product_Type__c,Opportunity__r.Borrower_Category__c,Opportunity__r.Loan_Categorization__c,Opportunity__r.Acre_Category__c,Opportunity__r.PSL_Sub_Type__c,Opportunity__r.Non_PSL_Categorization__c,Opportunity__r.Customer_Type__c,Opportunity__r.Recommendation_for_the_Loan__c FROM Applicant__c WHERE Id =: applicantId And 
                              Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false 
                              WITH SECURITY_ENFORCED limit 1];
            if(!saveSearchList.isEmpty()){
                if(Test.isRunningTest()){
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return saveSearchList.get(0);
            }else{
                return null;
            }
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('IND_LWC_CreditAssessmentCntrl' ,'getUserRemarks', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
    * @Method:      saveUserRemarks
    * @Created by:  
    * @Description: This method will save the remark feild value on applicant object.
    * @Param:       String -  Applicantion ID
    * @Param:       String - Applicant Type
    * @Param:       String - remarks that user want to save
    * @Return:      None
    */
    @AuraEnabled
    public static String saveUserRemarks(String applicantId, String loanApplicationId, String remarks){
        String appId=null;
        try{
            Applicant__c applicant = [SELECT Remarks__c FROM Applicant__c WHERE Id =: applicantId And 	Opportunity__c =: loanApplicationId And In_Active_Applicant__c = false WITH SECURITY_ENFORCED limit 1];
            if(applicant != null){            
                applicant.Remarks__c = remarks;
                if(Schema.sObjectType.Applicant__c.isUpdateable()){
                    update applicant;
                    appId= applicant.Id;
                }
            }
        }catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('IND_LWC_CreditAssessmentCntrl' ,'saveUserRemarks', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return appId;
    }
}