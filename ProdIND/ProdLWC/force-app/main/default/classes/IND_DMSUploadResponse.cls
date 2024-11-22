/*------------------------------------------------------------
    Author:        Yugandhar
    Company:       Persistent Systems
    Description:   This class is wrapper class for the DMS Upload API response 
    Test Class:     
    History
    Date            Author              Comments
    -------------------------------------------------------------
    12-19-2021      Yugandhar      Created
    ------------------------------------------------------------*/
    public class IND_DMSUploadResponse  extends ParentAPIResponse {    
        
        public ResponseData response {get;set;}
        
        public class ResponseData {
            public String status {get;set;}
            public String respDesc {get;set;}
            public String[] content {get;set;}
        }
        
    }