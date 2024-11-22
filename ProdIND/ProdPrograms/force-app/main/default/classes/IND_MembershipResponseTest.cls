@isTest
public class IND_MembershipResponseTest {
	@isTest
    public static void verifyIND_MembershipResponse(){
        IND_MembershipResponse.ResponseInfo objResponseInfo=new IND_MembershipResponse.ResponseInfo();
        objResponseInfo.ApplicationId=12;
        objResponseInfo.SolutionSetInstanceId='';
        System.assertEquals( objResponseInfo.ApplicationId,12);
        
        IND_MembershipResponse.Service_Z objService_Z=new IND_MembershipResponse.Service_Z();
        objService_Z.Id='';
        objService_Z.Name='test';
        objService_Z.Skip='';
        objService_Z.Consent='';
        objService_Z.EnableSimulation='';
        System.assertEquals( objService_Z.Name,'test');
        
        List<IND_MembershipResponse.Param> paramList = new List<IND_MembershipResponse.Param>();
        IND_MembershipResponse.Param objParam=new IND_MembershipResponse.Param();
        objParam.Name='test1';
        objParam.Value='';
        paramList.add(objParam);
        //System.assertEquals( objService_Z.Name,'test1');
        
        IND_MembershipResponse.Response objResponse=new IND_MembershipResponse.Response();
        objResponse.RawResponse='test';
        System.assertEquals( objResponse.RawResponse,'test');
        
        IND_MembershipResponse.Services_Z objServices_Z=new IND_MembershipResponse.Services_Z();
         System.assertEquals( objServices_Z.Service,null);
        
       IND_MembershipResponse.Applicant objApplicant=new IND_MembershipResponse.Applicant();
        objApplicant.ApplicantIdentifier='test';
         System.assertEquals( objApplicant.Services,null);
        System.assertEquals( objApplicant.ApplicantIdentifier,'test');
        
        IND_MembershipResponse.Applicants objApplicants=new IND_MembershipResponse.Applicants();
         System.assertEquals( objApplicants.Applicant,null);
        
        IND_MembershipResponse.Fields objFields=new IND_MembershipResponse.Fields();
        System.assertEquals( objFields.Applicants,null);
        System.assertEquals( objFields.ApplicationData,null);
        System.assertEquals( objFields.Decision,null);
        System.assertEquals( objFields.ApplicationId,null);
        
        List<IND_MembershipResponse.Operation> opList = new List<IND_MembershipResponse.Operation>();
        IND_MembershipResponse.Operation objOperation=new IND_MembershipResponse.Operation();
        System.assertEquals( objOperation.Id,null);
        System.assertEquals( objOperation.Name,null);
        System.assertEquals( objOperation.Params,null);
        System.assertEquals( objOperation.Data,null);
        System.assertEquals( objOperation.Status,null);
        opList.add(objOperation);
        
        List<IND_MembershipResponse.Service> serviceList = new List<IND_MembershipResponse.Service>();
        IND_MembershipResponse.Service objService=new IND_MembershipResponse.Service();
        System.assertEquals( objService.Id,null);
        System.assertEquals( objService.Name,null);
        System.assertEquals( objService.Operations,null);
        System.assertEquals( objService.Status,null);
        serviceList.add(objService);
        
        IND_MembershipResponse.ResponseData objResponseData=new IND_MembershipResponse.ResponseData();
        System.assertEquals( objResponseData.Status,null);
        System.assertEquals( objResponseData.ResponseInfo,null);
        System.assertEquals( objResponseData.Fields,null);    
        
         IND_MembershipResponse object1=new IND_MembershipResponse();
         System.assertEquals( object1.RequestId,null);
        System.assertEquals( object1.ResponseData,null);
        
        IND_MembershipResponse.ApplicationData objApplicationData=new IND_MembershipResponse.ApplicationData();
        System.assertEquals( objApplicationData.Services,null);
        
        IND_MembershipResponse.Data objData=new IND_MembershipResponse.Data();
        System.assertEquals( objData.Response,null);
        
        IND_MembershipResponse.Services sv1 = new IND_MembershipResponse.Services();
        sv1.Service = serviceList;
        
        IND_MembershipResponse.Operations opr1 = new IND_MembershipResponse.Operations();
        opr1.Operation = opList;
        
        IND_MembershipResponse.Params prs = new IND_MembershipResponse.Params();
        prs.Param = paramList;
    }
}