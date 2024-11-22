public class IND_ExternalDedupeStatusAPIRequest extends ParentAPIRequest{
    public  String CIC_No = '';
    public IND_ExternalDedupeStatusAPIRequest(Customer_Dedupe_Response__c cdr, String loanAppId){
        this.CIC_No = cdr.CIC_No__c;
        validate(System.Label.DedupeStatus);
    }   

    public override boolean validate(String serviceName){
        if(String.isBlank(this.CIC_No)){
          throw new IND_Exception(System.Label.CICNo);
        }
        return true;
    }

    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
        //requestheadermap is used to fetch the request from client
    }
}