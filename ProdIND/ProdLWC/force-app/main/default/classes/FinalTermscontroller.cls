/** 
* @Name         FinalTermscontroller
* @Author       Ruchi Jain
* @Company      Persistent Systems
* @Description  This class contains all methods related to Final Terms
* Inputs:       None
* Test Class:   FinalTermscontrollerTest
* History: 
* 19/01/2022    Ruchi Jain Added  loadSchemeData and checkSchemeEligibility method . 
*/
public with sharing class FinalTermscontroller {
    
    private final static String NOT_WAIVED = 'Not Waived';
    private final static String CASE_OBJECT = 'Case';
    private final static String FI_OBJECT = 'Field_Investigation__c';
    private final static String STR_FI = 'FI';
    private final static String OFFICE_FI = 'Office FI';
    private final static String CURRENT_FI = 'Current Residence FI';
    private final static String PERMANENT_FI = 'Permanent Residence FI';
    private final static List<String> CURRENT_PERMANENT_ADDR_LIST = new List<String>{'Current Residential Address', 'Permanent Residential Address'};
        private final static List<String> FI_RECORD_TYPES = new List<String>{'Office','Permanent','Residence'};
            private final static String CASE_STATUS_FI_UNASSIGNED = 'FI-Unassigned';
    
      
    /*
* @Method:      loadSchemeData
* @Created by:  Ruchi Jain
* @Description: This method is use to give all the schemes
* @Param:       None
* @Return:      list of schemes
*/
    @AuraEnabled
    public static List<Schemes__c> loadSchemeData(String loanApplicationId,String vehicleId){
        try {
            Opportunity opp=[SELECT Id,Product_Type__c,Agent_BL_code__c,Account.State__c, LeadSource ,OwnerId,Owner.Name FROM Opportunity WHERE Id=: loanApplicationId WITH SECURITY_ENFORCED];//CISP-3077
            if(opp!=null){
                if(opp.Product_Type__c!= null && opp.Product_Type__c=='Passenger Vehicles'){
                    List<Schemes__c> schemes=[SELECT Id,Name FROM Schemes__c WHERE Product__c =: opp.Product_Type__c WITH SECURITY_ENFORCED ORDER BY Name];
                    return schemes;
                }else if(opp.Product_Type__c!= null && opp.Product_Type__c=='Two Wheeler'){
                    List<Schemes__c> finalSchemeList = new List<Schemes__c>();
                    List<Vehicle_Detail__c> vehicledetails = [select Id,Ben_Code__c,Make__c,Model__c from Vehicle_Detail__c where Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                    List<Schemes__c> schemes = new List<Schemes__c>();
                    Date todaysDate = Date.today();
                    String query = 'SELECT Id, Name,Manufacturer_Code_Make__c,Manufacturer_Code_Make__r.Name, Model__c, State__c, Agent_BL_code__c, Dealer_Sub_dealer_name__c FROM Schemes__c WHERE Product__c = \'Two Wheeler\' AND (Scheme_Expiry__c >=: todaysDate OR Name Like \'No%\')';
                    if(opp.LeadSource=='OLA'){
                        query+= 'AND Name LIKE \'%ola %\'' ;
                    }
                    schemes = Database.query(query);
                    for (Schemes__c schemeObj : schemes) {
                        if(!vehicledetails.isEmpty()){
                            if(vehicledetails[0].Ben_Code__c!=null && schemeObj.Dealer_Sub_dealer_name__c != null && schemeObj.Dealer_Sub_dealer_name__c.contains(vehicledetails[0].Ben_Code__c)){
                                finalSchemeList.add(schemeObj);
                                continue;
                            }
                            String vehicleModel = vehicledetails[0].Model__c;
                            if(vehicleModel != null && schemeObj.Model__c != null && schemeObj.Model__c.contains(vehicleModel)){
                                finalSchemeList.add(schemeObj);
                                continue;
                            }
                            String vehicleMake = vehicledetails[0].Make__c;
                            if(vehicleMake != null &&  schemeObj.Model__c == null && schemeObj.Manufacturer_Code_Make__c != null && schemeObj.Manufacturer_Code_Make__r.Name == vehicleMake){
                                finalSchemeList.add(schemeObj);
                                continue;
                            }
                        }
                        Boolean hasAgentBlCode = false;
                        if(schemeObj.Dealer_Sub_dealer_name__c == null && opp.Agent_BL_code__c != null && schemeObj.Agent_BL_code__c != null && schemeObj.Agent_BL_code__c.contains(opp.Agent_BL_code__c)){
                            finalSchemeList.add(schemeObj);
                            hasAgentBlCode = true;
                            continue;
                        }
                        Boolean hasState = false;
                        if(schemeObj.Dealer_Sub_dealer_name__c == null && hasAgentBlCode == false && schemeObj.Agent_BL_code__c == null && schemeObj.State__c != null && opp.Account.State__c!=null && schemeObj.State__c.contains(opp.Account.State__c)){
                            finalSchemeList.add(schemeObj);
                            hasState = true;
                            continue;
                        }
                        if((schemeObj.Dealer_Sub_dealer_name__c == null && schemeObj.Agent_BL_code__c == null && schemeObj.State__c == null && hasAgentBlCode == false && hasState == false) || schemeObj.Name.contains('No Scheme')){
                            finalSchemeList.add(schemeObj);
                            continue;
                        }
                    }
                    Set<Schemes__c> tempList = new Set<Schemes__c>();
                    tempList.addAll(finalSchemeList);
                    finalSchemeList = new List<Schemes__c>();
                    finalSchemeList.addAll(tempList);
                    return finalSchemeList;
                }else if(opp.Product_Type__c!= null && opp.Product_Type__c=='Tractor'){
                    List<Vehicle_Detail__c> vehicledetails = [SELECT Id,Ben_Code__c,Make__c,Model__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanApplicationId AND Id=:vehicleId WITH SECURITY_ENFORCED LIMIT 1];
                    List<Final_Term__c> finaltermList = [SELECT Id,Business_Executive__r.Name,Business_Executive__c FROM Final_Term__c WHERE Vehicle_Detail__c =:vehicleId AND Loan_Application__c =:loanApplicationId LIMIT 1];
                    List<Documents__c> documentList = [SELECT Id, Taluka__c,KYC_City__c,KYC_District__c FROM Documents__c WHERE Is_Active__c = true AND Document_Type__c NOT IN ('Customer Image') AND Opportunity_Relation__c =:loanApplicationId AND Applicant__r.In_Active_Applicant__c = false AND Applicant__r.Applicant_Type__c = 'Borrower' WITH SECURITY_ENFORCED];
                    String talukaValue;
                    String districtValue;
                    if(!documentList.isEmpty()){
                        for (Documents__c documentObj : documentList) {
                            districtValue = String.isNotBlank(documentObj.KYC_District__c) ? documentObj.KYC_District__c : String.isNotBlank(documentObj.KYC_City__c) ? documentObj.KYC_City__c : districtValue;
                            talukaValue = String.isNotBlank(documentObj.Taluka__c) ? documentObj.Taluka__c : talukaValue;
                        }
                    }
                    String oppOwnerId;
                    String oppOwnerName;
                    oppOwnerId = opp.OwnerId;
                    oppOwnerName = opp.Owner.Name;
                    List<Schemes__c> schemes = new List<Schemes__c>();
                    Date todaysDate = Date.today();
                    String query = 'SELECT Id, Name,Taluka__c,Business_Executive__c,District__c,Manufacturer_Code_Make__c,Manufacturer_Code_Make__r.Name, Model__c, State__c, Agent_BL_code__c, Dealer_Sub_dealer_name__c FROM Schemes__c WHERE Product__c = \'Tractor\' AND (Scheme_Expiry__c >=: todaysDate OR Name Like \'No%\')';
                    schemes = Database.query(query);
                    List<Schemes__c> finalSchemeList = new List<Schemes__c>();
                    for (Schemes__c schemeObj : schemes) {
                        if(String.isNotBlank(talukaValue) && String.isNotBlank(schemeObj.Taluka__c) && schemeObj.Taluka__c.contains(talukaValue)){
                            finalSchemeList.add(schemeObj);
                            continue;
                        }
                        if(String.isNotBlank(schemeObj.Business_Executive__c) && String.isNotBlank(oppOwnerName) && String.isNotBlank(oppOwnerId) && (schemeObj.Business_Executive__c.contains(oppOwnerName) || schemeObj.Business_Executive__c.contains(oppOwnerId) || (!finaltermList.isEmpty() && String.isNotBlank(finaltermList[0].Business_Executive__c) && (schemeObj.Business_Executive__c.contains(finaltermList[0].Business_Executive__r.Name) || schemeObj.Business_Executive__c.contains(finaltermList[0].Business_Executive__c))))){
                            finalSchemeList.add(schemeObj);
                            continue;
                        }
                        if(!vehicledetails.isEmpty()){
                            if(String.isNotBlank(vehicledetails[0].Ben_Code__c) && String.isNotBlank(schemeObj.Dealer_Sub_dealer_name__c) && schemeObj.Dealer_Sub_dealer_name__c.contains(vehicledetails[0].Ben_Code__c)){
                                finalSchemeList.add(schemeObj);
                                continue;
                            }
                            String vehicleModel = vehicledetails[0].Model__c;
                            if(String.isNotBlank(vehicleModel) && String.isNotBlank(schemeObj.Model__c) && schemeObj.Model__c.contains(vehicleModel)){
                                finalSchemeList.add(schemeObj);
                                continue;
                            }
                            String vehicleMake = vehicledetails[0].Make__c;
                            if(String.isNotBlank(vehicleMake) &&  String.isBlank(schemeObj.Model__c) && String.isNotBlank(schemeObj.Manufacturer_Code_Make__c) && schemeObj.Manufacturer_Code_Make__r.Name == vehicleMake){
                                finalSchemeList.add(schemeObj);
                                continue;
                            }
                        }
                        if(String.isNotBlank(opp.Agent_BL_code__c) && String.isNotBlank(schemeObj.Agent_BL_code__c) && schemeObj.Agent_BL_code__c.contains(opp.Agent_BL_code__c)){
                            finalSchemeList.add(schemeObj);
                            continue;
                        }
                        if(String.isNotBlank(schemeObj.State__c) && String.isNotBlank(opp.Account.State__c) && schemeObj.State__c.contains(opp.Account.State__c)){
                            finalSchemeList.add(schemeObj);
                            continue;
                        }
                        if(String.isNotBlank(schemeObj.District__c) && String.isNotBlank(districtValue) && schemeObj.District__c.contains(districtValue)){
                            finalSchemeList.add(schemeObj);
                            continue;
                        }
                        if((String.isBlank(schemeObj.Taluka__c) && String.isBlank(schemeObj.Business_Executive__c) && String.isBlank(schemeObj.Dealer_Sub_dealer_name__c) && String.isBlank(schemeObj.Model__c) && String.isBlank(schemeObj.Manufacturer_Code_Make__c) && String.isBlank(schemeObj.Agent_BL_code__c) && String.isBlank(schemeObj.State__c) && String.isBlank(schemeObj.District__c)) || schemeObj.Name.contains('No Scheme')){
                            finalSchemeList.add(schemeObj);
                            continue;
                        }
                    }
                    return finalSchemeList;
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'loadSchemeData', System.Label.Apex, e,loanApplicationId);
          
            throw new AuraHandledException(System.Label.ExceptionMessage);
            
        }
    }

     /*
* @Method:      getApplicationDetails
* @Created by:  Saloni Jadhav
* @Description: This method is use to check product and vehicle type.
* @Param:       loanApplicationId
* @Return:      String
*/
    @AuraEnabled

public static string getApplicationDetails(String loanApplicationId){
    try {
        string res;
        Opportunity opp=[SELECT id,Product_Type__c,Vehicle_Type__c,Vehicle_Sub_Category__c FROM Opportunity 

                            WHERE Id=: loanApplicationId WITH SECURITY_ENFORCED]; 
        if(opp.Product_Type__c == System.Label.TwoWheeler){        
            if(opp.Vehicle_Type__c == System.Label.new || opp.Vehicle_Type__c == System.Label.used){
                res= 'twNew';
            }else if(opp.Vehicle_Type__c == System.Label.Refinance){
                res= 'twRefinance';
            }
        }
        if(opp.Product_Type__c == System.Label.PassengerVehicles){ 
            if(opp.Vehicle_Type__c == System.Label.new || opp.Vehicle_Sub_Category__c=='UPD'){ 
                res='passengerUpd';
            }else{
                res='passenger';
            }
        } 
        if(opp.Product_Type__c == 'Tractor'){
             res = 'tractor';
        }
        return res;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'loadSchemeData', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
    
@AuraEnabled

public static string getOpportunityDetailsForUPD(String loanApplicationId){
    try {
        string res = '';
        Opportunity opp=[SELECT id,Product_Type__c,Vehicle_Type__c,Vehicle_Sub_Category__c FROM Opportunity

                            WHERE Id=: loanApplicationId WITH SECURITY_ENFORCED];
        if(opp.Product_Type__c == System.Label.PassengerVehicles){
            if(opp.Vehicle_Type__c == System.Label.new || opp.Vehicle_Sub_Category__c=='UPD' || opp.Vehicle_Sub_Category__c == 'UEB'){
                res='passengerUpdUEB';
            }
        }
        return res;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'getOpportunityDetailsForUPD', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
    
}
    /*
    * @Method:      dsmNameData
    * @Created by:  Raj Gupta.
    * @Description: This method is use to give all the DSM Name
    * @Param:       None
    * @Return:      list of Dsm name
    */
    @AuraEnabled
    public static  List<String> dsmNameData(String loanApplicationId, String vehicleId){
        try {
            List<String> beneficiaryNameList = new List<String>();
            List<Benefi__c> ben = new  List<Benefi__c>();

            //Query the Vehicle details object related to Loan application.   
            List<Vehicle_Detail__c> vehicledetails = new List<Vehicle_Detail__c>();
            if(String.isNotBlank(vehicleId)){
                vehicledetails = [SELECT Id, Ben_Code__c, Loan_Application__r.Agent_BL_code__c, Loan_Application__r.Product_Type__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :loanApplicationId AND Id =: vehicleId WITH SECURITY_ENFORCED];
            }else{
                vehicledetails = [SELECT Id, Ben_Code__c, Loan_Application__r.Agent_BL_code__c, Loan_Application__r.Product_Type__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :loanApplicationId WITH SECURITY_ENFORCED];
            }
            

            if(!vehicledetails.isEmpty()){
                String productCode = vehicledetails[0].Loan_Application__r.Product_Type__c == 'Two Wheeler' ? 'H' : vehicledetails[0].Loan_Application__r.Product_Type__c == System.Label.Tractor ? 'T' : 'C';
                
                //query the Beneficary product by passing the Delear name, Product type and DSM
                for(Beneficiary_Product__c benficaryProduct : [SELECT Ben_code__c,Ben_code__r.name,Ben_code__r.Ben_code__c,Ben_code__r.Dealer_Code__c from Beneficiary_Product__c where product__r.ProductCode = :productCode AND Ben_code__r.Status_Flag__c = 'L'AND Ben_code__r.Dealer_Code__c = :vehicledetails[0].Ben_Code__c AND Ben_code__r.Beneficiary__c = 'DSM' WITH SECURITY_ENFORCED]){
                    if(benficaryProduct.Ben_code__c!=null && benficaryProduct.Ben_code__r.Ben_code__c != null){
                        beneficiaryNameList.add(benficaryProduct.Ben_code__r.name+'-'+benficaryProduct.Ben_code__r.Ben_code__c);
                    } else if(benficaryProduct.Ben_code__r.Dealer_Code__c != null){
                        beneficiaryNameList.add(benficaryProduct.Ben_code__r.Dealer_Code__c);
                    }
                }
            }
            return beneficiaryNameList;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller', 'dsmNameData', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
* @Method:      reffnamedata
* @Created by:  Sri.
* @Return:      tentative
*/
 /*  @AuraEnabled
    public static  Map<String,String> reffnamedata(String loanApplicationId){
        try {
            Map<String,String> beneficiaryNameList = new Map<String,String>();
            //Query the Vehicle details object related to Loan application.         
            List<Vehicle_Detail__c> vehicledetails = [select Id,Loan_Application__c, Loan_Application__r.Agent_BL_code__c,
                                                      Loan_Application__r.Product_Type__c,Ben_Code__c,Dealer_Sub_dealer_name__c 
                                                      from Vehicle_Detail__c
                                                      where Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED];
            if(!vehicledetails.isEmpty()){ 
                String productCode = vehicledetails[0].Loan_Application__r.Product_Type__c == 'Two Wheeler' ? 'H' : 'C';
                //query the Beneficary product by passing the Delear name, Product type and DSM
				Beneficiary_Product__c[] benficaryProduct = [select Id,Ben_code__c,Ben_code__r.name,product__r.Name,Ben_code__r.Dealer_Code__c 
                                                               from Beneficiary_Product__c where
                                                               product__r.ProductCode =: productCode  and
                                                               Name =: vehicledetails[0].Dealer_Sub_dealer_name__c and 
                                                               Ben_code__r.Beneficiary__c ='DSM' and Ben_code__r.Status_Flag__c = 'L' WITH SECURITY_ENFORCED];
                list<String> bencodes= new list<String>();
                for(Beneficiary_Product__c ben:benficaryProduct){
                    bencodes.add(ben.Ben_code__c);
                }
                system.debug('bencodes'+bencodes);
                for(Beneficiary_BlCode__c benficaryblcode : [select Id,Ben_code__c,Ben_code__r.Name,Bl_Code_Details__c, Bl_Code_Details__r.Name
                                                               from Beneficiary_BlCode__c where Ben_code__c IN:bencodes and Ben_code__r.Dealer_Code__c=:''
                                                              	WITH SECURITY_ENFORCED]){
                    beneficiaryNameList.put(benficaryblcode.Ben_code__c,benficaryblcode.Ben_code__r.Name);
                    system.debug('beneficiaryNameList'+beneficiaryNameList);

                }   
                //simple dummy commit      
                                         
                                                                              
            }
            return beneficiaryNameList;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller', 'reffNameData', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
            
        }
    }
    
    
    /*
* @Method:      rtoValidation
* @Created by:  Raj Gupta.
* @Description: This method is use to give List of Rto's based on agent BL code.
* @Param:       None
* @Return:      List of Rto's based on agent BL code
*/
    @AuraEnabled
    public static String rtoValidation(String loanApplicationId,String rtoAlnu){
        try {
            ResponseWrapper responseJSON = new ResponseWrapper(); 
            Opportunity opp =  [select id, Agent_BL_code__c from Opportunity where Id =: loanApplicationId WITH SECURITY_ENFORCED];
            BankBranchDetails__c branch = [select id,Geo_State_Master__c from BankBranchDetails__c where Bl_Code_Details__r.Bl_Code__c =: opp.Agent_BL_code__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Ind_RTO_Master__c> rtoList = [select id,RTO_ALNU__c from Ind_RTO_Master__c where Geo_State_Master__c =: branch.Geo_State_Master__c and RTO_ALNU__c =: rtoAlnu  WITH SECURITY_ENFORCED];
            List<Ind_RTO_Master__c> rtoListAll = [select id,RTO_ALNU__c from Ind_RTO_Master__c where RTO_ALNU__c =: rtoAlnu  WITH SECURITY_ENFORCED];
            if(!rtoList.isEmpty())
            {
                responseJSON.message='AgentBl Code Match Found';
                String serializedResonponse = JSON.serialize(responseJSON);
                return serializedResonponse;  
            }
            else
            {
                if(!rtoListAll.isEmpty())
                {
                    responseJSON.message= 'Valid Vehicle Registration Number';  
                    String serializedResonponse = JSON.serialize(responseJSON);
                    return serializedResonponse;  
                }
                else
                {
                    responseJSON.message= 'InValid Vehicle Registration Number';
                    String serializedResonponse = JSON.serialize(responseJSON);
                    return serializedResonponse; 
                }
            }
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller', 'dsmNameData', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    
    /*
* @Method:      NondsmNameData
* @Created by:  Raj Gupta.
* @Description: This method is use to give all the NON DSM Name
* @Param:       None
* @Return:      list of NON Dsm name
*/
    @AuraEnabled
    public static List<String> nonDsmNameData(String loanApplicationId, String vehicleId){
        try {
            List<String> beneficiaryNameList = new List<String>();
            List<Benefi__c> ben = new  List<Benefi__c>();
            //Query the Vehicle details object related to Loan application.         
            List<Vehicle_Detail__c> vehicledetails = new List<Vehicle_Detail__c>();
            if(String.isNotBlank(vehicleId)){
                vehicledetails = [select Id,Loan_Application__c, Loan_Application__r.Agent_BL_code__c,
                Loan_Application__r.Product_Type__c,Ben_Code__c,Dealer_Sub_dealer_name__c 
                from Vehicle_Detail__c
                where Loan_Application__c =: loanApplicationId AND Id=:vehicleId WITH SECURITY_ENFORCED];
            }else{
                vehicledetails = [select Id,Loan_Application__c, Loan_Application__r.Agent_BL_code__c,
                Loan_Application__r.Product_Type__c,Ben_Code__c,Dealer_Sub_dealer_name__c 
                from Vehicle_Detail__c
                where Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED];
            }

            ben = [select id, Dealer_Code__c from Benefi__c where Ben_code__c =: vehicledetails[0].Ben_Code__c WITH SECURITY_ENFORCED];
            
            if(!vehicledetails.isEmpty()){ 
                String productCode = vehicledetails[0].Loan_Application__r.Product_Type__c == 'Two Wheeler' ? 'H' : vehicledetails[0].Loan_Application__r.Product_Type__c == System.Label.Tractor ? 'T' : 'C';
               if (!ben.isEmpty()) {
                //query the Beneficary product by passing the Delear name, Product type and DSM
                for(Beneficiary_BlCode__c benficaryProduct : [Select id, Ben_code__r.name, Ben_code__r.Ben_code__c, Ben_code__r.Status_Flag__c, 
                                                                Ben_code__r.Dealer_Code__c, Ben_code__r.Beneficiary__c 
                                                                from Beneficiary_BlCode__c where Ben_code__c in (select Ben_code__c
                                                                from Beneficiary_Product__c where product__r.ProductCode =: productCode) and 
                                                                Bl_Code_Details__r.Bl_Code__c =: vehicledetails[0].Loan_Application__r.Agent_BL_code__c
                                                                AND Ben_code__r.Status_Flag__c = 'L'AND Ben_code__r.Pseudo_DSM__c = 'Y' AND Ben_code__r.Dealer_Code__c =: ben[0].Dealer_Code__c  AND 
                                                                Ben_code__r.Beneficiary__c = 'DSA' WITH SECURITY_ENFORCED]){
                                                                    if(benficaryProduct.Ben_code__c!=null && benficaryProduct.Ben_code__r.Ben_code__c != null){
                                                                        beneficiaryNameList.add(benficaryProduct.Ben_code__r.name+'-'+benficaryProduct.Ben_code__r.Ben_code__c);
                                                                    }else if(benficaryProduct.Ben_code__r.Dealer_Code__c != null){
                                                                        beneficiaryNameList.add(benficaryProduct.Ben_code__r.Dealer_Code__c);
                                                                        
                                                                    }
                }
            } 
            }
            return beneficiaryNameList;
            
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller', 'dsmNameData', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
            
        }
    }
    
    
    /*
* @Method:      checkSchemeEligibility
* @Created by:  Ruchi Jain
* @Description: This method is use to give the response according to elegibility conditions
* @Param:       String - current Applicant ID
String - scheme record id
* @Return:      String - Serialized JSON response
*/
    @AuraEnabled
    public static String checkSchemeEligibility(String schemeId, String loanApplicationId, String vehicleId){
        try {
            Decimal age;
            Boolean riskband = false;
            Boolean isExistingCustomer = false;
            Boolean cibilPresent = false;
            String customerType = 'New';
            
            ResponseWrapper responseJSON = new ResponseWrapper();           
            Schemes__c schemes=[SELECT Id, Name, FromDate__c, ToDate__c, Product__c, SubProduct__c, UsedVehicleProductCode__c, MinimumAge__c, MaximumAge__c, MinimumCIBILScore__c, MaximumCIBILScore__c, ExistingCustomer__c, RiskBand__c, ServiceCharges__c, DocCharges__c, ProductCode__c, ProductCode__r.Name, Unique_Identifier__c, Scheme_Code__c, AC_Open_Charges__c, Scheme_Expiry__c, Vehicle_Type__c, Manufacturer_Code_Make__c,Manufacturer_Code_Make__r.Name,Model__c, State__c, Agent_BL_code__c, Stamping_Charges__c, Due_Date_Shift_Charges__c, ECS_verification_by_Bank_customer__c, Verification_charges__c, Delinquency_Fund__c, Deliquency_Fund_type__c, RTO_Prefix__c, Trade_Certificate__c, Dlr_Exp_Reimburse_Amt__c, Dlr_Exp_Reimbursement__c, Dlr_Exp_Reimburse_Type__c, Mfr_Exp_Reimburse_Amt__c, Mfr_Exp_Reimburse__c, Mfr_Exp_Reimburse_Type__c, Dealer_incentive_amount_main_dealer__c, Dealer_incentive_amount_sub_dealer__c, Dealer_incentive_amount_main_dealer_p__c, Dealer_incentive_amount_sub_dealer_p__c, Dealer_discount_to_Customer__c, Gift_through_dealer_amount__c, Gift_through_dealer_amount_p__c, Mfr_incentive__c, Mfr_incentive_p__c, DSM_Name1__c, DSM_Incentive1__c, DSM_Incentive1_p__c, DSM_Name2__c, DSM_Incentive2__c, DSM_Incentive2_p__c, Referred_By__c, Referrer_Incetive__c, Referrer_Name__c, Branch__c, Emp_No__c, Emp_Name__c, Deal_no__c, Provision_Channel_Cost__c, DSA_Pay__c, RCU_Retention_Charges__c, Dealer_Sub_dealer_name__c,ECS_verification_Not_Applicable__c,Advance_EMI__c,Payout_Cap__c,Service_Charges_p__c,Doc_Charges_p__c,Entity_Type__c,Vehicle_SubType__c,Customer_Type__c,Asset_Category__c,Nos_of_Asset_Allowed_Min__c,Nos_of_Asset_Allowed_Max__c,Installment_Frequency__c,Installment_Type__c,CRM_IRR_Min__c,CRM_IRR_Max__c,Scheme_Verification__c,Tenure_Max_in_months__c,Tenure_Min_in_months__c FROM Schemes__c where Id=: schemeId WITH SECURITY_ENFORCED];//CISP-2955 //CISP-3013
            Opportunity opp = [SELECT Id,CreatedDate,Product_Type__c,Vehicle_Type__c,Entity_Type__c,Number_of_Products__c,Requested_CRM_IRR__c,Customer_Type__c,Agent_BL_code__c FROM Opportunity WHERE Id=: loanApplicationId WITH SECURITY_ENFORCED];
            Applicant__c apps = [SELECT Id,Customer_Code__c  FROM Applicant__c WHERE Opportunity__c=: loanApplicationId AND Applicant_Type__c=:'Borrower' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            List<Documents__c> docList  = [SELECT Id,Age__c,KYC_DOB__c FROM Documents__c WHERE Applicant__c =: apps.Id AND Proof_of_Identity_POI__c = true WITH SECURITY_ENFORCED];
            Boolean docNotPresent = false;
            if(!docList.isEmpty()){
                if(docList[0].Age__c != null){
                    age = docList[0].Age__c;
                }else if(docList[0].KYC_DOB__c != null){
                    Integer days = docList[0].KYC_DOB__c.daysBetween(Date.Today());
                    age = Integer.valueOf(days/365);
                }
            }else{
                docNotPresent = true;
            }            
            
            List<CIBIL_Details__c> cibilList = new List<CIBIL_Details__c>();
            cibilList = [SELECT Id,Score__c FROM CIBIL_Details__c WHERE Applicant__c =: apps.Id WITH SECURITY_ENFORCED];
            
            if(!cibilList.isEmpty() && cibilList[0].Score__c != null ){
                cibilPresent = true;
            }
            
            for(Applicant__c applicant : [SELECT Scorecard_Decision__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]){
                if(schemes.RiskBand__c == null || schemes.RiskBand__c!=null && applicant.Scorecard_Decision__c!=null && schemes.RiskBand__c.toUppercase().contains(applicant.Scorecard_Decision__c.toUppercase())){//CISP-3012
                    riskband = true;
                }
                else{
                    riskband = false;
                    break;
                }
            }
            
            if(apps.Customer_Code__c != null){
                isExistingCustomer = true;
                customerType = 'Existing';
            }
            List<Vehicle_Detail__c> vehicledetails = new List<Vehicle_Detail__c>();
            String assetCategory = '';
            if (opp.Product_Type__c =='Tractor') {
                vehicledetails = [SELECT Id, Make__c, Model__c,Vehicle_SubType__c,Vehicle_Category__c,Variant_Code__c,Required_CRM_IRR__c,Required_Tenure__c FROM Vehicle_Detail__c WHERE Id =: vehicleId WITH SECURITY_ENFORCED LIMIT 1];
                assetCategory = Utilities.getAssetCategory(opp, vehicledetails[0]);        
            } else {
                vehicledetails = [SELECT Id, Make__c, Model__c,Vehicle_SubType__c,Vehicle_Category__c,Variant_Code__c,Required_CRM_IRR__c,Required_Tenure__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];//StartCISP-2895                
            }
            string vehicleMake;
            string vehicleModel;
            if(vehicledetails.size()>0){
                vehicleMake = vehicledetails[0].Make__c;
                vehicleModel = vehicledetails[0].Model__c;
            }

            if(((schemes.Name.toLowerCase().contains(('No Scheme').toLowerCase()) || schemes.Name.contains('10130')) && opp.Product_Type__c.toLowerCase() =='Passenger Vehicles'.toLowerCase()) || ((schemes.FromDate__c == null  || opp.CreatedDate>schemes.FromDate__c) && 
               (schemes.ToDate__c == null || opp.CreatedDate<schemes.ToDate__c) && 
               (schemes.MinimumCIBILScore__c == null || (cibilPresent && schemes.MinimumCIBILScore__c < Integer.valueOf(cibilList[0].Score__c))) &&
               (schemes.MaximumCIBILScore__c == null || (cibilPresent && schemes.MaximumCIBILScore__c > Integer.valueOf(cibilList[0].Score__c))) && 
               (schemes.MinimumAge__c == null || (!docNotPresent && schemes.MinimumAge__c<age)) &&
               (schemes.MaximumAge__c == null || (!docNotPresent && schemes.MaximumAge__c>age)) && 
               (schemes.Product__c == null || opp.Product_Type__c == schemes.Product__c) &&
               riskband == true && (opp.Product_Type__c.toLowerCase() =='Passenger Vehicles'.toLowerCase() || (schemes.ProductCode__c == null || ((vehicleMake==null || (vehicleMake!=null && schemes.ProductCode__c!= null && schemes.ProductCode__r.Name!=null && vehicleMake.toLowerCase().contains((schemes.ProductCode__r.Name).toLowerCase()))) || (vehicleModel==null || (vehicleModel!=null && schemes.ProductCode__c!= null && schemes.ProductCode__r.Name!=null && vehicleModel.toLowerCase().contains((schemes.ProductCode__r.Name).toLowerCase()))))) && 
               ((opp.Product_Type__c !='Tractor' && isExistingCustomer == schemes.ExistingCustomer__c) || (opp.Product_Type__c =='Tractor' && (schemes.Vehicle_Type__c == null || opp.Vehicle_Type__c == schemes.Vehicle_Type__c) && (schemes.Customer_Type__c == null || (customerType!=null && schemes.Customer_Type__c.contains(customerType)))
               && (schemes.Entity_Type__c == null || (opp.Customer_Type__c!=null && schemes.Entity_Type__c.contains(opp.Customer_Type__c))) && (schemes.Vehicle_SubType__c == null || (vehicledetails[0].Vehicle_SubType__c!=null && schemes.Vehicle_SubType__c.contains(vehicledetails[0].Vehicle_SubType__c))) && (schemes.Asset_Category__c == null || (assetCategory != '' && schemes.Asset_Category__c.contains(assetCategory))) && (schemes.Nos_of_Asset_Allowed_Min__c == null || (opp.Number_of_Products__c!=null && schemes.Nos_of_Asset_Allowed_Min__c <= opp.Number_of_Products__c)) && (schemes.Nos_of_Asset_Allowed_Max__c == null || (opp.Number_of_Products__c!=null && schemes.Nos_of_Asset_Allowed_Max__c >= opp.Number_of_Products__c)) && (schemes.CRM_IRR_Min__c == null || (vehicledetails[0].Required_CRM_IRR__c!=null && schemes.CRM_IRR_Min__c <= vehicledetails[0].Required_CRM_IRR__c)) && (schemes.CRM_IRR_Max__c == null || (vehicledetails[0].Required_CRM_IRR__c!=null && schemes.CRM_IRR_Max__c >= vehicledetails[0].Required_CRM_IRR__c)) && (schemes.Tenure_Min_in_months__c == null || (vehicledetails[0].Required_Tenure__c!=null && schemes.Tenure_Min_in_months__c <= vehicledetails[0].Required_Tenure__c)) && (schemes.Tenure_Max_in_months__c == null || (vehicledetails[0].Required_Tenure__c!=null && schemes.Tenure_Max_in_months__c >= vehicledetails[0].Required_Tenure__c))))
               ))){//End CISP-2895 //CISP-2955 //CISP-2956 CISP-2970 //CISP-3043//CISP-3063 //CISP-3125
                   responseJSON.status=true;
                   responseJSON.docCharge=	schemes.DocCharges__c;
                   responseJSON.serviceCharge=	schemes.ServiceCharges__c;
                   responseJSON.schemeRecord = schemes;
               }
            String serializedResonponse = JSON.serialize(responseJSON);
            return serializedResonponse;   
            
        } catch (Exception e) {
            System.debug('Exception => '+e.getCause() + ' ' + e.getLineNumber());
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' checkSchemeEligibility ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
            
        }
    }
    
    
    //Wrapper Class 
    public class ResponseWrapper {
        public Boolean status {get;set;} 
        public Decimal serviceCharge {get;set;}
        public Decimal docCharge {get;set;}
        public ID finalTermId {get;set;} //add by Raj Gupta
        public String message {get;set;}
        public Schemes__c schemeRecord {get;set;}
        //constructor
        responseWrapper() {            
            this.status = false;
            this.serviceCharge = 0;
            this.docCharge = 0;
            this.finalTermId = null;
            this.message = '';
            
        }
    }
    
    
    /*
* @Method:      createFinalTermRecord
* @Created by:  Raj Gupta
* @Description: This method will create new record in final term object.
* @Param:       String - current Loan Applicantion ID
* @Return:      NA
*/
    @AuraEnabled
    public static String createFinalTermRecord(String loanApplicationId,String vehicleId){
        try{
            ResponseWrapper responseJSON = new ResponseWrapper();
            //Null Check 
            if(loanApplicationId != null){
                List<Final_Term__c> finalTermList = new List<Final_Term__c>();
                Final_Term__c finalTerm = new Final_Term__c();
                Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                if(opp != null && opp.Product_Type__c == System.Label.Tractor && String.isBlank(vehicleId)){
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                if(opp!=null && opp.Product_Type__c== 'Tractor' && vehicleId!=null){
                    finalTermList = [SELECT Id FROM Final_Term__c WHERE Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =:vehicleId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
                }else{
                    finalTermList = [SELECT Id FROM Final_Term__c WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
                }
                if(finalTermList.size()>0){
                    finalTerm = finalTermList[0];
                    responseJSON.finalTermId = finalTerm.id;
                    String serializedResonponse = JSON.serialize(responseJSON);
                    return serializedResonponse; 
                }else{
                    try{ //Duplicate Record Creation Start 
                    finalTerm.Loan_Application__c = loanApplicationId;
                    if(opp.Product_Type__c!= 'Tractor'){finalTerm.Loan_Number__c = loanApplicationId;} //Added Loan Number unique field 
                    
                    if(Schema.sObjectType.Final_Term__c.isCreateable())
                    {
                        insert finalTerm;
                    }
                    }catch(exception e){} //Duplicate Record Creation Start 
                    responseJSON.finalTermId = finalTerm.id;
                    String serializedResonponse = JSON.serialize(responseJSON);
                    return serializedResonponse; 
                }                
            }
            String serializedResonponse = JSON.serialize(responseJSON);
            return serializedResonponse;  
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller' ,'createFinalTermRecord', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

//CISP-3005-START
    /*
* @Method:      getFinalTermRecord
* @Created by:  Gaurav
* @Description: This method will get the record of final term.
* @Param:       String - current Loan Applicantion ID
* @Return:      
*/
    @AuraEnabled
    public static String getFinalTermRecord(String loanApplicationId, String vehicleId){
        try{
            //Null Check 
            String finalTermId = '';
            if(loanApplicationId != null){
                Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                List<Final_Term__c> finalTermList = new List<Final_Term__c>();
                if(opp!=null && opp.Product_Type__c== 'Tractor' && vehicleId!=null){
                    finalTermList = [SELECT Id FROM Final_Term__c WHERE Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =:vehicleId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
                }else{
                    finalTermList = [SELECT Id FROM Final_Term__c WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
                }
                if(finalTermList.size()>0){
                    finalTermId = finalTermList[0].Id;
                }
            }
            return finalTermId;  
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller' ,'getFinalTermRecord', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    // CISP-3005-END
    
    @AuraEnabled
    public static Final_Term__c getFinalTermObjectAsPerVehicle(String loanApplicationId, String vehicleId){
        try{
            List<Final_Term__c> finalTermList = new List<Final_Term__c>();
            if(loanApplicationId != null && vehicleId!=null){
                    finalTermList = [SELECT Id,Installment_Frequency__c FROM Final_Term__c WHERE Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =:vehicleId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            }
            if(finalTermList.size()>0){
                return finalTermList[0];
            }
            return null;  
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller' ,'getFinalTermRecord', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
* @Method:      checkRetryExhausted
* @Created by:  Raj Gupta
* @Description: This method will check retry attemps
* @Param:       String - current Applicantion ID
* @Return:      json -check the retry attemps
*/
    
    @AuraEnabled
    public static String checkRetryExhausted(String loanApplicationId,String vehicleId){ //sftrac-84 starts
        try{
            FinalTermApiWrapper responseJSON = new FinalTermApiWrapper();
            //Null Check 
            if(loanApplicationId != null){
                Retry_Count__c retryCount = new Retry_Count__c();
                List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                if(opp!=null && opp.Product_Type__c== 'Tractor' && vehicleId!=null){
                    retryCountList = [select Loan_Application_Id__c,Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c =:'FinalTermApi' AND Vehicle_Detail__c = :vehicleId WITH SECURITY_ENFORCED Order by createddate DESC LIMIT 1];
                }else{
                    retryCountList = [select Loan_Application_Id__c,Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c =:'FinalTermApi' WITH SECURITY_ENFORCED Order by createddate DESC LIMIT 1];
                }
                if(retryCountList.isEmpty()) {
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    if(opp.Product_Type__c == 'Tractor') {
                        retryCount.Vehicle_Detail__c=vehicleId;
                    }
                    retryCount.Service_Name__c = 'FinalTermApi';
                    retryCount.Count__c = 1;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable())
                    {
                        insert retryCount;
                    }
                }
                else{
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('offer_engine'); 
                    //If number of attempts are greater than predefined number of attempts.
                    // Retry_Count__c  count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c =:'FinalTermApi' WITH SECURITY_ENFORCED];
                    if(retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c)
                    { 
                        responseJSON.message = System.Label.Retry_Exhausted;
                        String serializedResponse = JSON.serialize(responseJSON);
                        return serializedResponse;
                    }
                }
            }
            String serializedResponse = JSON.serialize(responseJSON);
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return serializedResponse;
        }
        //Catch block 
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller' ,System.Label.CheckRetryExhausted, System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    //Wrapper Class
    public class FinalTermApiWrapper {
        public String message {get;set;}
        //constructor
        public FinalTermApiWrapper(){
            this.message = NUll;
        }
    }
    
    /*
* @Method:      retryCountIncrease
* @Created by:  Raj Gupta
* @Description: This method increment the retry attemps count.
* @Param:       String - loan Applicantion ID
* @Return:      NA
*/
    @AuraEnabled
    public static void retryCountIncrease(String loanApplicationId,String vehicleId,Boolean api){ //sftrac-84-changes
        try{
            if(loanApplicationId != null){
                Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                List<Retry_Count__c> count = new List<Retry_Count__c>();
                if(opp!=null && opp.Product_Type__c== 'Tractor' && vehicleId!=null){
                   count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c = 'FinalTermApi' AND Vehicle_Detail__c =:vehicleId WITH SECURITY_ENFORCED];
                }else{
                   count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c = 'FinalTermApi' AND Vehicle_Detail__c =:vehicleId WITH SECURITY_ENFORCED];
                }
                if(count.size() > 0){
                    count[0].Count__c += 1;
                    count[0].IsAPIFailed__c = api;
                }
                if (count.size() > 0 && Schema.sObjectType.Retry_Count__c.isUpdateable()){
                    update count;
                }
            }
        }
        //Catch block 
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller','retryCountIncrease', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    
    
    /*
* @Method:      getFinalTermDetails
* @Created by:  Raj Gupta
* @Description: This method will fetch fields from final term object.
* @Param:       String - current Loan Applicantion ID
* @Return:      json - Details from final term object. 
*/
    @AuraEnabled
    public static finalTermDetailWrapper getFinalTermDetails(String opportunityId,String finalTermId) {
        try
        {
            List<TBM_Proposal_Payin_Validation_Config__c> tfFinalTermValidationList = new List<TBM_Proposal_Payin_Validation_Config__c>();
            if(opportunityId != null){
                finalTermDetailWrapper finalTermDetailsObj = new finalTermDetailWrapper();
                list<Final_Term__c> finalTerm = new list<Final_Term__c>();
                if(finalTermId != null){
                    finalTerm = [SELECT Id,Is_Change_Pay_In_Out_Editable__c,Tenure__c, Scheme_Bank_offers__c, Service_charges__c, Documentation_charges__c, Loan_Deal_Date__c, First_EMI_Date__c, Second_EMI_Date__c,
                             Stamping_charges__c, Due_date_shift_charges__c,RTO_prefix__c,ECS_verification_by__c, Verification_charges__c, 
                             Delinquency_Fund__c, Deliquency_Fund_type__c, Trade_certificate__c, Dlr_Exp_Reimburse_Amt__c,Dlr_Exp_Reimbursement_percent__c,
                             Dlr_Exp_Reimburse_Type__c, Mfr_Exp_Reimburse_Amt__c,Mfr_Exp_Reimburse_percent__c, Mfr_Exp_Reimburse_Type__c, 
                             Dealer_incentive_amount_main_dealer__c, Dealer_incentive_amount_sub_dealer__c, Dealer_Disc_to_Customer__c, 
                             Gift_through_dealer_amount__c, Mfr_incentive__c, DSM_Incentive1__c, DSM_Incentive2__c, Non_Dlr_DSM_Incentive1__c,
                             Non_Dlr_DSM_Incentive2__c, Refered_By__c, Rreferrer_Incentive__c, Referrer_Name__c,RC_limit_enabled_DSA__c, Provisional_Channel_Cost__c,
                             DSA_pay__c, RCU_Retention_Charges__c,DSM_Name1__c,DSM_Name2__c, Repayment_mode__c,isNavigate__c,Loan_Amount__c,Previous_Loan_Amount__c,Advance_EMI__c,Holiday_period__c,Installment_Type__c,Agreement_Amount__c, CRM_IRR__c, 
                             Gross_IRR__c, Inputted_IRR__c, Net_IRR__c,Non_Dlr_DSM_Name2__c,Non_Dlr_DSM_Name1__c, Bank_IRR__c,Loan_Application__r.StageName,Loan_Application__r.Vehicle_Type__C,Loan_Application__r.Product_Type__c,Loan_Application__r.Vehicle_Sub_Category__c,
                             Emp_Name__c,Emp_No__c,EMI_Amount__c,Branch__c,OfferengineMaxLoanAmount__c,Offerengine_StopJourney_Flag__c,Schemes__c, Loan_Application__r.LeadSource, Funding_for_Body__c, Funding_for_Chassis__c,Installment_Frequency__c,LtvEngine_Ltv__c,IsFiWaiverApiSucces__c,PricingEngine_thresholdNetrr__c,L1_Final_Terms_Submitted__c,Vehicle_Detail__r.Loan_Amount__c,Vehicle_Detail__r.Total_Funded_Amount__c,Vehicle_Detail__r.Vehicle_SubCategory__c,Vehicle_Detail__r.Invoice_Price__c,Vehicle_Detail__r.Basic_Price__c,Offer_Agreement_Amount__c,Vehicle_Detail__r.Dealer_Sub_dealer_name__c FROM Final_Term__c where Loan_Application__c =: opportunityId AND Id=:finalTermId WITH SECURITY_ENFORCED LIMIT 1];//Ola Integration changes //sftrac-84(Installment_Frequency__c,LtvEngine_Ltv__c,IsFiWaiverApiSucces__c,PricingEngine_thresholdNetrr__c,L1_Final_Terms_Submitted__c added)
                    finalTermDetailsObj.finalTermDetailLst = finalTerm;
                }
                //Modified by Rohan for DSA
                //CISP-4785 Addded Is_Customer_Dedupe_Submit__c field in SOQL query
                Opportunity opp= [SELECT Id,FOIR_Check_At_FinalTerms__c,Is_Customer_Dedupe_Submit__c,Total_Funded_Premium__c,View_Application_Sub_Stages__c,Required_Tenure__c,Sub_Stage__c,LastStageName__c,StageName,Basic_Price__c,Customer_Type__c,
                                  GST_Amount__c,Discount_on_Basic_Price__c,RTO_Road_Tax__c,RTO_Road_Tax_New__c,Product_Type__c,Vehicle_Type__c,Other_charges__c,Funding_on_Ex_Showroom__c,Funding_on_ORP__c,
                                  X1st_yr_Insurance_Premium__c, LeadSource,Ex_showroom_price__c,On_Road_price__c,isTopUpLoan__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1 ];                
                finalTermDetailsObj.oppRecord = opp;
                Decimal rtoTaxNew = opp.RTO_Road_Tax_New__c != null ? opp.RTO_Road_Tax_New__c : 0;
                Decimal rtoTax = opp.RTO_Road_Tax__c != null ? opp.RTO_Road_Tax__c : 0;

                if(opp.Product_Type__c == 'Two Wheeler' && opp.Vehicle_Type__c == 'New'){
                    
                    finalTermDetailsObj.invoiceAmt = (Integer.valueOf(opp.Basic_Price__c) + Integer.valueOf(opp.GST_Amount__c == null ? 0 : opp.GST_Amount__c) + Integer.valueOf(opp.Discount_on_Basic_Price__c == null ? 0 : opp.Discount_on_Basic_Price__c) +
                                                      Integer.valueOf(rtoTaxNew) + Integer.valueOf(opp.Other_charges__c == null ? 0 : opp.Other_charges__c) + Integer.valueOf(opp.X1st_yr_Insurance_Premium__c == null ? 0 : opp.X1st_yr_Insurance_Premium__c));
                }else if(!(opp.LeadSource == 'D2C' && (opp.Vehicle_Type__c=='Used' || opp.Vehicle_Type__c== 'Refinance')) ){//Added by Rahul- for used and refinance this should not run
                    finalTermDetailsObj.invoiceAmt = (Integer.valueOf(opp.Basic_Price__c == null ? 0 : opp.Basic_Price__c) + Integer.valueOf(opp.GST_Amount__c == null ? 0 : opp.GST_Amount__c) + Integer.valueOf(opp.Discount_on_Basic_Price__c == null ? 0 : opp.Discount_on_Basic_Price__c) +
                                                      Integer.valueOf(rtoTax) + Integer.valueOf(opp.Other_charges__c == null ? 0 : opp.Other_charges__c) + Integer.valueOf(opp.X1st_yr_Insurance_Premium__c == null ? 0 : opp.X1st_yr_Insurance_Premium__c));
                }
                finalTermDetailsObj.basicPrice = opp.Basic_Price__c;
                finalTermDetailsObj.totalFundedPremium = opp.Total_Funded_Premium__c;
                finalTermDetailsObj.fundingOnExShowroom = opp.Funding_on_Ex_Showroom__c;
                finalTermDetailsObj.fundingOnORP = opp.Funding_on_ORP__c;
                finalTermDetailsObj.subStage = opp.Sub_Stage__c;
                finalTermDetailsObj.stage = opp.StageName;
                finalTermDetailsObj.lastStage = opp.LastStageName__c;
                finalTermDetailsObj.viewApplicationSubStages = opp.View_Application_Sub_Stages__c;
                finalTermDetailsObj.exShowroom = opp.Ex_showroom_price__c;
                finalTermDetailsObj.ORP = opp.On_Road_price__c;
                if(opp.Product_Type__c == System.Label.Tractor){
                    finalTermDetailsObj.invoiceAmt = finalTerm.size() > 0 ? Integer.valueOf(finalTerm[0].Vehicle_Detail__r.Invoice_Price__c) : 0;
                    finalTermDetailsObj.totalFundedPremium = finalTerm.size() > 0 ? Integer.valueOf(finalTerm[0].Vehicle_Detail__r.Total_Funded_Amount__c != null ? finalTerm[0].Vehicle_Detail__r.Total_Funded_Amount__c : 0) : 0;
                    finalTermDetailsObj.basicPrice = finalTerm.size() > 0 ? Integer.valueOf(finalTerm[0].Vehicle_Detail__r.Basic_Price__c) : 0;
                }
                if(finalTerm.size() > 0 && finalTerm[0].Loan_Application__r.StageName == 'Credit Processing'){
                    vehicleCategoryCode__mdt vehCatCode = [SELECT vehicleCategoryCode__c from vehicleCategoryCode__mdt where vehicleType__c =: finalTerm[0].Loan_Application__r.Vehicle_Type__C and productType__c =: finalTerm[0].Loan_Application__r.Product_Type__c];
                    finalTermValidation__mdt ftv = [SELECT Id,serviceChargesValue__c,documentChargesFinAmount__c,DocumentchargesPercentage__c,documentChargesMinAmount__c,serviceChargesValueMax__c, serviceChargesValueMin__c,
                                                    DealerExpReimburse__c,DealerExpReimbursePercent__c,MfrExpReimbursePercent__c, DealerIncentiveAmountSubDealer__c,
                                                    DealerIncentiveAmountMainDealer__c,
                                                    DealerDiscounttoCustomer__c, 
                                                    DsmIncentiveOne__c,DsmIncentiveTwo__c,
                                                    Referrer_Incentive_for_referrer__c,ManufacturerIncentive__c,
                                                    NonDlrDsmIncentiveOne__c, NonDlrDsmIncentiveTwo__c, 
                                                    GiftThroughDealerAmount__c,MfrExpReimburseAmt__c,
                                                    ProvisionalChannelCost__c, ProvisionalChannelCostTwo__c, 
                                                    ProvisionalChannelCostMax__c,ProvisionalChannelCostMin__c,
                                                    StampingCharges__c FROM finalTermValidation__mdt where Label =: vehCatCode.vehicleCategoryCode__c ];
                    //Applicant__c app = [Select Total_Insurance_Payable__c from Applicant__c where Opportunity__c =:opportunityId and Applicant_Type__c=:'Borrower' and In_Active_Applicant__c = false WITH SECURITY_ENFORCED limit 1];
                    Integer totalLoanAmount = 0;
                    if(opp.Product_Type__c == System.Label.Tractor){
                        // String vehicleType = opp.Vehicle_Type__c == 'New' ? 'N' : opp.Vehicle_Type__c == 'Used'  ? 'U' : opp.Vehicle_Type__c == 'Refinance' ? 'R' : ''; 
                        // tfFinalTermValidationList = [Select Id,Max_Amount__c,Max_RMC__c,Min_RCM__c,Type__c from TBM_Proposal_Payin_Validation_Config__c Where Used__c =: vehicleType AND Product__c = 'T' LIMIT 100];
                        // Double docMinPercentage = null;
                        // Double docMaxPercentage = null;
                        // Double docMaxAmount = null;

                        // Double serMinPercentage = null;
                        // Double serMaxPercentage = null;
                        // for(TBM_Proposal_Payin_Validation_Config__c tbmObj : tfFinalTermValidationList){
                        //     if(tbmObj.Type__c == 'DocumentCharges'){
                        //         docMaxPercentage = tbmObj.Max_RMC__c;
                        //         docMinPercentage = tbmObj.Min_RCM__c;
                        //         docMaxAmount = tbmObj.Max_Amount__c;   
                        //     }else if(tbmObj.Type__c == 'ServiceCharges'){
                        //         serMinPercentage = tbmObj.Min_RCM__c;
                        //         serMaxPercentage = tbmObj.Max_RMC__c;
                        //     }
                        // }
                        // totalLoanAmount= (Integer)Decimal.valueOf((finalTerm[0].Loan_Amount__c == null || finalTerm[0].Loan_Amount__c == '0') ? String.valueof(finalTerm[0].Vehicle_Detail__r.Loan_Amount__c) : finalTerm[0].Loan_Amount__c) + Integer.valueOf(finalTerm[0].Vehicle_Detail__r.Total_Funded_Amount__c == null ? 0 : finalTerm[0].Vehicle_Detail__r.Total_Funded_Amount__c);
                        // finalTermDetailsObj.financeAmount = totalLoanAmount; 
                        // if(totalLoanAmount!= null){     
                        //     Decimal minValue = (totalLoanAmount * serMinPercentage)/100;
                        //     Decimal maxValue = (totalLoanAmount * serMaxPercentage)/100;
                        //     if( Math.mod((Integer)Decimal.ValueOf(finalTerm[0].Service_charges__c),5) != 0){
                        //         finalTermDetailsObj.serviceChargeFlag = true;
                        //     }  
                        //     if((Decimal.ValueOf(finalTerm[0].Service_charges__c) > maxValue || Decimal.ValueOf(finalTerm[0].Service_charges__c) < minValue)){
                        //         finalTermDetailsObj.serviceChargeFlag = true;
                        //     }
                        //     if (Decimal.ValueOf(finalTerm[0].Service_charges__c) < 0) {
                        //         finalTermDetailsObj.serviceChargeFlag = true;
                        //     }

                        //     Decimal minDocValue = (totalLoanAmount * docMinPercentage)/100;
                        //     Decimal maxDocValue = (totalLoanAmount * docMaxPercentage)/100;
                        //     if( Math.mod((Integer)Decimal.ValueOf(finalTerm[0].Documentation_charges__c),5) != 0){
                        //         finalTermDetailsObj.documentChargeFlag = true;
                        //     }
                        //     if (Decimal.ValueOf(finalTerm[0].Documentation_charges__c) > docMaxAmount) {
                        //         finalTermDetailsObj.documentChargeFlag = true;
                        //     }
                        //     if (Decimal.ValueOf(finalTerm[0].Documentation_charges__c) > maxDocValue || Decimal.ValueOf(finalTerm[0].Documentation_charges__c) < minDocValue) {
                        //         finalTermDetailsObj.documentChargeFlag = true;
                        //     }
                        //     if (Decimal.ValueOf(finalTerm[0].Documentation_charges__c) < 0) {
                        //         finalTermDetailsObj.documentChargeFlag = true;
                        //     }
                        // }

                        // if((opp.Vehicle_Type__c == 'Used' || opp.Vehicle_Type__c == 'New') && opp.isTopUpLoan__c == false){
                        // if(ftv.DealerIncentiveAmountMainDealer__c!=null && finalTerm[0].Dealer_incentive_amount_main_dealer__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DealerIncentiveAmountMainDealer__c))/100) < (Integer)Decimal.ValueOf(finalTerm[0].Dealer_incentive_amount_main_dealer__c)){
                        //     finalTermDetailsObj.dealerIncentiveAmountMainDealerFlag = true;
                        // }
                        // if(finalTerm[0].Dealer_incentive_amount_main_dealer__c != null && (Integer)Decimal.ValueOf(finalTerm[0].Dealer_incentive_amount_main_dealer__c) < 0){
                        //     finalTermDetailsObj.dealerIncentiveAmountMainDealerFlag = true;
                        // }
                        // if (ftv.DealerDiscounttoCustomer__c!=null && finalTerm[0].Dealer_Disc_to_Customer__c!=null && ((((totalLoanAmount * Integer.ValueOf(ftv.DealerDiscounttoCustomer__c))/100) < (Integer)Decimal.ValueOf(finalTerm[0].Dealer_Disc_to_Customer__c)))) {
                        //     finalTermDetailsObj.dealerDiscounttoCustomerFlag = true;
                        // }
                        // if(finalTerm[0].Dealer_Disc_to_Customer__c != null && (Integer)Decimal.ValueOf(finalTerm[0].Dealer_Disc_to_Customer__c) < 0){
                        //     finalTermDetailsObj.dealerDiscounttoCustomerFlag = true;
                        // }
                        // if(ftv.GiftThroughDealerAmount__c!=null && finalTerm[0].Gift_through_dealer_amount__c!=null && (((totalLoanAmount * Integer.ValueOf(ftv.GiftThroughDealerAmount__c))/100) < (Integer)Decimal.ValueOf(finalTerm[0].Gift_through_dealer_amount__c))){
                        //     finalTermDetailsObj.giftThroughDealerAmountFlag = true;
                        // }
                        // if(finalTerm[0].Gift_through_dealer_amount__c != null && (Integer)Decimal.ValueOf(finalTerm[0].Gift_through_dealer_amount__c) < 0){
                        //     finalTermDetailsObj.giftThroughDealerAmountFlag = true;
                        // }
                        // if(ftv.DsmIncentiveOne__c!=null && finalTerm[0].DSM_Incentive1__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DsmIncentiveOne__c))/100) < (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive1__c)){
                        //     finalTermDetailsObj.dsmIncentiveOneFlag = true;
                        // }
                        // if(finalTerm[0].DSM_Incentive1__c != null && (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive1__c) < 0){
                        //     finalTermDetailsObj.dsmIncentiveOneFlag = true;
                        // }
                        // if(ftv.DsmIncentiveTwo__c!=null && finalTerm[0].DSM_Incentive2__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DsmIncentiveTwo__c))/100) < (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive2__c)){
                        //     finalTermDetailsObj.dsmIncentiveTwoFlag = true;
                        // }
                        // if(finalTerm[0].DSM_Incentive2__c != null && (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive2__c) < 0){
                        //     finalTermDetailsObj.dsmIncentiveTwoFlag = true;
                        // }
                        // if(ftv.Referrer_Incentive_for_referrer__c!= null && finalTerm[0].Rreferrer_Incentive__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.Referrer_Incentive_for_referrer__c))/100) < (Integer)Decimal.valueOf(finalTerm[0].Rreferrer_Incentive__c) && finalTerm[0].Refered_By__c == 'Ref. ref.'){
                        //     finalTermDetailsObj.reffererIncentiveFlag = true;
                        // }
                        // if(finalTerm[0].Rreferrer_Incentive__c != null && (Integer)Decimal.ValueOf(finalTerm[0].Rreferrer_Incentive__c) < 0){
                        //     finalTermDetailsObj.reffererIncentiveFlag = true;
                        // }
                        // }
                    }else{
                    if(finalTerm[0].Loan_Amount__c!=null && opp.Total_Funded_Premium__c!=null && (Integer)Decimal.valueOf(finalTerm[0].Loan_Amount__c)!=null && Integer.valueOf(opp.Total_Funded_Premium__c)!=null )
                    {//CISP-3188
                        totalLoanAmount= (Integer)Decimal.valueOf(finalTerm[0].Loan_Amount__c) + Integer.valueOf(opp.Total_Funded_Premium__c);//CISP-3188
                        finalTermDetailsObj.financeAmount = totalLoanAmount; 
                    }
                    if(totalLoanAmount!= null){     
                        Decimal minValue = (totalLoanAmount * ftv.serviceChargesValueMin__c)/100;
                        Decimal maxValue = (totalLoanAmount * ftv.serviceChargesValueMax__c)/100;
                        Decimal gstValue =  Decimal.ValueOf(finalTerm[0].Service_charges__c)*18.0/118;
                        gstValue = gstValue.setScale(2);
                        Decimal docAmount = Decimal.ValueOf(finalTerm[0].Service_charges__c) - gstValue;
                        if((docAmount > maxValue) && (vehCatCode.vehicleCategoryCode__c == 'C'
                                                      || vehCatCode.vehicleCategoryCode__c == 'R' || vehCatCode.vehicleCategoryCode__c == 'U')){
                                                          finalTermDetailsObj.serviceChargeFlag = true;
                                                      }
                        if( Math.mod((Integer)Decimal.ValueOf(finalTerm[0].Service_charges__c),5) != 0)//CISP-3188
                        {
                            finalTermDetailsObj.serviceChargeFlag = true;
                        }
                        
                        if((Decimal.ValueOf(finalTerm[0].Service_charges__c) > maxValue ||
                            Decimal.ValueOf(finalTerm[0].Service_charges__c) < minValue) && (vehCatCode.vehicleCategoryCode__c == 'S'
                                                                                             || vehCatCode.vehicleCategoryCode__c == 'H')){
                                                                                                 finalTermDetailsObj.serviceChargeFlag = true;
                                                                                             }
                        if( Math.mod((Integer)Decimal.ValueOf(finalTerm[0].Service_charges__c),5) != 0)//CISP-3188
                        {
                            finalTermDetailsObj.serviceChargeFlag = true;
                        }
                    }
                    Decimal gstValue1 =  Decimal.ValueOf(finalTerm[0].Documentation_charges__c)*18.0/118;
                    gstValue1 = gstValue1.setScale(2);
                    Decimal docAmount1 = Decimal.ValueOf(finalTerm[0].Documentation_charges__c) - gstValue1;
                    if (finalTerm[0].Loan_Application__r.Product_Type__c == System.Label.PassengerVehicles) {
                        decimal documentationChargesValuePv = (ftv.DocumentchargesPercentage__c * totalLoanAmount) / 100;
                        if ( docAmount1 > documentationChargesValuePv) {
                            finalTermDetailsObj.documentChargeFlag = true;
                        }
                    }
                    if (finalTerm[0].Loan_Application__r.Product_Type__c == System.Label.TwoWheeler) {
                        decimal documentationChargesValuetw = (ftv.DocumentchargesPercentage__c * totalLoanAmount) / 100;
                        if (totalLoanAmount < ftv.documentChargesFinAmount__c) {
                            if (Decimal.ValueOf(finalTerm[0].Documentation_charges__c) != documentationChargesValuetw) {
                                finalTermDetailsObj.documentChargeFlag = true;
                            }
                        }else {
                            if (Decimal.ValueOf(finalTerm[0].Documentation_charges__c) < ftv.documentChargesMinAmount__c || Decimal.ValueOf(finalTerm[0].Documentation_charges__c) > documentationChargesValuetw) {
                                finalTermDetailsObj.documentChargeFlag = true;
                            }
                        }
                    }

                    Integer checkDealerDiscounttoCustomer = 0;
                    Integer dealerDiscounttoCustomerValue = 0;
                    if(finalTerm.size() > 0 && finalTerm[0].Dealer_Disc_to_Customer__c != null){
                        dealerDiscounttoCustomerValue = (Integer)Decimal.valueof(finalTerm[0].Dealer_Disc_to_Customer__c);
                    }
                    if (finalTerm[0].Loan_Application__r.Product_Type__c == System.Label.PassengerVehicles && finalTerm[0].Loan_Application__r.Vehicle_Type__c == 'New') {
                        if (finalTermDetailsObj.fundingOnExShowroom == true) {
                            checkDealerDiscounttoCustomer = (Integer)((Integer.ValueOf(ftv.DealerDiscounttoCustomer__c) * finalTermDetailsObj.exShowroom) / 100);
                        }
                        if (finalTermDetailsObj.fundingOnORP == true) {
                            checkDealerDiscounttoCustomer = (Integer)((Integer.ValueOf(ftv.DealerDiscounttoCustomer__c) * finalTermDetailsObj.ORP) / 100);
                        }
                        if (dealerDiscounttoCustomerValue != null && checkDealerDiscounttoCustomer != null && ((Integer)dealerDiscounttoCustomerValue > (Integer)checkDealerDiscounttoCustomer)) {
                            finalTermDetailsObj.dealerDiscounttoCustomerFlag = true;
                        }
                    } else if ((finalTerm[0].Loan_Application__r.Product_Type__c == System.Label.PassengerVehicles || finalTerm[0].Loan_Application__r.Product_Type__c == System.Label.TwoWheeler) && (finalTerm[0].Loan_Application__r.Vehicle_Sub_Category__c == 'UPD')) {
                        checkDealerDiscounttoCustomer = (Integer.ValueOf(ftv.DealerDiscounttoCustomer__c) * totalLoanAmount) / 100;
                        if (dealerDiscounttoCustomerValue != null && checkDealerDiscounttoCustomer != null && ((Integer)dealerDiscounttoCustomerValue > (Integer)checkDealerDiscounttoCustomer)) {
                            finalTermDetailsObj.dealerDiscounttoCustomerFlag = true;
                        }
                    } else{
                        if (finalTermDetailsObj.fundingOnExShowroom == true) {
                            checkDealerDiscounttoCustomer = (Integer)((Integer.ValueOf(ftv.DealerDiscounttoCustomer__c) * finalTermDetailsObj.exShowroom) / 100);
                        }
                        if (finalTermDetailsObj.fundingOnORP == true) {
                            checkDealerDiscounttoCustomer = (Integer)((Integer.ValueOf(ftv.DealerDiscounttoCustomer__c) * finalTermDetailsObj.ORP) / 100);
                        }
                        if (dealerDiscounttoCustomerValue != null && checkDealerDiscounttoCustomer != null && ((Integer)dealerDiscounttoCustomerValue > (Integer)checkDealerDiscounttoCustomer)) {
                            finalTermDetailsObj.dealerDiscounttoCustomerFlag = true;
                        }
                    }

                    if (Decimal.ValueOf(finalTerm[0].Documentation_charges__c) < 0) {
                        finalTermDetailsObj.documentChargeFlag = true;
                    }
                    if(ftv.DealerExpReimburse__c!=null && finalTerm[0].Dlr_Exp_Reimburse_Amt__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DealerExpReimburse__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].Dlr_Exp_Reimburse_Amt__c)){//CISP-3188
                        finalTermDetailsObj.dealerExpReimburseFlag = true;
                    }
                    if(ftv.Referrer_Incentive_for_referrer__c!= null && finalTerm[0].Rreferrer_Incentive__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.Referrer_Incentive_for_referrer__c))/100) <= (Integer)Decimal.valueOf(finalTerm[0].Rreferrer_Incentive__c) && finalTerm[0].Refered_By__c == 'Ref. ref.'){//CISP-3188
                        finalTermDetailsObj.reffererIncentiveFlag = true;
                    }
                    if(ftv.DealerExpReimbursePercent__c!= null && finalTerm[0].Dlr_Exp_Reimbursement_percent__c!=null && finalTerm[0].Dlr_Exp_Reimbursement_percent__c!='null' && (10 <= Decimal.ValueOf(finalTerm[0].Dlr_Exp_Reimbursement_percent__c))){//CISP-2386 - Added another condition finalTerm[0].Dlr_Exp_Reimbursement_percent__c!='null'
                        finalTermDetailsObj.dlrExpReimbursementPercentageFlag = true;
                    }
                    if(ftv.MfrExpReimbursePercent__c!= null && finalTerm[0].Mfr_Exp_Reimburse_percent__c!=null && (10 <= Decimal.ValueOf(finalTerm[0].Mfr_Exp_Reimburse_percent__c))){
                        finalTermDetailsObj.mfrExpReimbursementPercentageFlag = true;
                    }
                    if (finalTerm[0].Dealer_incentive_amount_sub_dealer__c!=null && vehCatCode.vehicleCategoryCode__c == 'S' && (Integer)Decimal.ValueOf(finalTerm[0].Dealer_incentive_amount_sub_dealer__c) >= 1)
                    {//CISP-3188
                        finalTermDetailsObj.dealerIncentiveAmountSubDealerFlag = true;
                    }
                    else{if(ftv.DealerIncentiveAmountSubDealer__c!=null && finalTerm[0].Dealer_incentive_amount_sub_dealer__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DealerIncentiveAmountSubDealer__c))/100) <= (Integer)Decimal.valueOf(finalTerm[0].Dealer_incentive_amount_sub_dealer__c)){//CISP-3188
                        finalTermDetailsObj.dealerIncentiveAmountSubDealerFlag = true;
                    } 
                        }
                    if (finalTerm[0].Dealer_incentive_amount_main_dealer__c!=null && vehCatCode.vehicleCategoryCode__c == 'S' && (Integer)Decimal.ValueOf(finalTerm[0].Dealer_incentive_amount_main_dealer__c) >= 1)
                    {//CISP-3188
                        finalTermDetailsObj.dealerIncentiveAmountMainDealerFlag = true;
                    }
                    else{if(ftv.DealerIncentiveAmountMainDealer__c!=null && finalTerm[0].Dealer_incentive_amount_main_dealer__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DealerIncentiveAmountMainDealer__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].Dealer_incentive_amount_main_dealer__c)){//CISP-3188
                        finalTermDetailsObj.dealerIncentiveAmountMainDealerFlag = true;
                    } 
                        }
                    // if(ftv.DealerDiscounttoCustomer__c!=null && finalTerm[0].Dealer_Disc_to_Customer__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DealerDiscounttoCustomer__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].Dealer_Disc_to_Customer__c)){//CISP-3188
                    //     finalTermDetailsObj.dealerDiscounttoCustomerFlag = true;
                    // }
                    if (finalTerm[0].DSM_Incentive1__c!=null && vehCatCode.vehicleCategoryCode__c == 'S' && (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive1__c) >= 1)
                    {//CISP-3188
                        finalTermDetailsObj.dsmIncentiveOneFlag = true;
                    }
                    else{if(ftv.DsmIncentiveOne__c!=null && finalTerm[0].DSM_Incentive1__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DsmIncentiveOne__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive1__c)){//CISP-3188
                        finalTermDetailsObj.dsmIncentiveOneFlag = true;
                    }}
                    if (finalTerm[0].Non_Dlr_DSM_Incentive1__c!=null && vehCatCode.vehicleCategoryCode__c == 'S' && (Integer)Decimal.ValueOf(finalTerm[0].Non_Dlr_DSM_Incentive1__c) >= 1)
                    {//CISP-3188
                        finalTermDetailsObj.nonDlrDsmIncentiveOneFlag = true;
                    }
                    else{              
                        if(ftv.NonDlrDsmIncentiveOne__c!=null && finalTerm[0].Non_Dlr_DSM_Incentive1__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.NonDlrDsmIncentiveOne__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].Non_Dlr_DSM_Incentive1__c)){//CISP-3188
                            finalTermDetailsObj.nonDlrDsmIncentiveOneFlag = true;
                        }}
                    if (finalTerm[0].Non_Dlr_DSM_Incentive2__c!=null && vehCatCode.vehicleCategoryCode__c == 'S' && (Integer)Decimal.ValueOf(finalTerm[0].Non_Dlr_DSM_Incentive2__c) >= 1)
                    {//CISP-3188
                        finalTermDetailsObj.nonDlrDsmIncentiveTwoFlag = true;
                    }
                    else{
                        if(ftv.NonDlrDsmIncentiveTwo__c!=null && finalTerm[0].Non_Dlr_DSM_Incentive2__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.NonDlrDsmIncentiveTwo__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].Non_Dlr_DSM_Incentive2__c)){//CISP-3188
                            finalTermDetailsObj.nonDlrDsmIncentiveTwoFlag = true;
                        }}
                    if (finalTerm[0].DSM_Incentive2__c!=null && vehCatCode.vehicleCategoryCode__c == 'S' && (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive2__c) >= 1)
                    {//CISP-3188
                        finalTermDetailsObj.dsmIncentiveTwoFlag = true;
                    }
                    else{
                        if(ftv.DsmIncentiveTwo__c!=null && finalTerm[0].DSM_Incentive2__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.DsmIncentiveTwo__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].DSM_Incentive2__c)){//CISP-3188
                            finalTermDetailsObj.dsmIncentiveTwoFlag = true;
                        }
                    }
                    if (finalTerm[0].Gift_through_dealer_amount__c!=null && vehCatCode.vehicleCategoryCode__c == 'S' && (Integer)Decimal.ValueOf(finalTerm[0].Gift_through_dealer_amount__c) >= 1)
                    {//CISP-3188
                        finalTermDetailsObj.giftThroughDealerAmountFlag = true;
                    }
                    else{
                        if(ftv.GiftThroughDealerAmount__c!=null && finalTerm[0].Gift_through_dealer_amount__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.GiftThroughDealerAmount__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].Gift_through_dealer_amount__c)){//CISP-3188
                            finalTermDetailsObj.giftThroughDealerAmountFlag = true;
                        }
                    }
                    if(ftv.MfrExpReimburseAmt__c!=null && finalTerm[0].Mfr_Exp_Reimburse_Amt__c!=null && ((totalLoanAmount * Integer.ValueOf(ftv.MfrExpReimburseAmt__c))/100) <= (Integer)Decimal.ValueOf(finalTerm[0].Mfr_Exp_Reimburse_Amt__c)){//CISP-3188
                        finalTermDetailsObj.mfrExpReimburseAmtFlag = true;
                    }
                    if(vehCatCode.vehicleCategoryCode__c == 'H')
                    {
                        if(finalTerm[0].Tenure__c!=null && (Integer)Decimal.ValueOf(finalTerm[0].Tenure__c) > 12)
                        {//CISP-3188
                            if(ftv.ProvisionalChannelCost__c!=null && totalLoanAmount!=null && ftv.ProvisionalChannelCostMin__c!=null && finalTerm[0].Provisional_Channel_Cost__c!=null && (Math.round(((totalLoanAmount * Integer.ValueOf(ftv.ProvisionalChannelCost__c))/100) + ftv.ProvisionalChannelCostMin__c) != (Integer)Decimal.ValueOf(finalTerm[0].Provisional_Channel_Cost__c)) )
                            {//CISP-3188
                                finalTermDetailsObj.provisionalChannelCostFlag = true;
                            }
                        }
                        else
                        {
                            if(ftv.ProvisionalChannelCost__c!=null && totalLoanAmount!=null && ftv.ProvisionalChannelCostMax__c!=null && finalTerm[0].Provisional_Channel_Cost__c!=null && Math.round(((totalLoanAmount * Integer.ValueOf(ftv.ProvisionalChannelCost__c))/100) + ftv.ProvisionalChannelCostMax__c) != (Integer)Decimal.ValueOf(finalTerm[0].Provisional_Channel_Cost__c)) 
                            {//CISP-3188
                                finalTermDetailsObj.provisionalChannelCostFlag = true;
                            }
                        }
                    }
                    else if(vehCatCode.vehicleCategoryCode__c == 'S')
                    {
                        if(ftv.ProvisionalChannelCost__c!=null && totalLoanAmount!=null && ftv.ProvisionalChannelCostMax__c!=null && finalTerm[0].Provisional_Channel_Cost__c!=null && Math.round(((totalLoanAmount * Integer.ValueOf(ftv.ProvisionalChannelCost__c))/100) + ftv.ProvisionalChannelCostMax__c) != (Integer)Decimal.ValueOf(finalTerm[0].Provisional_Channel_Cost__c)) 
                        {//CISP-3188
                            finalTermDetailsObj.provisionalChannelCostFlag = true;
                        }
                    }
                }
            }//Adding Closing tag
            return finalTermDetailsObj;
            }
            return null;
        }
        //Catch block 
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller' , 'getFinalTermDetails', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    } 
    
    /*
* @Method:      getApiOutput.
* @Created by:  Raj Gupta
* @Description: This method will fetch fields from final term object.
* @Param:       String - current Loan Applicantion ID
* @Return:      json - Details from final term object.
*/
    @AuraEnabled
    public static finalTermDetailWrapper getApiOutput(String opportunityId) {
        try
        {
            if(opportunityId != null){
                finalTermDetailWrapper finalTermDetailsObj = new finalTermDetailWrapper();
                Final_Term__c finalTerm = [SELECT Id, LtvEngine_Ltv__c, PricingEngine_thresholdNetrr__c, IsFiWaiverApiSucces__c, FIwaiver_presentAddress__c,Loan_Amount__c,isNavigate__c FROM Final_Term__c
                                           where Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];
                finalTermDetailsObj.isFiWaiverApiSuccess = finalTerm.IsFiWaiverApiSucces__c;
                finalTermDetailsObj.ltvEngine = finalTerm.LtvEngine_Ltv__c;
                finalTermDetailsObj.pricingEnginethresholdNetIrr = finalTerm.PricingEngine_thresholdNetrr__c;
                finalTermDetailsObj.fiwaiverPresentAddress = finalTerm.FIwaiver_presentAddress__c;
                finalTermDetailsObj.loanAmt = finalTerm.Loan_Amount__c;
                finalTermDetailsObj.navigation = finalTerm.isNavigate__c;
                
                return finalTermDetailsObj;
            }
            return null;
        }
        //Catch block 
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller' , 'getApiOutput', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    } 
    
    
    //Wrapper class
    public class finalTermDetailWrapper{
        @AuraEnabled public List<Beneficiary_Manufacturer__c> manufacturerCodeList;//CISP-20395
        @AuraEnabled public List<Vehicle_Detail__c> vechicalDetailLst;
        @AuraEnabled public List<Final_Term__c> finalTermDetailLst;
        @AuraEnabled public List<finalTermValidation__mdt> finalTermVal;
        @AuraEnabled public List<TBM_Proposal_Payin_Validation_Config__c> tfFinalTermValidation;
        @AuraEnabled public String loanAmt;
        @AuraEnabled public String productTypestr;
        @AuraEnabled public Boolean dedupeSubmitted;
        @AuraEnabled public String applicationType;
        @AuraEnabled public String vehicleSubCategoryStr;
        @AuraEnabled public String vehicleTypeStr;
        @AuraEnabled public String vehicleDeliveredStr;
        @AuraEnabled public String name; 
        @AuraEnabled public String subStage;
        @AuraEnabled public String stage;
        @AuraEnabled public String lastStage;
        @AuraEnabled public String viewApplicationSubStages;
        @AuraEnabled public Decimal requiredTenure;
        @AuraEnabled public Boolean serviceChargeFlag=false;
        @AuraEnabled public Boolean documentChargeFlag= false;
        @AuraEnabled public Boolean dealerExpReimburseFlag = false;
        @AuraEnabled public Boolean dealerIncentiveAmountSubDealerFlag = false;
        @AuraEnabled public Boolean dealerIncentiveAmountMainDealerFlag = false;
        @AuraEnabled public Boolean dealerDiscounttoCustomerFlag = false;
        @AuraEnabled public Boolean dsmIncentiveOneFlag = false;
        @AuraEnabled public Boolean nonDlrDsmIncentiveOneFlag = false;
        @AuraEnabled public Boolean nonDlrDsmIncentiveTwoFlag = false;
        @AuraEnabled public Boolean dsmIncentiveTwoFlag = false;
        @AuraEnabled public Boolean giftThroughDealerAmountFlag = false;
        @AuraEnabled public Boolean mfrExpReimburseAmtFlag = false;
        @AuraEnabled public Boolean provisionalChannelCostFlag = false;
        @AuraEnabled public Boolean reffererIncentiveFlag = false;
        @AuraEnabled public Boolean dlrExpReimbursementPercentageFlag = false;
        @AuraEnabled public Boolean mfrExpReimbursementPercentageFlag = false;
        @AuraEnabled public Decimal invoiceAmt = 0;
        @AuraEnabled public Decimal basicPrice = 0;
        @AuraEnabled public Decimal totalFundedPremium = 0;
        @AuraEnabled public Boolean fundingOnORP = false;
        @AuraEnabled public Boolean fundingOnExShowroom = false;
        @AuraEnabled public Boolean isFiWaiverApiSuccess = false;
        @AuraEnabled public String fiwaiverPresentAddress = null;
        @AuraEnabled public Decimal  ltvEngine = null;
        @AuraEnabled public Decimal  pricingEnginethresholdNetIrr = null;
        @AuraEnabled public Boolean  navigation = false;
        @AuraEnabled public Boolean  scorecard = false;
        @AuraEnabled public Integer financeAmount = 0;
        @AuraEnabled public Opportunity oppRecord;
        @AuraEnabled public decimal manufactureIncentive = null;//CISP-2954
        @AuraEnabled public decimal exShowroom;//CISP-3785
        @AuraEnabled public decimal ORP;//CISP-3785
        @AuraEnabled public Boolean OEMDealer;
        @AuraEnabled public Decimal requiredCrmIRR;
        @AuraEnabled public String dealerSubDealer;        
        @AuraEnabled public String repaymentFrequency; //SFTRAC-1795
        @AuraEnabled public String installMentType;    //SFTRAC-1795
    }
    
    /*
* @Method:      getFinalTermFieldValidationDetails
* @Created by:  Raj Gupta
* @Description: This method will fetch fields from Opportunity, vehicle details and metadata.
* @Param:       String - current Loan Applicantion ID
* @Return:      json - Details From Opportunity, vehicle objects and metadata.
*/
    @AuraEnabled
    public static finalTermDetailWrapper getFinalTermFieldValidationDetails(String opportunityId,String vehicleId) {
        try
        {
            Opportunity opp = new Opportunity();
            String vehicleCategoryCode; 
            finalTermDetailWrapper finalTermDetailsObj = new finalTermDetailWrapper();
            list<finalTermValidation__mdt> finalTermVali = new list<finalTermValidation__mdt>();
            List<TBM_Proposal_Payin_Validation_Config__c> tfFinalTermValidationList = new List<TBM_Proposal_Payin_Validation_Config__c>();
            Map<String,Object> finalTermMetadata = new Map<String,Object>(); 
            //CISP-124 - START
            list<Final_Term__c> finalTerm = new list<Final_Term__c>();
            list<Vehicle_Detail__c> vehicleList = new list<Vehicle_Detail__c>();
            //CISP-124 - END
            if(opportunityId != null){
                opp = [SELECT Id,Product_Type__c,Vehicle_Sub_Category__c,Vehicle_Type__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];
                if(opp!= null && opp.Product_Type__c == 'Tractor'){
                    vehicleList = [SELECT Id,Repayment_Frequency__c, Installment_Type__c, Vehicle_SubCategory__c,Vehicle_Delivered__c, Required_Tenure__c,Loan_Amount__c,Required_CRM_IRR__c,Dealer_Sub_dealer_name__c FROM Vehicle_Detail__c where Loan_Application__c =: opportunityId AND Id =:vehicleId WITH SECURITY_ENFORCED LIMIT 1]; //SFTRAC-1795 added Repayment_Frequency__c and Installment_Type__c
                    finalTermDetailsObj.dealerSubDealer = vehicleList[0].Dealer_Sub_dealer_name__c;
                    finalTermDetailsObj.repaymentFrequency = vehicleList[0].Repayment_Frequency__c; //SFTRAC-1795
                    finalTermDetailsObj.installMentType = vehicleList[0].Installment_Type__c;   //SFTRAC-1795
                    String vehicleType = opp.Vehicle_Type__c == 'New' ? 'N' : opp.Vehicle_Type__c == 'Used'  ? 'U' : opp.Vehicle_Type__c == 'Refinance' ? 'R' : ''; 
                    finalTerm = [SELECT Id,Tenure__c, Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c, Installment_Type__c,Installment_Frequency__c,Vehicle_Detail__r.Vehicle_SubCategory__c, Vehicle_Detail__r.Vehicle_Delivered__c FROM Final_Term__c where Loan_Application__c =: opportunityId AND Vehicle_Detail__c =:vehicleId WITH SECURITY_ENFORCED LIMIT 1];// CISP-124 OR CISP-2655- Added TotalFundedPremium field in the query.
                    tfFinalTermValidationList = [Select Id,Max_Amount__c,Max_RMC__c,Min_RCM__c,Type__c from TBM_Proposal_Payin_Validation_Config__c Where Used__c =: vehicleType AND Product__c = 'T' LIMIT 100];
                }else{
                    finalTerm = [SELECT Id,Tenure__c, Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c,Installment_Type__c FROM Final_Term__c where Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];// CISP-124 OR CISP-2655- Added TotalFundedPremium field in the query.
                }
                finalTermDetailsObj.finalTermDetailLst = finalTerm;
                list<Applicant__c> app = new list<Applicant__c>();
                app = [Select Scorecard_Decision__c,Opportunity__r.Product_Type__c from Applicant__c where Opportunity__c =:opportunityId and In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                for(Applicant__c applicant : app)
                {
                    if(applicant.Opportunity__r.Product_Type__c == 'Two Wheeler' && applicant.Scorecard_Decision__c == 'Red'){
                        finalTermDetailsObj.scorecard = true;
                    }
                }
                vehicleCategoryCode__mdt vehicleCategoryCodes= [SELECT vehicleCategoryCode__c from vehicleCategoryCode__mdt where vehicleType__c =: opp.Vehicle_Type__c and productType__c =: opp.Product_Type__c];
                vehicleCategoryCode = vehicleCategoryCodes.vehicleCategoryCode__c; 
                finalTermVali = [SELECT Id,serviceChargesValue__c,documentChargesFinAmount__c,DocumentchargesPercentage__c,documentChargesMinAmount__c,serviceChargesValueMax__c, serviceChargesValueMin__c,
                                 DealerExpReimburse__c,DealerExpReimbursePercent__c,MfrExpReimbursePercent__c, DealerIncentiveAmountSubDealer__c,
                                 DealerIncentiveAmountMainDealer__c,
                                 DealerDiscounttoCustomer__c, 
                                 DsmIncentiveOne__c,DsmIncentiveTwo__c,
                                 Referrer_Incentive_for_referrer__c,ManufacturerIncentive__c,
                                 NonDlrDsmIncentiveOne__c, NonDlrDsmIncentiveTwo__c, 
                                 GiftThroughDealerAmount__c,MfrExpReimburseAmt__c,
                                 ProvisionalChannelCost__c, ProvisionalChannelCostTwo__c, 
                                 ProvisionalChannelCostMax__c,ProvisionalChannelCostMin__c, DocumentChargesMinPercentage__c,
                                 StampingCharges__c FROM finalTermValidation__mdt where product__c =:vehicleCategoryCode WITH SECURITY_ENFORCED LIMIT 1];
                finalTermDetailsObj.finalTermVal  = finalTermVali;
                finalTermDetailsObj.tfFinalTermValidation  = tfFinalTermValidationList;
                Map<String,Object> finalTermDetails = new Map<String,Object>(); 
                List<Opportunity> finalTermDetailsList = new List<Opportunity>();
                finalTermDetailsList = [SELECT Id,Is_Customer_Dedupe_Submit__c,Name,Required_Loan_amount__c,Product_Type__c,Required_Tenure__c,Vehicle_Sub_Category__c,Vehicle_Type__c,Total_Funded_Premium__c,Ex_showroom_price__c,On_Road_price__c, Application_Type__c,OEM_Dealer_Checkbox__c, //CISP-3785
                                        (SELECT ID,Make__c,Vehicle_SubType__c,Ben_code__c, Vehicle_Delivered__c FROM Vehicle_Details__r) //sftrac-85 - Vehicle_Sub_Category__c
                                        FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1 ];//Start CISP-2954

                if(finalTermDetailsList.size()> 0 && finalTermDetailsList[0].Vehicle_Details__r[0].Ben_Code__c != null){//CISP-20395
                        List<Beneficiary_Manufacturer__c> manufacturerCode = new List<Beneficiary_Manufacturer__c>();
                            manufacturerCode = [Select Beneficiary_Master__r.Ben_code__c,Manufacturer__r.Manufacturer_code__c from Beneficiary_Manufacturer__c where Beneficiary_Master__r.Ben_code__c  =:finalTermDetailsList[0].Vehicle_Details__r[0].Ben_Code__c];
                            finalTermDetailsObj.manufacturerCodeList = manufacturerCode;
                }

                Integer totalLoanAmount = 0;
                if(finalTermDetailsList.size()> 0 && (finalTermDetailsList[0].Required_Loan_amount__c!=null || (finalTerm.size()>0 && finalTerm[0].Loan_Amount__c!=null)) && finalTermDetailsList[0].Total_Funded_Premium__c!=null){
                    totalLoanAmount = ((finalTerm.size()>0 && finalTerm[0].Loan_Amount__c!=null) ? (Integer)Decimal.valueOf(finalTerm[0].Loan_Amount__c) : Integer.valueOf(finalTermDetailsList[0]?.Required_Loan_amount__c)) + Integer.valueOf(finalTermDetailsList[0].Total_Funded_Premium__c);//CISP-3188
                }   
                if (finalTermDetailsList[0].Product_Type__c == 'Two Wheeler' && finalTermDetailsList[0].Vehicle_Details__r[0].Make__c.toLowerCase().contains(('Hero MotoCorp').toLowerCase())) {
                    finalTermDetailsObj.manufactureIncentive = (finalTermVali[0].ManufacturerIncentive__c * totalLoanAmount) / 100;
                }// End CISP-2954
                for(Opportunity opportunityObj : finalTermDetailsList) {
                    finalTermDetailsObj.loanAmt = opportunityObj.Product_Type__c == System.Label.Tractor ? finalTerm.size() > 0 ? String.valueOf((finalTerm[0].Loan_Amount__c == null || finalTerm[0].Loan_Amount__c == '0') ? String.valueOf(vehicleList[0].Loan_Amount__c) : finalTerm[0].Loan_Amount__c) : String.valueOf(vehicleList[0].Loan_Amount__c) : String.valueOf(opportunityObj.Required_Loan_amount__c);
                    finalTermDetailsObj.productTypestr = opportunityObj.Product_Type__c;
                    finalTermDetailsObj.dedupeSubmitted = opportunityObj.Is_Customer_Dedupe_Submit__c;
                    finalTermDetailsObj.applicationType = opportunityObj.Application_Type__c;
                    finalTermDetailsObj.vehicleSubCategoryStr = opportunityObj.Product_Type__c == System.Label.Tractor ? finalTerm.size() > 0 ? finalTerm[0].Vehicle_Detail__r.Vehicle_SubCategory__c : vehicleList[0].Vehicle_SubCategory__c : opportunityObj.Vehicle_Sub_Category__c;
                    finalTermDetailsObj.requiredCrmIRR = opportunityObj.Product_Type__c == System.Label.Tractor && vehicleList.size() > 0 ? vehicleList[0].Required_CRM_IRR__c : null;
                    finalTermDetailsObj.vehicleTypeStr = opportunityObj.Vehicle_Type__c;
                    finalTermDetailsObj.vehicleDeliveredStr = opportunityObj.Product_Type__c == System.Label.Tractor ? finalTerm.size() > 0 ? finalTerm[0].Vehicle_Detail__r.Vehicle_Delivered__c : vehicleList[0].Vehicle_Delivered__c : '';
                    finalTermDetailsObj.name = opportunityObj.Name;
                    finalTermDetailsObj.OEMDealer = opportunityObj.OEM_Dealer_Checkbox__c;
                    finalTermDetailsObj.requiredTenure = opportunityObj.Product_Type__c == System.Label.Tractor ? finalTerm.size() > 0 ? Decimal.valueof((finalTerm[0].Tenure__c == null || finalTerm[0].Tenure__c == '0') ? String.valueof(vehicleList[0].Required_Tenure__c) : finalTerm[0].Tenure__c) : vehicleList[0].Required_Tenure__c : opportunityObj.Required_Tenure__c;
                    finalTermDetailsObj.exShowroom=opportunityObj.Product_Type__c == System.Label.Tractor ? 0 : opportunityObj.Ex_showroom_price__c;//CISP-3785
                    finalTermDetailsObj.ORP=opportunityObj.Product_Type__c == System.Label.Tractor ? 0 : opportunityObj.On_Road_price__c;//CISP-3785
                    
                    List<Vehicle_Detail__c> vechicalList = new List<Vehicle_Detail__c>();
                    for(Vehicle_Detail__c vehicleDetailsObj : opportunityObj.Vehicle_Details__r) {
                        finalTermDetails.put('vehicleDetails',vehicleDetailsObj);
                        vechicalList.add(vehicleDetailsObj);
                    }
                    finalTermDetailsObj.vechicalDetailLst = vechicalList;
                    if(Test.isRunningTest())
                    {
                        throw new AuraHandledException(System.Label.ExceptionMessage);
                    }
                }
                return finalTermDetailsObj;
            }
            return null;
        }
        //Catch block 
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller' , 'getFinalTermFieldValidationDetails', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }   
    
    
    
    
    /*
* @Method:      runEligibilityEngine
* @Created by:  Ruchi Jain
* @Description: This method is use to give the response according to elegibility conditions
* @Param:       String - current Applicant ID
String - scheme record id
* @Return:      String - Serialized JSON response
*/
    @AuraEnabled
    public static String runEligibilityEngine(String loanApplicationId){
        try {
            String borrowerApplicant;
            String coborrowerApplicant;
            Opportunity opp=[select id,CreatedDate  from Opportunity where Id=: loanApplicationId WITH SECURITY_ENFORCED];
            List<Applicant__c> app=[select id,Loan_Amount__c,Applicant_Type__c  from Applicant__c where Id=: loanApplicationId WITH SECURITY_ENFORCED];
            for (Applicant__c currentapp : app) {
                if(currentapp.Applicant_Type__c=='Borrower'){
                    borrowerApplicant=currentapp.id ;
                }else{
                    coborrowerApplicant=currentapp.id ;
                }
            }
            Vehicle_Detail__c vehicleObject=[select Eligible_Loan_Amount__c  from Vehicle_Detail__c where Loan_Application__c =:loanApplicationId  WITH SECURITY_ENFORCED];
            //Need to check for analysis report received,c.	If the analysis report received=False, call the method callIncomeSourceAPI
            //then Call the method callFIWaiverEngine
            return borrowerApplicant;
            //g.	Call the method callOfferEngine by pass the response from LTV and Pricing engine
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' checkSchemeEligibility ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
            
        }
    }
    
    @AuraEnabled
    public static string retryCountUpdate(Integer counter,String loanApplicationId){
        try {
            List<Retry_Count__c> retryAttemptRecord=[Select Id,Loan_Application_Id__c,Count__c,Service_Name__c from Retry_Count__c where Service_Name__c='FinalTermsEligiblitycheck' and User_Id__c=:UserInfo.getUserId() and Loan_Application_Id__c=: loanApplicationId]; 
            List<Retry_Count__c>  retObj = new List<Retry_Count__c>();
            if(retryAttemptRecord.size()>0 ){
                for(Retry_Count__c rC:retryAttemptRecord){
                    rC.Count__c=counter;
                    retObj.add(rC);
                }
                update retObj;
                return 'Success';
            }
            else{
                Retry_Count__c newRec = new Retry_Count__c(Loan_Application_Id__c=loanApplicationId,Count__c=counter,Service_Name__c='FinalTermsEligiblitycheck',User_Id__c=UserInfo.getUserId()); 
                retObj.add(newRec);
                insert retObj;
                return 'Success';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static Map<String,Object> getAPIEligibityCount(String loanApplicationId){
        try {
            Map<String,Object> mapOfApiData = new Map<String,Object>();
            List<Retry_Count__c> apiCount=[Select Id,Count__c from Retry_Count__c where Service_Name__c='FinalTermsEligiblitycheck' and Loan_Application_Id__c=:loanApplicationId and User_Id__c=:UserInfo.getUserId()];
            if(apiCount.size()>0){
                if(apiCount[0].Count__c != null ) {
                    mapOfApiData.put('COUNTER',apiCount[0].Count__c);
                } else {
                    mapOfApiData.put('COUNTER',0);
                }
            }
            else{
                mapOfApiData.put('COUNTER',0);
            }
            return mapOfApiData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
* @Method: createFIRecord
* @Created by: Yugandhar
* @Description: This method is used to create Field Investigation record(s)
* @Param: String - current Application ID
*	String - Current Applicant ID
*/
    @AuraEnabled public static void callCreateFI(String loanApplicationId, String parentLeadData){
        if(loanApplicationId != null){
            List<Final_Term__c> finalTermList = [SELECT Id, FIwaiver_offAddress__c, FIwaiver_currentAddress__c, FIwaiver_co_currentAddress__c,FIwaiver_co_offAddress__c,FIwaiver_co_presentAddress__c,
                                                 FIwaiver_presentAddress__c, Loan_Application__r.ID, Loan_Application__r.OwnerId,Loan_Application__r.Name,Loan_Application__r.AccountId, Loan_Application__r.leadsource //D2C added leadsource
                                                 FROM Final_Term__c where Loan_Application__c =: loanApplicationId];//CISP-3022- Added co FIwaiver fields in the query.
                                                  if(!finalTermList.isEmpty() && finalTermList != null){
                String result = IND_GetFinalOfferWithoutSharing.getParentApplicationFiCaseDetails(loanApplicationId);
                if(String.isNotBlank(result)){
                    if(result == 'Existing lead not found' || result == 'FI case not found'){
                        parentLeadData = 'Pre-FI';
                    } else {
                        IND_GetFinalOfferWithoutSharing.parentFICaseWrapper responseWrapper = new IND_GetFinalOfferWithoutSharing.parentFICaseWrapper();        
                        responseWrapper = (IND_GetFinalOfferWithoutSharing.parentFICaseWrapper)system.JSON.deserialize(result, IND_GetFinalOfferWithoutSharing.parentFICaseWrapper.class);
                        if(String.isNotBlank(responseWrapper.parentLoanAppId) && responseWrapper.productType == 'Passenger Vehicles'){
                            if(parentLeadData == 'Yes'){
                                parentLeadData = 'Pre-FI';
                            }else if(parentLeadData == 'No'){
                                parentLeadData = result;
                            }
                        }else if(String.isNotBlank(responseWrapper.parentLoanAppId) && responseWrapper.productType == 'Two Wheeler'){
                            if (responseWrapper.leadType == 'Restart' || responseWrapper.leadType == 'Revoked and Restart') {
                                parentLeadData = 'Pre-FI';
                            } else if (responseWrapper.leadType == 'Revoked') {
                                parentLeadData = result;
                            }
                        }
                    }
                }
            
                for(Applicant__c applicant : [select ID, Name,Opportunity__c,Applicant_Type__c,Is_Address_Declaration__c FROM Applicant__c WHERE Opportunity__c=:loanApplicationId AND In_Active_Applicant__c = false]){//CISP-2701
                    createFIRecord(finalTermList,applicant,parentLeadData);
                }
            }else{
                throw new AuraHandledException('Opps, Final Terms details are not present.');
            }
        }
    }
    
    
    @AuraEnabled
    public static void createFIRecord(List<Final_Term__c> finalTermList,Applicant__c applicant, String parentLeadData){
        Boolean isFiCasesPresent = false;
        String caseRecordType;
        String applicantType = applicant?.Applicant_Type__c;//CISP-3022
        Opportunity loanApplication = finalTermList[0].Loan_Application__r;
        List<Field_Investigation__c> fieldInvestigations = new List<Field_Investigation__c>();
        
        /* RecordType caseRecordType = [SELECT Id FROM RecordType where SobjectType=:CASE_OBJECT AND DeveloperName=:STR_FI];
			List<RecordType> fiRecordTypes = [SELECT Id,DeveloperName FROM RecordType 
			WHERE SobjectType=:FI_OBJECT AND DeveloperName IN :FI_RECORD_TYPES
			ORDER BY DeveloperName];
			Map<String,Id> mapOfRecordTypeToRecordID = new  Map<String,Id> ();
			for(RecordType recordTYpe : fiRecordTypes) {
			mapOfRecordTypeToRecordID.put(recordTYpe.DeveloperName, recordTYpe.Id);
			} 
		*/
        IND_GetFinalOfferWithoutSharing.parentFICaseWrapper responseWrapper = new IND_GetFinalOfferWithoutSharing.parentFICaseWrapper();
        if (parentLeadData!=null && parentLeadData!='Pre-FI') {
            responseWrapper = (IND_GetFinalOfferWithoutSharing.parentFICaseWrapper)system.JSON.deserialize(parentLeadData, IND_GetFinalOfferWithoutSharing.parentFICaseWrapper.class); 
        }
        
        caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get(STR_FI).getRecordTypeId();  // added by amol lamkhade to avoid Query on Recordtype Object   
        Map<String,Schema.RecordTypeInfo> fiRecordTypes =  Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName();//added by amol lamkhade to avoid Query on Recordtype Object           
        Map<String,Id> mapOfRecordTypeToRecordID = new  Map<String,Id> ();
        for(String recordTYpe : fiRecordTypes.keySet()) {
            mapOfRecordTypeToRecordID.put(fiRecordTypes.get(recordTYpe).getDeveloperName(), fiRecordTypes.get(recordTYpe).getRecordTypeId());
        }
        
        
        isFiCasesPresent = Utilities.isFiCasesAvailable(loanApplication.Id,applicant.Id ); 
        // CISP-2701-START
        Boolean isAddressDeclaration = false;
        if(applicant.Is_Address_Declaration__c){
                isAddressDeclaration = true;
        }
        system.debug(' isAddressDeclaration'+ isAddressDeclaration);
        //CISP-2701-END
        system.debug(' isFiCasesPresent'+ isFiCasesPresent);
        
        
        system.debug('finalTermList[0].FIwaiver_offAddress__c::'+finalTermList[0].FIwaiver_offAddress__c);
    if(applicantType == System.Label.Borrower){//CISP-3022
        if(finalTermList[0].FIwaiver_offAddress__c == NOT_WAIVED && !isFiCasesPresent && ((parentLeadData =='Pre-FI') || (String.isBlank(responseWrapper.bo_CaseOffStatus)) || (String.isNotBlank(responseWrapper.bo_CaseOffStatus) && responseWrapper.bo_CaseOffStatus =='Not completed'))) {
            system.debug('Inside the office FI');
            // Applicant__c app= [SELECT Id ,Declared_income__c from Applicant__c where Id=: applicant.Id];
            //Query on Income Detail objects and get the Primary Income Source data and set that as Office FI address. ’Primary Income Source’ is a Boolean field on the ‘Income Details’ object.
            List<Income_Details__c> incomeDetails = [SELECT Id,Is_Self_Employed__c,Income__c, Primary_Income_Source__c, Profile__c, Profile__r.Name,Profile__r.Sub_Bucket_Desc__c,
                                                     Office_Address_Line_1__c, Office_Address_Line_2__c, Office_City__c,Profile__r.Category__c,
                                                     Office_PinCode__c, Office_State__c, Office_District__c,Employer_Business_Name__c,
                                                     Current_Years_in_employment_business__c,Total_Years_in_employment_business__c
                                                     FROM Income_Details__c 
                                                     where Primary_Income_Source__c= true AND  Applicant__c = :applicant.Id];
            system.debug('incomeDetails::'+incomeDetails);
            if(!incomeDetails.isEmpty()){

                Case caseObj = populateCase(caseRecordType, OFFICE_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant);
                insert caseObj;

                Field_Investigation__c fieldInvestigation = new Field_Investigation__c();
                fieldInvestigation.Case__c = caseObj.Id;
                fieldInvestigation.RecordTypeId = mapOfRecordTypeToRecordID.get('Office');
                if(!incomeDetails.isEmpty()) {
                    fieldInvestigation.Address_Line_1__c = incomeDetails[0].Office_Address_Line_1__c; 
                    if(String.isBlank(incomeDetails[0].Office_Address_Line_2__c)){
                        fieldInvestigation.Address_Line_2__c = incomeDetails[0].Office_Address_Line_1__c;
                    }else{
                    fieldInvestigation.Address_Line_2__c = incomeDetails[0].Office_Address_Line_2__c;
                } 
                    fieldInvestigation.City__c = incomeDetails[0].Office_City__c;
                    fieldInvestigation.Pin_Code__c = incomeDetails[0].Office_PinCode__c;
                    fieldInvestigation.State__c = incomeDetails[0].Office_State__c;
                    fieldInvestigation.Profile__c = incomeDetails[0].Profile__r.Name;
                    fieldInvestigation.Employer_Business_Name__c=incomeDetails[0].Employer_Business_Name__c;
                    fieldInvestigation.Category__c = incomeDetails[0].Profile__r.Category__c; //Populate with Category from Income Details record. Currently the field is not available
                    fieldInvestigation.Total_Experience_Years__c =  incomeDetails[0].Total_Years_in_employment_business__c;
                    fieldInvestigation.Current_experience_years__c =  incomeDetails[0].Current_Years_in_employment_business__c;
                    for(Income_Details__c incomerec: incomeDetails){
                        if(incomerec.Primary_Income_Source__c){
                            system.debug('try '+incomerec.Income__c);
                            fieldInvestigation.Declared_Income_During_Application__c =incomerec.Income__c;
                        }
                        if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='SERVICE ORIENTED'){
                            fieldInvestigation.SENP_Service_oriented_Income__c=incomerec.Income__c;
                        }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='TRANSPORTER'){
                            fieldInvestigation.SENP_Transporter_Income__c=incomerec.Income__c;
                        }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='AGRICULTURE'){
                            fieldInvestigation.SENP_Agriculture_Income__c=incomerec.Income__c;
                        }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='RENTAL INCOME'){
                            fieldInvestigation.SENP_Rental_Income__c=incomerec.Income__c;
                        }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='CONTRACTOR'){
                            fieldInvestigation.SENP_Contractor_Income__c=incomerec.Income__c;
                        }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='OWN SHOP / STORE'){
                            fieldInvestigation.SENP_Own_Shop_Income__c=incomerec.Income__c;
                        }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='PENSION INCOME'){
                            fieldInvestigation.SENP_Pension_Income__c=incomerec.Income__c;
                        }//OWN SHOP / STORE ,,PENSION INCOME
                    }
                }
                fieldInvestigations.add(fieldInvestigation); 
            }           
        }
        
        if((finalTermList[0].FIwaiver_currentAddress__c == NOT_WAIVED || isAddressDeclaration) && !isFiCasesPresent && ((parentLeadData =='Pre-FI') || (String.isBlank(responseWrapper.bo_CaseResiStatus)) || (String.isNotBlank(responseWrapper.bo_CaseResiStatus) && responseWrapper.bo_CaseResiStatus =='Not completed'))) {//CISP-2701
            Case caseObj = populateCase(caseRecordType, CURRENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant);
            insert caseObj;
            List<Documents__c> documentList = new List<Documents__c>();

            if(loanApplication.leadSource == 'D2C') {//D2C changes
                documentList = [SELECT Id,
                    Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                    KYC_Pin_Code__c, KYC_State__c, 
                    Document_Type__c,Applicant__r.Current_Same_As_Permanent__c,
                    Image__c
                    FROM Documents__c
                    WHERE Applicant__c = :applicant.Id AND 
                    Current_Residential_Address_Proof__c=true AND KYC_Address_Line_1__c != null LIMIT 1];
            
            } else {
                documentList = [SELECT Id,
                        Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                        KYC_Pin_Code__c, KYC_State__c, 
                        Document_Type__c,Applicant__r.Current_Same_As_Permanent__c,
                        Image__c
                        FROM Documents__c
                        WHERE Applicant__c = :applicant.Id AND /*Addresss_Type__c IN :CURRENT_PERMANENT_ADDR_LIST*/ 
                        (Current_Residential_Address_Proof__c=true OR Document_Type__c =: System.Label.Address_Declaration) AND KYC_Address_Line_1__c != null LIMIT 1];//CISP-2701//CISP-3099 
 
            }
            
            if(!documentList.isEmpty()) {
                fieldInvestigations.add(populateFIRecord(documentList[0], caseObj.Id, mapOfRecordTypeToRecordID.get('Residence')));
            } else {
                fieldInvestigations.add(populateFIRecord(null, caseObj.Id, mapOfRecordTypeToRecordID.get('Residence')));
            }
        }
        
        if(finalTermList[0].FIwaiver_presentAddress__c == NOT_WAIVED && !isFiCasesPresent && ((parentLeadData =='Pre-FI') || (String.isBlank(responseWrapper.bo_CasePerStatus)) || (String.isNotBlank(responseWrapper.bo_CasePerStatus) && responseWrapper.bo_CasePerStatus =='Not completed'))) {
            Case caseObj = populateCase(caseRecordType, PERMANENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant);
            insert caseObj;
            
            List<Documents__c> documentList = [SELECT Id,
                                               Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                               KYC_Pin_Code__c, KYC_State__c,Applicant__r.Current_Same_As_Permanent__c,
                                               Document_Type__c,
                                               Image__c
                                               FROM Documents__c
                                               WHERE Applicant__c = :applicant.Id AND /*Addresss_Type__c IN :CURRENT_PERMANENT_ADDR_LIST*/ 
                                               (Permanent_Residential_Address_Proof__c=true OR 
                                               (Applicant__r.Current_Same_As_Permanent__c=true AND Current_Residential_Address_Proof__c = true)) AND KYC_Address_Line_1__c != null 
                                                LIMIT 1];//CISP-3099
            
            if(!documentList.isEmpty()) {
                fieldInvestigations.add(populateFIRecord(documentList[0], caseObj.Id, mapOfRecordTypeToRecordID.get('Permanent')));
            } else {
                fieldInvestigations.add(populateFIRecord(null, caseObj.Id, mapOfRecordTypeToRecordID.get('Permanent')));
            }
        }
        
        if(String.isBlank(finalTermList[0].FIwaiver_offAddress__c) &&
           String.isBlank(finalTermList[0].FIwaiver_currentAddress__c) &&
           String.isBlank(finalTermList[0].FIwaiver_presentAddress__c) && !isFiCasesPresent) {
               
               List<Case> caseList = new List<Case>();
               
               if(!isAddressDeclaration && (parentLeadData =='Pre-FI' || (String.isBlank(responseWrapper.bo_CaseResiStatus) || (String.isNotBlank(responseWrapper.bo_CaseResiStatus) && responseWrapper.bo_CaseResiStatus !='Completed')))){caseList.add(populateCase(caseRecordType, CURRENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant));}//CISP-3022
               if(parentLeadData =='Pre-FI' || (String.isBlank(responseWrapper.bo_CaseOffStatus) || (String.isNotBlank(responseWrapper.bo_CaseOffStatus) && responseWrapper.bo_CaseOffStatus !='Completed'))){caseList.add(populateCase(caseRecordType, OFFICE_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant));}
               if(parentLeadData =='Pre-FI' || (String.isBlank(responseWrapper.bo_CasePerStatus) || (String.isNotBlank(responseWrapper.bo_CasePerStatus) && responseWrapper.bo_CasePerStatus !='Completed'))){caseList.add(populateCase(caseRecordType, PERMANENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant));}
               insert caseList;
               
               List<Documents__c> documentList = [SELECT Id,
                                                  Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                                  KYC_Pin_Code__c, KYC_State__c, Permanent_Residential_Address_Proof__c,
                                                  Current_Residential_Address_Proof__c,
                                                  Document_Type__c,
                                                  Image__c
                                                  FROM Documents__c
                                                  WHERE Applicant__c = :applicant.Id AND Addresss_Type__c IN :CURRENT_PERMANENT_ADDR_LIST AND KYC_Address_Line_1__c != null LIMIT 1];//CISP-3099 
               
               Documents__c doc = null;
               if(!documentList.isEmpty()) {
                   doc = documentList[0];
               }
               for(Integer i=0; i<caseList.size(); i++) {
                   if(caseList[i].Type == CURRENT_FI && !isAddressDeclaration) {//CISP-3022
                       fieldInvestigations.add(populateFIRecord(doc, caseList[i].Id, mapOfRecordTypeToRecordID.get('Residence')));
                   } else if(caseList[i].Type == OFFICE_FI) {
                       
                       fieldInvestigations.add(populateOfficeFIRecord(doc, caseList[i].Id, mapOfRecordTypeToRecordID.get('Office'),applicant));
                   }
                   else if(caseList[i].Type == PERMANENT_FI) {
                       fieldInvestigations.add(populateFIRecord(doc, caseList[i].Id, mapOfRecordTypeToRecordID.get('Permanent')));
                   }
               }
           }
        
    }//CISP-3022-START
        if(applicantType == System.Label.CoBorrower){
            if(finalTermList[0].FIwaiver_co_offAddress__c == NOT_WAIVED && !isFiCasesPresent && ((parentLeadData =='Pre-FI') || (String.isBlank(responseWrapper.CB_CaseOffStatus)) || (String.isNotBlank(responseWrapper.CB_CaseOffStatus) && responseWrapper.CB_CaseOffStatus =='Not completed'))) {
                system.debug('Inside the office FI');
                // Applicant__c app= [SELECT Id ,Declared_income__c from Applicant__c where Id=: applicant.Id];
                //Query on Income Detail objects and get the Primary Income Source data and set that as Office FI address. ’Primary Income Source’ is a Boolean field on the ‘Income Details’ object.
                List<Income_Details__c> incomeDetails = [SELECT Id,Is_Self_Employed__c,Income__c, Primary_Income_Source__c, Profile__c, Profile__r.Name,Profile__r.Sub_Bucket_Desc__c,
                                                        Office_Address_Line_1__c, Office_Address_Line_2__c, Office_City__c,Profile__r.Category__c,
                                                        Office_PinCode__c, Office_State__c, Office_District__c,Employer_Business_Name__c,
                                                        Current_Years_in_employment_business__c,Total_Years_in_employment_business__c
                                                        FROM Income_Details__c  
                                                        where Primary_Income_Source__c= true AND  Applicant__c = :applicant.Id];
                system.debug('incomeDetails::'+incomeDetails);
                if(!incomeDetails.isEmpty()){
    
                    Case caseObj = populateCase(caseRecordType, OFFICE_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant);
                    insert caseObj;
    
                    Field_Investigation__c fieldInvestigation = new Field_Investigation__c();
                    fieldInvestigation.Case__c = caseObj.Id;
                    fieldInvestigation.RecordTypeId = mapOfRecordTypeToRecordID.get('Office');
                    if(!incomeDetails.isEmpty()) {
                        fieldInvestigation.Address_Line_1__c = incomeDetails[0].Office_Address_Line_1__c;
                        if(String.isBlank(incomeDetails[0].Office_Address_Line_2__c)){ 
                            fieldInvestigation.Address_Line_2__c = incomeDetails[0].Office_Address_Line_1__c;
                        }else{
                        fieldInvestigation.Address_Line_2__c = incomeDetails[0].Office_Address_Line_2__c;
                    } 
                        fieldInvestigation.City__c = incomeDetails[0].Office_City__c;
                        fieldInvestigation.Pin_Code__c = incomeDetails[0].Office_PinCode__c;
                        fieldInvestigation.State__c = incomeDetails[0].Office_State__c;
                        fieldInvestigation.Profile__c = incomeDetails[0].Profile__r.Name;
                        fieldInvestigation.Employer_Business_Name__c=incomeDetails[0].Employer_Business_Name__c;
                        fieldInvestigation.Category__c = incomeDetails[0].Profile__r.Category__c; //Populate with Category from Income Details record. Currently the field is not available
                        fieldInvestigation.Total_Experience_Years__c =  incomeDetails[0].Total_Years_in_employment_business__c;
                        fieldInvestigation.Current_experience_years__c =  incomeDetails[0].Current_Years_in_employment_business__c;
                        for(Income_Details__c incomerec: incomeDetails){
                            if(incomerec.Primary_Income_Source__c){
                                system.debug('try '+incomerec.Income__c);
                                fieldInvestigation.Declared_Income_During_Application__c =incomerec.Income__c;
                            }
                            if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='SERVICE ORIENTED'){
                                fieldInvestigation.SENP_Service_oriented_Income__c=incomerec.Income__c;
                            }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='TRANSPORTER'){
                                fieldInvestigation.SENP_Transporter_Income__c=incomerec.Income__c;
                            }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='AGRICULTURE'){
                                fieldInvestigation.SENP_Agriculture_Income__c=incomerec.Income__c;
                            }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='RENTAL INCOME'){
                                fieldInvestigation.SENP_Rental_Income__c=incomerec.Income__c;
                            }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='CONTRACTOR'){
                                fieldInvestigation.SENP_Contractor_Income__c=incomerec.Income__c;
                            }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='OWN SHOP / STORE'){
                                fieldInvestigation.SENP_Own_Shop_Income__c=incomerec.Income__c;
                            }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='PENSION INCOME'){
                                fieldInvestigation.SENP_Pension_Income__c=incomerec.Income__c;
                            }//OWN SHOP / STORE ,,PENSION INCOME
                        }
                    }
                    fieldInvestigations.add(fieldInvestigation); 
                }           
            }
            
            if((finalTermList[0].FIwaiver_co_currentAddress__c == NOT_WAIVED || isAddressDeclaration) && !isFiCasesPresent && ((parentLeadData =='Pre-FI') || (String.isBlank(responseWrapper.CB_CaseResiStatus)) || (String.isNotBlank(responseWrapper.CB_CaseResiStatus) && responseWrapper.CB_CaseResiStatus =='Not completed'))) {//CISP-2701
                Case caseObj = populateCase(caseRecordType, CURRENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant);
                insert caseObj;
                
                List<Documents__c> documentList = [SELECT Id,
                                                   Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                                   KYC_Pin_Code__c, KYC_State__c, 
                                                   Document_Type__c,Applicant__r.Current_Same_As_Permanent__c,
                                                   Image__c
                                                   FROM Documents__c
                                                   WHERE Applicant__c = :applicant.Id AND /*Addresss_Type__c IN :CURRENT_PERMANENT_ADDR_LIST*/ 
                                                   
                (Current_Residential_Address_Proof__c=true OR Document_Type__c =: System.Label.Address_Declaration) AND KYC_Address_Line_1__c != null LIMIT 1];//CISP-2701//CISP-3099  
                if(!documentList.isEmpty()) {
                    fieldInvestigations.add(populateFIRecord(documentList[0], caseObj.Id, mapOfRecordTypeToRecordID.get('Residence')));
                } else {
                    fieldInvestigations.add(populateFIRecord(null, caseObj.Id, mapOfRecordTypeToRecordID.get('Residence')));
                }
            }
            
            if(finalTermList[0].FIwaiver_co_presentAddress__c == NOT_WAIVED && !isFiCasesPresent && ((parentLeadData =='Pre-FI') || (String.isBlank(responseWrapper.CB_CasePerStatus)) || (String.isNotBlank(responseWrapper.CB_CasePerStatus) && responseWrapper.CB_CasePerStatus =='Not completed'))) {
                Case caseObj = populateCase(caseRecordType, PERMANENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant);
                insert caseObj;
                
                List<Documents__c> documentList = [SELECT Id,
                                                   Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                                   KYC_Pin_Code__c, KYC_State__c,Applicant__r.Current_Same_As_Permanent__c,
                                                   Document_Type__c,
                                                   Image__c
                                                   FROM Documents__c
                                                   WHERE Applicant__c = :applicant.Id AND /*Addresss_Type__c IN :CURRENT_PERMANENT_ADDR_LIST*/ 
                                                   (Permanent_Residential_Address_Proof__c=true OR 
                                                   (Applicant__r.Current_Same_As_Permanent__c=true AND Current_Residential_Address_Proof__c = true)) AND KYC_Address_Line_1__c != null 
                                                    LIMIT 1];//CISP-3099
                
                if(!documentList.isEmpty()) {
                    fieldInvestigations.add(populateFIRecord(documentList[0], caseObj.Id, mapOfRecordTypeToRecordID.get('Permanent')));
                } else {
                    fieldInvestigations.add(populateFIRecord(null, caseObj.Id, mapOfRecordTypeToRecordID.get('Permanent')));
                }
            }
            
            if(String.isBlank(finalTermList[0].FIwaiver_co_offAddress__c) &&
               String.isBlank(finalTermList[0].FIwaiver_co_currentAddress__c) &&
               String.isBlank(finalTermList[0].FIwaiver_co_presentAddress__c) && !isFiCasesPresent) {
                   
                   List<Case> caseList = new List<Case>();
                   
                   if(!isAddressDeclaration && (parentLeadData =='Pre-FI' || (String.isBlank(responseWrapper.CB_CaseResiStatus) || (String.isNotBlank(responseWrapper.CB_CaseResiStatus) && responseWrapper.CB_CaseResiStatus !='Completed')))){caseList.add(populateCase(caseRecordType, CURRENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant));}//CISP-3022
                   if(parentLeadData =='Pre-FI' || (String.isBlank(responseWrapper.CB_CaseOffStatus) || (String.isNotBlank(responseWrapper.CB_CaseOffStatus) && responseWrapper.CB_CaseOffStatus !='Completed'))){caseList.add(populateCase(caseRecordType, OFFICE_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant));}
                   if(parentLeadData =='Pre-FI' || (String.isBlank(responseWrapper.CB_CasePerStatus) || (String.isNotBlank(responseWrapper.CB_CasePerStatus) && responseWrapper.CB_CasePerStatus !='Completed'))){caseList.add(populateCase(caseRecordType, PERMANENT_FI, loanApplication, CASE_STATUS_FI_UNASSIGNED, applicant));}
                   insert caseList;
                   
                   List<Documents__c> documentList = [SELECT Id,
                                                      Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                                      KYC_Pin_Code__c, KYC_State__c, Permanent_Residential_Address_Proof__c,
                                                      Current_Residential_Address_Proof__c,
                                                      Document_Type__c,
                                                      Image__c
                                                      FROM Documents__c
                                                      WHERE Applicant__c = :applicant.Id AND Addresss_Type__c IN :CURRENT_PERMANENT_ADDR_LIST AND KYC_Address_Line_1__c != null LIMIT 1];//CISP-3099 
                   
                   Documents__c doc = null;
                   if(!documentList.isEmpty()) {
                       doc = documentList[0];
                   }
                   for(Integer i=0; i<caseList.size(); i++) {
                       if(caseList[i].Type == CURRENT_FI && !isAddressDeclaration) {//CISP-3022
                           fieldInvestigations.add(populateFIRecord(doc, caseList[i].Id, mapOfRecordTypeToRecordID.get('Residence')));
                       } else if(caseList[i].Type == OFFICE_FI) {
                           
                           fieldInvestigations.add(populateOfficeFIRecord(doc, caseList[i].Id, mapOfRecordTypeToRecordID.get('Office'),applicant));
                       }
                       else if(caseList[i].Type == PERMANENT_FI) {
                           fieldInvestigations.add(populateFIRecord(doc, caseList[i].Id, mapOfRecordTypeToRecordID.get('Permanent')));
                       }
                   }
               }
        }
        //CISP-3022-END
        if(!fieldInvestigations.isEmpty()) {
            insert fieldInvestigations;
        }
    }
    
    /*
* @Method: populateFIRecord
* @Created by: Yugandhar
* @Description: This method is used to populate different fields of a Field Investigation record
* @Param: Documents__c - The document record with the address details
*	String - The FI case ID
*	String - Record Type ID of the Field Investigation object based on the type of the FI
*@Return: Field_Investigation__c - The FI record with required fields populated
*/
    public static Field_Investigation__c populateFIRecord(Documents__c doc, String caseId, String recordTypeId) {
        Field_Investigation__c fieldInvestigation = new Field_Investigation__c();
        fieldInvestigation.Case__c = caseId;
        if(doc != null) {
            fieldInvestigation.Address_Line_1__c = doc.KYC_Address_Line_1__c;
            if(String.isBlank(doc.KYC_Address_Line_2__c)){ 
                fieldInvestigation.Address_Line_2__c = doc.KYC_Address_Line_1__c;
            }else{
            fieldInvestigation.Address_Line_2__c = doc.KYC_Address_Line_2__c;
        } 
            fieldInvestigation.City__c = doc.KYC_City__c;
            fieldInvestigation.Pin_Code__c = doc.KYC_Pin_Code__c;
            fieldInvestigation.State__c = doc.KYC_State__c;
        }
        fieldInvestigation.RecordTypeId = recordTypeId;
        return fieldInvestigation;
    }
    
    /*
* @Method: populateOfficeFIRecord
* @Created by: Yugandhar
* @Description: This method is used to populate different fields of a Field Investigation record
* @Param: Documents__c - The document record with the address details
*	String - The FI case ID
*	String - Record Type ID of the Field Investigation object based on the type of the FI
*@Return: Field_Investigation__c - The FI record with required fields populated
*/
    public static Field_Investigation__c populateOfficeFIRecord(Documents__c doc, String caseId, String recordTypeId,Applicant__c applicant) {
        Field_Investigation__c fieldInvestigation = new Field_Investigation__c();
        fieldInvestigation.Case__c = caseId;
        List<Income_Details__c> incomeDetails = [SELECT Id,Employer_Business_Name__c,Total_Years_in_employment_business__c,Current_Years_in_employment_business__c, Primary_Income_Source__c,Income__c,Is_Self_Employed__c, Profile__c, Profile__r.Name,Profile__r.Sub_Bucket_Desc__c,
                                                 Office_Address_Line_1__c, Office_Address_Line_2__c, Office_City__c,Profile__r.Category__c,
                                                 Office_PinCode__c, Office_State__c, Office_District__c,Applicant__r.Opportunity__r.Product_Type__c
                                                 FROM Income_Details__c  
                                                 where Primary_Income_Source__c= true AND Applicant__c = :applicant.Id];
        
        fieldInvestigation.Case__c = caseId;
        fieldInvestigation.RecordTypeId =recordTypeId;
        if(!incomeDetails.isEmpty()) { 
            fieldInvestigation.Address_Line_1__c = incomeDetails[0].Office_Address_Line_1__c; 
            if(String.isBlank(incomeDetails[0].Office_Address_Line_2__c)){
                fieldInvestigation.Address_Line_2__c = incomeDetails[0].Office_Address_Line_1__c;
            }else{
            fieldInvestigation.Address_Line_2__c = incomeDetails[0].Office_Address_Line_2__c;
        } 
            fieldInvestigation.City__c = incomeDetails[0].Office_City__c;
            fieldInvestigation.Pin_Code__c = incomeDetails[0].Office_PinCode__c;
            fieldInvestigation.State__c = incomeDetails[0].Office_State__c;
            fieldInvestigation.Category__c = incomeDetails[0].Profile__r.Category__c;
            fieldInvestigation.Product__c =incomeDetails[0].Applicant__r.Opportunity__r.Product_Type__c;
            fieldInvestigation.Profile__c = incomeDetails[0].Profile__r.Name;
            fieldInvestigation.Employer_Business_Name__c=incomeDetails[0].Employer_Business_Name__c;
            fieldInvestigation.Total_Experience_Years__c =  incomeDetails[0].Total_Years_in_employment_business__c;
            fieldInvestigation.Current_experience_years__c =  incomeDetails[0].Current_Years_in_employment_business__c;
            
            for(Income_Details__c incomerec: incomeDetails){
                if(incomerec.Primary_Income_Source__c){
                    system.debug('try '+incomerec.Income__c);
                    fieldInvestigation.Declared_Income_During_Application__c =incomerec.Income__c;
                }
                if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='SERVICE ORIENTED'){
                    fieldInvestigation.SENP_Service_oriented_Income__c=incomerec.Income__c;
                }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='TRANSPORTER'){
                    fieldInvestigation.SENP_Transporter_Income__c=incomerec.Income__c;
                }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='AGRICULTURE'){
                    fieldInvestigation.SENP_Agriculture_Income__c=incomerec.Income__c;
                }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='RENTAL INCOME'){
                    fieldInvestigation.SENP_Rental_Income__c=incomerec.Income__c;
                }else if(incomerec.Is_Self_Employed__c && incomerec.Profile__r.Sub_Bucket_Desc__c=='CONTRACTOR'){
                    fieldInvestigation.SENP_Contractor_Income__c=incomerec.Income__c;
                }
            }
            
        }
        return fieldInvestigation;
    }
    
    /*
* @Method: populateCase
* @Created by: Yugandhar
* @Description: This method is used to different fields of a Case record
* @Param: String - Record Type ID of the Case for FI
*	String - Case Type (Either CUrrentt, Permanent of Office FI)
*	String - Owner ID - Owner ID of the application which has to be set as the Owner ID of case
*	String - Status of the Case - Initially it will be FI-Unassigned
*@Return: Case - The Case record with required fields populated
*/
    public static Case populateCase(String recordTypeId, String caseType, Opportunity loanApplication, 
                                    String status, Applicant__c applicant) {
                                        Case caseObj = new Case();
                                        caseObj.RecordTypeId = recordTypeId;
                                        caseObj.Type = caseType;
                                        caseObj.OwnerId = loanApplication.OwnerId;
                                        caseObj.Loan_Application__c = loanApplication.Id;
                                        caseObj.Status = status;
                                        caseObj.Subject = loanApplication.Name +'_'+ caseType +'_'+ applicant.Applicant_Type__c;
                                        caseObj.Applicant__c = applicant.ID;
                                        caseObj.AccountId = loanApplication.AccountId;
                                        return caseObj;
                                    }
    
    // Added by aditya
    @AuraEnabled(continuation= true)
    public static String checkRetryExhaustedForResendSMS(String loanApplicationId){
        
        try{
            
            Retry_Count__c retryCount = new Retry_Count__c();
            List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
            retryCountList = [select Id, Loan_Application_Id__c,Applicant__c,Count__c from Retry_Count__c  where Loan_Application_Id__c =: loanApplicationId AND Service_Name__c = 'SMS' WITH SECURITY_ENFORCED];
            if(retryCountList.isEmpty()) {
                retryCount.Loan_Application_Id__c = loanApplicationId;
                retryCount.Service_Name__c = 'SMS';
                retryCount.Count__c = 1;
                if(Schema.sObjectType.Retry_Count__c.isCreateable())
                {
                    insert retryCount;
                }
                
            }else{
                System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('ResendSMS'); 
                //If number of attempts are greater than predefined number of attempts.
                Retry_Count__c  count = retryCountList[0];
                if(count.Count__c >= metadata.Number_Of_Attempts__c)
                { 
                    String serializedResponse =  System.Label.Retry_Exhausted;
                    return serializedResponse;
                }
                count.Count__c += 1;
                update count;
            }
            
            String serializedResponse = '';
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return serializedResponse; 
            
        }catch(Exception e){
            throw new AuraHandledException(System.Label.ExceptionMessage); 
        }
        
    }
    
    @AuraEnabled(continuation= true)
    public static void retryCountIncreaseForResendSMS(){
        try{
            list<Retry_Count__c>  lst_count = [select Count__c from Retry_Count__c where Service_Name__c = 'SMS' and Module__c = 'ApplicationForm'  WITH SECURITY_ENFORCED];
            Retry_Count__c retryCount = new Retry_Count__c();
            if(lst_count.isEmpty()){
                retryCount.Module__c = 'ApplicationForm';
                retryCount.Service_Name__c = 'SMS';
                retryCount.Count__c = 1;
                if(Schema.sObjectType.Retry_Count__c.isCreateable())
                {
                    insert retryCount;
                }  
            }else{
                Retry_Count__c  count = new Retry_Count__c();
                count = lst_count[0];
                count.Count__c += 1;
                if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                    update count;
                } 
            }
            
        }
        //Catch block 
        catch(Exception e){
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    //
    @AuraEnabled(continuation= true)
    public static list<Applicant__c> ResendSMS(Id loanId){
        list<Applicant__c> lst_applicant  = new List<Applicant__c>();
        try{
            Opportunity  opty = [SELECT Id,Product_Type__c,Customer_Type__c,Entity_Type__c FROM Opportunity WHERE Id =:loanId];
            if(opty != null && opty.Product_Type__c == Label.Tractor && opty.Customer_Type__c == 'Non-Individual' && opty.Entity_Type__c == 'Proprietorship'){
                for(Applicant__c applicant : [select id,Name,Opportunity__c, Application_Consent_OTP__c,Application_Form_SMS_Sent__c from Applicant__c where Opportunity__r.Id = :loanId and In_Active_Applicant__c =false AND ((Applicant_Type__c = 'Borrower') OR (Applicant_Type__c = 'Beneficiary' AND IsPrimary__c = true))]){
                    applicant.Application_Consent_OTP__c = string.valueOf(Utilities.generateUniqueNumber(5));
                    if(applicant.Application_Form_SMS_Sent__c ==null)
                        applicant.Application_Form_SMS_Sent__c =datetime.now();
                    lst_applicant.add(applicant);
                }
            }else if(opty != null && opty.Product_Type__c == Label.Tractor && opty.Customer_Type__c == 'Non-Individual'){
                for(Applicant__c applicant : [select id,Name,Opportunity__c, Application_Consent_OTP__c,Application_Form_SMS_Sent__c from Applicant__c where Opportunity__r.Id = :loanId and In_Active_Applicant__c =false AND Applicant_Type__c = 'Beneficiary' AND IsPrimary__c = true]){
                    applicant.Application_Consent_OTP__c = string.valueOf(Utilities.generateUniqueNumber(5));
                    if(applicant.Application_Form_SMS_Sent__c ==null)
                        applicant.Application_Form_SMS_Sent__c =datetime.now();
                    lst_applicant.add(applicant);
                }
            }else{
            for(Applicant__c applicant : [select id,Name,Opportunity__c, Application_Consent_OTP__c,Application_Form_SMS_Sent__c from Applicant__c where Opportunity__r.Id = :loanId and In_Active_Applicant__c =false])
            {
                applicant.Application_Consent_OTP__c = string.valueOf(Utilities.generateUniqueNumber(5));
                if(applicant.Application_Form_SMS_Sent__c ==null)
                    applicant.Application_Form_SMS_Sent__c =datetime.now();
                lst_applicant.add(applicant);
            }
            }
            if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                update lst_applicant;
            }
        }catch (exception e){
            System.debug(e.getCause() + '' + e.getLineNumber() + '' + e.getMessage());
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'ResendSMS', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        
        return lst_applicant;
    }
    
    /* @Method: createCase off roll employee approval
* @Created by: Anup's Team
* @Description: This method is used to crea Case record for off roll employee Approval
*   String - Owner ID - Owner ID of the application which has to be set as the Owner ID of case
*	String - Status of the Case - Initially it will be Pending-Off Role Employee App
*@Return: Case - The Case record with required fields populated

@AuraEnabled(continuation= true)
public static string createCase(string loappid,string producttype){
boolean f1;
boolean f2;
// checking user is IBL employee or not
Id uid = UserInfo.getUserId();
List<User> objUser = [SELECT Id,Name,CompanyName FROM User WHERE Id = :uid limit 1];
if(string.isNotBlank(objUser[0].CompanyName) && objUser[0].CompanyName !=System.Label.IBL){
f1 = true;
}
// if kyc is not biometric '
List<Documents__c> docList =[select Id,Aadhar_Source__c from Documents__c
where Opportunity_Relation__c =:loappid and Document_Type__c=: System.Label.AadhaarCard limit 1];
if(docList[0].Aadhar_Source__c != System.Label.Biometric ){
f2 = true;
}

// String offRoleEmpRecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Off_role_Emp_Approval').getRecordTypeId();

// recordType rt = [SELECT Id,name,developerName from recordtype where developerName='Off_role_Emp_Approval' limit 1];
List<user> beUser = [select id, name from user where name =: System.Label.Business_Executive limit 1];

if(f1 == true && f2 == true){

// create a case and assasign it to user //Business Executive  
case cs = new case();
cs.Loan_Application__c = loappid;
cs.OwnerId = beUser[0].Id;
//  cs.RecordTypeId =offRoleEmpRecordTypeID; 
cs.Subject=System.Label.Approval_Of_Application;
cs.Status = System.Label.Pending_Off_Role; 
cs.Origin = System.Label.Web;
if(Schema.sObjectType.Retry_Count__c.isCreateable()){
insert cs;
} 

return cs.Id;
}
return 'not entered';
}    
*/
    @AuraEnabled
    public static List<Opportunity>  fetchProductType(Id loanAppId){
        try{
            //CISP-4181 added Is_Revoked__c in fields to query
            //CISP-12424 added sub query to fetch Applicants
            //OLA-209 added sub query to get Customer Code from Applicant
            List<Opportunity> oppList = [select isTopUpLoan__c,Product_Type__c, LastStageName__c, StageName,Vehicle_Type__c,LeadSource, Is_Revoked__c,Owner.Id,Owner.Name,Loan_amount__c, (SELECT Customer_Code__c FROM Applicants__r WHERE Applicant_Type__c = 'Borrower') from Opportunity where id=:loanAppId];
            return oppList;
        }catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller', 'fetchProductType ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static string getUserInfo(String recordId){
        try {
            Opportunity opp = [Select Id,OwnerId,Owner.UserRole.Name,AccountId from Opportunity where Id =:recordId  WITH SECURITY_ENFORCED Limit 1 ];
            AccountTeamMember teamMember = [Select AccountId,userId,TeamMemberRole
                                            From AccountTeamMember
                                            Where userId = :opp.OwnerId
                                            AND AccountId = :opp.AccountId WITH SECURITY_ENFORCED
                                            Limit 1  ];
            return teamMember.TeamMemberRole;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/*
* @Method: checkIES
* @Created by: Abhishek
* @Description: This method is used to get Loan Payer Name
* @Param: String - loanApplicationId
*@Return: String - loan payer Name
*/
   @AuraEnabled
    public static Boolean checkIES(String loanApplicationId){
        try {
            String whowillrepayloan = '';
            Map<String,Applicant__c> ApplicantMap = new Map<String,Applicant__c>();
            for(Applicant__c applicant : [SELECT Id,Applicant_Type__c,Would_you_like_to_open_a_bank_account__c,Who_will_repay_the_loan__c FROM Applicant__c WHERE Opportunity__c = :loanApplicationId AND Opportunity__r.Product_Type__c IN ('Two Wheeler','Passenger Vehicles') WITH SECURITY_ENFORCED]) {
                ApplicantMap.put(applicant.Applicant_Type__c,applicant);
                if(applicant.Who_will_repay_the_loan__c != null)
                    whowillrepayloan = applicant.Who_will_repay_the_loan__c;
                if(String.isNotBlank(whowillrepayloan) && ApplicantMap.containsKey(whowillrepayloan) && ApplicantMap.get(whowillrepayloan).Would_you_like_to_open_a_bank_account__c == true)
                    return true;
            }
            return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'checkIES', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
* @Method: getbenefitioryDetails
* @Created by: Rohan Saxena
* @Description: This method is used to get benefic__c object records CISP-4784
* @Param: String - loanApplicationId
*@Return: List<benefic__c>
*/
   @AuraEnabled
   public static List<Benefi__c> getbenefitioryDetails(String loanApplicationId){
       try {
        List<Vehicle_Detail__c> vehicledetails = [SELECT Ben_Code__c FROM Vehicle_Detail__c
        WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];

        List<Benefi__c> ben = [SELECT Id,Dealership_Nature__c FROM Benefi__c WHERE Ben_code__c =: vehicledetails[0].Ben_Code__c WITH SECURITY_ENFORCED LIMIT 1];   
        return ben;       
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'checkIES', System.Label.Apex, e);
           throw new AuraHandledException(e.getMessage());
       }
   }

   @AuraEnabled
   public static Map<String, String> getRepaymentModePickListValue(String loanApplicationId){
       try {
        Applicant__c applicantDetails = new Applicant__c();
        List<Applicant__c> applicantList = new List<Applicant__c>([SELECT Id, Name, Applicant_Type__c,Who_will_repay_the_loan__c,Repayment_Will_Be_Done_By__c,Would_you_like_to_open_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Do_you_have_a_bank_account__c,Opportunity__r.LeadSource,Opportunity__r.Product_Type__c  FROM Applicant__c WHERE Opportunity__c = :loanApplicationId  AND In_Active_Applicant__c = false ORDER BY Applicant_Type__c ASC]);

        Boolean isD2CLead = false;
        Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c>();
        Boolean isTractor = false;
        for(Applicant__c applicant : applicantList){
            if(applicant.Opportunity__r.LeadSource == 'D2C'){
                isD2CLead = true;
                break;
            }
            if(!applicantMap.containsKey(applicant.Applicant_Type__c)){
                applicantMap.put(applicant.Applicant_Type__c,applicant);
            }
            if(applicant.Opportunity__r.Product_Type__c == System.Label.Tractor){
                isTractor = true;
                // break;
            }
        }
        if(isTractor == true){
            return FinalTermscontroller.getRepaymentModePickListValueTractor(applicantList);
        }
        if(isD2CLead == true){
            return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'SI','e-NACH'});
        }
        String willingValue = '';
        if(applicantMap.containsKey(System.Label.Borrower)){
            willingValue = applicantMap.get(System.Label.Borrower).Who_will_repay_the_loan__c;
        }
        if(applicantMap.containsKey(willingValue)){
            applicantDetails = applicantMap.get(willingValue);
        }
            //CISP-23393 implemented
        if(applicantDetails != null && applicantDetails.Do_you_have_a_bank_account__c && applicantDetails.Do_you_have_a_bank_account_with_IBL__c){          
            return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'SI','ACH','e-NACH'});
        }
        else if(applicantDetails != null && applicantDetails.Do_you_have_a_bank_account__c && applicantDetails.Would_you_like_to_open_a_bank_account__c){
                return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'IES','ACH','e-NACH'});
        }
        else if(applicantDetails != null && applicantDetails.Do_you_have_a_bank_account__c){
            return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'ACH','e-NACH'});
        }
        else if(applicantDetails != null && applicantDetails.Would_you_like_to_open_a_bank_account__c){
                return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'IES','ACH','e-NACH'});
        }


        return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{});

       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'fetchApplicant', System.Label.Apex, e);
           throw new AuraHandledException(e.getMessage());
       }
   }

   @AuraEnabled
   public static Map<String, String> getRepaymentModePickListValueTractor(List<Applicant__c> applicantList){
       try {
        Applicant__c applicantDetails = new Applicant__c();
        
        Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c>();
        String borrowerId = '';
        String loanApplicationId = '';
        for(Applicant__c applicant : applicantList){
            if(!applicantMap.containsKey(applicant.Applicant_Type__c + '_' + applicant.Id)){
                applicantMap.put(applicant.Applicant_Type__c + '_' + applicant.Id,applicant);
            }
            if(applicant.Applicant_Type__c == System.Label.Borrower){
                borrowerId = applicant.Id + '';
            }
            loanApplicationId =  applicant.Opportunity__c;
        }
        String willingValue = '';
        if(applicantMap.containsKey(System.Label.Borrower + '_' + borrowerId)){
            String repayDoneBy = String.isNotBlank(applicantMap.get(System.Label.Borrower + '_' + borrowerId).Repayment_Will_Be_Done_By__c) ? applicantMap.get(System.Label.Borrower + '_' + borrowerId).Repayment_Will_Be_Done_By__c : applicantMap.get(System.Label.Borrower + '_' + borrowerId).Id;
            willingValue = applicantMap.get(System.Label.Borrower + '_' + borrowerId).Who_will_repay_the_loan__c + '_' + repayDoneBy;
        }
        if(applicantMap.containsKey(willingValue)){
            applicantDetails = applicantMap.get(willingValue);
        }

            //CISP-23393 implemented
            if(applicantDetails != null && applicantDetails.Do_you_have_a_bank_account__c && applicantDetails.Do_you_have_a_bank_account_with_IBL__c){          
                return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'SI','ACH','e-NACH'});
            }
            else if(applicantDetails != null && applicantDetails.Do_you_have_a_bank_account__c && applicantDetails.Would_you_like_to_open_a_bank_account__c){
                    return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'IES','ACH','e-NACH'});
            }
            else if(applicantDetails != null && applicantDetails.Do_you_have_a_bank_account__c){
                return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'ACH','e-NACH'});
            }
            else if(applicantDetails != null && applicantDetails.Would_you_like_to_open_a_bank_account__c){
                    return FinalTermscontroller.getRepaymentPicklistValuesMap(new Set<String>{'IES','ACH','e-NACH'});
            } //CISP-23393 - End

        return new Map<String,String>();

       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'fetchApplicant', System.Label.Apex, e);
           throw new AuraHandledException(e.getMessage());
       }
   }

   public static Map<String, String> getRepaymentPicklistValuesMap(Set<String> picklistValueSet){
        Map<String, String> values = new Map<String, String>{};

        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{'Final_Term__c'});
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get('Repayment_mode__c').getDescribe().getPicklistValues()) {
                if (entry.isActive() && picklistValueSet.contains(entry.getLabel())) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        return values;
   }
    //sftrac-84
    @AuraEnabled
    public static List<Vehicle_Detail__c> getVehicleDetails(String loanApplicationId){
        try {
            List<Vehicle_Detail__c> vehicleDetailList = [SELECT Id,Name,Variant__c,Make__c,Model__c,Vehicle_SubType__c,Change_Pay_IN_Pay_OUT__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanApplicationId  WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
            if (!vehicleDetailList.isEmpty()) {
                for (Vehicle_Detail__c vehicleObj : vehicleDetailList) {
                    String variant = '';
                    String makeModelVariant = vehicleObj.Make__c != null ? vehicleObj.Make__c + ' ' : '';
                    makeModelVariant += vehicleObj.Model__c != null ? vehicleObj.Model__c + ' ' : '';
                    makeModelVariant += vehicleObj.Variant__c != null ? vehicleObj.Variant__c + '' : '';
                    variant += makeModelVariant.trim() == '' ? '' : '( ' + makeModelVariant + ' )';
                    vehicleObj.Variant__c = variant;
                }
                return vehicleDetailList;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'getVehicleDetails', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled//sftrac-84
    public static Boolean getFinalTermSuccessApis(String loanApplicationId,Boolean isRetryExhausted){
        try {
            // if(isRetryExhausted==true){
            //     if(loanApplicationId!=null){
            //         Opportunity opp = [SELECT Id,Product_Type__c,(SELECT Id from Vehicle_Details__r),(SELECT Id FROM Final_Terms__r) FROM Opportunity WHERE Id =: loanApplicationId AND Product_Type__c = 'Tractor' WITH SECURITY_ENFORCED LIMIT 1];
            //         if(opp!=null && opp.Vehicle_Details__r != null && opp.Final_Terms__r!=null && opp.Vehicle_Details__r.size()==opp.Final_Terms__r.size()){
            //             return true;
            //         }
            //     }
            //     return false;
            // }else{
                if(loanApplicationId!=null){
                    Opportunity opp = [SELECT Id,Product_Type__c,(SELECT Id from Vehicle_Details__r),(SELECT Id,L1_Final_Terms_Submitted__c FROM Final_Terms__r where L1_Final_Terms_Submitted__c = true) FROM Opportunity WHERE Id =: loanApplicationId AND Product_Type__c = 'Tractor' WITH SECURITY_ENFORCED LIMIT 1];
                    if(opp!=null && opp.Vehicle_Details__r != null && opp.Final_Terms__r!=null && opp.Vehicle_Details__r.size()==opp.Final_Terms__r.size()){
                        return true;
                    }
                }
                return false;
            // }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'getFinalTermSuccessApis', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled//sftrac-84
    public static Boolean isGotoNextScreen(String loanApplicationId){
        try {
            if(loanApplicationId!=null){
                    Opportunity opp = [SELECT Id,Product_Type__c,(SELECT Id from Vehicle_Details__r),(SELECT Id,L2_Final_Terms_Submitted__c FROM Final_Terms__r where L2_Final_Terms_Submitted__c = true) FROM Opportunity WHERE Id =: loanApplicationId AND Product_Type__c = 'Tractor' WITH SECURITY_ENFORCED LIMIT 1];
                    if(opp!=null && opp.Vehicle_Details__r != null && opp.Final_Terms__r!=null && opp.Vehicle_Details__r.size() == opp.Final_Terms__r.size()){
                        return true;
                    }
                }
                return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'isGotoNextScreen', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static Boolean validateAgreementAmount(String finalTermId) {
        try
        {
            if(finalTermId!=null){
                List<Final_Term__c> finalTermList = [SELECT Id, Agreement_Amount__c,Offer_Agreement_Amount__c, Loan_Application__r.Product_Type__c, Vehicle_Detail__r.Base_Prices__c,Loan_Application__r.Vehicle_Type__c FROM Final_Term__c WHERE Id =: finalTermId LIMIT 1];
                if(finalTermList[0].Loan_Application__r.Product_Type__c == 'Tractor'){
                    if((finalTermList.size() > 0 && finalTermList[0].Offer_Agreement_Amount__c != null && finalTermList[0].Offer_Agreement_Amount__c !=0 && finalTermList[0].Vehicle_Detail__r.Base_Prices__c!=null && finalTermList[0].Vehicle_Detail__r.Base_Prices__c!=0 && (finalTermList[0].Offer_Agreement_Amount__c > finalTermList[0].Vehicle_Detail__r.Base_Prices__c)) ){
                        return true;
                	}
                    }else{
                        if((finalTermList.size() > 0 && finalTermList[0].Agreement_Amount__c!= null && finalTermList[0].Agreement_Amount__c!=0 && finalTermList[0].Vehicle_Detail__r.Base_Prices__c!=null && finalTermList[0].Vehicle_Detail__r.Base_Prices__c!=0 && (finalTermList[0].Agreement_Amount__c > finalTermList[0].Vehicle_Detail__r.Base_Prices__c)) || (finalTermList.size() > 0 && finalTermList[0].Loan_Application__r.Vehicle_Type__c == 'New')){
                        return true;
                	}
                }
            }
            return false;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'validateAgreementAmount', System.Label.Apex, e);
        }
        return false;
    }
    @AuraEnabled
    public static Boolean isAllFICasesSubmitted(String loanApplicationId) {
        Boolean isAllFICaseSubmitted = true;
        try
        {
            if(loanApplicationId != null){
                String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                List<Case> caseList = new List<Case>([SELECT Id from Case Where RecordTypeId =: caseRecordType AND Loan_Application__c =: loanApplicationId AND Status != 'Completed' AND Status != 'Accepted']);

                if(caseList.size() > 0){
                    isAllFICaseSubmitted = false;
                }
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'isAllFICasesSubmitted', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return isAllFICaseSubmitted;
    }

   //CISP-21214
   @AuraEnabled
   public static List<Customer_Dedupe_Response__c>  getCustomerCodeStatus(String loanAppId){
       try{
           List<Customer_Dedupe_Response__c> customerDedupeList = [SELECT Id,Dedupe_Journey_Status_Reason__c,IND_isNewCustomer__c FROM Customer_Dedupe_Response__c WHERE Applicant__r.Opportunity__c =: loanAppId AND Applicant__r.Applicant_Type__c = 'Borrower' AND Applicant__r.In_Active_Applicant__c = false];
           if(!customerDedupeList.isEmpty()){
               return customerDedupeList;
           }
           return null;
       }catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('FinalTermscontroller', 'getCustomerCodeStatus ', System.Label.Apex, e, loanAppId);
           throw new AuraHandledException(System.Label.ExceptionMessage);
       }
   } 
}