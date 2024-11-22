@isTest
private class Form60_API_ResponseParser_Test {

@isTest
    static void Form60_API_ResponseParser_Test() {
        String jsonResponse = '{"content": [], "respDesc": "Success", "status": "200"}';
        Test.startTest();
        Form60_API_ResponseParser result = Form60_API_ResponseParser.parse(jsonResponse);
        Test.stopTest();
    }}