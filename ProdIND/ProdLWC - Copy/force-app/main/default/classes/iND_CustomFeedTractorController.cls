/**
 * @description       : 
 * @author            : Prashant Dixit
 * @group             : 
 * @Created modified on  : 11-01-2023
 * @last modified by  : Gaurav Rawat
**/
public without sharing class iND_CustomFeedTractorController {

    @AuraEnabled(cacheable=true)
    public static String getOrgBaseUrl(){
        String redirecURL = '';
        List<Profile> profileList = new List<Profile>([SELECT Id, Name,UserType FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1]);
        if(profileList.size() > 0 && profileList[0].Usertype == 'PowerPartner'){
            redirecURL = Label.IBL_Community_Partners_URL + '/s/detail';
        }else{
            String sfdcBaseURL = System.URL.getOrgDomainUrl().toExternalForm();
            redirecURL = sfdcBaseURL.replace('.my.salesforce.com','.lightning.force.com');
        }
        return redirecURL;
    }

    @AuraEnabled
    public static string getAccountId(String documentId){
        try {
            List<Documents__c> documentList = [Select Id,Opportunity_Relation__c,Opportunity_Relation__r.AccountId from Documents__c Where Id=:documentId Limit 1];
            if(!documentList.isEmpty()){
                if(documentList[0].Opportunity_Relation__c != null && documentList[0].Opportunity_Relation__r.AccountId != null)
                    return documentList[0].Opportunity_Relation__r.AccountId;
                return null;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case> getAllCasesRelatedToAccount(Id documentId){
        try {
            System.debug('documentId-->'+documentId);
            if(documentId!= null){
                System.debug('else');
                List<Case> caseList = [SELECT Id,CaseNumber, Owner.Name, CreatedDate FROM Case Where Case_Document__c=:documentId];
                if(!caseList.isEmpty()){
                    return caseList;
                } 
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static Case createQueryCaseRecords(Id userId, Id documentId, String body){
        if(userId != null && documentId != null){
            Id queryRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();

            List<Case> caseList = [SELECT Id FROM Case WHERE Case_Document__c=:documentId AND OwnerId=:userId];
            List<Documents__c> documentList = [SELECT Id,Applicant__c,Opportunity_Relation__c,Opportunity_Relation__r.Name,Opportunity_Relation__r.CreatedBy.Name,Opportunity_Relation__r.AccountId FROM Documents__c WHERE Id=:documentId LIMIT 1];
            String cvoUsername = '';
            String rcuUsername = '';
            String rcuAgencyName = '';
            if(documentList.size()>0){
                String loanApplicationId = documentList[0].Opportunity_Relation__c;
                for(OpportunityFieldHistory historyObj : [select id,CreatedBy.Name from OpportunityFieldHistory  where OpportunityId =:loanApplicationId AND CreatedBy.Profile.NAME IN ('IBL TF CVO','IBL Partner Community TF CVO') AND (Field ='StageName' OR Field = 'Sub_Stage__c') ORDER BY CreatedDate DESC LIMIT 1]){
                    cvoUsername = historyObj.CreatedBy.Name;
                }
                if(String.isBlank(cvoUsername)){
                    List<Opportunity> oppList = [Select Id,Owner.Profile.Name,Owner.Name From Opportunity Where Id =: loanApplicationId];
                    if(oppList.size() > 0 && oppList[0].Owner.Profile.Name.contains('CVO')){
                        cvoUsername = oppList[0].Owner.Name;
                    }
                }
                List<Case> rcuCaseList = new List<Case>([Select id,RCU_Manager__r.Name, RCU_Agent__c from Case Where Loan_Application__c =: loanApplicationId AND RecordType.Name = 'RCU' AND ParentId = null LIMIT 1]);
                if(rcuCaseList.size() > 0){
                    List<User> userList = [Select Id,Contact.Account.Name From User Where Id=: rcuCaseList[0].RCU_Agent__c];
                    rcuAgencyName = userList.size() > 0 ? userList[0].Contact.Account.Name : '';
                    rcuUsername = rcuCaseList[0].RCU_Manager__r.Name;
                }
            }   
            
            User userProfile = [SELECT Id, Profile.Name FROM User WHERE Id=:userId];
            String profileName = userProfile.Profile.Name;
            String caseStatus;
            if(profileName.contains('CVO')){
                caseStatus = 'Assigned to CVO';
            }
            else if(profileName.contains('BE')){
                caseStatus = 'Assigned to BE';
            }
            else if(profileName.contains('RCU Manager')){
                caseStatus = 'Assigned to RCU Manager';
            }
            else{
                caseStatus = null;
            }

            if(caseList.size()==0){
                Case cs = new Case();
                
                if(!documentList.isEmpty()){
                    cs.Loan_Application__c= documentList[0].Opportunity_Relation__c;
                    cs.Applicant__c=documentList[0].Applicant__c;
                    cs.Subject='RCU Document Queries - '+documentList[0].Opportunity_Relation__r.Name;
                }
                else{
                    cs.Subject='RCU Document Queries';
                }  
                cs.OwnerId = userId;
                cs.Status = caseStatus;
                cs.Priority = 'Medium';
                cs.RecordTypeId = queryRecordtypeId;
                cs.Case_Document__c = documentId;
                insert cs;

                CaseComment cc = new CaseComment();
                cc.CommentBody = body;
                cc.ParentId = cs.Id;
                cc.IsPublished = true;
                insert cc;


                List<CaseTeamRole> role = [select Id from CaseTeamRole where Name = 'caseaccess' limit 1];

                List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();

                if(role.size()>0){
                    CaseTeamMember caseTeamMember1 = new CaseTeamMember();
                    caseTeamMember1.ParentId = cs.Id;
                    caseTeamMember1.TeamRoleId = role[0].Id;
                    caseTeamMember1.MemberId = userId;
                    caseTeamMemberList.add(caseTeamMember1);

                    CaseTeamMember caseTeamMember2 = new CaseTeamMember();
                    caseTeamMember2.ParentId = cs.Id;
                    caseTeamMember2.TeamRoleId = role[0].Id;
                    caseTeamMember2.MemberId = userInfo.getUserId();
                    caseTeamMemberList.add(caseTeamMember2);
                }
                
                if(caseTeamMemberList.size()>0)
                    insert caseTeamMemberList;

                

                CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer' LIMIT 1];
                Messaging.CustomNotification noti = new Messaging.CustomNotification();
                
                List<User> userList = [Select Id,Contact.Account.Name From User Where Id=: userId];

                String loanId = documentList.size() > 0 ? documentList[0].Opportunity_Relation__r.Name : ''; 
                String loanSubmitter = 'Your Loan Submitter';
                String be = documentList.size() > 0 ? documentList[0].Opportunity_Relation__r.CreatedBy.Name : ''; 
                String cvo = cvoUsername;
                String rcuManager = rcuUsername; 
                String rcuAgency = rcuAgencyName; //RCU_Agent__c -> contact -> Account -> Name

                String notificationBody = 'Sir/Madam,\nThis is to notify that an query has been assigned to you related to RCU document verification. - ' + '\nQuery: ' + body + '\nLoan Id: ' + loanId + '\nLoan Submitter: ' + loanSubmitter + '\nBE: ' + be + '\nCVO: ' + cvo + '\nRCU Manager: ' + rcuManager + '\nRCU Agency: ' + rcuAgency;

                noti.setBody(notificationBody);
                noti.setTitle('Query Case Assignment');
                noti.setNotificationTypeId(notificationType.Id);
                noti.setTargetId(cs.Id);
                noti.send(new Set<String> { userId });

                return cs;
            }
            else{
                return null;
            }
        } 
        return null;  
    }

    @AuraEnabled
    public static WrapperData getAllPreviousChat(Id caseId) {
        WrapperData wrapData = new WrapperData();
        wrapData.createdbyId =[SELECT Id,CreatedById FROM Case WHERE Id =:caseId].CreatedById;
        wrapData.caseRecords = [SELECT Id,Format(CreatedDate), CreatedBy.Name, CommentBody FROM CaseComment WHERE ParentId=:caseId ORDER BY CreatedDate DESC];

        return wrapData;
    }

    @AuraEnabled
    public static String updateCase(Id caseId, Id createdById) {
        if(caseId != null && createdById != null){
            Case caseRecord = new Case();
            caseRecord.Id = caseId;
            caseRecord.OwnerId = createdById;
            caseRecord.Status = 'Query Answered';
            update caseRecord;
            return 'Case Updated Successfully';
        }
        return null;
    }

    public class WrapperData {
        @AuraEnabled
        public List<CaseComment> caseRecords{get;set;}
        @AuraEnabled
        public String createdbyId{get;set;}

    }
}