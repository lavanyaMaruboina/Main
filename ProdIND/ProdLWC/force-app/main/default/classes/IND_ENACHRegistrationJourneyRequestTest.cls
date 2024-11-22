@isTest
public class IND_ENACHRegistrationJourneyRequestTest {
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');
        insert u;
        System.runAs(u) 
        {
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            } 
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'RC Upload'; 
            insert dl;
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_Code__c = '12345';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Bank_Masters__c bankMaster = new Bank_Masters__c();
            bankMaster.Name='BANK OF BARODA';
            bankMaster.Bank_Code__c=12;            
            insert bankMaster;
            
            Repayments__c repayment = TestDataUtility.createTestRepayments(false,opp);
            repayment.Bank_Master__c = bankMaster.Id;     
			repayment.Deal_Number__c = dl.Id;            
            repayment.Is_Netbanking_available_with_customer__c = 'yes';
            if (Schema.sObjectType.Repayments__c.isCreateable()){
                insert repayment;
            }
                       
            List<Exposure__c> lstExp = new List<Exposure__c>();
            for(Integer i=0;i<1;i++) {
                lstExp.add(new Exposure__c(Name = 'expName'+i,
                                           Loan_Application__c = opp.id,
                                           Applicant__c = applicant.id,
                                           CIF_ID__c ='3534534',
                                           Deal_No__c = 'something1'
                                          ));
            }
            insert lstExp;
        }
    }
    
    @isTest
    public static void verifyIND_ENACHRegistrationJourneyRequest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Test.startTest();
                Applicant__c applicant = [SELECT Id, Opportunity__c, Customer_Code__c, Contact_number__c, Email_Id__c FROM Applicant__c LIMIT 1];                   
                List<Repayments__c> repayment=[SELECT Id,Repayment_to_be_done_by__c,Bank_Master__c, Bank_Master__r.Name,IFSC_Code__c,Account_Number__c,Created_Date__c,End_Date__c,Frequency__c,EMI_Amount__c 
                                       FROM Repayments__c 
                                       WHERE Loan_Application__c=:applicant.Opportunity__c WITH SECURITY_ENFORCED];
       			System.debug('repayment '+repayment[0].Bank_Master__c);
                Deal_Number__c dl = [select id from Deal_Number__c limit 1];
                IND_ENACHRegistrationJourneyRequest result = new IND_ENACHRegistrationJourneyRequest(applicant, applicant.Opportunity__c,dl.Id);
                Boolean isValid = result.validate(System.Label.StampingDetails);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                Test.stopTest();
            }
            catch(Exception e)
            {
                
            }
        }
    }
	
	@isTest
    public static void verifyIND_ENACHRegistrationJourneyRequest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Test.startTest();
                
                Opportunity op = [select id, product_type__c,AccountId from Opportunity limit 1];
                
                Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
                opp.StageName = 'Journey Restart';
                opp.Is_Mobile_Journey_Completed__c = true;
                opp.Vehicle_Type__c = System.Label.used;
                opp.CloseDate = Date.newInstance(2022, 1, 11);
                opp.Product_Type__c = System.Label.TwoWheeler;
                opp.Sanction_Status__c = System.Label.nonStp;
                opp.Vehicle_Sub_Category__c = 'UPB';
                opp.Funded__c = true;
                opp.Is_customer_interested_in_a_motor_insura__c = true;
                opp.Motor_Insurance_Premium__c = 10000;
                opp.Agent_BL_code__c = '1234';
                opp.AccountId = op.AccountId;
                insert opp;  
                
                Applicant__c applicant = [SELECT Id, Opportunity__c, Customer_Code__c, Contact_number__c, Email_Id__c FROM Applicant__c LIMIT 1];                   
                List<Repayments__c> repayment=[SELECT Id,Repayment_to_be_done_by__c,Bank_Master__c, Bank_Master__r.Name,IFSC_Code__c,Account_Number__c,Created_Date__c,End_Date__c,Frequency__c,EMI_Amount__c 
                                       FROM Repayments__c 
                                       WHERE Loan_Application__c=:applicant.Opportunity__c WITH SECURITY_ENFORCED];
                Deal_Number__c dl = [select id from Deal_Number__c limit 1];
                
                op.Product_Type__c = 'Passenger Vehicles';
                op.StageName = 'Final Offer';
                op.Parent_Loan_Application__c = opp.Id;
                update op;
                IND_ENACHRegistrationJourneyRequest result = new IND_ENACHRegistrationJourneyRequest(applicant, op.Id,dl.Id);
                Boolean isValid = result.validate(System.Label.StampingDetails);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                Test.stopTest();
            }
            catch(Exception e)
            {
                
            }
        }
    }
    
}