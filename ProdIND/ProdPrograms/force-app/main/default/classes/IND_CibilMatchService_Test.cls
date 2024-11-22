@isTest(SeeAllData=false)
public class IND_CibilMatchService_Test {
     @TestSetup
    public static void createTestData(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }        
        Applicant__c appl =new Applicant__c(Name='test',
                                           Contact_Number__c ='3232323232',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            Loan_amount__c = 50000,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
        appl.Opportunity__c=opp.id;
        insert appl;  
    }
    @IsTest
    public static void test_cibilMatchAsyncCallout(){
        Applicant__c app=[Select id from Applicant__c LIMIT 1];
        try{
        Test.startTest();
       	IND_CibilMatchService.cibilMatchAsyncCallout(app);
        Test.stopTest(); 
        }catch(Exception e){
               system.assertEquals('Script-thrown exception', e.getMessage());
            
    }
    }
    @IsTest
    public static void test_cibilMatchAsyncCallout1(){
        Applicant__c app=[Select id from Applicant__c LIMIT 1];
        try{
        Test.startTest();
       	IND_CibilMatchService.cibilMatchAsyncCallout(null);
        Test.stopTest(); 
        }catch(Exception e){
               system.assertEquals('Script-thrown exception', e.getMessage());
            
    }
    }
    
    
}