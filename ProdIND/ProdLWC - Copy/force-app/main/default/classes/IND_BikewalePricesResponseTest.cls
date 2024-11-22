@isTest
public class IND_BikewalePricesResponseTest {
@isTest
    public static void verifyIND_BikePricesResponse(){
         IND_BikewalePricesResponse.ExShowroom obj1 =new IND_BikewalePricesResponse.ExShowroom();
        System.assertEquals(obj1.value, null);
        System.assertEquals(obj1.type, null);
        System.assertEquals(obj1.id, null);
        System.assertEquals(obj1.name, null);
        IND_BikewalePricesResponse.rto obj2 =new IND_BikewalePricesResponse.rto();
       System.assertEquals(obj2.value, null);
        System.assertEquals(obj2.type, null);
        System.assertEquals(obj2.id, null);
        System.assertEquals(obj2.name, null);
        IND_BikewalePricesResponse.insuranceComprehensive obj3 =new IND_BikewalePricesResponse.insuranceComprehensive();
         System.assertEquals(obj3.value, null);
        System.assertEquals(obj3.type, null);
        System.assertEquals(obj3.id, null);
        System.assertEquals(obj3.name, null);
        IND_BikewalePricesResponse.otherCharges obj4 =new IND_BikewalePricesResponse.otherCharges();
         System.assertEquals(obj4.value, null);
        System.assertEquals(obj4.type, null);
        System.assertEquals(obj4.id, null);
        System.assertEquals(obj4.name, null);
        
        IND_BikewalePricesResponse pr1 = new IND_BikewalePricesResponse();
        pr1.exShowroom = obj1;
        IND_BikewalePricesResponse pr2 = new IND_BikewalePricesResponse();
        pr2.rto = obj2;
        IND_BikewalePricesResponse pr3 = new IND_BikewalePricesResponse();
        pr3.insuranceComprehensive = obj3;
        
    }
}