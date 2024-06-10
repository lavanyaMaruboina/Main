public class updateLandDetails {
    
    @AuraEnabled(cacheable=true)
    public static List<Land_detals__c> getLandDetails(Id contactId) {
        try {
            return [
                SELECT Id, Name, Area_Acres__c, Brand__c, Date_of_Sampling_Harvest__c, Pond_Number__c, Soil_testing_date__c, Water_Source__c, Contact__c,
                       Address__Street__s, Address__City__s, Address__StateCode__s, Address__PostalCode__s, Address__CountryCode__s, Total_Area__c, Total_Area_Sowed__c, Soil_Detail__c, Irrigation_Type__c, Last_date_of_inspection__c
                FROM Land_detals__c
                WHERE Contact__c = :contactId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id updateLandDetailsMethod(Id id, Map<String, Object> updatedFields) {
        system.debug('Updated Fields Keval >>>' + updatedFields);

        Land_detals__c land = [SELECT Name, Address__CountryCode__s, Address__City__s, Address__StateCode__s, 
                               Address__PostalCode__s, Address__Street__s, Area_Acres__c, Brand__c, 
                               Date_of_Sampling_Harvest__c, Pond_Number__c, Soil_Detail__c, 
                               Soil_testing_date__c, Total_Area__c, Total_Area_Sowed__c, Water_Source__c 
                               FROM Land_detals__c 
                               WHERE Id = :id LIMIT 1];

        for (String fieldName : updatedFields.keySet()) {
            Object fieldValue = updatedFields.get(fieldName);
           // system.debug('Field Name: ' + fieldName + ' | Field Value: ' + fieldValue + ' | Type of Field Value: ' + typeOf(fieldValue));

            // Check and convert date fields
            if (fieldName == 'Date_of_Sampling_Harvest__c' || fieldName == 'Soil_testing_date__c' || fieldName == 'Last_date_of_inspection__c') {
                // Ensure the value is a string and convert it to Date
                if (fieldValue != null && fieldValue instanceof String) {
                    try {
                        system.debug('Converting fieldValue to Date for field: ' + fieldName);
                        fieldValue = Date.valueOf((String) fieldValue);
                        system.debug('Converted fieldValue: ' + fieldValue);
                    } catch (Exception e) {
                        system.debug('Error converting date string for field: ' + fieldName + ' | Error: ' + e.getMessage());
                        // Optionally handle the error, such as logging it or adding to a list of errors
                    }
                }
            }
			system.debug('updating '+fieldName+' with value>>'+fieldValue);
            land.put(fieldName, fieldValue);
        }

        try {
            update land;
        } catch (Exception e) {
            system.debug('Error updating land record: ' + e.getMessage());
            // Optionally handle the error, such as logging it or adding to a list of errors
        }

        return land.Id;
    }
    
    
   
    
  
}