/*------------------------------------------------------------
Author:        Jitendra Sharma
Company:       Persistent Systems
Description:   This class handles case and App owner assignment
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-17-2021       Jitendra Sharma      Created
------------------------------------------------------------*/
public without sharing class FIAssignmentController  {

    public static string loanApplicationId;
    
    public class Details {
        @AuraEnabled
        public String accountId { get; set; }

        @AuraEnabled
        public String ProductType { get; set; }

        @AuraEnabled
        public String userRole { get; set; }  
        
        @AuraEnabled
        public String loanApplicationId { get; set; }  

        @AuraEnabled
        public String caseId { get; set; } 
        @AuraEnabled
        public String caseCurrentOwnerId { get; set; } 
    }

    // @Method:      getLoanApplicationDetails
    // @Created by:  Jitendra Sharma
    // @Description: Method to get loan or case details based on the input
    // @Param:       String : recordId : caseId or Opportunity Id , objectName: Opportunity or case
    // @Return:  wrapper data having opportunity data
    @AuraEnabled
    public static Details getLoanApplicationDetails(String recordId, String objectName) {
        try{        
            Details objDetails = new Details();
            if(objectName == System.Label.Opportunity) {           
                Opportunity opp = [Select Id,AccountId,Product_Type__c,Owner.UserRole.Name from Opportunity where Id =:recordId  Limit 1];
                loanApplicationId = opp.Id;
                if(opp != null) {
                    objDetails.accountId = opp.AccountId;
                    objDetails.ProductType = opp.Product_Type__c;
                    objDetails.userRole = opp.Owner.UserRole.Name;
                    objDetails.loanApplicationId = opp.Id;
                    objDetails.caseId = '';
                    objDetails.caseCurrentOwnerId = '';
                }
            } else {
                Case objCase = [Select Id,Loan_Application__r.AccountId,Loan_Application__r.Product_Type__c,OwnerId,Loan_Application__r.Owner.UserRole.Name from Case where Id =:recordId Limit 1];       
                    if(objCase != null) {
                        objDetails.accountId = objCase.Loan_Application__r.AccountId;
                        objDetails.ProductType = objCase.Loan_Application__r.Product_Type__c;
                        objDetails.userRole = objCase.Loan_Application__r.Owner.UserRole.Name;
                        objDetails.loanApplicationId = '';
                        objDetails.caseId = objCase.Id;
                        objDetails.caseCurrentOwnerId = objCase.OwnerId;
                    }
            
            }
        return objDetails;
    }catch(Exception e){
        ErrorLoggerUtil.logErrorEvent('FIAssignmentController', 'getLoanApplicationDetails', System.Label.Apex, e,loanApplicationId);
        return null;
    }

    }

    // @Method:      assignmentFIApp
    // @Created by:  Jitendra Sharma
    // @Description: update owner on case and opportunity
    // @Param:      recordIdCase, recordIDOpportunity, caseOwnerId, loanOwnerId, isAutomatedPV
    // @Return:  None
    @AuraEnabled
    public static void assignmentFIApp(String recordIdCase, String recordIDOpportunity, String caseOwnerId, String loanOwnerId, Boolean isAutomatedPV, String BlcodeAccountId) {
        try{
            List<Applicant__c> applicantLst = new List<Applicant__c>();
            List<Case> caseList;
            List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>();

            if(isAutomatedPV) {
                caseList = [select Id,Status,OwnerId,Loan_Application__c from Case where Loan_Application__c =:recordIDOpportunity and RecordType.DeveloperName ='FI'];
            }else{
                caseList = [select Id,Status,OwnerId,Loan_Application__c from Case where Id=:recordIdCase];
            }            

            List<AccountTeamMember> teamMemberFI = [Select AccountId,userId,TeamMemberRole
                                                                From AccountTeamMember
                                                                Where UserId =: caseOwnerId
                                                                AND user.isActive = true 
                                                                AND AccountId = :BlcodeAccountId];

            if(caseList != null) {
                if(caseOwnerId != null) {
                    List<Case> caseListUpdate = new List<Case>();
                    for(Case objCase : caseList){
                        loanApplicationId = objCase.Loan_Application__c;
                        objCase.OwnerId = caseOwnerId;
                        objCase.Status = 'FI Assigned';

                        caseListUpdate.add(objCase);

                        
                        OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                        oppTeam.OpportunityId= objCase.Loan_Application__c;
                        oppTeam.UserId=caseOwnerId;
                        oppTeam.TeamMemberRole= teamMemberFI.size() > 0 ? teamMemberFI[0].TeamMemberRole : '';//CISP-3082
                        oppTeam.OpportunityAccessLevel = 'Edit'; 
                        opptyTeams.add(oppTeam);                        
                
                    }
                    if(!opptyTeams.isEmpty()){
                        insert opptyTeams;
                    }  

                    if(!caseListUpdate.isEmpty()) {
                        update caseListUpdate;
                    }                   
                          
                }
                if(loanOwnerId!='' && loanOwnerId != null && recordIDOpportunity!= null) {
                    Opportunity objLoanApplication = [Select  Id,OwnerId,Product_Type__c,StageName,Sub_Stage__c,
                                                      (Select Id,Journey_Stage__c from Applicants__r where In_Active_Applicant__c =false)
                                                      from 	Opportunity 
                                                            where Id = :recordIDOpportunity LIMIT 1];
                    if(objLoanApplication != null) {
                        objLoanApplication.OwnerId = loanOwnerId;
                         //added this logic as part credit processing Journey
                        if(objLoanApplication.Product_Type__c == system.label.PassengerVehicles){
                            objLoanApplication.StageName = system.label.Credit_Processing;
                            objLoanApplication.Sub_Stage__c = system.label.View_Application_Details;
                            objLoanApplication.View_Application_Sub_Stages__c = 'Lead/KYC Details';
                        }
                        
                        
                        //Credit processing - resetting the stage to User details
                        for(Applicant__c applicant : objLoanApplication.Applicants__r){
                            applicant.Journey_Stage__c = system.label.userDetails;
                            applicantLst.add(applicant);
                        }
                    }
                    if(!applicantLst.isEmpty()){
                        update applicantLst;
                    }
                    update objLoanApplication;
                }                
                
            } 
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('FIAssignmentController', 'assignmentFIApp', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    // @Method:      checkUserRole
    // @Created by:  Saloni Jadhav
    // @Description: Check user, vehicle type and product type
    // @Param:      loanApplicationId
    // @Return:  boolean
    @AuraEnabled
    public static boolean checkUserRole(Id loanApplicationId) {
        try{
        boolean returnResp=false;
            Opportunity loanApplication = [ SELECT Id ,Product_Type__c, Owner.Name, AccountId,Vehicle_Type__c
                                            FROM Opportunity 
                                            WHERE Id=: loanApplicationId LIMIT 1 ];
            system.debug('loanApplication' + loanApplication);
            
            for(accountTeamMember accTem : [ SELECT Id, TeamMemberRole, UserId, User.Name 
                                            FROM AccountTeamMember
                                            WHERE UserId =: loanApplication.OwnerId 
                                            AND AccountId =:loanApplication.AccountId 
                                            ])
            {
                if(accTem.TeamMemberRole == 'MO' && loanApplication.Product_Type__c== System.Label.TwoWheeler 
                &&  loanApplication.Vehicle_Type__c == System.Label.Refinance){
                    returnResp= true;
                }

            }
        return returnResp;
    }catch(exception e){
        ErrorLoggerUtil.logErrorEvent('FIAssignmentController', 'checkUserRole', System.Label.Apex, e,loanApplicationId); 
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
    
    }


    // @Method:      applicationAssignmentTW
    // @Created by:  Jitendra Sharma
    // @Description: update CVO user on loan app for two wheeler
    // @Param:      loanApplicationId
    // @Return:  None
    @AuraEnabled
    public static void applicationAssignmentTW(Id loanApplicationId, Boolean isMoRefinanceApplication) {
        try{
            Opportunity loanApplication = [Select Id ,Product_Type__c, Owner.UserRole.Name, AccountId, StageName,Sub_Stage__c,
                                            (Select Id,Journey_Stage__c from Applicants__r where In_Active_Applicant__c =false)
                                            From Opportunity 
                                            where Id=: loanApplicationId LIMIT 1 ];
            List<Applicant__c> applicantsLst = new List<Applicant__c>();
            //Change the code to get the current user is MA/Mo in current Loan Application -->  Account Teams.
            if(loanApplication.Product_Type__c  == System.Label.TwoWheeler) {
                if(loanApplication!=null) {
                    Id oldOwnerId = loanApplication.OwnerId;
                    system.debug('Inside the assignment code');
                    List<AccountTeamMember> teamMemberCVO = new List<AccountTeamMember>([Select AccountId,userId
                                                        From AccountTeamMember
                                                        Where teammemberrole = 'CVO'
                                                        AND AccountId = :loanApplication.AccountId AND User.IsActive = true
                                                        Limit 1]); // append isactive CISP-2924//CISP-2765
                    system.debug('Team member CVO::'+teamMemberCVO);
                    if(!teamMemberCVO.isEmpty()) {
                        loanApplication.OwnerId = teamMemberCVO[0].userId;
                        loanApplication.StageName = system.label.Credit_Processing;
                        loanApplication.Sub_Stage__c = system.label.View_Application_Details;
                        loanApplication.View_Application_Sub_Stages__c = 'Lead/KYC Details';
                        
                        system.debug('loanApplication::'+loanApplication);
                          //Credit processing - resetting the stage to User details
                        for(Applicant__c applicant : loanApplication.Applicants__r){                            
                            applicant.Journey_Stage__c =system.label.userDetails;
                            applicantsLst.add(applicant);
                        }  
                    }
                    system.debug('applicantsLst::'+applicantsLst);
                    if(!applicantsLst.isEmpty()){
                        Update applicantsLst;
                    }
                    update loanApplication;
                    //FIAssignmentController_Helper.assignFI(loanApplication, teamMemberCVO.userId);

                    if(isMoRefinanceApplication){
                        FIAssignmentController_Helper.assignFItoMOUser(loanApplication);
                    }else{
                        //FIAssignmentController_Helper.assignFI(loanApplication, teamMemberCVO.userId);
                        FIAssignmentController_Helper.assignFI(loanApplication);
                    }

                    List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>([Select Id from OpportunityTeamMember Where OpportunityId =: loanApplication.Id AND UserId =: oldOwnerId]);
                    for(OpportunityTeamMember otm : opptyTeams){
                        otm.OpportunityAccessLevel = 'Edit';
                    }
                    if(opptyTeams.size() > 0){
                        update opptyTeams;
                    }else{
                        OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                        oppTeam.OpportunityId= loanApplication.Id;
                        oppTeam.UserId = oldOwnerId;
                        oppTeam.OpportunityAccessLevel = 'Edit';
                        insert oppTeam;
                    }
                    
                }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('FIAssignmentController', 'applicationAssignmentTW', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }   
    
    

    // @Method:      UpdateAccountTeamMemberFIExecutiveCounter
    // @Created by:  Jitendra Sharma
    // @Description: On Before insert update the lowest FI executive counter for FI users on account Team Members
    // @Param:     List Of account team member from trigger class
    // @Return:  None
    public static void UpdateAccountTeamMemberFIExecutiveCounter(List<AccountTeamMember> listAccountTeamMember) {
        try{
            Set<Id> accountIDSet = new Set<Id>();
            for(AccountTeamMember teamMember :listAccountTeamMember) {
                if(teamMember.teammemberrole == 'FI') {
                    accountIDSet.add(teamMember.AccountId);
                }
            }
            List<AccountTeamMember> existingfiList = [Select AccountId,userId,FI_Executive_Counter__c
                                                From AccountTeamMember
                                                Where teammemberrole = 'FI'
                                                AND AccountId IN :accountIDSet Order by FI_Executive_Counter__c asc ];
            
            Map<Id, Decimal> mapOfExisitingAccountIDtoFICounter = new Map<Id, Decimal>();
            if(existingfiList != null && !existingfiList.isEmpty()) {
                for(AccountTeamMember accountTeamMember : existingfiList) {
                    if(mapOfExisitingAccountIDtoFICounter.get(accountTeamMember.AccountId)==null) {
                        mapOfExisitingAccountIDtoFICounter.put(accountTeamMember.AccountId, accountTeamMember.FI_Executive_Counter__c);
                    }
                }
                
                for(AccountTeamMember teamMember :listAccountTeamMember) {                    
                    if(teamMember.teammemberrole == 'FI' && mapOfExisitingAccountIDtoFICounter.get(teamMember.AccountId)!=null) {
                        teamMember.FI_Executive_Counter__c = mapOfExisitingAccountIDtoFICounter.get(teamMember.AccountId);
                      
                    }                    
                }
                
            }
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FIAssignmentController', ' UpdateAccountTeamMemberFIExecutiveCounter ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
}