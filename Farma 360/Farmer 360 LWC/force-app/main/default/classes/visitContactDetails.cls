public without sharing class visitContactDetails { 

    @AuraEnabled(cacheable=true)
    public static List<Visit__c> getVisits(List<Id> Contactlistdetails) {
        return [SELECT Id, Name, Enter_Address__c,Street__c, State__c, Visit_Type__c, Country__c,Zip_Code__c,Date__c, Customer__r.Name, Visit_Notes__c , Address__c, Address__City__s,
        Address__CountryCode__s, Address__PostalCode__s, Address__StateCode__s, Address__Street__s
                FROM Visit__c 
                WHERE Customer__c IN :Contactlistdetails];
    }

    @AuraEnabled
    public static void saveVisit(Visit__c visit) {
        try {

            // system.debug('test..>>'+address);
            system.debug('test..>>'+JSON.serializePretty(visit));

            // visit.Address__City__s = address.city;
            // visit.Address__CountryCode__s = address.country;
            // visit.Address__PostalCode__s = address.postalCode;
            // visit.Address__StateCode__s = address.province;
            // visit.Address__Street__s = address.street;

            upsert visit;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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