public class SaveQuotePDF_controller {
    public Quote cusQtVar { get; private set; }
    
    public SaveQuotePDF_controller(ApexPages.StandardController controller) {
        String pageId = ApexPages.currentPage().getParameters().get('Id');
        cusQtVar = [SELECT Id, Name,Quote_Ref__c, Contact.Email, Email, ContactId, OwnerId FROM Quote WHERE Id = :pageId LIMIT 1];
    }
    
    public PageReference sendMailMethod() {
        try {
            PageReference pdf = Page.QuotePDFGenerator;
            pdf.getParameters().put('Id', cusQtVar.Id);
            pdf.setRedirect(true);
            
            Blob pdfBlob = null;
        
            if(Test.isRunningTest())
                {
                     pdfBlob = blob.valueOf('Unit.Test');
                }
                else
                {
                     pdfBlob = pdf.getContent();
                               
                }
             
            
            if (pdfBlob != null) {
                Attachment myAttach = new Attachment();
                myAttach.ParentId = cusQtVar.Id;
                myAttach.Name = cusQtVar.Quote_Ref__c + '.pdf';
                myAttach.Body = pdfBlob;
                
                insert myAttach;
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Personalized Quotation for Your Product Need');
                email.setPlainTextBody('Please find the Attached QuotationPDF.');
                email.setToAddresses(new String[] {cusQtVar.Contact.Email});
                
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(myAttach.Name);
                efa.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                Set<String> userset= new Set<String>();
                userset.add(cusQtVar.OwnerId);
                notifyUsers(userset,cusQtVar.Id);
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Quote PDF has been sent successfully'));

            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while sending email: ' + e.getMessage()));
        }
        
        return new PageReference('/'+cusQtVar.Id);
    }
    
    public PageReference attachAndSave() {
        try {
            PageReference pr = Page.QuotePDFGenerator;
            pr.getParameters().put('Id', cusQtVar.Id);
            Blob pdfBlob = null;
        
            if(Test.isRunningTest())
                {
                     pdfBlob = blob.valueOf('Unit.Test');
                }
                else
                {
                     pdfBlob = pr.getContentAsPdf();
                               
                }
            
            if (pdfBlob != null) {
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = cusQtVar.Quote_Ref__c + '.pdf';
                conVer.Title = cusQtVar.Quote_Ref__c;
                conVer.VersionData = pdfBlob;
                conVer.IsMajorVersion = true;
                insert conVer;
                
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;
                cDe.LinkedEntityId = cusQtVar.Id;
                cDe.ShareType = 'I';
                insert cDe;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PDF has been saved.'));
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attaching and saving: ' + e.getMessage()));
        }
        
        return new PageReference('/'+cusQtVar.Id);
    }
    
    public PageReference cancelGeneration(){
        return new PageReference('/'+cusQtVar.Id);    
    }
    
    public static void notifyUsers(Set<String> recipientsIds, String targetId) {
        
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Quote_is_sent' LIMIT 1];
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Quote Notification');
        notification.setBody('Quote PDF Details send through Email for this Customer');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}