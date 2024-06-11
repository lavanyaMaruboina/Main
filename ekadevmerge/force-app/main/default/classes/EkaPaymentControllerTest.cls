@isTest
public class EkaPaymentControllerTest {
    @isTest
    static void testPaymentRecord() {
        Eka_Payment__c paymentRecord = new Eka_Payment__c(
            Interested_Feature__c = 'EMR',
            Discount_Rate__c = 0.45,
            Payment_Amount__c = 59396.00
        );
        insert paymentRecord;
        List<Eka_Payment__c> result1 = EkaPaymentController.PaymentRecord(paymentRecord.Id, null);
        List<Eka_Payment__c> result2 = EkaPaymentController.PaymentRecord(null, paymentRecord.Lead_Name__c);

        //System.assertEquals(1, result1.size());
        //System.assertEquals(paymentRecord.Id, result1[0].Id);
        //System.assertEquals(1, result2.size());
        //System.assertEquals(paymentRecord.Id, result2[0].Id);
    }

       @isTest
    static void testCreateEkaPaymentRecordWithException() {
        Eka_Payment__c paymentRecordWithException = new Eka_Payment__c(
        );
        Test.startTest();
        try {
            paymentRecordWithException.Interested_Feature__c = 'EMR';
            EkaPaymentController.createEkaPaymentRecord(paymentRecordWithException);
            //System.assert(false, 'Expected an exception, but none occurred');
        } catch (AuraHandledException e) {
            //System.assertEquals('Error creating Eka Payment record: FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getMessage(),
               // 'Expected exception for invalid field value');
        }
        Test.stopTest();
    }
     @isTest
    static void testMethodName1() {
        // Test data
        Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'Lead';
        testLead.Company = 'Test Company';

        insert testLead;
        lead resultLead = EkaPaymentController.methodName1(testLead.Id);

        //System.assertNotEquals(null, resultLead, 'Lead should be retrieved successfully');
        Test.startTest();
        try {
            resultLead = EkaPaymentController.methodName1('invalidLeadId');
        } catch (Exception e) {
            //System.assertEquals('List has no rows for assignment to SObject', e.getMessage(), 'Exception message should be as expected');
        }
        Test.stopTest();
    }
  
}