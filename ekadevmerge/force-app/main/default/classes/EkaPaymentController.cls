public class EkaPaymentController {
    @AuraEnabled(cacheable=true)
    public static List<Eka_Payment__c> PaymentRecord(String recordId, String leadName) {
        return [
            SELECT Id, Interested_Feature__c, Payment_Amount__c, Subscription_Plan__c, Discount_Rate__c,
                Number_Of_Years__c, Reviews__c, Remarks__c, Lead_Name__c
            FROM Eka_Payment__c
            WHERE Id = :recordId OR Lead_Name__c = :leadName
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Id createEkaPaymentRecord(Eka_Payment__c paymentRecord) {
        try {
            insert paymentRecord;
            return paymentRecord.Lead_Name__c;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Eka Payment record: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
     public static Lead methodName1(String leadId) {
         return [SELECT Id, RecordType.Name FROM Lead WHERE Id = :leadId LIMIT 1];
    }
}