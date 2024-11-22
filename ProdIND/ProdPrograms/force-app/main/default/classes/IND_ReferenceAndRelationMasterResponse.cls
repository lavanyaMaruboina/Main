public class IND_ReferenceAndRelationMasterResponse extends ParentAPIResponse{
    public Response response {get;set;}
    public class Response {
        public String status {get;set;}
        public String respDesc {get;set;}
        public List<Content> content {get;set;}
    }
    public class Content {
    }
    
}