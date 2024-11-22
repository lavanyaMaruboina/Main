@isTest
public class IND_UidaiOTPVerifyResponseTest {
   
    @isTest
    public static void verifyIND_UidaiOTPVerifyTransactionInfo(){
        IND_UidaiOTPVerifyResponse.TransactionInfo objRes = new IND_UidaiOTPVerifyResponse.TransactionInfo();
        System.assertEquals(objRes.Pan, null);
        System.assertEquals(objRes.Proc_Code, null);
        System.assertEquals(objRes.Transm_Date_time, null);
        System.assertEquals(objRes.Stan, null);
        System.assertEquals(objRes.Local_Trans_Time, null);
        System.assertEquals(objRes.Local_date, null);
        System.assertEquals(objRes.AcqId, null);
        System.assertEquals(objRes.RRN, null);
        System.assertEquals(objRes.ResponseCode, null);
        System.assertEquals(objRes.ResponseMsg, null);
        System.assertEquals(objRes.CA_Tid, null);
        System.assertEquals(objRes.CA_ID, null);
        System.assertEquals(objRes.CA_TA, null);
        IND_UidaiOTPVerifyResponse.KycResponse objRes1 = new IND_UidaiOTPVerifyResponse.KycResponse();
        System.assertEquals(objRes1.TransactionInfo, null);
        System.assertEquals(objRes1.UidData, null);        
        
        IND_UidaiOTPVerifyResponse.UidData objRes2 = new IND_UidaiOTPVerifyResponse.UidData();
        System.assertEquals(objRes2.tkn, null);
        System.assertEquals(objRes2.txn, null);
        System.assertEquals(objRes2.uid, null);
        System.assertEquals(objRes2.dob, null);
        System.assertEquals(objRes2.name, null);
        System.assertEquals(objRes2.lm, null);
        System.assertEquals(objRes2.co, null);
        System.assertEquals(objRes2.subdist, null);
        System.assertEquals(objRes2.po, null);
        System.assertEquals(objRes2.loc, null);
        System.assertEquals(objRes2.pc, null);
        System.assertEquals(objRes2.state, null);
        System.assertEquals(objRes2.street, null);
        System.assertEquals(objRes2.vtc, null);
        System.assertEquals(objRes2.Pht, null);
       // System.assertEquals(objRes1.pc, null);
        
        
}

}