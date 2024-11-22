/**
* @Name         SendPendingApprovalNotificationBatch
* @Author       Rajat Jaiswal
* @Description  This batch will run every hour for passenger vehicles and every 4 hour for two wheelers and send an email (containing cam summary screen link) to all the users who has assigned deviations and they have not approved it..
**/
public with sharing class SendPendingApprovalNotificationBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful,Database.AllowsCallouts  {
    public List<RequestWrapper> requestWrappperList;
    public Set<Id> userIdSet;
    public Boolean isPV;
    
    public SendPendingApprovalNotificationBatch(Boolean invokePV){
        this.isPV = invokePV;
        requestWrappperList = new List<RequestWrapper>();
        userIdSet = new Set<Id>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        //prashanth - added Sanction_Status__c, Is_Pre_Approved__c, Leadsource fields in the below query.
        String pvQuery = 'SELECT Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Loan_Application__r.Vehicle_Type__c,Parent_CAM__r.Loan_Application__r.Product_Type__c,Parent_CAM__r.Loan_Application__r.Name, Role__c, EmployeeID__c,Parent_CAM__r.Loan_Application__r.LeadSource, Parent_CAM__r.Loan_Application__r.Sanction_Status__c,Parent_CAM__r.Loan_Application__r.Is_Pre_Approved__c FROM Deviation__c WHERE Parent_CAM__r.Action_Taken__c=false AND Parent_CAM__r.Loan_Application__r.Product_Type__c=\'Passenger Vehicles\' AND Approval_Status__c!=\'Approved\' AND Parent_CAM__r.Loan_Application__r.StageName !=\'Revoke\' AND Parent_CAM__r.Trigger_Deviations__c=true AND Parent_CAM__r.Loan_Application__r.Is_Revoked__c != true AND Approval_Status__c != \'Rejected\' AND Proposal_Status__c != \'Rejected\' AND Parent_CAM__r.Loan_Application__r.Is_Revoked__c != true AND Parent_CAM__r.Loan_Application__r.StageName =\'Credit Processing\' AND Parent_CAM__c NOT IN (SELECT Parent_CAM__c FROM Proposal_Approval_Log__c WHERE Approval_Status__c IN (\'Rejected\',\'Reject\'))';

        String twoVQuery = 'SELECT Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.Name,Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Loan_Application__r.Vehicle_Type__c,Parent_CAM__r.Loan_Application__r.Product_Type__c, Role__c, EmployeeID__c,Parent_CAM__r.Loan_Application__r.LeadSource, Parent_CAM__r.Loan_Application__r.Sanction_Status__c,Parent_CAM__r.Loan_Application__r.Is_Pre_Approved__c FROM Deviation__c WHERE Parent_CAM__r.Action_Taken__c=false AND Parent_CAM__r.Loan_Application__r.Product_Type__c=\'Two Wheeler\' AND Approval_Status__c!=\'Approved\' AND Parent_CAM__r.Loan_Application__r.StageName !=\'Revoke\' AND Parent_CAM__r.Trigger_Deviations__c=true AND Approval_Status__c != \'Rejected\' AND Proposal_Status__c != \'Rejected\' AND Parent_CAM__r.Loan_Application__r.Is_Revoked__c != true AND Parent_CAM__r.Loan_Application__r.StageName =\'Credit Processing\' AND Parent_CAM__c NOT IN (SELECT Parent_CAM__c FROM Proposal_Approval_Log__c WHERE Approval_Status__c IN (\'Rejected\',\'Reject\'))';
        String query;
        if(isPV == true){
            query = pvQuery;
        }
        else{
            query = twoVQuery;
        }
        return Database.getQueryLocator(query);
    }
    //action taken is the field which tracks whether the user has taken the final action on the cam or not on cam & approval screen.
    
    public void execute(Database.BatchableContext BC, List<Deviation__c> deviationList){
        try {
            Datetime targetDate = System.today();
            String dayOfWeek = targetDate.format('EEEE');
            Boolean runBatchBoolean = system.now().hour() < 21 && system.now().hour() >9  ? true : false;
            if((runBatchBoolean && !dayOfWeek.containsIgnoreCase('Saturday') && !dayOfWeek.containsIgnoreCase('Sunday')) || Test.isRunningTest()){
                Set<String> pvUserIdSet = new Set<String>();
                Set<String> twoVUserIdSet = new Set<String>();
                List<User> userList = [SELECT Id,Email,Name,Profile.UserLicense.Name FROM User WHERE IsActive = true];
                
                Map<Id,User> userIdVsObjMap = new Map<Id,User>();
                for (User userObj : userList) {
                    if(!userIdVsObjMap.containsKey(userObj.Id)){
                        userIdVsObjMap.put(userObj.Id, userObj);
                    }
                }
                
                for (Deviation__c deviationVar : deviationList) {
                    //prashanth - Bypass send email functionality for PA (OR) STP Loan Applications for D2C.
                    if(deviationVar.Parent_CAM__r.Loan_Application__r.LeadSource == 'D2C'){
                        if(deviationVar.Parent_CAM__r.Loan_Application__r.Is_Pre_Approved__c || deviationVar.Parent_CAM__r.Loan_Application__r.Sanction_Status__c =='STP'){
                            continue;
                        }
                    }
                    //prashanth-End
                    
                    List<String> relatedUserIdList = deviationVar.EmployeeID__c != null ? deviationVar.EmployeeID__c.split(',') : new List<String>();
                    if(relatedUserIdList.size() > 0){
                        if(deviationVar.Parent_CAM__r.Loan_Application__r.Product_Type__c != null && deviationVar.Parent_CAM__r.Loan_Application__r.Product_Type__c == 'Passenger Vehicles'){
                            for (String userId : relatedUserIdList) {
                                if(userIdVsObjMap.containsKey(userId) && !userIdSet.contains(userId)){
                                    User userObj = userIdVsObjMap.get(userId);
                                    if (deviationVar.Role__c != null && !deviationVar.Role__c.contains('NPH')) {
                                        sendEmailRequest(deviationVar,userObj);
                                    }else if (deviationVar.Role__c != null && deviationVar.Role__c.contains('NPH') && system.now().hour() == 10) {
                                        sendEmailRequest(deviationVar,userObj);
                                    }
                                }
                            }
                        }
                        if(deviationVar.Parent_CAM__r.Loan_Application__r.Product_Type__c!=null && deviationVar.Parent_CAM__r.Loan_Application__r.Product_Type__c=='Two Wheeler'){
                            for (String userId : relatedUserIdList) {
                                if(userIdVsObjMap.containsKey(userId) && !userIdSet.contains(userId)){
                                    User userObj = userIdVsObjMap.get(userId);
                                    sendEmailRequest(deviationVar,userObj);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('SendPendingApprovalNotificationBatch', 'execute', System.Label.Apex, e, null);
        }
    }
    
    public void sendEmailRequest(Deviation__c deviationVar,User userObj){
        List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='Pending_Application_Notification'];
        if(deviationVar != null && userObj != null && etList != null){
            RequestWrapper emailRequestWrapper = new RequestWrapper();
            emailRequestWrapper.name = userObj.Name;
            Boolean communityCheck = userObj.Profile?.UserLicense.Name == 'Partner Community';
            emailRequestWrapper.leadId = deviationVar.Parent_CAM__r.Loan_Application__c;
            emailRequestWrapper.loanApplicationId = deviationVar.Parent_CAM__r.Loan_Application__c;
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
        if(!Test.isRunningTest()){
            //Database.executeBatch(new SendForwardedUsersNotificationBatch(isPV, userIdSet), 1);
        }
    }
    public void execute(SchedulableContext sc) {
        if(isPV){
            String pvCron = '0 0 0/1 1/1 * ? *';//every hour
            if(!Test.isRunningTest()){
                Database.executeBatch(new SendPendingApprovalNotificationBatch(true), 1);
            }
        }
        else {
            String twoVCron = '0 0 0/4 1/1 * ? *';//every 4 hour
            if(!Test.isRunningTest()){
                Database.executeBatch(new SendPendingApprovalNotificationBatch(false), 1);
            }
        }
    }
}