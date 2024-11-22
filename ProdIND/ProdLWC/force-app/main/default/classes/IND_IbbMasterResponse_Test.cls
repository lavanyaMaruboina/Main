@isTest
public class IND_IbbMasterResponse_Test {
     
    @isTest
    public static void verifyIND_IbbMasterResponse(){
        IND_IbbMasterResponse objRes = new IND_IbbMasterResponse();
        System.assertEquals(objRes.application_no, null);
        System.assertEquals(objRes.vehicle_id, null);
        System.assertEquals(objRes.ibb_price_min, null);
        System.assertEquals(objRes.ibb_price_avg, null);
        System.assertEquals(objRes.ibb_price_max, null);
        System.assertEquals(objRes.status, null);
         System.assertEquals(objRes.message, null);
       
}


}