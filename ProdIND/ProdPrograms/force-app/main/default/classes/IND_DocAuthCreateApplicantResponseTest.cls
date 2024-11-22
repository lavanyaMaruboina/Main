@isTest
public class IND_DocAuthCreateApplicantResponseTest {
    @isTest
    public static void verifyIND_DocAuthCreateApplicantResponse(){
        IND_DocAuthCreateApplicantResponse.ResponseData resResponseData=new IND_DocAuthCreateApplicantResponse.ResponseData();
        System.assertEquals(resResponseData.Fields, null);
        System.assertEquals(resResponseData.ResponseInfo, null);
        System.assertEquals(resResponseData.Status, null);

        IND_DocAuthCreateApplicantResponse.ResponseInfo resResponseInfo=new IND_DocAuthCreateApplicantResponse.ResponseInfo();
        System.assertEquals(resResponseInfo.ApplicationId, null);
        System.assertEquals(resResponseInfo.SolutionSetInstanceId, null);
        
        IND_DocAuthCreateApplicantResponse.Service resService=new IND_DocAuthCreateApplicantResponse.Service();
        System.assertEquals(resService.Id, null);
        System.assertEquals(resService.Name, null);
        System.assertEquals(resService.Operations, null);
        System.assertEquals(resService.Status, null);
        
        IND_DocAuthCreateApplicantResponse.Operation resOperation=new IND_DocAuthCreateApplicantResponse.Operation();
        System.assertEquals(resOperation.Data, null);
        System.assertEquals(resOperation.Errors, null);
        System.assertEquals(resOperation.Id, null);
        System.assertEquals(resOperation.Name, null);
         System.assertEquals(resOperation.Params, null);
        System.assertEquals(resOperation.Status, null);
        
        IND_DocAuthCreateApplicantResponse.Service_Z resService_Z=new IND_DocAuthCreateApplicantResponse.Service_Z();
        System.assertEquals(resService_Z.Consent, null);
        System.assertEquals(resService_Z.EnableSimulation, null);
        System.assertEquals(resService_Z.Id, null);
        System.assertEquals(resService_Z.Name, null);
         System.assertEquals(resService_Z.Skip, null);
        
        IND_DocAuthCreateApplicantResponse.Fields resFields=new IND_DocAuthCreateApplicantResponse.Fields();
        System.assertEquals(resFields.Applicants, null);
        System.assertEquals(resFields.ApplicationData, null);
        System.assertEquals(resFields.ApplicationId, null);
        System.assertEquals(resFields.Decision, null);
        
        IND_DocAuthCreateApplicantResponse.Applicant resApplicant=new IND_DocAuthCreateApplicantResponse.Applicant();
        System.assertEquals(resApplicant.ApplicantFirstName, null);
        System.assertEquals(resApplicant.ApplicantIdentifier, null);
        System.assertEquals(resApplicant.ApplicantLastName, null);
        System.assertEquals(resApplicant.ApplicantMiddleName, null);
        System.assertEquals(resApplicant.Services, null);
        
        IND_DocAuthCreateApplicantResponse.Services_Z resServices_Z=new IND_DocAuthCreateApplicantResponse.Services_Z();
        System.assertEquals(resServices_Z.Service, null);
        
        IND_DocAuthCreateApplicantResponse.Errors resErrors=new IND_DocAuthCreateApplicantResponse.Errors();
        System.assertEquals(resErrors.Error, null);
        
         IND_DocAuthCreateApplicantResponse.Error resError=new IND_DocAuthCreateApplicantResponse.Error();
        System.assertEquals(resError.Code, null);
        System.assertEquals(resError.Message, null);
        
         IND_DocAuthCreateApplicantResponse.Applicants resApplicants=new IND_DocAuthCreateApplicantResponse.Applicants();
        System.assertEquals(resApplicants.Applicant, null);
        
        IND_DocAuthCreateApplicantResponse.Operations resOperations=new IND_DocAuthCreateApplicantResponse.Operations();
        System.assertEquals(resOperations.Operation, null);
        
        IND_DocAuthCreateApplicantResponse.Response resResponse=new IND_DocAuthCreateApplicantResponse.Response();
        System.assertEquals(resResponse.RawResponse, null);
        
        IND_DocAuthCreateApplicantResponse.Services resServices=new IND_DocAuthCreateApplicantResponse.Services();
        System.assertEquals(resServices.Service, null);
        
        IND_DocAuthCreateApplicantResponse.ApplicationData resApplicationData=new IND_DocAuthCreateApplicantResponse.ApplicationData();
        System.assertEquals(resApplicationData.Services, null);
        
        IND_DocAuthCreateApplicantResponse.Data resData=new IND_DocAuthCreateApplicantResponse.Data();
        System.assertEquals(resData.Response, null);
        
        IND_DocAuthCreateApplicantResponse.Params resParams=new IND_DocAuthCreateApplicantResponse.Params();
        System.assertEquals(resParams.Param, null);
        
         IND_DocAuthCreateApplicantResponse result=new IND_DocAuthCreateApplicantResponse();
        System.assertEquals(result.RequestId, null);
        System.assertEquals(result.ResponseData, null);
        
        

    }

}