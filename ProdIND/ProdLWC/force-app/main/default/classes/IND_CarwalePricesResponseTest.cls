@isTest
public class IND_CarwalePricesResponseTest {
@isTest
    public static void verifyIND_CarwalePricesResponse(){
         IND_CarwalePricesResponse.Response obj1 =new IND_CarwalePricesResponse.Response();
        System.assertEquals(obj1.status, null);
        System.assertEquals(obj1.respDesc, null);
        System.assertEquals(obj1.content, null);
        IND_CarwalePricesResponse.Content obj2 =new IND_CarwalePricesResponse.Content();
        System.assertEquals(obj2.isMetallic, null);
         System.assertEquals(obj2.pricesList, null);
         System.assertEquals(obj2.nearByCityId, null);
         System.assertEquals(obj2.nearByCityName, null);
        IND_CarwalePricesResponse.PricesList obj3 =new IND_CarwalePricesResponse.PricesList();
         System.assertEquals(obj3.value, null);
         System.assertEquals(obj3.type, null);
         System.assertEquals(obj3.id, null);
         System.assertEquals(obj3.name, null);
        
        IND_CarwalePricesResponse pr1 = new IND_CarwalePricesResponse();
        pr1.response = obj1;
    }
}