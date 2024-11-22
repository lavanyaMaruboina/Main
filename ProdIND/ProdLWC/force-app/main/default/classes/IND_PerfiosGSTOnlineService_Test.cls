/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   Test class for IND_PerfiosGSTOnlineRequest class 
Apex Class:    IND_PerfiosGSTOnlineRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Bhushan Charde       Created
------------------------------------------------------------*/
@isTest
public class IND_PerfiosGSTOnlineService_Test {

    // @Method:     TestServiceMetthod
    // @Created by: Bhushan Charde
    // @Description:Test setup method to create the test data for IND_PerfiosGSTOnlineRequest classs
    // @Param:      ''  
    // @Return:     '' 
    @isTest
    public static void testPerfiosGSTOnlineService(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
        
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9743514830s',
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
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
            	rw1.gstType = 'GSTOnline';
                
        
         //   String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "incomeDtlId":"L10012200039", "gstType":"GSTOnline"}'; 
            Continuation con = (Continuation)IntegrationEngine.doGSTOnlineCallout(Json.serialize(rw1));
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"cEYfHwBVCU8jDIBKeGynq+2hPCZRi8nkKJzkd+zC/Gu1w7hc6WWrjhH99fyxitff658UnsirmlfiN+zMMETQ9wF9l2LSKHllqDonMGTarZer9la+XziIVTYkpvVI0eU1i1hDdgOCl7otCmeOc113i52DHFV/Q9rIZMCe42rf8S95esMgx3f55u2VTUc+adhGxQkbM/TYq8ytRylXywGkA+wLzFnS27WvrMtE0wjhQxukEKqF6L9Suttv5Xgt7DmndQJRzDV62ioIaEGMm2Y3/8r7oBrXdwYQg75wKlJklThvQ3wcc/vLPje5Pby/JTvexcM4WH2Fkazo68SnUSisf59+4hbYou08AAKzY2x7y0A="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;  
            String gstResponse;
            system.runAs(u){
                Test.startTest();
                // IND_PerfiosGSTOnlineRequest.getPerfiosGSTOnlineRequest(rw1);
                Test.setContinuationResponse(continuationLabel, response);
                gstResponse = (String)IntegrationEngine.processGSTOnlineAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"url":"https://apidemo.perfios.com/KYCServer/api/v2/tr/82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","transactionId":null,"success":null,"generateLinkId":"82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","expires":"2022-01-08 22:06:07 Asia/Kolkata","clientTransactionId":"03012022220607219"}';
            System.assertEquals(responseExpected, gstResponse,'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'List has no rows for assignment to SObject', 'Exception');
        }
    }
   
    // @Method:     TestServiceMetthod
    // @Created by: Bhushan Charde
    // @Description:Test setup method to create the test data for IND_PerfiosGSTOnlineRequest classs
    // @Param:      ''  
    // @Return:     '' 
    @isTest
    public static void testPerfiosGSTOnlineService1(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Income_Details__c incomeObj= TestDataUtility.createTestIncomeDetails(false);
            incomeObj.Applicant__c = applicant.id;
            insert incomeObj;
             
            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "incomeDtlId":"L10012200039", "gstType":"GSTOnline"}';            
            Continuation con = (Continuation)IntegrationEngine.doGSTOnlineCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"cEYfHwBVCU8jDIBKeGynq+2hPCZRi8nkKJzkd+zC/Gu1w7hc6WWrjhH99fyxitff658UnsirmlfiN+zMMETQ9wF9l2LSKHllqDonMGTarZer9la+XziIVTYkpvVI0eU1i1hDdgOCl7otCmeOc113i52DHFV/Q9rIZMCe42rf8S95esMgx3f55u2VTUc+adhGxQkbM/TYq8ytRylXywGkA+wLzFnS27WvrMtE0wjhQxukEKqF6L9Suttv5Xgt7DmndQJRzDV62ioIaEGMm2Y3/8r7oBrXdwYQg75wKlJklThvQ3wcc/vLPje5Pby/JTvexcM4WH2Fkazo68SnUSisf59+4hbYou08AAKzY2x7y0A="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String gstResponse = (String)IntegrationEngine.processGSTOnlineAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"url":"https://apidemo.perfios.com/KYCServer/api/v2/tr/82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","transactionId":null,"success":null,"generateLinkId":"82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","expires":"2022-01-08 22:06:07 Asia/Kolkata","clientTransactionId":"03012022220607219"}';
            System.assertEquals(responseExpected, gstResponse, 'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Applicant data not found.', 'Exception');
        }
    }
    
    // @Method:     TestServiceMetthod
    // @Created by: Bhushan Charde
    // @Description:Test setup method to create the test data for IND_PerfiosGSTOnlineRequest classs
    // @Param:      ''  
    // @Return:     '' 
   /* @isTest
    public static void testPerfiosGSTOnlineService4(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Income_Details__c incomeObj= TestDataUtility.createTestIncomeDetails(false);
            incomeObj.Applicant__c = applicant.id;
            insert incomeObj;
             
            String gstType='GSTOnline';           
            Continuation con = (Continuation)IntegrationEngine.doGSTOnlineCallout(applicant.Id, incomeObj.id, gstType);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"cEYfHwBVCU8jDIBKeGynq+2hPCZRi8nkKJzkd+zC/Gu1w7hc6WWrjhH99fyxitff658UnsirmlfiN+zMMETQ9wF9l2LSKHllqDonMGTarZer9la+XziIVTYkpvVI0eU1i1hDdgOCl7otCmeOc113i52DHFV/Q9rIZMCe42rf8S95esMgx3f55u2VTUc+adhGxQkbM/TYq8ytRylXywGkA+wLzFnS27WvrMtE0wjhQxukEKqF6L9Suttv5Xgt7DmndQJRzDV62ioIaEGMm2Y3/8r7oBrXdwYQg75wKlJklThvQ3wcc/vLPje5Pby/JTvexcM4WH2Fkazo68SnUSisf59+4hbYou08AAKzY2x7y0A="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String gstResponse = (String)IntegrationEngine.processGSTOnlineAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"url":"https://apidemo.perfios.com/KYCServer/api/v2/tr/82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","transactionId":null,"success":null,"generateLinkId":"82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","expires":"2022-01-08 22:06:07 Asia/Kolkata","clientTransactionId":"03012022220607219"}';
            System.assertEquals(responseExpected, gstResponse, 'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.GstNumberError, 'Exception');
        }
    }*/
    
    @isTest
    public static void testPerfiosITROnlineService(){
        try{
            
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
        
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c doc= TestDataUtility.createTestDocumentITR(false, applicant, opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert doc;
            }
            
            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "itrType":"ITROnline"}';            
            Continuation con = (Continuation)IntegrationEngine.doGSTOnlineCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"cEYfHwBVCU8jDIBKeGynq+2hPCZRi8nkKJzkd+zC/Gu1w7hc6WWrjhH99fyxitff658UnsirmlfiN+zMMETQ9wF9l2LSKHllqDonMGTarZer9la+XziIVTYkpvVI0eU1i1hDdgOCl7otCmeOc113i52DHFV/Q9rIZMCe42rf8S95esMgx3f55u2VTUc+adhGxQkbM/TYq8ytRylXywGkA+wLzFnS27WvrMtE0wjhQxukEKqF6L9Suttv5Xgt7DmndQJRzDV62ioIaEGMm2Y3/8r7oBrXdwYQg75wKlJklThvQ3wcc/vLPje5Pby/JTvexcM4WH2Fkazo68SnUSisf59+4hbYou08AAKzY2x7y0A="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String itrResponse;
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                itrResponse = (String)IntegrationEngine.processGSTOnlineAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"url":"https://apidemo.perfios.com/KYCServer/api/v2/tr/82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","transactionId":null,"success":null,"generateLinkId":"82ad3b6e-8304-4dc6-b6a8-0df6210dcbc1","expires":"2022-01-08 22:06:07 Asia/Kolkata","clientTransactionId":"03012022220607219"}';
            System.assertEquals(responseExpected, itrResponse, 'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'List has no rows for assignment to SObject', 'Exception');
        }
    }
    
  /*  @isTest
    public static void verifyGetPerfiosGSTReportRequest(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        insert opp;
        
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c=opp.Id;
        
        insert applicant;
        
        
        try{
            IND_PerfiosGSTOnlineService result = IND_PerfiosGSTOnlineService.getPerfiosGSTOnlineRequest(applicant, opp.Id);
            System.debug('result ==>'+result);
        }catch(Exception pEx){
            System.debug('pEx ==>'+pEx); 
        }  
    } */
    
     @isTest
    public static void getPerfiosGSTOnlineRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        
        try{
          IND_PerfiosGSTOnlineService.getPerfiosGSTOnlineRequest(reqWrapper);       
        }catch(Exception e){}
        
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
                      IND_PerfiosGSTOnlineRequest gr1 = new IND_PerfiosGSTOnlineRequest(rw1);
                      Map<String,String> gr2 = gr1.getHttpRequestHeaders();
                Test.stopTest();
    }
}