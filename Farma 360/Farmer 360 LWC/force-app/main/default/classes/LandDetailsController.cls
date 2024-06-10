public with sharing class LandDetailsController {
    
    @AuraEnabled
    public static void createLandDetailsRecord(Double areaAcres, String brand, String contactId, Date samplingHarvestDate, Date stockingDate, Double pondNumber, Date soilTestingDate, String waterSource,string irrigation) {
        try {
            Land_detals__c landDetails = new Land_detals__c();
            landDetails.Area_Acres__c = areaAcres;
            landDetails.Brand__c = brand;
            landDetails.Contact__c = contactId;
            landDetails.Date_of_Sampling_Harvest__c = samplingHarvestDate;
            landDetails.Date_of_Stocking__c = stockingDate;
            landDetails.Pond_Number__c = pondNumber;
            landDetails.Soil_testing_date__c = soilTestingDate;
            landDetails.Water_Source__c = waterSource;
            landDetails.Irrigation_Type__c = irrigation;
          //  landDetails.Number_of_Lands__c=Lands;
            
            insert landDetails;
            
            System.debug('Land Details Record created with Id: ' + landDetails.Id);
        } catch(Exception e) {
            System.debug('Error creating Land Details Record: ' + e.getMessage());
        }
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

      @AuraEnabled (cacheable=true)
    public static List<Land_detals__c> fetchLands(){
        return [SELECT Id, Name,Soil_testing_date__c, Water_Source__c,Contact__c,Total_Area__c,Total_Area_Sowed__c,Soil_Detail__c,Irrigation_Type__c,Last_date_of_inspection__c
                FROM Land_detals__c WHERE Irrigation_Type__c !='' LIMIT 10];       
    }

    @AuraEnabled(cacheable=true)
    public static List<Land_detals__c> getLandDetails(Id contactId) {
        try {
            return [
                SELECT Id, Name, Area_Acres__c, Brand__c, Contact__r.Name, Date_of_Sampling_Harvest__c, Pond_Number__c, Soil_testing_date__c, Water_Source__c,Contact__c,
                       Address__Street__s, Address__City__s, Address__StateCode__s, Address__PostalCode__s, Address__CountryCode__s,Total_Area__c,Total_Area_Sowed__c,Soil_Detail__c,Irrigation_Type__c,Last_date_of_inspection__c
                FROM Land_detals__c
                WHERE Contact__c = :contactId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveLandDetails(List<Land_detals__c> data) {
        try {
            update data;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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


    /*  @AuraEnabled(cacheable=true)
    public static List<Harvest__c> getHarvestDetails(Id contactId) {
        return [SELECT Id, Name, Stocking_Density_in_Millions__c, Cum_feed_MT__c, Last_week_ABW__c, Salinity_ppt__c, Partial_1_Count__c,Partial_1_Biomass_MT__c, Partial_2_Count__c,Partial_2_Biomass_MT__c,
                 Pond_status__c,Partial_3_Biomass_MT__c,Weekly_growth__c,FCR__c,
                 Present_Final_Count__c,Present_Final_Survival_Millions__c,ADG_gRAMS__c,Contact__c
                 FROM Harvest__c  WHERE Contact__c = :contactId];
    }*/

      @AuraEnabled(cacheable=true)
    public static List<Harvest__c> getHarvestDetails(Id landDetailId) {
        return [SELECT Id, Name, Stocking_Density_in_Millions__c, Cum_feed_MT__c,Present_Final_Count__c, Last_week_ABW__c, Salinity_ppt__c, Partial_1_Count__c, Partial_3_Biomass_MT__c, Pond_Status__c, Remarks__c, ADG_grams__c, Weekly_growth__c, FCR__c
                FROM Harvest__c 
                WHERE Land_detals__c = :landDetailId];
    }

    @AuraEnabled
    public static void saveHarvestDetails(List<Harvest__c> data) {
        update data;
    }

     @AuraEnabled
    public static void saveOrderLineDetails(List<Order_Line_Item__c> data) {
        update data;
    }


     /* @AuraEnabled
    public static Harvest__c createHarvest(Harvest__c harvest) {
        try {
            insert harvest;
            return harvest;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

 @AuraEnabled
    public static Harvest__c createHarvest(Harvest__c harvest, Id landDetailId) {
        harvest.Land_detals__c = landDetailId;
        insert harvest;
        return harvest;
    }


    
 /*@AuraEnabled(cacheable=true)
    public static List<Harvest__c> getHarvestDetailsEqualtoLand(Id landDetailId) {
        try {
            return [SELECT id,Name,Stocking_Density_in_Millions__c,Cum_feed_MT__c,Last_week_ABW__c,Salinity_ppt__c,Partial_3_Biomass_MT__c,
                         Partial_1_Count__c,Partial_1_Biomass_MT__c,Partial_2_Count__c,Partial_2_Biomass_MT__c,
                         Present_Final_Count__c,Present_Final_Survival_Millions__c,Pond_status__c,Remarks__c
                          from Harvest__c 
                    WHERE Land_detals__c = :landDetailId];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving harvest details: ' + e.getMessage());
        }
    }*/


      @AuraEnabled(cacheable=true)
    public static List<Harvest__c> getHarvestDetailsEqualtoLand(Id landDetailId) {
        return [SELECT Id, Name, Stocking_Density_in_Millions__c, Cum_feed_MT__c,Present_Final_Count__c, Last_week_ABW__c, Salinity_ppt__c, Partial_1_Count__c, Partial_3_Biomass_MT__c, Pond_Status__c, Remarks__c, ADG_grams__c, Weekly_growth__c, FCR__c
                FROM Harvest__c 
                WHERE Land_detals__c = :landDetailId];
    }


    @AuraEnabled(cacheable=true)
    public static List<Order> getOrderDetailsByContactId(Id contactId) {
        try {
            return [SELECT Id, Name, EndDate, OrderNumber,TotalAmount, Type, BillingAddress, EffectiveDate, Status, Contact__r.Name, Account.Name
                    FROM Order 
                    WHERE Contact__c = :contactId ORDER BY Createddate Desc LIMIT 5];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
     public static Order createOrder(Order order) {
    try {
        insert order;
        return [SELECT Id FROM Order WHERE Id = :order.Id]; 
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
     }


       @AuraEnabled(cacheable=true)
    public static List<String> getStatusPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }
        @AuraEnabled(cacheable=true)
    public static List<String> getWaterStatusPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Land_detals__c.Water_Source__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }
    
      @AuraEnabled(cacheable=true)
    public static List<String> getIrrigationStatusPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Land_detals__c.Irrigation_Type__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }

      @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String searchTerm) {
        return [SELECT Id, Name FROM Account WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }

    public static List<Harvest__c> getHarvestDetailsByContactId(Id contactId) {
        return [SELECT id,Name,Stocking_Density_in_Millions__c,Cum_feed_MT__c,Last_week_ABW__c,Salinity_ppt__c,Partial_3_Biomass_MT__c,
                         Partial_1_Count__c,Partial_1_Biomass_MT__c,Partial_2_Count__c,Partial_2_Biomass_MT__c,
                         Present_Final_Count__c,Present_Final_Survival_Millions__c,Pond_status__c,Remarks__c
                          from Harvest__c 
                WHERE Contact__c = :contactId];

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
    	public static Id updateLandDetails(Id id, String name) {
        system.debug('Name>>>'+ name);
        system.debug('Name>>>'+ id);
        Land_detals__c land = [SELECT Id, Name FROM Land_detals__c WHERE Id = :id LIMIT 1];
        land.Name = name;
        system.debug('Name>>>'+ land);
        update land;
        return land.Id;
    }

    

}