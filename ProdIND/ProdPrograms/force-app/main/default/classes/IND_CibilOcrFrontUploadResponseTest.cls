@isTest
public class IND_CibilOcrFrontUploadResponseTest {

      
    @isTest
    public static void verifyIND_CibilOcrFrontUploadResponse(){
         IND_CibilOcrFrontUploadResponse obj = new IND_CibilOcrFrontUploadResponse();
        System.assertEquals(obj.RequestId, null);
         System.assertEquals(obj.ResponseData, null);
        
        IND_CibilOcrFrontUploadResponse.ResponseData objResp = new IND_CibilOcrFrontUploadResponse.ResponseData();
        
        IND_CibilOcrFrontUploadResponse.ResponseInfo objResponseInfo = new IND_CibilOcrFrontUploadResponse.ResponseInfo();
        System.assertEquals(objResponseInfo.ApplicationId, null);
        System.assertEquals(objResponseInfo.SolutionSetInstanceId, null);
        
        IND_CibilOcrFrontUploadResponse.APISourceSelection2s objAPISourceSelection2s = new IND_CibilOcrFrontUploadResponse.APISourceSelection2s();
        System.assertEquals(objAPISourceSelection2s.APISourceSelection2, null);
       
        IND_CibilOcrFrontUploadResponse.Fields objFields = new IND_CibilOcrFrontUploadResponse.Fields();
        System.assertEquals(objFields.Applicants, null);
        System.assertEquals(objFields.ApplicationData, null);
        System.assertEquals(objFields.Decision, null);
        System.assertEquals(objFields.ApplicationId, null);
        
      
       	IND_CibilOcrFrontUploadResponse.ResponseData objResponseData = new IND_CibilOcrFrontUploadResponse.ResponseData();
        System.assertEquals(objResponseData.Status, null);
        System.assertEquals(objResponseData.ResponseInfo, null);
        System.assertEquals(objResponseData.Fields, null);
       
       IND_CibilOcrFrontUploadResponse.Operation objOperation = new IND_CibilOcrFrontUploadResponse.Operation();
        System.assertEquals(objOperation.Id, null);
        System.assertEquals(objOperation.Params, null);
        System.assertEquals(objOperation.Data, null);
        System.assertEquals(objOperation.Status, null);
        System.assertEquals(objOperation.Errors, null);
        
        IND_CibilOcrFrontUploadResponse.Service_Z objService_Z = new IND_CibilOcrFrontUploadResponse.Service_Z();
        System.assertEquals(objService_Z.Id, null);
        System.assertEquals(objService_Z.Name, null);
        System.assertEquals(objService_Z.Skip, null);
        System.assertEquals(objService_Z.Consent, null);
        System.assertEquals(objService_Z.EnableSimulation, null);
        
        IND_CibilOcrFrontUploadResponse.Param objParam = new IND_CibilOcrFrontUploadResponse.Param();
        System.assertEquals(objParam.Value, null);
        System.assertEquals(objParam.Name, null);
        
        IND_CibilOcrFrontUploadResponse.Applicants objApplicants = new IND_CibilOcrFrontUploadResponse.Applicants();
        System.assertEquals(objApplicants.Applicant, null);
        
        IND_CibilOcrFrontUploadResponse.APISourceSelection2 objAPISourceSelection2 = new IND_CibilOcrFrontUploadResponse.APISourceSelection2();
        System.assertEquals(objAPISourceSelection2.APISource, null);
        
        IND_CibilOcrFrontUploadResponse.Applicant objApplicant = new IND_CibilOcrFrontUploadResponse.Applicant();
        System.assertEquals(objApplicant.Services, null);
        System.assertEquals(objApplicant.ApplicantIdentifier, null);    
        
        IND_CibilOcrFrontUploadResponse.Services_Z objServices_Z = new IND_CibilOcrFrontUploadResponse.Services_Z();
        System.assertEquals(objServices_Z.Service, null);
       
        IND_CibilOcrFrontUploadResponse.Errors objErrors = new IND_CibilOcrFrontUploadResponse.Errors();
        System.assertEquals(objErrors.Error, null);
        
        IND_CibilOcrFrontUploadResponse.Operations objOperations = new IND_CibilOcrFrontUploadResponse.Operations();
        System.assertEquals(objOperations.Operation, null);
        
        IND_CibilOcrFrontUploadResponse.Response objResponse = new IND_CibilOcrFrontUploadResponse.Response();
        System.assertEquals(objResponse.RawResponse, null);
        
        IND_CibilOcrFrontUploadResponse.Services objServices = new IND_CibilOcrFrontUploadResponse.Services();
        System.assertEquals(objServices.Service, null);
        
         IND_CibilOcrFrontUploadResponse.Hyperverge2s objHyperverge2s = new IND_CibilOcrFrontUploadResponse.Hyperverge2s();
        System.assertEquals(objHyperverge2s.Hyperverge2, null);
        
         IND_CibilOcrFrontUploadResponse.Data objData = new IND_CibilOcrFrontUploadResponse.Data();
        System.assertEquals(objData.Response, null);      




	    IND_CibilOcrFrontUploadResponse.OCRParameter objOCRParameter = new IND_CibilOcrFrontUploadResponse.OCRParameter();
        System.assertEquals(objOCRParameter.APISourceSelection2s, null);
        System.assertEquals(objOCRParameter.Hyperverge2s, null);
        
         IND_CibilOcrFrontUploadResponse.Params objParams = new IND_CibilOcrFrontUploadResponse.Params();
        System.assertEquals(objParams.Param, null); 

        IND_CibilOcrFrontUploadResponse.Hyperverge2 objHyperverge2 = new IND_CibilOcrFrontUploadResponse.Hyperverge2();
        System.assertEquals(objHyperverge2.ParamName, null);
        System.assertEquals(objHyperverge2.ParamValue, null);    
        
        IND_CibilOcrFrontUploadResponse.ApplicationData objApplicationData = new IND_CibilOcrFrontUploadResponse.ApplicationData();
        System.assertEquals(objApplicationData.Services, null);
        System.assertEquals(objApplicationData.OCRParameter, null);    
        System.assertEquals(objApplicationData.OCRSubscriptions, null);
        
        IND_CibilOcrFrontUploadResponse.Service objService = new IND_CibilOcrFrontUploadResponse.Service();
        System.assertEquals(objService.Id, null);
        System.assertEquals(objService.Operations, null);    
        System.assertEquals(objService.Status, null);
        System.assertEquals(objService.Name, null);
        
        IND_CibilOcrFrontUploadResponse.Error objError = new IND_CibilOcrFrontUploadResponse.Error();
        System.assertEquals(objError.Message, null);
        System.assertEquals(objError.Code, null);    
        
       // objResp.objResponseInfo = new List<IND_CibilOcrFrontUploadResponse.Content>{objContent};
       // objResp.respDesc = 'test';
       // objResp.status = 'test';
     
        
       // IND_CibilOcrFrontUploadResponse result = new IND_CibilOcrFrontUploadResponse();
       // result.response = objResp;
       // System.assert(result.response.status == 'test');
    }
    
    
    
}