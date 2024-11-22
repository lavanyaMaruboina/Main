@isTest
public class IND_APDPendingResponseTest {

    @isTest
    public static void verifyIND_APDPendingResponse(){
        IND_APDPendingResponse.Response objResp = new IND_APDPendingResponse.Response();
        
        IND_APDPendingResponse.UserRCPendings objRCPendings = new IND_APDPendingResponse.UserRCPendings();
        System.assertEquals(objRCPendings.Name, null);
        System.assertEquals(objRCPendings.Segment_Code, null);
        System.assertEquals(objRCPendings.Deal_Count, null);
        System.assertEquals(objRCPendings.Count_1_30, null);
        System.assertEquals(objRCPendings.Count_31_60, null);
        System.assertEquals(objRCPendings.Count_61_90, null);
        System.assertEquals(objRCPendings.Count_Above_90, null);
        System.assertEquals(objRCPendings.Total_Count, null);
        System.assertEquals(objRCPendings.Doc_Type, null);
        
        IND_APDPendingResponse.Content objContent = new IND_APDPendingResponse.Content();
        System.assertEquals(objContent.User_APD_Pending, null);
        System.assertEquals(objContent.Dealer_APD_Pending, null);
        
        IND_APDPendingResponse.DealerInsurancePending objDealerInsurancePending = new IND_APDPendingResponse.DealerInsurancePending();
        System.assertEquals(objDealerInsurancePending.Name, null);
        System.assertEquals(objDealerInsurancePending.Deposit_Avl, null);
        System.assertEquals(objDealerInsurancePending.Count_1_30, null);
        System.assertEquals(objDealerInsurancePending.SOH_1_30, null);
        System.assertEquals(objDealerInsurancePending.Count_31_60, null);
        System.assertEquals(objDealerInsurancePending.SOH_31_60, null);
        System.assertEquals(objDealerInsurancePending.Count_61_90, null);
        System.assertEquals(objDealerInsurancePending.SOH_61_90, null);
        System.assertEquals(objDealerInsurancePending.Count_Above_90, null);
        System.assertEquals(objDealerInsurancePending.SOH_Above_90, null);
        System.assertEquals(objDealerInsurancePending.Total_Count, null);
        System.assertEquals(objDealerInsurancePending.Doc_Type, null);
        
        IND_APDPendingResponse.UserInsurancePending objUserInsurancePending = new IND_APDPendingResponse.UserInsurancePending();
        System.assertEquals(objUserInsurancePending.Name, null);
        System.assertEquals(objUserInsurancePending.Segment_Code, null);
        System.assertEquals(objUserInsurancePending.Deposit_Avl, null);
        System.assertEquals(objUserInsurancePending.Count_1_30, null);
        System.assertEquals(objUserInsurancePending.SOH_1_30, null);
        System.assertEquals(objUserInsurancePending.Count_31_60, null);
        System.assertEquals(objUserInsurancePending.SOH_31_60, null);
        System.assertEquals(objUserInsurancePending.Count_61_90, null);
        System.assertEquals(objUserInsurancePending.SOH_61_90, null);
        System.assertEquals(objUserInsurancePending.Count_Above_90, null);
        System.assertEquals(objUserInsurancePending.SOH_Above_90, null);
        System.assertEquals(objUserInsurancePending.Total_Count, null);
        System.assertEquals(objUserInsurancePending.Doc_Type, null);
        
        IND_APDPendingResponse.DealerRCPending objDealerRCPending = new IND_APDPendingResponse.DealerRCPending();
        System.assertEquals(objDealerRCPending.Name, null);
        System.assertEquals(objDealerRCPending.Deal_Count, null);
        System.assertEquals(objDealerRCPending.Count_1_30, null);
        System.assertEquals(objDealerRCPending.Count_31_60, null);
        System.assertEquals(objDealerRCPending.Count_61_90, null);
        System.assertEquals(objDealerRCPending.Count_Above_90, null);
        System.assertEquals(objDealerRCPending.Total_Count, null);
        System.assertEquals(objDealerRCPending.Doc_Type, null);
       
    
        IND_APDPendingResponse.User_APD_Pending objUser_APD_Pending = new IND_APDPendingResponse.User_APD_Pending();
        System.assertEquals(objUser_APD_Pending.UserRCPendings, null);
        System.assertEquals(objUser_APD_Pending.UserInsurancePending, null);
        
        IND_APDPendingResponse.Dealer_APD_Pending objDealer_APD_Pending = new IND_APDPendingResponse.Dealer_APD_Pending();
        System.assertEquals(objDealer_APD_Pending.DealerRCPending, null);
        System.assertEquals(objDealer_APD_Pending.DealerInsurancePending, null);
        
        objResp.content = new List<IND_APDPendingResponse.Content>{objContent};
            objResp.respDesc = 'test';
        objResp.status = 'test';
        
        IND_APDPendingResponse result = new IND_APDPendingResponse();
        result.response = objResp;
        System.assert(result.response.status == 'test');
    }
}