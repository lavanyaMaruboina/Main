/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the IND_ITRScanUploadInitiateRequest
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
02-02-2022    Satyam More           Created
------------------------------------------------------------*/

public class IND_ITRScanUploadInitiateRequest extends ParentAPIRequest {

    public String Lead_Id;
    public String pan;
    public String type;
    public String scanned;
    public String Maker_Id;

    //public IND_ITRScanUploadInitiateRequest(RequestWrapper requestWrapper){
    public IND_ITRScanUploadInitiateRequest(Applicant__c app, String loanAppId,String panNo){
    this.Lead_Id= app.Opportunity__r.Lead_Number__c;
    this.pan= panNo==null?'':panNo;
    this.type= 'IncomeTaxStatementUpload';
    this.scanned= 'true';
    this.Maker_Id= IntegrationUtilities.getMakerId();
        
    validate(System.Label.ITRScanUploadInitiate);
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
         if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }    
         if(String.isBlank(this.pan)){
             throw new IND_Exception(System.Label.PAN_Number);
        }      
         if(String.isBlank(this.type)){
             throw new IND_Exception(System.Label.ITRFileType);
        }    
         if(String.isBlank(this.scanned)){
             throw new IND_Exception(System.Label.ITRScannedFile);
        }   
         if(String.isBlank(this.Maker_Id)){
             throw new IND_Exception(System.Label.MakerId);
        }   
        return true;
    }
}