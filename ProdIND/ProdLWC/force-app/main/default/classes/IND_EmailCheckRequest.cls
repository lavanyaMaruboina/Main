/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Email Check Request
Test Class: IND_EmailCheckService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
30-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_EmailCheckRequest extends ParentAPIRequest {
    //request paramaters for Email Check Request
    public final String Lead_Id{get;set;}
    public final String Email{get;set;}
    public final String Maker_Id{get;set;}
    
    //constructor
    // @Method:      IND_EmailCheckRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    
    public IND_EmailCheckRequest(RequestWrapper requestWrapper,String loanAppId){
        if( requestWrapper != null){
            this.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId; 
            this.Email = requestWrapper.email==null?'':requestWrapper.email; 
            this.Maker_Id = IntegrationUtilities.getMakerId(); 
            //fetching details from Request Wrapper
        }
        validate(System.Label.EmailCheck);
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
        
        if(String.isBlank(this.Email)){
            throw new IND_Exception(System.Label.EnterEmailAddress);            
        }       
        return true;
    }
}