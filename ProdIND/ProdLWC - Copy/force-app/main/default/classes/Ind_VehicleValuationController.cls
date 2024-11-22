/**
* @Name         Ind_VehicleValuationController
* @Author       Khushiram
* @Company      Persistent Systems
* @Description  This class contains all methods related to Vehicle Valuation.
* Inputs:       None
* Test Class:   Ind_VehicleValuationCntrlTest
*/

public with sharing class Ind_VehicleValuationController {
        
    /*
    * @Method:      getVehicleValuationDetails
    * @Created by:  Khushiram
    * @Description: This method will return the details of vehicle owner and application owner.
    * @Param:       String - current Applicantion ID
    * @Return:      wrapper object containing all the details.
    */
    @AuraEnabled
    public static String getVehicleValuationDetails(String loanApplicationId,String tfvehicleid){
        try{
            if(loanApplicationId != null){
                VehicleValutationDetailsWrapper responseJSON = new VehicleValutationDetailsWrapper();
                Opportunity oppObject = [select Owner.Name,Owner.MobilePhone,Lead_number__c, Vehicle_Registration_Number__c, Product_Type__c,LastStageName__c, StageName, leadsource, Aggregator_Source__c, Vehicle_Type__c from Opportunity where id =: loanApplicationId];
                List<Documents__c> docObject = [select Document_Type__c, Name,(Select id from ContentDocumentLinks) from Documents__c where Opportunity_Relation__c =: loanApplicationId and (Name='Vehicle RC Copy' or Name='Vehicle Image') AND Is_Active__c = true AND Vehicle_Detail__c =: tfvehicleid];
                Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c();
                if(String.isNotBlank(tfvehicleid) && oppObject.Product_Type__c == System.Label.Tractor){
                    vehicleDetailObject = [select Id,isOEMDealerChecked__c,MFC_Request_Id__c,OEM_Dealer__c,Owner_Name__c,Insurance_declared_value__c,Owner_Contact_Number__c,Location_Of_Vehicle__c,Vehicle_Place_Of_Valuation__c,State__c,City__c,Valuer_category__c,Valuer__c,Valuer_code__c,SLA_Number__c,Color_of_Vehicle__c,KMS_Run__c,Selling_Price__c,Valuation_price__c,Purpose_of_IBB_fetch__c,Grid_value__c,Ben_Code__c,Executive_name__c,Executive_Contact_Number__c,Vehicle_Registration_number__c,Dealer_Sub_dealer_name__c,Manufacturer_Year_Month__c,Variant__c, Vehicle_Details_MFC_State_Master__c, Vehicle_Details_MFC_City_Master__c,MFC_valuation_Report_URL__c,Cost_of_the_body__c,Cost_of_the_Chassis__c,Loan_Application__r.Application_Type__c,Variant_Code__c,Vehicle_SubType__c from Vehicle_Detail__c where Loan_Application__c =:loanApplicationId and id =:tfvehicleid WITH SECURITY_ENFORCED limit 1]; //D2C Change added url
                }else{
                    vehicleDetailObject = [select Id,isOEMDealerChecked__c,MFC_Request_Id__c,OEM_Dealer__c,Owner_Name__c,Insurance_declared_value__c,Owner_Contact_Number__c,Location_Of_Vehicle__c,Vehicle_Place_Of_Valuation__c,State__c,City__c,Valuer_category__c,Valuer__c,Valuer_code__c,SLA_Number__c,Color_of_Vehicle__c,KMS_Run__c,Selling_Price__c,Valuation_price__c,Purpose_of_IBB_fetch__c,Grid_value__c,Ben_Code__c,Executive_name__c,Executive_Contact_Number__c,Vehicle_Registration_number__c,Dealer_Sub_dealer_name__c,Manufacturer_Year_Month__c,Variant__c, Vehicle_Details_MFC_State_Master__c, Vehicle_Details_MFC_City_Master__c,MFC_valuation_Report_URL__c from Vehicle_Detail__c where Loan_Application__c =:loanApplicationId WITH SECURITY_ENFORCED limit 1]; //D2C Change added url
                }
                responseJSON.vehicleRecordId = vehicleDetailObject.Id;
                responseJSON.ownerName = vehicleDetailObject.Owner_Name__c;
                responseJSON.ownerContactNumber = vehicleDetailObject.Owner_Contact_Number__c;
                responseJSON.vehiclePlaceOfValuation = vehicleDetailObject.Vehicle_Place_Of_Valuation__c;
                responseJSON.state = vehicleDetailObject.State__c;
                responseJSON.city = vehicleDetailObject.City__c;
                responseJSON.benCode = vehicleDetailObject.Ben_Code__c;
                responseJSON.executiveName =  oppObject.Owner.Name;
                responseJSON.executiveContactNumber =  oppObject.Owner.MobilePhone;
                responseJSON.locationOfVehicle = vehicleDetailObject.Location_Of_Vehicle__c;
                responseJSON.insuranceDeclaredValue = vehicleDetailObject.Insurance_declared_value__c;
                responseJSON.leadNumber = oppObject.Lead_number__c; 
                if(oppObject.Product_Type__c == System.Label.Tractor){
                    responseJSON.vehicleRegNo =vehicleDetailObject.Vehicle_Registration_Number__c; 
                }else{
                responseJSON.vehicleRegNo =oppObject.Vehicle_Registration_Number__c; 
                }
                responseJSON.productType = oppObject.Product_Type__c;
                responseJSON.lastStage = oppObject.LastStageName__c;
                responseJSON.currentStageName = oppObject.StageName;
                responseJSON.valCat = vehicleDetailObject.Valuer_category__c;
                responseJSON.valuer = vehicleDetailObject.Valuer__c;
                responseJSON.valCode = vehicleDetailObject.Valuer_code__c;
                responseJSON.slaNum = vehicleDetailObject.SLA_Number__c;
                responseJSON.colOfVeh = vehicleDetailObject.Color_of_Vehicle__c;
                responseJSON.kmsRun = vehicleDetailObject.KMS_Run__c;
                responseJSON.sellPrice = vehicleDetailObject.Selling_Price__c;
                responseJSON.valPrice = vehicleDetailObject.Valuation_price__c;
                responseJSON.purposeIbb = vehicleDetailObject.Purpose_of_IBB_fetch__c;
                responseJSON.gridVal = vehicleDetailObject.Grid_value__c;
                responseJSON.oemCheck = vehicleDetailObject.OEM_Dealer__c;
                responseJSON.dealerName = vehicleDetailObject.Dealer_Sub_dealer_name__c;
                responseJSON.manufactureYear = vehicleDetailObject.Manufacturer_Year_Month__c;
                responseJSON.variantName = vehicleDetailObject.Variant__c;
                responseJSON.requestId = vehicleDetailObject.MFC_Request_Id__c;
                responseJSON.isOEMDealerChecked = vehicleDetailObject.isOEMDealerChecked__c;
                //D2C Change
                responseJSON.isD2C = oppObject.leadsource == 'D2C' ? true : false;
                responseJSON.mfcUrl = vehicleDetailObject.MFC_valuation_Report_URL__c;
                responseJSON.aggregatorSource = oppObject.Aggregator_Source__c;
                if(oppObject.Product_Type__c == System.Label.Tractor){
                    responseJSON.costOfBody = Integer.valueOf(vehicleDetailObject.Cost_of_the_body__c); //  Neeraj Mehethrajkar - SFTRAC-60
                    responseJSON.costOfChassis = Integer.valueOf(vehicleDetailObject.Cost_of_the_Chassis__c); //  Neeraj Mehethrajkar - SFTRAC-60
                    responseJSON.vehicleType = oppObject.Vehicle_type__c; //  Neeraj Mehethrajkar - SFTRAC-60
                    responseJSON.applicationType = vehicleDetailObject.Loan_Application__r.Application_Type__c; //  Neeraj Mehethrajkar - SFTRAC-60
                    responseJSON.varientCode = vehicleDetailObject.Variant_Code__c;
                    responseJSON.vehicleSubType = vehicleDetailObject.Vehicle_SubType__c;
                }
                //EO D2C Change
                
                if(!docObject.isEmpty()){
                    for(Documents__c doc:docObject){
                        if(doc.Document_Type__c=='Vehicle Image' && doc.ContentDocumentLinks.size() > 0){
                            responseJSON.vehicleImage=true;
                        } else if(doc.Document_Type__c=='Vehicle RC Copy' && doc.ContentDocumentLinks.size() > 0){
                            responseJSON.rcCopy= true;
                        }
                    }
                }

                String cityMasterId = vehicleDetailObject.Vehicle_Details_MFC_State_Master__c;
                String stateMasterId = vehicleDetailObject.Vehicle_Details_MFC_City_Master__c;
                responseJSON.cityStateDetails = Ind_VehicleValuationController.getMFCCityStateDetails(cityMasterId, stateMasterId);

                String serializedResponse = JSON.serialize(responseJSON);
                return serializedResponse;
            }
            return null;
        } catch(Exception e){
            system.Debug('Here error: '+ e);
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'getVehicleValuationDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
/*
    * @Method:      getVehicleValuationDetailsForTractor
    * @Created by:  Satyam
    * @Description: This method will return the details of vehicle owner and application owner.
    * @Param:       String - current Applicantion ID
    * @Return:      wrapper object containing all the details.
    */
    @AuraEnabled
    public static String getVehicleValuationDetailsForTractor(String loanApplicationId,String VehicleId){
        try{
            if(loanApplicationId != null){
                List<VehicleValutationDetailsWrapper> responseJSONList = new List<VehicleValutationDetailsWrapper>();
                Opportunity oppObject = [select Owner.Name,Owner.MobilePhone,Lead_number__c, Vehicle_Registration_Number__c, Product_Type__c,LastStageName__c, StageName, leadsource, Aggregator_Source__c from Opportunity where id =: loanApplicationId];
                List<Documents__c> docList = [select Document_Type__c,Vehicle_Detail__c, Name,(Select id from ContentDocumentLinks) from Documents__c where Opportunity_Relation__c =: loanApplicationId and (Name='Vehicle RC Copy' or Name='Vehicle Image') AND Is_Active__c = true];
                List<Vehicle_Detail__c> vehicleDetailList = [select Id,isOEMDealerChecked__c,MFC_Request_Id__c,OEM_Dealer__c,Owner_Name__c,Insurance_declared_value__c,Owner_Contact_Number__c,Location_Of_Vehicle__c,Vehicle_Place_Of_Valuation__c,State__c,City__c,Valuer_category__c,Valuer__c,Vehicle_SubType__c,Valuer_code__c,SLA_Number__c,Color_of_Vehicle__c,KMS_Run__c,Selling_Price__c,Valuation_price__c,Purpose_of_IBB_fetch__c,Grid_value__c,Ben_Code__c,Executive_name__c,Executive_Contact_Number__c,Vehicle_Registration_number__c,Dealer_Sub_dealer_name__c,Manufacturer_Year_Month__c,Variant__c,Make__c,Variant_Code__c, Vehicle_Details_MFC_State_Master__c, Vehicle_Details_MFC_City_Master__c,MFC_valuation_Report_URL__c from Vehicle_Detail__c where Loan_Application__c =:loanApplicationId AND Vehicle_SubType__c != 'Implement' WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC limit 10]; //D2C Change added url
                for(Vehicle_Detail__c vehicleDetailObject: vehicleDetailList){
                    VehicleValutationDetailsWrapper responseJSON = new VehicleValutationDetailsWrapper();
                    responseJSON.vehicleRecordId = vehicleDetailObject.Id;
                    responseJSON.ownerName = vehicleDetailObject.Owner_Name__c;
                    responseJSON.ownerContactNumber = vehicleDetailObject.Owner_Contact_Number__c;
                    responseJSON.vehiclePlaceOfValuation = vehicleDetailObject.Vehicle_Place_Of_Valuation__c;
                    responseJSON.state = vehicleDetailObject.State__c;
                    responseJSON.city = vehicleDetailObject.City__c;
                    responseJSON.benCode = vehicleDetailObject.Ben_Code__c;
                    responseJSON.executiveName =  oppObject.Owner.Name;
                    responseJSON.executiveContactNumber =  oppObject.Owner.MobilePhone;
                    responseJSON.locationOfVehicle = vehicleDetailObject.Location_Of_Vehicle__c;
                    responseJSON.insuranceDeclaredValue = vehicleDetailObject.Insurance_declared_value__c;
                    responseJSON.leadNumber = oppObject.Lead_number__c; 
                    responseJSON.vehicleRegNo =oppObject.Vehicle_Registration_Number__c; 
                    responseJSON.productType = oppObject.Product_Type__c;
                    responseJSON.lastStage = oppObject.LastStageName__c;
                    responseJSON.currentStageName = oppObject.StageName;
                    responseJSON.valCat = vehicleDetailObject.Valuer_category__c;
                    responseJSON.valuer = vehicleDetailObject.Valuer__c;
                    responseJSON.valCode = vehicleDetailObject.Valuer_code__c;
                    responseJSON.slaNum = vehicleDetailObject.SLA_Number__c;
                    responseJSON.colOfVeh = vehicleDetailObject.Color_of_Vehicle__c;
                    responseJSON.kmsRun = vehicleDetailObject.KMS_Run__c;
                    responseJSON.sellPrice = vehicleDetailObject.Selling_Price__c;
                    responseJSON.valPrice = vehicleDetailObject.Valuation_price__c;
                    responseJSON.purposeIbb = vehicleDetailObject.Purpose_of_IBB_fetch__c;
                    responseJSON.gridVal = vehicleDetailObject.Grid_value__c;
                    responseJSON.oemCheck = vehicleDetailObject.OEM_Dealer__c;
                    responseJSON.dealerName = vehicleDetailObject.Dealer_Sub_dealer_name__c;
                    responseJSON.manufactureYear = vehicleDetailObject.Manufacturer_Year_Month__c;
                    responseJSON.variantName = vehicleDetailObject.Variant__c;
                    responseJSON.requestId = vehicleDetailObject.MFC_Request_Id__c;
                    responseJSON.isOEMDealerChecked = vehicleDetailObject.isOEMDealerChecked__c;
                    responseJSON.isD2C = oppObject.leadsource == 'D2C' ? true : false;
                    responseJSON.mfcUrl = vehicleDetailObject.MFC_valuation_Report_URL__c;
                    responseJSON.aggregatorSource = oppObject.Aggregator_Source__c;
                    responseJSON.vehicleSubType = vehicleDetailObject.Vehicle_SubType__c;
                    if(!docList.isEmpty()){
                        for(Documents__c doc:docList){
                            if(doc.Vehicle_Detail__c == vehicleDetailObject.Id && doc.Document_Type__c=='Vehicle Image' && doc.ContentDocumentLinks.size() > 0){
                                responseJSON.vehicleImage=true;
                            } else if(doc.Vehicle_Detail__c == vehicleDetailObject.Id && doc.Document_Type__c=='Vehicle RC Copy' && doc.ContentDocumentLinks.size() > 0){
                                responseJSON.rcCopy= true;
                            }
                        }
                    }
                String cityMasterId = vehicleDetailObject.Vehicle_Details_MFC_State_Master__c;
                String stateMasterId = vehicleDetailObject.Vehicle_Details_MFC_City_Master__c;
                if(oppObject.Product_Type__c == 'Tractor'){
                    responseJSON.accordionLabel = 'Vehicle Valuation '+vehicleDetailObject.Make__c + ' ' + vehicleDetailObject.Variant_Code__c + ' ' + vehicleDetailObject.Variant__c;
                }
                responseJSON.cityStateDetails = Ind_VehicleValuationController.getMFCCityStateDetails(cityMasterId, stateMasterId);
                    responseJSONList.add(responseJSON);
                }
                String serializedResponse = JSON.serialize(responseJSONList);
                return serializedResponse;
            }
            return null;
        } catch(Exception e){
            system.Debug('Here error: '+ e);
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'getVehicleValuationDetailsForTractor', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    /*
    * @Method:      getMFCCityStateDetails
    * @Created by:  Sanketkumar
    * @Description: To get MFC City and State Details
    * @Param:       String - State Id, String City Id
    * @Return:      Map of State and City Object
    */
    @AuraEnabled
    public static Map<String, Object> getMFCCityStateDetails(String stateMasterId, String cityMasterId){
        try{
            Map<String,Object> cityStateListMap = new Map<String, Object>(); 

            if(Schema.sObjectType.MFC_State_Master__c.isAccessible() && Schema.sObjectType.MFC_City_Master__c.isAccessible()) {
                if(stateMasterId != null && stateMasterId != ''){
                    MFC_State_Master__c mFCStateObj = [SELECT Id, Name, State_Code__c, State_Name_Code__c FROM MFC_State_Master__c WHERE Id = :stateMasterId WITH SECURITY_ENFORCED];
                    cityStateListMap.put('stateDetails', mFCStateObj);
                }
                
                if(cityMasterId != null  && cityMasterId != ''){
                    MFC_City_Master__c mFCCityObj = [SELECT Id, Name, City_Code__c, City_Name_Code__c, State_Code__c, State_Name__c FROM MFC_City_Master__c WHERE Id = :cityMasterId WITH SECURITY_ENFORCED];
                    cityStateListMap.put('CityDetails', mFCCityObj);
                }
            }

            return cityStateListMap;
        }catch(Exception e){
            system.Debug('Here error: '+ e);
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'getMFCCityStateDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
        
    //Wrapper Class for Vehicle Valuation Details.
    public class VehicleValutationDetailsWrapper {
        public String requestId{get;set;}
        public String vehicleRecordId{get;set;}
        public String ownerName{get;set;}
        public String ownerContactNumber{get;set;}
        public String vehiclePlaceOfValuation{get;set;}
        public String state{get;set;}
        public String city{get;set;}
        public String benCode{get;set;}
        public String executiveName{get;set;}
        public String executiveContactNumber{get;set;}
        public String locationOfVehicle{get;set;}
        public String leadNumber{get;set;} 
        public String vehicleRegNo{get;set;} 
        public String productType{get;set;}
        public String valCat{get;set;}
        public String valuer{get;set;}
        public String valCode{get;set;}
        public Decimal slaNum{get;set;}
        public String colOfVeh{get;set;}
        public String kmsRun{get;set;}
        public Decimal sellPrice{get;set;}
        public Decimal insuranceDeclaredValue{get;set;}
        public Decimal valPrice{get;set;}
        public String purposeIbb{get;set;}
        public Decimal gridVal{get;set;}
        public Boolean oemCheck{get;set;}
        public Boolean vehicleImage{get;set;}
        public Boolean rcCopy{get;set;}
        String lastStage {get;set;}
        String currentStageName {get;set;}
        String dealerName {get;set;}
        String manufactureYear {get;set;}
        String variantName {get;set;}
        public Map<String, Object> cityStateDetails{get;set;}
        public Boolean isOEMDealerChecked {get;set;}
        public String accordionLabel {get;set;} //SFTRAC-237
        public Boolean isD2C {get;set;}
        public String mfcUrl {get;set;}
        public String aggregatorSource {get;set;}
        public Integer costOfBody {get;set;} //  Neeraj Mehethrajkar - SFTRAC-60
        public Integer costOfChassis {get;set;} //  Neeraj Mehethrajkar - SFTRAC-60
        public String vehicleType {get;set;} //  Neeraj Mehethrajkar - SFTRAC-60
        public String applicationType {get;set;} //  Neeraj Mehethrajkar - SFTRAC-60
        public String varientCode {get;set;}
        public String vehicleSubType {get;set;}
	}
    
    
    /*
    * @Method:      checkVehicleDocumentsDetails
    * @Created by:  Vinita K.
    * @Description: This method will be call while saving Vehicle Valuation details to check if RC Doc and Insurance Policy is captured correctly
    * @Param:       String - current Applicantion ID
    * @Return:      wrapper object containing required details(responseMessage).
    */
    @AuraEnabled
    public static String checkVehicleDocumentsDetails(String loanApplicationId){
        try{ 
            Boolean isTractor = false;
            if(loanApplicationId != null){
                sendResponseWrapper sendResponseElement = new sendResponseWrapper();
                List<Documents__c> listDocumentsRecord = [ SELECT Id,(Select id from ContentDocumentLinks),Document_Type__c FROM Documents__c WHERE Opportunity_Relation__c=:loanApplicationId and (Document_Type__c =: System.label.RC_Document or Document_Type__c=:System.label.RC_Copy OR Document_Type__c = :System.label.VehicleImage) and Is_Active__c = true  WITH SECURITY_ENFORCED];

                Boolean isRCDocumentsWithFiles = true;
                Boolean isVehicleDocumentsWithFiles = true;
                for (Documents__c doc : listDocumentsRecord) {
                    if((doc.Document_Type__c == System.label.RC_Document || doc.Document_Type__c == System.label.RC_Copy) && doc.ContentDocumentLinks.size() == 0){
                        isRCDocumentsWithFiles = false;
                        break;
                    }
                    if(doc.Document_Type__c == System.label.VehicleImage && doc.ContentDocumentLinks.size() == 0){
                        isVehicleDocumentsWithFiles = false;
                        break;
                    }
                }
                Opportunity loanApp  =[select Id,Product_Type__c from Opportunity where Id=:loanApplicationId Limit 1];
                if(loanApp.Product_Type__c == 'Tractor'){
                    isTractor = true;
                }
                if(listDocumentsRecord.isEmpty() && !isTractor){
                    sendResponseElement.status=false;
                    sendResponseElement.message= 'Please upload all required documents!';
                    String serializedResponseVehicle = JSON.serialize(sendResponseElement);
                    return serializedResponseVehicle;
                    // for(Documents__c doc:listDocumentsRecord){
                        //if((doc.Document_Type__c=='RC Document' && doc.Is_Photocopy__c==true) || doc.Document_Type__c=='Vehicle RC Copy'){
                            // sendResponseElement.message= System.Label.Original_Copy_for_RC_Document_is_not_Captured;
                            // sendResponseElement.status=true;
                            // String serializedResponseVehicle = JSON.serialize(sendResponseElement);
                            // return serializedResponseVehicle;
                        //}
                        // if(doc.Document_Type__c=='Vehicle Insurance Policy'){
                        //     sendResponseElement.message= System.Label.Vehicle_Insurance_Policy_not_Captured;
                        //     sendResponseElement.status=true;
                        // }
                } else if(isRCDocumentsWithFiles == false){
                    sendResponseElement.status=false;
                    sendResponseElement.message= System.label.RC_Upload_Mandatory;
                    String serializedResponseVehicle = JSON.serialize(sendResponseElement);
                    return serializedResponseVehicle;
                }else if(isVehicleDocumentsWithFiles == false){
                    sendResponseElement.status=false;
                    sendResponseElement.message= 'Please Upload Vehicle Image!';
                    String serializedResponseVehicle = JSON.serialize(sendResponseElement);
                    return serializedResponseVehicle;
                }
                sendResponseElement.status=true;                
                String serializedResponseVehicle = JSON.serialize(sendResponseElement);
                return serializedResponseVehicle;
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', ' checkVehicleDocumentsDetails ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    
    //Wrapper class for checkVehicleDocumentsDetails response.
    public class sendResponseWrapper{
        String message {get;set;}
        Boolean status {get;set;}
    }
    
    
    @AuraEnabled
    public static String checkIBBAPIAttempts(String loanApplicationId){ 
        try{
            if(loanApplicationId != null){
              
                System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('IBB_Internal_And_Master_Attempts'); 
                Vehicle_Detail__c vehicleDetailObject = [select IBB_Internal_API_Attempts__c from Vehicle_Detail__c where Loan_Application__c =:loanApplicationId WITH SECURITY_ENFORCED];
                
                if(vehicleDetailObject.IBB_Internal_API_Attempts__c >= metadata.Number_Of_Attempts__c){
                   return System.label.Retry_Exhausted;
                   
                }else{
                    if(vehicleDetailObject.IBB_Internal_API_Attempts__c == null){
                        vehicleDetailObject.IBB_Internal_API_Attempts__c = 0;
                    }
                    if(vehicleDetailObject.IBB_Internal_API_Attempts__c < metadata.Number_Of_Attempts__c ){
						vehicleDetailObject.IBB_Internal_API_Attempts__c += 1;
						 if (Schema.sObjectType.Vehicle_Detail__c.isUpdateable()){
							update vehicleDetailObject; 
						}
						return 'success';
                    }
                    
                }
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', ' callIBBInternalAPI ', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    
    
    /*
    * @Method:      getPicklistValuesForValuer
    * @Created by:  
    * @Description: 
    * @Param:       
    * @Return:      
    */
     @AuraEnabled(cacheable = true)
    public static List<Beneficiary_Category__c> getPicklistValuesForValuer(){
        try{ 
           	List<Beneficiary_Category__c> picklistValues = [Select Ben_code__r.Ben_code__c,Ben_code__r.Name from Beneficiary_Category__c where Name='VAL'];
			return picklistValues;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', ' getPicklistValuesForValuer ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    
    @AuraEnabled
    public static Boolean setOEMFlag(String loanApplicationId, String dealerName,String vehicleId){
        try{ 
            Vehicle_Detail__c vehicleDetailObject = [select Id,OEM_Dealer__c from Vehicle_Detail__c 
                                                        where Loan_Application__c =:loanApplicationId and id=:vehicleId WITH SECURITY_ENFORCED limit 1];
                                                         
            List<Benefi__c> benObj = [select id, Ben_code__c, Name from Benefi__c 
                                        where id in (select Beneficiary_Master__c from Beneficiary_Manufacturer__c
                                                     where Manufacturer__r.Manufacturer_code__c = 'U01') 
                                        and Beneficiary__c = 'DLR' and Status_Flag__c = 'L' and Name =: dealerName];

            if(!benObj.isEmpty()){
                vehicleDetailObject.OEM_Dealer__c = true;
                if (Schema.sObjectType.Vehicle_Detail__c.isUpdateable()){
                    update vehicleDetailObject; 
                    return true;
                } else{
                    return false; // On event of update failure
                }
            }else{
                vehicleDetailObject.OEM_Dealer__c = false;//CISP-3609
                update vehicleDetailObject;//CISP-3609
                return false;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'setOEMFlag ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }

    /*
    * @Method:      fetchGridValue
    * @Created by:  Vinita
    * @Description: This method will return the Market Value from Product Master on the basis of variant and vehicle age.
    * @Param:       String - vehicleAge
    * @Param:       String - variantName from Asset details
    * @Return:      Integer - Market Value Price
    */    
    @AuraEnabled
    public static Double fetchGridValue(Integer vehicleAge, String variantName){
        try{ 
            List<Product2> prodList = [Select Id,Name,Type__c,Market_Value_12year__c,Market_Value_11year__c, Market_Value_10year__c, Market_Value_9year__c, Market_Value_8year__c, Market_Value_7year__c, Market_Value_6year__c, Market_Value_5year__c, Market_Value_4year__c, Market_Value_3year__c, Market_Value_2year__c, Market_Value_1year__c from Product2 where Type__c ='Variant' and Name =:variantName];
            Double marketValue=0;
            if(vehicleAge!=null && variantName != null){
                switch on vehicleAge {
                    when 1 {
                        marketValue = prodList[0].Market_Value_1year__c;                        
                    }
                    when 2 {
                        marketValue = prodList[0].Market_Value_2year__c;                        
                    }
                    when 3 {
                        marketValue = prodList[0].Market_Value_3year__c;                        
                    }
                    when 4 {
                        marketValue = prodList[0].Market_Value_4year__c;                        
                    }
                    when 5 {
                        marketValue = prodList[0].Market_Value_5year__c;                        
                    }
                    when 6 {
                        marketValue = prodList[0].Market_Value_6year__c;                        
                    }
                    when 7 {
                        marketValue = prodList[0].Market_Value_7year__c;                        
                    }
                    when 8 {
                        marketValue = prodList[0].Market_Value_8year__c;                        
                    }
                    when 9 {
                        marketValue = prodList[0].Market_Value_9year__c;                        
                    }
                    when 10 {
                        marketValue = prodList[0].Market_Value_10year__c;                        
                    }
                    when 11 {
                        marketValue = prodList[0].Market_Value_11year__c;                        
                    }
                    when 12 {
                        marketValue = prodList[0].Market_Value_12year__c;                        
                    }
                    when else {
                        marketValue = 0;
                    }
                }
            } else if(variantName == null || vehicleAge == null ){
                return -1;
            }
            return marketValue;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'fetchGridValue', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    //CISP-2455
    /*
    * @Method:      getMFCUniqueResponse
    * @Created by:  Poonam
    * @Description: This method will return MFC response based on VehicleReg No.
    * @Param:       String - VehicleRegNo
    * @Return:      Object
    */  
    
    @AuraEnabled
    public static MFC_Response__c getMFCUniqueResponse(String vehicleRegNo){
        try{
            List<MFC_Response__c> mfcResponseList = [SELECT Id,CreatedDate,LastModifiedDate,MFC_Response_Data__c FROM MFC_Response__c where Name =:vehicleRegNo AND (CreatedDate = LAST_N_Days:30 OR LastModifiedDate = LAST_N_DAYS:30)];
            if(mfcResponseList.size()>0){
                return mfcResponseList[0];
            }
            return null;
            
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'getMFCUniqueResponse', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    /*
    * @Method:      saveMFCResponseRecord
    * @Created by:  Poonam
    * @Description: This method will create MFC response.
    * @Param:       String - VehicleRegNo, String res
    * @Return:      void
    */  
    
    @AuraEnabled
    public static void saveMFCResponseRecord(String vehiRegNo,String res){
        try{
            List<MFC_Response__c> mfcResponseList = [SELECT Id,CreatedDate,LastModifiedDate,MFC_Response_Data__c FROM MFC_Response__c where Name =:vehiRegNo];
            if(mfcResponseList.size()>0){
                mfcResponseList[0].MFC_Response_Data__c = res;
                update mfcResponseList[0];
            }else{
                MFC_Response__c mfcObj = new MFC_Response__c();
                mfcObj.name = vehiRegNo;
                mfcObj.MFC_Response_Data__c = res;
                insert mfcObj;
            }
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'saveMFCResponseRecord', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    //CISP-2455
    //
    @AuraEnabled //CISP-2737
    public static Opportunity getParentLeadNumber(String leadId){
        try {
            List<Opportunity> oppList = [Select Id,Parent_Loan_Application__c, Is_Revoked__c,Parent_Loan_Application__r.Lead_number__c,Parent_Loan_Application__r.Is_Revoked__c  from Opportunity where Id =: leadId];
            if(oppList.size() > 0){
                return oppList[0];
            }
            return null;
        } catch (Exception e) {
              ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'getParentLeadNumber', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }//CISP-2737

    @AuraEnabled
    public static Double fetchGridValueForTractor(String loanApplicationId, Integer vehicleAge, String variantCode){
        try{ 
            String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1].Agent_BL_code__c, 'T');
            System.debug('cfdStateCode' + cfdStateCode);
            List<TBM_Product_Variant_dt__c> tbmProdVarient = [SELECT Id, State_Code__c, Dealer_Landed_Price__c, Market_Value_20year__c, Market_Value_19year__c, Market_Value_18year__c, Market_Value_17year__c, Market_Value_16year__c, Market_Value_15year__c, Market_Value_14year__c, Market_Value_13year__c, Market_Value_12year__c,Market_Value_11year__c, Market_Value_10year__c, Market_Value_9year__c, Market_Value_8year__c, Market_Value_7year__c, Market_Value_6year__c, Market_Value_5year__c, Market_Value_4year__c, Market_Value_3year__c, Market_Value_2year__c, Market_Value_1year__c, Market_Value_0year__c FROM TBM_Product_Variant_dt__c WHERE Product_Variant_Code__c =: variantCode AND State_Code__c=:cfdStateCode];
            System.debug('tbmProdVarient' + tbmProdVarient);
            Double marketValue = 0;
            if(tbmProdVarient.size() > 0){
                switch on vehicleAge {
                    when 1 {
                        marketValue = tbmProdVarient[0].Market_Value_1year__c;                        
                    }
                    when 2 {
                        marketValue = tbmProdVarient[0].Market_Value_2year__c;                        
                    }
                    when 3 {
                        marketValue = tbmProdVarient[0].Market_Value_3year__c;                        
                    }
                    when 4 {
                        marketValue = tbmProdVarient[0].Market_Value_4year__c;                        
                    }
                    when 5 {
                        marketValue = tbmProdVarient[0].Market_Value_5year__c;                        
                    }
                    when 6 {
                        marketValue = tbmProdVarient[0].Market_Value_6year__c;                        
                    }
                    when 7 {
                        marketValue = tbmProdVarient[0].Market_Value_7year__c;                        
                    }
                    when 8 {
                        marketValue = tbmProdVarient[0].Market_Value_8year__c;                        
                    }
                    when 9 {
                        marketValue = tbmProdVarient[0].Market_Value_9year__c;                        
                    }
                    when 10 {
                        marketValue = tbmProdVarient[0].Market_Value_10year__c;                        
                    }
                    when 11 {
                        marketValue = tbmProdVarient[0].Market_Value_11year__c;                        
                    }
                    when 12 {
                        marketValue = tbmProdVarient[0].Market_Value_12year__c;                        
                    }
                    when 13 {
                        marketValue = tbmProdVarient[0].Market_Value_13year__c;                        
                    }
                    when 14 {
                        marketValue = tbmProdVarient[0].Market_Value_14year__c;                        
                    }
                    when 15 {
                        marketValue = tbmProdVarient[0].Market_Value_15year__c;                        
                    }
                    when 16 {
                        marketValue = tbmProdVarient[0].Market_Value_16year__c;                        
                    }
                    when 17 {
                        marketValue = tbmProdVarient[0].Market_Value_17year__c;                        
                    }
                    when 18 {
                        marketValue = tbmProdVarient[0].Market_Value_18year__c;                        
                    }
                    when 19 {
                        marketValue = tbmProdVarient[0].Market_Value_19year__c;                        
                    }
                    when 20 {
                        marketValue = tbmProdVarient[0].Market_Value_20year__c;                        
                    }
                    when else {
                        marketValue = tbmProdVarient[0].Market_Value_0year__c;
                    }
                }
            }
            return marketValue;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_VehicleValuationController', 'fetchGridValueForTractor', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
}