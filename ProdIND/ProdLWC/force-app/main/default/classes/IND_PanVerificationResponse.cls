/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the PAN Verification response
Test Class: IND_PANVerficationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
20-10-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_PanVerificationResponse extends ParentAPIResponse {
    
    public Response response{get;set;}
    
    public class Response{
        public String status{get;set;}
        public String respDesc{get;set;}
        public Content[] content{get;set;}
    }
    
    public class Content{
        public final String NSDLPANStatusDesc{get;set;}
        public final String NSDLReturnCdDesc{get;set;}
        public final String NSDLPANStatus{get;set;}
        public final String Name{get;set;}
        public final String ID{get;set;}
        public final Integer IDNSDLNameMatch{get;set;}
        public final Integer NSDLReturnCd {get;set;}
        public final string NSDLAadhaarSeedingStatus{get;set;}
    }
}