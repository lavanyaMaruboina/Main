public class DSA_IntegrationEngine {
    //variable refers to the async service name
    public static String serviceName { get; set; }
    //variable refers to the async ParentAPIRequest
    public static ParentAPIRequest parentAPIRequest { get; set; }

    // Test variable used for holding a reference to the Continuation Request
    @TestVisible
    public static String continuationLabel;

    // Test variable used for holding the value of the Continuation.state attribute
    @TestVisible
    public static Object continuationState;

    public static String loanApplicationRef;

    /*
     * @Method:      doSmsGatewayCallout
     * @Created by:  Divya Jawale
     * @Description: Method to return Response for SMS Getway API
     * @Param:       String - Applicant Id
     * @Return:      String - response
     */
    @AuraEnabled(continuation=true)
    public static Object doSmsGatewayCallout(String smsRequestString) {
        Continuation con;
        String loanAppId;
        try {
            if (String.isBlank(smsRequestString)) {
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.SMSGateway);

            //if stubs checked in Integration_Configuration then stubs will return
            if (apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c) {
                String stubData = IntegrationUtilities.getStubResponse(System.Label.SMSGateway);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }

            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            System.debug('smsRequestString>>' + smsRequestString);
            RequestWrapper requestWrapper = (RequestWrapper) IntegrationUtilities.parseJSONRequest(smsRequestString, 'RequestWrapper');
            List<Applicant__c> app = [
                SELECT Id, Contact_number__c, Whatsapp_number__c, OTP_for_borrower__c, Opportunity__r.Lead_number__c
                FROM Applicant__c
                WHERE Id = :requestWrapper.applicantId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (app.isEmpty()) {
                throw new IND_Exception(System.Label.Applicantdatamissing);
            } else {
                for (Applicant__c applicant : app) {
                    requestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c;
                    requestWrapper.contactNumber = applicant.Contact_number__c;
                    requestWrapper.otpForBorrower = applicant.OTP_for_borrower__c;
                    if (requestWrapper.flag.equals('AML')) {
                        requestWrapper.otpForBorrower = '';
                    }
                    requestWrapper.whatsappNo = applicant.Whatsapp_number__c;
                }
            }

            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef = requestWrapper.loanApplicationId;
            IND_SMSRequest smsRequest = IND_SMSService.getSmsCallOutRequest(requestWrapper);
            CalloutProcessor processor = new CalloutProcessor(System.Label.SMSGateway, smsRequest);
            HttpRequest request = processor.createHttpRequest();

            Long startTime = DateTime.now().getTime();

            Carrier carrier = new carrier(System.Label.SMSGateway, processor, request.getBody(), startTime, loanAppId, IntegrationUtilities.getPlainTextForLog(request.getBody()));

            //Add callout request to continuation
            con = new Continuation(timeout);
            con.continuationMethod = 'processSMSGatewayResponse';
            con.state = carrier;
            con.addHttpRequest(request);

            if (Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier;
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSmsGatewayCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }

    /*
     * @Method:      processSMSGatewayResponse
     * @Created by:  Divya Jawale
     * @Description: Method to return Response for SMS Getway API
     * @Param:       Collection - labels
     * @Param:       Object - state
     * @Return:      Object - response
     */
    @AuraEnabled
    public static Object processSMSGatewayResponse(List<String> labels, Object state) {
        IND_SMSResponse apiResponse;
        String request = '';
        String encryptedRequest = '';
        String serviceName = '';
        String data = '';
        HttpResponse response;
        String elapseTime = '';
        String loanAppId = '';
        try {
            Carrier carrier = (Carrier) state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();

            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
            loanAppId = carrier.getLoanApplicationId();
            if (response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_SMSResponse) processor.getHttpResponse(response, serviceName);
                if (apiResponse != null && apiResponse.response.status == 'SUCCESS') {
                    data = apiResponse.response.status;
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                } else {
                    data = 'FAIL';
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                }
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                data = System.Label.NoResponse;
            }
        } catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processResponseSMS', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }

    /*
     * @Method:      doCIBILReportCallout
     * @Created by:  Divya Jawale
     * @Description: Method to return Response for CIBIL Request Response API
     * @Param:       String - Applicant Id
     * @Return:      String - response
     */
    @AuraEnabled(continuation=true)
    public static Object doCIBILReportCallout(String cibilRequestString) {
        Continuation con;
        String loanAppId;
        String customer_Code;
        try {
            if (String.isBlank(cibilRequestString)) {
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GetCIBILReportAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            //if stubs checked in Integration_Configuration then stubs will return
            if (apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c) {
                String stubData = IntegrationUtilities.getStubResponse(System.Label.GetCIBILReportAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }

            RequestWrapper requestWrapper = (RequestWrapper) IntegrationUtilities.parseJSONRequest(cibilRequestString, 'RequestWrapper');
            Applicant__c app = [
                SELECT
                    Id,
                    Contact_number__c,
                    Opportunity__r.Lead_number__c,
                    Opportunity__r.Agent_BL_code__c,
                    Customer_First_Name__c,
                    Opportunity__r.Loan_amount__c,
                    Customer_Last_Name__c,
                    Loan_Amount__c,
                    Current_Same_As_Permanent__c,
                    Is_Existing_Customer__c,
                    Applicant_Type__c,
                    Opportunity__r.Product_Type__c,
                    Father_s_name__c,
                    Mother_s_name__c,
                    Spouse_Name__c,
                    Email_Id__c,
                    Opportunity__r.account.name,
                    applicant_number__c,
                    Opportunity__r.LeadSource //DSAMODIFYEXISTING
                FROM Applicant__c
                WHERE Id = :requestwrapper.applicantId
                WITH SECURITY_ENFORCED
            ];
            List<Documents__c> docs = [
                SELECT
                    Id,
                    Document_Type__c,
                    KYC_DOB__c,
                    Gender__c,
                    KYC_Address_Line_1__c,
                    KYC_Address_Line_2__c,
                    KYC_City__c,
                    KYC_State__c,
                    KYC_Pin_Code__c,
                    Salutation__c,
                    PAN_No__c,
                    Passport_No__c,
                    KYC_No__c,
                    KYC_name__c
                FROM Documents__c
                WHERE Applicant__c = :requestwrapper.applicantId
                WITH SECURITY_ENFORCED
            ];
            List<CIBIL_Details__c> cibilDetails = [
                SELECT Id, Name, Applicant__c, CIBIL_Report_URl__c, Equifax_Report_URl__c
                FROM CIBIL_Details__c
                WHERE Applicant__c = :requestwrapper.applicantId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            List<Customer_dedupe_response__c> custDedupe = [SELECT Customer_Code__c FROM customer_dedupe_response__c WHERE applicant__c = :requestWrapper.applicantId WITH SECURITY_ENFORCED LIMIT 1];
            if (!custDedupe.isEmpty()) {
                for (Customer_dedupe_response__c cust : custDedupe) {
                    customer_Code = cust.Customer_Code__c != null ? cust.Customer_Code__c : '';
                }
            } else {
                customer_Code = '';
            }

            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef = requestWrapper.loanApplicationId;
            IND_CIBILRequestDSA cibilreportRequest = IND_CIBILServiceDSA.getcibilCallout(app, docs, loanAppId, cibilDetails, customer_Code);
            CalloutProcessor processor = new CalloutProcessor(System.Label.GetCIBILReportAPI, cibilreportRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            objList.add(app);
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.GetCIBILReportAPI);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            carrier.setTempObject(objList);

            //Add callout request to continuation
            con = new Continuation(timeout);
            con.continuationMethod = 'processCIBILReportResponse';
            con.state = carrier;
            con.addHttpRequest(request);

            if (Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier;
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCIBILReportCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }

    /*
     * @Method:      processCIBILReportResponse
     * @Created by:  Divya Jawale
     * @Description: Method to return Response for CIBIL Report API
     * @Param:       Collection - labels
     * @Param:       Object - state
     * @Return:      Object - response
     */
    @AuraEnabled
    public static Object processCIBILReportResponse(List<String> labels, Object state) {
        IND_CIBILResponse apiResponse;
        String request = '';
        String encryptedRequest = '';
        String serviceName = '';
        String data = '';
        HttpResponse response;
        String elapseTime = '';
        List<Object> objList;
        String loanAppId = '';

        try {
            Carrier carrier = (Carrier) state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
            loanAppId = carrier.getLoanApplicationId();
            if (response != null && (response.getStatusCode() == 200)) {
                apiResponse = (IND_CIBILResponse) processor.getHttpResponse(response, serviceName);
                if (apiResponse != null) {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                    data = JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else if (response != null && response.getStatusCode() == 400) {
                String responseBody = '';
                String decryptedResponse = '';
                Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
                responseBody = response.getBody();
                responseBody = responseBody.substring(10, responseBody.length() - 2);
                decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody, System.Label.privateKey, System.Label.ivkey);

                String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                apiResponse = (IND_CIBILResponse) IntegrationUtilities.parseJSONResponse(searalizedJson, apiConfiguration.Response_wrapper__c);
                if (apiResponse != null) {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                    data = JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCIBILReportResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }

    /*
     * @Method:      doGatingScreeningCheckEligibilityCallout
     * @Created by:  Aman Mundhada
     * @Description: Continuation for Gating Screening-Check Eligibility
     * @Param:       String - checkEligibilityString
     * @Return:      Object - continuation
     */
    @AuraEnabled(continuation=true)
    public static Object doGatingScreeningCheckEligibilityCallout(String checkEligibilityString) {
        Continuation con;
        String loanAppId = '';
        try {
            if (String.isBlank(checkEligibilityString)) {
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.IblBre);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            //if stubs checked in Integration_Configuration then stubs will return
            if (apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c) {
                String stubData = IntegrationUtilities.getStubResponse(System.Label.IblBre);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }

            RequestWrapper requestWrapper = (RequestWrapper) IntegrationUtilities.parseJSONRequest(checkEligibilityString, 'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef = requestWrapper.loanApplicationId;
            List<Applicant__c> app = [
                SELECT Opportunity__r.Lead_Number__c, Declared_income__c, applicant_number__c, Opportunity__r.Loan_Amount__c
                FROM Applicant__c
                WHERE ID = :requestWrapper.applicantId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (!app.isEmpty()) {
                for (Applicant__c applicant : app) {
                    requestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c;
                    requestWrapper.income = String.valueOf(applicant.Declared_income__c);
                    requestWrapper.borrowerApplicantNumber = applicant.applicant_number__c;
                    requestWrapper.loanAmount = applicant.Opportunity__r.Loan_Amount__c;
                }
            } else {
                throw new IND_Exception(System.Label.Applicantdatamissing);
            }

            List<Documents__c> docs = [
                SELECT KYC_DOB__c, PAN_No__c
                FROM Documents__c
                WHERE Applicant__c = :requestWrapper.applicantId AND Document_Type__c = 'PAN' AND KYC_DOB__c != NULL
                WITH SECURITY_ENFORCED
            ];
            if (!docs.isEmpty()) {
                for (Documents__c doc : docs) {
                    if (String.isBlank(doc.PAN_No__c)) {
                        throw new IND_Exception(System.Label.PAN_Number);
                    } else {
                        requestWrapper.panNumber = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey); // Decryption added for CISP - 7614
                    }
                    requestWrapper.dOB = doc.KYC_DOB__c;
                }
            } else {
                List<Documents__c> docForm60 = [SELECT id FROM Documents__c WHERE Document_Type__c = 'Form 60' AND Applicant__c = :requestWrapper.applicantId WITH SECURITY_ENFORCED LIMIT 1];

                if (!docForm60.isEmpty()) {
                    requestWrapper.borrowerForm60Present = 'true';
                    List<Documents__c> docWithDate = [
                        SELECT kyc_dob__c
                        FROM documents__c
                        WHERE recordtype.name = 'KYC Document' AND kyc_dob__c != NULL AND Applicant__c = :requestWrapper.applicantId
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (!docWithDate.isEmpty()) {
                        requestWrapper.dOB = docWithDate[0].kyc_dob__c;
                    } else {
                        throw new IND_Exception(System.Label.DateOfBirth);
                    }
                } else {
                    throw new IND_Exception('PAN or Form 60 not found');
                }
            }
            System.debug('The Applicant ID in Integration ENgine IS  ---> ' + requestWrapper.applicantId);
            List<Customer_dedupe_response__c> custDedupe = [SELECT cin_no__c FROM customer_dedupe_response__c WHERE applicant__c = :requestWrapper.applicantId WITH SECURITY_ENFORCED LIMIT 1];
            if (!custDedupe.isEmpty()) {
                for (Customer_dedupe_response__c cust : custDedupe) {
                    //System.debug('The cust.CIN_No__c is ---> '+cust.CIN_No__c);
                    if (String.isNotBlank(cust.CIN_No__c) || cust.CIN_No__c != null) {
                        requestWrapper.cinNo = cust.CIN_No__c;
                    }
                }
            } else {
                requestWrapper.cinNo = '';
            }
            requestWrapper.noOfCoborrowers = String.valueOf(
                [SELECT COUNT() FROM Applicant__c WHERE Applicant_Type__c = 'Co-borrower' AND Applicant__c.Opportunity__c = :requestWrapper.loanApplicationId WITH SECURITY_ENFORCED]
            );
            if (Integer.valueOf(requestWrapper.noOfCoborrowers) > 0) {
                String appId;
                List<Applicant__c> coBorrowerApplicant = [
                    SELECT Id, Declared_income__c, applicant_number__c
                    FROM Applicant__c
                    WHERE Applicant_Type__c = 'Co-borrower' AND Applicant__c.Opportunity__c = :requestWrapper.loanApplicationId AND In_Active_Applicant__c = FALSE
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];

                if (!coBorrowerApplicant.isEmpty()) {
                    requestWrapper.noOfActiveCoborrowers = '1';
                    for (Applicant__c coBorrowerApp : coBorrowerApplicant) {
                        appId = coBorrowerApp.Id;
                        requestWrapper.coBorrowerIncome = String.valueOf(coBorrowerApp.Declared_income__c);
                        requestWrapper.coBorrowerApplicantNumber = coBorrowerApp.applicant_number__c;
                    }
                    List<Documents__c> coBorrowerDocs = [
                        SELECT KYC_DOB__c, PAN_No__c
                        FROM Documents__c
                        WHERE Applicant__c = :appId AND Document_Type__c = 'PAN' AND KYC_DOB__c != NULL
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];

                    if (!coBorrowerDocs.isEmpty()) {
                        for (Documents__c doc : coBorrowerDocs) {
                            if (String.isBlank(doc.PAN_No__c)) {
                                throw new IND_Exception(System.Label.PAN_Number);
                            } else {
                                requestWrapper.coBorrowerPanNumber = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey); // Decryption added for CISP - 7614
                            }

                            requestWrapper.coBorrowerDob = doc.KYC_DOB__c;
                        }
                    } else {
                        List<Documents__c> docForm60 = [SELECT id FROM Documents__c WHERE Document_Type__c = 'Form 60' AND Applicant__c = :appId WITH SECURITY_ENFORCED LIMIT 1];

                        if (!docForm60.isEmpty()) {
                            requestWrapper.coBorrowerForm60Present = 'true';
                            List<Documents__c> docWithDate = [
                                SELECT kyc_dob__c
                                FROM documents__c
                                WHERE recordtype.name = 'KYC Document' AND kyc_dob__c != NULL AND Applicant__c = :appId
                                WITH SECURITY_ENFORCED
                                LIMIT 1
                            ];
                            if (!docWithDate.isEmpty()) {
                                requestWrapper.coBorrowerDob = docWithDate[0].kyc_dob__c;
                            } else {
                                throw new IND_Exception(System.Label.DateOfBirth);
                            }
                        } else {
                            throw new IND_Exception('PAN or Form 60 not found');
                        }
                    }

                    List<Customer_dedupe_response__c> coBorrowerCustDedupe = [SELECT cin_no__c FROM customer_dedupe_response__c WHERE applicant__c = :appId WITH SECURITY_ENFORCED LIMIT 1];
                    if (!custDedupe.isEmpty()) {
                        for (Customer_dedupe_response__c cust : coBorrowerCustDedupe) {
                            if (String.isNotBlank(cust.CIN_No__c) || cust.CIN_No__c != null) {
                                requestWrapper.coBorrowerCinNo = cust.CIN_No__c;
                            }
                        }
                    } else {
                        requestWrapper.coBorrowerCinNo = '';
                    }
                }
            }

            List<Opportunity> opp = [SELECT Vehicle_Type__c, LeadSource FROM Opportunity WHERE ID = :requestWrapper.loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
            if (!opp.isEmpty()) {
                //Modified by Rohan for new DSA API
                for (Opportunity opportunity : opp) {
                    if (String.isBlank(opportunity.Vehicle_Type__c) || opportunity.Vehicle_Type__c == null) {
                        throw new IND_Exception(System.Label.VehicleType);
                    } else {
                        requestWrapper.vehicleType = opportunity.Vehicle_Type__c;
                        //requestWrapper.Channel = UserInfo.getProfileId() == System.Label.DSAProfileId ? opportunity.LeadSource : '';
                        requestWrapper.Channel = opportunity.LeadSource;
                    }
                }
            } else {
                throw new IND_Exception(System.Label.VehicleType);
            }

            IND_GatingScreeningRequestDSA gatingScreeningRequest = IND_GatingScreeningServiceDSA.getGatingScreeningCallOutRequest(requestWrapper);
            CalloutProcessor processor = new CalloutProcessor(System.Label.IblBre, gatingScreeningRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            Carrier carrier = new carrier();
            carrier.setServiceName('IBL BRE Check Eligibility DSA');
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);
            con.continuationMethod = 'processGatingScreeningCallOutResponse';
            con.state = carrier;
            con.addHttpRequest(request);

            if (Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier;
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGatingScreeningCheckEligibilityCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }

    /*
     * @Method:      processGatingScreeningCallOutResponse
     * @Created by:  Swapnil Prajapati
     * @Description: Method to return Response for Gating Screening-Check Eligibility
     * @Param:       Collection - labels
     * @Param:       Object - state
     * @Return:      Object - response
     */
    @AuraEnabled
    public static Object processGatingScreeningCallOutResponse(List<String> labels, Object state) {
        IND_GatingScreeningResponseDSA apiResponse;
        String request = '';
        String encryptedRequest = '';
        String serviceName = '';
        String loanAppId = '';
        String data = '';
        HttpResponse response;
        String elapseTime = '';
        try {
            Carrier carrier = (Carrier) state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
            loanAppId = carrier.getLoanApplicationId();
            if (response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_GatingScreeningResponseDSA) processor.getHttpResponse(response, serviceName);
                if (apiResponse != null) {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Failure
                    );
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processGatingScreeningCallOutResponseDSA', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }

    /*
     * @Method:      doLTVEngineCallout
     * @Created by:  Bondiga Thilak
     * @Description: This method is being used to call the Perfios LTV Engine API using continuation
     * @Param:       String - applicantId
     * @Return:      ''
     */
    @AuraEnabled(continuation=true)
    public static Object doLTVEngineCallout(String applicantId, String loanAppId) {
        Continuation con;
        try {
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.LTVEngine);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            RequestWrapper requestWrapper = new RequestWrapper();

            //if stubs checked in Integration_Configuration then stubs will return
            if (apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c) {
                String stubData = IntegrationUtilities.getStubResponse(System.Label.LTVEngine);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }

            loanApplicationRef = loanAppId;
            List<Applicant__c> appList = [
                SELECT Id, Who_will_repay_the_loan__c, Applicant_Type__c, Opportunity__r.LeadSource, Opportunity__r.Aggregator_Source__c, Opportunity__r.Applicant_ETC__c, Opportunity__r.Is_Pre_Approved__c //DSAMODIFYEXISTING //D2C Change
                FROM Applicant__c
                WHERE Opportunity__r.id = :loanAppId
                WITH SECURITY_ENFORCED
            ];
            List<Applicant__c> appListWithScoreCard = new List<Applicant__c>();
            String whoWillRepayTheLoan = '';

            for (Applicant__c applicant : appList) {
                if (applicant.Applicant_Type__c.equals('Borrower')) {
                    whoWillRepayTheLoan = applicant.Who_will_repay_the_loan__c;
                }
            }

            if (whoWillRepayTheLoan == null || String.isBlank(whoWillRepayTheLoan)) {
                throw new IND_Exception('Who will repay the loan field is required.');
            }

            for (Applicant__c applicant : appList) {
                List<Applicant__c> applicantWithScorecard = [
                    SELECT Scorecard_Decision__c, applicant_number__c, Applicant_Type__c, Id
                    FROM Applicant__c
                    WHERE Applicant_Type__c = :whoWillRepayTheLoan AND Opportunity__r.id = :loanAppId AND In_Active_Applicant__c = FALSE AND Id = :applicant.Id
                    WITH SECURITY_ENFORCED
                ];
                if (!applicantWithScorecard.isEmpty()) {
                    for (Applicant__c applicantScoreCard : applicantWithScorecard) {
                        appListWithScoreCard.add(applicantScoreCard);
                    }
                }
            }
            requestWrapper.Channel = appList[0]?.Opportunity__r?.LeadSource; //DSAMODIFYEXISTING
            if(appList[0]?.Opportunity__r?.Aggregator_Source__c != null){
                requestWrapper.Channel = 'Aggregator';
            }
            if(appList[0]?.Opportunity__r?.Is_Pre_Approved__c == true && appList[0]?.Opportunity__r?.LeadSource == 'D2C'){
                requestWrapper.Applicant_ETC = appList[0]?.Opportunity__r?.Applicant_ETC__c == true?'Yes':'No';
            }
            for (Applicant__c applicant : appListWithScoreCard) {
                if (!String.isBlank(applicant.Scorecard_Decision__c)) {
                    requestWrapper.scoreCardDecision = applicant.Scorecard_Decision__c;
                }
                if (!String.isBlank(applicant.applicant_number__c)) {
                    requestWrapper.applicantNumber = applicant.applicant_number__c;
                }
                if (!String.isBlank(applicant.Applicant_Type__c)) {
                    requestWrapper.proposalBasedOn = applicant.Applicant_Type__c;
                }
                if (!String.isBlank(applicant.id)) {
                    requestWrapper.applicantId = applicant.id;
                }
            }
            Opportunity opp = [
                SELECT Id, Customer_Deal_No__c, Lead_number__c, Product_Type__c, Category__c, Vehicle_Type__c, Agent_BL_code__c, Geo_State_Master__r.State_Code__c, LeadSource, Is_Pre_Approved__c
                FROM Opportunity
                WHERE ID = :loanAppId
                WITH SECURITY_ENFORCED
            ];
            List<Vehicle_Detail__c> vehicleDetails = [SELECT Model__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :loanAppId WITH SECURITY_ENFORCED LIMIT 1];
            if (!vehicleDetails.isEmpty()) {
                for (Vehicle_Detail__c vehicle : vehicleDetails) {
                    List<Product2> product2 = [SELECT asset_category__c FROM product2 WHERE name = :vehicle.Model__c WITH SECURITY_ENFORCED LIMIT 1];
                    if (!product2.isEmpty()) {
                        requestWrapper.subProduct = product2[0].asset_category__c;
                    } else {
                        throw new IND_Exception('Asset category not found in product');
                    }
                }
            }

            IND_LTVEngineRequestDSA LTVEngineRequestDetails = IND_LTVEngineServiceDSA.getLTVEngineRequest(opp, loanAppId, requestWrapper);
            CalloutProcessor process = new CalloutProcessor(System.Label.LTVEngine, LTVEngineRequestDetails);
            HttpRequest request = process.createHttpRequest();

            Long startTime = DateTime.now().getTime();

            Carrier carrier = new carrier();
            carrier.setServiceName('LTV Engine DSA');
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);
            con.continuationMethod = 'processLTVEngineAPIResponse';
            con.state = carrier;
            con.addHttpRequest(request);

            if (Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier;
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doLTVEngineCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }

    /*
     * @Method:      processLTVEngineAPIResponseDSA
     * @Created by:  Swapnil Prajapati
     * @Description: This method is being used to handle the response from continuation and return the response to calling processes
     * @Param:       Collection - labels
     * @Param:       Object - state
     * @Return:      Object - response
     */
    @AuraEnabled
    public static Object processLTVEngineAPIResponse(List<String> labels, Object state) {
        IND_LTVEngineResponseDSA apiResponse;
        String request = '';
        String responseBody = '';
        String encryptedRequest = '';
        String serviceName = '';
        String loanAppId = '';
        HttpResponse response;
        String elapseTime = '';

        try {
            Carrier carrier = (Carrier) state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();

            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
            loanAppId = carrier.getLoanApplicationId();
            if (response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_LTVEngineResponseDSA) processor.getHttpResponse(response, serviceName);
                if (apiResponse != null) {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Failure
                    );
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processLTVEngineAPIResponseDSA', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }

    /*
     * @Method:      doPricingEngineCallout
     * @Created by:  Bondiga Thilak
     * @Description: This method is being used to call the Perfios Pricing Engine API using continuation
     * @Param:       String - applicantId
     * @Return:      ''
     */
    @AuraEnabled(continuation=true)
    public static Object doPricingEngineCallout(String applicantId, String loanAppId) {
        Continuation con;
        try {
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.PricingEngine);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            RequestWrapper requestWrapper = new RequestWrapper();
            //if stubs checked in Integration_Configuration then stubs will return
            if (apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c) {
                String stubData = IntegrationUtilities.getStubResponse(System.Label.PricingEngine);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }
            loanApplicationRef = loanAppId;
            List<Applicant__c> appList = [
                SELECT Id, Who_will_repay_the_loan__c, Applicant_Type__c, Opportunity__r.LeadSource
                FROM Applicant__c
                WHERE Opportunity__r.id = :loanAppId
                WITH SECURITY_ENFORCED
            ];
            List<Applicant__c> appListWithScoreCard = new List<Applicant__c>();
            String whoWillRepayTheLoan = '';

            for (Applicant__c applicant : appList) {
                if (applicant.Applicant_Type__c.equals('Borrower')) {
                    whoWillRepayTheLoan = applicant.Who_will_repay_the_loan__c;
                }
            }

            if (whoWillRepayTheLoan == null || String.isBlank(whoWillRepayTheLoan)) {
                throw new IND_Exception('Who will repay the loan field is required.');
            }

            for (Applicant__c applicant : appList) {
                List<Applicant__c> applicantWithScorecard = [
                    SELECT Scorecard_Decision__c, applicant_number__c, Applicant_Type__c, Id
                    FROM Applicant__c
                    WHERE Applicant_Type__c = :whoWillRepayTheLoan AND Opportunity__r.id = :loanAppId AND In_Active_Applicant__c = FALSE AND Id = :applicant.Id
                    WITH SECURITY_ENFORCED
                ];
                if (!applicantWithScorecard.isEmpty()) {
                    for (Applicant__c applicantScoreCard : applicantWithScorecard) {
                        appListWithScoreCard.add(applicantScoreCard);
                    }
                }
            }
            String scoreCardDecision;
            for (Applicant__c applicant : appListWithScoreCard) {
                if (!String.isBlank(applicant.Scorecard_Decision__c)) {
                    requestWrapper.scoreCardDecision = applicant.Scorecard_Decision__c;
                }
                if (!String.isBlank(applicant.applicant_number__c)) {
                    requestWrapper.applicantNumber = applicant.applicant_number__c;
                }
                if (!String.isBlank(applicant.Applicant_Type__c)) {
                    requestWrapper.proposalBasedOn = applicant.Applicant_Type__c;
                }
                if (!String.isBlank(applicant.id)) {
                    requestWrapper.applicantId = applicant.id;
                }
            }
            Opportunity opp = [
                SELECT Id, Customer_Deal_No__c, Lead_number__c, Product_Type__c, Category__c, Vehicle_Type__c, Agent_BL_code__c, Geo_State_Master__r.State_Code__c, LeadSource, Aggregator_Source__c
                FROM Opportunity
                WHERE ID = :loanAppId
                WITH SECURITY_ENFORCED
            ];
            requestWrapper.Channel = opp.LeadSource == 'D2C' ? 'IndusMobile' : opp.LeadSource;
            if(opp?.Aggregator_Source__c != null){
                requestWrapper.Channel = 'Aggregator';
            }

            IND_PricingEngineRequestDSA pricingEngineRequestDetails = IND_PricingEngineServiceDSA.getPricingEngineRequest(opp, loanAppId, requestWrapper);
            CalloutProcessor process = new CalloutProcessor(System.Label.PricingEngine, pricingEngineRequestDetails);
            HttpRequest request = process.createHttpRequest();

            Long startTime = DateTime.now().getTime();

            Carrier carrier = new carrier();
            carrier.setServiceName('Pricing Engine DSA');
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);
            con.continuationMethod = 'processPricingEngineAPIResponse';
            con.state = carrier;
            con.addHttpRequest(request);

            if (Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier;
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPricingEngineCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }

    /*
     * @Method:      processPricingEngineAPIResponseDSA
     * @Created by:  Swapnil Prajapati
     * @Description: This method is being used to handle the response from continuation and return the response to calling processes for DSA
     * @Param:       Collection - labels
     * @Param:       Object - state
     * @Return:      Object - response
     */
    @AuraEnabled
    public static Object processPricingEngineAPIResponse(List<String> labels, Object state) {
        IND_PricingEngineResponseDSA apiResponse;
        String responseBody = '';
        String request = '';
        String encryptedRequest = '';
        String serviceName = '';
        String loanAppId = '';
        String data;
        HttpResponse response;
        String elapseTime = '';

        try {
            Carrier carrier = (Carrier) state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();

            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
            loanAppId = carrier.getLoanApplicationId();
            if (response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_PricingEngineResponseDSA) processor.getHttpResponse(response, serviceName);
                if (apiResponse != null) {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Failure
                    );
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processPricingEngineAPIResponseDSA', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }

    /*
     * @Method:      doBREscoreCardCallout
     * @Created by:  Bondiga Thilak
     * @Description: This method is being used to call the BREscoreCard API using continuation
     * @Param:       String - applicantId
     * @Return:      ''
     */
    @AuraEnabled(continuation=true)
    public static Object doBREscoreCardCallout(String applicantId, String loanAppId) {
        Continuation con;
        try {
            if (String.isBlank(applicantId)) {
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.BREscorecardAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            loanApplicationRef = loanAppId;

            //if stubs checked in Integration_Configuration then stubs will return
            if (apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c) {
                String stubData = IntegrationUtilities.getStubResponse(System.Label.BREscorecardAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }
            //Modified by Rohan for new DSA API
            Applicant__c app = [
                SELECT
                    Id,
                    Opportunity__r.Customer_Deal_No__c,
                    Opportunity__r.LeadSource,
                    Opportunity__r.Lead_number__c,
                    Opportunity__r.Product_Type__c,
                    Opportunity__r.Vehicle_Type__c,
                    Opportunity__r.Contact_number__c,
                    Applicant_Type__c,
                    Gender__c,
                    Income_Ca__c,
                    Marital_status__c,
                    Opportunity__r.Geo_State_Master__r.State_Code__c,
                    Residence_country__c,
                    Profile__c,
                    Contact_number__c,
                    applicant_number__c,
                    Opportunity__r.Agent_BL_code__c
                FROM Applicant__c
                WHERE Id = :applicantId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            Documents__c doc;
            List<Documents__c> docWithDate = [
                SELECT kyc_dob__c
                FROM documents__c
                WHERE recordtype.name = 'KYC Document' AND Applicant__c = :applicantId AND Proof_of_Identity_POI__c = TRUE
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            doc = new Documents__c();
            if (!docWithDate.isEmpty()) {
                doc.KYC_DOB__c = docWithDate[0].kyc_dob__c;
            } else {
                throw new IND_Exception(System.Label.DateOfBirth);
            }
            List<Documents__c> docWithPin=[Select KYC_Pin_Code__c from documents__c where recordtype.name = 'KYC Document' and Applicant__c=:applicantId and Proof_of_Identity_POI__c=true AND Is_Active__c =true WITH SECURITY_ENFORCED limit 1];//CISP-23348
            if(!docWithPin.isEmpty()){
                   doc.KYC_Pin_Code__c = docWithPin[0].KYC_Pin_Code__c;
                }
                else{
                    throw new IND_Exception('Pincode is Missing');
                }  

            IND_BREscoreCardRequestDSA BREscoreCardRequestDetails = IND_BREscoreCardServiceDSA.getBREscoreCardRequest(app, doc, loanAppId);
            CalloutProcessor process = new CalloutProcessor(System.Label.BREscorecardAPI, BREscoreCardRequestDetails);
            HttpRequest request = process.createHttpRequest();

            Long startTime = DateTime.now().getTime();

            Carrier carrier = new carrier();
            carrier.setServiceName('BREscorecardAPIDSA');
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);
            con.continuationMethod = 'processBREscoreCardAPIResponse';
            con.state = carrier;
            con.addHttpRequest(request);

            if (Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier;
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBREscoreCardCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }

    /*
     * @Method:      processBREscoreCardAPIResponseDSA
     * @Created by:  Rohan Saxena
     * @Description: This method is being used to handle the response from continuation and return the response to calling processes
     * @Param:       Collection - labels
     * @Param:       Object - state
     * @Return:      Object - response
     */
    @AuraEnabled
    public static Object processBREscoreCardAPIResponse(List<String> labels, Object state) {
        IND_BREscoreCardResponseDSA apiResponse;
        String request = '';
        String encryptedRequest = '';
        String serviceName = '';
        String data;
        String loanAppId = '';
        HttpResponse response;
        String elapseTime = '';

        try {
            Carrier carrier = (Carrier) state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
            loanAppId = carrier.getLoanApplicationId();

            if (response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_BREscoreCardResponseDSA) processor.getHttpResponse(response, serviceName);

                if (apiResponse != null) {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName,
                        elapseTime,
                        loanAppId,
                        System.Label.Failure
                    );
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processBREscoreCardAPIResponseDSA', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }

    /*
     * @Method:      doDSAOfferEngineCallout
     * @Created by:  Rohan Saxena
     * @Description: Continuation for DSA Offer Engine API
     * @Param:       String -
     * @Return:      Object - continuation
     */

    @AuraEnabled(continuation=true)
    public static Object doDSAOfferEngineCallout(String loanId, String applicantId) {
        Continuation con;
        Integer Income;
        Integer CoborrowerIncome;
        Integer BorrowerIncome;
        String Coborrower;
        Boolean isD2C = false;
        try {
            List<Applicant__c> lstApplicant = [
                SELECT
                    Id,
                    Applicant_Type__c,
                    In_Active_Applicant__c,
                    applicant_number__c,
                    Scorecard_Decision__c,
                    Declared_income__c,
                    Opportunity__r.Basic_Price__c,
                    Opportunity__r.Lead_Number__c,
                    Opportunity__r.Product_Type__c,
                    Opportunity__r.Vehicle_Type__c,
                    Opportunity__r.LeadSource,
                    Opportunity__r.On_Road_price__c,
                    Opportunity__r.On_Road_price_carwale__c,
                    Opportunity__r.Is_Pre_Approved__c,
                    Opportunity__r.Aggregator_Source__c
                FROM Applicant__c
                WHERE Opportunity__r.id = :loanId AND In_Active_Applicant__c = FALSE
                WITH SECURITY_ENFORCED
            ];
            RequestWrapper requestWrapper = new RequestWrapper();
            
            if(lstApplicant.size() > 0 && String.isNotBlank(lstApplicant[0].Opportunity__r.leadSource)) {
                isD2C = lstApplicant[0].Opportunity__r.leadSource == 'D2C' ? true : false;
            }
            Vehicle_Detail__c vehicleDetails = null;
            List<Product2> products = new List<Product2>();
            List<Benefi__c> dealers = new List<Benefi__c> ();
            if(isD2C) {
                vehicleDetails = [SELECT Valuation_price__c, Make_Code__c, Model_Code__c, Variant_Code__c, Loan_Application__r.Product_Type__c, Ben_Code__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanId LIMIT 1];
                products = [SELECT Id ,
                    Manufacturer_code__c FROM Product2 WHERE Variant_Code__c != null AND Product_Type__c = 'TWO WHEELER' 
                    AND make__c =: vehicleDetails.Make_Code__c AND model__c =: vehicleDetails.Model_Code__c AND Variant_Code__c =: vehicleDetails.Variant_Code__c ];
                dealers = [Select id, Grade__c from Benefi__c where Ben_code__c =: vehicleDetails.Ben_Code__c];
            }
                
            for (Applicant__c applicant : lstApplicant) {
                if (lstApplicant.size() > 1) {
                    if (applicant.Applicant_Type__c == 'Borrower') {
                        requestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c;
                        requestWrapper.borrowerApplicantNumber = applicant.applicant_number__c;
                        requestWrapper.product = applicant.Opportunity__r.Product_Type__c;
                        requestWrapper.vehicleType = applicant.Opportunity__r.Vehicle_Type__c;
                        
                        if (applicant.Declared_income__c != null) {
                            BorrowerIncome = (Integer) (applicant.Declared_income__c / 12);
                        }
                    } else if (applicant.Applicant_Type__c == 'Co-borrower') {
                        Coborrower = applicant.Id;
                        requestWrapper.scoreCardDecision = applicant.Scorecard_Decision__c;
                        CoborrowerIncome = (Integer) (applicant.Declared_income__c / 12);
                    }
                } else {
                    requestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c;
                    requestWrapper.borrowerApplicantNumber = applicant.applicant_number__c;
                    requestWrapper.product = applicant.Opportunity__r.Product_Type__c;
                    requestWrapper.vehicleType = applicant.Opportunity__r.Vehicle_Type__c;
                    requestWrapper.scoreCardDecision = applicant.Scorecard_Decision__c;
                    BorrowerIncome = (Integer) (applicant.Declared_income__c / 12);
                    requestWrapper.isPACustomer = applicant.Opportunity__r.Is_Pre_Approved__c;
                    
                    
                }
                applicantId = applicantId == null ? applicant.Id : applicantId;
                if(applicant.Opportunity__r.Basic_Price__c != null){
                    requestWrapper.ORPQuotationPrice = String.valueOf(applicant.Opportunity__r.Basic_Price__c.round(System.RoundingMode.DOWN));
                }
                if(String.isNotBlank(applicant.Opportunity__r.LeadSource) && applicant.Opportunity__r.LeadSource == 'D2C'){
                    System.debug('orp d2c'+String.valueOf(applicant.Opportunity__r.On_Road_price__c.round(System.RoundingMode.DOWN)));
                    requestWrapper.ORPQuotationPrice = String.valueOf(applicant.Opportunity__r.On_Road_price__c.round(System.RoundingMode.DOWN));
                    isD2C = true;
                    //Vehicle_Detail__c vehicleDetails = [SELECT Valuation_price__c, Make_Code__c, Model_Code__c, Variant_Code__c, Loan_Application__r.Product_Type__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanId LIMIT 1];
                    if(applicant.Opportunity__r.Vehicle_Type__c.toLowerCase() != 'new'){
                        requestWrapper.ORPQuotationPrice = String.valueOf(vehicleDetails.Valuation_price__c.round(System.RoundingMode.DOWN));
                    }
                    if(vehicleDetails.Ben_Code__c != null) {
                        
                        if(dealers.size() > 0) {
                            requestWrapper.DealerCategory = String.isNotBlank(dealers[0].Grade__c) ? dealers[0].Grade__c : 'Others';
                        }
                    }
                    if(String.isNotBlank(vehicleDetails.Make_Code__c) && String.isNotBlank(vehicleDetails.Model_Code__c) 
                    && String.isNotBlank(vehicleDetails.Variant_Code__c) && vehicleDetails.Loan_Application__r.Product_Type__c ==  'Two Wheeler') {
                        
                        
                        if(products.size() > 0) {   
                            requestWrapper.Manufacture_Code = products[0].Manufacturer_code__c;
                        }   
                        

                    }
                }
                
                if(!String.isBlank(applicant.Opportunity__r.LeadSource)){
                    if(applicant.Opportunity__r.LeadSource == 'D2C') {
                        requestWrapper.Channel = String.isNotBlank(applicant.Opportunity__r.Aggregator_Source__c) ? 'Aggregator' : 'IndusMobile';
                    } else {
                        requestWrapper.Channel = applicant.Opportunity__r.LeadSource;
                    }
                }
            }
            if (BorrowerIncome != null && CoborrowerIncome != null) {
                Income = BorrowerIncome + CoborrowerIncome;
            } else if (BorrowerIncome != null && CoborrowerIncome == null) {
                Income = BorrowerIncome;
            } else if (BorrowerIncome == null && CoborrowerIncome != null) {
                Income = CoborrowerIncome;
            }

            requestWrapper.income = String.valueOf(Income);
            List<Final_Term__c> objFinalTerms = [SELECT id, LtvEngine_Ltv__c, PricingEngine_thresholdNetrr__c, CRM_IRR__c, Loan_Application__r.Loan_amount__c, Tenure__c, Inputted_IRR__c, Net_IRR__c FROM Final_Term__c WHERE Loan_Application__c = :loanId LIMIT 1];
            if (objFinalTerms.size() != 0) {
                requestWrapper.EngineBankIrr = String.valueOf(objFinalTerms[0].PricingEngine_thresholdNetrr__c);
                requestWrapper.EngineLTV = String.valueOf(objFinalTerms[0].LtvEngine_Ltv__c);
            } else {
                requestWrapper.EngineBankIrr = '';
                requestWrapper.EngineLTV = '';
            }

            //As per clarification by Maitreye on 9/9/22 requestWrapper.emi = max(sum(Lower_EMI_Limit__c), EMI__c)
            Double existingEMI = 0;
            Double sumExistingEMILowerLimit = 0;
            for (Existing_EMI__c objEMI : [SELECT EMI__c, Lower_EMI_Limit__c FROM Existing_EMI__c WHERE Applicant_Id__c = :applicantId ORDER BY CreatedDate DESC]) {
                if (objEMI.EMI__c != null && existingEMI == 0) {
                    existingEMI = objEMI.EMI__c;
                } else if (objEMI.Lower_EMI_Limit__c != null) {
                    sumExistingEMILowerLimit += objEMI.Lower_EMI_Limit__c;
                }
            }
            if (Math.max(existingEMI, sumExistingEMILowerLimit) != 0) {
                requestWrapper.emi = String.valueOf(Math.max(existingEMI, sumExistingEMILowerLimit));
            } else {
                requestWrapper.emi = '';
            }

            Vehicle_Detail__c objVehicleDetails = [SELECT id, Base_Price__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :loanId LIMIT 1];
            if(objVehicleDetails?.Base_Price__c != null && !isD2C){
                requestWrapper.ORPQuotationPrice = String.valueOf(objVehicleDetails.Base_Price__c.round(System.RoundingMode.DOWN));
            }

            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('Offer Engine DSA');
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            IND_OfferEngineRequestDSA offerEngineRequestDSA = IND_OfferEngineServiceDSA.getDSAOfferEngineCallOutRequest(requestWrapper, loanId);
            CalloutProcessor processor = new CalloutProcessor('Offer Engine DSA', offerEngineRequestDSA);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            Carrier carrier = new carrier();
            carrier.setServiceName('Offer Engine DSA');
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanId);
            //Add callout request to continuation
            con = new Continuation(timeout);
            con.continuationMethod = 'processOfferEngineCalloutResponseDSA';
            con.state = carrier;
            con.addHttpRequest(request);
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDSAOfferEngineCallout', System.Label.Apex, ex, loanId);
            throw ex;
        }
        return con;
    }

    /*
     * @Method:      processOfferEngineCalloutResponseDSA
     * @Created by:  Rohan Saxena
     * @Description: Callback method to return Response for DSA Offer Engine API
     * @Param:       Collection - labels
     * @Param:       Object - state
     * @Return:      Object - response
     */
    @AuraEnabled
    public static Object processOfferEngineCalloutResponseDSA(List<String> labels, Object state) {
        IND_OfferEngineResponseDSA apiResponse;
        String request = '';
        String encryptedRequest = '';
        String serviceName = '';
        String loanAppId = '';
        HttpResponse response;
        String elapseTime = '';
        String responseBody = '';
        try {
            Carrier carrier = (Carrier) state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
            loanAppId = carrier.getLoanApplicationId();
            if (response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_OfferEngineResponseDSA) processor.getHttpResponse(response, serviceName);
                if (apiResponse != null) {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName + 'DSA',
                        elapseTime,
                        loanAppId,
                        System.Label.Success
                    );
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(
                        request,
                        encryptedRequest,
                        IntegrationUtilities.getPlainTextForLog(response.getBody()),
                        response.getBody(),
                        serviceName + 'DSA',
                        elapseTime,
                        loanAppId,
                        System.Label.Failure
                    );
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processOfferEngineCalloutResponseDSA', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }

    /* All API Method Should be added above this class
     * @Class:      Carrier
     * @Created by:  Bhushan Charde
     * @Description: This is a helper class used to transport object/fields to callback method from continuation block
     */
    public class Carrier {
        public transient string request;
        public transient string encryptedRequest;
        public transient String serviceName;
        public transient CalloutProcessor processor;
        public transient Long startTime;
        public transient String loanApplicationId;
        public transient List<Object> tempObject;

        Carrier() {
        }

        Carrier(String serviceName, CalloutProcessor processor, String encryptRequest, Long startTime, String loanAppId, String plainRequest) {
            this.serviceName = serviceName;
            this.processor = processor;
            this.encryptedRequest = encryptRequest;
            this.startTime = startTime;
            this.loanApplicationId = loanAppId;
            this.request = plainRequest;
        }

        void setTempObject(List<Object> tempObject) {
            this.tempObject = tempObject;
        }
        public List<Object> getTempObject() {
            return tempObject;
        }

        void setRequest(String request) {
            this.request = request;
        }
        public String getRequest() {
            return request;
        }
        void setEncryptedRequest(String encryptedRequest) {
            this.encryptedRequest = encryptedRequest;
        }
        public String getEncryptedRequest() {
            return encryptedRequest;
        }
        void setProcessor(CalloutProcessor processor) {
            this.processor = processor;
        }
        public CalloutProcessor getProcessor() {
            return processor;
        }
        void setServiceName(String serviceName) {
            this.serviceName = serviceName;
        }
        public String getServiceName() {
            return serviceName;
        }
        void setStartTime(Long startTime) {
            this.startTime = startTime;
        }
        public Long getStartTime() {
            return startTime;
        }
        void setLoanApplicationId(String loanApplicationId) {
            this.loanApplicationId = loanApplicationId;
        }
        public String getLoanApplicationId() {
            return loanApplicationId;
        }
    }

    @AuraEnabled
    public static Boolean expression(String valuepassedin) {
        return true;
    }
}