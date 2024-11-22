@isTest
private class DealerMasterAPITest {
@isTest
static void testGetDealerMaster() {
    // create test data
    D2C_BE_Master__c beMaster = new D2C_BE_Master__c(Pin_Code__c = 123456, BL_Code__c = 'BL123');
    insert beMaster;


    Benefi__c  benMaster = new Benefi__c (Name='Test Dealer', Beneficiary__c = 'DLR', Status_Flag__c = 'L', Used_Flag__c = 'N',Ben_code__c='Test123');
    insert benMaster;
    Bl_Code_Details__c blCodeDetails = new Bl_Code_Details__c(Bl_Code__c = 'BL123');
	insert blCodeDetails;
    Beneficiary_BlCode__c benBLCode = new Beneficiary_BlCode__c(Ben_code__c = benMaster.Id, BL_Code_Details__c = blCodeDetails.Id,Unique_Identifier__c='UQ123');
    insert benBLCode;
    Manufacturer__c manufacturer = new Manufacturer__c(Name ='Test', Manufacturer_code__c = '1234');
    insert manufacturer;
    Beneficiary_Manufacturer__c benManufacturer = new Beneficiary_Manufacturer__c(Beneficiary_Master__c = benMaster.Id, Manufacturer__c = manufacturer.Id,Unique_Identifier__c='UQ321');
    insert benManufacturer;
    Product2 superParentProduct = new Product2(Name = 'Passenger Vehicles',  Make_Code__c = 'test', Type__c = 'Make', Manufacturer__c = manufacturer.Id,External_Reference_Id__c='UQ1234');
    insert superParentProduct;
    Product2 parentProduct = new Product2(Name = 'Test Product',Parent_Product__c = superParentProduct.Id, Make_Code__c = 'test', Type__c = 'Make', Manufacturer__c = manufacturer.Id,External_Reference_Id__c = 'UQ12345');
    insert parentProduct;
	Product2 product = new Product2(Name = 'Test Product', Parent_Product__c = parentProduct.Id, Model_Code__c = 'test', Type__c = 'Model', Manufacturer__c = manufacturer.Id,External_Reference_Id__c = 'UQ123');
    insert product;    

    Opportunity opp = new Opportunity(Name = 'Test Opportunity', Vehicle_Type__c = 'New', Vehicle_Sub_Category__c = 'Test Category',StageName='Loan Initiation',CloseDate=Date.today());
    insert opp;

    // set up the request
    DealerMasterAPI.DealerDataRequest request = new DealerMasterAPI.DealerDataRequest();
    request.Loan_Application_Id = opp.Id;
    request.Model_Code = 'test';
    request.Product_Type = 'Passenger Vehicles';
    request.Pin_Code = '123456';

    // make the request
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/getDealers';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(request));
    RestContext.request = req;
    RestContext.response = res;
    List<DealerMasterAPI.DealerDataResponse> responseList = DealerMasterAPI.getDealerMaster();

    // verify the response
    System.assertEquals(1, responseList.size());
    DealerMasterAPI.DealerDataResponse response = responseList[0];
    System.assertEquals('Test Dealer', response.DealerName);
}
}