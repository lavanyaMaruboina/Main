public class SaveOrderPDF_controller {
    public Order cusOrderVar { get; private set; }
    
    public SaveOrderPDF_controller(ApexPages.StandardController controller) {
        String pageId = ApexPages.currentPage().getParameters().get('Id');
        cusOrderVar = [SELECT Id, Name, EndDate, OrderNumber, TotalAmount, Type, BillingAddress, EffectiveDate, Status, 
                            Contact__r.Name,Contact__r.Email, Account.Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                            BillingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Order WHERE Id = :pageId LIMIT 1];
    }
    
    public PageReference attachAndSave() {
        try {
            PageReference pr = Page.OrderPDFGenerator;
            pr.getParameters().put('Id', cusOrderVar.Id);
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
                conVer.PathOnClient = cusOrderVar.OrderNumber + '.pdf';
                conVer.Title = cusOrderVar.OrderNumber;
                conVer.VersionData = pdfBlob;
                conVer.IsMajorVersion = true;
                insert conVer;
                
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;
                cDe.LinkedEntityId = cusOrderVar.Id;
                cDe.ShareType = 'I';
                insert cDe;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PDF has been saved.'));
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attaching and saving: ' + e.getMessage()));
        }
        
        return new PageReference('/'+cusOrderVar.Id);
    }
    
    public PageReference cancelGeneration(){
        return new PageReference('/'+cusOrderVar.Id);    
    }
    

}