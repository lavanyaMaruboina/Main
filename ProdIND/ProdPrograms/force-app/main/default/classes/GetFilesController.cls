/**
  @description Gets related files for a record
  @author Prashant
**/
public without sharing class GetFilesController {
    /**
      @description get related latest contentVersions of all Content documents given a record id
      @param recordId Id of the record to be fetched
      @return list of file wrapper objects, each representing a content version
    **/
    /**
      @description get related latest contentVersions of all Content documents given a record id
      @param recordId Id of the record to be fetched
      @return list of file wrapper objects, each representing a content version
    **/
    @AuraEnabled(cacheable=true)
    public static string getUserRole(Id recordId){
      try {
        if(recordId!=null){
          List<User> currentUser = [SELECT Id,UserRole.Name FROM User WHERE Id=:recordId Limit 1];
          if(!currentUser.isEmpty()){
            return currentUser[0].UserRole.Name;
          }
        }
        return null;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
    @AuraEnabled(cacheable=true)
    public static FilesWrapper[] getFilesList(Id recordId) {
      /*{{{*/
  
      if(recordId != null){
        List<Documents__c> document = [SELECT Id,Document_Type__c,RecordTypeId,RecordType.Name FROM Documents__c WHERE Id =:recordId LIMIT 1];
        if(!document.isEmpty()){
          FilesWrapper[] filesList = new List<FilesWrapper>{};
          for (ContentDocumentLink link : [
            SELECT
              ContentDocumentId,
              ContentDocument.LatestPublishedVersion.Title,
              ContentDocument.LatestPublishedVersion.CreatedDate,
              ContentDocument.LatestPublishedVersion.CreatedBy.Name
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
          ]) {
            filesList.add(
              new FilesWrapper(
                link.ContentDocumentId,
                link.ContentDocument.LatestPublishedVersion.Title,
                link.ContentDocument.LatestPublishedVersion.CreatedBy.Name,
                Date.valueOf(link.ContentDocument.LatestPublishedVersion.CreatedDate),
                link.ContentDocument.LatestPublishedVersionId,
                document[0].Document_Type__c,
                document[0].RecordType.Name,
                document[0].RecordTypeId
              )
            );
          }
        return filesList;
      }
        
      }
      return null;
      
    } /*}}}*/
  
    // /**
    //   @description get details of contentversions for a content document
    //   @param recordId Id of the content document whose version details are to be fetched
    //   @return list of file version wrapper objects, each representing a content version
    // **/
    // @AuraEnabled
    // public static FileVersionWrapper[] getFileVersionDetails(Id fileId) {
    //   /*{{{*/
    //   FileVersionWrapper[] contentversions = new List<FileVersionWrapper>{};
    //   for (ContentVersion cv : [SELECT title, createddate, createdby.name, ReasonForChange FROM ContentVersion WHERE ContentDocumentId = :fileId]) {
    //     contentVersions.add(new FileVersionWrapper(cv.Id, cv.title, cv.createdby.name, Date.valueOf(cv.createddate), cv.ReasonForChange));
    //   }
    //   return contentVersions;
    // } /*}}}*/
  
    public class FilesWrapper /*{{{*/ {
      @AuraEnabled
      public String id { get; set; }
      @AuraEnabled
      public String title { get; set; }
      @AuraEnabled
      public String createdBy { get; set; }
      @AuraEnabled
      public Date createdDate { get; set; }
      @AuraEnabled
      public String latestVersionId { get; set; }
      @AuraEnabled
      public String documentType { get; set; }
      @AuraEnabled
      public String recordTypeName { get; set; }
      @AuraEnabled
      public String recordTypeId { get; set; }
  
      public FilesWrapper(String id, String title, String createdBy, Date createdDate, String latestVersionId, String documentType, String recordTypeName, String recordTypeId) {
        this.id = id;
        this.title = title;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
        this.latestVersionId = latestVersionId;
        this.documentType = documentType;
        this.recordTypeName = recordTypeName;
        this.recordTypeId = recordTypeId;
      }
    } /*}}}*/
  
    public class FileVersionWrapper /*{{{*/ {
      @AuraEnabled
      public String id { get; set; }
      @AuraEnabled
      public String title { get; set; }
      @AuraEnabled
      public String createdBy { get; set; }
      @AuraEnabled
      public Date createdDate { get; set; }
      @AuraEnabled
      public String reasonForChange { get; set; }
  
      public FileVersionWrapper(String id, String title, String createdBy, Date createdDate, String reasonForChange) {
        /*{{{*/
        this.id = id;
        this.title = title;
        this.createdBy = createdBy;
        this.createdDate = createdDate;
        this.reasonForChange = reasonForChange;
      } /*}}}*/
    } /*}}}*/
  
    // @AuraEnabled
    // public static Id createContentDocLink(Id contentVersionId, Id recordId) {
    //   Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId].ContentDocumentId;
    //   insert new ContentDocumentLink(ContentDocumentId = docId, LinkedEntityId = recordId);
    //   return docId;
    // }

    @AuraEnabled
    public static Boolean isKYCDocument(String documentId){
      try {
        if(documentId != null){
          List<Documents__c> documentList = [SELECT Id,RecordType.Name FROM Documents__c WHERE Id =: documentId Limit 1];
          if(documentList.size() > 0){
            return documentList[0].RecordType.Name == 'KYC Document';
          }
        }
        return false;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
    @AuraEnabled
    public static void deleteFile(String contentDocumentId, String linkedEntityId){
      try {
        if(contentDocumentId != null && linkedEntityId != null){
          List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId =: linkedEntityId];
          if(contentDocumentLinkList.size() > 0){
            delete contentDocumentLinkList;
          }
        }
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
    @AuraEnabled
    public static boolean isResiDocument(String documentId){
      try {
        if(documentId != null){
          String resiRecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId();
          List<Documents__c> resiDocumentList = new List<Documents__c>([SELECT Id FROM Documents__c WHERE Id =: documentId AND  Document_Type__c = 'Resi Profile Document' AND RecordTypeId =: resiRecordTypeId LIMIT 1]);
          if(resiDocumentList.size() > 0){
            List<User> userList = [SELECT Id,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            if(userList.size() > 0 && userList[0].Profile.Name == 'IBL TF RCU Agent'){
              return true;
            }
          }
        }
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
      return false;
    }
  }