/*------------------------------------------------------------
 Author:        Poonam Tilokani
 Company:       Manras   
 Description:   AdditionalDocumentsClass is used to get the additional documents details. 
 Apex Class :   AdditionalDocumentsClass
 Test Class:    AdditionalDocumentsClassTest
------------------------------------------------------------*/
public with sharing class AdditionalDocumentsClass {    
    
    /*
   * @Method:      getAdditionalData
   * @Created by:  Poonam Tilokani
   * @Description: This method return serialize String which contain document details , content document details.
   * @Param:       String - Loan Application ID
   * @Return:      String
   */
	@AuraEnabled
    public static String getAdditionalData(String loanApplicationId, String dealId){
        try{
            String contentDocList='';
            String contentVersionList = '';
            Map<String,Object> mapData = new Map<String,Object>();
            List<Loan_Application_Transaction_History__c> transHistoryList = new List<Loan_Application_Transaction_History__c>();
            List<Deal_Number__c > dealList = new List<Deal_Number__c >();
            transHistoryList = [Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId And Name='Additional Documents' And Module__c = 'Pre Disbursement Check' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(transHistoryList.size()>0){
                mapData.put('additionalPreHistory' ,transHistoryList[0].Submitted_Flag__c);
            }
            String docList = 'SELECT Id, Name,RC_Owner__c,Hypothecation_available__c,Hypothecation_in_name_of__c,Seller_Bank_name__c,Borrower_Bank_name__c,CoBorrower_Bank_name__c,Seller_Account_number__c,Borrower_Account_number__c,CoBorrower_Account_number__c,Name_of_Seller_account_holder__c,Name_of_Borrower_account_holder__c,Name_of_CoBorrower_account_holder__c,Invoice_number__c, Invoice_date__c, Invoice_amount__c, Payment_receipt_no__c, Payment_receipt_date__c, Payment_made_to__c, Payment_made_by__c, Payment_amount__c, is_Active__c,Hologram_no_as_per_NOC__c,NOC_ref_no_as_per_journey__c,Has_NOC_been_canceled__c,Document_Type__c,Are_enter_details_as_per_RC_doc_upload__c,Are_entered_details_as_per_document_uplo__c,Remarks_for_RC_Upload__c,Is_sale_DD_legible__c,Remarks_for_DD__c,Is_sale_Foreclosure_Letter_legible__c,Remarks_for_foreclosure_letter__c,entered_details_asper_passbook_upload__c,Is_passbook_legible_for_Seller__c,';
            docList += 'Passbook_Remarks_for_Seller__c,enter_details_asper_bank_STMT_upload__c,Is_bank_statement_legible_for_Seller__c,Bank_Statement_Remarks_for_Seller__c';
            docList += ',enter_details_as_per_canc_chq_upload__c,Is_cancelled_cheque_legible_for_Seller__c,cancelled_cheque_Remarks_for_Seller__c,IFSC_code_Seller__c,enter_DETLS_asper_BWR_passbook_upload__c,Is_passbook_legible_for_Borrower__c,Passbook_Remarks_for_Borrower__c,enter_DETLS_asper_BWR_bank_STMT_upload__c,Is_bank_statement_legible_for_Borrower__c,Bank_Statement_Remarks_for_Borrower__c,IFSC_code_Borrower__c';
            docList += ', Signature_Verification_Bank_Name__c, Signature_verification_for__c, Is_Signature_tally_with_other_documents__c, Is_Signature_verification_legible__c, Insurance_cover_note_number__c, Insurance_cover_note_Date__c, Insurance_declared_value__c, Is_Hypothecation_available__c, Are_entered_details_asper_doc_uploaded__c, Is_Insurance_cover_note_legible__c, Remarks__c, Insurance_Policy_number__c, Insurance_Policy_Date__c, Is_Insurance_Policy_legible__c, Delivery_Date_of_Asset__c, Is_customer_signature_available__c, Is_Asset_details_matching_with_Invoice__c, Is_Delivery_Challan_legible__c, Is_customer_declaration_letter_legible__c, Is_Affidavit_legible__c, Is_ENACH_form_completely_filled__c, Is_ENACH_form_signed_by_customer__c, Is_ENACH_Form_legible__c, Is_Debit_Authorisation_letter_completely__c, Is_Debit_Authorisation_letter_signed_by__c, Is_Debit_Authorisation_letter_legible__c, Is_DSA_Letter_legible__c, Is_Dealer_Letter_legible__c, Is_Talathi_Sarpanch_certificate_legible__c, Is_Vahan_legible__c, Is_Fund_utilisation_letter_filled__c, Is_Fund_utilisation_signed_by_customer__c, Is_Fund_utilisation_letter_legible__c';
            docList += ', enter_DETLS_as_per_BWR_canc_chq_upload__c,Is_cancelled_cheque_legible_for_Borrower__c,Cancelled_cheque_Remarks_for_Borrower__c,enter_DETLS_asper_COBWR_pasbook_upload__c,Is_passbook_legible_for_CoBorrower__c,Passbook_Remarks_for_CoBorrower__c,IFSC_code_CoBorrower__c,DETLS_asper_COBWR_bank_STMT_upload__c,Is_bank_statement_legible_for_CoBorrowe__c,Bank_Statement_Remarks_for_CoBorrower__c,DETLS_asper_COBWR_canc_chq_upload__c,Is_cancelled_cheque_legible_CoBorrower__c,Cancelled_cheque_Remarks_for_CoBorrower__c,Buyer_Seller_Undertaking_Letter_legib__c,Buyer_Seller_Undertaking_Letter_Remarks__c,Buy_Seller_Indemnity_LTR_legible__c,Indemnity_Remarks__c,Is_Sale_Agreement_legible__c,Sale_Agreement_Remarks__c,enter_details_asper_Tax_Invoice_upload__c,Is_Tax_Invoice_legible__c,Tax_Invoice_Remarks__c,Are_enter_details_asper_NOC_doc_upload__c,Is_Cancelled_NOC_legible__c,NOC_Remarks__c,Is_Branch_Undertaking_Letter_legible__c,Branch_Undertaking_Remarks__c,Doc_for_Good_Health_borrower_legible__c,Borrower_Good_Health_Dec_Remarks__c,Doc_for_Good_Health_coborrower_legible__c,CoBorrower_Good_Health_Declaration_Remak__c From Documents__c WHERE Opportunity_Relation__c =: loanApplicationId AND is_active__c =true AND Additional_Document__c = true ';
            Set<Id> documentId = new Set<Id>();
            Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED];
            if(opp.Product_Type__c == 'Tractor'){
                dealList = [Select Id, Not_Provided_Documents__c, IND_Remark__c from Deal_Number__c where id =: dealId WITH SECURITY_ENFORCED LIMIT 1];
                if(dealList.size()>0){
                    mapData.put('dealDetail', dealList);
                }
                List<Vehicle_Detail__c> vehLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
                docList += ' And Vehicle_Detail__c = \'' + vehLst[0].Id + '\'';
                for(Documents__c doc: [Select Id from Documents__c where Opportunity_Relation__c=:loanApplicationId AND is_Active__c=true AND Additional_Document__c = true And Vehicle_Detail__c =: vehLst[0].Id WITH SECURITY_ENFORCED]){
                    documentId.add(doc.Id);
                }
            }else{
                for(Documents__c doc: [Select id from Documents__c where Opportunity_Relation__c=:loanApplicationId AND is_Active__c=true AND Additional_Document__c = true WITH SECURITY_ENFORCED]){
                    documentId.add(doc.Id);
                }
            }
            mapData.put('docDetails',Database.query(docList));
            
            Set<Id> contentDocId = new Set<Id>();
            if(documentId.size()>0){
                for(ContentDocumentLink conDoc : [Select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId In: documentId ]){
                    contentDocId.add(conDoc.ContentDocumentId);
                }
            }
            if(documentId.size()>0){
                contentDocList ='SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId In: documentId' ;
                mapData.put('contentDocId',Database.query(contentDocList));
            }
            if(opp.Product_Type__c == 'Tractor'){
                contentVersionList ='SELECT Id, FileType, Title, FileExtension,IsLatest, ContentDocumentId, ContentDocument.FileType FROM   ContentVersion WHERE  ContentDocumentId in: contentDocId and isLatest = true' ;
                mapData.put('contentVersionList',Database.query(contentVersionList));
            }
            else if(documentId.size()>0){
                contentVersionList ='SELECT Id, FileType, Title, FileExtension,IsLatest, ContentDocumentId, ContentDocument.FileType FROM   ContentVersion WHERE  ContentDocumentId in: contentDocId and isLatest = true' ;
                mapData.put('contentVersionList',Database.query(contentVersionList));
            }
            return JSON.serialize(mapData);
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'getAdditionalData', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
    /*
   * @Method:      getInsuranceDetails
   * @Created by:  Poonam Tilokani
   * @Description: This method return Insurance details list.
   * @Param:       String - Loan Application ID
   * @Return:      List<InsuranceDetails__c>
   */
    @AuraEnabled
    public static List<InsuranceDetails__c> getInsuranceDetails(String loanApplicationId){
        try{
            return [SELECT Id,Name, Product_Type__c, Insurance_Plan__c, Amount__c, Loan_Application__c, Applicant__c,Applicant__r.Applicant_Type__c 
                    FROM InsuranceDetails__c
                    WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED
                   ];
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'getInsuranceDetails', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
     /*
   * @Method:      getApplicantData
   * @Created by:  Poonam Tilokani
   * @Description: This method return applicant list.
   * @Param:       String - Loan Application ID
   * @Return:      List<Applicant__c>
   */
    @auraEnabled
    public static List<Applicant__c> getApplicantData(String loanApplicationId){
        try{
            List<Applicant__c> applicantList = new List<Applicant__c>();
            applicantList = [Select id, Name,Applicant_Type__c,Opportunity__c from Applicant__c where Opportunity__c  =: loanApplicationId WITH SECURITY_ENFORCED];
            if(applicantList.size()>0){
                return applicantList;
            } 
            return null;
        }
        
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'getApplicantData', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
     /*
   * @Method:      getLoanApplicationCategory
   * @Created by:  Poonam Tilokani
   * @Description: This method return Loan application record and check that logged in user same as the owner of record.
   * @Param:       String - Loan Application ID
   * @Return:      String
   */
    @AuraEnabled
    public static String getLoanApplicationCategory(String loanApplicationId, String dealId){
        try{
            Map<String,Object> returnMap = new Map<String,Object>();
            // D2C_CHANGE - Raman, Added LeadSource in SOQL
            List<Opportunity> loanApplicationList =  [SELECT ownerId,NOC_Number__c,Vehicle_Sub_Category__c,StageName, LeadSource, Vehicle_Type__c, Product_Type__c, Id,(Select Id from Vehicle_Details__r Where Deal_Number__c =: dealId) FROM Opportunity 
                                                      where Id=:loanApplicationId WITH SECURITY_ENFORCED
                                                     ];
            if(loanApplicationList.size()>0){
                returnMap.put('loanApplication',loanApplicationList[0]);
                User Usr =[SELECT Id,profile.name,userType FROM User WHERE Id = : UserInfo.getUserId()];
                if(loanApplicationList[0].ownerId == UserInfo.getUserId()){
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
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'getLoanApplicationCategory', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    /*
   * @Method:      updateAdditionalDocument
   * @Created by:  Poonam Tilokani
   * @Description: This method insert or update the documents record and loan application transaction history record.
   * @Param:       String - Loan Application ID, document list and Flag(Boolean) variable
   * @Return:      Void
   */

    @AuraEnabled
    public static void updateAdditionalDocument(String loanApplicationId ,String data,Boolean submitFlag, String activeDocList, String dealId){//CISP-2432
        try{
            List<Documents__c> docList = (List<Documents__c>)JSON.deserialize(data, List<Documents__c>.class);
            List<String> activeDocName = (List<String>)JSON.deserialize(activeDocList, List<String>.class);//CISP-2432
            system.debug('doclist--'+docList);
            //CISP-2432
            for(Documents__c docObj : docList){
                if(activeDocName.contains(docObj.Document_Type__c)){
                    docObj.is_Active__c = true;
                }else
                docObj.is_Active__c = false;
            }

            Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            if(opp.Product_Type__c == 'Tractor'){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                for(Documents__c docObj : docList){
                    if(String.isBlank(docObj.Vehicle_Detail__c)){
                        docObj.Vehicle_Detail__c = VehicleLst[0].Id;
                    }
                }
            }

            if(docList.size()>0){
                upsert docList;
            }
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId And Name='Additional Documents' And Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];   
            if(lATList!=null && lATList.size()>0){
                lATList[0].Submitted_Flag__c = submitFlag;
                update lATList;
            }
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'updateAdditionalDocument', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    /*
   * @Method:      getBankName
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to get Bank name from Bank Master object.
   * @Return:      List<Bank_masters__c>
   */
    @AuraEnabled 
    public static List<Bank_masters__c> getBankName(){
        try{
            return [SELECT Id, Name from Bank_masters__c WITH SECURITY_ENFORCED];
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'getBankName', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    /*
   * @Method:      checkIfReadOnly
   * @Created by:  Poonam Tilokani
   * @Description: This method check weather addtional document loan transaction history record is submitted true or false.
   * @Param:       String - Loan Application ID
   * @Return:      boolean
   */
    @AuraEnabled
    Public static boolean checkIfReadOnly(String lAId, String dealId){
        try{
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:lAId And Name='Additional Documents' And Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(lATList!=null && lATList.size()>0){
                return (lATList[0].Submitted_Flag__c);
            }
            return false;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'checkIfReadOnly', System.Label.Apex, ex,lAId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    /*
   * @Method:      fetchRelatedDocument
   * @Created by:  Apoorva
   * @Description: This method return document records.
   * @Param:       String - Loan Application ID
   * @Return:      string
   */
    @AuraEnabled
    Public static string fetchRelatedDocument(String lAId, String dealId){
        try{
            List<Documents__c> relatedDocumentList = new List<Documents__c>();
            Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: lAId WITH SECURITY_ENFORCED];
            if(opp.Product_Type__c == 'Tractor'){
                List<Vehicle_Detail__c> vehLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
                relatedDocumentList= [SELECT Id,Document_Type__c 
                                        FROM Documents__c 
                                        WHERE Opportunity_Relation__c =: lAId AND Is_active__c = true AND Additional_Document__c = true AND Vehicle_Detail__c =: vehLst[0].Id
                                        WITH SECURITY_ENFORCED];
            }else{
                relatedDocumentList= [SELECT Id,Document_Type__c 
                                        FROM Documents__c 
                                        WHERE Opportunity_Relation__c =: lAId AND Is_active__c = true AND Additional_Document__c = true 
                                        WITH SECURITY_ENFORCED]; //CISP-2432
            }
            return JSON.serialize(relatedDocumentList);
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'fetchRelatedDocument', System.Label.Apex, ex,lAId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }

    /*
   * @Method:      fetchAdditionalDocuments
   * @Created by:  Gaurav
   * @Description: This method return document records.
   * @Param:       String - Document Type
   * @Return:      string
   */
  @AuraEnabled
  Public static String fetchAdditionalDocuments(String lAId, String dealId){
      try{
        List<Documents__c> relatedDocumentList = new List<Documents__c>();
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:lAId WITH SECURITY_ENFORCED];
        if(opp.Product_Type__c == 'Tractor'){
            List<Vehicle_Detail__c> vehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            relatedDocumentList= [SELECT Id,Document_Type__c,(select Id from ContentDocumentLinks) 
                                    FROM Documents__c 
                                    WHERE Opportunity_Relation__c =: lAId AND Is_active__c = true AND Additional_Document__c = true AND Vehicle_Detail__c =: vehicleLst[0].Id
                                    WITH SECURITY_ENFORCED];
        }else{
            relatedDocumentList= [SELECT Id,Document_Type__c,(select Id from ContentDocumentLinks) 
                                    FROM Documents__c 
                                    WHERE Opportunity_Relation__c =: lAId AND Is_active__c = true AND Additional_Document__c = true 
                                    WITH SECURITY_ENFORCED];
        }

        String documentName = '';
        //added if condition SFTRAC - 2549
        if(relatedDocumentList.size() != 0){
            for (Documents__c document : relatedDocumentList) {
                if(relatedDocumentList.size() == 1 && document.ContentDocumentLinks.size() == 0){
                    documentName = document.Document_Type__c;
                    break;
                }
            }
        }
        return documentName;
      }catch(Exception ex){
          ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'fetchAdditionalDocuments', System.Label.Apex, ex,lAId);
          throw new IND_Exception(ex.getMessage()); 
      }
  }
     /*
   * @Method:      fetchContentDocument
   * @Created by:  Apoorva
   * @Description: This method return Content document link.
   * @Param:       String - Loan Application ID and Document Type
   * @Return:      ContentDocumentLink
   */
    @AuraEnabled
    Public static ContentDocumentLink fetchContentDocument(String lAId, String docType, String dealId){
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: lAId WITH SECURITY_ENFORCED];
        try{
            ContentDocumentLink cdlList = new ContentDocumentLink();
            if(opp.Product_Type__c == 'Tractor'){
                List<Vehicle_Detail__c> vehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId];
                cdlList= [SELECT ContentDocumentId 
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId in ( SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: lAId AND Document_Type__c =: docType AND Is_active__c = true AND Vehicle_Detail__c =: vehicleLst[0].Id )
                            LIMIT 1];
            }else{
                cdlList= [SELECT ContentDocumentId 
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId in ( SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: lAId AND Document_Type__c =: docType AND Is_active__c = true ) 
                            LIMIT 1];
            }

            return cdlList;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'fetchContentDocument', System.Label.Apex, ex,lAId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
     /*
   * @Method:      fetchPicklistValue
   * @Created by:  Apoorva
   * @Description: This method return picklist field values.
   * @Param:       String - FieldName of document object
   * @Return:      List<Map<String, String>>
   */
    @AuraEnabled
    public static List<Map<String, String>> fetchPicklistValue(String fieldName) {
        try{
            String objApiName = 'Documents__c';
            List<Map<String,String>> options = new List<Map<String, String >>();
            Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
            if (objType == null) {
                return options;
            }
            Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
            if (fieldMap.get(fieldName) == null) {
                return options;
            }
            List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
            for (Schema.PicklistEntry f: pickListValues) {
                Map<String, String> values = new Map<String,String>{
                    'label' => f.getLabel(),
                        'value' => f.getValue()
                        };
                            options.add(values);
            }
            return options;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'fetchPicklistValue', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    /*
    * @Method:      postSavedDataOnSubmit
    * @Created by:  Apoorva
    * @Modified by : Poonam Tilokani, Rohan Saxena (CISP-3726)
    * @Description: This method update document record and check if any of the screen fields which are decided 'No' by CVO user 
    * 				so make loan transaction history record to false and if Product type is 'Passenger Vehicles' 
    * 				then it will be assign to previous owner of the loan application .
    * @Param:       String - Loan Application Id , String data(document records)
    * @Return:     	string
    */
    @AuraEnabled
    public static string postSavedDataOnSubmit(String loanApplicationId,String data, String dealId){
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        Boolean isAnyRecordFalse = false;
        List<Boolean> statusList = new List<Boolean>();
        List<Boolean> cheqList = new List<Boolean>();
        //CISP-3600 start 
        List<Documents__c> docList = (List<Documents__c>)JSON.deserialize(data, List<Documents__c>.class);
        system.debug('postSavedDataOnSubmit---'+ docList);
        if(Schema.sObjectType.Documents__c.isUpdateable() && Schema.SObjectType.Documents__c.isCreateable()){

            if(opp.Product_Type__c == 'Tractor'){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                for(Documents__c docObj : docList){
                    if(String.isBlank(docObj.Vehicle_Detail__c)){
                        docObj.Vehicle_Detail__c = VehicleLst[0].Id;
                    }
                }
            }

            upsert docList;
        }//CISP-3600 end
        List<Opportunity> loan = new List<Opportunity>([SELECT Id,Account.Type,OwnerId,Application_number__c,CVO_Accepts_SPDC_Documents__c,Product_Type__c,StageName, Vehicle_Type__c,Name, Vehicle_Sub_Category__c, Applicant__c, Sanction_Status__c, IND_Not_Provided_Documents__c,IND_Remark__c//CISP-3726
                                                        FROM Opportunity WHERE id = :loanApplicationId WITH SECURITY_ENFORCED]);
        try{
            List<Loan_Application_Transaction_History__c> transactionList = [SELECT Id, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c 
                                                                             FROM Loan_Application_Transaction_History__c 
                                                                             where Loan_Application_ID__c  =: loanApplicationId
                                                                             and Module__c = 'Pre Disbursement Check' and Submitted_Flag__c = false
                                                                            and screen__c != null and screen__c not in ('Additional Documents') And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(transactionList.size()>0){
                return 'All the modules screens have not been completed, please complete';
            }else{
                Map<String,Loan_Application_Transaction_History__c> loanHistoryMapForPreDis = new Map<String,Loan_Application_Transaction_History__c>();
                for(Loan_Application_Transaction_History__c loanHistoryPreObj : [SELECT Id, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c ,New_Owner__c,Current_Owner__c
                                                                              FROM Loan_Application_Transaction_History__c 
                                                                              where Loan_Application_ID__c  =: loanApplicationId
                                                                              and Module__c = 'Pre Disbursement Check' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED]){
                                                                                  loanHistoryMapForPreDis.put(loanHistoryPreObj.Screen__c, loanHistoryPreObj);                                                         
                                                                              }
                Map<String,Loan_Application_Transaction_History__c> loanHistoryMap = new Map<String,Loan_Application_Transaction_History__c>();
                for(Loan_Application_Transaction_History__c loanHistoryObj : [SELECT Id, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c ,New_Owner__c,Current_Owner__c
                                                                              FROM Loan_Application_Transaction_History__c 
                                                                              where Loan_Application_ID__c  =: loanApplicationId
                                                                              and Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED]){
                                                                                  loanHistoryMap.put(loanHistoryObj.Screen__c, loanHistoryObj);                                                         
                                                                              }
                List<String> docTypeList = new List<String>{'RC Document','DD for closing existing loan','Foreclosure letter for closed existing loan',
                    'Seller\'s Passbook','NOC','Seller\'s Bank Statement','Seller\'s Cancel Cheque','Borrower\'s Passbook',
                    'Borrower\'s Bank Statement','Borrower\'s Cancel Cheque','Co-Borrower\'s Passbook','Co-Borrower\'s Bank Statement',
                    'Co-Borrower\'s Cancel Cheque','Buyer-Seller Undertaking letter','Indemnity letter','Sale Agreement','Tax Invoice',
                    'Branch Undertaking letter','Declaration of Borrower Good Health','Declaration of Co-Borrower Good Health','Payment Receipt','Cheques SPDC'};
                        List<Documents__c> documentList = new List<Documents__c>();
                
                if(opp.Product_Type__c == 'Tractor'){
                    List<Vehicle_Detail__c> vehLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                    documentList = [SELECT Id, Document_Type__c,Name,Are_enter_details_as_per_RC_doc_upload__c,Are_entered_details_as_per_document_uplo__c,Is_sale_DD_legible__c,Is_sale_Foreclosure_Letter_legible__c,entered_details_asper_passbook_upload__c,Is_passbook_legible_for_Seller__c,
                                enter_details_asper_bank_STMT_upload__c,Is_bank_statement_legible_for_Seller__c,enter_details_as_per_canc_chq_upload__c,
                                Is_cancelled_cheque_legible_for_Seller__c,enter_DETLS_asper_BWR_passbook_upload__c,
                                Is_passbook_legible_for_Borrower__c,enter_DETLS_asper_BWR_bank_STMT_upload__c,Is_bank_statement_legible_for_Borrower__c,
                                enter_DETLS_as_per_BWR_canc_chq_upload__c,Is_cancelled_cheque_legible_for_Borrower__c,
                                enter_DETLS_asper_COBWR_pasbook_upload__c,Is_passbook_legible_for_CoBorrower__c,DETLS_asper_COBWR_bank_STMT_upload__c,
                                Is_bank_statement_legible_for_CoBorrowe__c,DETLS_asper_COBWR_canc_chq_upload__c,
                                Is_cancelled_cheque_legible_CoBorrower__c,Buyer_Seller_Undertaking_Letter_legib__c,
                                Buy_Seller_Indemnity_LTR_legible__c,Is_Sale_Agreement_legible__c,enter_details_asper_Tax_Invoice_upload__c,
                                Is_Tax_Invoice_legible__c,Are_enter_details_asper_NOC_doc_upload__c,Is_Cancelled_NOC_legible__c,
                                Is_Branch_Undertaking_Letter_legible__c,Doc_for_Good_Health_borrower_legible__c,Doc_for_Good_Health_coborrower_legible__c,enter_DETLS_asper_Payment_doc_upload__c,Is_Payment_Receipt_legible__c,Cheque_legible__c
                                FROM Documents__c 
                                WHERE document_type__c in: docTypeList
                                AND is_active__c = true AND (additional_document__c = true OR Document_Type__c = 'Cheques SPDC') AND Opportunity_Relation__c =:loanApplicationId
                                AND Vehicle_Detail__c =: vehLst[0].Id
                                WITH SECURITY_ENFORCED];
                }else{
                    documentList = [SELECT Id, Document_Type__c,Name,Are_enter_details_as_per_RC_doc_upload__c,Are_entered_details_as_per_document_uplo__c,Is_sale_DD_legible__c,Is_sale_Foreclosure_Letter_legible__c,entered_details_asper_passbook_upload__c,Is_passbook_legible_for_Seller__c,
                                enter_details_asper_bank_STMT_upload__c,Is_bank_statement_legible_for_Seller__c,enter_details_as_per_canc_chq_upload__c,
                                Is_cancelled_cheque_legible_for_Seller__c,enter_DETLS_asper_BWR_passbook_upload__c,
                                Is_passbook_legible_for_Borrower__c,enter_DETLS_asper_BWR_bank_STMT_upload__c,Is_bank_statement_legible_for_Borrower__c,
                                enter_DETLS_as_per_BWR_canc_chq_upload__c,Is_cancelled_cheque_legible_for_Borrower__c,
                                enter_DETLS_asper_COBWR_pasbook_upload__c,Is_passbook_legible_for_CoBorrower__c,DETLS_asper_COBWR_bank_STMT_upload__c,
                                Is_bank_statement_legible_for_CoBorrowe__c,DETLS_asper_COBWR_canc_chq_upload__c,
                                Is_cancelled_cheque_legible_CoBorrower__c,Buyer_Seller_Undertaking_Letter_legib__c,
                                Buy_Seller_Indemnity_LTR_legible__c,Is_Sale_Agreement_legible__c,enter_details_asper_Tax_Invoice_upload__c,
                                Is_Tax_Invoice_legible__c,Are_enter_details_asper_NOC_doc_upload__c,Is_Cancelled_NOC_legible__c,
                                Is_Branch_Undertaking_Letter_legible__c,Doc_for_Good_Health_borrower_legible__c,Doc_for_Good_Health_coborrower_legible__c,enter_DETLS_asper_Payment_doc_upload__c,Is_Payment_Receipt_legible__c,Cheque_legible__c
                                FROM Documents__c where document_type__c in: docTypeList
                                and is_active__c = true and 
                                (additional_document__c = true OR Document_Type__c = 'Cheques SPDC') 
                                and Opportunity_Relation__c =:loanApplicationId WITH SECURITY_ENFORCED];
                }
                system.debug('documentList--'+documentList);
                if(documentList.size()>0){
                    for(Documents__c doc : documentList){
                        if(doc.Document_Type__c=='RC Document' && (doc.Are_enter_details_as_per_RC_doc_upload__c == 'No' ||doc.Are_entered_details_as_per_document_uplo__c == 'No')){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'DD for closing existing loan' && doc.Is_sale_DD_legible__c == 'No'){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'Foreclosure letter for closed existing loan' && doc.Is_sale_Foreclosure_Letter_legible__c == 'No'){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'Seller\'s Passbook' && (doc.entered_details_asper_passbook_upload__c == 'No' || doc.Is_passbook_legible_for_Seller__c == 'No')){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'Seller\'s Bank Statement' && (doc.enter_details_asper_bank_STMT_upload__c == 'No' || doc.Is_bank_statement_legible_for_Seller__c == 'No')){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'Seller\'s Cancel Cheque' && (doc.enter_details_as_per_canc_chq_upload__c == 'No' || doc.Is_cancelled_cheque_legible_for_Seller__c == 'No')){
                            statusList.add(true);
                        } 
                        if(doc.Document_Type__c == 'Borrower\'s Passbook' && (doc.enter_DETLS_asper_BWR_passbook_upload__c == 'No' || doc.Is_passbook_legible_for_Borrower__c == 'No')){
                            statusList.add(true);
                        } 
                        if(doc.Document_Type__c == 'Borrower\'s Bank Statement' && (doc.enter_DETLS_asper_BWR_bank_STMT_upload__c == 'No' || doc.Is_bank_statement_legible_for_Borrower__c == 'No')){
                            statusList.add(true);
                        } 
                        if(doc.Document_Type__c == 'Borrower\'s Cancel Cheque' && (doc.enter_DETLS_as_per_BWR_canc_chq_upload__c == 'No' || doc.Is_cancelled_cheque_legible_for_Borrower__c == 'No')){
                            statusList.add(true);
                        } 
                        if(doc.Document_Type__c == 'Co-Borrower\'s Passbook' && (doc.enter_DETLS_asper_COBWR_pasbook_upload__c == 'No' || doc.Is_passbook_legible_for_CoBorrower__c == 'No')){
                          statusList.add(true);  
                        } 
                        if(doc.Document_Type__c == 'Co-Borrower\'s Bank Statement' && (doc.DETLS_asper_COBWR_bank_STMT_upload__c == 'No' || doc.Is_bank_statement_legible_for_CoBorrowe__c == 'No')){
                            statusList.add(true);
                        } 
                        if(doc.Document_Type__c == 'Co-Borrower\'s Cancel Cheque' && (doc.DETLS_asper_COBWR_canc_chq_upload__c == 'No' ||doc.Is_cancelled_cheque_legible_CoBorrower__c == 'No' )){
                           statusList.add(true); 
                        }
                        if(doc.Document_Type__c == 'Buyer-Seller Undertaking letter' && doc.Buyer_Seller_Undertaking_Letter_legib__c == 'No'){
                            statusList.add(true);
                        }if(doc.Document_Type__c == 'Indemnity letter' && doc.Buy_Seller_Indemnity_LTR_legible__c == 'No'){
                            statusList.add(true);
                        }if(doc.Document_Type__c == 'Sale Agreement' && doc.Is_Sale_Agreement_legible__c == 'No'){
                            statusList.add(true);
                        }if(doc.Document_Type__c == 'Tax Invoice' && (doc.enter_details_asper_Tax_Invoice_upload__c == 'No' || doc.Is_Tax_Invoice_legible__c == 'No')){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'NOC' && (doc.Are_enter_details_asper_NOC_doc_upload__c == 'No' || doc.Is_Cancelled_NOC_legible__c == 'No')){
                            statusList.add(true);
                        }if(doc.Document_Type__c == 'Branch Undertaking letter' && doc.Is_Branch_Undertaking_Letter_legible__c == 'No'){
                            statusList.add(true);
                        }if(doc.Document_Type__c == 'Declaration of Borrower Good Health' && doc.Doc_for_Good_Health_borrower_legible__c == 'No'){
                            statusList.add(true);
                        }if(doc.Document_Type__c == 'Declaration of Co-Borrower Good Health' && doc.Doc_for_Good_Health_coborrower_legible__c == 'No'){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'Payment Receipt' && (doc.enter_DETLS_asper_Payment_doc_upload__c == 'No' || doc.Is_Payment_Receipt_legible__c == 'No')){
                            statusList.add(true);
                        }
                        if(doc.Document_Type__c == 'Cheques SPDC' && doc.Cheque_legible__c == 'False'){
                            cheqList.add(true);
                        }
                    }
                    system.debug('statusList'+statusList);
                    if(statusList.size()>0){
                        if(statusList.contains(true)){
                            if(loanHistoryMap.containsKey('Additional Documents')){
                            	loanHistoryMap.get('Additional Documents').Submitted_Flag__c = false;
                                if(loanHistoryMapForPreDis.containsKey('Additional Documents')){
                                    loanHistoryMapForPreDis.get('Additional Documents').Submitted_Flag__c = false;
                                }
                        	}
                        }
                    }
                }
                //CISP-3726
                if(loan[0].IND_Not_Provided_Documents__c == 'No'){
                    if(loanHistoryMap.containsKey('Additional Documents')){
                        loanHistoryMap.get('Additional Documents').Submitted_Flag__c = false;
                        if(loanHistoryMapForPreDis.containsKey('Additional Documents')){
                            loanHistoryMapForPreDis.get('Additional Documents').Submitted_Flag__c = false;
                            loan[0].IND_Not_Provided_Documents__c = '';
                        }
                    }
                }

                List<Vehicle_Detail__c> vehicleList = [SELECT Id, Is_RC_Limit_Check_correctly_captured__c, Vehicle_inspection_approved_by_CVO__c, Loan_Application__c,Deal_Number__r.Accepts_SPDC_Documents__c FROM Vehicle_Detail__c
                                                       WHERE Loan_Application__c=:loanApplicationId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                if(vehicleList.size()>0){
                    if(vehicleList[0].Is_RC_Limit_Check_correctly_captured__c == 'No' || vehicleList[0].Vehicle_inspection_approved_by_CVO__c == 'No'){
                        if(loanHistoryMap.containsKey('Vehicle Inspection and RC Check')){
                            loanHistoryMap.get('Vehicle Inspection and RC Check').Submitted_Flag__c = false;
                            if(loanHistoryMapForPreDis.containsKey('Vehicle Inspection and RC Check')){
                                loanHistoryMapForPreDis.get('Vehicle Inspection and RC Check').Submitted_Flag__c = false;
                            }
                        }
                    }
                }
                if(opp.Product_Type__c == 'Tractor'){
                    if((vehicleList.size() > 0 && vehicleList[0].Deal_Number__r.Accepts_SPDC_Documents__c == 'No') || (cheqList.size() > 0)){
                        if(loanHistoryMap.containsKey('Security Mandate')){
                            loanHistoryMap.get('Security Mandate').Submitted_Flag__c = false;
                            if(loanHistoryMapForPreDis.containsKey('Security Mandate')){
                                loanHistoryMapForPreDis.get('Security Mandate').Submitted_Flag__c = false;
                            }
                        }
                    }
                }else{
                //CISP-2432 "Changed stage from Post sanction to Pre Dis."
                List<Opportunity> lstOpportunity= [select id,Account.Type,OwnerId,Application_number__c,CVO_Accepts_SPDC_Documents__c,Product_Type__c,StageName, Vehicle_Type__c,Name, Vehicle_Sub_Category__c, Applicant__c, Sanction_Status__c
                                                   from Opportunity where id = :loanApplicationId AND StageName= 'Pre Disbursement Check' WITH SECURITY_ENFORCED];
                if(lstOpportunity.size()>0){
                    if(lstOpportunity[0].CVO_Accepts_SPDC_Documents__c == 'No'){
                        if(loanHistoryMap.containsKey('Security Mandate')){
                            loanHistoryMap.get('Security Mandate').Submitted_Flag__c = false;
                            if(loanHistoryMapForPreDis.containsKey('Security Mandate')){
                                loanHistoryMapForPreDis.get('Security Mandate').Submitted_Flag__c = false;
                            }
                        }
                    }
                }
                }

                List<Loan_Agreement__c> loanAgreementList = new List<Loan_Agreement__c>();

                if(opp.Product_Type__c == 'Tractor'){
                    loanAgreementList = [SELECT Id, Is_Physical_Agreement_Eligible__c,Is_Stamp_Duty_as_per_norms__c,Loan_Application__c 
                                            FROM Loan_Agreement__c
                                            WHERE Loan_Application__c =:loanApplicationId AND Deal_Number__c =: dealId 
                                            WITH SECURITY_ENFORCED];
                }else{
                    loanAgreementList = [SELECT Id, Is_Physical_Agreement_Eligible__c,Is_Stamp_Duty_as_per_norms__c,Loan_Application__c 
                                            FROM Loan_Agreement__c
                                            WHERE Loan_Application__c =:loanApplicationId 
                                            WITH SECURITY_ENFORCED];
                }
                
                if(loanAgreementList.size()>0){
                    if(loanAgreementList[0].Is_Physical_Agreement_Eligible__c == 'No'  || loanAgreementList[0].Is_Stamp_Duty_as_per_norms__c == 'No'){
                        if(loanHistoryMap.containsKey('Loan Agreement')){
                            loanHistoryMap.get('Loan Agreement').Submitted_Flag__c = false;
                            if(loanHistoryMapForPreDis.containsKey('Loan Agreement')){
                                loanHistoryMapForPreDis.get('Loan Agreement').Submitted_Flag__c = false;
                            }
                        }
                    }
                }

                List<Repayments__c> repaymentList = new List<Repayments__c>();

                if(opp.Product_Type__c == 'Tractor'){
                    repaymentList = [SELECT Id, Is_ACH_Mandate_legible__c, Is_Cancelled_Cheque_legible__c, Is_SI_form_Legible__c, ACH_Form_filled_correctly__c, SI_Form_filled_correctly__c, SI_Status__c, Loan_Application__c ,Repayment_Method__c, Repayments_Captured_Correctly__c
                                        FROM Repayments__c 
                                        WHERE Loan_Application__c =:loanApplicationId AND Deal_Number__c =: dealId
                                        WITH SECURITY_ENFORCED];
                }else{
                    repaymentList = [SELECT Id, Is_ACH_Mandate_legible__c, Is_Cancelled_Cheque_legible__c, Is_SI_form_Legible__c, ACH_Form_filled_correctly__c, SI_Form_filled_correctly__c, SI_Status__c, Loan_Application__c ,Repayment_Method__c, Repayments_Captured_Correctly__c
                                        FROM Repayments__c 
                                        WHERE Loan_Application__c =:loanApplicationId 
                                        WITH SECURITY_ENFORCED];
                }
                
                if(repaymentList.size()>0){
                    if((repaymentList[0].Repayment_Method__c == 'A' && (repaymentList[0].Is_ACH_Mandate_legible__c == 'No' || repaymentList[0].Is_Cancelled_Cheque_legible__c == 'No' || repaymentList[0].ACH_Form_filled_correctly__c == 'No')) || repaymentList[0].Repayment_Method__c == 'I' && (repaymentList[0].SI_Form_filled_correctly__c == 'No' || repaymentList[0].Is_SI_form_Legible__c == 'No') || repaymentList[0].Repayments_Captured_Correctly__c == 'No')
                    {
                        if(loanHistoryMap.containsKey('Repayment Mandate')){
                            loanHistoryMap.get('Repayment Mandate').Submitted_Flag__c = false;
                            if(loanHistoryMapForPreDis.containsKey('Repayment Mandate')){
                                loanHistoryMapForPreDis.get('Repayment Mandate').Submitted_Flag__c = false;
                            }
                        }
                    }
                }
                List<Boolean> ihmDocCheckList = new List<Boolean>();
                List<Documents__c> ihmList = new List<Documents__c>();
                List<IHM__c> ihmObj = new List<IHM__c>();
                if(opp.Product_Type__c == 'Tractor'){
                    List<Vehicle_Detail__c> vehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                    ihmList = [SELECT Id, Is_IHM_Receipt_legible__c,Document_Type__c,Is_Active__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c =: loanApplicationId AND Document_Type__c =: System.Label.IHM_Receipt AND Is_Active__c = true AND Vehicle_Detail__c =: vehicleLst[0].Id
                                WITH SECURITY_ENFORCED];
                    ihmObj  = [SELECT Id, Select_Yes_if_IHM_details_are_correct__c 
                                FROM IHM__c 
                                WHERE Loan_Application__c =: loanApplicationId AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED];
                }else{
                    ihmList = [SELECT Id, Is_IHM_Receipt_legible__c,Document_Type__c,Is_Active__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c =: loanApplicationId AND Document_Type__c =: System.Label.IHM_Receipt AND Is_Active__c = true 
                                WITH SECURITY_ENFORCED];
                    ihmObj  = [SELECT Id, Select_Yes_if_IHM_details_are_correct__c 
                                FROM IHM__c 
                                WHERE Loan_Application__c =: loanApplicationId 
                                WITH SECURITY_ENFORCED];
                }
                
                if(ihmList.size()>0 || ihmObj.size()>0){
                    for(Documents__c doc : ihmList){
                        if(doc.Is_IHM_Receipt_legible__c == false){
                            ihmDocCheckList.add(true);
                        }
                    }
                    if(ihmDocCheckList.contains(true) ||  ihmObj[0].Select_Yes_if_IHM_details_are_correct__c == false){
                        if(loanHistoryMap.containsKey('IHM')){
                            loanHistoryMap.get('IHM').Submitted_Flag__c = false;
                            if(loanHistoryMapForPreDis.containsKey('IHM')){
                                loanHistoryMapForPreDis.get('IHM').Submitted_Flag__c = false;
                            }
                        }
                    }
                }
                
                List<Invoice_Details__c> invoiceList = new List<Invoice_Details__c>();

                if(opp.Product_Type__c == 'Tractor'){
                    invoiceList = [SELECT Id, Is_Invoice_date_correctly_captured__c, Is_Invoice_legible__c, Is_Invoice_amount_correctly_captured__c, Do_you_accept_uploaded_invoice__c 
                                    FROM Invoice_Details__c
                                    WHERE Loan_Application__c =:loanApplicationId AND Deal_Number__c =: dealId
                                    WITH SECURITY_ENFORCED];
                }else{
                    invoiceList = [SELECT Id, Is_Invoice_date_correctly_captured__c, Is_Invoice_legible__c, Is_Invoice_amount_correctly_captured__c, Do_you_accept_uploaded_invoice__c 
                                    FROM Invoice_Details__c
                                    WHERE Loan_Application__c =:loanApplicationId 
                                    WITH SECURITY_ENFORCED];
                }
                
                if(invoiceList.size()>0){
                    if(invoiceList[0].Is_Invoice_date_correctly_captured__c == 'No' || invoiceList[0].Is_Invoice_legible__c == 'No' || invoiceList[0].Is_Invoice_amount_correctly_captured__c == 'No'|| invoiceList[0].Do_you_accept_uploaded_invoice__c== 'No'){
                        if(loanHistoryMap.containsKey('Invoice')){
                            loanHistoryMap.get('Invoice').Submitted_Flag__c = false;
                            if(loanHistoryMapForPreDis.containsKey('Invoice')){
                                loanHistoryMapForPreDis.get('Invoice').Submitted_Flag__c = false;
                            }
                        }
                    }
                }

                List<Documents__c> docList1 = new List<Documents__c>();
                if(opp.Product_Type__c == 'Tractor'){
                    List<Vehicle_Detail__c> vehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                    docList1 = [SELECT Id, Document_Type__c, Is_Document_Eligible__c, Correctly_Captured__c, Opportunity_Relation__c 
                                    FROM Documents__c
                                    WHERE Opportunity_Relation__c=:loanApplicationId AND Document_Type__c in ('RTO','DPN','POA') AND is_active__c = true AND Vehicle_Detail__c =: vehicleLst[0].Id
                                    WITH SECURITY_ENFORCED];
                }else{
                    docList1 = [SELECT Id, Document_Type__c, Is_Document_Eligible__c, Correctly_Captured__c, Opportunity_Relation__c 
                                    FROM Documents__c
                                    WHERE Opportunity_Relation__c=:loanApplicationId AND Document_Type__c in ('RTO','DPN','POA') AND is_active__c = true 
                                    WITH SECURITY_ENFORCED];
                }
                
                if(docList1.size()>0){
                    for(Documents__c docObj :  docList1){
                        if((docObj.Document_Type__c == 'RTO' || docObj.Document_Type__c == 'DPN' || docObj.Document_Type__c == 'POA')
                           &&(docObj.Is_Document_Eligible__c == 'No' || docObj.Correctly_Captured__c == 'No')){
                               if(loanHistoryMap.containsKey('RTO, DPN, POA Documents Upload')){
                                   loanHistoryMap.get('RTO, DPN, POA Documents Upload').Submitted_Flag__c = false;
                                      if(loanHistoryMapForPreDis.containsKey('RTO, DPN, POA Documents Upload')){
                                        loanHistoryMapForPreDis.get('RTO, DPN, POA Documents Upload').Submitted_Flag__c = false;
                                      }
                               }
                           }
                    }
                }
                List<CAM__c> camList = [SELECT Id, CAM_conditional_approval_requirement__c FROM CAM__c
                                        WHERE Loan_Application__c =:loanApplicationId WITH SECURITY_ENFORCED];
                if(camList.size()>0){
                    if(camList[0].CAM_conditional_approval_requirement__c == 'No'){
                        // Revoke 
                    }
                }
                if(loanHistoryMap.size()>0){
                   if(Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()){
                    update loanHistoryMap.values();
                    update loanHistoryMapForPreDis.values();
                   }
                }
                List<Loan_Application_Transaction_History__c> loanHisAfterUpdate = [SELECT Id, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c ,New_Owner__c,Current_Owner__c
                                                                              FROM Loan_Application_Transaction_History__c 
                                                                              where Loan_Application_ID__c  =: loanApplicationId
                                                                              and Module__c = 'Post Sanction Checks and Documentation' and Submitted_Flag__c = false AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                if(loanHisAfterUpdate.size()>0){
                    isAnyRecordFalse = true;
                    if(isAnyRecordFalse == true){
                        if(loanHistoryMap.containsKey('RTO, DPN, POA Documents Upload')){
                            loanHistoryMap.get('RTO, DPN, POA Documents Upload').Submitted_Flag__c = false;
                        }
                        if(loanHistoryMapForPreDis.containsKey('Additional Documents')){
                            loanHistoryMapForPreDis.get('Additional Documents').Submitted_Flag__c = false;
                        }
                        if(loanHistoryMapForPreDis.containsKey('RTO, DPN, POA Documents Upload')){
                            loanHistoryMapForPreDis.get('RTO, DPN, POA Documents Upload').Submitted_Flag__c = false;
                        }
                        if(Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()){
                            update loanHistoryMap.values();
                            update loanHistoryMapForPreDis.values();
                        }
                    }
                }
                
                

                if(docList.size()>0 || loan[0].IND_Not_Provided_Documents__c != null ){ //CISP-3726
                   List<Loan_Application_Transaction_History__c> transactionList1 = [SELECT Id, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c 
                                                                             FROM Loan_Application_Transaction_History__c 
                                                                             where Loan_Application_ID__c  =: loanApplicationId
                                                                             and Module__c = 'Pre Disbursement Check'
                                                                            and screen__c != null and screen__c = 'Additional Documents' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                                                        
                    if(transactionList1.size()>0 && (isAnyRecordFalse == false || loan[0].Product_Type__c == System.Label.Tractor)){
                        transactionList1[0].Submitted_Flag__c = true;
                        if(Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()){
                            update transactionList1;
                        }
                    }
                    boolean checkAdditional = false;
                    if(loan.size()>0){
                        String ownerId;
                        if(isAnyRecordFalse == false){
                         	loan[0].StageName  = System.label.Loan_Stage_Additional_Documents;
                        	loan[0].Sub_Stage__c = System.label.Loan_SubStage_Additional_Documents;
                        }else{
                            loan[0].StageName  = 'Post Sanction Checks and Documentation';
                        	loan[0].Sub_Stage__c = '';
                            if((loan[0].Product_Type__c == System.Label.Tractor) || (loan[0].Product_Type__c =='Passenger Vehicles' && loanHistoryMap.containsKey('RTO, DPN, POA Documents Upload'))){
                                ownerId=loanHistoryMap.get('RTO, DPN, POA Documents Upload')?.Current_Owner__c;
                                if(ownerId!=null){
                                    loan[0].OwnerId=ownerId;
                                }
                            }
                        }
                        if(Schema.sObjectType.Opportunity.isUpdateable()){
                            if(loan[0].Product_Type__c == System.Label.Tractor){
                                if(allDealPDCompleted(loan[0].Id)){
                                    if(isAnyRecordFalse == true){
                                        List<Loan_Application_Transaction_History__c> hisList = new List<Loan_Application_Transaction_History__c>([SELECT Id FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =: loan[0].Id AND Module__c = 'Pre Disbursement Check' AND Submitted_Flag__c = false AND Screen__c='Additional Documents']);
                                        for (Loan_Application_Transaction_History__c lATH : hisList) {
                                            lATH.Submitted_Flag__c = false;
                                        }
                                        update hisList;
                                    }
                                    update loan;
                                }
                            }else{
                                update loan;
                            }
                        }
                        if(isAnyRecordFalse && loan[0].Product_Type__c =='Passenger Vehicles'){
                            Set<String> recepients = new Set<String>();
                            recepients.add(ownerId);
                            String message = 'Loan Application ' + loan[0].Name + ' has been assigned to you.';
                            notifyUsers(recepients,loanApplicationId,message);
                        } 
                      
                    } 
                    
                    return 'Success';
                }
                else if(loanHisAfterUpdate[0].Screen__c!='Additional Documents' && loan[0].StageName== 'Post Sanction Checks and Documentation'){
                    return 'Additional Document Screen is already Submitted.';
                }
                else{
                    return 'Data Submit Error';
                }
            }
            
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'postSavedDataOnSubmit', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }

    public static Boolean allDealPDCompleted(String loanId){
        Boolean result = true;
        List<Loan_Application_Transaction_History__c> hisList = new List<Loan_Application_Transaction_History__c>();
        hisList = [SELECT Id 
                    FROM Loan_Application_Transaction_History__c 
                    WHERE Loan_Application_ID__c =: loanId AND Module__c = 'Pre Disbursement Check' AND Submitted_Flag__c = false AND Screen__c	='Additional Documents'
                    WITH SECURITY_ENFORCED];
        if(hisList.size()>0){
            result = false;
        }

        return result;
    }

    /* 
    @description :   Method to send notification
    @param :  Set<String> recipientsIds - userIds to whom notification should be sent
    @param :  String loanId - Opportunity Id
    @param :  String loanName - Opportunity Name
    @return : Void 
    */
    public static void notifyUsers(Set<String> recipientsIds, String loanId, String message) {
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Loan Application Assignment');
        notification.setBody(message);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(loanId);
        try {
            notification.send(recipientsIds);
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'notifyUsers', System.Label.Apex, ex,loanId);
            throw new IND_Exception(ex.getMessage()); 
        }
  }
  @AuraEnabled
    public static List<ContentVersion> getContentVersionType(String contentVersionId){
        try{
            List<ContentVersion> versionList = [Select Id, FileType from ContentVersion where Id =: contentVersionId Limit 1];
            if(versionList.size()>0){
                return versionList;
            }
            return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'getContentVersionType', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    /*
* @Method:      deleteDocRecord
* @Created by:  Rohan Saxena
* @Description: CISP-4122
* @Param:       String - Loan Application Id , Map<String,Boolean>
* @Return:     	void
*/
    @AuraEnabled
    public static void deleteDocRecord(String loanApplicationId,List<String> docDetails){
        try{
            if(!docDetails.isEmpty()){
                Delete [Select Id from Documents__c where Opportunity_Relation__c=:loanApplicationId AND Document_Type__c IN: docDetails AND Additional_Document__c=true];
            }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AdditionalDocumentsClass', 'deleteDocRecord', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
}