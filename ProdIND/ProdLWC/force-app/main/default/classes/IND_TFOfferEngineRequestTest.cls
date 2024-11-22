@isTest
public class IND_TFOfferEngineRequestTest {
    @TestSetup
    static void testData(){
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'Test-2';
        opks1.Vehicle_Type__c = 'New';
        opks1.Product_Type__c = 'Tractor';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        apks1.In_Active_Applicant__c = false;
        apks1.DocAuth_Application_Id__c = 'T-authTest';
        apks1.Selfie_Upload__c = true;
        insert apks1;
        
        /* Deal_Number__c dealNo = new Deal_Number__c();
        dealNo.Loan_Application__c = opks1.Id;
        dealNo.Account_statement__c = true;
        dealNo.Banker_signature_verification__c = true;
        dealNo.All_Cheques_are_from_Same_bank__c = false;
        //dealNo.Deal_Number__c = 'AA2H67711';
        insert dealNo; */
        
        Vehicle_Detail__c vehicleDetailObj = new Vehicle_Detail__c();
        vehicleDetailObj.Loan_Application__c = opks1.Id;
        vehicleDetailObj.Model__c = 'Model-2';
        vehicleDetailObj.Invoice_Price__c = 23.08;
        //vehicleDetailObj.Deal_Number__c = dealNo.Deal_Number__c;
        insert vehicleDetailObj;
        
        Final_Term__c finalTermObj = new Final_Term__c();
        finalTermObj.Loan_Application__c = opks1.Id;
        finalTermObj.PricingEngine_thresholdNetrr__c = 78.2;
        finalTermObj.Vehicle_Detail__c = vehicleDetailObj.Id;
        finalTermObj.Installment_Frequency__c = 'Monthly';
        finalTermObj.Rreferrer_Incentive__c = '112';
        finalTermObj.Provisional_Channel_Cost__c = '2000';
        finalTermObj.EMI_Amount__c = 1230;
         finalTermObj.Structured_L1_Call__c = true;
        insert finalTermObj;
        
        Structered_EMI__c sEMI =New Structered_EMI__c(Loan_Application__c=opks1.Id,Vehicle_Detail__c =vehicleDetailObj.Id,EMI_Amount__c =20000,From_Month__c = 2,To_Month__c =12);
        insert sEMI;
        
    }
    
    @isTest
    public static void IND_TFOfferEngineRequestTest(){
        Opportunity opks1 = [Select id From Opportunity limit 1];
        opks1.Customer_Type__c = 'Individual';
        opks1.StageName = 'Credit Processing';
        opks1.Sub_Stage__c = 'CAM and Approval Log';
        update opks1;
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'Income Change',request);
        Test.stopTest();
    }
    
    @isTest
    public static void IND_TFOfferEngineRequestTest1(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        opks1.Vehicle_Type__c = 'Used';
        opks1.Customer_Type__c = 'Non-Individual';
        opks1.StageName = 'Final Terms';
        update opks1;
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        apks1.Applicant_Type__c = 'Beneficiary';
        update apks1;
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';

        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'Income Change',request);
        Test.stopTest();
    }
    
     @isTest
    public static void IND_TFOfferEngineRequestTest2(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        opks1.StageName = 'Offer Screen';
        update opks1;
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';

        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'Income Change',request);
        Test.stopTest();
    }
    
     @isTest
    public static void IND_TFOfferEngineRequestTest3(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        opks1.StageName = 'Insurance Details';
        update opks1;
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';

        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'Income Change',request);
        Test.stopTest();
    }
    
     @isTest
    public static void IND_TFOfferEngineRequestTest4(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        opks1.StageName = 'Credit Processing';
        opks1.Sub_Stage__c = 'Final Terms';
        update opks1;
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';

        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'Income Change',request);
        Test.stopTest();
    }
    
     @isTest
    public static void IND_TFOfferEngineRequestTest5(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';
		request.loanAmount ='200000';
        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'Income Offer',request);
        Test.stopTest();
    }
    
     @isTest
    public static void IND_TFOfferEngineRequestTest6(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';

        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'CAM and Approval Log',request);
        Test.stopTest();
    }
    
      @isTest
    public static void IND_TFOfferEngineRequestTest7(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';

        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'CIBIL',request);
        Test.stopTest();
    }
    
      @isTest
    public static void IND_TFOfferEngineRequestTest8(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        Applicant__c apks1 = [SELECT Id FROM Applicant__c LIMIT 1];
        RequestWrapper request = new RequestWrapper();
        request.applicantId = apks1.Id;
        request.crmIrrRequested = 'Test1';

        Test.startTest();
        IND_TFOfferEngineRequest testCont = new IND_TFOfferEngineRequest(opks1.Id,vehicleDetailObj.Id,'EMI Details',request);
        Test.stopTest();
    }
}