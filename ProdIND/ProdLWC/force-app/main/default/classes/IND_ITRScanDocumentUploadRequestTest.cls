@isTest
public class IND_ITRScanDocumentUploadRequestTest {
    
    
    @isTest
    public static void verifyIND_ITRScanDocumentUploadRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        Documents__c doc = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opgd1);
        doc.Document_Type__c = System.Label.Residence_Front_View;
        doc.Addresss_Type__c = System.Label.Document_Current_Residential_Address_Type;
        insert doc;
        
        // Create ContentVersion
        ContentVersion contVer1 = TestDataUtility.createContentVersionforOcrFront('Test document for content version', true, doc);
        
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId 
                             FROM ContentVersion WHERE Id = :contVer1.Id LIMIT 1];
        
        IND_ITRScanDocumentUploadRequest result = new IND_ITRScanDocumentUploadRequest(doc, cv.ContentDocumentId,  'perfiosTransactionId', opgd1.Id);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        result=IND_ITRScanDocumentUploadService.getITRScanDocumentUpload(doc, cv.ContentDocumentId, 'perfiosTransactionId', opgd1.Id);

// To cover catch        
        try{
            result=IND_ITRScanDocumentUploadService.getITRScanDocumentUpload(null, null, '', null);

        }
        catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
        }

        
    }
    
    
}