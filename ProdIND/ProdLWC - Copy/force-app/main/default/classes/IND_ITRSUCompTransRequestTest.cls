@isTest
public class IND_ITRSUCompTransRequestTest {

    
    
    @isTest
    public static void verifyIND_ITRSUCompTransRequest(){
        
        IND_ITRSUCompleteTransactionRequest result = new IND_ITRSUCompleteTransactionRequest();
        Boolean isValid = result.validate(System.Label.ITRScanUploadCompleteTransaction);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
        
    } 
}