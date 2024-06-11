public class EmailSendTrainingCompleted {
    @InvocableMethod
    public static void sendToEmail() {
        List<Opportunity> recordsToSendEmail = [
            SELECT Id, Name, Email__c, Activity_Status__c, LastModifiedById, ageing_times__c
            FROM Opportunity
            WHERE Activity_Status__c = 'Training Completed'
                  AND ageing_times__c = 7
        ];

        // Check if there are any records to process
        if (!recordsToSendEmail.isEmpty()) {
            // Email body template
            String emailBody = 'Dear EKA Care Team,\n\n' +
                'We would like to bring to your attention that there are leads in our system that have aged beyond the recommended timeframe,\n' +
                'and unfortunately, no action has been taken on them. Taking action on these leads will not only contribute to our overall \n' +
                'success but also enhance our responsiveness and customer satisfaction. We kindly request RM & all team members \n' +
                'to review and work on these aged leads at the earliest convenience.\n\n' +
                'Thank you for your prompt attention to this matter.\n\n';

            // Add information from each record to the email body
            for (Opportunity record : recordsToSendEmail) {
                // Check conditions for each record
                if (record.ageing_times__c == 7 && record.Activity_Status__c == 'Training Completed') {
                    emailBody += 'Doctor Name: ' + record.Name + '\n';
                    emailBody += 'Activity Status: ' + record.Activity_Status__c + '\n';

                    // Add a link to the record
                    String recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.Id;
                    emailBody += 'Record Link: ' + recordLink + '\n\n';
                }
            }

            // Get the current user's ID
            String currentUserId = UserInfo.getUserId();

            // Create a single email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Ageing of Leads for Activity status: Training Completed has not changed in the last 7 days');
            email.setPlainTextBody(emailBody);
            email.setToAddresses(new List<String>{currentUserId}); // Send the email to the logged-in user

            // Send the email
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}