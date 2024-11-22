@isTest
public class IND_AgreementBookletResponseTest {
    
    @isTest
    public static void verifyIND_AgreementBookletResponse(){
        IND_AgreementBookletResponse.Response objResp = new  IND_AgreementBookletResponse.Response();
        IND_AgreementBookletResponse.Content objContent = new IND_AgreementBookletResponse.Content();
        
        objContent.Stamp_S_No ='';
        objContent.Stamp_On ='';
        objContent.Stamp_On ='';
        objContent.Stamp_Printed_Location_Blcode ='';
        objContent.Stamp_Printed_Location_BlName ='';
        objContent.Stamp_Type ='';
        objContent.Stamp_Value ='';
        objContent.Stamped_For ='';
        objContent.Stamp_Towards ='';

        objResp.content = new List<IND_AgreementBookletResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_AgreementBookletResponse result = new IND_AgreementBookletResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    } 
}