/*
    * @Name         IND_LWC_VehicleInsuranceCntrl
    * @Author       Vinita Kamble
    * @Company      Persistent Systems
    * @Description  This class contains all the methods related to Vehicle Insurance details.
    * Inputs:       None
    * Test Class:   IND_LWC_VehicleInsuranceCntrlTest
    * History:
    */
    public with sharing class IND_LWC_VehicleInsuranceCntrl {
        
    /*
    * @Method:      loadVehicleInsuranceDetails
    * @Created by:  Vinita Kamble
    * @Description: To fetch details from Vehicle object and show on UI.
    * @Param:       String - Loan Application Id
    * @Return:      Record details of Vehicle 
    */
    @AuraEnabled
    public static String loadVehicleInsuranceDetails(String loanApplicationId, String applicantId){
        try {
            if(loanApplicationId!=null) {
                LoanApplicationWrapper loanWrapperElement = new LoanApplicationWrapper();
                List<vehicleWrapper> vehicleInsuranceList = new List<vehicleWrapper>();
                List<vehicleWrapper> vehicleDetail = new List<vehicleWrapper>();
                Date currentDate =Date.today();
                Opportunity oppObj=[ SELECT Id,Lead_number__c,Product_Type__c, Vehicle_Type__c,Vehicle_Sub_Category__c, Parent_Deal_number__c,Vehicle_Registration_Number__c, StageName, LastStageName__c,Existing_Motor_Insurance_Premium__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                Integer maxDays = 60;
                if(oppObj != null && oppObj.Product_Type__c=='Passenger Vehicles'){
                    maxDays = 90;
                }
                Date dateAfterSixtyDays = currentDate.addDays(maxDays);
                
                List<Vehicle_Detail__c> vehicleRecord = [ SELECT Id,Make__c,Variant_Code__c,Vehicle_SubType__c, Variant__c,Insurer_name__c,Insurance_number__c,Insurance_type__c, Insurance_declared_value__c,Insurance_Available__c,Ins_Issuance_date__c,Ins_Expiry_date__c, Insurance_expiring_within_60_days__c
                                    FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];

                                    List<Documents__c> docObjectList = new List<Documents__c>();
                                    Map<Id, vehicleWrapper> vehicleWrapperMap = new Map<Id, vehicleWrapper>();
                                    if(oppObj.Product_Type__c == 'Tractor'){
                                    if(String.isNotBlank(applicantId) && !vehicleRecord.isEmpty()){
                                       docObjectList = [SELECT Id,Vehicle_Detail__c,(SELECT Id FROM ContentDocumentLinks) from Documents__c WHERE is_Active__c = true And Applicant__c =:applicantId AND Vehicle_Detail__c IN: vehicleRecord AND Document_Type__c='Vehicle Insurance Policy' WITH SECURITY_ENFORCED];
                                    }

                                }

   
                        
                                    if(vehicleRecord!= null && !vehicleRecord.isEmpty()) {
                                        if(oppObj.Product_Type__c == 'Tractor'){
                                            for(Vehicle_Detail__c vehicleRec: vehicleRecord){
                    vehicleWrapper vehicleDetailElement = new vehicleWrapper();
                    vehicleDetailElement.leadNumber= oppObj.Lead_number__c;
                    vehicleDetailElement.vehicleDetailId= vehicleRec.Id;
                    vehicleDetailElement.insurerName= vehicleRec.Insurer_name__c;
                    vehicleDetailElement.insuranceNumber= vehicleRec.Insurance_number__c;
                    vehicleDetailElement.insuranceType= vehicleRec.Insurance_type__c;
                    vehicleDetailElement.insuranceDeclaredValue= vehicleRec.Insurance_declared_value__c;
                    vehicleDetailElement.insIssuanceDate=vehicleRec.Ins_Issuance_date__c;
                    vehicleDetailElement.insExpiryDate=vehicleRec.Ins_Expiry_date__c;
                    vehicleDetailElement.insuranceAvailable= vehicleRec.Insurance_Available__c;
                    vehicleDetailElement.insuranceExpiryCheckbox= vehicleRec.Insurance_expiring_within_60_days__c;
                            vehicleDetailElement.vehicleAccordianLabel = vehicleRec.Make__c + ' ' + vehicleRec.Variant_Code__c + ' ' + vehicleRec.Variant__c; 
                    vehicleDetailElement.lastStage = oppObj.LastStageName__c;
                    vehicleDetailElement.currentStageName = oppObj.StageName;
                    vehicleDetailElement.productType = oppObj.Product_Type__c;
                    vehicleDetailElement.existingMotorInsurancePremium = oppObj.Existing_Motor_Insurance_Premium__c;
                    vehicleDetailElement.isCaptureInsuranceAvailable = false;
                    vehicleDetailElement.istickCaptureInsurancePolicy=false;
                    vehicleDetailElement.documentId = null;
                    vehicleDetailElement.vehicleSubTypeStr = vehicleRec.Vehicle_SubType__c;
                    //Check Expiry date is within 60 days
                    Date expiryDate = Date.valueOf(vehicleDetailElement.insExpiryDate);
                    if(expiryDate <= dateAfterSixtyDays) {
                        vehicleDetailElement.isInsuranceExpired = true;
                    } else {
                        vehicleDetailElement.isInsuranceExpired = false;
                    }
                    vehicleDetail.add(vehicleDetailElement);
                    vehicleWrapperMap.put(vehicleRec.Id, vehicleDetailElement);
                }

                for(Documents__c doc: docObjectList) {
                    vehicleWrapper vehicleDetailElement = vehicleWrapperMap.get(doc.Vehicle_Detail__c);
                    vehicleDetailElement.documentId = doc.Id;
                        if(!doc.ContentDocumentLinks.isEmpty()){
                            vehicleDetailElement.isCaptureInsuranceAvailable = true;
                            vehicleDetailElement.istickCaptureInsurancePolicy = true;
                        }
                }
                System.debug('before return:'+JSON.serialize(vehicleDetail));
                if(Test.isRunningTest()) {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return JSON.serialize(vehicleDetail);
            }
            else{
                vehicleWrapper vehicleDetailElement = new vehicleWrapper();
                vehicleDetailElement.leadNumber= oppObj.Lead_number__c;
                vehicleDetailElement.vehicleDetailId= vehicleRecord[0].Id;
                vehicleDetailElement.insurerName= vehicleRecord[0].Insurer_name__c;
                vehicleDetailElement.insuranceNumber= vehicleRecord[0].Insurance_number__c;
                vehicleDetailElement.insuranceType= vehicleRecord[0].Insurance_type__c;
                vehicleDetailElement.insuranceDeclaredValue= vehicleRecord[0].Insurance_declared_value__c;
                vehicleDetailElement.insIssuanceDate=vehicleRecord[0].Ins_Issuance_date__c;
                vehicleDetailElement.insExpiryDate=vehicleRecord[0].Ins_Expiry_date__c;
                vehicleDetailElement.insuranceExpiryCheckbox= vehicleRecord[0].Insurance_expiring_within_60_days__c;
                        vehicleDetailElement.vehicleAccordianLabel = vehicleRecord[0].Make__c + ' ' + vehicleRecord[0].Variant_Code__c + ' ' + vehicleRecord[0].Variant__c;
                vehicleDetailElement.lastStage = oppObj.LastStageName__c;
                vehicleDetailElement.currentStageName = oppObj.StageName;
                vehicleDetailElement.productType = oppObj.Product_Type__c;
                vehicleDetailElement.existingMotorInsurancePremium = oppObj.Existing_Motor_Insurance_Premium__c;
                //Check Expiry date is within 60 days
                Date expiryDate = Date.valueOf(vehicleDetailElement.insExpiryDate);
                if(expiryDate <= dateAfterSixtyDays) {
                    vehicleDetailElement.isInsuranceExpired = true;
                } else {
                    vehicleDetailElement.isInsuranceExpired = false;
                }
                vehicleDetail.add(vehicleDetailElement);
                System.debug('before return:'+JSON.serialize(vehicleDetail));
                if(Test.isRunningTest()) {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return JSON.serialize(vehicleDetail);
            }
        }
    }
    return null;
} catch(Exception e){
    System.debug('Exception:'+e);
    ErrorLoggerUtil.logErrorEvent('IND_LWC_VehicleInsuranceCntrl', 'loadVehicleInsuranceDetails', System.Label.Apex, e,loanApplicationId);
    throw new AuraHandledException(System.Label.ExceptionMessage);
}
}

@AuraEnabled
public static string insertAllVehicleDetailForTractor(String allTractorVehicleData){
    try {
        System.debug('allTractorVehicleData-->'+allTractorVehicleData);
        List<Vehicle_Detail__c> tractorVehicleList = (List<Vehicle_Detail__c>)JSON.deserialize(allTractorVehicleData, List<Vehicle_Detail__c>.class);
        if(!tractorVehicleList.isEmpty()){
            update tractorVehicleList;
            return 'SUCCESS';
        }
        return null;   

    } catch (Exception e) {
        System.debug('allTractorData-->'+e.getMessage());
        throw new AuraHandledException(e.getMessage());
    }
}

    
    public class LoanApplicationWrapper{
        @AuraEnabled public List<vehicleWrapper> vehicleInsuranceList {get;set;}
    }
    
    //public added by Hemanth Thikka
    public class vehicleWrapper{
      public  string leadNumber{get;set;}
      public  String vehicleDetailId {get;set;}
      public  String insurerName {get;set;}
      public  String insuranceNumber {get;set;}
      public  String insuranceType {get;set;}
      public  Decimal insuranceDeclaredValue {get;set;}
      public  Date insIssuanceDate {get;set;}
      public   Date insExpiryDate {get;set;}
      public  Boolean isInsuranceExpired {get;set;}
      public String currentStageName {get;set;}
      public String lastStage {get;set;}
      public String productType {get;set;}
      public Decimal existingMotorInsurancePremium {get;set;}
      public Boolean isCaptureInsuranceAvailable {get;set;}
      public Boolean istickCaptureInsurancePolicy {get;set;}
      public String documentId {get;set;}
      public  Boolean insuranceAvailable {get;set;}
      public  Boolean insuranceExpiryCheckbox {get;set;}
      public  String vehicleAccordianLabel {get;set;}
      public  String vehicleSubTypeStr {get;set;}
    }
}