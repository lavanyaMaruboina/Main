global class QuotationExpireDate implements Database.Batchable<SObject>, Schedulable {
    
    // Invocable method to start the batch job
    @InvocableMethod(label='Start Quotation Expiry Batch')
    global static void startQuotationExpiryBatch() {
        QuotationExpireDate batchClass = new QuotationExpireDate();
        Database.executeBatch(batchClass);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bContext) {
        String quoteQuery = 'SELECT Id, Name, Expiry_Date__c, Email, Lead_time__c, Description, ContactId, Contact.Name, Contact.Email FROM Quote WHERE Expiry_Date__c = TODAY AND ContactId != null AND Contact.Email != null';
        
        return Database.getQueryLocator(quoteQuery);
    }
    
    global void execute(Database.BatchableContext bContext, List<SObject> recordsToProcess) {
        if (!recordsToProcess.isEmpty()) {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            for (SObject quoRecord : recordsToProcess) {
                Quote quoteRecord = (Quote) quoRecord;
                
                // Fetch related Contact's email address
                String contactEmail = quoteRecord.Contact.Email;
                System.debug('contactEmail in Quote related obj '+contactEmail);
                
                if (contactEmail != null) {
                    // Calculate expiration date
                    Date expirationDate = quoteRecord.Expiry_Date__c;
                    System.debug('uoteRecord.Expiry_Date__c in Quote related obj '+quoteRecord.Expiry_Date__c);
                    // Construct email content
                    String emailContent = 'Hi ' + quoteRecord.Contact.Name + ',<br/><br/>' +
                        'Thank you for your enquiry and we hope you are happy with your quotation. <br/>' +
                        'This is a quick reminder to let you know that your quotation will expire on ' + expirationDate.format() + '. <br/>' +
                        'If you would like to discuss your quotation in more detail or would like us to re-issue your quotation please get in touch with the team. <br/>' +
                        'You can call us at: 0116 2160650 or simply reply to this email and one of the team will be in touch to provide further assistance. <br/><br/>' +
                        'Yours sincerely, <br/>' +
                        'Blauberg UK Sales Team';
                    
                    // Create email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setHtmlBody(emailContent);
                    email.setSubject('Reminder: Your Quotation is Expiring Soon');
                    email.setToAddresses(new List<String>{contactEmail});
                    
                    emailsToSend.add(email);
                }
            }
            
            // Send emails
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
        }
    }
    
    global void finish(Database.BatchableContext bContext) {
        System.debug('Batch Job Id is: ' + bContext.getJobId());
    }
    
    // Implement the Schedulable interface method
    global void execute(SchedulableContext ctx) {
        // Instantiate the batch class
        QuotationExpireDate batchClass = new QuotationExpireDate();
        
        // Start the batch job
        Database.executeBatch(batchClass);
    }
}



/*
// Create an instance of the batch class
QuotationExpireDate batchInstance = new QuotationExpireDate();

// Start the batch job
Database.executeBatch(batchInstance);*/