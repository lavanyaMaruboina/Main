public class Fileuploadcttrl {
    @AuraEnabled
    public static List<ContentDocumentLink> fetchFiles(String recordId){
        try {
                return [SELECT Id,ContentDocumentId, LinkedEntityId, ContentDocument.CreatedDate, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType 
                            FROM ContentDocumentLink  
                        WHERE LinkedEntityId  =:recordId];
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteFile(String recordId){
        try {
                List<ContentDocument> contentDocList =  [SELECT Id FROM ContentDocument
                        WHERE Id  =:recordId];
                if(contentDocList.size()>0){
                    delete contentDocList[0];
                }
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}