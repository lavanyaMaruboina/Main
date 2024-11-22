/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is wrapper class for the Membership API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
8-10-2021      Manish Baldota      Created
------------------------------------------------------------*/
public class IND_MembershipResponse extends ParentAPIResponse{
    
    public String RequestId{get;set;}
	public ResponseData ResponseData{get;set;}
    
    public class ResponseInfo {
		public Integer ApplicationId{get;set;}
		public String SolutionSetInstanceId{get;set;}
	}

	public class ResponseData {
		public String Status{get;set;}
		public ResponseInfo ResponseInfo{get;set;}
		public Fields Fields{get;set;}
	}

	public class Params {
		public List<Param> Param{get;set;}
	}

	public class Service {
		public String Id{get;set;}
		public String Name{get;set;}
		public Operations Operations{get;set;}
		public String Status{get;set;}
	}

	public class ApplicationData {
		public Services_Z Services{get;set;}
	}

	public class Data {
		public Response Response{get;set;}
	}

	public class Operation {
		public String Id{get;set;}
		public String Name{get;set;}
		public Params Params{get;set;}
		public Data Data{get;set;}
		public String Status{get;set;}
	}

	public class Service_Z {
		public String Id{get;set;}
		public String Name{get;set;}
		public String Skip{get;set;}
		public String Consent{get;set;}
		public String EnableSimulation{get;set;}
	}

	public class Response {
		public String RawResponse{get;set;}
	}

	public class Services {
		public List<Service> Service{get;set;}
	}

	public class Fields {
		public Applicants Applicants{get;set;}
		public ApplicationData ApplicationData{get;set;}
		public String Decision{get;set;}
		public String ApplicationId{get;set;}
	}

	public class Param {
		public String Name{get;set;}
		public String Value{get;set;}
	}

	public class Applicants {
		public Applicant Applicant{get;set;}
	}

	public class Operations {
		public List<Operation> Operation{get;set;}
	}

	public class Applicant {
		public Services Services{get;set;}
		public String ApplicantIdentifier{get;set;}
	}

	public class Services_Z {
		public Service_Z Service{get;set;}
	}
    
}