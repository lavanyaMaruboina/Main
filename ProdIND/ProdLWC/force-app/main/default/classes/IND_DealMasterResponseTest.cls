@isTest
public class IND_DealMasterResponseTest {
  @isTest
    public static void verifyIND_DealMasterResponse(){
        IND_DealMasterResponse.Response objResp = new  IND_DealMasterResponse.Response();
        IND_DealMasterResponse.Content objContent = new IND_DealMasterResponse.Content();
     
        objResp.content = new List<IND_DealMasterResponse.Content>{objContent};
            
        objResp.respDesc = '';
        objResp.status = '';
        objContent.DealNumber = '';
        objContent.DealNoExists = '';
        objContent.StatusFlag = '';
        objContent.Engine_Number = '';
        objContent.Chassis_Number = '';
        objContent.Make = '';
        objContent.Model = '';
        objContent.Ins_Expiry_Date = '';
        objContent.Variant = '';
        objContent.Manufacture_Year_Month = '';
        objContent.Owner_Name = '';
        objContent.No_of_Ownership = '';
        objContent.Insurance_Number = '';
        objContent.Insurer_Name = '';
        objContent.Ins_Issuance_Date = '';
         objContent.Owner_Contact_Number = '';
         objContent.Vehicle_Place_of_Valuation = '';
        
        
        IND_DealMasterResponse result = new IND_DealMasterResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    
}