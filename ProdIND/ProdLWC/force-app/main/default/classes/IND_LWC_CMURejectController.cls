public without sharing class IND_LWC_CMURejectController {

    @AuraEnabled
    public static KycNumberWrapper getDecryptKycNumber(String documentId){
        String decryptedKycNumber;
        String kycNo;
        String kycDocumentType;
        String kycNoAPIName;
        String docOppId;
        String firstName;
        String lastName;
        String docAppId;
        Boolean isGoldenSouPass;
        Date kycDob;
        String oppProductType; //SFTRAC-2160
        KycNumberWrapper kycNumberWrapperObj = new KycNumberWrapper();
        try{ 
            for(Documents__c documentObj : [Select Id,Applicant__c,KYC_Document_Number__c,First_Name__c,Last_Name__c,Opportunity_Relation__c, KYC_No__c,PAN_No__c,Passport_No__c,document_Type__c,Golden_Source_Pass__c,KYC_DOB__c,Document_Number__c,Masked_KYC_No__c,Opportunity_Relation__r.Product_Type__c  from Documents__c Where Id=:documentId WITH SECURITY_ENFORCED LIMIT 1]){
                if(documentObj.Document_Type__c == System.Label.PassportCard){
                    kycNo = documentObj.Passport_No__c;
                    kycDocumentType = 'Passport No.';
                    kycNoAPIName = 'Passport_No__c';
                    decryptedKycNumber = Integrationutilities.getDecryptedResponse(kycNo,System.Label.privateKey,System.Label.ivkey);
                }else if(documentObj.Document_Type__c == System.Label.PanCards){
                    kycNo = documentObj.PAN_No__c;
                    kycDocumentType = 'PAN No.';
                    kycNoAPIName = 'PAN_No__c';
                    docAppId = documentObj.Applicant__c;
                    firstName = documentObj.First_Name__c;
                    lastName = documentObj.Last_Name__c;
                    docOppId = documentObj.Opportunity_Relation__c;
                    decryptedKycNumber = Integrationutilities.getDecryptedResponse(kycNo,System.Label.privateKey,System.Label.ivkey);
                }else if(documentObj.Document_Type__c == System.Label.AadhaarCard){
                    kycDocumentType = 'Aadhaar No.';
                    decryptedKycNumber = documentObj.Masked_KYC_No__c;
                    kycNoAPIName = 'KYC_No__c';
                }else{
                    kycNoAPIName = 'KYC_No__c';
                    if(documentObj.Document_Type__c == System.Label.VoterIdCard){
                        kycDocumentType = 'VoterId No.';
                        kycNo = documentObj.KYC_No__c;
                        decryptedKycNumber = Integrationutilities.getDecryptedResponse(kycNo,System.Label.privateKey,System.Label.ivkey);
                    }
                    else if(documentObj.Document_Type__c == System.Label.DrivingLicences){
                        kycDocumentType = 'DrivingLicences No.';
                        isGoldenSouPass = documentObj.Golden_Source_Pass__c;
                        kycDob = documentObj.KYC_DOB__c;
                        kycNo = documentObj.KYC_No__c;
                        decryptedKycNumber = Integrationutilities.getDecryptedResponse(kycNo,System.Label.privateKey,System.Label.ivkey);
                        docOppId = documentObj.Opportunity_Relation__c;
                        docAppId = documentObj.Applicant__c;
                    }else if (documentObj.Opportunity_Relation__r.Product_Type__c == 'Tractor'){
                        oppProductType = documentObj.Opportunity_Relation__r.Product_Type__c;   //SFTRAC-2160
                        //kycDocumentType = 'Document Number';
                        kycDocumentType = documentObj.document_Type__c == 'GST Certificate' ? 'GST Number' : documentObj.document_Type__c == 'CIN' ? 'CIN Number' : 'Document Number';  //SFTRAC-2160
                        kycNo = documentObj.KYC_Document_Number__c;
                        if(documentObj.document_Type__c == 'GST Certificate' || documentObj.document_Type__c == 'CIN'){
                       // decryptedKycNumber = documentObj.KYC_Document_Number__c;
                        decryptedKycNumber = Integrationutilities.getDecryptedResponse(kycNo,System.Label.privateKey,System.Label.ivkey);
                        } 
                    } /*else{
                    kycNo = documentObj.KYC_No__c;
                    decryptedKycNumber = Integrationutilities.getDecryptedResponse(kycNo,System.Label.privateKey,System.Label.ivkey);
                    } */
                }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(' IND_LWC_CMURejectController ', ' getDecryptKycNumber ', 'System.Label.Apex', e);
        }
        
        kycNumberWrapperObj.decryptedKycNumber = decryptedKycNumber;
        kycNumberWrapperObj.kycNo = kycNo;
        kycNumberWrapperObj.kycDocumentType = kycDocumentType;
        kycNumberWrapperObj.kycNoAPIName = kycNoAPIName;
        kycNumberWrapperObj.docAppId = docAppId;
        kycNumberWrapperObj.firstName = firstName;
        kycNumberWrapperObj.lastName = lastName;
        kycNumberWrapperObj.docOppId = docOppId;
        kycNumberWrapperObj.isGoldenSourcePass = isGoldenSouPass;
        kycNumberWrapperObj.kycDob = kycDob;
        kycNumberWrapperObj.oppProductType = oppProductType;    //SFTRAC-2160
        return kycNumberWrapperObj;
    }

    public class KycNumberWrapper{
        @AuraEnabled
        public String decryptedKycNumber{get;set;}
        @AuraEnabled
        public String kycNo{get;set;}
        @AuraEnabled
        public String kycDocumentType{get;set;}
        @AuraEnabled
        public String kycNoAPIName{get;set;}
        @AuraEnabled
        public String docAppId{get;set;}
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String lastName{get;set;}
        @AuraEnabled
        public String docOppId{get;set;}
        @AuraEnabled
        public Boolean isGoldenSourcePass{get;set;}
        @AuraEnabled
        public Date kycDob{get;set;}
        @AuraEnabled
        public String oppProductType{get;set;} //SFTRAC-2160
        
        KycNumberWrapper(){
            this.decryptedKycNumber = '';
            this.kycNo = '';
            this.kycDocumentType = '';
            this.kycNoAPIName = '';
            this.docOppId = '';
            this.docAppId = '';
            this.firstName = '';
            this.lastName = '';
            this.isGoldenSourcePass = false;
            this.oppProductType = '';   //SFTRAC-2160
        }
    }
    @AuraEnabled
    public static String getEncryptedRequest(String requestJSON){
        Blob privateKey = Blob.valueOf(IntegrationUtilities.getAPIKeys(System.Label.privateKey));
        Blob ivkey = Blob.valueOf(IntegrationUtilities.getAPIKeys(System.Label.ivkey)); 
        Blob data = Blob.valueOf(requestJSON);  
        Blob encrypted = Crypto.encrypt('AES256', privateKey, ivkey, data); 
        String encryptedString = EncodingUtil.base64Encode(encrypted);  
        return encryptedString;
    }

    @AuraEnabled	
    public static docListWrapper getDocumentsList(string caseId){	
        try{ 	
            docListWrapper listWrapper = new docListWrapper();	
            listWrapper.isDisabled = true;	
            String userId = UserInfo.getUserId();	
            List<Documents__c> docsList = [SELECT Id,Name,CMU_Rejection_Reason__c,Applicant_name__c,Rejection_Fields__c,CMU_Comment__c,	
                Document_Type__c,Applicant__c, recordTypeId,RecordType.Name,applicant_Type__c,First_Name__c,Last_Name__c,PAN_No__c FROM
                Documents__c WHERE CMU_Accept_Reject__c = 'Reject' AND Case__c =: caseId];	
            	
            List<Case> caseObj = [SELECT Id,OwnerId,Accept_Case__c,CMU_Case_Accepted_By__c,Loan_Application__r.LeadSource FROM Case WHERE Id =: caseId LIMIT 1];	
                if(caseObj.size() >0){	
                    if(caseObj[0].OwnerId == UserInfo.getUserId() && caseObj[0].CMU_Case_Accepted_By__c == UserInfo.getUserId() && caseObj[0].Accept_Case__c == true){	
                        listWrapper.isDisabled = false;	
                    }	
                }	
            	
            if(docsList != null && docsList.size() > 0){	
                listWrapper.documentList = docsList;	
                return listWrapper;	
            }	
            return null;	
        } catch(Exception e){	
            ErrorLoggerUtil.logErrorEvent(' IND_LWC_CMURejectController ', ' getDocumentsList ', 'System.Label.Apex', e);	
            throw new AuraHandledException(System.Label.ExceptionMessage);	
        }	
    }	
    
    public class docListWrapper{	
        @AuraEnabled	
        public List<Documents__c> documentList{get;set;}	
        @AuraEnabled	
        public Boolean isDisabled{get;set;}	
    }

    @AuraEnabled	
    public static Case getCaseDetails(String caseId) {	
        try{	
            List<Case> caseObj = [Select Id,CMU_Case_Submitted_By__c,Loan_Application__c,Accept_Case__c,CMU_Case_Accepted_By__c,OwnerId,Status,Loan_Application__r.LeadSource,Loan_Application__r.Is_Revoked__c,Loan_Application__r.Journey_Status__c,Loan_Application__r.Journey_Stop_Reason__c,CMU_Case_Accepted_By__r.Name FROM Case where Id =: caseId LIMIT 1];	
            if(caseObj.size() >0){	
                return caseObj[0];	
            }	
            return null;	
        }catch(Exception e){	
            ErrorLoggerUtil.logErrorEvent('IND_LWC_CMURejectController', 'getCaseDetails', System.Label.Apex, e, '');	
            throw new IND_Exception(e.getMessage());	
        }	
    }

    @AuraEnabled	
    public static caseDetailsWrapper updateCase(String caseId){	
        try{	
            caseDetailsWrapper caseWrapper = new caseDetailsWrapper();
            List<Case> caseObj = [SELECT Id,OwnerId,Accept_Case__c,CMU_Case_Accepted_By__c,CMU_Case_Accepted_By__r.Name,Status FROM Case WHERE Id =: caseId	
                AND Accept_Case__c=false LIMIT 1];	
            if(caseObj.size() >0){	
                System.debug('Inside if');	
                Case cs = caseObj[0];	
                cs.Accept_Case__c = true;	
                cs.OwnerId = UserInfo.getUserId();	
                cs.CMU_Case_Accepted_By__c = UserInfo.getUserId();	
                update cs;	
                caseWrapper.caseDetail = cs;
                caseWrapper.userName = UserInfo.getName();
                return caseWrapper;
            }else{
                List<Case> caseObjj = [SELECT Id,OwnerId,Accept_Case__c,CMU_Case_Accepted_By__c,CMU_Case_Accepted_By__r.Name,Status FROM Case WHERE Id =: caseId AND Accept_Case__c=true LIMIT 1];
                caseWrapper.caseDetail = caseObjj[0];
                caseWrapper.userName = caseObjj[0].CMU_Case_Accepted_By__r.Name;
                return caseWrapper;
            }	
        }catch(Exception e){	
            ErrorLoggerUtil.logErrorEvent('IND_LWC_CMURejectController', 'updateCase', System.Label.Apex, e, '');	
            throw new IND_Exception(e.getMessage());	
        }	
    }

    public class caseDetailsWrapper{
        @AuraEnabled
        public Case caseDetail{get;set;}
        @AuraEnabled
        public String userName{get;set;}
    }
    
    @AuraEnabled
    public static docFieldWrapper getDocumentDetails(String docId,String documentType){
        docFieldWrapper documentElement = new docFieldWrapper();
        String docQuery = 'SELECT ';
        
        if(documentType == System.Label.AadhaarCard){
            List<CMU_Query_Fields__mdt> customMtdList = [SELECT Query_Fields__c FROM CMU_Query_Fields__mdt WHERE DeveloperName = 'Aadhaar' WITH SECURITY_ENFORCED LIMIT 1 ];
            String str = customMtdList[0].Query_Fields__c;           
            docQuery += str;            
        } else if(documentType == System.Label.PanCards){
            List<CMU_Query_Fields__mdt> customMtdList = [SELECT Query_Fields__c FROM CMU_Query_Fields__mdt WHERE DeveloperName = 'PAN' WITH SECURITY_ENFORCED LIMIT 1];
            String str = customMtdList[0].Query_Fields__c;           
            docQuery += str;              
        } else if(documentType == System.Label.PassportCard){
            List<CMU_Query_Fields__mdt> customMtdList = [SELECT Query_Fields__c FROM CMU_Query_Fields__mdt WHERE DeveloperName = 'Passport' WITH SECURITY_ENFORCED LIMIT 1];
            String str = customMtdList[0].Query_Fields__c;           
            docQuery += str;  
        } else{
            docQuery += 'Document_Type__c,Salutation__c,First_Name__c,Last_Name__c,KYC_name__c,Gender__c,KYC_No__c,KYC_DOB__c,KYC_Expiry_Date__c,KYC_Issuance_Date__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,KYC_District__c,KYC_State__c,KYC_Pin_Code__c';
        }

        docQuery += ',Id,Rejection_Fields__c,Applicant__r.Father_s_name__c,Applicant__r.Spouse_Name__c,Applicant__r.Mother_s_name__c,Applicant__c FROM Documents__c WHERE Id = \''+ docId +'\' LIMIT 1';
        
        List<Documents__c> docList = Database.query(docQuery); 
        List<String> editableFields = new List<String>();
        List<appFieldWrapper> appFieldList = new List<appFieldWrapper>();
        if(!docList.isEmpty() && docList[0].Rejection_Fields__c != null){
            editableFields = getFieldAPIName('Documents__c',docList[0].Rejection_Fields__c);
            appFieldList = getAppFieldList(docList[0], docList[0].Rejection_Fields__c);            
        }
        
        documentElement.document = docList[0];
        documentElement.editableFields = editableFields;
        documentElement.appFieldList = appFieldList;
        return documentElement;
    }    
    
    @AuraEnabled
    public static void deleteRelatedDocuments(String documentId,String contentDocumentIds){
        try{
            if (contentDocumentIds!=null) {
                List<String> contentDocumentIdList = (List<String>)JSON.deserialize(contentDocumentIds, List<String>.class);
                List<ContentDocument> contentDocuments = new List<ContentDocument>();
                
                if (documentId!=null) {
                    for(ContentDocumentLink documentList:[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink  where LinkedEntityId=:documentId AND ContentDocumentId NOT IN : contentDocumentIdList]){
                        contentDocuments.add(new ContentDocument(id=documentList.ContentDocumentId));
                    } 
                }
                if (Schema.sObjectType.ContentDocument.isAccessible() && Schema.sObjectType.ContentDocument.isDeletable() ){
                    delete contentDocuments;
                }
            }
        } catch(Exception e){
            system.debug('Exception::'+e);
            ErrorLoggerUtil.logErrorEvent(' IND_LWC_CMURejectController ', ' deleteRelatedDocuments ', 'System.Label.Apex', e);
            throw new AuraHandledException('Something went wrong: '+ e.getMessage()); 
        }
    }    
    
    @AuraEnabled
    public static void deleteRelatedDocumentsOnUpload(String documentId,String contentDocumentIds, String docSide){
        try{
            if (contentDocumentIds!=null) {
                List<Documents__c> docList = [Select Id,isFrontDocReplaced__c,isBackDocReplaced__c,Aadhar_Source__c,Reupload_DateTime__c from Documents__c where Id =: documentId limit 1];
                if(docList.size() > 0 && docList[0].Aadhar_Source__c == 'OTP'){
                    docList[0].Aadhar_Source__c = 'Scan and Upload';
                    update docList[0];
                }

                List<String> contentDocumentIdList = (List<String>)JSON.deserialize(contentDocumentIds, List<String>.class);
                List<ContentDocument> contentDocuments = new List<ContentDocument>();
                Set<ContentDocument> contentDocumentsDeleted = new Set<ContentDocument>();  
                
                if (documentId!=null) {
                    for(ContentDocumentLink documentList:[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink  where LinkedEntityId=:documentId AND ContentDocumentId NOT IN : contentDocumentIdList]){
                        contentDocuments.add(new ContentDocument(id=documentList.ContentDocumentId));
                    } 
                }
                if(!contentDocuments.isEmpty()){
                    for(ContentVersion conVer : [select id,FileType,Document_Side_fileupload__c,ContentDocumentId from ContentVersion WHERE ContentDocumentId IN: contentDocuments and (Document_Side_fileupload__c =: docSide OR Document_Side_fileupload__c = null OR Document_Side_fileupload__c = '')]){
                        contentDocumentsDeleted.add(new ContentDocument(id=conVer.ContentDocumentId));
                    }

                }
                if (Schema.sObjectType.ContentDocument.isAccessible() && Schema.sObjectType.ContentDocument.isDeletable() ){
                    Database.delete(new List<ContentDocument>(contentDocumentsDeleted), false);  
                    if(!docList.isEmpty()){
                        if(docSide == 'Front' || docSide == 'Selfie'){
                            docList[0].isFrontDocReplaced__c = true;
                        }else{
                            docList[0].isBackDocReplaced__c = true;
                        }
                        docList[0].Reupload_DateTime__c = DateTime.now();
                        update docList;
                    }
                }
            }
        } catch(Exception e){
            system.debug('Exception::'+e);
            ErrorLoggerUtil.logErrorEvent(' IND_LWC_CMURejectController ', ' deleteRelatedDocumentsOnUpload ', 'System.Label.Apex', e);
            throw new AuraHandledException('Something went wrong: '+ e.getMessage()); 
        }
    }  
    public static List<String> getFieldAPIName (String objectName, String fieldLabelString){
        SObjectType type = Schema.getGlobalDescribe().get(objectName);
        List<String> returnFieldApiNameList = new List<String>();
        Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        List<String> fieldLables = fieldLabelString.split(';');
        
        for(String strField:mfields.keySet()){
            SObjectField fl = mfields.get(strField);
            
            
            for(String fieldLabel: fieldLables){
                if(fieldLabel == fl.getDescribe().getlabel()){
                    returnFieldApiNameList.add(strField);
                }
            }           
        }
        return returnFieldApiNameList;
    }
    public class docFieldWrapper{
        @AuraEnabled
        public Documents__c document{get;set;}
        @AuraEnabled
        public List<String> editableFields{get;set;}
        @AuraEnabled
        public List<appFieldWrapper> appFieldList{get;set;}
    }

    @AuraEnabled
    public static Boolean checkPortalEnable() {
        try{
            User usr = [Select Id,Name,IsPortalEnabled from User where id=:UserInfo.getUserId()];
            Boolean isPortalEnabled = false;
            
            if(usr.IsPortalEnabled){
                isPortalEnabled = true;            
            }
            return isPortalEnabled;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_LWC_CMURejectController', 'checkPortalEnable', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }
    @AuraEnabled
    public static Case getLoanApplication(String caseId){
        try{
            List<Case> caseObj = [Select Id,Loan_Application__c,OwnerId,status,Loan_Application__r.LeadSource FROM Case where Id =: caseId LIMIT 1];//CISP-3718 //OLA-114
            If(caseObj.size() >0){
                return caseObj[0];
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_LWC_CMURejectController', 'getLoanApplication', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getContentDocument(String docId){
        try{
            Map<String,Object> mapData = new Map<String,Object>();
            List<ContentDocumentLink> contentDocumentsLinkList = new List<ContentDocumentLink>();
            List<ContentVersion> contentVersionList = new List<ContentVersion>();

            if (docId != null) {
                contentDocumentsLinkList = [select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink  where LinkedEntityId=:docId];
                System.debug('contentDocumentsLinkList:: ' + contentDocumentsLinkList);

                if(contentDocumentsLinkList.size()>0){
                    mapData.put('contentDocLink',contentDocumentsLinkList);
                    Set<Id> linkId = new Set<Id>();

                    for(ContentDocumentLink conDoc : contentDocumentsLinkList){
                        linkId.add(conDoc.ContentDocumentId);
                    }

                    contentVersionList = [select id,FileType,Document_Side_fileupload__c,ContentDocumentId from ContentVersion WHERE ContentDocumentId IN :linkId];
                    mapData.put('contentVersionList',contentVersionList);
                }  
            }

            if(contentDocumentsLinkList.size()>0){
                return JSON.serialize(mapData);
            }

            return null;
        } catch(Exception e){
            system.debug('Exception::'+e);
            ErrorLoggerUtil.logErrorEvent(' IND_LWC_CMURejectController ', ' getContentDocument ', 'System.Label.Apex', e);
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }  

    public static List<appFieldWrapper> getAppFieldList(Documents__c doc, String rejectionFields){
        List<appFieldWrapper> appFieldList = new List<appFieldWrapper>();
        List<String> fieldLables = rejectionFields.split(';');
        for(String fieldLabel: fieldLables){
            if(fieldLabel.contains('Father')){
                appFieldWrapper appFieldObj = new appFieldWrapper();
                appFieldObj.label = 'Father\'s Name';
                appFieldObj.value = doc.Applicant__r.Father_s_name__c;
                appFieldList.add(appFieldObj);
            }
            if(fieldLabel.contains('Mother')){
                appFieldWrapper appFieldObj = new appFieldWrapper();
                appFieldObj.label = 'Mother\'s Name';
                appFieldObj.value = doc.Applicant__r.Mother_s_name__c;
                appFieldList.add(appFieldObj);
            }
            if(fieldLabel.contains('Spouse')){
                appFieldWrapper appFieldObj = new appFieldWrapper();
                appFieldObj.label = 'Spouse Name';
                appFieldObj.value = doc.Applicant__r.Spouse_Name__c;
                appFieldList.add(appFieldObj);
            }
        }
        return appFieldList;
    }

    @AuraEnabled	
    public static void updateApplicantDetails(List<appFieldWrapper> appFieldList, String applicantId) {	
        try{
            Applicant__c Applicant = [Select Id,Father_s_name__c,Mother_s_name__c,Spouse_Name__c FROM Applicant__c where Id =: applicantId LIMIT 1];
            boolean updateApplicant = false;
            if(Applicant!=null){
                for (appFieldWrapper appfield : appFieldList) {
                    if(appfield.label.contains('Father')){
                        Applicant.Father_s_name__c = appfield.value;
                        updateApplicant = true;
                    }
                    if(appfield.label.contains('Mother')){
                        Applicant.Mother_s_name__c = appfield.value;
                        updateApplicant = true;
                    }
                    if(appfield.label.contains('Spouse')){
                        Applicant.Spouse_Name__c = appfield.value;
                        updateApplicant = true;
                    }
                }
                if(updateApplicant){
                    update Applicant;
                }
            }	
        }catch(Exception e){	
            ErrorLoggerUtil.logErrorEvent('IND_LWC_CMURejectController', 'updateApplicantDetails', System.Label.Apex, e, '');	
            throw new IND_Exception(e.getMessage());	
        }	
    }
    public class appFieldWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
    }

    //CISP-17565
    @AuraEnabled
    public static Boolean checkPanDocument(String documentId){
        try {
            List<Documents__C> documentList = [Select Id,Applicant__c,NSDL_Response__c,AadhaarSeedingStatus__c,NSDLPANStatus__c from Documents__c Where Id=:documentId WITH SECURITY_ENFORCED LIMIT 1];
            if(documentList.size() > 0){
                if((documentList[0].NSDL_Response__c == 'Existing and Valid PAN' || documentList[0].NSDL_Response__c == 'Existing and Valid' || documentList[0].NSDLPANStatus__c == 'E') && documentList[0].AadhaarSeedingStatus__c == 'Y'){
                    return true;
                }
                return false;
            }
            return false;

        } catch(Exception e){	
            ErrorLoggerUtil.logErrorEvent('IND_LWC_CMURejectController', 'checkPanDocument', System.Label.Apex, e, '');	
            throw new IND_Exception(e.getMessage());	
        }	
    }
}