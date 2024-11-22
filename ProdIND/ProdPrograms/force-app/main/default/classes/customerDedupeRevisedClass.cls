public without sharing class customerDedupeRevisedClass {

    @AuraEnabled
    public static void withdrawnLeadBasedOnDecision(String leadNoToBeWithdrawn,String decision, String appId){
        try {
            List<String> lstOfLeadNo = new List<String>();
            Set<String> setOfUniqueNo = new Set<String>();
            if(leadNoToBeWithdrawn.contains(',')){
                lstOfLeadNo = leadNoToBeWithdrawn.split(',');
                setOfUniqueNo = new Set<String>(lstOfLeadNo);
            }else{
                setOfUniqueNo.add(leadNoToBeWithdrawn);
            }
            List<Opportunity> oppList = [Select Id ,Lead_Number__c from Opportunity where Lead_Number__c In : setOfUniqueNo];
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    opp.StageName = 'Withdrawn';
                }
                database.update(oppList, false);
            }
            List<Applicant__c> appList = [SElect Id,IsTwFound__c from Applicant__c where Id =: appId limit 1];
            if(!appList.isEmpty()){
                appList[0].IsTwFound__c = decision;
                update appList;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('customerDedupeRevisedClass', 'withdrawnLeadBasedOnDecision', System.Label.Apex, e);
        }
    }
    @AuraEnabled
    public static void withdrawnLeads(List<Opportunity> oppList){
        try{
            for(Opportunity opp : oppList){
                opp.stageName = 'Withdrawn';
            }
            update oppList;

        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('customerDedupeRevisedClass', 'withdrawnLeads', System.Label.Apex, e);
        }
    }
    @AuraEnabled
    public static void updateApplicantRecord(String app){
        try{
           List<Applicant__c> appList = [SELECT Id,IsTWMatchLeadFound__c from Applicant__c where Id =: app limit 1];
           if(!appList.isEmpty()){
                appList[0].IsTWMatchLeadFound__c = true;
                update appList;
           }

        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('customerDedupeRevisedClass', 'updateApplicantRecord', System.Label.Apex, e);
        }
    }
    @AuraEnabled
    public static void updateApplicantIsAllRecordValid(String app){
        try{
           List<Applicant__c> appList = [SELECT Id,isAllRowSelected__c from Applicant__c where Id =: app limit 1];
           if(!appList.isEmpty()){
                appList[0].isAllRowSelected__c = true;
                update appList;
           }

        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('customerDedupeRevisedClass', 'updateApplicantIsAllRecordValid', System.Label.Apex, e);
        }
    }
    @AuraEnabled
    public static void salesUserValidateAnyCode(String applicantId){
        try {
            List<Applicant__c> appList = [SELECT Id,isCodeValidateBySalesUser__c from Applicant__c where Id =: applicantId limit 1];
            if(!appList.isEmpty()){
                 appList[0].isCodeValidateBySalesUser__c = true;
                 update appList;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('customerDedupeRevisedClass', 'salesUserValidateAnyCode', System.Label.Apex, e);
        }
    }
    @AuraEnabled
    public static void updateJourneyStop(String leadNo){
        try {
            List<Opportunity> oppList = [Select Id ,JourneyStopScenarioFound__c from Opportunity where Id =:leadNo LIMIT 1];
            if(!oppList.isEmpty()){
                oppList[0].JourneyStopScenarioFound__c = true;
                update oppList;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('customerDedupeRevisedClass', 'updateJourneyStop', System.Label.Apex, e);
        }
    }

    
    //Trade_Certificate_Fee_master__c
    /*
* @Method:      TradeCertificateValidation
* @Created by:  Raj Gupta.
* @Description: This method is use to give TradeCertificate List of based on agent BL code.
* @Param:       None
* @Return:      List of TradeCertificateTradeCertificate based on agent BL code
*/
    @AuraEnabled
    public static Decimal TradeCertificateValidation(String loanApplicationId)//,String fee)
    {
        try {
            String vehicleCategoryCode; 
            Opportunity opp =  [select id, Agent_BL_code__c,Product_Type__c,Vehicle_Type__c from Opportunity where Id =: loanApplicationId WITH SECURITY_ENFORCED];
            VehicleTypeCategory__mdt[] vehicleTypeCategory = VehicleTypeCategory__mdt.getAll().values();
            for (VehicleTypeCategory__mdt idKey : vehicleTypeCategory) {
                if((idKey.vehicleType__c==opp.Vehicle_Type__c)&&(idKey.productType__c==opp.Product_Type__c)){
                    system.debug('inside the if');
                    vehicleCategoryCode =idKey.Product_Code__c;
                }               
            }  
            Trade_Certificate_Fee_master__c[] tradeCertificate = [select id,Fee__c 
                                                                  from Trade_Certificate_Fee_master__c where Active_Flag__c = true and Bl_Code__r.Bl_Code__c =: opp.Agent_BL_code__c 
                                                                  and  ProductCode__r.ProductCode =: vehicleCategoryCode WITH SECURITY_ENFORCED limit 1];
            Decimal feeAmount=0;
            if(!tradeCertificate.isEmpty()){
                feeAmount=tradeCertificate[0].Fee__c!=null ? tradeCertificate[0].Fee__c: 0;//CISP-2894
            }
            
            return feeAmount;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FinalTermscontroller', 'dsmNameData', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

}