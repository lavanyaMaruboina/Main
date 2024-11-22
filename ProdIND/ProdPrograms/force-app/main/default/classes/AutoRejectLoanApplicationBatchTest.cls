@isTest 
public class AutoRejectLoanApplicationBatchTest 
{
    @isTest
    public static void testAutoRejectLoanApplicationBatch() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1231@indusbank.com',MobilePhone = '9089078967');
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
            cam1.Proposal_Status__c = '';
            cam1.Trigger_Deviations__c = TRUE;       
            cam1.Loan_Application__c = opp1.Id;
            
            CAM__c cam2 = new CAM__c();   
            cam1.Proposal_Status__c = '';
            cam2.Trigger_Deviations__c = TRUE;       
            cam2.Loan_Application__c = opp.Id;
            
            lstCAM.add(cam1);
            lstCAM.add(cam2);
            insert lstCAM;
            
            Deviation__c deviation1 = new Deviation__c(Proposal_Status__c = 'Approved', Parent_CAM__c = cam1.Id);
            insert deviation1; 
            
            Deviation__c deviation2 = new Deviation__c(Proposal_Status__c = 'Approved', Parent_CAM__c = cam2.Id);
            insert deviation2; 
            
            Test.startTest();
            try
            {                
                AutoRejectLoanApplicationBatch obj = new AutoRejectLoanApplicationBatch();
                DataBase.executeBatch(obj);
                CAM__c cam = [SELECT Id, Proposal_Status__c FROM CAM__c LIMIT 1];
                System.assertEquals(null, cam.Proposal_Status__c);
            }
            catch(Exception e)
            {
                System.debug('error '+e.getMessage());
            }                        
            Test.stopTest();
        }
    }
}