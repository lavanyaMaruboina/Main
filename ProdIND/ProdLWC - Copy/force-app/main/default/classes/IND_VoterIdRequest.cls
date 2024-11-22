/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Salesforce
Description:   This class is wrapper class for the Voter ID request 
Test Class:    IND_VoterIdRequestTest
History
Date            Author              Comments
-------------------------------------------------------------
17-11-2021      Aman Mundhada       Created
------------------------------------------------------------*/
public class IND_VoterIdRequest extends ParentAPIRequest{
    //request paramaters for voter Id request
    public final String Maker_Id{get;set;}
    public final String TelephoneNumber{get;set;}
    public final String Identify_IdNumber{get;set;}
    public final String Lead_Id {get;set;}
    
    //constructor
    // @Method:      IND_VoterIdRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''    
    public IND_VoterIdRequest(RequestWrapper requestWrapper){    
        if(requestWrapper!= null){          
            this.Maker_Id=IntegrationUtilities.getMakerId();
            this.TelephoneNumber=  requestWrapper.telephoneNumber==null?'':requestWrapper.telephoneNumber; 
            this.Identify_IdNumber= requestWrapper.kycNo==null?'':requestWrapper.kycNo;  
            this.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId; 
        }
        validate(System.Label.VoterIdAPI);
    }
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Aman Mundhada
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.  
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
       Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      validate
    // @Created by:  Aman Mundhada
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed. 
    public override boolean validate(String serviceName){
        
        if(String.isBlank(this.Maker_Id)){            
            throw new IND_Exception(System.Label.MakerId);
        }
        if(String.isBlank(this.Identify_IdNumber)){
            throw new IND_Exception(System.Label.VoterIDNumber);
        }  
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }        
        return true;
    }
}