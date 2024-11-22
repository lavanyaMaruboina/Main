public without sharing class AmlCheckData {
    /**********************************************
    * @Commented By:  Daksh Mandowara
    * @UserStory:  Feature 8.2.23 - AML Check 
    * @Purpose: Created wrapper to save AML data from API into custom object
    ***********************************************/
   public class AmlDataWrapper{  
        public string id{get;set;}
        public Double score{get;set;}
        public String listName{get;set;}
        public String name{get;set;}
        public String nationality{get;set;}
   }
   /**********************************************
    * @Commented By:  Daksh Mandowara
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: Pass Aml records with ProfileName
    ***********************************************/
   public class AmlProfileDetails{
       @AuraEnabled public List<AML_Check__c> amlResultList{get;set;}
       @AuraEnabled public String profileName{get;set;}
   }
    /**********************************************
    * @Author:  Daksh Mandowara
    * @ModifiedDate: 22/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Execute: When API calls for iniating AML Check
    * @Purpose: To store received response from AML Check API to AML Check object.
    ***********************************************/
   @AuraEnabled//(continuation=true)
    public static String insertObjectRecords(String resp, String loanApplicationId, String applicantNumber, String amlCaseId){
        try{
            Case cs;
            AmlResponse amlResponse = (AmlResponse) JSON.deserialize(resp,AmlResponse.class);
            list<AML_Check__c> existingAML = new list<AML_Check__c>();
            list<MatchedRecords> matchedRecords = new list<MatchedRecords>();
            if(amlResponse.wlMatch!=null && amlResponse.wlMatch.matchedResults!=null && amlResponse.wlMatch.matchedResults.matchedRecords!=null){
                matchedRecords = amlResponse.wlMatch.matchedResults.matchedRecords;
            }
            
            List<AML_Check__c> amlChecks =new List<AML_Check__c>();
            List<Opportunity> loanApp = [SELECT Name,OwnerId,AccountId FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED];
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            if(String.isNotBlank(amlCaseId)){
                cs = new Case(Id=amlCaseId);
                existingAML = [Select Id from AML_Check__c where Case__c = :amlCaseId limit 1];
            }
            if(!matchedRecords.isEmpty()){
                if(!loanApp.isEmpty()){
                    
                        try{
                            //Duplicate record creation start 
                        cs = new Case(Subject=loanApp[0].Name+'_AML Check',Status='Pending with BE_CVO',Loan_Application__c=loanApplicationId,Origin='Web',OwnerId=loanApp[0].OwnerId,Priority='Medium',RecordTypeId=caseRecordTypeId,AccountId=loanApp[0].AccountId, Loan_Number__c= loanApp[0].Name+' AML');
                        insert cs;
                        }catch(exception e){System.debug('Exception: ' + e);}  //Duplicate record creation end 
                    
                }
                for(MatchedRecords matchedRecord : matchedRecords){
                    AML_Check__c amlCheck = new AML_Check__c();
                    amlCheck.Score__c = Decimal.valueOf(matchedRecord.score).setScale(4)*100;
                    amlCheck.List_Name__c = matchedRecord.listName;
                    amlCheck.ML_Id__c = matchedRecord.id;
                    amlCheck.Matched_base__c = matchedRecord.id;
                    if(matchedRecord.DateOfBirth!=null){
                        amlCheck.ML_Date_Of_Birth__c = matchedRecord.DateOfBirth;
                    }
                if(matchedRecord.address != null && matchedRecord.address != '' && matchedRecord.address.length() > 255){
                    amlCheck.ML_Address__c  = matchedRecord.address.left(255);
                }else{
                    amlCheck.ML_Address__c = matchedRecord.address;
                }
                    amlCheck.ML_City__c = matchedRecord.city;
                    amlCheck.Partial_KYC_Flag__c = matchedRecord.partialKycFlag;
                    amlCheck.ML_Description__c = matchedRecord.description;
                    if(cs!=null){
                        amlCheck.Case__c = cs.Id;
                    }
                    for(Field f : matchedRecord.fields){
                        if(f.name.equals('name')){
                            amlCheck.Name__c = String.valueOf(f.value);
                            amlCheck.Name_Score__c = f.score.setScale(4)*100;
                        }
                        if(f.name.equals('nationality')){
                            amlCheck.Nationality__c = String.valueOf(f.value);
                            amlCheck.Nationality_Score__c = f.score.setScale(4)*100;
                        }
                    }
                    amlCheck.Loan_Application__c = loanApplicationId;
                    amlCheck.Applicant_Number__c = applicantNumber;
                    amlChecks.add(amlCheck);
                }
            }
            
            Map<Id,Opportunity> opps = new Map<Id,Opportunity>();
            
            Opportunity opp;
            
            if(!amlChecks.isEmpty()){
                insert amlChecks;
                /*boolean matchFound = false;
                for(AML_Check__c amlCheck : amlChecks){
                    if(!matchFound) {
                        if(amlCheck.Score__c>95 && !amlCheck.Partial_KYC_Flag__c){
                            matchFound = true;
                        }
                    } 
                }*/
                opp = new Opportunity();
                opp.Id = loanApplicationId;
                opp.Received_AML_API_response__c = TRUE;
                opp.AML_Check_Completed__c = FALSE;
                opp.AML_Check_status__c = '';
                opps.put(opp.Id,opp);
                if(!opps.keySet().isEmpty()){
                    update opps.values();
                    if(cs!=null)
                        return System.label.AMLrecordsaved+'_'+cs.Id;
                    else
                        return System.label.AMLrecordsaved;
                }
            }else{
                if(existingAML.isEmpty() && String.isBlank(amlCaseId)) {
                    opp = new Opportunity();
                    opp.Id = loanApplicationId;
                    opp.AML_Check_Completed__c = TRUE;
                    opp.AML_Check_status__c = 'Approved';
                    opps.put(opp.Id,opp);
                }

            }
            
            if(!opps.keySet().isEmpty()){
                update opps.values();
                return System.label.NoAMLchecklistfound;
            }else{
                return 'Error';
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'insertObjectRecords', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage()+' '+e.getStackTraceString());

        }
    }       
   
    /**********************************************
    * @Comment By:  Daksh Mandowara
    * @ModifiedDate: 23/05/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To disable the Initialising AML if already once executed.
    ***********************************************/
   @AuraEnabled(cacheable=true)
   public static boolean disableInitiateAML(String loanApplicationId){
       try{
            List<Opportunity> opp = [SELECT Id,AML_Check_Completed__c, OwnerId FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED];
            if(!opp.isEmpty()){
                    if(opp[0].AML_Check_Completed__c || opp[0].OwnerId != UserInfo.getUserId()){
                        return true;
                    }else{
                        List<Case> caseList = [SELECT Id FROM Case WHERE Loan_Application__c = :loanApplicationId AND RecordType.Name = 'AML Check' WITH SECURITY_ENFORCED LIMIT 1];
                        if(!caseList.isEmpty()){
                            return true;
                        }
                    }
            }
            return false;
       }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'disableInitiateAML', System.Label.Apex, e);
           throw new AuraHandledException(e.getStackTraceString());
       }
   }
   @AuraEnabled(cacheable=true)
   public static List<Applicant__c> getLoanApplicants(String loanApplicationId){
       try{
           List<Applicant__c> applicants = [SELECT Id,Applicant_Type__c,Bank_Account_No__c FROM Applicant__c WHERE Opportunity__c = :loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
           if(!applicants.isEmpty()){
               return applicants;
           }
           return null;
       }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'getBorrowerLoanApplicant', System.Label.Apex, e);
           throw new AuraHandledException(e.getStackTraceString());
       }
   }
   @AuraEnabled(cacheable=true)
    public static List<Applicant__c> getBorrowerLoanApplicant(String loanApplicationId){
        try{
            List<Applicant__c> applicantList = [SELECT Id,Applicant_Type__c,applicant_number__c FROM Applicant__c WHERE Opportunity__c = :loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
           if(!applicantList.isEmpty()){
               return applicantList;
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'getBorrowerLoanApplicant', System.Label.Apex, e);
            throw new AuraHandledException(e.getStackTraceString());
        }
       
   }
   /**********************************************
    * @Comment By:  Daksh Mandowara
    * @ModifiedDate: 08/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches as per user's profile.
    ***********************************************/
   @AuraEnabled(cacheable=true)
   public static AmlProfileDetails getProfile(String caseStatus, String loanApplicationId){
       try {
           List<AML_Check__c> amlResultList = new List<AML_Check__c>();
           AmlProfileDetails AmlProfileDetail = new AmlProfileDetails();
           Id profileid = userinfo.getProfileId();
           Profile profileName = [Select Name from Profile where id =: profileid];
           AmlProfileDetail.profileName = profileName.Name;
           if(profileName.Name == 'IBL Business Executive'|| profileName.Name == 'IBL TF Business Executive' || profileName.Name == 'IBL Partner Community TF Business Executive' ||
           profileName.Name.contains('CVO')){
               amlResultList = getPenBECVO(loanApplicationId);
           }else if(profileName.Name == 'CMU'){
               amlResultList = getPenCMU(loanApplicationId);
           }else if(profileName.Name == 'IBL Credit Analyst' || profileName.Name == 'IBL National Credit Manager'){
               amlResultList = getPenCA(loanApplicationId);
           }else if(profileName.Name == 'IBL State Credit Manager' || profileName.Name == 'IBL Zonal Credit Manager'){ //SFTRAC-89
                amlResultList = getPenSCM_ZCM(loanApplicationId);
           }else if(profileName.Name == 'IBL Credit Head'){
               amlResultList = getPenCH(loanApplicationId);
           }else if(profileName.Name == 'System Administrator'){
               amlResultList= getAllAMLRecords(caseStatus,loanApplicationId);
           }   
		   System.debug('amlResultList : ' + amlResultList);
           AmlProfileDetail.amlResultList = amlResultList;
           return AmlProfileDetail;
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
   
   /**********************************************
    * @Comment By:  Daksh Mandowara
    * @ModifiedDate: 08/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for BE/CVO.
    ***********************************************/
   @AuraEnabled
   public static List<AML_Check__c> getPenBECVO(String laId) 
   {
        List<AML_Check__c> PenBECVOList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                                            ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                           ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                           Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                                           CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                           Case__c,Case__r.Status FROM AML_Check__c WHERE
                                           Case__r.Status =: System.label.PendingBECVO AND Score__c>=95 AND Partial_KYC_Flag__c=false AND Case__r.Loan_Application__c =:laId
                                           WITH SECURITY_ENFORCED];
                                          
       return PenBECVOList;
   }
    
    /**********************************************
    * @Comment By:  Daksh Mandowara
    * @ModifiedDate: 08/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for CMU.
    ***********************************************/
   @AuraEnabled
   public static List<AML_Check__c> getPenCMU(String laId) 
   {
        List<AML_Check__c> PenCMUList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                                         ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                        ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                        Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                                        CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                        Case__c,Case__r.Status FROM AML_Check__c
                                        WHERE BE_CVO_Decision__c = 'False Positive' 
                                        AND Case__r.Status =: System.label.PendingCMU AND Case__r.Loan_Application__c =:laId
                                        WITH SECURITY_ENFORCED];
       return PenCMUList;
   }

    /**********************************************
    * @Comment By:  Daksh Mandowara
    * @ModifiedDate: 08/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for CMU.
    ***********************************************/
    @AuraEnabled
    public static List<AML_Check__c> getPenCMUbefore(String laId) 
    {
         List<AML_Check__c> PenCMUList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                                          ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                         ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                         Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                                         CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                         Case__c,Case__r.Status FROM AML_Check__c
                                         WHERE BE_CVO_Decision__c = 'False Positive' 
                                         AND Case__r.Status =: System.label.PendingBECVO AND Case__r.Loan_Application__c =:laId
                                         WITH SECURITY_ENFORCED];
        return PenCMUList;
    }
    
    /**********************************************
    * @Comment By:  Daksh Mandowara
    * @ModifiedDate: 08/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for CA.
    ***********************************************/
   @AuraEnabled
   public static List<AML_Check__c> getPenCA(String laId) 
   {
        List<AML_Check__c> PenCAList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                                         ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                        ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                        Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                                        CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                        Case__c,Case__r.Status  FROM AML_Check__c 
                                        WHERE ((BE_CVO_Decision__c = 'Positive' OR CMU_Decision__c='Positive' OR Partial_KYC_Flag__c=true)
                                        AND Case__r.Status =: System.label.Pendingcreditanalyst) AND Case__r.Loan_Application__c =:laId
                                        WITH SECURITY_ENFORCED];
       return PenCAList;
   }

   /**********************************************
    * @Comment By:  Utakarsh maurya
    * @ModifiedDate: 26/12/2023
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for SCM/ZCM
    ***********************************************/
    @AuraEnabled
    public static List<AML_Check__c> getPenSCM_ZCM(String laId) //SFTRAC-89
    {
         List<AML_Check__c> PenCAList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                                          ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                         ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                         Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                                         CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                         Case__c,Case__r.Status  FROM AML_Check__c 
                                         WHERE ((BE_CVO_Decision__c = 'Positive' OR CMU_Decision__c='Positive' OR Partial_KYC_Flag__c=true)
                                         AND Case__r.Status =: System.label.PendingWithSCM_ZCM) AND Case__r.Loan_Application__c =:laId
                                         WITH SECURITY_ENFORCED];
        return PenCAList;
    }
    
   /**********************************************
    * @Comment By:  Daksh Mandowara
    * @ModifiedDate: 08/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for CA.
    ***********************************************/
    @AuraEnabled
    public static List<AML_Check__c> getPenCAbefore(String laId) 
    {
         List<AML_Check__c> PenCAList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                                          ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                         ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                         Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                                         CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                         Case__c,Case__r.Status  FROM AML_Check__c 
                                         WHERE ((BE_CVO_Decision__c = 'Positive' OR CMU_Decision__c='Positive' OR Partial_KYC_Flag__c=true)
                                         AND Case__r.Status =: System.label.PendingCMU) AND Case__r.Loan_Application__c =:laId
                                         WITH SECURITY_ENFORCED];
        return PenCAList;
    }

       /* @Comment By:  Gaurav Rawat
    * @ModifiedDate: 03/02/2023
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for CH.
    ***********************************************/
   @AuraEnabled
   public static List<AML_Check__c> getPenCH(String laId) 
   {
        List<AML_Check__c> PenCAList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                                         ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                        ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                        Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                                        CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                        Case__c,Case__r.Status  FROM AML_Check__c 
                                        WHERE ((BE_CVO_Decision__c = 'Positive' OR CMU_Decision__c='Positive' OR CA_Decision__c='Positive' OR Partial_KYC_Flag__c=true)
                                        AND Case__r.Status =: System.label.Pendingcredithead) AND Case__r.Loan_Application__c =:laId
                                        WITH SECURITY_ENFORCED];
       return PenCAList;
   }
   

    /**********************************************
    * @Comment By:  Kruthi Nadig
    * @ModifiedDate: 18/07/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all pending matches for CH.
    ***********************************************/
   @AuraEnabled
   public static List<AML_Check__c> getPenCHbefore(String laId) 
   {
    List<AML_Check__c> PenCHList = [SELECT Id, Credit_Head__c, Matched_base__c,List_Name__c,Name__c,Name_Score__c,
                                    ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                    ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                    Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,Documents__c, Content_Document_Id__c,
                                    CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                    Case__c,Case__r.Status,Case__r.OwnerId,case__r.Loan_Application__r.AML_Check_Completed__c FROM AML_Check__c WHERE 
                                    CA_Decision__c = 'Positive' AND ((Case__r.Status =: System.label.Pendingcreditanalyst) OR (Case__r.Status =: System.label.PendingWithSCM_ZCM AND Case__r.Product_Type__c =: System.Label.Tractor)) AND Loan_Application__c =:laId WITH SECURITY_ENFORCED];
       return PenCHList;
   }

   /**********************************************
    * @Comment By:  Kruthi Nadig
    * @ModifiedDate: 18/07/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To Approve AML.
    ***********************************************/
    @AuraEnabled
    public static void approveAML(String laId) 
    {
     Opportunity opp = new Opportunity(Id = laId);
     opp.AML_Check_status__c = 'Approved';
     opp.AML_Check_Completed__c = TRUE;
     update opp;
    }
   
   /**********************************************
    * @Author:  Daksh Mandowara
    * @ModifiedDate: 08/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get all the pending matches of loan application
    ***********************************************/
  @AuraEnabled
   public static List<AML_Check__c> getAllAMLRecords(String caseStatus,String loanApplicationId) {
       List<AML_Check__c> PenAllList;
      if(String.isBlank(caseStatus) && String.isNotBlank(loanApplicationId)){
            PenAllList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                            ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                           ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                           Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                           Case__c,CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                           Case__r.Status FROM AML_Check__c WHERE Loan_Application__c = :loanApplicationId WITH SECURITY_ENFORCED];
      }else if(String.isNotBlank(loanApplicationId)){
            PenAllList =  [SELECT Id, Partial_KYC_Flag__c,Matched_base__c,Applicant_Number__c,List_Name__c,Name__c,Name_Score__c,
                            ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                           ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                           Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,
                           Case__c,CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                           Case__r.Status FROM AML_Check__c WHERE Case__r.Status = :caseStatus AND Loan_Application__c = :loanApplicationId WITH SECURITY_ENFORCED];
      }
      for(AML_Check__c check : PenAllList){
           if(String.isBlank(check.BE_CVO_Decision__c)){
               check.BE_CVO_Decision__c = '';
           }
           if(String.isBlank(check.CMU_Decision__c)){
               check.CMU_Decision__c = '';
           }
           if(String.isBlank(check.CA_Decision__c)){
               check.CA_Decision__c = '';
           }
           if(String.isBlank(check.CH_Decision__c)){
               check.CH_Decision__c = '';
           }
           if(String.isBlank(check.Remarks_BE_CVO__c)){
               check.Remarks_BE_CVO__c = '';
           }
           if(String.isBlank(check.Remarks_CMU__c)){
               check.Remarks_CMU__c = '';
           }
           if(String.isBlank(check.Remarks_Credit_Analyst__c)){
               check.Remarks_Credit_Analyst__c = '';
           }
           if(String.isBlank(check.Remarks_Credit_Head__c)){
               check.Remarks_Credit_Head__c = '';
           }
      }
      return PenAllList;
  }
 
   /**********************************************
    * @Author:  Daksh Mandowara
    * @ModifiedDate: 04/05/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To check whether CAM is generated on submitting AML Checks to CA, 
    *          if CAM is generated update Loan Application's 'AML Check to CA' field to true.
    ************************************************/ 
   public static void submitAMLCheckToCA(String loanApplicationId){
       try{
           //List<CAM__c> CamList =[SELECT Id,Loan_Application__c FROM CAM__c WHERE Loan_Application__c =:loanApplicationId];
           List<Opportunity> updatedOpps = new List<Opportunity>();
                   Opportunity opp = new Opportunity();
                   opp.Id = loanApplicationId;
                   opp.Submit_AML_Check_To_CA__c = TRUE;
                   updatedOpps.add(opp);
               if(!updatedOpps.isEmpty()){
                   update updatedOpps;
               }
       }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'submitAMLCheckToCA', System.Label.Apex, e);   
       }
       
   }
   /**********************************************
    * @Author:  Daksh Mandowara
    * @ModifiedDate: 04/05/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Execute: On CAM Generation
    * @Purpose: To check whether AML Checks are submitted to CA, 
    *          if it is sumitted to CA update Loan Application's 'AML Check to CA' field to true.
    ************************************************/ 
   public static void updateAMLCheckToCA(String loanApplicationId){
       try{
           List<Opportunity> loanApp = [SELECT AccountId,Submit_AML_Check_To_CA__c,AML_Check_Completed__c FROM Opportunity WHERE Id = :loanApplicationId AND Submit_AML_Check_To_CA__c = TRUE AND AML_Check_Completed__c = FALSE WITH SECURITY_ENFORCED LIMIT 1];
           if(!loanApp.isEmpty()){
           List<AccountTeamMember> teamMembers = [SELECT Id,TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId = :loanApp[0].AccountId WITH SECURITY_ENFORCED];
           String chMemberId;
           if(!teamMembers.isEmpty()){
           for(AccountTeamMember atm : teamMembers){
            if(atm.TeamMemberRole != null || atm.TeamMemberRole != '') {
               if(atm.TeamMemberRole.equals('CH')){
                   chMemberId = atm.UserId;
               }
            }
           }
            }   
               Id caseAMLRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
               List<Case> cases = [SELECT Status FROM Case WHERE Loan_Application__c = :loanApplicationId AND Status='Pending with Credit Analyst' AND RecordTypeId = :caseAMLRecordTypeId WITH SECURITY_ENFORCED];
               if(!cases.isEmpty()){
                   for(Case cs : cases){
                       cs.Status = System.label.Pendingcredithead;
                       cs.OwnerId = chMemberId;
                   }
                   update cases;
               }
           }
       }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'updateAMLCheckToCA', System.Label.Apex, e);   
           throw new AuraHandledException(e.getMessage());
       }
   }
   /**********************************************
    * @Author:  Daksh Mandowara
    * @ModifiedDate: 04/05/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To get the AML Approvals for CH in CAM Summary Screen
    ************************************************/ 
   @AuraEnabled
   public static List<AMLApproval> getAMLApprovals(){
       try{
           Id profileid = userinfo.getProfileId();
           Profile chprofile = [Select Name from Profile where Id =: profileid];//CISP-3173 OR //CISP-3173
           Id caseAMLRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
        //    if(chprofile.Name == 'IBL Credit Head' || chprofile.Name == 'System Administrator' ){    //CISP-3173
               List<AMLApproval> amlApprovals = new List<AMLApproval>();
            //    List<Case> amlApprovalCases = [SELECT Loan_Application__c,Loan_Application__r.Name,Loan_Application__r.Account.Name,Loan_Application__r.Agent_BL_code__c,OwnerId,Owner.Name,CreatedDate FROM Case WHERE Status='Pending with Credit Head' AND RecordTypeId = :caseAMLRecordTypeId AND OwnerId = :UserInfo.getUserId() WITH SECURITY_ENFORCED];//CISP-3173
               List<Case> amlApprovalCases = [SELECT Id,Loan_Application__c,Loan_Application__r.Name,Loan_Application__r.Account.Name,Loan_Application__r.Agent_BL_code__c,OwnerId,Owner.Name,CreatedDate FROM Case WHERE Status LIKE '%Pending%' AND RecordTypeId = :caseAMLRecordTypeId AND OwnerId = :UserInfo.getUserId() WITH SECURITY_ENFORCED];//CISP-3173//CISP-3276
               Set<String> blCodes = new Set<String>();
               Map<String,String> branchNames = new Map<String,String>();
               Set<Id> oppIds = new Set<Id>();
               for(Case cs : amlApprovalCases){
                   blCodes.add(cs.Loan_Application__r.Agent_BL_code__c);
                   oppIds.add(cs.Loan_Application__c);
               }
               List<CAM__c> camList = [SELECT Id,Loan_Application__c FROM CAM__c WHERE Loan_Application__c IN :oppIds];    
               List<Bl_Code_Details__c> blCodeDetails = [SELECT Bl_Code__c,BlCodeName__c FROM Bl_Code_Details__c WHERE Bl_Code__c IN :blCodes WITH SECURITY_ENFORCED];
               for(Bl_Code_Details__c bl : blCodeDetails){
                   branchNames.put(bl.Bl_Code__c,bl.BlCodeName__c);
               }
               for(Case cs : amlApprovalCases){
                   AMLApproval aml = new AMLApproval();
                   aml.applicationNo = cs.Loan_Application__r.Name;
                   aml.applicationName = cs.Loan_Application__r.Account.Name;
                   aml.branchName = branchNames.containsKey(cs.Loan_Application__r.Agent_BL_code__c) ? branchNames.get(cs.Loan_Application__r.Agent_BL_code__c) : '';//CISP-3173
                   aml.executiveName = cs.Owner.Name;
                   aml.initiationDatetime = cs.CreatedDate;
                   aml.applicationId = cs.Loan_Application__c;
                   for(CAM__c cam : camList){
                       if(cam.Loan_Application__c.equals(cs.Loan_Application__c)){
                           aml.camId = cam.Id;
                       }
                   }
                   amlApprovals.add(aml);
               }
               if(!amlApprovals.isEmpty()){
                   return amlApprovals;
               }
        //    }//CISP-3173
           return null;
       }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'getAMLApprovals', System.Label.Apex, e);  
           throw new AuraHandledException(e.getMessage());
       }
   }
    /**********************************************
    * @Author:  Daksh Mandowara
    * @ModifiedDate: 25/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Purpose: To update all profile match decesion on AML check Object
    ************************************************/ 
   @AuraEnabled
   public static String updateAmlCheck(List<AML_Check__c> amlRecords,String loanApplicationId,string caseId){
       try{
        Boolean haingAccess = AmlCheckData.accessAMLCase(caseId);
        if(haingAccess){
           List<CAM__c> camList = [SELECT Id FROM CAM__c WHERE Loan_Application__c = :loanApplicationId LIMIT 1];
           Opportunity loanApp = [SELECT Id,Name,Submit_AML_Check_To_CA__c,AML_Check_Completed__c,OwnerId,AccountId,Product_Type__c FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
           List<AccountTeamMember> teamMembers = [SELECT Id,TeamMemberRole,UserId,User.Email,User.Name,User.IsActive FROM AccountTeamMember WHERE AccountId = :loanApp.AccountId AND User.IsActive = TRUE WITH SECURITY_ENFORCED];
           Map<Id,String> userEmails = new Map<Id,String>();
           Map<Id,String> userNames = new Map<Id,String>();
           String caMemberId;
           String chMemberId;
           String ncmMemberId;
           String scmMemberId;//SFTRAC-89
           String zcmMemberId;//SFTRAC-89
           Boolean amlapproved = false;
           for(AccountTeamMember atm : teamMembers){
               userEmails.put(atm.UserId,atm.User.Email);
               userNames.put(atm.UserId,atm.User.Name);
               if(atm.TeamMemberRole != null || atm.TeamMemberRole != null) {
                    if(atm.TeamMemberRole.equals('CA')){
                        caMemberId = atm.UserId;
                    }
                    if(atm.TeamMemberRole.equals('CH')){
                        chMemberId = atm.UserId;
                    }
                    if(atm.TeamMemberRole.equals('NCM')) {
                        ncmMemberId = atm.UserId;
                    }
                    if(atm.TeamMemberRole.equals('SCM')) {//SFTRAC-89
                        scmMemberId = atm.UserId;
                    }
                    if(atm.TeamMemberRole.equals('ZCM')) {//SFTRAC-89
                        zcmMemberId = atm.UserId;
                    }
                }
           }
           AmlProfileDetails AmlProfileDetail = new AmlProfileDetails();
           Id profileid = UserInfo.getProfileId();
           Profile profileName = [Select Name from Profile where id =: profileid];
           List<Group> AMLQueues = [SELECT Id,Name FROM Group WHERE Type = 'Queue'];
           Map<String,Id> queueIds = new Map<String,Id>();
            String CMUQueueId = '';
            for(Group gp : AMLQueues){
                queueIds.put(gp.Name,gp.Id);
                if(gp.Name.equals('CMU')){
                    CMUQueueId = gp.Id;
                }
            }
            List<String> queueEmailAddresses = new List<String>();
            List<String> queueUserIds = new List<String>();
            if(String.isNotBlank(CMUQueueId)){
                for(GroupMember gm :[Select UserOrGroupId From GroupMember where GroupId =:CMUQueueId]){
                    if(gm.UserOrGroupId.getSObjectType().getDescribe().getName().equals('User')){
                        queueUserIds.add(gm.UserOrGroupId);
                    }
                }
            }

            if(!queueUserIds.isEmpty()){
                for(User qu : [SELECT Id,Email FROM User WHERE Id IN :queueUserIds]){
                    queueEmailAddresses.add(qu.Email);
                }
            }
           set<Id> caseIds = new set<Id>();
           Map<Id,Case> cases = new Map<Id,Case>();
           Map<Id,AML_Check__c> amlChecks = new Map<Id,AML_Check__c>();
           String matchFoundForCMU = 'N/A';
           
           if(!amlRecords.isEmpty()){
                Update amlRecords;
               for(AML_Check__c amlrec : amlRecords){
                   amlChecks.put(amlrec.Id,amlrec);
                   if(profileName.Name == 'IBL Business Executive' || profileName.Name == 'IBL TF Business Executive' ||
                        profileName.Name == 'IBL Partner Community TF Business Executive' || profileName.Name.contains('CVO')){
                       amlrec.BE_CVO__c = TRUE;
                   }
                   if(profileName.Name == 'CMU'){
                       amlrec.CMU__c = TRUE;
                   }
                   
                   if(profileName.Name == 'IBL Credit Analyst' || profileName.Name == 'IBL National Credit Manager' || profileName.Name == 'IBL State Credit Manager' || profileName.Name == 'IBL Zonal Credit Manager'){
                    amlrec.Credit_Analyst__c = TRUE;
                        }

                    if(profileName.Name == 'IBL Credit Head'){
                            amlrec.Credit_Head__c = TRUE;
                    }
                   
               }
               
                Case cs = new Case();
                   
                   if(profileName.Name == 'System Administrator'){
                     cs.Status = System.label.PendingBECVO;
                     cs.OwnerId = loanApp.OwnerId;
                     cs.Id = caseId;
                     cases.put(cs.Id,cs);  
                   }
                   if(profileName.Name == 'IBL Business Executive' || profileName.Name == 'IBL TF Business Executive' ||
                    profileName.Name == 'IBL Partner Community TF Business Executive' || profileName.Name.contains('CVO')){
                        list<AML_Check__c> amllist = new list<AML_Check__c>();
                        amllist = getPenCMUbefore(loanApplicationId);
                        if(!amllist.isEmpty()) {
                            cs.Status = System.label.PendingCMU; 
                            cs.OwnerId = queueIds.get('CMU');
                        } else {
                            if(loanApp.Product_Type__c == 'Tractor')  {//SFTRAC-89
                                cs.Status = System.label.PendingWithSCM_ZCM;
                                cs.OwnerId = String.isNotBlank(scmMemberId)? scmMemberId : zcmMemberId;
                            } else if(loanApp.Product_Type__c == 'Passenger Vehicles')  {
                                cs.Status = System.label.Pendingcreditanalyst;
                                cs.OwnerId = caMemberId;
                            } else {
                                cs.Status = System.label.Pendingcreditanalyst;
                                cs.OwnerId = ncmMemberId;
                            }
                        }
                       cs.Id = caseId;
                       cases.put(cs.Id,cs);
                   }
                   if(profileName.Name == 'CMU'){
                       list<AML_Check__c> amllist = new list<AML_Check__c>();
                        amllist = getPenCAbefore(loanApplicationId);
                        if(!amllist.isEmpty()) {
                            if(loanApp.Product_Type__c == 'Tractor')  {//SFTRAC-89
                                cs.Status = System.label.PendingWithSCM_ZCM;
                                cs.OwnerId = String.isNotBlank(scmMemberId)? scmMemberId : zcmMemberId;
                        } else if(loanApp.Product_Type__c == 'Passenger Vehicles')  {
                            cs.Status = System.label.Pendingcreditanalyst; 
                            cs.OwnerId = caMemberId;
                        } else {
                            cs.Status = System.label.Pendingcreditanalyst; 
                            cs.OwnerId = ncmMemberId;
                        }
                        } else {
                        approveAML(loanApplicationId);
                        amlapproved = true;
                        cs.Status = 'Closed';
                       }
                       cs.Id = caseId;
                       cases.put(cs.Id,cs);
                   }
                   
                   if(profileName.Name == 'IBL Credit Analyst' || profileName.Name == 'IBL National Credit Manager' || profileName.Name == 'IBL State Credit Manager' || profileName.Name == 'IBL Zonal Credit Manager'){
                       //loanApp.Submit_AML_Check_To_CA__c = TRUE;
                       list<AML_Check__c> amllist = new list<AML_Check__c>();
                        amllist = getPenCHbefore(loanApplicationId);
                        submitAMLCheckToCA(loanApplicationId);
                        if(!amllist.isEmpty()) {
                        
                            if(!camList.isEmpty()){
                                cs.Status = System.label.Pendingcredithead;
                                cs.OwnerId = chMemberId;
                                cs.Id = caseId;
                                cases.put(cs.Id,cs);
                            }else{
                                return 'false';
                            }
                        } else {
                            approveAML(loanApplicationId);
                            amlapproved = true;
                            cs.Status = 'Closed';
                            cs.Id = caseId;
                            cases.put(cs.Id,cs);
                        }
                        
                   }

                   if(profileName.Name == 'IBL Credit Head'){
                    list<AML_Check__c> amllist = new list<AML_Check__c>();
                    approveAML(loanApplicationId);
                    amlapproved = true;
                    cs.Status = 'Closed';
                    cs.Id = caseId;
                    cases.put(cs.Id,cs);
                     
                }
                   
               if(!amlChecks.isEmpty()){
                Update amlChecks.values();
            }
               
           } else {
            Case cs = new Case();
            /*if(){
                        cs.Status = System.label.PendingCMU; 
                        cs.Id = caseId;
                       cs.OwnerId = queueIds.get('CMU');
                       cases.put(cs.Id,cs);
           }*/
           if(profileName.Name == 'CMU' || profileName.Name == 'IBL Business Executive' || profileName.Name == 'IBL TF Business Executive' ||
            profileName.Name == 'IBL Partner Community TF Business Executive' || profileName.Name.contains('CVO')){
                
                cs.Status = System.label.Pendingcreditanalyst;  
                if(loanApp.Product_Type__c == 'Tractor')  {//SFTRAC-89
                    cs.OwnerId = String.isNotBlank(scmMemberId)? scmMemberId : zcmMemberId;
                } else if(loanApp.Product_Type__c == 'Passenger Vehicles')  {
                    cs.OwnerId = caMemberId;
                } else {
                    cs.OwnerId = ncmMemberId;
                }
                cs.Id = caseId;
                cases.put(cs.Id,cs);
                submitAMLCheckToCA(loanApplicationId);
            }
            if(profileName.Name == 'IBL Credit Analyst' || profileName.Name == 'IBL National Credit Manager' || profileName.Name == 'IBL State Credit Manager'){
                if(!camList.isEmpty()){
                    cs.Status = System.label.Pendingcredithead;
                    cs.OwnerId = chMemberId;
                    cs.Id = caseId;
                    cases.put(cs.Id,cs);
                }else{
                    return 'false';
                }
                
            }

            if(profileName.Name == 'IBL Credit Head'){
                    cs.Status = System.label.Closed;
                    cs.Id = caseId;
                    cases.put(cs.Id,cs);                
            }
        }
           if(!cases.isEmpty()){
               Update cases.values();
               //commented due to CISP-3272
               /*if(!amlapproved) {
               List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
                for(Case cs :cases.values()){
                    List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='AML_To_Inform_BECVO'];
                    String deviationLevel = '';
                    if (camList.size() > 0) {
                        List<Deviation__c> deviationList = [SELECT Id,Deviation_Level__c,Role__c FROM Deviation__c WHERE Parent_CAM__r.Loan_Application__c = :loanApplicationId AND (NOT Deviation_Level__c LIKE 'L%')]; 
                        if (deviationList.size() > 0) {
                            deviationLevel = deviationList[0].Deviation_Level__c;
                        }
                    }
                    RequestWrapper emailRequestWrapper = new RequestWrapper();
                    emailRequestWrapper.leadId = loanApplicationId;
                    emailRequestWrapper.loanApplicationId = loanApplicationId;
                    String emailTemplateSubject = etList[0].Subject;
                    String emailBody = etList[0].HtmlValue;
                    if(cs.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                        emailRequestWrapper.emailTo = userEmails.get(cs.OwnerId);
                        emailRequestWrapper.emailCC =  userEmails.get(cs.OwnerId);
                        emailTemplateSubject = emailTemplateSubject.replace('{!Deviation__c.Deviation_Level__c} ',deviationLevel);
                        emailBody = emailBody.replace('{!Case.OwnerFullName}',userNames.get(cs.OwnerId));
                        emailBody = emailBody.replace('{!Deviation__c.Deviation_Level__c}',deviationLevel);
                    }else{
                       String queueEmailAddress = string.join(queueEmailAddresses,',');
                       if(String.isNotBlank(queueEmailAddress)){
                            emailRequestWrapper.emailTo = queueEmailAddress;
                            emailRequestWrapper.emailCC =  queueEmailAddress;
                            emailTemplateSubject = emailTemplateSubject.replace('{!Deviation__c.Deviation_Level__c} ',deviationLevel);
                            emailBody = emailBody.replace('{!Case.OwnerFullName}','CMU');
                            emailBody = emailBody.replace('{!Deviation__c.Deviation_Level__c}',deviationLevel);
                       }
                    }                    
                    emailTemplateSubject = emailTemplateSubject.replace('{!Case.Loan_Application__r}', loanApp.Name);
                    emailRequestWrapper.emailSubject = emailTemplateSubject;
                    emailBody = emailBody.replace('{!Case.Loan_Application__r}',  loanApp.Name);
                    if(cs.Status.equals(System.label.Pendingcredithead)){
                        emailBody = emailBody.replace('{!Case.Link}',URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/n/CAM_Screen');    
                    }else{
                        emailBody = emailBody.replace('{!Case.Link}',URL.getSalesforceBaseUrl().toExternalForm()+'/'+cs.Id);
                    }
                    emailBody = emailBody.replace('{!Case.Link}',URL.getSalesforceBaseUrl().toExternalForm()+'/'+cs.Id);
                    emailRequestWrapper.emailBody = emailBody;
                    emailRequestWrapperList.add(emailRequestWrapper);
                }
                Map<String,List<RequestWrapper>> reqMap = new Map<String, List<RequestWrapper>>();
                reqMap.put('EmailRequest',emailRequestWrapperList);

                return JSON.serializePretty(reqMap);
            }*/
           }
           return System.label.AMLrecordupdated;
        }else{
            return 'You do not have enough permission to perform this operation.';
        }
       }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'updateAmlCheck', System.Label.Apex, e);  
           throw new AuraHandledException(e.getMessage());
       }
   }
   /*
   * @Method Name: updateAMLCheckDocument
   * @Created by:  Daksh Mandowara
   * @description: To update the Content Document Id in AML Check
   * @Param:       String - Content Document Id, String AML Record Id
   */
   @AuraEnabled
   public static void updateAMLCheckDocument(string contentDocId,string amlRecordId) {
       try{  
           AML_Check__c aml = new AML_Check__c();
           aml.Id = amlRecordId;
           aml.Content_Document_Id__c = contentDocId;
           update aml;  
       }  
       catch(Exception e){  
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'updateAMLCheckDocument ', System.Label.Apex, e);
           throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
       }  
   }
   /*
   * @Method Name: changeFilename
   * @Created by:  Daksh Mandowara
   * @description: to change the file name
   * @Param:       String - contentDocumentId
   */
   @AuraEnabled
   public static void changeFilename(string contentDocId,string fname) {
       ContentDocument conDoc = [select id,Title from ContentDocument where Id=:contentDocId]; // Getting files from Parent record 
       conDoc.Title = fname;  
       try{  
       update conDoc;  
       }  
       catch(Exception e){  
           ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'changeFilename ', System.Label.Apex, e);
           throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
       }  
   }
    /*
   * @Method Name: checkRetryExhausted
   * @Created by:  Daksh Mandowara
   * @description: To check whether it reached to retry limit.
   * @Param:       String - contentDocumentId
   */
   @AuraEnabled
   public static Boolean checkRetryExhausted(String loanApplicationId) {
     try {
       if (loanApplicationId != null) {
         List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :System.Label.AML AND User_Id__c =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
         if (!retryCountList.isEmpty()) {
           System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.AML);
           if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
             return true;
           }
         }
       }
       return false;
     } catch (Exception e) {
       ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'checkRetryExhausted', System.Label.Apex, e);
       throw new AuraHandledException(System.Label.ExceptionMessage);
     }
   }
    /*
   * @Method Name: retryCountIncrease
   * @Created by:  Daksh Mandowara
   * @description: To store retry count details.
   * @Param:       String - Loan Application Id
   */
   @AuraEnabled
 public static Boolean retryCountIncrease(String loanApplicationId) {
   try {
       if (loanApplicationId != null) {
           List<Opportunity> loanApplications = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
           List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :System.Label.AML AND User_Id__c =: UserInfo.getUserId() LIMIT 1];
           if (!retryCountList.isEmpty()) {
               System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.AML);
               retryCountList[0].Count__c = retryCountList[0].Count__c == null ? 0 : retryCountList[0].Count__c;
               if (retryCountList[0].Count__c < metadata.Number_Of_Attempts__c) {
                   retryCountList[0].Count__c += 1;
                   if (Schema.sObjectType.Retry_Count__c.isUpdateable()) {
                       update retryCountList;
                   }else {
                       throw new AuraHandledException(System.label.Retrycountnotinserted);
                   }
                   if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                       return true;
                   }
               }
           } else {
               Retry_Count__c retryCount = new Retry_Count__c();
               retryCount.Loan_Application_Id__c = loanApplicationId;
               retryCount.Service_Name__c = System.Label.AML;
               retryCount.Module__c = loanApplications[0].StageName;
               retryCount.User_Id__c = UserInfo.getUserId();
               retryCount.Count__c = 1;
               if (Schema.sObjectType.Retry_Count__c.isCreateable()) {
                   insert retryCount;
               } else {
                   throw new AuraHandledException(System.label.Retrycountnotinserted);
               }
           }
       }
       return false;
   } catch (Exception e) {
       ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'retryCountIncrease', System.Label.Apex, e);
       throw new AuraHandledException(System.Label.ExceptionMessage);
   }
 }
   /**********************************************
    * @Author:  Daksh Mandowara
    * @Modified Date: 25/04/2022
    * @UserStory:  Feature 8.2.23 - AML Check
    * @Execute: In getAMLApprovals method which returns list of this Wrapper
    * @Purpose: Created wrapper to pass AML Approval logs to CAM Summary Screen
    ***********************************************/
   public class AMLApproval{
       @AuraEnabled
       public String applicationNo;
       @AuraEnabled
       public String applicationName;
       @AuraEnabled
       public String branchName;
       @AuraEnabled
       public String executiveName;
       @AuraEnabled
       public DateTime initiationDatetime;
       @AuraEnabled
       public String camId;
       @AuraEnabled
       public String applicationId;
   }
   
   public class AmlResponse{
       public WlMatch WlMatch{get;set;}
       public String body{get;set;}
   }
   
   public class WlMatch{
       public status status{get;set;}
       public MatchedResults matchedResults{get;set;}
   }
   public class status{
       public String errorDetails{get;set;}
       public String status{get;set;}
   }
   public class MatchedResults{
       public Integer total{get;set;}
       public list<MatchedRecords> matchedRecords{get;set;}
       public String maxScore{get;set;}
   }
   public class MatchedRecords{
       public String id{get;set;}
       public Boolean partialKycFlag{get;set;}
       public String listName{get;set;}
       public String DateOfBirth{get;set;}
       public String address{get;set;}
       public String city{get;set;}
       public String description{get;set;}
       public list<Field> fields{get;set;}
       public String score{get;set;}
   }
   public class Field{
       public Decimal score{get;set;}
       public String queryValue{get;set;}
       public String name{get;set;}
       public String value{get;set;}
   }
   @AuraEnabled
    public static List<ApplicantDetailWrapper> getLoanApplicantData(String loanApplicationId) {
        List<ApplicantDetailWrapper> wrapperList = new List<ApplicantDetailWrapper>();
        try {
            if (loanApplicationId != null) {
                List<Applicant__c> applicantList = new List<Applicant__c>();
                applicantList = [Select Id,Voter_ID_No__c,Driving_License_No__c,Name,Applicant_Type__c,Current_Same_As_Permanent__c from Applicant__c WHERE Opportunity__c  =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                if (applicantList.size() > 0) {
                List<Documents__c> documentList = new List<Documents__c>();
                documentList = [Select Id,Opportunity_Relation__c,Applicant__c,Proof_of_Identity_POI__c, KYC_DOB__c, Proof_of_Address_POA__c, Current_Residential_Address_Proof__c, KYC_Address_Line_1__c, KYC_Address_Line_2__c, Permanent_Residential_Address_Proof__c,Document_Type__c,KYC_No__c, PAN_No__c,Masked_KYC_No__c from Documents__c WHERE Applicant__c IN : applicantList WITH SECURITY_ENFORCED];
                List<Income_Details__c> incomeDetailList = new List<Income_Details__c>();
                incomeDetailList = [Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c,Applicant__c from Income_Details__c WHERE Applicant__c =: applicantList];
                    for (Applicant__c appObj : applicantList) {
                        ApplicantDetailWrapper wrapperObj = new ApplicantDetailWrapper();
                        if(wrapperObj.applicantId == null){
                            wrapperObj.applicantId = appObj.Id;
                        }
                        if(wrapperObj.applicantName == null){
                            wrapperObj.applicantName = appObj.Name;
                        }
                        if(wrapperObj.applicantType == null){
                            wrapperObj.applicantType = appObj.Applicant_Type__c!=null ?appObj.Applicant_Type__c : null;
                        }
                        if (documentList.size() > 0) {
                            for (Documents__c docObj : documentList) {
                                if (docObj.Applicant__c ==  wrapperObj.applicantId) {
                                    if(wrapperObj.dob == null){
                                        wrapperObj.dob = docObj.Proof_of_Identity_POI__c!=false && docObj.KYC_DOB__c!=null ? String.valueOf(docObj.KYC_DOB__c) : null;
                                    }
                                    if(wrapperObj.residentialAddress == null && docObj.Current_Residential_Address_Proof__c!=false){
                                        if(String.isNotEmpty(docObj.KYC_Address_Line_1__c) && String.isNotEmpty(docObj.KYC_Address_Line_2__c)){
                                            wrapperObj.residentialAddress = docObj.KYC_Address_Line_1__c + ' ' + docObj.KYC_Address_Line_2__c;
                                        } else if (String.isNotEmpty(docObj.KYC_Address_Line_1__c) && String.isEmpty(docObj.KYC_Address_Line_2__c)) {
                                            wrapperObj.residentialAddress = docObj.KYC_Address_Line_1__c;
                                        } else if (String.isEmpty(docObj.KYC_Address_Line_1__c) && String.isNotEmpty(docObj.KYC_Address_Line_2__c)) {
                                            wrapperObj.residentialAddress = docObj.KYC_Address_Line_2__c;
                                        } else{
                                            wrapperObj.residentialAddress = null;
                                        }
                                    }
                                    if(wrapperObj.permanentAddress == null && (appObj.Current_Same_As_Permanent__c!=false || docObj.Permanent_Residential_Address_Proof__c!=false)){
                                        if(String.isNotEmpty(docObj.KYC_Address_Line_1__c) && String.isNotEmpty(docObj.KYC_Address_Line_2__c)){
                                            wrapperObj.permanentAddress = docObj.KYC_Address_Line_1__c + ' ' + docObj.KYC_Address_Line_2__c;
                                        } else if (String.isNotEmpty(docObj.KYC_Address_Line_1__c) && String.isEmpty(docObj.KYC_Address_Line_2__c)) {
                                            wrapperObj.permanentAddress = docObj.KYC_Address_Line_1__c;
                                        } else if (String.isEmpty(docObj.KYC_Address_Line_1__c) && String.isNotEmpty(docObj.KYC_Address_Line_2__c)) {
                                            wrapperObj.permanentAddress = docObj.KYC_Address_Line_2__c;
                                        } else{
                                            wrapperObj.permanentAddress = null;
                                        }
                                    }
                                    if(wrapperObj.pan == null){
                                        //wrapperObj.pan = docObj.Document_Type__c == System.Label.PanCards && docObj.PAN_No__c!=null ? docObj.PAN_No__c : null;
                                        wrapperObj.pan = docObj.Document_Type__c == System.Label.PanCards && docObj.PAN_No__c!=null ? '**** **** **' : null;//CISP-3038
                                    }
                                    if(wrapperObj.aadhar == null){
                                        wrapperObj.aadhar = docObj.Document_Type__c == 'Aadhaar' && docObj.Masked_KYC_No__c!=null ? '**** **** ' + docObj.Masked_KYC_No__c.right(4) : null;
                                    }
                                    if(wrapperObj.passport == null){
                                        //wrapperObj.passport = docObj.Document_Type__c == System.Label.PassportCard && docObj.KYC_No__c!=null  ? docObj.KYC_No__c : null;
                                        wrapperObj.passport = docObj.Document_Type__c == System.Label.PassportCard && docObj.KYC_No__c!=null  ? '**** **** **** ***' : null;//CISP-3038
                                    }
                                    if(wrapperObj.voterId == null){
                                        //wrapperObj.voterId = docObj.Document_Type__c == System.Label.VoterIdCard && docObj.KYC_No__c!=null ? docObj.KYC_No__c : null;
                                        wrapperObj.voterId = docObj.Document_Type__c == System.Label.VoterIdCard && docObj.KYC_No__c!=null ? '**** **** **** ' : null;//CISP-3038
                                    }
                                    if(wrapperObj.drivingLicense == null){
                                        //wrapperObj.drivingLicense = docObj.Document_Type__c == System.Label.DrivingLicences && docObj.KYC_No__c!=null ? docObj.KYC_No__c : null;
                                        wrapperObj.drivingLicense = docObj.Document_Type__c == System.Label.DrivingLicences && docObj.KYC_No__c!=null ? '**** **** **** ***' : null;//CISP-3038
                                    }
                                }
                            }
                        }
                        if (incomeDetailList.size() > 0) {
                            for (Income_Details__c incomeObj : incomeDetailList) {
                                if(String.isEmpty(wrapperObj.officialAddress) && wrapperObj.applicantId == incomeObj.Applicant__c){
                                    if(String.isNotEmpty(incomeObj.Office_Address_Line_1__c) && String.isNotEmpty(incomeObj.Office_Address_Line_2__c)){
                                        wrapperObj.officialAddress = incomeObj.Office_Address_Line_1__c + ' ' + incomeObj.Office_Address_Line_2__c;
                                    } else if (String.isNotEmpty(incomeObj.Office_Address_Line_1__c) && String.isEmpty(incomeObj.Office_Address_Line_2__c)) {
                                        wrapperObj.officialAddress = incomeObj.Office_Address_Line_1__c;
                                    } else if (String.isEmpty(incomeObj.Office_Address_Line_1__c) && String.isNotEmpty(incomeObj.Office_Address_Line_2__c)) {
                                        wrapperObj.officialAddress = incomeObj.Office_Address_Line_2__c;
                                    } else{
                                        wrapperObj.officialAddress = null;
                                    }
                                }
                            }
                        }
                        wrapperList.add(wrapperObj);
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('AmlCheckData', 'getLoanApplicantData', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return wrapperList;
    }
    
    public class ApplicantDetailWrapper{
        @auraenabled public Id applicantId;
        @auraenabled public string applicantName;
        @auraenabled public string applicantType;
        @auraenabled public string dob;
        @auraenabled public string residentialAddress;
        @auraenabled public string officialAddress;
        @auraenabled public string permanentAddress;
        @auraenabled public string pan;
        @auraenabled public string aadhar;
        @auraenabled public string voterId;
        @auraenabled public string passport;
        @auraenabled public string drivingLicense;
    }

    @AuraEnabled
    public static boolean accessAMLCase(String caseId){
        Boolean isSameOwner = false;
        try{
            List<Case> caseList = new List<Case>([Select Id,OwnerId From Case Where Id =: caseId]);
            if(caseList.size() > 0){
                isSameOwner = (caseList[0].OwnerId == UserInfo.getUserId()) ? true : false;
            }
        } catch (Exception e) {
            return isSameOwner;
        }
        return isSameOwner;
    }
   
}