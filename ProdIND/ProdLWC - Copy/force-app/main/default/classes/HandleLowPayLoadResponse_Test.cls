/*
* @author: Santhosh Mothe
* @company: Persistent Systems
* @description: Test class for Trigger For HandleLowPayLoadResponse, HandleLowPayLoadResponseHelper class.
* History:
* Inputs: None
* 25/1/2022  Added by Santhosh . 
*/ 
@isTest 
public class HandleLowPayLoadResponse_Test {
    
    public static testmethod void testupdateforIntegrationLog()
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod456@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Test.startTest();
            TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
            trgSwitch.Name = 'HandleLowPayLoadResponse';
            trgSwitch.Active__c = true;
            insert trgSwitch;
            
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
            Low_Payload_Response__e lPay = new Low_Payload_Response__e();
            lPay.Response__c = '{"RequestId":"03102021204513966","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":22546137,"SolutionSetInstanceId":"cb894105-318c-4c0c-b5da-71b66366624b"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"Karthi","ApplicantMiddleName":"","ApplicantLastName":"M","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"},{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"}]},"Data":{"Response":{"RawResponse":{\"reports\":[{\"created_at\":\"2021-10-03T14:11:07Z\",\"documents\":[{\"id\":\"5f1fdef3-083a-4229-bb89-176c79fbb725\"}],\"href\":\"/v2/checks/ab579ec7-81d7-49ca-8fe7-f4764c87b957/reports/3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"id\":\"3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"name\":\"document\",\"properties\":{\"first_name\":\"KARTHI\",\"last_name\":\"M\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"BYOPK0288D\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1988-03-27\"},\"result\":\"consider\",\"status\":\"complete\",\"sub_result\":\"caution\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"image_integrity\":{\"result\":\"consider\",\"breakdown\":{\"conclusive_document_quality\":{\"result\":\"consider\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"consider\",\"obscured_data_points\":\"clear\"}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}}}},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"other\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":null,\"properties\":{}},\"fonts\":{\"result\":null,\"properties\":{}},\"security_features\":{\"result\":null,\"properties\":{}},\"template\":{\"result\":null,\"properties\":{}},\"picture_face_integrity\":{\"result\":null,\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}}}}}}]}}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"c17f1c3d-00f4-4cd2-b28a-50b541ebd85e"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"22546137"}}}';
            lPay.Reference_Id__c = '123456';
            lPay.SVC_Name__c = 'Document Report';
            
            Database.SaveResult sr = EventBus.publish(lPay);
            
            Test.stopTest();
            System.assertEquals(true, sr.isSuccess());
        }
    }  
}