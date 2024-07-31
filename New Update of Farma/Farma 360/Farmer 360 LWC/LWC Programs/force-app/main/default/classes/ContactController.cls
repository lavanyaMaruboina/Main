// ContactController.cls
public with sharing class ContactController {
    @AuraEnabled
    public static List<Contact> getContacts(String searchKey) {
        String searchPattern = '%' + searchKey + '%';
        return [
            SELECT Id, Name, Email, Phone
            FROM Contact
            WHERE Name LIKE :searchPattern
            OR Email LIKE :searchPattern
            OR Phone LIKE :searchPattern
            LIMIT 5
        ];
    }
      @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        String query = '%' + searchTerm + '%';
        return [SELECT Id, Name, Phone, Email 
                FROM Contact 
                WHERE Name LIKE :query OR Email LIKE :query OR Phone LIKE :query
                ORDER BY CreatedDate DESC];
    }
    
   
     @AuraEnabled
    public static Contact createContact(Contact contact) {
        system.debug('contact==============='+contact);
        try {
             system.debug('contactIn==============='+contact);
            insert contact;
            return contact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getFarmerTypePicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Type_of_Farmer__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }

    // @AuraEnabled(cacheable=true)
    // public static List<String> getFarmerTypePicklistValues() {
    //     List<String> picklistValues = new List<String>();
    //     Schema.DescribeFieldResult fieldResult = Contact.Type_of_Farmer__c.getDescribe();
    //     for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
    //         picklistValues.add(entry.getLabel());
    //     }
    //     return picklistValues;
    // }

    // @AuraEnabled(cacheable=true)
    // public static List<String> getSubTypePicklistValues(String farmerType) {
    //     List<String> subTypeValues = new List<String>();
    //     Schema.DescribeFieldResult fieldResult = Contact.Sub_Type__c.getDescribe();
        
    //     // Get the index of the selected Farmer Type value
    //     Integer selectedTypeIndex = null;
    //     for (Schema.PicklistEntry entry : Contact.Type_of_Farmer__c.getDescribe().getPicklistValues()) {
    //         if (entry.getLabel() == farmerType) {
    //             selectedTypeIndex = Integer.valueOf(entry.getValue());
    //             break;
    //         }
    //     }
        
    //     if (selectedTypeIndex != null) {
    //         for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
    //             if (entry.getValidFor().contains(selectedTypeIndex)) {
    //                 subTypeValues.add(entry.getLabel());
    //             }
    //         }
    //     }
        
    //     return subTypeValues;
    // }

   @AuraEnabled
    public static void updateContacts(Id id, Map<String, Object> Accounts) {
        try {
           system.debug('Account to Id' +  id);
           system.debug('Account to update' +  Accounts);
            
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}