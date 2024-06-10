public without sharing class AccountSearchController {
    @AuraEnabled
    public static Map<String, Object> search(String searchTerm) {
        String searchKeyword = searchTerm + '%';
        Map<String, Object> result = new Map<String, Object>();
        List<Contact> contacts = [SELECT Id, Name, Phone, Email, Department FROM Contact WHERE Name LIKE :searchKeyword ORDER BY CreatedDate DESC LIMIT 100];
        result.put('contacts', contacts);
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRecentContacts() {
        return [SELECT Id, Name, Phone, Email FROM Contact];
    }
    
    @AuraEnabled
    public static Contact createContact(String firstName, String lastName, String email, String city, String state, String postalCode, String street) {
        Contact newContact = new Contact();
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        newContact.Email = email;
        newContact.MailingStreet = street;
        newContact.MailingCity = city;
        newContact.MailingState = state;
        newContact.MailingPostalCode = postalCode;
        insert newContact;
        return newContact;
    }
    
    @AuraEnabled
    public static List<Contact> updateContacts(List<Contact> contactsToUpdate) {
        try {
            update contactsToUpdate;
            return contactsToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void insertVisitNotes(String contactId, String visitName, String visitNotes, Datetime actualStartTime, Datetime actualEndTime) {
        try {
            Visit visit = new Visit();
            visit.VisitorId = contactId; // Assuming contactId is the Id of the Contact related to the visit
            visit.Visit_Notes__c = visitNotes;
            visit.ActualVisitStartTime= actualStartTime;
            visit.ActualVisitEndTime= actualEndTime;
            insert visit;
        } catch (Exception e) {
            system.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error inserting visit notes: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> searchinventory(String searchTerm) {
        String searchKeyword = searchTerm + '%';
        Map<String, Object> result = new Map<String, Object>();
        List<Inventory__c> inventory = [SELECT Id, Name, Quntity__c, Product__r.Name, Dealer__r.Name, Address__c FROM Inventory__c WHERE Name LIKE :searchKeyword ORDER BY Name LIMIT 100];
        result.put('inventory', inventory);
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String searchKey) {
        String searchPattern = searchKey + '%';
        return [SELECT Id, Name, Industry, Phone FROM Account WHERE Name LIKE :searchPattern LIMIT 100];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchKey) {
        String searchPattern = searchKey + '%';
        return [SELECT Id, Name, Email, Phone FROM Contact WHERE Name LIKE :searchPattern LIMIT 100];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Inventory__c> searchDealerInventory(Id accountId, String searchKey) {
        String searchPattern = searchKey + '%';
        return [SELECT Id, Name, Quntity__c, Product__r.Name, Active__c, Dealer__r.Name, Address__c FROM Inventory__c WHERE Dealer__c = :accountId AND Name LIKE :searchPattern LIMIT 100];
    }
    
    @AuraEnabled
    public static void uploadFile(String base64, String filename, Id contactId) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.Title = filename;
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.PathOnClient = '/' + filename;
            insert cv;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = contactId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        } catch (Exception e) {
            system.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }  
    
    public static ContentVersion createContentVersion(String base64, String filename) {
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
    
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String contactId) {
        if (contentVersionId == null || contactId == null) {
            return null;
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = contactId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch (DMLException e) {
            System.debug(e);
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Contact getContactDetails(Id contactId) {
        try {
            return [SELECT Id, Name, Phone, Email FROM Contact WHERE Id = :contactId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Visit__c> getVisits() {
        return [SELECT Id, Name, Address__c, Date__c, Customer__r.Name, Visit_Notes__c FROM Visit__c];
    }
    
    @AuraEnabled
    public static void saveVisit(Visit__c visit) {
        try {
            upsert visit;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Harvest__c> getHarvestDetailsEqualtoLand(Id landDetailId) {
        return [SELECT Id, Name, Stocking_Density_in_Millions__c, Cum_feed_MT__c,Present_Final_Count__c, Last_week_ABW__c, Salinity_ppt__c, Partial_1_Count__c, Partial_3_Biomass_MT__c, Pond_Status__c, Remarks__c, ADG_grams__c, Weekly_growth__c, FCR__c
                FROM Harvest__c 
                WHERE Land_detals__c = :landDetailId];
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getIrrigationTypePicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Land_detals__c.Irrigation_Type__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }
    @AuraEnabled
    public static Land_detals__c createLand(Land_detals__c land) {
        try {
            insert land;
            return land;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Harvest__c createHarvest(Harvest__c harvest, Id landDetailId) {
        harvest.Land_detals__c = landDetailId;
        insert harvest;
        return harvest;
    }
    @AuraEnabled
    public static Land_detals__c getLandDetails(Id contactId) {
        
        return [SELECT Id, Name,Contact__c,Soil_Detail__c, Irrigation_Type__c from Land_detals__c where Contact__c = :contactId];
    }
    //Using in createLandDeatilsForm
    @AuraEnabled
    public static Land_detals__c getLandDetailstrue(Id contactId) {
        
        return [SELECT Id, Name,Contact__r.Name,Soil_Detail__c, Irrigation_Type__c from Land_detals__c 
                WHERE Contact__c = :contactId 
                ORDER BY CreatedDate 
                DESC 
                LIMIT 1];
    }
    
    // @AuraEnabled(cacheable=true)
    // public static List<LandWrapper> getLandsByContactId(Id contactId) {
    //     List<LandWrapper> landWrapperList = new List<LandWrapper>();
    
    //     List<Land_detals__c> lands = [
    //         SELECT Id, Name, Soil_Detail__c, Irrigation_Type__c,
    //             (SELECT Id, Name, Stocking_Density_in_Millions__c, Cum_feed_MT__c 
    //              FROM Harvests__r)
    //         FROM Land_detals__c
    //         WHERE Contact__c = :contactId
    //     ];
    
    //     for (Land_detals__c land : lands) {
    //         LandWrapper lw = new LandWrapper();
    //         lw.land = land;
    //         lw.harvests = land.Harvests__r;
    //         landWrapperList.add(lw);
    //     }
    
    //     return landWrapperList;
    // }
    
    @AuraEnabled()
    public static List<Land_detals__c> getLandsByContactId(Id contactId) {
        system.debug('fetching the contacts>>'+contactId);
        List<Land_detals__c> lands = [
            SELECT Id, Name, Soil_Detail__c, Irrigation_Type__c,
            (SELECT Id, Name, Stocking_Density_in_Millions__c, Cum_feed_MT__c 
             FROM Harvests__r)
            FROM Land_detals__c
            WHERE Contact__c = :contactId 
        ];
        
        system.debug('the retuning data is>>'+JSON.serializePretty(lands));
        return lands;
        
    }
    
    public class LandWrapper {
        @AuraEnabled public Land_detals__c land { get; set; }
        @AuraEnabled public List<Harvest__c> harvests { get; set; }
    }
}