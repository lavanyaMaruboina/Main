/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Text Match response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
09-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_TextMatchResponse extends ParentAPIResponse {
    
    public String RequestId{get;set;}
	public ResponseData ResponseData{get;set;}

	public class ApplicationData {
		public Services_Z Services{get;set;}
	}

	public class Operation {
		public String Id{get;set;}
		public Params Params{get;set;}
		public String Name{get;set;}
		public Data Data{get;set;}
		public String Status{get;set;}
	}

	public class Source {
		public String SourceName{get;set;}
		public Name Name{get;set;}
		public FatherName FatherName{get;set;}
		public String NameMatch{get;set;}
		public String FatherNameMatch{get;set;}
		public String AddressMatch{get;set;}
		public String DobMatch{get;set;}
		public String PhoneMatch{get;set;}
		public String GenderMatch{get;set;}
		public String IDMatch{get;set;}
		public String EmailMatch{get;set;}
	}

	public class Name {
		public String FirstName{get;set;}
		public String LastName{get;set;}
	}

	public class Names {
		public String Name{get;set;}
	}

	public class Applicants {
		public Applicant Applicant{get;set;}
	}

	public class MatchService {
		public List<Source> Source{get;set;}
	}

	public class Operations {
		public List<Operation> Operation{get;set;}
	}

	public class Services_Z {
		public Service_Z Service{get;set;}
	}

	public class RawResponse {
		public MatchService MatchService{get;set;}
	}

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
		public Operations Operations{get;set;}
		public String Skip{get;set;}
		public String Consent{get;set;}
		public String Status{get;set;}
		public String Name{get;set;}
	}

	public class Data {
		public Response Response{get;set;}
	}

	public class Service_Z {
		public String Id{get;set;}
		public String Skip{get;set;}
		public String Consent{get;set;}
		public String Name{get;set;}
	}

	public class Response {
		public RawResponse RawResponse{get;set;}
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

	public class Value {
		public List<DestinationSource> DestinationSource{get;set;}
	}

	public class Param {
		public String Name{get;set;}
		public Value Value{get;set;}
	}

	public class DestinationSource {
		public String DestinationName{get;set;}
		public Names Names{get;set;}
		public Object FatherName{get;set;}
		public Object DateOfBirth{get;set;}
		public Object Gender{get;set;}
		public Object EmailAddresses{get;set;}
		public Object Telephones{get;set;}
		public Object Addresses{get;set;}
		public Object Identifiers{get;set;}
	}

	public class Applicant {
		public String ApplicantFirstName{get;set;}
		public String ApplicantMiddleName{get;set;}
		public String ApplicantLastName{get;set;}
		public Services Services{get;set;}
		public String ApplicantIdentifier{get;set;}
	}

	public class FatherName {
		public String FirstName{get;set;}
		public String MiddleName{get;set;}
		public String LastName{get;set;}
	}
}