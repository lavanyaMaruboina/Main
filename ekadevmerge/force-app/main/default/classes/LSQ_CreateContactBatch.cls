/***
 * Description : Batch class defined to create Account and Contact for LSQ uploaded opportunities
 * Author : Maantic
 * Date: 28/10/2022
 **/
public class LSQ_CreateContactBatch implements Database.Batchable<sObject>{
    
    public String queryAccount='Select id, LSQ_ExtID__c, LSQ_Imported__c, Temporary_Contact_Name__c, phone,Temporary_Contact_Email__c from account where LSQ_Imported__c=true and LSQ_ExtID__c like \'LSQG%\'';
         
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Entry start()::'+queryAccount);
        System.debug('Exit start()::');
        return Database.getQueryLocator(queryAccount);
    }
    
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('Entry Execute():::'+scope);       
        List<Contact> contactList=new List<Contact>();      
        for(Account act : scope){
                      
            Contact cnt=new Contact();
            cnt.lastName=act.Temporary_Contact_Name__c;
            cnt.Email=act.Temporary_Contact_Email__c;
            cnt.Phone=act.phone;
            cnt.Salutation='Dr.';
            cnt.LSQ_Imported__c=true;
            cnt.LSQ_ExtID__c=act.LSQ_ExtID__c; 
            cnt.AccountId=act.id;          
            contactList.add(cnt);
            system.debug('The contactList list :::'+contactList);           
                
        }
       
            Database.SaveResult[] resultsInsert = Database.insert(contactList, true);        
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
       
      
        System.debug('Exit Execute():::');
        
    }
    
    public void finish(Database.BatchableContext BC){
        //Do Nothing
    }
    
}