/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the Passport response
Test Class:	IND_PassportService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
11-11-2021    Aman Mundhada            Created
------------------------------------------------------------*/

public class IND_PassportResponse extends ParentAPIResponse {
    
    public class ResponseInfo {
		public final Integer ApplicationId{get;set;}
		public final String SolutionSetInstanceId{get;set;}
	}

	public final String RequestId{get;set;}
	public final ResponseData ResponseData{get;set;}

	public class ResponseData {
		public final String Status{get;set;}
		public final ResponseInfo ResponseInfo{get;set;}
		public final Fields Fields{get;set;}
	}

	public class Params {
		public final List<Param> Param;
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
        public final Errors Errors{get;set;}
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

	public class Identifier {
		public final String IdNumber{get;set;}
		public final String IdType{get;set;}
	}

	public class Fields {
		public final Applicants Applicants{get;set;}
		public final ApplicationData ApplicationData{get;set;}
		public final String Decision{get;set;}
		public final String ApplicationId{get;set;}
	}

	public class Param {
		public final String Name{get;set;}
		public final String Value{get;set;}
	}

	public class Applicants {
		public final Applicant Applicant{get;set;}
	}

	public class Identifiers {
		public final Identifier Identifier{get;set;}
	}

	public class Operations {
		public final List<Operation> Operation{get;set;}
	}

	public class Applicant {
		public final String ApplicantFirstName{get;set;}
		public final String ApplicantMiddleName{get;set;}
		public final String ApplicantLastName{get;set;}
		public final String Gender{get;set;}
		public final datetime DateOfBirth{get;set;}
		public final Services Services{get;set;}
		public final Identifiers Identifiers{get;set;}
		public final String ApplicantIdentifier{get;set;}
	}

	public class Services_Z {
		public final Service_Z Service{get;set;}
	}
    public class Errors {
		public final List<Error> Error{get;set;}
	}
    
    public class Error {
		public final String Message{get;set;}
		public final String Code{get;set;}
	}
    
}