@isTest
public class HandleHighPayLoadResponseTest {
    
    @isTest
    public static void verifyHandleHighPayLoadResponse(){
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        High_Payload_Response__e objNewEvent = new High_Payload_Response__e();
        objNewEvent.Reference_Id__c = opp.Id;
        objNewEvent.Response__c = JSON.serialize(opp);
        objNewEvent.Response_Ext__c = JSON.serialize(opp);
        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(new List<High_Payload_Response__e>{objNewEvent});
        Test.stopTest();
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            System.assert(sr.isSuccess());
        }
    }  
    
}