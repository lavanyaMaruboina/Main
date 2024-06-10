public class AccountController {
   @AuraEnabled
    public static List<Account> searchAccounts(String searchTerm) {
        if (String.isBlank(searchTerm)) {
            return new List<Account>();
        }
        String formattedSearchTerm = searchTerm + '%';
        return [SELECT Industry,Id,Phone,Name FROM Account 
                WHERE Name LIKE :formattedSearchTerm LIMIT 10];
    }
}