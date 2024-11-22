/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is controller class for DSA related functionalities
Test Class:    
History
Date            Author              Comments 
-------------------------------------------------------------
11-07-2022      Rohan Saxena         Created 
------------------------------------------------------------*/
public with sharing class IND_DSAController {
    static DSA_WSController wsController;
    public static DSA_WSController getWSControllerInstance() {
        if (wsController == null) {
            wsController = new DSA_WSController();
        }
        return wsController;
    }

    /*
     * @Method:      uploadDocumentCntrl
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static String uploadDocumentCntrl(
        String docType,
        Id loanApplication,
        Id applicant,
        Boolean active,
        string contentDocId,
        String userId
    ) {
        try {
            Id docId, contentdoc, existDocId;
            Id RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName()
                .get(IND_Constant.DSA_DOCUMENTS)
                .getRecordTypeId();
            Documents__c[] arrexistDoc = [
                SELECT Id, CreatedById
                FROM Documents__c
                WHERE
                    Opportunity_Relation__c = :loanApplication
                    AND Applicant__c = :applicant
                    AND Document_Type__c = :docType
                AND Name = :docType  WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (arrexistDoc.size() > 0 && userId == arrexistDoc[0].CreatedById) {
                existDocId = arrexistDoc[0].Id;
            } else if (arrexistDoc.size() > 0 && userId != arrexistDoc[0].CreatedById) {
                return IND_Constant.NOT_AUTHORIZED;
            }

            if (existDocId == null) {
                docId = createdocument(docType, loanApplication, applicant, active, RecordTypeId);
                contentdoc = createContentDocumentLink(docId, contentDocId, 'I');
            } else {
                deleteDocAndFile(existDocId, false);
                contentdoc = createContentDocumentLink(existDocId, contentDocId, 'I');
            }
            return 'success';
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DSAController', 'createdocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
     * @Method:      deleteDocument&file
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    public static void deleteDocAndFile(String docId, boolean deleteDoc) {
        try {
            Documents__c objDocument = [SELECT id FROM Documents__c WHERE Id = :docId];
            ContentDocumentLink objContentDocLink = [
                SELECT id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :docId
                LIMIT 1
            ];
            List<ContentDocument> lstContentDoc = [
                SELECT id
                FROM ContentDocument
                WHERE Id = :objContentDocLink.ContentDocumentId
            ];
            if (objDocument != null && deleteDoc == true) {
                if (Schema.sObjectType.Documents__c.isAccessible()) {
                    delete objDocument;
                }
            }
            if (!lstContentDoc.isEmpty()) {
                delete lstContentDoc;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DSAController', 'deleteDocAndFile', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
     * @Method:      deleteDocument&file
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */ @AuraEnabled
    public static String deleteContentDocument(
        Id loanApplication,
        Id applicant,
        String DocType,
        String userId
    ) {
        try {
        Id DocumentId;
            Documents__c[] arrDocument = getDocumentList(loanApplication,applicant,DocType);
        if (arrDocument.size() > 0 && arrDocument[0].CreatedById == userId) {
            DocumentId = arrDocument[0].Id;
            deleteDocAndFile(DocumentId, true);
            return 'Deleted';
        } else if (arrDocument.size() > 0 && arrDocument[0].CreatedById != userId) {
            return 'Not Authorized';
        } 
            return 'no data';
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'IND_DSAController',
                'deleteContentDocument',
                '',
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
    }
    }
    
    /*
     * @Method:      createdocument
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    public static Documents__c[] getDocumentList(Id loanApplication,Id applicant,String DocType){
        return  [
            SELECT Id, CreatedById
            FROM Documents__c
            WHERE
            Applicant__c = :applicant
            AND Opportunity_Relation__c = :loanApplication
            AND Document_Type__c = :DocType
            AND Name = :DocType WITH SECURITY_ENFORCED
            ORDER BY CreatedDate desc];
    }
    
    /*
     * @Method:      createdocument
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    public static Id createdocument(
        String docType,
        Id loanApplication,
        Id applicant,
        Boolean active,
        String recordTypeId
    ) {
        try {
            Documents__c objDocument = new Documents__c();
            objDocument.Document_Type__c = docType;
            objDocument.Opportunity_Relation__c = loanApplication;
            objDocument.Applicant__c = applicant;
            objDocument.RecordTypeId = recordTypeId;
            objDocument.name = docType;
            objDocument.is_Active__c = active;
            Database.SaveResult srList;
            if (Schema.sObjectType.Documents__c.isCreateable()) {
             srList = database.insert(objDocument);
            }
            return srList.getId();
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DSAController', 'createdocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
     * @Method:      createContentDocumentLink
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    public static Id createContentDocumentLink(Id docId, Id contentdocId, String ShareType) {
        try {
            ContentDocumentLink objdoclink = new ContentDocumentLink();
            objdoclink.LinkedEntityId = docId;
            objdoclink.ContentDocumentId = contentdocId;
            objdoclink.ShareType = ShareType;
            Database.SaveResult srList = database.insert(objdoclink);
            return srList.getId();
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'IND_DSAController',
                'createContentDocumentLink',
                'Apex',
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
     * @Method:      getDocumentDetails
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */ @AuraEnabled
    public static String getDocumentDetails(Id loanApplication, Id applicant, String DocType) {
        try {
        ContentDocumentLink[] contentDoc;
        Id DocumentId;
        Documents__c[] arrDocument = getDocumentList(loanApplication,applicant,DocType);
            DocumentId = arrDocument.size() > 0 ? arrDocument[0].Id : null;
        
        if (DocumentId != null) {
            contentDoc = [
                SELECT Id, LinkedEntityId, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :DocumentId
                ORDER BY systemmodstamp DESC
                LIMIT 1
            ];
            if (contentDoc.size() > 0) {
                return contentDoc[0].ContentDocumentId;
            } 
                return 'no data';
            
        } else {
            return 'no data';
        }
         } catch (Exception e) {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
     * @Method:      getContentVersion
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static List<ContentVersion> getContentVersion(
        Id loanApplication,
        Id applicant,
        String DocType
    ) {
        try {
            List<ContentVersion> conVerList;
            String conDocId = IND_DSAController.getDocumentDetails(
                loanApplication,
                applicant,
                DocType
            );
            if (conDocId != 'no data') {
                conVerList = [
                    SELECT
                        Id,
                        VersionData,
                        FileType,
                        Title,
                        FileExtension,
                        IsLatest,
                        ContentDocumentId,
                        ContentDocument.FileType
                    FROM ContentVersion
                    WHERE ContentDocumentId = :conDocId AND IsLatest = TRUE
                ];
                if (conVerList.size() > 0) {
                    return conVerList;
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'IND_DSAController',
                'getContentVersion',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
     * @Method:      getContentVersion
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static String getDcoumentRecords(Id loanApplication, Id applicant) {
        String DocumentNames = '';
        List<Documents__c> arrDocument = [
            SELECT Id, Document_Type__c
            FROM Documents__c
            WHERE Applicant__c = :applicant AND Opportunity_Relation__c = :loanApplication WITH SECURITY_ENFORCED
            ORDER BY Createddate DESC
            LIMIT 50000
        ];
        for (Documents__c doc : arrDocument) {
            DocumentNames = DocumentNames + ' ' + doc.Document_Type__c;
        }
        return DocumentNames;
    }
    /*
     * @Method:      createCoborrowerScreening
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static void createCoborrowerScreening(Id loanApplication, Id applicant, String income) {
        List<Applicant__c> lstExistingApplicant = new List<Applicant__c>();
        try {
            for (Applicant__c objapplicant : [
                SELECT id, In_Active_Applicant__c, Who_will_repay_the_loan__c, Applicant_Type__c
                FROM Applicant__c
                WHERE Opportunity__c = :loanApplication WITH SECURITY_ENFORCED
            ]) {
                if (objapplicant.Applicant_Type__c == 'Co-borrower') {
                    objapplicant.In_Active_Applicant__c = true;
                }
                if (objapplicant.Applicant_Type__c == 'Borrower') {
                    objapplicant.Who_will_repay_the_loan__c = 'Co-borrower';
                }
                lstExistingApplicant.add(objapplicant);
            } if(Schema.sObjectType.Applicant__c.isUpdateable()){
            update lstExistingApplicant;
            }

            Documents__c doc = [
                SELECT
                    KYC_DOB__c,
                    Opportunity_Relation__c,
                    PAN_No__c,
                    Gender__c,
                    KYC_Address_Line_1__c,
                    KYC_Address_Line_2__c,
                    KYC_City__c,
                    KYC_State__c,
                    KYC_Pin_Code__c,
                    Salutation__c,
                    KYC_name__c,
                    Applicant__r.Contact_number__c,
                    Applicant__r.Customer_First_Name__c,
                    Applicant__r.Customer_Last_Name__c
                FROM Documents__c
                WHERE Applicant__c = :applicant
                LIMIT 1
            ];
            Income_Details__c appIncomeDetails = [
                SELECT Id, Applicant__c, Income__c, Profile__c
                FROM Income_Details__c
                WHERE Applicant__r.Opportunity__c = :doc.Opportunity_Relation__c
                LIMIT 1
            ];

            Applicant__c objApplicant = new Applicant__c();
            objApplicant.Opportunity__c = loanApplication;
            objApplicant.Income_Source__c = 'Earning';
            objApplicant.Declared_income__c = Decimal.ValueOf(income);
            objApplicant.Contact_number__c = doc.Applicant__r.Contact_number__c;
            objApplicant.PAN_No__c = doc.PAN_No__c;
            objApplicant.Applicant_Type__c = 'Co-borrower';
            objApplicant.Journey_Stage__c = System.Label.userDetails;
            objApplicant.Customer_First_Name__c = doc.Applicant__r.Customer_First_Name__c;
            objApplicant.Customer_Last_Name__c = doc.Applicant__r.Customer_Last_Name__c;
            objApplicant.Income_source_available__c = true;
            if(Schema.sObjectType.Applicant__c.isCreateable()){
            insert objApplicant;
            }

            Documents__c objdocument = new Documents__c();
            objdocument.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            objdocument.KYC_DOB__c = doc.KYC_DOB__c;
            objdocument.is_Active__c = true;
            objdocument.Proof_of_Identity_POI__c = true;
            objdocument.Name = 'PAN';
            objdocument.Document_Type__c = 'PAN';
            objdocument.PAN_No__c =IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
            objdocument.Applicant__c = objApplicant.Id;
            objdocument.Gender__c = doc.Gender__c;
            objdocument.KYC_Address_Line_1__c = doc.KYC_Address_Line_1__c;
            objdocument.KYC_Address_Line_2__c = doc.KYC_Address_Line_2__c;
            objdocument.KYC_City__c = doc.KYC_City__c;
            objdocument.KYC_State__c = doc.KYC_State__c;
            objdocument.KYC_Pin_Code__c = doc.KYC_Pin_Code__c;
            objdocument.Salutation__c = doc.Salutation__c;
            objdocument.KYC_name__c = doc.KYC_name__c;
            objdocument.Opportunity_Relation__c = loanApplication;
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert objdocument;
            }
            Income_Details__c incomeDetails = new Income_Details__c();
            incomeDetails.Applicant__c = objApplicant.Id;
            incomeDetails.Income__c = Decimal.ValueOf(income);
            incomeDetails.Profile__c = appIncomeDetails.Profile__c;
            if(Schema.sObjectType.Income_Details__c.isCreateable()){
                insert incomeDetails;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'IND_DSAController',
                'createCoborrowerScreening',
                'Apex',
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
     * @Method:      getApplicantDetails
     * @Created by:  Rohan Saxena
     * @Description:
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static List<Applicant__c> getApplicantDetails(String loanId) {
        return [
            SELECT id, Applicant_Type__c, Opportunity__r.DSA_Stage__c
            FROM Applicant__c
            WHERE
                opportunity__c = :loanId
                AND In_Active_Applicant__c = FALSE
                AND Applicant_Type__c = 'Co-borrower' 
        ];
    }
    /*
     * @Method:      initializeNewLeadData
     * @Created by:  Swapnil Prajapati
     * @Description: Creates a new Opportunity and returns it
     * @Param:
     * @Return: DSA_NewLeadWrapper:initializeNewLeadData
     */
    @AuraEnabled
    public static DSA_NewLeadWrapper initializeNewLeadData() {
        try {
            if (Schema.sObjectType.Opportunity.isCreateable()) {
                Opportunity opp = createLoanApplication();
                return new DSA_NewLeadWrapper(opp, new Applicant__c());
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'DSA_CreateNewLeadController',
                'initializeNewLeadData',
                'Apex',
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
     * @Method:      createLoanApplication
     * @Created by:  Swapnil Prajapati
     * @Description: Creates a new Opportunity and returns it
     * @Param:
     * @Return: Opportunity opp
     */
    public static Opportunity createLoanApplication() {
        try {
            User objDSA = [
                SELECT Id, EmployeeNumber
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            List<Beneficiary_BlCode__c> objBenef = getWSControllerInstance()
                .getBenefBlCode(objDSA.EmployeeNumber);
            //temName to be used to replace it with Lead Number as Name in trigger-generateUniqueLeadNumber
            String tempName = 'TempName';
            //String uniqueLeadNumber = Utilities.generateUniqueLeadNumber();
            Opportunity opp = new Opportunity(
                Name = tempName,
                StageName = 'Loan Initiation',
                CloseDate = System.today().addMonths(1),
                Sub_Stage__c = 'User Details',
                LastStageName__c = 'Loan Initiation',
                Product_Type__c = 'Passenger Vehicles',
                Vehicle_Type__c = 'Used',
                LeadSource = 'DSA',
                Agent_BL_code__c = objBenef.isEmpty()
                    ? ''
                    : objBenef[0].Bl_Code_Details__r?.Bl_Code__c
            );
            insert opp;
            SET<ID> oppIdSet = new Set<ID>{ opp.Id };
            UniqueLeadNumberHandler.updateLeadSeqNumber(oppIdSet);
            opp = [
                SELECT
                    Id,
                    Name,
                    Lead_number__c,
                    StageName,
                    CloseDate,
                    Sub_Stage__c,
                    LastStageName__c,
                    Product_Type__c,
                    Vehicle_Type__c
                FROM Opportunity
                WHERE Id = :opp.Id
                LIMIT 1
            ];
            return opp;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DSAController', 'createLoanApplication', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
     * @Method:      getLoanByRecordId
     * @Created by:  Swapnil Prajapati
     * @Description: Retrieves existing loan application and related details
     * @Param:
     * @Return: DSA_NewLeadWrapper
     */
    @AuraEnabled
    public static DSA_NewLeadWrapper getLoanByRecordId(String recordId) {
        return getWSControllerInstance().getLoanByRecordId(recordId);
    }
	
     /*
     * @Method:      GetBEDetails
     * @Created by:  Rohan Saxena
     * @Description: Retrieves BE Users for BE transfer logic.
     * @Param:
     * @Return: Map<Id,String>
     */
    @AuraEnabled
    public static Map<Id,String> GetBEDetails(String userId, String ApplicantId) {
        return getWSControllerInstance().GetBEDetails(userId,ApplicantId);
    }
    
    /*
     * @Method:      getIncomeDetailsByRecordId
     * @Created by:  Swapnil Prajapati
     * @Description: Retrieves existing loan application and related details
     * @Param:
     * @Return: DSA_NewLeadWrapper
     */
    @AuraEnabled
    public static List<Applicant__c> getIncomeDetailsByRecordId(String recordId) {
        return [
            SELECT
                Id,
                Applicant_Type__c,
                Income_Ca__c,
                Income_Source__c,
                DSA_DOB__c,
                (SELECT Id, Income__c, Profile__c, Profile__r.Name FROM Income_Details__r),
                (SELECT Id, EMI__c FROM Existing_EMIs__r)
            FROM Applicant__c
            WHERE Opportunity__c = :recordId AND In_Active_Applicant__c = FALSE ORDER BY LastModifiedDate DESC
        ];
    }

    /*
     * @Method:      getAssetDetailsByRecordId
     * @Created by:  Swapnil Prajapati
     * @Description: Retrieves existing loan application and related details
     * @Param:
     * @Return: DSA_NewLeadWrapper
     */
    @AuraEnabled
    public static Opportunity getAssetDetailsByRecordId(String recordId) {
         //SFD2C-161
        return [
            SELECT
                Id,
                Required_Loan_amount__c,
                (
                    SELECT Id, Loan_Application__c, Make__c, Model__c, Variant__c, Base_Price__c,Make_Code__c,Model_Code__c,Variant_Code__c
                    FROM Vehicle_Details__r
                )
            FROM Opportunity
            WHERE Id = :recordId
        ];
    }
    /*
     * @Method:      getOfferDetailsByRecordId
     * @Created by:  Swapnil Prajapati
     * @Description: Retrieves existing loan application and related details
     * @Param:
     * @Return: DSA_NewLeadWrapper
     */
    @AuraEnabled
    public static Opportunity getOfferDetailsByRecordId(String recordId) {
        return [
            SELECT
                Id,
                (
                    SELECT Id, Loan_Amount__c, Tenure__c, CRM_IRR__c, EMI_Amount__c
                    FROM Final_Terms__r
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                )
            FROM Opportunity
            WHERE Id = :recordId
        ];
    }
@AuraEnabled
public static Documents__c getDocumentdetailsByRecordId(String recordId) {
List<Documents__c> doc= [SELECT Id,KYC_DOB__c,Gender__c from Documents__c where Applicant__r.Opportunity__c=: recordId AND Document_Type__c='PAN' Limit 1];
if(!doc.isEmpty()){
return doc[0];
}
else{
return null;
}
}
    /*
     * @Method:      saveLead
     * @Created by:  Swapnil Prajapati
     * @Description: Saves new lead data from the DSA community
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static String saveLead(String dataWrapperJSON) {
        system.debug('reached saveLead Apex');
        DSA_NewLeadWrapper dataWrapper = (DSA_NewLeadWrapper) JSON.deserialize(
            dataWrapperJSON,
            DSA_NewLeadWrapper.class
        );
        Applicant__c applicant;
        Opportunity opp;
        //Insert applicant
        applicant = dataWrapper.applicant;
        opp = dataWrapper.opp;
        opp.Applicant_Name__c = applicant.Name;
        opp.Customer_Last_Name__c = applicant.Customer_Last_Name__c;
        update opp;
        if (
            Schema.sObjectType.Applicant__c.isCreateable() &&
            Schema.sObjectType.Applicant__c.isUpdateable()
        ) {
            upsert applicant;
        }
        return applicant.Id;
    }

    /*
     * @Method:      getRetryCount
     * @Created by:  Swapnil Prajapati
     * @Description: Gets retry count and max retries for dedupe API
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static String getRetryCount(
        String loanApplicationId,
        String applicantType,
        String countfieldName,
        String metadataAttemptsField
    ) {
        Decimal retryCount = Utilities.getRetryCount(
            loanApplicationId,
            applicantType,
            countfieldName,
            metadataAttemptsField
        );
        Decimal externalDedupeAPIMaxAttempts = System_Constant_custom_metadata__mdt.getInstance(
                'Customer_Dedupe_Attempts'
            )
            .Number_Of_Attempts__c;
        return JSON.serialize(
            new Map<String, Decimal>{
                'retryCount' => retryCount,
                'externalDedupeAPIMaxAttempts' => externalDedupeAPIMaxAttempts
            }
        );
    }

    /*
     * @Method:      getRCLimitData
     * @Created by:  Swapnil Prajapati
     * @Description: Gets RC Limit data for DSA dashboard
     * @Param:
     * @Return:
     */
    //prettier-ignore
    @AuraEnabled
    public static Map<String, String> getRCLimitData() {
        return getWSControllerInstance()
        .getRCLimitData();
    }
    /*
     * @Method:      createCoBorrower
     * @Created by:  Haarika Chodisetti
     * @Description: creates a Co-borrower record
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static String createCoBorrower(Id borrowerId, Id coborrowerId, List<string> fields) {
        system.debug('reached createCoBorrower');
        try {
            Applicant__c borr = [
                SELECT
                    Id,
                    Opportunity__c,
                    Contact_number__c,
                    PAN_No__c,
                    Customer_First_Name__c,
                    Customer_Last_Name__c
                FROM Applicant__c
                WHERE Id = :borrowerId
            ];
            Documents__c doc = [
                SELECT
                    KYC_DOB__c,
                    Opportunity_Relation__c,
                    PAN_No__c,
                    Gender__c,
                    KYC_Address_Line_1__c,
                    KYC_Address_Line_2__c,
                    KYC_City__c,
                    KYC_State__c,
                    KYC_Pin_Code__c,
                    Salutation__c,
                    KYC_name__c
                FROM Documents__c
                WHERE Applicant__c = :borrowerId
            ];
            Applicant__c coBor = new Applicant__c(
                Id = coborrowerId,
                Opportunity__c = borr.Opportunity__c,
                Income_Source__c = 'Earning',
                Income_Ca__c = fields[1],
                Profile__c = fields[2],
                Declared_income__c = String.isNotBlank(fields[3])
                    ? Decimal.ValueOf(fields[3])
                    : null,
                Contact_number__c = borr.Contact_number__c,
                PAN_No__c = borr.PAN_No__c,
                Applicant_Type__c = 'Co-borrower',
                Journey_Stage__c = System.Label.userDetails,
                Customer_First_Name__c = borr.Customer_First_Name__c,
                Customer_Last_Name__c = borr.Customer_Last_Name__c,
                Income_source_available__c= true
            );
            if (
                Schema.sObjectType.Applicant__c.isCreateable() &&
                Schema.sObjectType.Applicant__c.isUpdateable()
            ) {
                upsert coBor;
            }
            Documents__c coBorrDoc = new Documents__c(
                KYC_DOB__c = doc.KYC_DOB__c,
                Applicant__c = coBor.Id,
                Name = 'PAN',
                Document_Type__c = 'PAN',
                PAN_No__c = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey),
                Gender__c = doc.Gender__c,
                KYC_Address_Line_2__c = doc.KYC_Address_Line_2__c,
                KYC_Address_Line_1__c = doc.KYC_Address_Line_1__c,
                KYC_City__c = doc.KYC_City__c,
                KYC_State__c = doc.KYC_State__c,
                KYC_Pin_Code__c = doc.KYC_Pin_Code__c,
                Salutation__c = doc.Salutation__c,
                KYC_name__c = doc.KYC_name__c,
                Opportunity_Relation__c = doc.Opportunity_Relation__c
            );
            if (Schema.sObjectType.Documents__c.isCreateable()) {
                insert coBorrDoc;
            }
            system.debug('inserted in createCoBorrower');
            return coBor.Id;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_DSAController', 'createCoBorrower', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
     * @Method:      saveExistingEMIDetails
     * @Created by:  Haarika Chodisetti
     * @Description: creates an income details record
     * @Param:
     * @Return:
     
    @AuraEnabled
    public static void saveExistingEMIDetails(String applicantId, Integer emi) {
        system.debug('reached saveExistingEMIDetails : ' + applicantId);
        Existing_EMI__c exem = new Existing_EMI__c(
            Applicant_Id__c = applicantId,
            EMI__c = Decimal.ValueOf(emi)
        );
        //String incomeSource = fields[1];
        if (Schema.sObjectType.Existing_EMI__c.isCreateable()) {
            insert exem;
        }
        system.debug('inserted in saveExistingEMIDetails : ' + exem.Id);
    }*/

    /*
     * @Method:      saveAssetDetails
     * @Created by:  Haarika Chodisetti
     * @Description: creates an Asset details record
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static void saveAssetDetails(
        String applicantId,
        String assetDetailId,
        List<string> fields
    ) {
        String VehicleId = assetDetailId;
        Applicant__c borr = [
            SELECT Opportunity__c, Contact_number__c
            FROM Applicant__c
            WHERE Id = :applicantId
        ];
        opportunity opp = [
            SELECT Id, Required_Loan_amount__c, Loan_amount__c
            FROM opportunity
            WHERE Id = :borr.Opportunity__c
        ];
        List<Vehicle_Detail__c> lstvehicle= [
            SELECT Id from Vehicle_Detail__c where Loan_Application__c=:opp.Id limit 1
        ];
        if(!lstvehicle.isEmpty()){
            VehicleId = lstvehicle[0].Id;
        }
        Vehicle_Detail__c asset = new Vehicle_Detail__c(
            Id = VehicleId,
            Loan_Application__c = borr.Opportunity__c,
            Make__c = fields.size() > 0 ? fields[0] : '',
            Model__c = fields.size() > 1 ? fields[1] : '',
            Variant__c = fields.size() > 2 ? fields[2] : '',
            Base_Price__c = fields.size() > 3 ? (String.isNotBlank(fields[3]) ? Decimal.ValueOf(fields[3]) : null) : null,
            Make_Code__c= fields.size() > 5 ? fields[5] : '',  //SFD2C-161
            Model_Code__c= fields.size() > 6 ? fields[6] : '',  //SFD2C-161
            Variant_Code__c= String.isNotBlank(fields[7]) ? fields[7] : ''  //SFD2C-161
        );
        if (
            Schema.sObjectType.Vehicle_Detail__c.isCreateable() &&
            Schema.sObjectType.Vehicle_Detail__c.isUpdateable()
        ) {
            upsert asset;
        }
        opp.Required_Loan_amount__c = String.isNotBlank(fields[4])
            ? Decimal.ValueOf(fields[4])
            : null;
        opp.Loan_amount__c = fields[4];
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            update opp;
        }
        system.debug('inserted in vehicleDetails : ' + asset.Id);
        system.debug('Updated opp : ' + opp.Id);
    }

    /*
     * @Method:      getProducts
     * @Created by:  Swapnil Prajapati
     * @Description: Retrieves product makes
     * @Param:
     * @Return:
     */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(String type, String parentId) {
        List<Product2> prodList = new List<Product2>();
        Set<Id> makeIdSet = new Set<Id>();
        Set<Id> modelIdSet = new Set<Id>();
        if(type == 'Make' || type == 'Model'){
            for(Product2 prod : [SELECT Parent_Product__c, Parent_Product__r.Parent_Product__c FROM Product2 WHERE Type__c = 'Variant' AND IsActive = TRUE]){
                makeIdSet.add(prod.Parent_Product__r.Parent_Product__c);
                modelIdSet.add(prod.Parent_Product__c);
            }
        }
         //SFD2C-161
        String query = 'SELECT Id, Name, Make_Code__c,Model_Code__c ,Variant_Code__c,Type__c FROM Product2 WHERE Type__c = :type AND IsActive = TRUE';
        if(type == 'Make'){
            query += ' AND Parent_Product__r.Name = \'PASSENGER VEHICLE\'';
            query += ' AND Id IN: makeIdSet';
        }else if(type == 'Model'){
            query += ' AND Parent_Product__c = :parentId AND Id IN: modelIdSet';
        }else{
            query += ' AND Parent_Product__c = :parentId';
        }
        system.debug('query'+query);
        if (Schema.SObjectType.Product2.isAccessible()) {
            for (Product2 prod : Database.query(query)) {
                prodList.add(prod);
            }
            system.debug('prod1'+prodList);
        }
        return prodList;
    }

    /*
     * @Method:      getAssetFieldValues
     * @Created by:  Haarika Chodisetti
     * @Description: Retrieves values for Asset Screen fields
     * @Param:
     * @Return:
     */
    // @AuraEnabled(cacheable=true)
    // public static List<String> getAssetFieldValues(
    //     String makeCode,
    //     string modelCode
    // ) {
    //     system.debug('Reached');
    //     String field = 'Make_Code__c';
    //     String sQuery;
    //     String whereClause = '';
    //     Set<String> resultSet = new Set<String>();
    //     List<String> result = new List<String>();
    //     if (!String.isBlank(makeCode)) {
    //         field = 'Model_Code__c';
    //         if (!String.isBlank(modelCode)) {
    //             field = 'Variant_Code__c';
    //             whereClause =
    //                 ' AND Parent_Product__r.Parent_Product__r.Make_Code__c =: makeCode' +
    //                 +' AND Parent_Product__r.Model_Code__c =: modelCode';
    //         } else {
    //             whereClause = ' AND Parent_Product__r.Make_Code__c =: makeCode';
    //         }
    //     }
    //     sQuery =
    //         'SELECT ' +
    //         field +
    //         ' FROM Product2 WHERE ' +
    //         field +
    //         ' != null ' +
    //         whereClause;

    //     for (Product2 prod : Database.query(sQuery)) {
    //         resultSet.add((String) prod.get(field));
    //     }
    //     return new List<String>(resultSet);
    // }

    /*
     * @Method:      getStateCityData
     * @Created by:  Swapnil Prajapati
     * @Description: Retrieves state and related cities from Master data
     * @Param:
     * @Return:
     */
    @AuraEnabled(cacheable=true)
    public static List<Geo_State_Masters__c> getStateCityMaster() {
        try {
            List<Geo_State_Masters__c> listOfStateValue = new List<Geo_State_Masters__c>();
            if (Schema.sObjectType.Geo_State_Masters__c.isAccessible()) {
                listOfStateValue = getWSControllerInstance().getStateCityMaster();
            }
            return listOfStateValue;
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /* @Method:     getProfile
     * @Created by:  Swapnil Prajapati
     * @Description: Method to get profile according to category
     * @Param:       String - category
     * @Return:      List of Profile Master
     */
    @AuraEnabled(cacheable=true)
    public static List<Profile_Master__c> getProfile(String category) {
        try {
            List<Profile_Master__c> profileList = new List<Profile_Master__c>();
            List<String> categoryList = new List<String>();
            //DSA new changes bug fix
            if (category == 'SAL') {
                categoryList.add(category);
            } else if(category == 'SEP'){
                categoryList.add(category);
            }
            else if(category == 'SENP'){
                categoryList.add(category);
            }
            if (Schema.sObjectType.Profile_Master__c.isAccessible()) {
                profileList = [
                    SELECT Id, Name, Code__c, Category__c
                    FROM Profile_Master__c
                    WHERE Category__c IN :categoryList
                    WITH SECURITY_ENFORCED
                ];
            }
            return profileList;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'IND_DSAController',
                ' getProfile ',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static String assignToBE(String loanId,String UserId) {
        try {
            if (Schema.sObjectType.Opportunity.isUpdateable()) {
                return getWSControllerInstance().dsaToBEAssignment(loanId,UserId);
            }
            return '';
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    // prettier-ignore
    @AuraEnabled
    public static String validateCustomerCode(Id applicantId, Boolean ruleIdCustomerTypeMatch) {
        Ind_CustomerDedupCtrl.DedupeResponseWrapper validationResponse = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();

        try {
            String errMsg = System.Label.Err_Msg_Customer_Dedup_Resp_Err;
            String strBorrower = System.Label.Borrower;
            set<string> sDealStatusFlagSet = new Set<string>{};
            set<string> sCustomerStatusFlagSet = new Set<string>{};
            set<string> sNPATypeSet = new Set<string>{};

            sDealStatusFlagSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('DealStatusFlag').Flag_Values__c.split(','));
            sCustomerStatusFlagSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('CustomerStatusFlag').Flag_Values__c.split(','));
            sNPATypeSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('NPAType').Flag_Values__c.split(','));

            String custDedupeResponseObjId = '';
            String custDedupeResponse = '';
            String sSelectedCustCode;
            Applicant__c app = [SELECT Id, Applicant_Type__c, Opportunity__c,
                                    (SELECT Id, response__c FROM Customer_Dedupe_Response__r
                                    ORDER BY CreatedDate DESC LIMIT 1)
                                FROM Applicant__c
                                WHERE id = :applicantId
                                WITH SECURITY_ENFORCED
                                LIMIT 1];
            custDedupeResponseObjId = app.Customer_Dedupe_Response__r[0].Id;
            custDedupeResponse = app.Customer_Dedupe_Response__r[0].response__c;
            Customer_Dedup_Response_Parser dedupResponse = Customer_Dedup_Response_Parser.parse(custDedupeResponse);
            Opportunity opp = new Opportunity(ID = app.Opportunity__c);
            Customer_Dedupe_Response__c custDedupeResObj = new Customer_Dedupe_Response__c(ID = custDedupeResponseObjId);

            Set<String> custCodeSet = new Set<String>();
            List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]> dedupeValidateDataList = new List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]>();

            if (dedupResponse?.response?.content[0]?.Data?.ExternalDedupeResponse != null &&
                dedupResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS == 'M') {
                dedupeValidateDataList.add(dedupResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate);
            }
            if (dedupResponse?.response?.content[0]?.Data?.InternalDedupeResponse != null && dedupResponse?.response?.content[0]?.Data?.InternalDedupeResponse.size() > 0) {
                dedupeValidateDataList.add(dedupResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate);
            }

            for (Customer_Dedup_Response_Parser.cls_CustomerValidate[] validateData : dedupeValidateDataList) {
                for (Integer i = 0; i < validateData.size(); i++) {
                    //Skip if Customer Code already processed
                    if (custCodeSet.contains(validateData[i].CustomerCodeVal)) {
                        continue;
                    } else {
                        custCodeSet.add(validateData[i].CustomerCodeVal);
                    }

                    //DealStatus
                    if (!validateData[i]?.Dealstatus.isEmpty() && ruleIdCustomerTypeMatch) {
                        for (Customer_Dedup_Response_Parser.cls_Dealstatus status : validateData[i]?.Dealstatus) {
                            custDedupeResObj.Deal_Status_Flag__c = status.Status_Flag;

                            if (sDealStatusFlagSet.contains(status.Status_Flag)) {
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                validationResponse.message = 'Customer code tagged as ' + status.Status_Flag + ' flag. Hence cannot proceed.';
                                break;
                            }
                        }
                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                    system.debug('1. DealStatus Ran');

                    //CustomerStatus
                    if (!validateData[i]?.CustomerStatus.isEmpty() && ruleIdCustomerTypeMatch) {
                        for (Customer_Dedup_Response_Parser.cls_CustomerStatus status : validateData[i]?.CustomerStatus) {
                            custDedupeResObj.Customer_Status_Flag__c = status.Active_Flag;

                            if (sCustomerStatusFlagSet.contains(status.Active_Flag)) {
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                validationResponse.message = 'Customer code tagged as ' + status.Active_Flag + ' flag. Hence cannot proceed.';
                                break;
                            }
                        }
                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                    system.debug('2. CustomerStatus Ran');

                    //NPA
                    if (!validateData[i]?.NPA.isEmpty() && ruleIdCustomerTypeMatch) {
                        /*for (Customer_Dedup_Response_Parser.cls_NPA status : validateData[i]?.NPA) {

                            if (sNPATypeSet.contains(status.NPATYPE)) {
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                validationResponse.message = 'Customer code tagged as NPA. Hence cannot proceed.';
                                break;
                            }
                        }
                        */
                        opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                        validationResponse.message = 'Customer code tagged as NPA. Hence cannot proceed.';
                        //if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        //}
                    }
                    system.debug('3. NPA Ran');

                    //Restructure
                    if (!validateData[i]?.Restructure.isEmpty() && ruleIdCustomerTypeMatch) {
                        for (Customer_Dedup_Response_Parser.cls_Restructure status : validateData[i]?.Restructure) {

                            if (status.Deal_Restructured == 'Yes') {
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                validationResponse.message = 'Customer code under deal no has availed Restructure(com). Hence cannot proceed.';
                                break;
                            }
                        }
                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                    system.debug('4. Restructure Ran');

                    //PanAlert
                    if (!validateData[i]?.PanAlert.isEmpty()) {
                        for (Customer_Dedup_Response_Parser.cls_PanAlert status : validateData[i]?.PanAlert) {
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            validationResponse.message = 'This customer/ entity is listed by FIU under ' + status.Listing + ' ' +status.Remarks + ' dated ' + status.Source_Report_Date;
                            break;
                        }
                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                    system.debug('5. PanAlert Ran');

                    //CINAlert
                    if (!validateData[i]?.CINAlert.isEmpty()) {
                        for (Customer_Dedup_Response_Parser.cls_CINAlert status : validateData[i]?.CINAlert) {
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            validationResponse.message = 'This customer/ entity is listed by FIU under ' + status.Listing + ' ' + status.Remarks + ' dated ' + status.Source_Report_Date;
                            break;
                        }
                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                    system.debug('6. CINAlert Ran');

                    //ARC
                    if (!validateData[i]?.ARC.isEmpty() && ruleIdCustomerTypeMatch) {
                        for (Customer_Dedup_Response_Parser.cls_ARC arc : validateData[i]?.ARC) {
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            validationResponse.message = 'Customer has contract sold to ARC.';
                            break;
                        }
                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                    system.debug('7. ARC check Ran');

                    //Gecl
                    if (!validateData[i]?.Gecl.isEmpty() && ruleIdCustomerTypeMatch) {
                        for (Customer_Dedup_Response_Parser.cls_Gecl gecl : validateData[i]?.Gecl) {
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            validationResponse.message = 'Customer code under deal no has availed GECL. Hence cannot proceed.';
                            break;
                        }
                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                    system.debug('8. Gecl Ran');

                    //BeneficiaryAlert
                    if (validateData[i]?.BeneficiaryAlert?.PAN_No != null) {
                        Customer_Dedup_Response_Parser.cls_BeneficiaryAlert bAlert = validateData[i]?.BeneficiaryAlert;
                        opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                        validationResponse.message = 'Customer is part of beneficiary list. Hence cannot proceed.';

                        if (validationResponse.message != null) {
                            sSelectedCustCode = validateData[i]?.CustomerCodeVal;
                            break;
                        }
                    }
                }
                if (validationResponse.message != null) {
                    break;
                }
            }
            
            if(validationResponse.message == null){
                custDedupeResObj.Customer_Code__c = sSelectedCustCode;
                custDedupeResObj.Dedupe_Journey_Status__c = 'Continued';
                custDedupeResObj.Dedupe_Journey_Status_Reason__c = 'No duplicate found';
                app.Customer_Code__c = sSelectedCustCode;
                validationResponse.customerCode = sSelectedCustCode;
                validationResponse.isValid = true;
            } else {
                custDedupeResObj.Invalid_Customer_Code__c = sSelectedCustCode;
                custDedupeResObj.Dedupe_Journey_Status__c = 'Stopped';
                custDedupeResObj.Dedupe_Journey_Status_Reason__c = validationResponse.message;
                app.Invalid_Customer_Code__c = sSelectedCustCode;
                validationResponse.invalidCustomerCode = sSelectedCustCode;
                validationResponse.isValid = false;
            }

            if (Schema.sObjectType.Opportunity.isUpdateable() &&
                Schema.sObjectType.Applicant__c.isUpdateable() &&
                Schema.sObjectType.Customer_Dedupe_Response__c.isUpdateable()) {
                    update opp;
                    update app;
                    update custDedupeResObj;
            }

            return JSON.serialize(validationResponse);
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_DSAController', 'validateCustomerCode', System.Label.Apex, ex);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
Author:        Swapnil Prajapati
Class Name:    DSA_NewLeadWrapper
Description:   Wrapper class for all data from new lead screen
*/
    public class DSA_NewLeadWrapper {
        @AuraEnabled
        public Opportunity opp { get; set; }
        @AuraEnabled
        public Applicant__c applicant { get; set; }
        @AuraEnabled
        public Boolean updateOpportunity { get; set; }

        public DSA_NewLeadWrapper(Opportunity opp, Applicant__c applicant) {
            this.opp = opp;
            this.applicant = applicant;
            this.updateOpportunity = false;
        }
    }

    @future
    public static void sendEmailToBE(String beEmail, String dsaName, String leadNumber) {
        EmailTemplate et = [
            SELECT Id, Body, Subject
            FROM EmailTemplate
            WHERE DeveloperName = 'DSALeadTransferredBE'
        ];
        String emailBody = et.Body;
        emailBody = emailBody.replace('{leadNumber}', leadNumber);
        emailBody = emailBody.replace('{dsaName}', dsaName);

        List<String> toAddress = new List<String>();
        toAddress.add(beEmail);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('IBL DSA');
        mail.setToAddresses(toAddress);
        mail.setSubject(et.Subject);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(emailBody);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);

        try {
            Messaging.sendEmail(allmsg, false);
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}