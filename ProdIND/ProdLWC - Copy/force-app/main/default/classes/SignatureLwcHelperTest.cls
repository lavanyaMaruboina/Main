@isTest
public class SignatureLwcHelperTest {
    @isTest
    public static void saveSignatureTest(){
        Opportunity ops1 = new Opportunity();
        ops1.StageName = 'Qualification';
        ops1.CloseDate = Date.newInstance(2021, 1, 11);
        ops1.Name = 'testone';
        insert ops1;
        
        Test.startTest();
            SignatureLwcHelper.saveSignature('testdata',ops1.Id);
        Test.stopTest();
    }
}