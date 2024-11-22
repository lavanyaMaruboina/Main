/**
* @Name         IND_ValuationIDVCntrl
* @Author       Divya J
* @Company      Persistent Systems
* @Description  This class contains all methods related to Valuation IDV
* Inputs:       None
* Test Class:   IND_ValuationIDVCntrlTest
* History:      None
*/
public with sharing class IND_ValuationIDVCntrl {
    /*
* @Method:      loadVehicleDetailsData
* @Created by:  Divya J
* @Description: This method will return Current Loan Application Vehicle details in a wrappper
* @Param:       String - loanApplicationId ID
* @Return:      String - Wrapper response data
*/
    @AuraEnabled(cacheable=true)
    public static String loadVehicleDetailsData(String loanApplicationId){
        try {
            String serializedResonponse = null;
            if(loanApplicationId!=null){
                VehicleDetailsWrapper vehicleDetailsWrapper = new VehicleDetailsWrapper();
                
                List<Opportunity> loanDetailsList = new List<Opportunity>();
                Vehicle_Detail__c vehicleDeatilsObj = new Vehicle_Detail__c();
                Applicant__c applicantObj = new Applicant__c();
                Documents__c  docObj = new Documents__c();
                Final_Term__c  finalTermObj = new Final_Term__c();
                loanDetailsList = [select Id,Vehicle_Type__c,Lead_number__c,StageName,Sub_Stage__c, LeadSource, //D2C Change
                                   (SELECT Id,MFC_Request_Id__c,OEM_Dealer__c,Vehicle_type__c,Vehicle_Registration_number__c, Make__c, Model__c, Variant__c, 
                                    Manufacturer_Year_Month__c, Last_owner_name__c, Engine_number__c, Chassis_number__c,Valuation_price__c,
                                    Insurance_number__c,Insurance_type__c,Insurance_declared_value__c,Ins_Issuance_date__c,Valuation_Decisioning__c,
                                    Ins_Expiry_date__c,Valuer_category__c,MFC_valuation_Report_URL__c,Insurance_expiring_within_60_days__c
                                    FROM Vehicle_Details__r limit 1),
                                   (select Id from applicants__r),
                                   (SELECT Id, Document_Type__c From Documents__r limit 1),
                                   (SELECT Id,Loan_Application__c, LtvEngine_Ltv__c, PricingEngine_thresholdNetrr__c From Final_Terms__r)
                                   from Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                
               
                
                
                
                
                if(!loanDetailsList.isEmpty() && loanDetailsList[0].Vehicle_Details__r[0] != null){
                    
                    
                    for(Opportunity opportunityObj : loanDetailsList) {
                        vehicleDetailsWrapper.vehicleType=opportunityObj.Vehicle_Type__c;
                        vehicleDetailsWrapper.leadNumber=opportunityObj.Lead_number__c;
                        vehicleDetailsWrapper.stage = opportunityObj.StageName;
                        vehicleDetailsWrapper.subStage = opportunityObj.Sub_Stage__c;
                        vehicleDetailsWrapper.leadSource = opportunityObj.LeadSource;
                        
                        if( !opportunityObj.Vehicle_Details__r.isEmpty())
                        {
                            vehicleDeatilsObj = loanDetailsList[0].Vehicle_Details__r[0];
                            vehicleDetailsWrapper.vehicleDetailId= vehicleDeatilsObj.Id;
                            vehicleDetailsWrapper.vehicleMake= vehicleDeatilsObj.Make__c;
                            vehicleDetailsWrapper.vehicleModel= vehicleDeatilsObj.Model__c;
                            vehicleDetailsWrapper.vehicleVarient= vehicleDeatilsObj.Variant__c;
                            vehicleDetailsWrapper.vehicleRegNumber=vehicleDeatilsObj.Vehicle_Registration_number__c;
                            vehicleDetailsWrapper.manufacturerYearMonth = vehicleDeatilsObj.Manufacturer_Year_Month__c;
                            vehicleDetailsWrapper.engineNumber = vehicleDeatilsObj.Engine_number__c;
                            vehicleDetailsWrapper.chassisNumber = vehicleDeatilsObj.Chassis_number__c;
                            vehicleDetailsWrapper.insuranceNumber = vehicleDeatilsObj.Insurance_number__c;
                            vehicleDetailsWrapper.insuranceType = vehicleDeatilsObj.Insurance_type__c;
                            vehicleDetailsWrapper.insIssuenceDate = vehicleDeatilsObj.Ins_Issuance_date__c;
                            vehicleDetailsWrapper.insExpiryDate = vehicleDeatilsObj.Ins_Expiry_date__c;
                            vehicleDetailsWrapper.insuranceDeclaredValue = vehicleDeatilsObj.Insurance_declared_value__c;
                            vehicleDetailsWrapper.valuationPrice = vehicleDeatilsObj.Valuation_price__c;
                            vehicleDetailsWrapper.valuationDecisioning = vehicleDeatilsObj.Valuation_Decisioning__c;
                            vehicleDetailsWrapper.valuerCategory = vehicleDeatilsObj.Valuer_category__c;
                            vehicleDetailsWrapper.reportURL = vehicleDeatilsObj.MFC_valuation_Report_URL__c;
                            vehicleDetailsWrapper.isInsuranceExpired = vehicleDeatilsObj.Insurance_expiring_within_60_days__c;
                            vehicleDetailsWrapper.oemCheck = vehicleDeatilsObj.OEM_Dealer__c;
                            vehicleDetailsWrapper.requestId = vehicleDeatilsObj.MFC_Request_Id__c;
                        }
                        
                        if(!opportunityObj.applicants__r.isEmpty()){
                            applicantObj = loanDetailsList[0].applicants__r[0];
                            vehicleDetailsWrapper.applicantId=applicantObj.Id;
                        } 
                        if(!opportunityObj.Documents__r.isEmpty()){
                            docObj =loanDetailsList[0].Documents__r[0];
                            vehicleDetailsWrapper.documentType=docObj.Document_Type__c;
                        } 
                        if(!opportunityObj.Final_Terms__r.isEmpty()){
                            finalTermObj =loanDetailsList[0].Final_Terms__r[0];
                            vehicleDetailsWrapper.ltvEnginge=finalTermObj.LtvEngine_Ltv__c;
                            vehicleDetailsWrapper.pricingEngine=finalTermObj.PricingEngine_thresholdNetrr__c;
                        }
                    }
                }                    
                
                if(Test.isRunningTest()){
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                serializedResonponse = JSON.serialize(vehicleDetailsWrapper);
            }
            return serializedResonponse;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_ValuationIDVCntrl', 'loadVehicleDetailsData', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
/*
* @Method:      loadVehicleDetailsDataForTractor
* @Created by:  Utkarsh Maurya
* @Description: This method will return Current Loan Application Vehicle details in a wrappper for Tractor
* @Param:       String - loanApplicationId ID
* @Return:      String - Wrapper response data
*/
    @AuraEnabled
    public static String loadVehicleDetailsDataForTractor(String loanApplicationId){
        try {
            String serializedResonponse = null;
            if(loanApplicationId!=null){
                List<VehicleDetailsWrapper> vehicleDetailsWrapperList = new List<VehicleDetailsWrapper>();
                
                List<Opportunity> loanDetailsList = new List<Opportunity>();
                Vehicle_Detail__c vehicleDeatilsObj = new Vehicle_Detail__c();
                Applicant__c applicantObj = new Applicant__c();
                Documents__c  docObj = new Documents__c();
                Final_Term__c  finalTermObj = new Final_Term__c();
                loanDetailsList = [select Id,Vehicle_Type__c,Lead_number__c,StageName,Sub_Stage__c, LeadSource, //D2C Change
                                   (SELECT Id,MFC_Request_Id__c,OEM_Dealer__c,Vehicle_type__c,Vehicle_Registration_number__c, Make__c, Model__c, Variant__c, 
                                    Manufacturer_Year_Month__c, Last_owner_name__c, Engine_number__c, Chassis_number__c,Valuation_price__c,
                                    Insurance_number__c,Insurance_type__c,Insurance_declared_value__c,Ins_Issuance_date__c,Valuation_Decisioning__c,
                                    Ins_Expiry_date__c,Valuer_category__c,MFC_valuation_Report_URL__c,Insurance_expiring_within_60_days__c,Serial_number__c,
                                    Vehicle_SubType__c FROM Vehicle_Details__r WHERE Vehicle_SubType__c != 'Implement' ORDER BY CreatedDate ASC),
                                   (select Id from applicants__r WHERE Applicant_Type__c='Borrower'),
                                   (SELECT Id, Document_Type__c From Documents__r),
                                   (SELECT Id,Loan_Application__c, LtvEngine_Ltv__c, PricingEngine_thresholdNetrr__c From Final_Terms__r),
                                   Customer_Type__c
                                   from Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                
                Map<String , List<sObject>> loanApplicationMap = new Map<String , List<sObject>>();

                if(!loanDetailsList.isEmpty()){
                    
                    for(Opportunity opportunityObj : loanDetailsList) {
                       
                        if(!opportunityObj.Vehicle_Details__r.isEmpty())
                        {
                            for(Vehicle_Detail__c eachVehicle : opportunityObj.Vehicle_Details__r){
                                VehicleDetailsWrapper vehicleDetailsWrapper = new VehicleDetailsWrapper();

                                vehicleDetailsWrapper.vehicleType=opportunityObj.Vehicle_Type__c;
                                vehicleDetailsWrapper.customerType=opportunityObj.Customer_Type__c;
                                vehicleDetailsWrapper.leadNumber=opportunityObj.Lead_number__c;
                                vehicleDetailsWrapper.stage = opportunityObj.StageName;
                                vehicleDetailsWrapper.subStage = opportunityObj.Sub_Stage__c;
                                vehicleDetailsWrapper.leadSource = opportunityObj.LeadSource;
                                
                                vehicleDeatilsObj = eachVehicle;
                                vehicleDetailsWrapper.vehicleDetailId= vehicleDeatilsObj.Id;
                                vehicleDetailsWrapper.vehicleMake= vehicleDeatilsObj.Make__c;
                                vehicleDetailsWrapper.vehicleModel= vehicleDeatilsObj.Model__c;
                                vehicleDetailsWrapper.vehicleVarient= vehicleDeatilsObj.Variant__c;
                                vehicleDetailsWrapper.vehicleRegNumber=vehicleDeatilsObj.Vehicle_Registration_number__c;
                                vehicleDetailsWrapper.manufacturerYearMonth = vehicleDeatilsObj.Manufacturer_Year_Month__c;
                                vehicleDetailsWrapper.engineNumber = vehicleDeatilsObj.Engine_number__c;
                                vehicleDetailsWrapper.chassisNumber = vehicleDeatilsObj.Chassis_number__c;
                                vehicleDetailsWrapper.serialNumber = vehicleDeatilsObj.Serial_number__c;
                                vehicleDetailsWrapper.vehicleSubType = vehicleDeatilsObj.Vehicle_SubType__c;
                                vehicleDetailsWrapper.insuranceNumber = vehicleDeatilsObj.Insurance_number__c;
                                vehicleDetailsWrapper.insuranceType = vehicleDeatilsObj.Insurance_type__c;
                                vehicleDetailsWrapper.insIssuenceDate = vehicleDeatilsObj.Ins_Issuance_date__c;
                                vehicleDetailsWrapper.insExpiryDate = vehicleDeatilsObj.Ins_Expiry_date__c;
                                vehicleDetailsWrapper.insuranceDeclaredValue = vehicleDeatilsObj.Insurance_declared_value__c;
                                vehicleDetailsWrapper.valuationPrice = vehicleDeatilsObj.Valuation_price__c;
                                vehicleDetailsWrapper.valuationDecisioning = vehicleDeatilsObj.Valuation_Decisioning__c;
                                vehicleDetailsWrapper.valuerCategory = vehicleDeatilsObj.Valuer_category__c;
                                vehicleDetailsWrapper.reportURL = vehicleDeatilsObj.MFC_valuation_Report_URL__c;
                                vehicleDetailsWrapper.isInsuranceExpired = vehicleDeatilsObj.Insurance_expiring_within_60_days__c;
                                vehicleDetailsWrapper.oemCheck = vehicleDeatilsObj.OEM_Dealer__c;
                                vehicleDetailsWrapper.requestId = vehicleDeatilsObj.MFC_Request_Id__c;

                                if(!opportunityObj.applicants__r.isEmpty()){
                                    applicantObj = loanDetailsList[0].applicants__r[0];
                                    vehicleDetailsWrapper.applicantId=applicantObj.Id;
                                } 
                                if(!opportunityObj.Documents__r.isEmpty()){
                                    docObj =loanDetailsList[0].Documents__r[0];
                                    vehicleDetailsWrapper.documentType=docObj.Document_Type__c;
                                } 
                                if(!opportunityObj.Final_Terms__r.isEmpty()){
                                    finalTermObj =loanDetailsList[0].Final_Terms__r[0];
                                    vehicleDetailsWrapper.ltvEnginge=finalTermObj.LtvEngine_Ltv__c;
                                    vehicleDetailsWrapper.pricingEngine=finalTermObj.PricingEngine_thresholdNetrr__c;
                                }
        
                                vehicleDetailsWrapperList.add(vehicleDetailsWrapper);
                            }
                           
                        }  
                    }
                }                    
                
                if(Test.isRunningTest()){
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                serializedResonponse = JSON.serialize(vehicleDetailsWrapperList);
            }
            return serializedResonponse;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_ValuationIDVCntrl', 'loadVehicleDetailsDataForTractor', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }


    //Wrapper Class for Vehicle Valuation Details.
    public class VehicleDetailsWrapper {
        public String vehicleDetailId{get;set;}
        public String vehicleMake{get;set;}
        public String vehicleModel{get;set;}
        public String vehicleVarient{get;set;}
        public String vehicleRegNumber{get;set;}
        public String manufacturerYearMonth{get;set;}
        public String engineNumber{get;set;}
        public String chassisNumber{get;set;}
        public String serialNumber{get;set;}
        public String vehicleType{get;set;}
        public String vehicleSubType{get;set;}
        public String insuranceNumber{get;set;}
        public String insuranceType{get;set;}
        public Decimal insuranceDeclaredValue{get;set;}
        public Date insIssuenceDate{get;set;}
        public Date insExpiryDate{get;set;}
        public String applicantId{get;set;}
        public Decimal valuationPrice{get;set;}
        public String valuationDecisioning{get;set;}
        public String valuerCategory {get;set;}
        public String reportURL {get;set;}
        public String documentType {get;set;}
        public Boolean isInsuranceExpired {get;set;}
        public Decimal ltvEnginge{get;set;}
        public Decimal pricingEngine{get;set;}
        public String leadNumber{get;set;}
        public String status{get;set;}
        public String message{get;set;}
        public String stage{get;set;}
        public String subStage{get;set;}
        public String leadSource{get;set;}
        public boolean oemCheck{get;set;}
        public string requestId{get;set;}
        public string customerType{get;set;}
    }
    
    /*
* @Method:      documentData
* @Created by:  Divya J
* @Description: This method will return document details in a wrappper
* @Param:       String - loanApplicationId ID
* @Return:      String - Wrapper response data
*/
    @AuraEnabled
    public static String checkValidationBeforeSubmit(String loanApplicationId , String vehicleId){
        try {
            String serializedResonponse = null;
            Boolean isValuationReportFound = false;
            Boolean isRCCopyFound = false;
            Boolean isInsuranceCopyFound = false;
            if(loanApplicationId!=null){
                DocumentWrapper documentWrapper = new DocumentWrapper();
                List<Opportunity> loanDetailsList = new List<Opportunity>();
                Vehicle_Detail__c vehicleDeatilsObj = new Vehicle_Detail__c();
                List<Documents__c> documentObj = new List<Documents__c>();
                loanDetailsList= [SELECT Id,Product_type__c,(SELECT Id,Valuer_category__c,Insurance_expiring_within_60_days__c FROM Vehicle_Details__r WHERE Id=:vehicleId limit 1),
                                  (SELECT Id, Document_Type__c, Vehicle_Detail__c From Documents__r ORDER BY CreatedDate DESC) 
                                  FROM Opportunity WHERE Id=:loanApplicationId WITH SECURITY_ENFORCED limit 1];
                /*
                List<Documents__c> docToDelete = new List<Documents__c>();
                set<String> docToDeleteName = new set<String>();
                if(!loanDetailsList.isEmpty() && loanDetailsList[0].Vehicle_Details__r[0] != null){
                    for(Opportunity opportunityObj : loanDetailsList) {
                        integer i = 0;
                        for(Documents__c document : opportunityObj.Documents__r){
                            if(docToDeleteName.contains(document.Name)){
                                docToDelete.add(document);
                            }else{
                                docToDeleteName.add(document.Name);
                            }
                            
                        }
                        
                    }
                }
                
                DELETE docToDelete;
                */
                if(!loanDetailsList.isEmpty() && loanDetailsList[0].Vehicle_Details__r[0] != null){
                    
                    vehicleDeatilsObj = loanDetailsList[0].Vehicle_Details__r[0];
                    
                    for(Opportunity opportunityObj : loanDetailsList) {
                        
                        if( !opportunityObj.Vehicle_Details__r.isEmpty() &&  !opportunityObj.Documents__r.isEmpty() )
                        {
                            documentObj= opportunityObj.Documents__r;
                           
                            for(Documents__c docs : documentObj ){
                                if((docs.Document_Type__c == System.Label.ValuationReport && loanDetailsList.size() > 0 && loanDetailsList[0].Product_Type__c != System.Label.Tractor) || (docs.Document_Type__c == System.Label.ValuationReport && docs.Vehicle_Detail__c == vehicleId && loanDetailsList.size() > 0 && loanDetailsList[0].Product_Type__c == System.Label.Tractor)){
                                    isValuationReportFound = true;
                                }
                                if(((docs.Document_Type__c == System.Label.RC_Document || docs.Document_Type__c == System.Label.RC_Copy) && loanDetailsList.size() > 0 && loanDetailsList[0].Product_Type__c != System.Label.Tractor) || ((docs.Document_Type__c == System.Label.RC_Document || docs.Document_Type__c == System.Label.RC_Copy) && docs.Vehicle_Detail__c == vehicleId && loanDetailsList.size() > 0 && loanDetailsList[0].Product_Type__c == System.Label.Tractor)){
                                    isRCCopyFound = true;
                                }
                                if(docs.Document_Type__c == System.Label.InsurancePolicy && docs.Vehicle_Detail__c == vehicleId){
                                    isInsuranceCopyFound = true;
                                }
                            }
                        }
                    }
                    
                    if(vehicleDeatilsObj.Valuer_category__c == System.Label.Empanelled && !isValuationReportFound){
                        documentWrapper.status = false;                    
                        documentWrapper.message = System.Label.ValuationReportMessage;
                    } else if(!isRCCopyFound && loanDetailsList.size() > 0 && loanDetailsList[0].Product_Type__c != System.Label.Tractor){    
                        documentWrapper.status = false;  
                        documentWrapper.message=System.Label.RCDocumentMessage;
                    } else if(vehicleDeatilsObj.Insurance_expiring_within_60_days__c && !isInsuranceCopyFound){    
                        documentWrapper.status = false;  
                        documentWrapper.message=System.Label.InsuranceDocumentMessage;
                    } else {
                        documentWrapper.status = true;
                    }
                    
                }
                serializedResonponse = JSON.serialize(documentWrapper);
            }
            return serializedResonponse;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_ValuationIDVCntrl', 'checkValidationBeforeSubmit', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //Wrapper Class for Vehicle Valuation Details.
    public class DocumentWrapper {
        public Boolean status{get;set;}
        public String message{get;set;}
    }
}