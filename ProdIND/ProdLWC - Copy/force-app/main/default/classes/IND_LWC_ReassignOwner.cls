/**
 * @Name         IND_LWC_ReassignOwner
 * @Author       Udit Singhal
 * @Company      Salesforce
 * @Description  This class contains all methods related to Reassign Owner LWC component
 * Test Class:   IND_LWC_ReassignOwnerTest
 * 
 */

 /* Mapping Table:-
    Assignment Section	    For TW	   Lead Source	    Current owner	Status	            Assignment owner    Status      Requester   Approver
    Lead assignment         TRUE	    Salesforce	    MA	            Active/Resigned	    MA	                Active	    CVO	        SCB
    CMU Case assignment	    TRUE	    Salesforce	    MA	            Active/Resigned	    MA	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    FI	            Active/Resigned	    FI	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    FI	            Active/Resigned	    MO	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    FI	            Active/Resigned	    BE	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    MO	            Active/Resigned	    MO	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    MO	            Active/Resigned	    FI	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    MO	            Active/Resigned	    BE	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    BE	            Active/Resigned	    BE	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    BE	            Active/Resigned	    FI	                Active	    CVO	        SCB
    FI Case assignment	    TRUE	    Salesforce	    BE	            Active/Resigned	    MO	                Active	    CVO	        SCB
    CVO assignment	        TRUE	    Salesforce	    CVO	            Active/Resigned	    CVO	                Active	    SCB	        SCB
    Lead assignment	        FALSE	    Salesforce	    CS	            Active/Resigned     BE	                Active	    CVO	        SCM
    Lead assignment	        FALSE	    Salesforce	    BE	            Active/Resigned     BE	                Active	    CVO	        SCM
    CMU Case assignment	    FALSE	    Salesforce	    CS	            Active/Resigned     BE	                Active	    CVO	        SCM
    CMU Case assignment	    FALSE	    Salesforce	    BE	            Active/Resigned     BE	                Active	    CVO	        SCM
    FI Case assignment	    FALSE	    Salesforce	    BE	            Active/Resigned     BE	                Active	    CVO	        SCM
    CVO assignment	        FALSE	    Salesforce	    CVO	            Active/Resigned     CVO	                Active	    SCM	        SCM
    Lead assignment	        FALSE	    DSA	            CS	            Active/Resigned     BE	                Active	    CVO	        SCM
    Lead assignment	        FALSE	    DSA	            BE	            Active/Resigned     BE	                Active	    CVO	        SCM
    CMU Case assignment	    FALSE	    DSA	            CS	            Active/Resigned     BE	                Active	    CVO	        SCM
    CMU Case assignment	    FALSE	    DSA	            BE	            Active/Resigned     BE	                Active	    CVO	        SCM
    FI Case assignment	    FALSE	    DSA	            BE	            Active/Resigned     BE	                Active	    CVO	        SCM
 */         
public without sharing class IND_LWC_ReassignOwner {
    public static List<Reassign_Owner_Log__c> reassignOwnerLogsList = new List<Reassign_Owner_Log__c>();
    
    @AuraEnabled
    public static List<Opportunity> getLoanApplicationRecords(String reassignmentType, Boolean isTwoWheeler, Id blCode, String leadSource, String teamRole, String leadNumber, String benCode) {
        try {
            Set<String> stagesToExcludeSet = new Set<String>{'Journey Restart', 'Journey Stop', 'Revoke', 'Rejected', 'Withdrawn'};
            Set<String> l2JourneyStageNames = new Set<String>{'Credit Processing', 'Post Sanction Checks and Documentation', 'Pre Disbursement Check', 'Disbursement Request Preparation'};
            String myQuery = '';
            
            if(reassignmentType == 'Lead Assignment' && leadSource != 'D2C') {
                stagesToExcludeSet.addAll(l2JourneyStageNames);
                if(!isTwoWheeler) {
                    //show loan applications for PV which are in L2 screens for which deviations are not initiated/triggered
                    stagesToExcludeSet.remove('Credit Processing');
                }
            }
            
            myQuery = 'SELECT Id, Account.Name, Lead_number__c, StageName, Owner.EmployeeNumber, Owner.Name, Owner.IsActive, (SELECT Id, Trigger_Deviations__c FROM CAMS__r WHERE Trigger_Deviations__c = true) FROM Opportunity WHERE Id NOT IN (SELECT Loan_Application__c FROM Reassign_Owner_Log__c WHERE Approval_Status__c = \'Pending\' AND Reassignment_Type__c = \'Lead Assignment\') AND JourneyStopScenarioFound__c = false AND Is_Revoked__c = false AND StageName NOT IN';
            myQuery += ':stagesToExcludeSet AND AccountId = \'' + blCode + '\' AND LeadSource = \'' + leadSource + '\' AND OwnerId IN (SELECT UserId FROM AccountTeamMember WHERE AccountId = \'' + blCode + '\' AND TeamMemberRole = \'' +teamRole+ '\')';
            
            if(leadSource == 'D2C') {
                myQuery += ' AND StageName IN :l2JourneyStageNames';
            }
            if (String.isNotBlank(leadNumber)){
                myQuery += ' AND Lead_number__c Like  \'%' + leadNumber + '%\'';
            }
            if (String.isNotBlank(benCode)){
                myQuery += ' AND Owner.EmployeeNumber Like  \'%' + benCode + '%\'';
            }
            
            myQuery += ' ORDER BY Lead_number__c ASC LIMIT 50000';
            
            System.debug('myQuery: '+myQuery);
            Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>((List<Opportunity>) Database.query(myQuery));
            System.debug('result: '+ oppMap.size());

            if(reassignmentType == 'CVO Assignment') {
                return oppMap.values();
            } else {
                //only show loan application which are in L2 screens for which deviations are not initiated/triggered for 'Lead Assignment'
                for(Opportunity oppRecord :oppMap.values()) {
                    if(l2JourneyStageNames.contains(oppRecord.StageName) && oppRecord.CAMS__r.size() > 0) {
                        oppMap.remove(oppRecord.Id);
                    }
                }
                return oppMap.values();
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Case> getFICaseRecords(Id blCode, String leadSource, String teamRole, String leadNumber, String benCode) {
        try {
            Set<String> statusToExcludeSet = new Set<String>{'Accepted','Closed','Closed- Revoke'};
                
            String myQuery = '';
            myQuery = 'SELECT Id, CaseNumber, Account.Name, TYPEOF Owner WHEN User THEN EmployeeNumber, Name, IsActive WHEN Group THEN Name END, Loan_Application__c, Loan_Application__r.Lead_number__c FROM Case WHERE Id NOT IN (SELECT Case__c FROM Reassign_Owner_Log__c WHERE Approval_Status__c = \'Pending\' AND Reassignment_Type__c = \'FI Case Assignment\') AND RecordType.DeveloperName = \'FI\' AND Loan_Application__r.JourneyStopScenarioFound__c = false AND Loan_Application__c != null AND Loan_Application__r.Is_Revoked__c = false AND Status NOT IN';
            myQuery += ':statusToExcludeSet AND AccountId = \'' + blCode + '\' AND Loan_Application__r.LeadSource = \'' + leadSource + '\' AND OwnerId IN (SELECT UserId FROM AccountTeamMember WHERE AccountId = \'' + blCode + '\' AND TeamMemberRole = \'' +teamRole+ '\') AND Owner.Type = \'User\'';
            
            if (String.isNotBlank(leadNumber)){
                myQuery += ' AND Loan_Application__r.Lead_number__c Like  \'%' + leadNumber + '%\'';
            }
            if (String.isNotBlank(benCode)){
                List<User> userList = [SELECT Id FROM User WHERE EmployeeNumber Like : '%'+benCode+'%'];
                myQuery += ' AND OwnerId IN :userList';
            }
            
            myQuery += ' ORDER BY Loan_Application__r.Lead_number__c ASC LIMIT 50000';
            
            System.debug('myQuery: '+myQuery);
            List<Case> caseList = Database.query(myQuery);
            System.debug('result: '+ caseList.size());
            
            return caseList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Case> getCMUCaseRecords(Id blCode, String leadSource, String teamRole, String leadNumber, String benCode) {
        try {
            String myQuery = '';
            myQuery = 'SELECT Id, CaseNumber, Account.Name, TYPEOF Owner WHEN User THEN EmployeeNumber, Name, IsActive WHEN Group THEN Name END, Loan_Application__c, Loan_Application__r.Lead_number__c FROM Case WHERE Id NOT IN (SELECT Case__c FROM Reassign_Owner_Log__c WHERE Approval_Status__c = \'Pending\' AND Reassignment_Type__c = \'CMU Case Assignment\') AND RecordType.DeveloperName = \'CMU_Request\' AND Loan_Application__r.JourneyStopScenarioFound__c = false AND Loan_Application__c != null AND Loan_Application__r.Is_Revoked__c = false';
            myQuery += ' AND AccountId = \'' + blCode + '\' AND Loan_Application__r.LeadSource = \'' + leadSource + '\' AND Status = \'Pending with Sales\' AND OwnerId IN (SELECT UserId FROM AccountTeamMember WHERE AccountId = \'' + blCode + '\' AND TeamMemberRole = \'' +teamRole+ '\') AND Owner.Type = \'User\'';
            
            if (String.isNotBlank(leadNumber)){
                myQuery += ' AND Loan_Application__r.Lead_number__c Like  \'%' + leadNumber + '%\'';
            }
            if (String.isNotBlank(benCode)){
                List<User> userList = [SELECT Id FROM User WHERE EmployeeNumber Like : '%'+benCode+'%'];
                myQuery += ' AND OwnerId IN :userList';
            }
            
            myQuery += ' ORDER BY Loan_Application__r.Lead_number__c ASC LIMIT 50000';
            
            System.debug('myQuery: '+myQuery);
            List<Case> caseList = Database.query(myQuery);
            System.debug('result: '+ caseList.size());
            
            return caseList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Reassign_Owner_Log__c> getReassignOwnerRecords(String reassignmentType, Id reassignmentApprover) {
        try {
            return [SELECT Id, Loan_Application__r.Account.Name, Loan_Application__r.Lead_number__c, Case__r.CaseNumber, Loan_Application__r.Owner.EmployeeNumber, Loan_Application__r.Owner.Name, Loan_Application__r.Owner.IsActive, TYPEOF Case__r.Owner WHEN User THEN EmployeeNumber, Name, IsActive END, New_Record_Owner__r.EmployeeNumber, New_Record_Owner__r.Name, New_Record_Owner__r.IsActive FROM Reassign_Owner_Log__c WHERE Approval_Status__c = 'Pending' AND Reassignment_Type__c = :reassignmentType AND Reassignment_Approver__c = :reassignmentApprover];
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<sObject> getEligibleUserRecords(String reassignmentType, String leadSource, String teamRole, Id branchAccountId, String searchTerm) {
        try {
            List<Account> selectedAccount = [SELECT Id, Name, State__c FROM Account WHERE Id = :branchAccountId LIMIT 1];
            Set<String> eligibleRoleSet = new Set<String>();
            Boolean forTwoWheeler = selectedAccount[0]?.Name?.toLowercase()?.contains('tw') ? true : false;
            String selectedState = selectedAccount[0].State__c;
            String myQuery = 'SELECT UserId, User.Name, User.EmployeeNumber FROM AccountTeamMember WHERE User.IsActive = true AND User.EmployeeNumber Like \'%' + searchTerm + '%\'';
            
            if(reassignmentType == 'Lead Assignment') {
                myQuery += ' AND AccountId = :branchAccountId';
            } else if(reassignmentType == 'CMU Case Assignment') {
                myQuery += ' AND AccountId = :branchAccountId';
            } else if(reassignmentType == 'FI Case Assignment' ) {
                myQuery += ' AND Account.Name LIKE ' + (forTwoWheeler ? ('\'%tw%\'') : ('\'%pv%\''));
            } else if(reassignmentType == 'CVO Assignment') {
                if(String.isBlank(selectedState)) {
                    return null;
                } else {
                    List<Account> eligibleAccList = [SELECT Id FROM Account WHERE State__c = :selectedAccount[0].State__c];
                    myQuery += ' AND AccountId IN :eligibleAccList';
                    myQuery += ' AND Account.Name LIKE ' + (forTwoWheeler ? ('\'%tw%\'') : ('\'%pv%\''));
                }
            }

            if(reassignmentType == 'CVO Assignment') {
                eligibleRoleSet.add('CVO');
            } else {
                if(!forTwoWheeler) {
                    eligibleRoleSet.add('BE');
                } else {
                    if(reassignmentType == 'Lead Assignment') {
                        if(String.isBlank(leadSource)) {
                            eligibleRoleSet.add('MA');
                        } else if(leadSource == 'D2C') {
                            eligibleRoleSet.addAll(new Set<String>{'MO', 'MA'});
                        } else if(leadSource == 'OLA') {
                            eligibleRoleSet.add(teamRole == 'BE' ? 'BE' : 'PE');
                        }
                    } else if(reassignmentType == 'FI Case Assignment') {
                        if(String.isBlank(leadSource)) {
                            eligibleRoleSet.addAll(new Set<String>{'FI', 'MO', 'BE'});
                        } else if(leadSource == 'D2C') {
                            eligibleRoleSet.addAll(new Set<String>{'FI'});
                        } else if(leadSource == 'OLA') {
                            eligibleRoleSet.add(teamRole == 'BE' ? 'BE' : 'PE');
                        }
                    } else if(reassignmentType == 'CMU Case Assignment') {
                        if(String.isBlank(leadSource)) {
                            eligibleRoleSet.add('MA');
                        } else if(leadSource == 'OLA') {
                            eligibleRoleSet.add(teamRole == 'BE' ? 'BE' : 'PE');
                        }
                    }
                }
            }

            myQuery += ' AND TeamMemberRole IN :eligibleRoleSet GROUP BY UserId, User.Name, User.EmployeeNumber ORDER BY User.EmployeeNumber LIMIT 2000';
            List<sObject> sObjectList = Database.query(myQuery);
            return sObjectList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String submitReassignmentRequest(String reassignmentType, String approverRole, Id reassignmentRequestorId, Id newOwnerId, Id branchId, List<Id> selectedRecordIdList, Boolean autoApproveRequest) {
        Savepoint sp = null;
        Boolean isSuccess = false;
        String msg = '';
        try {
            sp = Database.setSavepoint();
            String myQuery = '';
            List<Reassign_Owner_Log__c> reassignLogsToInsertList = new List<Reassign_Owner_Log__c>();
            Map<String,Object> mapData = new Map<String,Object>();
            
            if(String.isNotBlank(reassignmentType) && String.isNotBlank(approverRole) && String.isNotBlank(reassignmentRequestorId) && String.isNotBlank(newOwnerId) && String.isNotBlank(branchId) && !selectedRecordIdList.isEmpty() && autoApproveRequest != null) {
                
                List<AccountTeamMember> approverList = [SELECT UserId FROM AccountTeamMember WHERE AccountId = :branchId AND User.IsActive = true AND TeamMemberRole = :approverRole];
                
                if(approverList.size() > 0) {
                    if(reassignmentType == 'Lead Assignment' || reassignmentType == 'CVO Assignment') {
                        myQuery = 'SELECT Id, OwnerId FROM Opportunity WHERE Id IN :selectedRecordIdList';
                    } else if(reassignmentType == 'FI Case Assignment' || reassignmentType == 'CMU Case Assignment') {
                        myQuery = 'SELECT Id, OwnerId, Loan_Application__c FROM Case WHERE Id IN :selectedRecordIdList';
                    }
                    
                    List<sObject> sObjectList = Database.query(myQuery);
                    
                    for(sObject sObjectRecord :sObjectList) {
                        if(newOwnerId != (String) sObjectRecord.get('OwnerId')){
                            Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
                            
                            if(reassignmentType == 'Lead Assignment' || reassignmentType == 'CVO Assignment') {
                                reassignLogRecord.Loan_Application__c = sObjectRecord.Id;
                            } else if(reassignmentType == 'FI Case Assignment' || reassignmentType == 'CMU Case Assignment') {
                                reassignLogRecord.Loan_Application__c = (Id) sObjectRecord.get('Loan_Application__c');
                                reassignLogRecord.Case__c = sObjectRecord.Id;
                            }
                            reassignLogRecord.Previous_Record_Owner__c = (Id) sObjectRecord.get('OwnerId');
                            reassignLogRecord.New_Record_Owner__c = newOwnerId;
                            reassignLogRecord.Approval_Status__c = autoApproveRequest == false ? 'Pending' : 'Approved';
                            reassignLogRecord.Reassignment_Type__c = reassignmentType;
                            reassignLogRecord.Reassignment_Requestor__c = reassignmentRequestorId;
                            reassignLogRecord.Reassignment_Approver__c = approverList[0].UserId;
                            
                            reassignLogsToInsertList.add(reassignLogRecord);
                        }else{
                            msg = 'You have selected the same lead owner. Select another member';
                        }
                    }
                    
                    if(reassignLogsToInsertList.size() > 0) {
                        Database.insert(reassignLogsToInsertList);
                        if(autoApproveRequest) {
                            IND_LWC_ReassignOwner.reassignOwnerLogsList = reassignLogsToInsertList;
                            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(IND_LWC_ReassignOwner.processReassignmentRequest(reassignmentType, null, autoApproveRequest));
                            if((Boolean)result.get('isSuccess')) {
                                isSuccess = true;
                            } else {
                                if(String.isNotBlank((String)result.get('msg'))) {
                                    msg = (String)result.get(msg);
                                } else {
                                    msg = System.Label.ExceptionMessage;
                                }
                            }
                        } else {
                            User recipientRecord = [SELECT Id, Name, UserType, EmployeeNumber FROM User WHERE Id = :approverList[0].UserId LIMIT 1];
                            User currentUser = [SELECT Id, Name, UserType, EmployeeNumber FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
                            
                            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Owner_Reassignment'];
                            Messaging.CustomNotification noti = new Messaging.CustomNotification();
                            
                            noti.setTitle(reassignmentType+' request');
                            noti.setBody(reassignmentType+' request from CVO (' + currentUser.Name + ' | ' + currentUser.EmployeeNumber + ')' +' is sent to you for validation. Click here to view the request details.');
                            noti.setNotificationTypeId(notificationType.Id);
                            if(recipientRecord.UserType == 'Standard') {
                                noti.setTargetPageRef('{"type":standard__navItemPage,"attributes":{"apiName":"Reassign_Owner"}}');
                            } else {
                                Map<String, Object> pageRef = new Map<String, Object> {
                                    'type' => 'standard__webPage',
                                    'attributes' => new Map<String, Object> {
                                        'url' => System.Label.IBL_Community_Partners_URL+'/s/reassign-owner'
                                    }
                                };
                                noti.setTargetPageRef(JSON.serialize(pageRef));
                            }
                            noti.send(new Set<String> { recipientRecord.Id });
                            isSuccess = true;
                        }
                    }
                } else {
                    msg = 'No eligible approver found for your request.';
                }
            }
            mapData.put('isSuccess', isSuccess);
            mapData.put('msg', msg);
            return JSON.serialize(mapData);
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String processReassignmentRequest(String reassignmentType, List<Id> selectedRecordIdList, Boolean isApproved) {
        Savepoint sp = null;
        Boolean isSuccess = false;
        Boolean autoApproveRequest = false;
        String msg = '';
        Map<String,Object> mapData = new Map<String,Object>();
        try {
            List<Case> casesToUpdateList = new List<Case>();
            List<Opportunity> oppToUpdateList = new List<Opportunity>();
            List<OpportunityTeamMember> oppTeamMemberToInsertList = new List<OpportunityTeamMember>();
            List<Reassign_Owner_Log__c> reassignLogsToProcessList = new List<Reassign_Owner_Log__c>();
            List<Reassign_Owner_Log__c> reassignLogsToUpsertList = new List<Reassign_Owner_Log__c>();
            Set<String> recipientIdSet = new Set<String>();

            String myQuery = 'SELECT Id, Approval_Status__c, Reassignment_Type__c, Reassignment_Requestor__c, Reassignment_Approver__c, Loan_Application__c, Loan_Application__r.Account.Name, Loan_Application__r.Lead_number__c, Case__c, Case__r.CaseNumber, Loan_Application__r.Owner.EmployeeNumber, Loan_Application__r.Owner.Name,Loan_Application__r.Name, Loan_Application__r.Owner.IsActive, TYPEOF Case__r.Owner WHEN User THEN EmployeeNumber, Name, IsActive END, New_Record_Owner__c, New_Record_Owner__r.EmployeeNumber, New_Record_Owner__r.Name, New_Record_Owner__r.IsActive,New_Record_Owner__r.ContactId,New_Record_Owner__r.UserType FROM Reassign_Owner_Log__c WHERE Id IN';
            
            if(selectedRecordIdList != null || selectedRecordIdList?.size() > 0) {
                myQuery += ' :selectedRecordIdList';
                reassignLogsToProcessList = Database.query(myQuery);
            } else if(IND_LWC_ReassignOwner.reassignOwnerLogsList != null && IND_LWC_ReassignOwner.reassignOwnerLogsList?.size() > 0) {
                autoApproveRequest = true;
                Set<Id> ids = new Set<Id>(new Map<Id, Reassign_Owner_Log__c>(IND_LWC_ReassignOwner.reassignOwnerLogsList).keySet());
                myQuery += ' :ids';
                reassignLogsToProcessList = Database.query(myQuery);
            } else {
                mapData.put('isSuccess', isSuccess);
                mapData.put('msg', msg);
                return JSON.serialize(mapData);
            }
            
            if(!isApproved) {
                for(Reassign_Owner_Log__c reassignRecord :reassignLogsToProcessList) {
                    reassignRecord.Approval_Status__c = 'Rejected';
                    reassignLogsToUpsertList.add(reassignRecord);
                    
                    recipientIdSet.add(reassignRecord.New_Record_Owner__c);
                }
            } else {
                Set<Id> oppIdSet = new Set<Id>();
                Set<Id> caseIdSet = new Set<Id>();
                for(Reassign_Owner_Log__c reassignRecord :reassignLogsToProcessList) {
                    if(! reassignRecord.New_Record_Owner__r.IsActive) {
                        msg = 'The user selected for re-assignment is Inactive.';
                        mapData.put('isSuccess', isSuccess);
                        mapData.put('msg', msg);
                        return JSON.serialize(mapData);
                    } else {
                        recipientIdSet.add(reassignRecord.New_Record_Owner__c);
                        if(reassignmentType == 'Lead Assignment' || reassignmentType == 'CVO Assignment') {
                            oppIdSet.add(reassignRecord.Loan_Application__c);
                        } else if(reassignmentType == 'FI Case Assignment' || reassignmentType == 'CMU Case Assignment') {
                            caseIdSet.add(reassignRecord.Case__c);
                        }
                    }
                }
                if(reassignmentType == 'Lead Assignment' || reassignmentType == 'CVO Assignment') {
                    List<Opportunity> oppList = new List<Opportunity>();
                    if(reassignmentType == 'Lead Assignment') {
                        oppList = [SELECT Id, OwnerId, (SELECT Id, OwnerId, Accept_Case__c, CMU_Case_Accepted_By__c, ContactId FROM Cases__r WHERE RecordType.DeveloperName = 'CMU_Request' AND Status = 'Pending with Sales') FROM Opportunity WHERE Id IN :oppIdSet];
                    } else if(reassignmentType == 'CVO Assignment') {
                        oppList = [SELECT Id, OwnerId, (SELECT Id, OwnerId, Accept_Case__c, CMU_Case_Accepted_By__c, ContactId FROM Cases__r WHERE RecordType.DeveloperName = 'TVR') FROM Opportunity WHERE Id IN :oppIdSet];
                    }
                    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(oppList);
                    
                    for(Reassign_Owner_Log__c reassignRecord :reassignLogsToProcessList) {
                        if(oppMap.containsKey(reassignRecord.Loan_Application__c)) {
                            Opportunity oppRecord = oppMap.get(reassignRecord.Loan_Application__c);
                            oppRecord.OwnerId = reassignRecord.New_Record_Owner__c;
                            oppToUpdateList.add(oppRecord);

                            if(oppRecord.Cases__r.size() > 0) {
                                for(Case caseRecord :oppRecord.Cases__r) {
                                    Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
                                    reassignLogRecord.Loan_Application__c = reassignRecord.Loan_Application__c;
                                    reassignLogRecord.Case__c = caseRecord.Id;
                                    reassignLogRecord.Previous_Record_Owner__c = caseRecord.OwnerId;
                                    reassignLogRecord.New_Record_Owner__c = reassignRecord.New_Record_Owner__c;
                                    reassignLogRecord.Approval_Status__c = 'Approved';
                                    reassignLogRecord.Reassignment_Type__c = reassignmentType;
                                    reassignLogRecord.Reassignment_Requestor__c = reassignRecord.Reassignment_Requestor__c;
                                    reassignLogRecord.Reassignment_Approver__c = reassignRecord.Reassignment_Approver__c;
                                    reassignLogsToUpsertList.add(reassignLogRecord);
                                    if(reassignRecord.New_Record_Owner__r.ContactId!=null){
                                        caseRecord.ContactId = reassignRecord.New_Record_Owner__r.ContactId;
                                    }
                                    if(caseRecord.Accept_Case__c){
                                        caseRecord.CMU_Case_Accepted_By__c = reassignRecord.New_Record_Owner__c;
                                    }
                                    caseRecord.OwnerId = reassignRecord.New_Record_Owner__c;
                                    casesToUpdateList.add(caseRecord);
                                }
                            }
                            
                            if(isApproved && !autoApproveRequest) {
                                reassignRecord.Approval_Status__c = 'Approved';
                                reassignLogsToUpsertList.add(reassignRecord);
                            }
                            if(reassignmentType == 'CVO Assignment') {
                                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                                oppTeamMember.UserId = reassignRecord.New_Record_Owner__c;
                                oppTeamMember.OpportunityId = reassignRecord.Loan_Application__c;
                                oppTeamMember.TeamMemberRole = 'CVO';
                                oppTeamMember.OpportunityAccessLevel = 'Edit'; 
                                oppTeamMemberToInsertList.add(oppTeamMember);
                            }
                        }
                    }
                } else if(reassignmentType == 'FI Case Assignment' || reassignmentType == 'CMU Case Assignment') {
                    Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, OwnerId, ContactId, Accept_Case__c, CMU_Case_Accepted_By__c, TYPEOF Owner WHEN User THEN UserRole.DeveloperName END FROM Case WHERE Id IN :caseIdSet]);
                    
                    for(Reassign_Owner_Log__c reassignRecord :reassignLogsToProcessList) {
                        if(caseMap.containsKey(reassignRecord.Case__c)) {
                            Case caseRecord = caseMap.get(reassignRecord.Case__c);
                            if(reassignRecord.New_Record_Owner__r.ContactId!=null){
                                caseRecord.ContactId = reassignRecord.New_Record_Owner__r.ContactId;
                            }
                            if(caseRecord.Accept_Case__c){
                                caseRecord.CMU_Case_Accepted_By__c = reassignRecord.New_Record_Owner__c;
                            }
                            caseRecord.OwnerId = reassignRecord.New_Record_Owner__c;
                            
                            // if(reassignmentType == 'CMU Case Assignment') {
                            //     caseRecord.Status = 'Pending with CMU';
                            // }
                            casesToUpdateList.add(caseRecord);
                            
                            if(isApproved && !autoApproveRequest) {
                                reassignRecord.Approval_Status__c = 'Approved';
                                reassignLogsToUpsertList.add(reassignRecord);
                            }
                            if(reassignmentType == 'FI Case Assignment') {
                                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                                oppTeamMember.UserId = reassignRecord.New_Record_Owner__c;
                                oppTeamMember.OpportunityId = reassignRecord.Loan_Application__c;
                                oppTeamMember.TeamMemberRole = caseMap.get(reassignRecord.Case__c).Owner.UserRole.DeveloperName;
                                oppTeamMember.OpportunityAccessLevel = 'Edit'; 
                                oppTeamMemberToInsertList.add(oppTeamMember);
                            }
                        }
                    }
                }
                
                if(casesToUpdateList.size() > 0) {
                    update casesToUpdateList;
                }
                if(oppToUpdateList.size() > 0) {
                    update oppToUpdateList;
                }
                if(oppTeamMemberToInsertList.size() > 0) {
                    insert oppTeamMemberToInsertList;
                }
            }

            if(!recipientIdSet.isEmpty()) {
                if(reassignLogsToUpsertList.size() > 0){
                    upsert reassignLogsToUpsertList;
                }
                
                CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Owner_Reassignment'];

                for(Reassign_Owner_Log__c reassignRecord :reassignLogsToProcessList) {
                    if(recipientIdSet.contains(reassignRecord.New_Record_Owner__c) && ((reassignmentType == 'Lead Assignment' || reassignmentType == 'CVO Assignment') || (reassignRecord.New_Record_Owner__r.UserType == 'Standard' && (reassignmentType == 'FI Case Assignment' || reassignmentType == 'CMU Case Assignment')))){
                        Messaging.CustomNotification noti = new Messaging.CustomNotification();             
                        noti.setNotificationTypeId(notificationType.Id);
                        if(reassignmentType == 'Lead Assignment' || reassignmentType == 'CVO Assignment') {
                            noti.setTitle(reassignmentType+' request - ' + reassignRecord.Loan_Application__r.Name);
                            noti.setBody('Your ' +reassignmentType + ' request has been ' + (isApproved ? 'Approved.' : 'Rejected.') +'  Click here to take action on this Loan Application.');
                            noti.setTargetId(reassignRecord.Loan_Application__c);
                        } 
                        else if(reassignmentType == 'FI Case Assignment' || reassignmentType == 'CMU Case Assignment') {
                            noti.setTitle(reassignmentType+' request - ' + reassignRecord.Case__r.CaseNumber);
                            noti.setBody('Your ' +reassignmentType + ' request has been ' + (isApproved ? 'Approved.' : 'Rejected.') +' Click here to take action on this case.');
                            noti.setTargetId(reassignRecord.Case__c);
                        }
                        
                        noti.send(new Set<String> { reassignRecord.New_Record_Owner__c});
                    }
                }
            }
            
            isSuccess = true;
            mapData.put('isSuccess', isSuccess);
            mapData.put('msg', msg);
            return JSON.serialize(mapData);
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
}