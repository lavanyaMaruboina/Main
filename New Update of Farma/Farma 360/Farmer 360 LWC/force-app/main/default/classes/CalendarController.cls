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
}