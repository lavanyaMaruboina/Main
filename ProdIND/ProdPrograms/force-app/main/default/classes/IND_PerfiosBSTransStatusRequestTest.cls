@isTest
public class IND_PerfiosBSTransStatusRequestTest {
    
    @isTest
    public static void verifyIND_PerfiosBSTransStatusRequest(){
        IND_PerfiosBSTransactionStatusRequest result = new IND_PerfiosBSTransactionStatusRequest('clientTransactionId');
        Boolean isValid = result.validate(System.label.Perfios_BS_Transaction_Status);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        String errorMessage = '';
        try{
            result = new IND_PerfiosBSTransactionStatusRequest('');
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.TxnIdErrorMsg));
    }
    
}