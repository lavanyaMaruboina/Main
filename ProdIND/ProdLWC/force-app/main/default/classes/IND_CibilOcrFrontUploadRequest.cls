/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the CIBIL OCR Front Upload Request
Test Class: IND_CibilOcrFrontUploadService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
27-10-2021    Satyam More            Created
------------------------------------------------------------*/

public with sharing class IND_CibilOcrFrontUploadRequest extends ParentAPIRequest  {
    //request paramaters for CIBIL OCR Front Upload request
    public final String Lead_Id{get;set;}
    public final String FileBase64{get;set;}
    public final String FileType{get;set;}
    public final String Identify_IdType{get;set;}
    public final String outputImageBase64{get;set;}
    public final String maskAadhaarText{get;set;}
    public final String maskAadhaar{get;set;}
    public final String maker_Id{get;set;}
    
    //constructor
    // @Method:      IND_CibilOcrFrontUploadRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Document
    // @Return:      ''
    
    public IND_CibilOcrFrontUploadRequest(Documents__c doc, String contentDocumentId,String loanAppId){
        if( doc != null){
            
            Set<Id> docIdSet = new Set<Id>();
            for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: doc.Id WITH SECURITY_ENFORCED]){
                docIdSet.add(contentdoc.ContentDocumentId);
            }
            ContentVersion cv=[SELECT Id,ContentDocumentId, Versiondata, Fileextension,Document_Side_fileupload__c from Contentversion where ContentDocumentId =: contentDocumentId AND Document_Side_fileupload__c= 'Front'  WITH SECURITY_ENFORCED ];
            system.debug('cv '+cv.ContentDocumentId);
            this.Lead_Id = doc.Opportunity_Relation__r.Lead_Number__c; 
            this.FileBase64 = EncodingUtil.Base64Encode(cv.VersionData); 
            this.FileType = String.valueOf(cv.FileExtension);
            if (doc.Document_Type__c == System.Label.DrivingLicences){
                this.Identify_IdType = System.Label.DrivingLicenceIdType;    
                this.outputImageBase64 = System.Label.TrueRespose; 
                this.maskAadhaarText = System.Label.TrueRespose; 
                this.maskAadhaar = System.Label.FalseRespose;
            }
            else if (doc.Document_Type__c == System.Label.PassportCard){
                this.Identify_IdType = System.Label.PassportIdType;    
                this.outputImageBase64 = System.Label.FalseRespose; 
                this.maskAadhaarText = System.Label.FalseRespose; 
                this.maskAadhaar = System.Label.FalseRespose;
            }
            else if (doc.Document_Type__c == System.Label.PAN_Picklist){
                this.Identify_IdType = System.Label.PantIdType;    
                this.outputImageBase64 = System.Label.FalseRespose;  
                this.maskAadhaarText = System.Label.FalseRespose; 
                this.maskAadhaar = System.Label.FalseRespose;
            }
            else if (doc.Document_Type__c == System.Label.VoterIdCard){
                this.Identify_IdType = System.Label.VoterIdType;    
                this.outputImageBase64 = System.Label.FalseRespose; 
                this.maskAadhaarText = System.Label.FalseRespose; 
                this.maskAadhaar = System.Label.FalseRespose;
            }
            else if (doc.Document_Type__c == System.Label.AadhaarCard){
                this.Identify_IdType = System.Label.AadhaarIdType;    
                this.outputImageBase64 = System.Label.TrueRespose; 
                this.maskAadhaarText = System.Label.FalseRespose; 
                this.maskAadhaar = System.Label.TrueRespose;
            }
            this.maker_Id = IntegrationUtilities.getMakerId();
        }
        validate(System.Label.OCRFront);
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
    // @Method:      validate
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        List<String> errorMessageList = new List<String>();
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.FileBase64)){
            throw new IND_Exception(System.Label.ImageUpload);
        }
        if(String.isBlank(this.FileType)){
            throw new IND_Exception(System.Label.ImageFileType);    
        }
        if(String.isBlank(this.Identify_IdType)){
            throw new IND_Exception(System.Label.OCRFileType);
        }
        if(String.isBlank(this.outputImageBase64)){
            throw new IND_Exception(System.Label.OCROutputImage);
        }
        if(String.isBlank(this.maskAadhaarText)){
            throw new IND_Exception(System.Label.OCRMaskAadhaarText);
        }
        if(String.isBlank(this.maskAadhaar)){
            throw new IND_Exception(System.Label.OCRMaskAadhaarComplete);
        }       
        if(String.isBlank(this.maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        }
        
        return true; 
    }
}