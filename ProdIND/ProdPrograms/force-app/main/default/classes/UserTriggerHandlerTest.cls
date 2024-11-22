@isTest
public class UserTriggerHandlerTest {
    @isTest
    public static void userTrigger_success()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'ntest', Email='parimal.shinde@nanostuffs.com',
                          EmailEncodingKey='UTF-8', LastName='Test Test User', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='vishal@kahuuuu.com',MobilePhone = '9089078967');
        Insert u;
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'IBL_Incident_Management_PS_Business_Executiv'].Id;
       Id permissionSetIdSSO = [SELECT Id FROM PermissionSet WHERE Name =:System.label.SSO_Permission_Set].Id;
        PermissionSetAssignment pr = new  PermissionSetAssignment();
        pr.PermissionSetId = permissionSetId;
        pr.AssigneeId = u.Id;
        //Insert pr;
        Test.startTest();
        Database.SaveResult saveResultList = Database.insert(u, false);
        Database.SaveResult updateResult = Database.update(u, false);
        Test.stopTest();
        //Assert
        System.assert(updateResult.isSuccess());
    }
}