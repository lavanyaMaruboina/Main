@isTest
public class SendForwardedUsersNotificationBatchTest {
    
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test1_userprod123@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            Account acc  = new Account ();
            acc.Name ='Test Account';
            insert acc;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);   
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.PassengerVehicles;
            opp.Sanction_Status__c = System.Label.nonStp;  
            opp.AccountId = acc.Id;
            oppList.add(opp);
            
            insert oppList;
            
            List<CAM__c> lstCAM= new List<CAM__c>();
            CAM__c cam1 = new CAM__c();            
            cam1.Status__c = 'Hold';
            cam1.Is_Hold__c = true;
            cam1.Trigger_Deviations__c = true;       
            cam1.Loan_Application__c = opp.Id;
            cam1.Action_Taken__c = false;
            cam1.Deviation_Created_Date__c = System.today().addDays(-30);
            lstCAM.add(cam1);
            
            insert lstCAM;
            
            Deviation__c deviation1 = new Deviation__c(Role__c = 'testrole',Approval_Status__c = 'Approved',EmployeeID__c = '1234567EMP',Proposal_Status__c = 'Hold',Parent_CAM__c = cam1.Id);
            insert deviation1;
            List<Deviation__c> deviationList = new List<Deviation__c> {deviation1};
                
                recordType rtp1 = [SELECT Id,name from recordtype where Name='Forward log' limit 1];
            
            Proposal_Approval_Log__c pa1 = new Proposal_Approval_Log__c();
            pa1.Deviation_Id__c = deviation1.Id;
            pa1.Parent_CAM__c = cam1.Id;
            pa1.Approval_Status__c = 'proaprv';
            pa1.Forward_Remark__c = 'testremark';
            pa1.Forwarded_Role__c = 'SCM';
            pa1.Forwarded_By__c = 'BE';
            pa1.Forwarded_Employee__c = u.Id;
            pa1.RecordTypeId = rtp1.Id;
            insert pa1;
            
            Proposal_Approval_Log__c pa2 = new Proposal_Approval_Log__c();
            pa2.Deviation_Id__c = deviation1.Id;
            pa2.Parent_CAM__c = cam1.Id;
            pa2.Approval_Status__c = 'proaprv';
            pa2.Forward_Remark__c = 'testremark';
            pa2.Forwarded_Role__c = 'NPH';
            pa2.Forwarded_By__c = 'SCM';
            pa2.Forwarded_Employee__c = u.Id;
            pa2.RecordTypeId = rtp1.Id;
            insert pa2;
        }
    }
    
    @isTest
    public static void SendForwardedUsersNotificationBatchTest() {
        try
        {            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                recordType rtp1 = [SELECT Id,name from recordtype where Name='Forward log' limit 1];
                List<Proposal_Approval_Log__c> ApprovalLogList = [SELECT Deviation_Id__c,Approval_Status__c,Parent_CAM__c,Forwarded_Employee__c,RecordType.Name FROM Proposal_Approval_Log__c ];
                
                SendForwardedUsersNotificationBatch obj = new SendForwardedUsersNotificationBatch(true);
                DataBase.executeBatch(obj); 
                String chron = '0 0 23 * * ?';
                system.schedule('Test Sched', chron, obj);
                System.assertEquals('Forward log',ApprovalLogList[0].RecordType.Name);
                System.assertEquals('proaprv', ApprovalLogList[0].Approval_Status__c);
                
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }       
    }
    
    
    
    
    @isTest
    public static void SendForwardedUsersNotificationBatchTest2() {
        try
        {            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                
                List<Opportunity> oppList = [select Id,Vehicle_Type__c,Product_Type__c,Sanction_Status__c,AccountId FROM Opportunity];
                List<Proposal_Approval_Log__c> ApprovalLogList = [SELECT Deviation_Id__c,Approval_Status__c,Parent_CAM__c,Forwarded_Employee__c,RecordType.Name FROM Proposal_Approval_Log__c ];
                
                for(Opportunity op :oppList){
                    op.Product_Type__c= 'Two Wheeler';
                }
                update oppList;
                SendForwardedUsersNotificationBatch obj = new SendForwardedUsersNotificationBatch(false);
                DataBase.executeBatch(obj); 
                String chron = '0 0 23 * * ?';
                system.schedule('Test Sched', chron, obj);
                System.assertEquals('Forward log',ApprovalLogList[0].RecordType.Name);
                System.assertEquals('proaprv', ApprovalLogList[0].Approval_Status__c);
                
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }       
    }
    
    @istest
    public static void SendForwardedUsersNotificationBatch_success(){    
        User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];  
        System.runAs(u) {
            set<id> setid = new set<id>();
            List<user> userList = [SELECT Id,username FROM user Limit 10000];
            for(User us : userList){
                setid.add(us.Id);
            }
            SendForwardedUsersNotificationBatch obj = new SendForwardedUsersNotificationBatch(true,setid);
        }
    }
}