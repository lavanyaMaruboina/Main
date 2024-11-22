/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is helper class for MIS_RC_Limit_Dt__c
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
19-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
public without sharing class DSA_RC_Limit_Dt_Helper {
    
  /*  public static void shareLeadToDSA(List<MIS_RC_Limit_Dt__c> newlst){
        try{
            List<OpportunityTeamMember> lstOppTeam = new List<OpportunityTeamMember>();
            Map<String,String> benAndDealerCode = new Map<String,String>();
            Map<Id,String> benAndUser = new Map<Id,String>();
            
            for(MIS_RC_Limit_Dt__c rcLimit: newlst){
                if(rcLimit.Ben_Type__c=='DSA'){
                    benAndDealerCode.put(rcLimit.Ben_Code__c ,rcLimit.Deal_No__c);
                }
            }
            
            for(User u : [Select Id,Name, EmployeeNumber  from user where EmployeeNumber IN: benAndDealerCode.keySet()]){
                benAndUser.put(u.Id,benAndDealerCode.get(u.EmployeeNumber));
            }
            
            for(Opportunity opp : [Select Id, CreatedById,Deal_Number__c from Opportunity where Deal_Number__c IN: benAndDealerCode.values()]){
                for(Id userId: benAndUser.keySet()){
                    if(benAndUser.get(userId) == opp.Deal_Number__c && opp.CreatedById !=userId){
                        OpportunityTeamMember OppTeamMemb = new OpportunityTeamMember();
                        OppTeamMemb.OpportunityId=opp.Id;
                        OppTeamMemb.UserId=userId;
                        OppTeamMemb.TeamMemberRole=IND_Constant.TeamMemberRole;
                        OppTeamMemb.OpportunityAccessLevel=IND_Constant.OpportunityAccessLevel;
                        lstOppTeam.add(OppTeamMemb);
                    }
                }
            }
            if(!lstOppTeam.isEmpty()){
                Insert lstOppTeam; 
            }
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('DSA_RC_Limit_Dt_Helper', ' shareLeadToDSA ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }*/
    
    public static void updateDisbursedfield(List<MIS_RC_Limit_Dt__c> newlst){
        try{
        List<Opportunity> lstnewOpp = new List<Opportunity>();
        Map<String, String> dealNo = new Map<String, String>();
        for(MIS_RC_Limit_Dt__c rc : newlst){
            if(rc.Deal_No__c != null){
            dealNo.put(rc.Deal_No__c, rc.IBL_Lien_Marked__c);
            }
        } 
        List<opportunity> lstOpp = [Select Id, name,Deal_Number__c from opportunity where Deal_Number__c IN : dealNo.keyset()];
        for(opportunity opp : lstOpp){
            if(dealNo.get(opp.Deal_Number__c)=='Y'){
                Opportunity objOpp = new Opportunity();
                objOpp.Id= opp.Id;
                objOpp.DSA_isDisbursed__c  = 'YES';
                lstnewOpp.add(objOpp);
            }
            else{
               Opportunity objOpp = new Opportunity();
                objOpp.Id= opp.Id;
                objOpp.DSA_isDisbursed__c  = 'NO';
                lstnewOpp.add(objOpp); 
            }
        } 
        update lstnewOpp;
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('DSA_RC_Limit_Dt_Helper', ' updateDisbursedfield ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }
    public static void updateDisbursedfield(Map<Id,MIS_RC_Limit_Dt__c> newMap, Map<Id,MIS_RC_Limit_Dt__c> oldMap){
        try{
            List<Opportunity> lstnewOpp = new List<Opportunity>();
            Map<String, String> dealNo = new Map<String, String>();
            for(MIS_RC_Limit_Dt__c rc : newMap.values()){
                if(rc.IBL_Lien_Marked__c != oldMap.get(rc.Id).IBL_Lien_Marked__c){
                    dealNo.put(rc.Deal_No__c, rc.IBL_Lien_Marked__c);
                    
                }
            } 
            List<opportunity> lstOpp = [Select Id, name,Deal_Number__c from opportunity where Deal_Number__c IN : dealNo.keyset()];
            for(opportunity opp : lstOpp){
                if(dealNo.get(opp.Deal_Number__c)=='Y'){
                    Opportunity objOpp = new Opportunity();
                    objOpp.Id= opp.Id;
                    objOpp.DSA_isDisbursed__c  = 'YES';
                    lstnewOpp.add(objOpp);
                }
                else{
               Opportunity objOpp = new Opportunity();
                objOpp.Id= opp.Id;
                objOpp.DSA_isDisbursed__c  = 'NO';
                lstnewOpp.add(objOpp); 
            }
            } 
            update lstnewOpp;
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('DSA_RC_Limit_Dt_Helper', ' updateDisbursedfield ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }
}