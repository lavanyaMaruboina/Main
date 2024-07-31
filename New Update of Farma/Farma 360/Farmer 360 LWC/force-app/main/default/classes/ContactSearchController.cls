public class ContactSearchController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRecentlyCreatedContacts() {
        return [SELECT Id, Name, Phone, Email 
                FROM Contact 
                ORDER BY CreatedDate DESC 
                LIMIT 5];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        String query = '%' + searchTerm + '%';
        return [SELECT Id, Name, Phone, Email 
                FROM Contact 
                WHERE Name LIKE :query OR Email LIKE :query OR Phone LIKE :query
                ORDER BY CreatedDate DESC];
    }
}