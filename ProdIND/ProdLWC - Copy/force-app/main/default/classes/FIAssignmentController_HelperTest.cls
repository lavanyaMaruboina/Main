@isTest
public class FIAssignmentController_HelperTest {
  @isTest
    public static void assignFITest(){
        try{
            Account ach1 = TestDataUtility.createTestAccount(true);
            
            Opportunity oph1 = TestDataUtility.createTestOpportunity(false);
            oph1.AccountId = ach1.Id;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert oph1;
            }
            
                 case cs2 = new case();
                 cs2.Loan_Application__c = oph1.Id;
                 cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs2.Status = 'Pending-Off Role Employee App';
                 cs2.Origin = 'Web';
                 cs2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 insert cs2; 
            
                 AccountTeamMember ath1 = new AccountTeamMember();
                 ath1.AccountId = ach1.Id;
		         ath1.TeamMemberRole = 'FI';
                 ath1.UserId = UserInfo.getUserId();
                 ath1.FI_Executive_Counter__c = 3;
                 insert ath1;
            
                 Test.startTest();
                      FIAssignmentController_Helper.assignFI(oph1);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void assignFITest1(){
        try{
            Account ach1 = TestDataUtility.createTestAccount(true);
            
            Opportunity oph1 = TestDataUtility.createTestOpportunity(false);
            oph1.AccountId = ach1.Id;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert oph1;
            }
            
                 case cs2 = new case();
                 cs2.Loan_Application__c = oph1.Id;
                 cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs2.Status = 'Pending-Off Role Employee App';
                 cs2.Origin = 'Web';
                 cs2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 insert cs2; 
            
                 Test.startTest();
                      FIAssignmentController_Helper.assignFI(oph1);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void assignFITest2(){
        try{
            Account ach1 = TestDataUtility.createTestAccount(true);
            
            Opportunity oph2 = TestDataUtility.createTestOpportunity(false);
            oph2.AccountId = ach1.Id;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert oph2;
            }
                 Test.startTest();
                      FIAssignmentController_Helper.assignFI(null);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLowestCounterFIExecutiveTest(){
        
        Map<Id, Decimal> userToCounter = new Map<Id, Decimal>();
        userToCounter.put(null,0);
        
        Test.startTest();
               FIAssignmentController_Helper.getLowestCounterFIExecutive(userToCounter);
        Test.stopTest();
    }
    
    @isTest
    public static void getLowestCounterFIExecutiveTest1(){
        Map<Id, Decimal> userMap = new Map<Id, Decimal>();
        userMap.put(UserInfo.getUserId(),2.00);
        
        Test.startTest();
             FIAssignmentController_Helper.getLowestCounterFIExecutive(userMap);
        Test.stopTest();
    }
    
    @isTest
    public static void assignFItoMOUserTest(){
        try{
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                opfv1.Vehicle_Type__c = 'New';
                opfv1.Product_Type__c = 'Two Wheeler';
                opfv1.OwnerId = UserInfo.getUserId();
                insert opfv1;
                
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                insert apfv1;
            
                 case cs2 = new case();
                 cs2.Loan_Application__c = opfv1.Id;
            //   cs2.OwnerId = opfv1.OwnerId;
                 cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs2.Status = 'Pending-Off Role Employee App';
                 cs2.Origin = 'Web';
                 cs2.Type = 'Office FI';
                 cs2.Status = 'FI-Unassigned';
                 cs2.Applicant__c = apfv1.Id;
                 insert cs2;
            
                 Test.startTest();
                      FIAssignmentController_Helper.assignFItoMOUser(opfv1);
                      FIAssignmentController_Helper.assignFItoMOUser(null);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}