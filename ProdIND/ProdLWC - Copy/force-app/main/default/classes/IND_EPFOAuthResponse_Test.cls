@isTest
public class IND_EPFOAuthResponse_Test {
    @isTest
    public static void verifyIND_EPFOAuthResponse(){
        IND_EPFOAuthResponse.ResponseInfo objRes = new IND_EPFOAuthResponse.ResponseInfo();
        System.assertEquals(objRes.ApplicationId, null);
        System.assertEquals(objRes.SolutionSetInstanceId, null);
        IND_EPFOAuthResponse objRes1 = new IND_EPFOAuthResponse();
        System.assertEquals(objRes1.RequestId, null);
        System.assertEquals(objRes1.ResponseData, null);
        IND_EPFOAuthResponse.Telephone objRes20 = new IND_EPFOAuthResponse.Telephone();
        System.assertEquals(objRes20.TelephoneNumber, null);
          System.assertEquals(objRes20.TelephoneType, null);

         IND_EPFOAuthResponse.ResponseData objRes21 = new IND_EPFOAuthResponse.ResponseData();
        System.assertEquals(objRes21.Status, null);
          System.assertEquals(objRes21.ResponseInfo, null);
          System.assertEquals(objRes21.Fields, null);
        IND_EPFOAuthResponse.Params objRes2 = new IND_EPFOAuthResponse.Params();
        System.assertEquals(objRes2.Param, null);
        IND_EPFOAuthResponse.Service objRes3 = new IND_EPFOAuthResponse.Service();
        System.assertEquals(objRes3.Id, null);
         System.assertEquals(objRes3.Name, null);
         System.assertEquals(objRes3.Operations, null);
         System.assertEquals(objRes3.Status, null);
         IND_EPFOAuthResponse.ApplicationData objRes4 = new IND_EPFOAuthResponse.ApplicationData();
         System.assertEquals(objRes4.Services, null);
        IND_EPFOAuthResponse.Data objRes5 = new IND_EPFOAuthResponse.Data();
         System.assertEquals(objRes5.Response, null);
        IND_EPFOAuthResponse.Operation objRes6 = new IND_EPFOAuthResponse.Operation();
         System.assertEquals(objRes6.Id, null);
         System.assertEquals(objRes6.Name, null);
          System.assertEquals(objRes6.Params, null);
         System.assertEquals(objRes6.Data, null);
         System.assertEquals(objRes6.Status, null);
           IND_EPFOAuthResponse.Service_Z objRes7 = new IND_EPFOAuthResponse.Service_Z();
         System.assertEquals(objRes7.Id, null);
         System.assertEquals(objRes7.Name, null);
          System.assertEquals(objRes7.Skip, null);
         System.assertEquals(objRes7.Consent, null);
         System.assertEquals(objRes7.EnableSimulation, null);
           IND_EPFOAuthResponse.Response objRes8 = new IND_EPFOAuthResponse.Response();
         System.assertEquals(objRes8.RawResponse, null);
           IND_EPFOAuthResponse.Services objRes9 = new IND_EPFOAuthResponse.Services();
         System.assertEquals(objRes9.Service, null);
           IND_EPFOAuthResponse.Fields objRes10 = new IND_EPFOAuthResponse.Fields();
          System.assertEquals(objRes10.Applicants, null);
         System.assertEquals(objRes10.ApplicationData, null);
         System.assertEquals(objRes10.Decision, null);
          System.assertEquals(objRes10.ApplicationId, null);
         IND_EPFOAuthResponse.Telephones objRes11 = new IND_EPFOAuthResponse.Telephones();
          System.assertEquals(objRes11.Telephone, null);
        
         IND_EPFOAuthResponse.Param objRes12 = new IND_EPFOAuthResponse.Param();
          System.assertEquals(objRes12.Name, null);
         System.assertEquals(objRes12.Value, null);
         IND_EPFOAuthResponse.Applicants objRes13 = new IND_EPFOAuthResponse.Applicants();
          System.assertEquals(objRes13.Applicant, null);
          IND_EPFOAuthResponse.Operations objRes14 = new IND_EPFOAuthResponse.Operations();
         System.assertEquals(objRes14.Operation, null);
          IND_EPFOAuthResponse.Applicant objRes15 = new IND_EPFOAuthResponse.Applicant();
         System.assertEquals(objRes15.Services, null);
          System.assertEquals(objRes15.Telephones, null);
          System.assertEquals(objRes15.ApplicantIdentifier, null);
           IND_EPFOAuthResponse.Services_Z objRes16 = new IND_EPFOAuthResponse.Services_Z();
                 System.assertEquals(objRes16.Service, null);

   }
}