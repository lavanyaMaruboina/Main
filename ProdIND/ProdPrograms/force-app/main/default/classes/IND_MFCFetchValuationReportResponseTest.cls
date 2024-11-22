@isTest
public class IND_MFCFetchValuationReportResponseTest {

    @isTest
    public static void verifyIND_MFCFetchValuationReportResponse(){
        IND_MFCFetchValuationReportResponse.Response objResp = new IND_MFCFetchValuationReportResponse.Response();
        
        IND_MFCFetchValuationReportResponse.Content objContent = new IND_MFCFetchValuationReportResponse.Content();
        System.assertEquals(objContent.LeadId, null);
        System.assertEquals(objContent.VehicleRegNo, null);
        System.assertEquals(objContent.ReportGenerated, null);
        System.assertEquals(objContent.ReportURL, null);
        System.assertEquals(objContent.Valuation_Price, null);
        
        
        objResp.content = new List<IND_MFCFetchValuationReportResponse.Content>{objContent};
            objResp.respDesc = 'test';
        objResp.status = 'test';
        
        IND_MFCFetchValuationReportResponse result = new IND_MFCFetchValuationReportResponse();
        result.response = objResp;
        System.assert(result.response.status == 'test');
    }
}