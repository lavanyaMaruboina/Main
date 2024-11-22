@isTest
public class IND_MFCValuationResponseTest {
   
    @isTest
    public static void verifyIND_MFCValuationResponse(){
        IND_MFCValuationResponse.Response objRes = new IND_MFCValuationResponse.Response();
        System.assertEquals(objRes.status, null);
        System.assertEquals(objRes.respDesc, null);
        System.assertEquals(objRes.content, null);
       IND_MFCValuationResponse.Content objRes1 = new IND_MFCValuationResponse.Content();
        System.assertEquals(objRes1.Requestid, null);
        System.assertEquals(objRes1.Applicationno, null);
        System.assertEquals(objRes1.Registrationno, null);
        System.assertEquals(objRes1.Msg, null);
        System.assertEquals(objRes1.Lead_Id, null);
        System.assertEquals(objRes1.Vehicle_Id, null);
        System.assertEquals(objRes1.Maker_Date, null);
}

}