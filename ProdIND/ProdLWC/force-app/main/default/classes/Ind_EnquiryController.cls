public with sharing class Ind_EnquiryController {
     /*
    * @Method:      getEnquiryDetails
    * @Created by:  Raghav
    * @Description: This method will return the details of Enquiry Record.
    * @Param:       String - current Record ID
    * @Return:      wrapper object containing all the details.
    */
    @AuraEnabled(cacheable=true)
    public static Enquiry__c getEnquiryDetails(String enquiryId){
        try {
            return [SELECT Customer_Name__c,Name,Journey_Type__c,Converted_to_Lead__c,Lead_Reference_ID__c,CIF_ID__c,Customer_code__c,Campaign_Type__c,Deal_No__c,Email__c,Enquiry_Status__c,Loan_amount__c,Mobile_Number_1__c,Mobile_Number_2__c,PAN_no__c,Product__c,Product_category__c,Reason__c,Referred_to_Branch__c,Remarks__c,Source__c,Bl_Code__c
                    FROM Enquiry__c WHERE Id = :enquiryId];
        } catch(Exception e) {
            throw new AuraHandledException('Error fetching Enquiry details: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveEnquiryDetails(Enquiry__c enquiryData) {
        try {
            update enquiryData;
        } catch(Exception e) {
            throw new AuraHandledException('Error saving Enquiry details: ' + e.getMessage());
        }
    }
}