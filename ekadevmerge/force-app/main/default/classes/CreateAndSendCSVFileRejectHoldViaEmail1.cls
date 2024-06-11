public class CreateAndSendCSVFileRejectHoldViaEmail1 {
    @InvocableMethod   
    public static void createAndSendCSVFile() {
        List<Opportunity> oppList = [SELECT Id, Name, Activity_Status__c, Onboarded_Date_Time__c, Calling_Time__c, Reason1__c, Phone__c, OwnerId, Owner.Name 
                                     FROM Opportunity WHERE Activity_Status__c ='On-Hold' OR Activity_Status__c = 'Rejected'];

        // Fetching all admin emails dynamically
        List<User> adminList = [SELECT Id, Email FROM User WHERE Profile.Name = 'Admin' AND IsActive = true];
        Set<String> adminEmails = new Set<String>();
        for (User admin : adminList) {
            adminEmails.add(admin.Email);
        }

        Set<Id> processedOpportunityIds = new Set<Id>();
        // Separating field values using a comma and storing in a list of strings ('oppDetails')
        List<String> oppDetails = new List<String>();
        if (oppList != null && !oppList.isEmpty()) {
            for (Opportunity oppObj : oppList) {
                // Check for duplicate Opportunity IDs
                if (!processedOpportunityIds.contains(oppObj.Id)) {
                    User ownerWithRole = [SELECT Id, Name, UserRole.Name FROM User WHERE Id = :oppObj.OwnerId LIMIT 1];
                    String ownerRole = (ownerWithRole.UserRole != null) ? ownerWithRole.UserRole.Name : '';

                    oppDetails.add(oppObj.Id + ',' + oppObj.Name + ',' + oppObj.Phone__c + ',' + oppObj.Onboarded_Date_Time__c + ','
                            + oppObj.Owner.Name + ',' + ownerRole + ',' + oppObj.Activity_Status__c + ',' + oppObj.Calling_Time__c + ',' + oppObj.Reason1__c);

                    processedOpportunityIds.add(oppObj.Id); // Add the Opportunity ID to the set
                }
            }
        }
       
        // Creating CSV file
        String csvFile;
        String csvColumnHeader = 'Opportunity ID, Opportunity Name,Phone,Onboarding Date/Time,Owner Name,Owner Role,Activity Status,Calling Time,Reason\n';
        
        if (!oppDetails.isEmpty()) {
            csvFile = csvColumnHeader + String.join(oppDetails, '\n');

            // Get the currently logged-in user's email
            String loggedInUserEmail = UserInfo.getUserEmail();

            // Adding additional recipients (cc) - in this case, Admins
            List<String> ccRecipients = new List<String>();
            ccRecipients.addAll(adminEmails);

            // Sending email and attaching the CSV file
            List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{loggedInUserEmail});
            mail.setCcAddresses(ccRecipients);
            mail.setSubject('List of Pending Onboardings is Reject/ON-Hold');
            String body = 'Dear Team, <br/><br/>' +
                          'Onboarding is pending for the following opportunities because of the reasons mentioned. <br/><br/>' +
                          'We kindly request <Manager name> & all team members to review and work on these aged leads at the earliest convenience.<br/><br/>'+
                          'Please find the attached File.<br/><br/>'+
                          'Thank you for your prompt attention to this matter. <br/><br/>';
            mail.setHtmlBody(body);
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('text/csv');
            attach.setFileName('Opportunity Reject/ON Hold File.csv');
            attach.setInline(true);
            attach.Body = Blob.valueOf(csvFile);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); // Set File Attachment
            
            mailsList.add(mail);
            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(mailsList);
        }
    }
}