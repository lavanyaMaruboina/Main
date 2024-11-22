/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_VahanVehicleValuationRequest IND_VahanVehicleValuationService IND_VahanVehicleValuationResponse class
History
Date            Author              Comments
-------------------------------------------------------------
23-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_VahanVehicleValuationService_Test {
@isTest
    public static void testVahanVehicleValuationService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                              MobilePhone = '9701498575',
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vahanVehicleValuation = '{"leadId":"'+opp.Lead_number__c+'" ,"vehicleRegisterationNumber":"'+opp.Vehicle_Registration_Number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVahanVehicleValuationCallout(vahanVehicleValuation);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngo4x2JS1r5HzlnM/zxGThwGUugDfGwsFb5701ruHGiu8UAvBTrFa0YvYPKu3g9fU4D3gKX39lo92+rqWfgvMVtDi9IWdhQF8somsiOu7V94rrxHwa77U38XnuQ1BJ2YB0="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String vahanVehicleValuationCallOutResponse;
             system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            vahanVehicleValuationCallOutResponse= (String)IntegrationEngine.processVahanVehicleValuationResponse(labels, IntegrationEngine.continuationState);
            system.debug('resulteeeeee'+vahanVehicleValuationCallOutResponse);
                 Test.stopTest();
             }
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Vehicle Details are submitted and sent to vahan for processing..","content":[""]}}';
            System.assertEquals(responseExpected, vahanVehicleValuationCallOutResponse, 'SUCCESS');
           
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'List has no rows for assignment to SObject');
            
            
        }
    }
    
   @isTest
    public static void testVahanVehicleValuationService2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vahanVehicleValuation = '{"leadId":"'+opp.Lead_number__c+'" ,"vehicleRegisterationNumber":""}';
            
            Continuation con = (Continuation)IntegrationEngine.doVahanVehicleValuationCallout(vahanVehicleValuation);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngo4x2JS1r5HzlnM/zxGThwGUugDfGwsFb5701ruHGiu8UAvBTrFa0YvYPKu3g9fU4D3gKX39lo92+rqWfgvMVtDi9IWdhQF8somsiOu7V94rrxHwa77U38XnuQ1BJ2YB0="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vahanVehicleValuationCallOutResponse= (String)IntegrationEngine.processVahanVehicleValuationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest(); 
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Vehicle Details are submitted and sent to vahan for processing..","content":[""]}}';
            System.assertEquals(responseExpected, vahanVehicleValuationCallOutResponse, 'SUCCESS'); 
            
        } catch(Exception ex){
          //System.assertEquals(ex.getMessage(),'Invalid conversion from runtime type String to System.Continuation', 'Exception');
        }
    }
    
    @isTest
    public static void testVahanVehicleValuationService3(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vahanVehicleValuation = '{"leadId":"" ,"vehicleRegisterationNumber":"'+opp.Vehicle_Registration_Number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVahanVehicleValuationCallout(vahanVehicleValuation);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngo4x2JS1r5HzlnM/zxGThwGUugDfGwsFb5701ruHGiu8UAvBTrFa0YvYPKu3g9fU4D3gKX39lo92+rqWfgvMVtDi9IWdhQF8somsiOu7V94rrxHwa77U38XnuQ1BJ2YB0="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vahanVehicleValuationCallOutResponse= (String)IntegrationEngine.processVahanVehicleValuationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest(); 
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Vehicle Details are submitted and sent to vahan for processing..","content":[""]}}';
            System.assertEquals(responseExpected, vahanVehicleValuationCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
         // System.assertEquals(ex.getMessage(),'Invalid conversion from runtime type String to System.Continuation', 'Exception');
        }
    }
    
    @isTest
    public static void testVahanVehicleValuationService4(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vahanVehicleValuation = '{"leadId":"'+opp.Lead_number__c+'" ,"vehicleRegisterationNumber":"'+opp.Vehicle_Registration_Number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVahanVehicleValuationCallout(vahanVehicleValuation);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngo4x2JS1r5HzlnM/zxGThwGUugDfGwsFb5701ruHGiu8UAvBTrFa0YvYPKu3g9fU4D3gKX39lo92+rqWfgvMVtDi9IWdhQF8somsiOu7V94rrxHwa77U38XnuQ1BJ2YB0="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vahanVehicleValuationCallOutResponse= (String)IntegrationEngine.processVahanVehicleValuationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest(); 
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Vehicle Details are submitted and sent to vahan for processing..","content":[""]}}';
            System.assertEquals(responseExpected, vahanVehicleValuationCallOutResponse, 'SUCCESS'); 
            
        } catch(Exception ex){
          //System.assertEquals(ex.getMessage(),'Invalid conversion from runtime type String to System.Continuation', 'Exception');
        }
    }
    @isTest
    public static void testVahanVehicleValuationService5(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opgd1.Id;
        appList.add(applicant);
        insert appList;
        IND_VahanVehicleValuationService.getVahanVehicleValuationCallOutRequest(reqWrapper,opgd1.id);
        }
        catch(Exception e){}
        
    }
    @isTest
    public static void testVahanVehicleValuationService6(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = opgd1.Id;
        
        
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opgd1.Id;
        appList.add(applicant);
        insert appList;
        IND_VahanVehicleValuationService.getVahanVehicleValuationCallOutRequest(reqWrapper,opgd1.id);
        }
        catch(Exception e){}
        
    }
    @isTest
    public static void testVahanVehicleValuationService7(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = opgd1.Id;
        reqWrapper.vehicleRegisterationNumber = opgd1.Id;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opgd1.Id;
        appList.add(applicant);
        insert appList;
        IND_VahanVehicleValuationService.getVahanVehicleValuationCallOutRequest(reqWrapper,opgd1.id);
        }
        catch(Exception e){}
        
    }
    
    @isTest
    public static void testRes(){
        
                Opportunity opgt1 = new Opportunity();
                opgt1.StageName = 'Qualification';
                opgt1.CloseDate = Date.newInstance(2021, 1, 11);
                opgt1.Name = 'testone';
                insert opgt1;
                
                Applicant__c apgt1 = new Applicant__c();
                apgt1.Opportunity__c = opgt1.Id;
                apgt1.Contact_number__c = '9743514830';
                apgt1.Applicant_Type__c = 'Borrower';
                insert apgt1;
        
                Income_Details__c idt1 = new Income_Details__c();
                idt1.Applicant__c = apgt1.Id;
                idt1.API_Transaction_Status__c = 'testapi';
                idt1.Bank_Account_Number__c = '32543409214';
                idt1.Client_Transaction_Id__c = 'testclient';
                idt1.Remarks__c = 'no comments';
                insert idt1;        
        
                RequestWrapper rw1 = new RequestWrapper();
                rw1.applicantId = apgt1.Id;
                rw1.panNumber = apgt1.PAN_No__c;
                rw1.firstName = 'testone';
                rw1.lastName = 'testlast';
                rw1.dealNumber = 'testdl';
                rw1.dateOfBirth = '23061994';
                rw1.telephoneNumber = '9999999999';
                rw1.kycNo = '4635643';
                rw1.kycPassportFileNo = 'pt23556';
                rw1.kycGender = 'male';
                rw1.kycPassportNo = '232041';
                rw1.leadId = '676476368';
                rw1.email = 'test@gmail.com';
                rw1.income = '200000';
                rw1.aadhaarNo = '56678862431';
                rw1.dOB = Datetime.newInstance(1994, 6, 23, 12, 30, 0);
                rw1.vehicleRegisterationNumber = 'ap 26 1234';
                rw1.loanApplicationId = opgt1.Id;
                rw1.noOfCoborrowers = '8';
                rw1.vehicleType = 'TwoWheelers';
                rw1.CityId = '26';
                rw1.VariantCode = 'test123';
                rw1.customerCode = 'samplle123';
                rw1.oldDealNo = 'test453';
                rw1.nocNo = '45545667';
                rw1.product = 'testprd';
                rw1.category = 'motor';
                rw1.subCategory = 'testsub';
                rw1.applicantId = 'testapid';
                rw1.cicNo = '1234';
                rw1.emailTo = 'samplw@gmail.com';
                rw1.emailCC = 'testcc@gmail.com';
                rw1.emailSubject = 'testclass';
                rw1.emailBody = 'testbody';
                rw1.loanAmount = '1500000';
                rw1.loanDuration = '60';
                rw1.loanType = 'Personal';
                rw1.processingType = 'typeone';
                rw1.acceptancePolicy = 'test';
                rw1.uploadingScannedStatements = 'docs';
                rw1.yearMonthFrom = '6';
                rw1.yearMonthTo = '10';
                rw1.productType = 'vehicle';
                rw1.employmentType = 'permenant';
                rw1.employerName = 'dhoni';
                rw1.fileId = 'testfield';
                rw1.institutionId = '23';
                rw1.password = '12345';
                rw1.perfiosTransactionId = 'testper';
                rw1.uid = '134455';
                rw1.otp = '764345';
                rw1.txn = '4566633445';
                rw1.rnn = 'testrnn';
                rw1.applicantFirstName = 'mahi';
                rw1.applicantMiddleName = 'singh';
                rw1.applicantLastName = 'dhoni';
                rw1.name = 'name';
                rw1.destinationName = 'ap';
                rw1.destinationNames = 'ap';
                rw1.cinNo = 'testcin';
                rw1.applicationNo = '134355544655';
                rw1.vehicleId = 'v34566';
                rw1.age = '26';
                rw1.gender = 'male';
                rw1.insProduct = 'testprd';
                rw1.planCode = 'testplan';
                rw1.Fin_Amount = '50000';
                rw1.tenure = '36';
                rw1.dealNumber = 'Insurance Premium';
                rw1.Borrower_Type = 'Insurance Recommendation';
                rw1.Vehicle_Category = 'Insurance Recommendation';
                rw1.Variant = 'Insurance Recommendation';
                rw1.Fin_Amount = '1000';
                rw1.Balance_Available = '100';
                rw1.Agreement_Value = '10000';
                rw1.Motor_Expiry_Date = '2023-12-11';
                rw1.Motor_Premium = '1000';
                rw1.coBorrowerPanNumber = 'BTWSA3241J';
                rw1.coBorrowerDob = datetime.newInstance(1995, 9, 15, 12, 30, 0);
                rw1.coBorrowerIncome = '200000';
                rw1.coBorrowerCinNo = '3445666';
                rw1.contactNumber = '8888888888';
                rw1.otpForBorrower = '345643';
                rw1.flag = 'testflag';
                rw1.valuerCategory = 'tetsvaluer';
                rw1.placeOfInspection = 'city';
                rw1.locationOfVehicle = 'ap';
                rw1.city = 'nellore';
                rw1.state = 'ap';
                rw1.incomeDtlId = idt1.Id;
                rw1.gstType = 'testgst';
                rw1.itrType = 'testitr';
                rw1.bankType = 'national';
                rw1.GstNumber = 'g667438383883';
                rw1.kycDOB = Date.newInstance(1995, 9, 15);
                rw1.year = '2020';
                rw1.month = '6';
                rw1.stateCode = '29';
                rw1.color = 'red';
                rw1.owner = 'testowner';
                rw1.kilometer = '200';
                rw1.incomeDetailId = idt1.Id;
                rw1.incomeDetails = idt1;
                rw1.whatsappNo = '7777777777';
                rw1.reportType = 'Account';
                rw1.enachStatus = 'testenach';
                rw1.contentId = 'con1234';
                rw1.crmIrrRequested = 'testcrm123';
                rw1.exShowroomPrice = '40000';
                rw1.onRoadPrice = '70000';
                rw1.finalTermId = 'testfinal';
                rw1.fundingOnExShowroom = '4000';
                rw1.fundingOnORP = 'teston';
                rw1.currentScreen = 'testscreen';
                rw1.sumOfFundedInsurance = '40000';
                rw1.riskBand = 'testrisk';
                rw1.borrowerNIP = 'testnip';
                rw1.coBorrowerNIP = 'conip';
                rw1.borrowerPresentAddress = 'testadd';
                rw1.coBorrowerPresentAddress = 'testcoadd';
                rw1.emi = '1000';
                rw1.subProduct = 'testsub';
                rw1.thresholdNetIRR = 'testirr';
        
                Test.startTest();
                     IND_VahanVehicleValuationRequest vr1 = new IND_VahanVehicleValuationRequest(rw1,opgt1.Id);
                     Map<String,String> vr2 = vr1.getHttpRequestHeaders();
                Test.stopTest();
    }

}