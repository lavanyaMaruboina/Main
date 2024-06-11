public class sendEmailFortask {

@InvocableMethod
public static void sendEmailToTaskCreator(List<Task> newTasks) {
        // Collect unique user Ids who created the tasks
        Set<Id> creatorIds = new Set<Id>();
        for(Task t : newTasks) {
            creatorIds.add(t.CreatedById);
        }

        // Query user emails
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :creatorIds]);

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        // Create and add emails to the list
        for(Task t : newTasks) {
            User creator = userMap.get(t.CreatedById);
            if(creator != null && creator.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{creator.Email});
                email.setSubject('Reminder: Tomorrow Task');
                
                 String emailBody = 'Dear EKA Care Team,\n\n' +
                               'We would like to bring to your attention that there are tasks in our system that have aged beyond the recommended timeframe,\n' +   
                               'Please check in the below links are Related to Tomorrow Tasks\n\n';

            // Add information from each record to the email body
            
                // Add information from each record to the email body
                
                emailBody += 'Subject: ' + t.Subject + '\n';
                emailBody += 'Related to: ' + t.What.name + '\n';
                emailBody += 'Status: ' + t.Status + '\n';
                emailBody += 'Due Date: ' + t.ActivityDate + '\n';

                // Add a link to the record
                String recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + t.Id;
                emailBody += 'Record Link: ' + recordLink + '\n\n';
                           

                
                email.setPlainTextBody(emailBody);
                emailsToSend.add(email);
            }
        }

        // Send the emails
        if(!emailsToSend.isEmpty()) {
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailsToSend);
            for(Messaging.SendEmailResult result : sendResults) {
                if(!result.isSuccess()) {
                    // Handle errors if needed
                    System.debug('Email sending failed: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }
}