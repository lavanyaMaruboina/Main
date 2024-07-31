public without sharing class visitContactDetails { 

    @AuraEnabled(cacheable=true)
    public static List<Visit__c> getVisits(Id Contactlistdetails) {
        return [SELECT Id, Name, Enter_Address__c,Street__c, State__c, Type_Of_Visit__c, Country__c,Zip_Code__c,Date__c, Customer__r.Name, Visit_Notes__c , Address__c, Address__City__s,
        Address__CountryCode__s, Address__PostalCode__s, Address__StateCode__s, Address__Street__s,Createddate
                FROM Visit__c 
                WHERE Customer__c =:Contactlistdetails ORDER BY Createddate Desc LIMIT 5];
    }
    
     @AuraEnabled(cacheable=true)
        public static List<Visit__c> getDealerVisits(Id Contactlistdetails) {
            List<Visit__c> visitsDealer = [SELECT Id, Name, Dealer__r.Name, Enter_Address__c, Street__c, State__c, Type_Of_Visit__c, Country__c, Zip_Code__c, Date__c,  Visit_Notes__c, Address__c, Address__City__s,
                                    Address__CountryCode__s, Address__PostalCode__s, Address__StateCode__s, Address__Street__s,Createddate
                                    FROM Visit__c 
                                    WHERE Dealer__c =: Contactlistdetails ORDER BY Createddate Desc LIMIT 10];
            
            // Log the result of the query
            System.debug('Query result: ' + visitsDealer);
            System.debug('Query result ID: ' + Contactlistdetails);
        
            return visitsDealer;
        }
    //public static void saveVisit(Visit__c visit) 
    @AuraEnabled
    public static void saveVisit(Visit__c visit,String contentVersionId) {
        try {

            // system.debug('test..>>'+address);
            system.debug('test..>>'+JSON.serializePretty(visit));

            // visit.Address__City__s = address.city;
            // visit.Address__CountryCode__s = address.country;
            // visit.Address__PostalCode__s = address.postalCode;
            // visit.Address__StateCode__s = address.province;
            // visit.Address__Street__s = address.street;

            upsert visit;
            if(!String.isBlank(contentVersionId)) {
                VisitImageController.createContentLink(contentVersionId,visit.Id);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchTerm) {
        if (String.isBlank(searchTerm)) {
            return new List<User>();
        }

        searchTerm = '%' + searchTerm + '%';
        return [SELECT Id, Name FROM User WHERE Name LIKE :searchTerm LIMIT 10];
    }
    

    // public class AddressWrapper {
    //     @AuraEnabled
    //     public String street { get; set; }
        
    //     @AuraEnabled
    //     public String city { get; set; }
        
    //     @AuraEnabled
    //     public String province { get; set; }
        
    //     @AuraEnabled
    //     public String country { get; set; }
        
    //     @AuraEnabled
    //     public String postalCode { get; set; }
        
    //     // Constructor
    //     public AddressWrapper(){}
        
    // }
}