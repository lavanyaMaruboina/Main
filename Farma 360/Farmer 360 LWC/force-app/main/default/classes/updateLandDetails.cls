public class updateLandDetails {
    
    @AuraEnabled(cacheable=true)
    public static List<Land_detals__c> getLandDetails(Id contactId) {
        try {
            return [
                SELECT Id, Name, Area_Acres__c, Brand__c, Date_of_Sampling_Harvest__c, Pond_Number__c, Soil_testing_date__c, Water_Source__c, Contact__c,
                       Contact__r.Name, Address__Street__s, Address__City__s, Address__StateCode__s, Address__PostalCode__s, Address__CountryCode__s, Total_Area__c, 
                       Total_Area_Sowed__c, Soil_Detail__c, Irrigation_Type__c, Last_date_of_inspection__c,Land_topography__c
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

        Land_detals__c land;
        
        if (id != null || id == null) {
            try {
                land = [
                    SELECT Name, Address__CountryCode__s, Address__City__s, Address__StateCode__s, 
                           Address__PostalCode__s, Address__Street__s, Area_Acres__c, 
                           Date_of_Sampling_Harvest__c, Soil_Detail__c,Land_topography__c,
                           Soil_testing_date__c, Total_Area__c, Total_Area_Sowed__c,Last_date_of_inspection__c
                    FROM Land_detals__c
                    WHERE Id = :id LIMIT 1
                ];
            } catch (Exception e) {
                system.debug('Error retrieving land record: ' + e.getMessage());
                throw new AuraHandledException('Error retrieving land record: ' + e.getMessage());
            }
        } else {
            land = new Land_detals__c();
        }

        for (String fieldName : updatedFields.keySet()) {
            Object fieldValue = updatedFields.get(fieldName);
            // Check and convert date fields
            if (fieldName == 'Last_date_of_inspection__c') {
                if (fieldValue != null && fieldValue instanceof String) {
                    try {
                        system.debug('Converting fieldValue to Date for field: ' + fieldName);
                        fieldValue = Date.valueOf((String) fieldValue);
                        system.debug('Converted fieldValue: ' + fieldValue);
                    } catch (Exception e) {
                        system.debug('Error converting date string for field: ' + fieldName + ' | Error: ' + e.getMessage());
                    }
                }
            }
            if (fieldName == 'Total_Area__c') {
                if (fieldValue != null && fieldValue instanceof String) {
                    try {
                        system.debug('Converting fieldValue to Decimal for field: ' + fieldName);
                        fieldValue = Decimal.valueOf((String) fieldValue);
                        system.debug('Converted fieldValue: ' + fieldValue);
                    } catch (Exception e) {
                        system.debug('Error converting decimal string for field: ' + fieldName + ' | Error: ' + e.getMessage());
                    }
                }
            }
            system.debug('Updating ' + fieldName + ' with value >> ' + fieldValue);
            land.put(fieldName, fieldValue);
        }

        try {
            if (land.Id == null) {
                insert land;
                system.debug('Inserted land record: ' + land.Id);
            } else {
                update land;
                system.debug('Updated land record: ' + land.Id);
            }
        } catch (Exception e) {
            system.debug('Error saving land record: ' + e.getMessage());
            throw new AuraHandledException('Error saving land record: ' + e.getMessage());
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
            
            AggregateResult[] results = [SELECT COUNT(Id) cnt, Type_Of_Visit__c
                                            FROM Visit__c
                                            WHERE CreatedDate = THIS_QUARTER
                                            GROUP BY Type_Of_Visit__c];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Type_Of_Visit__c');
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
    
    //kareem created
    //
    @AuraEnabled
        public static List<VisitDealerQuarterData> fetchdealerVisitReportsData(String contactId) {
            System.debug('this is contact id-' + contactId);
            List<VisitDealerQuarterData> visitdealerQuarterDataList = new List<VisitDealerQuarterData>();
            
            AggregateResult[] results = [SELECT COUNT(Id) cnt, Type_Of_Visit_For_Dealer__c FROM Visit__c 
                                         WHERE  Dealer__c =: contactId 
                                         GROUP BY Type_Of_Visit_For_Dealer__c];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Type_Of_Visit_For_Dealer__c');
                Integer count = (Integer)result.get('cnt');
                
                VisitDealerQuarterData data = new VisitDealerQuarterData(visitType, count);
                visitdealerQuarterDataList.add(data);
                System.debug('VisitDealerQuarterData--->' + data);
            }
            
            return visitdealerQuarterDataList;
        }
        
        public class VisitDealerQuarterData {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public Integer count { get; set; }
            
            public VisitDealerQuarterData(String label, Integer count) {
                this.label = label;
                System.debug('this is label--' + this.label);
                this.count = count;
                System.debug('this is count--' + this.count);
            }
        }
    
    
    @AuraEnabled
        public static List<onboardQuarterData> fetchOnboardReportsData(String userId) {
            System.debug('this is user id-' + userId);
            List<onboardQuarterData> OnBoardedQuarterDataList = new List<onboardQuarterData>();
            
            AggregateResult[] results = [SELECT Count(Id) cnt, CreatedBy.Name FROM Contact where CreatedById =: userId group by CreatedBy.Name];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Name');
                Integer count = (Integer)result.get('cnt');
                
                onboardQuarterData data = new onboardQuarterData(visitType, count);
                OnBoardedQuarterDataList.add(data);
                System.debug('onboardQuarterData--->' + data);
            }
            
            return OnBoardedQuarterDataList;
        }
        
        public class onboardQuarterData {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public Integer count { get; set; }
            
            public onboardQuarterData(String label, Integer count) {
                this.label = label;
                System.debug('this is label--' + this.label);
                this.count = count;
                System.debug('this is count--' + this.count);
            }
        }
    
    /////////////
    
    @AuraEnabled
        public static List<DealerConvertedOrderData> fetchdealerConvertedReportsData(String contactId) {
            System.debug('this is contact id-' + contactId);
            List<DealerConvertedOrderData> DealerConvertedOrderDataList = new List<DealerConvertedOrderData>();
            
            AggregateResult[] results = [select Count(id) cnt, Account.Name from Order where AccountId =: contactId group by Account.Name];
            
            for (AggregateResult result : results) {
                //String visitType = (String)result.get('Type_Of_Visit_For_Dealer__c');
                Integer count = (Integer)result.get('cnt');
                
                DealerConvertedOrderData data = new DealerConvertedOrderData(count);
                DealerConvertedOrderDataList.add(data);
                System.debug('DealerConvertedOrderData--->' + data);
            }
            
            return DealerConvertedOrderDataList;
        }
        
        public class DealerConvertedOrderData {
            //@AuraEnabled
            //public String label { get; set; }
            @AuraEnabled
            public Integer count { get; set; }
            
            public DealerConvertedOrderData(Integer count) {
                //this.label = label;
                //System.debug('this is label--' + this.label);
                this.count = count;
                System.debug('this is count--' + this.count);
            }
        }
    
    
    // End
          
    @AuraEnabled
        public static List<OrderQuarterData> fetchOrderReportsData(String contactId) {
            System.debug('this is contact id-' + contactId);
            List<OrderQuarterData> orderQuarterDataList = new List<OrderQuarterData>();
            
            AggregateResult[] results = [Select Product2.Name, COUNT(Id) cnt from OrderItem  
                                         where Order.Contact__c  = :contactId AND 
                                         CreatedDate = THIS_QUARTER 
                                         GROUP BY Product2.Name
                                        ];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Name');
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
    
    // Kareem created
    @AuraEnabled
        public static List<DealerOrderQuarterData> fetchdealerOrderReportsData(String AccountId) {
            System.debug('this is contact id-' + AccountId);
            id AccId = AccountId;
            System.debug('this is contact id-' + AccId);
            List<DealerOrderQuarterData> dealerOrderQuarterDataList = new List<DealerOrderQuarterData>();
            
            AggregateResult[] results = [Select Product2.Name, COUNT(Id) cnt from OrderItem  
                                         where Order.AccountId  =: AccId
                                         GROUP BY Product2.Name];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Name');
                Integer count = (Integer)result.get('cnt');
                
                dealerOrderQuarterData data = new dealerOrderQuarterData(visitType, count);
                dealerOrderQuarterDataList.add(data);
                System.debug('dealerOrderQuarterData--->' + data);
            }
            
            return dealerOrderQuarterDataList;
        }
        
        public class DealerOrderQuarterData {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public Integer count { get; set; }
            
            public DealerOrderQuarterData(String label, Integer count) {
                this.label = label;
                System.debug('this is label--' + this.label);
                this.count = count;
                System.debug('this is count--' + this.count);
            }
        }
    
    // End
    // 
    
    /*
     
	@AuraEnabled
        public static List<DealerOrderQuarterData> fetchdealerOrderReportsData(String AccountId) {
            System.debug('this is contact id-' + AccountId);
            id AccId = AccountId;
            System.debug('this is contact id-' + AccId);
            List<DealerOrderQuarterData> dealerOrderQuarterDataList = new List<DealerOrderQuarterData>();
            
            AggregateResult[] results = [Select Product2.Name, COUNT(Id) cnt from OrderItem  
                                         where Order.AccountId  = :AccId AND 
                                         CreatedDate = THIS_QUARTER 
                                         GROUP BY Product2.Name];
            
            for (AggregateResult result : results) {
                String visitType = (String)result.get('Name');
                Integer count = (Integer)result.get('cnt');
                
                dealerOrderQuarterData data = new dealerOrderQuarterData(visitType, count);
                dealerOrderQuarterDataList.add(data);
                System.debug('dealerOrderQuarterData--->' + data);
            }
            
            return dealerOrderQuarterDataList;
        }
        
        public class DealerOrderQuarterData {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public Integer count { get; set; }
            
            public DealerOrderQuarterData(String label, Integer count) {
                this.label = label;
                System.debug('this is label--' + this.label);
                this.count = count;
                System.debug('this is count--' + this.count);
            }
        }

	*/
    
    @AuraEnabled
        public static List<ContactAmountData> fetchContactAmountReportsData(String contactId) {
            System.debug('this is contact id-' + contactId);
            List<ContactAmountData> contactAmountDataList = new List<ContactAmountData>();
     
            Contact contact = [SELECT Total_Amount__c FROM Contact WHERE Id = :contactId LIMIT 1];
     
            if (contact != null) {
                Decimal totalAmount = contact.Total_Amount__c;
                String label = 'Total Amount';
     
                ContactAmountData data = new ContactAmountData(label, totalAmount);
                contactAmountDataList.add(data);
                System.debug('ContactAmountData--->' + data);
            }
     
            return contactAmountDataList;
        }
     
        public class ContactAmountData {
            @AuraEnabled
            public String label { get; set; }
            @AuraEnabled
            public Decimal amount { get; set; }
     
            public ContactAmountData(String label, Decimal amount) {
                this.label = label;
                System.debug('this is label--' + this.label);
                this.amount = amount;
                System.debug('this is amount--' + this.amount);
            }
        }
        @AuraEnabled(cacheable=true)
        public static Contact getContactDetails(Id contactId) {
            try {
                return [SELECT Id, Name, FirstName, LastName
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        @AuraEnabled(cacheable=true)
        public static Account getDealerDetails(Id accountId) {
            try {
                return [SELECT Id, Name
                FROM Account
                WHERE Id = :accountId
                LIMIT 1];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    
  
}