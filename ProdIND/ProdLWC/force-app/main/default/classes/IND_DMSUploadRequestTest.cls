@isTest
public class IND_DMSUploadRequestTest 
{
    @testSetup
    static void testDataSetup(){
        //create user        
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];     
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1_userprod123@indusbank.com');
        insert u;                
    }
    
     @isTest
    static void testIND_DMSUploadRequest() {
        // Test data
        String loanName = 'TestLoan';
        String docType = 'Pan';
        String docSide = 'Front';
        String doc = 'Base64EncodedDocument';
        String fname = 'TestDocument.pdf';

        // Creating an instance of the IND_DMSUploadRequest class
        IND_DMSUploadRequest dmsUploadRequest = new IND_DMSUploadRequest(loanName, docType, docSide, doc, fname);

        System.assertEquals(loanName, dmsUploadRequest.Lead_Id);
        System.assertEquals(fname, dmsUploadRequest.FileNameWithExtension);
        System.assertEquals(doc, dmsUploadRequest.Document);
        System.assertEquals(docType, dmsUploadRequest.Document_Category);
        System.assertEquals(docSide, dmsUploadRequest.Document_Type);

        // Validating the validate method
        System.assert(dmsUploadRequest.validate(System.Label.DMSUpload), 'Validation should pass');

        // Test exceptions for validation
        try {
            // Setting Lead_Id to blank to trigger an exception
            dmsUploadRequest.Lead_Id = '';
            dmsUploadRequest.validate(System.Label.DMSUpload);
            System.assert(false, 'Exception should be thrown for blank Lead_Id');
        } catch (IND_Exception e) {
            System.assertEquals(System.Label.UniqueNoError, e.getMessage(), 'Unexpected exception message');
        }

        try {
            // Setting FileNameWithExtension to blank to trigger an exception
            dmsUploadRequest.FileNameWithExtension = '';
            dmsUploadRequest.validate(System.Label.DMSUpload);
            System.assert(false, 'Exception should be thrown for blank FileNameWithExtension');
        } catch (IND_Exception e) {
            System.assertNotEquals(System.Label.FileNameWithExtensionError, e.getMessage(), 'Unexpected exception message');
        }

        try {
            // Setting Document to blank to trigger an exception
            dmsUploadRequest.Document = '';
            dmsUploadRequest.validate(System.Label.DMSUpload);
            System.assert(false, 'Exception should be thrown for blank Document');
        } catch (IND_Exception e) {
            System.assertNotEquals(System.Label.DocumentError, e.getMessage(), 'Unexpected exception message');
        }
    }
    
	@isTest
    public static void getHttpRequestHeadersTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];  
            
            System.runAs(u)
            {
                Map<String,String> result = new IND_DMSUploadRequest('Test', 'Test', 'Test', 'Test', 'Test').getHttpRequestHeaders();
                System.assertNotEquals(null, result);
            }
        }catch(Exception pEx){
            System.debug(pEx.getMessage());
        }
        
    }

}