@isTest
private class Ind_EnquiryControllerTest {

    @isTest
    static void testGetEnquiryDetails() {
        Enquiry__c testEnquiry = new Enquiry__c(
            Customer_Name__c = 'Test Customer',
            Journey_Type__c = 'Offline – BE assisted journey',
            Lead_Reference_ID__c = '1234',
            CIF_ID__c = 'Test CIF',
            Customer_code__c = 'Test Customer Code',
            Campaign_Type__c = 'Test Campaign',
            Deal_No__c = 'Test Deal No',
            Email__c = 'test@example.com',
            Enquiry_Status__c = 'Not Interested',
            Loan_amount__c = 10000,
            Mobile_Number_1__c = '9898877687',
            Mobile_Number_2__c = '0987654321',
            PAN_no__c = 'ABCDE1234F',
            Product__c = 'PV',  
            Product_category__c = 'New',
            Reason__c = 'Not Interested',
            Referred_to_Branch__c = 'Test Branch',
            Remarks__c = 'Test Remarks',
            Source__c = 'Test Source'
        );
        insert testEnquiry;

        Test.startTest();
        try {
            Enquiry__c result = Ind_EnquiryController.getEnquiryDetails(testEnquiry.Id);
            System.assertNotEquals(null, result);
        } catch (Exception e) {
            System.assert(false, 'Exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
    }

    @isTest
    static void testSaveEnquiryDetails() {
        Enquiry__c testEnquiry = new Enquiry__c(
            Customer_Name__c = 'Test Customer',
            Journey_Type__c = 'Offline – BE assisted journey',
            Lead_Reference_ID__c = '1234',
            Product_category__c = 'New',
            Enquiry_Status__c = 'Not Interested',
            Loan_amount__c = 10000
        );
        insert testEnquiry;

        testEnquiry.Customer_Name__c = 'Updated Test Customer';

        Test.startTest();
        try {
            Ind_EnquiryController.saveEnquiryDetails(testEnquiry);
            Enquiry__c updatedEnquiry = [SELECT Customer_Name__c FROM Enquiry__c WHERE Id = :testEnquiry.Id];
            System.assertEquals('Updated Test Customer', updatedEnquiry.Customer_Name__c);
        } catch (Exception e) {
            System.assert(false, 'Exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
    }

}