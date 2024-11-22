@isTest
public with sharing class SendPendingApprovalNotificationBatchTest {
    
    @testSetup 
    static void testDataSetup() 
        
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            Account acc = new Account();
            acc.Name = 'test account';
            insert acc;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            opp.StageName = 'Credit Processing';
            opp.Sub_Stage__c = 'CAM and Approval Log';
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.PassengerVehicles;
            opp.Sanction_Status__c = System.Label.nonStp;   
            opp.AccountId = acc.Id;
            oppList.add(opp);        
            
            Opportunity opp1 = TestDataUtility.createTestOpportunityForOcr(false);
            opp1.StageName = 'Credit Processing';
            opp1.Sub_Stage__c = 'CAM and Approval Log';
            opp1.Is_Mobile_Journey_Completed__c = true;
            opp1.Vehicle_Type__c = System.Label.used;
            opp1.Product_Type__c = System.Label.TwoWheeler;
            opp1.Sanction_Status__c = System.Label.nonStp;  
            oppList.add(opp1);
            
            Opportunity opp2 = TestDataUtility.createTestOpportunityForOcr(false);
            opp2.StageName = 'Credit Processing';
            opp2.Sub_Stage__c = 'CAM and Approval Log';
            opp2.Is_Mobile_Journey_Completed__c = true;
            opp2.Vehicle_Type__c = System.Label.used;
            opp2.Product_Type__c = System.Label.PassengerVehicles;
            opp2.Sanction_Status__c = System.Label.nonStp;
            opp2.LeadSource = 'D2C';
            opp2.Is_Pre_Approved__c = true;
            opp2.AccountId = acc.Id;
            oppList.add(opp2);            
            insert oppList;
            
            List<CAM__c> lstCAM= new List<CAM__c>();
            CAM__c cam1 = new CAM__c();            
            cam1.Status__c = 'Hold';
            cam1.Is_Hold__c = true;
            cam1.Trigger_Deviations__c = TRUE;       
            cam1.Loan_Application__c = opp.Id;
            cam1.Action_Taken__c = false;
            cam1.Deviation_Created_Date__c = System.today().addDays(-30);
            
            CAM__c cam2 = new CAM__c();            
            cam2.Status__c = 'Hold';
            cam2.Is_Hold__c = true;
            cam2.Trigger_Deviations__c = true;       
            cam2.Loan_Application__c = opp1.Id;
            cam2.Action_Taken__c = false;
            cam2.Deviation_Created_Date__c = System.today().addDays(-30);
            
            CAM__c cam3 = new CAM__c();            
            cam3.Status__c = 'Hold';
            cam3.Is_Hold__c = true;
            cam3.Trigger_Deviations__c = true;       
            cam3.Loan_Application__c = opp1.Id;
            cam3.Action_Taken__c = false;
            cam3.Deviation_Created_Date__c = System.today().addDays(-30);
            
            lstCAM.add(cam1);
            lstCAM.add(cam2);
            lstCAM.add(cam3);
            insert lstCAM;
            
            Deviation__c deviation1 = new Deviation__c(Role__c = 'NPH',Approval_Status__c = 'Hold',EmployeeID__c = u.Id,Proposal_Status__c = 'Hold',Parent_CAM__c = cam1.Id);
            insert deviation1;
            Deviation__c deviation2 = new Deviation__c(Role__c = 'BH',Approval_Status__c = 'Hold',EmployeeID__c = u.Id,Proposal_Status__c = 'Hold',Parent_CAM__c = cam2.Id);
            insert deviation2;
			Deviation__c deviation3 = new Deviation__c(Role__c = 'BH',Approval_Status__c = 'Hold',EmployeeID__c = u.Id,Proposal_Status__c = 'Hold',Parent_CAM__c = cam3.Id);
            insert deviation3;
            List<Deviation__c> deviationList = new List<Deviation__c> {deviation1,deviation2,deviation3};
                }
    }
    
    
    @isTest
    public static void SendPendingApprovalNotificationBatchTest() {
        try
        {            
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<Opportunity> oppList = [SELECT Id, Sub_Stage__c, Is_Mobile_Journey_Completed__c,Vehicle_Type__c,Product_Type__c,Sanction_Status__c FROM Opportunity];
                List<CAM__c> lstCAM= [select Id,Status__c,Is_Hold__c,Trigger_Deviations__c,Loan_Application__c,Deviation_Created_Date__c FROM CAM__c];
                List<Deviation__c> deviationList = [SELECT id,Approval_Status__c,EmployeeID__c,Proposal_Status__c,Parent_CAM__c FROM Deviation__c];
                // Act
                SendPendingApprovalNotificationBatch obj = new SendPendingApprovalNotificationBatch(false);
                DataBase.executeBatch(obj);
                String chron = '0 0 23 * * ?';        
                system.schedule('Test Sched', chron, obj);
                // Assert
                system.assertEquals('Hold', deviationList[0].Approval_Status__c);
                System.assertEquals(3,deviationList.size());
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }                        
    }
    @isTest
    public static void SendPendingApprovalNotificationBatchTest2() {
        try
        {            
            Test.startTest();
            // Arrange 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<Opportunity> oppList = [SELECT Id, Sub_Stage__c, Is_Mobile_Journey_Completed__c,Vehicle_Type__c,Product_Type__c,Sanction_Status__c FROM Opportunity];
                for(Opportunity op : oppList){
                    op.Product_Type__c ='Passenger Vehicles';   
                }
                update oppList;
                List<CAM__c> lstCAM= [select Id,Status__c,Is_Hold__c,Trigger_Deviations__c,Loan_Application__c,Deviation_Created_Date__c FROM CAM__c];
                List<Deviation__c> deviationList = [SELECT id,Approval_Status__c,EmployeeID__c,Proposal_Status__c,Parent_CAM__c FROM Deviation__c];
                // Act
                SendPendingApprovalNotificationBatch obj = new SendPendingApprovalNotificationBatch(true);
                DataBase.executeBatch(obj);
                String chron = '0 0 23 * * ?';        
                system.schedule('Test Sched', chron, obj);
                // Assert
                system.assertEquals('Hold', deviationList[0].Approval_Status__c);
                System.assertEquals(3,deviationList.size());
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }                        
    }
}