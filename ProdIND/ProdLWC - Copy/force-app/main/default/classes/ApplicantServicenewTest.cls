@isTest
public class ApplicantServicenewTest {
      @isTest
         public static void getApplicantsTest(){
             try{
                Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
                insert optg1;
                
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = optg1.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                insert apt1;
                
                 Documents__c dtg1 = new Documents__c();
                 dtg1.Applicant__c = apt1.Id;
                 dtg1.Opportunity_Relation__c = optg1.Id;
                 dtg1.Document_Type__c =  System.Label.AadhaarCard;
                 dtg1.Document_Side__c ='Back';
                 dtg1.Aadhar_Source__c = 'ScanAadhar';
                 dtg1.Addresss_Type__c = 'Current Residential Address';
                 insert dtg1;
                 
                 Test.startTest();
                       ApplicantService.getApplicants(optg1.Id);
                 Test.stopTest();
             }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
             }
      }
    
    @isTest
         public static void getApplicantsTest1(){
             try{
                Opportunity optg2 = new Opportunity();
                optg2.StageName = 'Qualification';
                optg2.CloseDate = Date.newInstance(2021, 1, 11);
                optg2.Name = 'testone';
                insert optg2;
                 
                 Test.startTest();
                       ApplicantService.getApplicants(optg2.Id);
                 Test.stopTest();
             }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
             }
                 
    }
    
     @isTest
    static void testUpdateConsentReceived() {
         TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
            trgSwitch.Name = 'ApplicantConsentTrigger';
            trgSwitch.Active__c = true;
            insert trgSwitch;
        // Create old applicants
        List<Applicant__c> oldApplicants = new List<Applicant__c>();
        List<Applicant__c> newApplicants = new List<Applicant__c>();
         Opportunity optg2 = new Opportunity();
                optg2.StageName = 'Qualification';
                optg2.CloseDate = Date.newInstance(2021, 1, 11);
                optg2.Name = 'testone';
                insert optg2;
       

        // Old applicant without any consent
        Applicant__c oldApplicant1 = new Applicant__c(Opportunity__c=optg2.Id,Consent_Sent__c = null, Application_Form_SMS_Sent__c = null, Insurance_Consent_OTP_Time__c = null,Insurance_Consent_Received__c = false,Application_Consent_Received__c= false,Consent_Received__c = false);
        insert oldApplicant1;
        
        Applicant__c newApp = new Applicant__c(Id=oldApplicant1.Id,Insurance_Consent_Received__c = true);
        update newApp;

        
    }
  
    @isTest
    public static void savePrimaryOfficeAddressTest(){
        try{
                Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
                insert optg1;
                
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = optg1.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                insert apt1;
        
        ApplicantService.ApplicantDetailsWrapper adw = new ApplicantService.ApplicantDetailsWrapper();
        adw.applicantId = apt1.Id;
        adw.name = 'testname';
        adw.street = 'teststreet';
        adw.addLine = 'testline';
        adw.pincode = '524315';
        adw.city = 'Hyderabad';
        adw.district = 'Hyderabad';
        adw.State = 'ap';
        adw.contactNumber = '9999966666';
            
        Income_Details__c inc1  = new Income_Details__c();
        inc1.Applicant__c = adw.applicantId;
        inc1.Primary_Income_Source__c = true;
        insert inc1;
        
        Test.startTest();
             ApplicantService.savePrimaryOfficeAddress(Json.serialize(adw));
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
    }
    
    @isTest
    public static void getEmployeeNameTest(){
        try{
                Opportunity optg2 = new Opportunity();
                optg2.StageName = 'Qualification';
                optg2.CloseDate = Date.newInstance(2021, 1, 11);
                optg2.Name = 'testone';
                insert optg2;
                
                Applicant__c apt2 = new Applicant__c();
                apt2.Opportunity__c = optg2.Id;
                apt2.Contact_number__c = '9743514830';
                apt2.Applicant_Type__c = 'Borrower';
                insert apt2;
            
                 Income_Details__c inc2 = new Income_Details__c();
                 inc2.Applicant__c = apt2.Id;
                 inc2.Primary_Income_Source__c = true;
                 insert inc2;
            
                  ApplicantService.getEmployeeName(apt2.Id);
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getEmployeeNameTest1(){
        try{
                Opportunity optg3 = new Opportunity();
                optg3.StageName = 'Qualification';
                optg3.CloseDate = Date.newInstance(2021, 1, 11);
                optg3.Name = 'testone';
                insert optg3;
            
                  ApplicantService.getEmployeeName(optg3.Id);
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void currentAddressCumOfficeCheckboxTest(){
        try{
                Opportunity optg3 = new Opportunity();
                optg3.StageName = 'Qualification';
                optg3.CloseDate = Date.newInstance(2021, 1, 11);
                optg3.Name = 'testone';
                insert optg3;
                
                Applicant__c apt3 = new Applicant__c();
                apt3.Opportunity__c = optg3.Id;
                apt3.Contact_number__c = '9743514830';
                apt3.Applicant_Type__c = 'Borrower';
                apt3.Is_this_current_residence_cum_office__c = true;
                insert apt3;
            
                Test.startTest();
                     ApplicantService.currentAddressCumOfficeCheckbox(apt3.Id);
                Test.stopTest();
            
        }catch(Exception e){
            
                System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}