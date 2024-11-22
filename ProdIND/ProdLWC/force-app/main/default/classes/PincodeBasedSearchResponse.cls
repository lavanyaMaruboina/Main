/*
* @Wrapper class: PincodeBasedSearchResponse
* @Created by:  Utkarsh Maurya
* @Description: To create wrapper data of PincodeBaseSearch response
*/
public with sharing class PincodeBasedSearchResponse {
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String respDesc { get; set; }
        @AuraEnabled
        public List<CustomerInfo> content { get; set; }
        
    public class CustomerInfo {
        @AuraEnabled
        public String Customer_Name { get; set; }
        @AuraEnabled
        public String SurName { get; set; }
        @AuraEnabled
        public String Customer_Code { get; set; }
        @AuraEnabled
        public String Address_Line_1 { get; set; }
        @AuraEnabled
        public String Address_Line_2 { get; set; }
        @AuraEnabled
        public String Address_Line_3 { get; set; }
        @AuraEnabled
        public String Address_Line_4 { get; set; }
        @AuraEnabled
        public String City { get; set; }
        @AuraEnabled
        public String District { get; set; }
        @AuraEnabled
        public String State { get; set; }
        @AuraEnabled
        public String Landmark { get; set; }
        @AuraEnabled
        public String Address_Flag { get; set; }
        @AuraEnabled
        public String Mobile_Number { get; set; }
        @AuraEnabled
        public String Maker_Date { get; set; }
        @AuraEnabled
        public String Product { get; set; }
        @AuraEnabled
        public String Exposure { get; set; }
    }
}