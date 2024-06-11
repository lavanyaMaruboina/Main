global class RejectedEmailSendToAdmin implements Database.Batchable<SObject> {
    // private Integer rejectedRecordsCount = 0;
    public list<Opportunity> lastopp;
    global Database.QueryLocator Start(Database.BatchableContext bContext) {
        String opportunitiesQuery = 'SELECT Id, Name, Activity_Status__c, Phone__c,Onboarded_Date_Time__c,Calling_Time__c, Reason1__c FROM Opportunity WHERE Activity_Status__c = \'On-Hold\' OR Activity_Status__c = \'Rejected\'';
         System.debug('=================='+opportunitiesQuery);
        return Database.getQueryLocator(opportunitiesQuery);
    }

    global void Execute(Database.BatchableContext bContext, List<Opportunity> recordsToProcess) {
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        system.debug('====================ooooo'+recordsToProcess);
        for (Opportunity oppRecord : recordsToProcess) {
            //Opportunity opportunityRecord = (Opportunity)oppRecord;

            if (oppRecord.Activity_Status__c == 'On-Hold' || oppRecord.Activity_Status__c == 'Rejected') {
                // rejectedRecordsCount++;
                opportunityToUpdate.add(oppRecord);
                
            }
        }

        if (!opportunityToUpdate.isEmpty()) {
            this.lastopp=opportunityToUpdate;
            system.debug('====================lavanya40268============'+lastopp);
            system.debug('====================lavanya26810============'+opportunityToUpdate);
            update lastopp;    
            
        }
    }

    global void Finish(Database.BatchableContext bContext) {
        System.debug('Batch Job Id is.....lavanya: ' + bContext.getJobId());

        // Query the Batch Job Details...
        AsyncApexJob jobDetails = [SELECT Id, Status, TotalJobItems, JobItemsProcessed, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bContext.getJobId()];

        // Write the Code to send the Email to the Users..
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        String[] toAddress = new String[]{jobDetails.CreatedBy.Email, 'maruboinalavanya@gmail.com'};
        email.setToAddresses(toAddress);

        email.setReplyTo('maruboinalavanya1998@gmail.com');
        email.setSenderDisplayName('Activity Status of Rejected/On-hold onboardings');

        String emailSubject = 'Activity Status of Notification Alert Rejected/On-hold onboardings (' + jobDetails.Id + ')';
        email.setSubject(emailSubject);

        // Records for Rejected / On-Hold
        List<String> recordDetails = new List<String>();

        for (Opportunity opportunityRecord : lastopp) {
            String details = 'Opportunity Name: ' + opportunityRecord.Name +
                '<br/>Activity Status: ' + opportunityRecord.Activity_Status__c +
                '<br/>Phone Number: ' + opportunityRecord.Phone__c +
                '<br/>Date of Onboarding: ' + opportunityRecord.Onboarded_Date_Time__c +
                '<br/>Number of Calls: ' + opportunityRecord.Calling_Time__c +
                '<br/>Reason for being on hold / rejection: ' + opportunityRecord.Reason1__c +
                '<br/>--------------------------<br/>';
            system.debug('=============lavanya========='+details);
            recordDetails.add(details);
        }

        String emailContent = 'Dear Eka Care Team, <br/><br/>' +
            'We have processed the below Weekly Customer Details Update Batch Job. <br/><br/>' +
            'We are pleased to inform you that we have processed the Batch Job - UpdateOpportunityRecordsBatch successfully. <br/><br/>' +
            'Here are the Batch Job Details and information about processed records: <br/><br/>' +
            'Batch Job Id is......: ' + jobDetails.Id +
            // '<br/>Number of Rejected Records Processed......: ' + rejectedRecordsCount +
            '<br/><br/>Processed Records Details:<br/><br/>' + String.join(recordDetails, '') +
            '<br/><br/> Please Contact Eka Care Team if you have any queries.' +
            '<br/><br> ***<i>This is a System Generated Email. Please Do Not Reply.</i>' +
            '<br/><br/>Thanks & Regards, <br/>Eka Care Team.';
        email.setHtmlBody(emailContent);

        // Send the Email...
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}
//RejectedEmailSendToAdmin opportunityBatch = new RejectedEmailSendToAdmin();
//Database.executeBatch(opportunityBatch, 2);