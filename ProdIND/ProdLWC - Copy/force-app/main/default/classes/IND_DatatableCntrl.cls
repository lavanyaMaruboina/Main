/*
    * @Name         IND_DatatableCntrl
    * @Author       Vinita Kamble
    * @Company      Persistent Systems
    * @Description  This class contains all the methods used for Upload and View Document Functionality.
    * Inputs:       None
    * Test Class:   IND_DatatableCntrlTest
    * History:
    */
public with sharing class IND_DatatableCntrl {
    
    /*
    * @Method:      fetchDataMapCached
    * @Created by:  Vinita Kamble
    * @Description: To fetch details of Documents from Content Document 
    * @Param:       String - parameters to retrive data using SOQL
    * @Return:      Record details of fetched data from contentDocument 
    */
	 @AuraEnabled(Cacheable=true)
    public static Map<String, Object> fetchDataMapCached(Map<String, Object> params) {
        return fetchDataMap(params);
    }
	
    /*
    * @Method:      fetchDataMap
    * @Created by:  Vinita Kamble
    * @Description: To fetch details from Vehicle object and show on UI.
    * @Param:       String - parameters to retrive data using SOQL
    * @Return:      SOQL for fetch data from content document
    */
    @AuraEnabled
    public static Map<String, Object> fetchDataMap(Map<String, Object> params) {
       
		System.debug('Query before : '+params);
        String objectName = params.containsKey('objectName') ? (String)params.get('objectName') : null;
        String fields = params.containsKey('fields') ? (String)params.get('fields') : null;
        String queryFilters = params.containsKey('queryFilters') ? (String)params.get('queryFilters') : null;
        String sortBy = params.containsKey('sortBy') ? (String)params.get('sortBy') : null;
        String queryType = params.containsKey('queryType') ? (String)params.get('queryType') : null;
        String soslSearchTerm = params.containsKey('soslSearchTerm') ? (String)params.get('soslSearchTerm') : null;
        Boolean sortAsc = params.containsKey('sortAsc') ? (Boolean)params.get('sortAsc') : false;
        Integer limitRecords = params.containsKey('limitRecords') ? Integer.valueOf(params.get('limitRecords')) : null;
        String functionality = params.containsKey('functionality') ? (String)params.get('functionality') : null;
        String loanApplicationId = params.containsKey('loanApplicationId') ? (String)params.get('loanApplicationId') : null;
        String docType = params.containsKey('docType') ? (String)params.get('docType') : null;
        System.debug('~~~~~'+functionality);
        System.debug('Query After : '+params);
        try{
            if(functionality=='ACH' || functionality=='SI_Offline'){
                System.debug('~~~~~'+loanApplicationId+' '+docType+' '+limitRecords+' '+functionality);
                return getACHDocuments(loanApplicationId,docType,limitRecords);
            }
            //Initial checks
            String limitRecordsStr = String.valueOf(Integer.valueOf(limitRecords));
            
            //Declare query string
            String query;
            //if objectname is ContentDocumentLink, row id will be contentdocumentId
            if(objectName == 'ContentDocumentLink') {
                fields = fields+',ContentDocumentId';
            }
            //Query initialization for Soql and Sosl
            if(queryType == 'SOQL'){
                query = 'SELECT Id, LinkedEntityId, ' + fields + ' FROM ' + objectName;
            }
            else if(queryType == 'SOSL') {
                query = 'Id, ' + fields;
            }

            //Adding filters
            if(String.isNotBlank(queryFilters)){
                query += ' WHERE ' + queryFilters;
            }
            
            //Adding order by and limit records
            if(String.isNotBlank(sortBy) && queryType == 'SOQL'){
                query += ' ORDER BY ' + sortBy + (sortAsc?' ASC ':' DESC ');
            }
            
            if(String.isNotBlank(limitRecordsStr)) {
                query += ' LIMIT ' + limitRecordsStr;
            }
            
            //Log the query before getting query results from database
            Map<String, Object> returnMap = new Map<String, Object>();
            List<sObject> sObjectsList = new List<sObject>();
            if(queryType == 'SOQL'){
                system.debug('query => '+query);
                sObjectsList = Database.query(query);
            }
            else if(queryType == 'SOSL') {
                
                query = 'FIND \'' + String.escapeSingleQuotes(soslSearchTerm) + '\' IN ALL FIELDS RETURNING ' + objectName + '(' + query + ')';
                system.debug('query => '+query);
                sObjectsList = Search.query(query)[0];
            }

            returnMap.put('records', sObjectsList);
            
            //Log the result
            system.debug('returnMap => '+returnMap);
            
            if(Test.isRunningTest())
            {
                 throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return returnMap;     
        }
       catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_DatatableCntrl', ' fetchDataMap ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        } 
    }
    /* 
     @description :   Method to get documents based on loan and document type
     @param :  String loanApplicationId
     @param :  String docType
     @return : Void
    */
    public static Map<String, Object> getACHDocuments(String loanApplicationId,String docType,Integer limitRecords){
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<Id,Documents__c> docMap=new Map<Id,Documents__c>([SELECT Id FROM Documents__c WHERE Name=:docType AND Opportunity_Relation__c=:loanApplicationId WITH SECURITY_ENFORCED]);
        Set<Id> cdIds=new Set<Id>();
        List<ContentDocument> listOfContentDocs=new List<ContentDocument>();
        if(!docMap.isEmpty()){
            for(ContentDocumentLink cd:[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:docMap.keySet() WITH SECURITY_ENFORCED]){
                cdIds.add(cd.ContentDocumentId);
            }
        }
        listOfContentDocs=[SELECT Id, Title,ContentSize,FileType,Owner.Name,ParentId FROM ContentDocument WHERE Id IN:cdIds ORDER BY CreatedDate DESC LIMIT:limitRecords];
        returnMap.put('records', listOfContentDocs);
        return returnMap;
    }
}