/**
* @Name         CAMApprovalLogController
* @Author       Rajat Jaiswal
* @Description  This Class is used to creating and showing the CAM in the CAM and Approval Log Screen.
**/
public with sharing class CAMApprovalLogController{
    public static String level;
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to check whether the user can access the CAM & approval cmp or not by checking the journey status value of loan application not present in the IBLConfiguration metadata records.
***********************************************/
    @AuraEnabled
    public static Boolean canAccessCAMApprovalLog(String loanAppId){
        try {
            List<Opportunity> loanAppList = [SELECT Id, Name, Journey_Status__c FROM Opportunity WHERE Id = :loanAppId WITH SECURITY_ENFORCED LIMIT 1];
            if (loanAppList.size() > 0) {
                if (loanAppList[0].Journey_Status__c == 'Stop') {
                    return true;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'canAccessCAMApprovalLog', e.getTypeName(), e, loanAppId);
        }
        return false;
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to generate the CAM and returns the cam record along with loan amount & net IRR fetched from Final terms.
***********************************************/
    @AuraEnabled
    public static CAMDataWrapper generateCAM(String loanAppId){
        try {
            if(loanAppId!=null){
                //Duplicate record : Added  Loan_Number__c this unique field 
                CAM__c camRecord = new CAM__c(Loan_Application__c = loanAppId, Active__c = true,Trigger_Deviations__c=false, Generation_Date__c = Date.Today() ,Loan_Number__c =loanAppId ); 
                CAMDataWrapper wrapperObj = new CAMDataWrapper();
                List<Final_Term__c> finaltermsList = new List<Final_Term__c>(); //CISP-131
                finaltermsList = [SELECT id,OfferengineMinLoanAmount__c,Advance_EMI__c,Loan_Application__c,Loan_Application__r.Loan_amount__c,Loan_Application__r.Total_Funded_Premium__c, OfferengineMaxLoanAmount__c,Loan_Amount__c,Net_IRR__c,Inputted_IRR__c,Loan_Application__r.Product_Type__c,Service_charges__c,Documentation_charges__c,Stamping_charges__c,Due_date_shift_charges__c,RTO_prefix__c,Trade_certificate__c,Mfr_Exp_Reimburse_Amt__c,Mfr_Exp_Reimburse_percent__c,Mfr_Exp_Reimburse_Type__c,Dealer_incentive_amount_main_dealer__c,Dealer_Disc_to_Customer__c,Gift_through_dealer_amount__c,DSM_Incentive1__c,DSM_Incentive2__c,Refered_By__c,Rreferrer_Incentive__c,Referrer_Name__c,Provisional_Channel_Cost__c,DSA_pay__c,DSM_Name1__c,DSM_Name2__c,Emp_Name__c,Emp_No__c,EMI_Amount__c,Branch__c,Is_Loan_Amount_Change_From_CAM__c, First_EMI_Date__c,Second_EMI_Date__c,Holiday_period__c,Installment_Type__c FROM Final_Term__c WHERE Loan_Application__c = :loanAppId WITH SECURITY_ENFORCED  LIMIT 1];//CISP-2507
                if (finaltermsList.size() > 0) {
                    wrapperObj.productType = String.isNotEmpty(finaltermsList[0].Loan_Application__r.Product_Type__c)? finaltermsList[0].Loan_Application__r.Product_Type__c : '';
                    if (finaltermsList[0].Loan_Application__r.Product_Type__c == 'Passenger Vehicles') {
                        wrapperObj.netIRR = finaltermsList[0].Net_IRR__c!=null ?finaltermsList[0].Net_IRR__c:null;   
                    } else if (finaltermsList[0].Loan_Application__r.Product_Type__c == 'Two Wheeler') {
                        wrapperObj.netIRR = finaltermsList[0].Inputted_IRR__c!=null ?finaltermsList[0].Inputted_IRR__c:null;   
                    }  
                    wrapperObj.loanAmount = String.isNotEmpty(finaltermsList[0].Loan_amount__c) ? Decimal.valueOf(finaltermsList[0].Loan_amount__c)+finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c : finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c;
                    wrapperObj.finalTermsRecord = finaltermsList[0];  //CISP-131
                }
                wrapperObj.hasCommitteeDeviation = false;
                wrapperObj.approvedByMandatoryRoles = getApprovalFromMandatoryRoles(loanAppId);
                IBL_Configuration__mdt config = IBL_Configuration__mdt.getInstance('default');
                if(config != null){
                    wrapperObj.checkForMandatoryRole = config.Check_for_Mandatory_Role__c;
                    wrapperObj.mandatoryForwardRole = config.Mandatory_Forward_Role__c;
                }
                try {
                    insert camRecord;
                    wrapperObj.camRecord = camRecord;
                    AmlCheckData.updateAMLCheckToCA(loanAppId);
                    
                } catch(Exception e) {
                    ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'generateCAM', e.getTypeName(), e, loanAppId);
                }
                return wrapperObj;
            }
            return null;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'generateCAM', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to fetch all the availabe roles from the Account team to forward the cam .
***********************************************/
    @AuraEnabled
    public static String getAvailableRoles(String loanAppId){
        List<SelectOptionValues> teamRoleOptions = new List<SelectOptionValues>(); 
        Set<String> uniqueRoleList = new Set<String>();
        try {
            if(String.isNotEmpty(loanAppId)){
                List<Opportunity> opportunityList = [SELECT AccountId FROM Opportunity WHERE Id =:loanAppId LIMIT 1];
                if(opportunityList.size()>0 && opportunityList[0].AccountId!=null){
                    List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole FROM AccountTeamMember WHERE AccountId=:opportunityList[0].AccountId LIMIT 10000];
                    if(!accountTeamMemberList.isEmpty()){
                        IBL_Configuration__mdt config = IBL_Configuration__mdt.getInstance('default');
                        List<String> rolesToSkip = config.RolesToSkipInForwardTo__c.split(',');
                        for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                            if(accountTeamObj.TeamMemberRole!=null && !rolesToSkip.contains(accountTeamObj.TeamMemberRole)){
                                uniqueRoleList.add(accountTeamObj.TeamMemberRole);
                            }
                        }
                    }
                }
            }
            for (String roleObj : uniqueRoleList) {
                if(roleObj!=System.Label.SystemAdmin){
                    SelectOptionValues option = new SelectOptionValues(roleObj,roleObj);
                    teamRoleOptions.add(option);
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getAvailableRoles', e.getTypeName(), e, loanAppId);
        }
        return JSON.serialize(teamRoleOptions);
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to check whether the cam is already forwarded to SCM or not.
***********************************************/
    @AuraEnabled
    public static Boolean isCAMForwardedToSCM(String camId){
        try {
            List<Proposal_Approval_Log__c> forwardLogs = [ SELECT Id FROM Proposal_Approval_Log__c  WHERE Parent_CAM__c = :camId AND
                                                          RecordType.Name = 'Forward log' AND Forwarded_Role__c = 'SCM' WITH SECURITY_ENFORCED LIMIT 10000];
            if (forwardLogs.size() > 0) {
                return true;
            } else {
                return false;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'isCAMForwardedToSCM', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    @AuraEnabled
    public static Boolean isCAMForwardedToCA(String camId){
        try {
            List<Proposal_Approval_Log__c> forwardLogs = [ SELECT Id FROM Proposal_Approval_Log__c  WHERE Parent_CAM__c = :camId AND
                                                          RecordType.Name = 'Forward log' AND Forwarded_Role__c = 'CA' WITH SECURITY_ENFORCED LIMIT 10000];
            if (forwardLogs.size() > 0) {
                return true;
            } else {
                return false;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'isCAMForwardedToCA', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to forward the CAM by creating the proposal approval log of forward log recordtype and send the mail as well to the user.
***********************************************/
    @AuraEnabled
    public static Boolean forwardCAM(String camId, String role, String remarks){
        try {
            CAM__c cam = [SELECT Id,Loan_Application__c, Loan_Application__r.AccountId, Loan_Application__r.Name,Loan_Application__r.Product_Type__c FROM CAM__c WHERE id=:camId WITH SECURITY_ENFORCED];
            Id accountId = cam.Loan_Application__r.AccountId;
            List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive FROM AccountTeamMember WHERE AccountId= :accountId AND TeamMemberRole=:role AND user.IsActive=TRUE WITH SECURITY_ENFORCED]; //CISP-4176
            List<AccountTeamMember> currentUserRoleList = [SELECT TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accountId AND UserId = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1]; 
            User runningUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            String str = 'Success';
            Id recType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Forward log').getRecordTypeId();
            List<Proposal_Approval_Log__c> proposalLogToInsert = new List<Proposal_Approval_Log__c>();
            if(str=='Success'){
                for(AccountTeamMember roleMember : roleList){
                    Proposal_Approval_Log__c logRec = new Proposal_Approval_Log__c();
                    logRec.Name = String.valueOf(Math.floor(Math.random() * 10000).intValue()); // CISP-16665
                    logRec.Proposal_description__c = 'Forward Approval Log - ' + cam.Loan_Application__r.Name; // CISP-16665
                    logRec.Parent_CAM__c = camId;
                    logRec.Date_and_Time__c = System.now();
                    logRec.RecordTypeId = recType;
                    logRec.Forwarded_On__c=System.now();
                    logRec.Forwarded_By__c = runningUser.Name;
                    logRec.Forwarded_Role__c = role;
                    logRec.Forwarding_Employee__c =runningUser.Id;
                    logRec.Forwarded_Employee__c =roleMember.UserId;
                    logRec.Proposal_Remark__c=remarks;  //CISP-2332
                    if(currentUserRoleList.size() > 0){
                        logRec.Forwarding_Role__c = currentUserRoleList[0].TeamMemberRole;
                    }
                    proposalLogToInsert.add(logRec);
                }
                if(proposalLogToInsert.size()>0){
                    insert proposalLogToInsert;
                    return true;
                }
                else{
                    return false;
                }
            }
            return false;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'forwardCAM', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        } 
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to get all the proposal approval logs related to the cam.
***********************************************/
    @AuraEnabled
    public static List<Proposal_Approval_Log__c> getProposalApprovalLog(String camId){
        try {
            List<Proposal_Approval_Log__c> approvalLogs = [
                SELECT Forwarded_On__c,Forwarded_By__c, Forwarded_Role__c, Forwarding_Role__c,Proposal_description__c,Parent_CAM__r.Loan_Application__r.Product_Type__c,
                Forwarded_Employee__r.Name, Remark__c, Log_Status__c, Role__c, Approval_Status__c, Name,SF_Role__c, Parent_CAM__r.Required_CRM_IRR__c ,Parent_CAM__r.Loan_Amount__c,Hold_Remark__c,Decision__c,Vehicle_ID__c,Parent_CAM__c,
                Loan_Ammount__c,Required_CRM_IRR__c,Date_and_Time__c, Forwarded_Employee__c,Proposal_Approval_Log_ID__c,Action__c,Proposal_Approval_Condition__c,CreatedDate,Proposal_Rejected_by_any_authority__c,RecordType.Name,Proposal_Remark__c FROM Proposal_Approval_Log__c WHERE Parent_CAM__C=: camId ORDER BY CreatedDate DESC limit 10000];
            return approvalLogs;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getProposalApprovalLog', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to send the mail to all the assigned user of the deviations.
***********************************************/
    @AuraEnabled
    public static List<RequestWrapper> triggerDeviationMail(String camId){
        List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
        try {
            if(camId!=null){
                List<Deviation__c> deviationList = [SELECT Id,Name,DeviationID__c,Deviation_Level__c,Role__c,Parent_CAM__c,Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Trigger_Deviations__c,Parent_CAM__r.Loan_Application__r.Name , EmployeeID__c,Deviation_Description__c FROM Deviation__c WHERE Parent_CAM__c=:camId WITH SECURITY_ENFORCED];
                Id accountId = deviationList[0].Parent_CAM__r.Loan_Application__r.AccountId; 
                List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive FROM AccountTeamMember WHERE Account.id= :accountId AND user.IsActive=TRUE WITH SECURITY_ENFORCED]; //CISP-4176
                List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='Deviation_EMail1'];
                for (Deviation__c deviation : deviationList){
                    for (AccountTeamMember roleMember : roleList){
                        if(deviation.Role__c != null && deviation.Role__c.contains(roleMember.TeamMemberRole) && etList.size()>0){
                            RequestWrapper emailRequestWrapper = new RequestWrapper();
                            emailRequestWrapper.leadId = deviation.Parent_CAM__r.Loan_Application__c;
                            emailRequestWrapper.emailTo = roleMember.User.Email;
                            emailRequestWrapper.emailCC =  roleMember.User.Email;
                            String emailTemplateSubject = etList[0].Subject.replace('{!Opportunity.Name}', deviation.Parent_CAM__r.Loan_Application__r.Name);
                            emailTemplateSubject = emailTemplateSubject.replace('{!Deviation__c.Deviation_Level__c}', deviation.Deviation_Level__c !=null ? deviation.Deviation_Level__c : '');
                            emailTemplateSubject = emailTemplateSubject.replace('{!User.Name}', roleMember.User.Name !=null ? roleMember.User.Name : '');
                            emailRequestWrapper.emailSubject = emailTemplateSubject;
                            String emailBody = etList[0].HtmlValue.replace('{!Receiving_User.Name}',roleMember.User.Name);
                            emailBody = emailBody.replace('{!Opportunity.Name}',  deviation.Parent_CAM__r.Loan_Application__r.Name);
                            emailBody = emailBody.replace('{!Deviation__c.Deviation_Level__c}',deviation.Deviation_Level__c !=null ? deviation.Deviation_Level__c : '');
                            emailBody = emailBody.replace('{!Deviation__c.Deviation_Description__c}',deviation.Deviation_Description__c !=null ? deviation.Deviation_Description__c : '');
                            emailBody = emailBody.replace('{!CAM__c.Id}',deviation.Parent_CAM__c);
                            emailRequestWrapper.emailBody = emailBody;
                            emailRequestWrapperList.add(emailRequestWrapper);
                        }
                    }
                }
                CAM__c camObj = new CAM__c(Id = camId,Trigger_Deviations__c = true);
                update camObj;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'triggerDeviationMail', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
        }
        return emailRequestWrapperList;
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to getting TeamMemberRole and showing it to forward child component on CAM and Approval Log.
***********************************************/
    @AuraEnabled(cacheable=true)
    public static String getTeamRoles(){
        try {
            List<SelectOptionValues> teamRoleOptions = new List<SelectOptionValues>(); 
            teamRoleOptions.add(new SelectOptionValues('--None--', '')); 
            Map<String, Schema.SObjectField> pkMap = AccountTeamMember.sObjectType.getDescribe().fields.getMap();
            List<Schema.PicklistEntry> pl  = pkMap.get('TeamMemberRole').getDescribe().getPicklistValues();
            for(Schema.PicklistEntry p : pl)
                teamRoleOptions.add(new SelectOptionValues(p.getLabel(), p.getValue()));        
            return JSON.serialize(teamRoleOptions);
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getTeamRoles', e.getTypeName(), e, '');
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to update the action of user on conditionl approval logs and will create a new proposal approval log of proposal log recordtype signifying the changes made by user.
***********************************************/
    @AuraEnabled
    public static Boolean updateConditionalProposalLogs(String proposalLogList,List<Proposal_Approval_Log__c> originalProposalLogList,String currentUserRole){
        try {
            if(proposalLogList!=null){
                List<ConditionalApprovalLogWrapper> proposalLogWrapperList = (List<ConditionalApprovalLogWrapper>)JSON.deserialize(proposalLogList, List<ConditionalApprovalLogWrapper>.class);
                String parentCamId;
                Map<Id,Proposal_Approval_Log__c> proposalIdVsLogMap = new Map<Id,Proposal_Approval_Log__c>(originalProposalLogList);
                List<Proposal_Approval_Log__c> updateProposalList = new List<Proposal_Approval_Log__c>();
                for (ConditionalApprovalLogWrapper newProp : proposalLogWrapperList) {
                    for (Proposal_Approval_Log__c oldProp : originalProposalLogList) {
                        if(newProp.id==oldProp.Id && (newProp.action!=oldProp.Action__c || newProp.remark!=oldProp.Proposal_Remark__c)){
                            parentCamId = oldProp.Parent_CAM__c;
                            updateProposalList.add(new Proposal_Approval_Log__c(Id=newProp.id,Action__c=newProp.action,Proposal_Remark__c=newProp.remark));
                        }
                    }
                }
                if(updateProposalList.size()>0){
                    update updateProposalList;
                    List<Proposal_Approval_Log__c> newProposalList = new List<Proposal_Approval_Log__c>();
                    Id proposalRecType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Proposal log').getRecordTypeId();
                    for(Proposal_Approval_Log__c updatedProp:updateProposalList){
                        if(proposalIdVsLogMap.containsKey(updatedProp.Id)){
                            Proposal_Approval_Log__c existedProposalLogObj = proposalIdVsLogMap.get(updatedProp.Id);
                            Proposal_Approval_Log__c proposalLogObj = new Proposal_Approval_Log__c();
                            proposalLogObj.Parent_CAM__c = existedProposalLogObj.Parent_CAM__c;
                            proposalLogObj.Name = String.valueOf(Math.floor(Math.random() * 10000).intValue()); // CISP-16665
                            proposalLogObj.Proposal_description__c = 'Proposal Action taken on Conditional Approve Proposal by '+UserInfo.getName(); // CISP-16665
                            proposalLogObj.Role__c = currentUserRole;
                            proposalLogObj.Deviation_Id__c = existedProposalLogObj.Deviation_Id__c;
                            proposalLogObj.Approval_Status__c = updatedProp.Action__c;
                            proposalLogObj.Proposal_Remark__c = updatedProp.Proposal_Remark__c;
                            if(proposalRecType!=null){
                                proposalLogObj.RecordTypeId = proposalRecType;
                            }
                            newProposalList.add(proposalLogObj);
                        }
                    }
                    if(newProposalList.size()>0){
                        insert newProposalList;
                    }
                }
                return true;
            }
            return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'updateConditionalProposalLogs', e.getTypeName(), e, '');
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This wrapper is used for displaying the details of conditionally approved logs.
***********************************************/
    public Class ConditionalApprovalLogWrapper{
        @auraenabled public string id;
        @auraenabled public string action;
        @auraenabled public string remark;
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This wrapper is used to store the dropdown values in the component.
***********************************************/
    public class SelectOptionValues{
        public String label;
        public String value;
        public SelectOptionValues(String l, String v) {
            this.label = l;
            this.value = v;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to return the Vehicle Detail which related to Loan Application.
***********************************************/
    @AuraEnabled
    public static List<Vehicle_Detail__c> getVehicleIDs(String loanApplicationID){
        try{
            List<Vehicle_Detail__c> vehicleID=[ Select id, Name from Vehicle_Detail__c where Loan_Application__r.id=:loanApplicationID];
            return vehicleID;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getVehicleIDs', e.getTypeName(), e, loanApplicationID);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Gaurav Rawat
* @Purpose: This method is used to return the Final term Detail which related to Loan Application.
***********************************************/
    @AuraEnabled
    public static List<Final_Term__c> getFinalTerms(String loanApplicationID){
        try{
            List<Final_Term__c> finalTermList=[ Select id,Loan_Amount__c,Required_CRM_IRR__c,Gross_IRR__c,Net_IRR__c,Vehicle_Detail__c,Vehicle_Detail__r.Total_Funded_Amount__c,Vehicle_Detail__r.Variant__c,L1_L2_Final_Terms_Changed__c from Final_Term__c where Loan_Application__r.id=:loanApplicationID AND Vehicle_Detail__r.Approval_Status__c = 'Approved' ORDER BY Vehicle_Detail__r.CreatedDate ASC];
            return finalTermList;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getVehicleIDs', e.getTypeName(), e, loanApplicationID);
            return null;
        }
    }
    @AuraEnabled
    public static string proposalApprove(String camRecordId,String proposalStatus){
        String alertMessage = '';
        try{
            CAM__c camRecord = [SELECT Loan_Application__c,Is_CAM_Reopen__c,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c,Loan_Application__r.AccountId FROM CAM__c WHERE Id = :camRecordId LIMIT 1]; 
            Boolean isCurrentUserACMSCM = false;
            String currentUserRole = '';
            List<AccountTeamMember> accountTeamMember = [SELECT Id, Level__c,TeamMemberRole FROM AccountTeamMember WHERE AccountId =:camRecord.Loan_Application__r.AccountId AND UserId = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
            if (accountTeamMember.size() > 0) {
                List<String> camApprovalRoleLabelList = System.Label.camApprovalRoleLabel.split(',');
                currentUserRole = accountTeamMember[0].TeamMemberRole;
                if(camApprovalRoleLabelList.contains(accountTeamMember[0].TeamMemberRole) && camRecord.CAM_Submitted_by_ACM_SCM__c == false && camRecord.Submit_for_Approval_UserId__c == UserInfo.getUserId()){ 
                    isCurrentUserACMSCM = true;
                }
            }            
            String recordId = camRecord.Loan_Application__c;

            Boolean allVehicleApprovedORAccepted = true;
            for(Vehicle_Detail__c vehicleObj: [SELECT Approval_Status__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :recordId WITH SECURITY_ENFORCED LIMIT 10000]){
                if(String.isBlank(vehicleObj.Approval_Status__c)){
                    allVehicleApprovedORAccepted = false;
                    break;
                }
            }
            if(isCurrentUserACMSCM == true && allVehicleApprovedORAccepted == true){
                List<Proposal_Approval_Log__c> proposalLogList = new List<Proposal_Approval_Log__c>();
                Id proposalRecType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Proposal log').getRecordTypeId();
                if(proposalStatus!=null){
                    Proposal_Approval_Log__c proposalLogObj = new Proposal_Approval_Log__c();
                    proposalLogObj.Parent_CAM__c = camRecord.Id;
                    proposalLogObj.Name = 'Proposal Action taken by '+UserInfo.getName();
                    proposalLogObj.Role__c = currentUserRole;
                    proposalLogObj.Approval_Status__c = proposalStatus;
                    if(proposalRecType!=null){
                        proposalLogObj.RecordTypeId = proposalRecType;
                    }
                    proposalLogList.add(proposalLogObj);
                    if (camRecord.Is_CAM_Reopen__c) {
                        camRecord.Is_CAM_Reopen__c = false;
                        camRecord.Proposal_Status__c = proposalStatus == 'Approve' ? 'Accept' : proposalStatus;
                        camRecord.Action_Taken__c = true;
                        if(proposalStatus == 'Approve'){
                            camRecord.CAM_Approval_Date__c = Datetime.now();
                        }
                        update camRecord;
                    }else{
                        camRecord.CAM_Submitted_by_ACM_SCM__c = true;
                        update camRecord;
                    }
                }
                if(!proposalLogList.isEmpty()){
                    upsert proposalLogList;
                    if(proposalStatus == 'Approve' ){
                        ViewCamController.sendApprovedCAMEmail(camRecord.Id);
                        alertMessage = 'Proposal has been Approved.';
                    }else{
                        ViewCamController.sendApprovedCAMEmail(camRecord.Id);
                        alertMessage = 'Proposal has been Rejected.';
                    }
                }
            }else if(allVehicleApprovedORAccepted == false){
                alertMessage = 'Vehicle approval is pending!';
            }else{
                alertMessage = 'Proposal has already Approved/Reject OR You don\'t have accesss to Approved/Reject this.';
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'proposalApprove', e.getTypeName(), e, '');
        }
        return alertMessage;
    }
    @AuraEnabled
    public static string checkCAMBeforeApproval(String camRecordId){
        try{
            CAM__c camRecord = [SELECT Loan_Application__c,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c,Loan_Application__r.AccountId FROM CAM__c WHERE Id = :camRecordId LIMIT 1];
            List<AccountTeamMember> accountTeamMember = [SELECT Id, Level__c,TeamMemberRole FROM AccountTeamMember WHERE AccountId =:camRecord.Loan_Application__r.AccountId AND UserId = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
            if (accountTeamMember.size() > 0) {
                if(camRecord.Submit_for_Approval_UserId__c != UserInfo.getUserId() || camRecord.CAM_Submitted_by_ACM_SCM__c == true){
                    return 'Proposal has already Approved/Reject OR You don\'t have accesss to Approved/Reject this.';
                }
            }            
            String recordId = camRecord.Loan_Application__c;
            Boolean allVehicleApprovedORAccepted = true;
            for(Vehicle_Detail__c vehicleObj: [SELECT Approval_Status__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :recordId WITH SECURITY_ENFORCED LIMIT 10000]){
                if(String.isBlank(vehicleObj.Approval_Status__c)){
                    allVehicleApprovedORAccepted = false;
                    break;
                }
            }
            if(allVehicleApprovedORAccepted == false){
                return 'Vehicle approval is pending!';
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'proposalApprove', e.getTypeName(), e, '');
        }
        return '';
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to get the remark of related deviation.
***********************************************/ 
    @AuraEnabled
    public static  List<Deviation__c>  getDevRemarks(String deviationName){
        try{
            List<Deviation__c> devRemarks=[SELECT Id, Name, Remarks__c, DeviationID__c, Deviation_Level__c, EmployeeID__c, Parent_CAM__c, Active__c FROM Deviation__c where Name=:deviationName];
            return devRemarks;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getDevRemarks', e.getTypeName(), e, '');
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to get all deviation which generated eariler for approval.
***********************************************/  
    @AuraEnabled
    public static List<Deviation__c> getDeviationsForApprovals(String camID){
        try{
            Map<String,Deviation__c> mapDeviation= new Map<String, Deviation__c>();
            String enabled='Enabled';
            String disabled='Disabled';
            
            List<Deviation__c> lstdeviation1=[SELECT Id, Name, Remarks__c,Deviation_Description__c, DeviationID__c,CreatedDate, Source__c,Type__c,Deviation_Level__c, EmployeeID__c, Parent_CAM__c, Active__c,Role__c, Approval_Status__c,UpInFlag__c,CreatedById,Parent_CAM__r.Loan_Application__c, Parent_CAM__r.Loan_Application__r.AccountId,Proposal_Status__c,Parent_CAM__r.Loan_Application__r.Product_Type__c,Justification_Remarks__c FROM Deviation__c WHERE Parent_CAM__c=:camID  WITH SECURITY_ENFORCED];          
            if(lstdeviation1.size()>0){
                String accID=lstdeviation1[0].Parent_CAM__r.Loan_Application__r.AccountId;               
                List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember> ();
                accountTeamMemberList = [SELECT Id ,TeamMemberRole,User.Name, Level__c ,Account.id FROM AccountTeamMember WHERE Account.id=:accID AND UserId = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
                AccountTeamMember acctemMem = accountTeamMemberList.size() > 0 ? accountTeamMemberList[0] : new AccountTeamMember();
                for(Deviation__C objDeviation :lstdeviation1){
                    if(String.isNotBlank(acctemMem.Level__c) && acctemMem.Level__c.contains(objDeviation.Deviation_Level__c)){
                        mapDeviation.put(enabled,objDeviation);
                    }else{
                        mapDeviation.put(disabled,objDeviation);
                    }
                }
                return lstdeviation1;
            }
            return null;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getDeviationsForApprovals', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camID LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    @AuraEnabled
    public static List<Deviation__c> getDeviationsForApprovalsTractor(String camID){
        return [SELECT Id, Name, Remarks__c,Deviation_Description__c, DeviationID__c,CreatedDate, Source__c,Type__c,Deviation_Level__c, EmployeeID__c, Parent_CAM__c, Active__c,Role__c, Approval_Status__c,UpInFlag__c,CreatedById,Parent_CAM__r.Loan_Application__c, Parent_CAM__r.Loan_Application__r.AccountId,Proposal_Status__c,Parent_CAM__r.Loan_Application__r.Product_Type__c FROM Deviation__c WHERE Parent_CAM__c=:camID AND Deviation_Type__c != 'Manual' AND Type__c != 'Manual Deviation'];
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to create the deviation records and assign roles from the account team using the response from the fico API.
***********************************************/
    @AuraEnabled
    public static String triggerDeviations(String camId,String deviationResponse){
        try {
            CAM__c cam = [SELECT Id,Loan_Application__c,Credit_Analyst_Remarks__c, Committee__c, Loan_Application__r.AccountId,Loan_Application__r.Product_Type__c,Loan_Application__r.LeadSource FROM CAM__c WHERE id=:camId WITH SECURITY_ENFORCED];
            if(cam!=null){
                Boolean isTractor = cam.Loan_Application__r.Product_Type__c == System.Label.Tractor ? true : false;
                String accID=cam.Loan_Application__r.AccountId;
                String applicantId;
                String loanAppId = cam.Loan_Application__c;
                String response='{ "Borrower": \n' +
                    '{\n' +
                    '"Deviations": [\n' +
                    '{\n' +
                    '"DeviationId": "3126",\n' +
                    ' "DeviationName": "Cibil Detect BORROWER",\n' +
                    '"Level": "L6",\n' +
                    '"conditionValues": [\n '+
                    '{\n' + 
                    '"variableName": "CIBIL Decision",\n' +
                    '"variableValue": "High"\n' + 
                    '}\n' + 
                    ']\n' +
                    '},\n' +
                    '{\n '+
                    '"DeviationId": "1058",\n' +
                    '"DeviationName": "ONE OR MORE CUSTOMER DEAL(S) IS/ARE HAVING LIEN",\n' +
                    '"Level": "L4",\n '+
                    '"conditionValues": [\n '+
                    ' {\n' + 
                    '"variableName": "LIEN Flag",\n' +
                    ' "variableValue": "Y"\n '+
                    '}\n' +
                    ']\n' +
                    '},\n' +
                    '{\n' +
                    ' "DeviationId": "1062",\n' +
                    ' "DeviationName": "60-90 DAY OD BORROWER IN RBI LIST",\n' +
                    ' "Level": "L6",\n' +
                    '"conditionValues": [\n' +
                    '{\n' +
                    ' "variableName": "60_90_OD_RBI Flag",\n '+
                    '"variableValue": "Y"\n' +
                    '}\n '+
                    ']\n' +
                    '},\n' +
                    ' {\n' +
                    '"DeviationId": null,\n' +
                    '"DeviationName": "New To Credit Customer",\n' +
                    ' "Level": "BCC",\n' +
                    '"conditionValues": [\n' +
                    '{\n' +
                    ' "variableName": "Multiple Product Flag",\n' +
                    '"variableValue": "true"\n '+
                    '},\n' +
                    ' {\n '+
                    '"variableName": "Total Exposure",\n' +
                    '"variableValue": "20000.0"\n' +
                    '}\n' +
                    ']\n' +
                    '},\n' +
                    '{\n' +
                    '"DeviationId": "3198",\n '+
                    '"DeviationName": "Pan CIN alert for Borrower",\n '+
                    '"Level": "CCC",\n '+
                    '"conditionValues": [\n '+
                    ' {\n' +
                    ' "variableName": "Pan CIN Flag of Borrower",\n'  +
                    '"variableValue": "Y"\n '+
                    ' }\n' +
                    ']\n '+
                    '},\n' +
                    ' {\n' + 
                    '"DeviationId": "1036",\n' +
                    '"DeviationName": "Profile Deviation",\n' +
                    ' "Level": "L3",\n' +
                    ' "conditionValues": [\n' +
                    ' {\n' +
                    ' "variableName": "Profile Type",\n' +
                    '"variableValue": "CAUTION"\n' +
                    '},\n' +
                    '{\n '+
                    '"variableName": "Quantam Finance",\n' +
                    ' "variableValue": "100000.0"\n' +
                    ' },\n' +
                    ' {\n' +
                    ' "variableName": "Category",\n'  +
                    ' "variableValue": "SENP"\n' +
                    '},\n' +
                    '{\n' +
                    '"variableName": "State Code IBL",\n' +
                    '"variableValue": "A"\n' +
                    '},\n' +
                    '{\n' +
                    ' "variableName": "ltv PV New",\n' +
                    '"variableValue": "Infinity"\n' +
                    ' },\n '+
                    '{\n' +
                    ' "variableName": "ltv PV Used Non Oem",\n' +
                    '"variableValue": "0.0"\n' +
                    ' },\n' +
                    '{\n' +
                    '"variableName": "ltv PV Used Oem",\n' +
                    ' "variableValue": "0.0"\n' +
                    ' }\n' +
                    ']\n' +
                    '}\n' +
                    ']\n' +
                    '},\n' +
                    '"CoBorrower": null\n' + 
                    '}\n';
                response = deviationResponse;
                List<Deviation__c> deviRecords=[SELECT Id,Name,Parent_CAM__c FROM Deviation__c WHERE Parent_CAM__c=:camId AND Deviation_Type__c != 'Manual' AND Type__c != 'Manual Deviation' WITH SECURITY_ENFORCED];
                Integer size= deviRecords.size();
                if(size==0){
                    IND_FicoDeviationResponse responseWrapper =(IND_FicoDeviationResponse)system.JSON.deserialize(response, IND_FicoDeviationResponse.class);
                    List<Deviation__c> devi = new List<Deviation__c>();
                    List<Deviation__c> committeeDeviationList = new List<Deviation__c>();
                    List<Deviation__c> mandatoryTFDeviationList = new List<Deviation__c>();
                    List<AccountTeamMember> acctemMem = new List<AccountTeamMember>();
                    if(cam.Loan_Application__r.Product_Type__c == Label.Tractor){
                        acctemMem = [SELECT ID ,TeamMemberRole,User.Name, Level__c ,Account.id FROM AccountTeamMember WHERE Account.id=:accID AND TeamMemberRole != 'CVO' AND User.IsActive = true WITH SECURITY_ENFORCED];
                    }else{
                        acctemMem = [SELECT ID ,TeamMemberRole,User.Name, Level__c ,Account.id FROM AccountTeamMember WHERE Account.id=:accID WITH SECURITY_ENFORCED];
                    }
                    List<Committee_Deviation__mdt> lstcdm=[SELECT Id,Label,DeveloperName,CCC_Above_Flag__c,Mandatory_Role__c,Non_Mandatory_Role__c from Committee_Deviation__mdt WITH SECURITY_ENFORCED limit 100];
                    List<IND_FicoDeviationResponse.Deviations> deviationWrapperList = new List<IND_FicoDeviationResponse.Deviations>();
                    if(responseWrapper != null && responseWrapper.Borrower != null && responseWrapper.Borrower.Deviations != null){
                        deviationWrapperList.addAll(responseWrapper.Borrower.Deviations);
                    }
                    if(responseWrapper != null && responseWrapper.CoBorrower != null && responseWrapper.CoBorrower.Deviations != null){
                        deviationWrapperList.addAll(responseWrapper.CoBorrower.Deviations);
                    } //Start CISP-2399
                    if(isTractor && responseWrapper != null && responseWrapper.Guarantor != null && responseWrapper.Guarantor.Deviations != null){
                        deviationWrapperList.addAll(responseWrapper.Guarantor.Deviations);
                    }
                    if(isTractor && responseWrapper != null && responseWrapper.Beneficiary != null && responseWrapper.Beneficiary.Deviations != null){
                        deviationWrapperList.addAll(responseWrapper.Beneficiary.Deviations);
                    }
                    Map<String,List<AccountTeamMember>> levelVsAccountTeamMemberListMap = new Map<String,List<AccountTeamMember>>();
                    Map<String,List<String>> levelVsRoleListMap = new Map<String,List<String>>();
                    for(AccountTeamMember acc: acctemMem){
                        if(acc.Level__c != null){
                            List<String> levelList = acc.Level__c.split(';');
                            for(String level:levelList){
                                if(!levelVsAccountTeamMemberListMap.containsKey(level)){
                                    levelVsAccountTeamMemberListMap.put(level,new List<AccountTeamMember>{acc});
                                    if(acc.TeamMemberRole != null){
                                        levelVsRoleListMap.put(level,new List<String>{acc.TeamMemberRole});
                                    }
                                }
                                else{
                                    levelVsAccountTeamMemberListMap.get(level).add(acc);
                                    if(acc.TeamMemberRole != null){
                                        levelVsRoleListMap.get(level).add(acc.TeamMemberRole);
                                    }
                                }
                            }
                        }
                    }

                    Map<String,Committee_Deviation__mdt> committeeDeviationMTDMap = new Map<String,Committee_Deviation__mdt>();
                    for(Committee_Deviation__mdt committee : [SELECT Non_Mandatory_Role__c,Mandatory_Role__c,Partial_Mandatory_Roles__c,MasterLabel FROM Committee_Deviation__mdt WHERE Product__c=:cam.Loan_Application__r.Product_Type__c WITH SECURITY_ENFORCED]){
                        if(!committeeDeviationMTDMap.containsKey(committee.MasterLabel)){
                            committeeDeviationMTDMap.put(committee.MasterLabel,committee);
                        }
                    }
                    
                    for(IND_FicoDeviationResponse.Deviations objDeviation  :deviationWrapperList){
                        if (objDeviation.Level != null && !String.isEmpty(objDeviation.Level)) {
                            Deviation__c deviation= new Deviation__c();
                            deviation.Parent_CAM__c=camId;
                            if(cam.Loan_Application__r.Product_Type__c != System.Label.Tractor){ 
                                deviation.Deviation_Description__c=objDeviation?.displayDeviation; // CISP -3987 Mapping Display Deviation
                            }else{
                            deviation.Deviation_Description__c=objDeviation?.DeviationName;
                        } 
                            deviation.DeviationID__c=objDeviation?.DeviationId;
                            deviation.Deviation_Level__c =objDeviation?.Level;
                            deviation.Source__c='FICO ENGINE';
                            deviation.Applicant_Type__c= 'Borrower';
                            deviation.Type__c = 'Normal Deviation';
                            // if(acc.Level__c != null && acc.Level__c == objDeviation.Level){
                            if(objDeviation.Level != null){
                                if(deviation.Role__c==null){//Start CISP-2596
                                    List<String> deviationLevelList = objDeviation.Level.split(',');
                                    if(isTractor && objDeviation.Level.contains('+')){
                                        deviationLevelList.addAll(objDeviation.Level.split('\\+'));
                                    }
                                    for(String deviationLevel:deviationLevelList){
                                        if (levelVsAccountTeamMemberListMap.containsKey(deviationLevel)) {
                                            for(AccountTeamMember accTeam:levelVsAccountTeamMemberListMap.get(deviationLevel)){
                                                if(accTeam.TeamMemberRole != null){
                                                    if(deviation.Role__c == null){
                                                        deviation.Role__c=accTeam.TeamMemberRole;
                                                    }else{
                                                        if(!deviation.Role__c.contains(accTeam.TeamMemberRole)){
                                                            deviation.Role__c+=','+accTeam.TeamMemberRole;
                                                            deviation.EmployeeID__c+=','+accTeam.UserID;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }// End CISP-2596
                                    // deviation.Role__c=levelVsAccountTeamMemberListMap.get(objDeviation.Level)[0].TeamMemberRole;
                                    // deviation.EmployeeID__c=levelVsAccountTeamMemberListMap.get(objDeviation.Level)[0].UserID;
                                }
                            }
                            for(AccountTeamMember acc: acctemMem){ //End CISP-2399
                                                       
                                if(committeeDeviationMTDMap.containsKey(deviation.Deviation_Level__c)){
                                    Committee_Deviation__mdt com = committeeDeviationMTDMap.get(deviation.Deviation_Level__c);
                                    deviation.Type__c='Committee Deviation';
                                    if(deviation.Role__c == null){
                                        deviation.Role__c = com.Mandatory_Role__c != null ? String.valueOf(com.Mandatory_Role__c) : '';
                                        deviation.Role__c += com.Non_Mandatory_Role__c != null ? ',' + String.valueOf(com.Non_Mandatory_Role__c) : '';
                                    }
                                    if(deviation.Role__c != null && acc.TeamMemberRole != null && deviation.Role__c.contains(acc.TeamMemberRole)){
                                        if(deviation.EmployeeID__c == null){
                                            deviation.EmployeeID__c = acc.UserID;
                                        }else{
                                            deviation.EmployeeID__c += ',' +acc.UserID;  
                                        }
                                    }
                                    
                                }
                            }
                            for(AccountTeamMember lev: acctemMem){
                                if(deviation.Type__c=='Normal Deviation'){
                                    String[] tmpString = lev.Level__c!=null?lev.Level__c.split(';'):null;
                                    if(tmpString!=null){
                                        for(string level : tmpString){
                                            if(deviation.UpInFlag__c==null && level >=  deviation.Deviation_Level__c){
                                                deviation.UpInFlag__c=level;
                                            }else if(level >=  deviation.Deviation_Level__c && !deviation.UpInFlag__c.contains(level)){
                                                deviation.UpInFlag__c+=','+level;
                                            }
                                        }   
                                    }
                                }
                            }
                            for(Committee_Deviation__mdt com :lstcdm){
                                if(deviation.Type__c=='Committee Deviation'){
                                    if(com.CCC_Above_Flag__c==true && deviation.UpInFlag__c==null && com.Label!=deviation.Deviation_Level__c){
                                        deviation.UpInFlag__c=com.Label;
                                    }else if(com.CCC_Above_Flag__c==true && com.Label!=deviation.Deviation_Level__c){
                                        deviation.UpInFlag__c+=',' +com.Label;
                                    }
                                }
                            }
                            if(isTractor && deviation.Deviation_Level__c != null && deviation.Deviation_Level__c.contains('+')){
                                mandatoryTFDeviationList.add(deviation); 
                            }else if(deviation.Type__c=='Committee Deviation'){
                                committeeDeviationList.add(deviation);
                            }
                            else {
                                devi.add(deviation);
                            }
                        }
                    }
                    for (Deviation__c deviationObj : committeeDeviationList) {
                        if (cam.Committee__c == null) {
                            cam.Committee__c = deviationObj.Deviation_Level__c;
                        }
                        List<String> roleList = deviationObj.Role__c != null ? deviationObj.Role__c.split(',') : new List<String>();
                        if(roleList.size()>0){
                            for (String role : roleList) {
                                Deviation__c clonedDeviationObj = deviationObj.clone(false,false,false,false);
                                clonedDeviationObj.Role__c = role;
                                devi.add(clonedDeviationObj);
                            }
                        }
                        if(isTractor && committeeDeviationMTDMap.containsKey(deviationObj.Deviation_Level__c) && String.isNotBlank(committeeDeviationMTDMap.get(deviationObj.Deviation_Level__c).Partial_Mandatory_Roles__c)){
                            Deviation__c clonedDeviationObj = deviationObj.clone(false,false,false,false);
                            clonedDeviationObj.Role__c = committeeDeviationMTDMap.get(deviationObj.Deviation_Level__c).Partial_Mandatory_Roles__c;
                            devi.add(clonedDeviationObj);
                        }
                    }
                    for (Deviation__c deviationObj : mandatoryTFDeviationList) {
                        List<String> levelList = deviationObj.Deviation_Level__c != null ? deviationObj.Deviation_Level__c.split('\\+') : new List<String>();
                        if(levelList.size()>0){
                            for (String level : levelList) {
                                Deviation__c clonedDeviationObj = deviationObj.clone(false,false,false,false);
                                clonedDeviationObj.Role__c = null;
                                if (levelVsAccountTeamMemberListMap.containsKey(level)) {
                                    for(AccountTeamMember accTeam:levelVsAccountTeamMemberListMap.get(level)){
                                        if(accTeam.TeamMemberRole != null){
                                            if(clonedDeviationObj.Role__c == null){
                                                clonedDeviationObj.Role__c=accTeam.TeamMemberRole;
                                            }else{
                                                if(!clonedDeviationObj.Role__c.contains(accTeam.TeamMemberRole)){
                                                    clonedDeviationObj.Role__c+=','+accTeam.TeamMemberRole;
                                                    clonedDeviationObj.EmployeeID__c+=','+accTeam.UserID;
                                                }
                                            }
                                        }
                                    }
                                }
                                clonedDeviationObj.Deviation_Level__c = level;
                                devi.add(clonedDeviationObj);
                            }
                        }
                    }
                    if(cam.Loan_Application__r.Product_Type__c == Label.Tractor){
                        Set<String> teamRoleSet = new Set<String>();
                        Set<String> teamLevelSet = new Set<String>();
                        for (AccountTeamMember accountTeam : acctemMem) {
                            if(accountTeam.TeamMemberRole != null){
                                teamRoleSet.add(accountTeam.TeamMemberRole);
                            }
                            if(accountTeam.Level__c != null){
                                teamLevelSet.addAll(accountTeam.Level__c.split(','));
                            }
                        }
                        Map<String, String> roleSkipMapWithRole = new Map<String, String>();
                        Map<String, String> levelSkipMapWithRole = new Map<String, String>();
                        Map<String, String> levelSkipMapWithLevel = new Map<String, String>();
                        Map<String, String> currentLevelCurrentRoleMap = new Map<String, String>();
                        for(Deviation_Level_Skip_Metadata__mdt levelSkipRecord : [SELECT Id,Current_Level__c, Current_Role__c,Skip_To_Level__c,Skip_To_Role__c,Product_Type__c from Deviation_Level_Skip_Metadata__mdt WHERE Product_Type__c =: cam.Loan_Application__r.Product_Type__c]){
                            if(String.isNotBlank(levelSkipRecord.Skip_To_Role__c)){
                                List<String> skipRoleList = levelSkipRecord.Skip_To_Role__c.split(',');
                                for (String skipRole : skipRoleList) {
                                    if(teamRoleSet.contains(skipRole)){
                                        if(!roleSkipMapWithRole.containsKey(levelSkipRecord.Current_Role__c)){
                                            roleSkipMapWithRole.put(levelSkipRecord.Current_Role__c, skipRole);
                                        }
                                        if(!levelSkipMapWithRole.containsKey(levelSkipRecord.Current_Level__c)){
                                            levelSkipMapWithRole.put(levelSkipRecord.Current_Level__c, skipRole);
                                        }
                                    }
                                }
                            }
                            if(String.isNotBlank(levelSkipRecord.Skip_To_Level__c)){
                                List<String> skipLevelList = levelSkipRecord.Skip_To_Level__c.split(',');
                                for (String skipLevel : skipLevelList) {
                                    if(teamLevelSet.contains(skipLevel) && !levelSkipMapWithLevel.containsKey(levelSkipRecord.Current_Level__c)){
                                        levelSkipMapWithLevel.put(levelSkipRecord.Current_Level__c, skipLevel);
                                    }
                                    currentLevelCurrentRoleMap.put(levelSkipRecord.Current_Level__c,levelSkipRecord.Current_Role__c);
                                }
                            }
                        }
                        devi.addAll([SELECT Id,Deviation_Level__c,Type__c,Role__c FROM Deviation__c WHERE Parent_CAM__c=:camId AND Deviation_Type__c = 'Manual' AND Type__c = 'Manual Deviation']);
                        if(devi.size() > 0){
                            for (Deviation__c dev : devi) {
                                if(dev.Type__c == 'Committee Deviation' && dev.Role__c != null){
                                    for (String role : dev.Role__c.split(',')) {
                                        if(!teamRoleSet.contains(role)){
                                            if(dev.Role__c != null){
                                                if(roleSkipMapWithRole.containsKey(role)){
                                                    for (String roleStr : dev.Role__c.split(',')) {
                                                        dev.Role__c = dev.Role__c.replace(roleStr,roleSkipMapWithRole.get(role));
                                                    }
                                                    Set<String> removeDuplicateSet = new Set<String>(dev.Role__c.split(','));
                                                    if(removeDuplicateSet.size() > 0){
                                                        List<String> removeDuplicateList = new List<String>();
                                                        removeDuplicateList.addAll(removeDuplicateSet);
                                                        dev.Role__c = String.join(removeDuplicateList,',');
                                                    }
                                                }
                                            }else if(roleSkipMapWithRole.containsKey(role)){
                                                dev.Role__c = roleSkipMapWithRole.get(role);
                                            }
                                        }
                                    }
                                }else if(dev.Type__c != 'Committee Deviation' && dev.Deviation_Level__c != null){
                                    for (Integer i = 0; i < dev.Deviation_Level__c.split(',').size(); i++) {
                                        String level = dev.Deviation_Level__c.split(',')[i];
                                        if(!teamLevelSet.contains(level)){
                                            if(levelSkipMapWithLevel.containsKey(level)){
                                                dev.Deviation_Level__c = dev.Deviation_Level__c.replace(level,levelSkipMapWithLevel.get(level));
                                                if(dev.Role__c != null){
                                                    if(levelSkipMapWithRole.containsKey(level)){
                                                        if(dev.Role__c.split(',').contains(currentLevelCurrentRoleMap.get(level))){
                                                            for (String role : dev.Role__c.split(',')) {
                                                                dev.Role__c = dev.Role__c.replace(role,levelSkipMapWithRole.get(level));
                                                            }
                                                        }else{
                                                            dev.Role__c = dev.Role__c + ',' + levelSkipMapWithRole.get(level);
                                                            List<String> tempRoleList = dev.Role__c.split(',');
                                                            if(tempRoleList.size() > i){
                                                                tempRoleList.add(i,levelSkipMapWithRole.get(level));
                                                                tempRoleList.remove(tempRoleList.size() - 1);
                                                                dev.Role__c = String.join(tempRoleList,',');
                                                            }
                                                        }
                                                        Set<String> removeDuplicateSet = new Set<String>(dev.Role__c.split(','));
                                                        if(removeDuplicateSet.size() > 0){
                                                            List<String> removeDuplicateList = new List<String>();
                                                            removeDuplicateList.addAll(removeDuplicateSet);
                                                            dev.Role__c = String.join(removeDuplicateList,',');
                                                        }
                                                    }
                                                }else if(levelSkipMapWithRole.containsKey(level)){
                                                    dev.Role__c = levelSkipMapWithRole.get(level);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (devi.size() > 0) {
                        upsert devi;
                    }
                    // cam.Deviation_Created_Date__c = Date.today();
                    // List<Final_Term__c> finalTermList = [SELECT Id,Calculated_Net_LTV__c,Calculated_Gross_LTV__c FROM Final_Term__c LIMIT 1];//Start CISP-2491
                    // if(finalTermList.size()>0){
                    //     finalTermList[0].Calculated_Net_LTV__c = responseWrapper.netLTV != null ? Decimal.valueOf(responseWrapper.netLTV) : null;
                    //     finalTermList[0].Calculated_Gross_LTV__c = responseWrapper.grossltv != null ? Decimal.valueOf(responseWrapper.grossltv) : null;
                    // }
                    // update finalTermList;//End CISP-2491
                    update cam;
                    return 'Success';
                }
            }
            return 'NO records';
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'triggerDeviations', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to check whether any cam related to the loan application already exist or not if yes then retunrs the cam along with more details.
***********************************************/
    @AuraEnabled
    public static CAMDataWrapper getRelatedCAM(string loanAppId){
        try {
            if(String.isNotBlank(loanAppId)){
                // D2C_CHANGE  - Raman, Added LeadSource, Is_Pre_Approved__c and Sanction_Status__c field in SOQL                            
                Opportunity oppty = [SELECT Id,LeadSource,Sanction_Status__c,Is_Pre_Approved__c,OwnerId FROM Opportunity WHERE Id=:loanAppId WITH SECURITY_ENFORCED LIMIT 1];//D2C Change
                List<CAM__c> camList = [SELECT Id,Loan_Amount__c,Credit_Analyst_Remarks__c,Required_CRM_IRR__c,Proposal_Status__c,BE_CVO_Remark__c,Trigger_Deviations__c, Loan_Application__r.LeadSource, Loan_Application__r.Sanction_Status__c, Loan_Application__r.Is_Pre_Approved__c, Loan_Application__r.Total_Funded_Premium__c, Deviation_Created_Date__c,Loan_Application__r.Product_Type__c,Loan_Application__r.Is_Revoked__c,Loan_Application__r.Parent_Loan_Application__c,Total_Deviations__c FROM CAM__c WHERE Loan_Application__c=:loanAppId LIMIT 1];//CISP-2382
                List<Applicant__c> applicantList = [SELECT Id, Applicant_Type__c FROM Applicant__c WHERE Opportunity__c =: loanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                CAMDataWrapper wrapperObj = new CAMDataWrapper();
                wrapperObj.oppty = oppty;
                wrapperObj.camRecord = !camList.isEmpty()?camList[0]:null;
                if(!camList.isEmpty() && camList[0].Loan_Application__r.Product_Type__c == 'Passenger Vehicles'){
                    List<Deviation__c> deviationList = [SELECT Id FROM Deviation__c WHERE Approval_Status__c = 'Approved' AND Parent_CAM__c =: camList[0].Id WITH SECURITY_ENFORCED];
                    if (deviationList.size() > 0 && camList[0].Total_Deviations__c == deviationList.size()) {
                        wrapperObj.enablePayinPayout = true;
                    }     
                }
                if(applicantList.size() > 0){
                    for (Applicant__c appObj : applicantList) {
                        if(appObj.Applicant_Type__c == 'Borrower'){
                            wrapperObj.borrowerAppId = appObj.Id;
                        }else if(appObj.Applicant_Type__c == 'Co-borrower'){
                            wrapperObj.coborrowerAppId = appObj.Id;
                        }
                    }
                }
                List<Final_Term__c> finaltermsList = new List<Final_Term__c>();  //CISP-131
                finaltermsList = [SELECT id,OfferengineMinLoanAmount__c,Advance_EMI__c,OfferengineMaxLoanAmount__c,Loan_Application__r.Loan_amount__c,Loan_Amount__c,Net_IRR__c,Inputted_IRR__c,Loan_Application__r.Product_Type__c,Loan_Application__r.Total_Funded_Premium__c,Service_charges__c,Documentation_charges__c,Stamping_charges__c,Due_date_shift_charges__c,RTO_prefix__c,Trade_certificate__c,Mfr_Exp_Reimburse_Amt__c,Mfr_Exp_Reimburse_percent__c,Mfr_Exp_Reimburse_Type__c,Dealer_incentive_amount_main_dealer__c,Dealer_Disc_to_Customer__c,Gift_through_dealer_amount__c,DSM_Incentive1__c,DSM_Incentive2__c,Refered_By__c,Rreferrer_Incentive__c,Referrer_Name__c,Provisional_Channel_Cost__c,DSA_pay__c,DSM_Name1__c,DSM_Name2__c,Emp_Name__c,Emp_No__c,EMI_Amount__c,Branch__c,Loan_Application__c,Loan_Application__r.Is_Revoked__c,Is_Loan_Amount_Change_From_CAM__c,Tenure__c,Loan_Application__r.Vehicle_Type__c, First_EMI_Date__c,Second_EMI_Date__c,Holiday_period__c,Installment_Type__c  FROM Final_Term__c WHERE Loan_Application__c = :loanAppId WITH SECURITY_ENFORCED  LIMIT 1];//CISP-2382 CISP-2507
                if (finaltermsList.size() > 0) {
                    if (finaltermsList[0].Loan_Application__r.Product_Type__c == 'Passenger Vehicles') {
                        wrapperObj.netIRR = finaltermsList[0].Net_IRR__c!=null ?finaltermsList[0].Net_IRR__c:null;   
                    } else if (finaltermsList[0].Loan_Application__r.Product_Type__c == 'Two Wheeler') {
                        wrapperObj.netIRR = finaltermsList[0].Inputted_IRR__c!=null ?finaltermsList[0].Inputted_IRR__c:null;   
                    }
                    wrapperObj.loanAmount = String.isNotEmpty(finaltermsList[0].Loan_amount__c) ? Decimal.valueOf(finaltermsList[0].Loan_amount__c)+finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c : finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c;
                     wrapperObj.fundedIns = finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c; //D2C Change//CISP-7754
                    wrapperObj.vehicleType = finaltermsList[0].Loan_Application__r.Vehicle_Type__c;//CISP-7754
                    wrapperObj.productType = String.isNotEmpty(finaltermsList[0].Loan_Application__r.Product_Type__c)? finaltermsList[0].Loan_Application__r.Product_Type__c : '';
                    Map<String,String> committeeDeviationNMRolesMap = new Map<String,String>();
                    List<Committee_Deviation__mdt> committeeDeviationMDList=[SELECT Id, Label, DeveloperName,CCC_Above_Flag__c,Mandatory_Role__c,Non_Mandatory_Role__c from Committee_Deviation__mdt WHERE Product__c=:finaltermsList[0].Loan_Application__r.Product_Type__c limit 100];
                    if(committeeDeviationMDList!=null && committeeDeviationMDList.size()>0){
                        for(Committee_Deviation__mdt committeeMdt:committeeDeviationMDList){
                            if(!committeeDeviationNMRolesMap.containsKey(committeeMdt.Label)){
                                committeeDeviationNMRolesMap.put(committeeMdt.Label,committeeMdt.Non_Mandatory_Role__c);
                            }
                        }
                    }
                    wrapperObj.committeeDeviationNMRolesMap = committeeDeviationNMRolesMap;
                    wrapperObj.finalTermsRecord = finaltermsList[0];  //CISP-131
                }
                wrapperObj.hasCommitteeDeviation = false;
                if(camList.size()>0){
                    List<Deviation__c> deviationList = [SELECT Id,Deviation_Level__c,Type__c FROM Deviation__c WHERE Parent_CAM__c =:camList[0].Id WITH SECURITY_ENFORCED LIMIT 10000];
                    for (Deviation__c deviationObj : deviationList) {
                        if(deviationObj.Type__c!=null && deviationObj.Type__c=='Committee Deviation'){
                            wrapperObj.hasCommitteeDeviation = true;
                            break;
                        }
                    }
                }
                IBL_Configuration__mdt config = IBL_Configuration__mdt.getInstance('default');
                if(config != null){
                    wrapperObj.checkForMandatoryRole = config.Check_for_Mandatory_Role__c;
                    wrapperObj.mandatoryForwardRole = config.Mandatory_Forward_Role__c;
                }
                wrapperObj.approvedByMandatoryRoles = getApprovalFromMandatoryRoles(loanAppId);
                Id currentLoanAppId=loanAppId;
                Set<Id> parentLoanAppIdSet = new Set<Id>();
                Boolean isCoborrowerPresent = true;
                Integer count = 0;
                while (isCoborrowerPresent) {
                    List<Opportunity> appCoBorrowerList = [SELECT Id, Name, Parent_Loan_Application__c from Opportunity WHERE Id =:currentLoanAppId WITH SECURITY_ENFORCED];
                    if (appCoBorrowerList.size()>0 && appCoBorrowerList[0].Parent_Loan_Application__c!=null) {
                        currentLoanAppId = appCoBorrowerList[0].Parent_Loan_Application__c;
                        parentLoanAppIdSet.add(appCoBorrowerList[0].Parent_Loan_Application__c);
                    } else {
                        isCoborrowerPresent =false; 
                    }
                }
                if (parentLoanAppIdSet!=null) {
                    List<Applicant__c> appCoBorrowerList = [SELECT ID, Profile__c, Applicant_Type__c, In_Active_Applicant__c from Applicant__c WHERE Opportunity__c IN :parentLoanAppIdSet AND Applicant_Type__c = 'Co-borrower' WITH SECURITY_ENFORCED];
                    if (appCoBorrowerList.size() > 0) {
                        count += appCoBorrowerList.size();
                    }
                }
                // if (appCoBorrowerList.size() > 0) {
                //     for (Applicant__c appCoBorrowerObj : appCoBorrowerList) {
                //         if (appCoBorrowerObj.In_Active_Applicant__c == true) {
                //             count++;
                //         }
                //     }
                    wrapperObj.inactiveCoborrowers = count;//CISP-2499
                    if (count < 3) {
                        wrapperObj.enableAddOrChangeCoborrower = false; 
                    }else {
                        wrapperObj.enableAddOrChangeCoborrower = true;
                    }
               // }//Start CISP-2445
                Opportunity opportunityObj = [SELECT Id, Parent_Loan_Application__c,Parent_Loan_Application__r.Parent_Loan_Application__c FROM Opportunity WHERE Id =: loanAppId WITH SECURITY_ENFORCED LIMIT 1];
                Id parentloanAppId = opportunityObj.Parent_Loan_Application__c;
                Id grandParentLoanId;
                if(parentloanAppId != null){
                    grandParentLoanId = opportunityObj.Parent_Loan_Application__r.Parent_Loan_Application__c;
                    CAMDataWrapper parentCamWrapper = getParentLoanApplicationData(parentloanAppId);
                    if(parentCamWrapper != null){
                        wrapperObj.parentLoanCam = parentCamWrapper.parentLoanCam;
                        wrapperObj.parentLoanDeviation = parentCamWrapper.parentLoanDeviation;
                        wrapperObj.parentLoanProposal = parentCamWrapper.parentLoanProposal;
                    }
                }
                if(grandParentLoanId != null){
                    CAMDataWrapper grandparentCamWrapper = getParentLoanApplicationData(grandParentLoanId);
                    if(grandparentCamWrapper != null){
                        wrapperObj.grandparentLoanCam = grandparentCamWrapper.parentLoanCam;
                        wrapperObj.grandparentLoanDeviation = grandparentCamWrapper.parentLoanDeviation;
                        wrapperObj.grandparentLoanProposal = grandparentCamWrapper.parentLoanProposal;
                    }
                }//End CISP-2445
                return wrapperObj;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getRelatedCAM', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to get whether any older cam, deviations and proposal approval logs related to the parent loan application already exist or not if yes then retunrs the all record.
***********************************************/
    @AuraEnabled
    public static CAMDataWrapper getParentLoanApplicationData(string parentloanAppId){
        try {
            CAMDataWrapper wrapperObj = new CAMDataWrapper();
            if (parentloanAppId != null) {
                List<CAM__c> parentLoanCamList = [SELECT Id,Loan_Application__r.Id,Loan_Application__r.Application_number__c,
                                                  Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Exposure_Amount__c,
                                                  Loan_Application__r.Employee_Branch__c ,Loan_Application__r.variant__c ,Loan_Application__r.OwnerId,
                                                  Committee__c,CAM_Status__c, Generation_Date__c ,SCM_Approval__c,No_of_Days_Pending__c, BE_CVO_Remark__c,Proposal_Status__c,Action_Taken__c,Productivity_YTD__c,Weighted_IRR_YTD__c,Conditional_Approval__c,Hold_Date__c,Is_Hold__c,Level_of_Hold_User__c,Loan_Application__c from CAM__c WHERE Loan_Application__c = :parentloanAppId WITH SECURITY_ENFORCED LIMIT 1];
                wrapperObj.parentLoanCam= !parentLoanCamList.isEmpty()?parentLoanCamList[0]:null;
                if(!parentLoanCamList.isEmpty()){
                    List<Deviation__c> deviationList = [SELECT Id, Name, Remarks__c,Deviation_Description__c, DeviationID__c,CreatedDate, Source__c,Type__c,Deviation_Level__c, EmployeeID__c, Parent_CAM__c, Active__c,Role__c, Approval_Status__c,UpInFlag__c,CreatedById,Parent_CAM__r.Loan_Application__c, Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Loan_Application__r.Id,Proposal_Status__c,Source_AppNo__c 
                                                        FROM Deviation__c WHERE Parent_CAM__c =: parentLoanCamList[0].Id WITH SECURITY_ENFORCED];
                    wrapperObj.parentLoanDeviation = !deviationList.isEmpty()?deviationList:null;
                    
                    List<Proposal_Approval_Log__c> proposalList = [SELECT Parent_CAM__r.Loan_Application__c,Proposal_description__c,Parent_CAM__r.Loan_Application__r.Id,Forwarded_On__c,Forwarded_By__c, Forwarded_Role__c,Forwarding_Role__c,Forwarded_Employee__r.Name, Remark__c, Log_Status__c, Role__c, Approval_Status__c, Name,SF_Role__c, Parent_CAM__r.Required_CRM_IRR__c ,Parent_CAM__r.Loan_Amount__c,Hold_Remark__c,Decision__c,Vehicle_ID__c,
                                                                   Loan_Ammount__c,Required_CRM_IRR__c,Date_and_Time__c, Forwarded_Employee__c,Proposal_Approval_Log_ID__c,Action__c,Proposal_Approval_Condition__c,CreatedDate,Proposal_Rejected_by_any_authority__c,RecordType.Name,LastModifiedDate,CreatedBy.FirstName,CreatedBy.LastName,Proposal_Remark__c from Proposal_Approval_Log__c WHERE Parent_CAM__c =: parentLoanCamList[0].Id WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
                    wrapperObj.parentLoanProposal = !proposalList.isEmpty()?proposalList:null;
                }
            }
            return wrapperObj;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getParentLoanApplicationData', e.getTypeName(), e, parentloanAppId);
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to get whether any older deviations related to the parent loan application already exist or not if yes then retunrs the all record.
***********************************************/
    @AuraEnabled
    public static List<Deviation__c> getParentLoanDeviations(string parentloanAppId){
        try {
            List<Deviation__c> parentLoanDeviations = new List<Deviation__c>();
            if (parentloanAppId != null) {
                List<CAM__c> parentLoanCamList = [SELECT Id,Loan_Application__r.Id,Loan_Application__r.Application_number__c,
                                                  Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Exposure_Amount__c,
                                                  Loan_Application__r.Employee_Branch__c ,Loan_Application__r.variant__c ,Loan_Application__r.OwnerId,
                                                  Committee__c,CAM_Status__c, Generation_Date__c ,SCM_Approval__c,No_of_Days_Pending__c, BE_CVO_Remark__c,Proposal_Status__c,Action_Taken__c,Productivity_YTD__c,Weighted_IRR_YTD__c,Conditional_Approval__c,Hold_Date__c,Is_Hold__c,Level_of_Hold_User__c,Loan_Application__c from CAM__c WHERE Loan_Application__c = :parentloanAppId WITH SECURITY_ENFORCED LIMIT 1];
                if(!parentLoanCamList.isEmpty()){
                    List<Deviation__c> deviationList = [SELECT Id, Name, Remarks__c,Deviation_Description__c, DeviationID__c,CreatedDate, Source__c,Type__c,Deviation_Level__c, EmployeeID__c, Parent_CAM__c, Active__c,Role__c, Approval_Status__c,UpInFlag__c,CreatedById,Parent_CAM__r.Loan_Application__c, Parent_CAM__r.Loan_Application__r.AccountId,Proposal_Status__c,Source_AppNo__c 
                                                        FROM Deviation__c WHERE Parent_CAM__c =: parentLoanCamList[0].Id WITH SECURITY_ENFORCED];
                    parentLoanDeviations = deviationList;
                }
            }
            return parentLoanDeviations;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getParentLoanDeviations', e.getTypeName(), e, parentloanAppId);
            return null;
        }
    }
    
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to return the boolean specifying whether the mandatory roles for all committee deviations are approved or not.
***********************************************/
    public static Boolean getApprovalFromMandatoryRoles(String loanAppId){
        try {
            if(loanAppId!=null){
                List<Opportunity> loanApplicationList = new List<Opportunity>();
                loanApplicationList = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id=:loanAppId WITH SECURITY_ENFORCED LIMIT 1];
                Map<String,String> committeeDeviationRolesMap = new Map<String,String>();
                List<Committee_Deviation__mdt> committeeDeviationMDList=[SELECT Id,Label,DeveloperName,CCC_Above_Flag__c,Mandatory_Role__c,Non_Mandatory_Role__c from Committee_Deviation__mdt WHERE Product__c=:loanApplicationList[0].Product_Type__c WITH SECURITY_ENFORCED limit 100 ];
                if(committeeDeviationMDList!=null && committeeDeviationMDList.size()>0){
                    for(Committee_Deviation__mdt committeeMdt:committeeDeviationMDList){
                        if(!committeeDeviationRolesMap.containsKey(committeeMdt.Label) && committeeMdt.Mandatory_Role__c != null){
                            committeeDeviationRolesMap.put(committeeMdt.Label,committeeMdt.Mandatory_Role__c);
                        }
                    }
                }
                Boolean approvedByMandatoryRoles = true;
                Boolean checkForNonMandatory = false;
                List<Deviation__c> deviationList = new List<Deviation__c>();
                deviationList = [SELECT Id,Approval_Status__c,Type__c,Deviation_Level__c,Role__c FROM Deviation__c WHERE Parent_CAM__r.Loan_Application__c=:loanAppId WITH SECURITY_ENFORCED LIMIT 100];
                for(Deviation__c deviationObj:deviationList){
                    if(deviationObj.Type__c == 'Committee Deviation' && committeeDeviationRolesMap.containsKey(deviationObj.Deviation_Level__c) && committeeDeviationRolesMap.get(deviationObj.Deviation_Level__c)!=null){
                        for (String role : String.valueOf(committeeDeviationRolesMap.get(deviationObj.Deviation_Level__c)).split(',')) {
                            if(deviationObj.Role__c == role && deviationObj.Approval_Status__c != 'Approved' && deviationObj.Approval_Status__c != 'Conditionally Approve'){
                                approvedByMandatoryRoles = false;
                            }
                        }
                        if(deviationObj.Approval_Status__c!=null && deviationObj.Approval_Status__c != 'Approved' && deviationObj.Approval_Status__c != 'Conditionally Approve'){
                            approvedByMandatoryRoles = false;
                        }
                    }
                }
                return approvedByMandatoryRoles;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getApprovalFromMandatoryRoles', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to check the current user role from the ACcount team member
***********************************************/
    @AuraEnabled
    public static UserDataWrapper checkCurrentUserRole(string loanAppId){
        try {   
            String currentUserRole;
            Boolean flag = false;
            UserDataWrapper wrapperObj = new UserDataWrapper();
            if(String.isNotEmpty(loanAppId)){
                List<Opportunity> opportunityList = [SELECT AccountId FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED LIMIT 1];
                if(opportunityList.size()>0 && opportunityList[0].AccountId!=null){
                    List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId=:opportunityList[0].AccountId WITH SECURITY_ENFORCED LIMIT 10000];
                    if(!accountTeamMemberList.isEmpty()){
                        for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                            if(accountTeamObj.UserId!=null && accountTeamObj.UserId==UserInfo.getUserId()){
                                currentUserRole=accountTeamObj.TeamMemberRole;
                                flag = true;
                            }
                        }
                    }
                }
            }
            if(flag==true){
                wrapperObj.currentUserRole = currentUserRole;
                wrapperObj.userName = UserInfo.getName();
                wrapperObj.proposalRecordTypeId = (String)Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Proposal log').getRecordTypeId();   
                return wrapperObj;
            }
            else{
                String currentProfileId = UserInfo.getProfileId();
                List<Profile> profileList = [Select Name FROM Profile WHERE Id=:currentProfileId LIMIT 1];
                wrapperObj.currentUserRole = profileList[0].Name;
                wrapperObj.userName = UserInfo.getName();
                wrapperObj.proposalRecordTypeId = (String)Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Proposal log').getRecordTypeId();
                return wrapperObj;
            } 
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'checkCurrentUserRole', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This wrapper is used for getting current user details.
***********************************************/
    public class UserDataWrapper{
        @auraenabled public string userName;
        @auraenabled public string currentUserRole;
        @auraenabled public string proposalRecordTypeId;
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to update the loan application substage is user takes final action on cam.
***********************************************/
    @AuraEnabled
    public static Boolean updateLoanApplication(string loanAppId,Boolean isAccepted, CAM__c cam){
        try {
            if(loanAppId!=null){
                Opportunity opportunityObj = new Opportunity(Id = loanAppId, IsRejected__c = cam.Proposal_Status__c == 'Reject');
                cam.CAM_Sanction_date__c = Date.today();
                cam.CCC_Exposure_Editable__c = false;
                if(cam.Proposal_Status__c == 'Accept'){
                    cam.CAM_Approval_Date__c = Datetime.now();
                }
                update cam;
                Boolean isMoveNextScreen = false;
                if(isAccepted && String.isNotBlank(cam.Proposal_Status__c)){
                    opportunityObj.Sub_Stage__c = 'Sanction of Application';
                    isMoveNextScreen = true;
                }
                update opportunityObj;
                if(isMoveNextScreen){
                    return true;
                } else {
                    return false;
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'updateLoanApplication', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This wrapper is used to store the cam details along with loan details from final terms.
***********************************************/
    public Class CAMDataWrapper{
        @AuraEnabled
        public CAM__C camRecord;
        @AuraEnabled
        public Decimal netIRR; 
        @AuraEnabled
        public Decimal loanAmount;
        @AuraEnabled 
        public Decimal fundedIns; //D2C Change//CISP-7754
        @AuraEnabled 
        public String vehicleType;//CISP-7754
        @AuraEnabled
        public Boolean hasCommitteeDeviation; 
        @AuraEnabled
        public Boolean approvedByMandatoryRoles;       
        @AuraEnabled
        public String checkForMandatoryRole;       
        @AuraEnabled
        public String mandatoryForwardRole; 
        @AuraEnabled
        public Boolean enableAddOrChangeCoborrower;   
        @AuraEnabled
        public CAM__C parentLoanCam;
        @AuraEnabled
        public List<Deviation__c> parentLoanDeviation;
        @AuraEnabled
        public List<Proposal_Approval_Log__c> parentLoanProposal;
        @AuraEnabled
        public CAM__C grandparentLoanCam;//Start CISP-2445
        @AuraEnabled
        public List<Deviation__c> grandparentLoanDeviation;
        @AuraEnabled
        public List<Proposal_Approval_Log__c> grandparentLoanProposal;
        @AuraEnabled//End CISP-2445
        public String productType;
        @AuraEnabled
        public Map<String,String> committeeDeviationNMRolesMap;
        @AuraEnabled
        public Final_Term__c finalTermsRecord;  //CISP-131
        @AuraEnabled
        public Integer inactiveCoborrowers;  //CISP-2499
        @AuraEnabled
        public Opportunity oppty;  //D2C Change
        @AuraEnabled
        public Boolean isloanAppOwner;
        @AuraEnabled
        public String borrowerAppId;
        @AuraEnabled
        public String coborrowerAppId;
        @AuraEnabled
        public Boolean enablePayinPayout;
    }   
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to get finalTermId record by loanAppId.
***********************************************/
    @AuraEnabled
    public static Id getFinalTermId(string loanAppId){
        try {
            return [SELECT Id FROM Final_Term__c WHERE Loan_Application__c = :loanAppId LIMIT 1].Id;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getFinalTermId', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.15 - CAM and Approval Log
* @Purpose: This method is used to calculate netLTV, grossLTV, LTVInvoiceAmount, grossInvoiceAmount, invoiceAmount of final term object by loanAppId.
***********************************************/
    @AuraEnabled
    public static FinalTermCalculationWrapper getFinalTermCalculations(String loanAppId){
        try {
            FinalTermCalculationWrapper wrapperObj = new FinalTermCalculationWrapper(); 
            List<Opportunity> oppLoanList = new List<Opportunity>();
            oppLoanList = [SELECT id,Name,Applicant_Name__c,Bank_Branch_Detail__c,Employee_Branch__c,Customer_Code__c,Vehicle_Type__c,Agent_BL_code__c,OwnerId,Owner.Name,Funding_on_ORP__c,IBL_State__c,Product_Type__c,Loan_Application_Number__c,Parent_Deal_number__c,Required_Tenure__c,Net_LTV__c,Gross_LTV__c,NOC_Number__c,Invoice__c,LTV__c,Vehicle_Sub_Category__c,Funding_on_Ex_Showroom__c,CRM_IRR__c,Documentation_Charges__c,LeadSource,Dealer_Expence_Reimburse_Amt__c,Service_Charges__c,DSM_Incentive1__c,Gift_through_Dealer_Amount__c,Mfr_Incentive__c,Repayment_mode__c,Basic_Price__c,RTO_Road_Tax__c,RTO_Road_Tax_New__c,X1st_yr_Insurance_Premium__c,Finance_Amount__c,Advance_EMI__c,Other_charges__c,GST_Amount__c,Gross_Invoice_Amount__c,Loan_amount__c,Discount_on_Basic_Price__c,EMI_Amount__c,Total_Funded_Premium__c,Gross_IRR__c,Net_IRR__c,Verification_charges__c,FAME_Subsidy__c,Performance_Upgrade__c,Account.BranchBLCode__c FROM Opportunity WHERE Id = :loanAppId WITH SECURITY_ENFORCED LIMIT 1];//OLA-107
            
            List<Vehicle_Detail__c> vehList = new List<Vehicle_Detail__c>();
            vehList = [SELECT id,Purpose_of_purchase__c,Make__c,Model__c,Lead_Source__c,Variant__c,Variant_Code__c,RC_retention_applicable__c,Ben_Code__c,OEM_Dealer__c,Can_we_continue_with_above_RC_limit__c,Dealer_Sub_dealer_name__c,Vehicle_Registration_number__c,Vehicle_Category__c,Base_Prices__c,Product__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :oppLoanList WITH SECURITY_ENFORCED LIMIT 1];
            List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
            finaltermsList = [SELECT id,OfferengineMinLoanAmount__c,Advance_EMI__c,Loan_Application__c,Loan_Application__r.Loan_amount__c,Loan_Application__r.Total_Funded_Premium__c, OfferengineMaxLoanAmount__c,EMI_Amount__c,Loan_Amount__c,Net_IRR__c,Calculated_Gross_LTV__c,Calculated_Net_LTV__c,Is_Loan_Amount_Change_From_CAM__c FROM Final_Term__c WHERE Loan_Application__c = :oppLoanList WITH SECURITY_ENFORCED  LIMIT 1];// CISP-2491
            if(oppLoanList!=null){
                Decimal basePrice = vehList[0].Base_Prices__c!=null?vehList[0].Base_Prices__c:0;
                Decimal basicPrice = oppLoanList[0].Basic_Price__c!=null?oppLoanList[0].Basic_Price__c:0;
                Decimal roadTax;
                Decimal famesubsidy = oppLoanList[0].FAME_Subsidy__c!=null?oppLoanList[0].FAME_Subsidy__c:0; //OLA-107
                Decimal performanceUpgrade = oppLoanList[0].Performance_Upgrade__c!=null?oppLoanList[0].Performance_Upgrade__c:0; //OLA-107
                if(oppLoanList[0].Product_Type__c == 'Two Wheeler' && oppLoanList[0].Vehicle_Type__c=='New'){
                    roadTax = oppLoanList[0].RTO_Road_Tax_New__c!=null?oppLoanList[0].RTO_Road_Tax_New__c:0;
                }
                else{
                    if(oppLoanList[0].Product_Type__c == 'Passenger Vehicles'){
                        List<Retry_Count__c> retryCounList = new List<Retry_Count__c>([Select Id from Retry_Count__c WHERE Loan_Application_Id__c =: loanAppId AND Service_Name__c = 'CarwaleApi' AND Count__c >= 3]);
                        if(retryCounList.size() > 0){
                            roadTax = oppLoanList[0].RTO_Road_Tax_New__c!=null?oppLoanList[0].RTO_Road_Tax_New__c:0;
                        }else{
                            roadTax = oppLoanList[0].RTO_Road_Tax__c!=null?oppLoanList[0].RTO_Road_Tax__c:0;
                        }
                    }else{
                        roadTax = oppLoanList[0].RTO_Road_Tax__c!=null?oppLoanList[0].RTO_Road_Tax__c:0;
                    }
                }
                Decimal istInsurancePremium = oppLoanList[0].X1st_yr_Insurance_Premium__c!=null?oppLoanList[0].X1st_yr_Insurance_Premium__c:0;
                Decimal otherCharges = oppLoanList[0].Other_charges__c!=null?oppLoanList[0].Other_charges__c:0;
                Decimal gstAmount = oppLoanList[0].GST_Amount__c!=null?oppLoanList[0].GST_Amount__c:0;
                Decimal discount = oppLoanList[0].Discount_on_Basic_Price__c!=null?oppLoanList[0].Discount_on_Basic_Price__c:0;
                Decimal totalFundedInsurancePremium = oppLoanList[0].Total_Funded_Premium__c!=null?oppLoanList[0].Total_Funded_Premium__c:0;
                Decimal LTVInvoiceAmount;
                Decimal invoiceAmount;
                Decimal finalLoanAmount = finaltermsList[0].Loan_Amount__c!=null?Decimal.valueOf(finaltermsList[0].Loan_Amount__c)+totalFundedInsurancePremium:totalFundedInsurancePremium;
                if(oppLoanList[0].Vehicle_Type__c == 'New' && oppLoanList[0].Product_Type__c == 'Passenger Vehicles'){
                    wrapperObj.grossInvoiceAmount = (basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount).setScale(2);
                    if(oppLoanList[0].Funding_on_Ex_Showroom__c==true){
                        LTVInvoiceAmount = ((basicPrice - discount) + gstAmount).setScale(2);
                    }
                    if(oppLoanList[0].Funding_on_ORP__c==true){
                        LTVInvoiceAmount = (basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount-discount).setScale(2);
                    }
                    wrapperObj.LTVInvoiceAmount = LTVInvoiceAmount;
                    invoiceAmount = (basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount-discount).setScale(2);
                    wrapperObj.invoiceAmount = invoiceAmount;
                    if(finalLoanAmount!=null && LTVInvoiceAmount!=null && LTVInvoiceAmount!=0){
                        wrapperObj.grossLTV = (finaltermsList[0].Calculated_Gross_LTV__c == null || finaltermsList[0].Is_Loan_Amount_Change_From_CAM__c) ? ((finalLoanAmount/LTVInvoiceAmount)*100).setScale(2) : finaltermsList[0].Calculated_Gross_LTV__c;//CISP-2491
                    }
                    if(finaltermsList[0].EMI_Amount__c!=null && finalLoanAmount!=null && LTVInvoiceAmount!=null && LTVInvoiceAmount!=0){
                        wrapperObj.netLTV = (finaltermsList[0].Calculated_Net_LTV__c == null || finaltermsList[0].Is_Loan_Amount_Change_From_CAM__c) ? ((((finalLoanAmount-(finaltermsList[0].EMI_Amount__c*(finaltermsList[0].Advance_EMI__c==true?1:0)))/LTVInvoiceAmount)*100).setScale(2)) : finaltermsList[0].Calculated_Net_LTV__c;//CISP-2491
                    }
                }
                else if((oppLoanList[0].Vehicle_Type__c=='Used' || oppLoanList[0].Vehicle_Type__c=='Refinance') && oppLoanList[0].Product_Type__c == 'Passenger Vehicles'){
                    if(finalLoanAmount!=null && basePrice!=null && basePrice!=0){
                        wrapperObj.grossLTV = (finaltermsList[0].Calculated_Gross_LTV__c == null || finaltermsList[0].Is_Loan_Amount_Change_From_CAM__c) ? ((finalLoanAmount/basePrice)*100).setScale(2) : finaltermsList[0].Calculated_Gross_LTV__c;//CISP-2491
                    }
                    if(finaltermsList[0].EMI_Amount__c!=null && finalLoanAmount!=null && basePrice!=null && basePrice!=0){
                        wrapperObj.netLTV = (finaltermsList[0].Calculated_Net_LTV__c == null || finaltermsList[0].Is_Loan_Amount_Change_From_CAM__c) ? ((((finalLoanAmount-(finaltermsList[0].EMI_Amount__c*(finaltermsList[0].Advance_EMI__c==true?1:0)))/basePrice))*100).setScale(2) : finaltermsList[0].Calculated_Net_LTV__c;//CISP-2491
                    }
                }
                else if(oppLoanList[0].Vehicle_Type__c=='New' && oppLoanList[0].Product_Type__c == 'Two Wheeler'){
                    wrapperObj.grossInvoiceAmount = (basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount).setScale(2);
                    if(oppLoanList[0].Funding_on_Ex_Showroom__c==true){
                        LTVInvoiceAmount = ((basicPrice - discount) + gstAmount).setScale(2);
                    }
                    if(oppLoanList[0].Funding_on_ORP__c==true){
                        if(oppLoanList[0].LeadSource == 'OLA'){
                            LTVInvoiceAmount = (basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount+performanceUpgrade-discount-famesubsidy).setScale(2); //OLA-107
                            }else{
                        LTVInvoiceAmount = (basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount-discount).setScale(2);
                    }
                }
                    wrapperObj.LTVInvoiceAmount = LTVInvoiceAmount;
                    invoiceAmount = (LTVInvoiceAmount + totalFundedInsurancePremium).setScale(2);
                    wrapperObj.invoiceAmount = invoiceAmount;
                    if(finalLoanAmount!=null && invoiceAmount!=null && invoiceAmount!=0){
                        wrapperObj.grossLTV = finaltermsList[0].Calculated_Gross_LTV__c == null ? ((finalLoanAmount/invoiceAmount)*100).setScale(2) : finaltermsList[0].Calculated_Gross_LTV__c;//CISP-2491
                    }
                    if(finaltermsList[0].EMI_Amount__c!=null && finalLoanAmount!=null && invoiceAmount!=null && finaltermsList[0].Advance_EMI__c!=null && invoiceAmount!=0){
                        wrapperObj.netLTV = finaltermsList[0].Calculated_Net_LTV__c == null ? ((((finalLoanAmount-(finaltermsList[0].EMI_Amount__c*(finaltermsList[0].Advance_EMI__c==true?1:0)))/invoiceAmount))*100).setScale(2) : finaltermsList[0].Calculated_Net_LTV__c;//CISP-2491
                    } 
                }
                else if((oppLoanList[0].Vehicle_Type__c=='Used' || oppLoanList[0].Vehicle_Type__c=='Refinance') && oppLoanList[0].Product_Type__c == 'Two Wheeler'){
                    if(finalLoanAmount!=null && basePrice!=null && basePrice!=0){
                        wrapperObj.grossLTV = finaltermsList[0].Calculated_Gross_LTV__c == null ? ((finalLoanAmount/basePrice)*100).setScale(2) : finaltermsList[0].Calculated_Gross_LTV__c;//CISP-2491
                    }
                    if(finaltermsList[0].EMI_Amount__c!=null && finalLoanAmount!=null && basePrice!=null && finaltermsList[0].Advance_EMI__c!=null && basePrice!=0){
                        wrapperObj.netLTV = finaltermsList[0].Calculated_Net_LTV__c == null ? ((((finalLoanAmount-(finaltermsList[0].EMI_Amount__c*(finaltermsList[0].Advance_EMI__c==true?1:0)))/basePrice))*100).setScale(2) : finaltermsList[0].Calculated_Net_LTV__c;//CISP-2491
                    }
                }
            }
            return wrapperObj;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'getFinalTermCalculations', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    public class FinalTermCalculationWrapper{
        @AuraEnabled
        public Decimal netLTV; 
        @AuraEnabled
        public Decimal grossLTV; 
        @AuraEnabled
        public Decimal LTVInvoiceAmount; 
        @AuraEnabled
        public Decimal grossInvoiceAmount;       
        @AuraEnabled
        public Decimal invoiceAmount;          
    }   

    @AuraEnabled
    public static boolean checkInsuranceSubmitted(string loanAppId){
        try {
            Boolean isInsuranceSubmitted = false;
            List<Applicant__c> applicantList = [SELECT Id, Applicant_Type__c,Opportunity__r.Submitted_Tabs__c FROM Applicant__c WHERE Opportunity__c =: loanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY Applicant_Type__c ASC];
            if(applicantList.size() > 0){
                for (Applicant__c appObj : applicantList) {
                    if(appObj.Applicant_Type__c == 'Borrower'){
                        if(appObj.Opportunity__r.Submitted_Tabs__c.contains('Borrower Insurance Recompute')){
                            isInsuranceSubmitted = true;
                        }else{
                            isInsuranceSubmitted = false;
                        }
                    }else if(appObj.Applicant_Type__c == 'Co-borrower'){
                        if(appObj.Opportunity__r.Submitted_Tabs__c.contains('Coborrower Insurance Recompute')){
                            isInsuranceSubmitted = true;
                        }else{
                            isInsuranceSubmitted = false;
                        }
                    }
                }
            }
            return isInsuranceSubmitted;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMApprovalLogController', 'checkInsuranceSubmitted', e.getTypeName(), e, loanAppId);
            return false;
        }
    }
    @AuraEnabled
    public static string calculateFinalTermLTVCalculations(String loanAppId){
        List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
        List<Final_Term__c> listFinalTerms = new List<Final_Term__c>();

        finaltermsList = [select id,Installment_Type__c ,CashFlowPerAnnum__c,Installment_To_Income_Ratio__c,Installment_Frequency__c,Net_Income__c,No_of_Installment__c,Name,OfferengineMinLoanAmount__c,DSM_Incentive2__c,DSM_Incentive1__c,Rreferrer_Incentive__c,Mfr_incentive__c,Gift_through_Dealer_Amount__c,Mfr_Exp_Reimburse_Amt__c,Dlr_Exp_Reimburse_Amt__c,Service_charges__c,Dealer_incentive_amount_main_dealer__c,Trade_certificate__c,Advance_EMI__c,OfferengineMaxLoanAmount__c,Required_CRM_IRR__c,EMI_Amount__c,OfferengineMinTenure__c,OfferengineMaxTenure__c,Tenure__c,PricingEngine_thresholdNetrr__c,LtvEngine_Ltv__c,FIwaiver_co_currentAddress__c, FIwaiver_co_offAddress__c, FIwaiver_co_presentAddress__c,Documentation_charges__c, FIwaiver_currentAddress__c, FIwaiver_offAddress__c,Holiday_period__c, FIwaiver_presentAddress__c,Provisional_Channel_Cost__c,Dealer_incentive_amount_sub_dealer__c,Gross_IRR__c,CRM_IRR__c,Net_IRR__c,Repayment_mode__c,Inputted_IRR__c,Calculated_Net_LTV__c,Calculated_Gross_LTV__c,Is_Loan_Amount_Change_From_CAM__c,Referrer_Name__c,Schemes__r.Name,Refered_By__c,Fi_Score_Band__c, Vehicle_Detail__c,Vehicle_Detail__r.MFC_valuation_Report_URL__c,Vehicle_Detail__r.Valuer_category__c,Loan_amount__c,Vehicle_Detail__r.Grid_value__c,Vehicle_Detail__r.Valuation_price__c,Vehicle_Detail__r.Insurance_declared_value__c, Vehicle_Detail__r.Invoice_Price__c, Vehicle_Detail__r.Selling_Price__c,Vehicle_Detail__r.Total_Funded_Amount__c,Loan_Application__r.Vehicle_Type__c,Loan_Application__r.isTopUpLoan__c,Vehicle_Detail__r.Variant_Code__c FROM Final_Term__c WHERE Loan_Application__c = :loanAppId WITH SECURITY_ENFORCED];
        List<Exposure__c> expoList = [SELECT Id,SOH__c,Type__c  from Exposure__c where Loan_Application__c =:loanAppId and Type__c = 'Borrower Exposure' limit 1];
        Map<String,Decimal> dlpVariantMap = ViewCamController.getDLPVariant(finaltermsList);
        for (Final_Term__c finalTermObj : finaltermsList) {
            Decimal minInvDlp = dlpVariantMap.containsKey(finaltermObj.Vehicle_Detail__r.Variant_Code__c) ? dlpVariantMap.get(finaltermObj.Vehicle_Detail__r.Variant_Code__c) : 0;
            ViewCamController.GrossNetLTVWrapper responseJSONWrapper  = ViewCamController.getGrossNetLTVTractor(finalTermObj,expoList, minInvDlp);
                finalTermObj.Calculated_Gross_LTV__c = decimal.valueOf(responseJSONWrapper.ltvWithInsurance);
                finalTermObj.Calculated_Net_LTV__c = decimal.valueOf(responseJSONWrapper.ltvWithoutInsurance);
                listFinalTerms.add(finalTermObj);
        }
        if(!listFinalTerms.isEmpty()){


            update listFinalTerms;
            return 'success';
         }
         return 'failed';
    }
    @AuraEnabled
    public static boolean isJustificationProvided(String camId){
        Boolean isJustificationProvided = true;
        for (Deviation__c deviation : [SELECT Id,Justification_Remarks__c FROM Deviation__c WHERE Parent_CAM__c=:camId WITH SECURITY_ENFORCED]) {
            if(deviation.Justification_Remarks__c == null){
                isJustificationProvided = false;
                break;
            }
        }
        return isJustificationProvided;
    }
}