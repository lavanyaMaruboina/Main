@isTest
public class OpportunityHelperTest {
    @isTest
    public static void getOpportunityListTest(){
       
            
            Opportunity opp = TestDataUtility.createTestOpportunityForDeal(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
       List<Opportunity> op= OpportunityHelper.getOpportunityList();

    }
}