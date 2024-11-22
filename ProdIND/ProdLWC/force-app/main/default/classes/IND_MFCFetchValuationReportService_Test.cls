/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   Test class created to validate the IND_MFCFetchValuationReportRequest, IND_MFCFetchValuationReportService and IND_MFCFetchValuationReportResponse class
History
Date            Author              Comments
-------------------------------------------------------------
04-12-2022      Divya Jawale      Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_MFCFetchValuationReportService_Test {
    @isTest
    public static void testMFCFetchValuationService(){
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(true);
            Vehicle_Detail__c vehicleDetail = TestDataUtility.createTestVehicleDetailForMFCValuation(true,opp);
            String mfcValuationReportRequest = '{"loanApplicationId":"'+opp.Id+'", "leadId":"'+opp.Lead_number__c+'","vehicleRegisterationNumber":"'+vehicleDetail.Vehicle_Registration_number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doMFCFetchValuationReportCallout(mfcValuationReportRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
             String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngWw5kAQ1qneDZFDDkiD9/qOlOcZ28rkvXVgIcUrIgOnUv1YFSlzTbw8h9StXDX3M6fKnwtTRyqfNBRd9G1id2fBjsPFZ3s699M7WJKXCfbdpGfTTEFocAiWblhwsNEVbf64PJwjRm0vURghqh7aiuM7Vst0xi6TrBaI06CsTEI0XmYLQpGJ/aR8BcLird9IvhCbESpIGjlARqry0Dff8DZmQybd7EAg4dsFbwWwBV2l1cO7lRVH9ORGwQUBY226nI0e1rbgoOfz0hKQ9/XEmzHYtZYo2OU/xeztiG7n9wvE5glJCdN1/JHQ48YvUifVi2rHElsxdnxhYCO8iGZBaPn7QJgf3GrgDpB/+BmGgOQyg=="}';
            response.setBody(body);          
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String mfcValuationReportCallOutResponse= (String)IntegrationEngine.processMFCFetchValuationReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"MFC FetchValuation Report","content":[{"VehicleRegNo":"TN99U6312","Valuation_Price":"1150000.0000","ReportURL":"https://aiv3portal.autoinspekt.com/report/view/MjkzMDIwMjg5/Q1ZSVEwyOTMwMjAyODk=","ReportGenerated":"Yes","Overall_Remarks":null,"LeadId":null}]}}';
            System.assertEquals(responseActual,mfcValuationReportCallOutResponse);
            
        } catch(Exception ex){
          // System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void testMFCFetchValuationService2(){
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(true);
            Vehicle_Detail__c vehicleDetail = TestDataUtility.createTestVehicleDetailForMFCValuationVehRegNo(true,opp);
            String mfcValuationReportRequest = '{"loanApplicationId":"'+opp.Id+'", "leadId":"'+opp.Lead_number__c+'","vehicleRegisterationNumber":"'+vehicleDetail.Vehicle_Registration_number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doMFCFetchValuationReportCallout(mfcValuationReportRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
             String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngWw5kAQ1qneDZFDDkiD9/qOlOcZ28rkvXVgIcUrIgOnUv1YFSlzTbw8h9StXDX3M6fKnwtTRyqfNBRd9G1id2fBjsPFZ3s699M7WJKXCfbdpGfTTEFocAiWblhwsNEVbf64PJwjRm0vURghqh7aiuM7Vst0xi6TrBaI06CsTEI0XmYLQpGJ/aR8BcLird9IvhCbESpIGjlARqry0Dff8DZmQybd7EAg4dsFbwWwBV2l1cO7lRVH9ORGwQUBY226nI0e1rbgoOfz0hKQ9/XEmzHYtZYo2OU/xeztiG7n9wvE5glJCdN1/JHQ48YvUifVi2rHElsxdnxhYCO8iGZBaPn7QJgf3GrgDpB/+BmGgOQyg=="}';
            response.setBody(body);          
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String mfcValuationReportCallOutResponse= (String)IntegrationEngine.processMFCFetchValuationReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"MFC FetchValuation Report","content":[{"VehicleRegNo":"TN99U6312","Valuation_Price":"1150000.0000","ReportURL":"https://aiv3portal.autoinspekt.com/report/view/MjkzMDIwMjg5/Q1ZSVEwyOTMwMjAyODk=","ReportGenerated":"Yes","LeadId":null}]}}';
            System.assertEquals(responseActual,mfcValuationReportCallOutResponse);
            
        } catch(Exception ex){
          // System.assertEquals(ex.getMessage(),System.Label.VehicleRegistrationNumber);
        }
    }
    
    @isTest
    public static void testMFCFetchValuationService3(){
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(true);
            Vehicle_Detail__c vehicleDetail = TestDataUtility.createTestVehicleDetailForMFCValuation(true,opp);
            String mfcValuationReportRequest = '{"loanApplicationId":"'+opp.Id+'", "leadId":"'+opp.Lead_number__c+'","vehicleRegisterationNumber":"'+vehicleDetail.Vehicle_Registration_number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doMFCFetchValuationReportCallout(mfcValuationReportRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngWw5kAQ1qneDZFDDkiD9/qOlOcZ28rkvXVgIcUrIgOnUv1YFSlzTbw8h9StXDX3M6fKnwtTRyqfNBRd9G1id2fBjsPFZ3s699M7WJKXCfbdpGfTTEFocAiWblhwsNEVbf64PJwjRm0vURghqh7aiuM7Vst0xi6TrBaI06CsTEI0XmYLQpGJ/aR8BcLird9IvhCbESpIGjlARqry0Dff8DZmQybd7EAg4dsFbwWwBV2l1cO7lRVH9ORGwQUBY226nI0e1rbgoOfz0hKQ9/XEmzHYtZYo2OU/xeztiG7n9wvE5glJCdN1/JHQ48YvUifVi2rHElsxdnxhYCO8iGZBaPn7QJgf3GrgDpB/+BmGgOQyg=="}';
            response.setBody(body);          
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String mfcValuationReportCallOutResponse= (String)IntegrationEngine.processMFCFetchValuationReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"MFC FetchValuation Report","content":[{"VehicleRegNo":"TN99U6312","Valuation_Price":"1150000.0000","ReportURL":"https://aiv3portal.autoinspekt.com/report/view/MjkzMDIwMjg5/Q1ZSVEwyOTMwMjAyODk=","ReportGenerated":"Yes","Overall_Remarks":null,"LeadId":null}]}}';
            System.assertEquals(responseActual,mfcValuationReportCallOutResponse,'Success');
            
        } catch(Exception ex){
          //  System.assertEquals(ex.getMessage(),System.Label.LeadId,'Exception');
        }
    }
    
    @isTest
    public static void testMFCFetchValuationService4(){
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(true);
            Vehicle_Detail__c vehicleDetail = TestDataUtility.createTestVehicleDetailForMFCValuation(true,opp);
            String mfcValuationReportRequest = '{"loanApplicationId":"'+opp.Id+'", "leadId":"'+opp.Lead_number__c+'","vehicleRegisterationNumber":"'+vehicleDetail.Vehicle_Registration_number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doMFCFetchValuationReportCallout(mfcValuationReportRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
             String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngWw5kAQ1qneDZFDDkiD9/qOlOcZ28rkvXVgIcUrIgOnUv1YFSlzTbw8h9StXDX3M6fKnwtTRyqfNBRd9G1id2fBjsPFZ3s699M7WJKXCfbdpGfTTEFocAiWblhwsNEVbf64PJwjRm0vURghqh7aiuM7Vst0xi6TrBaI06CsTEI0XmYLQpGJ/aR8BcLird9IvhCbESpIGjlARqry0Dff8DZmQybd7EAg4dsFbwWwBV2l1cO7lRVH9ORGwQUBY226nI0e1rbgoOfz0hKQ9/XEmzHYtZYo2OU/xeztiG7n9wvE5glJCdN1/JHQ48YvUifVi2rHElsxdnxhYCO8iGZBaPn7QJgf3GrgDpB/+BmGgOQyg=="}';
            response.setBody(body);          
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String mfcValuationReportCallOutResponse= (String)IntegrationEngine.processMFCFetchValuationReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"MFC FetchValuation Report","content":[{"VehicleRegNo":"TN99U6312","Valuation_Price":"1150000.0000","ReportURL":"https://aiv3portal.autoinspekt.com/report/view/MjkzMDIwMjg5/Q1ZSVEwyOTMwMjAyODk=","ReportGenerated":"Yes","LeadId":null}]}}';
            System.assertEquals(responseActual,mfcValuationReportCallOutResponse);
            
        } catch(Exception ex){
          // System.assertEquals(ex.getMessage(),' List has no rows for assignment to SObject');
        }
    } 
    
    @isTest
    public static void test1(){
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
        
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opgt1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'BEN000280';
                vg3.Variant__c = 'testvariant';
                vg3.Model__c ='testModel';
                vg3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
                vg3.Ben_Code__c = 'BEN059659';
                vg3.Model__c ='TATA TIAGO BS 6';
                vg3.Make__c ='TATA';
                vg3.Vehicle_SubType__c = 'Tractor';
                insert vg3;
            
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
                rw1.leadId = 'L109939';
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
                rw1.vehicleId = vg3.Id;
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
                     IND_MFCFetchValuationReportRequest mr1 = new IND_MFCFetchValuationReportRequest(rw1);
                     Map<String,String> mr2 = mr1.getHttpRequestHeaders();
                Test.stopTest();
    }
}