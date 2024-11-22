@isTest
public class IND_ENACHRegistrationStatusResponseTest {

    
      @isTest
    public static void verifyIND_ENACHRegistrationStatusResponse(){
        IND_ENACHRegistrationStatusResponse objResp = new  IND_ENACHRegistrationStatusResponse();
   
            objResp.Dcustomerbank = '';
        objResp.DcustomerbankIFSCI = '';
        objResp.endDate = '';
        objResp.session = '';
        objResp.fluxmessage = '';
        objResp.urmn = '';
        objResp.CIFID = '';
        objResp.DealNo = '';
        objResp.message = '';
        objResp.Dcustomername = '';
        objResp.frequency = '';
        objResp.DcustomerAcc = '';
        objResp.npcirejectreason = '';
        objResp.emi_amount = '';
        objResp.customerEmail = '';
        objResp.referralCode = '';
        objResp.max_amount = '';
        objResp.digioID = '';
        objResp.updatetime = '';
        objResp.customerMobile = '';
        objResp.startDate = '';
        objResp.fluxstatus = '';
        objResp.DcustomerbankIFSCI = '';
        

        
        
     //   IND_SMSResponse result = new IND_SMSResponse();
       // result.response = objResp;
        System.assert( objResp.message == '');
    }
    
    
}