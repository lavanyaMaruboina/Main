/**
* @author Khushiram.
* @company Persistent Systems
* @description A  Test class for the IND_CreditProcessing class
* Inputs: None
* History:
*/
@isTest(seeAllData = false)
public class IND_CreditProcessingTest {
    @testSetup 
    public static void setup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod2134@indusbank.com');//Rohan
        insert u;
        System.runAs(u) 
        {
            Account testAccount = TestDataUtility.createTestAccount(true);
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName='Credit Processing';
            opp.Sub_Stage__c = 'Credit Assessment';    
            opp.Sanction_Status__c ='Non-STP';
            
            insert opp;
            
            Stage_Profile_visibility_Custom_Setting__c profileCS = new Stage_Profile_visibility_Custom_Setting__c(
                Loan_Application_Stage__c = 'Credit Processing', Active__c =true, SetupOwnerId = userinfo.getProfileId());
            upsert profileCS;
        }
    }
    
    @istest 
    public static void getCreditProcessTabsForNewTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2134@indusbank.com' AND IsActive = true LIMIT 1]; //Rohan
        System.runAs(u) 
        {
            try{
                Opportunity opp = [select id,Vehicle_Type__c,Product_Type__c,Sanction_Status__c,Sub_Stage__c from Opportunity where name='Opportunity'];
                opp.Sub_Stage__c = 'Credit Assessment';
                opp.Vehicle_Type__c = 'New';
                opp.Sanction_Status__c ='Non-STP';
                opp.Product_Type__c = 'Passenger Vehicles';            
                update opp;
                Test.startTest();
                IND_CreditProcessing.CreditProcessingTabs response = IND_CreditProcessing.getCreditProcessTabs(opp.id); 
                //      IND_CreditProcessing.CreditProcessingTabs updateStageResponse = IND_CreditProcessing.updateStage(opp.id); 
                Test.stopTest();      
                system.assertEquals(response.creditassesment , true);
            }catch(Exception e){
                System.debug('Script-thrown exception');
            }
        }
    }
    
    @istest 
    public static void getCreditProcessTabsForNewTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2134@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [select id,Vehicle_Type__c,Product_Type__c,Sanction_Status__c,Sub_Stage__c from Opportunity where name='Opportunity'];
                opp.Sub_Stage__c = 'Credit Assessment';
                opp.Vehicle_Type__c = 'Used';
                opp.Product_Type__c = 'Passenger Vehicles';
                opp.Sanction_Status__c ='Non-STP';                        
                update opp;
                Test.startTest();
                IND_CreditProcessing.CreditProcessingTabs response = IND_CreditProcessing.getCreditProcessTabs(opp.id); 
                //     IND_CreditProcessing.CreditProcessingTabs updateStageResponse = IND_CreditProcessing.updateStage(opp.id); 
                Test.stopTest();  
                system.assertEquals(response.creditassesment , true);
            }catch(Exception e){
                System.debug('Script-thrown exception');
            }
        }
    }
    
    
    @istest 
    public static void getCreditProcessTabsForUsedTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2134@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [select id,Vehicle_Type__c,Product_Type__c,Sanction_Status__c,Sub_Stage__c from Opportunity where name='Opportunity'];
                opp.Sub_Stage__c = 'Credit Assessment';
                opp.Vehicle_Type__c = 'Used';
                opp.Sanction_Status__c ='Non-STP';
                opp.Product_Type__c = 'Passenger Vehicles';            
                update opp;
                Test.startTest();
                IND_CreditProcessing.CreditProcessingTabs response = IND_CreditProcessing.getCreditProcessTabs(opp.id); 
                //    IND_CreditProcessing.CreditProcessingTabs updateStageResponse = IND_CreditProcessing.updateStage(opp.id); 
                Test.stopTest();     
                system.assertEquals(response.creditassesment , true);
            }catch(Exception e){
                System.debug('Script-thrown exception');
            }
        }
    }
    
    @istest 
    public static void getCreditProcessTabsForUsedTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2134@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [select id,Vehicle_Type__c,Product_Type__c,Sanction_Status__c,Sub_Stage__c from Opportunity where name='Opportunity'];
                opp.Sub_Stage__c = 'View Application Details';
                opp.Vehicle_Type__c = 'Used';
                opp.Sanction_Status__c ='Non-STP';
                opp.Product_Type__c = 'Passenger Vehicles';            
                update opp;
                Test.startTest();
                //      IND_CreditProcessing.CreditProcessingTabs response = IND_CreditProcessing.updateStage(opp.id); 
                
                Test.stopTest();            
                //     system.assertEquals(response.cibil, true);
            }catch(Exception e){
                System.debug('Script-thrown exception');
            }
        }
    }
    
    @isTest
    public static void navigateToViewApplicationDataTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2134@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
                insert optg1;
                
                Test.startTest();
                IND_CreditProcessing.navigateToViewApplicationData(optg1.Id);
                IND_CreditProcessing.navigateToViewApplicationData(null);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
    
    @isTest
    public static void getCreditProcessTabsTest1(){
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
        
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opfv1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'testveh';
                insert vg3;
        
                Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
             //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
        
                Test.startTest();
                      IND_CreditProcessing.getCreditProcessTabs(opfv1.Id);
                Test.stopTest();
    }
    
     @isTest
    public static void getCreditProcessTabsTest2(){
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
        
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = System.Label.FI_Accepted;
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opfv1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'testveh';
                insert vg3;
        
                Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
             //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
        
                Test.startTest();
                      IND_CreditProcessing.getCreditProcessTabs(opfv1.Id);
                Test.stopTest();
    }
    
    @isTest
    public static void getCreditProcessTabsTest3(){
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                opfv1.Vehicle_Type__c = 'New';
                opfv1.Product_Type__c = 'Passenger Vehicles';
                opfv1.Sanction_Status__c = 'Non-STP';
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
        
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = System.Label.FI_Accepted;
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opfv1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'testveh';
                insert vg3;
        
                Webapp_Tab_Settings__mdt wmdt = new Webapp_Tab_Settings__mdt();
                wmdt.Sub_Stage__c = System.label.Field_Investigation;
                wmdt.Stage__c = Label.Credit_Processing;
                wmdt.Vehicle_Category__c = opfv1.Vehicle_Type__c;
                wmdt.Product_Type__c = opfv1.Product_Type__c;
                wmdt.Sanction_Status__c = opfv1.Sanction_Status__c;
                
        
                Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
             //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
        
                Test.startTest();
                      IND_CreditProcessing.getCreditProcessTabs(opfv1.Id);
                Test.stopTest();
    }
    
    @isTest
    public static void getCreditProcessTabsTest4(){
        try{
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                opfv1.Vehicle_Type__c = 'New';
                opfv1.Product_Type__c = 'Passenger Vehicles';
                opfv1.Sanction_Status__c = 'Non-STP';
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
        
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = System.Label.FI_Accepted;
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opfv1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'testveh';
                insert vg3;
        
                Webapp_Tab_Settings__mdt wmdt = new Webapp_Tab_Settings__mdt();
                wmdt.Sub_Stage__c = System.label.Field_Investigation;
                wmdt.Stage__c = Label.Credit_Processing;
                wmdt.Vehicle_Category__c = opfv1.Vehicle_Type__c;
                wmdt.Product_Type__c = opfv1.Product_Type__c;
                wmdt.Sanction_Status__c = opfv1.Sanction_Status__c;
                wmdt.Tab_Sequence__c = '10';
                
        
                Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
             //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
        
                Test.startTest();
                      IND_CreditProcessing.getCreditProcessTabs(opfv1.Id);
                      IND_CreditProcessing.getCreditProcessTabs(null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCreditProcessTabsTest5(){
        try{
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                opfv1.Vehicle_Type__c = 'New';
                opfv1.Product_Type__c = 'Passenger Vehicles';
                opfv1.LeadSource='D2C';
                opfv1.Is_Pre_Approved__c=true;
                opfv1.Sanction_Status__c = 'STP';

            
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
        
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = System.Label.FI_Accepted;
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opfv1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'testveh';
                insert vg3;
        
                Webapp_Tab_Settings__mdt wmdt = new Webapp_Tab_Settings__mdt();
                wmdt.Sub_Stage__c = System.label.Field_Investigation;
                wmdt.Stage__c = Label.Credit_Processing;
                wmdt.Vehicle_Category__c = opfv1.Vehicle_Type__c;
                wmdt.Product_Type__c = opfv1.Product_Type__c;
                wmdt.Sanction_Status__c = opfv1.Sanction_Status__c;
                wmdt.Tab_Sequence__c = '10';
                
        
                Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
             //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
        
                Test.startTest();
                      IND_CreditProcessing.getCreditProcessTabs(opfv1.Id);
                      IND_CreditProcessing.getCreditProcessTabs(null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCreditProcessTabsTest6(){
        try{
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                opfv1.Vehicle_Type__c = 'New';
                opfv1.Product_Type__c = 'Passenger Vehicles';
                opfv1.LeadSource='D2C';
                opfv1.Is_Pre_Approved__c=false;
                opfv1.Sanction_Status__c = 'STP';

            
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
        
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = System.Label.FI_Accepted;
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opfv1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'testveh';
                insert vg3;
        
                Webapp_Tab_Settings__mdt wmdt = new Webapp_Tab_Settings__mdt();
                wmdt.Sub_Stage__c = System.label.Field_Investigation;
                wmdt.Stage__c = Label.Credit_Processing;
                wmdt.Vehicle_Category__c = opfv1.Vehicle_Type__c;
                wmdt.Product_Type__c = opfv1.Product_Type__c;
                wmdt.Sanction_Status__c = opfv1.Sanction_Status__c;
                wmdt.Tab_Sequence__c = '10';
                
        
                Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
             //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
        
                Test.startTest();
                      IND_CreditProcessing.getCreditProcessTabs(opfv1.Id);
                      IND_CreditProcessing.getCreditProcessTabs(null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getCreditProcessTabsTest7(){
        try{
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                opfv1.Vehicle_Type__c = 'New';
                opfv1.Product_Type__c = 'Passenger Vehicles';
                opfv1.LeadSource='D2C';
                opfv1.Is_Pre_Approved__c=true;
                opfv1.Sanction_Status__c = 'Non-STP';

            
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                apfv1.In_Active_Applicant__c = false;
                insert apfv1;
        
                case cs3 = new case();
                cs3.Loan_Application__c = opfv1.Id;
                cs3.Applicant__c = apfv1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = System.Label.FI_Accepted;
                cs3.Origin = 'Web';
                cs3.Type = System.Label.Case_Current_Residence_FI_Type;
                insert cs3; 
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opfv1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'testveh';
                insert vg3;
        
                Webapp_Tab_Settings__mdt wmdt = new Webapp_Tab_Settings__mdt();
                wmdt.Sub_Stage__c = System.label.Field_Investigation;
                wmdt.Stage__c = Label.Credit_Processing;
                wmdt.Vehicle_Category__c = opfv1.Vehicle_Type__c;
                wmdt.Product_Type__c = opfv1.Product_Type__c;
                wmdt.Sanction_Status__c = opfv1.Sanction_Status__c;
                wmdt.Tab_Sequence__c = '10';
                
        
                Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
             //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
        
                Test.startTest();
                      IND_CreditProcessing.getCreditProcessTabs(opfv1.Id);
                      IND_CreditProcessing.getCreditProcessTabs(null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}