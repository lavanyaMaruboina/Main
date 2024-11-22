@isTest
public class IND_DocAuthDocumentReportResponseTest {
	@isTest
    public static void verifyIND_DocAuthDocumentReportResponse(){
        IND_DocAuthDocumentReportResponse res=new IND_DocAuthDocumentReportResponse();
        System.assertEquals(res.RequestId, null);
        System.assertEquals(res.ResponseData, null);
                IND_DocAuthDocumentReportResponse.ResponseData res1=new IND_DocAuthDocumentReportResponse.ResponseData();
         System.assertEquals(res1.Status, null);
        System.assertEquals(res1.ResponseInfo, null);
         System.assertEquals(res1.Fields, null);
    }
}