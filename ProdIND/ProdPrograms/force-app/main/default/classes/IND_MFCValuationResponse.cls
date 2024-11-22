/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the MFC Valuation Response 
Test Class:    IND_MFCValuationService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
27-10-2021      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_MFCValuationResponse extends ParentAPIResponse{
    public Response response; 
    
    public class Response{
        public String status;
        public String respDesc;
        public Content[] content;
    }
    public class Content{
        public final String Requestid;
        public final String Applicationno;
        public final String Registrationno;
        public final String Msg;
        public final String Lead_Id;
        public final String Vehicle_Id;
        public final String Maker_Date;
    }
}