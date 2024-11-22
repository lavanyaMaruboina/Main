/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the MFC Fetch Valuation Report response 
Test Class:     IND_MFCFetchValuationReportService_Test
History
Date            Author              Comments
-------------------------------------------------------------
04-01-2022      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_MFCFetchValuationReportResponse extends ParentAPIResponse{
    public class Response {
        public String status{get;set;}
        public String respDesc{get;set;}
        public List<Content> content{get;set;}
    }
    
    public Response response{get;set;}
    
    public class Content {
        public final String LeadId{get;set;}
        public final String VehicleRegNo{get;set;}
        public final String ReportGenerated{get;set;}
        public final String ReportURL{get;set;}
        public final String Valuation_Price{get;set;}
        public final String Overall_Remarks{get;set;}
    }
    
}