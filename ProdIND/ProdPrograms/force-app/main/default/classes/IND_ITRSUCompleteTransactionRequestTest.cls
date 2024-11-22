@isTest
public class IND_ITRSUCompleteTransactionRequestTest {
   @isTest
    public static void tesRes(){
        Test.startTest();
              IND_ITRSUCompleteTransactionRequest tr1 = new IND_ITRSUCompleteTransactionRequest();
              Map<String,String> tr2 = tr1.getHttpRequestHeaders();
        Test.stopTest();
    }
    
    @isTest
    public static void tesRes2(){
        Opportunity opr2 = new Opportunity();
        opr2.StageName = 'Qualification';
        opr2.CloseDate = Date.newInstance(2021, 1, 11);
        opr2.Name = 'testone';
        insert opr2;
        
        Test.startTest();
            IND_ITRSUCompleteTransactionService.getITRSUCompleteTransactionRequest(opr2.Id);
            IND_ITRSUCompleteTransactionService.getITRSUCompleteTransactionRequest(null);
        Test.stopTest();
    }
    
	@isTest
    static void testGetITRSUCompleteTransactionRequest() {
        Opportunity opr2 = new Opportunity();
        opr2.StageName = 'Qualification';
        opr2.CloseDate = Date.newInstance(2021, 1, 11);
        opr2.Name = 'testone';
        insert opr2;
        Test.startTest();
        try {
            IND_ITRSUCompleteTransactionService.getITRSUCompleteTransactionRequest('12345');
        } catch (IND_Exception ex) {
            System.assertEquals(null, ex.getMessage());
        }
        Test.stopTest();
    }
}