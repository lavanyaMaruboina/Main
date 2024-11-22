public with sharing class GenericUploadController {

    @AuraEnabled
    public static Opportunity checkPaymentRequest(string loanApplicationId, String dealId){
        try {
            if(loanApplicationId != null) {
            List<Opportunity> oppList = [Select Id , Payment_Request_Generation_Date__c,(Select id from Vehicle_Details__r WHERE Deal_Number__c =: dealId) FROM Opportunity where Id =: loanApplicationId];
                if(oppList.size()>0){
                    return oppList[0];
                }
                
            }
            return null;
        } catch( Exception e) {
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'checkPaymentRequest', '', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method Name: getRelatedFileByRecordId
    * @Created by:  Kruthi Nadig
    * @description: to get version data of file
    * @Param:       String contentversion Id
    */
    @AuraEnabled
    public static string getRelatedFileByRecordId(string contentVersionId) {
        ContentVersion conv = [Select Id,versionData from ContentVersion where Id = :contentVersionId];
        return EncodingUtil.base64Encode(conv.versionData);
    }
    
    /*
    * @Method Name: checkRCDocument
    * @Created by:  Kruthi Nadig
    * @description: to check if RC Document already exists
    * @Param:       String Loan Application Id, String Applicant Id
    */
    @AuraEnabled
    public static String checkRCDocument(string loanApplicationId,string applicantId, String dealId){
        if(loanApplicationId != NULL){
            Opportunity oppObj = [Select Id,Vehicle_Type__c, Product_Type__c from Opportunity Where Id=:loanApplicationId];
            string docName;
            if(oppObj.Vehicle_Type__c == 'New'){
                docName = 'RC';
            }else if(oppObj.Vehicle_Type__c == 'Used' || oppObj.Vehicle_Type__c == 'Refinance'){
                docName = 'Post Payments Request RC';
            }
            list<Documents__c> doclist = new list<Documents__c>();
            if(oppObj.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                doclist = [SELECT Id 
                            FROM Documents__c 
                            WHERE Document_Type__c = :docName AND Opportunity_Relation__c = :loanApplicationId AND Applicant__c =:applicantId AND Is_Active__c = true AND Vehicle_Detail__c =: VehicleLst[0].Id
                            WITH SECURITY_ENFORCED];
            }else{
                doclist = [SELECT Id 
                            FROM Documents__c 
                            WHERE Document_Type__c = :docName AND Opportunity_Relation__c = :loanApplicationId AND Applicant__c =:applicantId AND Is_Active__c = true 
                            WITH SECURITY_ENFORCED];
            }

            if(!doclist.isEmpty()) {
                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                contentDocumentLinkList =[SELECT id, contentdocumentid, linkedentity.name, linkedentityid FROM ContentDocumentLink WHERE linkedentityid =: doclist[0].Id ];
                if(contentDocumentLinkList.isEmpty()){
                    return null;
                }else{
                    return doclist[0].Id;
                }
            } else {
                return null;
            }
        }else{
            return null;
        }
    }

    /*
    * @Method Name: clearRCDocument
    * @Created by:  Kruthi Nadig
    * @description: clear the values in RC
    * @Param:       String Loan Disbursement Id
    */
    @AuraEnabled
    public static void clearRCDocument(string loanDisbursementId){
        try {
            if(loanDisbursementId != null) {
            update new LoanDisbursementDetails__c(Id=loanDisbursementId,Registration_Date__c=null,Registration_Format__c='',Registration_Number__c='',Registration_Owner_Nam__c='',RC_Document__c=null);
            }
        } catch( Exception e) {
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'clearRCDocument', '', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method Name: fetchDisbursementRecord
    * @Created by:  Kruthi Nadig
    * @description: to fetch disbursement recordId
    * @Param:       String Loan Application Id, String Applicant Id
    */
    @AuraEnabled
    public static LoanDisbursementDetails__c fetchDisbursementRecord(string loanApplicationId,string applicantId, String dealId){
        try {
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            list<LoanDisbursementDetails__c> disbList = new list<LoanDisbursementDetails__c>();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                disbList = [SELECT Id,Parent_Loan_Application__r.Vehicle_Type__c 
                                FROM LoanDisbursementDetails__c 
                                WHERE Parent_Loan_Application__c = :loanApplicationId AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED];
            }else{
                disbList = [SELECT Id,Parent_Loan_Application__r.Vehicle_Type__c 
                                FROM LoanDisbursementDetails__c 
                                WHERE Parent_Loan_Application__c = :loanApplicationId 
                                WITH SECURITY_ENFORCED];
            }
            if(!disbList.isEmpty()) {
                return disbList[0];
            } else {
                return null;
            }
        } catch( Exception e) {
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'fetchDisbursementRecord', '', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method Name: deleteContentDocument
    * @Created by:  Kruthi Nadig
    * @description: to delete the content document
    * @Param:       String - Document ID
    */
    @AuraEnabled
    public static String deleteContentDocument(String docIds){
        try{
            ContentDocumentLink conLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE Id=:docIds WITH SECURITY_ENFORCED];
            delete new ContentDocument(Id = conLink.ContentDocumentId);
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return 'SUCCESS';
           
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'deleteContentDocument', '', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method Name: createOtherDocument
    * @Created by:  Kruthi Nadig
    * @description: to create a Document object for 'Other documents'
    * @Param:       String - Document Type
    * @Param:       String - current Vehicle Record ID
    * @Param:       String - Loan Applicant ID
    * @Return:      String - loanApplication ID
    */
	@AuraEnabled
    public static string createOtherDocument(String docType,String vehicleDetailId,String applicantId,String loanApplicationId){
         try {  
                string leadNo;
                list<Documents__c> docUpdList = new list<Documents__c>();
                ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                if(loanApplicationId!=null ){
                   list<Opportunity> loanApp= [Select Name from Opportunity where Id =: loanApplicationId WITH SECURITY_ENFORCED];
                   if(!loanApp.isEmpty()) {
                       leadNo = loanApp[0].Name;
                       //Deactivate existing Document, if any                      
                       for(Documents__c doc : [Select Id from Documents__c where Document_Type__c = :docType and Opportunity_Relation__c = :loanApplicationId and Applicant__c =:applicantId and Vehicle_Detail__c =: vehicleDetailId WITH SECURITY_ENFORCED]) {
                            doc.is_Active__c = false;
                            docUpdList.add(doc);
                       }
                   }
                   if(!docUpdList.isEmpty()) {
                        update docUpdList;
                   }   
                   Documents__c docObject= new Documents__c(Name = docType+' '+leadNo,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType,is_Active__c = true);
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
                    ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'createOtherDocument ', System.Label.Apex, e);
            		throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());  
              }

    }

    /*
    * @Method Name: changeFilename
    * @Created by:  Kruthi Nadig
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
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'changeFilename ', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }  
    }
    
     
    /*
    * @Method Name: getContentVersion
    * @Created by:  Poonam Tilokani
    * @description: to get content version
    * @Param:       String - contentDocumentId
    */
    
     @AuraEnabled
    public static List<ContentVersion> getContentVersion(String conDocId){
        try{
            List<ContentVersion> conVerList = [SELECT Id, VersionData, FileType, Title, FileExtension,IsLatest, 
                                                     ContentDocumentId, ContentDocument.FileType
                                                    FROM   ContentVersion 
                                                    WHERE  ContentDocumentId =: conDocId and IsLatest = true];
            if(conVerList.size()>0){
                return conVerList;
            }
            return null;
            
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'getContentVersion', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage()); 
        }
    }
    /*
    * @Method Name: getProfileName
    * @Created by:  Poonam Tilokani
    * @description: to get profile name
    * @Param:       String - Loan application Id
    */
    @AuraEnabled
    public static Boolean getProfileName(String loanApplicationId){
        try{                   
            User Usr =[SELECT Id,profileId,profile.name,userType FROM User WHERE Id = : UserInfo.getUserId()];
            if(Usr.userType == 'PowerPartner'){
                return true;
            }else{
                return false;
            }
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'getProfileName', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage()); 
        }
    }

    /*
    * @Method Name: fetchLoanApplicationSubStage
    * @Created by:  Gaurav Rawat
    * @description: to fetch the loan application sub stage
    * @Param:       String - Loan application Id
    */
    @AuraEnabled
    public static Boolean fetchLoanApplicationSubStage(String loanApplicationId){
        Boolean isSubStageRC = false;
        try{
            List<Opportunity> oppList = new List<Opportunity>([SELECT Id,Sub_Stage__c FROM Opportunity WHERE Id = : loanApplicationId WITH SECURITY_ENFORCED LIMIT 1]);
            for(Opportunity opp : oppList){
                if(opp.Sub_Stage__c == System.Label.RC_Disbursement_Substage){
                    isSubStageRC = true;
                }
            }
            return isSubStageRC;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'fetchLoanApplicationSubStage', System.Label.Apex, e, loanApplicationId);
            throw new IND_Exception(e.getMessage()); 
        }
    }
    @AuraEnabled
    public static void otherFilesDeleted(string contentDocId, String documentId){
        try{
            if(documentId != null && contentDocId != null){
               List<ContentDocumentLink> conLinkList = [Select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId =: documentId AND ContentDocumentId !=: contentDocId ];
               if(conLinkList.size()>0){
                   delete conLinkList;
               }
                    
            }

        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'otherFilesDeleted ', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
}