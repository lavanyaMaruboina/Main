@isTest
public class IND_TextMatchResponseTest {
   
    @isTest
    public static void verifyIND_TextMatchResponse(){
        IND_TextMatchResponse objRes = new IND_TextMatchResponse();
        System.assertEquals(objRes.RequestId, null);
        System.assertEquals(objRes.ResponseData, null);
       IND_TextMatchResponse.ApplicationData objRes1 = new IND_TextMatchResponse.ApplicationData();
        System.assertEquals(objRes1.Services, null);
       IND_TextMatchResponse.Operation objRes2 = new IND_TextMatchResponse.Operation();
        System.assertEquals(objRes2.Id, null);
        System.assertEquals(objRes2.Params, null);
        System.assertEquals(objRes2.Name, null);
        System.assertEquals(objRes2.Data, null);
        System.assertEquals(objRes2.Status, null);
        
        IND_TextMatchResponse.Source objRes3 = new IND_TextMatchResponse.Source();
        System.assertEquals(objRes3.SourceName, null);
        System.assertEquals(objRes3.Name, null);
        System.assertEquals(objRes3.NameMatch, null);
        System.assertEquals(objRes3.FatherNameMatch, null);
        System.assertEquals(objRes3.AddressMatch, null);
        System.assertEquals(objRes3.DobMatch, null);
        System.assertEquals(objRes3.PhoneMatch, null);
        System.assertEquals(objRes3.GenderMatch, null);
        System.assertEquals(objRes3.IDMatch, null);
        System.assertEquals(objRes3.EmailMatch, null);
         System.assertEquals(objRes3.FatherName, null);
 IND_TextMatchResponse.Names objRes40 = new IND_TextMatchResponse.Names();
        System.assertEquals(objRes40.Name, null);
        
        IND_TextMatchResponse.Name objRes4 = new IND_TextMatchResponse.Name();
        System.assertEquals(objRes4.FirstName, null);
        System.assertEquals(objRes4.LastName, null);
        
        IND_TextMatchResponse.Applicants objRes5 = new IND_TextMatchResponse.Applicants();
        System.assertEquals(objRes5.Applicant, null);
        
        IND_TextMatchResponse.MatchService objRes6 = new IND_TextMatchResponse.MatchService();
        System.assertEquals(objRes6.Source, null);
        
        IND_TextMatchResponse.Operations objRes7 = new IND_TextMatchResponse.Operations();
        System.assertEquals(objRes7.Operation, null);
        
        IND_TextMatchResponse.Services_Z objRes8 = new IND_TextMatchResponse.Services_Z();
        System.assertEquals(objRes8.Service, null);
        
        IND_TextMatchResponse.RawResponse objRes9 = new IND_TextMatchResponse.RawResponse();
        System.assertEquals(objRes9.MatchService, null);
       
        IND_TextMatchResponse.ResponseInfo objRes10 = new IND_TextMatchResponse.ResponseInfo();
        System.assertEquals(objRes10.ApplicationId, null);
        System.assertEquals(objRes10.SolutionSetInstanceId, null);
        
        IND_TextMatchResponse.ResponseData objRes11 = new IND_TextMatchResponse.ResponseData();
        System.assertEquals(objRes11.Status, null);
        System.assertEquals(objRes11.ResponseInfo, null);
        System.assertEquals(objRes11.Fields, null);
        
        IND_TextMatchResponse.Params objRes12 = new IND_TextMatchResponse.Params();
        System.assertEquals(objRes12.Param, null);
        
        IND_TextMatchResponse.Service objRes13 = new IND_TextMatchResponse.Service();
        System.assertEquals(objRes13.Id, null);
        System.assertEquals(objRes13.Operations, null);
        System.assertEquals(objRes13.Skip, null);
        System.assertEquals(objRes13.Consent, null);
        System.assertEquals(objRes13.Status, null);
        System.assertEquals(objRes13.Name, null);
        
        IND_TextMatchResponse.Data objRes14 = new IND_TextMatchResponse.Data();
        System.assertEquals(objRes14.Response, null);
        
        IND_TextMatchResponse.Service_Z objRes15 = new IND_TextMatchResponse.Service_Z();
        System.assertEquals(objRes15.Id, null);
        System.assertEquals(objRes15.Skip, null);
        System.assertEquals(objRes15.Consent, null);
        System.assertEquals(objRes15.Name, null);

        IND_TextMatchResponse.Fields objRes16 = new IND_TextMatchResponse.Fields();
        System.assertEquals(objRes16.Applicants, null);
        System.assertEquals(objRes16.ApplicationData, null);
        System.assertEquals(objRes16.Decision, null);
        System.assertEquals(objRes16.ApplicationId, null);
         IND_TextMatchResponse.Response objRes160 = new IND_TextMatchResponse.Response();
        System.assertEquals(objRes160.RawResponse, null);
         IND_TextMatchResponse.Services objRes161 = new IND_TextMatchResponse.Services();
        System.assertEquals(objRes161.Service, null);
        
      IND_TextMatchResponse.Value objRes17 = new IND_TextMatchResponse.Value();  
        System.assertEquals(objRes17.DestinationSource, null);
        
         IND_TextMatchResponse.Param objRes18 = new IND_TextMatchResponse.Param();  
        System.assertEquals(objRes18.Name, null);
        System.assertEquals(objRes18.Value, null);
        
        IND_TextMatchResponse.DestinationSource objRes19 = new IND_TextMatchResponse.DestinationSource();  
        System.assertEquals(objRes19.DestinationName, null);
        System.assertEquals(objRes19.Names, null);
        System.assertEquals(objRes19.FatherName, null);
        System.assertEquals(objRes19.DateOfBirth, null);
        System.assertEquals(objRes19.Gender, null);
        System.assertEquals(objRes19.EmailAddresses, null);
        System.assertEquals(objRes19.Telephones, null);
        System.assertEquals(objRes19.Addresses, null);
        System.assertEquals(objRes19.Identifiers, null);
        
       IND_TextMatchResponse.Applicant objRes20 = new IND_TextMatchResponse.Applicant();  
        System.assertEquals(objRes20.ApplicantFirstName, null);
        System.assertEquals(objRes20.ApplicantMiddleName, null);
        System.assertEquals(objRes20.ApplicantLastName, null);
        System.assertEquals(objRes20.Services, null);
        System.assertEquals(objRes20.ApplicantIdentifier, null); 
        
       IND_TextMatchResponse.FatherName objRes21 = new IND_TextMatchResponse.FatherName();  
        System.assertEquals(objRes21.FirstName, null);
        System.assertEquals(objRes21.MiddleName, null);
        System.assertEquals(objRes21.LastName, null);
        
}

}