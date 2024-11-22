@isTest
public class IND_ImageUploadAPIResponse_Test 
{
    @isTest
    public static void verifyIND_ImageUploadAPIResponse(){
        IND_ImageUploadAPIResponse.ResponseInfo objRes = new IND_ImageUploadAPIResponse.ResponseInfo();
        System.assertEquals(objRes.ApplicationId, null);
        System.assertEquals(objRes.SolutionSetInstanceId, null);
        
        IND_ImageUploadAPIResponse objRes1 = new IND_ImageUploadAPIResponse();
        System.assertEquals(objRes1.RequestId, null);
        System.assertEquals(objRes1.ResponseData, null);
        
        IND_ImageUploadAPIResponse.Front objRes20 = new IND_ImageUploadAPIResponse.Front();
        System.assertEquals(objRes20.Id, null);

         IND_ImageUploadAPIResponse.ResponseData objRes21 = new IND_ImageUploadAPIResponse.ResponseData();
        System.assertEquals(objRes21.Status, null);
          System.assertEquals(objRes21.ResponseInfo, null);
          System.assertEquals(objRes21.Fields, null);
        IND_ImageUploadAPIResponse.Params objRes2 = new IND_ImageUploadAPIResponse.Params();
        System.assertEquals(objRes2.Param, null);
        IND_ImageUploadAPIResponse.Error objRes25 = new IND_ImageUploadAPIResponse.Error();
        System.assertEquals(objRes25.Code, null);
        System.assertEquals(objRes25.Message, null);
        
        IND_ImageUploadAPIResponse.Service objRes3 = new IND_ImageUploadAPIResponse.Service();
        System.assertEquals(objRes3.Id, null);
         System.assertEquals(objRes3.Name, null);
         System.assertEquals(objRes3.Operations, null);
         System.assertEquals(objRes3.Status, null);
         IND_ImageUploadAPIResponse.ApplicationData objRes4 = new IND_ImageUploadAPIResponse.ApplicationData();
         System.assertEquals(objRes4.Services, null);
        IND_ImageUploadAPIResponse.Operation objRes6 = new IND_ImageUploadAPIResponse.Operation();
         System.assertEquals(objRes6.Id, null);
         System.assertEquals(objRes6.Name, null);
          System.assertEquals(objRes6.Params, null);
         System.assertEquals(objRes6.Errors, null);
         System.assertEquals(objRes6.Status, null);
           IND_ImageUploadAPIResponse.Service_Z objRes7 = new IND_ImageUploadAPIResponse.Service_Z();
         System.assertEquals(objRes7.Id, null);
         System.assertEquals(objRes7.Name, null);
          System.assertEquals(objRes7.Skip, null);
         System.assertEquals(objRes7.Consent, null);
         System.assertEquals(objRes7.EnableSimulation, null);
           IND_ImageUploadAPIResponse.Errors objRes8 = new IND_ImageUploadAPIResponse.Errors();
         System.assertEquals(objRes8.Error, null);
           IND_ImageUploadAPIResponse.Services objRes9 = new IND_ImageUploadAPIResponse.Services();
         System.assertEquals(objRes9.Service, null);
        
           IND_ImageUploadAPIResponse.Fields objRes10 = new IND_ImageUploadAPIResponse.Fields();
          System.assertEquals(objRes10.Applicants, null);
         System.assertEquals(objRes10.ApplicationData, null);
         System.assertEquals(objRes10.Decision, null);
          System.assertEquals(objRes10.ApplicationId, null);
        
         IND_ImageUploadAPIResponse.Value objRes11 = new IND_ImageUploadAPIResponse.Value();
          System.assertEquals(objRes11.Step, null);
        System.assertEquals(objRes11.Type, null);
        System.assertEquals(objRes11.Front, null);
        System.assertEquals(objRes11.DocIType, null);
         System.assertEquals(objRes11.DefaultCountryId, null);
        System.assertEquals(objRes11.Email, null);
                System.assertEquals(objRes11.SendPhone, null);
                System.assertEquals(objRes11.SendEmail, null);
                        System.assertEquals(objRes11.CurrentStep, null);



        
         IND_ImageUploadAPIResponse.Param objRes12 = new IND_ImageUploadAPIResponse.Param();
          System.assertEquals(objRes12.Name, null);
         System.assertEquals(objRes12.Value, null);
          System.assertEquals(objRes12.Value_Z, null);
         IND_ImageUploadAPIResponse.Applicants objRes13 = new IND_ImageUploadAPIResponse.Applicants();
          System.assertEquals(objRes13.Applicant, null);
          IND_ImageUploadAPIResponse.Operations objRes14 = new IND_ImageUploadAPIResponse.Operations();
         System.assertEquals(objRes14.Operation, null);
          IND_ImageUploadAPIResponse.Applicant objRes15 = new IND_ImageUploadAPIResponse.Applicant();
         System.assertEquals(objRes15.Services, null);
          System.assertEquals(objRes15.ApplicantIdentifier, null);
           IND_ImageUploadAPIResponse.Services_Z objRes16 = new IND_ImageUploadAPIResponse.Services_Z();
                 System.assertEquals(objRes16.Service, null);

   }
}