/***
 * Description : Batch class defined to create Account and Contact for LSQ uploaded opportunities
 * Author : Maantic
 * Date: 21/10/2022
 **/
public class LSQ_CreateAccountNContactBatch implements Database.Batchable<sObject>{
    
    public String queryOPP='Select id, LSQ_ExtID__c, name,Temp_Clinic_Name__c, Email__c, Phone__c, Daily_OPD_Vol__c,  GMB_Paid__c, Infra_in_clinic__c, Number_of_Staff_in_Clinic__c, OPD_Days__c, OPD_Start_Timing__c, OPD_End_Timing__c, OPD_Start_Timing_2__c, OPD_End_Timing_2__c, Other_Apps_Used__c, Software_Name__c, Specialization__c, Staff_Alternate_Phone_Number__c, Staff_Name__c  from opportunity where lsq_imported__c=true and account.name=\'LSQ Data Account\'';
         
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Entry start()::');
        System.debug('Exit start()::');
        return Database.getQueryLocator(queryOpp);
    }
    
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        System.debug('Entry Execute():::'+scope);
        List<Account> accountList=new List<Account>();
        List<Contact> contactList=new List<Contact>();
        List<Opportunity> oppList=new List<Opportunity>();
        List<sObject> insertList=new List<sObject>();
        for(Opportunity opp : scope){
            Account act=new Account();
            act.name= opp.Name+'_'+opp.LSQ_ExtID__c;
            act.Daily_OPD_Vol__c=opp.Daily_OPD_Vol__c;
            act.GMB_Paid__c=opp.GMB_Paid__c;
            act.Infra_In_Clinic__c=  opp.Infra_In_Clinic__c;
            act.Number_of_Staff_in_Clinic__c= opp.Number_of_Staff_in_Clinic__c;
            act.OPD_Days__c=  opp.OPD_Days__c;
            act.OPD_Start_Timing__c= opp.OPD_Start_Timing__c;
            act.OPD_End_Timing__c= opp.OPD_End_Timing__c;
            act.LSQ_Imported__c=true;
            act.LSQ_ExtID__c=opp.LSQ_ExtID__c;
                     
            Contact cnt=new Contact();
            cnt.lastName=opp.name;
            cnt.Email=opp.Email__c;
            cnt.Phone=opp.Phone__c;
            cnt.Salutation='Dr.';
            cnt.LSQ_Imported__c=true;
            cnt.LSQ_ExtID__c=opp.LSQ_ExtID__c; 
            
            
            Account accountReference = new Account();
            accountReference.LSQ_ExtID__c=opp.LSQ_ExtID__c;                
            opp.Account = accountReference;
            cnt.Account=accountReference;           
            accountList.add(act);
            contactList.add(cnt);
            system.debug('The account and contact  list :::');        
            oppList.add(opp);
            system.debug('The oppList list :::'+oppList);            
                
        }
        insertList.addAll(accountList);
        insertList.addAll(contactList);
            Database.SaveResult[] resultsInsert = Database.insert(insertList, true);        
        // Check results.
        for (Integer i = 0; i < resultsInsert.size(); i++) {
            if (resultsInsert[i].isSuccess()) {
            System.debug('Successfully created ID: '
                  + resultsInsert[i].getId());
            } else {
            System.debug('Error: could not create sobject '
                  + 'for array element ' + i + '.');
            System.debug('   The error reported was: '
                  + resultsInsert[i].getErrors()[0].getMessage() + '\n');
            }
        }
       
         Database.SaveResult[] resultsUpdate = Database.update(oppList, true);
        
        // Check results.
        for (Integer i = 0; i < resultsUpdate.size(); i++) {
            if (resultsUpdate[i].isSuccess()) {
            System.debug('Successfully updated ID: '
                  + resultsUpdate[i].getId());
            } else {
            System.debug('Error: could not update sobject '
                  + 'for array element ' + i + '.');
            System.debug('   The error reported was: '
                  + resultsUpdate[i].getErrors()[0].getMessage() + '\n');
            }
        }
        System.debug('Exit Execute():::');
        
    }
    
    public void finish(Database.BatchableContext BC){
        //Do Nothing
    }
    
}