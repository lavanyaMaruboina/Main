@isTest
public class IND_UidaiOTPRequestTest {

    
    @isTest
    public static void verifyIND_UidaiOTPRequest(){
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L00100011';
        reqWrapper.otp = '6890001';
        reqWrapper.aadhaarNo = '232398989898';
        reqWrapper.txn = 'TXN001';
        reqWrapper.rnn = 'RNN0001';
        reqWrapper.subCategory = 'TestSubCategory';
        
        
      /*  IND_UidaiOTPRequest result = new  IND_UidaiOTPRequest(reqWrapper);
        Boolean isValid = result.validate(System.Label.UIDAIOTPVERIFY);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
        
        String resp = result.xmlConvertedRequest();
        System.assert(resp != null); */
    } 
}