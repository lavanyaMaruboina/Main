public without sharing class VehicleDetailsController {

    /**********************************************
    * @Commented By:  surendhar vb
    * @UserStory:  Feature 24.10.24 - Income detail screen
    * @Purpose: This method is used to fetch Purpose of Purchase for Vehicle_Detail__c to disable FOIR button in the LWC.
    ***********************************************/
    @TestVisible
    private static Boolean simulateTestException = false;
    
    @AuraEnabled(cacheable=true)
    public static String getPurposeOfPurchase(Id opportunityId) {
        try {
            // Simulated exception for test coverage
            if (simulateTestException) {
                throw new AuraHandledException('Simulated exception for test coverage');
            }
			system.debug('inside VehicleDetailsController');
            // Querying the Vehicle_Detail__c record based on Opportunity (Loan Application)
            Vehicle_Detail__c vehicleDetail = [
                SELECT Purpose_of_Purchase__c 
                FROM Vehicle_Detail__c 
                WHERE Loan_Application__c = :opportunityId
                LIMIT 1
            ];

            return vehicleDetail.Purpose_of_Purchase__c;

        } catch (Exception e) {
            // Error handling and logging with Opportunity ID
            ErrorLoggerUtil.logErrorEvent('VehicleDetailsController', 'getPurposeOfPurchase', e.getTypeName(), e, opportunityId);
            return null;
        }
    }
}