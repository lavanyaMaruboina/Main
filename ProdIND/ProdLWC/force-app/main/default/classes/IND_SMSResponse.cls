/*------------------------------------------------------------
Author:        Sharad Kathane
Company:       Persistent Systems
Description:   This class is wrapper class for the SMS Getway response 
Test Class:    IND_SMSResponse_Test 
History
Date            Author              Comments
-------------------------------------------------------------
8-10-2021      Sharad Kathane      Created
------------------------------------------------------------*/
public class IND_SMSResponse extends ParentAPIResponse{
    
    public Response response {get;set;}
    
    public class Response{
        public String status {get;set;}
        public String respDesc {get;set;}
        public Content[] content {get;set;}
    }
    
    public class Content{
        public final String Transaction_Id {get;set;}     
    }
    
}