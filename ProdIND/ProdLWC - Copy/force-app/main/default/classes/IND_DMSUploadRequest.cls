/*------------------------------------------------------------
Author:        Yugandhar
Company:       Persistent Systems
Description:   This class is wrapper class for the DMSUploadRequest API request
Apex Class : IND_DMSUploadRequest for API DMSUploadRequest
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-29-2021      Yugandhar      Created
------------------------------------------------------------*/
public class IND_DMSUploadRequest extends ParentAPIRequest {
    
    
    public String Lead_Id {get;set;}
    public String FileNameWithExtension {get;set;}
    //document in base64encoded
    public String Document {get;set;}
    //docType like Pan,Adhaar,RC
    public String Document_Category {get;set;} 
    public String Document_Type {get;set;}
    
    
    // @Method:      IND_DMSUploadRequest
    // @Created by:  Yugandhar
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_DMSUploadRequest(string loanName, string docType, string docSide, string doc, string fname){  
        
        this.Lead_Id = loanName;
        this.FileNameWithExtension = fname;
        this.Document = doc;
        this.Document_Category = docType;
        this.Document_Type = docSide;
        System.debug('Lead_Id '+Lead_Id+' FileNameWithExtension '+FileNameWithExtension+' Document '+doc+' Document_Category '+Document_Category+' Document_Type '+Document_Type);
        
        validate(System.Label.DMSUpload);
    }    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Yugandhar
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Yugandhar
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        
        if(String.isBlank(this.Lead_Id)){
            throw new  IND_Exception(System.Label.UniqueNoError);
        }
        if(String.isBlank(this.FileNameWithExtension)){
            throw new  IND_Exception(System.Label.FileNameWithExtensionError);
        }
        if(String.isBlank(this.Document)){
            throw new IND_Exception(System.Label.DocumentError);
        }
        
        return true;
    }
}