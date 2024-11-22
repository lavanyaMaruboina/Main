@IsTest
public class MSILRestCalloutTest {
    static testMethod void testPut() {
        Test.startTest();
        Account a = new Account();
        a.BranchBLCode__c = 'TCA';
        a.name = 'MSILTest';
        insert a;
        Benefi__c bnf1 = new Benefi__c();
        bnf1.Ben_code__c = 'BEN003622';
        bnf1.Name = 'testBenefi';
        bnf1.Dealer_Code__c = 'testdealer';
        bnf1.Indusind_AcNo__c = '786767832788';
        bnf1.Beneficiary__c = 'DSM';
        bnf1.Status_Flag__c = 'L';
        insert bnf1;
        
        Product2 prd1 = new Product2();
        prd1.Name = 'prod1';
        prd1.Asset_Category__c = 'te';
        prd1.Type__c = 'Make';
        prd1.Make_Code__c = 'MARUTI';
        prd1.IsActive = true;
        prd1.External_Reference_Id__c = '58568568';
        insert prd1;
        
        Product2 prd2 = new Product2();
        prd2.Name = 'prod2';
        prd2.Asset_Category__c = 'te';
        prd2.Type__c = 'Model';
        prd2.Model_Code__c = 'P766';
        prd2.IsActive = true;
        prd2.External_Reference_Id__c = '58568567';
        insert prd2;
        
        Product2 prd3 = new Product2();
        prd3.Name = 'prod3';
        prd3.Asset_Category__c = 'te';
        prd3.Type__c = 'Variant';
        prd3.Variant_Code__c = 'MRWAGONR3';
        prd3.IsActive = true;
        prd3.External_Reference_Id__c = '585685689';
        insert prd3;
        
        User ld = new User();
        String myJSON = '{\"metaData\":{\"applicationInfo\":{\"IIModuleID\":\"DA0560138\",\"Lead_Sourced_Through\":\"Digital-MSIL-Custom\",\"agentId\":\"135509_MA\",\"agentBLCode\":\"TCA\"}},\"leadExistingRelationship\":{\"leadVehicleType\":\"N\",\"ExistingCustomerStatus\":\"No\",\"CustomerCode\":\"\",\"DealNumber\":\"\",\"CustomerDataJSON\":null,\"MakeCode\":\"MARUTI\",\"MakeName\":\"MARUTISUZUKIINDIALTD\",\"ModelCode\":\"P766\",\"ModelName\":\"MARUTIWAGONRBS6OLD\",\"ManufacturerCode\":\"M23\",\"Product\":\"C\",\"VariantCode\":\"MRWAGONR3\",\"VariantName\":\"MARUTIWAGONRLXI1.0LBSVI\"},\"leadDetails\":{\"TimeFrame\":\"1\",\"leadStatus\":\"\",\"Product\":\"C\",\"Make\":\"MARUTI\",\"FinanceAmount\":\"621924.0000\",\"Mobile\":\"9645475026\",\"Name\":\"PAULAROGYAM\",\"LeadSource\":\"Digi\",\"Model\":\"P766\",\"VariantCount\":\"1\",\"VehicleCount\":\"1\",\"Dealer\":\"BRDCARWORLDLTD\",\"MakeData\":{\"id\":\"\",\"make_code\":\"MARUTI\",\"make_name\":\"MARUTISUZUKIINDIALTD\",\"manufacturer_code\":\"M23\",\"model_code\":\"P766\",\"model_name\":\"MARUTIWAGONRBS6OLD\",\"product\":\"C\",\"variant_code\":\"MRWAGONR3\",\"variant_name\":\"MARUTIWAGONRLXI1.0LBSVI\"},\"ModelData\":{\"id\":\"\",\"make_code\":\"MARUTI\",\"make_name\":\"MARUTISUZUKIINDIALTD\",\"manufacturer_code\":\"M23\",\"model_code\":\"P766\",\"model_name\":\"MARUTIWAGONRBS6OLD\",\"product\":\"C\",\"variant_code\":\"MRWAGONR3\",\"variant_name\":\"MARUTIWAGONRLXI1.0LBSVI\"},\"DealerData\":{\"Ben_Name\":\"BRDCARWORLDLTD\",\"Ben_code\":\"BEN003622\",\"Beneficiary_Type\":\"\",\"Dealership_Nature\":\"\",\"GST_Number\":\"\",\"Product\":\"C\",\"Used_Flag\":\"\",\"bl_code\":\"ESA\",\"id\":\"\",\"manufacturer_code\":\"M23\"}},\"MSIL_UserData\":{\"Salutation\":\"Mr\",\"FirstName\":\"PAUL\",\"LastName\":\"AROGYAM\",\"Gender\":\"Male\",\"DateofBirth\":\"1974-03-16\",\"Profession\":\"Salaried\",\"employmentType\":\"\",\"CustomerQualification\":\"OTHE\",\"noOfDependents\":\"1\",\"PANNumber\":\"BNVPA8323B\",\"Mobile\":\"9645475026\",\"email\":\"paularogyam@gmail.com\",\"MaritalStatus\":\"MARRIED\",\"Payslip\":\"\",\"Curr_Resi_Address_Line_1\":\"Karumkudiyarhouse\",\"Curr_Resi_Address_Line_2\":\"Edanad\",\"Curr_Resi_City\":\"ANGAMALY\",\"Curr_Resi_Pin_code\":\"683580\",\"Curr_Resi_State\":\"KERALA\",\"YearsInResidence\":\"3\",\"Off_Address_Line_1\":\"Karumkudiyarhouse\",\"Off_Address_Line_2\":\"Edanad\",\"Off_City\":\"ANGAMALY\",\"Off_Pin_code\":\"683580\",\"Off_State\":\"KERALA\",\"FinanceROI\":\"10.4300\",\"FinanceVehicleTenor\":\"5\",\"Employee_Name\":\"MANUNJ\",\"Branch_Name\":\"ALWAYE_ESA\",\"Send_SMS_To\":\"9946244499\"}}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/msil-lead/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueof(myJSON);
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        MSILRestCallout.insertLoanApplication();
        Test.stopTest();
    }
}