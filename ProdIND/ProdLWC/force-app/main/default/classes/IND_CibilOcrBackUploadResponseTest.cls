@isTest
public class IND_CibilOcrBackUploadResponseTest {

    
    @isTest
    public static void verifyIND_CibilOcrBackUploadResponse(){
         IND_CibilOcrBackUploadResponse obj = new IND_CibilOcrBackUploadResponse();
        System.assertEquals(obj.RequestId, null);
         System.assertEquals(obj.ResponseData, null);
        
        IND_CibilOcrBackUploadResponse.ResponseData objResp = new IND_CibilOcrBackUploadResponse.ResponseData();
        
        IND_CibilOcrBackUploadResponse.ResponseInfo objResponseInfo = new IND_CibilOcrBackUploadResponse.ResponseInfo();
        System.assertEquals(objResponseInfo.ApplicationId, null);
        System.assertEquals(objResponseInfo.SolutionSetInstanceId, null);
        
        IND_CibilOcrBackUploadResponse.APISourceSelection2s objAPISourceSelection2s = new IND_CibilOcrBackUploadResponse.APISourceSelection2s();
        System.assertEquals(objAPISourceSelection2s.APISourceSelection2, null);
       
        IND_CibilOcrBackUploadResponse.Fields objFields = new IND_CibilOcrBackUploadResponse.Fields();
        System.assertEquals(objFields.Applicants, null);
        System.assertEquals(objFields.ApplicationData, null);
        System.assertEquals(objFields.Decision, null);
        System.assertEquals(objFields.ApplicationId, null);
        
      
       	IND_CibilOcrBackUploadResponse.ResponseData objResponseData = new IND_CibilOcrBackUploadResponse.ResponseData();
        System.assertEquals(objResponseData.Status, null);
        System.assertEquals(objResponseData.ResponseInfo, null);
        System.assertEquals(objResponseData.Fields, null);
       
       IND_CibilOcrBackUploadResponse.Operation objOperation = new IND_CibilOcrBackUploadResponse.Operation();
        System.assertEquals(objOperation.Id, null);
        System.assertEquals(objOperation.Params, null);
        System.assertEquals(objOperation.Data, null);
        System.assertEquals(objOperation.Status, null);
        
        IND_CibilOcrBackUploadResponse.Service_Z objService_Z = new IND_CibilOcrBackUploadResponse.Service_Z();
        System.assertEquals(objService_Z.Id, null);
        System.assertEquals(objService_Z.Name, null);
        System.assertEquals(objService_Z.Skip, null);
        System.assertEquals(objService_Z.Consent, null);
        System.assertEquals(objService_Z.EnableSimulation, null);
        
        IND_CibilOcrBackUploadResponse.Param objParam = new IND_CibilOcrBackUploadResponse.Param();
        System.assertEquals(objParam.Value, null);
        System.assertEquals(objParam.Name, null);
        
        IND_CibilOcrBackUploadResponse.Applicants objApplicants = new IND_CibilOcrBackUploadResponse.Applicants();
        System.assertEquals(objApplicants.Applicant, null);
        
        IND_CibilOcrBackUploadResponse.APISourceSelection2 objAPISourceSelection2 = new IND_CibilOcrBackUploadResponse.APISourceSelection2();
        System.assertEquals(objAPISourceSelection2.APISource, null);
        
        IND_CibilOcrBackUploadResponse.Applicant objApplicant = new IND_CibilOcrBackUploadResponse.Applicant();
        System.assertEquals(objApplicant.Services, null);
        System.assertEquals(objApplicant.ApplicantIdentifier, null);    
        
        IND_CibilOcrBackUploadResponse.Services_Z objServices_Z = new IND_CibilOcrBackUploadResponse.Services_Z();
        System.assertEquals(objServices_Z.Service, null);
       
        IND_CibilOcrBackUploadResponse.Errors objErrors = new IND_CibilOcrBackUploadResponse.Errors();
        System.assertEquals(objErrors.Error, null);
        
        IND_CibilOcrBackUploadResponse.Operations objOperations = new IND_CibilOcrBackUploadResponse.Operations();
        System.assertEquals(objOperations.Operation, null);
        
        IND_CibilOcrBackUploadResponse.Response objResponse = new IND_CibilOcrBackUploadResponse.Response();
        System.assertEquals(objResponse.RawResponse, null);
        
        IND_CibilOcrBackUploadResponse.Services objServices = new IND_CibilOcrBackUploadResponse.Services();
        System.assertEquals(objServices.Service, null);
        
         IND_CibilOcrBackUploadResponse.Hyperverge2s objHyperverge2s = new IND_CibilOcrBackUploadResponse.Hyperverge2s();
        System.assertEquals(objHyperverge2s.Hyperverge2, null);
        
         IND_CibilOcrBackUploadResponse.Data objData = new IND_CibilOcrBackUploadResponse.Data();
        System.assertEquals(objData.Response, null);      




	    IND_CibilOcrBackUploadResponse.OCRParameter objOCRParameter = new IND_CibilOcrBackUploadResponse.OCRParameter();
        System.assertEquals(objOCRParameter.APISourceSelection2s, null);
        System.assertEquals(objOCRParameter.Hyperverge2s, null);
        
         IND_CibilOcrBackUploadResponse.Params objParams = new IND_CibilOcrBackUploadResponse.Params();
        System.assertEquals(objParams.Param, null); 

        IND_CibilOcrBackUploadResponse.Hyperverge2 objHyperverge2 = new IND_CibilOcrBackUploadResponse.Hyperverge2();
        System.assertEquals(objHyperverge2.ParamName, null);
        System.assertEquals(objHyperverge2.ParamValue, null);    
        
        IND_CibilOcrBackUploadResponse.ApplicationData objApplicationData = new IND_CibilOcrBackUploadResponse.ApplicationData();
        System.assertEquals(objApplicationData.Services, null);
        System.assertEquals(objApplicationData.OCRParameter, null);    
        System.assertEquals(objApplicationData.OCRSubscriptions, null);
        
        IND_CibilOcrBackUploadResponse.Service objService = new IND_CibilOcrBackUploadResponse.Service();
        System.assertEquals(objService.Id, null);
        System.assertEquals(objService.Operations, null);    
        System.assertEquals(objService.Status, null);
        System.assertEquals(objService.Name, null);
        
        IND_CibilOcrBackUploadResponse.Error objError = new IND_CibilOcrBackUploadResponse.Error();
        System.assertEquals(objError.Message, null);
        System.assertEquals(objError.Code, null);    
        
       // objResp.objResponseInfo = new List<IND_CibilOcrBackUploadResponse.Content>{objContent};
       // objResp.respDesc = 'test';
       // objResp.status = 'test';
     
        
       // IND_CibilOcrBackUploadResponse result = new IND_CibilOcrBackUploadResponse();
       // result.response = objResp;
       // System.assert(result.response.status == 'test');
    }
}