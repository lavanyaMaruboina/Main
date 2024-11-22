/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Pan Verification Request
Test Class: IND_PANVerficationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
20-10-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_PanVerificationRequest extends ParentAPIRequest {
    //request paramaters for PAN Verification request
    public final String Reference_No{get;set;}
    public final String PAN{get;set;}
    public final String Applicant_FirstName{get;set;}
    public final String Applicant_MiddleName{get;set;}
    public final String Applicant_LastName{get;set;}
    
    //constructor
    // @Method:      IND_PanVerificationRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    // 
    public IND_PanVerificationRequest(RequestWrapper requestWrapper){
        if( requestWrapper != null){
            this.Reference_No = requestWrapper.leadId ==null?'':requestWrapper.leadId;
            this.PAN = requestWrapper.panNumber==null?'':requestWrapper.panNumber ; 
            this.Applicant_FirstName = requestWrapper.firstName ==null?'':requestWrapper.firstName ;
            this.Applicant_MiddleName ='';
            this.Applicant_LastName = requestWrapper.lastName==null?'':requestWrapper.lastName ;
        }
        validate(System.Label.PANVerificationAPI);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    //Method to get the HTTP request header data
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
        
        if(String.isBlank(this.PAN)){
            throw new IND_Exception(System.Label.PAN_Number);            
        }
        if(String.isBlank(this.Applicant_FirstName)){
            throw new IND_Exception(System.Label.ApplicantFirstName);    
        }
        if(String.isBlank(this.Applicant_LastName)){
            throw new IND_Exception(System.Label.ApplicantLastName);
        }    
        return true;
    }
}