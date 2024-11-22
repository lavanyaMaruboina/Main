/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is wrapper class for the Validate Recent Lead response 
Test Class:     IND_ValidateRecentLeadService_Test
History
Date            Author              Comments
-------------------------------------------------------------
18-11-2021      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_ValidateRecentLeadResponse extends ParentAPIResponse{
    
    public Response response{get;set;} 
    
    public class Response{
        public String status{get;set;}
        public String respDesc{get;set;}
        public Content[] content{get;set;}
    }
    public class Content{
        public final String PG_Application_No{get;set;}    
        public final String PG_cust_dedupe{get;set;}
        public final String BL_Code{get;set;} //CISP-6559
    }
}