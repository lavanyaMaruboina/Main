public with sharing class HarvestController {
    @AuraEnabled
    public static String createHarvestRecord( String adgGrams, 
        Double cumulativeFeed, Double density, 
        Double densityAfterHarvest, Double densityAfterSurvival, 
        Double doc, Double fcr, String name, 
        Double lastWeekABW, Double partial1Biomass, Double partial1Count, 
        Double partial2Biomass, Double partial2Count, Double partial3Biomass, 
        Double partial3Count, String pondStatus, Integer presentFinalCount, 
        String remarks, Double salinity, Double stockingDensity, 
        Double weeklyGrowth, String contactId) {
        
        try {
            // Create a new Harvest record
            Harvest__c newHarvest = new Harvest__c(
               // ABW_grams__c = abwGrams;
                ADG_grams__c = adgGrams,
              //  Biomass_MT__c = biomass,
                Cum_feed_MT__c = cumulativeFeed,
                Density_pcs_mtr2__c = density,
                Density_after_harvest_pcs_mtr2__c = densityAfterHarvest,
                Density_after_survival_in_millions__c = densityAfterSurvival,
                DOC__c = doc,
                FCR__c = fcr,
                Name = name,
               // Land_detals__c = landDetails,
                Last_week_ABW__c = lastWeekABW,
                Partial_1_Biomass_MT__c = partial1Biomass,
                Partial_1_Count__c = partial1Count,
                Partial_2_Biomass_MT__c = partial2Biomass,
                Partial_2_Count__c = partial2Count,
                Partial_3_Biomass_MT__c = partial3Biomass,
                Partial_3_Count__c = partial3Count,
                Pond_status__c = pondStatus,
                Present_Final_Count__c = presentFinalCount,
                Remarks__c = remarks,
                Salinity_ppt__c = salinity,
                Stocking_Density_in_Millions__c = stockingDensity,
               // Total_Bimoass__c = totalBiomass,
                Weekly_growth__c = weeklyGrowth,
                Contact__c = contactId
            );
            
            // Insert the new record
            insert newHarvest;
            
            return 'Success';
        } catch (Exception ex) {
            // Handle any exceptions and return the error message
            return ex.getMessage();
        }
    }
}