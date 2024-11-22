/*------------------------------------------------------------
Author:        Thilak Bondiga
Company:       Persistent Systems
Description:   Test class for IND_PerfiosITRReportRequest class 
Apex Class:    IND_PerfiosITRReportRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Thilak Bondiga       Created
------------------------------------------------------------*/
@isTest
public class IND_PerfiosITRReportService_Test {
     // @Method:        TestServiceMetthod
    // @Created by: Thilak Bondiga
    // @Description:Test setup method to create the test data for IND_PerfiosITRReportRequest classs
    // @Param:      ''  
    // @Return:     '' 
  /*  @isTest
    public static void testIND_PerfiosITRReportService(){
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
            
            
            Continuation con = (Continuation)IntegrationEngine.doITRReportCallout(applicant.Id);
            
            // Create a mock response 
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"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"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String itrResponse = (String)IntegrationEngine.processITRReportAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            system.debug('itrResponse '+itrResponse);
            String responseExpected ='{ "itrDetails": { "filingDetailsList": [ { "filingDatesDiff": "0", "isItrNotFiledForPrevYear": "NA", "filingDatesLTSixMonths": "NA" } ], "itrInfoList": { "itr": [ { "date": "2020-11-26", "deductionsUnderScheduleVIA": 0, "personalInfo": { "firstName": "", "surNameOrOrgName": "Venkata Rajkumar Puvvada", "addressInfo": { "localityOrArea": "Sanath Nagar", "roadOrStreet": "", "pinCode": "500082", "residenceNo": "513", "cityOrTownOrDistrict": "HYDERABAD", "state": "TELANGANA", "residenceName": "Vasavi Central Court" }, "emailAddress": "rajkumar_puvvada@rediffmail.com", "address": "513 , Vasavi Central Court, Sanath Nagar, HYDERABAD, TELANGANA, 500082", "dob": "17/05/1976", "aadhaarCardNo": "645842284557", "name": "Venkata Rajkumar Puvvada", "mobileNo": "91 - 9490987588", "pan": "AJWPP6120D", "employerCategory": "Others" }, "lateFilingFee234F": 0, "totalSurcharge": 0, "incChargeTaxSplRate111A112": 0, "incomeFromSal": 2007724, "origRetFiledDate": "", "losses": { "lossesOfCurrentYearCarriedFwd": 0, "currentYearLoss": 0, "broughtFwdLossesSetoff": 0 }, "type": "ITR-1", "ackNoOriginalReturn": "750186000261120", "taxPaid": { "selfAssessmentTax": 0, "tds": 426091, "balTaxPayable": 0, "refundDue": 47010, "advanceTax": 0, "tcs": 0, "totalTaxesPaid": 426091 }, "totTaxRelief": 0, "fy": "2019-20", "rebate87A": 0, "taxPayableOnRebate": 364506, "totIncFromOS": 0, "intrstPayUs234A": 0, "intrstPayUs234B": 0, "profBusGain": { "profGainSpeculativeBus": 0, "profGainSpecifiedBus": 0, "profGainNoSpecBus": 0, "totProfBusGain": 0 }, "intrstPayUs234C": 0, "aggregateIncome": 0, "bankAccountDtls": { "priBankDetails": [ { "bankAccountType": null, "useForRefund": null, "bankAccountNo": "50100017064517", "bankName": "HDFC BANK", "ifscCode": "HDFC0000628" } ], "addtnlBankDetails": [ { "bankAccountType": null, "useForRefund": null, "bankAccountNo": null, "bankName": null, "ifscCode": null } ] }, "aggregateTaxInterestLiability": 0, "capGain": { "totalLongTerm": 0, "totalShortTerm": 0, "totalCapGains": 0 }, "incomeFromHP": 0, "grossTaxLiability": 379086, "incChargeableTaxSplRates": 0, "totTaxPlusIntrstPay": 379086, "taxPayableOnTotInc": 0, "totalIncome": 80, "tdSonSalaries": { "tdSonSalary": null, "totalTDSonSalaries": 0 }, "educationCess": 14580, "grossTotalIncome": 2007724, "receiptNo": "", "ay": "2020-21", "netTaxLiability": 0, "netAgricultureIncomeOrOtherIncomeForRate": 0, "totalIntrstPay": 0, "totalExemptInc": 0, "returnType": "" } ] } } }';
            //System.assertEquals(responseExpected, itrResponse);
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void testIND_PerfiosITRReportService2(){
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
            
            
            Continuation con = (Continuation)IntegrationEngine.doITRReportCallout(applicant.Id);
            
            // Create a mock response 
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"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"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String itrResponse = (String)IntegrationEngine.processITRReportAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            system.debug('itrResponse '+itrResponse);
            String responseExpected ='{ "itrDetails": { "filingDetailsList": [ { "filingDatesDiff": "0", "isItrNotFiledForPrevYear": "NA", "filingDatesLTSixMonths": "NA" } ], "itrInfoList": { "itr": [ { "date": "2020-11-26", "deductionsUnderScheduleVIA": 0, "personalInfo": { "firstName": "", "surNameOrOrgName": "Venkata Rajkumar Puvvada", "addressInfo": { "localityOrArea": "Sanath Nagar", "roadOrStreet": "", "pinCode": "500082", "residenceNo": "513", "cityOrTownOrDistrict": "HYDERABAD", "state": "TELANGANA", "residenceName": "Vasavi Central Court" }, "emailAddress": "rajkumar_puvvada@rediffmail.com", "address": "513 , Vasavi Central Court, Sanath Nagar, HYDERABAD, TELANGANA, 500082", "dob": "17/05/1976", "aadhaarCardNo": "645842284557", "name": "Venkata Rajkumar Puvvada", "mobileNo": "91 - 9490987588", "pan": "AJWPP6120D", "employerCategory": "Others" }, "lateFilingFee234F": 0, "totalSurcharge": 0, "incChargeTaxSplRate111A112": 0, "incomeFromSal": 2007724, "origRetFiledDate": "", "losses": { "lossesOfCurrentYearCarriedFwd": 0, "currentYearLoss": 0, "broughtFwdLossesSetoff": 0 }, "type": "ITR-1", "ackNoOriginalReturn": "750186000261120", "taxPaid": { "selfAssessmentTax": 0, "tds": 426091, "balTaxPayable": 0, "refundDue": 47010, "advanceTax": 0, "tcs": 0, "totalTaxesPaid": 426091 }, "totTaxRelief": 0, "fy": "2019-20", "rebate87A": 0, "taxPayableOnRebate": 364506, "totIncFromOS": 0, "intrstPayUs234A": 0, "intrstPayUs234B": 0, "profBusGain": { "profGainSpeculativeBus": 0, "profGainSpecifiedBus": 0, "profGainNoSpecBus": 0, "totProfBusGain": 0 }, "intrstPayUs234C": 0, "aggregateIncome": 0, "bankAccountDtls": { "priBankDetails": [ { "bankAccountType": null, "useForRefund": null, "bankAccountNo": "50100017064517", "bankName": "HDFC BANK", "ifscCode": "HDFC0000628" } ], "addtnlBankDetails": [ { "bankAccountType": null, "useForRefund": null, "bankAccountNo": null, "bankName": null, "ifscCode": null } ] }, "aggregateTaxInterestLiability": 0, "capGain": { "totalLongTerm": 0, "totalShortTerm": 0, "totalCapGains": 0 }, "incomeFromHP": 0, "grossTaxLiability": 379086, "incChargeableTaxSplRates": 0, "totTaxPlusIntrstPay": 379086, "taxPayableOnTotInc": 0, "totalIncome": 80, "tdSonSalaries": { "tdSonSalary": null, "totalTDSonSalaries": 0 }, "educationCess": 14580, "grossTotalIncome": 2007724, "receiptNo": "", "ay": "2020-21", "netTaxLiability": 0, "netAgricultureIncomeOrOtherIncomeForRate": 0, "totalIntrstPay": 0, "totalExemptInc": 0, "returnType": "" } ] } } }';
          //  System.assertEquals(responseExpected, itrResponse);
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    } */
    
    @isTest
    public static void getPerfiosITRReportRequest(){
        
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opgd1.Id;
        appList.add(applicant);
        insert appList;
        try{
        IND_PerfiosITRReportService.getPerfiosITRReportRequest(appList[0]); 
        }catch(Exception e){}
        
    }
    
}