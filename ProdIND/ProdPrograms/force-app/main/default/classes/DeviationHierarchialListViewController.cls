/**
* @Enhancement  CISP-2511
* @Name         DeviationHierarchialListViewController
* @Author       Rajat Jaiswal
* @Description  This Class is used to showing all Loan Applications which in committee role hierarchy.
**/

public with sharing class DeviationHierarchialListViewController {
    
    /**
* @Enhancement  CISP-2511
* @Method Name  getDeviationHierarchyList
* @Author       Rajat Jaiswal
* @Description  This method is used to showing all Loan Applications which in committee role hierarchy.
* @Return       List of Deviation wrapper(List of Loan Applications)
**/
    @AuraEnabled
    public static List<DeviationWrapper> getDeviationHierarchyList(){
        try {
            List<DeviationWrapper> deviationWrapperList = new List<DeviationWrapper>();
            List<CAM__c> camList = new List<CAM__c>();
            camList = [SELECT Id,Name,CAM_Page__c,Action_Taken__c,Loan_Application__r.AccountId,Loan_Application__r.Application_number__c,Loan_Application__r.Applicant_Name__c,Loan_Application__r.Employee_Branch__c ,Loan_Application__r.Geo_State_Master__r.Name,Loan_Application__r.Make__c ,Loan_Application__r.Model__c, Loan_Application__r.variant__c ,Loan_Application__r.OwnerId,Loan_Application__r.Total_Exposure_Amount__c,Loan_Application__r.Owner.Name,Committee__c,CAM_Status__c, Generation_Date__c ,SCM_Approval__c,No_of_Days_Pending__c,Deviations_Approved_By_Authorities__c,Total_Deviations__c,Total_Deviations_Proposal_Count__c,Loan_Application__r.Account.BranchBLCode__c,CreatedDate,Trigger_Deviations__c,Deviation_Created_Date__c,Loan_Application__r.Name,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c,Loan_Application__r.Product_Type__c FROM CAM__c WHERE Action_Taken__c=false AND Deviations_Approved_By_Authorities__c != true AND Trigger_Deviations__c = true AND Loan_Application__r.StageName !='Revoke' AND Loan_Application__r.StageName !='Withdrawn'];
            Set<Id> accountIdSet = new Set<Id>();
            
            String currentUserRoleTF = '';
            for (AccountTeamMember accountTeamObj : [SELECT TeamMemberRole,UserId,AccountId FROM AccountTeamMember WHERE UserId=:UserInfo.getUserId() AND TeamMemberRole != null WITH SECURITY_ENFORCED LIMIT 1]) {
                if(String.isBlank(currentUserRoleTF)){
                    currentUserRoleTF =  accountTeamObj.TeamMemberRole;
                }
            }
            List<CAM__c> tempCamList = new  List<CAM__c>();
            if(!camList.isEmpty()){
                for (CAM__c cam : camList) {
                    if(cam.Loan_Application__r.Product_Type__c == System.Label.Tractor){
                        if((cam.Trigger_Deviations__c == true && cam.CAM_Submitted_by_ACM_SCM__c == true) || (cam.Submit_for_Approval_UserId__c == UserInfo.getUserId())){
                            if(cam.Loan_Application__r.AccountId!=null){
                                accountIdSet.add(cam.Loan_Application__r.AccountId);
                            }
                            tempCamList.add(cam);
                        }
                    }else{
                        if(cam.Loan_Application__r.AccountId!=null){
                            accountIdSet.add(cam.Loan_Application__r.AccountId);
                        }
                        tempCamList.add(cam);
                    }
                }
                Map<Id,AccountTeamMember> accountIdVsTeamMember = new Map<Id,AccountTeamMember>();
                String currentUserId = UserInfo.getUserId();
                List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole,UserId,AccountId FROM AccountTeamMember WHERE AccountId IN:accountIdSet AND UserId=:currentUserId WITH SECURITY_ENFORCED LIMIT 10000];
                if(!accountTeamMemberList.isEmpty()){
                    for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                        if(!accountIdVsTeamMember.containsKey(accountTeamObj.AccountId)){
                            accountIdVsTeamMember.put(accountTeamObj.AccountId,accountTeamObj);
                        }
                    }
                }
                
                Map<Id,CAM__c> camIdVsCamObj = new Map<Id,CAM__C>(tempCamList);
                List<Deviation__c> deviationList = new List<Deviation__c>();
                deviationList = [SELECT Id,Parent_CAM__r.Loan_Application__r.Vehicle_Type__c,Approval_Status__c,Proposal_Status__c,Parent_CAM__c,Parent_CAM__r.Loan_Application__r.AccountId,Role__c,Number_of_Days_Pending__c,Deviation_Level__c FROM Deviation__c WHERE Parent_CAM__c IN:camIdVsCamObj.keySet()  WITH SECURITY_ENFORCED Order by Parent_CAM__r.Loan_Application__r.Name LIMIT 10000];
                
                Map<String,List<String>> roleVsHighlightedRoleList = new Map<String,List<String>>();
                
                List<Deviation_Hierarchy_Management__mdt> deviationHierarchyMdtList = [SELECT Label,Highlight_Roles_For__c FROM Deviation_Hierarchy_Management__mdt LIMIT 10000];
                for (Deviation_Hierarchy_Management__mdt metaData : deviationHierarchyMdtList) {
                    if(metaData.Highlight_Roles_For__c != null){
                        roleVsHighlightedRoleList.put(metaData.Label, metaData.Highlight_Roles_For__c.split(','));
                    }
                }
                
                Map<Id,Set<string>> camIdVsRoleListMap =  new Map<Id,Set<string>>();
                Map<Id,List<Deviation__c>> highlightedDeviationsMap =  new Map<Id,List<Deviation__c>>();
                Map<Id,List<Deviation__c>> deviationsTriggeredToMeMap =  new Map<Id,List<Deviation__c>>();
                
                for(Deviation__c deviationObj:deviationList){
                    String accountId = deviationObj.Parent_CAM__r.Loan_Application__r.AccountId; 
                    if(deviationObj.Role__c != null){
                        List<String> deviationRoleList = deviationObj.Role__c.split(',');
                        for (String role : deviationRoleList) {
                            if(roleVsHighlightedRoleList.containsKey(role) && accountIdVsTeamMember.containsKey(accountId) &&  accountIdVsTeamMember.get(accountId).TeamMemberRole != null){
                                if (roleVsHighlightedRoleList.get(role).contains('NSM')) {
                                    if(deviationObj.Parent_CAM__r.Loan_Application__r.Vehicle_Type__c == 'New'){
                                        roleVsHighlightedRoleList.get(role).add('PVNSM');
                                    }else if(deviationObj.Parent_CAM__r.Loan_Application__r.Vehicle_Type__c == 'Used' || deviationObj.Parent_CAM__r.Loan_Application__r.Vehicle_Type__c == 'Refinance'){
                                        roleVsHighlightedRoleList.get(role).add('UPVNSM');
                                    }
                                }
                                if(roleVsHighlightedRoleList.get(role).contains(accountIdVsTeamMember.get(accountId).TeamMemberRole)){
                                    if(!highlightedDeviationsMap.containsKey(deviationObj.Parent_CAM__c)){
                                        highlightedDeviationsMap.put(deviationObj.Parent_CAM__c,new List<Deviation__c>{deviationObj});
                                        camIdVsRoleListMap.put(deviationObj.Parent_CAM__c, new Set<String>{role});
                                    }else {
                                        highlightedDeviationsMap.get(deviationObj.Parent_CAM__c).add(deviationObj);
                                        camIdVsRoleListMap.get(deviationObj.Parent_CAM__c).add(role);
                                    }
                                }
                            }
                            else if(role != null && accountIdVsTeamMember.containsKey(accountId) &&  accountIdVsTeamMember.get(accountId).TeamMemberRole != null && role == accountIdVsTeamMember.get(accountId).TeamMemberRole){
                                if(!deviationsTriggeredToMeMap.containsKey(deviationObj.Parent_CAM__c)){
                                    deviationsTriggeredToMeMap.put(deviationObj.Parent_CAM__c,new List<Deviation__c>{deviationObj});
                                }else {
                                    deviationsTriggeredToMeMap.get(deviationObj.Parent_CAM__c).add(deviationObj);
                                }
                            }
                        }
                    }
                }
                
                for (Id camId : highlightedDeviationsMap.keySet()) {
                    CAM__c camObj = camIdVsCamObj.get(camId);
                    DeviationWrapper wrapperObj = new DeviationWrapper();
                    wrapperObj.cam = camObj.Name;
                    wrapperObj.applicantName = camObj.Loan_Application__r.Applicant_Name__c;
                    // wrapperObj.deviationDescription = deviationObj.Deviation_Description__c;
                    // wrapperObj.deviationLevel = deviationObj.Deviation_Level__c;
                    wrapperObj.isHighlighted = true;
                    wrapperObj.loanApplication = camObj.Loan_Application__r.Name;
                    wrapperObj.camLink = camId;
                    wrapperObj.style = 'background:#fff700';
                    List<String> roleList = new List<String>();
                    roleList.addAll(camIdVsRoleListMap.get(camId));
                    wrapperObj.loanApplicationId = camObj.Loan_Application__c;//CISP-2869
                    wrapperObj.deviationTriggeredTo = String.join(roleList, ',');
                    deviationWrapperList.add(wrapperObj);
                }
                for (Id camId : deviationsTriggeredToMeMap.keySet()) {
                    CAM__c camObj = camIdVsCamObj.get(camId);
                    DeviationWrapper wrapperObj = new DeviationWrapper();
                    wrapperObj.cam = camObj.Name;
                    wrapperObj.applicantName = camObj.Loan_Application__r.Applicant_Name__c;
                    // wrapperObj.deviationDescription = deviationObj.Deviation_Description__c;
                    // wrapperObj.deviationLevel = deviationObj.Deviation_Level__c;
                    wrapperObj.isHighlighted = false;
                    wrapperObj.loanApplication = camObj.Loan_Application__r.Name;
                    wrapperObj.camLink = camId;
                    wrapperObj.loanApplicationId = camObj.Loan_Application__c;//CISP-2869
                    wrapperObj.style = null;
                    wrapperObj.deviationTriggeredTo = '';//CISP-2869
                    deviationWrapperList.add(wrapperObj);
                }
            }
            return deviationWrapperList;            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('DeviationHierarchialListViewController', 'getDeviationHierarchyList', e.getTypeName(), e, '');
        }
        return null;
    }
    
    /**
* @Enhancement  CISP-2511
* @Wrapper Name  DeviationWrapper
* @Author        Rajat Jaiswal
* @Description   This wrapper used to store value of Loan Applications
**/
    public Class DeviationWrapper{
        @auraEnabled public string loanApplication;
        @auraEnabled public string applicantName;
        @auraEnabled public string cam;
        @auraEnabled public string deviationDescription;
        @auraEnabled public string deviationLevel;
        @auraEnabled public string deviationTriggeredTo;
        @auraEnabled public string style;
        @auraEnabled public string camLink;
        @auraEnabled public string loanApplicationId;//CISP-2869
        @auraEnabled public Boolean isHighlighted;
        
    }
}