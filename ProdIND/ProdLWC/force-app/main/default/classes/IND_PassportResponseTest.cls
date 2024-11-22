@isTest
public class IND_PassportResponseTest {
	@isTest
    public static void verifyIND_PassportResponse(){
        IND_PassportResponse.ResponseInfo resResponseInfo=new IND_PassportResponse.ResponseInfo();
        	System.assertEquals(resResponseInfo.ApplicationId, null);
         	System.assertEquals(resResponseInfo.SolutionSetInstanceId, null);
        
        IND_PassportResponse.ResponseData resResponseData=new IND_PassportResponse.ResponseData();
        	System.assertEquals(resResponseData.Status, null);
         	System.assertEquals(resResponseData.ResponseInfo, null);
        	System.assertEquals(resResponseData.Fields, null);
        
         IND_PassportResponse.Service resService=new IND_PassportResponse.Service();
        	System.assertEquals(resService.Id, null);
         	System.assertEquals(resService.Name, null);
        	System.assertEquals(resService.Operations, null);
       	    System.assertEquals(resService.Status, null);
        
        
         IND_PassportResponse.ApplicationData resApplicationData=new IND_PassportResponse.ApplicationData();
        	System.assertEquals(resApplicationData.Services, null);
        
        
         IND_PassportResponse.Data resData=new IND_PassportResponse.Data();
        	System.assertEquals(resData.Response, null);
        
          IND_PassportResponse.Operation resOperation=new IND_PassportResponse.Operation();
        	System.assertEquals(resOperation.Id, null);
         	System.assertEquals(resOperation.Name, null);
        	System.assertEquals(resOperation.Params, null);
       	    System.assertEquals(resOperation.Data, null);
           	System.assertEquals(resOperation.Status, null);
       	    System.assertEquals(resOperation.Errors, null);

		IND_PassportResponse.Service_Z resService_Z=new IND_PassportResponse.Service_Z();
        	System.assertEquals(resService_Z.Id, null);
         	System.assertEquals(resService_Z.Name, null);
        	System.assertEquals(resService_Z.Skip, null);
       	    System.assertEquals(resService_Z.Consent, null);
           	System.assertEquals(resService_Z.EnableSimulation, null); 
        
        IND_PassportResponse.Response resResponse=new IND_PassportResponse.Response();
        	System.assertEquals(resResponse.RawResponse, null);
        
        IND_PassportResponse.Services resServices=new IND_PassportResponse.Services();
        	System.assertEquals(resServices.Service, null);
        
         IND_PassportResponse.Identifier resIdentifier=new IND_PassportResponse.Identifier();
        	System.assertEquals(resIdentifier.IdNumber, null);
        	System.assertEquals(resIdentifier.IdType, null);
        
        IND_PassportResponse.Fields resFields=new IND_PassportResponse.Fields();
        	System.assertEquals(resFields.Applicants, null);
         	System.assertEquals(resFields.ApplicationData, null);
        	System.assertEquals(resFields.Decision, null);
       	    System.assertEquals(resFields.ApplicationId, null);
        
         IND_PassportResponse.Param resParam=new IND_PassportResponse.Param();
        	System.assertEquals(resParam.Name, null);
        	System.assertEquals(resParam.Value, null);
        
         IND_PassportResponse.Applicants resApplicants=new IND_PassportResponse.Applicants();
        	System.assertEquals(resApplicants.Applicant, null);
        
         IND_PassportResponse.Identifiers resIdentifiers=new IND_PassportResponse.Identifiers();
        	System.assertEquals(resIdentifiers.Identifier, null);
        
         IND_PassportResponse.Operations resOperations=new IND_PassportResponse.Operations();
        	System.assertEquals(resOperations.Operation, null);
        
        IND_PassportResponse.Services_Z resServices_Z=new IND_PassportResponse.Services_Z();
        	System.assertEquals(resServices_Z.Service, null);
        
         IND_PassportResponse.Errors resErrors=new IND_PassportResponse.Errors();
        	System.assertEquals(resErrors.Error, null);
        
         IND_PassportResponse.Error resError=new IND_PassportResponse.Error();
        	System.assertEquals(resError.Message, null);
       	    System.assertEquals(resError.Code, null);
        
        
        IND_PassportResponse.Applicant resApplicant=new IND_PassportResponse.Applicant();
        	System.assertEquals(resApplicant.ApplicantFirstName, null);
         	System.assertEquals(resApplicant.ApplicantMiddleName, null);
        	System.assertEquals(resApplicant.ApplicantLastName, null);
       	    System.assertEquals(resApplicant.Gender, null);
       	    System.assertEquals(resApplicant.DateOfBirth, null);
        	System.assertEquals(resApplicant.Services, null);
       	    System.assertEquals(resApplicant.Identifiers, null);
            System.assertEquals(resApplicant.ApplicantIdentifier, null);
        
         IND_PassportResponse result=new IND_PassportResponse();
        	System.assertEquals(result.RequestId, null);
         	System.assertEquals(result.ResponseData, null);
    }  
}