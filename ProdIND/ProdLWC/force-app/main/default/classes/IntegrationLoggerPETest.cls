@isTest
public class IntegrationLoggerPETest {
	 @isTest
    static void testIntegrationLoggerPlatformEventTrigger() {
        // Start test context
        Test.startTest();
        
        // Create a list of platform events
        List<Integration_Logger_Event__e> events = new List<Integration_Logger_Event__e>();

        // Define a sample event with all necessary fields filled out
        Integration_Logger_Event__e sampleEvent1 = new Integration_Logger_Event__e(
            Request__c = 'Sample Request',
            Response__c = 'Sample Response',
            EncryptedRequest__c = 'Encrypted Request',
            EncryptedResponse__c = 'Encrypted Response',
            ServiceName__c = 'Sample Service',
            Request_Ext__c = 'Request Extension',
            Response_Ext__c = 'Response Extension',
            Status__c = 'Success'
        );
        
        events.add(sampleEvent1);

        // Insert platform events
        EventBus.publish(events);
        
        // End test context
        Test.stopTest();
       
    }
}