@isTest
public class IND_ReferenceRelationMasterResponseTest {
    
    @isTest
    public static void referenceRelationMasterResponseTest(){
        IND_ReferenceAndRelationMasterResponse.Response objRes = new IND_ReferenceAndRelationMasterResponse.Response();
        System.assertEquals(objRes.status, null);
        System.assertEquals(objRes.respDesc, null);
        System.assertEquals(objRes.content, null);
        
    }
}