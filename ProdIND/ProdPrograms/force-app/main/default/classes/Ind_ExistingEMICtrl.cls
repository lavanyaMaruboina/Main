public with sharing class Ind_ExistingEMICtrl {

    @AuraEnabled
    public static existingEMIResponseWrapper loadExistingEMIData(String loanApplicationId, String applicantId){
        try {
            Opportunity oppObj=[ SELECT Product_Type__c,StageName,Customer_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
            List<Applicant__c> currentApplicant = [select id, FOIR__c,Rental_Expense__c,Other_Obligation__c,Name, Is_Existing_EMI_Submitted__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c, Is_RUN_EMI_Assessed__c,Applicant_type__c from Applicant__c where id =: applicantId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
            List<Documents__c> docList = [Select Id, Document_Type__c from Documents__c where Document_Type__c= 'Customer Bank Statement' and Applicant__c =: applicantId WITH SECURITY_ENFORCED LIMIT 1];
            List<Income_Details__c> indLst = [SELECT Id,Income__c FROM Income_Details__c WHERE Applicant__c=:applicantId LIMIT 1];
           
            existingEMIResponseWrapper existingEMIResponseObj = new existingEMIResponseWrapper();
            if(!(indLst.size() > 0) ){
                existingEMIResponseObj.monthlyIncome  = 0;
            }else if(indLst[0].Income__c!=null){
                existingEMIResponseObj.monthlyIncome  = Decimal.valueOf((indLst[0]?.Income__c/12)?.round());
            }else{
                existingEMIResponseObj.monthlyIncome = 0;
            }
            existingEMIResponseObj.documentRecordDetails = docList;
            existingEMIResponseObj.isHaveBankAccount = currentApplicant[0].Do_you_have_a_bank_account__c;
            existingEMIResponseObj.isHaveIBLBankAccount = currentApplicant[0].Do_you_have_a_bank_account_with_IBL__c;
            existingEMIResponseObj.rentalExpense = currentApplicant[0]?.Rental_Expense__c;
            existingEMIResponseObj.otherObligation = currentApplicant[0]?.Other_Obligation__c;
            existingEMIResponseObj.foirPercent = currentApplicant[0]?.FOIR__c;
            //existingEMIResponseObj.isExistingEMISubmitted = currentApplicant[0].Is_Existing_EMI_Submitted__c;
            if(oppObj.StageName != 'Income Details'){
                existingEMIResponseObj.isExistingEMISubmitted = true;
            }
            existingEMIResponseObj.isRUNEMIAccessed = currentApplicant[0].Is_RUN_EMI_Assessed__c;
            existingEMIResponseObj.applicantType = currentApplicant[0].Applicant_type__c;

            if(oppObj.Product_Type__c == 'Passenger Vehicles' || oppObj.Product_Type__c == 'Two Wheeler' || (oppObj.Product_Type__c == System.Label.Tractor && oppObj.Customer_Type__c == 'Non-Individual' && currentApplicant[0].Applicant_Type__c != System.Label.Borrower) || (oppObj.Product_Type__c == System.Label.Tractor && oppObj.Customer_Type__c == 'Individual')){
                List<Existing_EMI__c> emiDetail= [select Id, EMI__c, Loan_Type__c, Lower_EMI_Limit__c, Outstanding_Amount__c, Upper_EMI_Limit__c from Existing_EMI__c where Applicant_Id__c=:applicantId WITH SECURITY_ENFORCED];
                List<Retry_Count__c> retryCountList=[Select Id, Count__c, Applicant_type__c from Retry_Count__c where Service_Name__c='RUNEMIEngine' and Applicant__c=:applicantId WITH SECURITY_ENFORCED limit 1]; 
                
                existingEMIResponseObj.existingEMIDetails = emiDetail;
                if(!retryCountList.isEmpty()){
                    existingEMIResponseObj.retryCountDetails = retryCountList;
                } else{
                    existingEMIResponseObj.retryCountDetails = null;
                }
            }

            return existingEMIResponseObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class existingEMIResponseWrapper{
        @AuraEnabled public List<Existing_EMI__c> existingEMIDetails;
        @AuraEnabled public List<Documents__c> documentRecordDetails;
        @AuraEnabled public List<Applicant__c> applicantRecordDetails;
        @AuraEnabled public List<Retry_Count__c> retryCountDetails;
        @AuraEnabled public Boolean isExistingEMISubmitted {get;set;}
        @AuraEnabled public Boolean isHaveBankAccount {get;set;}
        @AuraEnabled public Boolean isHaveIBLBankAccount {get;set;}
        @AuraEnabled public Boolean isRUNEMIAccessed {get;set;}
        @AuraEnabled public String applicantType {get;set;}
        @AuraEnabled public Decimal rentalExpense {get;set;}
        @AuraEnabled public Decimal otherObligation {get;set;}
        @AuraEnabled public Decimal monthlyIncome {get;set;}
        @AuraEnabled public Decimal foirPercent {get;set;}

    }

    @AuraEnabled
    public static existingEMIResponseWrapper getExistingEMISubmittedValue(String loanApplicationId){
        try {
            existingEMIResponseWrapper existingEMIResponseObj = new existingEMIResponseWrapper();

            List<Applicant__c> appList = [select Id, Is_Existing_EMI_Submitted__c, Applicant_Type__c from Applicant__c where Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            
            existingEMIResponseObj.applicantRecordDetails = appList;
            return existingEMIResponseObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Object> getAPIEligibityCount(String applicantId){
        try {
            Map<String,Object> mapOfApiData = new Map<String,Object>();
            List<Applicant__c> oppoId=[Select Id,Opportunity__c from Applicant__c where Id=:applicantId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
            List<Retry_Count__c> apiCount=[Select Id,Count__c from Retry_Count__c where Service_Name__c='RUNEMIEngine' and Loan_Application_Id__c=:oppoId[0].Opportunity__c and User_Id__c=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
            if(apiCount.size()>0){
                mapOfApiData.put('EMICOUNTER',apiCount[0].Count__c);
               
            }
            else{
                mapOfApiData.put('EMICOUNTER',0);
            }
            return mapOfApiData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateRetryCount(String applicantId, String loanAppId){
        try{
            System.debug('applicantId : '+applicantId);
            if(loanAppId != null ) {
                List<Applicant__c> applicantObj=[Select Id,Applicant_Type__c from Applicant__c where Id=:applicantId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
                Retry_Count__c retryCount = new Retry_Count__c();
                List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanAppId AND Applicant__c =:applicantId AND Service_Name__c ='RUNEMIEngine' AND Module__c = 'Existing EMI' WITH SECURITY_ENFORCED];
                System.debug('retryCountList Existing EMI::'+retryCountList);
                if(retryCountList.isEmpty() && !applicantObj.isEmpty() ) {
                    retryCount.Loan_Application_Id__c = loanAppId;
                    retryCount.Service_Name__c = 'RUNEMIEngine';
                    retryCount.Applicant__c = applicantId;
                    retryCount.Module__c = 'Existing EMI';
                    retryCount.Applicant_Type__c = applicantObj[0].Applicant_Type__c;
                    retryCount.Count__c = 1;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable()) {
                        insert retryCount;
                    }
                    return 'Success';
                } else {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Retry_Count'); 
                    //If number of attempts are greater than predefined number of attempts.
                    Retry_Count__c  count = [Select Count__c from Retry_Count__c WhERE Loan_Application_Id__c =: loanAppId AND Applicant__c =:applicantId AND Service_Name__c ='RUNEMIEngine' AND Module__c = 'Existing EMI' WITH SECURITY_ENFORCED limit 1];
                    System.debug('retry count::'+count.Count__c);
                    System.debug('metadata count::'+metadata.Number_Of_Attempts__c);
                    if(count.Count__c >= metadata.Number_Of_Attempts__c){
                        count.Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update count;
                        }
                        return System.Label.Retry_Exhausted;
                    }
                    //If number of attempts are Less than predefined number of attempts.
                    else{
                        count.Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update count;
                        }                    
                        return 'Success';
                    }
                }
            }
            return 'Failure';    
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_ExistingEMICtrl' ,'updateRetryCount', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static string retryCountUpdate(Integer counter, String applicantId){
        System.debug('applicantId : '+applicantId);
        try {
            List<Retry_Count__c> existingUser=[Select Id,Loan_Application_Id__c,Count__c,Service_Name__c from Retry_Count__c where Service_Name__c='RUNEMIEngine' and User_Id__c=:UserInfo.getUserId() WITH SECURITY_ENFORCED]; 
            List<Retry_Count__c>  retObj = new List<Retry_Count__c>();
            
            if(existingUser.size()>0 ){        
                for(Retry_Count__c rC:existingUser){
                    System.debug('count123;'+counter);
                    rC.Count__c=counter;
                    retObj.add(rC);
                }                  
            }else{
            List<Applicant__c> appObj=[Select Id,Opportunity__c from Applicant__c where Id=:applicantId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED] ;
                System.debug('oppId 1234'+appObj[0].Opportunity__c);
                Retry_Count__c newRec = new Retry_Count__c(Loan_Application_Id__c=appObj[0].Opportunity__c,Count__c=counter,Service_Name__c='RUNEMIEngine',User_Id__c=UserInfo.getUserId()); 
                retObj.add(newRec);
                if(Schema.sObjectType.Retry_Count__c.isCreateable()){
                    insert retObj;
                }
                return 'Success';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Boolean validateBankStatementUploadForCoBorrower(String loanApplicationId){
        Boolean isUploadedFlag = false;
        try {
            List<applicant__c> appList = [select id, (select id from Documents__r where Document_Type__c = 'Customer Bank Statement' limit 1) from applicant__c where Income_source_available__c = false and In_Active_Applicant__c = false and applicant_Type__c = 'Co-borrower' and Do_you_have_a_bank_account__c = true and Opportunity__c = :loanApplicationId WITH SECURITY_ENFORCED];
            
            //Soft check
            if(!appList.isEmpty()){
                //If applicant with Having bank account and has income source case found then doc shuold exists - Hard Check
                if(appList[0].Documents__r.size() > 0){
                    ID documentId = appList[0].Documents__r[0].id;
                    System.debug('Document ID:: '+documentId);
                    
                    if(documentId != null){
                        Set<Id> docIdSet = new Set<Id>();
                        
                        for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :documentId WITH SECURITY_ENFORCED]){
                            docIdSet.add(contentdoc.ContentDocumentId);
                        }

                        List<ContentVersion> cv = [SELECT Id, ContentDocumentId from Contentversion where ContentDocumentId IN :docIdSet WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
                        System.debug('Content Documents Count :: '+cv.size());
                        
                        if(!cv.isEmpty() && cv.size()>0) {
                            isUploadedFlag = true;
                        }
                    }
                }
            } else {
                //If applicant with Having bank account and has income source not found then allow processing - Soft Check
                isUploadedFlag = true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return isUploadedFlag;
    }

    @AuraEnabled
    public static List<Existing_EMI__c> saveEMIDetails1(String emiData,String applicantId){
        try {
            List<ExistingEMIWrapper> existingEMIData=new List<ExistingEMIWrapper>();
            if(emiData!='null' || emiData!='' ||emiData!=null) {
                List<Existing_EMI__c> listOfExistinEMI=new List<Existing_EMI__c>();
                existingEMIData = (List<ExistingEMIWrapper>)JSON.deserialize(emiData, List<ExistingEMIWrapper>.class);
                Applicant__c app = new Applicant__c();
                app.Id = applicantId;
                app.Is_RUN_EMI_Assessed__c = true;
                update app; 
                for(ExistingEMIWrapper wrapperObj : existingEMIData) {
                    if(wrapperObj.emi == null || wrapperObj.emi == '') {
                        Existing_EMI__c emiDetailObj = new Existing_EMI__c(Loan_Type__c=wrapperObj.Loan_Type,Outstanding_Amount__c=Decimal.valueOf(String.valueOf(wrapperObj.Outstanding_Amount)), Applicant_Id__c=applicantId,Upper_EMI_Limit__c=Decimal.valueOf(String.valueOf(wrapperObj.upper_LimitEMI)),Lower_EMI_Limit__c=Decimal.valueOf(String.valueOf(wrapperObj.lower_LimitEMI)), EMI__c=null);
                        listOfExistinEMI.add(emiDetailObj);
                    }
                }
                if(!listOfExistinEMI.isEmpty()) {
                    if(Schema.sObjectType.Existing_EMI__c.isCreateable()) {
                        upsert listOfExistinEMI;
                    }
                    return listOfExistinEMI;
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_ExistingEMICtrl' ,'saveEMIDetails1', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public class ExistingEMIWrapper {
        public String Id { get; set; }
        public String Loan_Type { get; set; }
        public String Outstanding_Amount { get; set; }
        public String Sequential_Number { get; set; }
        public String upper_LimitEMI { get; set; }
        public String lower_LimitEMI { get; set; }
        public String emi { get; set; }
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getBankStatementDocument(String docType,String applicantId){
        try {
            //List<Documents__c> docList=[Select Id,Document_Type__c from Documents__c where Document_Type__c=:docType and Applicant__c=:applicantId WITH SECURITY_ENFORCED LIMIT 1];
            List<Documents__c> docList = [SELECT Id ,(SELECT Id from ContentDocumentLinks) from Documents__c WHERE Applicant__c =:applicantId AND Applicant__r.In_Active_Applicant__c = false and Document_Type__c =:docType and Is_Active__c = true WITH SECURITY_ENFORCED];
            return docList.size() > 0 ? docList[0].ContentDocumentLinks : new List<ContentDocumentLink>();
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_ExistingEMICtrl' ,'getBankStatementDocument', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static Map<String, String> validateExistingEMISubmitAction(String applicantId){
        try {
            Map<String, String> validationStatus = New Map<String,String>{'allowed' => 'true'};
            List<Applicant__c> appList = [select id, Do_you_have_a_bank_account__c, Is_RUN_EMI_Assessed__c, opportunity__r.Product_type__c,opportunity__r.Customer_Type__c, Opportunity__r.LeadSource,Applicant_Type__c  from Applicant__c where id =: applicantId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
            List<ContentDocumentLink> docList = getBankStatementDocument('Customer Bank Statement', applicantId);

            //CHECK:: If Product Type is Not TW then check 1. API exhuast limits 2. EMI Status 3. Document Upload
            if(appList.isEmpty()) {
                validationStatus.put('allowed', 'false');
                validationStatus.put('message', 'Error in execution');
                return validationStatus;
            }

            if(appList[0].Opportunity__r.LeadSource == 'DSA' && appList[0].Applicant_Type__c == 'Borrower'){ //CISP-19393 ##Additional Check for DSA given no Retry Count record available for the DSA application. //CISP-19146 Bug
                //CISP-19146 Start
                List<Retry_Count__c> retryCountList=[Select Id, Count__c from Retry_Count__c where Service_Name__c='RUNEMIEngine' and Applicant__c=:applicantId WITH SECURITY_ENFORCED limit 1]; 
                if(retryCountList.size()>0){
                    if(retryCountList[0].Count__c < 4 && appList[0].Is_RUN_EMI_Assessed__c == false){
                        validationStatus.put('allowed', 'false');
                        validationStatus.put('message', 'Use RUN EMI Engine button to calculate the EMI');
                    }
                }else{
                //CISP-19146 End
                    if(appList[0].Is_RUN_EMI_Assessed__c == false){
                        validationStatus.put('allowed', 'false');
                        validationStatus.put('message', 'Use RUN EMI Engine button to calculate the EMI');
                    }
                }
            }else{
                if(appList[0].opportunity__r.Product_type__c == 'Passenger Vehicles' || (appList[0].opportunity__r.Product_Type__c == System.Label.Tractor && appList[0].opportunity__r.Customer_Type__c == 'Non-Individual' && appList[0].Applicant_Type__c != System.Label.Borrower) || (appList[0].opportunity__r.Product_Type__c == System.Label.Tractor && appList[0].opportunity__r.Customer_Type__c == 'Individual')){
                    List<Retry_Count__c> retryCountList=[Select Id, Count__c from Retry_Count__c where Service_Name__c='RUNEMIEngine' and Applicant__c=:applicantId WITH SECURITY_ENFORCED limit 1]; 
                    List<Existing_EMI__c> emiList= [select Id from Existing_EMI__c where Applicant_Id__c=:applicantId and EMI__c = null WITH SECURITY_ENFORCED];

                    //1. API Exhuast limits Check
                    if (retryCountList.isEmpty() || (!retryCountList.isEmpty() && retryCountList[0].Count__c == 0)) {
                        validationStatus.put('allowed', 'false');
                        validationStatus.put('message', 'Use RUN EMI Engine button to calculate the EMI');
                    } else if(!retryCountList.isEmpty() && retryCountList[0].Count__c > 0 && retryCountList[0].Count__c < 4){
                        if(appList[0].Is_RUN_EMI_Assessed__c == false) {
                            validationStatus.put('allowed', 'false');
                            validationStatus.put('message', 'Use RUN EMI Engine button to calculate the EMI');
                        } else if(appList[0].Is_RUN_EMI_Assessed__c == true && !emiList.isEmpty()) {
                            validationStatus.put('allowed', 'false');
                            validationStatus.put('message', 'EMI field validation is required');
                        }
                    }
                }
            }

            //Document Check
            if(validationStatus.get('allowed') == 'true' && docList.isEmpty() && appList[0].Do_you_have_a_bank_account__c == true && appList[0].opportunity__r.Product_type__c != 'Tractor'){
                validationStatus.put('allowed', 'false');
                validationStatus.put('message', 'Please capture bank statement to proceed in the journey');
            }

            return validationStatus;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_ExistingEMICtrl' ,'getBankStatementDocument', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    } 

    @AuraEnabled
    public static Map<String, String> validateExistingEMISubmitActionTW(String applicantId){
        try {
            Map<String, String> validationStatus = New Map<String,String>{'allowed' => 'true'};
            List<Applicant__c> appList = [select id, Do_you_have_a_bank_account__c, Is_RUN_EMI_Assessed__c, opportunity__r.Product_type__c,opportunity__r.Customer_Type__c, Opportunity__r.LeadSource,Applicant_Type__c from Applicant__c where id =: applicantId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
            if(appList.isEmpty()) {
                validationStatus.put('allowed', 'false');
                validationStatus.put('message', 'Error in execution');
                return validationStatus;
            }

                if(appList[0].opportunity__r.Product_type__c == 'Two Wheeler'){
                    List<Retry_Count__c> retryCountList=[Select Id, Count__c from Retry_Count__c where Service_Name__c='RUNEMIEngine' and Applicant__c=:applicantId WITH SECURITY_ENFORCED limit 1]; 
                    List<Existing_EMI__c> emiList= [select Id from Existing_EMI__c where Applicant_Id__c=:applicantId and EMI__c = null WITH SECURITY_ENFORCED];
                    //1. API Exhuast limits Check
                    if (retryCountList.isEmpty() || (!retryCountList.isEmpty() && retryCountList[0].Count__c == 0)) {
                        validationStatus.put('allowed', 'false');
                        validationStatus.put('message', 'Use RUN EMI Engine button to calculate the EMI');
                    } else if(!retryCountList.isEmpty() && retryCountList[0].Count__c > 0 && retryCountList[0].Count__c < 4){
                        if(appList[0].Is_RUN_EMI_Assessed__c == false) {
                            validationStatus.put('allowed', 'false');
                            validationStatus.put('message', 'Use RUN EMI Engine button to calculate the EMI');
                        } else if(appList[0].Is_RUN_EMI_Assessed__c == true && !emiList.isEmpty()) {
                            validationStatus.put('allowed', 'false');
                            validationStatus.put('message', 'EMI field validation is required');
                        }
                    }
                }
            //}
            return validationStatus;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_ExistingEMICtrl' ,'validateExistingEMISubmitActionTW', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    } 
    
    
    @AuraEnabled
    public static Map<String, String> validateFoir(String oppId){
        try {
            Map<String, String> validationStatus = new Map<String,String>{'borrowerAllowed' => 'true','coBorrowerAllowed' => 'true'};
            List<Applicant__c> appList = [SELECT Id,FOIR__c,FOIR_Check__c,Applicant_Type__c FROM Applicant__c WHERE opportunity__c =:oppId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
            if(appList.isEmpty()) {
                validationStatus.put('borrowerAllowed', 'false');
                validationStatus.put('coBorrowerAllowed', 'false');
                return validationStatus;
            }
            for(Applicant__c app : appList){
                if(app.Applicant_Type__c == 'Borrower' && app.FOIR_Check__c==false){
                    validationStatus.put('borrowerAllowed', 'false');
                }
                if(app.Applicant_Type__c == 'Co-borrower' && app.FOIR_Check__c==false){
                    validationStatus.put('coBorrowerAllowed', 'false');
                }
            }
            return validationStatus;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_ExistingEMICtrl' ,'validateFoir', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static FoirWrapper calculateFoir(String applicantId, Integer rentalExpense, Integer otherObligation, Integer currentEMI){
        FoirWrapper foirReturnWrapper = new FoirWrapper();
        Decimal applicantMonthlyIncome=0.00;
        Decimal foirPercent=0.00;
        Decimal emiAmount=0.00;
        List<Existing_EMI__c> emiDetailList= [select Id, EMI__c from Existing_EMI__c where Applicant_Id__c=:applicantId WITH SECURITY_ENFORCED];
        if(emiDetailList.size() > 0){
        for(Existing_EMI__c emi : emiDetailList){
            emiAmount+=emi.EMI__c;
        }
        }
        List<Income_Details__c> indLst = [SELECT Id,Income__c FROM Income_Details__c WHERE Applicant__c=:applicantId LIMIT 1];
        if(!(indLst.size() > 0)){
            foirReturnWrapper.totalEmiObligation = emiAmount;
            foirReturnWrapper.foirPercent = foirPercent;
            Applicant__c app = new Applicant__c();
            app.Id = applicantId;
            app.FOIR_Check__c = true;
            app.Rental_Expense__c = Decimal.valueOf(rentalExpense);
            app.Other_Obligation__c = Decimal.valueOf(otherObligation);
            update app;
            return foirReturnWrapper;
        }else if(indLst[0].Income__c!=null){
            //applicantMonthlyIncome = Decimal.valueOf((indLst[0]?.Income__c/12).round());
            applicantMonthlyIncome = (indLst[0].Income__c/12).round();
        }
        Decimal denominatorVal= applicantMonthlyIncome - (rentalExpense+otherObligation);
        if(denominatorVal!=0){
            foirPercent = (((emiAmount+currentEMI)/(applicantMonthlyIncome - (rentalExpense+otherObligation)))*100).setScale(2);
        }
        //if((applicantMonthlyIncome - (Decimal.valueOf(rentalExpense)+Decimal.valueOf(otherObligation))).setScale(2)!=0.00){
        //}
        foirReturnWrapper.totalEmiObligation = emiAmount+currentEMI;
        foirReturnWrapper.foirPercent = foirPercent;
       // if(foirPercent>0){
            Applicant__c app = new Applicant__c();
            app.Id = applicantId;
            app.FOIR__c = foirPercent;
            app.FOIR_Check__c = true;
            app.Rental_Expense__c = Decimal.valueOf(rentalExpense);
            app.Other_Obligation__c = Decimal.valueOf(otherObligation);
            update app;
       // }
        return foirReturnWrapper;
    }

    @AuraEnabled
    public static String calculateFoirInFinalTerms(String oppId){
        List<Applicant__c> updateAppList = new List<Applicant__c>();
        Decimal currentEmi=0.00;

        String borrowerId;
        Decimal borrowerMonthlyIncome=0.00;
        Decimal borrowerFoirPercent=0.00;
        Decimal borrowerEmiAmount=0.00;
        Decimal borrowerRentalExpense = 0.00;
        Decimal borrowerOtherExpense = 0.00;

        String coBorrowerId;
        Decimal coBorrowerMonthlyIncome=0.00;
        Decimal coBorrowerFoirPercent=0.00;
        Decimal coBorrowerEmiAmount=0.00;
        Decimal coBorrowerRentalExpense = 0.00;
        Decimal coBorrowerOtherExpense = 0.00;

        List<Applicant__c> appList = [SELECT Id,Other_Obligation__c,Rental_Expense__c,Applicant_type__c FROM Applicant__c WHERE Opportunity__c  =:oppId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
        Final_Term__c ft = [SELECT Id,EMI_Amount__c FROM Final_Term__c WHERE Loan_Application__c = :oppId LIMIT 1];
        currentEmi = ft?.EMI_Amount__c!=null ? ft.EMI_Amount__c : 0.00;
        for(Applicant__c app : appList){
            if(app.Applicant_type__c == 'Borrower'){
                borrowerId = app.Id;
                borrowerRentalExpense = app.Rental_Expense__c!=null ? app.Rental_Expense__c : 0.00;
                borrowerOtherExpense = app.Other_Obligation__c!=null ? app.Other_Obligation__c : 0.00;
            }
            if(app.Applicant_type__c == 'Co-borrower'){
                coBorrowerId = app.Id;
                coBorrowerRentalExpense = app.Rental_Expense__c!=null ? app.Rental_Expense__c : 0.00;
                coBorrowerOtherExpense = app.Other_Obligation__c!=null ? app.Other_Obligation__c : 0.00;
            }
        }
        if(borrowerId != null){
            List<Existing_EMI__c> emiDetailList= [select Id, EMI__c from Existing_EMI__c where Applicant_Id__c=:borrowerId WITH SECURITY_ENFORCED];
            if(emiDetailList.size() > 0){
            for(Existing_EMI__c emi : emiDetailList){
                borrowerEmiAmount+=emi.EMI__c !=null ? emi.EMI__c : 0;
            }
            }
            List<Income_Details__c> indLst = [SELECT Id,Income__c FROM Income_Details__c WHERE Applicant__c=:borrowerId LIMIT 1];
            if(indLst.size() > 0 && indLst[0].Income__c!=null){
                borrowerMonthlyIncome = (indLst[0]?.Income__c/12).round();
                Decimal borrowerDenom = borrowerMonthlyIncome - (borrowerRentalExpense+borrowerOtherExpense);
                if(borrowerDenom!=0){
                    borrowerFoirPercent = (((borrowerEmiAmount+currentEMI)/(borrowerMonthlyIncome - (borrowerRentalExpense+borrowerOtherExpense)))*100)?.setScale(2);
                }
                Applicant__c app = new Applicant__c();
                app.Id = borrowerId;
                app.FOIR__c = borrowerFoirPercent;
                updateAppList.add(app);
            }
        }

        if(coBorrowerId != null){
            List<Existing_EMI__c> emiDetailListcb= [select Id, EMI__c from Existing_EMI__c where Applicant_Id__c=:coBorrowerId WITH SECURITY_ENFORCED];
            if(emiDetailListcb.size() > 0){
            for(Existing_EMI__c emi : emiDetailListcb){
                coBorrowerEmiAmount+=emi.EMI__c;
            }
            }
            List<Income_Details__c> indLstcb = [SELECT Id,Income__c FROM Income_Details__c WHERE Applicant__c=:coBorrowerId LIMIT 1];
            if(indLstcb.size() > 0 && indLstcb[0].Income__c!=null){
                coBorrowerMonthlyIncome = (indLstcb[0]?.Income__c/12).round();
                Decimal coBorrowerDenom = coBorrowerMonthlyIncome - (coBorrowerRentalExpense+coBorrowerOtherExpense);
                if(coBorrowerDenom!=null){
                coBorrowerFoirPercent = (((coBorrowerEmiAmount+currentEMI)/(coBorrowerMonthlyIncome - (coBorrowerRentalExpense+coBorrowerOtherExpense)))*100)?.setScale(2);
                }
                Applicant__c appcb = new Applicant__c();
                appcb.Id = coBorrowerId;
                appcb.FOIR__c = coBorrowerFoirPercent;
                updateAppList.add(appcb);
            }
        }

        if(updateAppList.size()>0){
            update updateAppList;
        }
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.FOIR_Check_At_FinalTerms__c = true;
        update opp;
        return 'Success';
    }

    @AuraEnabled
    public static List<Final_Term__c> getEmi(String oppId) {
        return [Select Id,EMI_Amount__c FROM Final_Term__c WHERE Loan_Application__c =:oppId];
    }

    public class FoirWrapper{
        @AuraEnabled
        public Decimal totalEmiObligation;
        @AuraEnabled
        public Decimal foirPercent;
       }
}