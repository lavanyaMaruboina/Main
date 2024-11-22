public with sharing class AccountTeamMemberTriggerHandler  extends TriggerHandler{ 
    //Global Variable for to be used for Casting the Sobject details   
    List<AccountTeamMember> newAccountTeamMemberList;
    List<AccountTeamMember> oldAccountTeamMemberList;
    Map<Id,AccountTeamMember> newAccountTeamMemberMap;
    Map<Id,AccountTeamMember> oldAccountTeamMemberMap; 
    public AccountTeamMemberTriggerHandler(){
        newAccountTeamMemberList = (List<AccountTeamMember>)Trigger.new;
        oldAccountTeamMemberList = (List<AccountTeamMember>)Trigger.old;
        newAccountTeamMemberMap = (MAP<Id,AccountTeamMember>)Trigger.newMap; 
        oldAccountTeamMemberMap = (MAP<Id,AccountTeamMember>)Trigger.oldMap;
    }
    public override void beforeInsert() {
        FIAssignmentController.UpdateAccountTeamMemberFIExecutiveCounter(newAccountTeamMemberList); 
    }
}