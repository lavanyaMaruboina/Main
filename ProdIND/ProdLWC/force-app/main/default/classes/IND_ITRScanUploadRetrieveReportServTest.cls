@isTest
public class IND_ITRScanUploadRetrieveReportServTest {
    @isTest
    public static void testRes1(){
        Test.startTest();
             IND_ITRScanUploadRetrieveReportService.getITRScanUploadRetrieveReportRequest();
        Test.stopTest();
    }
    
    @isTest
    public static void testRes2(){
        Test.startTest();
             IND_ITRScanUploadRetrieveReportRequest rr1 = new IND_ITRScanUploadRetrieveReportRequest();
             Map<String,String> rr2 = rr1.getHttpRequestHeaders();
        Test.stopTest();
    }
}