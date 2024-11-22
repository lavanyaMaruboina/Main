public with sharing class IND_LWC_LienMarkingModalController {
public static Boolean isTestRun = false;
    @AuraEnabled
    public static List<Exposure__c> getExposures(Id loanApplicationId){
        try {
            List<Exposure__c> listToReturn = [SELECT Id, Deal_No__c, Deal_Date__c, Product_Variant_Name__c, Finance_Amt__c FROM Exposure__c WHERE Loan_Application__c = :loanApplicationId]; 
            if (isTestRun) {
                throw new testException();
            }
            return listToReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    class testException extends Exception {}
}