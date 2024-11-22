/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:   Test class created to validate the IND_IbbMasterRequest IND_IbbMasterService IND_IbbMasterResponse class
History
Date            Author              Comments
-------------------------------------------------------------
16-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/


@isTest(SeeAllData=false)
public class IND_IbbMasterServiceTest {

    @isTest
    public static void testINDIbbMasterService(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opp);
             if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vehicleDetail;
            }
            String ibbRequestString='{"loanApplicationId":"'+opp.Id+'" ,"vehicleId":"'+vehicleDetail.id+'" ,"color":"white","owner":"1","kilometer":"1230"}';
            Continuation con = (Continuation)IntegrationEngine.doIbbMasterCallout(ibbRequestString);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"7Jhl/0C8bTs1PbBVb8ml7un0zzs9M0rkuPBBKEX9O23z+RP50y/Aw+esLmVQAZ6wwEI//Ue0er3ClUlXVcppXz5Fr6JQQAIObLpNElFCOwGn6dVYkmjKzaBSGQJSWoU9He87NKneiXkfQNpYLQcZAJ0YZkaazr77h+sZR1hbvauI+TDnInVZRsxu3pP0PQg0Huy3fLyJqzYeC8T68QbnCn50wzKsRc7bXv1sQ259TWQ="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String iBBMasterCallOutResponse= (String)IntegrationEngine.processIbbMasterCallOutResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
          String responseExpected ='{"body":null,"vehicle_id":"a0Y710000002jgzEAA","status":"200","message":"Success","ibb_price_min":"396053","ibb_price_max":"446600","ibb_price_avg":"424246","application_no":"L20012200007"}';
         System.assertEquals(responseExpected, iBBMasterCallOutResponse,'Success');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Variant not found in product','Exception');
        }
    }
    
    /*   @isTest
    public static void testINDIbbMasterService2(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opp);
             if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
               insert vehicleDetail;
            }
            String ibbRequestString='{"loanApplicationId":"'+opp.Id+'" ,"vehicleId":"'+vehicleDetail.id+'" ,"color":"","owner":"1","kilometer":"1230"}';
            Continuation con = (Continuation)IntegrationEngine.doIbbMasterCallout(ibbRequestString);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"7Jhl/0C8bTs1PbBVb8ml7un0zzs9M0rkuPBBKEX9O23z+RP50y/Aw+esLmVQAZ6wwEI//Ue0er3ClUlXVcppXz5Fr6JQQAIObLpNElFCOwGn6dVYkmjKzaBSGQJSWoU9He87NKneiXkfQNpYLQcZAJ0YZkaazr77h+sZR1hbvauI+TDnInVZRsxu3pP0PQg0Huy3fLyJqzYeC8T68QbnCn50wzKsRc7bXv1sQ259TWQ="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String iBBMasterCallOutResponse= (String)IntegrationEngine.processIbbMasterCallOutResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
           String responseExpected ='{"body":null,"vehicle_id":"a0Y710000002jgzEAA","status":"200","message":"Success","ibb_price_min":"396053","ibb_price_max":"446600","ibb_price_avg":"424246","application_no":"L20012200007"}';
          //System.assertEquals(responseExpected, iBBMasterCallOutResponse,'Success');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Null label','Exception');
        }
    } */
    
  /*    @isTest
    public static void testINDIbbMasterService3(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opp);
             if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
               insert vehicleDetail;
            }
            String ibbRequestString='{"loanApplicationId":"'+opp.Id+'" ,"vehicleId":"'+vehicleDetail.id+'" ,"color":"white","owner":"1","kilometer":""}';
            Continuation con = (Continuation)IntegrationEngine.doIbbMasterCallout(ibbRequestString);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"7Jhl/0C8bTs1PbBVb8ml7un0zzs9M0rkuPBBKEX9O23z+RP50y/Aw+esLmVQAZ6wwEI//Ue0er3ClUlXVcppXz5Fr6JQQAIObLpNElFCOwGn6dVYkmjKzaBSGQJSWoU9He87NKneiXkfQNpYLQcZAJ0YZkaazr77h+sZR1hbvauI+TDnInVZRsxu3pP0PQg0Huy3fLyJqzYeC8T68QbnCn50wzKsRc7bXv1sQ259TWQ="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String iBBMasterCallOutResponse= (String)IntegrationEngine.processIbbMasterCallOutResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
           String responseExpected ='{"body":null,"vehicle_id":"a0Y710000002jgzEAA","status":"200","message":"Success","ibb_price_min":"396053","ibb_price_max":"446600","ibb_price_avg":"424246","application_no":"L20012200007"}';
         // System.assertEquals(responseExpected, iBBMasterCallOutResponse,'Success');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Null label','Exception');
        }
    } */
    
   /*   @isTest
    public static void testINDIbbMasterService4(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opp);
             if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
               insert vehicleDetail;
            }
            String ibbRequestString='{"loanApplicationId":"'+opp.Id+'" ,"vehicleId":"'+vehicleDetail.id+'" ,"color":"white","owner":"","kilometer":"1230"}';
            Continuation con = (Continuation)IntegrationEngine.doIbbMasterCallout(ibbRequestString);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"7Jhl/0C8bTs1PbBVb8ml7un0zzs9M0rkuPBBKEX9O23z+RP50y/Aw+esLmVQAZ6wwEI//Ue0er3ClUlXVcppXz5Fr6JQQAIObLpNElFCOwGn6dVYkmjKzaBSGQJSWoU9He87NKneiXkfQNpYLQcZAJ0YZkaazr77h+sZR1hbvauI+TDnInVZRsxu3pP0PQg0Huy3fLyJqzYeC8T68QbnCn50wzKsRc7bXv1sQ259TWQ="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String iBBMasterCallOutResponse= (String)IntegrationEngine.processIbbMasterCallOutResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
           String responseExpected ='{"body":null,"vehicle_id":"a0Y710000002jgzEAA","status":"200","message":"Success","ibb_price_min":"396053","ibb_price_max":"446600","ibb_price_avg":"424246","application_no":"L20012200007"}';
          //System.assertEquals(responseExpected, iBBMasterCallOutResponse,'Success');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Null label','Exception');
        }
    } */
  /*  @isTest
    public static void getIbbMasterCallOutRequestTest(){
        
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
        IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        }
        catch(Exception e){}
        
    } */
   /* @isTest
    public static void getIbbMasterCallOutRequestTest1(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    }
    @isTest
    public static void getIbbMasterCallOutRequestTest2(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    }
   /* @isTest
    public static void getIbbMasterCallOutRequestTest3(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        reqWrapper.year = 'testyear';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    } */
    @isTest
    public static void getIbbMasterCallOutRequestTest4(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        reqWrapper.year = 'testyear';
        reqWrapper.month = 'testmonth';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    }
    @isTest
    public static void getIbbMasterCallOutRequestTest5(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        reqWrapper.year = 'testyear';
        reqWrapper.month = 'testmonth';
        reqWrapper.variant = 'testVariant';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    } 
  /*  @isTest
    public static void getIbbMasterCallOutRequestTest6(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        reqWrapper.year = 'testyear';
        reqWrapper.month = 'testmonth';
        reqWrapper.variant = 'testVariant';
        reqWrapper.stateCode = 'TS';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    } */
 /*   @isTest
    public static void getIbbMasterCallOutRequestTest7(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        reqWrapper.year = 'testyear';
        reqWrapper.month = 'testmonth';
        reqWrapper.variant = 'testVariant';
        reqWrapper.stateCode = 'TS';
        reqWrapper.color = 'Testcolor';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    } */
  /*  @isTest
    public static void getIbbMasterCallOutRequestTest8(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        reqWrapper.year = 'testyear';
        reqWrapper.month = 'testmonth';
        reqWrapper.variant = 'testVariant';
        reqWrapper.stateCode = 'TS';
        reqWrapper.color = 'Testcolor';
        reqWrapper.owner = 'TestOwner';
        
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    } */
    @isTest
    public static void getIbbMasterCallOutRequestTest9(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.applicationNo = 'test';
        reqWrapper.vehicleId = 'test123';
        reqWrapper.year = 'testyear';
        reqWrapper.month = 'testmonth';
        reqWrapper.variant = 'testVariant';
        reqWrapper.stateCode = 'TS';
        reqWrapper.color = 'Testcolor';
        reqWrapper.owner = 'TestOwner';
        reqWrapper.Kilometer = 'testKM';
        
        Test.StartTest();
         IND_IbbMasterService.getIbbMasterCallOutRequest(reqWrapper);
        Test.StopTest();
        }
        catch(Exception e){}
        
    } 
    
    @isTest
    public static void testOne(){
        
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
                      IND_IbbMasterRequest mr1 = new IND_IbbMasterRequest(rw1);
                      Map<String,String> mr2 = mr1.getHttpRequestHeaders();
                Test.stopTest();
    }
}