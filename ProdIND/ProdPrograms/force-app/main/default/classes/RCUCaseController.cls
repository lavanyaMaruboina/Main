public without sharing class RCUCaseController {

    /*
    * @Method Name: createRCUCase
    * @Created by: Gaurav Rawat
    * @description: We are creating a new RCU case.
    * @Param:       current Loan application Id
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean createRCUCase(string loanApplicationId){
        Boolean returnVal = true;
        try{
            List<Case> notCompletedCaseList = new List<Case>([select Id, Loan_Application__c,status,Type,OwnerId FROM case where Loan_Application__c =:loanApplicationId and recordType.Name = 'FI' and RejectedFI__c = false AND (Type =: System.Label.Case_Current_Residence_FI_Type OR (Type =: System.Label.Case_Office_FI_Type AND Loan_Application__r.Customer_Type__c = 'Non-Individual') ) AND Status != 'Completed']);
            if(notCompletedCaseList.size() > 0){
                return false;
            }
            String rcuRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();

            List<Case> rcuCaseList = new List<Case>([Select id from Case Where RecordTypeId =: rcuRecordTypeId and Loan_Application__c =: loanApplicationId]);
            if(rcuCaseList.size() > 0){
                return false;
            }
            Set<String> documentTypeList = new Set<String>{System.Label.PanCards,System.Label.Form60DocumentType, System.Label.VoterIdCard, System.Label.AadhaarCard,System.Label.PassportCard,System.Label.DrivingLicences, 'Bank Statement','RC Document','Co-Borrower\'s Passbook','Borrower\'s Passbook','Land Photo','Electronic Bill','ICN','ITR-V','ITR-Forms','Affidavit','Talathi_Certificate','HOUSE TAX RECEIPT','Asset Photos','Sarpanch_Letter','Insurance copy','Income Docs','TRADE LICENCE','UID','SDPC / ACH Form','Loan statement','Loan NOC','Dealer letter','Work Order','CIN','GST CERTIFICATE','Water Bill','Govt letter of accommodation allotment','Govt pension payment order','Property or municipal tax receipt','Gas bill','Post paid mobile bill','Telephone bill','Resi Profile Document','RC Copy','Land Holder','Land document','Sale Agreement','Leased land proof','Electronic Bill',System.Label.Electricity_Bill,'House Tax Receipt','PARTNERSHIP DEED','PARTNERSHIP REGISTRATION CERT','MEMORANDUM OF ASSOCIATION','ARTICLES OF ASSOCIATION','CERTIFICATE OF COMMENCEMENT OF BUSINESS','CERTIFICATE OF INCORPORATION','TRUST DEED/BYE LAW','SHOPS AND ESTABLISHMENT CERTIFICATE','GST Certificate','UDYAM REGISTRATION CERTIFICATE','SALES TAX REGISTRATION CERTIFICATE','MSME REGISTRATION CERTIFICATE','UDYOG AADHAAR REG CERTIFICATE','Utility bill in the name of company','Loan Statement 1','Loan Statement 2','Loan Statement 3','OD clearance proof 1','OD clearance proof 2','OD clearance proof 3','OD clearance proof 4','Salary certificate','Talathi/Sarpanch Certificate','Subsidy sanction letter'};
            //Logic for creating the RCU case for tractor..
            List<Opportunity> oppList = new List<Opportunity>([Select id,Product_Type__c,AccountId,Name From Opportunity WHERE Id =: loanApplicationId LIMIT 1]);
            if(oppList.size() > 0 && oppList[0].Product_Type__c == 'Tractor'){
                //String documentId = createResiDoc(loanApplicationId);
                List<Documents__c> createResiDocList = createResiDoc(loanApplicationId); //SFTRAC-1359
                //List<Documents__c> documentsList = new List<Documents__c>([Select id from Documents__c WHERE Opportunity_Relation__c =: loanApplicationId AND (Document_Type__c IN : documentTypeList OR Id =: documentId) AND Is_Active__c = true LIMIT 100]);
                List<Documents__c> documentsList = new List<Documents__c>([Select id from Documents__c WHERE Opportunity_Relation__c =: loanApplicationId AND (Document_Type__c IN : documentTypeList OR Id IN : createResiDocList) AND Is_Active__c = true AND Applicant__r.In_Active_Applicant__c = false LIMIT 100]);    //SFTRAC-1359
                for (Documents__c doc : documentsList) {
                    doc.RCU_Agency_Verification_Status__c = 'Initiated';
                }
                if(documentsList.size() > 0){
                    update documentsList;
                }

                List<AccountTeamMember> accountTeamMemberList = [SELECT Id,UserId FROM AccountTeamMember WHERE AccountId =: oppList[0].AccountId AND User.IsActive = true and TeamMemberRole = 'RCU_M' WITH SECURITY_ENFORCED LIMIT 10];

                if(accountTeamMemberList.size() > 0){
                    String rcuUserId = accountTeamMemberList[0].UserId;
                    
                    List<Documents__c> borrowerPOA = new List<Documents__c>([Select Id,KYC_District__c,KYC_City__c from Documents__c where Opportunity_Relation__c =: loanApplicationId AND Proof_of_Address_POA__c = true and Applicant__r.Applicant_Type__c =: System.Label.Borrower AND Is_Active__c = true LIMIT 1]);
                    Case caseObj = new Case();
                    caseObj.Loan_Application__c = loanApplicationId;
                    caseObj.RecordTypeId = rcuRecordTypeId;
                    caseObj.Type = 'RCU';
                    caseObj.Status = 'New';
                    caseObj.Subject = 'RCU Request for Loan Application -' + oppList[0].Name;
                    caseObj.OwnerId = rcuUserId;
                    caseObj.District__c = borrowerPOA.size() > 0 ? String.isNotBlank(borrowerPOA[0].KYC_District__c) ? borrowerPOA[0].KYC_District__c : borrowerPOA[0].KYC_City__c : '';
                    caseObj.AccountId = oppList[0].AccountId;
                    if(Schema.sObjectType.Case.isCreateable()){
                        insert caseObj;
                    }
                    List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id FROM Vehicle_Detail__c Where Loan_Application__c =: loanApplicationId]);
                    for (Vehicle_Detail__c vehicleObj : vehicleList) {
                        vehicleObj.Parent_RCU_Case__c = caseObj.Id;
                    }
                    if(vehicleList.size() > 0){
                        update vehicleList;
                    }
                    for(Documents__c documentObj : documentsList){
                        documentObj.RCU_Case__c = caseObj.Id;
                    }
                    if(documentsList.size() > 0 && Schema.sObjectType.Documents__c.isUpdateable()){
                        update documentsList;
                    }
                }else{
                    returnVal = false;
                }
            }
        }catch (Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('RCUCaseController', 'createRCUCase', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){ insert errorLogRecord; }
            returnVal = false; 
        }
        return returnVal;
    }
    /*
    * @Method:      saveCaseDataToBackend
    * @Created by:  Gaurav Rawat
    * @Description: This method will return boolean value based on the case record type..
    * @Param:       String - recordId, String caseData
    * @Return:      String
    */
    @AuraEnabled
    public static String saveCaseDataToBackend(String recordId, String caseData) {
        Boolean isAlldocumentAccepted = true;
        Boolean isAllDocumentValid = true;
        Boolean isAllDocumentScreened = true;
        Boolean isAnyDocumentNotValid = false;
        try{
            if(recordId != null){
                List<Case> caseList = new List<Case>([Select id, RecordType.Name, Owner.Name, Loan_Application__r.Name, Loan_Application__r.CreatedBy.Name, Loan_Application__c,
                RCU_Manager__c,RCU_Manager__r.Name, RCU_Agent__c,AccountId, (Select Id, RCU_Agency_Verification_Status__c, RCU_Agency_Verification_Sub_Status__c from Documents1__r Where Is_Active__c = true) from Case Where id =: recordId LIMIT 1]);

                String oppId = caseList.size()> 0 ? caseList[0].Loan_Application__c: '';
                system.debug('oppId-->'+oppId);
                List<OpportunityFieldHistory> oppFieldHistoryList = new List<OpportunityFieldHistory>();
                Set<Id> cvoIdSet = new Set<Id>();
               for(OpportunityFieldHistory historyObj : [select id,CreatedById from OpportunityFieldHistory  where OpportunityId =:oppId AND CreatedBy.Profile.NAME IN ('IBL TF CVO','IBL Partner Community TF CVO') AND Field ='StageName']){
                   cvoIdSet.add(historyObj.CreatedById);
                 }
                 
                String cvo = '';
                if(!cvoIdSet.isEmpty()){
                for(AccountTeamMember cvoTeamMembers :[SELECT Id,User.Name FROM AccountTeamMember WHERE AccountId =: caseList[0].AccountId AND User.IsActive = true AND TeamMemberRole='CVO' AND User.ID IN : cvoIdSet Order by CreatedDate DESC LIMIT 1]){
                    cvo = cvoTeamMembers.User.Name;
                }
                }else{
                    cvo ='';
                }
                Boolean isAnyDocPenForRCUVer = false;
                if(caseList.size() > 0 && caseList[0].RecordType.Name == 'RCU'){
                    for(Documents__c doc : caseList[0].Documents1__r){
                        if(doc.RCU_Agency_Verification_Sub_Status__c == 'Pending for RCU Verification'){
                            isAnyDocPenForRCUVer = true;
                            break;
                        }
                        if(doc.RCU_Agency_Verification_Status__c == null || doc.RCU_Agency_Verification_Status__c == 'New' || doc.RCU_Agency_Verification_Status__c == 'Initiatied'){
                            isAlldocumentAccepted = false;
                            break;
                        }

                        if((doc.RCU_Agency_Verification_Status__c != 'Screened' && doc.RCU_Agency_Verification_Status__c != 'Not Required') || (doc.RCU_Agency_Verification_Status__c == 'Sampled' && doc.RCU_Agency_Verification_Sub_Status__c == 'Clear')){
                            isAllDocumentScreened = false;
                        }
                        if(doc.RCU_Agency_Verification_Status__c != 'Screened' && doc.RCU_Agency_Verification_Status__c == 'Sampled' && doc.RCU_Agency_Verification_Sub_Status__c != 'Clear'){
                            isAllDocumentValid = false;
                        }
                        if(doc.RCU_Agency_Verification_Status__c == 'Sampled' && ( doc.RCU_Agency_Verification_Sub_Status__c == 'Negative' || doc.RCU_Agency_Verification_Sub_Status__c == 'Non-clear Profile' || doc.RCU_Agency_Verification_Sub_Status__c == 'Non-clear Document'|| doc.RCU_Agency_Verification_Sub_Status__c == 'Refer to Credit' ||  doc.RCU_Agency_Verification_Sub_Status__c == 'Failed')){
                            isAnyDocumentNotValid = true;
                        }
                    } 
                    if(isAlldocumentAccepted == false){
                        return 'Please review all document first.';
                    }
                    if(isAnyDocPenForRCUVer == true){
                        return 'Documents are Pending for RCU Verification!';
                    }
                    if(isAlldocumentAccepted == true){

                        List<Opportunity> oppList = new List<Opportunity>([Select Id,StageName from Opportunity WHERE Id =: caseList[0].Loan_Application__c  LIMIT 1]);
                        if(oppList.size() > 0 && oppList[0].StageName != 'Disbursement Request Preparation'){
                            return 'You can\'t submit this case as Pre-disbursement is not completed.';
                        }

                        Case caseRecord = (Case) JSON.deserialize(caseData, Case.class);
                        if(isAllDocumentValid == true && caseRecord.Overall_RCU_Agency_Verification_Status__c == 'Negative'){
                            return 'Please select correct verification status!';
                        }
                        // List<CaseHistory> caseHistoryList = new List<CaseHistory>([Select Id,CreatedById,CreatedBy.Name from CaseHistory where Field = 'Owner' and CaseId =: recordId order by createddate ASC LIMIT 1]);
                        caseRecord.Status = isAnyDocumentNotValid == true ? 'Pending Approval' : isAllDocumentScreened == true ? 'Closed' : isAllDocumentValid == true ? 'Resolved' : caseRecord.Status;
                        // caseRecord.Overall_RCU_Agency_Verification_Status__c = isAnyDocumentNotValid == true ? 'Pending Approval' : caseRecord.Overall_RCU_Agency_Verification_Status__c;
                        // if(caseHistoryList.size() > 0){
                            //     caseRecord.OwnerId = caseHistoryList[0].CreatedById;
                        // }
                        if(caseRecord.Status == 'Pending Approval' || caseRecord.Status == 'Resolved'){
                            caseRecord.OwnerId = caseList[0].RCU_Manager__c;
                        }

                        update caseRecord;

                        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer' LIMIT 1];
                        Messaging.CustomNotification noti = new Messaging.CustomNotification();
                        
                        List<User> userList = [Select Id,Contact.Account.Name From User Where Id=: caseList[0].RCU_Agent__c];

                        String loanId = caseList.size() > 0 ? caseList[0].Loan_Application__r.Name : ''; 
                        String loanSubmitter = 'Your Loan Submitter';
                        String be = caseList.size() > 0 ? caseList[0].Loan_Application__r.CreatedBy.Name : ''; 
                        // String cvo = caseList.size() > 0 ? caseList[0].Owner.Name : '';
                        String rcuManager = caseList.size() > 0 ? caseList[0].RCU_Manager__r.Name : ''; 
                        String rcuAgency = userList.size() > 0 ? userList[0].Contact.Account.Name : ''; //RCU_Agent__c -> contact -> Account -> Name

                        String notificationBody = 'Sir/Madam,\nThis is to notify that the RCU request has been fulfilled by the Agency. Loan details below - ' + '\nLoan Id: ' + loanId + '\nLoan Submitter: ' + loanSubmitter + '\nBE: ' + be + '\nCVO: ' + cvo + '\nRCU Manager: ' + rcuManager + '\nRCU Agency: ' + rcuAgency;

                        noti.setBody(notificationBody);
                        noti.setTitle('RCU Case Assignment');
                        noti.setNotificationTypeId(notificationType.Id);
                        noti.setTargetId(caseRecord.Id);
                         if(caseRecord.Status!='Closed'){
                        noti.send(new Set<String> { caseRecord.OwnerId });
                         }
                         else if(!caseList.isEmpty() && String.isNotBlank(caseList[0].RCU_Manager__c)){
                             noti.send(new Set<String> { caseList[0].RCU_Manager__c });
                         }
                        return 'Case Submitted Successfully!';
                    }
                }
            }            

        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('RCUCaseController', 'saveCaseDataToBackend', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return null;
    }

    /*
    * @Method:      getRCUCaseDetails
    * @Created by:  Gaurav Rawat
    * @Description: This method will return case data..
    * @Param:       String - recordId
    * @Return:      String
    */
    @AuraEnabled
    public static Case getRCUCaseDetails(String recordId) {
        try{
            if(String.isNotEmpty(recordId)){
                List<Case> caseList = new List<Case>([Select id,Overall_RCU_Agency_Verification_Remarks__c,Overall_RCU_Agency_Verification_Status__c,Status,Owner.Name,Subject,Resi_Profile_Remarks__c,Resi_Profile__c,CaseNumber from Case where id=: recordId LIMIT 1]);
                if(caseList.size() > 0){
                    return caseList[0];
                }                
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('RCUCaseController', 'getRCUCaseDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return null;
    }
    
    /*
    * @Method:      getCurrentUser
    * @Created by:  Satyam
    * @Description: This method will return user data..
    * @Param:       String - recordId
    * @Return:      String
    */
    @AuraEnabled
    public static User getCurrentUser(String userId) {
        try{
            if(String.isNotEmpty(userId)){
                User userInfo = [select Id,Name ,contact.AccountId from User where id=: userId Limit 1];
                return userInfo;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('RCUCaseController', 'getCurrentUser', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return null;
    }
    
    /*
    * @Method:      submitRCUCaseForApproval
    * @Created by:  Gaurav Rawat
    * @Description: This method will execute the logic of spliting the document into different casees for NCM/SCM. 
    * @Param:       String - recordId
    * @Return:      String
    */
    @AuraEnabled
    public static string submitRCUCaseForApproval(String caseId){
        try {
            if(caseId != null){
                List<Case> caseList = new List<Case>([Select id,RecordType.Name,Loan_Application__r.AccountId,Loan_Application__c,Loan_Application__r.Name,Owner.Name,OwnerId,District__c, (Select Id,RCU_Agency_Verification_Status__c,RCU_Agency_Verification_Sub_Status__c from Documents1__r Where Is_Active__c = true) from Case Where id =: caseId LIMIT 1]);
                if(caseList.size() > 0 && caseList[0].RecordType.Name == 'RCU'){
                    List<Documents__c> ncmDocumentsList = new List<Documents__c>();
                    List<Documents__c> scmDocumentsList = new List<Documents__c>();
                    List<Documents__c> tempList = new List<Documents__c>();
                    for(Documents__c doc : caseList[0].Documents1__r){
                        if(doc.RCU_Agency_Verification_Status__c == 'Sampled' && (doc.RCU_Agency_Verification_Sub_Status__c == 'Negative' || doc.RCU_Agency_Verification_Sub_Status__c == 'Non-clear Profile'|| doc.RCU_Agency_Verification_Sub_Status__c == 'Non-clear Document')){
                            ncmDocumentsList.add(doc);
                        }else if((doc.RCU_Agency_Verification_Status__c == 'Sampled' && (doc.RCU_Agency_Verification_Sub_Status__c == 'Refer to Credit' ||  doc.RCU_Agency_Verification_Sub_Status__c == 'Failed'))){
                            scmDocumentsList.add(doc);
                        }
                        else {
                            doc.NCM_Status__c='';
                            doc.NCM_Comment__c='';
                            doc.SCM_Status__c='';
                            doc.SCM_Comment__c='';
                            tempList.add(doc);

                        }
                    }
                    if(!tempList.isEmpty()){
                        update tempList;
                    }
                    Boolean ncmCaseCreated = false;
                    Boolean scmCaseCreated = false;
                    if(ncmDocumentsList.size() > 0){
                        ncmCaseCreated = createRCUChildCase(caseList[0].Loan_Application__r.Name,caseList[0].Loan_Application__c,caseList[0].Loan_Application__r.AccountId, caseList[0].Id, ncmDocumentsList, 'NCM',caseList[0].Owner.Name,caseList[0].OwnerId,caseList[0].District__c);
                    }
                    if(scmDocumentsList.size() > 0){
                        scmCaseCreated = createRCUChildCase(caseList[0].Loan_Application__r.Name,caseList[0].Loan_Application__c,caseList[0].Loan_Application__r.AccountId, caseList[0].Id, scmDocumentsList, 'SCM',caseList[0].Owner.Name,caseList[0].OwnerId,caseList[0].District__c);
                    }

                    if(scmCaseCreated == false && scmDocumentsList.size() > 0 && ncmCaseCreated == false && ncmDocumentsList.size() > 0){
                        return 'SCM/NCM users not found!';
                    }
                    if(scmCaseCreated == false && scmDocumentsList.size() > 0){
                        return 'SCM user not found';
                    }
                    if(ncmCaseCreated == false && ncmDocumentsList.size() > 0){
                        return 'NCM user not found';
                    }
                    if(scmCaseCreated == false && scmDocumentsList.size() == 0 && ncmCaseCreated == false && ncmDocumentsList.size() == 0){
                        return 'Approval already sent';
                    }
                }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('RCUCaseController', 'submitRCUCaseForApproval', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return 'Approval sent successfully';
    }

    @AuraEnabled
    public static Boolean createRCUChildCase(String loanApplicationNumber,String loanApplicationId,String accountId, String caseId, List<Documents__c> documentList, String teamRole,String parentCaseOwnername,String parentCaseOwnerId, String parentCaseDistrict){
        try{
            String rcuRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();
            List<AccountTeamMember> accountTeamMemberList = [SELECT Id,UserId FROM AccountTeamMember WHERE AccountId =: accountId AND User.IsActive = true and TeamMemberRole =: teamRole WITH SECURITY_ENFORCED LIMIT 10];
             Set<Id> cvoIdSet = new Set<Id>();
               for(OpportunityFieldHistory historyObj : [select id,CreatedById from OpportunityFieldHistory  where OpportunityId =:loanApplicationId AND CreatedBy.Profile.NAME IN ('IBL TF CVO','IBL Partner Community TF CVO') AND Field ='StageName']){
                   cvoIdSet.add(historyObj.CreatedById);
            }
             String cvo = '';
           
           if(!cvoIdSet.isEmpty()){
               for(AccountTeamMember cvoTeamMembers :[SELECT Id,User.Name FROM AccountTeamMember WHERE AccountId =: accountId AND User.IsActive = true AND TeamMemberRole='CVO' AND User.ID IN : cvoIdSet Order by CreatedDate DESC LIMIT 1]){
                   cvo = cvoTeamMembers.User.Name;
               }
            }
            else{
                cvo = '';
            }
            List<CaseHistory> caseHistoryList = [SELECT Field, OldValue, NewValue,DataType,CaseId,Case.CaseNumber FROM CaseHistory WHERE Case.ParentId =: caseId and Field = 'Owner' and DataType = 'EntityId' Order By CreatedDate ASC];

            Map<String, String> mapOfOwnerTypeAndChildCaseId = new Map<String,String>();
            Map<Id,String> mapOfUserIdAndChildCaseId = new Map<Id, String>();
            Set<Id> userId = new Set<Id>();
            if(!caseHistoryList.isEmpty()){
                for(CaseHistory caseHis:caseHistoryList){
                    System.debug('caseHis-->'+caseHis);
                    userId.add(String.valueOf(caseHis.OldValue));
                    mapOfUserIdAndChildCaseId.put(String.valueOf(caseHis.OldValue), caseHis.CaseId);
                }
                System.debug('mapOfUserIdAndChildCaseId-->'+mapOfUserIdAndChildCaseId);
                for(User usr: [SELECT Id,UserRole.Name FROM User WHERE Id in: userId]){
                    mapOfOwnerTypeAndChildCaseId.put(usr.UserRole.Name,mapOfUserIdAndChildCaseId.get(usr.Id));
                }
                System.debug('mapOfOwnerTypeAndChildCaseId-->'+mapOfOwnerTypeAndChildCaseId);

            }
            
            if(accountTeamMemberList.size() > 0){
                String caseOwnerId = accountTeamMemberList[0].UserId;
                Case caseObj = new Case();
                if(!mapOfOwnerTypeAndChildCaseId.isEmpty() && mapOfOwnerTypeAndChildCaseId.containsKey(teamRole)){
                    caseObj.Id = mapOfOwnerTypeAndChildCaseId.get(teamRole);
                }
                caseObj.Loan_Application__c = loanApplicationId;
                caseObj.RecordTypeId = rcuRecordTypeId;
                caseObj.Type = 'RCU';
                caseObj.Status = 'New';
                caseObj.Subject = 'RCU Request for Loan Application -' + loanApplicationNumber;
                caseObj.OwnerId = caseOwnerId;
                caseObj.District__c = parentCaseDistrict;
                caseObj.AccountId = accountId;
                caseObj.ParentId = caseId;
                if(Schema.sObjectType.Case.isCreateable()){
                    upsert caseObj;
                    List<Case> caseList = new List<Case>([Select id,RecordType.Name,Owner.Name,Loan_Application__r.Name,Loan_Application__r.CreatedBy.Name,Loan_Application__c,CaseNumber from Case Where id =: caseObj.id LIMIT 1]);
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer' limit 1];
                    Messaging.CustomNotification noti = new Messaging.CustomNotification();
                    List<Account> accountList = [Select Id,Name from Account where RCU_Manager__c =:parentCaseOwnerId LIMIT 1];
                    String loanId = caseList.size() > 0 ? caseList[0].Loan_Application__r.Name : ''; 
                    String loanSubmitter = 'Your Loan Submitter';
                    String be = caseList.size() > 0 ? caseList[0].Loan_Application__r.CreatedBy.Name : ''; 
                                        String rcuManager = parentCaseOwnername!=null ? parentCaseOwnername:'';
                    String caseNumber = caseList.size() > 0 ? caseList[0].CaseNumber : '';
                    String rcuAgency = accountList.size() > 0 && accountList[0].Name!=null ? accountList[0].Name : '';
                    String notificationBody = 'Sir/Madam,\nThis is to notify that an Approval request for case '+caseNumber+' has been submitted for your review related to RCU document verification.\nLoan details below - ' + '\nLoan Id- ' + loanId + '\nLoan Submitter details- ' + loanSubmitter + '\nBE- ' + be + '\nCVO- ' + cvo + '\nRCU Manager- ' + rcuManager + '\nRCU Agency- ' + rcuAgency;
                    noti.setBody(notificationBody);
                    noti.setTitle('RCU Case Assignment');
                    noti.setNotificationTypeId(notificationType.Id);
                    noti.setTargetId(caseObj.Id);
                    noti.send(new Set<String> { caseObj.OwnerId });
                }
                Utilities.createCaseTeamMember(caseObj.id);
                for(Documents__c documentObj : documentList){
                    documentObj.RCU_Case__c = caseObj.Id;
                    documentObj.NCM_Status__c = '';
                    documentObj.NCM_Comment__c = '';
                    documentObj.SCM_Status__c = '';
                    documentObj.SCM_Comment__c = '';
                }
                if(documentList.size() > 0 && Schema.sObjectType.Documents__c.isUpdateable()){
                    update documentList;
                }
            }else{
                return false;
            }
        } catch (Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('RCUCaseController', 'createRCUChildCase', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){ insert errorLogRecord; }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return true;
    }
    @AuraEnabled
    public static String updateCaseOwner(String recordId, String ownerId){
        try{
            Case caseObj = [Select id,ownerId,Loan_Application__c from case where id=: recordId Limit 1];
            caseObj.ownerId = ownerId;
            update caseObj;

            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(OpportunityAccessLevel='Edit', OpportunityId=caseObj.Loan_Application__c, TeamMemberRole='RCUAGY', UserId=ownerId );
            insert oppTeamMember;
            
            return 'Success';
        }catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('RCUCaseController', 'createRCUChildCase', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){ insert errorLogRecord; }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }


    @AuraEnabled
    public static String updateCaseStatus(String recordId){
        try{
            List<Case> parentCaseList = [SELECT Id, Status, Overall_RCU_Verification_Status__c, OwnerId, AccountId, (Select Id,Status from Cases) from Case Where Id =: recordId and ParentId = null];
            

                Integer numberOfChildCaseApproved = 0;
                Integer numberOfChildCaseRejected = 0;
                if(parentCaseList.size() > 0){ //SFTRAC-263 //Change owner to NCM/SCM in RCU flow
                    List<AccountTeamMember> ncmTeamMemberRole = [SELECT Id,UserId,TeamMemberRole from AccountTeamMember where AccountId  =: parentCaseList[0].AccountId and TeamMemberRole = 'NCM' LIMIT 1 ];
                    List<AccountTeamMember> scmTeamMemberRole = [SELECT Id,UserId,TeamMemberRole from AccountTeamMember where AccountId  =: parentCaseList[0].AccountId and TeamMemberRole = 'SCM' LIMIT 1 ];
                    for(Case parentcaseInst : parentCaseList){
                        if(parentcaseInst.Overall_RCU_Verification_Status__c == 'Negative' || parentcaseInst.Overall_RCU_Verification_Status__c == 'Non-clear Profile' || parentcaseInst.Overall_RCU_Verification_Status__c == 'Non-clear Document' ){
                            parentcaseInst.ownerId = ncmTeamMemberRole[0].UserId;
                        }
                        else if(parentcaseInst.Overall_RCU_Verification_Status__c == 'Refer to Credit' || parentcaseInst.Overall_RCU_Verification_Status__c == 'Failed'){
                            parentcaseInst.ownerId = scmTeamMemberRole[0].UserId;
                        }
                }
                if(!parentCaseList.isEmpty() && (parentCaseList[0].Overall_RCU_Verification_Status__c=='Negative' || parentCaseList[0].Overall_RCU_Verification_Status__c == 'Non-clear Profile' || parentCaseList[0].Overall_RCU_Verification_Status__c == 'Non-clear Document' || parentCaseList[0].Overall_RCU_Verification_Status__c=='Refer to Credit' || parentCaseList[0].Overall_RCU_Verification_Status__c=='Failed')){
                    update parentCaseList;
                    return 'RCU Case approval sent to SCM/NCM';
                }
            }
                if(parentCaseList[0].Cases.size() > 0){
                    for(Case caseInst : parentCaseList[0].Cases){
                        if(caseInst.Status == 'Rejected'){
                            return 'reject';
                        }
                        else if(caseInst.Status == 'Resolved'){
                            numberOfChildCaseApproved++;
                        }
                        else if(caseInst.Status == 'New'){
                            return null;
                        }
                    }
    
                    if(numberOfChildCaseApproved == parentCaseList[0].Cases.size()){
                        return 'success';
                    }

                    return null;
                }else if(parentCaseList.size()>0 && parentCaseList[0].status == 'Resolved'){
                    return 'success';
                }
                else{
                    return 'No Child Case Exist';
                }
        }
            catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('RCUCaseController', 'updateCaseStatus', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){ insert errorLogRecord; }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    @AuraEnabled
    public static string isRCUCaseClosed(String loanApplicationId){
        try{
            List<Opportunity> oppList = new List<Opportunity>([Select Id,Product_Type__c from Opportunity Where Id =: loanApplicationId LIMIT 1]);
            if(oppList.size() > 0 && oppList[0].Product_Type__c == System.Label.Tractor){
                String rcuRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();
                List<Case> rcuCaseList = [SELECT Id,Status from Case Where Loan_Application__c =: loanApplicationId and ParentId = null and RecordTypeId =: rcuRecordTypeId LIMIT 1];
                
                if(rcuCaseList.size() > 0 && rcuCaseList[0].Status == 'Closed'){
                    return 'RCU-Case Closed';
                }else{
                    return 'RCU-Case Not Closed';
                }
            }else{
                return 'Non-Tractor';
            }
            
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('RCUCaseController', 'isRCUCaseClosed', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){ insert errorLogRecord; }
        }
        return null;
    }

    @AuraEnabled
    public static Map<String, String> getSamplingReasonPicklist(){
        try{
            Map<String, String> samplingReasonPicklistMap = new Map<String, String>();

            List<Schema.PicklistEntry> picklistEntries = Case.sObjectType.getDescribe().fields.getMap().get('Overall_RCU_Agency_Sampling_Reason__c').getDescribe().getPicklistValues();

            for(Schema.PicklistEntry sr : picklistEntries){
                samplingReasonPicklistMap.put(sr.value , sr.label);
            }

            if(!samplingReasonPicklistMap.isEmpty()){
                return samplingReasonPicklistMap;
            }

        }
            catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('RCUCaseController', 'getSamplingReasonPicklist', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){ insert errorLogRecord; }
        }
        return null;

    }
    /*
    * @Method:      RCUVerification
    * @Created by:  Satyam Singh
    * @Description: This method will show the RCU case data. 
    * @Param:       String - recordId
    * @Return:      Wrapper AllApplicantsData
    */
    @AuraEnabled
    public static AllApplicantsData RCUVerification(string recordId){
        try {
            System.debug('recordId::' + recordId);
            AllApplicantsData allApplicantsData = new AllApplicantsData();
            allApplicantsData.ApplicantsDataList = new List<ApplicantsData>();

            list<case>  caseRec= [SELECT Id,Loan_Application__c FROM case WHERE Id =: recordId LIMIT 1];
            if(caseRec.size()>0){
                list<Applicant__c> applicantList = [select Id, Name, CRIFF_Report_URL__c, Contact_number__c, Applicant_Type__c, Opportunity__r.Customer_Type__c, Opportunity__r.Account.State__c, Opportunity__r.Account.BranchBLCode__c, (select id, KYC_Address_Line_1__c, KYC_Address_Line_2__c,is_Active__c, Proof_of_Identity_POI__c from Documents__r where is_Active__c = true and Proof_of_Identity_POI__c = true limit 1), (select Id, Applicant__c from CIBIL_Details__r LIMIT 1) from Applicant__c where Opportunity__c =:caseRec[0].Loan_Application__c AND In_Active_Applicant__c=FALSE limit 100];
                
                map<string,string> ApplicantvsCibilId = new Map<string,string>();
                for(Applicant__c applicant : applicantList){
                    ApplicantsData AppData = new ApplicantsData();
                    AppData.ApplicantName = applicant.Name;
                    AppData.ApplicantType = applicant.Applicant_Type__c;
                    AppData.Contactnumber = applicant.Contact_number__c;
                    AppData.ApplicantID   = applicant.Id;
                    AppData.State = applicant.Opportunity__r.Account.State__c;
                    AppData.BranchBLCode = applicant.Opportunity__r.Account.BranchBLCode__c;
                    if(applicant.Applicant_Type__c == 'Borrower'){
                    	allApplicantsData.cRIFFReportURL = applicant.CRIFF_Report_URL__c;
                    	allApplicantsData.oppCustomerType = applicant.Opportunity__r.Customer_Type__c;    
                    }
                    String KYCAdd = '';
                    for(Documents__c Doc: applicant.Documents__r){
                        if(doc.KYC_Address_Line_1__c != null){
                            KYCAdd = Doc.KYC_Address_Line_1__c + ' ' ;
                            AppData.KYCAddress = KYCAdd;
                        }

                        if(doc.KYC_Address_Line_2__c != null){
                            AppData.KYCAddress =  KYCAdd + Doc.KYC_Address_Line_2__c;
                        }
                    }
                    
                    for(CIBIL_Details__c CIBILDetail: applicant.CIBIL_Details__r){
                        AppData.cibilID = CIBILDetail.id;
                        ApplicantvsCibilId.put(applicant.Id,CIBILDetail.Id);
                    }

                    AllApplicantsData.ApplicantsDataList.add(AppData);
                }
                AllApplicantsData.ApplicantvsCibilIdMap = ApplicantvsCibilId;
            }
            return AllApplicantsData;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    
    public class ApplicantsData{
        @AuraEnabled
        public string ApplicantName{get;set;}
        @AuraEnabled
        public string ApplicantType{get;set;}
        @AuraEnabled
        public string Contactnumber{get;set;}
        @AuraEnabled
        public string KYCAddress{get;set;}
        @AuraEnabled
        public string cibilID {get;set;}
        @AuraEnabled
        public string ApplicantID {get;set;}
        @AuraEnabled
        public string State {get;set;}
        @AuraEnabled
        public string BranchBLCode {get;set;}
    }
    
    public class AllApplicantsData{
        @AuraEnabled
        public list<ApplicantsData>  ApplicantsDataList {get;set;}
        @AuraEnabled
        public  Map<String,string>  ApplicantvsCibilIdMap{get;set;}
        @AuraEnabled
        public string cRIFFReportURL {get;set;}
        @AuraEnabled
        public string oppCustomerType {get;set;}
    }

    @AuraEnabled
    public static boolean isAllDocumentsScreened(String caseId){
        List<Documents__c> documentList = [SELECT Id FROM Documents__c where RCU_Case__c =: caseId AND ((RCU_Agency_Verification_Status__c != 'Screened' AND Document_Type__c != 'Resi Profile Document') OR (Document_Type__c = 'Resi Profile Document' AND RCU_Agency_Verification_Status__c != 'Screened' AND RCU_Agency_Verification_Status__c != 'Not Required'))];
        return documentList.size() > 0 ? false : true;
    }
    /*@AuraEnabled
    public static string createResiDoc(String loanApplicationId){
        List<Applicant__c> borrowerList = new List<Applicant__c>([SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanApplicationId AND In_Active_Applicant__c = false AND Applicant_Type__c =: Label.Borrower LIMIT 1]);
        String resiRecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId();
        List<Documents__c> resiDocumentList = new List<Documents__c>([SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: loanApplicationId AND Is_Active__c = true AND Applicant__c =: borrowerList[0].Id AND  Document_Type__c = 'Resi Profile Document' AND RecordTypeId =: resiRecordTypeId]);
        if(resiDocumentList.size() == 0){
            Documents__c doc = new Documents__c();
            doc.Document_Type__c = 'Resi Profile Document';
            doc.Name = 'Resi Profile Document';
            doc.Is_Active__c = true;
            doc.Applicant__c = borrowerList.size() > 0 ? borrowerList[0].Id : '';
            doc.Opportunity_Relation__c = loanApplicationId;
            doc.RecordTypeId = resiRecordTypeId;
            insert doc;
            return doc.Id;
        }
        return resiDocumentList[0].Id;
    }*/

    //SFTRAC-1359 Starts Resi Doc record to be created for all the applicant related to Loan Application
    @AuraEnabled
    public static list<Documents__c> createResiDoc(String loanApplicationId){
        List<Applicant__c> applicantList = new List<Applicant__c>([SELECT Id,Applicant_Type__c FROM Applicant__c WHERE Opportunity__c =:loanApplicationId AND In_Active_Applicant__c = false]);
        String resiRecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId();
        List<Documents__c> resiDocumentList = new List<Documents__c>([SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: loanApplicationId AND Is_Active__c = true AND  Document_Type__c = 'Resi Profile Document' AND RecordTypeId =: resiRecordTypeId]);
        system.debug('+++++applicantList '+applicantList);
        system.debug('+++++resiDocumentList '+resiDocumentList);
        List<Documents__c> insertResiDocumentList = new List<Documents__c>();
        if(resiDocumentList.size() == 0){
            if(applicantList.size() != 0){
                for(Applicant__c appRec: applicantList){
                    Documents__c doc = new Documents__c();
                    doc.Document_Type__c = 'Resi Profile Document';
                    doc.Name = appRec.Applicant_Type__c + ' - Resi Profile Document';
                    doc.Is_Active__c = true;
                    doc.Applicant__c = appRec.Id;
                    doc.Opportunity_Relation__c = loanApplicationId;
                    doc.RecordTypeId = resiRecordTypeId;
                    insertResiDocumentList.add(doc);
                }
            }
            system.debug('+++++insertResiDocumentList outside '+insertResiDocumentList);
            if(insertResiDocumentList.size() != 0){
                system.debug('+++++insertResiDocumentList Inside '+insertResiDocumentList);
                insert insertResiDocumentList;
                return insertResiDocumentList;
            }
        }
        return resiDocumentList;
    }//SFTRAC-1359 Ends

    @AuraEnabled
    public static boolean isResiDocumentUploaded(String caseId){
        String resiRecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId();
        List<Documents__c> documentList = [SELECT Id,RCU_Agency_Verification_Status__c,(SELECT Id FROM ContentDocumentLinks) FROM Documents__c where RCU_Case__c =: caseId AND Document_Type__c = 'Resi Profile Document' ANd Is_Active__c = true AND RCU_Agency_Verification_Status__c != 'Not Required' AND RCU_Agency_Verification_Status__c != 'Screened' AND RecordTypeId =: resiRecordTypeId LIMIT 1];
        if(documentList.size() > 0 && (documentList[0].RCU_Agency_Verification_Status__c == 'Not Required' || documentList[0].RCU_Agency_Verification_Status__c == 'Screened' || documentList[0].ContentDocumentLinks.size() > 0)){
            return true;
        }
        return documentList.size() == 0 ? true : false;
    }
    @AuraEnabled
    public static boolean allDocumentSubmitted(String caseId){
        List<Documents__c> documentList = [SELECT Id FROM Documents__c where RCU_Case__c =: caseId AND (RCU_Agency_Verification_Status__c = null OR RCU_Agency_Verification_Status__c = 'Initiated') ANd Is_Active__c = true LIMIT 1];
        if(documentList.size() > 0){
            return false;
        }
        return true;
    }

    @AuraEnabled
    public static boolean isCommunityUser(){
        User Usr =[SELECT Id,profile.name,userType FROM User WHERE Id = : UserInfo.getUserId()];
        if(Usr.userType == 'PowerPartner'){
            return true;
        }
        return false;
    }
}