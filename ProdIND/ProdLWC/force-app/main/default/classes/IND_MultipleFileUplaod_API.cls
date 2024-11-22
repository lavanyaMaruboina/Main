/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is being used to expose the Post API, to upload multiple files using multipart/form-data. This is being used with Mobile APP.
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-23-2021      Manish Baldota       Created
------------------------------------------------------------*/
@RestResource(urlMapping='/multifileapi/*')
global with sharing class IND_MultipleFileUplaod_API
{
    private static List<KV> keyValues;
    @HttpPost
    global static void doPost(){
        
        Blob body = RestContext.request.requestBody;
        String blobStr = EncodingUtil.base64Encode(body);
        system.debug('blobStr::'+blobStr);
        String encodedBoundary = blobStr.substring(0,blobStr.indexof('Q29udGVudC1EaXNwb3NpdGlvbjo'));
        system.debug('encodedBoundary::'+encodedBoundary);
        String actualBoundary = EncodingUtil.base64decode(encodedBoundary).toString().replace('\n','').replace('\r','');       
		system.debug('encodedBoundary::'+actualBoundary);
        String actualBody = EncodingUtil.base64decode(blobStr).toString().replace('\n','').replace('\r',''); 
        actualBody = actualBody.replaceFirst(actualBoundary, '');
        actualBody = actualBody.substring(0,actualBody.length()-2);
        system.debug('actualBody::'+actualBody);
        List<String> keyValueStr = actualBody.split(actualBoundary);
        getKeyValue(keyValueStr);
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        res.responseBody = Blob.valueOf(JSON.serialize(keyValues));
    }
    @TestVisible
    private static List<KV> getKeyValue(List<String> pairs){
        keyValues = new List<KV>();
        for(String s:pairs){
            KV kv = new KV();
            kv.key = s.substring(s.indexOf('\"')+1,s.lastIndexOf('\"'));
            kv.value = s.substring(s.lastIndexOf('\"')+1);
            kv.contentDisposition = s.substring(s.indexOf('Content-Disposition: ')+21,s.indexOf(';'));
            keyValues.add(kv);
        }
        return keyValues;
    }
    
    private class KV{
        String contentDisposition;
        String key;
        String value;
        
    }
}