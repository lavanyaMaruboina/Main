/*------------------------------------------------------------
Author:        Yugandhar C.
Company:       Persistent Systems
Description:   This handle the current and permananet residence FI components data retrival and storage
                
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
08-02-2022      Yugandhar C.       Created
24-02-2022      Manish Baldota     Added the loadResidenceFIData method
------------------------------------------------------------*/
public with sharing class IND_ResidenceFIController {  

    // @Method:      saveCurrentResidenceFI
    // @Created by:  Yugandhar C.
    // @Description: update the FI record details to FI record.
    // @Param:       inputWrapper : inputWrapper 
    @AuraEnabled
    public static Boolean saveCurrentResidenceFI(String inputWrapper) {
        try{
            IND_ResidenceFIInputWrapper wrapper = IND_ResidenceFIInputWrapper.parse(inputWrapper);
            Field_Investigation__c fiRecord = new Field_Investigation__c(Id = wrapper.fiId.value);
            fiRecord.Address_Line_1__c = wrapper.addrLine1.value;
            fiRecord.Address_Line_2__c = wrapper.addrLine2.value;
            fiRecord.City__c = wrapper.city.value;
            fiRecord.Pin_Code__c = wrapper.pinCode.value;
            fiRecord.State__c = wrapper.state.value;
            fiRecord.Landmark__c = wrapper.landmark.value;
            fiRecord.Phone_Number__c = wrapper.phoneNo.value;
            fiRecord.Mobile__c = wrapper.mobile.value;
            fiRecord.Customer_house_same_as_in_application__c = wrapper.locationSameAsInApplication.value;
            fiRecord.Years_in_Residence__c = wrapper.yearsInResidence.value;
            fiRecord.Product__c = wrapper.product.value;
            fiRecord.Residence_Type__c = wrapper.resiType.value;
            fiRecord.Purpose_of_Purchase__c = wrapper.purposeOfPurchase.value;
            fiRecord.Profile_to_Product_Match__c = wrapper.profileProductMatch.value;
            fiRecord.Number_of_Dependent__c = wrapper.noofDependents.value;
            fiRecord.Number_of_Earning_Member_in_Family__c = wrapper.numberOfEarningMembersInTheFamily.value;
            fiRecord.Name_of_Person_met__c = wrapper.nameOfPersonMet.value;
            fiRecord.Relationship__c = wrapper.relationShipWithCustomer.value;
            fiRecord.Years_in_CIty__c = wrapper.noOfYearsinCity.value;
            fiRecord.No_of_Attempts__c = wrapper.noofAttempts.value;
            fiRecord.FI_Observation__c = wrapper.fiObservation.value;
            fiRecord.FI_Feedback__c = wrapper.fiFeedback.value;
            fiRecord.No_of_TVs__c = wrapper.noOfTVs.value;
            fiRecord.No_of_Fridges__c = wrapper.noOfFridgess.value;
            fiRecord.No_of_Washing_Machines__c = wrapper.noofWashingMachines.value;
            fiRecord.No_of_Sofas__c = wrapper.noOfSofas.value;
            fiRecord.No_of_ACs__c = wrapper.noOfACs.value;
            fiRecord.No_of_Computers__c = wrapper.noOfComputers.value;
            fiRecord.No_of_2_Wheelers__c = wrapper.noOf2Wheelers.value;
            fiRecord.No_of_3_Wheelers__c = wrapper.noOf3Wheelers.value;
            fiRecord.No_of_4_Wheelers__c = wrapper.noOf4Wheelers.value;
            fiRecord.No_of_CVs__c = wrapper.noOfCVs.value;
            fiRecord.FI_Status__c = System.label.Complete;
            //IntegrationEngine.doGeoCoderAPI(wrapper.fiId.value,wrapper.applicationId.value);//CISP-2701
            if (Schema.sObjectType.Field_Investigation__c.isUpdateable()) {
                UPDATE fiRecord;
               
            }
            return true;
        }
        catch(Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
    }

    //CISP-2701-START
    @AuraEnabled
    public static Field_Investigation__c getFieldInvestigation(String fieldInvestigationId) {
        try{
            Field_Investigation__c fiRecord = new Field_Investigation__c();
            fiRecord = [Select Id,Coordinates_Distance__c From Field_Investigation__c WHERE Id=:fieldInvestigationId];
            return fiRecord;
        }
        catch(Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
    }

    /* 
   @description :   Method to check if retry count is exhausted
   @param :  String loanApplicationId
   @return : Boolean
  */
  @AuraEnabled
  public static Boolean checkRetryExhausted(String loanApplicationId, String fieldInvestigation) {//CISP-3069
    try {
      if (loanApplicationId != null) {
        List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :System.Label.Capture_FI_Latitude_Longitude AND Field_Investigation__c =: fieldInvestigation WITH SECURITY_ENFORCED];//CISP-3069
        if (!retryCountList.isEmpty()) {
          System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.Capture_FI_Latitude_Longitude);
          if (retryCountList[0].Count__c > metadata.Number_Of_Attempts__c) {
            return true;
          }
        }
      }
      return false;
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('IND_ResidenceFIController', System.Label.CheckRetryExhausted, System.Label.Apex, e,loanApplicationId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
  /* 
  @description :   Method to increase retry count
  @param :  String loanApplicationId
  @return : Boolean 
 */
  @AuraEnabled
  public static Boolean retryCountIncrease(String loanApplicationId, String fieldInvestigation) {//CISP-3069
    try {
      if (loanApplicationId != null) {
        List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :System.Label.Capture_FI_Latitude_Longitude AND Field_Investigation__c =: fieldInvestigation WITH SECURITY_ENFORCED];//CISP-3069
        if (!retryCountList.isEmpty()) {
          System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.Capture_FI_Latitude_Longitude);
          Decimal count =  retryCountList[0].Count__c == null ? 0 : retryCountList[0].Count__c;
          if (count <= metadata.Number_Of_Attempts__c) {
            retryCountList[0].Count__c += 1;
            if (Schema.sObjectType.Retry_Count__c.isUpdateable()) {
              update retryCountList;
            } else {
              throw new AuraHandledException(System.Label.Retrycountnotupdate);
            }
            if (retryCountList[0].Count__c > metadata.Number_Of_Attempts__c) {
              return true;
            }
          }else{
            return true;
          }
        } else {
          Retry_Count__c retryCount = new Retry_Count__c();
          retryCount.Loan_Application_Id__c = loanApplicationId;
          retryCount.Service_Name__c = System.Label.Capture_FI_Latitude_Longitude;
          retryCount.Field_Investigation__c = fieldInvestigation;//CISP-3069
          retryCount.Count__c = 1;
          if (Schema.sObjectType.Retry_Count__c.isCreateable()) {
            insert retryCount;
          } else {
            throw new AuraHandledException(System.Label.Retrycountnotinserted);
          }
        }
      }
      return false;
    } catch (Exception e) {
      ErrorLoggerUtil.logErrorEvent('IND_ResidenceFIController', 'retryCountIncrease', System.Label.Apex, e,loanApplicationId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }
//   CISP-2701-END
    // @Method:      loadResidenceFIData
    // @Created by:  Manish Baldota
    // @Description: get the document list associated with the Applicant of the FI record.
    // @Param:       String : applicantId // ID of applicant for which documents to be retrived.  
    // @Return:      List<DocumentWrapper>: documentList // Created Wrapper as we need to pass the original verified flag for featuring the disablemetn of checkbox.
    @AuraEnabled(cacheable=true)
    public static List<DocumentWrapper> loadResidenceFIData(String applicantId, String addrType){
        try {
            if(string.isBlank(applicantId)){
                throw new IND_Exception('Applicant details are not valid, please contact your administrator.');
            }  
            String kycRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.label.KYCDocument).getRecordTypeId();

           // List<DocumentWrapper> documentList = new List<DocumentWrapper>();
            Map<String,DocumentWrapper> documentTypeDocumentMap = new Map<String,DocumentWrapper>();   //  List<Documents__c> documents = ; //Replace hard coded Applicant ID with corresponding opportunity ID       
            for(Documents__c doc : [SELECT KYC_Address_Line_1__c,Raw_Response__c,KYC_Address_Line_2__c, KYC_City__c, KYC_DOB__c, KYC_District__c, 
                    KYC_Pin_Code__c, KYC_State__c, DocAuth_Passed__c, Is_this_a_Photocopy__c, Applicant__c,CreatedDate, Document_Type__c,Addresss_Type__c
                    FROM Documents__c
                    WHERE Applicant__c = :applicantId AND RecordTypeId =: kycRecordTypeId AND Addresss_Type__c=:addrType
                    AND Document_Type__c <>: System.label.CustomerImageDocumentType AND Document_Type__c <>: System.label.Office_Front_View 
                  AND  Document_Type__c <>: System.label.Residence_Front_View WITH SECURITY_ENFORCED]) {
				DocAuthJSONParser parse = new DocAuthJSONParser();
                DocumentWrapper wrapElement = new DocumentWrapper();
                wrapElement.doument = doc;
                if(String.isNotBlank(doc.Raw_Response__c)){
                        String rawResponse = doc.Raw_Response__c.replaceAll('&quot;', '"');
                        system.debug('rawResponse'+rawResponse);
                    
                        parse = (DocAuthJSONParser)JSON.deserialize(rawResponse, DocAuthJSONParser.class);       
                }               
                if(((parse.reports != null && parse.reports[0].sub_result == 'Caution' &&  parse.reports[0].breakdown.visual_authenticity.breakdown.original_document_present.result != 'Clear') 
                    ||  doc.Is_this_a_Photocopy__c == true) && !documentTypeDocumentMap.containsKey(doc.Document_Type__c)){
                    wrapElement.originalVerified = false;
                    documentTypeDocumentMap.put(doc.Document_Type__c,wrapElement);
                } else {
                    wrapElement.originalVerified = true;
                    documentTypeDocumentMap.put(doc.Document_Type__c,wrapElement);
                }
            }            
            return documentTypeDocumentMap.values();
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_ResidenceFIController', 'loadResidenceFIData', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }
    
    // @Method:         createDocumentRecord
    // @Created by:     Manish Baldota
    // @Description:    Method to create new document record.
    // @Param:          String : applicantId // ID of applicant for which documents to be retrived.  
    //                  String : loanApplicationId // Id of the loan application.
    //                  String : documentType // Document Type of document.
    //                  String : recordTypeName // Name of the record type
    // @Return:         String : documentId // Returning created Id to the LWC Component.
    
    @AuraEnabled
    public static String createDocumentRecord(String caseId,String applicantId, String loanApplicationId,String documentType,String recordTypeName){
        try{
             String otherDocumentRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
           String orignaldoc=null;
           List<Field_Investigation__c> cas = [SELECT ID,Case__c FROM Field_Investigation__c where Id =: caseId];

            for(Documents__c doc : [SELECT KYC_Address_Line_1__c,Raw_Response__c,KYC_Address_Line_2__c, KYC_City__c, KYC_DOB__c, KYC_District__c, 
                    KYC_Pin_Code__c, KYC_State__c, DocAuth_Passed__c, Is_this_a_Photocopy__c, Applicant__c,CreatedDate, Document_Type__c
                    FROM Documents__c
                    WHERE Applicant__c = :applicantId AND RecordTypeId =: otherDocumentRecordTypeId 
                    AND Document_Type__c =:documentType AND Case__c=:cas[0].Case__c
                    and is_Active__c =true WITH SECURITY_ENFORCED]) {
				DocAuthJSONParser parse = new DocAuthJSONParser();
                if(String.isNotBlank(doc.Raw_Response__c)){
                    parse = (DocAuthJSONParser)JSON.deserialize(doc.Raw_Response__c, DocAuthJSONParser.class);            
                }               
                if(((parse.reports != null && parse.reports[0].sub_result == 'Caution' &&  parse.reports[0].breakdown.visual_authenticity.breakdown.original_document_present.result != 'Clear') 
                    ||  doc.Is_this_a_Photocopy__c == true) ){
                        continue;
                } else {
                    orignaldoc= doc.Id;
                }
            }  

            if(orignaldoc==null){
                Documents__c document =  new Documents__c(Name=documentType,is_Active__c = true,Opportunity_Relation__c = loanApplicationId,Applicant__c = applicantId,Document_Type__c = documentType, RecordTypeId = otherDocumentRecordTypeId, Case__c=cas[0].Case__c);
                if(Schema.sObjectType.Documents__c.isCreateable()){
                    Insert document;
                } 
                orignaldoc=document.Id;
            }else{
                return orignaldoc;
            } 
            return orignaldoc;    
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_ResidenceFIController', 'createDocumentRecord', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }
     // @Method:      fetchAddtionalRealtedDetails
    // @Created by:  Manish Baldota
    // @Description: method to get the details related to the Loan Application & Applicant, which can't be retrived from getRecord.
    // @Param:       String : applicationId // Loan application ID.  
    // @Return:      boolean
    @AuraEnabled
    public static Boolean getDocumentRecord(String caseId,String applicantId, String loanApplicationId,String documentType,String recordTypeName){
        try{
            String otherDocumentRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            String orignaldoc=null;
            List<Field_Investigation__c> cas = [SELECT ID,Case__c FROM Field_Investigation__c where Id =: caseId];

            List<Documents__c> doc = new List<Documents__c>([SELECT KYC_Address_Line_1__c,Raw_Response__c,KYC_Address_Line_2__c, KYC_City__c, KYC_DOB__c, KYC_District__c, KYC_Pin_Code__c, KYC_State__c, DocAuth_Passed__c, Is_this_a_Photocopy__c, Applicant__c,CreatedDate, Document_Type__c,(Select id from contentDocumentLinks) FROM Documents__c WHERE Applicant__c = :applicantId AND RecordTypeId =: otherDocumentRecordTypeId AND Document_Type__c =:documentType AND Case__c=:cas[0].Case__c and is_Active__c =true WITH SECURITY_ENFORCED LIMIT 1]);
            if(!doc.isEmpty() && doc[0].contentDocumentLinks.size() > 0){
                return true;
            }
            return false;
            }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_ResidenceFIController', 'getDocumentRecord', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    // @Method:      fetchAddtionalRealtedDetails
    // @Created by:  Manish Baldota
    // @Description: method to get the details related to the Loan Application & Applicant, which can't be retrived from getRecord.
    // @Param:       String : applicationId // Loan application ID.  
    // @Return:      List<DocumentWrapper>: documentList
    @AuraEnabled(cacheable=true)
    public static Vehicle_Detail__c fetchAddtionalRealtedDetails(String applicationId){
        try{
            if(String.isBlank(applicationId)){
                throw new IND_Exception('Applicant details are not valid, please contact your administrator.');
            }
            Vehicle_Detail__c vehicleDetails = [SELECT Id,Make__c,Model__c,Variant__c,Dealer_Sub_dealer_name__c 
                                                    FROM Vehicle_Detail__c WHERE Loan_Application__c =: applicationId WITH SECURITY_ENFORCED];
            return vehicleDetails;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_ResidenceFIController', 'fetchAddtionalRealtedDetails', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    // @Method:      updateActualGeoLocationDetails
    // @Created by:  Manish Baldota
    // @Description: method to get the details related to the Loan Application & Applicant, which can't be retrived from getRecord.
    // @Param:       String : fiId // Loan application ID.  
    //               String : lattitude //
    //               String : longitude
    // @Return:       
    @AuraEnabled
    public static void updateActualGeoLocationDetails(String fiId, String lattitude,String longitude){
        try {
            if(String.isNotBlank(fiId)){
                Field_Investigation__c fiRecord = new Field_Investigation__c(Id = fiId, FI_Location__Latitude__s = Decimal.valueOf(lattitude), FI_Location__Longitude__s =Decimal.valueOf(longitude));
                if (Schema.sObjectType.Field_Investigation__c.isUpdateable()) {
                    Update fiRecord;
                } 
            }else{
                throw new IND_Exception('Field Investigation Record Details are not correct, Please contact your administrator.');
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('utilites', 'createContentDocumentFromApex', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }        
    }

    Public Class DocumentWrapper{
        @AuraEnabled public Boolean originalVerified;
        @AuraEnabled public Documents__c doument;        
    }

     /*
      * @Method:      getContentDocumentId
      * @Created by:  Ruchi Jain
      * @Description: Method to check for image if yes then returns contentdocument id
      * @Param:       id applicantId, document type
      * @Return:     ID
      */
      @AuraEnabled
      public static ID getContentDocumentId(String applicantId,String docType ){
          try{
              if(applicantId != null){
  
                List<Applicant__c> applicantList= [select Id,(select Id,Name from Documents__r where Document_Type__c=: docType and is_Active__c =true ORDER BY CreatedDate DESC LIMIT 1) from Applicant__c where Id=:applicantId and  In_Active_Applicant__c=false WITH SECURITY_ENFORCED];
                    if(applicantList[0].Documents__r.size()>0){
                        System.debug('applicantList[0].Documents__r[0].Id=> '+applicantList[0].Documents__r[0].Id);
                        ID documentId =applicantList[0].Documents__r[0].Id;
                        if(documentId!=null){
                            Set<Id> docIdSet = new Set<Id>();
                            for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: documentId WITH SECURITY_ENFORCED]){
                                docIdSet.add(contentdoc.ContentDocumentId);
                            }
                            List<ContentVersion> cv=[SELECT Id,ContentDocumentId from Contentversion where ContentDocumentId IN : docIdSet WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
                            System.debug('cv.size()=> '+cv.size());
                            if(!cv.isEmpty() && cv.size()>0){
                                System.debug('cv[0].ContentDocumentId => '+cv[0].ContentDocumentId);
                                return cv[0].ContentDocumentId;
                            } else {
                                return null;
                            }
                        }else{
                            return null;
                        }
                    }
                    return null;
                } 
                else {
                    return null;
                }
            }catch(Exception e){
                System.debug('e=> '+e.getMessage()+' '+e.getLineNumber());
                ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'getContentDocumentId', 'Apex', e);
                throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    } 


    
/*
* @Method Name: checkDocFromApp
* @Created by:  Ruchi Jain
* @description: takes Applicant record id as parameter, and returns true if Consent_Received__c checkbox is checked in the respective Applicant record
* @Param:       current Applicant ID
* @Return:      String - returns documents id if both front and back are uploaded
*/
@AuraEnabled
public static String checkDocFromApp(String applicantId,String docType){
    // Boolean otpConsentFlag=false;
    try {      
        if(applicantId!=null)
        {
            Integer frontCount=0;
            Integer backCount=0;
            Integer selfieCount=0;
            Documents__c doc = [Select Id, Aadhar_Source__c from Documents__c where Applicant__c =: applicantId And Document_Type__c=:docType and is_Active__c =true ORDER BY CreatedDate DESC limit 1]; 
            Set<Id> docIdSet = new Set<Id>();
            for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: doc.Id WITH SECURITY_ENFORCED]){
                docIdSet.add(contentdoc.ContentDocumentId);
            }
            List<ContentVersion> cv=[SELECT Id,Document_Side_fileupload__c from Contentversion where ContentDocumentId IN : docIdSet WITH SECURITY_ENFORCED ];
            for(ContentVersion contentver : cv){
                if(contentver.Document_Side_fileupload__c=='Front'){
                    frontCount+=1;
                }else if(contentver.Document_Side_fileupload__c=='Selfie'){
                    selfieCount+=1;
                }
                else{
                    backCount+=1;
                }
            }
            if((frontCount>0 && backCount>0)|| (docType==System.Label.CustomerImageDocumentType && selfieCount>0) ||((docType==System.Label.PanCards || docType=='Form 60' || (docType==System.Label.AadhaarCard && doc.Aadhar_Source__c =='ScanAadhar')) && frontCount>0)){
                String id=doc.Id;
                return id;
              }
                return null;
           
        }
        return null;
    } catch(Exception e){
         
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' checkDocFromApp ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
        insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
//End: checkDocFromApp()

/*
* @Method Name: IsAllRequiredFISubmitted
* @Created by: ProposalStatusClass
* @description: Checking if the all Office and Current FI are submitted 
* @Param:       current Loan application Id
* @Return:      boolean
*/
    @AuraEnabled
public static boolean IsAllRequiredFISubmitted(string loanApplicationId){
    boolean returnVal =true;
    try{
        Set<Id> caseOwnerId = new Set<Id>();
        Set<Id> loanApplicationIdSet = new Set<Id>();
        for(Case caseRec : [select Id, Loan_Application__c,status,Type,OwnerId FROM case where Loan_Application__c =:LoanapplicationId and recordType.Name ='FI' and RejectedFI__c = false AND Applicant__r.In_Active_Applicant__c = false]){//CISP-3137
            if(caseRec.Status == 'Accepted'){
                caseOwnerId.add(caseRec.OwnerId);
                loanApplicationIdSet.add(caseRec.Loan_Application__c);
            }
            if(caseRec.Type == 'Current Residence FI' && caseRec.status !='Accepted'){
                returnVal =false;
            }else if(caseRec.Type == 'Office FI'  && caseRec.status !='Accepted'){
                returnVal =false;
            }
        }
        List<OpportunityTeamMember> oppurtunityTeamMembersToBeDeleted = new List<OpportunityTeamMember>();

        if(returnVal){
            oppurtunityTeamMembersToBeDeleted = [SELECT Id,TeamMemberRole,OpportunityId FROM OpportunityTeamMember WHERE UserId IN:caseOwnerId AND OpportunityId IN:loanApplicationIdSet AND TeamMemberRole = 'FI'];
            if(!oppurtunityTeamMembersToBeDeleted.isEmpty()){           	
                CaseWithoutSharingUpdate.deleteOTMRecords(oppurtunityTeamMembersToBeDeleted);
            } 
        }
        return returnVal;
    }catch (exception e){
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.LwcLOSLoanApplicationCntrl, ' checkDocFromApp ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
        insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

    @AuraEnabled
    public static Boolean haveCurrentCaseAccess(String loanId, String caseId){
        try{
            if(caseId != null){
                List<Case> caseList = [SELECT Id FROM Case WHERE Id =: caseId AND (ownerId =: UserInfo.getUserId())];
                if(caseList.size()> 0){
                    return true;
                }else{
                    return false;
                }
            }
            return false;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_ResidenceFIController', 'haveCurrentCaseAccess', 'Apex', e,loanId);
            return false;
        }
    }
}