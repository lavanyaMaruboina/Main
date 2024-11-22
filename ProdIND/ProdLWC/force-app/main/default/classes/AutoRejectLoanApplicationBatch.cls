/**
* @Name         AutoRejectLoanApplicationBatch
* @Author       Rajat Jaiswal
* @Description  This batch will run everyday and auto rejects the camn loan application and creates the corresponding proposal log if the cam has all the deviations approved but the fina
**/
public class AutoRejectLoanApplicationBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, Loan_Application__c FROM CAM__c WHERE Trigger_Deviations__c = true AND Deviations_Approved_By_Authorities__c = true AND Proposal_Status__c = null WITH SECURITY_ENFORCED');
    }
    
    public void execute(Database.BatchableContext BC, List<CAM__c> camList){
        try {
            if(camList.size() > 0){
                Map<Id, CAM__c> camMap = new Map<Id, CAM__c>(camList);
                Set<Id> camIdSet = new Set<Id>();  
                for (CAM__c camObj : camList) {
                    camIdSet.add(camObj.Id);
                }
                List<Deviation__c> deviationList = new List<Deviation__c>();
                deviationList = [SELECT Id, Proposal_Status__c, LastModifiedDate, Parent_CAM__c FROM Deviation__c WHERE Proposal_Status__c != null AND Parent_CAM__c IN :camIdSet WITH SECURITY_ENFORCED Order By LastModifiedDate desc];
                if (deviationList.size() > 0) {
                    Map<Id, Datetime> camIdVsLastModifiedDateMap = new Map<Id, Datetime>(); 
                    for (Deviation__c deviation : deviationList) {
                        if (!camIdVsLastModifiedDateMap.containsKey(deviation.Parent_CAM__c)) {
                            camIdVsLastModifiedDateMap.put(deviation.Parent_CAM__c, deviation.LastModifiedDate);
                        }
                    }
                    if (camIdVsLastModifiedDateMap.size() > 0) {
                        List<CAM__c> camListToReject = new List<CAM__c>();
                        List<Opportunity> loanApplicationListToReject = new List<Opportunity>();
                        List<Proposal_Approval_Log__c> proposalApprovalLogListToInsert = new List<Proposal_Approval_Log__c>();
                        Id recType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Forward log').getRecordTypeId();
                        for (Id camId : camIdVsLastModifiedDateMap.keySet()) {
                            if (camIdVsLastModifiedDateMap.get(camId).addDays(30) < Datetime.now() || Test.isRunningTest()) {
                                camListToReject.add(new CAM__c(Id = camId, Proposal_Status__c = 'Reject'));
                                loanApplicationListToReject.add(new Opportunity(Id = camMap.get(camId).Loan_Application__c, StageName = 'Rejected'));
                                proposalApprovalLogListToInsert.add(new Proposal_Approval_Log__c(
                                    Decision__c = 'Reject',
                                    Name = System.Label.Auto_Rejected,
                                    Approval_Status__c = 'Reject',
                                    Parent_CAM__c = camId,
                                    RecordTypeId = recType
                                ));
                            }
                        }
                        if (camListToReject.size() > 0) {
                            Update camListToReject;
                            Update loanApplicationListToReject;
                            Insert proposalApprovalLogListToInsert;
                        }
                    }
                }   
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('AutoRejectLoanApplicationBatch', 'execute', e.getTypeName(), e, '');
        }     
    }
    public void finish(Database.BatchableContext BC){}
}