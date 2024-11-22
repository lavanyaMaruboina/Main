@isTest
public class loanEAgreementControllerTest 
{
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod2024@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            // Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp;                
            
            Opportunity opp2 = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp2.Sub_Stage__c = System.Label.Field_Investigation;
            opp2.Is_Mobile_Journey_Completed__c = true;
            opp2.Vehicle_Type__c = System.Label.used;
            opp2.Product_Type__c = System.Label.Tractor;
            opp2.Sanction_Status__c = System.Label.nonStp;
            insert opp2;      
            
            // Create Applicant__c
            Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant.Applicant_Type__c = 'Borrower';
            applicant.Customer_Qualification__c = 'B1';
            applicant.Marital_status__c = 'MARR';
            insert applicant;
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant1.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant1.Applicant_Type__c = System.Label.CoBorrower;
            applicant1.Customer_Qualification__c = 'B1';
            applicant1.Marital_status__c = 'MARR';
            insert applicant1;
            
            List<Deal_Number_Setting__c> settings = new List<Deal_Number_Setting__c>();
            settings.add(new Deal_Number_Setting__c(Name = 'Passenger Vehicles', MDNField1__c = 'AA', MDNField2__c = 1));
            settings.add(new Deal_Number_Setting__c(Name = 'Tractor', MDNField1__c = 'AA', MDNField2__c = 1));
            settings.add(new Deal_Number_Setting__c(Name = 'Two Wheeler', MDNField1__c = 'AA', MDNField2__c = 1));
            insert settings;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.Sub_Stage__c = 'Payment Request';
            insert dl;
            
            //Create Retry Count
            Retry_Count__c retryCount = new Retry_Count__c(Count__c = 3, Loan_Application_Id__c = opp.Id, 
                                                           Service_Name__c = 'Retry_Count', Applicant__c = applicant.Id, Applicant_Type__c = 'Borrower',
                                                           User_Id__c = UserInfo.getUserId(), Module__c = 'Test Module');         
            insert retryCount;
            
            //Create Loan Application Transaction History
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Name = 'Loan Agreement', 
                                                                                                             Screen__c = 'Loan Agreement',
                                                                                                             Module__c = 'Post Sanction Checks and Documentation',
                                                                                                             Submitted_Flag__c = false,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            // Create Loan agreement        
            Loan_Agreement__c la = new Loan_Agreement__c(e_agreement_Agreement_Signed_For_Borrowe__c = 'Yes', 
                                                         Loan_Application__c = opp.Id);
            insert la;
        }
    }
    
    @isTest
    public static void getLoanEAgreementDetailsTest(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c !=:System.Label.Tractor LIMIT 1];  
                Deal_Number__c dealNumber = [SELECT id from Deal_Number__c where Sub_Stage__c = 'Payment Request' LIMIT 1];
                Loan_Agreement__c loanAgreement = loanEAgreementController.getLoanEAgreementDetails(oppRec.Id, dealNumber.Id);
                //System.assertNotEquals(null, loanAgreement);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLoanEAgreementDetails2Test(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =: System.Label.Tractor LIMIT 1];  
                Deal_Number__c dealNumber = [SELECT id from Deal_Number__c where Sub_Stage__c = 'Payment Request' LIMIT 1];
                Loan_Agreement__c loanAgreement = loanEAgreementController.getLoanEAgreementDetails(oppRec.Id, dealNumber.Id);
                //System.assertNotEquals(null, loanAgreement);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLoanEAgreementDetailsNegativeTest(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =: System.Label.Tractor LIMIT 1];  
                Deal_Number__c dealNumber = [SELECT id from Deal_Number__c where Sub_Stage__c = 'Payment Request' LIMIT 1];
                Loan_Agreement__c loanAgreement = loanEAgreementController.getLoanEAgreementDetails('', dealNumber.Id);
                //System.assertNotEquals(null, loanAgreement);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getApplicantTest(){
        try
        {            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                list<Applicant__c> appList = loanEAgreementController.getApplicant(oppRec.Id);
                System.assertNotEquals(null, appList);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }   
    
    @isTest
    public static void getMaxTryCountTest(){
        try{
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Integer result = loanEAgreementController.getMaxTryCount();
                System.assertNotEquals(null, result);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];                        
                Boolean result1 = loanEAgreementController.checkRetryExhausted(appRec.Opportunity__c, 'Retry_Count', appRec.Id, 'Borrower', 'Test Module');
                System.assertNotEquals(false, result1);
                Boolean result2 = loanEAgreementController.checkRetryExhausted(null, 'Retry_Count', appRec.Id, 'Borrower', 'Test Module');
                System.assertNotEquals(true, result2);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void retryCountIncreaseTest1(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1]; 
                List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :appRec.Opportunity__c AND Applicant__c =: appRec.Id LIMIT 1];           
                retryCountList[0].Count__c = 1;
                update retryCountList;
                loanEAgreementController.retryCountIncrease(appRec.Opportunity__c, 'Retry_Count', appRec.Id, 'Borrower', 'Test Module');
                List<Retry_Count__c> updatedRetryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :appRec.Opportunity__c AND Applicant__c =: appRec.Id LIMIT 1]; 
                System.assertEquals(2, updatedRetryCountList[0].Count__c);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void retryCountIncreaseTest3(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1]; 
                List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :appRec.Opportunity__c AND Applicant__c =: appRec.Id LIMIT 1];           
                retryCountList[0].Count__c = 2;
                update retryCountList;
                loanEAgreementController.retryCountIncrease(appRec.Opportunity__c, 'Retry_Count', appRec.Id, 'Borrower', 'Test Module');
                List<Retry_Count__c> updatedRetryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :appRec.Opportunity__c AND Applicant__c =: appRec.Id LIMIT 1]; 
                System.assertEquals(3, updatedRetryCountList[0].Count__c);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void retryCountIncreaseTest2(){
        try{            
            Test.startTest();   
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];
                List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :appRec.Opportunity__c AND Applicant__c =: appRec.Id LIMIT 1];           
                delete retryCountList;
                loanEAgreementController.retryCountIncrease(appRec.Opportunity__c, 'Retry_Count', appRec.Id, 'Borrower', 'Test Module');
                List<Retry_Count__c> newRetryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :appRec.Opportunity__c AND Applicant__c =: appRec.Id LIMIT 1];           
            	System.assertNotEquals(null, newRetryCountList);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getSubmittedCheckTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =: System.Label.TwoWheeler LIMIT 1];
                Deal_Number__c dealNumber = [SELECT id from Deal_Number__c where Sub_Stage__c = 'Payment Request' LIMIT 1];
                Loan_Application_Transaction_History__c loanAPp = [SELECT Id FROM Loan_Application_Transaction_History__c LIMIT 1];
                loanAPp.Loan_Application_ID__c = oppRec.Id;
                loanAPp.Screen__c = System.Label.Loan_Agreement;
                loanAPp.Module__c = System.Label.Post_Sanction_Checks_and_Documentation;
                loanAPp.Deal_Number__c = dealNumber.Id;
                update loanAPp;
                Boolean result = loanEAgreementController.getSubmittedCheck(oppRec.Id, dealNumber.Id);
                //System.assertNotEquals(true, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }    
    
    @isTest
    public static void getInitiateAgreementDisableTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =: System.Label.Tractor LIMIT 1];  
                Deal_Number__c dealNumber = [SELECT id from Deal_Number__c where Sub_Stage__c = 'Payment Request' LIMIT 1];
                Boolean result = loanEAgreementController.getInitiateAgreementDisable(oppRec.Id, dealNumber.Id);
                System.assertEquals(false, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }  
    
    @isTest
    public static void getInitiateAgreementDisableNegativeTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =: System.Label.Tractor LIMIT 1];  
                Deal_Number__c dealNumber = [SELECT id from Deal_Number__c where Sub_Stage__c = 'Payment Request' LIMIT 1];
                Boolean result = loanEAgreementController.getInitiateAgreementDisable('', dealNumber.Id);
                System.assertEquals(false, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }  
    
    @isTest
    public static void getInitiateAgreementDisable2Test(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c !=: System.Label.Tractor LIMIT 1];  
                Deal_Number__c dealNumber = [SELECT id from Deal_Number__c where Sub_Stage__c = 'Payment Request' LIMIT 1];
                Boolean result = loanEAgreementController.getInitiateAgreementDisable(oppRec.Id, dealNumber.Id);
                System.assertNotEquals(false, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }  
    
    @isTest
    public static void updateLoanAppHistoryTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];                            
                Boolean result = loanEAgreementController.updateLoanAppHistory(oppRec.Id);
                System.assertNotEquals(false, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    public static void updateLoanAppHistoryTest2(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];                            
                List<Loan_Application_Transaction_History__c> latList = [Select id,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:oppRec.id];
                delete latList;
                Boolean result = loanEAgreementController.updateLoanAppHistory(oppRec.Id);
                System.assertNotEquals(true, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    public static void eAgreementValidateTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];                                        
                Boolean result = loanEAgreementController.eAgreementValidate(appRec.Opportunity__c); 
                System.assertNotEquals(false, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void eAgreementValidateTest2(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Loan_Agreement__c loanAgree = [Select Id,Loan_Application__c,e_agreement_Agreement_Signed_For_Co_Borr__c,e_agreement_Agreement_Signed_For_Borrowe__c From Loan_Agreement__c LIMIT 1];
                loanAgree.e_agreement_Agreement_Signed_For_Co_Borr__c = 'Yes';
                Update loanAgree;
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];                                        
                Boolean result = loanEAgreementController.eAgreementValidate(appRec.Opportunity__c); 
                System.assertNotEquals(false, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void eAgreementValidateTest1(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];  
                appRec.Applicant_Type__c = System.Label.CoBorrower;
                update appRec;
                Loan_Agreement__c agr = [Select id From Loan_Agreement__c Where Loan_Application__c =: appRec.Opportunity__c LIMIT 1];
                agr.e_agreement_Agreement_Signed_For_Co_Borr__c = 'Yes';
                update agr;
                Boolean result = loanEAgreementController.eAgreementValidate(appRec.Opportunity__c); 
                System.assertEquals(false, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}