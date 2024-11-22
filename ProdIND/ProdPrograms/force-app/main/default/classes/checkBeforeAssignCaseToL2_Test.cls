@isTest
public class checkBeforeAssignCaseToL2_Test {
    @isTest
    public static void checkCaseStatusTest() {
        try{
            Account testAccount = new Account(Name='Test Account');
            insert testAccount;
            
            List<Opportunity> opp = new List<Opportunity>();
            for(Integer i=0;i<1;i++) {
                opp.add(new Opportunity(Name= 'Opportunity'+i,
                                        StageName='Loan Initiation',
                                        CloseDate=System.today().addMonths(1),
                                        AccountId= testAccount.Id));
            }
            insert opp;
            
            
            List<Case> doc = new List<Case>();     
            Case updateCase = new Case(CMU_Accept__c = false, Loan_Application__c = opp[0].id, Status = 'In Progress - L1');
            insert updateCase;
            
            ApexPages.currentPage().getParameters().put('id', [select id from case limit 1].Id);
            checkBeforeAssignCaseToL2Class cobj = new checkBeforeAssignCaseToL2Class();
            
            updateCase.status = 'New';
            update updateCase;
            checkBeforeAssignCaseToL2Class cobj1 = new checkBeforeAssignCaseToL2Class();
        }
        catch(Exception e){
            system.debug('e--'+e.getMessage());
        }
        
    }
}