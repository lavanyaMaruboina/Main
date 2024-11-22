@isTest
public class CamForCarforCAMTest {
    @isTest
    public static void getCamRecTest(){
        
                Opportunity opgc1 = new Opportunity();
                opgc1.StageName = 'Qualification';
                opgc1.CloseDate = Date.newInstance(2021, 1, 11);
                opgc1.Name = 'testone';
                insert opgc1;
        
                Test.startTest();
                     CamForCarforCAM.getCamRec(opgc1.Id);
                Test.stopTest();
    }
    
     @isTest
    public static void getCamRecTest1(){
        
                Opportunity opgc2 = new Opportunity();
                opgc2.StageName = 'Qualification';
                opgc2.CloseDate = Date.newInstance(2021, 1, 11);
                opgc2.Name = 'testone';
                insert opgc2;
        
                Test.startTest();
                     CamForCarforCAM.getCamRec('test');
                Test.stopTest();
    }
    
    
}