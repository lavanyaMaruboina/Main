@isTest
public class Ind_DelegateAuthRequestTest {
    
    @isTest
    public static void verifyInd_DelegateAuthRequest(){
        Ind_DelegateAuthRequest objInput = new Ind_DelegateAuthRequest('test@user.com', 'pass@123');     
        System.assert(objInput.User_Name == 'test@user.com');
        System.assert(objInput.Password == 'pass@123');
    }
    
    @isTest
    public static void validateTest(){
        Test.startTest();
             Ind_DelegateAuthRequest dr1 = new Ind_DelegateAuthRequest('test@user.com', 'pass@123');
             dr1.validate('test');
        Test.stopTest();
    }
    
}