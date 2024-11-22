/*------------------------------------------------------------
Author:        Rajat Jaiswal
Description:   This class is wrapper class for the Productivity API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
24-03-2023     Rajat Jaiswal       Created
------------------------------------------------------------*/
public class IND_ProductivityResponse extends ParentAPIResponse {
   
    public Response response;
 
    public class Response {
        public String status{get;set;}
        public String respDesc{get;set;}
        public List<Content> content{get;set;}
    }

    public class Content {
        public final String Productivity{get;set;}
    }
 }