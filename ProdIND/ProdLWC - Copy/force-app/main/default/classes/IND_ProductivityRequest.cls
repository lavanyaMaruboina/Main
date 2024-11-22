/*------------------------------------------------------------
Author:        Rajat Jaiswal
Description:   This class is wrapper class for the Productivity API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
24-03-2023     Rajat Jaiswal       Created
------------------------------------------------------------*/
public class IND_ProductivityRequest extends ParentAPIRequest {
	
    public final string Emp_Id {get;set;}
    
    
    // @Method:      IND_ProductivityRequest
    // @Created by:  Rajat Jaiswal
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_ProductivityRequest(String empId,String loanAppId){  
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        this.Emp_Id = empId;
        
        
        validate(System.Label.Productivity);
    }    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Rajat Jaiswal
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Rajat Jaiswal
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){

        if(this.Emp_Id == null || String.isBlank(this.Emp_Id)){
            throw new IND_Exception(System.Label.Emp_IdError);
        }     
        
        
        return true;
    }
}