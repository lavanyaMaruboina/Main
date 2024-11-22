/**
* @author Karunakar M.
* @company Persistent Systems
* @description A  Test class for the IND_CibilEquifaxReportController class
* Inputs: None
* History:
	Modified by Siva
*/

@IsTest 
public class IND_CibilEquifaxReportController_Test {
    
    @testSetup static void testDataMethod(){
        
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                       Scorecard_Decision__c='Test',
                                       ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.LTV_as_per_LTV_engine__c = 'testltv';
        ft1.PricingEngine_thresholdNetrr__c = 5;
        insert ft1;
        
        
    }
    
    @isTest
    public static void getCibilRecordTest(){
        
       Opportunity opp = [select id from Opportunity where Name = 'testone'];
        
       Test.startTest();
       		IND_CibilEquifaxReportController.getCibilRecord(opp.Id);
       Test.stopTest();
        
        
    }
    
     @isTest
    public static void getCibilRecordTest1(){
        
        Opportunity opp = [select id from Opportunity where Name = 'testone'];
        Applicant__c apl = [select id from Applicant__c where Name = 'apName0' limit 1];
        apl.Applicant_Type__c = 'Co-borrower';
        update apl;
        
        Test.startTest();
          IND_CibilEquifaxReportController.CibilEquifaxWrapper ef1 = IND_CibilEquifaxReportController.getCibilRecord(opp.Id);
         // system.assertEquals(ef1,IND_CibilEquifaxReportController.getCibilRecord(opp.Id));
        Test.stopTest();
        
    }
     @isTest
    public static void getCIBILDetailsTest2(){
        try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
        
                Applicant__c apgr1 = new Applicant__c();
                apgr1.Opportunity__c = opgr1.Id;
                apgr1.Contact_number__c = '9743514830';
                apgr1.Applicant_Type__c = 'Borrower';
                insert apgr1;
        
                CIBIL_Details__c cdo1 = new CIBIL_Details__c();
                cdo1.Applicant__c = apgr1.Id;
                cdo1.CIC_No__c = 'testcbd';
                insert cdo1;
            
                Test.startTest();
                    CIBIL_Details__c cb1 = IND_CibilEquifaxReportController.getCIBILDetails(cdo1.Id);
                    system.assertEquals(cb1,IND_CibilEquifaxReportController.getCIBILDetails(cdo1.Id));
                      IND_CibilEquifaxReportController.getCIBILDetails('test');
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }  
    
    @isTest
    public static void getCibilRecordTest3(){
        try{
            Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
        
                Applicant__c apgr1 = new Applicant__c();
                apgr1.Opportunity__c = opgr1.Id;
                apgr1.Contact_number__c = '9743514830';
                apgr1.Applicant_Type__c = 'Borrower';
                insert apgr1;
        
                CIBIL_Details__c cdo1 = new CIBIL_Details__c();
                cdo1.Applicant__c = apgr1.Id;
                cdo1.CIC_No__c = 'testcbd';
                insert cdo1;
            
                 Final_Term__c ft1 = new Final_Term__c();
                 ft1.Loan_Application__c = opgr1.Id;
                 ft1.LTV_as_per_LTV_engine__c = 'testltv';
                 ft1.PricingEngine_thresholdNetrr__c = 5;
                 ft1.LtvEngine_Ltv__c = 5;
                 insert ft1;
            
                 Test.startTest();
                   IND_CibilEquifaxReportController.CibilEquifaxWrapper ew1 = IND_CibilEquifaxReportController.getCibilRecord(opgr1.Id);
                //   system.assertEquals(ew1,IND_CibilEquifaxReportController.getCibilRecord(opgr1.Id));
                   IND_CibilEquifaxReportController.getCibilRecord(null);
                 Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    public static void getCibilRecordTFTest(){
        
       Opportunity opp = [select id from Opportunity where Name = 'testone'];
       Applicant__c app = [SELECT Id,Opportunity__c,Applicant_Type__c,In_Active_Applicant__c  FROM Applicant__c where Opportunity__c=:opp.Id ];
       app.In_Active_Applicant__c = false;
       update app;
        
       CIBIL_Details__c cibil = [select id,Applicant__c from CIBIL_Details__c where Applicant__c =: app.Id];
       Final_Term__c finalTerm = [select id,Loan_Application__c from Final_Term__c where Loan_Application__c=:opp.Id];
        
       Test.startTest();
       		IND_CibilEquifaxReportController.getCibilRecordTF(opp.Id,app.Id);
       Test.stopTest();
        
        
    }
  
        
   }