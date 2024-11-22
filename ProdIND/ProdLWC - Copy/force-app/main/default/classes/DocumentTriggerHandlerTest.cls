@isTest
public class DocumentTriggerHandlerTest {
    @TestSetup
	public static void setupData(){
		
		TriggerSwitch__c triggerCustomSettingElement = new TriggerSwitch__c();
		triggerCustomSettingElement.Name = 'IND_DocumentTrigger';
		triggerCustomSettingElement.Active__c = true;
		insert triggerCustomSettingElement;
	}
    @isTest
    public static void afterInsertTest(){
        try{
            Opportunity opdt1 = new Opportunity();
            opdt1.StageName = 'Qualification';
            opdt1.CloseDate = Date.newInstance(2024, 1, 11);
            opdt1.Name = 'testone';
            opdt1.Journey_Status__c = 'No Impact';
            insert opdt1;
            
            Applicant__c apdt1 = new Applicant__c();
            apdt1.Opportunity__c = opdt1.Id;
            apdt1.Contact_number__c = '9743514830';
            apdt1.Applicant_Type__c = 'Borrower';
            insert apdt1;
            
                Documents__c dsdt1 = new Documents__c();
                dsdt1.Applicant__c = apdt1.Id;
                dsdt1.Opportunity_Relation__c = opdt1.Id;
                dsdt1.Document_Type__c = 'RC Copy';
                dsdt1.Document_Side__c ='Back';
                dsdt1.Aadhar_Source__c = 'ScanAadhar';
                
                List<Documents__c> doctList = new List<Documents__c>();
                doctList.add(dsdt1);
                insert doctList;
    
                Test.startTest();
                    DocumentTriggerHandler dth = new DocumentTriggerHandler();
                    dth.afterInsert();
                Test.stopTest();
                
                }catch(Exception e){
        // System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }  
    @isTest
    public static void beforeUpdateTest(){
		List<Opportunity> opdtList = new List<Opportunity>();
        Opportunity opdt1 = new Opportunity();
        opdt1.StageName = 'Qualification';
        opdt1.CloseDate = system.today().addDays(10);
        opdt1.Name = 'test';
        opdt1.LeadSource='DSA';
        opdt1.Journey_Status__c = 'No Impact';
        opdt1.Product_Type__c='Tractor';
        opdt1.Customer_Type__c='Non-Individual';
		opdtList.add(opdt1);
		
		Opportunity opdt2 = new Opportunity();
        opdt2.StageName = 'Qualification';
        opdt2.CloseDate = system.today().addDays(10);
        opdt2.Name = 'test 2';
        opdt2.LeadSource='DSA';
        opdt2.Journey_Status__c = 'No Impact';
        opdt2.Product_Type__c='Tractor';
        opdt2.Customer_Type__c='Non-Individual';
		opdtList.add(opdt2);
        insert opdtList;
        
        List<Applicant__c> apdtList = new List<Applicant__c>();
		Applicant__c apdt1 = new Applicant__c();
        apdt1.Opportunity__c = opdt1.Id;
        apdt1.Contact_number__c = '9747514830';
        apdt1.Applicant_Type__c = 'Beneficiary';
        apdt1.In_Active_Applicant__c = false;
        apdt1.Beneficial_Owner_Category__c='Beneficial Owner';
		apdtList.add(apdt1);
		
		Applicant__c apdt2 = new Applicant__c();
        apdt2.Opportunity__c = opdt1.Id;
        apdt2.Contact_number__c = '9747514833';
        apdt2.Applicant_Type__c = 'Beneficiary';
        apdt2.In_Active_Applicant__c = false;
        apdt2.Beneficial_Owner_Category__c='Beneficial Owner';
		apdtList.add(apdt2);
        insert apdtList;
		
        List<Documents__c> dsdtList = new List<Documents__c>();
		Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt1.Id;
        dsdt1.Opportunity_Relation__c = opdt1.Id;
        dsdt1.Document_Type__c = 'RC Copy';
        dsdt1.Document_Side__c ='Back';
        dsdt1.Aadhar_Source__c = 'ScanAadhar';
        dsdt1.PAN_No__c = 'CIMPD2398T';
        List<Documents__c> doctList = new List<Documents__c>();
        dsdtList.add(dsdt1);
		
		Documents__c dsdt2 = new Documents__c();
        dsdt2.Applicant__c = apdt1.Id;
        dsdt2.Opportunity_Relation__c = opdt1.Id;
        dsdt2.Document_Type__c = 'PAN';
        dsdt2.Document_Side__c ='Front';
        dsdt2.Aadhar_Source__c = 'ScanAadhar';
        dsdt2.PAN_No__c = 'KPRDD2398Y';
        dsdtList.add(dsdt2);
        
        insert dsdtList;
        
        Test.startTest();
        dsdtList[0].PAN_No__c ='RMPD2398TS';
		dsdtList[1].PAN_No__c ='UPIDW5234I';
        update dsdtList;
        
        Test.stopTest();
         
    }
    @isTest
    public static void beforeInsertTest(){
        Opportunity opdt1 = new Opportunity();
        opdt1.StageName = 'Qualification';
        opdt1.CloseDate = system.today().addDays(10);
        opdt1.Name = 'test';
        opdt1.LeadSource='DSA';
        opdt1.Journey_Status__c = 'No Impact';
        opdt1.Product_Type__c='Tractor';
        opdt1.Customer_Type__c='Non-Individual';
        insert opdt1;
        List<Applicant__c> apdtList = new List<Applicant__c>();
        Applicant__c apdt1 = new Applicant__c();
        apdt1.Opportunity__c = opdt1.Id;
        apdt1.Contact_number__c = '9747514830';
        apdt1.Applicant_Type__c = 'Beneficiary';
        apdt1.In_Active_Applicant__c = false;
        apdt1.Beneficial_Owner_Category__c='Beneficial Owner';
        apdtList.add(apdt1);
        
        Applicant__c apdt2 = new Applicant__c();
        apdt2.Opportunity__c = opdt1.Id;
        apdt2.Contact_number__c = '9747514830';
        apdt2.Applicant_Type__c = 'Beneficiary';
        apdt2.In_Active_Applicant__c = false;
        apdt2.Beneficial_Owner_Category__c='Authorised Signatory';
         apdtList.add(apdt2);
        insert apdtList;
        
        Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt1.Id;
        dsdt1.Opportunity_Relation__c = opdt1.Id;
        dsdt1.Document_Type__c = 'RC Copy';
        dsdt1.Document_Side__c ='Back';
        dsdt1.Aadhar_Source__c = 'ScanAadhar';
        dsdt1.PAN_No__c = 'CIMPD2398T';
        List<Documents__c> doctList = new List<Documents__c>();
        doctList.add(dsdt1);
        
        insert doctList;
        Test.startTest();
        DocumentTriggerHandler dth = new DocumentTriggerHandler();
        dth.newDocumentList = [SELECT Id, Opportunity_Relation__c, PAN_No__c From Documents__c];
        dth.beforeInsert();
        Test.stopTest();
    }
    
    @isTest
    public static void afterUpdateTest(){
        Opportunity opdt1 = new Opportunity();
        opdt1.StageName = 'Qualification';
        opdt1.CloseDate = system.today().addDays(10);
        opdt1.Name = 'test';
        opdt1.LeadSource='DSA';
        opdt1.Journey_Status__c = 'No Impact';
        opdt1.Product_Type__c='Tractor';
        opdt1.Customer_Type__c='Non-Individual';
        insert opdt1;
        
        Applicant__c apdt1 = new Applicant__c();
        apdt1.Opportunity__c = opdt1.Id;
        apdt1.Contact_number__c = '9747514830';
        apdt1.Applicant_Type__c = 'Beneficiary';
        apdt1.In_Active_Applicant__c = false;
        apdt1.Beneficial_Owner_Category__c='Beneficial Owner';
        insert apdt1;
        Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt1.Id;
        dsdt1.Opportunity_Relation__c = opdt1.Id;
        dsdt1.Document_Type__c = 'RC Copy';
        dsdt1.Document_Side__c ='Back';
        dsdt1.Aadhar_Source__c = 'OTP';
        dsdt1.PAN_No__c = 'CIMPD2398T';
        List<Documents__c> doctList = new List<Documents__c>();
        doctList.add(dsdt1);
        
        insert doctList;
        
        List<Documents__c> doslist1= new List<Documents__c>();
        doslist1 = doctList;
        doslist1[0].Aadhar_Source__c ='ScanAadhar';
        update doslist1[0];
        
        Map<Id,Documents__c> docMap = new Map<Id,Documents__c>();
        docMap.put(doslist1[0].Id, doslist1[0]);
        Test.startTest();
        DocumentTriggerHandler dth = new DocumentTriggerHandler();
        dth.newDocumentList = doctList;
        dth.oldDocumentMap = docMap;
        dth.afterUpdate();
        Test.stopTest();
    }
}