/**
* @Name         lWC_ManualDeviationMitigantsCntrl
* @Author       Aakash J
* @Company      Salesforce
* @Description  This class contains all methods related to Tractor Manual Deviation and Mitigants process 
* Inputs:       None
* Test Class:   
* History:
*/
public with sharing class lWC_ManualDeviationMitigantsCntrl{
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
    
    @AuraEnabled
    public static String saveDeviationRec(List <deviationMasterWrapper> listofDeviation, String camRecId) {
        String returnedValue = 'Successful';
        try {
            List<Deviation__c> devUpdateList = new List<Deviation__c>();
            CAM__c cam = [SELECT Id,Loan_Application__c,Credit_Analyst_Remarks__c, Committee__c, Loan_Application__r.AccountId,Loan_Application__r.Product_Type__c FROM CAM__c WHERE id=:camRecId WITH SECURITY_ENFORCED];

            List<Deviation__c> deviationListToDelete = new List<Deviation__c>();
            deviationListToDelete = [Select Id from Deviation__c Where Parent_CAM__c =: camRecId AND Deviation_Type__c = 'Manual' AND Type__c = 'Manual Deviation' WITH SECURITY_ENFORCED];

            List<AccountTeamMember> acctemMem=[SELECT ID ,TeamMemberRole,User.Name, Level__c ,Account.id FROM AccountTeamMember WHERE Account.id=:cam.Loan_Application__r.AccountId AND User.isActive = true AND TeamMemberRole != 'CVO' WITH SECURITY_ENFORCED];
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
            if(!listofDeviation.isEmpty()){
                for(deviationMasterWrapper mdWrapRec: listofDeviation){
                    List<String> deviationLevelList = new List<String>();
                    if(mdWrapRec.Deviation_Level != null && mdWrapRec.Deviation_Level.contains(',')){
                        deviationLevelList.addAll(mdWrapRec.Deviation_Level.split(','));
                    }else if(mdWrapRec.Deviation_Level != null && mdWrapRec.Deviation_Level.contains('+')){
                        deviationLevelList.addAll(mdWrapRec.Deviation_Level.split('\\+'));
                    }else{
                        deviationLevelList.add(mdWrapRec.Deviation_Level);
                    }
                    for (String level : deviationLevelList) {
                        Deviation__c  devRec = new Deviation__c ();
                        devRec.Active__c  = true;
                        if (levelVsAccountTeamMemberListMap.containsKey(level)) {
                            for(AccountTeamMember accTeam:levelVsAccountTeamMemberListMap.get(level)){
                                if(accTeam.TeamMemberRole != null){
                                    if(devRec.Role__c == null){
                                        devRec.Role__c=accTeam.TeamMemberRole;
                                    }else{
                                        if(!devRec.Role__c.contains(accTeam.TeamMemberRole)){
                                            devRec.Role__c+=','+accTeam.TeamMemberRole;
                                            devRec.EmployeeID__c+=','+accTeam.UserID;
                                        }
                                    }
                                }
                            }
                        }
                        devRec.Parent_CAM__c = camRecId=='' ? '' : camRecId;
                        devRec.DeviationID__c  = mdWrapRec.Deviation_Id;
                        devRec.Source__c  = mdWrapRec.Source;
                        devRec.Deviation_Description__c   = mdWrapRec.Parameter;
                        devRec.Deviation_Level__c   = level;
                        devRec.Deviation_Type__c  ='Manual';
                        devRec.Type__c  ='Manual Deviation';
                        devUpdateList.add(devRec);
                    }
                }
                if(!devUpdateList.isEmpty()){
                    insert devUpdateList; 
                    delete deviationListToDelete;  
                }         
            } 
            return returnedValue; 
        } catch ( Exception e ) {   
            system.debug('ERROR '+e.getMessage() + 'ERROR Line '+e.getLineNumber());
            throw new AuraHandledException( e.getMessage() );            
        }
    }

    @AuraEnabled
    public static List<Deviation__c> fetchManulaDeviationRecords(String camRecId) {
        try {
            List<Deviation__c> deviationList = new List<Deviation__c>();
            deviationList = [Select Id,Source__c,Deviation_Level__c,Deviation_Description__c,DeviationID__c from Deviation__c Where Parent_CAM__c =: camRecId AND Deviation_Type__c = 'Manual' AND Type__c = 'Manual Deviation' WITH SECURITY_ENFORCED];
            return deviationList;
        } catch ( Exception e ) {   
            throw new AuraHandledException( e.getMessage() );            
        }
    }

    // Method for mitigants Master get to LWC
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
                
                mitigantsMasterWrapperLst.add(mitigantsMasterWrapperRec);
            }
            return mitigantsMasterWrapperLst;            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String saveMitigantRec(List <mitigantsMasterWrapper> listofMitigant, String camRecId) {
        try {
            List<Mitigant__c> mitipdateList = new List<Mitigant__c>();
            List<Mitigant__c> mitigantListToDelete = new List<Mitigant__c>();
            mitigantListToDelete = [Select id,Description__c,Name from Mitigant__c Where CAM__c =: camRecId WITH SECURITY_ENFORCED];
            if(!listofMitigant.isEmpty()){
                for(mitigantsMasterWrapper mdWrapRec: listofMitigant){
                    Mitigant__c  mitiRec = new Mitigant__c ();
                    mitiRec.Active__c  = true;
                    mitiRec.CAM__c = camRecId=='' ? '' : camRecId;
                    mitiRec.Description__c  = mdWrapRec.Description;
                    mitiRec.Name  = mdWrapRec.Name;
                    mitipdateList.add(mitiRec);
                }
                if(!mitipdateList.isEmpty()){
                    insert mitipdateList;
                    delete mitigantListToDelete;
                }         
            } 
            return 'Successful'; 
        } catch ( Exception e ) {   
            system.debug('ERROR '+e.getMessage() + 'ERROR Line '+e.getLineNumber());
            throw new AuraHandledException( e.getMessage() );            
        }
    }

    @AuraEnabled
    public static List<Mitigant__c> fetchMitigantRecords(String camRecId) {
        try {
            List<Mitigant__c> mitigantList = new List<Mitigant__c>();
            mitigantList = [Select id,Description__c,Name from Mitigant__c Where CAM__c =: camRecId WITH SECURITY_ENFORCED];
            return mitigantList; 
        } catch ( Exception e ) {   
            throw new AuraHandledException( e.getMessage() );            
        }
    }
    
    // Send Email notification to SCM/ACm for Approval
    @AuraEnabled
    public static List<RequestWrapper> sendApprovalCAMReqAPI(String camRecId){
        System.debug('++++camRecId '+camRecId);
        List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
        String camApprovalRoleLabel = System.Label.camApprovalRoleLabel; 
        List<String> camApprovalRoleLabelList = camApprovalRoleLabel.split(',');
        System.debug('++++camApprovalRoleLabelList '+camApprovalRoleLabelList);
        try {
            if(camRecId!=null && camApprovalRoleLabelList!=null){
                
                CAM__c cam=[SELECT Id,Loan_Application__c,Loan_Application__r.Name, Loan_Application__r.AccountId FROM CAM__c WHERE id=:camRecId ];
                System.debug('++++cam '+cam);
                Id accountId = cam.Loan_Application__r.AccountId;
                List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,User.Profile.UserLicense.Name FROM AccountTeamMember WHERE Account.id= :accountId AND TeamMemberRole IN: camApprovalRoleLabelList ];
                
                List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='TractorLoanApplicationApprovalEmail'];
        
                List<Applicant__c> applicant = [SELECT Id, Name FROM Applicant__c WHERE Opportunity__c = :cam.Loan_Application__c AND Applicant_Type__c = 'Borrower'];
                
                String applicantName = applicant.size() > 0 ? applicant[0].Name : '';
                System.debug('++++roleList '+roleList);
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
                        emailRequestWrapperList.add(emailRequestWrapper);
                    }
                }
                System.debug('++++emailRequestWrapperList '+emailRequestWrapperList);
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('lWC_ManualDeviationMitigantsCntrl', 'sendApprovalCAMReqAPI', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecId LIMIT 1].Loan_Application__c);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return emailRequestWrapperList;
    }
    
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
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String recordId){
        if(recordId != null){
            Opportunity oppObj = [Select id,StageName,Sub_Stage__c from Opportunity Where Id=: recordId LIMIT 1];
            return oppObj;
        }
        return null;
    }
}