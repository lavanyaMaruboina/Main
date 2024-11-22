public with sharing class IND_CMUCaseOwnershipChangeActionCntrl {
    /* @Method Name: getUserDetails
    * @Created by:  Sanketkumar Patil
    * @description: To get the CMU User list based on PROFILE
    * @Return:      Wrapper String
    */
    @AuraEnabled
    public static String getUserList(Id recordId){
        ResponseWrapper resWrapper = New ResponseWrapper();

        try{
            //Without SECURITY_ENFORCED since this will be executed by Community user as well
            List<Case> caseList = [SELECT id, ownerId FROM Case WHERE id = :recordId WITH SECURITY_ENFORCED];
            List<User> userDetailsList = [SELECT id, Profile.Name, UserRole.DeveloperName, IsPortalEnabled FROM User WHERE id = :UserInfo.getUserId() and IsActive = true WITH SECURITY_ENFORCED];

            if(!userDetailsList.isEmpty()){
                //CMU Users
                if(userDetailsList[0].Profile.Name == 'CMU' && userDetailsList[0].UserRole.DeveloperName == 'CMU_Team_Lead'){
                    List<User> userList = [SELECT id, Name FROM User WHERE Profile.Name = 'CMU' and IsActive = true and id != :caseList[0].ownerId WITH SECURITY_ENFORCED ORDER BY Name];

                    if(!userList.isEmpty()){
                        resWrapper.status = true;
                        resWrapper.userList = userList;
                    } else {
                        resWrapper.status = false;
                        resWrapper.message = 'No User Found';
                    }
                }
            } else {
                resWrapper.status = false;
                resWrapper.message = 'No User Found';
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CMUCaseOwnershipChangeActionCntrl', 'getUserList', System.Label.Apex, ex, recordId);
            resWrapper.status = false;
            resWrapper.message = 'Error in fetching User details - '+ex.getMessage();       
        }
        return JSON.serialize(resWrapper);
    }

    public class ResponseWrapper{
        Boolean status {get;set;}
        String message {get;set;}
        List<User> userList {get;set;}
    }

    /* @Method Name: updateOwner
    * @Created by:  Sanketkumar Patil
    * @description: To Update Case Owner
    * @Return:      Warpper String
    */
    @AuraEnabled
    public static String updateOwner(Id recordId, Id userId){
        ResponseWrapper resWrapper = New ResponseWrapper();
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>(); 

        try{
            if(recordId == null || userId == null){
                resWrapper.status = false;
                resWrapper.message = 'Error in updating Case Owner';
            } else {
                List<Case> caseList = [SELECT id, OwnerId, CaseNumber, Loan_Application__c FROM Case WHERE id = :recordId WITH SECURITY_ENFORCED];
                System.debug('Log - Case List:: '+caseList);

                if(!caseList.isEmpty()){
                    caseList[0].OwnerId = userId;

                    OpportunityTeamMember oppTeamMember =new OpportunityTeamMember();
                    oppTeamMember.UserId = userId;
                    oppTeamMember.OpportunityId = caseList[0].Loan_Application__c;
                    oppTeamMember.TeamMemberRole ='CMU';
                    oppTeamMember.OpportunityAccessLevel = 'Edit'; 
                    oppTeamMemberList.add(oppTeamMember);

                    System.debug('Log - Team Member Details:: '+oppTeamMemberList);

                    if(Schema.sObjectType.OpportunityTeamMember.isCreateable() && Schema.sObjectType.Case.isUpdateable()){
                        if(!Test.isRunningTest()){
                            CaseWithoutSharingUpdate.insertopptyTeamMembers(oppTeamMemberList);
                        }
                        update caseList;
                    } else {
                        resWrapper.status = false;
                        resWrapper.message = 'Error in updating Case Owner, Please contact System Administrator';
                    } 
                }
                
                if(resWrapper.status != false){
                    resWrapper.status = true;
                    resWrapper.message = 'now owns the record for ' + caseList[0].CaseNumber;
                }
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CMUCaseOwnershipChangeActionCntrl', 'updateOwner', System.Label.Apex, ex, recordId);
            resWrapper.status = false;
            resWrapper.message = 'Error in updating Case Owner - '+ex.getMessage();       
        }

        return JSON.serialize(resWrapper);
    }
}