/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the DocAuth Document Report response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
19-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_DocAuthDocumentReportResponse extends ParentAPIResponse {
	

	public String RequestId;
	public ResponseData ResponseData;

	public class ResponseData {
		public String Status;
		public ResponseInfo ResponseInfo;
		public Fields Fields;
	}
    
    public class ResponseInfo {
		public Integer ApplicationId;
		public String SolutionSetInstanceId;
	}

	public class Params {
		public List<Param> Param;
	}

	public class Service {
		public String Id;
		public String Name;
		public Operations Operations;
		public String Status;
	}

	public class ApplicationData {
		public Services_Z Services;
	}

	public class Data {
		public Response Response;
	}

	public class Operation {
		public String Id;
		public String Name;
		public Params Params;
		public Data Data;
		public String Status;
	}

	public class Service_Z {
		public String Id;
		public String Name;
		public String Skip;
		public String Consent;
		public String EnableSimulation;
	}

	public class Response {
		public String RawResponse;
	}

	public class Services {
		public List<Service> Service;
	}

	public class Fields {
		public Applicants Applicants;
		public ApplicationData ApplicationData;
		public String Decision;
		public String ApplicationId;
	}

	public class Param {
		public String Name;
		public String Value;
	}

	public class Applicants {
		public Applicant Applicant;
	}

	public class Operations {
		public List<Operation> Operation;
	}

	public class Applicant {
		public String ApplicantFirstName;
		public String ApplicantMiddleName;
		public String ApplicantLastName;
		public Services Services;
		public String ApplicantIdentifier;
	}

	public class Services_Z {
		public Service_Z Service;
	}
 
}