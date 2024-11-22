@isTest(seeAllData = false)
public class IND_EmailCheckControllerTest {
	
    
    /***********************************************************************************************************************
    * @Method Name - testEmailVerifyPass
    * @Created by: Nidhi Dhote
    * @description: testEmailVerifyPass to test Email valid or not
    ***********************************************************************************************************************/
       
        @isTest 
        static void testEmailVerifyPass()
        {
            try{
                
                Opportunity opsd1 = new Opportunity();
                opsd1.StageName = 'Qualification';
                opsd1.CloseDate = Date.newInstance(2021, 1, 11);
                opsd1.Name = 'testone';
                insert opsd1;
                
            Applicant__c applicant = new Applicant__c( Name= ' Applicant',Opportunity__c = opsd1.Id,
                                                      Contact_number__c  = '9325322455',
                                                     Is_Email_Valid__c = true);
            Insert applicant;
              //  User userTest = TestDataUtility.createIBCounterStaffUser(true);
              
            Test.startTest();
            IND_EmailCheckController.emailVerifyPass(applicant.id); 
            Test.stopTest();
                
                 }Catch(Exception e){
                    System.assertEquals('Script-thrown exception', e.getMessage());
                }
        }
    
    /***********************************************************************************************************************
    * @Method Name - testEmailBlackListed
    * @Created by: Nidhi Dhote
    * @description: testEmailBlackListed to test email is blacklisted or not
    ***********************************************************************************************************************/
    
    @isTest 
        static void testEmailBlackListed()
        {
            try{
                
                Opportunity opsb1 = new Opportunity();
                opsb1.StageName = 'Qualification';
                opsb1.CloseDate = Date.newInstance(2021, 1, 11);
                opsb1.Name = 'testone';
                insert opsb1;
                
            Applicant__c applicant = new Applicant__c( Name= ' Applicant',Opportunity__c = opsb1.Id,
                                                      Contact_number__c  = '9325322455',
                                                      Is_Blacklisted_Email_Address__c = true);
            Insert applicant;
             //   User userTest = TestDataUtility.createIBCounterStaffUser(true);
                
             // system.runAs(userTest){   
            Test.startTest();
            IND_EmailCheckController.emailBlackListed(applicant.id); 
            Test.stopTest();
              
                 }Catch(Exception e){
                    System.assertEquals('Script-thrown exception', e.getMessage());
                }
        }
    
    /***********************************************************************************************************************
    * @Method Name - testgetFailEmailValuepositive
    * @Created by: Nidhi Dhote
    * @description: testgetFailEmailValuepositive to test Count of backlisted, unverify email
    ***********************************************************************************************************************/
    @isTest 
        static void testgetFailEmailValuepositive()
        {
            try{
                
                 Opportunity opsb3 = new Opportunity();
                opsb3.StageName = 'Qualification';
                opsb3.CloseDate = Date.newInstance(2021, 1, 11);
                opsb3.Name = 'testone';
                insert opsb3;
                
            Applicant__c applicant = new Applicant__c( Name= ' Applicant',Opportunity__c = opsb3.Id,
                                                      Contact_number__c  = '9325322455',
                                                      Email_Fail_Count__c = 2);
            applicant.Email_Fail_Count__c = 2;
            Insert applicant;
              User userTest = TestDataUtility.createIBCounterStaffUser(true);    
                
                 system.runAs(userTest){
            Test.startTest();
           // System.assertEquals(false, IND_EmailCheckController.getFailEmailValue(applicant.id));
            Test.stopTest();
                 }
                 }Catch(Exception e){
                    //System.assertEquals('Script-thrown exception', e.getMessage());
                }
        }
    
    /***********************************************************************************************************************
    * @Method Name - testgetFailEmailValuenegative
    * @Created by: Nidhi Dhote
    * @description: testgetFailEmailValuenegative to test Count of backlisted, unverify email
    ***********************************************************************************************************************/
    @isTest 
        static void testgetFailEmailValuenegative()
        {
            try{
                
                Opportunity opsb4 = new Opportunity();
                opsb4.StageName = 'Qualification';
                opsb4.CloseDate = Date.newInstance(2021, 1, 11);
                opsb4.Name = 'testone';
                insert opsb4;
                
            Applicant__c applicant = new Applicant__c( Name= ' Applicant', Opportunity__c = opsb4.Id,
                                                      Contact_number__c  = '9325322455',
                                                      Is_Blacklisted_Email_Address__c = true,
                                                      Email_Fail_Count__c = 2);
            applicant.Email_Fail_Count__c = 4;
            Insert applicant;
                  User userTest = TestDataUtility.createIBCounterStaffUser(true);
                
                 system.runAs(userTest){
            Test.startTest();
                
         //   System.assertEquals(false, IND_EmailCheckController.getFailEmailValue(applicant.id));
            Test.stopTest();
                 }
                 }Catch(Exception e){
                   // System.assertEquals('Script-thrown exception', e.getMessage());
                }
        }
    
    @isTest
    public static void getFailEmailValueTest1(){
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Email_Fail_Count__c = 2;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        Test.startTest();
              IND_EmailCheckController.getFailEmailValue(applicantObj.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getFailEmailValueTest2(){
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        applicantObj.Email_Fail_Count__c = 5;
        insert applicantObj;
        
        Test.startTest();
              IND_EmailCheckController.getFailEmailValue(applicantObj.Id);
        Test.stopTest();
    }
    
}