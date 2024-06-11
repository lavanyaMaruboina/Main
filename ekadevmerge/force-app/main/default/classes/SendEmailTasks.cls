public class SendEmailTasks {

    @InvocableMethod
    public static void sendToEmail() {
        // Calculate tomorrow's date
        Date tomorrowDate = Date.today().addDays(1);

        // Select opportunities that meet the criteria
        List<Task> recordsToSendEmail = [SELECT Id, Subject, Status, ActivityDate FROM Task 
                                         WHERE ActivityDate =:tomorrowDate];
		system.debug('recordsToSendEmail'+recordsToSendEmail);
        // Check if there are records to process
        if (!recordsToSendEmail.isEmpty()) {
            // Get the current user's ID
            String currentUserId = UserInfo.getUserId();

            // Use the same email template for each email
          //  String emailTemplateApiName = 'YOUR_TEMPLATE_API_NAME';

            // Build the email body with information from all records
            String emailBody = 'Dear EKA Care Team,\n\n' +
                               'We would like to bring to your attention that there are tasks in our system that have aged beyond the recommended timeframe,\n' +   
                               'Please check in the below links are Related to Tomorrow Tasks\n\n';

            // Add information from each record to the email body
            for (Task record : recordsToSendEmail) {
                // Add information from each record to the email body
                emailBody += 'Subject: ' + record.Subject + '\n';
                emailBody += 'Status: ' + record.Status + '\n';
                emailBody += 'Due Date: ' + record.ActivityDate + '\n';

                // Add a link to the record
                String recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.Id;
                emailBody += 'Record Link: ' + recordLink + '\n\n';
            }

            // Create a single email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Reminder: Tomorrow Tasks');
            email.setPlainTextBody(emailBody);

            // Set the recipient email addresses as a list
            //email.setToAddresses(new List<String>{'maruboinalavanya@gmail.com'});
            email.setToAddresses(new List<String>{UserInfo.getUserEmail()}); // Send the email to the logged-in user's email

            // Send the email
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}