@isTest
private class IND_VahanVehicleValuationResponseTest {

@isTest
    static void IND_VahanVehicleValuationResponseTest() {
        String jsonResponse = '{"content": [], "respDesc": "Success", "status": "200"}';
        Test.startTest();
         IND_VahanVehicleValuationResponse.parse(jsonResponse);
        Test.stopTest();
      
}}