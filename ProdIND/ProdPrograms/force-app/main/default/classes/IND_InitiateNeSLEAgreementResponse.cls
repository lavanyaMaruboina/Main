/*------------------------------------------------------------
    Author:        Yugandhar
    Company:       Persistent Systems
    Description:   This class is wrapper class for the Initiate NeSL EAgreementResponse API response 
    Test Class:     
    History
    Date            Author              Comments
    -------------------------------------------------------------
    12-31-2021      Yugandhar      Created
    ------------------------------------------------------------*/
    public class IND_InitiateNeSLEAgreementResponse  extends ParentAPIResponse {    
        
        public ResponseData response {get;set;}
        
        public class ResponseData {
            public String status {get;set;}
            public String respDesc {get;set;}
            public Content[] content {get;set;}
        }
        
        public class Content {
            public String ResURL {get;set;}
            public String res {get;set;}
            public String Status_Code {get;set;}
            public String Status_Description {get;set;}
            public String Esign_Link {get;set;}
        }
        
    }