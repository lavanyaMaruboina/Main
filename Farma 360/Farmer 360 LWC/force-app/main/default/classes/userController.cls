public without sharing class userController {
    @AuraEnabled(cacheable=true)
    public static User getUserDetails(Id userId) {
        return [SELECT Id, Name FROM User WHERE Id = :userId LIMIT 1];
    }

    @AuraEnabled
    public static void createEvent(EventWrapper eventWrapper) {

        system.debug('the datareceived is>>'+JSON.serializePretty(eventWrapper));

        string whoid;
        List<User> userObj = [SELECT Id, ContactId FROM User WHERE Id = :eventWrapper.whoId];

        If(userObj.size()>0 && userObj[0].ContactId != null){
           
            system.debug('user found>>'+userObj[0].ContactId);
            whoid = userObj[0].ContactId;
        }else{
            whoid = [SELECT Id FROM Contact LIMIT 1].Id;
            system.debug('who id is>>'+whoid);
        }

        Event eventRecord = new Event(
            Subject = eventWrapper.subject,
            Location = eventWrapper.location,
            StartDateTime = eventWrapper.startDateTime.addHours(5).addMinutes(30),
            EndDateTime = eventWrapper.endDateTime.addHours(5).addMinutes(30),
            WhoId = whoid
        );

        try {
            insert eventRecord;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating event: ' + e.getMessage());
        }
    }

    public class EventWrapper {
        @AuraEnabled public String whoId { get; set; }
        @AuraEnabled public String subject { get; set; }
        @AuraEnabled public String location { get; set; }
        @AuraEnabled public DateTime startDateTime { get; set; }
        @AuraEnabled public DateTime endDateTime { get; set; }

    }
}