/**
* @Name         CaseWithoutSharingUpdate
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This class to update case
* Inputs:       None
* Test Class:   CaseWithoutSharingUpdate_Test
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 05-24-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
public without sharing class CaseWithoutSharingUpdate {
        /*
* @Method:      updateCase
* @Created by:  mohammad_shahkomeni
* @Description: This function updates case
* @Param:       Case
* @Return:      void
*/
    public static void updateCase(Case cse) {
        try{
            UPDATE cse;
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'updateCase', 'Class', e);
			throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }

/*
* @Method:      updateFi
* @Created by:  Saloni Jadhav
* @Description: This function updates FI 
* @Param:       FI
* @Return:      void
*/
    public static void updateFi(Field_Investigation__c fiRecord) {
        try{
            UPDATE fiRecord;
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'updateFi', 'Class', e);
			throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }

/*
* @Method:      insertopptyTeamMembers
* @Created by:  Saloni Jadhav
* @Description: This function Insert Opportunity Teams Records 
* @Param:       FI
* @Return:      void
*/
    public static void insertopptyTeamMembers(List<OpportunityTeamMember> opptyTeamMembersToBeInserted) {
        try{
            insert opptyTeamMembersToBeInserted;
            System.debug('opptyTeamMembersToBeInserted'+opptyTeamMembersToBeInserted);
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'insertopptyTeamMembers', 'Class', e);
			throw new AuraHandledException(System.Label.ExceptionMessage);
        }   
    }
    /*
    * @Method:      deleteOTMRecord
    * @Created by:  Manish Baldota
    * @Description: This function Insert Opportunity Teams Records 
    * @Param:       FI
    * @Return:      void
    */
    public static void deleteOTMRecords(List<OpportunityTeamMember> opptyTeamMembersToBeInserted) {
        try{
            Delete opptyTeamMembersToBeInserted;
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'insertopptyTeamMembers', 'Class', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }   
    }
    
    /*
    * @Method:      deleteOCRRetryCounts
    * @Created by:  Rajat Jaiswal
    * @Description: This function will delete OCR retry counts records
    * @Param:       Retry_Count__c List
    * @Return:      void
    */
    public static void deleteOCRRetryCounts(List<Retry_Count__c> retryCountsToBeDeleted) {
        try{
            Delete retryCountsToBeDeleted;
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'deleteOCRRetryCounts', 'Class', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }   
    }

     /*
    *@Method:      storedMaskedKYCDoc
    *@Created by:  Rajat Jaiswal
    *@Description: store masked aadhar doc received from OCR API response against the document
    *@Param:       String : base64Imag, documentId, docSide, contentDocumentId 
    *@Return:      String
    */
    @AuraEnabled
    public static String storedMaskedKYCDoc(String base64Imag, String documentId, String docSide, String contentDocumentId) {
        try{
            if(!String.isBlank(base64Imag)) {
                List<ContentDocument> conDocumentToDelete = new List<ContentDocument>();
                conDocumentToDelete = [SELECT Id,FileExtension,FileType FROM ContentDocument where Id = :contentDocumentId];
                String fileExtension = conDocumentToDelete[0].FileExtension;
                Documents__c DC=[select id, Document_Type__c from Documents__c where id=:documentId];//CISP-3344
                ContentVersion versionData = new ContentVersion();
                versionData.ContentLocation = 'S';
                versionData.Document_Side_fileupload__c = docSide;
                Blob body = EncodingUtil.base64Decode(base64Imag);
                versionData.VersionData = body;
                //CISP-3344 --start, added if and else block for DL
                if(DC.Document_Type__c==System.Label.DrivingLicences)
                {
                    versionData.Title = docSide+'_'+ System.Label.DrivingLicences+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                    versionData.PathOnClient = docSide+'_'+System.Label.DrivingLicences+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                }
                else {
                	versionData.Title = docSide+'_'+'Aadhaar'+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                	versionData.PathOnClient = docSide+'_'+'Aadhaar'+'_'+DateTime.now().millisecond()+'.'+fileExtension;
                }
                //CISP-3344 --end
                insert versionData;
            
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :versionData.Id].ContentDocumentId;
                conDocLink.LinkedEntityId = documentId;
                conDocLink.ShareType = 'V';
                insert conDocLink;

                if(!conDocumentToDelete.isEmpty() && conDocLink != null) {
                    if(Schema.sObjectType.ContentDocument.isDeletable()) {  
                        DELETE conDocumentToDelete;
                    }
                }
                return conDocLink.ContentDocumentId;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'storedMaskedKYCDoc', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage()+' '+e.getLineNumber());
        }
    }

    /* @Method:      updateCase
    * @Created by:  Rajat Jaiswal
    * @Description: This function updates case
    * @Param:       Case
    * @Return:      void
    */
        public static void updateCaseList(List<Case> cse) {
            try{
                UPDATE cse;
            }Catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'updateCaseList', 'Class', e);
                throw new AuraHandledException(System.Label.ExceptionMessage);
            } 
        }
    
    /*
    * @Method:      updateFi
    * @Created by:  Rajat Jaiswal
    * @Description: This function updates FI 
    * @Param:       FI
    * @Return:      void
    */
        public static void updateFiList(List<Field_Investigation__c> fiRecord) {
            try{
                UPDATE fiRecord;
            }Catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'updateFiList', 'Class', e);
                throw new AuraHandledException(System.Label.ExceptionMessage);
            } 
        }

        public static List<Asset_Verification__c> getAssetVerRecord(String loanApplicationId,String dealId){
            try{
                List<Asset_Verification__c> assetVerificationList = new List<Asset_Verification__c>();
                List<Case>caseList = [SELECT Id FROM Case WHERE Loan_Application__c = :loanApplicationId AND RecordType.Name ='Asset Verification' ORDER BY CreatedDate DESC limit 1];
                if(caseList.size() > 0){
                    assetVerificationList = [SELECT Id,Date_of_submission__c,Case__c,OwnerId FROM Asset_Verification__c WHERE Case__r.Loan_Application__c =:loanApplicationId AND Case__c =:caseList[0].Id AND Vehicle_Detail__r.Deal_Number__c =:dealId];
                }
                return assetVerificationList;
            }Catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('CaseWithoutSharingUpdate', 'getAssetVerRecord', 'Class', e);
                throw new AuraHandledException(System.Label.ExceptionMessage);
            } 
            
        }
}