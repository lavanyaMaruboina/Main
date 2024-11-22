@IsTest
public class IND_SmsConsentReminder_Test {
	@isTest
    public static void smsCallOutTest(){
           try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;

                List<Applicant__c> lstApl = new List<Applicant__c>();
		        
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = opgr1.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                insert apt1;
               
               lstApl.add(apt1);
               
               List<List<Applicant__c>> Apids= new List<List<Applicant__c>>();
             	Apids.add(lstApl);
               
               Test.startTest();
               			IND_SmsConsentReminder.smsCallOut(Apids);
               Test.stopTest();
                
        }catch(Exception e){
               system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
}