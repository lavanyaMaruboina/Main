Public class CreateFieldInvestigationRecord{
    
    @AuraEnabled
    Public static boolean uploadDocuments(Map<String,String> patttaDocData, Map<String,String> landPhotoData,
                                          Map<String,String> rentAggrementData, 
                                          Map<String,String> pensionDocData, String recordId){
        try{
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            ContentVersion pattaDocCV, landPhotoCV, rentAgreemtntCV, pensionDataCV;
            if(patttaDocData != null){
                pattaDocCV = createContentVersion(patttaDocData.get('base64'), patttaDocData.get('filename'));               
                contentVersionList.add(pattaDocCV);
                //contentVersionList.add(signDataCV);
            }
            if(landPhotoData != null){
                landPhotoCV = createContentVersion(landPhotoData.get('base64'), patttaDocData.get('filename'));
                contentVersionList.add(landPhotoCV);
            }
            if(rentAggrementData != null){
                rentAgreemtntCV = createContentVersion(rentAggrementData.get('base64'), rentAggrementData.get('filename'));
                contentVersionList.add(rentAgreemtntCV);
            }
            if(pensionDocData != null){
                pensionDataCV = createContentVersion(pensionDocData.get('base64'), pensionDocData.get('filename'));
                contentVersionList.add(pensionDataCV);
            }
            if(!contentVersionList.isEmpty()){
                Insert contentVersionList;
            }
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            if(pattaDocCV != null){
                cdlList.add(createContentLink(pattaDocCV.Id, recordId));
            }
            if(landPhotoCV != null){
                cdlList.add(createContentLink(landPhotoCV.Id, recordId));
            }
            if(rentAgreemtntCV != null){
                cdlList.add(createContentLink(rentAgreemtntCV.Id, recordId));
            }
            if(pensionDataCV != null){
                cdlList.add(createContentLink(pensionDataCV.Id, recordId));
            }
            if(!cdlList.isEmpty()){
                Insert cdlList;
            }
            return true;
        }
        catch(Exception ex){
            System.debug('An Exception: '+ex.getCause());
            System.debug('An Exception: '+ex.getLineNumber());
            System.debug('An Exception: '+ex.getMessage());
            return false;
        }
    }
    /*
* @method createContentVersion() [private]
* @desc Creates a content version from a given file's base64 and name
* 
* @param {String} base64 - base64 string that represents the file
* @param {String} filename - full file name with extension, i.e. 'products.csv'
* 
* @return {ContentVersion} - returns the newly created ContentVersion, or null
*   if there was an error inserting the record
*/
    //@Testvisible added by Pravallika K
    
    @TestVisible
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            //insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    /*
* @method createContentLink() [private]
* @desc Creates a content link for a given ContentVersion and record
* 
* @param {String} contentVersionId - Id of the ContentVersion of the file
* @param {String} recordId - Id of the record you want to attach this file to
* 
* @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
*   or null if there was an error inserting the record
*/
    //@Testvisible added by PravallikaK
    
    @TestVisible
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { 
            return null; 
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            //insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
}