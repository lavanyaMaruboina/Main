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
            LIMIT 50
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
        try {
            insert contact;
            return contact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     @AuraEnabled
    public static void updateContact(Contact contact) {
        update contact;
    }

}