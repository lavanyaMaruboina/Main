@isTest
public class IND_AadhaarVault_ResponseTest { 
@isTest
    public static void IND_AadhaarVault_ResponseTest(){
        IND_AadhaarVault_Response  objVault = new  IND_AadhaarVault_Response();
        IND_AadhaarVault_Response.Response objtrans = new  IND_AadhaarVault_Response.Response();
        IND_AadhaarVault_Response.Content objkyc = new IND_AadhaarVault_Response.Content();
        
        
        System.assertEquals(objtrans.status, null);
        System.assertEquals(objtrans.respDesc, null);
        System.assertEquals(objtrans.content, null);
        
        
        System.assertEquals(objkyc.Status, null);
        System.assertEquals(objkyc.Message, null);
        System.assertEquals(objkyc.UID_Token_No, null);
        System.assertEquals(objkyc.Vault_Reference_No, null);
    

    }
}