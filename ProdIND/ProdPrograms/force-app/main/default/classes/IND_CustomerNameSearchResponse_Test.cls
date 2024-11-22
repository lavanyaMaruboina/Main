@isTest
public class IND_CustomerNameSearchResponse_Test {
  
    @isTest
    public static void verifyIND_CustomerNameSearchResponse(){
        IND_CustomerNameSearchResponse.Response objRes = new IND_CustomerNameSearchResponse.Response();
        System.assertEquals(objRes.status, null);
        System.assertEquals(objRes.respDesc, null);
        System.assertEquals(objRes.content, null);
         IND_CustomerNameSearchResponse.Content objRes1 = new IND_CustomerNameSearchResponse.Content();
        System.assertEquals(objRes1.Customer_Name, null);
        System.assertEquals(objRes1.Flag, null);
        System.assertEquals(objRes1.Description, null);
        System.assertEquals(objRes1.Customer_Code, null);
        
        IND_CustomerNameSearchResponse sr1 = new IND_CustomerNameSearchResponse();
        sr1.response = objRes;
       
}
}