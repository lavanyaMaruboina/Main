public without sharing class VisitController {
    @AuraEnabled
    public static Visit__c createVisit(Visit__c visit){
        
        system.debug('Visit Details : '+visit);
        try{
            system.debug('Visit Details : '+visit);
            insert visit;
            return visit;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Land_Yield__c createLandYield(Land_Yield__c landYield){
        system.debug('Visit Details : '+landYield);
        try{
            system.debug('Visit Details : '+landYield);
            insert landYield;
            return landYield;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
     @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : values) {
            picklistValues.add(entry.getLabel());
        }

        return picklistValues;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Visit__c> fetchVisitDetails(id VisitId){
        List<Visit__c> FetchedVisitDetails = new List<Visit__c>([select id, Name, Status__c, Visit_Location__c, Customer__r.Name,Date__c,
                                                                 Visit_Type__c, Type_Of_Visit_For_Dealer__c, Visit_Notes__c, 
                                                                 Cancel_Reason__c from Visit__c where id =: VisitId]);
        system.debug('fetched visit details: '+FetchedVisitDetails);
        return FetchedVisitDetails;
    }
    @AuraEnabled(cacheable=true)
    public static List<Visit__c> fetchVisits(){
        List<Visit__c> FetchedVisits = new List<Visit__c>([select id, Name, Status__c, Visit_Location__c, Customer__r.Name,Date__c,
                                                                 Visit_Type__c, Type_Of_Visit_For_Dealer__c, Visit_Notes__c, 
                                                                 Cancel_Reason__c from Visit__c]);
        system.debug('fetched visit details: '+FetchedVisits);
        return FetchedVisits;
    }
    
    @AuraEnabled
    public static void updateVisitExecutelatLong(Id visitId, double Lat, double Longt) {
        Visit__c visit = [SELECT id, Execute__Latitude__s, Execute__Longitude__s FROM Visit__c WHERE Id = :visitId LIMIT 1];
        visit.Execute__Latitude__s = Lat;
        visit.Execute__Longitude__s = Longt;
        update visit;
    }
    @AuraEnabled
    public static void updateVisitExection(Id visitId,string visitedParty,string visitTypeDealer,string visitTypeFarmer ,Id FarmerVisitId , Id DealerVisitId ,string visitNotes,Id landId) {
        Visit__c visit = [SELECT id,Type_Of_Visit_For_Dealer__c,Visit_Notes__c, Visit_Location__c, Type_Of_Visit__c,Customer__c,Dealer__c,Land_Details__c FROM Visit__c WHERE Id = :visitId LIMIT 1];
        visit.Type_Of_Visit_For_Dealer__c = visitTypeDealer;
        visit.Type_Of_Visit__c = visitTypeFarmer;
        visit.Customer__c = FarmerVisitId;
        visit.Dealer__c = DealerVisitId;
        visit.Visit_Notes__c = visitNotes;
        visit.Land_Details__c = landId;
        visit.id = visitId;
        visit.Visit_Location__c = visitedParty;
        update visit;
    }
    
  	  @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        return [SELECT Id, Name FROM Contact WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }
    
    @AuraEnabled
    public static List<Land_detals__c> searchLands(String searchTerm) {
        return [SELECT Id, Name FROM Land_detals__c WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccount(String searchTerm) {
        return [SELECT Id, Name FROM Account WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Visit__c> searchContactName(Id contactId) {
        return [SELECT Id, Name, Customer__r.Name, Customer__c,Dealer__r.Name, Status__c, Type_Of_Visit__c, Type_Of_Visit_For_Dealer__c FROM visit__c where Id =: contactId];
    }
    
    @AuraEnabled
    public static Visit__C captureLatLong(Visit__c visit){
        System.debug('I am capturing Latitude and Logitude'+visit);
        try{
            update visit;
            return visit;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
//diplay visit and update the visit
@AuraEnabled(cacheable=true)
    public static Visit__c displayVisits(Id visitid) {
        return [SELECT Id, Name, Dealer__r.Name,Dealer__c, Customer__r.Name,Customer__c, User_Name__r.Name, Land_Details__r.Name,Quantity__c, Status__c, 
                       Visit_Location__c, Date__c, Visit_Type__c, Type_Of_Visit_For_Dealer__c,Type_Of_Visit__c, 
                       Visit_Notes__c, Cancel_Reason__c 
                FROM Visit__c 
                WHERE Id = :visitid];
    }
    @AuraEnabled
    public static Visit__c updateVisitRecords(String visitid, String visitLocation, String landDetailsId, string visitNotes, integer quantity, string image) {
        Visit__c vis = [SELECT Id, Name, Dealer__r.Name, Customer__r.Name, Land_Details__r.Name,Quantity__c, Status__c, 
                               Visit_Location__c, Date__c, Visit_Type__c, Type_Of_Visit_For_Dealer__c, Type_Of_Visit__c,
                               Visit_Notes__c, Cancel_Reason__c 
                        FROM Visit__c 
                        WHERE Id = :visitid LIMIT 1];
        vis.Visit_Location__c = visitLocation;
        vis.Visit_Notes__c = visitNotes;
        vis.Quantity__c =  quantity;
        if (landDetailsId != null && landDetailsId != '') {
            vis.Land_Details__c = landDetailsId;
        }

        try {
            update vis;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return displayVisits(visitid);
    }

    @AuraEnabled(cacheable=true)
    public static List<Land_detals__c> searchLandDetails(String searchTerm) {
        String searchPattern = '%' + searchTerm + '%';
        return [SELECT Id, Name FROM Land_detals__c WHERE Name LIKE :searchPattern];
    }

    @AuraEnabled
        public static String uploadFile(String base64, String filename, Id visitId) {
            system.debug('Image>>'+ base64);
            system.debug('Image>>'+ visitId);
             // Create ContentVersion for the image
            ContentVersion cv = createContentVersion(base64, filename);
            
            // Create ContentDocumentLink to link the image to the contact
            ContentDocumentLink cdl = createContentLink(cv.Id, visitId);
            
            if (cv == null || cdl == null) {
                return null;
            }
            
            return cdl.Id;
        }
        
         /***** image code******/
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