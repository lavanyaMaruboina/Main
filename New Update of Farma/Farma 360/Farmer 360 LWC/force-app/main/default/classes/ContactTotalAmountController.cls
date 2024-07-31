public class ContactTotalAmountController {
    public static void updateContactAmount(Set<Id> contactIds) {

        Map<Id, Decimal> contactAmountMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [SELECT Contact__c, SUM(TotalAmount) totalAmount
                                   FROM Order
                                   WHERE Contact__c IN :contactIds AND Status = 'Accepted'
                                   GROUP BY Contact__c
                                  ]) {
            contactAmountMap.put((Id) ar.get('Contact__c'), (Decimal) ar.get('totalAmount'));
        }

        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : contactIds) {
            Decimal totalAmount = contactAmountMap.get(contactId);
            Contact contact = new Contact(
                Id = contactId,
                Total_Amount__c = totalAmount != null ? totalAmount : 0
            );
            contactsToUpdate.add(contact);
        }
        
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}