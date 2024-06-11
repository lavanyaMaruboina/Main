public without sharing class FileUploaderClass {
    @AuraEnabled
    public static String uploadFile(string filename, string fileBody, String recordId, string filename1, string filebody1) {
        
        
        system.debug('filename>>'+filename);
        system.debug('fileBody>>'+fileBody);
        system.debug('recordId>>'+recordId);
        system.debug('filename1>>'+filename1);
        system.debug('fileBody1>>'+fileBody1);
        
        ContentVersion cv = createContentVersion(fileBody, filename);
        ContentVersion cv1 = createContentVersion(fileBody1, filename1);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        ContentDocumentLink cdl1 = createContentLink(cv1.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
        
    }
    
    private static ContentVersion createContentVersion(String fileBody, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(fileBody);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    @AuraEnabled
    public static string Insertregistarionid(Request_For_ID__c request, string filename, string filebody, string filename1, string filebody1, string Leadid, string leadRecodName, string Opporid, string oppRecodName) {
    
        system.debug('lavanya Opportunity name is===============' + Opporid);
    
        try {
            System.debug('Vicky>>>>>>>>>>>>>>>>>>>>>>>>>>' + request);
    
            // Fetch the related Lead record
            Lead relatedLead = [SELECT Id, Email,Company FROM Lead WHERE Id = :Leadid LIMIT 1];
    
            if (relatedLead != null) {
                // Update Email_ID__c with the email from the related Lead
                request.Email_ID__c = relatedLead.Email;
                request.Clinic_Name__c = relatedLead.Company;
            }
    
            insert request;
    
            // Update Opportunity fields in Request_For_ID__c
            request.Lead__c = Leadid;
            request.Record_Name__c = leadRecodName;
            request.Opportunity_Name__c = Opporid;
            request.Opportunity_Record_Name__c = oppRecodName;
            update request;
    
            System.debug('have fun');
            System.debug(request.id);
            System.debug(filename);
            System.debug(filebody);
            return request.Id;
        } catch (Exception e) {
            system.debug(e);
            system.debug('lavanya>>>>>>>>>>>>>>>>>>>>>>>>' + e.getLineNumber());
            return e.getMessage();
        }
    }
    @AuraEnabled(cacheable=true)
    public static lead methodName1(string recordid){
        lead l= [SELECT Id,RecordType.name FROM Lead WHERE Id = :recordid];
        return l;
    }
    @AuraEnabled(cacheable=true)
    public static Opportunity methodName2(string recordid1){
        Opportunity p= [SELECT Id,RecordType.name  FROM Opportunity WHERE Id = :recordid1];
        return p;
    
    } 

    @AuraEnabled(cacheable=true)
    public static String getEmail(Id recordId){
    return [SELECT Email_ID__c FROM Request_For_ID__c WHERE Id=: recordId ].Email_ID__c;  
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isEmailUnique(String email , Id recordId){
    List<Request_For_ID__c> Req = [SELECT Id FROM Request_For_ID__c WHERE Email_ID__c =:email AND Id !=: recordId ];  
        return Req.isEmpty();
    }
    @AuraEnabled(cacheable=true)
    public static Lead getCurrentLead(String leadId) {
        return [SELECT Id, Name, Email, Company FROM Lead WHERE Id = :leadId LIMIT 1];
    }
    @AuraEnabled(cacheable=true)
    public static id getrequestId(String leadId) {
        system.debug('lavanya>>>>>>>>>>>>>>>>>>>>>>>>ID' + leadId);
        return [SELECT Id,Lead__c FROM Request_For_ID__c WHERE Lead__c = :leadId LIMIT 1].id;

    }
}



