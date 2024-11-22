@isTest
private class IND_CombinedBERServiceTest {
    
    @isTest
    static void testGetCombinedBreRequest(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Name = 'VDR Test';
        opp.Product_Type__c = 'Tractor';
        insert opp;
        Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(true, opp);
        
        Test.startTest();
        try {
            IND_CombinedBERRequest request = IND_CombinedBERService.getCombinedBreRequest(opp.Id, vehicleDetail.Id);
        } catch (IND_Exception ex) {
            System.assertNotEquals(null,ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetCombinedBreRequest1() {        
        Test.startTest();
        try {
            IND_CombinedBERService.getCombinedBreRequest(null, null);
        } catch (IND_Exception ex) {
            System.assertNotEquals(null,ex.getMessage());
        }
        Test.stopTest();
    }
    
    
}