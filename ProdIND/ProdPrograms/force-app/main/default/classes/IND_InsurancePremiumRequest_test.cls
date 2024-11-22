/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_APDPendingRequest class 
Apex Class:    IND_APDPendingRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_InsurancePremiumRequest_test {
    
    
    @isTest
    public static void testInsurancePremiumService2(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = applicant.Id;
                 dfks1.Opportunity_Relation__c = opp.Id;
                 dfks1.Document_Type__c = 'Aadhaar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = System.Label.AadhaarCard;
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Gender__c = 'MALE';
                 insert dfks1;
            
            
            Continuation con = (Continuation)IntegrationEngine.doInsurancePremiumCallout(applicant.Id,'GPA','PPD_2L_1Y',loanAppId);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData": "g0B3b1vDdO/jNH/nOcUjwA/cuqsPuMuSzjCXs8AGokDoun20l+1qJ9Ohnc4x5VA2HszU4Q4vGrvz2hGnqmIo3RN6MBI7sOYNDz831IlBNDMFYwK8gXPRhSDqb60KO8R8MPUmGtSu9oVdcP/EEBiR06P9MpV5yA3KrXIO9DArsXOOqnBZWk9oQSlnTXGZks1Oc/1BH8ERA3m2OUOyfIuvcPgASBGwh7vphasHa/Ta/hCSsFXpHATBmcMjKY6GQsD51tJIjYFMhjrCBxKbkWNSTEL0XNa0aLkaghRFzgW1HCbou1i8nw4PDlm7RSiN1q7xa11yR4YmhhsFS62pbBN9h1GoIlgKAxFMaKkB/eVHp56cXuKa2ZBeKuf8Kn2idBh38ulwEujzJcDzurCeKJpOOiyERXJO7FaHivf2Abzscnw=');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processInsurancePremiumAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{ "Application_No": "A1234567", "Vehicle_ID": "1", "Premium_Details": [ { "Ins_Product": "Flexi", "Plan_Code": "FLEXI_3L2Y", "Premium": "2567" }, { "Ins_Product": "GPA", "Plan_Code": "CV34", "Premium": "3105" }, { "Ins_Product": "Motor", "Plan_Code": "", "Premium": "7000" } ], "Status_Flag": "Success", "Error_Code": "200", "Error_Description": "" }';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.debug('ex.getMessage -> '+ ex.getMessage());
            // System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    
    @isTest
    public static void testInsurancePremiumService3(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Application_number__c='1213242';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            List<IND_InsurancePremiumRequest.Product_Details> productDetailList = new List<IND_InsurancePremiumRequest.Product_Details>();
            IND_InsurancePremiumRequest.Product_Details productDetailObj = new IND_InsurancePremiumRequest.Product_Details();
                    productDetailObj.Ins_Product = 'MOTOR';
                    productDetailObj.Opt_YN = 'Y';
                    productDetailObj.Plan_Code = '';
                    productDetailObj.Premium = '';
                    productDetailObj.Fund_YN = 'Y';
            productDetailList.add(productDetailObj);
            String proDetail = JSON.serialize(productDetailList);
            
            Continuation con = (Continuation)IntegrationEngine.doInsurancePremiumCallout(applicant.Id,proDetail,'PPD_2L_1Y',loanAppId);
            
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData": "g0B3b1vDdO/jNH/nOcUjwA/cuqsPuMuSzjCXs8AGokDoun20l+1qJ9Ohnc4x5VA2HszU4Q4vGrvz2hGnqmIo3RN6MBI7sOYNDz831IlBNDMFYwK8gXPRhSDqb60KO8R8MPUmGtSu9oVdcP/EEBiR06P9MpV5yA3KrXIO9DArsXOOqnBZWk9oQSlnTXGZks1Oc/1BH8ERA3m2OUOyfIuvcPgASBGwh7vphasHa/Ta/hCSsFXpHATBmcMjKY6GQsD51tJIjYFMhjrCBxKbkWNSTEL0XNa0aLkaghRFzgW1HCbou1i8nw4PDlm7RSiN1q7xa11yR4YmhhsFS62pbBN9h1GoIlgKAxFMaKkB/eVHp56cXuKa2ZBeKuf8Kn2idBh38ulwEujzJcDzurCeKJpOOiyERXJO7FaHivf2Abzscnw=');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processInsurancePremiumAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{ "Application_No": "A1234567", "Vehicle_ID": "1", "Premium_Details": [ { "Ins_Product": "Flexi", "Plan_Code": "FLEXI_3L2Y", "Premium": "2567" }, { "Ins_Product": "GPA", "Plan_Code": "CV34", "Premium": "3105" }, { "Ins_Product": "Motor", "Plan_Code": "", "Premium": "7000" } ], "Status_Flag": "Success", "Error_Code": "200", "Error_Description": "" }';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.debug('ex.getMessage -> '+ ex.getMessage());
            //System.assertEquals(ex.getMessage(),System.Label.Product,'ex');
        }
    }
    
    
     @isTest
    public static void verifyIND_InsurancePremiumRequest(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG-001';
        opgd1.Application_number__c = '2984';
        opgd1.Age__c = 27.0;
        opgd1.Loan_amount__c = '89999.00';
        opgd1.Required_Tenure__c = 7.0;
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Borrower';
        applicant.Scorecard_Decision__c = 'Red';
        applicant.Contact_number__c = '9898989898';
        applicant.Gender__c = 'MALE';
        applicant.Residence_country__c = 'India';
        applicant.DocAuth_Application_Id__c = '26936700';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
        vehicleDetail.Loan_Application__c = opgd1.Id;
        vehicleDetail.Product__c = 'Two Wheeler';
        insert vehicleDetail;
        
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c doc = new Documents__c();
        doc.Proof_of_Identity_POI__c= true;
        doc.Applicant__c=applicant.Id;
        doc.Gender__c='MALE';
        doc.KYC_DOB__c=Date.parse('06/07/2000');
        doc.Opportunity_Relation__c=opgd1.Id;
        doc.Document_Type__c='4';

        Documents__c doc1 = new Documents__c();
        doc1.Proof_of_Identity_POI__c= false;
        doc1.Applicant__c=applicant.Id;
        doc1.Gender__c='MALE';
        doc1.KYC_DOB__c=Date.parse('06/07/2000');
        doc1.Opportunity_Relation__c=opgd1.Id;
        doc1.Document_Type__c='Pan';
        
        Final_Term__c ft2 = new Final_Term__c();
        ft2.CRM_IRR__c = 120;
        ft2.Loan_Application__c = opgd1.Id;
        ft2.Holiday_period__c='30';
        ft2.EMI_Amount__c= 10000;
        ft2.FIwaiver_offAddress__c = 'Not Waived';
        ft2.Loan_Amount__c = '1500000345';
        ft2.Tenure__c='56';
        insert ft2;
        
        insert doc;
        insert doc1;
        dcList.add(doc);
        dcList.add(doc1);

        
        //IND_InsurancePremiumRequest objResult = new IND_InsurancePremiumRequest(applicant, '[{"Ins_Product":"COMBO","Plan_Code":"2WCOMBO4","Plan_Name":"Group +Hospital Cash Daily(HDC) Combo","Sum_Insured":"0.00","Premium":"1590.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}]', 'P-112', String.valueOf(opgd1.Id));
        //Map<String,String> resultHeadersMap = objResult.getHttpRequestHeaders();
        //System.assert(!resultHeadersMap.isEmpty());
    }
    
    @isTest
    public static void verifyIND_InsurancePremiumRequest2(){
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = '';
        opgd1.Agent_BL_code__c = 'AG-001';
        opgd1.Application_number__c = '2984';
        opgd1.Age__c = 27.0;
        opgd1.Loan_amount__c = '89999.00';
        opgd1.Required_Tenure__c = 7.0;
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Borrower';
        applicant.Scorecard_Decision__c = 'Red';
        applicant.Contact_number__c = '9898989898';
        applicant.Gender__c = 'MALE';
        applicant.Residence_country__c = 'India';
        applicant.DocAuth_Application_Id__c = '26936700';
        String loanAppId = applicant.Opportunity__r.id;
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
        vehicleDetail.Loan_Application__c = opgd1.Id;
        vehicleDetail.Product__c = 'Two Wheeler';
        insert vehicleDetail;
        
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c doc = new Documents__c();
        doc.Proof_of_Identity_POI__c= true;
        doc.Applicant__c=applicant.Id;
        //doc.Gender__c='MALE';
        //doc.KYC_DOB__c=Date.parse('06/07/2000');
        doc.Opportunity_Relation__c=opgd1.Id;
        doc.Document_Type__c='4';

        Documents__c doc1 = new Documents__c();
        doc1.Proof_of_Identity_POI__c= false;
        doc1.Applicant__c=applicant.Id;
        //doc1.Gender__c='MALE';
        //doc1.KYC_DOB__c=Date.parse('06/07/2000');
        doc1.Opportunity_Relation__c=opgd1.Id;
        doc1.Document_Type__c='Pan';
        
        insert doc;
        insert doc1;
        dcList.add(doc);
        dcList.add(doc1);

        Continuation con = (Continuation)IntegrationEngine.doInsurancePremiumCallout(applicant.Id,'[{"Ins_Product":"COMBO","Plan_Code":"2WCOMBO4","Plan_Name":"Group +Hospital Cash Daily(HDC) Combo","Sum_Insured":"0.00","Premium":"1590.00","Plan_Recommend":"N","Disable_Funding":"N","Funding_Option":"N"}]','PPD_2L_1Y',loanAppId);
            
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData": "g0B3b1vDdO/jNH/nOcUjwA/cuqsPuMuSzjCXs8AGokDoun20l+1qJ9Ohnc4x5VA2HszU4Q4vGrvz2hGnqmIo3RN6MBI7sOYNDz831IlBNDMFYwK8gXPRhSDqb60KO8R8MPUmGtSu9oVdcP/EEBiR06P9MpV5yA3KrXIO9DArsXOOqnBZWk9oQSlnTXGZks1Oc/1BH8ERA3m2OUOyfIuvcPgASBGwh7vphasHa/Ta/hCSsFXpHATBmcMjKY6GQsD51tJIjYFMhjrCBxKbkWNSTEL0XNa0aLkaghRFzgW1HCbou1i8nw4PDlm7RSiN1q7xa11yR4YmhhsFS62pbBN9h1GoIlgKAxFMaKkB/eVHp56cXuKa2ZBeKuf8Kn2idBh38ulwEujzJcDzurCeKJpOOiyERXJO7FaHivf2Abzscnw=');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processInsurancePremiumAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{ "Application_No": "A1234567", "Vehicle_ID": "1", "Premium_Details": [ { "Ins_Product": "Flexi", "Plan_Code": "FLEXI_3L2Y", "Premium": "2567" }, { "Ins_Product": "GPA", "Plan_Code": "CV34", "Premium": "3105" }, { "Ins_Product": "Motor", "Plan_Code": "", "Premium": "7000" } ], "Status_Flag": "Success", "Error_Code": "200", "Error_Description": "" }';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.debug('ex.getMessage -> '+ ex.getMessage());
           // System.assertEquals(ex.getMessage(),System.Label.Age,'ex');
        }
    }
    
    
}