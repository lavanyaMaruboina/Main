/**
* @Name         LwcLOSGattingAndScreeningCntrl
* @Author       Khushiram
* @Company      Persistent Systems
* @Description  This class contains all methods related to Gatting And Screening Screen's buttons.

* Test Class:   LwcLOSGattingAndScreeningCntrlTest
*/
public with sharing class LwcLOSGattingAndScreeningCntrl {
    /*
    * @Method:      getCurrentApplicantRecord
    * @Created by:  Khushiram
    * @Description: This method will return the current applicant record field values.
    * @Param:       String - current Applicant ID
    * @Return:      object of applicant record.
    */
    @AuraEnabled
    public static Applicant__c getCurrentApplicantRecord(String applicantId){
        try{
            return  [Select Opportunity__r.Entity_Type__c, Check_Eligibility_Match__c,Opportunity__r.Product_Type__c,Opportunity__r.CRIFF_Report_Initiated__c, Opportunity__r.Customer_Type__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Bureau_Pull_Match__c,PAN_CIN_Match__c,
            Bureau_Pull_Message__c,Check_Eligibility_Message__c,PAN_CIN_Message__c, Declared_income__c,Income_source_available__c,Check_Eligibility_Final_Reason__c,
          (SELECT Id FROM Documents__r WHERE Document_Type__c= 'Form 60'),(select id,CIBIL_Report_URl__c,Equifax_Report_URl__c from CIBIL_Details__r),Opportunity__r.StageName,Opportunity__r.LastStageName__c,Opportunity__r.LeadSource,Journey_Stage__c,CRIFF_Report_URL__c,Opportunity__r.isParentLeadMoreThan30or90Days__c from Applicant__c where id =:applicantId WITH SECURITY_ENFORCED limit 1];//Ola Integration changes
          //CISP-113/CISP-2425 - Added Check_Eligibility_Final_Reason__c field
          //CISP-2378 -- Opportunity__r.StageName,Opportunity__r.LastStageName__c Added
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'getCurrentApplicantRecord', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
    }
    
    
    /*
    * @Method:      gattingCheckEligibility
    * @Created by:  Neha G.
    * @Description: This method will check Loan Eligibility and attempts count for applicant 
    *               (Borrower/Co-borrower) - IND-347
    * @Param:       String - current Applicant ID
    * @Param:       String - loanApplication ID
    * @Return:      String - Serialized JSON response
    */
    @AuraEnabled
    public static string gattingCheckEligibility(String applicantId,String loanApplicationId ){
        try{
            System.debug('Check Id :'+applicantId+' - '+loanApplicationId);
            List<Applicant__c> listOfApplicant = [Select Id, Applicant_Type__c,Income_source_available__c, Income_Source__c, Bureau_Pull_Match__c,Bureau_Pull_Message__c, Do_you_have_a_bank_account__c, Would_you_like_to_open_a_bank_account__c,In_Active_Applicant__c,Check_Eligibility_Retry_Attempts__c From Applicant__c where Opportunity__c =: loanApplicationId WITH SECURITY_ENFORCED];
            List<Applicant__c> listCoborrowers = new List<Applicant__c>();
            Applicant__c applObject = new Applicant__c();
                                    
            if(listOfApplicant.size() > 1){
                for(Applicant__c applicant : listOfApplicant){
                    if((applicant.Applicant_Type__c == System.label.CoBorrower || applicant.Applicant_Type__c == System.Label.Beneficiary || applicant.Applicant_Type__c == System.label.Guarantor) && applicant.In_Active_Applicant__c == false){
                        listCoborrowers.add(applicant);                      
                    }
                    if(applicant.Applicant_Type__c == System.label.Borrower){
                        applObject = applicant;                      
                    }
                }
            }else{
                applObject = listOfApplicant[0];    
            }
            
            for(Applicant__c coborrower : listCoborrowers){
                if(coborrower.Applicant_Type__c == System.label.CoBorrower && coborrower.Bureau_Pull_Match__c == false && coborrower.Bureau_Pull_Message__c != System.label.Retry_Exhausted){
                    return System.label.BureauPull_CoBorrower;   
                }else if(coborrower.Applicant_Type__c == System.label.Guarantor && coborrower.Bureau_Pull_Match__c == false && coborrower.Bureau_Pull_Message__c != System.label.Retry_Exhausted){
                    return 'Please check the Bureau Pull for Guarantor First';
                }else if(coborrower.Applicant_Type__c == System.label.Beneficiary && coborrower.Bureau_Pull_Match__c == false && coborrower.Bureau_Pull_Message__c != System.label.Retry_Exhausted){
                    return 'Please check the Bureau Pull for Beneficiary First';   
                }else if((coborrower.Do_you_have_a_bank_account__c==false && applObject.Do_you_have_a_bank_account__c==false && coborrower.Would_you_like_to_open_a_bank_account__c ==false) && coborrower.Do_you_have_a_bank_account__c){
                    return System.label.CheckBankAccountForBorrowerAndCoborrower;
                }
            }
            // if(!listCoborrowers.isEmpty() && (listCoborrowers[0].Bureau_Pull_Match__c == false && listCoborrowers[0].Bureau_Pull_Message__c != System.label.Retry_Exhausted)){
            //     return System.label.BureauPull_CoBorrower;   
            // }
            // //Checks if “Having Bank Account?” checkbox is false for borrower and Co-borrower & “willing to open bank account with IIB” checkbox is false for “Co-borrower”
            // else if(!listCoborrowers.isEmpty() && listCoborrowers[0].Do_you_have_a_bank_account__c==false && applObject.Do_you_have_a_bank_account__c==false && listCoborrowers[0].Would_you_like_to_open_a_bank_account__c ==false){
            //     return System.label.CheckBankAccountForBorrowerAndCoborrower;
            // } 
            return 'Success';
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'gattingCheckEligibility', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage); 
            //throw e;       
        }         
    }
    //End: gattingCheckEligibility()
    
    
    /*
    * @Method:      getDocumentPANonApplicantId
    * @Created by:  Sathyanarayana Somayajula
    * @Description: This method will get the PAN from Document on Applicant Id (Borrower/Co-borrower)
    * @Param:       String - current Applicant ID
    * @Return:      String - PAN Number
    */
    
    public static Set<String> getDocumentPANonApplicantId(String applicantId){
        
        List<Documents__c> documentsPAN=[Select Id, PAN_No__c, Applicant__r.In_Active_Applicant__c,
                                         Applicant__r.Applicant_Type__c, Applicant__r.id 
                                         from 	Documents__c 
                                         where  Applicant__r.id=:applicantId WITH SECURITY_ENFORCED];
        
        Set<String> panList=new Set<String>();
        if(documentsPAN!=null && documentsPAN.size()>0){
            for(Documents__c document:documentsPAN){
                if(String.isNotBlank(document.PAN_No__c))
                    panList.add(document.PAN_No__c);
            }
            return panList;
        }
        return null;
    }
    
    /*
    * @Method:      getCustDedupeResForPANCINonApplicantId
    * @Created by:  Sathyanarayana Somayajula
    * @Description: This method will check the PAN in CUstomer Dedupe Response on Applicant Id (Borrower/Co-borrower)
    * @Param:       String - Applicant ID, panNumber
    * @Return:      Boolean
    */
    public static Map<String,String> getCustDedupeResForPANCINonApplicantId(String applicantId, Set<String> panNumbers){
        List<Customer_Dedupe_Response__c> custDedupeResList=[Select Id, CIN_No__c,Applicant__r.id , Response__c,
                                                             SF_Cust_Dedupe__c, createdDate 
                                                             from   Customer_Dedupe_Response__c 
                                                             where Applicant__r.id=:applicantId WITH SECURITY_ENFORCED
                                                             order by createdDate  desc 
                                                            ];
        Map<String,String> statusesMap=new Map<String,String>();
        if(!custDedupeResList.isEmpty()){
            Customer_Dedupe_Response__c custDedupeRes=custDedupeResList[0];
            String responsePan=String.valueOf(custDedupeRes.Response__c).substringBetween(System.Label.Customer_Dedupe_Response_PAN, ']');
            String responseCIN=String.valueOf(custDedupeRes.Response__c).substringBetween(System.Label.Customer_Dedupe_Response_CIN, ']');
            System.debug('responsePan :'+responsePan+', responseCIN:  '+responseCIN);
            if(!String.isBlank(responsePan)){
                statusesMap.put('PAN Found',responsePan);
            }            
            if(!String.isBlank(responseCIN)){
                 statusesMap.put('CIN Found',responsePan);
             }
        }else{
           statusesMap.put('No Customer DedupeResponse','Customer Dedupe Response Not Found'); 
        }
        return statusesMap;
    }    
    
    /*
    * @Method:      addAdditionalDetails
    * @Created by:  Devanshu Gupta
    * @Description: This method will change the status of the Loan Application to Addition Details Capture
    * @Param:       String - current Opportunity ID
    * @Return:      String - updated recored Id
    */
    @AuraEnabled
    public static String addAdditionalDetails(String loanApplicationId) {
        try{
            Opportunity oppObj = new Opportunity();
            oppObj.Id = loanApplicationId;
            oppObj.StageName = System.Label.Addition_Details_Capture;
            oppObj.LastStageName__c = System.Label.Addition_Details_Capture;
            update oppObj;
            List<Applicant__c> applicantList = [SELECT ID,Applicant_Type__c,Journey_Stage__c  FROM Applicant__c where Opportunity__c =: loanApplicationId AND Applicant_Type__c <>''];
            if(applicantList.size() > 0) {
                for(Applicant__c appObj :applicantList) {
                    if(appObj.Applicant_Type__c == System.Label.Borrower || appObj.Applicant_Type__c == System.Label.CoBorrower) {
                        appObj.Journey_Stage__c = System.Label.Current_Residential_Address;
                    }
                }
                update applicantList;
            }
            return loanApplicationId;
            
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'addAdditionalDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
        
    }    
    
    /*
    * @Method:      changeCoborrower
    * @Created by:  Sathyanarayana Somayajula
    * @Description: This method will make the coborrower as inactive.
    * @Param:       String - loanApplication ID
    * @Return:      String - loanApplicationId
    * Modified By                Modified Date
    * Chaynnitt Agarwal         28-12-2023
    */
    @AuraEnabled
    public static List<newApplicantWrapper> changeCoborrower(String loanApplicationId, Integer additionCoBorrower, Integer additionGuarantor) {
        try{
            List<Opportunity> oppList = new List<Opportunity>([SELECT Id,Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1]);

            List<newApplicantWrapper> newApplicantIds = new List<newApplicantWrapper>();
            List<Applicant__c> newApplicantToInsert = new List<Applicant__c>();
            Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c>();
            if(additionCoBorrower !=0 ){
                List<Applicant__c> coborrowerApp = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c 
                                                    FROM Applicant__c 
                                                    WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.CoBorrower AND In_Active_Applicant__c = true 
                                                    WITH SECURITY_ENFORCED 
                                                    ORDER BY LASTMODIFIEDDATE
                                                    LIMIT 1];
                applicantMap.put(System.Label.CoBorrower,coborrowerApp[0]);
            }
            if(additionGuarantor != 0){
                List<Applicant__c> guarantorApp = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c 
                                                    FROM Applicant__c 
                                                    WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.Guarantor AND In_Active_Applicant__c = true 
                                                    WITH SECURITY_ENFORCED 
                                                    ORDER BY LASTMODIFIEDDATE
                                                    LIMIT 1];
                applicantMap.put(System.Label.Guarantor,guarantorApp[0]);
            }

            if(applicantMap.size()!=0) {
                for(Integer i=0;i<additionCoBorrower;i++){
                    Applicant__c newApplicant = applicantMap.get(System.Label.CoBorrower).clone(false, false, false, true);
                    newApplicant.Journey_Stage__c = 'User Details';
                    newApplicant.In_Active_Applicant__c = false;
                    newApplicantToInsert.add(newApplicant);
                }
                for(Integer i=0;i<additionGuarantor;i++){
                    Applicant__c newApplicant = applicantMap.get(System.Label.Guarantor).clone(false, false, false, true);
                    newApplicant.Journey_Stage__c = 'User Details';
                    newApplicant.In_Active_Applicant__c = false;
                    newApplicantToInsert.add(newApplicant);
                }
            }

            if(newApplicantToInsert.size()>0){
                if (Schema.sObjectType.Applicant__c.isCreateable()){
                    System.debug('Log - NewApplicant:: '+newApplicantToInsert);
                    insert newApplicantToInsert;
                }
                for(Integer i=0;i<newApplicantToInsert.size();i++){
                    newApplicantIds.add(new newApplicantWrapper(newApplicantToInsert[i].Id,newApplicantToInsert[i].Applicant_Type__c));
                    if(oppList.size() > 0 && oppList[0].Product_Type__c == Label.Tractor){
                        LwcLOSLoanApplicationCntrl.createResiDocument(loanApplicationId,newApplicantToInsert[i].Id);
                    }
                }
            }

            return newApplicantIds;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'changeCoborrower', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
        
    }

    class newApplicantWrapper{
        @AuraEnabled
        public String appId{get;set;}
        @AuraEnabled
        public String appType{get;set;}
        
        public newApplicantWrapper(String id, String type){
            this.appId = id;
            this.appType = type;
        }
    }

     /*
    * @Method:      addCoborrower
    * @Created by:  Raj Gupta
    * @Description: we are adding co-borrower on the response of API.
    * @Param:       String - loanApplication ID
    * @Return:      String - loanApplicationId
    */
    @AuraEnabled
    public static String addCoborrower(String loanApplicationId) {
        try{
            List<Opportunity> oppList = new List<Opportunity>([SELECT Id,Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1]);
            //SFTRAC-567 Start
            List<Applicant__c> coborLst = [SELECT Id 
                                            FROM Applicant__c 
                                            WHERE Applicant_Type__c =: System.Label.CoBorrower AND Opportunity__c =:loanApplicationId AND In_Active_Applicant__c = false 
                                            WITH SECURITY_ENFORCED ];
            if(coborLst.size() >= Integer.valueOf(System.Label.TF_No_Of_CoBorrower)){
                return '';
            }
            //SFTRAC-567 End
            List<Applicant__c> applicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c FROM Applicant__c where Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.Borrower AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            System.debug('Log - applicantList:: '+applicantList);
            String appId = '';
            if(!applicantList.isEmpty()) {
                
                    Applicant__c newApplicant = applicantList[0].clone(false, false, false, true);
                    newApplicant.Journey_Stage__c = 'User Details';
                    newApplicant.In_Active_Applicant__c = false;
                    newApplicant.Applicant_Type__c = System.Label.CoBorrower; 
                    if(oppList.size() > 0 && oppList[0].Product_Type__c == Label.Tractor){
                        newApplicant.IsPrimary__c = LwcLOSLoanApplicationCntrl.isFirstCoborrower(loanApplicationId,System.Label.CoBorrower);
                    }

                    if (Schema.sObjectType.Applicant__c.isCreateable()){
                        System.debug('Log - NewApplicant:: '+newApplicant);
                        insert newApplicant;
                    }

                    appId = newApplicant.Id;

                    if(oppList.size() > 0 && oppList[0].Product_Type__c == Label.Tractor){
                        LwcLOSLoanApplicationCntrl.createResiDocument(loanApplicationId,appId);
                    }
            }

            return appId;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'addCoborrower', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
        
    }

     /*
    * @Method:      coborrowerCount
    * @Created by:  Raj Gupta
    * @Description: to get total of active and Inactive Coborrowers.
    * @Param:       String - loanApplication ID
    * @Return:      String - Count (Integer)
    */
@AuraEnabled
public static Integer coborrowerCount (String loanApplicationId) {
    try{
        ////CISP-2583-START
        Opportunity opp = new Opportunity();
        opp = [Select id, Parent_Loan_Application__c,Revoked_Applicant_Count__c From Opportunity Where Id =: loanApplicationId WITH SECURITY_ENFORCED];
        Integer revokedApplicantCount = 0;
        if(opp.Parent_Loan_Application__c != null){
            revokedApplicantCount = Integer.valueOf(opp.Revoked_Applicant_Count__c);
        }
        //CISP-2583-END
        List<Applicant__c> applicantList = [SELECT ID FROM Applicant__c where Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.CoBorrower WITH SECURITY_ENFORCED];
        Integer count = applicantList.size() + revokedApplicantCount;
        return count;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'coborrowerCount', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage); 
    }
}

//CISP-113/CISP-2425- START
/*
    * @Method:      doInActiveCoBorrower
    * @Created by:  Gaurav
    * @Description: This method will make the coborrower as inactive.
    * @Param:       String - loanApplication ID
    * @Return:      String - loanApplicationId
    * ModifiedBy               ModifiedDate
    * ChaynnittAgarwal         28-12-2023
    */
    @AuraEnabled
    public static List<String> doInActiveCoBorrower(String loanApplicationId, Boolean isCoborrower, List<Integer> num) {
        try{
            Map<Integer,Integer> numMap = new Map<Integer,Integer>();
            for(Integer n: num){
                numMap.put(n,n);
            }
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if(isCoborrower){
                applicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c 
                                FROM Applicant__c 
                                WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.CoBorrower AND In_Active_Applicant__c = false 
                                WITH SECURITY_ENFORCED];
            }else{
                applicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c 
                                FROM Applicant__c 
                                WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.Guarantor AND In_Active_Applicant__c = false 
                                WITH SECURITY_ENFORCED];
            }
            System.debug('Log - applicantList:: '+applicantList);
            List<String> InactiveAppId = new List<String>();

            Integer current = 1;

            for(Applicant__c coborrower: applicantList){
                if(numMap.containsKey(current)){
                    coborrower.In_Active_Applicant__c = true;
                    coborrower.IsPrimary__c = false;
                    InactiveAppId.add(coborrower.Id);
                }
                current++;
            }

            if (Schema.sObjectType.Applicant__c.isUpdateable()){
                update applicantList;
            }

            Boolean isPrimaryCo = false;
            List<Applicant__c> coapplicantList = new List<Applicant__c>();
            coapplicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c,IsPrimary__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.CoBorrower AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED Order By CreatedDate ASC];
            for (Applicant__c coborrower : coapplicantList) {
                if(coborrower.IsPrimary__c == true){
                    isPrimaryCo=true;
                    break;
                }
            }
            if(isPrimaryCo == false && coapplicantList.size() > 0){
                coapplicantList[0].IsPrimary__c = true;
                update coapplicantList[0];
            }
            Boolean isPrimaryBene = false;
            List<Applicant__c> beneapplicantList = new List<Applicant__c>();
            beneapplicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c,IsPrimary__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c = 'Beneficiary' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED Order By CreatedDate ASC];
            for (Applicant__c beneficiary : beneapplicantList) {
                if(beneficiary.IsPrimary__c == true){
                    isPrimaryBene=true;
                    break;
                }
            }
            if(isPrimaryBene == false && beneapplicantList.size() > 0){
                beneapplicantList[0].IsPrimary__c = true;
                update beneapplicantList[0];
            }
            
            // if(!applicantList.isEmpty()) {
            //     applicantList[0].In_Active_Applicant__c = true;
                
            //     if (Schema.sObjectType.Applicant__c.isUpdateable()){
            //         update applicantList;
            //     }
            // }

            return InactiveAppId;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'doInActiveCoBorrower', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
        
    }
    //CISP-113/CISP-2425-END

    /*
    * @Method:      checkRetryExhausted
    * @Created by:  Khushiram
    * @Description: This method will check No of api triggered attempts for applicant (Borrower/Co-borrower)
    * @Param:       String - current Applicant ID
    * @Param:       String - loanApplication ID
    * @Param:       String - attemptFor : For which api number of attempts need to checked
    * @Param:       String - moduleName : Name of module on which the api is being triggered
    * @Return:      String - Success/Failure
    */
        
    @AuraEnabled
    public static String checkRetryExhausted(String loanApplicationId,String attemptFor,String applicantId,String moduleName){
        return checkRetryExhausted(loanApplicationId,attemptFor,applicantId,moduleName,'');
    }
        
    @AuraEnabled
    public static String checkRetryExhausted(String loanApplicationId,String attemptFor,String applicantId,String moduleName, String mtDataName){
        try{
            System.debug('Loan Appliation id :'+loanApplicationId+', attemptFor : '+attemptFor+', applicantId :'+', moduleName: '+moduleName);
            //Null Check 
            if(loanApplicationId != null && attemptFor != null){
                Retry_Count__c retryCount = new Retry_Count__c();
                List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId AND Applicant__c =:applicantId AND Service_Name__c =:attemptFor AND Module__c =: moduleName WITH SECURITY_ENFORCED];
                system.debug('retryCountList::'+retryCountList);
                if(retryCountList.isEmpty()) {
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = attemptFor;
                    retryCount.Applicant__c = applicantId;
                    retryCount.Module__c = moduleName;
                    retryCount.Count__c = 1;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable()){
                        insert retryCount;
                    }
                    return System.Label.SuccessMessage;
                }
                else{
                    System_Constant_custom_metadata__mdt metadata;
                    if(String.isBlank(mtDataName)){
                        metadata = System_Constant_custom_metadata__mdt.getInstance('Retry_Count');
                    }else{
                        metadata = System_Constant_custom_metadata__mdt.getInstance(mtDataName);   
                    }
                    //If number of attempts are greater than predefined number of attempts.
                    Retry_Count__c  count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId AND Applicant__c =:applicantId AND Service_Name__c =:attemptFor AND Module__c =: moduleName WITH SECURITY_ENFORCED limit 1];
                    system.debug('count::'+count.Count__c);
                     system.debug('count::'+metadata.Number_Of_Attempts__c);
                    //CISP-2377
                    if(count.Count__c >= metadata.Number_Of_Attempts__c){
                        return System.Label.Retry_Exhausted;
                    }
                    //If number of attempts are Less than predefined number of attempts.
                    else{
                        count.Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update count;
                        }                    
                        return System.label.SuccessMessage;
                    }
                }
            }
            
            return System.label.FailureMessage;
        }
        //Catch block 
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl' ,'checkRetryExhausted', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

     /*
    * @Method:      getCheckeligibility
    * @Created by:  Rohan
    * @Description: This method will return the checkEligibilitydata
    * @Param:       String - current Applicant ID
    * @Return:      object of applicant record.
    */
    @AuraEnabled
    public static Applicant__c getCheckeligibility(String LoanId, String type){
        try{
          return [SELECT Id,Bureau_Pull_Match__c,Bureau_Pull_Message__c,Check_Eligibility_Match__c,Check_Eligibility_Message__c FROM Applicant__c WHERE Opportunity__c=:LoanId AND Applicant_Type__c = :type LIMIT 1];
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'getCheckeligibility', System.Label.Apex, e);  
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
     /*
    * @Method:      getCoborrowerApplicants
    * @Created by:  Santhosh Guhan
    * @Description: This method will return the CoborrowerApplicants
    * @Param:       String - current Application ID
    * @Return:      object of Co borrower applicant records
    */

    @AuraEnabled(cacheable=false)
    public static List<Applicant__c> getCoborrowerRecords(String LoanId){
        try {
            return [SELECT Name,Applicant_Type__c FROM Applicant__c WHERE Applicant_Type__c IN ('Co-Borrower','Guarantor','Beneficiary') AND In_Active_Applicant__c = FALSE AND Opportunity__c=:LoanId Order By CreatedDate ASC];
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'getCoborrowerRecords', System.Label.Apex, e);  
            throw new AuraHandledException(System.Label.ExceptionMessage);          
        }
    }
     /*
    * @Method:      removeCoborrowerApplicants
    * @Created by:  Santhosh Guhan
    * @Description: This method will inactivate the CoborrowerApplicants
    * @Param:       String - current Applicant ID
    * @Return:      void
    */

    @AuraEnabled
    public static void removeCoborrowerRecords(List<Id> appIds){
        try {
            List<Applicant__c> updApp = new List<Applicant__c>();
            List<Applicant__c> listApp = [SELECT Name,Opportunity__c FROM Applicant__c WHERE Id IN:appIds];
            String loanApplicationId = listApp.size() > 0 ? listApp[0].Opportunity__c : null;
            for(Applicant__c app :listApp){
                app.In_Active_Applicant__c = true;
                app.IsPrimary__c = false;
                updApp.add(app);
            }
            update updApp;
            Boolean isPrimaryCo = false;
            List<Applicant__c> coapplicantList = new List<Applicant__c>();
            coapplicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c,IsPrimary__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: System.Label.CoBorrower AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED Order By CreatedDate ASC];
            for (Applicant__c coborrower : coapplicantList) {
                if(coborrower.IsPrimary__c == true){
                    isPrimaryCo=true;
                    break;
                }
            }
            if(isPrimaryCo == false && coapplicantList.size() > 0){
                coapplicantList[0].IsPrimary__c = true;
                update coapplicantList[0];
            }
            Boolean isPrimaryBene = false;
            List<Applicant__c> beneapplicantList = new List<Applicant__c>();
            beneapplicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c,IsPrimary__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c = 'Beneficiary' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED Order By CreatedDate ASC];
            for (Applicant__c beneficiary : beneapplicantList) {
                if(beneficiary.IsPrimary__c == true){
                    isPrimaryBene=true;
                    break;
                }
            }
            if(isPrimaryBene == false && beneapplicantList.size() > 0){
                beneapplicantList[0].IsPrimary__c = true;
                update beneapplicantList[0];
            }
            if(listApp.size() > 0){
                String rcuRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();
                List<Case> rcuCaseList = new List<Case>([Select id from Case Where RecordTypeId =: rcuRecordTypeId and Loan_Application__c =: listApp[0].Opportunity__c]);
                List<Documents__c> documentList = new List<Documents__c>([SELECT Id from Documents__c Where RCU_Case__c IN : rcuCaseList AND Applicant__c IN : listApp]);
                if(documentList.size() > 0){
                    for (Documents__c document : documentList) {
                        document.RCU_Case__c = null;
                    }
                    update documentList;
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'removeCoborrowerRecords', System.Label.Apex, e);  
            throw new AuraHandledException(System.Label.ExceptionMessage);          
        }
    }
}