public without sharing class visitContactDetails { 

    @AuraEnabled(cacheable=true)
    public static List<Visit__c> getVisits(Id Contactlistdetails) {
        return [SELECT Id, Name, Enter_Address__c,Street__c, State__c, Type_Of_Visit__c, Country__c,Zip_Code__c,Date__c, Customer__r.Name, Visit_Notes__c , Address__c, Address__City__s,
        Address__CountryCode__s, Address__PostalCode__s,Land_Details__c, Address__StateCode__s, Address__Street__s,Createddate
                FROM Visit__c 
                WHERE Customer__c =:Contactlistdetails ORDER BY Createddate Desc LIMIT 5];
    }
    
   @AuraEnabled(cacheable=true)
        public static List<Visit__c> getMyVisits() {
            Id userId = UserInfo.getUserId();
            System.debug('Logged-in User ID: ' + userId);
        
            List<Visit__c> visits = [SELECT Id, Name, Enter_Address__c, Street__c, State__c, Type_Of_Visit__c, Country__c, Zip_Code__c, Date__c, Customer__r.Name, Visit_Notes__c, Address__c, Address__City__s,
                    Address__CountryCode__s,Land_Details__c, Address__PostalCode__s, Address__StateCode__s, Address__Street__s, Createddate, Dealer__r.Name
                    FROM Visit__c 
                    WHERE CreatedById = :userId AND Status__c != 'Cancelled'
                    ORDER BY Createddate DESC 
                    LIMIT 5];
        
            System.debug('Retrieved Visits: ' + visits);
        
            return visits;
        }
    
   @AuraEnabled
public static void updateVisitCancelReason(Id visitId, String cancelReason) {
    try {
        Visit__c visit = [SELECT Id, Cancel_Reason__c,Status__c FROM Visit__c WHERE Id = :visitId LIMIT 1];
        visit.Cancel_Reason__c = cancelReason;
        visit.Status__c = 'Cancelled';
        update visit;
    } catch (Exception e) {
        // Handle exception as needed, e.g., logging or rethrowing
        System.debug('Error in updateVisitCancelReason: ' + e.getMessage());
        throw new AuraHandledException('An error occurred while updating the visit cancel reason.');
    }
}

    @AuraEnabled (cacheable = true)
    public static void editVisitDetails(Id visitId,string htmlTypeOfVisit) {
        Visit__c visit = [SELECT Id, Visit_Location__c,Type_Of_Visit__c,Type_Of_Visit_For_Dealer__c,Customer__r.Name,Dealer__r.Name,Visit_Notes__c,Land_Details__r.Name ,Quantity__c,Land_Details__c FROM Visit__c WHERE Id = :visitId];
        visit.Type_Of_Visit__c = htmlTypeOfVisit;
        update visit;
    } 
    /*@AuraEnabled (cacheable = true)
    public static Visit__c editVisitDetails(Id visitId , String htmlVisitValue , string htmlTypeOfVisit,string htmlTypeOfVisitFDealer) {
        Visit__c visit = [SELECT Id, Visit_Location__c,Type_Of_Visit__c,Type_Of_Visit_For_Dealer__c,Customer__r.Name,Dealer__r.Name FROM Visit__c WHERE Id = :visitId];
        visit.Visit_Location__c = htmlVisitValue;
        visit.Type_Of_Visit__c = htmlTypeOfVisit;
        visit.Type_Of_Visit_For_Dealer__c = htmlTypeOfVisitFDealer;
       // visit.Dealer__r.Name = htmlDealerName;
        //visit.Customer__r.Name = htmlFarmerName;
        update visit;
        return visit;
    } */
    
    @AuraEnabled
    public static void updateVisitExecuteLatLong(Id visitId, double lat, double longi) {
        Visit__c visit = [SELECT Id, Execute__Latitude__s, Visit_Execute_Date__c,Status__c,Execute__Longitude__s FROM Visit__c WHERE Id = :visitId LIMIT 1];
        visit.Execute__Latitude__s = lat;
        visit.Execute__Longitude__s = longi;
        visit.Status__c = 'In-Progress';
        visit.Visit_Execute_Date__c = Datetime.now();
        update visit;
    }
    
    
    @AuraEnabled
    public static void updateVisitCompleteLatLong(Id visitId, double lat, double longi) {
        Visit__c visit = [SELECT Id, Complete__Latitude__s, Status__c,Visit_Complete_Date__c, Complete__Longitude__s FROM Visit__c WHERE Id = :visitId LIMIT 1];
        visit.Complete__Latitude__s = lat;
        visit.Complete__Longitude__s = longi;
        visit.Status__c = 'Completed';
        visit.Visit_Complete_Date__c = Datetime.now();
        update visit;
    }
    
     @AuraEnabled(cacheable=true)
        public static List<Visit__c> getDealerVisits(Id Contactlistdetails) {
            List<Visit__c> visitsDealer = [SELECT Id, Name, Dealer__r.Name, Enter_Address__c, Street__c, State__c, Type_Of_Visit__c, Country__c, Zip_Code__c, Date__c,  Visit_Notes__c, Address__c, Address__City__s,
                                    Address__CountryCode__s,Land_Details__c, Address__PostalCode__s, Address__StateCode__s, Address__Street__s,Createddate
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
        public static void updateVisit(Visit__c visit) {
        try {
            upsert visit;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Land_detals__c> searchLandDetails(String searchKey, Id contactId) {
        // Log the input parameters
        System.debug('searchKey: ' + searchKey);
        System.debug('contactId: ' + contactId);
        
        // Perform the query
        List<Land_detals__c> landDetails = [SELECT Id, Name FROM Land_detals__c
                                            WHERE Name LIKE :('%' + searchKey + '%')
                                            AND Contact__c = :contactId
                                            LIMIT 10];
        
        // Log the results of the query
        System.debug('landDetails: ' + landDetails);
        
        return landDetails;
    }


    
}