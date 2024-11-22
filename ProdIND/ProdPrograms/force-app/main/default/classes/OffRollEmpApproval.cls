/*------------------------------------------------------------
Class Name:    OffRollEmpApproval
Author:        Mohammed Iliyas
Description:   Class for creating and approving the case for off roll employess 
------------------------------------------------------------*/
public with sharing class OffRollEmpApproval 
{    
    /*
    * @Method Name: createCase  
    * @Created by:  Mohammed Iliyas  
    * @description: to update the fields on Loan Application
    * @Param:       Id - CaseId    
    */
    @AuraEnabled
    public static void UpdateFieldsOnConformation(Id CaseId)
    {
        try
        {
            if(string.isNotBlank(CaseId))
            {               
                Case caseRec = [SELECT Id, Status, Loan_Application__c FROM Case WHERE Id =: CaseId WITH SECURITY_ENFORCED];
                Id loanAppId = caseRec.Loan_Application__c;
                if(string.isNotBlank(loanAppId))
                {                    
                    Opportunity opp = [SELECT Id,name,Approval_of_app_sourced_by_off_roll_emp__c,Approval_sourced_by_off_role_emp__c 
                                       FROM Opportunity WHERE Id = :loanAppId WITH SECURITY_ENFORCED LIMIT 1];
                    opp.Approval_sourced_by_off_role_emp__c ='Verified Original KYC;Self-Attested KYC copy collected;Met the applicant in person;Current Residence FI has been done;Record confirmations and approve';//CISP-3082 OR CISP-3090
                    opp.Approval_of_app_sourced_by_off_roll_emp__c = true;
                    update opp;
                    caseRec.Status = 'Closed';
                    update caseRec;
                }
                
            }            
        }
        catch(exception e)
        {
            ErrorLoggerUtil.logErrorEvent('OffRollEmpApproval', 'UpdateFieldsOnConformation', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);   
        }        
    }
    
    /*
    * @Method Name: checkCase
    * @Created by:  Ganesh
    * @description: to check whether a loan application has a case or not
    * @Param:       String - loanId       
    */
    @AuraEnabled
    public static Boolean checkCase(String loanId){
        List<Case> caseList = [select id, Loan_Application__c from case where Loan_Application__c =: loanId];
        if(caseList.size() > 0){
            return true;
        } else{
            return false;
        }
    }
    
    /*
    * @Method Name: createCase
    * @Created by:  Mohammed Iliyas
    * @description: to create a case
    * @Param:       String - loanId
    * @Param:       String - productType    
    */
    @AuraEnabled
    public static string createCase(String loanId,String productType,string laownerId){
        Boolean isOffRollEmployee = false;
        Boolean kycIsNotBiometric = false;
        String accountId;
        String loanAppOwnerId;
        try
        {
            // checking user is IBL employee or not
            //Id userId = UserInfo.getUserId();
            String userType = UserInfo.getUserType();
            //List<User> currentUser = [SELECT Id, Name, UserType FROM User WHERE Id = :userId WITH SECURITY_ENFORCED LIMIT 1];
            if(userType == 'PowerPartner')
            {
                isOffRollEmployee = true;
            }                        
            
            Boolean aadhaarIsPresent = false;//CISP-3082 OR CISP-3090
            Boolean isAddressDeclaration = false;//CISP-2701
            // if kyc is not biometric 
            Opportunity opp = [Select Id,AccountId,Lead_number__c FROM Opportunity Where Id = : loanId LIMIT 1];//CISP-3082
            accountId = opp.AccountId;//CISP-3082 OR CISP-3090
            List<Documents__c> docList =[SELECT Id, Aadhar_Source__c, Opportunity_Relation__r.AccountId, Opportunity_Relation__r.Product_Type__c,Opportunity_Relation__r.OwnerId ,Document_Type__c
                                         FROM Documents__c
                                         WHERE Opportunity_Relation__c =:loanId and (Document_Type__c=: System.Label.AadhaarCard OR Document_Type__c=: System.Label.Address_Declaration) AND Is_Active__c = true WITH SECURITY_ENFORCED];//CISP-2701
            
            //CISP-3082 OR CISP-3090-START
            if(docList.size() == 0){
                kycIsNotBiometric = true;
            }
            for(Documents__c doc : docList){
                if(doc.Document_Type__c == System.Label.AadhaarCard){
                    aadhaarIsPresent = true;
                }
                if(doc.Document_Type__c == System.Label.Address_Declaration){
                    isAddressDeclaration=true;
                } else if(doc.Document_Type__c == System.Label.AadhaarCard && doc.Aadhar_Source__c != System.Label.Biometric){
                    kycIsNotBiometric = true;
                }
            }  //CISP-2701-END  
            //CISP-3082 OR CISP-3090-END      
            //Get record type id for Off_Role_Emp_Approval record type
            String offRoleEmpRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Off_Role_Emp_Approval').getRecordTypeId();              
            List<Case> offRoleCaseList = new List<Case>([Select id From Case Where RecordTypeId =: offRoleEmpRecordTypeID AND Loan_Application__c =: loanId WITH SECURITY_ENFORCED]);  
            Boolean isOffRoleCasePresent = offRoleCaseList.size() > 0 ? true : false;   
            
            if(((isOffRollEmployee == true && (kycIsNotBiometric == true || aadhaarIsPresent == false) && (productType == 'Two Wheeler' || productType == System.Label.Tractor)) || isAddressDeclaration == true) && !isOffRoleCasePresent){//CISP-2701 //CISP-3082 OR CISP-3090
                
                // create a case and assasign it to user //Business Executive  
                case cs = new case();
                cs.Loan_Application__c = loanId;
                cs.AccountId = accountId;
                Boolean ownerAssigned = false;
                
                if(productType == 'Passenger Vehicles')
                {
                    if(laownerId != null)
                    {
                        cs.OwnerId = laownerId;
                        ownerAssigned = true;
                    }                                   
                }
                else if(productType == 'Two Wheeler')
                {                
                    List<AccountTeamMember> userList = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember 
                                                       WHERE TeamMemberRole = 'PE' AND User.UserType != 'PowerPartner' AND AccountId =: accountId AND User.isActive = true WITH SECURITY_ENFORCED LIMIT 1];
                    if(!userList.isEmpty())
                    {
                        for(AccountTeamMember userRec : userList)
                        {
                            //if(userRec.User.userType != 'PowerPartner')
                            //{
                                cs.OwnerId = userRec.UserId;
                                ownerAssigned = true;
                                break;
                            //}
                        }
                        }else{
                        List<AccountTeamMember> userList1 = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'RPM' AND User.UserType != 'PowerPartner' AND AccountId =: accountId AND User.isActive = true WITH SECURITY_ENFORCED LIMIT 1];
                        
                        if(userList1.size() > 0){
                                cs.OwnerId = userList1[0].UserId;
                                ownerAssigned = true;
                                }else{
                            List<AccountTeamMember> userList2 = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'SH' AND User.UserType != 'PowerPartner' AND AccountId =: accountId AND User.isActive = true WITH SECURITY_ENFORCED LIMIT 1];
                            
                            if(userList2.size() > 0){
                                    cs.OwnerId = userList2[0].UserId;
                                    ownerAssigned = true;
                            }
                        }
                    }                        
                }
                else if(productType == System.Label.Tractor)
                {                
                    List<AccountTeamMember> userList = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'BH' AND AccountId =: accountId AND User.isActive = true WITH SECURITY_ENFORCED LIMIT 1];
                    if(userList.size() > 0)
                    {
                        cs.OwnerId = userList[0].UserId;
                        ownerAssigned = true;
                    }else{
                        List<AccountTeamMember> userList1 = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'HHEAD' AND AccountId =: accountId AND User.isActive = true WITH SECURITY_ENFORCED LIMIT 1];
                        
                        if(userList1.size() > 0){
                            cs.OwnerId = userList1[0].UserId;
                            ownerAssigned = true;
                        }
                    }                        
                }
                
                if(ownerAssigned)
                {
                    cs.RecordTypeId = offRoleEmpRecordTypeID; 
                    cs.Subject = (String.isBlank(Opp.Lead_number__c) ? '' : Opp.Lead_number__c) + '_' + System.Label.Approval_Of_Application;//CISP-3082
                    cs.Status = System.Label.Pending_Off_Role; 
                    cs.Origin = System.Label.Web;
                    if(Schema.sObjectType.Case.isCreateable())
                    {
                        insert cs;
                    }  
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = loanId;
                    otm.UserId = cs.OwnerId;
                    otm.OpportunityAccessLevel = 'Edit';
  
                    if(Schema.sObjectType.OpportunityTeamMember.isCreateable())
                    {
                        insert otm;
                    }                   
                    return cs.Id;
                }                
            }
            return 'not entered';
        }
        catch(exception e)
        {            
            ErrorLoggerUtil.logErrorEvent('OffRollEmpApproval', 'createCase', System.Label.Apex, e, loanId);
            throw new AuraHandledException(System.Label.ExceptionMessage);   
        }
    }    
}