public class DSA_Batch_DisbursedLead implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        string FTQuery='SELECT Id, Name, Referrer_Ben_Code__c, Referrer_Name__c, Loan_Application__c  FROM Final_Term__c Where Referrer_Ben_Code__c !=null';
        return Database.getQueryLocator(FTQuery);
    }
    public void execute(Database.BatchableContext bc, List<Final_Term__c> LoanData){
        // process each batch of records
        Set<String> Bencode =new Set<String>();
        Map<Id,String> OppANDBencode =new Map<Id,String>();
        List<OpportunityShare> lstOpp = new List<OpportunityShare>();
        try{
            for(Final_Term__c ft : LoanData){
                Bencode.add(ft.Referrer_Ben_Code__c);
                OppANDBencode.put(ft.Loan_Application__c,ft.Referrer_Ben_Code__c);
            }
            system.debug('OppANDBencode-->'+JSON.serializePretty(OppANDBencode));
            List<User> DSAUser = [Select Id, name, employeenumber,Profile.Name from User where employeenumber IN: Bencode AND Profile.Name='DSA Community User'];
            system.debug('DSAUser-->'+JSON.serializePretty(DSAUser));
            for(Id loanid: OppANDBencode.keySet()){
                for(User u : DSAUser){
                    if(OppANDBencode.get(loanid) == u.employeenumber){
                        OpportunityShare ObjOppSh = new OpportunityShare();
                        ObjOppSh.OpportunityId = loanid;
                        ObjOppSh.UserOrGroupId = u.Id;
                        ObjOppSh.OpportunityAccessLevel = 'Edit';
                        ObjOppSh.RowCause= 'Manual';
                        lstOpp.add(ObjOppSh);
                    }
                }
            }
            
            insert lstOpp;
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('DSA_Batch_DisbursedLead', 'execute', 'Apex', e);
        }
    }
    public void finish(Database.BatchableContext bc){
        
    }
    
}