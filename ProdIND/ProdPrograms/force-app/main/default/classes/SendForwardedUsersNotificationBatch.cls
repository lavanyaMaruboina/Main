/**
* @Name         SendPendingApprovalNotificationBatch
* @Author       Rajat Jaiswal
* @Description  This batch will run every hour for passenger vehicles and every 4 hour for two wheelers and send an email (containing cam summary screen link) to all the users who has been forwarded the cam and they have not taken any action on it.
**/
public with sharing class SendForwardedUsersNotificationBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful,Database.AllowsCallouts {
    // public List<User> pvUserMailList;
    // public List<User> twoVUserMailList;
    public Set<Id> userIdSet;
    public List<RequestWrapper> requestWrappperList;
    
    public Boolean isPV;
    
    public SendForwardedUsersNotificationBatch(Boolean invokePV, Set<Id> userIdSet) {
        this.isPV = invokePV;
        requestWrappperList = new List<RequestWrapper>();
        this.userIdSet = userIdSet;
    }
    
    public SendForwardedUsersNotificationBatch(Boolean invokePV) {
        this.isPV = invokePV;
        requestWrappperList = new List<RequestWrapper>();
        userIdSet = new Set<Id>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        //prashanth - added Sanction_Status__c, Is_Pre_Approved__c, Leadsource fields in the below query.
        String pvQuery = 'SELECT Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Loan_Application__r.Vehicle_Type__c,Parent_CAM__r.Loan_Application__r.Product_Type__c,Forwarded_Employee__c,Forwarded_Role__c,Parent_CAM__r.Action_Taken__c,Parent_CAM__r.Loan_Application__r.LeadSource, Parent_CAM__r.Loan_Application__r.Sanction_Status__c,Parent_CAM__r.Loan_Application__r.Is_Pre_Approved__c FROM Proposal_Approval_Log__c WHERE Parent_CAM__r.Action_Taken__c=false AND Parent_CAM__r.Loan_Application__r.Product_Type__c=\'Passenger Vehicles\' AND RecordType.Name=\'Forward log\' AND Parent_CAM__r.Loan_Application__r.StageName !=\'Revoke\' AND Parent_CAM__r.Trigger_Deviations__c=true';
        String twoVQuery = 'SELECT Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Loan_Application__r.Vehicle_Type__c,Parent_CAM__r.Loan_Application__r.Product_Type__c,Forwarded_Employee__c,Forwarded_Role__c,Parent_CAM__r.Action_Taken__c,Parent_CAM__r.Loan_Application__r.LeadSource, Parent_CAM__r.Loan_Application__r.Sanction_Status__c,Parent_CAM__r.Loan_Application__r.Is_Pre_Approved__c FROM Proposal_Approval_Log__c WHERE Parent_CAM__r.Action_Taken__c=false AND Parent_CAM__r.Loan_Application__r.Product_Type__c=\'Two Wheeler\' AND RecordType.Name=\'Forward log\' AND Parent_CAM__r.Loan_Application__r.StageName !=\'Revoke\' AND Parent_CAM__r.Trigger_Deviations__c=true';
        String query;
        if(isPV==true){
            query = pvQuery;
        }
        else{
            query = twoVQuery;
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Proposal_Approval_Log__c> proposalList){
        try {
            Datetime targetDate = System.today();
            String dayOfWeek = targetDate.format('EEEE');
            Boolean runBatchBoolean = system.now().hour() < 21 && system.now().hour() >9  ? true : false;
            if((runBatchBoolean && !dayOfWeek.containsIgnoreCase('Saturday') && !dayOfWeek.containsIgnoreCase('Sunday')) || Test.isRunningTest()){
                List<User> userList = [SELECT Id,Email,Name,Profile.UserLicense.Name FROM User];
                Map<Id,User> userIdVsObjMap = new Map<Id,User>();
                for (User userObj : userList) {
                    if(!userIdVsObjMap.containsKey(userObj.Id)){
                        userIdVsObjMap.put(userObj.Id, userObj);
                    }
                }
                for (Proposal_Approval_Log__c proposalObj : proposalList) {
                    //prashanth - Bypass send email functionality for PA (OR) STP Loan Applications for D2C.
                    if(proposalObj.Parent_CAM__r.Loan_Application__r.LeadSource == 'D2C'){
                        if(proposalObj.Parent_CAM__r.Loan_Application__r.Is_Pre_Approved__c || proposalObj.Parent_CAM__r.Loan_Application__r.Sanction_Status__c =='STP'){
                            continue;
                        }
                    }
                    //prashanth-End
                    
                    if(proposalObj.Parent_CAM__r.Loan_Application__r.Product_Type__c!=null && proposalObj.Parent_CAM__r.Loan_Application__r.Product_Type__c=='Passenger Vehicles'){
                        if(userIdVsObjMap.containsKey(proposalObj.Forwarded_Employee__c) && !userIdSet.contains(proposalObj.Forwarded_Employee__c)){
                            User userObj = userIdVsObjMap.get(proposalObj.Forwarded_Employee__c);
                            if (proposalObj.Forwarded_Role__c != null && !proposalObj.Forwarded_Role__c.contains('NPH')) {
                                sendEmailRequest(proposalObj,userObj);
                            }else if (proposalObj.Forwarded_Role__c != null && proposalObj.Forwarded_Role__c.contains('NPH') && system.now().hour() == 10) {
                                sendEmailRequest(proposalObj,userObj);
                            }
                        }
                    }
                    if(proposalObj.Parent_CAM__r.Loan_Application__r.Product_Type__c!=null && proposalObj.Parent_CAM__r.Loan_Application__r.Product_Type__c=='Two Wheeler'){
                        if(userIdVsObjMap.containsKey(proposalObj.Forwarded_Employee__c) && !userIdSet.contains(proposalObj.Forwarded_Employee__c)){
                            User userObj = userIdVsObjMap.get(proposalObj.Forwarded_Employee__c);
                            sendEmailRequest(proposalObj,userObj);
                        }
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SendForwardedUsersNotificationBatch', 'execute', System.Label.Apex, e, null);
        }
    }
    
    public void sendEmailRequest(Proposal_Approval_Log__c proposalLogObj,User userObj){
        List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='Pending_Application_Notification'];
        if(proposalLogObj != null && userObj != null && etList != null){
            RequestWrapper emailRequestWrapper = new RequestWrapper();
            emailRequestWrapper.name = userObj.Name;
            Boolean communityCheck = userObj.Profile?.UserLicense.Name == 'Partner Community';
            emailRequestWrapper.leadId = proposalLogObj.Parent_CAM__r.Loan_Application__c;
            emailRequestWrapper.loanApplicationId = proposalLogObj.Parent_CAM__r.Loan_Application__c;
            emailRequestWrapper.emailTo = userObj.Email;
            emailRequestWrapper.emailCC =  userObj.Email;
            emailRequestWrapper.emailSubject = etList[0].Subject;
            String emailBody = etList[0].HtmlValue.replace('{!Receiving_User.Name}',userObj.Name);
            if (communityCheck) {
                emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Community_Partners_URL+'/s/cam-summary-screen');
            } else {
                emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Lightning_Base_URL+'/lightning/n/CAM_Screen');
            }
            emailRequestWrapper.emailBody = emailBody;
            userIdSet.add(userObj.Id);
            IntegrationEngine.doEmailServiceCalloutwithoutContinuation(JSON.serialize(emailRequestWrapper));
        }
    }
    
    public void finish(Database.BatchableContext bc){
    }
    public void execute(SchedulableContext sc) {
        if(isPV){
            String pvCron = '0 0 0/1 1/1 * ? *';//every hour
            Database.executeBatch(new SendForwardedUsersNotificationBatch(true));
        } else {
            String twoVCron = '0 0 0/4 1/1 * ? *';//every 4 hour
            Database.executeBatch(new SendForwardedUsersNotificationBatch(false));
        }
    }
}