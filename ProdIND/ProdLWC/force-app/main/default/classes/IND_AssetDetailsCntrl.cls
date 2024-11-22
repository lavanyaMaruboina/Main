/**
* @Name         IND_AssetDetailsCntrl
* @Author       Neha Gosavi
* @Company      Persistent Systems
* @Description  This class contains all methods related to Asset Details
* Inputs:       None
* Test Class:   IND_AssetDetailsCntrlTest
* History:      None
*/
public with sharing class IND_AssetDetailsCntrl {
	@AuraEnabled
    public static String loadAssetDetailsData(String loanApplicationId){
        try {
            if(loanApplicationId!=null){
                List<AssetDetailsWrapper> assetDetailwrapperList = new List<AssetDetailsWrapper>();
                AssetDetailsWrapper assetDetailElement = new AssetDetailsWrapper();
                Opportunity oppObj=[ SELECT Id,LeadSource,Parent_Loan_Application__c,Parent_Loan_Application__r.LeadSource ,Agent_BL_code__c,Lead_number__c,Product_Type__c,CreatedDate, Vehicle_Type__c,Vehicle_Sub_Category__c, Parent_Deal_number__c,Vehicle_Registration_Number__c, LastStageName__c, StageName,isTopUpLoan__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];//CISP-3431
                
                List<Applicant__c> applicantList = new List<Applicant__c>();
                List<Vehicle_Detail__c> vehicleObjList = new List<Vehicle_Detail__c>();
           		if (Schema.sObjectType.Applicant__c.isAccessible() && Schema.sObjectType.Vehicle_Detail__c.isAccessible() && Schema.sObjectType.Retry_Count__c.isAccessible()) {
                	applicantList = [SELECT ID,Name FROM Applicant__c WHERE Applicant_Type__c= 'Borrower' AND Opportunity__c = :loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                    vehicleObjList = [ SELECT Id,Ben_Code__c,Vehicle_type__c,Product__c, Purpose_of_purchase__c, Vehicle_registered_in_the_name_of__c, Vehicle_Registration_number__c, Make__c, Model__c, Variant__c, Dealer_Sub_dealer_name__c, Invoice_in_the_name_of__c,Product_Segment__c,Usage_Type__c, Lien_in_favor_of__c, RC_retention_applicable__c, RC_Hold_Amount__c, Number_of_ownerships__c, Manufacturer_Year_Month__c, Last_owner_name__c, Engine_number__c, Chassis_number__c,  Is_Get_Vehicle_Details_Successful__c,Is_D_Category_Vehicle__c,Make_Code__c,Model_Code__c,Variant_Code__c,RC_limit_enabled_Dealer__c,Vehicle_SubType__c,Serial_number__c,Vehicle_Delivered__c,Vehicle_SubCategory__c,Parent_Deal_Number__c,Distance__c,Gross_Receipts_Month__c,Number_of_vehicle_owned__c,Expense__c,Vehicle_Route__c,Route__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];//CISP-2794
                }
                
                List<String> picklistFieldList = new List<String> {'Purpose_of_purchase__c', 'Vehicle_registered_in_the_name_of__c', 'Usage_Type__c', 'Lien_in_favor_of__c', 'RC_retention_applicable__c', 'Number_of_ownerships__c'};
                Map<String, List<PicklistDataWrapper>> picklistFieldValMap = IND_AssetDetailsCntrl.getPicklistValues('Vehicle_Detail__c',picklistFieldList);

                if(Test.isRunningTest()){
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }

                if(!vehicleObjList.isEmpty()){
                    if(oppObj.Product_Type__c == 'Tractor'){
                        for(Vehicle_Detail__c vehicleRec: vehicleObjList){
                            AssetDetailsWrapper assetDetailWrapper = new AssetDetailsWrapper();

                            assetDetailWrapper.vehicleDetailId = vehicleRec.Id;
                            assetDetailWrapper.vehicleMake = vehicleRec.Make__c;
                            assetDetailWrapper.vehicleModel = vehicleRec.Model__c;
                            assetDetailWrapper.vehicleVarient = vehicleRec.Variant__c;
                            assetDetailWrapper.purposeOfPurchase = vehicleRec.Purpose_of_purchase__c;
                            assetDetailWrapper.dealerSubdealerName = vehicleRec.Dealer_Sub_dealer_name__c;
                            //assetDetailWrapper.invoiceInNameOf = vehicleRec.Invoice_in_the_name_of__c;
                            assetDetailWrapper.vehicleInNameOf = vehicleRec.Vehicle_registered_in_the_name_of__c;
                            assetDetailWrapper.usageType = vehicleRec.Usage_Type__c;
                            assetDetailWrapper.vehicleRegNumber = vehicleRec.Vehicle_Registration_number__c;
                            assetDetailWrapper.LienInFavorOf = vehicleRec.Lien_in_favor_of__c;
                            assetDetailWrapper.rcRetentionApplicable = vehicleRec.RC_retention_applicable__c;
                            assetDetailWrapper.rcHoldAmount = vehicleRec.RC_Hold_Amount__c; //SFTRAC-1715
                            assetDetailWrapper.numberOfOwnerships = vehicleRec.Number_of_ownerships__c;
                            assetDetailWrapper.manufacturerYearMonth = vehicleRec.Manufacturer_Year_Month__c;
                            assetDetailWrapper.lastOwnerName = vehicleRec.Last_owner_name__c;
                            assetDetailWrapper.engineNumber = vehicleRec.Engine_number__c;
                            assetDetailWrapper.chassisNumber = vehicleRec.Chassis_number__c;
                            assetDetailWrapper.isGetVehicleDetailsSuccessful = vehicleRec.Is_Get_Vehicle_Details_Successful__c;
                            assetDetailWrapper.isDCategoryVehicle = vehicleRec.Is_D_Category_Vehicle__c;
                            assetDetailWrapper.benCode = vehicleRec.Ben_Code__c; //CISP-2353
                            assetDetailWrapper.makeCode = vehicleRec.Make_Code__c;//CISP-2794
                            assetDetailWrapper.modelCode = vehicleRec.Model_Code__c;//CISP-2794
                            assetDetailWrapper.variantCode = vehicleRec.Variant_Code__c;//CISP-2794
                            assetDetailWrapper.vehicleSubType = vehicleRec.Vehicle_SubType__c;//SFTRAC - 26
                            assetDetailWrapper.vehicleSerialNumber = vehicleRec.Serial_number__c;
                            assetDetailWrapper.picklistFieldValueMap = picklistFieldValMap;

                            assetDetailWrapper.productType = oppObj.Product_Type__c;
                            assetDetailWrapper.vehicleType = oppObj.Vehicle_Type__c;
                            
                            assetDetailWrapper.vehicleSubCategory = vehicleRec.Vehicle_SubCategory__c;
                            assetDetailWrapper.parentDealNumber = vehicleRec.Parent_Deal_number__c;
                            //assetDetailWrapper.vehicleRegNumber = oppObj.Vehicle_Registration_Number__c;
                            assetDetailWrapper.leadNo = oppObj.Lead_number__c;
                            assetDetailWrapper.lastStage = oppObj.LastStageName__c;
                            assetDetailWrapper.currentStageName = oppObj.StageName;
                            assetDetailWrapper.agentBLCode = oppObj.Agent_BL_code__c;
                            assetDetailWrapper.CreatedDate = oppObj.CreatedDate;//CISP-3431
                            assetDetailWrapper.leadSource = oppObj.LeadSource;//CISP-3705
                            assetDetailWrapper.parentLeadId = oppObj.Parent_Loan_Application__c;//CISP-3705
                            assetDetailWrapper.parentLeadSource = oppObj.Parent_Loan_Application__r.LeadSource;//CISP-3705
                            assetDetailWrapper.topUpLoan = oppObj.isTopUpLoan__c;//SFTRAC-172

                            if(!applicantList.isEmpty()){
                                assetDetailWrapper.applicantId = applicantList[0].Id;
                                assetDetailWrapper.invoiceInNameOf = applicantList[0].Name;
                            } 

                            assetDetailWrapper.vehicleDelivered = vehicleRec.Vehicle_Delivered__c;

                            assetDetailwrapperList.add(assetDetailWrapper);
                        }
                        System.debug('Asset Wrapper:: '+ assetDetailwrapperList);
                        return JSON.serialize(assetDetailwrapperList);
                    }
                    else{
                        assetDetailElement.vehicleDetailId= vehicleObjList[0].Id;
                        assetDetailElement.vehicleMake= vehicleObjList[0].Make__c;
                        assetDetailElement.vehicleModel= vehicleObjList[0].Model__c;
                        assetDetailElement.vehicleVarient= vehicleObjList[0].Variant__c;
                        assetDetailElement.purposeOfPurchase= vehicleObjList[0].Purpose_of_purchase__c;
                        assetDetailElement.dealerSubdealerName= vehicleObjList[0].Dealer_Sub_dealer_name__c;
                        if(oppObj.LeadSource == 'Hero' && !applicantList.isEmpty()){//CISH-64
                            assetDetailElement.invoiceInNameOf = applicantList[0].Name;
                        }else{//CISH-64
                        assetDetailElement.invoiceInNameOf= vehicleObjList[0].Invoice_in_the_name_of__c;
                        }
                        assetDetailElement.vehicleInNameOf= vehicleObjList[0].Vehicle_registered_in_the_name_of__c;
                        assetDetailElement.usageType= vehicleObjList[0].Usage_Type__c;
                        assetDetailElement.vehicleRegNumber=vehicleObjList[0].Vehicle_Registration_number__c;
                        assetDetailElement.LienInFavorOf=vehicleObjList[0].Lien_in_favor_of__c;
                        assetDetailElement.rcRetentionApplicable = vehicleObjList[0].RC_retention_applicable__c;
                        assetDetailElement.numberOfOwnerships = vehicleObjList[0].Number_of_ownerships__c;
                        assetDetailElement.manufacturerYearMonth = vehicleObjList[0].Manufacturer_Year_Month__c;
                        assetDetailElement.lastOwnerName = vehicleObjList[0].Last_owner_name__c;
                        assetDetailElement.engineNumber = vehicleObjList[0].Engine_number__c;
                        assetDetailElement.chassisNumber = vehicleObjList[0].Chassis_number__c;
                        assetDetailElement.isGetVehicleDetailsSuccessful = vehicleObjList[0].Is_Get_Vehicle_Details_Successful__c;
                        assetDetailElement.isDCategoryVehicle = vehicleObjList[0].Is_D_Category_Vehicle__c;
                        assetDetailElement.benCode = vehicleObjList[0].Ben_Code__c; //CISP-2353
                        assetDetailElement.makeCode = vehicleObjList[0].Make_Code__c;//CISP-2794
                        assetDetailElement.modelCode = vehicleObjList[0].Model_Code__c;//CISP-2794
                        assetDetailElement.variantCode = vehicleObjList[0].Variant_Code__c;//CISP-2794
                        assetDetailElement.productSegment = vehicleObjList[0].Product_Segment__c;//CISP-20532
                        assetDetailElement.distance  =vehicleObjList[0].Distance__c; //commercial vehicle pv
                        assetDetailElement.grossReceiptsMonth  =vehicleObjList[0].Gross_Receipts_Month__c; //commercial vehicle pv
                        assetDetailElement.numberOfVehicleOwned  =vehicleObjList[0].Number_of_vehicle_owned__c; //commercial vehicle pv
                        assetDetailElement.expense  =vehicleObjList[0].Expense__c; //commercial vehicle pv
                        assetDetailElement.vehicleRoute  =vehicleObjList[0].Vehicle_Route__c; //commercial vehicle pv
                        assetDetailElement.route  =vehicleObjList[0].Route__c; //commercial vehicle pv
                        //CISP-2419
                        assetDetailElement.rcLimitEnabledDealer = vehicleObjList[0].RC_limit_enabled_Dealer__c;
                            //START DSA	
                        assetDetailElement.picklistFieldValueMap = picklistFieldValMap;
                        //CISP-2419
                        //START DSA Apply for D2C if needed
                        //if(oppObj.LeadSource == 'D2C'){
                        //    List<String> picklistFieldList2 = new List<String> {'Purpose_of_purchase__c', 'Vehicle_registered_in_the_name_of__c', 'Usage_Type__c', 'Lien_in_favor_of__c', 'RC_retention_applicable__c', 'Number_of_ownerships__c'};
                        //    Map<String, List<PicklistDataWrapper>> picklistFieldValMap2 = IND_AssetDetailsCntrl.getPicklistValues('Vehicle_Detail__c',picklistFieldList2);
                        //    assetDetailElement.picklistFieldValueMap = picklistFieldValMap2;
                        //}
                        //END DSA
                        assetDetailElement.productType=oppObj.Product_Type__c;
                        assetDetailElement.vehicleType=oppObj.Vehicle_Type__c;
                        assetDetailElement.vehicleSubCategory=oppObj.Vehicle_Sub_Category__c;
                        assetDetailElement.parentDealNumber=oppObj.Parent_Deal_number__c;
                        assetDetailElement.vehicleRegNumber=oppObj.Vehicle_Registration_Number__c;
                        assetDetailElement.leadNo=oppObj.Lead_number__c;
                        assetDetailElement.lastStage=oppObj.LastStageName__c;
                        assetDetailElement.currentStageName=oppObj.StageName;
                        assetDetailElement.agentBLCode=oppObj.Agent_BL_code__c;
                        assetDetailElement.CreatedDate = oppObj.CreatedDate;//CISP-3431
                        assetDetailElement.leadSource = oppObj.LeadSource;//CISP-3705
                        assetDetailElement.parentLeadId = oppObj.Parent_Loan_Application__c;//CISP-3705
                        assetDetailElement.parentLeadSource = oppObj.Parent_Loan_Application__r.LeadSource;//CISP-3705

                        if(!applicantList.isEmpty()){
                            assetDetailElement.applicantId=applicantList[0].Id;
                        }

                        System.debug('Asset Wrapper:: '+ assetDetailElement);
                        return JSON.serialize(assetDetailElement);
                    }
                } else {
                    if(oppObj.Product_Type__c == 'Tractor'){
                        assetDetailwrapperList[0].picklistFieldValueMap = picklistFieldValMap;
                    } else{
                        assetDetailElement.picklistFieldValueMap = picklistFieldValMap;
                    }
                }

                if(oppObj != null){
                    assetDetailElement.productType=oppObj.Product_Type__c;
                    assetDetailElement.vehicleType=oppObj.Vehicle_Type__c;
                    assetDetailElement.vehicleSubCategory=oppObj.Vehicle_Sub_Category__c;
                    assetDetailElement.parentDealNumber=oppObj.Parent_Deal_number__c;
                    assetDetailElement.vehicleRegNumber=oppObj.Vehicle_Registration_Number__c;
                    assetDetailElement.leadNo=oppObj.Lead_number__c;
                    assetDetailElement.lastStage=oppObj.LastStageName__c;
                    assetDetailElement.currentStageName=oppObj.StageName;
                    assetDetailElement.agentBLCode=oppObj.Agent_BL_code__c;
                    assetDetailElement.CreatedDate = oppObj.CreatedDate;//CISP-3431
                    assetDetailElement.leadSource = oppObj.LeadSource;//CISP-3705
                    assetDetailElement.parentLeadId = oppObj.Parent_Loan_Application__c;//CISP-3705
                    assetDetailElement.parentLeadSource = oppObj.Parent_Loan_Application__r.LeadSource;//CISP-3705
                }
                
                if(!applicantList.isEmpty()){
                	assetDetailElement.applicantId=applicantList[0].Id;
                } 

                if(oppObj.Product_Type__c == 'Tractor'){
                    return JSON.serialize(assetDetailwrapperList);
                } else{
                    return JSON.serialize(assetDetailElement);
                }
                                
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getAssetDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //public added by Hemanth Thikka
    public class AssetDetailsWrapper{
        Map<String, List<PicklistDataWrapper>> picklistFieldValueMap {get;set;}
        String vehicleDetailId {get;set;}
   public Decimal vaahanAPIRetryCount {get;set;}
   public Decimal dealMasterAPIRetryCount {get;set;}
        String vehicleMake {get;set;}
        String vehicleModel {get;set;}
        String vehicleVarient {get;set;}
        String purposeOfPurchase {get;set;}
        String vehicleInNameOf {get;set;}
        String productSegment {get;set;}
        String dealerSubdealerName {get;set;}
        String invoiceInNameOf {get;set;}
        String productType {get;set;}
        String vehicleType {get;set;}
        String vehicleSubType {get;set;}
        String vehicleSubCategory {get;set;}
        String parentDealNumber {get;set;}
        String leadNo {get;set;}
        Boolean isGetVehicleDetailsSuccessful {get;set;}
        Boolean isDCategoryVehicle {get;set;}
        String lastStage {get;set;}
        String currentStageName {get;set;}
        String agentBLCode {get;set;}
        //commercial vehicle pv
        Decimal distance {get;set;}
        Decimal grossReceiptsMonth {get;set;}
        Decimal numberOfVehicleOwned {get;set;}
        Decimal expense {get;set;}
        String vehicleRoute {get;set;}
        String route {get;set;}
 
        //Used Vehicle Type Fields
        String usageType {get;set;}
        String vehicleRegNumber {get;set;}
        String manufacturerYearMonth {get;set;}
        String lastOwnerName {get;set;}
        String numberOfOwnerships {get;set;}
        String engineNumber {get;set;}
        String chassisNumber {get;set;}
        String LienInFavorOf {get;set;}
        String rcRetentionApplicable {get;set;}
        Decimal rcHoldAmount {get;set;} //SFTRAC-1715
        String applicantId {get;set;}
        String benCode {get;set;} //CISP-2353
        String makeCode{get;set;}//CISP-2794
        String modelCode{get;set;}//CISP-2794
        String variantCode{get;set;}//CISP-2794
        Datetime CreatedDate{get;set;}//CISP-3431
        String leadSource{get;set;}//CISP-3705
        String parentLeadId {get;set;}//CISP-3705
        String parentLeadSource {get;set;} //CISP-3705
        Boolean rcLimitEnabledDealer {get;set;}//CISP-8762
        String vehicleSerialNumber {get;set;}
        Boolean topUpLoan {get;set;}//SFTRAC-172
        String vehicleDelivered {get;set;}//SFTRAC-172

    }
    //public added by Hemanth Thikka
    public class MMVDataWrapper{
       public Set<String> make_mmv {get;set;}
       public Map<String,Set<String>> model_mmv {get;set;}
       public Map<String,Set<String>> variant_mmv {get;set;}
    }

    @AuraEnabled
    public static Decimal getDelayTime(){
        try {
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Vehicle_Detail_Attempt'); 
            if(Test.isRunningTest()){
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return metadata.Delay_Time_in_milliseconds__c;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getDelayTime', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
    }
    
    /*
    * @Method:      getDealerSubDealerDetails
    * @Created by:  Sanketkumar Patil
    * @Description: This method will return Dealer/Subdealer based on the Selected Model
    * @Param:       String - loanApplication ID
    * @Return:      String - Wrapper response data
    */
    @AuraEnabled
    public static String getDealerSubDealerDetails(String sModelName, String sBLCode, String loanApplicationId){
        try {
            Opportunity loanApplicantionObj = [Select Id,Vehicle_Type__c,Vehicle_Sub_Category__c From Opportunity Where Id =: loanApplicationId With SECURITY_ENFORCED];
            List<Beneficiary_BlCode__c> benBLCodeRefDealerList = new List<Beneficiary_BlCode__c>();

            //Get Current Products Manufacturer
            List<Product2> manufacturerList= [select id, Manufacturer__c from Product2 where Name=:sModelName AND Type__c='Model' WITH SECURITY_ENFORCED];

            if(!manufacturerList.isEmpty() && loanApplicantionObj.Vehicle_Type__c == 'New'){       
                benBLCodeRefDealerList = [SELECT id, Ben_code__r.name, Ben_code__r.Ben_code__c from Beneficiary_BlCode__c where Ben_code__c in (SELECT Beneficiary_Master__c FROM Beneficiary_Manufacturer__c WHERE Manufacturer__c= :manufacturerList[0].Manufacturer__c) AND Bl_Code_Details__r.Bl_Code__c = :sBLCode and Ben_code__r.Beneficiary__c = 'DLR' and Ben_code__r.Status_Flag__c = 'L' and (Ben_code__r.Used_Flag__c != 'U' OR Ben_code__r.Used_Flag__c = Null) ORDER BY Ben_code__r.name ASC];
            }else if(!manufacturerList.isEmpty() && (loanApplicantionObj.Vehicle_Sub_Category__c == 'UPD' || loanApplicantionObj.Vehicle_Sub_Category__c == 'UEB')){
                benBLCodeRefDealerList = [SELECT id, Ben_code__r.name, Ben_code__r.Ben_code__c from Beneficiary_BlCode__c where  Bl_Code_Details__r.Bl_Code__c = :sBLCode and Ben_code__r.Beneficiary__c = 'DLR' AND (Ben_code__r.Dealership_Nature__c = 'MDR' OR Ben_code__r.Dealership_Nature__c = 'EDR') and Ben_code__r.Status_Flag__c = 'L' and (Ben_code__r.Used_Flag__c != 'N' OR Ben_code__r.Used_Flag__c = Null) WITH SECURITY_ENFORCED ORDER BY Ben_code__r.name ASC];
            }

            if(!benBLCodeRefDealerList.isEmpty()){
                return JSON.serialize(benBLCodeRefDealerList);
            } else {
                return JSON.serialize('');
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getDealerSubDealerDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
    }

    /*
    * @Method:      getMakeList
    * @Created by:  Sanketkumar Patil
    * @Description: This method will return Make List.
    * @Param:       String - Product Type
                    String - vehicleType //CISP-4974
    * @Return:      List<Product2> - List of Make records
    */
    @AuraEnabled (cacheable=true)
    public static List<OptionsWrapper> getMakeList(String sProductType, String vehicleType, String sleadsource){ //CISP-4974 & CISP-7045
        try {
            //Added by Sathya as part of Fix for Make values Not Populating IND-1652
            String productTypeStr=null;
            if(String.isNotBlank(sProductType) && sProductType != System.Label.Tractor){
                productTypeStr=(sProductType.length() > 5 ? sProductType.substring(0, 5):sProductType) +'%';
            }else{
                productTypeStr = System.Label.TRACTORS_AND_FARM_EQUIPMENT;
            }
            
            List<Product2> productList=[Select Name from Product2 where name like:productTypeStr] ;
            if(!productList.isEmpty()){
                sProductType=productList[0].Name;
            }
            List<OptionsWrapper> makeList = new List<OptionsWrapper>();	
            //CISP-4974
            // for loading MakeList - NEW - TWO WHEELER & PASSENGER VEHICLE
            if(vehicleType == 'New'){
                    List<AggregateResult> Make = [SELECT Parent_Product__c, Parent_Product__r.Name name, Parent_Product__r.Make_Code__c makecode
                        FROM Product2
                        WHERE Product_Type__c =: sProductType
                        AND Type__c = 'Model'
                        AND IsActive = true
                        GROUP BY Parent_Product__c, Parent_Product__r.name, Parent_Product__r.Make_Code__c
                        ORDER by Parent_Product__c, Parent_Product__r.name];
                    for(AggregateResult ag : Make){
                        OptionsWrapper options = new OptionsWrapper();
                        options.label = String.valueOf(ag.get('name'));
                        options.value = String.valueOf(ag.get('makecode'));
                        options.segmentCode = '';
                       // if(sleadsource == 'OLA'){//CISP-7045
                        makeList.add(options);
                     // }else if(ag.get('makecode') != 'OLA'){  
				     //  makeList.add(options);
                    }//CISP-7045
			    //}
                return makeList;
            }
            else{
                //CISP-2794
                List<OptionsWrapper> makeList2 = new List<OptionsWrapper>();
                List<Product2> make = [SELECT Id, Name,Make_Code__c FROM Product2 where Product_Type__c = :sProductType AND Type__c = 'Make' AND IsActive = true WITH SECURITY_ENFORCED ORDER by Name ASC]; 
                for(Product2 product : make){
                    OptionsWrapper options = new OptionsWrapper();
                    options.label = product.Name;
                    options.value = product.Make_Code__c;
                    options.segmentCode = '';
                    makeList2.add(options);
                }
                return makeList2;
            }
            } catch(Exception e){
                    ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getMMVMasterDataDetails', 'Apex', e);
                    //throw new AuraHandledException(System.Label.ExceptionMessage);
                    throw e;  
            }
            }
            
            public class OptionsWrapper{
                @AuraEnabled
                public String label;
                @AuraEnabled
                public String value;
                @AuraEnabled
                public String segmentCode;
            }

    /*
    * @Method:      getRelatedModelList
    * @Created by:  Sanketkumar Patil
    * @Description: This method will return related Model List.
    * @Param:       String - Make
                    String - vehicleType //CISP-4294
                    String - productType
    * @Return:      List<Product2> - List of Model records
    */
    @AuraEnabled (cacheable=true)
    public static List<OptionsWrapper> getRelatedModelList(String sMake, String vehicleType, String productType){ //CISP-4294
       try {
            //CISP-4294
            List<OptionsWrapper> modelList = new List<OptionsWrapper>();
            if(vehicleType == 'New' && (productType == 'TW' || productType == 'Two Wheeler')){
                // for loading ModelList - NEW - H - TWO WHEELER
                // OLA-132 
                if(sMake == 'OLA'){
                    List<AggregateResult> models = [SELECT Parent_Product__c,  Parent_Product__r.Name name, Parent_Product__r.Model_Code__c modelcode, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c segmentCode
                FROM Product2
                where Parent_Product__r.Make_Code__c =:sMake
                AND Type__c = 'variant'
                AND IsActive = true
                AND Emission_Norms__c = 'EV1'
                AND Parent_Product__r.Segment__r.segment_code__c = 'ESCOOTER'
                GROUP BY Parent_Product__c, Parent_Product__r.name, Parent_Product__r.Model_Code__c, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c
                order by Parent_Product__c, Parent_Product__r.name, Parent_Product__r.Model_Code__c, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c];
                for(AggregateResult ag : models){
                    OptionsWrapper options = new OptionsWrapper();
                    options.label = String.valueOf(ag.get('name'));
                    options.value = String.valueOf(ag.get('modelcode'));
                    options.segmentCode = String.valueOf(ag.get('segmentCode'));
                    modelList.add(options);
                        }//OLA-132
                }else{
               List<AggregateResult> models = [SELECT Parent_Product__c,  Parent_Product__r.Name name, Parent_Product__r.Model_Code__c modelcode, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c segmentCode
                FROM Product2
                where Parent_Product__r.Make_Code__c =:sMake
                AND Type__c = 'variant'
                AND IsActive = true
                AND Emission_Norms__c IN ('BS6','EV1')
                AND Parent_Product__r.Segment__r.segment_code__c in ('MOPEDS','SCOOTER','MOTORCYC','ESCOOTER')
                GROUP BY Parent_Product__c, Parent_Product__r.name, Parent_Product__r.Model_Code__c, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c
                order by Parent_Product__c, Parent_Product__r.name, Parent_Product__r.Model_Code__c, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c];

                System.debug('AggregateResult__'+models.size());
                
				for(AggregateResult ag : models){
				OptionsWrapper options = new OptionsWrapper();
				options.label = String.valueOf(ag.get('name'));
				options.value = String.valueOf(ag.get('modelcode'));
                 if(String.valueOf(ag.get('segmentCode')) == 'ESCOOTER'){//CISP-21804
                 options.segmentCode = String.valueOf(ag.get('segmentCode'));
                }else{
                 options.segmentCode = 'TWO WHEELER';
                }//CISP-21804
				modelList.add(options);
				}
            }
                return modelList;
            } 
            else if(vehicleType == 'New' && (productType == 'PV' || productType == 'Passenger Vehicles')){
			
                // for loading ModelList - NEW - C - Passenger vehicle
				List<OptionsWrapper> modelList2 = new List<OptionsWrapper>();
				
                List<AggregateResult> models = [SELECT Parent_Product__c, Parent_Product__r.Name name, Parent_Product__r.Model_Code__c modelcode, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c
                FROM Product2
                where Parent_Product__r.Make_Code__c = :sMake 
                AND Type__c = 'variant'
                AND IsActive = true
                AND Emission_Norms__c IN ('BS6','EV1')
                GROUP BY Parent_Product__c, Parent_Product__r.Name, Parent_Product__r.Model_Code__c, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c
                order by Parent_Product__c, Parent_Product__r.Name, Parent_Product__r.Model_Code__c, Parent_Product__r.Make_Code__c, Parent_Product__r.Segment__r.segment_code__c];
				
				for(AggregateResult ag : models){
				OptionsWrapper options = new OptionsWrapper();
				options.label = String.valueOf(ag.get('name'));
				options.value = String.valueOf(ag.get('modelcode'));
                options.segmentCode = '';
				modelList2.add(options);
				}
				return modelList2;
            }
            else {
            //CISP-2794
            List<Product2> models = [SELECT Id, Name, Model_Code__c,Make_Code__c FROM Product2 where Parent_Product__r.Make_Code__c = :sMake AND Type__c = 'Model' AND IsActive = true WITH SECURITY_ENFORCED order by Name ASC];
			List<OptionsWrapper> modelList3 = new List<OptionsWrapper>();
			for(Product2 product : models){
				OptionsWrapper options = new OptionsWrapper();
				options.label = product.Name;
				options.value = product.Model_Code__c;
                options.segmentCode = '';
				modelList3.add(options);
				}
				return modelList3;
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getMMVMasterDataDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }

    public class PicklistDataWrapper{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
    
    /*
    * @Method:      getPicklistValues
    * @Created by:  Sanketkumar Patil
    * @Description: This method will return Required set of picklist values.
    * @Param:       String - objectName, List<String> - Field List
    * @Return:      Map<String, Map<String, String>> - Picklist Field Value Map
    */
    @AuraEnabled
    public static Map<String, List<PicklistDataWrapper>> getPicklistValues(String objectName, List<String> fieldList) {
        Map<String, List<PicklistDataWrapper>> picklistFieldValueMap = new Map<String, List<PicklistDataWrapper>>{};
        
        for(Schema.DescribeSobjectResult res : Schema.describeSObjects(new List<String>{objectName})) {
            for(String fieldName : fieldList){
                List<PicklistDataWrapper> values = new List<PicklistDataWrapper>();
                
                for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) {
                        PicklistDataWrapper obj = new PicklistDataWrapper();
                        obj.label = entry.getLabel();
                        obj.value = entry.getValue();
						values.add(obj);
                        
                        if (entry.isDefaultValue()) {
                            picklistFieldValueMap.put('Default_'+fieldName, new List<PicklistDataWrapper>{obj});
                        }
                    }
                }
            	picklistFieldValueMap.put(fieldName, values);
            }
        }
        return picklistFieldValueMap;
    }
    
    /*
    * @Method:      getRelatedVariantList
    * @Created by:  Sanketkumar Patil
    * @Description: This method will return related Variant List.
    * @Param:       String - Model
                    string - vehicleType //CISP-4818
    * @Return:      List<Product2> - List of Variant records
    */
    @AuraEnabled (cacheable=true)
    public static List<Product2> getRelatedVariantList(String sModel, String vehicleType){
        try {
            if(vehicleType == 'New'){ //CISP-4818
                // for loading VariantList - NEW - Both TWO WHEELER & PASSENGER VEHICLE
            return [SELECT Id, Name, type__C, Variant_Code__c, Model_Code__c, Emission_Norms__c FROM Product2 where Parent_Product__r.Model_Code__c = :sModel AND type__c = 'Variant' AND Emission_Norms__c IN ('BS6','EV1') AND IsActive = true WITH SECURITY_ENFORCED order by Name Asc];
            }
            else {
                // for loading VariantList - USED - Both TWO WHEELER & PASSENGER VEHICLE
            //CISP-2794
            return [SELECT Id, Name, type__C,Variant_Code__c,Model_Code__c FROM Product2 where Parent_Product__r.Model_Code__c = :sModel and type__c = 'Variant' AND IsActive = true WITH SECURITY_ENFORCED order by Name Asc];
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getMMVMasterDataDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    
    @AuraEnabled
    public static Boolean changeStage(String stageName,String loanApplicationId){
        try {
            Boolean updateStatus = false;
            Opportunity opp = new Opportunity(id = loanApplicationId, StageName = stageName, LastStageName__c = stageName);
            
            if(Schema.sObjectType.Opportunity.isUpdateable()) {
                try{
                    update opp;
                    updateStatus = true;
                } catch(Exception e){
                    System.debug('Error in updating Stagename after Asset Details submit:: '+ e.getStackTraceString());
                    return updateStatus;
                }
            } else {
                return updateStatus;
            }
            
            return updateStatus;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'changeStage', 'Apex', e);
            throw new AuraHandledException(e.getStackTraceString());  
        }
    }
    @AuraEnabled
    public static String validateVehicleRecords(String loanApplicationId){
        List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>([Select Id,Ben_Code__c,Dealer_Sub_dealer_name__c,Vehicle_type__c FROM Vehicle_Detail__c Where Loan_Application__c =: loanApplicationId]);
        for (Vehicle_Detail__c vehicle : vehicleDetailList) {
            if(vehicle.Vehicle_type__c == 'New'){
                if(String.isBlank(vehicle.Ben_Code__c) || String.isBlank(vehicle.Dealer_Sub_dealer_name__c)){
                    return 'Dealer/DSA is not captured. Please try again!';  
                }
            }
        }
        return 'true';
    }

    /*
    * @Method:      validateDVehicleCategory
    * @Created by:  Vinita Kamble
    * @Description: This Method will validate whether vehicle is of D Category or not
    * @Param:       String - Model
    * @Return:      Boolean 
    */
    @AuraEnabled
    public static Boolean validateDVehicleCategory(String sModel){
        try {
            Boolean validateVehicleCategory= false;
            
            if(sModel != null){
                List<Product2> prod = [SELECT Id,Asset_Category__c FROM Product2 where Name = :sModel WITH SECURITY_ENFORCED];
                if(!prod.isEmpty()){
                    if(prod[0].Asset_Category__c == 'D'){  
                        validateVehicleCategory =true;
                    } 
                }
            }

            return validateVehicleCategory;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'validateDVehicleCategory', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    
      /*
    * @Method:      getMMVNameBasedOnCode
    * @Created by:  Divya Jawale
    * @Description: This method will return Dealer/Subdealer based on the Selected Model
    * @Param:       String - make, model, variant
    * @Return:      String - Wrapper response data
    */
    @AuraEnabled
    public static String getMMVNameBasedOnCode(String makeCode, String modelCode, String variantCode){
        try {
            AssetDetailsWrapper assetDetailsWrapper = new AssetDetailsWrapper();
            
            if(makeCode != null && modelCode != null && variantCode != null){
                List<Product2> makeObjList= [select Id, Name from Product2 where Make_Code__c=:makeCode and type__c = 'make' WITH SECURITY_ENFORCED limit 1];
                List<Product2> modelObjList= [select Id, Name from Product2 where Model_Code__c=:modelCode and type__c = 'model' WITH SECURITY_ENFORCED limit 1];
                List<Product2> varinatObjList= [select Id, Name from Product2 where Variant_Code__c=:variantCode  and type__c = 'variant' WITH SECURITY_ENFORCED limit 1];

                if(!makeObjList.isEmpty()) {
                    assetDetailsWrapper.vehicleMake = makeObjList[0]?.Name;
                }

                if(!modelObjList.isEmpty()) {
                    assetDetailsWrapper.vehicleModel = modelObjList[0]?.Name;
                }

                if(!varinatObjList.isEmpty()){
                    assetDetailsWrapper.vehicleVarient = varinatObjList[0]?.Name;
                }
            }
            return JSON.serialize(assetDetailsWrapper);
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getMMVNameBasedOnCode', 'Apex', e);
            throw new AuraHandledException(e.getStackTraceString());        
        }
    }
      /*
    * @Method:      createRecordUsingApex
    * @Created by:  Gaurav Rawat
    * @Description: 
    * @Param:       
    * @Return:      
    */
    @AuraEnabled
    public static String createRecordUsingApex(String apiName, String fields,String loanApplicationId){
        try {
            String vehicleRecordId;
            if(String.isNotBlank(apiName) && string.isNotBlank(fields) && String.isNotBlank(loanApplicationId)){
                if(apiName == 'Vehicle_Detail__c'){
                    Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
                    vehicleObj = (Vehicle_Detail__c) JSON.deserialize(fields,Vehicle_Detail__c.class);
                    if(String.isNotBlank(vehicleObj.Loan_Number__c)){
                        vehicleObj.Loan_Number__c = loanApplicationId;
                    }
                    insert vehicleObj;
                    vehicleRecordId = vehicleObj.Id;
                }
            }
            return vehicleRecordId;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'getMMVNameBasedOnCode', 'Apex', e, loanApplicationId);
            throw new AuraHandledException(e.getStackTraceString());        
        }
    }

      /*
    * @Method:      updateVehicleRecords
    * @Created by:  Utkarsh Maurya
    * @Description: 
    * @Param:       
    * @Return:      
    */
    @AuraEnabled
    public static String updateVehicleRecords(String vehicleList, String loanApplicationId){
        try {
            List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>();
            vehicleDetailList = (List<Vehicle_Detail__c>) JSON.deserialize(vehicleList, List<Vehicle_Detail__c>.class);

            Set<String> variantSet = new Set<String>();
            for(Vehicle_Detail__c vehicleObj : vehicleDetailList) {
                if(String.isNotBlank(vehicleObj.Variant_Code__c)){
                    variantSet.add(vehicleObj.Variant_Code__c);
                }
            }
            String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1].Agent_BL_code__c, 'T');
            List<TBM_Product_Variant_dt__c> dlpMasterList = [SELECT Id,Product_Variant_Code__c,Dealer_Landed_Price__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode AND Product_Variant_Code__c IN: variantSet];
            
            Map<String,Decimal> dlpMasterMAP = new Map<String,Decimal>();
            for(TBM_Product_Variant_dt__c dlpMasterRec: dlpMasterList){
                if(!dlpMasterMAP.containsKey(dlpMasterRec.Product_Variant_Code__c)){
                    dlpMasterMAP.put(dlpMasterRec.Product_Variant_Code__c, dlpMasterRec.Dealer_Landed_Price__c);
                }
            }

            for(Vehicle_Detail__c vehicleObj : vehicleDetailList) {
                if(dlpMasterMAP.containsKey(vehicleObj.Variant_Code__c)){
                    vehicleObj.DLP__c = dlpMasterMAP.get(vehicleObj.Variant_Code__c);
                }
            }
            update vehicleDetailList;
            return 'SUCCESS';
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AssetDetailsCntrl', 'updateVehicleRecords', 'Apex', e, loanApplicationId);
            throw new AuraHandledException(e.getStackTraceString());        
        }
    }

        //CISP-8762
        @AuraEnabled
        public static Boolean checkRCLimitBasedOnBencode(String benCodeValue){
            try {
                List<DSA_RC_Limit__c> dsaList = [SELECT ID,Max_Limit__c from DSA_RC_Limit__c where Ben_Code__c =: benCodeValue AND Max_Limit__c > 0 limit 1];//CISP-12190
                if(!dsaList.isEmpty()){
                    return true;
                }
                return false;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
}