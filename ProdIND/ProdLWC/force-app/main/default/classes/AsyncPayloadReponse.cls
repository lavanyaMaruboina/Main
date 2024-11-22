public class AsyncPayloadReponse {

    public String responseExt{get;set;}
    public String encryptResponseExt{get;set;}
    public String response{get;set;}
    public String encryptResponse{get;set;}
    public String referenceId{get;set;}
    
    public AsyncPayloadReponse(String refId, String resp, String respExt){
        this.responseExt = respExt;
        this.response = resp;
        this.referenceId = refId;
    }
}