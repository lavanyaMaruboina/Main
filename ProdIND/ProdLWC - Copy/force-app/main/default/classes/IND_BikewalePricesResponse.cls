/*------------------------------------------------------------
Author: Poonam	
Description: This class is wrapper class for the Bikewale Prices response
History
Date            Author              Comments
------------------------------------------------------------- 
28-10-2021    Poonam            Created
------------------------------------------------------------*/
public class IND_BikewalePricesResponse extends ParentAPIResponse {
    public Boolean isMetallic {get;set;}
    public ExShowroom exShowroom{get;set;}
    public rto rto{get;set;}
    public insuranceComprehensive insuranceComprehensive{get;set;}
    public otherCharges otherCharges{get;set;}
    
    
    public class ExShowroom {
        public Integer value{get;set;}
        public Integer type{get;set;}
        public Integer id{get;set;}
        public String name{get;set;}
    }
    public class rto {
        public Integer value{get;set;}
        public Integer type{get;set;}
        public Integer id{get;set;}
        public String name{get;set;}
    }
    public class insuranceComprehensive {
        public Integer value{get;set;}
        public Integer type{get;set;}
        public Integer id{get;set;}
        public String name{get;set;}
    }
    public class otherCharges {
        public Integer value{get;set;}
        public Integer type{get;set;}
        public Integer id{get;set;}
        public String name{get;set;}
    }
    
    /*public  IND_BikewalePricesResponse parseJSON(String json) {
        return (IND_BikewalePricesResponse) System.JSON.deserialize(json, IND_BikewalePricesResponse.class);
    }*/
}