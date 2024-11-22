/*
* @Name         PurgeUnusedRecordsBatch
* @Author       Rajat Jaiswal
* @Description  Purge unused records
*/
public with sharing class PurgeUnusedRecordsBatch implements Database.Batchable<sObject> {
    public String databaseQuery;
    
    public PurgeUnusedRecordsBatch(String query) {
        databaseQuery = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(databaseQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> recordList){
        try {
            Id idKey = recordList[0].Id;
            if (idKey.getSObjectType().getDescribe().getName() == 'Documents__c') {
                purgeDocumentRelatedRecords(recordList);
            }
            delete recordList;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('PurgeUnusedRecordsBatch', 'execute', System.Label.Apex, e, null);
        }
    }
    
    public void finish(Database.BatchableContext bc){}

    public void purgeDocumentRelatedRecords(List<sObject> recordList){
        try {
            Set<String> documentIdSet = new Set<String>();
            for (sObject docObj : recordList) {
                documentIdSet.add(docObj.Id);
            }
            Set<String> cdIds = new Set<String>();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl: [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: documentIdSet]){
                cdIds.add(cdl.ContentDocumentId);
                cdlList.add(cdl);
            }
            if(cdlList.size() > 0){                   
                delete cdlList;
                List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id IN: cdIds];
                if(cdList.size() > 0){
                    delete cdList;
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('PurgeUnusedRecordsBatch', 'purgeDocumentRelatedRecords', System.Label.Apex, e, null);
        }
    }
}