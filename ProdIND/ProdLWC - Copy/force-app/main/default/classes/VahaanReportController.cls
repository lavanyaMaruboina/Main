public with sharing class VahaanReportController {
    public String vehicleId {get;set;}
    public String reportDateTime {get;set;}
    public String registrationNo {get;set;}
    public String engineNo {get;set;}
    public String vehicleClass {get;set;}
    public String chassisNo {get;set;}
    public String fitnessUpto {get;set;}
    public String registrationDt {get;set;}
    public String dealer {get;set;}
    public String bodyType {get;set;}
    public String ownerSrNo {get;set;}
    public String manufacturer {get;set;}
    public String makerModel {get;set;}
    public String ownerName {get;set;}
    public String fatherName {get;set;}
    public String presentAddress {get;set;}
    public String financerName {get;set;}

    public VahaanReportController() {

        String formatPattern = 'dd-MM-yyyy HH:mm:ss';

        reportDateTime = DateTime.now().format(formatPattern);

        vehicleId = ApexPages.currentPage().getParameters().get('vehicleId');
        
        Vehicle_Detail__c veh = new Vehicle_Detail__c();

        if(String.isNotBlank(vehicleId)){
            veh = [SELECT Id, Vehicle_Registration_number__c, Engine_number__c, Vehicle_Class__c, 
                    Chassis_number__c, Fitness_Upto__c, Registration_Date__c, Dealer__c, 
                    Body_Type__c, Owner_Sr_No__c, Manufacturer__c, Maker_Model__c, Owner_Name__c, 
                    Father_Name__c, Present_Address__c, Financier_Name__c 
                    FROM Vehicle_Detail__c
                    WHERE Id =: vehicleId
                    WITH SECURITY_ENFORCED];
        }

        if(veh!=null){
            registrationNo = veh.Vehicle_Registration_number__c;
            engineNo = veh.Engine_number__c;
            vehicleClass = veh.Vehicle_Class__c;
            chassisNo = veh.Chassis_number__c;
            fitnessUpto = veh.Fitness_Upto__c!=null ? veh.Fitness_Upto__c.format(formatPattern): '';
            registrationDt = veh.Registration_Date__c!=null ? veh.Registration_Date__c.format(formatPattern):'';
            dealer = veh.Dealer__c;
            bodyType = veh.Body_Type__c;
            ownerSrNo = veh.Owner_Sr_No__c;
            manufacturer = veh.Manufacturer__c;
            makerModel = veh.Maker_Model__c;
            ownerName = veh.Owner_Name__c;
            fatherName = veh.Father_Name__c;
            presentAddress = veh.Present_Address__c;
            financerName = veh.Financier_Name__c;
        }
    }
}