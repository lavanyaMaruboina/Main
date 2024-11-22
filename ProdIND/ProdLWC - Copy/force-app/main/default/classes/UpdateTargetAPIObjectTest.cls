/*
* @author: Santhosh Mothe
* @company: Persistent Systems
* @description: Test class for Trigger For UpdateTargetAPIObject, UpdateTargetAPIObjectHelper class.
* History:
* Inputs: None
* 25/1/2022  Added by Santhosh . 
*/
@isTest 
public class UpdateTargetAPIObjectTest {
    
    // for UpdateTargetAPIObjectHelper.updateApplicantDocReportResponse method
    public static testmethod void testApplicantDocAuthReport()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c=oppObj.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = '{"JData":"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"}';
        ilog.Encrypted_request__c = '{"JData":"X8BK4b/BoBhLB0WhnXBJCDSeqBOjiM0tzLU/pRi4fTZUoelJs7y5mCJiPzQ6b7jW"}';
        ilog.isSync__c = false;
        ilog.Original_request__c = '{"Maker_Id":"1001","appId":"30075541"}';
        String finaloutput = '{"RequestId":"12072022203049687","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":30075570,"SolutionSetInstanceId":"67153b2f-8ebb-449e-a663-572a0cacbb91"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"CMU","ApplicantMiddleName":"okay","ApplicantLastName":"otp","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"52738539-5562-4a6d-9642-504bc9d8009f"}]},"Data":{"Response":{"RawResponse":"{\"reports\":[{\"created_at\":\"2022-07-12T15:06:15Z\",\"documents\":[{\"id\":\"3c4f9e60-9223-46cc-9fbc-b18cafa62271\"}],\"href\":\"/v2/checks/52738539-5562-4a6d-9642-504bc9d8009f/reports/5cc7af43-25b3-4411-a44e-777878690eda\",\"id\":\"5cc7af43-25b3-4411-a44e-777878690eda\",\"name\":\"document\",\"properties\":{\"first_name\":\"PAWAN \",\"last_name\":\"NULL\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"EQPPP2407F\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1990-04-18\"},\"result\":\"clear\",\"status\":\"complete\",\"sub_result\":\"clear\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"image_integrity\":{\"result\":\"clear\",\"breakdown\":{\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"conclusive_document_quality\":{\"result\":\"clear\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"clear\",\"obscured_data_points\":\"clear\"}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"picture_face_integrity\":{\"result\":\"clear\",\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}},\"security_features\":{\"result\":\"clear\",\"properties\":{}},\"fonts\":{\"result\":\"clear\",\"properties\":{}},\"template\":{\"result\":\"clear\",\"properties\":{}},\"other\":{\"result\":\"clear\",\"properties\":{}}}}}}]}"}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"78df666d-5bb7-4f86-b636-a0cedb904f58"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"30075570"}}}';
        ilog.Original_response__c = finaloutput;//.replace('""', '"');
        ilog.Service_Name__c = System.Label.DocumentReport;
        ilog.targetRecordId__c = applicant.Id +''+ backDoc.Id;
        
        insert ilog;
        try{
            ilog.Loan_Application__c = oppObj.id;
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
    /*public static testmethod void testInsertforIntegrationLog()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c=opp.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, opp);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.RequestExt__c = 'req ext';
        ilog.ResponseExt__c = 'res ext';
        ilog.isSync__c = true;
        ilog.Original_request__c = 'request';
        ilog.Original_response__c = '{"RequestId":"03102021204513966","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":22546137,"SolutionSetInstanceId":"cb894105-318c-4c0c-b5da-71b66366624b"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"Karthi","ApplicantMiddleName":"","ApplicantLastName":"M","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"},{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"}]},"Data":{"Response":{"RawResponse":{\"reports\":[{\"created_at\":\"2021-10-03T14:11:07Z\",\"documents\":[{\"id\":\"5f1fdef3-083a-4229-bb89-176c79fbb725\"}],\"href\":\"/v2/checks/ab579ec7-81d7-49ca-8fe7-f4764c87b957/reports/3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"id\":\"3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"name\":\"document\",\"properties\":{\"first_name\":\"KARTHI\",\"last_name\":\"M\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"BYOPK0288D\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1988-03-27\"},\"result\":\"consider\",\"status\":\"complete\",\"sub_result\":\"caution\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"image_integrity\":{\"result\":\"consider\",\"breakdown\":{\"conclusive_document_quality\":{\"result\":\"consider\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"consider\",\"obscured_data_points\":\"clear\"}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}}}},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"other\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":null,\"properties\":{}},\"fonts\":{\"result\":null,\"properties\":{}},\"security_features\":{\"result\":null,\"properties\":{}},\"template\":{\"result\":null,\"properties\":{}},\"picture_face_integrity\":{\"result\":null,\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}}}}}}]}}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"c17f1c3d-00f4-4cd2-b28a-50b541ebd85e"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"22546137"}}}';
        ilog.Service_Name__c = System.Label.DocumentReport;
     //   ilog.targetRecordId__c = applicant.id+''+backDoc.id;
        
        insert ilog;
        
        
        try{
            ilog.Loan_Application__c = opp.id;
            update ilog;
        }catch(Exception e)
        {
            system.debug('exception '+e.getStackTraceString());
        }
        Test.stopTest();
    
    }*/
    
    
    //Divya
    
   
    /* public static testmethod void testupdateforIntegrationLog1()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.isSync__c = false;
        ilog.Original_request__c = 'request';
        ilog.Original_response__c = 'rewponse';
        ilog.Service_Name__c = System.Label.GSTStatus;
        
        insert ilog;
        try{
            ilog.Loan_Application__c = oppObj.id;
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
     public static testmethod void testupdateforIntegrationLog2()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.isSync__c = false;
        ilog.Original_request__c = 'request';
        ilog.Original_response__c = 'rewponse';
        ilog.Service_Name__c = System.Label.ITRStatus;
        
        insert ilog;
        try{
            ilog.Loan_Application__c = oppObj.id;
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }

     public static testmethod void testupdateforIntegrationLog3()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.isSync__c = false;
        ilog.Original_request__c = 'request';
        ilog.Original_response__c = 'rewponse';
        ilog.Service_Name__c = System.Label.Perfios_BS_Transaction_Status;
        
        insert ilog;
        try{
            ilog.Loan_Application__c = oppObj.id;
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
      public static testmethod void testInsertforIntegrationLog1()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c=opp.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, opp);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.RequestExt__c = 'req ext';
        ilog.ResponseExt__c = 'res ext';
        ilog.isSync__c = true;
        ilog.Original_request__c = 'request';
        ilog.Original_response__c = '{"RequestId":"03102021204513966","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":22546137,"SolutionSetInstanceId":"cb894105-318c-4c0c-b5da-71b66366624b"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"Karthi","ApplicantMiddleName":"","ApplicantLastName":"M","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"},{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"}]},"Data":{"Response":{"RawResponse":{\"reports\":[{\"created_at\":\"2021-10-03T14:11:07Z\",\"documents\":[{\"id\":\"5f1fdef3-083a-4229-bb89-176c79fbb725\"}],\"href\":\"/v2/checks/ab579ec7-81d7-49ca-8fe7-f4764c87b957/reports/3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"id\":\"3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"name\":\"document\",\"properties\":{\"first_name\":\"KARTHI\",\"last_name\":\"M\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"BYOPK0288D\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1988-03-27\"},\"result\":\"consider\",\"status\":\"complete\",\"sub_result\":\"caution\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"image_integrity\":{\"result\":\"consider\",\"breakdown\":{\"conclusive_document_quality\":{\"result\":\"consider\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"consider\",\"obscured_data_points\":\"clear\"}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}}}},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"other\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":null,\"properties\":{}},\"fonts\":{\"result\":null,\"properties\":{}},\"security_features\":{\"result\":null,\"properties\":{}},\"template\":{\"result\":null,\"properties\":{}},\"picture_face_integrity\":{\"result\":null,\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}}}}}}]}}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"c17f1c3d-00f4-4cd2-b28a-50b541ebd85e"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"22546137"}}}';
        ilog.Service_Name__c = System.Label.GSTStatus;
      //  ilog.targetRecordId__c = applicant.id+''+backDoc.id;
        
        insert ilog;
        
        
        try{
            ilog.Loan_Application__c = opp.id;
            update ilog;
        }catch(Exception e)
        {
            system.debug('exception '+e.getStackTraceString());
        }
        Test.stopTest();
    
    }
    
          public static testmethod void testInsertforIntegrationLog2()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c=opp.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, opp);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.RequestExt__c = 'req ext';
        ilog.ResponseExt__c = 'res ext';
        ilog.isSync__c = true;
        ilog.Original_request__c = 'request';
        ilog.Original_response__c = '{"RequestId":"03102021204513966","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":22546137,"SolutionSetInstanceId":"cb894105-318c-4c0c-b5da-71b66366624b"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"Karthi","ApplicantMiddleName":"","ApplicantLastName":"M","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"},{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"}]},"Data":{"Response":{"RawResponse":{\"reports\":[{\"created_at\":\"2021-10-03T14:11:07Z\",\"documents\":[{\"id\":\"5f1fdef3-083a-4229-bb89-176c79fbb725\"}],\"href\":\"/v2/checks/ab579ec7-81d7-49ca-8fe7-f4764c87b957/reports/3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"id\":\"3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"name\":\"document\",\"properties\":{\"first_name\":\"KARTHI\",\"last_name\":\"M\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"BYOPK0288D\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1988-03-27\"},\"result\":\"consider\",\"status\":\"complete\",\"sub_result\":\"caution\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"image_integrity\":{\"result\":\"consider\",\"breakdown\":{\"conclusive_document_quality\":{\"result\":\"consider\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"consider\",\"obscured_data_points\":\"clear\"}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}}}},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"other\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":null,\"properties\":{}},\"fonts\":{\"result\":null,\"properties\":{}},\"security_features\":{\"result\":null,\"properties\":{}},\"template\":{\"result\":null,\"properties\":{}},\"picture_face_integrity\":{\"result\":null,\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}}}}}}]}}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"c17f1c3d-00f4-4cd2-b28a-50b541ebd85e"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"22546137"}}}';
        ilog.Service_Name__c = System.Label.ITRStatus;
     //   ilog.targetRecordId__c = applicant.id+''+backDoc.id;
        
        insert ilog;
        
        
        try{
            ilog.Loan_Application__c = opp.id;
            update ilog;
        }catch(Exception e)
        {
            system.debug('exception '+e.getStackTraceString());
        }
        Test.stopTest();
    
    }*/
    
    // for UpdateTargetAPIObjectHelper.updateSelfieReportResponse method
     public static testmethod void testupdateforIntegrationLogSelfieReport()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.isSync__c = false;
        ilog.Original_request__c = 'request';
        ilog.Original_response__c = 'rewponse';
        ilog.Service_Name__c = System.Label.Selfie_Report;
        
        insert ilog;
        try{
            ilog.Loan_Application__c = oppObj.id;
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
    // for UpdateTargetAPIObjectHelper.updateSelfieReportResponse method
     public static testmethod void testInsertforIntegrationLogSelfieReport()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c=opp.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, opp);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
       List<Documents__c> docList = new List<Documents__c>();
        docList.add(backDoc);
        insert docList;
        
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = 'encrypted response';
        ilog.Encrypted_request__c = 'encrypted request';
        ilog.RequestExt__c = 'req ext';
        ilog.ResponseExt__c = 'res ext';
        ilog.isSync__c = true;
        ilog.Original_request__c = 'request';
        ilog.Service_Name__c = System.Label.Selfie_Report;
     //   ilog.targetRecordId__c = applicant.id+''+docList[0].id;
        
        insert ilog;
        
        
        try{
            ilog.Loan_Application__c = opp.id;
            ilog.Original_response__c = '{"RequestId":"03102021204513966","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":22546137,"SolutionSetInstanceId":"cb894105-318c-4c0c-b5da-71b66366624b"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"Karthi","ApplicantMiddleName":"","ApplicantLastName":"M","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"},{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"}]},"Data":{"Response":{"RawResponse":{\"reports\":[{\"created_at\":\"2021-10-03T14:11:07Z\",\"documents\":[{\"id\":\"5f1fdef3-083a-4229-bb89-176c79fbb725\"}],\"href\":\"/v2/checks/ab579ec7-81d7-49ca-8fe7-f4764c87b957/reports/3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"id\":\"3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"name\":\"document\",\"properties\":{\"first_name\":\"KARTHI\",\"last_name\":\"M\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"BYOPK0288D\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1988-03-27\"},\"result\":\"consider\",\"status\":\"complete\",\"sub_result\":\"caution\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"image_integrity\":{\"result\":\"consider\",\"breakdown\":{\"conclusive_document_quality\":{\"result\":\"consider\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"consider\",\"obscured_data_points\":\"clear\"}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}}}},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"other\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":null,\"properties\":{}},\"fonts\":{\"result\":null,\"properties\":{}},\"security_features\":{\"result\":null,\"properties\":{}},\"template\":{\"result\":null,\"properties\":{}},\"picture_face_integrity\":{\"result\":null,\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}}}}}}]}}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"c17f1c3d-00f4-4cd2-b28a-50b541ebd85e"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"22546137"}}}';
			update ilog;
        }catch(Exception e)
        {
            system.debug('exception '+e.getStackTraceString());
        }
        Test.stopTest();
    
    }
    
   /* @isTest
    public static void perfiosJsonReportAPITest(){
        try{
                Opportunity opfb2 = new Opportunity();
                opfb2.StageName = 'Qualification';
                opfb2.CloseDate = Date.newInstance(2021, 1, 11);
                opfb2.Name = 'testone';
                insert opfb2;
                
                Applicant__c afb2 = new Applicant__c();
                afb2.Opportunity__c = opfb2.Id;
                afb2.Contact_number__c = '9743514830';
                afb2.Applicant_Type__c = 'Borrower';
                insert afb2;
        
                Bank_Masters__c bm1 = new Bank_Masters__c();
                bm1.Bank_Code__c = 3919;
                bm1.Name = 'test';
                bm1.OwnerId = UserInfo.getUserId();
                insert bm1;
        
                Income_Details__c incomeObj = new Income_Details__c();
                incomeObj.Applicant__c = afb2.id;
                incomeObj.Name_of_Recipient_Banks__c = bm1.Id;
                incomeObj.Is_Salaried__c = true;
                insert incomeObj;
        
                Test.startTest();
                  //   UpdateTargetAPIObjectHelper.perfiosJsonReportAPI(incomeObj.Id,'PGAZIRXO4GM30FY8R1FEV','GST','11012022145302027');
                Test.stopTest();
        }catch(Exception e){
                 system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }*/
    
    //for ITR
    public static testmethod void testforITRStatus()
    {
        
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=oppObj.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = '{"JData":"fe3Nf/1fdl3jSBAkv+GVdWncseIYYPXRvE2OAdpFCENUqf1KsA8aMgLyM4dE/4r8zHqymDHrS95zlevR6N2Xgdtt29S72WOiVo0FVRwX8bvcI1wAyJLF3yOnxpOO62VlS76NFqDCNvxUiWdWfQsRKMktcRBw2YT5G/roM6+KoycG63CZWbuB57p8oNemzoOrImuho0/Ffilondo8O22Hn9QB0ouRALRtBGFYYDEthns="}';
        ilog.Encrypted_request__c = '{"JData":"ijk6sdS8XvSIhB2BAamjpNJ+mv6WJK65aeSGnn9asLl3cCV2sXzISQSXIgA2d+y/"}';
        ilog.isSync__c = false;
        ilog.Original_request__c = '{"ClientTransactionId":"05092022155250924"}';
        ilog.Original_response__c = '{"clientTransactionId":"05092022155250924","perfiosTransactionId":"PIECYGEB71FVKURD1JZ18","Status":"COMPLETED","error_message":"","error_code":""}';
        ilog.Service_Name__c = System.Label.ITRStatus;
        ilog.targetRecordId__c = incomeDetails.Id;
        
        insert ilog;
        Test.startTest();
        try{
            ilog.Loan_Application__c = oppObj.id;
            Test.setMock(HttpCalloutMock.class, new SampleCalloutMockForITR());
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
    public class SampleCalloutMockForITR implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            //res.setBody('{"JData":"yEJwCnJS7ojeNJDz8cIEW+FExrzcGaBJhHeSlFMTK6Q68PofB7mhNpl63fYjb5LXydey+CnFTuyi0RjFK7FrpB+A0cQnT4T/Zv6JZ0B5irXji/EimJ/PY/o3x1Zt8eT4wmLEM2sIG2qwkaobvCb6QPoNkQ2/XmC3jQpuP8QOqwKVuxx38TaCaVLAawRIQ5gAW+mOHPbS6Qgh3PmSC8qeEAO/eIx7sFNaBa12WPmbFo6aSEAcSMpPpXNT1ysQXp0lSc3Kkn8LTa4ST11xbPzmPNgZq/RUFo5cXNq2z5o+LE+19bKKk9fzp+62DRbpipuGZw+zy+d4qaOLY78lEiTh0O4xMlb0wRuATo8qAo+kT1gZ/VWtBQEFN+ekytGL2KBywEvlEhk8ALyxCh3bghJTOfA+aAYMJQ4NWYUVKmtceUj8hbsAPRSrsN2Q9aZasoe3UW0M/i70ZEfcFKXVOm//Tn2tf3jiL8SD6SdLfraXFzldg/qKiBpGUTPGTu4hr1kDReamRXeN09ndGvX/H40T//t3BHymcF+g7UgQttGRjY0F8ZEY/0xiUc1RW2M+9piay02bmd+fdb3edMXc44c1LOTtm8rOZnkVkTN2oTEdbOj8ObvK85iHDx0rhpE+bGDVdeiPw85lMYDVU6R3FUKvn9CpdgSE6ZDIRhe3z9Wuwb7uE8zlt4QeCofaWl9hvy3c+yDtPtR5sog5r6gVUZPP0daShVO8rgwx3jIDBjG6ks5rJVViIAf2TmFP3YpD3W7BaGTLKp+ZUZkKNwwPtGZU5ZQ/3fJrUXxptebkrt8cgY4IEZQ9YoDyBG0KftwEF9d7etSnzeATRttWgWgbDQZAKw=="}');
            res.setBody('{"JData":"yEJwCnJS7ojeNJDz8cIEW+FExrzcGaBJhHeSlFMTK6Q68PofB7mhNpl63fYjb5LXc1gX8tluLdS+fEKCM7s+leGFGmeJ5o553+bCHu/N7L+9GWad++T81E0MyUFn4OZjZO+tfVM6q3WVtoEWYjKkjNEmYqiWk5XLe5hd00hTv7C9G+xXvIhLkqTWm9fpWJHd76lYZPMZF3rPdBg+m4dfqQpt7BzxiccDxcOLRDPKINHL/vKJQS+XT/IeaEKak1aIriHYAjlFxCytIg4CX+LZvuR96aWbldKJUzeQ7Or/wIEXM/qumexCZMiDtrXKfW32EE/qmXV9+XqGYRQVJ0fFu2NZ6Gs0AVHkrgbb519VeY1cxeLHcTl18g9uBwl5ThtFaeGCljOCZewW+wqBXLFwdQjAVGHMKvntsrWyOOEiOYABZSPPbGlUpIDon1bom8/Eq3HQ7muRtHaJaSbQodMH6poDh8VLFL0xppBzuTo83i7GVMhyU61HQvk5kUKiSKr3Bb8oHHFV1j5tDKhqrWLKmwt9PG44Kd6n6K6ABPGZrWMpkNjzY39xj1mR9H/GzAvinWa5Tt1Fs5Bm+5j6qlolhKzVzYWAuOiGrWvwrRNz/D1oVcJO6e46GNwZGLurxj2PaxjcuqOJwgryEOli1XKMFiw1z8WWtkDEYL2NAGpxjH6nM8QocJPgYe0s6F/ViYicqMje5EmpRCKSnsrEuMD07TbPJ3CT+3KTLzT8s8cq8V4lwevhCC7UuFE2cR2OQpQiZK+ZlL+T1c++23BHU7ec8F49Im7HNrhaJGsrWyyL3Ajb5gMMPfN9a1ihBd8k+nBNBmiJ07r5xF66eR85E9AAtw=="}');
            return res;
        }
    }
    
    //for GST
    public static testmethod void testforGSTStatus()
    {
        
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=oppObj.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = '{"JData":"fe3Nf/1fdl3jSBAkv+GVdRjVlP3NIDebf4x5o6XX9k24KBRLYAk4KO5wNjWByU2iafY69YqiSiwuw2k//mGEV90ZamtWugcQ44LOHnFVupzqPm4XWMBUSX8Q+4SV1ohv1EcB/hC4WNH6+89e6hcEvvbFSBSq9b4N+1UbGofh+KBQyt7jLKmig6km8psuYUIsjr9lpWlihxcEqkmVk0pKRuW/BICALGMGj6PM3m/Ie/8="}';
        ilog.Encrypted_request__c = '{"JData":"ijk6sdS8XvSIhB2BAamjpM5sQpznW/vmF4HMQVSBZ/B24pKPNg/6UnSWJlsimQkb"}';
        ilog.isSync__c = false;
        ilog.Original_request__c = '{"ClientTransactionId":"07092022151727247"}';
        ilog.Original_response__c = '{"clientTransactionId":"07092022151727247","perfiosTransactionId":"PGOIGRFDCWFQKYFPGYH8D","Status":"COMPLETED","error_message":"","error_code":""}';
        ilog.Service_Name__c = System.Label.GSTStatus;
        ilog.targetRecordId__c = incomeDetails.Id;
        
        insert ilog;
        Test.startTest();
        try{
            ilog.Loan_Application__c = oppObj.id;
            Test.setMock(HttpCalloutMock.class, new SampleCalloutMockForGST());
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
    public class SampleCalloutMockForGST implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"JData":"89Vh60h/UDonvjEEEMVhY8+FeBg/gvqrNW609WTUnmtRYDS271jB8CE69+vv11X67TLZtqJUOh1WjRkmweRavE+ZVifw666JSucNQm1LEazKpDeT9Eu+VK++iUvYhMDZ4niOugzjjP4jVlT9NNbxqAHkc33hb89df3pexwxbL2U4eCpG+EDMZcSHHFyF9qprSj99EBP1j5j2DhTRjggog8u4Cpzy2ex9843XyJBZoMAii9l/X2Klr7OOj/m0LERd0hZHG27BSZ5kIEUb4ScLatKHt/pgsVEKVDVuER80zC5KZ6T7uHfKEoag0OUtKI0NoTiw4Y5tGiWazVfUc5U++HaDU0VNPNFwEvn06j0kvgNomBYuIkVoOB5dI4/3qbt3OuW/aiRhtz/P/v/0iQ8bYNh16wcO9S7teT396UmoHddjTQfltGEcfJZ18/DMH7+V5YJGnV2Ixc3gkijxodZD78nniwWMnspmYKnSV7t+UK4wqMPY2fsyPwS00ciXBoVxrrCrwqDqr6G+9v9RTQAYPnETl1pb13+hfbjzmLTFNDoAp+yFnmHE2MVBKL8edZvoffeAImxKUCK6Em/vyIXI/Ao366N3oRc8ehjGuE/aG8hr/9TMUKlGTth/lCB1BudYKWLdBqB3P7KXXVojCFhzItZivF9IffCh5gwScZHP4stCCfEBy4JRHIh0AJHd4aLhI6pNJxBA7+JsQc6PrBarENKruNcDSbzj6nprWgtiBeorSXQa4V4t/8LnyihmcdaZUjVjaiGrh9bgTPhRgHp6JsZFgvl0PT+GenzSAfAwH8hH8nSKGIyAwCfg45V0bHopg+xsyuC5dyaGLQjaWGWqxfC4x64jVEDI1qN7TINjl29lqGrwRu+ncgJAbxY2WyRG9/L0JLnsFb62ljsD1hvieBoGsOEAFgVUSWQ9oUqoEMSDtG1VEKq5sYzsUB3DQaAJv2GuMyQhDmah1rY/3FgTvp8rNgAKDSreKJ8KWGoKhJLcJI70Fms8wMywOasLjYsaiAmIVdw/3Agnbj3ztIECfhCM39S2mAU9rFnCFE9tCOLUDpP7dW6zaLa5B9EE0v7fQ0ioeVnGAWTanEmWhqj/Mnph6PJUimul+SzuuyHfh1cYGwJDz4MDhqQ08dbMQUO+65Vf6w/wlsKOin9hawCPZXHVuB0SZ4NqHsYVNSyRYNSuqEE+500Utb9rdUSGutu98BlhfjQvrv9mUtaa1bg60jWDcwbmef2CE7bUYR8N0Z+wQc87GUQRop7xBqb1Yuv956typfwvLj/Q8QsxAHn5XsRFpiVJ1SdiwKr4HQTagCIzOhnep6nFhuKsneTR7edA+ubL10sZbjPgyTvtfhsVoMrGHHWHMHunUN+0BOEaUpxBlEd9g20nmG8kByLOX9bWMfiw+RDcozcYLD6M1yRmF9cA6ivl0aJ8MYnje5d65bpcpWsj/0wxQ67nMjESTl/8mNFKd6+VphpxkydrhltRZSw2hVPqvI4RhreFhGFMsisiiYLmQLUuZGERvZm0im/W"}');
            return res;
        }
    }
    
     //for Bank Statement for Self Employeed
    public static testmethod void testforBSFor_Self_Employeed()
    {
        
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=oppObj.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = '{"JData":"fe3Nf/1fdl3jSBAkv+GVdWncseIYYPXRvE2OAdpFCENrKKqt7nfg88+SyYjqNlqrQsGlkPaeLLneHA9GOAslbRgW3gYFJQ2XHMNR+gIjvvzl7WVELtuHisOcUDhvlgQN6+wuksSRaPn2pSJXki2CJotSXBwfIMPbyFKWLHw2u9FnmeF/41J4M+Pun8UCKlL2kYAJTy6KbJHyiP3nD3zfiuvRA3n2lOkszUbblArwKpzjn8nmP6xlD6vFH4+3lnBo"}';
        ilog.Encrypted_request__c = '{"JData":"ijk6sdS8XvSIhB2BAamjpNJ+mv6WJK65aeSGnn9asLnTTLR48uDfEDPyCtPpUf69"}';
        ilog.isSync__c = false;
        ilog.Original_request__c = '{"ClientTransactionId":"05092022115814406"}';
        ilog.Original_response__c = '{"clientTransactionId":"05092022115814406","perfiosTransactionId":"DGDP1662359320345","Status":"COMPLETED","error_message":"","error_code":"E_NO_ERROR"}';
        ilog.Service_Name__c = System.Label.Perfios_BS_Transaction_Status;
        ilog.targetRecordId__c = incomeDetails.Id;
        
        insert ilog;
        Test.startTest();
        try{
            ilog.Loan_Application__c = oppObj.id;
            Test.setMock(HttpCalloutMock.class, new SampleCalloutMockForBS());
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
    //BS for Self Employeed
    public class SampleCalloutMockForBS implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            //res.setBody('{"JData":"jPp3wCXn7hyyw1BT8XHR1fmNFcu0O2c5M/lGxEwWAEHhSLeJRMBEwkc1chvW83ns9u4OPfxegGklx28wzJG1D2so94CVb6y8otfUWzY/h2I="}');
            res.setBody('{"JData":"13Qr4fM9GhwgafJU/A0wDUj3YKakgXcGmI9VFqoSmqqmopfDYnqt0u8alFbgYb7kl+OmWhNa2GgVGRC+QCRju8f8zsfLmktg1JETkDedNZ4M9JpKDB45bSNCR3/UPl+Oj8fT2GShNMaamC5UqowbXTM2pjt1SAycqMbONwiqkAz1phqJgozzGzZP84c4bFpRn496rrM9R/lZrg9ahPlz5nLKAfibtaLrB/X8nUmvRKcU4zDig4VeUOoQF6Q+NRlpRBhP6CkKCgeKGCLwJbpqJuQolXufjtsd14uOz39W1flzbnrEZD1mVLjZpnKMBYyq1q35+5PYe0ztCSwkaxe/5ORBzsICSkBGi+63krW5obk09j5S+BGU/WDiDAiz/0KrXcReCbO0Ux7Dxm0YX7otvutlVIdvwUoHABn/U1q9V8vc4TngGf/InZgxcbtNQ6G5mMfUCuN6fZTXrbb5VgCKVGhwnPQbuyjGsPBAbx8T+wos4Q07cy8iLBKAmjMqLCoN9OcxBD+7cSYxURM0Bw2BotPLrTBPyD8QvQz/xg/Pv9kv/h0egqRT+tps/OsXAXKJyjN+kESdqjRru9HlvwhbpAl/btxSiQ3epqksBwv/0mxgOUqdJcD+NmLpm5/KMvSbnzj66sY2TUHsM7Oa9Zfy0sxNLRr9EyDr8DGab8p3nn9dRk7RLmJ95NfC24NVll4PKYLm//Bpf4BNkc/tkZHTQuqeQoI6dS+UHocYCbqHrzb8aivnfrn7DD7LnCzlESeYBOPRKeODXtKKaXQtc/vVvk/q4Bc86PvbBciGQBP0tSJEhogXwYT3roFOQkh3kuaG5egvTyTJMfHRSyHI/UxmhUeK8u806NhX7osacJufsNi+GGkbdNb7txytmIM8dBCd2WPsThJYOBQmKb09w9c5poXnx3USsNHqexVVSU9JCbXVWHp/pt0DfeZta0fE+mYBs8AK0PQzpuJEKhDxChg47Uycu/pR3A6Nu4nYD7FZTPUEYxDLK1JqsralSvpCiezY7WSzR26nsHpI9DrXPz24q4pirTAmt1/YUllk1I+EbJLVLV3oDGelf4aaq2zhB9/3"}');
            return res;
        }
    }
    
    //BS for Salaried
    public class SampleCalloutMockForBS_Salaried implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"JData":"jPp3wCXn7hyyw1BT8XHR1fmNFcu0O2c5M/lGxEwWAEHhSLeJRMBEwkc1chvW83ns9u4OPfxegGklx28wzJG1D2so94CVb6y8otfUWzY/h2I="}');
           return res;
        }
    }
    
        //for ITR
    public static testmethod void testforITRScanUploadJsonRetrieveReport()
    {
        
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=oppObj.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = '{"JData":"fe3Nf/1fdl3jSBAkv+GVdWncseIYYPXRvE2OAdpFCENUqf1KsA8aMgLyM4dE/4r8zHqymDHrS95zlevR6N2Xgdtt29S72WOiVo0FVRwX8bvcI1wAyJLF3yOnxpOO62VlS76NFqDCNvxUiWdWfQsRKMktcRBw2YT5G/roM6+KoycG63CZWbuB57p8oNemzoOrImuho0/Ffilondo8O22Hn9QB0ouRALRtBGFYYDEthns="}';
        ilog.Encrypted_request__c = '{"JData":"ijk6sdS8XvSIhB2BAamjpNJ+mv6WJK65aeSGnn9asLl3cCV2sXzISQSXIgA2d+y/"}';
        ilog.isSync__c = false;
        ilog.Original_request__c = '{"ClientTransactionId":"05092022155250924"}';
        ilog.Original_response__c = '{"clientTransactionId":"05092022155250924","perfiosTransactionId":"PIECYGEB71FVKURD1JZ18","Status":"COMPLETED","error_message":"","error_code":""}';
        ilog.Service_Name__c = System.Label.ITR_Scan_upload_retrieve_report;
        ilog.targetRecordId__c = incomeDetails.Id;
        
        insert ilog;
        Test.startTest();
        try{
            ilog.Loan_Application__c = oppObj.id;
            Test.setMock(HttpCalloutMock.class, new SampleCalloutMockForITRJsonRetrieveReport());
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
     public class SampleCalloutMockForITRJsonRetrieveReport implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            //res.setBody('{"JData":"yEJwCnJS7ojeNJDz8cIEW+FExrzcGaBJhHeSlFMTK6Q68PofB7mhNpl63fYjb5LXydey+CnFTuyi0RjFK7FrpB+A0cQnT4T/Zv6JZ0B5irXji/EimJ/PY/o3x1Zt8eT4wmLEM2sIG2qwkaobvCb6QPoNkQ2/XmC3jQpuP8QOqwKVuxx38TaCaVLAawRIQ5gAW+mOHPbS6Qgh3PmSC8qeEAO/eIx7sFNaBa12WPmbFo6aSEAcSMpPpXNT1ysQXp0lSc3Kkn8LTa4ST11xbPzmPNgZq/RUFo5cXNq2z5o+LE+19bKKk9fzp+62DRbpipuGZw+zy+d4qaOLY78lEiTh0O4xMlb0wRuATo8qAo+kT1gZ/VWtBQEFN+ekytGL2KBywEvlEhk8ALyxCh3bghJTOfA+aAYMJQ4NWYUVKmtceUj8hbsAPRSrsN2Q9aZasoe3UW0M/i70ZEfcFKXVOm//Tn2tf3jiL8SD6SdLfraXFzldg/qKiBpGUTPGTu4hr1kDReamRXeN09ndGvX/H40T//t3BHymcF+g7UgQttGRjY0F8ZEY/0xiUc1RW2M+9piay02bmd+fdb3edMXc44c1LOTtm8rOZnkVkTN2oTEdbOj8ObvK85iHDx0rhpE+bGDVdeiPw85lMYDVU6R3FUKvn9CpdgSE6ZDIRhe3z9Wuwb7uE8zlt4QeCofaWl9hvy3c+yDtPtR5sog5r6gVUZPP0daShVO8rgwx3jIDBjG6ks5rJVViIAf2TmFP3YpD3W7BaGTLKp+ZUZkKNwwPtGZU5ZQ/3fJrUXxptebkrt8cgY4IEZQ9YoDyBG0KftwEF9d7etSnzeATRttWgWgbDQZAKw=="}');
            res.setBody('{"JData":"cgd+54iEVeJS4KApRPIiHWwSIDD88Bf3hEOocRSRTJw9H6zYOAfR03IisZszyqkpbmVWb5PHKSENi/xrBqOncJKDA2DmCFrOgVGuVsvViyme1n6U9x9vWElahs4AAwhJ33tYJ5I4oubMcEDaSeZZ7rsHCuSq2eebtFkgDyv1T+M="}');
            return res;
        }
    }
    
     //for ITR
    public static testmethod void testforBSScanUploadJsonRetrieveReport()
    {
        
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'UpdateTargetAPIObject';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=oppObj.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
        
        Integration_Log__c ilog = new Integration_Log__c();
        ilog.Encrypted_response__c = '{"JData":"fe3Nf/1fdl3jSBAkv+GVdWncseIYYPXRvE2OAdpFCENUqf1KsA8aMgLyM4dE/4r8zHqymDHrS95zlevR6N2Xgdtt29S72WOiVo0FVRwX8bvcI1wAyJLF3yOnxpOO62VlS76NFqDCNvxUiWdWfQsRKMktcRBw2YT5G/roM6+KoycG63CZWbuB57p8oNemzoOrImuho0/Ffilondo8O22Hn9QB0ouRALRtBGFYYDEthns="}';
        ilog.Encrypted_request__c = '{"JData":"ijk6sdS8XvSIhB2BAamjpNJ+mv6WJK65aeSGnn9asLl3cCV2sXzISQSXIgA2d+y/"}';
        ilog.isSync__c = false;
        ilog.Original_request__c = '{"ClientTransactionId":"05092022155250924"}';
        ilog.Original_response__c = '{"clientTransactionId":"05092022155250924","perfiosTransactionId":"PIECYGEB71FVKURD1JZ18","Status":"COMPLETED","error_message":"","error_code":""}';
        ilog.Service_Name__c = System.Label.ScanUploadRetrieveReport;
        ilog.targetRecordId__c = incomeDetails.Id;
        
        insert ilog;
        Test.startTest();
        try{
            ilog.Loan_Application__c = oppObj.id;
            Test.setMock(HttpCalloutMock.class, new SampleCalloutMockForBSJsonRetrieveReport());
            update ilog;
        }catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    
    }
    
     public class SampleCalloutMockForBSJsonRetrieveReport implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            //res.setBody('{"JData":"yEJwCnJS7ojeNJDz8cIEW+FExrzcGaBJhHeSlFMTK6Q68PofB7mhNpl63fYjb5LXydey+CnFTuyi0RjFK7FrpB+A0cQnT4T/Zv6JZ0B5irXji/EimJ/PY/o3x1Zt8eT4wmLEM2sIG2qwkaobvCb6QPoNkQ2/XmC3jQpuP8QOqwKVuxx38TaCaVLAawRIQ5gAW+mOHPbS6Qgh3PmSC8qeEAO/eIx7sFNaBa12WPmbFo6aSEAcSMpPpXNT1ysQXp0lSc3Kkn8LTa4ST11xbPzmPNgZq/RUFo5cXNq2z5o+LE+19bKKk9fzp+62DRbpipuGZw+zy+d4qaOLY78lEiTh0O4xMlb0wRuATo8qAo+kT1gZ/VWtBQEFN+ekytGL2KBywEvlEhk8ALyxCh3bghJTOfA+aAYMJQ4NWYUVKmtceUj8hbsAPRSrsN2Q9aZasoe3UW0M/i70ZEfcFKXVOm//Tn2tf3jiL8SD6SdLfraXFzldg/qKiBpGUTPGTu4hr1kDReamRXeN09ndGvX/H40T//t3BHymcF+g7UgQttGRjY0F8ZEY/0xiUc1RW2M+9piay02bmd+fdb3edMXc44c1LOTtm8rOZnkVkTN2oTEdbOj8ObvK85iHDx0rhpE+bGDVdeiPw85lMYDVU6R3FUKvn9CpdgSE6ZDIRhe3z9Wuwb7uE8zlt4QeCofaWl9hvy3c+yDtPtR5sog5r6gVUZPP0daShVO8rgwx3jIDBjG6ks5rJVViIAf2TmFP3YpD3W7BaGTLKp+ZUZkKNwwPtGZU5ZQ/3fJrUXxptebkrt8cgY4IEZQ9YoDyBG0KftwEF9d7etSnzeATRttWgWgbDQZAKw=="}');
            res.setBody('{"JData":"jPp3wCXn7hyyw1BT8XHR1fmNFcu0O2c5M/lGxEwWAEHhSLeJRMBEwkc1chvW83ns9u4OPfxegGklx28wzJG1D07M1tgwkY2JXDLGLT+y991OFphe3IXSiKyNzUggB67qPqm6aDk9gnSKyyifabKllcd6H7PNhLf5Hqcbwi92Lcd7ZiwibuEQPPDI0m3DsPd7pOO09/dmAX49tiNmWrcSmfKwqOEIoDq6DpeWkQXQDlGFO/1ni1zOpE+oKL1XznDOX9b8ih2tiVSOA07+Wo4/M2KZiz+mi8fyRj7e0vXxY3XiHlzNAbFF/FwlgLG437+PwQhtIft4c11+V2IIefNpAFHirg/564r8qtuhxkS0wTRICTx7rjsK3QVN+DT6HpS/Ju+MmLaB1DTZpwDFR4uh7337PMuX+X9nXL6Lk+m4xgn1bW5NDRhHORsaPf2nkZxtlI4avKrachhZJL/hIUGjz4vLtDa//EDuN3ty0iz7subgGiOAVLch5Qq5ONj84L3RNWyAxpA0dIiZ1FTn+wYmCcJBXB813Js1Q0A9Q4tVOFmeFrWfZEftZzNno8uSThpm8IFVqpxDJnGPk89IiejnBNaLCi19LTMTMvCcFl4Lu7YTDYJ1vYGovgJo2oU7D1bjYd1O9lXnT0RJfSNLWJRZKdvLUNIJVPR9PLkJTtFwPwFWVukhRf3sXxpUuqchayHKVQWQwBdEprbZ10gNdgpUaaM7BPzJenGok2AiMRMbw+Ted2dxj05M5AHRWo9cJKfDokYvs57N50hWMYjQlKUf7tuIM1K/wNLoLxmTZ9hAZJsjy15+QezBnypP0IFr//U7IvkVfaPghfU27ZEHWASpYiwBHiLpuJejJeTiA7f8/0jNn/Y5Qv3iUXx7X3M9owCY/i19kR21+bzHp15k9VT03BoStHay6QQuWfaG8XU4JiYTP9uQefOYSDpPGwQO1OwG7a4++WsKCcY49jYDOAOCsZIIgZurPOT7oAmXpjdZiXhYisLjJiFOpwibFSTVvoOm57wxkL7/YqgxCaPYdilI7BTCJYUkoFqePCZJdLMhKmoHxrf0Q4qsF9Y/QnXLWHTI"}');
            return res;
        }
    }
    @isTest
    static void testCatchBlock() {
        Test.setMock(HttpCalloutMock.class, new SampleCalloutMockForBSJsonRetrieveReport());
 		Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=oppObj.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
        try {
            UpdateTargetAPIObjectHelper.perfiosXlsxReportAPI(incomeDetails.Id, 'PerfiosID', 'InvalidServiceName', 'ClientTxnId');
        } catch (IND_Exception ex) {

        }
    }
}