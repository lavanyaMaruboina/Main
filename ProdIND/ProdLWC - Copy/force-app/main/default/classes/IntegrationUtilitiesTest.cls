@isTest
public class IntegrationUtilitiesTest {
    @testSetup 
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];

        User user = new User();
        // user.Maker_Id__c='99877';
        // user.IsPortalEnabled=true;
        user.Alias = 'standt';
        user.Email='standarduser@testorg.com';
        user.MobilePhone = '9999999999';
        user.EmailEncodingKey='UTF-8';
        user.LastName='Testing';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US'; 
        user.ProfileId = p.Id; 
        user.Maker_Id__c='12';
        user.TimeZoneSidKey='America/Los_Angeles';
        user.UserName='standarduser4@testorg.com.psdev1';
        insert user;

        System.runAs(user){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Deal_Number__c = 'TUT06226H';
            opp.Parent_Deal_number__c = 'DL109939';
            opp.Lead_Number__c='L-10122021-1685';
            opp.Product_Type__c = 'Passenger Vehicles';
            opp.Required_Loan_amount__c = 50000;
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
            doc.KYC_No__c = 'test kyc no';
            doc.KYC_Issuance_Date__c = Date.newInstance(2022, 05, 20);
            doc.Proof_of_Address_POA__c = true;
            doc.Proof_of_Identity_POI__c = true;
            doc.Opportunity_Relation__c = opp.Id;
            doc.Applicant__c =applicant.id;
            doc.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.label.KYCDocument).getRecordTypeId();
            insert doc;

            Integration_Log__c integLog = new Integration_Log__c();
            integLog.ReferenceId__c='dhshsh';
            integLog.Original_response__c='hshggaga';
            integLog.Service_Name__c='APD Pending';
            integLog.Encrypted_response__c='hshgagagaaa';
            insert integLog;
        }

        // ContentVersion cv = new ContentVersion();
        // // cv.ContentDocumentId=
        // insert cv;

        // Documents__c doc = new Documents__c();
        // doc.ContentVersionId__c='ssss';
        // insert doc;
    }

    @isTest
    public static void gattingCheckEligibilityAPITest(){
        Test.StartTest();
        System.assertEquals(IntegrationUtilities.gattingCheckEligibilityAPI(),'{"status":"false","message":"Journey Stop"}');
        Test.StopTest();
    }

    @isTest
    public static void getAPIConfigurationTest(){
        Test.startTest();
             IntegrationUtilities.getAPIConfiguration('ADAuthentication');
        Test.stopTest();
    }

    @isTest
    public static void parseJSONResponseTest(){
        String InsertResponseString = '{'+
        '  \"aadhaar_name\": \"Test ABC XYZ\",'+
        '  \"aadhaar_no\": \"344195214770\",'+
        '  \"aadhaar_otp_status\": \"Y\",'+
        '  \"aadhaar_serv_flag\": \"B\",'+
        '  \"aadhaar_status\": \"Verified\",'+
        '  \"active_money\": \"Y\",'+
        '  \"active_sweep_in\": \"1000\",'+
        '  \"active_sweep_out\": \"1000\",'+
        '  \"annual_income\": \"01\",'+
        '  \"appointment_location\": \"M\",'+
        '  \"appointment_date\": \"2021-02-12\",'+
        '  \"appointment_slot\": \"TestSlot\",'+
        '  \"campaign_id\": \"Test\",'+
        '  \"core_account_number\": \"1234567890\",'+
        '  \"create_user\": \"MBWAL\",'+
        '  \"crn\": \"103264128\",'+
        '  \"date_of_birth\": \"2021-02-12\",'+
        '  \"email\": \"abc@gmail.com\",'+
        '  \"fatca_reportable_flag\": \"N\",'+
        '  \"fathers_name\": \"Test Father\",'+
        '  \"firstName\": \"Test\",'+
        '  \"gender\": \"M\",'+
        '  \"home_branch_code\": \"12345\",'+
        '  \"is_aadhaar_pan_same\": \"Y\",'+
        '  \"kit_type\": \"PGN\",'+
        '  \"leadSource\": \"Google\",'+
        '  \"lastName\": \"Test\",'+
        '  \"company\": \"Kotak Bank\",'+
        '  \"fkyc_lc_code\": \"12345\",'+
        '  \"lc_code_name\": \"Kotak Employee\",'+
        '  \"lc_code\": \"MBOTP\",'+
        '  \"lead_id\": \"12345\",'+
        '  \"lg_code\": \"MBOTP\",'+
        '  \"marital_status\": \"M\",'+
        '  \"meeting_serv_flag\": \"Y\",'+
        '  \"meet_addr1\": \"TestAddr1\",'+
        '  \"meet_addr2\": \"TestAddr2\",'+
        '  \"meet_addr3\": \"TestAddr3\",'+
        '  \"meet_city\": \"City\",'+
        '  \"meet_pincode\": \"123456\",'+
        '  \"meet_state\": \"Test State\",'+
        '  \"middleName\": \"Middlename\",'+
        '  \"mobilePhone\": \"1234567890\",'+
        '  \"phone\": \"1234567891\",'+
        '  \"mode_of_operations\": \"9\",'+
        '  \"mothers_maidan_name\": \"TestMaiden\",'+
        '  \"new_wallet_flag\": \"Y\",'+
        '  \"nominee_flag\": \"Y\",'+
        '  \"nominee_address_1\": \"Test Address 1\",'+
        '  \"nominee_address_2\": \"Test Address 2\",'+
        '  \"nominee_address_3\": \"Test Address 3\",'+
        '  \"nominee_city\": \"Test\",'+
        '  \"nominee_country\": \"Test\",'+
        '  \"nominee_dob\": \"2021-02-12\",'+
        '  \"nominee_fName\": \"Test\",'+
        '  \"nominee_grdn_address_1\": \"Test Address\",'+
        '  \"nominee_grdn_address_2\": \"Test Address\",'+
        '  \"nominee_grdn_address_3\": \"Test Address\",'+
        '  \"nominee_grdn_add_flag\": \"Test\",'+
        '  \"nominee_grdn_city\": \"Test\",'+
        '  \"nominee_grdn_country\": \"Test\",'+
        '  \"nominee_grdn_dob\": \"2021-02-12\",'+
        '  \"nominee_grdn_email_add\": \"test@gmail.com\",'+
        '  \"nominee_grdn_fname\": \"Test\",'+
        '  \"nominee_grdn_lname\": \"Test\",'+
        '  \"nominee_grdn_name\": \"Test\",'+
        '  \"nominee_grdn_phone_no\": \"1234567890\",'+
        '  \"nominee_grdn_pin\": \"Test\",'+
        '  \"nominee_grdn_relstn_with_key\": \"SON\",'+
        '  \"nominee_grdn_relstn_with_minor\": \"FAT\",'+
        '  \"nominee_grdn_state\": \"Test State\",'+
        '  \"nominee_grdn_title\": \"MR.\",'+
        '  \"nominee_lname\": \"Test\",'+
        '  \"nominee_mname\": \"Test\",'+
        '  \"nominee_name\": \"Test\",'+
        '  \"nominee_nominee_add_flag\": \"Test\",'+
        '  \"nominee_phone_no\": \"1234567890\",'+
        '  \"nominee_pin\": \"123456\",'+
        '  \"nominee_relstn_with_app\": \"FAT\",'+
        '  \"nominee_state\": \"Test State\",'+
        '  \"nominee_title\": \"MR.\",'+
        '  \"occupation_type\": \"P\",'+
        '  \"office_addr_line1\": \"Test\",'+
        '  \"office_addr_line2\": \"Test\",'+
        '  \"office_addr_line3\": \"Test\",'+
        '  \"office_city\": \"Test\",'+
        '  \"office_country\": \"Test\",'+
        '  \"office_state\": \"Test\",'+
        '  \"office_zipcode\": \"123456\",'+
        '  \"online_conf_code\": \"\",'+
        '  \"online_ref_1\": \"\",'+
        '  \"online_ref_2\": \"\",'+
        '  \"online_ref_3\": \"\",'+
        '  \"original_lead_source\": \"SWNW\",'+
        '  \"pan_image\": \"\",'+
        '  \"pan_no\": \"AKUPV9601L\",'+
        '  \"pan_valid_flag\": \"Y\",'+
        '  \"pep_flag\": \"Y\",'+
        '  \"permanent_addr_line1\": \"Test\",'+
        '  \"permanent_addr_line2\": \"Test\",'+
        '  \"permanent_addr_line3\": \"Test\",'+
        '  \"permanent_city\": \"Test\",'+
        '  \"permanent_country\": \"Test\",'+
        '  \"permanent_state\": \"Test\",'+
        '  \"permanent_zipcode\": \"Test\",'+
        '  \"phone_number_status\": \"Y\",'+
        '  \"photo_stream\": \"Test\",'+
        '  \"preffered_address\": \"RESIDENCE\",'+
        '  \"promotional_code\": \"Test\",'+
        '  \"promo_code\": \"Test\",'+
        '  \"residence_addr_line1\": \"Test\",'+
        '  \"residence_addr_line2\": \"Test\",'+
        '  \"residence_addr_line3\": \"Test\",'+
        '  \"residence_city\": \"Test\",'+
        '  \"residence_country\": \"Test\",'+
        '  \"residence_state\": \"Test\",'+
        '  \"residence_zipcode\": \"123456\",'+
        '  \"rm_code\": \"Test\",'+
        '  \"sb_account_number\": \"123456789\",'+
        '  \"scheme_code\": \"SJIFL\",'+
        '  \"self_declaration\": \"Test\",'+
        '  \"sign_url\": \"Test\",'+
        '  \"salutation\": \"MR.\",'+
        '  \"verification_mode\": \"DEMOAUTH\",'+
        '  \"preferred_product_desc\": \"Test product\",'+
        '  \"lead_score\": \"Test\",'+
        '  \"risk_score\": \"12345\",'+
        '  \"tmx_data\": \"Test\",'+
        '  \"pan_display_name\": \"Test\",'+
        '  \"pan_nsdl_api_name\": \"Test\",'+
        '  \"scc_applied\": \"Y\",'+
        '  \"fd_amount\": \"1000\",'+
        '  \"account_opening_date\": \"2021-02-12\",'+
        '  \"mf_applied\": \"Y\",'+
        '  \"kra_verified\": \"Y\",'+
        '  \"stp_cc_applied\": \"Y\",'+
        '  \"ip_funded\": \"Y\",'+
        '  \"channel_of_appointment\": \"OCC\",'+
        '  \"esc_flag_for_appointment\": \"Y\",'+
        '  \"gpa_flag\": \"Y\",'+
        '  \"so_flag\": \"Y\",'+
        '  \"hc_flag\": \"Y\",'+
        '  \"nsdl_pan_status\": \"Y\",'+
        '  \"aadhar_pan_link_status\": \"Y\",'+
        '  \"signature_image\": \"\",'+
        '  \"workflow\":\"OTP\",'+
        '  \"verna_decl\": \"Y\",'+
        '  \"verna_lang\": \"Y\",'+
        '  \"image_id\": \"12345\",'+
        '  \"image_name\":\"Iname\",'+
        '  \"image_stream\":\"\",'+
        '  \"no_nominee_decl_ver\": \"Y\",'+
        '\"maiden_name\":\"Test M name\"'+
        '}';
        Test.startTest();
            // IntegrationUtilities.parseJSONResponse(InsertResponseString,'Class1');
        Test.stopTest();
    }
        // Test.startTest();
        //     IntegrationUtilities.parseJSONResponse('nothing','anything');
        // Test.stopTest();


    @isTest
    public static void getStubResponseTest(){
        Test.startTest();
             IntegrationUtilities.getStubResponse('APD Pending');
        Test.stopTest();
    }

    @isTest
    public static void publishHighPayloadTest(){
        Test.startTest();
            // IntegrationUtilities.publishHighPayload('fadads','hhhafaf','asse','ssded','44433322221','');
        Test.stopTest();
    }

    // @isTest
    // public static void publishHighPayloadTest(){
    //     Test.startTest();
    //          IntegrationUtilities.publishHighPayload('fadads','hhhafaf','asse','ssded','44433322221','');
    //     Test.stopTest();
    // }

    @isTest
    public static void publishLowPayloadTest(){
        Test.startTest();
             //IntegrationUtilities.publishLowPayload('fadads','hhhafaf','asse','44433322221','');
        Test.stopTest();
    }

    // @isTest
    // public static String getPlainTextForLogTest(){
    //     Test.startTest();
    //     System.assertEquals(IntegrationUtilities.getPlainTextForLog('fadads'));
    //     Test.stopTest();
    // }

    @isTest
    public static void createIntegrationLoggerTest(){
        Test.startTest();
             IntegrationUtilities.createIntegrationLogger('wwss','eeee','aaaa','bbbb','APD Pending','aass','00671000001a0c8AAA','SUCCESS');
        Test.stopTest();
    }

    @isTest
    public static void createContentDocforIntegrationLogTest(){
        try{
        Test.startTest();
             IntegrationUtilities.createContentDocforIntegrationLog('wwss','eeee','aaaa','bbbb','APD Pending','aass','00671000001a0c8AAA','SUCCESS');
        Test.stopTest();
        }catch(Exception e){
            system.debug('createContentDocforIntegrationLogTest' + e);
        }
    }

    @isTest
    public static void updateIntegrationLoggerTest(){
        Test.startTest();
             IntegrationUtilities.updateIntegrationLogger('aaaa','bbbb','aasse','hhhh');
        Test.stopTest();
    }

    @isTest
    public static void getMakerIdTest(){
        Test.startTest();
              IntegrationUtilities.getMakerId();
        Test.stopTest();
    }

    @isTest
    public static void getCicNoTest(){
        Test.startTest();
             IntegrationUtilities.getCicNo();
        Test.stopTest();
    }

    @isTest
    public static void highPayloadResponseTest(){
        AsyncPayloadReponse[] AsyncPayloadReponses = new AsyncPayloadReponse[]{};
        AsyncPayloadReponse asyncPayload = new AsyncPayloadReponse('testref','testres','testexp');
            asyncPayload.encryptResponseExt = 'testencry';
            asyncPayload.encryptResponse = 'testres';
        AsyncPayloadReponses.add(asyncPayload);
        Test.startTest();
             IntegrationUtilities.highPayloadResponse(AsyncPayloadReponses);
        Test.stopTest();
    }

    // @isTest
    // public static void handleLowPayloadResponseTest(){
    //     Test.startTest();
    //          IntegrationUtilities.handleLowPayloadResponse(refIdRespMap);
    //     Test.stopTest();
    // }

    @isTest
    public static void getAPIKeysTest(){
        Test.startTest();
             IntegrationUtilities.getAPIKeys('pkey');
             IntegrationUtilities.getAPIKeys('iv');
             IntegrationUtilities.getAPIKeys('');
        Test.stopTest();
    }

    @isTest
    public static void getCoborrowerNameTest(){ 
        Test.startTest();
             IntegrationUtilities.getCoborrowerName('Co Borrower');
        Test.stopTest();
    }

    @isTest
    public static void saveImagetoSFTest(){

        Documents__c doc = [Select id, ContentVersionId__c FROM Documents__c LIMIT 1];

        Test.startTest();
             //IntegrationUtilities.saveImagetoSF('base64Imag',doc.Id,'');
        Test.stopTest();
    }

    @isTest
    public static void getEncryptedRequestTest(){ 
        Test.startTest();
            // IntegrationUtilities.getEncryptedRequest('requestJSON','34334433','vkey');
        Test.stopTest();
    }

    @isTest
    public static void getDecryptedResponseTest(){ 
        Test.startTest();
           //  IntegrationUtilities.getDecryptedResponse('requestJSON','LD334334433311A','vkey');
        Test.stopTest();
    }

    @isTest
    public static void getPlainTextForLogTest(){ 
        Test.startTest();
             IntegrationUtilities.getPlainTextForLog('encryResponse');
        Test.stopTest();
    }

    @isTest
    public static void parseJSONRequestTest(){ 
        String InsertApplicantResponseString = '{'+
        '  \"aadhaar_name\": \"Test ABC XYZ\",'+
        '  \"aadhaar_no\": \"344195214770\",'+
        '  \"aadhaar_otp_status\": \"Y\",'+
        '  \"aadhaar_serv_flag\": \"B\",'+
        '  \"aadhaar_status\": \"Verified\",'+
        '  \"active_money\": \"Y\",'+
        '  \"active_sweep_in\": \"1000\",'+
        '  \"active_sweep_out\": \"1000\",'+
        '  \"annual_income\": \"01\",'+
        '  \"appointment_location\": \"M\",'+
        '  \"appointment_date\": \"2021-02-12\",'+
        '  \"appointment_slot\": \"TestSlot\",'+
        '  \"campaign_id\": \"Test\",'+
        '  \"core_account_number\": \"1234567890\",'+
        '  \"create_user\": \"MBWAL\",'+
        '  \"crn\": \"103264128\",'+
        '  \"date_of_birth\": \"2021-02-12\",'+
        '  \"email\": \"abc@gmail.com\",'+
        '  \"fatca_reportable_flag\": \"N\",'+
        '  \"fathers_name\": \"Test Father\",'+
        '  \"firstName\": \"Test\",'+
        '  \"gender\": \"M\",'+
        '  \"home_branch_code\": \"12345\",'+
        '  \"is_aadhaar_pan_same\": \"Y\",'+
        '  \"kit_type\": \"PGN\",'+
        '  \"leadSource\": \"Google\",'+
        '  \"lastName\": \"Test\",'+
        '  \"company\": \"Kotak Bank\",'+
        '  \"fkyc_lc_code\": \"12345\",'+
        '  \"lc_code_name\": \"Kotak Employee\",'+
        '  \"lc_code\": \"MBOTP\",'+
        '  \"lead_id\": \"12345\",'+
        '  \"lg_code\": \"MBOTP\",'+
        '  \"marital_status\": \"M\",'+
        '  \"meeting_serv_flag\": \"Y\",'+
        '  \"meet_addr1\": \"TestAddr1\",'+
        '  \"meet_addr2\": \"TestAddr2\",'+
        '  \"meet_addr3\": \"TestAddr3\",'+
        '  \"meet_city\": \"City\",'+
        '  \"meet_pincode\": \"123456\",'+
        '  \"meet_state\": \"Test State\",'+
        '  \"middleName\": \"Middlename\",'+
        '  \"mobilePhone\": \"1234567890\",'+
        '  \"phone\": \"1234567891\",'+
        '  \"mode_of_operations\": \"9\",'+
        '  \"mothers_maidan_name\": \"TestMaiden\",'+
        '  \"new_wallet_flag\": \"Y\",'+
        '  \"nominee_flag\": \"Y\",'+
        '  \"nominee_address_1\": \"Test Address 1\",'+
        '  \"nominee_address_2\": \"Test Address 2\",'+
        '  \"nominee_address_3\": \"Test Address 3\",'+
        '  \"nominee_city\": \"Test\",'+
        '  \"nominee_country\": \"Test\",'+
        '  \"nominee_dob\": \"2021-02-12\",'+
        '  \"nominee_fName\": \"Test\",'+
        '  \"nominee_grdn_address_1\": \"Test Address\",'+
        '  \"nominee_grdn_address_2\": \"Test Address\",'+
        '  \"nominee_grdn_address_3\": \"Test Address\",'+
        '  \"nominee_grdn_add_flag\": \"Test\",'+
        '  \"nominee_grdn_city\": \"Test\",'+
        '  \"nominee_grdn_country\": \"Test\",'+
        '  \"nominee_grdn_dob\": \"2021-02-12\",'+
        '  \"nominee_grdn_email_add\": \"test@gmail.com\",'+
        '  \"nominee_grdn_fname\": \"Test\",'+
        '  \"nominee_grdn_lname\": \"Test\",'+
        '  \"nominee_grdn_name\": \"Test\",'+
        '  \"nominee_grdn_phone_no\": \"1234567890\",'+
        '  \"nominee_grdn_pin\": \"Test\",'+
        '  \"nominee_grdn_relstn_with_key\": \"SON\",'+
        '  \"nominee_grdn_relstn_with_minor\": \"FAT\",'+
        '  \"nominee_grdn_state\": \"Test State\",'+
        '  \"nominee_grdn_title\": \"MR.\",'+
        '  \"nominee_lname\": \"Test\",'+
        '  \"nominee_mname\": \"Test\",'+
        '  \"nominee_name\": \"Test\",'+
        '  \"nominee_nominee_add_flag\": \"Test\",'+
        '  \"nominee_phone_no\": \"1234567890\",'+
        '  \"nominee_pin\": \"123456\",'+
        '  \"nominee_relstn_with_app\": \"FAT\",'+
        '  \"nominee_state\": \"Test State\",'+
        '  \"nominee_title\": \"MR.\",'+
        '  \"occupation_type\": \"P\",'+
        '  \"office_addr_line1\": \"Test\",'+
        '  \"office_addr_line2\": \"Test\",'+
        '  \"office_addr_line3\": \"Test\",'+
        '  \"office_city\": \"Test\",'+
        '  \"office_country\": \"Test\",'+
        '  \"office_state\": \"Test\",'+
        '  \"office_zipcode\": \"123456\",'+
        '  \"online_conf_code\": \"\",'+
        '  \"online_ref_1\": \"\",'+
        '  \"online_ref_2\": \"\",'+
        '  \"online_ref_3\": \"\",'+
        '  \"original_lead_source\": \"SWNW\",'+
        '  \"pan_image\": \"\",'+
        '  \"pan_no\": \"AKUPV9601L\",'+
        '  \"pan_valid_flag\": \"Y\",'+
        '  \"pep_flag\": \"Y\",'+
        '  \"permanent_addr_line1\": \"Test\",'+
        '  \"permanent_addr_line2\": \"Test\",'+
        '  \"permanent_addr_line3\": \"Test\",'+
        '  \"permanent_city\": \"Test\",'+
        '  \"permanent_country\": \"Test\",'+
        '  \"permanent_state\": \"Test\",'+
        '  \"permanent_zipcode\": \"Test\",'+
        '  \"phone_number_status\": \"Y\",'+
        '  \"photo_stream\": \"Test\",'+
        '  \"preffered_address\": \"RESIDENCE\",'+
        '  \"promotional_code\": \"Test\",'+
        '  \"promo_code\": \"Test\",'+
        '  \"residence_addr_line1\": \"Test\",'+
        '  \"residence_addr_line2\": \"Test\",'+
        '  \"residence_addr_line3\": \"Test\",'+
        '  \"residence_city\": \"Test\",'+
        '  \"residence_country\": \"Test\",'+
        '  \"residence_state\": \"Test\",'+
        '  \"residence_zipcode\": \"123456\",'+
        '  \"rm_code\": \"Test\",'+
        '  \"sb_account_number\": \"123456789\",'+
        '  \"scheme_code\": \"SJIFL\",'+
        '  \"self_declaration\": \"Test\",'+
        '  \"sign_url\": \"Test\",'+
        '  \"salutation\": \"MR.\",'+
        '  \"verification_mode\": \"DEMOAUTH\",'+
        '  \"preferred_product_desc\": \"Test product\",'+
        '  \"lead_score\": \"Test\",'+
        '  \"risk_score\": \"12345\",'+
        '  \"tmx_data\": \"Test\",'+
        '  \"pan_display_name\": \"Test\",'+
        '  \"pan_nsdl_api_name\": \"Test\",'+
        '  \"scc_applied\": \"Y\",'+
        '  \"fd_amount\": \"1000\",'+
        '  \"account_opening_date\": \"2021-02-12\",'+
        '  \"mf_applied\": \"Y\",'+
        '  \"kra_verified\": \"Y\",'+
        '  \"stp_cc_applied\": \"Y\",'+
        '  \"ip_funded\": \"Y\",'+
        '  \"channel_of_appointment\": \"OCC\",'+
        '  \"esc_flag_for_appointment\": \"Y\",'+
        '  \"gpa_flag\": \"Y\",'+
        '  \"so_flag\": \"Y\",'+
        '  \"hc_flag\": \"Y\",'+
        '  \"nsdl_pan_status\": \"Y\",'+
        '  \"aadhar_pan_link_status\": \"Y\",'+
        '  \"signature_image\": \"\",'+
        '  \"workflow\":\"OTP\",'+
        '  \"verna_decl\": \"Y\",'+
        '  \"verna_lang\": \"Y\",'+
        '  \"image_id\": \"12345\",'+
        '  \"image_name\":\"Iname\",'+
        '  \"image_stream\":\"\",'+
        '  \"no_nominee_decl_ver\": \"Y\",'+
        '\"maiden_name\":\"Test M name\"'+
        '}';
        Test.startTest();
            // IntegrationUtilities.parseJSONRequest(InsertApplicantResponseString,'Class');
        Test.stopTest();
    }

    @isTest
    public static void handleLowPayloadResponseTest(){ 
        AsyncPayloadReponse[] AsyncPayloadReponses = new AsyncPayloadReponse[]{};
        AsyncPayloadReponse asyncPayload = new AsyncPayloadReponse('testref','testres','testexp');
            asyncPayload.encryptResponseExt = 'testencry';
            asyncPayload.encryptResponse = 'testres';
        AsyncPayloadReponses.add(asyncPayload);
        Test.startTest();
        IntegrationUtilities.handleLowPayloadResponse(AsyncPayloadReponses);
        Test.stopTest();
    }

    // @isTest
    // public static void highPayloadResponseTest(){ 
    //     Test.startTest();
    //          IntegrationUtilities.highPayloadResponse('dasadfar');
    //     Test.stopTest();
    // }

    @isTest
    public static void getPlainTextForLogFromFlowTest(){
        List<String> str = new List<String>();
        str.add('str1');
        str.add('str2');
        str.add('str3');
        str.add('str4');
        str.add('str5');
        Test.startTest();
          //   IntegrationUtilities.getPlainTextForLogFromFlow(str);
        Test.stopTest();
    }

    @isTest
    public static void parseResponseDOMTest(){

        HttpResponse response = new HttpResponse();
        response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');  
        response.setStatusCode(200);
        Test.startTest();
             //IntegrationUtilities.parseResponseDOM(response);
        Test.stopTest();
    }
    @isTest
    public static void saveTKNIDTest(){
        Documents__c doc = [Select id,IND_Aadhaar_Vault_Token_ID__c FROM Documents__c LIMIT 1];
        Test.startTest();
        IntegrationUtilities.saveTKNID(doc.Id,'fghhkjhkjjkjkljlkjlkjlljl');
        Test.stopTest();
    }

}


// HttpResponse response = new HttpResponse();
// response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');            
// response.setStatusCode(200);