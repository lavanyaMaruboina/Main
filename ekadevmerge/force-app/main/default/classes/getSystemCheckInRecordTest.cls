@isTest()
public class getSystemCheckInRecordTest {
    @isTest()
    public static void systemCheckInTest(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Field Sales Team' LIMIT 1]; 	
        
        User usr = new User(LastName = 'User1',
                            FirstName='Testing',
                            Alias = 'tuser',
                            Email = 'testing.user1@abc.com',
                            Username = 'testing.user1@abc.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        system.runAs(usr){
            
            System_Check_In__c sys = new System_Check_In__c();
            sys.Check_In_Time__c = system.today();
            sys.User__c = UserInfo.getUserId();
            
            insert sys;
            
            System_Check_In__c todayCheckInRecord = getSystemCheckInRecord.getCurrentUserDailyCheckInId();
            
            Id uId = [select id from user where Alias = 'tuser'].Id;
            Id recordId = [select Id,Check_In_Time__c,Check_Out_Time__c from System_Check_In__c 
                           where User__c =: uId
                           and CreatedDate = TODAY limit 1].Id;
            system.assertEquals(todayCheckInRecord.Id, recordId, 'id Mismatched');
        }
    }    
}