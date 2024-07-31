public without sharing class CalendarController {
    @AuraEnabled//(cacheable=true)
    public static List<Event> getEvents(String userId) {
        List<Event> eventList = new List<Event>();
        List<Id> eventIds = new List<Id>();
        try {
            String contactId = LanguageVedhaGenericClass.getContactId(userId);
            eventList = [SELECT Id,WhoId, Subject, StartDateTime, IsAllDayEvent, EndDateTime, Location
                            FROM Event
                            WHERE WhoId =:contactId
                            ORDER BY CreatedDate DESC
                        ];
            System.debug('eventList- ' + eventList);

            return eventList;
        } catch (Exception e) {
            System.debug('Error in getEvents method- ' + e.getMessage());
        }
        return eventList;
         
    }
    
    
    @AuraEnabled//(cacheable=true)
    public static List<Visit__c> getVisits(String userId) {
        List<Visit__c> VisitList = new List<Visit__c>();
        List<Id> VisitIds = new List<Id>();
        try {
            //String contactId = LanguageVedhaGenericClass.getContactId(userId);
            VisitList = [Select id, Type_Of_Visit_For_Dealer__c, Type_Of_Visit__c, Status__c, Name, Date__c, End_Date__c, Visit_Notes__c, Address__Street__s from Visit__c 
                         where CreatedById =: userId
                         ORDER BY CreatedDate DESC
                        ];
            System.debug('VisitList- ' + VisitList);

            return VisitList;
        } catch (Exception e) {
            System.debug('Error in getVisits method- ' + e.getMessage());
        }
        return VisitList;
         
    }
    
}