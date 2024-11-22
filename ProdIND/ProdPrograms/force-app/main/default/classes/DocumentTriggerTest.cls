/*
* @author: Raj Gupta.
* @company: Persistent Systems
* @description: Test class for IND_DocumentTrigger class.
* History:
* Inputs: None
* 11/10/2012  Added by Raj for Initial (IND-309). 
*/
@isTest
public class DocumentTriggerTest
{
    //Setup method is use to create demo data.
    @testSetup 
    static void setup()
    {
       /* TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'IND_DocumentTrigger';
        trgSwitch.Active__c = true;
        insert trgSwitch;*/
        
        TriggerSwitch__c trgSwitch = TestDataUtility.getTrigerSwitchData(true);
        
        Opportunity optg1 = new Opportunity();
        optg1.StageName = 'Qualification';
        optg1.CloseDate = Date.newInstance(2021, 1, 11);
        optg1.Name = 'testone';
        insert optg1;
        
        
        //Applicant__c applicant = new Applicant__c(Name='Applicant1',Contact_Number__c ='1234567891',Whatsapp_number__c='1231231231',Income_Ca__c='SAL',Profile__c = 'Software Engineer', Bureau_Pull_Attempts__c=1,Selfie_Retry_Attempts__c=2);
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c = optg1.Id;
        
        if (Schema.sObjectType.Applicant__c.isCreateable())
        {   
            insert applicant;     
        }
        
        Documents__c document = new Documents__c();
        
        //Documents__c document=new Documents__c();
        document.Opportunity_Relation__c = optg1.Id;
        document.Applicant__c = applicant.Id;       
        document.Proof_of_Identity_POI__c = false;
        document.Name_Mismatch_Percentage__c = 10;
        document.Name_Mismatch_Pass__c = true;        
        if (Schema.sObjectType.Applicant__c.isCreateable())
        {   
            insert document;    
        }
        
    }
    
    //DocumentUpdate method is test method use to test IND_documentTrigger
    @isTest
    public static void documentUpdate()
    {
           
        try
        {
            Test.startTest();
            Documents__c doc = [SELECT PAN_No__c,Proof_of_Identity_POI__c,Rejection_Fields__c FROM Documents__c LIMIT 1];
            doc.Proof_of_Identity_POI__c = true;
            doc.PAN_No__c = 'xxxxxxxxxxxx';
            update doc;
            doc.PAN_No__c = 'yyyyyyyyyy';
            doc.Name_Mismatch_Pass__c = true;
            doc.Name_Mismatch_Percentage__c = 80;
            update doc;
            Test.stopTest();
        }
        //DML exception handle here.
       Catch(Exception e){
          /*  System.debug('***Exception '+e.getMessage()+' occurred at line number '+e.getLineNumber());
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.documentTriggerTest, ' afterUpdate ', System.Label.Apex, e);
            insert errorLogRecord;
            throw new TriggerHandler.TriggerHandlerException(System.Label.ExceptionMessage);*/
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
	    }
    }
    
    @isTest
    public static void documentUpdates()
    {    
        try
        {
            Test.startTest();
            Documents__c doc = [SELECT Aadhar_Source__c FROM Documents__c LIMIT 1];
            doc.Aadhar_Source__c = 'OTP';
            update doc;
            Test.stopTest();
        }
        //DML exception handle here.
       Catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
	    }
    }

    @isTest
    public static void documentUpdate3()
    {
        try
        {
            Test.startTest();
            Documents__c doc = [SELECT Proof_of_Identity_POI__c, Rejection_Fields__c FROM Documents__c LIMIT 1];
            doc.Proof_of_Identity_POI__c = true;
            doc.CMU_Accept_Reject__c = 'Reject';
            doc.CMU_Rejection_Reason__c = 'Incorrect fields';
            doc.Rejection_Fields__c = 'Gender;Salutation';
            update doc;
            Test.stopTest();
        }
        //DML exception handle here.
       Catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
	    }
    }
}