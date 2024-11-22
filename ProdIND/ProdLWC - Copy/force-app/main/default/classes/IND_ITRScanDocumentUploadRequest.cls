/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the IND_ITRScanDocumentUploadRequest
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
07-02-2022    Satyam More           Created
------------------------------------------------------------*/
public class IND_ITRScanDocumentUploadRequest extends ParentAPIRequest{
public String File;
    public String documentType;

    //public IND_ITRScanUploadInitiateRequest(RequestWrapper requestWrapper){
    public IND_ITRScanDocumentUploadRequest(Documents__c doc, String contentDocumentId,String perfiosTransactionId ,String loanAppId){
        
    ContentDocumentLink  contDocLink = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =: doc.Id];  
    ContentVersion cv=[SELECT Id,ContentDocumentId, pathonclient, versiondata, fileextension from Contentversion where ContentDocumentId=: contentDocumentId];    
    
    //String pdffile = Encodingutil.base64Decode(cv.PathOnClient);
    Blob itrfile = cv.VersionData ;
    this.File= String.valueOf(itrfile) ;//Blob.valueOf(Encodingutil.base64Decode(cv.FileExtension)+Encodingutil.base64Encode(cv.VersionData)); //Blob.valueOf(Encodingutil.base64Encode(cv.versiondata)+cv.PathOnClient+cv.FileExtension);//app.Opportunity__r.Lead_Number__c; //'AC12434_12421243'; // requestWrapper.leadId==null?'':requestWrapper.leadId; 
    this.documentType= 'SCANNED_ITR '; //app.PAN_No__c; //'BNIPM6633A';//IntegrationUtilities.getMakerId();
        
    validate(System.Label.ITRScanDocumentUpload);
  }

//Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        requestHeaderMap.put('Content-Type', 'multipart/form-data');
        requestHeaderMap.put('Content-Disposition', 'name="file"');
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){
        /* if(Blob.isBlank(this.File)){
            throw new IND_Exception(System.Label.LeadId);
        }*/    
         if(String.isBlank(this.documentType)){
             throw new IND_Exception(System.Label.PAN_Number);
        }      
          
        return true;
    }
}