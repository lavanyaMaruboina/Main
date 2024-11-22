/**
* @Name         FIAssignmentController_Helper
* @Author       Manish Baldota	
* @Company      Persistent Systems
* @Description  This class is helper to the FIAssignmentController class, to open up the access for FI Assignment.
				We are facing issues with AccountTeamMember,Case Assignment for Community users, so using this class to give access.
* Inputs:       None
* Test Class:   
*/
public without sharing class FIAssignmentController_Helper {
	/*
    * @Method:      searchLookup
    * @Created by:  Manish Baldota
    * @Description: This method is used to assign the FI records to the external as well as internal user to share the access.
    * @Param:       String - Query (field name that needs to be fetched).
    * @Return:      List of sObjects.
    */
   public static void assignFI(Opportunity loanApplication) {
        Set<Id> userIDs = new Set<Id>();

        try{
           
            Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();

            List<Case> listCase  = [SELECT Id, AccountId, Loan_Application__c, RecordType.DeveloperName , Loan_Application__r.LeadSource,Status
                                    FROM case 
                                    WHERE Loan_Application__c =:loanApplication.Id AND recordTypeId =:recTypeId];
            System.debug('listCase is: '+listCase);
            List<AccountTeamMember> teamMemberFI = [Select AccountId,userId,FI_Executive_Counter__c
                                                    From AccountTeamMember
                                                    Where teammemberrole = 'FI'
                                                    AND user.isActive = true
                                                    AND AccountId = :loanApplication.AccountId 
                                                    Order by LastModifiedDate ASC];////CISP-2765
            System.debug('teamMemberFI is: '+teamMemberFI);
            //CISP-2765 - start
            List<Case> caseMOList = new List<Case>();
            Map<Id, Integer> mapOfUserIdToCounter = new Map<Id, Integer>();
            List<AccountTeamMember> listAccountTeamMemberToUpdate = new List<AccountTeamMember>(); 
            Map<Id, AccountTeamMember> mapOfUserIdToAccountTeamMember = new Map<Id, AccountTeamMember>();  
            
            if(teamMemberFI.isEmpty()) {
                List<AccountTeamMember> teamMemberMO = [Select Id,userId,FI_Executive_Counter__c From AccountTeamMember Where teammemberrole = 'MO'
                                                         AND User.isActive = true AND AccountId = :loanApplication.AccountId Order by LastModifiedDate ASC];//CISP-2765
                System.debug('teamMemberMO is: '+teamMemberMO);
                if(!teamMemberMO.isEmpty()) {
                    for(AccountTeamMember accountTeamMember : teamMemberMO) {
                        System.debug('accountTeamMember MO is: '+accountTeamMember);
                        accountTeamMember.FI_Executive_Counter__c = accountTeamMember.FI_Executive_Counter__c == null ? 0 : accountTeamMember.FI_Executive_Counter__c;//change made for round robin
                        Decimal executiveCount = accountTeamMember.FI_Executive_Counter__c == null ? 0.0 : accountTeamMember.FI_Executive_Counter__c;
                        mapOfUserIdToCounter.put(accountTeamMember.userId,Integer.valueOf(executiveCount));
                        mapOfUserIdToAccountTeamMember.put(accountTeamMember.userId,accountTeamMember);
                	}
                }
                else {
                    List<AccountTeamMember> teamMemberBE = [Select Id,userId,FI_Executive_Counter__c From AccountTeamMember Where teammemberrole = 'BE'
                                                         AND User.isActive = true AND AccountId = :loanApplication.AccountId Order by LastModifiedDate ASC];//CISP-2765
                    System.debug('teamMemberBE is: '+teamMemberBE);
                    if(!teamMemberBE.isEmpty()) {
                        for(AccountTeamMember accountTeamMember : teamMemberBE) {
                            System.debug('accountTeamMember BE is: '+accountTeamMember);
                            accountTeamMember.FI_Executive_Counter__c = accountTeamMember.FI_Executive_Counter__c == null ? 0 : accountTeamMember.FI_Executive_Counter__c;//change made for round robin
                            Decimal executiveCount = accountTeamMember.FI_Executive_Counter__c == null ? 0.0 : accountTeamMember.FI_Executive_Counter__c;
                            mapOfUserIdToCounter.put(accountTeamMember.userId,Integer.valueOf(executiveCount));
                            mapOfUserIdToAccountTeamMember.put(accountTeamMember.userId,accountTeamMember);
                		}
                    }
                }
            }
            //CISP-2765 - end
                                                    
                                         
            if(!teamMemberFI.isEmpty()) {            
                for(AccountTeamMember accountTeamMember : teamMemberFI) {
                    System.debug('accountTeamMember FI is: '+accountTeamMember);
                    accountTeamMember.FI_Executive_Counter__c = accountTeamMember.FI_Executive_Counter__c == null ? 0 : accountTeamMember.FI_Executive_Counter__c;//change made for round robin
                    Decimal executiveCount = accountTeamMember.FI_Executive_Counter__c == null ? 0.0 : accountTeamMember.FI_Executive_Counter__c;
                    mapOfUserIdToCounter.put(accountTeamMember.userId,Integer.valueOf(executiveCount));
                    mapOfUserIdToAccountTeamMember.put(accountTeamMember.userId,accountTeamMember);
                }
            }
            //update Owner Id on case and increase the counter on Round robin basis
            List<Case> updatedCase = new List<Case>();
            if(!mapOfUserIdToCounter.isEmpty()){
                Id assignmenedUserId = getLowestCounterFIExecutive(mapOfUserIdToCounter);
                for(Case objCase : listCase) {
                    if(String.isBlank(objCase.Status) || objCase.Status != 'Completed'){
                        objCase.Status ='FI Assigned';
                    }
                    if(mapOfUserIdToCounter != null && mapOfUserIdToCounter.size()>0) {
                        System.debug('assignmenedUserId is: '+assignmenedUserId);
                        if(objCase.Loan_Application__r.LeadSource == 'OLA'){//CISH-47 && CISH-114
                        objCase.OwnerId = UserInfo.getUserId();
                    } else{
                        objCase.OwnerId = assignmenedUserId;		
                        userIDs.add(assignmenedUserId);
                        //Push the detail to SET of assignmentUserId, declare the Set at top                    
                        mapOfUserIdToCounter.put(assignmenedUserId, mapOfUserIdToCounter.get(assignmenedUserId) + 1);
                        System.debug('mapOfUserIdToCounter line 90 '+mapOfUserIdToCounter);
                    }
                    } else {
                        //objCase.OwnerId = cvoUserId;
                    }
                    updatedCase.add(objCase);
                    System.debug('updatedCase is'+updatedCase);
                }
            }
            if(!updatedCase.isEmpty()) {
                List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>();
				if(!userIDs.isEmpty()){
                    for(Id usr : userIDs){                       
                        OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                        oppTeam.OpportunityId= loanApplication.Id;
                        oppTeam.UserId=usr;
                        oppTeam.TeamMemberRole='FI';
                        oppTeam.OpportunityAccessLevel = 'Edit'; 
                       opptyTeams.add(oppTeam);
                    }
				}                
				//insert opptyTeams
                update updatedCase;
                insert opptyTeams;
               
            }
            System.debug('before FI update: '+mapOfUserIdToCounter);
            // Update counter on FI Executive
            for(Id assignmentUserId : mapOfUserIdToCounter.keySet()) {
                AccountTeamMember fiExectiveAccountTeamMember = mapOfUserIdToAccountTeamMember.get(assignmentUserId);
                System.debug('fiExectiveAccountTeamMember is '+fiExectiveAccountTeamMember);
                System.debug('fiExectiveAccountTeamMember FI counter '+fiExectiveAccountTeamMember.FI_Executive_Counter__c);
                if(mapOfUserIdToCounter.get(assignmentUserId) > fiExectiveAccountTeamMember.FI_Executive_Counter__c) {
                    System.debug('line 118 '+fiExectiveAccountTeamMember.FI_Executive_Counter__c+' leftv '+mapOfUserIdToCounter.get(assignmentUserId));
                    fiExectiveAccountTeamMember.FI_Executive_Counter__c = mapOfUserIdToCounter.get(assignmentUserId);
                    listAccountTeamMemberToUpdate.add(fiExectiveAccountTeamMember);
                }
            }
            System.debug('list to update '+listAccountTeamMemberToUpdate);
            if(!listAccountTeamMemberToUpdate.isEmpty()) {
                update listAccountTeamMemberToUpdate;
            }
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FIAssignmentController', 'assignFI', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
    * @Method:      searchLookup
    * @Created by:  Manish Baldota
    * @Description: This method is used to assign the FI records to the external as well as internal user to share the access.
    * @Param:       String - Query (field name that needs to be fetched).
    * @Return:      List of sObjects.
    */
    public static void assignFItoMOUser(Opportunity loanApplication) {
        try{
           
            Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();

            List<Case> listCase  = [SELECT Id, AccountId, Loan_Application__c, RecordType.DeveloperName, Loan_Application__r.OwnerId, Status
                                    FROM case 
                                    WHERE Loan_Application__c =:loanApplication.Id AND recordTypeId =:recTypeId];

            List<Case> updatedCase = new List<Case>();
            for(Case objCase : listCase) {
                if(String.isBlank(objCase.Status) || objCase.Status != 'Completed'){
                    objCase.Status ='FI Assigned';
                }
                objCase.OwnerId = UserInfo.getUserId();
                updatedCase.add(objCase);
            }
            system.debug('updatedCase::'+updatedCase);

            OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                oppTeam.OpportunityId= loanApplication.Id;
                oppTeam.UserId=UserInfo.getUserId();
                oppTeam.TeamMemberRole='MO';
                oppTeam.OpportunityAccessLevel = 'Edit'; 
                system.debug('opptyTeams::'+oppTeam);

            update updatedCase;
            insert oppTeam;

        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FIAssignmentController', 'assignFItoMOUser', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }

    }

    //Round robin, get lowest counter value
    //@Testvisible added by Hemanth Thikka
    // @Method:      getLowestCounterFIExecutive
    // @Created by:  Jitendra Sharma
    // @Description: get lowest FI executive counter for the user
    // @Param:     Map of user ID to FI executive counter
    // @Return:  None
    @Testvisible
    private static Id getLowestCounterFIExecutive(Map<Id, Decimal> mapOfUserIdToCounter) {
        Decimal lowestCountervalue =new list<Decimal>(mapOfUserIdToCounter.values())[0];
        Id assignmentUserId = new list<Id>(mapOfUserIdToCounter.keySet())[0];
        ////CISP-2765
        // for(Id userId : mapOfUserIdToCounter.keySet()) {
        //     if(mapOfUserIdToCounter.get(userId) < lowestCountervalue) {
        //         lowestCountervalue = mapOfUserIdToCounter.get(userId);
        //         assignmentUserId = userId;
        //     }
        // }
        ////CISP-2765
        return assignmentUserId;
    }
}