public without sharing class SignatureController {
    @AuraEnabled
    public static void saveSignature(String signElement) {
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; // S-Document is in Salesforce.
        cVersion.PathOnClient = 'Signature-' + System.now() + '.png'; // File name with extension
        cVersion.Origin = 'H'; // H-Chatter Origin.
        cVersion.Title = 'Signature-' + '-' + System.now() + '.png'; // Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode(signElement); // File content
        insert cVersion;
    }
    
    	@AuraEnabled
            public static void saveFarmerSignature(id UserID,id recId){
            // Get the Uploaded doc ContentDocumentId
            List<ContentVersion> recentSignature = New List<ContentVersion>();
            recentSignature = [SELECT id, ContentDocumentId, CreatedDate,CreatedById FROM ContentVersion where CreatedById =: UserID ORDER BY CreatedDate DESC LIMIT 1];
            Id recentSignatureId = recentSignature[0].Id;
            
            System.debug('Contecnt Document ID: '+recentSignatureId);
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :recentSignatureId].ContentDocumentId;
            System.debug('Contecnt Document ID: '+conDocument);
            
           
            // Insert ContentDocumentLink to share
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;
            cDocLink.LinkedEntityId = recId;
            System.debug('recId ID: '+cDocLink.LinkedEntityId);
            cDocLink.ShareType = 'I';
            cDocLink.Visibility = 'AllUsers';
            insert cDocLink;
        }
}