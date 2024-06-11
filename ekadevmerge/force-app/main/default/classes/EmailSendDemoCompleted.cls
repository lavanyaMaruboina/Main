public class EmailSendDemoCompleted {
    @InvocableMethod
    public static void sendToEmail() {
        // Select opportunities that meet the criteria
        List<Opportunity> recordsToSendEmail = [SELECT Id, Name, Email__c, Activity_Status__c, ageing_times__c
                                                FROM Opportunity
                                                WHERE Activity_Status__c = 'Demo Completed'
                                                AND ageing_times__c = 10];

        // Check if there are records to process
        if (!recordsToSendEmail.isEmpty()) {
            // Build the email body
            String emailBody = 'Dear EKA Care Team,\n\n' +
                               'We would like to bring to your attention that there are leads in our system that have aged beyond the recommended timeframe,\n' +
                               'and unfortunately, no action has been taken on them. Taking action on these leads will not only contribute to our overall \n' +
                               'success but also enhance our responsiveness and customer satisfaction. We kindly request RM & all team members \n' +
                               'to review and work on these aged leads at the earliest convenience.\n\n' +
                               'Thank you for your prompt attention to this matter.\n\n';

            // Add information from each record to the email body
            for (Opportunity record : recordsToSendEmail) {
                emailBody += 'Doctor Name: ' + record.Name + '\n';
                emailBody += 'Activity Status: ' + record.Activity_Status__c + '\n';

                // Add a link to the record
                String recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.Id;
                emailBody += 'Record Link: ' + recordLink + '\n\n';
            }

            // Get the current user's ID
            String currentUserId = UserInfo.getUserId();

            // Create a single email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Ageing of Leads for Activity status: Demo Completed has not changed in the last 10 days');
            email.setPlainTextBody(emailBody);
            email.setToAddresses(new List<String>{currentUserId}); // Send the email to the logged-in user

            // Send the email
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}