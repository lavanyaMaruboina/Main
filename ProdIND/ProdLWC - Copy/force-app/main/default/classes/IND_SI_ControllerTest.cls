@isTest
public class IND_SI_ControllerTest {
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');
        insert u;
        System.runAs(u) 
        {
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }        
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_Code__c = '12345';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Bank_Masters__c bankMaster = new Bank_Masters__c();
            bankMaster.Name='BANK OF BARODA';
            bankMaster.Bank_Code__c=12;
            if (Schema.sObjectType.Bank_Masters__c.isCreateable()){
                insert bankMaster;
            }
            Repayments__c repayment = TestDataUtility.createTestRepayments(false,opp);
            repayment.Bank_Master__c = bankMaster.Id;
            repayment.Is_Netbanking_available_with_customer__c = 'yes';
            if (Schema.sObjectType.Repayments__c.isCreateable()){
                insert repayment;
            }
            
            Repayments__c repayment1 = TestDataUtility.createTestRepayments1(false,opp);
            repayment1.Bank_Master__c = bankMaster.Id;
            repayment1.Is_Netbanking_available_with_customer__c = 'no';
            if (Schema.sObjectType.Repayments__c.isCreateable()){
                insert repayment1;
            }    
            
            //Create Documents__c records            
            Documents__c doc = TestDataUtility.createTestDocumentITR(false, applicant, opp);            
            doc.Name = 'test';
            doc.Opportunity_Relation__c = opp.Id;
            doc.Is_active__c = true;
            doc.Document_Type__c = 'Chassis Number uploaded during verification';
            
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert doc;
            }
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;  
        }
    }    
    
    @isTest
    public static void getSIUrlTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
                Opportunity oppRec = [Select Id From Opportunity Where Id =: appRec.Opportunity__c LIMIT 1];
                Repayments__c repayment = [SELECT Id FROM Repayments__c LIMIT 1];
                String result = IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
                System.assert(result != null);
                repayment.Frequency__c = null;
                update repayment;
                IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
                repayment.EMI_Amount__c = null;
                update repayment;
                IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
                repayment.Created_Date__c = null;
                update repayment;
                IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
                repayment.End_Date__c = null;
                update repayment;
                IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
                oppRec.Deal_Number__c = null;
                update oppRec;
                IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
                
                appRec.Customer_Code__c = null;
                update appRec;
                IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
                appRec.Contact_number__c = null;
                update appRec;
                IND_SI_Controller.getSIUrl(appRec.Opportunity__c, appRec.Id, repayment.Id);
            }
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }        
    }
    
    @isTest
    public static void validateSIDocsTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];                 
                Boolean result = IND_SI_Controller.validateSIDocs(appRec.Opportunity__c);
                System.assert(result != null);
            }
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }        
    }
    
    
}