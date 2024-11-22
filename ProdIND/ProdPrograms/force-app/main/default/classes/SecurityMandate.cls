/*------------------------------------------------------------
 Author:        Poonam Tilokani
 Company:       Manras
 Description:   SecurityMandate is used to store and get Cheque details that are store in document object. 
 Apex Class :   SecurityMandate
 Test Class:    SecurityMandateTest
------------------------------------------------------------*/
public with sharing class SecurityMandate {
    
	/*
   * @Method:      getDocDetails
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to return documents and content document records that are related to Cheques SPDC document type.
   * @Param:       String - Loan Application ID
   * @Return:      String
   */
    @AuraEnabled
    public static String getDocDetails(string loanApplicationId, String dealId){
        Map<String,Object> mapData = new Map<String,Object>();
        String docType = 'Cheques SPDC';
        try {
            Set<Id> documentId = new Set<Id>();
            Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED];
            if(opp.Product_Type__c == 'Tractor'){
                List<Vehicle_Detail__c> vehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
                Id vehicleId = (vehicleLst.isEmpty()) ? null : vehicleLst[0].Id;
                String docList = 'Select id,Name,Document_Type__c,Cheque_Number__c,is_Active__c,Cheque_legible__c,Remarks__c from Documents__c where Opportunity_Relation__c=:loanApplicationId AND is_Active__c=true AND Document_Type__c =:docType AND Vehicle_Detail__c =: vehicleId WITH SECURITY_ENFORCED order by Name asc';
                mapData.put('docDetails',Database.query(docList));
                for(Documents__c doc: [Select id,Name,Document_Type__c,Cheque_Number__c,is_Active__c,Cheque_legible__c,Remarks__c from Documents__c where Opportunity_Relation__c=:loanApplicationId AND is_Active__c=true AND Document_Type__c =:docType AND Vehicle_Detail__c =: vehicleLst[0].Id WITH SECURITY_ENFORCED order by Name asc]){
                    documentId.add(doc.Id);
                }
            }else{
                String docList = 'Select id,Name,Document_Type__c,Cheque_Number__c,is_Active__c,Cheque_legible__c,Remarks__c from Documents__c where Opportunity_Relation__c=:loanApplicationId AND is_Active__c=true AND Document_Type__c =:docType WITH SECURITY_ENFORCED order by Name asc';
                mapData.put('docDetails',Database.query(docList));
                for(Documents__c doc: [Select id,Name,Document_Type__c,Cheque_Number__c,is_Active__c,Cheque_legible__c,Remarks__c from Documents__c where Opportunity_Relation__c=:loanApplicationId AND is_Active__c=true AND Document_Type__c =:docType WITH SECURITY_ENFORCED order by Name asc]){
                    documentId.add(doc.Id);
                }
            }
            system.debug('documentId'+documentId);
            Map<Id,Id> contentDocId = new Map<Id,Id>();
            set<Id> contentDocIdSet = new Set<Id>();
            if(documentId.size()>0){
                for(ContentDocumentLink conLink : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId In: documentId]){
                    contentDocId.put(conLink.LinkedEntityId,conLink.ContentDocumentId);
                    contentDocIdSet.add(conLink.ContentDocumentId);
                }
            }
            mapData.put('contentDocId',contentDocId);
            
            Map<Id,Id> contentVersionId = new Map<Id,Id>();
            if(documentId.size()>0){
                for(ContentVersion conVersion : [SELECT Id, VersionData, FileType, Title, FileExtension,IsLatest, 
                                                 ContentDocumentId, ContentDocument.FileType FROM   ContentVersion 
                                                 WHERE  ContentDocumentId In :contentDocIdSet  and IsLatest = true]){
                                                     contentVersionId.put(conVersion.ContentDocumentId, conVersion.Id);
                                                 }
            }
            mapData.put('contentVersionId',contentVersionId);
            return JSON.serialize(mapData);
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'getDocDetails', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage()); 
        }
        //return docList;
    }
    /*
   * @Method:      getChequeData
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to return number of SPDC to be allowed according to product type.
   * @Param:       String - Product type
   * @Return:      ProductTypeBasedOnCheque__mdt
   */
    @AuraEnabled
    public static ProductTypeBasedOnCheque__mdt getChequeData(String productType){
        try{
        	return [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Product_Type__c, Number_of_Cheque__c FROM ProductTypeBasedOnCheque__mdt 
                    WHERE  Product_Type__c =: productType WITH SECURITY_ENFORCED];
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'getChequeData', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage()); 
        }
    }
    /*
   * @Method:      getApplicantData
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to return applicant record.
   * @Param:       String - Loan application id
   * @Return:      Applicant__c
   */
     @AuraEnabled 
    public static Applicant__c getApplicantData(String loanApplicationId){
        try{
            List<Applicant__c> applicantList = new List<Applicant__c>();
            applicantList = [Select id,Name ,Applicant_Type__c,Opportunity__c from Applicant__c where Opportunity__c  =: loanApplicationId AND Applicant_Type__c='Borrower' WITH SECURITY_ENFORCED];
            if(applicantList.size()>0){
                return applicantList[0];
            }
            return null;
        }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'getApplicantData', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage()); 
        }
    }
    /*
   * @Method:      getLADetails
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to return Loan application record and check that logged in user same as the owner of record.
   * @Param:       String - Loan application id
   * @Return:      String
   */
    @AuraEnabled
    public static String getLADetails(string loanApplicationId, String dealId){
        Map<String,Object> returnMap = new Map<String, Object>();
        List<Opportunity> oppList = new List<Opportunity>();
        try {
            oppList = [Select Id,ownerId,StageName,NOC_Number__c,Applicant__c, Product_Type__c ,Number_of_SPDC_collected__c,All_Cheques_are_from_Same_bank__c, CVO_Accepts_SPDC_Documents__c, CVO_Remarks_SPDC__c,(Select Id from Vehicle_Details__r where Deal_Number__c=: dealId) FROM Opportunity WHERE id=:loanApplicationId  WITH SECURITY_ENFORCED];
            if(oppList != null){
                returnMap.put('loanApplication',oppList[0]);
                
                User Usr =[SELECT Id,profileId,profile.name,userType FROM User WHERE Id = : UserInfo.getUserId()];
                if(oppList[0].ownerId == usr.Id){
                    returnMap.put('isOwnerSame',true);
                }else{
                    returnMap.put('isOwnerSame',false);
                }
                if(Usr.userType == 'PowerPartner'){
                    returnMap.put('isCommunityUser',true);
                }else{
                    returnMap.put('isCommunityUser',false);
                }
                return JSON.serialize(returnMap);
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'getLADetails', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage()); 
        }
        
    }
     /*
   * @Method:      saveOrUpdateLoanApplication
   * @Created by:  Poonam Tilokani
   * @Modified by : Apoorva
   * @Description: This method is used update loan application records and also document records.
   * @Param:       String - Loan application id, Boolean - sameBankAccount, Integer - Number of cheques,
   * 				 String - cvo accept cheques, String - CVORemarks, String - List of document Records, String - Loan stage name, Boolean submitted flag 
   * @Return:      void
   */
    @AuraEnabled
    public static void saveOrUpdateLoanApplication(String loanApplicationId, boolean sameBankAccount, Integer numberOfChecks,String cvo,String remarks,String lstDoc,String loanStageName,boolean submitFlag, String dealId){
        Opportunity OppRecord;
        List<Object> results = (List<Object>)JSON.deserializeUntyped(lstDoc);
        system.debug('results--'+results);
        List<Opportunity> oppList = new List<Opportunity>();
        List<Deal_Number__c> dealList = new List<Deal_Number__c>();
         List<Documents__c> docList = new List<Documents__c>();
        try {
            oppList = [SELECT ID,All_Cheques_are_from_Same_bank__c,Number_of_SPDC_collected__c,CVO_Accepts_SPDC_Documents__c,CVO_Remarks_SPDC__c, Product_Type__c FROM 
                                                Opportunity WHERE ID=:loanApplicationId  WITH SECURITY_ENFORCED];
            System.debug('oppList'+oppList);
            if(oppList != null && oppList[0].Product_Type__c == 'Tractor'){
                Deal_Number__c DealNumber = new Deal_Number__c();
                DealNumber.id = dealId;
                DealNumber.All_Cheques_are_from_Same_bank__c = sameBankAccount;
                DealNumber.Accepts_SPDC_Documents__c = cvo;
                DealNumber.Remarks_SPDC__c = remarks;
                DealNumber.Number_of_SPDC_collected__c = numberOfChecks;
                dealList.add(DealNumber);

                if(!dealList.isEmpty()){
                    UPDATE dealList;
                }

            }else if(oppList != null && oppList[0].Product_Type__c != 'Tractor'){
                OppRecord = oppList[0];
                OppRecord.All_Cheques_are_from_Same_bank__c = sameBankAccount;
                OppRecord.CVO_Accepts_SPDC_Documents__c = cvo;
                OppRecord.CVO_Remarks_SPDC__c = remarks;
                OppRecord.Number_of_SPDC_collected__c = numberOfChecks;
                Update OppRecord;
            }
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId and Name='Security Mandate' And Module__c =:loanStageName And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                if(lATList.size()>0){
                    lATList[0].Submitted_Flag__c = submitFlag;
                    update lATList;
                }

             if(results!=null){
                for(Object o:results){
                 Map<String, Object> itemMap = (Map<String, Object>)o;
                   	System.debug('itemMap '+itemMap);
                    Object chequeNoValue = itemMap.get('chequeNo');
                    Documents__c doc=new Documents__c(Id = (Id)itemMap.get('docId'));  
                    doc.Cheque_legible__c = (String)itemMap.get('chequeLegible');
                    if (chequeNoValue instanceof Decimal){
                    doc.Cheque_Number__c = (Decimal)itemMap.get('chequeNo');
                    }
                    else if (chequeNoValue instanceof String) {
                        doc.Cheque_Number__c = Decimal.valueOf((String)chequeNoValue);
                    } 
                    doc.Remarks__c = (String)itemMap.get('chequeRemarks');
                    docList.add(doc);
                }
             }
            if(docList != null && !docList.isEmpty()){
                update docList;
            }
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'saveOrUpdateLoanApplication', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage()); 
        }
    }
      /*
   * @Method:      deleteDocRecord
   * @Created by:  Poonam Tilokani
   * @Description: This method is used delete document records.
   * @Param:       String - Loan application id, String - updated documents list, String - deleted document list
   * @Return:      void
   */
    @AuraEnabled
    public static void deleteDocRecord(String loanApplicationId,String updatedList,String deleteList, String dealId){
        try {
            List<chequeWrapper> updateList = (List<chequeWrapper>)JSON.deserialize(updatedList, List<chequeWrapper>.class);
            List<chequeWrapper> deletedList = (List<chequeWrapper>)JSON.deserialize(deleteList, List<chequeWrapper>.class);
            
            system.debug('updatedList'+updateList);
            system.debug('deleteList'+deletedList);
            
            Set<Id> chequeIdDelete = new Set<Id>();
            for(chequeWrapper che : deletedList){
                chequeIdDelete.add(che.docId);
            }
            List<Documents__c> docListforDelete = [SELECT ID from Documents__c WHERE ID IN: chequeIdDelete WITH SECURITY_ENFORCED];
            if(docListforDelete.size()>0){
                delete docListforDelete;
            }
            
            List<Documents__c> docForUpsert = new List<Documents__c>();
            for(chequeWrapper che : updateList){
                Documents__c doc = new Documents__c();
                doc.Name = che.chequeUnique;
                doc.Cheque_Number__c= che.chequeNo;
                doc.Id = che.docId;
                docForUpsert.add(doc);
            }
            Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            if(opp.Product_Type__c == 'Tractor'){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                for(Documents__c doc : docForUpsert){
                    doc.Vehicle_Detail__c = VehicleLst[0].Id;
                }
            }
            if(docForUpsert.size()>0){
                upsert docForUpsert;
            }
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'deleteDocRecord', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage()); 
        }
    } 
    
    @TestVisible
    class chequeWrapper{
        @TestVisible
        String id {get;set;}
        @TestVisible
        String chequeSeq {get;set;}
        @TestVisible
        Double chequeNo {get;set;}
        @TestVisible
        String chequePreview {get;set;}
        @TestVisible
        String chequeLegible {get;set;}
        @TestVisible
        String chequeRemarks {get;set;}
        @TestVisible
        String docId {get;set;}
        @TestVisible
        String chequeUnique {get;set;}     
    }
      /*
   * @Method:      checkIfReadOnly
   * @Created by:  Poonam Tilokani
   * @Description: This method is used check weather Loan application transaction history record for Security Mandate pre-disbursment is submitted or not.
   * @Param:       String - Loan application id
   * @Return:      boolean
   */
    @AuraEnabled
    Public static boolean checkIfReadOnly(String lAId, String dealId){
        try{
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:lAId And Name='Security Mandate' And Module__c = 'Pre Disbursement Check' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(lATList!=null && lATList.size()>0){
                return (lATList[0].Submitted_Flag__c);
            }
            return false;
        }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'checkIfReadOnly', System.Label.Apex, e,lAId);
            throw new IND_Exception(e.getMessage()); 
        }
    }

           /*
   * @Method:      isSecurityMandateSubmitted
   * @Created by:  Gaurav Rawat
   * @Description: This method is used check weather Loan application transaction history record for Security Mandate post-sanction is submitted or not.
   * @Param:       String - Loan application id
   * @Return:      boolean
   */
  @AuraEnabled
  Public static boolean isSecurityMandateSubmitted(String lAId, String dealId){
      try{
          List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:lAId And Name='Security Mandate' And Module__c = 'Post Sanction Checks and Documentation' AND Deal_Number__c=: dealId WITH SECURITY_ENFORCED];
          if(lATList!=null && lATList.size()>0){
              return (lATList[0].Submitted_Flag__c);
          }
          return false;
      }catch (Exception e) {
          ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'isSecurityMandateSubmitted', System.Label.Apex, e,lAId);
          throw new IND_Exception(e.getMessage()); 
      }
  }

      /*
   * @Method:      checkIFRTOISSubmitted
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to check weather Loan application transaction history record for Security Mandate Post sanction and RTO DPN Screen is submitted or not.
   * @Param:       String - Loan application id
   * @Return:      String
   */
     @AuraEnabled
    Public static String checkIFRTOISSubmitted(String lAId, String dealId){
        try{
            Map<String,Object> transactionRecords = new Map<String,Object>();
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:lAId And 
                                                                   Screen__c='RTO, DPN, POA Documents Upload' And 
                                                                   Module__c = 'Post Sanction Checks and Documentation'
                                                                   AND Deal_Number__c=: dealId WITH SECURITY_ENFORCED];
            if(lATList!=null && lATList.size()>0){
                transactionRecords.put('RTOSub',lATList[0].Submitted_Flag__c);
            }
            List<Loan_Application_Transaction_History__c> lATList1=[Select id,Name, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:lAId And 
                                                                    screen__c= 'Security Mandate' And 
                                                                    Module__c = 'Post Sanction Checks and Documentation'
                                                                    AND Deal_Number__c=: dealId
                                                                    WITH SECURITY_ENFORCED];
            if(lATList1!=null && lATList1.size()>0){
                transactionRecords.put('securityMandate',lATList1[0].Submitted_Flag__c);
            }
            return JSON.serialize(transactionRecords);
            
        }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'checkIFRTOISSubmitted', System.Label.Apex, e,lAId);
            throw new IND_Exception(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getContentVersion(String conDocId){
        try{
            List<ContentVersion> conVerList = [SELECT Id, VersionData, FileType, Title, FileExtension,IsLatest, 
                                                     ContentDocumentId, ContentDocument.FileType
                                                    FROM   ContentVersion 
                                                    WHERE  ContentDocumentId =: conDocId and isLatest = true];
            if(conVerList.size()>0){
                return conVerList;
            }
            return null;
            
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('SecurityMandate', 'getContentVersion', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage()); 
        }
    }
      /*
   * @Method:      getDealNumberDetails
   * @Created by:  Satyam Singh
   * @Description:SFTRAC-101 To get the dealNumber deatils.
   * @Param:       String - Deal id
   * @Return:      Deal_Number__c
   */
    @AuraEnabled
    public static Deal_Number__c getDealNumberDetails(string dealId){
        try {
            Deal_Number__c dealNumber = [Select Id, Security_ACH__c, Banker_signature_verification__c, Account_statement__c, Remarks_SPDC__c, Accepts_SPDC_Documents__c, All_Cheques_are_from_Same_bank__c, Number_of_SPDC_collected__c from Deal_Number__c where Id =: dealId limit 1];
            return dealNumber;
        } 
        
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

          /*
   * @Method:      updateDealNumber
   * @Created by:  Satyam Singh
   * @Description:SFTRAC-101 To update dealNumber deatils.
   * @Return:      void
   */
    @AuraEnabled
    public static void updateDealNumber(string dealId, boolean securityACH, boolean BankerSignature, boolean AccountStatement){
        try {
            if(dealId != null)
            {
                Deal_Number__c dealNumber = [Select Id, Security_ACH__c, Banker_signature_verification__c, Account_statement__c from Deal_Number__c where Id =: dealId limit 1];
                dealNumber.Security_ACH__c = securityACH;
                dealNumber.Banker_signature_verification__c = BankerSignature;
                dealNumber.Account_statement__c = AccountStatement;
                update dealNumber;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}