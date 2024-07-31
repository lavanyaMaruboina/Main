public without sharing class AccountSearchController {
    @AuraEnabled
    public static Map<String, Object> search(String searchTerm) {
        String searchKeyword = searchTerm + '%';
        Map<String, Object> result = new Map<String, Object>();
        List<Contact> contacts = [SELECT Id,DOB__c, Name,FirstName,LastName,Aadhar_Number_Masked__c,Pan_Card_Masked__c, 
                                  Phone, Email,Aadhar_Number__c, PAN_Card__c, Department ,Type_of_Farmer__c,Sub_Type__c
                                  FROM Contact 
                                  WHERE Name 
                                  LIKE :searchKeyword ORDER BY 
                                  CreatedDate DESC LIMIT 5];
        result.put('contacts', contacts);
        return result;
    }
    @AuraEnabled
    public static Map<String, Object> searchDealer(String searchTerm) {
        String searchKeyword = searchTerm + '%';
        Map<String, Object> result = new Map<String, Object>();
        List<Account> accounts = [SELECT Id, Name, Phone, Email__c,ShippingStreet, shippingCity, ShippingState, ShippingPostalCode, ShippingCountry, YearStarted 
                                FROM Account 
                                WHERE Name LIKE :searchKeyword ORDER BY CreatedDate DESC LIMIT 100];
        result.put('accounts', accounts);
        return result;
    }
    
    
    @AuraEnabled
    public static List<ContactWrapper> getRecentContacts() {
        // Fetch recent contacts
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, PAN_Card__c, CreatedDate, Aadhar_Number__c, Name,
                   Aadhar_Number_Masked__c, Pan_Card_Masked__c, Phone, Email, DOB__c, Type_of_Farmer__c, Sub_Type__c
            FROM Contact
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];

        System.debug('Fetched Contacts: ' + contacts);

        // Collect contact IDs
        Set<Id> contactIds = new Set<Id>();
        for (Contact contact : contacts) {
            contactIds.add(contact.Id);
        }

        System.debug('Contact IDs: ' + contactIds);

        // Fetch related files
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileExtension
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :contactIds
            AND ContentDocument.FileExtension != null
        ];

        System.debug('Document Links: ' + documentLinks);

        // Collect ContentDocumentIds
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : documentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        System.debug('Content Document IDs: ' + contentDocumentIds);

        // Fetch ContentVersions
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            ORDER BY CreatedDate DESC
        ];

        System.debug('Content Versions: ' + contentVersions);

        // Create maps for quick lookup
        Map<Id, ContentDocumentLink> contactToFileMap = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink link : documentLinks) {
            contactToFileMap.put(link.LinkedEntityId, link);
        }

        System.debug('Contact to File Map: ' + contactToFileMap);

        Map<Id, ContentVersion> documentToVersionMap = new Map<Id, ContentVersion>();
        for (ContentVersion version : contentVersions) {
            documentToVersionMap.put(version.ContentDocumentId, version);
        }

        System.debug('Document to Version Map: ' + documentToVersionMap);

        // Create the wrapper list
        List<ContactWrapper> contactWrapperList = new List<ContactWrapper>();
        for (Contact contact : contacts) {
            ContactWrapper wrapper = new ContactWrapper();
            wrapper.contact = contact;

            ContentDocumentLink link = contactToFileMap.get(contact.Id);
            if (link != null) {
                ContentVersion version = documentToVersionMap.get(link.ContentDocumentId);
                if (version != null && link.ContentDocument != null && link.ContentDocument.FileExtension != null /*&& link.ContentDocument.FileExtension.startsWith('image')*/) {
                    String imageUrl = 'data:image/' + link.ContentDocument.FileExtension + ';base64,' + EncodingUtil.base64Encode(version.VersionData);
                    wrapper.attachmentUrl = imageUrl;

                    System.debug('Contact Id: ' + contact.Id + ' - Image URL: ' + imageUrl);
                } else {
                    System.debug('No valid image file for Contact Id: ' + contact.Id);
                }
            } else {
                System.debug('No linked file for Contact Id: ' + contact.Id);
            }

            contactWrapperList.add(wrapper);
        }

        System.debug('Final Contact Wrapper List: ' + contactWrapperList);
        return contactWrapperList;
    }

    public class ContactWrapper {
        @AuraEnabled public Contact contact { get; set; }
        @AuraEnabled public String attachmentUrl { get; set; }
    }


    @AuraEnabled(cacheable=true)
    public static List<Contact> getUserCreatedFarmers(id userId) {
        system.debug('user id : '+userId);
        
        return [SELECT Id,FirstName,LastName, Name, Phone, Email,DOB__c, Type_of_Farmer__c,Sub_Type__c FROM Contact where CreatedById =: userId];
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getUserCreatedDealers(id userId) {
        system.debug('user id : '+userId);
        
        return [SELECT Id,Name, Phone, Email__c, Primary_Contact_Name__c, Primary_Contact_Phone__c ,ShippingStreet, shippingCity, ShippingState, ShippingPostalCode, ShippingCountry, YearStarted FROM Account where Active__c = 'Yes' AND CreatedById =: userId];
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
    
    //===============Lavanya Created================
    @AuraEnabled
    public static Id updateDealerContact(Id id, Map<String, Object> DealerDetailsList) {
        system.debug('Updated Fields >>>' + DealerDetailsList);
        system.debug('Updated Id >>>' + id);
    
        Account account;
        
        if (id != null) {
            try {
                account = [SELECT Id, Name, Phone, Email__c, Primary_Contact_Name__c,Primary_Contact_Phone__c FROM Account WHERE Id = :id LIMIT 1];
            } catch (Exception e) {
                system.debug('Error retrieving account record: ' + e.getMessage());
                throw new AuraHandledException('Error retrieving account record: ' + e.getMessage());
            }
        } else {
            account = new Account();
        }
    
        if (DealerDetailsList.containsKey('Name')) {
            account.Name = (String) DealerDetailsList.get('Name');
        }
        if (DealerDetailsList.containsKey('Phone')) {
            account.Phone = (String) DealerDetailsList.get('Phone');
        }
        if (DealerDetailsList.containsKey('Email__c')) {
            account.Email__c = (String) DealerDetailsList.get('Email__c');
        }
        if (DealerDetailsList.containsKey('Primary_Contact_Name__c')) {
            account.Primary_Contact_Name__c = (String) DealerDetailsList.get('Primary_Contact_Name__c');
        }
        if (DealerDetailsList.containsKey('Primary_Contact_Phone__c')) {
            account.Primary_Contact_Phone__c = (String) DealerDetailsList.get('Primary_Contact_Phone__c');
        }
        
    
       
        if (account.Name == null) {
            throw new AuraHandledException('Account Name is required.');
        }
    
        try {
            if (account.Id == null) {
                insert account;
                system.debug('Inserted Account record: ' + account.Id);
            } else {
                update account;
                system.debug('Updated Account record: ' + account.Id);
            }
        } catch (Exception e) {
            system.debug('Error saving account record: ' + e.getMessage());
            throw new AuraHandledException('Error saving account record: ' + e.getMessage());
        }
    
        return account.Id;
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
        public static List<Inventory__c> searchAccountsIn(String searchKey) {
            String searchPattern = searchKey + '%';
            return [
                SELECT Id, Name, 
                       Dealer__r.Name, 
                       Product__r.Name,
                		Quntity__c
                FROM Inventory__c 
                WHERE Name LIKE :searchPattern 
                LIMIT 100
            ];
        }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchKey) {
        String searchPattern = searchKey + '%';
        return [SELECT Id, Name, Email, Phone FROM Contact WHERE Name LIKE :searchPattern LIMIT 100];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Inventory__c> searchDealerInventory(Id accountId, String searchKey) {
        String searchPattern = searchKey + '%';
        return [SELECT Id, Name, Quntity__c, Product__r.Name, Active__c, Dealer__r.Name, Address__c FROM Inventory__c WHERE Dealer__c = :accountId AND Name LIKE :searchPattern AND Active__c = true  LIMIT 100];
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
            return [SELECT Id, Name, Phone,MiddleName,Farmer_Consent__c, Email,DOB__c,Aadhar_Number__c,Sub_Type__c,Type_of_Farmer__c,PAN_Card__c,MailingStreet FROM Contact WHERE Id = :contactId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Account getAccountDetails(Id accountId) {
        try {
            return [SELECT Id, FirstName,LastName, Phone, Email__c,ShippingStreet, shippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Primary_Contact_Name__c, Primary_Contact_Phone__c, YearStarted FROM Account WHERE Id = :accountId LIMIT 1];
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
        return [SELECT Id, Name, Stocking_Density_in_Millions__c,Harvest_Date__c, Cum_feed_MT__c,Present_Final_Count__c, Last_week_ABW__c, Salinity_ppt__c, Partial_1_Count__c, Partial_3_Biomass_MT__c, Pond_Status__c, Remarks__c, ADG_grams__c, Weekly_growth__c, FCR__c
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
        
        return [SELECT Id, Name,Contact__c,Soil_Detail__c,Unique_Number__c, Irrigation_Type__c from Land_detals__c where Contact__c = :contactId];
    }
    //Using in createLandDeatilsForm
    @AuraEnabled
    public static Land_detals__c getLandDetailstrue(Id contactId) {
        
        return [SELECT Id, Name,Contact__r.Name,Unique_Number__c,Soil_Detail__c, Irrigation_Type__c from Land_detals__c 
                WHERE Contact__c = :contactId 
                ORDER BY CreatedDate 
                DESC 
                LIMIT 1];
    }


    //================= contact Details edited (Lavanya)================================

    @AuraEnabled
    public static Id updateContactDetails(Id id, Map<String, Object> ContactDetailsList) {
        system.debug('Updated Fields >>>' + ContactDetailsList);
        system.debug('Updated Id >>>' + id);
    
        Contact contact;
        
        if (id != null) {
            try {
                contact = [SELECT Id, FirstName, LastName, Phone, Email, Aadhar_Number__c, PAN_Card__c, DOB__c, Type_of_Farmer__c, Sub_Type__c
                            FROM Contact 
                            WHERE Id = :id LIMIT 1];
            } catch (Exception e) {
                system.debug('Error retrieving contact record: ' + e.getMessage());
                throw new AuraHandledException('Error retrieving contact record: ' + e.getMessage());
            }
        } else {
            contact = new Contact();
        }
    
        if (ContactDetailsList.containsKey('FirstName')) {
            contact.FirstName = (String) ContactDetailsList.get('FirstName');
        }
        if (ContactDetailsList.containsKey('LastName')) {
            contact.LastName = (String) ContactDetailsList.get('LastName');
        }
        if (ContactDetailsList.containsKey('Phone')) {
            contact.Phone = (String) ContactDetailsList.get('Phone');
        }
        if (ContactDetailsList.containsKey('Email')) {
            contact.Email = (String) ContactDetailsList.get('Email');
        }
        if (ContactDetailsList.containsKey('Aadhar_Number__c')) {
        try {
            Object aadharValue = ContactDetailsList.get('Aadhar_Number__c');
            if (aadharValue instanceof Decimal) {
                contact.Aadhar_Number__c = (Decimal) aadharValue;
            } else if (aadharValue instanceof String) {
                contact.Aadhar_Number__c = Decimal.valueOf((String) aadharValue);
            } else {
                throw new AuraHandledException('Invalid type for Aadhar Number.');
            }
        } catch (TypeException e) {
            throw new AuraHandledException('Invalid value for Aadhar Number.');
        }
    }
        if (ContactDetailsList.containsKey('PAN_Card__c')) {
            contact.PAN_Card__c = (String) ContactDetailsList.get('PAN_Card__c');
        }
        if (ContactDetailsList.containsKey('DOB__c')) {
            contact.DOB__c = Date.valueOf((String) ContactDetailsList.get('DOB__c'));
        }
        // if (ContactDetailsList.containsKey('Type_of_Farmer__c')) {
        //     contact.Type_of_Farmer__c = (String) ContactDetailsList.get('Type_of_Farmer__c');
        // }
        // if (ContactDetailsList.containsKey('Sub_Type__c')) {
        //     contact.Sub_Type__c = (String) ContactDetailsList.get('Sub_Type__c');
        // }
    
        if (contact.FirstName == null || contact.LastName == null) {
            throw new AuraHandledException('Both First Name and Last Name are required.');
        }
    
        try {
            if (contact.Id == null) {
                insert contact;
                system.debug('Inserted contact record: ' + contact.Id);
            } else {
                update contact;
                system.debug('Updated contact record: ' + contact.Id);
            }
        } catch (Exception e) {
            system.debug('Error saving contact record: ' + e.getMessage());
            throw new AuraHandledException('Error saving contact record: ' + e.getMessage());
        }
    
        return contact.Id;
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
    
    @AuraEnabled
    public static List<Land_detals__c> getLandsByContactId(Id contactId) {
        system.debug('fetching the contacts>>'+contactId);
        List<Land_detals__c> lands = [
            SELECT Id, Name, Soil_Detail__c, Irrigation_Type__c,Unique_Number__c,
            (SELECT Id, Name, Stocking_Density_in_Millions__c, Cum_feed_MT__c,Harvest_Date__c 
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
    
//    @AuraEnabled(cacheable=true)
// public static List<ContactFileWrapper> getFilesList(Id contactId) {
//     List<ContactFileWrapper> filesList = new List<ContactFileWrapper>();
//     List<ContentDocumentLink> documentLinks = [
//         SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension
//         FROM ContentDocumentLink
//         WHERE LinkedEntityId = :contactId
//         AND ContentDocument.FileExtension != null
        
//         LIMIT 1
//     ]; 
    
   
//     for (ContentDocumentLink link : documentLinks) {
       
//         ContentVersion contentVersion = [
//             SELECT VersionData
//             FROM ContentVersion
//             WHERE ContentDocumentId = :link.ContentDocumentId
//             ORDER BY CreatedDate DESC
//             LIMIT 1
//         ];
      
//         filesList.add(new ContactFileWrapper(
//             link.ContentDocumentId,
//             link.ContentDocument.Title,
//             link.ContentDocument.FileExtension,
//             EncodingUtil.base64Encode(contentVersion.VersionData) 
//         ));
//     }
    
//     return filesList;
// }

// public class ContactFileWrapper {
//     @AuraEnabled public Id contentDocumentId { get; private set; }
//     @AuraEnabled public String title { get; private set; }
//     @AuraEnabled public String fileExtension { get; private set; }
//     @AuraEnabled public String versionData { get; private set; }
    
//     public ContactFileWrapper(Id id, String title, String extension, String data) {
//         this.contentDocumentId = id;
//         this.title = title;
//         this.fileExtension = extension;
//         this.versionData = data;
//     }
// }
@AuraEnabled(cacheable=true)
public static List<ContactFileWrapper> getFilesList(Id contactId) {
    List<ContactFileWrapper> filesList = new List<ContactFileWrapper>();
    List<ContentDocumentLink> documentLinks = [
        SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :contactId
        AND ContentDocument.FileExtension != null
        AND ContentDocument.Title LIKE '%Image%'
        
        LIMIT 1
    ]; 
    
   
    for (ContentDocumentLink link : documentLinks) {
       
        ContentVersion contentVersion = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :link.ContentDocumentId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
      
        filesList.add(new ContactFileWrapper(
            link.ContentDocumentId,
            link.ContentDocument.Title,
            link.ContentDocument.FileExtension,
            EncodingUtil.base64Encode(contentVersion.VersionData) 
        ));
    }
    
    return filesList;
}

public class ContactFileWrapper {
    @AuraEnabled public Id contentDocumentId { get; private set; }
    @AuraEnabled public String title { get; private set; }
    @AuraEnabled public String fileExtension { get; private set; }
    @AuraEnabled public String versionData { get; private set; }
    
    public ContactFileWrapper(Id id, String title, String extension, String data) {
        this.contentDocumentId = id;
        this.title = title;
        this.fileExtension = extension;
        this.versionData = data;
    }
}


// Account Images 
@AuraEnabled(cacheable=true)
public static List<AccountFileWrapper> getFilesAccountList(Id accountId) {
    List<AccountFileWrapper> filesList = new List<AccountFileWrapper>();
    List<ContentDocumentLink> documentLinks = [
        SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :accountId
        AND ContentDocument.FileExtension != null
        
        LIMIT 1
    ]; 
    
   
    for (ContentDocumentLink link : documentLinks) {
       
        ContentVersion contentVersion = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :link.ContentDocumentId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
      
        filesList.add(new AccountFileWrapper(
            link.ContentDocumentId,
            link.ContentDocument.Title,
            link.ContentDocument.FileExtension,
            EncodingUtil.base64Encode(contentVersion.VersionData) 
        ));
    }
    
    return filesList;
}

public class AccountFileWrapper {
    @AuraEnabled public Id contentDocumentId { get; private set; }
    @AuraEnabled public String title { get; private set; }
    @AuraEnabled public String fileExtension { get; private set; }
    @AuraEnabled public String versionData { get; private set; }
    
    public AccountFileWrapper(Id id, String title, String extension, String data) {
        this.contentDocumentId = id;
        this.title = title;
        this.fileExtension = extension;
        this.versionData = data;
    }
}
}