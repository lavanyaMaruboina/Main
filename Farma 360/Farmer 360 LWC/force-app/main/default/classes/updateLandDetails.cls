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
    
    
        
          @AuraEnabled
    public static List<CaseStageData> fetchReportsData(string contactId) {
        system.debug('this is contact id-'+contactId);
        List<CaseStageData> caseStageDataList = new List<CaseStageData>();
        
        AggregateResult[] results = [SELECT status, COUNT(Id) cnt
                                     FROM Case
                                     GROUP BY status];
        
        for (AggregateResult result : results) {
            String status = (String)result.get('status');
            Integer count = (Integer)result.get('cnt');
            
            CaseStageData data = new CaseStageData(status, count);
            caseStageDataList.add(data);
            system.debug('case data--->'+caseStageDataList);
        }
        
        return caseStageDataList;
    }
    
    public class CaseStageData {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Integer count { get; set; }
        
        public CaseStageData(String label, Integer count) {
            this.label = label;
            system.debug('this is label--'+this.label);
            this.count = count;
            system.debug('this is count--'+this.count);
        }
    }
    
    
        @AuraEnabled
        public static List<VisitQuarterData> fetchVisitReportsData(String contactId) {
            System.debug('this is contact id-' + contactId);
            List<VisitQuarterData> visitQuarterDataList = new List<VisitQuarterData>();
            
            AggregateResult[] results = [SELECT COUNT(Id) cnt, Visit_Type__c
                                         FROM Visit__c
                                         GROUP BY Visit_Type__c
                                        ];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Visit_Type__c');
                Integer count = (Integer)result.get('cnt');
                
                VisitQuarterData data = new VisitQuarterData(visitType, count);
                visitQuarterDataList.add(data);
                System.debug('VisitQuarterData--->' + data);
            }
            
            return visitQuarterDataList;
        }
        
        public class VisitQuarterData {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public Integer count { get; set; }
            
            public VisitQuarterData(String label, Integer count) {
                this.label = label;
                System.debug('this is label--' + this.label);
                this.count = count;
                System.debug('this is count--' + this.count);
            }
        }  
          
    @AuraEnabled
        public static List<OrderQuarterData> fetchOrderReportsData(String contactId) {
            System.debug('this is contact id-' + contactId);
            List<OrderQuarterData> orderQuarterDataList = new List<OrderQuarterData>();
            
            AggregateResult[] results = [SELECT COUNT(Id) cnt, Status
                                         FROM Order
                                         GROUP BY Status
                                        ];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Status');
                Integer count = (Integer)result.get('cnt');
                
                OrderQuarterData data = new OrderQuarterData(visitType, count);
                orderQuarterDataList.add(data);
                System.debug('OrderQuarterData--->' + data);
            }
            
            return orderQuarterDataList;
        }
        
        public class OrderQuarterData {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public Integer count { get; set; }
            
            public OrderQuarterData(String label, Integer count) {
                this.label = label;
                System.debug('this is label--' + this.label);
                this.count = count;
                System.debug('this is count--' + this.count);
            }
        }
    
   
    
  
}