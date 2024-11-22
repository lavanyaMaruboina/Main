/**
* @Name         IND_CAMWithoutSharing
* @Author       Rajat Jaiswal
* @Description  This Class is used to for WITHOUT SHARING
**/
public without sharing class IND_CAMWithoutSharing {
    @AuraEnabled
    public static List<RequestWrapper> forwardCAMWithAPI(String camId, String role){
        List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
        try {
            if(camID!=null && role!=null){
                CAM__c cam=[SELECT Id,Loan_Application__c,Loan_Application__r.Name, Loan_Application__r.AccountId FROM CAM__c WHERE id=:camId ];
                Id accountId = cam.Loan_Application__r.AccountId;
                List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,User.Profile.UserLicense.Name FROM AccountTeamMember WHERE Account.id= :accountId AND TeamMemberRole=:role AND user.IsActive=TRUE]; //CISP-4176
                List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='ForwordToEMail1'];
                List<Deviation__c> deviationList = [SELECT Id,Deviation_Level__c,Role__c FROM Deviation__c WHERE Parent_CAM__c=:camId AND Deviation_Level__c != null AND (NOT Deviation_Level__c LIKE 'L%')];
                String deviationLevel = '';
                if (deviationList.size() > 0) {
                    deviationLevel = deviationList[0].Deviation_Level__c;
                }
                List<Applicant__c> applicant = [SELECT Id, Name FROM Applicant__c WHERE Opportunity__c = :cam.Loan_Application__c AND Applicant_Type__c = 'Borrower'];
                String applicantName = applicant.size() > 0 ? applicant[0].Name : '';
                if(roleList.size() > 0) {
                    for (AccountTeamMember roleMember : roleList){
                        RequestWrapper emailRequestWrapper = new RequestWrapper();
                        if (roleMember.TeamMemberRole != null) {
                            emailRequestWrapper.employmentType = roleMember.TeamMemberRole;
                            emailRequestWrapper.name = roleMember.user.Name;
                        }
                        Boolean communityCheck = roleMember.User.Profile?.UserLicense.Name == 'Partner Community';
                        emailRequestWrapper.leadId = cam.Loan_Application__c;
                        emailRequestWrapper.loanApplicationId = cam.Loan_Application__c;
                        emailRequestWrapper.emailTo = roleMember.User.Email;
                        emailRequestWrapper.emailCC =  roleMember.User.Email;
                        String emailTemplateSubject = etList[0].Subject.replace('{!Opportunity.Name}', cam.Loan_Application__r.Name);
                        emailTemplateSubject = emailTemplateSubject.replace('{!Deviation__c.Deviation_Level__c}', deviationLevel);
                        emailTemplateSubject = emailTemplateSubject.replace('{!User.Name}', applicantName);
                        emailRequestWrapper.emailSubject = emailTemplateSubject;
                        String emailBody = etList[0].HtmlValue.replace('{!Receiving_User.Name}',roleMember.User.Name);
                        emailBody = emailBody.replace('{!Opportunity.Name}',  cam.Loan_Application__r.Name);
                        emailBody = emailBody.replace('{!Deviation__c.Deviation_Level__c}', deviationLevel);
                        emailBody = emailBody.replace('{!User.Name}',applicantName);
                        emailBody = emailBody.replace('{!CAM__c.Id}',camId);
                        if (communityCheck) {
                            emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Community_Partners_URL);
                        } else {
                            emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Lightning_Base_URL);
                        }
                        emailRequestWrapper.emailBody = emailBody;
                        emailRequestWrapperList.add(emailRequestWrapper);
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_CAMWithoutSharing', 'forwardCAMWithAPI', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return emailRequestWrapperList;
    }
    
    @AuraEnabled
    public static List<RequestWrapper> triggerDeviationMail(String camId, String caRemark,String calledfrom){
        List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
        try {
            if(camId!=null){
                 checkDeviationLevelSkip(camId);//CISP-13443
                List<CAM__c> camList = new List<CAM__c>();
                camList = [SELECT Id,Loan_Application__r.AccountId,Loan_Application__r.Product_Type__c from CAM__c WHERE id =: camId];
                List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
                if(camList.size() > 0 && camList[0].Loan_Application__r.Product_Type__c == Label.Tractor){
                    String camApprovalRoleLabel = System.Label.camApprovalRoleLabel; 
                    List<String> camApprovalRoleLabelList = camApprovalRoleLabel.split(',');
                    accTeamList = [SELECT ID ,TeamMemberRole FROM AccountTeamMember WHERE Account.id= :camList[0].Loan_Application__r.AccountId AND TeamMemberRole IN: camApprovalRoleLabelList AND User.isActive = true];

                    Map<String,AccountTeamMember> atmRoleMap = new Map<String,AccountTeamMember>();
                    for (AccountTeamMember atm : accTeamList) {
                        if(atm.TeamMemberRole != null && !atmRoleMap.containsKey(atm.TeamMemberRole)){
                            atmRoleMap.put(atm.TeamMemberRole,atm);
                        }
                    }
                    accTeamList = new List<AccountTeamMember>();
                    if(atmRoleMap.containsKey('ACM')){
                        accTeamList.add(atmRoleMap.get('ACM'));
                    }else if(atmRoleMap.containsKey('SCM')){
                        accTeamList.add(atmRoleMap.get('SCM'));
                    }else if(atmRoleMap.containsKey('ZCM')){
                        accTeamList.add(atmRoleMap.get('ZCM'));
                    }else if(atmRoleMap.containsKey('NCM')){
                        accTeamList.add(atmRoleMap.get('NCM'));
                    }
                }
                List<Deviation__c> deviationList = [SELECT Id,Name,DeviationID__c,Deviation_Level__c,Role__c,Type__c,Parent_CAM__c,Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Trigger_Deviations__c,Parent_CAM__r.Loan_Application__r.Name , EmployeeID__c,Deviation_Description__c,Parent_CAM__r.Loan_Application__r.Product_Type__c,Parent_CAM__r.Loan_Application__r.Vehicle_Type__c FROM Deviation__c WHERE Parent_CAM__c=:camId];//Start CISP-2617
                if (deviationList.size()>0) { //Start CISP-2596
                    if(deviationList[0].Parent_CAM__r.Loan_Application__r.Product_Type__c == Label.Tractor){
                        List<Deviation__c> tempDeviationList = new List<Deviation__c>();
                        for (Deviation__c deviation : deviationList) {
                            if(calledfrom == 'camScreen'){
                                if(String.isNotEmpty(deviation.Role__c) && accTeamList[0].TeamMemberRole.contains(deviation.Role__c)){
                                    tempDeviationList.add(deviation);
                                }
                            }else if(calledfrom == 'assetApprovalCmp'){
                                if(String.isNotEmpty(deviation.Role__c) && !accTeamList[0].TeamMemberRole.contains(deviation.Role__c)){
                                    tempDeviationList.add(deviation);
                                }
                            }
                        }
                        deviationList = tempDeviationList;
                        if(deviationList.size() == 0){
                            return emailRequestWrapperList;
                        }
                    }
                    List<CommitteeRoleLevel__mdt> committeeRoleList = [SELECT id,Business_Credit__c, Product__c,MasterLabel,Label from CommitteeRoleLevel__mdt WHERE  Product__c =: deviationList[0].Parent_CAM__r.Loan_Application__r.Product_Type__c];	
                    Set<String> assignedRoleSet = new Set<String>();
                    Set<String> deviationRoleSet = new Set<String>();//CISP-13443
                    Set<String> teamNameSet = new Set<String>();
                    String businessCredit = 'Both';
                    String levelOfUnassignedDeviation;

                    
                    if (deviationList.size()==1 && deviationList[0].EmployeeID__c==null) {
                        String vehicleType = deviationList[0].Parent_CAM__r.Loan_Application__r.Vehicle_Type__c;
                        if (deviationList[0].Parent_CAM__r.Loan_Application__r.Vehicle_Type__c =='Used' || deviationList[0].Parent_CAM__r.Loan_Application__r.Vehicle_Type__c =='Refinance') {
                            vehicleType = 'Used';
                        }
                        for(Deviation__c deviationObj : deviationList){
                            if (deviationObj.Type__c == 'Committee Deviation') {
                                for(CommitteeRoleLevel__mdt committeeObj : committeeRoleList){
                                    assignedRoleSet.add(committeeObj.Label);
                                    if (deviationObj.Role__c != null && deviationObj.Deviation_Level__c!=null && deviationObj.Type__c == 'Committee Deviation' && deviationObj.Role__c.contains(committeeObj.Label)) {
                                        businessCredit += ',' + committeeObj.Business_Credit__c;                                
                                    }
                                }
                                List<CommitteeRoleHierarchy__mdt> committeeRoleHierarchyMdtList = new List<CommitteeRoleHierarchy__mdt>();
                                if(deviationList[0].Parent_CAM__r.Loan_Application__r.Product_Type__c == System.Label.Tractor){
                                    committeeRoleHierarchyMdtList = [SELECT Id,Product__c,New_Used__c,Approval_level__c FROM CommitteeRoleHierarchy__mdt WHERE Product__c=:deviationList[0].Parent_CAM__r.Loan_Application__r.Product_Type__c AND label =: deviationList[0].Role__c];
                                }else{
                                    committeeRoleHierarchyMdtList = [SELECT Id,Product__c,New_Used__c,Approval_level__c FROM CommitteeRoleHierarchy__mdt WHERE Product__c=:deviationList[0].Parent_CAM__r.Loan_Application__r.Product_Type__c AND New_Used__c=:vehicleType AND label =: deviationList[0].Role__c];
                                }
                                if (committeeRoleHierarchyMdtList.size()>0) {
                                    levelOfUnassignedDeviation = committeeRoleHierarchyMdtList[0].Approval_level__c;
                                }
                            }else {
                                levelOfUnassignedDeviation = deviationObj.Deviation_Level__c;
                            }
                        }
                        for(Deviation__c deviationObj : deviationList){
                            for(CommitteeRoleLevel__mdt committeeObj : committeeRoleList){
                                if (businessCredit.contains(committeeObj.Business_Credit__c)) {
                                    teamNameSet.add(committeeObj.Label);
                                }
                            }
                        }
                        System.debug(businessCredit+teamNameSet);
                    }//End CISP-2617
                    Map<String,List<String>> deviationLevelVsDeviationListMap = new Map<String,List<String>>();
                    Id accountId = deviationList[0].Parent_CAM__r.Loan_Application__r.AccountId;
                    Deviation__c deviationRecord = deviationList[0];
                    String deviationLevel = '';
                    String deviationDescription = '';
                    for(Deviation__c deviationObj : deviationList){
                        if(deviationObj.Role__c != null){
                            List<String> roleList = deviationObj.Role__c.split(',');
                            assignedRoleSet.addAll(roleList);//CISP-2617
                            deviationRoleSet.addAll(roleList);//CISP-13443
                        }
                        if (deviationObj.Deviation_Level__c != null) {
                            List<String> devLevelList = deviationObj.Deviation_Level__c.split(',');
                            for (String devLevel : devLevelList) {
                                if (deviationObj.Role__c != null) {
                                    List<String> roleList = deviationObj.Role__c.split(',');
                                    if(!deviationLevelVsDeviationListMap.containsKey(devLevel)){
                                        deviationLevelVsDeviationListMap.put(devLevel,roleList);
                                    }else{
                                        deviationLevelVsDeviationListMap.get(devLevel).addAll(roleList);
                                    }
                                }
                            }
                        }
                        if(deviationObj.Deviation_Level__c != null && !deviationObj.Deviation_Level__c.startsWith('L')){
                            deviationLevel = deviationObj.Deviation_Level__c;
                            deviationDescription = deviationObj.Deviation_Description__c;
                        }
                    }
                    //if(assignedRoleSet.size() > 0){//CISP-2617
                        List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,User.Profile.UserLicense.Name FROM AccountTeamMember WHERE Account.id= :accountId AND user.IsActive=TRUE];//CISP-2617 & CISP-4176
                        List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='Deviation_EMail1'];
                        if (roleList.size() > 0 && etList.size()>0) {
                            Map<String,List<AccountTeamMember>> levelVsAccountTeamMemberListMap = new Map<String,List<AccountTeamMember>>();
                            for(AccountTeamMember acc: roleList){
                                if(acc.Level__c != null){
                                    List<String> levelList = acc.Level__c.split(';');
                                    for(String level:levelList){
                                        if(!levelVsAccountTeamMemberListMap.containsKey(level)){
                                            levelVsAccountTeamMemberListMap.put(level,new List<AccountTeamMember>{acc});
                                        }else{
                                            levelVsAccountTeamMemberListMap.get(level).add(acc);
                                        }
                                    }
                                }
                            }
                            for(Deviation__c deviationObj : deviationList){
                                for(AccountTeamMember acc: roleList){
                                    if (deviationObj.Role__c != null && deviationObj.Deviation_Level__c!=null && acc.TeamMemberRole != null && deviationObj.Type__c == 'Committee Deviation' && deviationObj.Role__c.contains(acc.TeamMemberRole)) {
                                        if(!levelVsAccountTeamMemberListMap.containsKey(deviationObj.Deviation_Level__c)){
                                            levelVsAccountTeamMemberListMap.put(deviationObj.Deviation_Level__c,new List<AccountTeamMember>{acc});
                                        }else{
                                            levelVsAccountTeamMemberListMap.get(deviationObj.Deviation_Level__c).add(acc);
                                        }
                                    }
                                }
                            }
                            if (deviationList.size() == 1 && deviationList[0].EmployeeID__c==null) {//Start CISP-2617
                                string nextLevel;
                                for (Deviation__c deviationObj: deviationList) {
                                    for (AccountTeamMember acc: roleList) {
                                        if (acc.Level__c!=null) {
                                        List<String> levelList = acc.Level__c.split(';');
                                        for (String level : levelList) {
                                        if (deviationObj.Role__c != null && deviationObj.Deviation_Level__c != null && deviationObj.Type__c == 'Committee Deviation') {
                                            // if (levelVsAccountTeamMemberListMap.get(deviationObj.Deviation_Level__c) == null) {
                                                if (teamNameSet.contains(acc.TeamMemberRole) && levelOfUnassignedDeviation!=null) {
                                                    System.debug(acc.Level__c+' === '+levelOfUnassignedDeviation+' === '+nextLevel +' == '+Decimal.valueOf(level.substringAfter('L')) +' === '+ Decimal.valueOf(levelOfUnassignedDeviation.substringAfter('L')));
                                                        if(level!=null && Decimal.valueOf(level.substringAfter('L')) >= Decimal.valueOf(levelOfUnassignedDeviation.substringAfter('L'))){
                                                            if(nextLevel==null){
                                                                nextLevel = level;
                                                            }else if(Decimal.valueOf(level.substringAfter('L'))<Decimal.valueOf(nextLevel.substringAfter('L'))){
                                                                nextLevel = level;
                                                            }
                                                        }
                                                }
                                            // }
                                        }else if(deviationObj.Deviation_Level__c != null && deviationObj.Type__c == 'Normal Deviation'){
                                            if(level!=null && Decimal.valueOf(level.substringAfter('L')) >= Decimal.valueOf(levelOfUnassignedDeviation.substringAfter('L'))){
                                                if(nextLevel==null){
                                                    nextLevel = level;
                                                }else if(Decimal.valueOf(level.substringAfter('L'))<Decimal.valueOf(nextLevel.substringAfter('L'))){
                                                    nextLevel = level;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                                for (AccountTeamMember acc: roleList) {
                                    if (acc.Level__c!=null) {
                                        List<String> levelList = acc.Level__c.split(';');
                                        for (String level : levelList) {
                                    if(level != null && nextLevel!=null && level == nextLevel){
                                        Deviation__c deviationObj = deviationList[0];
                                        if (!levelVsAccountTeamMemberListMap.containsKey(deviationObj.Deviation_Level__c)) {
                                            levelVsAccountTeamMemberListMap.put(deviationObj.Deviation_Level__c, new List < AccountTeamMember > {acc});
                                            if (!deviationLevelVsDeviationListMap.containsKey(deviationObj.Deviation_Level__c)) {
                                                deviationLevelVsDeviationListMap.put(deviationObj.Deviation_Level__c, new List<String>());
                                            }
                                            deviationLevelVsDeviationListMap.get(deviationObj.Deviation_Level__c).add(acc.TeamMemberRole);
                                        } else {
                                            levelVsAccountTeamMemberListMap.get(deviationObj.Deviation_Level__c).add(acc);
                                            if (!deviationLevelVsDeviationListMap.containsKey(deviationObj.Deviation_Level__c)) {
                                                deviationLevelVsDeviationListMap.put(deviationObj.Deviation_Level__c, new List<String>());
                                            }
                                            deviationLevelVsDeviationListMap.get(deviationObj.Deviation_Level__c).add(acc.TeamMemberRole);
                                        }
                                        break;
                                        System.debug('nextLevel'+nextLevel+levelOfUnassignedDeviation);
                                    }
                                }
                            }
                        }
                            }// End CISP-2617

                            //CISP-13443 - START                            
                            System.debug('deviationLevelVsDeviationListMap'+deviationLevelVsDeviationListMap);
                            for (string levelVar : deviationLevelVsDeviationListMap.keySet()){
                                if (levelVsAccountTeamMemberListMap.containsKey(levelVar)) {
                                    for (AccountTeamMember roleMember : levelVsAccountTeamMemberListMap.get(levelVar)) {
                                        if (deviationLevelVsDeviationListMap.get(levelVar).contains(roleMember.TeamMemberRole)) {
                                            RequestWrapper emailRequestWrapper = new RequestWrapper();
                                            emailRequestWrapper.leadId = deviationRecord.Parent_CAM__r.Loan_Application__c;
                                            emailRequestWrapper.loanApplicationId = deviationRecord.Parent_CAM__r.Loan_Application__c;
                                            emailRequestWrapper.emailTo = roleMember.User.Email;
                                            emailRequestWrapper.emailCC =  roleMember.User.Email;
                                            emailRequestWrapper.employmentType = roleMember.TeamMemberRole != null ? roleMember.TeamMemberRole : null;
                                            String emailTemplateSubject = etList[0].Subject.replace('{!Opportunity.Name}', deviationRecord.Parent_CAM__r.Loan_Application__r.Name);
                                            emailTemplateSubject = emailTemplateSubject.replace('{!Deviation__c.Deviation_Level__c}', deviationLevel);
                                            emailTemplateSubject = emailTemplateSubject.replace('{!User.Name}', roleMember.User.Name !=null ? roleMember.User.Name : '');
                                            emailRequestWrapper.emailSubject = emailTemplateSubject;
                                            String emailBody = etList[0].HtmlValue.replace('{!Receiving_User.Name}',roleMember.User.Name);
                                            emailBody = emailBody.replace('{!Opportunity.Name}',  deviationRecord.Parent_CAM__r.Loan_Application__r.Name);
                                            emailBody = emailBody.replace('{!Deviation__c.Deviation_Level__c}',deviationLevel);
                                            emailBody = emailBody.replace('{!Deviation__c.Deviation_Description__c}',deviationDescription);
                                            emailBody = emailBody.replace('{!CAM__c.Id}',deviationRecord.Parent_CAM__c);
                                            if (roleMember.User.Profile?.UserLicense.Name == 'Partner Community') {
                                                emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Community_Partners_URL);
                                            } else {
                                                emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Lightning_Base_URL);
                                            }
                                            emailRequestWrapper.emailBody = emailBody;
                                            emailRequestWrapperList.add(emailRequestWrapper);
                                        }
                                    }
                                }
                            }
                            if (emailRequestWrapperList.size()>0) {
                                CAM__c camObj = new CAM__c(Id = camId,Trigger_Deviations__c = true);
                                if(calledfrom == 'assetApprovalCmp'){
                                    camObj.CAM_Submitted_by_ACM_SCM__c = true;
                                }
                                camObj.Deviation_Created_Date__c = Date.today();
                                String devtime = System.now().format('HH:mm:ss');//CISP-7949
                                camObj.Deviation_Created_Time__c = devtime;//CISP-7949
                                camObj.Deviation_Created_Date_Time__c = System.now();//CISP-7949
                                if(caRemark != null){
                                    camObj.Credit_Analyst_Remarks__c = caRemark;
                                }
                                update camObj;
                            }
                        }
                    }
                //}//End CISP-2596
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_CAMWithoutSharing', 'triggerDeviationMail', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
        }
        return emailRequestWrapperList;
    }
    
    @AuraEnabled
    public static Boolean createProposalLog(String camId, String role, String remarks, String emailTo){
        try {
            CAM__c cam = [SELECT Id,Loan_Application__c, Loan_Application__r.AccountId, Loan_Application__r.Name,Loan_Application__r.Product_Type__c FROM CAM__c WHERE id=:camId];
            Id accountId = cam.Loan_Application__r.AccountId;
            List<AccountTeamMember> roleList = new List<AccountTeamMember>();
            if (!String.isBlank(emailTo)) {
                roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive FROM AccountTeamMember WHERE AccountId= :accountId AND TeamMemberRole=:role AND User.Email =: emailTo AND user.IsActive=TRUE]; //CISP-4176
            }else{
                roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive FROM AccountTeamMember WHERE AccountId= :accountId AND TeamMemberRole=:role AND user.IsActive=TRUE]; //CISP-4176
            }
            List<AccountTeamMember> currentUserRoleList = [SELECT TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accountId AND UserId = :UserInfo.getUserId() LIMIT 1]; 
            User runningUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            List<Proposal_Approval_Log__c> existingProposalLogList = new List<Proposal_Approval_Log__c>();//CISP-2532
            if (roleList.size() > 0 && roleList[0].UserId!=null) {
                existingProposalLogList = [SELECT Id,Is_Forwarded_Flag__c FROM Proposal_Approval_Log__c WHERE Forwarded_Employee__c =: runningUser.Id AND Forwarding_Employee__c =:roleList[0].UserId LIMIT 10000];//CISP-2532
            }
			String str = 'Success';
            Id recType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Forward log').getRecordTypeId();
            List<Proposal_Approval_Log__c> proposalLogToInsert = new List<Proposal_Approval_Log__c>();
            if(str=='Success'){
                for(AccountTeamMember roleMember : roleList){
                    Proposal_Approval_Log__c logRec = new Proposal_Approval_Log__c();
                    logRec.Name = String.valueOf(Math.floor(Math.random() * 10000).intValue()); // CISP-16665
                    logRec.Proposal_description__c = 'Forward Approval Log - ' + cam.Loan_Application__r.Name;  // CISP-16665
                    logRec.Parent_CAM__c = camId;
                    logRec.Date_and_Time__c = System.now();
                    logRec.RecordTypeId = recType;
                    logRec.Forwarded_On__c=System.now();
                    logRec.Forwarded_By__c = runningUser.Name;
                    logRec.Forwarded_Role__c = role;
                    logRec.Forwarding_Employee__c =runningUser.Id;
                    logRec.Forwarded_Employee__c =roleMember.UserId;
                    if(String.isNotBlank(remarks)){
                        logRec.Proposal_Remark__c=remarks;  //CISP-2332
                    }
                    if(currentUserRoleList.size() > 0){
                        logRec.Forwarding_Role__c = currentUserRoleList[0].TeamMemberRole;
                    }
                    logRec.Is_Forwarded_Flag__c = true;//Start CISP-2532

                    // if(existingProposalLogList.size()==0){
                    //     logRec.Is_Forwarded_Flag__c = true;
                    // }
                    proposalLogToInsert.add(logRec);
                }
                if(existingProposalLogList.size()>0){
                    for (Proposal_Approval_Log__c existingLog : existingProposalLogList) {
                        existingLog.Is_Forwarded_Flag__c = false;
                    }
                    update existingProposalLogList;
                }//End CISP-2532
                if(proposalLogToInsert.size()>0){
                    insert proposalLogToInsert;
                    return true;
                } else{
                    return false;
                }
            }
            return false;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_CAMWithoutSharing', 'createProposalLog', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        } 
    }
    
    @AuraEnabled
    public static List<RequestWrapper> getForwardWrapper(String camId){
        List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
        try {
            if(camID!=null){
                CAM__c cam=[SELECT Id,Loan_Application__c,Loan_Application__r.Name, Loan_Application__r.AccountId FROM CAM__c WHERE id=:camId ];
                Id accountId = cam.Loan_Application__r.AccountId;
                List<Deviation__c> deviationList = [SELECT Deviation_Level__c FROM Deviation__c WHERE Parent_CAM__c=:camId AND Deviation_Level__c !=null AND (NOT Deviation_Level__c LIKE 'L%')];
                String deviationLevel = '';
                if (deviationList.size() > 0) {
                    deviationLevel = deviationList[0].Deviation_Level__c;
                }
                List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,User.Profile.UserLicense.Name FROM AccountTeamMember WHERE Account.id= :accountId AND user.IsActive=TRUE]; //CISP-4176
                List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='ForwordToEMail1'];
                List<Applicant__c> applicant = [SELECT Id, Name FROM Applicant__c WHERE Opportunity__c = :cam.Loan_Application__c AND Applicant_Type__c = 'Borrower'];
                String applicantName = applicant.size() > 0 ? applicant[0].Name : '';
                if(roleList.size() > 0) {
                    for (AccountTeamMember roleMember : roleList){
                        RequestWrapper emailRequestWrapper = new RequestWrapper();
                        if (roleMember.TeamMemberRole != null) {
                            emailRequestWrapper.employmentType = roleMember.TeamMemberRole;
                            emailRequestWrapper.name = roleMember.user.Name;
                            emailRequestWrapper.leadId = cam.Loan_Application__c;
                            emailRequestWrapper.loanApplicationId = cam.Loan_Application__c;
                            emailRequestWrapper.emailTo = roleMember.User.Email;
                            emailRequestWrapper.emailCC =  roleMember.User.Email;
                            String emailTemplateSubject = etList[0].Subject.replace('{!Opportunity.Name}', cam.Loan_Application__r.Name);
                            emailTemplateSubject = emailTemplateSubject.replace('{!Deviation__c.Deviation_Level__c}', deviationLevel);
                            emailTemplateSubject = emailTemplateSubject.replace('{!User.Name}', applicantName);
                            emailRequestWrapper.emailSubject = emailTemplateSubject;
                            String emailBody = etList[0].HtmlValue.replace('{!Receiving_User.Name}',roleMember.User.Name);
                            emailBody = emailBody.replace('{!Opportunity.Name}',  cam.Loan_Application__r.Name);
                            emailBody = emailBody.replace('{!Deviation__c.Deviation_Level__c}', deviationLevel);
                            emailBody = emailBody.replace('{!User.Name}',applicantName);
                            emailBody = emailBody.replace('{!CAM__c.Id}',camId);
                            if (roleMember.User.Profile?.UserLicense.Name == 'Partner Community') {
                                emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Community_Partners_URL);
                            } else {
                                emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Lightning_Base_URL);
                            }
                            emailRequestWrapper.emailBody = emailBody;
                            emailRequestWrapperList.add(emailRequestWrapper);
                        }
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_CAMWithoutSharing', 'getForwardWrapper', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
        }
        return emailRequestWrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static List<deviationMasterWrapper> getdeviMasterRecords() { 
        List<deviationMasterWrapper> deviationMasterWrapperLst = new List<deviationMasterWrapper>();
        try{
            List<Deviation_Master__c> devMasterRecords = [SELECT Id, Name, Active__c, Deviation_Level__c, Parameter__c,
                                                          Source__c  FROM Deviation_Master__c where Active__c = true];
            
            for(Deviation_Master__c dMRec: devMasterRecords){
                deviationMasterWrapper deviationMasterWrapperRec = new deviationMasterWrapper();
                //deviationMasterWrapperRec.isActive = dMRec.Active__c;
                deviationMasterWrapperRec.Deviation_Id = dMRec.Name;
                deviationMasterWrapperRec.Source = dMRec.Source__c;
                deviationMasterWrapperRec.Parameter = dMRec.Parameter__c;
                deviationMasterWrapperRec.Deviation_Level = dMRec.Deviation_Level__c;
                
                deviationMasterWrapperLst.add(deviationMasterWrapperRec);
            }
            return deviationMasterWrapperLst;            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<mitigantsMasterWrapper> getmitigantsMasterRecords() {
        List<mitigantsMasterWrapper> mitigantsMasterWrapperLst = new List<mitigantsMasterWrapper>();
        try{
            List<Mitigant_Master__c> mitiMasterRecords = [SELECT Id, Name, Active__c, Description__c
                                                          FROM Mitigant_Master__c where Active__c = true];
            
            for(Mitigant_Master__c mMRec: mitiMasterRecords){
                mitigantsMasterWrapper mitigantsMasterWrapperRec = new mitigantsMasterWrapper();
                //mitigantsMasterWrapperRec.isActive = mMRec.Active__c;
                mitigantsMasterWrapperRec.Name = mMRec.Name;
                mitigantsMasterWrapperRec.Description = mMRec.Description__c;
                mitigantsMasterWrapperRec.Id = mMRec.Id;
                
                mitigantsMasterWrapperLst.add(mitigantsMasterWrapperRec);
            }
            return mitigantsMasterWrapperLst;            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Send Email notification to SCM/ACm for Approval
    @AuraEnabled
    public static List<RequestWrapper> sendApprovalCAMReqAPI(String camRecId){
        List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
        String camApprovalRoleLabel = System.Label.camApprovalRoleLabel; 
        List<String> camApprovalRoleLabelList = camApprovalRoleLabel.split(',');
        try {
            if(camRecId!=null && camApprovalRoleLabelList!=null){
                
                CAM__c cam=[SELECT Id,Loan_Application__c,Loan_Application__r.Name, Loan_Application__r.AccountId,Loan_Application__r.CreatedBy.Name FROM CAM__c WHERE id=:camRecId ];
                Id accountId = cam.Loan_Application__r.AccountId;
                List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,User.Profile.UserLicense.Name FROM AccountTeamMember WHERE Account.id= :accountId AND TeamMemberRole IN: camApprovalRoleLabelList AND User.isActive = true];

                Map<String,AccountTeamMember> atmRoleMap = new Map<String,AccountTeamMember>();
                for (AccountTeamMember atm : roleList) {
                    if(atm.TeamMemberRole != null && !atmRoleMap.containsKey(atm.TeamMemberRole)){
                        atmRoleMap.put(atm.TeamMemberRole,atm);
                    }
                }
                roleList = new List<AccountTeamMember>();
                if(atmRoleMap.containsKey('ACM')){
                    roleList.add(atmRoleMap.get('ACM'));
                }else if(atmRoleMap.containsKey('SCM')){
                    roleList.add(atmRoleMap.get('SCM'));
                }else if(atmRoleMap.containsKey('ZCM')){
                    roleList.add(atmRoleMap.get('ZCM'));
                }else if(atmRoleMap.containsKey('NCM')){
                    roleList.add(atmRoleMap.get('NCM'));
                }
                List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='TractorLoanApplicationApprovalEmail'];
        
                List<Applicant__c> applicant = [SELECT Id, Name FROM Applicant__c WHERE Opportunity__c = :cam.Loan_Application__c AND Applicant_Type__c = 'Borrower'];
                
                String applicantName = applicant.size() > 0 ? applicant[0].Name : '';
                if(roleList.size() > 0) {
                    for (AccountTeamMember roleMember : roleList){
                        RequestWrapper emailRequestWrapper = new RequestWrapper();
                        if (roleMember.TeamMemberRole != null) {
                            emailRequestWrapper.employmentType = roleMember.TeamMemberRole;
                            emailRequestWrapper.name = roleMember.user.Name;
                        }
                        Boolean communityCheck = roleMember.User.Profile?.UserLicense.Name == 'Partner Community';
                        emailRequestWrapper.leadId = cam.Loan_Application__c;
                        emailRequestWrapper.loanApplicationId = cam.Loan_Application__c;
                        emailRequestWrapper.userId = roleMember.UserId;
                        emailRequestWrapper.emailTo = roleMember.User.Email;
                        emailRequestWrapper.emailCC =  roleMember.User.Email;
                        String emailTemplateSubject = etList[0].Subject.replace('{!Opportunity.Name}', cam.Loan_Application__r.Name);
                        emailRequestWrapper.emailSubject = emailTemplateSubject;

                        String emailBody = etList[0].HtmlValue.replace('{!Receiving_User.Name}',roleMember.User.Name);
                        emailBody = emailBody.replace('{!Opportunity.Name}',  cam.Loan_Application__r.Name);
                        emailBody = emailBody.replace('{!User.Name}',applicantName);
                        emailBody = emailBody.replace('{!CAM__c.Id}',camRecId);
                        emailBody = emailBody.replace('{cvo.Name}',UserInfo.getName());
                        if (communityCheck) {
                            emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Community_Partners_URL);
                        } else {
                            emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Lightning_Base_URL);
                        }
                        emailRequestWrapper.emailBody = emailBody;

                        String notificationBody = 'Dear {!Receiving_User.Name},\nThis is to notify that an Approval request has been submitted for your review related to CAM Approval. Please click on the here to approve or reject deviation.\nLoan details below:\nLoan Id - {!Opportunity.Name}\nLoan submitter details - {!User.Name}\nBE - {BE.Name}\nCVO - {cvo.Name}\nRegards,';
                        notificationBody = notificationBody.replace('{!Receiving_User.Name}',roleMember.User.Name);
                        notificationBody = notificationBody.replace('{!InsertHyperLink}',cam.Loan_Application__r.Name);
                        notificationBody = notificationBody.replace('{!Opportunity.Name}',  cam.Loan_Application__r.Name);
                        notificationBody = notificationBody.replace('{!User.Name}',applicantName);
                        notificationBody = notificationBody.replace('{cvo.Name}',UserInfo.getName());
                        notificationBody = notificationBody.replace('{BE.Name}',cam.Loan_Application__r.CreatedBy.Name);
                        emailRequestWrapper.notificationBody = notificationBody.trim();

                        emailRequestWrapperList.add(emailRequestWrapper);
                    }
                }else{
                    throw new AuraHandledException('There is no ' + System.Label.camApprovalRoleLabel.replace(',','/') + 'users in account of lead');
                }
            }
            if(emailRequestWrapperList.size() > 0){
                CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
                
                Messaging.CustomNotification noti = new Messaging.CustomNotification();
                
                noti.setBody(emailRequestWrapperList[0].notificationBody);
                noti.setTitle(emailRequestWrapperList[0].emailSubject);
                noti.setNotificationTypeId(notificationType.Id);
                noti.setTargetId(emailRequestWrapperList[0].loanApplicationId);
                noti.send(new Set<String> { emailRequestWrapperList[0].userId });
                if(camRecId != null){
                    CAM__c cam = new CAM__c();
                    cam.Id = camRecId;
                    cam.Submit_for_Approval_UserId__c = emailRequestWrapperList[0].userId;
                    update cam;
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('lWC_ManualDeviationMitigantsCntrl', 'sendApprovalCAMReqAPI', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecId LIMIT 1].Loan_Application__c);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return emailRequestWrapperList;
    }
    //CISP-13443 - START
    public static void checkDeviationLevelSkip(String camId)
    {
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        List<Deviation__c> deviationList = new List<Deviation__c>();
        List<Deviation__c> skippedDeviationsList = new List<Deviation__c>();
        Set<String> deviationRolesSet = new Set<String>();
        Set<String> atmRolesSet = new Set<String>();
        Set<String> missedDeviationRoles = new Set<String>();
        Map<String, String> levelSkipMapWithRole = new Map<String, String>();
        Map<String, String> levelSkipMapWithRoleTemp = new Map<String, String>();
        List<Deviation__c> deviationsToUpdate = new List<Deviation__c>();
        for(Deviation__c dv : [SELECT Id,Name,DeviationID__c,Deviation_Level__c,Role__c,Type__c,Parent_CAM__c,Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.AccountId,Parent_CAM__r.Trigger_Deviations__c,Parent_CAM__r.Loan_Application__r.Name , EmployeeID__c,Deviation_Description__c,Parent_CAM__r.Loan_Application__r.Product_Type__c,Parent_CAM__r.Loan_Application__r.Vehicle_Type__c FROM Deviation__c WHERE Parent_CAM__c=:camId])
        {
            if(dv.Role__c != null)
            {
                for(String roleValue : dv.Role__c.split(','))
                {
                    deviationRolesSet.add(roleValue);
                }
            }
            deviationList.add(dv);
        }
        Id accountId;
        if(!deviationList.isEmpty())
        {
            accountId = deviationList[0].Parent_CAM__r.Loan_Application__r.AccountId;
            for(Deviation_Level_Skip_Metadata__mdt levelSkipRecord : [SELECT Id,Current_Level__c, Current_Role__c,Skip_To_Level__c,Skip_To_Role__c,Product_Type__c from Deviation_Level_Skip_Metadata__mdt WHERE Product_Type__c =: deviationList[0].Parent_CAM__r.Loan_Application__r.Product_Type__c])
            {
                levelSkipMapWithRole.put(levelSkipRecord.Current_Role__c, levelSkipRecord.Skip_To_Role__c);
                levelSkipMapWithRoleTemp.put(levelSkipRecord.Current_Role__c, levelSkipRecord.Skip_To_Role__c);
            }
        }
        if(accountId != null)
        {
            for(AccountTeamMember atm : [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,User.Profile.UserLicense.Name FROM AccountTeamMember WHERE Account.id= :accountId AND user.IsActive=TRUE])
            {
                atmRolesSet.add(atm.TeamMemberRole);
                atmList.add(atm);
            }
        }
        if(!atmList.isEmpty() && !deviationRolesSet.isEmpty())
        {
                for(String roleName : deviationRolesSet)
                {
                    if(!atmRolesSet.contains(roleName))
                        missedDeviationRoles.add(roleName);
                }
        }
        if(!missedDeviationRoles.isEmpty())
        {
            for(String roleName : missedDeviationRoles)
                {
                    String targetRole = returnActiveRoles(roleName, levelSkipMapWithRoleTemp, atmRolesSet);
                    if(targetRole != '' && targetRole != null)
                    {
                        if(levelSkipMapWithRole.containsKey(roleName))
                            if(levelSkipMapWithRole.get(roleName) != targetRole)
                                levelSkipMapWithRole.put(roleName,targetRole);
                    }
 
                }
        }
        if(!missedDeviationRoles.isEmpty())
        {
            for(String roleName : missedDeviationRoles)
                {
                    for(Deviation__c dv : deviationList)
                    {
                        if(dv.Role__c != null)
                        {
                            if(String.valueOf(dv.Role__c).toLowerCase().contains(roleName.toLowerCase()))
                                {
                                if(levelSkipMapWithRole.containsKey(roleName))
                                    {
                                        dv.Role__c = dv.Role__c.replace(roleName, levelSkipMapWithRole.get(roleName));
                                        deviationsToUpdate.add(dv);
                                    }
                                }
                        }
                    }
                }
        }
        if(!deviationsToUpdate.isEmpty())
        update deviationsToUpdate;
    }
 
    public static String returnActiveRoles(String roleName, Map<String, String> levelSkipMapWithRole, Set<String> atmRolesSet)
    {
        String finalRole;
        if(levelSkipMapWithRole.containsKey(roleName))
        {
            if(atmRolesSet.contains(levelSkipMapWithRole.get(roleName)))
            {
                return levelSkipMapWithRole.get(roleName);
            }
            else
                {
                    finalRole = returnActiveRoles(levelSkipMapWithRole.get(roleName), levelSkipMapWithRole, atmRolesSet);
                    return finalRole;
                }
        }
        else
            return '';
    }
    //CISP-13443 - END
    // Wrapper class for Deviation Master
    public class deviationMasterWrapper{
        /*@AuraEnabled
		public Boolean isActive;*/
        @AuraEnabled
        public String Deviation_Id {get;set;}
        @AuraEnabled
        public String Source {get;set;}
        @AuraEnabled
        public String Parameter {get;set;}
        @AuraEnabled
        public String Deviation_Level {get;set;}   
    }
    
    // Wrapper class for mitigants Master
    public class mitigantsMasterWrapper{
        /*@AuraEnabled
		public Boolean isActive;*/
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Description {get;set;} 
        @AuraEnabled
        public String Id {get;set;} 
    }
    @AuraEnabled
    public static Map<Id,String> applicantAge(List<Documents__c> document, Map<Id,String> coborrowerAgeMap){
        for(Documents__c documentObj:document){
            if(documentObj.Applicant__r.Applicant_Type__c== Label.Beneficiary && documentObj.Proof_of_Identity_POI__c == true){
                if(documentObj.KYC_DOB__c!=null && (documentObj.KYC_DOB__c.month() > date.today().month() || (documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() > date.today().day()))) {
                    if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                        coborrowerAgeMap.put(documentObj.Applicant__c, String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()-1));
                    }
                }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() <= date.today().day()) {
                    if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                        coborrowerAgeMap.put(documentObj.Applicant__c, String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()));
                    }
                }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() < date.today().month()) {
                    if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                        coborrowerAgeMap.put(documentObj.Applicant__c, String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()));
                    }
                }else{
                    if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                        coborrowerAgeMap.put(documentObj.Applicant__c, '');
                    }
                }
            }
        }
        return coborrowerAgeMap;
    }
    @AuraEnabled
    public static Map<Id,String> applicantGender(List<Documents__c> document, Map<Id,String> coborrowerGenderMap){
        for(Documents__c documentObj:document){
            if(documentObj.Applicant__r.Applicant_Type__c== Label.Beneficiary && documentObj.Proof_of_Identity_POI__c == true){
                if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                    if(documentObj.Gender__c!=null) {
                        coborrowerGenderMap.put(documentObj.Applicant__c, String.valueOf(documentObj.Gender__c));
                    }else{
                        coborrowerGenderMap.put(documentObj.Applicant__c, '');
                    }
                }
            }
        }
        return coborrowerGenderMap;
    }

    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        Map<String, String> picklistValues = new Map<String, String>();
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
    
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            picklistValues.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }
    
        return picklistValues;
    }

    public static string getFieldValue(Object str) {
        return str != null ? String.valueOf(str) : '';
    }
    
    public static Double getMinimumValue(List<Double> doubleList) {
        if (doubleList == null || doubleList.isEmpty()) {
            return null;
        }
        Double minValue = doubleList[0];
        for (Double num : doubleList) {
            if (num < minValue) {
                minValue = num;
            }
        }
        return minValue;
    }
}