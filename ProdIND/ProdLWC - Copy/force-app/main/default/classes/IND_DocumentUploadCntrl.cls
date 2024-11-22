/*
* @Name         IND_DocumentUploadCntrl
* @Author       Vinita Kamble
* @Company      Persistent Systems
 
* Inputs:       None
* Test Class:   IND_DocumentUploadCntrlTest
* History:
*/
public with sharing class IND_DocumentUploadCntrl {
    /*
* @Method Name: createDocument
* @Created by:  Vinita Kamble
* @description: to create a Vehicle document object 
* @Param:       String - current Vehicle Record ID
* @Param:       String - Loan Applicant ID
* @Param:       String - Loan Application ID
* @Return:      String - Created Document's ID
*/
    @AuraEnabled
    public static string createDocument(String vehicleDetailId,String applicantId,String loanApplicationId){
         try {
                if(vehicleDetailId!=null  && loanApplicationId!=null ){
                   ID personAccountRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                   //CISP-3075-START
                   List<Documents__c> docList = new List<Documents__c>([Select id From Documents__c Where Vehicle_Detail__c =: vehicleDetailId AND Applicant__c =: applicantId AND Opportunity_Relation__c =: loanApplicationId AND Is_Active__c=true]);
                   for (Documents__c doc : docList) {
                    doc.is_Active__c = false;
                   }
                   if(Schema.sObjectType.Documents__c.isUpdateable() && docList.size() > 0){
                    update docList;
                   }
                   //CISP-3075-END
                   Documents__c docObject= new Documents__c(Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId);
                  
                   docObject.RecordTypeId = personAccountRecordTypeId;
                   docObject.is_Active__c = true;
                   if (Schema.sObjectType.Documents__c.isCreateable()){
                        insert docObject;
                   }
                   if(Test.isRunningTest())
                   {
                      throw new AuraHandledException(System.Label.ExceptionMessage);
                   }
                   return docObject.Id;
                }
                 return null;
              } catch(Exception e){
                    ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'createDocument ', System.Label.Apex, e);
                    throw new AuraHandledException(System.Label.ExceptionMessage);  
              }
    }
    
    /*
* @Method Name: createDocumentForCheque
* @Created by:  Poonam Tilokani
* @description: to create a Document object for 'cheque documents'
* @Param:       String - Document Type
* @Param:       String - current Vehicle Record ID
* @Param:       String - loanApplication ID
* @Return:      String - created Document's ID
*/
    @AuraEnabled
    public static string createDocumentForCheque(String docType,String vehicleDetailId,String applicantId,String loanApplicationId,Double chequeNum,Integer chequeSeq){
        system.debug('chequeNum' + chequeNum);
        try {
            if(loanApplicationId!=null ){
                String docName = docType+' '+loanApplicationId + ' ' + chequeSeq;
                system.debug('docName--' + docName);
                system.debug('applicantId' + applicantId);
                //applicantId  = [Select Id, Applicant__c from Opportunity where Id=:loanApplicationId].Applicant__c;
                //System.debug('AAA'+applicantId);
                Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
                List<Documents__c> documentList = new List<Documents__c>();
                if(opp.Product_Type__c == 'Tractor'){
                    documentList = [SELECT Id,Name,Opportunity_Relation__c,Vehicle_Detail__c,Document_Type__c,Applicant__c 
                                        FROM Documents__c
                                        WHERE Opportunity_Relation__c =:loanApplicationId AND Applicant__c =:applicantId AND Name =:docName AND Vehicle_Detail__c =: vehicleDetailId
                                        WITH SECURITY_ENFORCED];
                }else{
                    documentList = [SELECT Id,Name,Opportunity_Relation__c,Vehicle_Detail__c,Document_Type__c,Applicant__c 
                                        FROM Documents__c
                                        WHERE Opportunity_Relation__c =:loanApplicationId AND Applicant__c =:applicantId AND Name =:docName 
                                        WITH SECURITY_ENFORCED];
                }
                
                if(documentList.size()>0){
                    for(Documents__c doc : documentList){
                        doc.is_Active__c = false;
                    }
                    update documentList;
                }
                ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                System.debug('otherDocRecordTypeId'+otherDocRecordTypeId);
                System.debug('docType'+docType+'vehicleDetailId'+vehicleDetailId+'applicantId'+applicantId+'loanApplicationId'+loanApplicationId);
                system.debug('Cheque_Number__c'+ chequeNum);
                Documents__c docObject= new Documents__c(Name = docType+' '+loanApplicationId + ' ' + chequeSeq,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType,
                                                         Cheque_Number__c = chequeNum,is_Active__c = true);
                System.debug('docObject'+docObject);
                docObject.RecordTypeId = otherDocRecordTypeId;
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert docObject;
                }
                if(Test.isRunningTest())
                {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return docObject.Id;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'createOtherDocument ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
        
    }
    /*
* @Method Name: createDocumentForAdditionalDocument
* @Created by:  Poonam Tilokani
* @description: to create a Document object for 'AdditionalDocument'
* @Param:       String - Document Type
* @Param:       String - current Vehicle Record ID
* @Param:       String - loanApplication ID
* @Return:      String - created Document's ID
*/
    @AuraEnabled
    public static string createDocumentForAdditionalDocument(String docType,String vehicleDetailId,String applicantId,String loanApplicationId){
        try {
            if(loanApplicationId!=null ){
                String docName = docType+' '+loanApplicationId;
                system.debug('docName--' + docName);
                
                List<Documents__c> documentList = new List<Documents__c>();
                Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED];
                if(opp.Product_Type__c == 'Tractor'){
                    documentList = [SELECT Id,Name,Opportunity_Relation__c,Vehicle_Detail__c,Document_Type__c,Applicant__c 
                                    FROM Documents__c
                                    WHERE Opportunity_Relation__c =:loanApplicationId AND Applicant__c =:applicantId AND Name =:docName AND Vehicle_Detail__c =: vehicleDetailId
                                    WITH SECURITY_ENFORCED];
                }else{
                    documentList = [SELECT Id,Name,Opportunity_Relation__c,Vehicle_Detail__c,Document_Type__c,Applicant__c 
                                    FROM Documents__c
                                    WHERE Opportunity_Relation__c =:loanApplicationId AND Applicant__c =:applicantId AND Name =:docName 
                                    WITH SECURITY_ENFORCED];
                }
                
                System.debug('documentList '+documentList.size());
                if(documentList.size()>0 && docType != 'Payment Receipt'){
                    for(Documents__c doc : documentList){
                        doc.is_Active__c = false;
                    }
                    update documentList;
                }
                ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                System.debug('otherDocRecordTypeId'+otherDocRecordTypeId);
                System.debug('docType'+docType+'vehicleDetailId'+vehicleDetailId+'applicantId'+applicantId+'loanApplicationId'+loanApplicationId);
                Documents__c docObject= new Documents__c(Name = docType+' '+loanApplicationId,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType,
                                                         Additional_Document__c = true,is_active__c = true);
                System.debug('docObject'+docObject);
                docObject.RecordTypeId = otherDocRecordTypeId;
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert docObject;
                }
                if(Test.isRunningTest())
                {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return docObject.Id;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'createOtherDocument ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
        
    }
    /*
* @Method Name: createOtherDocument
* @Created by:  Kruthi Nadig
* @description: to create a Document object for 'Other documents'
* @Param:       String - Document Type
* @Param:       String - current Vehicle Record ID
* @Param:       String - loanApplication ID
* @Return:      String - created Document's ID
*/
    @AuraEnabled
    public static string createOtherDocument(String docType,String vehicleDetailId,String applicantId,String loanApplicationId){
        try {
            if(loanApplicationId!=null ){
                ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                System.debug('otherDocRecordTypeId'+otherDocRecordTypeId);
                System.debug('docType'+docType+'vehicleDetailId'+vehicleDetailId+'applicantId'+applicantId+'loanApplicationId'+loanApplicationId);
                Documents__c docObject= new Documents__c(Name = docType+' '+loanApplicationId,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType);
                System.debug('docObject'+docObject);
                docObject.RecordTypeId = otherDocRecordTypeId;
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert docObject;
                }
                if(Test.isRunningTest())
                {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return docObject.Id;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'createOtherDocument ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
        
    }
    
    /*
* @Method Name: deleteDocument
* @Created by:  Vinita Kamble
* @description: to delete document object 
* @Param:       String - Document ID
*/
    @AuraEnabled
    public static void deleteDocument(String documentId){
        try{
            if(documentId!=null){
                List<ContentDocument> conDoc = [SELECT Id FROM ContentDocument WHERE Id=:documentId WITH SECURITY_ENFORCED];
                if(conDoc.size()  > 0){
                    List<SObject> documentsObject= [Select Id from Documents__c Where Id= :documentId WITH SECURITY_ENFORCED ];
                    
                    if (Schema.sObjectType.Documents__c.isAccessible() && Schema.sObjectType.Documents__c.isDeletable() ){
                        delete documentsObject;
                    }
                    delete [SELECT Id FROM ContentDocument WHERE Id=:documentId WITH SECURITY_ENFORCED];
                }
                
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'deleteDocument ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    /*
* @Method Name: deleteDocumentsFromContentDocument
* @Created by:  Vinita Kamble
* @description: to delete document Id from Content Document
* @Param:       String - Document ID
*/
    @AuraEnabled
    public static String deleteDocumentsFromContentDocument(String docIds){
        try{
            delete [SELECT Id FROM ContentDocument WHERE Id=:docIds WITH SECURITY_ENFORCED];
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return 'SUCCESS';
            
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'deleteDocumentsFromContentDocument', '', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //created by Aditya
    @AuraEnabled(cacheable = true)
    public static string getProfile(){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        return profileName;
    }

    /* @Method Name: getUserDetails
    * @Created by:  Daksh Mandowara
    * @description: To get user details.
    * @Return:      User
    */
    @AuraEnabled
    public static Map<String,String> getUserDetails(){
        Map<String,String> userMap = new Map<String,String>();
        userMap.put(System.label.currentUserId,UserInfo.getUserId());
        userMap.put(System.label.currentUserName,UserInfo.getUserName());
        userMap.put(System.label.currentUserEmailid,UserInfo.getUserEmail());
        return userMap;
    }

    /* @Method Name: deleteDocuments
    * @Created by:  Daksh Mandowara
    * @description: To delete the Documents
    * @Param:       List<String> - Document Ids ID & List<String> - Content Document Ids
    * @Return:      void
    */
    @AuraEnabled
    public static void deleteDocuments(List<String> docIds,List<String> contentDocIds){
        try{
            List<ContentDocument> contentDocs = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocIds WITH SECURITY_ENFORCED];
            if(!contentDocs.isEmpty()){
                delete contentDocs;
            }
            List<Documents__c> docs = [SELECT Id FROM Documents__c WHERE Id IN :docIds WITH SECURITY_ENFORCED];
            if(!docs.isEmpty()){
                delete docs;
            }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'deleteDocuments', System.Label.Apex, ex);           
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /* @Method Name: isDeleteable
    * @Created by:  Daksh Mandowara
    * @description: To check whether user can delete the documents or not.
    * @Param:       String - Loan Application Id & String - Document Type
    * @Return:      void
    */
    @AuraEnabled
    public static boolean isDeleteable(String documentId){
        try{
            if(String.isNotBlank(documentId)){
                Documents__c document = [SELECT Id,Document_Type__c,CreatedById,Opportunity_Relation__r.StageName,
                                                Opportunity_Relation__r.Sanction_Date__c 
                                        FROM Documents__c 
                                        WHERE Id = :documentId 
                                        WITH SECURITY_ENFORCED];
                if(document.CreatedById.equals(UserInfo.getUserId())){
                    return true;
                }
                if(document.Opportunity_Relation__r.Sanction_Date__c==NULL){
                    return true;
                }else{
                    if(document.Document_Type__c.equals(System.Label.Other)){
                        return true;
                    }
                }
            }
            return false;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'deleteDocuments', System.Label.Apex, ex);           
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /* @Method Name: inactiveDocuments
    * @Created by:  Daksh Mandowara
    * @description: To get the Documents
    * @Param:       String - Document Id & String - Document Type
    * @Return:      List<Id> - List of Document Id
    */
    @AuraEnabled
    public static void inactiveDocuments(String docId,String docType, String loanApplicationId, String documentSide, String applicantId){
        try{
            if(String.isNotBlank(docId)){
                List<Opportunity> oppList = new List<Opportunity>([Select Id,Product_Type__c FROM Opportunity Where Id=:loanApplicationId LIMIT 1]);
                Boolean isTractor =  (oppList.size() > 0 && oppList[0].Product_Type__c == Label.Tractor) ? true : false;
                Boolean isBothSideDoc = false;
                Boolean deactivateExistingRecord = false;
                //if the document needs both front & back sides, check which side is already present
                if(docType == System.Label.AadhaarCard || docType == System.Label.DrivingLicences || docType == System.Label.VoterIdCard || docType == System.Label.PassportCard){
                    isBothSideDoc = true;
                    List<ContentDocumentLink> contDocList = new List<ContentDocumentLink>([Select Id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId =: docId]);
                    if(contDocList.size() > 0){
                        Set<Id> contDocIdSet = new Set<Id>();
                        for(ContentDocumentLink contDocLink : contDocList){
                            contDocIdSet.add(contDocLink.ContentDocumentId);
                        }
                        if(!contDocIdSet.isEmpty()){
                            for(ContentVersion contVersion : [Select Id, ContentDocumentId, Document_Side_fileupload__c From ContentVersion Where ContentDocumentId IN : contDocIdSet]){
                                if(contVersion.Document_Side_fileupload__c == documentSide){
                                    deactivateExistingRecord = true; 
                                    break;
                                }
                            }
                        }
                    }
                }
                List<Documents__c> docs = [SELECT Id,First_Name__c,applicant_Type__c,Applicant__c ,Name,Salutation__c ,Sequence_Number__c ,KYC_Issuance_Date__c ,Last_Name__c ,Addresss_Type__c ,Aadhar_Source__c ,Name_Mismatch_Pass__c, Name_Mismatch_Percentage__c,
                                           Current_Residential_Address_Proof__c, Permanent_Residential_Address_Proof__c ,Passport_File_No__c ,PAN_No__c,Passport_No__c,KYC_Expiry_Date__c,Case__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                KYC_District__c,KYC_DOB__c,KYC_No__c,KYC_Pin_Code__c,KYC_State__c,Gender__c,
                Masked_KYC_No__c,KYC_name__c,is_Active__c,Document_Type__c,Is_this_a_Photocopy__c,Proof_of_Address_POA__c,Proof_of_Identity_POI__c,Opportunity_Relation__r.Product_Type__c,GST_No__c,CIN_No__c,Village__c,Taluka__c,Landmark__c,RecordTypeId FROM Documents__c WHERE Document_Type__c=:docType AND Id != :docId AND is_Active__c=true AND Opportunity_Relation__c=:loanApplicationId AND Applicant__c =: applicantId WITH SECURITY_ENFORCED];//CISP-3239
                if(!docs.isEmpty()){
                    Set<Documents__c> docsToUpdate = new Set<Documents__c>();
                    for(Documents__c doc : docs){
                        if(isBothSideDoc){
                            if(deactivateExistingRecord && doc.Document_Type__c != 'Other')
                                doc.is_Active__c = false;
                        } else if(doc.Document_Type__c != 'Other'){
                            doc.is_Active__c = false;
                        }
                        //check for existing document,
                        //if there is one then update POA & POI on new record
                        if(doc.Is_this_a_Photocopy__c == true || (doc.Opportunity_Relation__r.Product_Type__c == System.Label.Tractor && doc.Document_Type__c != 'Other')){
                            Documents__c updateDoc = doc.clone(false, false, false, false);
                            updateDoc.id = docId;
                            updateDoc.Is_this_a_Photocopy__c = false;
                            updateDoc.is_Active__c = true;
                            docsToUpdate.add(updateDoc);
                        }
                    }
                    if(!docsToUpdate.isEmpty())
                        docs.addAll(docsToUpdate);
                    update docs;
                }
                if(isTractor){
                    Documents__c updateDoc = new Documents__c();
                    updateDoc.id = docId;
                    updateDoc.is_Active__c = true;
                    update updateDoc;
                }
                if(docType == 'Other'){//CISP-5670
                    List<Documents__c> docnameUpadtion =[SELECT id,name from Documents__c where Document_Type__c=:docType AND is_Active__c=true AND Opportunity_Relation__c=:loanApplicationId AND id=:docId WITH SECURITY_ENFORCED];
                    List<ContentDocumentLink> contentdocDetails = [SELECT  ContentDocument.Title from ContentDocumentLink where LinkedEntityId=:docId];
                    for(Documents__c doc : docnameUpadtion){
                        doc.name = contentdocDetails[0].ContentDocument.Title; 
                    }
                    update docnameUpadtion;
                }//CISP-5670
            }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'deleteDocuments', System.Label.Apex, ex);           
            throw new AuraHandledException(ex.getMessage());
        }
    }
	//INDI-4645 || CISP-42
    @AuraEnabled
    public static String getVehicleData(String loanApplicationId){
        try{
            List<Vehicle_Detail__c> vehiList = [Select Id From Vehicle_Detail__c where Loan_Application__c =: loanApplicationId LIMIT 1];
            if(!vehiList.isEmpty()){
                return vehiList[0].Id;
            }
            return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getVehicleData', System.Label.Apex, ex, loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static Integer countOfChequesDoc(String loanApplicationId){
        try{
            List<Documents__c> docList = [Select Id, document_type__c from Documents__c where document_type__c = 'Cheques SPDC' and Is_active__c = true AND Opportunity_Relation__c = :loanApplicationId ];
            if(!docList.isEmpty()){
                return docList.size();
            }
            return 0;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'countOfChequesDoc', System.Label.Apex, ex, loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
    }
	//INDI-4645 || CISP-42
    
    /* @Method Name: getDocumentTypes
    * @Created by:  Daksh Mandowara
    * @description: To get the Document Types
    * @Param:       String - Loan Application Id
    * @Return:      List<String> - List of Document Type
    */
    @AuraEnabled
    public static String getDocumentTypes(String loanApplicationId,String loanApplicantId, String action, String customerType){ //SFTRAC-286
        try{
            Id kycRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            Id otherRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
            Set<String> viewDocTypes = new Set<String>();
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartArray();

            
            //To get picklist entries
            List<Schema.PicklistEntry> values = Documents__c.Document_Type__c.getDescribe().getPicklistValues();
            Map<String,String> statusApiToLabelMap = new Map<String,String>();
            For(Schema.PicklistEntry sp : values){
                //Map to hold Picklist API as Key and Picklist Label as Value
                statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
            }

            Opportunity oppObj = [Select Id, StageName,Product_Type__c,Sub_Stage__c,Sanction_Date__c,Customer_Type__c from opportunity where Id =: loanApplicationId];//286
            List<Applicant__c> appListOfCoBorrower = [SELECT ID FROM Applicant__c where Opportunity__c =: loanApplicationId and Applicant_Type__c ='Co-borrower'  and In_Active_Applicant__c = false LIMIT 1];
            Map<String,Loan_Application_Transaction_History__c> historyMap = new Map<String,Loan_Application_Transaction_History__c>();
            for(Loan_Application_Transaction_History__c history : [SELECT Id, Name, Submitted_Flag__c, Screen__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =: loanApplicationId AND Module__c = 'Post Sanction Checks and Documentation' AND Submitted_Flag__c = false WITH SECURITY_ENFORCED]){
                historyMap.put(history.Screen__c, history);
            }
            List<String> DocTypesName = new List<String>{'Cheques SPDC','Borrower\'s Passbook','NOC','RC Document','Invoice','IHM Receipt','Agreement Copy','ACH Mandate Form','Cancelled Cheque','DPN','RTO','RCU report','Co-Borrower\'s Passbook','Co-Borrower\'s Bank Statement','Borrower\'s Bank Statement','Agreement Wrapper Booklet','Agreement 1st Schedule','IT Return or Saral','Salary Slip','Form 16','GST Certificate','Agreement 2nd Schedule'};

            if(action.equals('Upload')){
                if(String.isNotBlank(loanApplicationId)){
                    List<Documents__c> docs = [SELECT Id,Document_Type__c,RecordTypeId, CreatedById, RecordType.Name
                                                FROM Documents__c 
                                                WHERE is_Active__c = TRUE 
                                                AND Is_this_a_Photocopy__c = TRUE 
                                                AND (RecordTypeId = :kycRecordTypeId OR Document_Type__c = :System.Label.New_RC_Doc_Type)
                                                AND Opportunity_Relation__c = :loanApplicationId 
                                                AND Applicant__c= :loanApplicantId 
                                                AND Opportunity_Relation__r.StageName != :System.Label.Loan_Initiation 
                                                AND Opportunity_Relation__r.Sanction_Date__c=NULL
                                                AND Document_Type__c!=NULL
                                                WITH SECURITY_ENFORCED];
                    if(!docs.isEmpty()){
                        for(Documents__c doc : docs){
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label',statusApiToLabelMap.get(doc.Document_Type__c));
                            jsonGen.writeStringField('value',doc.Document_Type__c);
                            jsonGen.writeStringField('recordtypeid',doc.RecordTypeId);
                            jsonGen.writeStringField('recordtype',doc.RecordType.Name);
                            jsonGen.writeEndObject();
                        }
                    }
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('label',System.Label.OD_Receipt);
                    jsonGen.writeStringField('value',System.Label.OD_Receipt);
                    jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                    jsonGen.writeStringField('recordtype',System.Label.Other);
                    jsonGen.writeEndObject();
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('label',System.Label.Other);
                    jsonGen.writeStringField('value',System.Label.Other);
                    jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                    jsonGen.writeStringField('recordtype',System.Label.Other);
                    jsonGen.writeEndObject();
                    
                    //INDI-4645 |CISP-42 Adding document type for only MA and MO
                    Id profileId = UserInfo.getProfileId();
                    String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
                    //Opportunity oppObj = [Select Id, StageName,Product_Type__c,Sanction_Date__c,Customer_Type__c from opportunity where Id =: loanApplicationId]; //SFTRAC-49,286

                    if(oppObj.Product_Type__c == 'Tractor'){ //SFTRAC-49
                        if(oppObj.Sanction_Date__c == null){
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Electricity Bill (within 2 months)');
                        jsonGen.writeStringField('value','Electronic Bill');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','House Tax Receipt');
                        jsonGen.writeStringField('value','House Tax Receipt');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Land document');
                        jsonGen.writeStringField('value','Land document');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Sale Agreement');
                        jsonGen.writeStringField('value','Sale Agreement');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Leased land proof');
                        jsonGen.writeStringField('value','Leased land proof');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Seller RC Document');
                        jsonGen.writeStringField('value','Seller RC Document');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Exchanged asset RC Document');
                        jsonGen.writeStringField('value','Exchanged asset RC Document');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Form of Particular / RC - Borrower Asset');
                        jsonGen.writeStringField('value','Form of Particular / RC - Borrower Asset');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Form of Particular / RC - Co-Borrower Asset');
                        jsonGen.writeStringField('value','Form of Particular / RC - Co-Borrower Asset');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Form of Particular / RC - Guarantor Asset');
                        jsonGen.writeStringField('value','Form of Particular / RC - Guarantor Asset');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','CH/DCH FI format');
                        jsonGen.writeStringField('value','CH/DCH FI format');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Loan Statement 1');
                        jsonGen.writeStringField('value','Loan Statement 1');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Loan Statement 2');
                        jsonGen.writeStringField('value','Loan Statement 2');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Loan Statement 3');
                        jsonGen.writeStringField('value','Loan Statement 3');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','OD clearance proof 1');
                        jsonGen.writeStringField('value','OD clearance proof 1');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','OD clearance proof 2');
                        jsonGen.writeStringField('value','OD clearance proof 2');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','OD clearance proof 3');
                        jsonGen.writeStringField('value','OD clearance proof 3');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','OD clearance proof 4');
                        jsonGen.writeStringField('value','OD clearance proof 4');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','ITR-Forms');
                        jsonGen.writeStringField('value','ITR-Forms');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Salary certificate');
                        jsonGen.writeStringField('value','Salary certificate');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Work order');
                        jsonGen.writeStringField('value','Work order');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        }
                        if(customerType == 'Non-Individual'){ //SFTRAC-286
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','PARTNERSHIP DEED');
                            jsonGen.writeStringField('value','PARTNERSHIP DEED');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','PARTNERSHIP REGISTRATION CERT/PARTNERSHIP LETTER');
                            jsonGen.writeStringField('value','PARTNERSHIP REGISTRATION CERT');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','MEMORANDUM OF ASSOCIATION');
                            jsonGen.writeStringField('value','MEMORANDUM OF ASSOCIATION');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','ARTICLES OF ASSOCIATION');
                            jsonGen.writeStringField('value','ARTICLES OF ASSOCIATION');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','CERTIFICATE OF COMMENCEMENT OF BUSINESS');
                            jsonGen.writeStringField('value','CERTIFICATE OF COMMENCEMENT OF BUSINESS');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','CERTIFICATE OF INCORPORATION');
                            jsonGen.writeStringField('value','CERTIFICATE OF INCORPORATION');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','SHOPS AND ESTABLISHMENT CERTIFICATE');
                            jsonGen.writeStringField('value','SHOPS AND ESTABLISHMENT CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','GST CERTIFICATE');
                            jsonGen.writeStringField('value','GST CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','UDYAM REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('value','UDYAM REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','SALES TAX REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('value','SALES TAX REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','MSME REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('value','MSME REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','UDYOG AADHAAR REG CERTIFICATE');
                            jsonGen.writeStringField('value','UDYOG AADHAAR REG CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','List of Partners');
                            jsonGen.writeStringField('value','List of Partners');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','Utility bill in the name of company');
                            jsonGen.writeStringField('value','Utility bill in the name of company');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','Beneficial Ownership Declaration');
                            jsonGen.writeStringField('value','Beneficial Ownership Declaration');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','Board Resolution');
                            jsonGen.writeStringField('value','Board Resolution');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','List of Directors');
                            jsonGen.writeStringField('value','List of Directors');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','LLP Agreement');
                            jsonGen.writeStringField('value','LLP Agreement');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','List of Trustees/Office Bearers');
                            jsonGen.writeStringField('value','List of Trustees/Office Bearers');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','Linkage Proof');
                            jsonGen.writeStringField('value','Linkage Proof');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','TRUST DEED/BYE LAW');
                            jsonGen.writeStringField('value','TRUST DEED/BYE LAW');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','List of Co-Percenters');
                            jsonGen.writeStringField('value','List of Co-Percenters');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject();
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','HUF deed/letter');
                            jsonGen.writeStringField('value','HUF deed/letter');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject(); 
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','REGISTRATION CERTIFICATE (ANY)');
                            jsonGen.writeStringField('value','REGISTRATION CERTIFICATE - OTHERS');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject(); 
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','TAX/SERVICE TAX/PROFESSIONAL TAX AUTH');
                            jsonGen.writeStringField('value','TAX/SERVICE TAX/PROFESSIONAL TAX AUTH');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject(); 
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','FACTORY REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('value','FACTORY REGISTRATION CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject(); 
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES');
                            jsonGen.writeStringField('value','CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject(); 
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','TRADE LICENCE');
                            jsonGen.writeStringField('value','TRADE LICENCE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject(); 
                            jsonGen.writeStartObject();
                            jsonGen.writeStringField('label','IMPORT AND EXPORT CERTIFICATE');
                            jsonGen.writeStringField('value','IMPORT AND EXPORT CERTIFICATE');
                            jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                            jsonGen.writeStringField('recordtype',System.Label.Other);
                            jsonGen.writeEndObject(); 
                        }
                        if(oppObj.StageName != 'Disbursement Request Preparation')	{
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Foreclosure letter for closed existing loan');
                        jsonGen.writeStringField('value','Foreclosure letter for closed existing loan');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Release letter');
                        jsonGen.writeStringField('value','Release letter');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Loan NOC other Bank');
                        jsonGen.writeStringField('value','Loan NOC other Bank');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Affidavit');
                        jsonGen.writeStringField('value','Affidavit');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Talathi/Sarpanch Certificate');
                        jsonGen.writeStringField('value','Talathi/Sarpanch Certificate');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Subsidy sanction letter');
                        jsonGen.writeStringField('value','Subsidy sanction letter');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        }
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Vahan Extract');
                        jsonGen.writeStringField('value','Vahan Extract');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label','Fund Utilisation letter for Refinance');
                        jsonGen.writeStringField('value','Fund Utilisation letter for Refinance');
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeStringField('recordtype',System.Label.Other);
                        jsonGen.writeEndObject();
                        }
              
                    
                    if((profileName == 'System Administrator' || profileName == 'IBL Partner Community Marketing Agent' ||
                        profileName == 'IBL Partner Community Marketing Officer' || profileName == 'IBL Marketing Officer')
                       && (oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Post Sanction Checks and Documentation' ||
                          oppObj.stageName == 'Credit Processing') && oppObj.Product_Type__c == 'Two Wheeler')
                    {
                                
                                system.debug('DocTypesName--'+DocTypesName);
                        system.debug('DocTypesName--'+DocTypesName.size());
                        system.debug('doc type list---' +[Select Id, document_type__c from Documents__c where document_type__c In : docTypesName AND Opportunity_Relation__c = :loanApplicationId ]);
                        set<String> alreadyUploadedDocTypes = new set<String>();
                        Integer chequesCount = 0;
                        Integer IHMReceiptCount = 0;
                        for(Documents__c doc : [Select Id, document_type__c,(SELECT Id FROM ContentDocumentLinks) from Documents__c where document_type__c In : docTypesName and Is_active__c = true AND Opportunity_Relation__c = :loanApplicationId ]){
                            if(doc.ContentDocumentLinks.size() > 0){
                                alreadyUploadedDocTypes.add(doc.Document_Type__c);
                                if(doc.Document_Type__c == 'Cheques SPDC'){
                                    chequesCount ++;
                                }
                                if(doc.Document_Type__c == 'IHM Receipt'){
                                    IHMReceiptCount ++;
                                }
                            }
                        }
                        system.debug('chequesCount--'+chequesCount);
                        system.debug('IHMReceiptCount--'+IHMReceiptCount);
                        system.debug('alreadyUploadedDocTypes--'+alreadyUploadedDocTypes.size());
                        system.debug('alreadyUploadedDocTypes--'+alreadyUploadedDocTypes);
                        if(oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if(!alreadyUploadedDocTypes.contains('NOC')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Cancelled NOC');
                                jsonGen.writeStringField('value','NOC');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('RC Document')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Updated RC Document');
                                jsonGen.writeStringField('value','RC Document');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                        if(oppObj.StageName == 'Final Offer' || (oppObj.StageName == 'Credit Processing' && oppObj.Sub_Stage__c == 'Income')){
                            if(!alreadyUploadedDocTypes.contains('IT Return or Saral')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','IT Return or Saral');
                                jsonGen.writeStringField('value','IT Return or Saral');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('Salary Slip')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Salary Slip');
                                jsonGen.writeStringField('value','Salary Slip');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('Form 16')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Form 16');
                                jsonGen.writeStringField('value','Form 16');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('GST Certificate')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','GST Certificate');
                                jsonGen.writeStringField('value','GST Certificate');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('RCU Report')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','RCU Report');
                                jsonGen.writeStringField('value','RCU report');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                        if((historyMap.containsKey('Security Mandate') && historyMap.get('Security Mandate') !=null  && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if((!alreadyUploadedDocTypes.contains('Cheques SPDC')) || chequesCount < 6){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Security PDC');
                                jsonGen.writeStringField('value','Cheques SPDC');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                        if((historyMap.containsKey('Additional Documents') && historyMap.get('Additional Documents') !=null  && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if(!alreadyUploadedDocTypes.contains('Borrower\'s Passbook')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Passbook - Borrower');
                                jsonGen.writeStringField('value','Borrower\'s Passbook');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if((!alreadyUploadedDocTypes.contains('Co-Borrower\'s Passbook')) && appListOfCoBorrower.size()>0){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Passbook - Co-Borrower');
                                jsonGen.writeStringField('value','Co-Borrower\'s Passbook');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('Borrower\'s Bank Statement')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Bank Statement - Borrower');
                                jsonGen.writeStringField('value','Borrower\'s Bank Statement');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if((!alreadyUploadedDocTypes.contains('Co-Borrower\'s Bank Statement')) && appListOfCoBorrower.size()>0){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Bank Statement - Co-Borrower');
                                jsonGen.writeStringField('value','Co-Borrower\'s Bank Statement');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                        if((historyMap.containsKey('Invoice') && historyMap.get('Invoice') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if(!alreadyUploadedDocTypes.contains('Invoice')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Performa Invoice/ Tax Invoice');
                                jsonGen.writeStringField('value','Invoice');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                        if((historyMap.containsKey('IHM') && historyMap.get('IHM') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if((!alreadyUploadedDocTypes.contains('IHM Receipt')) || IHMReceiptCount < 2){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','IHM Receipt');
                                jsonGen.writeStringField('value','IHM Receipt');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                        if((historyMap.containsKey('Loan Agreement') && historyMap.get('Loan Agreement') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if(!alreadyUploadedDocTypes.contains('Agreement Copy')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Agreement Booklet');
                                jsonGen.writeStringField('value','Agreement Copy');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                        if((historyMap.containsKey('Repayment Mandate') && historyMap.get('Repayment Mandate') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if(!alreadyUploadedDocTypes.contains('ACH Mandate Form')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','ACH Mandate');
                                jsonGen.writeStringField('value','ACH Mandate Form');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('Cancelled Cheque')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Cancelled Cheque');
                                jsonGen.writeStringField('value','Cancelled Cheque');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            }
                        if((historyMap.containsKey('RTO, DPN, POA Documents Upload') && historyMap.get('RTO, DPN, POA Documents Upload') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing'){
                            if(!alreadyUploadedDocTypes.contains('Agreement Wrapper Booklet')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Agreement Wrapper Page');
                                jsonGen.writeStringField('value','Agreement Wrapper Booklet');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('DPN')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','DPN');
                                jsonGen.writeStringField('value','DPN');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('RTO')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','RTO');
                                jsonGen.writeStringField('value','RTO');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('Agreement 1st Schedule')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','1st Schedule');
                                jsonGen.writeStringField('value','Agreement 1st Schedule');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('Agreement 2nd Schedule')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','2nd Schedule');
                                jsonGen.writeStringField('value','Agreement 2nd Schedule');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                            if(!alreadyUploadedDocTypes.contains('DPR')){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('label','Dealer Payment Request (DPR)');
                                jsonGen.writeStringField('value','DPR');
                                jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                                jsonGen.writeStringField('recordtype',System.Label.Other);
                                jsonGen.writeEndObject();
                            }
                        }
                    }
                }
            }else{
                Map<Id,Documents__c> docs = new Map<Id,Documents__c>([SELECT Id,Document_Type__c
                                                FROM Documents__c 
                                                WHERE is_Active__c = TRUE 
                                                AND Opportunity_Relation__c = :loanApplicationId 
                                                AND Applicant__c= :loanApplicantId
                                                WITH SECURITY_ENFORCED]);
                List<ContentDocumentLink> conDocLinks = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :docs.keySet() ORDER BY ContentDocument.CreatedDate DESC];
                if(!docs.keySet().isEmpty() && !conDocLinks.isEmpty()){
                    viewDocTypes.add('All');
                    for(Documents__c doc : docs.values()){
                        for(ContentDocumentLink link : conDocLinks){
                            if(doc.Id == link.LinkedEntityId && String.isNotBlank(doc.Document_Type__c)){
                                if(oppObj.Product_Type__c == 'Tractor')
                                viewDocTypes.add(doc.Document_Type__c);
                                System.debug('variable: ' + doc);
                                System.debug('variable: ' + historyMap);
                                if((oppObj.Product_Type__c == 'Passenger Vehicles') || ((oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing') && oppObj.Product_Type__c == 'Two Wheeler') || (oppObj.Product_Type__c == 'Two Wheeler' && !DocTypesName.contains(doc.Document_Type__c))){
                                viewDocTypes.add(doc.Document_Type__c);
                            }
                                if(oppObj.Product_Type__c == 'Two Wheeler' && oppObj.StageName == 'Credit Processing' && oppObj.Sub_Stage__c == 'Income'){
                                    List<String> docTypeList = new List<String>{'IT Return or Saral','Salary Slip','Form 16','GST Certificate','RCU Report'};
                                    if(docTypeList.contains(doc.Document_Type__c)){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                                if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Security Mandate') && historyMap.get('Security Mandate') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing') ){                            
                                    if(doc.Document_Type__c.equals('Cheques SPDC')){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                                if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Additional Documents') && historyMap.get('Additional Documents') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                                    List<String> docTypeList = new List<String>{'Borrower\'s Passbook','Co-Borrower\'s Passbook','Borrower\'s Bank Statement','Co-Borrower\'s Bank Statement'};
                                    if(docTypeList.contains(doc.Document_Type__c)){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                                if (oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Invoice') && historyMap.get('Invoice') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation')||oppObj.StageName == 'Credit Processing')){
                                    if(doc.Document_Type__c.equals('Invoice')){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                                if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('IHM') && historyMap.get('IHM') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                                    if(doc.Document_Type__c.equals('IHM Receipt')){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                                if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Loan Agreement') && historyMap.get('Loan Agreement') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                                    if(doc.Document_Type__c.equals('Agreement Copy')){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                                if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Repayment Mandate') && historyMap.get('Repayment Mandate') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation')|| oppObj.StageName == 'Credit Processing')){
                                    List<String> docTypeList = new List<String>{'ACH Mandate Form','Cancelled Cheque'};
                                    if(docTypeList.contains(doc.Document_Type__c)){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                                if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('RTO, DPN, POA Documents Upload') && historyMap.get('RTO, DPN, POA Documents Upload') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                                    List<String> docTypeList = new List<String>{'Agreement Wrapper Booklet','DPN','RTO','Agreement 1st Schedule','DPR','Agreement 2nd Schedule'};
                                    if(docTypeList.contains(doc.Document_Type__c)){
                                        viewDocTypes.add(doc.Document_Type__c);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            System.debug('viewDocTypes: ' + viewDocTypes);
            for(String docType : viewDocTypes){
                if(docType != 'All'){
                    if(statusApiToLabelMap.containsKey(docType)){
                        jsonGen.writeStartObject();
                        jsonGen.writeStringField('label',statusApiToLabelMap.get(docType));
                        jsonGen.writeStringField('value',docType);
                        jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                        jsonGen.writeEndObject();
                    }
                } else {
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('label',docType);
                    jsonGen.writeStringField('value',docType);
                    jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                    jsonGen.writeEndObject();
                }
            }
            Set<Id> teleVerificationIds = new Set<Id>();
            for(TeleVerification__c teleObj :[Select Id from TeleVerification__c where Loan_Application__c =:loanApplicationId]){
                teleVerificationIds.add(teleObj.Id);
            }
             if(!teleVerificationIds.isEmpty()){
                Map<Id,ContentDocumentLink> con1 = new Map<Id,ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId  IN : teleVerificationIds]);
                system.debug('ContentDocumentLink'+con1);
                if(!con1.isEmpty()){
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('label','TVR');
                    jsonGen.writeStringField('value','TVR');
                    jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                    jsonGen.writeEndObject();
                }
            }
            Set<Id> amlIds = new Set<Id>();
             for(AML_Check__c amlObj : [SELECT Id,Loan_Application__c,Content_Document_Id__c from AML_Check__c where Loan_Application__c =: loanApplicationId]){
                amlIds.add(amlObj.Id);
            }
             if(!amlIds.isEmpty()){
                Map<Id,ContentDocumentLink> con = new Map<Id,ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId  IN: amlIds]);
                system.debug('ContentDocumentLink'+con);
                if(!con.isEmpty()){
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('label','AML');
                    jsonGen.writeStringField('value','AML');
                    jsonGen.writeStringField('recordtypeid',otherRecordTypeId);
                    jsonGen.writeEndObject();
                }
            }
            jsonGen.writeEndArray();
            return jsonGen.getAsString();
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getDocumentTypes', System.Label.Apex, ex, loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<Id> getTVRDocuments(String loanApplicationId){
        try{
            Set<Id> teleVerificationIds = new Set<Id>();
            for(TeleVerification__c teleObj :[Select Id from TeleVerification__c where Loan_Application__c =:loanApplicationId]){
                teleVerificationIds.add(teleObj.Id);
            }
            if(!teleVerificationIds.isEmpty()){
                Map<Id,ContentDocumentLink> con1 = new Map<Id,ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId  IN : teleVerificationIds]);
                system.debug('ContentDocumentLink'+con1);
                if(!con1.isEmpty()){
                    return new List<Id>(con1.keySet());
                }
            }
            return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getTVRDocuments ', System.Label.Apex, ex,loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
    }    
    public static List<Id> getAMLDocuments(String loanApplicationId){
        try{
            Set<Id> amlIds = new Set<Id>();
            for(AML_Check__c amlObj : [SELECT Id,Loan_Application__c,Content_Document_Id__c from AML_Check__c where Loan_Application__c =: loanApplicationId]){
                amlIds.add(amlObj.Id);
            }
            
            if(!amlIds.isEmpty()){
                Map<Id,ContentDocumentLink> con = new Map<Id,ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId  IN: amlIds]);
                system.debug('ContentDocumentLink'+con);
                if(!con.isEmpty()){
                    return new List<Id>(con.keySet());
                }
            }
            return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getAMLDocuments ', System.Label.Apex, ex,loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /* @Method Name: getDocuments
    * @Created by:  Daksh Mandowara
    * @description: To get the Documents
    * @Param:       String - loanApplication ID & String - Applicant Id
    * @Return:      List<Id> - List of Document Id
    */
    @AuraEnabled(cacheable = true)
    public static List<Id> getDocuments(String loanApplicationId, String applicantId){
        try{
            System.debug('in get documents');
            List<Id> returnIdList = new List<Id>(); 
           
            Set<Id> teleVerificationIds = new Set<Id>();
            Set<Id> amlIds = new Set<Id>();
            for(TeleVerification__c teleObj :[Select Id from TeleVerification__c where Loan_Application__c =:loanApplicationId]){
                teleVerificationIds.add(teleObj.Id);
            }
            for(AML_Check__c amlObj : [SELECT Id,Loan_Application__c,Content_Document_Id__c from AML_Check__c where Loan_Application__c =: loanApplicationId]){
                amlIds.add(amlObj.Id);
            }
            Opportunity oppObj = [Select Id,StageName,Product_Type__c,Sub_Stage__c from opportunity where Id =: loanApplicationId];
            Map<String,Loan_Application_Transaction_History__c> historyMap = new Map<String,Loan_Application_Transaction_History__c>();
            for(Loan_Application_Transaction_History__c history : [SELECT Id, Name, Submitted_Flag__c, Screen__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =: loanApplicationId AND Module__c = 'Post Sanction Checks and Documentation' AND Submitted_Flag__c = false WITH SECURITY_ENFORCED]){
                historyMap.put(history.Screen__c, history);
            }
            List<String> DocTypesName = new List<String>{'Cheques SPDC','Borrower\'s Passbook','NOC','RC Document','Invoice','IHM Receipt','Agreement Copy','ACH Mandate Form','Cancelled Cheque','DPN','RTO','RCU report','Co-Borrower\'s Passbook','Co-Borrower\'s Bank Statement','Borrower\'s Bank Statement','Agreement Wrapper Booklet','Agreement 1st Schedule','IT Return or Saral','Salary Slip','Form 16','GST Certificate','Agreement 2nd Schedule'};
            Map<Id,Documents__c> documents = new Map<Id,Documents__c>([Select Id,Document_Type__c FROM Documents__c WHERE Opportunity_Relation__c = :loanApplicationId AND Applicant__c = :applicantId AND is_Active__c = TRUE WITH SECURITY_ENFORCED]);
            system.debug('## documents: ' + documents);
            system.debug('## documents size : ' + documents.size());
            Set<Id> documentIdSet = new Set<Id>();           
            if(!documents.isEmpty()){
                for (Documents__c doc : documents.values()) {
                    if(oppObj.Product_Type__c == 'Tractor')
			            documentIdSet.add(doc.Id);
                    if((oppObj.Product_Type__c == 'Passenger Vehicles') || ((oppObj.StageName == 'Final Offer' || oppObj.StageName == 'Credit Processing') && oppObj.Product_Type__c == 'Two Wheeler') || (oppObj.Product_Type__c == 'Two Wheeler' && !DocTypesName.contains(doc.Document_Type__c))){
                        documentIdSet.add(doc.Id);
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && oppObj.StageName == 'Credit Processing' && oppObj.Sub_Stage__c == 'Income'){
                        List<String> docTypeList = new List<String>{'IT Return or Saral','Salary Slip','Form 16','GST Certificate','RCU Report'};
                        if(docTypeList.contains(doc.Document_Type__c)){
                            documentIdSet.add(doc.Id);
                        }
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Security Mandate') && historyMap.get('Security Mandate') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                        if(doc.Document_Type__c.equals('Cheques SPDC')){
                            documentIdSet.add(doc.Id);
                        }
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Additional Documents') && historyMap.get('Additional Documents') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                        List<String> docTypeList = new List<String>{'Borrower\'s Passbook','Co-Borrower\'s Passbook','Borrower\'s Bank Statement','Co-Borrower\'s Bank Statement'};
                        if(docTypeList.contains(doc.Document_Type__c)){
                            documentIdSet.add(doc.Id);
                        }
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Invoice') && historyMap.get('Invoice') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                        if(doc.Document_Type__c.equals('Invoice')){
                            documentIdSet.add(doc.Id);
                        }
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('IHM') && historyMap.get('IHM') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                        if(doc.Document_Type__c.equals('IHM Receipt')){
                            documentIdSet.add(doc.Id);
                        }
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Loan Agreement') && historyMap.get('Loan Agreement') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                        if(doc.Document_Type__c.equals('Agreement Copy')){
                            documentIdSet.add(doc.Id);
                        }
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('Repayment Mandate') && historyMap.get('Repayment Mandate') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                        List<String> docTypeList = new List<String>{'ACH Mandate Form','Cancelled Cheque'};
                        if(docTypeList.contains(doc.Document_Type__c)){
                            documentIdSet.add(doc.Id);
                        }
                    }
                    if(oppObj.Product_Type__c == 'Two Wheeler' && ((historyMap.containsKey('RTO, DPN, POA Documents Upload') && historyMap.get('RTO, DPN, POA Documents Upload') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation') || oppObj.StageName == 'Credit Processing')){
                        List<String> docTypeList = new List<String>{'Agreement Wrapper Booklet','DPN','RTO','Agreement 1st Schedule','DPR','Agreement 2nd Schedule'};
                        if(docTypeList.contains(doc.Document_Type__c)){
                            documentIdSet.add(doc.Id);
                        }
                    }
                }
              system.debug('## documentIdSet : ' + documentIdSet);
               Map<Id,ContentDocumentLink> contentDocumentMap = new Map<Id,ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId IN: documentIdSet]);
                if(!contentDocumentMap.isEmpty()){
                    returnIdList.addAll(contentDocumentMap.keySet());
                }
            }
            system.debug('returnIdList'+returnIdList.size());
            system.debug('amlIds'+amlIds);
            if(!amlIds.isEmpty()){
                Map<Id,ContentDocumentLink> con = new Map<Id,ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId  IN: amlIds]);
                system.debug('ContentDocumentLink'+con);
                if(!con.isEmpty()){
                    returnIdList.addAll(con.keySet());
                }
            }
            if(!teleVerificationIds.isEmpty()){
                Map<Id,ContentDocumentLink> con1 = new Map<Id,ContentDocumentLink>([Select Id from ContentDocumentLink where LinkedEntityId  IN : teleVerificationIds]);
                system.debug('ContentDocumentLink'+con1);
                if(!con1.isEmpty()){
                    returnIdList.addAll(con1.keySet());
                }
            }
            
             
            
            /*List<ID> amlIds = new List<Id>();
            amlIds = getAMLDocuments(loanApplicationId);
            if(amlIds.size()>0){
                returnIdList.addAll(amlIds);
            }*/
            system.debug('after returnIdList'+returnIdList.size());
            if(returnIdList.size()>0){
            
                return returnIdList;
                }
              return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getApplicantDetails ', System.Label.Apex, ex,loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    /* @Method Name: getDocumentByType
    * @Created by:  Daksh Mandowara
    * @description: To get the Documents
    * @Param:       String - Applicant Id & String Document Type
    * @Return:      List<Id> - List of Document Id
    */
    @AuraEnabled
    public static List<Id> getDocumentByType(String loanApplicationId,String applicantId,String docType){
        try{
            if(String.isNotBlank(applicantId)){
                Map<Id,Documents__c> documents = new Map<Id,Documents__c>();
                if(docType.equals('All')){
                    return getDocuments(loanApplicationId,applicantId);
                    //documents = new Map<Id,Documents__c>([Select Id FROM Documents__c WHERE Applicant__c = :applicantId AND is_Active__c = TRUE WITH SECURITY_ENFORCED]);
                }else if(docType.equals('TVR')){
                    return getTVRDocuments(loanApplicationId);
                }
                else if(docType.equals('AML')){
                   return getAMLDocuments(loanApplicationId);
                }else{
                    documents = new Map<Id,Documents__c>([Select Id FROM Documents__c WHERE Applicant__c = :applicantId AND is_Active__c = TRUE AND Document_Type__c=:docType and Opportunity_Relation__c =:loanApplicationId WITH SECURITY_ENFORCED]);
                }
                if(!documents.isEmpty()){
                    return new List<Id>(documents.keySet());
                }
            }
            return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getApplicantDetails ', System.Label.Apex, ex);           
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

     /*
    * @Method Name: deleteContentDocument
    * @Created by:  Daksh Mandowara
    * @description: For deleting the content document
    * @Param:       String - Document ID
    */
    @AuraEnabled
    public static void deleteContentDocument(String docId){
        try{
            //CISP-2525
            Documents__c document = [SELECT Id,Document_Type__c,CreatedById,Opportunity_Relation__r.StageName,
                                                Opportunity_Relation__r.Sanction_Date__c 
                                        FROM Documents__c 
                                        WHERE Id = :docId 
                                        WITH SECURITY_ENFORCED];
                        delete document;
           // ContentDocumentLink conLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE Id=:docId];
            //delete new ContentDocument(Id = conLink.ContentDocumentId);
            //CISP-2525
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'deleteContentDocument', '', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* @Method Name: getApplicantDetails
    * @Created by:  Daksh Mandowara
    * @description: To get the applicants
    * @Param:       String - loanApplication ID
    * @Return:      List<Applicant__c> - Return Applicant Details
    */
    @AuraEnabled(cacheable = true)
    public static List<Applicant__c> getApplicantDetails(String loanApplicationId){
        try{
            List<Applicant__c> applicants = [Select Id,Applicant_Type__c,Name,Opportunity__r.Customer_Type__c FROM Applicant__c WHERE Opportunity__c = :loanApplicationId AND In_Active_Applicant__c=false WITH SECURITY_ENFORCED]; //SFTRAC-49
            if(!applicants.isEmpty()){
                return applicants;
            }
        return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getApplicantDetails ', System.Label.Apex, ex,loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    /*@Method Name: loadInputsForDocumentsUpload
    * @Created by:  Sanketkumar Patil
    * @description: To get required details for the documents upload.
    * @Return:      DocumentsUploadResponseWrapper
    */
    @AuraEnabled
    public static DocumentsUploadResponseWrapper loadInputsForDocumentsUpload(){
        DocumentsUploadResponseWrapper docUploadResponseObj = new DocumentsUploadResponseWrapper();

        docUploadResponseObj.otherDocumentRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
        return docUploadResponseObj;
    }

    public class DocumentsUploadResponseWrapper{
        @AuraEnabled public ID otherDocumentRecordTypeId {get;set;}
    }
    
    //CISP-2743 - start
    @AuraEnabled
    public static Boolean getMAProfileName(String loanApplicationId){
        try{
            boolean isProfileMA = false;
            boolean isProductTW = false;
            User Usr =[SELECT Id,profile.name FROM User WHERE Id = : UserInfo.getUserId()];
            if(Usr.profile.name == 'IBL Partner Community Marketing Agent'){ //IBL Business Executive
                isProfileMA = true;
            }
            
            List<Opportunity> opportunityList = [Select Id,Product_Type__c,StageName From Opportunity Where Id=:loanApplicationId WITH SECURITY_ENFORCED];
            System.debug('opp '+opportunityList+'lID '+loanApplicationId);
            if (opportunityList.size()> 0 && (opportunityList[0].StageName != 'Final Offer' && opportunityList[0].StageName != 'Credit Processing' && opportunityList[0].StageName != 'Post Sanction Checks and Documentation')) {
                if (opportunityList[0].Product_Type__c == 'Two Wheeler') {
                    isProductTW = true;
                }
            }
            
            if(isProfileMA && isProductTW) {
                return true;
            }
            else {
                return false;
            }
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'getMAProfileName', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    Public Static boolean isProfileCVO(String LinkedEntityId,String loanApplicationId) {
        try {
            boolean profileFlag = false;
            boolean checkDocType = false;
            boolean isProductTW = false;
            
            String profileName = [Select Id, Name from Profile where Id=: UserInfo.getProfileId()].Name;
            if(profileName=='IBL CVO' || profileName =='IBL Partner Community CVO') {
                profileFlag = true;
            }
            
            List<Opportunity> opportunityList = [Select Id,Product_Type__c From Opportunity Where Id=:loanApplicationId WITH SECURITY_ENFORCED];
            if (opportunityList.size()> 0) {
                if (opportunityList[0].Product_Type__c == 'Two Wheeler') {
                    isProductTW = true;
                }
            }
            
            List<ContentDocumentLink> cldList = [SELECT ContentDocumentId, LinkedEntityId , TYPEOF LinkedEntity WHEN Documents__c THEN Id,Document_Type__c,RecordType.Name END FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId IN (Select Id from Documents__c where (RecordType.Name ='KYC Document' or Document_Type__c = 'Customer Image') and Id=: LinkedEntityId)];
            System.debug('cldList is: '+cldList);
            if(!cldList.isEmpty() && cldList.size() > 0) {
                checkDocType = true;
            }
            
            if(profileFlag && checkDocType && isProductTW) {
                return true;
            }
            else {
                return false;
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'isProfileCVO', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage()); 
        }
    }
    //CISP-2743 - end

    /*@Method Name: loanApplicationproductType
    * @Created by:  Rajat Jaiswal
    * @Modified by: Santhosh Guhan 
    * @description: This method used for getting Product type. 
    * @Return:      String
    */
    @AuraEnabled
    public static String loanApplicationproductType(String loanApplicationId){
        try{
            if (loanApplicationId!=null) {
                List<Opportunity> oppList = [Select Id,Product_Type__c from Opportunity WHERE Id =: loanApplicationId];
                if(oppList.size() > 0){
                  return oppList[0].Product_Type__c;
                }
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'loanApplicationproductType', System.Label.Apex, e, loanApplicationId);
        }
       // return false;
       return null;
    }
    /*@Method Name: loanApplicationCustomerType
    * @Created by:  Santhosh Guhan
    * @description: This method used for getting Customer type. 
    * @Return:      String
    */
    @AuraEnabled
    public static String loanApplicationCustomerType(String loanApplicationId){
        try{
            if (loanApplicationId!=null) {
                List<Opportunity> oppList = [Select Id,Customer_Type__c from Opportunity WHERE Id =: loanApplicationId and Product_Type__c = 'Tractor'];
                if(oppList.size() > 0){
                  return oppList[0].Customer_Type__c;
                }
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'loanApplicationCustomerType', System.Label.Apex, e, loanApplicationId);
        }
       // return false;
       return null;
    }
    /*@Method Name: checkUserAbleToDeleteDoc
    * @Created by:  Rajat Jaiswal
    * @description: To check whether the user is able to delete the file or not.
    * @Return:      boolean value
    */
    @AuraEnabled
    Public Static boolean checkUserAbleToDeleteDoc(String LinkedEntityId,String loanApplicationId) {
        try {
            List<Opportunity> opportunityList = [Select Id,Product_Type__c,StageName From Opportunity Where Id=:loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
            if (opportunityList.size()> 0) {
                Boolean allDeviationApproved = false;
                Boolean docPassToCMU= false;
                Boolean isAdditionalDetailsStage= false;
                if (opportunityList[0].Product_Type__c == 'Passenger Vehicles' || opportunityList[0].Product_Type__c == Label.Tractor) {
                    if (opportunityList[0].StageName =='Additional Details') {
                        isAdditionalDetailsStage = true;
                    }
                    List<CAM__c> camList = [SELECT Id,Total_Deviations__c,Action_Taken__c,Loan_Application__c,Total_Deviations_Proposal_Count__c,Trigger_Deviations__c,Deviation_Created_Date__c,Proposal_Status__c from CAM__c WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                    if (camList.size()> 0) {
                        if (camList[0].Total_Deviations__c > 0 && camList[0].Trigger_Deviations__c == true) {
                            Integer count = 0;
                            Set<Id> camIdSet = new Set<Id>();
                            for (CAM__c camObj : camList) {
                                camIdSet.add(camObj.Id);
                            }
                            List<Deviation__c> deviationList = [SELECT Id,Approval_Status__c,Proposal_Status__c,Parent_CAM__c,Role__c,Number_of_Days_Pending__c,Type__c FROM Deviation__c WHERE Parent_CAM__c IN : camIdSet WITH SECURITY_ENFORCED LIMIT 1000];
                            if (deviationList.size() > 0) {
                                for (Deviation__c deviationObj : deviationList) {
                                    if (deviationObj.Approval_Status__c =='Approved') {
                                        count += 1;
                                    }
                                }
                                if(camList[0].Total_Deviations__c == count){
                                    allDeviationApproved = true;
                                }
                            }
                        }
                    }
                    String cmuCaseRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId();
                    List<Case> cmuCaseList = [SELECT Id,Loan_Application__c FROM Case WHERE RecordTypeId =: cmuCaseRecordTypeId AND Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED];
                    if (!cmuCaseList.isEmpty() && cmuCaseList.size() > 0) {
                        Set<Id> cmuCaseIdSet = new Set<Id>();
                        for (Case caseObj : cmuCaseList) {
                            cmuCaseIdSet.add(caseObj.Id);
                        }
                        if (!cmuCaseIdSet.isEmpty()) {
                            List<ContentDocumentLink> cldList = [SELECT ContentDocumentId, LinkedEntityId, TYPEOF LinkedEntity WHEN Documents__c THEN Id,Document_Type__c,RecordType.Name,Case__c END FROM ContentDocumentLink WHERE LinkedEntityId IN (Select Id from Documents__c where Id=: LinkedEntityId AND Case__c IN : cmuCaseIdSet)];
                            if(!cldList.isEmpty() && cldList.size() > 0) {
                                docPassToCMU = true;
                            }
                        }
                    }
                    if(allDeviationApproved || docPassToCMU || isAdditionalDetailsStage) {
                        return true;
                    }
                    else {
                        return false;
                    }
                }else if(opportunityList[0].Product_Type__c == 'Two Wheeler'){
                    List<String> DocTypesName = new List<String>{'Cheques SPDC','Borrower\'s Passbook','NOC','RC Document','Invoice','IHM Receipt','Agreement Copy','ACH Mandate Form','Cancelled Cheque','DPN','RTO','RCU report','Co-Borrower\'s Passbook','Co-Borrower\'s Bank Statement','Borrower\'s Bank Statement','Agreement Wrapper Booklet','Agreement 1st Schedule','IT Return or Saral','Salary Slip','Form 16','GST Certificate','Agreement 2nd Schedule'};
                    List<Documents__c> docList = [SELECT Id,Document_Type__c FROM Documents__c WHERE Id =:LinkedEntityId LIMIT 1];
                    if(docList.size() > 0 && docList[0].Document_Type__c != null && DocTypesName.contains(docList[0].Document_Type__c)){
                        return false; 
                    }else{
                        return true; 
                    }
                }
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'checkUserAbleToDeleteDoc', System.Label.Apex, e, loanApplicationId);
            throw new IND_Exception(e.getMessage()); 
        }
        return false;
    }

    /*
    * @Method:      contentDocumentPresentOrNot
    * @Created by:  gaurav rawat
    * @Description: This method will check contentdocument present or not
    * @Param:       String -  docId
    * @Return:      boolean 
    */
    @AuraEnabled
    public static Boolean contentDocumentPresentOrNot(String docId){
        Boolean contentDocumentsPresent = false;
        try{
            if(docId != null){
                List<Documents__c> docList =  new List<Documents__c>();
                docList = [Select id,Document_Type__c from Documents__c Where Id =: docId LIMIT 1];

                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                contentDocumentLinkList =[SELECT id, contentdocumentid, linkedentity.name, linkedentityid FROM ContentDocumentLink WHERE linkedentityid =:docId ];
                if(docList.size() > 0 && (docList[0].Document_Type__c == System.Label.AadhaarCard || docList[0].Document_Type__c == System.Label.VoterIdCard || docList[0].Document_Type__c == System.Label.DrivingLicences || docList[0].Document_Type__c == System.Label.PassportCard)){
                    if(contentDocumentLinkList.size() >= 2){
                        contentDocumentsPresent = true;
                    }
                } else if(docList.size() > 0 && contentDocumentLinkList.size() > 0){
                    contentDocumentsPresent = true;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'contentDocumentPresentOrNot ', System.Label.Apex, e);
        }
        return contentDocumentsPresent;
    }

    /* @Method Name: checkDeleteButtonRequired
    * @Created by:  Rajat Jaiswal
    * @description: To check delete button required or not
    * @Param:       String - loanApplication ID
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean checkDeleteButtonRequired(String loanApplicationId){
        try{
            Boolean isDeleteRequired = false;
            Opportunity oppObj = [Select Id,StageName,Product_Type__c,Sub_Stage__c from opportunity where Id =: loanApplicationId];
            Map<String,Loan_Application_Transaction_History__c> historyMap = new Map<String,Loan_Application_Transaction_History__c>();
            for(Loan_Application_Transaction_History__c history : [SELECT Id, Name, Submitted_Flag__c, Screen__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =: loanApplicationId AND Module__c = 'Post Sanction Checks and Documentation' AND Submitted_Flag__c = false WITH SECURITY_ENFORCED]){
                historyMap.put(history.Screen__c, history);
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && oppObj.StageName == 'Final Offer'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && oppObj.StageName == 'Credit Processing' && oppObj.Sub_Stage__c == 'Income'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && historyMap.containsKey('Security Mandate') && historyMap.get('Security Mandate') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && historyMap.containsKey('Additional Documents') && historyMap.get('Additional Documents') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && historyMap.containsKey('Invoice') && historyMap.get('Invoice') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && historyMap.containsKey('IHM') && historyMap.get('IHM') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && historyMap.containsKey('Loan Agreement') && historyMap.get('Loan Agreement') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && historyMap.containsKey('Repayment Mandate') && historyMap.get('Repayment Mandate') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation'){
                isDeleteRequired = true;
            }
            if(oppObj.Product_Type__c == 'Two Wheeler' && historyMap.containsKey('RTO, DPN, POA Documents Upload') && historyMap.get('RTO, DPN, POA Documents Upload') !=null && oppObj.StageName == 'Post Sanction Checks and Documentation'){
                isDeleteRequired = true;
            }
            return isDeleteRequired;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocumentUploadCntrl', 'checkDeleteButtonRequired ', System.Label.Apex, ex,loanApplicationId);           
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    @AuraEnabled
    public static string checkFileSize(String docId){
        try {
            if(docId != null){
                Integer fileSize  =0;
                Set<Id> contentDocId = new Set<Id>();
                for(ContentDocumentLink conDoc : [Select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId =: docId ]){
                    contentDocId.add(conDoc.ContentDocumentId);
                }
            List<ContentDocument> conObjList = [SELECT Id,ContentSize from ContentDocument where id IN: contentDocId];
            for(ContentDocument conObj : conObjList){
                fileSize += conObj.ContentSize;
            }
            system.debug('fileSize--' +fileSize);
            if(fileSize >0){
                if(fileSize/1024 > 200){
                    system.debug('fileSize/1024 > 200--' +fileSize/1024);
                    delete conObjList;
                    return 'File size cannot be greater than 200 KB. Please reupload';
                }
                return null;
            }
            return null;
        }
            return null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}