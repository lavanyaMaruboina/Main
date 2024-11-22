@isTest
public class IND_DMSUploadResponseTest 
{    
    @isTest
    public static void verifyIND_DMSUploadResponse(){
        IND_DMSUploadResponse.ResponseData objRes = new IND_DMSUploadResponse.ResponseData();
        System.assertEquals(objRes.status, null);
        System.assertEquals(objRes.respDesc, null);
        System.assertEquals(objRes.content, null);
        
    }    
}