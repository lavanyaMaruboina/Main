@isTest(SeeAllData=false)
// Test class for UpdateLeadsTowithdrawan Class.
public class UpdateLeadsTowithdrawanTest {
	@isTest
    public static void UpdateLeadsTowithdrawanTest1(){
        
      List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity optl1 = new Opportunity();
        optl1.StageName =     'Qualification';
        optl1.CloseDate = Date.newInstance(2021, 1, 11);
        optl1.Sanction_Date__c = null;
        optl1.Name = 'testone';
        listOpp.add(optl1);

        insert listOpp;  
        
       	Opportunity optl2 = new Opportunity();
        optl2.Id = listOpp[0].Id;
        optl2.StageName = System.Label.Withdrawn_Stage; 
        Date customCreatedDate = Date.today().addDays(-93);
        Test.setCreatedDate(optl1.Id,customCreatedDate);
        update optl2;
       
        
        Test.startTest();
            UpdateLeadsTowithdrawan obj  = new UpdateLeadsTowithdrawan();
            Database.executebatch(obj); 
          UpdateLeadsTowithdrawan utd1 = new UpdateLeadsTowithdrawan();
          string ud3 = '0 00 00 * * ?';
          Id jobId = System.schedule('LeadSeq', ud3, utd1);
        Test.stopTest();
    }
}