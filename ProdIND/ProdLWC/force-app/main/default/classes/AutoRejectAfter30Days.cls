/**
* @Name         AutoRejectAfter30Days
* @Author       Rajat Jaiswal
* @Description  This batch will run everyday and auto rejects the camn loan application and creates the corresponding proposal log if the cam has been on hold for more than 30 days.
**/
public class AutoRejectAfter30Days  implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date LastDate = System.today().addDays(-30);
        return Database.getQueryLocator([SELECT Id,Loan_Application__c,Proposal_Status__c FROM CAM__c WHERE Is_Hold__c=true AND Deviation_Created_Date__c =:LastDate WITH SECURITY_ENFORCED]);
    }
    public void execute(Database.BatchableContext BC, List<CAM__c> camList){
        try {
            if(!camList.isEmpty()){
                set<id> parentCamId = new set<Id>();
                List<Opportunity> loanApplicationListToReject = new List<Opportunity>();
                List<Proposal_Approval_Log__c> proposalApprovalLogListToInsert = new List<Proposal_Approval_Log__c>();
                Id recType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Forward log').getRecordTypeId();
                for(CAM__c camObj:camList){
                    camObj.Proposal_Status__c='Reject';
                    parentCamId.add(camObj.Id);  
                    if(camObj.Loan_Application__c!=NULL){
                        loanApplicationListToReject.add(new Opportunity(Id = camObj.Loan_Application__c, StageName = 'Rejected'));
                    }
                    proposalApprovalLogListToInsert.add(new Proposal_Approval_Log__c(
                        Decision__c = 'Reject',
                        Name = System.Label.Auto_Rejected,
                        Parent_CAM__c = camObj.Id,
                        RecordTypeId  = recType
                    ));
                }
                List<Deviation__c> deviationList = [SELECT Id,Approval_Status__c,Parent_CAM__c FROM Deviation__c WHERE Approval_Status__c!='Rejected' AND  Parent_CAM__c IN:parentCamId WITH SECURITY_ENFORCED];
                if(deviationList.size()>0){
                    for(Deviation__c deviationObj:deviationList){
                        deviationObj.Approval_Status__c = 'Rejected';
                    }
                    Update deviationList;
                }
                Update loanApplicationListToReject;
                Update camList;
                Insert proposalApprovalLogListToInsert;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('AutoRejectAfter30Days', 'execute', e.getTypeName(), e, '');
        }
    }
    public void finish(Database.BatchableContext BC){}
}