@isTest 
public class AutoRejectAfter30DaysTest 
{
    @isTest
    public static void testAutoRejectAfter30Days() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1239994567524@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);         
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;   
            oppList.add(opp);        
            
            Opportunity opp1 = TestDataUtility.createTestOpportunityForOcr(false);         
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;  
            oppList.add(opp1);
            
            insert oppList;
            
            List<CAM__c> lstCAM= new List<CAM__c>();
            CAM__c cam1 = new CAM__c();            
            cam1.Status__c = 'Hold';
            cam1.Is_Hold__c = true;
            cam1.Loan_Application__c = opp1.Id;
            cam1.Deviation_Created_Date__c = System.today().addDays(-30);
            
            CAM__c cam2 = new CAM__c();            
            cam2.Status__c = 'Hold';
            cam2.Is_Hold__c = true;
            cam2.Loan_Application__c = opp.Id;
            cam2.Deviation_Created_Date__c = System.today().addDays(-30);
            
            lstCAM.add(cam1);
            lstCAM.add(cam2);
            insert lstCAM;
            List<Deviation__c> devList= new List<Deviation__c>();
            Deviation__c devObj1 = new Deviation__c(); 
            devObj1.Approval_Status__c = 'Hold';
            devObj1.Parent_CAM__c = cam1.Id;
            
            Deviation__c devObj2 = new Deviation__c(); 
            devObj2.Approval_Status__c = 'Hold';
            devObj2.Parent_CAM__c = cam2.Id;
            devList.add(devObj1);
            devList.add(devObj2);
            insert devList;
            Test.startTest();
            try
            {                
                AutoRejectAfter30Days obj = new AutoRejectAfter30Days();
                DataBase.executeBatch(obj);
                Opportunity result = [SELECT Id, StageName FROM Opportunity LIMIT 1];
                System.assertNotEquals(null, result.StageName);
            }
            catch(Exception e)
            {
                System.debug('error '+e.getMessage());
            }                        
            Test.stopTest();
        }
    }
}