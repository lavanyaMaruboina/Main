public without sharing class ind_leadAssignmentForNCMUser{

    @AuraEnabled
    public static List<Opportunity> getLeadDetails(String searchValue,String searchOption){
        try{
            Set<String> stageNameList = new Set<String>{'Credit Processing','Post Sanction Checks and Documentation','Pre Disbursement Check','Disbursement Request Preparation'};

            if(searchOption == 'searchByLeadNumber'){
                List<Opportunity> oppList = [SELECT ID,Name,stageName,Owner.name,owner.Profile.name,owner.UserRole.name ,owner.UserRoleId,AccountId from Opportunity where stageName IN :stageNameList AND Lead_Number__c =: searchValue AND Product_Type__c = 'Tractor' AND Is_Revoked__c = false  LIMIT 1];
                if(oppList.size()>0){
                    return oppList;
                }
            }else if(searchOption == 'searchByUserName'){
                List<Opportunity> oppList = [SELECT ID,Name,Owner.name,owner.Profile.name,stageName,owner.UserRole.name ,owner.UserRoleId,AccountId from Opportunity where stageName IN :stageNameList AND  Product_Type__c = 'Tractor' AND Owner.name =: searchValue AND Is_Revoked__c = false ];
                if(oppList.size()>0){
                    return oppList;
                }
            }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('ind_leadAssignmentForNCMUser', 'getLeadDetails', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getStackTraceString());
        }
        return null;
    }
    @AuraEnabled
    public static void changeOwnerFromLeadAssignment(String listOfLeads){
        try {
            System.debug('listOfLeads---' + listOfLeads);
            List<leadWrapper> officeDetailData = (List<leadWrapper>)JSON.deserialize(listOfLeads, List<leadWrapper>.class);
            Set<ID> oppIDForCase = new Set<ID>();
            List<Opportunity> oppListToBEUpdated = new List<Opportunity>();
            Set<String> newOwnerId = new Set<String>();
            Map<ID,ID> oppIDWithNewOwnerID = new Map<ID,ID>();
            for(leadWrapper ldObj : officeDetailData){
                Opportunity opp = new Opportunity();
                opp.Id = ldObj.Id;
                opp.ownerId = ldObj.selectedRecordId;
                opp.Name = ldObj.Name;
                oppIDWithNewOwnerID.put(ldObj.Id,ldObj.selectedRecordId);
                oppListToBEUpdated.add(opp);
                oppIDForCase.add(ldObj.Id);
            }
            List<Case> updatedCase = new List<Case>();
            
            List<Case>  cases= [Select Id,OwnerId,Status,Loan_Application__c,Loan_Application__r.OwnerId from case where Status !='Closed' AND Loan_Application__c IN : oppIDForCase];
            for(Case c : cases){
                if (oppIDWithNewOwnerID.containsKey(c.Loan_Application__c) && c.OwnerId == c.Loan_Application__r.OwnerId) {
                    c.OwnerId = oppIDWithNewOwnerID.get(c.Loan_Application__c);
                    updatedCase.add(c);
                }
            }
            System.debug('updatedCase--'+updatedCase);
            System.debug('oppListToBEUpdated--'+oppListToBEUpdated);

            if(oppListToBEUpdated.size() > 0){
                update oppListToBEUpdated;
                if(updatedCase.size()>0){
                    update updatedCase;
                }
                for(Opportunity opp : oppListToBEUpdated){
                    System.debug('opp.Id--'+opp.Id);
                    String message = 'Loan Application ' + opp.Name + ' has been assigned to you.';
                    newOwnerId.add(opp.ownerId);
                    notifyUsers(newOwnerId,opp.Id,message);
                }
            }
        System.debug('the data is '+ officeDetailData);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

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
            ErrorLoggerUtil.logErrorEvent('ind_leadAssignmentForNCMUser', 'notifyUsers', System.Label.Apex, ex,loanId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    public class leadWrapper {
        public String Id;
        public String selectedRecordId;
        public String Name;
        
        public leadWrapper(String Id, String selectedRecordId, String Name){
            this.Id = Id;
            this.selectedRecordId = selectedRecordId;
            this.Name = Name;
      }
    }
}