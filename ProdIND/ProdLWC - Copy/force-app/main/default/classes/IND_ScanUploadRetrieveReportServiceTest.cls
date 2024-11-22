@isTest
public class IND_ScanUploadRetrieveReportServiceTest {
     @isTest
    public static void testOne1(){
        Test.startTest();
            IND_ScanUploadRetrieveReportService.getScanUploadRetrieveReportRequest();
        Test.stopTest();
    }
    
    @isTest
    public static void testOne2(){
        Test.startTest();
             IND_ScanUploadRetrieveReportRequest sr1 = new IND_ScanUploadRetrieveReportRequest();
             Map<String,String> sr2 = sr1.getHttpRequestHeaders();
        Test.stopTest();
    }
}