@isTest
public class IND_PanVerificationRequestTest {
    
    @isTest
    public static void verifyIND_PanVerificationRequest(){
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        
        IND_PanVerificationRequest result = new IND_PanVerificationRequest(reqWrapper);
        Boolean isValid = result.validate(System.Label.PANVerificationAPI);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    }
    
}