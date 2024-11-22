@isTest
public class AsyncPayloadReponseTest {
     @isTest
    public static void testTwo(){
        
        Test.startTest();
              AsyncPayloadReponse ap1 = new AsyncPayloadReponse('testref','testres','testexp');
              ap1.encryptResponseExt = 'testencry';
              ap1.encryptResponse = 'testres';
        Test.stopTest();
    }
}