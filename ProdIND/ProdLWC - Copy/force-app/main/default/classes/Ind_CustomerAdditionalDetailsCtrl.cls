/**
* @Name         Ind_CustomerAdditionalDetailsCtrl 
* @Author       Devanshu Gupta
* @Company      Persistent Systems
* @Description  This class contains all methods related to Additonal Details initiation
* Inputs:       None
* Test Class:   Ind_CustomerAdditionalDetailsCtrlTest
*/
public with sharing class Ind_CustomerAdditionalDetailsCtrl{

	@TestVisible	
    private static Boolean checkForException = false;
    private static String applicantNumber = 'Application_number__c';
    private static String journeyStage = 'Journey_Stage__c';
    private static String applicantId = 'applicantId';
    private static String currentAddress = 'currentAddress';
    private static String currentAddressDocumentType = 'currentAddressDocumentType';
    private static String permanentAddressDocumentType = 'permanentAddressDocumentType';
    private static String permanentAddress = 'permanentAddress';
    private static String isApplicantPresent = 'isApplicantPresent';
    private static String applicantName = 'name';//CISP-2757
    private static String productType  = 'productType';//CISP-2781
    private static String entityType  = 'entityType';//SFTRAC-308
    private static String isAddressDeclaration  = 'isAddressDeclaration';//CISP-2701
        
    /*
    * @Method:      getAddress
    * @Created by:  Devanshu Gupta
    * @Description: Method to information related to applicant
    * @Param:       String - opportunityId , String applicantType, String applicantId
    * @Return:      Map<String,Object>
    */    
    @AuraEnabled
    public static Map<String, Object> getAddress(String opportunityId, String applicantType, String applicantId) {
        try {
            Map<String,Object> applicantAddressDetails = new Map<String, Object>(); 
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if (Schema.sObjectType.Applicant__c.isAccessible() && Schema.sObjectType.Documents__c.isAccessible()) {
                applicantList = [SELECT Id, Name,Current_Same_As_Permanent__c,Permanent_Address_Not_Present__c, Applicant_Type__c,Opportunity__r.Application_number__c,Opportunity__r.Customer_Type__c, Opportunity__r.Product_Type__c,Journey_Stage__c,Is_Address_Declaration__c,Current_Address_Not_Present__c,Opportunity__r.LeadSource,//D2C Change //CISP-10087
                            (SELECT Id , Name, Document_Type__c, KYC_name__c , KYC_Address_Line_1__c, KYC_Address_Line_2__c , KYC_Pin_Code__c,
                                    KYC_City__c, KYC_District__c, KYC_State__c , Current_Residential_Address_Proof__c,
                                    Permanent_Residential_Address_Proof__c,Content_Document_Count__c ,Taluka__c,Taluka_Id__c,Landmark__c,Village__c,Applicant__r.Opportunity__r.Product_Type__c,Applicant__r.Opportunity__r.Customer_Type__c,Applicant__r.Applicant_Type__c,Applicant__r.Is_this_current_residence_cum_office__c FROM Documents__r WHERE Current_Residential_Address_Proof__c = true OR 
                                    Permanent_Residential_Address_Proof__c = true OR (Document_Type__c =: System.Label.GST_Cert AND Applicant__r.Opportunity__r.Product_Type__c =: System.Label.Tractor AND Permanent_Residential_Address_Proof__c = true))
                                    FROM Applicant__c WHERE Opportunity__c =: opportunityId AND Applicant_Type__c =: applicantType AND Id =: applicantId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1]; //CISP-2701
            }
            Map<String,String> documentTypeMap = new Map<String,String>();
            Schema.DescribeFieldResult objFieldDescribe = Documents__c.Document_Type__c.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
                if(!documentTypeMap.containsKey(objPickList.getValue())){
                    documentTypeMap.put(objPickList.getValue(), objPickList.getLabel());
                }
            }

            if(applicantList.size() > 0) {
                for(Applicant__c appLicantObj : applicantList) {
                    applicantAddressDetails.put(applicantNumber,appLicantObj.Opportunity__r.Application_number__c);
                    applicantAddressDetails.put('leadSource',appLicantObj.Opportunity__r.LeadSource);//D2C Change
                    applicantAddressDetails.put(journeyStage,appLicantObj.Journey_Stage__c);
                    applicantAddressDetails.put('applicantId',appLicantObj.Id);
                    applicantAddressDetails.put(applicantName,appLicantObj.Name);//CISP-2757
                    applicantAddressDetails.put(productType, appLicantObj.Opportunity__r.Product_Type__c);//CISP-2781
                    applicantAddressDetails.put(entityType, appLicantObj.Opportunity__r.Customer_Type__c);//SFTRAC-308
                    applicantAddressDetails.put(isAddressDeclaration, appLicantObj.Is_Address_Declaration__c);//CISP-2701
                    applicantAddressDetails.put('isPermanentAddressNotPresent',appLicantObj.Permanent_Address_Not_Present__c);//CISP-10087
                    applicantAddressDetails.put('isCurrentAddressNotPresent', appLicantObj.Current_Address_Not_Present__c);
                    applicantAddressDetails.put('isCurrentSameAsPermanent', appLicantObj.Current_Same_As_Permanent__c);
                    for(Documents__c docObj : appLicantObj.Documents__r) {
                        if(docObj.Document_Type__c == System.Label.GST_Cert && docObj.Permanent_Residential_Address_Proof__c == true){
                            applicantAddressDetails.put('isGSTUploaded',true);
                        }
                        if(docObj.Applicant__r.Is_this_current_residence_cum_office__c == true){
                            applicantAddressDetails.put('residenceCumOffice',true);
                        }
                        if((docObj.Current_Residential_Address_Proof__c != null && docObj.Current_Residential_Address_Proof__c == true && (docObj.Content_Document_Count__c != 0 || docObj.Document_Type__c == 'Address Declaration' || appLicantObj.Opportunity__r.LeadSource == 'D2C')) || (docObj.Applicant__r.Opportunity__r.Customer_Type__c == 'Non-Individual' && docObj.Applicant__r.Opportunity__r.Product_Type__c == System.Label.Tractor && docObj.Applicant__r.Applicant_Type__c == System.Label.Borrower && docObj.Applicant__r.Is_this_current_residence_cum_office__c == true)) {
                            applicantAddressDetails.put(currentAddress,docObj);
                            applicantAddressDetails.put('isCurrentAddressPresent',true); //SFTRAC-454
                            if(documentTypeMap.containsKey(docObj.Document_Type__c)){
                                applicantAddressDetails.put(currentAddressDocumentType,documentTypeMap.get(docObj.Document_Type__c));
                            }
                            if(appLicantObj.Current_Same_As_Permanent__c || (docObj.Applicant__r.Opportunity__r.Customer_Type__c == 'Non-Individual' && docObj.Applicant__r.Opportunity__r.Product_Type__c == System.Label.Tractor && docObj.Applicant__r.Applicant_Type__c == System.Label.Borrower && docObj.Applicant__r.Is_this_current_residence_cum_office__c == true)) {
                                applicantAddressDetails.put(permanentAddress,docObj);
                                if(documentTypeMap.containsKey(docObj.Document_Type__c)){
                                    applicantAddressDetails.put(permanentAddressDocumentType,documentTypeMap.get(docObj.Document_Type__c));
                                }                            
                            }
                        }
                        if((docObj.Permanent_Residential_Address_Proof__c != null && docObj.Permanent_Residential_Address_Proof__c == true && (docObj.Content_Document_Count__c != 0 || appLicantObj.Opportunity__r.LeadSource == 'D2C')) || (docObj.Document_Type__c == System.Label.GST_Cert && docObj.Applicant__r.Opportunity__r.Customer_Type__c == 'Non-Individual' && docObj.Applicant__r.Opportunity__r.Product_Type__c == System.Label.Tractor && docObj.Applicant__r.Applicant_Type__c == System.Label.Borrower && docObj.Permanent_Residential_Address_Proof__c == true)) {
                            applicantAddressDetails.put(permanentAddress,docObj);
                            if(documentTypeMap.containsKey(docObj.Document_Type__c)){
                                applicantAddressDetails.put(permanentAddressDocumentType,documentTypeMap.get(docObj.Document_Type__c));
                            }
                        }
                    }
                }
                applicantAddressDetails.put(isApplicantPresent, true);
            } else {
                applicantAddressDetails.put(isApplicantPresent, false);
            }
            
            if(Ind_CustomerAdditionalDetailsCtrl.checkForException) {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            
            return applicantAddressDetails;
            
        }catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_CustomerAdditionalDetailsCtrl', ' getAddress ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
        
    }

    /*
    * @Method:      saveDocumentData
    * @Created by:  Devanshu Gupta
    * @Description: Method to save document data of applicant
    * @Param:       String - addressData , String applicantId
    * @Return:      String
    */  
    @AuraEnabled
    public static string saveDocumentData(String addressData, String applicantId) {
        try {
            AddressWrapper currentAddressData = new AddressWrapper();
            if(addressData !=null) {
            
                currentAddressData = (AddressWrapper)JSON.deserialize(addressData, AddressWrapper.class);
                System.debug('the current data '+currentAddressData);
                System.debug('Other Doc Record Type Id::  '+currentAddressData.isDisabled);
                
                if(currentAddressData.isDisabled == false) {
                    System.debug('Getting Other Doc Record Type Id');
                    Id otherDocRecordTypeId =  Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get('Other_Documents').getRecordTypeId();
                    System.debug('Other Doc Record Type Id::  '+otherDocRecordTypeId);

                    Documents__c currentAddressDataDoc = new Documents__c (Applicant__c =applicantId ,
                                                                            Document_Type__c = currentAddressData.documentType , Opportunity_Relation__c = currentAddressData.loanId,
                                                                            KYC_Address_Line_1__c = currentAddressData.address1,
                                                                            KYC_Address_Line_2__c = currentAddressData.address2 ,
                                                                            KYC_Pin_Code__c=currentAddressData.pincode,
                                                                            KYC_City__c = currentAddressData.city,
                                                                            KYC_District__c = currentAddressData.district,
                                                                            KYC_State__c=currentAddressData.state,
                                                                            is_Active__c= true,
                                                                            Village__c=currentAddressData.village,
                                                                            Landmark__c=currentAddressData.landmark,
                                                                            Taluka__c=currentAddressData.talukaValue,Taluka_Id__c = currentAddressData.talukaId,
                                                                            Name=currentAddressData.name//CISP-3052
                                                                            );
                    
                    if(!String.isEmpty(currentAddressData.id)) {
                        currentAddressDataDoc.Id = currentAddressData.id;
                    }else{
                        currentAddressDataDoc.RecordTypeId = otherDocRecordTypeId;
                    }
                    
                    if(currentAddressData.isCurrentAddress) {
                        currentAddressDataDoc.Current_Residential_Address_Proof__c = true;
                    } else {
                        if(currentAddressData.residenceCumOffice == true){
                            currentAddressDataDoc.Current_Residential_Address_Proof__c = true;
                        }
                        currentAddressDataDoc.Permanent_Residential_Address_Proof__c =true;
                    }
                    Applicant__c appRecord = [SELECT Id,Opportunity__r.Customer_Type__c, Applicant_Type__c,Opportunity__r.Product_Type__c from Applicant__c Where Id=:applicantId LIMIT 1];
                    if(appRecord != null && appRecord.Opportunity__r.Customer_Type__c == 'Non-Individual' && appRecord.Opportunity__r.Product_Type__c == Label.Tractor && appRecord.Applicant_Type__c == Label.Borrower && currentAddressData.poaFlag == true){
                        currentAddressDataDoc.Proof_of_Address_POA__c = currentAddressData.poaFlag;
                    }

                    if(Schema.sObjectType.Documents__c.isCreateable() && Schema.sObjectType.Documents__c.isUpdateable()) {
                        upsert currentAddressDataDoc;
                    }

                    if(currentAddressData.residenceCumOffice == true){
                        Applicant__c appObj = new Applicant__c();
                        appObj.Id = applicantId;
                        appObj.Is_this_current_residence_cum_office__c = true;
                        update appObj;
                    }
                    
                    if(Ind_CustomerAdditionalDetailsCtrl.checkForException) {
                        throw new AuraHandledException(System.Label.ExceptionMessage);
                    }
                    return currentAddressDataDoc.Id;
                }
            }
            return applicantId;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_CustomerAdditionalDetailsCtrl', ' saveDocumentData ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }

    /*
    * @Method:      kycDelete
    * @Created by:  Devanshu Gupta
    * @Description: Method to delete contentDocumentData
    * @Param:       String documentId ,Boolean isDone , Boolean isCancel ,String contentDocumentData
    * @Return:      Geo_State_Masters__c List
    */
    @AuraEnabled
    public static void kycDelete(String documentId ,Boolean isDone , Boolean isCancel ,String contentDocumentData){
        try{
            if(documentId!=null){
                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                if(Schema.sObjectType.ContentDocumentLink.isAccessible()) {
                    contentDocumentLinkList =[SELECT id,contentdocumentid,linkedentity.name,linkedentityid FROM ContentDocumentLink WHERE linkedentityid =:documentId ];
                }
                
                System.debug('the document '+contentDocumentLinkList);
                List<id> docIdList = new List<id>();
                
                for(ContentDocumentLink cdl: contentDocumentLinkList){
                    docIdList.add(cdl.contentdocumentid);
                }
                
                List<ContentDocument> conDocList = new List<ContentDocument>();
                if(!docIdList.isEmpty()) {
                    if(Schema.sObjectType.ContentDocument.isAccessible()) {
                    conDocList =[SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id IN: docIdList];
                    }
                }
                
                System.debug('the document con '+conDocList);
                List<ContentDocument> conDocumentToDelete = new List<ContentDocument>();
                system.debug(ConDocList);
                Id contentDocumentDataId = String.isNotBlank(contentDocumentData)? Id.valueOf(contentDocumentData):null;
                if(!conDocList.isEmpty()) {
                    if(isCancel) {
                        System.debug('the document cancel');
                        for(ContentDocument conDoc : conDocList) {
                            if(conDoc.Id == contentDocumentDataId) {
                                conDocumentToDelete.add(conDoc);
                                System.debug('for 195 document '+conDocumentToDelete);
                            }
                        }
                        
                        if(!conDocumentToDelete.isEmpty()) {
                        System.debug('for cancel delete the document '+conDocumentToDelete);
                        List<Documents__c>lstdocuments = [Select Id From Documents__c Where Id =: documentId ];
                            System.debug('deleting the document '+lstdocuments);
                            delete lstdocuments;
                            delete conDocumentToDelete;
                        }
                    }
                    if(isDone) {
                        System.debug('the document done');
                        for(ContentDocument conDoc : conDocList) {
                            if(conDoc.Id != contentDocumentDataId) {
                                conDocumentToDelete.add(conDoc);
                            }
                        }
                        
                        if(!conDocumentToDelete.isEmpty()) {
                            System.debug('for done delete the document '+conDocumentToDelete);
                            delete conDocumentToDelete;
                        }
                    }
                }
                if(Ind_CustomerAdditionalDetailsCtrl.checkForException) {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_CustomerAdditionalDetailsCtrl', ' kycDelete ', System.Label.Apex, e);
        }
    }

  /*
    * @Method:      fetchDocument
    * @Created by:  Ruchi Jain
    * @Description: Method to check for image
    * @Param:       String documentId 
    * @Return:     Boolean
    */
    @AuraEnabled
    public static Boolean fetchDocument(String documentId ){
        try{
            if(documentId != null){
                List<Documents__c> doc = [select Aadhar_Source__c, KYC_No__c from Documents__c where Id =: documentId];
                if(!doc.isEmpty() && (doc[0].Aadhar_Source__c == 'OTP' || doc[0].Aadhar_Source__c == 'Biometric')){
                    if(doc[0].KYC_No__c != null){
                        return true;
                    }
                    return false;
                }
                else{
                    Set<Id> docIdSet = new Set<Id>();
                    for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: documentId WITH SECURITY_ENFORCED]){
                        docIdSet.add(contentdoc.ContentDocumentId);
                    }
                    List<ContentVersion> cv=[SELECT Id from Contentversion where ContentDocumentId IN : docIdSet WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC ];
                    System.debug('here1 '+cv.size());
                    if(!cv.isEmpty() && cv.size()>0){
                        return true;
                    } else {
                        return false;
                    }
                }
               
            } else {
                System.debug('here2 '+documentId);
                return false;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'fetchDocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }   

    public class AddressWrapper {
        public String id { get; set; }
        public String name { get; set; }
        public String loanId { get; set; }
        public String documentType { get; set; }
        public String address1 { get; set; }
        public String address2  { get; set; }
        public String pincode { get; set; }
        public String city { get; set; }
        public String district { get; set; }
        public String state { get; set; }
        public Boolean isDisabled { get; set; }
        public Boolean isCurrentAddress { get; set; }
        public String village { get; set; }
        public String landmark { get; set; }
        public String taluka { get; set; }
        public Boolean residenceCumOffice { get; set; }
        public Boolean poaFlag { get; set; }
        public string talukaValue {get;set;} //SFTRAC-1660
        public string talukaId {get;set;}   //SFTRAC-1660
    }

    @AuraEnabled
    public static String getUploadDocument(String applicantId, String docType){
        try{
            if(String.isNotBlank(applicantId)){
                Documents__c doc = [Select Id from Documents__c where Applicant__c =: applicantId And Document_Type__c=:docType WITH SECURITY_ENFORCED limit 1];
                    return doc.Id;
            }
            return null;
        }catch(Exception e){
            System.debug('error '+e.getMessage()+' line '+e.getLineNumber());
            return null;
        }
    }
}