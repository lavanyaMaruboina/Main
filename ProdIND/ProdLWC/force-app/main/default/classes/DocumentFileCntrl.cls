public class DocumentFileCntrl {

    @AuraEnabled
    public static String getRelatedFile(String docId){
        Map<String,Object> mapData = new Map<String,Object>();
        Set<Id> contentDocId = new Set<Id>();
        String contentDocList='';
        String contentVersionList='';
        if(docId != null){
            for(ContentDocumentLink conDoc : [Select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId =:docId ]){
                contentDocId.add(conDoc.ContentDocumentId);
            }
        }
        if(docId != null){
            contentDocList ='SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:docId' ;
            mapData.put('contentDocId',Database.query(contentDocList));
        }
        if(contentDocId.size()>0){
            contentVersionList ='SELECT Id, VersionData, FileType, Title, FileExtension,IsLatest, ContentDocumentId, ContentDocument.FileType,LastModifiedDate,Document_Side_fileupload__c  FROM   ContentVersion WHERE  ContentDocumentId in: contentDocId and isLatest = true' ;
            mapData.put('contentVersionList',Database.query(contentVersionList));
        }
        return JSON.serialize(mapData);
    }

    /*
   * @Method Name: getRelatedDocumentDetails
   * @Created by:  Rajat Jaiswal
   * @description: To get current document and user Profile details and many more
   * @Param:       String - docId
   */
    @AuraEnabled
    public static DocumentDataWrapper getRelatedDocumentDetails(String docId){
        try {
            DocumentDataWrapper wrapperObj = new DocumentDataWrapper();
            String currentProfileId = UserInfo.getProfileId();
            List<Profile> profileList = [Select Name FROM Profile WHERE Id=:currentProfileId LIMIT 1];
            wrapperObj.userProfileName = profileList[0].Name;
            List<Documents__c> docList = [Select Id, Document_Type__c, Opportunity_Relation__c FROM Documents__c WHERE Id =: docId LIMIT 1];
            wrapperObj.DocumentRecord = docList[0]; 
            String loanApplicationId = docList[0].Opportunity_Relation__c;
            if (loanApplicationId!=null) {
                List<Retry_Count__c> retryCountFrontList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c =: System.Label.CMU_Front AND User_Id__c =: UserInfo.getUserId()];
                if (retryCountFrontList.size() > 0 && !retryCountFrontList.isEmpty()) {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.CMU_OCR);
                    if (retryCountFrontList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                      wrapperObj.haveFrontAttemt = false; 
                    }else{
                        wrapperObj.haveFrontAttemt = true; 
                    }
                }else{
                    wrapperObj.haveFrontAttemt = true; 
                }
                List<Retry_Count__c> retryCountBackList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c =: System.Label.CMU_Back AND User_Id__c =: UserInfo.getUserId()];
                if (retryCountBackList.size() > 0 && !retryCountBackList.isEmpty()) {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.CMU_OCR);
                    if (retryCountBackList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                      wrapperObj.haveBackAttempt = false; 
                    }else{
                        wrapperObj.haveBackAttempt = true; 
                    }
                }else{
                    wrapperObj.haveBackAttempt = true; 
                }
            }
            return wrapperObj;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' DocumentFileCntrl ', ' getRelatedDocumentDetails ', 'System.Label.Apex', e);
            throw new AuraHandledException('Something went wrong: '+ e.getMessage()); 
        }
    }

 /*
   * @Method Name: deleteDocumentRecord
   * @Created by:  Rajat Jaiswal
   * @description: To delete document which is not masked after getting masked document from OCR API.
   * @Param:       String - documentId
   * @Param:       String - contentDocumentIds
   */
    @AuraEnabled
    public static void deleteDocumentRecord(String documentId,String contentDocumentIds){
        try{
            if (contentDocumentIds!=null) {
                List<String> contentDocumentIdList = (List<String>)JSON.deserialize(contentDocumentIds, List<String>.class);
                List<ContentDocument> contentDocuments = new List<ContentDocument>();
                
                if (documentId!=null) {
                    for(ContentDocumentLink documentList:[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink  where LinkedEntityId=:documentId AND ContentDocumentId IN : contentDocumentIdList]){
                        contentDocuments.add(new ContentDocument(id=documentList.ContentDocumentId));
                    } 
                }
                if (Schema.sObjectType.ContentDocument.isAccessible() && Schema.sObjectType.ContentDocument.isDeletable() ){
                    delete contentDocuments;
                }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(' DocumentFileCntrl ', ' deleteDocumentRecord ', 'System.Label.Apex', e);
            throw new AuraHandledException('Something went wrong: '+ e.getMessage()); 
        }
    }   

 /*
   * @Method Name: retryCountIncrease
   * @Created by:  Rajat Jaiswal
   * @description: To store retry count details.
   * @Param:       String - Loan Application Id
   * @Param:       String - Service Name
   */
  @AuraEnabled
  public static Boolean retryCountIncrease(String loanApplicationId, String serviceName) {
    try {
        if (loanApplicationId != null) {
            List<Opportunity> loanApplications = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
            List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :serviceName AND User_Id__c =: UserInfo.getUserId() LIMIT 1];
            if (!retryCountList.isEmpty()) {
                System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.CMU_OCR);
                retryCountList[0].Count__c = retryCountList[0].Count__c == null ? 0 : retryCountList[0].Count__c;
                if (retryCountList[0].Count__c < metadata.Number_Of_Attempts__c) {
                    retryCountList[0].Count__c += 1;
                    if (Schema.sObjectType.Retry_Count__c.isUpdateable()) {
                        update retryCountList;
                    }else {
                        throw new AuraHandledException(System.label.Retrycountnotinserted);
                    }
                    if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                        return true;
                    }
                }
            } else {
                Retry_Count__c retryCount = new Retry_Count__c();
                retryCount.Loan_Application_Id__c = loanApplicationId;
                retryCount.Service_Name__c = serviceName;
                retryCount.Module__c = loanApplications[0].StageName;
                retryCount.User_Id__c = UserInfo.getUserId();
                retryCount.Count__c = 1;
                if (Schema.sObjectType.Retry_Count__c.isCreateable()) {
                    insert retryCount;
                } else {
                    throw new AuraHandledException(System.label.Retrycountnotinserted);
                }
            }
        }
        return false;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('DocumentFileCntrl', 'retryCountIncrease', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
  /*
   * @Method Name: getImageFile
   * @Created by:  Rohan Saxena
   * @description: To fetch Image doc content id //CISP-4143
   * @Param:       String - Document Id
   */
    @AuraEnabled
    public static String getImageFile(String docId){
            Map<String, Object> mapData = new Map<String, Object>();
            Set<Id> contentDocId = new Set<Id>();
            String contentDocList='';
            String contentVersionList='';
            List<Documents__c> lstIMGdoc;
            Documents__c doc;
            if(!String.isBlank(docId)){
                doc=[SELECT Id,Name, Applicant__c FROM Documents__c WHERE Id=:docId];
                if(doc.Name !='Customer Image'){
                    lstIMGdoc=[SELECT Id FROM Documents__c WHERE Applicant__c =:doc.Applicant__c AND Name='Customer Image' LIMIT 1];
                }
            }
            if(lstIMGdoc[0].Id != null){
                for(ContentDocumentLink conDoc : [Select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId =:lstIMGdoc[0].Id ]){
                    contentDocId.add(conDoc.ContentDocumentId);
                }
            }
            if(lstIMGdoc[0].Id != null){
                String lstIMGDocId = lstIMGdoc[0].Id;
                contentDocList ='SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:lstIMGDocId' ;
                mapData.put('contentDocId',Database.query(contentDocList));
            }
            if(contentDocId.size()>0){
                contentVersionList ='SELECT Id, VersionData, FileType, Title, FileExtension,IsLatest, ContentDocumentId, ContentDocument.FileType,LastModifiedDate,Document_Side_fileupload__c FROM ContentVersion WHERE ContentDocumentId in: contentDocId and isLatest = true' ;
                mapData.put('contentVersionList',Database.query(contentVersionList));
            }
            return JSON.serialize(mapData);
    }
/*
   * @Method Name: getPOIdetails
   * @Created by:  Rohan Saxena
   * @description: To fetch POI document details //CISP-4635
   * @Param:       String - Document Id
   */
  @AuraEnabled
  public static Documents__c getPOIdetails(String docId){
      try{
          List<Documents__c> lstPOIDoc;
          Documents__c doc;
          if(!String.isBlank(docId)){
              doc=[SELECT Id,Name, Applicant__c FROM Documents__c WHERE Id=:docId];
              lstPOIDoc=[SELECT Id, Gender__c, Salutation__c FROM Documents__c WHERE Applicant__c =:doc.Applicant__c AND Proof_of_Identity_POI__c = true Limit 1];
              if(!lstPOIDoc.isEmpty()){
                return lstPOIDoc[0];
              }
          }
          return null;
      }
      catch (Exception e) {
          ErrorLoggerUtil.logErrorEvent('DocumentFileCntrl', 'getPOIdetails', System.Label.Apex, e);
          throw new AuraHandledException(System.Label.ExceptionMessage);
      }
  }
    
/*
   * @Wrapper Name: DocumentDataWrapper
   * @Created by:  Rajat Jaiswal
   * @description: This wrapper is used for storing values from Document.
   */
    public class DocumentDataWrapper{
        @auraenabled public string userProfileName;
        @auraenabled public Documents__c DocumentRecord;
        @auraenabled public Boolean haveFrontAttemt;
        @auraenabled public Boolean haveBackAttempt;
    }
}