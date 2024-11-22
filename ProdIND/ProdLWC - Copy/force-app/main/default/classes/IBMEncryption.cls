public class IBMEncryption {

    
    /*
* @Method:      getEncryptedRequest
* @Created by:  Divya
* @Description: Method to return Encrypted Request
* @Param:       String - JSON Request
* @Param:       String - key
* @Param:       String - vkey
* @Return:      String - encryptedString
*/
public static String getEncryptedRequest(String requestJSON,String key,String vKey){
    system.debug('privateKey: '+key+'vKey: '+vKey);
    Blob privateKey = Blob.valueOf(getAPIKeys(key));
    Blob ivkey = Blob.valueOf(getAPIKeys(vKey)); 
    Blob data = Blob.valueOf(requestJSON);  
    Blob encrypted = Crypto.encrypt('AES256', privateKey, ivkey, data); 
    //system.debug('encrypted.toString(): '+encrypted.toString());
    String encryptedString = EncodingUtil.base64Encode(encrypted);  
    system.debug('encryptedString length : '+encryptedString.length());
    return encryptedString;
}


/*
* @Method:      getPlainTextForLog
* @Created by:  Raman Raj Saxena
* @Description: Method to return Stub Response for API
* @Param:       String - encryptedText
* @Return:      String - decryptedRequest
*/    
public static String getPlainTextForLog(String encryptedText) {
    String decryptedRequest='';
    if(encryptedText != null && !String.isBlank(encryptedText)){
        system.debug('encryptedText: '+encryptedText.length());
        
        String requestBody = encryptedText.substring(12, encryptedText.length()-2);
        
        system.debug('requestBody : '+requestBody);                                                             
        decryptedRequest = getDecryptedResponse(requestBody, System.Label.privateKey, System.Label.ivkey);
    }
    system.debug('decryptedRequest: '+decryptedRequest);
    return decryptedRequest;
}
                                                         
    /*
* @Method:      getDecryptedResponse
* @Created by:  Raman Raj Saxena
* @Description: Method to return Decrypted Response
* @Param:       String - JSON Response
* @Param:       String - key
* @Param:       String - vkey
* @Return:      String - decryptedString
*/
public static String getDecryptedResponse(String responseJSON,String key,String vKey){
    system.debug('privateKey: '+getAPIKeys(key)+' vKey: '+getAPIKeys(vKey));
    
    Blob privateKey = Blob.valueOf(getAPIKeys(key));  
    Blob ivkey = Blob.valueOf(getAPIKeys(vKey)); 
    system.debug('ivkey : '+ivkey);
    Blob data = EncodingUtil.base64Decode(responseJSON);
    system.debug('data: '+data);
    Blob decrypted = Crypto.decrypt('AES256', privateKey, ivkey, data);   
    String decryptedString = decrypted.toString();  
    return decryptedString;
}
                                                         
                                                             /*
* @Method:      getAPIKeys
* @Created by:  Raman Raj Saxena
* @Description: Method used to get keys for encryption and decryption
* @Param:      String
* @Return:     String
*/
public static String getAPIKeys(String label){
    
    Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.MasterKeyIBM);
    
    if(System.Label.privateKey.equals(label)){
        return metadataApi?.Private_Key__c;
    }
    if(System.Label.ivkey.equals(label)){
        return metadataApi?.IV_Key__c;
    }
    
    return '';
}

        /*
* @Method:      getEncryptedRequestHero
* @Description: Method to return Encrypted Request
* @Param:       String - JSON Request
* @Param:       String - key
* @Param:       String - vkey
* @Return:      String - encryptedString
*/
public static String getEncryptedRequestHero(String requestJSON,String key,String vKey){
    system.debug('privateKey: '+key+'vKey: '+vKey);
    Blob privateKey = Blob.valueOf(getAPIKeysHero(key));
    Blob ivkey = Blob.valueOf(getAPIKeysHero(vKey)); 
    Blob data = Blob.valueOf(requestJSON);  
    Blob encrypted = Crypto.encrypt('AES256', privateKey, ivkey, data); 
    //system.debug('encrypted.toString(): '+encrypted.toString());
    String encryptedString = EncodingUtil.base64Encode(encrypted);  
    system.debug('encryptedString length : '+encryptedString.length());
    return encryptedString;
}
 /*
* @Method:      getAPIKeys
* @Created by:  Raman Raj Saxena
* @Description: Method used to get keys for encryption and decryption
* @Param:      String
* @Return:     String
*/
    public static String getAPIKeysHero(String label){
        
        Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.HERO_API_Keys);
        
        if(System.Label.privateKey.equals(label)){
            return metadataApi?.Private_Key__c;
        }
        if(System.Label.ivkey.equals(label)){
            return metadataApi?.IV_Key__c;
        }
        
        return '';
    }
}