@isTest()
public class CalculateDailyTraveledDistanceTest {
    
    @isTest()
    public static void distanceCalculateTest(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Field Sales Team' LIMIT 1]; 	
        
        User usr = new User(LastName = 'User2',
                            FirstName='Testing',
                            Alias = 'tuser',
                            Email = 'testing.user2@abc.com',
                            Username = 'testing.user2@abc.com',
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
            sys.Check_In_Geolocation__Latitude__s =  22.6528 ;
            sys.Check_In_Geolocation__Longitude__s =  88.3228 ;
            sys.Check_Out_Geolocation__Latitude__s = 24.6528 ;
            sys.Check_Out_Geolocation__Longitude__s = 90.3228 ;
            sys.User_Profile__c = 'Field Sales Team';
            insert sys;
            
            Account acc = new account();
            acc.name = 'test acc';
            insert acc;
            
            opportunity opp = new opportunity();
            opp.Name = 'test opp';
            opp.AccountId = [select id from account where name = 'test acc' limit 1].id;
            opp.CloseDate = system.today().adddays(365);
            opp.StageName = 'Connect';
            opp.Activity_Date_Time__c  = system.today();
            opp.Notes__c = 'test';
            insert opp;
            
            Check_in_out__c ck = new Check_in_out__c();
            ck.Check_In_Geolocation__Latitude__s = 22.6528 ;
            ck.Check_In_Geolocation__Longitude__s =  88.3228 ;
            ck.Opportunity__c = [select id from opportunity where name = 'test opp' limit 1].id;
            insert ck;
            
            test.startTest();
            Id batchJobId = Database.executeBatch(new CalculateDailyTraveledDistance());
            test.stopTest();
            
        }
    } 
    
}