/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the Driving License response
Test Class: IND_DrivingLicenseService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
10-11-2021    Aman Mundhada            Created
------------------------------------------------------------*/


public class IND_DrivingLicenseResponse extends ParentAPIResponse {
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
		public final String Building{get;set;}
		public final String City{get;set;}
		public final String Pin{get;set;}
		public final String District{get;set;}
		public final String Floor{get;set;}
		public final String House{get;set;}
		public final String locality{get;set;}
		public final String Complex{get;set;}
		public final String State{get;set;}
		public final String Landmark{get;set;}
		public final String Untagged{get;set;}
		public final String CO{get;set;}
		public final String Street{get;set;}
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
		public final String DateOfBirth{get;set;}
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