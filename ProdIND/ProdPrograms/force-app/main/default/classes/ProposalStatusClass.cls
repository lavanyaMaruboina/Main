/**
* @Name         ProposalStatusClass
* @Author       Rajat Jaiswal
* @Description  This Class is used to showing Proposal Status of CAM.
**/
public with sharing class ProposalStatusClass {
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch related Pending Proposal Loan Application list and showing the data to CAM summary screen.
***********************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<CAM__c> pendingProposalLoanApplication(String camId){
        try {
            List<CAM__c> pendingProposal = [SELECT Loan_Application__r.Id,Loan_Application__r.Application_number__c,
                                            Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Exposure_Amount__c,
                                            Loan_Application__r.Employee_Branch__c,Loan_Application__r.Make__c ,Loan_Application__r.Model__c, Loan_Application__r.variant__c ,Loan_Application__r.OwnerId,Loan_Application__r.Owner.Name,
                                            Committee__c,CAM_Status__c, Generation_Date__c ,SCM_Approval__c,No_of_Days_Pending__c,
                                            (SELECT Id ,Name, Hold_by_others__c From Proposal_Approval_Logs__r LIMIT 1000) 
                                            FROM CAM__c where CAM_Status__c ='Pending for approval' WITH SECURITY_ENFORCED];
            
            return pendingProposal;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'pendingProposalLoanApplication', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
        
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch related Proposal Hold By You list and showing the data to CAM summary screen.
***********************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<CAM__c> proposalHoldByYou(String camId){
        try{
            List<CAM__c> pendingProposal = [SELECT Loan_Application__r.Id,Loan_Application__r.Application_number__c,
                                            Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Exposure_Amount__c,
                                            Loan_Application__r.Employee_Branch__c ,Loan_Application__r.variant__c ,Loan_Application__r.OwnerId,
                                            Committee__c,CAM_Status__c, Generation_Date__c ,SCM_Approval__c,No_of_Days_Pending__c,
                                            (SELECT Id ,Name, Hold_by_others__c From Proposal_Approval_Logs__r LIMIT 1)
                                            FROM CAM__c where Id=:camId AND CAM_Status__c ='Hold by you' WITH SECURITY_ENFORCED];
            return pendingProposal;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'proposalHoldByYou', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch related Proposal Not Approved By SCM list and showing the data to CAM summary screen.
***********************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<CAM__c> proposalNotApprovedBySCM(String camId){
        try {
            List<CAM__c> pendingProposal = [SELECT Loan_Application__r.Id,Loan_Application__r.Application_number__c
                                            ,Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Exposure_Amount__c,
                                            Loan_Application__r.Employee_Branch__c ,Loan_Application__r.variant__c ,Loan_Application__r.OwnerId,
                                            Committee__c,CAM_Status__c, Generation_Date__c ,SCM_Approval__c,No_of_Days_Pending__c,
                                            (SELECT Id ,Name, Hold_by_others__c From Proposal_Approval_Logs__r LIMIT 1) 
                                            FROM CAM__c where Id=:camId AND CAM_Status__c ='Not approved by SCM' AND SCM_Approval__c ='Not approved' WITH SECURITY_ENFORCED];
            return pendingProposal;    
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'proposalNotApprovedBySCM', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch related Proposal Forwarded By You list and showing the data to CAM summary screen.
***********************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<CAM__c> proposalForwardedByYou(String camId){
        try {
            Proposal_Approval_Log__c proposalLog = new Proposal_Approval_Log__c();
            List<CAM__c> pendingProposal = [SELECT Loan_Application__r.Id,Loan_Application__r.Application_number__c,
                                            Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Exposure_Amount__c,
                                            Loan_Application__r.Employee_Branch__c ,Loan_Application__r.variant__c ,Loan_Application__r.OwnerId,
                                            Committee__c,CAM_Status__c, Generation_Date__c ,SCM_Approval__c,No_of_Days_Pending__c,
                                            (SELECT Id ,Name, Hold_by_others__c,Forwarded_Employee__c  From Proposal_Approval_Logs__r LIMIT 1) 
                                            FROM CAM__c where Id=:camId AND CAM_Status__c ='Forwarded to you' WITH SECURITY_ENFORCED];          
            User runningUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
            if(pendingProposal.size()>0){
                proposalLog = pendingProposal[0].Proposal_Approval_Logs__r ; 
                if(runningUser.Id==proposalLog.Forwarded_Employee__c){
                    return pendingProposal;
                }
            }        
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'proposalForwardedByYou', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
        }
        return null;
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch all state list and showing the data to CAM summary screen.
***********************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<CFD_State_Master__C> getAllState(){
        try {
            List<CFD_State_Master__c> stateList = new List<CFD_State_Master__c>();
            stateList =[SELECT Id, Name, CFD_State_Code__c FROM CFD_State_Master__c ORDER BY Name];
            return stateList;            
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'getAllState', e.getTypeName(), e, '');
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch related state Bank Branch list and showing the data to CAM summary screen.
***********************************************/ 
    @AuraEnabled
    public static List<BankBranchDetails__c> getRelatedBLCodes(string state){
        try {
            if(String.isNotBlank(state)){
                List<Geo_State_Masters__c> stateList = new List<Geo_State_Masters__c>();
                stateList =[SELECT Id,Name FROM Geo_State_Masters__c WHERE Name=:state LIMIT 1];
                List<BankBranchDetails__c> branchDetails = new List<BankBranchDetails__c>();
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'getRelatedBLCodes', e.getTypeName(), e, '');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch related state Bank Branch list and showing the data to CAM summary screen.
***********************************************/ 
    @AuraEnabled(cacheable=true)
    public static  List<BankBranchDetails__c> blCodeMapping(String stateKey){
        try {
            if(stateKey!=null){
                List<BankBranchDetails__c> bankBranchList = [SELECT Id, Geo_State_Master__c,Bl_Code__c, Address_1__c, Address_2__c, Address_3__c, Address_4__c, Pincode__c, City__c, State_Code__c, Business_Hub__c, Bl_Code_Details__c, Product__c, UniqueIdentifier__c, District__c, Name FROM BankBranchDetails__c WHERE State_Code__c=:stateKey ];
                return bankBranchList;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'blCodeMapping', e.getTypeName(), e, '');
        }
        return null;
    }
    
    
    // filtering the proposals
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to filter the CAM based on the criterias selected by user in CAM summary screen and processes the whole data and return all the deviations and proposals related to them.
***********************************************/
    @AuraEnabled()
    public static CamDataWrapper searchLogs(String productName, String Category,String State ,String BLCode,String committee, String daysPending, String leadNum, String approvedBy,String stateName,String pendingWith){//CISP-2864
        try {
            String currentUserId = UserInfo.getUserId();
            List<Proposal_Approval_Log__c> proposalApprovalLogList = [SELECT Id, Parent_CAM__c FROM Proposal_Approval_Log__c WHERE Approval_Status__c = 'Hold' AND Parent_CAM__r.Is_Hold__c = true AND CreatedById = :currentUserId AND Parent_CAM__r.Action_Taken__c = false];
            Set<String> camIdSet = new Set<String>();
            if (!proposalApprovalLogList.isEmpty()) {
                for (Proposal_Approval_Log__c palRecord : proposalApprovalLogList) {
                    camIdSet.add(palRecord.Parent_CAM__c);
                }
            }
            List<String> committeeList = new List<String>{'CCC', 'COCC1', 'COCC2'};
                List<Deviation__c> notApprovedDeviationByNonMandatoryList = [SELECT Id, Parent_CAM__c FROM Deviation__c WHERE Parent_CAM__r.Action_Taken__c = TRUE AND Proposal_Status__c = null AND Approval_Status__c = null AND Deviation_Level__c IN :committeeList];
            Set<Id> camIdToConsiderSet = new Set<Id>();
            if (notApprovedDeviationByNonMandatoryList.size() > 0) {
                for (Deviation__c deviationRecord : notApprovedDeviationByNonMandatoryList) {
                    camIdToConsiderSet.add(deviationRecord.Parent_CAM__c);
                }
            }
            Map<Id,AccountTeamMember> accountIdVsTeamMember = new Map<Id,AccountTeamMember>();
            List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole,UserId,AccountId FROM AccountTeamMember WHERE UserId=:currentUserId WITH SECURITY_ENFORCED];
            String currentUserRoleTF = '';
            if(!accountTeamMemberList.isEmpty()){
                for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                    if(String.isBlank(currentUserRoleTF)){
                        currentUserRoleTF =  accountTeamObj.TeamMemberRole;
                    }
                    accountIdVsTeamMember.put(accountTeamObj.AccountId,accountTeamObj);
                }
            }
            Set<Id> accountIdSet = accountIdVsTeamMember.keySet();
            String query = 'SELECT Id,Loan_Application__r.AccountId,Loan_Application__r.Application_number__c,Loan_Application__r.Applicant_Name__c,Loan_Application__r.Owner.Name,Committee__c,No_of_Days_Pending__c,Loan_Application__r.Account.BranchBLCode__c,Trigger_Deviations__c,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c,Deviation_Created_Date__c,Deviation_Created_Time__c,Deviation_Created_Date_Time__c,Loan_Application__r.Name,Loan_Application__r.Product_Type__c FROM CAM__c WHERE (Id IN :camIdToConsiderSet OR (Action_Taken__c=false AND Loan_Application__r.StageName =\'Credit Processing\')) AND Loan_Application__r.Is_Revoked__c != true AND Loan_Application__r.StageName != \'Journey Restart\' AND Proposal_Status__c = null AND Loan_Application__r.AccountId IN :accountIdSet AND Id NOT IN (SELECT Parent_CAM__c FROM deviation__c WHERE Approval_Status__c = \'Rejected\' OR Proposal_Status__c = \'Rejected\') AND Id NOT IN (SELECT Parent_CAM__c FROM Proposal_Approval_Log__c WHERE Approval_Status__c IN (\'Rejected\',\'Reject\'))';//CISP-2529 //CISP-3002 //CISP-3115 //CISP-7949
            Boolean hasCondition = false;
            string productCondtion = String.isNotBlank(productName)? ' AND (Loan_Application__r.Product_Type__c =: productName)':'';
            if(productName=='ALL'){
                productCondtion =  ' AND (Loan_Application__r.Product_Type__c = \'Two Wheeler\' OR Loan_Application__r.Product_Type__c = \'Passenger Vehicles\' OR Loan_Application__r.Product_Type__c = \'Tractor\')';
            }
            string categoryCondition = String.isNotBlank(Category)? ' AND (Loan_Application__r.Vehicle_Type__c =:Category)':''; 
            if(Category=='ALL'){
                categoryCondition =  ' AND (Loan_Application__r.Vehicle_Type__c = \'New\' OR Loan_Application__r.Vehicle_Type__c = \'Used\' OR Loan_Application__r.Vehicle_Type__c = \'Refinance\')';
            }
            string stateConditions = String.isNotBlank(State) && String.isNotBlank(stateName) ? ' AND (Loan_Application__r.Account.Account_Type__c =\'Branch\' AND Loan_Application__r.Account.State__c=:stateName )': '';
            string blCodesCondition = String.isNotBlank(BLCode) ? ' AND (Loan_Application__r.Account.Account_Type__c = \'Branch\' AND Loan_Application__r.Account.BranchBLCode__c =: BLCode)' : '';
            String committeeCondition = String.isNotBlank(committee)? ' AND (Committee__c =:committee)':'';
            if(committee=='ALL'){
                committeeCondition =  ' AND (Committee__c = \'BCC\' OR Committee__c = \'SCC\' OR Committee__c = \'ZCC\' OR Committee__c = \'CCC\' OR Committee__c = \'COCC1\' OR Committee__c = \'COCC2\')';
            }
            string daysPendingCondition;
            if(daysPending!=null){
                Integer days = Integer.valueOf(daysPending);
                if (days == 3) {//Start CISP-2863
                    daysPendingCondition =  ' AND (No_of_Days_Pending__c >=: days AND No_of_Days_Pending__c <= 7)';
                } else if (days == 7) {
                    daysPendingCondition =  ' AND (No_of_Days_Pending__c >: days)';
                }//End CISP-2863
                else {
                    daysPendingCondition =  ' AND (No_of_Days_Pending__c=:days)';
                }
            }
            else {
                daysPendingCondition = '';
            }
            string leadNoCondition = leadNum!=null && leadNum!='' ? ' AND (Loan_Application__r.Name=: leadNum)':'';
            if(String.isNotEmpty(productCondtion) || String.isNotEmpty(categoryCondition) || String.isNotEmpty(committeeCondition) || String.isNotEmpty(daysPendingCondition) || String.isNotEmpty(leadNoCondition) || String.isNotEmpty(stateConditions) || String.isNotEmpty(blCodesCondition)){
                hasCondition = true;
            }
            string queryString;
            string productLimitCondition = String.isNotBlank(productName) && productName == 'Two Wheeler' ? ' LIMIT 2000':'';
            if(hasCondition){
                queryString = Query + productCondtion +categoryCondition + committeeCondition + daysPendingCondition + leadNoCondition + stateConditions + blCodesCondition + ' order by LastModifiedDate DESC'+ productLimitCondition;//CISP-7949';
            }
            else {
                queryString = Query +' order by LastModifiedDate DESC'+ productLimitCondition;//CISP-7949'; 
            }
            List<CAM__c> records = new List<CAM__c>();
            records = Database.query(queryString);
            Map<Id,CAM__c> loanIdVsCamObjMap = new Map<Id,CAM__C>();
            Set<String> blCodeSet = new Set<String>();
            List<CAM__c> tempRecords = new List<CAM__c>();
            for (CAM__c cam : records) {
                if(cam.Loan_Application__r.Product_Type__c == System.Label.Tractor){
                    if((cam.Trigger_Deviations__c == true && cam.CAM_Submitted_by_ACM_SCM__c == true) || (cam.Trigger_Deviations__c == true && (cam.Submit_for_Approval_UserId__c == UserInfo.getUserId()))){
                        if(!loanIdVsCamObjMap.containsKey(cam.Loan_Application__c)){
                            loanIdVsCamObjMap.put(cam.Loan_Application__c,cam);
                        }
                        if(cam.Loan_Application__r.AccountId!=null){
                            if(cam.Loan_Application__r.Account.BranchBLCode__c != null){
                                blCodeSet.add(cam.Loan_Application__r.Account.BranchBLCode__c);
                            }
                        }
                        tempRecords.add(cam);
                    }
                }else{
                    if(!loanIdVsCamObjMap.containsKey(cam.Loan_Application__c)){
                        loanIdVsCamObjMap.put(cam.Loan_Application__c,cam);
                    }
                    if(cam.Loan_Application__r.AccountId!=null){
                        if(cam.Loan_Application__r.Account.BranchBLCode__c != null){
                            blCodeSet.add(cam.Loan_Application__r.Account.BranchBLCode__c);
                        }
                    }
                    tempRecords.add(cam);
                }
            }
            Map<Id,CAM__c> camIdVsCamObj = new Map<Id,CAM__C>(tempRecords);
            
            // Map<String,String> committeeDeviationPVRolesMap = new Map<String,String>();
            // List<Committee_Deviation__mdt> committeeDeviationMDList=[SELECT Id,Label,DeveloperName,CCC_Above_Flag__c,Mandatory_Role__c,Non_Mandatory_Role__c from Committee_Deviation__mdt WHERE Product__c='Passenger Vehicles' WITH SECURITY_ENFORCED limit 100 ];
            // if(committeeDeviationMDList!=null && committeeDeviationMDList.size()>0){
            //     for(Committee_Deviation__mdt committeeMdt:committeeDeviationMDList){
            //         if(!committeeDeviationPVRolesMap.containsKey(committeeMdt.Label)){
            //             committeeDeviationPVRolesMap.put(committeeMdt.Label,committeeMdt.Non_Mandatory_Role__c);
            //         }
            //     }
            // }
            // Map<String,String> committeeDeviationTWRolesMap = new Map<String,String>();
            // committeeDeviationMDList=[SELECT Id,Label,DeveloperName,CCC_Above_Flag__c,Mandatory_Role__c,Non_Mandatory_Role__c from Committee_Deviation__mdt WHERE Product__c='Two Wheeler' WITH SECURITY_ENFORCED limit 100 ];
            // if(committeeDeviationMDList!=null && committeeDeviationMDList.size()>0){
            //     for(Committee_Deviation__mdt committeeMdt:committeeDeviationMDList){
            //         if(!committeeDeviationTWRolesMap.containsKey(committeeMdt.Label)){
            //             committeeDeviationTWRolesMap.put(committeeMdt.Label,committeeMdt.Non_Mandatory_Role__c);
            //         }
            //     }
            // }
            
            List<Deviation__c> deviationList = new List<Deviation__c>();
            deviationList = [SELECT Id,Approval_Status__c,Proposal_Status__c,Parent_CAM__c,Role__c,Number_of_Days_Pending__c,Type__c FROM Deviation__c WHERE Parent_CAM__c IN:camIdVsCamObj.keySet() WITH SECURITY_ENFORCED];//CISP-3115
            Map<Id,List<Deviation__c>> camIdVsDeviationList = new Map<Id,List<Deviation__c>>();
            Map<Id,List<String>> camIdVsDeviationRoleList = new Map<Id,List<String>>();//CISP-2864
            for (Deviation__c deviationObj : deviationList) {
                if(!camIdVsDeviationList.containsKey(deviationObj.Parent_CAM__c)){
                    camIdVsDeviationList.put(deviationObj.Parent_CAM__c,new List<Deviation__c>());
                }
                camIdVsDeviationList.get(deviationObj.Parent_CAM__c).add(deviationObj);
                if(deviationObj.Role__c != null){//Start CISP-2864
                    if(!camIdVsDeviationRoleList.containsKey(deviationObj.Parent_CAM__c)){
                        camIdVsDeviationRoleList.put(deviationObj.Parent_CAM__c,new List<String>());
                    }
                    camIdVsDeviationRoleList.get(deviationObj.Parent_CAM__c).addAll(deviationObj.Role__c.split(','));
                }//End CISP-2864
            }
            Map<String,String> camIdVsApprovalByStatus = new Map<String,String>();
            Map<Id,String> camIdVsIsHold = new Map<Id,String>();
            Map<Id,Boolean> camIdVsCurrentUserAccept = new Map<Id,Boolean>();
            Map<Id,Boolean> camIdVsPendingWithUser = new Map<Id,Boolean>();//CISP-2864
            Map<Id,List<Deviation__c>> camIdVsFinalDeviationList = new Map<Id,List<Deviation__c>>();
            for(Id camId:camIdVsDeviationList.keySet()){
                if(camIdVsDeviationList.containsKey(camId) && !camIdVsDeviationList.get(camId).isEmpty()){
                    Boolean checkIfApproved = false;
                    Boolean hasCurrentUser = false;
                    Boolean hasApprovedByUser = false;
                    Boolean checkIfHold = false;
                    Boolean pendingWithUser = false;//CISP-2864
                    if(!camIdVsIsHold.containsKey(camId)){
                        camIdVsIsHold.put(camId, 'No');
                    }
                    if(camIdVsCamObj.containsKey(camId) && camIdVsCamObj.get(camId).Loan_Application__r.AccountId!=null && camIdVsCamObj.get(camId).Trigger_Deviations__c==true){
                        String currentUserRole = accountIdVsTeamMember.containsKey(camIdVsCamObj.get(camId).Loan_Application__r.AccountId)?accountIdVsTeamMember.get(camIdVsCamObj.get(camId).Loan_Application__r.AccountId).TeamMemberRole:null;
                        for(Deviation__c deviationObj:camIdVsDeviationList.get(camId)){
                            if(deviationObj.Role__c!=null && currentUserRole!=null && deviationObj.Role__c.contains(currentUserRole)){
                                if(deviationObj.Approval_Status__c==null){
                                    hasCurrentUser = true;
                                }
                                if(deviationObj.Approval_Status__c == 'Approved'){
                                    camIdVsCurrentUserAccept.put(camId, true);
                                }
                            }
                            if(deviationObj.Role__c!=null && approvedBy!=null && deviationObj.Role__c.contains(approvedBy)){
                                hasApprovedByUser = true;
                                if(deviationObj.Approval_Status__c=='Approved'){
                                    checkIfApproved = true;
                                }
                                else {//CISP-2476
                                    checkIfApproved = false;
                                }//CISP-2476
                            }
                            if(deviationObj.Proposal_Status__c=='Hold'){
                                camIdVsIsHold.put(camId,'Yes');
                            }
                            if(pendingWith!=null && deviationObj.Role__c!=null && deviationObj.Role__c==pendingWith && deviationObj.Approval_Status__c==null){//Start CISP-2864
                                pendingWithUser = true;
                                camIdVsPendingWithUser.put(camId, true);//CISP-2864
                            }
                        }
                        if(hasCurrentUser && hasApprovedByUser==false){
                            if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                camIdVsApprovalByStatus.put(camId, approvedBy+' Not Available');
                            }//End CISP-2864
                        }
                        if(hasCurrentUser && hasApprovedByUser && currentUserRole!=null && approvedBy!=null && currentUserRole==approvedBy && checkIfApproved==false){
                            camIdVsApprovalByStatus.put(camId, 'Not Approved');
                        }
                        if(hasCurrentUser && hasApprovedByUser && checkIfApproved==false){
                            camIdVsApprovalByStatus.put(camId, 'Not Approved');
                        }
                        if(hasCurrentUser && hasApprovedByUser && checkIfApproved){
                            if(pendingWith==null || (pendingWith!=null && pendingWithUser)){//Start CISP-2864
                            camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                            camIdVsApprovalByStatus.put(camId, 'Approved');
                            }//End CISP-2864
                        }
                    }
                }
            }
            List<Proposal_Approval_Log__c> proposalLogList = new List<Proposal_Approval_Log__c>();
            proposalLogList = [SELECT Id,RecordType.Name,Forwarding_Employee__c,RecordTypeId,Parent_CAM__c,Forwarded_By__c,Forwarded_Employee__c,Approval_Status__c FROM Proposal_Approval_Log__c WHERE ((RecordType.Name='Forward log' AND Forwarded_Employee__c=:UserInfo.getUserId()) OR (RecordType.Name='Proposal log' AND CreatedById =: UserInfo.getUserId() AND Approval_Status__c !=null)) AND Parent_CAM__c IN:camIdVsCamObj.keySet() AND Parent_CAM__r.Action_Taken__c=false WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];

            List<Proposal_Approval_Log__c> forwardedProposalLogList = new List<Proposal_Approval_Log__c>();//Start CISP-2532
            forwardedProposalLogList = [SELECT Id,Parent_CAM__c,Is_Forwarded_Flag__c FROM Proposal_Approval_Log__c WHERE Forwarding_Employee__c=:UserInfo.getUserId() AND RecordType.Name='Forward log' AND Parent_CAM__c IN:camIdVsCamObj.keySet() AND Parent_CAM__r.Action_Taken__c=false WITH SECURITY_ENFORCED ORDER BY LastModifiedDate ASC];
            List<String> forwardedByProposalList = new List<String>();
            Map<Id,Boolean> camIdVsForwardedtoCurrentUser = new Map<Id,Boolean>();
            for(Proposal_Approval_Log__c proposalObj : forwardedProposalLogList){
                if(!camIdVsForwardedtoCurrentUser.containsKey(proposalObj.Parent_CAM__c)){
                    camIdVsForwardedtoCurrentUser.put(proposalObj.Parent_CAM__c, proposalObj.Is_Forwarded_Flag__c);
                } else{
                    camIdVsForwardedtoCurrentUser.put(proposalObj.Parent_CAM__c, proposalObj.Is_Forwarded_Flag__c);
                }
            }//End CISP-2532
            if(!camIdVsForwardedtoCurrentUser.isEmpty()){
                for (Id camId : camIdVsForwardedtoCurrentUser.keySet()) {
                    if(camIdVsForwardedtoCurrentUser.get(camId) == true){
                        forwardedByProposalList.add(camId);
                    }
                }
            }
            Map<Id,List<String>> camIdVsProposalList = new Map<Id,List<String>>();
            Map<Id,Boolean> camIdVsCurrentForwardedUserAccept = new Map<Id,Boolean>();
            List<Proposal_Approval_Log__c> forwardToYouProposalList = new List<Proposal_Approval_Log__c>();
            for (Proposal_Approval_Log__c proposalVar : proposalLogList) {
                if(!camIdVsCurrentForwardedUserAccept.containsKey(proposalVar.Parent_CAM__c) || (camIdVsCurrentForwardedUserAccept.containsKey(proposalVar.Parent_CAM__c) && camIdVsCurrentForwardedUserAccept.get(proposalVar.Parent_CAM__c) != true)){
                    camIdVsCurrentForwardedUserAccept.put(proposalVar.Parent_CAM__c, false);
                }
                if(proposalVar.RecordTypeId != null && proposalVar.RecordType.Name == 'Proposal log'){
                    camIdVsCurrentForwardedUserAccept.put(proposalVar.Parent_CAM__c, true);
                } else if(proposalVar.RecordTypeId != null && proposalVar.RecordType.Name == 'Forward log'){
                    camIdVsCurrentForwardedUserAccept.put(proposalVar.Parent_CAM__c, false);
                }
            }
            for (Proposal_Approval_Log__c proposalObj : proposalLogList) {
                if(!camIdVsproposalList.containsKey(proposalObj.Parent_CAM__c)){
                    camIdVsproposalList.put(proposalObj.Parent_CAM__c,new List<String>());
                }
                if(proposalObj.RecordTypeId != null && proposalObj.RecordType.Name == 'Forward log'){
                    camIdVsproposalList.get(proposalObj.Parent_CAM__c).add(proposalObj.Forwarded_Employee__c);
                }
                if(proposalObj.Forwarded_Employee__c==UserInfo.getUserId() && ((camIdVsCurrentUserAccept.containsKey(proposalObj.Parent_CAM__c) && camIdVsCurrentUserAccept.get(proposalObj.Parent_CAM__c) == false) || ( (camIdVsCurrentForwardedUserAccept.containsKey(proposalObj.Parent_CAM__c) && camIdVsCurrentForwardedUserAccept.get(proposalObj.Parent_CAM__c) == false)))){//CISP-2977 //CISP-3115
                    if(pendingWith==null || (pendingWith!=null && camIdVsDeviationRoleList.containsKey(proposalObj.Parent_CAM__c) && camIdVsDeviationRoleList.get(proposalObj.Parent_CAM__c).contains(pendingWith) && camIdVsPendingWithUser.containsKey(proposalObj.Parent_CAM__c))){//Start CISP-2864
                        forwardToYouProposalList.add(proposalObj);
                    }//End CISP-2864
                }
            }
            
            Map<Id,BankBranchDetails__c> loanApplicationVsBankBranch = new Map<Id,BankBranchDetails__c>();
            List<BankBranchDetails__c> bankBranchList = [SELECT Id,Name,Bl_Code__c FROM BankBranchDetails__c WHERE Bl_Code__c IN: blCodeSet];
            Map<String, BankBranchDetails__c> blCodeVsBankBranch = new Map<String, BankBranchDetails__c>();
            if(bankBranchList.size()>0 && loanIdVsCamObjMap != null){
                for (BankBranchDetails__c bankBranch : bankBranchList) {
                    if(bankBranch.Bl_Code__c!=null && !blCodeVsBankBranch.containsKey(bankBranch.Bl_Code__c)){
                        blCodeVsBankBranch.put(bankBranch.Bl_Code__c, bankBranch);
                    }
                }
            }
            List<Applicant__c> applicantList = [SELECT Id, Name, Opportunity__c FROM Applicant__c WHERE Opportunity__c IN: loanIdVsCamObjMap.keySet() AND In_Active_Applicant__c = false AND Applicant_Type__c = 'Borrower' WITH SECURITY_ENFORCED];
            if(applicantList.size()>0){
                Set<Id> oppIdSet = new Set<Id>();
                for(Applicant__c  applicant : applicantList) {
                    if (!oppIdSet.contains(applicant.Opportunity__c)) {
                        camIdVsCamObj.get(loanIdVsCamObjMap.get(applicant.Opportunity__c).Id).Loan_Application__r.Applicant_Name__c = applicant.Name;
                        oppIdSet.add(applicant.Opportunity__c);
                    }
                }
            }
            Map<Id,Decimal> loanIdVsTotalExposure = new Map<id,Decimal>();
            Map<Id,Decimal> loanIdVsfinalLoanAmount =  new Map<Id,Decimal>();
            List<Final_Term__c> finalTermList = [SELECT Id, Loan_Application__c,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c FROM Final_Term__c WHERE Loan_Application__c IN: loanIdVsCamObjMap.keySet() WITH SECURITY_ENFORCED];
            if(finalTermList.size()>0){
                for(Final_Term__c finalObj : finalTermList){
                    loanIdVsfinalLoanAmount.put(finalObj.Loan_Application__c ,finalObj.Loan_Amount__c == null ? 0: (Decimal.valueof(finalObj.Loan_Amount__c) + finalObj.Loan_Application__r.Total_Funded_Premium__c));
                }
            }
            List<Exposure__c> expList = new List<Exposure__c>();
            expList = [SELECT id,Loan_Application__c,Sanctioned_Amt__c,SOH__c,Type__c FROM Exposure__c WHERE Loan_Application__c IN :loanIdVsCamObjMap.keySet() WITH SECURITY_ENFORCED];
            Map<Id, List<Exposure__c>> loanIdVsExpListMap = new Map<Id, List<Exposure__c>>();
            if(expList.size()>0){
                for (Exposure__c exp : expList) {
                    if (!loanIdVsExpListMap.containsKey(exp.Loan_Application__c)) {
                        loanIdVsExpListMap.put(exp.Loan_Application__c, new List<Exposure__c>{exp});
                    }else{
                        loanIdVsExpListMap.get(exp.Loan_Application__c).add(exp);
                    }
                }
            }
            for(Id loanId :loanIdVsCamObjMap.keySet()){
                if(blCodeVsBankBranch != null){
                    if(loanIdVsCamObjMap.get(loanId).Loan_Application__r.AccountId != null && loanIdVsCamObjMap.get(loanId).Loan_Application__r.Account.BranchBLCode__c != null && blCodeVsBankBranch.containsKey(loanIdVsCamObjMap.get(loanId).Loan_Application__r.Account.BranchBLCode__c)){
                        if(!loanApplicationVsBankBranch.containsKey(loanId)){
                            loanApplicationVsBankBranch.put(loanId, blCodeVsBankBranch.get(loanIdVsCamObjMap.get(loanId).Loan_Application__r.Account.BranchBLCode__c));
                        }
                    }
                }
                Decimal totalExposureAmount = 0;
                if(expList.size()>0 && loanIdVsExpListMap!=null && loanIdVsExpListMap.containsKey(loanId)){
                    for(Exposure__c expObj : loanIdVsExpListMap.get(loanId)){
                        if(expObj.Type__c == System.Label.Borrower_Exposure){ 
                            totalExposureAmount += expObj.SOH__c !=null ? (Decimal)expObj.SOH__c : 0;
                        }
                        if(expObj.Type__c == System.Label.Co_Borrower_Exposure){
                            totalExposureAmount += expObj.SOH__c !=null ? (Decimal)expObj.SOH__c : 0;
                        }
                        if(expObj.Type__c == System.Label.Additional_Customer){
                            totalExposureAmount += expObj.SOH__c !=null ? (Decimal)expObj.SOH__c : 0;
                        }
                        if(expObj.Type__c == System.Label.Bank_Exposure){
                            totalExposureAmount += expObj.Sanctioned_Amt__c != null? (Decimal)expObj.Sanctioned_Amt__c : 0;
                        }
                    }
                }
                if(loanIdVsfinalLoanAmount.containskey(loanId) && loanIdVsfinalLoanAmount.get(loanId) != null){
                    loanIdVsTotalExposure.put(loanId,(loanIdVsfinalLoanAmount.get(loanId) + totalExposureAmount));
 
                }
             }
            CamDataWrapper dataWrapperObj = new CamDataWrapper();
            dataWrapperObj.camIdVsCamObjMap = camIdVsCamObj;
            dataWrapperObj.loanIdVsCamObjMap = loanIdVsCamObjMap;
            dataWrapperObj.camIdVsDeviationListMap = camIdVsFinalDeviationList;
            dataWrapperObj.camIdVsForwardedUserMap = camIdVsProposalList;
            dataWrapperObj.camIdVsApprovalByStatus = camIdVsApprovalByStatus;
            dataWrapperObj.camIdVsIsHoldMap = camIdVsIsHold;
            dataWrapperObj.accountIdVsTeamMemberMap = accountIdVsTeamMember;
            dataWrapperObj.forwardToYouProposalList = forwardToYouProposalList;
            dataWrapperObj.loanApplicationVsBankBranch = loanApplicationVsBankBranch;
            dataWrapperObj.loanIdVsVehicleDetail = getLoanIdVsVehicleDetail(loanIdVsCamObjMap.keySet());
            dataWrapperObj.loanIdVsTotalExposure = loanIdVsTotalExposure;
            dataWrapperObj.currentUserId = UserInfo.getUserId();
            dataWrapperObj.camIdSet = new List<String>(camIdSet);
            dataWrapperObj.forwardedByProposalList = forwardedByProposalList;//CISP-2532
            Return dataWrapperObj;   
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'searchLogs', e.getTypeName(), e, '');
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch all the proposals that are forwarded to the current login user.
***********************************************/
    @AuraEnabled
    public static CamDataWrapper fetchForwardedProposals(Map<Id,CAM__c> camIdVsCamMap,string pendingWith){//CISP-2864
        try {
            if(camIdVsCamMap!=null){
                CamDataWrapper dataWrapperObj = new CamDataWrapper();
                string currentUserId = UserInfo.getUserId();
                List<Proposal_Approval_Log__c> proposalLogList = new List<Proposal_Approval_Log__c>();
                if(pendingWith==null){//Start CISP-2864
                    proposalLogList = [SELECT Id,Forwarding_Employee__c,Parent_CAM__c,Forwarded_By__c,Forwarded_Employee__c FROM Proposal_Approval_Log__c WHERE Forwarding_Employee__c=:currentUserId AND RecordType.Name='Forward log' AND Parent_CAM__c IN:camIdVsCamMap.keySet() AND Parent_CAM__r.Action_Taken__c=false AND Parent_CAM__r.Deviations_Approved_By_Authorities__c=false AND Is_Forwarded_Flag__c = true WITH SECURITY_ENFORCED];//CISP-2532
                }else{
                    proposalLogList = [SELECT Id,Forwarding_Employee__c,Parent_CAM__c,Forwarded_By__c,Forwarded_Employee__c,Forwarded_Role__c FROM Proposal_Approval_Log__c WHERE Forwarding_Employee__c=:currentUserId AND RecordType.Name='Forward log' AND Parent_CAM__c IN:camIdVsCamMap.keySet() AND Parent_CAM__r.Action_Taken__c=false AND Parent_CAM__r.Deviations_Approved_By_Authorities__c=false AND Is_Forwarded_Flag__c = true AND Forwarded_Role__c=:pendingWith WITH SECURITY_ENFORCED];//CISP-2532
                }//End CISP-2864
                Map<Id,List<Proposal_Approval_Log__c>> camIdVsProposalList = new Map<Id,List<Proposal_Approval_Log__c>>();
                for (Proposal_Approval_Log__c proposalObj : proposalLogList) {
                    if(!camIdVsproposalList.containsKey(proposalObj.Parent_CAM__c)){
                        camIdVsproposalList.put(proposalObj.Parent_CAM__c,new List<Proposal_Approval_Log__c>());
                    }
                    camIdVsproposalList.get(proposalObj.Parent_CAM__c).add(proposalObj);
                }
               
                dataWrapperObj.IdVsProposalApprovalLog = camIdVsProposalList;
                
                return dataWrapperObj;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'fetchForwardedProposals', e.getTypeName(), e, '');
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch all the proposals which are hold by the current login user.
***********************************************/
    @AuraEnabled
    public static CamDataWrapper fetchHoldProposals(string approvedBy, String daysPending,string pendingWith){//CISP-2864
        try {
            String currentUserId = UserInfo.getUserId();
            List<Proposal_Approval_Log__c> proposalApprovalLogList = [SELECT Id, Parent_CAM__c FROM Proposal_Approval_Log__c WHERE Approval_Status__c = 'Hold' AND CreatedById =: currentUserId AND Parent_CAM__r.Is_Hold__c = true AND Parent_CAM__r.Action_Taken__c = false];
            if (!proposalApprovalLogList.isEmpty()) {
                Set<Id> camIdSet = new Set<Id>();
                for (Proposal_Approval_Log__c palRecord : proposalApprovalLogList) {
                    camIdSet.add(palRecord.Parent_CAM__c);
                }
                string daysPendingCondition;//Start CISP-2863
                if(daysPending!=null){
                    Integer days = Integer.valueOf(daysPending);
                    if (days == 3) {
                        daysPendingCondition =  ' AND (No_of_Days_Pending__c >=: days AND No_of_Days_Pending__c <= 7)';
                    } else if (days == 7) {
                        daysPendingCondition =  ' AND (No_of_Days_Pending__c >: days)';
                    }
                    else {
                        daysPendingCondition =  ' AND (No_of_Days_Pending__c=:days)';
                    }
                }
                else {
                    daysPendingCondition = '';
                }
                Map<Id,AccountTeamMember> accountIdVsTeamMember = new Map<Id,AccountTeamMember>();
                List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole,UserId,AccountId FROM AccountTeamMember WHERE UserId=:currentUserId];
                if(!accountTeamMemberList.isEmpty()){
                    for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                        if(!accountIdVsTeamMember.containsKey(accountTeamObj.AccountId)){
                            accountIdVsTeamMember.put(accountTeamObj.AccountId,accountTeamObj);
                        }
                    }
                }
                Set<Id> accountIdSet = accountIdVsTeamMember.keySet();
                string query = 'SELECT Loan_Application__c,Loan_Application__r.AccountId,Loan_Application__r.Application_number__c,Loan_Application__r.Account.BranchBLCode__c,Loan_Application__r.Applicant_Name__c,Loan_Application__r.Owner.Name,Committee__c,No_of_Days_Pending__c,Deviation_Created_Date__c,Loan_Application__r.Name,Loan_Application__r.Product_Type__c FROM CAM__c WHERE Id IN :camIdSet AND Loan_Application__r.AccountId IN :accountIdSet AND Loan_Application__r.StageName =\'Credit Processing\' AND Loan_Application__r.StageName != \'Journey Restart\' AND Trigger_Deviations__c = true AND Loan_Application__r.Is_Revoked__c != true AND Proposal_Status__c = null' + daysPendingCondition +' AND Id NOT IN (SELECT Parent_CAM__c FROM deviation__c WHERE Approval_Status__c = \'Rejected\' OR Proposal_Status__c = \'Rejected\') AND Id NOT IN (SELECT Parent_CAM__c FROM Proposal_Approval_Log__c WHERE Approval_Status__c IN (\'Rejected\',\'Reject\')) WITH SECURITY_ENFORCED';//CISP-2529 //End CISP-2863 //CISP-3002//CISP-3115
                List<CAM__c> records = new List<CAM__c>();
                records = Database.query(query); 
                Map<Id,CAM__c> camIdVsCamObj = 	new Map<Id,CAM__C>(records);
                Set<String> blCodeSet = new Set<String>();
                Map<Id,CAM__c> loanIdVsCamObjMap = new Map<Id,CAM__C>();
                for (CAM__c cam : records) {
                    if(!loanIdVsCamObjMap.containsKey(cam.Loan_Application__c)){
                        loanIdVsCamObjMap.put(cam.Loan_Application__c,cam);
                    }
                    if(cam.Loan_Application__r.AccountId!=null){
                        blCodeSet.add(cam.Loan_Application__r.Account.BranchBLCode__c);
                    }
                }
                
                if(camIdVsCamObj!=null && accountIdVsTeamMember!=null && String.isNotBlank(approvedBy)){
                    List<Deviation__c> deviationList = new List<Deviation__c>();
                    deviationList = [SELECT Id,Approval_Status__c,Proposal_Status__c,Parent_CAM__c,Role__c,Type__c FROM Deviation__c WHERE Parent_CAM__c IN:camIdVsCamObj.keySet()];//CISP-3115
                    Map<Id,List<Deviation__c>> camIdVsDeviationList = new Map<Id,List<Deviation__c>>();
                    for (Deviation__c deviationObj : deviationList) {
                        if(!camIdVsDeviationList.containsKey(deviationObj.Parent_CAM__c)){
                            camIdVsDeviationList.put(deviationObj.Parent_CAM__c,new List<Deviation__c>());
                        }
                        camIdVsDeviationList.get(deviationObj.Parent_CAM__c).add(deviationObj);
                    }
                    Map<String,String> camIdVsApprovalByStatus = new Map<String,String>();
                    Map<Id,List<Deviation__c>> camIdVsFinalDeviationList = new Map<Id,List<Deviation__c>>();                
                    for(Id camId:camIdVsDeviationList.keySet()){
                        if(camIdVsDeviationList.containsKey(camId) && !camIdVsDeviationList.get(camId).isEmpty()){//CISP-3115
                            Boolean checkIfApproved = false;
                            Boolean hasCurrentUser = true;
                            Boolean hasApprovedByUser = false;
                            Boolean pendingWithUser = false;//CISP-2864
                            if(camIdVsCamObj.containsKey(camId) && camIdVsCamObj.get(camId).Loan_Application__r.AccountId!=null){                            
                                String currentUserRole = accountIdVsTeamMember.containsKey(camIdVsCamObj.get(camId).Loan_Application__r.AccountId)?accountIdVsTeamMember.get(camIdVsCamObj.get(camId).Loan_Application__r.AccountId).TeamMemberRole:null;                            
                                for(Deviation__c deviationObj:camIdVsDeviationList.get(camId)){
                                    if(deviationObj.Role__c!=null && currentUserRole!=null && deviationObj.Role__c.contains(currentUserRole) && deviationObj.Proposal_Status__c=='Hold'){
                                        hasCurrentUser = true;
                                    }
                                    if(deviationObj.Role__c!=null && approvedBy!=null && deviationObj.Role__c.contains(approvedBy)){
                                        hasApprovedByUser = true;
                                        if(deviationObj.Approval_Status__c=='Approved'){
                                            checkIfApproved = true;
                                        }
                                        else {//CISP-2476
                                            checkIfApproved = false;
                                        }//CISP-2476
                                    }
                                    if(pendingWith!=null && deviationObj.Role__c!=null && deviationObj.Role__c==pendingWith && deviationObj.Approval_Status__c==null){//Start CISP-2864
                                        pendingWithUser = true;
                                    }
                                }
                                if(hasCurrentUser && hasApprovedByUser==false){
                                    if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                    camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                    camIdVsApprovalByStatus.put(camId, approvedBy+' Not Available');
                                    }
                                }
                                if(hasCurrentUser && hasApprovedByUser && currentUserRole!=null && approvedBy!=null && currentUserRole==approvedBy && checkIfApproved==false){
                                    if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                    camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                    camIdVsApprovalByStatus.put(camId, 'Not Approved');
                                    }
                                }
                                if(hasCurrentUser && hasApprovedByUser && checkIfApproved==true){
                                    if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                    camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                    camIdVsApprovalByStatus.put(camId, 'Approved');
                                    }
                                }
                                if(hasCurrentUser && hasApprovedByUser && checkIfApproved==false){
                                    if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                    camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                    camIdVsApprovalByStatus.put(camId, 'Not Approved');
                                    }
                                }
                            }
                        }
                    }//End CISP-2864

                    List<Applicant__c> applicantList = [SELECT Id, Name, Total_Insurance_Payable__c, Applicant_Type__c, Opportunity__c,Opportunity__r.Total_Funded_Premium__c FROM Applicant__c WHERE Opportunity__c IN: loanIdVsCamObjMap.keySet() AND In_Active_Applicant__c = false AND Applicant_Type__c = 'Borrower' WITH SECURITY_ENFORCED];
                    if(applicantList.size()>0){
                        Set<Id> oppIdSet = new Set<Id>();
                        for(Applicant__c  applicant : applicantList ) {
                            if (!oppIdSet.contains(applicant.Opportunity__c)) {
                                camIdVsCamObj.get(loanIdVsCamObjMap.get(applicant.Opportunity__c).Id).Loan_Application__r.Applicant_Name__c = applicant.Name;
                                oppIdSet.add(applicant.Opportunity__c);
                            }
                        }
                    }
                    
                    List<Exposure__c> expList = new List<Exposure__c>();
                    expList = [SELECT id,Loan_Application__c,Sanctioned_Amt__c,SOH__c,Type__c From Exposure__c WHERE Loan_Application__c IN :loanIdVsCamObjMap.keySet() WITH SECURITY_ENFORCED];
                    Map<Id, List<Exposure__c>> loanIdVsExpListMap = new Map<Id, List<Exposure__c>>();
                    if(expList.size()>0){
                        for (Exposure__c exp : expList) {
                            if (!loanIdVsExpListMap.containsKey(exp.Loan_Application__c)) {
                                loanIdVsExpListMap.put(exp.Loan_Application__c, new List<Exposure__c>{exp});
                            }
                            loanIdVsExpListMap.get(exp.Loan_Application__c).add(exp);
                        }
                    }

                    Map<Id,BankBranchDetails__c> loanApplicationVsBankBranch = new Map<Id,BankBranchDetails__c>();
                    List<BankBranchDetails__c> bankBranchList = [SELECT Id,Name,Bl_Code__c FROM BankBranchDetails__c WHERE Bl_Code__c IN: blCodeSet];
                    Map<String, BankBranchDetails__c> blCodeVsBankBranch = new Map<String, BankBranchDetails__c>();
                    if(bankBranchList.size()>0 && loanIdVsCamObjMap != null){
                        for (BankBranchDetails__c bankBranch : bankBranchList) {
                            if(bankBranch.Bl_Code__c!=null && !blCodeVsBankBranch.containsKey(bankBranch.Bl_Code__c)){
                                blCodeVsBankBranch.put(bankBranch.Bl_Code__c, bankBranch);
                            }
                        }
                    }
                    Map<Id,Decimal> loanIdVsfinalLoanAmount =  new Map<Id,Decimal>();
                    List<Final_Term__c> finalTermList =  [SELECT Id,Loan_Application__c,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c FROM Final_Term__c WHERE Loan_Application__c IN: loanIdVsCamObjMap.keySet() WITH SECURITY_ENFORCED];
                    if(finalTermList.size()>0){
                        for(Final_Term__c finalObj : finalTermList){
                            loanIdVsfinalLoanAmount.put(finalObj.Loan_Application__c ,finalObj.Loan_Amount__c == null ? 0: (Decimal.valueof(finalObj.Loan_Amount__c) + finalObj.Loan_Application__r.Total_Funded_Premium__c));  
                        }
                    }
                    Map<Id,Decimal> loanIdVsTotalExposure = new Map<id,Decimal>();
                    for(Id loanId :loanIdVsCamObjMap.keySet()){
                        if(blCodeVsBankBranch != null){
                            if(loanIdVsCamObjMap.get(loanId).Loan_Application__r.AccountId != null && loanIdVsCamObjMap.get(loanId).Loan_Application__r.Account.BranchBLCode__c != null && blCodeVsBankBranch.containsKey(loanIdVsCamObjMap.get(loanId).Loan_Application__r.Account.BranchBLCode__c)){
                                if(!loanApplicationVsBankBranch.containsKey(loanId)){
                                    loanApplicationVsBankBranch.put(loanId, blCodeVsBankBranch.get(loanIdVsCamObjMap.get(loanId).Loan_Application__r.Account.BranchBLCode__c));
                                }
                            }
                        }
                        Decimal totalExposureAmount = 0;
                        if(expList.size()>0 && loanIdVsExpListMap!=null && loanIdVsExpListMap.containsKey(loanId)){
                            for(Exposure__c expObj : loanIdVsExpListMap.get(loanId)){
                                if(expObj.Type__c == System.Label.Borrower_Exposure){ 
                                    totalExposureAmount += expObj.SOH__c !=null ? (Decimal)expObj.SOH__c : 0;
                                }
                                if(expObj.Type__c == System.Label.Co_Borrower_Exposure){
                                    totalExposureAmount += expObj.SOH__c !=null ? (Decimal)expObj.SOH__c : 0;
                                }
                                if(expObj.Type__c == System.Label.Additional_Customer){
                                    totalExposureAmount += expObj.SOH__c !=null ? (Decimal)expObj.SOH__c : 0;
                                }
                                if(expObj.Type__c == System.Label.Bank_Exposure){
                                    totalExposureAmount += expObj.Sanctioned_Amt__c != null? (Decimal)expObj.Sanctioned_Amt__c : 0;
                                }
                            }
                        }
                        loanIdVsTotalExposure.put(loanId, (loanIdVsfinalLoanAmount.get(loanId) + totalExposureAmount));                        
                    }
                    CamDataWrapper dataWrapperObj = new CamDataWrapper();
                    dataWrapperObj.loanIdVsVehicleDetail = getLoanIdVsVehicleDetail(loanIdVsCamObjMap.keySet());
                    dataWrapperObj.loanApplicationVsBankBranch = loanApplicationVsBankBranch;
                    dataWrapperObj.camIdVsApprovalByStatus = camIdVsApprovalByStatus;
                    dataWrapperObj.camIdVsDeviationListMap = camIdVsFinalDeviationList;
                    dataWrapperObj.camIdVsCamObjMap = camIdVsCamObj; 
                    dataWrapperObj.loanIdVsTotalExposure = loanIdVsTotalExposure;
                    return dataWrapperObj;
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'fetchHoldProposals', e.getTypeName(), e, '');
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This method is used to fetch all the proposals that are assigned to both user and selected approved by user but has not approved by the selected approved by user.
***********************************************/
    @AuraEnabled
    public static CamDataWrapper fetchNonApprovedProposals(Map<Id,CAM__c> camIdVsCamObj,Map<Id,AccountTeamMember> accountIdVsTeamMember,String approvedBy,string pendingWith){//CISP-2864
        try {
            if(camIdVsCamObj!=null && approvedBy!=null){
                List<Deviation__c> deviationList = new List<Deviation__c>();
                deviationList = [SELECT Id,Approval_Status__c,Proposal_Status__c,Parent_CAM__c,Role__c,Type__c FROM Deviation__c WHERE Parent_CAM__c IN:camIdVsCamObj.keySet() WITH SECURITY_ENFORCED];//CISP-3115
                Map<Id,List<Deviation__c>> camIdVsDeviationList = new Map<Id,List<Deviation__c>>();
                for (Deviation__c deviationObj : deviationList) {
                    if(!camIdVsDeviationList.containsKey(deviationObj.Parent_CAM__c)){
                        camIdVsDeviationList.put(deviationObj.Parent_CAM__c,new List<Deviation__c>());
                    }
                    camIdVsDeviationList.get(deviationObj.Parent_CAM__c).add(deviationObj);
                }
                Map<String,String> camIdVsApprovalByStatus = new Map<String,String>();
                Map<Id,List<Deviation__c>> camIdVsFinalDeviationList = new Map<Id,List<Deviation__c>>();                
                for(Id camId:camIdVsDeviationList.keySet()){
                    if(camIdVsDeviationList.containsKey(camId) && !camIdVsDeviationList.get(camId).isEmpty()){//CISP-3115
                        Boolean checkIfApproved = false;
                        Boolean hasCurrentUser = false;
                        Boolean hasApprovedByUser = false;
                        Boolean currentUserApprovedProposal = false;
                        Boolean pendingWithUser = false;//CISP-2864
                        if(camIdVsCamObj.containsKey(camId) && camIdVsCamObj.get(camId).Loan_Application__r.AccountId!=null  && camIdVsCamObj.get(camId).Trigger_Deviations__c==true){//CISP-2864
                            String currentUserRole = accountIdVsTeamMember.containsKey(camIdVsCamObj.get(camId).Loan_Application__r.AccountId)?accountIdVsTeamMember.get(camIdVsCamObj.get(camId).Loan_Application__r.AccountId).TeamMemberRole:null;
                            for(Deviation__c deviationObj:camIdVsDeviationList.get(camId)){
                                if(deviationObj.Role__c!=null && currentUserRole!=null && deviationObj.Role__c.contains(currentUserRole)){
                                    hasCurrentUser = true;
                                    if(deviationObj.Approval_Status__c == 'Approved'){
                                        currentUserApprovedProposal = true;
                                    }
                                    else {//CISP-2476
                                        currentUserApprovedProposal = false;
                                    }
                                }
                                if(deviationObj.Role__c!=null && approvedBy!=null && deviationObj.Role__c.contains(approvedBy)){
                                    hasApprovedByUser = true;
                                    if(deviationObj.Approval_Status__c=='Approved'){
                                        checkIfApproved = true;
                                    }
                                    else {//CISP-2476
                                        checkIfApproved = false;
                                    }//CISP-2476
                                }
                                if(pendingWith!=null && deviationObj.Role__c!=null && deviationObj.Role__c==pendingWith && deviationObj.Approval_Status__c==null){//Start CISP-2864
                                    pendingWithUser = true;
                                }
                            }
                            if(hasCurrentUser && hasApprovedByUser==false){
                                camIdVsApprovalByStatus.put(camId, approvedBy+' Not Available');
                            }
                            if(hasCurrentUser && hasApprovedByUser && currentUserRole!=null && approvedBy!=null && currentUserRole==approvedBy && checkIfApproved==false && currentUserApprovedProposal == false){
                                if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                camIdVsApprovalByStatus.put(camId, 'Not Approved');
                                }
                            }
                            
                            if(hasCurrentUser && hasApprovedByUser && checkIfApproved==false && currentUserApprovedProposal == false){
                                if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                camIdVsApprovalByStatus.put(camId, 'Not Approved');
                                }//End CISP-2864
                            }
                        }
                    }
                }
                CamDataWrapper dataWrapperObj = new CamDataWrapper();
                dataWrapperObj.camIdVsApprovalByStatus = camIdVsApprovalByStatus;
                dataWrapperObj.camIdVsDeviationListMap = camIdVsFinalDeviationList;
                
                return dataWrapperObj;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'fetchNonApprovedProposals', e.getTypeName(), e, '');
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getAccountRole(){
        try {
            Map<String, List<String>> roleMap = new Map<String, List<String>>();
            roleMap.put('ALL', new List<String>());
            IBL_Configuration__mdt config = IBL_Configuration__mdt.getInstance('default');
            List<String> allRoles = new List<String>();
            if (config.Roles_for_TW__c != null) {
                roleMap.put('Two Wheeler', new List<String>(config.Roles_for_TW__c.split(',')));
            }
            if (config.Roles_for_PV__c != null) {
                roleMap.put('Passenger Vehicles', new List<String>(config.Roles_for_PV__c.split(',')));
            }
            if (config.Roles_for_TF__c != null) {
                roleMap.put('Tractor', new List<String>(config.Roles_for_TF__c.split(',')));
            }
            if (roleMap.containsKey('Two Wheeler')) {
                roleMap.get('ALL').addAll(roleMap.get('Two Wheeler'));
            }
            if (roleMap.containsKey('Passenger Vehicles')) {
                roleMap.get('ALL').addAll(roleMap.get('Passenger Vehicles'));
            }
            if (roleMap.containsKey('Tractor')) {
                roleMap.get('ALL').addAll(roleMap.get('Tractor'));
            }
            return roleMap;           
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'getAccountRole', e.getTypeName(), e, '');
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.19 - CAM Summary Screen
* @Purpose: This wrapper is used to store all the data about cam and proposals to display and processes all the details on CAM summary screen.
***********************************************/
    public Class CamDataWrapper{
        @auraEnabled public Map<Id,CAM__c> loanIdVsCamObjMap;
        @auraEnabled public Map<Id,CAM__c> camIdVsCamObjMap;
        @auraEnabled public Map<Id,BankBranchDetails__c> loanApplicationVsBankBranch;
        @auraEnabled public Map<Id,List<Deviation__c>> camIdVsDeviationListMap;
        @auraEnabled public Map<Id,List<String>> camIdVsForwardedUserMap;
        @auraEnabled public Map<Id,AccountTeamMember> accountIdVsTeamMemberMap;
        @auraEnabled public Map<String,String> camIdVsApprovalByStatus;
        @auraEnabled public Map<Id,String> camIdVsIsHoldMap;
        @auraEnabled public Map<Id, Vehicle_Detail__c> loanIdVsVehicleDetail;
        @auraEnabled public Map<Id,Decimal> loanIdVsTotalExposure;
        @auraEnabled public List<CAM__c> filteredCamList;
        @auraEnabled public Map<Id,List<Proposal_Approval_Log__c>> IdVsProposalApprovalLog;
        @auraEnabled public List<Proposal_Approval_Log__c> forwardToYouProposalList;
        @auraEnabled public List<String> forwardedByProposalList;//CISP-2532
        @auraEnabled public String currentUserId;
        @auraEnabled public List<String> camIdSet;
    }
    
    private static Map<Id, Vehicle_Detail__c> getLoanIdVsVehicleDetail (Set<Id> loanIdSet) {
        Map<Id, Vehicle_Detail__c> loanIdVsVehicleDetail = new Map<Id, Vehicle_Detail__c>();
        List<Vehicle_Detail__c> vehicleList = [SELECT Make__c, Model__c, Variant__c, Loan_Application__c, Product_Segment__c FROM Vehicle_Detail__c WHERE Loan_Application__c IN: loanIdSet WITH SECURITY_ENFORCED];
        Map<String, String> variantVsCodeMap = new Map<String, String>();
        if(vehicleList != null){
            for(Vehicle_Detail__c vehicleObj : vehicleList){
                if (vehicleObj.Variant__c != null) {
                    variantVsCodeMap.put(vehicleObj.Variant__c, '');
                }
            }
            List<Product2> productList = [SELECT Id, Name, Variant_Code__c FROM Product2 WHERE Name IN :variantVsCodeMap.keySet() ];
            if (productList.size() > 0) {
                for (Product2 productRecord : productList) {
                    if (variantVsCodeMap.containsKey(productRecord.Name) && productRecord.Variant_Code__c != null) {
                        variantVsCodeMap.put(productRecord.Name, productRecord.Variant_Code__c);
                    }
                }
            }
            for(Vehicle_Detail__c vehicleObj : vehicleList){
                if(!loanIdVsVehicleDetail.containsKey(vehicleObj.Loan_Application__c)){
                    String variant = '';
                    if (variantVsCodeMap.containsKey(vehicleObj.Variant__c)) {
                        variant += variantVsCodeMap.get(vehicleObj.Variant__c) + ' ';
                    }
                    String makeModelVariant = vehicleObj.Make__c != null ? vehicleObj.Make__c + ' ' : '';
                    makeModelVariant += vehicleObj.Model__c != null ? vehicleObj.Model__c + ' ' : '';
                    makeModelVariant += vehicleObj.Variant__c != null ? vehicleObj.Variant__c + '' : '';
                    variant += makeModelVariant.trim() == '' ? '' : '( ' + makeModelVariant + ' )';
                    vehicleObj.Variant__c = variant;
                    loanIdVsVehicleDetail.put(vehicleObj.Loan_Application__c, vehicleObj);
                }
            }
        }
        return loanIdVsVehicleDetail;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProductType(){
        try {
            String currentUserId = UserInfo.getUserId();
            List<AccountTeamMember> accTeamList = [SELECT Account.Name FROM AccountTeamMember WHERE UserId=: currentUserId LIMIT 1];
            String currentUserProductTeam;
            if(accTeamList.size() > 0){
                if(accTeamList[0].Account.Name.contains('PV')){
                    currentUserProductTeam = 'Passenger Vehicles';
                }else if (accTeamList[0].Account.Name.contains('TW')) {
                    currentUserProductTeam = 'Two Wheeler';
                }else if (accTeamList[0].Account.Name.contains('TF')) {
                    currentUserProductTeam = 'Tractor';
                }
            }
            return currentUserProductTeam;           
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'getCurrentUserProductType', e.getTypeName(), e, '');
            return null;
        }
    }

    // SFTRAC-2023 Start
    @AuraEnabled
    public static void updateForwardedLogs(Id camId){
        if(camId != null){
            List<CAM__c> camLst = [SELECT Id,Loan_Application__c, Loan_Application__r.Product_Type__c FROM CAM__c WHERE Id =: camId WITH SECURITY_ENFORCED];
            if(camLst.size() > 0 && camLst[0].Loan_Application__r.Product_Type__c == 'Tractor'){
                String userId = UserInfo.getUserId();
                List<Proposal_Approval_Log__c> forwardedLogLst = [SELECT Id,Parent_CAM__c FROM Proposal_Approval_Log__c WHERE  Parent_CAM__c =: camId AND RecordType.DeveloperName = 'Forward_log' AND Forwarded_Employee__c =: userId AND Action__c = null WITH SECURITY_ENFORCED];
                for(Proposal_Approval_Log__c proposal : forwardedLogLst){
                    proposal.Action__c = 'Action Taken';
                }
                update forwardedLogLst;
            }
        }
    }
    @AuraEnabled
    public static List<forwardProposalWrapper> getForwardedProposals(){
        try{
            Set<String> camIdSet  = new Set<String>();
            List<forwardProposalWrapper> forwardproposalLst = new List<forwardProposalWrapper>();
            Set<Id> loanIdSet = new Set<Id>();
            Map<Id,Decimal> loanIdExposureMap = new Map<Id,Decimal>();
            String userId = UserInfo.getUserId();
            List<Proposal_Approval_Log__c> forwardedLogLst = [SELECT Id,Parent_CAM__c 
                                                                FROM Proposal_Approval_Log__c
                                                                WHERE  RecordType.DeveloperName = 'Forward_log' AND Forwarded_Employee__c =: userId AND Action__c = null AND Parent_CAM__r.Action_Taken__c = false AND Parent_CAM__r.Loan_Application__r.Is_Revoked__c = false AND Parent_CAM__r.Loan_Application__r.StageName != 'Withdrawn' AND Parent_CAM__r.Loan_Application__r.StageName != 'Journey Restart' AND Parent_CAM__r.Loan_Application__r.StageName != 'Journey Stop' AND Parent_CAM__r.Loan_Application__r.StageName != 'Rejected' 
                                                                WITH SECURITY_ENFORCED];
            
            for(Proposal_Approval_Log__c log: forwardedLogLst){
                camIdSet.add(log.Parent_CAM__c);
            }

            List<CAM__c> camLst = [SELECT Id,Loan_Application__r.AccountId,Loan_Application__r.Application_number__c,
                                    Loan_Application__r.Applicant_Name__c,Loan_Application__r.Owner.Name,Committee__c,
                                    No_of_Days_Pending__c,Loan_Application__r.Account.BranchBLCode__c,Trigger_Deviations__c,
                                    CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c,Deviation_Created_Date__c,
                                    Deviation_Created_Time__c,Deviation_Created_Date_Time__c,Loan_Application__r.Name, 
                                    Loan_Application__c, Loan_Application__r.Product_Type__c
                                    FROM CAM__c
                                    WHERE Id IN :camIdSet
                                    WITH SECURITY_ENFORCED];
            
            Map<Id,CAM__c> camIdVsCamObj = new Map<Id,CAM__c>(camLst);

            for(CAM__c cam: camLst){
                loanIdSet.add(cam.Loan_Application__c);
            }

            //TOTAL EXPOSURE LOGIC 
            for(Final_Term__c fin: [SELECT Id, Loan_Amount__c, Loan_Application__r.Total_Funded_Premium__c, Loan_Application__c FROM Final_Term__c WHERE Loan_Application__c IN :loanIdSet]){
                Decimal amt = fin.Loan_Amount__c == null ? 0 : (Decimal.valueof(fin.Loan_Amount__c) + fin.Loan_Application__r.Total_Funded_Premium__c);
                loanIdExposureMap.put(fin.Loan_Application__c,amt);
            }

            for(Exposure__c exp: [SELECT Id,SOH__c,Loan_Application__c FROM Exposure__c WHERE Loan_Application__c IN :loanIdSet ]){
                Decimal amt = loanIdExposureMap.get(exp.Loan_Application__c);
                amt+=exp.SOH__c;
                loanIdExposureMap.put(exp.Loan_Application__c,amt);
            }

            // APPROVAL LOGIC 
            String approvedBy = 'SCM';
            String pendingWith;

            Map<Id,AccountTeamMember> accountIdVsTeamMember = new Map<Id,AccountTeamMember>();
            List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole,UserId,AccountId FROM AccountTeamMember WHERE UserId=:userId];
            if(!accountTeamMemberList.isEmpty()){
                for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                    if(!accountIdVsTeamMember.containsKey(accountTeamObj.AccountId)){
                        accountIdVsTeamMember.put(accountTeamObj.AccountId,accountTeamObj);
                    }
                }
            }

            List<Deviation__c> deviationList = new List<Deviation__c>();
            deviationList = [SELECT Id,Approval_Status__c,Proposal_Status__c,Parent_CAM__c,Role__c,Number_of_Days_Pending__c,Type__c FROM Deviation__c WHERE Parent_CAM__c IN:camIdVsCamObj.keySet() WITH SECURITY_ENFORCED];
            Map<Id,List<Deviation__c>> camIdVsDeviationList = new Map<Id,List<Deviation__c>>();
            Map<Id,List<String>> camIdVsDeviationRoleList = new Map<Id,List<String>>();
            for (Deviation__c deviationObj : deviationList) {
                if(!camIdVsDeviationList.containsKey(deviationObj.Parent_CAM__c)){
                    camIdVsDeviationList.put(deviationObj.Parent_CAM__c,new List<Deviation__c>());
                }
                camIdVsDeviationList.get(deviationObj.Parent_CAM__c).add(deviationObj);
                if(deviationObj.Role__c != null){
                    if(!camIdVsDeviationRoleList.containsKey(deviationObj.Parent_CAM__c)){
                        camIdVsDeviationRoleList.put(deviationObj.Parent_CAM__c,new List<String>());
                    }
                    camIdVsDeviationRoleList.get(deviationObj.Parent_CAM__c).addAll(deviationObj.Role__c.split(','));
                }
            }

            Map<String,String> camIdVsApprovalByStatus = new Map<String,String>();
            Map<Id,String> camIdVsIsHold = new Map<Id,String>();
            Map<Id,Boolean> camIdVsCurrentUserAccept = new Map<Id,Boolean>();
            Map<Id,Boolean> camIdVsPendingWithUser = new Map<Id,Boolean>();
            Map<Id,List<Deviation__c>> camIdVsFinalDeviationList = new Map<Id,List<Deviation__c>>();
            for(Id camId:camIdVsDeviationList.keySet()){
                if(camIdVsDeviationList.containsKey(camId) && !camIdVsDeviationList.get(camId).isEmpty()){
                    Boolean checkIfApproved = false;
                    Boolean hasCurrentUser = false;
                    Boolean hasApprovedByUser = false;
                    Boolean checkIfHold = false;
                    Boolean pendingWithUser = false;
                    if(!camIdVsIsHold.containsKey(camId)){
                        camIdVsIsHold.put(camId, 'No');
                    }
                    if(camIdVsCamObj.containsKey(camId) && camIdVsCamObj.get(camId).Loan_Application__r.AccountId!=null && camIdVsCamObj.get(camId).Trigger_Deviations__c==true){
                        String currentUserRole = accountIdVsTeamMember.containsKey(camIdVsCamObj.get(camId).Loan_Application__r.AccountId)?accountIdVsTeamMember.get(camIdVsCamObj.get(camId).Loan_Application__r.AccountId).TeamMemberRole:null;
                        for(Deviation__c deviationObj:camIdVsDeviationList.get(camId)){
                            if(deviationObj.Role__c!=null && currentUserRole!=null && deviationObj.Role__c.contains(currentUserRole)){
                                if(deviationObj.Approval_Status__c==null){
                                    hasCurrentUser = true;
                                }
                                if(deviationObj.Approval_Status__c == 'Approved'){
                                    camIdVsCurrentUserAccept.put(camId, true);
                                }
                            }
                            if(deviationObj.Role__c!=null && approvedBy!=null && deviationObj.Role__c.contains(approvedBy)){
                                hasApprovedByUser = true;
                                if(deviationObj.Approval_Status__c=='Approved'){
                                    checkIfApproved = true;
                                }
                                else {
                                    checkIfApproved = false;
                                }
                            }
                            if(deviationObj.Proposal_Status__c=='Hold'){
                                camIdVsIsHold.put(camId,'Yes');
                            }
                            if(pendingWith!=null && deviationObj.Role__c!=null && deviationObj.Role__c==pendingWith && deviationObj.Approval_Status__c==null){
                                pendingWithUser = true;
                                camIdVsPendingWithUser.put(camId, true);
                            }
                        }
                        if(hasCurrentUser && hasApprovedByUser==false){
                            if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                                camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                                camIdVsApprovalByStatus.put(camId, approvedBy+' Not Available');
                            }
                        }
                        if(hasCurrentUser && hasApprovedByUser && currentUserRole!=null && approvedBy!=null && currentUserRole==approvedBy && checkIfApproved==false){
                            camIdVsApprovalByStatus.put(camId, 'Not Approved');
                        }
                        if(hasCurrentUser && hasApprovedByUser && checkIfApproved==false){
                            camIdVsApprovalByStatus.put(camId, 'Not Approved');
                        }
                        if(hasCurrentUser && hasApprovedByUser && checkIfApproved){
                            if(pendingWith==null || (pendingWith!=null && pendingWithUser)){
                            camIdVsFinalDeviationList.put(camId,camIdVsDeviationList.get(camId));
                            camIdVsApprovalByStatus.put(camId, 'Approved');
                            }
                        }
                    }
                }
            }

            //Variant Logic
            Map<Id, Vehicle_Detail__c> loanIdVsVehicleDetail = getLoanIdVsVehicleDetail(loanIdSet);

            // FINAL PROPOSAL WRAPPER
            for(CAM__c cam: camLst){
                forwardProposalWrapper proposal = new forwardProposalWrapper();
                proposal.appNo = cam.Loan_Application__r.Application_number__c;
                proposal.leadNo = cam.Loan_Application__r.Name;
                proposal.directForwarded = 'Forwarded';
                proposal.applicantName = cam.Loan_Application__r.Applicant_Name__c;
                proposal.daysPending = cam.No_of_Days_Pending__c;
                proposal.branchName = cam.Loan_Application__r.Account.BranchBLCode__c;
                proposal.executiveName = cam.Loan_Application__r.Owner.Name;
                proposal.exposure = String.valueOf(loanIdExposureMap.get(cam.Loan_Application__c));
                proposal.committee = cam.Committee__c;
                proposal.camIntimationDate = String.valueOf(cam.Deviation_Created_Date__c);
                proposal.camIntimationTime = cam.Deviation_Created_Time__c;
                proposal.approvedByApproval = camIdVsApprovalByStatus.get(cam.Id);
                proposal.noOfDaysPending = String.valueOf(cam.No_of_Days_Pending__c);
                proposal.holdByOthers = camIdVsIsHold.get(cam.Id);
                proposal.variant = loanIdVsVehicleDetail.get(cam.Loan_Application__c).Variant__c;
                proposal.isVisible = cam.Loan_Application__r.Product_Type__c == System.Label.Tractor ? true : false;
                proposal.url = '/apex/IBLCAMPage' + '?id='+cam.Id;
                forwardproposalLst.add(proposal);
            }

            return forwardproposalLst;
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ProposalStatusClass', 'getForwardedProposals', e.getTypeName(), e, '');
        }
        return null;
    }

    public class forwardProposalWrapper{
        @AuraEnabled public String appNo { get; set; }
        @AuraEnabled public String leadNo { get; set; }
        @AuraEnabled public String directForwarded { get; set; }
        @AuraEnabled public String applicantName { get; set; }
        @AuraEnabled public Decimal daysPending { get; set; }
        @AuraEnabled public String branchName { get; set; }
        @AuraEnabled public String executiveName { get; set; }
        @AuraEnabled public String exposure { get; set; }
        @AuraEnabled public String committee { get; set; }
        @AuraEnabled public String camIntimationDate { get; set; }
        @AuraEnabled public String camIntimationTime { get; set; }
        @AuraEnabled public String approvedByApproval { get; set; }
        @AuraEnabled public String noOfDaysPending { get; set; }
        @AuraEnabled public String holdByOthers { get; set; }
        @AuraEnabled public String variant { get; set; }
        @AuraEnabled public Boolean isVisible { get; set; }
        @AuraEnabled public String url { get; set; }

        public forwardProposalWrapper() {
            this.appNo = '';
            this.leadNo = '';
            this.directForwarded = '';
            this.applicantName = '';
            this.daysPending = 0;
            this.branchName = '';
            this.executiveName = '';
            this.exposure = '';
            this.committee = '';
            this.camIntimationDate = '';
            this.camIntimationTime = '';
            this.approvedByApproval = '';
            this.noOfDaysPending = '';
            this.holdByOthers = '';
            this.variant = '';
            this.isVisible = false;
        }
    }
    // SFTRAC-2023 End
    
}