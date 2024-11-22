@isTest
 public class IND_ValuationIDVCntrlTest {
    @isTest
     public static void loadVehicleDetailsDataTest(){
         try{
                Opportunity opks1 = TestDataUtility.createTestOpportunity(false);
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = TestDataUtility.createTestApplicant(false);
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.label.AadhaarCard;
                 insert dfks1;
             
                 Final_Term__c fgd3 = new Final_Term__c();
                 fgd3.CRM_IRR__c = 120;
                 fgd3.Loan_Application__c = opks1.Id;
                 fgd3.Holiday_period__c='30';
                 fgd3.EMI_Amount__c= 10000;
                 insert fgd3;
             
                 Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
                 vc2.Loan_Application__c = opks1.Id;
                 vc2.Base_Price__c = 100000.00;
                 vc2.Ben_Code__c = 'testveh';
                 insert vc2; 
             
                 Test.startTest();
                      IND_ValuationIDVCntrl.loadVehicleDetailsData(opks1.Id);
                 Test.stopTest();
         }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
         }
         
     }
     
     @isTest
     public static void checkValidationBeforeSubmitTest(){
         try{
             Opportunity opks1 = TestDataUtility.createTestOpportunity(false);
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = TestDataUtility.createTestApplicant(false);
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.ValuationReport;
                 insert dfks1;
             
                 Final_Term__c fgd3 = new Final_Term__c();
                 fgd3.CRM_IRR__c = 120;
                 fgd3.Loan_Application__c = opks1.Id;
                 fgd3.Holiday_period__c='30';
                 fgd3.EMI_Amount__c= 10000;
                 insert fgd3;
             
                 Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
                 vc2.Loan_Application__c = opks1.Id;
                 vc2.Base_Price__c = 100000.00;
                 vc2.Ben_Code__c = 'testveh';
                 vc2.Valuer_category__c = System.Label.Empanelled;
                 insert vc2; 
             
                  Test.startTest();
                        IND_ValuationIDVCntrl.checkValidationBeforeSubmit(opks1.Id,vc2.Id);
                  Test.stopTest();
         }catch(Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     
          @isTest
     public static void checkValidationBeforeSubmitTest1(){
         try{
             Opportunity opks1 = TestDataUtility.createTestOpportunity(false);
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = TestDataUtility.createTestApplicant(false);
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.RC_Document;
                 insert dfks1;
             
                 Final_Term__c fgd3 = new Final_Term__c();
                 fgd3.CRM_IRR__c = 120;
                 fgd3.Loan_Application__c = opks1.Id;
                 fgd3.Holiday_period__c='30';
                 fgd3.EMI_Amount__c= 10000;
                 insert fgd3;
             
                 Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
                 vc2.Loan_Application__c = opks1.Id;
                 vc2.Base_Price__c = 100000.00;
                 vc2.Ben_Code__c = 'testveh';
                 vc2.Valuer_category__c = System.Label.Empanelled;
                 insert vc2; 
             
                  Test.startTest();
                        IND_ValuationIDVCntrl.checkValidationBeforeSubmit(opks1.Id,vc2.Id);
                  Test.stopTest();
         }catch(Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     
      @isTest
     public static void checkValidationBeforeSubmitTest11(){
         try{
             Opportunity opks1 = TestDataUtility.createTestOpportunity(false);
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = TestDataUtility.createTestApplicant(false);
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.InsurancePolicy;
                 insert dfks1;
             
                 Final_Term__c fgd3 = new Final_Term__c();
                 fgd3.CRM_IRR__c = 120;
                 fgd3.Loan_Application__c = opks1.Id;
                 fgd3.Holiday_period__c='30';
                 fgd3.EMI_Amount__c= 10000;
                 insert fgd3;
             
                 Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
                 vc2.Loan_Application__c = opks1.Id;
                 vc2.Base_Price__c = 100000.00;
                 vc2.Ben_Code__c = 'testveh';
                 vc2.Valuer_category__c = System.Label.Empanelled;
                 insert vc2; 
             
                  Test.startTest();
                        IND_ValuationIDVCntrl.checkValidationBeforeSubmit(opks1.Id,vc2.Id);
                  Test.stopTest();
         }catch(Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     
               @isTest
     public static void checkValidationBeforeSubmitTest2(){
         try{
                Opportunity opks2 = TestDataUtility.createTestOpportunity(false);
                opks2.StageName = 'Qualification';
                opks2.CloseDate = Date.newInstance(2021, 1, 11);
                opks2.Name = 'testone';
                insert opks2;
              
                IND_ValuationIDVCntrl.VehicleDetailsWrapper vdw1 = new IND_ValuationIDVCntrl.VehicleDetailsWrapper();
                vdw1.status = 'testmsg';
                vdw1.message = 'no msg';
             
                 Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
                 vc2.Loan_Application__c = opks2.Id;
                 vc2.Base_Price__c = 100000.00;
                 vc2.Ben_Code__c = 'testveh';
                 vc2.Insurance_expiring_within_60_days__c = true;
                 insert vc2; 
             
                  Test.startTest();
                        IND_ValuationIDVCntrl.checkValidationBeforeSubmit(opks2.Id,vc2.Id);
                  Test.stopTest();
         }catch(Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     
     @isTest
     public static void checkValidationBeforeSubmitTest3(){
         try{
             Opportunity opks1 = TestDataUtility.createTestOpportunity(false);
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = TestDataUtility.createTestApplicant(false);
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.RC_Document;
                 insert dfks1;
             
                 Final_Term__c fgd3 = new Final_Term__c();
                 fgd3.CRM_IRR__c = 120;
                 fgd3.Loan_Application__c = opks1.Id;
                 fgd3.Holiday_period__c='30';
                 fgd3.EMI_Amount__c= 10000;
                 insert fgd3;
             
                 Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
                 vc2.Loan_Application__c = opks1.Id;
                 vc2.Base_Price__c = 100000.00;
                 vc2.Ben_Code__c = 'testveh';
             //    vc2.Valuer_category__c = System.Label.Empanelled;
                 vc2.Insurance_expiring_within_60_days__c = true;
                 insert vc2; 
             
                  Test.startTest();
                        IND_ValuationIDVCntrl.checkValidationBeforeSubmit(opks1.Id,vc2.Id);
                  Test.stopTest();
         }catch(Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     
     @isTest
     public static void checkValidationBeforeSubmitTest4(){
         try{
             Opportunity opks1 = TestDataUtility.createTestOpportunity(false);
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = TestDataUtility.createTestApplicant(false);
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.InsurancePolicy;
                 insert dfks1;
             
                 Final_Term__c fgd3 = new Final_Term__c();
                 fgd3.CRM_IRR__c = 120;
                 fgd3.Loan_Application__c = opks1.Id;
                 fgd3.Holiday_period__c='30';
                 fgd3.EMI_Amount__c= 10000;
                 insert fgd3;
             
                 Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
                 vc2.Loan_Application__c = opks1.Id;
                 vc2.Base_Price__c = 100000.00;
                 vc2.Ben_Code__c = 'testveh';
             //    vc2.Valuer_category__c = System.Label.Empanelled;
                 vc2.Insurance_expiring_within_60_days__c = false;
                 insert vc2; 
             
                  Test.startTest();
                        IND_ValuationIDVCntrl.checkValidationBeforeSubmit(opks1.Id,vc2.Id);
                  Test.stopTest();
         }catch(Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     
     @isTest
     public static void loadVehicleDetailsDataForTractorTest(){
         
         try{
         Opportunity opks3 = TestDataUtility.createTestOpportunity(false);
                opks3.StageName = 'Qualification';
                opks3.CloseDate = Date.newInstance(2021, 1, 12);
                opks3.Name = 'testone';
                insert opks3;
         
            Applicant__c apks1 = TestDataUtility.createTestApplicant(false);
                apks1.Opportunity__c = opks3.Id;
                apks1.Contact_number__c = '8743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks3.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.InsurancePolicy;
                 insert dfks1;
         
                 Final_Term__c fgd3 = new Final_Term__c();
                 fgd3.CRM_IRR__c = 120;
                 fgd3.Loan_Application__c = opks3.Id;
                 fgd3.Holiday_period__c='30';
                 fgd3.EMI_Amount__c= 10000;
                 insert fgd3;
         
         
                 Vehicle_Detail__c vc1 = new Vehicle_Detail__c();
                 vc1.Loan_Application__c = opks3.Id;
                 vc1.Base_Price__c = 100000.00;
                 vc1.Ben_Code__c = 'testveh';
                 vc1.Insurance_expiring_within_60_days__c = false;
                 insert vc1;
         
                  Test.startTest();
                        IND_ValuationIDVCntrl.loadVehicleDetailsDataForTractor(opks3.Id);
             Test.stopTest();
         }
         catch(Exception e){
              System.assertEquals('Script-thrown exception', e.getMessage());
         }
     }
     
}