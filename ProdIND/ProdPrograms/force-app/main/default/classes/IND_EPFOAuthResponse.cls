/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the EPFO Auth response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
17-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_EPFOAuthResponse extends ParentAPIResponse{
    public class ResponseInfo {
		public final Integer ApplicationId{get;set;}
		public final String SolutionSetInstanceId{get;set;}
	}

	public final String RequestId{get;set;}
	public final ResponseData ResponseData{get;set;}

	public class Telephone {
		public final String TelephoneNumber{get;set;}
		public final String TelephoneType{get;set;}
	}

	public class ResponseData {
		public final String Status{get;set;}
		public final ResponseInfo ResponseInfo{get;set;}
		public final Fields Fields{get;set;}
	}

	public class Params {
		public final List<Param> Param{get;set;}
	}

	public class Service {
		public final String Id{get;set;}
		public final String Name{get;set;}
		public final Operations Operations{get;set;}
		public final String Status{get;set;}
	}

	public class ApplicationData {
		public final Services_Z Services{get;set;}
	}

	public class Data {
		public final Response Response{get;set;}
	}

	public class Operation {
		public final String Id{get;set;}
		public final String Name{get;set;}
		public final Params Params{get;set;}
		public final Data Data{get;set;}
		public final String Status{get;set;}
	}

	public class Service_Z {
		public final String Id{get;set;}
		public final String Name{get;set;}
		public final String Skip{get;set;}
		public final String Consent{get;set;}
		public final String EnableSimulation{get;set;}
	}

	public class Response {
		public final String RawResponse{get;set;}
	}

	public class Services {
		public final List<Service> Service{get;set;}
	}

	public class Fields {
		public final Applicants Applicants{get;set;}
		public final ApplicationData ApplicationData{get;set;}
		public final String Decision{get;set;}
		public final String ApplicationId{get;set;}
	}

	public class Telephones {
		public final Telephone Telephone{get;set;}
	}

	public class Param {
		public final String Name{get;set;}
		public final String Value{get;set;}
	}

	public class Applicants {
		public final Applicant Applicant{get;set;}
	}

	public class Operations {
		public final List<Operation> Operation{get;set;}
	}

	public class Applicant {
		public final Services Services{get;set;}
		public final Telephones Telephones{get;set;}
		public final String ApplicantIdentifier{get;set;}
	}

	public class Services_Z {
		public final Service_Z Service{get;set;}
	}

}