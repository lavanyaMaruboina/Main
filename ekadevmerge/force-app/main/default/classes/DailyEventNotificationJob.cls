public class DailyEventNotificationJob implements Schedulable {
    public void execute(SchedulableContext ctx) {
  /*      // Define the date and time for 12:00 PM today
        Datetime notificationDateTime = Datetime.newInstance(
            Date.today(),
            Time.newInstance(10, 2, 0, 0)
        );

        // Find events scheduled for today
        List<Event> todayEvents = [SELECT Id, OwnerId, Subject, StartDateTime FROM Event
                                   WHERE ActivityDate = TODAY];

        // Iterate through today's events
        for (Event evt : todayEvents) {
            // Check if the event is scheduled for or after 12:00 PM
            if (evt.StartDateTime >= notificationDateTime) {
                // Send a custom notification for the event
                sendCustomNotification(evt);
            }
        }
    }

    // Example method to send a custom notification
    public void sendCustomNotification(Event event) {
        // Replace this with your custom notification logic
        // For example, sending an email
  /*      String recipientEmail = event.OwnerId; // Assuming the event has an owner with an email
        String subject = 'Event Notification: ' + event.Subject;
        String message = 'This is a custom notification message for the event: ' + event.Subject;   
        
        // Create an email message
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] { recipientEmail });
    mail.setSubject(subject);
    mail.setPlainTextBody(message);

    // Send the email
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
         User owner = [SELECT Email FROM User WHERE Id = :event.OwnerId ];
    if (owner != null && owner.Email != null) {
        // Send the custom notification to the owner's email
        String recipientEmail = 'luckysurya347@gmail.com';
        String subject = 'Event Notification: ' + event.Subject;
        String message = 'This is a custom notification message for the event: ' + event.Subject;

        // Create an email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { recipientEmail });
        mail.setSubject(subject);
        mail.setPlainTextBody(message);

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } else {
        // Handle the case where the owner's email is not found or is null
    }*/ 
    } 
}