@isTest
public class ParentAPIRequestTest extends ParentAPIRequest{
    
    @isTest
    public static void verifyParentAPIRequest(){
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L00100011';
        reqWrapper.otp = '6890001';
        reqWrapper.aadhaarNo = '232398989898';
        reqWrapper.txn = 'TXN001';
        reqWrapper.rnn = 'RNN0001';
        reqWrapper.subCategory = 'TestSubCategory';
        
        
        ParentAPIRequestTest result = new  ParentAPIRequestTest();
        String jsonRes = result.convertToJSON();
        System.assert(jsonRes != null);
        
        jsonRes = result.convertToNullEscapeJson();
        System.assert(jsonRes != null);
        
        Boolean res = result.validate('test');
        System.assert(res);
        
        res = result.validate();
        System.assert(res);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String resp = result.xmlConvertedRequest();
        System.assert(resp != null);
    }
}