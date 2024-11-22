@isTest
public class AgentWorkTriggerHandlerTest {
    @isTest
    public static void testOne1(){
        try{
        Test.startTest();
             AgentWorkTriggerHandler awt1 = new AgentWorkTriggerHandler();
             awt1.afterUpdate();
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }   
    }
}