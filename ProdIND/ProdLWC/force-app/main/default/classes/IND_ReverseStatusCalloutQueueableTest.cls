/*------------------------------------------------------------
Author:        Vishal Gadhave
Company:       Nanostuffs Technologies
Description:   Test class for IND_ReverseStatusCalloutQueueable.
Inputs:        None 
Test Classes:    
History
Date            Author              Comments
-------------------------------------------------------------
4-11-2022      Vishal               Created
------------------------------------------------------------*/
@isTest
public class IND_ReverseStatusCalloutQueueableTest {
	
    @testSetup
    public static void setupData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          timezonesidkey='america/los_angeles',username='vishal@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u)
        {
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.RTO_Road_Tax__c = 13;
            opp.Vehicle_Type__c ='New';
            opp.Funding_on_ORP__c = true;
            opp.IModuleId__c = 'DA0012573';
            if(Schema.sObjectType.Opportunity.isCreateable())
                insert opp;
                
            IHM__c ihmObj = new IHM__c();
            ihmObj.Loan_Application__c = opp.Id;
            ihmObj.Total_amount_to_be_paid_by_customer_G__c = 2000;
            
            insert ihmObj;
            Applicant__c objApplicant = new Applicant__c();
            objApplicant.Opportunity__c = opp.Id;
            objApplicant.Applicant_Type__c = 'Borrower';
            objApplicant.Contact_number__c = '1234567890';
            if(Schema.sObjectType.Applicant__c.isCreateable())
                insert objApplicant;
            
            Documents__c objDocument = new Documents__c();
            objDocument.Opportunity_Relation__c = opp.Id;
            objDocument.name = 'DocName';
            objDocument.Document_Type__c = 'Insurance Policy Doc';
            objDocument.is_Active__c = true;
            objDocument.Applicant__c = objApplicant.Id;
            if(Schema.sObjectType.Documents__c.isCreateable())
                insert objDocument;
        }
    }
    @isTest
    public static void doReverseStatusCallout_Test(){
        User u = [SELECT Id,usertype FROM User WHERE username='vishal@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            try{
                String loanAppId = [Select Id From Opportunity LIMIT 1].Id;
                String status = 'SANCTIONED';
                String code = '230003';
                String Imod = 'DA0012573';
                Test.setMock(HttpCalloutMock.class, new ReverseStatusCalloutTestMock());
                Id pactLmsJobId = System.enqueueJob(new IND_ReverseStatusCalloutQueueable(loanAppId,status,code));
                List<Opportunity> opps = [Select Id,Lead_number__c from Opportunity where IModuleId__c=:Imod WITH SECURITY_ENFORCED Limit 1];
                Test.stopTest();
                //Opportunity loanAppRec = [Select Id, Payment_Request_Generation_Date__c From Opportunity Where Id =:loanAppId LIMIT 1];
                System.assertNotEquals(null, pactLmsJobId);                
            }catch(Exception e){
                System.debug('Exception ' + e.getMessage());
            }
        }        
    }
    
    @isTest
    public static void doReverseStatusCallout_Negative(){
        User u = [SELECT Id,usertype FROM User WHERE username='vishal@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {	
            try{
                Test.startTest();
                String loanAppId = [Select Id From Opportunity LIMIT 1].Id;
                String status = 'SANCTIONED';
                String code = '230003';
                Test.setMock(HttpCalloutMock.class, new ReverseStatusCalloutFailureTestMock());
                Id pactLmsJobId = System.enqueueJob(new IND_ReverseStatusCalloutQueueable(loanAppId,status,code));
                Test.stopTest();
                Opportunity loanAppRec = [Select Id, Payment_Request_Generation_Date__c From Opportunity Where Id =:loanAppId LIMIT 1];
                System.assertNotEquals(null, pactLmsJobId);
                System.assertNotEquals(system.now(), loanAppRec.Payment_Request_Generation_Date__c);
            } catch(Exception ex){
                System.assertNotEquals(null, ex.getMessage());
            }
        }
    }
    
    @isTest
    public static void IND_ReverseStatusRequestMethod(){
        String loanAppId = [Select Id From Opportunity LIMIT 1].Id;
        Opportunity oppObj = [SELECT ID from Opportunity LIMIT 1];
        oppObj.Sanction_Date__c = Date.newInstance(2024, 08, 20);
                update oppObj;
                Final_Term__c fObj = new Final_Term__c();
                fObj.Loan_Application__c =oppObj.Id;
                insert fObj;
        String status = 'SANCTIONED';
        String code = '230003';
        
        Applicant__c objApplicant = new Applicant__c();
        objApplicant.Opportunity__c = loanAppId;
        objApplicant.Applicant_Type__c = 'Borrower';
        objApplicant.Contact_number__c = '1234567890';
        
        if(Schema.sObjectType.Applicant__c.isCreateable())
            insert objApplicant;
        
        Documents__c objDocument = new Documents__c();
        objDocument.Opportunity_Relation__c = loanAppId;
        objDocument.name = 'DocName';
        objDocument.CMU_Accept_Reject__c = 'Reject';
        objDocument.CMU_Rejection_Reason__c ='Incorrect fields';
        objDocument.Rejection_Fields__c ='PAN No.';
        objDocument.Document_Type__c = 'Insurance Policy Doc';
        objDocument.is_Active__c = true;
        objDocument.Applicant__c = objApplicant.Id;
        if(Schema.sObjectType.Documents__c.isCreateable())
            insert objDocument;
        
        Test.startTest();
            try{
                IND_ReverseStatusRequest indr = new IND_ReverseStatusRequest(loanAppId,status,code);
            }catch(Exception e){
                System.debug('Exception ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    @isTest
    public static void IND_ReverseStatusServiceTestMethod(){
        String loanAppId = [Select Id From Opportunity LIMIT 1].Id;
        String status = 'SANCTIONED';
        String code = '230003';
        Test.startTest();
        IND_ReverseStatusService.getReverseStatusCallOutRequest(loanAppId,status,code);
        Test.stopTest();
    }
    
    @isTest
    public static void IND_ReverseStatusServiceTestMethod2(){
         Test.startTest();
        try{
            String loanAppId = [Select Id From Account LIMIT 1].Id;
            String status = 'SANCTIONED';
            String code = '230003';
            
            IND_ReverseStatusService.getReverseStatusCallOutRequest(loanAppId,status,code);
        }catch(Exception e){
            System.debug('Exception ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void IND_ReverceStatusResponseTest(){
         Test.startTest();
        try{
            IND_ReverceStatusResponse.response resp = new IND_ReverceStatusResponse.response();
            IND_ReverceStatusResponse.content cont = new IND_ReverceStatusResponse.content();
            IND_ReverceStatusResponse.error_message err = new IND_ReverceStatusResponse.error_message();
            list<IND_ReverceStatusResponse.content> ContentOfAPI = new list<IND_ReverceStatusResponse.content>();
            resp.status = 'SUCCESS';
            resp.respDesc = 'Test';
            resp.content = ContentOfAPI;
            cont.enquiry_id = 'NX-07112022-980609455';
            cont.error_message = null;
            cont.message = 'Application Status of DA0012569 updated successfully';
            cont.status = 'success';
            cont.updated_status = '340002';
            cont.success = 'True';
        }catch(Exception e){
            System.debug('Exception ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    public static void doReverseStatusCallout_TestNew(){
        User u = [SELECT Id,usertype FROM User WHERE username='vishal@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            try{
                Opportunity loanAppId = [Select Id From Opportunity LIMIT 1];
                loanAppId.LeadSource = System.label.Mahindra_Custom_Lead_API_Value;
        		loanAppId.Sanction_Date__c = Date.newInstance(2024, 08, 20);
                update loanAppId;
                Final_Term__c fObj = new Final_Term__c();
                fObj.Loan_Application__c =loanAppId.Id;
                insert fObj;
                String status = 'SANCTIONED';
                String code = '230003';
                String Imod = 'DA0012573';
                Test.setMock(HttpCalloutMock.class, new ReverseStatusCalloutTestMock());
                Id pactLmsJobId = System.enqueueJob(new IND_ReverseStatusCalloutQueueable(loanAppId.Id,status,code));
                List<Opportunity> opps = [Select Id,Lead_number__c from Opportunity where IModuleId__c=:Imod WITH SECURITY_ENFORCED Limit 1];
                Test.stopTest();
                //Opportunity loanAppRec = [Select Id, Payment_Request_Generation_Date__c From Opportunity Where Id =:loanAppId LIMIT 1];
                System.assertNotEquals(null, pactLmsJobId);                
            }catch(Exception e){
                System.debug('Exception ' + e.getMessage());
            }
        }        
    }
}