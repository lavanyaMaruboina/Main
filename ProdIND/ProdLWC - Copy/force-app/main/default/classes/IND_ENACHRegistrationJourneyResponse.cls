/*------------------------------------------------------------
Author: Bhushan Charde 
Company: Persistent Systems
Description: This class is wrapper class for the ENACH Registration Journey Response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
12-28-2021    Bhushan Charde            Created
------------------------------------------------------------*/
public class IND_ENACHRegistrationJourneyResponse extends ParentAPIResponse {
    
    public String Session_Id{get;set;}
        public String Resp_Code{get;set;}
        public string Resp_Message{get;set;}
        public string Registration_Url{get;set;}
}