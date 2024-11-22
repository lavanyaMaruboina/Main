@isTest
public class ParentAPIResponseTest {

      @isTest
    public static void verifyParentAPIResponse(){
        Account objNewAcc = new Account();
        objNewAcc.Name = 'Test Account';
        insert objNewAcc;
        System.assert(objNewAcc.Id != null);
        ParentAPIResponse objNewParenrtAPIResp = new ParentAPIResponse();
        objNewParenrtAPIResp.body = objNewAcc;
        System.assert(objNewParenrtAPIResp.body.get('Name') == 'Test Account');
    }
    
}