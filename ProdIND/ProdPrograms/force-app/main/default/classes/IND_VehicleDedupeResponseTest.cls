@isTest
public class IND_VehicleDedupeResponseTest {


    
    @isTest
    public static void testParseMethod() {
        String jsonResponse = '{"response":{"status":"Success","respDesc":"The request was processed successfully","content":[{"Description":"Test Description","NOC_Number_as_per_DB":"NOC123","Proceed_Flag":"Y"}]}}';
        
        IND_VehicleDedupeResponse parsedResponse = IND_VehicleDedupeResponse.parse(jsonResponse);
        
        // Assertions to verify the values
        System.assertEquals('Success', parsedResponse.response.status, 'Parsed status should be Success');
        System.assertEquals('The request was processed successfully', parsedResponse.response.respDesc, 'Parsed response description should match');
        System.assertEquals(1, parsedResponse.response.content.size(), 'Parsed content size should be 1');
        System.assertEquals('Test Description', parsedResponse.response.content[0].Description, 'Parsed description should match');
        System.assertEquals('NOC123', parsedResponse.response.content[0].NOC_Number_as_per_DB, 'Parsed NOC Number should match');
        System.assertEquals('Y', parsedResponse.response.content[0].Proceed_Flag, 'Parsed Proceed Flag should be Y');
    }
}