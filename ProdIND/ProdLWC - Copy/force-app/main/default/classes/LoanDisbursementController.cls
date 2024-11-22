public with sharing class LoanDisbursementController {
    
    @AuraEnabled
    public static Map<string,object> isValidUser(string loanApplicationId){
        try{
            
            Map<string,object> respMap = new Map<string,object>();
            Profile prof = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id = :loanApplicationId];
            if(prof.Name.equals('System Administrator') || prof.Name.equalsIgnoreCase('IBL Support L1') || prof.Name.equalsIgnoreCase('IBL Support L2')){//CISP-3128
                respMap.put('isValid',true);
                respMap.put('profile',prof.Name);
                respMap.put('productType',opp.Product_Type__c);
                return respMap;
            }else{
                if(opp.Product_Type__c.equals('Two Wheeler')){
                    if(prof.Name.contains('CVO')){
                        respMap.put('isValid',true);
                        respMap.put('profile',prof.Name);
                        respMap.put('productType',opp.Product_Type__c);
                        return respMap;
                    }
                }else if(opp.Product_Type__c.equals('Passenger Vehicles')){
                    if(prof.Name.equals('IBL Business Executive') || prof.Name.contains('CVO') || prof.Name.contains('Synergy')){
                        respMap.put('isValid',true);
                        respMap.put('profile',prof.Name);
                        respMap.put('productType',opp.Product_Type__c);
                        return respMap;
                    }
                // SFTRAC-144
                }else if(opp.Product_Type__c == System.Label.Tractor){//SFTRAC-142 - START
                    if(prof.Name.equals('IBL TF Payment Executive') || prof.Name.equals('IBL TF Internal Payment Executive')){
                        respMap.put('isValid',true);
                        respMap.put('profile',prof.Name);
                        respMap.put('productType',opp.Product_Type__c);
                        return respMap;
                    }
                }//SFTRAC-142 - START
                // SFTRAC-144
            }
            respMap.put('isValid',false);
            return respMap;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'isValidUser', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Vehicle_Detail__c getUsedRegAndVehilceDetails(string loanApplicationId, String dealId){
        VehicleWrapper vehicleDetailElement = new VehicleWrapper();
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        if(loanApplicationId!=null){
            List<VehicleWrapper> vehicleInsuranceList = new List<VehicleWrapper>();
            Vehicle_Detail__c vehicleRecord = new Vehicle_Detail__c();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                vehicleRecord = [ SELECT Id, Vehicle_Registration_number__c, Vehicle_type__c, Engine_number__c, Chassis_number__c 
                                    FROM Vehicle_Detail__c 
                                    WHERE Loan_Application__c=:loanApplicationId AND Deal_Number__c =: dealId
                                    WITH SECURITY_ENFORCED limit 1];
            }else{
                vehicleRecord = [ SELECT Id, Vehicle_Registration_number__c, Vehicle_type__c, Engine_number__c, Chassis_number__c 
                                    FROM Vehicle_Detail__c 
                                    WHERE Loan_Application__c=:loanApplicationId 
                                    WITH SECURITY_ENFORCED limit 1];
            }
            return vehicleRecord;
        }
        return null;
           
    }
    @AuraEnabled
    public static List<Applicant__c> getLoanApplicantDetails(string loanApplicationId){
        List<Applicant__c> applicants = [SELECT Id,Applicant_Type__c,Bank_Account_No__c FROM Applicant__c WHERE Opportunity__c = :loanApplicationId ORDER BY CreatedDate DESC];
        if(!applicants.isEmpty()){
            return applicants;
        }
        
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static void inactiveInsuranceApplicationDocument(string loanApplicationId, String dealId){
        List<Documents__c> docs = new List<Documents__c>();
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            docs = [SELECT Id 
                    FROM Documents__c 
                    WHERE Opportunity_Relation__c = :loanApplicationId AND Document_Type__c='Insurance Policy Doc' AND is_Active__c = TRUE AND Vehicle_Detail__c =: VehicleLst[0].Id
                    LIMIT 1];
        }else{
            docs = [SELECT Id 
                    FROM Documents__c 
                    WHERE Opportunity_Relation__c = :loanApplicationId AND Document_Type__c='Insurance Policy Doc' AND is_Active__c = TRUE 
                    LIMIT 1];
        }

        try{
            if(!docs.isEmpty()){
                docs[0].is_Active__c = FALSE;
            }
            update docs;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'inactiveInsuranceApplicationDocument', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }
    }

    @AuraEnabled(cacheable=true)
    public static LoanDisbursementDetails__c getLoanDisbursementDetails(string loanApplicationId){
        return LoanDisbursementController.getLoanDisbursementDetails(loanApplicationId,'');
    }

    @AuraEnabled(cacheable=true)
    public static LoanDisbursementDetails__c getLoanDisbursementDetails(string loanApplicationId,String dealId){
        System.debug(loanApplicationId);
        try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        if(String.isNotBlank(loanApplicationId)){
            List<LoanDisbursementDetails__c> disbursementDetails = new  List<LoanDisbursementDetails__c>();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                disbursementDetails = [SELECT Id,Parent_Loan_Application__c,
                                        Parent_Loan_Application__r.Vehicle_Type__c,Parent_Loan_Application__r.Registration_Number_Format__c,
                                        Parent_Loan_Application__r.Vehicle_Registration_Number__c,Payment_Originated_From__c,
                                        Vehicle_Sold_By__c,Vehicle_Registered_in_Name__c, Business_Sourced_By__c, Business_Sourced_By__r.Id, 
                                        Business_Sourced_By__r.Name,Business_Done_By__c, Business_Done_By__r.Id,Business_Done_By__r.Name,
                                        FI_Done_By__c, FI_Done_By__r.Id, FI_Done_By__r.Name, Collection_Executive__c,
                                        Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, Balance_Transfer_Amount_in_Rs__c,
                                        Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, Original_purchase_date__c, Fund_End_Use__c ,PDAV_Flag__c
                                        FROM LoanDisbursementDetails__c 
                                        WHERE Parent_Loan_Application__c =: loanApplicationId AND Deal_Number__c =: dealId
                                        WITH SECURITY_ENFORCED 
                                        LIMIT 1];
            }else{
            disbursementDetails = [SELECT Id,Parent_Loan_Application__c,
            Parent_Loan_Application__r.Vehicle_Type__c,Parent_Loan_Application__r.Registration_Number_Format__c,Parent_Loan_Application__r.Vehicle_Registration_Number__c,Payment_Originated_From__c,
            Vehicle_Sold_By__c,Vehicle_Registered_in_Name__c, Business_Sourced_By__c, Business_Sourced_By__r.Id, Business_Sourced_By__r.Name,Business_Done_By__c, Business_Done_By__r.Id,Business_Done_By__r.Name,
                FI_Done_By__c, FI_Done_By__r.Id, FI_Done_By__r.Name, Collection_Executive__c,
                Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, Balance_Transfer_Amount_in_Rs__c,
                Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, Original_purchase_date__c, Fund_End_Use__c 
                FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
            }
            if(!disbursementDetails.isEmpty()){
                return disbursementDetails[0];
            }    
        }
        return null;
    }catch(Exception e){
        ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getLoanDisbursementDetails', System.Label.Apex, e);
        throw new AuraHandledException(e.getMessage() + ' - ' + e.getStackTraceString());
    }
    }
    @AuraEnabled
    public static LoanDisbursementDetails__c getLoanDisbursementRecord(string loanApplicationId,String dealId){
        System.debug(loanApplicationId);
        try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        if(loanApplicationId != null){
            List<LoanDisbursementDetails__c> disbursementDetails = new List<LoanDisbursementDetails__c>();

            if(oppRec.Product_Type__c == System.Label.Tractor){
                disbursementDetails = [SELECT Id,Parent_Loan_Application__c,
                                        Parent_Loan_Application__r.Vehicle_Type__c,Parent_Loan_Application__r.Registration_Number_Format__c,
                                        Parent_Loan_Application__r.Vehicle_Registration_Number__c,Payment_Originated_From__c,
                                        Vehicle_Sold_By__c,Vehicle_Registered_in_Name__c, Business_Sourced_By__c, Business_Sourced_By__r.Id, 
                                        Business_Sourced_By__r.Name,Business_Done_By__c, Business_Done_By__r.Id,Business_Done_By__r.Name,
                                        FI_Done_By__c, FI_Done_By__r.Id,FI_Done_By__r.Name, Collection_Executive__c,
                                        Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, Balance_Transfer_Amount_in_Rs__c,
                                        Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, Original_purchase_date__c, Fund_End_Use__c ,PDAV_Flag__c
                                        FROM LoanDisbursementDetails__c 
                                        WHERE Parent_Loan_Application__c =: loanApplicationId AND Deal_Number__c =: dealId
                                        WITH SECURITY_ENFORCED 
                                        LIMIT 1];
            }else{
                disbursementDetails = [SELECT Id,Parent_Loan_Application__c,
                                        Parent_Loan_Application__r.Vehicle_Type__c,Parent_Loan_Application__r.Registration_Number_Format__c,
                                        Parent_Loan_Application__r.Vehicle_Registration_Number__c,Payment_Originated_From__c,
                                        Vehicle_Sold_By__c,Vehicle_Registered_in_Name__c, Business_Sourced_By__c, Business_Sourced_By__r.Id, 
                                        Business_Sourced_By__r.Name,Business_Done_By__c, Business_Done_By__r.Id,Business_Done_By__r.Name,
                                        FI_Done_By__c, FI_Done_By__r.Id,FI_Done_By__r.Name, Collection_Executive__c,
                                        Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, Balance_Transfer_Amount_in_Rs__c,
                                        Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, Original_purchase_date__c, Fund_End_Use__c 
                                        FROM LoanDisbursementDetails__c 
                                        WHERE Parent_Loan_Application__c =: loanApplicationId 
                                        WITH SECURITY_ENFORCED 
                                        LIMIT 1];
            }

            if(!disbursementDetails.isEmpty()){
                return disbursementDetails[0];
            }    
        }
        return null;
    }catch(Exception e){
        ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getLoanDisbursementRecord', System.Label.Apex, e);
        throw new AuraHandledException(e.getMessage() + ' - ' + e.getStackTraceString());
    }
    }
    // start CISP-2984
    @AuraEnabled
    public static Opportunity getVehicleType(string loanApplicationId){
        try{
            if(String.isNotBlank(loanApplicationId)){
                List<Opportunity> vehicleType = [SELECT Id, Vehicle_Type__c,(Select Id,Name From Applicants__r Where Applicant_Type__c =: System.Label.Borrower AND In_Active_Applicant__c = false) FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];//CISP-2983
                if(!vehicleType.isEmpty()){
                    return vehicleType[0];
                }    
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getVehicleType', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }// end CISP-2984
    
    public class VehicleWrapper{
        String vehicletype{get;set;}
        String vehicleReg{get;set;}
        String vehicleengine{get;set;}
        String vehiclechassis{get;set;}
        Boolean isvehicletype {get;set;}
       
    }

    @AuraEnabled
    public static Boolean CheckBalanceTranserFieldAccessbility(String loanApplicationId, String dealId){
        try {
            if(String.isNotBlank(loanApplicationId)) {
                list<Opportunity> oppList= [ SELECT Id,Vehicle_Type__c,Vehicle_Sub_Category__c, Product_Type__c,
                    Ben_Code__c FROM Opportunity WHERE Id =: loanApplicationId  and Vehicle_Type__c != 'New' WITH SECURITY_ENFORCED limit 1];
                if(!oppList.isEmpty()){     
                    Opportunity oppObj = oppList[0]; 
                    if(oppObj.Product_Type__c == System.Label.Tractor) {
                        List<Vehicle_Detail__c> vehicleList = [Select Id,Vehicle_SubCategory__c from Vehicle_Detail__c Where Deal_Number__c =: dealId];
                        if(vehicleList.size() > 0 && (vehicleList[0].Vehicle_SubCategory__c == 'UPB' || vehicleList[0].Vehicle_SubCategory__c == 'UOB')){
                            return true;
                        }
                    }else{
                        if(oppObj.Vehicle_Sub_Category__c.equals('UPB') || oppObj.Vehicle_Sub_Category__c.equals('UOB')){
                            return true;
                        }
                    }
                }
            }
                return false;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'CheckBalanceTranserFieldAccessbility', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }
    }
    /************************************* 
        @Author:  Daksh Mandowara
        @ModifiedDate: 08/04/2022
        @UserStory:  Feature 10.2.1 - Business Payment
    *************************************/
    @AuraEnabled(cacheable=true) 
    public static String getPymntOrigFromDDValues(String loanApplicationId, String dealId){
        System.debug(loanApplicationId);
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartArray();
        try {
            if(String.isNotBlank(loanApplicationId)) {
                List<Opportunity> oppObj= [ SELECT Id,Vehicle_Type__c,Vehicle_Sub_Category__c, Product_Type__c,
                    Ben_Code__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                System.debug(oppObj);
                if(!oppObj.isEmpty()){     
                    if(oppObj[0].Product_Type__c.equals('Two Wheeler')){
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','HUB');
                        jsonGen.writeStringField('value','HUB');
                        jsonGen.writeEndObject();
                        
                    }else if(oppObj[0].Product_Type__c.equals('Passenger Vehicles')){
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','SO');
                        jsonGen.writeStringField('value','SO');
                        jsonGen.writeEndObject();
                    }else{
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','SO');
                        jsonGen.writeStringField('value','SO');
                        jsonGen.writeEndObject();
                    }
                    list<Vehicle_Detail__c> vehDetail = new list<Vehicle_Detail__c>();
                    if(oppObj[0].Product_Type__c == System.Label.Tractor){
                        vehDetail = [SELECT Id,Ben_Code__c,Vehicle_SubCategory__c 
                                        FROM Vehicle_Detail__c 
                                        WHERE Loan_Application__c = :loanApplicationId AND Deal_Number__c =: dealId
                                        WITH SECURITY_ENFORCED limit 1 ];
                        if(oppObj[0].Vehicle_Type__c == 'New' || vehDetail[0].Vehicle_SubCategory__c == 'UPD'){
                            List<Benefi__c> benficiaryMasterObj = [ SELECT Id, TA__c, Ben_code__c FROM Benefi__c WHERE Ben_code__c =: vehDetail[0].Ben_Code__c WITH SECURITY_ENFORCED limit 1];
                            if(!benficiaryMasterObj.isEmpty()){
                                if(benficiaryMasterObj[0].TA__c.equals('Y')){
                                    jsonGen.writeStartObject();
                                    jsonGen.writeStringField('label','TA');
                                    jsonGen.writeStringField('value','TA');
                                    jsonGen.writeEndObject();
                                }
                            }
                        }
                    }else{
                        vehDetail = [SELECT Id,Ben_Code__c 
                                        FROM Vehicle_Detail__c 
                                        WHERE Loan_Application__c = :loanApplicationId 
                                        WITH SECURITY_ENFORCED limit 1 ];
                    

                    if(oppObj[0].Product_Type__c.equals('Two Wheeler') || oppObj[0].Product_Type__c.equals('Passenger Vehicles')){
                        if(oppObj[0].Vehicle_Type__c.equals('New') || oppObj[0].Vehicle_Sub_Category__c.equals('UPD') || oppObj[0].Vehicle_Sub_Category__c.equals('UEB')){
                            List<Benefi__c> benficiaryMasterObj = [ SELECT Id, TA__c, Ben_code__c FROM Benefi__c WHERE Ben_code__c =: vehDetail[0].Ben_Code__c WITH SECURITY_ENFORCED limit 1];
                            if(!benficiaryMasterObj.isEmpty()){
                                if(benficiaryMasterObj[0].TA__c.equals('Y')){
                                    jsonGen.writeStartObject();
                                    jsonGen.writeStringField('label','TA');
                                    jsonGen.writeStringField('value','TA');
                                    jsonGen.writeEndObject();
                                }
                            }
                        }
                    }
                    }
                    /****************************

                    @Author: Daksh Mandowara
                    @ModifiedDate: 11/04/2022
                    @UserStory:  Feature 10.2.1 - Business Payment
                    
                    if((oppObj[0].Vehicle_Type__c != 'New') || (oppObj[0].Vehicle_Sub_Category__c == 'UPD' || oppObj[0].Vehicle_Sub_Category__c == 'UEB')){
                        //Not TA Enabled
                        if(oppObj[0].Product_Type__c == 'Two Wheeler'){
                            //TODO HUB option only
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','HUB');
                            jsonGen.writeStringField('value','HUB');
                            jsonGen.writeEndObject();

                            //return 'HUB_ONLY';
                        }
                        else if(oppObj[0].Product_Type__c == 'Passenger Vehicles'){
                            //TODO SO option only
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','SO');
                            jsonGen.writeStringField('value','SO');
                            jsonGen.writeEndObject();

                            //return 'SO_ONLY';
                        }
                        else{
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','SO');
                            jsonGen.writeStringField('value','SO');
                            jsonGen.writeEndObject();                          

                            //return 'SO_ONLY';
                        }
                    }
                    else if((oppObj[0].Vehicle_Type__c == 'New') || (oppObj[0].Vehicle_Sub_Category__c == 'UPD' || oppObj[0].Vehicle_Sub_Category__c == 'UEB')){
                        //May be TA Enabled
                        List<Benefi__c> benficiaryMasterObj = [ SELECT Id, TA__c, Ben_code__c FROM Benefi__c WHERE Ben_code__c =: oppObj[0].Ben_Code__c WITH SECURITY_ENFORCED limit 1];
                       System.debug(benficiaryMasterObj);
                        if(!benficiaryMasterObj.isEmpty()){
                            //TA Enabled
                            if(benficiaryMasterObj[0].TA__c == 'Y'){
                                if(oppObj[0].Product_Type__c == 'Two Wheeler'){
                                    //TODO HUB and TA options only
                                    jsonGen.writeStartObject();
                                    jsonGen.writeStringField('label','HUB');
                                    jsonGen.writeStringField('value','HUB');
                                    jsonGen.writeEndObject();
                                    jsonGen.writeStartObject();
                                    jsonGen.writeStringField('label','TA');
                                    jsonGen.writeStringField('value','TA');
                                    jsonGen.writeEndObject();                                  

                                    //return 'HUB_TA_ONLY';
                                }
                                else if(oppObj[0].Product_Type__c == 'Passenger Vehicles'){
                                    //TODO SO and TA options only
                                    jsonGen.writeStartObject();
                                    jsonGen.writeStringField('label','SO');
                                    jsonGen.writeStringField('value','SO');
                                    jsonGen.writeEndObject();
                                    jsonGen.writeStartObject();
                                    jsonGen.writeStringField('label','TA');
                                    jsonGen.writeStringField('value','TA');
                                    jsonGen.writeEndObject();
                                    
                                    //return 'SO_TA_ONLY';
                                }
                            }
                        }
                        //TA not Enabled
                        else{
                            if(oppObj[0].Product_Type__c == 'Two Wheeler'){
                                //TODO HUB option only
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','HUB');
                                jsonGen.writeStringField('value','HUB');
                                jsonGen.writeEndObject();
                                
                                //return 'HUB_ONLY';
                            }
                            else if(oppObj[0].Product_Type__c == 'Passenger Vehicles'){
                                //TODO SO option only
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','SO');
                                jsonGen.writeStringField('value','SO');
                                jsonGen.writeEndObject();
                                
                                //return 'SO_ONLY';
                            }
                        }
                    }
                    ****************************************/
                }          
            }
            jsonGen.writeEndArray();
            return jsonGen.getAsString();
        }
        catch(Exception e){
            System.debug(e.getMessage());
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getPymntOrigFromDDValues', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }
    }

    /*@Method:      getBusinessUserIds
    * @Created by:  Daksh Mandowara
    * @Description: 
    * @Param:       String - loanApplicationId
    * @Return:      */
    @AuraEnabled(cacheable=true) 
    public static String getBusinessUserIds(String loanApplicationId, String dealId){
        List<LoanAppHistoryWrapper> modules = new List<LoanAppHistoryWrapper>();
        try {
            if(String.isNotBlank(loanApplicationId)) {
                Set<String> sSalesStages = new Set<String>{'Additional Details','Asset Details', 'Vehicle Valuation', 'Loan Details', 'Income Details', 'Final Terms', ' Offer Screen', 'Customer Code Addition', 'Insurance Details', 'Final Offer'};
                Set<String> sSalesProfiles = new Set<String>{'IBL Partner Community Marketing Agent', 'IBL Partner Community Marketing Officer', 'IBL Partner Community Counter Staff', 'IBL Marketing Officer', 'IBL Business Executive', 'IBL Product Executive', 'IBL Business Executive TW','IBL TF Business Executive','IBL Partner Community TF Business Executive'};//OLA-156
           
                Opportunity loanAppRec = [Select Id, CreatedById, CreatedBy.Name,mapped_BE__c,Name,LeadSource,Product_Type__c,OwnerId,Owner.Name From Opportunity Where Id=:loanApplicationId WITH SECURITY_ENFORCED];// CISP-2574- Added the LeadSource field in the query.
                // CISP-2574-START
                List<Final_Term__c> finalTermList = new List<Final_Term__c>();
                
                if(loanAppRec.Product_Type__c == System.Label.Tractor){
                    List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                    finalTermList = [SELECT Id,CreatedById,CreatedBy.Name 
                                        FROM Final_Term__c 
                                        WHERE Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id
                                        WITH SECURITY_ENFORCED];
                }else{
                    finalTermList = [SELECT Id,CreatedById,CreatedBy.Name 
                                        FROM Final_Term__c 
                                        WHERE Loan_Application__c =: loanApplicationId 
                                        WITH SECURITY_ENFORCED];
                }

                List<User> userList = [Select id,Name from User where id =: loanAppRec.mapped_BE__c];
                if(loanAppRec.LeadSource == 'D2C' && userList.size() > 0){
                    LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(userList[0].Id,userList[0].Name.removeStart('ibl'),'Loan Details');
                    modules.add(wrapper);
                }else
                if((loanAppRec.LeadSource == System.Label.MSIL_Lead_API_Value || loanAppRec.LeadSource == System.label.Mahindra_Custom_Lead_API_Value || loanAppRec.LeadSource == System.label.Mahindra_PreA_Lead_API_Value) && finalTermList.size() > 0){ //CISP-15890
                    LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(finalTermList[0].CreatedById,finalTermList[0].CreatedBy.Name.removeStart('ibl'),'Loan Details');
                    modules.add(wrapper);
                }else{
                // CISP-2574-END
                //CISP-4137
                if(loanAppRec.Product_Type__c=='Two Wheeler'){
                OpportunityHistory opphisttw = [select id, CreatedById,CreatedBy.Name from OpportunityHistory where OpportunityId =: loanApplicationId AND StageName ='Final Offer' AND CreatedBy.Profile.Name in :sSalesProfiles order by CreatedDate desc  limit 1];
                if(opphisttw != null) {
                    LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(opphisttw.CreatedById,opphisttw.CreatedBy.Name.removeStart('ibl'),'Loan Details');
                    modules.add(wrapper);
                    }
                }
                else{
                    if((loanAppRec.Name.contains('-A') || loanAppRec.Name.contains('_C1'))){
                        OpportunityHistory opphist = [select id, CreatedById,CreatedBy.Name from OpportunityHistory where OpportunityId =: loanApplicationId AND StageName in :sSalesStages AND CreatedBy.Profile.Name in :sSalesProfiles order by CreatedDate desc  limit 1];
                        if(opphist != null) {
                        LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(opphist.CreatedById,opphist.CreatedBy.Name.removeStart('ibl'),'Loan Details');
                        modules.add(wrapper);
                        }
                        /*
                        LoanAppHistoryWrapper wrapper2 = new LoanAppHistoryWrapper(loanAppRec.ownerId,loanAppRec.Owner.Name,'Asset Details');
                        modules.add(wrapper2);*/
                    } else {
                        LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(loanAppRec.CreatedById,loanAppRec.CreatedBy.Name.removeStart('ibl'),'Loan Details');
                        modules.add(wrapper);
                    }
                }
                }
                List<Case> cases = [SELECT Id,OwnerId,Owner.Name FROM Case WHERE (Type = 'Current Residence FI' OR Type = 'Permanent Residence FI' OR Type = 'Office FI') AND Loan_Application__c = :loanApplicationId AND Status = 'Accepted' WITH SECURITY_ENFORCED LIMIT 1];
                if(!cases.isEmpty()){
                    LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(cases[0].OwnerId,cases[0].Owner.Name.removeStart('ibl'),'FI');
                    modules.add(wrapper);
                }                
            }
            return JSON.serialize(modules); 
        }             
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'BusinessUserIds', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }
    }
//CISP-6283
    @AuraEnabled
    public static string GetBusinessUserIdsForPVProduct(String loanApplicationId){
        List<LoanAppHistoryWrapper> modules = new List<LoanAppHistoryWrapper>();
        try {
            if(String.isNotBlank(loanApplicationId)) {
                Applicant__c app = [SELECT ID from Applicant__c where applicant_Type__c = 'Borrower' and Opportunity__c =: loanApplicationId LIMIT 1];
                List<Retry_Count__c> retryList = [SELECT ID,Module__c, Service_Name__c,Applicant__r.Applicant_Type__c,CreatedBy.name,CreatedById  from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Applicant__r.Applicant_Type__c = 'Borrower' and Module__c = 'Gatting & Screening' and
                Service_Name__c = 'Check Eligibility Attempts' LIMIT 1];
                List<Opportunity> opp = [SELECT Id, Owner.Name,OwnerId FROM Opportunity WHERE Id=:loanApplicationId];
                if(!retryList.isEmpty()){
                        LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(retryList[0].CreatedById,retryList[0].CreatedBy.Name.removeStart('ibl'),'Business Sourced By');
                        modules.add(wrapper);
                }  else {
                    if(!opp.isEmpty()){
                        LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(opp[0].OwnerId,opp[0].Owner.Name.removeStart('ibl'),'Business Sourced By');
                        modules.add(wrapper);
                }
                }
                if(!opp.isEmpty()){
                    LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(opp[0].OwnerId,opp[0].Owner.Name.removeStart('ibl'),'Business Done By');
                    modules.add(wrapper);
                }
                List<Case> cases = [SELECT Id,OwnerId,Owner.Name FROM Case WHERE (Type = 'Current Residence FI' OR Type = 'Permanent Residence FI' OR Type = 'Office FI') AND Loan_Application__c = :loanApplicationId AND Status = 'Accepted' WITH SECURITY_ENFORCED LIMIT 1];
                if(!cases.isEmpty()){
                    LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper(cases[0].OwnerId,cases[0].Owner.Name.removeStart('ibl'),'FI');
                    modules.add(wrapper);
                }   
            }
            return JSON.serialize(modules); 

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'GetBusinessUserIdsForPVProduct', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }//CISP-6283 end

    /*@Method:      getBusinessUserIds
    * @Created by:  Daksh Mandowara
    * @Description: 
    * @Param:       String - loanApplicationId
    * @Return:      */
    @AuraEnabled(cacheable=true) 
    public static String getbussdoneby(String loanApplicationId, String dealId){
        Map<string,string> moUsermap = new Map<string,string>();
        List<LoanDisbursementDetails__c> LoanDisbus = new List<LoanDisbursementDetails__c>(); 
        Opportunity opp = [Select accountId,owner.Name,ownerId,Product_Type__c,CreatedBy.Id,CreatedBy.Name from Opportunity where Id =:loanApplicationId];
        if(opp.Product_Type__c == System.Label.Tractor){
            LoanDisbus = [SELECT Id , Business_Done_By__c, Business_Done_By__r.Name 
                            FROM LoanDisbursementDetails__c 
                            WHERE Parent_Loan_Application__c = :loanApplicationId AND Deal_Number__c =: dealId];
        }else{
            LoanDisbus = [SELECT Id , Business_Done_By__c, Business_Done_By__r.Name 
                            FROM LoanDisbursementDetails__c 
                            WHERE Parent_Loan_Application__c = :loanApplicationId]; 
        }
        try {
        if(opp.Product_Type__c == Label.Tractor){
            if(!LoanDisbus.isEmpty() && LoanDisbus[0].Business_Done_By__c != null){
                moUsermap.put(LoanDisbus[0].Business_Done_By__c, LoanDisbus[0].Business_Done_By__r.Name.removeStart('ibl'));
            }else{
                moUsermap.put(opp.CreatedBy.Id,opp.CreatedBy.Name.removeStart('ibl')); 
            }
        }else if(opp.Product_Type__c.equals('Two Wheeler')){//CISP: 2742
        for(AccountTeamMember atm : [SELECT AccountId, TeamMemberRole, User.Name,UserId FROM AccountTeamMember 
                                        WHERE AccountId =: opp.accountId AND (TeamMemberRole = 'BE' OR TeamMemberRole = 'PE') AND user.UserType ='Standard' WITH SECURITY_ENFORCED]) {
                                            moUsermap.put(atm.UserId,atm.User.Name.removeStart('ibl'));
                                        }
        } else {
             if(!LoanDisbus.isEmpty() && LoanDisbus[0].Business_Done_By__c != null){
                moUsermap.put(LoanDisbus[0].Business_Done_By__c, LoanDisbus[0].Business_Done_By__r.Name.removeStart('ibl'));
            }
            moUsermap.put(opp.ownerId,opp.owner.Name.removeStart('ibl'));
        }
        return JSON.serialize(moUsermap);
        }             
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'BusinessUserIds', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }
    }
    

    @AuraEnabled(cacheable=true) 
    public static String getCollectionExecutiveDDValues(String loanApplicationId){
        List<TBM_DL_Master_Wrapper> masterList = new List<TBM_DL_Master_Wrapper>();
        //List<TBM_DL_Masters>
        // masterList.add(new TBM_DL_Master_Wrapper('a1L710000001VPxEAM','PJ1234','Excutive 1'));
        // masterList.add(new TBM_DL_Master_Wrapper('a1L710000001VRZEA2','PJ5678','Excutive 2'));
        try {
            if(String.isNotBlank(loanApplicationId)) {
                    List<Opportunity> oppObj= [ SELECT Id, Product_Type__c, Ben_Code__c, Agent_BL_code__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                    /*List<Loan_Application_Transaction_History__c> loanHistory = [SELECT Id, Loan_Application_ID__c, Loan_Application_ID__r.Name,Loan_Application_ID__r.Product_Type__c, Screen__c, Current_Owner__c, 
                    Loan_Application_ID__r.Agent_BL_code__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c= :loanApplicationId 
                    AND Screen__c='Initiate RCU' WITH SECURITY_ENFORCED limit 1];*/
                    
                    if(!oppObj.isEmpty()){
                        String prodType='D';
                        if(oppObj[0].Product_Type__c.equals('Passenger Vehicles') || oppObj[0].Product_Type__c == Label.Tractor){
                            prodType = 'D';
                        }else{
                            prodType = 'H'; 
                        }
                        List<TBM_DL_Master__c> dealMasterList = [SELECT Id, DL_Code__c, Executive_Name__c FROM TBM_DL_Master__c
                        WHERE BL_Code__r.Bl_Code__c = :oppObj[0].Agent_BL_code__c AND 
                        Product__c = :prodType AND Status__c = 'L' ORDER BY DL_Code__c];

                        if(!dealMasterList.isEmpty()){
                            for(TBM_DL_Master__c obj : dealMasterList){
                                TBM_DL_Master_Wrapper wrapper = new TBM_DL_Master_Wrapper(obj.Id,obj.DL_Code__c,obj.Executive_Name__c);
                                masterList.add(wrapper);
                            }                
                        }
                    }
            } 
        }             
        catch(Exception e){
            System.debug(e.getMessage());
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getCollectionExecutiveDDValues', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }

        return JSON.serialize(masterList);
    }
    
    @AuraEnabled(cacheable=true) 
    public static String getDoToBeAuthorizedByDDValues(String loanApplicationId){
        List<Beneficiary_Master_Wrapper> masterList = new List<Beneficiary_Master_Wrapper>();
     //   masterList.add(new Beneficiary_Master_Wrapper('a0v710000007aRoAAI','BEN000465','UNIVERSAL MOTORS'));
     //   masterList.add(new Beneficiary_Master_Wrapper('a0v710000007aRpAAI','BEN000489','RAJ VEHICLES P LTD'));
        try {
            if(String.isNotBlank(loanApplicationId)) {
                List<Opportunity> opp = [SELECT Id, Ben_Code__c, Loan_Application_Number__c,Agent_BL_code__c, Product_Type__c, Vehicle_Type__c, Vehicle_Sub_Category__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                List<Benefi__c> benefiMasterList = new List<Benefi__c>();
                set<Id> blcodebenIds =new set<Id>(); 
                Map<String,Benefi__c> benMap = new Map<String,Benefi__c>();
                if(!opp.isEmpty()){
                    if(opp[0].Product_Type__c.equals('Two Wheeler')){
                        //CISP-3688
                        
                        benefiMasterList = [SELECT Id, Ben_code__c,Beneficiary__c, Name FROM Benefi__c 
                        WHERE 
                        Beneficiary__c = 'EMP' AND
                        Dealership_Nature__c IN ('PP-BH', 'PP-HHC', 'PV-HH') AND
                        Status_Flag__c = 'L' AND
                        Email__c != null];
                        Set<Id> benfiCodeIds = new Set<Id>();
                        for(Benefi__c bMaster : benefiMasterList){
                            benfiCodeIds.add(bMaster.Id);
                            benMap.put(bMaster.Id,bMaster);
                        }

                        List<Beneficiary_Product__c> benfiProds = [SELECT Ben_code__c FROM Beneficiary_Product__c WHERE Ben_Code__c = :benfiCodeIds and Product__r.ProductCode != 'C'];
                        Set<Id> benfiCodeProdIds = new Set<Id>();
                        for(Beneficiary_Product__c bProd : benfiProds){
                            benfiCodeProdIds.add(bProd.Ben_code__c);
                        }
                        
                        for(Beneficiary_BlCode__c be: [Select id,Ben_code__c from Beneficiary_BlCode__c where Ben_code__c =:benfiCodeProdIds and Bl_Code_Details__r.Bl_Code__c =: opp[0].Agent_BL_code__c]) {
                            blcodebenIds.add(be.Ben_code__c);
                        }
                        //CISP-3688
                    }
                    else if(opp[0].Product_Type__c.equals('Passenger Vehicles')){
                        /*List<Beneficiary_Product__c> benfiProds = [SELECT Ben_code__c FROM Beneficiary_Product__c WHERE Product__r.ProductCode = 'C'];
                        Set<Id> benfiCodeIds = new Set<Id>();
                        for(Beneficiary_Product__c bProd : benfiProds){
                            benfiCodeIds.add(bProd.Ben_code__c);
                        }
                        set<Id> blcodebenIds =new set<Id>();
                        for(Beneficiary_BlCode__c be: [Select id,Ben_code__c from Beneficiary_BlCode__c where Ben_code__c =:benfiCodeIds and Bl_Code_Details__r.Bl_Code__c =: opp[0].Agent_BL_code__c]) {
                            blcodebenIds.add(be.Ben_code__c);
                        }
                        benefiMasterList = [SELECT Id, Ben_code__c,Beneficiary__c, Name FROM Benefi__c 
                        WHERE Id = :blcodebenIds AND 
                        Beneficiary__c = 'EMP' AND
                        Dealership_Nature__c IN ('CP-BH', 'CP-BHB', 'PV-BH', 'PV-BHB', 'UPV-BH', 'UV-BH', 'UV-BHB', 'CP-HH') AND
                        Status_Flag__c = 'L' AND
                        Email__c != null];*/
                        //CISP-3688
                        benefiMasterList = [SELECT Id, Ben_code__c,Beneficiary__c, Name FROM Benefi__c 
                        WHERE 
                        Beneficiary__c = 'EMP' AND
                        Dealership_Nature__c IN ('CP-BH', 'CP-BHB', 'PV-BH', 'PV-BHB', 'UPV-BH', 'UV-BH', 'UV-BHB', 'CP-HH') AND
                        Status_Flag__c = 'L' AND
                        Email__c != null];
                        Set<Id> benfiCodeIds = new Set<Id>();
                        for(Benefi__c bMaster : benefiMasterList){
                            benfiCodeIds.add(bMaster.Id);
                            benMap.put(bMaster.Id,bMaster);
                        }

                        List<Beneficiary_Product__c> benfiProds = [SELECT Ben_code__c FROM Beneficiary_Product__c WHERE Ben_Code__c = :benfiCodeIds and Product__r.ProductCode = 'C'];
                        Set<Id> benfiCodeProdIds = new Set<Id>();
                        for(Beneficiary_Product__c bProd : benfiProds){
                            benfiCodeProdIds.add(bProd.Ben_code__c);
                        }
                        
                        
                        for(Beneficiary_BlCode__c be: [Select id,Ben_code__c from Beneficiary_BlCode__c where Ben_code__c =:benfiCodeProdIds and Bl_Code_Details__r.Bl_Code__c =: opp[0].Agent_BL_code__c]) {
                            blcodebenIds.add(be.Ben_code__c);
                        }
                        //CISP-3688
                    }else if(opp[0].Product_Type__c == System.Label.Tractor){
                        benefiMasterList = [SELECT Id, Ben_code__c,Beneficiary__c, Name FROM Benefi__c 
                        WHERE 
                        Beneficiary__c = 'EMP' AND
                        Dealership_Nature__c IN ('CP-BH', 'CP-BHB', 'PV-BH', 'PV-BHB', 'UPV-BH', 'UV-BH', 'UV-BHB', 'CP-HH') AND
                        Status_Flag__c = 'L' AND
                        Email__c != null];
                        Set<Id> benfiCodeIds = new Set<Id>();
                        for(Benefi__c bMaster : benefiMasterList){
                            benfiCodeIds.add(bMaster.Id);
                            benMap.put(bMaster.Id,bMaster);
                        }

                        List<Beneficiary_Product__c> benfiProds = [SELECT Ben_code__c FROM Beneficiary_Product__c WHERE Ben_Code__c = :benfiCodeIds and Product__r.ProductCode = 'T'];
                        Set<Id> benfiCodeProdIds = new Set<Id>();
                        for(Beneficiary_Product__c bProd : benfiProds){
                            benfiCodeProdIds.add(bProd.Ben_code__c);
                        }
                        
                        
                        for(Beneficiary_BlCode__c be: [Select id,Ben_code__c from Beneficiary_BlCode__c where Ben_code__c =:benfiCodeProdIds and Bl_Code_Details__r.Bl_Code__c =: opp[0].Agent_BL_code__c]) {
                            blcodebenIds.add(be.Ben_code__c);
                        }
                    }
                }
                
                if(!blcodebenIds.isEmpty()){
                    for(String benId : blcodebenIds){
                        if(benMap.containsKey(benId))
                        masterList.add(new Beneficiary_Master_Wrapper(benId,benMap.get(benId).Ben_code__c,benMap.get(benId).Name));
                    }
                }
            }
        }             
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getDoToBeAuthorizedByDDValues', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }

        return JSON.serialize(masterList);
    }
    /******** End Changes by Daksh Mandowara ***************/
    /*@Method:      getVehicleSoldBy
    * @Created by:  Daksh Mandowara
    * @Description: 
    * @Param:       String - loanApplicationId
    * @Return:      */
    @AuraEnabled(cacheable=true) 
    public static String getVehicleSoldBy(String loanApplicationId, String dealId){
        try {
            if(String.isNotBlank(loanApplicationId)) {
                Opportunity oppObj = [SELECT Vehicle_Sub_Category__c, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
                if(oppObj != null){
                    List<Invoice_Details__c> inv = new List<Invoice_Details__c>();
                    if(oppObj.Product_Type__c == System.Label.Tractor){
                        inv = [SELECT Dealer_Name__c FROM Invoice_Details__c WHERE Loan_Application__c = :oppObj.Id AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC limit 1];

                        List<Vehicle_Detail__c> vehicleList = [ SELECT Id,Vehicle_SubCategory__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanApplicationId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED limit 1];

                        if(oppObj.Vehicle_Type__c != null && oppObj.Vehicle_Type__c.equals('New')){
                            if(!inv.isEmpty()){
                                return inv[0].Dealer_Name__c;
                            }
                        } else {
                            if(vehicleList.size() > 0 && (vehicleList[0].Vehicle_SubCategory__c == 'UPD')){
                                if(!inv.isEmpty()){
                                    return inv[0].Dealer_Name__c;
                                }
                            }
                            else if(vehicleList.size() > 0 && (vehicleList[0].Vehicle_SubCategory__c == 'UOM' || vehicleList[0].Vehicle_SubCategory__c == 'UOB')){
                                return 'EDITABLE_FIELD';
                            }
                            else{
                                return 'DISABLE_FIELD';
                            }
                    }
                    }else{
                        inv = [SELECT Dealer_Name__c 
                                FROM Invoice_Details__c 
                                WHERE Loan_Application__c = :oppObj.Id 
                                WITH SECURITY_ENFORCED 
                                ORDER BY CreatedDate DESC limit 1];

                    if(oppObj.Vehicle_Type__c != null && oppObj.Vehicle_Type__c.equals('New')){
                        // List<Invoice_Details__c> inv = [SELECT Dealer_Name__c FROM Invoice_Details__c WHERE Loan_Application__c = :oppObj.Id WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC limit 1];
                            if(!inv.isEmpty()){
                                return inv[0].Dealer_Name__c;
                            }
                    } else {
                        if(oppObj.Vehicle_Sub_Category__c.equals('UPD') || oppObj.Vehicle_Sub_Category__c.equals('UEB')){
                            // List<Invoice_Details__c> inv = [SELECT Dealer_Name__c FROM Invoice_Details__c WHERE Loan_Application__c = :oppObj.Id WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC limit 1];
                            if(!inv.isEmpty()){
                                return inv[0].Dealer_Name__c;
                            }
                        }
                        else if(oppObj.Vehicle_Sub_Category__c.equals('UOM') || oppObj.Vehicle_Sub_Category__c.equals('UOB')){
                            return 'EDITABLE_FIELD';
                        }
                        else{
                            return 'DISABLE_FIELD';
                        }
                    }

                    }
                }
                return 'DISABLE_FIELD';
            }
            return 'DISABLE_FIELD';
        }             
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getDoToBeAuthorizedByDDValues', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }
    }
    //public added by govind 
    public class BusinessPaymentWrapper {
       public String disbursementRecordId {get;set;}
       public String paymentOrgFrom {get;set;}
       public String vehicleSoldBy {get;set;}
       public String vehicleRegInNameOf {get;set;}
       public String busiSourceBy {get;set;}
       public String busiDoneBy {get;set;}
       public String fiDoneBy {get;set;}
       public String colleExe {get;set;}
       public String doIssuance {get;set;}
       public String doIssuanceMode {get;set;}
       public String toBeAuthBy {get;set;}
       public Decimal balTrans {get;set;}
       public String purChasDocCatq {get;set;}
       public Decimal origPurchaseVal {get;set;}
       public Date origPurchaseDate {get;set;}
       public String fundEndUse {get;set;}
       public String parentLoanApplication {get;set;}
    }

    public class Beneficiary_Master_Wrapper{
        public String id {get;set;}
        public String benCode {get;set;}
        public String benName {get;set;}

        public Beneficiary_Master_Wrapper(){}

        public Beneficiary_Master_Wrapper(String uid,String code,String name){
            this.id = uid;
            this.benCode = code;
            this.benName = name;
        }        
    }

    @AuraEnabled(cacheable=true)
    public static Beneficiary_Master_Wrapper newBeneficiaryMasterWrapper(){
        Beneficiary_Master_Wrapper wrapper = new Beneficiary_Master_Wrapper();
        return wrapper;
    }

    public class TBM_DL_Master_Wrapper{
        public String id {get;set;}
        public String dlcode {get;set;}
        public String excname {get;set;}

        public TBM_DL_Master_Wrapper(){}

        public TBM_DL_Master_Wrapper(String uid,String dlc,String exName){
            this.id = uid;
            this.dlcode = dlc;
            this.excname = exName;
        }        
    }

    @AuraEnabled(cacheable=true)
    public static TBM_DL_Master_Wrapper newTBMDLMasterWrapper(){
        TBM_DL_Master_Wrapper wrapper = new TBM_DL_Master_Wrapper();
        return wrapper;
    }
    
    public class LoanAppHistoryWrapper{
        public String id {get;set;}
        public String name {get;set;}
        public String module {get;set;}

        public LoanAppHistoryWrapper(){}

        public LoanAppHistoryWrapper(String userId,String username,String moduleName){
            this.id = userId;
            this.name = username;
            this.module = moduleName;
        }        
    }

    @AuraEnabled(cacheable=true)
    public static LoanAppHistoryWrapper newLoanAppHistoryWrapper(){
        LoanAppHistoryWrapper wrapper = new LoanAppHistoryWrapper();
        return wrapper;
    }

    
    @AuraEnabled(cacheable=true)
    public static BusinessPaymentWrapper newBusinessPaymentWrapper(){
        BusinessPaymentWrapper wrapper = new BusinessPaymentWrapper();
        return wrapper;
    }
    
    public class InsuranceWrapper{
        public Boolean isInsurancePresent{get;set;}
        public Boolean isInsurancePresentForCobo{get;set;}
        public Boolean isInsurancePresentForBorro{get;set;}
        public String disbursementRecordId {get; set;}
        public String insuranceAppNo {get;set;}
        public String installments {get;set;}
        public String longTermPolicyAvailable{get;set;}
        public String longTermPolicyOwnDamageYrs{get;set;}
        public String policyAvailable{get;set;}
        public String insurer{get;set;}
        public String rsd {get;set;} 
        public String gst{get;set;}
        public String ownDamagePremiumAddons{get;set;}
        public String thirdPartyPremiumsPaCover{get;set;} 
        public String firstYr_Idv{get;set;}
        public String firstYr_OwnDamagePremium{get;set;}
        public String firstYr_ThirdPartyPremium{get;set;}
        public String secondYr_IDV{get;set;}
        public String secondYr_OwnDamagePremium{get;set;}
        public String secondYr_ThirdPartyPremium{get;set;}
        public String thirdYr_IDV{get;set;}
        public String thirdYr_OwnDamagePremium{get;set;}
        public String thirdYr_ThirdParty_Premium{get;set;}
        public String fourthYr_IDV{get;set;}
        public String fourthYr_OwnDamagePremium{get;set;}
        public String fourthYr_ThirdPartyPremium{get;set;}
        public String fifthYr_Idv{get;set;}
        public String fifthYr_OwnDamagePremium{get;set;}
        public String fifthYr_ThirdPartyPremium{get;set;}
        //Nominee Details Screen
        public Boolean isCoBorrowerPresent{get;set;} 
        public String borrowerName{get;set;}
        public String borrowerDOB{get;set;}
        public String borrowerRelationship{get;set;}
        public String borrowerAddress{get;set;}
        public String borrowerSpouseGender{get;set;}
        public String borrowerSpouseDOB{get;set;}
        public String borrowerFirstChildName{get;set;}
        public String borrowerFirstChildGender{get;set;}
        public String borrowerFirstChildDOB{get;set;}
        public String borrowerSecondChildName{get;set;}
        public String borrowerSecondChildGender{get;set;}
        public String borrowerSecondChildDOB{get;set;}
        public String borrowerThirdChildName{get;set;}
        public String borrowerThirdChildGender{get;set;}
        public String borrowerThirdChildDOB{get;set;}
        public String borrowerFatherDOB{get;set;}
        public String borrowerMotherDOB{get;set;}
        public String borrowerInsuDoneBy{get;set;}

        public String coBorrowerName{get;set;}
        public String coBorrowerDOB{get;set;}
        public String coBorrowerRelationship{get;set;}
        public String coBorrowerAddress{get;set;}
        public String coBorrowerSpouseGender{get;set;}
        public String coBorrowerSpouseDOB{get;set;}
        public String coBorrowerFirstChildName{get;set;}
        public String coBorrowerFirstChildGender{get;set;}
        public String coBorrowerFirstChildDOB{get;set;}
        public String coBorrowerSecondChildName{get;set;}
        public String coBorrowerSecondChildGender{get;set;}
        public String coBorrowerSecondChildDOB{get;set;}
        public String coBorrowerThirdChildName{get;set;}
        public String coBorrowerThirdChildGender{get;set;}
        public String coBorrowerThirdChildDOB{get;set;}
        public String coBorrowerFatherDOB{get;set;}
        public String coBorrowerMotherDOB{get;set;}
        public String coBorrowerInsuDoneBy{get;set;}
        public List<Map<String, String>> nomineeGenderOptions{get;set;}
        public List<Map<String, String>> nomineeRelationshipOptions{get;set;}
        public List<Map<String, String>> nomineeInsDoneByOptions{get;set;}
        public List<Map<String, String>> nomineeInsDoneByOptionsCob{get;set;}
        public Boolean isPassengerVehicles{get;set;}
        public Boolean isBoNomineeRequired{get;set;}
        public Boolean isBofamilyDisabled{get;set;}
        public Boolean isCoNomineeRequired{get;set;}
        public Boolean isCofamilyDisabled{get;set;}
        public String appBorrowerName{get;set;}
        public String appCoborrowerName{get;set;}
        public String vehicleID{get;set;}
   }

    @AuraEnabled(cacheable=true) 
        public static List<String>  getIstInsurancePremiumPaidByDDValues(String loanApplicationId){
            try{
                if(loanApplicationId!=null) {
                    Opportunity oppObj=[ SELECT Id,Vehicle_Type__c,Funded__c,Non_Funded__c,Is_customer_interested_in_a_motor_insura__c,Motor_Insurance_Premium__c
                                            FROM Opportunity 
                                            WHERE Id =: loanApplicationId];
                    List<InsuranceDetails__c> insuranceDetails = [Select Id, Name, Funded_Non_funded__c
                                                                   From InsuranceDetails__c 
                                                                   Where Loan_Application__c =:loanApplicationId and Name = 'MOTOR' limit 1];
                    
                    if(insuranceDetails != null && insuranceDetails.size() > 0){
                        if(insuranceDetails[0].Funded_Non_funded__c == 'Funded'){
                            return new List<String>{'By Bank (Funding)'};
                        } 
                        else{
                            return new List<String>{'BY CUSTOMER (UPFRONT)'};
                        } 
                    }    
                    else {
                        return new List<String>{'Dealer','Free Insurance','Policy Taken By Customer'};
                    }
                }
            } 
            catch(Exception e) {
                ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getIstInsurancePremiumPaidByDDValues',System.Label.Apex, e);
                throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
            }
            return null;    
    }
    @AuraEnabled 
    public static List<Documents__c> getUploadedDocuments(String loanApplicationId){
        return [SELECT Id,Document_Type__c FROM Documents__c WHERE Opportunity_Relation__c = :loanApplicationId];
    }
    @AuraEnabled
    public static String handleInsuranceSubmit(String inputJson, String recordId, String dealId){
        try {
            System.debug('inputJSON::'+inputJson);
            InsuranceWrapper iw = (InsuranceWrapper)JSON.deserialize(inputJson,InsuranceWrapper.Class );
            System.debug('iw::'+iw);

            LoanDisbursementDetails__c ldd = new LoanDisbursementDetails__c();
            ldd.Id = iw.disbursementRecordId != '' ? Id.ValueOf(iw.disbursementRecordId) : null;
            if(String.isBlank(ldd.Id))
                ldd.Parent_Loan_Application__c = recordId;
            ldd.Insurance_application_no__c = iw.insuranceAppNo != '' ? iw.insuranceAppNo : null;
            ldd.RSD__c = iw.rsd != '' ? Date.valueOf(iw.rsd) : null;
            ldd.Insurer__c = iw.insurer != '' ? iw.insurer : null;
            ldd.X1st_Yr_Insurance_premium_paid_by__c = iw.installments!=''?iw.installments:null;
            ldd.GST__c =iw.gst!=''? Decimal.valueOf(iw.gst):null;
            ldd.Policy_available__c= iw.policyavailable!=''? iw.policyavailable=='Yes' ? true : false:null;
            ldd.Long_term_policy_available__c= iw.longTermPolicyAvailable!='' ? iw.longTermPolicyAvailable:null;   
            ldd.Long_term_policy_Own_Damage_Yrs__c= iw.longTermPolicyOwnDamageYrs!=''? iw.longTermPolicyOwnDamageYrs:null;
            ldd.Own_Damage_Premium_Add_ons__c = iw.ownDamagePremiumAddons!=''? Decimal.valueOf(iw.ownDamagePremiumAddons):null;
            ldd.Third_Party_Premiums_PA_Cover__c =iw.thirdPartyPremiumsPaCover!=''? Decimal.valueOf(iw.thirdPartyPremiumsPaCover):null;
            
            ldd.FirstYr_IDV__c = iw.firstYr_Idv!=''?Decimal.valueOf(iw.firstYr_Idv):0;
            ldd.FirstYr_Own_Damage_Premium__c = iw.firstYr_OwnDamagePremium!=''?Decimal.valueOf(iw.firstYr_OwnDamagePremium):0;
            ldd.FirstYr_Third_Party_Premium__c = iw.firstYr_ThirdPartyPremium!=''?Decimal.valueOf(iw.firstYr_ThirdPartyPremium):0;
            
            ldd.SecondYr_IDV__c = iw.secondYr_IDV!=''? Decimal.valueOf(iw.secondYr_IDV):0;
            ldd.SecondYr_Own_Damage_Premium__c = iw.secondYr_OwnDamagePremium!=''? Decimal.valueOf(iw.secondYr_OwnDamagePremium):0;
            ldd.SecondYr_Third_Party_Premium__c = iw.secondYr_ThirdPartyPremium!=''? Decimal.valueOf(iw.secondYr_ThirdPartyPremium):0;
            
            ldd.ThirdYr_IDV__c = iw.thirdYr_IDV!=''? Decimal.valueOf(iw.thirdYr_IDV):0;
            ldd.ThirdYr_Own_Damage_Premium__c = iw.thirdYr_OwnDamagePremium!=''? Decimal.valueOf(iw.thirdYr_OwnDamagePremium):0;
            ldd.ThirdYr_Third_Party_Premium__c = iw.thirdYr_ThirdParty_Premium!=''? Decimal.valueOf(iw.thirdYr_ThirdParty_Premium):0;
            
            ldd.FourthYr_IDV__c = iw.fourthYr_IDV!=''?Decimal.valueOf(iw.fourthYr_IDV):0;
            ldd.FourthYr_Own_Damage_Premium__c = iw.fourthYr_OwnDamagePremium!=''? Decimal.valueOf(iw.fourthYr_OwnDamagePremium):0;
            ldd.FourthYr_Third_Party_Premium__c = iw.fourthYr_ThirdPartyPremium!=''? Decimal.valueOf(iw.fourthYr_ThirdPartyPremium):0;

            ldd.FifthYr_IDV__c = iw.fifthYr_Idv!=''? Decimal.valueOf(iw.fifthYr_Idv):0;
            ldd.FifthYr_Own_Damage_Premium__c = iw.fifthYr_OwnDamagePremium!=''? Decimal.valueOf(iw.fifthYr_OwnDamagePremium):0;
            ldd.FifthYr_Third_Party_Premium__c = iw.fifthYr_ThirdPartyPremium!=''? Decimal.valueOf(iw.fifthYr_ThirdPartyPremium):0;
           
            //update nominee details if needed
            //CISP-2548-START
            // if(iw.isCoBorrowerPresent){
                ldd = addNomineeDetailsToUpdate(ldd, iw);
            // }//CISP-2548-END
            
            update ldd;
            
            if(String.isNotBlank(recordId)){
                Opportunity loanApp = [SELECT Id, StageName, Sub_Stage__c,Product_Type__c FROM Opportunity WHERE Id = :recordId WITH SECURITY_ENFORCED];
                if(loanApp.Product_Type__c == System.Label.Tractor && String.isNotBlank(dealId)){
                    Deal_Number__c dealObj = new Deal_Number__c();
                    dealObj.Id = dealId;
                    dealObj.Sub_Stage__c = 'Insurance Details';
                    update dealObj;
                }
                else if(loanApp.StageName.equals('Disbursement Request Preparation') && loanApp.Sub_Stage__c != null  && loanApp.Sub_Stage__c.equals('Business Payment Details') && !loanApp.Sub_Stage__c.equals('Insurance Details')){
                    loanApp.Sub_Stage__c = 'Insurance Details';
                    update loanApp;
                }
            }
            return 'success';
        } catch (Exception e) {
            return 'error'+e.getMessage()+e.getStackTraceString();
        }
    }
    
    /**
    * This method transfers wrapper data into object instance
    *
    **/
    public static LoanDisbursementDetails__c addNomineeDetailsToUpdate(LoanDisbursementDetails__c ldd, InsuranceWrapper iw){
        ldd.Borrower_Name__c = iw.borrowerName; 
        ldd.Borrower_DOB__c = iw.borrowerDOB != null && iw.borrowerDOB != '' ? Date.valueOf(iw.borrowerDOB) : null;
        ldd.Borrower_Relationship__c = iw.borrowerRelationship; 
        ldd.Borrower_Address__c = iw.borrowerAddress;
        ldd.CoBorrower_Name__c = iw.coBorrowerName; 
        ldd.CoBorrower_DOB__c = iw.coBorrowerDOB != null && iw.coBorrowerDOB != '' ? Date.valueOf(iw.coBorrowerDOB) : null; 
        ldd.CoBorrower_Relationship__c = iw.coBorrowerRelationship;
        ldd.CoBorrower_Address__c = iw.coBorrowerAddress;
        ldd.Borrower_Spouse_Gender__c = iw.borrowerSpouseGender; 
        ldd.Borrower_Spouse_DOB__c = iw.borrowerSpouseDOB != null && iw.borrowerSpouseDOB != '' ? Date.valueOf(iw.borrowerSpouseDOB) : null;
        ldd.Borrower_X1st_Child_Name__c = iw.borrowerFirstChildName; 
        ldd.Borrower_X1st_Child_Gender__c = iw.borrowerFirstChildGender;
        ldd.Borrower_X1st_Child_DOB__c = iw.borrowerFirstChildDOB != null && iw.borrowerFirstChildDOB != '' ? Date.valueOf(iw.borrowerFirstChildDOB) : null;
        ldd.Borrower_X2nd_Child_Name__c = iw.borrowerSecondChildName;
        ldd.Borrower_X2nd_Child_Gender__c = iw.borrowerSecondChildGender; 
        ldd.Borrower_X2nd_Child_DOB__c = iw.borrowerSecondChildDOB != null && iw.borrowerSecondChildDOB != '' ? Date.valueOf(iw.borrowerSecondChildDOB) : null; 
        ldd.Borrower_X3rd_Child_Name__c = iw.borrowerThirdChildName;
        ldd.Borrower_X3rd_Child_Gender__c = iw.borrowerThirdChildGender; 
        ldd.Borrower_X3rd_Child_DOB__c = iw.borrowerThirdChildDOB != null && iw.borrowerThirdChildDOB != '' ? Date.valueOf(iw.borrowerThirdChildDOB) : null;
        ldd.Borrower_Father_DOB__c = iw.borrowerFatherDOB != null && iw.borrowerFatherDOB != '' ? Date.valueOf(iw.borrowerFatherDOB) : null; 
        ldd.Borrower_Mother_DOB__c = iw.borrowerMotherDOB != null && iw.borrowerMotherDOB != '' ? Date.valueOf(iw.borrowerMotherDOB) : null; 
        ldd.Borrower_Insurance_business_done_by__c = iw.borrowerInsuDoneBy;
        ldd.CoBorrower_Spouse_Gender__c = iw.coBorrowerSpouseGender;
        ldd.CoBorrower_Spouse_DOB__c = iw.coBorrowerSpouseDOB != null && iw.coBorrowerSpouseDOB != '' ? Date.valueOf(iw.coBorrowerSpouseDOB) : null;
        ldd.CoBorrower_X1st_Child_Name__c = iw.coBorrowerFirstChildName;
        ldd.CoBorrower_X1st_Child_Gender__c = iw.coBorrowerFirstChildGender; 
        ldd.CoBorrower_X1st_Child_DOB__c = iw.coBorrowerFirstChildDOB != null && iw.coBorrowerFirstChildDOB != '' ? Date.valueOf(iw.coBorrowerFirstChildDOB) : null;
        ldd.CoBorrower_X2nd_Child_Name__c = iw.coBorrowerSecondChildName;
        ldd.CoBorrower_X2nd_Child_Gender__c = iw.coBorrowerSecondChildGender; 
        ldd.CoBorrower_X2nd_Child_DOB__c = iw.coBorrowerSecondChildDOB != null && iw.coBorrowerSecondChildDOB != '' ? Date.valueOf(iw.coBorrowerSecondChildDOB) : null; 
        ldd.CoBorrower_X3rd_Child_Name__c = iw.coBorrowerThirdChildName; 
        ldd.CoBorrower_X3rd_Child_Gender__c = iw.coBorrowerThirdChildGender;
        ldd.CoBorrower_X3rd_Child_DOB__c = iw.coBorrowerThirdChildDOB != null && iw.coBorrowerThirdChildDOB != '' ? Date.valueOf(iw.coBorrowerThirdChildDOB) : null; 
        ldd.CoBorrower_Father_DOB__c = iw.coBorrowerFatherDOB != null && iw.coBorrowerFatherDOB != '' ? Date.valueOf(iw.coBorrowerFatherDOB) : null; 
        ldd.CoBorrower_Mother_DOB__c = iw.coBorrowerMotherDOB != null && iw.coBorrowerMotherDOB != '' ? Date.valueOf(iw.coBorrowerMotherDOB) : null; 
        ldd.CoBorrower_Insurance_business_done_by__c = iw.coBorrowerInsuDoneBy;
        return ldd;
    }

    /*@Method:      loadInsuranceDetails
    * @Created by:  Daksh Mandowara
    * @Description: 
    * @Param:       String - loanApplicationId
    * @Return:      */

    @AuraEnabled(cacheable=true) // overload Method - Chaynnitt Agarwal
    public static String loadInsuranceDetails(String loanApplicationId){
        return loadInsuranceDetails(loanApplicationId,'');
    }

    @AuraEnabled(cacheable=true)
    public static String loadInsuranceDetails(String loanApplicationId, String dealId){
        try{
                InsuranceWrapper iw = new InsuranceWrapper();
                Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
                if(String.isNotBlank(loanApplicationId)){
                    List<LoanDisbursementDetails__c> disbursement = [SELECT Id,Insurance_application_no__c,RSD__c,Insurer__c,GST__c,Policy_available__c,Long_term_policy_available__c,
                    Long_term_policy_Own_Damage_Yrs__c, X1st_Yr_Insurance_premium_paid_by__c,
                    Own_Damage_Premium_Add_ons__c,Third_Party_Premiums_PA_Cover__c,FirstYr_IDV__c,FirstYr_Own_Damage_Premium__c,FirstYr_Third_Party_Premium__c,
                    SecondYr_IDV__c,SecondYr_Own_Damage_Premium__c,SecondYr_Third_Party_Premium__c,ThirdYr_IDV__c,ThirdYr_Own_Damage_Premium__c,ThirdYr_Third_Party_Premium__c,
                    FourthYr_IDV__c,FourthYr_Own_Damage_Premium__c,FourthYr_Third_Party_Premium__c,FifthYr_IDV__c,FifthYr_Own_Damage_Premium__c,FifthYr_Third_Party_Premium__c,
                    Borrower_Name__c, Borrower_DOB__c, Borrower_Relationship__c, Borrower_Address__c, CoBorrower_Name__c, CoBorrower_DOB__c, CoBorrower_Relationship__c,
                    CoBorrower_Address__c, Borrower_Spouse_Gender__c, Borrower_Spouse_DOB__c, Borrower_X1st_Child_Name__c, Borrower_X1st_Child_Gender__c,
                    Borrower_X1st_Child_DOB__c, Borrower_X2nd_Child_Name__c, Borrower_X2nd_Child_Gender__c, Borrower_X2nd_Child_DOB__c, Borrower_X3rd_Child_Name__c,
                    Borrower_X3rd_Child_Gender__c, Borrower_X3rd_Child_DOB__c, Borrower_Father_DOB__c, Borrower_Mother_DOB__c, Borrower_Insurance_business_done_by__c,
                    CoBorrower_Spouse_Gender__c, CoBorrower_Spouse_DOB__c, CoBorrower_X1st_Child_Name__c, CoBorrower_X1st_Child_Gender__c, CoBorrower_X1st_Child_DOB__c,
                    CoBorrower_X2nd_Child_Name__c, CoBorrower_X2nd_Child_Gender__c, CoBorrower_X2nd_Child_DOB__c, CoBorrower_X3rd_Child_Name__c, CoBorrower_X3rd_Child_Gender__c, 
                    CoBorrower_X3rd_Child_DOB__c, CoBorrower_Father_DOB__c, CoBorrower_Mother_DOB__c, CoBorrower_Insurance_business_done_by__c
                    FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =:loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC limit 1];
                    if(oppRec.Product_Type__c == System.Label.Tractor){
                        disbursement = [SELECT Id,Insurance_application_no__c,RSD__c,Insurer__c,GST__c,Policy_available__c,Long_term_policy_available__c,
                                        Long_term_policy_Own_Damage_Yrs__c, X1st_Yr_Insurance_premium_paid_by__c,
                                        Own_Damage_Premium_Add_ons__c,Third_Party_Premiums_PA_Cover__c,FirstYr_IDV__c,FirstYr_Own_Damage_Premium__c,FirstYr_Third_Party_Premium__c,
                                        SecondYr_IDV__c,SecondYr_Own_Damage_Premium__c,SecondYr_Third_Party_Premium__c,ThirdYr_IDV__c,ThirdYr_Own_Damage_Premium__c,ThirdYr_Third_Party_Premium__c,
                                        FourthYr_IDV__c,FourthYr_Own_Damage_Premium__c,FourthYr_Third_Party_Premium__c,FifthYr_IDV__c,FifthYr_Own_Damage_Premium__c,FifthYr_Third_Party_Premium__c,
                                        Borrower_Name__c, Borrower_DOB__c, Borrower_Relationship__c, Borrower_Address__c, CoBorrower_Name__c, CoBorrower_DOB__c, CoBorrower_Relationship__c,
                                        CoBorrower_Address__c, Borrower_Spouse_Gender__c, Borrower_Spouse_DOB__c, Borrower_X1st_Child_Name__c, Borrower_X1st_Child_Gender__c,
                                        Borrower_X1st_Child_DOB__c, Borrower_X2nd_Child_Name__c, Borrower_X2nd_Child_Gender__c, Borrower_X2nd_Child_DOB__c, Borrower_X3rd_Child_Name__c,
                                        Borrower_X3rd_Child_Gender__c, Borrower_X3rd_Child_DOB__c, Borrower_Father_DOB__c, Borrower_Mother_DOB__c, Borrower_Insurance_business_done_by__c,
                                        CoBorrower_Spouse_Gender__c, CoBorrower_Spouse_DOB__c, CoBorrower_X1st_Child_Name__c, CoBorrower_X1st_Child_Gender__c, CoBorrower_X1st_Child_DOB__c,
                                        CoBorrower_X2nd_Child_Name__c, CoBorrower_X2nd_Child_Gender__c, CoBorrower_X2nd_Child_DOB__c, CoBorrower_X3rd_Child_Name__c, CoBorrower_X3rd_Child_Gender__c, 
                                        CoBorrower_X3rd_Child_DOB__c, CoBorrower_Father_DOB__c, CoBorrower_Mother_DOB__c, CoBorrower_Insurance_business_done_by__c
                                        FROM LoanDisbursementDetails__c 
                                        WHERE Parent_Loan_Application__c =:loanApplicationId AND Deal_Number__c =: dealId
                                        WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC limit 1];
                        List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                        iw.vehicleID = VehicleLst.size() > 0 ? VehicleLst[0].Id : '';
                    }else{
                        disbursement = [SELECT Id,Insurance_application_no__c,RSD__c,Insurer__c,GST__c,Policy_available__c,Long_term_policy_available__c,
                                        Long_term_policy_Own_Damage_Yrs__c, X1st_Yr_Insurance_premium_paid_by__c,
                                        Own_Damage_Premium_Add_ons__c,Third_Party_Premiums_PA_Cover__c,FirstYr_IDV__c,FirstYr_Own_Damage_Premium__c,FirstYr_Third_Party_Premium__c,
                                        SecondYr_IDV__c,SecondYr_Own_Damage_Premium__c,SecondYr_Third_Party_Premium__c,ThirdYr_IDV__c,ThirdYr_Own_Damage_Premium__c,ThirdYr_Third_Party_Premium__c,
                                        FourthYr_IDV__c,FourthYr_Own_Damage_Premium__c,FourthYr_Third_Party_Premium__c,FifthYr_IDV__c,FifthYr_Own_Damage_Premium__c,FifthYr_Third_Party_Premium__c,
                                        Borrower_Name__c, Borrower_DOB__c, Borrower_Relationship__c, Borrower_Address__c, CoBorrower_Name__c, CoBorrower_DOB__c, CoBorrower_Relationship__c,
                                        CoBorrower_Address__c, Borrower_Spouse_Gender__c, Borrower_Spouse_DOB__c, Borrower_X1st_Child_Name__c, Borrower_X1st_Child_Gender__c,
                                        Borrower_X1st_Child_DOB__c, Borrower_X2nd_Child_Name__c, Borrower_X2nd_Child_Gender__c, Borrower_X2nd_Child_DOB__c, Borrower_X3rd_Child_Name__c,
                                        Borrower_X3rd_Child_Gender__c, Borrower_X3rd_Child_DOB__c, Borrower_Father_DOB__c, Borrower_Mother_DOB__c, Borrower_Insurance_business_done_by__c,
                                        CoBorrower_Spouse_Gender__c, CoBorrower_Spouse_DOB__c, CoBorrower_X1st_Child_Name__c, CoBorrower_X1st_Child_Gender__c, CoBorrower_X1st_Child_DOB__c,
                                        CoBorrower_X2nd_Child_Name__c, CoBorrower_X2nd_Child_Gender__c, CoBorrower_X2nd_Child_DOB__c, CoBorrower_X3rd_Child_Name__c, CoBorrower_X3rd_Child_Gender__c, 
                                        CoBorrower_X3rd_Child_DOB__c, CoBorrower_Father_DOB__c, CoBorrower_Mother_DOB__c, CoBorrower_Insurance_business_done_by__c
                                        FROM LoanDisbursementDetails__c 
                                        WHERE Parent_Loan_Application__c =:loanApplicationId 
                                        WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC limit 1];
                    }
                    //check if there is co-borrower
                    List<Opportunity> opps = [SELECT Id, LeadSource,Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId ];
                    Boolean isD2CApplication = (opps.size() > 0 && opps[0].LeadSource == 'D2C') ? TRUE : FALSE;
                    List<Applicant__c> applicantList = [Select Id, Opportunity__c, Applicant_Type__c From Applicant__c Where Opportunity__c =:loanApplicationId AND In_Active_Applicant__c = false];//CISP-2548
                    //check if Insurance Record is present for this loanApp
                    List<InsuranceDetails__c> insuranceDetailList = new List<InsuranceDetails__c>([Select Id,Applicant__c,Applicant__r.Applicant_Type__c,Name,Loan_Application__r.Product_Type__c,Applicant__r.Name From InsuranceDetails__c Where Loan_Application__c=:loanApplicationId AND Applicant__r.In_Active_Applicant__c = false]);
                    if(!disbursement.isEmpty()){
                        iw.isPassengerVehicles = (opps.size() > 0 && opps[0].Product_Type__c =='Passenger Vehicles') ? true : false;
                        iw.isInsurancePresent = insuranceDetailList.size() > 0 ? true : false;
                        //check if insurance present for Borrower & Co-borrower
                        iw.isInsurancePresentForCobo = false;
                        iw.isInsurancePresentForBorro = false;
                        for(InsuranceDetails__c insuDetail : insuranceDetailList){
                            if(insuDetail.Applicant__c != null){
                                if(insuDetail.Applicant__r.Applicant_Type__c == 'Borrower'){
                                    iw.isInsurancePresentForBorro = true;
                                    if(insuDetail.Loan_Application__r.Product_Type__c =='Passenger Vehicles' && insuDetail.Name != 'MOTOR'){
                                        iw.isBoNomineeRequired = true;
                                        iw.appBorrowerName = insuDetail.Applicant__r.Name;
                                    }
                                    if(insuDetail.Loan_Application__r.Product_Type__c =='Passenger Vehicles' && insuDetail.Name == 'FLEXI'){
                                        iw.isBofamilyDisabled = true;
                                    }
                                } else {
                                    iw.isInsurancePresentForCobo = true;
                                    if(insuDetail.Loan_Application__r.Product_Type__c =='Passenger Vehicles' && insuDetail.Name != 'MOTOR'){
                                        iw.isCoNomineeRequired = true;
                                        iw.appCoborrowerName = insuDetail.Applicant__r.Name;
                                    }
                                    if(insuDetail.Loan_Application__r.Product_Type__c =='Passenger Vehicles' && insuDetail.Name == 'FLEXI'){
                                        iw.isCofamilyDisabled = true;
                                    }
                                }
                            }
                        }
                        iw.disbursementRecordId = disbursement[0].Id != null ? disbursement[0].Id : '';
                        iw.insuranceAppNo = disbursement[0].Insurance_application_no__c != null ? String.valueOf(disbursement[0].Insurance_application_no__c) : '';
                        iw.rsd = disbursement[0].RSD__c != null ? String.valueOf(disbursement[0].RSD__c) : '';
                        iw.insurer = disbursement[0].Insurer__c != null ? String.valueOf(disbursement[0].Insurer__c) : '';
                        iw.installments = disbursement[0].X1st_Yr_Insurance_premium_paid_by__c != null ? String.valueOf(disbursement[0].X1st_Yr_Insurance_premium_paid_by__c) : '';
                        iw.longTermPolicyOwnDamageYrs = disbursement[0].Long_term_policy_Own_Damage_Yrs__c != null ? String.valueOf(disbursement[0].Long_term_policy_Own_Damage_Yrs__c) : '';
                        iw.policyAvailable = disbursement[0].Policy_available__c ? 'Yes' : 'No';
                        iw.longTermPolicyAvailable = disbursement[0].Long_term_policy_available__c != null ? String.valueOf(disbursement[0].Long_term_policy_available__c) : '';
                        iw.gst = disbursement[0].GST__c != null ? String.valueOf(disbursement[0].GST__c) : '';
                
                        iw.ownDamagePremiumAddons = disbursement[0].Own_Damage_Premium_Add_ons__c != null ? String.valueOf(disbursement[0].Own_Damage_Premium_Add_ons__c) : '';
                        iw.thirdPartyPremiumsPaCover = disbursement[0].Third_Party_Premiums_PA_Cover__c != null ? String.valueOf(disbursement[0].Third_Party_Premiums_PA_Cover__c) : '';
                        iw.firstYr_Idv = disbursement[0].FirstYr_IDV__c != null ? String.valueOf(disbursement[0].FirstYr_IDV__c) : '';
                        iw.firstYr_OwnDamagePremium = disbursement[0].FirstYr_Own_Damage_Premium__c != null ? String.valueOf(disbursement[0].FirstYr_Own_Damage_Premium__c) : '';
                        iw.firstYr_ThirdPartyPremium = disbursement[0].FirstYr_Third_Party_Premium__c != null ? String.valueOf(disbursement[0].FirstYr_Third_Party_Premium__c) : '';
                        iw.secondYr_IDV = disbursement[0].SecondYr_IDV__c != null ? String.valueOf(disbursement[0].SecondYr_IDV__c) : '';
                        
                        
                        iw.secondYr_OwnDamagePremium = disbursement[0].SecondYr_Own_Damage_Premium__c != null ? String.valueOf(disbursement[0].SecondYr_Own_Damage_Premium__c) : '';
                        iw.secondYr_ThirdPartyPremium = disbursement[0].SecondYr_Third_Party_Premium__c != null ? String.valueOf(disbursement[0].SecondYr_Third_Party_Premium__c) : '';
                        iw.thirdYr_IDV = disbursement[0].ThirdYr_IDV__c != null ? String.valueOf(disbursement[0].ThirdYr_IDV__c) : '';
                        iw.thirdYr_OwnDamagePremium = disbursement[0].ThirdYr_Own_Damage_Premium__c != null ? String.valueOf(disbursement[0].ThirdYr_Own_Damage_Premium__c) : '';
                        iw.thirdYr_ThirdParty_Premium = disbursement[0].ThirdYr_Third_Party_Premium__c != null ? String.valueOf(disbursement[0].ThirdYr_Third_Party_Premium__c) : '';
                        iw.fourthYr_IDV = disbursement[0].FourthYr_IDV__c != null ? String.valueOf(disbursement[0].FourthYr_IDV__c) : '';
                        iw.fourthYr_OwnDamagePremium = disbursement[0].FourthYr_Own_Damage_Premium__c != null ? String.valueOf(disbursement[0].FourthYr_Own_Damage_Premium__c) : '';
                        iw.fourthYr_ThirdPartyPremium = disbursement[0].FourthYr_Third_Party_Premium__c != null ? String.valueOf(disbursement[0].FourthYr_Third_Party_Premium__c) : '';
                        iw.fifthYr_Idv = disbursement[0].FifthYr_IDV__c != null ? String.valueOf(disbursement[0].FifthYr_IDV__c) : '';
                        iw.fifthYr_OwnDamagePremium = disbursement[0].FifthYr_Own_Damage_Premium__c != null ? String.valueOf(disbursement[0].FifthYr_Own_Damage_Premium__c) : '';
                        iw.fifthYr_ThirdPartyPremium = disbursement[0].SecondYr_Third_Party_Premium__c != null ? String.valueOf(disbursement[0].FifthYr_Third_Party_Premium__c) : '';
                        
                        //Borrower and Co-borrower details
                        //CISP-2548-START
                        if(applicantList != null && applicantList.size() > 1 && !isD2CApplication){
                            iw.isCoBorrowerPresent = true;
                        }else{
                            iw.isCoBorrowerPresent = false;
                        }
                        iw = addNomineeDetailsToWrapper(iw, disbursement, loanApplicationId);
                        //CISP-2548-END
                        return JSON.serialize(iw);
                    }
                }
                return null;
            }
        catch(Exception e){
            
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getDisbursementInsuranceDetails', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }  
    } 
    
    /**
    * This method transfers object data into wrapper instance
    *
    **/
    public static InsuranceWrapper addNomineeDetailsToWrapper(InsuranceWrapper iw, List<LoanDisbursementDetails__c> disbursement,
                                                             String loanApplicationId){
        // iw.isCoBorrowerPresent = true;//CISP-2548
        //picklistOptions
        List<Map<String, String>> nomineeGenderOptions = new List<Map<String, String>>();
        List<Map<String, String>> nomineeRelationshipOptions = new List<Map<String, String>>();
        List<Map<String, String>> nomineeInsDoneByOptions = new List<Map<String, String>>();
        List<Map<String, String>> nomineeInsDoneByOptionsCob = new List<Map<String, String>>();
        Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('LoanDisbursementDetails__c');
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        
        //gender options
        List <Schema.PicklistEntry> genderPickListValues = fieldMap.get('Borrower_Spouse_Gender__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: genderPickListValues) {
            Map <String, String> values = new Map < String, String > {
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            nomineeGenderOptions.add(values);
        }
        //relationship options
        List <Schema.PicklistEntry> relationPickListValues = fieldMap.get('Borrower_Relationship__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: relationPickListValues) {
            Map <String, String> values = new Map <String, String> {
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            nomineeRelationshipOptions.add(values);
        }
        //Insurance business done by options
        Set<String> benCodeList = new Set<String>();
        Opportunity loanApprecord = [Select Id, Product_Type__c, Ben_Code__c, Agent_BL_code__c From Opportunity Where Id =:loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
        String prodTypeString = '';
        if(loanApprecord.Product_Type__c == 'Passenger Vehicles'){
            prodTypeString = loanApprecord.Product_Type__c.toUpperCase().removeEnd('S');
        }
        else{
            prodTypeString = loanApprecord.Product_Type__c.toUpperCase();
        } 
        List<Beneficiary_BlCode__c> benBlCodeList = new List<Beneficiary_BlCode__c>([Select Id, Ben_code__c, Bl_Code_Details__r.Bl_Code__c  
            From Beneficiary_BlCode__c Where Bl_Code_Details__r.Bl_Code__c=: loanApprecord.Agent_BL_code__c and Ben_Code__r.Status_Flag__c = 'L' WITH SECURITY_ENFORCED]);
        for(Beneficiary_BlCode__c benBLCode : benBlCodeList){
            benCodeList.add(benBLCode.Ben_code__c);
        } 
          system.debug('++'+loanApprecord.Product_Type__c+'++'+prodTypeString + '++'+benCodeList);                                                       
        List<Beneficiary_Product__c> benProdList = new List<Beneficiary_Product__c>([Select Id, Ben_code__c, Ben_Code__r.Role__c, Ben_Code__r.Beneficiary__c, Ben_Code__r.Name,Product__c, Product__r.Product_Type__c
            From Beneficiary_Product__c Where Ben_Code__c in: benCodeList and Product__r.Name =: prodTypeString AND (Ben_Code__r.Beneficiary__c = 'EMP' OR Ben_Code__r.Beneficiary__c = 'DR' OR Ben_Code__r.Beneficiary__c = 'MA') WITH SECURITY_ENFORCED]);
        //End    
        //Map<Id, Benefi__c> benMasterMap = new Map<Id, Benefi__c>([Select Id, Name, Ben_Code__c,Role__c From Benefi__c Where Ben_Code__c =:loanApprecord.Ben_Code__c AND Status_Flag__c = 'L' WITH SECURITY_ENFORCED]);
        /*//Now get the ben master with Bl code same as Loan app
        List<Beneficiary_BlCode__c> benBlCodeList = new List<Beneficiary_BlCode__c>([Select Id, Ben_code__c, Bl_Code_Details__r.Bl_Code__c 
                                                                                    From Beneficiary_BlCode__c Where Ben_code__c IN :benMasterMap.keySet()
                                                                                   AND Bl_Code_Details__r.Bl_Code__c=: loanApprecord.Agent_BL_code__c WITH SECURITY_ENFORCED]);
        Set<Id> benMasterIdSet = new Set<Id>();
        for(Beneficiary_BlCode__c benBlCode : benBlCodeList){
            benMasterIdSet.add(benBlCode.Ben_code__c);
        }
        // and now from these filtered records, get where the vehicle type is same as loan app
        List<Beneficiary_Product__c> benProdList = new List<Beneficiary_Product__c>([Select Id, Ben_code__c, Ben_Code__r.Role__c, Ben_Code__r.Beneficiary__c, Ben_Code__r.Name,Product__c, Product__r.Product_Type__c
                                                                                    From Beneficiary_Product__c Where Ben_code__c IN :benMasterIdSet 
                                                                                     AND (Product__r.Product_Type__c =:loanApprecord.Product_Type__c 
                                                                                          OR Product__r.Product_Type__c =: prodTypeString) WITH SECURITY_ENFORCED]);
        */
        //iterate through eligible Ben Master records and create picklist values
        if(benProdList != null && !benProdList.isEmpty()){
            Set<String> picklistOprtionsSet = new Set<String>();
            for(Beneficiary_Product__c benProd : benProdList){
                if('Two Wheeler'.equalsIgnoreCase(loanApprecord.Product_Type__c)){
                    if(benProd.Ben_Code__r.Beneficiary__c == 'DR' 
                       ||(benProd.Ben_Code__r.Beneficiary__c == 'EMP' && (benProd.Ben_Code__r.Role__c == 'MO' || benProd.Ben_Code__r.Role__c == 'TWDB'))
                       ||benProd.Ben_Code__r.Beneficiary__c == 'MA'){
                        picklistOprtionsSet.add(benProd.Ben_Code__r.Name);
                    }
                } else if('Passenger Vehicles'.equalsIgnoreCase(loanApprecord.Product_Type__c)){
                    if(benProd.Ben_Code__r.Beneficiary__c == 'EMP' && (benProd.Ben_Code__r.Role__c == 'MO' || benProd.Ben_Code__r.Role__c == 'CVALL' 
                                                             || benProd.Ben_Code__r.Role__c == 'CVBE')){
                        picklistOprtionsSet.add(benProd.Ben_Code__r.Name);
                    }
                }
            }
            //create options map
            if(picklistOprtionsSet != null && !picklistOprtionsSet.isEmpty()){
                for(String name : picklistOprtionsSet){
            Map <String, String> values = new Map <String, String> {
                        'label' => name,
                        'value' => name
            };
            nomineeInsDoneByOptions.add(values);
            nomineeInsDoneByOptionsCob.add(values);
        }
            }
        }                                                          
        //add options to wrapper
        iw.nomineeGenderOptions = nomineeGenderOptions;
        iw.nomineeRelationshipOptions = nomineeRelationshipOptions;
        
        //Borrower details
        iw.borrowerName = disbursement[0].Borrower_Name__c != null ? String.valueOf(disbursement[0].Borrower_Name__c) : '';
        iw.borrowerDOB = disbursement[0].Borrower_DOB__c != null ? String.valueOf(disbursement[0].Borrower_DOB__c) : '';
        iw.borrowerRelationship = disbursement[0].Borrower_Relationship__c != null ? String.valueOf(disbursement[0].Borrower_Relationship__c) : '';
        iw.borrowerAddress = disbursement[0].Borrower_Address__c != null ? String.valueOf(disbursement[0].Borrower_Address__c) : '';
        iw.borrowerSpouseGender = disbursement[0].Borrower_Spouse_Gender__c != null ? String.valueOf(disbursement[0].Borrower_Spouse_Gender__c) : '';
        iw.borrowerSpouseDOB = disbursement[0].Borrower_Spouse_DOB__c != null ? String.valueOf(disbursement[0].Borrower_Spouse_DOB__c) : '';
        iw.borrowerFirstChildName = disbursement[0].Borrower_X1st_Child_Name__c != null ? String.valueOf(disbursement[0].Borrower_X1st_Child_Name__c) : '';
        iw.borrowerFirstChildGender = disbursement[0].Borrower_X1st_Child_Gender__c != null ? String.valueOf(disbursement[0].Borrower_X1st_Child_Gender__c) : '';
        iw.borrowerFirstChildDOB = disbursement[0].Borrower_X1st_Child_DOB__c != null ? String.valueOf(disbursement[0].Borrower_X1st_Child_DOB__c) : '';
        iw.borrowerSecondChildName = disbursement[0].Borrower_X2nd_Child_Name__c != null ? String.valueOf(disbursement[0].Borrower_X2nd_Child_Name__c) : '';
        iw.borrowerSecondChildGender = disbursement[0].Borrower_X2nd_Child_Gender__c != null ? String.valueOf(disbursement[0].Borrower_X2nd_Child_Gender__c) : '';
        iw.borrowerSecondChildDOB = disbursement[0].Borrower_X2nd_Child_DOB__c != null ? String.valueOf(disbursement[0].Borrower_X2nd_Child_DOB__c) : '';
        iw.borrowerThirdChildName = disbursement[0].Borrower_X3rd_Child_Name__c != null ? String.valueOf(disbursement[0].Borrower_X3rd_Child_Name__c) : '';
        iw.borrowerThirdChildGender = disbursement[0].Borrower_X3rd_Child_Gender__c != null ? String.valueOf(disbursement[0].Borrower_X3rd_Child_Gender__c) : '';
        iw.borrowerThirdChildDOB = disbursement[0].Borrower_X3rd_Child_DOB__c != null ? String.valueOf(disbursement[0].Borrower_X3rd_Child_DOB__c) : '';
        iw.borrowerFatherDOB = disbursement[0].Borrower_Father_DOB__c != null ? String.valueOf(disbursement[0].Borrower_Father_DOB__c) : '';
        iw.borrowerMotherDOB = disbursement[0].Borrower_Mother_DOB__c != null ? String.valueOf(disbursement[0].Borrower_Mother_DOB__c) : '';
        iw.borrowerInsuDoneBy = disbursement[0].Borrower_Insurance_business_done_by__c != null ? String.valueOf(disbursement[0].Borrower_Insurance_business_done_by__c) : '';
        if(iw.borrowerInsuDoneBy != null && iw.borrowerInsuDoneBy != ''){
            Map <String, String> existingValue = new Map <String, String> {
                        'label' => iw.borrowerInsuDoneBy,
                        'value' => iw.borrowerInsuDoneBy
            };
          nomineeInsDoneByOptions.add(existingValue);
        }
        iw.nomineeInsDoneByOptions = nomineeInsDoneByOptions;
        //Co-borrower details
        iw.coBorrowerName = disbursement[0].CoBorrower_Name__c != null ? String.valueOf(disbursement[0].CoBorrower_Name__c) : '';
        iw.coBorrowerDOB = disbursement[0].CoBorrower_DOB__c != null ? String.valueOf(disbursement[0].CoBorrower_DOB__c) : '';
        iw.coBorrowerRelationship = disbursement[0].CoBorrower_Relationship__c != null ? String.valueOf(disbursement[0].CoBorrower_Relationship__c) : '';
        iw.coBorrowerAddress = disbursement[0].CoBorrower_Address__c != null ? String.valueOf(disbursement[0].CoBorrower_Address__c) : '';
        iw.coBorrowerSpouseGender = disbursement[0].CoBorrower_Spouse_Gender__c != null ? String.valueOf(disbursement[0].CoBorrower_Spouse_Gender__c) : '';
        iw.coBorrowerSpouseDOB = disbursement[0].CoBorrower_Spouse_DOB__c != null ? String.valueOf(disbursement[0].CoBorrower_Spouse_DOB__c) : '';
        iw.coBorrowerFirstChildName = disbursement[0].CoBorrower_X1st_Child_Name__c != null ? String.valueOf(disbursement[0].CoBorrower_X1st_Child_Name__c) : '';
        iw.coBorrowerFirstChildGender = disbursement[0].CoBorrower_X1st_Child_Gender__c != null ? String.valueOf(disbursement[0].CoBorrower_X1st_Child_Gender__c) : '';
        iw.coBorrowerFirstChildDOB = disbursement[0].CoBorrower_X1st_Child_DOB__c != null ? String.valueOf(disbursement[0].CoBorrower_X1st_Child_DOB__c) : '';
        iw.coBorrowerSecondChildName = disbursement[0].CoBorrower_X2nd_Child_Name__c != null ? String.valueOf(disbursement[0].CoBorrower_X2nd_Child_Name__c) : '';
        iw.coBorrowerSecondChildGender = disbursement[0].CoBorrower_X2nd_Child_Gender__c != null ? String.valueOf(disbursement[0].CoBorrower_X2nd_Child_Gender__c) : '';
        iw.coBorrowerSecondChildDOB = disbursement[0].CoBorrower_X2nd_Child_DOB__c != null ? String.valueOf(disbursement[0].CoBorrower_X2nd_Child_DOB__c) : '';
        iw.coBorrowerThirdChildName = disbursement[0].CoBorrower_X3rd_Child_Name__c != null ? String.valueOf(disbursement[0].CoBorrower_X3rd_Child_Name__c) : '';
        iw.coBorrowerThirdChildGender = disbursement[0].CoBorrower_X3rd_Child_Gender__c != null ? String.valueOf(disbursement[0].CoBorrower_X3rd_Child_Gender__c) : '';
        iw.coBorrowerThirdChildDOB = disbursement[0].CoBorrower_X3rd_Child_DOB__c != null ? String.valueOf(disbursement[0].CoBorrower_X3rd_Child_DOB__c) : '';
        iw.coBorrowerFatherDOB = disbursement[0].CoBorrower_Father_DOB__c != null ? String.valueOf(disbursement[0].CoBorrower_Father_DOB__c) : '';
        iw.coBorrowerMotherDOB = disbursement[0].CoBorrower_Mother_DOB__c != null ? String.valueOf(disbursement[0].CoBorrower_Mother_DOB__c) : '';
        iw.coBorrowerInsuDoneBy = disbursement[0].CoBorrower_Insurance_business_done_by__c != null ? String.valueOf(disbursement[0].CoBorrower_Insurance_business_done_by__c) : '';
        if(iw.coBorrowerInsuDoneBy != null && iw.coBorrowerInsuDoneBy != ''){
            Map <String, String> existingValue = new Map <String, String> {
                        'label' => iw.coBorrowerInsuDoneBy,
                        'value' => iw.coBorrowerInsuDoneBy
            };
          nomineeInsDoneByOptionsCob.add(existingValue);
        }
        iw.nomineeInsDoneByOptionsCob = nomineeInsDoneByOptionsCob;
        return iw;
    }

    @AuraEnabled
    public static Id handleBeneficiaryDetailsSubmit(String inputData){
        try {
            System.debug('inputData ==>'+inputData);
            BeneficiaryDetailsWrapper objInputData;
            if(String.isNotBlank(inputData)){
                objInputData = (BeneficiaryDetailsWrapper)JSON.deserialize(inputData, BeneficiaryDetailsWrapper.class);
            }
            System.debug('objInputData ==>'+objInputData);
            
            LoanDisbursementDetails__c  objLoanDisbursmentDetail = new LoanDisbursementDetails__c();
            List<Opportunity> oppList = new List<Opportunity>([SELECT Id,Product_Type__c FROM Opportunity WHERE Id=: objInputData.parentLoanAppId]);
            Boolean isTractor = oppList.size() > 0  && oppList[0].Product_Type__c == Label.Tractor ? true : false;
            if(String.isNotBlank(objInputData.loanDisbursementDetailId)){
                objLoanDisbursmentDetail.Id = objInputData.loanDisbursementDetailId;
            }else{
                objLoanDisbursmentDetail.Parent_Loan_Application__c  = objInputData.parentLoanAppId;
            }
            objLoanDisbursmentDetail.DSA_Name__c = objInputData.dsaName;
            objLoanDisbursmentDetail.Physical_mandate_dispatched_to_Karapakka__c = objInputData.phyMandateDispToKarapakkam;
            objLoanDisbursmentDetail.Payment_To_DSA__c = objInputData.paymentToDSA;
            objLoanDisbursmentDetail.Co_borrower_name__c  = objInputData.coborrowerName;
            objLoanDisbursmentDetail.Payment_to_co_borrower__c = objInputData.paymentToCoborrower;
            objLoanDisbursmentDetail.Dealer_Payment__c  = objInputData.dealerPayment; 
            
            
            objLoanDisbursmentDetail.Adjustment_Deal_Number1__c  = objInputData.adjDealNumber1; 
            objLoanDisbursmentDetail.Adjustment_Deal_Number2__c  = objInputData.adjDealNumber2; 
            objLoanDisbursmentDetail.Adjustment_Deal_Number3__c  = objInputData.adjDealNumber3; 
            objLoanDisbursmentDetail.Adjustment_Deal_Number4__c  = objInputData.adjDealNumber4; 
            objLoanDisbursmentDetail.Adjustment_Deal_Number5__c  = objInputData.adjDealNumber5; 
            objLoanDisbursmentDetail.Adjustment_Deal_Number6__c  = objInputData.adjDealNumber6; 
            objLoanDisbursmentDetail.Adjustment_Deal_Number7__c  = objInputData.adjDealNumber7; 
            objLoanDisbursmentDetail.Adjustment_Deal_Number8__c  = objInputData.adjDealNumber8; 
            objLoanDisbursmentDetail.Customer_name1__c  = objInputData.customerName1; 
            objLoanDisbursmentDetail.Customer_name2__c  = objInputData.customerName2; 
            objLoanDisbursmentDetail.Customer_name3__c  = objInputData.customerName3; 
            objLoanDisbursmentDetail.Customer_name4__c  = objInputData.customerName4; 
            objLoanDisbursmentDetail.Customer_name5__c  = objInputData.customerName5; 
            objLoanDisbursmentDetail.Customer_name6__c  = objInputData.customerName6;
            objLoanDisbursmentDetail.Customer_name7__c  = objInputData.customerName7;
            objLoanDisbursmentDetail.Customer_name8__c  = objInputData.customerName8;
            //CISP-2629-START
            objLoanDisbursmentDetail.Customer_code1__c  = objInputData.customerCode1;
            objLoanDisbursmentDetail.Customer_code2__c  = objInputData.customerCode2;
            objLoanDisbursmentDetail.Customer_code3__c  = objInputData.customerCode3;
            objLoanDisbursmentDetail.Customer_code4__c  = objInputData.customerCode4;
            objLoanDisbursmentDetail.Customer_code5__c  = objInputData.customerCode5;
            objLoanDisbursmentDetail.Customer_code6__c  = objInputData.customerCode6;
            objLoanDisbursmentDetail.Customer_code7__c  = objInputData.customerCode7;
            objLoanDisbursmentDetail.Customer_code8__c  = objInputData.customerCode8;
            //CISP-2629-END
            objLoanDisbursmentDetail.Adjustment_Amount1__c  = objInputData.adjAmount1; 
            objLoanDisbursmentDetail.Adjustment_Amount2__c  = objInputData.adjAmount2; 
            objLoanDisbursmentDetail.Adjustment_Amount3__c  = objInputData.adjAmount3; 
            objLoanDisbursmentDetail.Adjustment_Amount4__c  = objInputData.adjAmount4; 
            objLoanDisbursmentDetail.Adjustment_Amount5__c  = objInputData.adjAmount5; 
            objLoanDisbursmentDetail.Adjustment_Amount6__c  = objInputData.adjAmount6; 
            objLoanDisbursmentDetail.Adjustment_Amount7__c  = objInputData.adjAmount7; 
            objLoanDisbursmentDetail.Adjustment_Amount8__c  = objInputData.adjAmount8; 
            
            
            objLoanDisbursmentDetail.Beneficiary_1__c  = objInputData.beneficiaryName1;
            objLoanDisbursmentDetail.Beneficiary_2__c  = objInputData.beneficiaryName2;
            objLoanDisbursmentDetail.Beneficiary_3__c  = objInputData.beneficiaryName3;
            objLoanDisbursmentDetail.Beneficiary_4__c  = objInputData.beneficiaryName4;
            objLoanDisbursmentDetail.Beneficiary_1_Account_Number__c  = objInputData.beneficiaryAccNo1;
            objLoanDisbursmentDetail.Beneficiary_2_Account_Number__c  = objInputData.beneficiaryAccNo2;
            objLoanDisbursmentDetail.Beneficiary_3_Account_Number__c  = objInputData.beneficiaryAccNo3;
            objLoanDisbursmentDetail.Beneficiary_4_Account_Number__c  = objInputData.beneficiaryAccNo4;
            objLoanDisbursmentDetail.Beneficiary_1_Amount__c  = objInputData.beneficiaryAmount1;
            objLoanDisbursmentDetail.Beneficiary_2_Amount__c  = objInputData.beneficiaryAmount2;
            objLoanDisbursmentDetail.Beneficiary_3_Amount__c  = objInputData.beneficiaryAmount3;
            objLoanDisbursmentDetail.Beneficiary_4_Amount__c  = objInputData.beneficiaryAmount4;
            objLoanDisbursmentDetail.Seller_Bank_Name__c = objInputData.bankName;
            objLoanDisbursmentDetail.Seller_Account_Number__c = objInputData.accountNumber;
            objLoanDisbursmentDetail.Seller_Bank_Branch_Name__c = objInputData.bankBranchName;
            objLoanDisbursmentDetail.Seller_Bank_Branch_Pincode__c = objInputData.bankBranchPincode;
            objLoanDisbursmentDetail.Seller_Bank_IFSC_Code__c = objInputData.bankIFSCcode;
            objLoanDisbursmentDetail.Bank_Ben_Code__c = objInputData.benefiCode;
            if(objInputData.isNewVehicle){
                objLoanDisbursmentDetail.Beneficiary_1_Type__c = objInputData.dealershipNature;
            }else{
                if(objInputData.loanAppVehicleSubCategory == 'UOB'){
                    if(objInputData.paymentToDSA && objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Bank';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'DSA';
                        objLoanDisbursmentDetail.Beneficiary_3_Type__c = 'Coborrower';
                    }else if(!objInputData.paymentToDSA && objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Bank';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Seller';
                        objLoanDisbursmentDetail.Beneficiary_3_Type__c = 'Coborrower';
                    }else if(objInputData.paymentToDSA && !objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Bank';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'DSA';
                        objLoanDisbursmentDetail.Beneficiary_3_Type__c = 'Borrower';
                    }else if(!objInputData.paymentToDSA && !objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Bank';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Seller';
                        objLoanDisbursmentDetail.Beneficiary_3_Type__c = 'Borrower';
                    }
                }else if(objInputData.loanAppVehicleSubCategory == 'UPB'){
                    if(objInputData.paymentToDSA){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Bank';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'DSA';
                    }else if(!objInputData.paymentToDSA && objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Bank';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Coborrower';
                    }else if(!objInputData.paymentToDSA && !objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Bank';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Borrower';
                    }
                }else if(objInputData.loanAppVehicleSubCategory == 'UOM'){
                    if(objInputData.paymentToDSA && objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'DSA';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Coborrower ';
                    }else if(objInputData.paymentToDSA && !objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'DSA';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Borrower';
                    }else if(!objInputData.paymentToDSA && objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Seller';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Coborrower ';
                    }else if(!objInputData.paymentToDSA && !objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Seller';
                        objLoanDisbursmentDetail.Beneficiary_2_Type__c = 'Borrower';
                    }
                }else if(objInputData.loanAppVehicleSubCategory == 'UPO' || objInputData.loanAppVehicleSubCategory == 'URV'){
                    if(objInputData.paymentToDSA){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'DSA';
                    }else if(!objInputData.paymentToDSA && !objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Borrower';
                    }else if(!objInputData.paymentToDSA && objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Coborrower';
                    }
                }else if(objInputData.loanAppVehicleSubCategory == 'RLY' || objInputData.loanAppVehicleSubCategory == 'RLN' || (objInputData.loanAppVehicleSubCategory == 'UEB' && isTractor == true)){
                    if(objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Coborrower';
                    }else if(!objInputData.paymentToCoborrower){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Borrower';
                    }
                }else if(objInputData.loanAppVehicleSubCategory == 'UPD' || objInputData.loanAppVehicleSubCategory == 'UEB'){
                    if(isTractor && objInputData.loanAppVehicleSubCategory == 'UPD'){
                        if(objInputData.paymentToDSA){
                            objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'DSA';
                        }else{
                            objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Dealer';
                        }
                    }else if(!isTractor && (objInputData.loanAppVehicleSubCategory == 'UEB' || objInputData.loanAppVehicleSubCategory == 'UPD')){
                        objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Dealer';
                    }
                }else if(objInputData.loanAppVehicleSubCategory == 'UIM'){
                    objLoanDisbursmentDetail.Beneficiary_1_Type__c = 'Borrower';
                }
            }
            
            System.debug('objLoanDisbursmentDetail ==>'+objLoanDisbursmentDetail);
            update objLoanDisbursmentDetail;

            if(String.isNotBlank(objInputData.parentLoanAppId)){
                Opportunity loanApp = [SELECT Id, StageName,LeadSource,Sub_Stage__c,Hero_Disbursed_Date__c,Hero_IsDisbursed__c FROM Opportunity WHERE Id = :objInputData.parentLoanAppId];//CISH-17
                if(loanApp.StageName.equals('Disbursement Request Preparation') && loanApp.Sub_Stage__c != null && loanApp.Sub_Stage__c.equals('New/Used Vehicle Details') && !loanApp.Sub_Stage__c.equals('Beneficiary Details')){
                    // loanApp.Sub_Stage__c = 'Beneficiary Details';
                    // update loanApp;
                } if(loanApp.LeadSource == 'Hero'){//CISH-17
                    loanApp.Hero_Disbursed_Date__c = system.now();
                    loanApp.Hero_IsDisbursed__c = true;
                    update loanApp;
                }//CISH-17
            }
            return objLoanDisbursmentDetail.id;
        }
        catch(Exception e){            
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'handleBeneficiaryDetailsSubmit', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static BeneficiaryDetailsWrapper getBeneficiaryDetails(String parentLoanAppId, String dealId){
        System.debug('parentLoanAppId ==>'+parentLoanAppId);
        List<LoanDisbursementDetails__c> lstRecords = [SELECT Id, Payment_Originated_From__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c,
                                                       Payment_To_DSA__c, Co_borrower_name__c, Payment_to_co_borrower__c, Dealer_Payment__c,
                                                       Parent_Loan_Application__c,Parent_Loan_Application__r.Vehicle_Sub_Category__c,Parent_Loan_Application__r.Vehicle_Type__c,Parent_Loan_Application__r.Product_Type__c,
                                                       Adjustment_Amount1__c, Adjustment_Amount2__c, Adjustment_Amount3__c, Adjustment_Amount4__c, Adjustment_Amount5__c,
                                                       Adjustment_Amount6__c, Adjustment_Amount7__c, Adjustment_Amount8__c,
                                                       Adjustment_Deal_Number1__c, Adjustment_Deal_Number2__c, Adjustment_Deal_Number3__c, Adjustment_Deal_Number4__c,
                                                       Adjustment_Deal_Number5__c, Adjustment_Deal_Number6__c, Adjustment_Deal_Number7__c, Adjustment_Deal_Number8__c, 
                                                       Customer_name1__c,Customer_name2__c, Customer_name3__c, Customer_name4__c, Customer_name5__c, Customer_name6__c,
                                                       Customer_name7__c, Customer_name8__c, Beneficiary_1_Account_Number__c,Beneficiary_2_Account_Number__c, 
                                                       Beneficiary_3_Account_Number__c, Beneficiary_4_Account_Number__c,Beneficiary_1_Amount__c, Beneficiary_2_Amount__c, 
                                                       Beneficiary_3_Amount__c, Beneficiary_4_Amount__c,Beneficiary_1__c, Beneficiary_2__c, Beneficiary_3__c, Beneficiary_4__c,
                                                        Total_Adjustment_Amount__c, Total_beneficiary_amount__c, Balance_Transfer_Amount_in_Rs__c, Seller_Account_Number__c, 
                                                        Seller_Bank_Branch_Name__c, Seller_Bank_Branch_Pincode__c, Seller_Bank_IFSC_Code__c, Seller_Bank_Name__c,Parent_Loan_Application__r.StageName,Parent_Loan_Application__r.Sub_Stage__c,Bank_Ben_Code__c,
                                                        Customer_code1__c,Customer_code2__c,Customer_code3__c,Customer_code4__c,Customer_code5__c,Customer_code6__c,Customer_code7__c,Customer_code8__c, Parent_Loan_Application__r.Application_Type__c, Payment_to_Builder__c, Payment_to_Dealer__c
                                                       FROM LoanDisbursementDetails__c  WHERE Parent_Loan_Application__c =: parentLoanAppId AND Deal_Number__c = : dealId ORDER BY CreatedDate DESC
                                                      ];//CISP-2629- Added customer code fields in the query.
        BeneficiaryDetailsWrapper objData = new BeneficiaryDetailsWrapper();

        List<Final_Term__c> lstFinalTerm = new List<Final_Term__c>([SELECT Id, Referrer_Name__c,Loan_Amount__c,RC_limit_enabled_DSA__c,Loan_Application__r.Total_Funded_Premium__c,Can_we_continue_with_above_RC_limit__c, Referrer_Ben_Code__c,Gross_IRR__c,CRM_IRR__c,Net_IRR__c,Inputted_IRR__c,Installment_Type__c,EMI_Amount__c,Tenure__c,Loan_Application__r.Vehicle_Type__c,First_EMI_Date__c,Second_EMI_Date__c,Advance_EMI__c,Loan_Deal_Date__c,Service_charges__c,Documentation_charges__c,CAM_CRM_IRR__c,CAM_Gross_IRR__c,CAM_NET_IRR__c, Last_Offer_Engine_Equat__c, Last_Offer_Engine_Struct__c, Vehicle_Detail__r.Total_Funded_Amount__c FROM Final_Term__c WHERE Loan_Application__c =: parentLoanAppId AND Vehicle_Detail__r.Deal_Number__c = : dealId WITH SECURITY_ENFORCED]);//CISP-8762 //CISP-15591

        List<LoanDisbursementDetails__c> lstLoanDisDetails = new List<LoanDisbursementDetails__c>([Select Id,Vehicle_Sold_By__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: parentLoanAppId AND Deal_Number__c = : dealId WITH SECURITY_ENFORCED]);

        List<Applicant__c> lstApplicant = new List<Applicant__c>([SELECT Id, Name,Applicant_Type__c,Would_you_like_to_open_a_bank_account__c,CASA_Consent_Received__c,Who_will_repay_the_loan__c,IsPrimary__c,Opportunity__r.Product_Type__c FROM Applicant__c WHERE Opportunity__c =: parentLoanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);

        if(!lstRecords.isEmpty()){
            LoanDisbursementDetails__c tempRecord = lstRecords[0];

            List<Vehicle_Detail__c> vehiclelist = new List<Vehicle_Detail__c>();
            if( tempRecord.Parent_Loan_Application__r.Product_type__c == System.Label.Tractor){
                vehiclelist = [Select id,Vehicle_SubCategory__c from Vehicle_Detail__c Where Deal_Number__c =: dealId LIMIT 1];
            }
            objData.loanDisbursementDetailId = tempRecord.Id;
            objData.finaltermObj = lstFinalTerm.size() > 0 ? lstFinalTerm[0]:null;
            objData.dsaName = lstFinalTerm.size() > 0 ? lstFinalTerm[0].Referrer_Name__c : '';
            objData.finalTermRecordId = lstFinalTerm.size()> 0 ? lstFinalTerm[0].Id : '';//CISP-8762
            objData.rcLimitEnabledDSA = lstFinalTerm.size() > 0 ? lstFinalTerm[0].RC_limit_enabled_DSA__c : false;//CISP-8762
            objData.financeAmount = lstFinalTerm.size() > 0 ? Double.valueof(lstFinalTerm[0].Loan_Amount__c) == null ? 0 : Double.valueof(lstFinalTerm[0].Loan_Amount__c) : 0;
            objData.financeAmountForRcLimit = lstFinalTerm.size() > 0 ? Double.valueof(lstFinalTerm[0].Loan_Amount__c) == null ? 0 : Double.valueof(lstFinalTerm[0].Loan_Amount__c) + lstFinalTerm[0].Loan_Application__r.Total_Funded_Premium__c : 0;//CISP-8762
            objData.rcLimitClearedForDSA = lstFinalTerm.size()> 0 ? lstFinalTerm[0].Can_we_continue_with_above_RC_limit__c : false;//CISP-8762
            objData.paymentToDSA = tempRecord.Payment_To_DSA__c;
objData.paymentToBuilder = tempRecord.Payment_to_Builder__c;
            objData.paymentToDealer = tempRecord.Payment_to_Dealer__c;
            objData.coborrowerName = tempRecord.Co_borrower_name__c;
            objData.phyMandateDispToKarapakkam = tempRecord.Physical_mandate_dispatched_to_Karapakka__c;
            objData.parentLoanAppId = tempRecord.Parent_Loan_Application__c;
            objData.paymentToCoborrower = tempRecord.Payment_to_co_borrower__c;
            objData.dealerPayment = tempRecord.Dealer_Payment__c;
            objData.paymentOriginatedFrom = tempRecord.Payment_Originated_From__c;
            if( tempRecord.Parent_Loan_Application__r.Product_type__c == System.Label.Tractor){
                objData.loanAppVehicleSubCategory = vehiclelist.size() > 0 ? vehiclelist[0].Vehicle_SubCategory__c : '';
            }else{
            objData.loanAppVehicleSubCategory = tempRecord.Parent_Loan_Application__r.Vehicle_Sub_Category__c == null ? '' : tempRecord.Parent_Loan_Application__r.Vehicle_Sub_Category__c;
            }
            objData.loanAppVehicleType = tempRecord.Parent_Loan_Application__r.Vehicle_Type__c;
            objData.loanAppProductType = tempRecord.Parent_Loan_Application__r.Product_Type__c;
objData.loanAppApplicationType = tempRecord.Parent_Loan_Application__r.Application_Type__c;
            objData.adjDealNumber1 = tempRecord.Adjustment_Deal_Number1__c;
            objData.adjDealNumber2 = tempRecord.Adjustment_Deal_Number2__c;
            objData.adjDealNumber3 = tempRecord.Adjustment_Deal_Number3__c;
            objData.adjDealNumber4 = tempRecord.Adjustment_Deal_Number4__c;
            objData.adjDealNumber5 = tempRecord.Adjustment_Deal_Number5__c;
            objData.adjDealNumber6 = tempRecord.Adjustment_Deal_Number6__c;
            objData.adjDealNumber7 = tempRecord.Adjustment_Deal_Number7__c;
            objData.adjDealNumber8 = tempRecord.Adjustment_Deal_Number8__c;
            objData.customerName1 = tempRecord.Customer_name1__c;
            objData.customerName2 = tempRecord.Customer_name2__c;
            objData.customerName3 = tempRecord.Customer_name3__c;
            objData.customerName4 = tempRecord.Customer_name4__c;
            objData.customerName5 = tempRecord.Customer_name5__c;
            objData.customerName6 = tempRecord.Customer_name6__c;
            objData.customerName7 = tempRecord.Customer_name7__c;
            objData.customerName8 = tempRecord.Customer_name8__c;
            //CISP-2629-START
            objData.customerCode1 = tempRecord.Customer_code1__c == null ? '' : tempRecord.Customer_code1__c;
            objData.customerCode2 = tempRecord.Customer_code2__c == null ? '' : tempRecord.Customer_code2__c;
            objData.customerCode3 = tempRecord.Customer_code3__c == null ? '' : tempRecord.Customer_code3__c;
            objData.customerCode4 = tempRecord.Customer_code4__c == null ? '' : tempRecord.Customer_code4__c;
            objData.customerCode5 = tempRecord.Customer_code5__c == null ? '' : tempRecord.Customer_code5__c;
            objData.customerCode6 = tempRecord.Customer_code6__c == null ? '' : tempRecord.Customer_code6__c;
            objData.customerCode7 = tempRecord.Customer_code7__c == null ? '' : tempRecord.Customer_code7__c;
            objData.customerCode8 = tempRecord.Customer_code8__c == null ? '' : tempRecord.Customer_code8__c;
            //CISP-2629-END
            objData.adjAmount1  = tempRecord.Adjustment_Amount1__c;
            objData.adjAmount2 = tempRecord.Adjustment_Amount2__c;
            objData.adjAmount3 = tempRecord.Adjustment_Amount3__c;
            objData.adjAmount4 = tempRecord.Adjustment_Amount4__c ;
            objData.adjAmount5 = tempRecord.Adjustment_Amount5__c; 
            objData.adjAmount6 = tempRecord.Adjustment_Amount6__c;
            objData.adjAmount7 = tempRecord.Adjustment_Amount7__c;
            objData.adjAmount8 = tempRecord.Adjustment_Amount8__c;
            
            // objData.beneficiaryName1 = tempRecord.Beneficiary_1__c;
            objData.benefiDisabled = lstRecords.size() > 0 ? (lstRecords[0].Parent_Loan_Application__r.StageName == 'Disbursement Request Preparation' && lstRecords[0].Parent_Loan_Application__r.Sub_Stage__c == 'Beneficiary Details')  : false;
            
            if( tempRecord.Parent_Loan_Application__r.Product_type__c == System.Label.Tractor){
                if( vehiclelist.size() > 0 && (vehiclelist[0].Vehicle_SubCategory__c == 'UPB' || vehiclelist[0].Vehicle_SubCategory__c == 'UOB')){
                    List<Benefi__c> lstBenif = new List<Benefi__c>([SELECT Id, Ben_Code__c,Name FROM Benefi__c WHERE Ben_Code__c =:  tempRecord.Bank_Ben_Code__c With SECURITY_ENFORCED LIMIT 1]);
                    objData.beneficiaryName1 = lstBenif.size() > 0 ? lstBenif[0].Name +' | '+lstBenif[0].Ben_Code__c : '';//CISP-5192
                    objData.beneficiaryId1 = lstBenif.size() > 0 ? String.valueOf(lstBenif[0].Id) : '';
                }
                else{
                    objData.beneficiaryName1 = tempRecord.Beneficiary_1__c;
                    objData.beneficiaryId1 = '';
                }
            }else{
                if( tempRecord.Parent_Loan_Application__r.Vehicle_Sub_Category__c == 'UPB' || tempRecord.Parent_Loan_Application__r.Vehicle_Sub_Category__c == 'UOB'){
                    List<Benefi__c> lstBenif = new List<Benefi__c>([SELECT Id, Ben_Code__c,Name FROM Benefi__c WHERE Ben_Code__c =:  tempRecord.Bank_Ben_Code__c With SECURITY_ENFORCED LIMIT 1]);
                    objData.beneficiaryName1 = lstBenif.size() > 0 ? lstBenif[0].Name +' | '+lstBenif[0].Ben_Code__c : '';//CISP-5192
                    objData.beneficiaryId1 = lstBenif.size() > 0 ? String.valueOf(lstBenif[0].Id) : '';
                }
                else{
                    objData.beneficiaryName1 = tempRecord.Beneficiary_1__c;
                    objData.beneficiaryId1 = '';
                }
            }
            objData.benefiCode = tempRecord.Bank_Ben_Code__c;
            objData.beneficiaryName2 = tempRecord.Beneficiary_2__c;
            objData.beneficiaryName3 = tempRecord.Beneficiary_3__c;
            objData.beneficiaryName4 = tempRecord.Beneficiary_4__c;
            objData.beneficiaryAccNo1 = tempRecord.Beneficiary_1_Account_Number__c;
            objData.beneficiaryAccNo2 = tempRecord.Beneficiary_2_Account_Number__c; 
            objData.beneficiaryAccNo3 = tempRecord.Beneficiary_3_Account_Number__c;
            objData.beneficiaryAccNo4 = tempRecord.Beneficiary_4_Account_Number__c;
            objData.beneficiaryAmount1 = tempRecord.Beneficiary_1_Amount__c;
            objData.beneficiaryAmount2 = tempRecord.Beneficiary_2_Amount__c;
            objData.beneficiaryAmount3 = tempRecord.Beneficiary_3_Amount__c;
            objData.beneficiaryAmount4 = tempRecord.Beneficiary_4_Amount__c;
            
            objData.totalAdjAmount = tempRecord.Total_Adjustment_Amount__c ;
            objData.totalBeneficiaryAmount = tempRecord.Total_beneficiary_amount__c ;
            objData.balanceTransferAmountInRs = tempRecord.Balance_Transfer_Amount_in_Rs__c;

            objData.bankName = tempRecord.Seller_Bank_Name__c;
            objData.accountNumber = tempRecord.Seller_Account_Number__c;
            objData.bankBranchName = tempRecord.Seller_Bank_Branch_Name__c;
            objData.bankBranchPincode = tempRecord.Seller_Bank_Branch_Pincode__c;
            objData.bankIFSCcode = tempRecord.Seller_Bank_IFSC_Code__c;

            objData.finalTermReferrerName = lstFinalTerm.size() > 0 ? lstFinalTerm[0].Referrer_Name__c : null;

            objData.loanDisbursementDetailsVehicleSoldBy = lstLoanDisDetails.size() > 0 ? lstLoanDisDetails[0].Vehicle_Sold_By__c : null;

            List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>([SELECT Id, Ben_Code__c,Dealer_Sub_dealer_name__c,RC_limit_enabled_Dealer__c,Can_we_continue_with_above_RC_limit__c FROM Vehicle_Detail__c WHERE Loan_Application__c =:parentLoanAppId AND Deal_Number__c = : dealId With SECURITY_ENFORCED LIMIT 1]);
            objData.dealerName = vehicleDetailList.size() > 0 ? vehicleDetailList[0].Dealer_Sub_dealer_name__c + '|' + vehicleDetailList[0].Ben_Code__c : null;
            objData.dealerBenCode = vehicleDetailList.size() > 0 ? vehicleDetailList[0].Ben_Code__c : null;//CISP-11627
            objData.rcLimitEnabledDealer = vehicleDetailList.size() > 0 ? vehicleDetailList[0].RC_limit_enabled_Dealer__c : false;//CISP-8762
            objData.vehicleRecordId = vehicleDetailList.size() > 0 ? vehicleDetailList[0].Id : null;//CISP-8762
            objData.rcLimitClearedForDealer = vehicleDetailList.size() > 0 ? vehicleDetailList[0].Can_we_continue_with_above_RC_limit__c : false;//CISP-8762
            for(Applicant__c applicant : lstApplicant){
                if(applicant.Applicant_Type__c == 'Borrower'){
                    objData.primaryApplicantName = applicant.Name;
                    objData.primaryApplicantId = applicant.Id;
                    objData.primaryApplicantWillingnessforAccOpening = applicant.Would_you_like_to_open_a_bank_account__c;
                    objData.borrowerconsentRecived = applicant.CASA_Consent_Received__c;
                    if(String.isNotBlank(applicant.Who_will_repay_the_loan__c)){
                        objData.whoWillRepayLoan = applicant.Who_will_repay_the_loan__c;
                    }
                }
                else if((applicant.Applicant_Type__c == 'Co-borrower' && applicant.Opportunity__r.Product_Type__c != Label.Tractor) || (applicant.Applicant_Type__c == 'Co-borrower' && applicant.Opportunity__r.Product_Type__c == Label.Tractor && applicant.IsPrimary__c == true)){
                    objData.secondaryApplicantName = applicant.Name;
                    objData.secondaryApplicantId = applicant.Id;
                    objData.secondaryApplicantWillingnessforAccOpening = applicant.Would_you_like_to_open_a_bank_account__c;
                    objData.coborrowerconsentRecived = applicant.CASA_Consent_Received__c;
                    if(String.isNotBlank(applicant.Who_will_repay_the_loan__c)){
                        objData.whoWillRepayLoan = applicant.Who_will_repay_the_loan__c;
                    }
                }
            }
            List<Invoice_Details__c> invoiceDetailsList = new List<Invoice_Details__c>([SELECT Id,Invoice_Amount_incl_discounts__c,Payment_to_be_made__c,Ben_Code_Of_Main_dealer__c FROM Invoice_Details__c WHERE Loan_Application__c =: parentLoanAppId AND Deal_Number__c = : dealId With SECURITY_ENFORCED]);

            List<IHM__c> ihmList = new List<IHM__c>([SELECT Id,Total_IHM_paid_to_dealer_A__c,IHM_Recovery__c  FROM IHM__c WHERE Loan_Application__c =: parentLoanAppId AND Deal_Number__c = : dealId With SECURITY_ENFORCED]);
                    
            List<Benefi__c> lstBenif = new List<Benefi__c>();
            List<Benefi__c> benefiData = new List<Benefi__c>();
            List<Beneficiary_Manufacturer__c> beneMfrData = new List<Beneficiary_Manufacturer__c>();
            if(invoiceDetailsList.size() > 0){
                Id paymentId = invoiceDetailsList[0].Payment_to_be_made__c;
                lstBenif.addAll([SELECT Id, Ben_Code__c,Dealership_Nature__c FROM Benefi__c WHERE Ben_code__c =:  invoiceDetailsList[0].Ben_Code_Of_Main_dealer__c With SECURITY_ENFORCED LIMIT 100]);
                if(paymentId != null && paymentId.getSObjectType().getDescribe().getName() == 'Benefi__c'){
                benefiData.addAll([select Name, Ben_Code__c from Benefi__c where Id=: invoiceDetailsList[0].Payment_to_be_made__c With SECURITY_ENFORCED LIMIT 100]);//CISP-5192
                objData.paymentToBeMade = benefiData.size() > 0 ? benefiData[0].Name +' | '+benefiData[0].Ben_Code__c : '';//CISP-5192
                }
                if(paymentId != null && paymentId.getSObjectType().getDescribe().getName() == 'Beneficiary_Manufacturer__c'){
                beneMfrData.addAll([Select Manufacturer__r.Name,Manufacturer_Ben_Code__c from Beneficiary_Manufacturer__c where Id =:invoiceDetailsList[0].Payment_to_be_made__c WITH SECURITY_ENFORCED LIMIT 100]); //SFTRAC-145
                objData.paymentToBeMade = beneMfrData.size() > 0 ? beneMfrData[0].Manufacturer__r.Name +' | '+beneMfrData[0].Manufacturer_Ben_Code__c : '';//CISP-5192
                }
            }
            objData.invoiceAmountInclDiscount = invoiceDetailsList.size() > 0 ? invoiceDetailsList[0].Invoice_Amount_incl_discounts__c == null ? 0 : invoiceDetailsList[0].Invoice_Amount_incl_discounts__c : 0;
            objData.totalIHMPaidToDealer =  ihmList.size() > 0 ? ihmList[0].Total_IHM_paid_to_dealer_A__c == null ? 0 : ihmList[0].Total_IHM_paid_to_dealer_A__c : 0;
            objData.ihmRecoveryAmount =  ihmList.size() > 0 ? ihmList[0].IHM_Recovery__c == null ? 0 : ihmList[0].IHM_Recovery__c : 0;
            objData.dealershipNature = lstBenif.size() > 0 ? lstBenif[0].Dealership_Nature__c : '';
        }
        return objData;
    }
    
    
    public class BeneficiaryDetailsWrapper{
        @AuraEnabled
        public Id loanDisbursementDetailId;
        @AuraEnabled
        public Id parentLoanAppId;
        @AuraEnabled
        public String dsaName;
        @AuraEnabled
        public Double financeAmount;
        @AuraEnabled
        public String loanAppVehicleSubCategory;
        @AuraEnabled
        public String loanAppVehicleType;
        @AuraEnabled
        public String loanAppProductType;
        @AuraEnabled
        public String loanAppApplicationType;
        @AuraEnabled
        public Boolean paymentToDSA;
        @AuraEnabled
        public Boolean paymentToDealer;
        @AuraEnabled
        public Boolean paymentToBuilder;
        @AuraEnabled
        public String coborrowerName;
        @AuraEnabled
        public Boolean paymentToCoborrower;
        @AuraEnabled
        public String phyMandateDispToKarapakkam;
        @AuraEnabled
        public String bankName;
        @AuraEnabled
        public String accountNumber;
        @AuraEnabled
        public String bankBranchName;
        @AuraEnabled
        public String bankBranchPincode;
        @AuraEnabled
        public String bankIFSCcode;
        @AuraEnabled
        public Decimal dealerPayment;
        @AuraEnabled
        public String paymentOriginatedFrom;
        @AuraEnabled
        public Decimal adjAmount1;
        @AuraEnabled
        public Decimal adjAmount2;
        @AuraEnabled
        public Decimal adjAmount3;
        @AuraEnabled
        public Decimal adjAmount4;
        @AuraEnabled
        public Decimal adjAmount5;
        @AuraEnabled
        public Decimal adjAmount6;
        @AuraEnabled
        public Decimal adjAmount7;
        @AuraEnabled
        public Decimal adjAmount8;
        @AuraEnabled
        public String adjDealNumber1;
        @AuraEnabled
        public String adjDealNumber2;
        @AuraEnabled
        public String adjDealNumber3;
        @AuraEnabled
        public String adjDealNumber4;
        @AuraEnabled
        public String adjDealNumber5;
        @AuraEnabled
        public String adjDealNumber6;
        @AuraEnabled
        public String adjDealNumber7;
        @AuraEnabled
        public String adjDealNumber8;
        @AuraEnabled
        public String customerName1;
        @AuraEnabled
        public String customerName2;
        @AuraEnabled
        public String customerName3;
        @AuraEnabled
        public String customerName4;
        @AuraEnabled
        public String customerName5;
        @AuraEnabled
        public String customerName6;
        @AuraEnabled
        public String customerName7;
        @AuraEnabled
        public String customerName8;
        //CISP-2629-START
        @AuraEnabled
        public String customerCode1;
        @AuraEnabled
        public String customerCode2;
        @AuraEnabled
        public String customerCode3;
        @AuraEnabled
        public String customerCode4;
        @AuraEnabled
        public String customerCode5;
        @AuraEnabled
        public String customerCode6;
        @AuraEnabled
        public String customerCode7;
        @AuraEnabled
        public String customerCode8;
        //CISP-2629-END
        @AuraEnabled
        public String beneficiaryAccNo1;
        @AuraEnabled
        public String beneficiaryAccNo2;
        @AuraEnabled
        public String beneficiaryAccNo3;
        @AuraEnabled
        public String beneficiaryAccNo4;
        @AuraEnabled
        public Decimal beneficiaryAmount1;
        @AuraEnabled
        public Decimal beneficiaryAmount2;
        @AuraEnabled
        public Decimal beneficiaryAmount3;
        @AuraEnabled
        public Decimal beneficiaryAmount4;
        @AuraEnabled
        public String beneficiaryName1;
        @AuraEnabled
        public String beneficiaryName2;
        @AuraEnabled
        public String beneficiaryName3;
        @AuraEnabled
        public String beneficiaryName4;
        @AuraEnabled
        public Decimal totalAdjAmount;
        @AuraEnabled
        public Decimal totalBeneficiaryAmount;
        @AuraEnabled
        public Decimal balanceTransferAmountInRs;
        @AuraEnabled
        public String finalTermReferrerName;
        @AuraEnabled
        public String dealerName;
        @AuraEnabled
        public String loanDisbursementDetailsVehicleSoldBy;
        @AuraEnabled
        public String beneficiaryId1;
        @AuraEnabled
        public String benefiCode;
        @AuraEnabled
        public boolean benefiDisabled;
        @AuraEnabled
        public String primaryApplicantName;
        @AuraEnabled
        public String secondaryApplicantName;
        @AuraEnabled
        public String primaryApplicantId;
        @AuraEnabled
        public String secondaryApplicantId;
        @AuraEnabled
        public Boolean primaryApplicantWillingnessforAccOpening;
        @AuraEnabled
        public Boolean secondaryApplicantWillingnessforAccOpening;
        @AuraEnabled
        public Boolean coborrowerconsentRecived;
        @AuraEnabled
        public Boolean borrowerconsentRecived;
        @AuraEnabled
        public String paymentToBeMade;
        @AuraEnabled
        public Double invoiceAmountInclDiscount;
        @AuraEnabled
        public Double totalIHMPaidToDealer;
        @AuraEnabled
        public Double ihmRecoveryAmount;
        @AuraEnabled
        public String dealershipNature;
        @AuraEnabled
        public Boolean isNewVehicle;
        @AuraEnabled
        public String whoWillRepayLoan;
        //CISP-8762 start
        @AuraEnabled
        public Boolean rcLimitEnabledDealer;
        @AuraEnabled
        public Boolean rcLimitEnabledDSA;
        @AuraEnabled
        public  string vehicleRecordId;
        @AuraEnabled
        public  string finalTermRecordId;
        @AuraEnabled
        public Double financeAmountForRcLimit;
        @AuraEnabled
        public Boolean rcLimitClearedForDealer;
        @AuraEnabled
        public Boolean rcLimitClearedForDSA ;//CISP-8762 end
        @AuraEnabled
        public string dealerBenCode ;//CISP-11627
        @AuraEnabled
        public Final_Term__c finaltermObj;/** CISP-20786*/
        @AuraEnabled
        public String productSegment;/** CISP-20786*/
        @AuraEnabled
        public Decimal requiredLoanAmount;//CISP-12592
        @AuraEnabled
        public Boolean isPACTGenerated; //SFTRAC-2313
    }
    
    
    @AuraEnabled
    public static String getDealerSubDealerName(String parentLoanAppId){
        List<Opportunity> lstOpp = [SELECT Id, AccountId FROM Opportunity WHERE Id =: parentLoanAppId];
        if(!lstOpp.isEmpty()){
            List<Asset> lstAssetRecords = [SELECT Id, Dealer_Sub_dealer_name__r.Name FROM Asset WHERE Dealer_Sub_dealer_name__c =: lstOpp[0].AccountId];
            if(!lstAssetRecords.isEmpty()){
                return lstAssetRecords[0].Dealer_Sub_dealer_name__r.Name;
            }
        }
        return null;
        
    }
     //CISP-13118 start
     @AuraEnabled
     public static Boolean dsaPaymentDisbaling(String loanAppId){
        String bencode;
        List<Final_Term__c> finalTermList = [SELECT Id, Referrer_Name__c,Referrer_Ben_Code__c,Loan_Application__r.LeadSource,Loan_Application__r.Vehicle_Type__c FROM Final_Term__c WHERE Loan_Application__c =: loanAppId WITH SECURITY_ENFORCED LIMIT 1];
        User Usr =[SELECT Id,profile.name,userType FROM User WHERE Id = : UserInfo.getUserId()];
        if(!finalTermList.isEmpty() && finalTermList[0].Referrer_Name__c != null && finalTermList[0].Loan_Application__r.Vehicle_Type__c == 'Used' && finalTermList[0].Loan_Application__r.LeadSource == null){
            bencode = finalTermList[0].Referrer_Ben_Code__c;
            List<DSA_Preferred_BE_Mapping__c> dsaUserdata = [SELECT Id,Preferred_BE_Name__c, Emp_Id__c,Ben_code__c, Ben_name__c FROM DSA_Preferred_BE_Mapping__c WHERE Ben_code__c =:bencode AND Active_Flag__c = true ];
            if(!dsaUserdata.isEmpty() && Usr.profile.name != 'System Administrator'){
                return true;
                }else{
                return false;
                }
            }
         return false;
     } 
      //CISP-13118 end
    
    @AuraEnabled
    public static Documents__c getSellerBankDetails(String loanAppId){
        List<Documents__c> docs = [SELECT Id, Seller_Bank_name__c, Seller_Bank_name__r.Name, 
                                    Seller_Account_number__c, Name_of_Seller_account_holder__c, 
                                    IFSC_code_Seller__c FROM Documents__c WHERE Opportunity_Relation__c = :loanAppId
                                    AND Document_Type__c = 'Seller Bank Details' LIMIT 1];
        if(!docs.isEmpty()){
            return docs[0];
        }
        return null;
    }

    @AuraEnabled
    public static Boolean saveLoanAppTransactionHistory(String loanAppId, String screenName, String dealId){
        try{
            String ownerUserId='00571000000MESXAA4'; //assign User for testing only
            AccountTeamMember accTeamMemberObj;
            Opportunity oppObj = [SELECT Id, Loan_Application_Number__c, AccountId, Product_Type__c  FROM Opportunity WHERE Id =: loanAppId WITH SECURITY_ENFORCED LIMIT 1];
            if(oppObj != null){
                if(oppObj.Product_Type__c=='Two Wheeler'){
                    accTeamMemberObj = [SELECT AccountId, TeamMemberRole, UserId,Level__c, AccountAccessLevel, User.Id FROM AccountTeamMember 
                                        WHERE AccountId =: oppObj.AccountId AND TeamMemberRole = 'CVO' WITH SECURITY_ENFORCED LIMIT 1];
                }
                else if(oppObj.Product_Type__c=='Passenger Vehicles'){
                    accTeamMemberObj = [SELECT AccountId, TeamMemberRole, UserId,Level__c, AccountAccessLevel, User.Id FROM AccountTeamMember 
                                        WHERE AccountId =: oppObj.AccountId AND TeamMemberRole = 'BE' WITH SECURITY_ENFORCED LIMIT 1];
                }

                if(accTeamMemberObj != null){
                    ownerUserId = accTeamMemberObj.User.Id;
                }

                //Save Loan App Tran History details
                Loan_Application_Transaction_History__c appHistory = new Loan_Application_Transaction_History__c();
                appHistory.Module__c = 'Disbursement Request Preparation';
                appHistory.Loan_Application_ID__c = loanAppId;
                appHistory.Screen__c = screenName;
                appHistory.Submitted_Flag__c = false;
                appHistory.New_Owner__c = ownerUserId;
                appHistory.Module_Name__c = 'Disbursement Request Preparation';
                if(oppObj.Product_Type__c == System.Label.Tractor){
                    appHistory.Deal_Number__c = dealId;
                }
                insert appHistory;

                if(appHistory.Id != null){
                    return true;
                }
                else{
                    return false;
                }
            }
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getDisbursementInsuranceDetails', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' - '+e.getStackTraceString() );
        }
        return false;
    }


    @AuraEnabled(cacheable=true)
    public static Decimal calculateDealerPayment(Id loanAppId, String vehicleType, String dealId){
        Decimal dealerPayment = 0;
        String productType = '';
        String vehicleSubCategory = '';
        if(loanAppId != null){
            List<Opportunity> lstOpps = new List<Opportunity>([SELECT Id, Vehicle_Type__c,Product_Type__c, Vehicle_Sub_Category__c, Loan_amount__c FROM Opportunity WHERE Id =:loanAppId AND Vehicle_Type__c = :vehicleType LIMIT 1]);
            productType = lstOpps[0].Product_Type__c == null ? '' : lstOpps[0].Product_Type__c;
            if(productType == System.Label.Tractor){
                List<Vehicle_Detail__c> vehicleList = [ SELECT Id,Vehicle_SubCategory__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanAppId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED limit 1];
                vehicleSubCategory = vehicleList.size() > 0  ? vehicleList[0].Vehicle_SubCategory__c == null ? '' : vehicleList[0].Vehicle_SubCategory__c : '';
            }else{
            vehicleSubCategory = lstOpps[0].Vehicle_Sub_Category__c == null ? '' : lstOpps[0].Vehicle_Sub_Category__c;
            }
            if(!lstOpps.isEmpty()){
                List<IHM__c> lstIHMs = [SELECT  Id, Total_IHM_paid_to_dealer_A__c,Total_amount_customer_paid_to_bank_E__c, Margin_money_to_be_deducted_from_disburs__c FROM IHM__c  WHERE Loan_Application__c =:loanAppId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];

                List<Final_Term__c> finTerm = [SELECT Loan_Amount__c FROM Final_Term__c  WHERE Loan_Application__c = :loanAppId AND Vehicle_Detail__r.Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];

                Decimal ihmMarginMoneyToBeDeductedFromDisbursment = 0;
                Decimal loanAmountExclusive = 0;
                Decimal ihmTotalMoneyPaidToDealer = 0;
                Decimal invoiceAmount = 0;
                Decimal ihmToalAmountPaidToBank = 0;

                if(!lstIHMs.isEmpty()){
                    ihmMarginMoneyToBeDeductedFromDisbursment = lstIHMs[0].Margin_money_to_be_deducted_from_disburs__c != null ? lstIHMs[0].Margin_money_to_be_deducted_from_disburs__c : 0;
                    ihmToalAmountPaidToBank = lstIHMs[0].Total_amount_customer_paid_to_bank_E__c != null ? lstIHMs[0].Total_amount_customer_paid_to_bank_E__c : 0;
                    ihmTotalMoneyPaidToDealer = lstIHMs[0].Total_IHM_paid_to_dealer_A__c != null ? lstIHMs[0].Total_IHM_paid_to_dealer_A__c : 0;
                }
                if(!finTerm.isEmpty()){
                    loanAmountExclusive = Decimal.valueof(finTerm[0].Loan_Amount__c);
                }
                List<Invoice_Details__c> invoiceDetails = new List<Invoice_Details__c>([Select Id,Invoice_Amount_incl_discounts__c From Invoice_Details__c Where Loan_Application__c =:loanAppId AND Deal_Number__c =: dealId]);
                if(!invoiceDetails.isEmpty() && invoiceDetails[0].Invoice_Amount_incl_discounts__c != null){
                    invoiceAmount = invoiceDetails[0].Invoice_Amount_incl_discounts__c;
                }

                if(String.isNotBlank(vehicleType) && vehicleType.equalsIgnoreCase('Used')){
                    dealerPayment = loanAmountExclusive - ihmMarginMoneyToBeDeductedFromDisbursment;
                } else if(String.isNotBlank(vehicleType) && vehicleType.equalsIgnoreCase('New')){
                    dealerPayment = invoiceAmount - ihmTotalMoneyPaidToDealer;
                }

                if(vehicleSubCategory.equalsIgnoreCase('UPD') && (productType == System.Label.PassengerVehicles || productType == Label.Tractor) && (vehicleType.equalsIgnoreCase('Used') || vehicleType.equalsIgnoreCase('Refinance'))){
                    dealerPayment = loanAmountExclusive - ihmTotalMoneyPaidToDealer;
                }else if((productType == System.Label.PassengerVehicles || productType == Label.Tractor) && (vehicleType.equalsIgnoreCase('Used') || vehicleType.equalsIgnoreCase('Refinance'))){
                    dealerPayment = loanAmountExclusive;
                }
            }
        }
        return dealerPayment;
    }

    @AuraEnabled
    public static List<Benefi__c> getBenifRecord(String recordId){
        return [SELECT Id, Ben_Code__c,Name FROM Benefi__c WHERE Id =:recordId With SECURITY_ENFORCED LIMIT 1];
    }
    
    @AuraEnabled
    public static Boolean isAcctNumberPresentInBenMaster(String acctNoToCheck){
        List<Benefi__c> benMasterList = new List<Benefi__c>([Select Id From Benefi__c Where (Indusind_AcNo__c =:acctNoToCheck OR Other_AcNo__c=:acctNoToCheck OR Indusind_AcNo_Incentive__c=:acctNoToCheck OR Other_AcNo_Incentive__c=:acctNoToCheck)]);
        if(benMasterList.size() > 0){
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static BeneficiaryDetailsWrapper isCasaConsentReceived(String parentLoanAppId){
        BeneficiaryDetailsWrapper objData = new BeneficiaryDetailsWrapper();
        List<Applicant__c> lstApplicant = new List<Applicant__c>([SELECT Id, Name,Applicant_Type__c,Would_you_like_to_open_a_bank_account__c,CASA_Consent_Received__c FROM Applicant__c WHERE Opportunity__c =: parentLoanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);
        for(Applicant__c applicant : lstApplicant){
            if(applicant.Applicant_Type__c == 'Borrower'){
                objData.borrowerconsentRecived = applicant.CASA_Consent_Received__c;
            }
            else if(applicant.Applicant_Type__c == 'Co-borrower'){
                objData.coborrowerconsentRecived = applicant.CASA_Consent_Received__c;
            }
        }
        return objData;
    }

/* @Method:     isPaymentRequestGenerated
* @Created by:  Rajat Jaiswal
* @Description: This method used for verifying that Payment Request generated or not.
* @Param:       String - loanApplicationId
* @Return:      Boolean
*/
    @AuraEnabled
    public static Boolean isPaymentRequestGenerated(String loanApplicationId, String dealId){
        try {
            List<Opportunity> opportunityList = [Select Id,Payment_Request_Generation_Date__c,Product_Type__c From Opportunity Where Id=:loanApplicationId WITH SECURITY_ENFORCED];
            if (opportunityList.size()> 0) {
                if(opportunityList[0].Product_Type__c == System.Label.Tractor){
                    if(String.isNotBlank(dealId)){
                        List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id From Vehicle_Detail__c WHERE Loan_Application__c =: loanApplicationId AND Payment_requested__c != null AND Deal_Number__c =: dealId LIMIT 1]);
                        if(vehicleList.size() > 0){
                            return true;
                        }
                    }else{
                        List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id From Vehicle_Detail__c WHERE Loan_Application__c =: loanApplicationId AND Payment_requested__c != null LIMIT 1]);
                        if(vehicleList.size() > 0){
                            return true;
                        }
                    }
                }else if (opportunityList[0].Payment_Request_Generation_Date__c!=null) {
                    return true;
                }
            }
            return false;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'isPaymentRequestGenerated', System.Label.Apex, e, loanApplicationId);
        }
        return false;
    }

    @AuraEnabled
    public static Boolean isPACTLMSIntegrationLogGenerated(String loanApplicationId, String dealId){
        try {
            Boolean pactIntegrationStatus = IND_RevokeController.isPACTLMSIntegrationLogFailed(loanApplicationId,dealId);
            if (!pactIntegrationStatus) {
                return false;
            }
            return true;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'isPACTLMSIntegrationLogGenerated', System.Label.Apex, e, loanApplicationId);
        }
        return true;
    }
    
    //CISP-2490 -- start
    /* @Method:     isInsuranceProductSelected
	* @Created by:  Vishal Gadhave
	* @Description: This method used for checking Which insurance product is selected (only GPA or Combo).
	* @Param:       String - loanApplicationId
	* @Return:      Boolean
	*/
    @AuraEnabled
    public static boolean isInsuranceProductSelected(String loanApplicationId){
        try {
            List<InsuranceDetails__c> insurList = [select Id,Name from InsuranceDetails__c Where Loan_Application__c=:loanApplicationId WITH SECURITY_ENFORCED];
            for(InsuranceDetails__c insur : insurList) {
                if(insur.Name == 'GPA' || insur.Name == 'COMBO' || insur.Name == 'LI_EMI') {
                    return true;
                }
            }
            return false;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', 'isInsuranceProductSelected', System.Label.Apex, e, loanApplicationId);
        }
        return false;
    }
    
    /* @Method:     isDocumentPresentForInsuranceApplication
	* @Created by:  Vishal Gadhave
	* @Description: This method used to check if insurance document is present on document.
	* @Param:       String - loanApplicationId
	* @Return:      Boolean
	*/
    @AuraEnabled
    public static boolean isDocumentPresentForInsuranceApplication(String loanApplicationId, String dealId){
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        List<Documents__c> docList = new List<Documents__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            docList = [SELECT Id,Name, applicant_Type__c, is_Active__c, Document_Type__c 
                        FROM Documents__c 
                        WHERE Opportunity_Relation__c =: loanApplicationId AND is_Active__c = true AND Document_Type__c ='Insurance Application' AND Vehicle_Detail__c =: VehicleLst[0].Id ];
        }else{
            docList = [SELECT Id,Name, applicant_Type__c, is_Active__c, Document_Type__c 
                        FROM Documents__c 
                        WHERE Opportunity_Relation__c =: loanApplicationId AND is_Active__c = true AND Document_Type__c ='Insurance Application' ];
        }

        if(docList.size() > 0 && !docList.isempty()) {
            return true;
        }
        return false;
    }
    //CISP-2490 -- end
    
    /* @Method:     isTVRCaseCompleted
    * @Created by:  Rajat Jaiswal
    * @Description: This method used for verifying that TVR Case completed or not.
    * @Param:       String - loanApplicationId
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean isTVRCaseCompleted(String loanApplicationId){
        try {
            List<Case> tvrCases = [SELECT Id, Status FROM Case WHERE RecordType.Name='TVR' AND Loan_Application__c=:loanApplicationId AND Loan_Application__r.Product_Type__c = 'Passenger Vehicles' WITH SECURITY_ENFORCED LIMIT 1];
            if(!tvrCases.isEmpty()){
                if(tvrCases[0].Status.equals('Pass')){
                    return true;
                }else{
                    return false;
                }
            }                       
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'isTVRCasecompleted', System.Label.Apex, e, loanApplicationId);
        }
        return false;
    }
    /* @Method:     isTVRCaseCompleted
    * @Created by:  Gaurav Rawat
    * @Description: This method used check loan application is revoked or Not.
    * @Param:       String - loanApplicationId
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean isRevokedLead(String loanApplicationId){
        try {
            if(!String.isBlank(loanApplicationId)){
                Opportunity opp = [Select Id,Is_Revoked__c from Opportunity WHERE Id =: loanApplicationId];
                if(opp.Is_Revoked__c == true){
                    return true;
                }
            }                    
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'isRevokedLead', System.Label.Apex, e, loanApplicationId);
        }
        return false;
    }
    /* @Method:     getDealNumberDetails
    * @Created by:  Gaurav Rawat
    * @Description: This method is returning deal number record details.
    * @Param:       String - loanApplicationId, dealId
    * @Return:      Deal_Number__c
    */
    @AuraEnabled
    public static Deal_Number__c getDealNumberDetails(String loanApplicationId, String dealId){
        try {
            if(String.isNotBlank(loanApplicationId) && String.isNotBlank(dealId)){
                List<Deal_Number__c> dealNumberList = new List<Deal_Number__c>();
                dealNumberList = [Select id,Loan_Application__r.StageName, Loan_Application__r.Product_Type__c,Sub_Stage__c from Deal_Number__c Where id =: dealId LIMIT 1];
                if(dealNumberList.size() > 0){
                    return dealNumberList[0];
                }
            }                    
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getDealNumberDetails', System.Label.Apex, e, loanApplicationId);
        }
        return null;
    }
    //SFTRAC-163
    @AuraEnabled
    public static CaseFIWrapper getFICaseListRecord(String loanApplicationId,String dealId){
        try {
            CaseFIWrapper caseFiWrapper = new CaseFIWrapper();
            List<ApplicantCibilWrapper> tempcbrWrapperList = new List<ApplicantCibilWrapper>();
            List<Case> csList = [SELECT Id, Status, OwnerId FROM Case WHERE RecordType.Name='FI' AND Loan_Application__c =:LoanApplicationId AND RejectedFI__c = false];
            Map<Id,Case> caseIdVsCaseMap = new Map<Id,Case>();
            Boolean tempIsFieldInvsNotCompleted = false;
            for(Case caseRec : csList){
                caseIdVsCaseMap.put(caseRec.Id, caseRec);
            }
            List<Case> tempcaseList = new List<Case>();
            List<Field_Investigation__c> tempieldInvestigationList = new List<Field_Investigation__c>();
            //case and FI
            Set<Id> caseIdSet = caseIdVsCaseMap.keySet();
            List<Field_Investigation__c> fieldInvestigationList = [SELECT Id, Case__c, Residence_FI_completion_time__c, Office_FI_Completion_Time__c,RecordType.Name,FI_Feedback__c FROM Field_Investigation__c WHERE case__c IN :caseIdSet];
            for(Field_Investigation__c fieldInvRecord : fieldInvestigationList){
                if(fieldInvRecord.RecordType.Name == 'Office'){
                    if(fieldInvRecord.Office_FI_Completion_Time__c != null && fieldInvRecord.Office_FI_Completion_Time__c < (Date.today()-30)){
                        tempcaseList.add(caseIdVsCaseMap.get(fieldInvRecord.Case__c));
                        tempieldInvestigationList.add(fieldInvRecord);
                    } else if(fieldInvRecord.Office_FI_Completion_Time__c == null){
                        tempIsFieldInvsNotCompleted = true;
                    }
                }else{
                    if(fieldInvRecord.Residence_FI_completion_time__c != null && fieldInvRecord.Residence_FI_completion_time__c < (Date.today()-30)){
                        tempcaseList.add(caseIdVsCaseMap.get(fieldInvRecord.Case__c));
                        tempieldInvestigationList.add(fieldInvRecord);
                    }else if(fieldInvRecord.Residence_FI_completion_time__c == null){
                        tempIsFieldInvsNotCompleted = true;
                    }
                }
            }
            //cam record
            Boolean tempIsCamSucess = false;
            Boolean tempIsCamApprovalNotCompleted = false;
            if(loanApplicationId != null){
                CAM__c camRecord  =  [SELECT Id,CAM_Approval_Date__c FROM CAM__c WHERE Loan_Application__c =:loanApplicationId LIMIT 1];
                if(camRecord != null){
                    if(camRecord.CAM_Approval_Date__c!=null && camRecord.CAM_Approval_Date__c<(Date.today()-30)){
                        tempIsCamSucess = true;
                    }else if(camRecord.CAM_Approval_Date__c == null){
                        tempIsCamApprovalNotCompleted = true;
                    }
                }
            }
            //cibil record
            List<Applicant__c> coBorrowerApplicantList = new List<Applicant__c>();
            for(Applicant__c applicant : [SELECT Id,Name,Applicant_Type__c,(SELECT Id,CIBIL_Pull_Date__c FROM CIBIL_Details__r LIMIT 1) FROM Applicant__c WHERE opportunity__c =:loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]) {
                if(!applicant.CIBIL_Details__r.isEmpty()){
                    if(applicant?.CIBIL_Details__r[0].CIBIL_Pull_Date__c < (Date.today()-30)){
                        ApplicantCibilWrapper wprObj = new ApplicantCibilWrapper();
                        wprObj.applicantId = applicant.Id;
                        wprObj.cibilRecord = applicant?.CIBIL_Details__r[0];
                        wprObj.nameAndType = applicant.Applicant_Type__c + '( '+ applicant.Name + ' )';
                        tempcbrWrapperList.add(wprObj);
                    }                                 
                }
            }
            // asset details
            List<Asset_Verification__c> assetVerificationFailedList = new List<Asset_Verification__c>();
            List<Asset_Verification__c> assetVerificationList = CaseWithoutSharingUpdate.getAssetVerRecord(loanApplicationId,dealId);
            Boolean tempIsAssetVerFailed = false;
            for(Asset_Verification__c assetVeriRec : assetVerificationList){
                if(assetVeriRec.Date_of_submission__c != null  && assetVeriRec.Date_of_submission__c < (Date.today()-30)){
                    assetVerificationFailedList.add(assetVeriRec);
                }else if(assetVeriRec.Date_of_submission__c == null){
                    tempIsAssetVerFailed = true;
                }
            }
            caseFiWrapper.caseList = tempcaseList;
            caseFiWrapper.fieldInvsList = tempieldInvestigationList;
            caseFiWrapper.isCamSucess = tempIsCamSucess;
            caseFiWrapper.cbrWrapperList = tempcbrWrapperList;
            caseFiWrapper.isFieldInvsNotCompleted = tempIsFieldInvsNotCompleted;
            caseFiWrapper.isCamApprovalNotCompleted = tempIsCamApprovalNotCompleted;
            caseFiWrapper.assetVerFailedList = assetVerificationFailedList;
            caseFiWrapper.isAssetVerFailed = tempIsAssetVerFailed;
            return caseFiWrapper;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getFICaseListRecord', System.Label.Apex, e, loanApplicationId);
            return null;
        }
    }
    //SFTRAC-163
    public class CaseFIWrapper{
        @AuraEnabled public List<Case> caseList {get;set;}
        @AuraEnabled public List<Field_Investigation__c> fieldInvsList {get;set;}
        @AuraEnabled public Boolean isCamSucess {get;set;}
        @AuraEnabled public String borrowerId {get;set;}
        @AuraEnabled public CIBIL_Details__c borrowerCibilRecord;
        @AuraEnabled public List<ApplicantCibilWrapper> cbrWrapperList {get;set;}
        @AuraEnabled public Boolean isFieldInvsNotCompleted {get;set;}
        @AuraEnabled public Boolean isCamApprovalNotCompleted {get;set;}
        @AuraEnabled public List<Asset_Verification__c> assetVerFailedList {get;set;}
        @AuraEnabled public Boolean isAssetVerFailed {get;set;}
    }
    //SFTRAC-163
    public class ApplicantCibilWrapper{
        @AuraEnabled public String applicantId {get;set;}
        @AuraEnabled public CIBIL_Details__c cibilRecord {get;set;}
        @AuraEnabled public String nameAndType {get;set;}
    }

    //SFTRAC-163 
    @AuraEnabled
    public static String updateCaseFIRecords(List<Case> caseList, List<Field_Investigation__c> fieldInvsList, String loanApplicationId){
        try {
            if(caseList.size() > 0){
                String caseRecId = caseList[0].Id;
                List<CaseHistory> caseHistoryList = [SELECT Id, CreatedById,CreatedBy.UserRole.Name from CaseHistory where CaseId =: caseRecId Order by CreatedDate ASC LIMIT 1];
                if(caseHistoryList.size()>0){
                String createdById = caseHistoryList[0].CreatedById;
                List<OpportunityTeamMember> otmList = [SELECT Id,UserId, Name,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId =:loanApplicationId AND UserId =:createdById LIMIT 1];
                if(otmList.size()==0){
                    List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>();
                    OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                    oppTeam.OpportunityId= loanApplicationId;
                    oppTeam.UserId=createdById;
                    oppTeam.TeamMemberRole= caseHistoryList[0].CreatedBy.UserRole.Name;
                    oppTeam.OpportunityAccessLevel = 'Edit'; 
                   opptyTeams.add(oppTeam);
                   CaseWithoutSharingUpdate.insertopptyTeamMembers(opptyTeams);
                }
                for(Case caseRec : caseList){
                caseRec.Status = 'FI-Unassigned';
                caseRec.OwnerId = createdById;
                }
                for(Field_Investigation__c fieldInvRec :fieldInvsList){
                    fieldInvRec.Remarks__c = null;
                    fieldInvRec.FI_Status__c = 'Pending';
                    if(fieldInvRec.RecordType.Name == 'Office'){
                        fieldInvRec.Office_FI_Completion_Time__c = null;
                        fieldInvRec.Office_FI_Status__c = null;
                    }else{
                    fieldInvRec.Residence_FI_completion_time__c = null;
                    fieldInvRec.Residence_FI_Status__c = null;
                    }
                }
                CaseWithoutSharingUpdate.updateCaseList(caseList);
                CaseWithoutSharingUpdate.updateFiList(fieldInvsList);
                }
            }
            return 'success';
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'updateCaseFIRecords', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    //SFTRAC-163
    @AuraEnabled
    public static String getCamRecord(String loanApplicationId){
        try {
            if(loanApplicationId != null){
                CAM__c camRecord  =  [SELECT Id FROM CAM__c WHERE  Loan_Application__c =:loanApplicationId LIMIT 1];
                if(camRecord != null){
                    return camRecord.Id;
                }
            }
            return null;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getCamRecord', System.Label.Apex, e, loanApplicationId);
            return null;
        }
    }
    @AuraEnabled
    public static String updateAssetVerAndCase(List<Asset_Verification__c> assetVerList, String loanApplicationId){
        try {
            if(assetVerList.size() > 0){
                Set<Id> caseIds = new Set<Id>();
                for(Asset_Verification__c assetVer : assetVerList){
                    assetVer.Date_of_submission__c = null;
                    caseIds.add(assetVer.case__c);
                }
                update assetVerList;
                if(caseIds!=null){
                    List<Case> caseList = [SELECT Status,Priority FROM Case where Id IN :caseIds];
                    if(caseList.size() > 0){
                        for(Case caseRec : caseList){
                            caseRec.Status = 'New';
                            caseRec.Priority = 'Medium';
                        }
                        CaseWithoutSharingUpdate.updateCaseList(caseList);
                    }
                }
            }
            return 'success';
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'updateAssetVerAndCase', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean isChildLeadClosed(String loanApplicationId){
        try {
            if(!String.isBlank(loanApplicationId)){
                Opportunity opp = [Select Id,Deal_Number__c from Opportunity WHERE Id =: loanApplicationId];
                if(opp.Deal_Number__c != null){
                    List<Opportunity> childOpp = [Select Id,Parent_Deal_number__c,Deal_Number__c,Payment_Request_Generation_Date__c from Opportunity WHERE Parent_Deal_number__c =: opp.Deal_Number__c LIMIT 1];
                    if(childOpp.size()>0){
                        if(childOpp[0].Payment_Request_Generation_Date__c == null){
                            return true;
                        }
                    }
                    return false;
                }
                return false;
            }                    
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'isChildLeadClosed', System.Label.Apex, e, loanApplicationId);
        }
        return false;
    }

@AuraEnabled
    public static String allIrrDeviationApproved(String camId,String loanApplicationId){ // CISP-20786
        String role;
        String userName;
    try{
        List<Deviation__c> deviationList = [Select Id,Is_IRR_Deviation__c,Approval_Status__c,Parent_CAM__r.Loan_Application__r.AccountId,Role__c  from Deviation__c where Parent_CAM__c =:camId and Is_IRR_Deviation__c = true and Approval_Status__c !='Approved'];
        Map<String,String> deviationMap = new Map<String,String>();
        if(deviationList!=null && !deviationList.isEmpty()){
            List<String> RoleList = new List<String>();
            RoleList = deviationList[0].Role__c.split(',');
            String accId=deviationList[0].Parent_CAM__r.Loan_Application__r.AccountId;               
            List<AccountTeamMember> accountTeamMemberList = [SELECT Id ,TeamMemberRole,User.Name, Level__c ,Account.id FROM AccountTeamMember WHERE Account.id=:accId  AND TeamMemberRole IN:RoleList WITH SECURITY_ENFORCED];
            if(!accountTeamMemberList.isEmpty()){
                deviationMap.put('isSuccess','true');
                deviationMap.put('role',accountTeamMemberList[0].TeamMemberRole);
                deviationMap.put('userName',accountTeamMemberList[0].User.Name);
                return JSON.serialize(deviationMap);
            }
        }
        deviationMap.put('isSuccess','false');
        return JSON.serialize(deviationMap);
    }
    catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'allIrrDeviationApproved', System.Label.Apex, ex,loanApplicationId);
        throw new IND_Exception(ex.getMessage());   
    }
}
@AuraEnabled // CISP-20786
    public static List<Deviation__c> getIrrDeviationsForApprovals(String camID){
        try{
            List<Deviation__c> lstdeviation1=[SELECT Id,Name,Parent_CAM__c,Is_IRR_Deviation__c FROM Deviation__c WHERE Parent_CAM__c=:camID AND Is_IRR_Deviation__c = true WITH SECURITY_ENFORCED];          
            if(lstdeviation1.size()>0){
                return lstdeviation1;
            }
            return null;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getIrrDeviationsForApprovals', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camID LIMIT 1].Loan_Application__c);
            return null;
        }
    } 

    @AuraEnabled
    public static Boolean checkCIBILFetchDate(String loanApplicationId, String dealId){
    try{
        List<Vehicle_Detail__c> vehiObjList = new List<Vehicle_Detail__c>();
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        if(opp.Product_Type__c == 'Tractor'){
            List<CIBIL_Details__c> cibilList = [SELECT Id,CIBIL_Pull_Date__c from CIBIL_Details__c where Applicant__r.Opportunity__c =:loanApplicationId and Applicant__r.Applicant_Type__c ='Borrower' and Applicant__r.In_Active_Applicant__c = false];
            if(dealId != null){
                vehiObjList = [SELECT ID, Deal_Number__c,MFC_Valuation_Report_Date__c FROM Vehicle_Detail__c WHERE Id =:loanApplicationId AND Deal_Number__c =: dealId LIMIt 1];
            }else{
             vehiObjList = [SELECT ID, Deal_Number__c,MFC_Valuation_Report_Date__c FROM Vehicle_Detail__c WHERE Id =:loanApplicationId AND MFC_Valuation_Report_Date__c != null order by MFC_Valuation_Report_Date__c asc LIMIt 1];
            }
            if(cibilList.size() >0){
                if(cibilList[0].CIBIL_Pull_Date__c != null){
                    Date todayDate =  System.today();
                    Integer days = (cibilList[0].CIBIL_Pull_Date__c.date()).daysBetween(todayDate);
                    if(days > 30)
                        return true;
                }
            }else if(vehiObjList.size() >0){
                if(vehiObjList[0].MFC_Valuation_Report_Date__c != null){
                    Date todayDate =  System.today();
                    Integer days = (vehiObjList[0].MFC_Valuation_Report_Date__c.date()).daysBetween(todayDate);
                    if(days > 90)
                        return true;
                }
            }
        }else{
            return false;
        }
        return false;
    }
    catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'getInvoiceRecord', System.Label.Apex, ex,loanApplicationId);
        throw new IND_Exception(ex.getMessage());   
    }
}
}