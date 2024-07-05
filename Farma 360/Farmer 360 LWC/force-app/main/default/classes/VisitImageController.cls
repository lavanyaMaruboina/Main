public class VisitImageController {
      @AuraEnabled
    public static String uploadFileVisit(String base64, String filename, Id contactId) {
        // Create ContentVersion for the image
        ContentVersion cv = createContentVersion(base64, filename);
        /* 
        Create ContentDocumentLink to link the image to the contact
        ContentDocumentLink cdl = createContentLink(cv.Id, contactId);
        
        if (cv == null || cdl == null) {
            return null;
        }
        
        return cdl.Id;
        */
        return cv.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch (DMLException e) {
            System.debug(e);
            return null;
        }
    }
    public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) {
            return null;
        }
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
            LIMIT 1
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        
        try {
            insert cdl;
            return cdl;
        } catch (DMLException e) {
            System.debug(e);
            return null;
        }
    }

}