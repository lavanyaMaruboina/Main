@isTest
public class IND_InsertApplicantWrappertest {
    public static void test() {
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
        
        IND_InsertApplicantWrapper userInsertData = (IND_InsertApplicantWrapper)IND_InsertApplicant.parseJSONRequest(InsertApplicantResponseString, 'IND_InsertApplicantWrapper');
        
        System.assert(userInsertData != null);
    }

}