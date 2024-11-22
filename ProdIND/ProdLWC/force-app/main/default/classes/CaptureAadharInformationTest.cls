@isTest
private class CaptureAadharInformationTest {

    @isTest
    static void testGetAadharDocument() {
        // Create test data
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            LeadSource = 'D2C'
        );
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Documents__c document = new Documents__c(
            Opportunity_Relation__c = opp.Id,
            Applicant__c = applicant.Id,
            Name = 'Test Document'
        );
        insert document;

        // Mock the incoming request
        CaptureAadharInformation.AadharRequest request = new CaptureAadharInformation.AadharRequest();
            request.loanApplicationId = opp.Id;
            request.applicantId = applicant.Id;
            request.aadharDocumentId = document.Id;
            request.aadharNumber = '123456789012';
            request.aadharVaultCode = 'TEST';
            request.aadharOTPorBiometric = true;
            request.FirstName = 'Test';
            request.LastName = 'Applicant';
	        request.customerImageBase64Data = 'testCustomerImage';
        	request.aadharBase64EncodedData = 'testAadhaar';

        String requestJSON = JSON.serialize(request);
        RestContext.request = new RestRequest();
        String encryptedResponse = IntegrationUtilities.getEncryptedRequest(requestJSON,System.Label.privateKey,System.Label.ivkey); 
        String jdataRequest = '"JData":';
        RestContext.request.requestBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
		RestResponse res = new RestResponse();
        RestContext.response= res;
        // Call the method
        Test.startTest();
        CaptureAadharInformation.getAadharDocument();
        Test.stopTest();

        // Verify the updates
        opp = [SELECT RE_KYC_Stage__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('PostInitialOffer', opp.RE_KYC_Stage__c);

        applicant = [SELECT Name, Aadhar_No__c, Aadhar_OTP_or_Biometric__c, Customer_First_Name__c, Customer_Last_Name__c FROM Applicant__c WHERE Id = :applicant.Id];
        System.assertEquals('Test Applicant', applicant.Name);
        System.assertEquals('123456789012', applicant.Aadhar_No__c);
        System.assertEquals(true, applicant.Aadhar_OTP_or_Biometric__c);
        System.assertEquals('Test', applicant.Customer_First_Name__c);
        System.assertEquals('Applicant', applicant.Customer_Last_Name__c);

        document = [SELECT Pre_Initial_Address__c, KYC_No__c, Aadhar_Vault_Code__c, KYC_name__c, First_Name__c, Last_Name__c FROM Documents__c WHERE Id = :document.Id];
        System.assertEquals(false, document.Pre_Initial_Address__c);
        System.assertEquals('123456789012', document.KYC_No__c);
        System.assertEquals('TEST', document.Aadhar_Vault_Code__c);
        System.assertEquals('Test Applicant', document.KYC_name__c);
        System.assertEquals('Test', document.First_Name__c);
        System.assertEquals('Applicant', document.Last_Name__c);
    }

}