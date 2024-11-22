@isTest
public class IND_VoterIdResponseTest {
   
    @isTest
    public static void verifyIND_VoterIdResponse(){
        IND_VoterIdResponse.ResponseInfo objRes = new IND_VoterIdResponse.ResponseInfo();
        System.assertEquals(objRes.ApplicationId, null);
        System.assertEquals(objRes.SolutionSetInstanceId, null);
       IND_VoterIdResponse.Telephone objRes1 = new IND_VoterIdResponse.Telephone();
        System.assertEquals(objRes1.TelephoneNumber, null);
        System.assertEquals(objRes1.TelephoneType, null);
        
       IND_VoterIdResponse.ResponseData objRes2 = new IND_VoterIdResponse.ResponseData();
        System.assertEquals(objRes2.Status, null);
        System.assertEquals(objRes2.ResponseInfo, null);
        System.assertEquals(objRes2.Fields, null);
      IND_VoterIdResponse objRes30 = new IND_VoterIdResponse();
         System.assertEquals(objRes30.RequestId, null);
        System.assertEquals(objRes30.ResponseData, null);
        
        IND_VoterIdResponse.Service objRes3 = new IND_VoterIdResponse.Service();
        System.assertEquals(objRes3.Id, null);
        System.assertEquals(objRes3.Name, null);
        System.assertEquals(objRes3.Operations, null);
        System.assertEquals(objRes3.Status, null);
        
        IND_VoterIdResponse.ApplicationData objRes4 = new IND_VoterIdResponse.ApplicationData();
        System.assertEquals(objRes4.Services, null);
        
        IND_VoterIdResponse.Data objRes5 = new IND_VoterIdResponse.Data();
        System.assertEquals(objRes5.Response, null);
        
        IND_VoterIdResponse.Operation objRes6 = new IND_VoterIdResponse.Operation();
        System.assertEquals(objRes6.Id, null);
        System.assertEquals(objRes6.Data, null);
        System.assertEquals(objRes6.Status, null);
        System.assertEquals(objRes6.Errors, null);
        
        IND_VoterIdResponse.Service_Z objRes7 = new IND_VoterIdResponse.Service_Z();
        System.assertEquals(objRes7.Id, null);
        System.assertEquals(objRes7.Consent, null);
        System.assertEquals(objRes7.Skip, null);
        System.assertEquals(objRes7.EnableSimulation, null);
        System.assertEquals(objRes7.Name, null);
        
        IND_VoterIdResponse.Response objRes8 = new IND_VoterIdResponse.Response();
        System.assertEquals(objRes8.RawResponse, null);
        
        IND_VoterIdResponse.Services objRes9 = new IND_VoterIdResponse.Services();
        System.assertEquals(objRes9.Service, null);
       
        IND_VoterIdResponse.Identifier objRes10 = new IND_VoterIdResponse.Identifier();
        System.assertEquals(objRes10.IdNumber, null);
        System.assertEquals(objRes10.IdType, null);
        
        IND_VoterIdResponse.Fields objRes11 = new IND_VoterIdResponse.Fields();
        System.assertEquals(objRes11.Applicants, null);
        System.assertEquals(objRes11.ApplicationData, null);
        System.assertEquals(objRes11.ApplicationId, null);
        
        IND_VoterIdResponse.Telephones objRes12 = new IND_VoterIdResponse.Telephones();
        System.assertEquals(objRes12.Telephone, null);
        
        IND_VoterIdResponse.Applicants objRes13 = new IND_VoterIdResponse.Applicants();
        System.assertEquals(objRes13.Applicant, null);
        
        IND_VoterIdResponse.Identifiers objRes14 = new IND_VoterIdResponse.Identifiers();
        System.assertEquals(objRes14.Identifier, null);
        
        IND_VoterIdResponse.Operations objRes15 = new IND_VoterIdResponse.Operations();
        System.assertEquals(objRes15.Operation, null);
       
        IND_VoterIdResponse.Applicant objRes16 = new IND_VoterIdResponse.Applicant();
        System.assertEquals(objRes16.Telephones, null);
        System.assertEquals(objRes16.Identifiers, null);
        System.assertEquals(objRes16.Services, null);
        System.assertEquals(objRes16.ApplicantIdentifier, null);
        
        IND_VoterIdResponse.Services_Z objRes18 = new IND_VoterIdResponse.Services_Z();  
        System.assertEquals(objRes18.Service, null);
        
        IND_VoterIdResponse.Errors objRes19 = new IND_VoterIdResponse.Errors();  
        System.assertEquals(objRes19.Error, null);
        
       IND_VoterIdResponse.Error objRes20 = new IND_VoterIdResponse.Error();  
        System.assertEquals(objRes20.Message, null);
        System.assertEquals(objRes20.Code, null);
        
}

}