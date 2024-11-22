/**
* @Name         UpdateLeadsTowithdrawan
* @Author       Nidhi Dhote
* @Company      Persistent Systems
* @Description  If sanction date is null for past 90 days lead and than we are updating stage name to withdrawn and scheduling class for everyday 1am.
* Inputs:       NONE
* Test Class:   UpdateLeadsTowithdrawanTest
* History:
*/
public class UpdateLeadsTowithdrawan implements Database.Batchable<SObject>,Schedulable {
    // Here we are retreving past 90 days before data.
    public static database.QueryLocator start(database.BatchableContext bc){
        return database.getQueryLocator('select Id, name,Sanction_Date__c,StageName from Opportunity where CreatedDate < LAST_90_DAYS');
    }
    //If sanction date is null than we are updating stage name to withdrawn.
    public static void Execute(database.BatchableContext bc, List<Opportunity> listopp){  
        List<Opportunity> updateOppList = new List<Opportunity>();
        For(Opportunity opp : listopp){
            if(opp.Sanction_Date__c == null){
               opp.StageName = System.Label.Withdrawn_Stage;
               updateOppList.add(opp);
            }
        }
        if(updateOppList.size() > 0){
        	database.update(updateOppList, false);
        }
    }
    public static void finish(database.BatchableContext bc){
    }
    
    // Here we are scheduling class for everyday 1am
    public void execute(SchedulableContext sc) {
        UpdateLeadsTowithdrawan opp = new UpdateLeadsTowithdrawan();
		database.executebatch(opp);   
    }
}