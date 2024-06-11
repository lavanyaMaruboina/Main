global class QuotationExpireDate1 implements Database.Batchable<SObject> {
     
    global Database.QueryLocator start(Database.BatchableContext bContext) {
        String quoteQuery = 'SELECT Id, Name, ExpirationDate, Email, Lead_time__c, Description, ContactId, Contact.Name, Contact.Email FROM Quote WHERE ExpirationDate = TODAY AND ContactId != null AND Contact.Email != null';
        System.debug('Quote record==============='+quoteQuery);
        return Database.getQueryLocator(quoteQuery);
    }
    
    global void execute(Database.BatchableContext bContext, List<SObject> recordsToProcess) {
        if (!recordsToProcess.isEmpty()) {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            for (SObject quoRecord : recordsToProcess) {
                Quote quoteRecord = (Quote) quoRecord;
                String contactEmail = quoteRecord.Contact.Email;
                System.debug('contactEmail in Quote related obj '+contactEmail);
                
                if (contactEmail != null) {
                    Date expirationDate = quoteRecord.ExpirationDate;
                    System.debug('uoteRecord.ExpirationDate in Quote related obj '+quoteRecord.ExpirationDate);
                    String emailContent = 'Hi ' + quoteRecord.Contact.Name + ',<br/><br/>' +
                        'Thank you for your enquiry and we hope you are happy with your quotation. <br/>' +
                        'This is a quick reminder to let you know that your quotation will expire on ' + expirationDate.format() + '. <br/>' +
                        'If you would like to discuss your quotation in more detail or would like us to re-issue your quotation please get in touch with the team. <br/>' +
                        'You can call us at: 0116 2160650 or simply reply to this email and one of the team will be in touch to provide further assistance. <br/><br/>' +
                        'Yours sincerely, <br/>' +
                        'Blauberg UK Sales Team';
            
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setHtmlBody(emailContent);
                    email.setSubject('Reminder: Your Quotation is Expiring Soon');
                    email.setToAddresses(new List<String>{contactEmail});
                    
                    emailsToSend.add(email);
                }
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
        }
    }
    
    global void finish(Database.BatchableContext bContext) {
        System.debug('Batch Job Id is: ' + bContext.getJobId());
    }
}