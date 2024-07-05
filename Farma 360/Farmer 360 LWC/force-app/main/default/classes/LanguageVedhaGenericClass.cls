public class LanguageVedhaGenericClass {
    public static String getContactId(String userId){
        String contactId;
        try{
            User userWithContact = [SELECT Id, Name, IsActive, ContactId FROM User Where Id =:userId AND IsActive = true];
            contactId = userWithContact.ContactId;
        }catch(Exception e){
            System.debug('Exception in getContactId method- ' + e.getMessage());
        }
        return contactId;
    }
}