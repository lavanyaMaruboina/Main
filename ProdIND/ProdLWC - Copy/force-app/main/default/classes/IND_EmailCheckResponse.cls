/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Email Check response
Test Class: IND_EmailCheckService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
30-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_EmailCheckResponse extends ParentAPIResponse {
    
    @AuraEnabled public final String RequestId;
    @AuraEnabled public final ResponseData ResponseData;
    
    public class ResponseData {
        @AuraEnabled public final String Status;
        @AuraEnabled public final ResponseInfo ResponseInfo;
        @AuraEnabled public final Fields Fields;
    }
    
    public class ResponseInfo {
        @AuraEnabled public final Integer ApplicationId;
        @AuraEnabled public final String SolutionSetInstanceId;
    }
    
    public class Response_Z {
        @AuraEnabled public final DREmailVerification DREmailVerification;
        @AuraEnabled public final DSEmailVerification DSEmailVerification;
        @AuraEnabled public final DSEmailVerificationData DSEmailVerificationData;
        @AuraEnabled public final DSEmailVerificationStatus DSEmailVerificationStatus;
    }
    
    public class Params {
        @AuraEnabled public final List<Param> Param;
    }
    
    public class Service {
        @AuraEnabled public final String Id;
        @AuraEnabled public final String Name;
        @AuraEnabled public final Operations Operations;
        @AuraEnabled public final String Status;
    }
    
    public class ApplicationData {
        @AuraEnabled public final Services_Z Services;
    }
    
    public class Data {
        @AuraEnabled public final String RawResponse;
        @AuraEnabled public final Integer Status;
        @AuraEnabled public final String GatewayTransactionId;
    }
    
    public class Operation {
        @AuraEnabled public final String Id;
        @AuraEnabled public final String Name;
        @AuraEnabled public final Params Params;
        @AuraEnabled public final Data_Z Data;
        @AuraEnabled public final String Status;
    }
    
    public class DSEmailVerification {
        @AuraEnabled public final String RequestDateTime;
        @AuraEnabled public final String BasicCheckStatus;
        @AuraEnabled public final String BasicCheckStatusCode;
        @AuraEnabled public final String LongevityScore;
        @AuraEnabled public final String VelocityScore;
        @AuraEnabled public final String PopularityScore;
        @AuraEnabled public final String DateFirstSeen;
        @AuraEnabled public final String BasicCheckStatusCodeDesc;
    }
    
    public class Service_Z {
        @AuraEnabled public final String Id;
        @AuraEnabled public final String Name;
        @AuraEnabled public final String Skip;
        @AuraEnabled public final String Consent;
    }
    
    public class Response {
        @AuraEnabled public final String Success;
        @AuraEnabled public final Data Data;
    }
    
    public class Services {
        @AuraEnabled public final List<Service> Service;
    }
    
    public class Data_Z {
        @AuraEnabled public final Response_Z Response;
    }
    
    public class Fields {
        @AuraEnabled public final Applicants Applicants;
        @AuraEnabled public final ApplicationData ApplicationData;
        @AuraEnabled public final String Decision;
        @AuraEnabled public final String ApplicationId;
    }
    
    public class DSEmailVerificationData {
        @AuraEnabled public final String Request;
        @AuraEnabled public final Response Response;
    }
    
    public class Param {
    }
    
    public class Applicants {
        @AuraEnabled public final Applicant Applicant;
    }
    
    public class DREmailVerification {
        @AuraEnabled public final Boolean IsEmailValid;
        @AuraEnabled public final String IsEmailBlackListCheckSuccess;
        @AuraEnabled public final String IsBlackListedEmailDomain;
        @AuraEnabled public final String IsBlackListedEmailAddress;
        @AuraEnabled public final String IsEmailAPICallSuccess;
        @AuraEnabled public final String APIResponseInMS;
    }
    
    public class DSEmailVerificationStatus {
        @AuraEnabled  public final String Outcome;
        @AuraEnabled  public final String IsSuccess;
    }
    
    public class Operations {
        @AuraEnabled  public final List<Operation> Operation;
    }
    
    public class Applicant {
        @AuraEnabled public final String EmailAddress;
        @AuraEnabled public final Services Services;
        @AuraEnabled public final String ApplicantIdentifier;
    }
    
    public class Services_Z {
        @AuraEnabled  public final Service_Z Service;
    }
    
    
}