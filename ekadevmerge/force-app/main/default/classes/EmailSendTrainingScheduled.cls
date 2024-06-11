public class EmailSendTrainingScheduled {
    @InvocableMethod
    public static void sendToEmail() {
        // Calculate the date 21 days ago
        //DateTime twentyOneDaysAgo = DateTime.now().addDays(-2=1);

        // Query Opportunities with Activity Status as 'Training Scheduled' and ageing_times__c greater than or equal to 5
        List<Opportunity> recordsToSendEmail = [
            SELECT Id, Name, Email__c, Activity_Status__c, LastModifiedById,ageing_times__c
            FROM Opportunity
            WHERE Activity_Status__c = 'Training Scheduled'
                  AND ageing_times__c = 5
        ];
    	system.debug(recordsToSendEmail);
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
            if (record.ageing_times__c == 5 && record.Activity_Status__c == 'Training Scheduled'){
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
            email.setSubject('Ageing of Leads for Activity status: Training Scheduled has not changed in the last 5 days');
            email.setPlainTextBody(emailBody);
            email.setToAddresses(new List<String>{currentUserId}); // Send the email to the logged-in user

            // Send the email
            List<Messaging.SendEmailResult> sendResults  = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}