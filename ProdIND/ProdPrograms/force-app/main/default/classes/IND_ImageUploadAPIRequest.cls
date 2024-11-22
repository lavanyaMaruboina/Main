/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the Image Upload API request 
Test Class:    IND_ImageUploadAPIService_Test
History
Date            Author              Comments
-------------------------------------------------------------
22-11-2021      Divya Jawale       Created
------------------------------------------------------------*/
public with sharing class IND_ImageUploadAPIRequest extends ParentAPIRequest{
    //request paramaters for Image upload API request
    
    public final String Param_Val_Type {get;set;}
    public final String ImageType {get;set;}
    public final String appId {get;set;}
    public final String Maker_Id {get;set;}
    public final String fileName {get;set;}
    public final String Image {get;set;}
    
    /*
    @Method:      IND_ImageUploadAPIRequest
    @Created by:  Divya Jawale
    @Description: Contructor to initialize the details
    @Param:       String - documentId, imageType
    @Return:      '' 
    */
    public IND_ImageUploadAPIRequest(String documentId , String imageType, String loanAppId){
        if(documentId != null && imageType != null){
            
            Documents__c doc = [SELECT Id, Document_Type__c, Applicant__r.DocAuth_Application_Id__c, Opportunity_Relation__r.Lead_Number__c 
                                FROM Documents__c 
                                WHERE Id=:documentId WITH SECURITY_ENFORCED Limit 1];
            List<ContentDocumentLink> contDocLink = [SELECT ContentDocumentId, LinkedEntityId 
                                                     FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId =: doc.Id WITH SECURITY_ENFORCED];  
            
            String fileNameTemp;
            String imageTemp;
            ContentVersion cv0 =null;
            ContentVersion cv1 =null;
            if(!contDocLink.isEmpty()){
                if(imageType =='Selfie'){
                    cv0=[SELECT id,ContentDocumentId, versiondata, fileextension,Title,Document_Side_fileupload__c FROM Contentversion
                         WHERE ContentDocumentId=: contDocLink[0].ContentDocumentId WITH SECURITY_ENFORCED];
                } else {
                    if(contDocLink.size() == 2){
                        cv0=[SELECT id,ContentDocumentId, versiondata, fileextension,Title,Document_Side_fileupload__c FROM Contentversion
                             WHERE ContentDocumentId=: contDocLink[0].ContentDocumentId WITH SECURITY_ENFORCED];
                        
                        cv1=[SELECT id,ContentDocumentId, versiondata, fileextension,Title,Document_Side_fileupload__c FROM Contentversion
                             WHERE ContentDocumentId=: contDocLink[1].ContentDocumentId WITH SECURITY_ENFORCED];
                    } else {
                        cv0=[SELECT id,ContentDocumentId, versiondata, fileextension,Title,Document_Side_fileupload__c FROM Contentversion
                             WHERE ContentDocumentId=: contDocLink[0].ContentDocumentId WITH SECURITY_ENFORCED];
                    }
                } 
            }
            
            if(cv0 != null && imageType.equals(cv0.Document_Side_fileupload__c)){
                fileNameTemp = String.valueOf(cv0.Title)+'.'+cv0.fileextension;
                imageTemp= EncodingUtil.Base64Encode(cv0.VersionData);
            }
            else if(cv1 != null && imageType.equals(cv1.Document_Side_fileupload__c)){
                fileNameTemp = String.valueOf(cv1.Title)+'.'+cv1.fileextension;
                imageTemp= EncodingUtil.Base64Encode(cv1.VersionData);
            }
            system.debug('ContentVersion 0= '+cv0);
            system.debug('ContentVersion 1= '+cv1);
            String docType= doc.Document_Type__c;
            if (doc.Document_Type__c == System.Label.CustomerImageDocumentType || doc.Document_Type__c == System.Label.PanCard){
                docType = 'tax id';
            }
            if (doc.Document_Type__c == System.Label.AadhaarCard){
                docType = 'national identity card';
            }
            //CISP-3349 -- start
            if (doc.Document_Type__c == System.Label.VoterIdCard){
                docType = 'voter id';
            }
            if (doc.Document_Type__c == System.Label.DrivingLicences){
                docType = 'driving licence';
            }
            //CISP-3349 -- end
            
            if(doc != null && (cv0 != null || cv1 != null)){
                if (doc.Document_Type__c == System.Label.PassportCard){
                    this.Param_Val_Type='passport';
                }
                else{
                this.Param_Val_Type=docType.replaceAll(' ','_').toLowercase();
                }
                this.ImageType= imageType.toLowercase();
                this.appId = doc.Applicant__r.DocAuth_Application_Id__c ;
                this.Maker_Id = IntegrationUtilities.getMakerId();
                this.fileName= fileNameTemp; 
                this.Image=  imageTemp;
                    
            } 
            
        }
        validate(System.Label.ImageAPI);
    }
    
    /*Method to get the HTTP request header data
    @Method:      getHttpRequestHeaders
    @Created by:  Divya Jawale
    @Description: Method to get the HTTP request header data
    @Param:       ''
    @Return:      Header required to callout the service.
    */
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
        //requestheadermap is used to fetch the request from client
    }    
    
    /*Method to validate the request data
    @Method:      validate
    @Created by:  Divya Jawale
    @Description: Method to validate the required input details
    @Param:       Service name
    @Return:      True - If all the validations are passed.
    */
    public override boolean validate(String serviceName){
        List<String> errorMessageList = new List<String>();
        if(String.isBlank(this.Param_Val_Type)){
            throw new IND_Exception(System.Label.DocumentType);
        }
        if(String.isBlank(this.ImageType)){
            throw new IND_Exception(System.Label.ImageType);
        }
        if(String.isBlank(this.appId)){
            throw new IND_Exception(System.Label.AppId);
        }
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        }
        if(String.isBlank(this.fileName)){
            throw new IND_Exception(System.Label.ImageFileName);
        }
        if(String.isBlank(this.Image)){
            throw new IND_Exception(System.Label.ImageUpload);
        }
        
        return true;
    }
}