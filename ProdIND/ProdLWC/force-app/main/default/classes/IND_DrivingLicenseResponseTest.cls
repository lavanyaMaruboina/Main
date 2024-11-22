@isTest
public class IND_DrivingLicenseResponseTest {
 @isTest
    public static void verifyIND_DrivingLicenseResponse(){
        IND_DrivingLicenseResponse.ResponseInfo resResponseInfo=new IND_DrivingLicenseResponse.ResponseInfo();
        	System.assertEquals(resResponseInfo.ApplicationId, null);
         	System.assertEquals(resResponseInfo.SolutionSetInstanceId, null);
        
        IND_DrivingLicenseResponse.ResponseData resResponseData=new IND_DrivingLicenseResponse.ResponseData();
        	System.assertEquals(resResponseData.Status, null);
         	System.assertEquals(resResponseData.ResponseInfo, null);
			System.assertEquals(resResponseData.Fields, null);
         	System.assertEquals(resResponseData.Building, null);
        	System.assertEquals(resResponseData.City, null);
         	System.assertEquals(resResponseData.Pin, null);
			System.assertEquals(resResponseData.District, null);
         	System.assertEquals(resResponseData.Floor, null);
        	System.assertEquals(resResponseData.House, null);
         	System.assertEquals(resResponseData.locality, null);
			System.assertEquals(resResponseData.Complex, null);
         	System.assertEquals(resResponseData.State, null);
        	System.assertEquals(resResponseData.Landmark, null);
         	System.assertEquals(resResponseData.Untagged, null);
			System.assertEquals(resResponseData.CO, null);
         	System.assertEquals(resResponseData.Street, null);
        
        IND_DrivingLicenseResponse.Service resService=new IND_DrivingLicenseResponse.Service();
        	System.assertEquals(resService.Id, null);
         	System.assertEquals(resService.Name, null);
			System.assertEquals(resService.Operations, null);
         	System.assertEquals(resService.Status, null);
        
       IND_DrivingLicenseResponse.Params resParams=new IND_DrivingLicenseResponse.Params();
        	System.assertEquals(resParams.Param, null);

        IND_DrivingLicenseResponse.ApplicationData resApplicationData=new IND_DrivingLicenseResponse.ApplicationData();
        	System.assertEquals(resApplicationData.Services, null);

        IND_DrivingLicenseResponse.Data resData=new IND_DrivingLicenseResponse.Data();
        	System.assertEquals(resData.Response, null);

         IND_DrivingLicenseResponse.Operation resOperation=new IND_DrivingLicenseResponse.Operation();
        	System.assertEquals(resOperation.Id, null);
         	System.assertEquals(resOperation.Name, null);
			System.assertEquals(resOperation.Params, null);
         	System.assertEquals(resOperation.Data, null);
        	System.assertEquals(resOperation.Status, null);
         	System.assertEquals(resOperation.Errors, null);
        
         IND_DrivingLicenseResponse.Service_Z resService_Z=new IND_DrivingLicenseResponse.Service_Z();
        	System.assertEquals(resService_Z.Id, null);
         	System.assertEquals(resService_Z.Name, null);
			System.assertEquals(resService_Z.Skip, null);
         	System.assertEquals(resService_Z.Consent, null);
        	System.assertEquals(resService_Z.EnableSimulation, null);
        
        IND_DrivingLicenseResponse.Response resResponse=new IND_DrivingLicenseResponse.Response();
        	System.assertEquals(resResponse.RawResponse, null);

        IND_DrivingLicenseResponse.Services resServices=new IND_DrivingLicenseResponse.Services();
        	System.assertEquals(resServices.Service, null);
       
        IND_DrivingLicenseResponse.Identifier resIdentifier=new IND_DrivingLicenseResponse.Identifier();
        	System.assertEquals(resIdentifier.IdNumber, null);
        	System.assertEquals(resIdentifier.IdType, null);
        
        IND_DrivingLicenseResponse.Fields resFields=new IND_DrivingLicenseResponse.Fields();
        	System.assertEquals(resFields.Applicants, null);
         	System.assertEquals(resFields.ApplicationData, null);
			System.assertEquals(resFields.Decision, null);
         	System.assertEquals(resFields.ApplicationId, null);
        
          IND_DrivingLicenseResponse.Param resParam=new IND_DrivingLicenseResponse.Param();
        	System.assertEquals(resParam.Name, null);
         	System.assertEquals(resParam.Value, null);
              
          IND_DrivingLicenseResponse.Applicants resApplicants=new IND_DrivingLicenseResponse.Applicants();
        	System.assertEquals(resApplicants.Applicant, null);
              
          IND_DrivingLicenseResponse.Identifiers resIdentifiers=new IND_DrivingLicenseResponse.Identifiers();
        	System.assertEquals(resIdentifiers.Identifier, null);
        	
        IND_DrivingLicenseResponse.Operations resOperations=new IND_DrivingLicenseResponse.Operations();
        	System.assertEquals(resOperations.Operation, null);
        	
        IND_DrivingLicenseResponse.Services_Z resServices_Z=new IND_DrivingLicenseResponse.Services_Z();
        	System.assertEquals(resServices_Z.Service, null);
        
        IND_DrivingLicenseResponse.Errors resErrors=new IND_DrivingLicenseResponse.Errors();
        	System.assertEquals(resErrors.Error, null);
        
        IND_DrivingLicenseResponse.Error resError=new IND_DrivingLicenseResponse.Error();
        	System.assertEquals(resError.Message, null);
     	    System.assertEquals(resError.Code, null);
        
        IND_DrivingLicenseResponse.Applicant resApplicant=new IND_DrivingLicenseResponse.Applicant();
        	System.assertEquals(resApplicant.DateOfBirth, null);
     	    System.assertEquals(resApplicant.Services, null);
        	System.assertEquals(resApplicant.Identifiers, null);
     	    System.assertEquals(resApplicant.ApplicantIdentifier, null);
        
        IND_DrivingLicenseResponse result1=new IND_DrivingLicenseResponse();
        	System.assertEquals(result1.RequestId, null);
     	    //System.assertEquals(result.ResponseData, null);
     
       // IND_DrivingLicenseResponse.ResponseData = resResponseData;
    }
}