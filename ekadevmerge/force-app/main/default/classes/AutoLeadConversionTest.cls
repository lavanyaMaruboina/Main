@isTest  	  
public class AutoLeadConversionTest {
    @testSetup
    static void testLeadSetUp() {          
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Field Sales Team' LIMIT 1]; 	
        
        User usr = new User(LastName = 'User3',
                            FirstName='Testing',
                            Alias = 'tuser',
                            Email = 'testing.user3@abc.com',
                            Username = 'testing.user3@abc.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        system.runAs(usr){
            
            Lead objLead = new Lead();
            objLead.FirstName = 'Dr. Pritam';
            objLead.LastName = 'Das';
            objLead.Company = 'Das Medical';  
            objLead.Gender__c = 'Male';
            objLead.Phone = '7890732156';
            objLead.LeadSource = 'Website Leads';
            objLead.Specialization__c = 'ENT';
            objLead.Number_of_Staff_in_Clinic__c = 5;
            objLead.Daily_OPD_Vol__c = 20;
            objLead.OPD_Days__c = 'Mon';
            objLead.OPD_Start_Timing__c = time.newInstance(10, 30,00,00);
            objLead.OPD_End_Timing__c = time.newInstance(11, 30,00,00);
            objLead.Infra_in_clinic__c = 'Internet';
            objLead.Other_Apps_Used__c = 'DocOn';
            objLead.Street = 'Olaichanditala';
            objLead.City = 'Hooghly';
            objLead.State = 'West Bengal';
            objLead.Status = 'Qualified';
            insert objLead;  
        } 
    }
    
    @isTest static void testMethod1() {       
        
        Test.startTest();
        User u = [select id from user where name = 'Testing User3'];
        system.runAs(u){
            list<Id> leadId = new list<Id>();
            for(lead l:[select id from lead where name = 'Dr. Pritam Das']){
                leadId.add(l.Id);
            }
            AutoLeadConversion.bulkLeadConvert(leadId);
            String leadName = [select name from lead where name = 'Dr. Pritam Das'].Name;
            system.assertEquals('Dr. Pritam Das',leadName, 'Data Mismatch');
        }
        Test.stopTest();
    }
}