@isTest
public class CreateStage2_Test {
	 @isTest
    public static void fetchOppTest(){
           try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
           
                Test.startTest();
                     CreateStage2.fetchOpp();
               
                Test.stopTest();
        }catch(Exception e){
               system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}