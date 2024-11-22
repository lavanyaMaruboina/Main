@isTest
public class IND_EPFUANLookupResponseTest {
	@isTest
    public static void verifyIND_EPFUANLookupResponse(){
        IND_EPFUANLookupResponse.ResponseInfo resInfo=new IND_EPFUANLookupResponse.ResponseInfo();
        System.assertEquals(resInfo.ApplicationId, null);
        System.assertEquals(resInfo.SolutionSetInstanceId,null);
    
       IND_EPFUANLookupResponse.Telephone resTelephone=new IND_EPFUANLookupResponse.Telephone();
            System.assertEquals(resTelephone.TelephoneNumber, null);
            System.assertEquals(resTelephone.TelephoneType,null);
        
       IND_EPFUANLookupResponse.ResponseData resResponseData=new IND_EPFUANLookupResponse.ResponseData();
            System.assertEquals(resResponseData.Fields, null);
            System.assertEquals(resResponseData.ResponseInfo,null);      
            System.assertEquals(resResponseData.Status,null);  
            
       IND_EPFUANLookupResponse.Service resService=new IND_EPFUANLookupResponse.Service();
            System.assertEquals(resService.Id, null);
            System.assertEquals(resService.Name,null);      
            System.assertEquals(resService.Operations,null);      
            System.assertEquals(resService.Status,null);  
  
           IND_EPFUANLookupResponse.Operation resOperation=new IND_EPFUANLookupResponse.Operation();
                System.assertEquals(resOperation.Data, null);
                System.assertEquals(resOperation.Id,null);      
                System.assertEquals(resOperation.Name,null);      
                System.assertEquals(resOperation.Params,null);  
                System.assertEquals(resOperation.Status,null);  
                

           IND_EPFUANLookupResponse.Service_Z resService_Z=new IND_EPFUANLookupResponse.Service_Z();
                System.assertEquals(resService_Z.Consent, null);
                System.assertEquals(resService_Z.EnableSimulation,null);      
                System.assertEquals(resService_Z.Id,null);      
                System.assertEquals(resService_Z.Name,null);  
                System.assertEquals(resService_Z.Skip,null);  
                
    
          IND_EPFUANLookupResponse.Fields resFields=new IND_EPFUANLookupResponse.Fields();
                System.assertEquals(resFields.Applicants, null);
                System.assertEquals(resFields.ApplicationData,null);      
                System.assertEquals(resFields.ApplicationId,null);      
                System.assertEquals(resFields.Decision,null);  
                
        IND_EPFUANLookupResponse.Applicant resApplicant=new IND_EPFUANLookupResponse.Applicant();
                System.assertEquals(resApplicant.ApplicantIdentifier, null);
                System.assertEquals(resApplicant.Services,null);      
                System.assertEquals(resApplicant.Telephones,null);    
        IND_EPFUANLookupResponse.Services_Z resServices_Z=new IND_EPFUANLookupResponse.Services_Z();
                System.assertEquals(resServices_Z.Service, null);
        IND_EPFUANLookupResponse.Applicants resApplicants=new IND_EPFUANLookupResponse.Applicants();
                System.assertEquals(resApplicants.Applicant, null);
        IND_EPFUANLookupResponse.Operations resOperations=new IND_EPFUANLookupResponse.Operations();
                System.assertEquals(resOperations.Operation, null);
        IND_EPFUANLookupResponse.Telephones resTelephones=new IND_EPFUANLookupResponse.Telephones();
                System.assertEquals(resTelephones.Telephone, null);
        IND_EPFUANLookupResponse.Param resParam=new IND_EPFUANLookupResponse.Param();
                System.assertEquals(resParam.Name, null);
        		System.assertEquals(resParam.Value, null);
        IND_EPFUANLookupResponse.Response resResponsex=new IND_EPFUANLookupResponse.Response();
                System.assertEquals(resResponsex.RawResponse, null);
        IND_EPFUANLookupResponse.Services resServices=new IND_EPFUANLookupResponse.Services();
                System.assertEquals(resServices.Service, null);
        IND_EPFUANLookupResponse.ApplicationData resApplicationData=new IND_EPFUANLookupResponse.ApplicationData();
                System.assertEquals(resApplicationData.Services, null);
        IND_EPFUANLookupResponse.Data resData=new IND_EPFUANLookupResponse.Data();
                System.assertEquals(resData.Response, null);
        IND_EPFUANLookupResponse.Params resParams=new IND_EPFUANLookupResponse.Params();
                System.assertEquals(resParams.Param, null);
        
        IND_EPFUANLookupResponse ePresponse =new IND_EPFUANLookupResponse();
        System.assertEquals(ePresponse.RequestId, null);
        System.assertEquals(ePresponse.ResponseData, null);
            }
    
}