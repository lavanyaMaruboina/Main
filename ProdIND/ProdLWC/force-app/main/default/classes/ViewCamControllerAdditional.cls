/**
* @Name         ViewCamControllerHelper
* @Author       Surendhar VB
* @Description  This class is created as helper class to support extended functionality of ViewCamController Class.
**/

public without sharing class ViewCamControllerAdditional {
    
    /**********************************************
* @Commented By:  surendhar vb
* @UserStory:  Feature 25.9.24 - CAM Screen
* @Purpose: This method is used to provide the viability details to iND_LWC_CAMViewViability cmp.
***********************************************/
    @TestVisible
    private static Boolean simulateTestException = false;
    
    @AuraEnabled
    public static List<Vehicle_Detail__c> getViabilityDetails(Id recordId, Id vehicleId) {
        try {
            if (simulateTestException) {
                throw new AuraHandledException('Simulated exception for test coverage');
            }
            return  [SELECT Distance__c, Gross_Receipts_Month__c, Number_of_vehicle_owned__c, Expense__c, Vehicle_Route__c, Route__c FROM Vehicle_Detail__c 
                     WHERE Loan_Application__c = :recordId AND Id = :vehicleId];
            
        } catch (Exception e) {         
  
            String loanApplicationId = null;
            if (vehicleId != null) { // Add a null check for vehicleId
                List<Vehicle_Detail__c> vehicleDetailsList = [SELECT Loan_Application__c FROM Vehicle_Detail__c WHERE Id = :vehicleId LIMIT 1];
                if (!vehicleDetailsList.isEmpty()) {
                    loanApplicationId = vehicleDetailsList[0].Loan_Application__c;
                }
            }
            ErrorLoggerUtil.logErrorEvent('ViewCamControllerAdditional', 'getViabilityDetails', e.getTypeName(), e, loanApplicationId);
            return new List<Vehicle_Detail__c>(); 
        }
        
        
    }
    
}