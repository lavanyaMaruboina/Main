public class ContentDocumentTriggerHandler {
    /*
    * @Method:      handleAfterDelete
    * @Created by:  Sanketkumar Patil
    * @Description: Handles all the before delete operations for ContentDocumentLink object
    * @Param:       Content Document List
    * @Return:      Void   
	*/
    public static void handleBeforeDelete(List<ContentDocument> contDocList){
        ContentDocumentTriggerHandler.updateDocumentCount(contDocList);
    }

    /*
    * @Method:      handleBeforeUpdate
    * @Created by:  Raj Gupta.
    * @Description: Restrict access Of CMU user to Upload files.
    * @Param:       Content Document List
    * @Return:      Void   
	*/
    public static void handleBeforeUpdate(List<ContentDocument> contDocList){
        // List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        // for(ContentDocument a : contDocList) {
            // CISP-3116-START
            // if(!profiles.isEmpty() && profiles[0].Name == 'CMU')
            // {
            //     a.addError('Dont have access to upload files');
            // }
            // CISP-3116-END
        // }
    }
    

    /*
    * @Method:      updateDocumentCount
    * @Created by:  Sanketkumar Patil
    * @Description: Method to update File count on KYC and Other Type Document Records
    * @Param:       Content Document List
    * @Return:      Void   
	*/
    public static void updateDocumentCount(List<ContentDocument> contDocList){
        List<Documents__c> docUpdateList = new List<Documents__c>();
        Set<Id> contentDocIdSet = new Set<Id>();
        Set<Id> documentIdSet = new Set<Id>();

        for(ContentDocument con : contDocList){
            contentDocIdSet.add(con.Id);
        }

        List<ContentDocumentLink> contDocLinkFieldList = [SELECT LinkedEntityId, LinkedEntity.recordtype.DeveloperName FROM ContentDocumentLink WHERE ContentDocumentId IN : contentDocIdSet];

        if(!contDocLinkFieldList.isEmpty()){
            for(ContentDocumentLink contDocLink : contDocLinkFieldList){
                if(contDocLink.LinkedEntity.RecordType.DeveloperName == 'Other_Documents' || contDocLink.LinkedEntity.RecordType.DeveloperName == 'KYC'){
                    documentIdSet.add(contDocLink.LinkedEntityId);           
                }
            }
        }

        System.debug('Log - contDocList:: '+ contDocList);
        System.debug('Log - contDocLinkFieldList:: '+ contDocLinkFieldList);
        System.debug('Log - documentIdSet:: ' + documentIdSet);

        List<Documents__c> docList = [SELECT Id, Content_Document_Count__c FROM Documents__c WHERE Id IN :documentIdSet WITH SECURITY_ENFORCED];        
        System.debug('Log - DocList:: '+ docList);

        if(!docList.isEmpty()){
            for(Documents__c doc : docList){
                if(doc.get('Content_Document_Count__c') != null){
                    doc.Content_Document_Count__c = doc.Content_Document_Count__c - 1;
                    docUpdateList.add(doc);
                }
            }
        }

        System.debug('Log - docUpdateList:: '+ docUpdateList);

        if(!docUpdateList.isEmpty() && Schema.sObjectType.Documents__c.isUpdateable()){ 
            update docUpdateList;
        }
    }
}