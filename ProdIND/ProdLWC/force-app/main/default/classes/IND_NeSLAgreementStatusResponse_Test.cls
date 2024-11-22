@isTest
public class IND_NeSLAgreementStatusResponse_Test {
    
    @isTest
    public static void verifyIND_NeSLAgreementStatusResponse(){
        try{
            //create user
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                              TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1237633357780851@indusbank.com');
            insert u;
            System.runAs(u) 
            {
                IND_NeSLAgreementStatusResponse.Response objResp = new  IND_NeSLAgreementStatusResponse.Response();
                IND_NeSLAgreementStatusResponse.Content objContent = new IND_NeSLAgreementStatusResponse.Content();
                
                objContent.Status_Code ='';
                objContent.Status_Description ='';
                objContent.Esign_Link ='';
                objResp.content = new List<IND_NeSLAgreementStatusResponse.Content>{objContent};
                objResp.respDesc = '';
                objResp.status = '';
                IND_NeSLAgreementStatusResponse result = new IND_NeSLAgreementStatusResponse();
                result.response = objResp;
                System.assert(result.response.status == '');
            }
        }catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
        
    }
    
    
}