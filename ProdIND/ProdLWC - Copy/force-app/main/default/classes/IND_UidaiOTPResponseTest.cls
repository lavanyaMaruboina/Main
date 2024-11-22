@isTest
public class IND_UidaiOTPResponseTest {

    
          @isTest
    public static void verifyIND_UidaiOTPResponse(){
        IND_UidaiOTPResponse  objotp = new  IND_UidaiOTPResponse();
        IND_UidaiOTPResponse.TransactionInfo objtrans = new  IND_UidaiOTPResponse.TransactionInfo();
        IND_UidaiOTPResponse.KycResponse objkyc = new IND_UidaiOTPResponse.KycResponse();
        IND_UidaiOTPResponse.UidData objuid = new IND_UidaiOTPResponse.UidData();
        
        System.assertEquals(objtrans.Pan, null);
        System.assertEquals(objtrans.Proc_Code, null);
        System.assertEquals(objtrans.Transm_Date_time, null);
        System.assertEquals(objtrans.Stan, null);
        System.assertEquals(objtrans.Local_Trans_Time, null);
        System.assertEquals(objtrans.Local_date, null);
        System.assertEquals(objtrans.AcqId, null);
        System.assertEquals(objtrans.RRN, null);
        System.assertEquals(objtrans.ResponseCode, null);
        System.assertEquals(objtrans.ResponseMsg, null);
        System.assertEquals(objtrans.CA_Tid, null);
        System.assertEquals(objtrans.CA_ID, null);
        System.assertEquals(objtrans.CA_TA, null);
        
        System.assertEquals(objkyc.TransactionInfo, null);
        System.assertEquals(objkyc.UidData, null);
        
        
        System.assertEquals(objuid.txn, null);
        
        IND_UidaiOTPResponse rt1 = new IND_UidaiOTPResponse();
        rt1.kycResponse = objkyc;

    }
    
}