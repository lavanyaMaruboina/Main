@isTest
public class RequestDataValidationExceptionTest {
     @isTest
    public static void testOne(){
        
        List<String> errList = new List<String>();
        errList.add('tester1');
        errList.add('tester2');
        
        Test.startTest();
        RequestDataValidationException rdv1 = new RequestDataValidationException(errList);
        Test.stopTest();
    }
}