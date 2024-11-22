@isTest
public class GetFinalTermsRecordsTest {
    @isTest
    
    public static void getdetailsTest(){
        
        Opportunity opgf1 = new Opportunity();
        opgf1.StageName = 'Qualification';
        opgf1.CloseDate = Date.newInstance(2021, 1, 11);
        opgf1.Name = 'testone';
        insert opgf1;
        
        Final_Term__c fg1 = new Final_Term__c();
        fg1.CRM_IRR__c = 120;
        fg1.Loan_Application__c = opgf1.Id;
        fg1.Holiday_period__c='30';
        fg1.EMI_Amount__c= 10000;
        insert fg1;
        
        Applicant__c apgf1 = new Applicant__c();
        apgf1.Opportunity__c = fg1.Loan_Application__c;
        apgf1.Contact_number__c = '9743514830';
        apgf1.Applicant_Type__c = 'Borrower';
        apgf1.Scorecard_Decision__c = 'red';
        insert apgf1;
        
        Test.startTest();
        GetFinalTermsRecords.getdetails(fg1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getdetailsTest1(){
        
        Opportunity opgf1 = new Opportunity();
        opgf1.StageName = 'Qualification';
        opgf1.CloseDate = Date.newInstance(2021, 1, 11);
        opgf1.Name = 'testone';
        insert opgf1;
        
        Final_Term__c fg1 = new Final_Term__c();
        fg1.CRM_IRR__c = 120;
        fg1.Loan_Application__c = opgf1.Id;
        fg1.Holiday_period__c='30';
        fg1.EMI_Amount__c= 10000;
        insert fg1;
        
        Applicant__c apgf1 = new Applicant__c();
        apgf1.Opportunity__c = fg1.Loan_Application__c;
        apgf1.Contact_number__c = '9743514830';
        apgf1.Applicant_Type__c = 'Borrower';
        apgf1.Scorecard_Decision__c = 'green';
        insert apgf1;
        
        Test.startTest();
        GetFinalTermsRecords.getdetails(fg1.Id);
        Test.stopTest();
    }
    @isTest
    public static void getdetailsTest2(){
        
        Opportunity opgf1 = new Opportunity();
        opgf1.StageName = 'Qualification';
        opgf1.CloseDate = Date.newInstance(2021, 1, 11);
        opgf1.Name = 'testone';
        opgf1.Journey_Status__c = 'Non STP';
        insert opgf1;
        
        Final_Term__c fg1 = new Final_Term__c();
        fg1.CRM_IRR__c = 120;
        fg1.Loan_Application__c = opgf1.Id;
        fg1.Holiday_period__c='30';
        fg1.EMI_Amount__c= 10000;
        insert fg1;
        
        Applicant__c apgf1 = new Applicant__c();
        apgf1.Opportunity__c = fg1.Loan_Application__c;
        apgf1.Contact_number__c = '9743514830';
        apgf1.Applicant_Type__c = 'Borrower';
        apgf1.Scorecard_Decision__c = 'green' ;
        insert apgf1;
        
        Test.startTest();
        GetFinalTermsRecords.getdetails(fg1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getdetailsTest3(){
        
        Opportunity opgf1 = new Opportunity();
        opgf1.StageName = 'Qualification';
        opgf1.CloseDate = Date.newInstance(2021, 1, 11);
        opgf1.Name = 'testone';
        opgf1.Journey_Status__c = 'Non STP';
        insert opgf1;
        
        Final_Term__c fg1 = new Final_Term__c();
        fg1.CRM_IRR__c = 120;
        fg1.Loan_Application__c = opgf1.Id;
        fg1.Holiday_period__c='30';
        fg1.EMI_Amount__c= 10000;
        insert fg1;
        
        Applicant__c apgf1 = new Applicant__c();
        apgf1.Opportunity__c = fg1.Loan_Application__c;
        apgf1.Contact_number__c = '9743514830';
        apgf1.Applicant_Type__c = 'Borrower';
        apgf1.Scorecard_Decision__c = 'Light Green';
        insert apgf1;
        
        Test.startTest();
        GetFinalTermsRecords.getdetails(fg1.Id);
        Test.stopTest();
    }
    
    
    @isTest
    public static void getFinalOfferDetailsflagTest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2022, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Journey_Status__c = 'Non STP';
        insert opgd1;
        
        Final_Term__c fgd2 = new Final_Term__c();
        fgd2.CRM_IRR__c = 120;
        fgd2.Loan_Application__c = opgd1.Id;
        fgd2.Holiday_period__c='30';
        fgd2.EMI_Amount__c= 10000;
        insert fgd2;
        
        Applicant__c apgd1 = new Applicant__c();
        apgd1.Opportunity__c = fgd2.Loan_Application__c;
        apgd1.Contact_number__c = '9743514830';
        apgd1.Applicant_Type__c = 'Borrower';
        apgd1.Scorecard_Decision__c = 'green';
        insert apgd1;
        
        Test.startTest();
        GetFinalTermsRecords.getFinalOfferDetailsflag(fgd2.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getFinalOfferDetailsflagTest2(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Journey_Status__c = 'Non STP';
        insert opgd1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        insert fgd3;
        
        Applicant__c apgd1 = new Applicant__c();
        apgd1.Opportunity__c = fgd3.Loan_Application__c;
        apgd1.Contact_number__c = '9743514830';
        apgd1.Applicant_Type__c = 'Borrower';
        apgd1.Scorecard_Decision__c = '';
        insert apgd1;
        
        Test.startTest();
        GetFinalTermsRecords.getFinalOfferDetailsflag(fgd3.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void getFinalOfferDetailsflagTest3(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Journey_Status__c = 'Non STP';
        insert opgd1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        insert fgd3;
        
        Applicant__c apgd1 = new Applicant__c();
        apgd1.Opportunity__c = fgd3.Loan_Application__c;
        apgd1.Contact_number__c = '9743514830';
        apgd1.Applicant_Type__c = 'Borrower';
        apgd1.Scorecard_Decision__c = 'Dark Green';
        insert apgd1;
        
        Test.startTest();
        GetFinalTermsRecords.getFinalOfferDetailsflag(fgd3.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void getFinalOfferDetailsflagTest4(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Journey_Status__c = 'stop';
        insert opgd1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        insert fgd3;
        
        Applicant__c apgd1 = new Applicant__c();
        apgd1.Opportunity__c = fgd3.Loan_Application__c;
        apgd1.Contact_number__c = '9743514830';
        apgd1.Applicant_Type__c = 'Borrower';
        apgd1.Scorecard_Decision__c = 'Dark Green';
        insert apgd1;
        
        Test.startTest();
        GetFinalTermsRecords.getFinalOfferDetailsflag(fgd3.Id);
        // GetFinalTermsRecords.getFinalOfferDetailsflag(null);
        Test.stopTest();
    }
    
    @isTest
    public static void getFinalOfferDetailsflagTest5(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Journey_Status__c = 'stop';
        insert opgd1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        insert fgd3;
        
        Applicant__c apgd1 = new Applicant__c();
        apgd1.Opportunity__c = fgd3.Loan_Application__c;
        apgd1.Contact_number__c = '9743514830';
        apgd1.Applicant_Type__c = 'Borrower';
        apgd1.Scorecard_Decision__c = 'Light Green';
        insert apgd1;
        
        Test.startTest();
        GetFinalTermsRecords.getFinalOfferDetailsflag(fgd3.Id);
        // GetFinalTermsRecords.getFinalOfferDetailsflag(null);
        Test.stopTest();
    }
    
    @isTest
    public static void getFinalOfferDetailsflagTest6(){
        try{
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            opgd1.Journey_Status__c = 'stop';
            insert opgd1;
            
            Final_Term__c fgd3 = new Final_Term__c();
            fgd3.CRM_IRR__c = 120;
            fgd3.Loan_Application__c = opgd1.Id;
            fgd3.Holiday_period__c='30';
            fgd3.EMI_Amount__c= 10000;
            insert fgd3;
            
            Applicant__c apgd1 = new Applicant__c();
            apgd1.Opportunity__c = fgd3.Loan_Application__c;
            apgd1.Contact_number__c = '9743514830';
            apgd1.Applicant_Type__c = 'Borrower';
            apgd1.Scorecard_Decision__c = 'Light Green';
            insert apgd1;
            
            
            Test.startTest();
            //GetFinalTermsRecords.getFinalOfferDetailsflag(fgd3.Id);
            GetFinalTermsRecords.getFinalOfferDetailsflag(null);
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testGetFinalTerms() {
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            opgd1.Journey_Status__c = 'stop';
            insert opgd1;
            
            Applicant__c apks = new Applicant__c();
            apks.Opportunity__c = opgd1.Id;
            apks.Contact_number__c = '9743514830';
            apks.Applicant_Type__c = 'Borrower';
            insert apks;
            
            Final_Term__c fgd3 = new Final_Term__c();
            fgd3.CRM_IRR__c = 120;
            fgd3.Loan_Application__c = opgd1.Id;
            fgd3.Holiday_period__c='30';
            fgd3.EMI_Amount__c= 10000;
            insert fgd3;
            
            Vehicle_Detail__c vehDet = new Vehicle_Detail__c();
            vehDet.Loan_Application__c = opgd1.Id;
            vehDet.Make__c ='TATA';
            vehDet.Model__c ='testModel';
            vehDet.Variant__c = 'testvariant';            
            insert vehDet; 
            
            Test.startTest();
            try {
                GetFinalTermsRecords.getFinalTerms(fgd3.Id);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            Test.stopTest();
        }
}