/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Text Match Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
09-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_TextMatchRequest extends ParentAPIRequest{
    //request paramaters for  TextMatchAPI request
    public final String Lead_Id {get;set;}
    public final String Maker_Id {get;set;}
    public Fields Fields {get;set;}
    public class Fields{
        public Applicants Applicants {get;set;}
    }
    public class Applicants{
        public Applicant Applicant {get;set;}
    }
    public class Applicant{
        public final String ApplicantFirstName {get;set;}
        public final String ApplicantMiddleName {get;set;}  
        public final String ApplicantLastName {get;set;}
        public Services Services {get;set;}
    }
    public class Services{
        public Service Service{get;set;}
    }
    public class Service{
        public Operations Operations{get;set;}
    }
    public class Operations{
        public List<Operation> Operation {get;set;}
    }
    public class Operation{
        public Params Params{get;set;}
    } 
    public class Params{
        public List<Param> Param {get;set;}  
    }
    public class Param{
        public String Name{get;set;} 
        public Value Value {get;set;}
    }
    public class Value{
        public DestinationSources DestinationSources {get;set;}
    }
    public class DestinationSources{
        public DestinationSource DestinationSource {get;set;}
    }
    public class DestinationSource{
        public String DestinationName{get;set;}
        public Names Names {get;set;}
    }
    public class Names{
        public String Name{get;set;}
    }
    
    //constructor
    // @Method:      IND_TextMatchRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    //
    
    public  IND_TextMatchRequest(RequestWrapper requestWrapper){
        if( requestWrapper != null){
            this.Lead_Id=requestWrapper.leadId;
            this.Maker_Id=IntegrationUtilities.getMakerId();
            this.Fields = new Fields();
            
            this.Fields.Applicants= new Applicants();
            Applicants applicants = new Applicants(); 
            this.Fields.Applicants.Applicant= new Applicant();
            Applicant applicant = new Applicant();
            applicant.ApplicantFirstName=requestWrapper.applicantFirstName;
            applicant.ApplicantMiddleName=requestWrapper.applicantMiddleName;
            applicant.ApplicantLastName=requestWrapper.applicantLastName;
            applicants.applicant=applicant;
            fields.applicants=applicants;
            
            this.Fields.Applicants.Applicant.Services = new Services();
            Services services = new Services();
            this.Fields.Applicants.Applicant.Services.Service = new Service();
            Service service = new Service();
            this.Fields.Applicants.Applicant.Services.Service.Operations = new Operations();
            Operations operations = new Operations();
            List<Operation> operationList = new List<Operation>();
            Operation operation = new Operation();
            operationList.add(operation);
            operations.operation=operationList;
            fields.applicants.applicant.services.service.operations=operations;
            
            this.Fields.Applicants.Applicant.Services.Service.Operations.Operation[0].Params = new Params();
            Params params = new Params();
            List<Param> paramList = new List<Param>();
            Param param = new Param();
            param.name = system.label.DestinationSources; //requestWrapper.name;
            paramList.add(param);
            params.param=paramList;
            fields.applicants.applicant.services.service.operations.operation[0].params=params;
            
            this.Fields.Applicants.Applicant.Services.Service.Operations.Operation[0].Params.Param[0].Value = new Value();
            Value value = new Value();
            this.Fields.Applicants.Applicant.Services.Service.Operations.Operation[0].Params.Param[0].Value.DestinationSources = new DestinationSources();
            DestinationSources destinationSources = new DestinationSources();
            this.Fields.Applicants.Applicant.Services.Service.Operations.Operation[0].Params.Param[0].Value.DestinationSources.DestinationSource = new DestinationSource();
            DestinationSource destinationSource = new DestinationSource();
            destinationSource.DestinationName = system.label.GoldenSource; //requestWrapper.destinationName;
            destinationSources.destinationSource=destinationSource;
            fields.applicants.applicant.services.service.operations.operation[0].params.param[0].value.destinationSources=destinationSources;
            
            this.Fields.Applicants.Applicant.Services.Service.Operations.Operation[0].Params.Param[0].Value.DestinationSources.DestinationSource.Names= new Names();
            Names names = new Names();
            names.name = requestWrapper.destinationNames;
            fields.applicants.applicant.services.service.operations.operation[0].params.param[0].value.destinationSources.destinationSource.names=names;
            
        }
        validate(System.Label.TextMatch);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        List<String> errorMessageList = new List<String>();
        
        if(String.isBlank(this.Lead_Id)){
            ErrorLoggerUtil.logErrorEvent('IND_TextMatchRequest', 'validate', System.Label.Apex, new AuraHandledException(System.Label.LeadId));
            throw new IND_Exception(System.Label.LeadId);
        }
        return true;
    }
}