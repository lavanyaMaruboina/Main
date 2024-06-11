public without sharing class userController {
    @AuraEnabled(cacheable=true)
    public static User getUserDetails(Id userId) {
        return [SELECT Id, Name FROM User WHERE Id = :userId LIMIT 1];
    }
}