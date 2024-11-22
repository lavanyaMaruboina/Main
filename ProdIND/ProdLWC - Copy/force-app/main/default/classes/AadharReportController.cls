public without sharing class AadharReportController {
    public Documents__c adharDoc {get;set;}  
    public Id id;
    public  AadharReportController(ApexPages.StandardController controller){
        id =ApexPages.CurrentPage().getparameters().get('id');  
        adharDoc = [select id, Masked_KYC_No__c, KYC_name__c, KYC_DOB__c, Gender__c, KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_City__c, KYC_Pin_Code__c, KYC_State__c, Aadhar_Report_Image__c from Documents__c where id=:id order by createddate desc limit 1];    	System.debug('Log - Aadhar Details:: '+ adharDoc);
    	System.debug('Log - Aadhar Details:: '+ adharDoc);
    }
    @future(callout=true)
    public static void createAadharReportPdf(String documentId)
    {
        Blob fileDetails ;
        PageReference PDf =  Page.AadharReport;
        PDf.getParameters().put('Id',documentId);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();
        fileDetails = PDf.getContentAsPdf();
        Utilities.createContentDocumentFromApex(documentId,'Aadhar vKYC', fileDetails, 'pdf');
    }
}