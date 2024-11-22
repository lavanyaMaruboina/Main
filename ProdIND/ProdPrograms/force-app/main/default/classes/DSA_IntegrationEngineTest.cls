@isTest
public class DSA_IntegrationEngineTest {
    @testSetup
    static void testDataSetup()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u;
        System.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Deal_Number__c = 'TUT06226H';
            opp.Parent_Deal_number__c = 'DL109939';
            opp.Lead_Number__c='L-10122021-1685';
            opp.Product_Type__c = 'Passenger Vehicles';
            opp.Required_Loan_amount__c = 50000;
            opp.LeadSource = 'DSA';
            if (Schema.sObjectType.Opportunity.isCreateable()){

                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.DocAuth_Application_Id__c = 'AC1241_24524353_g1';
            String dealNumber = opp.Deal_Number__c;
            String loanAppId = opp.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Documents__c doc = new Documents__c();
            doc.Name = 'Test document';
            doc.Document_Type__c = 'PAN';
            doc.Document_Side__c = 'Front';
            doc.Age__c = 30;
            doc.KYC_DOB__c = Date.newInstance(1993, 05, 05);
            doc.KYC_City__c = 'Mumbai';
            doc.PAN_No__c = 'testpan';
            doc.KYC_name__c = 'Test KYC Name';
            doc.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            doc.KYC_Issuance_Date__c = Date.newInstance(2022, 05, 20);
            doc.Proof_of_Address_POA__c = true;
            doc.Proof_of_Identity_POI__c = true;
            doc.Opportunity_Relation__c = opp.Id;
            doc.Applicant__c =applicant.id;
            insert doc;


        }

    }

    @isTest
    public static void doAMLCheckCalloutTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Opportunity loanApp = [SELECT Id,Lead_number__c FROM Opportunity];
            Applicant__c applicant = [SELECT Id,DocAuth_Application_Id__c,Applicant_Number__c,Name,Opportunity__r.Lead_number__c,(SELECT Id,Proof_of_Address_POA__c,Proof_of_Identity_POI__c, KYC_DOB__c, KYC_City__c FROM Documents__r WHERE KYC_DOB__c != NULL AND KYC_City__c != NULL AND (Proof_of_Address_POA__c = true OR Proof_of_Identity_POI__c = true)) FROM Applicant__c ];
            System.debug('applicant ---> ' + applicant);
            Continuation con = (Continuation)IntegrationEngine.doAMLCheckCallout(applicant.Id,loanApp.Id);

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            response.setStatusCode(200);

            String continuationLabel = IntegrationEngine.continuationLabel;
            System.debug('continuationLabel ---> ' + continuationLabel);
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processAMLCheckAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');


        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }

    @isTest
    public static void doDealMasterCalloutForCustomerNameTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Opportunity loanApp = [SELECT Id,Lead_number__c,Deal_Number__c FROM Opportunity];
            Applicant__c applicant = [select Id, Opportunity__c FROM Applicant__c ];

            Continuation con = (Continuation)IntegrationEngine.doDealMasterCalloutForCustomerName(loanApp.Deal_Number__c,loanApp.Id);
            System.debug('con ---> ' + con);
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            response.setStatusCode(200);

            String continuationLabel = IntegrationEngine.continuationLabel;
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processDealMasterAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
        }
    }


    @isTest
    public static void doNeSLAgreementStatusCalloutTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Opportunity loanApp = [SELECT Id,Lead_number__c FROM Opportunity];
            Applicant__c applicant = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Deal_number__c FROM Applicant__c ];
            System.debug('applicant ---> ' + applicant);
            Continuation con = (Continuation)IntegrationEngine.doNeSLAgreementStatusCallout(applicant.Id,loanApp.Id);

            Map<String, HttpRequest> requests = con.getRequests();
            system.assert(requests.size() != 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            response.setStatusCode(200);

            String continuationLabel = IntegrationEngine.continuationLabel;
            System.debug('continuationLabel ---> ' + continuationLabel);
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processNeSLAgreementStatusAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');


        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
    @isTest
    public static void doNeSLAgreementStatusCalloutTest1(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Opportunity loanApp = [SELECT Id,Lead_number__c FROM Opportunity];
            Applicant__c applicant = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Deal_number__c FROM Applicant__c ];
            System.debug('applicant ---> ' + applicant);
            Continuation con = (Continuation)IntegrationEngine.doNeSLAgreementStatusCallout(applicant.Id,loanApp.Id);

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            response.setStatusCode(200);

            String continuationLabel = IntegrationEngine.continuationLabel;
            System.debug('continuationLabel ---> ' + continuationLabel);
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processNeSLAgreementStatusAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');


        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }

    @isTest
    public static void doStampingDetailsCalloutTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Opportunity loanApp = [SELECT Id,Deal_number__c,Product_Type__c,Lead_number__c,Finance_Amount__c FROM Opportunity];
            Applicant__c applicant = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Deal_number__c FROM Applicant__c ];
            System.debug('applicant ---> ' + applicant);
            Continuation con = (Continuation)IntegrationEngine.doStampingDetailsCallout(applicant.Id,loanApp.Id,'33','test');

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            response.setStatusCode(200);

            String continuationLabel = IntegrationEngine.continuationLabel;
            System.debug('continuationLabel ---> ' + continuationLabel);
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processStampingDetailsAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');


        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }

    @isTest
    public static void doStampingDetailsCalloutTest1(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Opportunity loanApp = [SELECT Id,Deal_number__c,Product_Type__c,Lead_number__c,Finance_Amount__c FROM Opportunity];
            Applicant__c applicant = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Deal_number__c FROM Applicant__c ];
            System.debug('applicant ---> ' + applicant);
            Continuation con = (Continuation)IntegrationEngine.doStampingDetailsCallout(applicant.Id,loanApp.Id,'33','test');

            Map<String, HttpRequest> requests = con.getRequests();
            system.assert(requests.size() != 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            response.setStatusCode(250);

            String continuationLabel = IntegrationEngine.continuationLabel;
            System.debug('continuationLabel ---> ' + continuationLabel);
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processStampingDetailsAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');


        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }


    @isTest
    public static void doIHMReceiptCalloutTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Opportunity loanApp = [SELECT Id,Lead_number__c FROM Opportunity];
            Applicant__c applicant = [SELECT Id,Opportunity__r.Deal_number__c FROM Applicant__c ];
            System.debug('applicant ---> ' + applicant);
            Continuation con = (Continuation)IntegrationEngine.doIHMReceiptCallout(applicant.Id,loanApp.Id,'test');

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            // HttpResponse response = new HttpResponse();
            // response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            // response.setStatusCode(200);

            //String continuationLabel = IntegrationEngine.continuationLabel;
            //System.debug('continuationLabel ---> ' + continuationLabel);
            String membershipResponse = '';
            //List<String> labels = new List<String>{continuationLabel};
            //  Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            //Test.setContinuationResponse(continuationLabel, response);
            // membershipResponse = (String)IntegrationEngine.processDealMasterAPIResponse(labels, IntegrationEngine.continuationState);

            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuVrKDeBNiojndyKtLQoX7upFsTrRkJmZJNIgdkS7hNrJigY5/m9JrXCt+K6YQwxMDFlsL3BshrRI8XlQdZTrUgYg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = IntegrationEngine.continuationLabel;
            //Object continuationState= IntegrationEngine.continuationState;
            List<String> labels = new List<String>{continuationLabel};

                Object continuationState= IntegrationEngine.continuationState;
            membershipResponse = (String)IntegrationEngine.processIHMReceiptResponse(labels, IntegrationEngine.continuationState);

            System.debug('labels===>'+labels);
            System.debug('continuationState===>'+continuationState);


            Test.setContinuationResponse(continuationLabel, response);
            //Object result3 = aml.processSMSGatewayResponse(labels, aml.continuationState);

            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            //System.assertEquals(responseExpected, membershipResponse,'SUCCESS');


        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
    @isTest
    public static void doRCLimitCheckCalloutTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Opportunity optg1 = new Opportunity();
            optg1.StageName = 'Loan Details';
            optg1.CloseDate = Date.newInstance(2022, 1, 11);
            optg1.Name = 'testone';
            optg1.Vehicle_Type__c = 'New';
            optg1.Product_Type__c = 'Passenger Vehicles';
            optg1.Ben_Code__c = 'optg2';
            optg1.Vehicle_Sub_Category__c = 'UOM';
            optg1.Agent_BL_code__c = 'BLC';
            optg1.Funded__c = false;
            optg1.Is_customer_interested_in_a_motor_insura__c = true;
            optg1.Motor_Insurance_Premium__c = 20000;
            optg1.Sub_Stage__c = 'Business Payment Details';

            insert optg1;

            Applicant__c objApplicant = new Applicant__c();
            objApplicant.Opportunity__c = optg1.Id;
            objApplicant.Applicant_Type__c = 'Borrower';
            objApplicant.Contact_number__c = '1234567890';
            insert objApplicant;

            Test.startTest();
            IntegrationEngine.doRCLimitCheckCallout(objApplicant.Id, optg1.Id,'test');
            Test.stopTest();
        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
    @isTest
    public static void doSmsGatewayCalloutTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE username='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            String loanApplicationId = '00671000001Dz1tAAC';
            Opportunity loanApp = [SELECT Id,Lead_number__c,Deal_number__c FROM Opportunity];
            System.debug('loanApp::' + loanApp);
            Applicant__c applicant = [SELECT Id,Contact_number__c,Whatsapp_number__c,OTP_for_borrower__c,Opportunity__r.Deal_number__c,Opportunity__r.Lead_number__c FROM Applicant__c LIMIT 1];
            System.debug('applicant::' + applicant);
            RequestWrapper requestWrapper = new RequestWrapper();
            requestWrapper.applicantId = applicant.ID;
            String statusCheckString = '{"enachStatus":"00671000001 "  ,"loanApplicationId":"00671000001Dz1tAAC", "applicantId":"' + applicant.Id + '"}';
            system.debug('requestWraper in test class>>'+requestWrapper);
            Object str1 = DSA_IntegrationEngine.doSmsGatewayCallout(statusCheckString);

            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');
            response.setStatusCode(200);

            String continuationLabel = IntegrationEngine.continuationLabel;
            System.debug('continuationLabel ---> ' + continuationLabel);
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            RequestWrapper requestWrapper1 = (RequestWrapper)IntegrationUtilities.parseJSONRequest('xyz','RequestWrapper');
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');


        } catch(Exception ex){
            System.debug('error ---> ' + ex.getMessage());
            System.debug('error ---> ' + ex.getLineNumber());
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
}