@istest
public class IND_RenderAsPDFControllerTest {

    @testSetup static void setup(){
        
        Account accobj = new Account();
        accobj.Name = 'testname';
        accobj.State__c = 'ASSAM';
        accobj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert accobj;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        oppobj.accountid = accobj.id;
        insert oppobj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c = oppObj.Id;
        applicant.Application_Form_SMS_Sent__c = System.now();
        applicant.Application_Consent_Received__c = true;
        insert applicant;
        
        Documents__c getDoc = TestDataUtility.createTestDocumentITR(false, applicant, oppObj);
        getDoc.Applicant__c = applicant.id;
        getDoc.Addresss_Type__c = 'Current Residential Address';
        insert getDoc;
        
        Income_Details__c incme = TestDataUtility.createIncomeDetailsRecord();
        incme.Applicant__c = applicant.id;
        insert incme;
        
        Vehicle_Detail__c veh = TestDataUtility.createTestVehicleDetailForMFCValuation(true, oppObj);
    }

    @isTest 
    public static void IND_RenderAsPDFControllerTest()
    {
        Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);        
        
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);     
        IND_RenderAsPDFController ext = new IND_RenderAsPDFController(sc);
        ext.Records = apList;
        ext.getlinkExpired();
        ext.acceptandRender();
        Test.StopTest();
    }
}