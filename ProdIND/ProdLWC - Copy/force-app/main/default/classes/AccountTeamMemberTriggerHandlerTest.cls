@isTest
public class AccountTeamMemberTriggerHandlerTest {

    @isTest
    private static void testBeforeInsert() {
        TriggerSwitch__c triggerSwitch = TestDataUtility.getTrigerSwitchData(false);
        triggerSwitch.Name = 'Trigger_For_AccountTeamMember';
        insert triggerSwitch;
        
        insert new Account(name='test acc', State__c='ASSAM');
        
        AccountTeamMember atm = TestDataUtility.createAccountTeamMember(true, 'CVO');
    }
    
}