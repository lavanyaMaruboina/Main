@isTest
public class IND_PerfiosITRStatusRequestTest {
    
    @isTest
    public static void verifyIND_PerfiosITRStatusRequest(){
        
        IND_PerfiosITRStatusRequest result = new IND_PerfiosITRStatusRequest('txnId');
        Boolean isValid = result.validate(System.label.ITRStatus);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        String errorMessage = '';
        try{
            result = new IND_PerfiosITRStatusRequest('');
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.ClientTransactionIdError));
        
    }
    
}