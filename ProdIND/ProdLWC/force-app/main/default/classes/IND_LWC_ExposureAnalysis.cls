/*------------------------------------------------------------
Author:        Siva
Company:       Persistent Systems
Description:   This class contains all the Exposure object related methods.
Test Class:    IND_LWC_ExposureAnalysisTest 
History
Date           Author              Comments
-------------------------------------------------------------
08-02-2022     Siva                Created
------------------------------------------------------------*/

public with sharing class IND_LWC_ExposureAnalysis {
    //CISP-10782 - Start
    @AuraEnabled
    public static List<Applicant__c> getRecordDetails(String oppId) {
        try{
            if(oppId != null){
                List<Applicant__c> applicantDetails = [SELECT Id,Applicant_Type__c,Opportunity__c,(select Id,IND_isNewCustomer__c from Customer_Dedupe_Response__r) FROM Applicant__c WHERE Opportunity__c =:oppId AND In_Active_Applicant__c = false AND Opportunity__r.StageName != 'Journey Stop' AND isCodeValidateBySalesUser__c=false WITH SECURITY_ENFORCED];//CISP-3447 (For cmu user can check the dedupe response)// CISP-10782 (Added isCodeValidateBySalesUser__c)
                List<Applicant__c> finalApplicants = new List<Applicant__c>();
                if(applicantDetails.size()>0){
                    for(Applicant__c app : applicantDetails){
                        if(app.Customer_Dedupe_Response__r.size() > 0 && app.Customer_Dedupe_Response__r[0].IND_isNewCustomer__c){
                           continue; 
                        }
                        finalApplicants.add(app);
                    }
                }
                return finalApplicants;
            }else{
                throw new IND_Exception('Lead is not available.');
            }
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getRecordDetails', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }
    //CISP-10782 - End

    /* 
* @Method:      getExposureDetails
* @Created by:  Siva
* @Description: Get Exposer details for a specific opportunity
* @Param:       Opportunity ID
* @Return:      ExposureWrapper
*/
    @AuraEnabled (cacheable=true)
    public static ExposureWrapper getExposureDetails(String oppId)
    {
        //system.debug('oppId ::'+oppId);
        List<Exposure__c> lstBorExposureDetails = new List<Exposure__c>();
        List<Exposure__c> lstCoBorExposureDetails = new List<Exposure__c>();
List<Exposure__c> lstGuarantorDetails = new List<Exposure__c>();//Added by Prashant Dixit for Guarantor : SFTRAC-96
        List<Exposure__c> lstAdditionalExposureDetails = new List<Exposure__c>();
        String substage, loanApplicationProdType;//Updated by Prashant Dixit for Guarantor : SFTRAC-96
        Decimal curExpAmount=0, BorrowerExposureAmount=0, CoBorrowerExposureAmount=0, GuarantorExposureAmount=0, OtherExposureAmount=0, TotInsPayable=0, BankExpAmt=0, ChkRtnCnt=0; //Updated by Prashant Dixit for Guarantor : SFTRAC-96
        ExposureWrapper expwrap = new ExposureWrapper();
        Boolean isCoborrowerRelationMatch = false; //CISP-7987  
        List<String> relationWithBorrowerList = new List<String>{'BROTHER - IN LAW' , 'BROTHER - INCLUDING STEP BROTHER' , 'DAUGHTER - INCLUDING STEP DAUGHTER' , 'FATHER' , 'GRANDDAUGHTER' , 'GRANDSON' , 'HUSBAND', 'HUSBAND OF GRANDDAUGHTER',
        'HUSBAND OF SISTER' , 'MATERNAL GRANDFATHER' ,'MATERNAL GRANDMOTHER' , 'MEMBER OF HINDU UNDIVIDED FAMILY' , 'MOTHER -INCLUDING STEP MOTHER' , 'PATERNAL GRANDFATHER',
        'PATERNAL GRANDMOTHER', 'SISTER - IN LAW', 'SISTER - INCLUDING STEP SISTER' , 'SON - INCLUDING STEP SON', 'SON WIFE' , 'WIFE' , 'WIFE OF BROTHER' , 'WIFE OF GRANDSON'};//CISP-7987 
        try{
            
            for(Applicant__c applicantRecord : [SELECT Id, Name,Applicant_Type__c, Total_Insurance_Payable__c,
                                                Cheque_Return_Count__c,Relationship_Since__c,Relationship_with_borrower__c
                                                From Applicant__c                                                
                                                Where Opportunity__c =:oppId and In_Active_Applicant__c =false WITH SECURITY_ENFORCED])
            {
                
                if(applicantRecord.Applicant_Type__c == system.label.Borrower){
                    expwrap.chequeReturn = applicantRecord.Cheque_Return_Count__c!=null?applicantRecord.Cheque_Return_Count__c:0;
                    expwrap.relationshipSince = applicantRecord.Relationship_Since__c;
                    
                }
                //CISP-7987
                if(applicantRecord.Applicant_Type__c == 'Co-borrower'){
                    if(relationWithBorrowerList.contains(applicantRecord.Relationship_with_borrower__c)){
                        isCoborrowerRelationMatch = true;
                    }
                } 
            }

            for(Final_Term__c finalRecord : [Select Id, Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c from Final_Term__c where Loan_Application__c =:oppId WITH SECURITY_ENFORCED]){
                curExpAmount = finalRecord.Loan_amount__c != null ? decimal.valueOf(finalRecord.Loan_amount__c) : 0;
                system.debug('curExpAmount value '+ curExpAmount);
                TotInsPayable = finalRecord.Loan_Application__r.Total_Funded_Premium__c != null ? finalRecord.Loan_Application__r.Total_Funded_Premium__c:0;
            }
            
            for(Exposure__c exposureRecord : [SELECT Id,Name,Exposure_Type__c,Type__c,Loan_Application__r.Loan_amount__c,Loan_Application__r.Sub_Stage__c,
                                              Deal_Stage__c,Deal_No__c,Deal_Date__c,Product__c,Product_Variant_Name__c,
                                              Used__c,Status_Flag__c,Finance_Amt__c,SOH__c,Over_Due__c, AD__c, PD__c,
                                              Customer_Code__c,Customer_Code__r.Name,Customer_Code__r.Customer_Name__c,
                                              Current_Demand__c,Mor1__c, Mor2__c, Sanctioned_Amt__c, Loan_Application__r.Product_Type__c
                                              from Exposure__c where Loan_Application__c =:oppId WITH SECURITY_ENFORCED ORDER BY DealDate__c DESC])//Updated by Prashant Dixit for product Tractor : SFTRAC-96
            {
                substage = exposureRecord.Loan_Application__r.Sub_Stage__c;
                
                
                if(exposureRecord.Type__c  == system.Label.Borrower_Exposure){ 
                    lstBorExposureDetails.add(exposureRecord);
                    BorrowerExposureAmount = exposureRecord.SOH__c !=null ? BorrowerExposureAmount + (Decimal)exposureRecord.SOH__c:BorrowerExposureAmount;
                }
                if(exposureRecord.Type__c  == system.Label.Co_Borrower_Exposure){
                    lstCoBorExposureDetails.add(exposureRecord);
                    CoBorrowerExposureAmount = exposureRecord.SOH__c != null ? CoBorrowerExposureAmount + (Decimal)exposureRecord.SOH__c:CoBorrowerExposureAmount;
                }
                //Added by Prashant Dixit : SFTRAC-96 start
                if(exposureRecord.Type__c  == system.Label.Guarantor_Exposure){
                    lstGuarantorDetails.add(exposureRecord);
                    GuarantorExposureAmount = exposureRecord.SOH__c != null ? GuarantorExposureAmount + (Decimal)exposureRecord.SOH__c:GuarantorExposureAmount;
                }
                if(exposureRecord.Loan_Application__r.Product_Type__c == 'Tractor'){
                    loanApplicationProdType = exposureRecord.Loan_Application__r.Product_Type__c;
                }
                //Added by Prashant Dixit : SFTRAC-96 end
                if(exposureRecord.Type__c  == system.Label.Additional_Customer){
                    lstAdditionalExposureDetails.add(exposureRecord);
                    OtherExposureAmount = exposureRecord.SOH__c != null ? OtherExposureAmount + (Decimal)exposureRecord.SOH__c:exposureRecord.SOH__c;
                }
                if(exposureRecord.Type__c  == system.Label.Bank_Exposure){
                    BankExpAmt = exposureRecord.Sanctioned_Amt__c != null? BankExpAmt + (Decimal)exposureRecord.Sanctioned_Amt__c:BankExpAmt;
                }
                
            }
            if(isCoborrowerRelationMatch == false){
                CoBorrowerExposureAmount = 0;//CISP-7987 
            }
            expwrap.loanAppProductType = loanApplicationProdType;//Added by Prashant Dixit : SFTRAC-96
            expwrap.lstBorExposureDetails = lstBorExposureDetails;
            expwrap.lstCoBorExposureDetails = lstCoBorExposureDetails;
            expwrap.lstGuarantorExposureDetails = lstGuarantorDetails;//Added by Prashant Dixit : SFTRAC-96
            expwrap.lstAdditionalExposureDetails = lstAdditionalExposureDetails;
            system.debug('curExpAmount value output- '+ curExpAmount);
            expwrap.currentExposureAmount = curExpAmount + TotInsPayable;
            system.debug('expwrap.currentExposureAmount '+ expwrap.currentExposureAmount);
            expwrap.existingBorrowerExposureAmount = BorrowerExposureAmount;
            expwrap.existingCoBorrowerExposureAmount = CoBorrowerExposureAmount;
            expwrap.existingGuarantorExposureAmount = GuarantorExposureAmount;//Added by Prashant Dixit : SFTRAC-96
            expwrap.existingOtherExposureAmount = OtherExposureAmount;
            expwrap.bankExposureAmount = BankExpAmt;
            expWrap.substage = substage;
            expwrap.totalExposureAmount = expwrap.currentExposureAmount + expwrap.existingBorrowerExposureAmount +
                expwrap.existingCoBorrowerExposureAmount
                + expwrap.existingOtherExposureAmount + expwrap.bankExposureAmount;       
        }
        catch(exception e){
            system.debug(e.getMessage());            
            system.debug('Line No '+e.getLineNumber());
            system.debug('Line No '+e.getCause());
            system.debug('Line No '+e.getMessage());
            
             ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getExposureDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        system.debug('ExposureAnalysis getExposureDetails===>' + expwrap);
        return expwrap;
    }
    
    /*
* @Method:      getLienDetails
* @Created by:  Siva
* @Description: To Get Lien Detail records for an exposure
* @Param:       Exposure ID
* @Return:      List of Lien Details
*/
    @AuraEnabled
    public static List<Lien_Detail__c> getLienDetails(String expId)
    {
       // system.debug('expId :'+expId);
        List<Lien_Detail__c> lstLienDetails = new List<Lien_Detail__c>();
        try{
            
            lstLienDetails=[SELECT Id, Name, Deal_No__c,  Lien_Type__c, Source_Deal_No__c, Lien_Marking_Period__c,
                                                   Lien_Maker_Date__c, Lien_Request_By__c, Lien_Marking_Reason__c
                                                   from Lien_Detail__c 
                                                   where Deal_No__c =:expId WITH SECURITY_ENFORCED];
        }
        catch(exception e){
            system.debug(e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getLienDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        //system.debug('get LienDetails===>' + lstLienDetails);
        return lstLienDetails;
    }

    /*
* @Method:      getAdditionalExposureDetails
* @Created by:  Saloni
* @Description: To Get Family Exposer details for an opportunity
* @Param:       Opportunity ID
* @Return:      List of Exposure
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Exposure__c>> getAdditionalExposureDetails(String oppId)
    {
        system.debug('getFamilyExpCustCodes oppId ::'+oppId);
        Map<String, List<Exposure__c>> lstAdditionalExpCustCodes = new Map<String, List<Exposure__c>>();
        try{
            for(Exposure__c familyExposureRecord : [SELECT  Id,Name,Exposure_Type__c,
                                                    Deal_Stage__c,Deal_No__c,Deal_Date__c,Product__c,Product_Variant_Name__c,
                                                    used__c,Status_Flag__c,Finance_Amt__c,SOH__c,Over_Due__c, AD__c, PD__c,
                                                    Current_Demand__c,Mor1__c, Mor2__c,Customer_Code__r.Name,Customer_Code__r.Customer_Name__c,
                                                    Applicant__c, Applicant__r.Customer_Code__c,Applicant__r.Name,Manufacture_Date__c
                                                    from Exposure__c 
                                                    where Loan_Application__c =:oppId and 
                                                    (Type__c =: system.label.Additional_Customer or 
                                                     ExposureHeader__c =: system.label.Additional_Customer) ORDER BY DealDate__c DESC])
            { 
                if(familyExposureRecord.Customer_Code__c != null){
                    string key =familyExposureRecord.Customer_Code__r.Name+' - '+familyExposureRecord.Customer_Code__r.Customer_Name__c;
                    if(lstAdditionalExpCustCodes.containsKey(key)){
                        List<Exposure__c> ExposureLst = lstAdditionalExpCustCodes.get(key);
                        ExposureLst.add(familyExposureRecord);
                        lstAdditionalExpCustCodes.put(key, ExposureLst);
                    }else{                        
                        lstAdditionalExpCustCodes.put(key, new List<Exposure__c>{familyExposureRecord});
                    }
                }else if(familyExposureRecord.Applicant__c != null){
                    string key = familyExposureRecord.Applicant__r.Customer_Code__c +' - '+familyExposureRecord.Applicant__r.Name;
                    if(lstAdditionalExpCustCodes.containsKey(key)){
                        List<Exposure__c> ExposureLst = lstAdditionalExpCustCodes.get(key);
                        ExposureLst.add(familyExposureRecord);
                        lstAdditionalExpCustCodes.put(key, ExposureLst);
                    }else{
                        lstAdditionalExpCustCodes.put(key, new List<Exposure__c>{familyExposureRecord});
                    }
                    
                }
            }
                
            List<Customer_Code__c> custCOdes = [SELECT  Id,Name,Customer_Name__c
                                                 FROM Customer_Code__c WHERE Loan_Application__c=:oppId];                                                
                System.debug('custCOdes=>'+custCOdes);
                for(Customer_Code__c csd:custCOdes ){
                    string key =csd.Name+' - '+csd.Customer_Name__c;
                    System.debug('key outside if=>'+key);

                    if(!lstAdditionalExpCustCodes.containsKey(key)){
                        System.debug('key inside if=>'+key);
                        lstAdditionalExpCustCodes.put(key,new List<Exposure__c>());
                        System.debug('lstAdditionalExpCustCodes inside if=>'+lstAdditionalExpCustCodes);

                    }
            }
        }
        catch(exception e){
            system.debug(e.getMessage());
             ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getAdditionalExposureDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
       system.debug('ExposureAnalysis getFamilyExposureDetails===>' + lstAdditionalExpCustCodes);
        return lstAdditionalExpCustCodes;
    }

    /*
* @Method:      getFamilyExposureDetails
* @Created by:  Siva
* @Description: To Get Family Exposer details for an opportunity
* @Param:       Opportunity ID
* @Return:      List of Exposure
*/
    @AuraEnabled  (cacheable=true)
    public static List<Exposure__c> getFamilyExposureDetails(String oppId)
    {
       // system.debug('oppId ::'+oppId);
        List<Exposure__c> lstFamilyExposureDetails = new List<Exposure__c>();
        try{
            for(Exposure__c familyExposureRecord : [SELECT  Id,Name,Exposure_Type__c,
                                                    Deal_Stage__c,Deal_No__c,Deal_Date__c,Product__c,Product_Variant_Name__c,
                                                    used__c,Status_Flag__c,Finance_Amt__c,SOH__c,Over_Due__c, AD__c, PD__c,
                                                    Current_Demand__c,Mor1__c, Mor2__c,Customer_Code__r.Name,Customer_Code__r.Customer_Name__c,
                                                    Applicant__c, Applicant__r.Customer_Code__c,Applicant__r.Name,Manufacture_Date__c
                                                    from Exposure__c 
                                                    where Loan_Application__c =:oppId and 
                                                    (Type__c =: system.label.Family_Exposure or 
                                                     ExposureHeader__c =: system.label.Family_Exposure) WITH SECURITY_ENFORCED ORDER BY DealDate__c DESC])
            { 
                lstFamilyExposureDetails.add(familyExposureRecord);
            }
        }
        catch(exception e){
            system.debug(e.getMessage());
             ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getFamilyExposureDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
       // system.debug('ExposureAnalysis getFamilyExposureDetails===>' + lstFamilyExposureDetails);
        return lstFamilyExposureDetails;
    }
    @AuraEnabled
    public static Map<String, List<Exposure__c>> getFamilyExpCustCodes(String oppId)
    {
        system.debug('getFamilyExpCustCodes oppId ::'+oppId);
        Map<String, List<Exposure__c>> lstFamilyExpCustCodes = new Map<String, List<Exposure__c>>();
        try{
            for(Exposure__c familyExposureRecord : [SELECT  Id,Name,Exposure_Type__c,
                                                    Deal_Stage__c,Deal_No__c,Deal_Date__c,Product__c,Product_Variant_Name__c,
                                                    used__c,Status_Flag__c,Finance_Amt__c,SOH__c,Over_Due__c, AD__c, PD__c,
                                                    Current_Demand__c,Mor1__c, Mor2__c,Customer_Code__r.Name,Customer_Code__r.Customer_Name__c,
                                                    Applicant__c, Applicant__r.Customer_Code__c,Applicant__r.Name,Manufacture_Date__c,Agreement_amount__c,IB_Seasoning__c,Amount_Paid__c
                                                    from Exposure__c 
                                                    where Loan_Application__c =:oppId and 
                                                    (Type__c =: system.label.Family_Exposure or 
                                                     ExposureHeader__c =: system.label.Family_Exposure) WITH SECURITY_ENFORCED ORDER BY DealDate__c DESC])
            { 
                
                  
                //if(familyExposureRecord.Customer_Code__c != null && !lstFamilyExpCustCodes.contains(familyExposureRecord.Customer_Code__r.Name+' - '+familyExposureRecord.Customer_Code__r.Customer_Name__c)){
                    //lstFamilyExpCustCodes.add(familyExposureRecord.Customer_Code__r.Name+' - '+familyExposureRecord.Customer_Code__r.Customer_Name__c);

               // }else if( familyExposureRecord.Applicant__c != null && !lstFamilyExpCustCodes.contains(familyExposureRecord.Applicant__r.Customer_Code__c+' - '+familyExposureRecord.Applicant__r.Name)){
               //     lstFamilyExpCustCodes.add(familyExposureRecord.Applicant__r.Customer_Code__c +' - '+familyExposureRecord.Applicant__r.Name);
              //  }  
              //  
                if(familyExposureRecord.Customer_Code__c != null){
                    string key =familyExposureRecord.Customer_Code__r.Name+' - '+familyExposureRecord.Customer_Code__r.Customer_Name__c;
                    if(lstFamilyExpCustCodes.containsKey(key)){
                        List<Exposure__c> ExposureLst = lstFamilyExpCustCodes.get(key);
                        ExposureLst.add(familyExposureRecord);
                        lstFamilyExpCustCodes.put(key, ExposureLst);
                    }else{                        
                        lstFamilyExpCustCodes.put(key, new List<Exposure__c>{familyExposureRecord});
                    }
                }else if(familyExposureRecord.Applicant__c != null){
                    string key = familyExposureRecord.Applicant__r.Customer_Code__c +' - '+familyExposureRecord.Applicant__r.Name;
                    if(lstFamilyExpCustCodes.containsKey(key)){
                        List<Exposure__c> ExposureLst = lstFamilyExpCustCodes.get(key);
                        ExposureLst.add(familyExposureRecord);
                        lstFamilyExpCustCodes.put(key, ExposureLst);
                    }else{
                        lstFamilyExpCustCodes.put(key, new List<Exposure__c>{familyExposureRecord});
                    }
                    
                }
                
                
            }
        }
        catch(exception e){
            system.debug(e.getMessage());
             ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getFamilyExposureDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
       system.debug('ExposureAnalysis getFamilyExposureDetails===>' + lstFamilyExpCustCodes);
        return lstFamilyExpCustCodes;
    }
    /*
* @Method:      getBankExposureDetails
* @Created by:  Siva
* @Description: To Get Bank Exposer details for an opportunity
* @Param:       Opportunity ID
* @Return:      List of Exposure
*/
    @AuraEnabled(cacheable=true)
    public static List<Exposure__c> getBankExposureDetails(String oppId)
    {
        //system.debug('oppId ::'+oppId);
        List<Exposure__c> lstBankExposureDetails = new List<Exposure__c>();
        try{
            for(Exposure__c bankExposureRecord : [SELECT Id,Name,CIF_ID__c,Type_of_Facility__c,
                                                  Date_of_Sanction__c, Sanctioned_Amt__c, Amount_Utilized__c, ApprButPenForDis__c 
                                                  from Exposure__c 
                                                  where Loan_Application__c =:oppId and Type__c =:system.label.Bank_Exposure WITH SECURITY_ENFORCED ORDER BY DealDate__c DESC])
            { //system.label.Bank_Exposure
                lstBankExposureDetails.add(bankExposureRecord);
            }
        }
        catch(exception e){
            system.debug(e.getMessage());
            //ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getBankExposureDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        system.debug('ExposureAnalysis getFamilyExposureDetails===>' + lstBankExposureDetails);
        return lstBankExposureDetails;
        
    }
    
    /*
* @Method:      checkCustomerCodeDetails
* @Created by:  Siva
* @Description: To compare Customer Code with existing data
* @Param:       Opportunity ID, Customer Code
* @Return:      Boolean value
*/
    @AuraEnabled
    public static Boolean checkCustomerCodeDetails(String oppID, String custCodeString)
    {
        //system.debug('Inside checkCustomerCodeDetails');
        Boolean cusCde = false;
        try{
            for(Applicant__c applicantRecord : [SELECT Id, Opportunity__c, Customer_Code__c 
                                                from Applicant__c where Opportunity__c=:oppID and 
                                                In_Active_Applicant__c =false and Customer_Code__c =:custCodeString WITH SECURITY_ENFORCED])
            {                
                cusCde = true;                
            }
            for(Customer_Code__c cusCdeRec: [SELECT Id, Name from Customer_Code__c where
                                             Loan_Application__c =:oppID and Name =:custCodeString WITH SECURITY_ENFORCED ])
            {                   
                cusCde = true;
                
            }
            
            system.debug('cusCde ::'+cusCde); 
        }
        catch(exception e){
            system.debug(e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'checkCustomerCodeDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return cusCde;
    }
    
    /*
* @Method:      getCustomerCodeDetails
* @Created by:  Siva
* @Description: To Get Customer Code details for an opportunity
* @Param:       Opportunity ID
* @Return:      List of Customer Code details
*/
    @AuraEnabled(cacheable=true)
    public static List<Customer_Code__c> getCustomerCodeDetails(String oppId)
    {
        List<Customer_Code__c> lstCustCodeDetails = new List<Customer_Code__c>();
        try{
            for(Customer_Code__c custCodeRecord : [SELECT Id,Name,Customer_Name__c, Cheque_Return_Count__c, Min_Deal_Date__c                                                    
                                                   from Customer_Code__c 
                                                   where Loan_Application__c =:oppId WITH SECURITY_ENFORCED]){
                                                       lstCustCodeDetails.add(custCodeRecord);
                                                   }
        }
        catch(exception e){
            system.debug(e.getMessage());
            //ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'checkCustomerCodeDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        //system.debug('ExposureAnalysis getCustomerCodeDetails===>' + lstCustCodeDetails);
        return lstCustCodeDetails;
        
    }
    
    
    //Wrapper to hold Exposure records    
    public ExposureWrapper exposureWrapper {get;set;}
    public class ExposureWrapper{
        @AuraEnabled
        public List<Exposure__c> lstBorExposureDetails{get;set;}
        @AuraEnabled
        public List<Exposure__c> lstCoBorExposureDetails{get;set;}
@AuraEnabled
        public List<Exposure__c> lstGuarantorExposureDetails{get;set;}//Added for Guarantor by Prashant Dixit : SFTRAC-96
        @AuraEnabled
        public List<Exposure__c> lstAdditionalExposureDetails{get;set;}
        @AuraEnabled
        public Decimal currentExposureAmount{get;set;}//Finance_Amt__c
        @AuraEnabled
        public Decimal existingBorrowerExposureAmount{get;set;}//total SOH of Borrower
        @AuraEnabled
        public Decimal existingCoBorrowerExposureAmount{get;set;}//total SOH of Co-Borrower
        @AuraEnabled
        public Decimal existingGuarantorExposureAmount{get;set;}//total SOH of Guarantor Added by Prashant Dixit : SFTRAC-96
        @AuraEnabled
        public String loanAppProductType{get;set;}//total SOH of Guarantor Added by Prashant Dixit : SFTRAC-96
        @AuraEnabled
        public Decimal existingOtherExposureAmount{get;set;}//total SOH of Other Exposure
        @AuraEnabled
        public Decimal bankExposureAmount{get;set;} //changed from Amount_Sanctioned__c to Sanctioned_Amt__c : Thilak
        @AuraEnabled
        public Decimal totalExposureAmount{get;set;} //Sum of all Exposures
        @AuraEnabled
        public Decimal chequeReturn{get;set;} //Cheque Return
        @AuraEnabled
        public date relationshipSince{get;set;} //Relationship Since        
        @AuraEnabled
        public String substage{get; set;}
        
    }
    
        /* 
* @Method:      getCustomerCodesExpAPI
* @Created by:  Siva
* @Description: Get list of customer code which are not sent to Exposure API
* @Param:       Opportunity ID
* @Return:      List of customer codes as string
*/
    @AuraEnabled
    public static List<String> getCustomerCodesExpAPI(string loanApplicationId){
        //system.debug('loanApplicationId ::'+loanApplicationId);
        //doCustomerExposureCallout(List<String> lstCustCodes,String loanAppId)         
        //Customer_Code__c
        List<String> customerCodes = new List<String>();
        List<String>exposureCustomerCodes = new List<String>();
        List<String> exposureAPIcustCodes = new List<String>();
        
        for( Opportunity oppty : [select Id,  
                                  (select Id,Name,Customer_Name__c from  Customer_Codes__r where IsExposureRecived__c =false),
                                  (select Id, Customer_Code__c from Applicants__r where IsExposureRecived__c =false)                                  
                                  from opportunity 
                                  where Id =: loanApplicationId WITH SECURITY_ENFORCED])
        {
            
            for(Applicant__c applicantRecord : oppty.Applicants__r){
                if(applicantRecord.Customer_Code__c != null){
                    customerCodes.add(applicantRecord.Customer_Code__c);
                }
            }
            
            for(Customer_Code__c costCode : oppty.Customer_Codes__r){
                customerCodes.add(costCode.Name);
            }          
        }   
                
        //doing one mre query to check if exposure 
        system.debug('exposureAPIcustCodes ::'+exposureAPIcustCodes);    
        
        updateCustomerCode(customerCodes);
        return customerCodes;
    }
    
     /* updateCustomerCode
* @Method:      deletecustCodes
* @Created by:  Siva
* @Description: delete the Customer code record along with childs of customer code like Exposure, Liens
* @Param:       customer code ID
* @Return:      Boolean 
*/
    @AuraEnabled
    public static boolean deletecustCodes(string customercodeId){
        boolean isDeleteSuccess= true;
        try{
            Map<Id, Exposure__c> exposuresMap = new Map<Id, Exposure__c>();
            for(Exposure__c exp : [select Id from Exposure__c where Customer_Code__c =:customercodeId WITH SECURITY_ENFORCED]){
                exposuresMap.put(exp.id, exp);
            }            
            List<Lien_Detail__c> LienDetails = [select Id from Lien_Detail__c where Deal_No__c =: exposuresMap.keySet() WITH SECURITY_ENFORCED];
            LIst<Customer_Code__c> customercodes = [select Id from Customer_Code__c where Id =:customercodeId WITH SECURITY_ENFORCED];
            
            if(!LienDetails.isempty()){
                delete LienDetails;
            }
            if (!exposuresMap.isempty()){                
                delete exposuresMap.values();                
            }
            if(!customercodes.isEmpty()){
                delete customercodes;
            }
            
        }catch(exception e){
            isDeleteSuccess = false;
            system.debug('exception :'+e);
            ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'deletecustCodes', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        
        
        return isDeleteSuccess;
    }
    
     /* 
* @Method:      allCostCodeTrgExpAPI
* @Created by:  Siva
* @Description: checking if all the customer codes are sent for EXposure API then return true OW false.
* @Param:       Opportunity Id
* @Return:      Boolean 
*/
    @AuraEnabled
    public static boolean allCostCodeTrgExpAPI(string loanapplicationId){        
        Boolean resp =true;
        LIst<Customer_Code__c> customercodes = [select Id from Customer_Code__c where 
                                                IsExposureTriggered__c =false and 
                                                Loan_Application__c =:loanapplicationId WITH SECURITY_ENFORCED];
        if(!customercodes.isEmpty()){
            resp =false;
        }
        return resp;
    }
    
     /* 
* @Method:      updateCustomerCode
* @Created by:  Siva
* @Description: Once the customer code is sent for Exposure API then updating the flag to true.
* @Param:       List if customer codes
* @Return:      none 
*/
    @future
    public static void updateCustomerCode(List<String> customerCodes){
        
        List<Customer_Code__c> custCodes = New List<Customer_Code__c>();
        for(Customer_Code__c code : [select Id,IsExposureTriggered__c, Name from Customer_Code__c where
                                     Name IN :customerCodes WITH SECURITY_ENFORCED])
        {
            code.IsExposureTriggered__c =true;
            custCodes.add(code);
        }
        
        if(!custCodes.isEmpty()){
            update custCodes;
        }
        
    }
    
    /* 
* @Method:      getOpptyStage
* @Created by:  Siva
* @Description: return the opportunity stage name.
* @Param:       Opportunity Id
* @Return:      String 
*/
    @AuraEnabled
    public static string getOpptyStage(String loanApplicationId){
        string responseVal;
        try{
            responseVal= [Select Sub_Stage__c from Opportunity where Id =:loanApplicationId WITH SECURITY_ENFORCED].Sub_Stage__c;
        }catch (exception e){
            system.debug('exception ex '+e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getOpptyStage', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }     
        return responseVal;
    }
     /* 
* @Method:      getOpptyStageCAM
* @Created by:  Siva
* @Description: return the opportunity stage name.
* @Param:       Opportunity Id
* @Return:      String 
*/
@AuraEnabled
public static Boolean getOpptyStageCAM(String loanApplicationId){
    Boolean responseVal;
    CAM__c[] cams= [Select CCC_Exposure_Editable__c from CAM__c where Loan_Application__c=:loanApplicationId WITH SECURITY_ENFORCED];
    id id1 = userinfo.getProfileId();
    Profile profileName = [Select Name from Profile where Id =: id1];
    if(cams.size()>0){
        if(cams[0].CCC_Exposure_Editable__c && (profileName.Name==system.label.Credit_Analyst_Profile ||
                                               profileName.Name==system.label.IBL_State_Credit_Manager ||
                                               profileName.Name==system.label.IBL_Credit_Analyst)){
            responseVal=true;
        }else{
            responseVal=false;
        }
    }else{
        responseVal=false;
    }
   
   
    return responseVal;
}

     /* 
* @Method:      getExposureDetails
* @Created by:  Siva
* @Description: Get Exposer details for a specific opportunity
* @Param:       Opportunity ID
* @Return:      ExposureWrapper
*/
    @AuraEnabled
    public static ExposureWrapper getExpRecords(String oppId)
    {
        //system.debug('oppId ::'+oppId);
        List<Exposure__c> lstBorExposureDetails = new List<Exposure__c>();
        List<Exposure__c> lstCoBorExposureDetails = new List<Exposure__c>();
        List<Exposure__c> lstAdditionalExposureDetails = new List<Exposure__c>();
        String substage;
        Decimal curExpAmount=0, BorrowerExposureAmount=0, CoBorrowerExposureAmount=0, OtherExposureAmount=0, TotInsPayable=0, BankExpAmt=0, ChkRtnCnt=0;
        ExposureWrapper expwrap = new ExposureWrapper();
        Boolean isCoborrowerRelationMatch = false;//CISP-7987
        List<String> relationWithBorrowerList = new List<String>{'BROTHER - IN LAW' , 'BROTHER - INCLUDING STEP BROTHER' , 'DAUGHTER - INCLUDING STEP DAUGHTER' , 'FATHER' , 'GRANDDAUGHTER' , 'GRANDSON' , 'HUSBAND', 'HUSBAND OF GRANDDAUGHTER',
        'HUSBAND OF SISTER' , 'MATERNAL GRANDFATHER' ,'MATERNAL GRANDMOTHER' , 'MEMBER OF HINDU UNDIVIDED FAMILY' , 'MOTHER -INCLUDING STEP MOTHER' , 'PATERNAL GRANDFATHER',
        'PATERNAL GRANDMOTHER', 'SISTER - IN LAW', 'SISTER - INCLUDING STEP SISTER' , 'SON - INCLUDING STEP SON', 'SON WIFE' , 'WIFE' , 'WIFE OF BROTHER' , 'WIFE OF GRANDSON'};//CISP-7987 
        try{            
            for(Applicant__c applicantRecord : [SELECT Id, Name,Applicant_Type__c, Total_Insurance_Payable__c,
                                                Cheque_Return_Count__c,Relationship_Since__c,Relationship_with_borrower__c 
                                                From Applicant__c                                                
                                                Where Opportunity__c =:oppId and In_Active_Applicant__c =false WITH SECURITY_ENFORCED])
            {
               
                if(applicantRecord.Applicant_Type__c == system.label.Borrower){
                    expwrap.chequeReturn = applicantRecord.Cheque_Return_Count__c;
                    expwrap.relationshipSince = applicantRecord.Relationship_Since__c;
                }
                //CISP-7987
                if(applicantRecord.Applicant_Type__c == 'Co-borrower'){
                    if(relationWithBorrowerList.contains(applicantRecord.Relationship_with_borrower__c)){
                        isCoborrowerRelationMatch = true;
                    }
                }
            }

            for(Final_Term__c finalRecord : [Select Id, Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c from Final_Term__c where Loan_Application__c =:oppId WITH SECURITY_ENFORCED]){
                curExpAmount = finalRecord.Loan_amount__c != null ? decimal.valueOf(finalRecord.Loan_amount__c) : 0;
                TotInsPayable = finalRecord.Loan_Application__r.Total_Funded_Premium__c != null? finalRecord.Loan_Application__r.Total_Funded_Premium__c:0;
                system.debug('curExpAmount value update '+ curExpAmount);
            }
            
            for(Exposure__c exposureRecord : [SELECT Id,Name,Exposure_Type__c,Type__c,Loan_Application__r.Loan_amount__c,Loan_Application__r.Sub_Stage__c,
                                              Deal_Stage__c,Deal_No__c,Deal_Date__c,Product__c,Product_Variant_Name__c,
                                              Used__c,Status_Flag__c,Finance_Amt__c,SOH__c,Over_Due__c, AD__c, PD__c,
                                              Current_Demand__c,Mor1__c, Mor2__c, Sanctioned_Amt__c
                                              from Exposure__c where Loan_Application__c =:oppId WITH SECURITY_ENFORCED ORDER BY DealDate__c DESC])
            {
                substage = exposureRecord.Loan_Application__r.Sub_Stage__c;                
                
                if(exposureRecord.Type__c  == system.Label.Borrower_Exposure){ 
                    lstBorExposureDetails.add(exposureRecord);
                    BorrowerExposureAmount = exposureRecord.SOH__c !=null ? BorrowerExposureAmount + (Decimal)exposureRecord.SOH__c:BorrowerExposureAmount;
                }
                if(exposureRecord.Type__c  == system.Label.Co_Borrower_Exposure){
                    lstCoBorExposureDetails.add(exposureRecord);
                    CoBorrowerExposureAmount = exposureRecord.SOH__c != null ? CoBorrowerExposureAmount + (Decimal)exposureRecord.SOH__c:CoBorrowerExposureAmount;
                }
                if(exposureRecord.Type__c  == system.Label.Additional_Customer){
                    lstAdditionalExposureDetails.add(exposureRecord);
                    OtherExposureAmount = exposureRecord.SOH__c != null ? OtherExposureAmount + (Decimal)exposureRecord.SOH__c:exposureRecord.SOH__c;
                }
                if(exposureRecord.Type__c  == system.Label.Bank_Exposure){
                    BankExpAmt = exposureRecord.Sanctioned_Amt__c != null? BankExpAmt + (Decimal)exposureRecord.Sanctioned_Amt__c:BankExpAmt;
                }                
            }
            if(isCoborrowerRelationMatch == false){
                CoBorrowerExposureAmount = 0;//CISP-7987
            }
            expwrap.lstBorExposureDetails = lstBorExposureDetails;
            expwrap.lstCoBorExposureDetails = lstCoBorExposureDetails;
            expwrap.lstAdditionalExposureDetails = lstAdditionalExposureDetails;
            system.debug('currentExposureAmount update '+ curExpAmount);            
            expwrap.currentExposureAmount = curExpAmount + TotInsPayable;
            expwrap.existingBorrowerExposureAmount = BorrowerExposureAmount;
            expwrap.existingCoBorrowerExposureAmount = CoBorrowerExposureAmount;
            expwrap.existingOtherExposureAmount = OtherExposureAmount;
            expwrap.bankExposureAmount = BankExpAmt;
            expWrap.substage = substage;
            expwrap.totalExposureAmount = expwrap.currentExposureAmount + expwrap.existingBorrowerExposureAmount +
                expwrap.existingCoBorrowerExposureAmount
                + expwrap.existingOtherExposureAmount + expwrap.bankExposureAmount;//Start CISP-1120
            List<Opportunity> oppList = [SELECT Id,Current_Exposure_Amt__c,Existing_Borrowers_Exposure_Amt__c,Existing_Co_Borrowers_Exposure_Amt__c,Existing_Others_Exposure_Amt__c,Total_Bank_Exposure__c,Total_Exposures_Amount__c FROM Opportunity WHERE Id =: oppId  LIMIT 1];
            if (oppList.size()> 0) {
                oppList[0].Current_Exposure_Amt__c = expwrap.currentExposureAmount;
                oppList[0].Existing_Borrowers_Exposure_Amt__c = expwrap.existingBorrowerExposureAmount;
                oppList[0].Existing_Co_Borrowers_Exposure_Amt__c = expwrap.existingCoBorrowerExposureAmount;
                oppList[0].Existing_Others_Exposure_Amt__c = expwrap.existingOtherExposureAmount;
                oppList[0].Total_Bank_Exposure__c = expwrap.bankExposureAmount;
                oppList[0].Total_Exposures_Amount__c = expwrap.totalExposureAmount;
                update oppList;
            }//End CISP-1120
        }
        catch(exception e){
            system.debug('Exposure error message :'+ e.getMessage()); 
            system.debug('Line Number :'+ e.getLineNumber()); 
            ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getExpRecords', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        //system.debug('ExposureAnalysis getExposureDetails===>' + expwrap);
        return expwrap;
    }
    
/*  Enhancement for INDI-3470
* @Method:      updateTotalExposureAmount
* @Created by:  Rajat Jaiswal
* @Description: updating Total Exposure Amount field on Opportunity
* @Param:       loanApplicationId, totalExposureAmount
* @Return:      none
*/
    @AuraEnabled
    public static void updateTotalExposureAmount(String loanApplicationId,ExposureWrapper exposureWrapperData){
        try{//Start CISP-1120
            List<Opportunity> oppList = [SELECT Id,Current_Exposure_Amt__c,Existing_Borrowers_Exposure_Amt__c,Existing_Co_Borrowers_Exposure_Amt__c,Existing_Others_Exposure_Amt__c,Total_Bank_Exposure__c,Total_Exposures_Amount__c FROM Opportunity WHERE Id =: loanApplicationId  LIMIT 1];
            if (oppList.size()> 0 && exposureWrapperData!=null) {
                oppList[0].Current_Exposure_Amt__c = exposureWrapperData.currentExposureAmount;
                oppList[0].Existing_Borrowers_Exposure_Amt__c = exposureWrapperData.existingBorrowerExposureAmount;
                oppList[0].Existing_Co_Borrowers_Exposure_Amt__c = exposureWrapperData.existingCoBorrowerExposureAmount;
                oppList[0].Existing_Others_Exposure_Amt__c = exposureWrapperData.existingOtherExposureAmount;
                oppList[0].Total_Bank_Exposure__c = exposureWrapperData.bankExposureAmount;
                oppList[0].Total_Exposures_Amount__c = exposureWrapperData.totalExposureAmount;
                update oppList;
            } //End CISP-1120
        }catch (exception e){
            system.debug('exception ex '+e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'updateTotalExposureAmount', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }

     /* 
* @Method:      getApplicantInfo
* @Created by:  Poonam
* @Description: return Applicant record.
* @Param:       Opportunity Id
* @Return:      Applicant__c 
*/
@AuraEnabled
public static String getApplicantInfo(String loanApplicationId){//CISP-3447
    try{
        Map<String,object> mapObj = new Map<String,object>();
        for(Applicant__c app : [SElect Id,isCodeValidateBySalesUser__c, Customer_Code__c,Applicant_Type__c,Opportunity__c,Opportunity__r.Is_Customer_Dedupe_Submit__c,Opportunity__r.IsExposureAPITriggered__c,Opportunity__r.LeadSource from Applicant__c where Opportunity__c =: loanApplicationId and In_Active_Applicant__c =false]){
            if(app.Applicant_Type__c == System.label.Borrower){
                mapObj.put('BorrowerDetails',app);
            }else if(app.Applicant_Type__c == 'Co-borrower'){
                mapObj.put('CoBorrowerDetails',app);
            }
        }
        List<Vehicle_Detail__c> vehicleDetails = [SELECT Purpose_of_Purchase__c 
                                                  FROM Vehicle_Detail__c 
                                                  WHERE Loan_Application__c = :loanApplicationId 
                                                  LIMIT 1];
 
        // CISP-4486
        if(!vehicleDetails.isEmpty()) {
            mapObj.put('VehicleDetails', vehicleDetails[0].Purpose_of_Purchase__c);
        }

        if(!mapObj.isEmpty()){
            return JSON.serialize(mapObj);
        }
        return null;
    }catch (exception e){
        system.debug('exception ex '+e.getMessage());
        ErrorLoggerUtil.logErrorEvent('IND_LWC_ExposureAnalysis', 'getApplicantInfo', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }     
}//CISP-3447 end
}