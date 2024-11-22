@isTest
public class IND_LWC_FICasePageCntrlTest {
    @isTest
       public static void getFIRecordTest(){
           try{
               Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
               
            case cs2 = new case();
            cs2.Loan_Application__c = opp.Id;
            cs2.Applicant__c = app1.Id;
            cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs2.Status = 'Pending-Off Role Employee App';
            cs2.Origin = 'Web';
            insert cs2; 
            System.assert(cs2.Id!=NULL,'Not matched the condition') ;
      //  if(cs2.Id!=NULL){      
            Field_Investigation__c fiv2 = new Field_Investigation__c();
            fiv2.Case__c = cs2.Id;
            fiv2.Address_Line_1__c = 'testone';
            fiv2.Address_Line_2__c = 'testtwo';
            fiv2.City__c = 'Nellore';
            fiv2.Pin_Code__c = '524315';
            fiv2.State__c = 'Andhra Pradesh';
            fiv2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv2;
    //           }  
            Test.startTest();
                  IND_LWC_FICasePageCntrl.getFIRecord(cs2.Id);
                //IND_LWC_FICasePageCntrl.getFIRecord(null);
            Test.stopTest();
            
           }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
           }
           
           
       }
    
    @isTest
       public static void getFIRecordTest1(){
           try{       
            Test.startTest();
                IND_LWC_FICasePageCntrl.getFIRecord(null);
            Test.stopTest();
           }catch(Exception e){
         //      System.assertEquals('Script-thrown exception', e.getMessage());
           }}
  /*  
   @isTest
       public static void getFIRecordTest2(){
           try{
               Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
               
            case cs2 = new case();
            cs2.Loan_Application__c = '';
            cs2.Applicant__c ='';
           
            insert cs2; 
            System.assert(cs2.Id!=NULL,'Not matched the condition') ;
          
            List<Field_Investigation__c> fiList =new List<Field_Investigation__c>();
            Field_Investigation__c fiv2 = new Field_Investigation__c();
            fiv2.Case__c= cs2.Id;
            fiv2.Address_Line_1__c = '';
            fiv2.Address_Line_2__c = '';
            fiv2.City__c = '';
            fiv2.Pin_Code__c = '';
            fiv2.State__c = '';
            fiv2.RecordTypeId ='';
            insert fiv2;
   			//fiList.add('');
            System.assertEquals(0, fiList.size(), 'Not Empty');
           
            Test.startTest();
                  IND_LWC_FICasePageCntrl.getFIRecord(cs2.Id);
              //  IND_LWC_FICasePageCntrl.getFIRecord('');
            Test.stopTest();
            
           }catch(Exception e){
        //       System.assertEquals('Script-thrown exception', e.getMessage());
           }}
    */
}