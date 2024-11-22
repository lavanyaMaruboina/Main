public with sharing class SignatureHelper {
    
    @AuraEnabled
    public static String saveSign(String strSignElement,String documentId){
        try{
            Blob fileDetails = EncodingUtil.base64Decode(strSignElement);
            return Utilities.createContentDocumentFromApex(documentId,'Signature', fileDetails, 'png');
           
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('SignatureHelper', 'saveSign', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }    
    }
}