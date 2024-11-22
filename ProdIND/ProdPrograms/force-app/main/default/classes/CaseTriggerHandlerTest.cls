@isTest
public class CaseTriggerHandlerTest {
    List<Case> newCaseList = new List<Case>();
    List<Case> oldCaseList = new List<Case>();
    
    MAP<Id,Case> newCaseMap = new MAP<Id,Case>();
    MAP<Id,Case> oldCaseMap = new MAP<Id,Case>();
    
    @isTest
    public static void afterUpdateTest() {
        try{
            TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
            trgSwitch.Name = 'Trigger_For_Case';
            trgSwitch.Active__c = true;
            insert trgSwitch;
            
            Account testAccount = new Account(Name='Test Account');
            insert testAccount;
            
            List<Opportunity> opp = new List<Opportunity>();
            for(Integer i=0;i<2;i++) {
                opp.add(new Opportunity(Name= 'Opportunity'+i,
                                        StageName='Loan Initiation',
                                        CloseDate=System.today().addMonths(1),
                                        AccountId= testAccount.Id));
            }
            insert opp;
            
            List<Case> doc = new List<Case>();     
            Case updateCase = new Case(CMU_Accept__c = false, Loan_Application__c = opp[1].id, Status = 'new',Type = 'CMU Request',OwnerId=UserInfo.getUserId());
            insert updateCase;
            
            updateCase.Status = 'Closed';
            update updateCase;
            CaseTriggerHandler ch1 = new CaseTriggerHandler();
            ch1.afterUpdate();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void afterUpdateTest1() {
        try{
            TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
            trgSwitch.Name = 'Trigger_For_Case';
            trgSwitch.Active__c = true;
            insert trgSwitch;
            
            Account testAccount = new Account(Name='Test Account');
            insert testAccount;
            
            List<Opportunity> opp = new List<Opportunity>();
            for(Integer i=0;i<2;i++) {
                opp.add(new Opportunity(Name= 'Opportunity'+i,
                                        StageName='Loan Initiation',
                                        CloseDate=System.today().addMonths(1),
                                        AccountId= testAccount.Id));
            }
            insert opp;
            
            List<Case> doc = new List<Case>();     
            Case updateCase = new Case(CMU_Accept__c = false, Loan_Application__c = opp[1].id, Status = 'new',Type = 'CMU Request',OwnerId=UserInfo.getUserId());
            insert updateCase;
            
            updateCase.Status = 'Pending with Sales';
            update updateCase;
            CaseTriggerHandler ch1 = new CaseTriggerHandler();
            ch1.afterUpdate();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
}